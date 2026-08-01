---
name: react-component-standards
description: Enforces official React best practices, high performance, reusability, and clean code styles for creating and using React components.
---

# React Component Standards & Review

Use this skill whenever you are creating, refactoring, or reviewing React components. It ensures code adheres to the official React documentation, performance best practices, TypeScript strictness, and modern design systems.

## 📌 Core Architecture & Best Practices
1. **Function Components & Hooks**:
   - Use standard function components (prefer arrow functions or standard declarations, be consistent).
   - Always use modern hooks (`useState`, `useEffect`, `useMemo`, `useCallback`, `useId`, etc.).
   - Custom Hooks: Extract complex stateful logic or side-effects into reusable custom hooks (e.g., `useCopy`, `useAuth`).

2. **Strict Props & Types**:
   - Define clear TypeScript interfaces/types for all component props.
   - For components wrapping native HTML elements, extend the native component props using `React.ComponentPropsWithoutRef<"element">` or `React.ComponentPropsWithRef<"element">`.
   - Example:
     ```typescript
     export interface ButtonProps extends React.ComponentPropsWithRef<"button"> {
       variant?: "primary" | "secondary";
     }
     ```

3. **DOM Ref Forwarding**:
   - Use `React.forwardRef` for reusable UI/atom components so parent components can access the underlying DOM node.
   - Example:
     ```typescript
     export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
       ({ className, children, ...props }, ref) => {
         return (
           <button ref={ref} className={cn("btn", className)} {...props}>
             {children}
           </button>
         );
       }
     );
     Button.displayName = "Button";
     ```

---

## ⚡ Performance Optimization
1. **Unnecessary State**:
   - Do not duplicate props in state.
   - Derive values during rendering rather than storing them in state and syncing with `useEffect`.
2. **Memoization Strategy**:
   - Use `useMemo` for computationally expensive calculations.
   - Use `useCallback` to preserve referential identity of callback props when passing them to memoized child components.
   - Use `React.memo` selectively on expensive leaf components that render frequently with unchanged props.
3. **Key Prop Rules**:
   - Always provide unique, stable `key` props when rendering lists. Avoid using array indices as keys if list items can be reordered, deleted, or inserted.

---

## 🎨 Styling & Reusability
1. **Tailwind & Class Name Merging**:
   - Always use the `cn(...)` utility (combining `clsx` and `tailwind-merge`) to merge incoming class names.
   - Ensure default styles can be easily overridden by classes passed via props.
2. **Semantic HTML**:
   - Choose semantic HTML elements (`header`, `main`, `section`, `nav`, `button`, `article`) instead of nesting generic `div`s.
   - Ensure components follow WCAG accessibility standards (e.g., proper ARIA attributes, button roles, keyboard navigability).

---

## 🔍 Change-in-Progress Review Checklist
Before marking any React component task as done, review the following:
*   [ ] Does the component extend standard HTML attributes where applicable?
*   [ ] If it wraps a native element, does it use `forwardRef` correctly?
*   [ ] Are class names merged safely using `cn(...)`?
*   [ ] Are there any redundant state variables or unnecessary `useEffect` hooks?
*   [ ] Is lists rendering using stable keys?
*   [ ] Does it compile without TypeScript errors?
