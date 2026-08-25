## HTTP vs HTTPS Structure


Both schemes follow the standard hierarchical URI structure:

```
http://authority/path?query#fragment
https://authority/path?query#fragment
```

**Key differences:**

- **Default ports**: HTTP uses port 80, HTTPS uses port 443
- **Security**: HTTPS encrypts all communication; HTTP transmits in plaintext
- **Certificate requirements**: HTTPS requires valid TLS/SSL certificates
- **Browser indicators**: Modern browsers display security indicators for HTTPS
- **SEO impact**: Search engines prioritize HTTPS content [Inference - based on documented search engine behavior]

**Example:**

```
http://example.com/page.html   // Unencrypted
https://example.com/page.html  // Encrypted with TLS
```

