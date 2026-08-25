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

