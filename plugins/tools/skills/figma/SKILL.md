---
name: figma
description: "Figma MCP integration for design-to-code workflows, reading designs, writing to Figma, managing Code Connect component mappings, and generating FigJam diagrams. Use when tasks involve Figma files, Figma URLs, UI design implementation, design tokens, design system components, or FigJam boards. Covers: get_design_context, use_figma, generate_diagram, Code Connect, web capture, and design system search. This skill does NOT cover non-Figma design tools."
---

# Figma

## When to Use This Skill

Use this skill when:

- The user shares a Figma URL (`figma.com/design/...`, `figma.com/board/...`, `figma.com/make/...`)
- The user asks to read, inspect, or implement a Figma design
- The user wants to create or edit designs in Figma
- The user wants to capture a web page into Figma
- The user wants to create a diagram in FigJam
- The user wants to map Figma components to codebase components (Code Connect)
- The user asks about design tokens, variables, or design system components

## URL Parsing

Extract `fileKey` and `nodeId` from Figma URLs before calling any tool:

| URL Pattern | fileKey | nodeId |
|---|---|---|
| `figma.com/design/:fileKey/:fileName?node-id=1-2` | `:fileKey` | `1:2` (convert `-` to `:`) |
| `figma.com/design/:fileKey/branch/:branchKey/:fileName` | `:branchKey` | from `node-id` param |
| `figma.com/make/:makeFileKey/:makeFileName` | `:makeFileKey` | from `node-id` param |
| `figma.com/board/:fileKey/:fileName` | `:fileKey` | from `node-id` param (FigJam) |

Always convert `-` to `:` in node IDs (e.g., `1-2` becomes `1:2`).

## Process

### 1. Authenticate and Identify Context

If this is the first Figma interaction in the session, call `mcp__plugin_figma_figma__whoami` to verify the authenticated user and retrieve available plan keys. Store the plan key for later use with file creation or diagram generation.

### 2. Choose the Right Tool

#### Reading Designs

| Goal | Tool | Notes |
|---|---|---|
| Get design context + code reference | `get_design_context` | **Primary tool.** Returns reference code, screenshot, and metadata. Always prefer this. |
| Get a screenshot only | `get_screenshot` | Use when you only need the visual, not the code. `nodeId` and `fileKey` are both required. |
| Get structural overview | `get_metadata` | Returns XML with node IDs, types, names, positions. Use to explore structure before calling `get_design_context` on specific nodes. Never use on Figma Make files. |
| Read a FigJam board | `get_figjam` | Only for FigJam files (`figma.com/board/...`). Use `0:1` as nodeId for the full board. |
| Get design tokens/variables | `get_variable_defs` | Returns variable definitions (colors, spacing, fonts) for a node. |
| List design libraries | `get_libraries` | Returns subscribed and available libraries for a file. Use library keys to scope `search_design_system`. |
| Search design system | `search_design_system` | Search components, variables, and styles across libraries. Requires `fileKey` for context. |

#### Writing to Figma

| Goal | Tool | Notes |
|---|---|---|
| Create/edit/delete anything | `use_figma` | **General-purpose write tool.** Executes JavaScript via the Figma Plugin API. Default choice for all write operations. |
| Capture a web page | `generate_figma_design` | First call without `outputMode` to get options. Then call with chosen mode. Poll with `captureId` every 5s (max 10 times) until `completed`. |
| Create a blank file | `create_new_file` | Requires `planKey` from `whoami`. Use before `use_figma` when no target file exists. |
| Create a diagram | `generate_diagram` | Generates Mermaid diagrams in FigJam. Creates its own file — do not call `create_new_file` first. Always show the returned URL to the user. |
| Upload images | `upload_assets` | Call with `count` to get upload URLs. POST raw bytes with correct Content-Type. Max 10MB per asset. |

#### Code Connect

| Goal | Tool | Notes |
|---|---|---|
| Get existing mappings | `get_code_connect_map` | Returns `{nodeId: {codeConnectSrc, codeConnectName}}` for a node. |
| Get AI-suggested mappings | `get_code_connect_suggestions` | Returns suggestions. Review with user, then save via `send_code_connect_mappings`. |
| Get component metadata | `get_context_for_code_connect` | Returns properties, variants, and descendant tree for building Code Connect templates. |
| Add a single mapping | `add_code_connect_map` | Maps one Figma node to one code component. Requires `label` (framework). |
| Bulk save mappings | `send_code_connect_mappings` | Save multiple mappings at once. Use after `get_code_connect_suggestions`. |

#### Design System

| Goal | Tool | Notes |
|---|---|---|
| Generate design system rules | `create_design_system_rules` | Produces a prompt for generating design system rules for the current repo. |

### 3. Design-to-Code Workflow

When the user wants to implement a Figma design in code:

1. Call `get_design_context` with the `fileKey` and `nodeId`. Pass the project's `clientLanguages` and `clientFrameworks`.
2. The response contains reference code (React + Tailwind by default), a screenshot, and contextual hints. This is a **reference**, not final code.
3. Adapt the output to the target project:
   - If the response includes **Code Connect snippets**, use the mapped codebase component directly.
   - If it includes **component documentation links**, follow them for usage guidance.
   - If it includes **design tokens as CSS variables**, map them to the project's token system.
   - If it includes **raw hex colors or absolute positioning**, the design is loosely structured — rely on the screenshot.
4. Check the target project for existing components, layout patterns, and tokens. Reuse what exists.
5. Before creating new components in code, call `search_design_system` to check if the design system already has matching components.

### 4. Web Capture Workflow

When the user wants to capture a web page into Figma:

1. Call `generate_figma_design` **without** `outputMode` to get capture instructions and available options.
2. Present the options to the user and let them choose `newFile`, `existingFile`, or `clipboard`.
3. Call again with the chosen `outputMode` (plus `planKey`/`fileName` for `newFile`, or `fileKey` for `existingFile`).
4. Poll with the returned `captureId` every 5 seconds, up to 10 times, until status is `completed`.
5. For web apps, run `generate_figma_design` and `use_figma` with `search_design_system` in parallel for best results — then refine the `use_figma` output to match the captured layout, and delete the capture (it was used as reference only).

### 5. Diagram Workflow

When the user wants a diagram in FigJam:

1. Get `planKey` from `whoami` if not already known.
2. Write the diagram in Mermaid.js syntax. Supported types: `graph`, `flowchart`, `sequenceDiagram`, `stateDiagram`, `stateDiagram-v2`, `gantt`.
3. Call `generate_diagram` with the Mermaid syntax and `planKey`.
4. Always show the returned URL to the user as a markdown link.

Mermaid syntax rules:
- Use `LR` direction by default for graph/flowchart diagrams.
- Put all shape and edge text in quotes (e.g., `["Text"]`, `-->|"Edge Text"|`).
- No emojis, no `\n` for newlines.
- Color styling allowed sparingly for graph/flowchart only — not for gantt or sequence diagrams.
- No notes in sequence diagrams.
- Do not use the word `end` in class names.

## Gotchas

- **Font "Inter"**: style names have a space — `"Semi Bold"` not `"SemiBold"`, `"Extra Bold"` not `"ExtraBold"`.
- **Setting current page**: `figma.currentPage = page` does not work. Use `await figma.setCurrentPageAsync(page)`.
- **Plugin data**: `getPluginData`/`setPluginData` are not supported (web-only). Use `getSharedPluginData(namespace, key)` and `setSharedPluginData(namespace, key, value)` with a stable namespace (>=3 chars, alphanumeric/`_`/`.`).
- **Capture IDs**: each `captureId` is single-use. To capture multiple pages, call `generate_figma_design` once per page.
- **generate_diagram**: creates its own file — do not call `create_new_file` beforehand.
- **get_metadata**: never use on Figma Make files.
