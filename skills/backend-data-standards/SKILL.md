---
name: backend-data-standards
description: Enforces stack-agnostic backend, API, and data-layer standards (Node/TS, Next.js/React Router server, Python/FastAPI, SQL/NoSQL) covering boundary schema validation, strict typing, transactions, idempotency, error taxonomy, and query hygiene. Activate whenever writing or updating API handlers, server actions, database schemas, queries, or background jobs.
---

# Backend & Data-Layer Standards (DDIA + Hexagonal + Release It! + Twelve-Factor)

Ground all backend, server-action, and data-layer code in **DDIA (Kleppmann)**, **Hexagonal Architecture (Cockburn)**, ***Release It!* (Nygard)**, **Parse, Don't Validate (King)**, **OWASP ASVS**, **The Twelve-Factor App**, and **RFC 9457**, alongside `rules/GEMINI.md` §3 (Code, Docs & Testing Baseline) and §4 (Safety & Workflow Guardrails).

## 1. Boundary Validation & Strict Typing (Parse, Don't Validate + Twelve-Factor III)

Parse every untrusted input into a strict domain type at the system edge rather than checking raw values downstream.

| Boundary | Required Standard (`MUST` / `MUST NOT`) |
| :--- | :--- |
| **External Inputs** | Parse HTTP bodies, query params, URL params, headers, and webhooks into typed objects with a schema validator (Zod/Valibot, Pydantic) before use. |
| **Environment Config** | Validate all required env vars once at startup (Twelve-Factor III); fail fast with a clear error when missing or malformed. |
| **Strict Type Contracts** | Enforce strict typing end-to-end (`strict: true` and zero `any` in TS; full type hints with `pyright`/`mypy` in Python). |
| **Auth & Ownership** | Check authentication and resource ownership (OWASP ASVS) via early guard clauses before reading or mutating records. |

## 2. Thin Handlers & Layered Architecture (Hexagonal / Ports & Adapters)

Keep transport handlers thin and isolate business rules from HTTP and database mechanics.

| Layer | Owns | Forbidden (`MUST NOT`) |
| :--- | :--- | :--- |
| **Transport / Route** | Parse/validate input, enforce auth, invoke service, map result to HTTP status | Raw SQL queries, multi-step business logic, transaction orchestration |
| **Domain / Service** | Business invariants, state transitions, orchestration, domain errors | Reading `req`/`res` objects, returning HTTP status codes |
| **Repository / Data** | Parameterized queries, schema mapping, DB transactions | HTTP formatting, UI concerns, unvalidated external input |

## 3. Data Integrity, Transactions & Query Hygiene (DDIA + SQL Antipatterns)

Enforce invariants in the database schema and prevent unbounded or N+1 queries.

- **Parameterized Queries:** Data access `MUST` use parameterized queries or ORM bindings; never interpolate user input into SQL, NoSQL filters, or shell commands.
- **Schema Constraints:** Define `NOT NULL`, `UNIQUE`, foreign keys, and indexes on filter/join columns in migrations rather than relying solely on application checks.
- **Atomic Transactions:** `WHEN` a use case writes multiple dependent records, wrap writes in a single DB transaction; `MUST NOT` hold DB transactions open across external HTTP calls.
- **Bounded Queries:** List endpoints `MUST` enforce pagination (`limit`/`cursor` with a hard max cap) and avoid N+1 loops via joins, `IN` batching, or eager loading.

## 4. Idempotency, Concurrency & Outbound Resilience (Release It! + DDIA)

Design mutations and integrations to survive retries, duplicate deliveries, and partial failures.

| Mechanism | Required Rule (`MUST`) |
| :--- | :--- |
| **Idempotency** | Payments, webhooks, and retried mutations `MUST` be idempotent via an idempotency key, `UNIQUE` constraint, or `UPSERT`. |
| **Race Protection** | Guard concurrent balance, quota, or state transitions with optimistic locking (`WHERE version = ?`) or row locks (`SELECT ... FOR UPDATE`). |
| **Timeouts & Retries** | Set explicit timeouts on all outbound HTTP/DB calls; retry only transient faults (`429`, `502–504`, network errors) using bounded exponential backoff with jitter. |

## 5. Typed Error Taxonomy & Structured Logging (RFC 9457 + Twelve-Factor XI)

Map domain errors consistently to RFC 9457-style machine-readable HTTP responses without leaking internals.

| Domain Error | HTTP Status | Client Response Rule |
| :--- | :---: | :--- |
| **ValidationError** | `400` / `422` | Return `{ code, message, details }` listing invalid fields |
| **Unauthorized / Forbidden** | `401` / `403` | Return generic auth error; never reveal whether an account exists |
| **NotFound / Conflict** | `404` / `409` | Return stable machine-readable `code` (e.g., `ORDER_NOT_FOUND`, `EMAIL_TAKEN`) |
| **RateLimited** | `429` | Include `Retry-After` header |
| **Unexpected / Internal** | `500` | Return generic message + `requestId`; `MUST NOT` expose stack traces or SQL errors |

- **Structured Logs:** Emit JSON logs with `requestId`, operation, latency, and error code; `MUST` redact passwords, tokens, API keys, and sensitive PII.

## 6. Migrations, Seeds & Runtime Hygiene

Keep schema evolution reversible, local data repeatable, and runtime dependencies audited.

| Area | Mandatory Standard (`MUST` / `MUST NOT`) |
| :--- | :--- |
| **Schema Migrations** | Schema changes `MUST` use versioned, reversible migrations; destructive DDL (`DROP COLUMN`, type narrowing) `MUST` follow expand-contract. |
| **Deterministic Seeds** | Local dev and test seed scripts `MUST` be idempotent and deterministic across repeated runs. |
| **Supply Chain & Containers** | Commit lockfiles, run dependency vulnerability audits (`npm audit` / `pip-audit`) before launch, and run containers as non-root using multi-stage builds. |
