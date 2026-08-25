## Standards Compliance Considerations


### When to Follow RFC 3986

**Appropriate contexts:**

- Implementing URI parsers for non-web contexts
- Designing new URI schemes
- Protocol specifications requiring formal grammar
- Systems requiring strict validation without error recovery

### When to Follow WHATWG URL Standard

**Appropriate contexts:**

- Web browser implementation
- Client-side JavaScript applications
- Server-side rendering for web applications
- Systems requiring compatibility with browser behavior
- Applications using the URL API

### Interoperability Challenges

When working across both standards, be aware of:

**Encoding differences:** Some characters may be encoded differently.

**File URL handling:** Significant differences in file: URL interpretation, especially with Windows paths.

**Error handling:** RFC 3986 may reject inputs that WHATWG processes with recovery.

**Host parsing:** IPv6 address parsing and domain validation may differ.

**[Inference] Best practice:** For web-facing applications, follow WHATWG standards for consistency with browser behavior. For formal protocol design or non-web contexts, RFC 3986 may be more appropriate.

