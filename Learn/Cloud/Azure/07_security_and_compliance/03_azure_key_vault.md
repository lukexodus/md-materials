## Azure Key Vault


Azure Key Vault provides centralized, secure storage and management of cryptographic keys, secrets, and certificates used by cloud applications and services.

**Key Points:**

- Hardware Security Module (HSM) backed key protection
- Centralized secrets management with access policies
- Certificate lifecycle management and automation
- Integration with Azure services for seamless authentication
- Audit logging for all key and secret operations
- Geo-redundant replication for high availability

**Key Management:**

- **Software-protected keys**: AES-256 encryption in software
- **HSM-protected keys**: FIPS 140-2 Level 2 validated HSMs
- **Key rotation**: Automated and manual rotation policies
- **Key versioning**: Historical key versions for data recovery
- **Import/Export**: Secure key transfer between environments

**Secrets Management:**

- Database connection strings and API keys
- Application passwords and authentication tokens
- Configuration values and sensitive parameters
- Integration with Azure App Service and Function Apps
- Managed identity authentication for keyless access

**Certificate Management:**

- SSL/TLS certificate provisioning and renewal
- Integration with certificate authorities (CAs)
- Automatic certificate deployment to Azure services
- Certificate monitoring and expiration alerts
- Custom certificate authorities for internal PKI

**Access Control Models:**

- **Vault Access Policies**: Traditional RBAC with specific permissions
- **Azure RBAC**: Unified role-based access control integration
- **Network Access Controls**: VNet service endpoints and private endpoints
- **Firewall Rules**: IP address-based access restrictions

