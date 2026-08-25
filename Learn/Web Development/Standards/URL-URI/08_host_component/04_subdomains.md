## Subdomains


Subdomains are additional levels in the domain hierarchy beneath the registered domain. They exist at the third level and beyond, fully controlled by the domain owner.

### Subdomain Structure

```
level4.level3.example.com
  │      │       │
  │      │       └─── Registered domain (second-level)
  │      └─────────── First subdomain (third-level)
  └────────────────── Second subdomain (fourth-level)
```

There is no practical limit to subdomain depth, though DNS query limits and usability considerations typically restrict excessive nesting.

### Common Subdomain Patterns

**Service-based Subdomains:**

```
www.example.com        (web service)
mail.example.com       (email service)
ftp.example.com        (file transfer)
api.example.com        (API endpoint)
cdn.example.com        (content delivery)
blog.example.com       (blog service)
shop.example.com       (e-commerce)
```

**Environment-based Subdomains:**

```
dev.example.com        (development environment)
staging.example.com    (staging/testing)
qa.example.com         (quality assurance)
prod.example.com       (production, though often uses apex)
```

**Geographic Subdomains:**

```
us.example.com         (United States)
eu.example.com         (Europe)
asia.example.com       (Asia)
uk.example.com         (United Kingdom)
```

**Functional Subdomains:**

```
docs.example.com       (documentation)
support.example.com    (customer support)
status.example.com     (service status)
admin.example.com      (administrative interface)
portal.example.com     (user portal)
```

**User/Tenant Subdomains:**

```
user1.example.com      (individual user spaces)
tenant-a.example.com   (multi-tenant application)
company1.example.com   (organizational spaces)
```

### Wildcard Subdomains

DNS supports wildcard records that match any subdomain at a specific level:

```
*.example.com          (matches any direct subdomain)
*.mail.example.com     (matches any subdomain under mail.example.com)
```

**Wildcard Behavior:**

```
DNS Record: *.example.com → 192.0.2.1

Matches:
- anything.example.com
- test.example.com
- xyz.example.com

Does Not Match:
- example.com (apex/bare domain)
- sub.test.example.com (deeper level)
```

Wildcards only match one level unless multiple wildcard records are configured at different levels.

### Subdomain Management

**DNS Configuration:**

Subdomains are configured through DNS records in the parent domain's zone:

```
www.example.com.     IN A     192.0.2.1
mail.example.com.    IN A     192.0.2.2
*.api.example.com.   IN CNAME api-server.example.com.
```

**Delegation:**

Subdomains can be delegated to separate nameservers using NS records:

```
subdomain.example.com.  IN NS  ns1.subdomain.example.com.
subdomain.example.com.  IN NS  ns2.subdomain.example.com.
```

This transfers DNS authority for that subdomain to different nameservers, allowing independent management.

### Technical Considerations

**Cookie Scope:**

Cookies set on subdomains behave according to domain attribute rules:

```
Set on: sub.example.com
Cookie domain: .example.com
    → Accessible to all subdomains and example.com

Set on: sub.example.com  
Cookie domain: sub.example.com
    → Only accessible to sub.example.com
```

**SSL/TLS Certificates:**

Certificates can cover subdomains through different mechanisms:

**Single Subdomain:**

```
CN: www.example.com
    → Only covers www.example.com
```

**Wildcard Certificate:**

```
CN: *.example.com
    → Covers any direct subdomain (mail.example.com, api.example.com)
    → Does NOT cover example.com (apex) or deeper levels (sub.api.example.com)
```

**Multi-Domain Certificate (SAN):**

```
Subject Alternative Names:
- example.com
- www.example.com
- mail.example.com
- api.example.com
    → Explicitly listed domains only
```

### Subdomain Enumeration and Security

Subdomains can be discovered through:

**DNS Zone Transfer:**

```
AXFR request to authoritative nameserver
```

Most production nameservers disable zone transfers to non-authorized parties.

**DNS Brute Forcing:**

Attempting common subdomain names against target domain.

**Certificate Transparency Logs:**

Public logs reveal subdomains in issued certificates.

**Search Engine Indexing:**

Subdomains discovered through site: queries and web crawling.

**Security Implications:**

- Forgotten or abandoned subdomains may have vulnerabilities
- Subdomain takeover occurs when DNS points to unclaimed resources
- Wildcard subdomains increase attack surface
- Internal subdomains exposed publicly create information disclosure

### Subdomain Routing and Architecture

**Load Distribution:**

```
www1.example.com  →  192.0.2.1
www2.example.com  →  192.0.2.2
www3.example.com  →  192.0.2.3
```

Multiple subdomains can distribute load across servers, though round-robin DNS or load balancers on single subdomain are more common.

**Service Isolation:**

```
frontend.example.com  →  Public-facing application
backend.example.com   →  API services (internal only)
db.example.com        →  Database access (internal only)
```

Subdomains enable network segmentation and access control policies.

**Content Delivery:**

```
static.example.com    →  CDN for static assets
images.example.com    →  Image hosting service
videos.example.com    →  Video streaming service
```

Separating content types allows optimized caching, delivery, and security policies per subdomain.

**Key Points:**

- DNS hostname labels must be 1-63 octets, start/end with alphanumeric, and can contain hyphens in middle positions
- Complete hostnames cannot exceed 253 octets total length
- Domain hierarchy reads right to left: subdomain.example.com where .com is TLD, example.com is registered domain, subdomain is third-level
- TLDs include generic (.com, .org), country-code (.uk, .jp), sponsored (.edu, .gov), and new categories (.app, .tech, .london)
- Public suffixes define registration boundaries and may extend beyond TLD (.co.uk, .github.io)
- Subdomains are fully controlled by domain owner and configured through DNS records in parent zone
- Wildcard DNS records (*.example.com) match one level of subdomains but not apex or deeper levels
- Subdomain delegation using NS records transfers DNS authority to separate nameservers

---

