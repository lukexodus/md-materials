## IANA URI Scheme Registry


The **IANA (Internet Assigned Numbers Authority) URI Scheme Registry** is the authoritative repository of registered URI schemes. It maintains comprehensive documentation of scheme names, specifications, registration status, and responsible contacts.

The registry is publicly accessible at:

```
https://www.iana.org/assignments/uri-schemes/uri-schemes.xhtml
```

### Registry Structure

The registry organizes schemes into categories and provides standardized information for each entry.

**Required Registration Information:**

- **Scheme name**: The identifier used in URIs
- **Status**: Permanent, Provisional, or Historical
- **Reference**: Specification document (RFC number or external document)
- **Registrant**: Contact information for responsible party
- **Registration date**: When the scheme was registered
- **Last modified**: Most recent update timestamp

**Example Entry:**

```
Scheme: https
Status: Permanent
Reference: RFC 7230, RFC 2818
Description: Hypertext Transfer Protocol Secure
Registrant: IETF
```

### Registration Process

URI scheme registration follows procedures defined in **RFC 7595** (previously RFC 4395). The process varies based on the requested registration status.

**Permanent Scheme Registration:**

1. **Specification Development**: Create comprehensive technical specification documenting syntax, semantics, operations, and security considerations
2. **IETF Review**: Submit specification through IETF standards process or to designated expert reviewers
3. **Community Feedback**: Address comments and concerns from technical community
4. **IANA Submission**: Submit registration request with complete documentation
5. **Registration**: IANA adds scheme to permanent registry upon approval

**Provisional Scheme Registration:**

1. **Basic Specification**: Prepare documentation describing scheme purpose and basic syntax
2. **Registration Request**: Submit request to IANA with specification reference
3. **Review**: Designated expert performs basic review for namespace conflicts and completeness
4. **Registration**: IANA adds scheme to provisional registry upon approval

### Registration Template

Registration requests follow a standardized template specified in RFC 7595:

```
URI Scheme Name: [scheme-name]

Status: [Permanent/Provisional]

Scheme Syntax: [formal syntax definition]

Scheme Semantics: [description of what URIs mean]

Encoding Considerations: [character encoding rules]

Applications/Protocols That Use This Scheme: [usage context]

Interoperability Considerations: [compatibility notes]

Security Considerations: [security implications]

Contact: [name and email]

Author/Change Controller: [responsible party]

References: [specification documents]
```

### Registry Categories

The IANA registry maintains several views and categorizations:

**By Status:**

- Permanent schemes (134+ entries as of 2025)
- Provisional schemes (300+ entries as of 2025)
- Historical schemes (deprecated but documented)

**By Application Domain:**

- Network protocols (http, ftp, ssh)
- Communication (mailto, tel, sms)
- Identification (urn, tag, uuid)
- Media and content (data, javascript)
- Application-specific (spotify, slack, zoom)

### Registry Usage

**For Implementers:**

- Verify scheme standardization status before implementation
- Locate authoritative specifications
- Check for deprecated schemes to avoid
- Find contact information for scheme maintainers

**For Specification Authors:**

- Confirm scheme name availability
- Review existing schemes for similar functionality
- Understand registration requirements
- Access templates and procedures

**For Application Developers:**

- Determine appropriate schemes for use cases
- Verify scheme support across platforms
- Identify standardized alternatives to custom schemes

### Notable Registry Statistics

[Unverified] The registry contains approximately 450+ registered schemes across all categories. HTTP/HTTPS remain the most widely used, followed by mailto, ftp, and tel.

**Distribution:** [Inference] Permanent schemes represent roughly 30% of registrations, with provisional schemes comprising the majority. This distribution reflects both the rigorous requirements for permanent status and the growing ecosystem of application-specific URI handlers.

### Key Points

- IANA registry is the sole authoritative source for URI schemes
- RFC 7595 defines current registration procedures
- Registration prevents namespace collisions and promotes interoperability
- Public registry enables discovery and documentation
- Both permanent and provisional registrations are freely accessible
- Registration does not guarantee implementation or adoption
- Historical entries preserve documentation of deprecated schemes

### Coordination with Other Standards

The URI scheme registry coordinates with related IANA registries:

**Media Types Registry**: Some schemes (data, http) reference MIME media types **Port Numbers Registry**: Network schemes often have associated default ports **TLD Registry**: Schemes may interact with domain name system **Protocol Registries**: Schemes based on network protocols reference protocol specifications

This coordination ensures consistency across internet standards and prevents conflicts between different specification domains.

The IANA registry serves as the central coordination point for URI scheme namespace management, enabling the decentralized yet interoperable internet architecture that relies on standardized resource identification.

---

