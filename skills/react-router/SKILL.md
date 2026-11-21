---
name: react-router
description: Build applications with React Router v7+ in Framework, Data, Declarative, and RSC modes. Use when configuring routes, route modules, loaders, actions, forms, fetchers, navigation, pending UI, SSR/SPA/pre-rendering, middleware, URL params/search params, or React Router upgrades.
license: MIT
---

# React Router (v7+)

All React Router code written, updated, or deleted MUST follow `rules/GEMINI.md` Section 3 (minimal chunks, guard clauses, self-explaining names, zero narrator comments, surgical diffs).

## 1. Core Clean Code & v7 Package Rules

Import all runtime primitives from `"react-router"` and keep route handlers thin.

- **Unified Imports:** Code MUST import from `"react-router"` (never `"react-router-dom"` or `"@remix-run/*"`). Use `@react-router/dev/routes` (`index`, `route`, `layout`, `prefix`) only inside `app/routes.ts`.
- **Flat `loader` & `action` Functions:** Use early guard clauses (`if (!session) throw redirect("/login");`) and extract DB/validation logic into named server functions (`getProjectById`).
- **No Route-Level `useEffect` Fetching:** WHILE in Framework or Data mode, routes MUST load via `loader`/`clientLoader` and mutate via `action`/`clientAction`.

## 2. Identify the App Mode First

Never mix mode patterns unless migrating between modes.

| Mode | How to Detect | Core Primitives |
| :--- | :--- | :--- |
| **Framework Mode** | `@react-router/dev` in `package.json`, `react-router.config.ts`, `app/routes.ts`, `./+types/<route>` | Route modules (`loader`, `action`, `clientLoader`, `clientAction`, `default`, `ErrorBoundary`, `HydrateFallback`, `meta`, `middleware`) |
| **Data Mode** | `createBrowserRouter` / `createMemoryRouter` + `<RouterProvider>` without `@react-router/dev/vite` | Route objects (`path`, `Component`, `ErrorBoundary`, `loader`, `action`, `lazy`, `children`) outside render |
| **Declarative Mode** | `<BrowserRouter>`, `<Routes>`, `<Route element={<Comp />}>` | Client routing (`<Outlet>`, `<Link>`, `<NavLink>`, `useParams`, `useSearchParams`, `useNavigate`); no loaders or actions |
| **Unstable RSC Mode** | `unstable_reactRouterRSC`, `@vitejs/plugin-rsc`, or `unstable_RSCRouteConfig` | `ServerComponent`, `ServerLayout`, `ServerErrorBoundary`, `"use client"`, `"server-only"` |

## 3. Framework Mode Standards

Rely on generated route types and isolate server-only dependencies.

- **Route Types (`typegen`):** Import `import type { Route } from "./+types/<route>";` for `LoaderArgs`, `ActionArgs`, `ComponentProps`, `MetaArgs`, and `MiddlewareFunction`. Never edit `.react-router/types`.
- **Route Component Props:** Read `loaderData`, `actionData`, `params`, and `matches` from `Route.ComponentProps`; `meta` MUST read `{ loaderData }` instead of deprecated `data`.
- **Server/Client Isolation:** Keep Node, DB, and secret logic in `.server.ts` modules called only from `loader`, `action`, or server `middleware`.
- **v7.9–v7.18+ Features:** Support `future.v8_middleware`, `future.v8_splitRouteModules`, `future.v8_viteEnvironmentApi`, and `fetcher.reset()` when enabled in `react-router.config.ts`.

## 4. Loaders, Actions, Forms & Fetchers

Choose the mutation primitive by URL/history behavior and return structured responses.

| Primitive | Use Case | URL / History Behavior |
| :--- | :--- | :--- |
| `<Form method="get">` | Search and filter updates | Updates URL search params (`request.url` in `loader`) |
| `<Form method="post">` | Page-level mutations | Navigates, pushes history, or triggers `redirect()` |
| `useFetcher()` / `<fetcher.Form>` | In-place toggles, inline edits, popovers | Mutates without URL change; use `fetcher.formData` and `fetcher.reset()` |

- **Action Validation Errors:** WHEN `action` validation fails, return `data({ errors }, { status: 400 })` and render via `actionData` or `fetcher.data`.
- **Fatal Loader Errors:** IF a required resource is missing in `loader`, THEN `throw data("Not Found", { status: 404 })` to trigger the nearest `ErrorBoundary`.
- **Automatic Revalidation:** Let React Router revalidate loaders after actions unless `shouldRevalidate` is explicitly required.

## 5. Navigation & URL State (All Modes)

Validate URL parameters as untrusted strings and select navigation APIs by context.

| Navigation Context | Required API | Constraint |
| :--- | :--- | :--- |
| Declarative internal link | `<Link>` / `<NavLink>` | Preserve semantic `<a>` navigation |
| Server/client `loader` or `action` | `throw redirect("/path")` | Never use `useNavigate()` inside loaders/actions |
| Imperative client event | `useNavigate()` | Use only when declarative `<Link>` or `<Form>` does not apply |

- **Untrusted URL State:** Routes MUST parse and validate `params` and `searchParams`, and preserve unrelated search params when updating filters.

## 6. Version-Matched Local Docs Fallback

WHEN working on unfamiliar edge cases (custom SSR `createStaticHandler`, RSC boundaries, middleware context, or upgrades), inspect `node_modules/react-router/docs/` and verify the top `[MODES: ...]` marker before applying.
