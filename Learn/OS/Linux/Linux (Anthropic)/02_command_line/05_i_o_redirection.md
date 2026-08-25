## I/O Redirection


### Standard Streams (stdin, stdout, stderr)

Linux systems utilize three fundamental data streams that form the foundation of input/output operations for all processes. These streams provide standardized communication channels between programs, the shell, and the operating system, enabling flexible data flow control and error handling.

Standard input (stdin) serves as the primary data input channel for programs, typically connected to the keyboard by default. Programs read user input, configuration data, or piped information through this stream using file descriptor 0. Applications can modify their behavior based on whether stdin originates from interactive input, file redirection, or pipeline connections.

Standard output (stdout) represents the main output channel for program results and normal operational messages, using file descriptor 1. By default, stdout connects to the terminal display, but redirection allows sending output to files, other programs, or alternative destinations. Most command-line utilities send their primary results through stdout for easy capture and manipulation.

Standard error (stderr) provides a dedicated channel for error messages, warnings, and diagnostic information using file descriptor 2. This separation allows programs to send errors to the terminal while redirecting normal output elsewhere, ensuring users always see critical messages. System administrators leverage this distinction for logging and monitoring purposes.

**Key points:**

- Each stream has a unique file descriptor number (0, 1, 2)
- Streams operate independently and can be redirected separately
- Default connections: stdin (keyboard), stdout (terminal), stderr (terminal)
- All processes inherit these streams from their parent process
- Stream redirection doesn't affect program logic, only data routing

The separation of output streams enables sophisticated error handling and data processing workflows. Programs can simultaneously write results to files while displaying progress information on screen, or send normal output through pipelines while preserving error visibility for debugging.

**Example stream demonstration:**

```bash
# Display file descriptor information
ls -la /proc/self/fd/

# Identify stream sources in scripts
echo "Normal output" >&1
echo "Error message" >&2
read -p "Enter input: " variable <&0
```

### Redirection Operators (`>`, `>>`, `<`)

Redirection operators provide precise control over data flow between programs and files, enabling users to capture output, supply input, and manage data persistence. These operators modify the default stream connections without altering program behavior, creating flexible data processing pipelines.

The output redirection operator (`>`) redirects stdout to a specified file, creating new files or overwriting existing content. This operator proves essential for capturing command results, creating configuration files, and preserving program output for later analysis. The shell handles file creation, permissions, and truncation automatically.

Append redirection (`>>`) adds stdout content to the end of existing files without destroying previous data. This operator enables logging, incremental data collection, and building composite files from multiple command executions. The operator creates files if they don't exist, providing seamless operation regardless of initial file state.

Input redirection (`<`) supplies file content as stdin to programs, eliminating the need for manual data entry or file reading code. This operator enables batch processing, automated testing, and data analysis workflows where programs expect interactive input but receive file-based data instead.

**Key points:**

- Redirection occurs before command execution
- File permissions and ownership affect redirection success
- Redirection operators work with any file descriptor number
- Multiple redirections can operate simultaneously
- Shell performs redirection, not the target program

Advanced redirection techniques include file descriptor manipulation, allowing redirection of stderr independently from stdout. The notation `2>` redirects stderr specifically, while `&>` redirects both stdout and stderr to the same destination. These techniques prove crucial for comprehensive logging and error management.

**Example redirection patterns:**

```bash
# Basic output redirection
ls -la > directory_listing.txt
date >> logfile.txt

# Input redirection
sort < unsorted_data.txt
mysql database_name < schema.sql

# Advanced descriptor redirection
command > output.txt 2> errors.txt
command &> combined_output.txt
command 2>&1 > all_output.txt
```

### Pipes (`|`)

Pipes create direct communication channels between processes, connecting the stdout of one command to the stdin of another without intermediate file storage. This mechanism enables real-time data processing, filtering, and transformation through command composition, forming the backbone of Unix-style text processing workflows.

The pipe operator (`|`) establishes a buffer-managed connection where the first program's output becomes the second program's input automatically. The shell creates both processes simultaneously and manages data transfer, allowing efficient processing of large datasets without temporary file creation or manual data movement.

Named pipes (FIFOs) provide persistent communication channels that exist as filesystem objects, enabling inter-process communication between unrelated programs. Unlike anonymous pipes created by the shell, named pipes persist until explicitly removed and support bidirectional communication patterns.

**Key points:**

- Pipes operate in real-time without intermediate storage
- Data flows automatically as programs produce and consume it
- Multiple pipes can chain together for complex processing
- Pipe failure in any stage affects the entire pipeline
- Buffer management prevents data loss during processing

Pipeline composition enables sophisticated data processing through simple command combinations. Text processing utilities like grep, sed, awk, and sort integrate seamlessly through pipes, creating powerful analysis tools from basic components. Each program in the pipeline operates independently while contributing to the overall data transformation.

Error handling in pipelines requires attention to individual command exit status and stderr management. The PIPESTATUS array preserves exit codes from all pipeline stages, enabling comprehensive error detection and handling in complex processing workflows.

**Example pipeline patterns:**

```bash
# Basic text processing pipeline
cat logfile.txt | grep "ERROR" | sort | uniq -c

# Complex data analysis
ps aux | awk '{print $3}' | sort -n | tail -10

# Network data processing
netstat -an | grep LISTEN | wc -l

# File processing with multiple filters
find /var/log -name "*.log" | xargs grep "failed" | cut -d: -f1 | sort | uniq
```

### Command Chaining (`&&`, `||`, `;`)

Command chaining operators control execution flow between multiple commands based on success, failure, or unconditional sequence requirements. These operators enable conditional execution, error handling, and workflow automation without complex scripting structures.

The logical AND operator (`&&`) executes the second command only if the first command succeeds (returns exit status 0). This operator proves essential for dependency chains where subsequent operations require successful completion of prerequisite tasks. System administration tasks frequently use this pattern for safe operation sequences.

The logical OR operator (`||`) executes the second command only if the first command fails (returns non-zero exit status). This operator enables fallback mechanisms, error recovery, and alternative execution paths when primary operations encounter problems. The pattern proves valuable for robust automation scripts.

The semicolon separator (`;`) executes commands sequentially regardless of individual success or failure status. This operator enables batch command execution where each operation remains independent of others. The shell processes each command in order, continuing execution even if intermediate commands fail.

**Key points:**

- Command chaining evaluates left-to-right with short-circuit logic
- Exit status determines conditional execution for && and || operators
- Parentheses group commands for complex conditional logic
- Multiple chaining operators can combine in single command lines
- Error propagation depends on the specific chaining operator used

Advanced chaining patterns combine multiple operators for sophisticated control flow. The pattern `command1 && command2 || command3` attempts command1, executes command2 on success, or falls back to command3 on failure. This creates try-catch-like behavior in shell command sequences.

Subshell grouping with parentheses enables complex conditional blocks where multiple commands execute as a unit. The grouped commands share environment changes and their collective exit status determines conditional execution flow.

**Example chaining patterns:**

```bash
# Conditional execution chains
make && make install && echo "Installation successful"
cd /backup || mkdir /backup && cd /backup

# Complex conditional logic
(git pull && make clean && make) || echo "Build failed"

# Sequential execution regardless of status
command1; command2; command3

# Mixed chaining for robust operations
backup_database && compress_backup || send_alert_email
```

**Output management in chains:** Command chaining interacts with redirection operators to create comprehensive workflow control. Output redirection applies to individual commands unless explicitly grouped, while error handling can redirect based on chain success or failure patterns.

**Example comprehensive workflow:**

```bash
# Complete backup workflow with error handling
backup_files.sh > backup.log 2>&1 && \
compress_backup.sh >> backup.log 2>&1 && \
upload_backup.sh >> backup.log 2>&1 || \
(echo "Backup failed: $(date)" >> error.log && notify_admin.sh)
```

**Important related topics:** Process substitution, Here documents and here strings, File descriptor manipulation, Signal handling in pipelines

---

