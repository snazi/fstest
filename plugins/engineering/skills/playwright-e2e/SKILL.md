---
name: playwright-e2e
description: "Set up Playwright MCP, then write, execute, and fix Playwright end-to-end (E2E) tests using auth-first token injection, Page Object Models, browser automation, and MCP browser tools for live selector verification. Use when planning, generating, or healing browser E2E tests against a running web application. Do not use for API-only tests or unit tests."
---

# Playwright E2E Testing

## When to Use This Skill

Use when planning, generating, or healing Playwright end-to-end tests against a running web application. Always use this skill for any browser automation or E2E test work.

## MCP Setup

Before using any `browser_*` MCP tools, verify the Playwright MCP server is configured. If it is not, set it up first.

### 1. Detect `<frontend_path>`

Identify the frontend root directory — the directory that contains `playwright.config.ts` and `package.json`. Search the repository if it is not obvious. Common locations: `app/ui/`, `frontend/`, `web/`, or the repo root.

### 2. Check Whether MCP Is Already Configured

Read `.codex/config.toml`. Look for an entry under `[mcp_servers]` whose command references `playwright run-test-mcp-server`.

If found: MCP is already configured — skip to the Auth-First Policy section below.

### 3. Verify Playwright Is Installed

Check that `@playwright/test` is listed in `<frontend_path>/package.json` dependencies. If it is not installed, tell the user to run:

```bash
cd <frontend_path> && npm install --save-dev @playwright/test
npx playwright install
```

Do not proceed until Playwright is confirmed installed.

### 4. Add MCP Server Configuration

Read `.codex/config.toml` (create it if it does not exist). Add the following entry under `[mcp_servers]`, substituting the actual `<frontend_path>`:

```toml
[mcp_servers.playwright-test]
command = "bash"
args = ["-c", "set -a; if [ -f <frontend_path>/.env.test ]; then . <frontend_path>/.env.test; fi; set +a; cd <frontend_path> && npx playwright run-test-mcp-server"]
```

Merge with any existing `[mcp_servers]` entries — do not overwrite them.

### 5. Confirm and Restart

Tell the user:
- The MCP server has been added to `.codex/config.toml`.
- They must **restart Codex** for the new MCP server to be available.
- After restart, `browser_*` tools will be available and this skill can proceed.

Do not attempt to use `browser_*` tools in the same session in which the MCP was just configured — they will not yet be available.

---

## Auth-First Policy

Default to token injection. Never use seed bootstrap unless the user explicitly asks.

1. Read `.env.test` before any navigation.
2. Extract `E2E_SESSION_TOKEN` (and `PLAYWRIGHT_BASE_URL` if present).
3. Navigate to the base URL and inject the session cookie using browser code tooling.
4. Verify auth: navigate to a protected route and confirm no redirect to the sign-in page.
5. Never print token values in logs or responses.

**Auth recovery:** if still on sign-in page after injection — re-check `.env.test`, re-inject with the active base URL/domain, retry once. If still unauthenticated, report a blocker with exactly what was attempted and stop.

## Key Paths

- **Test directory:** `<frontend_path>/e2e/`
- **Specs/plans:** `<frontend_path>/e2e/specs/`
- **Page Objects:** `<frontend_path>/e2e/pages/`
- **Fixtures:** `<frontend_path>/e2e/fixtures/`
- **Config:** `<frontend_path>/playwright.config.ts`

Always use repo-root paths when passing file paths to MCP browser tools.

## Test Structure

```typescript
import { test, expect } from "@playwright/test";

test.describe("[Feature Group]", () => {
  test("[Scenario Name]", async ({ page }) => {
    // 1. Step description
    // ... actions

    // 2. Expected outcome
    // ... assertions
  });
});
```

**Selector priority (best to worst):** `getByRole` -> `getByText` -> `getByPlaceholder` -> `getByLabel`. Never use bare CSS selectors.

**Never use:** `waitForNetworkIdle` or other deprecated APIs. Use `waitFor` with explicit conditions.

## Page Object Models

- Reuse existing Page Objects for pages that already have one.
- Create a new Page Object (`<frontend_path>/e2e/pages/<PageName>.ts`) if testing a page without one.
- Never duplicate locators across test files — all locators for a page belong in its Page Object.

## Planning Process

1. Authenticate browser context (Auth-First Policy).
2. Navigate and explore using `browser_snapshot`, `browser_click`, `browser_type`, `browser_hover`.
3. Map primary user journeys, critical paths, and feature boundaries.
4. Design scenarios: happy path, edge cases, error handling, unauthenticated access.
5. Write test plan to `<frontend_path>/e2e/specs/<feature>.md`.

## Generation Process

1. Read the test plan from `<frontend_path>/e2e/specs/`.
2. Authenticate browser session (Auth-First Policy).
3. Execute each step live using MCP browser tools to verify selectors and expected behavior.
4. Read the generator log for best-practice selector and timing recommendations.
5. Write test file — one test per file, file name is a filesystem-friendly version of the scenario name.
6. Run the test and verify it passes before moving to the next scenario.

## Healing Process

1. Run the failing test with debug mode to pause at the failure point.
2. Use `browser_snapshot`, `browser_console_messages`, `browser_network_requests`, `browser_evaluate` to diagnose the failure.
3. Categorize: selector changed, timing issue, data dependency, application regression.
4. Fix: update selectors to match current DOM, fix assertions, improve wait strategies, update Page Objects.
5. If a test is correct but the app has a genuine bug, mark with `test.fixme()` and a clear comment explaining actual vs expected behavior.
6. Re-run after each fix; run the full suite after all fixes to catch regressions.

## Safety Guards

- Do not hardcode values that exist in shared fixture files
- Each scenario must be independent and runnable in any order
- Do not duplicate scenarios already covered by existing tests
- Do not run seed bootstrap unless explicitly requested
