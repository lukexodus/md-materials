## Domain Name Structure


Domain names form a hierarchical tree structure, read from right to left, with each level separated by dots. This hierarchy represents administrative delegation boundaries.

**Hierarchical Levels:**

```
subdomain.example.com.
    │       │      │  │
    │       │      │  └─ Root (implicit)
    │       │      └─── Top-Level Domain (TLD)
    │       └────────── Second-Level Domain (SLD)
    └────────────────── Third-Level Domain / Subdomain
```

### Fully Qualified Domain Names (FQDN)

An FQDN includes all levels up to the root, which is represented by a trailing dot:

```
www.example.com.     (FQDN with explicit root)
www.example.com      (FQDN with implicit root, common usage)
```

The trailing dot is typically omitted in user-facing contexts but is significant in DNS configuration files and certain technical contexts where it distinguishes absolute names from relative names.

### Administrative Boundaries

Each level in the hierarchy represents a delegation of administrative authority:

**Root Level:**

- Managed by ICANN and root server operators
- Delegates authority to TLD operators

**TLD Level:**

- Managed by registry operators
- Delegates authority to domain registrants or second-level registries

**Second-Level and Below:**

- Managed by domain owner
- Owner controls all subdomains
- DNS records define resolution behavior

### Domain Name Resolution Order

DNS queries resolve from right to left:

```
mail.support.example.com
         ↑       ↑      ↑
         │       │      └─ Query root servers for .com
         │       └──────── Query .com servers for example.com
         └──────────────── Query example.com servers for support.example.com
                           Query support.example.com servers for mail.support.example.com
```

Each level in the hierarchy can provide authoritative DNS servers for the next level.

### Public Suffix

The public suffix (or effective TLD) represents the boundary where domain registration occurs. This is not always the TLD:

```
example.com          (public suffix: .com)
example.co.uk        (public suffix: .co.uk)
example.github.io    (public suffix: .github.io)
example.s3.amazonaws.com (public suffix: .s3.amazonaws.com)
```

The Public Suffix List (maintained by Mozilla) catalogs these boundaries, which is important for:

- Cookie scope restrictions
- Certificate validation
- Security policies
- Organizational domain identification

### Reserved Domain Names

Certain domain names are reserved for special purposes:

**RFC 2606 Reserved TLDs:**

```
.test       (for testing purposes)
.example    (for documentation examples)
.invalid    (guaranteed to be invalid)
.localhost  (for local loopback)
```

**RFC 6761 Special-Use Domains:**

```
.local      (Multicast DNS)
.onion      (Tor hidden services)
.arpa       (infrastructure, reverse DNS)
```

**Reserved Second-Level Domains:**

```
example.com, example.net, example.org (documentation)
```

These should not be used for actual services or registered.

