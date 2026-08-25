## Placing Grid Items


### Grid-column and Grid-row

The `grid-column` and `grid-row` properties allow precise positioning of grid items by specifying which grid lines they should start and end on. These properties provide granular control over item placement within the grid structure.

**Key points for grid-column:**

- `grid-column-start`: Specifies the starting column line
- `grid-column-end`: Specifies the ending column line
- `grid-column`: Shorthand combining start and end values
- Syntax: `grid-column: start / end` or `grid-column: start / span count`

**Key points for grid-row:**

- `grid-row-start`: Specifies the starting row line
- `grid-row-end`: Specifies the ending row line
- `grid-row`: Shorthand combining start and end values
- Syntax: `grid-row: start / end` or `grid-row: start / span count`

Grid lines are numbered starting from 1, and you can also use negative numbers to count from the end of the grid. The `span` keyword allows you to specify how many tracks the item should occupy rather than explicit end lines.

**Example:**

```css
.grid-container {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  grid-template-rows: repeat(3, 100px);
}

.item1 {
  grid-column: 1 / 3;     /* Spans from line 1 to line 3 */
  grid-row: 1 / 2;        /* Occupies first row */
}

.item2 {
  grid-column: 3 / span 2; /* Starts at line 3, spans 2 columns */
  grid-row: 2 / -1;        /* Starts at row 2, ends at last line */
}
```

When grid items overlap, the `z-index` property determines stacking order. Items placed later in the HTML naturally stack above earlier items unless explicitly controlled.

### Grid-area and Named Grid Lines

The `grid-area` property provides a concise way to specify all four grid boundaries simultaneously, while named grid lines offer semantic clarity for complex layouts.

**Key points for grid-area:**

- Shorthand syntax: `grid-area: row-start / column-start / row-end / column-end`
- Can reference line numbers, named lines, or span values
- Provides single-property positioning for complete item placement
- When used with grid-template-areas, references named areas

**Key points for named grid lines:**

- Defined within `grid-template-columns` and `grid-template-rows`
- Syntax: `[line-name] track-size [line-name]`
- Multiple names can be assigned to the same line
- Improves code readability and maintainability

Named grid lines create semantic meaning in your grid layout, making it easier to understand and maintain complex positioning logic. They're particularly valuable in responsive designs where grid structure changes across breakpoints.

**Example:**

```css
.grid-container {
  display: grid;
  grid-template-columns: [sidebar-start] 200px [sidebar-end main-start] 1fr [main-end];
  grid-template-rows: [header-start] 80px [header-end content-start] 1fr [content-end];
}

.header {
  grid-area: header-start / sidebar-start / header-end / main-end;
}

.sidebar {
  grid-area: content-start / sidebar-start / content-end / sidebar-end;
}

.main-content {
  grid-area: content-start / main-start / content-end / main-end;
}
```

When naming grid lines, CSS automatically creates implicit area names. For example, lines named `sidebar-start` and `sidebar-end` create a `sidebar` area that can be referenced directly.

### Grid-template-areas

The `grid-template-areas` property creates a visual ASCII-art representation of the grid layout, making complex designs intuitive to understand and modify. This approach combines grid structure definition with semantic area naming.

**Key points:**

- Each string represents a grid row
- Each word within a string represents a grid cell
- Identical names create rectangular areas spanning multiple cells
- Empty cells represented by dots (.) or the keyword `none`
- Area names must form rectangles (no L-shapes or disconnected areas)

This method excels for creating common layout patterns like headers, sidebars, and footers. The visual nature makes it immediately clear how the layout is structured, and changes to the template automatically reposition items.

**Example:**

```css
.grid-container {
  display: grid;
  grid-template-columns: 200px 1fr 200px;
  grid-template-rows: auto 1fr auto;
  grid-template-areas:
    "header header header"
    "sidebar main ads"
    "footer footer footer";
}

.header { grid-area: header; }
.sidebar { grid-area: sidebar; }
.main { grid-area: main; }
.ads { grid-area: ads; }
.footer { grid-area: footer; }
```

For responsive designs, you can redefine grid-template-areas at different breakpoints to completely restructure the layout:

**Example:**

```css
/* Mobile layout */
@media (max-width: 768px) {
  .grid-container {
    grid-template-columns: 1fr;
    grid-template-areas:
      "header"
      "main"
      "sidebar"
      "ads"
      "footer";
  }
}
```

Areas can be partially empty using dots, allowing for complex layouts with intentional white space:

**Example:**

```css
.complex-grid {
  grid-template-areas:
    "logo nav nav nav"
    "sidebar main main ."
    "sidebar main main ads"
    "footer footer footer footer";
}
```

**Output:** These grid placement methods offer different levels of control and semantic meaning. Line-based positioning provides precise control for individual items, named grid lines add semantic clarity while maintaining flexibility, and grid-template-areas creates intuitive visual layouts perfect for page-level structures.

**Conclusion:** Mastering these three approaches to grid item placement enables you to choose the most appropriate method for each layout challenge. Simple positioning benefits from grid-column and grid-row properties, complex layouts gain clarity from named grid lines, and page-level designs become intuitive with grid-template-areas. Understanding when to apply each technique results in maintainable, responsive grid layouts that clearly communicate design intent.

---
