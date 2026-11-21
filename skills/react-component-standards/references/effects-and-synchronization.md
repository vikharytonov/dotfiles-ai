# React Effects & Synchronization Best Practices

`useEffect` is one of the most misused features in React. Following official React guidance, **Effects are strictly for synchronizing your component with an external system**. They are not for handling user events or transforming data for rendering.

---

## 1. The Core Rule of Effects

An **external system** means anything outside of React's render loop, such as:
- Browser APIs (`window.addEventListener`, `IntersectionObserver`, `localStorage`)
- Third-party non-React libraries (Chart.js, Leaflet maps, D3)
- Subscribing to network sockets or server events
- Fetching data from APIs

If code is not synchronizing with an external system, **you probably do not need `useEffect`**.

---

## 2. "You Might Not Need an Effect" Decision Matrix

| Goal | Don't Use Effect | Do This Instead |
| :--- | :--- | :--- |
| **Transform data for rendering** | `useEffect` + `useState` | Compute value in body during render |
| **Handle user clicks / submits** | `useEffect` checking state | Put logic in event handlers (`onClick`, `onSubmit`) |
| **Reset state when prop changes** | `useEffect` calling `setState` | Pass a unique `key` prop to the child component |
| **Notify parent of state change** | `useEffect` calling `onChange` | Call `onChange` directly inside the event handler |
| **Cache expensive calculations** | `useEffect` + `useState` | Use `useMemo` |

---

## 3. Event Handlers vs Effects

- **Event Handlers**: Code runs because a specific action occurred (e.g., user clicked a "Buy" button). Put user-triggered logic, analytics tracking, and POST requests here.
- **Effects**: Code runs because the component was displayed or state synchronized with an external system (e.g., component mounted and needs a WebSocket connection).

### ❌ Anti-Pattern: Triggering User Intent via Effect
```tsx
// BAD: Using an effect to handle a form submit side-effect
function Form() {
  const [submitted, setSubmitted] = useState(false);

  useEffect(() => {
    if (submitted) {
      postData('/api/submit'); // Should be in onSubmit!
    }
  }, [submitted]);

  const handleSubmit = () => setSubmitted(true);
}
```

### ✅ Best Practice: User Intent Belongs in Event Handlers
```tsx
// GOOD: Immediate, predictable, and clear responsibility
function Form() {
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    await postData('/api/submit');
  };
}
```

---

## 4. Effect Cleanup & Race Condition Prevention

Every Effect that sets up a subscription, timer, event listener, or fetch call **must provide a cleanup function**.

### Fetching Data Safely (Handling Race Conditions)
When fetching data inside an effect, fast consecutive prop changes can cause responses to return out of order.

```tsx
// GOOD: Clean up using an active flag or AbortController
useEffect(() => {
  let ignore = false;

  async function startFetching() {
    const json = await fetchResult(query);
    if (!ignore) {
      setResults(json);
    }
  }

  startFetching();

  return () => {
    ignore = true; // Prevents stale response from setting state
  };
}, [query]);
```

### Subscriptions & DOM Event Cleanup
```tsx
// GOOD: Clean up subscriptions and window event listeners
useEffect(() => {
  const handleResize = () => setWindowWidth(window.innerWidth);
  window.addEventListener('resize', handleResize);

  return () => {
    window.removeEventListener('resize', handleResize);
  };
}, []);
```

---

## 5. StrictMode Double-Invocation Resilience

In React StrictMode (development), components mount, unmount, and remount automatically to test effect cleanup.

- **Rule**: If your effect breaks when it runs twice (e.g., creating duplicate DOM elements or dual connections), your cleanup function is incomplete.
- **Solution**: Always undo in cleanup what you did in setup.

---

## 6. Extracting Custom Hooks

When effect logic becomes non-trivial or shared across components, extract it into a custom hook.

```tsx
// Reusable Custom Hook
export function useOnlineStatus() {
  const [isOnline, setIsOnline] = useState(navigator.onLine);

  useEffect(() => {
    const handleOnline = () => setIsOnline(true);
    const handleOffline = () => setIsOnline(false);

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);

  return isOnline;
}
```
