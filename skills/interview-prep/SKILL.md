---
name: interview-prep
description: "Generate interview questions & answer frameworks from resume bullets — shallow/mid/deep tiers, tech selection defense, safety boundaries, Chinese interview context. Load when user says: 面试准备, prepare for interviews, mock interview, what questions might they ask, how should I answer, what are my weak spots, simulate interview."
version: 2.5.0
author: mxyinvoker@gmail.com
metadata:
  hermes:
    tags: [interview, career, job-search, preparation, resume]
    category: productivity
    related_skills: [resume-polish, humanizer]
    last_updated: 2026-06-04
    darwin_score_baseline: 91.5
---

# Interview Prep: Generate Questions & Answer Frameworks from Resume

Load this skill when the user asks to:
- "prepare for interviews", "面试准备", "mock interview"
- "what questions might they ask about my resume"
- "how should I answer if they ask about X"
- "what are the weak spots in my resume"

## What This Skill Does

Takes a resume as input and produces a complete interview preparation document:

1. **基础技术预演** — Go/MySQL/Redis/分布式等通用基础题，不映射简历但必问
2. **项目逐条问答** — 每个简历子弹的三层提问 + 安全边界
3. **技术选型防御** — "为什么用 X 不用 Y"的完整回答框架
4. **业务场景压力测试** — 基于项目描述的假设性边缘场景
5. **系统设计题库** — 经典系统设计题（短链接/秒杀/IM/限流器等）和项目延伸方案设计题，各含需求澄清+容量估算+架构设计+追问链
6. **行为面试映射** — 常见行为题 → 简历中的具体故事
7. **自我介绍框架** — 60秒结构化模板，含 hook 选项
8. **反问环节** — "你有什么想问我们的"的回答策略
9. **脆弱点审计** — 3-5 个最脆弱的声明 + 防御话术
10. **面试节奏策略** — 什么展开、什么带过、时间分配

---

## Before You Start

1. **Load user preferences from memory**: Check the following specifically:
   - `memory` → exaggeration boundary: what the user considers fabricated (e.g. "100万QPS" threshold). This defines the depth limits for interview questions — don't generate questions that push beyond what the resume actually claims.
   - `memory` → participation level for each project (owned / contributed / integrated). This determines how deep mid/deep questions can go.
   - `memory` → tech stack rules: what's on the resume vs. what's genuinely deep knowledge for this user.
   - `session_search` → recent resume-polish sessions: which version (conservative/moderate/bold) was applied to each bullet. A conservative bullet gets shallow/mid questions only; a bold bullet can go deeper.

2. **Know which version each bullet uses**: Before generating questions, understand the polish level of each bullet. If the user chose "保守版" for a bullet, don't generate deep questions that would expose fabrication. If they chose "激进版", prepare extra defense for those points.

3. **Confirm the resume file**: The resume should already be polished (via `resume-polish`). If not, suggest running resume-polish first. Interview prep builds on top of polished content.

4. **Output location**: Default save path is `./面试准备-{简历文件名}.md` in the same directory as the resume.

---

## Iterative Workflow

Interview prep typically takes 2-4 rounds:

```
Round 1: Generate all sections → present as draft
Round 2: User reviews → adjusts depth levels, adds/removes topics
Round 3: Practice simulation → user tries answering, identifies weak spots
Round 4: Final polish → update answers, refine defense
```

**Key rule**: One project or section at a time. Don't dump all 60+ questions at once. Generate by project, let the user review, then move to the next.

**出题追踪规则（模拟面试多轮）**：首次模拟面试结束后，agent 必须生成/更新出题追踪文件（见 Step 12），记录本轮出了哪些题。第二轮起，agent **现场生成新题目**（基于用户经验年限 + 简历实际技术栈），然后查追踪文件排除已出过的题，避免重复。追踪文件是**去重工具**，不是预定义题库——不可以在追踪文件中预先写入题目然后从中"抽取"。每道题必须在出题时现场判断难度和措辞。

## Round 启动检查清单
**🔴 CHECKPOINT: 每次新轮次开始前必须执行以下检查**

1. 检查目录下是否有旧版追踪文件（裸名 `面试出题追踪.md` 或旧简历版本），读取并合并到新版后删除旧版
2. 确认 `面试旧题库-{简历文件名}.md` 存在且包含所有历史已出题目
3. 确认 `面试出题追踪-{简历文件名}.md` 存在且为当前轮次题目
4. 检查是否有过时的归档文件（多次归档只保留最近一次）
5. 向用户确认"从哪里继续"，不要假设上一轮的进度

---

## Core Principles

### Interviewer Mindset

An interviewer reads your resume and asks:
1. "Did you really do this?" → tests authenticity
2. "How deep did you go?" → tests technical depth
3. "What would you do differently?" → tests reflection
4. "Can you handle our scale?" → tests adaptability

Every question you prepare should address one of these four concerns.

### 中文面试语境

Chinese tech interviews have specific cultural expectations beyond technical accuracy:

**"谦虚但有底气" — humble but confident:**
- Don't oversell. Acknowledge limitations before showing depth: "这个项目QPS不高，所以我们没做分库分表。不过我在XX场景下验证过..."
- The best Chinese interview answers follow the pattern: 承认边界 → 展示深度 → 引导到擅长领域

**回答模式:**
```
1. 先定边界: "这个项目规模不大，日均X笔..."
2. 再展深度: "但我当时考虑过几个方案，选X是因为..."
3. 引向擅长: "如果你感兴趣，我可以展开讲XX的实现..."
```

**"反问是加分项":**
- 不问问题 = 没思考。问得好 = 加分。
- 避免: 问薪资待遇、加班情况、几点下班
- 推荐: 问技术栈演进、团队分工、项目下一阶段规划

### Answer Framework, Not Script

Never provide a word-for-word answer. Provide:

1. **Hook** — 开场句，争取思考时间 + 设定语境
2. **Structure** — 2-3 个要点，逻辑递进
3. **Landing** — 收尾句，自然过渡到下一个话题

Chinese example:
```
问："为什么用 PostGIS 而不是 Redis GEO？"

Hook: "这个项目的查询场景决定了 PostGIS 更合适。"

Structure:
  1. 数据本来就在 PostgreSQL，引入 Redis 增加运维复杂度
  2. 项目 QPS 不高，PostGIS 的单库查询完全够用
  3. 业务需要多边形围栏查询（不属于某个圆心半径），Redis GEO 不支持

Landing: "所以综合考虑维护成本和功能需求，单库方案就够了。如果你对 PostGIS 的索引细节感兴趣，我可以展开。"

不要说的:
  - "PostgreSQL 性能比 Redis 好" — 技术上站不住
  - "Redis 太慢了" — 明显不懂，恰好相反
```

### Safety Boundaries

For every claim in the resume, define a clear interview boundary:

| 层 | 含义 | 回答策略 |
|---|------|---------|
| ✅ 安全区 | 亲手做过，能展开讲细节 | 主动展示，这是你的主场 |
| ⚠️ 边界区 | 知道原理但没亲手做过 | "我知道原理，实际场景中我用的是..."（诚实过渡到安全区） |
| ❌ 禁区 | 没做过，简历里也没有 | 直接说"这部分我没接触过"，不编、不绕 |

The boundary map prevents the user from wandering into fabrication during an interview. Every bullet in the question drill must have its boundary labeled.

---

## Process

### Step 1: Load Context

Read the resume file and extract:
- Personal summary
- Skills (flat list)
- Projects (name, tech stack, bullets — note polish version for each)
- Work history (company, title, period)
- Education

Also load from memory: the user's participation level for each project, any weak spots previously identified during resume-polish, and the exaggeration boundary.

### Step 2: 基础技术预演

Generate fundamental technical questions based on the resume's tech stack. These are NOT mapped to specific resume bullets — they're the universal questions every interviewer asks.

**三轮渐进难度（模拟面试专用）:**

| 轮次 | 深度 | 目标 | 题量 |
|------|------|------|------|
| Round 1 | 浅层 | 确认基本功，快速筛选明显短板 | 8-10 题（必答，覆盖 6-8 领域） |
| Round 2 | 中层 | 测试决策能力，结合简历实际技术栈 | 每核心领域 3-5 题，按简历技术栈广度决定总量（如 Go/MySQL/Redis/Kafka/ES 各 5 题 = 20+ 题） |
| Round 3 | 深层 | 区分高手，展示机会 | 每核心领域 1-2 题，聚焦面试官可能深挖的方向 |

> 题量依据：国内技术一面标准时长 45-60 分钟，Round 1 每题 2-3 分钟回答，8-10 题正好覆盖 20-30 分钟，剩余时间留给中层/深层题和项目问答。总题量过多会导致每道题回答不充分，无法区分真实水平。

**规则**：Round 1 完成后 agent **必须**读取出题追踪文件（见 Step 12）记录已出题目。Round 2/3 **现场生成新题**：基于用户经验年限和简历技术栈判断难度和措辞，然后查追踪文件排除已出过的题。已出过的题目不再重复。

**出题密度参考（依据国内 7 年 Go 后端面试统计）**: 建议覆盖 6-8 个技术领域，每个领域 2-3 题，总基础题 15-20 题。不要只覆盖 3-5 个领域——领域过窄会导致面试覆盖面不足。国内中型以上公司的技术一面通常覆盖 6+ 个技术栈维度，每个维度出题 2-3 道以区分熟练度。

**出题方法（每道题现场生成，非预定义）**：出题时综合考虑三个维度：

1. **经验年限**：7 年工龄的 Go 开发者应该能回答的不只是 API 用法，而是选型决策和故障排查思路
2. **简历技术栈**：题目绑定简历中实际出现的技术（go-zero / gRPC / MySQL / Redis / Kafka / canal / ES），不考简历没写的工具（如 Redis Cluster、etcd 深度运维）
3. **追踪文件去重**：每道题生成后查追踪文件，如果 Round 1 已出过同领域同类难度的题，换角度或换领域

### Step 3: 项目逐条问答

For each project in the resume, generate questions bullet by bullet. **Per-project cap: 5-8 questions total**, allocated by priority:

| 优先级 | 子弹类型 | 问题数 |
|--------|---------|--------|
| 高 | 技术选型、架构决策 | 2-3 题 |
| 中 | 功能实现、集成 | 1-2 题 |
| 低 | 业务描述、运维 | 1 题或跳过 |

**For old work experience (2+ years ago):** 2-3 questions per role, not per bullet. The focus is on confirming scope, not drilling depth.

**Format per bullet:**

```
### [Project Name] — [Bullet Priority: 高/中/低]

**简历原文:**
> [exact bullet text]

**当前版本:** [保底/适中/激进 — determines depth limit]

**安全边界:** [✅/⚠️/❌]

**浅层 — 确认你真的做了:**
- [1 question]

**中层 — 测试你的决策能力:**
- [1-2 questions — skip if conservative version]

**深层 — 区分高手的展示机会:**
- [1 question — only for bold version or high-priority bullets]
```

### Step 4: 技术选型防御

Group all "why X over Y" questions that arise from the resume's tech choices. For each:

```
### [Selection]: X vs Y

**面试官怎么问:**
- [specific Chinese phrasing]

**回答框架:**
1. 项目背景 → "这个项目的特点是..."
2. 方案对比 → "我也考虑过 Y，但..."
3. 选择理由 → "所以选了 X，因为..."

**不要说的:**
- [pitfall answers]

**可主动引导到:** [adjacent strength you want to showcase]
```

### Step 5: 业务场景压力测试

For each project, generate 2 hypothetical edge cases:

```
### [Project Name] — 场景压力测试

**场景 1：** [hypothetical failure or edge case]
- 面试官想问什么：[underlying concern]
- 回答思路：[structured approach, 2-3 sentences]

**场景 2：** [another scenario]
- 面试官想问什么：[underlying concern]
- 回答思路：[structured approach]
```

### Step 6: 系统设计题库

Generate system design questions in two categories. These are OPEN-ENDED architectural thinking exercises — the interviewer evaluates how you structure a solution from scratch, not whether you recall facts.

**出题原则：**

1. **经典系统设计题** — 不绑简历，纯架构思维。测试需求澄清、容量估算、数据建模、组件选型、trade-off 分析。
2. **项目延伸方案设计题** — 从简历项目的技术栈和业务场景延伸，测试"如果让你重做/扩展，你怎么设计"。

**经典系统设计题选题标准：**
- 优先级从高到低：与简历技术栈关联度（如用户用过 Snowflake → 出分布式 ID 生成器）、面试高频题、难度递增
- 数量：3-4 道
- 难度分布：1 道基础经典题（短链接）+ 1-2 道技术关联题（分布式ID/限流器）+ 1 道进阶题（IM/推送）

**项目延伸方案设计题选题标准：**
- 从简历核心项目的技术决策点延伸：如用户做过清算调度 → "设计一个高可用的清算调度系统"
- 必须基于简历真实技术栈（go-zero/MySQL/Redis/Kafka/canal/ES），不引入用户没接触过的工具
- 数量：2-3 道

**每道题的结构：**

```
### [类型标签] 设计题 N：题目名

**面试官怎么问：**
- [中文原话，模拟真实面试开场]

**关联项目/技能：** [选填，如果是项目延伸题必填]

**第 1 层 — 需求澄清（你要先问什么）：**
- [3-5 个澄清问题，展示你不会直接动手画架构]

**第 2 层 — 容量估算：**
- [QPS/存储/带宽的估算思路，不需要精确数字，要的是估算方法]

**第 3 层 — 架构设计：**
- [核心组件 + 数据流，给出高可用/扩展性考虑]

**第 4 层 — 关键决策深挖：**
- ["为什么选 X 不选 Y" — 3-5 个关键决策点的 trade-off 分析]

**第 5 层 — 面试官追问链：**
- 追问 1：[递进追问]
- 追问 2：[递进追问]
- 追问 3：[递进追问]

**回答要点：** [不写完整答案，给回答框架：开场句 → 2-3个核心论据 → 收尾引导]
```

### Step 7: 行为面试映射

Map standard behavioral questions to specific stories from this resume:

| 常见行为面试题 | 简历中的具体故事 | 回答角度 |
|---------------|-----------------|---------|
| "你最大的技术挑战是什么？" | [which bullet + why] | [what you learned] |
| "你遇到过的最大坑是什么？" | [real mistake + reflection] | [**不要编造**——见 Pitfall 10。如果没有真实的大坑，诚实说"项目节奏可控没遇到单个大坑"然后转向技术挑战或学习习惯] |
| "你和同事意见不一致怎么办？" | [which situation] | [how you resolved it] |
| "你如何学习新技术？" | [which example] | [learning methodology] |
| "你做过最自豪的项目？" | [which project + hook] | [your specific contribution] |
| "你的职业规划？" | [how to connect to this resume] | [trajectory narrative] |
| "为什么离职/看机会？" | [framing] | [forward-looking, never negative] |

### Step 8: 自我介绍框架

Generate a structured 60-second self-introduction:

```
**结构:** 我是谁（15秒）→ 我做过什么（30秒）→ 我为什么适合（15秒）

**Hook 选项:**

**选项 A — 项目驱动型（适合项目经验强的人）:**
"我叫[名字]，[X]年[语言]后端开发。最近一个项目是[项目名]，我负责[一句话核心贡献]。
之前还做过[第二个项目]和[第三个项目]，技术栈覆盖[列举]。
看到贵司的[职位/业务]，我觉得我的[某段经验]比较匹配。"

**选项 B — 技术深度型（适合有技术亮点的人）:**
"我叫[名字]，做了[X]年后端，主要用[语言]。
我对[某个技术领域]比较深入，在[项目名]里实现过[具体技术点]。
我希望找一个能继续在[方向]上深入的团队。"

**选项 C — 广度适应型（适合多项目/多角色的人）:**
"我叫[名字]，[X]年经验，从[语言A]做到[语言B]。
完整做过[列举项目类型]，从[业务类型A]到[业务类型B]。
我能快速适应不同的技术栈和业务场景，之前[举一个例子]。"
```

Pick the template that fits this resume's profile and fill in concrete details.

### Step 9: 反问环节

Prepare 3-5 questions for the "你有什么想问我们的" moment. Rules:

**展示深度的问题（推荐）:**
- "团队目前的技术栈是怎么演进的？有哪些技术债在还？"
- "这个岗位的日常工作节奏是怎样的？独立开发 vs 协作的比例？"
- "目前团队在技术上的最大挑战是什么？"

**踩雷的问题（绝对不要问）:**
- 薪资待遇、加班强度、几点下班 → 这些跟 HR 聊
- "你们用什么技术栈" → 显得你没做功课
- "我能多久升职" → 太着急

```
**推荐反问（按优先级）:**

1. [团队/技术方向的问题 — 展示你关心技术成长]
2. [项目/业务的问题 — 展示你做过了功课]
3. [工作方式的问题 — 展示你关心协作]
```

### Step 10: 脆弱点审计

Identify the 3-5 most vulnerable claims in the resume and prepare defense:

```
### 脆弱点：[specific claim or gap]

**面试官可能追问:**
- [specific question phrasing]

**如何应对:**
- [honest framing — acknowledge boundary + redirect to strength]
```

Common vulnerability patterns to scan for:
- A technology in the skills list that appears in zero project bullets
- A bullet that implies senior-level scope but the title was mid-level
- A project with impressive tech stack but thin description
- A gap in employment timeline
- A technology the user "knows" but hasn't used in production

### Step 11: 面试节奏策略

For the complete resume, classify what to emphasize and what to move past:

```
**主动展开（你的核心亮点，多花时间）:**
- [Project A, Bullet X] — 技术深度够，面试官会追问
- [Project B, Bullet Y] — 有选型决策，能展示思考
- [项目 Z 整体] — 最完整、技术栈最匹配目标岗位

**一带而过（尽快结束，不主动展开）:**
- [旧工作经验] — 确认你做过就行，不需要深挖
- [简单项目] — 承认简单，转到"但我在另一个项目里..."
- [你不确定能答深的问题] — 浅层答完就收

**时间分配建议:**
- 35% 时间在核心亮点项目
- 25% 时间在基础技术预演
- 20% 时间在系统设计题库
- 10% 时间在数据管道和可观测性
- 10% 时间在行为面试 + 反问环节
```

### Step 12: 出题追踪

每次模拟面试结束后，agent 必须在简历同目录自动维护出题追踪文件，避免多轮面试间重复出题或遗漏。

**文件命名**:

- `面试旧题库-{简历文件名}.md` — 所有已出过的题目（纯去重查询，只读不写当前轮次）
- `面试出题追踪-{简历文件名}.md` — 当前轮次的未出题目（日常操作文件）

**轮次流转规则**：

1. 每轮出题前：现场生成新题 → 去 `面试旧题库` 查重 → 过滤已出过的题 → 写入 `面试出题追踪` 
2. 每轮结束后：将 `面试出题追踪` 中本轮已出（[x]）的题目迁移到 `面试旧题库`，追加到对应领域下
3. 下一轮开始：清空 `面试出题追踪`（或覆盖为本轮新生成的题目），重复步骤 1

**文件格式（旧题库）:**

```markdown
# 面试旧题库 — {简历文件名}

> 本文件只用于去重查询。新轮次出题前，检查旧题库确认题目未被出过。

## Round 1 — {YYYY-MM-DD}
### Go
- [x] goroutine 调度模型（浅层）

### MySQL
- [x] MVCC 实现原理（中层）

## Round 2 — {YYYY-MM-DD}
### Go
- [x] GC 三色标记（中层）
```

**文件格式（出题追踪，当前轮次）:**

```markdown
# 面试出题追踪 — {简历文件名}

> 当前轮次题目。出题前先去 `面试旧题库-{简历文件名}.md` 查重。
> 本轮结束后，已出题目（[x]）迁移到旧题库，本文件重新生成为下一轮题目。

## Round N 中层题 — {YYYY-MM-DD}
### Go
- [ ] context.Context 在 gRPC 调用链里怎么传递？
- [ ] goroutine 泄漏怎么发现和控制？

### MySQL
- [ ] 索引设计：以白条表为例，建了哪些索引？
```

**规则**:
- 每道题一行，`[x]` = 本轮已出过，`[ ]` = 本轮未出过
- 本轮结束后：将 `[x]` 题目迁移到 `面试旧题库-{简历文件名}.md`，追加到对应领域下（标注所属轮次）
- 下一轮开始：清空本文件，现场生成新题写入 → 查旧题库去重 → 开始新一轮
- 旧题库是**去重工具**，出题追踪是**当前轮次工作表**。追踪文件不预定义题目——每道题现场生成后写进去
- **命名必须包含简历文件名**：`面试旧题库-{简历文件名}.md` 和 `面试出题追踪-{简历文件名}.md`，不要用裸名
- **创建新追踪文件前**：检查目录下是否有旧版追踪文件（裸名或旧简历版本），如果有，先读取其内容并合并到旧题库中，再删除旧版。不要丢弃历史出题记录

### Step 13: 面试准备文档归档

每次重新生成面试准备文档前，agent 必须归档旧版本：

1. 检查同目录是否已有 `面试准备-{简历文件名}.md`
2. 如果存在，重命名为 `面试准备-{简历文件名}-{YYYYMMDD}.md`（使用当天日期）
3. 保留最新版本为 `面试准备-{简历文件名}.md`（当前工作文档）

归档保留完整历史，方便用户回溯对比各版本。

**额外清理（每次归档时顺手做）：**
- 删除比当前归档更早的归档版本（只保留最近一次）
- 检查是否有裸名旧文件（如 `面试出题追踪.md`）需要合并到新命名的追踪文件
- 确保目录下所有面试相关文件都使用 `{简历文件名}` 后缀

### Step 14: Output & Save

Generate the complete prep document and save to `./面试准备-{简历文件名}.md`.

**Document structure:**
```
# 面试准备 — [简历文件名]

## 总览
[1 paragraph: resume's interview posture, strengths, what to emphasize]

## 自我介绍
[3 hook options, pick one]

## 基础技术预演
[by technology, 6-8 sections]

## 项目逐条问答
[organized by project, each bullet with depth tiers + safety boundary]

## 技术选型防御
[standalone section, all "why X over Y"]

## 业务场景压力测试
[by project, 2 scenarios each]

## 系统设计题库
[3-4 classic system design + 2-3 project extension solution design questions, each with 5 layers: requirements clarification, capacity estimation, architecture design, key trade-off decisions, interviewer follow-up chain]

## 行为面试映射
[table format]

## 反问环节
[3-5 recommended questions]

## 脆弱点审计
[3-5 items with defense]

## 面试节奏建议
[what to emphasize / move past, time allocation]
```

---

## Question Depth Rules

**Shallow questions** must be answerable by anyone who actually did the work. If the user can't answer a shallow question, the bullet is likely fabricated — flag it.

**Mid questions** test whether the user made decisions or just followed orders. A developer who " participated" (参与) won't have solid answers; one who "owned" (负责) will.

**Deep questions** are optional showcase opportunities. Not knowing a deep answer isn't a red flag — but knowing one strongly signals seniority.

**Volume control:**
- 3-project resume with 4-5 bullets each → ~20 questions total (not 60+)
- Old work experience → 2-3 questions per role
- Thin bullets (pure business description) → skip or 1 shallow question
- Per-project cap: 8 questions max; per-bullet cap: 3 questions max
> 题量依据：国内技术面试总时长 45-60 分钟，项目问答环节通常占 20-30 分钟。按每题平均 2 分钟回答计算，一个 3 项目简历最多能覆盖 ~20 个问题。超过这个数量会导致每个问题回答浮于表面，面试官没有时间深挖真正有价值的点。每个项目 8 题上限是为了给新技术栈/亮点项目留出空间，避免把时间全花在最旧的项目上。

---

## Pitfalls & Lessons Learned

### Pitfall 1: Scripted answers sound like recitation

Memorizing word-for-word answers makes you sound like a robot. Practice the Hook → Structure → Landing flow, but vary the exact wording each time. The structure is your anchor; the words are flexible.

### Pitfall 2: Not matching question depth to bullet version

Asking deep questions for a conservative-version bullet will expose the gap between the resume and reality. If a bullet was written conservatively, cap questions at mid-level. If it was written boldly, prepare extra defense.

### Pitfall 3: Over-preparing one project, under-preparing fundamentals

Resume-driven questions feel "preparable" so candidates over-index on them. But Chinese interviewers spend 30-40% of time on fundamentals (Go internals, MySQL indexes, Redis data structures) — questions that aren't on the resume. Don't skip Step 2.

### Pitfall 4: Wandering into forbidden territory

A candidate who says "I know pgbouncer's principle..." on a project where they never used connection pooling invites the follow-up "so what pool size did you configure?" Now they're in ❌禁区. Only mention boundary-zone knowledge after clearly stating "这部分我没有亲手做过，但我知道原理..."

### Pitfall 5: 反问环节问错问题

Asking "你们用什么技术栈" when the JD clearly lists it, or asking about salary in the technical round, signals poor judgment. Prepare 3 specific questions that show you researched the company.

### Pitfall 6: 自我介绍像背简历

Reciting your resume word-for-word wastes the interviewer's time — they already read it. The self-introduction should be a 60-second narrative that connects the dots between your experiences, not a chronological listing.

### Pitfall 7: 防御话术用"弱框架"被面试官拆穿

面试官追问"为什么用 X 不用 Y"时，用不成立的框架（如"Redis 做短锁、etcd 做长锁"——其实两个都能做长短锁）会被拆穿。正确的防御模式：

**模式：真实分工 + 降级路径**
```
不是说"X 适合 A 场景、Y 适合 B 场景"
而是说"在这个项目里 X 负责 A，Y 负责 B，因为实际约束是..."
```

**模式：两层锁防御（外层性能 + 内层兜底）**
```
面试官: "如果 etcd 挂了锁怎么办？"
不是: "etcd 很可靠，不会挂。"
而是: "分两条降级路径：定时任务锁跳过本轮下轮补偿，额度扣减锁降级到 MySQL 行锁。外层锁做性能，内层锁做底线。"
```

关键技术选型防御的构造步骤：
1. 先明确真实分工（哪个工具做什么）
2. 指出如果主方案失效的降级路径（不是"不会失效"）
3. 把每个追问拆成具体场景（如 cron 场景 vs 请求级场景），分别给出降级策略

### Pitfall 9: 面试模拟中追问质量不过关——三种劣质问法

When acting as a mock interviewer, avoid three categories of bad questions that waste the candidate's time and erode trust:

**类型一：虚构并发竞态**

Do NOT fabricate concurrency conflicts between operations that the candidate's system wouldn't actually have. Before asking "拆分的 freeze_amount 更新和转让的状态校验之间怎么互斥", verify: do these two operations happen at the same lifecycle stage? By the same actor? If they don't, there's no real race condition. You're asking the candidate to defend against a problem that doesn't exist.

**检测方法**：画两个操作的时间线。如果它们在同一个请求/事务/角色内才可能并发，否则你的追问是硬凑的。

**类型二：质疑组件级已有保证**

Do NOT frame well-known component guarantees as if they're design gaps the candidate overlooked. "canal 重启后消费位点怎么对齐" — canal records its binlog position, MySQL replication handles this. "Kafka 重启后 offset 怎么对齐" — Kafka persists consumer group offsets. "ES 写入失败数据丢了怎么办" — at-least-once + commit-after-write means it doesn't.

The candidate will correctly point out these are solved at the component level, making you look like you don't understand the stack. You just wasted a question.

**类型三：框架 API 细节追问**

Do NOT push into trivia-level implementation questions when the candidate has already demonstrated architectural understanding. "trace-id 在 gRPC metadata 里具体用哪个 key 传递的" — this tests recall of a framework constant, not engineering judgment. A candidate who can explain the architecture, the business logic, and the failure modes doesn't need to recite API names.

**类型四：编造不存在的外部系统细节（穿帮风险）**

Do NOT invent external system behaviors that the candidate has never confirmed. This is the single most dangerous category of bad questioning for mock interviews — it fabricates a false premise and builds follow-up pressure on top of fiction.

Examples of forbidden invented details:
- ❌ "建行会主动提供结算日历" — unless the user explicitly said they receive a settlement calendar from CCB
- ❌ "银行会发通知临时调整结算日" — unless the user described this notification mechanism
- ❌ "外部系统突然改了接口返回格式但没通知你" — unless the user mentioned this happened

Before asking any follow-up about external systems, agent must self-audit:

> "用户在之前的回答里确认过这个细节吗？这是我加的还是用户加的内容？"

If agent added it — skip immediately. Pressure-testing scenarios must be grounded in what could realistically happen in the user's actual architecture, not what agent imagines could happen in a generic system.

**Correct approach**: Before asking any follow-up question, run this filter:
1. Does this operation actually exist in their system? (not my inference)
2. Does the concurrency/consistency concern reflect their real architecture? (not a generic pattern)
3. Does answering this question demonstrate engineering judgment? (not API recall)
If any answer is "no", skip the question.

### Pitfall 12: 技术点评中的代码示例不正确——降低信任度

模拟面试中对技术回答做点评时，如果给出错误的代码示例或纠错，会降低用户的信任度：

- ❌ 用 `*User` 返回值类型解释 nil interface 坑时，`*User` 作为具体类型而非接口类型，坑不成立
- ❌ 说"go-zero 默认超时 2s"而实际是 3s
- ❌ 把 Redlock 说成 etcd concurrency.Mutex，搞混用户项目的实际技术栈

**检测方法**：交付代码示例前，确认：

1. 这个例子真的能触发题目描述的问题吗？（nil interface 坑必须用 `interface{}` 或者 `error` 接口作为返回值类型才成立）
2. 这个例子和用户的真实项目技术栈一致吗？（etc vs Redlock 不一样）
3. 引用的参数值准确吗？（go-zero RPC client timeout default 是 3s，不是 2s）

**通用验证规则（出题和点评前自查）**：

| 验证维度 | 检查项 | 反例 |
|---------|--------|------|
| 代码示例正确性 | 示例代码真的能复现描述的问题吗？nil interface 坑的返回值类型必须是接口（`error`、`interface{}`），用具体类型（`*User`）坑不成立 | `func getUser() *User` 返回 nil — 这不是 nil interface 坑 |
| 框架参数准确性 | 引用的框架默认值、参数名准确吗？不确定就查文档或标注"据文档" | go-zero RPC client timeout default 是 3s，不是 2s |
| 工具分工一致性 | 点评中提到的工具和用户项目真实技术栈一致吗？Redis Redlock 不等于 etcd concurrency.Mutex，不要混用 | 用户项目用 Redlock，点评却说 etcd 分布式锁 |

如果发现错误，立即纠正并感谢用户指出。不要先用错再补救——最好在出题和点评前先自查。

### Pitfall 11: 模拟面试中过渡句带"资格预审"语气

在基础技术预演结束后切换到下一板块时，不要用挑战性语气：
- ❌ "还是你觉得自己没问题想跳过？" — 听起来像在质疑能力
- ❌ "你需要继续练吗？" — 暗示对方不够好
- ✅ "基础 3 题结束。继续下一领域，还是你想多练这个？" — 直接给选项

模拟面试的过渡应该像考官自然推进，不像教练质疑学生。给出两个中性选项即可。

**过渡句式表（精确措辞）**：

| 场景 | 推荐句式 | 说明 |
|------|---------|------|
| 板块结束 → 下一板块 | "X 基础 3 题结束。继续 Y，还是你想多练 X？" | 给两个中性选项，不暗示某个板块弱 |
| 板块结束 → 没有更多内容 | "X 全过了一遍。继续 Y？" | 简洁推进，不加评价 |
| 板块完整结束 | "X 全部完成。接下来你想做 Y、Z，还是休息？" | 列出剩余选项，包含休息选项 |
| 单题过渡 | "进下一题。" | 最简洁，不拖泥带水 |

**不要用的句式**："要不要再练练这个？""你觉得这个板块你掌握了吗？""这块你还需要加强吗？"——这些都有隐形评价，听起来像考官在打分。

### Pitfall 10: 为"最大坑"问题编造故事——必然被技术审查击穿

面试官必问："你遇到过最大的坑是什么？"或"说一个你踩过的最大的技术坑"。这道题测试的是**反思能力**，不是你的项目有多刺激。

**禁止做的事**：为候选人编造一个看起来"戏剧性"的坑（goroutine 泄漏、并发穿透、数据管道延迟等）。经验丰富的候选人会在技术审查中一眼看穿编造的场景是否可能在他们的系统里发生：

| 编造的坑 | 为什么会被击穿 |
|---------|-------------|
| Redis 连接池耗尽 | B2B低频项目根本不会打满连接池 |
| MySQL RR 隔离级别穿透 | 7年经验的开发者不可能上线后才发现 |
| 多实例 cron 重复执行 | 微服务基础常识，测试阶段就该发现 |
| canal 导致 MySQL 慢查询 | canal 是 binlog 订阅者，不会拖慢 MySQL |

**检测信号**（agent 进入编造模式时的特征）：
- 场景需要引入多个组件交互才能成立（"MySQL 被 canal 拖慢，然后 relay goroutine 超时，然后..."）
- 用户在追问时反复说"我不理解你描述的问题"或"这个描述我一头雾水"
- 用户指出场景中的某个因果链不成立（"canal 作为从机只是接收 binlog，这会导致 MySQL 变慢吗？"）
- 用户沉默或给出简短否定后 agent 又换一个方向重新编

**正确做法**：

1. **先确认项目特点**：B2B/C2C？高频/低频？几人在做？这些决定了"坑"的上限。
2. **区分三个问题的不同意图**：
   - "最大的坑" → 你犯了什么错、学到了什么。要的是**错误+反思**。
   - "最大的技术挑战" → 你克服了什么困难。要的是**难度+方案**。
   - "最后悔的技术决策" → 你事后觉得换个方案会更好。要的是**选择+复盘**。
   这三个是完全不同的问题，不能用一个答案串。
3. **如果项目确实没有单独的大坑**，提供诚实回答框架：
   - **承认项目类型**："这个项目说实话没遇到过一个单独的大坑——B2B 低频、团队小、节奏可控。"
   - **转向可说的**："如果你问的是最大的技术挑战——那是白条拆分的额度并发控制，我反复改过三四版。"
   - **或转向学习**："小问题积累起来让我养成了一个习惯：任何外部依赖都假设它会在某个时刻失败。"
4. **如果必须编造**，只用一种方向：**外部系统的不可控变更**。比如银行改了接口返回格式但没通知你，你排查了半天——这不是你的低级错误，是外部依赖的客观风险。但这类故事的前提是候选人确实对接过外部系统。
5. **如果 candidate 追问时沉默了**，不继续编下一个。停下来问他："你的项目里有没有一个真实的、让你当时停下来重新想方案的时刻？哪怕很小。"

**关键原则**："我没有大坑"比"我编了一个大坑"强一百倍。面试官听得出编造——编造的故事会有多余的因果链、不自然的复杂度和防御性细节。诚实的"没有"加上有深度的转向，比编造出来的故事更有说服力。

### Pitfall 8: 不识别压力面（interviewer stress-testing）

Some companies (字节跳动、拼多多、快手等) are known for deliberate pressure-testing tactics:
- Aggressive follow-up drilling until you hit your knowledge boundary
- Deliberate silence after your answer, testing whether you'll nervously fill the gap
- Contrarian questioning: "你真的觉得这个方案最优吗？"

These are NOT punishments or signs the interview is going badly. The interviewer is mapping your knowledge boundary — they want to know where you stop. The correct response: calmly state your boundary when you reach it. "这部分我没有深入做过，没有更多细节可以分享了。" is a perfect answer. Do NOT guess, bluff, or take the contrarian question personally.

**How to prepare:** During practice, have someone drill you past your comfort zone on purpose. Practice saying "这个我没做过" calmly and without apology. The ability to state your boundary confidently signals seniority more than guessing does.

### Pitfall 13: 文件生命周期失控——目录变成垃圾场

多轮模拟面试跨多个 session 时，文件会快速积累：旧版追踪文件、多次归档、裸名文件、版本不一致的副本。如果 agent 不主动清理，用户下次打开目录会看到一团混乱。

**必须做的清理（每轮开始前）：**

| 检查项 | 动作 |
|--------|------|
| 裸名追踪文件（`面试出题追踪.md`） | 读取内容 → 合并到 `面试出题追踪-{简历}.md` → 删除裸名 |
| 多个归档版本 | 只保留最近一次归档，删除更早的 |
| 追踪文件和面试准备文档的简历后缀不一致 | 统一重命名为 `- {简历文件名}.md` 后缀 |
| 上一轮的临时文件 | 清理 |

**命名规范：**
- 面试准备：`面试准备-{简历文件名}.md`
- 出题追踪：`面试出题追踪-{简历文件名}.md`
- 归档：`面试准备-{简历文件名}-{YYYYMMDD}.md`

**不要做的事：**
- 创建新文件时不检查同目录下是否有旧版 → 旧版变成孤儿
- 归档时不删除已归档的原始文件 → 两份内容重复
- 用裸名（不带简历后缀）创建文件 → 多份简历时无法区分

### Pitfall 14: 编造项目系统性穿帮防御

简历中存在基于合理编造但未实际上线的项目时（如供应链金融平台、内部工具等），模拟面试中 agent 必须启动系统性穿帮防御机制，而非仅靠 Pitfall 10 覆盖"最大坑"单一场景。

**🔴 CHECKPOINT: 模拟面试开始前 — 检查 memory**

Agent 必须先检查用户 memory 中是否有以下标记：
- "项目未上线"或"基于合理编造"标记
- "穿帮监控"相关记录
- 已标注的穿帮高风险点（如银行结算日历、具体业务量、生产环境运维细节、无法给出代码实现的技术细节）

如果存在以上任一标记，**整个模拟面试必须在穿帮防御模式下运行**。

**面试进行中 — 细节真实性自检:**

每当面试官（agent）准备追问一个细节时，必须自问：

> "这个细节在用户的项目里真实存在吗？是我推断出来的，还是用户明确说过的？"

如果答案是"推断出来的"——立即跳过该追问。

**高风险话题 — 追问前先提示用户:**

以下话题属于穿帮高风险区，agent 在追问前**必须先向用户发出提示**：

| 高风险话题 | 提示模板 |
|-----------|---------|
| 生产环境运维细节 | "如果你的项目未实际上线，可以跳过运维细节。是否继续？" |
| 具体 QPS / 并发数字 | "如果没有真实压测数据，这个可以标注为禁区。" |
| 银行/第三方接口具体对接流程 | "如果你没实际对接过这个接口，我们不展开——可以标注为禁区。" |
| 无法给出代码实现的技术细节 | "这个需要实际写过才能答——如果你没写过，我们跳过。" |

用户确认"跳过"后，agent 在出题追踪文件中将该题标记为 `[x] 禁区`，后续轮次不再出。

**agent 自己编造细节 — 立刻撤回:**

如果 agent 在追问中自己补充了用户从未提及的细节（如"银行提供结算日历"、"银行会发通知调整结算日"、"建行临时变更结算日"），一旦意识到，必须：

1. **立刻停止当前追问**
2. **向用户明确指出**: "我刚才说的是我自己推断的，这不属于你的项目。我们撤回这个追问。"
3. **不要尝试"圆回来"或换一个方向继续追问同一个虚构前提**

**检测信号（agent 正在编造模式）:**
- 追问的前提依赖之前自己补充的、用户从未确认的假设
- 用户说"我不理解你描述的问题"或"这个我没说过"
- 追问需要多个虚构组件交互才能成立
- 用户在多次追问中保持沉默或给出简短否定

如果出现以上任一信号，立即停止追问，回到用户真实的项目描述中。宁可少问，不可编造。

### Pitfall 15: 把追踪文件当预定义题库——出题僵化

追踪文件是**去重工具**，不是预定义题库。以下行为是错误的：

- ❌ 在上一个 session 的追踪文件中预先写入一堆 `[ ]` 题目（如"Go: time.Now() 和 MySQL time.Time 比较"），下一个 session 直接从池里"抽取"
- ❌ 看到追踪文件里有 `[ ]` 题目就直接拿来用，不检查这些题是否匹配用户的实际经验年限和技术栈
- ❌ 出题时引用"题目池已耗尽"作为跳过某领域的理由——题目是现场生成的，不存在"池耗尽"

**正确做法**：每轮出题时，基于用户的**实际经验年限**和**简历技术栈**现场生成题目，然后查追踪文件排除已出过的。追踪文件里没有预存题目——它只记录"出过什么"，不决定"接下来出什么"。

**为什么旧 agent 会犯这个错**：为了省事，在生成追踪文件时顺手把 8 道中层题也写进去作为占位符。下一个 session 加载 skill 后直接从里面"抽取"，完全不结合用户实际情况——比如问一个用 go-zero + etcd 做服务发现的用户"Redis Cluster vs Sentinel 区别"，这题跟他简历毫无关系。

### Pitfall 16: 系统设计题中假设外部系统行为——设计题也有穿帮风险

Pitfall 14 覆盖了模拟面试中的穿帮防御，但系统设计题同样存在穿帮风险，尤其是项目延伸方案设计题。生成这类题目时，外部系统的能力应作为未知变量处理。

**示例：清算调度设计题**
- ❌ 直接假设："银行支持按唯一兑付 ID 幂等" — 未确认的架构推断
- ✅ 正确写法："设计时需要银行提供幂等支持——如果银行不支持，在适配层通过唯一兑付 ID + 本地状态机做幂等兜底"
- ✅ 也可将幂等性作为需求澄清的一部分：在第 1 层询问"银行接口是否支持幂等？"

**通用规则**：项目延伸设计题中的外部系统行为（银行接口、资金方协议、第三方能力），写入前必须自问：
> "这是用户确认过的，还是我推断的？"

如果是推断的——将其转化为假设条件或需求澄清的一部分，而非当作已知事实。

### Pitfall 19: 系统设计题中用户是第一次做该题型——需要先教框架再推进

面试准备文档的 Step 6 假设用户能直接进入 5 层递进（需求澄清 → 容量估算 → 架构设计 → 关键决策 → 追问链）。但用户可能是**第一次做系统设计题**，遇到容量估算会说"不知道该如何估算"。

**🔴 CHECKPOINT: 用户表示"不知道如何估算"时，先教框架再推进**

当用户对容量估算、字节估算、组件请求路径等基础概念说"不知道"、"不理解"、"没有理解...是什么意思"时：

1. 不要在用户说"不知道如何估算"后直接跳到架构设计——先停下来教框架
2. 加载 `references/system-design-capacity-estimation.md`，教三步法（拆指标 → 算存储 → 加缓存）
3. 对用户的"题外话"技术质疑（如"短码不需要长度一致吗"、"Go 不能处理请求为什么还要 Nginx"）**不打断、不跳过**——这些问题展示用户的技术思考深度，是加分项而非偏离主线
4. 系统设计题天然会有更多侧问题和 detour，agent 应自然处理完后回到主线，不当作"流程中断"

### Pitfall 20: 容量估算的字节估算被用户质疑——需要解释估算依据

当用户问"是如何预估短码8B，原始URL200B"时，这是合理的技术追问——用户想知道你的估算来源而非质疑你。

**正确做法**：逐字段拆解依据（短码 base62 编码 ≈ 7B、URL 取 google 论文均值 200B、时间戳 DATETIME 5B / BIGINT 8B），并主动承认"量级估算 ±20% 面试官不计较，他们看的是你有没有估算意识而非精确到个位数"。

**不要说的**："这是经验值"——用户要的是推理过程，不是权威压人。

### Pitfall 17: 系统设计题的技术事实准确性——框架 API 和组件能力

生成设计题时引用的技术框架特性必须准确，尤其是与简历技术栈直接相关的工具。

**已知的错误示例：**
- ❌ "go-zero 的 PeriodLimit 是基于 Redis 的令牌桶" — PeriodLimit 是滑动窗口实现，令牌桶是 TokenLimit
- ❌ "K8s CronJob + etcd 选主" — CronJob pod 是临时性的，etcd 选主更适合常驻 Deployment。若用 CronJob 模式，concurrencyPolicy: Forbid + Redlock 去重是更自然的组合

**检测方法**：生成设计题后，对每个引用简历技术栈的断言做反向检查：
1. 这个工具的机制真的是我说的这样吗？不确定时查文档
2. 这个架构组合（如 K8s 资源 + 协调机制）在实际工程中是否合理？

### Pitfall 18: 对账/一致性设计中的权威源混淆

在混合「内部数据一致性」和「外部对账」的场景中，容易混淆权威源。

**错误模式**：同一层描述中既说"以 MySQL 为准"又说"以银行文件为准"

**正确模式**：按数据源对拆分权威源：
- 内部对账（MySQL ↔ ES）：以 MySQL 为权威源（事务保证）
- 外部对账（MySQL ↔ 银行文件）：以银行文件为权威源（银行是资金实际操作方）

两个原则不矛盾，但要显式拆开，避免读者困惑。

---

## Reference Documents

- `references/distributed-lock-defense.md` — 分布式锁选型防御模式：分级选型（Redis短锁+etcd长锁）、Redlock防御（fencing token + MySQL兜底）、银行结算日历应答、降级路径设计
- `references/local-message-table-defense.md` — 本地消息表防御模式：Transactional Outbox 三部分结构（同事务写入 + relay 投递 + 幂等消费）、DTM vs 自建决策框架、面试追问链
- `references/system-design-capacity-estimation.md` — 系统设计容量估算入门框架：三步法（拆指标/算存储/加缓存）、常见字段字节估算参考值、面试话术模板。当用户第一次做系统设计题说"不知道如何估算"时加载此文件先教框架再推进。

## Related Skills

- `resume-polish`: Polish resume before running interview-prep. The polish version (conservative/moderate/bold) determines question depth limits.
- `humanizer`: Apply to interview answers to ensure they sound natural in spoken Chinese, not like written documentation.
