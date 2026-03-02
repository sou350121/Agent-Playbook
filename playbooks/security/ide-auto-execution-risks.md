# 警報：IDE 自動執行配置導致的私鑰外洩 (IDE Auto-Execution Risks)

> **警告：** 仅仅是 `git clone` 並在 IDE (Cursor, VS Code) 中打開項目，就可能觸發惡意代碼執行並竊取你的私鑰。

---

## 1. 攻擊原理：被忽視的「自動化」

很多人誤以為不執行 `npm install` 或 `node index.js` 就是安全的。但在現代前端工具鏈中，IDE 為了提供型別分析、語法檢查和熱更新，會**自動加載**專案中的配置文件。

### 1.1 哪些文件是危險的？
以下文件本質上都是可執行的 JavaScript：
- `eslint.config.js` / `.eslintrc.js`
- `vite.config.js`
- `next.config.js`
- `prettier.config.js`
- `postcss.config.js`

### 1.2 攻擊路徑 (The Kill Chain)
1. **誘餌**：攻擊者發佈一個看起來很誘人的開源項目或在面試中讓你 Clone 一個 Repo。
2. **埋伏**：在 `vite.config.js` 中插入一段讀取 `~/.ssh/id_rsa` 並發送到遠端服務器的代碼。
3. **觸發**：你打開 IDE，IDE 掃描到 Vite 項目，啟動 Node.js 進程加載 `vite.config.js` 以準備環境。
4. **收割**：惡意代碼在後台靜默運行，你的私鑰在幾秒鐘內流出。

---

## 2. 為什麼 AI 掃描也可能失效？

雖然你在打開 IDE 前可以用 AI 掃描源碼，但有兩個問題：
1. **放鬆警惕**：看到是知名的配置文件，往往會掃一眼就過，忽略了混淆後的惡意代碼。
2. **掃描順序**：如果你習慣在 IDE 裡叫 AI 掃描，那麼在 AI 啟動前，IDE 的插件（ESLint/Vite）可能已經先一步執行了配置。

---

## 3. 防禦方案：構建「開發無塵室」

為了應對這種「配置即攻擊」，你必須改變你的開發習慣。

### 3.1 基礎防禦：不信任模式
- **VS Code "Trusted Workspaces"**：永遠不要在不信任的目錄中選擇 "Yes, I trust the authors"。這會限制大部分插件的自動執行。
- **Cursor 特定配置**：在打開陌生項目時，保持警惕，觀察是否有異常的網絡活動。

### 3.2 進階防禦：環境隔離 (Recommended)
- **Windows Sandbox**：最快速的隔離手段。開完即銷毀，適合快速看一眼代碼。
- **Docker + VS Code Remote Container**：讓 Node.js 和所有工具鏈跑在容器裡，即使中毒也只能拿到容器內的假數據。
- **專屬 VM (虛擬機)**：最穩健的隔離方式。為不信任的 Repo 準備一個獨立的 Linux VM，切斷與本地硬碟和網絡的直接橋接。

---

## 4. 核心洞見：安全的本質是「拒絕自動化」

在 Vibe Coding 時代，我們追求的是「極速自動化」。但安全要求我們在關鍵入口（代碼加載層）保留一份「手動審查」或「物理隔離」。

> **金句：** 
> 不要讓你的 IDE 成為攻擊者的遠端 Shell。一次性軟體需要一次性環境來保護你的持久化資產。

---

## 🔗 關聯閱讀
- [一次性軟體與邊緣推理範式](../../blog/2026-01-09-disposable-software-and-edge-inference.md)
- [Docker 專家級指南](../tools/docker-mastery-for-agents.md)
