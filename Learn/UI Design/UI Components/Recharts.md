# Recharts for Modern Web Development — Complete Mastery Guide

> **Accuracy Policy**: All behavioral claims about Recharts (animations, performance, rendering) are labeled `[Inference]` or `[Unverified]` where behavior is environment-dependent or not confirmed against a live codebase. API shapes follow official Recharts docs as of v2.x.

---

## Part 1 — Foundations

### What Is Recharts?

Recharts is a composable charting library for React built on top of SVG. It is not a general-purpose visualization framework — it is specifically designed to make common chart types (line, bar, area, pie, etc.) declarative and idiomatic within a React component tree.

The library was created because before Recharts, the dominant approach to charts in React apps was wrapping D3.js — which works but fights against React's declarative model. D3 uses imperative DOM mutations; React uses a virtual DOM and renders from state. Bridging the two requires lifecycle hacks, ref gymnastics, or abandoning React rendering for chart subtrees entirely.

Recharts solves this by taking D3's math utilities (scales, paths, arcs) and wrapping the *output* in React SVG components, so you write JSX and let React handle the DOM.

---

### Mental Model: The Three-Layer Cake

Think of a Recharts chart as three stacked layers:

```
┌─────────────────────────────────────────┐
│  Layer 3: React Components              │
│  <LineChart> <XAxis> <Tooltip>          │
│  You interact with this layer           │
├─────────────────────────────────────────┤
│  Layer 2: SVG Rendering                 │
│  <svg> <path> <g> <text> <rect>        │
│  Recharts generates this from your JSX  │
├─────────────────────────────────────────┤
│  Layer 1: D3 Math                       │
│  scaleBand(), scaleLinear(), arc()      │
│  Recharts uses this internally          │
└─────────────────────────────────────────┘
```

You only ever work at Layer 3. Recharts handles the translation down to SVG, using D3 for layout math. This is the core architectural bargain: you gain ergonomics, you lose fine-grained D3 control.

---

### Why SVG (Not Canvas)?

Recharts renders to SVG, not `<canvas>`. SVG nodes exist in the DOM, meaning:

- CSS styling works
- Browser DevTools can inspect individual elements
- Event handlers attach directly to shapes
- Accessibility attributes (ARIA) can be placed on elements
- But: performance degrades with thousands of DOM nodes [Inference — this is a general SVG characteristic, not benchmarked specifically against Recharts]

Canvas-based libraries (Chart.js, ECharts canvas mode) render to a pixel buffer — faster for large datasets, but you lose DOM introspectability and native event propagation.

**Rule of thumb**: SVG (Recharts) for ≤ ~2,000 data points and interactive/accessible charts. Canvas for dense real-time data or very large series.

---

### Recharts and D3: What's Borrowed

Recharts uses D3 internally for:

| D3 Utility | Used For |
|---|---|
| `d3-scale` | Converting data values to pixel positions |
| `d3-shape` | Generating SVG path strings for lines and areas |
| `d3-arc` | Pie and radial arc paths |
| `d3-interpolate` | Animation transitions |

Recharts does NOT expose D3's selection/join model. You cannot do `d3.select()` inside a Recharts tree (well, you can, but it's fighting the library).

---

### When to Use Recharts

✅ Use Recharts when:
- Your app is React-based
- Charts are interactive (hover, click, drill-down)
- You need tooltips, legends, and axes without custom code
- Design team wants charts to match the app's design system
- You're building dashboards, admin panels, analytics UIs
- Accessibility (ARIA) matters
- The data is modest in scale (< ~5,000 points per series)

---

### When NOT to Use Recharts

❌ Avoid Recharts when:
- You need large-scale data (10,000+ points) — consider ECharts or Victory with canvas
- You need WebGL-accelerated rendering — consider deck.gl, Observable Plot, or Vega
- You need geographic/map visualizations — consider Mapbox GL or Leaflet
- You need network graphs or force-directed layouts — consider Cytoscape.js or D3 directly
- You need a fully custom D3 visualization — just write D3 (with `useEffect` + `useRef`)
- You need chart-to-image export in a Node.js pipeline — consider Puppeteer + React DOM server rendering

---

### Architecture Overview

```
<ResponsiveContainer width="100%" height={400}>
  <LineChart data={data}>         ← Chart container (coordinate system)
    <CartesianGrid />              ← Visual grid
    <XAxis dataKey="date" />       ← Axis configuration
    <YAxis />
    <Tooltip />                    ← Interaction layer
    <Legend />
    <Line dataKey="revenue" />     ← Data series
  </LineChart>
</ResponsiveContainer>
```

The outer container (`LineChart`, `BarChart`, etc.) establishes:
- A coordinate system (Cartesian or polar)
- Layout dimensions
- The shared data array

Children read from this context and render themselves accordingly. This is why `XAxis` doesn't need you to pass `data` — it receives it from context.

---

### Advantages

- Declarative — charts look like JSX, not imperative instructions
- React lifecycle — state changes rerender charts naturally
- Composable — mix `Line` and `Bar` in one `ComposedChart`
- TypeScript support — typed props via `@types/recharts` (bundled since v2)
- Animation out of the box
- Active community and long maintenance history

### Disadvantages

- SVG performance ceiling — not suitable for high-frequency real-time data
- Customization depth — deeply custom visuals require `customizedComponent` patterns that get awkward
- Bundle size — Recharts is ~450KB minified, ~150KB gzipped [Unverified — check your bundler analysis for the actual footprint in your project]
- Some advanced chart types (candlestick, waterfall) require building from primitives
- The internal context system makes unit testing chart internals non-trivial

---

## Part 2 — Core Building Blocks

### ResponsiveContainer

`ResponsiveContainer` is a wrapper that observes its parent's dimensions using `ResizeObserver` [Inference — the specific browser API used internally is not confirmed in public docs] and passes `width` and `height` as props to its single chart child.

```tsx
import { ResponsiveContainer, LineChart } from 'recharts';

// ✅ Correct — fills parent width, fixed height
<div style={{ width: '100%', height: 300 }}>
  <ResponsiveContainer width="100%" height="100%">
    <LineChart data={data}>...</LineChart>
  </ResponsiveContainer>
</div>

// ✅ Also correct — aspect ratio mode
<ResponsiveContainer width="100%" aspect={16 / 9}>
  <LineChart data={data}>...</LineChart>
</ResponsiveContainer>

// ❌ Common mistake — parent has no height
<div style={{ width: '100%' }}>  {/* no height! */}
  <ResponsiveContainer height={300}>
    <LineChart data={data}>...</LineChart>
  </ResponsiveContainer>
</div>
```

**Critical Props**:

| Prop | Type | Purpose |
|---|---|---|
| `width` | `number \| string` | Fixed px or `"100%"` |
| `height` | `number \| string` | Fixed px, `"100%"`, or omit if using `aspect` |
| `aspect` | `number` | width/height ratio — overrides `height` |
| `minWidth` | `number` | Minimum width before chart clips |
| `minHeight` | `number` | Minimum height |
| `debounce` | `number` | ms to delay resize callbacks — useful for expensive charts |

**Performance note**: Without `debounce`, resize events trigger on every animation frame during window resize. For charts with many series, add `debounce={50}` [Inference — debounce reduces rerender frequency; actual threshold depends on your chart complexity].

---

### CartesianGrid

Renders horizontal and/or vertical gridlines behind chart data.

```tsx
// Minimal — shows both axes lines
<CartesianGrid />

// Production pattern — subtle grid
<CartesianGrid
  strokeDasharray="3 3"
  stroke="#e0e0e0"
  horizontal={true}
  vertical={false}
/>

// Custom grid lines at specific values
<CartesianGrid
  horizontalPoints={[100, 200, 300]}
  verticalPoints={[50, 150]}
/>
```

**Key Props**:

| Prop | Purpose |
|---|---|
| `strokeDasharray` | CSS dash pattern — `"3 3"` is the classic dashed line |
| `horizontal` | Show horizontal lines (default true) |
| `vertical` | Show vertical lines (default true) |
| `horizontalPoints` | Exact y-positions for lines (pixels) |
| `verticalPoints` | Exact x-positions for lines (pixels) |
| `fill` | Background fill for the grid area |

**Design note**: Horizontal-only grids with `strokeDasharray="4 4"` and a light gray stroke are the most common production pattern. Vertical gridlines frequently add visual noise.

---

### XAxis

Controls the bottom (or top) categorical or numeric axis.

```tsx
// Categorical axis (default)
<XAxis dataKey="month" />

// Numeric axis
<XAxis type="number" domain={[0, 100]} />

// Time axis
<XAxis
  dataKey="date"
  type="number"
  scale="time"
  domain={['auto', 'auto']}
  tickFormatter={(ts) => format(new Date(ts), 'MMM d')}
/>

// Rotated labels — common for many categories
<XAxis
  dataKey="category"
  angle={-45}
  textAnchor="end"
  height={60}
  interval={0}
/>
```

**Key Props**:

| Prop | Type | Purpose |
|---|---|---|
| `dataKey` | string | Which field from data array to use |
| `type` | `"category" \| "number"` | Axis type |
| `scale` | string | D3 scale: `"linear"`, `"log"`, `"time"`, `"band"`, `"point"` |
| `domain` | `[min, max]` | Explicit axis range — supports `"auto"`, `"dataMin"`, `"dataMax"` |
| `tickCount` | number | Approximate number of ticks |
| `tickFormatter` | function | Transform tick label text |
| `ticks` | array | Explicit tick values |
| `hide` | boolean | Hides axis completely |
| `allowDecimals` | boolean | Default true — set false for integer axes |
| `padding` | object | `{ left: 20, right: 20 }` — adds space at axis ends |
| `interval` | `number \| "preserveStart" \| "preserveEnd" \| "preserveStartEnd"` | Controls which ticks render |

---

### YAxis

Same API as XAxis but vertical. One common production pattern is dual Y-axes for biaxial charts:

```tsx
// Primary Y-axis (left)
<YAxis yAxisId="left" />

// Secondary Y-axis (right)
<YAxis yAxisId="right" orientation="right" />

// Each series references an axis
<Line yAxisId="left" dataKey="revenue" />
<Line yAxisId="right" dataKey="users" />
```

**Formatting tips**:

```tsx
// Currency
<YAxis tickFormatter={(value) => `$${(value / 1000).toFixed(0)}k`} />

// Percentage
<YAxis tickFormatter={(value) => `${value}%`} domain={[0, 100]} />

// Compact numbers
<YAxis tickFormatter={(value) =>
  new Intl.NumberFormat('en', { notation: 'compact' }).format(value)
} />
```

---

### ZAxis

Used only in `ScatterChart`. Controls the size (radius) of scatter dots.

```tsx
<ScatterChart>
  <ZAxis dataKey="magnitude" range={[20, 200]} name="Magnitude" />
  <Scatter data={data} />
</ScatterChart>
```

`range` maps data values to pixel area values — `[minSize, maxSize]` in square pixels.

---

### ReferenceLine

Draws a horizontal or vertical line at a specific value — useful for targets, thresholds, averages.

```tsx
// Horizontal threshold
<ReferenceLine y={1000} stroke="red" strokeDasharray="4 2" label="Target" />

// Vertical marker (time or category)
<ReferenceLine x="2024-01" stroke="#8884d8" label="Launch" />

// Custom label component
<ReferenceLine
  y={averageRevenue}
  stroke="#ff7300"
  label={<CustomLabel value={averageRevenue} />}
/>
```

**Key Props**: `x`, `y`, `stroke`, `strokeDasharray`, `strokeWidth`, `label`, `labelPosition`, `isFront` (renders above chart data)

---

### ReferenceArea

Shades a rectangular region between two axis values — useful for highlighting periods (weekends, outages, campaigns).

```tsx
<ReferenceArea
  x1="2024-01"
  x2="2024-03"
  y1={0}
  y2={5000}
  fill="#8884d8"
  fillOpacity={0.1}
  label="Q1 Campaign"
/>
```

For dynamic highlighting (e.g., user-selected zoom region), pair with `useState`:

```tsx
const [refArea, setRefArea] = useState<{ x1?: string; x2?: string }>({});

// On mouse events in the chart:
onMouseDown={(e) => setRefArea({ x1: e.activeLabel })}
onMouseMove={(e) => setRefArea((prev) => ({ ...prev, x2: e.activeLabel }))}
onMouseUp={handleZoom}

// In the chart:
{refArea.x1 && refArea.x2 && (
  <ReferenceArea x1={refArea.x1} x2={refArea.x2} strokeOpacity={0.3} />
)}
```

---

### ReferenceDot

Marks a specific (x, y) coordinate with a dot — useful for anomalies, events, record values.

```tsx
<ReferenceDot
  x="2024-06"
  y={9800}
  r={8}
  fill="red"
  stroke="white"
  strokeWidth={2}
  label={{ value: 'Record', position: 'top' }}
/>
```

---

### Brush

Adds a scrollable/zoomable selector below the chart — the user can drag handles to focus on a data window.

```tsx
<LineChart data={data}>
  <XAxis dataKey="date" />
  <YAxis />
  <Line dataKey="value" />
  <Brush
    dataKey="date"
    height={30}
    stroke="#8884d8"
    startIndex={data.length - 30}  // Show last 30 points by default
    endIndex={data.length - 1}
  />
</LineChart>
```

**Key Props**:

| Prop | Purpose |
|---|---|
| `dataKey` | What to display in the brush preview |
| `startIndex` | Initial start position (array index) |
| `endIndex` | Initial end position (array index) |
| `height` | Brush area height in px |
| `onChange` | Callback `{ startIndex, endIndex }` when user adjusts |
| `gap` | Minimum pixels between ticks in brush |
| `travellerWidth` | Handle width in px |

**Performance warning**: Brush renders a miniature copy of the chart inside it. For large datasets, this doubles rendering cost. Consider setting `tickFormatter` on the brush's `<XAxis>` equivalent or using a simple `Brush` without a preview. [Inference — performance impact scales with dataset size; exact thresholds are environment-dependent]

---

## Part 3 — Every Chart Type

### LineChart

**Purpose**: Show trends over time or ordered categories. The most common chart in any analytics application.

**Best use cases**:
- Revenue over time
- Active users over time
- System metrics (CPU, memory) over time
- Any continuous quantitative trend

**When NOT to use**:
- Comparing parts of a whole (use Pie/Bar)
- Unordered categories (use Bar)
- More than 6–8 series (becomes unreadable)

**Production example**:

```tsx
import {
  LineChart, Line, XAxis, YAxis, CartesianGrid,
  Tooltip, Legend, ResponsiveContainer
} from 'recharts';
import { format, parseISO } from 'date-fns';

interface RevenueDataPoint {
  date: string;   // ISO date string
  mrr: number;
  arr: number;
}

interface RevenueChartProps {
  data: RevenueDataPoint[];
}

const COLORS = {
  mrr: '#6366f1',
  arr: '#10b981',
};

export function RevenueChart({ data }: RevenueChartProps) {
  return (
    <ResponsiveContainer width="100%" height={320}>
      <LineChart
        data={data}
        margin={{ top: 8, right: 16, left: 0, bottom: 8 }}
      >
        <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" vertical={false} />
        <XAxis
          dataKey="date"
          tickFormatter={(d) => format(parseISO(d), 'MMM yy')}
          tick={{ fontSize: 12, fill: '#6b7280' }}
          axisLine={false}
          tickLine={false}
        />
        <YAxis
          tickFormatter={(v) =>
            new Intl.NumberFormat('en', { notation: 'compact', style: 'currency', currency: 'USD' }).format(v)
          }
          tick={{ fontSize: 12, fill: '#6b7280' }}
          axisLine={false}
          tickLine={false}
          width={64}
        />
        <Tooltip
          formatter={(value: number, name: string) => [
            new Intl.NumberFormat('en', { style: 'currency', currency: 'USD' }).format(value),
            name.toUpperCase(),
          ]}
          labelFormatter={(label) => format(parseISO(label), 'MMMM yyyy')}
          contentStyle={{
            borderRadius: 8,
            border: '1px solid #e5e7eb',
            boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)',
          }}
        />
        <Legend />
        <Line
          type="monotone"
          dataKey="mrr"
          stroke={COLORS.mrr}
          strokeWidth={2}
          dot={false}
          activeDot={{ r: 5, strokeWidth: 0 }}
        />
        <Line
          type="monotone"
          dataKey="arr"
          stroke={COLORS.arr}
          strokeWidth={2}
          dot={false}
          activeDot={{ r: 5, strokeWidth: 0 }}
        />
      </LineChart>
    </ResponsiveContainer>
  );
}
```

**Advanced props for `Line`**:

| Prop | Type | Purpose |
|---|---|---|
| `type` | string | Curve interpolation: `"monotone"`, `"linear"`, `"step"`, `"basis"`, `"cardinal"` |
| `dot` | bool/object/component | Data point dots — `false` for performance |
| `activeDot` | object/component | Dot shown on hover |
| `strokeDasharray` | string | Dashed lines for secondary series |
| `connectNulls` | boolean | Connect across null/undefined values |
| `animationDuration` | number | ms for enter animation |

---

### AreaChart

**Purpose**: Same as LineChart but fills the area under the line — emphasizes magnitude and volume.

**Best use cases**:
- Cumulative values
- Stacked composition (revenue by segment)
- Volume data (pageviews, sign-ups)

**Stacked area — most common production pattern**:

```tsx
<AreaChart data={data}>
  <defs>
    <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
      <stop offset="5%" stopColor="#6366f1" stopOpacity={0.15} />
      <stop offset="95%" stopColor="#6366f1" stopOpacity={0} />
    </linearGradient>
  </defs>
  <XAxis dataKey="date" />
  <YAxis />
  <Tooltip />
  <Area
    type="monotone"
    dataKey="revenue"
    stroke="#6366f1"
    fill="url(#colorRevenue)"
    strokeWidth={2}
    stackId="1"
  />
  <Area
    type="monotone"
    dataKey="costs"
    stroke="#ef4444"
    fill="url(#colorCosts)"
    strokeWidth={2}
    stackId="1"
  />
</AreaChart>
```

**Key `Area` props**:

| Prop | Purpose |
|---|---|
| `stackId` | Set same value on multiple Areas to stack them |
| `fill` | Fill color or gradient reference |
| `fillOpacity` | Transparency (0.1–0.3 typical for multi-series) |
| `baseValue` | Custom baseline (default: 0 or axis min) |

---

### BarChart

**Purpose**: Compare discrete categories or time periods.

**Best use cases**:
- Monthly/quarterly comparisons
- Category breakdowns
- Distribution histograms (with numeric x-axis)
- Ranked lists

**Grouped vs stacked**:

```tsx
// Grouped bars (default)
<BarChart data={data} barCategoryGap="20%">
  <Bar dataKey="q1" fill="#6366f1" />
  <Bar dataKey="q2" fill="#10b981" />
</BarChart>

// Stacked bars
<BarChart data={data}>
  <Bar dataKey="organic" fill="#6366f1" stackId="a" />
  <Bar dataKey="paid" fill="#10b981" stackId="a" />
  <Bar dataKey="direct" fill="#f59e0b" stackId="a" />
</BarChart>
```

**Horizontal bar chart** (good for ranked lists):

```tsx
<BarChart layout="vertical" data={data}>
  <XAxis type="number" />
  <YAxis type="category" dataKey="name" width={120} />
  <Bar dataKey="value" fill="#6366f1">
    <LabelList dataKey="value" position="right" />
  </Bar>
</BarChart>
```

**Key `Bar` props**:

| Prop | Purpose |
|---|---|
| `stackId` | Groups bars into a stack |
| `barSize` | Fixed bar width in px |
| `maxBarSize` | Caps bar width for sparse data |
| `radius` | Rounded corners — `[4, 4, 0, 0]` for top-only rounding |
| `background` | Renders a background track behind each bar |

---

### PieChart

**Purpose**: Show part-to-whole relationships. Misused more than any other chart type.

**Best use cases**:
- 2–4 categories where the contrast is obvious
- Showing a single "share" metric (e.g., market share)

**When NOT to use**:
- More than 5–6 slices (use bar chart)
- When precise comparison matters (humans are bad at comparing angles)
- When values are close together

```tsx
import { PieChart, Pie, Cell, Tooltip, Legend } from 'recharts';

const COLORS = ['#6366f1', '#10b981', '#f59e0b', '#ef4444'];

<PieChart width={400} height={300}>
  <Pie
    data={data}
    cx="50%"
    cy="50%"
    outerRadius={100}
    innerRadius={60}   // Donut hole — innerRadius > 0 = donut chart
    dataKey="value"
    nameKey="name"
    paddingAngle={2}
    label={({ name, percent }) =>
      `${name}: ${(percent * 100).toFixed(0)}%`
    }
  >
    {data.map((_, index) => (
      <Cell
        key={`cell-${index}`}
        fill={COLORS[index % COLORS.length]}
      />
    ))}
  </Pie>
  <Tooltip formatter={(value: number) => [`${value}`, 'Count']} />
  <Legend />
</PieChart>
```

---

### RadarChart

**Purpose**: Compare entities across multiple quantitative dimensions simultaneously.

**Best use cases**:
- Performance reviews (5–8 skill dimensions)
- Product comparison across features
- Player stats in sports analytics
- Risk assessment with multiple factors

```tsx
import { RadarChart, PolarGrid, PolarAngleAxis, PolarRadiusAxis, Radar } from 'recharts';

const data = [
  { subject: 'Performance', A: 120, B: 110 },
  { subject: 'Security', A: 98, B: 130 },
  { subject: 'Reliability', A: 86, B: 130 },
  { subject: 'Scalability', A: 99, B: 100 },
  { subject: 'Usability', A: 85, B: 90 },
];

<RadarChart cx={250} cy={250} outerRadius={150} width={500} height={500} data={data}>
  <PolarGrid />
  <PolarAngleAxis dataKey="subject" />
  <PolarRadiusAxis angle={30} domain={[0, 150]} />
  <Radar name="Product A" dataKey="A" stroke="#6366f1" fill="#6366f1" fillOpacity={0.2} />
  <Radar name="Product B" dataKey="B" stroke="#10b981" fill="#10b981" fillOpacity={0.2} />
  <Legend />
</RadarChart>
```

---

### ScatterChart

**Purpose**: Show correlation or distribution between two numeric variables.

**Best use cases**:
- Correlation analysis (revenue vs. spend)
- Outlier detection
- Cluster visualization
- Bivariate distribution

```tsx
import { ScatterChart, Scatter, XAxis, YAxis, ZAxis, CartesianGrid, Tooltip } from 'recharts';

interface DataPoint {
  x: number;
  y: number;
  z: number;  // bubble size
  name: string;
}

<ScatterChart width={500} height={400}>
  <CartesianGrid />
  <XAxis type="number" dataKey="x" name="Spend" unit="k" />
  <YAxis type="number" dataKey="y" name="Revenue" unit="k" />
  <ZAxis type="number" dataKey="z" range={[40, 400]} name="Customers" />
  <Tooltip cursor={{ strokeDasharray: '3 3' }} />
  <Scatter data={data} fill="#6366f1" />
</ScatterChart>
```

---

### RadialBarChart

**Purpose**: Circular progress bars — good for KPI gauges and goal tracking.

```tsx
<RadialBarChart
  width={400}
  height={400}
  innerRadius="20%"
  outerRadius="90%"
  data={[
    { name: 'Revenue', value: 78, fill: '#6366f1' },
    { name: 'Signups', value: 92, fill: '#10b981' },
    { name: 'Retention', value: 65, fill: '#f59e0b' },
  ]}
  startAngle={180}
  endAngle={0}
>
  <RadialBar minAngle={15} background dataKey="value" />
  <Legend />
  <Tooltip />
</RadialBarChart>
```

---

### FunnelChart

**Purpose**: Show progressive drop-off through stages of a process.

```tsx
import { FunnelChart, Funnel, LabelList } from 'recharts';

const data = [
  { value: 10000, name: 'Visitors', fill: '#6366f1' },
  { value: 3200,  name: 'Sign-ups', fill: '#8b5cf6' },
  { value: 1800,  name: 'Activated', fill: '#a78bfa' },
  { value: 800,   name: 'Paying', fill: '#c4b5fd' },
];

<FunnelChart width={400} height={300}>
  <Funnel dataKey="value" data={data} isAnimationActive>
    <LabelList position="right" fill="#111" stroke="none" dataKey="name" />
  </Funnel>
  <Tooltip />
</FunnelChart>
```

---

### Treemap

**Purpose**: Show hierarchical data with proportional area.

**Best use cases**:
- Disk/memory usage breakdown
- Revenue by category and subcategory
- Portfolio allocation

```tsx
import { Treemap } from 'recharts';

const data = [
  {
    name: 'Product',
    children: [
      { name: 'Engineering', size: 6500 },
      { name: 'Design', size: 2400 },
      { name: 'PM', size: 1200 },
    ],
  },
  {
    name: 'Sales',
    children: [
      { name: 'Enterprise', size: 4200 },
      { name: 'SMB', size: 2800 },
    ],
  },
];

<Treemap
  width={400}
  height={300}
  data={data}
  dataKey="size"
  ratio={4 / 3}
  stroke="#fff"
  fill="#6366f1"
/>
```

---

### ComposedChart

**Purpose**: Combine multiple chart types in one coordinate system.

**Most common use**: Bars for absolute values + line for a rate/trend.

```tsx
import { ComposedChart, Bar, Line, Area, XAxis, YAxis } from 'recharts';

<ComposedChart data={data}>
  <CartesianGrid strokeDasharray="3 3" vertical={false} />
  <XAxis dataKey="month" />
  <YAxis yAxisId="left" />
  <YAxis yAxisId="right" orientation="right" tickFormatter={(v) => `${v}%`} />
  <Tooltip />
  <Legend />
  <Bar yAxisId="left" dataKey="revenue" fill="#6366f1" radius={[4, 4, 0, 0]} />
  <Line
    yAxisId="right"
    type="monotone"
    dataKey="growthRate"
    stroke="#ef4444"
    strokeWidth={2}
    dot={false}
  />
</ComposedChart>
```

---

## Part 4 — Graph Elements

### Line

The `<Line>` component renders a connected path through data points.

**Curve types** (`type` prop):
- `"linear"` — straight segments between points
- `"monotone"` — smooth curve that never overshoots values (most common for financial data)
- `"step"` / `"stepBefore"` / `"stepAfter"` — staircase — good for discrete state changes
- `"basis"` — B-spline, very smooth but can overshoot
- `"cardinal"` — tension-controlled smooth curve

**Custom dot rendering**:

```tsx
const CustomDot = (props: any) => {
  const { cx, cy, payload } = props;
  if (payload.isAnomaly) {
    return (
      <svg x={cx - 8} y={cy - 8} width={16} height={16}>
        <circle cx={8} cy={8} r={7} fill="#ef4444" stroke="white" strokeWidth={2} />
        <text x={8} y={12} textAnchor="middle" fill="white" fontSize={10}>!</text>
      </svg>
    );
  }
  return <circle cx={cx} cy={cy} r={3} fill="#6366f1" />;
};

<Line dataKey="value" dot={<CustomDot />} activeDot={false} />
```

---

### Area

Extends `Line` with fill. The fill area is defined between the line and a baseline (`baseValue`).

**SVG gradient fills** (production pattern):

```tsx
// Must be defined inside <defs> within the chart SVG
<defs>
  <linearGradient id="gradient1" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0%" stopColor="#6366f1" stopOpacity={0.4} />
    <stop offset="100%" stopColor="#6366f1" stopOpacity={0} />
  </linearGradient>
</defs>

<Area
  type="monotone"
  dataKey="sessions"
  stroke="#6366f1"
  strokeWidth={2}
  fill="url(#gradient1)"
/>
```

**Negative value areas** (profit/loss):

```tsx
<Area
  type="monotone"
  dataKey="profit"
  stroke="#10b981"
  fill="#10b981"
  fillOpacity={0.1}
  baseValue={0}
/>
```

---

### Bar

Key advanced patterns:

**Dynamic cell coloring** (color each bar individually):

```tsx
<Bar dataKey="value">
  {data.map((entry, index) => (
    <Cell
      key={`cell-${index}`}
      fill={entry.value > 0 ? '#10b981' : '#ef4444'}
    />
  ))}
</Bar>
```

**Custom bar shapes**:

```tsx
const RoundedBar = (props: any) => {
  const { x, y, width, height, fill } = props;
  const radius = 4;
  return (
    <path
      d={`M${x + radius},${y}
          h${width - 2 * radius}
          a${radius},${radius} 0 0 1 ${radius},${radius}
          v${height - radius}
          h${-width}
          v${-(height - radius)}
          a${radius},${radius} 0 0 1 ${radius},${-radius}
          z`}
      fill={fill}
    />
  );
};

<Bar dataKey="revenue" shape={<RoundedBar />} />
```

---

### Cell

`Cell` renders inside `Pie`, `Bar`, `Funnel`, or `RadialBar` to apply per-item styling:

```tsx
// Inside a Pie
<Pie dataKey="value">
  {data.map((entry, index) => (
    <Cell key={index} fill={colorScale(entry.value)} />
  ))}
</Pie>
```

---

### Scatter

Renders individual data points as dots. Supports custom shapes:

```tsx
const StarShape = (props: any) => {
  const { cx, cy } = props;
  // Return an SVG star centered at cx, cy
  return <polygon points={starPath(cx, cy, 8, 5)} fill="#f59e0b" />;
};

<Scatter data={data} shape={<StarShape />} />
```

---

## Part 5 — Labels and Annotation System

### Label

Places a single label on a chart element.

```tsx
// On a ReferenceLine
<ReferenceLine y={target} label={{ value: `Target: ${target}`, position: 'insideTopRight' }} />

// Label positions: 'top', 'bottom', 'left', 'right',
// 'insideTop', 'insideBottom', 'insideLeft', 'insideRight',
// 'insideTopLeft', 'insideTopRight', 'insideBottomLeft', 'insideBottomRight',
// 'center', 'outside'
```

---

### LabelList

Renders labels for every data point in a series. Essential for bar charts where exact values matter:

```tsx
<Bar dataKey="revenue">
  <LabelList
    dataKey="revenue"
    position="top"
    formatter={(value: number) =>
      new Intl.NumberFormat('en', { notation: 'compact', style: 'currency', currency: 'USD' }).format(value)
    }
    style={{ fontSize: 11, fill: '#6b7280' }}
  />
</Bar>
```

**Custom label component**:

```tsx
const CustomBarLabel = (props: any) => {
  const { x, y, width, value } = props;
  return (
    <text
      x={x + width / 2}
      y={y - 6}
      textAnchor="middle"
      fill="#374151"
      fontSize={11}
    >
      {value > 1000 ? `${(value / 1000).toFixed(1)}k` : value}
    </text>
  );
};

<Bar dataKey="count">
  <LabelList content={<CustomBarLabel />} />
</Bar>
```

**Collision warning**: LabelList does not handle collision detection [Unverified — no confirmed built-in collision avoidance in Recharts v2 docs]. For dense data, use `position="inside"` or hide labels below a threshold:

```tsx
<LabelList
  dataKey="value"
  content={(props: any) => {
    const { width } = props;
    if (width < 40) return null;  // Don't render if bar too narrow
    return <CustomBarLabel {...props} />;
  }}
/>
```

---

### Text

`Text` is a low-level SVG text component with overflow handling. Mainly used when building fully custom chart components.

```tsx
import { Text } from 'recharts';

<Text
  x={200}
  y={150}
  textAnchor="middle"
  verticalAnchor="middle"
  width={100}       // Enables word wrapping
>
  This text wraps inside 100px
</Text>
```
## Part 6 — Tooltip System

### Default Tooltip

The simplest useful tooltip requires zero configuration:

```tsx
<Tooltip />
```

This auto-generates a tooltip showing all active series values for the hovered x-position.

---

### Tooltip Props Reference

| Prop | Type | Purpose |
|---|---|---|
| `formatter` | `(value, name, props) => [value, name]` | Transform displayed values |
| `labelFormatter` | `(label) => string` | Transform the header label |
| `contentStyle` | object | CSS for the tooltip box |
| `itemStyle` | object | CSS for each line item |
| `labelStyle` | object | CSS for the header |
| `cursor` | bool/object | The crosshair line — `false` to disable |
| `active` | bool | Manual control of visibility |
| `position` | `{x, y}` | Fixed position |
| `offset` | number | px offset from cursor |
| `isAnimationActive` | bool | Default true — disable for real-time charts |
| `filterNull` | bool | Hide null values from tooltip |
| `separator` | string | Between label and value |

---

### Custom Tooltip Component

This is the production pattern — nearly every non-trivial dashboard needs a custom tooltip:

```tsx
import { TooltipProps } from 'recharts';
import { ValueType, NameType } from 'recharts/types/component/DefaultTooltipContent';

interface CustomTooltipProps extends TooltipProps<ValueType, NameType> {
  currency?: string;
}

export function CustomTooltip({ active, payload, label, currency = 'USD' }: CustomTooltipProps) {
  if (!active || !payload?.length) return null;

  const fmt = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency,
    minimumFractionDigits: 0,
  });

  return (
    <div className="bg-white border border-gray-200 rounded-lg shadow-lg p-3 min-w-40">
      <p className="text-xs text-gray-500 mb-2 font-medium">{label}</p>
      {payload.map((entry) => (
        <div key={entry.dataKey as string} className="flex items-center gap-2 text-sm">
          <span
            className="w-2.5 h-2.5 rounded-full flex-shrink-0"
            style={{ backgroundColor: entry.color }}
          />
          <span className="text-gray-600 capitalize">
            {String(entry.name).replace(/_/g, ' ')}:
          </span>
          <span className="font-semibold text-gray-900 ml-auto">
            {typeof entry.value === 'number' ? fmt.format(entry.value) : entry.value}
          </span>
        </div>
      ))}
    </div>
  );
}

// Usage:
<Tooltip content={<CustomTooltip currency="USD" />} />
```

---

### Tooltip Theming

**Dark theme tooltip**:

```tsx
<Tooltip
  contentStyle={{
    backgroundColor: '#1f2937',
    border: '1px solid #374151',
    borderRadius: 8,
    color: '#f9fafb',
  }}
  itemStyle={{ color: '#e5e7eb' }}
  labelStyle={{ color: '#9ca3af', marginBottom: 4 }}
/>
```

**No border / glassmorphism**:

```tsx
<Tooltip
  contentStyle={{
    backgroundColor: 'rgba(255, 255, 255, 0.9)',
    backdropFilter: 'blur(8px)',
    border: 'none',
    borderRadius: 12,
    boxShadow: '0 20px 25px -5px rgb(0 0 0 / 0.1)',
  }}
/>
```

---

### Shared Tooltip Across Synchronized Charts

When using `syncId` to link multiple charts (see Part 17), a single tooltip hover highlights the same x-position across all charts:

```tsx
<LineChart data={revenueData} syncId="dashboard">
  <Tooltip />
  ...
</LineChart>

<LineChart data={usersData} syncId="dashboard">
  <Tooltip />
  ...
</LineChart>
```

---

### Mobile Tooltip Optimization

On touch devices, hover tooltips don't fire. Use `trigger="click"` as a workaround [Unverified — `trigger` prop behavior on all mobile browsers is not confirmed]:

```tsx
<Tooltip trigger="click" />
```

For production mobile dashboards, consider:
- Fixed-position tooltip at top of chart (never overlaps data)
- Tap-to-show detail pattern using `onClick` on the chart container
- Cards instead of tooltips for primary data display

---

### Accessibility for Tooltips

The default Recharts tooltip is not accessible to screen readers [Inference — Recharts generates SVG DOM nodes that may not have appropriate ARIA semantics by default; verify with your screen reader target]. For accessible tooltips:

```tsx
// Append aria-live region to page
const [announcement, setAnnouncement] = useState('');

<Tooltip
  content={(props) => {
    if (props.active && props.payload?.length) {
      const text = props.payload
        .map(p => `${p.name}: ${p.value}`)
        .join(', ');
      setAnnouncement(`${props.label}: ${text}`);
    }
    return <CustomTooltip {...props} />;
  }}
/>

// Offscreen announcer
<div
  role="status"
  aria-live="polite"
  aria-atomic="true"
  style={{ position: 'absolute', left: -9999, top: -9999 }}
>
  {announcement}
</div>
```

---

## Part 7 — Legend System

### Default Legend

```tsx
<Legend />                          // Horizontal, below chart
<Legend layout="vertical" />        // Vertical
<Legend verticalAlign="top" />      // Above chart
<Legend align="right" />            // Right-aligned
```

**Legend `wrapperStyle`** — controls the container div:

```tsx
<Legend
  wrapperStyle={{ paddingTop: 16, fontSize: 12 }}
/>
```

---

### Custom Legend Component

```tsx
interface LegendItem {
  color: string;
  name: string;
  value?: number;
}

function CustomLegend({ payload }: { payload?: LegendItem[] }) {
  if (!payload) return null;
  return (
    <div className="flex flex-wrap gap-4 justify-center mt-4">
      {payload.map((entry, index) => (
        <div key={index} className="flex items-center gap-1.5 text-sm text-gray-600">
          <span
            className="w-3 h-3 rounded-sm"
            style={{ backgroundColor: entry.color }}
          />
          {entry.name}
        </div>
      ))}
    </div>
  );
}

<Legend content={<CustomLegend />} />
```

---

### Interactive Legend — Toggle Series

This is the most requested Recharts pattern: click legend to show/hide series.

```tsx
import { useState } from 'react';

function InteractiveChart({ data }: { data: DataPoint[] }) {
  const [hiddenKeys, setHiddenKeys] = useState<Set<string>>(new Set());

  const toggleKey = (key: string) => {
    setHiddenKeys(prev => {
      const next = new Set(prev);
      next.has(key) ? next.delete(key) : next.add(key);
      return next;
    });
  };

  const series: Array<{ key: string; color: string; label: string }> = [
    { key: 'revenue', color: '#6366f1', label: 'Revenue' },
    { key: 'expenses', color: '#ef4444', label: 'Expenses' },
    { key: 'profit', color: '#10b981', label: 'Profit' },
  ];

  return (
    <>
      {/* Custom legend above chart */}
      <div className="flex gap-4 mb-4">
        {series.map(({ key, color, label }) => (
          <button
            key={key}
            onClick={() => toggleKey(key)}
            className={`flex items-center gap-1.5 text-sm transition-opacity
              ${hiddenKeys.has(key) ? 'opacity-30' : 'opacity-100'}`}
          >
            <span
              className="w-3 h-1.5 rounded-full"
              style={{ backgroundColor: color }}
            />
            {label}
          </button>
        ))}
      </div>

      <ResponsiveContainer width="100%" height={300}>
        <LineChart data={data}>
          <XAxis dataKey="month" />
          <YAxis />
          <Tooltip />
          {series.map(({ key, color }) => (
            <Line
              key={key}
              dataKey={key}
              stroke={color}
              strokeWidth={2}
              dot={false}
              hide={hiddenKeys.has(key)}
            />
          ))}
        </LineChart>
      </ResponsiveContainer>
    </>
  );
}
```

---

### Highlighting Series on Legend Hover

```tsx
const [activeKey, setActiveKey] = useState<string | null>(null);

// In series components:
<Line
  dataKey="revenue"
  stroke="#6366f1"
  strokeWidth={activeKey === null || activeKey === 'revenue' ? 2 : 1}
  strokeOpacity={activeKey === null || activeKey === 'revenue' ? 1 : 0.2}
/>

// Custom legend with hover:
function HoverLegend({ payload, onHover }: any) {
  return (
    <div className="flex gap-4">
      {payload?.map((entry: any) => (
        <span
          key={entry.dataKey}
          onMouseEnter={() => onHover(entry.dataKey)}
          onMouseLeave={() => onHover(null)}
          style={{ cursor: 'pointer', color: entry.color }}
        >
          {entry.value}
        </span>
      ))}
    </div>
  );
}

<Legend content={<HoverLegend onHover={setActiveKey} />} />
```

---

## Part 8 — Interactivity

### Hover States and `onMouseEnter`/`onMouseLeave`

Chart-level events:

```tsx
<LineChart
  onMouseMove={(state) => {
    if (state.isTooltipActive) {
      // state.activePayload — array of series values at cursor
      // state.activeLabel — the x-axis value at cursor
      // state.activeCoordinate — { x, y } pixel position
    }
  }}
  onMouseLeave={() => {
    // Reset hover state
  }}
>
```

Series-level events:

```tsx
<Bar
  dataKey="revenue"
  onMouseEnter={(data, index) => {
    // data: the full data row
    // index: position in data array
    setHoveredBar(index);
  }}
  onMouseLeave={() => setHoveredBar(null)}
/>
```

---

### Active Shape — Pie Chart

The `activeShape` pattern on `PieChart` is a classic UX pattern for showing detail on hover:

```tsx
const renderActiveShape = (props: any) => {
  const {
    cx, cy, innerRadius, outerRadius, startAngle, endAngle,
    fill, payload, percent, value
  } = props;

  return (
    <g>
      <text x={cx} y={cy - 8} textAnchor="middle" fill="#111" fontSize={14} fontWeight={600}>
        {payload.name}
      </text>
      <text x={cx} y={cy + 16} textAnchor="middle" fill="#6b7280" fontSize={12}>
        {`${(percent * 100).toFixed(1)}%`}
      </text>
      <Sector
        cx={cx}
        cy={cy}
        innerRadius={innerRadius}
        outerRadius={outerRadius + 8}
        startAngle={startAngle}
        endAngle={endAngle}
        fill={fill}
      />
      <Sector
        cx={cx}
        cy={cy}
        innerRadius={outerRadius + 12}
        outerRadius={outerRadius + 16}
        startAngle={startAngle}
        endAngle={endAngle}
        fill={fill}
      />
    </g>
  );
};

function DonutChart({ data }: { data: DataPoint[] }) {
  const [activeIndex, setActiveIndex] = useState(0);

  return (
    <PieChart width={400} height={300}>
      <Pie
        data={data}
        cx="50%"
        cy="50%"
        innerRadius={60}
        outerRadius={90}
        dataKey="value"
        activeIndex={activeIndex}
        activeShape={renderActiveShape}
        onMouseEnter={(_, index) => setActiveIndex(index)}
      >
        {data.map((_, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} />)}
      </Pie>
    </PieChart>
  );
}
```

---

### Click Handling — Drill-Down Pattern

```tsx
interface DrillDownState {
  level: 'region' | 'country' | 'city';
  filter: string | null;
}

function DrillDownChart() {
  const [drill, setDrill] = useState<DrillDownState>({ level: 'region', filter: null });
  const data = useChartData(drill);  // Hook that fetches based on drill state

  const handleBarClick = (data: any) => {
    if (drill.level === 'region') {
      setDrill({ level: 'country', filter: data.name });
    } else if (drill.level === 'country') {
      setDrill({ level: 'city', filter: data.name });
    }
  };

  return (
    <>
      {drill.filter && (
        <button onClick={() => setDrill({ level: 'region', filter: null })}>
          ← Back to Regions
        </button>
      )}
      <BarChart data={data} onClick={handleBarClick}>
        <Bar dataKey="revenue" cursor="pointer" />
      </BarChart>
    </>
  );
}
```

---

### Cross-Filtering Dashboard

Cross-filtering means clicking one chart filters data in all other charts. Pattern:

```tsx
interface Filter {
  region?: string;
  period?: string;
  segment?: string;
}

function Dashboard() {
  const [filter, setFilter] = useState<Filter>({});
  const rawData = useRawData();  // All data
  const filtered = useMemo(() => applyFilters(rawData, filter), [rawData, filter]);

  return (
    <div className="grid grid-cols-2 gap-4">
      <RegionBarChart
        data={filtered.byRegion}
        onBarClick={(region) =>
          setFilter(f => f.region === region ? { ...f, region: undefined } : { ...f, region })
        }
        activeFilter={filter.region}
      />
      <TimelineChart
        data={filtered.byPeriod}
        onSegmentClick={(period) => setFilter(f => ({ ...f, period }))}
      />
      <SegmentPieChart
        data={filtered.bySegment}
        onSliceClick={(segment) => setFilter(f => ({ ...f, segment }))}
      />
      <KPIMetrics data={filtered.kpis} />
    </div>
  );
}
```

---

## Part 9 — Responsive Design

### The ResponsiveContainer Contract

`ResponsiveContainer` **requires** its parent to have a defined height. It measures the parent and passes those dimensions to the chart.

**Common failures**:

```tsx
// ❌ BROKEN: flexbox parent has no height
<div style={{ display: 'flex' }}>
  <ResponsiveContainer height={300}>...</ResponsiveContainer>
</div>

// ✅ FIX: explicit height on parent
<div style={{ display: 'flex', height: 300 }}>
  <ResponsiveContainer width="100%" height="100%">...</ResponsiveContainer>
</div>

// ❌ BROKEN: grid parent, height not set
<div style={{ display: 'grid' }}>
  <ResponsiveContainer height="100%">...</ResponsiveContainer>
</div>

// ✅ FIX
<div style={{ display: 'grid', gridTemplateRows: '300px' }}>
  <ResponsiveContainer width="100%" height="100%">...</ResponsiveContainer>
</div>
```

---

### Aspect Ratio Mode

```tsx
// 16:9 — good for full-width dashboard panels
<ResponsiveContainer width="100%" aspect={16 / 9}>
  <LineChart>...</LineChart>
</ResponsiveContainer>

// 2:1 — compact panel
<ResponsiveContainer width="100%" aspect={2}>
  <BarChart>...</BarChart>
</ResponsiveContainer>
```

---

### Mobile-Adaptive Chart Components

```tsx
function useBreakpoint() {
  const [width, setWidth] = useState(window.innerWidth);
  useEffect(() => {
    const handler = () => setWidth(window.innerWidth);
    window.addEventListener('resize', handler);
    return () => window.removeEventListener('resize', handler);
  }, []);
  return { isMobile: width < 640, isTablet: width < 1024 };
}

function AdaptiveChart({ data }: { data: DataPoint[] }) {
  const { isMobile, isTablet } = useBreakpoint();

  return (
    <ResponsiveContainer width="100%" height={isMobile ? 200 : 320}>
      <LineChart
        data={data}
        margin={isMobile
          ? { top: 4, right: 8, left: 0, bottom: 4 }
          : { top: 8, right: 24, left: 8, bottom: 8 }
        }
      >
        <XAxis
          dataKey="date"
          tickFormatter={isMobile
            ? (d) => format(parseISO(d), 'MM/dd')
            : (d) => format(parseISO(d), 'MMM d, yyyy')
          }
          interval={isMobile ? 'preserveStartEnd' : 0}
          tick={{ fontSize: isMobile ? 10 : 12 }}
        />
        <YAxis hide={isMobile} />
        <Tooltip />
        <Line dataKey="value" dot={false} />
      </LineChart>
    </ResponsiveContainer>
  );
}
```

---

### Dashboard Grid Layout

```tsx
// CSS Grid dashboard — responsive at different breakpoints
.dashboard-grid {
  display: grid;
  gap: 1rem;
  grid-template-columns: 1fr;
}

@media (min-width: 768px) {
  .dashboard-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (min-width: 1280px) {
  .dashboard-grid {
    grid-template-columns: repeat(3, 1fr);
  }
}

.chart-panel {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 1px 3px rgb(0 0 0 / 0.1);
}

.chart-panel--wide {
  grid-column: span 2;
}
```

---

### Common Responsive Pitfalls

**1. Chart renders at 0x0 on initial mount** [Inference — this can occur when the parent hasn't finished layout before the chart mounts]:

```tsx
// Workaround: defer rendering
const [mounted, setMounted] = useState(false);
useEffect(() => setMounted(true), []);
if (!mounted) return <div style={{ height: 300 }} />;
```

**2. Tooltip overflows the viewport on mobile**: Use `position={{ x: 20, y: 20 }}` or a custom tooltip that adjusts its position:

```tsx
<Tooltip
  position={{ x: 10, y: 10 }}  // Fixed top-left — never overflows
  content={<MobileTooltip />}
/>
```

**3. Too many x-axis ticks on small screens**: Use `interval="preserveStartEnd"` or a dynamic interval:

```tsx
const tickInterval = isMobile
  ? Math.ceil(data.length / 4)
  : Math.ceil(data.length / 12);

<XAxis interval={tickInterval} />
```

---

## Part 10 — Animation

### Default Animation Behavior

By default, Recharts animates chart series on mount:
- Lines draw from left to right
- Bars grow from bottom to top
- Pie slices radiate from center

Each series component accepts:

| Prop | Type | Default | Purpose |
|---|---|---|---|
| `isAnimationActive` | bool | `true` | Enable/disable animation |
| `animationBegin` | number | `0` | ms delay before animation starts |
| `animationDuration` | number | `1500` | ms total animation time |
| `animationEasing` | string | `"ease"` | CSS easing or `"linear"`, `"ease-in"`, `"ease-out"`, `"ease-in-out"`, `"spring"` |

---

### When to Disable Animation

**Always disable for**:
- Real-time / streaming data (animation causes flicker on each update) [Inference — disabling animation on frequently-updating data should visually reduce flicker; actual behavior depends on update frequency]
- Charts that are re-rendered frequently (filtering, cross-filtering)
- Server-side rendering / snapshot testing
- Accessibility (respect `prefers-reduced-motion`)

```tsx
// Respect reduced motion
function useReducedMotion() {
  return window.matchMedia('(prefers-reduced-motion: reduce)').matches;
}

function AccessibleChart({ data }: { data: DataPoint[] }) {
  const reducedMotion = useReducedMotion();

  return (
    <LineChart data={data}>
      <Line
        dataKey="value"
        isAnimationActive={!reducedMotion}
      />
    </LineChart>
  );
}
```

---

### Animation on Data Updates

By default, Recharts re-animates the entire series when `data` changes [Inference — re-animation on data prop change is Recharts' default behavior; the exact timing depends on the `animationBegin` prop]. For dashboards that update on interval, this creates a distracting "redraw" effect.

**Fix — disable animation for data updates, keep enter animation**:

```tsx
// Recharts doesn't natively distinguish first-mount from update animation.
// The pragmatic solution for live data:
<Line dataKey="value" isAnimationActive={false} />
```

For a controlled enter-then-freeze approach:

```tsx
function AnimatedOnceChart({ data }: { data: DataPoint[] }) {
  const [animated, setAnimated] = useState(true);
  const isFirstRender = useRef(true);

  useEffect(() => {
    if (!isFirstRender.current) {
      setAnimated(false);
    }
    isFirstRender.current = false;
  }, [data]);

  return (
    <LineChart data={data}>
      <Line
        dataKey="value"
        isAnimationActive={animated}
        animationDuration={600}
      />
    </LineChart>
  );
}
```

---

### Large Dataset Animation Performance

For datasets > 500 points, animation can cause dropped frames [Inference — SVG animation cost scales with path complexity; exact frame-drop threshold is hardware-dependent]:

```tsx
const ANIMATION_THRESHOLD = 500;

<Line
  isAnimationActive={data.length <= ANIMATION_THRESHOLD}
  animationDuration={data.length > 200 ? 400 : 1200}
/>
```
## Part 11 — Customization

### Custom Shapes

#### Custom Bar Shape

The most common customization. Pass a component or render function to `Bar`'s `shape` prop:

```tsx
interface BarShapeProps {
  x: number;
  y: number;
  width: number;
  height: number;
  fill: string;
  value: number;
}

// Rounded top corners only
const RoundedTopBar = ({ x, y, width, height, fill }: BarShapeProps) => {
  if (height <= 0) return null;
  const r = Math.min(4, width / 2, height / 2);
  return (
    <rect
      x={x}
      y={y}
      width={width}
      height={height}
      rx={r}
      ry={r}
      fill={fill}
      // Clip the bottom radius by overlapping a plain rect at the bottom
      // This is the pure-SVG trick for "top-only" rounded corners:
    />
  );
};

// Full custom shape with gradient
const GradientBar = ({ x, y, width, height, fill }: BarShapeProps) => {
  const gradientId = `bar-gradient-${x}`;
  return (
    <g>
      <defs>
        <linearGradient id={gradientId} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor={fill} stopOpacity={1} />
          <stop offset="100%" stopColor={fill} stopOpacity={0.4} />
        </linearGradient>
      </defs>
      <rect x={x} y={y} width={width} height={height} fill={`url(#${gradientId})`} rx={3} />
    </g>
  );
};

// Waterfall bar — positive/negative with correct baseline
const WaterfallBar = ({ x, y, width, height, fill, value }: BarShapeProps) => {
  const isNegative = value < 0;
  return (
    <rect
      x={x}
      y={isNegative ? y + height : y}
      width={width}
      height={Math.abs(height)}
      fill={isNegative ? '#ef4444' : '#10b981'}
      rx={2}
    />
  );
};

<Bar dataKey="value" shape={<RoundedTopBar />} />
<Bar dataKey="value" shape={<GradientBar />} />
```

---

#### Custom Line Dot

```tsx
interface DotProps {
  cx: number;
  cy: number;
  index: number;
  payload: Record<string, unknown>;
  value: number;
}

// Conditional dot — only show for notable values
const ConditionalDot = ({ cx, cy, payload, value }: DotProps) => {
  if (value < threshold && !payload.isHighlight) return <g />;  // empty but valid SVG

  return (
    <g>
      <circle cx={cx} cy={cy} r={5} fill="#fff" stroke="#6366f1" strokeWidth={2} />
      {payload.isHighlight && (
        <circle cx={cx} cy={cy} r={10} fill="#6366f1" fillOpacity={0.15} />
      )}
    </g>
  );
};

<Line dataKey="value" dot={<ConditionalDot />} activeDot={{ r: 6 }} />
```

---

#### Custom Sector (Pie)

```tsx
const ExplodedSector = (props: any) => {
  const { cx, cy, innerRadius, outerRadius, startAngle, endAngle, fill, isActive } = props;

  const midAngle = ((startAngle + endAngle) / 2) * (Math.PI / 180);
  const explodeOffset = isActive ? 8 : 0;
  const offsetX = explodeOffset * Math.cos(-midAngle);
  const offsetY = explodeOffset * Math.sin(-midAngle);

  return (
    <Sector
      cx={cx + offsetX}
      cy={cy + offsetY}
      innerRadius={innerRadius}
      outerRadius={outerRadius}
      startAngle={startAngle}
      endAngle={endAngle}
      fill={fill}
    />
  );
};
```

---

### Render Props and SVG Customization

Recharts exposes a `customizedComponent` pattern through the `<Customized>` component — allows inserting arbitrary SVG into the chart canvas at the correct coordinate space:

```tsx
import { Customized } from 'recharts';

// A horizontal target band
const TargetBand = ({ xAxisMap, yAxisMap }: any) => {
  const yAxis = Object.values(yAxisMap)[0] as any;
  const y1 = yAxis.scale(900);
  const y2 = yAxis.scale(1100);

  return (
    <rect
      x={60}
      y={y2}
      width="100%"
      height={y1 - y2}
      fill="#10b981"
      fillOpacity={0.1}
    />
  );
};

<LineChart data={data}>
  <Customized component={<TargetBand />} />
  <Line dataKey="value" />
</LineChart>
```

---

### Reusable Custom Shape Templates

```tsx
// Template: Badge dot for events
const EventDot = ({
  cx, cy, payload, label
}: { cx: number; cy: number; payload: any; label?: string }) => {
  if (!payload.hasEvent) return <g />;
  return (
    <g>
      <circle cx={cx} cy={cy - 18} r={8} fill="#f59e0b" />
      <text
        x={cx}
        y={cy - 14}
        textAnchor="middle"
        fill="white"
        fontSize={9}
        fontWeight={700}
      >
        {label ?? '!'}
      </text>
      <line x1={cx} y1={cy - 10} x2={cx} y2={cy} stroke="#f59e0b" strokeWidth={1} strokeDasharray="2 2" />
    </g>
  );
};

// Template: Progress bar background track
const BarTrack = ({ x, y, width, height, background }: any) => (
  <rect
    x={x}
    y={background.y}
    width={width}
    height={background.height}
    fill="#f3f4f6"
    rx={4}
  />
);

<Bar dataKey="progress" shape={<BarTrack />} background={{ fill: '#f3f4f6', rx: 4 }} />
```

---

## Part 12 — Theming

### Design Token Architecture

The foundation of a maintainable chart theme is a token system that maps semantic names to values:

```tsx
// tokens/chart.ts
export const chartTokens = {
  colors: {
    series: [
      '#6366f1',  // indigo-500 — primary
      '#10b981',  // emerald-500
      '#f59e0b',  // amber-500
      '#ef4444',  // red-500
      '#8b5cf6',  // violet-500
      '#06b6d4',  // cyan-500
      '#ec4899',  // pink-500
      '#84cc16',  // lime-500
    ],
    positive: '#10b981',
    negative: '#ef4444',
    neutral: '#6b7280',
    grid: '#f0f0f0',
    gridDark: '#374151',
    axis: '#9ca3af',
    axisDark: '#6b7280',
  },
  font: {
    tick: 12,
    label: 11,
    title: 14,
  },
  stroke: {
    series: 2,
    grid: 1,
    axis: 0,
  },
  radius: {
    bar: 4,
    tooltip: 8,
  },
} as const;

export type ChartTheme = typeof chartTokens;
```

---

### Theme Context

```tsx
// context/ChartTheme.tsx
import { createContext, useContext } from 'react';
import { chartTokens } from '../tokens/chart';

const ChartThemeContext = createContext(chartTokens);

export const ChartThemeProvider = ({
  theme = chartTokens,
  children,
}: {
  theme?: typeof chartTokens;
  children: React.ReactNode;
}) => (
  <ChartThemeContext.Provider value={theme}>
    {children}
  </ChartThemeContext.Provider>
);

export const useChartTheme = () => useContext(ChartThemeContext);
```

---

### Dark Mode Implementation

```tsx
// tokens/chartDark.ts
export const chartTokensDark: typeof chartTokens = {
  ...chartTokens,
  colors: {
    ...chartTokens.colors,
    grid: '#1f2937',
    axis: '#6b7280',
  },
};

// Usage with system preference:
function ThemedDashboard() {
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
  const theme = prefersDark ? chartTokensDark : chartTokens;

  return (
    <ChartThemeProvider theme={theme}>
      <Dashboard />
    </ChartThemeProvider>
  );
}

// Within chart components:
function ThemedLineChart({ data }: { data: DataPoint[] }) {
  const theme = useChartTheme();

  return (
    <LineChart data={data}>
      <CartesianGrid stroke={theme.colors.grid} />
      <XAxis tick={{ fill: theme.colors.axis, fontSize: theme.font.tick }} />
      <YAxis tick={{ fill: theme.colors.axis, fontSize: theme.font.tick }} />
      <Tooltip
        contentStyle={{
          backgroundColor: theme === chartTokensDark ? '#1f2937' : '#fff',
          borderColor: theme.colors.grid,
        }}
      />
      {theme.colors.series.map((color, i) => (
        <Line key={i} dataKey={`series${i}`} stroke={color} strokeWidth={theme.stroke.series} />
      ))}
    </LineChart>
  );
}
```

---

### Semantic Color Patterns

```tsx
// Pattern: auto-color by value (positive/negative)
const getValueColor = (value: number, theme: ChartTheme) =>
  value >= 0 ? theme.colors.positive : theme.colors.negative;

// Pattern: heat map coloring
function interpolateColor(value: number, min: number, max: number): string {
  const t = (value - min) / (max - min);
  const r = Math.round(239 + (16 - 239) * t);   // 239→16 (red to green r channel)
  const g = Math.round(68 + (185 - 68) * t);
  const b = Math.round(68 + (129 - 68) * t);
  return `rgb(${r}, ${g}, ${b})`;
}

// Pattern: categorical color by index, wrapping
const getSeriesColor = (index: number, theme: ChartTheme) =>
  theme.colors.series[index % theme.colors.series.length];
```

---

### Accessibility Color Considerations

Standard color palettes fail colorblind users. Recharts doesn't handle this automatically. [Inference — Recharts renders colors as specified; no built-in colorblind adaptation]

```tsx
// Accessible palette — distinguishable under deuteranopia/protanopia
export const accessibleSeries = [
  '#0173b2',  // blue
  '#de8f05',  // orange
  '#029e73',  // teal
  '#d55e00',  // vermillion
  '#cc78bc',  // lavender
  '#ca9161',  // tan
  '#fbafe4',  // pink
  '#949494',  // gray
];

// Add pattern fills for extra distinction:
const PATTERN_IDS = ['dots', 'lines', 'crosses', 'diag'];

// Define patterns in <defs>:
<defs>
  <pattern id="dots" x="0" y="0" width="4" height="4" patternUnits="userSpaceOnUse">
    <circle cx="1" cy="1" r="1" fill="#0173b2" />
  </pattern>
  <pattern id="lines" x="0" y="0" width="4" height="4" patternUnits="userSpaceOnUse">
    <line x1="0" y1="0" x2="4" y2="4" stroke="#de8f05" strokeWidth="1" />
  </pattern>
</defs>

// Use in bars:
<Bar dataKey="a" fill="url(#dots)" />
<Bar dataKey="b" fill="url(#lines)" />
```

---

## Part 13 — Data Handling

### Data Shape Requirements

Recharts expects `data` as a flat array of objects:

```tsx
// ✅ Correct shape
const data = [
  { month: 'Jan', revenue: 4200, users: 1200 },
  { month: 'Feb', revenue: 5800, users: 1450 },
  { month: 'Mar', revenue: 5100, users: 1380 },
];

// Each key in the objects can be referenced by dataKey
<Line dataKey="revenue" />
<Line dataKey="users" />
```

Recharts does not accept nested objects by default. Flatten first:

```tsx
// ❌ Nested
const raw = [{ date: 'Jan', metrics: { revenue: 4200, users: 1200 } }];

// ✅ Flattened
const flat = raw.map(d => ({ date: d.date, ...d.metrics }));
```

---

### Data Transformation Utilities

```tsx
// Aggregation — daily data → weekly
function aggregateByWeek(
  data: Array<{ date: string; value: number }>
): Array<{ week: string; total: number; avg: number }> {
  const weeks = new Map<string, number[]>();

  data.forEach(({ date, value }) => {
    const weekKey = format(startOfWeek(parseISO(date)), 'yyyy-MM-dd');
    const existing = weeks.get(weekKey) ?? [];
    weeks.set(weekKey, [...existing, value]);
  });

  return Array.from(weeks.entries()).map(([week, values]) => ({
    week,
    total: values.reduce((a, b) => a + b, 0),
    avg: values.reduce((a, b) => a + b, 0) / values.length,
  }));
}

// Moving average
function movingAverage(
  data: number[],
  window: number
): (number | null)[] {
  return data.map((_, i) => {
    if (i < window - 1) return null;
    const slice = data.slice(i - window + 1, i + 1);
    return slice.reduce((a, b) => a + b, 0) / window;
  });
}

// Normalize to 100 (useful for stacked percentage charts)
function normalizeToPercent(
  data: Array<Record<string, number>>,
  keys: string[]
): Array<Record<string, number>> {
  return data.map(row => {
    const total = keys.reduce((sum, k) => sum + (row[k] ?? 0), 0);
    if (total === 0) return row;
    const normalized: Record<string, number> = { ...row };
    keys.forEach(k => { normalized[k] = (row[k] ?? 0) / total * 100; });
    return normalized;
  });
}

// Fill gaps in time-series
function fillTimeGaps(
  data: Array<{ date: string; value: number }>,
  interval: 'day' | 'week' | 'month'
): Array<{ date: string; value: number | null }> {
  if (data.length === 0) return [];
  const start = parseISO(data[0].date);
  const end = parseISO(data[data.length - 1].date);
  const dateMap = new Map(data.map(d => [d.date, d.value]));

  const dates: Date[] = eachInterval[interval]({ start, end });
  return dates.map(d => {
    const key = format(d, 'yyyy-MM-dd');
    return { date: key, value: dateMap.get(key) ?? null };
  });
}
```

---

### Time-Series Data Patterns

```tsx
// Timestamp-based axis (milliseconds)
const timeData = [
  { ts: 1704067200000, value: 420 },
  { ts: 1704153600000, value: 580 },
];

<XAxis
  dataKey="ts"
  type="number"
  scale="time"
  domain={['dataMin', 'dataMax']}
  tickFormatter={(ts) => format(new Date(ts), 'MMM d')}
/>

// Granularity-aware formatters
function tickFormatterForGranularity(
  granularity: 'hourly' | 'daily' | 'weekly' | 'monthly' | 'yearly'
) {
  const formats: Record<typeof granularity, string> = {
    hourly: 'HH:mm',
    daily: 'MMM d',
    weekly: 'MMM d',
    monthly: 'MMM yy',
    yearly: 'yyyy',
  };
  return (ts: number) => format(new Date(ts), formats[granularity]);
}
```

---

### Large Dataset Handling

**Data sampling** — reduce to N evenly spaced points:

```tsx
function sampleData<T>(data: T[], maxPoints: number): T[] {
  if (data.length <= maxPoints) return data;
  const step = data.length / maxPoints;
  return Array.from({ length: maxPoints }, (_, i) => data[Math.floor(i * step)]);
}
```

**LTTB (Largest-Triangle-Three-Buckets)** — perceptually optimal downsampling that preserves visual shape better than uniform sampling. Use the `d3fc-sample` or `@observablehq/plot` downsampling utilities, or implement directly:

```tsx
// Simplified LTTB for single-key data
function lttb(
  data: Array<{ x: number; y: number }>,
  threshold: number
): Array<{ x: number; y: number }> {
  if (threshold >= data.length || threshold === 0) return data;

  const sampled: Array<{ x: number; y: number }> = [data[0]];
  const bucketSize = (data.length - 2) / (threshold - 2);
  let a = 0;

  for (let i = 0; i < threshold - 2; i++) {
    const rangeOffs = Math.floor((i + 1) * bucketSize) + 1;
    const rangeTo = Math.floor((i + 2) * bucketSize) + 1;
    const range = data.slice(rangeOffs, Math.min(rangeTo + 1, data.length));
    const avgX = range.reduce((s, d) => s + d.x, 0) / range.length;
    const avgY = range.reduce((s, d) => s + d.y, 0) / range.length;

    const bucketStart = Math.floor(i * bucketSize) + 1;
    const bucketEnd = Math.floor((i + 1) * bucketSize) + 1;
    let maxArea = -1;
    let maxPoint = data[bucketStart];

    for (let j = bucketStart; j < Math.min(bucketEnd, data.length); j++) {
      const area = Math.abs(
        (data[a].x - avgX) * (data[j].y - data[a].y) -
        (data[a].x - data[j].x) * (avgY - data[a].y)
      ) * 0.5;
      if (area > maxArea) { maxArea = area; maxPoint = data[j]; a = j; }
    }
    sampled.push(maxPoint);
  }

  sampled.push(data[data.length - 1]);
  return sampled;
}
```

**Memoization** — prevent expensive transforms on every render:

```tsx
function RevenueChart({ rawData, filters }: Props) {
  const chartData = useMemo(
    () => transformData(rawData, filters),
    [rawData, filters]
  );

  const sampledData = useMemo(
    () => sampleData(chartData, 500),
    [chartData]
  );

  return <LineChart data={sampledData}>...</LineChart>;
}
```

---

## Part 14 — Performance Engineering

### Understanding Re-Render Cost

Every time a Recharts chart re-renders, it:
1. Re-runs layout calculations
2. Re-computes SVG path strings
3. Re-renders all child SVG nodes

For a typical line chart with 200 points, this is fast. For a dashboard with 12 charts each with 1,000 points, parent state changes cascade into expensive re-renders. [Inference — actual render cost depends on data volume, series count, and hardware; profile your specific setup with React DevTools]

---

### React.memo for Chart Components

```tsx
// Wrap the chart component itself
const RevenueChart = React.memo(function RevenueChart({ data, theme }: Props) {
  return (
    <ResponsiveContainer width="100%" height={320}>
      <LineChart data={data}>...</LineChart>
    </ResponsiveContainer>
  );
}, (prev, next) => {
  // Custom equality — only re-render if data reference or theme changes
  return prev.data === next.data && prev.theme === next.theme;
});
```

---

### useMemo for Data Transformations

```tsx
function Dashboard({ rawData, dateRange, segments }: DashboardProps) {
  // Expensive — run only when inputs change
  const processedData = useMemo(
    () => processData(rawData, dateRange, segments),
    [rawData, dateRange, segments]
  );

  // Derived views — also memoized
  const revenueByMonth = useMemo(
    () => groupByMonth(processedData),
    [processedData]
  );

  const revenueBySegment = useMemo(
    () => groupBySegment(processedData),
    [processedData]
  );

  return (
    <>
      <RevenueChart data={revenueByMonth} />
      <SegmentChart data={revenueBySegment} />
    </>
  );
}
```

---

### useCallback for Event Handlers

```tsx
function InteractiveChart({ onDataClick }: Props) {
  // Stable reference — won't cause Bar to re-render
  const handleBarClick = useCallback(
    (data: any, index: number) => {
      onDataClick(data.name, index);
    },
    [onDataClick]
  );

  return (
    <BarChart data={data}>
      <Bar dataKey="value" onClick={handleBarClick} />
    </BarChart>
  );
}
```

---

### Avoiding Expensive Patterns

**1. Inline object/array props** — creates new reference on every render:

```tsx
// ❌ New object every render → triggers re-render
<CartesianGrid stroke="#f0f0f0" strokeDasharray="3 3" style={{ opacity: 0.5 }} />

// ✅ Stable reference
const gridStyle = { opacity: 0.5 };
<CartesianGrid stroke="#f0f0f0" strokeDasharray="3 3" style={gridStyle} />
```

**2. Inline formatter functions** — redefines on every render:

```tsx
// ❌ New function reference every render
<XAxis tickFormatter={(v) => format(new Date(v), 'MMM d')} />

// ✅ Stable
const formatTick = useCallback((v: number) => format(new Date(v), 'MMM d'), []);
<XAxis tickFormatter={formatTick} />
```

**3. Too many `Cell` components** — for large pie charts or bars with per-item colors, consider a custom shape approach instead of mapping `Cell` elements if you have hundreds of items.

---

### Profiling Technique

```tsx
// Wrap chart in Profiler to measure render cost
import { Profiler } from 'react';

<Profiler
  id="RevenueChart"
  onRender={(id, phase, actualDuration) => {
    if (actualDuration > 16) {
      console.warn(`[Perf] ${id} took ${actualDuration.toFixed(1)}ms (${phase})`);
    }
  }}
>
  <RevenueChart data={data} />
</Profiler>
```

For systemic profiling across a dashboard, use React DevTools Profiler to record an interaction and look for charts with high "actual duration" on updates that shouldn't need re-rendering.

---

### Virtualization for Many Charts

When rendering many charts (e.g., a per-user breakdown with 500 rows), virtualize the list:

```tsx
import { FixedSizeList } from 'react-window';

const ROW_HEIGHT = 120;

const ChartRow = ({ index, style, data }: any) => (
  <div style={style}>
    <MiniSparkline data={data[index]} />
  </div>
);

function ChartList({ data }: { data: DataPoint[][] }) {
  return (
    <FixedSizeList
      height={600}
      itemCount={data.length}
      itemSize={ROW_HEIGHT}
      itemData={data}
      width="100%"
    >
      {ChartRow}
    </FixedSizeList>
  );
}
```

---

## Part 15 — Accessibility

### The Default Accessibility Gap

Recharts generates SVG without ARIA labels, keyboard navigation, or focus management by default. [Inference — this is documented behavior; Recharts SVG output has not been verified against WCAG 2.1 AA in all configurations]

For many internal dashboards, this is acceptable. For public-facing products or government/enterprise requirements, you need to augment.

---

### Data Table Alternative

The most robust accessibility pattern: render the chart visually, and include a visually-hidden data table as the accessible alternative.

```tsx
function AccessibleChart({ data, title }: Props) {
  return (
    <figure role="figure" aria-labelledby={`chart-title-${title}`}>
      <figcaption id={`chart-title-${title}`} className="sr-only">
        {title}
      </figcaption>

      {/* Visual chart */}
      <ResponsiveContainer width="100%" height={300}>
        <LineChart data={data}>...</LineChart>
      </ResponsiveContainer>

      {/* Accessible data table — visually hidden */}
      <table className="sr-only">
        <caption>{title} — data table</caption>
        <thead>
          <tr>
            <th scope="col">Date</th>
            <th scope="col">Revenue</th>
            <th scope="col">Users</th>
          </tr>
        </thead>
        <tbody>
          {data.map((row, i) => (
            <tr key={i}>
              <td>{row.date}</td>
              <td>{row.revenue}</td>
              <td>{row.users}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </figure>
  );
}
```

---

### Keyboard Navigation Pattern

Recharts does not provide built-in keyboard navigation [Inference — no keyboard event handling is documented in Recharts v2 for chart traversal]. Add it via a managed focus index:

```tsx
function KeyboardChart({ data }: { data: DataPoint[] }) {
  const [focusIndex, setFocusIndex] = useState<number | null>(null);
  const chartRef = useRef<HTMLDivElement>(null);

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (data.length === 0) return;
    if (e.key === 'ArrowRight') {
      setFocusIndex(i => Math.min((i ?? -1) + 1, data.length - 1));
    } else if (e.key === 'ArrowLeft') {
      setFocusIndex(i => Math.max((i ?? 1) - 1, 0));
    } else if (e.key === 'Escape') {
      setFocusIndex(null);
    }
  };

  return (
    <div
      ref={chartRef}
      tabIndex={0}
      role="application"
      aria-label={`Chart — press left/right arrows to navigate data points`}
      onKeyDown={handleKeyDown}
      className="focus:outline-2 focus:outline-indigo-500 rounded"
    >
      {/* Announce focused data point */}
      {focusIndex !== null && (
        <div role="status" aria-live="polite" className="sr-only">
          {data[focusIndex].date}: {data[focusIndex].value}
        </div>
      )}

      <LineChart data={data}>
        <Line
          dataKey="value"
          dot={(props: any) => {
            if (props.index === focusIndex) {
              return (
                <circle
                  cx={props.cx}
                  cy={props.cy}
                  r={6}
                  fill="#6366f1"
                  stroke="white"
                  strokeWidth={2}
                  role="img"
                  aria-label={`${data[props.index].date}: ${data[props.index].value}`}
                />
              );
            }
            return <circle cx={props.cx} cy={props.cy} r={2} fill="#6366f1" />;
          }}
        />
      </LineChart>
    </div>
  );
}
```

---

### ARIA Attributes

Minimum viable ARIA for a chart panel:

```tsx
<section
  aria-labelledby="chart-heading"
  aria-describedby="chart-desc"
>
  <h2 id="chart-heading">Monthly Revenue</h2>
  <p id="chart-desc" className="sr-only">
    Line chart showing monthly revenue from January to December 2024.
    Revenue ranged from $42,000 to $98,000, peaking in October.
  </p>
  <ResponsiveContainer>
    <LineChart>
      ...
      <title>Monthly Revenue 2024</title>
      <desc>Line chart showing revenue growth across 12 months</desc>
    </LineChart>
  </ResponsiveContainer>
</section>
```

---

### Color Contrast

WCAG 2.1 AA requires a contrast ratio of at least 3:1 for graphical objects (chart lines, bars) against their background. [This is a WCAG specification, not an inference about Recharts]

```tsx
// Test palette contrast ratios — use a tool like https://webaim.org/resources/contrastchecker/
// or the `wcag-contrast` npm package:
import { score } from 'wcag-contrast';

const isAccessible = (fg: string, bg: string) =>
  score(fg, bg) !== 'Fail';  // Returns 'AA', 'AAA', or 'Fail'

// Enforce minimum strokeWidth for lines — thin lines fail contrast
<Line strokeWidth={2} />  // 2px minimum recommended
```

---

### Reduced Motion

```tsx
// Respect prefers-reduced-motion at the system level
const prefersReducedMotion =
  typeof window !== 'undefined' &&
  window.matchMedia('(prefers-reduced-motion: reduce)').matches;

// Apply to all series in a chart set
const ANIMATION_PROPS = prefersReducedMotion
  ? { isAnimationActive: false }
  : { isAnimationActive: true, animationDuration: 600 };

<Line {...ANIMATION_PROPS} dataKey="value" />
<Bar {...ANIMATION_PROPS} dataKey="value" />
```
## Part 16 — Dashboard Architecture

### Folder Structure

```
src/
├── components/
│   ├── charts/
│   │   ├── base/                   # Primitives — low-level reusable pieces
│   │   │   ├── ChartContainer.tsx  # ResponsiveContainer + loading/error
│   │   │   ├── ChartTooltip.tsx    # Standard tooltip
│   │   │   ├── ChartLegend.tsx     # Standard legend
│   │   │   └── ChartSkeleton.tsx   # Loading placeholder
│   │   │
│   │   ├── series/                 # Typed chart type components
│   │   │   ├── LineChart.tsx
│   │   │   ├── BarChart.tsx
│   │   │   ├── AreaChart.tsx
│   │   │   ├── DonutChart.tsx
│   │   │   └── SparklineChart.tsx
│   │   │
│   │   └── widgets/               # Business-level chart panels
│   │       ├── RevenuePanel.tsx
│   │       ├── UserGrowthPanel.tsx
│   │       ├── FunnelPanel.tsx
│   │       └── RetentionPanel.tsx
│   │
│   ├── dashboard/
│   │   ├── DashboardGrid.tsx
│   │   ├── DashboardPanel.tsx
│   │   └── DashboardFilters.tsx
│   │
│   └── kpi/
│       ├── KPICard.tsx
│       └── KPIGrid.tsx
│
├── hooks/
│   ├── useChartData.ts             # Data fetching abstraction
│   ├── useChartTheme.ts            # Theme hook
│   ├── useDashboardFilters.ts      # Global filter state
│   └── useBreakpoint.ts
│
├── lib/
│   ├── chartTransforms.ts          # Pure transform functions
│   ├── colorScales.ts              # Color generation utilities
│   └── formatters.ts               # Number/date formatters
│
├── tokens/
│   ├── chart.ts                    # Design tokens
│   └── chartDark.ts
│
└── types/
    └── chart.ts                    # Shared TypeScript types
```

---

### ChartContainer — Base Component

Every chart in a production app should go through a base container that handles:
- Responsive sizing
- Loading state
- Error state
- Empty state
- Title/description

```tsx
// components/charts/base/ChartContainer.tsx
interface ChartContainerProps {
  title?: string;
  description?: string;
  height?: number;
  isLoading?: boolean;
  error?: Error | null;
  isEmpty?: boolean;
  emptyMessage?: string;
  children: React.ReactNode;
  actions?: React.ReactNode;   // Optional header actions (export, filter)
}

export function ChartContainer({
  title,
  description,
  height = 320,
  isLoading = false,
  error = null,
  isEmpty = false,
  emptyMessage = 'No data available',
  children,
  actions,
}: ChartContainerProps) {
  return (
    <div className="bg-white rounded-xl border border-gray-200 p-6">
      {(title || actions) && (
        <div className="flex items-start justify-between mb-5">
          <div>
            {title && <h3 className="text-sm font-semibold text-gray-900">{title}</h3>}
            {description && <p className="text-xs text-gray-500 mt-0.5">{description}</p>}
          </div>
          {actions && <div className="flex items-center gap-2">{actions}</div>}
        </div>
      )}

      <div style={{ height }}>
        {isLoading ? (
          <ChartSkeleton height={height} />
        ) : error ? (
          <ChartError error={error} height={height} />
        ) : isEmpty ? (
          <ChartEmpty message={emptyMessage} height={height} />
        ) : (
          <ResponsiveContainer width="100%" height="100%">
            {children as React.ReactElement}
          </ResponsiveContainer>
        )}
      </div>
    </div>
  );
}
```

---

### Shared Chart System

```tsx
// components/charts/series/LineChart.tsx
// This is NOT Recharts' LineChart — it's your app's wrapper

interface AppLineChartProps {
  data: Record<string, unknown>[];
  series: Array<{
    key: string;
    label: string;
    color?: string;
    dashed?: boolean;
  }>;
  xKey: string;
  xFormatter?: (value: string | number) => string;
  yFormatter?: (value: number) => string;
  yDomain?: [number | string, number | string];
  height?: number;
  showGrid?: boolean;
  connectNulls?: boolean;
}

export const AppLineChart = React.memo(function AppLineChart({
  data,
  series,
  xKey,
  xFormatter,
  yFormatter,
  yDomain,
  height = 280,
  showGrid = true,
  connectNulls = false,
}: AppLineChartProps) {
  const theme = useChartTheme();

  return (
    <ResponsiveContainer width="100%" height={height}>
      <LineChart data={data} margin={{ top: 8, right: 8, left: 0, bottom: 8 }}>
        {showGrid && (
          <CartesianGrid
            strokeDasharray="3 3"
            stroke={theme.colors.grid}
            vertical={false}
          />
        )}
        <XAxis
          dataKey={xKey}
          tickFormatter={xFormatter}
          tick={{ fontSize: theme.font.tick, fill: theme.colors.axis }}
          axisLine={false}
          tickLine={false}
        />
        <YAxis
          tickFormatter={yFormatter}
          domain={yDomain}
          tick={{ fontSize: theme.font.tick, fill: theme.colors.axis }}
          axisLine={false}
          tickLine={false}
          width={56}
        />
        <Tooltip content={<ChartTooltip labelFormatter={xFormatter} valueFormatter={yFormatter} />} />
        {series.map(({ key, label, color, dashed }, i) => (
          <Line
            key={key}
            type="monotone"
            dataKey={key}
            name={label}
            stroke={color ?? theme.colors.series[i % theme.colors.series.length]}
            strokeWidth={2}
            strokeDasharray={dashed ? '4 2' : undefined}
            dot={false}
            activeDot={{ r: 4, strokeWidth: 0 }}
            connectNulls={connectNulls}
          />
        ))}
      </LineChart>
    </ResponsiveContainer>
  );
});
```

---

### Dashboard Panel with Fetch

```tsx
// components/charts/widgets/RevenuePanel.tsx
interface RevenuePanelProps {
  dateRange: DateRange;
  granularity: 'daily' | 'weekly' | 'monthly';
}

export function RevenuePanel({ dateRange, granularity }: RevenuePanelProps) {
  const { data, isLoading, error } = useRevenueData(dateRange, granularity);

  const isEmpty = !isLoading && !error && (!data || data.length === 0);

  return (
    <ChartContainer
      title="Revenue"
      description={`${granularity} breakdown`}
      height={300}
      isLoading={isLoading}
      error={error}
      isEmpty={isEmpty}
      actions={<ExportButton data={data} filename="revenue" />}
    >
      <AppLineChart
        data={data ?? []}
        series={[
          { key: 'mrr', label: 'MRR', color: '#6366f1' },
          { key: 'arr', label: 'ARR', color: '#10b981', dashed: true },
        ]}
        xKey="date"
        xFormatter={tickFormatterForGranularity(granularity)}
        yFormatter={(v) => `$${(v / 1000).toFixed(0)}k`}
      />
    </ChartContainer>
  );
}
```

---

## Part 17 — Advanced Patterns

### Multi-Axis Charts

```tsx
// Biaxial: revenue (left) + growth rate (right)
<ComposedChart data={data}>
  <CartesianGrid strokeDasharray="3 3" vertical={false} />
  <XAxis dataKey="month" />

  <YAxis
    yAxisId="revenue"
    tickFormatter={(v) => `$${(v / 1000).toFixed(0)}k`}
    domain={[0, 'dataMax + 10000']}
  />
  <YAxis
    yAxisId="growth"
    orientation="right"
    tickFormatter={(v) => `${v}%`}
    domain={[-100, 200]}
  />

  <Tooltip content={<BiaxialTooltip />} />
  <Legend />

  <Bar yAxisId="revenue" dataKey="revenue" fill="#6366f1" radius={[4, 4, 0, 0]} opacity={0.9} />
  <Line yAxisId="growth" type="monotone" dataKey="growthRate" stroke="#ef4444" strokeWidth={2} dot={false} />
</ComposedChart>
```

---

### Synchronized Charts with `syncId`

```tsx
// syncId connects tooltip and cursor across charts
// Charts with the same syncId show the same x-position highlight

function SyncedDashboard({ data }: { data: MetricsData }) {
  const SYNC = 'metrics-sync';

  return (
    <div className="space-y-4">
      <ChartContainer title="Revenue" height={200}>
        <AreaChart data={data.revenue} syncId={SYNC}>
          <XAxis dataKey="date" hide />
          <YAxis />
          <Tooltip />
          <Area dataKey="value" stroke="#6366f1" fill="#6366f1" fillOpacity={0.1} />
        </AreaChart>
      </ChartContainer>

      <ChartContainer title="Active Users" height={200}>
        <AreaChart data={data.users} syncId={SYNC}>
          <XAxis dataKey="date" hide />
          <YAxis />
          <Tooltip />
          <Area dataKey="value" stroke="#10b981" fill="#10b981" fillOpacity={0.1} />
        </AreaChart>
      </ChartContainer>

      <ChartContainer title="Errors" height={200}>
        <BarChart data={data.errors} syncId={SYNC}>
          <XAxis dataKey="date" />
          <YAxis />
          <Tooltip />
          <Bar dataKey="count" fill="#ef4444" />
        </BarChart>
      </ChartContainer>
    </div>
  );
}
```

**Architecture note**: For `syncId` to work correctly, all synced charts must share the same `data` array length and the same `dataKey` for the x-axis. Mismatched arrays will cause sync to appear broken. [Inference — this constraint follows from how Recharts maps array indices for sync; not officially documented as a strict requirement]

---

### Architecture Diagram: Drill-Down Analytics

```
┌─────────────────────────────────────────────────────────┐
│  Dashboard State                                         │
│  { level: 'region', filter: null }                       │
└────────────────────┬────────────────────────────────────┘
                     │ drill down
                     ▼
┌─────────────────────────────────────────────────────────┐
│  Level 1: Region View                                    │
│  <BarChart data={revenueByRegion} />                     │
│  onClick(region) → setDrill({ level: 'country', ... })   │
└────────────────────┬────────────────────────────────────┘
                     │ click "North America"
                     ▼
┌─────────────────────────────────────────────────────────┐
│  Level 2: Country View                                   │
│  <BarChart data={revenueByCountry('North America')} />   │
│  onClick(country) → setDrill({ level: 'state', ... })    │
└────────────────────┬────────────────────────────────────┘
                     │ click "United States"
                     ▼
┌─────────────────────────────────────────────────────────┐
│  Level 3: State/City View                                │
│  <BarChart data={revenueByState('US')} />                │
└─────────────────────────────────────────────────────────┘
```

```tsx
type DrillLevel = 'region' | 'country' | 'state';

interface DrillState {
  level: DrillLevel;
  path: string[];  // breadcrumb path
}

function DrillDownChart() {
  const [drill, setDrill] = useState<DrillState>({ level: 'region', path: [] });

  const data = useDrillData(drill);

  const drillDown = (name: string) => {
    const nextLevel: Record<DrillLevel, DrillLevel | null> = {
      region: 'country',
      country: 'state',
      state: null,
    };
    const next = nextLevel[drill.level];
    if (!next) return;
    setDrill({ level: next, path: [...drill.path, name] });
  };

  const drillTo = (index: number) => {
    setDrill({
      level: (['region', 'country', 'state'] as DrillLevel[])[index],
      path: drill.path.slice(0, index),
    });
  };

  return (
    <div>
      {/* Breadcrumb */}
      <nav aria-label="drill-down path">
        <button onClick={() => drillTo(0)}>All Regions</button>
        {drill.path.map((name, i) => (
          <span key={i}>
            {' / '}
            <button onClick={() => drillTo(i + 1)}>{name}</button>
          </span>
        ))}
      </nav>

      <BarChart data={data} onClick={(d) => drillDown(d.activeLabel)}>
        <XAxis dataKey="name" />
        <YAxis />
        <Bar dataKey="revenue" fill="#6366f1" cursor="pointer" />
      </BarChart>
    </div>
  );
}
```

---

### Real-Time Dashboard Pattern

```tsx
function RealTimeMetricChart() {
  const [buffer, setBuffer] = useState<DataPoint[]>([]);
  const MAX_POINTS = 60;  // Show last 60 seconds

  useEffect(() => {
    const ws = new WebSocket('wss://your-metrics-service/stream');

    ws.onmessage = (event) => {
      const point: DataPoint = JSON.parse(event.data);
      setBuffer(prev => {
        const next = [...prev, point];
        return next.length > MAX_POINTS ? next.slice(-MAX_POINTS) : next;
      });
    };

    return () => ws.close();
  }, []);

  // No animation on real-time charts
  return (
    <ResponsiveContainer width="100%" height={200}>
      <LineChart data={buffer}>
        <XAxis
          dataKey="ts"
          type="number"
          domain={['dataMin', 'dataMax']}
          tickFormatter={(ts) => format(new Date(ts), 'HH:mm:ss')}
          scale="time"
        />
        <YAxis />
        <Line
          type="monotone"
          dataKey="value"
          stroke="#10b981"
          strokeWidth={1.5}
          dot={false}
          isAnimationActive={false}
        />
      </LineChart>
    </ResponsiveContainer>
  );
}
```

---

## Part 18 — TypeScript

### Typing Chart Data

```tsx
// types/chart.ts

// Generic time-series point
export interface TimeSeriesPoint {
  date: string;
  [key: string]: string | number | null;
}

// Typed for specific charts
export interface RevenuePoint {
  date: string;
  mrr: number;
  arr: number;
  churn: number | null;
}

export interface UserGrowthPoint {
  date: string;
  newUsers: number;
  activeUsers: number;
  churned: number;
}

export interface FunnelStage {
  name: string;
  value: number;
  fill?: string;
}

// Series config type
export interface SeriesConfig {
  key: string;
  label: string;
  color?: string;
  type?: 'line' | 'bar' | 'area';
  yAxisId?: string;
  format?: 'number' | 'currency' | 'percent';
}
```

---

### Generic Chart Component

```tsx
// A strongly typed generic line chart
interface GenericLineChartProps<T extends Record<string, unknown>> {
  data: T[];
  xKey: keyof T & string;
  yKeys: Array<keyof T & string>;
  colors?: string[];
  xFormatter?: (value: T[typeof xKey]) => string;
  yFormatter?: (value: number) => string;
  height?: number;
}

function GenericLineChart<T extends Record<string, unknown>>({
  data,
  xKey,
  yKeys,
  colors = ['#6366f1', '#10b981', '#f59e0b'],
  xFormatter,
  yFormatter,
  height = 300,
}: GenericLineChartProps<T>) {
  return (
    <ResponsiveContainer width="100%" height={height}>
      <LineChart data={data as Record<string, unknown>[]}>
        <XAxis
          dataKey={xKey}
          tickFormatter={xFormatter as ((v: unknown) => string) | undefined}
        />
        <YAxis tickFormatter={yFormatter} />
        <Tooltip />
        {yKeys.map((key, i) => (
          <Line
            key={key}
            type="monotone"
            dataKey={key}
            stroke={colors[i % colors.length]}
            strokeWidth={2}
            dot={false}
          />
        ))}
      </LineChart>
    </ResponsiveContainer>
  );
}

// Usage — fully typed
<GenericLineChart<RevenuePoint>
  data={revenueData}
  xKey="date"
  yKeys={['mrr', 'arr']}
  yFormatter={(v) => `$${v.toLocaleString()}`}
/>
```

---

### Typing Custom Tooltip

```tsx
import type { TooltipProps } from 'recharts';
import type { ValueType, NameType } from 'recharts/types/component/DefaultTooltipContent';

// The Recharts types for custom content
type CustomTooltipProps = TooltipProps<ValueType, NameType> & {
  /** Your own extra props */
  currency?: string;
};

export function TypedTooltip({ active, payload, label, currency = 'USD' }: CustomTooltipProps) {
  if (!active || !payload?.length) return null;

  return (
    <div className="recharts-custom-tooltip">
      <p className="label">{label}</p>
      {payload.map((p) => (
        <p key={String(p.dataKey)} style={{ color: p.color }}>
          {p.name}: {typeof p.value === 'number'
            ? new Intl.NumberFormat('en-US', { style: 'currency', currency }).format(p.value)
            : p.value
          }
        </p>
      ))}
    </div>
  );
}
```

---

### Typing Event Handlers

```tsx
import type {
  CategoricalChartState,
} from 'recharts/types/chart/generateCategoricalChart';

// Bar click
const handleBarClick = (
  data: {
    name: string;
    value: number;
    payload: Record<string, unknown>;
  },
  index: number
) => {
  console.log(data.name, index);
};

// Chart mouse move
const handleMouseMove = (state: CategoricalChartState) => {
  if (state.isTooltipActive) {
    // state.activePayload is typed
  }
};
```

---

### Reusable Chart Hook

```tsx
// hooks/useChartData.ts
interface UseChartDataOptions<T> {
  url: string;
  transform?: (raw: unknown) => T[];
  refetchInterval?: number;
}

function useChartData<T>({
  url,
  transform,
  refetchInterval,
}: UseChartDataOptions<T>) {
  const [data, setData] = useState<T[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    let cancelled = false;

    const fetch_ = async () => {
      try {
        const res = await fetch(url);
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        const raw = await res.json();
        if (!cancelled) {
          setData(transform ? transform(raw) : raw);
          setError(null);
        }
      } catch (e) {
        if (!cancelled) setError(e instanceof Error ? e : new Error(String(e)));
      } finally {
        if (!cancelled) setIsLoading(false);
      }
    };

    fetch_();
    if (refetchInterval) {
      const id = setInterval(fetch_, refetchInterval);
      return () => { cancelled = true; clearInterval(id); };
    }
    return () => { cancelled = true; };
  }, [url, refetchInterval]);

  return { data, isLoading, error };
}
```

---

## Part 19 — Common Production Recipes

### Recipe 1: Revenue Dashboard

```tsx
// Architecture
interface RevenueDashboardData {
  byMonth: Array<{ month: string; mrr: number; arr: number; churnRate: number }>;
  bySegment: Array<{ name: string; value: number }>;
  kpis: {
    currentMRR: number;
    mrrGrowth: number;
    churnRate: number;
    ltv: number;
  };
}

function RevenueDashboard() {
  const { data, isLoading } = useChartData<RevenueDashboardData>({
    url: '/api/metrics/revenue',
    refetchInterval: 60_000,
  });

  return (
    <div className="space-y-6">
      {/* KPI Row */}
      <div className="grid grid-cols-4 gap-4">
        <KPICard label="MRR" value={data?.kpis.currentMRR} format="currency" trend={data?.kpis.mrrGrowth} />
        <KPICard label="ARR" value={(data?.kpis.currentMRR ?? 0) * 12} format="currency" />
        <KPICard label="Churn Rate" value={data?.kpis.churnRate} format="percent" invertTrend />
        <KPICard label="LTV" value={data?.kpis.ltv} format="currency" />
      </div>

      {/* Main trend */}
      <ChartContainer title="MRR Trend" height={320} isLoading={isLoading}>
        <ComposedChart data={data?.byMonth ?? []}>
          <CartesianGrid strokeDasharray="3 3" vertical={false} />
          <XAxis dataKey="month" />
          <YAxis yAxisId="mrr" tickFormatter={(v) => `$${(v / 1000).toFixed(0)}k`} />
          <YAxis yAxisId="churn" orientation="right" tickFormatter={(v) => `${v}%`} />
          <Tooltip />
          <Legend />
          <Bar yAxisId="mrr" dataKey="mrr" fill="#6366f1" radius={[4, 4, 0, 0]} name="MRR" />
          <Line yAxisId="churn" type="monotone" dataKey="churnRate" stroke="#ef4444" dot={false} name="Churn %" />
        </ComposedChart>
      </ChartContainer>

      {/* Segment breakdown */}
      <ChartContainer title="Revenue by Segment" height={280} isLoading={isLoading}>
        <PieChart>
          <Pie
            data={data?.bySegment ?? []}
            dataKey="value"
            nameKey="name"
            cx="50%"
            cy="50%"
            innerRadius={70}
            outerRadius={110}
          >
            {(data?.bySegment ?? []).map((_, i) => (
              <Cell key={i} fill={chartTokens.colors.series[i]} />
            ))}
          </Pie>
          <Tooltip formatter={(v: number) => `$${v.toLocaleString()}`} />
          <Legend />
        </PieChart>
      </ChartContainer>
    </div>
  );
}
```

---

### Recipe 2: User Growth Chart

```tsx
interface UserGrowthPoint {
  date: string;
  newUsers: number;
  activeUsers: number;
  churned: number;
}

function UserGrowthChart({ data }: { data: UserGrowthPoint[] }) {
  return (
    <ResponsiveContainer width="100%" height={320}>
      <ComposedChart data={data}>
        <defs>
          <linearGradient id="activeGrad" x1="0" y1="0" x2="0" y2="1">
            <stop offset="5%" stopColor="#6366f1" stopOpacity={0.1} />
            <stop offset="95%" stopColor="#6366f1" stopOpacity={0} />
          </linearGradient>
        </defs>
        <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f0f0f0" />
        <XAxis dataKey="date" tickFormatter={(d) => format(parseISO(d), 'MMM d')} />
        <YAxis />
        <Tooltip />
        <Legend />
        <Area
          type="monotone"
          dataKey="activeUsers"
          stroke="#6366f1"
          fill="url(#activeGrad)"
          name="Active Users"
          strokeWidth={2}
        />
        <Bar dataKey="newUsers" fill="#10b981" name="New Users" radius={[2, 2, 0, 0]} />
        <Bar dataKey="churned" fill="#ef4444" name="Churned" radius={[2, 2, 0, 0]} />
      </ComposedChart>
    </ResponsiveContainer>
  );
}
```

---

### Recipe 3: Marketing Funnel

```tsx
const FUNNEL_COLORS = ['#6366f1', '#8b5cf6', '#a78bfa', '#c4b5fd', '#ddd6fe'];

interface FunnelStage {
  name: string;
  value: number;
  fill: string;
}

function MarketingFunnel({ stages }: { stages: FunnelStage[] }) {
  const withConversion = stages.map((stage, i) => ({
    ...stage,
    conversionFromPrev: i === 0
      ? 100
      : ((stage.value / stages[i - 1].value) * 100).toFixed(1),
    fill: FUNNEL_COLORS[i],
  }));

  return (
    <div className="flex gap-8">
      <div className="flex-1">
        <FunnelChart width="100%" height={350}>
          <Funnel
            dataKey="value"
            data={withConversion}
            isAnimationActive
            lastShapeType="rectangle"
          >
            <LabelList
              position="right"
              content={(props: any) => (
                <text x={props.x + props.width + 8} y={props.y + props.height / 2 + 4} fill="#374151" fontSize={12}>
                  {props.name}: {Number(props.value).toLocaleString()}
                  {props.index > 0 && (
                    <tspan fill="#6b7280" fontSize={11}>
                      {' '}({withConversion[props.index].conversionFromPrev}%)
                    </tspan>
                  )}
                </text>
              )}
            />
          </Funnel>
          <Tooltip formatter={(v: number) => v.toLocaleString()} />
        </FunnelChart>
      </div>

      {/* Stage metrics table */}
      <div className="w-48">
        {withConversion.map((stage, i) => (
          <div key={i} className="flex items-center justify-between py-2 border-b border-gray-100 text-sm">
            <span style={{ color: stage.fill }} className="font-medium">{stage.name}</span>
            <span className="text-gray-900">{stage.value.toLocaleString()}</span>
          </div>
        ))}
      </div>
    </div>
  );
}
```

---

### Recipe 4: System Monitoring Dashboard

```tsx
interface SystemMetric {
  ts: number;
  cpu: number;
  memory: number;
  requests: number;
  errorRate: number;
}

const THRESHOLD = {
  cpu: 80,
  memory: 85,
  errorRate: 5,
};

function SystemMonitor({ data }: { data: SystemMetric[] }) {
  const latestPoint = data[data.length - 1];

  const getCriticalColor = (value: number, threshold: number) =>
    value > threshold ? '#ef4444' : value > threshold * 0.8 ? '#f59e0b' : '#10b981';

  return (
    <div className="grid grid-cols-2 gap-4">
      {/* CPU */}
      <ChartContainer title={`CPU Usage — ${latestPoint?.cpu.toFixed(1)}%`} height={160}>
        <AreaChart data={data} syncId="system">
          <XAxis dataKey="ts" hide />
          <YAxis domain={[0, 100]} tick={{ fontSize: 10 }} width={28} />
          <ReferenceLine y={THRESHOLD.cpu} stroke="#ef4444" strokeDasharray="3 2" />
          <Area
            type="monotone"
            dataKey="cpu"
            stroke={getCriticalColor(latestPoint?.cpu ?? 0, THRESHOLD.cpu)}
            fill={getCriticalColor(latestPoint?.cpu ?? 0, THRESHOLD.cpu)}
            fillOpacity={0.1}
            isAnimationActive={false}
          />
        </AreaChart>
      </ChartContainer>

      {/* Memory */}
      <ChartContainer title={`Memory — ${latestPoint?.memory.toFixed(1)}%`} height={160}>
        <AreaChart data={data} syncId="system">
          <XAxis dataKey="ts" hide />
          <YAxis domain={[0, 100]} tick={{ fontSize: 10 }} width={28} />
          <ReferenceLine y={THRESHOLD.memory} stroke="#ef4444" strokeDasharray="3 2" />
          <Area
            type="monotone"
            dataKey="memory"
            stroke={getCriticalColor(latestPoint?.memory ?? 0, THRESHOLD.memory)}
            fill={getCriticalColor(latestPoint?.memory ?? 0, THRESHOLD.memory)}
            fillOpacity={0.1}
            isAnimationActive={false}
          />
        </AreaChart>
      </ChartContainer>

      {/* Requests/s */}
      <ChartContainer title="Requests / second" height={160}>
        <BarChart data={data} syncId="system">
          <XAxis dataKey="ts" hide />
          <YAxis tick={{ fontSize: 10 }} width={28} />
          <Bar dataKey="requests" fill="#6366f1" isAnimationActive={false} />
        </BarChart>
      </ChartContainer>

      {/* Error Rate */}
      <ChartContainer title={`Error Rate — ${latestPoint?.errorRate.toFixed(2)}%`} height={160}>
        <AreaChart data={data} syncId="system">
          <XAxis dataKey="ts" tickFormatter={(ts) => format(new Date(ts), 'HH:mm')} />
          <YAxis tick={{ fontSize: 10 }} width={28} />
          <ReferenceLine y={THRESHOLD.errorRate} stroke="#ef4444" strokeDasharray="3 2" />
          <Area
            type="monotone"
            dataKey="errorRate"
            stroke="#ef4444"
            fill="#ef4444"
            fillOpacity={0.1}
            isAnimationActive={false}
          />
        </AreaChart>
      </ChartContainer>
    </div>
  );
}
```

---

## Part 20 — Interview Knowledge

### Frequently Asked Questions

**Q: What is the difference between `LineChart` and `ComposedChart`?**

`LineChart` is a convenience wrapper that only accepts `Line` components as series. `ComposedChart` accepts `Line`, `Bar`, and `Area` simultaneously, giving you mixed chart types on the same axes. [Inference — this distinction is based on Recharts documentation; verify against the version you are using]

**Q: How does `ResponsiveContainer` determine chart size?**

`ResponsiveContainer` observes its DOM parent's dimensions using a resize observer. It passes `width` and `height` as props to its chart child. The parent element must have explicit dimensions — it cannot infer height from children. `width="100%"` is the most common configuration, paired with a fixed `height` prop or a `height="100%"` and a sized parent.

**Q: How do you add a horizontal reference line at the average value?**

```tsx
const avg = data.reduce((sum, d) => sum + d.value, 0) / data.length;
<ReferenceLine y={avg} stroke="#f59e0b" strokeDasharray="4 2" label={`Avg: ${avg.toFixed(0)}`} />
```

**Q: How do you make a chart's legend interactive (toggle series)?**

Manage a `Set<string>` of hidden keys in state. Pass `hide={hiddenKeys.has(key)}` to each series. Render a custom `<Legend content={...}>` that calls a toggle handler on click. (Full example in Part 7.)

---

### Senior-Level Questions

**Q: You have a dashboard with 20 charts. A global filter changes and causes all charts to re-render simultaneously, causing a 2-second freeze. How do you fix it?**

Several strategies, applied in order of impact:

1. `React.memo` each chart component with proper equality — prevent re-renders when their own data hasn't changed.
2. Derive per-chart data with `useMemo` so filter changes only recompute affected chart data.
3. Stagger renders with a micro-scheduler or `React.startTransition` to let the browser paint between chart updates.
4. If charts fetch their own data, the filter change should update query keys, and suspense boundaries isolate loading states.
5. For extreme cases: virtualize the chart grid so off-screen charts don't render at all.

**Q: How do you implement zoom on a time-series chart?**

Use `ReferenceArea` dragging to capture the user's selection, then derive a new `domain` for `XAxis` from the selection. Store the zoom state (`{ left, right }`) and pass it to `domain={[left, right]}`. Add a "Reset Zoom" button. (This is the standard Recharts zoom recipe — an example appears in the official Recharts docs.)

**Q: How do you synchronize a cursor across multiple charts?**

Use the `syncId` prop — set the same string value on multiple chart containers. Recharts' internal context propagates the active x-position across all charts sharing that `syncId`. For charts on separate page sections that need sync beyond Recharts' mechanism, use a shared state and pass `activeIndex` as a controlled prop.

**Q: How do you handle null/undefined values in a line chart?**

By default, null values break the line (a gap appears). Behavior options:
- `connectNulls={true}` on `<Line>` — connects across nulls
- Filter nulls out of the data before passing to the chart — no gap, but loses the x-position
- Replace nulls with 0 — wrong semantically but visually continuous
- Use a custom dot renderer to mark null positions with a visual indicator

**Q: What is the `Cell` component for?**

`Cell` applies individual styles to items within `Pie`, `Bar`, `RadialBar`, and `Funnel`. Without `Cell`, all bars in a `Bar` series are the same color. With `Cell`, you can color each bar based on its value, index, or any condition.

---

### Architecture Questions

**Q: How do you build a reusable chart library for a large team?**

1. Define a token system (colors, typography, spacing) as a TypeScript constant object.
2. Create a `ChartThemeProvider` that distributes tokens via context.
3. Build a set of typed "series" components (`AppLineChart`, `AppBarChart`) that enforce your design system internally but accept a standard data/config interface.
4. Build "panel" components that add `ChartContainer` (title, loading, error, empty) around the series components.
5. Document each component with Storybook stories that show real data shapes.

**Q: How would you design a chart system that supports both light and dark mode?**

Separate design tokens into `chartTokensLight` and `chartTokensDark`. Provide them via a `ChartThemeProvider`. All chart components read colors from the theme context, never hardcoding hex values. The provider switches based on the system/app theme preference. This means the same chart component renders correctly in both modes with zero per-chart changes.

---

### Performance Questions

**Q: When should you disable animation?**

- Real-time charts updating more than once per second
- Charts that re-render on user interaction (filter changes, hover cross-effects)
- Server-side rendering or snapshot tests
- When the user has `prefers-reduced-motion` set

**Q: A LineChart with 5,000 points is slow. What do you do?**

1. Downsample to 500 points using LTTB (preserves visual shape).
2. Disable animation.
3. Set `dot={false}` to skip rendering individual point elements.
4. Memoize the data transformation.
5. If still slow, evaluate canvas-based alternatives (ECharts, uPlot) for this specific use case.
## Final Section

### Recharts Component Cheat Sheet

#### Must Know

These components appear in virtually every production Recharts implementation:

| Component | What It Does |
|---|---|
| `ResponsiveContainer` | Makes any chart fill its container width/height |
| `LineChart` | Container for line charts — establishes Cartesian coordinate space |
| `BarChart` | Container for bar charts |
| `AreaChart` | Container for area charts |
| `ComposedChart` | Container that mixes Line, Bar, and Area |
| `XAxis` | Horizontal axis — data key, ticks, labels |
| `YAxis` | Vertical axis — scale, domain, formatter |
| `CartesianGrid` | Background grid lines |
| `Tooltip` | Hover tooltip |
| `Legend` | Series legend |
| `Line` | A line series inside LineChart or ComposedChart |
| `Bar` | A bar series |
| `Area` | An area series |
| `Cell` | Per-item styling inside Pie or Bar |
| `Pie` | A pie/donut slice series inside PieChart |
| `PieChart` | Container for pie/donut charts |

---

#### Frequently Used

| Component | Typical Use Case |
|---|---|
| `ReferenceLine` | Target lines, averages, thresholds |
| `ReferenceArea` | Highlighted periods, campaign windows |
| `LabelList` | Data labels on bars or lines |
| `Brush` | Zoom/scroll on time-series charts |
| `ScatterChart` + `Scatter` | Correlation/distribution charts |
| `RadialBarChart` + `RadialBar` | Gauge / progress ring KPIs |
| `FunnelChart` + `Funnel` | Conversion funnel visualizations |
| `Treemap` | Hierarchical proportional area |

---

#### Occasionally Used

| Component | When You Need It |
|---|---|
| `RadarChart` + `Radar` + `PolarGrid` | Multi-dimensional comparison (5–8 axes) |
| `ZAxis` | Bubble sizing in ScatterChart |
| `ReferenceDot` | Marking specific anomaly/event points |
| `Label` | Custom annotation on a single element |
| `Customized` | Injecting arbitrary SVG into chart space |
| `ErrorBar` | Statistical error ranges on data points |
| `SankeyChart` | Flow diagrams (limited in Recharts v2) |

---

#### Advanced

| Component/Pattern | When You Need It |
|---|---|
| Custom `shape` on Bar | Fully custom bar rendering |
| Custom `dot` on Line | Per-point conditional dot rendering |
| Custom `content` on Tooltip | Branded, fully styled tooltips |
| Custom `content` on Legend | Interactive toggle legends |
| `activeShape` on Pie | Hover-expand sectors |
| `syncId` across charts | Synchronized multi-chart dashboards |
| SVG `<defs>` + `linearGradient` | Gradient fills for areas/bars |

---

#### Rarely Used

| Component | Notes |
|---|---|
| `Surface` | Low-level SVG surface — use chart containers instead |
| `Sector` | SVG arc primitive — use inside custom activeShape |
| `Curve` | SVG path primitive — use inside custom shapes |
| `Rectangle` | SVG rect primitive — use inside custom bars |
| `Dot` | SVG circle primitive — use inside custom dots |
| `Polygon` | SVG polygon primitive |
| `Trapezoid` | Used internally by FunnelChart |
| `Text` | SVG text with word-wrap — use inside custom labels |
| `PolarGrid` | Grid inside RadarChart |
| `PolarAngleAxis` | Angle axis inside RadarChart |
| `PolarRadiusAxis` | Radius axis inside RadarChart |

---

### Learning Roadmap

#### Stage 1 — Learn First (Week 1)

These are the building blocks that appear in every chart:

1. Install Recharts and render a basic `LineChart` with hardcoded data
2. Add `ResponsiveContainer` — understand parent height requirements
3. Add `XAxis`, `YAxis`, `CartesianGrid`, `Tooltip`, `Legend`
4. Switch to `BarChart` — grouped and stacked modes
5. Add `Cell` to color individual bars
6. Understand the `data` array shape — flat objects, one key per series

**Milestone**: Build a static monthly revenue bar chart with a tooltip.

---

#### Stage 2 — Learn Next (Week 2)

7. `AreaChart` with gradient fills using `<defs>`
8. `PieChart` / donut with `innerRadius`
9. `ReferenceLine` for target/average overlays
10. `LabelList` for data labels on bars
11. Custom Tooltip component
12. `tickFormatter` on `XAxis`/`YAxis` — currency, dates, compact numbers
13. `ComposedChart` — mix Bar + Line

**Milestone**: Build a revenue dashboard with KPI cards, a composed chart (bars + growth line), and a donut chart for segment breakdown.

---

#### Stage 3 — Intermediate (Weeks 3–4)

14. `ResponsiveContainer` aspect ratios and mobile adaptation
15. Interactive legend — toggle series with `useState`
16. `ReferenceArea` for highlighting periods
17. `Brush` for zoom on time-series
18. `syncId` for synchronized multi-chart views
19. Dark mode via a theme token system
20. `React.memo` and `useMemo` — preventing unnecessary re-renders
21. Time-series data with `type="number" scale="time"` on `XAxis`

**Milestone**: Build a synchronized monitoring dashboard with two or more linked charts and a shared date range filter.

---

#### Stage 4 — Advanced (Month 2)

22. Custom bar shapes (`shape` prop)
23. Custom dot rendering (`dot` prop)
24. `activeShape` on `PieChart`
25. Drill-down navigation pattern
26. Cross-filtering dashboard
27. LTTB downsampling for large datasets
28. Accessibility: data table fallback, ARIA announcer, keyboard navigation
29. TypeScript — generic chart components, typed event handlers
30. `ChartContainer` base component (loading/error/empty states)

**Milestone**: Build a full analytics dashboard module with a reusable chart library, theme system, and TypeScript throughout.

---

#### Stage 5 — Expert

31. Real-time streaming charts with WebSocket
32. SVG `<Customized>` component for arbitrary overlays
33. Custom series shapes with D3 path math
34. Accessible chart patterns meeting WCAG 2.1 AA
35. Performance profiling and virtualized chart lists
36. Design system integration — Storybook stories, design token governance
37. Evaluating when to leave Recharts (ECharts, uPlot, D3 raw)

---

### The 80/20 Guide

#### The 20% of Recharts that delivers 80% of real-world value:

**1. `ResponsiveContainer` (correctly used)**
Every chart in production needs this. Master the parent height requirement once and never debug it again.

**2. `LineChart` with `XAxis`, `YAxis`, `CartesianGrid`, `Tooltip`, `Legend`**
This five-component combination is 80% of all charts you will ever build. Get it fluent.

**3. `ComposedChart` with Bar + Line**
The "revenue bar + growth line" chart appears in every analytics product. Combining bar and line on a biaxial chart is a single skill that covers a huge portion of dashboard requirements.

**4. Custom Tooltip**
The default tooltip is almost never acceptable in production. Writing one custom tooltip component and reusing it everywhere is one of the highest-ROI skills.

**5. `Cell` for dynamic coloring**
Color bars by positive/negative, by category, by rank — this single component makes charts informative instead of decorative.

**6. `tickFormatter` on axes**
Currency, compact numbers, date formatting — the difference between `123456.78` and `$124k` on an axis is entirely this prop.

**7. `PieChart` / donut pattern**
Part-to-whole charts appear everywhere. The donut with `activeShape` for hover detail is the production-quality version of a pie chart.

**8. `ReferenceLine`**
Adding a target, average, or threshold line transforms a descriptive chart into an analytical one.

**9. `React.memo` + `useMemo` on chart components**
Without memoization, dashboard performance degrades as you add charts. Apply these early and you'll never fight re-render waterfalls.

**10. `ChartContainer` base component (your own)**
Building one container that handles loading/error/empty state, wraps `ResponsiveContainer`, and accepts title/description turns 30 lines of per-chart boilerplate into a single reusable component. This is the highest-leverage architectural move in any chart system.

---

### What to Ignore Until You Need It

- `SankeyChart` — immature in Recharts v2; use a D3-based implementation for production
- `RadarChart` — useful for a specific use case (multi-dimensional comparison) but rarely needed
- `Surface` — internal primitive, not needed in application code
- `Polygon`, `Trapezoid`, `Curve`, `Sector` — SVG primitives only needed when building fully custom chart types
- `Brush` — useful but a niche feature; skip until a user specifically asks for time-series zoom
- `ZAxis` — only needed for bubble charts (ScatterChart with sized points)

---

### Quick Reference: Common Patterns in Two Lines

```tsx
// Gradient area fill
<defs><linearGradient id="g1" x1="0" y1="0" x2="0" y2="1"><stop offset="5%" stopColor="#6366f1" stopOpacity={0.15}/><stop offset="95%" stopColor="#6366f1" stopOpacity={0}/></linearGradient></defs>
<Area fill="url(#g1)" stroke="#6366f1" />

// Currency Y-axis
<YAxis tickFormatter={(v) => new Intl.NumberFormat('en', { notation: 'compact', style: 'currency', currency: 'USD' }).format(v)} />

// Date X-axis from ISO strings
<XAxis dataKey="date" tickFormatter={(d) => format(parseISO(d), 'MMM d')} />

// Rounded bar tops
<Bar radius={[4, 4, 0, 0]} />

// Dynamic bar color by value
<Bar>{data.map((d, i) => <Cell key={i} fill={d.value >= 0 ? '#10b981' : '#ef4444'} />)}</Bar>

// Disable all animation
<Line isAnimationActive={false} />
<Bar isAnimationActive={false} />

// Hide axis lines but keep ticks
<XAxis axisLine={false} tickLine={false} />

// Biaxial chart
<YAxis yAxisId="left" /><YAxis yAxisId="right" orientation="right" />
<Bar yAxisId="left" /><Line yAxisId="right" />

// Sync tooltip across charts
<LineChart syncId="dashboard"><Tooltip /></LineChart>
<BarChart syncId="dashboard"><Tooltip /></BarChart>

// Toggle series hide
<Line hide={hiddenKeys.has('revenue')} />

// Compact number formatter
const fmtCompact = new Intl.NumberFormat('en', { notation: 'compact' });
<YAxis tickFormatter={(v) => fmtCompact.format(v)} />
```

---

*Guide complete. All behavioral claims about Recharts are labeled `[Inference]` or `[Unverified]` where not confirmed against a live environment. API shapes follow Recharts v2.x documentation. Validate props against the version in your `package.json`.*