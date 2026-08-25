## Overview

service "payment-service" {
  policy = "write"
}
service_prefix "" {
  policy = "read"
}
```

Services must provide valid token to register. Read access allowed for all services, write access only for specific service.

#### Authorization

Control what each service can do in the registry.

**Access Control Levels:**

- Register own service only
- Query specific services
- Query all services
- Modify service metadata
- Administrative operations

**Key Points:**

- Principle of least privilege
- Service-specific tokens
- Audit logging for sensitive operations
- Regular token rotation

#### Encrypted Communication

Protect data in transit between services and registry.

**TLS/SSL:**

- Registry listens on HTTPS
- Client certificate authentication
- Mutual TLS (mTLS) for service-to-service

**Example:** Consul with TLS:

```hcl
tls {
  defaults {
    ca_file = "/etc/consul/ca.pem"
    cert_file = "/etc/consul/server.pem"
    key_file = "/etc/consul/server-key.pem"
    verify_incoming = true
    verify_outgoing = true
  }
}
```

All communication encrypted. Clients must present valid certificate signed by trusted CA. Man-in-the-middle attacks prevented.

### DNS-Based Service Discovery

#### How DNS Discovery Works

Services are registered with DNS names that resolve to service instance IPs.

**DNS Record Types:**

- A records: IP addresses of instances
- SRV records: IP, port, priority, weight
- DNS load balancing through multiple A records

**Key Points:**

- Uses existing DNS infrastructure
- No special client libraries needed
- Limited health checking capabilities
- DNS caching can cause staleness

**Example:** Consul DNS interface:

```bash
