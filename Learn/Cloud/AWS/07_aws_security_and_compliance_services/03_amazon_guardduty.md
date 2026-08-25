## Amazon GuardDuty


GuardDuty provides threat detection using machine learning, anomaly detection, and threat intelligence to identify malicious activity in AWS accounts. It analyzes data from multiple sources without requiring additional security software or infrastructure.

**Data Sources and Analysis** GuardDuty analyzes VPC Flow Logs to detect network-based threats including reconnaissance, instance compromises, and data exfiltration. DNS logs identify communication with malicious domains and DNS tunneling attempts. CloudTrail events reveal suspicious API activity including credential compromise and privilege escalation. [Inference: GuardDuty likely uses proprietary machine learning models trained on AWS's threat intelligence data, though specific algorithms are not publicly documented.]

**Threat Detection Categories** GuardDuty detects various threat types including reconnaissance (port scanning, unusual API calls), instance compromise (malware, cryptocurrency mining, backdoor communication), account compromise (unusual login patterns, credential stuffing), and data exfiltration (suspicious data transfers, DNS tunneling). Findings include severity levels, threat descriptions, and recommended remediation actions.

**Integration and Response** GuardDuty integrates with Security Hub for centralized security findings management. EventBridge rules can trigger automated responses through Lambda functions, SNS notifications, or Security Orchestration and Automated Response (SOAR) platforms. Trusted IP lists and threat lists customize detection for organizational requirements.

