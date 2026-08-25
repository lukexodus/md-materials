## What are URIs and URLs


A **Uniform Resource Identifier (URI)** is a string of characters that identifies a resource on the internet or within a system. It provides a standardized way to name and locate resources using a specific syntax defined by RFC 3986.

A **Uniform Resource Locator (URL)** is a specific type of URI that not only identifies a resource but also provides the means to locate it by describing its primary access mechanism, typically its network location. URLs include the protocol (scheme) needed to access the resource.

URIs serve as the fundamental addressing mechanism for the web and other networked systems. They enable consistent identification of resources regardless of their physical location or implementation details.

**Key Points:**

- URIs are identifiers that may or may not provide location information
- URLs are locators that always specify how to access a resource
- Both follow the syntax defined in RFC 3986
- URIs enable resource abstraction and location independence

**Example:**

```
URI: urn:isbn:0-486-27557-4
URL: https://example.com/book/12345
URL: ftp://files.example.com/document.pdf
URI: mailto:user@example.com
```

