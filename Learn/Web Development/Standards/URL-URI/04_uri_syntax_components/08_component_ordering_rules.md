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

