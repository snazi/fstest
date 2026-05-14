---
name: slide-deck-content
description: "Turn a topic, brief, or outline into a fully specified slide-by-slide Content Manifest for presentation decks. Use for slide deck content planning, presentation content creation, Google Slides content generation, narrative structure, and slide type selection. Includes chart specs, image prompts, and speaker notes. Scope: content planning only -- does not render files or define visual styling."
---

# Slide Deck Content

## When to Use This Skill

Load this skill whenever you are asked to plan, build, or improve a presentation deck. This skill handles **what goes on each slide and why** — it does not render files, define brand tokens, or write full speaker scripts.

## Process

### 1. Load the Layout Skill

Read `$slide-deck-layout`. Understand the deck structure conventions — slide frame size, text styles, and layout patterns — before planning any content. The Content Manifest you produce must use slide types that the layout skill can render.

### 2. Research the Topic (if needed)

If the input is a topic, brief, or outline that would benefit from supporting data, context, or evidence, read `$context-research` and run a targeted search before planning slides. Use the research report to:

- Source statistics and data points for hook and evidence slides
- Identify recent developments or context the audience may expect
- Find internal references (Slack threads, documents, Jira tickets) that ground the deck in real data

Skip this step if the user provides a complete outline, existing document, or rework request with all content already supplied.

### 3. Parse the Input

Identify the input type and extract what you need:

| Input type | What to extract |
|------------|----------------|
| Topic only | Infer audience, goal, and desired slide count (ask if ambiguous) |
| Rough outline | Treat each outline item as a candidate slide; reorder if narrative logic requires it |
| Bullet list | Group related bullets into slides; discard or merge redundant ones |
| Existing document | Identify the key argument or insight; build the deck around that, not the doc structure |
| Rework request | Read the existing plan first, identify what is weak (too text-heavy, no hook, missing CTA), then fix those slides specifically |

If the topic is ambiguous or the audience is unknown, ask one focused question before continuing. Do not guess at audience and proceed — it shapes every slide type decision.

### 4. Plan Narrative Structure

Every deck must follow this arc. Map your slide plan to it before selecting slide types:

1. **Hook** — an unexpected stat, question, or provocative claim. Never an agenda slide.
2. **Context** — why this matters, what the problem or opportunity is
3. **Insight** — the key finding, recommendation, or argument
4. **Evidence** — data, case studies, or proof points supporting the insight
5. **Action** — what the audience should do, decide, or believe after this deck
6. **Close** — a single memorable takeaway, not a summary of everything

Recommend slide count based on content density. A crisp deck is 8–14 slides. Flag if content warrants more and explain why.

### 5. Select Slide Types

For each slide in the plan, choose the type from `references/slide-types.md` that best serves the content. Apply these rules:

- **Default to visual slides** (stat callout, chart, full-bleed image) for the first 3 slides
- **Never open with an agenda slide** — move it to slide 2 at earliest if required at all
- **Never use a bullet slide when a stat callout, chart, or two-column layout would work**
- **One idea per slide** — if you have 5 bullets, that is probably 3 slides
- **Prefer two-column** over plain text + image stacked vertically
- If you are tempted to use bullets, ask: is this evidence (use a chart), a list of features (use icon grid), or a comparison (use comparison table)?

### 6. Split Dense Content

After assigning slide types, review every slide for content density. A slide is too dense if any of these are true:

- Body text exceeds **40 words** (roughly 3 lines at presentation font sizes)
- There are more than **3 bullet points**
- The slide tries to cover **more than one idea, comparison, or data point**
- The speaker notes need more than 4 sentences to explain the slide

When a slide is too dense, split it:

1. **Identify the natural seams** — each distinct idea, metric, example, or argument becomes its own slide
2. **Promote sub-points to slides** — a bullet that needs its own context or evidence is not a bullet, it is a slide
3. **Distribute, do not compress** — never shrink font size or cram text to fit. Add slides instead. A 20-slide deck where every slide lands in 3 seconds beats a 10-slide deck the audience has to squint at.
4. **Re-check the narrative arc** — after splitting, verify the hook -> context -> insight -> evidence -> action -> close sequence still flows. Add transition slides if the split created a jarring jump.

Apply this step to the entire plan before generating asset specs. It is cheaper to add slides now than to fix overflow in the renderer.

### 7. Generate Asset Specs

For each slide, produce the asset spec appropriate to its type:

**Charts** — produce a complete spec per `references/chart-specs.md`. Include chart type, labels, data values, color mapping, caption, and data source. Flag illustrative data explicitly.

**Images** — produce one of: an image generation prompt, a stock search query, or a placeholder spec. Follow all templates in `references/image-prompts.md`. Never use a vague prompt like "a business photo" — be specific about subject, mood, lighting, and composition.

**Icons** — for icon-grid slides, specify icon name (Lucide, Material, or Phosphor library), size, color, and container style (e.g., "24px `Zap` from Lucide, white, in a 48px filled circle using accent color").

**No asset** — some slides (comparison table, quote) need no image asset. State "asset: none" explicitly so the renderer does not wait for one.

### 8. Self-Critique Before Output

Before producing the Content Manifest, run this checklist against your plan:

- [ ] Does the deck open with a hook, not an agenda or intro?
- [ ] Is every slide doing exactly one job?
- [ ] Are there any bullet slides that should be charts, stat callouts, or icon grids?
- [ ] Does every chart slide have a clear takeaway in the title (not just "Q3 Revenue")?
- [ ] Does every stat callout slide give context for why the number matters?
- [ ] Is the narrative arc complete: hook -> context -> insight -> evidence -> action -> close?
- [ ] Does the deck end with a single CTA, not a summary of everything?
- [ ] Does any slide have body text exceeding 40 words or more than 3 bullets? If so, split it (step 6).

Fix any issues before outputting. If a slide's content plan is genuinely unclear or underdetermined, flag it with `design_notes: "NEEDS CLARIFICATION -- [what is missing]"` rather than filling it with placeholder content.

Also write a one-paragraph **visual brief** for each slide describing what a viewer should feel and understand within 3 seconds of seeing it. This is part of the manifest output.

### 9. Output the Content Manifest

Produce the Content Manifest as a structured document. Use this schema for each slide:

```json
{
  "slide_number": 1,
  "slide_type": "title_cover",
  "title": "The slide title exactly as it will appear",
  "subtitle": "Subtitle or null",
  "body": "Body text, bullet points, or null",
  "speaker_notes": "What the presenter says on this slide (2-4 sentences)",
  "asset": {
    "type": "image | chart | icon_set | none",
    "prompt": "Image generation prompt, chart JSON spec, icon spec, or null",
    "dimensions": "e.g., 1280x720, 16:9, or null",
    "placement": "background | right-column | full-bleed | inline | null"
  },
  "visual_brief": "One paragraph: what a viewer feels and understands in 3 seconds",
  "design_notes": "Any instructions for the renderer, or NEEDS CLARIFICATION note",
  "transition_note": "What the speaker says moving TO the next slide"
}
```

Output the full manifest as a JSON array or as a structured Markdown document with one `##` section per slide. After the manifest, include a **Deck Summary** block:

```
DECK SUMMARY
------------
Total slides: N
Narrative arc: [hook / context / insight / evidence / action / close]
Asset breakdown: N charts, N images, N icon sets, N no-asset slides
Estimated presentation time: N-N minutes (assuming ~1.5 min/slide)
Flagged slides: [list any slides marked NEEDS CLARIFICATION]
```

## Boundaries

- Do **not** render this manifest into a deck directly — hand it to `$slide-deck-layout`
- Do **not** define colors, fonts, or spacing — defer to the layout skill's styling conventions
- Do **not** write full speaker scripts — speaker notes are 2-4 sentences maximum
- Do **not** source or download actual image files — produce prompts and specs only
- Do **not** render .pptx or any file format — this skill produces a manifest, not a file
