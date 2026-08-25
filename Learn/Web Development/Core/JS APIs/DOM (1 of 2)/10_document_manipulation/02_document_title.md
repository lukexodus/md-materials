## document.title


### Core Mechanics

`document.title` is a string property representing the title displayed in the browser tab, window title bar, bookmarks, and history. It reads from and writes to the `<title>` element in the document's `<head>`.

```javascript
// Read current title
console.log(document.title); // "My Page"

// Set new title
document.title = "New Title"; // Updates <title> element and browser UI
```

Both getter and setter operations are synchronous and immediately reflected in the DOM and browser chrome.

### Relationship with \<title> Element

`document.title` provides direct access to the text content of `<title>`:

```javascript
// These are equivalent
document.title = "Example";

const titleEl = document.querySelector('title');
titleEl.textContent = "Example";
```

[Inference: document.title is a convenience accessor for the title element's text]

If no `<title>` element exists, reading returns empty string. Setting creates a `<title>` element if missing:

```javascript
// Document with no <title>
console.log(document.title); // ""

document.title = "Created";
// Now <title>Created</title> exists in <head>
```

### Multiple \<title> Elements

If multiple `<title>` elements exist (invalid HTML), `document.title` targets the first one:

```javascript
<head>
  <title>First</title>
  <title>Second</title>
</head>

console.log(document.title); // "First"

document.title = "Updated";
// Only first <title> changes to "Updated"
// Second remains "Second"
```

[Unverified: Exact behavior may vary slightly across browsers, but first-element priority is standard]

### Character Encoding and Special Characters

Supports Unicode characters directly:

```javascript
document.title = "Hello 世界 🌍";
// Displays correctly in browser UI if font supports glyphs
```

HTML entities are **not interpreted** when setting via JavaScript:

```javascript
document.title = "Test &amp; Example";
// Displays as: Test &amp; Example (literal ampersand-amp-semicolon)
// Not: Test & Example

// Correct approach for ampersand:
document.title = "Test & Example"; // Displays: Test & Example
```

When setting innerHTML on title element, entities are parsed:

```javascript
document.querySelector('title').innerHTML = "Test &amp; Example";
// Displays: Test & Example (entity converted)
```

### Whitespace Handling

Leading and trailing whitespace is preserved when setting:

```javascript
document.title = "  Spaced  ";
console.log(document.title); // "  Spaced  "
// Browser tab shows with spaces
```

Internal whitespace collapses in some contexts [Unverified: browser-specific rendering]:

```javascript
document.title = "Multiple    Spaces";
// May display with collapsed spaces in some browser UIs
```

Newlines and tabs are preserved but may render as spaces:

```javascript
document.title = "Line 1\nLine 2\tTabbed";
// Stored literally, but browser UI typically renders as single-line with spaces
```

### Maximum Length Constraints

[Unverified: Exact limits are browser and platform-specific]

Browsers impose practical limits on title length:

- **Chrome/Edge**: ~1000 characters before truncation in tab display
- **Firefox**: Similar length before tab truncation
- **Safari**: May truncate earlier in tab UI

No programmatic error occurs with long titles:

```javascript
document.title = "A".repeat(10000); // No error
// But browser UI will truncate display
```

Full title remains accessible via `document.title` even if UI truncates.

### Empty String Behavior

Setting empty string is valid:

```javascript
document.title = "";
// Browser tab shows: (empty) or fallback text
// <title></title> exists but empty
```

Browser fallback behavior when title is empty [Unverified: specific defaults vary]:

- May show document URL
- May show "Untitled"
- May show blank tab

### Title Changes and Browser History

Each `document.title` modification updates the history entry:

```javascript
history.pushState({}, "", "/page");
document.title = "New Title";
// Back button now shows "New Title" for this history entry
```

[Inference: Title changes affect current history state's display]

Changing title doesn't create new history entries—it updates the current entry's metadata:

```javascript
document.title = "Title 1";
document.title = "Title 2";
document.title = "Title 3";
// No new history entries created
// Only current page shows "Title 3"
```

### Single-Page Application Patterns

SPAs typically update title on route changes:

```javascript
function navigateTo(route, title) {
  history.pushState({}, "", route);
  document.title = title;
  // Render new content
}

// Common pattern with template
function setTitle(pageName) {
  document.title = `${pageName} | Site Name`;
}
```

Dynamic title updates improve:

- Back/forward navigation display
- Bookmark quality
- Browser history clarity
- Screen reader announcements [Inference]

### Security and XSS Considerations

`document.title` doesn't execute scripts:

```javascript
document.title = "<script>alert('XSS')</script>";
// Displays literally: <script>alert('XSS')</script>
// No script execution
```

HTML tags are not rendered:

```javascript
document.title = "<b>Bold</b> Text";
// Displays: <b>Bold</b> Text (tags as text)
```

Safe for user-generated content without sanitization [Inference: based on text-only nature]:

```javascript
document.title = userInput; // Safe from XSS
// Worst case: weird title display, no execution
```

### Document Type Variations

**HTML documents**: Standard behavior as described

**XML documents** [Unverified: XML-specific behavior]:

```javascript
// XML document
document.title = "XML Title";
// May not affect <title> element the same way
// Browser support varies
```

**SVG documents embedded as standalone**:

```javascript
// SVG <title> element has different purpose (accessibility)
// document.title interaction varies by context [Unverified]
```

**iframes**:

```javascript
// Each iframe has its own document.title
iframe.contentDocument.title = "Frame Title";
// Doesn't affect parent or browser tab display
// Only affects internal document representation
```

### Reading vs Setting Performance

[Inference: Based on typical DOM access patterns]

**Reading**: Fast, direct property access

- No layout calculation required
- Simple string return from cached value

**Setting**: Slightly more expensive

- Updates DOM tree (`<title>` element)
- Triggers browser chrome updates (tab display)
- May trigger accessibility tree updates
- No layout reflow (title not rendered in page)

Neither operation is expensive enough to cause performance concerns in normal usage.

### Notification Pattern with Title

Common technique for drawing attention:

```javascript
let original = document.title;
let blinkState = false;

const interval = setInterval(() => {
  document.title = blinkState ? original : "🔴 New Message!";
  blinkState = !blinkState;
}, 1000);

// Stop on focus
window.addEventListener('focus', () => {
  clearInterval(interval);
  document.title = original;
});
```

Creates flashing effect in browser tab to notify users of events in background tabs.

### Title and SEO Impact

Search engines use `document.title` for:

- Search result display titles
- Ranking signals (keyword relevance)
- Social media sharing metadata (fallback)

[Inference: Based on common SEO practices]

JavaScript-set titles are crawled by modern search engines:

```javascript
// Executes before crawlers finish rendering
document.title = "Dynamically Set Title";
// Google/Bing will index this title
```

However, initial HTML `<title>` is preferred for:

- Faster crawler discovery
- Guaranteed indexing before JavaScript execution
- Support for non-JavaScript crawlers

### Template Literal Patterns

Common construction patterns:

```javascript
// With optional sections
const category = "Tech";
const article = "JavaScript Tips";
document.title = `${article}${category ? ` - ${category}` : ""} | My Blog`;
// "JavaScript Tips - Tech | My Blog"

// Conditional formatting
const unread = 5;
document.title = unread > 0 ? `(${unread}) Messages` : "Messages";
// "(5) Messages"

// Localization helper
function setLocalizedTitle(key, params) {
  const template = i18n.get(key);
  document.title = template.replace(/{(\w+)}/g, (_, k) => params[k]);
}
```

### MutationObserver on Title

Can observe title changes via DOM mutations:

```javascript
const observer = new MutationObserver((mutations) => {
  mutations.forEach((mutation) => {
    if (mutation.target.nodeName === 'TITLE') {
      console.log('Title changed to:', document.title);
    }
  });
});

observer.observe(
  document.querySelector('title'),
  { childList: true, characterData: true, subtree: true }
);

document.title = "New"; // Triggers observer
```

Useful for tracking title changes made by third-party scripts or libraries.

### iframe Parent Access

Child iframe cannot directly modify parent title due to same-origin policy:

```javascript
// In iframe (different origin)
parent.document.title = "Attack"; // SecurityError
```

Same-origin iframes can modify parent:

```javascript
// Same-origin iframe
parent.document.title = "Changed from iframe"; // Works
```

[Inference: Standard cross-origin security applies]

### Default Title Fallback

When no title is set [Unverified: specific defaults vary by browser]:

**New blank document**:

```javascript
const newDoc = document.implementation.createHTMLDocument();
console.log(newDoc.title); // "" (empty string)
```

**data: URLs**:

```javascript
window.open('data:text/html,<h1>Test</h1>');
// Tab may show "data:text/html,..." or truncated version
```

**file:// URLs without title**:

```javascript
// Local file with no <title>
// Tab typically shows filename
```

### Screen Reader Announcements

[Inference: Accessibility behavior based on typical AT implementation]

When `document.title` changes, some screen readers announce the new title:

```javascript
document.title = "Page Loaded";
// May trigger screen reader announcement
```

Announcement behavior varies:

- Some SRs announce on every change
- Some only announce on page load
- Some require focus change to announce [Unverified]

For explicit announcements, use ARIA live regions instead:

```javascript
// More reliable for screen readers
liveRegion.textContent = "Content updated";
// Rather than relying on title change announcement
```

### Title Persistence Across Navigation

`document.title` is page-specific:

```javascript
document.title = "Page 1";
location.href = "/page2"; // Navigate away
// Title doesn't persist to new page
```

For maintaining title patterns across navigation, use:

- Server-side rendering with title in HTML
- SPA router with title management
- Meta-framework conventions (Next.js, Nuxt, etc.)

### documentElement.title vs document.title

They are **different properties**:

```javascript
console.log(document.title); // <title> element text
console.log(document.documentElement.title); // "" (empty)

document.documentElement.title = "Test";
// Sets title attribute on <html> element
// <html title="Test">
// Does NOT affect browser tab display
```

`documentElement.title` is a generic `title` attribute, not the document title.

### Getter/Setter Overriding

Can override with defineProperty:

```javascript
let customTitle = document.title;

Object.defineProperty(document, 'title', {
  get() { return `[Custom] ${customTitle}`; },
  set(value) { 
    customTitle = value;
    document.querySelector('title').textContent = value;
  }
});

document.title = "Test";
console.log(document.title); // "[Custom] Test"
```

[Inference: Overriding may break third-party code expecting standard behavior]

Practical use cases are limited—generally not recommended.

### Print Dialog Title

`document.title` determines the default filename in print/save dialogs:

```javascript
document.title = "Q4-Report-2024";
window.print();
// Print dialog suggests "Q4-Report-2024.pdf" as filename
```

[Unverified: Exact filename generation varies by browser and OS]

Sanitize titles when using for automated printing:

```javascript
// Remove problematic filename characters
document.title = title.replace(/[<>:"/\\|?*]/g, '-');
```

### Title in Browser Extensions

Extensions can read/modify titles across origins:

```javascript
// Content script with host permissions
chrome.tabs.executeScript({
  code: 'document.title = "Modified by Extension"'
});
```

[Inference: Subject to extension permissions model]

Useful for:

- Tab management tools
- Productivity trackers
- Custom tab naming
- Session managers

### Null and Undefined Coercion

Setting null or undefined converts to string:

```javascript
document.title = null;
console.log(document.title); // "null"

document.title = undefined;
console.log(document.title); // "undefined"
```

Always provide explicit strings:

```javascript
document.title = value || "Default Title";
document.title = value ?? "Default Title"; // Nullish coalescing preferred
```

### Document.write and Title

Using `document.write` after page load replaces entire document, including title:

```javascript
document.title = "Original";
document.write("<h1>New Content</h1>");
// Entire document replaced
// document.title now "" (no <title> in new content)
```

Avoid `document.write` post-load. For dynamic title updates, use direct assignment.

### CSP and Title Modification

Content Security Policy does **not restrict** `document.title` modification:

```javascript
// Even with strict CSP
document.title = "Any String";
// Works without restriction
```

[Inference: Title modification is not considered script execution]

CSP restrictions apply to:

- `<title>` element creation via innerHTML containing scripts
- Not to plain text title assignment

### Title in Worker Contexts

Web Workers and Service Workers have no `document` object:

```javascript
// Inside worker
console.log(document); // ReferenceError: document is not defined
// Cannot access or modify title from worker
```

To update title from worker, post message to main thread:

```javascript
// In worker
postMessage({ type: 'updateTitle', title: 'New Title' });

// In main thread
worker.onmessage = (e) => {
  if (e.data.type === 'updateTitle') {
    document.title = e.data.title;
  }
};
```

---

