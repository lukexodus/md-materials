## Difference between URI, URL, and URN


The relationship between URI, URL, and URN follows a hierarchical classification where URI is the broadest category.

**Uniform Resource Identifier (URI)** is the complete set of all identifiers. Every URL and URN is a URI, but not every URI is a URL or URN.

**Uniform Resource Locator (URL)** identifies a resource by its location and access method. It specifies the protocol scheme (http, ftp, mailto) and the path to the resource. URLs answer "where is it and how do I get it?"

**Uniform Resource Name (URN)** identifies a resource by name within a particular namespace, independent of location. URNs are persistent identifiers that remain valid even if the resource moves or becomes unavailable. They answer "what is it called?" without specifying location.

**Key Points:**

- URI = URL + URN (conceptually)
- URLs contain access mechanisms (schemes like http://, ftp://)
- URNs use the "urn:" scheme and require namespace identifiers
- URLs can break when resources move; URNs remain stable
- Most web addresses are URLs, making them a subset of URIs

**Example:**

```
URL: https://www.example.com/page.html
     (location-based, includes protocol and domain)

URN: urn:isbn:978-3-16-148410-0
     (name-based, identifies a book regardless of where copies exist)

URI: /path/to/resource
     (relative reference, context-dependent)

URI: #section-2
     (fragment identifier, references part of a document)
```

The distinction became less emphasized in modern specifications. RFC 3986 uses "URI" as the primary term, treating URLs as URIs with specific characteristics rather than a separate category.

