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

