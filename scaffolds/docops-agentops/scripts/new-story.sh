#!/usr/bin/env bash
set -euo pipefail

ID="${1:?Story id required (e.g. S-0002)}"
TITLE="${2:?Title required (e.g. add-login)}"

STORY_FILE="stories/${ID}-${TITLE}.md"
PROMPT_FILE="prompts/${ID}-${TITLE}.md"
SESSION_DIR="sessions/${ID}-${TITLE}"
FEATURE_DIR="docs/features/${ID}-${TITLE}"

mkdir -p "$(dirname "$STORY_FILE")" "$(dirname "$PROMPT_FILE")" "$SESSION_DIR" "$FEATURE_DIR/screenshots"

cat > "$STORY_FILE" <<EOF
# ${ID}-${TITLE}

## 目标

## 验收标准（必须可验证）
- [ ]

## 范围 / 非目标

## 任务拆分
- [ ]

## 关联文件（计划/实际）
- 

## 进度日志（每次 Agent session 追加）
- $(date +%F): 初始化
EOF

cat > "$PROMPT_FILE" <<EOF
# Prompt VCS: ${ID}-${TITLE}

## 1. 核心提示词 (Master Prompt)

```markdown
目标：实现 ${ID}-${TITLE}。
约束：只改动允许目录；不要引入与需求无关的重构。
输出：必须提供验证命令，并在 PR description 回填 story/prompt/failures 链接。
```

## 2. 环境与配置
- 模型：
- 模式：

## 3. 迭代策略
- 如果偏航：回到验收标准逐条对齐。
EOF

cat > "$SESSION_DIR/failures.md" <<EOF
# 失败路径记录 (Failure Log)

## 尝试 #1
- 日期：$(date +%F)
- 现象：
- 根因分析：
- 教训/对策：
EOF

cat > "$FEATURE_DIR/status.md" <<EOF
# ${ID}-${TITLE} 状态

- 状态：进行中
- Story：
  - ${STORY_FILE}
- Prompt：
  - ${PROMPT_FILE}
- Failures：
  - ${SESSION_DIR}/failures.md
- PR：

## 变更摘要

## 验证
EOF

echo "Created:
- $STORY_FILE
- $PROMPT_FILE
- $SESSION_DIR/
- $FEATURE_DIR/"
