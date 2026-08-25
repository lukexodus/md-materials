## Kibana Essentials — Lens and Visualize

### Overview

Lens is Kibana's primary drag-and-drop visualization editor, designed to let users build charts by dragging fields onto a canvas without writing queries or configuring aggregations manually. It replaced the older, more manual visualization builders as the recommended default for most charting tasks. Visualize Library is the broader home for all saved visualizations in Kibana, including those built with Lens, TSVB (Time Series Visual Builder), Timelion, and legacy visualization types.

Both tools operate on top of Elasticsearch data views (formerly called index patterns), which define which indices Kibana queries and how fields are typed and formatted.

### Data Views: The Foundation

Before building any visualization, Kibana needs a data view pointing at one or more Elasticsearch indices.

**Key Points**

- A data view is a saved object mapping to one or more indices, data streams, or index aliases, often using wildcards (e.g., `logs-*`).
- Data views define field lists, field types, and formatting (date formats, custom field labels).
- Runtime fields can be defined at the data view level, letting users add computed fields without reindexing.
- Data views are created under Stack Management → Data Views, or inline while creating a visualization.

### Lens: Core Concepts

Lens works on a "drag fields onto zones" model. The main interface has three logical areas:

1. **Field list** — available fields from the selected data view, with icons indicating type (string, number, date, geo).
2. **Chart canvas** — live preview of the visualization, updated as configuration changes.
3. **Configuration panel** — horizontal/vertical axes, breakdown/color dimensions, and per-dimension settings.

**Key Points**

- Lens automatically suggests chart types based on the fields dragged in (e.g., a date field + numeric field suggests a line chart).
- Users can switch chart types after the fact without losing the underlying configuration, since Lens preserves the dimension mappings where possible.
- Lens supports bar, line, area, pie, donut, treemap, heat map, tag cloud, gauge, metric, and table visualizations, among others.

### Building a Basic Visualization in Lens

**Example**

To chart average response time over time from a `logs-*` data view:

1. Open Lens (Analytics → Visualize Library → Create visualization → Lens, or directly from Discover).
2. Select the `logs-*` data view.
3. Drag `@timestamp` to the horizontal axis — Lens auto-buckets it into a date histogram.
4. Drag `response_time` to the vertical axis — Lens defaults to the Average aggregation.
5. Optionally drag `service.name` to "Break down by" to split the line per service.

The resulting configuration is a stacked/multi-series line chart with time on the X-axis, average response time on the Y-axis, and one series per service value.

### Field Aggregations Available in Lens

**Key Points**

- Numeric fields: Average, Sum, Min, Max, Median, Percentile, Unique Count (cardinality), Count.
- Date fields: Date histogram (auto or fixed interval), Min, Max.
- Keyword/text fields: Terms (top values), Unique Count, Filters (custom Elasticsearch query per bucket), Rare terms.
- Formula: a scripted-field-like expression editor supporting math on multiple aggregations, e.g. `average(bytes) / 1000`.

### Lens Formula

Formula is Lens's built-in expression language for combining aggregations into a single computed metric, without writing a scripted field or Painless script in the index mapping.

**Example**



```
100 * count(kql='status_code >= 500') / count()
```

This computes the percentage of requests that returned a server error, using KQL as a per-metric filter inside the formula.

**Key Points**

- Formula supports math operators, functions like `sum()`, `average()`, `count()`, `unique_count()`, `moving_average()`, `cumulative_sum()`, `differences()`, and time-shift functions like `time_shift`.
- Formulas can reference other formulas' underlying aggregations but not other visualizations.
- Formula results can be formatted as percentages, bytes, duration, or custom number formats directly in the dimension editor.

### Visualization Types and When to Use Them

| Chart Type | Best For |
| --- | --- |
| Line/Area | Trends over time, especially multiple series |
| Bar (vertical/horizontal) | Comparing discrete categories |
| Pie/Donut | Proportions of a whole (small number of categories) |
| Metric | Single KPI value, often with a comparison/trend sparkline |
| Data Table | Precise values, multiple dimensions, sortable exports |
| Heat Map | Density/intensity across two categorical or time dimensions |
| Treemap | Hierarchical proportions |
| Gauge | Progress against a threshold or target |
| Tag Cloud | Relative frequency of terms (less precise, more visual) |

### Layer Types in Lens

Lens supports multiple **layers** within a single chart, each potentially querying different data.

**Key Points**

- **Data layer** — the standard aggregation-based layer built from a data view.
- **Reference line layer** — static or dynamic threshold lines (e.g., a horizontal line at the 95th percentile).
- **Annotation layer** — marks specific events on a time-based chart, either manually placed or query-driven (e.g., mark deployment events pulled from a separate index).

[Inference] Multiple data layers pulling from different data views in a single chart is supported in reasonably recent Kibana versions, but the exact availability and behavior can differ by version, so this should be verified against the specific deployed release.

### Filtering Within Lens

**Key Points**

- Global filters and the KQL/Lucene search bar apply to the whole visualization.
- Per-series filters can be added via the "Filters" aggregation type, allowing multiple differently-filtered series in one chart (e.g., "errors" vs "successes" as two bars).
- Time range is controlled by the dashboard/visualization time picker, independent of any explicit time-range filters.

### Visualize Library

The Visualize Library (Analytics → Visualize Library) is the catalog of all saved visualization objects, regardless of which editor created them.

**Key Points**

- Supports search, tagging, and filtering by type (Lens, TSVB, Timelion, legacy aggregation-based visualizations, Vega).
- Visualizations saved here can be embedded into dashboards, or opened directly for editing.
- Legacy visualization types (e.g., the original "Area," "Bar," "Line" aggregation-based builders) are largely superseded by Lens but may still appear in older Kibana instances or imported saved objects.

### Other Visualization Editors Accessible from the Library

- **TSVB (Time Series Visual Builder)** — a more advanced, panel-based editor for complex time-series math, math across multiple index patterns in a single panel, and pipeline aggregations without needing Formula syntax.
- **Timelion** — a query-language-based time-series visualization tool using its own expression syntax (`.es()`, `.label()`, etc.), largely superseded by Lens Formula and TSVB but still present for backward compatibility.
- **Vega/Vega-Lite** — a fully custom, declarative visualization grammar for advanced/custom charts not achievable through Lens, requiring hand-written JSON/Vega specifications.

**Key Points**

- Lens is recommended as the default choice for most use cases due to its simpler interface and tight dashboard integration.
- TSVB and Vega remain relevant when Lens's aggregation model can't express the required logic (e.g., complex pipeline aggregations, custom D3-like visuals).

### Saving and Embedding

**Key Points**

- Visualizations can be saved directly to the Visualize Library or saved "by value" inside a specific dashboard (not appearing in the shared library).
- "By reference" (library) visualizations are reusable across multiple dashboards and update everywhere when edited.
- "By value" visualizations are local to one dashboard panel and don't affect other dashboards, useful for one-off, dashboard-specific tweaks.

### Panel Configuration Diagram

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 360">
\<style\>
.box { fill: #ffffff; stroke: #4a4a4a; stroke-width: 1.5; }
.label { font-family: sans-serif; font-size: 13px; fill: #1a1a1a; }
.title { font-family: sans-serif; font-size: 15px; fill: #1a1a1a; font-weight: bold; }
.arrow { stroke: #4a4a4a; stroke-width: 1.5; marker-end: url(#arrowhead); fill: none; }
.sub { font-family: sans-serif; font-size: 11px; fill: #555555; }
\</style\>
<text x="20" y="25" class="title">Lens Visualization Flow (svg_diagram)</text>
<rect x="20" y="50" width="160" height="60" class="box" rx="4" />
<text x="35" y="75" class="label">Data View</text>
<text x="35" y="93" class="sub">logs-* / index pattern</text>
<rect x="230" y="50" width="160" height="60" class="box" rx="4" />
<text x="245" y="75" class="label">Field List</text>
<text x="245" y="93" class="sub">drag fields to canvas</text>
<rect x="440" y="50" width="160" height="60" class="box" rx="4" />
<text x="455" y="75" class="label">Dimension Config</text>
<text x="455" y="93" class="sub">axis, breakdown, formula</text>
<line x1="180" y1="80" x2="225" y2="80" class="arrow" />
<line x1="390" y1="80" x2="435" y2="80" class="arrow" />
<rect x="230" y="160" width="160" height="60" class="box" rx="4" />
<text x="245" y="185" class="label">Chart Canvas</text>
<text x="245" y="203" class="sub">live preview</text>
<line x1="520" y1="110" x2="330" y2="155" class="arrow" />
<rect x="230" y="270" width="160" height="60" class="box" rx="4" />
<text x="245" y="295" class="label">Save</text>
<text x="245" y="313" class="sub">library or by-value</text>
<line x1="310" y1="220" x2="310" y2="265" class="arrow" />
<rect x="450" y="270" width="200" height="60" class="box" rx="4" />
<text x="465" y="295" class="label">Dashboard Panel</text>
<text x="465" y="313" class="sub">embedded, filterable</text>
<line x1="390" y1="300" x2="445" y2="300" class="arrow" />
</svg>

### Common Pitfalls

**Key Points**

- Choosing "Unique Count" instead of "Count" when cardinality (not raw document count) is actually intended, producing misleading totals for high-cardinality fields.
- Forgetting that Lens's default date histogram interval is "Auto," which changes bucket size based on the selected time range — comparisons across saved screenshots taken at different times can look inconsistent as a result.
- Applying a global KQL filter that unintentionally excludes documents needed by a reference line or annotation layer, since filters generally cascade to all layers unless a layer-specific filter overrides them. [Inference] The precise cascading behavior for reference lines specifically can vary by Kibana version and should be checked against the deployed version's documentation.
- Mixing "by value" and "by reference" visualizations without a clear convention, making it hard to track which dashboard changes propagate elsewhere.

### Conclusion

Lens provides a fast, discoverable path to building most Elasticsearch visualizations through drag-and-drop field mapping and Formula expressions, while the Visualize Library serves as the shared catalog and entry point to more specialized editors (TSVB, Timelion, Vega) for cases Lens's aggregation model doesn't cover. Understanding data views, aggregation types, and the by-value/by-reference distinction is foundational to using either tool effectively within dashboards.

### Related Topics

- Kibana Dashboards — layout, panel linking, and drilldowns
- TSVB Deep Dive — pipeline aggregations and multi-index math
- Kibana Alerting — threshold and anomaly-based rules on visualized data
- Data View Runtime Fields and Scripted Fields
- Vega/Vega-Lite Custom Visualizations in Kibana
- Kibana Canvas for pixel-perfect reporting
- Elasticsearch Aggregations Deep Dive (bucket vs. metric aggregations)