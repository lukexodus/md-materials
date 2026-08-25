## Azure Policy and Blueprints


Azure Policy and Blueprints provide governance capabilities to ensure resource compliance with organizational standards and regulatory requirements through automated policy enforcement and standardized deployments.

**Key Points:**

- Declarative policy definitions using JSON-based rules
- Automatic compliance evaluation and remediation
- Initiative groupings for comprehensive governance frameworks
- Resource exemptions and exclusions for specific scenarios
- Built-in policies for common security and compliance requirements
- Custom policy development for organization-specific needs

**Policy Types:**

- **Audit Policies**: Compliance reporting without enforcement
- **Deny Policies**: Prevention of non-compliant resource creation
- **Append Policies**: Automatic addition of required properties
- **Modify Policies**: Resource property changes for compliance
- **DeployIfNotExists**: Automatic resource provisioning for compliance

**Built-in Policy Categories:**

- **Security**: Network security, encryption, access controls
- **Compute**: VM configurations, extensions, disk encryption
- **Storage**: Access controls, encryption, redundancy settings
- **Networking**: NSG rules, subnets, routing configurations
- **Monitoring**: Diagnostic settings, log collection requirements

**Azure Blueprints:**

- **Artifacts**: Resource Manager templates, policies, role assignments
- **Blueprint Definitions**: Reusable governance frameworks
- **Blueprint Assignments**: Scoped deployment to management groups
- **Versioning**: Blueprint lifecycle management and updates
- **Lock Assignments**: Resource protection against modifications

**Example** policy definition for required tags:

```json
{
  "mode": "Indexed",
  "policyRule": {
    "if": {
      "field": "tags['Environment']",
      "exists": "false"
    },
    "then": {
      "effect": "deny"
    }
  }
}
```

