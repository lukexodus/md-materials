# Syllabus

## Module 1: Fundamentals

- What are URIs and URLs
- Difference between URI, URL, and URN
- Historical context and evolution
- Purpose and use cases
- Resource identification concept
- Web addressing basics
- Importance in web architecture
- Standards organizations (IETF, WHATWG)

## Module 2: URI (Uniform Resource Identifier) - RFC 3986

- RFC 3986 specification overview
- URI syntax components
- Generic URI syntax
- URI character encoding
- Reserved vs unreserved characters
- URI normalization
- URI comparison rules
- Hierarchical vs non-hierarchical URIs

## Module 3: URL Standard (WHATWG Living Standard)

- WHATWG URL Standard overview
- Living standard concept
- Differences from RFC 3986
- Browser implementation alignment
- URL parsing algorithm
- URL serialization
- Modern URL handling
- Backward compatibility considerations

## Module 4: URI Syntax Components

- Scheme component
- Authority component
- Path component
- Query component
- Fragment component
- Component separator characters
- Optional vs required components
- Component ordering rules

## Module 5: URI Schemes

- Scheme definition and purpose
- Common schemes (http, https, ftp, file)
- Permanent vs provisional schemes
- IANA URI scheme registry
- Scheme-specific syntax rules
- Case sensitivity in schemes
- Custom scheme definition
- Deprecated schemes

## Module 6: HTTP/HTTPS Schemes

- http:// scheme syntax
- https:// scheme syntax
- Default ports (80, 443)
- Security implications
- Mixed content considerations
- HTTPS-only mode
- Protocol relative URLs
- Scheme upgrading

## Module 7: Authority Component

- Authority syntax (userinfo@host:port)
- User information (userinfo)
- Host component
- Port component
- IPv4 addresses
- IPv6 addresses
- Domain names
- Authority parsing rules

## Module 8: Host Component

- DNS hostname syntax
- Domain name structure
- Top-level domains (TLDs)
- Subdomains
- Internationalized Domain Names (IDN)
- Punycode encoding
- IP addresses as hosts
- localhost and special hostnames

## Module 9: Internationalized Domain Names (IDN)

- IDN overview and purpose
- Unicode domain names
- Punycode encoding algorithm
- xn-- prefix
- IDNA (Internationalized Domain Names in Applications)
- IDNA2003 vs IDNA2008
- IDN security concerns (homograph attacks)
- Browser IDN support

## Module 10: IPv4 and IPv6 in URLs

- IPv4 address syntax (192.0.2.1)
- IPv6 address syntax ([2001:db8::1])
- IPv6 bracket notation requirement
- IPv4-mapped IPv6 addresses
- Zone identifiers in IPv6
- IP address validation
- Localhost addresses
- Special-use addresses

## Module 11: Port Numbers

- Port component syntax
- Default ports by scheme
- Well-known ports (0-1023)
- Registered ports (1024-49151)
- Dynamic/private ports (49152-65535)
- Port omission rules
- Non-standard port usage
- Security implications of port exposure

## Module 12: Path Component

- Path syntax and structure
- Absolute vs relative paths
- Path segments
- Hierarchical path structure
- Root path (/)
- Empty path
- Dot segments (. and ..)
- Path normalization

## Module 13: Path Encoding and Special Characters

- Percent-encoding (URL encoding)
- Reserved characters in paths
- Unreserved characters
- Path segment delimiters (/)
- Special path segments
- Case sensitivity in paths
- Path comparison rules
- Platform-specific path handling

## Module 14: Query Component

- Query string syntax
- Question mark delimiter (?)
- Key-value pair format
- Ampersand separator (&)
- Multiple values for same key
- Empty query strings
- Query string encoding
- Query string parsing

## Module 15: Query String Encoding

- application/x-www-form-urlencoded
- Percent-encoding in queries
- Space encoding (+ vs %20)
- Reserved characters in queries
- UTF-8 encoding requirement
- Character encoding declaration
- Special character handling
- Encoding best practices

## Module 16: Query String Patterns

- Search parameters (?q=search)
- Pagination parameters (?page=2)
- Filtering parameters (?filter=active)
- Sorting parameters (?sort=date)
- Multiple parameter handling
- Array parameters (?id[]=1&id[]=2)
- Nested parameters
- Parameter ordering significance

## Module 17: Fragment Component

- Fragment identifier syntax
- Hash/pound sign delimiter (#)
- Fragment semantics
- Fragment and server requests
- Client-side routing with fragments
- Fragment encoding
- Fragment vs query string
- Accessibility considerations

## Module 18: Fragment Identifiers in Different Contexts

- HTML anchor fragments
- Media fragments (temporal, spatial)
- SVG fragments
- PDF fragments
- JSON fragments (JSON Pointer)
- XML fragments (XPointer)
- Plain text fragments
- Custom fragment schemes

## Module 19: Percent-Encoding (URL Encoding)

- Percent-encoding algorithm
- Encoding non-ASCII characters
- UTF-8 byte sequences
- Hexadecimal representation
- Reserved character encoding
- Double encoding issues
- Decoding process
- Encoding consistency

## Module 20: Reserved Characters

- gen-delims (: / ? # [ ] @)
- sub-delims (! $ & ' ( ) * + , ; =)
- When to encode reserved characters
- Context-specific encoding rules
- Reserved vs unreserved distinction
- Character encoding by component
- Special cases and exceptions
- RFC 3986 reserved character list

## Module 21: Unreserved Characters

- ALPHA (A-Z, a-z)
- DIGIT (0-9)
- Hyphen (-)
- Period (.)
- Underscore (_)
- Tilde (~)
- Never need encoding
- Safe characters in URLs
- Cross-component usage

## Module 22: Relative URLs

- Relative reference concept
- Relative path references
- Network-path references (//)
- Absolute-path references (/)
- Relative-path references
- Base URI concept
- Relative URL resolution
- Use cases for relative URLs

## Module 23: URL Resolution

- Base URL determination
- Resolution algorithm (RFC 3986)
- Merging paths
- Removing dot segments
- Component inheritance
- Resolution examples
- Edge cases in resolution
- Browser resolution behavior

## Module 24: Absolute vs Relative URLs

- Absolute URL definition
- Relative URL definition
- When to use absolute URLs
- When to use relative URLs
- Performance implications
- Portability considerations
- Protocol-relative URLs
- Context-dependent URLs

## Module 25: URL Normalization

- Normalization purpose
- Case normalization (scheme, host)
- Percent-encoding normalization
- Path segment normalization
- Default port removal
- Empty path normalization
- Canonical URL forms
- Normalization for comparison

## Module 26: URL Comparison

- Simple string comparison
- Syntax-based normalization
- Scheme-based normalization
- Protocol-based normalization
- Equivalence testing
- Case sensitivity rules
- Percent-encoding equivalence
- Practical comparison strategies

## Module 27: Data URLs

- data: URI scheme
- Media type specification
- Base64 encoding
- Plain text data URLs
- Image data URLs
- Inline resources
- Size limitations
- Performance considerations

## Module 28: Blob URLs

- blob: URL scheme
- Creating blob URLs (URL.createObjectURL)
- Revoking blob URLs (URL.revokeObjectURL)
- Blob URL lifetime
- Security origin
- Use cases (file uploads, downloads)
- Memory management
- Cross-origin considerations

## Module 29: File URLs

- file:// URL scheme
- Local file system access
- File URL syntax variations
- UNC path representation
- Platform-specific file URLs (Windows, Unix, macOS)
- Security restrictions
- Browser file URL handling
- File URL limitations

## Module 30: JavaScript URL API

- URL constructor
- URL interface properties
- URLSearchParams interface
- Creating URL objects
- Parsing URLs
- Manipulating URL components
- Serializing URLs
- Browser compatibility

## Module 31: URL Object Properties

- href property
- protocol property
- username property
- password property
- host property
- hostname property
- port property
- pathname property
- search property
- searchParams property
- hash property
- origin property

## Module 32: URLSearchParams API

- URLSearchParams constructor
- append() method
- delete() method
- get() method
- getAll() method
- has() method
- set() method
- entries(), keys(), values() methods
- toString() method
- forEach() iteration
- Sorting parameters

## Module 33: URL Validation

- Valid URL criteria
- Malformed URL detection
- Validation libraries
- Browser URL validation
- Server-side validation
- Common validation errors
- Security validation concerns
- User input validation

## Module 34: URL Shortening

- URL shortener concepts
- Short URL generation
- Redirect mechanisms
- Custom short URLs
- Analytics and tracking
- URL shortener services
- Self-hosted shorteners
- Security considerations

## Module 35: Pretty URLs and Slugs

- Human-readable URLs
- Slug generation
- Removing special characters
- Handling Unicode in slugs
- Slug uniqueness
- Date-based URLs
- Category-based URLs
- SEO benefits

## Module 36: URL Routing

- URL pattern matching
- Route parameters
- Path parameters (/users/:id)
- Query parameters in routing
- Wildcard routes
- Regular expression routes
- Route priorities
- Named routes

## Module 37: URL Rewriting

- URL rewriting concept
- .htaccess rewrite rules
- Apache mod_rewrite
- Nginx rewrite directives
- IIS URL Rewrite module
- Rewrite flags and conditions
- Redirect vs rewrite
- Clean URL strategies

## Module 38: Canonical URLs

- Canonical URL definition
- rel="canonical" link element
- Duplicate content issues
- Canonical URL selection
- Cross-domain canonicalization
- Self-referencing canonical
- Canonical vs 301 redirect
- SEO implications

## Module 39: URL Parameters for Tracking

- UTM parameters (utm_source, utm_medium, utm_campaign)
- Google Analytics parameters
- Facebook Click ID (fbclid)
- Google Click ID (gclid)
- Custom tracking parameters
- Parameter pollution
- Privacy considerations
- Parameter stripping

## Module 40: URL Security

- Open redirect vulnerabilities
- URL injection attacks
- Phishing via URL manipulation
- Homograph attacks
- URL parameter tampering
- SSRF (Server-Side Request Forgery)
- URL validation for security
- Sanitizing user-provided URLs

## Module 41: Safe URL Practices

- Validating user input
- Whitelist allowed schemes
- Restricting URL characters
- Preventing XSS via URLs
- HTTPS enforcement
- URL encoding user data
- Avoiding sensitive data in URLs
- Rate limiting URL endpoints

## Module 42: URL Length Limitations

- Browser URL length limits
- Server URL length limits
- HTTP specification (no formal limit)
- Internet Explorer limits (2083 characters)
- Chrome, Firefox, Safari limits
- GET request implications
- POST as alternative
- Practical length recommendations

## Module 43: URL Redirects

- 301 Moved Permanently
- 302 Found (temporary)
- 303 See Other
- 307 Temporary Redirect
- 308 Permanent Redirect
- Redirect chains
- Redirect loops
- SEO impact of redirects

## Module 44: URL Structure Best Practices

- Hierarchical structure
- Logical organization
- Keeping URLs short
- Using hyphens vs underscores
- Avoiding special characters
- Lowercase URLs
- Avoiding session IDs in URLs
- Consistent URL patterns

## Module 45: RESTful URL Design

- Resource-based URLs
- Noun vs verb in URLs
- Collection resources (/users)
- Member resources (/users/123)
- Sub-resources (/users/123/posts)
- Filtering with query strings
- Versioning in URLs (/v1/users)
- HTTP methods and URLs

## Module 46: API URL Conventions

- Base URL structure
- API versioning strategies
- Endpoint naming
- Resource nesting limits
- Plural vs singular nouns
- Query parameter conventions
- Pagination URLs
- Filtering and searching

## Module 47: URL Internationalization (i18n)

- Language in URLs (en-us/page)
- Subdomain vs subdirectory
- Country code TLDs
- hreflang annotations
- UTF-8 in URLs
- RTL language considerations
- Locale detection
- URL translation strategies

## Module 48: Mobile Deep Links

- Deep linking concept
- URI schemes for apps (myapp://)
- Universal Links (iOS)
- App Links (Android)
- Custom URL schemes
- Fallback to web URLs
- Deep link routing
- Branch.io and similar services

## Module 49: QR Codes and URLs

- Encoding URLs in QR codes
- URL shortening for QR codes
- QR code capacity
- Error correction levels
- QR code best practices
- Dynamic QR codes
- Tracking QR code scans
- QR code security

## Module 50: URL Performance Optimization

- DNS lookup impact
- Connection reuse
- URL length and performance
- Query string caching
- CDN URLs
- Resource hints (dns-prefetch, preconnect)
- Domain sharding (legacy)
- HTTP/2 and multiple domains

## Module 51: URL Parsing Algorithms

- WHATWG URL parsing algorithm
- State machine approach
- Parsing steps
- Error handling in parsing
- Compatibility with RFC 3986
- Browser parsing differences
- Server-side parsing
- Parser implementation considerations

## Module 52: URL Serialization

- Serialization algorithm
- Component ordering
- Percent-encoding during serialization
- Omitting default ports
- Empty component handling
- Canonical serialization
- Cross-platform serialization
- String representation

## Module 53: URL in Different Programming Languages

- JavaScript (URL API)
- Python (urllib.parse)
- Java (java.net.URL, java.net.URI)
- PHP (parse_url, http_build_query)
- Ruby (URI module)
- Go (net/url package)
- C# (System.Uri)
- Rust (url crate)

## Module 54: URL Manipulation Libraries

- JavaScript: url-parse, query-string
- Python: furl, yarl
- Node.js: url module
- Java: Apache Commons UrlBuilder
- PHP: League\Uri
- Ruby: Addressable
- Cross-language comparisons
- Library selection criteria

## Module 55: URL Testing and Debugging

- Testing URL parsing
- Testing URL generation
- Debugging malformed URLs
- Browser developer tools
- URL testing tools
- Online URL encoders/decoders
- Unit testing URLs
- Integration testing with URLs

## Module 56: URL in Web Frameworks

- Express.js URL handling
- Django URL routing
- Ruby on Rails routing
- ASP.NET Core routing
- Spring Boot URL mapping
- Laravel routing
- Flask URL routing
- Framework-specific conventions

## Module 57: URL Encoding in Forms

- Form submission encoding
- GET vs POST and URLs
- application/x-www-form-urlencoded
- multipart/form-data
- Form action attribute
- Method attribute implications
- File uploads and URLs
- Form encoding best practices

## Module 58: URL in Email Contexts

- URLs in email bodies
- Email client URL rendering
- Mailto URLs (mailto:)
- URL tracking in emails
- Link wrapping services
- Plain text vs HTML URLs
- Mobile email client handling
- Anti-phishing considerations

## Module 59: URL Obfuscation Techniques

- Base64 encoding URLs
- Hex encoding
- IP address obfuscation
- Unicode tricks
- URL shortening for obfuscation
- Detecting obfuscated URLs
- Security scanner evasion
- Ethical considerations

## Module 60: URL in Content Security Policy

- CSP source expressions
- Scheme matching in CSP
- Host matching in CSP
- Path matching in CSP
- Port matching in CSP
- Wildcard usage in CSP
- URL validation for CSP
- CSP and URL security

## Module 61: Same-Origin Policy and URLs

- Origin determination
- Scheme, host, port matching
- Cross-origin requests
- CORS and URLs
- Same-origin vs cross-origin
- Subdomain considerations
- Port differences
- Protocol differences

## Module 62: URL in Web Storage APIs

- URLs as storage keys
- IndexedDB and URLs
- LocalStorage key patterns
- SessionStorage URL handling
- Cache API URL matching
- Service Worker URL scope
- URL-based data retrieval
- Storage quota and URLs

## Module 63: URL in WebSockets

- ws:// and wss:// schemes
- WebSocket URL syntax
- Origin header
- WebSocket handshake URLs
- Path and query in WebSocket URLs
- WebSocket security
- URL routing for WebSockets
- WebSocket proxy URLs

## Module 64: URL in Server-Sent Events (SSE)

- EventSource URL
- SSE connection URLs
- Cross-origin SSE
- URL parameters for SSE
- SSE reconnection URLs
- Last-Event-ID handling
- SSE security
- SSE vs WebSocket URLs

## Module 65: URL in GraphQL

- GraphQL endpoint URLs
- Query parameters for GraphQL
- GET requests with GraphQL
- POST requests URL structure
- Persisted queries and URLs
- GraphQL over WebSocket URLs
- URL shortening for complex queries
- RESTful alternatives

## Module 66: URL in Web Scraping

- Scraping target URLs
- Pagination URL patterns
- Dynamic URL generation
- URL normalization for scraping
- robots.txt and URL filtering
- URL queuing strategies
- URL deduplication
- Rate limiting by domain

## Module 67: Sitemap URLs

- XML sitemap structure
- URL elements in sitemaps
- loc element requirements
- lastmod, changefreq, priority
- Sitemap index files
- URL encoding in sitemaps
- Sitemap URL limits (50,000 URLs)
- Sitemap submission URLs

## Module 68: robots.txt and URLs

- robots.txt URL location
- User-agent directives
- Disallow directive
- Allow directive
- URL pattern matching in robots.txt
- Crawl-delay directive
- Sitemap directive
- Wildcard usage

## Module 69: Open Graph and URL Metadata

- og:url property
- Canonical URL in Open Graph
- URL sharing on social media
- Facebook URL scraper
- Twitter Card URLs
- LinkedIn URL preview
- URL metadata caching
- Debugging URL previews

## Module 70: AMP (Accelerated Mobile Pages) URLs

- AMP URL structure
- /amp/ URL pattern
- google.com/amp/ proxy URLs
- Ampersand parameter
- AMP canonical URLs
- AMP to non-AMP linking
- AMP URL caching
- AMP deprecation and URLs

## Module 71: Progressive Web App URLs

- PWA scope
- Start URL in manifest
- Service Worker scope
- URL handling in PWAs
- Deep linking in PWAs
- Share Target API URLs
- Install prompt URLs
- PWA URL best practices

## Module 72: URL in Browser Extensions

- Extension URLs (chrome-extension://)
- Web accessible resources
- Content script URL matching
- Background page URLs
- Options page URLs
- Popup URLs
- Extension message passing with URLs
- Cross-extension URL communication

## Module 73: URL in Content Delivery Networks

- CDN URL structure
- Subdomain vs path-based CDN
- Query string versioning
- Cache busting with URLs
- CDN origin URLs
- Custom domain CNAMEs
- SSL/TLS and CDN URLs
- Geo-distributed URLs

## Module 74: URL Versioning Strategies

- Path-based versioning (/v1/, /v2/)
- Subdomain versioning (v1.api.example.com)
- Query parameter versioning (?version=1)
- Header-based vs URL versioning
- Deprecating old versions
- Version migration paths
- Semantic versioning in URLs
- Breaking changes and URLs

## Module 75: URL Accessibility

- Descriptive URL text
- Screen reader URL handling
- Keyboard navigation
- Focus management with URL changes
- Skip links and anchors
- ARIA and URL updates
- Single Page App URL accessibility
- Accessible URL patterns

## Module 76: URL Analytics and Tracking

- Page view tracking
- Event tracking URLs
- Campaign tracking
- Referrer URLs
- Click tracking
- Conversion tracking URLs
- A/B testing URLs
- Privacy-preserving tracking

## Module 77: URL in Search Engine Optimization

- URL structure and SEO
- Keyword-rich URLs
- URL depth and ranking
- Duplicate content via URLs
- 301 redirects for SEO
- URL parameters and SEO
- Dynamic vs static URLs
- Mobile-first URL considerations

## Module 78: URL Taxonomy and Information Architecture

- Category hierarchies in URLs
- Tag-based URL structures
- Faceted navigation URLs
- Breadcrumb URL correlation
- Site structure reflection
- URL scalability
- Future-proofing URL design
- Reorganization strategies

## Module 79: URL in E-commerce

- Product URLs
- Category URLs
- Search result URLs
- Filtering URLs
- Cart and checkout URLs
- Session handling in URLs
- Affiliate tracking URLs
- Product variation URLs

## Module 80: URL in Content Management Systems

- WordPress permalink structure
- Drupal URL aliases
- Joomla SEF URLs
- Custom URL patterns
- URL rewriting in CMS
- Multi-language URLs in CMS
- CMS migration URL mapping
- URL conflicts and resolution

## Module 81: URL Migration Strategies

- URL mapping
- 301 redirect planning
- Wildcard redirects
- Regular expression redirects
- Migration testing
- Monitoring 404 errors
- Updating internal links
- External link notifications

## Module 82: URL in Documentation

- Documentation URL structure
- Version-specific docs URLs
- Anchor links in documentation
- API reference URLs
- Code example URLs
- Search-friendly documentation URLs
- Internationalized documentation URLs
- Documentation generators and URLs

## Module 83: URL in Legal and Compliance

- Privacy policy URLs
- Terms of service URLs
- Cookie consent URLs
- GDPR compliance URLs
- CCPA Do Not Sell URLs
- Legal notice requirements
- Regulatory URL standards
- Compliance verification URLs

## Module 84: URL in Webhooks

- Webhook endpoint URLs
- Callback URLs
- Webhook security (signatures)
- Retry URLs
- Webhook payload URLs
- URL validation for webhooks
- Dynamic webhook URLs
- Webhook URL testing

## Module 85: URL in OAuth and Authentication

- Authorization URLs
- Redirect URIs
- Token endpoint URLs
- Callback URL validation
- State parameter in URLs
- PKCE and URLs
- OAuth scope URLs
- Single Sign-On URLs

## Module 86: URL in Microservices Architecture

- Service discovery URLs
- API gateway URLs
- Service mesh URLs
- Internal vs external URLs
- Service-to-service URLs
- Load balancer URLs
- Health check endpoint URLs
- Service registry URLs

## Module 87: URL Localization vs Internationalization

- Locale in URL (/en-US/)
- Language vs region codes
- Currency in URLs
- Date format implications
- Localized slug generation
- Fallback URL strategies
- Automatic locale detection
- User locale preference URLs

## Module 88: URL in Streaming Media

- HLS manifest URLs
- DASH manifest URLs
- Media segment URLs
- Adaptive bitrate URLs
- Live stream URLs
- VOD URLs
- DRM license URLs
- Subtitle/caption URLs

## Module 89: URL in Web Performance

- Critical resource URLs
- Preload hints with URLs
- Resource prioritization
- Connection management
- DNS prefetching URLs
- Preconnect URLs
- Prefetch URLs
- Render-blocking URLs

## Module 90: URL Anti-Patterns

- Session IDs in URLs
- Exposing internal paths
- Overly long URLs
- Special character abuse
- Cryptic parameter names
- Inconsistent casing
- Unnecessary nesting
- Index.html in URLs

## Module 91: URL Future Standards and Proposals

- Emerging URL standards
- Web Platform Incubator Community Group proposals
- IETF drafts
- Deprecation of old standards
- New URI schemes
- URL modernization efforts
- Security enhancements
- Performance improvements

## Module 92: URL Fingerprinting and Privacy

- URL-based tracking
- Tracking parameter identification
- URL history sniffing
- Browser fingerprinting via URLs
- Privacy-preserving URL handling
- URL parameter stripping (Brave, Firefox)
- Bounce tracking mitigation
- Privacy-focused URL practices

## Module 93: URL in Blockchain and Web3

- IPFS URLs (ipfs://)
- Ethereum Name Service (ENS)
- NFT metadata URLs
- Decentralized storage URLs
- Blockchain explorer URLs
- Smart contract URLs
- Web3 gateway URLs
- Distributed web URLs

## Module 94: URL Monitoring and Observability

- URL uptime monitoring
- Broken link detection
- URL change detection
- Performance monitoring by URL
- Error rate by endpoint
- URL access logging
- Alerting on URL issues
- Historical URL data

## Module 95: URL in Augmented and Virtual Reality

- AR content URLs
- VR experience URLs
- 3D model URLs
- Spatial web URLs
- WebXR URLs
- AR marker-based URLs
- Location-based AR URLs
- Immersive web standards

## Module 96: URL Governance and Policies

- URL ownership
- Subdomain allocation
- URL naming standards
- Approval workflows
- URL retirement policies
- Documentation requirements
- Change management
- URL lifecycle management

## Module 97: URL in Edge Computing

- Edge function URLs
- Regional endpoint URLs
- Cloudflare Workers URLs
- Vercel Edge Functions URLs
- AWS Lambda@Edge URLs
- URL routing at the edge
- Geographic URL distribution
- Edge caching and URLs

## Module 98: URL Testing Frameworks

- URL validation testing
- Integration test URLs
- End-to-end test URLs
- Mocking URL responses
- Test URL patterns
- Staging vs production URLs
- URL test fixtures
- Automated URL testing

## Module 99: URL Documentation Best Practices

- API documentation URLs
- OpenAPI/Swagger URLs
- URL pattern documentation
- Example URLs
- Parameter documentation
- Response URL documentation
- Changelog URLs
- Deprecation notices

## Module 100: URL Case Studies and Real-World Examples

- Large-scale URL migrations
- URL structure redesigns
- Performance optimizations
- Security incident responses
- International expansion URL strategies
- Platform consolidations
- Legacy system integration
- Industry-specific solutions

---

# Fundamentals

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

## Purpose and Use Cases

URIs serve as the fundamental addressing and identification mechanism for resources across networked systems and the internet. They provide a uniform, standardized syntax for naming and locating digital and abstract resources.

**Resource Identification:** URIs uniquely identify resources including web pages, documents, images, APIs, services, and abstract entities. This identification enables consistent referencing regardless of resource location or format.

**Web Navigation:** URLs enable browsers and clients to locate and retrieve web resources. They specify the protocol, domain, path, and parameters needed to access content over HTTP/HTTPS.

**API Endpoints:** RESTful APIs use URIs to identify resources and operations. Each endpoint represents a specific resource or collection, enabling structured access to services and data.

**Linking and Hypermedia:** URIs enable the hypertext architecture of the web. They allow documents to reference other resources, creating the interconnected web structure.

**Persistent Identification:** URNs provide location-independent identifiers for long-term resource identification. They're used in digital libraries, academic publishing, legal documents, and archival systems where stability matters more than access method.

**Bookmarking and Sharing:** URLs enable users to save, share, and return to specific resources. They serve as portable references that work across applications and platforms.

**Search Engine Indexing:** URIs provide stable addresses that search engines can index and rank. Well-structured URLs improve discoverability and SEO.

**Access Control and Authentication:** URIs identify protected resources in security systems. They specify what users are requesting access to.

**Key Points:**

- Universal addressing across internet and intranet systems
- Protocol-independent resource naming through URNs
- Machine-readable resource identification for automation
- Human-readable addresses for usability
- Hierarchical structure supporting organization and namespaces
- Fragment identifiers for addressing parts of resources

**Example:**

```
Web Pages:
https://example.com/products/shoes

API Endpoints:
https://api.example.com/v1/users/12345
https://api.example.com/v1/orders?status=pending

Email:
mailto:support@example.com?subject=Question

File Transfer:
ftp://ftp.example.com/pub/files/document.pdf

Persistent Identifiers:
urn:isbn:978-0-123456-78-9
urn:doi:10.1000/xyz123

Database Records:
jdbc:postgresql://localhost:5432/database

Telephone:
tel:+1-555-123-4567

Fragment References:
https://example.com/page.html#section-3
```

URIs enable interoperability between systems by providing a common language for resource addressing. They support the decentralized architecture of the web where any resource can reference any other resource without central coordination.

The flexibility of URI syntax accommodates new schemes as technology evolves, allowing the system to adapt to new protocols and resource types while maintaining backward compatibility with existing identifiers.

---

## Resource Identification Concept

A Uniform Resource Identifier (URI) is a string of characters that identifies a resource on the internet or within a system. Resources can be anything addressable: web pages, images, videos, API endpoints, files, or abstract concepts. The URI provides a standardized way to reference these resources regardless of their location or type.

The relationship between URIs, URLs, and URNs:

- **URI (Uniform Resource Identifier)**: The umbrella term for all types of names and addresses that refer to objects on the web
- **URL (Uniform Resource Locator)**: A subset of URI that specifies where a resource is located and how to retrieve it (includes access mechanism)
- **URN (Uniform Resource Name)**: A subset of URI that identifies a resource by name in a particular namespace, independent of location

URLs are the most commonly used form of URI in web contexts. Every URL is a URI, but not every URI is a URL. URNs persist even when the resource moves or becomes unavailable, while URLs point to specific locations.

## Web Addressing Basics

### URL Structure

A complete URL consists of several components that follow a standardized syntax:

```
scheme://username:password@host:port/path?query#fragment
```

**Scheme**: Defines the protocol for accessing the resource (http, https, ftp, mailto, file, data). The scheme is followed by a colon and usually two forward slashes. Different schemes have different rules for the remaining components.

**Authority Component** (optional, follows `//`):

- **Userinfo** (optional): Username and optionally password, separated by colon, followed by `@` symbol
- **Host**: Domain name (example.com) or IP address (192.168.1.1 or [2001:db8::1] for IPv6)
- **Port** (optional): Numeric value preceded by colon, indicates the network port for connection. Default ports are assumed when omitted (80 for HTTP, 443 for HTTPS)

**Path**: Hierarchical structure identifying the resource within the host, uses forward slashes as separators. Can be absolute (starting with /) or relative. An empty path is equivalent to a single forward slash.

**Query** (optional): Begins with `?`, contains key-value pairs typically formatted as `key=value`, separated by `&` or `;`. Used to pass parameters to the resource.

**Fragment** (optional): Begins with `#`, identifies a specific portion within the resource. Not sent to the server but processed by the client (browser).

### Character Encoding

URLs can only contain a limited set of ASCII characters. Characters outside this set must be percent-encoded using the format `%XX` where XX is the hexadecimal value of the character's byte in UTF-8.

Reserved characters that have special meaning in URLs:

```
: / ? # [ ] @ ! $ & ' ( ) * + , ; =
```

When these characters need to appear as data (not as delimiters), they must be percent-encoded. For example, a space becomes `%20` or `+` in query strings, and `#` becomes `%23`.

Unreserved characters (never need encoding):

```
A-Z a-z 0-9 - . _ ~
```

### URL Types

**Absolute URLs**: Contain all components needed to locate a resource from any context:

```
https://www.example.com:443/path/to/resource?key=value#section
```

**Relative URLs**: Defined in relation to a base URL, lacking scheme and often authority:

```
/path/to/resource          (absolute path, relative to host)
resource                   (relative to current directory)
../resource                (relative to parent directory)
?key=value                 (relative to current path, new query)
#section                   (relative to current URL, new fragment)
```

**Protocol-Relative URLs**: Omit the scheme, inheriting it from the current page:

```
//example.com/resource
```

### Common URL Schemes

**http/https**: Web resources using Hypertext Transfer Protocol (Secure)

```
https://example.com/page.html
```

**ftp**: File Transfer Protocol resources

```
ftp://ftp.example.com/files/document.pdf
```

**mailto**: Email addresses

```
mailto:user@example.com?subject=Hello&body=Message
```

**file**: Local file system resources

```
file:///C:/Users/Documents/file.txt
```

**data**: Inline data embedded directly in the URL

```
data:text/html,<h1>Hello</h1>
data:image/png;base64,iVBORw0KG...
```

**tel**: Telephone numbers

```
tel:+1-234-567-8900
```

**javascript**: JavaScript code to execute

```
javascript:void(0)
javascript:alert('Hello')
```

## Importance in Web Architecture

### Universal Resource Identification

URLs provide a universal naming system that enables consistent resource identification across different systems, platforms, and contexts. This universality is fundamental to the web's distributed architecture, allowing any client to reference any resource regardless of geographic or technological boundaries.

Without standardized URLs, each system would require its own addressing scheme, preventing interoperability and making the global web impossible.

### Linking and Navigation

URLs enable hypertext linking, the defining characteristic of the World Wide Web. Each hyperlink uses a URL to reference its target, creating the web's interconnected structure. This linking capability allows:

- Navigation between resources
- Citation and reference mechanisms
- Relationship establishment between content
- Discovery of related information

### Resource Location and Access

URLs specify both the location of resources and the protocol for accessing them. This dual function allows clients to:

- Determine where a resource resides
- Understand how to request the resource
- Apply appropriate security and authentication
- Cache and optimize resource retrieval

### API and Service Integration

Modern web applications rely on URLs for API endpoints and service integration. RESTful APIs use URL structure to represent resource hierarchies and actions:

```
https://api.example.com/v1/users/123
https://api.example.com/v1/users/123/orders
```

URL design in APIs affects discoverability, usability, and semantic meaning.

### Bookmarking and Sharing

URLs enable users to bookmark, share, and return to specific resources. Persistent URLs (permalinks) ensure long-term accessibility and citation reliability, which is critical for:

- Academic and professional references
- Social media sharing
- Search engine indexing
- Digital preservation

### Security and Trust

URL structure provides security indicators and trust signals. The HTTPS scheme signals encrypted transmission, domain names establish ownership and authority, and URL inspection helps users identify phishing attempts and malicious sites.

### Internationalization

URL standards have evolved to support international characters through Internationalized Domain Names (IDN) and Internationalized Resource Identifiers (IRI), making the web accessible to non-English speakers while maintaining backward compatibility.

## Standards Organizations

### IETF (Internet Engineering Task Force)

The IETF is the premier internet standards organization responsible for developing and maintaining core URL and URI specifications. It operates through an open, volunteer-driven process where anyone can contribute to standards development.

**Key URI/URL RFCs**:

- **RFC 3986** (2005): Uniform Resource Identifier (URI): Generic Syntax - The current foundational standard defining URI syntax and semantics
- **RFC 3987** (2005): Internationalized Resource Identifiers (IRIs) - Extends URIs to support Unicode characters
- **RFC 6874** (2013): IPv6 Zone ID representation in URI addresses
- **RFC 7230-7235** (2014): HTTP/1.1 specifications including URI usage in HTTP
- **RFC 8820** (2020): URI Design and Ownership

**Obsoleted RFCs** (historical context):

- **RFC 1738** (1994): Original URL specification
- **RFC 2396** (1998): Previous URI generic syntax
- **RFC 2732** (1999): IPv6 literal addresses in URLs

The IETF working process involves:

1. Internet-Drafts (I-D): Preliminary proposals, valid for 6 months
2. Working Group review and discussion
3. IETF Last Call for community feedback
4. IESG (Internet Engineering Steering Group) evaluation
5. RFC publication with standards track designation

IETF standards have different maturity levels:

- **Proposed Standard**: Initial specification, requires implementation experience
- **Internet Standard**: Proven through deployment and interoperability testing
- **Best Current Practice**: Recommended procedures
- **Informational**: General information, not standards track

### WHATWG (Web Hypertext Application Technology Working Group)

WHATWG is a community-driven organization focused on evolving web standards through a living standard model rather than versioned specifications. Founded in 2004 by individuals from Apple, Mozilla, and Opera in response to W3C's direction with XHTML.

**URL Living Standard**:

WHATWG maintains the URL Living Standard (https://url.spec.whatwg.org/), which differs from IETF RFCs by:

- Continuously updating rather than versioned releases
- Focusing on parsing algorithms and implementation details
- Emphasizing browser interoperability
- Including error handling for malformed URLs
- Defining exactly how browsers should process URLs in practice

The WHATWG URL specification provides:

- Precise parsing algorithms that implementations can follow
- Definition of the URL and URLSearchParams JavaScript APIs
- Handling of edge cases and legacy formats
- Compatibility with existing web content
- Alignment with actual browser behavior

**Living Standard Philosophy**:

WHATWG's approach contrasts with traditional standards:

- Standards evolve continuously through commits and pull requests
- Changes require implementation and testing in browsers
- No fixed versions; references point to the living document
- Emphasis on "rough consensus and running code"
- Regular coordination between browser vendors

**Key Contributions**:

- URL parsing algorithm that handles real-world malformed URLs
- URLSearchParams API for query string manipulation
- Blob URLs specification
- Integration with other WHATWG standards (HTML, Fetch, Streams)

### W3C (World Wide Web Consortium)

While W3C primarily focuses on web content and application standards, it coordinates with IETF and WHATWG on URI-related specifications. W3C's role includes:

- Ensuring URI standards integrate properly with HTML, CSS, and DOM specifications
- Developing IRI specifications for internationalized web content
- Creating best practices for URI design and persistence
- Coordinating namespace URIs for XML and RDF vocabularies

**Relevant W3C Specifications**:

- Character Model for the World Wide Web
- Architecture of the World Wide Web, Volume One (incorporating URI principles)
- Cool URIs best practices
- XML namespace URIs

### IANA (Internet Assigned Numbers Authority)

IANA, operated by ICANN, maintains official registries that support URI standards:

**URI Scheme Registry**: Lists all registered URI schemes (http, https, ftp, mailto, etc.) with their specifications and responsible parties. Anyone can propose new schemes through the IETF process.

**Port Number Registry**: Assigns standard port numbers for protocols, which affects default URL behavior.

**Media Type Registry**: Defines MIME types used in data URLs and content negotiation.

### Coordination Between Organizations

These organizations coordinate to prevent conflicting standards:

- IETF provides foundational URI syntax and semantics
- WHATWG defines practical parsing and browser APIs
- W3C ensures integration with web technologies
- IANA maintains registries that enable implementation

Browser vendors (Google, Mozilla, Apple, Microsoft) participate in all relevant organizations, ensuring standards align with implementation reality. The HTML5 standardization process demonstrated how WHATWG and W3C can coordinate, eventually leading to W3C adopting WHATWG's HTML Living Standard.

**Standards Adoption Process**:

For URLs specifically:

1. IETF RFC 3986 defines the theoretical syntax
2. WHATWG URL Standard defines practical parsing
3. Browsers implement WHATWG specification
4. IANA maintains scheme and related registries
5. W3C ensures compatibility with web platform

This multi-organizational approach balances theoretical rigor with practical implementation needs, though it can sometimes create confusion about which standard to follow. [Inference: In practice, modern web development follows WHATWG standards for URL handling in browsers while respecting IETF RFCs for protocol-level implementations and non-browser contexts.]

---

# URI (Uniform Resource Identifier) - RFC 3986

The Uniform Resource Identifier (URI) is a fundamental internet standard defined in RFC 3986, published in January 2005 by the Internet Engineering Task Force (IETF). URIs provide a compact sequence of characters that identifies an abstract or physical resource on the internet or other networks.

## RFC 3986 Specification Overview

RFC 3986 supersedes previous specifications including RFC 1738, RFC 1808, and RFC 2396. The specification establishes a uniform syntax for identifying resources while allowing for extensibility and the definition of new schemes. The document distinguishes between URIs that locate resources (URLs) and those that name resources (URNs), though both follow the same syntactic conventions.

The specification addresses:

- Syntax requirements for URI construction
- Resolution of relative references
- Comparison and normalization procedures
- Security considerations for URI usage
- Registration procedures for URI schemes

## URI Syntax Components

A URI consists of several hierarchical components that provide the information necessary to identify a resource:

**Scheme**: Identifies the protocol or naming authority. The scheme component is mandatory and must begin with a letter, followed by any combination of letters, digits, plus (+), period (.), or hyphen (-). The scheme is case-insensitive and is separated from the remainder of the URI by a colon (:).

**Authority**: Contains information about the naming authority responsible for the namespace. The authority component begins with a double slash (//) and may include:

- Userinfo: Optional username and password (deprecated for security reasons)
- Host: Domain name or IP address
- Port: Optional network port number

**Path**: Identifies the specific resource within the scope of the authority. The path component consists of a sequence of segments separated by forward slashes (/). The path may be empty, absolute (beginning with /), or relative.

**Query**: Contains non-hierarchical data that identifies the resource in conjunction with the path. The query component is indicated by a question mark (?) and typically consists of key-value pairs.

**Fragment**: Provides direction to a secondary resource or a specific portion of the primary resource. The fragment component is indicated by a hash symbol (#) and is processed by the client after retrieval.

## Generic URI Syntax

The complete generic URI syntax follows this structure:

```
scheme:[//authority]path[?query][#fragment]
```

Where the authority component expands to:

```
[userinfo@]host[:port]
```

**Key Points:**

- Square brackets indicate optional components
- The scheme and path are the only required components
- Components must appear in the specified order
- The authority component, when present, is preceded by //

Examples of URI structure variations:

```
http://www.example.com/path/to/resource?key=value#section
ftp://user:password@ftp.example.com:21/file.txt
mailto:user@example.com
urn:isbn:0-486-27557-4
file:///C:/Users/Documents/file.txt
```

The specification defines reserved characters that have special meaning within URI components:

**General delimiters**: : / ? # [ ] @ **Sub-delimiters**: ! $ & ' ( ) * + , ; =

Reserved characters must be percent-encoded when used for purposes other than their reserved function.

## URI Character Encoding

URI character encoding ensures that URIs remain compatible with systems that may have limited character set support. The specification uses percent-encoding (also called URL encoding) to represent characters that are not allowed in their literal form.

**Percent-Encoding Mechanism**: Characters are represented as a percent sign (%) followed by two hexadecimal digits representing the character's byte value in UTF-8 encoding. For example:

- Space character: %20
- Forward slash (when literal): %2F
- Percent sign (when literal): %25

**Unreserved Characters**: These characters do not require encoding and should not be percent-encoded:

- Uppercase and lowercase letters: A-Z, a-z
- Decimal digits: 0-9
- Hyphen: -
- Period: .
- Underscore: _
- Tilde: ~

**Reserved Characters**: Characters with special syntactic meaning in URIs. They must be percent-encoded when used in a literal capacity:

- Reserved for general delimiters: : / ? # [ ] @
- Reserved as sub-delimiters: ! $ & ' ( ) * + , ; =

**Normalization Considerations**:

Character encoding normalization involves several processes:

**Case Normalization**: The scheme and host components are case-insensitive and should be normalized to lowercase. Percent-encoding triplets (the hexadecimal digits) should be normalized to uppercase.

**Percent-Encoding Normalization**: Unreserved characters that are percent-encoded should be decoded. For example, %7E should be normalized to ~.

**Path Segment Normalization**: Removal of dot-segments (. and ..) from the path component according to specified algorithms.

**International Characters**: Non-ASCII characters must be converted to UTF-8, then percent-encoded. For example, the character "ü" (U+00FC) in UTF-8 is encoded as %C3%BC.

```
Original: http://example.com/ümlaut
Encoded:  http://example.com/%C3%BCmlaut
```

**Security and Privacy Implications**:

Character encoding affects security in several ways:

- Improper decoding can lead to security vulnerabilities
- Multiple encodings of the same character may bypass security filters
- Sensitive information in userinfo components is visible in plain text
- Fragment identifiers are not sent to servers but are processed by clients

The specification recommends against including sensitive information in URIs and encourages the use of HTTPS for protection during transmission.

**Implementation Requirements**:

Systems implementing URI processing must:

- Accept percent-encoded octets for characters even when the unencoded character would be valid
- Produce normalized URIs when generating new URIs
- Preserve character encoding in components where it affects resource identification
- Handle internationalized domain names according to relevant standards (Punycode/IDNA)

The character encoding rules ensure interoperability across diverse systems while maintaining the ability to represent resources with complex naming schemes. Proper encoding prevents parsing errors, security vulnerabilities, and ensures consistent resource identification across different platforms and applications.

---

## Reserved vs Unreserved Characters

### Unreserved Characters

These characters never need to be percent-encoded and have no special meaning:

- Alphanumeric: `A-Z`, `a-z`, `0-9`
- Special characters: `-`, `.`, `_`, `~`

### Reserved Characters

These characters have special meaning in URIs and must be percent-encoded when used literally:

**General Delimiters:**

- `:` (colon)
- `/` (slash)
- `?` (question mark)
- `#` (hash/fragment identifier)
- `[` and `]` (brackets)
- `@` (at sign)

**Sub-Delimiters:**

- `!` (exclamation mark)
- `$` (dollar sign)
- `&` (ampersand)
- `'` (apostrophe)
- `(` and `)` (parentheses)
- `*` (asterisk)
- `+` (plus sign)
- `,` (comma)
- `;` (semicolon)
- `=` (equals sign)

**Example:** To include a literal `?` in a path segment:

```
https://example.com/what%3Fis%3Fthis  // Correct
https://example.com/what?is?this      // Incorrect - creates query string
```

## Percent-Encoding

Characters outside the unreserved set should be percent-encoded as `%HH` where HH is the hexadecimal representation of the character's byte value.

**Example:**

- Space: → `%20`
- Exclamation: `!` → `%21` (when used literally)
- UTF-8 character 'ñ': `%C3%B1`

## URI Normalization

Normalization is the process of converting URIs to a canonical form for comparison purposes. RFC 3986 defines several normalization techniques:

### Case Normalization

- **Scheme and host**: Case-insensitive, should be normalized to lowercase
- **Path**: Case-sensitive in most schemes

**Example:**

```
HTTP://Example.COM/Path  →  http://example.com/Path
```

### Percent-Encoding Normalization

- Decode unreserved characters that are percent-encoded
- Uppercase hexadecimal digits in percent-encoding

**Example:**

```
http://example.com/%7Euser  →  http://example.com/~user
http://example.com/%2d      →  http://example.com/-
http://example.com/%2a      →  http://example.com/%2A
```

### Path Segment Normalization

- Remove dot-segments (`.` and `..`)
- Remove empty path segments

**Example:**

```
http://example.com/a/b/../c/./d  →  http://example.com/a/c/d
http://example.com//path         →  http://example.com/path
```

### Default Port Removal

Remove default ports for common schemes:

- HTTP: port 80
- HTTPS: port 443
- FTP: port 21

**Example:**

```
http://example.com:80/path  →  http://example.com/path
https://example.com:443/    →  https://example.com/
```

### Empty Path Normalization

An empty path should be normalized to `/` for HTTP(S) URIs.

**Example:**

```
http://example.com  →  http://example.com/
```

## URI Comparison Rules

RFC 3986 defines several levels of URI comparison:

### Simple String Comparison

Direct byte-by-byte comparison. Fast but may produce false negatives for equivalent URIs.

```
http://example.com/path ≠ http://example.com/Path  // Different case
```

### Syntax-Based Normalization

Apply normalization rules before comparison:

1. Case normalization
2. Percent-encoding normalization
3. Path segment normalization
4. Default port removal

**Example:**

```
HTTP://Example.com:80/%7Euser/./data
http://example.com/~user/data
// These are equivalent after normalization
```

### Scheme-Based Normalization

Apply scheme-specific rules (e.g., HTTP path segments are case-sensitive).

### Protocol-Based Normalization

Consider semantic equivalence based on protocol behavior [Inference - requires protocol-specific knowledge].

## Hierarchical vs Non-Hierarchical URIs

### Hierarchical URIs

Use the `//` authority indicator and organize resources in a hierarchy:

```
scheme://authority/path?query#fragment
```

**Example:**

```
http://example.com/dir/subdir/file.html
ftp://ftp.example.org/pub/documents/
```

**Key characteristics:**

- Have authority component
- Use `/` for path hierarchy
- Support relative references
- Path segments represent hierarchical relationships

### Non-Hierarchical (Opaque) URIs

Do not use the `//` authority format and treat the resource as a flat namespace:

```
scheme:path?query#fragment
```

**Example:**

```
mailto:user@example.com
urn:isbn:0-486-27557-4
tel:+1-555-0123
data:text/plain;base64,SGVsbG8gV29ybGQ=
```

**Key characteristics:**

- No authority component
- No path hierarchy interpretation
- Scheme-specific structure
- Cannot be used as base for relative references

### Distinguishing Between Types

The presence or absence of `//` after the scheme determines the type:

```
http://example.com/   // Hierarchical
mailto:user@host      // Non-hierarchical
```

## Relative References

Hierarchical URIs support relative references, which are resolved against a base URI:

**Base URI:**

```
http://example.com/dir/file.html
```

**Relative references:**

```
subdir/page.html              →  http://example.com/dir/subdir/page.html
/absolute/path.html           →  http://example.com/absolute/path.html
//other.example.com/resource  →  http://other.example.com/resource
?query=new                    →  http://example.com/dir/file.html?query=new
#fragment                     →  http://example.com/dir/file.html#fragment
```

## URI vs URL vs URN

- **URI (Uniform Resource Identifier)**: Generic term for all identifiers
- **URL (Uniform Resource Locator)**: URIs that provide access methods (http, ftp, etc.)
- **URN (Uniform Resource Name)**: URIs that name resources without implying location

**Example:**

```
http://example.com/doc.pdf    // URL (and URI)
urn:isbn:0-123-45678-9        // URN (and URI)
```

## Common URI Schemes

Different schemes have different syntax and semantics:

- **http/https**: Web resources
- **ftp**: File transfer
- **mailto**: Email addresses
- **file**: Local file system
- **data**: Inline data
- **tel**: Telephone numbers
- **urn**: Persistent identifiers
- **ws/wss**: WebSocket connections

## Security Considerations

### Homograph Attacks

Internationalized domain names can use visually similar characters:

```
http://example.com     // Legitimate
http://еxamplе.com     // Uses Cyrillic 'е' characters
```

### Open Redirects

Improperly validated URIs can enable phishing:

```
http://trusted.com/redirect?url=http://malicious.com
```

### Path Traversal

Improper normalization can expose unintended resources:

```
http://example.com/files/../../../etc/passwd
```

**Key Points:**

- Always normalize URIs before security-sensitive operations
- Validate scheme, authority, and path components
- Be cautious with user-supplied URI components
- Consider canonicalization before comparison
- Implement proper percent-encoding/decoding

## Practical Implementation Guidelines

When working with URIs in applications:

1. **Parsing**: Use RFC 3986-compliant libraries rather than regex
2. **Construction**: Build URIs programmatically to ensure proper encoding
3. **Comparison**: Apply appropriate normalization before comparing
4. **Storage**: Store normalized forms for consistency
5. **Display**: Consider security implications of displaying URIs to users
6. **Validation**: Validate all components according to scheme-specific rules

**Example** (conceptual):

```
// Parsing
uri = parseURI("http://example.com/path?key=value")

// Construction
uri = buildURI({
  scheme: "https",
  host: "example.com",
  path: "/my path",  // Library handles encoding
  query: {key: "value with spaces"}
})

// Normalization
normalizedURI = normalize(uri)

// Comparison
if (compareURIs(uri1, uri2)) { ... }
```

---

# URL and URI Standards (WHATWG Living Standard)

URLs (Uniform Resource Locators) and URIs (Uniform Resource Identifiers) are fundamental web technologies governed by multiple standards that have evolved over decades. Understanding these standards is critical for web developers, protocol designers, and anyone working with web resources.

## Historical Context and Standard Evolution

The specification of URLs and URIs has undergone significant evolution since the early days of the web. The Internet Engineering Task Force (IETF) established the foundational standards through a series of RFCs (Request for Comments), while the Web Hypertext Application Technology Working Group (WHATWG) later developed a parallel standard focused on browser implementation reality.

**Key Points:**

- RFC 1738 (1994) defined the original URL syntax
- RFC 2396 (1998) introduced the URI concept, generalizing URLs and URNs
- RFC 3986 (2005) replaced RFC 2396 with comprehensive URI syntax
- WHATWG URL Standard emerged to document actual browser behavior
- The two standards coexist but serve different purposes

## RFC 3986: URI Generic Syntax

RFC 3986 represents the IETF's authoritative specification for URI syntax. This standard provides a rigorous, formal grammar for constructing and parsing URIs.

### URI Components Structure

The generic URI syntax follows this pattern:

```
URI = scheme:[//authority]path[?query][#fragment]
authority = [userinfo@]host[:port]
```

### Scheme Component

The scheme defines the protocol or namespace being used. It must begin with a letter and contain only letters, digits, plus (+), period (.), or hyphen (-).

**Example:**

```
http:
https:
ftp:
mailto:
file:
data:
```

### Authority Component

The authority component identifies the governing namespace and typically contains the host, optional port, and optional user information.

**Host formats:**

- DNS names: `example.com`, `subdomain.example.org`
- IPv4 addresses: `192.168.1.1`
- IPv6 addresses: `[2001:db8::1]`
- Registered names: any sequence of allowed characters

**Port specification:**

```
http://example.com:8080/path
```

**User information** (deprecated for security reasons):

```
ftp://user:password@ftp.example.com/file.txt
```

### Path Component

The path identifies a resource within the scope of the authority. It consists of segments separated by forward slashes.

**Path types:**

- Absolute path: begins with `/`
- Relative path: does not begin with `/`
- Empty path: valid in some schemes

**Example:**

```
/catalog/products/item123
/docs/api/v2/reference.html
```

### Query Component

The query component provides non-hierarchical data, typically key-value pairs. It begins with a question mark (?).

**Example:**

```
?category=electronics&sort=price&order=asc
?q=search+term&page=2
```

### Fragment Component

The fragment identifies a secondary resource or a portion of the primary resource. It begins with a hash (#) and is not sent to the server.

**Example:**

```
#section-3
#introduction
```

### Percent-Encoding

RFC 3986 defines percent-encoding (URL encoding) for representing characters outside the allowed set. Characters are encoded as `%` followed by two hexadecimal digits.

**Reserved characters:**

```
: / ? # [ ] @ ! $ & ' ( ) * + , ; =
```

**Unreserved characters** (no encoding needed):

```
A-Z a-z 0-9 - . _ ~
```

**Example:**

```
Original: /search?q=hello world
Encoded:  /search?q=hello%20world

Original: /user@email/profile
Encoded:  /user%40email/profile
```

### URI Normalization

RFC 3986 defines several normalization techniques to determine URI equivalence:

**Syntax-based normalization:**

- Case normalization for scheme and host
- Percent-encoding normalization
- Path segment normalization (removing `.` and `..`)

**Example:**

```
http://example.com:80/a/b/../c/./d
Normalized: http://example.com/a/c/d
```

### Relative References

RFC 3986 provides algorithms for resolving relative references against a base URI.

**Relative reference types:**

- Network-path reference: `//example.com/path`
- Absolute-path reference: `/path/to/resource`
- Relative-path reference: `../other/resource`
- Empty reference: references the base URI
- Fragment-only reference: `#fragment`

**Resolution example:**

```
Base: http://example.com/a/b/c
Relative: ../d/e
Result: http://example.com/a/d/e
```

## WHATWG URL Standard

The WHATWG URL Standard is a living standard that defines URL parsing and manipulation as actually implemented in web browsers. Unlike RFC 3986, which provides formal grammar, the WHATWG standard provides detailed algorithms and error handling procedures.

### Living Standard Concept

A living standard is continuously updated without version numbers. Changes are made incrementally based on implementation feedback, bug reports, and new requirements. This approach allows the standard to evolve with the web platform while maintaining implementation consensus.

**Characteristics:**

- No version numbers or dated snapshots
- Continuous integration of improvements
- Alignment with actual browser implementations
- Detailed parsing algorithms with defined error handling
- Comprehensive test suites

### Differences from RFC 3986

The WHATWG URL Standard diverges from RFC 3986 in several significant ways:

**Parsing algorithm specificity:** The WHATWG standard provides character-by-character parsing algorithms with explicit state machines, while RFC 3986 provides BNF grammar.

**Error handling:** [Inference] WHATWG defines specific behavior for invalid input (often attempting recovery), while RFC 3986 typically treats such input as malformed without specifying recovery mechanisms.

**Host parsing:** WHATWG includes detailed algorithms for parsing domain names, IPv4, and IPv6 addresses, with specific error conditions. RFC 3986 provides syntax but less algorithmic detail.

**Percent-encoding differences:** The sets of characters requiring percent-encoding differ between the standards in certain contexts.

**Special schemes:** WHATWG defines "special schemes" (http, https, file, ftp, ws, wss) with scheme-specific parsing rules. RFC 3986 treats most schemes uniformly.

**Example of divergence:**

```
Input: http://example.com/path with spaces

RFC 3986: Invalid (spaces not allowed)
WHATWG: Likely percent-encodes spaces during parsing
```

**File URLs:** WHATWG provides extensive specifications for file: URLs, including Windows path handling and UNC paths. RFC 3986 offers minimal guidance for file: URLs.

**Setter behavior:** WHATWG specifies how URL properties can be individually modified, defining side effects and validation for each component.

### URL API

The WHATWG standard defines a JavaScript API for URL manipulation available in browsers and Node.js.

**Constructor:**

```javascript
new URL(url [, base])
```

**Example:**

```javascript
const url = new URL('https://example.com/path?query=value#fragment');

// Properties
console.log(url.protocol);  // "https:"
console.log(url.hostname);  // "example.com"
console.log(url.pathname);  // "/path"
console.log(url.search);    // "?query=value"
console.log(url.hash);      // "#fragment"

// Modification
url.pathname = '/new-path';
url.searchParams.set('page', '2');

// Result: https://example.com/new-path?query=value&page=2#fragment
```

**URLSearchParams API:**

```javascript
const params = new URLSearchParams('key1=value1&key2=value2');

params.append('key3', 'value3');
params.get('key1');        // "value1"
params.has('key2');        // true
params.delete('key2');
params.toString();         // "key1=value1&key3=value3"

// Iteration
for (const [key, value] of params) {
  console.log(key, value);
}
```

### Browser Implementation Alignment

The WHATWG URL Standard achieves high implementation alignment across major browsers through several mechanisms:

**Specification clarity:** Detailed algorithms eliminate ambiguity in interpretation.

**Test suites:** Comprehensive web-platform-tests ensure consistent behavior across implementations.

**Implementation feedback:** Browser vendors actively contribute to standard development, ensuring specifications are implementable.

**Interoperability focus:** The standard prioritizes interoperability over theoretical purity, making pragmatic decisions based on deployed content.

**Example of alignment:** Modern browsers consistently handle these cases according to WHATWG:

```javascript
new URL('HTTP://EXAMPLE.COM').hostname  // "example.com" (lowercased)
new URL('http://example.com:80').port   // "" (default port omitted)
new URL('//example.com', 'http://base.com').href  // "http://example.com/"
```

### Special URL Schemes

WHATWG defines special handling for certain schemes:

**Special schemes list:**

- `http:` - default port 80
- `https:` - default port 443
- `ws:` - default port 80
- `wss:` - default port 443
- `ftp:` - default port 21
- `file:` - local file access

**Special scheme behaviors:**

- Cannot have empty host (except file:)
- Use specific parsing rules
- Have default ports that are omitted when set
- Subject to additional validation

**Example:**

```javascript
// Special scheme - requires host
new URL('http:///path');  // Throws TypeError

// Non-special scheme - host optional
new URL('custom:///path');  // Valid
```

### URL Parsing State Machine

The WHATWG standard defines a detailed state machine for URL parsing with numerous states:

**Major states include:**

- Scheme start state
- Scheme state
- No scheme state
- Special relative or authority state
- Authority state
- Host state
- Port state
- Path start state
- Path state
- Query state
- Fragment state

Each state defines specific transitions based on the current character and context.

### Domain Name Processing

WHATWG specifies detailed domain name processing including:

**ASCII domain handling:**

- Lowercasing
- Forbidden domain code points
- Validation rules

**Internationalized Domain Names (IDN):**

- Conversion to ASCII using Unicode IDNA algorithm
- Punycode encoding
- Validation of domain labels

**Example:**

```javascript
new URL('http://münchen.de').hostname  // "xn--mnchen-3ya.de"
```

### URL Equivalence

WHATWG defines URL equivalence based on serialization:

Two URLs are equivalent if their serialized forms are identical after parsing.

**Example:**

```javascript
const url1 = new URL('HTTP://EXAMPLE.COM:80/Path');
const url2 = new URL('http://example.com/Path');

url1.href === url2.href  // true (both serialize to lowercase, port 80 omitted)
```

## Practical Applications

### Web Development

**Link construction:**

```javascript
function buildProductURL(baseURL, productId, filters) {
  const url = new URL(`/products/${productId}`, baseURL);
  Object.entries(filters).forEach(([key, value]) => {
    url.searchParams.set(key, value);
  });
  return url.href;
}

// Usage
buildProductURL('https://shop.example.com', '12345', {
  color: 'blue',
  size: 'large'
});
// Result: https://shop.example.com/products/12345?color=blue&size=large
```

**URL manipulation:**

```javascript
function addTrackingParams(urlString, campaign) {
  const url = new URL(urlString);
  url.searchParams.set('utm_source', campaign.source);
  url.searchParams.set('utm_medium', campaign.medium);
  url.searchParams.set('utm_campaign', campaign.name);
  return url.href;
}
```

### Security Considerations

**URL validation for open redirects:**

```javascript
function isSafeRedirect(redirectURL, allowedHosts) {
  try {
    const url = new URL(redirectURL, window.location.origin);
    return allowedHosts.includes(url.hostname);
  } catch {
    return false;
  }
}
```

**Sanitizing user input:**

```javascript
function sanitizeURL(userInput) {
  try {
    const url = new URL(userInput);
    // Only allow http and https
    if (!['http:', 'https:'].includes(url.protocol)) {
      throw new Error('Invalid protocol');
    }
    return url.href;
  } catch {
    throw new Error('Invalid URL');
  }
}
```

### Server-Side Processing

**Request routing:**

```javascript
// Node.js example
const { URL } = require('url');

function routeRequest(request) {
  const url = new URL(request.url, `http://${request.headers.host}`);
  
  // Extract components for routing
  const path = url.pathname;
  const queryParams = Object.fromEntries(url.searchParams);
  
  return { path, queryParams };
}
```

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

## URI Schemes Beyond HTTP

### Common Schemes

**mailto:** Email addresses

```
mailto:user@example.com?subject=Hello&body=Message%20text
```

**tel:** Telephone numbers

```
tel:+1-555-123-4567
```

**data:** Inline data

```
data:text/plain;base64,SGVsbG8sIFdvcmxkIQ==
```

**Custom schemes:** Applications can register custom schemes for deep linking

```
myapp://action/param1/param2
```

### IRI (Internationalized Resource Identifiers)

RFC 3987 extends URIs to support Unicode characters directly without percent-encoding.

**Example:**

```
IRI: http://例え.jp/引き/
URI: http://xn--r8jz45g.jp/%E5%BC%95%E3%81%8D/
```

## Testing and Validation

### URL Parsing Tests

**Test cases should cover:**

- Valid URLs with all components
- Missing components
- Invalid characters
- Percent-encoding edge cases
- Scheme-specific rules
- Relative URL resolution
- Internationalized domain names
- IPv6 addresses

**Example test structure:**

```javascript
describe('URL parsing', () => {
  test('parses complete URL', () => {
    const url = new URL('https://user:pass@example.com:8080/path?q=1#frag');
    expect(url.protocol).toBe('https:');
    expect(url.username).toBe('user');
    expect(url.password).toBe('pass');
    expect(url.hostname).toBe('example.com');
    expect(url.port).toBe('8080');
    expect(url.pathname).toBe('/path');
    expect(url.search).toBe('?q=1');
    expect(url.hash).toBe('#frag');
  });
  
  test('handles relative URL', () => {
    const url = new URL('../other', 'https://example.com/path/file');
    expect(url.href).toBe('https://example.com/other');
  });
});
```

### Validation Libraries

**Popular validation libraries:**

- `validator.js` for JavaScript/Node.js
- URI parser libraries in various languages
- Regular expression approaches (limited, not recommended for full parsing)

**Note:** [Unverified] Regular expressions alone cannot fully validate URLs according to either standard due to context-dependent parsing rules.

## Performance Considerations

### URL Parsing Overhead

URL parsing involves multiple steps:

- Character encoding detection
- State machine execution
- Host parsing and validation
- Percent-encoding/decoding
- Normalization

**[Inference] Optimization strategies:**

- Cache parsed URL objects when possible
- Avoid reparsing the same URLs repeatedly
- Use relative URL resolution when appropriate
- Consider lazy parsing of URL components

### Memory Usage

**URL objects contain:**

- Original input string
- Parsed components
- Internal representation for manipulation

**Best practices:**

- Don't create URL objects unnecessarily
- Reuse URL objects when modifying multiple times
- Consider string operations for simple cases

## Future Directions

### Ongoing Standardization Work

**Current focus areas:**

- Improved file: URL handling across platforms
- Enhanced security features
- Better error reporting and validation
- Performance optimizations in specifications

### Emerging Patterns

**Protocol handlers:** Browsers increasingly support custom protocol handlers for web applications.

**Service Worker integration:** URL manipulation in service workers for request interception and routing.

**WebAssembly:** URL processing in WebAssembly for performance-critical applications.

**Note:** [Unverified] Specific future features are subject to working group decisions and implementation feedback.

---

## Understanding URLs and URIs

A URI (Uniform Resource Identifier) is the broader concept that encompasses both URLs (Uniform Resource Locators) and URNs (Uniform Resource Names). A URL specifically identifies a resource by describing its location and access mechanism, while a URN identifies a resource by name in a particular namespace without implying location.

The generic URI syntax follows this pattern: `scheme:[//authority]path[?query][#fragment]`

The authority component can be further broken down into: `[userinfo@]host[:port]`

**Key Points:**

- URLs are a subset of URIs that specify location and access method
- URNs identify resources by name without location information
- The distinction between URL and URI has become less emphasized in modern specifications
- Most web addresses encountered are technically URLs

## RFC 3986: URI Generic Syntax

RFC 3986, published in 2005, is the foundational standard for URI syntax. It obsoleted RFC 2396 and provides comprehensive rules for URI structure and parsing.

### Scheme Component

The scheme defines the protocol or namespace for the URI. It must begin with a letter and can contain letters, digits, plus (+), period (.), or hyphen (-). The scheme is case-insensitive but conventionally written in lowercase.

Common schemes include http, https, ftp, mailto, file, data, and tel.

### Authority Component

The authority component identifies the governing entity for the resource's namespace. It consists of optional user information, a host (domain name or IP address), and optional port number.

User information is deprecated for security reasons in most modern contexts. The host can be a registered domain name, IPv4 address, or IPv6 address enclosed in brackets. The port number, if present, specifies the TCP/UDP port for connection.

**Example:**

```
https://user:password@www.example.com:8080/path/to/resource
```

- Scheme: https
- User info: user:password (deprecated practice)
- Host: www.example.com
- Port: 8080
- Path: /path/to/resource

### Path Component

The path identifies the specific resource within the scope of the scheme and authority. It consists of a sequence of path segments separated by forward slashes (/). Paths can be absolute (starting with /) or relative (not starting with /).

Path segments can contain unreserved characters (letters, digits, hyphen, period, underscore, tilde) and percent-encoded characters for special or reserved characters.

### Query Component

The query component provides non-hierarchical data, typically as key-value pairs. It begins with a question mark (?) and commonly uses ampersand (&) to separate multiple parameters, though this is a convention rather than a requirement of RFC 3986.

Query parameters enable passing data to the resource, such as search terms, filters, or configuration options.

### Fragment Component

The fragment identifier, preceded by a hash (#), refers to a secondary resource or specific portion within the primary resource. Fragments are processed client-side and are not sent to the server in HTTP requests.

Fragments commonly reference specific sections within documents, timestamps in media files, or application states in single-page applications.

## Percent-Encoding

Percent-encoding (URL encoding) represents characters that have special meaning or are not allowed in URIs. It uses the percent sign (%) followed by two hexadecimal digits representing the character's byte value in UTF-8.

Reserved characters that have special meaning in URI syntax include: `:/?#[]@!$&'()*+,;=`

These characters must be percent-encoded when used literally in URI components. Unreserved characters (A-Z, a-z, 0-9, hyphen, period, underscore, tilde) should never be encoded.

**Example:**

```
Original: Hello World! How are you?
Encoded: Hello%20World%21%20How%20are%20you%3F
```

Modern standards prefer percent-encoding based on UTF-8 byte sequences rather than other character encodings.

## Normalization

URI normalization is the process of converting URIs into a consistent, canonical form for comparison. Different URI strings can refer to the same resource, making normalization essential for caching, deduplication, and security.

### Syntax-Based Normalization

Syntax-based normalization applies transformations that are guaranteed to preserve semantic equivalence according to URI syntax rules.

Case normalization converts scheme and host to lowercase, as these components are case-insensitive. Percent-encoding normalization uppercases hexadecimal digits in percent-encoded triplets and decodes unreserved characters that are unnecessarily encoded.

Path segment normalization removes dot segments (. and ..) according to the algorithm specified in RFC 3986. This resolves relative references and removes redundant navigation.

**Example:**

```
Before: HTTP://Example.COM:80/path/../other/./file.html
After: http://example.com/other/file.html
```

### Scheme-Based Normalization

Scheme-based normalization applies rules specific to particular URI schemes. For HTTP and HTTPS, this includes removing default ports (80 for HTTP, 443 for HTTPS) and ensuring absolute paths start with a slash.

Empty path components can be replaced with "/" for HTTP(S) URIs. Query and fragment components may undergo scheme-specific normalization based on their semantics.

### Protocol-Based Normalization

Protocol-based normalization requires protocol-level knowledge and may involve network access. This includes resolving directory indexes, removing duplicate slashes, and handling case-insensitive file systems.

This level of normalization is less deterministic and may change resource identity in some cases.

## URL Standard (WHATWG Living Standard)

The WHATWG URL Standard represents the modern specification for URL parsing and handling. Unlike RFC 3986, which is relatively static, the WHATWG standard is a living document that evolves with web platform needs.

### URL Parsing Algorithm

The URL parsing algorithm defines precisely how browsers and modern applications should parse URL strings. It provides detailed steps for handling edge cases, invalid input, and legacy formats that RFC 3986 leaves ambiguous.

The algorithm operates as a state machine with distinct states for parsing different URL components. It handles scheme parsing, authority parsing with special cases for special schemes, path parsing with scheme-specific rules, query parsing, and fragment parsing.

**Key Points:**

- Defines exact parsing behavior for ambiguous cases
- Handles legacy formats for backward compatibility
- Specifies error handling and validation
- Provides deterministic results across implementations

### Special Schemes

The WHATWG standard defines special handling for certain schemes: ftp, file, http, https, ws, and wss. These schemes have specific parsing rules, always use authority components, and have scheme-specific path handling.

Special schemes use special host parsing, which handles domain names, IPv4 addresses, IPv6 addresses, and opaque hosts differently than other schemes.

### URL Serialization

URL serialization converts a parsed URL object back into a string representation. The standard defines precise rules for serializing each component, ensuring consistent output across implementations.

Serialization includes proper percent-encoding of special characters, formatting of IPv6 addresses, handling of credentials in authority, and assembly of components in the correct order.

### Modern URL Handling

The WHATWG standard introduces the URL and URLSearchParams interfaces for JavaScript. These provide programmatic access to URL components with automatic parsing and serialization.

The URL constructor accepts absolute or relative URL strings and optional base URLs. Properties provide access to individual components with automatic encoding/decoding. Methods enable component modification with validation.

**Example:**

```javascript
const url = new URL('https://example.com:8080/path?query=value#fragment');
console.log(url.protocol); // "https:"
console.log(url.hostname); // "example.com"
console.log(url.port); // "8080"
console.log(url.pathname); // "/path"
console.log(url.search); // "?query=value"
console.log(url.hash); // "#fragment"

url.searchParams.append('newParam', 'newValue');
console.log(url.href); // Updated URL string
```

### URLSearchParams Interface

URLSearchParams provides methods for working with query strings: append, delete, get, getAll, has, set, and iteration methods. It handles encoding/decoding automatically and supports multiple values per parameter name.

**Example:**

```javascript
const params = new URLSearchParams('foo=1&bar=2&foo=3');
params.get('foo'); // "1" (first value)
params.getAll('foo'); // ["1", "3"] (all values)
params.append('baz', '4');
params.toString(); // "foo=1&bar=2&foo=3&baz=4"
```

### Backward Compatibility Considerations

The WHATWG standard maintains compatibility with existing web content while clarifying ambiguities. It documents how browsers actually behave rather than prescribing idealized behavior.

Legacy URL formats are parsed consistently with historical browser behavior. Invalid URLs produce predictable results rather than undefined behavior. The standard aligns with RFC 3986 where practical but diverges when web compatibility requires different handling.

## Differences Between RFC 3986 and WHATWG URL Standard

While both standards describe URLs, they serve different purposes and have notable differences in scope, precision, and handling of edge cases.

### Philosophical Approach

RFC 3986 is a generic specification for all URIs, not just URLs used on the web. It provides a framework that URI schemes can build upon. The WHATWG URL Standard is specifically designed for web URLs and describes actual browser behavior.

RFC 3986 leaves many details to scheme-specific specifications, while WHATWG provides complete, deterministic parsing for web URLs.

### Parsing Precision

The WHATWG standard provides explicit state machine algorithms for parsing, while RFC 3986 uses regular expressions and prose descriptions that can be interpreted differently.

For ambiguous inputs, the WHATWG standard specifies exact behavior, while RFC 3986 may leave behavior undefined or implementation-dependent.

### Host Parsing

The WHATWG standard includes detailed rules for parsing and validating hostnames, including domain name validation, IPv4 address formats (including legacy formats), IPv6 address syntax, and percent-encoded hosts.

RFC 3986 provides basic syntax but leaves validation details to other specifications like DNS and IP address standards.

### Special URLs

The WHATWG standard defines special schemes (http, https, file, ftp, ws, wss) with specific parsing rules. RFC 3986 treats all schemes generically, leaving special handling to scheme-specific specifications.

### Relative URL Resolution

Both standards describe relative URL resolution, but the WHATWG standard provides more detailed algorithms that handle edge cases explicitly. The WHATWG approach is designed to match browser behavior precisely.

## International Domain Names (IDN)

Internationalized Domain Names allow domain names to contain non-ASCII characters. IDN is handled through ASCII-compatible encoding (ACE) using the Punycode algorithm.

### Punycode Encoding

Punycode converts Unicode strings into ASCII strings that can be used in DNS. Encoded labels begin with "xn--" followed by the encoded representation.

**Example:**

```
Original: münchen.de
Punycode: xn--mnchen-3ya.de

Original: 中国.cn
Punycode: xn--fiqs8s.cn
```

### IDNA Standards

IDNA (Internationalized Domain Names in Applications) defines how applications should process international domain names. IDNA2008 is the current standard, though IDNA2003 is still widely used in practice.

The standards define which Unicode characters are valid in domain names, how to normalize domain names before encoding, and validation rules for preventing security issues.

### Security Considerations

IDN homograph attacks exploit visual similarity between characters from different scripts. Characters from different alphabets may look identical (e.g., Latin 'a' vs. Cyrillic 'а').

Browsers implement protections such as displaying Punycode for mixed-script domains, limiting certain character combinations, and maintaining lists of confusable characters.

## Data URLs

Data URLs embed small data items directly in documents. They use the data: scheme and include the media type and encoding directly in the URL.

The syntax follows: `data:[<mediatype>][;base64],<data>`

**Example:**

```
data:text/plain;charset=UTF-8,Hello%20World
data:text/html,<h1>Hello</h1>
data:image/png;base64,iVBORw0KGgoAAAANS...
```

Data URLs are useful for embedding small images, fonts, or other resources without separate HTTP requests. They increase document size and cannot be cached separately. Base64 encoding increases data size by approximately 33%.

## File URLs

File URLs reference files on local file systems using the file: scheme. The syntax and behavior vary significantly across operating systems and implementations.

General format: `file://[host]/path`

On Windows: `file:///C:/path/to/file.txt` On Unix/Linux: `file:///path/to/file.txt` With UNC paths: `file://server/share/file.txt`

File URLs have security implications as they access local resources. Modern browsers restrict file URL usage in web contexts and prevent cross-origin access from file URLs to other schemes.

## Mailto URLs

Mailto URLs initiate email composition with pre-filled fields. They use the mailto: scheme and can include recipient addresses, subject, body, and other email headers.

Syntax: `mailto:address[?header=value&header=value]`

**Example:**

```
mailto:user@example.com
mailto:user@example.com?subject=Hello&body=Message%20text
mailto:user1@example.com,user2@example.com?cc=user3@example.com
```

The behavior depends on the user's email client configuration. Not all clients support all mailto features, and maximum URL length varies by client and system.

## Telephone URLs

Telephone URLs enable click-to-call functionality on devices with telephony capabilities. They use the tel: scheme defined in RFC 3966.

Syntax: `tel:phone-number[;parameter][?parameter]`

**Example:**

```
tel:+1-201-555-0123
tel:+1-201-555-0123;ext=123
tel:+1-201-555-0123;phone-context=+1-201
```

Phone numbers should include country codes using + notation. Extensions can be specified using ";ext=" parameter. The tel: scheme initiates the default phone application on supported devices.

## Security Considerations in URLs

URLs present various security challenges that implementations must address through careful handling and validation.

### Open Redirect Vulnerabilities

Open redirects occur when applications redirect users to URLs specified in parameters without validation. Attackers can use this to redirect users to malicious sites.

Mitigation involves validating redirect destinations against allowlists, checking for same-origin redirects when appropriate, encoding redirect parameters properly, and displaying warnings for external redirects.

### Server-Side Request Forgery (SSRF)

SSRF attacks trick servers into making requests to unintended destinations. Attackers provide URLs that cause the server to access internal resources or perform actions on behalf of the server.

Protection requires validating and sanitizing user-provided URLs, blocking access to private IP ranges and localhost, implementing allowlists for permitted destinations, and using separate networking contexts for user-initiated requests.

### URL Parsing Inconsistencies

Different URL parsers may interpret the same URL string differently, leading to security bypasses. Attackers exploit parser differences to bypass security checks.

**Example:**

```
http://example.com@attacker.com
https://example.com\@attacker.com
http://example.com.attacker.com
```

Different parsers might interpret these differently, treating "example.com" as the host or as userinfo/subdomain.

### Credential Exposure

Including credentials in URLs exposes them in browser history, server logs, referrer headers, and shoulder surfing. The userinfo component (username:password) is deprecated in modern standards.

Best practices include using POST requests for credentials, implementing proper authentication mechanisms, avoiding credential inclusion in URLs, and redacting credentials from logs and error messages.

### Fragment Identifier Security

Fragment identifiers are processed client-side and can be accessed by JavaScript. They're not sent to servers in HTTP requests but are visible in referrer headers when navigating from pages with fragments.

Security implications include potential exposure of sensitive data if fragments contain confidential information, cross-site scripting if fragments are used unsafely in JavaScript, and tracking through fragment-based analytics.

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

## URL Shortening and Link Management

URL shortening services convert long URLs into shorter aliases for easier sharing. These services create short identifiers that redirect to the original URL.

Benefits include more manageable URLs for social media and messaging, tracking capabilities through redirect analytics, and ability to update target URLs without changing the short link.

Concerns involve link rot if the service shuts down, privacy implications of tracking through redirects, security risks if the service is compromised, and lack of transparency about final destination.

Best practices include using established, reliable services for important links, implementing custom shorteners for organizational control, providing preview functionality showing final destination, setting appropriate expiration policies, and monitoring short links for abuse.

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

# URI Syntax Components

## Scheme Component

The scheme component identifies the protocol or naming system used to interpret the resource identifier. It appears at the beginning of the URI and is case-insensitive, though lowercase is conventional.

**Syntax Structure:**

```
scheme = ALPHA *( ALPHA / DIGIT / "+" / "-" / "." )
```

The scheme consists of a sequence starting with a letter, followed by any combination of letters, digits, plus (+), hyphen (-), or period (.). The scheme is terminated by a colon (:).

**Common Scheme Examples:**

- `http` and `https` for web resources
- `ftp` for file transfer protocol
- `mailto` for email addresses
- `file` for local file system access
- `data` for inline data
- `tel` for telephone numbers
- `urn` for uniform resource names
- `ws` and `wss` for WebSocket connections

**Scheme Registration:**

Schemes are registered with IANA (Internet Assigned Numbers Authority). Registered schemes follow standardized specifications, while provisional or private schemes may be used for specific applications. The scheme determines how the remainder of the URI is parsed and interpreted.

**Case Sensitivity:**

While schemes themselves are case-insensitive per RFC 3986, the interpretation of the rest of the URI depends on the scheme specification. Normalizing schemes to lowercase is standard practice.

## Authority Component

The authority component identifies the naming authority governing the namespace for the resource. It is prefixed by a double slash (//) and contains information about the location where the resource can be accessed.

**Syntax Structure:**

```
authority = [ userinfo "@" ] host [ ":" port ]
```

### Userinfo Subcomponent

The userinfo subcomponent contains authentication credentials or user identification information. It precedes the host and is separated by an at sign (@).

**Structure:**

```
userinfo = *( unreserved / pct-encoded / sub-delims / ":" )
```

**Example:**

```
user:password@example.com
username@example.com
```

Modern security practices discourage including passwords in URIs due to visibility in logs, browser history, and over-the-shoulder observation. Many schemes have deprecated or restricted userinfo usage.

### Host Subcomponent

The host identifies the server or naming authority. It can take three forms:

**1. Registered Name (Domain Name):**

```
example.com
subdomain.example.org
```

Domain names are case-insensitive and should be normalized to lowercase. They follow DNS naming conventions and may include internationalized domain names (IDN) using punycode encoding.

**2. IPv4 Address:**

```
192.0.2.1
10.0.0.1
```

IPv4 addresses consist of four decimal octets separated by periods. Each octet ranges from 0 to 255.

**3. IPv6 Address:**

```
[2001:db8::1]
[::1]
[fe80::a%eth0]
```

IPv6 addresses are enclosed in square brackets to distinguish them from port separators. They use hexadecimal notation with colon separators and support compression of zero sequences using double colons (::). Zone identifiers for link-local addresses are appended with a percent sign.

### Port Subcomponent

The port number specifies the TCP or UDP port for connection. It follows the host, separated by a colon.

**Structure:**

```
port = *DIGIT
```

**Examples:**

```
example.com:8080
192.0.2.1:443
[2001:db8::1]:8000
```

Each scheme defines a default port (HTTP uses 80, HTTPS uses 443). When the default port is used, it is typically omitted from the URI. Empty port specifications (host:) are syntactically valid but uncommon.

**Authority Examples:**

```
//example.com
//user@example.com:8080
//192.0.2.1
//[2001:db8::1]:443
//example.com:
```

## Path Component

The path component identifies the resource within the scope of the naming authority. It consists of a sequence of segments separated by forward slashes (/).

**Syntax Structure:**

```
path = path-abempty    ; begins with "/" or is empty
     / path-absolute   ; begins with "/" but not "//"
     / path-noscheme   ; begins with a non-colon segment
     / path-rootless   ; begins with a segment
     / path-empty      ; zero characters
```

### Path Types

**Path-abempty:** Used when an authority is present. May begin with slash or be empty.

```
//example.com/path/to/resource
//example.com
```

**Path-absolute:** Begins with slash but not double slash. Used without authority.

```
/path/to/resource
/
```

**Path-noscheme:** Used in relative references without a scheme. Cannot begin with colon.

```
relative/path
../parent/resource
```

**Path-rootless:** Begins with a segment without leading slash.

```
relative/path/to/resource
resource
```

**Path-empty:** Zero-length path.

```
http://example.com?query
mailto:user@example.com
```

### Path Segments

Path segments are separated by forward slashes and may contain:

```
segment = *pchar
pchar = unreserved / pct-encoded / sub-delims / ":" / "@"
unreserved = ALPHA / DIGIT / "-" / "." / "_" / "~"
sub-delims = "!" / "$" / "&" / "'" / "(" / ")" / "*" / "+" / "," / ";" / "="
```

**Special Segments:**

- `.` (single dot) represents the current directory
- `..` (double dot) represents the parent directory
- Empty segments (`//`) are distinct from single slashes

**Percent Encoding:**

Characters outside the unreserved and allowed sets must be percent-encoded using the format %XX where XX is the hexadecimal representation of the byte value.

```
/path%20with%20spaces
/path/to/resource%3Fspecial
```

### Path Normalization

Normalization removes redundant path components:

**Before Normalization:**

```
/a/b/c/./../../g
/a/../b/c/
/a/./b/./c/
```

**After Normalization:**

```
/a/g
/b/c/
/a/b/c/
```

The algorithm processes dot segments according to RFC 3986:

1. Remove single-dot segments (`.`)
2. Process double-dot segments (`..`) by removing the preceding segment
3. Remove leading dot segments from absolute paths
4. Preserve trailing slashes

**Case Sensitivity:**

Path comparison is case-sensitive unless the scheme specification indicates otherwise. Some file systems and servers normalize paths to a specific case, but the URI specification treats paths as case-sensitive by default.

## Query Component

The query component contains non-hierarchical data that identifies the resource in combination with the path. It is separated from the preceding component by a question mark (?).

**Syntax Structure:**

```
query = *( pchar / "/" / "?" )
```

The query may contain any character from the pchar set plus forward slashes and question marks. Percent encoding applies to characters outside this set.

### Query String Format

While the URI specification does not mandate a specific query format, the most common convention uses key-value pairs separated by ampersands or semicolons:

```
?key1=value1&key2=value2&key3=value3
?name=John&age=30&city=Boston
?param1=value1;param2=value2
```

**Key Components:**

- **Key-value pairs:** Separated by equals sign (=)
- **Pair separators:** Ampersand (&) is most common, semicolon (;) is an alternative
- **Multiple values:** Same key repeated or array notation

**Examples:**

```
?search=term&page=2&sort=date
?id[]=1&id[]=2&id[]=3
?filter=active&filter=verified
```

### Query Parameter Encoding

Special characters in query strings require percent encoding:

**Reserved Characters in Queries:**

```
?name=John+Doe              (space as plus, legacy form-encoding)
?name=John%20Doe            (space as %20, standard percent-encoding)
?email=user%40example.com   (@ encoded)
?url=https%3A%2F%2Fexample.com  (colons and slashes encoded)
```

The application/x-www-form-urlencoded media type has additional encoding rules:

- Spaces may be encoded as plus signs (+) or %20
- Ampersands, equals signs, and other delimiters must be encoded in values
- Line breaks are encoded as CR LF pairs (%0D%0A)

**Different Encoding Contexts:**

```
?search=hello%20world       (standard URI encoding)
?search=hello+world         (form encoding)
?data=%7B%22key%22%3A%22value%22%7D  (JSON in query, fully encoded)
```

### Query String Parsing

Query string parsing conventions vary by implementation:

**Parameter Without Value:**

```
?flag
?key1&key2=value2
```

These may be interpreted as boolean flags or as keys with empty values, depending on the parser.

**Array Parameters:**

Different conventions for representing arrays:

```
?id=1&id=2&id=3              (repeated keys)
?id[]=1&id[]=2&id[]=3        (bracket notation)
?id=1,2,3                    (comma-separated)
```

**Nested Objects:**

Frameworks support various nested object notations:

```
?user[name]=John&user[age]=30
?filter[date][from]=2024-01-01&filter[date][to]=2024-12-31
```

### Query String Semantics

The query component is non-hierarchical, meaning its interpretation does not depend on hierarchical parsing like the path component. The order of parameters may or may not be significant depending on the application.

**Idempotence Considerations:**

```
?page=2&sort=date&filter=active
?sort=date&filter=active&page=2
```

These may be semantically equivalent, but string comparison shows them as different. Applications implementing caching or comparison must normalize query parameter order.

**Query String Length Limitations:**

While the URI specification does not impose length limits, practical constraints exist:

- HTTP servers often limit total URI length (commonly 2048-8192 bytes)
- Browsers impose varying maximum lengths
- Proxies and intermediaries may have stricter limits
- Long queries should be moved to request bodies when possible

### Empty Query Component

An empty query component (URI ending with `?`) is distinct from no query component:

```
http://example.com/path       (no query)
http://example.com/path?      (empty query)
http://example.com/path?key=  (key with empty value)
```

These are three distinct URIs that may resolve to different resources or trigger different application behavior.

**Key Points:**

- Scheme determines protocol interpretation and parsing rules for remaining components
- Authority contains optional userinfo, mandatory host (domain, IPv4, or bracketed IPv6), and optional port
- Path structure varies based on presence of authority and relative/absolute context
- Query component uses non-hierarchical key-value convention, though format is not mandated by URI specification
- Each component has specific character allowances, with percent-encoding required for characters outside allowed sets
- Normalization rules differ by component, with schemes being case-insensitive while paths are case-sensitive
- Component boundaries are determined by reserved delimiters: `://` separates scheme from authority, `/` begins path, `?` begins query

---

## Fragment Component

The fragment component identifies a secondary resource within the primary resource identified by the URI. It appears after a hash symbol (#) and is the final component of a URI.

**Syntax Position:**

```
scheme://authority/path?query#fragment
                              ↑
                        fragment starts here
```

The fragment component provides a method to reference a specific part of a resource without requiring the server to process it. When a URI containing a fragment is dereferenced, the client retrieves the primary resource first, then processes the fragment identifier locally.

**Processing Behavior:**

Fragment identifiers are not sent to the server during HTTP requests. When a browser requests `https://example.com/doc.html#section2`, only `https://example.com/doc.html` is transmitted in the HTTP request. The client handles the fragment after receiving the response.

**Allowed Characters:**

The fragment component permits unreserved characters (letters, digits, hyphen, period, underscore, tilde), percent-encoded characters, and sub-delimiters (!, $, &, ', (, ), *, +, ,, ;, =). Additionally, the characters : @ / ? are allowed within fragments.

**Common Applications:**

In HTML documents, fragments reference element IDs or named anchors. For `https://example.com/page.html#introduction`, the browser scrolls to the element with `id="introduction"`. In JSON documents using JSON Pointer notation, fragments specify paths to specific values. SVG files use fragments to reference specific graphic elements within the image. Media fragments specify temporal or spatial segments of audio/video resources.

**Fragment Semantics:**

The interpretation of fragment identifiers depends on the media type of the retrieved resource. HTML fragments identify elements, while PDF fragments might specify page numbers or named destinations. This media-type-specific interpretation occurs entirely on the client side.

## Component Separator Characters

URI syntax employs specific reserved characters to delimit and separate components. These characters have designated syntactic purposes and must be percent-encoded when used literally within component values.

**Primary Separators:**

The colon (:) separates the scheme from the hierarchical part. In `http://example.com`, the colon after "http" terminates the scheme component. The double forward slash (//) marks the beginning of the authority component when present. The single forward slash (/) separates the authority from the path and delimits path segments. The question mark (?) introduces the query component. The hash symbol (#) introduces the fragment component.

**Authority Component Separators:**

Within the authority component, the at symbol (@) separates optional userinfo from the host. In `ftp://user:pass@ftp.example.com`, the @ symbol divides the authentication credentials from the hostname. Square brackets ([]) enclose IPv6 addresses to distinguish colons in the address from the port separator. The colon (:) within the authority separates the host from the optional port number.

**Sub-Delimiters:**

The characters ! $ & ' ( ) * + , ; = function as sub-delimiters. These characters are reserved but may appear in certain URI components without percent-encoding. Their specific usage depends on the URI scheme and component. For instance, the semicolon historically separated path parameters in some schemes, though this usage has declined.

**Percent-Encoding Requirements:**

Reserved characters must be percent-encoded when they appear as data rather than delimiters. The percent sign (%) itself must be encoded as %25 when used literally. To include a literal question mark in a path segment, encode it as %3F. To include a literal hash in a query parameter value, encode it as %23.

**Character Precedence:**

The separators have hierarchical significance. The scheme separator (:) is processed first, followed by the authority marker (//), then path separators (/), query separator (?), and finally fragment separator (#). This ordering determines how parsers tokenize URI strings.

## Optional vs Required Components

URI components vary in their requirement status depending on the URI scheme and syntax form. Understanding which components are mandatory versus optional is essential for constructing valid URIs.

**Required Components:**

The scheme component is mandatory in absolute URIs. Every absolute URI must begin with a scheme name followed by a colon. The scheme determines the interpretation of the remaining components and the protocols or rules for accessing the resource.

**Optional Components:**

The authority component is optional in the general URI syntax. When present, it is indicated by the // prefix. URIs like `mailto:user@example.com` omit the authority component entirely. The scheme-specific rules determine whether an authority is permitted or required.

Path components vary by context. In hierarchical URIs with an authority, the path may be empty, though an absolute path (beginning with /) is typical. In URIs without an authority, the path cannot begin with //. Relative references may consist solely of a path without scheme or authority.

The query component is optional and indicated by the ? prefix. Many URIs function without query strings. When present, the query may be empty (? followed immediately by # or end of URI).

The fragment component is optional and indicated by the # prefix. Its presence does not affect resource retrieval from the server but guides client-side processing.

**Userinfo Subcomponent:**

Within the authority, the userinfo subcomponent (username and optional password) is optional. When present, it is separated from the host by @. Modern security practices discourage including passwords in URIs due to visibility in logs and browser history.

**Port Subcomponent:**

The port number is optional within the authority. When omitted, the default port for the scheme is assumed (80 for HTTP, 443 for HTTPS, 21 for FTP). Explicit port specification overrides the default.

**Empty Components:**

Some components may be syntactically present but empty. A URI may have an empty query (`http://example.com/path?`) or empty fragment (`http://example.com/path#`). An empty path is valid in certain contexts, such as `http://example.com?query`.

**Scheme-Specific Requirements:**

Individual URI schemes impose additional requirements. HTTP and HTTPS URIs require an authority component. The `file` scheme may omit the authority for local files. The `data` scheme contains the data directly in the path component without an authority. The `tel` scheme uses only a path component for telephone numbers.

## Component Ordering Rules

URI components must appear in a strict sequence defined by the URI specification. This ordering enables unambiguous parsing and consistent interpretation across implementations.

**Canonical Ordering:**

The scheme appears first and is terminated by a colon. Following the scheme, if an authority component is present, it is introduced by //. The authority contains userinfo (if present), host, and port (if present) in that sequence. The path component follows the authority or scheme. The query component follows the path and is introduced by ?. The fragment component appears last and is introduced by #.

**Complete Ordering Pattern:**

```
scheme:[//[userinfo@]host[:port]]path[?query][#fragment]
```

This pattern represents the maximum structure. Individual URIs may omit optional components but cannot reorder them.

**Parsing Implications:**

The fixed ordering allows parsers to process URIs left-to-right, identifying components by their delimiter characters. A parser first extracts the scheme by locating the first colon. If // follows the scheme colon, an authority component is present and extends until the first /, ?, #, or end of string. The path extends from the end of the authority (or scheme if no authority) until ?, #, or end of string. The query extends from ? until # or end of string. The fragment extends from # until end of string.

**Relative Reference Ordering:**

Relative references omit the scheme and optionally the authority, but maintained component ordering applies to components that are present. A relative reference might consist of only a path, or a path with query, or any combination that preserves the canonical sequence. The forms include `//authority/path?query#fragment` (network-path reference), `/path?query#fragment` (absolute-path reference), `path?query#fragment` (relative-path reference), `?query#fragment` (query-only reference), and `#fragment` (fragment-only reference).

**Authority Component Internal Ordering:**

Within the authority, userinfo must precede the host, separated by @. The host must precede the port, separated by :. IPv6 addresses enclosed in brackets maintain the host position but use internal colons that do not function as port separators. The pattern is `[userinfo@]host[:port]` where userinfo consists of `username[:password]`.

**Component Boundary Determination:**

The first occurrence of delimiter characters determines component boundaries. The first / after the authority marks the start of the path. The first ? after the path marks the start of the query. The first # marks the start of the fragment. Characters within percent-encoded triplets do not function as delimiters. The sequence %3F represents a literal question mark, not a query separator.

**Scheme-Specific Ordering Variations:**

[Inference] While the general URI syntax defines this ordering, specific schemes may impose additional constraints or utilize components differently. However, when schemes use the general URI syntax structure, they adhere to the canonical ordering.

**Serialization Requirements:**

When constructing URIs programmatically, components must be assembled in canonical order. Generating the scheme first, followed by authority prefix and authority components, then path, query, and fragment ensures syntactic validity. Attempting to place components out of order produces invalid URIs that parsers may reject or misinterpret.

---

# URI Schemes

## Scheme Definition and Purpose

A **URI scheme** is the first component of a URI that defines the syntax and semantics for the remainder of the identifier. It specifies the protocol, namespace, or context used to interpret the resource identifier that follows.

The scheme appears before the first colon in a URI and determines how the rest of the URI should be parsed and what operations are valid for that resource type. Schemes establish the rules for resource identification and access within their respective domains.

According to RFC 3986, a scheme name consists of a sequence of characters beginning with a letter and followed by any combination of letters, digits, plus (+), period (.), or hyphen (-). Scheme names are case-insensitive, though lowercase is conventional.

**Syntax Structure:**

```
scheme:scheme-specific-part

Examples:
https://example.com
mailto:user@example.com
ftp://files.server.com/path
urn:isbn:0-486-27557-4
```

**Primary Functions:**

**Protocol Specification:** Network-based schemes (http, https, ftp) define the communication protocol for accessing resources. They indicate how clients should connect to servers and retrieve data.

**Namespace Definition:** Schemes like "urn" and "tag" define naming systems for resources. They establish rules for constructing identifiers within specific organizational or semantic spaces.

**Resource Type Indication:** Schemes signal the nature of resources and appropriate handling methods. For example, "mailto" indicates email addresses, "tel" indicates telephone numbers, and "data" indicates inline data.

**Operational Semantics:** Each scheme defines valid operations. HTTP supports GET, POST, and other methods; mailto implies email composition; file indicates local filesystem access.

**Key Points:**

- Schemes are mandatory in absolute URIs
- They determine parsing rules for the remainder of the URI
- Different schemes may use identical syntax patterns for different purposes
- Scheme-specific syntax follows the colon delimiter
- No universal default scheme exists; context determines appropriate scheme

The scheme component enables URI extensibility. New schemes can be defined to support emerging protocols, technologies, or identification systems without changing the fundamental URI syntax structure.

**Example:**

```
Network Access:
http://example.com/resource
ftp://ftp.example.com/file.zip
ssh://server.com:22

Communication:
mailto:admin@example.com
tel:+1-555-0123
sms:+1-555-0456

Resource Identification:
urn:uuid:f81d4fae-7dec-11d0-a765-00a0c91e6bf6
tag:example.com,2024:posts/123

Data and Content:
data:text/plain;base64,SGVsbG8gV29ybGQ=
javascript:alert('Hello')

Filesystem:
file:///home/user/document.txt
```

The scheme's position at the URI's beginning allows parsers to immediately determine how to process the identifier. This front-loaded information architecture supports efficient URI handling and routing across diverse systems.

## Common Schemes

### HTTP and HTTPS

**http (Hypertext Transfer Protocol)** is the foundational scheme for the World Wide Web, defined in RFC 7230. It specifies unencrypted transmission of web content between clients and servers over TCP/IP networks.

**https (HTTP Secure)** extends HTTP with encryption using TLS (Transport Layer Security), defined in RFC 2818. It provides confidentiality, integrity, and authentication for web communications.

**Syntax:**

```
http://host[:port]/path[?query][#fragment]
https://host[:port]/path[?query][#fragment]

Examples:
http://example.com/page.html
https://secure.example.com:443/login
https://example.com/search?q=term&limit=10
https://example.com/article#section-2
```

**Components:**

- **host**: Domain name or IP address (required)
- **port**: Optional (default 80 for HTTP, 443 for HTTPS)
- **path**: Hierarchical resource location
- **query**: Key-value parameters following "?"
- **fragment**: Reference to document section following "#"

HTTPS has become the standard for web traffic. Modern browsers mark HTTP sites as "not secure," and many services require HTTPS for security-sensitive operations.

### FTP

**ftp (File Transfer Protocol)** enables file transfer between clients and servers, defined in RFC 1738. It supports directory navigation, file upload/download, and basic file management operations.

**Syntax:**

```
ftp://[user[:password]@]host[:port]/path

Examples:
ftp://ftp.example.com/pub/files/
ftp://user:pass@ftp.example.com/private/document.pdf
ftp://ftp.example.com:2121/archive/
```

FTP URLs may include authentication credentials, though this practice is discouraged for security reasons. Anonymous FTP access typically uses "anonymous" as the username.

Modern usage has declined in favor of HTTPS, SFTP (SSH File Transfer Protocol), and cloud storage APIs. Many browsers have deprecated or removed FTP support.

### FILE

**file** accesses resources on local filesystems, defined in RFC 8089. It references files and directories on the local machine or network-accessible file shares.

**Syntax:**

```
file://[host]/path
file:///path (localhost implied)

Examples:
file:///home/user/documents/report.pdf
file:///C:/Users/Admin/Desktop/image.jpg
file://server.local/share/file.txt
```

The file scheme typically uses three slashes (///) for local files on Unix-like systems, where the empty host component represents localhost. Windows paths require special handling for drive letters.

**Key Points:**

- Limited to local or network filesystem access
- No standardized authentication or encryption
- Browser support varies due to security concerns
- Path syntax depends on operating system conventions

### MAILTO

**mailto** initiates email composition, defined in RFC 6068. It specifies recipient addresses and optionally includes subject, body, and other email headers.

**Syntax:**

```
mailto:address[@host][?headers]

Examples:
mailto:user@example.com
mailto:support@example.com?subject=Help%20Request
mailto:contact@example.com?subject=Inquiry&body=Message%20text
mailto:sales@example.com?cc=manager@example.com&bcc=archive@example.com
```

The scheme triggers the user's default email client with pre-populated fields. Multiple recipients can be specified using comma separation.

### TEL and SMS

**tel** identifies telephone numbers according to RFC 3966, using the E.164 international format.

**sms** initiates SMS text messaging, similar to mailto for email.

**Syntax:**

```
tel:+1-555-123-4567
tel:+442071234567
sms:+1-555-123-4567?body=Message%20text

Examples:
tel:+1-800-555-0199
sms:+447700900123
```

### DATA

**data** embeds small data items inline within URIs, defined in RFC 2397. It encodes content directly rather than referencing external resources.

**Syntax:**

```
data:[mediatype][;base64],data

Examples:
data:text/plain;charset=utf-8,Hello%20World
data:text/html,<h1>Title</h1>
data:image/png;base64,iVBORw0KGgoAAAANS...
```

Data URIs are useful for embedding images, stylesheets, or scripts within HTML/CSS, reducing HTTP requests. However, they increase document size and cannot be cached separately.

### URN

**urn (Uniform Resource Name)** provides persistent, location-independent identifiers, defined in RFC 8141. URNs use namespace identifiers (NID) to organize naming systems.

**Syntax:**

```
urn:nid:nss

Examples:
urn:isbn:978-0-123456-78-9
urn:uuid:6e8bc430-9c3a-11d9-9669-0800200c9a66
urn:ietf:rfc:3986
urn:doi:10.1000/182
```

Common URN namespaces include ISBN (books), UUID (universally unique identifiers), DOI (digital object identifiers), and ISSN (serial publications).

### Additional Common Schemes

**javascript** executes JavaScript code when activated, primarily in web browsers.

```
javascript:alert('Hello')
javascript:void(0)
```

**ws/wss** (WebSocket/WebSocket Secure) enable bidirectional communication channels over TCP.

```
ws://example.com/socket
wss://example.com/socket
```

**magnet** specifies resources available through peer-to-peer file sharing networks.

```
magnet:?xt=urn:btih:hash&dn=name
```

**Key Points:**

- HTTP/HTTPS dominate web traffic (70%+ of all URIs)
- HTTPS is now standard practice for security
- FTP usage has significantly declined
- Specialized schemes serve specific application domains
- Mobile platforms introduced app-specific URI schemes

Different schemes serve distinct purposes in the internet ecosystem, enabling diverse resource types and access methods within the unified URI framework.

## Permanent vs Provisional Schemes

URI schemes are classified into two registration categories by IANA (Internet Assigned Numbers Authority): **permanent** and **provisional**. This classification reflects the scheme's standardization status, stability, and expected longevity.

### Permanent Schemes

**Permanent schemes** have undergone formal review and registration through the IETF (Internet Engineering Task Force) standards process or equivalent rigorous evaluation. They are expected to remain stable and widely supported indefinitely.

**Characteristics:**

- Documented in RFCs or equivalent formal specifications
- Reviewed by the IETF or designated expert reviewers
- Stable syntax and semantics unlikely to change
- Intended for long-term, widespread use
- Subject to community consensus

**Registration Requirements:**

- Complete technical specification
- Demonstrated implementation and deployment
- Clear operational semantics
- Security considerations documented
- Interoperability requirements defined

**Examples:**

```
http, https - Web protocols (RFC 7230, RFC 2818)
ftp - File Transfer Protocol (RFC 1738)
mailto - Email addresses (RFC 6068)
tel - Telephone numbers (RFC 3966)
urn - Uniform Resource Names (RFC 8141)
file - Local filesystem access (RFC 8089)
ws, wss - WebSocket protocols (RFC 6455)
```

Permanent schemes undergo updates through additional RFCs or specification revisions. Changes follow formal processes to ensure backward compatibility and community review.

### Provisional Schemes

**Provisional schemes** are registered for experimental use, emerging technologies, or specialized applications. They may lack complete standardization, have limited deployment, or serve narrow use cases.

**Characteristics:**

- Less rigorous review process than permanent schemes
- May be experimental or application-specific
- Subject to change or deprecation
- Limited deployment or vendor-specific use
- Registration may be first-come-first-served

**Registration Requirements:**

- Basic specification document (may be less formal than RFC)
- Demonstration of intent to use
- Contact information for maintainer
- May not require implementation proof

**Examples:**

```
webcal - Calendar subscription (provisional)
facetime - Apple's video calling
steam - Valve's gaming platform
spotify - Spotify music links
slack - Slack workspace links
```

Provisional schemes may transition to permanent status if they gain widespread adoption, complete formal standardization, and demonstrate long-term viability. Alternatively, they may remain provisional indefinitely or be deprecated.

### Historical and Deprecated Schemes

Some schemes have been registered but later **deprecated** due to obsolescence, security concerns, or replacement by superior alternatives.

**Examples:**

```
gopher - Gopher protocol (largely obsolete)
wais - Wide Area Information Server (obsolete)
prospero - Prospero Directory Service (obsolete)
```

Browsers and applications may remove support for deprecated schemes, though registrations often remain for historical reference.

### Private and Unregistered Schemes

Organizations may use **unregistered schemes** for internal purposes or application-specific URI handling. These do not appear in IANA registries.

**Examples:**

```
myapp:// - Custom application protocol
x-internal:// - Private organizational scheme
```

[Inference] Unregistered schemes risk collision with future registered schemes and lack guarantees of uniqueness or interoperability. The "x-" prefix convention historically indicated experimental or private schemes, though RFC 6648 deprecated this practice.

### Comparison

|Aspect|Permanent|Provisional|
|---|---|---|
|Review Process|Rigorous IETF/expert review|Basic registration review|
|Stability|High, changes rare|May change or be deprecated|
|Documentation|Formal RFC or equivalent|May be informal specification|
|Implementation|Proven, widely deployed|May be limited or experimental|
|Expected Lifespan|Indefinite|Variable, may be temporary|

**Key Points:**

- Permanent schemes undergo formal standardization
- Provisional schemes support innovation and experimentation
- Transition from provisional to permanent is possible
- Historical schemes may remain registered but deprecated
- Registration prevents namespace collisions
- Both categories appear in IANA registry

The two-tier system balances standardization with flexibility. Permanent schemes provide stability for core internet functionality, while provisional registration enables rapid deployment of new technologies without blocking innovation during standardization.

Organizations implementing URI schemes should prefer permanent schemes for established protocols and consider provisional registration for experimental or application-specific needs. The IANA registry provides authoritative information on all registered schemes and their current status.

## IANA URI Scheme Registry

The **IANA (Internet Assigned Numbers Authority) URI Scheme Registry** is the authoritative repository of registered URI schemes. It maintains comprehensive documentation of scheme names, specifications, registration status, and responsible contacts.

The registry is publicly accessible at:

```
https://www.iana.org/assignments/uri-schemes/uri-schemes.xhtml
```

### Registry Structure

The registry organizes schemes into categories and provides standardized information for each entry.

**Required Registration Information:**

- **Scheme name**: The identifier used in URIs
- **Status**: Permanent, Provisional, or Historical
- **Reference**: Specification document (RFC number or external document)
- **Registrant**: Contact information for responsible party
- **Registration date**: When the scheme was registered
- **Last modified**: Most recent update timestamp

**Example Entry:**

```
Scheme: https
Status: Permanent
Reference: RFC 7230, RFC 2818
Description: Hypertext Transfer Protocol Secure
Registrant: IETF
```

### Registration Process

URI scheme registration follows procedures defined in **RFC 7595** (previously RFC 4395). The process varies based on the requested registration status.

**Permanent Scheme Registration:**

1. **Specification Development**: Create comprehensive technical specification documenting syntax, semantics, operations, and security considerations
2. **IETF Review**: Submit specification through IETF standards process or to designated expert reviewers
3. **Community Feedback**: Address comments and concerns from technical community
4. **IANA Submission**: Submit registration request with complete documentation
5. **Registration**: IANA adds scheme to permanent registry upon approval

**Provisional Scheme Registration:**

1. **Basic Specification**: Prepare documentation describing scheme purpose and basic syntax
2. **Registration Request**: Submit request to IANA with specification reference
3. **Review**: Designated expert performs basic review for namespace conflicts and completeness
4. **Registration**: IANA adds scheme to provisional registry upon approval

### Registration Template

Registration requests follow a standardized template specified in RFC 7595:

```
URI Scheme Name: [scheme-name]

Status: [Permanent/Provisional]

Scheme Syntax: [formal syntax definition]

Scheme Semantics: [description of what URIs mean]

Encoding Considerations: [character encoding rules]

Applications/Protocols That Use This Scheme: [usage context]

Interoperability Considerations: [compatibility notes]

Security Considerations: [security implications]

Contact: [name and email]

Author/Change Controller: [responsible party]

References: [specification documents]
```

### Registry Categories

The IANA registry maintains several views and categorizations:

**By Status:**

- Permanent schemes (134+ entries as of 2025)
- Provisional schemes (300+ entries as of 2025)
- Historical schemes (deprecated but documented)

**By Application Domain:**

- Network protocols (http, ftp, ssh)
- Communication (mailto, tel, sms)
- Identification (urn, tag, uuid)
- Media and content (data, javascript)
- Application-specific (spotify, slack, zoom)

### Registry Usage

**For Implementers:**

- Verify scheme standardization status before implementation
- Locate authoritative specifications
- Check for deprecated schemes to avoid
- Find contact information for scheme maintainers

**For Specification Authors:**

- Confirm scheme name availability
- Review existing schemes for similar functionality
- Understand registration requirements
- Access templates and procedures

**For Application Developers:**

- Determine appropriate schemes for use cases
- Verify scheme support across platforms
- Identify standardized alternatives to custom schemes

### Notable Registry Statistics

[Unverified] The registry contains approximately 450+ registered schemes across all categories. HTTP/HTTPS remain the most widely used, followed by mailto, ftp, and tel.

**Distribution:** [Inference] Permanent schemes represent roughly 30% of registrations, with provisional schemes comprising the majority. This distribution reflects both the rigorous requirements for permanent status and the growing ecosystem of application-specific URI handlers.

### Key Points

- IANA registry is the sole authoritative source for URI schemes
- RFC 7595 defines current registration procedures
- Registration prevents namespace collisions and promotes interoperability
- Public registry enables discovery and documentation
- Both permanent and provisional registrations are freely accessible
- Registration does not guarantee implementation or adoption
- Historical entries preserve documentation of deprecated schemes

### Coordination with Other Standards

The URI scheme registry coordinates with related IANA registries:

**Media Types Registry**: Some schemes (data, http) reference MIME media types **Port Numbers Registry**: Network schemes often have associated default ports **TLD Registry**: Schemes may interact with domain name system **Protocol Registries**: Schemes based on network protocols reference protocol specifications

This coordination ensures consistency across internet standards and prevents conflicts between different specification domains.

The IANA registry serves as the central coordination point for URI scheme namespace management, enabling the decentralized yet interoperable internet architecture that relies on standardized resource identification.

---

## Scheme-Specific Syntax Rules

URI schemes define how the remainder of the URI should be interpreted after the scheme name and colon. Each scheme has its own syntax rules, character restrictions, and semantic requirements defined in its specification.

### General Scheme Syntax Pattern

After the scheme name and colon, URIs follow one of several patterns:

**Hierarchical Schemes** (most common, use `//` after colon):

```
scheme://authority/path?query#fragment
```

**Non-Hierarchical Schemes** (no `//`, data immediately follows colon):

```
scheme:scheme-specific-part
```

The presence or absence of `//` significantly affects parsing. Hierarchical schemes separate authority from path, while non-hierarchical schemes interpret everything after the colon according to scheme-specific rules.

### HTTP and HTTPS Schemes

Defined in RFC 7230, these schemes follow the standard hierarchical structure with specific requirements:

```
http://host[:port]/path[?query][#fragment]
https://host[:port]/path[?query][#fragment]
```

**Syntax Rules**:

- Authority component is mandatory (must include host)
- Default ports: 80 for HTTP, 443 for HTTPS
- Path is optional; empty path is treated as `/`
- Query strings use `key=value` pairs separated by `&`
- Fragment identifies portion of retrieved resource
- All components except scheme are case-sensitive

**Character Encoding**:

- Percent-encoding required for reserved characters in path and query
- Space encoded as `%20` in path, can be `+` or `%20` in query
- Non-ASCII characters must be UTF-8 encoded then percent-encoded

**Example**:

```
https://user:pass@www.example.com:8443/products/item%2042?sort=price&color=blue#reviews
```

### FTP Scheme

Defined in RFC 1738, FTP URLs specify File Transfer Protocol resources:

```
ftp://[user[:password]@]host[:port]/path[;type=typecode]
```

**Syntax Rules**:

- Default port: 21
- Path represents directory structure on FTP server
- Leading `/` in path may indicate absolute path from root or relative to user's home directory (server-dependent)
- Type parameter specifies transfer mode:
    - `type=a`: ASCII text mode
    - `type=i`: Binary/image mode
    - `type=d`: Directory listing

**Example**:

```
ftp://anonymous:email@ftp.example.com/pub/files/document.pdf;type=i
```

[Inference: Modern browsers have deprecated or removed FTP support, though the scheme remains valid for specialized FTP clients and libraries.]

### Mailto Scheme

Defined in RFC 6068, mailto creates email message composition links:

```
mailto:address[,address]*[?header=value[&header=value]*]
```

**Syntax Rules**:

- One or more email addresses separated by commas
- No `//` after colon (non-hierarchical)
- Query parameters specify email headers (subject, body, cc, bcc)
- Header names are case-insensitive
- Values must be percent-encoded
- Line breaks in body represented as `%0D%0A` (CRLF)

**Supported Headers**:

- `subject`: Email subject line
- `body`: Message body text
- `cc`: Carbon copy recipients
- `bcc`: Blind carbon copy recipients
- `to`: Additional recipients (can also be in main address list)

**Example**:

```
mailto:user@example.com,other@example.com?subject=Hello%20World&body=This%20is%20a%20test&cc=copy@example.com
```

### File Scheme

Defined in RFC 8089, file URLs reference local or network-accessible files:

```
file://[host]/path
file:///path
```

**Syntax Rules**:

- Three slashes (`file:///`) indicate localhost
- Host can specify network server (UNC path on Windows)
- Path follows operating system conventions
- On Windows, drive letters appear as `/C:/path`
- On Unix-like systems, absolute paths begin with `/`

**Platform-Specific Examples**:

Windows local file:

```
file:///C:/Users/Documents/file.txt
```

Windows network share:

```
file://server/share/file.txt
```

Unix-like system:

```
file:///home/user/documents/file.txt
```

[Unverified: Browser implementations of file URLs vary significantly in their security restrictions and path handling, particularly regarding cross-origin access and directory listings.]

### Data Scheme

Defined in RFC 2397, data URLs embed data directly within the URI:

```
data:[mediatype][;base64],data
```

**Syntax Rules**:

- No `//` after colon (non-hierarchical)
- Default media type: `text/plain;charset=US-ASCII`
- Optional `;base64` parameter indicates base64 encoding
- Data component contains the actual content
- Comma separates metadata from data
- Percent-encoding applies to data component unless base64 is used

**Media Type Specification**:

- Full MIME type can be specified: `text/html`, `image/png`, `application/json`
- Parameters follow media type: `text/plain;charset=UTF-8`

**Examples**:

Plain text:

```
data:text/plain,Hello%20World
```

HTML content:

```
data:text/html,<h1>Title</h1><p>Content</p>
```

Base64-encoded image:

```
data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUA...
```

JSON data:

```
data:application/json,{"key":"value","number":42}
```

**Size Limitations**: [Unverified: While the specification doesn't impose length limits, browsers typically restrict data URLs to 2-10 MB depending on implementation, and some contexts (like CSS) may have stricter limits.]

### Tel Scheme

Defined in RFC 3966, tel URIs represent telephone numbers:

```
tel:phone-number[;parameter]*
```

**Syntax Rules**:

- No `//` after colon (non-hierarchical)
- Global numbers must start with `+` and country code
- Local numbers may omit `+` but require context
- Visual separators (hyphens, parentheses, spaces) are allowed but ignored
- Parameters separated by semicolons

**Format Examples**:

Global number:

```
tel:+1-234-567-8900
tel:+12345678900
```

Local number with context:

```
tel:555-0100;phone-context=+1-234
```

With extension:

```
tel:+1-234-567-8900;ext=123
```

**Parameters**:

- `phone-context`: Provides context for local numbers
- `ext`: Extension number
- `isub`: ISDN subaddress

### URN Scheme

Defined in RFC 8141, URNs provide persistent, location-independent identifiers:

```
urn:namespace:namespace-specific-string
```

**Syntax Rules**:

- Namespace identifier (NID) must be registered with IANA
- Namespace-specific string (NSS) follows rules defined by the namespace
- No `//` after colon (non-hierarchical)
- Case sensitivity depends on namespace specification
- Optional components for resolution, query, and fragment

**Common URN Namespaces**:

ISBN (books):

```
urn:isbn:0451450523
urn:isbn:978-0-451-45052-9
```

ISSN (serials):

```
urn:issn:1234-5678
```

UUID:

```
urn:uuid:f81d4fae-7dec-11d0-a765-00a0c91e6bf6
```

OID (Object Identifier):

```
urn:oid:1.2.3.4.5
```

**Extended Syntax**:

```
urn:namespace:nss?+resolution?=query#fragment
```

### JavaScript Scheme

Used in HTML to execute JavaScript code:

```
javascript:code
```

**Syntax Rules**:

- No `//` after colon (non-hierarchical)
- Code directly follows colon
- Percent-encoding not typically required but supported
- Return value of last expression used as document content if not `undefined`
- `void(0)` or `void 0` prevents navigation

**Examples**:

Alert dialog:

```
javascript:alert('Hello World');
```

No-operation (prevents default link action):

```
javascript:void(0);
```

Multiple statements:

```
javascript:(function(){var x=5;alert(x*2);})();
```

[Unverified: Many modern browsers restrict or block javascript: URLs in certain contexts due to security concerns, particularly in Content Security Policy (CSP) environments.]

### Magnet Scheme

Used for peer-to-peer file sharing, particularly with BitTorrent:

```
magnet:?xt=urn:btih:hash[&parameter]*
```

**Syntax Rules**:

- Query-like format immediately after `?`
- Multiple parameters separated by `&`
- No authority or path components
- Hash identifies content cryptographically

**Common Parameters**:

- `xt`: Exact topic (content hash)
- `dn`: Display name (filename)
- `tr`: Tracker URL (can be repeated)
- `as`: Acceptable source (web seed)
- `xs`: Exact source (direct download)
- `kt`: Keyword topic (search terms)

**Example**:

```
magnet:?xt=urn:btih:cdabcd1234567890abcdef&dn=filename.txt&tr=http://tracker.example.com:80/announce
```

### News and NNTP Schemes

Defined in RFC 5538, these schemes reference Usenet newsgroups and articles:

```
news:newsgroup-name
news:message-id
nntp://host[:port]/newsgroup-name[/article-number]
```

**Syntax Rules**:

News scheme (no authority):

```
news:comp.lang.python
news:<message-id@example.com>
```

NNTP scheme (with server):

```
nntp://news.example.com/comp.lang.python
nntp://news.example.com/comp.lang.python/12345
```

Message IDs enclosed in angle brackets in news URLs, but not in NNTP URLs.

### WebSocket Schemes

Defined in RFC 6455, ws and wss schemes establish WebSocket connections:

```
ws://host[:port]/path[?query]
wss://host[:port]/path[?query]
```

**Syntax Rules**:

- ws: unencrypted WebSocket (default port 80)
- wss: encrypted WebSocket over TLS (default port 443)
- No fragment component (fragments not sent in WebSocket handshake)
- Authority and path components follow HTTP rules
- Used in WebSocket constructor, not directly in HTML links

**Example**:

```
wss://example.com:9000/socket?token=abc123
```

### SSH and SFTP Schemes

Used for Secure Shell connections and file transfers:

```
ssh://[user@]host[:port]
sftp://[user@]host[:port]/path
```

**Syntax Rules**:

- Default port: 22 for both schemes
- User authentication credentials in authority
- Path in sftp indicates remote file location
- Not standardized in RFCs but widely implemented

**Examples**:

```
ssh://admin@server.example.com:2222
sftp://user@files.example.com/home/user/document.txt
```

### Git Scheme

Used for Git repository cloning and operations:

```
git://host[:port]/path
```

**Syntax Rules**:

- Default port: 9418
- Path indicates repository location on server
- No authentication support (unauthenticated protocol)
- Often replaced by git+ssh or https for authenticated access

**Examples**:

```
git://github.com/user/repository.git
git+ssh://git@github.com/user/repository.git
```

### Scheme Comparison Table

Different schemes balance human readability, machine parseability, and semantic meaning:

|Scheme|Hierarchical|Authority Required|Default Port|Primary Use|
|---|---|---|---|---|
|http/https|Yes|Yes|80/443|Web resources|
|ftp|Yes|Yes|21|File transfer|
|file|Yes|No (localhost)|N/A|Local files|
|mailto|No|No|N/A|Email composition|
|data|No|No|N/A|Inline data|
|tel|No|No|N/A|Phone numbers|
|urn|No|No|N/A|Persistent IDs|
|javascript|No|No|N/A|Code execution|
|ws/wss|Yes|Yes|80/443|WebSocket|

**Key Points**: Each scheme's syntax reflects its purpose—hierarchical schemes organize resources by location and path, while non-hierarchical schemes encode data or identifiers directly. Understanding scheme-specific rules is essential for proper URI construction, parsing, and validation.

## Case Sensitivity in Schemes

Case sensitivity varies across different URI components, with specific rules governing scheme names, host names, paths, and other elements. Proper handling of case prevents broken links and ensures correct resource identification.

### Scheme Name Case Rules

According to RFC 3986, scheme names are **case-insensitive**. All three representations below are equivalent:

```
HTTP://example.com/path
http://example.com/path
HtTp://example.com/path
```

**Normalization**: The specification recommends normalizing scheme names to lowercase for consistency. Parsers must treat schemes case-insensitively, but producers should emit lowercase schemes.

**Implementation**:

```javascript
// Both are valid and equivalent
new URL('HTTP://example.com')
new URL('http://example.com')
// Both resolve to: http://example.com/
```

**Historical Context**: Early URI specifications allowed mixed case, but lowercase became the universal convention. Modern systems convert schemes to lowercase during normalization.

### Authority Component Case Sensitivity

The authority component has mixed case sensitivity rules:

**Host Names (Domain Names)**: Case-insensitive according to DNS specifications (RFC 1034, RFC 1035). These are equivalent:

```
http://EXAMPLE.COM/path
http://example.com/path
http://ExAmPlE.cOm/path
```

DNS resolution treats all domain names case-insensitively. Normalization converts hostnames to lowercase.

**IP Addresses**: Case-insensitive for hexadecimal characters in IPv6 addresses:

```
http://[2001:DB8::1]/path
http://[2001:db8::1]/path
```

IPv4 addresses contain only digits and dots (no case consideration).

**Userinfo (Username/Password)**: Case-sensitivity depends on the authentication system. The URI specification treats userinfo as case-sensitive, but individual systems may differ:

```
http://User:Pass@example.com/    // May differ from:
http://user:pass@example.com/
```

[Inference: Most modern authentication systems treat usernames case-insensitively for usability, but passwords are typically case-sensitive for security.]

**Port Numbers**: Only digits, no case consideration.

**Normalization**: Convert hostnames and IPv6 addresses to lowercase; preserve userinfo case unless system-specific knowledge indicates otherwise.

### Path Component Case Sensitivity

Path case sensitivity is **server-dependent** and varies by operating system and server configuration.

**Unix/Linux Servers**: Paths are case-sensitive by default:

```
http://example.com/Path/File.txt    // Different from:
http://example.com/path/file.txt
```

These URLs reference different resources on Unix systems. Requesting the wrong case results in 404 errors.

**Windows Servers**: Often case-insensitive (but case-preserving):

```
http://example.com/Path/File.txt    // Same as:
http://example.com/path/file.txt
```

Both URLs typically retrieve the same resource, though the file system stores the original case.

**macOS Servers**: Default HFS+ and APFS file systems are case-insensitive but case-preserving, similar to Windows.

**Best Practices**:

- Treat paths as case-sensitive in development to ensure cross-platform compatibility
- Use consistent casing (typically lowercase) for paths
- Configure URL rewriting or redirects to normalize case variations
- Test on case-sensitive systems even if deploying to case-insensitive environments

**Example of Case-Sensitive Path Issue**:

```
// Link in HTML
<a href="/products/category">Products</a>

// Actual file path on server
/Products/Category

// Result: 404 on case-sensitive systems
```

### Query Component Case Sensitivity

Query parameters are **case-sensitive** according to URI specifications, but interpretation depends on the application:

**Parameter Names**: Generally case-sensitive:

```
http://example.com/search?Query=test     // Different from:
http://example.com/search?query=test
```

Server applications decide whether to treat parameter names case-sensitively.

**Parameter Values**: Always case-sensitive:

```
http://example.com/search?query=Test     // Different from:
http://example.com/search?query=test
```

Search for "Test" vs "test" produces different results if search is case-sensitive.

**Common Convention**: Many web applications treat parameter names case-insensitively for usability but preserve value case sensitivity. Database queries and filters typically respect value case.

**Example**:

```
// E-commerce site may treat these the same:
?Category=Electronics
?category=electronics

// But these search for different products:
?product=iPhone
?product=iphone
```

### Fragment Identifier Case Sensitivity

Fragment identifiers are **case-sensitive** according to RFC 3986, but interpretation depends on the document format:

**HTML IDs**: Case-sensitive in HTML5:

```html
<div id="Section"></div>

<!-- This will not match: -->
<a href="#section">Link</a>

<!-- This will match: -->
<a href="#Section">Link</a>
```

**XML IDs**: Always case-sensitive.

**Plain Text**: No standard interpretation; case-sensitivity depends on viewer implementation.

**Best Practice**: Use consistent casing for fragment identifiers and matching element IDs to avoid broken anchors.

### Percent-Encoded Characters

Hexadecimal digits in percent-encoding are case-insensitive:

```
http://example.com/path%2Fto    // Same as:
http://example.com/path%2fto
```

Both represent the same character (`/`). Normalization converts hex digits to uppercase.

**Normalization Example**:

```
Original:  http://example.com/path%2fto
Normalized: http://example.com/path%2Fto
```

However, different percent-encoded representations of case-sensitive characters are distinct:

```
http://example.com/Path    // Different from:
http://example.com/path    // Which differs from:
http://example.com/%50ath  // (where %50 = 'P')
```

The last two are equivalent after decoding, but differ from the first on case-sensitive systems.

### Scheme-Specific Case Rules

Some schemes define additional case sensitivity rules:

**HTTP/HTTPS**: Recommends case-sensitive paths but case-insensitive hostnames. Query and fragment case sensitivity determined by application.

**File Scheme**: Case sensitivity follows underlying file system (Unix: sensitive, Windows/macOS: insensitive).

**Mailto**: Email addresses in the local part (before `@`) may be case-sensitive depending on mail server, though most treat them insensitively. Domain part is always case-insensitive.

**Data Scheme**: Media type is case-insensitive; data payload case sensitivity depends on type.

**URN**: Case sensitivity specified by individual namespace definitions. Some namespaces (like ISBN) are case-insensitive, others require exact case matching.

### URI Comparison and Equivalence

RFC 3986 defines comparison algorithms that account for case sensitivity:

**Simple String Comparison**: Fastest but catches only identical URIs:

```
http://Example.com/path ≠ http://example.com/path
```

**Syntax-Based Normalization**: Applies case normalization rules:

1. Lowercase scheme and hostname
2. Uppercase percent-encoding hex digits
3. Decode unnecessary percent-encoded characters
4. Remove default ports

After normalization:

```
HTTP://Example.com:80/Path%2fto%2Fresource%7e
Becomes:
http://example.com/Path/to/resource~
```

**Scheme-Based Normalization**: Applies scheme-specific rules (removing default ports, normalizing paths).

**Protocol-Based Normalization**: Requires understanding server behavior (path case sensitivity, redirects, content negotiation).

### Case Sensitivity Security Implications

Case sensitivity mismatches can create security vulnerabilities:

**Access Control Bypass**: If access controls use case-sensitive matching but the server is case-insensitive:

```
// Blocked by security rule
/admin/delete

// Might bypass rule if comparison is case-sensitive
/Admin/delete
```

**Cache Poisoning**: Case variations might create separate cache entries for the same resource, potentially serving malicious content.

**Duplicate Content**: Search engines may treat case variants as different URLs, diluting SEO value.

**Best Security Practice**: Normalize URLs at application entry points, treating path components consistently regardless of server file system case sensitivity.

### Practical Recommendations

**For URI Producers** (applications generating URIs):

- Always emit lowercase schemes and hostnames
- Use consistent path casing (preferably lowercase)
- Document whether your API treats parameters case-sensitively
- Normalize URIs before storing or comparing

**For URI Consumers** (applications parsing URIs):

- Treat schemes and hostnames case-insensitively
- Preserve original case for paths, queries, and fragments unless you have specific knowledge about the target system
- Implement normalization for comparison operations
- Consider security implications of case sensitivity in access control

**For Web Developers**:

- Use lowercase for all URI components when possible
- Test on case-sensitive systems (Linux/Unix)
- Implement canonical URLs with proper redirects
- Configure servers to handle case variations appropriately (301 redirects to canonical form)

**Key Points**: Case sensitivity in URIs is not uniform—schemes and hostnames are case-insensitive, while paths, queries, and fragments are case-sensitive by specification but may be treated differently by specific servers or applications. Understanding these distinctions prevents broken links, security issues, and integration problems.

## Custom Scheme Definition

Organizations and applications can define custom URI schemes to enable specialized functionality, protocol handlers, and deep linking. The process involves technical specification, optional registration, and implementation considerations.

### When to Define Custom Schemes

Custom schemes are appropriate for:

**Application-Specific Protocols**: When existing schemes don't adequately represent your protocol's semantics:

```
myapp://action/resource
spotify://track/1234567890
```

**Deep Linking**: Enabling direct navigation to specific application states:

```
shopping://product/12345
news://article/breaking-story
```

**Protocol Integration**: Creating bridges between different systems:

```
git://repository/path
magnet:?xt=urn:btih:...
```

**Internal Corporate Systems**: Organization-specific resource identification:

```
corpnet://department/document
intranet://wiki/page
```

**Avoid Custom Schemes When**:

- Existing schemes suffice (http/https for web resources)
- Deep linking can use URL parameters (https://example.com/app?action=open)
- Universal schemes (data:, javascript:) meet your needs
- Custom scheme would confuse users or conflict with established patterns

### Technical Specification Requirements

A well-defined custom scheme requires documentation of:

**Scheme Name**: Must follow RFC 3986 rules:

- Start with a letter
- Contain only letters, digits, plus (`+`), period (`.`), or hyphen (`-`)
- Should be short, descriptive, and unlikely to conflict
- Case-insensitive but conventionally lowercase

**Valid Examples**:

```
myapp
example-app
app.example
git+ssh
```

**Invalid Examples**:

```
123app      // Cannot start with digit
my_app      // Underscore not allowed
my-app!     // Special character not allowed
```

**Syntax Definition**: Specify the structure after the scheme:

```
scheme:scheme-specific-part[?query][#fragment]
```

Document:

- Whether to use hierarchical (`://`) or non-hierarchical (`:`) format
- Authority component requirements (host, port, userinfo)
- Path structure and allowed characters
- Query parameter format and semantics
- Fragment identifier meaning
- Encoding requirements for special characters

**Example Specification**:

```
shopapp://action/resource?param=value

Components:
- scheme: "shopapp" (case-insensitive)
- action: One of {view, add, purchase} (case-sensitive)
- resource: Resource ID (alphanumeric, percent-encoded if special chars)
- param: Optional query parameters (standard URL query format)

Examples:
shopapp://view/product-123
shopapp://add/item-456?quantity=2
shopapp://purchase/cart?checkout=true
```

**Semantics**: Define what the URI represents:

- What resource or action does it identify?
- What should happen when a client processes it?
- What operations are supported?
- What states or contexts are valid?

**Security Considerations**: Address potential vulnerabilities:

- Parameter injection risks
- Authentication requirements
- Authorization checks
- Resource access boundaries
- Cross-origin implications
- User consent for sensitive actions

**Error Handling**: Specify behavior for malformed URIs:

- Missing required components
- Invalid characters
- Out-of-range values
- Unknown actions or resources

**Versioning**: Plan for future evolution:

- Version number in scheme name (`myapp-v2://`) or path (`myapp://v2/`)
- Backward compatibility strategy
- Migration path for old URIs

### IANA Registration Process

Formal registration with IANA provides:

- Official recognition and documentation
- Prevention of naming conflicts
- Public specification availability
- Standards-track status

**Registration Types**:

**Permanent Schemes**: For widely-used, stable protocols

- Requires IETF RFC or equivalent specification
- Expert review and IESG approval
- Long-term commitment to maintenance
- Examples: http, ftp, mailto

**Provisional Schemes**: For experimental or limited-scope use

- Lighter documentation requirements
- First-come, first-served registration
- Can be promoted to permanent later
- Suitable for application-specific schemes

**Historical Schemes**: Previously registered but now obsolete

- Maintained for reference
- Should not be used for new implementations

**Registration Steps**:

1. **Prepare Specification Document**:
    
    - Scheme name and syntax
    - Semantics and use cases
    - Encoding and character set
    - Security considerations
    - Contact information
2. **Submit to IANA**:
    
    - Email registration request to iana@iana.org
    - Include completed registration template
    - Reference specification document (if available)
3. **Expert Review**:
    
    - Designated expert reviews submission
    - Checks for conflicts with existing schemes
    - Evaluates specification quality
    - May request modifications
4. **Publication**:
    
    - Approved schemes added to IANA registry
    - Publicly accessible at https://www.iana.org/assignments/uri-schemes/
    - Specification linked from registry entry

**Registration Template**:

```
Scheme name: example
Status: Provisional
Applications/protocols: Example application protocol
Contact: admin@example.com
Change controller: Example Organization
References: https://example.com/spec/example-uri-scheme.html
```

### Implementation Approaches

**Operating System Registration**:

Different platforms provide mechanisms to register custom scheme handlers:

**Windows**: Registry entries associate schemes with applications

```
HKEY_CLASSES_ROOT\myapp
    (Default) = "URL:MyApp Protocol"
    URL Protocol = ""
    
HKEY_CLASSES_ROOT\myapp\shell\open\command
    (Default) = "C:\Path\To\App.exe" "%1"
```

**macOS**: Info.plist configuration in application bundle

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>myapp</string>
        </array>
        <key>CFBundleURLName</key>
        <string>com.example.myapp</string>
    </dict>
</array>
```

**Linux**: Desktop entry files specify scheme handlers

```
[Desktop Entry]
Name=MyApp
Exec=myapp %u
MimeType=x-scheme-handler/myapp;
```

**Web Browsers**:

Browsers handle custom schemes through protocol handler APIs:

**Navigator.registerProtocolHandler** (limited support):

```javascript
navigator.registerProtocolHandler(
    'web+myapp',  // Must start with 'web+' for security
    'https://example.com/handle?url=%s',
    'My App Handler'
);
```

Restrictions:

- Scheme must start with `web+` or be an approved scheme (mailto, etc.)
- Handler must be HTTPS URL on same origin
- User must explicitly approve registration

**Android**:

Intent filters in AndroidManifest.xml:

```xml
<activity android:name=".MainActivity">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="myapp" />
    </intent-filter>
</activity>
```

Handle in activity:

```java
Intent intent = getIntent();
Uri data = intent.getData();
if (data != null) {
    String scheme = data.getScheme();
    String path = data.getPath();
    // Process custom URI
}
```

**iOS**:

URL Schemes in Info.plist:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>myapp</string>
        </array>
    </dict>
</array>
```

Handle in AppDelegate:

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    if url.scheme == "myapp" {
        // Handle custom URL
        return true
    }
    return false
}
```

### Security Considerations for Custom Schemes

**Injection Attacks**: Custom scheme handlers must validate and sanitize URI components:

```javascript
// Vulnerable code
let uri = "myapp://action/" + userInput;
window.location = uri;

// Safer approach
function createSafeURI(action, resource) {
    const safeAction = encodeURIComponent(action);
    const safeResource = encodeURIComponent(resource);
    return `myapp://${safeAction}/${safeResource}`;
}
```

**Privilege Escalation**: Handlers should verify user authorization before performing sensitive actions:

```javascript
// Check if action requires authentication
if (requiresAuth(action) && !isAuthenticated()) {
    promptLogin();
    return;
}

// Verify user has permission for resource
if (!hasPermission(user, resource, action)) {
    showError("Access denied");
    return;
}
```

**Phishing and Social Engineering**: Custom schemes can be abused to trick users:

```
mybank://transfer?to=attacker&amount=1000
```

[Inference: Applications should display confirmation dialogs for sensitive actions triggered by URIs, especially when the URI originates from external sources like web pages or emails.]

**Cross-Site Request Forgery (CSRF)**: URIs triggered from web pages can perform actions without user consent:

**Mitigation Strategies**:

- Require user confirmation for state-changing actions
- Implement one-time tokens in URIs for sensitive operations
- Check referrer or origin of URI invocation
- Rate-limit action execution

**URL Spoofing**: Schemes with similar names can confuse users:

```
myapp://...      // Legitimate
rnyapp://...     // Visual similarity attack (rn vs m)
my-app://...     // Slight variation
```

**Protection**:

- Choose distinctive scheme names
- Register variations proactively
- Educate users about official scheme names

### Best Practices for Custom Schemes

**Naming Conventions**:

- Use organization/app name prefix to avoid conflicts: `spotify://`, `slack://`
- Keep names short but descriptive
- Avoid generic terms that might conflict
- Consider future expansion in naming

**Structure Design**:

- Follow established patterns (hierarchical for resources)
- Make URIs human-readable when possible
- Support both minimal and detailed forms
- Allow optional parameters for extensibility

**Example Well-Designed Scheme**:

```
appname://module/action/resource?param=value

Examples:
appname://editor/open/document-123
appname://settings/preferences/display?theme=dark
appname://share/content/post-456?platform=twitter
```

**Backward Compatibility**:

- Version critical changes
- Maintain support for old URI formats during transition
- Provide migration tools or automatic conversion
- Document deprecation timeline clearly

**Documentation**:

- Publish complete specification
- Provide usage examples for common scenarios
- Document error codes and handling
- Include security considerations
- Maintain changelog for specification updates

**Testing**:

- Test across target platforms and OS versions
- Verify proper handling of malformed URIs
- Check security against injection attacks
- Validate encoding/decoding edge cases
- Test integration with different URI sources (web, email, QR codes)

**User Experience**:

- Provide clear feedback when URI is processed
- Show error messages for invalid URIs
- Allow users to review actions before execution
- Support fallback behavior for unregistered handlers

**Privacy**:

- Minimize sensitive data in URIs (they may be logged)
- Use tokens or references instead of explicit user data
- Consider URI visibility in browser history and logs
- Implement expiration for time-sensitive URIs

### Alternative Approaches to Custom Schemes

Before defining custom schemes, consider alternatives:

**Universal Links (iOS) / App Links (Android)**:

- Use standard HTTPS URLs that open apps when installed
- Provide web fallback when app is not installed
- Better for SEO and universal sharing
- More secure (requires domain verification)

**Example**:

```
https://example.com/product/123
// Opens app if installed, otherwise loads web page
```

**URL Parameters with Standard Schemes**:

```
https://example.com/app?action=open&resource=document-123
```

**Deep Linking Services**:

- Branch.io, Firebase Dynamic Links, AppsFlyer
- Provide cross-platform deep linking
- Include analytics and attribution
- Handle deferred deep linking (install then open)

**Key Points**: Custom URI schemes enable powerful application integration and deep linking capabilities but require careful design, security consideration, and proper implementation across platforms. For web-to-app scenarios, modern alternatives like Universal Links often provide better user experience and security. Registration with IANA provides official recognition but is optional for private or application-specific schemes.

## Deprecated Schemes

URI schemes become deprecated when they're superseded by better alternatives, pose security risks, or reference obsolete protocols. Understanding deprecated schemes helps maintain legacy systems and avoid implementing outdated technologies.

### HTTP Scheme Deprecation Context

While HTTP itself is not fully deprecated, its use is actively discouraged in favor of HTTPS:

**Migration from HTTP to HTTPS**:

**Security Motivations**:

- HTTP transmits data in plaintext, exposing sensitive information to eavesdropping
- No authentication of server identity enables man-in-the-middle attacks
- Content can be modified in transit without detection
- Session hijacking through cookie theft

**Browser Treatment**:

Modern browsers mark HTTP sites as "Not Secure":

- Chrome, Firefox, Safari show security warnings
- Progressive degradation of HTTP features
- Some features restricted to HTTPS contexts only

**Features Requiring HTTPS**:

- Geolocation API
- Service Workers and Progressive Web Apps
- HTTP/2 and HTTP/3 protocols
- Secure cookies with SameSite attribute
- Camera and microphone access
- Payment Request API
- Credential Management API

**Search Engine Penalties**: [Unverified: Major search engines like Google reportedly rank HTTPS sites higher than equivalent HTTP sites in search results.]

**Migration Path**:

1. Obtain SSL/TLS certificate
2. Install certificate on server
3. Configure HTTPS on all pages
4. Redirect HTTP to HTTPS (301 redirects)
5. Update internal links to use HTTPS
6. Enable HTTP Strict Transport Security (HSTS)

**Gradual Deprecation Timeline**:

- 2014: Google announced HTTPS as ranking signal
- 2016: Let's Encrypt launched, providing free SSL certificates
- 2017: Chrome began marking HTTP sites with password/credit card fields as "Not Secure"
- 2018: Chrome marked all HTTP sites as "Not Secure"
- 2020+: Major sites overwhelmingly use HTTPS

[Inference: While HTTP URIs remain technically valid and functional, best practice treats them as legacy, using them only for backward compatibility or specific non-sensitive use cases.]

### FTP Scheme

The FTP scheme has been deprecated by major browsers due to security and usability concerns:

**Security Issues**:

- Credentials transmitted in plaintext (username/password)
- No encryption of data transfer
- Vulnerable to packet sniffing and man-in-the-middle attacks
- Difficult to secure behind firewalls (requires multiple ports)
- Complex active/passive mode handling

**Browser Support Status**:

- **Chrome**: Removed FTP support in version 95 (October 2021)
- **Firefox**: Disabled FTP by default in version 88 (April 2021), removed in version 90
- **Edge**: Removed following Chrome deprecation
- **Safari**: Deprecated, limited support remains

**Deprecation Timeline**:

- 2020: Chrome announced intent to deprecate
- Early 2021: Major browsers disabled by default
- Late 2021: Complete removal from Chrome and Firefox

**Modern Alternatives**:

**SFTP (SSH File Transfer Protocol)**:

```
sftp://user@host/path
```

- Encrypted authentication and data transfer
- Uses SSH protocol (port 22)
- Widely supported by dedicated FTP clients
- Not supported in browsers

**FTPS (FTP Secure)**:

```
ftps://host/path
```

- FTP with added TLS/SSL encryption
- Can use implicit (port 990) or explicit (port 21 with STARTTLS) modes
- Limited browser support

**HTTPS for File Downloads**:

```
https://example.com/files/document.pdf
```

- Encrypted transfer
- Better firewall compatibility
- Integrated with web authentication
- Simpler implementation

**WebDAV over HTTPS**:

```
https://example.com/webdav/path
```

- Full file management (read, write, delete)
- HTTP-based protocol
- Better suited for web integration

**Migration Strategy**: For legacy systems using FTP URIs:

1. Audit all FTP links and references
2. Evaluate alternatives based on use case
3. For public downloads, use HTTPS
4. For file management, consider WebDAV or cloud storage APIs
5. For secure transfers, implement SFTP
6. Update documentation and user guidance
7. Provide dedicated FTP clients for users requiring FTP access

**Remaining Use Cases**:

- Legacy system integration
- Dedicated FTP client software
- Automated scripts and file transfer tools
- Internal networks with security perimeter at edge

### Gopher Scheme

Gopher was an early internet protocol for distributing documents, predating the web:

```
gopher://host[:port]/type/selector
```

**Historical Context**:

- Developed at University of Minnesota in 1991
- Popular in early 1990s before WWW adoption
- Menu-driven, text-based document retrieval
- Organized content hierarchically

**Deprecation Reasons**:

- HTTP and HTML provided richer functionality
- Lack of inline images and formatting
- No commercial support or development
- Limited to text and simple file types
- Complex implementation compared to HTTP

**Browser Support**:

- **Firefox**: Removed Gopher support in version 4.0 (2011)
- **Chrome**: Never supported natively
- **Internet Explorer**: Dropped support in IE 6
- **Lynx** (text browser): Still supports Gopher

**Current Status**:

- Small enthusiast community maintains Gopher servers
- Used for nostalgia and minimal computing projects
- Some archives preserved in Gopher format
- Browser extensions available for access

**Modern Equivalent**: HTTP/HTTPS for document distribution, with vastly superior capabilities.

### WAIS Scheme

Wide Area Information Server (WAIS) was an early internet search protocol:

```
wais://host[:port]/database?search
```

**Purpose**: Full-text search of databases across internet

**Deprecation**:

- Superseded by web search engines (Google, etc.)
- Never achieved widespread adoption
- Limited to specific academic and research use cases
- Protocol complexity hindered implementation

**Browser Support**: Removed from all major browsers by early 2000s

**Modern Equivalent**: HTTP-based search APIs and REST services

### Prospero Scheme

Prospero was a distributed file system protocol:

```
prospero://host/path
```

**Purpose**: Unified namespace for distributed file systems

**Deprecation Reasons**:

- Limited adoption beyond research environments
- Superseded by NFS, SMB/CIFS, and web protocols
- Complexity of implementation
- Lack of commercial backing

**Status**: Essentially extinct; historical footnote in internet protocol development

### Telnet Scheme

Telnet provides remote terminal access:

```
telnet://host[:port]
```

**Security Issues**:

- All data transmitted in plaintext, including passwords
- No encryption of session data
- Vulnerable to session hijacking
- Credentials easily intercepted

**Browser Support**:

- Most browsers never supported telnet URIs natively
- Some provided external protocol handlers
- Modern browsers actively block telnet for security

**Modern Alternative**: SSH (Secure Shell)

```
ssh://user@host[:port]
```

[Unverified: SSH URIs are not universally supported in browsers but are handled by terminal applications and SSH clients.]

**Remaining Uses**:

- Legacy embedded systems without SSH support
- Internal network device management (with network security)
- IoT devices with limited resources
- Specific industrial control systems

**Migration Path**:

- Replace with SSH for all new systems
- Restrict telnet to isolated network segments
- Implement VPN access for legacy telnet devices
- Gradual hardware replacement to SSH-capable devices

### News and NNTP Schemes

These schemes access Usenet newsgroups:

```
news:newsgroup-name
news:message-id
nntp://host/newsgroup
```

**Status**: Not formally deprecated but declining

**Decline Reasons**:

- Web forums and social media replaced newsgroups
- Spam overwhelmed many newsgroups
- Lack of moderation and quality control
- Difficult for new users to understand
- ISPs stopped providing Usenet access

**Browser Support**:

- Limited or removed in modern browsers
- Requires separate newsreader applications
- Some webmail services removed newsgroup integration

**Current Usage**:

- Technical communities (comp.* hierarchy)
- Binary file distribution (alt.binaries.*)
- Niche interest groups
- Archive access through Google Groups and others

**Modern Equivalents**:

- Web forums (Reddit, Stack Exchange)
- Mailing lists
- Discord/Slack communities
- Social media groups

### JavaScript Scheme Security Deprecation

While not fully deprecated, javascript: URIs face increasing restrictions:

```
javascript:code
```

**Security Concerns**:

- Cross-Site Scripting (XSS) vector
- Can execute arbitrary code in page context
- Bypasses some security controls
- User may not understand code execution risk

**Browser Restrictions**:

- Content Security Policy (CSP) can block javascript: URIs
- Not allowed in certain contexts (form actions, iframes)
- Some browsers show warnings
- Blocked in email clients and sanitized contexts

**Modern Alternatives**:

**Event Handlers**:

```html
<!-- Instead of: -->
<a href="javascript:doAction()">Click</a>

<!-- Use: -->
<button onclick="doAction()">Click</button>
```

**Unobtrusive JavaScript**:

```javascript
document.getElementById('myButton').addEventListener('click', doAction);
```

**Data Attributes**:

```html
<a href="#" data-action="delete" data-id="123">Delete</a>

<script>
document.querySelectorAll('[data-action]').forEach(el => {
    el.addEventListener('click', function(e) {
        e.preventDefault();
        handleAction(this.dataset.action, this.dataset.id);
    });
});
</script>
```

**Remaining Valid Uses**:

- Bookmarklets (user-added browser bookmarks with JavaScript)
- `void(0)` to prevent default link behavior
- Testing and development tools

### Data Scheme Restrictions

Data URIs are not deprecated but face increasing restrictions:

```
data:text/html,<script>alert('XSS')</script>
```

**Security Issues**:

- Can embed malicious HTML/JavaScript
- Bypasses some Content Security Policies
- Difficult to whitelist/blacklist specific content
- No origin for security checks

**Browser Restrictions**:

- Top-level navigation to data: URIs blocked in many browsers
- Cannot be used for iframes in some contexts
- Service workers cannot intercept data: URIs
- Local storage not accessible from data: URI context

**Restricted Contexts**:

- Email clients strip data: URIs for security
- Social media platforms block data: URI links
- Some Content Management Systems filter data: URIs

**Safe Uses**:

- Inline images in controlled contexts:
    
    ```html
    <img src="data:image/png;base64,...">
    ```
    
- CSS background images
- Font embedding
- Small SVG graphics
- Configuration data (within size limits)

**Alternative Approaches**:

- Host files on CDN or web server
- Use blob: URLs for client-generated content
- Implement proper CSP headers
- Use JavaScript to populate content dynamically

### File Scheme Restrictions

The file scheme has increasing restrictions for security:

```
file:///path/to/file
```

**Security Motivations**:

- Prevents web pages from reading local files
- Stops malicious sites from scanning file system
- Protects user privacy
- Prevents information leakage

**Browser Restrictions**:

- Same-origin policy treats file: URIs strictly
- Cannot make XMLHttpRequest to other file: URIs
- Local storage often disabled for file: origins
- Cannot load web workers from file: URIs
- Cookies typically disabled

**Cross-Origin Restrictions**: Each file: URI often treated as unique origin, preventing:

- Scripts from accessing other local files
- Canvas manipulation of local images
- Module imports from file system

**Modern Development Practices**:

- Use local development servers (Node.js http-server, Python SimpleHTTPServer)
- Development frameworks include built-in servers (webpack-dev-server, Vite)
- Browser developer tools often require HTTP origin

**Valid Use Cases**:

- Opening local HTML files for viewing
- Development with proper local server setup
- Electron/desktop applications
- Accessing documentation stored locally

### General Deprecation Patterns

**Common Reasons for Scheme Deprecation**:

1. **Security Vulnerabilities**: Plaintext transmission (FTP, Telnet), XSS vectors (javascript:), local file access (file:)
    
2. **Technological Obsolescence**: Protocols superseded by better alternatives (Gopher by HTTP, Telnet by SSH)
    
3. **Lack of Adoption**: Limited implementation and usage (WAIS, Prospero)
    
4. **Complexity**: Difficult implementation or firewall traversal (FTP)
    
5. **Privacy Concerns**: Exposure of user data or behavior
    
6. **Maintenance Burden**: Cost of supporting declining protocols
    

**Identifying Deprecated Schemes**:

- Check IANA URI Scheme Registry status
- Review browser compatibility tables
- Monitor security advisories
- Follow standards body announcements (IETF, W3C, WHATWG)
- Examine RFC status (obsoleted, historic)

**Migration Best Practices**:

1. **Audit Usage**: Identify all instances of deprecated schemes in codebases, documentation, and user-facing content
    
2. **Prioritize Updates**: Focus on security-critical and user-visible URIs first
    
3. **Choose Replacements**: Select modern alternatives that meet functional and security requirements
    
4. **Implement Gradually**: Phase migration to minimize disruption
    
5. **Maintain Redirects**: Provide temporary redirects or fallbacks during transition
    
6. **Update Documentation**: Revise developer and user documentation
    
7. **Communicate Changes**: Inform users and stakeholders of deprecation timeline
    
8. **Monitor Impact**: Track errors and user feedback during migration
    

**Key Points**: Scheme deprecation typically results from security vulnerabilities or technological obsolescence. HTTP to HTTPS migration represents the most significant ongoing deprecation, while FTP, Telnet, and Gopher are effectively obsolete in web contexts. JavaScript and data schemes face increasing restrictions rather than full deprecation. Understanding deprecation helps maintain secure, modern applications while supporting necessary legacy integration.

---

# HTTP/HTTPS Schemes

HTTP (Hypertext Transfer Protocol) and HTTPS (HTTP Secure) are the most widely used URI schemes for accessing resources on the World Wide Web. These schemes define how web browsers and other clients communicate with web servers to retrieve and transmit data.

## http:// Scheme Syntax

The http:// scheme follows the generic URI syntax defined in RFC 3986, with specific conventions established in RFC 7230 and related HTTP specifications. The scheme identifier "http" is case-insensitive but conventionally written in lowercase.

**Complete Syntax Structure**:

```
http://[userinfo@]host[:port][/path][?query][#fragment]
```

**Component Breakdown**:

**Scheme**: The literal string "http" followed by a colon and double slash (http://)

**Userinfo**: [Unverified - rarely used in modern practice] An optional component containing username and optionally password, separated by a colon and followed by an @ symbol. This component is deprecated for security reasons as credentials are transmitted in plain text.

```
http://username:password@example.com/resource
```

**Host**: The domain name or IP address of the server hosting the resource. This component is mandatory.

Valid host formats:

- Domain name: `http://www.example.com`
- IPv4 address: `http://192.168.1.1`
- IPv6 address (enclosed in brackets): `http://[2001:db8::1]`

**Port**: An optional port number following the host, separated by a colon. When omitted, the default port for HTTP is used.

**Path**: The hierarchical path to the resource on the server. An empty path is equivalent to "/".

```
http://example.com/products/electronics/laptops
```

**Query**: Optional parameters following a question mark, typically formatted as key-value pairs separated by ampersands.

```
http://example.com/search?q=laptops&category=electronics&sort=price
```

**Fragment**: An optional identifier following a hash symbol, used to reference a specific section within the resource. The fragment is processed by the client and not sent to the server.

```
http://example.com/documentation#installation
```

**Examples of Valid HTTP URIs**:

```
http://example.com
http://example.com:8080
http://example.com/
http://example.com/path/to/resource
http://subdomain.example.com/resource?param=value
http://192.168.1.100:3000/api/users
http://[2001:db8::1]/index.html
```

**Character Encoding in HTTP URIs**:

All characters in HTTP URIs must be from the ASCII character set. Non-ASCII characters and reserved characters used literally must be percent-encoded:

```
http://example.com/search?q=caf%C3%A9
http://example.com/path%20with%20spaces
```

## https:// Scheme Syntax

The https:// scheme syntax is identical to the http:// scheme, with the distinction being the protocol used for communication. HTTPS indicates that HTTP communication is encrypted using Transport Layer Security (TLS) or its predecessor, Secure Sockets Layer (SSL).

**Complete Syntax Structure**:

```
https://[userinfo@]host[:port][/path][?query][#fragment]
```

All components follow the same rules as the HTTP scheme:

**Examples of Valid HTTPS URIs**:

```
https://example.com
https://example.com:8443
https://secure.example.com/login
https://api.example.com/v1/users?format=json
https://192.168.1.100:443/admin
https://[2001:db8::1]:8443/secure
```

**Behavioral Differences from HTTP**:

While syntactically identical, HTTPS URIs trigger different client behavior:

- Establishment of TLS/SSL connection before HTTP communication
- Certificate verification against trusted certificate authorities
- Encryption of all HTTP traffic including headers, body, and cookies
- [Inference] Browser security indicators (padlock icon, green address bar in some browsers)
- Stricter enforcement of mixed content policies

**Mixed Content Considerations**:

When an HTTPS page references HTTP resources (images, scripts, stylesheets), browsers typically block or warn about "mixed content" to prevent security vulnerabilities. Modern web standards require HTTPS pages to only load resources via HTTPS.

## Default Ports (80, 443)

Port numbers identify specific network services on a host. HTTP and HTTPS have well-known default ports registered with the Internet Assigned Numbers Authority (IANA).

**HTTP Default Port: 80**

Port 80 is the standard port for HTTP communication. When a URI uses the http:// scheme without specifying a port number, clients automatically connect to port 80.

**Explicit vs. Implicit Port Specification**:

```
http://example.com          → Connects to port 80 (implicit)
http://example.com:80       → Connects to port 80 (explicit)
http://example.com:8080     → Connects to port 8080 (non-standard)
```

These URIs are functionally equivalent for default ports:

- `http://example.com/path`
- `http://example.com:80/path`

However, for URI comparison and normalization purposes, the explicit port specification should be removed when it matches the scheme's default.

**Common Non-Standard HTTP Ports**:

While port 80 is standard, HTTP servers frequently use alternative ports:

- 8080: Common alternative HTTP port for development and testing
- 8000: Often used for development servers
- 3000: Frequently used by Node.js applications
- 8008: Alternative HTTP port
- 8888: Another common development port

**HTTPS Default Port: 443**

Port 443 is the standard port for HTTPS communication. When a URI uses the https:// scheme without specifying a port number, clients automatically connect to port 443.

**Explicit vs. Implicit Port Specification**:

```
https://example.com         → Connects to port 443 (implicit)
https://example.com:443     → Connects to port 443 (explicit)
https://example.com:8443    → Connects to port 8443 (non-standard)
```

**Common Non-Standard HTTPS Ports**:

- 8443: Common alternative HTTPS port for development and administrative interfaces
- 4443: Sometimes used for HTTPS services
- 9443: Used by various applications for secure communication

**Port Number Constraints**:

- Valid range: 0-65535
- Well-known ports: 0-1023 (typically require administrative privileges)
- Registered ports: 1024-49151 (registered with IANA for specific services)
- Dynamic/private ports: 49152-65535 (available for temporary use)

**Normalization Rules**:

According to RFC 3986, URIs that explicitly specify the default port should be normalized by removing the port component:

```
Normalized:   http://example.com/path
Non-normalized: http://example.com:80/path

Normalized:   https://example.com/path
Non-normalized: https://example.com:443/path
```

**Firewall and Network Considerations**:

[Inference based on common network architecture] Default ports 80 and 443 are typically allowed through corporate firewalls and network security appliances, while non-standard ports may be blocked. This makes default ports more reliable for public-facing services.

## Security Implications

The choice between HTTP and HTTPS has significant security, privacy, and trust implications for both users and service providers.

**HTTP Security Vulnerabilities**:

**Lack of Encryption**: All data transmitted over HTTP is sent in plain text, making it vulnerable to interception. This includes:

- Request and response headers
- URL parameters (including sensitive query strings)
- Request and response bodies
- Authentication credentials
- Session cookies
- Form data

**Man-in-the-Middle Attacks**: Attackers positioned between the client and server can:

- Read all transmitted data
- Modify requests and responses
- Inject malicious content
- Steal authentication credentials and session tokens

**Session Hijacking**: Since HTTP cookies and session identifiers are transmitted in plain text, attackers can capture and reuse them to impersonate legitimate users.

**Content Injection**: Without encryption and integrity verification, attackers can inject malicious content into HTTP responses, including:

- Cross-site scripting (XSS) payloads
- Malware downloads
- Phishing content
- Advertising or tracking code

**DNS Spoofing Vulnerability**: HTTP provides no mechanism to verify that the server responding is the intended server, making users vulnerable to DNS poisoning attacks.

**HTTPS Security Benefits**:

**Encryption**: TLS/SSL encryption protects data in transit:

- All HTTP headers are encrypted
- Request and response bodies are encrypted
- URL paths and query parameters are encrypted (though the hostname remains visible for routing)
- Protection against eavesdropping on networks

**Authentication**: TLS/SSL certificates verify server identity:

- Certificates are issued by trusted Certificate Authorities (CAs)
- Browsers verify certificate validity, expiration, and chain of trust
- [Inference] Extended Validation (EV) certificates provide additional verification of organization identity
- Protection against impersonation and phishing

**Data Integrity**: TLS/SSL includes mechanisms to detect tampering:

- Message Authentication Codes (MACs) verify data hasn't been modified
- Protection against content injection
- Detection of man-in-the-middle attacks

**Forward Secrecy**: [Inference - depends on configuration] Modern TLS implementations support Perfect Forward Secrecy (PFS), ensuring that compromise of long-term keys doesn't compromise past session keys.

**Specific Security Risks and Mitigations**:

**Mixed Content**: HTTPS pages loading HTTP resources create security vulnerabilities:

- Active mixed content (scripts, iframes): Blocked by modern browsers
- Passive mixed content (images, media): Warned or blocked depending on browser policy
- [Inference] Mitigation: Use Content-Security-Policy headers and HTTPS for all resources

**Certificate Validation Issues**:

- Expired certificates trigger browser warnings
- Self-signed certificates are not trusted by default
- Certificate name mismatch (accessing via IP when certificate is for domain)
- Revoked certificates may still be accepted if revocation checking fails

**TLS/SSL Protocol Vulnerabilities**: [Unverified - specific to implementation and version] Older TLS/SSL versions (SSL 3.0, TLS 1.0, TLS 1.1) have known vulnerabilities:

- POODLE attack (SSL 3.0)
- BEAST attack (TLS 1.0)
- [Inference] Modern best practice: Use TLS 1.2 or TLS 1.3

**Privacy Implications**:

**HTTP Privacy Risks**:

- Internet Service Providers (ISPs) can monitor all browsing activity
- Network administrators can log and analyze all traffic
- Third parties on shared networks (public WiFi) can observe activity
- Advertising networks can track users across sites more easily

**HTTPS Privacy Improvements**:

- Encrypted content prevents ISPs from monitoring detailed browsing
- Protection on public and shared networks
- Server Name Indication (SNI) still reveals the hostname being accessed [Inference - though Encrypted SNI (ESNI) is being developed]
- DNS queries may still reveal browsing activity unless DNS-over-HTTPS is used

**Authentication and Trust**:

**Certificate Types**:

**Domain Validated (DV)**: Verifies domain ownership only

- Fastest and least expensive
- Provides encryption but minimal identity verification
- Suitable for blogs, personal sites, and non-commercial applications

**Organization Validated (OV)**: Verifies organization identity

- Requires validation of organization details
- Certificate includes organization name
- Suitable for business websites and e-commerce

**Extended Validation (EV)**: Highest level of validation

- Rigorous verification of organization legal existence and identity
- [Unverified - browser-dependent] May display organization name in browser address bar
- Provides highest level of trust indicators to users

**Certificate Pinning**: [Inference] Applications can be configured to only accept specific certificates or certificate authorities for a domain, preventing acceptance of fraudulent certificates.

**Regulatory and Compliance Requirements**:

**PCI DSS**: Payment Card Industry Data Security Standard requires HTTPS for transmitting cardholder data.

**GDPR**: General Data Protection Regulation in the EU requires appropriate technical measures to protect personal data, which [Inference] generally includes encryption in transit via HTTPS.

**HIPAA**: Health Insurance Portability and Accountability Act in the US requires encryption of protected health information in transit, necessitating HTTPS for healthcare applications.

**Browser and Search Engine Policies**:

**Browser Security Indicators**: [Inference based on common browser behavior] Modern browsers display:

- Padlock icon for HTTPS sites
- "Not Secure" warning for HTTP sites with password or credit card fields
- Full URL security warnings for potentially dangerous sites

**Search Engine Ranking**: [Unverified - based on public statements] Search engines like Google use HTTPS as a ranking signal, favoring secure sites in search results.

**HTTP Strict Transport Security (HSTS)**:

HSTS is a web security policy mechanism that forces browsers to interact with websites only over HTTPS:

```
Strict-Transport-Security: max-age=31536000; includeSubDomains
```

**Benefits**:

- Prevents protocol downgrade attacks
- Prevents cookie hijacking
- Eliminates the insecure initial HTTP request
- Browsers automatically upgrade HTTP requests to HTTPS

**Risks**: Misconfiguration can make sites inaccessible if HTTPS is not properly maintained.

**Performance Considerations**:

**HTTPS Overhead**: TLS/SSL handshake adds latency:

- Initial connection requires additional round trips
- Certificate validation adds processing time
- [Inference] Modern protocols like TLS 1.3 reduce handshake latency

**Optimization Techniques**:

- TLS session resumption reduces handshake overhead for subsequent connections
- HTTP/2 over HTTPS improves performance through multiplexing
- OCSP stapling reduces certificate validation latency

**Migration from HTTP to HTTPS**:

Organizations migrating from HTTP to HTTPS should consider:

**Technical Steps**:

- Obtain SSL/TLS certificates from trusted Certificate Authorities
- Configure web servers to support HTTPS
- Implement HTTP to HTTPS redirects (301 permanent redirects)
- Update internal links and resources to use HTTPS
- Update canonical URLs and sitemaps
- Configure HSTS headers

**SEO Considerations**:

- [Unverified] Search engines treat HTTP and HTTPS URLs as different pages
- Proper redirects maintain search engine rankings
- Update search engine console properties
- Monitor for crawl errors and mixed content issues

**Common Pitfalls**:

- Expired certificates causing site outages
- Mixed content warnings degrading user experience
- Incomplete redirects leaving some pages on HTTP
- Performance degradation from improper configuration
- Certificate renewal failures

The security implications of choosing HTTPS over HTTP are substantial and increasingly critical as cyber threats evolve. Modern web development best practices strongly recommend HTTPS for all websites, regardless of whether they handle sensitive data, to protect user privacy and maintain trust.

---

## HTTP vs HTTPS Structure

Both schemes follow the standard hierarchical URI structure:

```
http://authority/path?query#fragment
https://authority/path?query#fragment
```

**Key differences:**

- **Default ports**: HTTP uses port 80, HTTPS uses port 443
- **Security**: HTTPS encrypts all communication; HTTP transmits in plaintext
- **Certificate requirements**: HTTPS requires valid TLS/SSL certificates
- **Browser indicators**: Modern browsers display security indicators for HTTPS
- **SEO impact**: Search engines prioritize HTTPS content [Inference - based on documented search engine behavior]

**Example:**

```
http://example.com/page.html   // Unencrypted
https://example.com/page.html  // Encrypted with TLS
```

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

## HTTPS-Only Mode

HTTPS-Only Mode is a browser security feature that automatically attempts to upgrade all HTTP connections to HTTPS, protecting users from insecure connections.

### Browser Implementation

Different browsers implement HTTPS-Only Mode with varying approaches:

**Firefox:**

- User-enabled in Settings > Privacy & Security
- Attempts HTTPS upgrade for all connections
- Displays warning page if HTTPS unavailable
- Per-site exceptions available

**Chrome/Edge:**

- "Always use secure connections" option
- Automatic upgrading in address bar
- Gradual rollout of automatic HTTPS

**Safari:**

- Automatic HTTPS upgrade attempts [Unverified - specific implementation details]
- Integrated with privacy features

### Behavior and User Experience

When HTTPS-Only Mode is enabled:

1. **Automatic upgrade attempts**: Browser tries HTTPS first
2. **Connection timeout**: Brief wait for HTTPS response (typically 3-5 seconds)
3. **Fallback warning**: If HTTPS fails, user sees warning page
4. **User choice**: Option to proceed with HTTP or stay on HTTPS

**Example** warning page message:

```
Secure Connection Not Available

example.com doesn't support HTTPS. Continue to HTTP site?

[Go Back]  [Continue to HTTP Site]
```

### Server-Side Configuration

**HTTP Strict Transport Security (HSTS):** Servers can enforce HTTPS-only connections:

```http
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
```

**Parameters:**

- `max-age`: Duration in seconds (31536000 = 1 year)
- `includeSubDomains`: Apply to all subdomains
- `preload`: Eligible for browser preload lists

**HSTS Preload Lists:** Major browsers maintain lists of sites that should only be accessed via HTTPS:

- Hardcoded into browser
- Prevents first-visit downgrade attacks
- Requires commitment to HTTPS [Domain removal is possible but takes time]

### Deployment Considerations

**Testing HTTPS-Only:**

1. Enable HTTPS-Only Mode in browser
2. Navigate site completely
3. Check for broken resources
4. Verify all API endpoints support HTTPS
5. Test third-party integrations

**Migration strategy:**

```
Phase 1: Implement HTTPS, maintain HTTP
Phase 2: Add HSTS header with short max-age
Phase 3: Gradually increase max-age
Phase 4: Add includeSubDomains
Phase 5: Submit to HSTS preload list
```

**Potential issues:**

- Legacy internal systems without HTTPS support
- Third-party resources only available via HTTP
- Development/testing environments
- Cost considerations for certificates (now largely resolved with Let's Encrypt)

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

## Scheme Upgrading

Scheme upgrading refers to the process of automatically converting HTTP requests to HTTPS, either at the browser, server, or network level. This mechanism protects users from insecure connections and facilitates the web's transition to HTTPS-by-default.

### Browser-Level Upgrading

**Automatic HTTPS Upgrades:** Modern browsers implement various upgrade mechanisms:

1. **Address bar intervention:**

```
User types: example.com
Browser loads: https://example.com (not http://example.com)
```

2. **HTTPS-First Mode:** Browser attempts HTTPS before falling back to HTTP (if enabled).
    
3. **Type-specific upgrades:** Some browsers upgrade specific resource types automatically [Browser-specific behavior varies].
    

**Upgrade-Insecure-Requests CSP Directive:** Web pages can request automatic upgrading via Content Security Policy:

```http
Content-Security-Policy: upgrade-insecure-requests
```

**Effect:**

- All HTTP URLs in page are automatically upgraded to HTTPS
- Applies to all resource types (images, scripts, stylesheets, etc.)
- Prevents mixed content issues
- No code changes required in HTML

**Example:**

```html
<!-- HTML Source -->
<img src="http://example.com/image.jpg">
<script src="http://cdn.example.com/script.js"></script>

<!-- With upgrade-insecure-requests, browser requests -->
https://example.com/image.jpg
https://cdn.example.com/script.js
```

**Meta tag alternative:**

```html
<meta http-equiv="Content-Security-Policy" content="upgrade-insecure-requests">
```

### Server-Level Upgrading

**HTTP to HTTPS Redirects:** Servers redirect HTTP requests to HTTPS equivalents:

**301 Permanent Redirect:**

```http
HTTP/1.1 301 Moved Permanently
Location: https://example.com/path
```

**302 Found (Temporary):**

```http
HTTP/1.1 302 Found
Location: https://example.com/path
```

**307 Temporary Redirect (preserves method):**

```http
HTTP/1.1 307 Temporary Redirect
Location: https://example.com/path
```

**Example** Apache configuration:

```apache
<VirtualHost *:80>
    ServerName example.com
    Redirect permanent / https://example.com/
</VirtualHost>
```

**Example** Nginx configuration:

```nginx
server {
    listen 80;
    server_name example.com;
    return 301 https://$server_name$request_uri;
}
```

**HSTS Header (Post-Upgrade):** After redirecting to HTTPS, include HSTS header:

```http
Strict-Transport-Security: max-age=31536000; includeSubDomains
```

This prevents future HTTP requests to the domain from the browser.

### Network-Level Upgrading

**HTTPS-by-Default Networks:** Some networks (ISPs, corporate, public Wi-Fi) may implement upgrade proxies [Deployment varies by provider].

**DNS-Level Security:**

- DNS over HTTPS (DoH)
- DNS over TLS (DoT)
- DNSSEC for authenticity verification

These don't directly upgrade HTTP to HTTPS but protect DNS queries that often precede HTTP requests.

### Upgrade Decision Flow

When a browser encounters an HTTP URL:

```
1. Check HSTS preload list
   └─ If present: Use HTTPS (no HTTP attempt)
   └─ If absent: Continue

2. Check HSTS header from previous visits
   └─ If valid HSTS: Use HTTPS (no HTTP attempt)
   └─ If no HSTS: Continue

3. Check upgrade-insecure-requests directive
   └─ If present: Upgrade to HTTPS
   └─ If absent: Continue

4. Check HTTPS-Only Mode setting
   └─ If enabled: Try HTTPS first
   └─ If disabled: Continue

5. Make HTTP request as specified
```

### Implementation Best Practices

**Gradual Migration Strategy:**

**Phase 1: Support both protocols**

```nginx
# HTTP server
server {
    listen 80;
    # Serve content normally
}

# HTTPS server
server {
    listen 443 ssl;
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    # Serve same content
}
```

**Phase 2: Redirect HTTP to HTTPS**

```nginx
server {
    listen 80;
    return 301 https://$host$request_uri;
}
```

**Phase 3: Add HSTS with short max-age**

```http
Strict-Transport-Security: max-age=86400
```

**Phase 4: Increase HSTS max-age**

```http
Strict-Transport-Security: max-age=31536000
```

**Phase 5: Add includeSubDomains**

```http
Strict-Transport-Security: max-age=31536000; includeSubDomains
```

**Phase 6: Submit to HSTS preload**

```http
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
```

### Testing Scheme Upgrades

**Manual testing:**

1. Clear browser cache and HSTS state
2. Visit HTTP version of site
3. Verify redirect to HTTPS
4. Check HSTS header presence
5. Test with HSTS in effect (should skip HTTP entirely)

**Automated testing:**

```bash
# Check HTTP to HTTPS redirect
curl -I http://example.com

# Check HSTS header
curl -I https://example.com | grep -i strict-transport

# Check certificate validity
openssl s_client -connect example.com:443 -servername example.com
```

**Tools:**

- SSL Labs Server Test (ssllabs.com/ssltest)
- Security Headers checker (securityheaders.com)
- HSTS Preload checker (hstspreload.org)
- Browser DevTools Security tab

### Edge Cases and Considerations

**Localhost and development:**

```
http://localhost:3000  → Often not upgraded
http://127.0.0.1:8080  → Often not upgraded
```

Development environments typically exempt localhost from upgrade rules.

**Internal networks:**

```
http://internal.company.local → May need explicit exemption
```

Corporate internal sites may require HTTP access [Configuration-dependent].

**Legacy system integration:**

- API endpoints without HTTPS support
- Third-party services requiring HTTP callbacks
- IoT devices with limited TLS support

**Performance considerations:**

- TLS handshake overhead (mitigated by TLS 1.3, session resumption)
- Certificate chain validation
- OCSP stapling for revocation checking

**Key Points:**

- Multiple layers provide redundant upgrade mechanisms
- Server-side redirects are most reliable for initial visits
- HSTS prevents downgrade attacks after first HTTPS visit
- upgrade-insecure-requests directive fixes mixed content automatically
- Testing should cover all upgrade mechanisms
- Gradual HSTS deployment reduces risk of lockout

## Security Headers for HTTP/HTTPS

Beyond HSTS, several headers enhance HTTPS security:

**Content-Security-Policy (CSP):**

```http
Content-Security-Policy: default-src https:; script-src 'self' https://trusted.com
```

**X-Frame-Options:**

```http
X-Frame-Options: SAMEORIGIN
```

**X-Content-Type-Options:**

```http
X-Content-Type-Options: nosniff
```

**Referrer-Policy:**

```http
Referrer-Policy: strict-origin-when-cross-origin
```

**Permissions-Policy:**

```http
Permissions-Policy: geolocation=(self), microphone=()
```

## Certificate Management

HTTPS requires valid TLS certificates:

**Certificate types:**

- Domain Validation (DV): Basic identity verification
- Organization Validation (OV): Company verification
- Extended Validation (EV): Rigorous verification [Browser UI indicators vary]

**Certificate acquisition:**

- Let's Encrypt: Free, automated certificates
- Commercial CAs: Paid certificates with support
- Self-signed: Development only (browsers show warnings)

**Certificate renewal:**

- Certificates expire (typically 90 days for Let's Encrypt)
- Automated renewal recommended (certbot, ACME clients)
- Monitor expiration dates to prevent outages

**Example** Let's Encrypt with certbot:

```bash
# Install certbot
apt-get install certbot python3-certbot-nginx

# Obtain and install certificate
certbot --nginx -d example.com -d www.example.com

# Automatic renewal (cron job)
certbot renew --quiet
```

## HTTP/2 and HTTP/3 Considerations

Modern HTTP versions are HTTPS-only [Inference - browsers require HTTPS for HTTP/2 and HTTP/3]:

**HTTP/2:**

- Binary protocol
- Multiplexing
- Server push
- Header compression
- Requires HTTPS in browsers

**HTTP/3:**

- QUIC transport protocol
- UDP-based
- Improved latency
- Built-in encryption
- HTTPS-only

**Key Points:**

- Performance benefits require HTTPS adoption
- Legacy HTTP/1.1 remains for HTTP connections
- Migration to HTTP/2+ incentivizes HTTPS deployment

---

# Authority Component

The authority component is a critical part of URI syntax that identifies the naming authority governing the namespace of the URI. It appears after the scheme and double slashes (`//`) and contains information about where and how to locate a resource within that namespace.

## Authority Syntax Structure

The authority component follows this hierarchical pattern:

```
authority = [userinfo@]host[:port]
```

All three subcomponents are optional in the general syntax, though specific schemes may impose requirements. The authority appears in the overall URI structure as:

```
scheme://authority/path?query#fragment
```

### Syntax Rules

**Component boundaries:**

- Authority begins after `://` in absolute URIs
- Authority ends at the first `/`, `?`, `#`, or end of string
- Empty authority is valid: `scheme:///path` has an empty authority

**Character restrictions:**

- Must use percent-encoding for characters outside the allowed set
- Different subcomponents have different allowed character sets
- Reserved characters within authority: `@`, `:`, `[`, `]`

**Example:**

```
https://user:password@www.example.com:8080/path
       └──────────────authority─────────────┘
       └─userinfo─┘ └─────host──────┘ └port┘
```

## User Information Component (userinfo)

The userinfo subcomponent provides user authentication information. It appears before the host and is delimited by an `@` symbol.

### Syntax

```
userinfo = username[:password]
```

The userinfo is optional and deprecated in modern web contexts due to security concerns.

**Allowed characters (unreserved + sub-delims):**

```
A-Z a-z 0-9 - . _ ~ ! $ & ' ( ) * + , ; =
```

Any other characters must be percent-encoded.

### Username

The username portion identifies the user attempting to access the resource.

**Example:**

```
ftp://john.doe@ftp.example.com/files
    └username┘
```

**Percent-encoding example:**

```
Original: user@email
Encoded:  user%40email

Complete URI: ftp://user%40email@ftp.example.com/
```

### Password

The password portion follows the username and is separated by a colon.

**Example:**

```
ftp://john:secret123@ftp.example.com/files
    └user┘ └password┘
```

**Multiple colons:** If the password contains colons, only the first colon separates username from password:

```
ftp://user:pass:word@example.com
    └user┘ └password─┘
```

### Security Concerns and Deprecation

**Critical security issues:**

**Plain-text transmission:** Credentials appear in plain text in the URI, visible in browser history, logs, and referrer headers.

**Shoulder surfing:** Credentials are visible in the address bar.

**Server logs:** URLs with credentials are often logged on servers and intermediate proxies.

**Referrer leakage:** Credentials can be leaked through HTTP Referer headers when navigating to external sites.

**Browser storage:** URLs with credentials may be stored in browser history and bookmarks.

**Modern browser behavior:**

- Most browsers display warnings for userinfo in HTTP(S) URLs
- Some browsers strip userinfo from display
- Many browsers block userinfo in HTTP(S) URLs entirely for security

**Example of warning:**

```
http://user:pass@example.com/
// Modern browsers may show: "This site is trying to load an unsafe URL"
```

**[Inference] Recommended alternatives:**

- HTTP authentication headers (Basic, Digest, Bearer tokens)
- Form-based authentication with secure cookies
- OAuth 2.0 flows
- API keys passed in headers or query parameters
- Client certificates

### Legacy Use Cases

**Still encountered in:**

- FTP URLs (though GUI clients typically handle credentials separately)
- Legacy database connection strings
- Internal tools and scripts (where URLs aren't exposed)
- Documentation and examples (often with placeholder values)

**Example database connection:**

```
postgresql://dbuser:dbpassword@localhost:5432/mydb
```

**Note:** Even in these contexts, consider environment variables or configuration files instead.

### Parsing Userinfo

**Algorithm for extracting userinfo:**

1. Locate the `@` symbol in the authority
2. If no `@` exists, there is no userinfo
3. If `@` exists, everything before it is userinfo
4. Within userinfo, split on first `:` to separate username and password

**Example parsing:**

```
Input: user%40domain:p%40ss@example.com:8080

Steps:
1. Find @: position 22
2. Userinfo: "user%40domain:p%40ss"
3. Split on first :: username="user%40domain", password="p%40ss"
4. Decode: username="user@domain", password="p@ss"
```

**Edge cases:**

**Multiple @ symbols:** The last `@` separates userinfo from host:

```
user@email:pass@example.com
└────userinfo────┘ └─host──┘
```

**Empty password:**

```
user:@example.com
// username="user", password=""
```

**Empty username:**

```
:password@example.com
// username="", password="password"
```

**Only username:**

```
user@example.com
// username="user", no password
```

## Host Component

The host subcomponent identifies the specific host machine or service within the authority's namespace. It is the only mandatory part of the authority for most schemes.

### Host Types

The host can be specified in three formats:

**DNS/registered name:** Domain names and other registered identifiers

```
example.com
subdomain.example.org
localhost
my-server
```

**IPv4 address:** Dotted-decimal notation

```
192.168.1.1
127.0.0.1
10.0.0.255
```

**IPv6 address:** Hexadecimal notation enclosed in brackets

```
[2001:db8::1]
[::1]
[fe80::1%eth0]
```

### DNS Names and Registered Names

A registered name consists of labels separated by dots, following DNS naming conventions.

**Syntax rules (RFC 3986):**

- Labels contain letters, digits, hyphens
- Labels cannot start or end with hyphen
- Labels are case-insensitive
- Maximum label length: 63 characters
- Maximum total length: 253 characters

**Example:**

```
http://www.example.com/
http://api-v2.staging.example.org/
http://EXAMPLE.COM/  // Equivalent to example.com
```

**Percent-encoding in hosts:** Hosts generally use limited character sets, but percent-encoding is allowed for internationalized domain names (IDN) processing:

```
http://ex%61mple.com/  // Decodes to example.com
```

**Special characters:** Per RFC 3986, hosts allow unreserved characters and sub-delimiters, but not the general delimiters `:`, `/`, `?`, `#`, `[`, `]`, `@`

### Internationalized Domain Names (IDN)

Domain names containing non-ASCII Unicode characters require special encoding.

**Encoding process (Punycode):**

1. Unicode domain name provided by user
2. Converted to ASCII using IDNA (Internationalized Domain Names in Applications)
3. Each label with Unicode characters gets `xn--` prefix
4. Unicode characters encoded as ASCII string

**Example:**

```
Original: http://münchen.de/
Encoded:  http://xn--mnchen-3ya.de/

Original: http://例え.jp/
Encoded:  http://xn--r8jz45g.jp/
```

**Mixed scripts:**

```
http://中国.中国/
Encoded: http://xn--fiqs8s.xn--fiqs8s/
```

**Browser behavior:** Modern browsers typically display the decoded Unicode form in the address bar while transmitting the encoded form.

### IPv4 Addresses

IPv4 addresses consist of four decimal octets separated by dots.

**Standard format:**

```
192.168.1.1
10.0.0.0
172.16.254.1
127.0.0.1
```

**Value ranges:**

- Each octet: 0-255
- Total: 2^32 possible addresses (4,294,967,296)

**Example in URI:**

```
http://192.168.1.1/admin
http://127.0.0.1:8080/
ftp://10.0.0.5/files
```

**Leading zeros:** RFC 3986 allows leading zeros, but interpretation varies:

```
http://192.168.001.001/
```

Some systems interpret leading zeros as octal notation, causing ambiguity. **[Inference] Modern practice avoids leading zeros.**

**Alternative formats:** Some systems accept non-standard IPv4 formats (not in RFC 3986):

- Decimal: `3232235777` (representing 192.168.1.1)
- Octal: `0300.0250.0001.0001`
- Hexadecimal: `0xC0.0xA8.0x01.0x01`

**Note:** [Unverified] These alternative formats are not universally supported and should be avoided for interoperability.

**Localhost and loopback:**

```
http://127.0.0.1/  // IPv4 loopback
http://localhost/   // DNS name that resolves to 127.0.0.1
```

### IPv6 Addresses

IPv6 addresses use 128-bit addressing with hexadecimal notation and must be enclosed in brackets within URIs.

**Standard format:**

```
[2001:0db8:0000:0000:0000:0000:0000:0001]
```

**Compressed format:** Consecutive zero groups can be replaced with `::` (once per address):

```
[2001:db8::1]
[::1]  // Loopback address
[::ffff:192.0.2.1]  // IPv4-mapped IPv6 address
```

**Example in URI:**

```
http://[2001:db8::1]/
http://[2001:db8::1]:8080/path
https://[fe80::1%eth0]/  // With zone identifier
```

**Zone identifiers:** Link-local addresses may include a zone identifier (network interface) after a percent sign:

```
[fe80::1%eth0]
[fe80::1%25en0]  // %25 is percent-encoded %
```

**Bracket requirement:** Brackets are mandatory to distinguish the colons in the IPv6 address from the port separator:

```
Correct: http://[2001:db8::1]:80/
Wrong:   http://2001:db8::1:80/  // Ambiguous
```

**IPv4-mapped IPv6:**

```
[::ffff:192.0.2.1]
[::ffff:c000:0201]  // Same address in hex
```

**Parsing challenges:**

**Double colon placement:** Only one `::` allowed per address

```
Valid:   [2001:db8::1]
Invalid: [2001::db8::1]
```

**Group limits:** Maximum 8 groups of 4 hex digits

```
Valid:   [2001:db8:0:0:0:0:0:1]
Invalid: [2001:db8:0:0:0:0:0:0:1]  // 9 groups
```

**Mixed notation:**

```
[2001:db8::192.0.2.1]  // Last 32 bits in IPv4 notation
```

### Localhost Representations

**IPv4 loopback:**

```
127.0.0.1
127.0.0.0/8  // Entire range
```

**IPv6 loopback:**

```
::1
```

**DNS name:**

```
localhost
```

**Example URIs:**

```
http://localhost/
http://127.0.0.1/
http://[::1]/
```

### Host Normalization

Host normalization ensures consistent representation for comparison.

**Case normalization:** DNS names are case-insensitive and should be normalized to lowercase:

```
HTTP://EXAMPLE.COM/ → http://example.com/
http://Example.Com/ → http://example.com/
```

**Percent-encoding normalization:** Decode percent-encoded characters that are in the unreserved set:

```
http://ex%61mple.com/ → http://example.com/
```

**IPv6 compression:** Apply standard compression rules:

```
[2001:0db8:0000:0000:0000:0000:0000:0001] → [2001:db8::1]
```

**IDN normalization:** Ensure consistent Punycode encoding:

```
http://münchen.de/ → http://xn--mnchen-3ya.de/
```

### Empty Host

Some URI schemes allow empty hosts:

**File scheme:**

```
file:///path/to/file  // Empty host, local file
file://host/path      // Named host
```

**Custom schemes:**

```
custom:///resource    // Scheme-dependent interpretation
```

## Port Component

The port subcomponent specifies the network port for connection. It appears after the host, separated by a colon.

### Syntax

```
port = *DIGIT
```

The port consists of zero or more decimal digits.

**Example:**

```
http://example.com:8080/
              └──port──┘
```

### Port Ranges

**Valid range:** 0-65535 (16-bit unsigned integer)

**Reserved ports:** 0-1023 (well-known ports, often require elevated privileges)

**Registered ports:** 1024-49151 (registered with IANA)

**Dynamic/private ports:** 49152-65535 (ephemeral ports)

**Example:**

```
http://example.com:80/      // Valid
http://example.com:8080/    // Valid
http://example.com:65535/   // Valid, maximum
http://example.com:65536/   // Invalid, exceeds range
```

### Default Ports

Each URI scheme defines a default port used when no port is specified.

**Common default ports:**

```
http://     → port 80
https://    → port 443
ftp://      → port 21
ssh://      → port 22
smtp://     → port 25
ws://       → port 80
wss://      → port 443
```

**Example:**

```
http://example.com/
// Equivalent to: http://example.com:80/

https://example.com/
// Equivalent to: https://example.com:443/
```

### Port Normalization

When a port matches the scheme's default, it should be omitted during normalization:

**Example:**

```
http://example.com:80/   → http://example.com/
https://example.com:443/ → https://example.com/
ftp://example.com:21/    → ftp://example.com/
```

**Non-default ports are preserved:**

```
http://example.com:8080/   // Not normalized
https://example.com:8443/  // Not normalized
```

### Empty Port

A colon without following digits represents an empty port:

```
http://example.com:/path
              └empty┘
```

**RFC 3986 behavior:** Empty port is syntactically valid.

**WHATWG behavior:** [Inference] Empty port typically treated as omitted, using default port.

**Example:**

```
http://example.com:/
// RFC 3986: Valid with empty port
// WHATWG: Treated as http://example.com/
```

### Port Parsing

**Algorithm:**

1. Locate the last colon in the authority
2. If colon precedes IPv6 brackets, it's part of the IPv6 address
3. Everything after the last colon (outside brackets) is the port
4. Parse as decimal integer
5. Validate range (0-65535)

**Example parsing:**

```
http://example.com:8080/path

1. Find last colon: position 18
2. No brackets involved
3. Port string: "8080"
4. Parse: 8080
5. Valid (0 ≤ 8080 ≤ 65535)
```

**IPv6 edge case:**

```
http://[2001:db8::1]:8080/

1. Find last colon: position 20 (after brackets)
2. Colon at position 7, 12, 15 are inside brackets
3. Port string: "8080"
4. Parse: 8080
5. Valid
```

### Leading Zeros in Ports

**RFC 3986:** Allows leading zeros, interprets as decimal

```
http://example.com:0080/  // Port 80
```

**Normalization:** Leading zeros should be removed

```
http://example.com:0080/ → http://example.com:80/
                         → http://example.com/  (default port)
```

**Note:** Unlike IPv4 addresses, ports are always interpreted as decimal, never octal, even with leading zeros.

### Port in Different Contexts

**Web browsers:**

```
http://example.com:8080/
https://localhost:3000/
```

**Database connections:**

```
postgresql://localhost:5432/mydb
mysql://host:3306/database
mongodb://localhost:27017/
```

**API endpoints:**

```
http://api.example.com:8080/v1/users
https://service.example.com:443/api  // Explicit default
```

**WebSocket connections:**

```
ws://example.com:8080/socket
wss://example.com:443/socket
```

### Port Security Considerations

**Privileged ports (0-1023):** On Unix-like systems, binding to these ports typically requires root privileges.

**Firewall rules:** Many networks restrict which ports can be accessed. Common allowed ports: 80, 443, 8080, 8443.

**Port scanning:** Exposing non-standard ports may invite port scanning attacks.

**Well-known port conflicts:** Using well-known ports for non-standard services can cause confusion:

```
http://example.com:22/  // HTTP on SSH port (confusing)
```

**[Inference] Best practices:**

- Use standard ports for standard services
- Document non-standard port usage clearly
- Implement proper firewall rules
- Avoid exposing unnecessary ports
- Use HTTPS (443) for sensitive services

## Authority Parsing Algorithm

### Complete Parsing Process

**Step-by-step algorithm:**

1. **Extract authority from URI:**
    
    - Locate `://` after scheme
    - Authority ends at first `/`, `?`, `#`, or end of string
2. **Check for userinfo:**
    
    - Scan for `@` symbol
    - If found, everything before last `@` is userinfo
    - Split userinfo on first `:` into username and password
3. **Identify host boundaries:**
    
    - If `[` present, host is IPv6 (extract up to matching `]`)
    - Otherwise, host extends from start (or after `@`) to `:` or end
4. **Parse host:**
    
    - IPv6: Validate bracket-enclosed address
    - IPv4: Validate dotted-decimal format
    - DNS: Validate registered name syntax
5. **Extract port:**
    
    - Locate colon after host (after `]` for IPv6)
    - Parse remaining digits as port number
    - Validate range (0-65535)
6. **Percent-decode components:**
    
    - Decode userinfo if present
    - Decode host (except IPv6 literals)
    - Port is not percent-encoded

### Parsing Example

**Input:**

```
https://user%40email:p%40ss@[2001:db8::1]:8080/path
```

**Parsing steps:**

```
1. Extract authority:
   "user%40email:p%40ss@[2001:db8::1]:8080"

2. Find @ at position 22:
   userinfo = "user%40email:p%40ss"
   host+port = "[2001:db8::1]:8080"

3. Split userinfo on first ::
   username = "user%40email"
   password = "p%40ss"

4. Host starts with [:
   IPv6 = "2001:db8::1"
   Remaining = ":8080"

5. Port after ]:
   port = "8080"

6. Decode:
   username = "user@email"
   password = "p@ss"
   host = "2001:db8::1" (no decoding for IPv6)
   port = 8080
```

## Authority Comparison and Equivalence

### Normalization for Comparison

**Case normalization:**

```
HTTP://EXAMPLE.COM:80/
http://example.com:80/
http://example.com/
// All equivalent
```

**Percent-encoding normalization:**

```
http://ex%61mple.com/
http://example.com/
// Equivalent
```

**Port normalization:**

```
http://example.com:80/
http://example.com/
// Equivalent
```

**IPv6 normalization:**

```
http://[2001:0db8:0000:0000:0000:0000:0000:0001]/
http://[2001:db8::1]/
// Equivalent
```

### Equivalence Rules

Two authorities are equivalent if, after normalization:

- Schemes match (case-insensitive)
- Hosts match (case-insensitive for DNS, literal for IP)
- Ports match (considering defaults)
- Userinfo matches (if present, case-sensitive)

**Example equivalence:**

```
Equivalent:
- http://EXAMPLE.COM:80/
- http://example.com/
- http://example.com:80/

Not equivalent:
- http://example.com/
- https://example.com/  (different scheme)
- http://example.com:8080/  (different port)
```

## WHATWG URL Standard Differences

### WHATWG Authority Handling

**Special schemes enforcement:** For special schemes (http, https, ws, wss, ftp, file), WHATWG requires non-empty host (except file:).

**Example:**

```javascript
new URL('http:///path');
// Throws TypeError: invalid URL (empty host)

new URL('custom:///path');
// Valid (non-special scheme)
```

**Default port handling:** WHATWG automatically omits default ports:

```javascript
const url = new URL('http://example.com:80/');
console.log(url.port);  // "" (empty string)
console.log(url.href);  // "http://example.com/"
```

**Case normalization:** WHATWG automatically lowercases hosts:

```javascript
const url = new URL('http://EXAMPLE.COM/');
console.log(url.hostname);  // "example.com"
```

### Username and Password Properties

**WHATWG URL API provides separate properties:**

```javascript
const url = new URL('http://user:pass@example.com/');

console.log(url.username);  // "user"
console.log(url.password);  // "pass"
console.log(url.host);      // "example.com" (without userinfo)
console.log(url.hostname);  // "example.com" (without port)
console.log(url.port);      // ""

// Modification
url.username = "newuser";
url.password = "newpass";
// Result: http://newuser:newpass@example.com/
```

**Automatic percent-encoding:**

```javascript
const url = new URL('http://example.com/');
url.username = "user@email";
console.log(url.username);  // "user%40email"
console.log(url.href);      // "http://user%40email@example.com/"
```

### Host vs Hostname Properties

**WHATWG distinguishes between `host` and `hostname`:**

**hostname:** Host without port **host:** Host with port (if non-default)

```javascript
const url = new URL('http://example.com:8080/');

console.log(url.hostname);  // "example.com"
console.log(url.host);      // "example.com:8080"
console.log(url.port);      // "8080"
```

**With default port:**

```javascript
const url = new URL('http://example.com:80/');

console.log(url.hostname);  // "example.com"
console.log(url.host);      // "example.com" (port omitted)
console.log(url.port);      // "" (empty)
```

### IPv6 Bracket Handling

**WHATWG includes brackets in host property:**

```javascript
const url = new URL('http://[2001:db8::1]:8080/');

console.log(url.hostname);  // "[2001:db8::1]" (with brackets)
console.log(url.host);      // "[2001:db8::1]:8080"
console.log(url.port);      // "8080"
```

## Practical Applications

### URL Construction

**Building URLs programmatically:**

```javascript
function buildAPIURL(config) {
  const url = new URL(`https://${config.host}`);
  
  if (config.port && config.port !== 443) {
    url.port = config.port;
  }
  
  if (config.username && config.password) {
    url.username = config.username;
    url.password = config.password;
  }
  
  url.pathname = config.path;
  
  return url.href;
}

// Usage
buildAPIURL({
  host: 'api.example.com',
  port: 8080,
  path: '/v1/users'
});
// Result: https://api.example.com:8080/v1/users
```

### Host Validation

**Validating user input:**

```javascript
function isValidHost(hostString) {
  // Try to parse as URL
  try {
    const url = new URL(`http://${hostString}/`);
    return true;
  } catch {
    return false;
  }
}

// IPv4 validation
function isIPv4(host) {
  const ipv4Regex = /^(\d{1,3}\.){3}\d{1,3}$/;
  if (!ipv4Regex.test(host)) return false;
  
  return host.split('.').every(octet => {
    const num = parseInt(octet, 10);
    return num >= 0 && num <= 255;
  });
}

// IPv6 validation
function isIPv6(host) {
  return host.startsWith('[') && 
         host.endsWith(']') && 
         host.includes(':');
}
```

### Port Extraction

**Extracting effective port (considering defaults):**

```javascript
function getEffectivePort(url) {
  const urlObj = new URL(url);
  
  if (urlObj.port) {
    return parseInt(urlObj.port, 10);
  }
  
  // Return default port for scheme
  const defaultPorts = {
    'http:': 80,
    'https:': 443,
    'ftp:': 21,
    'ws:': 80,
    'wss:': 443
  };
  
  return defaultPorts[urlObj.protocol] || null;
}

// Usage
getEffectivePort('http://example.com/');      // 80
getEffectivePort('https://example.com:8443/'); // 8443
```

### Security Filtering

**Blocking unsafe authority patterns:**

```javascript
function isSafeAuthority(urlString) {
  try {
    const url = new URL(urlString);
    
    // Block userinfo in web URLs
    if (['http:', 'https:'].includes(url.protocol)) {
      if (url.username || url.password) {
        return false;
      }
    }
    
    // Block private IP ranges (example)
    if (url.hostname.startsWith('192.168.') ||
        url.hostname.startsWith('10.') ||
        url.hostname === 'localhost' ||
        url.hostname === '127.0.0.1') {
      return false;
    }
    
    // Block non-standard ports for HTTP/HTTPS
    const port = parseInt(url.port, 10);
    if (port && (port < 80 || port > 65535)) {
      return false;
    }
    
    return true;
  } catch {
    return false;
  }
}
```

## Testing Considerations

### Test Cases for Authority Parsing

**Comprehensive test coverage should include:**

**Valid authorities:**

```javascript
test('parses complete authority', () => {
  const url = new URL('http://user:pass@example.com:8080/');
  expect(url.username).toBe('user');
  expect(url.password).toBe('pass');
  expect(url.hostname).toBe('example.com');
  expect(url.port).toBe('8080');
});
```

**Edge cases:**

```javascript
test('handles IPv6 with port', () => {
  const url = new URL('http://[2001:db8::1]:8080/');
  expect(url.hostname).toBe('[2001:db8::1]');
  expect(url.port).toBe('8080');
});

test('handles empty password', () => {
  const url = new URL('http://user:@example.com/');
  expect(url.username).toBe('user');
  expect(url.password).toBe('');
});

test('handles default port', () => {
  const url = new URL('http://example.com:80/');
  expect(url.port).toBe('');
  expect(url.href).toBe('http://example.com/');
});
```

**Invalid input:**

```javascript
test('rejects invalid port', () => {
  expect(() => new URL('http://example.com:99999/')).toThrow();
});

test('rejects empty host for http', () => {
  expect(() => new URL('http:///path')).toThrow();
});
```

**Percent-encoding:**

```javascript
test('handles encoded userinfo', () => {
  const url = new URL('http://user%40email:p%40ss@example.com/');
  expect(url.username).toBe('user%40email');
  expect(url.password).toBe('p%40ss');
});
```

**Normalization:**

```javascript
test('normalizes case', () => {
  const url = new URL('HTTP://EXAMPLE.COM/');
  expect(url.hostname).toBe('example.com');
  expect(url.protocol).toBe('http:');
});
```

### Important subtopics to explore further:

- **URI Resolution:** How relative URIs are resolved against base URIs, including complex edge cases with authority components
- **Security Headers:** How HTTP headers like Host, Origin, and Referer interact with authority components
- **Proxy and Gateway Handling:** How intermediaries process and modify authority information
- **DNS Resolution and Caching:** The interaction between URI authority and DNS lookup processes
- **Certificate Validation:** How TLS/SSL certificates validate against hostname in HTTPS URIs

---

## Structure of the Authority Component

The authority component follows the optional scheme and double-slash (//) and precedes the path. Its general structure is: `[userinfo@]host[:port]`

Each subcomponent serves a specific purpose in identifying and accessing the resource. The host is the only required element, while userinfo and port are optional.

The authority component is delimited by the first single slash (/), question mark (?), or hash (#) following the double slash, or by the end of the URL string. This structure allows clear separation of the authority from other URL components.

**Example:**

```
https://user:pass@example.com:8080/path?query#fragment
        └─────────┬─────────┘
            authority component
        └───┬───┘ └───┬──┘ └┬┘
        userinfo    host   port
```

## Userinfo Subcomponent

The userinfo subcomponent contains optional authentication credentials or user identification. It appears before the host and is delimited by an at sign (@). The format is typically `username:password` though the structure is not strictly defined by RFC 3986.

**Key Points:**

- Deprecated for security reasons in modern web contexts
- Exposures credentials in browser history, logs, and referrer headers
- Supported for backward compatibility but discouraged in practice
- Automatically stripped by some browsers for HTTP(S) URLs
- Still used in some non-web URI schemes like FTP

**Example:**

```
ftp://anonymous:guest@ftp.example.com/file.txt
    └────────┬────────┘
         userinfo

http://admin:secret@internal.example.com/admin
    └─────┬──────┘
      userinfo (deprecated usage)
```

The colon separator within userinfo is conventional but not mandated. Some schemes may use different formats. Percent-encoding must be applied to special characters within userinfo, including the at sign if it appears literally.

Modern authentication mechanisms prefer separate authentication headers (like HTTP Authorization), POST request bodies, or secure token-based systems rather than embedding credentials in URLs.

## Host Subcomponent

The host identifies the network location where the resource resides. It can take several forms: registered domain names, IPv4 addresses, IPv6 addresses (enclosed in brackets), or registered names that are not domain names.

The host subcomponent is case-insensitive and should be normalized to lowercase for comparison. It is the most critical part of the authority component as it determines where connection attempts are directed.

### Host Types and Validation

Different host types require different validation approaches. Domain names must conform to DNS rules and may include internationalized characters through Punycode encoding. IP addresses must match specific format requirements for their version. Some schemes allow opaque hosts that don't fit standard categories.

The WHATWG URL Standard categorizes hosts more specifically: domain (DNS domain names), IPv4 address (dotted decimal notation), IPv6 address (hexadecimal with colons), opaque host (scheme-dependent format), and empty host (allowed in some contexts like file: URLs).

## IPv4 Addresses

IPv4 addresses identify network hosts using 32-bit numeric addresses. In URLs, they appear in dotted decimal notation with four octets separated by periods.

### Standard Dotted Decimal Format

The standard IPv4 format uses four decimal numbers ranging from 0 to 255, separated by periods. Each number represents one octet (8 bits) of the 32-bit address.

**Example:**

```
http://192.168.1.1/
http://127.0.0.1:8080/
http://10.0.0.1/admin
https://172.16.254.1/
```

Each octet must be between 0 and 255 inclusive. Leading zeros are typically not allowed in standard notation but may be interpreted differently by legacy parsers. For example, "192.168.001.001" might be parsed as "192.168.1.1" by some implementations.

### Alternative IPv4 Formats

Several alternative IPv4 formats exist for historical reasons, though their use is discouraged in modern applications. These formats can create security vulnerabilities when parsers interpret them inconsistently.

Octal notation uses leading zeros to indicate octal (base-8) numbers. The address "0300.0250.0001.0001" equals "192.168.1.1" in decimal. This format is deprecated due to ambiguity and potential for parser confusion.

Hexadecimal notation uses "0x" prefix for base-16 numbers. The address "0xC0.0xA8.0x01.0x01" also represents "192.168.1.1". Mixed formats can combine decimal, octal, and hexadecimal octets.

Integer notation represents the entire address as a single 32-bit integer. The address "3232235777" equals "192.168.1.1". This format calculates as: (192 × 256³) + (168 × 256²) + (1 × 256) + 1.

**Example:**

```
http://192.168.1.1/          (standard decimal)
http://0300.0250.0001.0001/  (octal notation)
http://0xC0.0xA8.0x1.0x1/    (hexadecimal)
http://3232235777/           (integer notation)
```

All these formats can represent the same address, creating security issues when different components of a system parse them differently. A URL filter might block "192.168.1.1" but allow "3232235777", even though they reference the same host.

### IPv4 Address Validation

Proper IPv4 validation requires checking multiple criteria. Each octet must be a valid number between 0 and 255. The address must have exactly four octets. Leading zeros should be rejected or handled consistently. Alternative formats should be normalized or rejected based on security policy.

**Example validation logic:**

```
Valid:   192.168.1.1
Valid:   10.0.0.255
Invalid: 192.168.1.256  (octet exceeds 255)
Invalid: 192.168.1      (only three octets)
Invalid: 192.168.1.1.1  (five octets)
Ambiguous: 192.168.01.1 (leading zero - octal or decimal?)
```

Security-conscious applications should reject alternative formats entirely or normalize them explicitly before processing. The safest approach is accepting only standard dotted decimal notation with no leading zeros.

### Private and Special IPv4 Ranges

Certain IPv4 address ranges have special meanings and security implications. Private address ranges (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) are not routable on the public internet and typically reference internal networks.

Loopback addresses (127.0.0.0/8, typically 127.0.0.1) reference the local host. Link-local addresses (169.254.0.0/16) are self-assigned when DHCP fails. Multicast addresses (224.0.0.0/4) target multiple recipients simultaneously.

Server-Side Request Forgery (SSRF) protections must block or carefully validate requests to these ranges, as attackers may use them to access internal resources or probe network topology.

## IPv6 Addresses

IPv6 addresses use 128-bit identifiers to provide a vastly larger address space than IPv4. They appear in hexadecimal notation with eight groups of four hexadecimal digits separated by colons.

### Standard IPv6 Format

The full IPv6 format contains eight groups of four hexadecimal digits (0-9, a-f, case-insensitive) separated by colons. Each group represents 16 bits of the 128-bit address.

**Example:**

```
http://[2001:0db8:0000:0000:0000:0000:0000:0001]/
http://[2001:0db8:85a3:0000:0000:8a2e:0370:7334]/
```

IPv6 addresses in URLs must be enclosed in square brackets to avoid ambiguity with the port separator. Without brackets, the colons in the IPv6 address would be indistinguishable from the port delimiter.

**Example:**

```
http://[2001:db8::1]:8080/path
      └────┬────┘ └┬┘
      IPv6 addr  port
```

### IPv6 Compression Rules

IPv6 addresses can be compressed using specific rules to reduce length. Leading zeros in any group can be omitted, so "0db8" becomes "db8" and "0000" becomes "0".

One sequence of consecutive zero groups can be replaced with a double colon (::). This compression can only be used once per address to maintain unambiguous parsing. The double colon represents one or more groups of zeros.

**Example:**

```
Full:       2001:0db8:0000:0000:0000:0000:0000:0001
Compressed: 2001:db8::1

Full:       2001:0db8:0000:0042:0000:8a2e:0370:7334
Compressed: 2001:db8:0:42:0:8a2e:370:7334
Better:     2001:db8::42:0:8a2e:370:7334
Invalid:    2001:db8::42::7334  (double :: used twice)
```

The loopback address is typically written as `::1` (compressed from 0000:0000:0000:0000:0000:0000:0000:0001). The unspecified address is `::` (all zeros).

### IPv6 Zone Identifiers

Zone identifiers (scope IDs) specify the network interface for link-local addresses. They appear after a percent sign (%) following the IPv6 address. Zone identifiers are necessary when link-local addresses might be ambiguous across multiple interfaces.

**Example:**

```
http://[fe80::1%eth0]/
http://[fe80::1%25eth0]/  (percent-encoded in URLs)
```

In URL contexts, the percent sign in zone identifiers must itself be percent-encoded as "%25" to distinguish it from percent-encoding of other characters. The first example shows the conceptual format, while the second shows the actual URL representation.

### IPv4-Mapped IPv6 Addresses

IPv4-mapped IPv6 addresses embed IPv4 addresses within IPv6 format, facilitating dual-stack implementations. They use the format `::ffff:w.x.y.z` where w.x.y.z is the IPv4 address.

**Example:**

```
::ffff:192.168.1.1  (IPv4 192.168.1.1 mapped to IPv6)
::ffff:c0a8:0101    (same address, IPv4 in hex)
```

These addresses allow IPv6-only applications to communicate with IPv4 hosts. They're commonly used in network stacks but less common in user-facing URLs.

### IPv6 Address Validation

IPv6 validation requires checking format correctness, bracket enclosure in URLs, valid hexadecimal digits, correct use of compression (:: appears at most once), proper zone identifier encoding, and verification of special address ranges.

**Example validation cases:**

```
Valid:   [2001:db8::1]
Valid:   [::1]
Valid:   [fe80::1%25eth0]
Invalid: 2001:db8::1        (missing brackets in URL)
Invalid: [2001:db8:::1]     (malformed compression)
Invalid: [gggg::1]          (invalid hex digit 'g')
Invalid: [2001:db8::1%eth0] (unencoded % in zone ID)
```

### Special IPv6 Address Ranges

IPv6 includes several special address ranges with security implications. The loopback address (::1) references localhost. Link-local addresses (fe80::/10) are valid only on a single network segment. Unique local addresses (fc00::/7) are similar to IPv4 private addresses.

Multicast addresses (ff00::/8) target multiple recipients. Documentation addresses (2001:db8::/32) are reserved for examples and documentation. SSRF protections must account for these ranges in IPv6 contexts.

## Domain Names

Domain names provide human-readable labels for network resources, mapped to IP addresses through the Domain Name System (DNS). They consist of labels separated by periods, read from specific (left) to general (right).

### Domain Name Structure

A fully qualified domain name (FQDN) specifies the complete path from a specific host through all intermediate domains to the DNS root. It typically consists of a hostname, domain, and top-level domain (TLD).

**Example:**

```
www.example.com
└┬┘ └──┬──┘ └┬┘
 |     |     └── Top-level domain (TLD)
 |     └──────── Second-level domain (SLD)
 └────────────── Subdomain/hostname
```

Each label can contain letters (a-z, A-Z), digits (0-9), and hyphens (-). Labels cannot start or end with hyphens. Each label can be 1-63 characters long. The total FQDN length cannot exceed 253 characters including dots.

Domain names are case-insensitive, though preservation of case is recommended. "Example.COM", "example.com", and "EXAMPLE.com" all refer to the same domain.

### Label Restrictions

Individual domain labels must follow specific rules for validity. Labels cannot be empty (consecutive dots are invalid). Labels cannot exceed 63 octets in length. Labels cannot begin or end with hyphens. The total domain name with all labels and dots cannot exceed 253 characters.

**Example:**

```
Valid:   example.com
Valid:   sub-domain.example.com
Valid:   xn--nxasmq6b.example.com  (IDN in Punycode)
Invalid: example..com               (empty label)
Invalid: -example.com                (starts with hyphen)
Invalid: example-.com                (ends with hyphen)
Invalid: [very long label exceeding 63 characters].com
```

Labels consisting entirely of digits are valid, though they may be confused with IP addresses in some contexts. The label "123" is a valid domain label.

### Top-Level Domains

Top-level domains (TLDs) form the highest level of the domain name hierarchy. They fall into several categories with different governance and purposes.

Generic TLDs (gTLDs) include traditional domains (.com, .net, .org, .edu, .gov, .mil) and new gTLDs introduced since 2013 (.app, .blog, .shop, .tech, etc.). Country-code TLDs (ccTLDs) represent specific countries or territories (.us, .uk, .de, .jp, .ph, etc.).

Sponsored TLDs (sTLDs) are specialized domains with restrictions (.aero, .museum, .coop). Infrastructure TLD (.arpa) is reserved for technical infrastructure purposes.

Some ccTLDs like .tv (Tuvalu) and .io (British Indian Ocean Territory) are marketed for other purposes beyond their geographic designation.

### Subdomain Hierarchy

Subdomains create hierarchical structure within domain names. Organizations can create arbitrary subdomains under domains they control. Each level adds specificity and can be managed independently.

**Example:**

```
blog.marketing.example.com
└──┬──┘ └───┬────┘ └──┬──┘
   |        |         └── Second-level domain
   |        └──────────── Third-level domain
   └───────────────────── Fourth-level domain
```

Common subdomain patterns include service separation (www, mail, ftp), environment distinction (dev, staging, prod), geographic distribution (us, eu, asia), and functional organization (blog, shop, api, docs).

### Domain Name Validation

Validating domain names requires checking multiple criteria beyond basic syntax. Labels must conform to length and character restrictions. The overall length must not exceed limits. TLD must exist in the DNS (for strict validation). Labels should not contain homograph characters in security-sensitive contexts.

Domain validation complexity varies by use case. Syntax validation checks format correctness without network access. DNS validation performs lookups to verify domain existence. Security validation checks for suspicious patterns like IDN homographs.

**Example validation approaches:**

```
Syntax only:  example.com         ✓ (valid format)
              exam ple.com         ✗ (space in label)
              
DNS verified: existing-domain.com  ✓ (resolves)
              nonexistent12345.com ✗ (NXDOMAIN)

Security:     example.com          ✓ (safe)
              exаmple.com          ⚠ (Cyrillic 'а' - homograph)
```

### Internationalized Domain Names

Internationalized Domain Names (IDN) allow non-ASCII Unicode characters in domain names through ASCII-compatible encoding. The Punycode algorithm converts Unicode to ASCII while DNS infrastructure remains unchanged.

IDN-capable applications convert Unicode domain names to Punycode before DNS lookup and display Unicode to users while using Punycode internally.

**Example:**

```
Display:   münchen.de
Punycode:  xn--mnchen-3ya.de
DNS query: xn--mnchen-3ya.de

Display:   日本.jp
Punycode:  xn--wgv71a.jp
DNS query: xn--wgv71a.jp
```

All Punycode labels begin with "xn--" prefix to identify them as encoded international names. The remaining characters encode the Unicode string using the Punycode algorithm.

### IDN Security Considerations

IDN introduces security challenges through homograph attacks where visually similar characters create deceptive domain names. Attackers register domains using Unicode characters that look identical to legitimate domains.

**Example homograph scenarios:**

```
Legitimate:  google.com
Homograph:   gооgle.com  (Cyrillic о instead of Latin o)

Legitimate:  paypal.com
Homograph:   pаypal.com  (Cyrillic а instead of Latin a)

Legitimate:  apple.com
Homograph:   аpple.com   (Cyrillic а instead of Latin a)
```

Modern browsers implement protections including displaying Punycode for suspicious domains, restricting mixed-script domains, maintaining lists of confusable characters, requiring entire labels to be from single scripts (with exceptions), and highlighting unusual character combinations.

Users cannot reliably distinguish these visually, making technical protections essential. Applications handling domains should implement similar safeguards.

## Authority Parsing Rules

Parsing the authority component correctly requires handling multiple formats, edge cases, and ambiguities. Different standards and implementations approach parsing with varying levels of strictness.

### Basic Parsing Algorithm

Authority parsing begins after identifying the authority through the initial "//" sequence. The parser must identify boundaries between userinfo, host, and port subcomponents.

The algorithm proceeds by searching for delimiters that separate authority from subsequent components (/, ?, #, or end of string). Within the authority, identifying the @ symbol (rightmost occurrence for userinfo/host separation). Identifying the colon for host/port separation (complex with IPv6). Extracting and validating each subcomponent.

**Example parsing:**

```
URL: https://user:pass@example.com:443/path?query

Step 1: Identify authority start after https://
        → user:pass@example.com:443

Step 2: Find @ delimiter
        → userinfo: "user:pass"
        → remaining: "example.com:443"

Step 3: Find port delimiter (rightmost : not in brackets)
        → host: "example.com"
        → port: "443"
```

### Handling IPv6 in Authority

IPv6 addresses complicate authority parsing because they contain colons that could be confused with the port delimiter. Square brackets solve this ambiguity by enclosing the IPv6 address.

The parser must recognize square brackets as IPv6 indicators, extract everything between [ and ] as the IPv6 address, and look for port delimiter only after the closing bracket.

**Example:**

```
URL: http://[2001:db8::1]:8080/path

Parsing steps:
1. Detect [ indicating IPv6
2. Extract to matching ]: "2001:db8::1"
3. Find : after ] for port: "8080"

Result:
  host: "2001:db8::1" (IPv6)
  port: "8080"
```

Without brackets, parsing would fail: `http://2001:db8::1:8080/path` would be ambiguous—is "8080" part of the IPv6 address or the port?

### Userinfo Parsing Edge Cases

The userinfo component can create parsing ambiguities, particularly when @ symbols appear in passwords or usernames through percent-encoding.

The algorithm uses the rightmost @ symbol to separate userinfo from host. This handles @ symbols within userinfo if they're percent-encoded as %40.

**Example:**

```
URL: http://user@domain.com:pass@example.com/

Parsing:
  Rightmost @: splits at second @
  userinfo: "user@domain.com:pass"
  host: "example.com"

If username contains @:
  http://user%40domain.com:pass@example.com/
  userinfo: "user%40domain.com:pass"
  host: "example.com"
  Decoded username: "user@domain.com"
```

Multiple @ symbols without proper encoding create ambiguity. Implementations may differ in handling malformed inputs, making consistent encoding essential.

### Port Parsing and Validation

Port numbers are 16-bit unsigned integers ranging from 0 to 65535. The port subcomponent appears after a colon following the host.

Port parsing must distinguish port delimiters from other colons (especially in IPv6 addresses), validate numeric range (0-65535), handle empty port declarations, and recognize default ports for common schemes.

**Example:**

```
Valid:   example.com:80
Valid:   example.com:8080
Valid:   [2001:db8::1]:443
Invalid: example.com:70000      (exceeds 65535)
Invalid: example.com:abc        (non-numeric)
Special: example.com:           (empty port - may default)
```

Empty port strings (host followed by colon but no digits) are handled differently by various implementations. Some treat it as missing port, others as error. The WHATWG standard treats it as invalid for special schemes like HTTP.

### Default Ports and Normalization

Many URL schemes define default ports that are implied when no port is specified. For comparison and normalization, explicitly specified default ports should be equivalent to missing ports.

**Common default ports:**

```
http://    → 80
https://   → 443
ftp://     → 21
ws://      → 80
wss://     → 443
```

**Normalization examples:**

```
http://example.com:80/  → http://example.com/
https://example.com/    (already normalized)
https://example.com:443/ → https://example.com/
ftp://example.com:21/   → ftp://example.com/
```

Normalized URLs with default ports omitted are considered equivalent to URLs with explicit default ports for caching, comparison, and security policy enforcement.

### Empty Authority Components

Some URL schemes allow empty or missing authority components. The file: scheme often uses empty authority (`file:///path`), indicating local filesystem. Some schemes allow missing authority entirely.

**Example:**

```
file:///C:/path/file.txt     (empty authority)
mailto:user@example.com      (no authority)
data:text/plain,Hello        (no authority)
about:blank                  (no authority)
```

HTTP and HTTPS require non-empty authorities. The WHATWG standard defines "special schemes" that mandate authorities with specific validation rules.

### Handling Malformed Authority

Real-world URLs often contain malformed authority components due to user error, legacy systems, or malicious intent. Implementations must decide between strict validation (rejecting invalid input) and lenient parsing (attempting best-effort interpretation).

Security-sensitive contexts should prefer strict validation to prevent bypasses. User-facing applications might use lenient parsing with validation warnings. Different components of a system should use consistent parsing to avoid security issues.

**Example malformed authorities:**

```
http://example.com::8080/    (double colon)
http://example .com/         (space in host)
http://[::1:8080/            (missing bracket)
http://user@:pass@host.com/  (malformed userinfo)
```

These should generally be rejected rather than attempting creative interpretation, as inconsistent parsing across systems creates vulnerabilities.

### WHATWG Authority Parsing

The WHATWG URL Standard defines precise authority parsing as a state machine. It handles special schemes (http, https, ws, wss, ftp, file) with specific validation requirements and opaque schemes with different rules.

The algorithm processes the authority character by character, transitioning between states based on input. States include authority state, host state, hostname state, port state, and special authority state.

**Key WHATWG behaviors:**

```
1. Special schemes require authority
2. Userinfo deprecated but parsed for http/https
3. IPv6 requires brackets
4. Empty hosts invalid for special schemes
5. Port must be valid number or empty
6. Specific error handling for each violation
```

The standard prioritizes matching existing browser behavior over strict RFC compliance, ensuring web compatibility while providing security through predictable parsing.

### RFC 3986 vs WHATWG Differences

RFC 3986 provides generic URI authority rules applicable to all schemes. It's more permissive about authority structure and leaves scheme-specific details to other specifications. It uses regular expressions for grammar definition.

WHATWG URL Standard specifies exact parsing algorithms for web URLs, provides deterministic behavior for edge cases, includes special handling for common schemes, and defines precise error conditions and recovery.

**Example difference:**

```
URL: http://example.com:99999/

RFC 3986: May parse "99999" as port (exceeds range)
WHATWG:   Parsing fails (port exceeds 65535)

URL: http://example.com:/path

RFC 3986: Allows empty port string
WHATWG:   Fails for special schemes
```

Applications should choose the appropriate standard based on their needs: WHATWG for web browser compatibility, RFC 3986 for generic URI handling across schemes.

## Security Implications of Authority Parsing

Inconsistent authority parsing between security components creates vulnerabilities. Attackers exploit parsing differences to bypass security controls.

### Parser Differential Attacks

When different parts of a system parse URLs differently, attackers craft URLs that bypass security checks but reach malicious destinations.

**Example attack scenario:**

```
URL: http://trusted.com@evil.com/

Security filter parsing:
  - Sees "trusted.com" as host
  - Allows request

Actual request parser:
  - Parses "trusted.com" as userinfo
  - Connects to "evil.com"
```

The security component and request component interpret the same URL differently, allowing the attacker to bypass the trust check.

### SSRF Through Authority Manipulation

Server-Side Request Forgery attacks often exploit authority parsing to access internal resources. Attackers use alternative IP formats, DNS rebinding, authority confusion, and URL parser discrepancies.

**Example SSRF techniques:**

```
Block bypass using integer notation:
  Blocked:  http://127.0.0.1/admin
  Allowed:  http://2130706433/admin  (same address)

DNS rebinding:
  Initial resolution:  attacker.com → 1.2.3.4 (allowed)
  Later resolution:    attacker.com → 127.0.0.1 (internal)

Authority confusion:
  http://127.0.0.1#@example.com/
  Depending on parser, may connect to localhost
```

Robust SSRF protection requires resolving domains to IP addresses before validation, blocking private IP ranges regardless of format, using consistent parsing across all components, and implementing request whitelisting rather than blacklisting.

### Open Redirect Vulnerabilities

Open redirects allow attackers to redirect users to arbitrary URLs. Authority component confusion amplifies these attacks.

**Example vulnerable code:**

```
// Unsafe: trusts user-provided URL
redirect_url = request.get_parameter('url')
if redirect_url.startswith('https://trusted.com'):
    redirect(redirect_url)

Attack:
  https://trusted.com@evil.com/phishing
  - Passes prefix check
  - Redirects to evil.com
```

Safe redirect handling requires parsing URLs completely before validation, verifying host component specifically, using allowlists of complete domains, and displaying interstitial warnings for external redirects.

### Credential Leakage Prevention

Userinfo components in URLs can leak credentials through various channels including browser history, server access logs, referrer headers, and network monitoring.

**Mitigation strategies:**

```
Input sanitization:
  Remove userinfo before logging
  Strip userinfo from displayed URLs
  Warn users about credential exposure

Technical controls:
  Use POST for credentials
  Implement proper authentication mechanisms
  Configure servers to not log userinfo
  Set referrer policies to prevent leakage
```

Modern security practices treat credentials in URLs as a vulnerability requiring remediation rather than a supported feature.

## Testing and Validation Strategies

Comprehensive testing ensures authority parsing handles both valid inputs correctly and invalid inputs safely. Test suites should cover standard cases, edge cases, security cases, and interoperability cases.

### Standard Cases

Basic authority formats must parse correctly for common scenarios. Testing should cover simple domains, domains with ports, IPv4 addresses with and without ports, IPv6 addresses in brackets with ports, authorities with subdomains, and missing port specifications.

**Example test cases:**

```
Input:  example.com
Expect: host="example.com", port=null

Input:  example.com:8080
Expect: host="example.com", port=8080

Input:  192.168.1.1:443
Expect: host="192.168.1.1", port=443

Input:  [2001:db8::1]:80
Expect: host="2001:db8::1", port=80

Input:  sub.example.com
Expect: host="sub.example.com", port=null
```

### Edge Cases

Edge case testing addresses uncommon but valid inputs and boundary conditions. This includes maximum length domains, single-character labels, numeric-only domains, IPv4 in various formats, compressed IPv6 addresses, and empty authority for appropriate schemes.

**Example edge case tests:**

```
Input:  a.b.c.d.e.f.g.h.i.j.example.com
Expect: valid (many subdomains)

Input:  1.2.3.4
Expect: valid IPv4 address

Input:  [::1]
Expect: valid IPv6 loopback

Input:  example.com:1
Expect: valid (minimum valid port)

Input:  example.com:65535
Expect: valid (maximum valid port)
```

### Invalid Input Handling

Testing must verify that invalid authorities are properly rejected or handled according to policy. Test missing closing bracket for IPv6, port exceeding 65535, negative port numbers, non-numeric ports, spaces in hostnames, double colons in wrong positions, and malformed IPv6 addresses.

**Example invalid input tests:**

```
Input:  [2001:db8::1:8080
Expect: error (missing bracket)

Input:  example.com:70000
Expect: error (port too large)

Input:  example.com:-1
Expect: error (negative port)

Input:  exam ple.com
Expect: error (space in host)

Input:  example..com
Expect: error (empty label)
```

### Security Test Cases

Security testing validates protections against attack patterns. Tests should include SSRF attempts with various IP formats, homograph domain names, credential injection attempts, parser differential inputs, redirect bypass attempts, and malicious userinfo components.

**Example security tests:**

```
Input:  http://trusted.com@attacker.com/
Expect: host="attacker.com" (not "trusted.com")

Input:  http://2130706433/
Expect: recognized as 127.0.0.1 (if blocking localhost)

Input:  http://xn--80ak6aa92e.com/
Expect: recognized as Cyrillic (IDN homograph detection)

Input:  http://0x7f.0x0.0x0.0x1/
Expect: recognized as 127.0.0.1 variant
```

### Cross-Implementation Testing

Testing across different parsers identifies compatibility issues. Compare parsing results between WHATWG-compliant browsers, RFC 3986-compliant libraries, language standard libraries, and web frameworks.

**Example cross-implementation test:**

```
URL: http://example.com:80/

Browser (WHATWG):
  - Normalizes to http://example.com/
  - Omits default port

Strict RFC parser:
  - May preserve port 80
  - Depends on normalization settings

Both should agree on:
  - host="example.com"
  - Semantic equivalence
```

Discrepancies indicate areas requiring careful handling in security-sensitive applications.

## Performance Considerations

Authority parsing performance impacts application responsiveness, especially when processing many URLs. Optimization strategies balance speed with correctness and security.

### Caching Parsed Results

Frequently processed URLs benefit from caching parsed authority components. Cache parsed authority by input string, include validation results, set appropriate cache size limits, and implement cache invalidation strategies.

**Example caching approach:**

```
cache = {}

def parse_authority(authority_string):
    if authority_string in cache:
        return cache[authority_string]
    
    result = expensive_parse_and_validate(authority_string)
    cache[authority_string] = result
    return result
```

Cache effectiveness depends on URL repetition patterns. Applications processing many unique URLs gain less benefit than those repeatedly processing the same URLs.

### Lazy Validation

Not all URL validation must occur immediately. Separate parsing from validation for performance, validate only when needed for security decisions, defer expensive checks (like DNS lookups), and validate incrementally as components are accessed.

**Example lazy approach:**

```
class Authority:
    def __init__(self, string):
        self._string = string
        self._parsed = None
        self._validated = None
    
    def get_host(self):
        if not self._parsed:
            self._parsed = self._parse()
        return self._parsed.host
    
    def validate_security(self):
        if not self._validated:
            self._validated = self._perform_validation()
        return self._validated
```

This approach parses only when components are actually used and performs expensive validation only when security requires it.

### Regular Expression vs State Machine

Parsing implementation choices affect performance. Regular expressions offer concise expression of patterns and easy maintenance for simple cases. State machines provide predictable performance, fine-grained control over parsing, and better error reporting.

**Performance characteristics:**

```
Regular Expression:
  + Faster for simple, well-formed input
  - Slower for complex or malformed input
  - May exhibit pathological backtracking
  
State Machine:
  + Consistent performance across inputs
  + Handles edge cases efficiently
  - More code to write and maintain
  + Precise error location reporting
```

The WHATWG standard uses state machines for predictability and exact behavior specification. Performance-critical applications benefit from state machine approaches.

### Precomputation and Constants

Certain validation checks can be precomputed. Use lookup tables for valid characters in different contexts, precompile regular expressions for repeated use, cache default port values for schemes, and maintain sets of blocked IP ranges for SSRF protection.

**Example precomputation:**

```
# Precomputed valid character sets
HOST_CHARS = set('abcdefghijklmnopqrstuvwxyz0123456789-.')
PORT_DIGITS = set('0123456789')

# Default ports
DEFAULT_PORTS = {
    'http': 80,
    'https': 443,
    'ftp': 21,
    'ws': 80,
    'wss': 443
}

# Blocked IP ranges (precomputed)
PRIVATE_RANGES = [
    ('10.0.0.0', '10.255.255.255'),
    ('172.16.0.0', '172.31.255.255'),
    ('192.168.0.0', '192.168.255.255')
]
```

Precomputation trades memory for CPU time, improving performance when the same validations occur repeatedly.

**Conclusion:**

The authority component serves as the foundation for locating and accessing resources across networks. Understanding its structure—userinfo, host, and port—and the specific formats for IPv4 addresses, IPv6 addresses, and domain names enables robust URL handling. Authority parsing rules vary between standards, with RFC 3986 providing generic URI guidance and the WHATWG URL Standard specifying precise web behavior. Security considerations around authority parsing are critical, as inconsistent handling creates vulnerabilities like SSRF, open redirects, and credential leakage. Comprehensive testing across standard cases, edge cases, and security scenarios ensures reliable parsing. Performance optimization through caching, lazy validation, and efficient algorithms maintains responsiveness in high-throughput applications.

---

# Host Component

## DNS Hostname Syntax

DNS hostnames follow specific syntax rules defined in RFC 1123, which updated the original RFC 952 specifications. These rules govern the formation of valid hostnames used in the host subcomponent of URIs.

**Character Set:**

```
hostname = *( label "." ) label
label = (ALPHA / DIGIT) *( (ALPHA / DIGIT / "-") (ALPHA / DIGIT) )
```

Valid characters include:

- Letters: A-Z, a-z (case-insensitive)
- Digits: 0-9
- Hyphen: - (not at start or end of label)

**Label Rules:**

Each label (segment between dots) must satisfy:

- Minimum length: 1 character
- Maximum length: 63 octets
- Must start with alphanumeric character
- Must end with alphanumeric character
- May contain hyphens in middle positions
- Cannot be all-numeric (except for IPv4 addresses)

**Examples of Valid Labels:**

```
example
example-site
a1b2c3
test-123-server
```

**Examples of Invalid Labels:**

```
-example        (starts with hyphen)
example-        (ends with hyphen)
ex@mple         (contains invalid character)
123.456.789     (appears as IPv4, but octets exceed 255)
a_label         (underscore not permitted in hostnames, though allowed in DNS generally)
```

**Total Hostname Length:**

The complete hostname, including all labels and dots, cannot exceed 253 octets in DNS wire format (255 octets total, minus 2 for encoding). When represented in ASCII form with dots, this typically means 253 characters maximum.

**Case Insensitivity:**

DNS hostnames are case-insensitive. The following are considered identical:

```
Example.COM
example.com
EXAMPLE.com
ExAmPlE.CoM
```

Standard normalization converts hostnames to lowercase for comparison and canonical representation.

**Internationalized Domain Names (IDN):**

Non-ASCII characters in domain names use Punycode encoding with the "xn--" prefix:

```
münchen.de           (Unicode representation)
xn--mnchen-3ya.de    (ASCII-compatible encoding)

日本.jp              (Unicode)
xn--wgv71a.jp        (Punycode)

παράδειγμα.gr        (Greek)
xn--hxajbheg2az3al.gr (Punycode)
```

The encoding process:

1. Unicode domain is normalized using Nameprep (RFC 3491)
2. Each label with non-ASCII characters is encoded using Punycode algorithm
3. Encoded labels receive "xn--" prefix
4. Result is ASCII-compatible encoding (ACE)

**Numeric Restrictions:**

While labels can contain digits, pure numeric labels (like "123") can create ambiguity with IPv4 addresses. Many systems and specifications impose additional restrictions:

```
example.123           (technically valid)
123.example.com       (valid, TLD distinguishes from IPv4)
192.168.1.1          (IPv4 address, not hostname)
```

## Domain Name Structure

Domain names form a hierarchical tree structure, read from right to left, with each level separated by dots. This hierarchy represents administrative delegation boundaries.

**Hierarchical Levels:**

```
subdomain.example.com.
    │       │      │  │
    │       │      │  └─ Root (implicit)
    │       │      └─── Top-Level Domain (TLD)
    │       └────────── Second-Level Domain (SLD)
    └────────────────── Third-Level Domain / Subdomain
```

### Fully Qualified Domain Names (FQDN)

An FQDN includes all levels up to the root, which is represented by a trailing dot:

```
www.example.com.     (FQDN with explicit root)
www.example.com      (FQDN with implicit root, common usage)
```

The trailing dot is typically omitted in user-facing contexts but is significant in DNS configuration files and certain technical contexts where it distinguishes absolute names from relative names.

### Administrative Boundaries

Each level in the hierarchy represents a delegation of administrative authority:

**Root Level:**

- Managed by ICANN and root server operators
- Delegates authority to TLD operators

**TLD Level:**

- Managed by registry operators
- Delegates authority to domain registrants or second-level registries

**Second-Level and Below:**

- Managed by domain owner
- Owner controls all subdomains
- DNS records define resolution behavior

### Domain Name Resolution Order

DNS queries resolve from right to left:

```
mail.support.example.com
         ↑       ↑      ↑
         │       │      └─ Query root servers for .com
         │       └──────── Query .com servers for example.com
         └──────────────── Query example.com servers for support.example.com
                           Query support.example.com servers for mail.support.example.com
```

Each level in the hierarchy can provide authoritative DNS servers for the next level.

### Public Suffix

The public suffix (or effective TLD) represents the boundary where domain registration occurs. This is not always the TLD:

```
example.com          (public suffix: .com)
example.co.uk        (public suffix: .co.uk)
example.github.io    (public suffix: .github.io)
example.s3.amazonaws.com (public suffix: .s3.amazonaws.com)
```

The Public Suffix List (maintained by Mozilla) catalogs these boundaries, which is important for:

- Cookie scope restrictions
- Certificate validation
- Security policies
- Organizational domain identification

### Reserved Domain Names

Certain domain names are reserved for special purposes:

**RFC 2606 Reserved TLDs:**

```
.test       (for testing purposes)
.example    (for documentation examples)
.invalid    (guaranteed to be invalid)
.localhost  (for local loopback)
```

**RFC 6761 Special-Use Domains:**

```
.local      (Multicast DNS)
.onion      (Tor hidden services)
.arpa       (infrastructure, reverse DNS)
```

**Reserved Second-Level Domains:**

```
example.com, example.net, example.org (documentation)
```

These should not be used for actual services or registered.

## Top-Level Domains (TLDs)

Top-level domains form the highest level of the domain name hierarchy. They are categorized into several types based on their purpose and administration.

### Generic Top-Level Domains (gTLDs)

Generic TLDs are not associated with specific countries and serve general purposes.

**Original gTLDs (created 1985-1988):**

```
.com    (commercial, unrestricted)
.net    (network infrastructure, unrestricted)
.org    (organizations, unrestricted)
.edu    (educational institutions, restricted to accredited institutions)
.gov    (US government, restricted)
.mil    (US military, restricted)
.int    (international organizations, restricted)
```

**Sponsored TLDs (sTLDs):**

Operated by specialized organizations with eligibility requirements:

```
.aero   (air transport industry)
.coop   (cooperatives)
.museum (museums)
.travel (travel industry)
.jobs   (employment-related sites)
.mobi   (mobile devices)
.xxx    (adult content)
.cat    (Catalan language/culture)
```

**New gTLDs (post-2013 expansion):**

ICANN's new gTLD program introduced hundreds of additional generic TLDs:

**Geographic/City TLDs:**

```
.london, .tokyo, .nyc, .paris, .berlin
```

**Brand TLDs:**

```
.google, .apple, .amazon, .microsoft
.bmw, .canon, .ford
```

**Generic Category TLDs:**

```
.app, .blog, .shop, .store, .news
.tech, .digital, .online, .website
.email, .cloud, .data
```

**Community/Interest TLDs:**

```
.music, .art, .film, .book
.bike, .golf, .ski, .fitness
.pizza, .coffee, .restaurant
```

### Country Code Top-Level Domains (ccTLDs)

Two-letter domains assigned to countries and territories based on ISO 3166-1 alpha-2 codes:

```
.us     (United States)
.uk     (United Kingdom)
.de     (Germany)
.jp     (Japan)
.cn     (China)
.fr     (France)
.au     (Australia)
.ca     (Canada)
```

**Special ccTLD Cases:**

Some ccTLDs have become generic due to marketing:

```
.tv     (Tuvalu, marketed for television/video)
.co     (Colombia, marketed as alternative to .com)
.io     (British Indian Ocean Territory, popular with tech startups)
.ai     (Anguilla, marketed for artificial intelligence)
.me     (Montenegro, marketed for personal sites)
```

**Internationalized ccTLDs (IDN ccTLDs):**

Country codes in native scripts:

```
.中国    (China in Chinese)
.рф      (Russia in Cyrillic)
.مصر     (Egypt in Arabic)
.ελ      (Greece in Greek)
```

### Infrastructure TLD

```
.arpa
```

The Address and Routing Parameter Area TLD is used exclusively for Internet infrastructure purposes:

**Reverse DNS:**

```
1.0.0.127.in-addr.arpa    (IPv4 reverse DNS)
1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.e.f.ip6.arpa
                           (IPv6 reverse DNS)
```

**Special Infrastructure Records:**

```
e164.arpa              (ENUM telephone number mapping)
uri.arpa               (URI resolution)
urn.arpa               (URN resolution)
```

### TLD Management and Policies

Each TLD has distinct registration policies:

**Open Registration:**

- No restrictions on who can register
- Examples: .com, .net, .org, .info

**Restricted Registration:**

- Eligibility requirements based on location, organization type, or purpose
- Examples: .edu (accredited educational institutions), .gov (US government)

**Closed/Private TLDs:**

- Controlled entirely by brand owner
- Not available for public registration
- Example: .google (used exclusively by Google)

**Reserved Second-Level Names:**

Many TLDs reserve certain second-level domains:

```
nic.tld        (registry information)
whois.tld      (WHOIS service)
www.tld        (TLD website)
```

## Subdomains

Subdomains are additional levels in the domain hierarchy beneath the registered domain. They exist at the third level and beyond, fully controlled by the domain owner.

### Subdomain Structure

```
level4.level3.example.com
  │      │       │
  │      │       └─── Registered domain (second-level)
  │      └─────────── First subdomain (third-level)
  └────────────────── Second subdomain (fourth-level)
```

There is no practical limit to subdomain depth, though DNS query limits and usability considerations typically restrict excessive nesting.

### Common Subdomain Patterns

**Service-based Subdomains:**

```
www.example.com        (web service)
mail.example.com       (email service)
ftp.example.com        (file transfer)
api.example.com        (API endpoint)
cdn.example.com        (content delivery)
blog.example.com       (blog service)
shop.example.com       (e-commerce)
```

**Environment-based Subdomains:**

```
dev.example.com        (development environment)
staging.example.com    (staging/testing)
qa.example.com         (quality assurance)
prod.example.com       (production, though often uses apex)
```

**Geographic Subdomains:**

```
us.example.com         (United States)
eu.example.com         (Europe)
asia.example.com       (Asia)
uk.example.com         (United Kingdom)
```

**Functional Subdomains:**

```
docs.example.com       (documentation)
support.example.com    (customer support)
status.example.com     (service status)
admin.example.com      (administrative interface)
portal.example.com     (user portal)
```

**User/Tenant Subdomains:**

```
user1.example.com      (individual user spaces)
tenant-a.example.com   (multi-tenant application)
company1.example.com   (organizational spaces)
```

### Wildcard Subdomains

DNS supports wildcard records that match any subdomain at a specific level:

```
*.example.com          (matches any direct subdomain)
*.mail.example.com     (matches any subdomain under mail.example.com)
```

**Wildcard Behavior:**

```
DNS Record: *.example.com → 192.0.2.1

Matches:
- anything.example.com
- test.example.com
- xyz.example.com

Does Not Match:
- example.com (apex/bare domain)
- sub.test.example.com (deeper level)
```

Wildcards only match one level unless multiple wildcard records are configured at different levels.

### Subdomain Management

**DNS Configuration:**

Subdomains are configured through DNS records in the parent domain's zone:

```
www.example.com.     IN A     192.0.2.1
mail.example.com.    IN A     192.0.2.2
*.api.example.com.   IN CNAME api-server.example.com.
```

**Delegation:**

Subdomains can be delegated to separate nameservers using NS records:

```
subdomain.example.com.  IN NS  ns1.subdomain.example.com.
subdomain.example.com.  IN NS  ns2.subdomain.example.com.
```

This transfers DNS authority for that subdomain to different nameservers, allowing independent management.

### Technical Considerations

**Cookie Scope:**

Cookies set on subdomains behave according to domain attribute rules:

```
Set on: sub.example.com
Cookie domain: .example.com
    → Accessible to all subdomains and example.com

Set on: sub.example.com  
Cookie domain: sub.example.com
    → Only accessible to sub.example.com
```

**SSL/TLS Certificates:**

Certificates can cover subdomains through different mechanisms:

**Single Subdomain:**

```
CN: www.example.com
    → Only covers www.example.com
```

**Wildcard Certificate:**

```
CN: *.example.com
    → Covers any direct subdomain (mail.example.com, api.example.com)
    → Does NOT cover example.com (apex) or deeper levels (sub.api.example.com)
```

**Multi-Domain Certificate (SAN):**

```
Subject Alternative Names:
- example.com
- www.example.com
- mail.example.com
- api.example.com
    → Explicitly listed domains only
```

### Subdomain Enumeration and Security

Subdomains can be discovered through:

**DNS Zone Transfer:**

```
AXFR request to authoritative nameserver
```

Most production nameservers disable zone transfers to non-authorized parties.

**DNS Brute Forcing:**

Attempting common subdomain names against target domain.

**Certificate Transparency Logs:**

Public logs reveal subdomains in issued certificates.

**Search Engine Indexing:**

Subdomains discovered through site: queries and web crawling.

**Security Implications:**

- Forgotten or abandoned subdomains may have vulnerabilities
- Subdomain takeover occurs when DNS points to unclaimed resources
- Wildcard subdomains increase attack surface
- Internal subdomains exposed publicly create information disclosure

### Subdomain Routing and Architecture

**Load Distribution:**

```
www1.example.com  →  192.0.2.1
www2.example.com  →  192.0.2.2
www3.example.com  →  192.0.2.3
```

Multiple subdomains can distribute load across servers, though round-robin DNS or load balancers on single subdomain are more common.

**Service Isolation:**

```
frontend.example.com  →  Public-facing application
backend.example.com   →  API services (internal only)
db.example.com        →  Database access (internal only)
```

Subdomains enable network segmentation and access control policies.

**Content Delivery:**

```
static.example.com    →  CDN for static assets
images.example.com    →  Image hosting service
videos.example.com    →  Video streaming service
```

Separating content types allows optimized caching, delivery, and security policies per subdomain.

**Key Points:**

- DNS hostname labels must be 1-63 octets, start/end with alphanumeric, and can contain hyphens in middle positions
- Complete hostnames cannot exceed 253 octets total length
- Domain hierarchy reads right to left: subdomain.example.com where .com is TLD, example.com is registered domain, subdomain is third-level
- TLDs include generic (.com, .org), country-code (.uk, .jp), sponsored (.edu, .gov), and new categories (.app, .tech, .london)
- Public suffixes define registration boundaries and may extend beyond TLD (.co.uk, .github.io)
- Subdomains are fully controlled by domain owner and configured through DNS records in parent zone
- Wildcard DNS records (*.example.com) match one level of subdomains but not apex or deeper levels
- Subdomain delegation using NS records transfers DNS authority to separate nameservers

---

## Internationalized Domain Names (IDN)

Internationalized Domain Names allow domain names to contain characters from non-ASCII scripts, enabling users to register and access domains in their native languages and writing systems. IDN support extends the Domain Name System beyond the original ASCII character limitation.

**Character Set Expansion:**

Traditional DNS hostnames are restricted to ASCII letters (a-z, A-Z), digits (0-9), and hyphens, with additional constraints on placement. IDNs permit characters from Unicode, including Latin characters with diacriticals (é, ñ, ü), Cyrillic script (кириллица), Arabic script (العربية), Chinese characters (中文), Japanese scripts (日本語), and numerous other writing systems.

**Protocol Compatibility:**

The DNS infrastructure operates on ASCII-based protocols that cannot directly process non-ASCII characters. IDNs employ an encoding mechanism to represent Unicode characters as ASCII-compatible strings, allowing seamless integration with existing DNS infrastructure without protocol modifications.

**Label Processing:**

Domain names consist of labels separated by dots. Each label in an IDN is processed independently. A domain like `例え.jp` contains two labels: `例え` (Unicode) and `jp` (ASCII). The Unicode label requires encoding while the ASCII label remains unchanged.

**Unicode Normalization:**

[Inference] Before encoding, IDN labels undergo Unicode normalization to ensure consistent representation. Different Unicode sequences can represent visually identical characters, and normalization resolves these variations to canonical forms.

**IDNA Standard:**

The Internationalized Domain Names in Applications (IDNA) specification defines the conversion between Unicode domain names and ASCII-compatible representations. The current standard is IDNA2008, which supersedes the earlier IDNA2003 specification. These standards define character validation, normalization procedures, and encoding requirements.

**Display vs. Protocol Forms:**

IDNs exist in two forms: the Unicode form displayed to users and the ASCII-encoded form used in DNS protocols. Applications must convert between these forms appropriately. Browsers display `münchen.de` to users but query DNS for the encoded equivalent.

**Security Considerations:**

IDNs introduce homograph attack risks where visually similar characters from different scripts create deceptive domain names. The Cyrillic 'а' (U+0430) appears identical to the Latin 'a' (U+0061) in many fonts. An attacker could register `pаypal.com` (with Cyrillic 'а') to mimic `paypal.com`. Browsers and registrars implement policies to mitigate these risks, including script mixing restrictions and visual warnings.

**Registry Policies:**

Top-level domain registries establish rules governing which characters are permitted in registrations under their domains. Some TLDs restrict registrations to specific scripts or implement bundling policies where visually similar variants are assigned to the same registrant.

## Punycode Encoding

Punycode is the ASCII-compatible encoding algorithm used to represent IDN labels in DNS. It transforms Unicode strings into ASCII strings prefixed with a distinctive marker.

**Encoding Marker:**

Punycode-encoded labels begin with the ASCII prefix `xn--` followed by the encoded representation. This prefix signals that the label contains encoded Unicode content. The label `münchen` becomes `xn--mnchen-3ya` when encoded.

**Encoding Algorithm:**

The Punycode algorithm separates ASCII and non-ASCII characters within a label. ASCII characters (basic code points) are preserved in their original form. Non-ASCII characters (extended code points) are encoded using a variable-length integer encoding scheme with positional insertion markers.

**Encoding Process:**

For the label `münchen`: The basic ASCII characters `m`, `n`, `c`, `h`, `e`, `n` are extracted, forming the base string `mnchen`. The non-ASCII character `ü` (U+00FC) is encoded with positional information. The position indicator and character code are compressed using base-36 encoding. The result combines as `xn--mnchen-3ya`, where `3ya` encodes the insertion of `ü` after the second character.

**Base-36 Encoding:**

Punycode uses base-36 (digits 0-9 and letters a-z) to represent encoded values compactly. The algorithm employs variable-length encoding where certain positions trigger threshold adjustments, optimizing for common cases while supporting arbitrary Unicode code points.

**Delimiter Function:**

When basic ASCII characters exist in the original label, a hyphen separates them from the encoded portion. In `xn--mnchen-3ya`, the final hyphen delimits `mnchen` (basic characters) from `3ya` (encoded insertion data). Labels containing only non-ASCII characters lack this delimiter.

**Decoding Process:**

Punycode decoding reverses the transformation. The decoder recognizes the `xn--` prefix, extracts basic characters before the final hyphen, interprets the encoded portion to determine insertion positions and code points, and reconstructs the Unicode string by inserting characters at specified positions.

**Case Insensitivity:**

Punycode encoding is case-insensitive. The encoded form uses lowercase letters, and decoders treat uppercase and lowercase equivalently. Domain name case-insensitivity extends to Punycode labels.

**Length Constraints:**

DNS labels are limited to 63 octets. Punycode-encoded labels must respect this constraint. Long Unicode labels may exceed the limit after encoding, making them invalid for DNS registration. The `xn--` prefix and encoding overhead reduce the effective capacity for Unicode characters.

**All-ASCII Labels:**

Labels containing only ASCII characters are not Punycode-encoded and do not receive the `xn--` prefix. The domain `example.com` remains unchanged rather than becoming `xn--example-xxxx.com`.

**Application Responsibilities:**

Applications displaying URIs must decode Punycode to present Unicode forms to users. Applications constructing DNS queries must encode Unicode labels to Punycode. Web browsers typically display decoded IDNs in the address bar while sending encoded forms in HTTP Host headers.

**Example Transformations:**

- `日本.jp` → `xn--wgv71a.jp`
- `الإمارات.ae` → `xn--mgbaam7a8h.ae`
- `москва.рф` → `xn--80adxhks.xn--p1ai`
- `café.fr` → `xn--caf-dma.fr`

## IP Addresses as Hosts

IP addresses can serve directly as host components in URIs, providing numeric addressing that bypasses domain name resolution. Both IPv4 and IPv6 address formats are supported with distinct syntax rules.

**IPv4 Address Format:**

IPv4 addresses appear in dotted-decimal notation consisting of four decimal octets separated by periods. Each octet represents 8 bits and ranges from 0 to 255. Valid examples include `192.168.1.1`, `10.0.0.1`, `172.16.254.1`, and `8.8.8.8`.

**IPv4 URI Examples:**

```
http://192.168.1.1/admin
https://10.0.0.50:8443/api
ftp://172.16.0.100/files
```

**IPv4 Syntax Constraints:**

The IPv4 address must contain exactly four octets. Each octet must be a decimal number without leading zeros (with the exception of the single digit `0`). Octet values exceeding 255 create invalid addresses. Spaces or other characters within the address are not permitted.

**IPv6 Address Format:**

IPv6 addresses use hexadecimal notation with eight 16-bit groups separated by colons. The address `2001:0db8:85a3:0000:0000:8a2e:0370:7334` demonstrates the full format. Zero compression allows consecutive zero groups to be replaced with `::`, appearing once per address: `2001:0db8:85a3::8a2e:0370:7334`.

**IPv6 URI Syntax:**

IPv6 addresses in URIs must be enclosed in square brackets to distinguish address colons from the port separator colon. Without brackets, parsers cannot determine where the address ends and the port begins.

**IPv6 URI Examples:**

```
http://[2001:db8::1]/page
https://[fe80::1%eth0]:8080/api
http://[::1]/localhost
ftp://[2001:db8:85a3::8a2e:370:7334]/
```

**Zone Identifier:**

IPv6 link-local addresses may include a zone identifier specifying the network interface. The zone ID follows a percent sign: `fe80::1%eth0`. In URIs, the percent sign must be percent-encoded as `%25`: `http://[fe80::1%25eth0]/`.

**IPv6 Zero Compression:**

The `::` notation replaces one or more consecutive groups of zeros. It may appear only once in an address. The loopback address `0000:0000:0000:0000:0000:0000:0000:0001` compresses to `::1`. The address `2001:db8:0:0:0:0:2:1` can be written as `2001:db8::2:1`.

**IPv4-Mapped IPv6 Addresses:**

IPv6 can represent IPv4 addresses using a hybrid notation. The format `::ffff:192.168.1.1` maps the IPv4 address into IPv6 space. In URIs: `http://[::ffff:192.168.1.1]/`.

**Leading Zero Omission:**

Within IPv6 groups, leading zeros may be omitted. The group `0db8` can be written as `db8`. The group `0000` can be written as `0` or omitted entirely through zero compression.

**Port Specification:**

Port numbers follow the closing bracket in IPv6 URIs. The syntax `[address]:port` maintains unambiguous parsing. Example: `http://[2001:db8::1]:8080/` specifies port 8080.

**Address Validation:**

[Inference] Applications parsing URIs with IP address hosts must validate address format correctness. Invalid formats should be rejected rather than misinterpreted. Validation includes verifying octet ranges for IPv4, hexadecimal group validity for IPv6, proper bracket usage for IPv6, and port number validity when present.

**Localhost Addresses:**

The IPv4 address `127.0.0.1` and IPv6 address `::1` designate the local host. URIs using these addresses reference services on the same machine: `http://127.0.0.1:3000/` and `http://[::1]:3000/`.

**Private Address Ranges:**

IPv4 defines private address ranges (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) for internal networks. IPv6 defines unique local addresses (fc00::/7) for similar purposes. URIs containing private addresses typically function only within the relevant network context.

## Localhost and Special Hostnames

Certain hostnames carry special meanings within network protocols and operating systems, representing local resources or reserved functions rather than resolvable domain names.

**Localhost Hostname:**

The hostname `localhost` conventionally resolves to the loopback interface, typically `127.0.0.1` for IPv4 and `::1` for IPv6. It references the local machine without requiring external network communication. URIs like `http://localhost:8000/` access services running on the same host.

**Loopback Address Range:**

The entire IPv4 range `127.0.0.0/8` (127.0.0.0 through 127.255.255.255) is reserved for loopback. Any address in this range routes to the local host. The address `127.0.0.1` is conventional, but `127.0.0.2` or `127.53.192.8` function identically.

**Localhost Resolution:**

Operating systems typically define `localhost` in the hosts file (`/etc/hosts` on Unix-like systems, `C:\Windows\System32\drivers\etc\hosts` on Windows) mapping it to loopback addresses. This mapping ensures `localhost` resolution without DNS queries.

**Domain Name Suffix:**

The `.localhost` top-level domain is reserved for local use. Names under this domain (like `app.localhost` or `test.localhost`) are guaranteed never to exist in the global DNS and always resolve to loopback addresses. This allows developers to use multiple local hostnames without conflicts.

**Special-Use Domain Names:**

RFC 6761 defines several special-use domain names with reserved meanings. The `.local` domain is reserved for multicast DNS (mDNS) in local networks. The `.invalid` domain is reserved for invalid names that will never resolve. The `.test` domain is reserved for testing purposes. The `.example`, `.example.com`, `.example.net`, and `.example.org` domains are reserved for documentation examples.

**Wildcard DNS:**

Some development tools configure wildcard DNS for subdomains of `localhost`. Services like `*.localhost` or `*.test` resolve to `127.0.0.1`, enabling developers to use multiple hostnames for local services without configuration.

**Zero Configuration Networking:**

The `.local` domain participates in zero-configuration networking (Zeroconf/Bonjour/mDNS). Hostnames like `printer.local` or `server.local` allow device discovery on local networks without DHCP or DNS servers. These names resolve via multicast queries on the local network segment.

**Link-Local Addressing:**

IPv6 link-local addresses (fe80::/10) facilitate communication on a single network link without global addressing. Combined with the `.local` domain, they enable local service discovery and communication.

**Private DNS Roots:**

Organizations may operate internal DNS infrastructure with private top-level domains not present in the global DNS. These internal domains function only within the organization's network. Examples might include `.corp`, `.internal`, or `.lan`, though RFC 6761 discourages creating new special-use domains without standardization.

**Hostname Validation:**

[Inference] Applications should recognize special hostnames and handle them appropriately. Requests to `localhost` should not trigger external DNS queries. Browsers may apply different security policies to localhost URIs compared to remote hosts.

**Development and Testing:**

Special hostnames facilitate development and testing workflows. Developers run local servers accessible via `http://localhost:3000/` or `http://app.localhost:8080/`. Testing frameworks use `.test` domains for test fixtures. Documentation uses `.example` domains in code samples.

**Security Implications:**

The localhost name and loopback addresses receive special security treatment in browsers. Mixed content restrictions may be relaxed, certain Web APIs may be available without HTTPS, and cookie scope rules may differ. [Inference] However, this special treatment applies specifically to recognized localhost names and loopback addresses, not arbitrary local network addresses.

**Host File Override:**

The hosts file allows manual hostname-to-address mappings that override DNS. Developers use this for testing production domains locally (`127.0.0.1 production.example.com`) or blocking unwanted domains (`0.0.0.0 ads.example.com`). These mappings affect URI resolution system-wide.

---

# Internationalized Domain Names (IDN)

## IDN Overview and Purpose

**Internationalized Domain Names (IDN)** are domain names that contain characters beyond the ASCII character set (a-z, 0-9, and hyphen). They enable internet users to register and use domain names in their native languages and scripts, including Chinese, Arabic, Cyrillic, Hebrew, Devanagari, and other writing systems.

Traditional DNS (Domain Name System) was designed in the early 1980s with ASCII-only restrictions. This limitation meant that billions of non-English speakers could only use domain names written in Latin characters, creating a significant barrier to internet accessibility and cultural representation.

IDNs address this limitation by allowing domain names to include:

- Non-Latin alphabets (Cyrillic, Greek, Arabic, Hebrew)
- CJK ideographs (Chinese, Japanese, Korean characters)
- Characters with diacritical marks (é, ñ, ü, ø)
- Scripts from various languages (Thai, Devanagari, Armenian)

**Technical Foundation:**

IDNs are defined primarily in **RFC 5890** through **RFC 5894**, collectively known as IDNA2008 (Internationalized Domain Names in Applications). The earlier standard, IDNA2003 (RFC 3490), has been superseded but some systems still reference it.

The core challenge IDNs solve is maintaining backward compatibility with existing DNS infrastructure while enabling Unicode characters. DNS protocols and systems expect ASCII-only labels, so IDNs use an encoding mechanism to represent Unicode characters in ASCII-compatible format.

**Key Components:**

**Unicode Representation**: Domain names as users see and input them, containing native script characters **ASCII Compatible Encoding (ACE)**: The encoded ASCII representation used in DNS queries and storage **Punycode**: The specific algorithm used to convert Unicode to ASCII **IDNA Protocol**: The complete system for processing and validating IDN strings

**Purpose and Benefits:**

**Cultural and Linguistic Inclusion**: Users can access the internet using their native scripts without requiring Latin character knowledge. This removes a significant barrier to digital literacy and internet adoption.

**Brand and Identity Representation**: Organizations can register domain names that accurately reflect their brands in local scripts, enhancing recognition and trust among native language speakers.

**Improved Usability**: Users can type domain names naturally in their preferred language without transliteration or memorization of Latin equivalents.

**Market Expansion**: Businesses can reach local markets more effectively with culturally appropriate domain names.

**Key Points:**

- IDNs enable domain names in any Unicode script
- Backward compatible with existing DNS infrastructure
- Require special encoding for DNS protocol compatibility
- Supported by all major web browsers and email clients
- Subject to specific validation rules to prevent confusion and security issues
- Over 150 scripts can be used in domain names

**Example:**

```
Traditional ASCII domain:
example.com

Chinese IDN (displayed):
例え.jp

Arabic IDN (displayed):
مثال.مصر

Russian IDN (displayed):
пример.рф

German IDN with umlaut:
müller.de

Hindi IDN:
उदाहरण.भारत
```

**Scope and Limitations:**

IDNs apply to domain names (second-level domains, subdomains, and top-level domains) but not to other URI components like paths, queries, or fragments. The email address local part (before @) has separate internationalization specifications under RFC 6531.

[Inference] Not all characters within Unicode are permitted in IDNs. The IDNA specification defines strict rules about which characters can be used to prevent visual confusion (homograph attacks), ensure technical compatibility, and maintain stability.

The implementation of IDNs represents a significant evolution in internet architecture, balancing technical constraints with the goal of making the internet truly global and accessible to speakers of all languages.

## Unicode Domain Names

**Unicode domain names** are domain names composed of characters from the Unicode Standard, which encompasses virtually all writing systems used in the world. Unicode provides a universal character encoding system that assigns a unique code point to each character across all languages.

The Unicode Standard (maintained by the Unicode Consortium) includes over 149,000 characters covering 159 modern and historic scripts. This comprehensive character set enables domain names to represent virtually any human language.

**Unicode Code Points:**

Each Unicode character is identified by a code point, typically written in hexadecimal notation with a "U+" prefix:

```
U+0041 = A (Latin capital letter A)
U+00E9 = é (Latin small letter e with acute)
U+4E2D = 中 (Chinese character for "middle")
U+0627 = ا (Arabic letter alef)
U+0410 = А (Cyrillic capital letter A)
U+0915 = क (Devanagari letter ka)
```

**Normalization:**

Unicode characters can sometimes be represented in multiple ways. For example, "é" can be encoded as:

- Single character: U+00E9 (precomposed form)
- Two characters: U+0065 + U+0301 (base letter + combining accent)

IDNA requires **Unicode Normalization Form C (NFC)**, which converts characters to their precomposed forms where possible. This ensures consistent representation and comparison of domain names.

**Character Categories:**

The Unicode Standard organizes characters into categories:

**Letters (L)**: Alphabetic characters from all scripts **Marks (M)**: Combining characters and diacritics **Numbers (N)**: Numeric digits from various scripts **Punctuation (P)**: Punctuation marks **Symbols (S)**: Various symbols **Separators (Z)**: Space and invisible separators

IDN specifications define which categories and specific characters are valid in domain names.

**IDNA Character Classes:**

IDNA2008 categorizes Unicode characters into classes that determine their validity in domain names:

**PVALID**: Characters always permitted in domain names

```
Examples:
- Latin letters: a-z, A-Z
- Arabic letters: ا ب ت
- Chinese characters: 中 文
- Cyrillic letters: а б в
```

**CONTEXTJ**: Characters permitted only in specific contexts (primarily zero-width joiner and non-joiner used in scripts like Arabic and Devanagari)

**CONTEXTO**: Characters permitted in specific contexts (middle dot, Greek lower numeral sign, Hebrew punctuation)

**DISALLOWED**: Characters never permitted in domain names

```
Examples:
- Control characters
- Whitespace (except specific exceptions)
- Certain punctuation
- Emoji (under IDNA2008)
- Symbols that could cause confusion
```

**UNASSIGNED**: Code points not yet assigned in Unicode (treated conservatively)

**Script Mixing Rules:**

[Inference] To prevent confusion and potential security issues, many registries implement policies restricting script mixing within a single domain label. Common approaches include:

**Single Script Policy**: Entire domain must use characters from one script **Limited Script Mixing**: Specific script combinations permitted (e.g., Latin + Han for Japanese) **Registry-Specific Rules**: Each TLD defines its own mixing policies

**Example:**

```
Permitted (single script):
münchen.de (all Latin with diacritics)
日本.jp (all Japanese)
москва.рф (all Cyrillic)

Potentially prohibited (mixed scripts):
exаmple.com (mixing Latin 'e' and Cyrillic 'а')
中国example.com (mixing Chinese and Latin)
```

**Right-to-Left Scripts:**

Scripts like Arabic and Hebrew write from right to left (RTL). When used in domain names, special handling ensures proper display:

```
Arabic domain: موقع.مصر
Displayed RTL: رصم.عقوم
(The domain visually appears right-to-left in RTL contexts)
```

Browsers and applications must implement bidirectional text algorithms (Unicode Bidirectional Algorithm) to correctly display mixed LTR and RTL content.

**Case Folding:**

Domain names are case-insensitive in ASCII, but Unicode introduces complexity. IDNA defines **case folding** rules that map uppercase characters to lowercase equivalents:

```
EXAMPLE.COM → example.com
MÜNCHEN.DE → münchen.de
МОСКВА.РФ → москва.рф
```

[Inference] Some scripts lack uppercase/lowercase distinctions (Chinese, Japanese, Arabic, Hebrew). For these scripts, case folding has no effect.

**Zero-Width Characters:**

Certain Unicode characters are invisible:

- Zero Width Joiner (U+200D)
- Zero Width Non-Joiner (U+200C)

These characters are contextually permitted in scripts where they affect character shaping (Arabic, Devanagari, Persian) but prohibited elsewhere to prevent abuse.

**Compatibility Characters:**

Unicode includes compatibility characters for backward compatibility with legacy encodings. IDNA2008 generally prohibits these to prevent confusion:

```
Regular A: U+0041
Full-width A: U+FF21 (DISALLOWED in IDNA2008)
```

**Key Points:**

- Unicode enables domain names in any script
- NFC normalization ensures consistent representation
- Character validity determined by IDNA tables
- Script mixing often restricted for security
- Case folding applies to all scripts
- Right-to-left scripts require bidirectional display algorithms
- Zero-width characters permitted only in specific contexts

**Validation Process:**

Converting a Unicode domain name for DNS use involves:

1. Normalize to Unicode NFC form
2. Apply case folding
3. Validate characters against IDNA tables
4. Check contextual rules for special characters
5. Verify script mixing policies
6. Encode to Punycode for DNS queries

This validation ensures domain names are technically valid, unambiguous, and secure against visual confusion attacks.

Unicode domain names represent the human-readable, culturally appropriate form that users interact with, while the underlying DNS infrastructure continues to use ASCII-compatible encoding for technical compatibility.

## Punycode Encoding Algorithm

**Punycode** is the encoding algorithm that converts Unicode domain labels to ASCII-compatible format for use in DNS infrastructure. Defined in **RFC 3492**, Punycode enables Unicode domain names to function within ASCII-only DNS protocols without requiring changes to core DNS software.

The algorithm is specifically designed for encoding Internationalized Domain Names in Applications (IDNA), though it can theoretically encode any Unicode string. Punycode is deterministic, bijective (one-to-one mapping), and produces compact ASCII representations.

**Algorithm Overview:**

Punycode separates the encoding process into two phases:

1. **Basic code points** (ASCII characters already in the string) are copied directly
2. **Non-basic code points** (non-ASCII Unicode characters) are encoded using a compressed representation

The encoded string consists of:

- All ASCII characters from the original string (if any)
- A delimiter (hyphen) separating basic from encoded sections
- Encoded representation of non-ASCII characters and their positions

**Encoding Structure:**

```
Basic-ASCII-Characters-EncodedNonASCII

Example:
münchen → mnchen-3ya
(ASCII: mnchen, Delimiter: -, Encoded: 3ya)
```

**Detailed Encoding Process:**

**Step 1: Extract Basic Code Points**

Copy all ASCII characters (code points < 128) directly to the output in their original positions:

```
Input: münchen
ASCII extracted: mnchen
Remaining to encode: ü (U+00FC)
```

**Step 2: Add Delimiter**

If there are both ASCII and non-ASCII characters, insert a hyphen (-) to separate them:

```
Output so far: mnchen-
```

**Step 3: Encode Non-Basic Code Points**

Punycode uses a variable-length encoding scheme with bias adaptation to efficiently encode the positions and values of non-ASCII characters.

The algorithm iteratively processes non-ASCII characters in order of their Unicode code points, encoding both:

- The character's code point value
- Its position in the original string

**Key Algorithm Parameters:**

```
base = 36 (uses digits 0-9 and letters a-z)
tmin = 1
tmax = 26
skew = 38
damp = 700
initial_bias = 72
initial_n = 128 (first non-ASCII code point)
delimiter = '-' (hyphen)
```

**Bias Adaptation:**

Punycode uses adaptive bias to optimize encoding efficiency. The bias adjusts based on the number of code points processed, making frequent patterns more compact.

**Variable-Length Integer Encoding:**

Non-ASCII characters are encoded as variable-length base-36 integers. Each digit represents a value from 0-35:

```
0-9 → values 0-9
a-z → values 10-35
```

**Complete Example Walkthrough:**

Encoding **"münchen"**:

```
Step 1: Extract ASCII
ASCII: m, n, c, h, e, n
Non-ASCII: ü (U+00FC, decimal 252)

Step 2: Initial output
mnchen-

Step 3: Encode ü position and value
Position: 1 (after 'm')
Code point: 252
Bias: 72 (initial)

Calculation: [specific encoding arithmetic]
Encoded: 3ya

Final result: mnchen-3ya
```

Encoding **"日本"** (Japan):

```
Step 1: No ASCII characters
Output: (empty)

Step 2: No delimiter needed
Output: (empty)

Step 3: Encode both characters
日 = U+65E5 (decimal 26085)
本 = U+672C (decimal 26412)

Encoded: wgv71a
Final result: wgv71a
```

**Decoding Process:**

Punycode decoding reverses the encoding:

1. Split string at the last hyphen
2. Characters before hyphen are literal ASCII
3. Characters after hyphen are decoded to extract Unicode code points and positions
4. Insert decoded characters at specified positions

```
Input: mnchen-3ya
Split: "mnchen" | "3ya"
Decode "3ya" → ü at position 1
Result: münchen
```

**Properties of Punycode:**

**Bijective**: Every Unicode string has exactly one Punycode encoding, and every valid Punycode string decodes to exactly one Unicode string.

**Compact**: ASCII characters require no encoding overhead. Non-ASCII characters are encoded efficiently, especially when similar code points appear.

**Case-preserving**: Although domain names are case-insensitive, Punycode preserves case information for applications that need it.

**ASCII-safe**: Encoded output contains only ASCII letters, digits, and hyphens, compatible with all DNS implementations.

**Key Points:**

- Punycode enables Unicode in ASCII-only DNS
- Defined in RFC 3492
- Uses base-36 encoding for efficiency
- Adaptive bias optimizes compression
- Bijective mapping ensures unique encoding/decoding
- ASCII characters pass through unchanged
- Encoding is deterministic and reversible

**Algorithm Complexity:**

[Inference] Punycode encoding time complexity is approximately O(n × m) where n is the number of non-ASCII characters and m is the total string length. Decoding is approximately O(m) where m is the encoded string length.

**Limitations:**

**Maximum length**: Encoded labels are limited to 63 octets (DNS label length limit), which constrains how many Unicode characters can be encoded, particularly for high code point values.

**No compression**: Each Unicode character requires encoding space. Strings with many unique non-ASCII characters produce longer encoded outputs.

**Not human-readable**: Encoded strings (after the "xn--" prefix) are not meaningful to humans, though this is by design for DNS compatibility.

**Example Encodings:**

```
Original → Punycode

münchen → mnchen-3ya
zürich → zrich-kva
москва → 80ake
中国 → fiqs8s
مصر → wgbl6i
παράδειγμα → hxajbheg2az4pqz2a
日本語 → wgv71a119e
example → example (no encoding needed)
```

The Punycode algorithm successfully bridges Unicode's rich character set with DNS's ASCII limitations, enabling internationalized domain names while maintaining full backward compatibility with existing internet infrastructure.

## xn-- Prefix

The **"xn--" prefix** is the ASCII Compatible Encoding (ACE) prefix that identifies Punycode-encoded internationalized domain name labels in DNS. This prefix distinguishes encoded IDN labels from regular ASCII domain labels, enabling DNS systems to recognize and process them correctly.

**Definition and Purpose:**

According to RFC 3490 and RFC 5891, the ACE prefix "xn--" (case-insensitive) marks the beginning of a Punycode-encoded label. When DNS software encounters this prefix, it recognizes the following characters as an encoded representation of Unicode characters.

The prefix serves multiple functions:

**Identification**: Signals that the label contains Punycode encoding **Namespace separation**: Prevents collision with existing ASCII-only domains **Backward compatibility**: Allows non-IDN-aware systems to process labels as ASCII strings **Detection**: Enables IDN-aware applications to decode and display Unicode

**Structure:**

```
xn--[punycode-encoded-string]

Format: xn-- + punycode(unicode_label)
```

The prefix always appears in lowercase in DNS queries and responses, though it is case-insensitive for processing. The Punycode-encoded portion follows immediately after the prefix.

**Example Transformations:**

```
User sees: münchen.de
DNS queries: xn--mnchen-3ya.de

User sees: 中国.cn
DNS queries: xn--fiqs8s.cn

User sees: москва.рф
DNS queries: xn--80ake.xn--p1ai

User sees: مثال.إختبار
DNS queries: xn--mgbh0fb.xn--kgbechtv

User sees: παράδειγμα.δοκιμή
DNS queries: xn--hxajbheg2az4pqz2a.xn--jxalpdlp
```

**Application in Domain Names:**

The xn-- prefix applies to each label (segment between dots) independently. In a fully internationalized domain name, multiple labels may be encoded:

```
User types: 例え.日本.jp
Browser converts: xn--r8jz45g.xn--wgv71a.jp

User types: مكتب.شركة.مصر
Browser converts: xn--[encoded1].xn--[encoded2].xn--wgbl6i
```

**Key Points:**

- "xn--" is the universal ACE prefix for all IDNs
- Case-insensitive (xn--, XN--, Xn-- all equivalent)
- Applied per label, not to entire domain
- 63-octet label limit includes the "xn--" prefix (4 bytes)
- ASCII labels never receive the prefix
- Must be followed by valid Punycode encoding

**Processing Flow:**

**User Input to DNS Query:**

1. User enters Unicode domain: "münchen.de"
2. Application detects non-ASCII characters
3. Application applies IDNA processing (normalization, validation)
4. Application encodes label to Punycode: "mnchen-3ya"
5. Application prepends "xn--": "xn--mnchen-3ya"
6. DNS query sent for: "xn--mnchen-3ya.de"

**DNS Response to User Display:**

1. DNS returns: "xn--mnchen-3ya.de"
2. Application detects "xn--" prefix
3. Application extracts Punycode: "mnchen-3ya"
4. Application decodes to Unicode: "münchen"
5. User sees: "münchen.de"

**Length Constraints:**

DNS labels are limited to 63 octets (bytes). The "xn--" prefix consumes 4 octets, leaving 59 octets for the Punycode-encoded string:

```
Total label length: ≤ 63 octets
xn-- prefix: 4 octets
Punycode portion: ≤ 59 octets
```

[Inference] This constraint limits how many Unicode characters can appear in a single label, particularly for characters with high code point values that require more encoding space.

**Example:**

```
Short Unicode: 中国
Encoded: xn--fiqs8s (10 total octets)
Within limit: ✓

Long Unicode: αβγδεζηθικλμνξοπρστυφχψω
Encoded: xn--[very long string]
Potential limit issue: may approach 63-octet boundary
```

**Security Implications:**

The xn-- prefix provides a visual indicator that a domain contains encoded non-ASCII characters. However, most users never see the encoded form in modern browsers.

**Homograph attack consideration**: The prefix doesn't prevent confusion attacks where visually similar characters from different scripts create lookalike domains:

```
Legitimate: example.com
Malicious IDN: еxample.com (Cyrillic 'е' looks like Latin 'e')
Encoded: xn--xample-9ub.com
```

Modern browsers implement **IDN display policies** to mitigate homograph attacks:

- Show Punycode for suspicious domains
- Restrict display of IDNs mixing scripts
- Show warning indicators for lookalike domains

**Browser Display Behavior:**

**IDN display** (typical case):

```
Address bar shows: münchen.de
Tooltip/inspect may show: xn--mnchen-3ya.de
```

**Punycode display** (security-triggered):

```
Address bar shows: xn--xample-9ub.com
(Browser detected suspicious pattern)
```

**Registry and Registrar Handling:**

Domain registries store domain names in their ACE-encoded form (xn-- prefix with Punycode) in zone files and databases:

```
Zone file entry:
xn--mnchen-3ya.de.  IN  A  192.0.2.1

Whois database:
Domain Name: xn--mnchen-3ya.de
```

Registrar interfaces typically display both forms:

```
Domain: münchen.de (xn--mnchen-3ya.de)
```

**Email Addresses:**

The xn-- prefix applies to domain portions of email addresses:

```
User enters: user@münchen.de
Email system converts: user@xn--mnchen-3ya.de
SMTP transmission: user@xn--mnchen-3ya.de
Display to user: user@münchen.de
```

The local part (before @) uses different internationalization mechanisms defined in RFC 6531 (SMTPUTF8) rather than Punycode encoding.

**Historical Context:**

The "xn--" prefix was chosen through IETF consensus to:

- Be highly unlikely to collide with existing domains
- Be short to minimize label length consumption
- Be clearly recognizable as special encoding
- Be typeable on all keyboards

Alternative prefixes considered included "bq--", "dq--", and "ra--", but "xn--" was selected as the standard.

**Validation:**

Applications must validate that strings following "xn--" contain valid Punycode:

```
Valid: xn--mnchen-3ya (correct Punycode)
Invalid: xn--invalid!@# (contains invalid Punycode characters)
Invalid: xn-- (empty Punycode portion)
```

[Inference] Invalid xn-- strings should be rejected during domain registration and DNS query processing to prevent malformed IDNs.

**Key Points:**

- "xn--" universally identifies Punycode-encoded IDN labels
- Four-character prefix reduces available encoding space
- Applied per-label in multi-label domains
- Enables transparent IDN processing in DNS infrastructure
- Modern browsers hide encoding from users under normal conditions
- Security policies may force Punycode display for suspicious domains
- Case-insensitive but conventionally lowercase

The xn-- prefix is fundamental to IDN implementation, providing the bridge between Unicode domain names and ASCII-compatible DNS infrastructure while maintaining transparency for end users in typical use cases.

---

## IDNA (Internationalized Domain Names in Applications)

Internationalized Domain Names in Applications (IDNA) is a mechanism that enables domain names to contain characters from non-ASCII scripts, allowing users worldwide to access the internet using their native languages and writing systems. IDNA bridges the gap between human-readable international characters and the ASCII-only DNS infrastructure.

### The ASCII Limitation Problem

The Domain Name System (DNS) was designed with ASCII characters, limiting domain names to:

- Letters: a-z (case-insensitive)
- Digits: 0-9
- Hyphen: - (not at start or end)

This restriction excluded billions of users whose languages use non-Latin scripts:

- Chinese: 中国.com
- Arabic: السعودية.com
- Cyrillic: россия.ru
- Devanagari: भारत.in
- Greek: ελλάδα.gr
- Hebrew: ישראל.il

### IDNA Architecture

IDNA enables international domain names through a two-layer architecture:

**User Layer**: Applications display domain names using Unicode characters in the user's native script, providing a natural, localized experience.

**Protocol Layer**: DNS and other internet protocols continue using ASCII-compatible encoding (ACE), ensuring backward compatibility with existing infrastructure.

**Conversion Process**: IDNA defines algorithms to convert between Unicode domain names (U-labels) and their ASCII-compatible representations (A-labels).

### Punycode Encoding

Punycode is the encoding algorithm that converts Unicode strings to ASCII-compatible format:

**Encoding Pattern**:

```
xn--<encoded-string>
```

The `xn--` prefix identifies a Punycode-encoded label, signaling that it represents international characters.

**Examples**:

Chinese domain:

```
Unicode (U-label): 中国
Punycode (A-label): xn--fiqs8s
Full domain: 中国.com → xn--fiqs8s.com
```

Arabic domain:

```
Unicode: السعودية
Punycode: xn--mgberp4a5d4ar
Full domain: السعودية.com → xn--mgberp4a5d4ar.com
```

German domain:

```
Unicode: münchen
Punycode: xn--mnchen-3ya
Full domain: münchen.de → xn--mnchen-3ya.de
```

Greek domain:

```
Unicode: ελλάδα
Punycode: xn--qxam
Full domain: ελλάδα.gr → xn--qxam.gr
```

Mixed ASCII and Unicode:

```
Unicode: café
Punycode: xn--caf-dma
Full domain: café.fr → xn--caf-dma.fr
```

**Punycode Algorithm Characteristics**:

- Efficient encoding of Unicode characters
- Preserves ASCII characters unchanged (except triggering xn-- prefix if any non-ASCII present)
- Case-insensitive encoding
- Variable length output depending on Unicode complexity
- Deterministic and reversible

### IDNA Processing Steps

**User Input to DNS Query**:

1. **Normalization**: Convert Unicode string to normalized form (NFC - Normalization Form C)
    
    ```
    Input: café (with combining acute accent)
    Normalized: café (with precomposed é)
    ```
    
2. **Validation**: Check characters against allowed Unicode code points for domain names
    
3. **Punycode Encoding**: Convert each label (segment between dots) to ASCII-compatible encoding
    
    ```
    café.example.com
    → xn--caf-dma.example.com
    ```
    
4. **DNS Query**: Send ASCII-encoded domain to DNS servers
    

**DNS Response to User Display**:

1. **Receive ASCII Response**: DNS returns ASCII-encoded domain
    
2. **Punycode Detection**: Identify labels with `xn--` prefix
    
3. **Punycode Decoding**: Convert A-labels back to U-labels
    
    ```
    xn--caf-dma.example.com
    → café.example.com
    ```
    
4. **Display**: Show Unicode domain to user in application interface
    

### Label-by-Label Processing

IDNA processes each label (domain segment) independently:

```
例え.テスト.example
```

Becomes:

```
xn--r8jz45g.xn--zckzah.example
```

Where:

- `例え` → `xn--r8jz45g`
- `テスト` → `xn--zckzah`
- `example` remains unchanged (pure ASCII)

This label-by-label approach allows mixing of:

- International labels
- ASCII labels
- Different scripts in different labels (though not recommended)

### Character Restrictions

IDNA defines which Unicode characters are permitted in domain names:

**Allowed Characters**:

- Letters from various scripts (Latin, Chinese, Arabic, Cyrillic, etc.)
- Digits from various scripts
- Certain marks and symbols specific to writing systems
- Hyphen-minus (U+002D)

**Disallowed Characters**:

- Control characters
- Whitespace characters
- Format characters
- Most punctuation and symbols
- Bidirectional control characters (in most contexts)
- Unassigned code points

**Contextual Rules**: Some characters allowed only in specific contexts:

- Middle dot (·) only in Catalan l·l combinations
- Zero-width joiner/non-joiner only with appropriate scripts
- Arabic-Indic digits only with Arabic script

### Right-to-Left (RTL) Script Handling

IDNA includes special rules for right-to-left scripts like Arabic and Hebrew:

**Bidi Rule**: Ensures consistent directionality within labels:

- If a label contains RTL characters, it must follow RTL rules
- Mixing LTR and RTL must follow specific patterns
- Prevents visual confusion from directional ambiguity

**Example**:

```
Arabic: مثال.com
Display: com.مثال (may appear reversed in some contexts)
Encoding: xn--mgbh0fb.com
```

**Display Challenges**: RTL domains may display differently depending on:

- Operating system
- Browser rendering
- Font support
- Surrounding text context

### IDNA Versions

Two major IDNA versions exist with significant differences:

**IDNA2003** (RFC 3490, 3491, 3492):

- Original IDNA specification
- More permissive character allowances
- Used Nameprep for string preparation
- Based on Unicode 3.2

**IDNA2008** (RFC 5890-5894):

- Updated specification addressing IDNA2003 limitations
- Stricter character validation
- Protocol-independent Unicode normalization
- Based on Unicode properties that evolve with Unicode versions
- Better security considerations

The differences between versions create compatibility challenges addressed in the next section.

### Protocol Integration

IDNA integrates with various internet protocols:

**HTTP/HTTPS**: Browsers convert Unicode domains to Punycode for HTTP Host headers and TLS Server Name Indication (SNI):

```
User types: https://例え.jp
Browser sends Host: xn--r8jz45g.jp
```

**Email**: Email addresses can contain IDN domains:

```
User display: user@例え.jp
SMTP transmission: user@xn--r8jz45g.jp
```

**DNS**: All DNS queries use Punycode-encoded A-labels, maintaining ASCII compatibility.

**Certificates**: SSL/TLS certificates can be issued for IDN domains, with the domain appearing as Punycode in the certificate but displayed as Unicode to users.

### IDNA Benefits

**Accessibility**: Enables internet access for non-English speakers using native scripts, removing language barriers.

**Cultural Identity**: Allows businesses and organizations to represent their brands authentically in native scripts.

**User Experience**: Simplifies domain memorization and typing for users in their native languages.

**Market Reach**: Enables localized domain names for international markets.

**Linguistic Preservation**: Supports minority languages and scripts in the digital space.

### Implementation Considerations

**Application Requirements**:

- Unicode text processing capabilities
- Punycode encoding/decoding libraries
- Normalization algorithms
- Character validation against IDNA rules
- Proper display of mixed scripts

**DNS Server Compatibility**: DNS servers don't require IDNA awareness since they only process ASCII-encoded A-labels. The encoding/decoding happens in applications.

**Database Storage**: Applications must decide whether to store:

- Unicode form (U-labels): Human-readable, requires conversion for DNS
- Punycode form (A-labels): DNS-ready, less human-readable
- Both forms: Redundant but optimizes for different use cases

**Testing Requirements**:

- Verify encoding/decoding accuracy
- Test with various Unicode scripts
- Validate character restriction enforcement
- Check proper handling of edge cases (mixed scripts, RTL text)

**Key Points**: IDNA enables international domain names through Punycode encoding, converting Unicode characters to ASCII-compatible format for DNS compatibility while displaying native scripts to users. The system processes each domain label independently and includes strict character validation to ensure security and consistency. IDNA represents a critical advancement in internet accessibility, allowing billions of users to interact with the internet in their native languages.

## IDNA2003 vs IDNA2008

The evolution from IDNA2003 to IDNA2008 addressed fundamental design issues and security concerns, but the transition created compatibility challenges that persist today.

### IDNA2003 Overview

Defined in RFC 3490, 3491, 3492, IDNA2003 was the original internationalized domain name standard.

**Key Characteristics**:

**Nameprep String Preparation**: Used a fixed string preparation algorithm called Nameprep (RFC 3491):

- Based on Unicode 3.2
- Applied normalization (NFKC - Normalization Form KC)
- Performed case folding
- Removed prohibited characters
- Applied bidirectional text rules

**Character Allowances**: More permissive in allowed characters, including some that later proved problematic for security.

**Fixed Unicode Version**: Tied to Unicode 3.2, preventing incorporation of new characters added in later Unicode versions.

**Mapping**: Performed character mappings before encoding:

- Case folding (uppercase to lowercase)
- Compatibility mappings (e.g., full-width to half-width)
- Normalization that could change character meanings

**Example Processing**:

```
Input: Café (with uppercase C)
Nameprep: café (lowercase, normalized)
Punycode: xn--caf-dma
```

### IDNA2008 Overview

Defined in RFC 5890-5894, IDNA2008 redesigned the architecture for better security, stability, and flexibility.

**Key Characteristics**:

**Protocol-Independent Unicode**: No longer tied to a specific Unicode version; uses character properties that evolve with Unicode.

**No Mapping**: Removed character mapping from the protocol:

- Applications perform any desired mappings before IDNA processing
- Case folding and other transformations are application-specific
- More predictable behavior

**Stricter Character Validation**: Uses Unicode character properties to classify characters:

- PVALID: Always allowed
- DISALLOWED: Never allowed
- CONTEXTJ: Allowed in specific contexts (joining characters)
- CONTEXTO: Allowed with specific contextual rules

**Label Validation**: Each label must pass validation rules:

- Character property checks
- Contextual rules for specific characters
- Bidi rule for right-to-left scripts
- No leading combining marks

**Normalization**: Uses NFC (Normalization Form C) instead of NFKC:

- Preserves more character distinctions
- Reduces security ambiguities
- More stable across Unicode versions

### Major Differences

**Character Mapping**:

IDNA2003:

```
Input: Straße (German sharp s: ß)
Mapped: strasse (ß → ss)
Punycode: strasse (or xn--strae-oqa if ß preserved in some implementations)
```

IDNA2008:

```
Input: Straße
No mapping: straße (only normalized, case preserved in processing)
Punycode: xn--strae-oqa
```

Result: Different Punycode encodings for the same intended domain.

**Character Allowances**:

Some characters allowed in IDNA2003 but disallowed in IDNA2008:

- Zero-width space (U+200B)
- Zero-width non-joiner in some contexts
- Certain symbols and punctuation

Example:

```
Domain: test‌ing.com (contains zero-width non-joiner)
IDNA2003: May accept (depending on implementation)
IDNA2008: Rejects (disallowed character)
```

**Case Handling**:

IDNA2003:

```
Input: EXAMPLE.COM
Processing: example.com (case-folded by protocol)
```

IDNA2008:

```
Input: EXAMPLE.COM
Processing: Applications should lowercase before IDNA
Protocol: Case-sensitive validation
```

**Unicode Version Dependency**:

IDNA2003: Fixed to Unicode 3.2

```
New character in Unicode 6.0: 𐍈 (Gothic letter)
IDNA2003: Cannot process (not in Unicode 3.2)
```

IDNA2008: Works with evolving Unicode

```
New character in Unicode 6.0: 𐍈
IDNA2008: Evaluates based on character properties
Result: Allowed if properties indicate PVALID
```

### Compatibility Issues

**Incompatible Domains**: Some domains valid under one version are invalid or encode differently under the other.

**ß (German Sharp S) Problem**:

IDNA2003 behavior varied by implementation:

- Some mapped ß → ss
- Others preserved ß

IDNA2008:

- ß is PVALID, preserved in encoding
- `straße.de` → `xn--strae-oqa.de`

Result: Domains registered under IDNA2003 with ß→ss mapping become inaccessible under strict IDNA2008.

**Greek Final Sigma (ς vs σ)**:

IDNA2003:

```
ς (final sigma) and σ (regular sigma) both mapped to σ
Domain: μάθησις.gr → μάθησισ.gr → xn--wxaikc6b.gr
```

IDNA2008:

```
ς preserved as distinct from σ
Domain: μάθησις.gr → xn--nxas3a3e.gr (different encoding)
```

Domains registered with one form may not match the other.

**Practical Compatibility Example**:

A domain registered in 2005 under IDNA2003:

```
faß.de (German domain with ß)
IDNA2003 encoding: fass.de or xn--fa-hia.de
```

User typing the same domain in 2024:

```
Browser using IDNA2008: xn--fa-hia.de
Server expecting IDNA2003: fass.de
Result: Domain not found (mismatch)
```

### Transition Mechanisms

**Transitional Processing**: Some systems implement both versions with fallback:

1. Attempt IDNA2008 encoding first
2. If validation fails, try IDNA2003
3. Use whichever succeeds

**UTS #46 (Unicode IDNA Compatibility Processing)**: Unicode Technical Standard #46 provides transitional mechanisms:

**Mapping Options**:

- Transitional processing: Applies IDNA2003-like mappings
- Non-transitional processing: Follows strict IDNA2008

**Example with ß**:

Transitional:

```
Input: Straße
Mapped: strasse
Encoded: strasse (or appropriate Punycode)
```

Non-transitional:

```
Input: Straße
Preserved: straße
Encoded: xn--strae-oqa
```

**Browser Implementation**: Most modern browsers use UTS #46 transitional processing to maximize compatibility:

```javascript
// Browser internally processes both:
straße.de → checks both xn--strae-oqa.de and strasse.de
```

### Implementation Status

**Modern Browsers** (as of 2024):

- Chrome: UTS #46 transitional processing
- Firefox: UTS #46 transitional processing
- Safari: UTS #46 transitional processing
- Edge: UTS #46 transitional processing

[Inference: Browsers prioritize compatibility, using transitional processing to handle domains registered under either IDNA version.]

**Email Systems**: Email handling varies:

- Some use IDNA2008 strictly
- Others apply transitional processing
- Legacy systems may still use IDNA2003

**Programming Libraries**:

- Python 3: `idna` library supports both versions
- JavaScript: Punycode built-in, libraries add IDNA support
- ICU (International Components for Unicode): Supports UTS #46
- libidn2: IDNA2008 implementation

**DNS Registries**: Domain registrars handle compatibility differently:

- Some accept only IDNA2008-compliant domains
- Others grandfather IDNA2003 domains
- Many implement transitional rules to prevent domain squatting

### Migration Challenges

**Domain Ownership Conflicts**:

A domain registered as `faß.de` under IDNA2003 (encoded as `fass.de`) may conflict with someone registering `fass.de` under IDNA2008.

**Resolution strategies**:

- Registry policies preventing registration of both variants
- Grandfather clauses protecting existing registrations
- Requiring registrants to claim all variants

**User Confusion**:

Users may not understand why the same domain:

- Works in some browsers but not others
- Requires different spellings in different contexts
- Appears differently in browser address bars

**Technical Debt**:

Organizations with IDNA2003 domains face decisions:

- Maintain legacy encoding
- Migrate to IDNA2008
- Register both variants
- Update all references and documentation

### Best Practices for Implementation

**For New Domains**:

- Use IDNA2008-compliant encoding
- Validate using strict IDNA2008 rules
- Avoid characters with problematic mapping (ß, final sigma)
- Consider registering both variants if ambiguity exists

**For Existing Domains**:

- Audit current encoding (IDNA2003 vs IDNA2008)
- Test accessibility across browsers and systems
- Consider registering variant spellings
- Document which encoding is canonical

**For Application Developers**:

- Use UTS #46 libraries for compatibility
- Implement transitional processing for user input
- Store canonical forms consistently
- Validate both on input and output
- Provide clear error messages for invalid domains

**For Testing**:

```
Test cases:
1. Pure ASCII: example.com
2. Simple IDN: café.com
3. German ß: faß.de (test both variants)
4. Greek sigma: μάθησις.gr
5. Mixed scripts: test-テスト.com
6. RTL scripts: مثال.com
7. Edge cases: xn--xn--abc.com (Punycode in input)
```

### Technical Comparison Table

|Aspect|IDNA2003|IDNA2008|
|---|---|---|
|RFCs|3490, 3491, 3492|5890, 5891, 5892, 5893, 5894|
|Unicode Version|Fixed (3.2)|Evolving (property-based)|
|String Preparation|Nameprep (NFKC)|NFC, no mapping|
|Case Handling|Protocol maps to lowercase|Application responsibility|
|ß Handling|Mapped to ss|Preserved|
|Character Validation|List-based|Property-based|
|Bidi Rules|Defined in RFC 3454|Updated in RFC 5893|
|Compatibility|With legacy systems|Forward-compatible|

### Future Outlook

[Speculation: Full transition to IDNA2008 may never be complete due to legacy domains and systems, but transitional processing mechanisms will likely continue to bridge the gap.]

**Ongoing Challenges**:

- Millions of domains registered under IDNA2003
- Gradual migration limited by technical and economic factors
- Need for backward compatibility prevents clean breaks
- New Unicode versions may introduce new edge cases

**Industry Direction**:

- Registries increasingly require IDNA2008 compliance for new registrations
- Browsers maintain transitional support indefinitely
- Standards bodies focus on UTS #46 for practical interoperability
- Security research continues to identify character confusability issues

**Key Points**: IDNA2008 significantly improved upon IDNA2003 through stricter character validation, protocol-independent Unicode handling, and removal of problematic character mappings. However, the transition created compatibility issues that persist through different encodings for the same domains. UTS #46 provides transitional processing mechanisms that most modern browsers use to maximize compatibility, allowing systems to handle domains registered under either version. Understanding both versions is essential for implementing robust IDN support and troubleshooting domain accessibility issues.

## IDN Security Concerns (Homograph Attacks)

Internationalized Domain Names introduce significant security vulnerabilities through character visual similarity, enabling attackers to create deceptive domains that appear identical to legitimate ones. These homograph attacks exploit human visual perception rather than technical systems.

### Homograph Attack Fundamentals

A homograph attack uses characters from different scripts that look identical or very similar to create fraudulent domains that visually mimic legitimate ones.

**Basic Concept**:

```
Legitimate: apple.com
Malicious:  аррӏе.com (using Cyrillic а, р, and Latin l)
Visual:     indistinguishable in many fonts
Punycode:   xn--80ak6aa92e.com
```

Users cannot distinguish the malicious domain from the legitimate one when displayed in browsers, emails, or other interfaces.

### Types of Visual Confusability

**Identical Appearance**:

Characters that look exactly the same across scripts:

```
Latin a vs Cyrillic а (U+0061 vs U+0430)
Latin e vs Cyrillic е (U+0065 vs U+0435)
Latin o vs Cyrillic о (U+006F vs U+043E)
Latin p vs Cyrillic р (U+0070 vs U+0440)
Latin c vs Cyrillic с (U+0063 vs U+0441)
```

Full domain example:

```
Legitimate:  paypal.com
Homograph:   pаypаl.com (using Cyrillic а)
Punycode:    xn--pypl-4ve.com
```

**Near-Identical Appearance**:

Characters with subtle differences that may not be noticed:

```
Latin l (lowercase L) vs I (uppercase i) vs 1 (digit one) vs | (pipe)
Latin O (uppercase o) vs 0 (zero)
Latin rn vs m (in some fonts)
Latin vv vs w
```

Example:

```
Legitimate:  microsoft.com
Homograph:   rnicrosoft.com (rn appears as m in some fonts)
```

**Combining Characters**:

Diacritical marks can be added or removed:

```
e vs é vs ě vs ė
a vs à vs á vs â vs ã
```

Example:

```
Legitimate:  cafe.com
Homograph:   café.com (legitimate alternative or confusable)
```

### Cross-Script Confusability

**Latin vs Cyrillic**:

Most dangerous combination due to numerous identical-looking characters:

```
Full Cyrillic homograph of "google.com":
gооglе.com (using Cyrillic о and е)
Punycode: xn--ggle-4le.com
```

**Latin vs Greek**:

```
Latin: a, e, i, o, p, t, v, x, y
Greek:  α, ε, ι, ο, ρ, τ, ν, χ, ν
```

Example:

```
Legitimate:  example.com
Homograph:   еxаmplе.com (using Greek ε and α)
```

**Other Script Combinations**:

Hebrew vs Latin:

```
Hebrew ם (final mem) can resemble Latin o in some fonts
```

Armenian vs Latin:

```
Armenian Ս can resemble Latin U
```

Mathematical Alphanumeric Symbols:

```
𝐠𝐨𝐨𝐠𝐥𝐞.𝐜𝐨𝐦 (mathematical bold letters)
Punycode: xn--ggle-qpb.xn--m-7ub
```

### Attack Scenarios

**Phishing**:

Attacker registers homograph domain resembling a bank or service:

```
Legitimate:  bankofamerica.com
Homograph:   bаnkоfаmеrіcа.com (Cyrillic characters)
```

Attack flow:

1. Attacker sends email with homograph link
2. User clicks, seeing familiar domain name
3. Phishing site collects credentials
4. User doesn't notice discrepancy

**Man-in-the-Middle**:

Homograph domain used to intercept traffic:

```
Legitimate:  login.company.com
Homograph:   lоgіn.cоmpаny.com (Cyrillic)
```

Attacker captures login credentials and forwards to legitimate site, remaining undetected.

**Brand Impersonation**:

Cybersquatting on homograph domains:

```
Legitimate:  amazon.com
Homograph:   аmаzоn.com (Cyrillic а and о)
```

Used for:

- Fraudulent e-commerce
- Brand reputation damage
- Typosquatting enhancement

**Malware Distribution**:

Homograph domain hosting malware:

```
Legitimate:  adobe.com (software downloads)
Homograph:   аdоbе.com (Cyrillic)
```

Users download malware thinking they're on legitimate site.

### Real-World Examples

**2017 Punycode Phishing Attack**:

Security researcher demonstrated vulnerability:

```
Target:      apple.com
Homograph:   аррӏе.com (Cyrillic)
Punycode:    xn--80ak6aa92e.com
```

Major browsers displayed Unicode version without warning, making attack viable. This prompted browser vendors to implement stronger protections.

[Inference: While specific attack statistics are not publicly available, the 2017 demonstration led to immediate browser security updates, suggesting the threat was considered serious by major vendors.]

**Epic Games Homograph**:

```
Target:      epicgames.com
Homograph:   еpicgames.com (Cyrillic е)
```

[Unverified: Various reports have described homograph attacks targeting gaming platforms, though specific confirmed incidents are not well-documented in public sources.]

### Detection Challenges

**Visual Inspection Inadequate**:

Humans cannot reliably distinguish homograph domains:

- Character differences invisible in most fonts
- No visual indication of script mixing
- Browser UI shows Unicode, hiding underlying encoding

**URL Bar Display**:

```
What user sees:    paypal.com
Actual domain:     pаypаl.com (Cyrillic)
Punycode encoding: xn--pypl-4ve.com
```

Most browsers show Unicode by default, hiding the substitution.

**Copy-Paste Vulnerability**:

Copying a homograph domain preserves the deceptive appearance:

```
Copied text:   apple.com (appears correct)
Actual bytes:  аррӏе.com (contains Cyrillic)
```

Users sharing URLs may unknowingly propagate homographs.

**Font Rendering**:

Confusability varies by font:

- Some fonts make distinctions clear
- Others render identically
- Users have different font configurations

### Browser Defenses

**Punycode Display**:

When browsers detect potential homograph attacks, they display Punycode instead of Unicode:

```
Suspicious domain display:
xn--80ak6aa92e.com

Instead of:
аррӏе.com
```

**Detection Heuristics**:

**Mixed Script Detection**:

Browsers flag domains mixing scripts from different languages:

```
Allowed:     example.com (all Latin)
Allowed:     例え.jp (all Japanese)
Flagged:     exаmple.com (Latin + Cyrillic а)
Display:     xn--exmple-5of.com (Punycode shown)
```

**Exception**: Some script combinations commonly used together are allowed:

- Latin + common (numbers, hyphens)
- Chinese + Latin (for brand names)
- Japanese scripts (Hiragana + Katakana + Kanji)

**Confusable Character Detection**:

Browsers maintain lists of confusable characters and may display Punycode when detected.

**Whitelist Approach**:

Some browsers maintain whitelists of allowed script combinations and display Punycode for others.

**Certificate Validation**:

Extended Validation (EV) certificates and proper SSL/TLS validation help:

- Certificate must match exact domain (including script)
- Certificate authorities should validate domain ownership
- Browser UI shows security indicators

[Inference: Homograph domains typically cannot obtain legitimate certificates for major brands, as certificate authorities verify domain ownership.]

### Browser-Specific Implementations

**Chrome**:

- Displays Punycode for mixed-script domains
- Allows certain safe script combinations (Chinese + Latin for Chinese domains)
- Updates confusable character database regularly

**Firefox**:

- `network.IDN_show_punycode` preference controls IDN display
- More restrictive than Chrome in allowed script combinations
- Displays Punycode for most mixed-script domains

**Safari**:

- Restrictive IDN policy
- Displays Punycode for potentially confusable domains
- Integrates with macOS security features

**Edge**:

- Follows Chromium's approach (based on Chrome)
- Mixed-script detection
- Regular security updates

### IDN Policy Configurations

Browsers allow configuration of IDN handling:

**Firefox Settings**:

```
about:config → network.IDN_show_punycode
false: Show Unicode when deemed safe (default)
true:  Always show Punycode for all IDN
```

**Chrome Settings**: No user-facing setting; policy controlled through enterprise configurations.

### Mitigation Strategies

**For Users**:

1. **Check Punycode**: Manually inspect domains by copying to text editor:
    
    ```
    Copy: аррӏе.com
    Paste: may reveal xn--80ak6aa92e.com or show different characters
    ```
    
2. **Verify Certificates**: Click padlock icon, examine certificate details:
    
    - Check certificate domain matches expected
    - Verify certificate authority is legitimate
    - Look for Extended Validation indicators
3. **Use Bookmarks**: Access sensitive sites via bookmarks rather than links:
    
    - Bookmarks store exact URLs
    - Reduces exposure to homograph links
4. **Enable Security Features**: Use browser security settings and extensions:
    
    - Enable phishing protection
    - Use password managers that verify domains
    - Install security extensions that flag suspicious domains
5. **Scrutinize URLs**: Before entering credentials:
    
    - Carefully examine full URL
    - Look for unusual characters or spellings
    - Verify HTTPS and certificate

**For Developers and Organizations**:

1. **Domain Monitoring**: Register likely homograph variants:
    
    ```
    Primary: example.com
    Register: еxаmple.com, exаmplе.com, etc.
    ```
    
2. **HSTS Preloading**: Enable HTTP Strict Transport Security:
    
    ```
    Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
    ```
    
    Prevents attackers from serving content on HTTP homograph domains.
    
3. **Certificate Transparency Monitoring**: Monitor Certificate Transparency logs for:
    
    - Certificates issued for similar domains
    - Potential homograph registrations
    - Unauthorized certificate issuance
4. **Brand Protection Services**: Use services that:
    
    - Monitor domain registrations for similar names
    - Identify potential homograph registrations
    - Provide alerts for suspicious activity
5. **User Education**: Train users to:
    
    - Recognize homograph risks
    - Verify URLs before clicking
    - Report suspicious domains
    - Use secure access methods
6. **Email Filtering**: Implement filters detecting:
    
    - IDN domains in email links
    - Mixed-script domains
    - Known homograph patterns

**For Registrars and Registries**:

1. **Registration Restrictions**: Prevent registration of obvious homographs:
    
    - Cross-reference with existing domains
    - Restrict mixed-script registrations
    - Require justification for similar domains
2. **Reserved Domains**: Automatically reserve homograph variants of major brands
    
3. **Dispute Resolution**: Provide mechanisms for challenging homograph registrations:
    
    - Trademark protection
    - Cybersquatting policies
    - Rapid takedown procedures

### Unicode Consortium Efforts

**Confusables.txt**: Unicode maintains a data file listing visually confusable characters:

```
0041 ; 0410 ;  SA  # LATIN CAPITAL LETTER A vs CYRILLIC CAPITAL LETTER A
0065 ; 0435 ;  SA  # LATIN SMALL LETTER E vs CYRILLIC SMALL LETTER IE
```

Applications can use this data to detect potential homographs.

**Security Mechanisms**: UTS #39 (Unicode Security Mechanisms) provides:

- Confusable detection algorithms
- Mixed-script detection
- Spoofing identification techniques

### Limitations of Current Defenses

**Coverage Gaps**:

Browsers cannot detect all homographs:
- Single-script homographs (using similar characters within one script)
- Newly discovered confusable characters
- Context-dependent confusability

**User Override**:

Security-conscious users may disable IDN entirely, but this:

- Breaks legitimate international domains
- Reduces internet accessibility for non-English speakers
- Creates digital divide

**Performance Trade-offs**:

Extensive checking impacts browser performance:

- Every domain must be validated
- Confusable databases are large
- Real-time checking adds latency

**Legitimate Multi-Script Domains**:

Some legitimate domains use multiple scripts:

```
bmw中国.com (brand name + Chinese)
```

Distinguishing legitimate use from attacks is challenging.

### Future Considerations

**Machine Learning**: [Speculation: Future defenses may use machine learning to detect suspicious domain patterns based on usage, registration patterns, and behavioral analysis.]

**Stricter Policies**: [Speculation: Registrars may implement stricter policies requiring business justification for IDN registrations and cross-script combinations.]

**Enhanced UI**: Browsers may add visual indicators:

- Color-coding for script types
- Tooltips showing Punycode
- Explicit warnings for mixed scripts

**Key Points**: Homograph attacks exploit visual similarity between characters from different scripts to create deceptive domains indistinguishable from legitimate ones. Browsers implement mixed-script detection and selective Punycode display as primary defenses, but perfect protection is impossible without breaking legitimate IDN use. Users must remain vigilant, verify certificates, and use secure access methods. Organizations should register defensive homograph variants and implement monitoring for suspicious domain registrations. The tension between security and accessibility remains the central challenge in IDN deployment.

## Browser IDN Support

Modern browsers provide varying levels of Internationalized Domain Name support, balancing accessibility for international users with security concerns around homograph attacks. Implementation details significantly affect both usability and security.

### Universal Browser Capabilities

All modern browsers support core IDN functionality:

**Punycode Encoding/Decoding**: Automatic conversion between Unicode display and ASCII-compatible encoding for DNS queries.

**Unicode Display**: Show internationalized domains in the address bar using native scripts when deemed safe.

**IDNA Processing**: Handle Internationalized Domain Names in Applications protocol for domain resolution.

**Selective Punycode Display**: Show ASCII-encoded Punycode when potential security issues are detected.

### Chrome IDN Implementation

**Version Support**: IDN support introduced in early versions, continuously refined.

**Display Policy**:

Chrome displays Unicode domains when:

- Domain uses single script (all characters from one script system)
- Script combination is explicitly whitelisted
- Domain doesn't contain confusable characters

Chrome displays Punycode when:

- Mixed scripts from different language families detected
- Characters match confusable patterns
- Security heuristics triggered

**Whitelisted Script Combinations**:

```
Chinese + Latin: allowed for Chinese domains with Latin brand names
  Example: bmw中国.com displayed as Unicode

Japanese scripts: Hiragana, Katakana, Kanji can mix
  Example: テスト.example displayed as Unicode

Korean + Latin: allowed combinations
  Example: 한국.com displayed as Unicode
```

**Confusable Character Detection**:

Chrome maintains internal database of confusable characters and applies heuristics:

```
Displayed as Unicode:
  café.com (legitimate diacritic use)

Displayed as Punycode:
  pаypаl.com (Cyrillic а detected)
  → xn--pypl-4ve.com
```

**Configuration**:

Chrome doesn't expose user-facing IDN settings. Enterprise deployments can configure via policies:

```
IDNTranslationEnabled: Controls IDN translation
  true: Enable IDN (default)
  false: Always show Punycode
```

**Security Updates**:

Chrome regularly updates its confusable character database and detection algorithms through browser updates.

**DevTools Display**:

Chrome DevTools shows actual Punycode in network requests:

```
Address bar:      café.com
Network tab:      xn--caf-dma.com
DNS query:        xn--caf-dma.com
```

### Firefox IDN Implementation

**Version Support**: IDN support from Firefox 1.0 with evolving security policies.

**Display Policy**:

Firefox uses a more restrictive approach than Chrome:

- Stricter mixed-script detection
- Configurable user preferences
- Emphasis on user control

**Configuration Preferences**:

Access via `about:config`:

```
network.IDN_show_punycode
  false: Show Unicode for safe IDN (default)
  true:  Always show Punycode

network.IDN.restriction_profile
  moderate: Default restrictions (default)
  high:     Stricter restrictions
  moderate: Standard restrictions

network.IDN.whitelist.tld
  Add TLDs to whitelist for Unicode display
```

**Per-TLD Whitelisting**:

Firefox allows configuring which top-level domains can display Unicode:

```
network.IDN.whitelist.jp: true (display Japanese domains)
network.IDN.whitelist.cn: true (display Chinese domains)
network.IDN.whitelist.com: true (display .com IDNs if safe)
```

**Script Mixing Rules**:

Firefox applies conservative rules:

```
Allowed:  テスト.jp (single script)
Blocked:  tеst.com (mixed Latin/Cyrillic)
Display:  xn--tst-bma.com
```

**User Warnings**:

Firefox may show additional warnings for:

- First visit to IDN domain
- Domains with unusual character combinations
- Certificates with IDN subject names

### Safari IDN Implementation

**Version Support**: IDN support from Safari 1.3, with macOS integration.

**Display Policy**:

Safari takes a conservative approach:

- Restrictive mixed-script policies
- Integration with macOS security features
- Emphasis on security over permissiveness

**Whitelist Approach**:

Safari maintains whitelist of allowed script combinations:

```
Allowed:
  Single-script domains (Chinese, Arabic, Cyrillic, etc.)
  Specific approved combinations
  Common script + Latin numbers

Displayed as Punycode:
  Most mixed-script combinations
  Domains with confusable characters
```

**macOS Integration**:

Safari leverages macOS capabilities:

- System-wide font rendering consistency
- Integrated security frameworks
- Consistent behavior across Apple devices

**Configuration**:

Limited user-facing configuration:

- No direct IDN preference settings
- Controlled through system security policies
- Enterprise management via configuration profiles

**iOS Safari**:

Mobile Safari follows similar policies:

- Consistent with desktop Safari
- Touch-optimized security warnings
- Integrated with iOS security features

### Edge IDN Implementation

**Version Support**: Legacy Edge (pre-Chromium) had independent implementation; modern Edge (Chromium-based) follows Chrome.

**Chromium-Based Edge** (current):

Display policies match Chrome:

- Same mixed-script detection
- Identical confusable character handling
- Consistent Punycode display rules

Microsoft may apply additional enterprise-specific policies:

- Integration with Windows security
- Azure AD conditional access policies
- Microsoft Defender SmartScreen integration

**Legacy Edge** (discontinued):

Used different heuristics but followed similar principles:

- Mixed-script detection
- Punycode display for suspicious domains
- Windows integration

### Opera IDN Implementation

**Version Support**: Opera (Chromium-based since version 15) follows Chrome's implementation.

**Display Policy**:

Inherits Chrome's behavior:

- Identical script mixing rules
- Same confusable character detection
- Consistent Punycode display

**Additional Features**:

Opera may add supplementary security features:

- Integrated VPN affects domain resolution
- Built-in ad blocker may flag suspicious IDN domains
- Opera Turbo compression may affect IDN display

### Mobile Browser Considerations

**Mobile-Specific Challenges**:

Smaller screens and touch interfaces create additional IDN security concerns:

- Limited URL visibility (truncated address bars)
- Harder to inspect full domains
- Touch selection of text more difficult
- Users less likely to scrutinize URLs

**Android Chrome**:

Follows desktop Chrome policies:

- Same mixed-script detection
- Punycode display for suspicious domains
- Limited screen space shows partial URLs

**iOS Safari**:

Consistent with desktop Safari:

- Conservative mixed-script handling
- Punycode for potentially confusable domains
- iOS security integration

**Mobile-Specific Mitigations**:

Browsers implement additional protections:

- Full URL display on tap/long-press
- Security warnings before navigation
- Certificate information prominently displayed
- Integration with mobile OS security features

### IDN in Browser APIs

**JavaScript URL API**:

Browsers provide programmatic access to IDN handling:

```javascript
// Create URL object with IDN
const url = new URL('https://café.com/path');

console.log(url.hostname);  // "café.com" (Unicode)
console.log(url.href);      // "https://xn--caf-dma.com/path" (Punycode in href)

// Creating with Punycode
const punyUrl = new URL('https://xn--caf-dma.com/');
console.log(punyUrl.hostname);  // May display as "café.com" depending on browser
```

[Inference: The exact behavior of the URL API's hostname property varies between browsers, with some normalizing to Unicode and others preserving Punycode.]

**Fetch API and IDN**:

```javascript
// Fetch with Unicode domain
fetch('https://例え.jp/api/data')
  .then(response => response.json());

// Browser internally converts to Punycode for actual request
// Network request: https://xn--r8jz45g.jp/api/data
```

**XMLHttpRequest**:

Similar handling to Fetch API:

```javascript
const xhr = new XMLHttpRequest();
xhr.open('GET', 'https://café.com/data');
// Request sent to: https://xn--caf-dma.com/data
```

**WebSocket**:

IDN support in WebSocket connections:

```javascript
const ws = new WebSocket('wss://テスト.example.com/socket');
// Connects to: wss://xn--zckzah.example.com/socket
```

### Certificate Handling with IDN

**SSL/TLS Certificates**:

Certificates can be issued for IDN domains:

```
Certificate Subject:
  CN=xn--caf-dma.com (Punycode form)

Browser displays:
  Issued to: café.com (Unicode form)
```

**Subject Alternative Names (SAN)**:

IDN domains appear as Punycode in certificate SAN fields:

```
X509v3 Subject Alternative Name:
  DNS:xn--caf-dma.com
  DNS:www.xn--caf-dma.com
```

Browsers convert to Unicode for display in security information.

**Extended Validation (EV) Certificates**:

EV certificates for IDN domains:

- Certificate authority validates ownership of Punycode domain
- Browser displays organization name with Unicode domain
- Green address bar or organization name shown (browser dependent)

**Certificate Transparency**:

IDN domains appear as Punycode in Certificate Transparency logs:

```
CT Log Entry:
  Domain: xn--caf-dma.com
  Issuer: Let's Encrypt Authority
```

Monitoring services should search both Unicode and Punycode forms.

### Browser Security Indicators

**Address Bar Display**:

Browsers use various indicators for IDN domains:

**Secure (HTTPS) IDN**:

```
[Padlock] café.com
```

**Insecure (HTTP) IDN**:

```
[Info icon] café.com (Not Secure)
```

**Suspicious IDN** (Punycode shown):

```
[Warning icon] xn--caf-dma.com
```

**Certificate Errors**:

IDN-specific certificate warnings:

- Certificate issued for different domain (Unicode vs Punycode mismatch)
- Self-signed certificate on IDN domain
- Expired certificate

**Phishing Warnings**:

Browsers may show specific warnings for:

- Known homograph phishing domains
- Domains resembling popular sites
- Newly registered suspicious IDN domains

### Developer Tools and IDN

**Network Panel**:

Shows Punycode in actual network requests:

```
Request:
  URL: https://xn--caf-dma.com/api/users
  Host: xn--caf-dma.com

Response headers:
  Content-Type: application/json
```

**Console**:

JavaScript console displays both forms:

```javascript
window.location.hostname
// Display may show: "café.com" or "xn--caf-dma.com" depending on browser
```

**Application Tab**:

Storage viewers show domains:

```
Cookies:
  Domain: xn--caf-dma.com (Punycode form)

Local Storage:
  Origin: https://xn--caf-dma.com
```

### Testing IDN Support

**Test Domains**:

Create test cases for various scenarios:

```
Single script:
  中国.example
  россия.example
  ελλάδα.example

Mixed scripts (should show Punycode):
  tеst.example (Latin + Cyrillic е)
  exаmple.example (Latin + Cyrillic а)

Legitimate mixed:
  bmw中国.example (brand + Chinese)
```

**Verification Methods**:

1. **Manual Inspection**: Type domain in address bar, observe display
    
2. **JavaScript Testing**:
    

```javascript
function testIDN(domain) {
  const url = new URL(`https://${domain}`);
  console.log('Input:', domain);
  console.log('Hostname:', url.hostname);
  console.log('Href:', url.href);
}

testIDN('café.com');
testIDN('xn--caf-dma.com');
```

3. **Network Tools**: Use browser DevTools to inspect actual DNS queries
    
4. **Certificate Inspection**: Check certificate domain name encoding
    

### Browser Extension Integration

**IDN Handling in Extensions**:

Browser extensions can interact with IDN domains:

```javascript
// Manifest v3 extension
chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
  if (changeInfo.url) {
    const url = new URL(changeInfo.url);
    if (url.hostname.startsWith('xn--')) {
      // Handle Punycode domain
      console.log('IDN domain detected:', url.hostname);
    }
  }
});
```

**Security Extensions**:

Extensions can enhance IDN security:

- Flag suspicious homograph domains
- Display Punycode alongside Unicode
- Warn before navigation to IDN domains
- Check domains against known phishing lists

**Example Extension Features**:

```
IDN Guardian Extension:
- Shows Punycode in tooltip on hover
- Highlights mixed-script domains
- Provides one-click Punycode conversion
- Integrates with phishing databases
```

### Accessibility Considerations

**Screen Readers**:

IDN domains create challenges for screen readers:

- Unicode characters may be announced character-by-character
- Script names may be announced ("Cyrillic A, Latin P, Cyrillic P...")
- Punycode is unintelligible when read aloud
- Users may not understand announced domain

**Assistive Technology**:

Browsers should provide:

- Clear indication of script mixing
- Alternative text for security warnings
- Keyboard-accessible certificate inspection
- Audio feedback for security state

### Performance Implications

**Encoding Overhead**:

IDN processing adds minimal overhead:

- Punycode encoding/decoding is fast
- Confusable detection requires database lookup
- Mixed-script checking involves character property inspection

[Inference: Performance impact is negligible for typical browsing, measured in microseconds per domain resolution.]

**Caching**:

Browsers cache IDN validation results:

- Reduces repeated confusable checks
- Speeds up revisits to IDN domains
- Invalidated on database updates

**DNS Resolution**:

IDN adds no latency to DNS queries since:

- Conversion happens locally before query
- DNS servers receive standard ASCII
- Response handling unchanged

### Future Browser Developments

[Speculation: Future browsers may implement more sophisticated IDN security, including machine learning-based homograph detection, contextual analysis of domain usage patterns, and enhanced visual indicators for script types.]

**Potential Enhancements**:

- Visual script indicators (color-coding, icons)
- Improved certificate UI for IDN domains
- Enhanced warnings for first-time IDN visits
- Integration with threat intelligence services
- Better accessibility for international domains

**Key Points**: Browser IDN support varies in restrictiveness, with Chrome being more permissive and Firefox/Safari taking conservative approaches. All modern browsers implement mixed-script detection and selective Punycode display to mitigate homograph attacks while preserving accessibility for legitimate international domains. Developers must test IDN handling across browsers and understand that JavaScript APIs, certificates, and developer tools all interact with both Unicode and Punycode representations. The balance between security and international accessibility remains a central challenge in browser IDN implementation.

---

# IPv4 and IPv6 in URLs

Internet Protocol (IP) addresses serve as unique identifiers for devices connected to networks. Both IPv4 and IPv6 addresses can be used directly in URLs as alternatives to domain names, allowing direct addressing of network resources without relying on DNS resolution.

## IPv4 Address Syntax (192.0.2.1)

IPv4 (Internet Protocol version 4) addresses consist of 32 bits divided into four octets, each represented as a decimal number between 0 and 255, separated by periods (dots).

**Basic Structure**:

```
decimal.decimal.decimal.decimal
```

Each decimal number represents 8 bits (one octet), ranging from 0 to 255.

**URL Syntax with IPv4 Addresses**:

When used in URLs, IPv4 addresses replace the hostname component and follow standard URI syntax:

```
scheme://IPv4address[:port][/path][?query][#fragment]
```

**Examples**:

```
http://192.0.2.1
http://192.0.2.1:8080
https://192.0.2.1/path/to/resource
http://192.0.2.1:3000/api/users?id=123
ftp://192.0.2.1/files/document.pdf
https://203.0.113.45:8443/admin
```

**Valid IPv4 Address Ranges**:

**Public IP Addresses**: Routable on the public internet

- Class A: 1.0.0.0 to 126.255.255.255
- Class B: 128.0.0.0 to 191.255.255.255
- Class C: 192.0.0.0 to 223.255.255.255

**Private IP Addresses**: Reserved for private networks (RFC 1918)

- 10.0.0.0 to 10.255.255.255 (Class A private)
- 172.16.0.0 to 172.31.255.255 (Class B private)
- 192.168.0.0 to 192.168.255.255 (Class C private)

**Special-Use Addresses**:

- 127.0.0.0 to 127.255.255.255: Loopback addresses (localhost)
- 169.254.0.0 to 169.254.255.255: Link-local addresses (APIPA)
- 0.0.0.0: Represents "this network" or default route
- 255.255.255.255: Broadcast address

**Common URL Usage Examples**:

```
http://127.0.0.1              → Local loopback (localhost)
http://127.0.0.1:8080         → Local development server
http://192.168.1.1            → Common router address
http://192.168.0.100:3000     → Local network device
http://10.0.0.5/admin         → Private network server
```

**Dotted-Decimal Notation Rules**:

**Standard Format**: Each octet must be represented as a decimal number without leading zeros (except for the number 0 itself):

```
Correct:   192.0.2.1
Correct:   192.0.2.10
Incorrect: 192.000.002.001
Incorrect: 192.0.2.01
```

**Octet Value Constraints**:

- Minimum value per octet: 0
- Maximum value per octet: 255
- Total possible addresses: 4,294,967,296 (2³²)

**Alternative Representations**:

[Inference based on legacy systems] Some systems historically supported alternative IPv4 representations, though these are not recommended for URLs:

**Octal notation**: Octets prefixed with 0 (e.g., 0300.0000.0002.0001) **Hexadecimal notation**: Octets prefixed with 0x (e.g., 0xC0.0x00.0x02.0x01) **Integer notation**: Single 32-bit integer (e.g., 3221225985)

Modern URL parsing typically only accepts standard dotted-decimal notation.

**Parsing and Validation**:

Valid IPv4 addresses in URLs must:

- Contain exactly four octets separated by three periods
- Have each octet value between 0 and 255
- Not contain leading zeros (except for the value 0)
- Not contain any whitespace or special characters

**Invalid Examples**:

```
192.0.2          → Missing octets
192.0.2.256      → Octet exceeds 255
192.0.2.1.5      → Too many octets
192.0.2.-1       → Negative value
192.0.2.1a       → Non-numeric characters
```

**Security Considerations**:

Using IP addresses directly in URLs has security implications:

- No DNS-based protection or filtering
- [Inference] Certificate validation issues with HTTPS (certificates typically issued for domain names, not IP addresses)
- Bypass of host-based security policies
- [Inference] Difficulty in implementing virtual hosting (multiple domains on one IP)
- Exposure of internal network topology when using private addresses

## IPv6 Address Syntax ([2001:db8::1])

IPv6 (Internet Protocol version 6) addresses consist of 128 bits represented as eight groups of four hexadecimal digits, separated by colons. IPv6 was developed to address IPv4 address exhaustion and provides significantly more addresses.

**Basic Structure**:

```
hextet:hextet:hextet:hextet:hextet:hextet:hextet:hextet
```

Each hextet represents 16 bits (4 hexadecimal digits), ranging from 0000 to ffff.

**Full IPv6 Address Format**:

```
2001:0db8:0000:0000:0000:0000:0000:0001
```

**Hexadecimal Representation**:

- Case-insensitive: Both uppercase and lowercase are valid
- Valid characters: 0-9, a-f, A-F
- Each hextet can contain 1 to 4 hexadecimal digits

**IPv6 Address Compression Rules**:

**Leading Zero Suppression**: Leading zeros within each hextet can be omitted:

```
2001:0db8:0000:0042:0000:0000:0000:0001
Compressed: 2001:db8:0:42:0:0:0:1
```

**Zero Compression**: One sequence of consecutive zero hextets can be replaced with double colons (::):

```
2001:0db8:0000:0000:0000:0000:0000:0001
Compressed: 2001:db8::1
```

**Important Compression Constraints**:

- Double colon (::) can appear only once in an address
- Can represent one or more consecutive zero hextets
- Can appear at the beginning, middle, or end of the address

**Compression Examples**:

```
Full:       2001:0db8:0000:0000:0000:0000:0000:0001
Compressed: 2001:db8::1

Full:       2001:0db8:0000:0042:0000:8a2e:0370:7334
Compressed: 2001:db8:0:42:0:8a2e:370:7334
Better:     2001:db8:0:42::8a2e:370:7334

Full:       0000:0000:0000:0000:0000:0000:0000:0001
Compressed: ::1 (loopback address)

Full:       0000:0000:0000:0000:0000:0000:0000:0000
Compressed: :: (unspecified address)
```

**Canonical Form**: RFC 5952 defines rules for representing IPv6 addresses in a consistent, canonical format:

- Use lowercase hexadecimal digits
- Suppress leading zeros in each hextet
- Use :: to compress the longest sequence of consecutive zero hextets
- If multiple sequences of equal length exist, compress the leftmost sequence
- Do not use :: to compress a single zero hextet

**IPv6 Address Types**:

**Unicast Addresses**: Identify a single interface

- Global unicast: 2000::/3 (routable on internet)
- Link-local: fe80::/10 (used on single network segment)
- Unique local: fc00::/7 (private addresses, similar to IPv4 private ranges)

**Multicast Addresses**: ff00::/8 (deliver packets to multiple destinations)

**Anycast Addresses**: Assigned to multiple interfaces; packets delivered to nearest

**Special Addresses**:

- ::1/128: Loopback address (equivalent to 127.0.0.1)
- ::/128: Unspecified address (equivalent to 0.0.0.0)
- ::ffff:0:0/96: IPv4-mapped IPv6 addresses

**Scope Identifiers (Zone IDs)**:

Link-local addresses may include a zone identifier to specify the network interface:

```
fe80::1%eth0
fe80::1%1
```

The zone identifier follows a percent sign (%) and specifies the interface name or index.

## IPv6 Bracket Notation Requirement

When IPv6 addresses are used in URLs, they must be enclosed in square brackets to distinguish the colons in the address from the colon that separates the host from the port number.

**Mandatory Bracket Syntax**:

```
scheme://[IPv6address][:port][/path][?query][#fragment]
```

**Rationale for Brackets**:

Without brackets, ambiguity arises because both IPv6 addresses and URL syntax use colons:

```
Ambiguous:  http://2001:db8::1:8080/path
            Is ":8080" part of the address or the port?

Clear:      http://[2001:db8::1]:8080/path
            IPv6 address: 2001:db8::1
            Port: 8080
```

**URL Examples with IPv6 Addresses**:

```
http://[2001:db8::1]
http://[2001:db8::1]:8080
https://[2001:db8::1]/path/to/resource
http://[2001:db8::1]:3000/api/users?id=123
ftp://[2001:db8::1]/files/document.pdf
https://[2001:db8:0:42::8a2e:370:7334]:8443/admin
http://[::1]                              → IPv6 loopback
http://[::1]:8080                         → Local development server
```

**Bracket Notation Rules**:

**Required Elements**:

- Opening bracket [ must immediately follow the // in the authority component
- Closing bracket ] must appear after the complete IPv6 address
- No spaces allowed inside brackets
- IPv6 address must be valid according to IPv6 syntax rules

**With Port Numbers**:

```
Correct:   http://[2001:db8::1]:8080
Incorrect: http://[2001:db8::1:8080]     → Port inside brackets
Incorrect: http://2001:db8::1:8080       → Missing brackets
```

**Zone Identifier in URLs**:

When zone identifiers are included, they remain inside the brackets:

```
http://[fe80::1%eth0]
http://[fe80::1%eth0]:8080/path
```

However, percent signs in URLs are typically used for percent-encoding, which can create complications. The zone identifier's percent sign must be percent-encoded as %25:

```
http://[fe80::1%25eth0]
http://[fe80::1%25eth0]:8080/path
```

**Comparison with Domain Names**:

IPv6 addresses in URLs differ from domain names:

```
Domain:     http://example.com:8080
IPv4:       http://192.0.2.1:8080
IPv6:       http://[2001:db8::1]:8080
```

Only IPv6 addresses require brackets; IPv4 addresses and domain names do not.

**Browser and Client Support**:

[Inference based on modern standards] Contemporary web browsers and HTTP clients properly support IPv6 bracket notation. However, older software or improperly configured systems may not correctly parse IPv6 URLs.

**Parsing and Validation Challenges**:

URL parsers must:

- Detect opening bracket after // to identify IPv6 address
- Extract complete IPv6 address including compression
- Validate IPv6 syntax within brackets
- Distinguish closing bracket from path or query components
- Handle zone identifiers with percent-encoding
- Identify port number after closing bracket

**Invalid Examples**:

```
http://2001:db8::1                    → Missing brackets
http://[2001:db8::1                   → Missing closing bracket
http://2001:db8::1]                   → Missing opening bracket
http://[2001:db8::1:8080]/path        → Port inside brackets
http://[2001:db8::g1]                 → Invalid hex digit 'g'
http://[2001:db8:::1]                 → Multiple double colons
```

**HTTPS Certificate Validation**:

[Inference] HTTPS with IPv6 addresses faces similar challenges as with IPv4:

- Certificates are typically issued for domain names
- Subject Alternative Name (SAN) extension can include IP addresses
- Certificate validation may fail if IP address is not in certificate
- Many Certificate Authorities do not issue certificates for IP addresses

## IPv4-Mapped IPv6 Addresses

IPv4-mapped IPv6 addresses provide a mechanism to represent IPv4 addresses within the IPv6 address space, facilitating interoperability between IPv4 and IPv6 networks.

**Purpose and Usage**:

IPv4-mapped IPv6 addresses allow IPv6-enabled applications to communicate with IPv4-only nodes using IPv6 sockets. This dual-stack approach enables transition from IPv4 to IPv6 while maintaining backward compatibility.

**Address Format**:

IPv4-mapped IPv6 addresses use the prefix ::ffff:0:0/96, followed by the IPv4 address:

```
::ffff:IPv4address
```

**Representation Methods**:

**Method 1: Hexadecimal Notation**

The IPv4 address is converted to hexadecimal and represented as the last two hextets:

```
IPv4: 192.0.2.1

Binary: 11000000 00000000 00000010 00000001
Hex:    c0       00       02       01

IPv6:   ::ffff:c000:0201
```

**Method 2: Dotted-Decimal Notation**

The IPv4 address is represented in dotted-decimal format after the ::ffff: prefix:

```
IPv4:   192.0.2.1
IPv6:   ::ffff:192.0.2.1
```

This mixed notation is more readable and is the preferred representation.

**Complete Format Examples**:

```
Full form (hexadecimal):
0000:0000:0000:0000:0000:ffff:c000:0201

Compressed (hexadecimal):
::ffff:c000:0201

Compressed (dotted-decimal):
::ffff:192.0.2.1
```

**Common IPv4-Mapped IPv6 Addresses**:

```
IPv4 Address       Mapped IPv6 (hex)         Mapped IPv6 (dotted)
127.0.0.1          ::ffff:7f00:0001          ::ffff:127.0.0.1
192.168.1.1        ::ffff:c0a8:0101          ::ffff:192.168.1.1
10.0.0.1           ::ffff:0a00:0001          ::ffff:10.0.0.1
172.16.0.1         ::ffff:ac10:0001          ::ffff:172.16.0.1
8.8.8.8            ::ffff:0808:0808          ::ffff:8.8.8.8
```

**URL Syntax with IPv4-Mapped IPv6 Addresses**:

When used in URLs, IPv4-mapped IPv6 addresses follow IPv6 bracket notation requirements:

```
http://[::ffff:192.0.2.1]
http://[::ffff:192.0.2.1]:8080
https://[::ffff:192.0.2.1]/path/to/resource
http://[::ffff:127.0.0.1]:3000/api
```

**Comparison with Native Formats**:

The same address represented three ways:

```
Native IPv4:               http://192.0.2.1:8080
IPv4-mapped (hexadecimal): http://[::ffff:c000:0201]:8080
IPv4-mapped (dotted):      http://[::ffff:192.0.2.1]:8080
```

**Operational Context**:

**Dual-Stack Systems**: Systems supporting both IPv4 and IPv6 may use IPv4-mapped addresses internally:

- IPv6 sockets can accept connections from IPv4 clients
- Single socket can handle both IPv4 and IPv6 connections
- Operating system translates between address formats

**API and Socket Programming**: [Inference based on common socket implementation] When IPv6 sockets are configured with IPV6_V6ONLY disabled, they can accept IPv4 connections, representing them as IPv4-mapped IPv6 addresses.

**Network Address Translation**: NAT64 and similar transition mechanisms may use IPv4-mapped addresses to facilitate communication between IPv4 and IPv6 networks.

**Distinction from IPv4-Compatible Addresses**:

IPv4-compatible IPv6 addresses (deprecated) used the format ::IPv4address:

```
Deprecated IPv4-compatible: ::192.0.2.1
Current IPv4-mapped:        ::ffff:192.0.2.1
```

IPv4-compatible addresses are obsolete and should not be used. The ::ffff: prefix clearly identifies IPv4-mapped addresses.

**Validation and Parsing**:

Valid IPv4-mapped IPv6 addresses must:

- Begin with ::ffff: (or uncompressed form with all zeros and ffff in positions 5 and 6)
- Contain a valid IPv4 address after the prefix
- Follow standard IPv6 compression rules
- Use bracket notation in URLs

**Examples of Valid and Invalid Formats**:

```
Valid:
::ffff:192.0.2.1
::ffff:c000:0201
0000:0000:0000:0000:0000:ffff:192.0.2.1
[::ffff:192.0.2.1]                        (in URL)

Invalid:
::ffff:256.0.2.1                          → IPv4 octet exceeds 255
::ffff:192.0.2                            → Incomplete IPv4 address
::ffff::192.0.2.1                         → Double compression with prefix
::192.0.2.1                               → Missing ffff prefix (deprecated format)
```

**Application Behavior**:

[Inference] Different applications and systems may handle IPv4-mapped addresses differently:

**Web Servers**: May log IPv4-mapped addresses as native IPv4 for consistency **Access Control**: Security policies may need to recognize both formats **DNS**: Does not typically return IPv4-mapped IPv6 addresses; returns separate A (IPv4) and AAAA (IPv6) records

**Security Considerations**:

**Address Filtering**: Security systems must recognize that IPv4-mapped addresses can bypass IPv4-only filters:

- Firewall rules should account for both formats
- Access control lists should handle IPv4-mapped representations
- [Inference] Attackers might use IPv4-mapped format to evade detection

**Logging and Monitoring**: Systems should normalize addresses for consistent logging:

- Convert IPv4-mapped to native IPv4 for clarity
- Or consistently use one format across all logs
- Correlation requires recognizing equivalent addresses

**Application Compatibility**: Not all applications properly handle IPv4-mapped addresses:

- Some may reject them as invalid
- Others may not correctly extract the IPv4 portion
- Testing required for critical systems

**Best Practices**:

**Prefer Native Formats**: When possible, use native IPv4 or IPv6 addresses rather than IPv4-mapped format in URLs and configuration.

**Consistent Representation**: Within a system, use consistent address representation:

- Log files should use one format
- Configuration should use native formats when possible
- APIs should accept both but normalize internally

**Application Testing**: Test applications with:

- Native IPv4 addresses
- Native IPv6 addresses
- IPv4-mapped IPv6 addresses
- Both hexadecimal and dotted-decimal IPv4-mapped formats

**Documentation**: Clearly specify which address formats are supported and how they are processed.

The use of IP addresses directly in URLs, whether IPv4, IPv6, or IPv4-mapped IPv6, provides flexibility for direct network addressing but introduces considerations around syntax, security, and compatibility that differ from domain name usage. Understanding these formats and their proper representation in URLs is essential for robust network application development and troubleshooting.

---

## IPv4 Address Format in URLs

IPv4 addresses in URLs use the standard dotted-decimal notation without special delimiters.

### Basic Syntax

```
scheme://ipv4-address:port/path?query#fragment
```

**Example:**

```
http://192.168.1.1/admin
https://10.0.0.5:8443/api/data
ftp://203.0.113.42/files
```

### Dotted-Decimal Notation

IPv4 addresses consist of four decimal octets (0-255) separated by dots:

```
192.168.1.1
10.0.0.1
172.16.0.0
203.0.113.0
```

**Invalid formats:**

```
192.168.1          // Missing octets
192.168.1.256      // Octet exceeds 255
192.168.1.1.1      // Too many octets
192.168.01.1       // Leading zeros may cause issues
```

### Alternative IPv4 Notations

Some systems historically supported alternative representations, though these are discouraged in URLs:

**Decimal notation:**

```
http://3232235777/   // Equivalent to 192.168.1.1
```

Calculation: `(192 × 256³) + (168 × 256²) + (1 × 256) + 1 = 3232235777`

**Octal notation (deprecated):**

```
http://0300.0250.0001.0001/   // Equivalent to 192.168.1.1
```

**Hexadecimal notation (deprecated):**

```
http://0xC0.0xA8.0x01.0x01/   // Equivalent to 192.168.1.1
```

**Key Points:**

- Use standard dotted-decimal notation in URLs
- Alternative notations may be misinterpreted or blocked by security filters
- Modern browsers and applications generally reject non-standard formats
- Leading zeros can cause octal interpretation issues

### IPv4 Ranges and CIDR Notation

CIDR notation is not valid in URLs but is used for network configuration:

```
192.168.1.0/24     // Network notation (not a URL)
10.0.0.0/8         // Network notation (not a URL)
```

For URL purposes, specify individual IP addresses only.

## IPv6 Address Format in URLs

IPv6 addresses in URLs require square bracket delimiters to distinguish colons in the address from the port separator.

### Basic Syntax

```
scheme://[ipv6-address]:port/path?query#fragment
```

**Example:**

```
http://[2001:db8::1]/page.html
https://[2001:db8:85a3::8a2e:370:7334]:8443/api
ftp://[::1]/files
```

### Square Bracket Requirements

Square brackets are **mandatory** for IPv6 addresses in URLs to avoid ambiguity:

```
http://[2001:db8::1]:80/       // Correct
http://2001:db8::1:80/          // Incorrect - ambiguous colons
```

Without brackets, the parser cannot distinguish between address colons and the port separator.

### IPv6 Address Notation

**Full notation:**

```
[2001:0db8:0000:0000:0000:0000:0000:0001]
```

**Compressed notation (preferred):**

```
[2001:db8::1]
```

Rules for compression:

- Leading zeros in each hextet can be omitted
- One sequence of consecutive zero hextets can be replaced with `::`
- The `::` notation can appear only once per address

**Example:**

```
2001:0db8:0000:0000:0000:0000:0000:0001   // Full form
2001:db8:0:0:0:0:0:1                       // Leading zeros removed
2001:db8::1                                // Compressed
```

### IPv6 Address Components

IPv6 addresses consist of eight 16-bit hextets written in hexadecimal:

```
2001:db8:85a3:0:0:8a2e:370:7334
 │    │   │   │ │  │    │   │
 └────┴───┴───┴─┴──┴────┴───┴─── 8 hextets (128 bits total)
```

**Valid hexadecimal characters:** `0-9`, `a-f`, `A-F` (case insensitive)

### Special IPv6 Addresses in URLs

**Loopback address:**

```
http://[::1]/          // IPv6 localhost
http://[0:0:0:0:0:0:0:1]/   // Same address, uncompressed
```

**Unspecified address:**

```
[::] or [0:0:0:0:0:0:0:0]   // All zeros
```

**IPv4-mapped IPv6 addresses:**

```
[::ffff:192.168.1.1]        // IPv4 192.168.1.1 mapped to IPv6
[::ffff:c0a8:0101]          // Same address, hex notation
```

**IPv4-compatible IPv6 (deprecated):**

```
[::192.168.1.1]             // Deprecated format
```

### Link-Local Addresses

Link-local addresses require zone identifiers (see dedicated section):

```
[fe80::1%eth0]              // With zone identifier
[fe80::1%25eth0]            // URL-encoded zone identifier
```

## Zone Identifiers in IPv6

Zone identifiers (also called scope IDs) specify which network interface to use for link-local and site-local IPv6 addresses.

### Purpose and Use Cases

Zone identifiers are necessary because link-local addresses are not globally unique:

```
fe80::1    // Could exist on multiple network interfaces
```

Without a zone identifier, the system cannot determine which interface to use.

**Scenarios requiring zone identifiers:**

- Link-local addresses (fe80::/10)
- Site-local addresses (deprecated, fec0::/10)
- Multicast addresses with link-local or site-local scope
- Multiple network interfaces with overlapping address spaces

### Syntax

**Operating system syntax:**

```
fe80::1%eth0           // Linux/Unix
fe80::1%en0            // macOS
fe80::1%3              // Windows (interface index)
fe80::1%Local Area Connection  // Windows (interface name)
```

**URL syntax:** The `%` character must be percent-encoded as `%25` in URLs:

```
http://[fe80::1%25eth0]/       // Correct URL encoding
http://[fe80::1%eth0]/         // Invalid - unencoded %
```

**Example:**

```
# System command
ping6 fe80::1%eth0

# Equivalent URL
http://[fe80::1%25eth0]:8080/api
```

### Zone Identifier Format

**Interface names (Linux/macOS):**

```
[fe80::1%25lo]          // Loopback interface
[fe80::1%25eth0]        // Ethernet interface 0
[fe80::1%25wlan0]       // Wireless interface 0
[fe80::1%25en0]         // macOS Ethernet
[fe80::1%25bridge0]     // Bridge interface
```

**Interface indices (Windows/numeric):**

```
[fe80::1%251]           // Interface index 1
[fe80::1%252]           // Interface index 2
[fe80::1%2512]          // Interface index 12
```

**Encoded special characters:** If interface names contain special characters, additional encoding may be required:

```
[fe80::1%25Local%20Area%20Connection]   // Windows interface with spaces
```

### Validation Rules

Zone identifiers have specific validation requirements:

**Allowed characters (before URL encoding):**

- Alphanumeric: `a-z`, `A-Z`, `0-9`
- Special: `-`, `.`, `_`, `~`
- System-specific characters [Operating system-dependent]

**Length limitations:**

- Maximum length varies by operating system [Typically 15-255 characters]
- Shorter names preferred for compatibility

**Case sensitivity:**

- Generally case-insensitive on most systems [Operating system-dependent]
- Preserve case for best compatibility

### Browser and Application Support

**Support status:**

- Modern browsers support zone identifiers with `%25` encoding
- Older browsers may reject URLs with zone identifiers
- Some HTTP libraries require explicit zone identifier support
- Server applications rarely need to handle zone identifiers [Typically used for client-side local connections]

**Example** browser behavior:

```javascript
// Modern browsers
fetch('http://[fe80::1%25eth0]:8080/api')
  .then(response => response.json())
  .catch(error => console.error(error));

// May work in some contexts
new URL('http://[fe80::1%25eth0]/path')
```

### Security Considerations

**Zone identifier validation:**

- Always validate zone identifiers to prevent injection attacks
- Restrict to known interface names or indices
- Reject unexpected characters or formats

**Information disclosure:** Interface names can reveal system configuration [Inference]:

```
[fe80::1%25corporate_network]   // Reveals network naming
[fe80::1%25eth0_dmz]            // Reveals network topology
```

**Access control:** Link-local addresses with zone identifiers should be restricted to localhost or trusted networks [Inference - security best practice].

### Practical Examples

**Web server on link-local address:**

```bash
# Start server
python3 -m http.server 8000 --bind fe80::1%eth0

# Access from same machine
curl 'http://[fe80::1%25eth0]:8000/'

# Access from another machine on same link
curl 'http://[fe80::1%25eth1]:8000/'  # Using client's interface
```

**Docker container networking:**

```bash
# Container with IPv6 link-local
docker run -p [fe80::1%25docker0]:8080:80 nginx

# Access container
curl 'http://[fe80::1%25docker0]:8080/'
```

**IoT device discovery:**

```javascript
// Discover devices on local network
const devices = [
  'http://[fe80::1%25eth0]:8080',
  'http://[fe80::2%25eth0]:8080',
  'http://[fe80::3%25eth0]:8080'
];

// Query each device
devices.forEach(url => {
  fetch(url + '/status')
    .then(response => response.json())
    .then(data => console.log(data));
});
```

**Key Points:**

- Zone identifiers specify network interface for link-local addresses
- `%` must be encoded as `%25` in URLs
- Required for fe80::/10 addresses on multi-interface systems
- Format varies by operating system (names vs. indices)
- Validate zone identifiers to prevent security issues
- Support varies across browsers and HTTP libraries

## IP Address Validation

Proper validation of IP addresses in URLs is essential for security, functionality, and compatibility.

### IPv4 Validation Rules

**Structural validation:**

1. Exactly four octets separated by dots
2. Each octet is a decimal number
3. Each octet is between 0 and 255
4. No leading zeros (to avoid octal interpretation ambiguity)
5. No whitespace or extra characters

**Regular expression (basic):**

```regex
^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$
```

**Example** validation logic:

```javascript
function isValidIPv4(ip) {
  const octets = ip.split('.');
  if (octets.length !== 4) return false;
  
  return octets.every(octet => {
    const num = parseInt(octet, 10);
    // Check no leading zeros, valid range
    return octet === num.toString() && num >= 0 && num <= 255;
  });
}

// Valid
isValidIPv4('192.168.1.1')      // true
isValidIPv4('255.255.255.255')  // true
isValidIPv4('0.0.0.0')          // true

// Invalid
isValidIPv4('192.168.1')        // false - too few octets
isValidIPv4('192.168.1.256')    // false - octet > 255
isValidIPv4('192.168.01.1')     // false - leading zero
isValidIPv4('192.168.1.1.1')    // false - too many octets
```

**Edge cases:**

```
0.0.0.0              // Valid (unspecified address)
255.255.255.255      // Valid (broadcast address)
192.168.001.1        // Invalid (leading zero)
192.168.1.1a         // Invalid (non-numeric)
192.168. 1.1         // Invalid (whitespace)
```

### IPv6 Validation Rules

**Structural validation:**

1. 0 to 8 hextets (with compression, minimum 2)
2. Each hextet is 1-4 hexadecimal characters
3. Hextets separated by colons
4. At most one `::` compression
5. Optional zone identifier after `%`
6. Optional IPv4 suffix for mapped addresses

**Complexity considerations:** IPv6 validation is significantly more complex than IPv4 due to:

- Multiple valid representations of the same address
- Compression rules with `::`
- Zone identifiers
- IPv4-mapped addresses
- Case insensitivity

**Regular expression (comprehensive):**

```regex
^(([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|
   ([0-9a-fA-F]{1,4}:){1,7}:|
   ([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|
   ([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|
   ([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|
   ([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|
   ([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|
   [0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|
   :((:[0-9a-fA-F]{1,4}){1,7}|:)|
   fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|
   ::(ffff(:0{1,4}){0,1}:){0,1}
   ((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3}
   (25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|
   ([0-9a-fA-F]{1,4}:){1,4}:
   ((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3}
   (25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$
```

**Example** validation function:

```javascript
function isValidIPv6(ip) {
  // Remove zone identifier if present
  const [address, zone] = ip.split('%');
  
  // Split into hextets
  const parts = address.split(':');
  
  // Check for :: compression
  const emptyIndex = parts.indexOf('');
  const hasCompression = emptyIndex !== -1;
  
  if (hasCompression) {
    // Remove consecutive empty strings (::)
    const filtered = parts.filter((p, i) => {
      return p !== '' || (i > 0 && parts[i-1] !== '');
    });
    
    // After compression, must have fewer than 8 hextets
    if (filtered.length >= 8) return false;
  } else {
    // Without compression, must have exactly 8 hextets
    if (parts.length !== 8) return false;
  }
  
  // Validate each hextet
  return parts.every(part => {
    if (part === '') return hasCompression; // Empty only valid with ::
    if (part.length > 4) return false;
    return /^[0-9a-fA-F]+$/.test(part);
  });
}

// Valid
isValidIPv6('2001:db8::1')                    // true
isValidIPv6('2001:db8:85a3::8a2e:370:7334')   // true
isValidIPv6('::1')                            // true
isValidIPv6('fe80::1')                        // true

// Invalid
isValidIPv6('2001:db8::1::2')                 // false - multiple ::
isValidIPv6('gggg::1')                        // false - invalid hex
isValidIPv6('2001:db8:1')                     // false - too few hextets
```

### URL Context Validation

In addition to address format validation, URLs require additional checks:

**Square bracket validation (IPv6):**

```javascript
function extractIPv6FromURL(url) {
  const match = url.match(/\[([^\]]+)\]/);
  return match ? match[1] : null;
}

// Extract and validate
const url = 'http://[2001:db8::1]:8080/path';
const ip = extractIPv6FromURL(url);
if (ip && isValidIPv6(ip)) {
  // Valid IPv6 URL
}
```

**Port validation:**

```javascript
function validateIPURL(url) {
  const parsed = new URL(url);
  const hostname = parsed.hostname;
  const port = parsed.port;
  
  // Check if hostname is valid IP
  const isIPv4 = isValidIPv4(hostname);
  const isIPv6 = hostname.startsWith('[') && 
                 hostname.endsWith(']') &&
                 isValidIPv6(hostname.slice(1, -1));
  
  // Validate port if present
  if (port && (parseInt(port) < 1 || parseInt(port) > 65535)) {
    return false;
  }
  
  return isIPv4 || isIPv6;
}
```

### Library-Based Validation

Most programming languages provide IP address validation libraries:

**JavaScript (using built-in URL API):**

```javascript
function isValidIP(ip) {
  try {
    // IPv4
    new URL(`http://${ip}`);
    return true;
  } catch {
    try {
      // IPv6
      new URL(`http://[${ip}]`);
      return true;
    } catch {
      return false;
    }
  }
}
```

**Python (using ipaddress module):**

```python
import ipaddress

def is_valid_ip(ip):
    try:
        ipaddress.ip_address(ip)
        return True
    except ValueError:
        return False

# Usage
is_valid_ip('192.168.1.1')    # True
is_valid_ip('2001:db8::1')    # True
is_valid_ip('invalid')        # False
```

**Node.js (using net module):**

```javascript
const net = require('net');

function isValidIP(ip) {
  return net.isIP(ip) !== 0;
}

function isIPv4(ip) {
  return net.isIP(ip) === 4;
}

function isIPv6(ip) {
  return net.isIP(ip) === 6;
}
```

### Security Validation

**SSRF (Server-Side Request Forgery) prevention:** Validate IP addresses to prevent access to internal networks:

```javascript
function isPrivateIPv4(ip) {
  const octets = ip.split('.').map(Number);
  
  // 10.0.0.0/8
  if (octets[0] === 10) return true;
  
  // 172.16.0.0/12
  if (octets[0] === 172 && octets[1] >= 16 && octets[1] <= 31) return true;
  
  // 192.168.0.0/16
  if (octets[0] === 192 && octets[1] === 168) return true;
  
  // 127.0.0.0/8 (loopback)
  if (octets[0] === 127) return true;
  
  // 169.254.0.0/16 (link-local)
  if (octets[0] === 169 && octets[1] === 254) return true;
  
  return false;
}

function isPrivateIPv6(ip) {
  // ::1 (loopback)
  if (ip === '::1' || ip === '0:0:0:0:0:0:0:1') return true;
  
  // fc00::/7 (unique local)
  if (ip.startsWith('fc') || ip.startsWith('fd')) return true;
  
  // fe80::/10 (link-local)
  if (ip.startsWith('fe8') || ip.startsWith('fe9') || 
      ip.startsWith('fea') || ip.startsWith('feb')) return true;
  
  return false;
}
```

**Allowlist approach:**

```javascript
function isSafeExternalIP(ip) {
  if (isValidIPv4(ip)) {
    return !isPrivateIPv4(ip) && 
           !isSpecialUseIPv4(ip);
  }
  if (isValidIPv6(ip)) {
    return !isPrivateIPv6(ip) && 
           !isSpecialUseIPv6(ip);
  }
  return false;
}
```

**Key Points:**

- Use established libraries for validation when possible
- Regular expressions for IP addresses are complex and error-prone
- Validate both format and security constraints
- Consider context-specific requirements (URL encoding, square brackets)
- Test edge cases thoroughly
- Implement SSRF protections for user-supplied IP addresses

## Localhost Addresses

Localhost addresses refer to the local machine itself and are used for testing, development, and inter-process communication.

### IPv4 Localhost

**Primary loopback address:**

```
127.0.0.1
```

**Entire loopback range (127.0.0.0/8):**

```
127.0.0.0 to 127.255.255.255
```

All addresses in this range refer to the local machine [Specification: RFC 1122].

**Example:**

```
http://127.0.0.1/
http://127.0.0.1:3000/
http://127.1.2.3:8080/         // Also valid loopback
```

**Common usage:**

```
http://127.0.0.1               // Default web development
http://127.0.0.1:3000          // Node.js development server
http://127.0.0.1:8000          // Python HTTP server
http://127.0.0.1:8080          // Alternative web port
```

### IPv6 Localhost

**Loopback address:**

```
::1
```

**Full notation:**

```
0:0:0:0:0:0:0:1
```

**Example:**

```
http://[::1]/
http://[::1]:8080/
http://[0:0:0:0:0:0:0:1]:3000/
```

### Hostname Localhost

The hostname `localhost` typically resolves to loopback addresses:

```
localhost → 127.0.0.1 (IPv4)
localhost → ::1 (IPv6)
```

**Example:**

```
http://localhost/
http://localhost:3000/
https://localhost:8443/
```

**DNS resolution:**

- Usually resolved via `/etc/hosts` or system hosts file
- May resolve to both IPv4 and IPv6 [System-dependent]
- IPv4 often preferred for compatibility [System-dependent]

**Hosts file entries:**

```
# /etc/hosts (Unix/Linux/macOS)
127.0.0.1       localhost
::1             localhost

# C:\Windows\System32\drivers\etc\hosts (Windows)
127.0.0.1       localhost
::1             localhost
```

### Localhost vs 127.0.0.1 vs ::1

**Functional differences:**

1. **localhost** (hostname):
    
    - Requires DNS/hosts resolution
    - May resolve to IPv4, IPv6, or both
    - Slightly slower due to resolution step [Inference]
    - More readable and conventional
2. **127.0.0.1** (IPv4):
    
    - Direct IPv4 connection
    - No DNS resolution required
    - Guaranteed IPv4 behavior
    - Faster initial connection [Inference]
3. **::1** (IPv6):
    
    - Direct IPv6 connection
    - Requires IPv6 support
    - May not work on IPv4-only systems
    - Future-proof approach

**Example** behavior differences:

```bash
# May try IPv6 first, then IPv4
curl http://localhost:8080/

# Forces IPv4
curl http://127.0.0.1:8080/

# Forces IPv6
curl http://[::1]:8080/
```

### Special Localhost Behaviors

**Firewall bypass:** Localhost connections often bypass firewall rules [System-dependent]:

```
http://127.0.0.1:8080/    // May bypass firewall
http://192.168.1.5:8080/  // Subject to firewall rules
```

**Cookie restrictions:** Cookies on localhost have special handling [Browser-dependent]:

- Some browsers treat localhost specially for cookie security
- `.localhost` subdomain cookies may behave differently

**HTTPS on localhost:** Browsers make exceptions for localhost HTTPS:

- Self-signed certificates generate warnings but may be allowed
- Some browsers have special localhost certificate trust [Browser-dependent]

**CORS (Cross-Origin Resource Sharing):** Localhost origins are treated distinctly:

```
http://localhost:3000     // Different origin from
http://localhost:8080     // this (different ports)

http://127.0.0.1:3000     // Different origin from
http://localhost:3000     // this (different hostnames)
```

### Development and Testing

**Binding to localhost:** Servers can bind specifically to localhost for security:

```javascript
// Node.js - accessible only from local machine
server.listen(3000, '127.0.0.1', () => {
  console.log('Server on http://127.0.0.1:3000/');
});

// Bind to all interfaces (less secure)
server.listen(3000, '0.0.0.0', () => {
  console.log('Server accessible from network');
});
```

**Port conflicts:** Multiple services can run on localhost with different ports:

```
http://localhost:3000      // React app
http://localhost:5000      // Flask API
http://localhost:8080      // Backend service
http://localhost:27017     // MongoDB
```

**Database connections:**

```
mongodb://localhost:27017/mydb
postgresql://localhost:5432/mydb
redis://localhost:6379
mysql://localhost:3306/mydb
```

### Security Considerations

**Localhost is trusted:** Applications often skip authentication or security checks for localhost [Varies by application]:

```javascript
if (request.hostname === 'localhost' || 
    request.hostname === '127.0.0.1') {
  // Skip authentication
  // This creates security risks
}
```

**Local network exposure:** Binding to `0.0.0.0` exposes services to the local network:

```
Bound to 127.0.0.1 → Only accessible from same machine
Bound to 0.0.0.0   → Accessible from any interface
Bound to 192.168.1.5 → Accessible from local network
```

**DNS rebinding attacks:** Attackers may exploit localhost resolution [Inference - known attack vector]:

- Malicious sites resolving to 127.0.0.1
- Bypassing same-origin policy
- Accessing local services

**Protection mechanisms:**

```javascript
// Validate Host header
if (!['localhost', '127.0.0.1', '[::1]'].includes(request.hostname)) {
  return 403; // Forbidden
}

// Require authentication even for localhost
if (isProductionMode() && !authenticated) {
  return 401; // Unauthorized
}
```

**Key Points:**

- 127.0.0.0/8 range entirely reserved for loopback
- IPv6 loopback is only ::1 (not a range)
- localhost hostname may resolve to IPv4, IPv6, or both
- Localhost connections often bypass security mechanisms
- Different ports create different origins for CORS
- Binding to 0.0.0.0 exposes services beyond localhost

## Special-Use Addresses

Certain IP address ranges are reserved for special purposes and should not be used for general internet communication.

### IPv4 Special-Use Ranges

**0.0.0.0/8 - This Network:**

```
0.0.0.0 to 0.255.255.255
```

**Usage:**

- Source address for unknown/unspecified host
- Used in DHCP before address assignment
- "Any" address for server binding

**Example:**

```javascript
// Bind to all interfaces
server.listen(3000, '0.0.0.0');
```

**Not valid in URLs** as a destination address.

**10.0.0.0/8 - Private Network:**

```
10.0.0.0 to 10.255.255.255
```

**Usage:**

- Large private networks
- Corporate networks
- Not routable on public internet

**Example:**

```
http://10.0.1.50/internal-app
http://10.20.30.40:8080/api
```

**127.0.0.0/8 - Loopback:**

```
127.0.0.0 to 127.255.255.255
```

Covered in the Localhost section above.

**169.254.0.0/16 - Link-Local:**

```
169.254.0.0 to 169.254.255.255
```

**Usage:**

- Automatic Private IP Addressing (APIPA)
- Used when DHCP fails
- Only valid on local network segment

**Example:**

```
http://169.254.1.1/           // Auto-configured device
```

**172.16.0.0/12 - Private Network:**

```
172.16.0.0 to 172.31.255.255
```

**Usage:**

- Medium private networks
- Often used by Docker, VPNs

**Example:**

```
http://172.16.0.1/admin
http://172.18.0.2:8080/       // Docker container
```

**192.0.0.0/24 - IETF Protocol Assignments:**

```
192.0.0.0 to 192.0.0.255
```

**Usage:**

- Reserved for IETF protocol use
- Special documentation and examples

**192.0.2.0/24 - Documentation (TEST-NET-1):**

```
192.0.2.0 to 192.0.2.255
```

**Usage:**

- Documentation examples
- Should never appear in real network traffic

**Example:**

```
http://192.0.2.1/example       // Safe for documentation
```

**192.168.0.0/16 - Private Network:**

```
192.168.0.0 to 192.168.255.255
```

**Usage:**

- Small private networks
- Home networks
- Most

---

# Port Numbers

Port numbers are 16-bit unsigned integers that identify specific processes or network services on a host machine. In URI syntax, ports appear as part of the authority component and enable multiple services to operate on a single host by multiplexing network connections.

## Port Component Syntax

### Basic Syntax Structure

The port component in URI syntax consists of zero or more decimal digits following a colon after the host:

```
authority = [userinfo@]host[:port]
port = *DIGIT
```

**Position in URI:**

```
scheme://host:port/path?query#fragment
           └──┬──┘
              port
```

### Character Restrictions

**Allowed characters:** Only decimal digits (0-9)

**No other characters permitted:**

- No letters: `http://example.com:80ab/` is invalid
- No signs: `http://example.com:+80/` is invalid
- No spaces: `http://example.com:80 80/` is invalid
- No hexadecimal: `http://example.com:0x50/` is invalid

**Example valid ports:**

```
http://example.com:80/
https://example.com:443/
http://localhost:3000/
ftp://ftp.example.com:21/
```

**Example invalid ports:**

```
http://example.com:8080a/     // Contains letter
http://example.com:80.80/     // Contains period
http://example.com:0x50/      // Hexadecimal notation
http://example.com:-80/       // Negative sign
```

### Length Limitations

**Maximum value:** 65535 (2^16 - 1)

**Minimum value:** 0

**Binary representation:** 16 bits

**Decimal digits:** 1 to 5 digits maximum

```
Valid range examples:
0       // Minimum
1       // Single digit
80      // Two digits
8080    // Four digits
65535   // Maximum (five digits)

Invalid:
65536   // Exceeds maximum
100000  // Exceeds maximum
```

### Empty Port Syntax

A colon followed immediately by a delimiter represents an empty port:

```
http://example.com:/path
                  ↑
              empty port
```

**RFC 3986 interpretation:** Syntactically valid but semantically means "use default port"

**WHATWG interpretation:** Treated as if no port was specified

**Example behavior:**

```javascript
// WHATWG URL API
const url = new URL('http://example.com:/path');
console.log(url.port);  // "" (empty string)
console.log(url.href);  // "http://example.com/path"
```

### Port Separator Ambiguity

The colon (`:`) serves multiple purposes in URIs, requiring careful parsing:

**Separates username from password:**

```
http://user:pass@example.com/
           ↑
    password separator
```

**Separates host from port:**

```
http://example.com:8080/
                  ↑
           port separator
```

**Part of IPv6 address:**

```
http://[2001:db8::1]:8080/
            ↑     ↑     ↑
     IPv6 colons  port separator
```

**Parsing rule:** The last colon outside of brackets (after the host) indicates the port separator.

**Example parsing:**

```
http://user:pass@example.com:8080/path
        ↑1       ↑2              ↑3

Colon 1: Password separator (in userinfo)
Colon 2: End of userinfo (before @)
Colon 3: Port separator (last colon in authority)
```

**IPv6 example:**

```
http://[2001:db8::1]:8080/
        └─IPv6 addr─┘ ↑
                   port separator (after ])
```

### Leading Zeros

RFC 3986 allows leading zeros in port numbers, but they are interpreted as decimal (not octal):

```
http://example.com:0080/
                   ↑
            leading zeros
```

**Interpretation:** Always decimal, never octal

```
:0080  →  80 (decimal)
:0123  →  123 (decimal, NOT octal)
:00080 →  80 (decimal)
```

**Normalization:** Leading zeros should be removed:

```
Original:   http://example.com:0080/
Normalized: http://example.com:80/
            http://example.com/     (if 80 is default for scheme)
```

**Comparison with IPv4:** Unlike IPv4 octets where leading zeros historically indicated octal (implementation-dependent), port numbers are always decimal regardless of leading zeros.

### Port Parsing Algorithm

**Step-by-step process:**

1. **Locate the port separator:**
    
    - Find the last colon in the authority component
    - Ensure it's outside IPv6 brackets (after `]` if present)
    - Ensure it's after the userinfo component (after `@` if present)
2. **Extract port string:**
    
    - All characters between the colon and the next delimiter (`/`, `?`, `#`, or end)
3. **Validate characters:**
    
    - Verify all characters are decimal digits (0-9)
    - Empty string is valid (means default port)
4. **Parse as integer:**
    
    - Convert string to integer (ignore leading zeros)
    - Treat empty string as "no port specified"
5. **Range validation:**
    
    - Verify value is between 0 and 65535 inclusive
    - Values outside this range are invalid

**Example implementation:**

```javascript
function parsePort(authority) {
  // Find last colon outside brackets
  let colonIndex = -1;
  let inBrackets = false;
  
  for (let i = authority.length - 1; i >= 0; i--) {
    if (authority[i] === ']') inBrackets = true;
    if (authority[i] === '[') inBrackets = false;
    if (authority[i] === ':' && !inBrackets) {
      colonIndex = i;
      break;
    }
  }
  
  if (colonIndex === -1) return null; // No port
  
  const portString = authority.slice(colonIndex + 1);
  
  // Validate digits only
  if (!/^\d*$/.test(portString)) {
    throw new Error('Invalid port: non-digit characters');
  }
  
  // Empty port string means default
  if (portString === '') return null;
  
  const port = parseInt(portString, 10);
  
  // Validate range
  if (port < 0 || port > 65535) {
    throw new Error('Invalid port: out of range');
  }
  
  return port;
}

// Usage
parsePort('example.com:8080');           // 8080
parsePort('[2001:db8::1]:8080');         // 8080
parsePort('example.com:');               // null (empty port)
parsePort('example.com:65536');          // Error: out of range
parsePort('example.com:80abc');          // Error: non-digit characters
```

### Port in Different URI Components

**Authority component only:** Port numbers only appear in the authority component, never in path, query, or fragment:

```
Valid:   http://example.com:8080/path?query#fragment
Invalid: http://example.com/path:8080
Invalid: http://example.com/path?port=8080:value
```

**Multiple colons handling:**

```
Userinfo with port:
ftp://user:pass@example.com:21/
      └userinfo┘ └─host──┘ └┘
                          port

IPv6 with port:
http://[fe80::1]:8080/
       └IPv6──┘ └─┘
                port
```

## Default Ports by Scheme

### Concept of Default Ports

Default ports are standard port numbers associated with specific URI schemes. When a URI omits the port component, the default port for that scheme is assumed.

**Purpose:**

- Simplify URI syntax by omitting commonly-used ports
- Establish standard conventions for protocols
- Enable automatic connection to correct service

**Behavior:**

```
http://example.com/
// Implicitly: http://example.com:80/

https://example.com/
// Implicitly: https://example.com:443/
```

### Common Scheme Default Ports

**HTTP (Hypertext Transfer Protocol):**

```
Scheme: http://
Default port: 80
Example: http://example.com/ → connects to port 80
```

**HTTPS (HTTP Secure):**

```
Scheme: https://
Default port: 443
Example: https://example.com/ → connects to port 443
```

**FTP (File Transfer Protocol):**

```
Scheme: ftp://
Default port: 21 (control connection)
Note: FTP also uses port 20 for data transfer (active mode)
Example: ftp://ftp.example.com/ → connects to port 21
```

**FTPS (FTP Secure):**

```
Scheme: ftps://
Default port: 990 (implicit FTPS)
Note: Explicit FTPS uses port 21
```

**SSH (Secure Shell):**

```
Scheme: ssh://
Default port: 22
Example: ssh://user@example.com/ → connects to port 22
```

**Telnet:**

```
Scheme: telnet://
Default port: 23
Example: telnet://example.com/ → connects to port 23
```

**SMTP (Simple Mail Transfer Protocol):**

```
Scheme: smtp://
Default port: 25 (unencrypted)
Alternative ports: 587 (submission), 465 (SMTPS)
```

**DNS (Domain Name System):**

```
Scheme: dns://
Default port: 53
```

**LDAP (Lightweight Directory Access Protocol):**

```
Scheme: ldap://
Default port: 389
Example: ldap://directory.example.com/ → connects to port 389
```

**LDAPS (LDAP Secure):**

```
Scheme: ldaps://
Default port: 636
```

**WebSocket:**

```
Scheme: ws://
Default port: 80
Example: ws://example.com/socket → connects to port 80
```

**WebSocket Secure:**

```
Scheme: wss://
Default port: 443
Example: wss://example.com/socket → connects to port 443
```

**RTSP (Real Time Streaming Protocol):**

```
Scheme: rtsp://
Default port: 554
```

**SIP (Session Initiation Protocol):**

```
Scheme: sip://
Default port: 5060 (unencrypted)
Alternative: 5061 (encrypted SIPS)
```

**IRC (Internet Relay Chat):**

```
Scheme: irc://
Default port: 6667 (unencrypted)
Alternative: 6697 (SSL/TLS)
```

**MQTT (Message Queuing Telemetry Transport):**

```
Scheme: mqtt://
Default port: 1883 (unencrypted)
Alternative: 8883 (encrypted)
```

**Redis:**

```
Scheme: redis://
Default port: 6379
```

**PostgreSQL:**

```
Scheme: postgresql://
Default port: 5432
Example: postgresql://localhost/mydb → connects to port 5432
```

**MySQL:**

```
Scheme: mysql://
Default port: 3306
```

**MongoDB:**

```
Scheme: mongodb://
Default port: 27017
```

### Default Port Normalization

URLs specifying the default port explicitly should be normalized to omit it:

**HTTP examples:**

```
http://example.com:80/path
Normalized: http://example.com/path

http://example.com:80/
Normalized: http://example.com/
```

**HTTPS examples:**

```
https://example.com:443/api
Normalized: https://example.com/api
```

**Non-default ports remain:**

```
http://example.com:8080/
// Not normalized (8080 ≠ 80)

https://example.com:8443/
// Not normalized (8443 ≠ 443)
```

### Equivalence with Default Ports

For URI comparison, explicit default ports are equivalent to omitted ports:

**Equivalent URIs:**

```
http://example.com/path
http://example.com:80/path
// These are equivalent

https://example.com/api
https://example.com:443/api
// These are equivalent
```

**Not equivalent:**

```
http://example.com/path
http://example.com:8080/path
// Different ports (80 vs 8080)

http://example.com/path
https://example.com/path
// Different schemes (different default ports: 80 vs 443)
```

### WHATWG URL API Behavior

The WHATWG URL API automatically handles default ports:

**Port property returns empty string for defaults:**

```javascript
const url1 = new URL('http://example.com/');
console.log(url1.port);  // "" (empty, using default 80)

const url2 = new URL('http://example.com:80/');
console.log(url2.port);  // "" (empty, normalized)

const url3 = new URL('http://example.com:8080/');
console.log(url3.port);  // "8080" (non-default, preserved)
```

**Setting default port:**

```javascript
const url = new URL('http://example.com:8080/');
url.port = '80';  // Set to default
console.log(url.port);  // "" (empty)
console.log(url.href);  // "http://example.com/"
```

**Host property behavior:**

```javascript
const url1 = new URL('http://example.com:80/');
console.log(url1.host);      // "example.com" (no port)
console.log(url1.hostname);  // "example.com"

const url2 = new URL('http://example.com:8080/');
console.log(url2.host);      // "example.com:8080" (includes port)
console.log(url2.hostname);  // "example.com"
```

### Scheme-Specific Considerations

**File URLs:** The `file://` scheme typically doesn't use network ports as it accesses local filesystem:

```
file:///path/to/file
// No port concept for local files
```

**Data URLs:** The `data:` scheme embeds data directly and has no host or port:

```
data:text/plain;base64,SGVsbG8=
// No authority component
```

**Mailto URLs:** The `mailto:` scheme doesn't specify a port (SMTP client handles connection):

```
mailto:user@example.com
// No port in URI (SMTP uses port 25/587/465)
```

## Well-Known Ports (0-1023)

### Definition and Characteristics

Well-known ports are port numbers from 0 to 1023, reserved for common services and protocols by IANA (Internet Assigned Numbers Authority).

**Key characteristics:**

**Privileged ports:** On Unix-like systems (Linux, macOS, BSD), binding to these ports requires root/superuser privileges.

**Standardization:** Registered with IANA for specific services to ensure global consistency.

**Historical significance:** Established early in Internet history for foundational protocols.

**System services:** Typically used by operating system services rather than user applications.

### Privilege Requirements

**Unix-like systems:**

```bash
# Requires root privileges
sudo node server.js  # Binding to port 80

# Alternative: Use capabilities (Linux)
sudo setcap 'cap_net_bind_service=+ep' /usr/bin/node
node server.js  # Can now bind to port 80 without full root
```

**Windows:** No special privileges required to bind to any port.

**Security implications:**

- Privilege requirement provides security boundary
- Prevents regular users from impersonating system services
- Reduces attack surface by limiting who can bind to critical ports

### Major Well-Known Ports

**Port 20 - FTP Data:**

```
Protocol: FTP (File Transfer Protocol) - Data channel
Usage: Active mode data transfer
Related: Port 21 (control channel)
```

**Port 21 - FTP Control:**

```
Protocol: FTP - Control channel
Usage: Commands and responses
Example: ftp://ftp.example.com/ → port 21
```

**Port 22 - SSH:**

```
Protocol: SSH (Secure Shell)
Usage: Secure remote login, command execution, file transfer (SFTP, SCP)
Example: ssh://user@example.com/ → port 22
Common tools: OpenSSH, PuTTY
```

**Port 23 - Telnet:**

```
Protocol: Telnet
Usage: Unencrypted text communication
Security: Deprecated due to lack of encryption (use SSH instead)
Example: telnet://example.com/ → port 23
```

**Port 25 - SMTP:**

```
Protocol: SMTP (Simple Mail Transfer Protocol)
Usage: Email transmission between mail servers
Example: smtp://mail.example.com/ → port 25
Note: Often blocked by ISPs to prevent spam
```

**Port 53 - DNS:**

```
Protocol: DNS (Domain Name System)
Usage: Domain name resolution
Transport: UDP (primarily), TCP (for large responses, zone transfers)
Example: dns://8.8.8.8/ → port 53
```

**Port 67/68 - DHCP:**

```
Port 67: DHCP Server
Port 68: DHCP Client
Protocol: DHCP (Dynamic Host Configuration Protocol)
Usage: Automatic IP address assignment
```

**Port 69 - TFTP:**

```
Protocol: TFTP (Trivial File Transfer Protocol)
Usage: Simple file transfer (no authentication)
Transport: UDP
Common use: Network device firmware updates
```

**Port 80 - HTTP:**

```
Protocol: HTTP (Hypertext Transfer Protocol)
Usage: Unencrypted web traffic
Example: http://example.com/ → port 80
Default for: Web browsers, web servers
```

**Port 110 - POP3:**

```
Protocol: POP3 (Post Office Protocol version 3)
Usage: Email retrieval from server
Example: pop3://mail.example.com/ → port 110
Secure alternative: Port 995 (POP3S)
```

**Port 119 - NNTP:**

```
Protocol: NNTP (Network News Transfer Protocol)
Usage: Usenet news reading/posting
Example: nntp://news.example.com/ → port 119
```

**Port 123 - NTP:**

```
Protocol: NTP (Network Time Protocol)
Usage: Clock synchronization
Transport: UDP
Example: Time servers like time.nist.gov:123
```

**Port 143 - IMAP:**

```
Protocol: IMAP (Internet Message Access Protocol)
Usage: Email access and management
Example: imap://mail.example.com/ → port 143
Secure alternative: Port 993 (IMAPS)
```

**Port 161/162 - SNMP:**

```
Port 161: SNMP Agent
Port 162: SNMP Trap
Protocol: SNMP (Simple Network Management Protocol)
Usage: Network device monitoring and management
```

**Port 389 - LDAP:**

```
Protocol: LDAP (Lightweight Directory Access Protocol)
Usage: Directory services access
Example: ldap://directory.example.com/ → port 389
Secure alternative: Port 636 (LDAPS)
```

**Port 443 - HTTPS:**

```
Protocol: HTTPS (HTTP Secure)
Usage: Encrypted web traffic (HTTP over TLS/SSL)
Example: https://example.com/ → port 443
Default for: Secure web browsers, web APIs
```

**Port 445 - SMB:**

```
Protocol: SMB (Server Message Block)
Usage: Windows file sharing, printer sharing
Also known as: Microsoft-DS
Security: Frequently targeted by malware
```

**Port 465 - SMTPS:**

```
Protocol: SMTPS (SMTP Secure)
Usage: Email submission over SSL/TLS (deprecated, then revived)
Note: Port 587 with STARTTLS is preferred
```

**Port 514 - Syslog:**

```
Protocol: Syslog
Usage: System logging
Transport: UDP (traditionally), TCP (modern)
```

**Port 587 - SMTP Submission:**

```
Protocol: SMTP (Mail Submission)
Usage: Email client to mail server submission
Security: Typically requires authentication and STARTTLS
Preferred over: Port 25 for email clients
```

**Port 636 - LDAPS:**

```
Protocol: LDAPS (LDAP Secure)
Usage: LDAP over SSL/TLS
Example: ldaps://directory.example.com/ → port 636
```

**Port 853 - DNS over TLS:**

```
Protocol: DoT (DNS over TLS)
Usage: Encrypted DNS queries
Example: Cloudflare's 1.1.1.1:853
```

**Port 989/990 - FTPS:**

```
Port 989: FTPS Data (implicit)
Port 990: FTPS Control (implicit)
Protocol: FTPS (FTP over SSL/TLS)
Usage: Secure file transfer
```

**Port 993 - IMAPS:**

```
Protocol: IMAPS (IMAP Secure)
Usage: IMAP over SSL/TLS
Example: imaps://mail.example.com/ → port 993
```

**Port 995 - POP3S:**

```
Protocol: POP3S (POP3 Secure)
Usage: POP3 over SSL/TLS
Example: pop3s://mail.example.com/ → port 995
```

### Reserved and Special Ports

**Port 0:**

```
Meaning: System-assigned port
Usage: Request OS to assign any available port
Not valid in URIs: Cannot explicitly specify port 0
Example use case: Socket binding in programming
```

```python
# Python example
import socket
sock = socket.socket()
sock.bind(('', 0))  # OS assigns available port
actual_port = sock.getsockname()[1]
print(f"Assigned port: {actual_port}")
```

**Ports 1-9:** Various historical services, rarely used today.

**Port 7 - Echo:**

```
Protocol: Echo
Usage: Testing, debugging (echoes back received data)
Security: Typically disabled due to abuse potential
```

**Port 9 - Discard:**

```
Protocol: Discard
Usage: Testing (discards all received data)
Security: Typically disabled
```

### Security Considerations for Well-Known Ports

**Common attack targets:**

- Port 22 (SSH): Brute-force attacks, credential stuffing
- Port 80/443 (HTTP/HTTPS): Web application attacks, DDoS
- Port 25 (SMTP): Spam relay attempts
- Port 445 (SMB): Ransomware, worm propagation
- Port 3389 (RDP): Brute-force attacks

**[Inference] Best practices:**

- Change default ports for sensitive services when possible
- Use firewall rules to restrict access
- Implement rate limiting and intrusion detection
- Disable unused services
- Use VPNs or SSH tunneling for remote access

**Port scanning awareness:** Well-known ports are frequently scanned by attackers searching for vulnerable services.

```bash
# Example: Common port scan (informational only)
nmap -p 20-1023 target.example.com
```

## Registered Ports (1024-49151)

### Definition and Characteristics

Registered ports are port numbers from 1024 to 49151, registered with IANA for specific services but not requiring special privileges to bind.

**Key characteristics:**

**User-accessible:** Any user can bind to these ports (no root/admin required on most systems).

**Semi-standardized:** IANA maintains registry, but enforcement is voluntary.

**Application services:** Typically used by user applications and services.

**Flexibility:** Can be used for custom services while having standard options available.

### IANA Registration Process

**Purpose of registration:**

- Avoid port conflicts between applications
- Establish conventions for common services
- Provide discovery mechanism for services

**Note:** [Unverified] Specific current IANA registration procedures and requirements.

**Registration does not guarantee:**

- Exclusive use (multiple applications may use same port)
- Universal adoption
- Conflict-free operation

### Major Registered Ports

**Port 1080 - SOCKS:**

```
Protocol: SOCKS (Socket Secure)
Usage: Proxy protocol for routing network packets
Example: socks5://proxy.example.com:1080/
Versions: SOCKS4, SOCKS5
```

**Port 1194 - OpenVPN:**

```
Protocol: OpenVPN
Usage: VPN connections
Transport: UDP (default), TCP
Example: openvpn://vpn.example.com:1194/
```

**Port 1433 - Microsoft SQL Server:**

```
Protocol: MS-SQL-S
Usage: Microsoft SQL Server database
Example: mssql://server.example.com:1433/
```

**Port 1521 - Oracle Database:**

```
Protocol: Oracle SQL*Net
Usage: Oracle database connections
Example: oracle://db.example.com:1521/
```

**Port 1723 - PPTP:**

```
Protocol: PPTP (Point-to-Point Tunneling Protocol)
Usage: VPN connections (legacy, less secure)
```

**Port 2049 - NFS:**

```
Protocol: NFS (Network File System)
Usage: Distributed file system
Example: nfs://fileserver.example.com:2049/export
```

**Port 2181 - Apache ZooKeeper:**

```
Protocol: ZooKeeper
Usage: Distributed coordination service
Example: Used by Kafka, Hadoop
```

**Port 2375/2376 - Docker:**

```
Port 2375: Docker daemon (unencrypted)
Port 2376: Docker daemon (TLS encrypted)
Usage: Docker API
Security: Port 2375 should never be exposed publicly
```

**Port 3000 - Development servers:**

```
Common usage: Default port for many development frameworks
Examples:
- Node.js applications (Express, Next.js default)
- Ruby on Rails development server
- Various frontend dev servers
```

**Port 3306 - MySQL:**

```
Protocol: MySQL
Usage: MySQL/MariaDB database
Example: mysql://localhost:3306/database
```

**Port 3389 - RDP:**

```
Protocol: RDP (Remote Desktop Protocol)
Usage: Windows remote desktop
Security: Frequently targeted by attacks
Alternative: Use VPN or SSH tunnel
```

**Port 4000-4999 - Various services:**

```
Port 4443: Common alternative HTTPS port
Port 4567: Sinatra (Ruby framework) default
Port 5000: Flask (Python framework) default, UPnP
```

**Port 5432 - PostgreSQL:**

```
Protocol: PostgreSQL
Usage: PostgreSQL database
Example: postgresql://localhost:5432/mydb
Connection string: postgres://user:pass@host:5432/db
```

**Port 5601 - Kibana:**

```
Protocol: Kibana web interface
Usage: Elasticsearch data visualization
Example: http://localhost:5601/
```

**Port 5672 - AMQP:**

```
Protocol: AMQP (Advanced Message Queuing Protocol)
Usage: Message broker (RabbitMQ default)
Management UI: Port 15672
```

**Port 5900-5999 - VNC:**

```
Protocol: VNC (Virtual Network Computing)
Usage: Remote desktop access
Port calculation: 5900 + display number
Example: Display :0 → port 5900, Display :1 → port 5901
```

**Port 6379 - Redis:**

```
Protocol: Redis
Usage: In-memory data store
Example: redis://localhost:6379/
Security: Should not be exposed publicly without authentication
```

**Port 6667 - IRC:**

```
Protocol: IRC (Internet Relay Chat)
Usage: Chat protocol (unencrypted)
Alternative: Port 6697 (SSL/TLS)
```

**Port 7000-7001 - Cassandra:**

```
Port 7000: Inter-node communication
Port 7001: TLS inter-node communication
Protocol: Apache Cassandra
```

**Port 8000 - Alternative HTTP:**

```
Common usage: Development servers, testing
Examples:
- Python SimpleHTTPServer default
- Django development server
- Alternative web servers
```

**Port 8008 - Alternative HTTP:**

```
Usage: HTTP alternate (often used for APIs)
Example: Internal services, development
```

**Port 8080 - HTTP Proxy/Alternative:**

```
Common usage: Most common HTTP alternative port
Uses:
- Development servers
- Proxy servers
- Application servers (Tomcat default)
- Testing environments
Example: http://localhost:8080/
```

**Port 8081-8089 - HTTP Alternatives:**

```
Usage: Additional HTTP ports for multiple services
Common in: Microservices architectures
```

**Port 8181 - Alternative HTTP:**

```
Usage: Common alternative for web services
Example: GlassFish admin console default
```

**Port 8443 - Alternative HTTPS:**

```
Common usage: Most common HTTPS alternative port
Uses:
- Development HTTPS servers
- Application servers
- Testing SSL/TLS
Example: https://localhost:8443/
```

**Port 8888 - Alternative HTTP:**

```
Common usage: Jupyter Notebook default, proxy servers
Example: http://localhost:8888/
```

**Port 9000 - Various services:**

```
Common usage:
- PHP-FPM default
- SonarQube default
- Alternative web servers
```

**Port 9090 - Prometheus:**

```
Protocol: Prometheus metrics
Usage: Monitoring and alerting
Example: http://localhost:9090/
```

**Port 9200 - Elasticsearch:**

```
Protocol: Elasticsearch HTTP API
Usage: Search and analytics engine
Example: http://localhost:9200/
```

**Port 9300 - Elasticsearch transport:**

```
Protocol: Elasticsearch transport
Usage: Node-to-node communication
```

**Port 9999 - Various applications:**

```
Usage: Commonly used as placeholder/testing port
```

**Port 11211 - Memcached:**

```
Protocol: Memcached
Usage: Distributed memory caching
Security: Should not be exposed publicly
```

**Port 15672 - RabbitMQ Management:**

```
Protocol: RabbitMQ HTTP API
Usage: Management interface
Example: http://localhost:15672/
```

**Port 27017 - MongoDB:**

```
Protocol: MongoDB
Usage: MongoDB database
Example: mongodb://localhost:27017/
Security: Should require authentication
```

**Port 27018 - MongoDB sharded:**

```
Usage: MongoDB sharded cluster
```

**Port 28017 - MongoDB HTTP status:**

```
Usage: MongoDB HTTP status interface (legacy)
```

### Development and Testing Ports

**Common conventions in development:**

**3000-3999 range:** Commonly used by JavaScript frameworks and Node.js applications:

```
3000: Express.js, React, Next.js defaults
3001: Common alternative for second dev server
3030: Alternative Node.js apps
```

**4000-4999 range:** Various development frameworks:

```
4000: Common alternative HTTP port
4200: Angular development server default
4567: Sinatra (Ruby) default
```

**5000-5999 range:** Python frameworks and various services:

```
5000: Flask default
5173: Vite default
5432: PostgreSQL (also used in development)
```

**8000-8999 range:** Most popular range for development HTTP servers:

```
8000: Django, Python SimpleHTTPServer
8080: Most common HTTP alternative
8443: HTTPS alternative
8888: Jupyter Notebook
```

### Port Selection Best Practices

**[Inference] Guidelines for choosing ports:**

**Check IANA registry:** Verify port isn't already registered for conflicting service.

**Avoid well-known ports:** Don't use 0-1023 unless necessary and you have privileges.

**Use common alternatives for common protocols:**

- 8080, 8000 for HTTP
- 8443 for HTTPS
- 3000-3999 for Node.js applications

**Document port usage:** Clearly document which ports your application uses.

**Make ports configurable:** Allow users to change ports via configuration.

**Check for conflicts:** Verify port isn't already in use on the system:

```bash
# Linux/macOS
lsof -i :8080
netstat -an | grep 8080

# Windows
netstat -an | findstr 8080
```

**Consider firewall implications:** Some ports may be blocked by corporate firewalls.

**Use environment variables:** Allow runtime port configuration:

```javascript
const PORT = process.env.PORT || 3000;
```

### Port Ranges for Specific Purposes

**Microservices architecture:** Common pattern is to assign consecutive ports:

```
Service A: 8080
Service B: 8081 
Service C: 8082 
Admin API: 8090
```

**Database services:**
```
PostgreSQL: 5432 
MySQL: 3306 
MongoDB: 27017 
Redis: 6379 
Cassandra: 9042
```

**Message queues:**
```
RabbitMQ: 5672 (AMQP), 15672 (Management) 
Kafka: 9092 
ActiveMQ: 61616
```

**Monitoring and metrics:**
```
Prometheus: 9090 
Grafana: 3000 
Elasticsearch: 9200 
Kibana: 5601
```

### Security Considerations for Registered Ports

**No privilege protection:**
Any user can bind to these ports, increasing potential for:
- Port conflicts
- Malicious services impersonating legitimate ones
- Unauthorized service exposure

**[Inference] Common security issues:**

**Exposed databases:**
```
3306 (MySQL), 5432 (PostgreSQL), 27017 (MongoDB) // Should never be exposed to public internet without authentication
```

**Development servers in production:**
```
Port 3000, 8000 (common dev servers) // Development servers lack production security features
```

**Management interfaces:**
```
Port 2375 (Docker), 15672 (RabbitMQ Management) // Should be firewalled or require strong authentication
````

**[Inference] Security best practices:**

**Firewall configuration:**
```bash
# Example: Allow only specific ports (Linux iptables)
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -j DROP  # Deny all other ports
````

**Bind to localhost only for internal services:**

```javascript
// Node.js example
server.listen(3000, '127.0.0.1', () => {
  console.log('Server listening on localhost:3000');
});
```

**Use authentication:**

```
// MongoDB with authentication
mongodb://user:password@localhost:27017/mydb

// Redis with authentication
redis://password@localhost:6379/
```

**Use reverse proxies:**

```
External: Port 443 (HTTPS)
    ↓
Reverse Proxy (Nginx/Apache)
    ↓
Internal: Port 3000, 8080, etc.
```

### Port Scanning and Discovery

**Service discovery mechanisms:**

**Port scanning tools:**

```bash
# Nmap scan of registered ports
nmap -p 1024-49151 target.example.com

# Scan specific services
nmap -p 3306,5432,27017 target.example.com
```

**Service fingerprinting:** Many services respond with identifying information on connection:

```bash
# Banner grabbing example
nc localhost 27017
# May reveal: MongoDB version information
```

**[Inference] Protection against scanning:**

- Implement rate limiting
- Use intrusion detection systems (IDS)
- Configure fail2ban or similar tools
- Monitor logs for scanning patterns
- Use port knocking for sensitive services

## Practical Applications

### Port Configuration in Applications

**Environment-based configuration:**

**Node.js example:**

```javascript
const express = require('express');
const app = express();

const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || '0.0.0.0';

app.listen(PORT, HOST, () => {
  console.log(`Server running on ${HOST}:${PORT}`);
});
```

**Python Flask example:**

```python
import os
from flask import Flask

app = Flask(__name__)

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    host = os.environ.get('HOST', '0.0.0.0')
    app.run(host=host, port=port)
```

**Configuration file approach:**

```json
{
  "server": {
    "host": "localhost",
    "port": 8080,
    "ssl": {
      "enabled": true,
      "port": 8443
    }
  },
  "database": {
    "host": "db.example.com",
    "port": 5432
  }
}
```

### URL Construction with Ports

**Dynamic URL building:**

```javascript
function buildDatabaseURL(config) {
  const { 
    protocol = 'postgresql',
    username,
    password,
    host,
    port = 5432,  // Default PostgreSQL port
    database
  } = config;
  
  let url = `${protocol}://`;
  
  if (username) {
    url += username;
    if (password) {
      url += `:${password}`;
    }
    url += '@';
  }
  
  url += host;
  
  // Only include port if non-default
  if (port !== getDefaultPort(protocol)) {
    url += `:${port}`;
  }
  
  if (database) {
    url += `/${database}`;
  }
  
  return url;
}

function getDefaultPort(protocol) {
  const defaults = {
    'postgresql': 5432,
    'mysql': 3306,
    'mongodb': 27017,
    'redis': 6379
  };
  return defaults[protocol];
}

// Usage
const dbURL = buildDatabaseURL({
  protocol: 'postgresql',
  username: 'admin',
  password: 'secret',
  host: 'localhost',
  port: 5432,
  database: 'myapp'
});
// Result: postgresql://admin:secret@localhost/myapp
// (Port 5432 omitted as it's default)
```

### Port Validation

**Comprehensive port validation function:**

```javascript
function validatePort(port) {
  // Convert to number if string
  const portNum = typeof port === 'string' ? parseInt(port, 10) : port;
  
  // Check if valid number
  if (isNaN(portNum)) {
    return {
      valid: false,
      error: 'Port must be a number'
    };
  }
  
  // Check range
  if (portNum < 0 || portNum > 65535) {
    return {
      valid: false,
      error: 'Port must be between 0 and 65535'
    };
  }
  
  // Check if integer
  if (!Number.isInteger(portNum)) {
    return {
      valid: false,
      error: 'Port must be an integer'
    };
  }
  
  return {
    valid: true,
    port: portNum,
    category: getPortCategory(portNum),
    requiresPrivilege: portNum < 1024
  };
}

function getPortCategory(port) {
  if (port === 0) return 'system-assigned';
  if (port < 1024) return 'well-known';
  if (port < 49152) return 'registered';
  return 'dynamic/private';
}

// Usage
console.log(validatePort(80));
// { valid: true, port: 80, category: 'well-known', requiresPrivilege: true }

console.log(validatePort(8080));
// { valid: true, port: 8080, category: 'registered', requiresPrivilege: false }

console.log(validatePort(99999));
// { valid: false, error: 'Port must be between 0 and 65535' }
```

### Port Conflict Detection

**Checking if port is available:**

**Node.js example:**

```javascript
const net = require('net');

function isPortAvailable(port, host = '0.0.0.0') {
  return new Promise((resolve) => {
    const server = net.createServer();
    
    server.once('error', (err) => {
      if (err.code === 'EADDRINUSE') {
        resolve(false);  // Port in use
      } else {
        resolve(false);  // Other error
      }
    });
    
    server.once('listening', () => {
      server.close();
      resolve(true);  // Port available
    });
    
    server.listen(port, host);
  });
}

// Find next available port
async function findAvailablePort(startPort = 3000, maxAttempts = 10) {
  for (let i = 0; i < maxAttempts; i++) {
    const port = startPort + i;
    if (await isPortAvailable(port)) {
      return port;
    }
  }
  throw new Error(`No available port found in range ${startPort}-${startPort + maxAttempts}`);
}

// Usage
(async () => {
  const port = await findAvailablePort(3000);
  console.log(`Using port: ${port}`);
})();
```

### Multi-Port Applications

**Applications listening on multiple ports:**

```javascript
const express = require('express');
const https = require('https');
const http = require('http');
const fs = require('fs');

const app = express();

// HTTP server on port 8080
const httpServer = http.createServer(app);
httpServer.listen(8080, () => {
  console.log('HTTP server on port 8080');
});

// HTTPS server on port 8443
const httpsOptions = {
  key: fs.readFileSync('key.pem'),
  cert: fs.readFileSync('cert.pem')
};
const httpsServer = https.createServer(httpsOptions, app);
httpsServer.listen(8443, () => {
  console.log('HTTPS server on port 8443');
});

// Admin API on different port
const adminApp = express();
adminApp.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});
adminApp.listen(9090, 'localhost', () => {
  console.log('Admin API on localhost:9090');
});
```

### Reverse Proxy Port Mapping

**Nginx configuration example:**

```nginx
# External requests to port 80/443
server {
    listen 80;
    listen 443 ssl;
    server_name example.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    # Map to internal service on port 3000
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Map API to different internal port
    location /api/ {
        proxy_pass http://localhost:8080/;
    }
}
```

**Benefits:**

- Hide internal port structure
- Terminate SSL at proxy
- Load balance across multiple backend ports
- Add authentication layer

### Port in Connection Strings

**Database connection examples:**

**PostgreSQL:**

```javascript
const connectionString = 'postgresql://user:password@localhost:5432/mydb';
// or
const config = {
  host: 'localhost',
  port: 5432,
  database: 'mydb',
  user: 'user',
  password: 'password'
};
```

**MongoDB:**

```javascript
const uri = 'mongodb://user:password@localhost:27017/mydb?authSource=admin';
// Multiple hosts with ports
const uri = 'mongodb://host1:27017,host2:27017,host3:27017/mydb?replicaSet=rs0';
```

**Redis:**

```javascript
const redisClient = redis.createClient({
  host: 'localhost',
  port: 6379,
  password: 'password'
});
// or with URL
const redisClient = redis.createClient({
  url: 'redis://password@localhost:6379/0'
});
```

### Testing with Ports

**Test isolation using random ports:**

```javascript
const request = require('supertest');
const app = require('./app');

describe('API Tests', () => {
  let server;
  let port;
  
  beforeAll(async () => {
    // Get random available port
    port = await findAvailablePort(10000);
    server = app.listen(port);
  });
  
  afterAll((done) => {
    server.close(done);
  });
  
  test('GET /', async () => {
    const response = await request(`http://localhost:${port}`)
      .get('/')
      .expect(200);
    expect(response.body).toHaveProperty('message');
  });
});
```

### Docker Port Mapping

**Mapping container ports to host ports:**

```bash
# Map container port 80 to host port 8080
docker run -p 8080:80 nginx

# Map container port 3000 to random host port
docker run -p 3000 myapp

# Map to specific host interface
docker run -p 127.0.0.1:8080:80 nginx

# Multiple port mappings
docker run -p 8080:80 -p 8443:443 webserver
```

**Docker Compose example:**

```yaml
version: '3'
services:
  web:
    image: nginx
    ports:
      - "8080:80"      # host:container
      - "8443:443"
  
  api:
    build: ./api
    ports:
      - "3000:3000"
    
  database:
    image: postgres
    ports:
      - "5432:5432"
    environment:
      POSTGRES_PASSWORD: password
```

### Important subtopics to explore further:

- **Dynamic Port Allocation:** How operating systems assign ephemeral ports (49152-65535) for client connections
- **Port Forwarding and NAT:** How routers and firewalls handle port translation for internal networks
- **Service Discovery:** How microservices architectures discover and register service ports dynamically
- **Port Security Scanning:** Tools and techniques for auditing port exposure and security
- **Cloud Platform Port Restrictions:** How cloud providers (AWS, Azure, GCP) handle port access and security groups

---

## Dynamic/Private Ports (49152-65535)

Dynamic ports, also known as private ports or ephemeral ports, occupy the range 49152-65535 as defined by IANA. These ports serve specific purposes in network communications and have distinct characteristics compared to well-known and registered ports.

**Port Range Categories:**

```
0-1023         Well-Known Ports (System Ports)
1024-49151     Registered Ports (User Ports)
49152-65535    Dynamic/Private Ports (Ephemeral Ports)
```

### Ephemeral Port Assignment

Operating systems automatically assign ephemeral ports for client-side connections when applications do not specify a source port. This occurs during outbound connection establishment.

**Connection Process:**

```
Client Application Request:
    Source: [OS assigns from ephemeral range]
    Destination: server.example.com:443

Example Assignment:
    Client: 192.0.2.10:51234 → Server: 203.0.113.5:443
                   ↑
            Ephemeral port
```

When a client initiates a TCP connection or sends UDP packets, the OS selects an available port from the ephemeral range. This port remains allocated for the connection's duration and is then released for reuse.

### Operating System Variations

Different operating systems use different ephemeral port ranges:

**Linux (kernel 2.4+):**

```
Default Range: 32768-60999
Configuration: /proc/sys/net/ipv4/ip_local_port_range
```

**Windows:**

```
Windows XP/Server 2003: 1025-5000
Windows Vista/7/Server 2008+: 49152-65535
Configuration: netsh int ipv4 set dynamicport tcp start=49152 num=16384
```

**FreeBSD:**

```
Default Range: 10000-65535
Configuration: sysctl net.inet.ip.portrange.first and net.inet.ip.portrange.last
```

**macOS:**

```
Default Range: 49152-65535
Configuration: sysctl net.inet.ip.portrange.first and net.inet.ip.portrange.hifirst
```

**Solaris:**

```
Default Range: 32768-65535
Configuration: /etc/default/ndd parameters
```

These variations can impact firewall rules, NAT configurations, and application behavior across different platforms.

### Port Exhaustion

Ephemeral port exhaustion occurs when all available ports in the dynamic range are allocated, preventing new outbound connections.

**Causes:**

- High connection volume from single source IP
- Connection pooling without proper closure
- TIME_WAIT state accumulation (TCP connections in closing phase)
- Inadequate ephemeral port range size
- Rapid connection cycling (connection thrashing)

**TIME_WAIT Impact:**

TCP connections entering the TIME_WAIT state (typically 2 minutes on Linux) consume ephemeral ports:

```
Available Ports: 28232 (Linux default: 60999 - 32768 + 1)
Connection Rate: 200 connections/second
TIME_WAIT Duration: 120 seconds

Ports in TIME_WAIT: 200 × 120 = 24,000 ports
Remaining Available: 28,232 - 24,000 = 4,232 ports
```

At sustained high rates, port exhaustion becomes likely.

**Mitigation Strategies:**

```
Expand ephemeral range:
    sysctl -w net.ipv4.ip_local_port_range="10000 65535"

Reduce TIME_WAIT duration (with caution):
    sysctl -w net.ipv4.tcp_fin_timeout=30

Enable TCP time-wait reuse:
    sysctl -w net.ipv4.tcp_tw_reuse=1

Enable TCP time-wait recycling (deprecated in newer kernels):
    sysctl -w net.ipv4.tcp_tw_recycle=1
```

[Inference] These kernel parameters affect TCP behavior and may have tradeoffs with connection reliability. TIME_WAIT exists to prevent delayed packets from corrupting new connections using the same port tuple.

### Private Port Services

While designated for dynamic allocation, some services use ports in this range for permanent services:

```
Examples:
    Port 49152: Used by some proprietary applications
    Port 50000-50100: SAP systems (though SAP uses various ranges)
    Port 60000: X11 forwarding on some systems
```

Using dynamic range ports for permanent services creates potential conflicts with ephemeral port allocation. Applications requiring fixed ports should use registered ports (1024-49151) or well-known ports when appropriate.

## Port Omission Rules

URI specifications define when ports can be omitted from the authority component. Port omission follows scheme-specific default port conventions.

### Default Ports by Scheme

Each URI scheme defines a default port used when none is specified:

```
http://example.com/path           → Port 80 implied
https://example.com/path          → Port 443 implied
ftp://example.com/file            → Port 21 implied (control)
ssh://example.com                 → Port 22 implied
telnet://example.com              → Port 23 implied
smtp://mail.example.com           → Port 25 implied
dns://ns.example.com              → Port 53 implied
ws://example.com/socket           → Port 80 implied
wss://example.com/socket          → Port 443 implied
```

### Explicit Default Port Specification

Including the default port explicitly is syntactically valid but semantically equivalent to omission:

```
http://example.com:80/path        (explicit default)
http://example.com/path           (implicit default)
    → Both refer to identical resource
```

### Canonical URI Form

URI normalization for comparison or canonicalization typically removes explicit default ports:

**Before Normalization:**

```
https://example.com:443/path?query
http://example.com:80/
ftp://example.com:21/file
```

**After Normalization:**

```
https://example.com/path?query
http://example.com/
ftp://example.com/file
```

This normalization enables proper URI comparison and deduplication. Two URIs differing only in explicit versus implicit default ports are equivalent.

### URI Comparison with Ports

When comparing URIs, port handling follows these rules:

```
Same URIs:
    http://example.com/path
    http://example.com:80/path

Different URIs:
    http://example.com:8080/path
    http://example.com/path

Different URIs:
    https://example.com/path       (port 443)
    http://example.com/path        (port 80)
```

Scheme changes imply different default ports, making the URIs distinct even with identical hosts and paths.

### Empty Port Specification

A colon followed by no port number is syntactically valid but has ambiguous interpretation:

```
http://example.com:/path
```

**Possible Interpretations:**

1. Treat as default port (most common implementation)
2. Treat as error/invalid URI
3. Treat as distinct from default port

[Inference] Different URI parsers may handle this differently, so it should be avoided in production URIs.

### Port in Relative References

Relative URI references that include authority must specify the entire authority component:

```
Base URI: http://example.com:8080/app/page

Relative Reference: //other.com/path
    Resolves to: http://other.com:80/path
    (Uses default port for scheme, not base URI port)

Relative Reference: //other.com:9000/path
    Resolves to: http://other.com:9000/path
```

Relative references do not inherit the port from the base URI when specifying a different authority.

## Non-Standard Port Usage

Non-standard ports are any ports differing from the scheme's default. They require explicit specification in URIs and have various implications for deployment and accessibility.

### Common Non-Standard Port Patterns

**Development Environments:**

```
http://localhost:3000         (React/Node.js development server)
http://localhost:4200         (Angular development server)
http://localhost:8000         (Python HTTP server)
http://localhost:8080         (Common alternative HTTP port)
http://localhost:5000         (Flask default)
```

**Alternative HTTP/HTTPS Ports:**

```
http://example.com:8080       (HTTP alternate)
http://example.com:8000       (HTTP alternate)
http://example.com:8888       (HTTP alternate)
https://example.com:8443      (HTTPS alternate)
https://example.com:9443      (HTTPS alternate)
```

**Proxy and Control Ports:**

```
http://proxy.example.com:3128 (Squid proxy)
http://proxy.example.com:8118 (Privoxy)
http://example.com:8001       (Kubernetes API proxy)
```

**Application-Specific Ports:**

```
http://jenkins.example.com:8080     (Jenkins CI/CD)
http://tomcat.example.com:8080      (Apache Tomcat)
http://grafana.example.com:3000     (Grafana monitoring)
http://prometheus.example.com:9090  (Prometheus)
```

### Port Selection Considerations

**Avoiding Privileged Ports:**

Ports 0-1023 require root/administrator privileges to bind on Unix-like systems:

```
Port 80:   Requires root privileges
Port 8080: Available to non-privileged users
```

Applications often use ports above 1024 to avoid requiring elevated permissions during development or deployment.

**Firewall and Network Compatibility:**

Many networks restrict outbound connections to standard ports:

```
Commonly Allowed:
    80 (HTTP)
    443 (HTTPS)
    22 (SSH, sometimes restricted)

Often Blocked:
    8080, 8000, 3000, etc.
```

Corporate firewalls, public Wi-Fi networks, and mobile carriers may block non-standard ports, limiting accessibility.

**Load Balancer and Reverse Proxy Patterns:**

```
External Access:
    https://example.com:443 → Load Balancer

Internal Routing:
    Load Balancer → http://backend1:8080
                 → http://backend2:8080
                 → http://backend3:8080
```

Public-facing services use standard ports while internal services use non-standard ports, with reverse proxies handling translation.

### Multiple Services on Single Host

Non-standard ports enable multiple services on one host/IP address:

```
http://server.example.com:8080    (Application A)
http://server.example.com:8081    (Application B)
http://server.example.com:8082    (Application C)
https://server.example.com:443    (Main website)
https://server.example.com:8443   (Admin panel)
```

This approach is common in development environments, container deployments, and resource-constrained scenarios.

### DNS SRV Records and Service Discovery

SRV records in DNS can specify non-standard ports for services:

```
_service._proto.example.com. IN SRV priority weight port target
_http._tcp.example.com.      IN SRV 10 60 8080 server1.example.com.
_http._tcp.example.com.      IN SRV 10 40 8080 server2.example.com.
```

[Inference] This enables service discovery where clients query DNS to determine the appropriate port, but HTTP/HTTPS clients typically do not use SRV records without explicit application support.

### Virtual Host Limitations

HTTP virtual hosting (multiple domains on one IP) relies on the Host header:

```
Same Port, Different Domains:
    http://site1.example.com:8080 → Virtual host: site1.example.com
    http://site2.example.com:8080 → Virtual host: site2.example.com

Different Ports, Same Domain:
    http://example.com:8080 → Service A
    http://example.com:8081 → Service B
```

Virtual hosting works across different ports, but each port requires separate listener configuration on the server.

## Security Implications of Port Exposure

Exposing services on network ports creates various security considerations. Port exposure, particularly non-standard port usage, has implications for attack surface, reconnaissance, and access control.

### Attack Surface and Port Scanning

**Information Disclosure:**

Open ports reveal service presence to attackers conducting reconnaissance:

```
Port Scan Results:
    Port 80:   Open (HTTP)
    Port 22:   Open (SSH)
    Port 8080: Open (HTTP alternate)
    Port 3306: Open (MySQL)
    Port 27017: Open (MongoDB)
```

Each open port provides information about deployed services and potential attack vectors. [Inference] Attackers can fingerprint services by banner grabbing or analyzing response behaviors to identify software versions and potential vulnerabilities.

**Port Scanning Techniques:**

```
TCP SYN Scan:
    Attacker → SYN → Target:8080
    Target → SYN-ACK (port open) or RST (port closed)

TCP Connect Scan:
    Complete three-way handshake
    More detectable but works without raw socket access

UDP Scan:
    Send UDP packet to port
    No response = open|filtered
    ICMP port unreachable = closed
```

[Inference] Port scans are detectable through IDS/IPS systems, but stealthy scanning techniques can evade detection.

### Firewall Configuration

**Default-Deny Policy:**

Secure firewall configurations block all ports except explicitly allowed services:

```
iptables Example:
    # Block all incoming by default
    iptables -P INPUT DROP
    
    # Allow specific services
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT
    iptables -A INPUT -p tcp --dport 443 -j ACCEPT
    iptables -A INPUT -p tcp --dport 22 -s 203.0.113.0/24 -j ACCEPT
```

**Port Exposure Principles:**

Minimize exposed ports:

- Only open ports required for legitimate functionality
- Use non-routable addresses (RFC 1918) for internal services
- Implement source IP restrictions where feasible
- Close ports immediately when services are decommissioned

### Database and Service Port Exposure

**Commonly Exposed Database Ports:**

```
MySQL:      3306
PostgreSQL: 5432
MongoDB:    27017
Redis:      6379
Cassandra:  9042
```

Exposing database ports directly to the internet creates significant risks:

- Direct authentication attacks against database services
- Exploitation of database software vulnerabilities
- Data exfiltration if authentication is compromised
- Denial of service through resource exhaustion

**Mitigation:**

```
Network Architecture:
    Internet → Firewall → Application Tier → Database Tier
                                           (No direct access)

Access Control:
    Database port only accessible from application servers
    VPN or bastion host required for administrative access
```

### Administrative Interface Exposure

Administrative interfaces on non-standard ports remain discoverable:

```
http://example.com:8443/admin
http://example.com:9000/management
http://example.com:8080/jenkins
```

**Risks:**

- Brute force attacks against administrative credentials
- Exploitation of management interface vulnerabilities
- Unauthorized configuration changes if accessed
- Information disclosure about system architecture

**Protection Measures:**

```
IP Whitelisting:
    Allow access only from specific IP ranges
    VPN requirement for administrative access

Authentication:
    Multi-factor authentication
    Strong password policies
    Certificate-based authentication

Rate Limiting:
    Limit login attempts
    CAPTCHA after failed attempts
    Account lockout policies
```

### Port Knocking and Security Through Obscurity

Port knocking involves sending connection attempts to specific closed ports in sequence to open a normally closed port:

```
Sequence: 1234, 5678, 9012 → Opens port 22 briefly
```

[Unverified] Port knocking provides an additional layer of defense against automated scanning but should not replace strong authentication. It relies on security through obscurity, which is not a substitute for proper security controls.

### SSL/TLS and Encrypted Ports

Using HTTPS on non-standard ports provides encryption but does not hide the port number:

```
https://example.com:8443/api
    → Port 8443 is visible to network observers
    → Traffic content is encrypted
    → Metadata (IP, port, packet timing/size) remains visible
```

**Deep Packet Inspection (DPI):**

[Inference] Even with encryption, network intermediaries can:

- Identify which ports are being accessed
- Analyze traffic patterns and timing
- Potentially identify protocols through traffic analysis

Encryption protects content but not connection metadata.

### Container and Microservice Port Exposure

Container orchestration platforms expose services through various mechanisms:

**Docker:**

```
docker run -p 8080:80 nginx
    → Host port 8080 maps to container port 80
    → Port 8080 exposed on host network interface
```

**Kubernetes:**

```
Service Types:
    ClusterIP: Internal cluster access only (no external exposure)
    NodePort:  Exposes on each node's IP at static port (30000-32767)
    LoadBalancer: Cloud load balancer with external IP
```

**Security Considerations:**

- Inadvertent external exposure through port mapping
- Port conflicts when mapping multiple containers
- Privilege escalation if container port binding allows host access
- Network policy enforcement to restrict inter-container communication

### Port-Based Access Control Lists (ACLs)

Network devices and firewalls implement ACLs based on ports:

```
Allow Ruleset Example:
    Source: Any         Destination: 192.0.2.10:443    Action: Allow
    Source: 203.0.113.0/24  Destination: 192.0.2.10:22     Action: Allow
    Source: Any         Destination: Any                Action: Deny
```

**Limitations:**

[Inference] Port-based filtering alone does not provide application-layer security:

- Malicious traffic can use allowed ports
- Application vulnerabilities remain exploitable on open ports
- Protocol mismatches (non-HTTP traffic on port 80) may bypass inspection
- Port-hopping malware can adapt to open ports

Defense-in-depth requires combining port filtering with application-layer firewalls, intrusion detection, and authentication.

### Intrusion Detection and Port Monitoring

**Anomaly Detection:**

Monitoring port access patterns helps identify:

- Unauthorized port scanning
- Unusual connection patterns to non-standard ports
- Attempts to access closed ports
- Geographic anomalies in connection sources

**Logging and Alerting:**

```
Security Event Examples:
    Multiple SYN packets to closed ports from single source
    Successful connections to administrative ports from unexpected IPs
    Port scan signatures (sequential port access)
    Connection attempts to honeypot ports
```

[Inference] Real-time monitoring and automated response systems can block suspicious sources before successful exploitation occurs.

### Zero Trust and Port Security

Zero Trust architecture assumes no implicit trust based on network location:

**Port Security in Zero Trust:**

- Ports alone do not indicate trustworthiness
- Authentication required regardless of source network
- Least privilege access enforcement
- Continuous verification of access requests
- Microsegmentation limits lateral movement even on internal networks

```
Traditional: Internal network → All ports accessible
Zero Trust:  All requests → Authentication + Authorization required
```

**Key Points:**

- Dynamic ports (49152-65535) are automatically assigned by operating systems for client connections, with ranges varying by OS (Linux defaults to 32768-60999)
- Port exhaustion occurs when high connection rates consume available ephemeral ports, exacerbated by TIME_WAIT state accumulation
- Default ports can be omitted from URIs (http://example.com implies :80), and explicit default ports are normalized to omitted form for canonical representation
- Non-standard ports enable multiple services on single hosts but may be blocked by corporate firewalls and limit accessibility
- Exposed ports increase attack surface through service fingerprinting, direct exploitation attempts, and information disclosure about infrastructure
- Database ports (3306, 5432, 27017) should not be directly internet-accessible and require network isolation with access restricted to application tiers
- Port-based filtering provides network-layer security but does not prevent application-layer attacks on allowed ports
- Container platforms require careful port mapping configuration to prevent inadvertent external exposure of internal services

---

# Path Component

## Path Syntax and Structure

The path component identifies a resource within the scope defined by the scheme and authority. It consists of a sequence of segments separated by forward slashes, following specific syntactic rules that vary based on the presence of an authority component.

**Basic Syntax Pattern:**

A path comprises zero or more segments delimited by forward slash (/) characters. The pattern takes the form `segment/segment/segment` where each segment contains data identifying a portion of the resource hierarchy. An empty path is valid and distinct from a path containing only a slash.

**Character Restrictions:**

Path segments may contain unreserved characters (A-Z, a-z, 0-9, hyphen, period, underscore, tilde), percent-encoded characters (% followed by two hexadecimal digits), and sub-delimiters (! $ & ' ( ) * + , ; =). Additionally, the colon (:) and at-sign (@) are permitted within path segments.

**Reserved Character Encoding:**

Characters with special syntactic meaning must be percent-encoded when used as data. The forward slash (/) delimits segments and must be encoded as %2F when appearing within segment data. The question mark (?) introduces the query component and must be encoded as %3F when appearing in path data. The hash (#) introduces the fragment component and must be encoded as %23 when appearing in path data.

**Percent-Encoding Requirements:**

Non-ASCII characters require percent-encoding in paths. The space character encodes to %20. The character ü (U+00FC) encodes to %C3%BC in UTF-8. Multi-byte UTF-8 sequences result in multiple percent-encoded octets. The Unicode character 中 (U+4E2D) encodes to %E4%B8%AD.

**Path Forms:**

Paths manifest in several distinct forms based on their initial character and context. An absolute path begins with / and provides a complete path from the root. A rootless path begins with a non-slash character and provides a relative reference. An empty path contains no characters and is valid in specific contexts.

**Authority Interaction:**

When a URI includes an authority component (introduced by //), the path must either be empty or begin with a forward slash. The sequence `http://example.com` has an empty path. The sequence `http://example.com/` has a path consisting of a single slash. The sequence `http://example.com/path` has an absolute path `/path`.

**Rootless Path Restrictions:**

When a URI lacks an authority component, the path can be rootless but faces a constraint: if rootless, the first segment cannot contain a colon. This restriction prevents ambiguity with scheme delimiters. The relative reference `path:segment` could be misinterpreted as `path` being a scheme. Relative references requiring a colon in the first segment must use `./path:segment` or an absolute path form.

**Empty Segments:**

Consecutive slashes create empty segments. The path `/path//to///file` contains empty segments between the duplicate slashes. While syntactically valid, empty segments may have semantic implications depending on the URI scheme and server interpretation. Some schemes normalize paths by removing empty segments, while others preserve them.

**Path Termination:**

The path component terminates at the first occurrence of a query separator (?), fragment separator (#), or the end of the URI string. The URI `http://example.com/path?query` has path `/path`. The URI `http://example.com/path#fragment` has path `/path`. The URI `http://example.com/path` has path `/path` extending to the end.

**Dot Segments:**

The special segments `.` (single dot) and `..` (double dot) carry hierarchical navigation semantics. The segment `.` represents the current level. The segment `..` represents the parent level. These segments participate in path normalization and relative reference resolution.

**Case Sensitivity:**

Path component case sensitivity depends on the URI scheme and server implementation. HTTP paths are conventionally case-sensitive, where `/Path` and `/path` identify different resources. Some servers implement case-insensitive path handling. The `file` scheme on Windows systems typically uses case-insensitive paths, while Unix-like systems use case-sensitive paths.

**Trailing Slashes:**

The presence or absence of a trailing slash creates semantically distinct paths. The path `/directory` differs from `/directory/`. Servers may treat these differently, with the trailing slash often indicating a directory resource. Some servers redirect between these forms, while others serve different content.

**Path-Only URIs:**

In relative references, a URI may consist solely of a path component without scheme, authority, query, or fragment. The reference `path/to/resource` provides a relative path resolved against a base URI context.

## Absolute vs Relative Paths

Paths within URIs exist in two fundamental forms: absolute paths that specify complete routes from a defined root, and relative paths that specify routes from a contextual position.

**Absolute Path Definition:**

An absolute path begins with a forward slash (/) character, indicating the path starts from the root of the hierarchical namespace. Absolute paths provide complete specification independent of context. The path `/documents/file.pdf` is absolute, starting from the root and traversing through the `documents` segment to `file.pdf`.

**Absolute Path in URIs:**

Within complete URIs containing an authority, paths appearing after the authority are typically absolute. The URI `http://example.com/api/users` contains the absolute path `/api/users`. The leading slash immediately follows the authority component, and the path is interpreted from the server's root directory or namespace.

**Absolute Paths Without Authority:**

[Inference] Some URI schemes permit absolute paths without authority components. The `file` scheme can express local file system paths: `file:/etc/hosts` contains the absolute path `/etc/hosts`. The leading slash remains significant, indicating root-level addressing within the relevant namespace.

**Relative Path Definition:**

A relative path lacks a leading forward slash and is interpreted relative to a base URI or current context. Relative paths express resource locations in relation to a known position rather than from an absolute root. The path `images/logo.png` is relative, specifying a resource in an `images` directory relative to the current location.

**Relative Path Resolution:**

Relative paths require resolution against a base URI to produce an absolute URI. The resolution algorithm combines the base URI's components with the relative reference to generate a complete target URI. Given base `http://example.com/docs/guide.html` and relative path `images/logo.png`, resolution produces `http://example.com/docs/images/logo.png`.

**Empty Relative Path:**

An empty path is a valid relative reference that refers to the base URI's resource. Combined with a query or fragment, it modifies only those components. The relative reference `?search=term` applied to base `http://example.com/page` produces `http://example.com/page?search=term`, preserving the base path.

**Relative Path Forms:**

Relative paths appear in multiple forms based on their initial segments. A relative path beginning with a regular segment navigates from the current directory. The reference `file.html` accesses a file in the current directory. A relative path beginning with `./` explicitly indicates the current directory. The references `file.html` and `./file.html` are functionally equivalent. A relative path beginning with `../` navigates to the parent directory. The reference `../file.html` ascends one level before accessing the file.

**Parent Directory Navigation:**

Multiple `..` segments ascend multiple directory levels. The path `../../assets/style.css` ascends two levels before descending into `assets`. Given base path `/docs/api/reference/`, this resolves to `/docs/assets/style.css`.

**Resolution Algorithm:**

The relative reference resolution process follows defined steps. First, if the reference contains a scheme, it is treated as an absolute URI and returned unchanged. If the reference contains an authority (begins with //), it inherits only the base scheme. If the reference path begins with /, it replaces the base path entirely. If the reference path is relative, it is merged with the base path using a merge algorithm. The query and fragment from the reference replace those in the base if present.

**Path Merge Algorithm:**

Merging a relative path with a base path depends on the base's characteristics. If the base has an authority and an empty path, the relative path is prepended with /. Otherwise, the relative path replaces everything after the final / in the base path. Given base path `/a/b/c/d` and relative path `e/f`, the last segment `d` is removed, producing merged path `/a/b/c/e/f`.

**Dot Segment Removal:**

After merging, dot segments are removed through a normalization algorithm. The algorithm processes the path buffer sequentially. Input `../` or `./` at the beginning is removed. Input `/./` is replaced with `/`. Input `/.` at the end is replaced with `/`. Input `/../` removes the preceding segment and the `/../` sequence. Input `/..` at the end removes the preceding segment and replaces `..` with `/`. Input `..` or `.` at the end is removed. Other segments are transferred to output unchanged.

**Network-Path References:**

References beginning with // are network-path references containing an authority. The reference `//other.example.com/path` inherits the scheme from the base but specifies a different authority and path. Given base `http://example.com/page`, this resolves to `http://other.example.com/path`.

**Absolute-Path References:**

References beginning with / but lacking a scheme and authority are absolute-path references. They replace the base path while retaining the base scheme and authority. Given base `http://example.com/old/path`, the reference `/new/path` resolves to `http://example.com/new/path`.

**Same-Document References:**

Relative references consisting only of a fragment (beginning with #) are same-document references. They modify only the fragment component, preserving scheme, authority, path, and query. Given base `http://example.com/page?q=search`, the reference `#section` resolves to `http://example.com/page?q=search#section`.

**Query-Only References:**

References consisting of only a query (beginning with ?) replace the base query and fragment while preserving scheme, authority, and path. Given base `http://example.com/page#fragment`, the reference `?new=query` resolves to `http://example.com/page?new=query`, removing the original fragment.

## Path Segments

Path segments are the individual units comprising a path, delimited by forward slash separators. Each segment identifies a component in the hierarchical resource structure.

**Segment Delimiter:**

The forward slash (/) character functions as the segment delimiter. It separates consecutive segments and defines the hierarchical structure. The path `/api/users/123` contains four segments: an empty segment (before the leading /), `api`, `users`, and `123`.

**Segment Content:**

Segments contain character sequences identifying resources or hierarchical levels. Segment content may represent directory names, file names, identifiers, command names, or arbitrary data depending on the URI scheme and server implementation. The segment `documents` might represent a directory, while `report.pdf` might represent a file name.

**Empty Segments:**

A segment containing zero characters is an empty segment. Empty segments occur when slashes appear consecutively or at path boundaries. The path `//` contains three empty segments. The path `/api/` contains three segments: empty, `api`, and empty. The leading slash creates an empty segment, as does the trailing slash.

**Segment Encoding:**

Segments may contain percent-encoded characters to represent values not directly permissible in URI syntax. The segment `my%20file` decodes to `my file`, with %20 representing a space. Multi-byte UTF-8 characters require multiple percent-encoded octets: `caf%C3%A9` decodes to `café`.

**Reserved Characters in Segments:**

Certain characters require encoding within segments to avoid syntactic interpretation. The forward slash (/) must be encoded as %2F when used as data within a segment rather than as a delimiter. The question mark (?) must be encoded as %3F to prevent interpretation as a query separator. Spaces must be encoded as %20 (or sometimes + in query contexts, though %20 is preferred in paths).

**Sub-Delimiters in Segments:**

The sub-delimiter characters (! $ & ' ( ) * + , ; =) may appear unencoded in segments. These characters are reserved for potential scheme-specific or implementation-specific uses but do not have universal syntactic meaning in the general path structure. The segment `data(value)` is valid without encoding the parentheses.

**Colon in Segments:**

The colon (:) may appear in segments except in the first segment of a rootless path. In rootless paths, a colon in the first segment creates ambiguity with scheme delimiters. The path `api:v2/users` as a rootless relative reference is ambiguous. The path `./api:v2/users` or `/api:v2/users` unambiguously includes the colon.

**Segment Length:**

No inherent length limit exists for individual segments in the URI specification. Practical limitations arise from implementation constraints. Web servers typically impose maximum path length restrictions (often 2048 or 4096 characters total). Individual segments may face filesystem constraints when mapped to directories or files.

**Path Parameters:**

Historically, some URI schemes used semicolons to delimit path parameters within segments. The syntax `segment;param=value` embedded parameters in the segment. The path `/resource;version=2/data` includes a parameter in the first segment. This syntax has declined in usage, with query parameters preferred for most applications.

**Matrix Parameters:**

Matrix parameters represent an alternative parameter syntax where multiple parameters appear in a segment. The format uses semicolons: `/resource;lang=en;format=json`. This approach differs from query parameters in that parameters apply to specific path segments rather than the entire resource.

**Dot Segments:**

The segments `.` and `..` carry special navigation semantics. The single dot `.` represents the current directory level and is typically removed during normalization. The double dot `..` represents the parent directory level, causing upward traversal during path resolution. The path `/a/b/../c/./d` normalizes to `/a/c/d`.

**Segment Interpretation:**

Segment interpretation varies by URI scheme and server implementation. HTTP servers commonly map path segments to filesystem directories and files. API servers may interpret segments as resource identifiers or command names. Database URIs might interpret segments as database and table names. The same segment syntax serves diverse semantic purposes.

**Case Sensitivity:**

Segment matching case sensitivity depends on the implementation. HTTP URIs conventionally treat segments as case-sensitive, where `/Users` and `/users` identify different resources. Windows filesystems typically use case-insensitive matching. Unix filesystems use case-sensitive matching. Applications must respect the case handling semantics of the target system.

**Special Segment Values:**

Beyond dot segments, certain segment values may carry special meaning in specific contexts. The segment `~` often represents user home directories in Unix systems (`/~username/`). Numeric segments might represent identifiers or version numbers. Segments beginning with `.` might represent hidden resources or configuration data.

## Hierarchical Path Structure

URI paths embody hierarchical organization, representing nested levels of resource containment or categorization. This hierarchical structure enables logical resource organization and supports operations like relative reference resolution.

**Hierarchy Expression:**

Path hierarchy manifests through segment ordering and slash delimiters. Each slash represents a level boundary in the hierarchy. The path `/organization/department/team/member` represents four nested levels: organization contains department, department contains team, team contains member. Traversing left to right descends through increasingly specific levels.

**Root Level:**

The leading slash in absolute paths represents the hierarchy root. All subsequent segments exist within this root namespace. The root provides an absolute reference point for addressing resources. HTTP URIs typically map the root to the server's document root or application namespace boundary.

**Parent-Child Relationships:**

Segments define parent-child relationships within the hierarchy. In `/documents/2024/report.pdf`, the `documents` segment is the parent of `2024`, which is the parent of `report.pdf`. This relationship structure enables navigation both downward (toward specific resources) and upward (toward containing contexts).

**Directory Metaphor:**

Path hierarchy commonly maps to filesystem directory structures, though this mapping is conceptual rather than required. The segment sequence `/home/user/documents` might correspond to nested directories in a filesystem. RESTful APIs often model resource collections hierarchically: `/customers/123/orders/456` represents order 456 belonging to customer 123.

**Depth and Breadth:**

Hierarchies vary in depth (number of levels) and breadth (number of siblings at each level). Deep hierarchies like `/a/b/c/d/e/f/g/h` have many levels but potentially few resources at each level. Broad hierarchies like `/category1/`, `/category2/`, `/category3/` have many resources at the same level. Design choices balance specificity and organization complexity.

**Hierarchical Navigation:**

The hierarchy enables relative navigation between resources. The `..` segment ascends one hierarchy level. From `/docs/api/reference.html`, the relative reference `../guide/intro.html` ascends to `/docs/`, then descends to `/docs/guide/intro.html`. Multiple ascension operations traverse multiple levels: `../../assets/style.css` ascends two levels.

**Hierarchical Authority:**

URI paths inherit their authoritative context from the scheme and authority components. The path `/admin/config` under authority `example.com` identifies a different resource than the same path under authority `other.com`. Hierarchy operates within the namespace established by scheme and authority.

**Collection and Member Pattern:**

RESTful design commonly uses hierarchical paths to express collection-member relationships. The path `/users` might represent a collection of users. The path `/users/123` represents a specific member (user 123) within that collection. The path `/users/123/posts` represents a subordinate collection belonging to that user.

**Hierarchical Scope:**

Operations on hierarchical resources often have scope implications. Deleting `/projects/alpha` might imply deleting all subordinate resources (`/projects/alpha/tasks`, `/projects/alpha/files`). Permission systems frequently apply inherited permissions where access to `/documents/confidential` controls access to all subordinate paths.

**Path Traversal Security:**

Hierarchical structure introduces path traversal security concerns. Malicious input might use `..` segments to escape intended directory boundaries. The path `/files/../../../etc/passwd` attempts to traverse outside the intended scope. Secure implementations validate and normalize paths, preventing unauthorized hierarchy traversal.

**Normalization and Equivalence:**

Multiple path representations may reference identical resources hierarchically. The paths `/a/b/c` and `/a/./b/../b/c` both reference the same location after normalization. Normalization removes redundant `.` segments and resolves `..` segments: `/a/./b/../b/c` → `/a/b/c`. Normalized paths facilitate comparison and caching.

**Hierarchical Decomposition:**

Applications may decompose paths into hierarchical components for processing. The path `/catalog/products/electronics/laptops` decomposes into segments representing increasingly specific categories. Middleware or routing systems might process each level sequentially, applying category-specific logic or access controls.

**Virtual Hierarchies:**

Hierarchical path structure need not correspond to physical storage organization. A path `/products/123` might map to a database query rather than a filesystem directory. RESTful APIs construct virtual hierarchies representing logical relationships rather than storage layouts. The hierarchy serves organizational and addressing purposes regardless of backend implementation.

**Hierarchical Addressing Benefits:**

Hierarchical structure provides multiple benefits: human-readable organization that conveys resource relationships, relative reference support enabling portable document structures, logical grouping facilitating permission management and access control, scalable organization supporting arbitrarily complex resource taxonomies, and intuitive navigation enabling users to infer related resource locations.

**Flat vs Hierarchical Design:**

Some URI designs eschew deep hierarchies in favor of flat structures. The path `/resource-12345` uses identifiers without hierarchical context. Flat designs simplify implementation but sacrifice the organizational and navigational benefits of hierarchy. The choice depends on application requirements and resource relationship complexity.

**Hierarchy Traversal Algorithms:**

[Inference] Processing hierarchical paths often requires traversal algorithms. Depth-first traversal processes paths from root to leaf, applying operations at each level. Breadth-first traversal processes all siblings at one level before descending. Implementations choose traversal strategies based on operation semantics and performance characteristics.

---

