## Script Input/Output in Linux


### Command Line Arguments

Command line arguments provide a way to pass data to scripts when they are executed. Linux shell scripts automatically receive these arguments through special variables.

#### Positional Parameters

The shell assigns command line arguments to positional parameters:

- `$0` - The script name itself
- `$1` - First argument
- `$2` - Second argument
- `$3` - Third argument (and so on up to `$9`)
- `${10}` - Tenth argument and beyond require braces

#### Special Parameter Variables

- `$#` - Number of arguments passed to the script
- `$@` - All arguments as separate quoted strings
- `$*` - All arguments as a single string
- `$$` - Process ID of the current shell
- `$?` - Exit status of the last executed command

**Example:**

```bash
#!/bin/bash
echo "Script name: $0"
echo "First argument: $1"
echo "Second argument: $2"
echo "Total arguments: $#"
echo "All arguments: $@"
```

#### Shifting Arguments

The `shift` command moves positional parameters to the left, allowing processing of more than 9 arguments:

```bash
while [ $# -gt 0 ]; do
    echo "Processing: $1"
    shift
done
```

### User Input with `read`

The `read` command captures user input during script execution and stores it in variables.

#### Basic Read Operations

```bash
# Simple input
read username
echo "Hello, $username"

# Prompt with input
read -p "Enter your name: " name
echo "Welcome, $name"

# Multiple variables
read first last
echo "First: $first, Last: $last"
```

#### Read Options and Flags

- `-p "prompt"` - Display prompt before reading
- `-s` - Silent mode (hide input, useful for passwords)
- `-n num` - Read only specified number of characters
- `-t timeout` - Set timeout in seconds
- `-r` - Raw mode (disable backslash escaping)
- `-a array` - Read into array variable

**Example:**

```bash
#!/bin/bash
read -p "Username: " username
read -s -p "Password: " password
echo
read -t 10 -p "Enter choice (10 sec timeout): " choice
```

#### Reading from Files

```bash
# Read line by line from file
while IFS= read -r line; do
    echo "Line: $line"
done < filename.txt

# Read specific fields
while IFS=: read -r user pass uid gid; do
    echo "User: $user, UID: $uid"
done < /etc/passwd
```

### Script Output Formatting

Proper output formatting enhances script usability and readability.

#### Standard Output Streams

- **stdout** (Standard Output) - Normal program output
- **stderr** (Standard Error) - Error messages and diagnostics
- **stdin** (Standard Input) - Input to programs

#### Output Redirection

```bash
# Redirect stdout to file
echo "Success message" > output.log

# Redirect stderr to file
command 2> error.log

# Redirect both stdout and stderr
command > output.log 2>&1

# Append to file
echo "Additional info" >> output.log
```

#### Formatting Techniques

```bash
# Using printf for formatted output
printf "Name: %-20s Age: %3d\n" "$name" "$age"

# Column formatting
printf "%-15s %-10s %-20s\n" "Name" "Age" "Department"
printf "%-15s %-10s %-20s\n" "$name" "$age" "$dept"

# Here documents for multi-line output
cat << EOF
This is a multi-line
output that preserves
formatting and spacing.
EOF
```

#### Color and Style Output

```bash
# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${RED}Error:${NC} Something went wrong"
echo -e "${GREEN}Success:${NC} Operation completed"
echo -e "${YELLOW}Warning:${NC} Check configuration"
```

### Exit Codes and `exit`

Exit codes communicate script execution status to the calling process or shell.

#### Standard Exit Codes

- `0` - Success (no errors)
- `1` - General errors
- `2` - Misuse of shell builtins
- `126` - Command invoked cannot execute
- `127` - Command not found
- `128+n` - Fatal error signal "n"

#### Using Exit Codes

```bash
#!/bin/bash
if [ $# -eq 0 ]; then
    echo "Error: No arguments provided" >&2
    exit 1
fi

# Process arguments
process_data "$1"
if [ $? -ne 0 ]; then
    echo "Failed to process data" >&2
    exit 2
fi

echo "Processing completed successfully"
exit 0
```

#### Checking Exit Codes

```bash
# Check immediately after command
if command; then
    echo "Command succeeded"
else
    echo "Command failed with exit code: $?"
fi

# Store and check exit code
command
exit_code=$?
if [ $exit_code -eq 0 ]; then
    echo "Success"
else
    echo "Failed with code: $exit_code"
fi
```

#### Exit Code Best Practices

- Always use `exit 0` for successful completion
- Use non-zero codes for different error conditions
- Document exit codes in script comments
- Check exit codes of critical commands
- Use `set -e` to exit on any command failure

**Example script demonstrating comprehensive input/output:**

```bash
#!/bin/bash
# File: data_processor.sh
# Usage: ./data_processor.sh <filename> [options]

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check arguments
if [ $# -eq 0 ]; then
    echo -e "${RED}Error:${NC} No filename provided" >&2
    echo "Usage: $0 <filename> [options]" >&2
    exit 1
fi

filename="$1"
shift  # Remove filename from arguments

# Check file existence
if [ ! -f "$filename" ]; then
    echo -e "${RED}Error:${NC} File '$filename' not found" >&2
    exit 2
fi

# Process remaining arguments
while [ $# -gt 0 ]; do
    case "$1" in
        -v|--verbose)
            verbose=true
            ;;
        -o|--output)
            output_file="$2"
            shift
            ;;
        *)
            echo -e "${YELLOW}Warning:${NC} Unknown option '$1'" >&2
            ;;
    esac
    shift
done

# Interactive confirmation
read -p "Process file '$filename'? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Operation cancelled"
    exit 0
fi

# Process file
echo -e "${GREEN}Processing:${NC} $filename"
# ... processing logic here ...

echo -e "${GREEN}Success:${NC} File processed successfully"
exit 0
```

**Key Points:**

- Command line arguments provide flexible script input through positional parameters
- The `read` command enables interactive user input with various formatting options
- Proper output formatting improves script usability and includes color coding and structured display
- Exit codes communicate execution status and enable proper error handling in script chains
- Combining these elements creates robust, user-friendly scripts that handle input validation and provide clear feedback

---

