## Functions & Advanced Scripting


### Function Definition and Calling

Functions in bash are reusable blocks of code that can accept parameters and return values. They provide modularity and reduce code duplication in scripts.

#### Basic Function Syntax

```bash
# Method 1: function keyword
function function_name() {
    # commands
}

# Method 2: without function keyword (POSIX compliant)
function_name() {
    # commands
}
```

#### Function Parameters and Return Values

Functions access parameters through positional variables (`$1`, `$2`, etc.) and can return exit status codes.

```bash
#!/bin/bash

# Function with parameters
calculate_sum() {
    local num1=$1
    local num2=$2
    local result=$((num1 + num2))
    echo $result
}

# Function with return status
validate_file() {
    if [[ -f "$1" ]]; then
        return 0  # success
    else
        return 1  # failure
    fi
}

# Calling functions
sum=$(calculate_sum 10 20)
echo "Sum: $sum"

if validate_file "/etc/passwd"; then
    echo "File exists"
else
    echo "File not found"
fi
```

#### Advanced Function Features

**Key points:**

- Functions can call other functions (recursion supported)
- Functions inherit the shell environment but can modify it
- Exit codes from functions can be captured using `$?`
- Functions can output to stdout, stderr, or both

**Example** of recursive function:

```bash
factorial() {
    local n=$1
    if [[ $n -le 1 ]]; then
        echo 1
    else
        local prev=$(factorial $((n-1)))
        echo $((n * prev))
    fi
}

result=$(factorial 5)
echo "5! = $result"
```

### Local vs Global Variables

Variable scope determines where variables can be accessed and modified within scripts and functions.

#### Global Variables

By default, all variables in bash are global and accessible throughout the entire script.

```bash
#!/bin/bash

global_var="I am global"

function show_global() {
    echo $global_var
    global_var="Modified globally"
}

echo $global_var        # Output: I am global
show_global             # Output: I am global
echo $global_var        # Output: Modified globally
```

#### Local Variables

Local variables are declared with the `local` keyword and exist only within the function scope.

```bash
#!/bin/bash

global_counter=0

increment_counter() {
    local local_counter=10
    global_counter=$((global_counter + 1))
    local_counter=$((local_counter + 1))
    
    echo "Local counter: $local_counter"
    echo "Global counter: $global_counter"
}

increment_counter       # Local: 11, Global: 1
echo "Global counter outside: $global_counter"  # Output: 1
echo "Local counter outside: $local_counter"    # Output: (empty)
```

#### Best Practices for Variable Scope

**Key points:**

- Always use `local` for function variables to prevent side effects
- Initialize local variables at function start
- Use descriptive names to avoid conflicts
- Consider using `readonly` for constants

**Example** of proper variable scoping:

```bash
#!/bin/bash

readonly SCRIPT_NAME="backup_script"
config_file="/etc/myapp.conf"

load_config() {
    local config_path="$1"
    local line
    
    while IFS= read -r line; do
        # Process configuration
        echo "Config: $line"
    done < "$config_path"
}
```

### Script Debugging

Debugging bash scripts involves identifying and fixing logical errors, syntax issues, and runtime problems.

#### Built-in Debugging Options

Bash provides several debugging flags that can be set via `set` command or shebang line.

```bash
#!/bin/bash -x  # Enable debug mode from start

# Or enable during execution
set -x          # Enable debug output
set +x          # Disable debug output
set -v          # Print shell input lines as read
set -e          # Exit on any command failure
set -u          # Exit on undefined variables
set -o pipefail # Exit on pipe command failures
```

#### Common Debugging Techniques

**Manual Debug Output:**

```bash
#!/bin/bash

DEBUG=true

debug_print() {
    if [[ "$DEBUG" == "true" ]]; then
        echo "[DEBUG] $*" >&2
    fi
}

main_function() {
    local input="$1"
    debug_print "Processing input: $input"
    
    # Main logic here
    debug_print "Function completed successfully"
}
```

**Function Tracing:**

```bash
#!/bin/bash

# Enable function tracing
set -o functrace
trap 'echo "Entering: $BASH_COMMAND"' DEBUG

process_data() {
    local data="$1"
    echo "Processing: $data"
    return 0
}
```

#### Advanced Debugging Tools

**Using bashdb (if available):**

```bash
# Install bashdb debugger
# bashdb script.sh

# Set breakpoints and step through code
# Commands: step, next, continue, print variable_name
```

**Syntax Checking:**

```bash
# Check syntax without execution
bash -n script.sh

# Check for common issues
shellcheck script.sh
```

### Error Handling

Proper error handling ensures scripts fail gracefully and provide meaningful feedback when problems occur.

#### Basic Error Detection

```bash
#!/bin/bash

set -e  # Exit on any error
set -u  # Exit on undefined variables
set -o pipefail  # Exit on pipe failures

# Custom error handler
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Usage
[[ -f "$config_file" ]] || error_exit "Configuration file not found: $config_file"
```

#### Trap-based Error Handling

The `trap` command allows executing cleanup code when errors occur or scripts exit.

```bash
#!/bin/bash

# Cleanup function
cleanup() {
    local exit_code=$?
    echo "Cleaning up temporary files..."
    rm -f /tmp/script_temp_*
    exit $exit_code
}

# Error handler
handle_error() {
    local line_number=$1
    echo "Error occurred on line $line_number" >&2
    cleanup
}

# Set traps
trap cleanup EXIT
trap 'handle_error $LINENO' ERR

# Main script logic
temp_file=$(mktemp /tmp/script_temp_XXXXXX)
echo "Working with temp file: $temp_file"
```

#### Advanced Error Handling Patterns

**Function-level Error Handling:**

```bash
#!/bin/bash

# Wrapper function for error checking
safe_execute() {
    local command="$1"
    local error_message="$2"
    
    if ! eval "$command"; then
        echo "Error: $error_message" >&2
        return 1
    fi
}

# Usage
safe_execute "cp source.txt dest.txt" "Failed to copy file" || exit 1
safe_execute "chmod 755 script.sh" "Failed to set permissions" || exit 1
```

**Logging and Error Reporting:**

```bash
#!/bin/bash

LOG_FILE="/var/log/script.log"

log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    if [[ "$level" == "ERROR" ]]; then
        echo "ERROR: $message" >&2
    fi
}

# Error handling with logging
handle_critical_error() {
    local error_msg="$1"
    log_message "ERROR" "$error_msg"
    log_message "INFO" "Script terminating due to critical error"
    exit 1
}

# Usage in script
if ! ping -c 1 google.com &>/dev/null; then
    handle_critical_error "Network connectivity check failed"
fi
```

#### Return Code Management

**Key points:**

- Use meaningful exit codes (0 for success, 1-255 for various errors)
- Document exit codes in script comments
- Check return codes of critical operations
- Use `$?` to capture the last command's exit status

**Example** of comprehensive error handling:

```bash
#!/bin/bash

# Exit codes
readonly SUCCESS=0
readonly ERROR_MISSING_FILE=1
readonly ERROR_NETWORK=2
readonly ERROR_PERMISSIONS=3

# Main function with error handling
main() {
    local config_file="$1"
    
    # Check file existence
    if [[ ! -f "$config_file" ]]; then
        echo "Configuration file not found: $config_file" >&2
        return $ERROR_MISSING_FILE
    fi
    
    # Check file permissions
    if [[ ! -r "$config_file" ]]; then
        echo "Cannot read configuration file: $config_file" >&2
        return $ERROR_PERMISSIONS
    fi
    
    # Process file
    if ! process_config "$config_file"; then
        echo "Failed to process configuration" >&2
        return $ERROR_NETWORK
    fi
    
    return $SUCCESS
}

# Script execution
if ! main "$@"; then
    exit_code=$?
    echo "Script failed with exit code: $exit_code" >&2
    exit $exit_code
fi
```

**Conclusion:** Advanced bash scripting with functions, proper variable scoping, debugging techniques, and robust error handling creates maintainable and reliable automation tools. These practices become essential when developing complex system administration scripts, deployment automation, or any production bash code.

**Next steps:** Consider exploring signal handling with trap commands, advanced parameter expansion techniques, and integration with system logging facilities for production-ready scripts.

---

