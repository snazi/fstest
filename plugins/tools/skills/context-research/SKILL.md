---
name: context-research
description: "Search across available tool integrations and connectors (Slack, Google Drive, Gmail, Atlassian, GitHub, web, local codebase) for information relevant to a query, then produce a structured research report with sourced findings. Use when the user asks to research a topic, gather context from multiple sources, find information across systems, or answer a question requiring multi-source search. Covers search strategy planning, parallel source querying, deduplication, and structured report generation. This skill does NOT perform actions or modifications — it is read-only research."
---

# Context Research

## When to Use This Skill

Load this skill when the user asks you to research a topic, gather context, find information across systems, or answer a question that may require searching multiple sources (Slack, Google Drive, Gmail, Atlassian, GitHub, the web, or other connected services).

## Process

### 1. Parse the Search Query

Extract:
- **Primary query** — the core question or topic
- **Scope constraints** — any time range, team, project, or system the user specified
- **Depth** — whether the user wants a quick check or an exhaustive search

If the query is ambiguous, ask one clarifying question before proceeding. Do not guess scope.

### 2. Plan the Search Strategy

Identify which sources are relevant to the query. Evaluate each source below and skip any that are clearly irrelevant to the topic.

| Source | When to search | How to search |
|--------|---------------|--------------|
| **Slack** | Conversations, decisions, announcements, team context | `slack_search_messages` for keyword matches; `slack_get_channel_history` for recent context in known channels |
| **Google Drive** | Documents, spreadsheets, presentations, shared files | `Google_Drive__search_files` to find files by name or content; `Google_Drive__read_file_content` to extract details |
| **Gmail** | Email threads, external communications, approvals | `Gmail` connector — search by subject, sender, or keyword |
| **Atlassian** | Jira tickets, Confluence pages, project tracking | `atlassian` MCP connector — search issues, pages, and comments |
| **GitHub** | Code, PRs, issues, discussions | `gh` CLI — `gh search issues`, `gh search prs`, `gh search code`; also `git log --grep` for commit history |
| **Web** | Public documentation, APIs, external references | `WebSearch` for broad queries; `WebFetch` for specific URLs |
| **Local codebase** | Code, configs, documentation files | `grep`, `find`, file reads within the working directory |

Announce the search plan to the user before executing: which sources you will search and why.

### 3. Execute Searches

Search each planned source. For each source:

1. **Authenticate if needed** — some connectors require OAuth. If a connector is not yet authenticated, prompt the user to complete the auth flow before proceeding.
2. **Run the search** — use the appropriate tool or MCP connector.
3. **Extract relevant findings** — read through results and pull out information directly related to the query. Discard noise.
4. **Record metadata** — for each finding, capture:
   - The source system (e.g., "Slack #engineering", "Google Drive", "Jira PROJ-123")
   - The date of the information (message timestamp, document modified date, commit date)
   - A reference link or location (URL, file path, channel + timestamp)

Work through sources in parallel where possible. Do not search sources that require authentication if the user has not connected them — note the skipped source in the report instead.

### 4. Synthesize Findings

After all searches complete:

1. **Deduplicate** — if the same information appears in multiple sources, keep the most authoritative or most recent version
2. **Assess relevance** — rank findings by how directly they answer the query
3. **Identify gaps** — note if key aspects of the query could not be answered from available sources
4. **Formulate the response** — write a direct answer to the query based on the collected evidence

### 5. Produce the Report

Output the report in exactly this format:

```markdown
# Search Query
[The original query, verbatim]

# Response to Query
[A direct, comprehensive answer to the query. Synthesize findings into a coherent response. Cite sources inline where claims are made (e.g., "per Slack #engineering on 2026-04-15"). If the query cannot be fully answered, state what is known and what remains unclear.]

# Summary of Information Findings
[A 2-4 sentence overview of what was found: how many sources were searched, how many returned relevant results, and the overall confidence level (high/medium/low) in the response.]

# Sources

## Source 1
Summary: [What this source contributed to the answer]
Date of Information: [YYYY-MM-DD or date range]
Reference Link: [URL, file path, or location identifier]

## Source 2
Summary: [What this source contributed to the answer]
Date of Information: [YYYY-MM-DD or date range]
Reference Link: [URL, file path, or location identifier]

...
```

If a planned source was skipped (not authenticated, not relevant, returned no results), include it as a source entry with `Summary: No results found` or `Summary: Skipped — [reason]`.

## Constraints

- Do not fabricate information. Every claim in the response must trace to a source listed in the report.
- Do not search sources the user explicitly excluded.
- If no sources return relevant results, say so clearly in the response rather than speculating.
- Respect rate limits on all APIs — do not flood any single connector with parallel requests.
- Do not store or cache sensitive information found during searches (credentials, PII, secrets). If encountered, omit from the report and note that sensitive content was redacted.
