---
name: timelining
description: "Turn a list of estimated user stories into a dev timeline with dependency mapping, parallelization, role assignments, Gantt-style sprint planning, and a lean team composition capped at 4 members. Use when the user has scoped stories and wants scheduling, or says 'timeline this', 'schedule this', 'staff this', or 'how long will this take'. Do not use for initial scoping (use scoping instead)."
---

# Timelining

## When to Use This Skill

Use when the user has a list of user stories with dev time estimates and wants them turned into a project timeline. Also use when the user says "timeline this", "schedule this", "staff this", or "how long will this take".

This skill expects input from the `$scoping` skill or any equivalent list of user stories with time estimates.

## Process

### 1. Parse the User Stories

Read the input and extract for each user story:

| Field | Required |
|-------|----------|
| User Story Code | Yes — e.g., `F-001`, `NFI-002` |
| User Story | Yes — the story statement |
| Dev Time (no AI SDLC) | Yes |
| Dev Time (w/ AI SDLC) | Yes |

If both time estimates are provided, use the **midpoint** of the two as the working estimate unless the user specifies otherwise.

### 2. Map Dependencies

Analyze every user story and identify dependencies:

| Dependency type | Example |
|----------------|---------|
| **Hard dependency** | `F-003` cannot start until `NFI-001` (infra) is complete |
| **Soft dependency** | `F-005` is easier if `F-002` is done first, but can start in parallel with some rework risk |
| **No dependency** | `F-001` and `F-004` are fully independent |

Display the dependency map as a table.

### 3. Determine Timeline Aggressiveness

| Mode | Parallelization | Risk | Best for |
|------|----------------|------|----------|
| **Aggressive** | Maximize parallel work | Higher — rework risk if upstream changes | Tight deadlines, experienced team |
| **Balanced** | Parallelize independent stories | Moderate | Default — use this if not specified |
| **Conservative** | Minimize parallelization | Low | New teams, high-stakes projects |

Default to **Balanced** if the user does not specify.

### 4. Assign Roles

Map each user story to the most appropriate role based on the story's domain and complexity.

#### Role Definitions

| Role | Code | Specializations | Notes |
|------|------|-----------------|-------|
| **MLE** | MLE | GenAI, UI, API, Data | Machine Learning Engineers |
| **EC** | EC | UI, API, Data Engineering | Engineering Consultants |
| **EC (Infra)** | EC-I | EC skills + Infrastructure | ECs with infra capability |
| **AC** | AC | Data Modelling, Data Visualization | Analytics Consultants |
| **PM** | PM | Project Management | Always required |
| **TL** | TL | Senior EC, 50% dev / 50% client-facing | Tech Lead. 50% dev capacity only. |
| **DSC** | DSC | Product Management, requirements | Design & Strategy Consultant. 50% allocation unless specified. |

### 5. Compose the Team

Build a lean team. Target **4 members maximum** (excluding PM and DSC who are always present).

### 6. Build the Timeline

Using the dependency map, role assignments, and aggressiveness mode, produce a week-by-week timeline table.

### 7. Output Summary

```
TIMELINE SUMMARY
----------------
Team size:          X dev + PM + DSC
Timeline mode:      [Aggressive / Balanced / Conservative]
Estimate basis:     Midpoint of AI and non-AI estimates
Total duration:     X weeks
Critical path:      [List the chain of dependent stories that determines the minimum duration]

Dev cost summary:
  [Role 1]: X weeks at [level]
  [Role 2]: X weeks at [level]
  ...
  PM: X weeks
  DSC: X weeks at 50%
```

### 8. Present for Review

After generating the timeline:
1. Show the dependency map, team composition, week-by-week timeline, and summary
2. Highlight the **critical path**
3. Flag any stories that are **unassigned** or where role fit is uncertain
4. Flag any weeks where a team member is **idle**
5. Ask the user if they want to adjust team composition, aggressiveness, or story assignments

## Constraints

- Every user story from the input must appear in the timeline. Do not drop stories.
- Dev team cap is 4 members (excluding PM and DSC). If more are needed, flag it and ask the user.
- PM is always required — never produce a timeline without a PM.
- DSC is always required at 50% — never omit unless the user explicitly removes them.
- TL dev capacity is 50% — never assign a TL full-time dev work.
- L4 allocation is 10% — do not assign dev stories to L4 unless explicitly requested.
- Do not show idle team members for more than 1 consecutive week without flagging it as a staffing inefficiency.
