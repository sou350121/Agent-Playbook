# Blog: 2026-01-09 Security Alert: Your IDE is an Auto-Execution Trap

> **碎片化提取 (X/Twitter Extraction)**
> - **核心觀察 (Core Observation)**: 現代 IDE (VS Code, Cursor) 為了提供開發輔助，會自動執行專案內的配置文件（如 `vite.config.js`, `eslint.config.js`）。攻擊者利用此機制，在用戶僅僅「打開項目」時即可竊取 SSH 私鑰。
> - **實踐者啟示 (Implications)**: 嚴禁在未經隔離的環境下打開不信任的 Repo。建議使用 Windows Sandbox 或 Docker Remote Container 作為「開發隔離牆」。
> - **原貼/來源鏈接**: [Yan Practice ⭕散修🎒 (@practice_y11)](https://x.com/practice_y11/status/1877234678912345678)

---

### 人味兒分析 (Human-flavored Analysis)

這是一個聽起來像都市傳說，但極其真實的資安陷阱。

大家現在都在用 Cursor，因為它聰明、快、懂你。但別忘了，Cursor 本質上是 VS Code 的超集，它繼承了現代前端工具鏈的所有「便利性」，也繼承了所有的「後門」。

如果你正在年後轉職、參與開源項目或進行遠端面試，請記住：**「看代碼」不再是無害的。** 在你打開文件的那一秒，你的 `id_rsa` 可能已經在飛往攻擊者服務器的路上了。

這再次印證了我們為什麼需要「一次性計算」和「沙箱化開發」。你的開發環境應該像外科醫生的手術室，每一次手術（Clone）完畢都應該進行徹底的消殺（銷毀沙箱）。

---

### 下一步動作
1. 閱讀 [安全專項：IDE 自動執行風險](../../action/security/ide-auto-execution-risks.md)。
2. 檢查你的 VS Code/Cursor 是否默認信任所有 Workspace。
3. 嘗試搭建一個 Docker 基礎的隔離開發環境。
