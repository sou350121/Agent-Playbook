# 实战案例：阿里云 + Vibe Coding 部署三部曲

> **核心理念**：代码是耗材，意图和流程才是核心。所有案例都遵循 Vibe Coding 第一定律——永远追求最优解。

---

## 案例概览

| 案例 | 难度 | 时间 | 成本 | 适用场景 |
|------|------|------|------|----------|
| **A：Flask + ECS** | ⭐⭐ | 30 分钟 | <1 元 | 首次体验，快速验证 |
| **B：定时爬虫 + FC+OSS** | ⭐⭐⭐ | 1 小时 | <0.1 元 | 定时任务，数据采集 |
| **C：多 Agent + ACK** | ⭐⭐⭐⭐⭐ | 3 小时 | 约 20 元 | 并行处理，生产环境 |

---

## 案例 A：Python Flask 应用 → Docker → ECS

### 目标
用一句话让 Agent 创建一个 Web API，并自动部署到阿里云。

**意图描述**：
> "创建一个 Python Flask 应用，提供 `/api/news` 接口（返回随机新闻标题），用 Docker 打包后部署到阿里云 ECS，并配置自动销毁脚本。"

### 步骤 0：准备环境

**前置检查清单**：
- [ ] 阿里云账号已注册，已创建 Access Key
- [ ] 本地已安装 Docker
- [ ] 本地已安装阿里云 CLI：`aliyun configure`
- [ ] zcode 已安装并连接 Claude Code

### 步骤 1：Agent 生成代码

**在 zcode 中输入**：

```
我要创建一个 Flask 应用，具体要求：

1. 提供 /api/news 接口，返回随机新闻标题（从预设列表中随机选择）
2. 提供 /health 接口，返回服务状态
3. 使用 Docker 部署
4. 生成阿里云部署脚本（自动创建 ECS、SSH 部署、启动容器）

请遵循 Vibe Coding 第一定律，使用工业级最佳实践（如 gunicorn、错误处理、日志记录）。
```

**Agent 应该生成以下文件结构**：

```
flask-news-api/
├── app.py                 # 主应用
├── requirements.txt       # Python 依赖
├── Dockerfile            # Docker 镜像定义
├── docker-compose.yml    # 可选：本地测试
├── deploy_to_aliyun.py   # 自动部署脚本
└── cleanup.sh            # 资源清理脚本
```

### 步骤 2：人类审核（关键！）

**检查清单**：
```bash
# 1. 查看应用代码
cat app.py
# 应包含：错误处理、日志记录、环境变量配置

# 2. 查看 Dockerfile
cat Dockerfile
# 应包含：多阶段构建、非 root 用户、健康检查

# 3. 查看部署脚本
cat deploy_to_aliyun.py
# 应包含：超时处理、错误回滚、成本提示
```

### 步骤 3：本地测试

```bash
# 构建并运行
docker build -t flask-news-api .
docker run -p 5000:5000 flask-news-api

# 测试接口
curl http://localhost:5000/health
curl http://localhost:5000/api/news
```

### 步骤 4：云端部署

```bash
# 执行自动部署脚本
python3 deploy_to_aliyun.py

# 预期输出：
# ✅ Docker 镜像已构建
# ✅ ECS 实例已创建（ID: i-xxxxx）
# ✅ 容器已部署到云端
# 🌐 访问地址: http://47.96.xxx.xxx:5000/api/news
```

### 步骤 5：验证与清理

```bash
# 验证应用运行正常
curl http://47.96.xxx.xxx:5000/health

# 实验完成后立即清理（避免持续计费）
./cleanup.sh
# 预期输出：已释放 ECS 实例
```

### 成本分析

| 资源 | 配置 | 时长 | 成本 |
|------|------|------|------|
| ECS | 2核4G | 1 小时 | 0.35 元 |
| 流量 | 公网出流量 | 1 GB | 0.8 元 |
| **总计** | | | **< 1 元** |

### 关键要点

✅ **遵循第一定律**：使用 gunicorn 而非 Flask 开发服务器
✅ **幂等安全墙**：部署脚本可重复执行，不会重复创建资源
✅ **成本透明**：清理脚本确保实验结束后立即释放资源

---

## 案例 B：定时爬虫 → 函数计算 + OSS

### 目标
每周一凌晨自动爬取某网站新闻，存储到 OSS，并用 AI 分析情感。

**意图描述**：
> "创建一个定时任务，每周一凌晨 2 点自动执行：
> 1. 爬取某新闻网站的 Top 10 新闻
> 2. 存储标题和摘要到阿里云 OSS
> 3. 调用智谱 AI 分析新闻情感（正面/负面/中性）
> 4. 生成报告并保存到 OSS
> 使用函数计算实现，按调用计费。"

### 步骤 1：Agent 生成代码

**核心文件**：

**`news_crawler.py`**（函数计算入口）：

```python
import json
import requests
import oss2
from datetime import datetime

# 环境变量（在函数计算控制台配置）
OSS_ENDPOINT = os.getenv('OSS_ENDPOINT')
OSS_ACCESS_KEY = os.getenv('OSS_ACCESS_KEY')
OSS_SECRET_KEY = os.getenv('OSS_SECRET_KEY')
OSS_BUCKET = os.getenv('OSS_BUCKET')
ZHIPU_API_KEY = os.getenv('ZHIPU_API_KEY')

def handler(event, context):
    """函数计算入口"""

    # 1. 爬取新闻
    news_list = crawl_news()
    print(f"爬取到 {len(news_list)} 条新闻")

    # 2. 分析情感
    for news in news_list:
        sentiment = analyze_sentiment(news['summary'])
        news['sentiment'] = sentiment

    # 3. 存储到 OSS
    save_to_oss(news_list)

    # 4. 生成报告
    report = generate_report(news_list)
    save_report_to_oss(report)

    return {
        'statusCode': 200,
        'body': json.dumps({'message': '任务完成', 'news_count': len(news_list)})
    }

def crawl_news():
    """爬取新闻（示例）"""
    url = "https://example.com/news"
    response = requests.get(url)
    # 解析 HTML，提取标题和摘要
    # ...
    return news_list

def analyze_sentiment(text):
    """调用智谱 AI 分析情感"""
    from zhipuai import ZhipuAI
    client = ZhipuAI(api_key=ZHIPU_API_KEY)

    response = client.chat.completions.create(
        model="glm-4-flash",
        messages=[{
            "role": "user",
            "content": f"分析以下新闻的情感（正面/负面/中性）：{text}"
        }]
    )

    return response.choices[0].message.content

def save_to_oss(news_list):
    """保存到 OSS"""
    auth = oss2.Auth(OSS_ACCESS_KEY, OSS_SECRET_KEY)
    bucket = oss2.Bucket(auth, OSS_ENDPOINT, OSS_BUCKET)

    date_str = datetime.now().strftime('%Y-%m-%d')
    content = json.dumps(news_list, ensure_ascii=False, indent=2)

    bucket.put_object(f'news/{date_str}.json', content)
    print(f"已保存到 OSS: news/{date_str}.json")

def generate_report(news_list):
    """生成报告"""
    positive = sum(1 for n in news_list if '正面' in n.get('sentiment', ''))
    negative = sum(1 for n in news_list if '负面' in n.get('sentiment', ''))

    report = f"""
    新闻情感分析报告
    ================
    日期: {datetime.now().strftime('%Y-%m-%d')}
    总数: {len(news_list)}
    正面: {positive}
    负面: {negative}
    中性: {len(news_list) - positive - negative}
    """

    return report

def save_report_to_oss(report):
    """保存报告到 OSS"""
    auth = oss2.Auth(OSS_ACCESS_KEY, OSS_SECRET_KEY)
    bucket = oss2.Bucket(auth, OSS_ENDPOINT, OSS_BUCKET)

    date_str = datetime.now().strftime('%Y-%m-%d')
    bucket.put_object(f'reports/{date_str}.txt', report)
```

**`serverless.yml`**（Serverless 框架配置）：

```yaml
service: news-crawler

provider:
  name: aliyun
  runtime: python3.10
  region: cn-hangzhou

functions:
  weeklyCrawler:
    handler: news_crawler.handler
    events:
      - timer:
          name: weekly-trigger
          cron: '0 2 * * 1'  # 每周一凌晨 2 点
          input: {}
    environment:
      OSS_ENDPOINT: 'https://oss-cn-hangzhou.aliyuncs.com'
      OSS_BUCKET: 'my-news-bucket'
      # 其他敏感信息使用阿里云 KMS 加密
```

### 步骤 2：部署到函数计算

```bash
# 安装 Serverless Framework
npm install -g serverless

# 部署
serverless deploy

# 预期输出：
# ✅ 函数已创建: news-crawler-weeklyCrawler
# ✅ 定时触发器已配置: 每周一 02:00
# 🌐 HTTP 触发器: https://xxxxx.cn-hangzhou.fc.aliyuncs.com/...
```

### 步骤 3：测试

```bash
# 手动触发测试（不等待周一）
serverless invoke --function weeklyCrawler --data '{}'

# 预期输出：
# {
#   "statusCode": 200,
#   "body": '{"message": "任务完成", "news_count": 10}'
# }

# 查看 OSS 文件
aliyun oss ls oss://my-news-bucket/news/
aliyun oss ls oss://my-news-bucket/reports/
```

### 成本分析

| 资源 | 用量 | 单价 | 小计 |
|------|------|------|------|
| 函数调用 | 4 次/月 × 1s 执行 | 0.000031 元/万次 | ≈ 0 元 |
| 流量 | 10 MB/月 | 0.50 元/GB | 0.005 元 |
| OSS 存储 | 1 MB | 0.12 元/GB/月 | 0.00012 元 |
| **总计** | | | **< 0.1 元/月** |

> **关键优势**：几乎免费！适合低频任务和个人实验。

### 关键要点

✅ **真正体现 Vibe Coding**：用完即走，无需管理服务器
✅ **事件驱动**：定时器自动触发，无需人工干预
✅ **成本极低**：百万次调用免费额度，个人使用几乎零成本

---

## 案例 C：多 Agent 并行分析 → ACK 集群

### 目标
模拟 Boris Cherny 提到的"20 个 Agent 并行工作"，分析多个数据源并生成报告。

**意图描述**：
> "启动 20 个数据采集 Agent，并发分析不同网站的新闻，使用阿里云 ACK（Kubernetes）编排，汇总结果并生成可视化报告。"

### 步骤 1：Agent 生成 Kubernetes 配置

**`Dockerfile`**：

```dockerfile
FROM python:3.10-slim

WORKDIR /app

RUN pip install requests beautifulsoup4 zhipuai --no-cache-dir -i https://mirrors.aliyun.com/pypi/simple/

COPY agent.py .

CMD ["python", "agent.py"]
```

**`agent.py`**（单个 Agent 的逻辑）：

```python
import os
import requests
from bs4 import BeautifulSoup
from zhipuai import ZhipuAI
import json

def crawl_site(site_url):
    """爬取单个网站"""
    response = requests.get(site_url, timeout=10)
    soup = BeautifulSoup(response.content, 'html.parser')

    # 提取新闻标题和链接
    news_items = soup.find_all('div', class_='news-item')[:10]

    results = []
    for item in news_items:
        title = item.find('h3').text.strip()
        summary = item.find('p').text.strip()

        # 分析情感
        client = ZhipuAI(api_key=os.getenv('ZHIPU_API_KEY'))
        sentiment_response = client.chat.completions.create(
            model="glm-4-flash",
            messages=[{
                "role": "user",
                "content": f"分析以下新闻的情感（正面/负面/中性）：{summary}"
            }]
        )

        results.append({
            'title': title,
            'summary': summary,
            'sentiment': sentiment_response.choices[0].message.content,
            'url': site_url
        })

    return results

if __name__ == '__main__':
    site_url = os.getenv('TARGET_URL')
    results = crawl_site(site_url)

    # 输出到 stdout（由 K8s 收集日志）
    print(json.dumps(results, ensure_ascii=False))
```

**`deployment.yaml`**（Kubernetes 配置）：

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: target-urls
data:
  urls: |
    - https://news.site1.com
    - https://news.site2.com
    - https://news.site3.com
    # ... 共 20 个网站

---
apiVersion: batch/v1
kind: Job
metadata:
  name: multi-agent-crawler
spec:
  parallelism: 20  # 并行运行 20 个 Pod
  completions: 20
  template:
    metadata:
      labels:
        app: news-agent
    spec:
      containers:
      - name: agent
        image: registry.cn-hangzhou.aliyuncs.com/your-namespace/news-agent:latest
        env:
        - name: TARGET_URL
          valueFrom:
            configMapKeyRef:
              name: target-urls
              key: urls
        - name: ZHIPU_API_KEY
          valueFrom:
            secretKeyRef:
              name: zhipu-credentials
              key: api-key
      restartPolicy: Never
```

### 步骤 2：部署到 ACK

```bash
# 1. 构建并推送镜像
docker build -t news-agent:latest .
docker tag news-agent registry.cn-hangzhou.aliyuncs.com/your-namespace/news-agent:latest
docker push registry.cn-hangzhou.aliyuncs.com/your-namespace/news-agent:latest

# 2. 创建 ACK 集群（或使用已有集群）
aliyun cs CreateCluster \
  --RegionId cn-hangzhou \
  --Name "vibe-coding-agents" \
  --NodeCount 3 \
  --InstanceType ecs.t6-c1m2.large

# 3. 部署 Kubernetes Job
kubectl apply -f deployment.yaml

# 4. 查看执行状态
kubectl get pods -l app=news-agent
kubectl logs -l app=news-agent --tail=-1 > results.json
```

### 步骤 3：结果汇总

**Agent 应该自动生成汇总脚本**：

```python
# aggregate_results.py
import json
import matplotlib.pyplot as plt

# 读取所有 Agent 的结果
with open('results.json', 'r') as f:
    all_results = [json.loads(line) for line in f]

# 汇总统计
total_news = sum(len(r) for r in all_results)
sentiment_distribution = {
    '正面': 0,
    '负面': 0,
    '中性': 0
}

for result in all_results:
    for item in result:
        sentiment = item.get('sentiment', '未知')
        if '正面' in sentiment:
            sentiment_distribution['正面'] += 1
        elif '负面' in sentiment:
            sentiment_distribution['负面'] += 1
        else:
            sentiment_distribution['中性'] += 1

# 生成可视化图表
plt.figure(figsize=(10, 6))
plt.bar(sentiment_distribution.keys(), sentiment_distribution.values())
plt.title(f'多 Agent 并行新闻分析报告（共 {total_news} 条）')
plt.savefig('sentiment-analysis.png')

print(f"✅ 报告已生成: sentiment-analysis.png")
```

### 成本分析

| 资源 | 配置 | 时长 | 成本 |
|------|------|------|------|
| ACK 集群 | 3 个节点（2核4G） | 1 小时 | 1.05 元 |
| 流量 | 100 MB | | 0.08 元 |
| 日志服务 SLS | 1 GB | | 0.5 元 |
| **总计** | | | **约 1.63 元** |

> **注意**：如果集群持续运行，成本会显著增加。建议实验完成后立即删除集群。

### 关键要点

✅ **真正的并行**：20 个 Agent 同时工作，10 分钟完成串行需要 3 小时的任务
✅ **云原生编排**：Kubernetes 自动调度、容错、负载均衡
✅ **日志聚合**：通过 SLS 统一收集所有 Agent 的输出

---

## 总结：三案例对比

| 维度 | 案例 A（ECS） | 案例 B（FC） | 案例 C（ACK） |
|------|--------------|-------------|--------------|
| **适用场景** | 长期运行的应用 | 定时任务、事件驱动 | 并行处理、微服务 |
| **复杂度** | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **成本** | 0.35 元/小时 | 几乎免费 | 1.05 元/小时 |
| **运维负担** | 中等（需管理服务器） | 低（无服务器） | 高（K8s 集群） |
| **学习曲线** | 平缓 | 适中 | 陡峭 |
| **Vibe Coding 体现** | 快速验证想法 | 真正的"短暂性" | 多 Agent 协作 |

### 推荐学习路径

1. **第 1-2 周**：完成案例 A，理解"意图 → 云端"全流程
2. **第 3-4 周**：完成案例 B，体验 Serverless 的"用完即走"
3. **第 5-8 周**：挑战案例 C，掌握云原生多 Agent 编排

### 下一步行动

1. **立即开始**：选择案例 A，在 zcode 中体验第一个部署
2. **记录过程**：使用 DocOps 方法，将每个步骤记录为文档
3. **分享经验**：将你的案例提交到本仓库的 `case-studies/` 目录

---

> **Vibe Coding 第一定律践行**：所有案例都使用工业级最佳实践（gunicorn、K8s、Serverless），而非"最快速完成"的方案。让 AI 承担繁琐的配置工作，人类专注业务意图。
