## Testing Considerations


### Test Cases for Authority Parsing

**Comprehensive test coverage should include:**

**Valid authorities:**

```javascript
test('parses complete authority', () => {
  const url = new URL('http://user:pass@example.com:8080/');
  expect(url.username).toBe('user');
  expect(url.password).toBe('pass');
  expect(url.hostname).toBe('example.com');
  expect(url.port).toBe('8080');
});
```

**Edge cases:**

```javascript
test('handles IPv6 with port', () => {
  const url = new URL('http://[2001:db8::1]:8080/');
  expect(url.hostname).toBe('[2001:db8::1]');
  expect(url.port).toBe('8080');
});

test('handles empty password', () => {
  const url = new URL('http://user:@example.com/');
  expect(url.username).toBe('user');
  expect(url.password).toBe('');
});

test('handles default port', () => {
  const url = new URL('http://example.com:80/');
  expect(url.port).toBe('');
  expect(url.href).toBe('http://example.com/');
});
```

**Invalid input:**

```javascript
test('rejects invalid port', () => {
  expect(() => new URL('http://example.com:99999/')).toThrow();
});

test('rejects empty host for http', () => {
  expect(() => new URL('http:///path')).toThrow();
});
```

**Percent-encoding:**

```javascript
test('handles encoded userinfo', () => {
  const url = new URL('http://user%40email:p%40ss@example.com/');
  expect(url.username).toBe('user%40email');
  expect(url.password).toBe('p%40ss');
});
```

**Normalization:**

```javascript
test('normalizes case', () => {
  const url = new URL('HTTP://EXAMPLE.COM/');
  expect(url.hostname).toBe('example.com');
  expect(url.protocol).toBe('http:');
});
```

### Important subtopics to explore further:

- **URI Resolution:** How relative URIs are resolved against base URIs, including complex edge cases with authority components
- **Security Headers:** How HTTP headers like Host, Origin, and Referer interact with authority components
- **Proxy and Gateway Handling:** How intermediaries process and modify authority information
- **DNS Resolution and Caching:** The interaction between URI authority and DNS lookup processes
- **Certificate Validation:** How TLS/SSL certificates validate against hostname in HTTPS URIs

---

