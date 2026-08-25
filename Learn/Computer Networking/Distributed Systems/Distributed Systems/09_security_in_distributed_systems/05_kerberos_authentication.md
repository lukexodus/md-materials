## Kerberos Authentication


### Protocol Architecture

**Three-party authentication model**: Client, Authentication Server (AS), Ticket-Granting Server (TGS), and application servers. Separates authentication from authorization and service access. Single sign-on achieved through ticket-based credentials with limited lifetime.

**Symmetric key cryptography foundation**: All parties share secret keys with Key Distribution Center (KDC). Client derives key from password hash. Service principals have keys stored in keytab files. No public key infrastructure required in base protocol (PKINIT extension adds PKI support).

**Ticket-based credentials**: Encrypted data structures proving identity. Tickets encrypted with service's secret key, unreadable by client. Prevents forgery and replay across different services. Include timestamps, authorization data, session keys.

**Realm-based namespacing**: Administrative domain containing principals and KDC. Principal names formatted as `primary/instance@REALM`. Cross-realm authentication via trust relationships and referral tickets. Hierarchical (parent-child) or non-hierarchical (peer) trust topologies.

### Authentication Exchange Protocol

**AS-REQ (Authentication Service Request)**: Client sends plaintext request containing username, requested service (krbtgt/REALM for TGT), timestamp. Pre-authentication data (encrypted timestamp using client's key) prevents offline password guessing. AS validates timestamp freshness (within 5 minutes default clock skew).

**AS-REP (Authentication Service Reply)**: AS returns TGT encrypted with TGS key, session key encrypted with client's key. TGT contains client identity, session key, validity period, authorization data. Client decrypts session key using password-derived key, stores TGT in credential cache.

**TGS-REQ (Ticket-Granting Service Request)**: Client presents TGT and authenticator (timestamp encrypted with session key) to request service ticket. Specifies target service principal. May request ticket flags (forwardable, proxiable, renewable). TGS validates TGT signature, authenticator freshness, client identity match.

**TGS-REP (Ticket-Granting Service Reply)**: TGS returns service ticket encrypted with service's key, new session key encrypted with TGT session key. Service ticket contains client identity, service session key, authorization data. Client stores service ticket in credential cache, keyed by service principal name.

**AP-REQ (Application Request)**: Client sends service ticket and authenticator to application server. Authenticator includes timestamp, checksum over application data. Server decrypts ticket using its key, extracts session key, decrypts authenticator, validates timestamp and checksum.

**AP-REP (Application Reply)**: Optional mutual authentication. Server returns timestamp from authenticator incremented by one, encrypted with session key. Client verifies server possesses session key and processed authenticator. Prevents man-in-the-middle attacks.

### Ticket Structure and Fields

**Encrypted portion**: Client principal, session key, timestamps (authtime, starttime, endtime, renew-till), authorization data, transited realm path. Encrypted using service's long-term key (DES, 3DES, AES128-CTS-HMAC-SHA1-96, AES256-CTS-HMAC-SHA1-96). Include HMAC for integrity protection.

**Plaintext portion**: Service principal, realm, encryption algorithm, key version number (KVNO). KVNO enables key rotation without coordinated cutover. Server tries multiple keys on KVNO mismatch.

**Ticket flags**: Forwardable (allows obtaining tickets from remote host), forwarded (obtained via forwarded TGT), proxiable (allows proxy tickets for different network addresses), proxy, renewable (can extend lifetime), initial (obtained via AS exchange), pre-authenticated, HW-authenticated, transit-policy-checked. Flags control delegation and lifetime semantics.

**Authorization data**: Privilege Attribute Certificate (PAC) contains user group memberships, SIDs (Windows), privilege assertions. PAC signed by KDC to prevent tampering. Application servers parse PAC for authorization decisions. Active Directory includes PAC by default; MIT Kerberos optional.

**Lifetime and renewal**: Initial ticket lifetime (8-10 hours typical). Renewable tickets extend lifetime without re-authentication up to maximum renewable lifetime (7 days typical). Clients automatically renew before expiration. Balances security (limited exposure) and usability (avoid repeated password prompts).

### Key Distribution and Management

**KDC database**: Stores principal records with keys, policy attributes, maximum ticket lifetimes, key version numbers. MIT Kerberos uses Berkeley DB or LDAP backend. Active Directory stores in AD database. Replicated across multiple KDC servers for availability.

**Master key**: Encrypts principal keys at rest in KDC database. Stored in stash file on KDC server filesystem with restricted permissions. Master key compromise exposes all principal keys. Hardware Security Module (HSM) integration protects master key.

**Password-to-key derivation**: PBKDF2 or string2key function derives encryption key from password. Salted with realm and principal name. Multiple encryption types (enctypes) supported per principal. Client attempts each enctype until successful. Weak passwords vulnerable to offline dictionary attacks on captured AS-REP.

**Keytab files**: Store long-term keys for service principals. Binary file format, restricted filesystem permissions. Services read keytab at startup to decrypt service tickets. Key rotation requires updating keytab and KVNO synchronization with KDC. Keytab extraction from compromised host exposes service impersonation capability.

**Key version numbers (KVNO)**: Incremented on key change. Ticket includes KVNO to indicate which key decrypts ticket. Server tries current and previous keys. KVNO mismatch errors indicate clock skew, key desynchronization, or configuration errors.

**Encryption type negotiation**: Client advertises supported enctypes in AS-REQ. KDC selects strongest mutually supported enctype. Service tickets encrypted with service's strongest key. Weak enctypes (DES, RC4-HMAC) deprecated due to cryptographic weaknesses. AES256-CTS-HMAC-SHA1-96 current best practice.

### Clock Synchronization Requirements

**Timestamp validation**: Authenticators include client timestamp. Server rejects if timestamp outside acceptable skew window (default 5 minutes). Prevents replay attacks. Assumes loosely synchronized clocks via NTP.

**Clock skew handling**: KDC and application servers compare received timestamp to local clock. Skew exceeding window causes `KRB_AP_ERR_SKEW`. Clients must synchronize clocks or adjust offset based on error response. Persistent skew errors indicate NTP misconfiguration.

**Replay cache**: Server maintains cache of recently seen authenticators (timestamp, checksum) within skew window. Duplicate authenticators rejected. Cache bounded by window size and purged on expiration. Memory consumption proportional to request rate and skew window.

**Timestamp-free alternatives**: PKINIT uses nonces instead of timestamps for freshness. Eliminates clock synchronization requirement. Anonymous PKINIT enables unauthenticated TGT acquisition for subsequent FAST armor.

### Cross-Realm Authentication

**Trust relationships**: Realms establish trust via shared inter-realm key. Hierarchical trusts follow DNS naming (child trusts parent). Non-hierarchical trusts require explicit principal `krbtgt/REMOTEREALM@LOCALREALM` in both KDCs.

**Referral tickets**: Client requests service in remote realm. Local TGS returns referral ticket for remote TGS. Client contacts remote TGS with referral to obtain final service ticket. Transited field records realm path for policy validation.

**Transit path validation**: Application servers optionally enforce transit path restrictions. Prevents unauthorized realm traversals. `transit-policy-checked` flag indicates KDC validated path. Requires TGS to maintain inter-realm topology database.

**Capaths configuration**: Client-side configuration specifying valid referral paths between realms. Prevents malicious referrals through untrusted intermediaries. Large multi-realm deployments require careful capaths maintenance.

**Active Directory forests**: Forest root serves as ultimate trust anchor. Transitive trusts within forest. External and forest trusts to separate forests. SID filtering prevents privilege elevation across forest boundaries.

### Credential Delegation

**Forwardable tickets**: Client obtains forwardable TGT, presents to intermediate server. Intermediate server requests new TGT on client's behalf (forwarded flag set). Forwarded TGT enables intermediate server to authenticate as client to backend services. GSS-API delegation via `gss_init_sec_context` with `GSS_C_DELEG_FLAG`.

**Constrained delegation**: Limits services that can be accessed with delegated credentials. Service1 configured to delegate only to Service2. Prevents lateral movement after Service1 compromise. Active Directory S4U2Proxy (Service-for-User-to-Proxy) protocol. MIT Kerberos requires `ok_to_auth_as_delegate` flag.

**Protocol transition (S4U2Self)**: Service obtains ticket for user without user credentials. Enables Kerberos authentication after non-Kerberos authentication (e.g., NTLM, form-based). Service must be trusted for delegation in Active Directory. Resulting ticket marked with protocol-transition flag.

**Resource-based constrained delegation**: Backend service controls which frontend services can delegate. Policy stored on resource rather than delegating service. Simplifies delegation configuration in large environments. Requires Windows Server 2012+ Active Directory functional level.

**Delegation risks**: Forwardable TGT compromise enables full impersonation within ticket lifetime. Minimize delegation scope via constrained delegation. Short ticket lifetimes reduce exposure window. Monitor delegation usage for anomalous patterns.

### GSS-API Integration

**Generic Security Services API**: Abstraction layer enabling application protocol independence from security mechanism. Kerberos implements GSS-API mechanism. Applications use GSS-API calls; Kerberos details abstracted. Enables mechanism negotiation (SPNEGO).

**Security context establishment**: `gss_init_sec_context` (client) and `gss_accept_sec_context` (server) exchange tokens. Initial token contains AP-REQ. Subsequent tokens for mutual authentication, channel binding, or subkey negotiation. Context provides session key for message protection.

**Message protection**: `gss_wrap` provides confidentiality and integrity. `gss_get_mic` provides integrity only. Negotiated during context establishment via `GSS_C_CONF_FLAG`, `GSS_C_INTEG_FLAG`. Kerberos uses Encrypt-then-MAC construction.

**Channel binding**: Cryptographically binds GSS-API context to underlying channel (TLS). Prevents man-in-the-middle attacks between application and Kerberos layers. Channel binding token includes hash of TLS certificate or channel parameters. Compared in AP-REQ checksum.

**Credential acquisition**: Applications call `gss_acquire_cred` to obtain credentials. Reads from credential cache (kinit-initialized) or keytab (service principals). Credential handle passed to context establishment functions.

### SPNEGO and Mechanism Negotiation

**Simple and Protected GSS-API Negotiation Mechanism**: Meta-mechanism negotiating between multiple GSS-API mechanisms. Client advertises supported mechanisms in preference order. Server selects first acceptable mechanism. Prevents downgrade attacks via mechanism integrity check.

**HTTP Negotiate**: Browser sends `Authorization: Negotiate <base64-token>`. Token contains SPNEGO negotiation with Kerberos as preferred mechanism. NTLM fallback for non-Kerberos environments. Server response `WWW-Authenticate: Negotiate <response-token>`.

**Optimistic mechanism selection**: Client includes initial mechanism token (Kerberos AP-REQ) with negotiation request. Eliminates round-trip if server supports preferred mechanism. Fallback to alternative mechanisms on rejection.

**NTLM interoperability**: SPNEGO enables transparent fallback to NTLM in mixed environments. NTLM uses challenge-response with password hash. Weaker than Kerberos (no mutual authentication, vulnerable to relay attacks). Modern deployments disable NTLM fallback.

### Flexible Authentication Secure Tunneling (FAST)

**Armored authentication**: Protects AS exchange within encrypted FAST channel. Prevents offline dictionary attacks on AS-REP. Enables strong pre-authentication without exposing password-derived key.

**FAST armor**: Existing TGT or anonymous PKINIT certificate provides armor ticket. Armor key derived from armor ticket and KDC key. Pre-authentication data encrypted within FAST tunnel. AS-REP encrypted with armor key.

**Fresh armor requirement**: Armor ticket must be unexpired and not previously used. Prevents replay of FAST-armored requests. KDC tracks used armor tickets within validity window.

**Cookie-based continuation**: KDC returns opaque cookie for multi-round-trip exchanges. Client includes cookie in subsequent requests. Enables complex pre-authentication mechanisms (multi-factor, smart card) without connection-oriented protocol.

### Pre-Authentication Mechanisms

**Encrypted timestamp**: Client encrypts current timestamp with password-derived key. Proves password possession without transmitting password. Vulnerable to offline dictionary attacks if AS-REQ captured. FAST armor mitigates this vulnerability.

**PKINIT (Public Key Cryptography for Initial Authentication)**: Client uses X.509 certificate and private key. Certificate validated against KDC's trust anchors. Eliminates password-based authentication weakness. Supports smart cards, hardware tokens. Diffie-Hellman key exchange provides PFS.

**Anonymous PKINIT**: Acquires TGT without proving identity. Anonymous TGT used as FAST armor for subsequent password-based authentication. Enables FAST without bootstrapping problem. Requires KDC to allow anonymous authentication.

**OTP pre-authentication**: One-time password challenges. KDC sends challenge, client responds with OTP. RADIUS backend integration for hardware tokens. Multi-factor authentication extension to Kerberos.

**Smart card pre-authentication**: Private key on smart card signs challenge. PIN unlocks card for signing operation. Combined with PKINIT certificate. Common in high-security environments, US DoD CAC cards.

### Service Principal Name (SPN) Management

**SPN registration**: Service principal registered in KDC database. Maps service name to host and instance. Windows requires SPN registration in Active Directory via `setspn` utility. Missing or incorrect SPN causes service ticket request failures.

**Canonical names**: Service accessed via multiple DNS names (alias, load balancer VIP). Each name requires SPN registration. Active Directory links SPNs to single service account. Client canonicalizes service name to SPN via DNS lookup and KDC rules.

**SPN format**: `service/hostname.realm@REALM` for MIT Kerberos. `SERVICE/hostname` registered in Active Directory. Service type examples: HTTP, host, LDAP, postgres, cifs. Case-insensitive in Active Directory, case-sensitive in MIT Kerberos.

**Service account types**: User accounts (human or service), machine accounts (computer objects), managed service accounts (MSAs), group managed service accounts (gMSAs). gMSAs provide automatic password rotation and SPN management.

**SPN conflicts**: Duplicate SPN registration causes authentication failures. KDC returns `KDC_ERR_S_PRINCIPAL_UNKNOWN` or wrong service key decrypts ticket. Active Directory validates SPN uniqueness. Duplicate detection via `setspn -X`.

### Credential Cache Management

**Cache types**: FILE (traditional file cache), KEYRING (Linux kernel keyring), MEMORY (process-private), API (Windows SSPI credential cache). Default cache per user session. Multiple caches via cache collection (primary and named caches).

**Cache location**: Unix default `/tmp/krb5cc_<uid>`. Environment variable `KRB5CCNAME` overrides. Windows uses LSA cache. Cache file permissions restrict to owner. World-readable cache enables credential theft.

**Credential lifecycle**: `kinit` acquires initial TGT. Applications obtain service tickets on demand via GSS-API. Background process renews tickets before expiration. `kdestroy` purges cache on logout. Credential cache survives process exit for SSO.

**Cache collection**: Multiple caches within collection, one primary. `kinit -c CACHE:collection:name` creates named cache. Applications iterate collection to find valid credentials. Enables switching between identities without kinit overhead.

**Ticket refresh strategies**: Automatic renewal by krenew, k5start daemons. Cron job runs kinit with keytab. SystemD timer units. Application-initiated renewal via `gss_acquire_cred` with `GSS_C_CRED_RENEW` flag. Balance between security (short lifetime) and operational burden.

### Active Directory Kerberos Extensions

**Privilege Attribute Certificate (PAC)**: Embedded in Kerberos ticket. Contains user SID, group memberships, privilege flags. Signed by KDC using `krbtgt` key and server's key. Application server validates PAC signatures, extracts authorization data for access control decisions.

**PAC validation**: Server verifies PAC signature using KDC key (generic signature) and own key (server signature). Prevents client from forging group memberships. Requires server to contact KDC for signature verification or maintain cached KDC key.

**RC4-HMAC encryption**: Windows default enctype for backward compatibility. MD4 hash of Unicode password is encryption key. Cryptographically weaker than AES. Vulnerable to rainbow tables if password hash extracted. Disable via Group Policy for AES-only environments.

**Compound authentication**: Combines user and device authentication. Device ticket included in TGS request. Enables authorization policies requiring both authenticated user and trusted device. Dynamic Access Control prerequisite.

**Claims transformation**: User and device claims (attributes) embedded in PAC. Claims mapped to file/directory permissions via central policy rules. Enables attribute-based access control (ABAC) in Windows environments.

**Selective authentication**: Cross-forest trust with restricted TGT. User granted `Allowed to Authenticate` permission on specific computers in remote forest. Prevents unrestricted access after trust establishment. Mitigates lateral movement in forest-to-forest trust scenarios.

### High Availability and Scalability

**KDC replication**: Master KDC accepts writes (password changes, principal creation). Slave KDCs replicate database via `kpropd` (MIT) or Active Directory replication. Clients configured with multiple KDC addresses. Automatic failover on KDC unreachability.

**DNS-based KDC discovery**: SRV records `_kerberos._tcp.<realm>` and `_kerberos._udp.<realm>` advertise KDC locations. Client queries DNS, tries KDCs in priority order. Dynamic KDC topology without client reconfiguration. Weight and priority fields enable load distribution.

**Read-only domain controllers (RODC)**: Active Directory domain controller without writeable database. Caches credentials after first authentication. Reduces WAN traffic from branch offices. Credential theft risk mitigated by limited cached credentials.

**Horizontal KDC scaling**: Stateless AS/TGS operations enable load distribution. Anycast IP addresses for KDC service. Geographic distribution reduces latency. Database replication lag causes temporary inconsistency (new password not yet replicated).

**Credential cache scalability**: Large deployments with many service tickets exhaust cache size. Periodic purging of expired tickets. Lazy ticket acquisition (obtain on first use) vs eager (obtain all at login). Credential cache per application process limits blast radius.

### Security Considerations

**Ticket encryption key exposure**: Service ticket encrypted with service's key. Key compromise enables offline ticket decryption and forgery. Key rotation limits exposure window. Hardware Security Modules (HSMs) protect high-value keys.

**Golden ticket attacks**: `krbtgt` key compromise enables forging arbitrary TGTs. Attacker creates tickets with any identity and lifetime. Detection via anomalous ticket lifetimes, encryption types, authorization data. Mitigation requires `krbtgt` password reset twice (current and previous KVNO).

**Silver ticket attacks**: Service key compromise enables forging service tickets. Bypasses TGS interaction, no KDC logging. Detection via missing TGS-REQ events for service access. Mitigation requires service key rotation.

**Pass-the-ticket attacks**: Attacker extracts valid tickets from compromised credential cache or memory. Tickets usable until expiration. Short ticket lifetimes limit window. Detection via anomalous source IPs for ticket usage.

**Kerberoasting**: Service account password extracted via offline cracking of service tickets. Attacker requests tickets for SPNs, extracts encrypted portion, brute-forces password. Mitigation: strong service account passwords (25+ characters), managed service accounts with automatic rotation.

**AS-REP roasting**: Users with pre-authentication disabled return encrypted AS-REP. Offline password cracking similar to Kerberoasting. Mitigation: enforce pre-authentication for all users, strong passwords, monitor accounts with disabled pre-authentication.

**Encryption downgrade attacks**: Attacker modifies supported enctype list to force weak encryption. DES, RC4-HMAC vulnerable to rapid offline cracking. Mitigation: disable weak enctypes at KDC, enforce strong enctypes via Group Policy.

### Monitoring and Troubleshooting

**KDC logging**: AS-REQ, TGS-REQ events logged with client IP, principal, requested service, enctype. Failed authentication reasons (pre-auth failure, clock skew, expired ticket). Log volume proportional to authentication rate. Centralized logging (syslog, Splunk) for security monitoring.

**Client-side debugging**: `KRB5_TRACE` environment variable enables detailed protocol tracing. Shows DNS lookups, KDC communication, ticket cache operations, GSS-API calls. Useful for troubleshooting authentication failures.

**Service-side debugging**: Server logs AP-REQ processing failures. Common errors: clock skew (`KRB_AP_ERR_SKEW`), replay (`KRB_AP_ERR_REPEAT`), key mismatch (`KRB_AP_ERR_MODIFIED`). Check service keytab KVNO matches KDC database.

**Network traffic analysis**: Capture Kerberos UDP/TCP port 88 traffic. Wireshark dissects AS-REQ/REP, TGS-REQ/REP, AP-REQ/REP. Encrypted portions opaque, but error codes and unencrypted fields visible. Identifies KDC reachability issues, DNS problems.

**Performance metrics**: KDC requests per second, latency percentiles (p50, p95, p99). Database query times, replication lag. Ticket cache hit rate (service tickets vs TGS requests). High TGS request rate indicates cache misses or short ticket lifetimes.

**Security monitoring**: Failed authentication spike indicates brute-force attack. TGS requests for disabled accounts suggest compromised credentials. Service tickets requested for unusual SPNs indicate Kerberoasting reconnaissance. Correlate with SIEM events.

### Protocol Limitations and Alternatives

**UDP packet size limits**: AS-REP and TGS-REP may exceed UDP MTU with large PACs. Requires TCP fallback or UDP fragmentation. TCP adds connection overhead. EDNS0 increases UDP buffer size but not universally supported.

**No credential revocation**: Issued tickets valid until expiration regardless of password change or account disable. Short ticket lifetimes mitigate impact. Checking account status at every service access defeats Kerberos scalability benefits.

**Limited cross-platform support**: Windows Active Directory Kerberos differs from MIT Kerberos. PAC semantics, encryption types, trust models vary. SSPI vs GSS-API differences complicate interoperability. Samba bridges Windows/Unix Kerberos.

**OAuth 2.0 and OIDC**: Modern alternatives for web-based authentication. Token-based with explicit revocation. REST-friendly JSON tokens vs binary Kerberos tickets. No time synchronization requirement. Wider cross-platform support. Kerberos retained for internal enterprise SSO, file shares, legacy applications.

**SAML**: XML-based SSO protocol. Browser-based authentication flow. Federation across organizational boundaries. SAML assertion similar to Kerberos ticket but HTTPS transport. Integration: Kerberos authenticates to IdP, SAML federates to SPs.

### Related Topics

- Network Time Protocol (NTP) architecture and security
- Public Key Infrastructure (PKI) and certificate management
- LDAP directory services and schema design
- RADIUS and TACACS+ for network device authentication
- Smart card authentication and hardware security tokens
- Active Directory domain services architecture
- Single sign-on (SSO) patterns and federation protocols
- SAML and OAuth 2.0 authentication flows
- Identity and access management (IAM) systems
- Privileged access management (PAM) solutions
- Security information and event management (SIEM)
- Lateral movement detection and prevention
- Zero-trust network architecture
- Mutual TLS authentication
- Diffie-Hellman key exchange protocols

---

