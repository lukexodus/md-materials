## Authority Comparison and Equivalence


### Normalization for Comparison

**Case normalization:**

```
HTTP://EXAMPLE.COM:80/
http://example.com:80/
http://example.com/
// All equivalent
```

**Percent-encoding normalization:**

```
http://ex%61mple.com/
http://example.com/
// Equivalent
```

**Port normalization:**

```
http://example.com:80/
http://example.com/
// Equivalent
```

**IPv6 normalization:**

```
http://[2001:0db8:0000:0000:0000:0000:0000:0001]/
http://[2001:db8::1]/
// Equivalent
```

### Equivalence Rules

Two authorities are equivalent if, after normalization:

- Schemes match (case-insensitive)
- Hosts match (case-insensitive for DNS, literal for IP)
- Ports match (considering defaults)
- Userinfo matches (if present, case-sensitive)

**Example equivalence:**

```
Equivalent:
- http://EXAMPLE.COM:80/
- http://example.com/
- http://example.com:80/

Not equivalent:
- http://example.com/
- https://example.com/  (different scheme)
- http://example.com:8080/  (different port)
```

