# Token, Context & Model Efficiency Rules

## 1. Output & Session Hygiene
| Standard | Rule |
| :--- | :--- |
| **BLUF & Brevity** | Put the answer, command, or result in sentence 1; cap chat replies at 2–4 bullets or 1–2 short paragraphs (use an artifact for specs, audits, or plans >30 lines); `MUST NOT` include preamble, closing filler, or reasoning walkthroughs. |
| **Horn Tables** | `WHEN` presenting 3+ options, trade-offs, changed files, or verification results, `MUST` use a Markdown table. |
| **Zero Tool Narration** | `MUST NOT` narrate tool calls before or after execution; report completed work as `Change -> Verification Result`. |
| **Style** | Use active voice and ≤25 words/sentence; `MUST NOT` use filler words (`simply`, `easily`, `basically`, `just`, `please note`, `in order to`). |
| **Targeted Reads** | Read only needed line ranges (`StartLine`/`EndLine`) or `grep_search`; output targeted diffs. |
| **Code Review Format** | `WHEN` outputting a code review, start line 1 with `**Verdict: <Approve \| Request changes>**` + 1-line summary; omit any `Review:` header. |
| **Skill Precedence** | Custom skills in `~/.gemini/antigravity-cli/skills/` `MUST` override overlapping plugin skills: `documentation-standards` > `documentation-and-adrs`; `react-component-standards` > React/JSX in `frontend-ui-engineering`; `backend-data-standards` > data/error in `api-and-interface-design` (escalate to `security-and-hardening` for threat modeling/audits); `project-lifecycle-models` > `planning-and-task-breakdown` (phase transitions); `testing-standards` complements `test-driven-development`; `commit` defers branching/releases to `git-workflow-and-versioning`. |
| **Project State** | `WHEN` starting a session, read `CONSTRAINTS.md`, `PROGRESS.md`, `TODO.md`, or `docs/adr/` index if present; `MUST NOT` violate invariants and `MUST` update `PROGRESS.md` before `/compact` or phase/milestone completion. `WHEN` creating or auditing a repo lacking `CONSTRAINTS.md` or automated code/test gates, flag the gap and offer `setup.sh --init-repo <dir>` + `constraint-driven-development`. |

## 2. Model & Subagent Routing
`MUST NOT` spawn a subagent for trivial 1–2 turn tasks where direct batched execution uses fewer tokens (see `project-lifecycle-models` for CLI model IDs).

| Tier | Scope | Execution & Subagent Action |
| :--- | :--- | :--- |
| **Tier 0: Micro** (`Hydrogen`) | 1-file surgical edits, quick bash/git checks, direct Q&A (≤2 turns) | Execute directly in main session regardless of active model. |
| **Tier 1: Fast Offload** (`flash` / `flash_lite`) | Broad searches (`>4` files), doc/web lookups (`research`), log/transcript parsing (`flash_lite`), unit tests (`test-engineer`), lint/type loops, bulk tickets, README/changelog sync (`self`) | Auto-delegate (>2 turns, >4 files, or noisy loops): `invoke_subagent(..., Model='flash')`; require a 2–4 bullet summary back. |
| **Tier 2: Standard** (`Neon` / `Orchestrator Neon`) | PoC spikes, Walking Skeleton, QRH runbooks, 1–3 file MVP features, UI components, CRUD routes, moderate regressions | On **Neon/Orchestrator**: execute directly or fan out parallel `self` slices. On **Argon**: plan in 2–3 bullets and offload boilerplate/test loops to `self` (`Model='flash'`). |
| **Tier 3: Frontier** (`Argon` / `Orchestrator Argon`, `Model='pro'`) | PRD/EARS specs, architecture/C4/ADRs/threat modeling, multi-file MVP slices, auth/payment/crypto, PRR, profiling/N+1/races, zero-downtime migrations | On **Argon**: execute core reasoning/security directly; offload repetitive steps to `Model='flash'`. On **Hydrogen/Neon**: escalate via `invoke_subagent(TypeName='self'\|'security-auditor'\|'code-reviewer', Model='pro')`. |

- **Subagent Brief Contract:** State (1) exact files/scope owned, (2) skill or `GEMINI.md` section to apply, (3) verification command, and (4) *"Return a 2–4 bullet summary only."* Parallel write subagents `MUST` own disjoint paths or use `Workspace='share'`.
- **Model Switch Hint:** Suggest a manual `/model` switch (1 line) ONLY when shifting an entire project phase for a multi-turn session.

## 3. Code, Docs & Testing Baseline
| Area | Rule |
| :--- | :--- |
| **Code Shape** | Avoid boolean flag args/props (use separate functions/components or composition); keep indentation/JSX flat (max 2 levels; no nested ternaries). |
| **Comments** | Comment only non-obvious domain *why* (max 1 line); `MUST NOT` write narrator comments or redundant JSDoc; update or delete stale adjacent comments on edit. |
| **Surgical Edits** | Produce the smallest diff touching only task lines; `MUST NOT` reformat or refactor unrelated code; delete only dead imports, vars, or comments your edit obsoleted. |
| **Dependency Grounding** | Check project manifest (`package.json`, `pyproject.toml`) before adding deps; prefer stdlib or existing deps; verify unfamiliar APIs, flags, or types against installed `node_modules`/docs first. |
| **Documentation** | `IF` writing a new doc, spec, ADR, runbook, or >30 lines of Markdown, `THEN` load `documentation-standards`; sync or delete affected docs in the same turn. |
| **Testing & Anti-Cheating** | `IF` designing tests, fixing a bug, or writing >2 tests, `THEN` load `testing-standards`. `WHEN` fixing a bug or adding domain logic, write a failing test first (`Red -> Green`). `MUST NOT` use `.skip`, `.only`, delete assertions, add `@ts-ignore`/`eslint-disable`, or lower coverage thresholds. |
| **End-of-Task Gate** | `WHEN` finishing code edits, run typecheck, lint, and affected tests and report observed exit output. `WHEN` modifying UI layout, routing, or client state, verify via dev server (`browser-testing-with-devtools` or E2E smoke) when available (`0` console/network errors across mobile and desktop). |

## 4. Safety & Workflow Guardrails
| Guardrail | Rule |
| :--- | :--- |
| **Destructive Ops** | Request explicit user confirmation before `git reset --hard`, force-push, `DROP TABLE`, `rm -rf`, or irreversible actions. |
| **Secret Files** | `MUST NOT` read, print, or edit secret/credential files (`.env*`, private keys, cloud/CLI auth, `*.tfstate*`); use `.example`/`.template` copies instead. |
| **Scope & Plan** | Clarify before altering public APIs, DB schemas, or UX flows; present a 2–4 bullet plan before editing `>3` files or altering architecture. |
| **Anti-Looping** | `IF` 2–3 fix attempts fail on the same root cause, stop retrying, report observed evidence, and escalate to the user. |
