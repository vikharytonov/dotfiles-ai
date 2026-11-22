---
name: testing-standards
description: Complements `test-driven-development` and `GEMINI.md` §5 with EARS-to-Test mapping, 6-point Boundary Value Analysis (BVA), Dodds/WCAG accessibility-first UI locators, Testing Trophy allocation, clean TS/RTL blueprints (zero narrator comments), and an executable anti-cheating diff gate. Activate when designing test matrices, writing domain BVA or React component tests, or auditing test quality.
---

# Testing & Verification Standards (EARS + BVA + Dodds + Clean Blueprints)

Apply `GEMINI.md` §3 (Clean Code) and §5 (Testing Principles) alongside `test-driven-development` for the Red-Green-Refactor loop. This skill supplies the non-overlapping specification, locator, and quality rules below.

---

## 1. Overrides Over Generic TDD Conventions

Where generic TDD examples conflict with these standards, enforce these stricter rules:

| Area | Avoid | Required Standard (`MUST`) |
| :--- | :--- | :--- |
| **AAA Formatting** | `// Arrange`, `// Act`, `// Assert` narrator comments | Separate **Build**, **Operate**, and **Check** with **1 blank line** only. |
| **Test Allocation (Testing Trophy)** | 80% shallow unit tests with mocked DB/API layers | **Unit tests** for pure domain logic & BVA; **Integration/Component tests** (highest ROI) for API routes, DB queries, and UI flows; **E2E** strictly for critical user journeys. |
| **Control Flow in Tests** | `if/else`, `for`/`while`, or manual `try/catch` inside `it()` | Keep test bodies flat; use `it.each(...)` and `expect(() => fn()).toThrow()` / `rejects.toThrow()`. |
| **UI Locator Priority (Dodds / WCAG)** | CSS classes (`.btn-primary`), tag names, XPath, or default `data-testid` | Query as users and screen readers do: **1. `getByRole` (with `name`) -> 2. `getByLabelText` -> 3. `getByPlaceholderText` / `getByText` -> 4. `getByTestId` (last resort)**. |

---

## 2. Rolls-Royce EARS-to-Test Mapping & Boundary Value Analysis (BVA)

Map every EARS clause from PRDs, specs, or `CONSTRAINTS.md` 1:1 to a deterministic test:

| EARS Pattern | 1:1 Test Naming & Assertion Structure |
| :--- | :--- |
| **Ubiquitous:** `The <system> MUST <response>.` | `it('validates JWT signature on protected routes', ...)` |
| **Event (`WHEN`):** `WHEN <trigger>, the <system> MUST <response>.` | `it('returns 401 TOKEN_EXPIRED when magic link exceeds TTL', ...)` |
| **State (`WHILE`):** `WHILE <state>, the <system> MUST <response>.` | `it('disables submit button and sets aria-busy while mutation is pending', ...)` |
| **Error (`IF/THEN`):** `IF <fault>, THEN the <system> MUST <recovery>.` | `it('aborts processing and logs security event if Stripe HMAC is invalid', ...)` |
| **Optional (`WHERE`):** `WHERE <flag>, the <system> MUST <response>.` | `it('records audit diff when ENABLE_AUDIT_LOG is true', ...)` |

### Mandatory 6-Point BVA Matrix

Cover all 6 boundary points for numeric, length, collection, or time ranges `[MIN, MAX]` using `it.each(...)`:

| Boundary Point | Value Tested | Expected Outcome |
| :--- | :--- | :--- |
| **Empty / Null / Missing** | `""`, `null`, `undefined`, `[]` | Reject with validation error or deterministic empty-state return |
| **Just Below Min** | `MIN - 1` | Reject (`< MIN` boundary error) |
| **Exact Min** | `MIN` | Accept (inclusive lower bound) |
| **Exact Max** | `MAX` | Accept (inclusive upper bound) |
| **Just Above Max** | `MAX + 1` | Reject (`> MAX` boundary error) |
| **Clock / Async Edge** | Exact expiry (`t === ttl`), concurrent duplicate call | Deterministic expiry handling & idempotency verified |

---

## 3. Clean Test Blueprints (Zero Narrator Comments)

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

## 4. Zero Bar-Lowering Diff Gate (QRH)

Before marking any coding or testing task complete, confirm the diff adds no `.skip`, `.only`, `todo`, commented-out `expect(...)`, `@ts-ignore`, `@ts-expect-error` (outside negative type tests), `eslint-disable`, or lowered coverage thresholds:
```bash
git diff | grep -E '^\+.*(\.skip|\.only|@ts-ignore|eslint-disable)'
```
**Verify:** Command produces `0` matches.
