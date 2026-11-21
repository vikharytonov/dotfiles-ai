# Token, Context & Model Efficiency Rules

## 1. Output & Tool Hygiene (Minimize Token Burn)
Apply these mandatory rules to every chat response and tool invocation to minimize token burn across turns.

| Standard | Mandatory Rule (`MUST` / `MUST NOT`) |
| :--- | :--- |
| **BLUF & Brevity** | Put the answer, command, or result in sentence 1; cap responses at 2–4 bullets or 1–2 short paragraphs; `MUST NOT` include preamble, closing filler, or reasoning walkthroughs. |
| **Horn Tables in Chat** | `WHEN` presenting 3+ options, trade-offs, changed files, or verification results, `MUST` use a Markdown table instead of prose paragraphs. |
| **Zero Tool Narration** | `MUST NOT` narrate tool calls before or after execution (*"I will now read..."*, *"I updated X to do Y"*); report completed work as `Change -> Verification Result`. |
| **ASD-STE100 Chat Style** | Use active voice and ≤25 words per sentence; `MUST NOT` use filler words (`simply`, `easily`, `basically`, `just`, `please note`, `in order to`). |
| **Targeted Reads & Edits** | Read only needed line ranges (`StartLine`/`EndLine`) or `grep_search`; batch independent tool calls and shell checks; output targeted diffs; recommend `/compact` when context grows long. |

## 2. Automatic Model-per-Task & Subagent Routing
Route tasks to minimize quota/token cost and keep the main context small. The agent `MUST NOT` spawn a subagent for trivial 1–2 tool call tasks where direct execution uses fewer tokens.

| Tier & Models | Scope | Execution & Subagent Action |
| :--- | :--- | :--- |
| **Tier 0: Micro** (`gemini-4-hydrogen-medium`/`high`) | 1-file surgical edits, quick bash/git checks, direct Q&A (≤2 tool calls) | Execute directly in main session (zero subagent overhead) regardless of active model. |
| **Tier 1: Fast Offload** (`Model='flash'` or `'flash_lite'`) | Broad searches (`>4` files), doc/web lookups (`research`), large log/transcript parsing (`flash_lite`), unit tests (`test-engineer`), lint/type loops, bulk Kanban tickets, README/table/changelog sync (`self`) | **Auto-delegate (>2 tool calls):** Spawn `invoke_subagent(..., Model='flash')` with clear brief and rule/skill pointers; require a 2–4 bullet summary back. |
| **Tier 2: Standard** (`gemini-4-neon-medium`/`high`, `gemini-pro-orchestrator-neon`) | PoC spikes, Walking Skeleton (CI/CD, test harness, `CONSTRAINTS.md`), QRH runbooks, 1–3 file MVP features, UI components, CRUD routes, moderate regressions | On **Neon/Orchestrator**: execute directly (or fan out parallel `self` slices). On **Argon**: plan in 2–3 bullets and offload boilerplate/test loops to `self` (`Model='flash'`). |
| **Tier 3: Frontier** (`gemini-4-argon-medium`/`high`, `gemini-pro-orchestrator-argon`, `Model='pro'`) | PRD/EARS specs (`Argon medium`), architecture/C4/ADRs/threat modeling (`Argon high`), multi-file MVP slices (`Orchestrator`), critical auth/payment/HMAC/crypto, PRR, profiling/N+1/races, zero-downtime DB migrations | On **Argon**: execute core reasoning/security directly and offload repetitive file/test steps to `Model='flash'`. On **Hydrogen/Neon**: auto-escalate via `invoke_subagent(TypeName='self'\|'security-auditor'\|'code-reviewer', Model='pro')`. |

- **Subagent Brief Contract:** `WHEN` spawning any subagent, the brief `MUST` state: (1) exact files/scope owned, (2) skill or `GEMINI.md` section to apply (e.g., *"Follow GEMINI.md Section 3 Clean Code"* or *"Load `documentation-standards` skill"*), (3) verification command, and (4) *"Return a 2–4 bullet summary only."*
- **Model Switch Hint:** The agent `MUST` suggest a manual `/model` switch (1 short line) ONLY when shifting an entire project phase for a multi-turn session (load `project-lifecycle-models` at transitions).

## 3. Fundamental Code & Comment Principles (Mandatory Baseline)
Apply these mandatory rules whenever writing, updating, refactoring, or deleting ANY code (React, TypeScript, backend, scripts) or comments.

| Principle | Mandatory Rule (`MUST` / `MUST NOT`) |
| :--- | :--- |
| **Minimal Code (KISS / YAGNI)** | Write the fewest lines possible; keep functions/components small, flat, single-purpose; `MUST NOT` add speculative features, premature abstractions, or single-use wrappers. |
| **Self-Explaining Names** | State intent clearly (`is/has/can/should*` booleans, `handle*` handlers, `on*` props); extract complex conditions into named variables or helpers instead of commenting. |
| **Guard Clauses** | Use early returns (`if (!isValid) return;`, `if (isLoading) return <Skeleton />;`) to keep indentation and JSX flat (max 1–2 levels; no nested ternaries). |
| **Signatures & Constants** | Limit functions to 2–3 args and components to focused props; avoid boolean flag props/args (use separate functions/components or composition); replace magic values with named constants. |
| **Comments as Last Resort** | Comment only non-obvious domain *why* (never *what*), max 1 short line; `MUST NOT` write narrator comments (`// loop through items`, `{/* render header */}`) or redundant JSDoc/boilerplate. |
| **Comment-Code Lifecycle** | `WHEN` modifying or deleting code, inspect adjacent comments and immediately update or delete stale or redundant ones. |
| **Surgical Edits** | Produce the smallest diff touching only task lines; `MUST NOT` reformat, rename, or refactor unrelated adjacent code; delete only dead imports, variables, or comments your edit rendered obsolete. |

## 4. Documentation Principles (Dual-Audience: Human + AI)
Apply these mechanical rules whenever creating, updating, or reviewing Markdown; `IF` writing a new doc, spec, ADR, runbook, or >30 lines of Markdown, `THEN` read `documentation-standards` first.

| Standard | Mechanical Rule (`MUST` / `MUST NOT`) |
| :--- | :--- |
| **Diátaxis & S1000D Caps** | Root `README.md` `MUST` be ≤150 lines (1-sentence purpose, 3–5 command Quick Start, link table to `docs/*.md`); topic docs `MUST` be ≤250 lines with 1 intent (Tutorial, How-To Runbook, Reference, or ADR Explanation). |
| **BLUF & Horn Tables** | Put command, table, or answer in first 3 lines of every section; max 1-sentence intro under headings; **3+ parallel items, CLI flags, env vars, options, or `if/else` paths `MUST` use a Markdown table** (prose banned). |
| **ASD-STE100 Mechanics** | Use imperative active voice (`Run X`, never `You can run X`); cap sentences at **≤20 words** (instructional) / **≤25 words** (descriptive), 1 action/step; ban `simply`, `easily`, `basically`, `just`, `please note`, `in order to`. |
| **EARS + RFC 2119 Specs** | Write requirements/PRDs/ACs with uppercase `MUST`/`MUST NOT`: Ubiquitous (`The <system> MUST...`), Event (`WHEN <trigger>...`), State (`WHILE <state>...`), Error (`IF <condition>, THEN...`), Optional (`WHERE <feature>...`). |
| **C4, ADRs & QRH** | Express architecture via C4 `mermaid` diagrams and 1-page ADRs (`docs/adr/NNNN-slug.md`: `Status -> Context -> Decision -> Consequences`); pair runbook steps with `Action Command -> Expected Verification Output` and `Rollback`. |
| **Docs-as-Code & Models** | `MUST NOT` duplicate code, types, or `package.json` in prose; sync or delete affected docs in the same turn. Route: `gemini-4-hydrogen-medium`/`high` (README/table/changelog sync), `gemini-4-neon-medium` (QRH/modularization), `gemini-4-argon-medium`/`high` (EARS/C4/ADRs). |

## 5. Testing & Verification Principles (Clean Code Ch. 9 + Khorikov + Dodds + EARS)
Apply these mandatory rules whenever writing, updating, or running tests; `IF` designing a test suite, fixing a bug, or writing >2 tests, `THEN` read `testing-standards` first.

| Principle | Mandatory Rule (`MUST` / `MUST NOT`) |
| :--- | :--- |
| **Red-Green & F.I.R.S.T.** | `WHEN` fixing a bug or adding domain logic, `MUST` write/run a failing test (`Red`) before production code (`Green`). All tests `MUST` be **F**ast, **I**ndependent (zero shared mutable state), **R**epeatable (offline/deterministic), **S**elf-Validating, and **T**imely. |
| **Clean Tests (AAA & DAMP)** | Structure tests as flat **Build–Operate–Check (AAA)** separated by blank lines (**`MUST NOT` write `// Arrange`, `// Act`, `// Assert` narrator comments**); enforce 1 behavioral concept per test, **DAMP** self-contained setup, and **zero control-flow logic (`if/else`, `for`, `try/catch`)** inside test bodies. |
| **Behavior Over Implementation** | Assert on observable outcomes (return value, public state change, or external boundary call); `MUST NOT` assert on private helpers, internal hook state, or internal function call counts. |
| **Mock Only External Boundaries** | Prefer `Real Implementation > In-Memory Fake > Stub > Mock`. `MUST` mock only unmanaged out-of-process boundaries (3rd-party HTTP/OAuth/Stripe APIs, clock, randomness); `MUST NOT` mock internal modules or pure helpers. |
| **EARS, BVA & UI Locators** | Map every EARS spec clause (`WHEN`/`WHILE`/`IF-THEN`) 1:1 to a test case plus **Boundary Value Analysis** (`min-1, min, max, max+1, empty/null`). UI/E2E tests `MUST` query by accessibility semantics first (`getByRole` > `getByLabelText` > `getByText` > `getByTestId`; `MUST NOT` query by CSS class). |
| **Anti-Cheating & Model Routing** | `MUST NOT` use `.skip`, `.only`, delete assertions, add `@ts-ignore`/`eslint-disable`, or lower coverage thresholds to pass CI. Route: `Model='flash'` (`test-engineer` / `self`) for >2-step unit test generation & runner loops; `Neon` for integration/component tests; `Argon` (`Model='pro'`) for security, concurrency, and test architecture. |
