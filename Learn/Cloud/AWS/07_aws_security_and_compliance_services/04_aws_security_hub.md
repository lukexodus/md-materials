## AWS Security Hub


Security Hub provides centralized security posture management by aggregating findings from multiple AWS security services and third-party tools. It normalizes findings into a standard format and provides prioritization based on severity and context.

**Finding Aggregation and Normalization** Security Hub collects findings from GuardDuty, Config, Inspector, IAM Access Analyzer, and dozens of third-party security tools. The AWS Security Finding Format (ASFF) standardizes finding structure including severity, confidence, resource details, and remediation guidance. Custom insights create filtered views of findings based on specific criteria.

**Compliance Standards** Security Hub includes compliance standards for AWS Foundational Security Standard, CIS AWS Foundations Benchmark, PCI DSS, and AWS Config Conformance Packs. Each standard includes multiple controls mapped to specific Config rules or custom Lambda functions. Compliance scores show overall posture and track improvements over time.

**Workflow and Integration** Security Hub supports finding workflow states (new, notified, resolved, suppressed) for tracking remediation progress. Integration with ticketing systems enables automatic creation of remediation tasks. Master-member account relationships provide centralized security management across AWS Organizations.

