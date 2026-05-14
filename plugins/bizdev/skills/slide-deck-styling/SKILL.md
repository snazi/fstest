---
name: slide-deck-styling
description: "Polish and style existing slide decks by converting dense text into visual diagrams, fixing overlapping elements, and adjusting layout for readability. Use for presentation styling, color palette adjustments, typography fixes, and visual polish of existing decks. Scope: visual polish of existing decks only -- does not create decks from scratch or plan content."
---

# Slide Deck Styling

## When to Use This Skill

Load this skill when the user has an existing slide deck that needs visual polish. This skill does **not** create decks from scratch — use `$slide-deck-layout` for that. This skill improves an existing deck by converting text-heavy slides into diagrams, fixing visual overlaps, and making minor layout adjustments.

## Process

### 1. Load the Layout Skill

Read `$slide-deck-layout` to understand the deck structure conventions and rendering method. Use the same rendering approach for all modifications.

### 2. Audit the Deck

Open the existing deck (PPTX file, Google Slides URL, or other format) and walk through every slide to identify:

| Issue type | What to look for |
|-----------|-----------------|
| **Text-heavy slides** | Body text exceeding 4 lines, bullet lists with 5+ items, paragraphs in content areas |
| **Visual overlaps** | Text boxes overlapping other text boxes, text overlapping images, elements outside the visible slide area |
| **Layout problems** | Uneven spacing between elements, inconsistent alignment across slides, orphaned elements (e.g., a single bullet on a slide) |
| **Empty elements** | Placeholder elements with no content, invisible text boxes causing ghost overlaps, whitespace-only elements |

Present a summary of findings to the user before making changes. Group by slide number and issue type.

### 3. Convert Text to Visual Diagrams

For each text-heavy slide, determine the best visual replacement:

| Content pattern | Recommended visual |
|-----------------|-------------------|
| Sequential steps or process | Flow diagram (horizontal or vertical arrows) |
| Hierarchy or org structure | Tree diagram or nested boxes |
| Comparison of 2-3 options | Side-by-side columns or comparison table |
| Timeline or milestones | Timeline diagram with markers |
| Grouped categories | Icon grid or card layout |
| Metrics or KPIs | Stat callout boxes or gauge visuals |
| Relationships between concepts | Network or Venn diagram |

Build diagrams using shape primitives (rectangles, circles, arrows, connectors) with text labels. Maintain the deck's existing color palette — do not introduce new colors.

Keep the original slide title. Replace only the body content with the diagram.

### 4. Fix Visual Overlaps

For each overlap identified in the audit:

1. **Read element positions** — check coordinates and dimensions of overlapping elements
2. **Determine priority** — titles take precedence over body text; images take precedence over decorative shapes
3. **Reposition or resize** — move lower-priority elements so they no longer collide
4. **Verify bounds** — ensure no element extends beyond the slide canvas

Never delete content to resolve an overlap. Reposition or resize instead.

### 5. Remove Empty Elements

After fixing overlaps, scan every slide for empty or effectively empty text elements:

- Contains no text at all
- Contains only whitespace (spaces, newlines, tabs)
- Is a placeholder element that was never filled in

For each empty element: confirm it is not structurally required, then delete it. Empty text boxes are the most common source of invisible overlap issues.

### 6. Minor Layout Adjustments

After diagram insertion and overlap fixes, do a final pass:

- **Align elements** — snap related elements to the same vertical or horizontal baseline
- **Equalize spacing** — maintain consistent gaps between diagram nodes and between content blocks
- **Reflow text** — if diagram insertion changed the amount of body text, adjust text box size so text does not clip or overflow
- **Check font sizes** — ensure no text is smaller than 14pt after resizing; flag to the user if content cannot fit at readable sizes

Save the updated deck and share with the user.

## Safety Guards

- Before converting a text-heavy slide to a diagram, confirm the conversion approach with the user.
- Before modifying multiple slides, state which slides will be affected and what will change.
- Do not delete slides or remove meaningful content. The only elements that may be deleted are empty text boxes (step 5).
- If a slide cannot be improved without removing content, flag it to the user and suggest splitting into two slides.
