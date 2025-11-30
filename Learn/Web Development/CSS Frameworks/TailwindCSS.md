# Grid

## Grid Container Basics

Start by making an element a grid container with `grid`, then define columns and rows:

```html
<div class="grid grid-cols-3">
  <div>Item 1</div>
  <div>Item 2</div>
  <div>Item 3</div>
</div>
```

## Column Definitions

Tailwind provides several ways to define columns:

**Fixed number of equal columns:**

- `grid-cols-1` through `grid-cols-12` - creates that many equal-width columns
- `grid-cols-none` - removes grid columns

**Fractional columns:**

- `grid-cols-2` = `grid-template-columns: repeat(2, minmax(0, 1fr))`
- Each column takes equal space

**Custom column sizing:** You can mix different column sizes, but you'll need arbitrary values:

- `grid-cols-[200px_1fr_100px]` - fixed, flexible, fixed
- `grid-cols-[1fr_2fr_1fr]` - proportional columns

## Row Definitions

Similar to columns but for rows:

- `grid-rows-1` through `grid-rows-6`
- `grid-rows-none`
- `grid-rows-[200px_1fr]` for custom sizing

## Gap Control

Control spacing between grid items:

- `gap-4` - applies to both rows and columns
- `gap-x-4` - horizontal gap only
- `gap-y-2` - vertical gap only
- Available sizes: 0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 16, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60, 64, 72, 80, 96

## Item Positioning

**Column spanning:**

- `col-span-2` - span across 2 columns
- `col-span-full` - span entire width
- `col-start-2` - start at column 2
- `col-end-4` - end at column 4

**Row spanning:**

- `row-span-2` - span across 2 rows
- `row-span-full` - span entire height
- `row-start-1` - start at row 1
- `row-end-3` - end at row 3

**Automatic placement:**

- `col-auto` - let grid auto-place the column
- `row-auto` - let grid auto-place the row

## Alignment

**Justify items (horizontal alignment within cells):**

- `justify-items-start`
- `justify-items-end`
- `justify-items-center`
- `justify-items-stretch` (default)

**Align items (vertical alignment within cells):**

- `items-start`
- `items-end`
- `items-center`
- `items-stretch` (default)

**Justify content (align entire grid horizontally):**

- `justify-start`
- `justify-end`
- `justify-center`
- `justify-between`
- `justify-around`
- `justify-evenly`

**Align content (align entire grid vertically):**

- `content-start`
- `content-end`
- `content-center`
- `content-between`
- `content-around`
- `content-evenly`

## Individual Item Alignment

Override alignment for specific items:

- `justify-self-start/end/center/stretch`
- `self-start/end/center/stretch`

## Responsive Grids

Use responsive prefixes to change grid behavior at different breakpoints:

```html
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3">
  <!-- 1 column on mobile, 2 on tablet, 3 on desktop -->
</div>
```

Breakpoints: `sm:`, `md:`, `lg:`, `xl:`, `2xl:`

## Auto-Fit and Auto-Fill

For responsive grids that adjust the number of columns automatically:

```html
<!-- Auto-fit: columns stretch to fill -->
<div class="grid grid-cols-[repeat(auto-fit,minmax(200px,1fr))]">

<!-- Auto-fill: maintains column size -->
<div class="grid grid-cols-[repeat(auto-fill,minmax(200px,1fr))]">
```

## Common Patterns

**Card grid:**

```html
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
  <div class="bg-white p-4 rounded-lg shadow">Card 1</div>
  <div class="bg-white p-4 rounded-lg shadow">Card 2</div>
  <div class="bg-white p-4 rounded-lg shadow">Card 3</div>
</div>
```

**Sidebar layout:**

```html
<div class="grid grid-cols-[250px_1fr] gap-4">
  <aside class="bg-gray-100">Sidebar</aside>
  <main>Main content</main>
</div>
```

**Header/main/footer layout:**

```html
<div class="grid grid-rows-[auto_1fr_auto] min-h-screen">
  <header>Header</header>
  <main>Main content</main>
  <footer>Footer</footer>
</div>
```

**Complex layout with overlapping:**

```html
<div class="grid grid-cols-4 grid-rows-3 gap-4">
  <div class="col-span-2 row-span-2">Large item</div>
  <div class="col-span-2">Item 2</div>
  <div>Item 3</div>
  <div>Item 4</div>
  <div class="col-span-3">Item 5</div>
</div>
```

## Grid vs Flexbox

Use Grid when:

- You need 2D layout (rows AND columns)
- You want to control both dimensions simultaneously
- Creating complex layouts with overlapping elements
- You know the overall layout structure upfront

Use Flexbox when:

- You need 1D layout (just rows OR columns)
- Content should determine the layout
- You want items to wrap naturally
- Creating navigation bars, button groups, or centering content

## Pro Tips

1. **Start simple** - Begin with basic `grid grid-cols-*` and add complexity
2. **Use Firefox DevTools** - Best for visualizing and debugging grids
3. **Mobile-first** - Design for small screens first, then scale up
4. **Combine with Flexbox** - Grid for page layout, Flexbox for component layout
5. **Use `place-items-center`** - Shorthand for centering both horizontally and vertically
6. **Test with different content lengths** - Ensure your grid works with varying content

---

# Flex

Flexbox with Tailwind is perfect for 1D layouts and component-level design. Here's everything you need to master it:

## Flex Container Basics

Make an element a flex container:

- `flex` - creates a flex container (flex-direction: row by default)
- `inline-flex` - creates an inline flex container

## Flex Direction

Control the main axis direction:

- `flex-row` - horizontal, left to right (default)
- `flex-row-reverse` - horizontal, right to left
- `flex-col` - vertical, top to bottom
- `flex-col-reverse` - vertical, bottom to top

```html
<div class="flex flex-col">
  <div>Item 1</div>
  <div>Item 2</div>
</div>
```

## Flex Wrap

Control whether items wrap to new lines:

- `flex-nowrap` - no wrapping (default)
- `flex-wrap` - wrap to new lines
- `flex-wrap-reverse` - wrap to new lines in reverse order

```html
<div class="flex flex-wrap">
  <!-- Items will wrap when they run out of space -->
</div>
```

## Justify Content (Main Axis Alignment)

Align items along the main axis:

- `justify-start` - align to start (default)
- `justify-end` - align to end
- `justify-center` - center items
- `justify-between` - space between items
- `justify-around` - space around items
- `justify-evenly` - equal space between and around items

```html
<div class="flex justify-between">
  <div>Left</div>
  <div>Right</div>
</div>
```

## Align Items (Cross Axis Alignment)

Align items along the cross axis:

- `items-stretch` - stretch to fill container (default)
- `items-start` - align to start
- `items-end` - align to end
- `items-center` - center items
- `items-baseline` - align to text baseline

```html
<div class="flex items-center h-20">
  <div>Centered vertically</div>
</div>
```

## Align Content

Align wrapped lines (only works with `flex-wrap`):

- `content-start`
- `content-end`
- `content-center`
- `content-between`
- `content-around`
- `content-evenly`
- `content-stretch`

## Gap

Control spacing between flex items:

- `gap-4` - applies to both directions
- `gap-x-4` - horizontal gap only
- `gap-y-2` - vertical gap only
- Available sizes: 0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 16, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60, 64, 72, 80, 96

## Flex Item Properties

**Flex Grow** - how much an item should grow:

- `flex-1` - grow to fill available space (flex: 1 1 0%)
- `flex-auto` - grow and shrink based on content (flex: 1 1 auto)
- `flex-initial` - shrink but don't grow (flex: 0 1 auto, default)
- `flex-none` - don't grow or shrink (flex: none)

**Individual alignment** - override container alignment for specific items:

- `self-auto` - use container's align-items value
- `self-start`
- `self-end`
- `self-center`
- `self-stretch`
- `self-baseline`

**Flex order** - change visual order without changing HTML:

- `order-1` through `order-12`
- `order-first` (order: -9999)
- `order-last` (order: 9999)
- `order-none` (order: 0)

## Common Patterns

**Navigation bar:**

```html
<nav class="flex items-center justify-between p-4">
  <div class="font-bold">Logo</div>
  <div class="flex gap-4">
    <a href="#">Home</a>
    <a href="#">About</a>
    <a href="#">Contact</a>
  </div>
</nav>
```

**Card with header/content/footer:**

```html
<div class="flex flex-col h-64">
  <div class="p-4 bg-gray-100">Header</div>
  <div class="flex-1 p-4">Content that grows</div>
  <div class="p-4 bg-gray-100">Footer</div>
</div>
```

**Centering content:**

```html
<!-- Perfect centering -->
<div class="flex items-center justify-center h-screen">
  <div>Perfectly centered</div>
</div>
```

**Button group:**

```html
<div class="flex gap-2">
  <button class="px-4 py-2 bg-blue-500 text-white">Save</button>
  <button class="px-4 py-2 bg-gray-500 text-white">Cancel</button>
</div>
```

**Responsive columns:**

```html
<div class="flex flex-col md:flex-row gap-4">
  <div class="flex-1">Column 1</div>
  <div class="flex-1">Column 2</div>
</div>
```

**Equal width columns:**

```html
<div class="flex gap-4">
  <div class="flex-1">Equal width</div>
  <div class="flex-1">Equal width</div>
  <div class="flex-1">Equal width</div>
</div>
```

**Sidebar layout:**

```html
<div class="flex h-screen">
  <aside class="w-64 bg-gray-100">Sidebar</aside>
  <main class="flex-1 p-4">Main content</main>
</div>
```

**Space between with multiple groups:**

```html
<div class="flex items-center justify-between">
  <div class="flex items-center gap-2">
    <img src="logo.png" alt="Logo">
    <span>Brand</span>
  </div>
  <div class="flex items-center gap-4">
    <button>Login</button>
    <button>Sign up</button>
  </div>
</div>
```

## Responsive Flexbox

Use responsive prefixes to change flex behavior:

```html
<!-- Stack on mobile, row on desktop -->
<div class="flex flex-col lg:flex-row">
  <div>Item 1</div>
  <div>Item 2</div>
</div>

<!-- Different alignment on different screens -->
<div class="flex justify-start md:justify-center lg:justify-end">
  <div>Responsive alignment</div>
</div>
```

## Advanced Flex Patterns

**Sticky footer:**

```html
<div class="flex flex-col min-h-screen">
  <header>Header</header>
  <main class="flex-1">Content</main>
  <footer>Footer</footer>
</div>
```

**Form with button alignment:**

```html
<form class="flex flex-col gap-4">
  <input type="text" class="p-2 border">
  <input type="email" class="p-2 border">
  <div class="flex justify-end gap-2">
    <button type="button">Cancel</button>
    <button type="submit">Submit</button>
  </div>
</form>
```

**Media object pattern:**

```html
<div class="flex gap-4">
  <img src="avatar.jpg" class="w-12 h-12 rounded-full flex-shrink-0">
  <div class="flex-1">
    <h3>John Doe</h3>
    <p>This content can wrap and the image stays aligned to the top.</p>
  </div>
</div>
```

## Flex vs Grid Decision Guide

**Use Flex when:**

- Creating 1D layouts (rows OR columns)
- Building navigation bars
- Aligning items within components
- Content determines the layout
- You need items to wrap naturally
- Creating button groups or form controls

**Use Grid when:**

- Creating 2D layouts (rows AND columns)
- Building page-level layouts
- You need precise control over positioning
- Creating card layouts or image galleries
- You know the structure upfront

## Pro Tips

1. **Start with direction** - Decide `flex-row` or `flex-col` first
2. **Use `flex-1` liberally** - Great for making items grow to fill space
3. **Combine with width classes** - `w-64 flex-shrink-0` for fixed-width sidebars
4. **Gap is your friend** - Much cleaner than margins for spacing
5. **Mobile-first approach** - Start with `flex-col` then add `md:flex-row`
6. **Use `items-center` often** - Most layouts benefit from vertical centering
7. **Remember `flex-wrap`** - Essential for responsive design
8. **Test with varying content** - Ensure your layout works with different text lengths

## Common Gotchas

- **Flex-shrink default**: Items shrink by default, use `flex-shrink-0` to prevent
- **Height with flex-col**: Parent needs explicit height for `items-center` to work vertically
- **Overflow**: Long content can break flex layouts, consider `min-w-0` or `overflow-hidden`
- **Gap vs margin**: Gap doesn't add space around the container edges

This covers everything you need to build flexible, responsive layouts with Tailwind's flexbox utilities. Practice with these patterns and you'll quickly master flexbox!