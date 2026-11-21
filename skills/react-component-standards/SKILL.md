---
name: react-component-standards
description: Enforces official React best practices, Clean Code rules, high performance, reusability, accessibility, and minimal state whenever writing, updating, or deleting React code.
---

# React Component Standards & Best Practices

**Mandatory Base Rule:** All React code written, updated, or deleted MUST strictly follow the global **Fundamental Code & Comment Principles** (`rules/GEMINI.md` Section 3: minimal code chunks, surgical diffs, zero narrator comments, strict comment-code sync/deletion) in addition to the React rules below.

## 1. Clean Code & Comment Rules in React
- **Flat JSX & Guard Clauses:** Use early returns for loading, error, or empty states (`if (isLoading) return <Skeleton />;`) instead of nested ternaries in JSX.
- **Intention-Revealing Variables Over JSX Comments:** Never write `{/* check if eligible */}` in JSX. Extract complex conditions into self-explaining booleans before the `return` (`const canRunTrialQa = ...;`).
- **Self-Explanatory Naming:** Use `is/has/can/should*` for booleans, `handle<Action>` for internal event handlers, and `on<Event>` for callback props so props and handlers never need explanatory comments or JSDoc.
- **Small Single-Purpose Components (No Mode-Switching Flags):** If a boolean prop splits a component's core behavior (e.g., `<UserModal isEditMode />`), split it into two small components (`<CreateUserModal />`, `<EditUserModal />`) sharing base primitives.
- **Comment Sync on Edit:** When updating or removing a component, hook, or prop, immediately update or delete any adjacent comments/JSDoc rendered stale or redundant.

## 2. State Management & Data Flow
- **Minimal & Derived State:** Never store computed values in `useState` or sync them via `useEffect`. Compute derived values directly during render (`const fullName = `${first} ${last}``).
- **Do Not Mirror Props in State:** Render props directly. If seeding an isolated draft editor, prefix the prop with `initial*` (`initialName`) or reset the component instance via `key`.
- **Reset State via `key`:** Pass a unique `key={entityId}` to a child component (`<ProfileEditor key={userId} userId={userId} />`) to cleanly reset internal state on entity changes instead of resetting state in `useEffect`.
- **State Colocation & Lifting:** Keep state in the lowest common ancestor that needs it. Use local state for single-component UI, localized Context for compound component subtrees, and global state only for app-wide concerns.
- **Immutability & Functional Updaters:** Never mutate state arrays/objects directly. Use functional updaters (`setItems(prev => [...prev, item])`) when next state depends on previous state.
- **Focused Context:** Split unrelated concerns into separate Contexts and memoize provider values when necessary so consumers do not re-render unnecessarily.

## 3. Effects & Synchronization ("You Might Not Need an Effect")
`useEffect` is strictly for **synchronizing with external systems** (DOM listeners, timers, WebSockets, non-React widgets, or network subscriptions).

| Goal | Anti-Pattern | Do This Instead |
| :--- | :--- | :--- |
| Transform data for rendering | `useEffect` + `useState` | Compute directly in component body during render |
| Cache expensive calculation | `useEffect` + `useState` | `useMemo(() => compute(a, b), [a, b])` |
| Handle user clicks / submits | `useEffect` watching state flag | Execute logic directly in `onClick` / `onSubmit` handler |
| Reset state when prop changes | `useEffect` calling `setState` | Pass `key={propId}` to the component |
| Notify parent of state change | `useEffect` calling `onChange` | Call `onChange` inside the event handler that updates state |

- **Cleanup & Race Conditions:** Every effect that registers listeners, timers, or async fetches must return a cleanup function (e.g., `AbortController` or `let ignore = false` flag on async fetches) and survive React `StrictMode` double-invocation.
- **Custom Hooks:** Extract non-trivial or reusable effect synchronization into focused `use*` custom hooks.

## 4. Performance & Rendering
- **Pure Render Phase:** Render must be a pure function of props, state, and context—never mutate external variables, touch the DOM, or trigger side-effects during render.
- **Stable List Keys:** Always use stable, unique entity IDs (`key={item.id}`). Never use `Math.random()` or array indices for lists that can filter, sort, or reorder.
- **Pragmatic Memoization:** Do not wrap cheap expressions in `useMemo`/`useCallback`. Use `useMemo` for heavy computations or referential identity passed to dependencies/memoized children; use `useCallback` for callbacks passed to `React.memo` children or hook dependencies (or rely on React Compiler where enabled).
- **Refs (`useRef`):** Use `useRef<ReturnType<typeof setInterval> | null>(null)` or DOM refs for mutable values that persist across renders without triggering re-renders.
- **Code Splitting:** Use `React.lazy` + `<Suspense fallback={...}>` for heavy, non-critical UI (charts, rich editors, modals).

## 5. Component API Design & Accessibility (WCAG / ARIA)
- **Composition Over Props Overload:** Avoid "god components" with many boolean flags. Use `children` slots or Compound Components (`<Card><Card.Header />...</Card>` or `<Tabs>` backed by Context).
- **Extend Native HTML Attributes & Refs:**
  - Extend `React.ComponentPropsWithRef<'button'>` (or target element) and spread `...props` so consumers can pass `aria-*`, `data-*`, `disabled`, and event handlers.
  - In React 19+, accept `ref` directly as a prop (`function Button({ ref, className, ...props }: ButtonProps)`); in React 18, wrap primitives in `React.forwardRef`.
  - Merge incoming `className` safely with `cn(...)` (`clsx` + `tailwind-merge`).
- **Accessibility Requirements:**
  - **Semantic HTML First:** Use `<button>` for actions (never `<div onClick>`), `<a href>` for navigation, and landmarks (`<main>`, `<nav>`, `<header>`).
  - **Keyboard & Focus:** Ensure interactive elements are tab-focusable with visible focus rings (`focus-visible:ring-2`), and trap/restore focus in modals/drawers.
  - **Forms & Dynamic ARIA:** Pair every input with a `<label htmlFor>` (or `aria-label`), link errors via `aria-describedby`/`aria-errormessage`, and expose state via `aria-expanded`, `aria-pressed`, `aria-selected`, and `aria-busy`.
