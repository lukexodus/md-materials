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

