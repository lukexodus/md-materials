## 2. Secret Management Integration


### HashiCorp Vault Integration

#### Basic Vault Provider Configuration

```hcl
terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.0"
    }
  }
}

provider "vault" {
  address = "https://vault.example.com"
  # Authentication methods: token, aws, kubernetes, etc.
}
```

#### Dynamic Database Credentials

```hcl
# Configure database secrets engine
resource "vault_database_secrets_mount" "db" {
  path = "database"

  mysql {
    name           = "my-database"
    connection_url = "{{username}}:{{password}}@tcp(localhost:3306)/"
    username       = "vault"
    password       = "vault-password"
  }
}

# Create database role
resource "vault_database_secret_backend_role" "role" {
  backend     = vault_database_secrets_mount.db.path
  name        = "app-role"
  db_name     = "my-database"
  creation_statements = [
    "CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';",
    "GRANT SELECT ON *.* TO '{{name}}'@'%';"
  ]
  default_ttl = 3600
  max_ttl     = 7200
}

# Generate dynamic credentials
data "vault_generic_secret" "db_creds" {
  path = "${vault_database_secrets_mount.db.path}/creds/${vault_database_secret_backend_role.role.name}"
}
```

#### PKI Certificate Management

```hcl
resource "vault_pki_secret_backend" "pki" {
  path        = "pki"
  default_ttl = 3600
  max_ttl     = 86400
}

resource "vault_pki_secret_backend_role" "role" {
  backend        = vault_pki_secret_backend.pki.path
  name           = "web-server"
  allowed_domains = ["example.com"]
  allow_subdomains = true
  max_ttl        = 86400
}

data "vault_pki_secret_backend_cert" "cert" {
  backend     = vault_pki_secret_backend.pki.path
  role        = vault_pki_secret_backend_role.role.name
  common_name = "web.example.com"
}
```

### AWS Secrets Manager Integration

#### Creating and Managing Secrets

```hcl
resource "aws_secretsmanager_secret" "app_secret" {
  name        = "app/database/credentials"
  description = "Database credentials for application"
  
  replica {
    region = "us-west-2"
  }
}

resource "aws_secretsmanager_secret_version" "app_secret_version" {
  secret_id = aws_secretsmanager_secret.app_secret.id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.db_password.result
  })
}

# Automatic rotation
resource "aws_secretsmanager_secret_rotation" "app_secret_rotation" {
  secret_id           = aws_secretsmanager_secret.app_secret.id
  rotation_lambda_arn = aws_lambda_function.rotation.arn
  
  rotation_rules {
    automatically_after_days = 30
  }
}
```

#### Retrieving Secrets

```hcl
data "aws_secretsmanager_secret" "app_secret" {
  name = "app/database/credentials"
}

data "aws_secretsmanager_secret_version" "app_secret_version" {
  secret_id = data.aws_secretsmanager_secret.app_secret.id
}

locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.app_secret_version.secret_string)
}

resource "aws_db_instance" "main" {
  # ... other configuration
  username = local.db_creds.username
  password = local.db_creds.password
}
```

### Azure Key Vault Integration

```hcl
data "azurerm_key_vault" "main" {
  name                = "example-keyvault"
  resource_group_name = "example-rg"
}

data "azurerm_key_vault_secret" "db_password" {
  name         = "database-password"
  key_vault_id = data.azurerm_key_vault.main.id
}

resource "azurerm_mysql_server" "main" {
  # ... other configuration
  administrator_login_password = data.azurerm_key_vault_secret.db_password.value
}
```

