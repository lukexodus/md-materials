# HTML Quirks Mode vs Standards Mode

HTML documents can be rendered by browsers in different modes that affect how the page is displayed and how CSS is interpreted. The two primary modes are **quirks mode** and **standards mode**.

## What They Are

**Standards mode** renders pages according to modern web standards (HTML and CSS specifications from W3C and WHATWG). The browser follows strict, predictable rules for layout and styling.

**Quirks mode** emulates older browser behavior (primarily Internet Explorer 5 and Netscape Navigator 4) to maintain backward compatibility with websites built before web standards were widely adopted. The browser intentionally implements non-standard behaviors and bugs from legacy browsers.

## How the Mode Is Determined

The browser determines which mode to use based on the **DOCTYPE declaration** at the beginning of the HTML document:

**Standards mode** is triggered by modern DOCTYPE declarations:
```html
<!DOCTYPE html>
```
or older strict DOCTYPEs like:
```html
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
```

**Quirks mode** is triggered by:
- Missing DOCTYPE declaration
- Incomplete or malformed DOCTYPE
- Very old DOCTYPE declarations
- Certain content before the DOCTYPE (like comments or XML declarations)

There's also a third mode called **almost standards mode** (or "limited quirks mode"), triggered by certain transitional DOCTYPEs, which behaves mostly like standards mode with minor exceptions for table cell sizing.

## Key Differences

### Box Model
In quirks mode, the CSS `width` and `height` properties include padding and borders (similar to IE 5's behavior). In standards mode, these properties only define the content area, with padding and borders added outside.

### Layout and Sizing
Tables, images, and form elements have different default sizing behaviors. Font sizes using relative units may calculate differently. Percentage heights behave differently depending on how parent elements are defined.

### CSS Parsing
Class and ID selectors are case-insensitive in quirks mode but case-sensitive in standards mode (for HTML). Some CSS properties may be parsed differently or have different default values.

### Inline Elements
The handling of `overflow` and `width`/`height` on inline elements differs between modes.

## Why This Matters

Modern web development should always use standards mode by including `<!DOCTYPE html>` at the start of every HTML document. Quirks mode exists primarily for legacy compatibility, and relying on it can lead to inconsistent behavior across browsers and unpredictable layouts.

Most contemporary websites and frameworks assume standards mode, and quirks mode rendering can break modern CSS techniques, responsive designs, and JavaScript that expects standard-compliant DOM behavior.