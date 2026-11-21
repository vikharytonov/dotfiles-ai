---
name: testing-standards
description: Enforces high-signal testing and verification standards blending Robert C. Martin's Clean Code (Chapter 9: F.I.R.S.T., Build-Operate-Check, 1 concept per test), Vladimir Khorikov's Classical Unit Testing (observable behavior over implementation details, mock only external boundaries), Kent C. Dodds' Testing Trophy (accessibility-first locators), Rolls-Royce EARS-to-Test mapping, and Boundary Value Analysis (BVA). Activate whenever writing tests, fixing bugs (Red-Green-Refactor), designing test suites, or reviewing test quality.
---

# Testing & Verification Standards (Clean Code Ch. 9 + Khorikov + Dodds + EARS)

All test code MUST follow `rules/GEMINI.md` Section 3 (Clean Code: self-explaining names, zero narrator comments, small functions, surgical diffs) and Section 5 (Testing Principles).

---

## 1. Model & Subagent Routing for Testing

Match the Gemini 4 model tier to the testing task and auto-delegate multi-step runner loops:

| Testing Scope | Recommended Model / Subagent | Execution Rule (`MUST`) |
| :--- | :--- | :--- |
| **Unit Test Generation, BVA Cases & Red-Green Loops (`>2` tool calls)** | `gemini-4-hydrogen-high` or `invoke_subagent(TypeName='test-engineer', Model='flash')` | `WHILE` main session is on Argon or Neon, `WHEN` generating unit tests or running >2 test-fix iterations, `MUST` auto-delegate to `Model='flash'` with the 4-part Brief Contract. |
| **Integration, API Route, React Component & E2E Flow Tests** | `gemini-4-neon-medium` or `gemini-pro-orchestrator-neon` | Execute on Neon/Orchestrator; on Argon, outline the test matrix in 2–3 bullets and offload boilerplate/runner execution to `Model='flash'`. |
| **Test Strategy, Concurrency/Race Conditions, Auth/Crypto & Fuzzing** | `gemini-4-argon-high` (or `Model='pro'` subagent when on Hydrogen/Neon) | Use Argon directly to design threat/race reproduction tests and verify boundary invariants. |

---

## 2. Bob Martin's *Clean Code* (Chapter 9) Test Mechanics

Test code is first-class code; dirty tests rot a codebase faster than no tests.

| Clean Code Rule | Mechanical Requirement (`MUST` / `MUST NOT`) |
| :--- | :--- |
| **F.I.R.S.T. Properties** | Every test `MUST` be **F**ast (ms for unit, s for integration), **I**ndependent (runs in any order with zero shared mutable state), **R**epeatable (deterministic clock/randomness, zero live internet dependency), **S**elf-Validating (automated boolean assertion), and **T**imely (written before or with the production change). |
| **Build–Operate–Check (AAA) Without Narrator Comments** | Separate setup (**Build**), execution (**Operate**), and verification (**Check**) using **1 blank line** between phases. In compliance with `GEMINI.md` Section 3, tests `MUST NOT` contain `// Arrange`, `// Act`, or `// Assert` narrator comments. |
| **One Behavioral Concept per Test** | Each `it()` block `MUST` verify strictly 1 logical scenario. Split multiple scenarios into separate tests or `it.each(...)` table rows. |
| **DAMP Over Over-DRY** | Keep each test self-contained and readable top-to-bottom (**DAMP**: Descriptive And Meaningful Phrases). Use domain factory builders (`buildUser({ role: 'admin' })`) showing only the overrides relevant to that test; `MUST NOT` hide critical test inputs inside opaque `beforeEach` blocks. |
| **Zero Control-Flow Logic in Tests** | Test bodies `MUST NOT` contain `if/else`, `for`/`while` loops, or manual `try/catch` blocks (use framework assertion primitives like `expect(() => fn()).toThrow()` or `rejects.toThrow()`). |
| **Red-Green-Refactor (Prove-It Pattern)** | `WHEN` fixing any bug, the agent `MUST` first run a test that reproduces the bug and watch it fail (`Red`), then apply the minimal production fix and watch it pass (`Green`). |

---

## 3. Khorikov's Classical School & Dodds' Testing Trophy

Protect against **False Positives** (tests that break during safe internal refactoring) and **Tautological Mocks** (tests that only verify their own mock setup):

| Dimension | Anti-Pattern (`MUST NOT`) | Required Standard (`MUST`) |
| :--- | :--- | :--- |
| **Observable Behavior vs. Implementation** | Asserting on private helpers, internal React `useState` values, SQL string formatting, or internal function call counts (`expect(internalHelper).toHaveBeenCalled()`). | Assert strictly on the **3 observable outcomes**: (1) Return value / thrown error, (2) Public state / DB mutation, or (3) Out-of-process external boundary call. |
| **Test Double Hierarchy** | Mocking internal modules (`vi.mock('./pricing')`), pure functions, or data mappers. | Follow strict preference: **1. Real Implementation -> 2. In-Memory Fake -> 3. Stub -> 4. Mock**. Mock **only** unmanaged external boundaries (3rd-party HTTP/OAuth/Stripe APIs, email/SMS gateways, system clock, randomness). |
| **Testing Trophy Allocation** | 100% shallow unit tests with mocked DB/API layers, or slow brittle E2E tests for every validation permutation. | Use **Unit Tests** for pure domain logic & BVA edge cases, **Integration/Component Tests** (highest ROI) for API routes, DB queries, and UI state flows, and **E2E Tests** strictly for critical user journeys (auth, checkout, core workflow). |
| **UI & Browser Locator Priority (Dodds / WCAG)** | Querying DOM elements by CSS classes (`.btn-primary`), tag names, XPath, or defaulting to `data-testid` when semantic text/roles exist. | Query the way users and screen readers perceive the UI: **1. `getByRole` (with `name`) -> 2. `getByLabelText` -> 3. `getByPlaceholderText` / `getByText` -> 4. `getByTestId` (last resort only)**. |

---

## 4. Rolls-Royce EARS-to-Test Mapping & Boundary Value Analysis (BVA)

Translate every EARS specification clause from PRDs, Kanban tickets, or `CONSTRAINTS.md` directly into deterministic tests:

| EARS Requirement Pattern | 1:1 Test Naming & Assertion Structure |
| :--- | :--- |
| **Ubiquitous:** `The <system> MUST <response>.` | `it('validates JWT signature on protected routes', ...)` |
| **Event (`WHEN`):** `WHEN <trigger>, the <system> MUST <response>.` | `it('returns 401 TOKEN_EXPIRED when magic link exceeds TTL', ...)` |
| **State (`WHILE`):** `WHILE <state>, the <system> MUST <response>.` | `it('disables submit button and sets aria-busy while mutation is pending', ...)` |
| **Error (`IF/THEN`):** `IF <fault>, THEN the <system> MUST <recovery>.` | `it('aborts processing and logs security event if Stripe HMAC is invalid', ...)` |
| **Optional (`WHERE`):** `WHERE <flag>, the <system> MUST <response>.` | `it('records audit diff when ENABLE_AUDIT_LOG is true', ...)` |

### Mandatory Boundary Value Analysis (BVA) Matrix
Whenever testing numeric, length, collection, or time boundaries (e.g., valid range `[MIN, MAX]`), cover all **6 boundary points** using parameterized `it.each` tables instead of copy-pasted tests:

| Boundary Point | Value Tested | Expected Outcome |
| :--- | :--- | :--- |
| **Empty / Null / Missing** | `""`, `null`, `undefined`, `[]` | Reject with validation error or deterministic empty-state return |
| **Just Below Min** | `MIN - 1` | Reject (`< MIN` boundary error) |
| **Exact Min** | `MIN` | Accept (inclusive lower bound) |
| **Exact Max** | `MAX` | Accept (inclusive upper bound) |
| **Just Above Max** | `MAX + 1` | Reject (`> MAX` boundary error) |
| **Clock / Async Edge** | Exact expiry timestamp (`t === ttl`), concurrent duplicate call | Deterministic expiry handling & idempotency verified |

---

## 5. Clean Test Blueprints (Zero Narrator Comments)

### Blueprint A: Domain Unit Test + BVA Table (`it.each`)
```typescript
describe('calculateDiscountedTotal', () => {
  it('applies percentage discount for eligible subtotal', () => {
    const order = buildOrder({ subtotalCents: 10_000, discountPercent: 15 });

    const totalCents = calculateDiscountedTotal(order);

    expect(totalCents).toBe(8_500);
  });

  it.each([
    { discountPercent: -1, reason: 'below minimum (0)' },
    { discountPercent: 101, reason: 'above maximum (100)' },
  ])('throws RangeError when discountPercent is $reason ($discountPercent)', ({ discountPercent }) => {
    const order = buildOrder({ subtotalCents: 5_000, discountPercent });

    expect(() => calculateDiscountedTotal(order)).toThrow(RangeError);
  });
});
```

### Blueprint B: Accessibility-First React Component Test
```tsx
describe('DeleteProjectDialog', () => {
  it('calls onConfirm only after user types exact project name and clicks confirm', async () => {
    const user = userEvent.setup();
    const handleConfirm = vi.fn();
    render(<DeleteProjectDialog projectName="apollo" onConfirm={handleConfirm} />);

    const confirmButton = screen.getByRole('button', { name: /delete project/i });
    expect(confirmButton).toBeDisabled();

    await user.type(screen.getByLabelText(/type project name to confirm/i), 'apollo');
    await user.click(confirmButton);

    expect(handleConfirm).toHaveBeenCalledOnce();
  });
});
```

---

## 6. Anti-Cheating & Execution Verification Gate (QRH)

Before marking any coding or testing task complete, enforce these strict verification rules:

1. **Discover Repo Test Runner First:** Inspect `package.json`, `Makefile`, `pyproject.toml`, `Cargo.toml`, or `go.mod` and run the repository's native test command.
2. **Focused Run -> Full Suite Run:** Run the single target test file during the Red-Green loop; run the full affected suite once after the last edit. **`MUST NOT` re-run passing test commands without an intervening edit.**
3. **Zero Bar-Lowering Gate:** The diff `MUST NOT` introduce `.skip`, `.only`, `todo`, commented-out `expect(...)` lines, `@ts-ignore`, `@ts-expect-error` (except inside negative type tests), `eslint-disable`, or lowered coverage thresholds in config files.
   **Verify:** Run `git diff | grep -E '^\+.*(\.skip|\.only|@ts-ignore|eslint-disable)'` and confirm output is empty (`0` matches).
