## Best Practices for URL Handling


Following established practices ensures robust, secure, and maintainable URL handling across applications.

### Use Standard Parsing Libraries

Always use well-tested URL parsing libraries that implement current standards. Avoid writing custom URL parsers, which are prone to edge case errors. In JavaScript, use the URL API. In Python, use urllib.parse. In Java, use java.net.URI or java.net.URL.

### Validate and Sanitize User Input

Never trust user-provided URLs without validation. Check scheme against an allowlist of permitted schemes. Validate host components against security policies. Sanitize path and query components to prevent injection. Consider maximum URL length limits.

### Normalize URLs Consistently

Apply normalization consistently across the application for URL comparison, caching, and deduplication. Use the same normalization level throughout. Document normalization rules for maintenance.

### Handle Encoding Properly

Use proper encoding for special characters in each URL component. Apply UTF-8 encoding consistently. Decode user input before processing. Re-encode for output in appropriate context.

### Implement Security Measures

Validate redirect targets before redirecting. Protect against SSRF in server-side URL fetching. Avoid including credentials in URLs. Implement Content Security Policy to restrict URL usage. Use HTTPS for sensitive resources.

### Consider Internationalization

Support internationalized domain names properly. Implement IDN homograph attack protections. Handle right-to-left text in URLs correctly. Provide clear feedback for non-ASCII domains.

### Document URL Structures

Document expected URL formats for APIs. Specify required and optional components. Provide examples of valid and invalid URLs. Document any scheme-specific or custom handling.

