## Domain Names


Domain names provide human-readable labels for network resources, mapped to IP addresses through the Domain Name System (DNS). They consist of labels separated by periods, read from specific (left) to general (right).

### Domain Name Structure

A fully qualified domain name (FQDN) specifies the complete path from a specific host through all intermediate domains to the DNS root. It typically consists of a hostname, domain, and top-level domain (TLD).

**Example:**

```
www.example.com
└┬┘ └──┬──┘ └┬┘
 |     |     └── Top-level domain (TLD)
 |     └──────── Second-level domain (SLD)
 └────────────── Subdomain/hostname
```

Each label can contain letters (a-z, A-Z), digits (0-9), and hyphens (-). Labels cannot start or end with hyphens. Each label can be 1-63 characters long. The total FQDN length cannot exceed 253 characters including dots.

Domain names are case-insensitive, though preservation of case is recommended. "Example.COM", "example.com", and "EXAMPLE.com" all refer to the same domain.

### Label Restrictions

Individual domain labels must follow specific rules for validity. Labels cannot be empty (consecutive dots are invalid). Labels cannot exceed 63 octets in length. Labels cannot begin or end with hyphens. The total domain name with all labels and dots cannot exceed 253 characters.

**Example:**

```
Valid:   example.com
Valid:   sub-domain.example.com
Valid:   xn--nxasmq6b.example.com  (IDN in Punycode)
Invalid: example..com               (empty label)
Invalid: -example.com                (starts with hyphen)
Invalid: example-.com                (ends with hyphen)
Invalid: [very long label exceeding 63 characters].com
```

Labels consisting entirely of digits are valid, though they may be confused with IP addresses in some contexts. The label "123" is a valid domain label.

### Top-Level Domains

Top-level domains (TLDs) form the highest level of the domain name hierarchy. They fall into several categories with different governance and purposes.

Generic TLDs (gTLDs) include traditional domains (.com, .net, .org, .edu, .gov, .mil) and new gTLDs introduced since 2013 (.app, .blog, .shop, .tech, etc.). Country-code TLDs (ccTLDs) represent specific countries or territories (.us, .uk, .de, .jp, .ph, etc.).

Sponsored TLDs (sTLDs) are specialized domains with restrictions (.aero, .museum, .coop). Infrastructure TLD (.arpa) is reserved for technical infrastructure purposes.

Some ccTLDs like .tv (Tuvalu) and .io (British Indian Ocean Territory) are marketed for other purposes beyond their geographic designation.

### Subdomain Hierarchy

Subdomains create hierarchical structure within domain names. Organizations can create arbitrary subdomains under domains they control. Each level adds specificity and can be managed independently.

**Example:**

```
blog.marketing.example.com
└──┬──┘ └───┬────┘ └──┬──┘
   |        |         └── Second-level domain
   |        └──────────── Third-level domain
   └───────────────────── Fourth-level domain
```

Common subdomain patterns include service separation (www, mail, ftp), environment distinction (dev, staging, prod), geographic distribution (us, eu, asia), and functional organization (blog, shop, api, docs).

### Domain Name Validation

Validating domain names requires checking multiple criteria beyond basic syntax. Labels must conform to length and character restrictions. The overall length must not exceed limits. TLD must exist in the DNS (for strict validation). Labels should not contain homograph characters in security-sensitive contexts.

Domain validation complexity varies by use case. Syntax validation checks format correctness without network access. DNS validation performs lookups to verify domain existence. Security validation checks for suspicious patterns like IDN homographs.

**Example validation approaches:**

```
Syntax only:  example.com         ✓ (valid format)
              exam ple.com         ✗ (space in label)
              
DNS verified: existing-domain.com  ✓ (resolves)
              nonexistent12345.com ✗ (NXDOMAIN)

Security:     example.com          ✓ (safe)
              exаmple.com          ⚠ (Cyrillic 'а' - homograph)
```

### Internationalized Domain Names

Internationalized Domain Names (IDN) allow non-ASCII Unicode characters in domain names through ASCII-compatible encoding. The Punycode algorithm converts Unicode to ASCII while DNS infrastructure remains unchanged.

IDN-capable applications convert Unicode domain names to Punycode before DNS lookup and display Unicode to users while using Punycode internally.

**Example:**

```
Display:   münchen.de
Punycode:  xn--mnchen-3ya.de
DNS query: xn--mnchen-3ya.de

Display:   日本.jp
Punycode:  xn--wgv71a.jp
DNS query: xn--wgv71a.jp
```

All Punycode labels begin with "xn--" prefix to identify them as encoded international names. The remaining characters encode the Unicode string using the Punycode algorithm.

### IDN Security Considerations

IDN introduces security challenges through homograph attacks where visually similar characters create deceptive domain names. Attackers register domains using Unicode characters that look identical to legitimate domains.

**Example homograph scenarios:**

```
Legitimate:  google.com
Homograph:   gооgle.com  (Cyrillic о instead of Latin o)

Legitimate:  paypal.com
Homograph:   pаypal.com  (Cyrillic а instead of Latin a)

Legitimate:  apple.com
Homograph:   аpple.com   (Cyrillic а instead of Latin a)
```

Modern browsers implement protections including displaying Punycode for suspicious domains, restricting mixed-script domains, maintaining lists of confusable characters, requiring entire labels to be from single scripts (with exceptions), and highlighting unusual character combinations.

Users cannot reliably distinguish these visually, making technical protections essential. Applications handling domains should implement similar safeguards.

