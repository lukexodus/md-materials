## Protocol Relative URLs


Protocol relative URLs (also called scheme-relative URLs or protocol-agnostic URLs) omit the scheme portion, allowing the browser to use the same protocol as the parent document.

### Syntax

```
//domain.com/path/to/resource
```

The leading `//` indicates a protocol-relative URL.

**Example:**

```html
<!-- On HTTP page: loads http://cdn.example.com/script.js -->
<!-- On HTTPS page: loads https://cdn.example.com/script.js -->
<script src="//cdn.example.com/script.js"></script>
```

### Use Cases

**Content Delivery Networks:**

```html
<link rel="stylesheet" href="//cdn.example.com/styles.css">
<script src="//ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
```

**Embedded content:**

```html
<iframe src="//www.youtube.com/embed/VIDEO_ID"></iframe>
<img src="//images.example.com/photo.jpg">
```

**API requests:**

```javascript
fetch('//api.example.com/data')
  .then(response => response.json())
```

### Advantages

1. **Protocol matching**: Automatically uses parent page protocol
2. **Mixed content avoidance**: Prevents HTTP resources on HTTPS pages
3. **Flexibility**: Works across HTTP and HTTPS environments
4. **Cache efficiency**: Single URL for both protocols [Inference - in CDN scenarios]

### Disadvantages and Limitations

**File protocol issues:** Protocol-relative URLs fail when viewing local files:

```
file:///path/to/page.html loading //cdn.example.com/script.js
Results in: file://cdn.example.com/script.js (invalid)
```

**Modern best practice:** Protocol-relative URLs are now considered **legacy**. Modern recommendation is to use explicit HTTPS URLs:

**Reasons for deprecation:**

1. HTTPS is now standard for all web resources
2. Removes ambiguity in resource loading
3. Enables HTTPS-specific optimizations (HTTP/2, TLS 1.3)
4. Simplifies debugging and resource tracking
5. Prevents accidental HTTP usage on HTTPS sites

**Current recommendation:**

```html
<!-- Legacy approach -->
<script src="//cdn.example.com/script.js"></script>

<!-- Modern approach -->
<script src="https://cdn.example.com/script.js"></script>
```

### Special Contexts

**In HTML:**

```html
<img src="//example.com/image.jpg">           <!-- Protocol relative -->
<img src="https://example.com/image.jpg">     <!-- Explicit HTTPS -->
<img src="/images/photo.jpg">                 <!-- Path relative -->
```

**In CSS:**

```css
/* Protocol relative */
@import url("//fonts.googleapis.com/css?family=Roboto");

/* Background image */
background-image: url("//cdn.example.com/bg.jpg");
```

**In JavaScript:**

```javascript
// Protocol relative
const apiUrl = '//api.example.com/endpoint';

// Explicit HTTPS (preferred)
const apiUrl = 'https://api.example.com/endpoint';
```

**Key Points:**

- Protocol-relative URLs match the parent document's protocol
- Fail with `file://` protocol in local development
- Considered legacy; explicit HTTPS is now preferred
- May still appear in older codebases or documentation
- Useful historically for HTTP/HTTPS transition periods

