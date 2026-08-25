## Enabling Security (TLS and Authentication)

### Overview

Elasticsearch security covers authentication (verifying identity), authorization (controlling access), and transport-layer encryption (protecting data in transit). Since version 8.0, security features are enabled by default on new installations, requiring TLS for HTTP and transport layers along with password-based authentication out of the box. This is a shift from earlier versions (particularly 6.x and early 7.x), where security was a paid feature (X-Pack) that had to be explicitly enabled and configured.

### Security Components

**Key Points**

- **Transport Layer Security (TLS/SSL)**: Encrypts communication between nodes (transport layer) and between clients and nodes (HTTP layer).
- **Authentication**: Verifies the identity of users and applications connecting to the cluster.
- **Authorization**: Determines what authenticated users are permitted to do, via roles and privileges.
- **Audit logging**: Records security-related events for compliance and troubleshooting.

### Default Security Behavior (8.x)

When a node is started for the first time in version 8.0 or later without a pre-existing configuration, Elasticsearch automatically:

- Generates TLS certificates and keys for the transport and HTTP layers.
- Enables and enforces TLS for transport-layer communication between nodes.
- Enables authentication for HTTP access, requiring a username and password.
- Generates a password for the built-in `elastic` superuser and prints it to the terminal output during the first startup.
- Generates an enrollment token that other nodes can use to join the cluster securely, and one for Kibana to establish its own trust with Elasticsearch.

[Inference] Automatic configuration behavior can differ slightly depending on the installation method (tarball, Docker, package manager) and whether the node detects an existing data directory, so the exact first-run experience should be verified against the specific installation method used.

### Manual Security Configuration

For cases where security was not auto-configured (upgrades from older versions, custom orchestration, or air-gapped environments), security must be configured manually in `elasticsearch.yml`.

**Minimum settings to enable security:**

```yaml
xpack.security.enabled: true
xpack.security.enrollment.enabled: true

xpack.security.http.ssl:
  enabled: true
  keystore.path: certs/http.p12

xpack.security.transport.ssl:
  enabled: true
  verification_mode: certificate
  keystore.path: certs/transport.p12
  truststore.path: certs/transport.p12
```

### Generating Certificates with elasticsearch-certutil

Elasticsearch ships with a certificate utility for generating a Certificate Authority (CA) and node certificates without relying on an external CA.

**Step 1: Generate a CA**

```bash
bin/elasticsearch-certutil ca
```

This produces a CA certificate and private key bundled into `elastic-stack-ca.p12`.

**Step 2: Generate node certificates signed by the CA**

```bash
bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12
```

This produces `elastic-certificates.p12`, containing a certificate and key signed by the CA, which can be distributed to all nodes.

**Step 3: Reference the certificates in configuration**

```yaml
xpack.security.transport.ssl:
  enabled: true
  verification_mode: certificate
  keystore.path: elastic-certificates.p12
  truststore.path: elastic-certificates.p12
```

Passwords for the `.p12` keystore/truststore files (if set during generation) must be stored in the Elasticsearch keystore rather than in plaintext YAML:

```bash
bin/elasticsearch-keystore add xpack.security.transport.ssl.keystore.secure_password
bin/elasticsearch-keystore add xpack.security.transport.ssl.truststore.secure_password
```

### HTTP Layer TLS

The transport layer (inter-node communication) and the HTTP layer (client-to-node communication, e.g., REST API calls) are configured independently. Enabling one does not automatically enable the other.

```yaml
xpack.security.http.ssl:
  enabled: true
  keystore.path: http.p12
  truststore.path: http.p12
```

If HTTP-layer TLS uses a CA that clients don't already trust (e.g., a self-signed or internal CA), clients need the CA certificate to validate the connection, or they must disable certificate verification (not recommended outside of testing).

### Setting the elastic User Password

After enabling security, the built-in `elastic` superuser password can be set or reset:

```bash
bin/elasticsearch-reset-password -u elastic
```

Or interactively set an auto-generated password:

```bash
bin/elasticsearch-reset-password -u elastic -i
```

### Authentication Realms

Elasticsearch supports multiple authentication mechanisms, called realms, which can be used individually or chained.

**Example**

| Realm Type | Description |
|---|---|
| `native` | Users and roles stored internally in Elasticsearch, managed via API or Kibana. |
| `file` | Users and roles defined in flat files on each node (`users`, `users_roles`). |
| `ldap` | Authenticates against an LDAP directory. |
| `active_directory` | Authenticates against Microsoft Active Directory. |
| `pki` | Authenticates using client TLS certificates (mutual TLS). |
| `saml` | Single sign-on via SAML 2.0, typically used with Kibana. |
| `oidc` | Single sign-on via OpenID Connect. |
| `kerberos` | Authenticates via Kerberos tickets. |

Realms are configured under `xpack.security.authc.realms` and are evaluated in order of a configured `order` value until one succeeds or all are exhausted.

```yaml
xpack.security.authc.realms:
  native:
    native1:
      order: 0
  ldap:
    ldap1:
      order: 1
      url: "ldaps://ldap.example.com:636"
      bind_dn: "cn=service_account,dc=example,dc=com"
      user_search:
        base_dn: "dc=example,dc=com"
        filter: "(cn={0})"
```

### API Keys

API keys are a common authentication mechanism for applications and automated processes, avoiding the need to embed user credentials directly. They can be scoped to specific privileges and given expiration times.

**Creating an API key:**

```
POST /_security/api_key
{
  "name": "monitoring-key",
  "expiration": "30d",
  "role_descriptors": {
    "monitoring_role": {
      "cluster": ["monitor"],
      "index": [
        {
          "names": ["metrics-*"],
          "privileges": ["read"]
        }
      ]
    }
  }
}
```

The response includes an `id` and `api_key` value; the encoded credential is used in requests as:

```
Authorization: ApiKey <base64(id:api_key)>
```

### Node-to-Node Communication Verification

Transport-layer TLS supports different verification modes controlling how strictly certificates are validated:

- `full`: Verifies the certificate chain and that the hostname/IP matches the certificate.
- `certificate`: Verifies the certificate chain but does not check hostname/IP matching. Commonly used with the shared node certificate generated by `elasticsearch-certutil cert`, since that certificate is typically shared across all nodes and doesn't contain individual hostnames.
- `none`: Disables verification entirely. [Speculation] This mode should generally be avoided outside of isolated test environments, as it removes protection against man-in-the-middle attacks on the transport layer.

### Security Configuration Flow

===MERMAID_DIAGRAM===
flowchart TD
    A[Start Elasticsearch Node] --> B{First-time startup and 8.x auto-config eligible?}
    B -->|Yes| C[Auto-generate CA and certificates]
    C --> D[Enable TLS on transport and HTTP layers]
    D --> E[Generate elastic user password]
    E --> F[Print enrollment token]
    B -->|No / Manual setup| G[Run elasticsearch-certutil to create CA and certs]
    G --> H[Configure xpack.security.transport.ssl in elasticsearch.yml]
    H --> I[Configure xpack.security.http.ssl in elasticsearch.yml]
    I --> J[Store keystore/truststore passwords via elasticsearch-keystore]
    J --> K[Set xpack.security.enabled: true]
    K --> L[Start or restart node]
    F --> M[Cluster ready with TLS and authentication enforced]
    L --> M
```

### Verifying Security Is Active

After configuration, authenticated requests can be tested:

```bash
curl -u elastic:<password> -k https://localhost:9200/_security/_authenticate?pretty
```

A successful response returns the authenticated user's details, roles, and metadata, confirming both TLS termination and authentication are functioning.

### Common Pitfalls

**Key Points**

- Forgetting that transport and HTTP SSL settings are configured separately, leading to one layer being encrypted while the other remains open.
- Using `verification_mode: full` with a shared certificate that lacks per-node hostname entries, causing node-to-node communication failures.
- Storing keystore passwords in plaintext `elasticsearch.yml` instead of the secure Elasticsearch keystore.
- Not distributing the same CA/certificate consistently across all nodes, breaking transport-layer trust.
- Overlooking that Kibana requires its own service account or enrollment token and separate TLS trust configuration to communicate with a secured Elasticsearch cluster.

### Related Topics

- Role-Based Access Control (RBAC): roles, privileges, and role mappings
- Configuring realms in depth (LDAP, SAML, OIDC integration)
- Field- and document-level security
- Audit logging configuration
- Securing Kibana's connection to Elasticsearch
- Certificate renewal and rotation strategies