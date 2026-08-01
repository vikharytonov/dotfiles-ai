---
name: react-component-standards
description: Enforces official React best practices, high performance, reusability, accessibility, state management, and clean code styles established over years of React development.
---

# React Component Standards & Best Practices

Use this skill whenever you are creating, refactoring, or reviewing React components. It enforces official React architecture principles, state minimization, effect synchronization rules, performance optimizations, TypeScript strictness, and accessibility.

---

## 📚 Reference Documentation Index

Before building or refactoring React components, consult the detailed topic references:

| Reference | Use When |
| :--- | :--- |
| [`references/state-management.md`](file:///home/vitalii/projects/dotfiles-ai/my-custom-skills/skills/react-component-standards/references/state-management.md) | Designing state structure, avoiding derived/redundant state, lifting state up, resetting state via `key`, or updating state immutably. |
| [`references/effects-and-synchronization.md`](file:///home/vitalii/projects/dotfiles-ai/my-custom-skills/skills/react-component-standards/references/effects-and-synchronization.md) | Determining when `useEffect` is required vs anti-pattern, handling fetch race conditions, cleaning up subscriptions, and creating custom hooks. |
| [`references/performance-and-rendering.md`](file:///home/vitalii/projects/dotfiles-ai/my-custom-skills/skills/react-component-standards/references/performance-and-rendering.md) | Pure rendering rules, list keys, pragmatic memoization (`useMemo`/`useCallback`/`React.memo`), `useRef` usage, and lazy loading with `Suspense`. |
| [`references/component-design-and-a11y.md`](file:///home/vitalii/projects/dotfiles-ai/my-custom-skills/skills/react-component-standards/references/component-design-and-a11y.md) | Designing component APIs, composition over props overload, extending native HTML attributes (`ComponentPropsWithRef`), compound components, `cn(...)` class merging, and WCAG/ARIA accessibility. |
| [`references/sources.md`](file:///home/vitalii/projects/dotfiles-ai/my-custom-skills/skills/react-component-standards/references/sources.md) | Checking upstream official React documentation, TypeScript cheatsheets, W3C WAI-ARIA specs, and release notes for future updates to this skill. |

---

## 📌 Core Architectural Principles

1. **Pure Component Rendering**:
   - Component render functions must be pure functions. Same props + state -> same JSX.
   - Never mutate outer variables or trigger side-effects directly during the render phase.

2. **Minimal & Derived State**:
   - Compute values during render instead of creating extra state variables synced with `useEffect`.
   - Never duplicate props into local state unless explicitly seeding initial state for an isolated draft editor.

3. **Effects are ONLY for Synchronization**:
   - Use `useEffect` strictly to synchronize with external systems (DOM APIs, websockets, third-party libraries).
   - User interactions (clicks, submits) belong in event handlers, NOT in effects.

4. **DOM & Ref Access**:
   - Wrap reusable primitives with `React.forwardRef` to expose underlying DOM nodes.
   - Extend `React.ComponentPropsWithRef<"element">` to inherit all standard HTML/ARIA attributes seamlessly.

5. **Tailwind & Class Merging**:
   - Combine `clsx` and `tailwind-merge` via `cn(...)` to allow clean class overrides without style specificity collisions.

---

## 🔍 Pre-Submission Quality Checklist

Before marking any React component task as complete, verify against this checklist:

- [ ] **Pure Rendering**: Does the component render without side-effects in the render phase?
- [ ] **Derived State**: Are calculated values computed directly during render rather than stored in state/effects?
- [ ] **Effect Check**: Are effects used only for external system synchronization and properly cleaned up?
- [ ] **Ref & Props**: Does the primitive extend native element props and forward DOM refs correctly?
- [ ] **Class Merging**: Are classes merged safely using `cn(...)`?
- [ ] **List Keys**: Are list items rendered with stable, unique IDs (avoiding non-deterministic or array index keys when reordering/filtering)?
- [ ] **Accessibility**: Are semantic HTML tags used (`<button>` instead of `<div onClick>`), with visible focus states and proper ARIA tags?
- [ ] **TypeScript**: Is the component strictly typed without `any` escape hatches?
