# 01 — 底層原理 (Foundational Principles)

> 在動手之前，先弄清楚機器是怎麼「想」的。
> 這裡沒有框架，沒有工具推薦——只有讓你做出更好判斷的底層模型。

---

## 本模塊定位

AI 工程師最常犯的錯誤不是「用錯工具」，而是「對模型的心智模型是錯的」。
底層原理解決的就是這個問題：建立正確的認知基礎，讓你的每個設計決策都有根據。

---

## 文章索引

### 心智模型（先讀）

| 文件 | 核心問題 | 關鍵詞 |
|------|----------|--------|
| `agent-mental-model.md` | 工程師應如何把自己定位為「管理者」而非「程序員」？委派、成本意識、模塊化的底層邏輯 | delegation, cost, modularity |

### 模型基礎

| 文件 | 核心問題 | 關鍵詞 |
|------|----------|--------|
| `latent-space-reasoning.md` | 模型在「語義空間」中推理意味著什麼？ | embedding, latent space, reasoning |
| `bayesian-estimation-and-uncertainty.md` | 模型輸出的不確定性應如何量化與傳遞？ | uncertainty, calibration, probability |
| `independent-reasoning-and-proof-logic.md` | AI 能真正「推導」嗎？與模式匹配的邊界在哪？ | reasoning, proof, logic |
| `lofa-vs-rag-comparison.md` | Long-Context Fine-tuning 和 RAG 各自的實際邊界在哪裡？ | LOFA, RAG, context window |
| `hypernetworks-explained.md` | 動態生成權重的網絡如何提升泛化能力？ | hypernetwork, meta-learning |
| `manifold-hyper-connections-mhc.md` | 連接拓撲如何影響模型容量與泛化？ | manifold, connectivity, architecture |
| `waveformer-wave-equation-vision.md` | 將波動方程引入視覺架構的工程含義是什麼？ | waveformer, physics-informed |
| `jagged-intelligence-rlvr.md` | 強化學習驗證獎勵（RLVR）的能力分布為何參差不齊？ | RLVR, capability gap, benchmark |
| `alphaopt-self-improving-library.md` | 自我改進的代碼庫如何設計迭代閉環？ | self-improvement, code optimization |
| `post-scaling-research-age-playbook.md` | Scaling Law 觸頂後，下一個性能槓桿在哪裡？ | post-scaling, architecture, efficiency |

---

## 推薦閱讀順序

```
agent-mental-model              # 最先讀：建立工程師的管理者視角
    ↓
latent-space-reasoning          # 建立「空間思維」
    ↓
bayesian-estimation             # 理解不確定性的工程含義
    ↓
lofa-vs-rag-comparison          # 直接影響你的 Agentic 系統設計
    ↓
jagged-intelligence-rlvr        # 理解 Agent 能力的不均勻分布
    ↓
post-scaling-research-age       # 判斷未來投資方向
```

---

## 與其他模塊的關係

- **底層原理 → 02-agent-design**：理解 latent space 後，才能正確設計 memory retrieval 策略
- **底層原理 → 03-engineering**：理解 LOFA vs RAG 邊界後，才能選擇正確的 context 管理方案（見 `context-engineering-field-guide`）
- **底層原理 → 06-frontier**：本模塊是理解前沿研究的前提知識
- **`agent-mental-model`**：連接 01-principles（思維方式）與 02-agent-design（設計模式）的橋樑文章
