## 5. Governance and Compliance at Scale


### Organizational Policies

#### Azure Policy Integration

```hcl
# Custom policy definition
resource "azurerm_policy_definition" "require_tags" {
  name         = "require-mandatory-tags"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Require mandatory tags"
  description  = "Require specific tags on all resources"
  
  metadata = jsonencode({
    category = "Tags"
  })
  
  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Resources/subscriptions/resourceGroups"
        },
        {
          anyOf = [
            {
              field  = "tags['Environment']"
              exists = "false"
            },
            {
              field  = "tags['Owner']"
              exists = "false"
            }
          ]
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
  
  parameters = jsonencode({
    requiredTags = {
      type = "Array"
      metadata = {
        displayName = "Required tag names"
        description = "List of required tag names"
      }
      defaultValue = ["Environment", "Owner", "Project"]
    }
  })
}

# Policy assignment
resource "azurerm_management_group_policy_assignment" "require_tags" {
  name                 = "require-tags-assignment"
  policy_definition_id = azurerm_policy_definition.require_tags.id
  management_group_id  = azurerm_management_group.corp.id
  
  parameters = jsonencode({
    requiredTags = {
      value = ["Environment", "Owner", "Project", "CostCenter"]
    }
  })
}
```

#### Google Cloud Organization Policies

```hcl
# Restrict VM external IP
resource "google_organization_policy" "vm_external_ip_access" {
  org_id     = var.organization_id
  constraint = "compute.vmExternalIpAccess"
  
  list_policy {
    deny {
      all = true
    }
  }
}

# Allowed machine types
resource "google_organization_policy" "vm_instance_types" {
  org_id     = var.organization_id
  constraint = "compute.vmInstanceTypes"
  
  list_policy {
    allow {
      values = [
        "projects/*/zones/*/machineTypes/n1-standard-1",
        "projects/*/zones/*/machineTypes/n1-standard-2",
        "projects/*/zones/*/machineTypes/n1-standard-4"
      ]
    }
  }
}
```

### Compliance Frameworks

#### SOC 2 Compliance Implementation

```hcl
# SOC 2 compliance module
module "soc2_compliance" {
  source = "./modules/soc2-compliance"
  
  # Security controls
  enable_cloudtrail        = true
  enable_config            = true
  enable_guardduty         = true
  enable_security_hub      = true
  
  # Access controls
  enable_mfa_enforcement   = true
  enable_password_policy   = true
  enable_access_logging    = true
  
  # Monitoring and alerting
  enable_cloudwatch_alarms = true
  notification_endpoints   = [var.security_notification_email]
  
  # Data protection
  enable_encryption_at_rest = true
  enable_encryption_in_transit = true
  enable_backup_encryption  = true
  
  # Change management
  require_approval_for_changes = true
  enable_change_logging        = true
  
  tags = {
    Compliance = "SOC2"
    Framework  = "SOC2-Type2"
  }
}
```

#### GDPR Compliance Controls

```hcl
# GDPR compliance implementation
module "gdpr_compliance" {
  source = "./modules/gdpr-compliance"
  
  # Data protection
  enable_data_encryption     = true
  enable_data_classification = true
  enable_data_retention      = true
  
  # Access controls
  enable_rbac               = true
  enable_audit_logging      = true
  enable_access_reviews     = true
  
  # Data subject rights
  enable_data_portability   = true
  enable_right_to_erasure   = true
  enable_data_breach_notification = true
  
  # Privacy by design
  enable_privacy_impact_assessment = true
  enable_data_minimization        = true
  
  # Data processing agreements
  dpa_requirements = {
    lawful_basis = "legitimate_interest"
    data_categories = ["personal_data", "special_categories"]
    processing_purposes = ["service_delivery", "analytics"]
  }
  
  tags = {
    Compliance = "GDPR"
    DataClassification = "PersonalData"
  }
}
```

