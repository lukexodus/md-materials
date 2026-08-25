## String Manipulation


### String Operations and Concatenation

String manipulation forms the foundation of effective Bash scripting, enabling you to process text data, format output, and build dynamic commands. Bash provides multiple approaches to string operations, each with specific use cases and performance characteristics.

**Basic String Assignment** in Bash doesn't require quotes for simple strings without spaces, but it's good practice to use quotes consistently. Single quotes preserve literal values, while double quotes allow variable expansion and command substitution.

**String Concatenation** can be accomplished through several methods. The most straightforward approach is placing variables and strings adjacent to each other. Bash automatically concatenates adjacent strings without requiring explicit operators.

```bash
first_name="John"
last_name="Smith"
full_name="$first_name $last_name"
greeting="Hello, $full_name!"
```

**Variable Expansion** within strings uses the `$variable` or `${variable}` syntax. The curly brace notation becomes essential when concatenating variables with additional text that might be interpreted as part of the variable name.

```bash
base="file"
extension="txt"
filename="${base}.${extension}"  # Results in "file.txt"
```

**Appending to Strings** can be done using the `+=` operator, which is particularly useful when building strings incrementally in loops or conditional statements.

```bash
message="Processing"
for i in {1..3}; do
    message+=" step $i"
done
# Results in "Processing step 1 step 2 step 3"
```

**Command Substitution** allows incorporating command output into strings using `$(command)` or backticks, though the former is preferred for readability and nesting capability.

```bash
current_date=$(date +"%Y-%m-%d")
backup_file="backup_${current_date}.tar.gz"
```

**Here Documents and Here Strings** provide powerful ways to work with multi-line strings and pass string data to commands.

```bash
# Here document
cat << EOF > config.txt
Server: $server_name
Port: $port_number
Database: $database_name
EOF

# Here string
grep "error" <<< "$log_data"
```

**Key points** for string operations:

- Use double quotes for variable expansion, single quotes for literal strings
- Employ `${variable}` syntax when concatenating with additional text
- Leverage `+=` for incremental string building
- Combine command substitution with string concatenation for dynamic content
- Consider here documents for multi-line string generation

### String Length and Substrings

Bash provides built-in parameter expansion features for extracting string length and substrings without requiring external tools, making string processing efficient and portable.

**String Length** calculation uses the `${#variable}` syntax, which returns the number of characters in the string. This operation is useful for validation, formatting, and loop control.

```bash
text="Hello, World!"
length=${#text}  # Returns 13
```

**Substring Extraction** employs the `${variable:offset:length}` syntax, where offset specifies the starting position (zero-based) and length determines how many characters to extract. If length is omitted, extraction continues to the end of the string.

```bash
text="Hello, World!"
substring1=${text:0:5}    # "Hello"
substring2=${text:7}      # "World!"
substring3=${text:7:5}    # "World"
```

**Negative Offsets** allow extraction from the end of the string, but require careful syntax with spaces or parentheses to avoid shell interpretation issues.

```bash
text="Hello, World!"
last_char=${text: -1}     # "!"
last_word=${text: -6}     # "World!"
```

**String Slicing with Variables** enables dynamic substring extraction based on calculated positions.

```bash
filename="document.pdf"
dot_position=$((${#filename} - 4))
name_part=${filename:0:$dot_position}      # "document"
extension=${filename:$dot_position+1}      # "pdf"
```

**Multiple Substring Operations** can be combined for complex text processing tasks.

```bash
log_entry="2024-01-15 14:30:22 ERROR Failed to connect"
date_part=${log_entry:0:10}           # "2024-01-15"
time_part=${log_entry:11:8}           # "14:30:22"
level_part=${log_entry:20:5}          # "ERROR"
message_part=${log_entry:26}          # "Failed to connect"
```

**Array-like Access** treats strings as arrays of characters, allowing individual character extraction.

```bash
text="Bash"
first_char=${text:0:1}    # "B"
second_char=${text:1:1}   # "a"
```

**Key points** for length and substring operations:

- Use `${#var}` for string length calculation
- Employ `${var:offset:length}` for substring extraction
- Negative offsets require space before the minus sign
- Combine operations for complex text parsing
- Consider zero-based indexing for offset calculations

### Pattern Matching and Replacement

Bash provides powerful pattern matching and replacement capabilities through parameter expansion, enabling complex text processing without external tools like sed or awk.

**Pattern Removal** uses various expansion forms to remove matching patterns from the beginning or end of strings. The `#` operator removes from the beginning, while `%` removes from the end.

```bash
filename="path/to/document.txt"
# Remove shortest match from beginning
name_with_ext=${filename##*/}      # "document.txt"
# Remove longest match from beginning  
path_part=${filename%/*}           # "path/to"
# Remove shortest match from end
name_only=${filename%.*}           # "path/to/document"
# Remove longest match from end
base_name=${filename##*/}
base_name=${base_name%.*}          # "document"
```

**Pattern Replacement** employs the `${variable/pattern/replacement}` syntax for substitution operations. Single slash replaces the first match, while double slash replaces all matches.

```bash
text="The quick brown fox jumps over the lazy dog"
# Replace first occurrence
modified=${text/the/a}             # "The quick brown fox jumps over a lazy dog"
# Replace all occurrences
modified=${text//the/a}            # "The quick brown fox jumps over a lazy dog"
# Replace all occurrences (case insensitive with shopt)
shopt -s nocasematch
modified=${text//the/a}            # "a quick brown fox jumps over a lazy dog"
shopt -u nocasematch
```

**Anchored Replacements** specify whether patterns must match at the beginning or end of the string using `#` and `%` prefixes.

```bash
filename="test_file.txt"
# Replace at beginning
new_name=${filename/#test/backup}   # "backup_file.txt"
# Replace at end
new_name=${filename/%txt/log}       # "test_file.log"
```

**Wildcard Patterns** support glob-style matching with `*`, `?`, and character classes.

```bash
files="file1.txt file2.log file3.txt"
# Remove all .txt extensions
cleaned=${files//*.txt/}
# Replace numbers with X
anonymized=${files//[0-9]/X}       # "fileX.txt fileX.log fileX.txt"
```

**Empty Replacement** effectively removes matching patterns by providing an empty replacement string.

```bash
text="Hello    World    with    spaces"
# Remove extra spaces
cleaned=${text//    / }            # "Hello World with spaces"
# Remove all spaces
nospaces=${text// /}               # "HelloWorldwithspaces"
```

**Complex Pattern Matching** combines multiple operations for sophisticated text processing.

```bash
log_line="[2024-01-15] INFO: User login successful"
# Extract date
date_part=${log_line#[}
date_part=${date_part%]*}          # "2024-01-15"
# Extract level
level_part=${log_line##*] }
level_part=${level_part%:*}        # "INFO"
# Extract message
message=${log_line##*: }           # "User login successful"
```

**Key points** for pattern matching:

- Use `#` and `##` for removal from beginning (shortest/longest match)
- Use `%` and `%%` for removal from end (shortest/longest match)
- Employ `/` for single replacement, `//` for global replacement
- Leverage `/#` and `/%` for anchored replacements
- Combine operations for complex text parsing tasks

### Case Conversion and Trimming

Bash 4.0 introduced built-in case conversion capabilities, while trimming operations use pattern matching to remove whitespace and unwanted characters from strings.

**Case Conversion** provides several parameter expansion operators for changing string case. The `^` operator converts to uppercase, while `,` converts to lowercase.

```bash
text="Hello World"
# Convert first character to uppercase
first_upper=${text^}               # "Hello World"
# Convert all characters to uppercase
all_upper=${text^^}                # "HELLO WORLD"
# Convert first character to lowercase
first_lower=${text,}               # "hello World"
# Convert all characters to lowercase
all_lower=${text,,}                # "hello world"
```

**Selective Case Conversion** allows targeting specific characters or patterns for conversion.

```bash
mixed="hello WORLD 123"
# Convert only alphabetic characters
alpha_upper=${mixed^^[[:alpha:]]}   # "HELLO WORLD 123"
alpha_lower=${mixed,,[[:alpha:]]}   # "hello world 123"
# Convert only specific characters
vowels_upper=${mixed^^[aeiou]}      # "hEllO WORLD 123"
```

**Legacy Case Conversion** for older Bash versions requires external tools or custom functions.

```bash
# Using tr command
text="Hello World"
upper=$(echo "$text" | tr '[:lower:]' '[:upper:]')
lower=$(echo "$text" | tr '[:upper:]' '[:lower:]')

# Custom function for older Bash
to_upper() {
    echo "$1" | tr '[:lower:]' '[:upper:]'
}
```

**Whitespace Trimming** removes leading and trailing whitespace using parameter expansion pattern matching.

```bash
text="   Hello World   "
# Remove leading whitespace
ltrim=${text##+([[:space:]])}
# Remove trailing whitespace
rtrim=${text%%+([[:space:]])}
# Remove both leading and trailing whitespace
trimmed=${text##+([[:space:]])}
trimmed=${trimmed%%+([[:space:]])}
```

**Custom Trimming Functions** provide reusable whitespace removal functionality.

```bash
trim() {
    local var="$1"
    var="${var#"${var%%[![:space:]]*}"}"   # Remove leading whitespace
    var="${var%"${var##*[![:space:]]}"}"   # Remove trailing whitespace
    echo "$var"
}

# Usage
clean_text=$(trim "   Hello World   ")
```

**Character Removal** extends trimming concepts to remove specific characters from string boundaries.

```bash
text="...Hello World..."
# Remove leading dots
no_leading=${text##*.}
# Remove trailing dots
no_trailing=${text%%.*}
# Remove both
clean=${text##*.}
clean=${clean%%.*}
```

**Advanced Trimming** handles multiple whitespace types and complex scenarios.

```bash
# Remove all types of whitespace
trim_all() {
    local text="$1"
    # Remove leading whitespace (spaces, tabs, newlines)
    text="${text#"${text%%[![:space:]]*}"}"
    # Remove trailing whitespace
    text="${text%"${text##*[![:space:]]}"}"
    echo "$text"
}

# Remove specific character sets
trim_chars() {
    local text="$1"
    local chars="$2"
    # Remove leading characters
    while [[ "$text" =~ ^[$chars] ]]; do
        text="${text#?}"
    done
    # Remove trailing characters
    while [[ "$text" =~ [$chars]$ ]]; do
        text="${text%?}"
    done
    echo "$text"
}
```

**Key points** for case conversion and trimming:

- Use `^^` and `,,` for full case conversion in Bash 4.0+
- Employ `^` and `,` for first character case conversion
- Leverage character classes for selective conversion
- Combine parameter expansion for whitespace trimming
- Create reusable functions for complex trimming operations
- Consider external tools for older Bash versions

**Example** comprehensive string processing function:

```bash
process_string() {
    local input="$1"
    local operation="$2"
    
    case "$operation" in
        "upper")
            echo "${input^^}"
            ;;
        "lower")
            echo "${input,,}"
            ;;
        "trim")
            local trimmed="${input#"${input%%[![:space:]]*}"}"
            echo "${trimmed%"${trimmed##*[![:space:]]}"}"
            ;;
        "clean")
            local cleaned="${input^^}"
            cleaned="${cleaned#"${cleaned%%[![:space:]]*}"}"
            echo "${cleaned%"${cleaned##*[![:space:]]}"}"
            ;;
        *)
            echo "Usage: process_string <string> <upper|lower|trim|clean>"
            return 1
            ;;
    esac
}
```

String manipulation in Bash provides extensive capabilities for text processing, enabling sophisticated data transformation and formatting without relying on external tools. Understanding these techniques allows for efficient script development and system administration tasks.

---

