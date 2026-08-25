## MD5 vs. SCRAM-SHA-256 Authentication in PostgreSQL


### Overview of Authentication Methods
In PostgreSQL, authentication methods defined in the **pg_hba.conf** file control how clients are verified when connecting to the database, whether using connection types like **local**, **host**, **hostssl**, or **hostnossl**. Two common password-based authentication methods are **MD5** and **SCRAM-SHA-256**, each with distinct security, performance, and compatibility characteristics. MD5, an older method, relies on a hash-based challenge-response mechanism, while SCRAM-SHA-256, introduced in PostgreSQL 10, uses a more secure, modern standard for password authentication. Understanding the differences between MD5 and SCRAM-SHA-256 is critical for securing PostgreSQL databases, especially in **Online Transaction Processing (OLTP)** systems requiring high concurrency or **Online Analytical Processing (OLAP)** systems needing robust remote access. This guide provides a comprehensive comparison of MD5 and SCRAM-SHA-256, covering their mechanics, security, performance, configuration, and best practices.

**Key points**:
- MD5 uses a hash-based authentication with known security weaknesses; SCRAM-SHA-256 is a modern, cryptographically secure standard.
- Both methods support password-based authentication in **pg_hba.conf** for all connection types.
- SCRAM-SHA-256 offers stronger protection against password leaks and replay attacks.
- MD5 is widely compatible but deprecated; SCRAM-SHA-256 is preferred for new deployments.
- Configuration and client support impact the choice, especially for legacy systems or cloud environments.

### MD5 Authentication
**MD5** authentication in PostgreSQL is a challenge-response mechanism that uses the MD5 hash function to verify client passwords. Introduced in early PostgreSQL versions, it was designed to avoid sending plaintext passwords over the network but has significant security limitations by modern standards.

#### Mechanics
- **Process**:
  1. The client sends a connection request with the username.
  2. The server responds with a random salt.
  3. The client computes an MD5 hash of the password concatenated with the username, then another MD5 hash of that result concatenated with the salt.
  4. The client sends the final hash to the server.
  5. The server compares the client’s hash with its stored hash (password + username, hashed with MD5).
- **Storage**:
  - Passwords are stored in **pg_authid.rolpassword** as `md5` + MD5(password + username).
  - Example: For user `app_user` with password `secret`, the stored hash is `md5` + MD5(`secretapp_user`).
- **pg_hba.conf Entry**:
  ```conf
  host all app_user 192.168.1.0/24 md5
  ```
- **Client Connection**:
  ```bash
  psql -U app_user -h dbserver -d mydb
  ```

**Key points**:
- Avoids plaintext password transmission but sends a hash vulnerable to attacks.
- Stored hashes are tied to usernames, requiring recalculation if usernames change.
- Fast authentication due to simple MD5 hashing, suitable for low-latency OLTP.
- Widely supported by all PostgreSQL clients and versions.
- Deprecated in favor of SCRAM-SHA-256 due to security flaws.

#### Security Considerations
- **Weaknesses**:
  - MD5 is cryptographically broken, vulnerable to collision and preimage attacks.
  - Stored hashes can be brute-forced if **pg_authid** is compromised, especially with weak passwords.
  - Susceptible to replay attacks if the hash is intercepted (though mitigated by salts).
  - No protection against password exposure if the server’s stored hashes are stolen.
- **Mitigations**:
  - Use strong, unique passwords to increase brute-force difficulty.
  - Combine with **hostssl** connections to encrypt communication.
  - Restrict **pg_hba.conf** to trusted IPs (e.g., `192.168.1.0/24`).

#### Use Cases
- **Legacy OLTP Systems**: Applications using older PostgreSQL versions or clients without SCRAM support.
- **Development Environments**: Quick setups where security is less critical.
- **Low-Security OLAP**: Temporary analytics databases on trusted networks.
- **Compatibility**: Supporting outdated drivers or tools (e.g., old JDBC versions).

**Example**:
```conf
# pg_hba.conf
hostssl mydb app_user 10.0.0.0/16 md5
```
```sql
-- Set MD5 password
ALTER ROLE app_user WITH PASSWORD 'secret';
```
```bash
# Connect
psql "host=10.0.0.100 user=app_user dbname=mydb sslmode=require"
```

**Output**:
- Prompts for password, connects if the MD5 hash matches.

**Conclusion**:
MD5 authentication is simple and compatible, suitable for legacy OLTP systems with **hostssl** connections, but its security weaknesses make it unsuitable for modern, secure deployments.

### SCRAM-SHA-256 Authentication
**SCRAM-SHA-256** (Salted Challenge Response Authentication Mechanism with SHA-256) is a modern, cryptographically secure authentication method introduced in PostgreSQL 10. Based on the IETF RFC 5802 standard, it provides robust protection against password leaks, replay attacks, and brute-forcing, making it the preferred choice for secure PostgreSQL deployments.

#### Mechanics
- **Process**:
  1. The client initiates a connection with the username.
  2. The server sends a random nonce and salt from the stored credentials.
  3. The client computes a proof using the password, salt, and nonces (client and server), applying SHA-256 and PBKDF2 (Password-Based Key Derivation Function 2).
  4. The client sends the proof to the server, which verifies it against the stored verifier.
  5. Mutual authentication occurs, as the server also proves its identity to the client.
- **Storage**:
  - Passwords are stored in **pg_authid.rolpassword** as SCRAM-SHA-256 verifiers, including salt, iteration count, and hashed keys.
  - Example: `SCRAM-SHA-256$4096:<salt>:<stored_key>:<server_key>`.
- **pg_hba.conf Entry**:
  ```conf
  host all app_user 192.168.1.0/24 scram-sha-256
  ```
- **Client Connection**:
  ```bash
  psql -U app_user -h dbserver -d mydb
  ```

**Key points**:
- Uses SHA-256 and PBKDF2 for strong cryptographic protection.
- Mutual authentication ensures both client and server are trusted.
- Stored verifiers are resistant to brute-forcing due to high iteration counts.
- Supported in PostgreSQL 10+ and modern clients (e.g., psql, JDBC, libpq).
- Slightly higher computational overhead than MD5, but negligible for most OLTP/OLAP workloads.

#### Security Considerations
- **Strengths**:
  - Resistant to replay attacks due to unique nonces per session.
  - Stored verifiers use PBKDF2 with high iterations, making brute-forcing impractical.
  - No password exposure even if **pg_authid** is compromised, as verifiers require computational effort to crack.
  - Mutual authentication protects against server impersonation.
- **Mitigations**:
  - Use **hostssl** to encrypt communication, as SCRAM-SHA-256 only secures authentication.
  - Enforce strong passwords to further enhance security.
  - Monitor for failed authentication attempts in logs.

#### Use Cases
- **Secure OLTP Systems**: E-commerce, banking, or healthcare applications requiring robust authentication.
- **OLAP in Cloud**: Data warehouses accessed over public networks with **hostssl**.
- **Regulatory Compliance**: Meeting GDPR, HIPAA, or PCI-DSS standards.
- **Modern Deployments**: New PostgreSQL installations or upgrades from older versions.

**Example**:
```conf
# pg_hba.conf
hostssl mydb secure_user 10.0.0.0/16 scram-sha-256
```
```sql
-- Set SCRAM-SHA-256 password
SET password_encryption = 'scram-sha-256';
ALTER ROLE secure_user WITH PASSWORD 'strongpassword';
```
```bash
# Connect
psql "host=10.0.0.100 user=secure_user dbname=mydb sslmode=verify-full"
```

**Output**:
- Prompts for password, connects securely if credentials match.

**Conclusion**:
SCRAM-SHA-256 provides strong, modern authentication for OLTP and OLAP systems, ensuring secure access with **hostssl** connections. It is the recommended method for production environments.

### Comparison of MD5 and SCRAM-SHA-256
MD5 and SCRAM-SHA-256 differ significantly in security, performance, and compatibility, impacting their suitability for various workloads.

| Aspect                  | MD5                              | SCRAM-SHA-256                    |
|-------------------------|----------------------------------|-----------------------------------|
| **Security**            | Weak (broken MD5 hash)          | Strong (SHA-256, PBKDF2)         |
| **Replay Protection**   | Limited (salt-based)            | Strong (nonces)                  |
| **Password Storage**    | MD5 hash (vulnerable)           | SCRAM verifier (resistant)       |
| **Mutual Authentication**| No                              | Yes                              |
| **Performance**         | Faster (simple hash)            | Slower (PBKDF2 iterations)       |
| **Compatibility**       | All PostgreSQL versions         | PostgreSQL 10+                   |
| **Client Support**      | Universal (legacy drivers)      | Modern clients (psql, JDBC)      |
| **Use Case**            | Legacy, low-security systems    | Secure, modern deployments       |

**Key points**:
- SCRAM-SHA-256 is cryptographically secure, ideal for production OLTP/OLAP.
- MD5 is faster but insecure, suitable only for legacy or non-critical systems.
- SCRAM-SHA-256 requires PostgreSQL 10+ and modern clients, limiting use in older setups.
- Both work with all connection types (**local**, **host**, **hostssl**, **hostnossl**).
- Transition to SCRAM-SHA-256 is recommended for compliance and security.

### Configuration in PostgreSQL
Configuring MD5 or SCRAM-SHA-256 involves setting the authentication method in **pg_hba.conf** and ensuring proper password storage.

#### Setting Password Encryption
- **postgresql.conf**:
  ```conf
  password_encryption = 'scram-sha-256'  # or 'md5'
  ```
- **Apply Changes**:
  ```sql
  SELECT pg_reload_conf();
  ```
- **Set Password**:
  ```sql
  SET password_encryption = 'scram-sha-256';
  ALTER ROLE app_user WITH PASSWORD 'strongpassword';
  ```

#### pg_hba.conf Configuration
- **MD5 Example**:
  ```conf
  host all all 192.168.1.0/24 md5
  ```
- **SCRAM-SHA-256 Example**:
  ```conf
  hostssl all all 192.168.1.0/24 scram-sha-256
  ```

**Key points**:
- Set `password_encryption` before creating or updating passwords to ensure correct storage.
- Use **hostssl** with SCRAM-SHA-256 for secure remote connections.
- Order **pg_hba.conf** rules to prioritize secure methods (e.g., SCRAM before MD5).
- Verify stored password format in **pg_authid**:
  ```sql
  SELECT rolname, rolpassword FROM pg_authid;
  ```
- Reload **pg_hba.conf** after changes: `SELECT pg_reload_conf();`.

**Example**:
```conf
# pg_hba.conf
local   all   postgres   peer
hostssl all   secure_user 10.0.0.0/16 scram-sha-256
host    all   legacy_user 192.168.1.0/24 md5
host    all   all   0.0.0.0/0   reject
```
```sql
-- Configure secure_user with SCRAM
SET password_encryption = 'scram-sha-256';
ALTER ROLE secure_user WITH PASSWORD 'strongpassword';
-- Configure legacy_user with MD5
SET password_encryption = 'md5';
ALTER ROLE legacy_user WITH PASSWORD 'oldsecret';
```

**Output**:
- **pg_authid**:
  | rolname      | rolpassword                          |
  |--------------|--------------------------------------|
  | secure_user  | SCRAM-SHA-256$4096:...               |
  | legacy_user  | md5...                               |

**Conclusion**:
This configuration supports secure SCRAM-SHA-256 for modern clients and MD5 for legacy systems, with **hostssl** ensuring encrypted connections for sensitive data.

### Security Considerations
Security is the primary differentiator between MD5 and SCRAM-SHA-256, impacting their use in OLTP and OLAP environments.

#### MD5 Security Risks
- **Vulnerable Hashes**: MD5 is broken; stored hashes in **pg_authid** can be brute-forced.
- **Replay Attacks**: Intercepted hashes can be reused if not encrypted (e.g., **hostnossl**).
- **No Mutual Authentication**: Clients cannot verify server identity, risking impersonation.
- **Mitigation**: Use **hostssl**, strong passwords, and restrict IP access in **pg_hba.conf**.

#### SCRAM-SHA-256 Security Benefits
- **Strong Cryptography**: SHA-256 and PBKDF2 resist brute-forcing, even if **pg_authid** is compromised.
- **Replay Protection**: Nonces ensure each authentication session is unique.
- **Mutual Authentication**: Clients verify server identity, preventing spoofing.
- **Mitigation**: Use **hostssl** to encrypt communication, as SCRAM only secures authentication.

**Key points**:
- SCRAM-SHA-256 is mandatory for compliance with standards like GDPR, HIPAA, or PCI-DSS.
- MD5 is acceptable only in trusted, legacy environments with **hostssl**.
- Monitor logs for failed authentication attempts to detect attacks.
- Use client certificates (**cert** authentication) for even stronger security.
- Regularly rotate passwords and audit **pg_hba.conf**.

### Performance Considerations
Authentication methods impact connection performance, particularly in high-concurrency OLTP systems.

**Key points**:
- **MD5**: Faster due to simple hashing, ideal for low-latency OLTP with many connections.
- **SCRAM-SHA-256**: Slower due to PBKDF2 iterations, but overhead is minimal (microseconds).
- **Connection Pooling**: Tools like PgBouncer reduce authentication overhead in OLTP.
- **SSL Overhead**: Both methods benefit from **hostssl**, but SSL handshakes add latency.
- **OLAP**: Performance impact is negligible, as connections are fewer and queries dominate.

**Example**:
```bash
# OLTP with PgBouncer for SCRAM-SHA-256
psql -U secure_user -h localhost -p 6432 -d mydb
```

**Output**:
- Connects via PgBouncer, minimizing SCRAM-SHA-256 overhead.

**Conclusion**:
MD5 offers slightly better performance for OLTP, but SCRAM-SHA-256’s security benefits outweigh minor latency costs, especially with connection pooling.

### Compatibility and Migration
Transitioning from MD5 to SCRAM-SHA-256 requires consideration of client support and database configuration.

#### Compatibility
- **MD5**: Supported by all PostgreSQL versions and clients, including legacy drivers.
- **SCRAM-SHA-256**: Supported in PostgreSQL 10+ and modern clients (e.g., psql 10+, JDBC 42.2.0+, libpq 10+).
- **Issues**: Older clients (e.g., JDBC < 42.2.0) may fail with SCRAM, requiring MD5 fallback or upgrades.

#### Migration Steps
1. **Check Client Compatibility**:
   - Verify client drivers support SCRAM-SHA-256 (e.g., `psql --version`, JDBC version).
2. **Set Password Encryption**:
   ```sql
   SET password_encryption = 'scram-sha-256';
   ```
3. **Update Passwords**:
   ```sql
   ALTER ROLE app_user WITH PASSWORD 'newpassword';
   ```
4. **Update pg_hba.conf**:
   ```conf
   hostssl all app_user 192.168.1.0/24 scram-sha-256
   ```
5. **Reload Configuration**:
   ```sql
   SELECT pg_reload_conf();
   ```
6. **Test Connections**:
   ```bash
   psql "host=dbserver user=app_user dbname=mydb sslmode=require"
   ```
7. **Remove MD5 Rules**: Once all clients are migrated, update **pg_hba.conf** to remove MD5.

**Key points**:
- Migration requires updating passwords and **pg_hba.conf** to use SCRAM-SHA-256.
- Maintain MD5 rules temporarily for legacy clients during transition.
- Test thoroughly in a staging environment to avoid connection failures.
- Update client drivers to ensure SCRAM support (e.g., JDBC 42.2.0+).
- Monitor logs for authentication errors during migration.

**Example**:
```sql
-- Migrate user to SCRAM-SHA-256
SET password_encryption = 'scram-sha-256';
ALTER ROLE app_user WITH PASSWORD 'securepassword';
```
```conf
# pg_hba.conf (transitional)
hostssl mydb app_user 192.168.1.0/24 scram-sha-256
hostssl mydb app_user 192.168.1.0/24 md5  # Fallback for legacy clients
```

**Output**:
- New clients use SCRAM-SHA-256; legacy clients fall back to MD5 until upgraded.

**Conclusion**:
Migration to SCRAM-SHA-256 enhances security but requires careful planning to ensure client compatibility and uninterrupted access.

### Monitoring and Troubleshooting
Monitoring authentication activity and resolving issues ensure secure and reliable connections.

#### Monitoring
- **Authentication Logs**:
  ```conf
  # postgresql.conf
  log_connections = on
  log_authentication = on
  ```
- **Failed Attempts**:
  ```sql
  SELECT * FROM pg_stat_activity WHERE state = 'authentication';
  ```
- **Stored Passwords**:
  ```sql
  SELECT rolname, rolpassword FROM pg_authid WHERE rolpassword IS NOT NULL;
  ```

#### Troubleshooting
- **Authentication Failures**: Check logs for errors (e.g., “password authentication failed”).
- **SCRAM Incompatibility**: Verify client version; fall back to MD5 if needed.
- **MD5 Security Alerts**: Audit weak passwords and enforce **hostssl**.
- **Connection Limits**: Monitor `max_connections` vs. active connections:
  ```sql
  SELECT count(*) FROM pg_stat_activity WHERE state != 'idle';
  ```
- **pg_hba.conf Errors**: Ensure rules match connection type and IP range.

**Key points**:
- Logs identify authentication issues (e.g., wrong method, invalid credentials).
- SCRAM failures often stem from outdated clients; MD5 failures from weak passwords.
- Connection pooling reduces authentication overhead in OLTP.
- Regular audits of **pg_authid** and **pg_hba.conf** detect misconfigurations.
- Use `pg_stat_activity` to monitor connection health.

**Example**:
```sql
-- Check authentication attempts
SELECT datname, usename, client_addr, state FROM pg_stat_activity WHERE state LIKE '%auth%';
```

**Output**:
| datname | usename    | client_addr   | state         |
|---------|------------|---------------|---------------|
| mydb    | app_user   | 192.168.1.101 | authentication |

**Conclusion**:
Monitoring reveals authentication issues, enabling quick resolution to maintain secure OLTP and OLAP access.

### Best Practices
Optimizing MD5 and SCRAM-SHA-256 usage ensures secure, efficient authentication.

**Key points**:
- Use **SCRAM-SHA-256** for all new PostgreSQL deployments and upgrades.
- Combine with **hostssl** to encrypt connections, especially for SCRAM-SHA-256.
- Maintain MD5 only for legacy clients during migration, phasing it out promptly.
- Enforce strong passwords (e.g., 12+ characters, mixed case) to enhance both methods.
- Restrict **pg_hba.conf** to trusted IPs (e.g., `10.0.0.0/16`) and specific databases/users.
- Implement connection pooling (e.g., PgBouncer) for high-concurrency OLTP.
- Regularly audit **pg_authid** and logs for weak passwords or unauthorized attempts.
- Test SCRAM-SHA-256 migration in staging to avoid client compatibility issues.

**Example**:
```conf
# Secure pg_hba.conf
local   all   postgres   peer
hostssl all   secure_user 10.0.0.0/16 scram-sha-256
host    all   all   0.0.0.0/0   reject
```
```sql
-- Ensure SCRAM-SHA-256 for all users
SET password_encryption = 'scram-sha-256';
ALTER ROLE secure_user WITH PASSWORD 'ComplexPass123!';
```

**Output**:
- Secure configuration applied, enforcing SCRAM-SHA-256 with **hostssl**.

**Conclusion**:
This setup prioritizes SCRAM-SHA-256 for secure, modern authentication, suitable for both OLTP and OLAP, while rejecting unauthorized access.

### Recommended Subtopics
- Configuring SSL/TLS for **hostssl** with SCRAM-SHA-256
- Optimizing PgBouncer for SCRAM-SHA-256 in OLTP
- Migrating from MD5 to SCRAM-SHA-256 in production
- Client certificate authentication (**cert**) as an alternative
- Auditing PostgreSQL authentication for regulatory compliance

---

