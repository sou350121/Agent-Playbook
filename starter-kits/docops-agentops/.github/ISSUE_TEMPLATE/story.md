---
name: Story (Index Only)
description: Issue 仅做索引/协作层，正文在 stories/
labels: [story]
body:
  - type: input
    id: story_id
    attributes:
      label: Story ID
      placeholder: S-0001
    validations:
      required: true
  - type: input
    id: canonical
    attributes:
      label: Canonical Story (required)
      description: 必须填写 stories/S-xxxx.md 的仓库路径链接（SSOT）
      placeholder: https://github.com/<org>/<repo>/blob/main/stories/S-0001-xxx.md
    validations:
      required: true
  - type: textarea
    id: tldr
    attributes:
      label: TL;DR
      description: 1-3 句话总结目标与范围（索引用）
    validations:
      required: true
  - type: textarea
    id: acceptance
    attributes:
      label: Acceptance (high-level)
      description: 粗粒度验收要点（详细验收请看 story 正文）
    validations:
      required: true
  - type: dropdown
    id: status
    attributes:
      label: Status
      options:
        - Triage
        - Planned
        - In Progress
        - Blocked
        - Done
    validations:
      required: true
