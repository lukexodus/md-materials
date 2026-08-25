## Step debugging


Key Points

Step debugging is the interactive process of executing code one instruction at a time to inspect the program's state (variables, memory, call stack) in real-time. Unlike "printf debugging," which relies on static snapshots of state printed to a console, step debugging allows for dynamic exploration of logic flow and data mutation.

- **Execution Control Primitives:**
    
    - **Step Over:** Executes the current line of code. If the line contains a function call, the function executes completely, and the debugger pauses at the next line in the _current_ scope. Used when you trust the function being called.
        
    - **Step Into:** Executes the current line. If the line contains a function call, the debugger enters that function and pauses at its first line. Used to investigate the internal logic of a helper function.
        
    - **Step Out:** Resumes execution until the current function returns, pausing immediately after the return in the calling function. Used when you have finished inspecting the current function and want to return to the higher-level logic.
        
    - **Resume/Continue:** Runs the program freely until the next breakpoint is hit or the program terminates.
        
- **Advanced Breakpoint Strategies:**
    
    - **Conditional Breakpoints:** The debugger pauses only when a specific expression evaluates to true (e.g., `user_id == 1054`). This is critical for debugging loops or high-frequency events without manually stepping through hundreds of iterations.
        
    - **Hit Count:** Pauses execution only after a line has been executed $N$ times.
        
    - **Logpoints/Tracepoints:** Prints a message to the console when hit without pausing execution. This injects logging dynamically without modifying source code.
        
- **State Inspection:**
    
    - **Call Stack:** Displays the hierarchy of active subroutines. It answers "How did I get here?" and reveals recursion depth or unexpected caller contexts.
        
    - **Watch Window:** Allows tracking specific variables or expressions (e.g., `list.size() > 5`) that update in real-time as you step through the code.
        
    - **Immediate Window / Debug Console:** An interactive REPL that executes in the context of the paused application, allowing you to modify variables or test functions with current data.
        

Example

Consider a scenario debugging a Python function intended to filter even numbers but returning an empty list due to a scope error.

Python

```
def filter_evens(numbers):
    result = []
    for num in numbers:
        # BREAKPOINT HERE (Line 4)
        if num % 2 == 0:
            result = [num]  # Logic Error: Overwriting list instead of appending
    return result

data = [1, 2, 3, 4]
output = filter_evens(data)
```

Output

When debugging this session:

1. **Hit Breakpoint:** Execution pauses at `if num % 2 == 0` with `num=1`.
    
2. **Step Over:** Condition is false. Loop continues.
    
3. **Step Over:** `num` becomes 2. Condition is true.
    
4. **Step Into:** Debugger moves to `result = [num]`.
    
5. **Inspection:** The developer hovers over `result`. Before execution, it is `[]`.
    
6. **Step Over:** Execution completes. `result` becomes `[2]`.
    
7. **Loop Continues:** `num` becomes 3. Skipped.
    
8. **Loop Continues:** `num` becomes 4.
    
9. **Step Over:** `result = [num]` executes.
    
10. **Inspection:** The developer sees `result` change from `[2]` to `[4]`.
    
11. **Realization:** The developer notices `result` is being replaced, not appended to. The fix (`result.append(num)`) becomes obvious.
    

Conclusion

Step debugging is the most precise method for validating assumptions about control flow and state mutation. While logging is superior for post-mortem analysis of production issues, step debugging is the gold standard for active development and complex logic verification. It forces the developer to confront the actual behavior of the code, often revealing that the error lies not in the variable values, but in the path the code took to derive them.

Next Steps

Identify a complex loop or recursive function in your current project. Set a Conditional Breakpoint to stop only on a specific edge case (e.g., the last iteration or a null value) to practice isolating issues without manual stepping.

---

