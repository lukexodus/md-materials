## https:// Scheme Syntax


The https:// scheme syntax is identical to the http:// scheme, with the distinction being the protocol used for communication. HTTPS indicates that HTTP communication is encrypted using Transport Layer Security (TLS) or its predecessor, Secure Sockets Layer (SSL).

**Complete Syntax Structure**:

```
https://[userinfo@]host[:port][/path][?query][#fragment]
```

All components follow the same rules as the HTTP scheme:

**Examples of Valid HTTPS URIs**:

```
https://example.com
https://example.com:8443
https://secure.example.com/login
https://api.example.com/v1/users?format=json
https://192.168.1.100:443/admin
https://[2001:db8::1]:8443/secure
```

**Behavioral Differences from HTTP**:

While syntactically identical, HTTPS URIs trigger different client behavior:

- Establishment of TLS/SSL connection before HTTP communication
- Certificate verification against trusted certificate authorities
- Encryption of all HTTP traffic including headers, body, and cookies
- [Inference] Browser security indicators (padlock icon, green address bar in some browsers)
- Stricter enforcement of mixed content policies

**Mixed Content Considerations**:

When an HTTPS page references HTTP resources (images, scripts, stylesheets), browsers typically block or warn about "mixed content" to prevent security vulnerabilities. Modern web standards require HTTPS pages to only load resources via HTTPS.

