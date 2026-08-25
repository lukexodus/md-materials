## Loops


### For Loops (C-style and Range)

Bash supports multiple for loop syntaxes, each suited for different use cases. The traditional range-based for loop iterates over lists or ranges, while C-style for loops provide more control over initialization, condition, and increment operations.

**Key points:**

- Range-based for loops iterate over word lists, arrays, or command output
- C-style for loops use three expressions: initialization, condition, increment
- Brace expansion creates numeric and character ranges
- Command substitution can provide dynamic lists
- Pathname expansion (globbing) works with for loops

**Example:**

```bash
# Basic range-based for loop
for item in apple banana cherry; do
    echo "Fruit: $item"
done

# Numeric range with brace expansion
for num in {1..10}; do
    echo "Number: $num"
done

# Step increment in range
for num in {0..20..2}; do
    echo "Even number: $num"
done

# Character range
for letter in {a..z}; do
    echo "Letter: $letter"
done

# Array iteration
fruits=("apple" "banana" "cherry" "date")
for fruit in "${fruits[@]}"; do
    echo "Processing: $fruit"
done

# File iteration with globbing
for file in *.txt; do
    if [[ -f "$file" ]]; then
        echo "Processing file: $file"
    fi
done

# Command substitution
for user in $(cut -d: -f1 /etc/passwd); do
    echo "User: $user"
done

# C-style for loop
for ((i=0; i<10; i++)); do
    echo "Index: $i"
done

# C-style with multiple variables
for ((i=0, j=10; i<j; i++, j--)); do
    echo "i=$i, j=$j"
done

# Reverse iteration
for ((i=10; i>=1; i--)); do
    echo "Countdown: $i"
done
```

### While and Until Loops

While loops execute as long as a condition remains true, whereas until loops execute until a condition becomes true. Both loops are essential for conditional iteration and processing input streams.

**Key points:**

- While loops test condition before each iteration
- Until loops are the logical opposite of while loops
- Both support complex conditions using test operators
- Infinite loops require explicit break statements
- Input redirection works with while loops for file processing

**Example:**

```bash
# Basic while loop
counter=1
while [[ $counter -le 5 ]]; do
    echo "Counter: $counter"
    ((counter++))
done

# Reading file line by line
while IFS= read -r line; do
    echo "Line: $line"
done < "input.txt"

# Reading with field separation
while IFS=':' read -r user pass uid gid gecos home shell; do
    echo "User: $user, Home: $home, Shell: $shell"
done < /etc/passwd

# Infinite loop with break condition
while true; do
    echo -n "Enter command (quit to exit): "
    read -r command
    
    if [[ "$command" == "quit" ]]; then
        break
    fi
    
    echo "You entered: $command"
done

# Until loop (opposite of while)
counter=1
until [[ $counter -gt 5 ]]; do
    echo "Counter: $counter"
    ((counter++))
done

# Until loop waiting for condition
until [[ -f "important_file.txt" ]]; do
    echo "Waiting for file to appear..."
    sleep 1
done
echo "File found!"

# Complex condition with logical operators
attempts=0
max_attempts=3
until [[ $attempts -eq $max_attempts ]] || [[ -f "success.flag" ]]; do
    echo "Attempt $((attempts + 1)): Running process..."
    # Simulate some process
    sleep 1
    ((attempts++))
done

# Process monitoring loop
while pgrep -f "my_process" > /dev/null; do
    echo "Process is running..."
    sleep 5
done
echo "Process has stopped"
```

### Loop Control (Break and Continue)

Loop control statements alter the normal flow of loop execution. The `break` statement terminates the loop entirely, while `continue` skips the current iteration and proceeds to the next one.

**Key points:**

- `break` exits the innermost loop completely
- `continue` skips remaining statements in current iteration
- Both commands accept numeric arguments for nested loops
- Loop control enables complex conditional logic
- Use sparingly to maintain code readability

**Example:**

```bash
# Basic break usage
for num in {1..10}; do
    if [[ $num -eq 5 ]]; then
        echo "Breaking at $num"
        break
    fi
    echo "Number: $num"
done

# Basic continue usage
for num in {1..10}; do
    if [[ $((num % 2)) -eq 0 ]]; then
        continue  # Skip even numbers
    fi
    echo "Odd number: $num"
done

# Break with levels (nested loops)
for i in {1..3}; do
    echo "Outer loop: $i"
    for j in {1..5}; do
        if [[ $j -eq 3 ]]; then
            echo "Breaking inner loop at j=$j"
            break
        fi
        echo "  Inner loop: $j"
    done
done

# Continue with levels
for i in {1..3}; do
    echo "Outer loop: $i"
    for j in {1..5}; do
        if [[ $j -eq 3 ]]; then
            echo "  Skipping j=$j"
            continue
        fi
        echo "  Inner loop: $j"
    done
done

# Break outer loop from inner loop
for i in {1..5}; do
    echo "Outer: $i"
    for j in {1..5}; do
        if [[ $i -eq 3 && $j -eq 2 ]]; then
            echo "Breaking outer loop"
            break 2  # Break two levels
        fi
        echo "  Inner: $j"
    done
done

# Menu system with break
while true; do
    echo "1. Option 1"
    echo "2. Option 2"
    echo "3. Exit"
    read -r choice
    
    case $choice in
        1)
            echo "Option 1 selected"
            ;;
        2)
            echo "Option 2 selected"
            ;;
        3)
            echo "Exiting..."
            break
            ;;
        *)
            echo "Invalid choice"
            continue
            ;;
    esac
done

# Processing with error handling
files=("file1.txt" "file2.txt" "file3.txt")
for file in "${files[@]}"; do
    if [[ ! -f "$file" ]]; then
        echo "Warning: $file not found, skipping"
        continue
    fi
    
    if [[ ! -r "$file" ]]; then
        echo "Error: Cannot read $file, aborting"
        break
    fi
    
    echo "Processing $file"
    # Process file here
done
```

### Nested Loops and Best Practices

Nested loops combine multiple iteration levels but require careful design to maintain performance and readability. Proper structure and optimization techniques prevent common pitfalls.

**Key points:**

- Limit nesting depth to maintain readability
- Use meaningful variable names for each loop level
- Consider loop order for performance optimization
- Break complex nested loops into functions
- Use appropriate loop types for each level

**Example:**

```bash
# Matrix processing with nested loops
matrix=(
    "1 2 3"
    "4 5 6"
    "7 8 9"
)

echo "Processing matrix:"
for row in "${!matrix[@]}"; do
    echo "Row $row:"
    IFS=' ' read -ra elements <<< "${matrix[$row]}"
    for col in "${!elements[@]}"; do
        echo "  [${row}][${col}] = ${elements[$col]}"
    done
done

# Multiplication table
echo "Multiplication Table:"
for ((i=1; i<=10; i++)); do
    for ((j=1; j<=10; j++)); do
        printf "%4d" $((i * j))
    done
    echo
done

# File comparison across directories
dirs=("dir1" "dir2" "dir3")
for dir in "${dirs[@]}"; do
    if [[ -d "$dir" ]]; then
        echo "Processing directory: $dir"
        for file in "$dir"/*; do
            if [[ -f "$file" ]]; then
                echo "  File: $(basename "$file")"
                echo "  Size: $(stat -c%s "$file" 2>/dev/null || echo "unknown")"
            fi
        done
    fi
done

# Optimized nested loop (outer loop smaller)
# Good: fewer outer iterations
users=("admin" "user1" "user2")
actions=("read" "write" "execute" "delete" "modify")

for user in "${users[@]}"; do
    echo "User: $user"
    for action in "${actions[@]}"; do
        echo "  Checking $action permission"
    done
done

# Function to reduce nesting complexity
process_directory() {
    local dir=$1
    local pattern=$2
    
    if [[ ! -d "$dir" ]]; then
        return 1
    fi
    
    for file in "$dir"/*; do
        if [[ -f "$file" && "$file" =~ $pattern ]]; then
            echo "Processing: $file"
            # Process file
        fi
    done
}

# Using function instead of deep nesting
directories=("logs" "data" "config")
for dir in "${directories[@]}"; do
    process_directory "$dir" "\.txt$"
done

# Efficient loop with early termination
found=false
for ((i=1; i<=100 && !found; i++)); do
    for ((j=1; j<=100 && !found; j++)); do
        if [[ $((i * j)) -eq 2024 ]]; then
            echo "Found: $i * $j = 2024"
            found=true
        fi
    done
done

# Parallel processing pattern
process_item() {
    local item=$1
    echo "Processing $item in background"
    sleep 1
    echo "$item completed"
}

# Sequential nested loops
items=("item1" "item2" "item3")
tasks=("task1" "task2" "task3")

for item in "${items[@]}"; do
    for task in "${tasks[@]}"; do
        echo "Running $task on $item"
        # process_item "$item-$task" &  # Uncomment for parallel
    done
done
# wait  # Uncomment when using parallel processing
```

**Best practices for nested loops:**

```bash
# Use meaningful variable names
for server in "${servers[@]}"; do
    for service in "${services[@]}"; do
        # Clear what each loop does
    done
done

# Limit nesting depth
# Bad: too many levels
for a in "${array_a[@]}"; do
    for b in "${array_b[@]}"; do
        for c in "${array_c[@]}"; do
            for d in "${array_d[@]}"; do
                # Too deep
            done
        done
    done
done

# Good: break into functions
process_level_one() {
    local item=$1
    for sub_item in "${sub_items[@]}"; do
        process_level_two "$item" "$sub_item"
    done
}

process_level_two() {
    local item=$1
    local sub_item=$2
    # Processing logic here
}

# Performance considerations
# Put smaller loop outside when possible
for small_array_item in "${small_array[@]}"; do
    for large_array_item in "${large_array[@]}"; do
        # Process
    done
done

# Early exit conditions
for ((i=0; i<1000; i++)); do
    for ((j=0; j<1000; j++)); do
        if [[ condition_met ]]; then
            break 2  # Exit both loops
        fi
    done
done

# Memory considerations for large datasets
# Use while loops for large files instead of loading into arrays
while IFS= read -r line1; do
    while IFS= read -r line2 <&3; do
        # Compare lines
    done 3< "second_file.txt"
done < "first_file.txt"
```

**Loop performance optimization:**

```bash
# Avoid command substitution in loop conditions
# Bad: executes command each iteration
while [[ $(ps aux | grep process | wc -l) -gt 1 ]]; do
    sleep 1
done

# Good: store result and update when needed
process_count=$(ps aux | grep process | wc -l)
while [[ $process_count -gt 1 ]]; do
    sleep 1
    process_count=$(ps aux | grep process | wc -l)
done

# Use arithmetic evaluation instead of external commands
# Bad: calls external command
for ((i=1; i<=100; i++)); do
    if [[ $(expr $i % 10) -eq 0 ]]; then
        echo "Multiple of 10: $i"
    fi
done

# Good: use built-in arithmetic
for ((i=1; i<=100; i++)); do
    if [[ $((i % 10)) -eq 0 ]]; then
        echo "Multiple of 10: $i"
    fi
done
```

Important related topics include loop optimization techniques, parallel processing with background jobs, signal handling in loops, and advanced iteration patterns with associative arrays.

---

