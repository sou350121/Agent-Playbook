# 06 — 前沿研究 (Frontier Research)

> 今天的前沿論文，是明天的工程基礎設施。
> 本模塊追蹤距離工程應用最近的前沿研究。

---

## 本模塊定位

不是所有前沿研究都值得立即跟進。本模塊的選文標準：
- **與 Agentic 系統直接相關**（不收純理論）
- **有可見的工程路徑**（不是「10年後也許有用」）
- **改變現有假設**（而不只是增量改進）

---

## 文章索引

| 文件 | 領域 | 工程相關性 | 核心突破 |
|------|------|-----------|---------|
| `1x-world-model-paradigm.mdx` | Embodied AI | High | 世界模型作為 Agent 規劃基礎的可行性 |
| `emu3-next-token-multimodal-world-model-route.mdx` | 多模態 | High | 統一 next-token 架構的世界模型路線 |
| `embodied-ai-economic-agents.mdx` | Embodied AI | High | 具身 AI 的經濟 Agent 設計框架 |
| `spatial-intelligence.mdx` | 多模態 | Medium | 空間智能：理解三維世界的下一步 |
| `bottleneck-data-selection-paradigm.mdx` | 訓練效率 | Medium | 瓶頸數據選擇：用更少數據達到更好效果 |
| `robotics-bootstrap-theory.mdx` | Robotics | Medium | 機器人自舉學習理論：從零到靈巧操作 |
| `intellifold2-open-source-biomolecular-foundation-model.mdx` | 生物分子 | Low* | 開源生物分子基礎模型的工程架構 |

\* _Low 不代表不重要，而是短期工程應用路徑不明確。_

---

## 與 Agentic 工程的連接

前沿研究對當前工程實踐的最直接影響：

1. **世界模型 → Agent 規劃**：Agent 不再只是「問答」，而是在模擬環境中預測行動結果
2. **多模態統一架構 → 工具多樣化**：Agent 可以同時處理文字、圖像、代碼，而不是多個專用模型
3. **瓶頸數據選擇 → 微調成本降低**：讓個人開發者也能負擔得起的領域適配

---

## 推薦閱讀時機

- **現在讀**：`1x-world-model-paradigm`、`emu3-next-token`（影響 Agentic 系統的架構選型）
- **季度追蹤**：`embodied-ai-economic-agents`、`spatial-intelligence`（Embodied AI 商業化進度）
- **年度回顧**：`robotics-bootstrap-theory`、`intellifold2`（長期基礎技術）

---

## 與 deep-dive/ 的關係

`deep-dive/` 是 Pulsar 每週自動生成的當週最強工程分析，其中許多話題源自本模塊的前沿研究。
當某篇前沿論文出現在 `deep-dive/` 時，說明它已進入「近期可用」的工程視野。
