## Advanced Function Concepts


### Recursive Functions

Recursive functions call themselves to solve problems by breaking them down into smaller, similar subproblems. In bash, recursion requires careful management of the call stack and proper base case handling to prevent infinite loops.

**Key points:**

- Every recursive function must have a base case to terminate recursion
- Bash has limited call stack depth (typically around 1000 calls)
- Local variables prevent variable collision between recursive calls
- Tail recursion optimization is not available in bash
- Use iterative solutions when possible for better performance

**Example:**

```bash
# Factorial calculation
factorial() {
    local n=$1
    
    # Base case
    if [[ $n -le 1 ]]; then
        echo 1
        return
    fi
    
    # Recursive case
    local prev_result
    prev_result=$(factorial $((n - 1)))
    echo $((n * prev_result))
}

# Fibonacci sequence
fibonacci() {
    local n=$1
    
    # Base cases
    if [[ $n -le 0 ]]; then
        echo 0
        return
    elif [[ $n -eq 1 ]]; then
        echo 1
        return
    fi
    
    # Recursive case
    local fib1 fib2
    fib1=$(fibonacci $((n - 1)))
    fib2=$(fibonacci $((n - 2)))
    echo $((fib1 + fib2))
}

# Directory tree traversal
traverse_directory() {
    local dir=$1
    local depth=${2:-0}
    local indent=""
    
    # Create indentation
    for ((i=0; i<depth; i++)); do
        indent+="  "
    done
    
    # Process current directory
    echo "${indent}$(basename "$dir")/"
    
    # Recursively process subdirectories
    for item in "$dir"/*; do
        if [[ -d "$item" ]]; then
            traverse_directory "$item" $((depth + 1))
        elif [[ -f "$item" ]]; then
            echo "${indent}  $(basename "$item")"
        fi
    done
}

# Binary search (recursive)
binary_search() {
    local -n arr=$1
    local target=$2
    local left=${3:-0}
    local right=${4:-$((${#arr[@]} - 1))}
    
    # Base case: element not found
    if [[ $left -gt $right ]]; then
        echo -1
        return
    fi
    
    local mid=$(( (left + right) / 2 ))
    
    if [[ ${arr[$mid]} -eq $target ]]; then
        echo $mid
        return
    elif [[ ${arr[$mid]} -gt $target ]]; then
        binary_search arr $target $left $((mid - 1))
    else
        binary_search arr $target $((mid + 1)) $right
    fi
}

# Greatest Common Divisor (Euclidean algorithm)
gcd() {
    local a=$1
    local b=$2
    
    # Base case
    if [[ $b -eq 0 ]]; then
        echo $a
        return
    fi
    
    # Recursive case
    gcd $b $((a % b))
}

# Tree structure processing
process_tree() {
    local node=$1
    local -n children_ref=$2
    local action=${3:-"process"}
    
    # Process current node
    echo "Processing node: $node"
    
    # Get children array name
    local children_var="${node}_children"
    
    # Check if children array exists
    if [[ -n "${!children_var}" ]]; then
        local -n node_children=$children_var
        
        # Recursively process children
        for child in "${node_children[@]}"; do
            process_tree "$child" children_ref "$action"
        done
    fi
}

# Memoized fibonacci (optimization technique)
declare -A fib_memo

fibonacci_memo() {
    local n=$1
    
    # Check if already computed
    if [[ -n "${fib_memo[$n]}" ]]; then
        echo "${fib_memo[$n]}"
        return
    fi
    
    # Base cases
    if [[ $n -le 0 ]]; then
        fib_memo[$n]=0
        echo 0
        return
    elif [[ $n -eq 1 ]]; then
        fib_memo[$n]=1
        echo 1
        return
    fi
    
    # Recursive case with memoization
    local result
    result=$(( $(fibonacci_memo $((n - 1))) + $(fibonacci_memo $((n - 2))) ))
    fib_memo[$n]=$result
    echo $result
}
```

### Function Libraries and Sourcing

Function libraries enable code reuse and modular programming by organizing related functions into separate files that can be sourced into scripts. This approach promotes maintainability and reduces code duplication.

**Key points:**

- Use `source` or `.` to load external function libraries
- Libraries should be self-contained and well-documented
- Implement proper error handling and input validation
- Use consistent naming conventions across libraries
- Consider dependency management for complex libraries

**Example:**

```bash
# math_lib.sh - Mathematical functions library
#!/bin/bash

# Library metadata
MATH_LIB_VERSION="1.0.0"
MATH_LIB_AUTHOR="System Administrator"

# Check if library is already loaded
if [[ -n "$MATH_LIB_LOADED" ]]; then
    return 0
fi

# Mathematical constants
readonly PI=3.14159265359
readonly E=2.71828182846

# Power function
power() {
    local base=$1
    local exp=$2
    local result=1
    
    if [[ $# -ne 2 ]]; then
        echo "Usage: power <base> <exponent>" >&2
        return 1
    fi
    
    for ((i=0; i<exp; i++)); do
        result=$((result * base))
    done
    
    echo $result
}

# Square root approximation
sqrt() {
    local number=$1
    local precision=${2:-6}
    
    if [[ $# -eq 0 ]]; then
        echo "Usage: sqrt <number> [precision]" >&2
        return 1
    fi
    
    if [[ $number -lt 0 ]]; then
        echo "Error: Cannot calculate square root of negative number" >&2
        return 1
    fi
    
    # Newton's method approximation
    local x=$number
    local prev_x
    
    for ((i=0; i<precision; i++)); do
        prev_x=$x
        x=$(echo "scale=10; ($x + $number/$x) / 2" | bc -l)
        
        if [[ $(echo "$x == $prev_x" | bc -l) -eq 1 ]]; then
            break
        fi
    done
    
    echo $x
}

# Check if number is prime
is_prime() {
    local n=$1
    
    if [[ $n -lt 2 ]]; then
        return 1
    fi
    
    if [[ $n -eq 2 ]]; then
        return 0
    fi
    
    if [[ $((n % 2)) -eq 0 ]]; then
        return 1
    fi
    
    local sqrt_n
    sqrt_n=$(sqrt $n)
    
    for ((i=3; i<=sqrt_n; i+=2)); do
        if [[ $((n % i)) -eq 0 ]]; then
            return 1
        fi
    done
    
    return 0
}

# Library initialization
math_lib_init() {
    if ! command -v bc >/dev/null 2>&1; then
        echo "Warning: bc calculator not found. Some functions may not work properly." >&2
    fi
    
    echo "Math library v$MATH_LIB_VERSION loaded successfully"
}

# Mark library as loaded
MATH_LIB_LOADED=true

# Auto-initialize if sourced directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This is a library file. Source it instead of running directly."
    exit 1
else
    math_lib_init
fi

# string_lib.sh - String manipulation library
#!/bin/bash

STRING_LIB_VERSION="1.0.0"
STRING_LIB_LOADED=true

# String length without external commands
str_length() {
    local str=$1
    echo ${#str}
}

# Convert to uppercase
str_upper() {
    local str=$1
    echo "${str^^}"
}

# Convert to lowercase
str_lower() {
    local str=$1
    echo "${str,,}"
}

# Reverse string
str_reverse() {
    local str=$1
    local reversed=""
    local len=${#str}
    
    for ((i=len-1; i>=0; i--)); do
        reversed+="${str:$i:1}"
    done
    
    echo "$reversed"
}

# Check if string is palindrome
str_is_palindrome() {
    local str=$1
    local reversed
    reversed=$(str_reverse "$str")
    
    [[ "$str" == "$reversed" ]]
}

# String contains substring
str_contains() {
    local string=$1
    local substring=$2
    
    [[ "$string" == *"$substring"* ]]
}

# Split string by delimiter
str_split() {
    local string=$1
    local delimiter=$2
    local -n result_array=$3
    
    IFS="$delimiter" read -ra result_array <<< "$string"
}

# Join array elements with delimiter
str_join() {
    local delimiter=$1
    shift
    local first=true
    local result=""
    
    for item in "$@"; do
        if [[ $first == true ]]; then
            result="$item"
            first=false
        else
            result+="${delimiter}${item}"
        fi
    done
    
    echo "$result"
}

# file_lib.sh - File operations library
#!/bin/bash

FILE_LIB_VERSION="1.0.0"
FILE_LIB_LOADED=true

# Backup file with timestamp
backup_file() {
    local file=$1
    local backup_dir=${2:-"./backups"}
    
    if [[ ! -f "$file" ]]; then
        echo "Error: File '$file' does not exist" >&2
        return 1
    fi
    
    mkdir -p "$backup_dir"
    
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_name="${backup_dir}/$(basename "$file").${timestamp}.bak"
    
    cp "$file" "$backup_name"
    echo "Backup created: $backup_name"
}

# Safe file write with atomic operation
safe_write() {
    local file=$1
    local content=$2
    local temp_file="${file}.tmp.$$"
    
    # Write to temporary file
    echo "$content" > "$temp_file"
    
    # Atomic move
    if mv "$temp_file" "$file"; then
        echo "File written successfully: $file"
        return 0
    else
        rm -f "$temp_file"
        echo "Error: Failed to write file: $file" >&2
        return 1
    fi
}

# Count lines in file
count_lines() {
    local file=$1
    
    if [[ ! -f "$file" ]]; then
        echo 0
        return
    fi
    
    wc -l < "$file"
}

# Using the libraries
#!/bin/bash

# Main script that uses libraries
source "./math_lib.sh"
source "./string_lib.sh"
source "./file_lib.sh"

# Function to check library dependencies
check_dependencies() {
    local missing_libs=()
    
    if [[ -z "$MATH_LIB_LOADED" ]]; then
        missing_libs+=("math_lib.sh")
    fi
    
    if [[ -z "$STRING_LIB_LOADED" ]]; then
        missing_libs+=("string_lib.sh")
    fi
    
    if [[ -z "$FILE_LIB_LOADED" ]]; then
        missing_libs+=("file_lib.sh")
    fi
    
    if [[ ${#missing_libs[@]} -gt 0 ]]; then
        echo "Error: Missing libraries: ${missing_libs[*]}" >&2
        return 1
    fi
    
    return 0
}

# Example usage
main() {
    if ! check_dependencies; then
        exit 1
    fi
    
    echo "Using math library:"
    echo "5^3 = $(power 5 3)"
    echo "sqrt(16) = $(sqrt 16)"
    
    echo -e "\nUsing string library:"
    echo "Reverse of 'hello' = $(str_reverse 'hello')"
    echo "Uppercase 'world' = $(str_upper 'world')"
    
    echo -e "\nUsing file library:"
    echo "test content" > test.txt
    backup_file "test.txt"
    echo "Lines in test.txt: $(count_lines test.txt)"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

### Dynamic Function Creation

Dynamic function creation allows scripts to generate functions at runtime based on conditions, configurations, or user input. This technique enables highly flexible and adaptive scripting solutions.

**Key points:**

- Use `eval` to create functions from string definitions
- Function names can be constructed dynamically
- Template-based function generation enables code reuse
- Dynamic functions can be created based on configuration files
- Security considerations are critical when using `eval`

**Example:**

```bash
# Basic dynamic function creation
create_greeting_function() {
    local name=$1
    local greeting_type=${2:-"hello"}
    
    local function_name="greet_${name,,}"  # Convert to lowercase
    
    # Create function definition
    eval "
    ${function_name}() {
        echo '${greeting_type^} ${name}!'
    }
    "
    
    echo "Created function: $function_name"
}

# Usage
create_greeting_function "John" "welcome"
create_greeting_function "Mary" "goodbye"

# Now these functions exist and can be called
greet_john    # Output: Welcome John!
greet_mary    # Output: Goodbye Mary!

# Template-based function generation
create_validator_function() {
    local field_name=$1
    local validation_type=$2
    local function_name="validate_${field_name}"
    
    case $validation_type in
        "email")
            eval "
            ${function_name}() {
                local value=\$1
                if [[ \$value =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
                    return 0
                else
                    echo 'Invalid email format' >&2
                    return 1
                fi
            }
            "
            ;;
        "phone")
            eval "
            ${function_name}() {
                local value=\$1
                if [[ \$value =~ ^[0-9]{10,15}$ ]]; then
                    return 0
                else
                    echo 'Invalid phone format' >&2
                    return 1
                fi
            }
            "
            ;;
        "numeric")
            eval "
            ${function_name}() {
                local value=\$1
                if [[ \$value =~ ^[0-9]+$ ]]; then
                    return 0
                else
                    echo 'Must be numeric' >&2
                    return 1
                fi
            }
            "
            ;;
    esac
    
    echo "Created validator: $function_name"
}

# Create validators dynamically
create_validator_function "email" "email"
create_validator_function "age" "numeric"
create_validator_function "phone" "phone"

# Configuration-driven function creation
create_crud_functions() {
    local entity=$1
    local -n fields_ref=$2
    
    # Create getter function
    eval "
    get_${entity}() {
        local id=\$1
        echo 'Getting ${entity} with ID: \$id'
        # Database query logic here
    }
    "
    
    # Create setter function
    eval "
    set_${entity}() {
        local id=\$1
        shift
        echo 'Setting ${entity} \$id with values: \$*'
        # Database update logic here
    }
    "
    
    # Create validation function
    local validation_code=""
    for field in "${fields_ref[@]}"; do
        validation_code+="
        validate_${field} \"\$${field}\" || return 1"
    done
    
    eval "
    validate_${entity}() {
        local $(printf '%s ' "${fields_ref[@]}")
        
        # Parse arguments
        while [[ \$# -gt 0 ]]; do
            case \$1 in
                $(printf -- '--%s) %s=\"\$2\"; shift 2 ;;\n' "${fields_ref[@]}" "${fields_ref[@]}")
                *) echo 'Unknown option: \$1' >&2; return 1 ;;
            esac
        done
        
        # Validate fields
        ${validation_code}
        return 0
    }
    "
    
    echo "Created CRUD functions for: $entity"
}

# Usage example
user_fields=("email" "age" "phone")
create_crud_functions "user" user_fields

# Factory pattern for function creation
create_calculator_function() {
    local operation=$1
    local function_name="calc_${operation}"
    
    case $operation in
        "add")
            eval "
            ${function_name}() {
                local a=\$1 b=\$2
                echo \$((a + b))
            }
            "
            ;;
        "subtract")
            eval "
            ${function_name}() {
                local a=\$1 b=\$2
                echo \$((a - b))
            }
            "
            ;;
        "multiply")
            eval "
            ${function_name}() {
                local a=\$1 b=\$2
                echo \$((a * b))
            }
            "
            ;;
        "divide")
            eval "
            ${function_name}() {
                local a=\$1 b=\$2
                if [[ \$b -eq 0 ]]; then
                    echo 'Division by zero' >&2
                    return 1
                fi
                echo \$((a / b))
            }
            "
            ;;
    esac
    
    echo "Created calculator function: $function_name"
}

# Create calculator functions
operations=("add" "subtract" "multiply" "divide")
for op in "${operations[@]}"; do
    create_calculator_function "$op"
done

# Advanced: Function creation from external configuration
create_functions_from_config() {
    local config_file=$1
    
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ $key =~ ^[[:space:]]*# ]] && continue
        [[ -z $key ]] && continue
        
        # Parse function definition
        if [[ $key == "function_"* ]]; then
            local func_name=${key#function_}
            
            eval "
            ${func_name}() {
                echo '${value}'
            }
            "
            
            echo "Created function from config: $func_name"
        fi
    done < "$config_file"
}

# Metaprogramming with function builders
build_accessor_functions() {
    local -n data_ref=$1
    
    for key in "${!data_ref[@]}"; do
        local getter_name="get_${key}"
        local setter_name="set_${key}"
        
        # Create getter
        eval "
        ${getter_name}() {
            echo \"\${data_ref[$key]}\"
        }
        "
        
        # Create setter
        eval "
        ${setter_name}() {
            local new_value=\$1
            data_ref[$key]=\$new_value
            echo 'Set $key to \$new_value'
        }
        "
    done
}

# Example usage
declare -A app_config=(
    ["app_name"]="MyApp"
    ["version"]="1.0.0"
    ["author"]="Developer"
)

build_accessor_functions app_config

# Now you can use: get_app_name, set_app_name, etc.
```

### Function Overloading Techniques

Bash doesn't support true function overloading, but various techniques can simulate overloading behavior through parameter analysis, argument counting, and type checking.

**Key points:**

- Use parameter counting to determine which implementation to call
- Implement type checking for different argument types
- Use naming conventions to create pseudo-overloaded functions
- Default parameter values can reduce the need for overloading
- Function wrapper patterns can dispatch to specific implementations

**Example:**

```bash
# Parameter count-based overloading
print_info() {
    case $# in
        1)
            print_info_simple "$1"
            ;;
        2)
            print_info_detailed "$1" "$2"
            ;;
        3)
            print_info_full "$1" "$2" "$3"
            ;;
        *)
            echo "Usage: print_info <name> [age] [location]" >&2
            return 1
            ;;
    esac
}

print_info_simple() {
    local name=$1
    echo "Name: $name"
}

print_info_detailed() {
    local name=$1
    local age=$2
    echo "Name: $name, Age: $age"
}

print_info_full() {
    local name=$1
    local age=$2
    local location=$3
    echo "Name: $name, Age: $age, Location: $location"
}

# Type-based overloading simulation
process_data() {
    local data=$1
    
    # Check if it's a file
    if [[ -f "$data" ]]; then
        process_file "$data"
        return
    fi
    
    # Check if it's a directory
    if [[ -d "$data" ]]; then
        process_directory "$data"
        return
    fi
    
    # Check if it's a URL
    if [[ "$data" =~ ^https?:// ]]; then
        process_url "$data"
        return
    fi
    
    # Check if it's numeric
    if [[ "$data" =~ ^[0-9]+$ ]]; then
        process_number "$data"
        return
    fi
    
    # Default: treat as string
    process_string "$data"
}

process_file() {
    echo "Processing file: $1"
    # File processing logic
}

process_directory() {
    echo "Processing directory: $1"
    # Directory processing logic
}

process_url() {
    echo "Processing URL: $1"
    # URL processing logic
}

process_number() {
    echo "Processing number: $1"
    # Number processing logic
}

process_string() {
    echo "Processing string: $1"
    # String processing logic
}

# Named parameter overloading
calculate() {
    local operation=""
    local operand1=""
    local operand2=""
    local precision=2
    
    # Parse named parameters
    while [[ $# -gt 0 ]]; do
        case $1 in
            --operation=*)
                operation="${1#*=}"
                shift
                ;;
            --operand1=*)
                operand1="${1#*=}"
                shift
                ;;
            --operand2=*)
                operand2="${1#*=}"
                shift
                ;;
            --precision=*)
                precision="${1#*=}"
                shift
                ;;
            *)
                echo "Unknown parameter: $1" >&2
                return 1
                ;;
        esac
    done
    
    # Dispatch to appropriate function
    case $operation in
        "add")
            calculate_add "$operand1" "$operand2" "$precision"
            ;;
        "subtract")
            calculate_subtract "$operand1" "$operand2" "$precision"
            ;;
        "multiply")
            calculate_multiply "$operand1" "$operand2" "$precision"
            ;;
        "divide")
            calculate_divide "$operand1" "$operand2" "$precision"
            ;;
        *)
            echo "Unknown operation: $operation" >&2
            return 1
            ;;
    esac
}

calculate_add() {
    local a=$1 b=$2 precision=$3
    printf "%.${precision}f\n" "$(echo "$a + $b" | bc -l)"
}

calculate_subtract() {
    local a=$1 b=$2 precision=$3
    printf "%.${precision}f\n" "$(echo "$a - $b" | bc -l)"
}

calculate_multiply() {
    local a=$1 b=$2 precision=$3
    printf "%.${precision}f\n" "$(echo "$a * $b" | bc -l)"
}

calculate_divide() {
    local a=$1 b=$2 precision=$3
    if [[ $(echo "$b == 0" | bc -l) -eq 1 ]]; then
        echo "Error: Division by zero" >&2
        return 1
    fi
    printf "%.${precision}f\n" "$(echo "scale=$precision; $a / $b" | bc -l)"
}

# Object-oriented style overloading
create_logger() {
    local logger_name=$1
    local log_level=${2:-"INFO"}
    
    # Create logger functions with namespace
    eval "
    ${logger_name}_log() {
        local level=\$1
        shift
        local message=\$*
        
        case \$level in
            DEBUG|INFO|WARN|ERROR)
                echo \"[\$(date '+%Y-%m-%d %H:%M:%S')] [\$level] \$message\"
                ;;
            *)
                # Default to INFO level
                echo \"[\$(date '+%Y-%m-%d %H:%M:%S')] [INFO] \$level \$message\"
                ;;
        esac
    }
    
    ${logger_name}_debug() {
        ${logger_name}_log DEBUG \"\$@\"
    }
    
    ${logger_name}_info() {
        ${logger_name}_log INFO \"\$@\"
    }
    
    ${logger_name}_warn() {
        ${logger_name}_log WARN \"\$@\"
    }
    
    ${logger_name}_error() {
        ${logger_name}_log ERROR \"\$@\"
    }
    "
    
    echo "Created logger: $logger_name"
}

# Create different logger instances
create_logger "app"
create_logger "system"

# Usage: app_info "Application started"
#        system_error "System failure detected"

# Polymorphic function dispatch
declare -A function_registry

register_handler() {
    local type=$1
    local handler_function=$2
    function_registry["$type"]="$handler_function"
}

handle_request() {
    local request_type=$1
    shift
    local handler="${function_registry[$request_type]}"
    
    if [[ -n "$handler" ]]; then
        "$handler" "$@"
    else
        echo "No handler registered for type: $request_type" >&2
        return 1
    fi
}

# Handler implementations
handle_json() {
    echo "Processing JSON data: $*"
}

handle_xml() {
    echo "Processing XML data: $*"
}

handle_csv() {
    echo "Processing CSV data: $*"
}

# Register handlers
register_handler "json" "handle_json"
register_handler "xml" "handle_xml"
register_handler "csv" "handle_csv"

# Function composition for overloading
compose_functions() {
    local func1=$1
    local func2=$2
    local composed_name=$3
    
    eval "
    ${composed_name}() {
        local temp_result
        temp_result=\$($func1 \"\$@\")
        $func2 \"\$temp_result\"
    }
    "
}

# Example functions for composition
double() {
    local n=$1
    echo $((n * 2))
}

square() {
    local n=$1
    echo $((n * n))
}

# Create composed function
compose_functions "double" "square" "double_then_square"

# Usage: double_then_square 5  # Returns (5*2)^2 = 100
```

**Advanced overloading patterns:**

```bash
# Fluent interface pattern
create_builder() {
    local builder_name=$1
    local -A builder_state
    
    eval "
    ${builder_name}_with_name() {
        builder_state['name']=\$1
        echo '$builder_name'
    }
    
    ${builder_name}_with_age() {
        builder_state['age']=\$1
        echo '$builder_name'
    }
    
    ${builder_name}_with_email() {
        builder_state['email']=\$1
        echo '$builder_name'
    }
    
    ${builder_name}_build() {
        echo \"Name: \${builder_state['name']}, Age: \${builder_state['age']}, Email: \${builder_state['email']}\"
    }
    "
}

# Usage: create_builder "user_builder"
#        user_builder_with_name "John" | user_builder_with_age 30 | user_builder_build
```

Important related topics include advanced parameter parsing techniques, function introspection and reflection, performance optimization for recursive functions, and memory management in function-heavy scripts.

---

