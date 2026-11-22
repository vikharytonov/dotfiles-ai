---
name: react-component-standards
description: Enforces official React best practices, Clean Code rules, high performance, reusability, accessibility, and minimal state whenever writing, updating, or deleting React code.
---

# React Component Standards & Best Practices

All React code written, updated, or deleted MUST follow `rules/GEMINI.md` Section 3 (minimal chunks, surgical diffs, zero narrator comments, comment-code sync) and the rules below.

## 1. Clean Code & Naming Rules in React

Use self-explaining names and flat control flow instead of JSX comments or mode flags.

- **Flat JSX & Guard Clauses:** Components MUST use early returns for loading, error, or empty states (`if (isLoading) return <Skeleton />;`) rather than nested JSX ternaries.
- **Intention-Revealing Variables:** Extract complex conditions into named booleans (`const canRunTrialQa = ...;`) before `return` instead of writing `{/* check if eligible */}`.
- **Small Single-Purpose Components:** WHEN a boolean prop splits core behavior (`<UserModal isEditMode />`), split it into dedicated components (`<CreateUserModal />`, `<EditUserModal />`) sharing base primitives.
- **Comment Sync on Edit:** WHEN updating or deleting a component, hook, or prop, immediately update or remove adjacent stale comments.

| Symbol Kind | Required Naming Pattern | Example |
| :--- | :--- | :--- |
| Boolean state / flag | `is*`, `has*`, `can*`, `should*` | `isSubmitting`, `canEdit` |
| Internal event handler | `handle<Action>` | `handleSubmit` |
| Callback prop | `on<Event>` | `onSave` |

## 2. State Management & Data Flow

Keep state minimal, immutable, and colocated at the lowest common ancestor.

- **Minimal & Derived State:** Components MUST NOT store computed values in `useState` or sync them via `useEffect`; compute them during render (`const fullName = `${first} ${last}``).
- **No Prop Mirroring:** Render props directly. Prefix isolated draft seeds with `initial*` (`initialName`) or reset state via `key={entityId}` (`<ProfileEditor key={userId} userId={userId} />`).
- **Immutability & Functional Updaters:** Never mutate state directly; use functional updaters (`setItems(prev => [...prev, item])`) when next state depends on previous state.

| State Scope | Mechanism | When to Use |
| :--- | :--- | :--- |
| Single component UI | `useState` / `useReducer` | State owned and read by one component |
| Compound subtree | Focused Context (memoized value) | Shared state across tightly coupled primitives |
| App-wide session/cache | Global store / router loader | Cross-route state needed across unrelated trees |

## 3. Effects & Synchronization

`useEffect` is strictly for synchronizing with external systems (DOM listeners, timers, WebSockets, non-React widgets, or subscriptions).

| Goal | Anti-Pattern | Required Pattern |
| :--- | :--- | :--- |
| Transform data for render | `useEffect` + `useState` | Compute directly in component body |
| Cache heavy calculation | `useEffect` + `useState` | `useMemo(() => compute(a, b), [a, b])` |
| Handle user clicks/submits | `useEffect` watching flag | Run logic inside `onClick` / `onSubmit` |
| Reset state on prop change | `useEffect` calling `setState` | Pass `key={propId}` to child component |
| Notify parent of change | `useEffect` calling `onChange` | Call `onChange` in the updating event handler |

- **Cleanup & Race Conditions:** WHEN an effect registers listeners, timers, or async fetches, it MUST return a cleanup function (`AbortController` or `ignore` flag) and survive `StrictMode` double-invocation.
- **Custom Hooks:** Extract non-trivial or reusable effect synchronization into focused `use*` hooks.

## 4. Performance & Rendering

Keep the render phase pure and defer heavy UI via lazy boundaries.

| Area | Rule (`MUST` / `SHOULD`) |
| :--- | :--- |
| **Pure Render** | Render `MUST` be a pure function of props, state, and context with zero external mutations or side-effects. |
| **Stable List Keys** | Lists `MUST` use stable entity IDs (`key={item.id}`); never use `Math.random()` or array indices for dynamic lists. |
| **Pragmatic Memoization** | Reserve `useMemo` and `useCallback` for heavy computations, hook deps, or `React.memo` child props (unless React Compiler handles memoization). |
| **Mutable Refs** | Use `useRef<ReturnType<typeof setInterval> \| null>(null)` or DOM refs for mutable values that must not trigger re-renders. |
| **Code Splitting** | Wrap heavy non-critical UI (charts, rich editors, modals) in `React.lazy` with `<Suspense fallback={...}>`. |

## 5. Component API Design & Accessibility (WCAG / ARIA)

Prefer composition over prop overload and preserve native HTML semantics.

- **Composition:** Use `children` slots or Compound Components (`<Card><Card.Header />...</Card>`) instead of boolean-heavy god components.
- **Native Props & Refs:** Extend `React.ComponentPropsWithRef<'button'>` (or target element), spread `...props`, and merge `className` with `cn(...)`. Accept `ref` as a prop in React 19+ (use `React.forwardRef` in React 18).

| Accessibility Area | Requirement (`MUST`) |
| :--- | :--- |
| **Semantic HTML** | Components MUST use `<button>` for actions, `<a href>` for navigation, and landmarks (`<main>`, `<nav>`, `<header>`). |
| **Keyboard & Focus** | Interactive elements MUST be tab-focusable with visible focus rings (`focus-visible:ring-2`) and modal focus trapping/restoration. |
| **Forms & ARIA** | Inputs MUST pair with `<label htmlFor>` (or `aria-label`), link errors via `aria-describedby`, and expose `aria-expanded`/`aria-pressed`/`aria-busy`. |

## 6. UI States & Design Tokens

Every data-driven or interactive view MUST handle all core visual states and consume semantic tokens.

| Dimension | Mandatory Standard (`MUST` / `MUST NOT`) |
| :--- | :--- |
| **Loading / Pending** | Render a skeleton or disabled control with `aria-busy="true"` during async fetches or mutations. |
| **Empty State** | Render clear copy and a primary next action when collections are empty; never leave a blank container. |
| **Error State** | Display actionable, human-readable error feedback with a retry path or fallback boundary. |
| **Responsive & Focus** | Support mobile-first viewports without horizontal overflow and preserve visible keyboard focus (`focus-visible:ring-2`). |
| **Design Tokens** | Use semantic CSS variables or theme tokens for colors, spacing, and typography; `MUST NOT` scatter raw magic hex/px values. |
