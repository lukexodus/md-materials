## 2. Terraform Enterprise Features


### Workspace Management

#### Workspace Configuration

```hcl
# Terraform Cloud/Enterprise workspace
resource "tfe_workspace" "app_production" {
  name         = "app-production"
  organization = var.tfe_organization
  
  # VCS integration
  vcs_repo {
    identifier     = "company/infrastructure"
    branch         = "main"
    oauth_token_id = var.vcs_oauth_token
  }
  
  # Execution mode
  execution_mode = "remote"
  
  # Terraform version constraint
  terraform_version = "~> 1.5.0"
  
  # Working directory
  working_directory = "environments/production"
  
  # Auto-apply
  auto_apply = false
  
  # Queue all runs
  queue_all_runs = false
  
  # Speculative plans
  speculative_enabled = true
  
  # Structured run output
  structured_run_output_enabled = true
  
  # Tags
  tag_names = ["production", "critical", "app"]
}

# Workspace variables
resource "tfe_variable" "aws_region" {
  key          = "aws_region"
  value        = "us-east-1"
  category     = "terraform"
  workspace_id = tfe_workspace.app_production.id
  description  = "AWS region for resources"
}

resource "tfe_variable" "aws_access_key" {
  key          = "AWS_ACCESS_KEY_ID"
  value        = var.aws_access_key_id
  category     = "env"
  workspace_id = tfe_workspace.app_production.id
  sensitive    = true
}
```

#### Workspace Sets and Organization-Level Policies

```hcl
# Workspace set for environment grouping
resource "tfe_workspace_set" "production_workspaces" {
  name         = "production-workspaces"
  description  = "All production workspaces"
  organization = var.tfe_organization
  global       = false
}

# Add workspaces to set
resource "tfe_workspace_set_workspace" "prod_members" {
  for_each = toset([
    tfe_workspace.app_production.id,
    tfe_workspace.database_production.id,
    tfe_workspace.network_production.id
  ])
  
  workspace_set_id = tfe_workspace_set.production_workspaces.id
  workspace_id     = each.value
}

# Variable set for common variables
resource "tfe_variable_set" "aws_credentials" {
  name         = "AWS Credentials"
  description  = "AWS access credentials"
  organization = var.tfe_organization
  global       = false
}

resource "tfe_workspace_set_variable_set" "aws_creds_assignment" {
  variable_set_id   = tfe_variable_set.aws_credentials.id
  workspace_set_id  = tfe_workspace_set.production_workspaces.id
}
```

### Private Module Registry

#### Module Publishing

```hcl
# Module registry configuration
resource "tfe_registry_module" "vpc_module" {
  organization = var.tfe_organization
  
  vcs_repo {
    display_identifier = "company/terraform-aws-vpc"
    identifier         = "company/terraform-aws-vpc"
    oauth_token_id     = var.vcs_oauth_token
  }
}

# Module versioning and publishing
resource "tfe_registry_module_version" "vpc_v2" {
  organization = var.tfe_organization
  namespace    = var.tfe_organization
  name         = "vpc"
  provider     = "aws"
  version      = "2.0.0"
  
  # Optional: specify the module registry module
  registry_module_id = tfe_registry_module.vpc_module.id
}
```

### Run Triggers and Automation

#### Workspace Dependencies

```hcl
# Run trigger between workspaces
resource "tfe_run_trigger" "network_to_app" {
  workspace_id    = tfe_workspace.app_production.id
  sourceable_id   = tfe_workspace.network_production.id
  sourceable_type = "workspace"
}

# Notification configuration
resource "tfe_notification_configuration" "slack_notifications" {
  name             = "slack-production-alerts"
  enabled          = true
  destination_type = "slack"
  triggers         = ["run:needs_attention", "run:errored"]
  url              = var.slack_webhook_url
  workspace_id     = tfe_workspace.app_production.id
}
```

