## Conditional Statements


### Basic if/then/else Structure

The fundamental conditional structure in bash follows the pattern:

```bash
if [ condition ]; then
    # commands
elif [ another_condition ]; then
    # commands
else
    # commands
fi
```

The `if` statement must be closed with `fi` (if backwards). The semicolon after the condition is required when the `then` keyword appears on the same line, or you can place `then` on a separate line without the semicolon.

### Test Command and Brackets

Bash provides multiple ways to test conditions:

**Single brackets `[ ]`** - This is the traditional POSIX-compliant test command. It's actually an alias for the `test` command.

**Double brackets `[[ ]]`** - This is a bash-specific enhancement that provides more features and is generally safer to use.

**Double parentheses `(( ))`** - Used specifically for arithmetic operations and comparisons.

```bash
# Single brackets
if [ "$var" = "value" ]; then
    echo "Match found"
fi

# Double brackets
if [[ $var == "value" ]]; then
    echo "Match found"
fi

# Double parentheses
if (( var > 10 )); then
    echo "Number is greater than 10"
fi
```

### String Comparison Operators

**Equality and Inequality:**

- `=` or `==` - Equal to (use `=` for POSIX compliance)
- `!=` - Not equal to
- `<` - Less than (lexicographically)
- `>` - Greater than (lexicographically)

**Pattern Matching (double brackets only):**

- `==` with wildcards - Pattern matching
- `=~` - Regular expression matching

**String Tests:**

- `-z` - String is empty (zero length)
- `-n` - String is not empty

```bash
# Basic string comparison
if [ "$name" = "John" ]; then
    echo "Hello John"
fi

# Case-insensitive comparison (using parameter expansion)
if [[ "${name,,}" == "john" ]]; then
    echo "Hello John (case insensitive)"
fi

# Pattern matching
if [[ $filename == *.txt ]]; then
    echo "Text file detected"
fi

# Regular expression
if [[ $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    echo "Valid email format"
fi

# Empty string check
if [ -z "$var" ]; then
    echo "Variable is empty"
fi
```

### Numeric Comparison Operators

**Within single/double brackets:**

- `-eq` - Equal to
- `-ne` - Not equal to
- `-gt` - Greater than
- `-ge` - Greater than or equal to
- `-lt` - Less than
- `-le` - Less than or equal to

**Within double parentheses:**

- `==` - Equal to
- `!=` - Not equal to
- `>` - Greater than
- `>=` - Greater than or equal to
- `<` - Less than
- `<=` - Less than or equal to

```bash
# Using test operators
if [ "$num" -gt 10 ]; then
    echo "Number is greater than 10"
fi

# Using arithmetic operators
if (( num > 10 )); then
    echo "Number is greater than 10"
fi

# Multiple conditions
if (( num >= 10 && num <= 20 )); then
    echo "Number is between 10 and 20"
fi
```

### File Test Operators

Bash provides extensive file testing capabilities:

**File Existence and Type:**

- `-e` - File exists
- `-f` - Regular file exists
- `-d` - Directory exists
- `-L` - Symbolic link exists
- `-S` - Socket exists
- `-p` - Named pipe exists
- `-b` - Block device exists
- `-c` - Character device exists

**File Permissions:**

- `-r` - File is readable
- `-w` - File is writable
- `-x` - File is executable
- `-u` - File has setuid bit set
- `-g` - File has setgid bit set
- `-k` - File has sticky bit set

**File Properties:**

- `-s` - File exists and is not empty
- `-O` - File is owned by current user
- `-G` - File is owned by current group
- `-N` - File was modified since last read

**File Comparison:**

- `file1 -nt file2` - file1 is newer than file2
- `file1 -ot file2` - file1 is older than file2
- `file1 -ef file2` - file1 and file2 refer to the same file

```bash
# Check if file exists and is readable
if [ -f "$filename" ] && [ -r "$filename" ]; then
    echo "File exists and is readable"
fi

# Check directory
if [ -d "$directory" ]; then
    echo "Directory exists"
else
    mkdir -p "$directory"
    echo "Directory created"
fi

# Check file age
if [ "backup.tar" -ot "data.txt" ]; then
    echo "Backup is older than data, need to update"
fi
```

### Logical Operators

**AND Operator (`&&`):**

- Both conditions must be true
- Short-circuit evaluation (if first condition is false, second is not evaluated)

**OR Operator (`||`):**

- At least one condition must be true
- Short-circuit evaluation (if first condition is true, second is not evaluated)

**NOT Operator (`!`):**

- Negates the condition

```bash
# AND operator
if [ "$user" = "admin" ] && [ "$pass" = "secret" ]; then
    echo "Access granted"
fi

# OR operator
if [ "$day" = "Saturday" ] || [ "$day" = "Sunday" ]; then
    echo "It's weekend"
fi

# NOT operator
if [ ! -f "$configfile" ]; then
    echo "Config file not found"
fi

# Complex logical expressions
if [[ ! -z "$var" && ( "$var" == "yes" || "$var" == "y" ) ]]; then
    echo "User confirmed"
fi
```

### Advanced Conditional Constructs

**Case Statement:**

```bash
case "$variable" in
    pattern1)
        commands
        ;;
    pattern2|pattern3)
        commands
        ;;
    *)
        default commands
        ;;
esac
```

**Conditional Execution:**

```bash
# Short-circuit AND
[ -f "$file" ] && echo "File exists"

# Short-circuit OR
[ -f "$file" ] || echo "File does not exist"

# Ternary-like operation
[ "$debug" = "true" ] && echo "Debug mode" || echo "Normal mode"
```

### Exit Status Testing

Every command in bash returns an exit status (0 for success, non-zero for failure). You can test this directly:

```bash
# Test command success
if command; then
    echo "Command succeeded"
else
    echo "Command failed"
fi

# Test specific exit code
if ! grep "pattern" file.txt > /dev/null; then
    echo "Pattern not found"
fi

# Using exit status variable
command
if [ $? -eq 0 ]; then
    echo "Success"
fi
```

### Nested Conditionals

```bash
if [ "$user_type" = "admin" ]; then
    if [ "$action" = "delete" ]; then
        if [ -f "$target_file" ]; then
            echo "Deleting $target_file"
            rm "$target_file"
        else
            echo "File not found"
        fi
    else
        echo "Action not permitted"
    fi
else
    echo "Access denied"
fi
```

### Common Pitfalls and Best Practices

**Always quote variables** to prevent word splitting:

```bash
# Wrong
if [ $var = "value" ]; then

# Correct
if [ "$var" = "value" ]; then
```

**Use double brackets for enhanced features:**

```bash
# Supports pattern matching and regex
if [[ $filename == *.log ]]; then
    echo "Log file detected"
fi
```

**Handle empty variables properly:**

```bash
# Safe way to check if variable is set and not empty
if [ -n "${var:-}" ]; then
    echo "Variable is set"
fi
```

**Use appropriate comparison operators:**

```bash
# For strings, use = or ==
if [ "$str1" = "$str2" ]; then

# For numbers, use arithmetic operators
if (( num1 > num2 )); then
```

**Key points:**

- Always use proper quoting around variables
- Choose the right test construct for your needs
- Use double brackets `[[ ]]` for enhanced bash features
- Use double parentheses `(( ))` for arithmetic comparisons
- Remember that `test` and `[` are the same command
- Exit status 0 means success, non-zero means failure

**Example:**

```bash
#!/bin/bash

# Comprehensive conditional example
check_system() {
    local user="$1"
    local action="$2"
    local target="$3"
    
    # Check if user is provided
    if [ -z "$user" ]; then
        echo "Error: User not specified"
        return 1
    fi
    
    # Check user permissions
    if [[ "$user" == "root" || "$user" == "admin" ]]; then
        echo "Admin user detected"
        
        # Check action type
        case "$action" in
            "read")
                if [ -r "$target" ]; then
                    echo "Reading $target"
                    cat "$target"
                else
                    echo "Cannot read $target"
                fi
                ;;
            "write")
                if [ -w "$target" ] || [ ! -e "$target" ]; then
                    echo "Writing to $target"
                    echo "Data" > "$target"
                else
                    echo "Cannot write to $target"
                fi
                ;;
            "delete")
                if [ -f "$target" ]; then
                    echo "Deleting $target"
                    rm "$target"
                elif [ -d "$target" ]; then
                    echo "Removing directory $target"
                    rmdir "$target" 2>/dev/null || echo "Directory not empty"
                else
                    echo "Target not found"
                fi
                ;;
            *)
                echo "Unknown action: $action"
                ;;
        esac
    else
        echo "Access denied for user: $user"
    fi
}

# Usage
check_system "admin" "read" "/etc/passwd"
```

Conditional statements form the backbone of bash script logic, enabling scripts to make decisions based on system state, user input, file conditions, and command results. Understanding these constructs thoroughly allows for creating robust, intelligent scripts that can handle various scenarios gracefully.

---

