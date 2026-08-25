## Amazon Inspector


Inspector provides automated security assessment of applications for vulnerabilities and deviations from security best practices. It supports both EC2 instances and container images with agent-based and agentless scanning capabilities.

**Assessment Types** Inspector performs network reachability assessments to identify ports accessible from outside the VPC and potential attack paths. Host assessments analyze EC2 instances for software vulnerabilities, unintended network exposure, and security configuration issues. Container image assessments scan images in Amazon ECR for known vulnerabilities and malware.

**Vulnerability Database and Scoring** Inspector uses multiple vulnerability databases including CVE, RHSA, and ALAS to identify known security issues. Common Vulnerability Scoring System (CVSS) provides standardized severity ratings. Inspector provides contextual prioritization considering factors like network exposure, exploit availability, and business criticality.

**Integration and Reporting** Inspector integrates with Security Hub for centralized vulnerability management and with Systems Manager for automated patching workflows. Assessment results include detailed findings with remediation guidance and affected package information. API integration enables custom reporting and workflow automation.

