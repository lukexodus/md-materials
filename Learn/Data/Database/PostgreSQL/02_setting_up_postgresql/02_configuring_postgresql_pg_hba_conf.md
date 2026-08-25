## Configuring PostgreSQL: `pg_hba.conf`


`pg_hba.conf` (Host-Based Authentication) is a crucial PostgreSQL configuration file that controls how clients authenticate when connecting to the database. Proper configuration ensures security while allowing necessary access.

---

### **1. Location of `pg_hba.conf`**  
The file is typically located in the PostgreSQL data directory:

- **Linux (Default Installation):**  
  ```
  /etc/postgresql/<version>/main/pg_hba.conf
  ```
- **Linux (Source Installation):**  
  ```
  /usr/local/pgsql/data/pg_hba.conf
  ```
- **Windows:**  
  ```
  C:\Program Files\PostgreSQL\<version>\data\pg_hba.conf
  ```
- **Find Configuration File Path Dynamically:**  
  ```sql
  SHOW hba_file;
  ```

---

### **2. Structure of `pg_hba.conf`**  
Each line in `pg_hba.conf` follows this format:

```
<TYPE>  <DATABASE>  <USER>  <ADDRESS>  <METHOD>  [OPTIONS]
```

| **Field**  | **Description**                                                |
| ---------- | -------------------------------------------------------------- |
| `TYPE`     | Connection type (local, host, hostssl, hostnossl).             |
| `DATABASE` | Database(s) the rule applies to.                               |
| `USER`     | User(s) the rule applies to.                                   |
| `ADDRESS`  | IP address or range (only for remote connections).             |
| `METHOD`   | Authentication method (md5, scram-sha-256, trust, peer, etc.). |
| `OPTIONS`  | Additional options for authentication (e.g., `clientcert=1`).  |

---

### **3. Connection Types**  
| **Type** | **Description** |
|----------|---------------|
| `local`  | Unix domain socket connections (for local machine users). |
| `host`   | TCP/IP connections (IPv4 or IPv6). |
| `hostssl` | TCP/IP connections over SSL. |
| `hostnossl` | TCP/IP connections without SSL. |

#### **Example: Local UNIX Socket Authentication**  
```
local   all   all   peer
```
- Allows all users to connect via Unix sockets using **peer authentication**.

#### **Example: Remote Connection via IPv4**  
```
host   all   all   192.168.1.0/24   md5
```
- Allows connections from the `192.168.1.x` subnet with **MD5 password authentication**.

---

### **4. Authentication Methods**  
| **Method**      | **Description**                                              |
| --------------- | ------------------------------------------------------------ |
| `trust`         | No password required (insecure, use with caution).           |
| `reject`        | Explicitly denies access.                                    |
| `peer`          | Uses OS username matching (local connections only).          |
| `md5`           | Encrypted password authentication (recommended).             |
| `scram-sha-256` | Stronger password authentication (recommended for security). |
| `password`      | Plain-text password authentication (not recommended).        |
| `ident`         | Uses an external authentication service.                     |
| `cert`          | Uses SSL client certificates.                                |
| `pam`           | Uses system PAM (Pluggable Authentication Modules).          |
| `ldap`          | Authenticates via an LDAP server.                            |

#### **Example: MD5 Authentication (Most Common for Remote Users)**  
```
host   all   all   0.0.0.0/0   md5
```
- Requires users to provide an encrypted password.

#### **Example: Reject Connections from a Specific IP**  
```
host   all   all   192.168.1.100/32   reject
```
- Blocks connections from `192.168.1.100`.

#### **Example: SSL Certificate Authentication**  
```
hostssl   all   all   192.168.1.0/24   cert clientcert=1
```
- Requires clients to authenticate using SSL certificates.

---

### **5. Configuring Remote Connections**  
To allow remote connections, update both `pg_hba.conf` and `postgresql.conf`:

#### **Step 1: Enable Listening for Remote Connections**  
Edit `postgresql.conf` and set:  
```ini
listen_addresses = '*'
```
or restrict to specific IPs:  
```ini
listen_addresses = '192.168.1.10'
```

#### **Step 2: Allow Remote Access in `pg_hba.conf`**  
```
host   all   all   0.0.0.0/0   md5
```
- Allows access from any IP (use cautiously).  
- Restrict access by subnet or specific IPs for security:  
  ```
  host   all   all   192.168.1.0/24   md5
  ```

#### **Step 3: Restart PostgreSQL for Changes to Take Effect**  
```sh
sudo systemctl restart postgresql
```
or  
```sql
SELECT pg_reload_conf();
```

---

### **6. Example `pg_hba.conf` Configuration**  
```ini
# Local connections using peer authentication
local   all   all             peer

# Allow password authentication from the local network
host    all   all   192.168.1.0/24   md5

# Allow SSL certificate-based authentication from a specific IP
hostssl all   all   203.0.113.50/32   cert clientcert=1

# Reject all other remote connections
host    all   all   0.0.0.0/0   reject
```

---

### **7. Checking Active Authentication Rules**  
List all active rules in `pg_hba.conf` using:  
```sql
SELECT * FROM pg_hba_file_rules;
```

---

**Conclusion**  
`pg_hba.conf` is a crucial security file for PostgreSQL, controlling authentication and access. Properly configuring it ensures secure and efficient database access while preventing unauthorized connections.

---

