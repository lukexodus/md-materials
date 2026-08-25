## Debugging Control Flow


### Trace Execution Path

Use conditional breakpoints to log execution without stopping:

**GDB:**

```gdb
break *0x401000
commands
  silent
  printf "Reached branch, EAX=%d\n", $eax
  continue
end
```

### Visualize Control Flow

Use debuggers to generate control flow graphs showing all possible paths:

**Example with GDB and Python:**

```python
# GDB Python script to trace branches
class BranchTracer(gdb.Breakpoint):
    def __init__(self, location):
        super().__init__(location)
        self.branches = []
    
    def stop(self):
        pc = gdb.selected_frame().pc()
        self.branches.append(pc)
        return False  # Don't stop execution

# Set breakpoints on all branch instructions
# Analyze branches list after execution
```

### Common Control Flow Bugs

**Off-by-One Errors:**

```asm
; Wrong: loops 11 times (0-10)
mov ecx, 10
loop_start:
    ; body
    dec ecx
    jge loop_start      ; Should be jg or test ecx before dec

; Correct: loops 10 times
mov ecx, 10
loop_start:
    ; body
    dec ecx
    jnz loop_start
```

**Incorrect Signed/Unsigned Comparison:**

```asm
mov eax, -1
cmp eax, 0
jg positive         ; Never jumps (correct: -1 is not > 0)
ja positive         ; ALWAYS jumps (wrong: 0xFFFFFFFF > 0 unsigned)
```

**Missing Break in Switch:**

```asm
case_1:
    mov ebx, 100
    ; Missing jmp end_switch - falls through to case_2!
case_2:
    mov ebx, 200
    jmp end_switch
```

**Stack Imbalance:**

```asm
function:
    push ebp
    ; ... code with conditional returns ...
    pop ebp
    ret
    
early_exit:
    ret             ; ERROR: EBP not restored!
```

**Key Points:**

- Control flow instructions modify the instruction pointer to change execution order
- Conditional jumps test FLAGS register bits set by previous instructions
- CMP performs subtraction without storing the result, only updating flags
- TEST performs bitwise AND without storing the result, only updating flags
- Loop instructions combine decrement and conditional jump
- Modern processors use branch prediction; unpredictable branches hurt performance
- Conditional moves can eliminate branches for better performance
- Understanding signed vs unsigned comparisons is critical for correct behavior
- Common patterns like if-else, loops, and switch statements map to specific instruction sequences

---

