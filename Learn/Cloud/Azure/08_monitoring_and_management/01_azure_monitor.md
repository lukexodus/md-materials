## Azure Monitor


Azure Monitor serves as the central hub for collecting, analyzing, and acting on telemetry data from Azure resources, applications, and infrastructure components across cloud and on-premises environments.

**Key points:**

- Unified monitoring platform collecting metrics, logs, traces, and dependencies from all Azure resources
- Built-in monitoring for platform metrics and activity logs without additional configuration
- Custom metrics ingestion through REST APIs, Azure CLI, PowerShell, and client libraries
- Real-time and historical data analysis with configurable retention periods
- Alert rules with multiple signal types: metric alerts, log search alerts, activity log alerts, and smart detection alerts
- Action groups for notification and automated remediation through webhooks, logic apps, Azure functions
- Integration with Azure dashboards, workbooks, and third-party SIEM solutions
- Cost optimization through data sampling, retention policies, and workspace-based pricing models
- Cross-resource queries enabling correlation analysis across multiple services and subscriptions

**Example:** A financial services company monitors their multi-tier application using Azure Monitor, setting up composite alerts that trigger when both CPU utilization exceeds 80% and response time increases beyond 2 seconds, automatically scaling resources and notifying the operations team.

