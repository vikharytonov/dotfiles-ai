---
name: documentation-standards
description: Enforces Dual-Audience (Human + AI) documentation standards blending Diátaxis, S1000D/OKF modularity, ASD-STE100 Simplified Technical English, Robert Horn's Information Mapping, Rolls-Royce EARS requirements syntax, Simon Brown's C4 Mermaid diagrams, Nygard ADRs, Aviation QRH runbooks, and Docs-as-Code lifecycle. Activate whenever writing, updating, reviewing, or auditing READMEs, specs, PRDs, ADRs, runbooks, or docs/.
---

# Dual-Audience (Human + AI) Documentation Standards

This skill translates **8 proven industrial & aerospace documentation frameworks** into mechanical rules and copy-paste templates so humans scan docs in seconds and AI agents parse them with minimal token burn and zero ambiguity.

---

## 1. Model Routing by Documentation Task

Match the Gemini 4 tier to task depth; WHEN a multi-step Reference/Syncing or Runbook task (>2 tool calls) runs on Argon or Neon, delegate via `invoke_subagent(TypeName='self', Model='flash')` (or escalate ADRs/EARS via `Model='pro'` from Hydrogen) with instructions to load `documentation-standards` and run `verify-docs.sh`:

| Doc Category | Recommended Model | Why |
| :--- | :--- | :--- |
| **Reference & Syncing** (`README.md` tables, CLI flags, `.env` tables, changelogs, commit drift checks) | `gemini-4-hydrogen-medium` or `high` | Facts already exist in the code diff; Hydrogen formats tables and checks links rapidly at lowest quota cost |
| **Runbooks & Modularization** (Aviation QRH runbooks, onboarding guides, splitting a bloated README into `docs/*.md`) | `gemini-4-neon-medium` or `gemini-pro-orchestrator-neon` | Requires multi-file workflow understanding without burning frontier Argon quota |
| **Specs, Architecture & ADRs** (Rolls-Royce EARS PRDs, Simon Brown C4 `mermaid` graphs, Nygard ADRs) | `gemini-4-argon-medium` (PRDs/EARS) or `gemini-4-argon-high` (ADRs/C4) | Writing specs and ADRs *is* system design; Argon spots edge cases, failure modes, and architectural trade-offs |

---

## 2. The 6 Mechanical Writing Rules (ASD-STE100 + Horn's Information Mapping)

Apply these deterministic rules to every Markdown file:

| Rule | Mechanical Cap / Standard |
| :--- | :--- |
| **1. BLUF (Bottom Line Up Front)** | Put the command, table, or answer in the **first 3 lines** under every heading; never bury commands under history. |
| **2. File & Section Caps (Diátaxis)** | Root `README.md` **≤150 lines** (sitemap only); topic modules `docs/<topic>.md` **≤250 lines** (1 intent); section intro **≤1 sentence**. |
| **3. Horn's Table Rule** | **3+ parallel items** (env vars, CLI flags, config keys, roles, error codes, `if/else` outcomes) **MUST** use a Markdown table. |
| **4. ASD-STE100 Limits** | Instructional **≤20 words** (imperative active voice, 1 action/step); explanatory **≤25 words** (max 3 sentences/paragraph); 1 term = 1 meaning. |
| **5. Banned Filler Words** | Delete fluff and passive phrasing (see replacement table below). |
| **6. Docs-as-Code (SSOT)** | Never duplicate TS interfaces, JSON schemas, or all `package.json` scripts; link to source files (`[schema.ts](../src/schema.ts)`). |

| Never Write (Banned Fluff / Passive) | Always Write (STE100 Imperative / Active) |
| :--- | :--- |
| `In order to start the server, you can simply run...` | `Start the server:` |
| `It should be noted that the token is required...` | `The API requires `AUTH_TOKEN`.` |
| `If you want to configure X, please make sure to...` | `Set `X` in `.env`:` |
| `This script basically handles the migration of...` | `Migrate the database schema:` |
| `easily`, `simply`, `basically`, `just`, `obviously` | *(Delete completely)* |

6. **Single Source of Truth (Docs-as-Code):** Never copy-paste large TypeScript interfaces, full JSON schemas, or all 30 `package.json` scripts into Markdown. Link directly to the source file (`[schema.ts](../src/schema.ts)`) and document only the entry command.

---

## 3. Rolls-Royce EARS + RFC 2119 Grammar for Specs & Acceptance Criteria

Every functional requirement, PRD capability, `CONSTRAINTS.md` rule, or Kanban ticket acceptance criterion **MUST** use one of the 5 deterministic EARS patterns with uppercase RFC 2119 keywords (`MUST`, `MUST NOT`, `SHOULD`):

| Pattern Type | Deterministic EARS Syntax | Concrete Example |
| :--- | :--- | :--- |
| **1. Ubiquitous** *(Always active)* | `The <system> MUST <response>.` | `The API gateway MUST validate JWT signatures on all `/v1/*` routes.` |
| **2. Event-Driven** *(Triggered by action)* | `WHEN <trigger event>, the <system> MUST <response>.` | `WHEN a user submits an expired magic link, the auth service MUST return HTTP 401 with `TOKEN_EXPIRED`.` |
| **3. State-Driven** *(Continuous condition)* | `WHILE <in specific state>, the <system> MUST <response>.` | `WHILE the database connection pool is saturated, the worker MUST queue incoming jobs in Redis.` |
| **4. Unwanted Behavior** *(Error/Fault handling)* | `IF <error/unwanted condition>, THEN the <system> MUST <recovery>.` | `IF the Stripe webhook HMAC verification fails, THEN the webhook handler MUST abort processing and log a security event.` |
| **5. Optional Feature** *(Config/Tier gated)* | `WHERE <feature/flag is enabled>, the <system> MUST <response>.` | `WHERE `ENABLE_AUDIT_LOG=true`, the repository layer MUST record before/after diffs for every `DELETE` query.` |
| **6. Complex (Combined)** | `WHILE <state>, WHEN <event>, the <system> MUST <response>.` | `WHILE in maintenance mode, WHEN a non-admin requests `/api/*`, the server MUST return HTTP 503 with `Retry-After: 300`.` |

---

## 4. Copy-Paste Document Blueprints (Diátaxis + OKF + C4 + QRH)

### Blueprint A: Gateway `README.md` Sitemap (≤150 Lines)
```markdown
# <Project Name>

<1-sentence BLUF summary stating what the system does and for whom.>

## Quick Start

| Prerequisite | Required Version | Verification Command |
| :--- | :--- | :--- |
| Node.js | `>=22.0.0` | `node -v` |
| PostgreSQL | `>=16.0` | `psql --version` |

1. Install dependencies and initialize local environment:
   ```bash
   cp .env.example .env && npm install && npm run db:setup
   ```
   **Verify:** Output ends with `Database seeded (0 errors)`.
2. Start the development server:
   ```bash
   npm run dev
   ```
   **Verify:** `curl -s http://localhost:3000/health` returns `{"status":"ok"}`.

## Documentation Map (Diátaxis Index)

| Topic | Type | Path | Description |
| :--- | :--- | :--- | :--- |
| **Architecture & C4 Map** | Explanation | [docs/architecture.md](docs/architecture.md) | System boundaries, data flow, and C4 diagrams |
| **Configuration & Env Vars** | Reference | [docs/configuration.md](docs/configuration.md) | Required environment variables and CLI flags |
| **Deployment & Rollback** | How-To (QRH) | [docs/runbooks/deploy.md](docs/runbooks/deploy.md) | Production release and emergency rollback steps |
| **Architecture Decisions** | ADR Log | [docs/adr/](docs/adr/) | Immutable records of core technical trade-offs |
```

---

### Blueprint B: Aviation QRH Runbook / How-To Guide (`docs/runbooks/<task>.md`)
Every operational guide must follow the **Do-Confirm (Action -> Verify -> Rollback)** pattern:
```markdown
---
id: runbook-<slug>
type: how-to
last_verified: YYYY-MM-DD
---

# Runbook: <Action-Oriented Title, e.g., Rotate Production JWT Signing Keys>

<1-sentence BLUF stating when to execute this procedure and expected downtime (e.g., Zero downtime).>

## 1. Pre-Flight Checklist

| Check | Command | Expected Output |
| :--- | :--- | :--- |
| Production cluster context | `kubectl config current-context` | `prod-eu-west-1` |
| Healthy replica count | `kubectl get deploy api -o jsonpath='{.status.readyReplicas}'` | `>=2` |

## 2. Execution Steps (Read-Do)

1. Generate and stage the new secondary signing key:
   ```bash
   ./scripts/rotate-keys.sh --stage-next
   ```
   **Verify:** `kubectl get secret jwt-keys -o jsonpath='{.data.NEXT_KEY_ID}'` returns a non-empty base64 string.
2. Promote the staged key to primary and reload workers:
   ```bash
   ./scripts/rotate-keys.sh --promote && kubectl rollout status deploy/api
   ```
   **Verify:** `deployment "api" successfully rolled out` and error rate in logs remains `0`.

## 3. Emergency Rollback (If Verification Fails)

IF any verification step fails or HTTP 5xx exceeds 1%, THEN revert immediately:
```bash
./scripts/rotate-keys.sh --rollback && kubectl rollout undo deploy/api
```
**Verify:** `curl -s https://api.example.com/health` returns `200 OK`.
```

---

### Blueprint C: Simon Brown C4 Architecture + Nygard ADR (`docs/adr/NNNN-<slug>.md`)
Combine concise text-based C4 `mermaid` diagrams (Level 1 Context or Level 2 Container) with Nygard's immutable ADR structure:
```markdown
---
id: ADR-0001
status: Accepted
date: YYYY-MM-DD
---

# ADR-0001: <Short Imperative Decision Title>

## Context
<2–4 STE100 sentences or a bullet list describing the technical constraint, forces at play, and why a decision is required now.>

## Architecture (C4 Container View)
```mermaid
flowchart LR
    User["Merchant Browser"] -->|"HTTPS / JSON"| Edge["Cloudflare Worker (Auth Proxy)"]
    Edge -->|"mTLS / gRPC"| Core["Order Service (Node.js)"]
    Core -->|"SQL"| DB[("PostgreSQL 16")]
    Core -->|"Async Events"| Queue[["Redis Streams"]]
```

## Options Considered

| Option | Pros | Cons | Verdict |
| :--- | :--- | :--- | :--- |
| **A: <Chosen Option>** | <Measurable benefit> | <Known trade-off> | **Accepted** |
| **B: <Rejected Option>** | <Benefit> | <Fatal flaw or excessive cost> | Rejected |

## Decision
We MUST use **<Option A>** for <scope>.

## Consequences (EARS Constraints)
- **Positive:** <Measurable improvement, e.g., Reduces p99 auth latency below 15ms>.
- **Negative / Trade-off:** <Operational cost accepted>.
- **Enforced Constraint:** WHEN a new service endpoint is added, it MUST authenticate via the Edge proxy (`CONSTRAINTS.md`).
```

---

### Blueprint D: Reference Module (`docs/configuration.md`)
Zero prose paragraphs—pure scannable tables:
```markdown
---
id: ref-configuration
type: reference
last_verified: YYYY-MM-DD
---

# Configuration & Environment Reference

All environment variables validated at startup by `[src/config/env.ts](../src/config/env.ts)`.

| Variable | Required | Default | Format / Allowed Values | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| `DATABASE_URL` | Yes | — | `postgres://user:pass@host:5432/db` | Primary PostgreSQL connection URI |
| `LOG_LEVEL` | No | `info` | `debug` \| `info` \| `warn` \| `error` | Minimum structured JSON log level |
| `PORT` | No | `3000` | Integer (`1024–65535`) | HTTP listener port |
```

---

## 5. Automated Verification (`scripts/verify-docs.sh`)

Run the bundled validator script whenever creating or refactoring documentation to verify mechanical compliance in 1 tool call:
```bash
~/.gemini/antigravity-cli/skills/documentation-standards/scripts/verify-docs.sh <project-root-or-doc-path>
```
What the script checks automatically:
1. **Line-Count Caps:** Warns if `README.md` exceeds 150 lines or any `docs/**/*.md` file exceeds 250 lines.
2. **Broken Relative Markdown Links:** Verifies every local `[label](relative/path.md)` target exists on disk.
3. **STE100 Filler Words:** Flags banned filler words (`simply`, `easily`, `basically`, `obviously`, `in order to`, `please note`).
4. **QRH Verification Checks:** Warns if a file in `docs/runbooks/` contains bash code blocks without `**Verify:**` checks.
