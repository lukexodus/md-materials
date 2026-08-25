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

