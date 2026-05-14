# Slide Type Reference

Use this guide to select the right layout for each slide. Choose based on what the content needs to communicate — not what is easiest to fill.

---

## title_cover

**When to use:** First slide only. Deck opener that sets tone and frames the session.

**Content rules:**
- Title: 6–10 words max, declarative or provocative — not "Q1 Business Review"
- Subtitle: optional, one line (date, client name, or framing statement)
- No bullets, no body text, no data
- Background image is strongly recommended — it sets the emotional register for the deck

**Asset:** Full-bleed background image with a dark overlay for text contrast. Provide an image generation prompt or stock search query.

**Example title:** "The Hidden Cost of Slow Decisions"

---

## section_divider

**When to use:** Visual break between major sections of a long deck (5+ slides per section). Do not use if the deck is under 12 slides — just flow through.

**Content rules:**
- Section title only: 3–5 words
- Optional: one-line preview of what this section covers
- No body text, no bullets

**Asset:** Accent color block or abstract background. Low information density — this slide is a breath.

---

## stat_callout

**When to use:** One to three headline numbers that anchor an argument. Use this instead of a bullet slide whenever your content is metric-driven.

**Content rules:**
- 1–3 stats maximum per slide
- Each stat: the number (large, bold), a 3–5 word label below it, and optionally a single-line context sentence
- Title states the takeaway, not the topic: "Most Teams Are Leaving Money on the Table" not "Key Metrics"
- Always give context for why the number matters — a number without context is noise

**Asset:** Usually none. Optionally a subtle background texture or icon set that reinforces the theme.

**Example:**
```
Slide title: "Speed Is the Differentiator"
Stat 1: 3x | faster time-to-insight with automated pipelines
Stat 2: 68% | of data teams still rely on manual exports
```

---

## two_column

**When to use:** When you have a text argument that is strengthened by a visual on the same slide — chart, image, or icon group. Default to this over stacking text above/below an image.

**Content rules:**
- Left column: title + 2–4 bullet points or a short paragraph (max 60 words)
- Right column: chart, image, or icon set
- Or reverse: image left, text right — choose based on which element should draw the eye first
- Do not put two text blocks side-by-side — that is a comparison table, not a two-column layout

**Asset:** Chart spec, image prompt, or icon set spec for the non-text column.

---

## full_bleed_image

**When to use:** Emotional moments — openers, transitions, closing statements. When the feeling matters more than the facts on this particular slide.

**Content rules:**
- Minimal text: title + at most one short sentence overlay
- Image must be high-quality, on-brand, and reinforce the slide's emotional beat
- Text must have sufficient contrast against the image (use dark overlay or white text with shadow)

**Asset:** Full-bleed image (1920x1080 or 16:9 crop). Provide a detailed generation prompt — never "a business photo".

**Avoid:** Data, bullets, or more than 15 words total on this slide type.

---

## chart

**When to use:** Any time you have quantitative evidence. Never summarize chart data in bullets — show the data, title the takeaway.

**Content rules:**
- Title states the insight, not the chart topic: "Revenue Growth Accelerated in H2" not "Revenue by Quarter"
- Caption below chart: data source + "Illustrative" flag if values are not real
- One chart per slide — do not stack two charts
- Body text (if any): 1–2 sentences interpreting the chart for the reader

**Asset:** Full chart spec per `chart-specs.md`. Required fields: chart type, labels, data values, color mapping, caption.

**Chart type quick-pick:**
| Situation | Chart type |
|-----------|-----------|
| Trend over time | Line |
| Compare values across categories | Bar (horizontal preferred for many labels) |
| Compare multiple series across categories | Grouped bar |
| Part-of-whole (<=5 segments) | Donut or pie |
| Relationship between two variables | Scatter |
| Cumulative contribution | Stacked area |

---

## timeline

**When to use:** Sequential steps, process flows, roadmaps, or historical progression. Use when order matters and each step is distinct.

**Content rules:**
- 3–6 steps maximum per slide; more than 6 should be split across two slides
- Each step: short label (2–4 words) + optional one-line description
- Horizontal layout for chronological timelines; vertical for process flows
- Title frames the arc: "How We Get from Data Chaos to Clarity"

**Asset:** Usually none — the layout itself is the visual. Optionally small icons per step.

---

## comparison_table

**When to use:** Side-by-side evaluation of options, before/after states, feature matrices, or competitive comparisons.

**Content rules:**
- 2–4 columns max (including the row-label column)
- 4–8 rows max
- Use checkmarks, X marks, or short labels — not paragraphs
- Title frames the verdict: "Option B Wins on Speed and Cost" not "Comparison"

**Asset:** None — the table is the asset. Do not add images to this slide type.

---

## quote

**When to use:** A compelling statement from a customer, executive, research source, or authority figure that validates your argument. Use sparingly — one per deck maximum.

**Content rules:**
- Quote text: 20–50 words. Longer quotes lose impact.
- Attribution: Name, Title, Company (or Source if not a person)
- Optional: one-line framing sentence above the quote giving context
- Title can be the first few words of the quote or the implication of it

**Asset:** Optional portrait photo of the quoted person (right column or background). If no photo, use a minimal accent graphic.

---

## icon_grid

**When to use:** Feature lists, capability overviews, principle sets, or benefit summaries where each item deserves equal visual weight.

**Content rules:**
- 4–6 items in a 2x2, 2x3, or 3x2 grid
- Each item: icon + 2–4 word label + optional one-line description
- All items must be parallel in structure (all nouns, all action phrases, etc.)
- Title frames the category: "What Sets Our Platform Apart"

**Asset:** Icon set spec — provide icon name from Lucide, Material Icons, or Phosphor for each cell. Specify color and container style (e.g., "24px `Zap` icon from Lucide, white, in a 48px filled circle using accent color").

**Avoid:** Using this for a list of steps or a process — use timeline for ordered content.

---

## closing_cta

**When to use:** Final slide. One clear takeaway and one clear next step.

**Content rules:**
- Headline: the single most important thing the audience should remember
- CTA: one specific action ("Schedule a discovery call", "Approve the Q3 roadmap", "Download the report")
- Contact or next-step info: name, email, or link — only if relevant
- No summary bullets — this is not a recap slide

**Asset:** Optional background image or accent graphic. Keep it clean and uncluttered.

**Avoid:** Summarizing the whole deck on this slide. If you catch yourself writing "In summary..." delete everything and start over with the single most important point.

---

## Anti-patterns to avoid

| Bad choice | Why it's bad | Better alternative |
|------------|-------------|-------------------|
| Opening with an agenda slide | Audiences don't care about the structure yet | Open with a hook stat or provocative question |
| Bullet slide with 6+ items | Audience reads ahead, presenter loses control | Break into 2–3 slides or use icon grid |
| Chart titled "Q3 Revenue" | No takeaway — the reader has to figure out what matters | Title: "Q3 Revenue Exceeded Target by 18%" |
| Stat slide with just the number | Context-free numbers don't persuade | Always include a label and one-line context |
| Two-column with text on both sides | Visually dense, no focal point | Use comparison table or two separate slides |
| Full-bleed image with long body text | Image and text fight for attention | Keep full-bleed slides to <=15 words of text |
