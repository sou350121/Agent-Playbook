# Agent UI / Agent API 設計模式 (Agent UI & API Design Patterns)

> **來源**: Karpathy "Not Designing for Humans" 框架 + API 設計工程實踐
> **日期**: 2026-03-02
> **定位**: 當 Agent 成為軟體的一等用戶，API 和介面的設計規則需要從根本上重寫

**X-Ray 開場**

人類用戶可以理解模糊的錯誤信息、適應不一致的響應格式、並在出錯時重試。Agent 不行——它依賴結構化、可預測、冪等的介面。把為人類設計的 API 直接暴露給 Agent，是大多數 Agentic 系統集成失敗的根本原因。本文定義 Agent-friendly API 的設計模式，讓 Agent 作為一等消費者被服務。

> **哲學基礎**：`04-paradigm/not-designing-for-humans-paradigm.mdx` 提供範式討論。
> 本文提供工程落地：如何把「Agent 是一等用戶」這個信念翻譯成具體 API 設計決策。

---

## Human API vs Agent API 的差異

| 維度 | Human UI/API | Agent API |
|------|-------------|-----------|
| 錯誤信息 | 可讀的文字描述 | 機器可解析的結構化 error code + context |
| 響應格式 | HTML / 混合格式可接受 | 嚴格 JSON，schema 固定 |
| 冪等性 | 可選（重試有 UX 保護）| **必須**（Agent 會自動重試）|
| 分頁 | cursor 或 page number 皆可 | cursor-based 優先（確定性）|
| 認證 | Cookie / session 可接受 | API key 或 service token（無狀態）|
| 版本更新 | 可以逐步棄用（用戶會注意到）| 必須維持向後兼容或顯式版本控制 |
| 輸出冗餘 | 可以包含 UI 展示用的額外字段 | 最小化輸出，只含 Agent 需要的字段 |

---

## 設計模式

### 模式 1：JSON-First 響應

Agent 無法解析 HTML、Markdown 表格或混合格式。所有響應必須是嚴格 JSON。

**反例（Agent 無法可靠解析）**：
```
操作成功！你的訂單 #12345 已被處理，預計 3-5 個工作日送達。
```

**正例（Agent 友好）**：
```json
{
  "status": "success",
  "order_id": "12345",
  "estimated_delivery_days": {"min": 3, "max": 5},
  "tracking_available_at": "2026-03-05T00:00:00Z"
}
```

---

### 模式 2：結構化錯誤響應

Agent 需要根據錯誤類型決定下一步行動。錯誤信息必須機器可解析，包含 `code`（用於程序判斷）和 `message`（用於 Agent 理解）。

```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Rate limit reached: 100 requests/minute",
    "retry_after_seconds": 60,
    "quota_reset_at": "2026-03-02T11:00:00Z"
  }
}
```

**Error Code 設計原則**：
- `VALIDATION_ERROR` — 輸入格式錯誤，Agent 應修正參數重試
- `PERMISSION_DENIED` — 需升級至人工（不應自動重試）
- `RATE_LIMIT_EXCEEDED` — 等待 `retry_after_seconds` 後重試
- `RESOURCE_NOT_FOUND` — 不應重試，應報告給委派人
- `INTERNAL_ERROR` — 可重試一次，若仍失敗升級至人工

---

### 模式 3：冪等性設計

Agent 在網絡不穩定或超時時會自動重試。如果 API 非冪等，重試會造成重複副作用（重複創建訂單、重複發送郵件）。

**實現冪等性的兩種方式**：

**方式 A：Idempotency Key**
```http
POST /orders
Idempotency-Key: task-2026-03-02-001-order-attempt-1

{
  "product_id": "prod_123",
  "quantity": 2
}
```
服務端以 `Idempotency-Key` 去重，相同 key 的重複請求返回同一結果。

**方式 B：PUT 語義（替代 POST）**
```http
PUT /orders/task-2026-03-02-001
```
使用客戶端生成的 ID，天然冪等。

---

### 模式 4：Cursor-Based 分頁

Agent 需要遍歷列表時，cursor-based 分頁比 page-number 更可靠（不受中途數據變更影響）。

```json
{
  "items": [...],
  "pagination": {
    "cursor": "eyJpZCI6MTIzfQ==",
    "has_more": true,
    "next_url": "/items?cursor=eyJpZCI6MTIzfQ=="
  }
}
```

Agent 只需持續請求 `next_url` 直到 `has_more: false`，不需要計算頁數。

---

### 模式 5：Agent API 版本控制

Agent 不會主動升級——它使用的 API 版本必須長期穩定。

**版本策略**：

```
/v1/orders     ← 永遠可用，最少維護 2 年
/v2/orders     ← 新版本，新功能
```

**棄用流程**（對 Agent 消費者）：
1. 在響應 header 中提前 6 個月告警：`Deprecation: 2026-09-01`
2. 在 `v1` 響應中加入 `_migration_hint` 字段
3. 不依賴 Agent 自動察覺棄用通知（Agent 不讀文檔）

---

### 模式 6：Agent-Readable Schema

所有 API 應提供機器可讀的 schema（OpenAPI 3.0 / JSON Schema），並確保：

- `description` 字段使用 **動詞 + 名詞** 格式（Agent 更容易匹配意圖）
- enum 值附帶說明（Agent 需要知道每個值的含義）
- 必填字段顯式標記（Agent 不擅長推斷哪些字段必須提供）

```yaml
# 反例
parameters:
  - name: type
    enum: [A, B, C]

# 正例
parameters:
  - name: order_type
    description: "Order fulfillment type: 'standard' (3-5d), 'express' (1-2d), 'same_day' (requires metro area)"
    enum:
      - standard
      - express
      - same_day
```

---

## Agent UI 設計：雙層介面

對於有 UI 的應用，在「人類 UI」之上建立「Agent UI 層」：

```
用戶（人類）→ Human UI（視覺、交互、反饋）
Agent     → Agent API（JSON、冪等、結構化錯誤）
              ↓
         共享業務邏輯層
```

不要試圖讓 Agent 通過 Scraping 或模擬點擊操作人類 UI——這是最脆弱的集成方式。

---

## 失效模式

| 失效類型 | 症狀 | 修復方向 |
|---------|------|---------|
| 非結構化錯誤 | Agent 誤解錯誤含義，錯誤重試或放棄 | 標準化 error code 體系 |
| 非冪等 POST | 重試後產生重複副作用 | 引入 Idempotency Key |
| 不穩定 schema | Agent 解析失敗率升高 | 版本化 API，不在同版本中修改 schema |
| 缺少 `retry_after` | Agent 立即重試導致 rate limit 雪崩 | 所有限流錯誤必須包含等待時間 |
| 過度輸出 | Agent 被無關字段干擾，解析出錯 | 精簡響應，只返回必要字段 |

---

## 相關文章

- `04-paradigm/not-designing-for-humans-paradigm.mdx` — 哲學基礎：Agent 是一等用戶
- `02-agent-design/skill-vs-mcp-architecture.mdx` — 工具接入架構的更高層決策
- `03-engineering/02-logical-contracts.mdx` — API schema 約束作為邏輯護欄
- `03-engineering/agent-failure-taxonomy.mdx` — T3 API 契約誤讀的根本原因
