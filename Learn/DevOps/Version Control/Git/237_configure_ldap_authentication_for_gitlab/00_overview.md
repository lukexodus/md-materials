## Overview

gitlab_rails['ldap_enabled'] = true
gitlab_rails['ldap_servers'] = {
  'main' => {
    'label' => 'Corporate LDAP',
    'host' =>  'ldap.example.com',
    'port' => 389,
    'uid' => 'sAMAccountName',
    'encryption' => 'plain',
    'bind_dn' => 'CN=GitLab Service,OU=Service Accounts,DC=example,DC=com',
    'password' => 'secure-password',
    'active_directory' => true,
    'base' => 'OU=Users,DC=example,DC=com',
    'group_base' => 'OU=Groups,DC=example,DC=com'
  }
}
```

### Git with Code Review Systems

Integrating Git with robust code review systems ensures code quality, knowledge sharing, and compliance in enterprise environments.

**Key Points**

- Code review is essential for maintainability and knowledge transfer
- Enterprise tools provide audit trails and compliance enforcement
- Automation reduces manual review burden
- Custom tooling can integrate with existing enterprise systems

#### GitHub Enterprise Configuration

```json
// Repository settings for code review enforcement
{
  "protection": {
    "required_pull_request_reviews": {
      "dismiss_stale_reviews": true,
      "require_code_owner_reviews": true,
      "required_approving_review_count": 2
    },
    "required_status_checks": {
      "strict": true,
      "contexts": [
        "ci/jenkins", 
        "security/scan",
        "legal/compliance"
      ]
    },
    "restrictions": {
      "users": [],
      "teams": ["release-managers", "senior-developers"]
    }
  }
}
```

#### GitLab Merge Request Approval Rules

```yaml
