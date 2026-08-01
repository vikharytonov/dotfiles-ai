# React Component API Design & Accessibility (a11y)

Writing clean, reusable React components requires thoughtful prop interface design, composition patterns, and built-in accessibility.

---

## 1. Composition over Inheritance & Props Overload

Avoid creating massive "god components" with dozens of configuration flags. Use composition and children slots to build flexible UI systems.

### ❌ Anti-Pattern: Props Overload
```tsx
// BAD: Rigid component with 20 configuration props
<Card
  title="Profile"
  showAvatar={true}
  avatarUrl="/user.png"
  showFooter={true}
  footerButtonText="Save"
  onFooterButtonClick={handleSave}
/>
```

### ✅ Best Practice: Composition via Children & Subcomponents
```tsx
// GOOD: Flexible, readable composition
<Card>
  <Card.Header title="Profile" avatarUrl="/user.png" />
  <Card.Body>
    <UserProfileDetails />
  </Card.Body>
  <Card.Footer>
    <Button onClick={handleSave}>Save</Button>
  </Card.Footer>
</Card>
```

---

## 2. Strict Props & Extending Native Elements

When building reusable UI primitives (buttons, inputs, cards, dialogs), extend native HTML attributes so consumers can pass standard attributes like `aria-*`, `data-*`, `disabled`, `autoFocus`, `onClick`, and `className`.

```tsx
import React from 'react';
import { cn } from '@/lib/utils'; // clsx + tailwind-merge helper

export interface ButtonProps extends React.ComponentPropsWithRef<'button'> {
  variant?: 'primary' | 'secondary' | 'danger' | 'ghost';
  isLoading?: boolean;
}

export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant = 'primary', isLoading, children, disabled, ...props }, ref) => {
    return (
      <button
        ref={ref}
        disabled={disabled || isLoading}
        className={cn(
          'inline-flex items-center justify-center rounded-md px-4 py-2 text-sm font-medium transition-colors focus:outline-none focus:ring-2',
          variant === 'primary' && 'bg-blue-600 text-white hover:bg-blue-700',
          variant === 'secondary' && 'bg-gray-100 text-gray-900 hover:bg-gray-200',
          variant === 'danger' && 'bg-red-600 text-white hover:bg-red-700',
          className
        )}
        {...props}
      >
        {isLoading ? <Spinner className="mr-2 h-4 w-4 animate-spin" /> : children}
      </button>
    );
  }
);

Button.displayName = 'Button';
```

---

## 3. Compound Components Pattern

When multiple components work together to manage shared implicit state (e.g., Accordion, Tabs, Dropdown), use the Compound Component pattern backed by React Context.

```tsx
import React, { createContext, useContext, useState } from 'react';

interface TabsContextType {
  activeTab: string;
  setActiveTab: (id: string) => void;
}

const TabsContext = createContext<TabsContextType | null>(null);

function useTabs() {
  const context = useContext(TabsContext);
  if (!context) throw new Error('Tabs compound components must be rendered inside <Tabs>');
  return context;
}

export function Tabs({ defaultTab, children }: { defaultTab: string; children: React.ReactNode }) {
  const [activeTab, setActiveTab] = useState(defaultTab);
  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      <div className="tabs-container">{children}</div>
    </TabsContext.Provider>
  );
}

Tabs.List = function TabsList({ children }: { children: React.ReactNode }) {
  return <div role="tablist" className="flex border-b">{children}</div>;
};

Tabs.Tab = function Tab({ id, children }: { id: string; children: React.ReactNode }) {
  const { activeTab, setActiveTab } = useTabs();
  const isActive = activeTab === id;

  return (
    <button
      role="tab"
      aria-selected={isActive}
      onClick={() => setActiveTab(id)}
      className={cn('px-4 py-2 border-b-2', isActive ? 'border-blue-600 font-bold' : 'border-transparent')}
    >
      {children}
    </button>
  );
};
```

---

## 4. Web Accessibility (WCAG & ARIA) Rules

Accessible components are usable by keyboard navigation, screen readers, and assistive technologies.

### Key Rules:
1. **Semantic HTML Elements First**:
   - Use `<button>` for clickable actions (never `<div onClick={...}>` unless adding `role="button"`, `tabIndex={0}`, and `onKeyDown` handlers for `Enter` and `Space`).
   - Use `<a>` with `href` for navigation.
   - Use `<nav>`, `<main>`, `<header>`, `<footer>`, `<aside>`, `<article>` for landmarks.
2. **Keyboard Navigation & Focus Management**:
   - Ensure interactive elements are focusable in tab order (`tabIndex={0}`).
   - Visible focus indicators must be present (`focus:outline-none focus:ring-2`).
   - Modals and Drawers should lock focus inside when open (Focus Trap) and return focus to the trigger element when closed.
3. **Form Accessibility**:
   - Associate input elements with labels using `htmlFor="input-id"` or wrapping inputs inside `<label>`.
   - Provide helper text/error messages linked via `aria-describedby` or `aria-errormessage`.
4. **Dynamic States**:
   - Indicate expand/collapse with `aria-expanded={isOpen}`.
   - Indicate active toggles with `aria-pressed={isPressed}`.
   - Indicate loading/busy states with `aria-busy={isLoading}`.
