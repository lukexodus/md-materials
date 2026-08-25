## Variables and Assignment


### Variable Declaration and Naming Conventions

In bash, variables are created by assignment without any special declaration syntax. Variables store data that can be referenced and modified throughout your script.

#### Basic Variable Assignment

```bash
# Basic assignment (no spaces around =)
name="John"
age=25
city="New York"

# Using variables
echo "Name: $name"
echo "Age: $age"
echo "City: $city"
```

#### Variable Naming Rules

Bash variable names must follow these rules:

- Must start with a letter or underscore
- Can contain letters, numbers, and underscores
- Cannot contain spaces or special characters
- Case-sensitive (NAME and name are different)

```bash
# Valid variable names
user_name="alice"
_private_var="secret"
DATABASE_URL="localhost"
counter1=0

# Invalid variable names
# 2user="bob"        # Cannot start with number
# user-name="charlie" # Cannot contain hyphen
# user name="david"   # Cannot contain space
```

#### Naming Conventions

**Best practices for variable naming:**

- Use lowercase for local variables: `user_name`, `file_path`
- Use uppercase for constants and environment variables: `MAX_RETRIES`, `CONFIG_FILE`
- Use descriptive names: `database_connection` instead of `db_conn`
- Use underscores for multi-word variables: `user_home_directory`

```bash
#!/bin/bash

# Constants (uppercase)
readonly MAX_ATTEMPTS=3
readonly CONFIG_FILE="/etc/myapp/config.conf"

# Local variables (lowercase)
current_user=$(whoami)
temp_directory="/tmp/myapp"
log_file="$temp_directory/app.log"

# Function-scoped variables
process_file() {
    local file_name="$1"
    local line_count=$(wc -l < "$file_name")
    echo "File $file_name has $line_count lines"
}
```

#### Variable Assignment Methods

```bash
# Direct assignment
username="admin"

# Command substitution
current_date=$(date)
file_count=$(ls -1 | wc -l)

# Arithmetic assignment
counter=$((counter + 1))
result=$((10 * 5))

# Array assignment
fruits=("apple" "banana" "orange")
colors[0]="red"
colors[1]="green"

# Parameter expansion with defaults
config_file="${CONFIG_FILE:-/etc/default.conf}"
port_number="${PORT:-8080}"
```

### Local vs Global Variables

Understanding variable scope is crucial for writing maintainable bash scripts, especially when using functions.

#### Global Variables

By default, all variables in bash are global, meaning they can be accessed and modified from anywhere in the script.

```bash
#!/bin/bash

# Global variables
global_counter=0
application_name="MyApp"

increment_counter() {
    global_counter=$((global_counter + 1))
    echo "Counter is now: $global_counter"
}

main() {
    echo "Application: $application_name"
    increment_counter
    increment_counter
    echo "Final counter value: $global_counter"
}

main
```

#### Local Variables

Use the `local` keyword to create variables that exist only within a function's scope.

```bash
#!/bin/bash

global_var="I'm global"

demonstrate_scope() {
    local local_var="I'm local"
    local global_var="I'm local override"
    
    echo "Inside function:"
    echo "  local_var: $local_var"
    echo "  global_var: $global_var"
}

demonstrate_scope

echo "Outside function:"
echo "  global_var: $global_var"
# echo "  local_var: $local_var"  # This would be empty/undefined
```

#### Best Practices for Variable Scope

```bash
#!/bin/bash

# Global configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly LOG_FILE="/var/log/${SCRIPT_NAME}.log"

# Function with proper local variable usage
process_user_data() {
    local username="$1"
    local user_id="$2"
    local temp_file="/tmp/user_${user_id}.tmp"
    
    # Local variables don't affect global scope
    local log_message="Processing user: $username (ID: $user_id)"
    
    echo "$log_message" >> "$LOG_FILE"
    echo "User data processed for $username"
    
    # Clean up local temporary file
    rm -f "$temp_file"
}

# Global variables remain accessible
process_user_data "alice" "1001"
process_user_data "bob" "1002"
```

### Environment Variables and Export

Environment variables are special variables that are available to all processes spawned from the current shell.

#### Understanding Environment Variables

```bash
# View all environment variables
env

# View specific environment variables
echo $HOME
echo $PATH
echo $USER
echo $SHELL
```

#### Creating Environment Variables with Export

```bash
#!/bin/bash

# Regular variable (not inherited by child processes)
local_var="not exported"

# Environment variable (inherited by child processes)
export GLOBAL_VAR="exported variable"

# Alternative syntax
export DATABASE_URL="postgresql://localhost:5432/mydb"
export DEBUG_MODE="true"

# Export existing variable
api_key="secret123"
export api_key

# Verify exports
echo "Local variable: $local_var"
echo "Environment variable: $GLOBAL_VAR"
```

#### Environment Variable Inheritance

```bash
#!/bin/bash

# Parent script
export PARENT_VAR="I'm from parent"
regular_var="I'm not exported"

# Child script will inherit PARENT_VAR but not regular_var
./child_script.sh

# child_script.sh content:
# #!/bin/bash
# echo "Parent var: $PARENT_VAR"        # Will print value
# echo "Regular var: $regular_var"      # Will be empty
```

#### Common Environment Variables

```bash
# System environment variables
echo "Home directory: $HOME"
echo "Current user: $USER"
echo "Shell: $SHELL"
echo "Path: $PATH"
echo "Working directory: $PWD"
echo "Previous directory: $OLDPWD"

# Application-specific environment variables
export APP_ENV="production"
export LOG_LEVEL="info"
export MAX_CONNECTIONS="100"
export DATABASE_PASSWORD="$secret_password"
```

#### Unsetting Variables

```bash
# Create variables
test_var="hello"
export TEST_ENV="world"

# Unset regular variable
unset test_var

# Unset environment variable
unset TEST_ENV

# Verify they're gone
echo "test_var: '$test_var'"      # Empty
echo "TEST_ENV: '$TEST_ENV'"      # Empty
```

### Special Variables

Bash provides several special variables that contain information about the script execution context and command-line arguments.

#### Script Information Variables

```bash
#!/bin/bash

echo "Script name: $0"
echo "Script PID: $$"
echo "Number of arguments: $#"
echo "All arguments: $@"
echo "All arguments as single string: $*"
echo "Last command exit status: $?"
```

#### Command-Line Argument Variables

```bash
#!/bin/bash
# Script: example.sh
# Usage: ./example.sh arg1 arg2 arg3

echo "Script name: $0"
echo "First argument: $1"
echo "Second argument: $2"
echo "Third argument: $3"
echo "Number of arguments: $#"

# Loop through all arguments
echo "All arguments:"
for arg in "$@"; do
    echo "  - $arg"
done
```

**Example** usage and output:

```bash
$ ./example.sh hello world "test string"
Script name: ./example.sh
First argument: hello
Second argument: world
Third argument: test string
Number of arguments: 3
All arguments:
  - hello
  - world
  - test string
```

#### Exit Status Variable ($?)

```bash
#!/bin/bash

# Command that succeeds
ls /etc/passwd
echo "ls exit status: $?"

# Command that fails
ls /nonexistent/directory 2>/dev/null
echo "ls exit status: $?"

# Function with return value
check_file() {
    if [[ -f "$1" ]]; then
        echo "File exists: $1"
        return 0
    else
        echo "File not found: $1"
        return 1
    fi
}

check_file "/etc/passwd"
echo "Function exit status: $?"

check_file "/nonexistent/file"
echo "Function exit status: $?"
```

#### Process ID Variables

```bash
#!/bin/bash

echo "Current script PID: $$"
echo "Parent process PID: $PPID"

# Background process
sleep 10 &
background_pid=$!
echo "Background process PID: $background_pid"

# Wait for background process
wait $background_pid
echo "Background process completed with status: $?"
```

#### Advanced Special Variable Usage

```bash
#!/bin/bash

# Argument processing with special variables
process_arguments() {
    echo "Processing $# arguments"
    
    if [[ $# -eq 0 ]]; then
        echo "No arguments provided"
        return 1
    fi
    
    local arg_count=1
    for arg in "$@"; do
        echo "Argument $arg_count: $arg"
        ((arg_count++))
    done
    
    return 0
}

# Shift arguments
demonstrate_shift() {
    echo "Before shift: $# arguments"
    echo "First argument: $1"
    
    shift  # Remove first argument
    
    echo "After shift: $# arguments"
    echo "New first argument: $1"
}

# Default argument handling
handle_arguments() {
    local input_file="${1:-input.txt}"
    local output_file="${2:-output.txt}"
    local verbose="${3:-false}"
    
    echo "Input file: $input_file"
    echo "Output file: $output_file"
    echo "Verbose mode: $verbose"
}

# Test functions
process_arguments "$@"
demonstrate_shift "first" "second" "third"
handle_arguments  # Uses defaults
handle_arguments "data.txt" "result.txt" "true"
```

#### Variable Expansion Techniques

```bash
#!/bin/bash

filename="document.txt"

# Basic expansion
echo "Filename: $filename"
echo "Filename: ${filename}"

# Length of variable
echo "Length: ${#filename}"

# Substring extraction
echo "First 3 chars: ${filename:0:3}"
echo "Extension: ${filename: -3}"

# Pattern matching
echo "Without extension: ${filename%.txt}"
echo "With .bak extension: ${filename%.txt}.bak"

# Default values
echo "Config file: ${CONFIG_FILE:-/etc/default.conf}"
echo "Port: ${PORT:=8080}"

# Array expansion
files=("file1.txt" "file2.txt" "file3.txt")
echo "All files: ${files[@]}"
echo "First file: ${files[0]}"
echo "Number of files: ${#files[@]}"
```

**Key points:**

- Variables are created by assignment without declaration
- Follow naming conventions for readability and maintainability
- Use `local` keyword for function-scoped variables
- Use `export` to make variables available to child processes
- Special variables provide script context and argument information
- Proper variable scoping prevents conflicts and improves code quality
- Environment variables are inherited by child processes
- Exit status ($?) is crucial for error handling and flow control

Understanding these variable concepts is essential for writing robust bash scripts that handle data correctly and interact properly with the system environment.

---

