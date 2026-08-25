## Reading User Input


### Read Command Variations

The `read` command is the primary way to capture user input in bash scripts. It offers numerous options for controlling how input is collected and processed.

#### Basic Read Usage

```bash
#!/bin/bash

# Simple input reading
echo "Enter your name:"
read name
echo "Hello, $name!"

# Reading multiple variables
echo "Enter your first and last name:"
read first_name last_name
echo "Welcome, $first_name $last_name!"

# Reading into an array
echo "Enter three colors separated by spaces:"
read -a colors
echo "You entered: ${colors[0]}, ${colors[1]}, ${colors[2]}"
```

#### Read with Prompt (-p option)

```bash
#!/bin/bash

# Inline prompt
read -p "Enter your age: " age
echo "You are $age years old"

# Multi-line prompt
read -p $'Enter your details:\nName: ' name
read -p "Email: " email
echo "Name: $name, Email: $email"

# Prompt with default suggestion
read -p "Enter port number [8080]: " port
port=${port:-8080}
echo "Using port: $port"
```

#### Reading Single Characters (-n option)

```bash
#!/bin/bash

# Read single character
echo "Press any key to continue..."
read -n 1 -s
echo "Continuing..."

# Read specific number of characters
read -p "Enter a 4-digit PIN: " -n 4 pin
echo -e "\nYour PIN is: $pin"

# Menu selection
echo "Select an option:"
echo "1) Start service"
echo "2) Stop service"
echo "3) Restart service"
read -p "Enter choice [1-3]: " -n 1 choice
echo

case $choice in
    1) echo "Starting service..." ;;
    2) echo "Stopping service..." ;;
    3) echo "Restarting service..." ;;
    *) echo "Invalid choice" ;;
esac
```

#### Reading Lines (-r option)

```bash
#!/bin/bash

# Read raw input (preserves backslashes)
echo "Enter a file path (may contain backslashes):"
read -r file_path
echo "Path entered: $file_path"

# Read until delimiter
echo "Enter multiple lines (end with 'END'):"
while IFS= read -r line && [[ $line != "END" ]]; do
    echo "Line: $line"
done
```

#### Reading from Files and Pipes

```bash
#!/bin/bash

# Read from file
while IFS= read -r line; do
    echo "Processing: $line"
done < input.txt

# Read from command output
ls -la | while read -r permissions links owner group size date time name; do
    echo "File: $name (Size: $size bytes)"
done

# Read CSV data
while IFS=',' read -r name age city; do
    echo "Name: $name, Age: $age, City: $city"
done < users.csv
```

#### Advanced Read Options

```bash
#!/bin/bash

# Read with custom delimiter
echo "Enter items separated by semicolons:"
read -d ';' items
echo "Items: $items"

# Read into specific variable name
read -p "Enter username: " -r username
read -p "Enter domain: " -r domain
echo "Email would be: $username@$domain"

# Read with input field separator
echo "Enter name,age,city (comma-separated):"
IFS=',' read -r name age city
echo "Name: $name, Age: $age, City: $city"
```

### Input Validation and Sanitization

Proper input validation is crucial for script security and reliability. Always validate and sanitize user input before using it.

#### Basic Input Validation

```bash
#!/bin/bash

validate_number() {
    local input="$1"
    
    # Check if input is a valid number
    if [[ $input =~ ^[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

validate_email() {
    local email="$1"
    
    # Basic email validation
    if [[ $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Usage example
while true; do
    read -p "Enter your age: " age
    if validate_number "$age" && [[ $age -ge 0 && $age -le 150 ]]; then
        echo "Valid age: $age"
        break
    else
        echo "Please enter a valid age (0-150)"
    fi
done

while true; do
    read -p "Enter your email: " email
    if validate_email "$email"; then
        echo "Valid email: $email"
        break
    else
        echo "Please enter a valid email address"
    fi
done
```

#### Input Sanitization

```bash
#!/bin/bash

sanitize_input() {
    local input="$1"
    
    # Remove leading/trailing whitespace
    input=$(echo "$input" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    # Remove potentially dangerous characters
    input=$(echo "$input" | sed 's/[;&|`$(){}[\]\\]//g')
    
    # Limit length
    if [[ ${#input} -gt 50 ]]; then
        input="${input:0:50}"
    fi
    
    echo "$input"
}

sanitize_filename() {
    local filename="$1"
    
    # Remove path separators and special characters
    filename=$(echo "$filename" | sed 's/[\/\\:*?"<>|]//g')
    
    # Replace spaces with underscores
    filename=$(echo "$filename" | sed 's/ /_/g')
    
    # Ensure it's not empty
    if [[ -z "$filename" ]]; then
        filename="untitled"
    fi
    
    echo "$filename"
}

# Usage examples
read -p "Enter your name: " raw_name
clean_name=$(sanitize_input "$raw_name")
echo "Sanitized name: $clean_name"

read -p "Enter filename: " raw_filename
clean_filename=$(sanitize_filename "$raw_filename")
echo "Sanitized filename: $clean_filename"
```

#### Comprehensive Input Validation Function

```bash
#!/bin/bash

validate_input() {
    local input="$1"
    local type="$2"
    local min_length="${3:-1}"
    local max_length="${4:-100}"
    
    # Check if input is empty
    if [[ -z "$input" ]]; then
        echo "Input cannot be empty"
        return 1
    fi
    
    # Check length
    if [[ ${#input} -lt $min_length || ${#input} -gt $max_length ]]; then
        echo "Input length must be between $min_length and $max_length characters"
        return 1
    fi
    
    # Type-specific validation
    case "$type" in
        "number")
            if ! [[ "$input" =~ ^[0-9]+$ ]]; then
                echo "Input must be a number"
                return 1
            fi
            ;;
        "float")
            if ! [[ "$input" =~ ^[0-9]+\.?[0-9]*$ ]]; then
                echo "Input must be a valid number"
                return 1
            fi
            ;;
        "alpha")
            if ! [[ "$input" =~ ^[a-zA-Z]+$ ]]; then
                echo "Input must contain only letters"
                return 1
            fi
            ;;
        "alphanum")
            if ! [[ "$input" =~ ^[a-zA-Z0-9]+$ ]]; then
                echo "Input must contain only letters and numbers"
                return 1
            fi
            ;;
        "email")
            if ! [[ "$input" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
                echo "Input must be a valid email address"
                return 1
            fi
            ;;
        "url")
            if ! [[ "$input" =~ ^https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/.*)?$ ]]; then
                echo "Input must be a valid URL"
                return 1
            fi
            ;;
        "ip")
            if ! [[ "$input" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
                echo "Input must be a valid IP address"
                return 1
            fi
            # Additional check for valid IP ranges
            IFS='.' read -ra IP_PARTS <<< "$input"
            for part in "${IP_PARTS[@]}"; do
                if [[ $part -gt 255 ]]; then
                    echo "Invalid IP address range"
                    return 1
                fi
            done
            ;;
    esac
    
    return 0
}

# Usage function
get_validated_input() {
    local prompt="$1"
    local type="$2"
    local min_length="${3:-1}"
    local max_length="${4:-100}"
    local input
    
    while true; do
        read -p "$prompt" input
        if validate_input "$input" "$type" "$min_length" "$max_length"; then
            echo "$input"
            return 0
        fi
    done
}

# Examples
name=$(get_validated_input "Enter your name: " "alpha" 2 50)
age=$(get_validated_input "Enter your age: " "number" 1 3)
email=$(get_validated_input "Enter your email: " "email")
website=$(get_validated_input "Enter your website: " "url")
```

### Silent Input (Passwords)

When collecting sensitive information like passwords, use the `-s` (silent) option to prevent echoing input to the terminal.

#### Basic Silent Input

```bash
#!/bin/bash

# Silent input for passwords
read -s -p "Enter password: " password
echo  # New line after silent input
echo "Password entered (${#password} characters)"

# Confirm password
read -s -p "Confirm password: " password_confirm
echo

if [[ "$password" == "$password_confirm" ]]; then
    echo "Passwords match!"
else
    echo "Passwords do not match!"
fi
```

#### Advanced Password Input

```bash
#!/bin/bash

get_password() {
    local prompt="$1"
    local min_length="${2:-8}"
    local password
    local password_confirm
    
    while true; do
        read -s -p "$prompt" password
        echo
        
        # Check minimum length
        if [[ ${#password} -lt $min_length ]]; then
            echo "Password must be at least $min_length characters long"
            continue
        fi
        
        # Check password complexity
        if ! [[ "$password" =~ [A-Z] && "$password" =~ [a-z] && "$password" =~ [0-9] ]]; then
            echo "Password must contain uppercase, lowercase, and numbers"
            continue
        fi
        
        # Confirm password
        read -s -p "Confirm password: " password_confirm
        echo
        
        if [[ "$password" == "$password_confirm" ]]; then
            echo "$password"
            return 0
        else
            echo "Passwords do not match. Try again."
        fi
    done
}

# Usage
echo "Creating new user account..."
read -p "Username: " username
password=$(get_password "Enter password: " 8)
echo "Account created for $username"
```

#### Masked Input (Alternative to Silent)

```bash
#!/bin/bash

# Function to read password with asterisk masking
read_password() {
    local prompt="$1"
    local password=""
    local char
    
    echo -n "$prompt"
    
    while IFS= read -r -s -n 1 char; do
        if [[ $char == $'\0' ]]; then
            break
        elif [[ $char == $'\177' ]]; then
            # Backspace
            if [[ ${#password} -gt 0 ]]; then
                password="${password%?}"
                echo -ne '\b \b'
            fi
        else
            password+="$char"
            echo -n '*'
        fi
    done
    
    echo
    echo "$password"
}

# Usage
password=$(read_password "Enter password: ")
echo "Password entered (${#password} characters)"
```

### Timeouts and Default Values

Control input timing and provide default values to improve user experience and script reliability.

#### Input with Timeout

```bash
#!/bin/bash

# Simple timeout
if read -t 10 -p "Enter your name (10 seconds): " name; then
    echo "Hello, $name!"
else
    echo "Timeout reached. Using default name: Guest"
    name="Guest"
fi

# Timeout with countdown
read_with_countdown() {
    local prompt="$1"
    local timeout="$2"
    local default_value="$3"
    local input
    
    for ((i=timeout; i>0; i--)); do
        echo -ne "\r$prompt($i seconds remaining): "
        if read -t 1 input; then
            echo "$input"
            return 0
        fi
    done
    
    echo -e "\nTimeout reached. Using default: $default_value"
    echo "$default_value"
}

# Usage
name=$(read_with_countdown "Enter your name " 5 "Anonymous")
echo "Using name: $name"
```

#### Default Values with User-Friendly Prompts

```bash
#!/bin/bash

# Function to read input with default value
read_with_default() {
    local prompt="$1"
    local default="$2"
    local input
    
    read -p "$prompt[$default]: " input
    echo "${input:-$default}"
}

# Configuration script example
echo "Server Configuration:"
echo "===================="

server_name=$(read_with_default "Server name " "localhost")
port=$(read_with_default "Port " "8080")
max_connections=$(read_with_default "Max connections " "100")
ssl_enabled=$(read_with_default "Enable SSL (y/n) " "n")

echo
echo "Configuration Summary:"
echo "Server: $server_name"
echo "Port: $port"
echo "Max Connections: $max_connections"
echo "SSL: $ssl_enabled"
```

#### Advanced Timeout and Default Handling

```bash
#!/bin/bash

# Function combining timeout, defaults, and validation
get_input_advanced() {
    local prompt="$1"
    local default="$2"
    local timeout="${3:-30}"
    local validation_type="${4:-any}"
    local input
    local attempt=1
    local max_attempts=3
    
    while [[ $attempt -le $max_attempts ]]; do
        echo -n "$prompt"
        if [[ -n "$default" ]]; then
            echo -n " [$default]"
        fi
        echo -n " (timeout: ${timeout}s): "
        
        if read -t "$timeout" input; then
            # Use default if input is empty
            input="${input:-$default}"
            
            # Validate input
            if validate_input "$input" "$validation_type"; then
                echo "$input"
                return 0
            else
                echo "Invalid input. Attempt $attempt of $max_attempts"
                ((attempt++))
                continue
            fi
        else
            echo -e "\nTimeout reached."
            if [[ -n "$default" ]]; then
                echo "Using default: $default"
                echo "$default"
                return 0
            else
                echo "No default value available."
                return 1
            fi
        fi
    done
    
    echo "Maximum attempts exceeded."
    return 1
}

# Interactive configuration with robust input handling
echo "System Configuration Wizard"
echo "============================"

if hostname=$(get_input_advanced "Hostname" "$(hostname)" 15 "alphanum"); then
    echo "✓ Hostname set to: $hostname"
else
    echo "✗ Failed to set hostname"
    exit 1
fi

if port=$(get_input_advanced "Port number" "8080" 10 "number"); then
    echo "✓ Port set to: $port"
else
    echo "✗ Failed to set port"
    exit 1
fi

if email=$(get_input_advanced "Admin email" "" 20 "email"); then
    echo "✓ Admin email set to: $email"
else
    echo "✗ Failed to set admin email"
    exit 1
fi
```

#### Menu-Driven Input with Timeouts

```bash
#!/bin/bash

# Menu with timeout and default selection
show_menu_with_timeout() {
    local timeout="$1"
    local default="$2"
    local choice
    
    echo "Please select an option:"
    echo "1) Install software"
    echo "2) Update system"
    echo "3) Configure services"
    echo "4) Exit"
    echo
    
    if read -t "$timeout" -p "Enter choice [1-4] (default: $default): " choice; then
        choice="${choice:-$default}"
    else
        echo -e "\nTimeout reached. Using default option: $default"
        choice="$default"
    fi
    
    case "$choice" in
        1) echo "Installing software..." ;;
        2) echo "Updating system..." ;;
        3) echo "Configuring services..." ;;
        4) echo "Exiting..." ;;
        *) echo "Invalid choice: $choice" ;;
    esac
}

# Usage
show_menu_with_timeout 15 "4"
```

**Key points:**

- Use `read -p` for inline prompts and better user experience
- Always validate and sanitize user input before processing
- Use `read -s` for sensitive information like passwords
- Implement timeouts to prevent scripts from hanging indefinitely
- Provide default values to improve usability
- Use appropriate validation patterns for different input types
- Consider input length limits and character restrictions
- Handle edge cases like empty input and special characters
- Combine multiple techniques for robust input handling

Mastering these input reading techniques will help you create interactive scripts that are both user-friendly and secure.

---

