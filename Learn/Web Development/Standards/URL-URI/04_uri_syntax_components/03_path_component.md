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

