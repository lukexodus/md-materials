## 3. Policy as Code with Sentinel


### Sentinel Policy Framework

#### Basic Policy Structure

```sentinel
# Policy: enforce-mandatory-tags.sentinel
import "tfplan-functions" as plan
import "strings"
import "types"

# Required tags for all resources
mandatory_tags = ["Environment", "Owner", "Project", "CostCenter"]

# Get all resource instances
allResourceInstances = plan.find_resources_from_plan()

# Function to validate tags
validate_tags = func(resource_instances) {
    validated = true
    for resource_instances as address, r {
        # Skip if resource doesn't support tags
        if "tags" not in keys(r.applied) {
            continue
        }
        
        current_tags = keys(r.applied.tags else {})
        missing_tags = []
        
        for mandatory_tags as tag {
            if tag not in current_tags {
                append(missing_tags, tag)
            }
        }
        
        if length(missing_tags) > 0 {
            print("Resource", address, "is missing mandatory tags:", missing_tags)
            validated = false
        }
    }
    return validated
}

# Main rule
main = rule {
    validate_tags(allResourceInstances)
}
```

#### Cost Control Policies

```sentinel
# Policy: limit-ec2-instance-types.sentinel
import "tfplan-functions" as plan

# Allowed instance types by environment
allowed_instance_types = {
    "development": ["t3.micro", "t3.small", "t3.medium"],
    "staging": ["t3.small", "t3.medium", "t3.large"],
    "production": ["t3.medium", "t3.large", "t3.xlarge", "m5.large", "m5.xlarge"]
}

# Get environment from workspace name or variables
get_environment = func() {
    if "environment" in keys(tfplan.variables) {
        return tfplan.variables.environment.value
    }
    
    # Fallback to workspace name parsing
    workspace_name = strings.split(tfplan.terraform_version, "-")
    if length(workspace_name) > 1 {
        return workspace_name[1]
    }
    
    return "development"
}

# Validate EC2 instance types
validate_instance_types = func() {
    environment = get_environment()
    allowed_types = allowed_instance_types[environment] else ["t3.micro"]
    
    ec2_instances = plan.find_resources("aws_instance")
    
    for ec2_instances as address, r {
        instance_type = r.applied.instance_type
        if instance_type not in allowed_types {
            print("Instance", address, "uses", instance_type, 
                  "which is not allowed in", environment, "environment")
            return false
        }
    }
    return true
}

main = rule {
    validate_instance_types()
}
```

#### Security Compliance Policies

```sentinel
# Policy: require-encryption.sentinel
import "tfplan-functions" as plan

# Resources that must be encrypted
encryption_required_resources = [
    "aws_s3_bucket",
    "aws_db_instance", 
    "aws_rds_cluster",
    "aws_ebs_volume"
]

# Validate encryption settings
validate_encryption = func() {
    violations = []
    
    # Check S3 buckets
    s3_buckets = plan.find_resources("aws_s3_bucket")
    for s3_buckets as address, r {
        if "server_side_encryption_configuration" not in keys(r.applied) {
            append(violations, address + " missing encryption configuration")
        }
    }
    
    # Check RDS instances
    rds_instances = plan.find_resources("aws_db_instance")
    for rds_instances as address, r {
        if r.applied.storage_encrypted is not true {
            append(violations, address + " storage not encrypted")
        }
    }
    
    # Check EBS volumes
    ebs_volumes = plan.find_resources("aws_ebs_volume")
    for ebs_volumes as address, r {
        if r.applied.encrypted is not true {
            append(violations, address + " not encrypted")
        }
    }
    
    if length(violations) > 0 {
        print("Encryption violations found:")
        for violations as violation {
            print("-", violation)
        }
        return false
    }
    
    return true
}

main = rule {
    validate_encryption()
}
```

### Policy Set Management

```hcl
# Policy set configuration
resource "tfe_policy_set" "security_policies" {
  name         = "security-baseline"
  description  = "Security baseline policies for all workspaces"
  organization = var.tfe_organization
  kind         = "sentinel"
  
  # Policy enforcement level
  policies_path = "policies/"
  
  # VCS integration
  vcs_repo {
    identifier     = "company/terraform-policies"
    branch         = "main"
    oauth_token_id = var.vcs_oauth_token
  }
  
  # Apply to workspace sets
  workspace_ids = []
}

# Attach policy set to workspace set
resource "tfe_policy_set_workspace_set" "security_to_production" {
  policy_set_id     = tfe_policy_set.security_policies.id
  workspace_set_id  = tfe_workspace_set.production_workspaces.id
}
```

