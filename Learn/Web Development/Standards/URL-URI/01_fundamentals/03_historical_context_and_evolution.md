## Historical Context and Evolution


The concept of URIs emerged from Tim Berners-Lee's work on the World Wide Web at CERN in the early 1990s. The first specification appeared in RFC 1630 (1994), titled "Universal Resource Identifiers in WWW."

**RFC 1738 (1994)** defined Uniform Resource Locators (URLs) as the first practical implementation of web addressing. It established schemes like http, ftp, gopher, mailto, news, telnet, and file. This specification focused on locating resources through network protocols.

**RFC 2396 (1998)** introduced "Uniform Resource Identifiers (URI): Generic Syntax," merging and clarifying the concepts of URLs and URNs under the broader URI umbrella. It defined the syntax that would form the basis for modern URI standards.

**RFC 2141 (1997)** separately specified URN syntax for persistent, location-independent identifiers. URNs were designed for long-term resource identification, particularly for digital libraries and bibliographic systems.

**RFC 3986 (2005)** superseded RFC 2396 and became the current standard for URI syntax. It refined the grammar, clarified ambiguities, and improved internationalization support. This specification unified the terminology and established "URI" as the primary term.

**RFC 3987 (2005)** introduced Internationalized Resource Identifiers (IRIs), extending URIs to support Unicode characters beyond ASCII. This enabled URIs in non-Latin scripts.

**Key Points:**

- 1990-1994: Initial WWW development and first URI concepts
- 1994-1998: Separate URL and URN specifications
- 1998-2005: Consolidation under URI terminology
- 2005-present: Modern URI standard (RFC 3986) with IRI support
- Terminology shifted from "Universal" to "Uniform" Resource Identifier

The evolution reflected changing understanding of web architecture. Early specifications treated URLs and URNs as distinct systems, but experience showed they shared common syntax and could be unified under the URI framework.

**Example:**

```
Early URL (RFC 1738):
http://www.example.com:80/path/file.html

Modern URI (RFC 3986):
https://example.com/path/file.html
(simplified syntax, HTTPS as default)

IRI (RFC 3987):
https://例え.jp/パス/ファイル
(Unicode support for international domains)
```

The standards continue evolving through the IETF (Internet Engineering Task Force), with additional specifications addressing specific schemes, security considerations, and new web technologies.

