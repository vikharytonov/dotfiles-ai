# Project Quality Constraints

Non-negotiable engineering contract for humans and AI agents. Agents MUST read this file at session start and MUST NOT lower any threshold or silence any check without explicit user approval.

## 1. Verification Commands (Single Gate)

Run the single quality gate before marking any task complete:

| Gate | Command | Required Outcome |
| :--- | :--- | :--- |
| **Full Check** | `<e.g., npm run check>` | Exit code `0` (typecheck + lint + tests) |
| **Typecheck** | `<e.g., npx tsc --noEmit>` | `0` errors (`strict: true` / `pyright`) |
| **Lint** | `<e.g., npm run lint>` | `0` errors, `0` new warnings |
| **Tests** | `<e.g., npm test>` | 100% pass, `0` skipped tests |

## 2. Hard Invariants (EARS)

- The codebase `MUST NOT` introduce `.skip`, `.only`, `it.todo`, `@ts-ignore`, `@ts-expect-error` (outside negative type tests), `eslint-disable`, `# type: ignore`, or `# noqa` to pass checks.
- The codebase `MUST NOT` lower test coverage, lint strictness, or performance budgets without an approved ADR in `docs/adr/`.
- `WHEN` handling untrusted input (HTTP, CLI, URL, webhooks), the boundary `MUST` parse it via a strict schema validator before use.
- `WHEN` mutating multiple dependent records, the repository layer `MUST` use an atomic DB transaction and parameterized queries.
- The repository `MUST NOT` commit `.env` files, secrets, tokens, or private keys.

## 3. Thresholds & Budgets

Fill in project-specific targets during Phase 4 (Walking Skeleton) and delete rows that do not apply.

| Dimension | Minimum Bar | Enforcement |
| :--- | :--- | :--- |
| **Unit / Integration Coverage** | `<e.g., ≥80% domain logic>` | CI coverage check |
| **Accessibility (UI)** | `WCAG 2.2 AA`, `0` critical/serious axe violations | Component tests + `accessibility-auditor` |
| **Web Performance (UI)** | `LCP ≤2.5s`, `INP ≤200ms`, `CLS ≤0.1` | Lighthouse / `web-performance-auditor` |
| **API Latency (p95)** | `<e.g., ≤200ms>` | Integration / load test |
| **Documentation** | `README.md` ≤150 lines, `docs/*.md` ≤250 lines, `0` broken links | `verify-docs.sh` + `pre-commit` |
