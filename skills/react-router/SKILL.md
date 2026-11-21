---
name: react-router
description: Build applications with React Router v7+ in Framework, Data, Declarative, and RSC modes. Use when configuring routes, route modules, loaders, actions, forms, fetchers, navigation, pending UI, SSR/SPA/pre-rendering, middleware, URL params/search params, or React Router upgrades.
license: MIT
---

# React Router (v7+)

**Mandatory Base Rule:** All React Router code written, updated, or deleted MUST strictly follow the global **Fundamental Code & Comment Principles** (`rules/GEMINI.md` Section 3: minimal code chunks, guard clauses, self-explaining names, zero narrator comments, strict comment-code sync/deletion, and surgical diffs).

## 1. Core Clean Code & v7 Package Rules
- **Unified Package Imports:** Always import from `"react-router"` (never `"react-router-dom"` or `"@remix-run/*"`). Use `@react-router/dev/routes` (`index`, `route`, `layout`, `prefix`) only inside `app/routes.ts`.
- **Small, Flat `loader` & `action` Functions:**
  - Use early guard clauses (`if (!session) throw redirect("/login");`, `if (!item) throw data("Not Found", { status: 404 });`).
  - Keep `loader` and `action` thin: extract database queries, validation, and business logic into self-explaining server functions (`getProjectById`, `validateCheckoutForm`) instead of bloated inline blocks.
- **No Route-Level `useEffect` Fetching:** In Framework and Data modes, always load via `loader`/`clientLoader` and mutate via `action`/`clientAction`.

## 2. Identify the App Mode First
Never mix mode patterns unless explicitly migrating:

| Mode | How to Detect | Core Primitives |
| :--- | :--- | :--- |
| **Framework Mode** | `@react-router/dev` in `package.json`, `react-router.config.ts`, `app/routes.ts`, `./+types/<route>` | Route modules (`loader`, `action`, `clientLoader`, `clientAction`, `default`, `ErrorBoundary`, `HydrateFallback`, `meta`, `middleware`), SSR/SPA/prerender |
| **Data Mode** | `createBrowserRouter` / `createMemoryRouter` + `<RouterProvider>` without `@react-router/dev/vite` | Route objects (`path`, `Component`, `ErrorBoundary`, `loader`, `action`, `lazy`, `children`) defined outside render |
| **Declarative Mode** | `<BrowserRouter>`, `<Routes>`, `<Route element={<Comp />}>` | Client-only routing (`<Outlet>`, `<Link>`, `<NavLink>`, `useParams`, `useSearchParams`, `useNavigate`). **No** loaders, actions, `<Form>`, or `useFetcher` |
| **Unstable RSC Mode** | `unstable_reactRouterRSC`, `@vitejs/plugin-rsc`, or `unstable_RSCRouteConfig` | `ServerComponent`, `ServerLayout`, `ServerErrorBoundary`, `"use client"`, `"server-only"` boundaries |

## 3. Framework Mode Standards
- **Route Types (`typegen`):** Import generated types via `import type { Route } from "./+types/<route>";` and type signatures with `Route.LoaderArgs`, `Route.ActionArgs`, `Route.ComponentProps`, `Route.MetaArgs`, and `Route.MiddlewareFunction`. Never edit `.react-router/types`.
- **Component Props over Hooks in Route Modules:** Read `loaderData`, `actionData`, `params`, and `matches` directly from `Route.ComponentProps` in the route's default component; `meta` receives `{ loaderData }` (do not use deprecated `data`).
- **Server/Client Isolation:** Keep Node/DB/secret logic in `.server.ts` modules called only from `loader`, `action`, or server `middleware`.
- **v7.9–v7.18+ Features:** Support `future.v8_middleware` (`middleware` / `clientMiddleware`), `future.v8_splitRouteModules`, `future.v8_viteEnvironmentApi`, and `fetcher.reset()` when enabled in `react-router.config.ts`.

## 4. Shared Data & Framework Patterns (Loaders, Actions, Forms, Fetchers)
- **Responses & Errors:**
  - Validation error in `action`: `return data({ errors }, { status: 400 })` and render via `actionData` or `fetcher.data`.
  - Not found / fatal error in `loader`: `throw data("Not Found", { status: 404 })` to trigger the nearest `ErrorBoundary`.
  - Let React Router automatically revalidate loaders after actions unless `shouldRevalidate` is explicitly required.
- **Form vs. Fetcher Selection:**
  - `<Form method="get">`: Search/filter updates that change URL search params (`new URL(request.url).searchParams` in `loader`).
  - `<Form method="post">`: Mutations that navigate or add a history entry/redirect.
  - `useFetcher()` / `<fetcher.Form>`: In-place mutations (toggles, inline edits, popovers) without URL change; use `fetcher.formData` for optimistic UI and `fetcher.reset()` to clear fetcher state.

## 5. Navigation & URL State (All Modes)
- Use `<Link>` or `<NavLink>` for internal links, `redirect()` inside loaders/actions, and `useNavigate()` only for imperative client events.
- Treat `params` and `searchParams` as untrusted strings—parse and validate them, and preserve unrelated search params when updating filters.

## 6. Version-Matched Local Docs Fallback
Only when working on unfamiliar edge cases (custom SSR `createStaticHandler`, RSC boundaries, middleware context, or version upgrades), inspect the installed package docs in `node_modules/react-router/docs/` (check the top `[MODES: ...]` marker before applying).
