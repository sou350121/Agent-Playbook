param(
  [Parameter(Mandatory=$true)][string]$Id,
  [Parameter(Mandatory=$true)][string]$Title
)

$root = Get-Location
$storyFile = Join-Path $root ("stories/{0}-{1}.md" -f $Id, $Title)
$promptFile = Join-Path $root ("prompts/{0}-{1}.md" -f $Id, $Title)
$sessionDir = Join-Path $root ("sessions/{0}-{1}" -f $Id, $Title)
$featureDir = Join-Path $root ("docs/features/{0}-{1}" -f $Id, $Title)

New-Item -ItemType Directory -Force -Path (Split-Path $storyFile) | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path $promptFile) | Out-Null
New-Item -ItemType Directory -Force -Path $sessionDir | Out-Null
New-Item -ItemType Directory -Force -Path $featureDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $featureDir "screenshots") | Out-Null

@"# $Id-$Title

## 目标

## 验收标准（必须可验证）
- [ ]

## 范围 / 非目标

## 任务拆分
- [ ]

## 关联文件（计划/实际）
- 

## 进度日志（每次 Agent session 追加）
- $(Get-Date -Format 'yyyy-MM-dd'): 初始化
"@ | Set-Content -Encoding UTF8 $storyFile

@"# Prompt VCS: $Id-$Title

## 1. 核心提示词 (Master Prompt)
```markdown
目标：实现 $Id-$Title。
约束：只改动允许目录；不要引入与需求无关的重构。
输出：必须提供验证命令，并在 PR description 回填 story/prompt/failures 链接。
```

## 2. 环境与配置
- 模型：
- 模式：

## 3. 迭代策略
- 如果偏航：回到验收标准逐条对齐。
"@ | Set-Content -Encoding UTF8 $promptFile

@"# 失败路径记录 (Failure Log)

## 尝试 #1
- 日期：$(Get-Date -Format 'yyyy-MM-dd')
- 现象：
- 根因分析：
- 教训/对策：
"@ | Set-Content -Encoding UTF8 (Join-Path $sessionDir "failures.md")

$storyRel = "stories/{0}-{1}.md" -f $Id, $Title
$promptRel = "prompts/{0}-{1}.md" -f $Id, $Title
$sessionRel = "sessions/{0}-{1}" -f $Id, $Title
$featureRel = "docs/features/{0}-{1}" -f $Id, $Title

@"# $Id-$Title 状态

- 状态：进行中
- Story：
  - $storyRel
- Prompt：
  - $promptRel
- Failures：
  - $sessionRel/failures.md
- PR：

## 变更摘要

## 验证
"@ | Set-Content -Encoding UTF8 (Join-Path $featureDir "status.md")

"Created:\n- $storyFile\n- $promptFile\n- $sessionDir\n- $featureDir" | Write-Host
