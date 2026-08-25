## WHATWG URL Standard Differences


### WHATWG Authority Handling

**Special schemes enforcement:** For special schemes (http, https, ws, wss, ftp, file), WHATWG requires non-empty host (except file:).

**Example:**

```javascript
new URL('http:///path');
// Throws TypeError: invalid URL (empty host)

new URL('custom:///path');
// Valid (non-special scheme)
```

**Default port handling:** WHATWG automatically omits default ports:

```javascript
const url = new URL('http://example.com:80/');
console.log(url.port);  // "" (empty string)
console.log(url.href);  // "http://example.com/"
```

**Case normalization:** WHATWG automatically lowercases hosts:

```javascript
const url = new URL('http://EXAMPLE.COM/');
console.log(url.hostname);  // "example.com"
```

### Username and Password Properties

**WHATWG URL API provides separate properties:**

```javascript
const url = new URL('http://user:pass@example.com/');

console.log(url.username);  // "user"
console.log(url.password);  // "pass"
console.log(url.host);      // "example.com" (without userinfo)
console.log(url.hostname);  // "example.com" (without port)
console.log(url.port);      // ""

// Modification
url.username = "newuser";
url.password = "newpass";
// Result: http://newuser:newpass@example.com/
```

**Automatic percent-encoding:**

```javascript
const url = new URL('http://example.com/');
url.username = "user@email";
console.log(url.username);  // "user%40email"
console.log(url.href);      // "http://user%40email@example.com/"
```

### Host vs Hostname Properties

**WHATWG distinguishes between `host` and `hostname`:**

**hostname:** Host without port **host:** Host with port (if non-default)

```javascript
const url = new URL('http://example.com:8080/');

console.log(url.hostname);  // "example.com"
console.log(url.host);      // "example.com:8080"
console.log(url.port);      // "8080"
```

**With default port:**

```javascript
const url = new URL('http://example.com:80/');

console.log(url.hostname);  // "example.com"
console.log(url.host);      // "example.com" (port omitted)
console.log(url.port);      // "" (empty)
```

### IPv6 Bracket Handling

**WHATWG includes brackets in host property:**

```javascript
const url = new URL('http://[2001:db8::1]:8080/');

console.log(url.hostname);  // "[2001:db8::1]" (with brackets)
console.log(url.host);      // "[2001:db8::1]:8080"
console.log(url.port);      // "8080"
```

