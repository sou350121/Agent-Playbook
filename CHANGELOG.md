# Changelog

## 2026-02-15 to 2026-02-27

### Reports
- Added biweekly 2026-02-26 report + reflection: AG-UI 标准化、MCP 生态收敛、多智能体生产化趋势
- Added biweekly 2026-02-18 report + reflection: Agent 执行层碎片化、分层推理路由省 66% 成本

### Pipeline Improvements
- `prep-ai-app-social.py`: replaced 28 release-focused search terms with 20 opinion/debate/viral terms
- `run-ai-app-workflow-two-phase.py`: added expert curation step (qwen3.5-plus scoring ≥4/5)
- `prep-ai-app-workflow.py`: increased max_queries 2→3; fixed `site:` + boolean timeout issue
- `prep-ai-deep-dive.py`: added `_platform_penalty()` and `_arch_bonus()` scoring
- Biweekly prediction reflection: fixed hardcoded `{}` schema — LLM now evaluates ✅/❌/⏳
- AI App biweekly: added social-intel + prev reflection as data sources; improved TG formatting

### Models
- All qwen-max calls migrated to qwen3.5-plus (better quality AND faster)

### Docs
- Added `README.md`: complete repo navigation guide with pipeline DAG and quick-start table
- Cleaned up `reports/biweekly/`: removed test/draft files

---

> Format: entries grouped by release date. Auto-pipeline changes tracked here when behavior-affecting.
