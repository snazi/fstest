---
name: slide-deck-layout
description: "Create and edit presentation decks as PPTX files using native capabilities. Use for slide deck layout creation, Google Slides layout generation, slide structure building, and rendering Content Manifests into presentation files. Scope: deck rendering and layout only -- does not plan content or define brand styling."
---

# Slide Deck Layout

## When to Use This Skill

Load this skill whenever you are asked to create, build, or edit a slide deck or presentation. Decks are built using the AI platform's native capabilities and output as PPTX files.

## Process

### 1. Choose the Rendering Method

Use whichever method is available in the current environment, in order of preference:

1. **Native design capability** — if the platform supports built-in design/document creation (e.g., Claude Design in Claude Cowork), use it to produce a PPTX directly.
2. **python-pptx** — generate PPTX programmatically via Python. Install with `pip install python-pptx` if not available. This works in all environments.
3. **Other available tools** — if the environment has a presentation tool available (Figma MCP, Google Slides API, etc.), use it as a fallback.

### 2. Set Up the Slide Canvas

Configure the presentation structure:

1. **Slide size:** 16:9 widescreen (13.333" x 7.5" / 1920x1080 px equivalent).
2. **Define a base layout** with the deck's accent color palette, font stack, and background style. Use this as the prototype for all subsequent slides.
3. **Define reusable styles:**
   - **Title:** 36–44pt bold, dark text
   - **Subtitle:** 20–24pt regular, muted color
   - **Body:** 18–24pt regular
   - **Caption:** 14–16pt, muted color
   - **Font stack:** use a clean sans-serif (Calibri, Arial, or Inter)
   - **Color palette:** if the user specifies a brand, apply it. Otherwise use a professional default — dark text on white, one accent color.

### 3. Build Slide Content

For each slide in the Content Manifest (from `$slide-deck-content`), create the appropriate layout:

| Goal | Approach |
|------|----------|
| Add a new slide | Create a slide with the appropriate layout type |
| Set slide title | Place a title text element using the heading style |
| Add body text | Place a body text element using the body style |
| Insert an image | Embed an image from a URL, file path, or generated asset |
| Create shapes/diagrams | Use rectangles, circles, lines, and connectors with labels |
| Build charts | Use native chart objects if available, or construct from shapes + text |
| Create tables | Use table objects for comparison and data slides |
| Delete a slide | Remove the slide |

### 4. Apply Consistent Styling

- Use the styles defined in step 2 across all slides.
- Maintain consistent margins: ~0.75" from edges for content areas.
- Ensure text contrast meets readability standards against backgrounds.
- Align elements consistently — titles at the same Y position across slides, body content starting at the same point.
- When duplicating slides, preserve all styling from the source.

### 5. Save and Deliver

Save the deck as a PPTX file. Share the file path with the user.

After delivery, offer optional next steps:

| Option | When to offer |
|--------|--------------|
| **Upload to Google Slides** | If the user wants it in Google Workspace — use `$gws-drive` to upload the PPTX, which auto-converts to Google Slides format |
| **Export as PDF** | If the user wants a non-editable version |
| **Iterate** | If the user wants to adjust specific slides |

## Safety Guards

- Before deleting slides, confirm with the user.
- Before bulk-editing multiple slides, state which slides will be affected and what will change.
- If the user asks to "update the template", clarify whether they mean the current deck or want to change the base styling.
