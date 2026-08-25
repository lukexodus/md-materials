## Security Headers for HTTP/HTTPS


Beyond HSTS, several headers enhance HTTPS security:

**Content-Security-Policy (CSP):**

```http
Content-Security-Policy: default-src https:; script-src 'self' https://trusted.com
```

**X-Frame-Options:**

```http
X-Frame-Options: SAMEORIGIN
```

**X-Content-Type-Options:**

```http
X-Content-Type-Options: nosniff
```

**Referrer-Policy:**

```http
Referrer-Policy: strict-origin-when-cross-origin
```

**Permissions-Policy:**

```http
Permissions-Policy: geolocation=(self), microphone=()
```

