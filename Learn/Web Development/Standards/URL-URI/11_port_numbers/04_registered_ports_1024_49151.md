## Registered Ports (1024-49151)


### Definition and Characteristics

Registered ports are port numbers from 1024 to 49151, registered with IANA for specific services but not requiring special privileges to bind.

**Key characteristics:**

**User-accessible:** Any user can bind to these ports (no root/admin required on most systems).

**Semi-standardized:** IANA maintains registry, but enforcement is voluntary.

**Application services:** Typically used by user applications and services.

**Flexibility:** Can be used for custom services while having standard options available.

### IANA Registration Process

**Purpose of registration:**

- Avoid port conflicts between applications
- Establish conventions for common services
- Provide discovery mechanism for services

**Note:** [Unverified] Specific current IANA registration procedures and requirements.

**Registration does not guarantee:**

- Exclusive use (multiple applications may use same port)
- Universal adoption
- Conflict-free operation

### Major Registered Ports

**Port 1080 - SOCKS:**

```
Protocol: SOCKS (Socket Secure)
Usage: Proxy protocol for routing network packets
Example: socks5://proxy.example.com:1080/
Versions: SOCKS4, SOCKS5
```

**Port 1194 - OpenVPN:**

```
Protocol: OpenVPN
Usage: VPN connections
Transport: UDP (default), TCP
Example: openvpn://vpn.example.com:1194/
```

**Port 1433 - Microsoft SQL Server:**

```
Protocol: MS-SQL-S
Usage: Microsoft SQL Server database
Example: mssql://server.example.com:1433/
```

**Port 1521 - Oracle Database:**

```
Protocol: Oracle SQL*Net
Usage: Oracle database connections
Example: oracle://db.example.com:1521/
```

**Port 1723 - PPTP:**

```
Protocol: PPTP (Point-to-Point Tunneling Protocol)
Usage: VPN connections (legacy, less secure)
```

**Port 2049 - NFS:**

```
Protocol: NFS (Network File System)
Usage: Distributed file system
Example: nfs://fileserver.example.com:2049/export
```

**Port 2181 - Apache ZooKeeper:**

```
Protocol: ZooKeeper
Usage: Distributed coordination service
Example: Used by Kafka, Hadoop
```

**Port 2375/2376 - Docker:**

```
Port 2375: Docker daemon (unencrypted)
Port 2376: Docker daemon (TLS encrypted)
Usage: Docker API
Security: Port 2375 should never be exposed publicly
```

**Port 3000 - Development servers:**

```
Common usage: Default port for many development frameworks
Examples:
- Node.js applications (Express, Next.js default)
- Ruby on Rails development server
- Various frontend dev servers
```

**Port 3306 - MySQL:**

```
Protocol: MySQL
Usage: MySQL/MariaDB database
Example: mysql://localhost:3306/database
```

**Port 3389 - RDP:**

```
Protocol: RDP (Remote Desktop Protocol)
Usage: Windows remote desktop
Security: Frequently targeted by attacks
Alternative: Use VPN or SSH tunnel
```

**Port 4000-4999 - Various services:**

```
Port 4443: Common alternative HTTPS port
Port 4567: Sinatra (Ruby framework) default
Port 5000: Flask (Python framework) default, UPnP
```

**Port 5432 - PostgreSQL:**

```
Protocol: PostgreSQL
Usage: PostgreSQL database
Example: postgresql://localhost:5432/mydb
Connection string: postgres://user:pass@host:5432/db
```

**Port 5601 - Kibana:**

```
Protocol: Kibana web interface
Usage: Elasticsearch data visualization
Example: http://localhost:5601/
```

**Port 5672 - AMQP:**

```
Protocol: AMQP (Advanced Message Queuing Protocol)
Usage: Message broker (RabbitMQ default)
Management UI: Port 15672
```

**Port 5900-5999 - VNC:**

```
Protocol: VNC (Virtual Network Computing)
Usage: Remote desktop access
Port calculation: 5900 + display number
Example: Display :0 → port 5900, Display :1 → port 5901
```

**Port 6379 - Redis:**

```
Protocol: Redis
Usage: In-memory data store
Example: redis://localhost:6379/
Security: Should not be exposed publicly without authentication
```

**Port 6667 - IRC:**

```
Protocol: IRC (Internet Relay Chat)
Usage: Chat protocol (unencrypted)
Alternative: Port 6697 (SSL/TLS)
```

**Port 7000-7001 - Cassandra:**

```
Port 7000: Inter-node communication
Port 7001: TLS inter-node communication
Protocol: Apache Cassandra
```

**Port 8000 - Alternative HTTP:**

```
Common usage: Development servers, testing
Examples:
- Python SimpleHTTPServer default
- Django development server
- Alternative web servers
```

**Port 8008 - Alternative HTTP:**

```
Usage: HTTP alternate (often used for APIs)
Example: Internal services, development
```

**Port 8080 - HTTP Proxy/Alternative:**

```
Common usage: Most common HTTP alternative port
Uses:
- Development servers
- Proxy servers
- Application servers (Tomcat default)
- Testing environments
Example: http://localhost:8080/
```

**Port 8081-8089 - HTTP Alternatives:**

```
Usage: Additional HTTP ports for multiple services
Common in: Microservices architectures
```

**Port 8181 - Alternative HTTP:**

```
Usage: Common alternative for web services
Example: GlassFish admin console default
```

**Port 8443 - Alternative HTTPS:**

```
Common usage: Most common HTTPS alternative port
Uses:
- Development HTTPS servers
- Application servers
- Testing SSL/TLS
Example: https://localhost:8443/
```

**Port 8888 - Alternative HTTP:**

```
Common usage: Jupyter Notebook default, proxy servers
Example: http://localhost:8888/
```

**Port 9000 - Various services:**

```
Common usage:
- PHP-FPM default
- SonarQube default
- Alternative web servers
```

**Port 9090 - Prometheus:**

```
Protocol: Prometheus metrics
Usage: Monitoring and alerting
Example: http://localhost:9090/
```

**Port 9200 - Elasticsearch:**

```
Protocol: Elasticsearch HTTP API
Usage: Search and analytics engine
Example: http://localhost:9200/
```

**Port 9300 - Elasticsearch transport:**

```
Protocol: Elasticsearch transport
Usage: Node-to-node communication
```

**Port 9999 - Various applications:**

```
Usage: Commonly used as placeholder/testing port
```

**Port 11211 - Memcached:**

```
Protocol: Memcached
Usage: Distributed memory caching
Security: Should not be exposed publicly
```

**Port 15672 - RabbitMQ Management:**

```
Protocol: RabbitMQ HTTP API
Usage: Management interface
Example: http://localhost:15672/
```

**Port 27017 - MongoDB:**

```
Protocol: MongoDB
Usage: MongoDB database
Example: mongodb://localhost:27017/
Security: Should require authentication
```

**Port 27018 - MongoDB sharded:**

```
Usage: MongoDB sharded cluster
```

**Port 28017 - MongoDB HTTP status:**

```
Usage: MongoDB HTTP status interface (legacy)
```

### Development and Testing Ports

**Common conventions in development:**

**3000-3999 range:** Commonly used by JavaScript frameworks and Node.js applications:

```
3000: Express.js, React, Next.js defaults
3001: Common alternative for second dev server
3030: Alternative Node.js apps
```

**4000-4999 range:** Various development frameworks:

```
4000: Common alternative HTTP port
4200: Angular development server default
4567: Sinatra (Ruby) default
```

**5000-5999 range:** Python frameworks and various services:

```
5000: Flask default
5173: Vite default
5432: PostgreSQL (also used in development)
```

**8000-8999 range:** Most popular range for development HTTP servers:

```
8000: Django, Python SimpleHTTPServer
8080: Most common HTTP alternative
8443: HTTPS alternative
8888: Jupyter Notebook
```

### Port Selection Best Practices

**[Inference] Guidelines for choosing ports:**

**Check IANA registry:** Verify port isn't already registered for conflicting service.

**Avoid well-known ports:** Don't use 0-1023 unless necessary and you have privileges.

**Use common alternatives for common protocols:**

- 8080, 8000 for HTTP
- 8443 for HTTPS
- 3000-3999 for Node.js applications

**Document port usage:** Clearly document which ports your application uses.

**Make ports configurable:** Allow users to change ports via configuration.

**Check for conflicts:** Verify port isn't already in use on the system:

```bash
# Linux/macOS
lsof -i :8080
netstat -an | grep 8080

# Windows
netstat -an | findstr 8080
```

**Consider firewall implications:** Some ports may be blocked by corporate firewalls.

**Use environment variables:** Allow runtime port configuration:

```javascript
const PORT = process.env.PORT || 3000;
```

### Port Ranges for Specific Purposes

**Microservices architecture:** Common pattern is to assign consecutive ports:

```
Service A: 8080
Service B: 8081 
Service C: 8082 
Admin API: 8090
```

**Database services:**
```
PostgreSQL: 5432 
MySQL: 3306 
MongoDB: 27017 
Redis: 6379 
Cassandra: 9042
```

**Message queues:**
```
RabbitMQ: 5672 (AMQP), 15672 (Management) 
Kafka: 9092 
ActiveMQ: 61616
```

**Monitoring and metrics:**
```
Prometheus: 9090 
Grafana: 3000 
Elasticsearch: 9200 
Kibana: 5601
```

### Security Considerations for Registered Ports

**No privilege protection:**
Any user can bind to these ports, increasing potential for:
- Port conflicts
- Malicious services impersonating legitimate ones
- Unauthorized service exposure

**[Inference] Common security issues:**

**Exposed databases:**
```
3306 (MySQL), 5432 (PostgreSQL), 27017 (MongoDB) // Should never be exposed to public internet without authentication
```

**Development servers in production:**
```
Port 3000, 8000 (common dev servers) // Development servers lack production security features
```

**Management interfaces:**
```
Port 2375 (Docker), 15672 (RabbitMQ Management) // Should be firewalled or require strong authentication
````

**[Inference] Security best practices:**

**Firewall configuration:**
```bash
# Example: Allow only specific ports (Linux iptables)
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -j DROP  # Deny all other ports
````

**Bind to localhost only for internal services:**

```javascript
// Node.js example
server.listen(3000, '127.0.0.1', () => {
  console.log('Server listening on localhost:3000');
});
```

**Use authentication:**

```
// MongoDB with authentication
mongodb://user:password@localhost:27017/mydb

// Redis with authentication
redis://password@localhost:6379/
```

**Use reverse proxies:**

```
External: Port 443 (HTTPS)
    ↓
Reverse Proxy (Nginx/Apache)
    ↓
Internal: Port 3000, 8080, etc.
```

### Port Scanning and Discovery

**Service discovery mechanisms:**

**Port scanning tools:**

```bash
# Nmap scan of registered ports
nmap -p 1024-49151 target.example.com

# Scan specific services
nmap -p 3306,5432,27017 target.example.com
```

**Service fingerprinting:** Many services respond with identifying information on connection:

```bash
# Banner grabbing example
nc localhost 27017
# May reveal: MongoDB version information
```

**[Inference] Protection against scanning:**

- Implement rate limiting
- Use intrusion detection systems (IDS)
- Configure fail2ban or similar tools
- Monitor logs for scanning patterns
- Use port knocking for sensitive services

