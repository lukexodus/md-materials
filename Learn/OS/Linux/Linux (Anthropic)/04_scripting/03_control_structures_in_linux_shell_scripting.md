## Control Structures in Linux Shell Scripting


### Conditional Statements

#### if Statements

The `if` statement executes commands based on the exit status of a test condition. The basic syntax follows the pattern `if condition; then commands; fi`.

```bash
if [ $USER = "root" ]; then
    echo "Running as root user"
fi

# Multiple conditions
if [ $# -eq 0 ]; then
    echo "No arguments provided"
elif [ $# -eq 1 ]; then
    echo "One argument provided: $1"
else
    echo "Multiple arguments provided: $#"
fi
```

**Key Points:**

- Exit status 0 means true/success
- Non-zero exit status means false/failure
- Square brackets `[ ]` are equivalent to the `test` command
- Double brackets `[[ ]]` provide extended functionality (bash-specific)

#### Test Operators

File test operators check file properties:

```bash
if [ -f "/etc/passwd" ]; then echo "File exists"; fi
if [ -d "/home" ]; then echo "Directory exists"; fi
if [ -r "$file" ]; then echo "File is readable"; fi
if [ -w "$file" ]; then echo "File is writable"; fi
if [ -x "$file" ]; then echo "File is executable"; fi
```

String comparison operators:

```bash
if [ "$string1" = "$string2" ]; then echo "Strings match"; fi
if [ "$string1" != "$string2" ]; then echo "Strings differ"; fi
if [ -z "$string" ]; then echo "String is empty"; fi
if [ -n "$string" ]; then echo "String is not empty"; fi
```

Numeric comparison operators:

```bash
if [ $num1 -eq $num2 ]; then echo "Numbers equal"; fi
if [ $num1 -gt $num2 ]; then echo "num1 greater than num2"; fi
if [ $num1 -lt $num2 ]; then echo "num1 less than num2"; fi
```

#### case Statements

The `case` statement provides multi-way branching based on pattern matching:

```bash
case $1 in
    start)
        echo "Starting service..."
        ;;
    stop)
        echo "Stopping service..."
        ;;
    restart)
        echo "Restarting service..."
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac
```

Pattern matching examples:

```bash
case $filename in
    *.txt)
        echo "Text file"
        ;;
    *.log)
        echo "Log file"
        ;;
    [Aa]*.*)
        echo "File starting with A or a"
        ;;
    ???)
        echo "Three-character filename"
        ;;
esac
```

### Loop Structures

#### for Loops

The `for` loop iterates over lists of items or ranges:

```bash
# Iterate over files
for file in *.txt; do
    echo "Processing $file"
    wc -l "$file"
done

# Iterate over command line arguments
for arg in "$@"; do
    echo "Argument: $arg"
done

# C-style for loop (bash)
for ((i=1; i<=10; i++)); do
    echo "Number: $i"
done

# Iterate over ranges
for num in {1..5}; do
    echo "Count: $num"
done
```

#### while Loops

The `while` loop continues as long as the condition returns true (exit status 0):

```bash
# Basic while loop
counter=1
while [ $counter -le 5 ]; do
    echo "Iteration: $counter"
    counter=$((counter + 1))
done

# Reading file line by line
while IFS= read -r line; do
    echo "Line: $line"
done < /etc/passwd

# Infinite loop with break condition
while true; do
    read -p "Enter command (quit to exit): " cmd
    if [ "$cmd" = "quit" ]; then
        break
    fi
    echo "You entered: $cmd"
done
```

#### until Loops

The `until` loop continues as long as the condition returns false (non-zero exit status):

```bash
# Wait for file to exist
until [ -f "/tmp/ready" ]; do
    echo "Waiting for file..."
    sleep 1
done

# Countdown timer
count=5
until [ $count -eq 0 ]; do
    echo "Countdown: $count"
    count=$((count - 1))
    sleep 1
done
echo "Time's up!"
```

### Loop Control Commands

#### break Command

The `break` command exits the current loop immediately:

```bash
for i in {1..10}; do
    if [ $i -eq 5 ]; then
        echo "Breaking at 5"
        break
    fi
    echo "Number: $i"
done
```

With nested loops, `break n` exits n levels:

```bash
for outer in {1..3}; do
    for inner in {1..3}; do
        if [ $outer -eq 2 ] && [ $inner -eq 2 ]; then
            break 2  # Exit both loops
        fi
        echo "Outer: $outer, Inner: $inner"
    done
done
```

#### continue Command

The `continue` command skips the rest of the current iteration:

```bash
for i in {1..10}; do
    if [ $((i % 2)) -eq 0 ]; then
        continue  # Skip even numbers
    fi
    echo "Odd number: $i"
done
```

### Nested Structures

#### Nested Conditionals

```bash
if [ -f "$1" ]; then
    if [ -r "$1" ]; then
        echo "File exists and is readable"
        if [ -s "$1" ]; then
            echo "File is not empty"
        else
            echo "File is empty"
        fi
    else
        echo "File exists but is not readable"
    fi
else
    echo "File does not exist"
fi
```

#### Nested Loops

```bash
# Multiplication table
for i in {1..5}; do
    for j in {1..5}; do
        result=$((i * j))
        printf "%2d " $result
    done
    echo
done

# Processing directory structure
for dir in */; do
    if [ -d "$dir" ]; then
        echo "Directory: $dir"
        for file in "$dir"*; do
            if [ -f "$file" ]; then
                echo "  File: $(basename "$file")"
            fi
        done
    fi
done
```

#### Mixed Nested Structures

```bash
for user in $(cut -d: -f1 /etc/passwd); do
    case $user in
        root|daemon|bin)
            echo "System user: $user"
            ;;
        *)
            if id "$user" &>/dev/null; then
                groups=$(groups "$user" 2>/dev/null)
                if [ $? -eq 0 ]; then
                    echo "User $user belongs to: $groups"
                fi
            fi
            ;;
    esac
done
```

### Advanced Control Flow Patterns

#### Function with Control Structures

```bash
process_files() {
    local directory="$1"
    
    if [ ! -d "$directory" ]; then
        echo "Error: Directory $directory does not exist"
        return 1
    fi
    
    for file in "$directory"/*; do
        if [ -f "$file" ]; then
            case "${file##*.}" in
                txt|log)
                    echo "Processing text file: $file"
                    while IFS= read -r line; do
                        if [[ $line =~ ERROR ]]; then
                            echo "Found error: $line"
                        fi
                    done < "$file"
                    ;;
                *)
                    continue
                    ;;
            esac
        fi
    done
}
```

#### Error Handling with Control Structures

```bash
backup_files() {
    local source_dir="$1"
    local backup_dir="$2"
    
    # Input validation
    if [ $# -ne 2 ]; then
        echo "Usage: backup_files <source> <destination>"
        return 1
    fi
    
    # Create backup directory if it doesn't exist
    if [ ! -d "$backup_dir" ]; then
        if ! mkdir -p "$backup_dir"; then
            echo "Error: Cannot create backup directory"
            return 1
        fi
    fi
    
    # Process files
    for file in "$source_dir"/*; do
        if [ -f "$file" ]; then
            if cp "$file" "$backup_dir/"; then
                echo "Backed up: $(basename "$file")"
            else
                echo "Failed to backup: $(basename "$file")"
                continue
            fi
        fi
    done
}
```

**Key Points:**

- Always quote variables to prevent word splitting
- Use `[[ ]]` for advanced pattern matching in bash
- Test exit status with `$?` variable
- Use `set -e` to exit on any command failure
- Combine control structures for complex logic flows

**Example** of comprehensive script using multiple control structures:

```bash
#!/bin/bash
set -e

main() {
    local action="$1"
    local target="$2"
    
    case "$action" in
        monitor)
            monitor_system "$target"
            ;;
        cleanup)
            cleanup_logs "$target"
            ;;
        *)
            echo "Usage: $0 {monitor|cleanup} <target>"
            exit 1
            ;;
    esac
}

monitor_system() {
    local threshold="${1:-80}"
    
    while true; do
        local usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
        
        if [ "$usage" -gt "$threshold" ]; then
            echo "Warning: Disk usage at ${usage}%"
            break
        fi
        
        sleep 60
    done
}

main "$@"
```

Control structures form the foundation of shell script logic, enabling complex decision-making and repetitive operations essential for system administration and automation tasks.

---

