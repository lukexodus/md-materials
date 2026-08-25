## Authentication Mechanisms


Authentication verifies the identity of users, devices, or processes attempting to access network resources.

### Authentication Factors

#### Something You Know (Knowledge Factor)

**Passwords:** Traditional text-based secrets known only to legitimate users **Passphrases:** Longer, more complex password alternatives using multiple words **PINs:** Numeric codes typically used with physical tokens or cards **Security Questions:** Personal information questions used for identity verification

**Password Security Considerations:**

- Complexity requirements balancing security with usability
- Regular password changes versus password fatigue
- Password storage security using hashing and salting
- Dictionary and brute-force attack resistance

#### Something You Have (Possession Factor)

**Smart Cards:** Physical devices containing embedded cryptographic capabilities **Hardware Tokens:** Dedicated devices generating time-based authentication codes **Mobile Device Authentication:** Smartphones and tablets as authentication tokens **USB Security Keys:** Hardware devices providing cryptographic authentication

**Token-Based Authentication Benefits:**

- Difficult to duplicate or steal remotely
- Time-based codes prevent replay attacks
- Hardware-based cryptographic operations
- Physical possession requirement adds security layer

#### Something You Are (Inherence Factor)

**Fingerprint Recognition:** Unique ridge patterns on fingertips **Facial Recognition:** Distinctive facial features and geometry **Voice Recognition:** Vocal characteristics and speech patterns **Retinal/Iris Scanning:** Unique eye characteristics for identification

**Biometric Considerations:**

- False positive and false negative rates affect reliability
- Template storage security prevents biometric theft
- Environmental factors may impact recognition accuracy
- Privacy concerns regarding biometric data collection

### Multi-Factor Authentication (MFA)

**Definition:** Using two or more different authentication factors simultaneously **Security Enhancement:** Compromising one factor doesn't grant complete access **Common Implementations:**

- Password + SMS code
- Smart card + PIN
- Biometric + hardware token

**Implementation Challenges:**

- User experience complexity may reduce adoption
- Additional infrastructure costs and management overhead
- Backup authentication methods for factor unavailability
- Integration with existing systems and applications

### Single Sign-On (SSO)

**Purpose:** Authenticate once to access multiple applications and services **User Experience:** Reduces password fatigue and improves productivity **Security Benefits:** Centralized authentication control and monitoring

**SSO Technologies:** **SAML (Security Assertion Markup Language):** XML-based standard for authentication assertions **OAuth:** Authorization framework enabling third-party access delegation **OpenID Connect:** Authentication layer built on OAuth 2.0 framework **Kerberos:** Network authentication protocol using symmetric key cryptography

### Certificate-Based Authentication

**Public Key Infrastructure (PKI):** Framework supporting digital certificate management **X.509 Certificates:** Standard format containing public keys and identity information **Certificate Authorities (CAs):** Trusted entities issuing and managing digital certificates **Smart Card Integration:** Storing private keys securely in tamper-resistant hardware

