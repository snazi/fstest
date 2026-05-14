---
name: tech-proposal
description: "Scope projects into user stories, build dev timelines, produce deliverable proposals for client budgets. Use for pre-sales technical scoping."
---

# Tech Proposal

Scope a project into user stories, build a dev timeline, and optionally produce a proposal deck for a client deal.

## Purpose

Use `$tech-proposal` to turn deal documentation into a deliverable project plan. The skill gathers project requirements, researches the client, scopes work into estimated user stories, builds a staffed timeline, and can produce a PPTX proposal deck — everything a sales team needs to pitch a technically sound, budget-aligned project.

## Usage

- `$tech-proposal` — start a new proposal from scratch (asks for project docs and client name)
- `$tech-proposal <client name>` — start with a client name pre-filled; asks for project documentation
- `$tech-proposal <client name> <link or file path>` — start with both a client name and project documentation

## Process

### 1. Load Relevant Skills

Read the following skills and apply their guidelines throughout:

- `$scoping` — for turning requirements into categorized user stories with complexity and time estimates
- `$timelining` — for building dev timelines with dependencies, role assignments, and team composition
- `$context-research` — for searching TM internal context (Slack, Drive, Gmail, Atlassian) about the client and deal
- `$slide-deck-content` — for planning slide-by-slide content manifests
- `$slide-deck-layout` — for rendering the content manifest into a PPTX deck
- `$slide-deck-styling` — for visual polish (diagrams, layout fixes)

### 2. Gather Inputs

Before starting, ask the user to provide:

1. **Project documentation** — RFP, proposal brief, requirements doc, client slides, email thread, or any material describing what needs to be built. At minimum, a description of the project scope.
2. **Client profile / name** — the client company name so you can research internal context.
3. **Staffing profiles** (optional) — if the user has preferred team members or constraints on available roles, accept them here. Otherwise, propose a team from the standard role pool.

Do not proceed until at least items 1 and 2 are provided. If the user provides only a client name with no project docs, ask for the project scope before continuing.

### 3. Research the Client and Deal

Use `$context-research` to search across Slack, Google Drive, Gmail, and Atlassian for:

| What to find | Why it matters |
|-------------|---------------|
| **Previous TM engagements** with this client | Understand relationship history, past project sizes, and what worked/didn't |
| **Client industry and scale** | Informs complexity assumptions and compliance requirements |
| **Existing proposals or SOWs** for this deal | Avoid duplicating work; align with what was already promised |
| **Internal discussions** about the deal | Catch context from Slack threads, email chains, or Jira tickets |
| **Budget signals** | Any mentions of client budget, rate expectations, or pricing constraints |
| **Technical environment** | What stack the client uses, cloud provider, existing systems to integrate with |

Summarize findings in a brief **Client & Deal Context** section before scoping. If no internal context is found, state that explicitly and proceed with the project docs alone.

### 4. Scope the Project

Follow `$scoping` to turn the project requirements into categorized user stories:

1. Parse all requirements from the project documentation
2. Split into Functional and Non-Functional stories
3. Categorize by complexity (High / Medium / Low)
4. Estimate dev time with and without AI SDLC
5. Output the full set of tables

Present the scope to the user for review before proceeding. Ask:
- *"Does this scope look complete? Any stories to add, remove, or re-estimate?"*

### 5. Technical Validation

After scope approval, validate the scope using Dev Task Planning:

1. **Break down high-complexity stories** — For each High-complexity user story, produce a task-level breakdown (file-level tasks with change types and dependencies) to verify the time estimate is realistic.
2. **Validate dependencies** — Use the task breakdowns to confirm or correct the dependency map between stories. Flag hidden dependencies that only become visible at the task level.
3. **Flag technical risks** — Identify stories that depend on uncertain technical decisions (e.g., third-party API availability, unproven architecture patterns, missing infrastructure) and note them for the Risks & Assumptions section.
4. **Adjust estimates** — If the task breakdown reveals a story is significantly under- or over-estimated, recommend an adjusted estimate with justification.

Present any estimate adjustments or newly discovered risks to the user before proceeding to timelining.

### 6. Build the Timeline

After scope approval, follow `$timelining` to produce the dev timeline:

1. Map dependencies between stories
2. Assign roles from the standard TM role pool (or staffing profiles if provided)
3. Compose a lean team (cap at 4 dev members + PM + DSC)
4. Build the week-by-week timeline with the following bookend phases:
   - **Design phase (2 weeks)** — prepended before dev starts. Covers finalizing user stories, wireframes, infra configuration, and architecture decisions. All dev team members + DSC + PM participate.
   - **Development phase** — the core dev timeline from the timelining skill
   - **Hypercare phase (2 weeks)** — appended after dev ends. Covers rigorous bug fixes, performance tuning, and adjustments to support production deployment. Full dev team participates.
5. Calculate the critical path and total duration (Design + Dev + Hypercare)

If staffing profiles were provided in step 2, use those team members as the starting point. Otherwise, propose the optimal team composition.

### 7. Produce the Proposal Summary

After the timeline is built, produce a proposal-ready summary combining all outputs:

```
PROPOSAL SUMMARY
================
Client:             [Client Name]
Project:            [Project Title]
Deal context:       [1-2 sentence summary of client relationship and deal background]

SCOPE
-----
Functional stories:     X (H: _, M: _, L: _)
Non-Functional stories: X (Infra: _, Data: _, Gov: _, App: _)
Total stories:          X

TIMELINE
--------
Team:               [Role list with levels]
Duration:           X weeks (Design: 2w + Dev: Xw + Hypercare: 2w)
Mode:               [Aggressive / Balanced / Conservative]
Estimate basis:     [Midpoint / AI-only / Non-AI / Custom]
Critical path:      [Story chain]

COST DRIVERS
------------
[List the biggest cost factors: team size, duration, complexity, compliance, etc.]

RISKS & ASSUMPTIONS
--------------------
[List key assumptions that affect the estimate and risks that could change scope]
```

### 8. Present for Review

After generating the proposal summary:
1. Show the full output: client context, scope tables, timeline, and proposal summary
2. Flag any areas where the scope is uncertain or could grow
3. Highlight cost optimization opportunities (e.g., "dropping NFG-002 saves 1 week and removes the need for an L3")
4. Ask the user if they want to adjust the scope, team, timeline mode, or estimates before finalizing
5. Ask if the user wants a proposal deck — if yes, proceed to step 9

### 9. Create the Proposal Deck (optional)

If the user requests a proposal deck, use the slide-deck skills to produce a PPTX presentation. The deck has three major sections.

#### 9a. Plan the Deck Content

Follow `$slide-deck-content` to build a content manifest. The deck structure must follow this order:

**Section 1 — TM Introduction (3-5 slides)**

Source: reference the TM Company Deck at `https://docs.google.com/presentation/d/1FehCGabvxRUksAWtFiGGWnFl21OE512EJMfH9F37OsY/edit` (Slides 3-14) for structure and talking points. Adapt the content — do not include actual employee names or client-specific case study details.

- **Title slide** — project name, client name, date, TM logo
- **About TM** — what TM does, core capabilities (data engineering, AI/ML, product development)
- **Track record** — anonymized highlights of past engagements at scale (reference enterprise-scale deployments without naming specific clients)
- **Why TM** — differentiators relevant to this deal (AI-native SDLC, lean teams, rapid delivery)

**Section 2 — Proposed Solution (5-8 slides)**

- **Client context** — relationship history and deal background (from step 3)
- **Requirements analysis** — the end-state solution described through the scoped user stories. Present functional and non-functional requirements as a clear picture of what the client gets when the project is done.
- **Infrastructure & scalability** — reference TM's customizable Azure/AWS infrastructure, deployed to scale for enterprise clients with 1000+ concurrent users. Source: `https://docs.google.com/presentation/d/1OlxM_chnHQ9-DHwodU5gKEgFeNseM4qnkDe_aGnlp68/edit` (Slide 26) for architecture reference points. Adapt to the client's cloud environment.
- **Scope overview** — story counts by category and complexity, with a visual breakdown chart
- **Scope detail** — functional and non-functional story tables with dual estimates (AI / non-AI)

**Section 3 — Delivery Plan (5-8 slides)**

- **Team composition** — proposed roles, levels, and allocations in a visual layout
- **Development approach** — how the team will build it, using the task breakdown per staff member from the technical validation (step 5)
- **Staffing + Timeline** — the full project timeline as a Gantt chart showing three phases:
  - **Design (2 weeks)** — finalizing user stories, wireframes, infra configuration
  - **Development (X weeks)** — the week-by-week task breakdown with role assignments and milestones
  - **Hypercare (2 weeks)** — bug fixes, performance tuning, production deployment support
- **Critical path** — the dependency chain that determines minimum duration, shown visually
- **Cost drivers** — the biggest factors affecting project cost
- **Risks & assumptions** — key assumptions and scope risks

**Closing (1-2 slides)**

- **Next steps** — what the client needs to decide or provide to proceed
- **Contact** — TM point of contact for the deal

**Visual requirements:**
- Include a Gantt chart for the Staffing + Timeline slide showing Design -> Dev -> Hypercare with per-person task assignments
- Include bar or pie charts for scope breakdown (functional vs non-functional, complexity distribution)
- Include a visual dependency graph for the critical path where applicable
- Use data visualizations over tables whenever the data supports it

#### 9b. Render the Deck

Follow `$slide-deck-layout` to render the content manifest into a PPTX file.

#### 9c. Polish

Follow `$slide-deck-styling` to audit and fix typography, alignment, chart styling, and visual consistency.

#### 9d. Deliver

Share the PPTX file path with the user. Offer to upload to Google Drive via `$gws-drive` if requested.

## Constraints

- Do not fabricate client context. If no internal data is found, say so.
- Do not skip the scope review step (step 4) or technical validation (step 5) — always get user confirmation before building the timeline.
- Do not exceed the 4-member dev team cap without flagging it and getting user approval.
- PM and DSC are always included in the proposal — never omit them.
- Always present both AI and non-AI estimates in the scope tables, even if the timeline uses the midpoint.
- The proposal must be deliverable — do not promise timelines that require unrealistic parallelization or understaffing.
- Do not generate the proposal deck unless the user explicitly requests it.
