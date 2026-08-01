# React State Management & Data Flow

This guide outlines official React principles and time-tested best practices for managing state, structuring data flow, and avoiding state synchronization anti-patterns.

---

## 1. Single Source of Truth & Lifting State Up

- **Top-Down (Unidirectional) Data Flow**: Data flows down from parent components to child components via props.
- **Lift State Up**: When two or more sibling components need access to the same state, move that state to their closest common ancestor.
- **Avoid Duplicating State**: Do not store the same data in multiple components. Pass state down as props and pass event callbacks up to request state changes.

---

## 2. Minimal & Derived State

The most common state bug in React applications is keeping redundant or derived data in state.

### ❌ Anti-Pattern: Storing Derived Values in State
```tsx
// BAD: Syncing derived state with useEffect or extra state setters
function Form() {
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [fullName, setFullName] = useState(''); // Redundant!

  useEffect(() => {
    setFullName(firstName + ' ' + lastName);
  }, [firstName, lastName]);
}
```

### ✅ Best Practice: Compute Derived Values During Render
```tsx
// GOOD: Calculated instantly during render; zero extra state or effect cycles
function Form() {
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');

  const fullName = `${firstName} ${lastName}`;
}
```

### ❌ Anti-Pattern: Mirroring Props in State
```tsx
// BAD: Local state gets out of sync when prop changes
function UserCard({ user }) {
  const [name, setName] = useState(user.name); // Will not update if user prop updates!
}
```

### ✅ Best Practice: Use Prop Directly (or Seed Initial State Explicitly)
```tsx
// GOOD: Always renders fresh prop data
function UserCard({ user }) {
  return <h2>{user.name}</h2>;
}

// GOOD: If editing a draft copy, prefix with 'initial' or use key to reset
function UserEditor({ initialName }) {
  const [name, setName] = useState(initialName);
}
```

---

## 3. Resetting State via the `key` Attribute

When a user switches between entities (e.g., selecting a different user profile or tab), resetting local component state manually via `useEffect` is brittle and error-prone.

### ✅ Best Practice: Use `key` to Re-initialize State
```tsx
// Outer component
function ProfilePage({ userId }) {
  // Passing a unique key forces React to treat ProfileEditor as a new component instance,
  // automatically resetting all internal state cleanly.
  return <ProfileEditor key={userId} userId={userId} />;
}

function ProfileEditor({ userId }) {
  const [comment, setComment] = useState(''); // Automatically resets when userId changes!
}
```

---

## 4. State Collocation

Keep state as close to where it is consumed as possible.

- **Local Component State**: UI state that only affects one component (e.g., `isOpen`, `isHovered`, `inputValue`) should live in that component.
- **Subtree State**: State shared by a small tree of components (e.g., form stepper, accordion) should live in the tree's root parent or a localized Context.
- **Global Application State**: Reserve global state (Zustand, Redux, global Context) strictly for data needed app-wide (e.g., authenticated user session, active theme, global notifications).

---

## 5. Immutability & Safe Updates

Never mutate state directly in React. Always treat state objects and arrays as immutable read-only values.

### ❌ Anti-Pattern: Direct Mutation
```tsx
// BAD: Mutating existing array/object prevents re-renders and breaks dev tools
const handleAdd = () => {
  items.push(newItem);
  setItems(items); // React won't detect object reference change!
};
```

### ✅ Best Practice: Immutable Updates & Functional Updaters
```tsx
// GOOD: Creating a new array reference
const handleAdd = () => {
  setItems((prevItems) => [...prevItems, newItem]);
};

// GOOD: Updating nested objects immutably
const handleUpdateCity = (newCity: string) => {
  setUser((prevUser) => ({
    ...prevUser,
    address: {
      ...prevUser.address,
      city: newCity,
    },
  }));
};
```

---

## 6. Context Usage Rules

Context is designed for sharing "global" data across a component tree without prop-drilling.

- **Keep Providers Focused**: Create separate contexts for logically distinct concerns (e.g., `AuthContext`, `ThemeContext`) rather than a single giant monolithic context.
- **Memoize Provider Values**: Wrap the value passed to `<Context.Provider value={...}>` in `useMemo` so consumers don't re-render on unrelated parent renders.
- **Do Not Overuse**: For 2-3 levels of components, explicit prop passing is cleaner, more readable, and easier to trace than Context.
