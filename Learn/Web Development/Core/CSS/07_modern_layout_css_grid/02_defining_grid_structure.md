## Defining Grid Structure


### Grid Template Rows and Columns

The foundation of any CSS Grid layout begins with defining the grid structure using `grid-template-rows` and `grid-template-columns`. These properties establish the explicit grid by specifying the size of rows and columns respectively.

```css
.grid-container {
  display: grid;
  grid-template-columns: 200px 1fr 100px;
  grid-template-rows: 80px 300px 60px;
}
```

You can define tracks using various units including pixels, percentages, ems, viewport units, and the flexible `fr` unit. The grid will create exactly the number of tracks you specify, with each value corresponding to the size of that track in order.

**Example**

```css
/* Three columns: fixed, flexible, fixed */
grid-template-columns: 250px 1fr 150px;

/* Four rows with different sizing approaches */
grid-template-rows: auto 200px 1fr 50px;
```

### Fr Unit and Repeat Function

The `fr` (fraction) unit represents a fraction of the available space in the grid container. It's particularly powerful for creating responsive layouts that adapt to container size changes.

```css
.grid-container {
  grid-template-columns: 1fr 2fr 1fr; /* Creates three columns with 1:2:1 ratio */
}
```

The `repeat()` function eliminates repetitive code when creating multiple tracks of the same size. It accepts two parameters: the number of repetitions and the track size pattern.

```css
/* Instead of writing: 1fr 1fr 1fr 1fr */
grid-template-columns: repeat(4, 1fr);

/* Complex patterns can also be repeated */
grid-template-columns: repeat(3, 100px 1fr);
/* Results in: 100px 1fr 100px 1fr 100px 1fr */
```

**Key points**

- `fr` units distribute remaining space after fixed-size tracks are placed
- Multiple `fr` values create proportional relationships
- `repeat()` can combine with other track definitions
- Pattern repetition allows for complex, consistent layouts

### Minmax and Auto-fit/Auto-fill

The `minmax()` function provides flexible sizing constraints by defining minimum and maximum track sizes. This creates responsive tracks that grow and shrink within specified bounds.

```css
.grid-container {
  grid-template-columns: repeat(3, minmax(200px, 1fr));
}
```

This creates three columns that are never smaller than 200px but can grow to fill available space equally.

`auto-fit` and `auto-fill` work with `repeat()` to create dynamic grid layouts that automatically adjust the number of tracks based on available space:

- `auto-fill` creates as many tracks as will fit, leaving empty tracks if items don't fill them
- `auto-fit` creates tracks only for existing items, collapsing empty tracks

```css
/* auto-fill: maintains empty tracks */
grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));

/* auto-fit: collapses empty tracks */
grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
```

**Example**

```css
.responsive-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
}
```

This creates a responsive grid where items are at least 300px wide, and the number of columns adjusts automatically based on container width.

### Grid Gaps

Grid gaps create consistent spacing between grid tracks without affecting the outer edges of the grid container. The `gap` property (formerly `grid-gap`) controls both row and column gaps simultaneously, or you can set them individually.

```css
.grid-container {
  display: grid;
  gap: 20px; /* Sets both row and column gaps */
}

/* Or set individually */
.grid-container {
  row-gap: 15px;
  column-gap: 25px;
}

/* Shorthand with different values */
.grid-container {
  gap: 15px 25px; /* row-gap column-gap */
}
```

Gaps are applied consistently between all tracks, creating uniform spacing throughout the grid. They don't add space around the outside edges of the grid container, only between internal tracks.

**Key points**

- Gaps apply only between tracks, not around the container edges
- Gap values can use any CSS length unit
- Gaps are included in fr unit calculations
- Different row and column gap values allow for asymmetric spacing

### Advanced Grid Structure Techniques

#### Named Grid Lines

You can assign names to grid lines for more semantic grid definitions:

```css
.grid-container {
  grid-template-columns: [sidebar-start] 250px [sidebar-end main-start] 1fr [main-end];
  grid-template-rows: [header-start] 80px [header-end content-start] 1fr [content-end footer-start] 60px [footer-end];
}
```

#### Implicit Grid Behavior

When grid items are placed outside the explicit grid, CSS Grid automatically creates implicit tracks. You can control the size of these implicit tracks:

```css
.grid-container {
  grid-auto-rows: minmax(100px, auto);
  grid-auto-columns: 1fr;
  grid-auto-flow: row; /* or column, row dense, column dense */
}
```

#### Subgrid

The `subgrid` value allows nested grids to inherit track sizing from their parent grid:

```css
.parent-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
}

.nested-grid {
  display: grid;
  grid-template-columns: subgrid;
  grid-column: span 3;
}
```

**Conclusion** Mastering grid structure definition provides the foundation for creating sophisticated, responsive layouts. The combination of explicit sizing with `grid-template-rows` and `grid-template-columns`, flexible units like `fr`, powerful functions like `repeat()` and `minmax()`, and automatic sizing with `auto-fit`/`auto-fill` creates a comprehensive toolkit for modern web layouts. Grid gaps ensure consistent spacing, while advanced features like named lines and implicit grid behavior provide additional control over complex layouts.

---

