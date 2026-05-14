# Chart Specs Reference

Use this guide whenever a slide calls for a chart. Every chart slide requires a complete spec — partial specs block the renderer. Flag illustrative data explicitly so presenters are not caught off guard.

---

## Chart Type Selection

| Goal | Chart type | Avoid when |
|------|-----------|-----------|
| Show trend over time | **Line** | Fewer than 3 time points — use bar instead |
| Compare values across named categories | **Bar** (horizontal) or **Column** (vertical) | More than 10 categories — group or aggregate |
| Compare multiple series across categories | **Grouped bar** | More than 3 series — too visually noisy |
| Show composition at one point in time | **Donut** or **Pie** | More than 5 segments — merge small slices into "Other" |
| Show composition change over time | **Stacked area** | Non-cumulative data — use line instead |
| Show two variables and their relationship | **Scatter** | Audiences unfamiliar with scatter — add a clear axis explanation |
| Show funnel or conversion | **Funnel** | Stages that don't have a natural drop-off ordering |

**Default to horizontal bar** when category labels are long — labels read better on the left than rotated on the bottom axis.

---

## Required Fields Per Chart

Every chart spec must include all of the following fields. Omit none.

```json
{
  "chart_type": "bar | column | line | grouped_bar | donut | pie | stacked_area | scatter | funnel",
  "title": "Slide title — states the insight, not the topic",
  "caption": "Source: [Source Name], [Year]. [Add 'Illustrative data.' if values are not real.]",
  "x_axis": {
    "label": "Axis label (omit if self-evident from data)",
    "values": ["Category A", "Category B", "Category C"]
  },
  "y_axis": {
    "label": "Axis label with unit (e.g., 'Revenue (USD millions)')",
    "min": 0,
    "max": null
  },
  "series": [
    {
      "name": "Series name (shown in legend)",
      "color": "primary | secondary | accent | neutral | [hex code]",
      "values": [42, 67, 31, 88]
    }
  ],
  "annotations": [],
  "show_legend": true,
  "show_data_labels": false,
  "illustrative": false
}
```

**Color palette tokens** (resolved by the styling skill):
- `primary` — TM dark navy
- `secondary` — TM medium teal
- `accent` — TM highlight color
- `neutral` — TM grey
- Use hex only when a specific brand color is required and none of the tokens fit

---

## Chart Type Specs

### Line Chart

```json
{
  "chart_type": "line",
  "title": "Platform Adoption Accelerated After the Q2 Launch",
  "caption": "Source: Internal analytics, 2025. Illustrative data.",
  "x_axis": { "label": "Month", "values": ["Jan", "Feb", "Mar", "Apr", "May", "Jun"] },
  "y_axis": { "label": "Active users (thousands)", "min": 0, "max": null },
  "series": [
    { "name": "Enterprise", "color": "primary", "values": [12, 14, 15, 28, 41, 55] },
    { "name": "SMB", "color": "secondary", "values": [8, 9, 11, 19, 27, 34] }
  ],
  "show_legend": true,
  "show_data_labels": false,
  "illustrative": true
}
```

**Rules:**
- Smooth curves preferred over jagged point-to-point lines
- Maximum 3 series on one line chart before it becomes unreadable
- Annotate significant events on the x-axis (product launch, policy change) with a vertical dashed line

---

### Bar Chart (Horizontal)

```json
{
  "chart_type": "bar",
  "title": "Southeast Asia Leads in Deployment Readiness",
  "caption": "Source: Gartner, 2024.",
  "x_axis": { "label": "Readiness score (0–100)", "values": null },
  "y_axis": { "label": null, "values": ["Philippines", "Vietnam", "Indonesia", "Thailand", "Malaysia"] },
  "series": [
    { "name": "Readiness score", "color": "primary", "values": [82, 74, 68, 61, 58] }
  ],
  "show_legend": false,
  "show_data_labels": true,
  "illustrative": false
}
```

**Rules:**
- Sort bars by value (largest to smallest) unless a natural ordering exists (chronological, alphabetical by convention)
- Use `show_data_labels: true` for bar charts so readers don't have to estimate from the axis
- Single-series bar charts need no legend

---

### Column Chart (Vertical)

```json
{
  "chart_type": "column",
  "title": "Cost Per Transaction Dropped 40% in 18 Months",
  "caption": "Source: Finance team, Q4 2024. Illustrative data.",
  "x_axis": { "label": "Quarter", "values": ["Q1 23", "Q2 23", "Q3 23", "Q4 23", "Q1 24", "Q2 24"] },
  "y_axis": { "label": "Cost per transaction (USD)", "min": 0, "max": null },
  "series": [
    { "name": "Cost per transaction", "color": "primary", "values": [4.20, 3.90, 3.40, 3.10, 2.70, 2.52] }
  ],
  "show_legend": false,
  "show_data_labels": false,
  "illustrative": true
}
```

**Rules:**
- Use column (vertical) when x-axis is time-based and there are <=8 time points
- Use horizontal bar when x-axis is categorical with long labels

---

### Grouped Bar Chart

```json
{
  "chart_type": "grouped_bar",
  "title": "Model B Outperforms Across All Accuracy Metrics",
  "caption": "Source: Internal benchmarks, March 2025. Illustrative data.",
  "x_axis": { "label": null, "values": ["Precision", "Recall", "F1 Score"] },
  "y_axis": { "label": "Score (%)", "min": 0, "max": 100 },
  "series": [
    { "name": "Model A (baseline)", "color": "neutral", "values": [71, 68, 69] },
    { "name": "Model B (proposed)", "color": "primary", "values": [84, 81, 82] }
  ],
  "show_legend": true,
  "show_data_labels": true,
  "illustrative": true
}
```

**Rules:**
- Maximum 3 series — beyond that, use small multiples or a table
- Highlight the winning series with `primary` color; use `neutral` for baselines

---

### Donut Chart

```json
{
  "chart_type": "donut",
  "title": "Manual Work Still Accounts for Half the Pipeline",
  "caption": "Source: Ops team survey, 2025. n=120.",
  "series": [
    {
      "name": "Segments",
      "values": [
        { "label": "Fully automated", "value": 28, "color": "primary" },
        { "label": "Partially automated", "value": 22, "color": "secondary" },
        { "label": "Manual", "value": 50, "color": "neutral" }
      ]
    }
  ],
  "center_label": "50%",
  "center_sublabel": "manual",
  "show_legend": true,
  "illustrative": false
}
```

**Rules:**
- Maximum 5 segments; merge anything under 5% into "Other"
- Always include a `center_label` that highlights the most important number
- Donut preferred over pie — the hollow center adds the center label and looks cleaner

---

### Stacked Area Chart

```json
{
  "chart_type": "stacked_area",
  "title": "Cloud Spend Is Shifting Toward ML Workloads",
  "caption": "Source: Finance, 2024. Illustrative data.",
  "x_axis": { "label": "Quarter", "values": ["Q1", "Q2", "Q3", "Q4"] },
  "y_axis": { "label": "Spend (USD thousands)", "min": 0, "max": null },
  "series": [
    { "name": "Compute", "color": "neutral", "values": [120, 130, 125, 118] },
    { "name": "Storage", "color": "secondary", "values": [40, 42, 45, 48] },
    { "name": "ML workloads", "color": "primary", "values": [20, 35, 58, 90] }
  ],
  "show_legend": true,
  "show_data_labels": false,
  "illustrative": true
}
```

**Rules:**
- Stack the most stable series at the bottom; the most variable series at the top
- Use when the total value and its composition both matter

---

### Scatter Chart

```json
{
  "chart_type": "scatter",
  "title": "Higher Automation Correlates with Lower Incident Rate",
  "caption": "Source: SRE team data, 2024. Each point = one team. Illustrative data.",
  "x_axis": { "label": "Automation coverage (%)", "min": 0, "max": 100 },
  "y_axis": { "label": "Incidents per month", "min": 0, "max": null },
  "series": [
    {
      "name": "Teams",
      "color": "primary",
      "points": [
        { "x": 20, "y": 45 }, { "x": 35, "y": 38 }, { "x": 50, "y": 27 },
        { "x": 65, "y": 18 }, { "x": 80, "y": 9 }, { "x": 90, "y": 5 }
      ]
    }
  ],
  "show_trendline": true,
  "show_legend": false,
  "illustrative": true
}
```

**Rules:**
- Add a trendline (`show_trendline: true`) whenever you want to show correlation
- Label outlier points if they need explanation
- Add a brief note explaining the unit of each data point (what one dot represents)

---

## Edge Cases

| Situation | How to handle |
|-----------|--------------|
| Data is missing for some periods | Use a dashed line segment or an explicit gap — never interpolate without noting it |
| Values are too similar to distinguish | Use a zoomed y-axis (non-zero baseline) but label the baseline clearly |
| Too many data series (>3 for bar, >3 for line) | Split into multiple slides or aggregate minor series into "Other" |
| Negative values | Use diverging color scheme (positive = primary, negative = red/orange) |
| Illustrative data | Set `"illustrative": true` and add "Illustrative data." to caption — always |
| No data source available | Caption: "Source: Internal estimates." — never omit the caption entirely |
| Very large or very small numbers | Abbreviate axis labels (e.g., "12M" not "12,000,000") and note the unit in the axis label |
