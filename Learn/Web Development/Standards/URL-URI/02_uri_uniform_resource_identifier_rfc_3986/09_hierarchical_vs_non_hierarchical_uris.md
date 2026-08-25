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

