# Review Notes — mxy-wiki skill

## 2026-05-31: v2.2.0 — 工具选择防御

**触发**：用户纠正了两个工具选择问题：
1. 假设 obsidian-cli 不可用而直接降级到 search_files，没有实际执行命令验证
2. 没有加载 defuddle skill 就直接用了 web_extract

**修复（3 patch + 1 frontmatter）**：

| 位置 | 改动 |
|---|---|
| 工具集成 > 降级策略 | 加粗「必须先实际执行命令验证」，明确不能凭假设跳过 |
| 工具集成 > 新增小节 | 「网页素材提取」对比表：defuddle / web_extract / browser_navigate |
| 注意事项 #8 | 新增：验证工具可用性再降级，所有「不可用」判断需要证据 |
| 注意事项 #9 | 新增：选工具前加载相关 skill，不要惯性使用默认工具 |
| frontmatter | related_skills 加入 defuddle；version 2.1.0 → 2.2.0 |

**根因**：惯性思维 — web_extract 是「默认」工具，拿到结果后觉得「够用了」没有评估替代方案。

---

## 2026-05-31: v2.3.0 — Ingest 实战修复

**触发**：一次完整的 dtm.pub 缓存一致性文章 ingest，暴露了 8 个问题。

**修复（8 项，SKILL.md + lint-stage-b.py）**：

| # | 问题 | 修复 |
|---|---|---|
| 1.1 | raw/ 文件被覆盖（defuddle 重提取后直接 write_file） | Step ① 加 ⚠️ 内联警告 + Pitfall 表 |
| 1.2 | 摘录写成了改写摘要而非原文子串 | Step ⑤ 加 4 步摘录写作流程（复制→粘贴→截断→分析） |
| 1.3 | ingest 流程没有工具选择步骤 | ⓪.5 选择素材获取工具（决策树） |
| 1.4 | Stage B 前没有用户确认 | 加 scope 确认步骤 |
| 2.1 | Unicode 弯引号导致摘录匹配失败 | lint 脚本加 `_normalize_unicode` 函数 |
| 2.2 | ingest 后没有衔接定向 lint | Step ⑧ 后加 "Ingest 后 lint" 提示 |
| 2.3 | 7 项检查的全局/局部分类未文档化 | Stage B 加检查范围表 + 脚本头部注释 |
| Pitfall | 4 条常见错误表 | 注意事项前新增 Pitfall 段落 |

**根因分析**：1.1/1.2/1.3 共享同一根因 — **约束文档离决策点太远**。规则在注意事项/防御矩阵中，但不在 agent 做决策的 ingest 流程步骤内。修复模式：在决策点加内联警告。

**新发现的脚本改进**：
- `_normalize_unicode` 处理弯引号/全角符号，避免编码差异误报
- 脚本头部加全局/局部检查分类注释

**未修复的遗留**（来自 2026-05-14 review）：
- S1: `_synthesis/` 路径检测不跨平台
- S2: `topics` 字段无下游消费
- S3: raw/ frontmatter 无脚本级验证
- S4: 跨领域交叉引用示例不完整

---

## 2026-05-14: Full Review

Full end-to-end review of SKILL.md, lint-stage-b.py, and schema-template.md.

### Fixed (11 patches applied)

| Category | Issue | Status |
|---|---|---|
| Blocking | Duplicate "置信度体系" section; operational Step 2/3 text embedded inside | Fixed — removed duplicate, extracted Steps to new "会话初始化" section |
| Blocking | "跨领域交叉引用" section garbled (broken code block, orphan `go/gc →`) | Fixed — replaced with clean yaml example |
| Blocking | `new_vs_existing` referenced in confirmation flow but absent from JSON schema | Fixed — added `new_vs_existing` object with 3 sub-fields |
| Blocking | Step numbering: ⑧/⑨ should be ⑦/⑧ (⑦ was missing) | Fixed — renumbered |
| Important | `confidence` field not validated for knowledge-type pages | Fixed — conditional check in `check_frontmatter` |
| Important | `contested: true` without `contradictions` not caught | Fixed — added validation |
| Important | Query `search_files` can't exclude `raw/` — no explicit instruction | Fixed — added note to manually filter results |
| Important | `verify_extracted_quotes` regex only captured single-line quotes | Fixed — rewrote as multi-line parser |
| Important | Stage C trigger ambiguous (auto vs manual) | Fixed — must ask user before entering C |

### Suggestions (not yet applied — revisit in next review cycle)

#### S1: `_synthesis/` path detection is not portable
**File**: `scripts/lint-stage-b.py` L390
**Current**: `"_synthesis/" in p["path"]` (string match)
**Risk**: On Windows, path separator is `\\`, so `_synthesis\\` won't match.
**Suggested fix**: `Path("_synthesis") in Path(p["path"]).parents or p["path"].startswith("wiki/_synthesis/")`
**Priority**: Low (current deployment is Linux-only)

#### S2: `topics` field in ingest JSON has no downstream consumer
**File**: `SKILL.md` L480-482
`entities` → wiki pages, `connections` → wikilinks, `contradictions` → contested, `suggested_tags` → tags. `topics` has no mapping.
**Options**: (a) Add comment explaining it's an LLM intermediate reasoning aid, or (b) remove it.
**Priority**: Low — doesn't break anything, just unclear.

#### S3: raw/ frontmatter has no script-level validation
**File**: `scripts/lint-stage-b.py` — `DEFAULT_EXCLUDED_DIRS` includes `"raw"`
raw/ has its own frontmatter schema (`source_url`, `ingested`, `extracted_to`) but no script checks it.
**Options**: Add a separate `raw-health-check` scan or a `--include-raw` flag.
**Priority**: Medium — LLM can forget to fill `ingested` date.

#### S4: Cross-reference section could use a more complete example
**File**: `SKILL.md` "跨领域交叉引用" section
Currently shows `related` field example. Could also show a full-body wikilink example.
**Priority**: Low — current example is functional.

### Tool / Technique Notes

- `verify_extracted_quotes` now collects multi-line `> 摘录：...` blocks by scanning consecutive `>`-prefixed lines. Content lines are joined with spaces for substring matching against source text.
- `check_frontmatter` now conditionally flags missing `confidence` based on `type` (concept, source-summary, comparison, question) rather than universally requiring it. MOC/synthesis pages are exempt.
