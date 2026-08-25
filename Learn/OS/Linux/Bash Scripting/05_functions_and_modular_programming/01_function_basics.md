## Function Basics


### Function Declaration Syntax

Bash provides multiple ways to declare functions:

**Standard POSIX syntax:**

```bash
function_name() {
    commands
}
```

**Bash-specific syntax:**

```bash
function function_name {
    commands
}
```

**Bash syntax with parentheses:**

```bash
function function_name() {
    commands
}
```

The first syntax is most portable and widely used. Functions must be declared before they are called in the script.

```bash
# Function declaration
greet() {
    echo "Hello, World!"
}

# Function call
greet
```

### Function Calling

Functions are called by simply using their name, optionally followed by arguments:

```bash
# Simple function call
function_name

# Function call with arguments
function_name arg1 arg2 arg3

# Capturing function output
result=$(function_name arg1 arg2)

# Using function output in pipeline
function_name arg1 | grep "pattern"
```

Functions execute in the current shell environment, meaning they can access and modify global variables directly.

### Parameters and Arguments

Functions access arguments through positional parameters, similar to how scripts access command-line arguments:

**Positional Parameters:**

- `$1, $2, $3, ...` - Individual arguments
- `$0` - Function name (in some contexts)
- `$#` - Number of arguments
- `$@` - All arguments as separate words
- `$*` - All arguments as single word
- `$?` - Exit status of last command

```bash
process_file() {
    local filename="$1"
    local action="$2"
    local options="$3"
    
    echo "Processing: $filename"
    echo "Action: $action"
    echo "Options: $options"
    echo "Total arguments: $#"
}

# Call function with arguments
process_file "/path/to/file.txt" "backup" "--verbose"
```

**Handling Variable Arguments:**

```bash
sum_numbers() {
    local total=0
    local num
    
    # Loop through all arguments
    for num in "$@"; do
        if [[ "$num" =~ ^-?[0-9]+$ ]]; then
            ((total += num))
        else
            echo "Warning: '$num' is not a valid number" >&2
        fi
    done
    
    echo "$total"
}

# Usage
result=$(sum_numbers 10 20 30 40)
echo "Sum: $result"
```

**Argument Validation:**

```bash
validate_args() {
    if [ $# -lt 2 ]; then
        echo "Error: At least 2 arguments required" >&2
        echo "Usage: validate_args <source> <destination> [options]" >&2
        return 1
    fi
    
    local source="$1"
    local dest="$2"
    shift 2  # Remove first two arguments
    local options="$@"  # Remaining arguments
    
    echo "Source: $source"
    echo "Destination: $dest"
    echo "Options: $options"
}
```

### Return Values and Exit Codes

Functions in bash return exit codes (0-255) rather than values like other programming languages:

**Return Statement:**

```bash
check_file() {
    local filename="$1"
    
    if [ -f "$filename" ]; then
        return 0  # Success
    else
        return 1  # Failure
    fi
}

# Using return value
if check_file "/etc/passwd"; then
    echo "File exists"
else
    echo "File not found"
fi
```

**Returning Data via Echo:**

```bash
get_timestamp() {
    echo "$(date '+%Y-%m-%d %H:%M:%S')"
}

# Capture output
current_time=$(get_timestamp)
echo "Current time: $current_time"
```

**Returning Multiple Values:**

```bash
get_file_info() {
    local filename="$1"
    
    if [ -f "$filename" ]; then
        local size=$(stat -c%s "$filename")
        local modified=$(stat -c%Y "$filename")
        echo "$size:$modified"
        return 0
    else
        return 1
    fi
}

# Parse multiple return values
if info=$(get_file_info "/etc/passwd"); then
    IFS=':' read -r size modified <<< "$info"
    echo "Size: $size bytes"
    echo "Modified: $(date -d @$modified)"
fi
```

**Using Global Variables for Complex Returns:**

```bash
parse_config() {
    local config_file="$1"
    
    # Clear global variables
    CONFIG_HOST=""
    CONFIG_PORT=""
    CONFIG_USER=""
    
    if [ ! -f "$config_file" ]; then
        return 1
    fi
    
    # Parse configuration
    while IFS='=' read -r key value; do
        case "$key" in
            "host") CONFIG_HOST="$value" ;;
            "port") CONFIG_PORT="$value" ;;
            "user") CONFIG_USER="$value" ;;
        esac
    done < "$config_file"
    
    return 0
}
```

### Local vs Global Scope

**Global Variables:** By default, all variables in bash are global, meaning they can be accessed and modified from anywhere in the script:

```bash
global_var="I am global"

modify_global() {
    global_var="Modified by function"
    new_global="Created in function"
}

echo "$global_var"  # "I am global"
modify_global
echo "$global_var"  # "Modified by function"
echo "$new_global"  # "Created in function"
```

**Local Variables:** Use the `local` keyword to create variables that are only accessible within the function:

```bash
demo_scope() {
    local local_var="I am local"
    global_var="I am global"
    
    echo "Inside function:"
    echo "Local: $local_var"
    echo "Global: $global_var"
}

demo_scope
echo "Outside function:"
echo "Local: $local_var"    # Empty - not accessible
echo "Global: $global_var"  # "I am global"
```

**Best Practices for Variable Scope:**

```bash
process_data() {
    local input_file="$1"
    local output_file="$2"
    local line_count=0
    local error_count=0
    
    # Process file locally
    while IFS= read -r line; do
        ((line_count++))
        if ! process_line "$line"; then
            ((error_count++))
        fi
    done < "$input_file"
    
    # Set global results
    TOTAL_LINES=$line_count
    TOTAL_ERRORS=$error_count
    
    return 0
}
```

**Local Arrays:**

```bash
process_list() {
    local -a items=("$@")  # Local array
    local -a results=()    # Local array for results
    local item
    
    for item in "${items[@]}"; do
        if [[ "$item" =~ ^[0-9]+$ ]]; then
            results+=("$item")
        fi
    done
    
    # Return results via echo
    printf '%s\n' "${results[@]}"
}

# Usage
numbers=(1 2 abc 3 def 4)
valid_numbers=($(process_list "${numbers[@]}"))
```

### Function Libraries and Sourcing

**Creating Function Libraries:**

```bash
# file: math_functions.sh
add() {
    local a="$1"
    local b="$2"
    echo $((a + b))
}

multiply() {
    local a="$1"
    local b="$2"
    echo $((a * b))
}

factorial() {
    local n="$1"
    local result=1
    local i
    
    for ((i = 1; i <= n; i++)); do
        ((result *= i))
    done
    
    echo "$result"
}
```

**Using Function Libraries:**

```bash
#!/bin/bash

# Source function library
source ./math_functions.sh

# Use functions
result=$(add 5 3)
echo "5 + 3 = $result"

fact=$(factorial 5)
echo "5! = $fact"
```

### Advanced Function Techniques

**Function Recursion:**

```bash
fibonacci() {
    local n="$1"
    
    if ((n <= 1)); then
        echo "$n"
        return
    fi
    
    local prev1=$(fibonacci $((n - 1)))
    local prev2=$(fibonacci $((n - 2)))
    echo $((prev1 + prev2))
}

# Usage
echo "Fibonacci(10): $(fibonacci 10)"
```

**Function Overloading (Simulation):**

```bash
process() {
    case $# in
        1)
            process_single "$1"
            ;;
        2)
            process_pair "$1" "$2"
            ;;
        *)
            process_multiple "$@"
            ;;
    esac
}

process_single() {
    echo "Processing single item: $1"
}

process_pair() {
    echo "Processing pair: $1 and $2"
}

process_multiple() {
    echo "Processing multiple items: $*"
}
```

**Function with Named Parameters:**

```bash
create_user() {
    local username=""
    local email=""
    local role="user"
    local active=true
    
    # Parse named parameters
    while [[ $# -gt 0 ]]; do
        case $1 in
            --username)
                username="$2"
                shift 2
                ;;
            --email)
                email="$2"
                shift 2
                ;;
            --role)
                role="$2"
                shift 2
                ;;
            --inactive)
                active=false
                shift
                ;;
            *)
                echo "Unknown option: $1" >&2
                return 1
                ;;
        esac
    done
    
    # Validate required parameters
    if [[ -z "$username" || -z "$email" ]]; then
        echo "Error: username and email are required" >&2
        return 1
    fi
    
    echo "Creating user: $username ($email) with role: $role, active: $active"
}

# Usage
create_user --username "john" --email "john@example.com" --role "admin"
```

### Error Handling in Functions

```bash
safe_copy() {
    local source="$1"
    local destination="$2"
    local backup_suffix=".backup"
    
    # Validate arguments
    if [[ $# -ne 2 ]]; then
        echo "Error: Expected 2 arguments, got $#" >&2
        return 1
    fi
    
    # Check source exists
    if [[ ! -f "$source" ]]; then
        echo "Error: Source file '$source' not found" >&2
        return 2
    fi
    
    # Create backup if destination exists
    if [[ -f "$destination" ]]; then
        if ! cp "$destination" "${destination}${backup_suffix}"; then
            echo "Error: Failed to create backup" >&2
            return 3
        fi
        echo "Backup created: ${destination}${backup_suffix}"
    fi
    
    # Perform copy
    if ! cp "$source" "$destination"; then
        echo "Error: Copy operation failed" >&2
        return 4
    fi
    
    echo "Successfully copied '$source' to '$destination'"
    return 0
}

# Usage with error handling
if ! safe_copy "file1.txt" "file2.txt"; then
    echo "Copy operation failed with exit code: $?"
fi
```

**Key points:**

- Functions must be declared before they are called
- Use `local` keyword to create function-scoped variables
- Functions return exit codes (0-255), not values
- Use `echo` or global variables to return data
- Always validate function arguments
- Use meaningful return codes for different error conditions

**Example:**

```bash
#!/bin/bash

# Comprehensive function example
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_file="${LOG_FILE:-/var/log/script.log}"
    
    # Validate log level
    case "$level" in
        "INFO"|"WARN"|"ERROR"|"DEBUG")
            ;;
        *)
            echo "Invalid log level: $level" >&2
            return 1
            ;;
    esac
    
    # Format and write log entry
    local log_entry="[$timestamp] [$level] $message"
    
    # Output to console
    echo "$log_entry"
    
    # Write to file if possible
    if [[ -w "$(dirname "$log_file")" ]]; then
        echo "$log_entry" >> "$log_file"
    fi
    
    return 0
}

backup_files() {
    local source_dir="$1"
    local backup_dir="$2"
    local -a failed_files=()
    local file_count=0
    local success_count=0
    
    # Validate directories
    if [[ ! -d "$source_dir" ]]; then
        log_message "ERROR" "Source directory not found: $source_dir"
        return 1
    fi
    
    # Create backup directory
    if ! mkdir -p "$backup_dir"; then
        log_message "ERROR" "Failed to create backup directory: $backup_dir"
        return 2
    fi
    
    log_message "INFO" "Starting backup from $source_dir to $backup_dir"
    
    # Process files
    while IFS= read -r -d '' file; do
        ((file_count++))
        local relative_path="${file#$source_dir/}"
        local backup_path="$backup_dir/$relative_path"
        
        # Create subdirectory if needed
        local backup_subdir=$(dirname "$backup_path")
        if [[ ! -d "$backup_subdir" ]]; then
            mkdir -p "$backup_subdir"
        fi
        
        # Copy file
        if cp "$file" "$backup_path"; then
            ((success_count++))
            log_message "DEBUG" "Backed up: $relative_path"
        else
            failed_files+=("$relative_path")
            log_message "WARN" "Failed to backup: $relative_path"
        fi
    done < <(find "$source_dir" -type f -print0)
    
    # Report results
    log_message "INFO" "Backup completed: $success_count/$file_count files successful"
    
    if [[ ${#failed_files[@]} -gt 0 ]]; then
        log_message "WARN" "Failed files: ${failed_files[*]}"
        return 3
    fi
    
    return 0
}

# Usage
LOG_FILE="/tmp/backup.log"
backup_files "/home/user/documents" "/backup/documents"
exit_code=$?

case $exit_code in
    0) log_message "INFO" "Backup completed successfully" ;;
    1) log_message "ERROR" "Source directory not found" ;;
    2) log_message "ERROR" "Failed to create backup directory" ;;
    3) log_message "WARN" "Backup completed with some failures" ;;
esac
```

Functions are essential for creating modular, reusable, and maintainable bash scripts. They enable code organization, reduce repetition, and provide a clean interface for complex operations. Understanding scope, parameter handling, and return mechanisms is crucial for writing robust bash functions.

---

