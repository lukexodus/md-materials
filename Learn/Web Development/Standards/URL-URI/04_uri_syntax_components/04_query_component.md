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

