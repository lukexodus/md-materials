## Configuration Management


Configuration management in bash scripting involves systematically organizing, maintaining, and deploying configuration data across different environments and systems. This encompasses managing environment-specific settings, processing configuration templates, integrating with version control systems, and automating deployment processes. Effective configuration management ensures consistency, repeatability, and maintainability in complex system deployments.

### Environment-Specific Configurations

Environment-specific configurations enable scripts to adapt behavior based on deployment contexts such as development, staging, and production environments. This approach centralizes configuration management while maintaining flexibility for different operational requirements.

Configuration hierarchies organize settings from general to specific, allowing inheritance and override patterns. Base configurations define common settings applicable across all environments, while environment-specific configurations override or extend base settings. This hierarchical approach reduces duplication and ensures consistency where appropriate.

Environment detection mechanisms automatically identify the current execution context through various indicators including hostname patterns, environment variables, network configurations, or explicit configuration files. Reliable environment detection prevents configuration mismatches that could lead to deployment failures or security vulnerabilities.

Configuration file formats commonly used include JSON, YAML, INI files, and bash-native associative arrays. Each format offers different advantages: JSON provides structured data with parsing tools, YAML offers human-readable hierarchical configurations, INI files provide simple key-value pairs, and bash arrays offer native integration without external dependencies.

Variable substitution techniques replace placeholders in configuration files with actual values during script execution. This includes simple string replacement, environment variable substitution, and computed value insertion. Substitution patterns typically use formats like `${VAR_NAME}` or `{{PLACEHOLDER}}` for clear identification.

Configuration validation ensures loaded configurations meet requirements before use. This includes checking required parameters, validating data types, verifying file paths, and testing connectivity to external services. Early validation prevents runtime failures caused by invalid configurations.

Secure configuration management addresses sensitive data like passwords, API keys, and certificates. This involves using encrypted storage, secure key management systems, environment variable injection, and access control mechanisms. Sensitive data should never be stored in plain text configuration files or version control systems.

### Template Processing

Template processing transforms configuration templates into final configuration files by replacing variables, evaluating expressions, and applying conditional logic. This approach enables dynamic configuration generation based on runtime conditions and environment-specific requirements.

Template engines for bash environments include simple variable substitution, external tools like envsubst, jinja2 with Python integration, and custom bash-based processors. Each approach offers different capabilities: simple substitution handles basic variable replacement, while sophisticated engines support conditional logic and iteration.

Variable interpolation techniques insert values into templates using various syntax patterns. Common patterns include shell-style `${VARIABLE}` substitution, double-brace `{{VARIABLE}}` notation, and percentage-based `%VARIABLE%` markers. Consistent syntax choices improve template readability and maintainability.

Conditional template processing includes or excludes template sections based on runtime conditions. This enables generating different configurations for different environments or features. Conditional logic can be implemented through external template engines or custom bash processing using conditional blocks.

Loop constructs in templates handle repetitive configuration elements such as server lists, database connections, or service definitions. Template engines supporting loops can generate configuration sections dynamically based on arrays or data structures.

Template inheritance allows complex templates to build upon base templates, inheriting common elements while customizing specific sections. This pattern reduces duplication and ensures consistency across related configurations.

Error handling in template processing addresses missing variables, invalid expressions, and template syntax errors. Robust error handling prevents generation of malformed configuration files that could cause service failures.

### Version Control Integration

Version control integration ensures configuration changes are tracked, reviewable, and deployable through established development workflows. This includes managing configuration files in repositories, implementing change approval processes, and maintaining deployment history.

Configuration file organization in version control repositories follows structured approaches separating environment-specific files, shared templates, and deployment scripts. Directory structures typically organize configurations by environment, application, or service to facilitate maintenance and deployment.

Branch-based configuration management aligns configuration changes with code development workflows. This includes maintaining environment-specific branches, using feature branches for configuration changes, and implementing merge strategies that ensure configuration consistency across environments.

Tagging and versioning strategies enable tracking configuration deployments and facilitating rollbacks when necessary. Semantic versioning approaches help identify the scope and impact of configuration changes, while deployment tags mark specific configuration versions deployed to different environments.

Automated configuration validation through pre-commit hooks and continuous integration pipelines ensures configuration changes meet quality standards before deployment. This includes syntax validation, security scanning, and compatibility testing across target environments.

Configuration drift detection identifies differences between deployed configurations and version-controlled sources. Regular drift detection helps maintain consistency and identifies unauthorized changes that might have been made directly to deployed systems.

Merge conflict resolution strategies handle situations where multiple team members modify the same configuration files. Clear conflict resolution procedures and tools help maintain configuration integrity during collaborative development.

### Deployment Automation

Deployment automation orchestrates the process of applying configuration changes to target systems reliably and consistently. This includes configuration deployment pipelines, rollback mechanisms, and health checking procedures.

Deployment pipelines automate the sequence of steps required to deploy configurations from version control to target systems. Pipelines typically include stages for validation, testing, staging deployment, and production deployment with appropriate approval gates between stages.

Configuration deployment strategies include blue-green deployments, rolling updates, and canary deployments. Blue-green deployments maintain two identical environments and switch traffic between them, rolling updates gradually replace configurations across multiple instances, and canary deployments test configurations with limited traffic before full deployment.

Rollback mechanisms provide the ability to quickly revert to previous configurations when deployments fail or cause issues. This includes maintaining configuration backups, implementing automated rollback triggers, and providing manual rollback procedures for emergency situations.

Health checking and monitoring validate that deployed configurations function correctly and meet performance requirements. This includes service health checks, configuration validation tests, and performance monitoring to detect issues early in the deployment process.

Deployment coordination manages dependencies between different configuration components and services. This includes orchestrating deployment sequences, managing service dependencies, and coordinating updates across multiple systems or environments.

Notification and reporting systems inform stakeholders about deployment status, success, and failures. This includes integration with communication platforms, automated reporting, and dashboard integration for deployment visibility.

Zero-downtime deployment techniques ensure service availability during configuration updates. This includes strategies for updating configurations without service interruption, managing database migrations, and coordinating updates across load-balanced environments.

**Key points:**

- Environment-specific configurations should be clearly separated and well-documented to prevent deployment errors
- Template processing enables dynamic configuration generation but requires careful error handling
- Version control integration ensures configuration changes follow established development workflows
- Deployment automation reduces human error and ensures consistent deployment processes
- Security considerations must be integrated throughout the configuration management lifecycle

**Example:**

```bash
#!/bin/bash

# Environment detection and configuration loading
detect_environment() {
    local env_file="/etc/deployment/environment"
    local hostname=$(hostname)
    
    # Check explicit environment file
    if [[ -f "$env_file" ]]; then
        source "$env_file"
        echo "$DEPLOYMENT_ENV"
        return 0
    fi
    
    # Detect based on hostname patterns
    case "$hostname" in
        *-dev-*)   echo "development" ;;
        *-stage-*) echo "staging" ;;
        *-prod-*)  echo "production" ;;
        *)         echo "unknown" ;;
    esac
}

# Configuration loading with hierarchy
load_configuration() {
    local environment="$1"
    local config_dir="/etc/app/config"
    
    # Load base configuration
    if [[ -f "$config_dir/base.conf" ]]; then
        source "$config_dir/base.conf"
    fi
    
    # Load environment-specific configuration
    if [[ -f "$config_dir/$environment.conf" ]]; then
        source "$config_dir/$environment.conf"
    fi
    
    # Load local overrides
    if [[ -f "$config_dir/local.conf" ]]; then
        source "$config_dir/local.conf"
    fi
}

# Template processing with variable substitution
process_template() {
    local template_file="$1"
    local output_file="$2"
    local temp_file
    
    temp_file=$(mktemp)
    
    # Simple variable substitution
    envsubst < "$template_file" > "$temp_file"
    
    # Custom processing for complex logic
    while IFS= read -r line; do
        # Process conditional blocks
        if [[ $line =~ ^#IF\ (.+)$ ]]; then
            local condition="${BASH_REMATCH[1]}"
            if eval "$condition"; then
                echo "# Condition $condition: true"
            else
                # Skip until #ENDIF
                while IFS= read -r skip_line && [[ ! $skip_line =~ ^#ENDIF ]]; do
                    continue
                done
            fi
        elif [[ $line =~ ^#ENDIF ]]; then
            continue
        else
            echo "$line"
        fi
    done < "$temp_file" > "$output_file"
    
    rm -f "$temp_file"
}

# Configuration validation
validate_configuration() {
    local config_file="$1"
    local errors=0
    
    # Check required variables
    local required_vars=("DATABASE_URL" "API_KEY" "SERVICE_PORT")
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var}" ]]; then
            echo "Error: Missing required variable $var" >&2
            ((errors++))
        fi
    done
    
    # Validate data types and formats
    if [[ ! $SERVICE_PORT =~ ^[0-9]+$ ]]; then
        echo "Error: SERVICE_PORT must be numeric" >&2
        ((errors++))
    fi
    
    if [[ ! $DATABASE_URL =~ ^[a-zA-Z]+:// ]]; then
        echo "Error: DATABASE_URL must be a valid URL" >&2
        ((errors++))
    fi
    
    return $errors
}

# Version control integration
deploy_from_git() {
    local repo_url="$1"
    local branch="$2"
    local deployment_dir="$3"
    local backup_dir="/var/backups/config"
    
    # Create backup of current configuration
    if [[ -d "$deployment_dir" ]]; then
        local backup_name="config-$(date +%Y%m%d-%H%M%S)"
        cp -r "$deployment_dir" "$backup_dir/$backup_name"
    fi
    
    # Clone or update repository
    if [[ -d "$deployment_dir/.git" ]]; then
        cd "$deployment_dir"
        git fetch origin
        git checkout "$branch"
        git pull origin "$branch"
    else
        git clone -b "$branch" "$repo_url" "$deployment_dir"
    fi
    
    # Validate configuration before deployment
    if ! validate_configuration "$deployment_dir/config"; then
        echo "Configuration validation failed, rolling back" >&2
        rollback_configuration "$backup_dir/$backup_name" "$deployment_dir"
        return 1
    fi
    
    echo "Configuration deployed successfully"
    return 0
}

# Deployment automation with health checks
deploy_configuration() {
    local environment="$1"
    local service_name="$2"
    local config_template="$3"
    local config_output="$4"
    
    # Load environment-specific configuration
    load_configuration "$environment"
    
    # Process configuration template
    process_template "$config_template" "$config_output"
    
    # Validate generated configuration
    if ! validate_configuration "$config_output"; then
        echo "Generated configuration is invalid" >&2
        return 1
    fi
    
    # Deploy configuration
    if systemctl is-active --quiet "$service_name"; then
        # Reload service with new configuration
        systemctl reload "$service_name"
        
        # Health check
        sleep 5
        if ! systemctl is-active --quiet "$service_name"; then
            echo "Service failed after configuration reload" >&2
            return 1
        fi
    else
        # Start service with new configuration
        systemctl start "$service_name"
        
        # Health check
        sleep 10
        if ! systemctl is-active --quiet "$service_name"; then
            echo "Service failed to start with new configuration" >&2
            return 1
        fi
    fi
    
    echo "Configuration deployed and service is healthy"
    return 0
}

# Rollback mechanism
rollback_configuration() {
    local backup_path="$1"
    local target_path="$2"
    local service_name="$3"
    
    if [[ ! -d "$backup_path" ]]; then
        echo "Backup not found: $backup_path" >&2
        return 1
    fi
    
    # Stop service
    systemctl stop "$service_name"
    
    # Restore configuration
    rm -rf "$target_path"
    cp -r "$backup_path" "$target_path"
    
    # Restart service
    systemctl start "$service_name"
    
    # Verify rollback
    sleep 5
    if systemctl is-active --quiet "$service_name"; then
        echo "Rollback successful"
        return 0
    else
        echo "Rollback failed - service not healthy" >&2
        return 1
    fi
}

# Main deployment workflow
main() {
    local environment
    environment=$(detect_environment)
    
    if [[ "$environment" == "unknown" ]]; then
        echo "Cannot determine environment" >&2
        exit 1
    fi
    
    echo "Deploying to environment: $environment"
    
    # Deploy from version control
    if ! deploy_from_git "$REPO_URL" "$environment" "/opt/app/config"; then
        echo "Failed to deploy from git" >&2
        exit 1
    fi
    
    # Deploy service configuration
    if ! deploy_configuration "$environment" "myapp" "/opt/app/config/app.conf.template" "/etc/myapp/app.conf"; then
        echo "Failed to deploy service configuration" >&2
        exit 1
    fi
    
    echo "Deployment completed successfully"
}

# Configuration drift detection
detect_drift() {
    local deployed_config="/etc/myapp/app.conf"
    local source_config="/opt/app/config/app.conf"
    
    if ! diff -q "$deployed_config" "$source_config" > /dev/null; then
        echo "Configuration drift detected"
        echo "Differences:"
        diff "$deployed_config" "$source_config"
        return 1
    fi
    
    echo "No configuration drift detected"
    return 0
}

# Example configuration template (app.conf.template)
: '
# Application Configuration Template
# Environment: ${ENVIRONMENT}
# Generated: $(date)

#IF [[ "$ENVIRONMENT" == "production" ]]
log_level=error
debug=false
#ENDIF

#IF [[ "$ENVIRONMENT" == "development" ]]
log_level=debug
debug=true
#ENDIF

database_url=${DATABASE_URL}
api_key=${API_KEY}
service_port=${SERVICE_PORT}
max_connections=${MAX_CONNECTIONS:-100}
'
```

**Conclusion:** Configuration management requires systematic approaches to handle complexity while maintaining reliability and security. Effective configuration management reduces deployment risks, improves consistency across environments, and enables rapid response to changing requirements. The integration of version control, automated testing, and deployment automation creates a robust foundation for managing complex system configurations.

For large-scale deployments, consider implementing configuration management platforms like Ansible, Puppet, or Chef for more sophisticated configuration orchestration and management capabilities.

---

