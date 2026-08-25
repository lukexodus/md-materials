## Security Considerations


### Homograph Attacks

Internationalized domain names can use visually similar characters:

```
http://example.com     // Legitimate
http://еxamplе.com     // Uses Cyrillic 'е' characters
```

### Open Redirects

Improperly validated URIs can enable phishing:

```
http://trusted.com/redirect?url=http://malicious.com
```

### Path Traversal

Improper normalization can expose unintended resources:

```
http://example.com/files/../../../etc/passwd
```

**Key Points:**

- Always normalize URIs before security-sensitive operations
- Validate scheme, authority, and path components
- Be cautious with user-supplied URI components
- Consider canonicalization before comparison
- Implement proper percent-encoding/decoding

