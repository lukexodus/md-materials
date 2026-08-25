## HTTPS-Only Mode


HTTPS-Only Mode is a browser security feature that automatically attempts to upgrade all HTTP connections to HTTPS, protecting users from insecure connections.

### Browser Implementation

Different browsers implement HTTPS-Only Mode with varying approaches:

**Firefox:**

- User-enabled in Settings > Privacy & Security
- Attempts HTTPS upgrade for all connections
- Displays warning page if HTTPS unavailable
- Per-site exceptions available

**Chrome/Edge:**

- "Always use secure connections" option
- Automatic upgrading in address bar
- Gradual rollout of automatic HTTPS

**Safari:**

- Automatic HTTPS upgrade attempts [Unverified - specific implementation details]
- Integrated with privacy features

### Behavior and User Experience

When HTTPS-Only Mode is enabled:

1. **Automatic upgrade attempts**: Browser tries HTTPS first
2. **Connection timeout**: Brief wait for HTTPS response (typically 3-5 seconds)
3. **Fallback warning**: If HTTPS fails, user sees warning page
4. **User choice**: Option to proceed with HTTP or stay on HTTPS

**Example** warning page message:

```
Secure Connection Not Available

example.com doesn't support HTTPS. Continue to HTTP site?

[Go Back]  [Continue to HTTP Site]
```

### Server-Side Configuration

**HTTP Strict Transport Security (HSTS):** Servers can enforce HTTPS-only connections:

```http
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
```

**Parameters:**

- `max-age`: Duration in seconds (31536000 = 1 year)
- `includeSubDomains`: Apply to all subdomains
- `preload`: Eligible for browser preload lists

**HSTS Preload Lists:** Major browsers maintain lists of sites that should only be accessed via HTTPS:

- Hardcoded into browser
- Prevents first-visit downgrade attacks
- Requires commitment to HTTPS [Domain removal is possible but takes time]

### Deployment Considerations

**Testing HTTPS-Only:**

1. Enable HTTPS-Only Mode in browser
2. Navigate site completely
3. Check for broken resources
4. Verify all API endpoints support HTTPS
5. Test third-party integrations

**Migration strategy:**

```
Phase 1: Implement HTTPS, maintain HTTP
Phase 2: Add HSTS header with short max-age
Phase 3: Gradually increase max-age
Phase 4: Add includeSubDomains
Phase 5: Submit to HSTS preload list
```

**Potential issues:**

- Legacy internal systems without HTTPS support
- Third-party resources only available via HTTP
- Development/testing environments
- Cost considerations for certificates (now largely resolved with Let's Encrypt)

