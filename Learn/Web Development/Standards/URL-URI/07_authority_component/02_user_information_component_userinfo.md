## User Information Component (userinfo)


The userinfo subcomponent provides user authentication information. It appears before the host and is delimited by an `@` symbol.

### Syntax

```
userinfo = username[:password]
```

The userinfo is optional and deprecated in modern web contexts due to security concerns.

**Allowed characters (unreserved + sub-delims):**

```
A-Z a-z 0-9 - . _ ~ ! $ & ' ( ) * + , ; =
```

Any other characters must be percent-encoded.

### Username

The username portion identifies the user attempting to access the resource.

**Example:**

```
ftp://john.doe@ftp.example.com/files
    └username┘
```

**Percent-encoding example:**

```
Original: user@email
Encoded:  user%40email

Complete URI: ftp://user%40email@ftp.example.com/
```

### Password

The password portion follows the username and is separated by a colon.

**Example:**

```
ftp://john:secret123@ftp.example.com/files
    └user┘ └password┘
```

**Multiple colons:** If the password contains colons, only the first colon separates username from password:

```
ftp://user:pass:word@example.com
    └user┘ └password─┘
```

### Security Concerns and Deprecation

**Critical security issues:**

**Plain-text transmission:** Credentials appear in plain text in the URI, visible in browser history, logs, and referrer headers.

**Shoulder surfing:** Credentials are visible in the address bar.

**Server logs:** URLs with credentials are often logged on servers and intermediate proxies.

**Referrer leakage:** Credentials can be leaked through HTTP Referer headers when navigating to external sites.

**Browser storage:** URLs with credentials may be stored in browser history and bookmarks.

**Modern browser behavior:**

- Most browsers display warnings for userinfo in HTTP(S) URLs
- Some browsers strip userinfo from display
- Many browsers block userinfo in HTTP(S) URLs entirely for security

**Example of warning:**

```
http://user:pass@example.com/
// Modern browsers may show: "This site is trying to load an unsafe URL"
```

**[Inference] Recommended alternatives:**

- HTTP authentication headers (Basic, Digest, Bearer tokens)
- Form-based authentication with secure cookies
- OAuth 2.0 flows
- API keys passed in headers or query parameters
- Client certificates

### Legacy Use Cases

**Still encountered in:**

- FTP URLs (though GUI clients typically handle credentials separately)
- Legacy database connection strings
- Internal tools and scripts (where URLs aren't exposed)
- Documentation and examples (often with placeholder values)

**Example database connection:**

```
postgresql://dbuser:dbpassword@localhost:5432/mydb
```

**Note:** Even in these contexts, consider environment variables or configuration files instead.

### Parsing Userinfo

**Algorithm for extracting userinfo:**

1. Locate the `@` symbol in the authority
2. If no `@` exists, there is no userinfo
3. If `@` exists, everything before it is userinfo
4. Within userinfo, split on first `:` to separate username and password

**Example parsing:**

```
Input: user%40domain:p%40ss@example.com:8080

Steps:
1. Find @: position 22
2. Userinfo: "user%40domain:p%40ss"
3. Split on first :: username="user%40domain", password="p%40ss"
4. Decode: username="user@domain", password="p@ss"
```

**Edge cases:**

**Multiple @ symbols:** The last `@` separates userinfo from host:

```
user@email:pass@example.com
└────userinfo────┘ └─host──┘
```

**Empty password:**

```
user:@example.com
// username="user", password=""
```

**Empty username:**

```
:password@example.com
// username="", password="password"
```

**Only username:**

```
user@example.com
// username="user", no password
```

