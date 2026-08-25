## 3. Terraform Cloud/Enterprise Security Features


### Workspace Security

- **Private Module Registry**: Centralized, version-controlled modules
- **Environment Variables**: Marked as sensitive to prevent exposure
- **VCS Integration**: Branch protection and pull request workflows
- **Run Environment**: Isolated execution environments

### Access Control

```hcl
# Organization-level permissions
resource "tfe_organization_membership" "member" {
  organization = "my-org"
  email        = "user@example.com"
}

# Team-based access
resource "tfe_team" "developers" {
  name         = "developers"
  organization = "my-org"
}

resource "tfe_team_access" "workspace_access" {
  access       = "write"
  team_id      = tfe_team.developers.id
  workspace_id = tfe_workspace.main.id
}
```

### SSO Integration

- SAML 2.0 support
- OIDC integration
- Multi-factor authentication enforcement
- Just-in-time user provisioning

