## Non-Standard Port Usage


Non-standard ports are any ports differing from the scheme's default. They require explicit specification in URIs and have various implications for deployment and accessibility.

### Common Non-Standard Port Patterns

**Development Environments:**

```
http://localhost:3000         (React/Node.js development server)
http://localhost:4200         (Angular development server)
http://localhost:8000         (Python HTTP server)
http://localhost:8080         (Common alternative HTTP port)
http://localhost:5000         (Flask default)
```

**Alternative HTTP/HTTPS Ports:**

```
http://example.com:8080       (HTTP alternate)
http://example.com:8000       (HTTP alternate)
http://example.com:8888       (HTTP alternate)
https://example.com:8443      (HTTPS alternate)
https://example.com:9443      (HTTPS alternate)
```

**Proxy and Control Ports:**

```
http://proxy.example.com:3128 (Squid proxy)
http://proxy.example.com:8118 (Privoxy)
http://example.com:8001       (Kubernetes API proxy)
```

**Application-Specific Ports:**

```
http://jenkins.example.com:8080     (Jenkins CI/CD)
http://tomcat.example.com:8080      (Apache Tomcat)
http://grafana.example.com:3000     (Grafana monitoring)
http://prometheus.example.com:9090  (Prometheus)
```

### Port Selection Considerations

**Avoiding Privileged Ports:**

Ports 0-1023 require root/administrator privileges to bind on Unix-like systems:

```
Port 80:   Requires root privileges
Port 8080: Available to non-privileged users
```

Applications often use ports above 1024 to avoid requiring elevated permissions during development or deployment.

**Firewall and Network Compatibility:**

Many networks restrict outbound connections to standard ports:

```
Commonly Allowed:
    80 (HTTP)
    443 (HTTPS)
    22 (SSH, sometimes restricted)

Often Blocked:
    8080, 8000, 3000, etc.
```

Corporate firewalls, public Wi-Fi networks, and mobile carriers may block non-standard ports, limiting accessibility.

**Load Balancer and Reverse Proxy Patterns:**

```
External Access:
    https://example.com:443 → Load Balancer

Internal Routing:
    Load Balancer → http://backend1:8080
                 → http://backend2:8080
                 → http://backend3:8080
```

Public-facing services use standard ports while internal services use non-standard ports, with reverse proxies handling translation.

### Multiple Services on Single Host

Non-standard ports enable multiple services on one host/IP address:

```
http://server.example.com:8080    (Application A)
http://server.example.com:8081    (Application B)
http://server.example.com:8082    (Application C)
https://server.example.com:443    (Main website)
https://server.example.com:8443   (Admin panel)
```

This approach is common in development environments, container deployments, and resource-constrained scenarios.

### DNS SRV Records and Service Discovery

SRV records in DNS can specify non-standard ports for services:

```
_service._proto.example.com. IN SRV priority weight port target
_http._tcp.example.com.      IN SRV 10 60 8080 server1.example.com.
_http._tcp.example.com.      IN SRV 10 40 8080 server2.example.com.
```

[Inference] This enables service discovery where clients query DNS to determine the appropriate port, but HTTP/HTTPS clients typically do not use SRV records without explicit application support.

### Virtual Host Limitations

HTTP virtual hosting (multiple domains on one IP) relies on the Host header:

```
Same Port, Different Domains:
    http://site1.example.com:8080 → Virtual host: site1.example.com
    http://site2.example.com:8080 → Virtual host: site2.example.com

Different Ports, Same Domain:
    http://example.com:8080 → Service A
    http://example.com:8081 → Service B
```

Virtual hosting works across different ports, but each port requires separate listener configuration on the server.

