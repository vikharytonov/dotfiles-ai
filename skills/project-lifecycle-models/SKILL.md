---
name: project-lifecycle-models
description: Guides project lifecycle phases (from Discovery and PoC to Architecture, Walking Skeleton, MVP, Launch PRR, Operations, and Migrations) and recommends the optimal Gemini 4 model (Argon, Neon, Hydrogen, or Orchestrator) for each phase and task. Activate when starting a new project, planning phases/epics/Kanban workflows, transitioning between development stages, or choosing which model to use.
---

# Industry-Standard Project Lifecycle & Gemini 4 Model Routing

Ground every project in this 8-phase engineering lifecycle synthesized from **Boehm's Spiral Model**, **Domain-Driven Design (DDD)**, **ThoughtWorks Evolutionary Architecture**, **DORA / Continuous Delivery**, **NIST SSDF**, **Google SRE**, and **Clean Code**.

At every phase boundary, tell the user which **Gemini 4 model** (`agy --model <id>` or `/model`) best fits the upcoming phase. **During any phase, if the main session is running on a heavier model (e.g., Gemini 4 Argon) and a sub-task belongs to a lighter tier (>2 tool calls of research, unit test writing, lint fixes, Kanban ticket drafting, or doc table syncing), automatically spawn an `invoke_subagent` with `Model='flash'` (or `Model='pro'` when escalating from Hydrogen/Neon) instead of making the user switch `/model` manually.**

---

## Quick Model Reference (`agy models`)

| Model Family | CLI IDs | Core Strength |
| :--- | :--- | :--- |
| **Gemini 4 Argon** | `gemini-4-argon-low` \| `medium` \| `high` | Flagship deep reasoning, system architecture, threat modeling, critical auth/crypto, subtle race conditions, zero-downtime migrations |
| **Orchestrator (Argon)** | `gemini-pro-orchestrator-g1-pro` | Dynamic Argon planner + Hydrogen executor for complex multi-file MVP feature slices and large refactors (50-70% lower quota burn) |
| **Gemini 4 Neon** | `gemini-4-neon-low` \| `medium` \| `high` \| `xhigh` | Sweet-spot frontier coding, PoC spikes, CI/CD & test harness setup, standard 1-3 file features, and moderate debugging |
| **Orchestrator (Neon)** | `gemini-pro-orchestrator-neon` | Dynamic Neon planner + Hydrogen executor for rapid PoC prototyping, observability instrumentation, and standard multi-file features |
| **Gemini 4 Hydrogen** | `gemini-4-hydrogen-low` \| `medium` \| `high` \| `xhigh` | High-speed executor for doc/web research, drafting Kanban tickets, unit tests, lint/type fixes, single-file bugs, and docs/changelogs |

---

## The 8 Bulletproof Project Lifecycle Phases

### Phase 1: Discovery, Domain Modeling & PRD
* **Methodology:** Lean Product Discovery, Marty Cagan's Dual-Track Agile, Eric Evans' Domain-Driven Design (DDD).
* **Deliverables:** Problem statement, user journeys, ubiquitous language, bounded contexts, and V1 PRD.
* **Model Routing:**
  * **Research & Competitor/Doc Scans:** `gemini-4-hydrogen-medium` (or `research` subagent with `Model='flash'`) to scan external documentation and summarize findings without bloating main context.
  * **PRD & Domain Synthesis:** `gemini-4-argon-medium` (pair with `/grill-me` or `interview-me`) to stress-test assumptions and define scope boundaries.

### Phase 2: PoC & High-Risk Technical Spikes (Before Finalizing Architecture)
* **Methodology:** Barry Boehm's Spiral Model & IEEE 12207 (validate highest technical risks before locking in architecture).
* **Deliverables:** Throwaway prototypes proving risky 3rd-party APIs, latency limits, or core algorithms.
* **Model Routing:**
  * **Rapid Spike Implementation:** `gemini-pro-orchestrator-neon` or `gemini-4-neon-medium` for fast integration wiring without over-engineering.
  * **Quick Script/Config Iteration:** `gemini-4-hydrogen-high` for fast inner-loop validation.

### Phase 3: Evolutionary Architecture, Threat Modeling & ADRs
* **Methodology:** ThoughtWorks Evolutionary Architecture, NIST Secure SDLC (shift-left security), Michael Nygard's *Release It!*.
* **Deliverables:** System architecture diagram, database schema, API contracts, OWASP/auth threat model, and lightweight ADRs grounded in Phase 2 PoC data.
* **Model Routing:**
  * **System Design, Threat Model & ADRs:** `gemini-4-argon-high` (pair with `doubt-driven-development` or `/plan`)—architectural mistakes here are the costliest to undo later and require maximum reasoning depth.

### Phase 4: Walking Skeleton, Quality Gates & Kanban Decomposition
* **Methodology:** Alistair Cockburn & Jez Humble's *Walking Skeleton*, DORA *Accelerate* capabilities.
* **Deliverables:** End-to-end deployable skeleton, CI/CD pipeline, automated test harness (unit/integration/E2E), structured logging baseline, `CONSTRAINTS.md`, and dependency-ordered Kanban epics/tickets.
* **Model Routing:**
  * **Epic & Dependency Map:** `gemini-4-argon-medium` to sequence vertical slices and unblock critical paths.
  * **CI/CD, Test Harness & `CONSTRAINTS.md`:** `gemini-4-neon-medium` to wire quality gates and pre-commit hooks.
  * **Bulk Kanban Tickets & Boilerplate:** `gemini-4-hydrogen-high` to draft individual task cards and acceptance criteria quickly.

### Phase 5: Iterative Delivery (MVP -> Product Vertical Slices)
* **Methodology:** DORA small-batch vertical slices, Kent Beck's TDD (Red-Green-Refactor), Robert C. Martin's *Clean Code* + John Ousterhout's *A Philosophy of Software Design* (KISS/YAGNI).
* **Deliverables:** Tested, production-ready increments merged continuously behind feature flags.
* **Model Routing:**
  * **Multi-File Feature Slices:** `gemini-pro-orchestrator-g1-pro` (Argon) or `gemini-pro-orchestrator-neon`—the frontier model plans the slice while Hydrogen executes boilerplate edits and test runs.
  * **Critical Core (Auth, RBAC, Billing, Crypto, HMAC):** `gemini-4-argon-high` directly so security-critical logic receives full frontier scrutiny.
  * **Standard Features (UI Components, CRUD, State):** `gemini-4-neon-medium`.
  * **Unit Tests, Styling & Lint/Type Fixes:** `gemini-4-hydrogen-high`.

### Phase 6: Production Readiness Review (PRR), Hardening & Launch
* **Methodology:** Google Site Reliability Engineering (SRE) PRR checklist, WCAG 2.2 AA accessibility, OWASP Top 10 audit.
* **Deliverables:** Security/a11y/performance audit sign-off, SLIs/SLOs, error tracking/alerting, staged rollout plan, and tested zero-downtime rollback runbook.
* **Model Routing:**
  * **Multi-Axis Pre-Launch Audit & Rollback Design:** `gemini-4-argon-high` (or `/boost` + `security-auditor` / `accessibility-auditor` / `web-performance-auditor`).
  * **Observability Instrumentation & A11y Remediation:** `gemini-pro-orchestrator-neon` or `gemini-4-neon-medium`.

### Phase 7: Operations, Incident Response & Continuous Support
* **Methodology:** Google SRE blameless post-mortems, ITIL incident triage, Kanban continuous flow.
* **Deliverables:** Root-cause bug fixes, regression tests, post-MVP feature enhancements, and synced documentation.
* **Model Routing:**
  * **Single-File Reproducible Bugs & UI Tweaks:** `gemini-4-hydrogen-high`.
  * **Standard Feature Requests & Regressions (1-3 files):** `gemini-4-neon-medium` or `gemini-4-neon-high`.
  * **Production Incidents, Race Conditions & Memory Leaks:** `gemini-4-argon-high` (pair with `debugging-and-error-recovery`).
  * **Changelogs, Commits & Doc Sync:** `gemini-4-hydrogen-low` or `medium`.

### Phase 8: Scale, Evolutionary Refactoring & Deprecation
* **Methodology:** Martin Fowler & Pramod Sadalage's *Expand-Contract (Parallel Change)* migrations, Core Web Vitals & query profiling.
* **Deliverables:** N+1 query fixes, caching layers, zero-downtime DB schema migrations, and legacy deprecation.
* **Model Routing:**
  * **Bottleneck Profiling & Zero-Downtime Migration Planning:** `gemini-4-argon-high` to design safe expand-contract database and API transitions.
  * **Codebase-Wide Refactoring & Dead-Code Removal:** `gemini-pro-orchestrator-g1-pro` (Argon) to coordinate multi-file edits with continuous test verification.
