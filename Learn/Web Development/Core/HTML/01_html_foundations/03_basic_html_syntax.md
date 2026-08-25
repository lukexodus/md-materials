## Basic HTML Syntax


### Element Structure

HTML elements form the building blocks of web pages and consist of opening tags, content, and closing tags. The basic structure follows the pattern `<tagname>content</tagname>`, where the opening tag defines the beginning of an element and the closing tag (with a forward slash) marks its end.

Most HTML elements require both opening and closing tags to properly contain their content. The opening tag `<p>` begins a paragraph element, while `</p>` ends it. Everything between these tags becomes the paragraph's content. This container structure allows HTML to create hierarchical relationships between elements, enabling proper document structure and styling.

Nested elements must be properly closed in reverse order of their opening. When you open `<div><p>content</p></div>`, the paragraph element closes before the div element. This nesting creates the document tree structure that browsers use to render and style content.

### Attributes and Values

Attributes provide additional information about HTML elements and are always specified in the opening tag. They consist of a name-value pair written as `attribute="value"`. Multiple attributes can be added to a single element, separated by spaces.

Common attributes include `id` for unique identification, `class` for styling groups of elements, `src` for specifying resource locations, and `href` for links. The `id` attribute must be unique within a document, while `class` attributes can be shared across multiple elements for consistent styling.

Attribute values should always be enclosed in quotes, though HTML5 allows unquoted values in certain cases. Double quotes are preferred, but single quotes work when the value doesn't contain single quotes. Boolean attributes like `disabled`, `checked`, or `required` can be written as just the attribute name or with the same value as the name.

**Example:**

```html
<img src="photo.jpg" alt="A beautiful sunset" class="large-image" id="hero-photo">
<input type="text" name="username" required disabled="disabled">
<a href="https://example.com" target="_blank" title="Visit Example">Link</a>
```

### Self-Closing Elements

Self-closing elements, also called void elements, don't contain content and therefore don't need closing tags. These elements represent standalone functionality like images, line breaks, or form inputs.

Common self-closing elements include `<img>`, `<br>`, `<hr>`, `<input>`, `<meta>`, `<link>`, and `<area>`. In XHTML and XML, self-closing tags require a forward slash before the closing bracket (`<br />`), but HTML5 makes this optional.

The distinction between container elements and self-closing elements is important for document validation and proper rendering. Attempting to add content or a closing tag to a self-closing element will cause parsing issues.

**Example:**

```html
<img src="logo.png" alt="Company Logo">
<br>
<hr>
<input type="email" placeholder="Enter your email">
<meta charset="UTF-8">
<link rel="stylesheet" href="styles.css">
```

### Comments in HTML

HTML comments allow developers to add notes and explanations within the code without affecting the displayed content. Comments begin with `<!--` and end with `-->`, and everything between these markers is ignored by the browser.

Comments serve multiple purposes: documenting code sections, temporarily disabling elements during development, leaving notes for other developers, and organizing large HTML files. They're particularly useful for marking the beginning and end of major sections in complex layouts.

Multi-line comments are supported, making them ideal for longer explanations or temporarily commenting out large blocks of code. However, comments increase file size and are visible in the page source, so avoid including sensitive information.

**Example:**

```html
<!-- Navigation section begins -->
<nav class="main-navigation">
    <!-- TODO: Add mobile menu toggle -->
    <ul>
        <li><a href="#home">Home</a></li>
        <!-- <li><a href="#about">About</a></li> Temporarily disabled -->
        <li><a href="#contact">Contact</a></li>
    </ul>
</nav>
<!-- Navigation section ends -->

<!-- 
This is a multi-line comment
that can span several lines
for detailed explanations
-->
```

### Case Sensitivity and Best Practices

HTML is case-insensitive, meaning `<DIV>`, `<div>`, and `<Div>` are all valid and equivalent. However, modern best practices strongly recommend using lowercase for all HTML elements and attributes to maintain consistency and compatibility with XHTML standards.

Consistent formatting improves code readability and maintainability. Use lowercase for elements, attributes, and attribute values when possible. Indent nested elements properly to show document structure clearly. Each nesting level should use consistent indentation, typically 2 or 4 spaces.

Attribute values should be quoted even when not strictly required. This prevents errors when values contain spaces or special characters and maintains consistency across the codebase. Use semantic HTML elements that describe content meaning rather than appearance.

**Key points:**

- Always use lowercase for element names and attributes
- Quote all attribute values consistently
- Maintain proper indentation for nested elements
- Use semantic elements appropriately
- Close all container elements properly
- Validate HTML regularly to catch errors early

**Example:**

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Best Practices Example</title>
</head>
<body>
    <header>
        <h1 class="main-title">Welcome</h1>
    </header>
    <main>
        <article class="blog-post">
            <h2>Article Title</h2>
            <p>This demonstrates proper HTML formatting with consistent lowercase elements and proper nesting.</p>
        </article>
    </main>
</body>
</html>
```

### Document Type Declaration

The DOCTYPE declaration must appear at the very beginning of every HTML document to inform the browser which version of HTML to use for rendering. HTML5 uses the simplified `<!DOCTYPE html>` declaration, which is case-insensitive but conventionally written in uppercase.

Without a proper DOCTYPE, browsers enter "quirks mode," which can cause inconsistent rendering across different browsers. The HTML5 DOCTYPE triggers "standards mode," ensuring consistent and predictable behavior.

### Character Encoding

Character encoding specification is crucial for proper text display, especially for international content. The `<meta charset="UTF-8">` declaration should appear early in the `<head>` section, preferably as the first element after the opening `<head>` tag.

UTF-8 encoding supports all Unicode characters, making it the recommended choice for modern web development. This encoding handles multiple languages, special characters, and symbols without issues.

Related topics you might want to explore: HTML document structure, semantic HTML elements, HTML forms and input types, accessibility best practices in HTML, and HTML validation techniques.

---

