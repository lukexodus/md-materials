## URL Rewriting and Routing


URL rewriting transforms incoming URLs into different internal forms for processing. Routing maps URLs to application handlers or resources.

### Server-Side Rewriting

Server-side rewriting modifies URLs before passing them to application logic. Common uses include creating clean, readable URLs, implementing redirects for moved content, enforcing canonical URL formats, and providing backward compatibility.

**Example:**

```
Original: /products.php?id=123&category=shoes
Rewritten: /products/shoes/123

Original: /old-page.html
Rewritten: /new-page.html (with redirect)
```

### Client-Side Routing

Single-page applications use client-side routing to handle navigation without full page reloads. The History API enables changing URLs without navigation. Hash-based routing uses fragment identifiers for routing.

Modern approaches prefer History API routing with server-side fallback for direct navigation and proper handling of initial page loads.

### SEO Considerations

URL structure affects search engine optimization. Descriptive paths improve relevance signals. Consistent structure aids crawling and indexing. Canonical URLs prevent duplicate content issues. Proper redirects maintain link equity.

**Conclusion:**

URL and URI standards provide the foundation for resource identification and location on the internet. Understanding these standards enables building robust, secure, and interoperable applications. RFC 3986 offers the generic URI framework, while the WHATWG URL Standard specifies modern web URL handling with precise parsing algorithms. Proper URL handling requires attention to encoding, normalization, security, and scheme-specific behaviors. Following established standards and best practices ensures consistent behavior across platforms and protects against common security vulnerabilities.

---

