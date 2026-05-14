---
name: copywriting-standards
description: "Standardize user-facing copy, UI microcopy, terminology, tone of voice, and agent persona voice across UI, prompts, and docs. Use when writing or reviewing product text, prompt instructions, labels, error messages, empty states, loading states, and documentation copy. Do not use for code documentation or API reference generation."
---

# Copywriting Standards

Keep copy clear, consistent, and aligned with the project's voice across UI, prompts, and docs.

## Voice Principles

- **Clear first**: plain language over jargon.
- **Concise**: short sentences, minimal filler.
- **Actionable**: tell the user what happened and what to do next.
- **Neutral and respectful**: avoid blame and alarmist language.
- **Consistent**: one preferred term per concept.

## Terminology Rules

- Use existing project terms already present in product surfaces.
- Avoid introducing new synonyms for existing concepts.
- Keep labels, menu names, and workflow terms consistent across UI and docs.
- If two terms conflict, flag as a copy finding and recommend one canonical term.

**Normalization pattern:**
1. Pick one canonical term.
2. Replace alternatives in touched files.
3. Add a reviewer note if untouched files still use old terms.

## UI Message Patterns

### Success
- State the completed action directly.
- Optional second sentence: what happens next.
- Avoid unnecessary adverbs like "successfully".
- Avoid: *"Your request has been successfully completed."*
- Prefer: *"Request complete."*

### Errors
- Explain what failed in plain language.
- Include next action (retry, check input, contact support).
- Do not expose sensitive internals, stack traces, or secret values.
- Avoid: *"An unknown error occurred."*
- Prefer: *"Something went wrong while saving. Try again."*

### Empty States
- Explain why the state is empty.
- Suggest one clear next action.
- Avoid: *"No data."*
- Prefer: *"No conversations yet. Start a new conversation to see results here."*

### Loading States
- Use short, stable labels.
- Avoid frequent text changes that cause UI jitter.

## Prompt and Agent Persona Standards

- Keep role, tone, and boundaries explicit.
- Prefer imperative, concrete instructions over vague phrasing.
- Avoid contradictory guidance within the same prompt.
- Keep persona consistent across prompts, UI helper text, and docs.
- If persona drift exists, recommend alignment to the existing project baseline.

## Review Workflow

1. Read changed text in UI, prompts, and docs.
2. Check clarity, brevity, actionability, and term consistency.
3. Check persona consistency across touched surfaces.
4. Flag ambiguous or conflicting language.
5. Suggest concrete rewrite options when useful.

## Severity Heuristics

- `R1`: wording causes critical legal/compliance/security risk or severe user harm
- `R2`: wording likely causes workflow errors, major confusion, or significant trust/UX issues
- `R3`: style, tone, terminology, and clarity improvements without immediate critical risk
- `R4`: optional polish and consistency cleanup

## Output Expectations

Keep recommendations:
- Specific to the changed text
- Minimal in scope (do not rewrite unrelated copy)
- Consistent with the shared review schema in $code-review

## Related Skills

- $code-review
