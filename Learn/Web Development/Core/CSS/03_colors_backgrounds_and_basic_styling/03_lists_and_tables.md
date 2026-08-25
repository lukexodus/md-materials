## Lists and Tables


### List Styling Properties

Lists are fundamental HTML elements that can be extensively customized using CSS to create navigation menus, content hierarchies, and decorative elements.

#### Basic List Properties

**List-style-type:** Controls the marker type for list items.

```css
/* Unordered list markers */
ul.bullets { list-style-type: disc; }
ul.circles { list-style-type: circle; }
ul.squares { list-style-type: square; }
ul.none { list-style-type: none; }

/* Ordered list markers */
ol.decimal { list-style-type: decimal; }
ol.roman-lower { list-style-type: lower-roman; }
ol.roman-upper { list-style-type: upper-roman; }
ol.alpha-lower { list-style-type: lower-alpha; }
ol.alpha-upper { list-style-type: upper-alpha; }
ol.leading-zero { list-style-type: decimal-leading-zero; }
```

**List-style-position:** Controls marker placement relative to the list item content.

```css
.outside-markers {
    list-style-position: outside; /* Default - markers outside content flow */
}

.inside-markers {
    list-style-position: inside; /* Markers inside content flow */
}
```

**List-style-image:** Uses custom images as list markers.

```css
.custom-bullets {
    list-style-image: url('bullet-icon.png');
}

.arrow-list {
    list-style-image: url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAiIGhlaWdodD0iMTAiPjxwb2x5Z29uIHBvaW50cz0iMCwwIDEwLDUgMCwxMCIgZmlsbD0iIzMzMyIvPjwvc3ZnPg==');
}
```

**List-style shorthand:**

```css
.shorthand-list {
    list-style: square inside url('custom-marker.png');
    /* type position image */
}
```

#### Advanced List Styling

**Removing default styling:**

```css
.reset-list {
    list-style: none;
    margin: 0;
    padding: 0;
}

.reset-list li {
    margin: 0;
    padding: 0;
}
```

**Custom markers with pseudo-elements:**

```css
.custom-list {
    list-style: none;
    padding-left: 0;
}

.custom-list li {
    position: relative;
    padding-left: 25px;
    margin-bottom: 10px;
}

.custom-list li::before {
    content: "→";
    position: absolute;
    left: 0;
    color: #007bff;
    font-weight: bold;
}

/* Numbered custom markers */
.custom-counter {
    list-style: none;
    counter-reset: custom-counter;
    padding-left: 0;
}

.custom-counter li {
    counter-increment: custom-counter;
    position: relative;
    padding-left: 40px;
    margin-bottom: 15px;
}

.custom-counter li::before {
    content: counter(custom-counter);
    position: absolute;
    left: 0;
    top: 0;
    background: #007bff;
    color: white;
    width: 25px;
    height: 25px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 14px;
    font-weight: bold;
}
```

#### Navigation Lists

**Horizontal navigation:**

```css
.nav-horizontal {
    list-style: none;
    margin: 0;
    padding: 0;
    display: flex;
}

.nav-horizontal li {
    margin-right: 20px;
}

.nav-horizontal a {
    display: block;
    padding: 10px 15px;
    text-decoration: none;
    background: #f8f9fa;
    border-radius: 5px;
    transition: background 0.3s ease;
}

.nav-horizontal a:hover {
    background: #007bff;
    color: white;
}
```

**Vertical navigation with styling:**

```css
.nav-vertical {
    list-style: none;
    margin: 0;
    padding: 0;
    background: #343a40;
    border-radius: 8px;
    overflow: hidden;
}

.nav-vertical li {
    border-bottom: 1px solid #495057;
}

.nav-vertical li:last-child {
    border-bottom: none;
}

.nav-vertical a {
    display: block;
    padding: 15px 20px;
    color: #fff;
    text-decoration: none;
    transition: background 0.3s ease;
}

.nav-vertical a:hover {
    background: #495057;
}
```

#### Multi-level Lists

**Nested list styling:**

```css
.nested-list {
    list-style: none;
    padding-left: 0;
}

.nested-list li {
    margin-bottom: 5px;
    position: relative;
    padding-left: 20px;
}

.nested-list li::before {
    content: "•";
    position: absolute;
    left: 0;
    color: #007bff;
}

/* Second level */
.nested-list ul {
    list-style: none;
    margin: 10px 0;
    padding-left: 20px;
}

.nested-list ul li::before {
    content: "◦";
    color: #6c757d;
}

/* Third level */
.nested-list ul ul li::before {
    content: "▪";
    color: #adb5bd;
}
```

### Table Styling and Layout

Tables require specific styling approaches due to their unique structure and layout behavior.

#### Basic Table Structure and Styling

**Table reset and base styling:**

```css
table {
    border-collapse: collapse;
    width: 100%;
    margin-bottom: 20px;
    background-color: transparent;
}

th, td {
    padding: 12px 15px;
    text-align: left;
    vertical-align: top;
    border-bottom: 1px solid #dee2e6;
}

th {
    background-color: #f8f9fa;
    font-weight: 600;
    color: #495057;
    border-bottom: 2px solid #dee2e6;
}
```

**Table layout control:**

```css
/* Fixed table layout - faster rendering, equal column widths */
.table-fixed {
    table-layout: fixed;
    width: 100%;
}

.table-fixed th,
.table-fixed td {
    width: 25%; /* Equal width columns */
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

/* Auto table layout - content-based column widths */
.table-auto {
    table-layout: auto;
}
```

#### Advanced Table Styling

**Striped tables:**

```css
.table-striped tbody tr:nth-child(odd) {
    background-color: #f8f9fa;
}

.table-striped tbody tr:nth-child(even) {
    background-color: #ffffff;
}
```

**Hoverable rows:**

```css
.table-hover tbody tr {
    transition: background-color 0.15s ease-in-out;
}

.table-hover tbody tr:hover {
    background-color: #e9ecef;
}
```

**Bordered tables:**

```css
.table-bordered {
    border: 1px solid #dee2e6;
}

.table-bordered th,
.table-bordered td {
    border: 1px solid #dee2e6;
}

.table-bordered thead th,
.table-bordered thead td {
    border-bottom-width: 2px;
}
```

**Compact tables:**

```css
.table-sm th,
.table-sm td {
    padding: 6px 10px;
    font-size: 14px;
}
```

#### Responsive Tables

**Scrollable tables:**

```css
.table-responsive {
    display: block;
    width: 100%;
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
}

.table-responsive table {
    min-width: 600px; /* Minimum width before scrolling */
}
```

**Mobile-friendly table transformation:**

```css
@media (max-width: 768px) {
    .table-mobile {
        border: 0;
    }
    
    .table-mobile thead {
        border: none;
        clip: rect(0 0 0 0);
        height: 1px;
        margin: -1px;
        overflow: hidden;
        padding: 0;
        position: absolute;
        width: 1px;
    }
    
    .table-mobile tr {
        border: 1px solid #ccc;
        display: block;
        margin-bottom: 10px;
        padding: 10px;
    }
    
    .table-mobile td {
        border: none;
        display: block;
        text-align: right;
        padding-left: 50%;
        position: relative;
    }
    
    .table-mobile td::before {
        content: attr(data-label) ": ";
        position: absolute;
        left: 10px;
        width: 45%;
        text-align: left;
        font-weight: bold;
    }
}
```

#### Table Caption and Accessibility

**Table captions:**

```css
caption {
    font-size: 18px;
    font-weight: bold;
    margin-bottom: 10px;
    text-align: left;
    color: #495057;
}

.caption-top {
    caption-side: top; /* Default */
}

.caption-bottom {
    caption-side: bottom;
}
```

**Accessible table styling:**

```css
/* Focus styles for keyboard navigation */
.table-accessible th:focus,
.table-accessible td:focus {
    outline: 2px solid #007bff;
    outline-offset: -2px;
}

/* Screen reader friendly sorting indicators */
.sortable th {
    cursor: pointer;
    position: relative;
    padding-right: 30px;
}

.sortable th::after {
    content: "↕";
    position: absolute;
    right: 10px;
    opacity: 0.5;
}

.sortable th.sort-asc::after {
    content: "↑";
    opacity: 1;
}

.sortable th.sort-desc::after {
    content: "↓";
    opacity: 1;
}
```

### Border-collapse and Spacing

Border-collapse is a crucial property that affects how table borders are rendered and how spacing is handled.

#### Border-collapse Property

**Collapse vs Separate:**

```css
/* Collapsed borders - adjacent borders merge */
.table-collapse {
    border-collapse: collapse;
    border-spacing: 0; /* Ignored when collapsed */
}

.table-collapse th,
.table-collapse td {
    border: 1px solid #dee2e6;
}

/* Separated borders - borders remain distinct */
.table-separate {
    border-collapse: separate;
    border-spacing: 2px; /* Space between cells */
}

.table-separate th,
.table-separate td {
    border: 1px solid #dee2e6;
}
```

#### Border-spacing Property

Border-spacing only applies when `border-collapse: separate` is used.

```css
/* Uniform spacing */
.table-spaced {
    border-collapse: separate;
    border-spacing: 5px;
}

/* Different horizontal and vertical spacing */
.table-custom-spacing {
    border-collapse: separate;
    border-spacing: 10px 5px; /* horizontal vertical */
}

/* No spacing */
.table-no-spacing {
    border-collapse: separate;
    border-spacing: 0;
}
```

#### Advanced Border Techniques

**Custom border patterns:**

```css
.table-custom-borders {
    border-collapse: collapse;
}

/* Remove all borders first */
.table-custom-borders th,
.table-custom-borders td {
    border: none;
}

/* Add specific borders */
.table-custom-borders thead th {
    border-bottom: 3px solid #007bff;
}

.table-custom-borders tbody tr {
    border-bottom: 1px solid #e9ecef;
}

.table-custom-borders tbody tr:last-child {
    border-bottom: none;
}

/* Vertical borders only */
.table-vertical-borders th:not(:last-child),
.table-vertical-borders td:not(:last-child) {
    border-right: 1px solid #dee2e6;
}
```

**Rounded table corners with separate borders:**

```css
.table-rounded {
    border-collapse: separate;
    border-spacing: 0;
    border: 1px solid #dee2e6;
    border-radius: 8px;
    overflow: hidden;
}

.table-rounded th:first-child {
    border-top-left-radius: 8px;
}

.table-rounded th:last-child {
    border-top-right-radius: 8px;
}

.table-rounded tr:last-child td:first-child {
    border-bottom-left-radius: 8px;
}

.table-rounded tr:last-child td:last-child {
    border-bottom-right-radius: 8px;
}
```

#### Empty-cells Property

Controls the display of empty table cells when using separated borders.

```css
.table-hide-empty {
    border-collapse: separate;
    empty-cells: hide; /* Hide borders and background of empty cells */
}

.table-show-empty {
    border-collapse: separate;
    empty-cells: show; /* Default - show empty cells */
}
```

#### Complex Table Layouts

**Multi-level headers:**

```css
.complex-table {
    border-collapse: collapse;
}

.complex-table th {
    background: #f8f9fa;
    border: 1px solid #dee2e6;
    text-align: center;
    padding: 10px;
}

.complex-table .header-group {
    background: #e9ecef;
    font-weight: bold;
}

.complex-table .sub-header {
    background: #f8f9fa;
    font-weight: normal;
    font-size: 14px;
}
```

**Table with row and column spans:**

```css
.spanning-table {
    border-collapse: collapse;
}

.spanning-table td,
.spanning-table th {
    border: 1px solid #dee2e6;
    padding: 10px;
    text-align: center;
}

.spanning-table .span-header {
    background: #007bff;
    color: white;
    font-weight: bold;
}

.spanning-table .span-data {
    background: #f8f9fa;
}
```

**Key points:**

- `border-collapse: collapse` merges adjacent borders for cleaner appearance
- `border-collapse: separate` maintains distinct borders and allows border-spacing
- Border-spacing only works with separated borders
- Empty-cells property controls visibility of empty cells in separated border mode
- Table layout can be fixed or auto, affecting rendering performance and column behavior
- Responsive table design requires careful consideration of mobile viewing patterns

**Conclusion:** Lists and tables are fundamental content structures that benefit from thoughtful CSS styling. List properties provide extensive customization options for creating everything from simple bullet points to complex navigation systems. Table styling requires understanding the unique behavior of border-collapse and spacing properties to achieve desired visual effects. Modern responsive design considerations are essential for both lists and tables to ensure usability across all device types.

---
