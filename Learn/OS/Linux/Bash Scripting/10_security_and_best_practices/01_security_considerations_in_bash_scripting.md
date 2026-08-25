## Security Considerations in Bash Scripting


### Input Validation and Sanitization

Input validation and sanitization are critical security practices that prevent malicious data from compromising script execution. Proper validation ensures that input data conforms to expected formats and constraints before processing.

#### Understanding Input Attack Vectors

Input attacks exploit vulnerabilities in how scripts process user-provided data. Common attack vectors include command injection, path traversal, format string attacks, and buffer overflow attempts. Attackers can manipulate input to execute arbitrary commands, access unauthorized files, or cause denial-of-service conditions.

**Key points:**

- All external input should be considered untrusted
- Validate input format, length, and character set
- Use whitelisting rather than blacklisting approaches
- Implement multiple layers of validation
- Sanitize input before processing or storage

#### Input Validation Strategies

Effective input validation combines format checking, length restrictions, character set validation, and semantic verification. Regular expressions provide powerful pattern matching capabilities for validating complex input formats.

**Example:**

```bash
# Comprehensive input validation framework
validate_email() {
    local email="$1"
    local email_regex='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    
    # Check format
    if [[ ! "$email" =~ $email_regex ]]; then
        return 1
    fi
    
    # Check length
    if [[ ${#email} -gt 254 ]]; then
        return 1
    fi
    
    # Check for dangerous characters
    if [[ "$email" =~ [^a-zA-Z0-9._%+-@] ]]; then
        return 1
    fi
    
    return 0
}

validate_filename() {
    local filename="$1"
    
    # Check for null or empty
    if [[ -z "$filename" ]]; then
        return 1
    fi
    
    # Check length
    if [[ ${#filename} -gt 255 ]]; then
        return 1
    fi
    
    # Check for path traversal attempts
    if [[ "$filename" =~ \.\./|\.\.\\ ]]; then
        return 1
    fi
    
    # Check for dangerous characters
    if [[ "$filename" =~ [^a-zA-Z0-9._-] ]]; then
        return 1
    fi
    
    # Check for reserved names
    local reserved_names=("CON" "PRN" "AUX" "NUL" "COM1" "COM2" "LPT1" "LPT2")
    for reserved in "${reserved_names[@]}"; do
        if [[ "${filename^^}" == "$reserved" ]]; then
            return 1
        fi
    done
    
    return 0
}

validate_numeric() {
    local value="$1"
    local min="$2"
    local max="$3"
    
    # Check if numeric
    if ! [[ "$value" =~ ^-?[0-9]+$ ]]; then
        return 1
    fi
    
    # Check range
    if [[ -n "$min" ]] && (( value < min )); then
        return 1
    fi
    
    if [[ -n "$max" ]] && (( value > max )); then
        return 1
    fi
    
    return 0
}
```

#### Advanced Sanitization Techniques

Input sanitization involves removing or encoding potentially dangerous characters while preserving legitimate data. Context-aware sanitization ensures that data is properly escaped for its intended use.

**Example:**

```bash
# Context-aware sanitization functions
sanitize_for_shell() {
    local input="$1"
    # Remove or escape shell metacharacters
    local sanitized="${input//[;&|<>(){}$`\\]/}"
    # Remove control characters
    sanitized="${sanitized//[[:cntrl:]]/}"
    echo "$sanitized"
}

sanitize_for_filename() {
    local input="$1"
    # Replace dangerous characters with underscores
    local sanitized="${input//[^a-zA-Z0-9._-]/_}"
    # Limit length
    sanitized="${sanitized:0:255}"
    # Ensure doesn't start with dot or dash
    sanitized="${sanitized#[.-]}"
    echo "$sanitized"
}

sanitize_for_sql() {
    local input="$1"
    # Escape single quotes
    local sanitized="${input//\'/\'\'}"
    # Remove null bytes
    sanitized="${sanitized//$'\0'/}"
    echo "$sanitized"
}

# Comprehensive input processing
process_user_input() {
    local raw_input="$1"
    local validation_type="$2"
    
    # Log input for security monitoring
    logger "Processing user input: type=$validation_type, length=${#raw_input}"
    
    # Validate input based on type
    case "$validation_type" in
        "email")
            if validate_email "$raw_input"; then
                echo "$raw_input"
            else
                echo "ERROR: Invalid email format" >&2
                return 1
            fi
            ;;
        "filename")
            if validate_filename "$raw_input"; then
                echo "$(sanitize_for_filename "$raw_input")"
            else
                echo "ERROR: Invalid filename" >&2
                return 1
            fi
            ;;
        "numeric")
            if validate_numeric "$raw_input" 0 999999; then
                echo "$raw_input"
            else
                echo "ERROR: Invalid numeric value" >&2
                return 1
            fi
            ;;
        *)
            echo "ERROR: Unknown validation type" >&2
            return 1
            ;;
    esac
}
```

#### Input Length and Resource Limits

Implementing input length limits and resource constraints prevents denial-of-service attacks and ensures system stability. These limits should be enforced at multiple levels of the application.

**Example:**

```bash
# Resource-aware input processing
process_large_input() {
    local input_source="$1"
    local max_size_mb="$2"
    local max_lines="$3"
    
    # Check file size if input is a file
    if [[ -f "$input_source" ]]; then
        local file_size=$(stat -c%s "$input_source")
        local max_size_bytes=$((max_size_mb * 1024 * 1024))
        
        if (( file_size > max_size_bytes )); then
            echo "ERROR: Input file too large (${file_size} bytes > ${max_size_bytes} bytes)" >&2
            return 1
        fi
    fi
    
    # Process input with line counting
    local line_count=0
    while IFS= read -r line; do
        ((line_count++))
        
        # Check line limit
        if (( line_count > max_lines )); then
            echo "ERROR: Too many input lines (${line_count} > ${max_lines})" >&2
            return 1
        fi
        
        # Check individual line length
        if (( ${#line} > 4096 )); then
            echo "ERROR: Line too long (${#line} characters)" >&2
            return 1
        fi
        
        # Process line safely
        echo "Processing line $line_count: ${line:0:50}..."
    done < "$input_source"
    
    echo "Successfully processed $line_count lines"
}
```

### Avoiding Code Injection

Code injection attacks occur when untrusted input is executed as code. Prevention requires careful handling of dynamic command construction and proper escaping of user-provided data.

#### Command Injection Prevention

Command injection exploits occur when user input is incorporated into shell commands without proper sanitization. Prevention strategies include avoiding dynamic command construction, using parameter arrays, and implementing strict input validation.

**Key points:**

- Never directly concatenate user input into shell commands
- Use array-based parameter passing where possible
- Implement strict input validation and sanitization
- Use built-in bash features instead of external commands when possible
- Employ principle of least privilege for command execution

**Example:**

```bash
# Secure command execution patterns
execute_safe_command() {
    local command="$1"
    shift
    local -a args=("$@")
    
    # Validate command against whitelist
    local -a allowed_commands=("ls" "cat" "grep" "find" "sort" "uniq")
    local command_allowed=false
    
    for allowed in "${allowed_commands[@]}"; do
        if [[ "$command" == "$allowed" ]]; then
            command_allowed=true
            break
        fi
    done
    
    if [[ "$command_allowed" != true ]]; then
        echo "ERROR: Command not allowed: $command" >&2
        return 1
    fi
    
    # Execute with validated arguments
    "$command" "${args[@]}"
}

# Safe file operations
safe_file_operation() {
    local operation="$1"
    local filename="$2"
    
    # Validate filename
    if ! validate_filename "$filename"; then
        echo "ERROR: Invalid filename" >&2
        return 1
    fi
    
    # Construct safe path
    local safe_path="/tmp/secure_zone/$(sanitize_for_filename "$filename")"
    
    # Ensure path doesn't escape designated directory
    local real_path=$(realpath "$safe_path" 2>/dev/null)
    if [[ "$real_path" != "/tmp/secure_zone"* ]]; then
        echo "ERROR: Path traversal attempt detected" >&2
        return 1
    fi
    
    case "$operation" in
        "read")
            if [[ -f "$safe_path" ]]; then
                cat "$safe_path"
            else
                echo "ERROR: File not found" >&2
                return 1
            fi
            ;;
        "write")
            # Read from stdin with size limit
            head -c 1048576 > "$safe_path"
            ;;
        "delete")
            rm -f "$safe_path"
            ;;
        *)
            echo "ERROR: Unknown operation" >&2
            return 1
            ;;
    esac
}
```

#### Dynamic Code Generation Security

When dynamic code generation is necessary, implement strict controls and validation. Use templates, parameter binding, and code review processes to minimize injection risks.

**Example:**

```bash
# Secure dynamic query builder
build_safe_query() {
    local table="$1"
    local column="$2"
    local value="$3"
    
    # Validate table name against whitelist
    local -a allowed_tables=("users" "products" "orders")
    local table_allowed=false
    
    for allowed in "${allowed_tables[@]}"; do
        if [[ "$table" == "$allowed" ]]; then
            table_allowed=true
            break
        fi
    done
    
    if [[ "$table_allowed" != true ]]; then
        echo "ERROR: Table not allowed: $table" >&2
        return 1
    fi
    
    # Validate column name
    if ! [[ "$column" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "ERROR: Invalid column name: $column" >&2
        return 1
    fi
    
    # Escape value for SQL
    local escaped_value=$(sanitize_for_sql "$value")
    
    # Build query using template
    local query="SELECT * FROM $table WHERE $column = '$escaped_value'"
    echo "$query"
}

# Template-based code generation
generate_config_file() {
    local template="$1"
    local -A parameters=()
    
    # Parse parameters safely
    while IFS='=' read -r key value; do
        # Validate parameter name
        if [[ "$key" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
            parameters["$key"]="$value"
        else
            echo "ERROR: Invalid parameter name: $key" >&2
            return 1
        fi
    done
    
    # Process template with parameter substitution
    local output="$template"
    for key in "${!parameters[@]}"; do
        local value="${parameters[$key]}"
        # Escape value for configuration file format
        local escaped_value="${value//\\/\\\\}"
        escaped_value="${escaped_value//\"/\\\"}"
        
        # Replace placeholder
        output="${output//\{\{$key\}\}/$escaped_value}"
    done
    
    echo "$output"
}
```

#### Expression Evaluation Security

Mathematical expression evaluation can introduce code injection vulnerabilities. Use dedicated tools and validate expressions before evaluation.

**Example:**

```bash
# Secure mathematical expression evaluation
evaluate_math_expression() {
    local expression="$1"
    
    # Validate expression contains only allowed characters
    if ! [[ "$expression" =~ ^[0-9+\-*/().\s]+$ ]]; then
        echo "ERROR: Invalid characters in expression" >&2
        return 1
    fi
    
    # Check for dangerous patterns
    if [[ "$expression" =~ \$|\`|\|| ]]; then
        echo "ERROR: Dangerous patterns detected" >&2
        return 1
    fi
    
    # Limit expression length
    if (( ${#expression} > 100 )); then
        echo "ERROR: Expression too long" >&2
        return 1
    fi
    
    # Evaluate using bc with restricted environment
    local result=$(echo "$expression" | bc -l 2>/dev/null)
    
    if [[ $? -eq 0 ]] && [[ -n "$result" ]]; then
        echo "$result"
    else
        echo "ERROR: Invalid mathematical expression" >&2
        return 1
    fi
}
```

### Secure File Handling

Secure file handling prevents unauthorized access, data corruption, and information disclosure. This includes proper permissions, secure temporary files, and safe file operations.

#### File System Security

File system security involves setting appropriate permissions, preventing directory traversal attacks, and implementing access controls. Understanding file system permissions and ownership is crucial for maintaining security.

**Key points:**

- Use principle of least privilege for file permissions
- Validate file paths to prevent directory traversal
- Create secure temporary files with appropriate permissions
- Implement file access logging and monitoring
- Use file locking for concurrent access control

**Example:**

```bash
# Secure file operations framework
secure_file_create() {
    local filepath="$1"
    local content="$2"
    local permissions="$3"
    
    # Validate filepath
    if ! validate_filepath "$filepath"; then
        echo "ERROR: Invalid file path" >&2
        return 1
    fi
    
    # Create parent directories securely
    local parent_dir=$(dirname "$filepath")
    if [[ ! -d "$parent_dir" ]]; then
        mkdir -p "$parent_dir" || return 1
        chmod 750 "$parent_dir" || return 1
    fi
    
    # Create file with secure permissions
    umask 077
    echo "$content" > "$filepath" || return 1
    chmod "$permissions" "$filepath" || return 1
    
    # Log file creation
    logger "File created: $filepath (permissions: $permissions)"
}

validate_filepath() {
    local filepath="$1"
    
    # Check for null or empty
    if [[ -z "$filepath" ]]; then
        return 1
    fi
    
    # Resolve path and check for traversal
    local resolved_path=$(realpath "$filepath" 2>/dev/null)
    if [[ -z "$resolved_path" ]]; then
        return 1
    fi
    
    # Check if path is within allowed directory
    local allowed_base="/opt/application/data"
    if [[ "$resolved_path" != "$allowed_base"* ]]; then
        echo "ERROR: Path outside allowed directory: $resolved_path" >&2
        return 1
    fi
    
    return 0
}

secure_file_read() {
    local filepath="$1"
    local max_size="$2"
    
    # Validate file path
    if ! validate_filepath "$filepath"; then
        return 1
    fi
    
    # Check file exists and is readable
    if [[ ! -f "$filepath" ]] || [[ ! -r "$filepath" ]]; then
        echo "ERROR: File not found or not readable: $filepath" >&2
        return 1
    fi
    
    # Check file size
    local file_size=$(stat -c%s "$filepath")
    if (( file_size > max_size )); then
        echo "ERROR: File too large: $file_size bytes" >&2
        return 1
    fi
    
    # Read file safely
    cat "$filepath"
    
    # Log file access
    logger "File read: $filepath (size: $file_size bytes)"
}
```

#### Temporary File Security

Temporary files must be created securely to prevent race conditions and unauthorized access. Use mktemp for secure temporary file creation and implement proper cleanup procedures.

**Example:**

```bash
# Secure temporary file management
create_secure_temp_file() {
    local template="$1"
    local cleanup_on_exit="${2:-true}"
    
    # Create secure temporary file
    local temp_file=$(mktemp "/tmp/${template}.XXXXXX")
    if [[ -z "$temp_file" ]]; then
        echo "ERROR: Failed to create temporary file" >&2
        return 1
    fi
    
    # Set secure permissions
    chmod 600 "$temp_file"
    
    # Setup cleanup if requested
    if [[ "$cleanup_on_exit" == true ]]; then
        trap "secure_cleanup '$temp_file'" EXIT
    fi
    
    echo "$temp_file"
}

secure_cleanup() {
    local temp_file="$1"
    
    if [[ -f "$temp_file" ]]; then
        # Overwrite file with random data before deletion
        dd if=/dev/urandom of="$temp_file" bs=1024 count=1 2>/dev/null
        rm -f "$temp_file"
        logger "Secure cleanup completed: $temp_file"
    fi
}

# Secure file processing with temporary files
process_file_securely() {
    local input_file="$1"
    local output_file="$2"
    
    # Create secure temporary file
    local temp_file=$(create_secure_temp_file "processing")
    
    # Process file with validation
    if secure_file_read "$input_file" 10485760 > "$temp_file"; then
        # Validate processed content
        if validate_file_content "$temp_file"; then
            # Move to final location
            mv "$temp_file" "$output_file"
            chmod 644 "$output_file"
            logger "File processed successfully: $input_file -> $output_file"
        else
            echo "ERROR: Invalid processed content" >&2
            return 1
        fi
    else
        echo "ERROR: Failed to process input file" >&2
        return 1
    fi
}

validate_file_content() {
    local filepath="$1"
    
    # Check for malicious content patterns
    if grep -q "<?php\|<script\|javascript:" "$filepath"; then
        echo "ERROR: Potentially malicious content detected" >&2
        return 1
    fi
    
    # Check file format
    local file_type=$(file -b "$filepath")
    if [[ "$file_type" != "ASCII text"* ]] && [[ "$file_type" != "UTF-8 Unicode text"* ]]; then
        echo "ERROR: Invalid file type: $file_type" >&2
        return 1
    fi
    
    return 0
}
```

#### File Permission Management

Proper file permission management ensures that only authorized users can access sensitive files. Implement regular permission audits and automated permission correction.

**Example:**

```bash
# File permission management system
set_secure_permissions() {
    local filepath="$1"
    local file_type="$2"
    
    case "$file_type" in
        "config")
            chmod 600 "$filepath"
            chown root:root "$filepath"
            ;;
        "log")
            chmod 640 "$filepath"
            chown root:adm "$filepath"
            ;;
        "data")
            chmod 644 "$filepath"
            chown www-data:www-data "$filepath"
            ;;
        "executable")
            chmod 755 "$filepath"
            chown root:root "$filepath"
            ;;
        *)
            echo "ERROR: Unknown file type: $file_type" >&2
            return 1
            ;;
    esac
    
    logger "Permissions set: $filepath ($file_type)"
}

audit_file_permissions() {
    local directory="$1"
    local -a violations=()
    
    # Find files with incorrect permissions
    while IFS= read -r -d '' file; do
        local permissions=$(stat -c%a "$file")
        local owner=$(stat -c%U "$file")
        local group=$(stat -c%G "$file")
        
        # Check for world-writable files
        if [[ "$permissions" =~ .*[2367]$ ]]; then
            violations+=("World-writable file: $file ($permissions)")
        fi
        
        # Check for SUID/SGID files
        if [[ "$permissions" =~ ^[4567] ]]; then
            violations+=("SUID/SGID file: $file ($permissions)")
        fi
        
        # Check for files owned by unexpected users
        if [[ "$owner" != "root" ]] && [[ "$owner" != "www-data" ]]; then
            violations+=("Unexpected owner: $file ($owner)")
        fi
        
    done < <(find "$directory" -type f -print0)
    
    # Report violations
    if [[ ${#violations[@]} -gt 0 ]]; then
        echo "Permission violations found:"
        printf '%s\n' "${violations[@]}"
        return 1
    else
        echo "No permission violations found"
        return 0
    fi
}
```

### Password and Credential Management

Secure credential management prevents unauthorized access and credential compromise. This includes secure storage, transmission, and handling of passwords and other sensitive authentication data.

#### Secure Password Storage

Passwords should never be stored in plain text. Use proper hashing algorithms, salt generation, and secure storage mechanisms to protect user credentials.

**Key points:**

- Never store passwords in plain text
- Use strong hashing algorithms (bcrypt, scrypt, Argon2)
- Generate unique salts for each password
- Implement secure credential storage systems
- Use environment variables or secure vaults for application credentials

**Example:**

```bash
# Secure password handling system
generate_salt() {
    local length="${1:-32}"
    openssl rand -hex "$length"
}

hash_password() {
    local password="$1"
    local salt="$2"
    
    # Use scrypt for password hashing
    local hash=$(echo -n "$password$salt" | openssl dgst -sha256 -hex)
    echo "${hash#* }"
}

store_user_credential() {
    local username="$1"
    local password="$2"
    local credential_file="/etc/secure/credentials"
    
    # Validate username
    if ! [[ "$username" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "ERROR: Invalid username format" >&2
        return 1
    fi
    
    # Validate password strength
    if ! validate_password_strength "$password"; then
        echo "ERROR: Password does not meet security requirements" >&2
        return 1
    fi
    
    # Generate unique salt
    local salt=$(generate_salt)
    
    # Hash password
    local password_hash=$(hash_password "$password" "$salt")
    
    # Store securely
    local entry="$username:$password_hash:$salt:$(date +%s)"
    echo "$entry" >> "$credential_file"
    chmod 600 "$credential_file"
    
    logger "Credential stored for user: $username"
}

validate_password_strength() {
    local password="$1"
    
    # Check minimum length
    if [[ ${#password} -lt 12 ]]; then
        return 1
    fi
    
    # Check for required character types
    if ! [[ "$password" =~ [a-z] ]]; then
        return 1
    fi
    
    if ! [[ "$password" =~ [A-Z] ]]; then
        return 1
    fi
    
    if ! [[ "$password" =~ [0-9] ]]; then
        return 1
    fi
    
    if ! [[ "$password" =~ [^a-zA-Z0-9] ]]; then
        return 1
    fi
    
    return 0
}

verify_user_credential() {
    local username="$1"
    local password="$2"
    local credential_file="/etc/secure/credentials"
    
    # Find user entry
    local user_entry=$(grep "^$username:" "$credential_file" 2>/dev/null)
    if [[ -z "$user_entry" ]]; then
        echo "ERROR: User not found" >&2
        return 1
    fi
    
    # Parse entry
    IFS=':' read -r stored_user stored_hash stored_salt timestamp <<< "$user_entry"
    
    # Verify password
    local password_hash=$(hash_password "$password" "$stored_salt")
    if [[ "$password_hash" == "$stored_hash" ]]; then
        logger "Successful authentication: $username"
        return 0
    else
        logger "Failed authentication attempt: $username"
        return 1
    fi
}
```

#### Environment Variable Security

Environment variables can expose sensitive information. Implement secure practices for handling credentials through environment variables.

**Example:**

```bash
# Secure environment variable handling
load_credentials_from_env() {
    local -A credentials=()
    
    # Load database credentials
    if [[ -n "$DB_PASSWORD" ]]; then
        credentials["db_password"]="$DB_PASSWORD"
        unset DB_PASSWORD  # Clear from environment
    else
        echo "ERROR: Database password not provided" >&2
        return 1
    fi
    
    # Load API keys
    if [[ -n "$API_KEY" ]]; then
        credentials["api_key"]="$API_KEY"
        unset API_KEY
    fi
    
    # Validate credentials
    for key in "${!credentials[@]}"; do
        if [[ -z "${credentials[$key]}" ]]; then
            echo "ERROR: Empty credential: $key" >&2
            return 1
        fi
    done
    
    # Store in secure location
    local credential_file=$(create_secure_temp_file "credentials")
    for key in "${!credentials[@]}"; do
        echo "$key=${credentials[$key]}" >> "$credential_file"
    done
    
    echo "$credential_file"
}

# Secure credential vault integration
retrieve_credential() {
    local credential_name="$1"
    local vault_path="$2"
    
    # Use external vault system (e.g., HashiCorp Vault)
    local credential=$(vault kv get -field="$credential_name" "$vault_path" 2>/dev/null)
    
    if [[ -z "$credential" ]]; then
        echo "ERROR: Failed to retrieve credential: $credential_name" >&2
        return 1
    fi
    
    echo "$credential"
}

# Secure credential rotation
rotate_credentials() {
    local service="$1"
    local new_password=$(generate_secure_password)
    
    # Update service with new password
    if update_service_password "$service" "$new_password"; then
        # Update credential store
        store_user_credential "$service" "$new_password"
        
        # Log rotation
        logger "Credential rotated for service: $service"
        
        # Notify monitoring systems
        echo "Credential rotation completed for $service" | \
            curl -X POST -H "Content-Type: application/json" \
                 -d @- https://monitoring.example.com/events
    else
        echo "ERROR: Failed to rotate credentials for $service" >&2
        return 1
    fi
}

generate_secure_password() {
    local length="${1:-24}"
    
    # Generate cryptographically secure password
    openssl rand -base64 "$length" | tr -d "=+/" | cut -c1-"$length"
}
```

#### Secure Authentication Mechanisms

Implement secure authentication mechanisms that protect against common attacks such as brute force, credential stuffing, and session hijacking.

**Example:**

```bash
# Secure authentication framework
authenticate_user() {
    local username="$1"
    local password="$2"
    local client_ip="$3"
    
    # Check for account lockout
    if is_account_locked "$username"; then
        echo "ERROR: Account is locked" >&2
        log_security_event "account_locked" "$username" "$client_ip"
        return 1
    fi
    
    # Check for rate limiting
    if is_rate_limited "$client_ip"; then
        echo "ERROR: Rate limit exceeded" >&2
        log_security_event "rate_limited" "$username" "$client_ip"
        return 1
    fi
    
    # Verify credentials
    if verify_user_credential "$username" "$password"; then
        # Reset failed attempts
        reset_failed_attempts "$username"
        
        # Generate session token
        local session_token=$(generate_session_token "$username")
        echo "$session_token"
        
        log_security_event "login_success" "$username" "$client_ip"
        return 0
    else
        # Increment failed attempts
        increment_failed_attempts "$username"
        
        log_security_event "login_failure" "$username" "$client_ip"
        return 1
    fi
}

is_account_locked() {
    local username="$1"
    local lock_file="/tmp/account_locks/$username"
    
    if [[ -f "$lock_file" ]]; then
        local lock_time=$(cat "$lock_file")
        local current_time=$(date +%s)
        local lock_duration=3600  # 1 hour
        
        if (( current_time - lock_time < lock_duration )); then
            return 0  # Account is locked
        else
            rm -f "$lock_file"  # Lock expired
        fi
    fi
    
    return 1  # Account is not locked
}

increment_failed_attempts() {
    local username="$1"
    local attempts_file="/tmp/failed_attempts/$username"
    local max_attempts=5
    
    mkdir -p "/tmp/failed_attempts"
    
    local current_attempts=0
    if [[ -f "$attempts_file" ]]; then
        current_attempts=$(cat "$attempts_file")
    fi
    
    ((current_attempts++))
    echo "$current_attempts" > "$attempts_file"
    
    if (( current_attempts >= max_attempts )); then
        # Lock account
        mkdir -p "/tmp/account_locks"
        date +%s > "/tmp/account_locks/$username"
        logger "Account locked due to failed attempts: $username"
    fi
}

generate_session_token() {
    local username="$1"
    local timestamp=$(date +%s)
    local random_data=$(openssl rand -hex 32)
    
    # Create session token
    local token_data="$username:$timestamp:$random_data"
    local token=$(echo -n "$token_data" | openssl dgst -sha256 -hex)
    
    # Store session
    local session_file="/tmp/sessions/${token#* }"
    echo "$username:$timestamp" > "$session_file"
    chmod 600 "$session_file"
    
    echo "${token#* }"
}

log_security_event() {
    local event_type="$1"
    local username="$2"
    local client_ip="$3"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Log to security log
    echo "[$timestamp] $event_type: user=$username, ip=$client_ip" >> /var/log/security.log
    
    # Send to SIEM system
    local event_json=$(cat <<EOF
{
    "timestamp": "$timestamp",
    "event_type": "$event_type",
    "username": "$username",
    "client_ip": "$client_ip",
    "source": "bash_script"
}
EOF
)
    
    echo "$event_json" | curl -X POST -H "Content-Type: application/json" \
                              -d @- https://siem.example.com/events 2>/dev/null
}
```

**Next steps:** Explore advanced security topics including secure communication protocols, cryptographic implementations, security monitoring and alert

---

