## Table Fundamentals


### When to Use Tables

Tables should be used exclusively for displaying tabular data - information that has relationships between rows and columns. The decision between using tables versus other layout methods is crucial for accessibility, semantics, and maintainability.

#### Appropriate Table Use Cases

Tables are designed for structured data where information is organized in rows and columns with meaningful relationships. Financial reports, statistical data, comparison charts, schedules, and product specifications are ideal candidates for table markup.

**Key points:**

- Use for data with clear row/column relationships
- Information that would make sense in a spreadsheet
- Data that benefits from column/row headers
- Content where cell relationships provide meaning
- Scientific data, financial reports, sports statistics

**Example:**

```html
<table>
  <caption>Quarterly Sales Report 2024</caption>
  <thead>
    <tr>
      <th>Product</th>
      <th>Q1</th>
      <th>Q2</th>
      <th>Q3</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Laptops</td>
      <td>$125,000</td>
      <td>$138,000</td>
      <td>$142,000</td>
    </tr>
  </tbody>
</table>
```

#### Inappropriate Table Use Cases

Never use tables for page layout, positioning elements, or creating visual designs. Modern CSS provides superior layout methods that are more flexible, accessible, and maintainable.

**Key points:**

- Avoid for page layout and positioning
- Don't use for creating columns or grids
- Not for aligning form elements
- Inappropriate for navigation menus
- Wrong choice for image galleries or card layouts

**Example of what NOT to do:**

```html
<!-- WRONG: Using table for layout -->
<table>
  <tr>
    <td>Header content</td>
  </tr>
  <tr>
    <td>Main content</td>
    <td>Sidebar</td>
  </tr>
</table>
```

### Basic Table Structure

The foundation of HTML tables consists of three primary elements that work together to create the table structure. Understanding their hierarchy and relationships is essential for proper table construction.

#### Table Element

The `<table>` element serves as the container for all table content. It establishes the table context and provides the foundation for styling and accessibility features.

**Key points:**

- Root container for all table elements
- Establishes table formatting context
- Can contain multiple table sections
- Supports various accessibility attributes
- Default display behavior can be modified with CSS

**Example:**

```html
<table role="table" aria-label="Employee information">
  <!-- Table content goes here -->
</table>
```

#### Table Row Element

The `<tr>` (table row) element defines horizontal rows within the table. Rows contain cells and establish the table's row structure.

**Key points:**

- Creates horizontal divisions in the table
- Must contain only `<td>` or `<th>` elements
- Can be grouped within `<thead>`, `<tbody>`, or `<tfoot>`
- Supports row-specific styling and attributes
- Number of cells should be consistent across rows

**Example:**

```html
<tr class="data-row">
  <td>John Doe</td>
  <td>Software Engineer</td>
  <td>$75,000</td>
</tr>
```

#### Table Data Cell Element

The `<td>` (table data) element represents individual data cells within table rows. These cells contain the actual content and data being presented.

**Key points:**

- Contains the actual table data
- Can span multiple rows or columns
- Supports rich content including other HTML elements
- Inherits alignment and styling properties
- Should contain meaningful, accessible content

**Example:**

```html
<td colspan="2">Merged cell spanning two columns</td>
<td rowspan="3">Cell spanning three rows</td>
<td>
  <img src="profile.jpg" alt="Employee photo" width="50">
  <span>John Smith</span>
</td>
```

### Table Headers

Table headers provide essential context and meaning to table data, significantly improving accessibility and user comprehension. Proper header implementation is crucial for screen readers and data interpretation.

#### Header Cell Element

The `<th>` (table header) element identifies header cells that provide context for data cells. Headers can be column headers, row headers, or both.

**Key points:**

- Provides context and meaning to data cells
- Automatically associated with related data cells
- Typically displayed in bold and centered
- Essential for screen reader accessibility
- Can serve as column headers, row headers, or both

**Example:**

```html
<thead>
  <tr>
    <th scope="col">Employee Name</th>
    <th scope="col">Department</th>
    <th scope="col">Salary</th>
    <th scope="col">Start Date</th>
  </tr>
</thead>
```

#### Header Scope Attribute

The `scope` attribute explicitly defines which cells a header applies to, improving accessibility and data relationships.

**Key points:**

- `scope="col"` for column headers
- `scope="row"` for row headers
- `scope="colgroup"` for header groups spanning multiple columns
- `scope="rowgroup"` for header groups spanning multiple rows
- Essential for complex tables with multiple header levels

**Example:**

```html
<table>
  <thead>
    <tr>
      <th scope="col">Product</th>
      <th scope="colgroup" colspan="4">Quarterly Sales</th>
    </tr>
    <tr>
      <th scope="col">Name</th>
      <th scope="col">Q1</th>
      <th scope="col">Q2</th>
      <th scope="col">Q3</th>
      <th scope="col">Q4</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">Laptops</th>
      <td>$50K</td>
      <td>$55K</td>
      <td>$48K</td>
      <td>$62K</td>
    </tr>
  </tbody>
</table>
```

#### Complex Header Relationships

For tables with multiple header levels or complex relationships, use `headers` attribute to explicitly associate data cells with their corresponding headers.

**Example:**

```html
<table>
  <thead>
    <tr>
      <th id="product">Product</th>
      <th id="sales" colspan="2">Sales</th>
    </tr>
    <tr>
      <th id="name">Name</th>
      <th id="domestic" headers="sales">Domestic</th>
      <th id="international" headers="sales">International</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td headers="product name">Widget A</td>
      <td headers="sales domestic">$100K</td>
      <td headers="sales international">$75K</td>
    </tr>
  </tbody>
</table>
```

### Table Captions

Table captions provide a title or description for the entire table, serving as an important accessibility feature and helping users understand the table's purpose and content.

#### Caption Element

The `<caption>` element provides a table title or description that's programmatically associated with the table. It must be the first child element of the table.

**Key points:**

- Must be the first child of the `<table>` element
- Provides title or description for the entire table
- Announced by screen readers before table content
- Can contain rich HTML content and formatting
- Improves table comprehension and context

**Example:**

```html
<table>
  <caption>
    <strong>Employee Performance Metrics</strong>
    <br>
    <small>Data collected from January 2024 to March 2024</small>
  </caption>
  <thead>
    <tr>
      <th>Employee</th>
      <th>Projects Completed</th>
      <th>Performance Score</th>
    </tr>
  </thead>
</table>
```

#### Caption Positioning and Styling

Captions can be positioned and styled using CSS while maintaining their semantic relationship with the table.

**Example:**

```html
<style>
caption {
  caption-side: bottom;
  text-align: left;
  font-style: italic;
  margin-top: 10px;
}
</style>

<table>
  <caption>
    Table 1: Market share data shows significant growth in mobile segment
  </caption>
  <!-- Table content -->
</table>
```

### Table Section Elements

HTML provides semantic elements to group table content into logical sections, improving structure and accessibility.

#### Table Head Section

The `<thead>` element groups header content, typically containing column headers and table metadata.

**Example:**

```html
<thead>
  <tr>
    <th scope="col">Product ID</th>
    <th scope="col">Product Name</th>
    <th scope="col">Price</th>
    <th scope="col">Stock</th>
  </tr>
</thead>
```

#### Table Body Section

The `<tbody>` element contains the main data content of the table and can be used multiple times to group related data.

**Example:**

```html
<tbody>
  <tr>
    <td>001</td>
    <td>Wireless Mouse</td>
    <td>$29.99</td>
    <td>150</td>
  </tr>
  <tr>
    <td>002</td>
    <td>Mechanical Keyboard</td>
    <td>$89.99</td>
    <td>75</td>
  </tr>
</tbody>
```

#### Table Footer Section

The `<tfoot>` element contains summary information like totals, averages, or footnotes.

**Example:**

```html
<tfoot>
  <tr>
    <th scope="row" colspan="3">Total Inventory Value</th>
    <td>$24,847.50</td>
  </tr>
</tfoot>
```

### Complete Table Structure Example

**Example:**

```html
<table class="data-table">
  <caption>
    <strong>Q3 2024 Sales Performance</strong>
    <br>Regional breakdown by product category
  </caption>
  
  <thead>
    <tr>
      <th scope="col">Region</th>
      <th scope="col">Electronics</th>
      <th scope="col">Clothing</th>
      <th scope="col">Books</th>
      <th scope="col">Total</th>
    </tr>
  </thead>
  
  <tbody>
    <tr>
      <th scope="row">North America</th>
      <td>$125,000</td>
      <td>$87,500</td>
      <td>$45,000</td>
      <td>$257,500</td>
    </tr>
    <tr>
      <th scope="row">Europe</th>
      <td>$98,000</td>
      <td>$112,000</td>
      <td>$38,500</td>
      <td>$248,500</td>
    </tr>
    <tr>
      <th scope="row">Asia Pacific</th>
      <td>$156,000</td>
      <td>$65,000</td>
      <td>$28,000</td>
      <td>$249,000</td>
    </tr>
  </tbody>
  
  <tfoot>
    <tr>
      <th scope="row">Grand Total</th>
      <td>$379,000</td>
      <td>$264,500</td>
      <td>$111,500</td>
      <td>$755,000</td>
    </tr>
  </tfoot>
</table>
```

**Conclusion:** Tables are powerful semantic elements for displaying structured data when used appropriately. The combination of proper table structure, meaningful headers, descriptive captions, and semantic sections creates accessible, maintainable, and user-friendly data presentations. Understanding when to use tables versus CSS layout methods is fundamental to creating semantic, accessible web content.

**Next steps:** Explore advanced table features like column groups (`<colgroup>`), responsive table techniques, and CSS styling strategies for enhanced table presentation and mobile compatibility.

---

