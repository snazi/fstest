---
name: compare-ai-tools
description: "Research, compare, and document SaaS tools. Produces comparison matrices, research reports, and MOPs."
---

# Compare AI Tools

Research, compare, and document SaaS tools — producing comparison matrices, research reports, slide decks, and MOPs.

## Purpose

Use `$compare-ai-tools` to generate a structured comparison of SaaS tools for presenting to Thinking Machines clients, or to produce research reports and MOPs for specific tools. The skill researches each tool's security, pricing, integrations, governance, and top features — plus TM-specific client and internal usage — then produces a polished deliverable.

## Usage

- `$compare-ai-tools` — compare the default set of tools (ChatGPT, Claude, Manus, MS Copilot 365)
- `$compare-ai-tools <additional context>` — e.g., `$compare-ai-tools focus on enterprise data governance for a banking client`
- `$compare-ai-tools mop <tool> <task>` — produce a MOP for a specific task in a specific SaaS tool

---

## SaaS Explanation / Comparison

Research, explain, and compare one or more SaaS tools. Produce a structured report covering security, pricing, integrations, governance, and TM-specific usage.

### 1. Load Relevant Skills

Read the following skills and apply their guidelines throughout:

- `$context-research` — for searching TM internal context (Slack, Drive, Gmail, Atlassian)
- `$gws-docs` — for Google Docs output
- `$gws-drive` — for file management
- `$slide-deck-content` — for structuring slide content
- `$slide-deck-layout` — for creating slide decks as PPTX
- `$slide-deck-styling` — for visual polish on slides

### 2. Identify the Tools

When invoked as `$compare-ai-tools` (without `mop`), the tools to compare are: **ChatGPT**, **Claude**, **Manus**, and **MS Copilot 365**. Do not ask the user to re-specify them.

If additional context is provided (e.g., a specific client vertical or evaluation priority), use it to weight the comparison dimensions accordingly.

### 3. Research the Web

For each tool, search the web and gather the following:

1. **Security Compliance** — certifications (SOC 2, ISO 27001, HIPAA, GDPR), audit reports, security whitepapers, incident history
2. **Data Protection & Privacy** — encryption at rest and in transit, data residency options, DPA availability, sub-processor transparency, right to deletion
3. **Capabilities per Pricing Plan** — build a table mapping features to plan tiers (free, pro, enterprise, etc.) with pricing where available
4. **Supported Integrations** — out-of-the-box integrations, API availability, webhook support, marketplace/app ecosystem
5. **Data Governance Features** — audit logs, access controls, RBAC, data retention policies, export capabilities, compliance dashboards
6. **Top 5 Biggest-Impact Features** — the features that most differentiate this tool from alternatives, with a one-sentence explanation of why each matters

### 4. Research TM Internal Context

Use `$context-research` to search across Slack, Google Drive, Gmail, and Atlassian for TM-specific information on each tool:

- **Client usage** — which existing clients have used this tool, what they used it for, and the impact it had on their work
- **Internal usage** — how TM has used the tool internally and the impact on our workflows
- **Additional context** — any evaluations, proposals, complaints, or recommendations from the team

If no internal context is found for a tool, state that explicitly rather than omitting the section.

### 5. Research Community Sentiment

For each tool, search the web for community feedback from the **latest quarter** (last 3 months). Focus on:

- **Reddit threads** — search `site:reddit.com` for the tool name + common subreddits (r/ChatGPT, r/ClaudeAI, r/MicrosoftCopilot, r/artificial, r/SaaS, r/devops, etc.)
- **Community forums** — official community boards, Discourse forums, GitHub Discussions
- **Review sites** — G2, Capterra, TrustRadius recent reviews
- **Social media** — X/Twitter threads, LinkedIn posts from power users or analysts
- **Hacker News** — search for recent discussions

For each tool, summarize:

1. **Overall sentiment** — positive, mixed, or negative, with a one-sentence summary
2. **Top praised features** — what users love most right now
3. **Top complaints** — recurring frustrations, bugs, or missing features
4. **Recent changes driving sentiment** — pricing changes, feature launches, outages, or policy shifts that triggered community reactions
5. **Trend direction** — is sentiment improving, declining, or stable compared to the previous quarter?

### 6. Produce the Output

This command always produces a **PPTX slide deck**. Do not ask for output format.

Structure the comparison output with:

1. Overview — what is being compared and why
2. Side-by-side comparison matrix (one row per evaluation dimension, one column per tool)
3. Security & Compliance comparison
4. Pricing comparison (table)
5. Integration overlap and gaps
6. Data Governance comparison
7. Feature highlights — top differentiators per tool
8. TM Experience — which tools TM and clients have used, with outcomes
9. Community Sentiment — side-by-side sentiment summary per tool with trend direction
10. Recommendation — which tool wins for which use case, with trade-offs

Follow the content -> layout -> styling pipeline:
1. Use `$slide-deck-content` to build the content manifest
2. Use `$slide-deck-layout` to render the PPTX
3. Use `$slide-deck-styling` to polish layout, typography, and visual consistency

### 7. Present to User

Share the PPTX file path. Walk the user through the key findings and ask if any section needs deeper investigation.

After the user is satisfied with the content, ask: *"Would you like me to upload this to Google Slides as well?"* If yes, upload the PPTX via `$gws-drive` — it auto-converts to Google Slides format.

---

## SaaS MOP

Produce a Method of Procedure (MOP) document for performing a specific task in a SaaS tool.

### 1. Load Relevant Skills

Read the following skills and apply their guidelines throughout:

- `$mop-documentation` — for MOP structure and conventions
- `$gws-docs` — for Google Docs output
- `$gws-drive` — for file management

### 2. Understand the Task

Ask the user to confirm:

- Which **SaaS tool** the MOP is for
- What **specific task** should be documented (e.g., "set up SSO in Databricks", "configure a Slack workflow", "create a Jira automation rule")
- The **audience** — is this for TM engineers, client admins, or end users?

### 3. Research the Procedure

Search the web for the tool's official documentation on the task. Cross-reference with:

- The tool's admin/settings UI flow
- Known prerequisites (permissions, plan tier, API keys)
- Common failure modes and rollback steps

If the tool has recently changed its UI or process, note the version or date of the documentation used.

### 4. Write the MOP

Follow `$mop-documentation` to produce the MOP. Include:

- **Purpose** — what the MOP accomplishes
- **Prerequisites** — required access, permissions, plan tier, and dependencies
- **Step-by-step procedure** — numbered steps with expected outcomes at each stage
- **Verification** — how to confirm the task completed successfully
- **Rollback** — how to undo the changes if something goes wrong
- **Troubleshooting** — common issues and their resolutions

### 5. Present to User

Create the MOP as a Google Doc. Share the link and confirm it covers the task completely.

## Constraints

- Do not ask the user which tools to compare — the four tools are fixed by this skill.
- Do not ask for output format — always produce a PPTX slide deck. Offer Google Slides upload after.
- Do not skip the TM internal context research step — client and internal usage data is required.
- All pricing, feature, and compliance data must reflect the latest publicly available information. Flag any data points that could not be verified as current.
- Follow the comparison output structure defined above (overview, matrix, security, pricing, integrations, governance, features, TM experience, recommendation).
- Ensure the comparison uses the most current publicly available information as of today's date.
