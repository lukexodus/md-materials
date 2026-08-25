## CSS Syntax and Structure


### Basic CSS Syntax

CSS (Cascading Style Sheets) follows a fundamental syntax pattern consisting of selectors, properties, and values. The basic structure is:

```css
selector {
    property: value;
    property: value;
}
```

**Key points:**

- Selectors target HTML elements
- Properties define what aspect to style
- Values specify how to style that property
- Each declaration ends with a semicolon
- Declarations are grouped within curly braces

### Selectors

CSS selectors are patterns used to select and target HTML elements for styling.

#### Element Selectors

Target HTML elements by their tag name:

```css
h1 { color: blue; }
p { font-size: 16px; }
div { margin: 10px; }
```

#### Class Selectors

Target elements with specific class attributes using a dot prefix:

```css
.highlight { background-color: yellow; }
.container { width: 100%; }
.btn-primary { background: #007bff; }
```

#### ID Selectors

Target elements with specific ID attributes using a hash prefix:

```css
#header { position: fixed; }
#main-content { padding: 20px; }
#footer { background: #333; }
```

#### Attribute Selectors

Target elements based on their attributes:

```css
[type="text"] { border: 1px solid #ccc; }
[href^="https"] { color: green; }
[class*="btn"] { padding: 10px; }
```

#### Pseudo-class Selectors

Target elements in specific states:

```css
a:hover { color: red; }
input:focus { border-color: blue; }
li:first-child { font-weight: bold; }
```

#### Pseudo-element Selectors

Target specific parts of elements:

```css
p::first-line { font-weight: bold; }
::before { content: "→ "; }
::after { content: " ←"; }
```

#### Combinators

Combine selectors to target elements based on relationships:

```css
/* Descendant combinator */
div p { color: blue; }

/* Child combinator */
ul > li { list-style: none; }

/* Adjacent sibling combinator */
h1 + p { margin-top: 0; }

/* General sibling combinator */
h1 ~ p { color: gray; }
```

### Properties and Values

CSS properties define what aspects of elements to style, while values specify how to style them.

#### Common Property Categories

**Layout Properties:**

```css
display: block | inline | inline-block | flex | grid;
position: static | relative | absolute | fixed | sticky;
float: left | right | none;
clear: left | right | both | none;
```

**Box Model Properties:**

```css
width: 300px | 50% | auto;
height: 200px | 100vh | auto;
margin: 10px | 10px 20px | 10px 20px 30px 40px;
padding: 15px | 5px 10px;
border: 1px solid #ccc;
```

**Typography Properties:**

```css
font-family: Arial, sans-serif;
font-size: 16px | 1.2em | 120%;
font-weight: normal | bold | 400 | 700;
color: #333 | rgb(51, 51, 51) | hsl(0, 0%, 20%);
```

**Background Properties:**

```css
background-color: #f0f0f0;
background-image: url('image.jpg');
background-repeat: no-repeat | repeat-x | repeat-y;
background-position: center | top left | 50% 50%;
```

#### Value Types

**Length Units:**

- Absolute: px, pt, cm, mm, in
- Relative: em, rem, %, vw, vh, vmin, vmax

**Color Values:**

- Keywords: red, blue, transparent
- Hex: #ff0000, #f00
- RGB: rgb(255, 0, 0), rgba(255, 0, 0, 0.5)
- HSL: hsl(0, 100%, 50%), hsla(0, 100%, 50%, 0.5)

**Functional Values:**

- calc(): calc(100% - 20px)
- url(): url('image.png')
- var(): var(--main-color)

### CSS Comments and Formatting

#### Comments

CSS comments are enclosed between `/*` and `*/` and can span multiple lines:

```css
/* This is a single-line comment */

/*
This is a multi-line comment
that spans several lines
*/

.button {
    background: blue; /* Inline comment */
    color: white;
}
```

#### Formatting Best Practices

**Readable Formatting:**

```css
/* Good formatting */
.navigation {
    background-color: #333;
    padding: 10px 20px;
    margin-bottom: 20px;
    border-radius: 5px;
}

.nav-item {
    display: inline-block;
    margin-right: 15px;
    color: white;
}
```

**Organizational Strategies:**

- Group related properties together
- Use consistent indentation (2 or 4 spaces)
- Add blank lines between rule sets
- Use meaningful class and ID names
- Organize stylesheets by sections (layout, typography, components)

### Inline, Internal, and External Stylesheets

#### Inline Styles

Applied directly to HTML elements using the `style` attribute:

```html
<p style="color: red; font-size: 18px;">This is styled text</p>
<div style="background: blue; padding: 10px;">Styled div</div>
```

**Advantages:**

- Highest specificity
- Quick for testing
- No external file dependencies

**Disadvantages:**

- Not reusable
- Difficult to maintain
- Mixes content with presentation

#### Internal Stylesheets

Defined within the HTML document's `<head>` section using `<style>` tags:

```html
<!DOCTYPE html>
<html>
<head>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
        }
        
        .header {
            background-color: #333;
            color: white;
            padding: 20px;
        }
        
        .content {
            margin: 20px 0;
            line-height: 1.6;
        }
    </style>
</head>
<body>
    <!-- HTML content -->
</body>
</html>
```

**Advantages:**

- Styles contained within the document
- Good for single-page applications
- Faster than external files (no additional HTTP request)

**Disadvantages:**

- Not reusable across multiple pages
- Increases HTML file size
- Harder to cache

#### External Stylesheets

Separate CSS files linked to HTML documents:

**styles.css:**

```css
/* Reset and base styles */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Helvetica Neue', Arial, sans-serif;
    line-height: 1.6;
    color: #333;
}

/* Layout */
.container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;
}

/* Components */
.button {
    display: inline-block;
    padding: 10px 20px;
    background: #007bff;
    color: white;
    text-decoration: none;
    border-radius: 5px;
    transition: background 0.3s ease;
}

.button:hover {
    background: #0056b3;
}
```

**HTML linking:**

```html
<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" href="styles.css">
    <link rel="stylesheet" href="responsive.css">
</head>
<body>
    <!-- HTML content -->
</body>
</html>
```

**Advantages:**

- Reusable across multiple pages
- Cacheable by browsers
- Cleaner HTML structure
- Easier maintenance and updates
- Better organization

**Disadvantages:**

- Additional HTTP request
- Potential for unused CSS
- Dependency on external files

### CSS Cascading and Inheritance Principles

#### The Cascade

The cascade determines which CSS rules apply when multiple rules target the same element. The cascade follows this order of importance:

1. **Importance and Origin:**
    
    - User agent (browser) styles
    - User styles
    - Author (developer) styles
    - Author !important declarations
    - User !important declarations
2. **Specificity:**
    
    - Inline styles (1000)
    - IDs (100)
    - Classes, attributes, pseudo-classes (10)
    - Elements and pseudo-elements (1)
3. **Source Order:**
    
    - Later rules override earlier rules with equal specificity

#### Specificity Calculation

**Example specificity calculations:**

```css
/* Specificity: 0,0,0,1 */
p { color: blue; }

/* Specificity: 0,0,1,0 */
.intro { color: red; }

/* Specificity: 0,1,0,0 */
#main { color: green; }

/* Specificity: 0,0,1,1 */
p.intro { color: purple; }

/* Specificity: 0,1,1,1 */
#main p.intro { color: orange; }

/* Specificity: 1,0,0,0 */
<p style="color: yellow;">
```

#### Inheritance

Some CSS properties are inherited from parent elements to child elements:

**Inherited Properties:**

- Typography: font-family, font-size, color, line-height
- Text: text-align, text-indent, text-transform
- Visibility: visibility
- List properties: list-style

**Non-inherited Properties:**

- Box model: margin, padding, border, width, height
- Positioning: position, top, left, right, bottom
- Background: background-color, background-image
- Display: display, float, clear

**Example of inheritance:**

```css
body {
    font-family: Arial, sans-serif;
    color: #333;
    line-height: 1.6;
}

/* These properties are inherited by all child elements */
p, h1, h2, div {
    /* Automatically inherit font-family, color, and line-height */
}

/* Controlling inheritance */
.special {
    color: inherit;    /* Explicitly inherit from parent */
    margin: initial;   /* Use initial browser value */
    padding: unset;    /* Remove property entirely */
}
```

#### CSS Custom Properties (Variables)

Modern CSS supports custom properties for better maintainability:

```css
:root {
    --primary-color: #007bff;
    --secondary-color: #6c757d;
    --font-size-base: 16px;
    --line-height-base: 1.6;
}

.button {
    background-color: var(--primary-color);
    font-size: var(--font-size-base);
    line-height: var(--line-height-base);
}

.button-secondary {
    background-color: var(--secondary-color);
}
```

**Key points:**

- Variables cascade and inherit like other properties
- Can be overridden at any level
- Fallback values: `var(--color, blue)`
- Useful for theming and consistency

**Conclusion:** Understanding CSS syntax and structure is fundamental to web development. The combination of selectors, properties, and values creates a powerful system for styling web pages. The cascade and inheritance principles ensure predictable styling behavior, while proper organization through external stylesheets promotes maintainability and reusability across projects.

---

