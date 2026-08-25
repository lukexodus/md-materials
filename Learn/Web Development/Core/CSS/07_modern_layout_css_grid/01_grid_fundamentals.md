## Grid Fundamentals


### Grid Container vs Grid Items

The CSS Grid system operates on a parent-child relationship between grid containers and grid items. The grid container is the parent element that establishes the grid formatting context, while grid items are the direct children that get positioned within the grid.

A grid container is created by applying `display: grid` or `display: inline-grid` to an element. This transforms the element into a grid container, making all of its direct children become grid items automatically. The grid container defines the overall grid structure, including the number of columns and rows, their sizes, and the gaps between them.

Grid items are the direct children of a grid container. They can be any HTML element - divs, paragraphs, images, or any other element. Importantly, only direct children become grid items; nested elements within grid items do not participate in the grid layout unless they themselves become grid containers.

The grid container controls the positioning and sizing of grid items through various grid properties. Grid items can span multiple cells, be positioned in specific areas, and can even overlap with other grid items when explicitly positioned.

**Key points:**

- Grid container: parent element with `display: grid` or `display: inline-grid`
- Grid items: direct children of the grid container
- Only direct children participate in the grid layout
- Grid container defines the overall structure and rules
- Grid items are positioned according to the container's grid properties

### Grid Lines, Tracks, Cells, and Areas

The CSS Grid system uses a coordinate-based approach with several key structural elements that define how content is organized and positioned.

Grid lines are the horizontal and vertical lines that form the structure of the grid. They can be numbered or named, and they define the boundaries of grid tracks. Grid lines are numbered starting from 1, and you can also count backwards using negative numbers (-1 being the last line). Horizontal lines run from left to right, while vertical lines run from top to bottom.

Grid tracks are the spaces between grid lines - essentially the columns and rows of the grid. A grid track is defined by two parallel grid lines. Column tracks run vertically between two vertical grid lines, while row tracks run horizontally between two horizontal grid lines. The size of grid tracks can be defined using various units including pixels, percentages, fr units, and flexible sizing functions.

Grid cells represent the intersection of a row track and a column track - the smallest unit of the grid. Each cell is bounded by four grid lines: two horizontal and two vertical. Grid cells are similar to table cells but with much more flexibility in terms of sizing and positioning.

Grid areas are rectangular regions that can span multiple grid cells. They are defined by four grid lines: two horizontal lines (defining the top and bottom boundaries) and two vertical lines (defining the left and right boundaries). Grid areas can be created implicitly by positioning grid items or explicitly by defining named grid areas using the `grid-template-areas` property.

**Key points:**

- Grid lines: boundaries that form the grid structure (numbered from 1 or named)
- Grid tracks: spaces between parallel grid lines (columns and rows)
- Grid cells: smallest units formed by intersection of row and column tracks
- Grid areas: rectangular regions spanning one or more cells
- All elements work together to create flexible, precise layouts

**Example:**

```css
.grid-container {
  display: grid;
  grid-template-columns: 100px 200px 100px; /* Creates 4 vertical grid lines, 3 column tracks */
  grid-template-rows: 50px 100px; /* Creates 3 horizontal grid lines, 2 row tracks */
}

.grid-item {
  grid-column: 1 / 3; /* Spans from grid line 1 to grid line 3 */
  grid-row: 1 / 2; /* Spans from grid line 1 to grid line 2 */
}
```

### Display: Grid and Inline-Grid

The `display` property values `grid` and `inline-grid` are the foundation for creating grid layouts, but they behave differently in how they interact with surrounding content and establish their formatting context.

`display: grid` creates a block-level grid container. This means the grid container behaves like a block element in the document flow, taking up the full width of its parent container by default and creating a new line both before and after itself. The grid container establishes a new block formatting context, and its internal grid layout is completely independent of the external layout context.

`display: inline-grid` creates an inline-level grid container. The grid container behaves like an inline element in the document flow, only taking up as much width as needed for its content and flowing alongside other inline elements on the same line. Despite being inline on the outside, it still establishes a grid formatting context internally, allowing its children to be arranged in a grid layout.

The choice between `grid` and `inline-grid` depends on how you want the grid container to interact with surrounding content. Use `grid` when you want the grid container to behave like a block element, and use `inline-grid` when you want it to flow inline with other content while maintaining internal grid behavior.

Both values establish the same internal grid formatting context, meaning all grid properties and behaviors work identically inside the container. The only difference is the external display behavior - how the grid container itself participates in the layout of its parent container.

**Key points:**

- `display: grid` creates a block-level grid container
- `display: inline-grid` creates an inline-level grid container
- Both establish identical internal grid formatting contexts
- Block-level grids take full width and create new lines
- Inline-level grids flow with surrounding inline content
- Internal grid behavior is identical regardless of external display type

**Example:**

```css
/* Block-level grid - takes full width, creates new lines */
.block-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
}

/* Inline-level grid - flows with surrounding content */
.inline-grid {
  display: inline-grid;
  grid-template-columns: 100px 100px;
}
```

### Grid Formatting Context

When an element becomes a grid container, it establishes a new grid formatting context. This is a fundamental concept that affects how elements within the grid behave and interact with each other and with elements outside the grid.

The grid formatting context means that the internal layout of the grid container is completely independent from the external layout context. Elements inside the grid are positioned according to grid rules, not according to normal document flow rules like block and inline formatting. This isolation allows for complex layouts without affecting or being affected by surrounding elements.

Within the grid formatting context, several important behaviors occur. Float and clear properties have no effect on grid items, as they are not part of the normal document flow. Vertical margins between grid items do not collapse, unlike in block formatting contexts. Grid items can overlap each other when explicitly positioned, which is not possible in normal document flow without absolute positioning.

The grid formatting context also affects how percentage values are resolved. Percentage widths and heights on grid items are resolved against the grid area they occupy, not against the entire grid container. This provides more predictable sizing behavior for grid items.

**Key points:**

- Grid containers establish independent formatting contexts
- Internal grid layout is isolated from external layout
- Float and clear properties don't affect grid items
- Margins don't collapse between grid items
- Grid items can overlap when positioned
- Percentage values resolve against grid areas, not the container

### Grid Item Behavior and Characteristics

Grid items have unique characteristics and behaviors that distinguish them from elements in other layout systems. Understanding these behaviors is crucial for effective grid layout implementation.

Grid items are automatically assigned to grid cells based on the grid's auto-placement algorithm if not explicitly positioned. The auto-placement algorithm fills grid cells in order, moving from left to right and top to bottom by default. This behavior can be modified using the `grid-auto-flow` property to change the direction or to prefer filling sparse areas.

Grid items can span multiple cells using the `grid-column` and `grid-row` properties. This spanning behavior allows for complex layouts where items occupy rectangular areas of various sizes. When items span multiple cells, they create a single grid area that can be styled and positioned as a unit.

The sizing of grid items is controlled by both the grid container's track sizing and the grid item's own sizing properties. Grid items can be sized using intrinsic sizing (based on their content), extrinsic sizing (based on the grid tracks they occupy), or a combination of both. The `align-self` and `justify-self` properties control how grid items are positioned within their assigned grid areas.

Grid items can be positioned outside the explicit grid (the grid defined by `grid-template-columns` and `grid-template-rows`). When this happens, implicit grid tracks are automatically created to accommodate the positioned items. These implicit tracks are sized according to the `grid-auto-columns` and `grid-auto-rows` properties.

**Key points:**

- Grid items are automatically placed by the auto-placement algorithm
- Items can span multiple cells to create larger grid areas
- Sizing is controlled by both container and item properties
- Items can be positioned outside the explicit grid
- Implicit tracks are created automatically when needed
- Alignment properties control positioning within grid areas

---

