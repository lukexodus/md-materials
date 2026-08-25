## Overview


**GDB (GNU Debugger)** is a powerful debugging tool commonly used for debugging C and C++ programs. It helps you control the execution of your program, set breakpoints, inspect variables, and trace program flow. Below is a comprehensive guide to using GDB for C++ debugging.

### 1. **Compiling with Debug Information**

Before you start debugging with GDB, compile your C++ program with the `-g` option to include debugging information.

```bash
g++ -g your_program.cpp -o your_program
```

### 2. **Starting GDB**

To start GDB, run:

```bash
gdb ./your_program
```

This will load the program into GDB. If you want to immediately start debugging with arguments:

```bash
gdb --args ./your_program arg1 arg2
```

### 3. **Basic Commands**

- **Run the program**:
  ```bash
  run [arguments]
  ```
  Starts executing your program. You can pass program arguments after `run`.

- **Breakpoints**:
  - **Set a breakpoint**:
    ```bash
    break main
    break 10  # Set breakpoint at line 10
    break your_function  # Set breakpoint at a function
    ```
  - **Delete a breakpoint**:
    ```bash
    delete 1  # Deletes the first breakpoint
    ```
  - **List all breakpoints**:
    ```bash
    info breakpoints
    ```
  - **Conditional breakpoints**:
    ```bash
    break 10 if i == 5
    ```

- **Continue execution**:
  ```bash
  continue
  ```
  Continues execution until the next breakpoint or program termination.

- **Step through code**:
  - **Step into a function**:
    ```bash
    step
    ```
  - **Step over a function** (i.e., execute it without stepping into it):
    ```bash
    next
    ```

- **Finish execution of a function**:
  ```bash
  finish
  ```
  This command allows you to run until the current function returns.

- **Exit GDB**:
  ```bash
  quit
  ```

### 4. **Inspecting Program State**

- **View variables**:
  - **Print a variable**:
    ```bash
    print variable_name
    ```
    Example:
    ```bash
    print i
    ```
  - **Print expression**:
    ```bash
    print 2 + 3
    ```
  - **Print value of `this` pointer in a class**:
    ```bash
    print *this
    ```

- **Examine memory**:
  - **Examine memory at a specific address**:
    ```bash
    x/nfu address
    ```
    where:
    - `n` is the number of units (optional)
    - `f` is the format (optional: `x` for hex, `d` for decimal, `s` for string, etc.)
    - `u` is the unit size (`b` for bytes, `h` for halfwords, `w` for words, etc.)

    Example:
    ```bash
    x/4xw &variable_name  # Examines memory for 4 words at variable address
    ```

- **Backtrace (show call stack)**:
  ```bash
  backtrace
  bt
  ```
  This shows the current function call stack, helping you understand how you arrived at the current point.

- **Frame switching**:
  - **Select a frame**:
    ```bash
    frame n  # Switch to frame number n
    ```
  - **Show the current frame**:
    ```bash
    info frame
    ```

### 5. **Advanced Features**

- **Watchpoints** (break on variable change):
  ```bash
  watch variable_name
  ```
  Stops execution when the variable is modified.

- **Conditional watchpoints**:
  ```bash
  watch variable_name if condition
  ```

- **Disassemble code**:
  ```bash
  disassemble function_name
  ```
  Shows the assembly code for a function.

- **TUI Mode** (Text User Interface for code and variables):
  ```bash
  gdb -tui ./your_program
  ```
  Or within GDB, press `Ctrl + X` followed by `A` to toggle TUI mode.

- **Set variable**:
  You can set the value of variables while debugging:
  ```bash
  set variable_name = value
  ```
  Example:
  ```bash
  set i = 10
  ```

### 6. **Debugging Optimized Code**

Optimized code can make debugging challenging. Variables might get optimized away or their values might not be what you expect. Compile your program with:

```bash
g++ -g -O1 your_program.cpp -o your_program
```

### 7. **Threads Debugging**

- **List threads**:
  ```bash
  info threads
  ```

- **Switch between threads**:
  ```bash
  thread thread_number
  ```

- **Breakpoints in threads**:
  ```bash
  break function_name thread thread_number
  ```

### 8. **Core Dumps**

If your program crashes and generates a core dump, you can use it to analyze the crash:

1. Enable core dumps (for Linux):
   ```bash
   ulimit -c unlimited
   ```
2. Run your program. If it crashes, a `core` file will be generated.
3. Debug using:
   ```bash
   gdb ./your_program core
   ```

### 9. **Scripting and Automation**

You can write GDB scripts to automate repetitive tasks. Here's an example of a simple GDB script (`debug.gdb`):

```bash
break main
run
backtrace
info locals
```

Run it as:

```bash
gdb -x debug.gdb ./your_program
```

### 10. **Common GDB Tips**

- **Show line numbers**:
  ```bash
  list  # Shows source code around the current line
  list 10  # Shows 10 lines of code starting from line 10
  ```

- **Debug shared libraries**:
  ```bash
  set follow-fork-mode child  # Debug child process (e.g., shared libraries)
  ```

- **Handling signals**:
  ```bash
  handle SIGSEGV stop  # Stop execution on a segmentation fault
  ```

**Summary of Key Commands**:

| Command               | Description                                           |
|-----------------------|-------------------------------------------------------|
| `break`               | Set a breakpoint                                      |
| `run`                 | Start program execution                               |
| `next`                | Step over function calls                              |
| `step`                | Step into function calls                              |
| `continue`            | Continue execution until the next breakpoint          |
| `print`               | Display variable or expression value                  |
| `backtrace` / `bt`    | Show current call stack                               |
| `watch`               | Stop execution when a variable changes                |
| `info`                | Get information (breakpoints, frames, variables, etc.)|

This should give you a solid foundation for debugging C++ programs using GDB. Let me know if you'd like examples for specific cases!

***
