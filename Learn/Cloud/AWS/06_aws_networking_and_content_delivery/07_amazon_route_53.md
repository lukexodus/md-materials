## Amazon Route 53


Amazon Route 53 is a scalable DNS web service that translates domain names into IP addresses and routes internet traffic to appropriate resources. Route 53 provides domain registration, DNS routing, and health checking capabilities.

**Hosted Zones** contain DNS records for a domain and define how Route 53 responds to DNS queries. Public hosted zones respond to queries from the internet, while private hosted zones respond to queries from within specified VPCs.

**DNS Record Types** supported by Route 53 include:

- **A records**: Map domain names to IPv4 addresses
- **AAAA records**: Map domain names to IPv6 addresses
- **CNAME records**: Map domain names to other domain names
- **MX records**: Define mail servers for email delivery
- **TXT records**: Store text information for various purposes
- **SRV records**: Define services available in the domain

**Routing Policies** determine how Route 53 responds to DNS queries:

**Simple Routing** returns a single resource record with multiple values in random order.

**Weighted Routing** distributes traffic across multiple resources based on assigned weights, enabling gradual traffic shifting and A/B testing.

**Latency-Based Routing** routes traffic to the resource that provides the lowest network latency for the end user's location.

**Failover Routing** configures active-passive failover where traffic routes to a secondary resource if the primary resource becomes unhealthy.

**Geolocation Routing** routes traffic based on the geographic location of DNS queries, enabling content localization and compliance with data residency requirements.

**Geoproximity Routing** routes traffic based on geographic location with the ability to bias traffic toward or away from specific resources.

**Multivalue Answer Routing** returns multiple healthy resources in response to DNS queries, providing basic load distribution and fault tolerance.

**Health Checks** monitor the health and performance of web applications and other resources. Route 53 can check HTTP, HTTPS, or TCP endpoints, and automatically remove unhealthy resources from DNS responses. Health checks can also monitor CloudWatch alarms and other health checks for more complex monitoring scenarios.

