## Process Execution and Management


Go provides powerful capabilities for executing external processes, managing their lifecycle, and handling their input/output streams.

**Key Points:**

- `os/exec` package handles process execution
- `exec.Command` creates process specifications
- Processes can be started, waited for, and killed
- Standard streams (stdin, stdout, stderr) can be redirected
- Process environment and working directory can be customized

**Example:**

```go
package main

import (
    "bufio"
    "context"
    "fmt"
    "os"
    "os/exec"
    "strings"
    "time"
)

func main() {
    // Simple command execution
    simpleCommand()

    // Command with input/output handling
    commandWithIO()

    // Command with timeout
    commandWithTimeout()

    // Pipeline of commands
    pipelineCommands()
}

func simpleCommand() {
    fmt.Println("=== Simple Command ===")
    cmd := exec.Command("echo", "Hello, World!")
    
    output, err := cmd.Output()
    if err != nil {
        fmt.Printf("Error: %v\n", err)
        return
    }
    
    fmt.Printf("Output: %s", output)
}

func commandWithIO() {
    fmt.Println("\n=== Command with I/O ===")
    cmd := exec.Command("grep", "error")
    
    // Set up stdin
    stdin, err := cmd.StdinPipe()
    if err != nil {
        panic(err)
    }
    
    // Set up stdout
    stdout, err := cmd.StdoutPipe()
    if err != nil {
        panic(err)
    }
    
    // Start the command
    if err := cmd.Start(); err != nil {
        panic(err)
    }
    
    // Send input
    go func() {
        defer stdin.Close()
        fmt.Fprintln(stdin, "This is an info message")
        fmt.Fprintln(stdin, "This is an error message")
        fmt.Fprintln(stdin, "Another info message")
    }()
    
    // Read output
    scanner := bufio.NewScanner(stdout)
    for scanner.Scan() {
        fmt.Printf("Grep output: %s\n", scanner.Text())
    }
    
    // Wait for command to finish
    if err := cmd.Wait(); err != nil {
        fmt.Printf("Command finished with error: %v\n", err)
    }
}

func commandWithTimeout() {
    fmt.Println("\n=== Command with Timeout ===")
    ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
    defer cancel()
    
    cmd := exec.CommandContext(ctx, "sleep", "5")
    
    err := cmd.Run()
    if err != nil {
        if ctx.Err() == context.DeadlineExceeded {
            fmt.Println("Command timed out")
        } else {
            fmt.Printf("Command failed: %v\n", err)
        }
    }
}

func pipelineCommands() {
    fmt.Println("\n=== Pipeline Commands ===")
    
    // Create commands
    cmd1 := exec.Command("echo", "apple\nbanana\napricot\nblueberry")
    cmd2 := exec.Command("grep", "a")
    cmd3 := exec.Command("sort")
    
    // Set up pipes
    pipe1, err := cmd1.StdoutPipe()
    if err != nil {
        panic(err)
    }
    cmd2.Stdin = pipe1
    
    pipe2, err := cmd2.StdoutPipe()
    if err != nil {
        panic(err)
    }
    cmd3.Stdin = pipe2
    
    // Start commands in reverse order
    if err := cmd3.Start(); err != nil {
        panic(err)
    }
    if err := cmd2.Start(); err != nil {
        panic(err)
    }
    if err := cmd1.Start(); err != nil {
        panic(err)
    }
    
    // Read final output
    output, err := cmd3.Output()
    if err != nil {
        panic(err)
    }
    
    fmt.Printf("Pipeline output:\n%s", output)
    
    // Wait for all commands
    cmd1.Wait()
    cmd2.Wait()
    cmd3.Wait()
}

// Advanced process management
func processManagement() {
    cmd := exec.Command("sleep", "10")
    
    // Start the process
    if err := cmd.Start(); err != nil {
        panic(err)
    }
    
    fmt.Printf("Process started with PID: %d\n", cmd.Process.Pid)
    
    // Kill the process after 2 seconds
    go func() {
        time.Sleep(2 * time.Second)
        fmt.Println("Killing process...")
        cmd.Process.Kill()
    }()
    
    // Wait for process to finish
    err := cmd.Wait()
    if err != nil {
        fmt.Printf("Process finished with error: %v\n", err)
    }
}
```

**Advanced Process Features:**

- Process groups for managing related processes
- Custom environment variables using `cmd.Env`
- Working directory changes using `cmd.Dir`
- Process attributes and system-specific options
- Resource limits and process monitoring

**Output:** Process execution enables Go programs to integrate with system tools, build automation pipelines, and create wrapper applications. The `exec` package provides both simple interfaces for basic use cases and sophisticated controls for complex process management scenarios.

**Security Considerations:**

- Always validate and sanitize external input before using it in commands
- Use `exec.CommandContext` with timeouts to prevent runaway processes
- Be cautious with shell execution and prefer direct command execution
- Consider using process sandboxing for untrusted code execution

[Inference] The Go runtime handles process cleanup automatically in most cases, but explicit process management may be necessary for long-running child processes or when dealing with process groups.

**Important Related Topics:**

- Memory-mapped files for large file operations
- File system watching and change notifications
- Inter-process communication (IPC) mechanisms
- System call interfaces and CGO integration
- Container and sandbox process execution
- Cross-platform compatibility considerations for system programming

---

