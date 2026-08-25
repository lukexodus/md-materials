## `std::process`


`std::process` provides functionality to interact with system processes, including spawning new processes, handling input/output, and managing exit statuses. Below are key components of `std::process`:

---

### **`Command` - Running External Processes**

Used to spawn and interact with system processes.

```rust
use std::process::Command;

let output = Command::new("echo")
    .arg("Hello, world!")
    .output()
    .expect("Failed to execute command");

println!("{}", String::from_utf8_lossy(&output.stdout));
```

---

### **`Child` - Managing Running Processes**

Represents a child process spawned from `Command`.

```rust
use std::process::{Command, Child};

let mut child: Child = Command::new("sleep")
    .arg("2")
    .spawn()
    .expect("Failed to start process");

let _ = child.wait().expect("Failed to wait on child");
println!("Process finished.");
```

---

### **`Output` - Capturing Process Output**

Contains the `stdout`, `stderr`, and exit status of a completed process.

```rust
use std::process::Command;

let output = Command::new("ls")
    .output()
    .expect("Failed to execute command");

println!("Status: {:?}", output.status);
println!("Stdout: {}", String::from_utf8_lossy(&output.stdout));
println!("Stderr: {}", String::from_utf8_lossy(&output.stderr));
```

---

### **`ExitStatus` - Handling Process Exit Codes**

Represents the status of a finished process.

```rust
use std::process::Command;

let status = Command::new("ls")
    .status()
    .expect("Failed to execute command");

if status.success() {
    println!("Command executed successfully.");
} else {
    println!("Command failed with status: {:?}", status);
}
```

---

### **`exit()` - Terminating the Current Process**

Exits the program with a specified exit code.

```rust
use std::process;

fn main() {
    println!("Exiting with code 1");
    process::exit(1);
}
```

---

### **`abort()` - Immediate Termination**

Unlike `exit()`, `abort()` terminates the process immediately without running destructors.

```rust
use std::process;

fn main() {
    println!("Process aborting...");
    process::abort();
}
```

---

### **`Command::stdin()`, `stdout()`, `stderr()` - Redirecting Streams**

These methods allow you to set up pipes for the child process’s standard input, output, and error streams.

```rust
use std::process::{Command, Stdio};

let mut child = Command::new("grep")
    .arg("hello")
    .stdin(Stdio::piped())   // Redirect input
    .stdout(Stdio::piped())  // Capture output
    .spawn()
    .expect("Failed to start process");

// You can write to `child.stdin` if needed
```

---

### **`Command::env()` - Setting Environment Variables**

Modifies the environment variables for the spawned process.

```rust
use std::process::Command;

let output = Command::new("printenv")
    .env("MY_VAR", "Hello, Rust!")
    .output()
    .expect("Failed to execute command");

println!("{}", String::from_utf8_lossy(&output.stdout));
```

---

### **`Command::env_remove()` - Removing Environment Variables**

Removes a specific environment variable for the new process.

```rust
use std::process::Command;

let output = Command::new("printenv")
    .env_remove("MY_VAR")
    .output()
    .expect("Failed to execute command");

println!("{}", String::from_utf8_lossy(&output.stdout));
```

---

### **`Command::current_dir()` - Setting Working Directory**

Runs the command in a specific directory.

```rust
use std::process::Command;

let output = Command::new("ls")
    .current_dir("/tmp")
    .output()
    .expect("Failed to execute command");

println!("{}", String::from_utf8_lossy(&output.stdout));
```

---

### **`Command::spawn()` vs. `Command::output()` vs. `Command::status()`**

- **`spawn()`**: Runs the command asynchronously, returning a `Child` process.
- **`output()`**: Runs the command synchronously, capturing `stdout` and `stderr`.
- **`status()`**: Runs the command synchronously, returning only the exit status.

Example:

```rust
use std::process::Command;

let child = Command::new("sleep").arg("5").spawn();
println!("Process spawned!");

let output = Command::new("echo").arg("Hello").output();
println!("Captured output!");

let status = Command::new("ls").status();
println!("Exit status checked!");
```

---

### **`Command::kill()` - Terminating a Process**

Terminates a running child process.

```rust
use std::process::{Command, Stdio};
use std::thread;
use std::time::Duration;

let mut child = Command::new("sleep")
    .arg("10")
    .stdout(Stdio::null())
    .spawn()
    .expect("Failed to start process");

thread::sleep(Duration::from_secs(2)); // Let it run for a while
child.kill().expect("Failed to kill process");
```

---

### **`Command::wait()` - Waiting for a Process**

Blocks execution until the child process exits.

```rust
use std::process::Command;

let mut child = Command::new("sleep")
    .arg("3")
    .spawn()
    .expect("Failed to start process");

child.wait().expect("Failed to wait for process");
println!("Process finished.");
```

---

### **`Command::wait_with_output()` - Capturing Output & Waiting**

Waits for the process to finish while collecting its output.

```rust
use std::process::Command;

let output = Command::new("echo")
    .arg("Rust!")
    .output()
    .expect("Failed to execute command");

println!("{}", String::from_utf8_lossy(&output.stdout));
```

---

### **`CommandExt` (Unix-specific) - Process Group Management**

For Unix-specific functionality, Rust provides `std::os::unix::process::CommandExt`.

```rust
use std::process::Command;
use std::os::unix::process::CommandExt;

Command::new("ls")
    .uid(1000)  // Set user ID
    .gid(1000)  // Set group ID
    .exec();    // Replace current process
```

### **`Command::arg()` and `args()` - Passing Command-line Arguments**

- **`arg()`**: Adds a single argument.
- **`args()`**: Adds multiple arguments at once.

```rust
use std::process::Command;

let output = Command::new("echo")
    .arg("Hello,")
    .arg("Rust!")
    .output()
    .expect("Failed to execute command");

println!("{}", String::from_utf8_lossy(&output.stdout));
```

```rust
use std::process::Command;

let output = Command::new("echo")
    .args(&["Hello,", "Rust!"])
    .output()
    .expect("Failed to execute command");

println!("{}", String::from_utf8_lossy(&output.stdout));
```

---

### **`Command::output()` - Running a Process and Capturing Output**

Captures both **stdout** and **stderr**.

```rust
use std::process::Command;

let output = Command::new("echo")
    .arg("Captured Output")
    .output()
    .expect("Failed to execute command");

println!("Output: {}", String::from_utf8_lossy(&output.stdout));
```


---

### **`std::process::id()` - Get Process ID**

Retrieves the current process ID.

```rust
use std::process;

fn main() {
    println!("Process ID: {}", process::id());
}
```

---

### **`std::process::Child` - Managing Child Processes**

Handles a spawned process.

```rust
use std::process::{Command, Child};

let mut child: Child = Command::new("sleep")
    .arg("5")
    .spawn()
    .expect("Failed to start process");

println!("Process started...");
child.wait().expect("Failed to wait for process");
println!("Process finished.");
```

---

### **`Child::try_wait()` - Non-blocking Check for Completion**

Checks if a child process has finished without blocking execution.

```rust
use std::process::Command;
use std::thread;
use std::time::Duration;

let mut child = Command::new("sleep")
    .arg("5")
    .spawn()
    .expect("Failed to start process");

thread::sleep(Duration::from_secs(1));

match child.try_wait() {
    Ok(Some(status)) => println!("Process exited: {:?}", status),
    Ok(None) => println!("Process is still running"),
    Err(e) => eprintln!("Error checking process status: {}", e),
}
```

---

### **`Child::kill()` - Force Terminate a Process**

Stops a running child process.

```rust
use std::process::{Command, Stdio};
use std::thread;
use std::time::Duration;

let mut child = Command::new("sleep")
    .arg("10")
    .stdout(Stdio::null())
    .spawn()
    .expect("Failed to start process");

thread::sleep(Duration::from_secs(2));
child.kill().expect("Failed to kill process");
println!("Process killed.");
```


