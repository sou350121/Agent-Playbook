---
auto_generated: true
generated_at: "2026-09-25T12:40:54Z"
source_url: "https://agentexecutor.io"
signal_type: "significant_update"
---
# AX：把 Agent 当作新工作负载的声明式编排器 (AX: Declarative Orchestration for Agentic Workloads)

> 🔍 本文由 Moltbot 自动生成 | 2026-09-25
>
> **项目/工具**: AX (Agent Executor)
> **链接**: https://agentexecutor.io
> **核心定位**: 一个面向 agent 的声明式控制平面——把「有状态、突发、长时」的 agent 执行当成一等工作负载，用 YAML 声明 Task/Workspace，底层用 Agent Substrate 做沙箱隔离、网络围栏与亚秒级挂起/恢复。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：它是一套「agent 版 Kubernetes 控制平面」——用 4 個聲明式原語（task / workspace / network policy / model）管理大規模 agent 執行，解決傳統編排器「留著空閒 sandbox 太貴、又沒有原生亞秒恢復」的痛點。
- **現在值得用嗎**：**看場景**。下面這些場景值得立刻試：需要在一台叢集上跑極大量隔離沙箱的團隊；其他情況先觀望（項目仍是 `v1alpha1`，且能力聲稱尚待獨立驗證）。
- **適合場景**：大規模可重現 sandbox、agent 評測/RL 軌跡採集、長時掛起等模型/工具/人類回應的 coding agent。
- **不適合場景**：單機小腳本、不需要強隔離的簡單自動化、不願引入叢集運維的團隊。
- **與傳統編排器（K8s / batch）核心差異**：AX 假設工作負載**有狀態、會閒置**，因此原生做「檢查點 + 亞秒恢復」，而 K8s 假設無狀態服務、冷啟動常以秒計。

## 是什么 / 解决什么问题

官方對 agent 的定義一句話點題：**「agents are a new kind of workload」**——它們既不是微服務，也不是批處理任務。它們會累積狀態、需要嚴格隔離、會呼叫模型 API 與工具伺服器，而如果沒人盯著，又很容易白白浪費資源（例如一個 sandbox 卡在等模型回覆，卻持續佔著 CPU/RAM）。

傳統編排器在這裡會兩頭不討好。照官方說法：為無狀態微服務或可預測批處理設計的編排器，在「為了等一個 async 呼叫而讓空閒 sandbox 一直開著」時會**成本失控**，同時又**缺少原生的亞秒掛起與恢復**。於是你要嘛自己拼容器隔離與網路策略，要嘛接受大量空轉算力。

AX 的做法是把這件事抽象成聲明式的原語：開發者只描述「我要什麼樣的 workspace、要達成什麼 goal」，AX 負責把它沙箱化、接好工作區、圍住網路，並在叢集層面大規模編排。它建立在 **Agent Substrate** 之上——一個「從頭為高密度與快速有狀態 actor 生命週期設計」的運算執行時。

值得注意的是它的出身：AX 誕生於 **Google**，由 agentic runtime 研究與前沿運算團隊共同孵化，並大量採用 Google DeepMind 的 agentic runtime 研究成果。這也解釋了它為何把「隔離、恢復、排程」當作核心而非外掛。

## 技术架构拆解

### 核心设计决策

- **声明的 4 个最小原语**：官方明确「把 **tasks、workspaces、network policies、models** 抽象成核心原语」，開發者只寫 YAML，不碰底層隔離與排程。
- **工作負載模型 = actor**：每個 task 跑成一個輕量 actor，官方聲稱可「每叢集擴展到十億級並行 agent session，且不受編排器上限限制」（*此為官方宣稱，尚無獨立 benchmark 佐證*）。
- **掛起/恢復是一等公民**：閒置 agent（等模型、等工具、等人類回覆）會被 checkpoint、suspend，再在**不到一秒**內復原，聲稱「零冷啟動延遲」。
- **密集多工（dense multiplexing）**：數十個 task 共用同一批 worker 資源，把「等待時間」回收成可用算力——只在你真正思考/跑碼時付費。
- **Generative runtime**：把生成式能力內建進平台。例如你用自然語言描述環境，AX 會在任務啟動前先派一個 agent 把該環境裝好並驗證依賴。
- **建立在既有執行時之上**：AX 本身**重度依賴 Agent Substrate**，只在其上加「agentic 抽象 + 生成式執行時組件」，保持 runtime 極簡。

### 与传统编排器的关键差异

| 维度 | 传统编排器 (K8s / batch) | AX |
|------|--------------------------|-----|
| 工作负载假设 | 无状态微服务 / 可预测批处理 | 有状态、突发、长时 actor |
| 空闲成本 | 保留 idle sandbox 成本高 | checkpoint + suspend，闲置不占算力 |
| 恢复延迟 | 冷启动按秒~分钟计 | 官方称亚秒恢复、零冷启动 |
| 隔离方式 | 容器/命名空间，需自行拼装 | 内建 sandbox + 网络围栏 |
| 编排范式 | 命令式 / 模板堆叠 | 声明式 YAML（Task / Workspace） |
| 密度 | 常见为每集群数千 pod 量级 | 官方称十亿级 actor session（待验证） |

### 架构 / 信息流图

```
开发者
  │  ax apply -f task.yaml        (声明式 Task + Workspace)
  ▼
AX 控制平面 (declarative control plane)
  │  调度 · 生命周期 · 网络策略 · 模型绑定
  ▼
Agent Substrate 执行时 (actor runtime, 高密度有状态生命周期)
  │
  ├─ Actor A (task) ── sandbox ── /workspace ── 网络围栏
  ├─ Actor B (task) ── sandbox ── /workspace ── 网络围栏
  └─ Actor C (task) ── suspend(checkpoint) ⇄ resume(<1s)
        │
        └─ 呼叫 模型 API / 工具服务器
             （等待期间 = 可回收算力，密集多工复用）
```

控制平面的状态变更是可观察的：`ax watch` 会打印 `Phase: Pending → Running` 并附上 `Actor` 与 `WorkerIP`，说明这是**面向集群的调度视图**，而非单机进程管理。

## 实用评估

### 什么场景值得用

- **大规模可重現 sandbox**：需要 spinner 出「數以千計」可重現環境的團隊。官方明說這是 *perfect match for researchers*——採集軌跡、跑 RL 迴圈、規模化評測 agent。
- **長時間掛起的 agent**：coding agent、需要等人類批准（human-in-the-loop）、或等外部工具回應的工作流。suspend/resume 讓「等待」不再是成本。
- **需要嚴格隔離與網路圍欄的執行**：官方強調 sandbox + 網路 fencing 是預設行為，適合跑不受信任的生成程式碼。

### 什么场景不值得用

- **單機 / 小規模**：如果只需要跑幾個 agent，引入叢集與 Substrate 是過度工程。
- **不需要隔離的簡單自動化**：普通排程腳本用 cron / 普通隊列即可。
- **對穩定性有硬要求的生產系統**：`apiVersion: ax.io/v1alpha1` 表明 API 尚未凍結；且「十億級密度」「亞秒恢復」目前都是**官方宣稱**，缺獨立第三方 benchmark，建議先在小規模 PoC 驗證。
- **不願維護叢集底座**：AX 依賴 Agent Substrate，等於多一層需要理解、運維的元件。

### 迁移成本

- **从 Docker / 自建 code-exec sandbox 迁移**：要把原來的執行邏輯改寫成 `Task` + `Workspace` YAML，並配置 network policy 與 model 綁定；再熟悉 `ax apply / watch / ssh / suspend / resume / delete` 這套 CLI。中小規模大概是一到數天的改寫量，但真正的成本在於**理解 Substrate 的 actor 模型與調度語義**。
- **从 K8s 迁移**：思維要從「無狀態 pod」轉成「有狀態、可掛起的 actor」，網路策略與模型的抽象方式都不同；適合做增量試點，而非整體替換。

## 对你的意义

AX 同时踩中了 Ken 两条线的交叉点，值得单独标记：

- **AI 应用开发线（Agent + 工程实践）**：AX 是「把 agent 基础设施抽象成声明式控制平面」的一次认真尝试——和你在 `theory/03-engineering` 里追踪的 agent runtime / 编排方向高度吻合。它的 4 原语（task/workspace/network/model）提供了一个干净的**概念词汇表**，即使用户最终不用它，这套划分也值得借鉴到自己的 agent 平台设计里。
- **跨域信号（VLA 研究 × Agent 工程）**：官方明确把「collect trajectories、run RL loops、evaluate agents at scale」列为设计目标——这恰好是你 VLA 团队在做的**大规模仿真/轨迹采集 + RL 训练**那件事。也就是说，agent 工程与 VLA 研究在「可重現環境 + 規模化 rollout」上正在合流，这是一个值得持续追踪的交叉趋势。
- **建议**：**观望 + 小规模试用**。先别在生产依赖它（v1alpha1、能力声称待验证），但可以拿一個小的評測/RL 採集場景做 PoC，評估其 suspend/resume 與隔離在真實工作負載下的表現。留意是否有第三方 benchmark 出現。

## 关键代码/配置片段

以下片段直接來自官方站點，展示了聲明式工作流（Task 內引用 Workspace，用 goal 描述環境）：

```yaml
apiVersion: ax.io/v1alpha1
kind: Workspace
metadata:
  name: golang
spec:
  git:
  - repo: https://github.com/golang/go.git
    branch: "my-fix"
---
apiVersion: ax.io/v1alpha1
kind: Task
metadata:
  name: test
spec:
  workspaces:
  - name: golang
  goal: "Ensure that Go tool chain is available and is built from source"
  debug: true
```

對應 CLI 生命週期（官方示例逐字）：

```bash
$ ax apply -f task.yaml
workspace.ax.io/golang created
task.ax.io/test created

$ ax watch task test
[10:42:01] Phase: Pending  Actor: test  WorkerIP:
[10:42:05] Phase: Running  Actor: test  WorkerIP: 10.20.3.67

$ ax ssh test -- cd /workspace/go && go build ./...
$ ax ssh test -- touch notes.txt

$ ax suspend task test
task.ax.io/test suspended
$ ax resume task test
task.ax.io/test resumed
$ ax ssh test -- ls notes.txt
notes.txt          # 掛起/恢復後工作區狀態仍然保留
```

`notes.txt` 在 suspend→resume 後依然存在，這正是 AX 的核心賣點：**工作區狀態跨掛起週期持久化**。Generative workspace 則把環境準備也交給 agent：

```yaml
apiVersion: ax.io/v1alpha1
kind: Task
metadata:
  name: data-analysis
spec:
  workspaces:
  - name: python-env
    goal: "Set up a Python 3 development environment"
```

---
[← Back to Deep Dives](./README.md)
