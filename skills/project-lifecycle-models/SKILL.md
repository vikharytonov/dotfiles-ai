---
name: project-lifecycle-models
description: Guides project lifecycle phases (from Discovery and PoC to Architecture, Walking Skeleton, MVP, Launch PRR, Operations, and Migrations) and recommends the optimal Gemini 4 model (Argon, Neon, Hydrogen, or Orchestrator) for each phase and task. Activate when starting a new project, planning phases/epics/Kanban workflows, transitioning between development stages, or choosing which model to use.
---

# Industry-Standard Project Lifecycle & Gemini 4 Model Routing

Ground every project in this 8-phase lifecycle synthesized from **Boehm's Spiral Model**, **DDD**, **ThoughtWorks Evolutionary Architecture**, **DORA**, **NIST SSDF**, **Google SRE**, and **Clean Code**.

## 1. EARS Model & Subagent Routing Rules

- `WHEN` transitioning between project phases, the agent `MUST` tell the user which **Gemini 4 model** (`agy --model <id>` or `/model`) fits the upcoming phase.
- `WHILE` running on a heavier model (e.g., Argon), `WHEN` a sub-task is a lighter tier (`>2` tool calls of research, unit tests, lint fixes, Kanban tickets, or doc syncing), the agent `MUST` spawn `invoke_subagent` with `Model='flash'` instead of asking the user to switch `/model`.
- `WHILE` running on Hydrogen or Neon, `WHEN` a task requires Tier 3 reasoning (architecture, threat modeling, security/PRR audits), the agent `MUST` escalate via `invoke_subagent` with `Model='pro'`.

## 2. Quick Model Reference (`agy models`)

| Model Family | CLI IDs | Core Strength |
| :--- | :--- | :--- |
| **Gemini 4 Argon** | `gemini-4-argon-low` \| `medium` \| `high` | Deep reasoning, architecture, threat modeling, auth/crypto, race conditions, zero-downtime migrations |
| **Orchestrator (Argon)** | `gemini-pro-orchestrator-g1-pro` | Argon planner + Hydrogen executor for complex multi-file MVP slices and refactors (50–70% lower quota burn) |
| **Gemini 4 Neon** | `gemini-4-neon-low` \| `medium` \| `high` \| `xhigh` | Frontier coding, PoC spikes, CI/CD & test harness setup, 1–3 file features, moderate debugging |
| **Orchestrator (Neon)** | `gemini-pro-orchestrator-neon` | Neon planner + Hydrogen executor for rapid PoC prototyping, observability, and standard multi-file features |
| **Gemini 4 Hydrogen** | `gemini-4-hydrogen-low` \| `medium` \| `high` \| `xhigh` | High-speed doc/web research, Kanban tickets, unit tests, lint/type fixes, single-file bugs, docs/changelogs |

## 3. 8-Phase Lifecycle Matrix

| Phase | Methodologies | Core Deliverables |
| :--- | :--- | :--- |
| **1. Discovery, Domain & PRD** | Lean Discovery, Dual-Track Agile (Cagan), DDD (Evans) | Problem statement, user journeys, ubiquitous language, bounded contexts, V1 PRD |
| **2. PoC & Technical Spikes** | Boehm's Spiral Model, IEEE 12207 | Throwaway prototypes proving risky 3rd-party APIs, latency limits, core algorithms |
| **3. Architecture, Threat Model & ADRs** | Evolutionary Architecture, NIST SSDF, *Release It!* (Nygard) | System diagram, DB schema, API contracts, OWASP/auth threat model, PoC-grounded ADRs |
| **4. Walking Skeleton & Quality Gates** | *Walking Skeleton* (Cockburn/Humble), DORA *Accelerate* | Deployable skeleton, CI/CD, unit/integration/E2E harness, logging baseline, `CONSTRAINTS.md`, Kanban epics |
| **5. Iterative Delivery (MVP -> Product)** | DORA vertical slices, TDD (Beck), *Clean Code*, Ousterhout | Tested, production-ready increments merged continuously behind feature flags |
| **6. Launch PRR & Hardening** | Google SRE PRR, WCAG 2.2 AA, OWASP Top 10 | Security/a11y/perf sign-off, SLIs/SLOs, alerting, staged rollout, tested zero-downtime rollback runbook |
| **7. Operations & Support** | Google SRE blameless post-mortems, ITIL triage, Kanban flow | Root-cause fixes, regression tests, post-MVP enhancements, synced documentation |
| **8. Scale, Refactoring & Deprecation** | *Expand-Contract* migrations (Fowler/Sadalage), CWV & profiling | N+1 fixes, caching layers, zero-downtime DB migrations, legacy deprecation |

## 4. Phase Task-to-Model & Skill Routing

| Phase | Task Scope | Recommended Model & Pairing |
| :--- | :--- | :--- |
| **1. Discovery** | Research & competitor/doc scans | `gemini-4-hydrogen-medium` (or `research` subagent, `Model='flash'`) |
| **1. Discovery** | PRD & domain synthesis | `gemini-4-argon-medium` + `/grill-me` or `interview-me` |
| **2. PoC Spikes** | Rapid spike implementation | `gemini-pro-orchestrator-neon` or `gemini-4-neon-medium` |
| **2. PoC Spikes** | Quick script/config iteration | `gemini-4-hydrogen-high` |
| **3. Architecture** | System design, threat model & ADRs | `gemini-4-argon-high` + `doubt-driven-development` or `/plan` |
| **4. Skeleton** | Epic & dependency mapping | `gemini-4-argon-medium` |
| **4. Skeleton** | CI/CD, test harness & `CONSTRAINTS.md` | `gemini-4-neon-medium` |
| **4. Skeleton** | Bulk Kanban tickets & boilerplate | `gemini-4-hydrogen-high` |
| **5. Delivery** | Multi-file feature vertical slices | `gemini-pro-orchestrator-g1-pro` (Argon) or `gemini-pro-orchestrator-neon` |
| **5. Delivery** | Critical core (auth, RBAC, billing, crypto, HMAC) | `gemini-4-argon-high` directly |
| **5. Delivery** | Standard features (UI components, CRUD, state) | `gemini-4-neon-medium` |
| **5. Delivery** | Unit tests, styling & lint/type fixes | `gemini-4-hydrogen-high` |
| **6. Launch PRR** | Multi-axis pre-launch audit & rollback design | `gemini-4-argon-high` (or `/boost` + `security-auditor` / `accessibility-auditor` / `web-performance-auditor`) |
| **6. Launch PRR** | Observability instrumentation & a11y fixes | `gemini-pro-orchestrator-neon` or `gemini-4-neon-medium` |
| **7. Operations** | Single-file bugs & UI tweaks | `gemini-4-hydrogen-high` |
| **7. Operations** | Standard features & regressions (1–3 files) | `gemini-4-neon-medium` or `gemini-4-neon-high` |
| **7. Operations** | Prod incidents, race conditions & memory leaks | `gemini-4-argon-high` + `debugging-and-error-recovery` |
| **7. Operations** | Changelogs, commits & doc sync | `gemini-4-hydrogen-low` or `medium` |
| **8. Scale** | Bottleneck profiling & zero-downtime migration plan | `gemini-4-argon-high` |
| **8. Scale** | Codebase-wide refactoring & dead-code removal | `gemini-pro-orchestrator-g1-pro` (Argon) |
