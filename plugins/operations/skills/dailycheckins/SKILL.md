---
name: dailycheckins
description: "Generate daily check-in reports, standup summaries, and activity logs by gathering data from Google Calendar, Slack, GitHub, and local git repositories. Use for daily check-in generation, standup preparation, time logging, status update creation, and activity summary compilation. Scope: activity summarization and check-in formatting only -- not project planning or task management."
---

# Daily Check-in

## When to Use This Skill

Use when the user asks to generate their daily check-in, standup summary, or time log for a specific date (or date range). Also use when the user says "check in", "what did I do today/yesterday", or asks for their activity summary in check-in format.

## Process

### 1. Determine the Target Date(s)

Identify which date(s) the user wants a check-in for. If not specified, default to today. Accept:
- A single date: "Monday", "yesterday", "2026-04-07"
- A date range: "last week", "April 7-11", "monday to friday this week"

Convert all relative dates to absolute `YYYY-MM-DD` format before proceeding.

#### Multi-Day Handling (up to 7 days)

When the input resolves to more than one date:

1. **Enumerate** every calendar date in the range. Exclude weekends unless the user explicitly includes them (e.g., "including Saturday").
2. **Cap at 7 days.** If the range exceeds 7 dates, reject with: *"Daily check-in supports up to 7 days per invocation. Please narrow the range."*
3. **Process each date independently** through Steps 2-6 below. Data gathering (Step 2) may be batched across the full range for efficiency (e.g., one calendar API call covering the whole period), but formatting, validation, and review (Steps 5-7) must produce a separate check-in block per date.
4. **File naming:** single date -> `YYYY-MM-DD-checkin.md`; multi-day -> `YYYY-MM-DD_to_YYYY-MM-DD-checkin.md` (first date to last date).

### 2. Gather Activity from Sources

Load `$context-research` and follow its process to search the following sources for the target date(s). All three primary sources must be checked for every check-in.

#### Primary Sources (always check)

| Source | What to look for | How to search |
|--------|-----------------|---------------|
| **Google Calendar** | Meetings, syncs, standups, presentations, 1:1s — any calendar event the user attended | Use `$gws-calendar` for the target date; extract event title, duration, and attendees |
| **Slack** | Messages sent by the user, channel activity, threads participated in | Use `$slack` with `from:@user` and date filter; also check channels the user is active in |
| **GitHub** | PRs opened/reviewed/merged, commits pushed, issues commented on | Use `gh` CLI: `gh search prs --author=@me`, `gh search issues --involves=@me`, `git log --author` with date filter |
| **Local Git** | Commits authored by the user in local repositories | Scan repositories in the current working directory and common project directories. See **Local Git Details** below |

##### Local Git Details

When the user is an engineer (or has local repositories), scan for git activity to capture coding work that may not appear in calendar or Slack.

**How to gather:**

1. **Find repositories to scan.** Start with the current working directory. If it is a git repo, scan it. Also scan immediate subdirectories that are git repos (one level deep). If the user specifies additional paths, scan those too.

2. **Query commits for the target date(s).** For each repository, run:
   ```bash
   git -C <repo-path> log --author="<user-email>" --after="<YYYY-MM-DD>T00:00:00" --before="<YYYY-MM-DD>T23:59:59" --format="%H %s" --no-merges
   ```
   Use the user's configured git email (`git config user.email`) if not explicitly provided.

3. **Query branches with recent activity.** For commits that are on feature branches, note the branch name — it often maps to a project or ticket:
   ```bash
   git -C <repo-path> log --author="<user-email>" --after="<YYYY-MM-DD>T00:00:00" --before="<YYYY-MM-DD>T23:59:59" --format="%H" --no-merges | while read hash; do git -C <repo-path> branch --contains "$hash" 2>/dev/null; done | sort -u
   ```

4. **Summarize per repository.** Group commits by repository and produce a one-line summary per repo (e.g., "3 commits on feature/auth-rbac — added role validation and tests"). If a single repo has many commits across unrelated branches, split into separate line items.

5. **Estimate time.** See Step 4 for git-specific estimation rules.

**Mapping to channels:** Match the repository name or branch to a Slack project channel. Common patterns:
- Repo name matches a project channel (e.g., repo `coach-ai` -> `#coach-ai` or similar)
- Branch prefix matches a project (e.g., `feature/temasek-trust-*` -> `#temasek-trust-*`)
- If no channel match, use `#engineering-office` as the default for general engineering work

#### Secondary Sources (check if relevant)

| Source | When to check |
|--------|--------------|
| **Google Drive** | If the user mentions document work or presentations |
| **Atlassian/Jira** | If the user works with Jira tickets |

For each activity found, extract:
- **Duration** — from calendar event duration, or estimate from context (e.g., a 30-minute standup = 0.5 hrs)
- **Project channel** — the Slack channel most closely associated with the activity
- **Description** — a concise summary of the activity

### 3. Map Activities to Slack Project Channels

Every check-in line item must reference a Slack project channel (`#channel-name`) unless the activity is not tied to any project.

To find the correct channel:
1. If the activity originated from Slack, use the channel it was posted in
2. If the activity is a calendar event, look for a matching Slack channel by project name or attendee team
3. If the activity is a GitHub PR/commit, match the repository to a Slack project channel
4. If the activity is from local git, match the repository name or branch name to a Slack project channel (see Local Git Details above)
5. If no channel match is found, use a general channel like `#engineering-office` or omit the channel prefix

### 4. Estimate Time in 0.5-Hour Increments

Round all durations to the nearest 0.5-hour increment:
- Calendar events: use the actual event duration, rounded
- Slack discussions: estimate based on message volume and thread depth (light thread = 0.25 hrs, extended discussion = 0.5-1 hr)
- GitHub work: estimate from commit activity and PR review depth (quick review = 0.25 hrs, substantial PR = 1-2 hrs)
- Local git commits: estimate from commit count, diff size, and complexity:
  - 1-2 small commits (config, typo, docs) = 0.25-0.5 hrs
  - 3-5 focused commits in one area = 1-2 hrs
  - 6+ commits or large diffs (new features, refactors) = 2-4 hrs
  - If `git diff --stat` shows >500 lines changed across a day, estimate at least 2 hrs
  - Do not double-count: if a commit also appears as a GitHub PR, count it once under the PR line item, not separately as local git work
- Heads-down work: if gaps exist between meetings, infer focused work time and label it (e.g., "heads down", "deep work"). Local git commits during these gaps should replace generic "heads down" entries with specific descriptions of what was built

The total hours for a standard work day should approximate 8 hours. If the total is significantly less, note gaps that may need the user's input.

### 5. Format the Check-in

Output the check-in in exactly this format:

```
checkin YYYY-MM-DD
- [hours] hrs #[slack-channel] [activity description]
- [hours] hrs #[slack-channel] [activity description]
...
```

Rules:
- Hours are in 0.5-hour increments (0.25, 0.5, 1, 1.5, 2, etc.)
- Channel names use the `#channel-name` format
- Activity descriptions are concise — one line per activity
- Group related activities (e.g., multiple short Slack conversations in the same channel can be one line)
- Order chronologically by time of day
- If generating for multiple dates, output one check-in block per date, separated by a blank line
- After the last check-in block, append a summary line: `total: X hrs across Y days (avg Z hrs/day)`

### 6. Validate the Check-in

Run the following checks on every generated check-in block before presenting it to the user.

#### 6a. Format Validation

Each check-in block must pass all of these rules. If a line fails, fix it automatically.

| Rule | Valid | Invalid |
|------|-------|---------|
| First line is `checkin YYYY-MM-DD` | `checkin 2026-04-07` | `Checkin 2026-04-07`, `checkin April 7` |
| Every activity line starts with `- ` | `- 0.5 hrs ...` | `0.5 hrs ...`, `* 0.5 hrs ...` |
| Hours value is a multiple of 0.25 | `0.25`, `0.5`, `1`, `1.75` | `0.3`, `0.6`, `1.1` |
| Hours value is followed by ` hrs ` | `- 1 hrs #channel` | `- 1hrs #channel`, `- 1 hr #channel` |
| No trailing whitespace on any line | `- 1 hrs #channel desc` | `- 1 hrs #channel desc   ` |
| No blank lines between activity lines within one day's block | consecutive lines | blank lines between entries |

If a line fails format validation, correct it silently (e.g., round `0.3` to `0.25`, fix `hrs` spelling, trim whitespace).

#### 6b. Slack Channel Verification

For every `#channel-name` referenced in the check-in, verify it exists in the user's Slack workspace.

1. Fetch the list of channels the user belongs to using `$slack` (or equivalent).
2. For each `#channel-name` in the check-in:
   - **Exact match found:** keep as-is.
   - **No exact match but a close match exists** (e.g., off by a typo, missing a prefix, or a hyphen difference — use Levenshtein distance <= 3 or substring containment as the threshold): automatically replace with the correct channel name. Mark the correction with a `[corrected]` flag in the review step.
   - **No match and no close match:** retain the channel name as-is. Mark it with an `[unverified]` flag in the review step.
   - **No channel prefix** (activity not tied to a project): leave as-is, no verification needed.

Do not remove or drop a channel reference that fails verification — always keep the original or corrected name so the user can review.

### 7. Present for Review

After generating and validating the check-in:
1. Show the formatted check-in to the user (all days if multi-day)
2. If any channels were auto-corrected in step 6b, list them: `#old-name -> #corrected-name [corrected]`
3. If any channels could not be verified, list them: `#channel-name [unverified]`
4. Flag any activities where you were uncertain about the duration or description
5. Note any gaps in the day that could not be accounted for
6. For multi-day check-ins, show the total/average summary and flag any day with < 4 hrs or > 12 hrs
7. Ask the user if they want to adjust anything before finalizing

## Example Output

```
checkin 2026-04-07
- 0.25 hrs #temasek-trust-data-platform-migration Meeting - Daily Standup
- 0.25 hrs #engineering-office Infrastructure: Daily Standup
- 1.25 hrs #temasek-trust-data-platform-migration [Temasek Trust] Design and Technical Presentation
- 1 hrs #bizdev-fgi FGI Alignment on initial proposal
- 0.5 hrs #management Levy / Pats: 1-1
- 2 hrs #genai-product-managers Bryce / Kayle
- 1.75 hrs nst-e2e AI SDLC KT + prep
- 1 hrs #engineering-office heads down
```

## Constraints

- Do not fabricate activities. Every line item must trace back to a real calendar event, Slack message, GitHub activity, or local git commit.
- If a source is not authenticated or returns no results, note it and proceed with available sources.
- Do not include activities from other users — only the authenticated user's activities.
- Round hours to 0.5 increments — never use arbitrary decimal values.
- If the total hours for any single day seem unreasonably low (< 4 hrs) or high (> 12 hrs), flag this to the user.
- Maximum 7 days per invocation. Reject ranges longer than 7 days.
