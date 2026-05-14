---
name: mobile-responsiveness
description: "End-to-end mobile responsiveness audit covering route discovery, screenshot capture across viewports and breakpoints, visual inspection for layout issues, responsive design anti-pattern detection, and findings report generation. Works with any web app framework including Next.js, Nuxt, and Vite. Do not use for native mobile app testing."
---

# Mobile Responsiveness Audit

Use this skill when the user asks to audit a web application for mobile and responsive layout issues. The skill covers the full pipeline: route discovery, screenshot capture across viewports, visual inspection, and a written findings report.

## Phase 0 — Prerequisites

Before starting, confirm two things:

### 0.1 Running application

The audit requires a reachable application. Ask the user:

> Is a local dev server or live app running? If so, provide the base URL (e.g. `http://localhost:3000`, `https://staging.example.com`).

Do not proceed until a base URL is confirmed reachable.

### 0.2 Authentication (if needed)

If the app requires authentication to reach audited routes, ask the user for credentials or a session token. The method depends on the framework — see the relevant **references/** file for framework-specific instructions (e.g. `references/nextjs.md` for cookie-based Next.js auth).

### 0.3 Framework detection

Identify the framework and test tooling in use by scanning the workspace root:

- `next.config.*` -> Next.js
- `nuxt.config.*` -> Nuxt
- `vite.config.*` / `svelte.config.*` -> Vite / SvelteKit
- `angular.json` -> Angular

If a **references/** file exists for the detected framework, load it for framework-specific guidance.

## Phase 1 — Route and State Coverage

Ensure all pages and meaningful UI states are registered for screenshot capture.

### 1.1 Discover pages

Scan the application source for page/route entry points using framework conventions.

### 1.2 Check existing test coverage

If the project already has a screenshot audit setup, compare discovered pages against registered routes. Flag any gaps.

### 1.3 Identify state variants

Look for UI states worth capturing separately: modals, sidebar toggles, tab switches, empty states vs populated views.

### 1.4 Readiness considerations

For pages that load content asynchronously, identify a readiness indicator.

## Phase 2 — Run the Screenshot Audit

### 2.1 Determine scope

Ask the user for routes, viewports, and timeout. Suggested viewports:

| Label | Width x Height |
|---|---|
| Desktop (1440) | 1440 x 900 |
| Desktop (1280) | 1280 x 800 |
| Tablet | 768 x 1024 |
| Mobile (Android) | 412 x 915 |
| Mobile (iOS) | 390 x 844 |

### 2.2 Execute the capture

Use Playwright or existing audit infrastructure to capture full-page screenshots across viewports.

### 2.3 After the run

Confirm completion. Report any failed captures.

## Phase 3 — Visual Inspection

### 3.1 Inspect each screenshot

Check for: horizontal overflow, illegible text, navigation overflow, missing column collapse, small tap targets, content clipping, fixed-width overflow, element collision, broken layout.

### 3.2 Write findings.json and findings report

Write structured findings to the audit output directory.

## Phase 4 — Static Source Audit (Optional)

If requested, inspect source files for responsive anti-patterns: fixed pixel widths, no-wrap on variable content, unresponsive multi-column layouts, tiny touch targets, inline push navigation.

## Handoff

After completing the audit:
1. Report the output directory path.
2. List all files written.
3. State how many issues were found and the top priorities.
4. Offer to re-run with different scope, viewports, or routes.
