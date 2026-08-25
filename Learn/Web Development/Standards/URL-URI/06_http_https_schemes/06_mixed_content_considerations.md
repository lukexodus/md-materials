## Mixed Content Considerations


Mixed content occurs when an HTTPS page loads resources over HTTP, creating security vulnerabilities. Browsers implement strict policies to protect users from these risks.

### Types of Mixed Content

**Passive (Display) Mixed Content:** Resources that cannot substantially alter page behavior:

- Images (`<img>`)
- Audio (`<audio>`)
- Video (`<video>`)
- Object embeds (`<object>`)

**Example:**

```html
<!-- HTTPS page loading HTTP image -->
<img src="http://example.com/image.jpg">
```

**Active Mixed Content:** Resources that can modify the entire page or steal credentials:

- Scripts (`<script>`)
- Stylesheets (`<link rel="stylesheet">`)
- Iframes (`<iframe>`)
- XMLHttpRequest/Fetch requests
- Web fonts (`@font-face`)
- WebSockets

**Example:**

```html
<!-- HTTPS page loading HTTP script - BLOCKED -->
<script src="http://example.com/script.js"></script>
```

### Browser Behavior

Modern browsers implement aggressive mixed content blocking:

1. **Active mixed content**: Automatically blocked, no user override
2. **Passive mixed content**: May be blocked or display warnings [Browser-dependent behavior]
3. **Console warnings**: Detailed information about blocked resources
4. **HTTPS enforcement**: Increasing strictness in newer browser versions

**Example** browser console output:

```
Mixed Content: The page at 'https://secure.example.com/' was loaded over HTTPS, 
but requested an insecure script 'http://insecure.example.com/script.js'. 
This request has been blocked; the content must be served over HTTPS.
```

### Upgrading Mixed Content

Strategies to resolve mixed content issues:

**1. Use HTTPS URLs:**

```html
<!-- Before -->
<img src="http://cdn.example.com/image.jpg">

<!-- After -->
<img src="https://cdn.example.com/image.jpg">
```

**2. Use protocol-relative URLs** (see dedicated section below):

```html
<img src="//cdn.example.com/image.jpg">
```

**3. Content Security Policy with upgrade-insecure-requests:**

```http
Content-Security-Policy: upgrade-insecure-requests
```

This directive instructs the browser to automatically upgrade HTTP requests to HTTPS.

**4. Serve all resources from same origin:**

```html
<!-- Relative URL - inherits page protocol -->
<img src="/images/photo.jpg">
```

### Testing for Mixed Content

Detection methods:

1. **Browser DevTools**: Check Console and Security tabs
2. **Security panel**: Shows mixed content warnings and details
3. **Automated scanners**: Tools that crawl sites for mixed content
4. **Certificate validation**: Verify full HTTPS chain

**Key Points:**

- Always use HTTPS for all resources on HTTPS pages
- Active mixed content is always blocked by modern browsers
- Passive mixed content may generate warnings or be blocked
- Use DevTools to identify and fix mixed content issues
- Consider Content Security Policy for automated upgrades

