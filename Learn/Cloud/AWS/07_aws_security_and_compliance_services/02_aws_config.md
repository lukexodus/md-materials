## AWS Config


Config continuously monitors and records AWS resource configurations, evaluating them against desired security and compliance baselines. It provides configuration history and change tracking for auditing and troubleshooting purposes.

**Configuration Items and Rules** Configuration items represent point-in-time snapshots of resource configurations including metadata, attributes, and relationships. Config rules evaluate whether resources comply with desired configurations automatically or through custom Lambda functions. AWS provides pre-built rules for common compliance frameworks including CIS, PCI DSS, and HIPAA. Custom rules can implement organization-specific requirements using Lambda functions.

**Remediation and Automation** Config supports automatic remediation of non-compliant resources through Systems Manager Automation documents or Lambda functions. Remediation actions can include modifying security groups, enabling encryption, or deleting non-compliant resources. Manual remediation workflows provide approval processes for sensitive changes.

**Compliance Dashboard and Reporting** Config provides compliance dashboards showing resource compliance status across rules and accounts. Configuration timelines visualize resource changes over time with corresponding CloudTrail events. Conformance packs bundle multiple Config rules and remediation actions for specific compliance frameworks, enabling consistent application across accounts and regions.

