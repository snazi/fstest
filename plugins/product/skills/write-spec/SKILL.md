---
name: write-spec
description: "Write a feature specification or product requirements document (PRD) from a problem statement, feature idea, or vague request. Covers goals, non-goals, user stories, acceptance criteria, success metrics, MoSCoW prioritization, and scope management. Use when turning a vague idea into a structured document, scoping a feature, defining success metrics, or breaking a big ask into a phased spec. Do not use for technical architecture docs or implementation plans."
---

# Write Spec

Write a feature specification or product requirements document (PRD).

## Workflow

### 1. Understand the Feature

Ask the user what they want to spec. Accept any of:
- A feature name ("SSO support")
- A problem statement ("Enterprise customers keep asking for centralized auth")
- A user request ("Users want to export their data as CSV")
- A vague idea ("We should do something about onboarding drop-off")

### 2. Gather Context

Ask the user for the following. Be conversational — do not dump all questions at once:

- **User problem**: What problem does this solve? Who experiences it?
- **Target users**: Which user segment(s) does this serve?
- **Success metrics**: How will we know this worked?
- **Constraints**: Technical constraints, timeline, regulatory requirements, dependencies
- **Prior art**: Has this been attempted before? Are there existing solutions?

### 3. Pull Context from Connected Tools

If project tracker, knowledge base, or design tools are connected, search for related content. If not connected, work entirely from what the user provides.

### 4. Generate the PRD

Produce a structured PRD with these sections:

- **Problem Statement**: The user problem, who is affected, and impact of not solving it (2-3 sentences)
- **Goals**: 3-5 specific, measurable outcomes tied to user or business metrics
- **Non-Goals**: 3-5 things explicitly out of scope, with brief rationale for each
- **User Stories**: Standard format ("As a [user type], I want [capability] so that [benefit]"), grouped by persona
- **Requirements**: Categorized as Must-Have (P0), Nice-to-Have (P1), and Future Considerations (P2), each with acceptance criteria
- **Success Metrics**: Leading indicators (change quickly) and lagging indicators (change over time), with specific targets
- **Open Questions**: Unresolved questions tagged with who needs to answer (engineering, design, legal, data)
- **Timeline Considerations**: Hard deadlines, dependencies, and phasing

### 5. Review and Iterate

After generating the PRD:
- Ask the user if any sections need adjustment
- Offer to expand on specific sections
- Offer to create follow-up artifacts (design brief, engineering ticket breakdown, stakeholder pitch)

## PRD Structure

### Problem Statement
- Describe the user problem in 2-3 sentences
- Who experiences this problem and how often
- What is the cost of not solving it (user pain, business impact, competitive risk)

### Goals
- 3-5 specific, measurable outcomes
- Distinguish between user goals and business goals
- Goals should be outcomes, not outputs

### Non-Goals
- 3-5 things this feature explicitly will NOT do
- For each, briefly explain why it is out of scope
- Non-goals prevent scope creep during implementation

### User Stories
Write in standard format: "As a [user type], I want [capability] so that [benefit]"

Good user stories are:
- **Independent**: Can be developed and delivered on their own
- **Negotiable**: Details can be discussed
- **Valuable**: Delivers value to the user
- **Estimable**: The team can roughly estimate the effort
- **Small**: Can be completed in one sprint
- **Testable**: There is a clear way to verify it works

### Requirements

**Must-Have (P0)**: Non-negotiable for launch.
**Nice-to-Have (P1)**: Important but not critical. Often fast follow-ups.
**Future Considerations (P2)**: Out of scope for v1 but design should support them.

### Acceptance Criteria

Write in Given/When/Then format or as a checklist:
- Given [precondition]
- When [action]
- Then [expected outcome]

### Success Metrics

**Leading Indicators**: adoption rate, activation rate, task completion rate, time to complete, error rate
**Lagging Indicators**: retention impact, revenue impact, NPS change, support ticket reduction

### Open Questions
- Tag each with who should answer (engineering, design, legal, data)
- Distinguish blocking from non-blocking questions

## Scope Management

### Preventing Scope Creep
- Write explicit non-goals in every spec
- Require that any scope addition comes with a scope removal or timeline extension
- Separate "v1" from "v2" clearly
- Time-box investigations

## Tips

- Be opinionated about scope. Tight, well-defined is better than expansive and vague.
- If the idea is too big, suggest breaking it into phases.
- Success metrics should be specific and measurable.
- Non-goals are as important as goals.
- Open questions should be genuinely open.
