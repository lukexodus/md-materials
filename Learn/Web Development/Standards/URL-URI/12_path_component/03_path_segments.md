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

