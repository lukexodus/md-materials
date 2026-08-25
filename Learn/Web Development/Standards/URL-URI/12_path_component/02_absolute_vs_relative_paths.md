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

