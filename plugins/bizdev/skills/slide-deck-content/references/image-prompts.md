# Image Prompts Reference

Use this guide whenever a slide needs an image asset. Every image specification must be concrete enough that a different person (or model) can produce the right image without asking follow-up questions. "A business photo" is not a spec.

---

## When to Use an Image

| Use an image | Skip the image |
|-------------|---------------|
| Title/cover — sets the emotional register | Dense data slides (charts, tables) |
| Full-bleed slides — emotion over information | Comparison tables |
| Two-column slides — image reinforces the text argument | Slides where the chart is the whole point |
| Section dividers — visual break | Stat callout slides (use accent design instead) |
| Quote slides — optional portrait of the quoted person | Timeline/process flow slides |

When in doubt: ask "would a photograph make this slide more persuasive, or is it just decoration?" If decoration, skip it.

---

## Prompt Structure

Every image prompt must include all of these components:

```
Subject: [who or what is in the center of the frame]
Setting: [where the scene takes place]
Mood: [the emotional register — optimistic, tense, calm, energetic, etc.]
Lighting: [quality and direction of light — soft diffused, golden hour, dramatic side-light, etc.]
Composition: [how the frame is arranged — rule of thirds with subject left, wide establishing shot, close-up detail, etc.]
Color temperature: [warm / cool / neutral — align with the slide's emotional beat]
Style: [photorealistic / editorial photography / abstract / illustration / flat design]
Avoid: [specific elements to exclude — text, logos, faces, clutter, specific colors that clash with the template]
```

Not all fields are always needed — omit what is genuinely not relevant, but never omit Subject, Mood, and Avoid.

---

## Templates by Slide Mood

### Technology / Innovation

**Use for:** AI, cloud, data platform, engineering, digital transformation decks.

```
Subject: Abstract network of glowing nodes and data streams, no visible text or UI
Setting: Dark background, deep space or dark studio
Mood: Optimistic, forward-looking, precise
Lighting: Cool blue and teal bioluminescent glow from the nodes; no harsh shadows
Composition: Wide, nodes clustered center-right with trails extending to the left edge — leaves room for text overlay on the left
Color temperature: Cool (blues, teals, subtle purples)
Style: Photorealistic digital art / CGI
Avoid: Human faces, circuit boards that look dated, neon green, text of any kind, logos
```

---

### Business Growth / Success

**Use for:** Revenue milestones, market expansion, partnership announcements, positive results decks.

```
Subject: An upward-trending abstract shape — rising curve, ascending steps, or a mountain peak emerging from mist
Setting: Clean minimal environment, subtle gradient background
Mood: Confident, aspirational, calm momentum
Lighting: Soft directional light from upper left, casting gentle shadow
Composition: Subject positioned lower-center, ample negative space in the upper half for title text
Color temperature: Warm-neutral (soft whites, warm grays, a hint of gold)
Style: Editorial photography or clean digital illustration
Avoid: Stock-photo handshakes, people in suits pointing at whiteboards, clip art arrows, text overlays
```

---

### Problem / Challenge

**Use for:** Problem statement slides, before-state illustrations, pain-point framing.

```
Subject: A single tangled knot of cables or threads against a clean surface, or a cracked dry earth texture
Setting: Stark, isolated — single element against a minimal background
Mood: Frustrated-but-solvable, tense, honest
Lighting: Flat even lighting or soft overhead — emphasizes texture, not drama
Composition: Subject center-frame, close-up, filling 60% of frame; negative space on sides for text
Color temperature: Cool-neutral or slightly desaturated
Style: Editorial macro photography
Avoid: People looking stressed or panicked (cliche), red warning icons, fire or explosions, text
```

---

### Human / Team / Culture

**Use for:** Team slides, values slides, culture descriptions, customer success stories.

```
Subject: Two or three people collaborating — looking at shared work (not at the camera)
Setting: Modern open-plan office or a warm cafe/studio — natural light, plants visible
Mood: Engaged, collaborative, genuine — not posed
Lighting: Soft natural window light from the side
Composition: Rule of thirds; people occupy left two-thirds, breathing room on the right for text
Color temperature: Warm (golden whites, soft wood tones)
Style: Documentary / candid editorial photography
Avoid: Direct-to-camera poses, stock-photo smiles, visible logos or brand names, formal suits, text
```

---

### Data / Analytics / Insight

**Use for:** Data team slides, analytics capability overviews, "what we learned" context slides.

```
Subject: An abstract visualization — flowing heatmap, particle field, or code stream — that suggests pattern and order in complexity
Setting: Dark or very dark blue background; visualization is the only element
Mood: Intelligent, precise, discovery-oriented
Lighting: Elements self-illuminate — no external light source
Composition: Visualization fills 70% of frame; denser on the right, fading to the left to leave space for text overlay
Color temperature: Cool (dark blues, teals, subtle data-orange for highlights)
Style: Photorealistic digital art — scientific visualization aesthetic
Avoid: Actual data, numbers, text, bar charts (the visualization should be abstract), pie charts
```

---

### Strategy / Roadmap / Future

**Use for:** Vision slides, roadmap context, where-we're-going narrative.

```
Subject: A wide open road or path disappearing into a distant horizon, or a compass on a map
Setting: Expansive outdoor landscape — desert highway, coastal road, or mountain pass — at dawn
Mood: Determined, wide-open possibility, clear direction
Lighting: Golden hour or early morning — long warm shadows, optimistic quality of light
Composition: Strong leading lines (road, path) pulling the eye from lower-foreground to upper-center; sky fills the top third for text
Color temperature: Warm (ambers, golds, dusty oranges)
Style: Landscape photography, slightly cinematic
Avoid: People, vehicles, signs or text in the image, overcast or stormy skies
```

---

### Security / Trust / Compliance

**Use for:** Security capability slides, compliance frameworks, data privacy, risk management.

```
Subject: An abstract lock form or layered shield shape — geometric, clean, not literal
Setting: Dark minimal background — near-black with subtle texture
Mood: Reliable, serious, authoritative — not fear-inducing
Lighting: Subtle cool light from above emphasizing the geometry
Composition: Lock/shield centered or slightly right; clean margins for text on the left
Color temperature: Cool (dark blues, silvers, white accents)
Style: Clean 3D geometric illustration or minimal CGI
Avoid: Padlocks with keyholes (cliche), red warning symbols, hacker aesthetics (green terminal text, hooded figures), text
```

---

### Closing / Call to Action

**Use for:** Final slide, CTA moment, closing emotional beat.

```
Subject: A single lit candle, a sunrise breaking over a horizon, or hands exchanging something (a plant seedling, a glowing orb)
Setting: Clean, simple, uncluttered — the subject is everything
Mood: Hopeful, decisive, warm conclusion
Lighting: Soft warm glow emanating from the subject itself or golden-hour backlighting
Composition: Subject center-frame with deliberate negative space — the simplicity IS the message
Color temperature: Warm
Style: Photorealistic editorial
Avoid: Fireworks (overdone), people cheering, text, logos, anything busy or loud
```

---

## Placeholder Specs

When no image is ready and generation is not feasible, produce a placeholder spec instead of leaving the field blank:

```json
{
  "type": "placeholder",
  "dimensions": "1280x720",
  "aspect_ratio": "16:9",
  "placement": "background | right-column | full-bleed",
  "alt_text": "One sentence describing what this image should show",
  "mood": "optimistic / tense / calm / etc.",
  "color_hint": "warm / cool / neutral",
  "source_suggestion": "Unsplash query: 'aerial city network lights night' OR generate via Claude with the prompt above"
}
```

---

## Stock Photo Search Queries

When sourcing from a stock library (Unsplash, Shutterstock, Getty), use specific descriptive queries. Never search generic terms.

| Bad query | Better query |
|-----------|-------------|
| "business meeting" | "people collaborating around laptop natural light candid" |
| "technology" | "abstract data visualization dark background teal glow" |
| "success" | "winding road mountain dawn golden hour wide shot" |
| "teamwork" | "two people reviewing whiteboard side by side not posed" |
| "innovation" | "geometric architecture clean lines minimal shadow overhead" |

---

## Image Placement Options

| Placement | When to use | Text contrast requirement |
|-----------|-------------|--------------------------|
| `background` | Full-bleed slides; image fills the entire slide | Dark overlay (50–70% opacity) required for text legibility |
| `right-column` | Two-column slides; image in right half | No overlay needed — text is in the left column |
| `full-bleed` | Same as background — explicitly full-width, full-height | Dark overlay required |
| `inline` | Rarely used; image embedded within body content | Surrounding text provides context |

For `background` and `full-bleed` placements, always specify the overlay in `design_notes`: `"Apply a dark gradient overlay (bottom-to-top, 60% opacity) to ensure white title text is legible."`
