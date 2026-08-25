## Simple Mail Transfer Protocol (SMTP)


SMTP provides reliable email delivery services between mail servers and from email clients to mail servers, forming the backbone of Internet email infrastructure.

### SMTP Protocol Operation

**Mail Transfer Process:**

- Client establishes TCP connection to server port 25
- Server responds with greeting message
- Client identifies itself using HELO or EHLO command
- Client specifies sender using MAIL FROM command
- Client specifies recipients using RCPT TO commands
- Client transmits message content using DATA command
- Client terminates session using QUIT command

**Extended SMTP (ESMTP):**

- EHLO command negotiates protocol extensions
- SIZE extension limits message sizes
- AUTH extension provides authentication mechanisms
- STARTTLS extension enables encryption
- PIPELINING extension improves efficiency

**Message Format Standards:**

- RFC 5322 defines message header format
- MIME extensions support multimedia content
- Quoted-printable encoding handles 8-bit characters
- Base64 encoding supports binary attachments

### SMTP Commands and Responses

**Basic Commands:**

- HELO identifies client to server
- MAIL FROM specifies message sender
- RCPT TO specifies message recipients
- DATA begins message content transmission
- RSET aborts current transaction
- QUIT terminates SMTP session

**Extended Commands:**

- EHLO requests extended capabilities
- AUTH initiates authentication process
- STARTTLS begins TLS encryption
- VRFY verifies email address validity
- EXPN expands mailing list contents

**Response Code Structure:**

- Three-digit codes indicate command results
- 2yz codes indicate successful completion
- 4yz codes indicate temporary failure
- 5yz codes indicate permanent failure
- Multi-line responses provide detailed information

### Email Routing and Delivery

**MX Record Resolution:**

- DNS MX records identify mail servers for domains
- Priority values enable backup server configuration
- Lowest priority value indicates preferred server
- Fallback to A records if MX records unavailable

**Mail Relay Operation:**

- SMTP servers forward messages toward destinations
- Relay restrictions prevent unauthorized usage
- Authentication required for external relay
- Greylisting delays initial delivery attempts

**Delivery Status Notifications:**

- Bounce messages report delivery failures
- Delivery receipts confirm successful delivery
- Message disposition notifications track user actions
- Automatic responses handle out-of-office situations

### SMTP Security and Anti-Spam

**Authentication Mechanisms:**

- SMTP-AUTH requires client authentication
- PLAIN mechanism sends credentials in clear text
- LOGIN mechanism uses base64 encoding
- CRAM-MD5 and DIGEST-MD5 provide challenge-response authentication

**Encryption and Privacy:**

- STARTTLS enables opportunistic encryption
- Mandatory TLS enforces encrypted connections
- Certificate validation prevents man-in-the-middle attacks
- Perfect Forward Secrecy protects past communications

**Anti-Spam Technologies:**

- Sender Policy Framework (SPF) validates sending servers
- DomainKeys Identified Mail (DKIM) provides message signatures
- Domain-based Message Authentication (DMARC) coordinates SPF and DKIM
- Real-time Blackhole Lists (RBLs) block known spam sources

**Content Filtering:**

- Bayesian spam filtering analyzes message content
- Regular expressions detect spam patterns
- Attachment filtering blocks dangerous file types
- Virus scanning protects against malware

