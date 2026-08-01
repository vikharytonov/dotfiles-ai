# React Performance & Render Optimization

React is fast by default. Most performance issues stem from impure render functions, improper key choices, unnecessary state allocations, or missing code-splitting boundaries.

---

## 1. Pure Component Rendering

React assumes every component you write is a **pure function**. Given the same inputs (props, state, context), it must always return the exact same JSX.

- **No Side Effects in Render**: Do not mutate variables created outside of the render function, perform DOM mutations, or trigger state updates during render.
- **StrictMode Verification**: React renders components twice in development to catch side-effects during render.

### ❌ Anti-Pattern: Impure Rendering
```tsx
// BAD: Mutating a variable declared outside the component during render
let guestCount = 0;

function Cup() {
  guestCount = guestCount + 1; // Side-effect during render!
  return <h2>Tea cup for guest #{guestCount}</h2>;
}
```

### ✅ Best Practice: Pass Inputs via Props
```tsx
// GOOD: Pure function relying only on props
function Cup({ guestNumber }: { guestNumber: number }) {
  return <h2>Tea cup for guest #{guestNumber}</h2>;
}
```

---

## 2. List Rendering & Stable Keys

When rendering lists of components, React relies on the `key` prop to identify which items have changed, been added, or been removed.

### ❌ Anti-Pattern: Index or Non-Deterministic Keys
```tsx
// BAD: Using array index when items can be filtered, sorted, or reordered
{items.map((item, index) => (
  <TodoItem key={index} todo={item} />
))}

// BAD: Non-deterministic key breaks DOM state and causes infinite remounting
{items.map((item) => (
  <TodoItem key={Math.random()} todo={item} />
))}
```

### ✅ Best Practice: Unique, Stable Entity IDs
```tsx
// GOOD: Use unique ID from database or data source
{items.map((item) => (
  <TodoItem key={item.id} todo={item} />
))}
```

---

## 3. Pragmatic Memoization (`useMemo`, `useCallback`, `React.memo`)

Do not default to wrapping every function in `useCallback` or every value in `useMemo`. Memoization carries a memory and comparison overhead.

### When to Use `useMemo`
1. **Computationally Expensive Calculations**: Filtering/sorting thousands of items or performing heavy calculations.
2. **Referential Identity Preservation**: Preserving object reference passed as a dependency to custom hooks or memoized child components.

```tsx
// GOOD: Filter 10,000 items only when items or query change
const visibleTodos = useMemo(() => {
  return filterTodos(todos, query);
}, [todos, query]);
```

### When to Use `useCallback`
* Use `useCallback` to preserve function referential identity when passing callbacks to child components wrapped in `React.memo`, or when passing callbacks in custom hook dependency arrays.

```tsx
const handleToggle = useCallback((id: string) => {
  setTodos((prev) => prev.map(t => t.id === id ? { ...t, done: !t.done } : t));
}, []); // Empty deps because updater form is used
```

### When to Use `React.memo`
* Wrap leaf components in `React.memo` only if they render frequently with the exact same props and re-rendering is measurably expensive.

---

## 4. Refs & DOM Management

Use `useRef` when you need to store a value that **persists across renders without triggering a re-render**.

### Valid Use Cases for `useRef`
- Storing timer IDs (`setInterval`, `setTimeout`)
- Storing DOM node references (`HTMLInputElement`, `HTMLDivElement`)
- Storing canvas/third-party instances
- Storing previous prop/state values for comparison

```tsx
function Timer() {
  const timerRef = useRef<NodeJS.Timeout | null>(null);

  const startTimer = () => {
    if (timerRef.current !== null) return;
    timerRef.current = setInterval(() => tick(), 1000);
  };

  const stopTimer = () => {
    if (timerRef.current) {
      clearInterval(timerRef.current);
      timerRef.current = null;
    }
  };
}
```

---

## 5. Code-Splitting & Lazy Loading

Reduce initial JavaScript bundle size by splitting heavy non-critical components (modals, complex charts, rich text editors).

```tsx
import React, { lazy, Suspense } from 'react';

// Lazy load heavy component
const HeavyChart = lazy(() => import('./HeavyChart'));

function Dashboard() {
  return (
    <div>
      <h1>Dashboard</h1>
      <Suspense fallback={<div>Loading chart...</div>}>
        <HeavyChart />
      </Suspense>
    </div>
  );
}
```
