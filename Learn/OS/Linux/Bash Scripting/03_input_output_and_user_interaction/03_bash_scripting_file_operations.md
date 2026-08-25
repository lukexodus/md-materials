## Bash Scripting File Operations


### Reading from Files Line by Line

Reading files line by line is a fundamental operation in bash scripting. There are several methods, each with different characteristics and use cases.

The most common and reliable method uses a while loop with the `read` command:

```bash
while IFS= read -r line; do
    echo "Processing: $line"
done < filename.txt
```

The `IFS=` prevents leading/trailing whitespace from being trimmed, and `-r` prevents backslash escaping. This method preserves the exact content of each line.

For files without a trailing newline, use this approach:

```bash
while IFS= read -r line || [[ -n "$line" ]]; do
    echo "Processing: $line"
done < filename.txt
```

Alternative methods include using `cat` with a pipe:

```bash
cat filename.txt | while read -r line; do
    echo "Processing: $line"
done
```

However, this creates a subshell, so variables modified inside the loop won't persist outside it.

For processing specific fields from structured data:

```bash
while IFS=':' read -r username password uid gid comment home shell; do
    echo "User: $username, Home: $home"
done < /etc/passwd
```

### Writing to Files Safely

Safe file writing involves preventing data corruption, handling concurrent access, and ensuring atomic operations.

Basic output redirection:

```bash
echo "Hello World" > output.txt
echo "Second line" >> output.txt
```

For safer writes, use temporary files with atomic moves:

```bash
temp_file=$(mktemp)
trap 'rm -f "$temp_file"' EXIT

echo "Critical data" > "$temp_file"
echo "More data" >> "$temp_file"

# Atomic move
mv "$temp_file" final_output.txt
```

When writing multiple lines efficiently:

```bash
{
    echo "Line 1"
    echo "Line 2"
    echo "Line 3"
} > output.txt
```

For appending with file locking (requires `flock`):

```bash
exec 200>>logfile.txt
flock -x 200
echo "$(date): Log entry" >&200
exec 200>&-
```

Here documents provide clean multi-line writing:

```bash
cat > config.txt << 'EOF'
server_name=example.com
port=8080
debug=true
EOF
```

### File Testing and Validation

Bash provides numerous test operators for file validation and system checks.

Common file tests:

```bash
if [[ -f "$filename" ]]; then
    echo "File exists and is a regular file"
fi

if [[ -d "$dirname" ]]; then
    echo "Directory exists"
fi

if [[ -r "$filename" ]]; then
    echo "File is readable"
fi

if [[ -w "$filename" ]]; then
    echo "File is writable"
fi

if [[ -x "$filename" ]]; then
    echo "File is executable"
fi
```

Advanced file property checks:

```bash
if [[ -s "$filename" ]]; then
    echo "File exists and is not empty"
fi

if [[ -L "$filename" ]]; then
    echo "File is a symbolic link"
fi

if [[ "$file1" -nt "$file2" ]]; then
    echo "file1 is newer than file2"
fi

if [[ "$file1" -ot "$file2" ]]; then
    echo "file1 is older than file2"
fi
```

Comprehensive file validation function:

```bash
validate_file() {
    local file="$1"
    local required_perms="${2:-r}"
    
    if [[ ! -e "$file" ]]; then
        echo "Error: File '$file' does not exist"
        return 1
    fi
    
    if [[ ! -f "$file" ]]; then
        echo "Error: '$file' is not a regular file"
        return 1
    fi
    
    case "$required_perms" in
        *r*) [[ ! -r "$file" ]] && { echo "Error: '$file' is not readable"; return 1; } ;;
        *w*) [[ ! -w "$file" ]] && { echo "Error: '$file' is not writable"; return 1; } ;;
        *x*) [[ ! -x "$file" ]] && { echo "Error: '$file' is not executable"; return 1; } ;;
    esac
    
    return 0
}
```

**Example** usage:

```bash
if validate_file "data.txt" "rw"; then
    echo "File is valid and accessible"
else
    echo "File validation failed"
    exit 1
fi
```

### Temporary Files and Cleanup

Proper temporary file management prevents security issues and disk space problems.

Creating temporary files with `mktemp`:

```bash
# Create temporary file
temp_file=$(mktemp)
echo "Temporary data" > "$temp_file"

# Create temporary directory
temp_dir=$(mktemp -d)
touch "$temp_dir/file1.txt"
```

Always set up cleanup using traps:

```bash
temp_file=$(mktemp)
temp_dir=$(mktemp -d)

cleanup() {
    rm -f "$temp_file"
    rm -rf "$temp_dir"
}

trap cleanup EXIT
trap cleanup INT TERM
```

For scripts that need multiple temporary files:

```bash
declare -a temp_files=()
declare -a temp_dirs=()

create_temp_file() {
    local temp_file
    temp_file=$(mktemp)
    temp_files+=("$temp_file")
    echo "$temp_file"
}

create_temp_dir() {
    local temp_dir
    temp_dir=$(mktemp -d)
    temp_dirs+=("$temp_dir")
    echo "$temp_dir"
}

cleanup_all() {
    for file in "${temp_files[@]}"; do
        [[ -f "$file" ]] && rm -f "$file"
    done
    
    for dir in "${temp_dirs[@]}"; do
        [[ -d "$dir" ]] && rm -rf "$dir"
    done
}

trap cleanup_all EXIT
```

Secure temporary file creation with specific permissions:

```bash
temp_file=$(mktemp)
chmod 600 "$temp_file"  # Owner read/write only

# Or create with specific template
temp_file=$(mktemp /tmp/myapp.XXXXXX)
```

**Key points** for temporary file management:

- Always use `mktemp` instead of predictable names
- Set restrictive permissions (600 for files, 700 for directories)
- Use traps to ensure cleanup on script exit
- Clean up in signal handlers for robustness
- Consider using process substitution for pipeline temporary data

### Advanced File Operation Patterns

Atomic file operations using lock files:

```bash
acquire_lock() {
    local lockfile="$1"
    local timeout="${2:-10}"
    
    while ! (set -C; echo $$ > "$lockfile") 2>/dev/null; do
        if [[ $((timeout--)) -le 0 ]]; then
            echo "Failed to acquire lock after timeout"
            return 1
        fi
        sleep 1
    done
    
    trap "rm -f '$lockfile'" EXIT
    return 0
}

if acquire_lock "/tmp/myapp.lock" 30; then
    # Critical section
    echo "Processing with exclusive access"
    sleep 5
else
    echo "Could not acquire lock"
    exit 1
fi
```

Backup and rotation strategies:

```bash
backup_file() {
    local file="$1"
    local backup_dir="${2:-./backups}"
    local max_backups="${3:-5}"
    
    [[ ! -f "$file" ]] && return 1
    
    mkdir -p "$backup_dir"
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$backup_dir/$(basename "$file").$timestamp"
    
    cp "$file" "$backup_file"
    
    # Rotate old backups
    local backup_count
    backup_count=$(find "$backup_dir" -name "$(basename "$file").*" | wc -l)
    
    if [[ $backup_count -gt $max_backups ]]; then
        find "$backup_dir" -name "$(basename "$file").*" -type f -printf '%T@ %p\n' | \
        sort -n | head -n -"$max_backups" | cut -d' ' -f2- | xargs rm -f
    fi
}
```

**Example** of comprehensive file processing script:

```bash
#!/bin/bash

process_data_file() {
    local input_file="$1"
    local output_file="$2"
    
    # Validate input
    if ! validate_file "$input_file" "r"; then
        return 1
    fi
    
    # Create backup
    backup_file "$input_file"
    
    # Process with temporary file
    local temp_file
    temp_file=$(mktemp)
    trap 'rm -f "$temp_file"' EXIT
    
    local line_count=0
    while IFS= read -r line || [[ -n "$line" ]]; do
        ((line_count++))
        
        # Process each line
        processed_line=$(echo "$line" | tr '[:lower:]' '[:upper:]')
        echo "Line $line_count: $processed_line" >> "$temp_file"
        
    done < "$input_file"
    
    # Atomic move to final location
    mv "$temp_file" "$output_file"
    
    echo "Processed $line_count lines from $input_file to $output_file"
}
```

**Next steps** for mastering file operations include exploring file descriptors, named pipes (FIFOs), process substitution, and advanced I/O redirection techniques for complex data processing workflows.

---

