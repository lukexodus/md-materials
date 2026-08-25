## Address Resolution Protocol (ARP)


ARP resolves IP addresses to MAC addresses within local network segments. ARP requests broadcast queries seeking hardware addresses for specific IP addresses. Target systems respond with ARP replies containing their MAC addresses.

ARP tables cache address mappings to reduce network traffic and improve performance. Static entries provide permanent mappings, while dynamic entries expire after predetermined timeouts. Proxy ARP enables routers to respond for remote network addresses.

Gratuitous ARP announces address assignments and detects duplicate addresses. Systems broadcast their own IP-to-MAC mappings during startup or address changes, updating other systems' ARP tables.

**Key Points:**

- Local network address resolution bridges Layer 2 and Layer 3
- Caching reduces repetitive broadcast traffic
- Proxy ARP extends resolution across network boundaries
- Gratuitous ARP provides duplicate address detection

