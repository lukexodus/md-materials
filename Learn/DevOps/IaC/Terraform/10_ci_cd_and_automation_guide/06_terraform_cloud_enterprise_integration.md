## Terraform Cloud/Enterprise Integration


### Workspace Configuration

```hcl
# terraform.tf
terraform {
  cloud {
    organization = "my-org"
    
    workspaces {
      name = "infrastructure-prod"
    }
  }
}
```

### Variable Sets

```json
{
  "data": {
    "type": "variable-sets",
    "attributes": {
      "name": "aws-credentials",
      "description": "AWS credentials for all workspaces",
      "global": true
    }
  }
}
```

### Policy as Code

```hcl
# sentinel/aws-security.sentinel
import "tfplan/v2" as tfplan

# Require encryption for S3 buckets
main = rule {
  all tfplan.resource_changes as _, changes {
    changes.type is "aws_s3_bucket" implies
      changes.change.after.server_side_encryption_configuration is not null
  }
}
```

### Run Triggers

```yaml
# tfc-integration.yml
- name: Trigger Terraform Cloud Run
  uses: hashicorp/tfc-workflows-github/actions/create-run@v1.0.0
  with:
    workspace: "infrastructure-prod"
    message: "Triggered by GitHub Actions"
```

