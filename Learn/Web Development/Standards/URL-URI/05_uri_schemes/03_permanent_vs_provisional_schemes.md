## Permanent vs Provisional Schemes


URI schemes are classified into two registration categories by IANA (Internet Assigned Numbers Authority): **permanent** and **provisional**. This classification reflects the scheme's standardization status, stability, and expected longevity.

### Permanent Schemes

**Permanent schemes** have undergone formal review and registration through the IETF (Internet Engineering Task Force) standards process or equivalent rigorous evaluation. They are expected to remain stable and widely supported indefinitely.

**Characteristics:**

- Documented in RFCs or equivalent formal specifications
- Reviewed by the IETF or designated expert reviewers
- Stable syntax and semantics unlikely to change
- Intended for long-term, widespread use
- Subject to community consensus

**Registration Requirements:**

- Complete technical specification
- Demonstrated implementation and deployment
- Clear operational semantics
- Security considerations documented
- Interoperability requirements defined

**Examples:**

```
http, https - Web protocols (RFC 7230, RFC 2818)
ftp - File Transfer Protocol (RFC 1738)
mailto - Email addresses (RFC 6068)
tel - Telephone numbers (RFC 3966)
urn - Uniform Resource Names (RFC 8141)
file - Local filesystem access (RFC 8089)
ws, wss - WebSocket protocols (RFC 6455)
```

Permanent schemes undergo updates through additional RFCs or specification revisions. Changes follow formal processes to ensure backward compatibility and community review.

### Provisional Schemes

**Provisional schemes** are registered for experimental use, emerging technologies, or specialized applications. They may lack complete standardization, have limited deployment, or serve narrow use cases.

**Characteristics:**

- Less rigorous review process than permanent schemes
- May be experimental or application-specific
- Subject to change or deprecation
- Limited deployment or vendor-specific use
- Registration may be first-come-first-served

**Registration Requirements:**

- Basic specification document (may be less formal than RFC)
- Demonstration of intent to use
- Contact information for maintainer
- May not require implementation proof

**Examples:**

```
webcal - Calendar subscription (provisional)
facetime - Apple's video calling
steam - Valve's gaming platform
spotify - Spotify music links
slack - Slack workspace links
```

Provisional schemes may transition to permanent status if they gain widespread adoption, complete formal standardization, and demonstrate long-term viability. Alternatively, they may remain provisional indefinitely or be deprecated.

### Historical and Deprecated Schemes

Some schemes have been registered but later **deprecated** due to obsolescence, security concerns, or replacement by superior alternatives.

**Examples:**

```
gopher - Gopher protocol (largely obsolete)
wais - Wide Area Information Server (obsolete)
prospero - Prospero Directory Service (obsolete)
```

Browsers and applications may remove support for deprecated schemes, though registrations often remain for historical reference.

### Private and Unregistered Schemes

Organizations may use **unregistered schemes** for internal purposes or application-specific URI handling. These do not appear in IANA registries.

**Examples:**

```
myapp:// - Custom application protocol
x-internal:// - Private organizational scheme
```

[Inference] Unregistered schemes risk collision with future registered schemes and lack guarantees of uniqueness or interoperability. The "x-" prefix convention historically indicated experimental or private schemes, though RFC 6648 deprecated this practice.

### Comparison

|Aspect|Permanent|Provisional|
|---|---|---|
|Review Process|Rigorous IETF/expert review|Basic registration review|
|Stability|High, changes rare|May change or be deprecated|
|Documentation|Formal RFC or equivalent|May be informal specification|
|Implementation|Proven, widely deployed|May be limited or experimental|
|Expected Lifespan|Indefinite|Variable, may be temporary|

**Key Points:**

- Permanent schemes undergo formal standardization
- Provisional schemes support innovation and experimentation
- Transition from provisional to permanent is possible
- Historical schemes may remain registered but deprecated
- Registration prevents namespace collisions
- Both categories appear in IANA registry

The two-tier system balances standardization with flexibility. Permanent schemes provide stability for core internet functionality, while provisional registration enables rapid deployment of new technologies without blocking innovation during standardization.

Organizations implementing URI schemes should prefer permanent schemes for established protocols and consider provisional registration for experimental or application-specific needs. The IANA registry provides authoritative information on all registered schemes and their current status.

