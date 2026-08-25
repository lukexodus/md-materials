## Testing and Validation


### URL Parsing Tests

**Test cases should cover:**

- Valid URLs with all components
- Missing components
- Invalid characters
- Percent-encoding edge cases
- Scheme-specific rules
- Relative URL resolution
- Internationalized domain names
- IPv6 addresses

**Example test structure:**

```javascript
describe('URL parsing', () => {
  test('parses complete URL', () => {
    const url = new URL('https://user:pass@example.com:8080/path?q=1#frag');
    expect(url.protocol).toBe('https:');
    expect(url.username).toBe('user');
    expect(url.password).toBe('pass');
    expect(url.hostname).toBe('example.com');
    expect(url.port).toBe('8080');
    expect(url.pathname).toBe('/path');
    expect(url.search).toBe('?q=1');
    expect(url.hash).toBe('#frag');
  });
  
  test('handles relative URL', () => {
    const url = new URL('../other', 'https://example.com/path/file');
    expect(url.href).toBe('https://example.com/other');
  });
});
```

### Validation Libraries

**Popular validation libraries:**

- `validator.js` for JavaScript/Node.js
- URI parser libraries in various languages
- Regular expression approaches (limited, not recommended for full parsing)

**Note:** [Unverified] Regular expressions alone cannot fully validate URLs according to either standard due to context-dependent parsing rules.

