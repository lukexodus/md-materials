## Basic Selectors


### Element Selectors

Element selectors target HTML elements directly by their tag name. They are the most fundamental type of CSS selector and apply styles to all instances of a specified element type throughout the document.

The syntax is straightforward: simply use the element name without any special characters. Element selectors have low specificity and are often used for establishing base styles across a website.

**Example:**

```css
p {
    color: blue;
    font-size: 16px;
}

h1 {
    font-weight: bold;
    margin-bottom: 20px;
}

div {
    border: 1px solid #ccc;
}
```

**Key points:**

- Target all elements of a specific type
- Case-insensitive in HTML documents
- Have low specificity (0,0,0,1)
- Commonly used for typography and layout resets

### Class and ID Selectors

Class and ID selectors provide more targeted styling options than element selectors. Class selectors use a period (.) prefix and can be applied to multiple elements, making them ideal for reusable styles. ID selectors use a hash (#) prefix and should be unique within a document, making them suitable for targeting specific, unique elements.

**Class Selectors:** Class selectors target elements with a specific class attribute value. They are the most commonly used selectors for styling because of their reusability and moderate specificity.

**Example:**

```css
.header {
    background-color: #f8f9fa;
    padding: 20px;
}

.btn {
    padding: 10px 15px;
    border: none;
    cursor: pointer;
}

.text-center {
    text-align: center;
}
```

**ID Selectors:** ID selectors target elements with a specific ID attribute value. They have high specificity and are typically used for layout containers or unique page elements.

**Example:**

```css
#navigation {
    position: fixed;
    top: 0;
    width: 100%;
}

#footer {
    background-color: #333;
    color: white;
    text-align: center;
}

#main-content {
    margin: 0 auto;
    max-width: 1200px;
}
```

**Key points:**

- Classes: reusable, moderate specificity (0,0,1,0)
- IDs: unique, high specificity (0,1,0,0)
- Classes are prefixed with a period (.)
- IDs are prefixed with a hash (#)
- Multiple classes can be applied to one element
- Only one ID should be used per element

### Universal Selector (`*`)

The universal selector matches all elements in the document. It's represented by an asterisk (*) and is often used for CSS resets, box-sizing declarations, or applying global styles. While powerful, it should be used judiciously as it can impact performance and cascade behavior.

**Example:**

```css
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

*::before,
*::after {
    box-sizing: inherit;
}

* + * {
    margin-top: 1rem;
}
```

**Key points:**

- Matches every element in the document
- Has the lowest specificity (0,0,0,0)
- Commonly used in CSS resets
- Can impact performance if overused
- Often combined with pseudo-elements or combinators

### Attribute Selectors

Attribute selectors target elements based on their attributes and attribute values. They provide fine-grained control over element selection and are particularly useful for styling form elements, links, or elements with custom data attributes.

**Basic Attribute Presence:**

```css
[title] {
    border-bottom: 1px dotted;
}

[disabled] {
    opacity: 0.5;
    cursor: not-allowed;
}
```

**Exact Attribute Value:**

```css
[type="email"] {
    border-color: blue;
}

[class="highlight"] {
    background-color: yellow;
}
```

**Attribute Value Patterns:**

```css
/* Begins with */
[href^="https"] {
    color: green;
}

/* Ends with */
[src$=".jpg"] {
    border: 2px solid #ccc;
}

/* Contains */
[title*="important"] {
    font-weight: bold;
}

/* Word match */
[class~="active"] {
    background-color: #007bff;
}

/* Language attribute */
[lang|="en"] {
    font-family: "Times New Roman", serif;
}
```

**Case Sensitivity:**

```css
[type="EMAIL" i] {
    /* Case-insensitive matching */
    background-color: lightblue;
}

[data-state="ACTIVE" s] {
    /* Case-sensitive matching (default) */
    color: green;
}
```

**Key points:**

- Square brackets [] enclose attribute conditions
- Multiple matching patterns available (^=, $=, *=, ~=, |=)
- Case sensitivity can be controlled with 'i' and 's' flags
- Particularly useful for form styling and dynamic content
- Can be combined with other selectors

### Descendant and Child Selectors

These combinators define relationships between elements in the HTML structure, allowing for contextual styling based on element hierarchy.

**Descendant Selector (Space):** The descendant selector uses whitespace to select elements that are descendants (at any level) of another element. It creates a parent-descendant relationship regardless of how deeply nested the descendant is.

**Example:**

```css
.container p {
    color: #666;
    line-height: 1.6;
}

header nav a {
    text-decoration: none;
    color: white;
}

.sidebar ul li {
    margin-bottom: 10px;
    padding-left: 20px;
}
```

**Child Selector (>):** The child selector uses the greater-than symbol (>) to select elements that are direct children of another element. It only matches immediate children, not deeper descendants.

**Example:**

```css
.menu > li {
    display: inline-block;
    margin-right: 20px;
}

.card > h2 {
    margin-top: 0;
    color: #333;
}

.form-group > label {
    display: block;
    margin-bottom: 5px;
    font-weight: bold;
}
```

**Practical Comparison:**

```css
/* Descendant - affects all p elements inside .content */
.content p {
    margin-bottom: 1em;
}

/* Child - only affects direct p children of .content */
.content > p {
    font-size: 18px;
}
```

```html
<div class="content">
    <p>Direct child paragraph</p> <!-- Affected by both rules -->
    <div>
        <p>Nested paragraph</p> <!-- Only affected by descendant rule -->
    </div>
</div>
```

**Key points:**

- Descendant selector: space character, matches any level of nesting
- Child selector: > character, matches only direct children
- Useful for creating contextual styles
- Help maintain specificity control
- Essential for component-based styling architectures

**Conclusion:** Basic selectors form the foundation of CSS styling. Element selectors provide broad styling capabilities, class and ID selectors offer targeted control with different specificity levels, the universal selector enables global styling, attribute selectors provide fine-grained selection based on element properties, and descendant/child selectors allow for contextual styling based on document structure. Mastering these selectors is essential for efficient CSS development and maintainable stylesheets.

---

