## AWS Global Infrastructure


AWS operates the world's most extensive and reliable cloud infrastructure, designed to provide high availability, fault tolerance, and scalability across multiple geographic locations worldwide.

### Regions

AWS Regions are separate geographic areas that AWS uses to house its infrastructure. Each region consists of multiple isolated locations known as Availability Zones. As of 2024, AWS operates in over 30 regions globally, with more planned for expansion. Regions are completely independent of each other, providing the highest level of fault tolerance and stability.

Each region is designed to be completely isolated from other regions to achieve the greatest possible fault tolerance and stability. Most AWS services are region-specific, meaning data stored in one region doesn't automatically replicate to other regions unless explicitly configured. This design helps organizations meet data residency requirements and compliance standards.

Regions are selected based on several factors including latency requirements, regulatory compliance, service availability, and cost considerations. Some AWS services are available in all regions, while others may be limited to specific regions based on local regulations or technical requirements.

### Availability Zones

Availability Zones are discrete data centers with redundant power, networking, and connectivity, housed in separate facilities within each region. Each region contains multiple Availability Zones, typically three or more, though some regions may have more. These zones are positioned tens of miles apart from each other, providing protection against localized disasters while maintaining low-latency connectivity.

Availability Zones are connected through high-bandwidth, low-latency networking, enabling synchronous replication between zones. This design allows applications to achieve higher availability by distributing resources across multiple zones within a region. If one zone experiences issues, applications can continue operating from other zones.

Each Availability Zone has independent power, cooling, and networking infrastructure to minimize the risk of simultaneous failures. AWS designs zones to be isolated from failures in other zones, providing inexpensive, low-latency network connectivity to other zones in the same region.

### Edge Locations

AWS Edge Locations are sites deployed in major cities and highly populated areas across the globe. These locations are separate from regions and Availability Zones, serving as endpoints for AWS services that require lower latency or improved performance for end users.

Edge locations primarily support Amazon CloudFront, AWS's content delivery network service, by caching copies of content closer to users. They also support other services like AWS Global Accelerator, Amazon Route 53, and AWS Shield. There are significantly more edge locations than regions—over 400 points of presence across more than 90 cities in over 47 countries.

These locations enable AWS to deliver content, APIs, and services with the lowest possible latency by serving requests from the location closest to the end user. Edge locations automatically route traffic to the optimal location based on network conditions and proximity.

