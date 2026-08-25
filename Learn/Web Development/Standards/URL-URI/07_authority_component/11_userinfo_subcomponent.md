## Userinfo Subcomponent


The userinfo subcomponent contains optional authentication credentials or user identification. It appears before the host and is delimited by an at sign (@). The format is typically `username:password` though the structure is not strictly defined by RFC 3986.

**Key Points:**

- Deprecated for security reasons in modern web contexts
- Exposures credentials in browser history, logs, and referrer headers
- Supported for backward compatibility but discouraged in practice
- Automatically stripped by some browsers for HTTP(S) URLs
- Still used in some non-web URI schemes like FTP

**Example:**

```
ftp://anonymous:guest@ftp.example.com/file.txt
    └────────┬────────┘
         userinfo

http://admin:secret@internal.example.com/admin
    └─────┬──────┘
      userinfo (deprecated usage)
```

The colon separator within userinfo is conventional but not mandated. Some schemes may use different formats. Percent-encoding must be applied to special characters within userinfo, including the at sign if it appears literally.

Modern authentication mechanisms prefer separate authentication headers (like HTTP Authorization), POST request bodies, or secure token-based systems rather than embedding credentials in URLs.

