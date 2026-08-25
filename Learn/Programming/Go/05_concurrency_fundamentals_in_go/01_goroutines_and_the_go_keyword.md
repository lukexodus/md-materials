## Goroutines and the go keyword


Goroutines are lightweight threads managed by the Go runtime. They are far more efficient than operating system threads, with initial stack sizes of only a few kilobytes that can grow and shrink as needed.

**Key Points:**

- Goroutines are created using the `go` keyword followed by a function call
- The Go runtime multiplexes goroutines across available OS threads using the M:N threading model
- Goroutines have very low overhead - you can create thousands or even millions of them
- The main function runs in its own goroutine, and the program exits when the main goroutine completes

**Example:**

```go
func main() {
    // Launch a goroutine
    go func() {
        fmt.Println("Hello from goroutine")
    }()
    
    // Launch another goroutine with parameters
    go printMessage("Concurrent execution")
    
    time.Sleep(time.Second) // Wait for goroutines to complete
}

func printMessage(msg string) {
    fmt.Println(msg)
}
```

The scheduler uses a work-stealing algorithm where idle processors can steal work from busy ones, ensuring efficient load distribution. Goroutines are cooperatively scheduled, primarily yielding control during channel operations, system calls, or when calling the `runtime.Gosched()` function.

