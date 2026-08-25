## Amazon CloudFront


Amazon CloudFront is a global content delivery network (CDN) service that accelerates delivery of websites, APIs, video content, and other web assets. CloudFront uses a global network of edge locations and regional edge caches to cache content closer to end users.

**Edge Locations** are CloudFront's globally distributed data centers that cache copies of content. When users request content, CloudFront routes the request to the edge location with the lowest latency. If the content is cached at the edge location, it's delivered immediately. If not, CloudFront retrieves it from the origin server.

**Origins** can be Amazon S3 buckets, EC2 instances, Elastic Load Balancers, or custom HTTP servers. Multiple origins can be configured for a single distribution, with different behaviors based on URL patterns.

**Distributions** are CloudFront's configuration entities that specify origins, caching behaviors, and delivery settings. Web distributions are used for general web content, while RTMP distributions handle Adobe Flash Media Server's protocol for streaming media.

**Caching Behaviors** define how CloudFront processes requests for different URL patterns. Each behavior specifies cache duration (TTL), allowed HTTP methods, query string forwarding, and header forwarding settings. Multiple behaviors can be configured with different origins and settings based on URL path patterns.

**Cache Invalidation** allows immediate removal of cached content from edge locations, though it incurs additional charges. CloudFront also supports versioned URLs and cache headers to control content freshness without invalidation costs.

Security features include AWS Web Application Firewall (WAF) integration, field-level encryption, and origin access identity (OAI) for secure S3 access. CloudFront supports SSL/TLS certificates for secure content delivery, including custom certificates through AWS Certificate Manager.

