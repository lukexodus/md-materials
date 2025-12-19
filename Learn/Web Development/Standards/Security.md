# Syllabus

## Module 1: Security Fundamentals

- Web security principles
- CIA triad (Confidentiality, Integrity, Availability)
- Defense in depth strategy
- Principle of least privilege
- Security by design
- Threat modeling basics
- Attack surface analysis
- Risk assessment methodology
- Security mindset and culture

## Module 2: OWASP Top 10 (Latest)

- Broken Access Control
- Cryptographic Failures
- Injection vulnerabilities
- Insecure Design
- Security Misconfiguration
- Vulnerable and Outdated Components
- Identification and Authentication Failures
- Software and Data Integrity Failures
- Security Logging and Monitoring Failures
- Server-Side Request Forgery (SSRF)

## Module 3: OWASP Additional Resources

- OWASP ASVS (Application Security Verification Standard)
- OWASP Testing Guide
- OWASP Code Review Guide
- OWASP Proactive Controls
- OWASP Cheat Sheet Series
- OWASP Mobile Security Project
- OWASP API Security Top 10
- OWASP Secure Coding Practices
- OWASP Security Knowledge Framework

## Module 4: Cross-Site Scripting (XSS)

- Reflected XSS
- Stored XSS
- DOM-based XSS
- Mutation XSS (mXSS)
- XSS attack vectors
- XSS payload construction
- XSS prevention techniques
- Output encoding strategies
- Context-aware sanitization
- XSS filters and bypasses

## Module 5: Content Security Policy (CSP)

- CSP directives overview
- default-src directive
- script-src directive
- style-src directive
- img-src directive
- connect-src directive
- font-src directive
- object-src directive
- media-src directive
- frame-src and frame-ancestors
- Nonces and hashes
- strict-dynamic keyword
- unsafe-inline and unsafe-eval
- CSP reporting mechanism
- report-uri and report-to
- CSP deployment strategies
- CSP testing and debugging
- CSP Level 2 and 3 features

## Module 6: Cross-Site Request Forgery (CSRF)

- CSRF attack mechanics
- CSRF token implementation
- SameSite cookie attribute
- Double submit cookie pattern
- Custom request headers
- Origin and Referer validation
- CSRF in modern SPAs
- CSRF prevention frameworks
- State-changing operations protection

## Module 7: SQL Injection

- SQL injection fundamentals
- Union-based SQLi
- Boolean-based blind SQLi
- Time-based blind SQLi
- Error-based SQLi
- Out-of-band SQLi
- Second-order SQLi
- Parameterized queries
- Prepared statements
- Stored procedures security
- ORM security considerations
- Input validation for SQLi
- Escaping techniques
- Database user permissions
- SQLi detection and prevention

## Module 8: Authentication Security

- Password policies and strength
- Password hashing algorithms
- bcrypt, scrypt, Argon2
- Salt generation and storage
- Pepper usage
- Rainbow table attacks
- Credential stuffing
- Password spraying
- Brute force protection
- Account lockout mechanisms
- Rate limiting strategies
- Session management
- Remember-me functionality security
- Account recovery security

## Module 9: Multi-Factor Authentication (MFA)

- MFA types and factors
- Time-based One-Time Passwords (TOTP)
- SMS-based authentication
- Email-based authentication
- Push notifications
- Hardware tokens
- Biometric authentication
- WebAuthn standard
- FIDO2 alliance
- Passkeys
- Backup codes
- MFA bypass prevention
- Account recovery with MFA

## Module 10: OAuth 2.0

- OAuth 2.0 roles
- Authorization Code flow
- Implicit flow (deprecated)
- Resource Owner Password Credentials
- Client Credentials flow
- Refresh tokens
- Access token security
- Token expiration strategies
- Scope management
- OAuth 2.0 security best practices
- PKCE (Proof Key for Code Exchange)
- State parameter usage
- Redirect URI validation
- Token introspection
- Token revocation

## Module 11: OpenID Connect (OIDC)

- OIDC layer over OAuth 2.0
- ID tokens structure
- Claims and scopes
- UserInfo endpoint
- Discovery document
- Authentication flows
- Hybrid flow
- ID token validation
- Nonce parameter
- OIDC session management
- Single Sign-On (SSO) with OIDC
- Single Logout (SLO)
- OIDC provider implementation

## Module 12: JSON Web Tokens (JWT)

- JWT structure (header, payload, signature)
- JWT signing algorithms
- Symmetric vs asymmetric signing
- HS256, RS256, ES256
- JWT claims (registered, public, private)
- JWT validation process
- JWT expiration (exp claim)
- JWT security vulnerabilities
- Algorithm confusion attacks
- None algorithm vulnerability
- JWT best practices
- JWE (JSON Web Encryption)
- JWK (JSON Web Keys)
- JWKS endpoints

## Module 13: Session Management

- Session creation and lifecycle
- Session ID generation
- Session storage mechanisms
- Cookie-based sessions
- Token-based sessions
- Session fixation attacks
- Session hijacking
- Session timeout configuration
- Idle timeout vs absolute timeout
- Secure session cookies
- HttpOnly flag
- Secure flag
- SameSite attribute
- Session regeneration
- Concurrent session management

## Module 14: Cross-Origin Resource Sharing (CORS)

- Same-Origin Policy (SOP)
- CORS preflight requests
- Simple requests vs preflight
- Access-Control-Allow-Origin
- Access-Control-Allow-Methods
- Access-Control-Allow-Headers
- Access-Control-Allow-Credentials
- Access-Control-Max-Age
- Access-Control-Expose-Headers
- CORS security misconfigurations
- Wildcard origin vulnerabilities
- Credentials and CORS
- CORS proxy patterns
- CORS in complex applications

## Module 15: Subresource Integrity (SRI)

- SRI purpose and benefits
- Integrity attribute syntax
- Hash generation (SHA-256, SHA-384, SHA-512)
- Multiple hash algorithms
- Fallback strategies
- SRI for CDN resources
- SRI browser support
- SRI deployment practices
- SRI limitations
- CORS requirements for SRI

## Module 16: HTTPS and TLS/SSL

- TLS/SSL protocol overview
- TLS handshake process
- Certificate authorities (CAs)
- X.509 certificates
- Certificate chains
- Public Key Infrastructure (PKI)
- Certificate pinning
- HTTP Strict Transport Security (HSTS)
- HSTS preload lists
- TLS versions and deprecation
- Cipher suites
- Perfect Forward Secrecy (PFS)
- Certificate transparency
- Let's Encrypt and ACME protocol
- Mixed content issues

## Module 17: HTTP Security Headers

- X-Content-Type-Options
- X-Frame-Options
- X-XSS-Protection (deprecated)
- Referrer-Policy
- Permissions-Policy (Feature-Policy)
- Cross-Origin-Embedder-Policy (COEP)
- Cross-Origin-Opener-Policy (COOP)
- Cross-Origin-Resource-Policy (CORP)
- Clear-Site-Data
- Expect-CT
- Security headers testing tools
- Header deployment strategies

## Module 18: API Security

- REST API security patterns
- GraphQL security considerations
- API authentication methods
- API keys management
- API rate limiting
- API versioning security
- Input validation for APIs
- Output encoding for APIs
- Mass assignment vulnerabilities
- API documentation security
- Swagger/OpenAPI security
- API gateway security
- Microservices security
- gRPC security

## Module 19: API Security Standards

- OWASP API Security Top 10
- Broken Object Level Authorization
- Broken User Authentication
- Excessive Data Exposure
- Lack of Resources & Rate Limiting
- Broken Function Level Authorization
- Mass Assignment
- Security Misconfiguration
- Injection
- Improper Assets Management
- Insufficient Logging & Monitoring

## Module 20: Injection Vulnerabilities

- Command injection
- LDAP injection
- XPath injection
- XML injection
- XXE (XML External Entity)
- Template injection
- Server-Side Template Injection (SSTI)
- Client-Side Template Injection
- Code injection
- Expression Language injection
- NoSQL injection
- ORM injection
- CRLF injection

## Module 21: File Upload Security

- File type validation
- Magic number verification
- File extension filtering
- Content-Type validation
- File size limits
- Filename sanitization
- Path traversal prevention
- Stored file location security
- Virus scanning integration
- Image processing vulnerabilities
- Polyglot files
- ZIP file vulnerabilities
- File upload DoS prevention

## Module 22: Clickjacking and UI Redressing

- Clickjacking attack mechanics
- Frame busting techniques
- X-Frame-Options header
- CSP frame-ancestors directive
- Likejacking
- Cursorjacking
- UI redressing variants
- Clickjacking prevention
- Testing for clickjacking

## Module 23: Server-Side Request Forgery (SSRF)

- SSRF attack vectors
- Internal network scanning via SSRF
- Cloud metadata services exploitation
- Blind SSRF
- SSRF prevention techniques
- URL validation and sanitization
- Allowlist vs blocklist approaches
- DNS rebinding attacks
- SSRF in modern applications

## Module 24: XML Security

- XML External Entity (XXE) attacks
- XML bomb (Billion Laughs attack)
- XPath injection
- XSLT injection
- XML signature wrapping
- XML parser configuration
- Disabling external entities
- XML schema validation
- SOAP security considerations

## Module 25: Deserialization Vulnerabilities

- Insecure deserialization risks
- Object injection attacks
- Remote code execution via deserialization
- Language-specific deserialization issues
- Java deserialization vulnerabilities
- Python pickle security
- PHP unserialize vulnerabilities
- .NET deserialization
- Deserialization prevention strategies
- Type validation
- Integrity checks for serialized data

## Module 26: Cryptography in Web Applications

- Symmetric encryption algorithms
- Asymmetric encryption algorithms
- AES encryption
- RSA encryption
- Elliptic Curve Cryptography (ECC)
- Key generation and storage
- Key rotation practices
- Initialization vectors (IVs)
- Salt and pepper usage
- Hashing algorithms
- SHA-2, SHA-3 families
- HMAC (Hash-based Message Authentication Code)
- Digital signatures
- Cryptographic random number generation
- Common cryptographic mistakes

## Module 27: Web Cryptography API

- SubtleCrypto interface
- Generating keys
- Encrypting and decrypting data
- Signing and verifying signatures
- Hashing with Web Crypto API
- Key derivation functions
- PBKDF2 implementation
- Importing and exporting keys
- Key wrapping and unwrapping
- Browser support and fallbacks

## Module 28: Input Validation and Sanitization

- Whitelisting vs blacklisting
- Server-side validation
- Client-side validation
- Data type validation
- Length and range validation
- Format validation
- Business logic validation
- Canonicalization
- Unicode security issues
- Homograph attacks
- Regular expression security
- ReDoS (Regular Expression Denial of Service)
- Validation libraries and frameworks

## Module 29: Output Encoding and Escaping

- Context-aware encoding
- HTML entity encoding
- JavaScript encoding
- URL encoding
- CSS encoding
- JSON encoding
- XML encoding
- SQL encoding
- LDAP encoding
- Encoding libraries
- Template engine auto-escaping
- Raw output dangers

## Module 30: Security Misconfiguration

- Default credentials
- Unnecessary features enabled
- Directory listing vulnerabilities
- Stack traces and error messages
- Security headers misconfiguration
- CORS misconfiguration
- Cloud storage misconfiguration
- S3 bucket security
- Database exposure
- Unpatched systems
- Development artifacts in production
- Configuration management

## Module 31: Access Control

- Role-Based Access Control (RBAC)
- Attribute-Based Access Control (ABAC)
- Discretionary Access Control (DAC)
- Mandatory Access Control (MAC)
- Vertical privilege escalation
- Horizontal privilege escalation
- Insecure Direct Object References (IDOR)
- Forced browsing
- Path traversal attacks
- Access control testing
- Permission boundaries
- Authorization frameworks

## Module 32: Security Logging and Monitoring

- Security event logging
- Log data to capture
- Sensitive data in logs
- Log injection attacks
- Log storage and retention
- Centralized logging
- SIEM (Security Information and Event Management)
- Real-time alerting
- Log analysis techniques
- Audit trails
- Incident detection
- Anomaly detection
- Compliance logging requirements

## Module 33: Vulnerability Scanning and Assessment

- Static Application Security Testing (SAST)
- Dynamic Application Security Testing (DAST)
- Interactive Application Security Testing (IAST)
- Software Composition Analysis (SCA)
- Vulnerability scanners overview
- Burp Suite
- OWASP ZAP
- Nmap
- Nikto
- Acunetix
- Nessus
- OpenVAS
- Automated vs manual testing
- False positive management

## Module 34: Penetration Testing

- Penetration testing methodology
- Reconnaissance and information gathering
- Scanning and enumeration
- Exploitation techniques
- Post-exploitation
- Privilege escalation
- Maintaining access
- Covering tracks
- Reporting findings
- Remediation verification
- Bug bounty programs
- Responsible disclosure

## Module 35: Secure Code Review

- Code review security checklist
- Manual code review techniques
- Automated code analysis tools
- Peer review processes
- Security-focused code review
- Common vulnerability patterns
- Framework-specific security issues
- Third-party library assessment
- Code review tools
- Pull request security gates

## Module 36: Dependency Management

- Software Bill of Materials (SBOM)
- Dependency vulnerability scanning
- npm audit
- Snyk
- Dependabot
- OWASP Dependency-Check
- License compliance
- Transitive dependencies
- Dependency pinning
- Version management strategies
- Supply chain attacks
- Package integrity verification
- Private package repositories

## Module 37: Container Security

- Docker security best practices
- Image vulnerability scanning
- Base image selection
- Minimal container images
- Container isolation
- User namespace mapping
- Secrets management in containers
- Docker Content Trust
- Kubernetes security
- Pod security policies
- Network policies
- RBAC in Kubernetes
- Container runtime security

## Module 38: Serverless Security

- Serverless architecture security
- Function-level security
- Cold start vulnerabilities
- Timeout and resource limits
- Event injection attacks
- Function permissions (IAM)
- Environment variable security
- Dependency management in serverless
- API Gateway security
- Serverless monitoring and logging
- Secrets management in serverless
- Vendor-specific security features

## Module 39: Client-Side Security

- Browser security model
- JavaScript security patterns
- DOM-based vulnerabilities
- Prototype pollution
- Client-side storage security
- localStorage and sessionStorage risks
- IndexedDB security
- Service Worker security
- Web Worker security
- WebSocket security
- WebRTC security
- Browser extension security
- Sandboxing techniques

## Module 40: Mobile Web Security

- Mobile-specific vulnerabilities
- Touch jacking
- Mobile browser security
- Progressive Web App (PWA) security
- Offline functionality security
- App cache security
- Mobile authentication patterns
- Mobile API security
- Platform-specific considerations
- iOS web security
- Android web security
- Responsive design security implications

## Module 41: Third-Party Integration Security

- Third-party script risks
- CDN security considerations
- Analytics script security
- Ad network security
- Social media widget security
- Payment processor integration
- iframe sandbox attribute
- postMessage security
- Cross-window messaging
- Subresource Integrity for third-party resources
- Third-party risk assessment

## Module 42: Payment Security

- PCI DSS compliance
- Tokenization
- Card data encryption
- Payment gateway integration
- 3D Secure (3DS)
- Strong Customer Authentication (SCA)
- Fraud detection mechanisms
- Chargeback prevention
- Payment page security
- CVV handling
- PAN (Primary Account Number) protection
- Payment method security comparison

## Module 43: Privacy and Data Protection

- GDPR compliance
- CCPA compliance
- Data minimization
- Privacy by design
- Consent management
- Cookie consent
- Privacy policies
- Data subject rights
- Right to be forgotten
- Data portability
- Privacy impact assessments
- Cross-border data transfers
- Anonymization and pseudonymization

## Module 44: Security Testing Automation

- Security in CI/CD pipelines
- Automated security testing
- Pre-commit hooks for security
- Security unit tests
- Integration security tests
- End-to-end security tests
- Continuous security monitoring
- Infrastructure as Code security
- GitOps security
- Pipeline security gates
- Security test coverage metrics

## Module 45: Web Application Firewall (WAF)

- WAF functionality
- Rule-based detection
- Signature-based detection
- Anomaly-based detection
- Virtual patching
- Rate limiting with WAF
- DDoS protection
- Bot mitigation
- WAF deployment modes
- Cloud-based WAF services
- ModSecurity
- WAF rule customization
- False positive tuning
- WAF bypass techniques

## Module 46: DDoS Protection

- DDoS attack types
- Volumetric attacks
- Protocol attacks
- Application layer attacks
- CDN-based DDoS mitigation
- Rate limiting strategies
- Connection throttling
- CAPTCHA implementation
- Proof of work challenges
- Traffic analysis
- DDoS mitigation services
- Cloudflare, Akamai, AWS Shield

## Module 47: Bot Detection and Mitigation

- Bot classification
- Good bots vs bad bots
- Bot detection techniques
- User-Agent analysis
- Behavioral analysis
- CAPTCHA systems
- reCAPTCHA implementation
- hCaptcha
- Invisible CAPTCHAs
- Device fingerprinting
- Challenge-response tests
- Bot management platforms

## Module 48: Race Conditions and Concurrency

- Race condition vulnerabilities
- Time-of-check-time-of-use (TOCTOU)
- Concurrent request handling
- Transaction isolation
- Optimistic vs pessimistic locking
- Database race conditions
- File system race conditions
- Atomic operations
- Idempotency in APIs
- Distributed system race conditions

## Module 49: Business Logic Vulnerabilities

- Business logic flaws overview
- Price manipulation
- Discount code abuse
- Workflow bypasses
- Insufficient process validation
- Transaction replay attacks
- Integer overflow vulnerabilities
- Logic testing methodologies
- Abuse case modeling
- Business rule validation

## Module 50: Social Engineering Defense

- Phishing attack vectors
- Spear phishing
- Whaling attacks
- Vishing (voice phishing)
- Smishing (SMS phishing)
- Pretexting
- Baiting
- Quid pro quo attacks
- Security awareness training
- Phishing simulation programs
- Reporting mechanisms
- Technical controls against phishing

## Module 51: Incident Response

- Incident response planning
- Incident classification
- Detection and analysis
- Containment strategies
- Eradication procedures
- Recovery processes
- Post-incident activities
- Lessons learned documentation
- Incident response team structure
- Communication protocols
- Forensic data collection
- Chain of custody
- Breach notification requirements

## Module 52: Security Compliance and Standards

- ISO/IEC 27001
- ISO/IEC 27002
- NIST Cybersecurity Framework
- CIS Controls
- PCI DSS
- SOC 2
- HIPAA (for health applications)
- FedRAMP
- Common Criteria
- Security audit preparation
- Compliance documentation
- Third-party assessments

## Module 53: Threat Intelligence

- Threat intelligence sources
- OSINT (Open Source Intelligence)
- Threat feeds
- Indicators of Compromise (IoCs)
- STIX (Structured Threat Information Expression)
- TAXII (Trusted Automated Exchange of Indicator Information)
- Threat actor profiles
- Attack pattern analysis
- CVE (Common Vulnerabilities and Exposures)
- CVSS (Common Vulnerability Scoring System)
- Threat modeling frameworks
- STRIDE methodology
- DREAD methodology

## Module 54: Security Architecture

- Secure architecture principles
- Zero Trust Architecture
- Micro-segmentation
- Network segmentation
- DMZ (Demilitarized Zone) design
- Defense in depth implementation
- Security by obscurity (limitations)
- Fail-safe defaults
- Complete mediation
- Separation of duties
- Least common mechanism

## Module 55: Secure Development Lifecycle (SDL)

- SDL phases overview
- Requirements gathering security
- Threat modeling in design phase
- Secure coding standards
- Security testing integration
- Security verification
- Security release processes
- Post-deployment security
- Security training for developers
- SDL maturity models
- Agile and DevSecOps integration

## Module 56: Security Training and Awareness

- Security culture building
- Developer security training programs
- Secure coding workshops
- Capture The Flag (CTF) exercises
- Security champions programs
- Continuous learning resources
- Security certifications (CISSP, CEH, OSCP)
- Security conferences
- Security communities and forums
- Staying current with threats

## Module 57: Emerging Security Technologies

- AI/ML in security
- Adversarial machine learning
- Blockchain security implications
- Smart contract security
- IoT web interface security
- Edge computing security
- 5G security considerations
- Quantum computing threats
- Post-quantum cryptography
- Homomorphic encryption

## Module 58: Browser Security Features

- Site Isolation
- Spectre and Meltdown mitigations
- Browser sandboxing
- Automatic HTTPS upgrades
- Password managers security
- Browser security indicators
- Certificate transparency in browsers
- Private browsing modes
- Tracking prevention
- Third-party cookie blocking
- Browser security APIs

## Module 59: Security Documentation

- Security requirements documentation
- Architecture security documentation
- Threat model documentation
- Security design patterns
- Security controls documentation
- Runbooks for security incidents
- Security knowledge base
- API security documentation
- User security guides
- Administrator security guides

## Module 60: Security Metrics and KPIs

- Security metrics framework
- Vulnerability density metrics
- Mean time to detect (MTTD)
- Mean time to respond (MTTR)
- Patching cadence metrics
- Security test coverage
- False positive rates
- Security debt tracking
- Compliance metrics
- Security training metrics
- Incident frequency metrics
- Security ROI calculation