# Next.js — Mobile Responsiveness Reference

Framework-specific guidance for the `mobile-responsiveness` skill when auditing a Next.js application.

## Page Discovery

### App Router (Next.js 13+)

```bash
find <app-dir> -name "page.tsx" -o -name "page.jsx" | sort
```

Map each file to a route:
- `app/page.tsx` → `/`
- `app/dashboard/page.tsx` → `/dashboard`
- `app/users/[id]/page.tsx` → `/users/[id]` (dynamic — ask for a concrete URL)
- `app/(group)/settings/page.tsx` → `/settings` (route groups are transparent)

### Pages Router

```bash
find <pages-dir> -name "*.tsx" -o -name "*.jsx" | grep -v '_app\|_document\|_error\|api/' | sort
```

## Authentication

Next.js apps commonly use **NextAuth.js** (Auth.js). To obtain a session token:

1. Open the running app in a browser.
2. Sign in normally.
3. Open DevTools → Application → Cookies → select the app origin.
4. Copy the value of the `next-auth.session-token` cookie.

Pass the token to the audit via environment variable:

```bash
E2E_SESSION_TOKEN=<token> <audit-command>
```

In Playwright test setup, inject the cookie before navigation:

```typescript
await context.addCookies([{
  name: 'next-auth.session-token',
  value: process.env.E2E_SESSION_TOKEN,
  domain: 'localhost',
  path: '/',
}]);
```

## Audit Command Patterns

If the project has a configured audit script (e.g. `npm run test:e2e:audit`):

```bash
# Scoped audit (preferred — faster)
E2E_SESSION_TOKEN=<token> npm run test:e2e:audit -- \
  --routes=<route-key-1>,<route-key-2> \
  --devices=<device-key-1>,<device-key-2>

# Full audit (slow — only when explicitly requested)
E2E_SESSION_TOKEN=<token> npm run test:e2e:audit

# Extended timeout for slow routes
AUDIT_ROUTE_TIMEOUT_MS=120000 E2E_SESSION_TOKEN=<token> npm run test:e2e:audit -- \
  --routes=<route-key>
```

## Readiness Selectors

Next.js App Router pages with server components render progressively. For pages that use:
- **Client components with data fetching** → wait for a `data-testid` attribute on the loaded content
- **Suspense boundaries** → wait for the fallback to disappear
- **Loading.tsx** → wait for the loading UI to unmount

Prefer `data-testid` selectors over generic role queries for reliability.

## Tailwind CSS — Responsive Anti-Patterns

When auditing Next.js + Tailwind source files, flag these patterns:

| Anti-pattern | Example | Fix |
|---|---|---|
| Fixed pixel width on containers | `w-[600px]`, `min-w-[800px]` | Use `max-w-full` or responsive classes: `w-full md:w-[600px]` |
| `whitespace-nowrap` on variable text | `<p className="whitespace-nowrap">` | Remove or scope to `md:whitespace-nowrap` |
| Multi-column without stacking | `flex flex-row` with no `flex-col` breakpoint | Add `flex-col md:flex-row` |
| Tiny click targets | `h-6 w-6` on buttons | Use `min-h-[44px] min-w-[44px]` or `p-2` to pad the hit area |
| Horizontal nav without collapse | `<nav className="flex gap-4">` with many items | Add mobile menu (hamburger) or `hidden md:flex` with a drawer |
| Overflow-hidden masking issues | `overflow-hidden` on a parent hiding clipped children | Use `overflow-x-auto` or fix the child sizing |
| Hardcoded heights | `h-[calc(100vh-64px)]` without mobile adjustment | Add `h-[calc(100dvh-56px)] md:h-[calc(100vh-64px)]` |

## Sidebar and Navigation

Common patterns in Next.js apps:

- **Dashboard sidebar**: check for `data-testid` toggle buttons. The audit should auto-collapse sidebars on mobile viewports before capturing.
- **Auto-opening modals**: onboarding tours or paywall dialogs that fire on first visit. Capture them as state variants, then dismiss before the base route screenshot.
- **Bottom navigation on mobile**: if the app uses a bottom nav bar, ensure it does not overlap page content.

## Route Config Schema

If the project uses an audit route config file, entries typically follow this shape:

```typescript
interface AuditRoute {
  key: string;               // kebab-case unique identifier
  url: string;               // concrete URL path
  auth: "public" | "authenticated";
  isDynamic?: boolean;       // true if url is a curated example for a [param] route
  sourcePagePath?: string;   // relative path to the page source file
  readinessSelector?: string;// CSS selector to wait for before capture
  beforeCapture?: Array<{
    action: "click" | "wait" | "waitForSelector";
    selector?: string;
    ms?: number;
    required?: boolean;       // default true; false = continue if element not found
  }>;
  notes?: string;
}
```
