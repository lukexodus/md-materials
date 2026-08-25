## Authority Component


The authority component identifies the naming authority governing the namespace for the resource. It is prefixed by a double slash (//) and contains information about the location where the resource can be accessed.

**Syntax Structure:**

```
authority = [ userinfo "@" ] host [ ":" port ]
```

### Userinfo Subcomponent

The userinfo subcomponent contains authentication credentials or user identification information. It precedes the host and is separated by an at sign (@).

**Structure:**

```
userinfo = *( unreserved / pct-encoded / sub-delims / ":" )
```

**Example:**

```
user:password@example.com
username@example.com
```

Modern security practices discourage including passwords in URIs due to visibility in logs, browser history, and over-the-shoulder observation. Many schemes have deprecated or restricted userinfo usage.

### Host Subcomponent

The host identifies the server or naming authority. It can take three forms:

**1. Registered Name (Domain Name):**

```
example.com
subdomain.example.org
```

Domain names are case-insensitive and should be normalized to lowercase. They follow DNS naming conventions and may include internationalized domain names (IDN) using punycode encoding.

**2. IPv4 Address:**

```
192.0.2.1
10.0.0.1
```

IPv4 addresses consist of four decimal octets separated by periods. Each octet ranges from 0 to 255.

**3. IPv6 Address:**

```
[2001:db8::1]
[::1]
[fe80::a%eth0]
```

IPv6 addresses are enclosed in square brackets to distinguish them from port separators. They use hexadecimal notation with colon separators and support compression of zero sequences using double colons (::). Zone identifiers for link-local addresses are appended with a percent sign.

### Port Subcomponent

The port number specifies the TCP or UDP port for connection. It follows the host, separated by a colon.

**Structure:**

```
port = *DIGIT
```

**Examples:**

```
example.com:8080
192.0.2.1:443
[2001:db8::1]:8000
```

Each scheme defines a default port (HTTP uses 80, HTTPS uses 443). When the default port is used, it is typically omitted from the URI. Empty port specifications (host:) are syntactically valid but uncommon.

**Authority Examples:**

```
//example.com
//user@example.com:8080
//192.0.2.1
//[2001:db8::1]:443
//example.com:
```

