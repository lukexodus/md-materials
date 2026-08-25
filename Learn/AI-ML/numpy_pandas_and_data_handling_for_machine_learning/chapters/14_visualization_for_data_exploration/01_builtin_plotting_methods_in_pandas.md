## Built-in Plotting Methods in pandas

### Core Concept

pandas provides a `.plot()` accessor on Series and DataFrame objects that wraps Matplotlib, allowing common chart types to be generated directly from pandas data structures without explicitly importing and calling Matplotlib functions for basic cases. This is documented pandas functionality, not [Speculation].

### Basic Setup

```python
import pandas as pd
import numpy as np

df = pd.DataFrame({
    "month": pd.date_range("2024-01-01", periods=12, freq="ME"),
    "sales": [100, 120, 90, 150, 200, 180, 220, 210, 190, 170, 160, 140],
    "costs": [80, 85, 75, 100, 130, 120, 140, 135, 125, 115, 110, 100]
})
df = df.set_index("month")
```

**Key Points**
- pandas' `.plot()` uses Matplotlib as its default backend, which is documented pandas behavior; this requires `matplotlib` to be installed.
- I cannot verify that `matplotlib` is installed in any specific environment without checking that environment directly.

### Line Plot (Default)

```python
df["sales"].plot()
```

**Key Points**
- Calling `.plot()` on a Series with no arguments produces a line plot by default, using the index as the x-axis, based on documented pandas plotting behavior.
- For a `DatetimeIndex` (as used here), the x-axis is automatically formatted as dates, which is documented pandas/Matplotlib integration behavior.

### Line Plot for Multiple Columns

```python
df[["sales", "costs"]].plot()
```

**Key Points**
- Calling `.plot()` on a DataFrame with multiple numeric columns plots each column as a separate line on the same axes by default, with a legend added automatically, based on documented pandas behavior.

### Bar Plots

```python
df["sales"].plot(kind="bar")
```

**Key Points**
- `kind="bar"` is a documented parameter value for `.plot()` producing a vertical bar chart.
- `kind="barh"` produces a horizontal bar chart, per the same documented parameter.

### Histogram

```python
df["sales"].plot(kind="hist", bins=6)
```

**Key Points**
- `kind="hist"` is documented functionality for producing a histogram, with `bins` controlling the number of intervals — this parameter is passed through to Matplotlib's underlying histogram function.

### Scatter Plot

```python
df.plot(kind="scatter", x="sales", y="costs")
```

**Key Points**
- `kind="scatter"` requires explicit `x` and `y` column arguments, based on documented pandas API design, unlike line and bar plots which can use the index automatically.
- [Unverified] I cannot verify whether calling `kind="scatter"` on a Series (rather than a DataFrame) is supported, without checking documentation for the specific pandas version in use, since scatter plots inherently require two variables.

### Box Plot

```python
df[["sales", "costs"]].plot(kind="box")
```

**Key Points**
- `kind="box"` produces a box-and-whisker plot per column, showing median, quartiles, and outliers, based on documented pandas/Matplotlib behavior.

### Area Plot

```python
df[["sales", "costs"]].plot(kind="area", alpha=0.5)
```

**Key Points**
- `kind="area"` produces a stacked area plot by default (columns stacked on top of each other), based on documented pandas behavior; `stacked=False` can be passed to overlay areas instead.
- `alpha` controls transparency and is a standard Matplotlib parameter passed through by pandas' plotting interface.

### Pie Chart

```python
df["sales"].head(4).plot(kind="pie")
```

**Key Points**
- `kind="pie"` is documented functionality typically used on a Series with a small number of values, since a pie chart with many slices becomes difficult to read — this is a general chart-design consideration, not a rule enforced by pandas.

### Customizing Plots with Standard Arguments

```python
df["sales"].plot(
    kind="line",
    title="Monthly Sales",
    xlabel="Month",
    ylabel="Sales ($)",
    figsize=(10, 5),
    color="steelblue",
    grid=True
)
```

**Key Points**
- `title`, `xlabel`, `ylabel`, `figsize`, `color`, and `grid` are documented parameters accepted by pandas' `.plot()` method, most of which are passed through to the underlying Matplotlib call.
- [Unverified] I cannot verify that every one of these exact parameter names is supported unchanged across all pandas versions without checking version-specific documentation directly, since plotting API details have been adjusted across releases.

### Subplots for Multiple Columns

```python
df[["sales", "costs"]].plot(subplots=True, figsize=(8, 6), layout=(2, 1))
```

**Key Points**
- `subplots=True` creates a separate subplot for each column instead of overlaying them on one axes, based on documented pandas behavior.
- `layout` controls the grid arrangement of subplots and is a documented parameter for this use case.

### Plotting Directly from `.groupby()` Aggregation

```python
df_grouped = pd.DataFrame({
    "category": ["A", "B", "A", "B", "C"],
    "value": [10, 20, 15, 25, 30]
})

df_grouped.groupby("category")["value"].mean().plot(kind="bar")
```

**Key Points**
- Since `.groupby(...).mean()` returns a Series, `.plot()` can be chained directly onto it, based on standard pandas method-chaining behavior — this is a common documented pattern for quick exploratory visualization.

### When to Use pandas Plotting vs. Direct Matplotlib/Other Libraries

**Key Points**
- pandas' `.plot()` is documented as a convenience wrapper intended for fast, exploratory visualization directly from a DataFrame or Series.
- [Inference] For more customized or publication-quality visualizations, using Matplotlib directly (or other libraries such as Seaborn or Plotly) is commonly recommended in practitioner discussion, since pandas' plotting interface exposes a subset of Matplotlib's full functionality — but I cannot verify this comparative judgment as a formally documented pandas recommendation without checking current official pandas documentation directly.
- [Unverified] I cannot verify the current exact relationship or level of interoperability between pandas' plotting accessor and Seaborn or Plotly without checking each library's documentation directly, since these are separate projects with independently evolving APIs.

### Accessing the Underlying Matplotlib Axes Object

```python
ax = df["sales"].plot(kind="line")
ax.set_ylim(0, 250)
ax.axhline(y=150, color="red", linestyle="--")
```

**Key Points**
- `.plot()` returns a Matplotlib `Axes` object by default, based on documented pandas behavior, allowing further customization using standard Matplotlib methods after the initial pandas call.
- This pattern is documented as a way to combine the convenience of pandas' quick plotting syntax with more granular Matplotlib customization when needed.

### pandas Plot Kind Overview

===MERMAID_DIAGRAM===
flowchart TD
    A["df.plot(kind=...)"] --> B["line - default, trends over index"]
    A --> C["bar / barh - categorical comparison"]
    A --> D["hist - distribution of a single variable"]
    A --> E["box - distribution summary with quartiles"]
    A --> F["scatter - relationship between two numeric columns"]
    A --> G["area - cumulative or stacked trends"]
    A --> H["pie - proportion of a whole, few categories"]

### Chart Type Selection Illustration

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 260">
  <text x="20" y="25" font-size="15" font-weight="bold">Choosing a pandas plot kind by data question (svg_diagram)</text>

  <rect x="20" y="55" width="180" height="50" fill="none" stroke="#1a73e8" />
  <text x="110" y="75" font-size="11" text-anchor="middle">"How does it change</text>
  <text x="110" y="90" font-size="11" text-anchor="middle">over time?" -&gt; line</text>

  <rect x="230" y="55" width="180" height="50" fill="none" stroke="#1a73e8" />
  <text x="320" y="75" font-size="11" text-anchor="middle">"How do categories</text>
  <text x="320" y="90" font-size="11" text-anchor="middle">compare?" -&gt; bar</text>

  <rect x="440" y="55" width="180" height="50" fill="none" stroke="#1a73e8" />
  <text x="530" y="75" font-size="11" text-anchor="middle">"What's the spread of</text>
  <text x="530" y="90" font-size="11" text-anchor="middle">values?" -&gt; hist / box</text>

  <rect x="20" y="130" width="180" height="50" fill="none" stroke="#e8710a" />
  <text x="110" y="150" font-size="11" text-anchor="middle">"How do two variables</text>
  <text x="110" y="165" font-size="11" text-anchor="middle">relate?" -&gt; scatter</text>

  <rect x="230" y="130" width="180" height="50" fill="none" stroke="#e8710a" />
  <text x="320" y="150" font-size="11" text-anchor="middle">"What makes up the</text>
  <text x="320" y="165" font-size="11" text-anchor="middle">total?" -&gt; area / pie</text>

  <text x="20" y="220" font-size="10" fill="#555">Conceptual grouping only, based on documented common use cases for each</text>
  <text x="20" y="235" font-size="10" fill="#555">plot kind; not a rule enforced by pandas itself.</text>
</svg>

### Uncertainty Label for This Response

[Unverified] This response combines documented pandas plotting API mechanics (`.plot()`, `kind` parameter values, returned `Axes` object) with inferred and unverified guidance about when to prefer pandas plotting versus other libraries, individually labeled [Inference] or [Unverified] above. I cannot verify the exact parameter defaults, supported arguments, or behavior of `.plot()` for any specific installed pandas or Matplotlib version without checking documentation directly for those versions. This should be confirmed against current official pandas documentation before being relied upon in production code.

### Related Topics

- Customizing plots further with direct Matplotlib `pyplot` and `Axes` methods
- Seaborn for statistical visualization built on top of Matplotlib
- Plotly and Bokeh for interactive, browser-based visualizations
- Visualizing model evaluation metrics (ROC curves, confusion matrices) with plotting libraries
- Styling and theming options for consistent visualization across a project
- Exporting plots to file formats (PNG, SVG, PDF) for reports and presentations