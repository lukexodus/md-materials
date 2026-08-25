## Pseudo-elements


Pseudo-elements are virtual elements that allow you to style specific parts of an element without adding extra HTML markup. They create styleable components that don't exist in the document tree but can be targeted with CSS. Pseudo-elements use the double-colon syntax (::) to distinguish them from pseudo-classes, though single colons (:) still work for backward compatibility.

### Before and After Pseudo-elements

The `::before` and `::after` pseudo-elements create virtual elements that are inserted as the first and last children of the selected element, respectively. These elements are inline by default and require the `content` property to be displayed.

#### Basic Syntax and Content Property

```css
.element::before {
  content: ""; /* Required - can be empty */
  display: block; /* Often needed for positioning */
}

.element::after {
  content: "★"; /* Text content */
  content: url('icon.svg'); /* Image content */
  content: attr(data-label); /* Attribute value */
  content: counter(section-counter); /* Counter value */
}
```

#### Content Property Values

The `content` property accepts various types of content:

```css
.content-examples::before {
  /* Text strings */
  content: "Hello World";
  content: "Chapter " counter(chapter) ": ";
  
  /* Unicode characters */
  content: "\2022"; /* Bullet point */
  content: "\2713"; /* Checkmark */
  content: "\2190"; /* Left arrow */
  content: "\00A0"; /* Non-breaking space */
  
  /* Attribute values */
  content: attr(title);
  content: attr(data-count);
  content: attr(href, url); /* URL attribute */
  
  /* Images */
  content: url('icon.png');
  content: url('data:image/svg+xml;utf8,<svg>...</svg>');
  
  /* Counters */
  content: counter(list-item);
  content: counters(section, ".");
  
  /* Multiple values */
  content: "Section " counter(section) ": " attr(title);
}
```

#### Decorative Elements

```css
/* Quote marks */
.quote::before {
  content: """;
  font-size: 2em;
  color: #666;
  line-height: 0;
  margin-right: 0.1em;
  vertical-align: -0.4em;
}

.quote::after {
  content: """;
  font-size: 2em;
  color: #666;
  line-height: 0;
  margin-left: 0.1em;
  vertical-align: -0.4em;
}

/* Decorative borders */
.fancy-heading::before,
.fancy-heading::after {
  content: "";
  display: inline-block;
  width: 50px;
  height: 2px;
  background: linear-gradient(90deg, transparent, #333, transparent);
  margin: 0 20px;
  vertical-align: middle;
}

/* Icons and symbols */
.warning::before {
  content: "⚠";
  color: #ff9800;
  font-weight: bold;
  margin-right: 8px;
}

.external-link::after {
  content: "↗";
  font-size: 0.8em;
  margin-left: 4px;
  color: #666;
}
```

#### Positioning and Layout

```css
/* Overlay elements */
.card::before {
  content: "";
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(45deg, rgba(255,0,0,0.1), rgba(0,0,255,0.1));
  pointer-events: none; /* Allow clicks to pass through */
  z-index: 1;
}

/* Positioned decorations */
.badge::after {
  content: "New";
  position: absolute;
  top: -10px;
  right: -10px;
  background: #ff4444;
  color: white;
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 0.7em;
  font-weight: bold;
}

/* Tooltip-style elements */
.tooltip::after {
  content: attr(data-tooltip);
  position: absolute;
  bottom: 100%;
  left: 50%;
  transform: translateX(-50%);
  background: #333;
  color: white;
  padding: 8px 12px;
  border-radius: 4px;
  white-space: nowrap;
  opacity: 0;
  pointer-events: none;
  transition: opacity 0.3s;
}

.tooltip:hover::after {
  opacity: 1;
}
```

#### Advanced Techniques

```css
/* CSS Shapes with pseudo-elements */
.triangle::before {
  content: "";
  position: absolute;
  top: -10px;
  left: 20px;
  width: 0;
  height: 0;
  border-left: 10px solid transparent;
  border-right: 10px solid transparent;
  border-bottom: 10px solid #333;
}

/* Loading spinner */
.loading::after {
  content: "";
  width: 20px;
  height: 20px;
  border: 2px solid #f3f3f3;
  border-top: 2px solid #333;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  display: inline-block;
  margin-left: 10px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Clearfix with pseudo-elements */
.clearfix::after {
  content: "";
  display: table;
  clear: both;
}

/* CSS-only hamburger menu */
.hamburger::before,
.hamburger::after {
  content: "";
  position: absolute;
  left: 0;
  width: 100%;
  height: 2px;
  background: #333;
  transition: transform 0.3s;
}

.hamburger::before {
  top: -6px;
}

.hamburger::after {
  bottom: -6px;
}

.hamburger.active::before {
  transform: rotate(45deg) translate(4px, 4px);
}

.hamburger.active::after {
  transform: rotate(-45deg) translate(4px, -4px);
}
```

#### Counters with Pseudo-elements

```css
/* Automatic numbering */
.counter-container {
  counter-reset: item-counter;
}

.counter-item {
  counter-increment: item-counter;
}

.counter-item::before {
  content: counter(item-counter) ". ";
  font-weight: bold;
  color: #666;
}

/* Nested counters */
.outline {
  counter-reset: section subsection;
}

.section {
  counter-increment: section;
  counter-reset: subsection;
}

.section::before {
  content: counter(section) ". ";
}

.subsection {
  counter-increment: subsection;
}

.subsection::before {
  content: counter(section) "." counter(subsection) " ";
}

/* Custom counter styles */
.roman-list {
  counter-reset: roman-counter;
}

.roman-item {
  counter-increment: roman-counter;
}

.roman-item::before {
  content: counter(roman-counter, upper-roman) ". ";
  font-weight: bold;
}
```

### First-Line Pseudo-element

The `::first-line` pseudo-element styles the first line of text in a block-level element. The styling applies only to the actual first line as rendered, which can change based on viewport size and font settings.

```css
/* Basic first-line styling */
.article::first-line {
  font-weight: bold;
  color: #333;
  font-size: 1.1em;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

/* Drop cap effect with first-line */
.paragraph::first-line {
  font-variant: small-caps;
  color: #666;
}

/* Magazine-style formatting */
.magazine-text::first-line {
  font-family: serif;
  font-weight: bold;
  font-size: 1.2em;
  color: #8B4513;
  text-shadow: 1px 1px 2px rgba(0,0,0,0.1);
}
```

#### Limitations and Properties

Only certain CSS properties can be applied to `::first-line`:

```css
.first-line-properties::first-line {
  /* Font properties */
  font-family: serif;
  font-style: italic;
  font-variant: small-caps;
  font-weight: bold;
  font-size: 1.1em;
  line-height: 1.2;
  
  /* Color and background */
  color: #333;
  background-color: yellow;
  
  /* Text properties */
  text-decoration: underline;
  text-transform: uppercase;
  letter-spacing: 1px;
  word-spacing: 2px;
  
  /* Text shadow */
  text-shadow: 1px 1px 2px rgba(0,0,0,0.3);
  
  /* Note: margin, padding, border properties are not allowed */
}
```

#### Responsive First-Line Effects

```css
.responsive-first-line::first-line {
  font-size: 1.1em;
  color: #333;
}

@media (min-width: 768px) {
  .responsive-first-line::first-line {
    font-size: 1.3em;
    letter-spacing: 0.5px;
    text-transform: uppercase;
  }
}

@media (min-width: 1024px) {
  .responsive-first-line::first-line {
    font-size: 1.5em;
    font-weight: bold;
    color: #8B4513;
  }
}
```

### First-Letter Pseudo-element

The `::first-letter` pseudo-element styles the first letter of the first line of a block-level element. It's commonly used to create drop caps and other typographic effects.

```css
/* Classic drop cap */
.drop-cap::first-letter {
  float: left;
  font-size: 3em;
  line-height: 0.8;
  margin: 0.1em 0.1em 0 0;
  font-family: serif;
  font-weight: bold;
  color: #8B4513;
}

/* Modern drop cap with background */
.modern-drop-cap::first-letter {
  float: left;
  font-size: 4em;
  line-height: 1;
  margin: 0 0.1em 0 0;
  padding: 0.1em 0.15em;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 4px;
  font-family: sans-serif;
  font-weight: 900;
}

/* Outlined first letter */
.outlined-first::first-letter {
  font-size: 2.5em;
  font-weight: bold;
  color: transparent;
  -webkit-text-stroke: 2px #333;
  text-stroke: 2px #333;
  margin-right: 0.1em;
}
```

#### Advanced First-Letter Styling

```css
/* Decorative first letter with shadow */
.fancy-first::first-letter {
  float: left;
  font-size: 5em;
  line-height: 0.7;
  margin: 0.05em 0.1em 0 0;
  font-family: "Georgia", serif;
  color: #444;
  text-shadow: 
    3px 3px 0px #ccc,
    6px 6px 0px #bbb,
    9px 9px 0px #aaa;
  transform: rotate(-2deg);
}

/* First letter with gradient */
.gradient-first::first-letter {
  float: left;
  font-size: 4em;
  line-height: 0.8;
  margin: 0 0.1em 0 0;
  background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
  font-weight: bold;
}

/* Animated first letter */
.animated-first::first-letter {
  float: left;
  font-size: 3em;
  line-height: 0.8;
  margin: 0 0.1em 0 0;
  color: #333;
  transition: all 0.3s ease;
  cursor: pointer;
}

.animated-first:hover::first-letter {
  transform: scale(1.2) rotate(5deg);
  color: #ff6b6b;
  text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
}
```

#### First-Letter with Punctuation

```css
/* Handle punctuation with first letter */
.punctuation-first::first-letter {
  float: left;
  font-size: 3em;
  line-height: 0.8;
  margin: 0 0.1em 0 0;
  font-weight: bold;
  color: #333;
}

/* When text starts with quotes */
.quote-text::first-letter {
  /* The opening quote and first letter are both styled */
  float: left;
  font-size: 4em;
  line-height: 0.6;
  margin: 0.1em 0.1em 0 0;
  font-family: serif;
  color: #666;
}
```

### Selection Pseudo-element

The `::selection` pseudo-element styles the portion of text that has been highlighted by the user. This allows you to customize the appearance of selected text to match your design.

```css
/* Global selection styling */
::selection {
  background-color: #ff6b6b;
  color: white;
  text-shadow: none;
}

/* Firefox compatibility */
::-moz-selection {
  background-color: #ff6b6b;
  color: white;
  text-shadow: none;
}

/* Element-specific selection */
.special-text::selection {
  background-color: #4ecdc4;
  color: #333;
}

.special-text::-moz-selection {
  background-color: #4ecdc4;
  color: #333;
}
```

#### Advanced Selection Styling

```css
/* Gradient selection background */
.gradient-selection::selection {
  background: linear-gradient(90deg, #ff6b6b, #4ecdc4);
  color: white;
}

/* Multiple element selections */
h1::selection, h2::selection, h3::selection {
  background-color: #333;
  color: #ffd700;
}

p::selection {
  background-color: rgba(255, 107, 107, 0.3);
  color: #333;
}

code::selection {
  background-color: #2d3748;
  color: #68d391;
}

/* Themed selection colors */
.dark-theme::selection {
  background-color: #4a5568;
  color: #e2e8f0;
}

.light-theme::selection {
  background-color: #bee3f8;
  color: #2d3748;
}
```

#### Selection Properties

Only certain properties can be applied to `::selection`:

```css
.selection-properties::selection {
  /* Allowed properties */
  background-color: #ff6b6b;
  color: white;
  text-shadow: 1px 1px 2px rgba(0,0,0,0.5);
  text-decoration: underline;
  
  /* Not allowed: margin, padding, border, etc. */
}
```

### Placeholder Pseudo-element

The `::placeholder` pseudo-element styles placeholder text in form inputs. This allows you to customize the appearance of placeholder text to match your design system.

```css
/* Basic placeholder styling */
input::placeholder {
  color: #999;
  font-style: italic;
  opacity: 1; /* Firefox default opacity is 0.54 */
}

textarea::placeholder {
  color: #666;
  font-family: inherit;
  font-size: 0.9em;
}

/* Vendor prefixes for older browsers */
input::-webkit-input-placeholder {
  color: #999;
  font-style: italic;
}

input::-moz-placeholder {
  color: #999;
  font-style: italic;
  opacity: 1;
}

input:-ms-input-placeholder {
  color: #999;
  font-style: italic;
}
```

#### Advanced Placeholder Styling

```css
/* Themed placeholders */
.dark-input::placeholder {
  color: #a0aec0;
  text-shadow: none;
}

.light-input::placeholder {
  color: #4a5568;
}

/* Animated placeholder */
.animated-placeholder::placeholder {
  transition: color 0.3s ease, transform 0.3s ease;
}

.animated-placeholder:focus::placeholder {
  color: transparent;
  transform: translateX(10px);
}

/* Custom placeholder with background */
.fancy-placeholder {
  position: relative;
}

.fancy-placeholder::placeholder {
  color: transparent;
}

.fancy-placeholder::before {
  content: attr(placeholder);
  position: absolute;
  left: 12px;
  top: 50%;
  transform: translateY(-50%);
  color: #999;
  pointer-events: none;
  transition: all 0.3s ease;
  background: linear-gradient(90deg, #ff6b6b, #4ecdc4);
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
}

.fancy-placeholder:focus::before,
.fancy-placeholder:not(:placeholder-shown)::before {
  top: -10px;
  font-size: 0.8em;
  color: #666;
}
```

#### Responsive Placeholder Styling

```css
.responsive-placeholder::placeholder {
  font-size: 14px;
  color: #999;
}

@media (max-width: 768px) {
  .responsive-placeholder::placeholder {
    font-size: 16px; /* Prevent zoom on iOS */
    color: #666;
  }
}

/* Accessibility considerations */
.accessible-placeholder::placeholder {
  color: #6b7280; /* Ensure sufficient contrast */
  opacity: 1;
}

@media (prefers-high-contrast: high) {
  .accessible-placeholder::placeholder {
    color: #374151;
  }
}
```

### Practical Applications

#### Complete Card Component

```css
.enhanced-card {
  position: relative;
  padding: 2rem;
  background: white;
  border-radius: 8px;
  box-shadow: 0 4px 6px rgba(0,0,0,0.1);
  overflow: hidden;
}

/* Decorative corner */
.enhanced-card::before {
  content: "";
  position: absolute;
  top: 0;
  right: 0;
  width: 0;
  height: 0;
  border-left: 40px solid transparent;
  border-top: 40px solid #ff6b6b;
}

/* Status indicator */
.enhanced-card::after {
  content: attr(data-status);
  position: absolute;
  top: 10px;
  right: 10px;
  background: #4ecdc4;
  color: white;
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 0.7em;
  font-weight: bold;
  text-transform: uppercase;
}

/* Enhanced typography */
.enhanced-card h3::first-letter {
  font-size: 1.5em;
  color: #333;
  font-weight: bold;
}

.enhanced-card p::first-line {
  font-weight: 500;
  color: #555;
}

/* Custom selection */
.enhanced-card::selection {
  background-color: rgba(255, 107, 107, 0.2);
  color: #333;
}
```

#### Form Enhancement

```css
.enhanced-form input {
  padding: 12px 16px;
  border: 2px solid #e2e8f0;
  border-radius: 6px;
  transition: border-color 0.3s ease;
}

.enhanced-form input::placeholder {
  color: #a0aec0;
  transition: color 0.3s ease;
}

.enhanced-form input:focus {
  border-color: #4ecdc4;
  outline: none;
}

.enhanced-form input:focus::placeholder {
  color: #cbd5e0;
}

/* Required field indicator */
.enhanced-form .required::after {
  content: "*";
  color: #e53e3e;
  margin-left: 4px;
}

/* Validation states */
.enhanced-form .error::after {
  content: "✕";
  color: #e53e3e;
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
}

.enhanced-form .success::after {
  content: "✓";
  color: #38a169;
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
}
```

**Key Points**

- Pseudo-elements create virtual styleable elements without adding HTML markup
- `::before` and `::after` elements require the `content` property to be visible
- `::first-line` and `::first-letter` have limited property support but create powerful typographic effects
- `::selection` allows customization of text selection appearance across browsers
- `::placeholder` enables styling of form input placeholder text with cross-browser considerations
- Pseudo-elements are powerful for decorative elements, icons, counters, and enhanced user interfaces

**Example**

```css
.demo-element {
  position: relative;
  padding: 2rem;
  line-height: 1.6;
}

.demo-element::before {
  content: "📝";
  position: absolute;
  top: 1rem;
  left: 1rem;
  font-size: 1.5em;
}

.demo-element::first-letter {
  float: left;
  font-size: 3em;
  line-height: 0.8;
  margin: 0 0.1em 0 0;
  color: #667eea;
  font-weight: bold;
}

.demo-element::selection {
  background-color: rgba(102, 126, 234, 0.2);
  color: #333;
}
```

**Output** This creates an element with a document emoji positioned in the top-left corner, a large colored drop cap for the first letter, and custom blue selection highlighting when text is selected.

**Next Steps** Understanding pseudo-elements opens the door to advanced CSS techniques including CSS-only interactive components, complex animations with pseudo-element manipulation, and sophisticated design patterns that enhance user experience without JavaScript dependencies.

---
