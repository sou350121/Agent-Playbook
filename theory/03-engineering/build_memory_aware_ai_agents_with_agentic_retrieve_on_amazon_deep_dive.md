---
auto_generated: true
generated_at: "2026-11-17T03:30:59Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/build-memory-aware-ai-agents-with-agentic-retrieve-on-amazon-bedrock-managed-knowledge-base/"
signal_type: "blog_post"
---
# 把「記憶」塞進檢索請求：Agentic Retrieve 如何一把接管長短期記憶 (Memory-Aware Agents with Agentic Retrieve on Bedrock Managed Knowledge Base)

> 🔍 本文由 Moltbot 自動生成 | 2026-11-17
>
> **項目/工具**: Amazon Bedrock Managed Knowledge Base + AgentCore Memory
> **連結**: https://aws.amazon.com/blogs/machine-learning/build-memory-aware-ai-agents-with-agentic-retrieve-on-amazon-bedrock-managed-knowledge-base/
> **核心定位**: 一個 `memoryConfiguration` 參數，把使用者長期記憶變成知識庫檢索的第三個資料源——應用層不再自己維護對話表、記憶抽取、事實注入。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：把 AgentCore Memory 註冊成 `AgenticRetrieveStream` 的檢索來源，讓 planner 自行決定「這一輪要不要撈使用者記憶」並用它改寫送往知識庫的子查詢。
- **現在值得用嗎**：是——前提是你已經（或願意）把知識庫放在 Amazon Bedrock Managed KB 上，且使用者隔離需求是「多租戶共用一個 KB」這種企業內訓／客服場景。
- **適合場景**：企業內部員工助理、SaaS 內的文件問答、客服 bot——同一個 KB 服務大量使用者，每個人只該看到自己有權限的文件，且需要記住「這個人上個月說過什麼」。
- **不適合場景**：自建向量庫（Pinecone/Weaviate/pgvector）已有成熟管線的團隊；拒絕綁定 AWS 的架構；單一使用者的工具型應用（記憶複雜度不值得）。
- **與「手刻記憶層」核心差異**：以前要自己做「存對話 → 抽事實 → 選事實 → 注入 prompt → ACL 過濾」五步，現在這五步壓縮成一個 API 欄位，且隔離由 IAM 兜底而非應用程式碼自律。

## 是什麼 / 解決什麼問題

知識庫型應用的使用者期待是兩件事，而不是一件：**答得準**，以及**記得我**。後者常被忽略——「我上個月說過我在法蘭克福辦公室的 Mac 上工作」這句話，如果沒有被記住，後面問「我的 PTO 怎麼算」時，回答就只能給通用版而不是個人化版。

問題在於：讓檢索變準的上下文，**住在知識庫外面**。使用者的地點、角色、產品等級，往往是在幾週前一段無關對話裡被順口提到的。要用它，應用程式必須：存下每一段對話 → 從中抽取持久事實 → 判斷哪些事實與當前問題相關 → 把它們注入請求。當一個應用服務成千上萬使用者時，上述每一步還得**逐一按使用者隔離**，文件權限也一樣。

這篇 AWS 官方 blog（2026-11-13）描述的解法，是把這四步全部上移到託管服務：

- **Amazon Bedrock Managed Knowledge Base** 負責攝取、ACL 過濾、索引、排序、規劃、檢索與生成
- **Amazon Bedrock AgentCore Memory** 負責儲存、保留期、加密與事實抽取
- 應用程式只保留真正屬於自己的部分：**驗證使用者身份，並把「他是誰」傳進去**

切換方式是 opt-in 且向後相容的：在 `AgenticRetrieveStream` 請求中加上 `memoryConfiguration`，AgentCore Memory 就成為與知識庫並列的檢索來源。根據官方說法，同一呼叫內會還原對話、由 planner 自行判斷「此刻關於使用者的事實是否有用」、從長期記憶撈出該事實、用它改寫送到知識庫的子查詢；生成答案後再把這一輪存回記憶。同一請求另帶 `userContext`，知識庫只回傳該使用者 ACL 允許的文件。

## 技術架構拆解

### 核心設計決策

- **記憶是「檢索來源」而非「prompt 拼接」**。傳統做法是先把記憶 dump 進 system prompt 再問一次模型；這裡改成 planner 在檢索階段就使用記憶改寫子查詢，等於讓記憶參與「怎麼找」而不是「怎麼答」。
- **身分雙軌制**。同一個請求裡有兩個識別碼做兩件事：`userContext.userId` 拿 ID token 的 **email**（因為資料源 ACL 用 email 記錄），`memoryConfiguration.sessionBinding.actorId` 拿 ID token 的 **sub**（因為記憶需要永不再分配給他人的穩定 ID）。官方明確點出理由：email 可以被更改，或在員工離職後被分配給新人，於是新人會繼承前人的記憶。
- **短期與長期記憶同一個資源**。STM（對話事件）與 LTR（抽取後的事實記錄）位於同一個 memory resource，靠 namespace 模板中的 `{actorId}` 在抽取時解析，達成「一個資源服務所有人、每個人天生隔離」。
- **兩個抽取策略並用**。`summaryMemoryStrategy` 抓「聊過什麼」（例如順口提到的「我在法蘭克福辦公室的 Mac」），`userPreferenceMemoryStrategy` 抽結構化的明確偏好（例如「偏好短條列、不要表格」「永遠先部署到 eu-central-1」）。官方原話：summary 給你「我們討論過什麼」，preference 給你「這個人想被怎麼回答」。
- **隔離由 IAM 兜底，不是靠程式碼自律**。應用後端為每個使用者 `sts:AssumeRole` 一次，帶上 `userId` session tag；IAM policy 用 `StringEquals: bedrock-agentcore:actorId == `{aws:PrincipalTag/userId}` 與 `StringLike: namespacePath == /anycompany/`{aws:PrincipalTag/userId}/*` 條件把記憶存取鎖死。這意味著即使應用程式碼忘了檢查，越權存取仍會被拒絕。
- **namespace 佈局是硬約束**。`retrievalConfigs` 只接受一筆，`namespacePath` 必須能一擊覆蓋該使用者所有該給 planner 看的記憶，所以 `{actorId}` 要直接掛在根下（`/anycompany/<sub>`），而不是分成 `/anycompany/profile/{actorId}` 與 `/anycompany/summaries/{actorId}`——後者會讓單一 entry 只能搆到其中一邊。

### 與前版／競品關鍵差異

| 維度 | 前版做法（自建對話表） | 本工具 |
|------|----------------------|--------|
| 對話儲存 | 應用自己建 table 存 history | 無對話表，UI 列表／重開直接讀 memory resource |
| 記憶抽取 | 自寫抽取邏輯或每次 LLM 摘要 | 服務按策略非同步抽取 LTR |
| 記憶注入 | 把記憶拼進 prompt | planner 在檢索階段挑選並改寫子查詢 |
| 使用者隔離 | 應用程式碼逐處過濾 | memory keying + IAM condition 雙層 |
| 文件權限 | 自行在檢索結果上過濾 | KB 內建 ACL 過濾（S3/SharePoint/Drive/Confluence） |
| 向量庫 | 需自備向量存儲 | 託管 KB 無需向量庫 |

官方說明這是對先前教學「Build multi-tenant agentic chat applications on enterprise data」的直接替代——**該篇的「persist conversation history yourself」步驟作廢**。

### 架構／資訊流圖

```
使用者 --Cognito 登入--> ID token (sub + verified email)
   |
   v
應用 handler: 驗證 token -> 讀 claims
   |   sub   -> actorId / namespace
   |   email -> userContext.userId (ACL)
   v
sts:AssumeRole (session tag userId=<sub>)
   |
   v
AgenticRetrieveStream(kb, userContext, memoryConfiguration)
   |
   +--> [5] 從 STM 還原該 actor+session 的對話歷史
   +--> [6] 依 userContext 做 ACL 過濾後檢索 KB
   |        同時 planner 決定是否撈 LTR（speculative 或 planner-selected search）
   +--> [7] 串流引用型答案 + trace 回傳
   +--> [8] persistenceMode=DEFAULT -> 存回本輪
                |
                v
        AgentCore Memory 非同步抽取 LTR（依策略）
```

## 實用評估

### 什麼場景值得用

- **多租戶共用一個 KB 的企業助理**：官方範例是 AnyCompany 的員工助理，11 份文件（HR／IT／工程 runbook／業務計畫）共用一個 KB，Maya、Liam 是工程師、Sofia 是業務，只有工程師能讀 runbook，只有業務能看佣金計畫。這正是「一個 KB + ACL file + 一個 memory resource」的最小可用形態。
- **既有 Bedrock Managed KB 專案的增量升級**：如果你的知識庫本來就建在 Managed KB 上（尤其已經跟著前篇 multi-tenant 教學做），這次整合就是替換一個步驟，而不是重構。
- **SaaS 內建文件問答**：每個租戶／終端使用者只該看到自己的文件，且需要記住其偏好（回答格式、部署區域習慣）。

### 什麼場景不值得用

- **自建檢索棧**：已經有 Pinecone / pgvector / Weaviate 管線的團隊，換過來等於把整個檢索層重寫，收益只在「記憶整合」一點，成本遠高。
- **單使用者工具**：記憶隔離的複雜度（IAM tag、namespace、雙 ID）在單人場景完全無意義。
- **強烈的地域／合規限制**：官方範例限定 US West (Oregon) `us-west-2`，且 memory resource 必須與 KB 同帳號、處於 ACTIVE 狀態。金融、醫療等有資料落地要求的場景需先確認可用區。
- **成本敏感的長尾應用**：每一輪都做 planner 決策 + 可能的 specular memory retrieval + 答案生成 + 非同步抽取，token 與記憶儲存成本疊加。官方沒有給出 benchmark 或單價對比——這是要自己 POC 才知道的部分。
- **想完全掌控檢索邏輯的團隊**：managed 服務意味著 planner 的行為是黑盒（只能從 trace 觀察），調參空間有限。

### 遷移成本

- **從前篇 multi-tenant 教學升級**：刪掉自建對話持久化層、改用 `memoryConfiguration`；新增一個 memory resource、兩個策略、一份含 IAM condition 的 policy。官方說法是「替換那一步」，實務上大概是**半天到兩天**級的改動（取決於 IAM 與 Cognito 的既有結構）。
- **注意不可逆設定**：`aclEnabled` 在 data source 建立後**不可更改**；Cognito user pool 的 email `Mutable: False` 也在建立後**不可更改**。這兩個決定必須在第一天做對，否則只能重建資源。
- **身分對接**：若使用者來自 Okta / Microsoft Entra ID，要把 IdP 的 email 映射到 Cognito 的 email 屬性，且必須與資料源 ACL 中記錄的 email 一致。

## 對你的意義

這是「**記憶層正在被平台化**」的一個明確訊號。過去一年 AI 應用工程的主戰場之一是「怎麼給 agent 加記憶」——Mem0、Zep、Letta 這類獨立記憶層服務，以及各家自己手刻的 RAG + profile store。AWS 這次的動作是把它變成 Bedrock KB 的一個參數。

對你的 RAG 工具鏈研究，值得記住的是三個設計取捨，它們大概率會被其他平台複製：

1. **記憶參與「檢索」而非「生成」**——這是與「把記憶塞 prompt」的根本分歧點，也決定了它能不能撐住長對話。
2. **兩個穩定 ID 分工**——email 給 ACL、sub 給記憶。這個細節很容易被忽略，但踩到就是資料串號。
3. **隔離下沉到 IAM**——把多租戶安全從「應用程式碼記得檢查」變成「基礎設施強制執行」，這是企業採購真正會問的問題。

建議：**觀望 + 小規模 POC**。如果你近期要做一個多租戶文件問答 demo，這條路徑能省掉大量膠水程式碼；但如果你手上已經有自建檢索棧，別為此搬遷。另外值得追的是這套 API 會不會被其他雲廠商對標——如果 Azure 與 GCP 跟進，記憶層的平台化就成了既定事實，獨立記憶層廠商的定位問題會變得很尖銳。

## 關鍵設定片段

建立帶 ACL 的資料源（重點在 `aclEnabled` 與 global ACL 檔）：

```python
ds = agent.create_data_source(
    knowledgeBaseId=kb["knowledgeBaseId"],
    name="s3-docs-acl",
    dataSourceConfiguration={
        "type": "MANAGED_KNOWLEDGE_BASE_CONNECTOR",
        "managedKnowledgeBaseConnectorConfiguration": {
            "connectorParameters": {
                "type": "S3",
                "version": "1",
                "connectionConfiguration": {"bucketName": BUCKET, "bucketOwnerAccountId": ACCOUNT_ID},
                "filterConfiguration": {"inclusionPrefixes": ["docs/"]},
                "aclEnabled": True,
                "aclConfiguration": {"globalAccessControlListS3Uri": f"s3://{BUCKET}/acl/global-acl.json"},
            }
        },
    },
)["dataSource"]
```

建立 memory resource（雙策略 + 根層 `{actorId}`）：

```python
memory = control.create_memory(
    name="anycompany_assistant_memory",
    eventExpiryDuration=30,  # 原始對話事件保留 30 天
    memoryStrategies=[
        {"userPreferenceMemoryStrategy": {
            "name": "EmployeeProfile",
            "namespaces": ["/anycompany/{actorId}/profile"],
        }},
        {"summaryMemoryStrategy": {
            "name": "ConversationSummaries",
            "namespaces": ["/anycompany/{actorId}/summaries/{sessionId}"],
        }},
    ],
)["memory"]
```

用 IAM 強制記憶隔離（即使應用程式碼出錯也擋得住）：

```json
{ "Sid": "MemoryRecordsScopedToCaller", "Effect": "Allow",
  "Action": ["bedrock-agentcore:RetrieveMemoryRecords", "bedrock-agentcore:ListMemoryRecords"],
  "Resource": "arn:aws:bedrock-agentcore:us-west-2:111122223333:memory/MEMORY_ID",
  "Condition": {"StringLike": {"bedrock-agentcore:namespacePath": "/anycompany/${aws:PrincipalTag/userId}/*"}} }
```

從 ID token 取兩個身分（只有 ID token 帶 email，access token 沒有）：

```python
def verify(id_token: str) -> Principal:
    key = jwks.get_signing_key_from_jwt(id_token)
    claims = jwt.decode(id_token, key.key, algorithms=["RS256"], issuer=ISSUER, audience=CLIENT_ID)
    if claims.get("token_use") != "id" or claims.get("email_verified") is not True:
        raise PermissionError("a verified ID token is required")
    return Principal(sub=claims["sub"], email=claims["email"].lower())
```

> TODO: 官方 blog 未提供記憶化檢索相對 baseline 的量化 benchmark（準確率／延遲／成本），若要做選型決策需自行 POC 量測。

> TODO: Boto3 版本要求為 1.43.72+、區域限定 us-west-2，其他區域可用性待確認。

---
[← Back to Deep Dives](./README.md)
