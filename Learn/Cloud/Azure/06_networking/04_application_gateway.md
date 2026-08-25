## Application Gateway


Application Gateway operates as a Layer 7 (application layer) load balancer and web application firewall, providing advanced traffic management capabilities for web applications. The service offers URL-based routing, SSL termination, cookie-based session affinity, and integrated web application firewall (WAF) protection.

URL path-based routing enables directing traffic to different backend pools based on request URLs, supporting microservices architectures and multi-tenant applications. SSL termination offloads certificate management and encryption processing from backend servers while maintaining end-to-end SSL encryption when required.

**Key Points:**

- URL-based routing for microservices and multi-tenant architectures
- SSL termination and end-to-end SSL encryption support
- Web Application Firewall (WAF) protection against OWASP top 10 vulnerabilities
- Cookie-based session affinity for stateful applications
- Integration with Azure Key Vault for certificate management

WAF capabilities include protection against common web vulnerabilities such as SQL injection, cross-site scripting (XSS), and other OWASP top 10 attacks. Custom WAF rules enable tailored protection based on application-specific requirements and threat intelligence.

**Example:** An e-commerce application uses Application Gateway to route /api/* requests to API servers, /images/* requests to content delivery networks, and default traffic to web servers, while WAF protection filters malicious requests.

Application Gateway v2 (Standard_v2 and WAF_v2 SKUs) provides enhanced performance, autoscaling capabilities, zone redundancy, and static VIP addresses. The service integrates with Azure Monitor for detailed application-level metrics and diagnostic logging.

