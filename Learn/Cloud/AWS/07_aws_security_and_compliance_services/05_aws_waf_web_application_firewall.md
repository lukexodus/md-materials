## AWS WAF (Web Application Firewall)


WAF protects web applications from common attacks by filtering HTTP/HTTPS requests based on configurable rules. It integrates with CloudFront, Application Load Balancer, API Gateway, and AWS AppSync to provide edge and application-layer protection.

**Rules and Rule Groups** WAF rules define conditions for allowing, blocking, or counting requests based on IP addresses, HTTP headers, body content, URI strings, and geographic location. Managed rule groups from AWS and third-party providers include pre-configured protection against OWASP Top 10 vulnerabilities, bot traffic, and application-specific threats. Custom rules address organization-specific attack patterns and compliance requirements.

**Rate-Based Rules and Bot Control** Rate-based rules protect against DDoS attacks and brute force attempts by tracking request rates from individual IP addresses. AWS WAF Bot Control provides sophisticated bot detection using machine learning and behavioral analysis to distinguish between legitimate and malicious bot traffic. Bot categories include search engine crawlers, social media bots, and malicious scrapers.

**Web ACLs and Monitoring** Web Access Control Lists (ACLs) combine multiple rules with defined precedence and default actions. Rules can operate in count mode for testing before enforcement. CloudWatch metrics track blocked requests, allowed requests, and rule matches. Sampled web requests provide detailed inspection of traffic patterns and rule effectiveness.

