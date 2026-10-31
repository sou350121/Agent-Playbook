🤖 AI 每日精选 | 2026-10-31

🔥 头条
- OpenAI 新版 Model Spec：AI 不得阻挠人类关停，适用范围扩到 agent 操作权限
  五项价值观 + Root 级最高优先 + 六级指令权限体系，要求 agent 只在事先约定的「结构化自主范围」内行动，明确成本/权限边界与人工介入触发条件。
  https://openai.com/index/updated-model-spec

- OpenAI 公开前沿模型失准检测体系：重放 HF 事件可提前 30 小时告警（附官方限定）
  四层监控（activation probe → 模型复核 → 调查 agent → 自动处置）；但官方承认误报导致只有前沿 RL 任务能 24h 值班，Codex 内部流量已关闭寻呼、其余仅工作时间——「能发现」不等于「会有人来」。
  https://openai.com/index/how-we-detect-frontier-model-misalignment

⚡ 精选动态
- 【🆕新发布】DeepSeek 完成第二轮 1055 亿元融资，估值 6155 亿元
  投资方含腾讯、宁德时代、长鑫存储、中芯国际、美团、vivo 等近 30 家，国产算力链与互联网巨头同时押注；二手报道为主，待官方口径确认。
  https://m.ithome.com/html/1020121.htm

- 【🔧工具】小米开源 Xiaomi-OCR-0：0.8B OCR/VLM，直出 Markdown 与 JSON
  HF 官方仓库 xiaomi-research/Xiaomi-OCR-0，1.5 万下载、GGUF/MLX 量化齐备，适合塞进文档解析与 RAG 摄取管线做本地兜底。
  https://huggingface.co/xiaomi-research/Xiaomi-OCR-0

- 【💬观点】Altman 自曝内部新模型：`两晚没睡`，并谈自我改进需要`限速`
  称内部模型已攻克多项学术难题，同时提 AI 自我复制数据中心；无正式发布公告，未列为产品发布。
  https://www.36kr.com/p/4047595233098247

- 【🧪实验】ScienceVision：前沿大模型三维科学理解评测——CAD 跑分高不等于工程可用
  覆盖生物/化学/医学影像/建筑/机械 CAD 五域 22 子域 250 题，66 位专家 ~500 小时打造；对 GPT-6 Astra 这类`视频看着真`的结果是一记冷水。
  https://readhub.cn/topic/8xeTm6gXR7x

- 【🏢行业】OpenAI 发布社区安全报告：Q3 向执法机构提交 200+ 次转介
  同时收紧未成年人与枪械相关内容，并承诺定期公开 Community Safeguards Report。
  https://openai.com/index/community-safety-report-and-new-protections-for-teens

🌟 GitHub Pick
- onehumanbeing/esp32-iphone-agent  ⭐4.1k / C · 用 7 美元 ESP32 让模型操作真 iPhone
  AirPlay 当眼睛、USB HID 当手，任何 OpenAI 兼容视觉模型可驱动；免 Mac、免开发者账号、免越狱——最便宜的 computer-use 真机靶场。
  https://github.com/onehumanbeing/esp32-iphone-agent

- wheresryan22/anatomy  ⭐23.0k / JavaScript · 画等轴测机械分解图的 agent skill
  输出带 WebGL 着色与 3D 效果的精细 SVG，是`skill 即产出物`路线里少见的视觉型样本。
  https://github.com/wheresryan22/anatomy

💬 社区热议
- B 站一周被 DeepSeek`入侵`（虎嗅）
  国产模型在内容社区的自发传播与二次创作，成了最真实的渗透率指标。
  https://www.huxiu.com/article/4901286.html
