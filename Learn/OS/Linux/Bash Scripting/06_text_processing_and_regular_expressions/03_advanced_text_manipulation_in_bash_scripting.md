## Advanced Text Manipulation in Bash Scripting


### sed Scripting for Complex Replacements

sed (Stream Editor) is a powerful command-line tool for performing complex text transformations on streams of data. It operates on a line-by-line basis and supports advanced pattern matching and replacement operations.

#### Basic sed Operations

sed uses addresses to specify which lines to operate on, followed by commands to execute. The general syntax is `sed 'address command' file`. Addresses can be line numbers, ranges, or regular expressions.

**Key points:**

- sed reads input line by line into a pattern space
- Commands are applied to the pattern space
- Modified content is output unless suppressed with -n flag
- Multiple commands can be chained with semicolons or -e flags

#### Advanced sed Commands

The substitute command (s) supports powerful features beyond basic replacement. Back-references allow you to capture parts of the matched pattern using parentheses and reference them with \1, \2, etc. The global flag (g) replaces all occurrences on a line, while numeric flags replace only the nth occurrence.

**Example:**

```bash
# Replace email domains while preserving usernames
sed 's/\([^@]*\)@[^@]*/\1@newdomain.com/g' contacts.txt

# Add line numbers to non-empty lines
sed '/./=' file.txt | sed 'N;s/\n/: /'

# Delete lines between two patterns
sed '/START/,/END/d' file.txt
```

#### Hold Space and Advanced Flow Control

sed maintains a hold space alongside the pattern space, enabling complex multi-line operations. The hold space acts as a temporary buffer where you can store and retrieve text.

Commands for hold space manipulation include:

- h/H: copy/append pattern space to hold space
- g/G: copy/append hold space to pattern space
- x: exchange pattern and hold spaces
- n/N: read next line into pattern space

**Example:**

```bash
# Reverse order of lines in a file
sed '1!G;h;$!d' file.txt

# Print lines that contain a pattern and the line before it
sed -n '/pattern/{x;p;x;p;d;}; x' file.txt
```

### awk Programming for Data Processing

awk is a pattern-scanning and data extraction language that excels at processing structured text data. It operates on records (typically lines) and fields (typically separated by whitespace or delimiters).

#### awk Structure and Syntax

awk programs follow the pattern `BEGIN { } /pattern/ { action } END { }` structure. The BEGIN block executes before processing any input, pattern-action pairs process matching records, and the END block executes after all input is processed.

**Key points:**

- Built-in variables: NR (record number), NF (field count), FS (field separator), RS (record separator)
- Field variables: $0 (entire record), $1, $2, etc. (individual fields)
- Supports variables, arrays, functions, and control structures
- Pattern matching uses regular expressions

#### Data Processing Capabilities

awk provides comprehensive programming constructs including variables, arrays, loops, conditionals, and functions. It's particularly effective for mathematical operations, string manipulation, and formatted output.

**Example:**

```bash
# Calculate average of third column
awk '{ sum += $3; count++ } END { print "Average:", sum/count }' data.txt

# Process CSV with custom field separator
awk -F',' '{ print $2, $4 }' data.csv

# Group by first field and sum second field
awk '{ sum[$1] += $2 } END { for (key in sum) print key, sum[key] }' data.txt
```

#### Advanced awk Features

awk supports associative arrays, user-defined functions, and complex string operations. The printf function provides formatted output similar to C programming, while built-in functions handle string manipulation, mathematical operations, and pattern matching.

**Example:**

```bash
# Custom function to process data
awk '
function process_record(field) {
    return toupper(substr(field, 1, 1)) tolower(substr(field, 2))
}
{ print process_record($1), $2 }
' data.txt

# Multi-dimensional array simulation
awk '{ data[NR":"$1] = $2 } END { for (key in data) print key, data[key] }' file.txt
```

### Processing CSV and Structured Data

CSV (Comma-Separated Values) files require special handling due to potential complications like embedded commas, quotes, and multiline fields. Bash provides several approaches for robust CSV processing.

#### CSV Parsing Challenges

Standard field separation fails with CSV data containing quoted fields, embedded commas, or escaped characters. Proper CSV parsing requires state-aware processing that handles quoting rules and escape sequences.

**Key points:**

- Fields may contain embedded delimiters within quotes
- Quotes within fields are escaped by doubling
- Some CSV variants use different quoting and escaping rules
- Multiline fields can span multiple records

#### awk-based CSV Processing

awk can handle many CSV scenarios with careful field separator configuration and pattern matching. For complex CSV files, custom parsing logic may be necessary.

**Example:**

```bash
# Basic CSV processing with awk
awk -F',' '{ gsub(/"/, "", $2); print $1, $2 }' data.csv

# Handle quoted fields with embedded commas
awk -F',' '
{
    for (i = 1; i <= NF; i++) {
        gsub(/^"/, "", $i)
        gsub(/"$/, "", $i)
        gsub(/""/, "\"", $i)
    }
    print $1, $3, $5
}' complex.csv
```

#### Advanced CSV Handling

For robust CSV processing, consider using specialized tools or implementing state machines in awk. This approach handles edge cases like multiline fields and complex quoting scenarios.

**Example:**

```bash
# State machine for CSV parsing
awk '
BEGIN { FS = ""; in_quote = 0; field = ""; field_num = 0 }
{
    for (i = 1; i <= length($0); i++) {
        char = substr($0, i, 1)
        if (char == "\"") {
            if (in_quote && substr($0, i+1, 1) == "\"") {
                field = field "\""
                i++
            } else {
                in_quote = !in_quote
            }
        } else if (char == "," && !in_quote) {
            fields[++field_num] = field
            field = ""
        } else {
            field = field char
        }
    }
    if (!in_quote) {
        fields[++field_num] = field
        # Process fields array
        for (j = 1; j <= field_num; j++) {
            print "Field " j ": " fields[j]
        }
        field_num = 0; field = ""
    }
}' data.csv
```

### Log File Analysis Techniques

Log file analysis involves extracting meaningful information from structured or semi-structured log entries. Effective log analysis requires understanding log formats, identifying patterns, and extracting relevant metrics.

#### Common Log Formats

Web server logs (Apache, Nginx) follow standard formats like Common Log Format (CLF) or Extended Log Format. System logs often use syslog format with timestamps, hostnames, and process information. Application logs may use custom formats requiring specific parsing approaches.

**Key points:**

- Timestamp parsing and normalization
- IP address extraction and geolocation
- Status code analysis and error detection
- Performance metrics calculation
- Pattern recognition for security analysis

#### Log Parsing with awk and sed

awk excels at log analysis due to its field-based processing model. Regular expressions help extract specific information from log entries, while awk's associative arrays enable aggregation and counting operations.

**Example:**

```bash
# Apache log analysis - top IP addresses
awk '{ print $1 }' access.log | sort | uniq -c | sort -nr | head -10

# Error log analysis with timestamp filtering
awk '
/ERROR/ && $1 >= "2024-01-01" && $1 <= "2024-01-31" {
    errors[$7]++
}
END {
    for (error in errors) print error, errors[error]
}' application.log

# Response time analysis
awk '{ 
    response_time = $NF
    total_time += response_time
    count++
    if (response_time > max_time) max_time = response_time
}
END {
    print "Average response time:", total_time/count
    print "Maximum response time:", max_time
}' access.log
```

#### Advanced Log Analysis

Complex log analysis involves correlation across multiple log sources, time-based analysis, and statistical processing. Advanced techniques include sliding window analysis, anomaly detection, and trend identification.

**Example:**

```bash
# Sliding window analysis for request rates
awk '
{
    timestamp = $4
    gsub(/\[/, "", timestamp)
    gsub(/:/, " ", timestamp)
    if (cmd = "date -d \"" timestamp "\" +%s") {
        cmd | getline epoch
        close(cmd)
        requests[int(epoch/300)]++  # 5-minute windows
    }
}
END {
    for (window in requests) {
        print strftime("%Y-%m-%d %H:%M", window*300), requests[window]
    }
}' access.log | sort

# Security analysis - detect potential attacks
awk '
$9 ~ /^(4|5)/ {  # HTTP error codes
    error_count[$(NF-1)]++
    if (error_count[$(NF-1)] > 10) {
        suspicious_ips[$(NF-1)] = 1
    }
}
END {
    print "Suspicious IP addresses:"
    for (ip in suspicious_ips) {
        print ip, "errors:", error_count[ip]
    }
}' access.log
```

#### Performance Optimization

Large log files require efficient processing strategies. Techniques include preprocessing with grep or sed to filter relevant entries, using appropriate field separators, and implementing efficient data structures for aggregation.

**Example:**

```bash
# Efficient log processing pipeline
grep "ERROR" large.log | \
sed 's/.*\[\(.*\)\].*/\1/' | \
awk '{ count[$1]++ } END { for (date in count) print date, count[date] }' | \
sort -k2 -nr

# Memory-efficient processing for huge files
awk '
BEGIN { 
    # Process in chunks to manage memory
    chunk_size = 10000
    current_chunk = 0
}
{
    if (NR % chunk_size == 0) {
        # Process accumulated data
        for (key in data) {
            print key, data[key] > "chunk_" current_chunk ".tmp"
        }
        delete data
        current_chunk++
    }
    data[$1] += $2
}
END {
    # Process final chunk
    for (key in data) {
        print key, data[key] > "chunk_" current_chunk ".tmp"
    }
}' huge_log.txt
```

**Next steps:** Consider exploring related topics like regular expressions mastery, shell scripting performance optimization, and integration with external tools like jq for JSON processing, or exploring advanced bash features like process substitution and co-processes for complex data pipelines.

---

