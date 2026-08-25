## Best Practices and Standards for Bash Scripting


### Code Style and Conventions

#### Shell Script Formatting Standards

Consistent formatting is crucial for maintainable bash scripts. Follow these formatting conventions to ensure your scripts are readable and professional.

```bash
#!/bin/bash
## Script: user_management.sh
## Description: Manages user accounts and permissions
## Author: System Administrator
## Date: 2025-01-15
## Version: 1.2.0

## Global variables - use UPPERCASE
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_FILE="${SCRIPT_DIR}/config.conf"
readonly LOG_FILE="/var/log/user_management.log"
readonly DEFAULT_SHELL="/bin/bash"

## Function definitions - use lowercase with underscores
create_user_account() {
    local username="$1"
    local full_name="$2"
    local user_group="${3:-users}"
    local home_dir="/home/${username}"
    
    ## Input validation
    if [[ -z "$username" || -z "$full_name" ]]; then
        log_error "Username and full name are required"
        return 1
    fi
    
    ## Check if user already exists
    if id "$username" &>/dev/null; then
        log_warning "User $username already exists"
        return 0
    fi
    
    ## Create user account
    if useradd -m -d "$home_dir" -s "$DEFAULT_SHELL" -c "$full_name" -g "$user_group" "$username"; then
        log_info "User account created successfully: $username"
        set_user_permissions "$username"
        return 0
    else
        log_error "Failed to create user account: $username"
        return 1
    fi
}

## Main execution
main() {
    local action="$1"
    shift
    
    case "$action" in
        "create")
            create_user_account "$@"
            ;;
        "delete")
            delete_user_account "$@"
            ;;
        "list")
            list_user_accounts "$@"
            ;;
        *)
            show_usage
            exit 1
            ;;
    esac
}

## Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

#### Naming Conventions

Follow consistent naming patterns throughout your scripts to improve readability and maintainability.

```bash
## Constants - UPPERCASE with underscores
readonly MAX_RETRY_COUNT=3
readonly DEFAULT_TIMEOUT=30
readonly CONFIG_FILE_PATH="/etc/myapp/config.conf"

## Variables - lowercase with underscores
user_count=0
current_timestamp=$(date +%s)
backup_directory="/backups/$(date +%Y%m%d)"

## Functions - lowercase with underscores, descriptive names
validate_input_parameters() { ... }
process_user_data() { ... }
generate_backup_filename() { ... }
send_notification_email() { ... }

## Private functions - prefix with underscore
_internal_helper_function() { ... }
_cleanup_temporary_files() { ... }

## Arrays - lowercase with descriptive names
declare -a user_list
declare -A configuration_settings
declare -a failed_operations
```

#### Indentation and Spacing

Use consistent indentation and spacing to improve code readability.

```bash
## Use 4 spaces for indentation (not tabs)
if [[ "$user_type" == "admin" ]]; then
    if [[ "$permissions" == "full" ]]; then
        grant_admin_privileges "$username"
        log_info "Admin privileges granted to $username"
    else
        grant_limited_privileges "$username"
        log_info "Limited privileges granted to $username"
    fi
else
    grant_user_privileges "$username"
    log_info "User privileges granted to $username"
fi

## Space around operators and after commas
total_count=$((current_count + new_count))
process_files "$input_dir" "$output_dir" "$file_pattern"

## Align related assignments
readonly SHORT_OPTION="-s"
readonly LONG_OPTION="--long-option"
readonly CONFIG_OPTION="--config-file"
readonly VERBOSE_OPTION="--verbose"
```

#### Error Handling Patterns

Implement consistent error handling throughout your scripts.

```bash
## Standard error handling function
handle_error() {
    local error_code="$1"
    local error_message="$2"
    local line_number="${3:-unknown}"
    
    log_error "Error $error_code at line $line_number: $error_message"
    
    ## Cleanup on error
    cleanup_resources
    
    ## Exit with appropriate code
    exit "$error_code"
}

## Set error trap
trap 'handle_error $? "Unexpected error occurred" $LINENO' ERR

## Function with proper error handling
backup_database() {
    local db_name="$1"
    local backup_path="$2"
    
    ## Validate parameters
    if [[ -z "$db_name" || -z "$backup_path" ]]; then
        log_error "Database name and backup path are required"
        return 1
    fi
    
    ## Check if backup directory exists
    if [[ ! -d "$(dirname "$backup_path")" ]]; then
        log_error "Backup directory does not exist: $(dirname "$backup_path")"
        return 1
    fi
    
    ## Perform backup with error checking
    if ! mysqldump "$db_name" > "$backup_path" 2>/dev/null; then
        log_error "Database backup failed for $db_name"
        return 1
    fi
    
    ## Verify backup file
    if [[ ! -s "$backup_path" ]]; then
        log_error "Backup file is empty or missing: $backup_path"
        return 1
    fi
    
    log_info "Database backup completed successfully: $backup_path"
    return 0
}
```

#### Code Organization Patterns

Structure your scripts in a logical and maintainable way.

```bash
#!/bin/bash
## =============================================================================
## SCRIPT HEADER
## =============================================================================
## Script Name: system_monitor.sh
## Description: Comprehensive system monitoring and alerting
## Author: DevOps Team
## Version: 2.1.0
## License: MIT

## =============================================================================
## GLOBAL CONFIGURATION
## =============================================================================
set -euo pipefail  ## Exit on error, undefined variables, pipe failures
IFS=$'\n\t'        ## Secure Internal Field Separator

## =============================================================================
## CONSTANTS AND CONFIGURATION
## =============================================================================
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PID_FILE="/var/run/${SCRIPT_NAME}.pid"
readonly LOCK_FILE="/var/lock/${SCRIPT_NAME}.lock"

## =============================================================================
## GLOBAL VARIABLES
## =============================================================================
declare -g debug_mode=false
declare -g verbose_mode=false
declare -g dry_run_mode=false

## =============================================================================
## UTILITY FUNCTIONS
## =============================================================================
log_message() { ... }
acquire_lock() { ... }
release_lock() { ... }

## =============================================================================
## CORE FUNCTIONS
## =============================================================================
check_system_resources() { ... }
monitor_processes() { ... }
generate_reports() { ... }

## =============================================================================
## MAIN EXECUTION
## =============================================================================
main() {
    parse_arguments "$@"
    validate_environment
    acquire_lock
    
    trap 'cleanup_and_exit $?' EXIT
    
    execute_monitoring_tasks
}

## =============================================================================
## SCRIPT EXECUTION
## =============================================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

### Documentation Standards

#### Inline Documentation

Provide comprehensive inline documentation for complex logic and important functions.

```bash
#!/bin/bash
## =============================================================================
## File: advanced_backup.sh
## Description: Advanced backup system with compression, encryption, and rotation
## 
## This script provides a comprehensive backup solution with the following features:
## - Multiple compression algorithms (gzip, bzip2, xz)
## - AES-256 encryption for sensitive data
## - Automatic backup rotation based on retention policies
## - Email notifications for backup status
## - Incremental and differential backup support
## - Database-specific backup procedures
## 
## Usage:
##   ./advanced_backup.sh [OPTIONS] SOURCE_PATH DESTINATION_PATH
## 
## Options:
##   -c, --compression TYPE    Compression type (gzip|bzip2|xz)
##   -e, --encrypt            Enable encryption for backup files
##   -r, --retention DAYS     Retention period in days (default: 30)
##   -i, --incremental        Perform incremental backup
##   -n, --notify EMAIL       Email address for notifications
##   -v, --verbose            Enable verbose output
##   -h, --help               Show this help message
## 
## Examples:
##   ./advanced_backup.sh /home/user /backups/home
##   ./advanced_backup.sh -c xz -e -r 7 /var/www /backups/web
##   ./advanced_backup.sh -i -n admin@example.com /data /backups/data
## 
## Author: System Administrator <admin@example.com>
## Version: 3.2.1
## Created: 2024-01-15
## Modified: 2025-01-15
## License: GPL-3.0
## =============================================================================

## =============================================================================
## FUNCTION: create_compressed_backup
## DESCRIPTION: Creates a compressed backup of the specified directory
## 
## This function handles the creation of compressed backups with support for
## multiple compression algorithms. It performs the following operations:
## 1. Validates source directory exists and is readable
## 2. Creates destination directory if it doesn't exist
## 3. Calculates source directory size for progress tracking
## 4. Applies appropriate compression based on user selection
## 5. Verifies backup integrity after creation
## 
## PARAMETERS:
##   $1 (source_path)      - Source directory to backup
##   $2 (destination_path) - Destination path for backup file
##   $3 (compression_type) - Compression algorithm (gzip|bzip2|xz)
## 
## RETURNS:
##   0 - Success
##   1 - Invalid parameters
##   2 - Source directory not accessible
##   3 - Compression failed
##   4 - Integrity check failed
## 
## GLOBALS:
##   VERBOSE_MODE - Controls verbose output
##   COMPRESSION_LEVEL - Compression level (1-9)
## 
## EXAMPLE:
##   create_compressed_backup "/var/www" "/backups/web_backup.tar.xz" "xz"
## =============================================================================
create_compressed_backup() {
    local source_path="$1"
    local destination_path="$2"
    local compression_type="$3"
    
    ## Parameter validation with detailed error messages
    if [[ $## -ne 3 ]]; then
        log_error "Function requires exactly 3 parameters: source_path, destination_path, compression_type"
        return 1
    fi
    
    if [[ ! -d "$source_path" ]]; then
        log_error "Source directory does not exist: $source_path"
        return 2
    fi
    
    if [[ ! -r "$source_path" ]]; then
        log_error "Source directory is not readable: $source_path"
        return 2
    fi
    
    ## Create destination directory if needed
    local dest_dir
    dest_dir="$(dirname "$destination_path")"
    if [[ ! -d "$dest_dir" ]]; then
        if ! mkdir -p "$dest_dir"; then
            log_error "Failed to create destination directory: $dest_dir"
            return 3
        fi
    fi
    
    ## Calculate source size for progress tracking
    local source_size
    source_size=$(du -sb "$source_path" | cut -f1)
    log_info "Source directory size: $(format_bytes "$source_size")"
    
    ## Apply compression based on type
    case "$compression_type" in
        "gzip")
            ## Use gzip compression with progress monitoring
            if [[ "$VERBOSE_MODE" == "true" ]]; then
                tar -czf "$destination_path" -C "$(dirname "$source_path")" "$(basename "$source_path")" --checkpoint=1000 --checkpoint-action=dot
            else
                tar -czf "$destination_path" -C "$(dirname "$source_path")" "$(basename "$source_path")"
            fi
            ;;
        "bzip2")
            ## Use bzip2 compression with higher compression ratio
            if [[ "$VERBOSE_MODE" == "true" ]]; then
                tar -cjf "$destination_path" -C "$(dirname "$source_path")" "$(basename "$source_path")" --checkpoint=1000 --checkpoint-action=dot
            else
                tar -cjf "$destination_path" -C "$(dirname "$source_path")" "$(basename "$source_path")"
            fi
            ;;
        "xz")
            ## Use xz compression with maximum compression
            if [[ "$VERBOSE_MODE" == "true" ]]; then
                tar -cJf "$destination_path" -C "$(dirname "$source_path")" "$(basename "$source_path")" --checkpoint=1000 --checkpoint-action=dot
            else
                tar -cJf "$destination_path" -C "$(dirname "$source_path")" "$(basename "$source_path")"
            fi
            ;;
        *)
            log_error "Unsupported compression type: $compression_type"
            return 1
            ;;
    esac
    
    ## Verify backup was created successfully
    if [[ ! -f "$destination_path" ]]; then
        log_error "Backup file was not created: $destination_path"
        return 3
    fi
    
    ## Check backup integrity
    if ! verify_backup_integrity "$destination_path" "$compression_type"; then
        log_error "Backup integrity check failed"
        return 4
    fi
    
    local backup_size
    backup_size=$(stat -c%s "$destination_path")
    local compression_ratio
    compression_ratio=$(echo "scale=2; $backup_size * 100 / $source_size" | bc)
    
    log_info "Backup created successfully: $destination_path"
    log_info "Backup size: $(format_bytes "$backup_size") (${compression_ratio}% of original)"
    
    return 0
}

## =============================================================================
## FUNCTION: parse_configuration_file
## DESCRIPTION: Parses configuration file and sets global variables
## 
## This function reads a configuration file in KEY=VALUE format and sets
## corresponding global variables. It supports:
## - Comments (lines starting with #)
## - Empty lines (ignored)
## - Variable substitution
## - Type validation for specific configuration keys
## 
## PARAMETERS:
##   $1 (config_file) - Path to configuration file
## 
## RETURNS:
##   0 - Success
##   1 - Configuration file not found
##   2 - Invalid configuration format
## 
## CONFIGURATION FORMAT:
##   ## Backup configuration
##   BACKUP_ROOT_DIR="/backups"
##   RETENTION_DAYS=30
##   COMPRESSION_TYPE="xz"
##   ENABLE_ENCRYPTION=true
## =============================================================================
parse_configuration_file() {
    local config_file="$1"
    
    if [[ ! -f "$config_file" ]]; then
        log_error "Configuration file not found: $config_file"
        return 1
    fi
    
    ## Read configuration file line by line
    while IFS= read -r line; do
        ## Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*## ]] && continue
        
        ## Parse KEY=VALUE pairs
        if [[ "$line" =~ ^[[:space:]]*([A-Z_][A-Z0-9_]*)[[:space:]]*=[[:space:]]*(.*)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            
            ## Remove quotes from value if present
            value="${value#\"}"
            value="${value%\"}"
            value="${value#\'}"
            value="${value%\'}"
            
            ## Set global variable
            declare -g "$key"="$value"
            
            [[ "$VERBOSE_MODE" == "true" ]] && log_debug "Configuration: $key=$value"
        else
            log_warning "Invalid configuration line: $line"
        fi
    done < "$config_file"
    
    return 0
}
```

#### Function Documentation Template

Use consistent documentation templates for all functions.

```bash
## =============================================================================
## FUNCTION: function_name
## DESCRIPTION: Brief description of what the function does
## 
## Detailed description of the function's purpose, behavior, and any important
## implementation details. Include information about:
## - What the function accomplishes
## - Any side effects or state changes
## - Prerequisites or assumptions
## - Special handling or edge cases
## 
## PARAMETERS:
##   $1 (param_name) - Description of parameter 1
##   $2 (param_name) - Description of parameter 2 (optional)
##   $3 (param_name) - Description of parameter 3 (default: value)
## 
## RETURNS:
##   0 - Success description
##   1 - Error condition 1
##   2 - Error condition 2
## 
## GLOBALS:
##   GLOBAL_VAR1 - Description of global variable usage
##   GLOBAL_VAR2 - Description of global variable modification
## 
## EXAMPLE:
##   function_name "param1" "param2" "param3"
##   if function_name "$input" "$output"; then
##       echo "Success"
##   fi
## 
## NOTES:
##   - Any special considerations
##   - Performance implications
##   - Security considerations
## =============================================================================
```

#### README Documentation

Create comprehensive README files for your bash projects.

```markdown
## Project Name

Brief description of what the project does and its main purpose.

### Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Examples](#examples)
- [API Reference](#api-reference)
- [Contributing](#contributing)
- [License](#license)

### Installation

#### Prerequisites

- Bash 4.0 or higher
- Required system packages:
  - `curl` for HTTP requests
  - `jq` for JSON processing
  - `bc` for mathematical calculations

#### Installation Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/username/project-name.git
   cd project-name
```

2. Make scripts executable:
    
    ```bash
    chmod +x *.sh
    ```
    
3. Copy configuration template:
    
    ```bash
    cp config.conf.example config.conf
    ```
    
4. Edit configuration file:
    
    ```bash
    vim config.conf
    ```
    

### Usage

#### Basic Usage

```bash
./script.sh [OPTIONS] COMMAND [ARGUMENTS]
```

#### Options

|Option|Description|Default|
|---|---|---|
|`-c, --config FILE`|Configuration file path|`./config.conf`|
|`-v, --verbose`|Enable verbose output|`false`|
|`-h, --help`|Show help message|-|

#### Commands

|Command|Description|Arguments|
|---|---|---|
|`backup`|Create backup|`SOURCE DESTINATION`|
|`restore`|Restore from backup|`BACKUP_FILE DESTINATION`|
|`list`|List available backups|`[PATTERN]`|

### Configuration

The configuration file uses KEY=VALUE format:

```bash
