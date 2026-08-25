## Canvas

### Overview

Canvas is Kibana's freeform, pixel-perfect presentation and infographic-style visualization tool. Unlike Dashboard's grid-based panel layout, Canvas offers a blank workpad where elements — charts, images, text, shapes — can be placed and styled with precise control, making it suited for reports, presentations, and highly customized live-data displays.

### Canvas vs. Dashboard

**Key Points**
- Dashboard arranges pre-built visualizations in a responsive grid, optimized for exploratory analysis and consistent, functional layouts.
- Canvas provides absolute positioning and free-form design, optimized for presentation-quality output — think a live, data-driven slide rather than an analytical workspace.
- [Inference] Canvas is generally better suited to a fixed audience-facing report or a TV/wall-display dashboard where visual polish and exact layout control matter, while Dashboard suits day-to-day exploratory investigation where flexible drilldown and filtering are the priority.
- Canvas elements can still be backed by live Elasticsearch queries, so a workpad isn't necessarily static — it can refresh and reflect current data just like a Dashboard.

### Workpads and Elements

**Key Points**
- A **workpad** is a Canvas document — analogous to a slide deck, it can contain multiple **pages**, each an independent freeform canvas.
- **Elements** are the individual building blocks placed on a page: charts, metrics, images, text, shapes, and data tables.
- Every element's data source, styling, and behavior is configurable independently, and elements can be freely resized, layered, and positioned anywhere on the page.

### Diagram: Canvas Workpad Structure

<svg width="100%" viewBox="0 0 680 300" role="img"><title>Canvas workpad, page, and element structure (svg_diagram)</title><desc>A Canvas workpad contains one or more pages, and each page contains freely positioned elements such as charts, metrics, text, and images, each independently connected to a data source.</desc>
<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<g class="c-gray">
<rect x="40" y="30" width="600" height="240" rx="16" stroke-width="0.5" />
<text class="th" x="60" y="20" dominant-baseline="central">Workpad</text>
</g>

<g class="c-blue">
<rect x="70" y="60" width="260" height="190" rx="10" stroke-width="0.5" />
<text class="th" x="200" y="82" text-anchor="middle">Page 1</text>
<g class="node c-teal">
<rect x="90" y="100" width="100" height="60" rx="8" stroke-width="0.5" />
<text class="ts" x="140" y="130" text-anchor="middle" dominant-baseline="central">Chart</text>
</g>
<g class="node c-coral">
<rect x="210" y="100" width="100" height="60" rx="8" stroke-width="0.5" />
<text class="ts" x="260" y="130" text-anchor="middle" dominant-baseline="central">Metric</text>
</g>
<g class="node c-purple">
<rect x="90" y="180" width="220" height="50" rx="8" stroke-width="0.5" />
<text class="ts" x="200" y="205" text-anchor="middle" dominant-baseline="central">Text / title</text>
</g>
</g>

<g class="c-blue">
<rect x="350" y="60" width="260" height="190" rx="10" stroke-width="0.5" />
<text class="th" x="480" y="82" text-anchor="middle">Page 2</text>
<g class="node c-teal">
<rect x="370" y="100" width="220" height="130" rx="8" stroke-width="0.5" />
<text class="ts" x="480" y="165" text-anchor="middle" dominant-baseline="central">Data table</text>
</g>
</g>
</svg>

### Data Sources for Elements

**Key Points**
- Elements are typically connected to Elasticsearch via Canvas's expression language, most commonly using an `esdocs` or `essql` function to query an index directly.
- **Canvas expressions** chain functions together in a pipeline syntax, where each function's output feeds the next — a query function retrieves data, subsequent functions transform or shape it, and a final render function determines how it's displayed.
- Elements can also use static data, external URLs for images, or reference values from other elements via workpad-level variables, allowing more dynamic, interconnected workpads.

```
essql query="SELECT service.name, count(*) AS total FROM logs-* GROUP BY service.name"
| pointseries x="service.name" y="total"
| plot defaultStyle={seriesStyle bars=0.75}
```

### The Expression Language

**Key Points**
- Canvas's expression language is a functional pipeline syntax — similar in concept to Unix pipes — where data flows through a chain of functions, each taking the previous function's output as implicit input.
- This gives fine-grained control over the exact transformation and rendering of an element's data, beyond what a purely UI-driven configuration panel would expose.
- The expression editor is directly accessible per element, allowing manual editing of the underlying expression for elements initially built through the visual UI, useful when a transformation isn't exposed as a UI control.

### Auto-Refresh and Live Data

Canvas workpads support configurable auto-refresh intervals, causing every data-backed element on the page to re-query and update on a schedule — this is what makes Canvas suitable for wall-mounted or TV-display "living dashboard" use cases in addition to static report generation.

### Sharing and Export

**Key Points**
- Workpads can be exported as PDF for static report distribution, capturing the current state of all pages at export time.
- Workpads can also be shared as a live, view-only link within Kibana for others to view (subject to the viewer's own Elasticsearch/Kibana permissions on the underlying data).
- [Unverified] Additional export formats and sharing mechanisms may have been added or changed in more recent Kibana versions, so current documentation should be checked for the full current export/sharing feature set.

### Custom Elements and Asset Management

**Key Points**
- Custom elements can be saved and reused across workpads, letting a commonly used chart-plus-styling combination be built once and dropped into multiple reports rather than rebuilt from scratch each time.
- The Asset Manager within Canvas stores uploaded images and other binary assets used across a workpad, keeping them available for reuse across elements and pages.

### Related Topics

- **Kibana Dashboard** as the comparison point for grid-based, exploratory visualization layout
- **ES|QL and Canvas's `essql` function** for SQL-like querying directly within Canvas expressions
- **Canvas expression function reference** in depth — the full set of transform and render functions available in the pipeline syntax
- **Kibana reporting (PDF/CSV generation)** as it relates to Canvas's own PDF export capability
- **Role-based access control for Kibana spaces**, which governs who can view or edit shared Canvas workpads
- **TSVB (Time Series Visual Builder)** as an alternative visualization tool sometimes used to source data for Canvas elements