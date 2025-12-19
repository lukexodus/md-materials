# Emmet Abbreviations

Emmet is a toolkit for web developers that dramatically speeds up HTML and CSS workflow through abbreviations that expand into full code blocks.

## What is Emmet?

Emmet is a plugin built into most modern code editors (VS Code, Sublime Text, Atom, etc.) that lets you write HTML and CSS faster using shorthand syntax. You type a short abbreviation and expand it into complete code structures.

## Basic HTML Syntax

### Elements
- `div` → `<div></div>`
- `p` → `<p></p>`
- `span` → `<span></span>`

### Nesting Operators

**Child: `>`**
- `div>p` → `<div><p></p></div>`
- `nav>ul>li` → `<nav><ul><li></li></ul></nav>`

**Sibling: `+`**
- `div+p+span` → `<div></div><p></p><span></span>`

**Climb-up: `^`**
- `div>p>span^div` → `<div><p><span></span></p><div></div></div>`
- Each `^` climbs up one level in the tree

**Grouping: `()`**
- `div>(header>ul>li*3)+footer>p` groups operations
- Creates clear structural boundaries

### Multiplication: `*`
- `ul>li*5` → Creates 5 list items inside a `<ul>`
- `div*3` → Three sibling divs

### Item Numbering: `$`
- `ul>li.item$*3` → 
  ```html
  <ul>
    <li class="item1"></li>
    <li class="item2"></li>
    <li class="item3"></li>
  </ul>
  ```
- `$$` for zero-padded numbers (01, 02, 03)
- `$@3` starts numbering at 3
- `$@-` reverses numbering order

## Attributes

### ID and Classes
- `div#header` → `<div id="header"></div>`
- `div.container` → `<div class="container"></div>`
- `div.container.main` → `<div class="container main"></div>`
- `p#intro.text.bold` → `<p id="intro" class="text bold"></p>`

### Custom Attributes: `[]`
- `a[href="#" title="Link"]` → `<a href="#" title="Link"></a>`
- `input[type="text" placeholder="Name"]`
- `img[src="photo.jpg" alt="Photo"]`

### Text Content: `{}`
- `p{Hello World}` → `<p>Hello World</p>`
- `a{Click here}` → `<a href="">Click here</a>`
- `div{Text}+span{More}` → `<div>Text</div><span>More</span>`

## Advanced Patterns

### Complex Nesting
```
div#page>div.container>header>nav>ul>li*4>a{Item $}
```
Expands to a complete navigation structure with 4 numbered items.

### Form Structures
```
form>input[type="text" name="username"]+input[type="password" name="pass"]+button{Submit}
```

### Table Generation
```
table>tr*3>td*4
```
Creates a 3×4 table structure.

## CSS Abbreviations

Emmet also works for CSS with shorthand property values:

- `m10` → `margin: 10px;`
- `p10-20` → `padding: 10px 20px;`
- `w100p` → `width: 100%;`
- `df` → `display: flex;`
- `fz14` → `font-size: 14px;`
- `bg#fff` → `background: #fff;`
- `c#333` → `color: #333;`

## Implicit Tag Names

Emmet can infer tag names based on context:

- `.container` inside `<div>` context → `<div class="container"></div>`
- `.item` inside `<ul>` or `<ol>` → `<li class="item"></li>`
- `#header` → `<div id="header"></div>` (defaults to div)

## Common Examples

**Navigation Menu:**
```
nav>ul>li*5>a[href="#"]{Menu Item $}
```

**Article Structure:**
```
article>h1{Title}+p*3>lorem
```

**Grid Layout:**
```
.container>(.row>(.col-md-4>div.card)*3)*2
```

**Form with Labels:**
```
form>(label{Name}+input[type="text" name="name"])+(label{Email}+input[type="email" name="email"])+button{Submit}
```

## Tips

- Start simple and build complexity gradually
- Use grouping `()` to keep structures clear
- Combine with Lorem Ipsum: `p*3>lorem` generates paragraphs with dummy text
- Most editors trigger expansion with Tab or Ctrl+E
- Practice common patterns to build muscle memory

Emmet dramatically reduces the time spent writing boilerplate HTML and CSS, letting you focus on structure and content rather than typing angle brackets and closing tags.