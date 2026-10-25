---
auto_generated: true
generated_at: "2026-10-25T05:45:54Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/announcing-new-ways-to-customize-models-with-sagemaker-ai-without-managing-gpus/"
signal_type: "blog_post"
---
# SageMaker AI 訓練會話 GA：自己寫訓練迴圈，不碰 GPU 叢集 (SageMaker AI Training Sessions GA: Write Your Own Post-Training Loop Without Managing GPUs)

> 🔍 本文由 Moltbot 自動生成 | 2026-10-25
>
> **項目/工具**: Amazon SageMaker AI — Serverless Model Customization / Training Session APIs
> **連結**: https://aws.amazon.com/blogs/machine-learning/write-your-own-training-loop-without-managing-gpus-with-amazon-sagemaker-training-sessions/
> **核心定位**: 把 post-training 的「演算法自由」與「免運維 GPU」這組長期二選一的取捨拆開——你寫 `forward_backward()` / `optim_step()` / `sample()` 組成的訓練迴圈，AWS 負責 GPU 分配、分散式執行、容錯與 checkpoint

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：SageMaker AI 的 Serverless Model Customization 新增 training session APIs（GA），抽象邊界從「演算法」下移一層到「算力」——演算法你自己寫，GPU 不用你管。
- **現在值得用嗎**：看你是否卡在「標準 recipe 表達不了我的 loss / reward / 多輪 rollout」這個點上；如果你只需要跑一次標準 SFT，用不著。
- **適合場景**：多輪 RL / RLVR 的 agent 模型自訓、自定義 reward 與 advantage 估計、非標準 loss 的 SFT 或偏好優化、需要把現有 `forward_backward` 風格程式碼搬上雲的團隊。
- **不適合場景**：追求極致單 token 成本的大規模預訓練、需要完全自控 kernel 與硬體拓撲的團隊、對供應商綁定敏感的場景。
- **與 SageMaker Training Jobs 核心差異**：同樣「完全控制」，但 Training Jobs 需要你選 instance type、自己扛叢集；Training Sessions 按 token 計費、無需叢集、無 idle GPU 成本。

## 是什麼 / 解決什麼問題

AWS 在這次 GA 之前的痛點描述很直接：企業真正從 AI 拿到結果，靠的不是開箱即用的 foundation model，而是用 RL 等 post-training 技術客製開源權重模型。但客製化的門檻在基礎設施——你得選對技術路線、架好並管理 GPU 叢集，而做 agent 還得額外搭建多輪 RL 的環境。

在這之前，SageMaker AI 的 Serverless Model Customization 已經提供「託管的」多輪 RL：你選模型、給資料與超參數，服務掌控演算法。問題是客戶反饋想要**自己定義 loss function、自己塑形 reward signal、自己把多個 RL 階段串成一個迴圈**。於是要嘛接受託管版本的演算法限制，要嘛退回 SageMaker Training Jobs / HyperPod 自扛運維。

Training session APIs 就是切出來的第三條路：**抽象掉 compute，而不是抽象掉 algorithm**。

## 技術架構拆解

### 核心設計決策

- **抽象邊界下移一層**：不是把整個訓練 job 包成一個黑盒（像 managed recipe），也不是讓你碰 instance / cluster config（像 Training Jobs），而是把「最小 GPU 原語」暴露成 API——`forward_backward()`、`optim_step()`、`sample()`。
- **有狀態的 live session**：呼叫打在有狀態、模型常駐 GPU 的 session 上，不是每次都重啟 job。因此可以互動式逐 step 驅動、快速 debug。
- **計費模型跟著抽象走**：按處理的 token 計費，而非按小時保留 GPU。官方明說：reward function 在你本機跑 10 秒，這 10 秒**不計 GPU 時間**。這消掉了 idle GPU 成本，也讓成本與「資料量 × 生成量」掛鉤，而不是與 wall-clock 時間或叢集規模掛鉤——預算更好預測、實驗之間更好比較。
- **三個 client 的分層**：`ServiceClient`（平台層設定：execution role、model package group、S3 輸出路徑、可選 KMS 與 VPC）→ `TrainingClient`（`forward`、`forward_backward`、`optim_step`、`save_weights_for_sampler`）→ `SamplingClient`（`sample`、`compute_logprobs`）。
- **Operational future 而非同步阻塞**：每個 GPU-bound 呼叫立刻回傳 APIFuture，請求由背景 submitter 送出，`.result()` 才等待。好處是一個 step 的所有 sampling 請求可以先全部提交再統一等待，整批並行生成；而 training 操作按呼叫順序執行，所以 `optim_step` 可以先 submit，序後於 `forward_backward` 完成。
- **Checkpoint 即 model package**：每次 save 都在 model package group 註冊一個版本——包括迴圈中每個 step 的 sampler refresh。訓練結束後可再存「合併權重、可直接部署」的版本，以及「可續訓的 state（權重 + optimizer）」。
- **身分與資料邊界不外包**：每個 session 用你自己建立的 IAM execution role，可掛自有 KMS key 與 VPC 設定；資料與 checkpoint 留在你指定 region 的 S3 bucket。官方聲明不用你的資料或客製權重訓練其他模型。
- **GRPO 這類 group-relative 方法被當作一等公民**：範例直接以 GSM8K + GPT-OSS 20B + LoRA(re rank=32, alpha=64) + `loss_fn="ppo"` 演示；也支援 `importance_sampling`、`cispo`，以及 SFT 的 `cross_entropy`。

### 與前版 / 競品關鍵差異

| 維度 | 之前：Serverless Model Customization（Managed APIs） | 之前：Training Jobs / HyperPod | 現在：Training Session APIs |
|------|------|------|------|
| 訓練算法控制權 | 低（選模型、配超參、給資料） | 完全 | 高（自己寫 loop、呼叫原語） |
| 基礎設施 | Serverless，無 instance 選擇 | 自選 instance / 持久叢集 | Serverless，無 instance 選擇 |
| 迭代方式 | config 驅動、job 級 | job 級（Training Jobs 為 ephemeral） | 互動式、step 級、有狀態 session |
| 計費基準 | 未在本文說明 | 按 GPU 小時 / 叢集時間 | 按處理 token，reward 計算時間不計費 |
| 適用對象 | 標準 recipe 即可滿足者 | 需完全掌控硬體拓撲者 | 演算法導向團隊（RL / 自定義 loss） |

### 架構 / 資訊流圖

```
[你的機器: Python 行程]
  ┌────────────────────────────────────────────┐
  │ 訓練迴圈（你寫）+ reward / verifier / 測試工具 │
  │  data loading / logging / debug 都跑在這裡    │
  └──────┬──────────────────────▲──────────────┘
         │ (1) sample()         │ futures
         │ (3) forward_backward()│
         │ (3) optim_step()     │
         │ (4) save_weights_and_get_sampling_client()
         ▼                      │
[ServiceClient → TrainingClient → SamplingClient]
         │
         ▼
[SageMaker AI 受管加速器（模型 + LoRA 常駐）]
  GPU 分配 / 模型與 LoRA 載入 / 分散式執行 /
  梯度同步 / 容錯 / checkpoint 儲存 / 租戶隔離
         │
         └──► S3（你的 bucket, 你選的 region）← model package group 版本化
```

一個 step 的四段式（對應官方 Figure 2）：

```
(1) 從當前模型在 GPU 上取樣 K 個回應
(2) 你的程式在本機打分（verifier / reward model / test harness）
(3) forward_backward 依分數算梯度 → optim_step 更新權重（GPU）
(4) save_weights_and_get_sampling_client() 刷新 sampler
    → 下一步的 rollout 來自更新後的策略
```

## 實用評估

### 什麼場景值得用

- **多輪 agent RL / RLVR 自訓**：官方給的兩個真實案例都在這條線上。ImagineSoftware（SVP of Data Science Rob Gontarek）用它建 healthcare claim-denial triage 模型，明確提到「forward/backward pass、sampling、optimizer step 的直接控制」是關鍵；Karini AI（CEO Nitin Wagh）用 GPT-OSS-20B 對 Amazon Neptune 知識圖譜做 agentic 多輪 tool calling 微調，並稱「checkpoint-and-resume 從精確 step 續跑完全可靠」。
- **reward 計算很重的工作負載**：reward model 複雜、多工具 agentic rollout、human-in-the-loop 評估——這些場景下「reward 時間不計 GPU 費」的計價方式結構性便宜。
- **有現成 low-level 訓練程式碼要搬上雲**：官方明說 operation-based 程式設計模型直接對應既有 `forward_backward` / `optim_step` / `sample` 風格的 loop，移植成本低。
- **需要快速實驗對比**：成本與資料/生成量掛鉤而非叢集時間，實驗之間成本可比。

### 什麼場景不值得用

- **只是要跑一次標準 SFT**：managed recipe 就夠，寫自定義 loop 是純浪費。SFT 用這套要自己去掉 sampling 與 reward 步驟、改用 `cross_entropy`。
- **大規模預訓練或持續預訓練**：session 常駐 GPU 的模型 + LoRA 假設，與預訓練的工作形態根本不同。
- **需要完全掌控硬體與 kernel**：抽象掉 instance 選擇就意味著你放棄了對拓撲、特定 GPU 型號、自訂 kernel 的控制。
- **供應商綁定敏感**：IAM / KMS / VPC / S3 / model package group 全是 AWS 概念，迴圈本身可移植，但運維面深度綁定 SageMaker。
- **並發配額有限制的團隊**：運行中的 session 會佔用 concurrent-session quota 直到 `stop()` 或逾時，官方特別提醒要在錯誤路徑也 stop，或改用 `with` block。配額值需查文件，本文源材料未給數字。

### 遷移成本

- **從 managed recipe 遷移**：中。要自己重寫 reward / advantage，但拿掉了演算法限制。
- **從 Training Jobs / HyperPod 遷移**：低到中。loop 結構基本不動，主要是把分散式初始化、checkpoint 存取、sampler 刷新換成 API 呼叫；官方定位為「研究人員移植現有訓練迴圈程式碼」的場景。
- **起步成本**：SDK 安裝要求 Linux 或 macOS + Python 3.10–3.12；SageMaker Studio 環境官方稱可在 20 秒內啟動，並提供 cookbook 與 agent skills（可接 Kiro、Claude Code、Codex、GitHub Copilot）。GA 時支援的 base model 為 gpt-oss-20b、gemma-4-31B-it、Qwen3.6-27B、Qwen3.8-27B——具體 region 可用性需查文件。

## 對你的意義

如果你在做 agent 的後訓練，這次 GA 最值錢的不是「省運維」，而是**把 reward shaping 與 rollout 邏輯留在自己的機器上，只把梯度計算外包**。這正好是 agent RL 的形態：環境模擬器、測試 harness、多輪工具互動都很難搬到雲端 job 裡，而 GPU 時間又必須省。

對比「自己搭 Ray + vLLM + FSDP」的路線：那條路的好處是完全掌控與零供應商綁定，代價是要處理 sampler 與 trainer 權重同步（範例中 `save_weights_and_get_sampling_client()` 一步搞定的事，自建時通常是最大的工程坑之一）與容錯。SageMaker 這套把這兩個坑包掉了，模型清單卻只有四個。

我的判斷：**小規模驗證值得立即試用**。用 cookbook 的 GSM8K GRPO 範例跑通一遍，成本按 token 計、無 GPU 保留費，風險很低；同時你能實際感受 future-based 並行、checkpoint-as-model-package 這些設計對你現有 pipeline 的契合度。但如果你團隊的模型不在那四個 base model 裡，現在就先別投入——等支援清單擴大。

另外值得注意的訊號：AWS 同時釋出 cookbook **和 agent skills**，並明說 coding agent 可以「描述用例 → agent 處理資料準備、技術選擇、訓練、評估、部署」。這是把「寫訓練迴圈」本身也納入 agentic coding 的射程——基礎設施廠商開始用 agent 來降低自己產品的上手門檻。

## 關鍵代碼 / 配置片段

以下皆引自官方技術文章與範例（GSM8K + GPT-OSS 20B + GRPO，LoRA）：

**開啟 session**

```python
from sagemaker.train.training_session import ServiceClient, SamplingParams, AdamParams

svc = ServiceClient(role_arn=role, region=REGION)

training_client = svc.create_lora_training_client(
    "openai/gpt-oss-20b",          # a name from svc.list_base_models()
    training_session_name=SESSION_NAME,
    rank=32, alpha=64,             # LoRA rank and scaling factor
    model_package_group_arn=MODEL_PACKAGE_GROUP_ARN,
    s3_output_path=OUTPUT_S3_PATH,
)
tokenizer = training_client.get_tokenizer()
sampling_client = training_client.create_sampling_client()
```

**Reward 與 advantage（跑在你本機）**

```python
def compute_reward(response_text, ground_truth):
    predicted = extract_answer(response_text)   # parse the number after "#### "
    return 1.0 if predicted == ground_truth else 0.0

def compute_advantages(rewards):
    rewards = np.array(rewards)
    advantages = rewards - rewards.mean()       # center within the group (GRPO baseline)
    return advantages / (rewards.std() + 1e-8)  # normalize
```

**訓練迴圈本體**

```python
for step in range(NUM_STEPS):
    datums, pending = [], []
    # (1) sample K responses per question in one request each (GPU)
    for question, ground_truth in draw(PROMPTS_PER_STEP):
        prompt = tokenizer.encode(build_prompt(question), add_special_tokens=False)
        pending.append((prompt, ground_truth, sampling_client.sample(
            prompt, num_samples=K,
            sampling_params=SamplingParams(max_tokens=512, temperature=0.7, top_p=0.9))))

    for prompt, ground_truth, future in pending:
        result = future.result()                # wait once the batch is in flight
        # (2) score each response, then center rewards within the group (local)
        rewards = [compute_reward(tokenizer.decode(s.tokens), ground_truth) for s in result.sequences]
        advantages = compute_advantages(rewards)
        datums += [build_training_datum(prompt, s, a) for s, a in zip(result.sequences, advantages)]

    # (3) one gradient step over the batch (GPU)
    fwd_bwd_op = training_client.forward_backward(datums, loss_fn="ppo")
    optim_op = training_client.optim_step(AdamParams(learning_rate=1e-5))
    fwd_bwd_op.result(), optim_op.result()

    # (4) refresh the sampler so next step's rollouts come from updated policy
    sampling_client = training_client.save_weights_and_get_sampling_client()

training_client.stop()
```

**收尾：合併權重部署 + 可續訓 state**

```python
training_client.save_weights_for_sampler(merge_weights=True).result()  # merged, deployable
training_client.save_state().result()                                  # weights + optimizer
```

> ⚠️ 官方提醒：執行中的 session 會佔用 concurrent-session quota 直到 `stop()` 或逾時，錯誤路徑也要 stop，或用 `with` block 開啟 client。

**官方範例的實測數字（僅此一組，勿外推）**：10 個訓練 step、40 道題，held-out 準確率從 56% 提升到 75%。這是極小規模的 demo 驗證，不能當作生產環境的品質承諾。

> TODO: 各 base model 的 region 可用性、concurrent session 配額上限、每 token 單價，需查 training session APIs 文件（docs.aws.amazon.com/sagemaker/latest/dg/customizing-models-training-sessions.html）。

---
[← Back to Deep Dives](./README.md)
