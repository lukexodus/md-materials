## Debuggers


Debuggers allow examination and control of program execution, enabling inspection of memory, registers, and program flow.

### GDB (GNU Debugger)

GDB is a powerful, command-line debugger for Unix-like systems. It supports multiple languages and architectures.

**Starting GDB:**

```bash
# Debug a program
gdb ./program

# Debug with arguments
gdb --args ./program arg1 arg2

# Attach to running process
gdb -p 1234

# Debug core dump
gdb ./program core
```

**Basic Commands:**

**Running and Controlling Execution:**

```gdb
run                     # Start program execution
run arg1 arg2          # Start with arguments
start                  # Start and break at main
continue               # Continue execution after breakpoint
next                   # Execute next line (step over)
step                   # Execute next line (step into)
finish                 # Execute until current function returns
until                  # Execute until reaching specified location
kill                   # Terminate program
quit                   # Exit GDB
```

**Breakpoints:**

```gdb
break main                    # Break at function
break *0x400000              # Break at address
break file.c:10              # Break at line in file
break function if x == 5     # Conditional breakpoint
info breakpoints             # List all breakpoints
delete 1                     # Delete breakpoint 1
delete                       # Delete all breakpoints
disable 1                    # Disable breakpoint 1
enable 1                     # Enable breakpoint 1
```

**Examining Memory and Registers:**

```gdb
info registers              # Display all registers
info registers eax          # Display specific register
print $eax                  # Print register value
print variable              # Print variable value
print/x $eax               # Print in hexadecimal
print/t $eax               # Print in binary
print/d $eax               # Print in decimal

x/10xw 0x400000            # Examine 10 words in hex at address
x/s 0x400000               # Examine string at address
x/i $eip                   # Examine instruction at EIP
x/10i $eip                 # Examine 10 instructions

# Format: x/[count][format][size] address
# Format: x=hex, d=decimal, u=unsigned, t=binary, i=instruction, s=string
# Size: b=byte, h=halfword(2), w=word(4), g=giant(8)
```

**Stack and Backtrace:**

```gdb
backtrace                  # Show call stack
frame 0                    # Select stack frame
info frame                 # Information about current frame
info locals                # Display local variables
info args                  # Display function arguments
```

**Disassembly:**

```gdb
disassemble main           # Disassemble function
disassemble 0x400000       # Disassemble at address
disassemble /r main        # Show raw bytes
set disassembly-flavor intel   # Use Intel syntax
set disassembly-flavor att     # Use AT&T syntax
```

**Watchpoints:**

```gdb
watch variable             # Break when variable changes
rwatch variable            # Break when variable is read
awatch variable            # Break on read or write
```

**Assembly-Level Debugging:**

```gdb
layout asm                 # Show assembly layout
layout regs                # Show registers layout
stepi                      # Step one instruction
nexti                      # Step over one instruction

# Display instruction being executed
display/i $pc
```

**TUI Mode (Text User Interface):**

```gdb
tui enable                 # Enable TUI mode
layout src                 # Source code view
layout asm                 # Assembly view
layout split               # Both source and assembly
layout regs                # Register view
focus cmd                  # Focus on command window
focus src                  # Focus on source window
```

**GDB Configuration (~/.gdbinit):**

```gdb
set disassembly-flavor intel
set pagination off
set history save on
set history filename ~/.gdb_history
```

**Example Debugging Session:**

```gdb
$ gdb ./program
(gdb) break main
(gdb) run
(gdb) info registers
(gdb) x/10i $eip
(gdb) stepi
(gdb) print/x $eax
(gdb) continue
```

### OllyDbg

OllyDbg is a popular 32-bit Windows debugger with a graphical interface, particularly useful for reverse engineering.

**Key Features:**

- Graphical user interface with multiple panels
- Interactive disassembly window
- Register and flag visualization
- Stack and memory viewing
- Plugin support
- Pattern recognition for code analysis

**Main Windows:**

**CPU Window:** The primary debugging interface showing disassembly, registers, stack, and memory dump.

**Disassembly Pane:** Shows disassembled machine code with addresses, opcodes, and instructions. Supports comments and labels.

**Registers Pane:** Displays current register values with color coding for modified registers.

**Stack Pane:** Shows stack contents with automatic annotation of return addresses and parameters.

**Memory Dump Pane:** Hexadecimal view of memory contents.

**Basic Operations:**

**Navigation:**

- F7: Step into (execute one instruction)
- F8: Step over (execute instruction, skip over calls)
- F9: Run (continue execution)
- Ctrl+F9: Execute until return
- Ctrl+F2: Restart program
- Alt+F9: Execute until user code

**Breakpoints:**

- F2: Toggle breakpoint at current instruction
- Software breakpoints: Modify code temporarily (INT3)
- Hardware breakpoints: Use CPU debug registers (limited to 4)
- Memory breakpoints: Break on memory access
- Conditional breakpoints: Break when condition is true

**Analysis:**

- Ctrl+A: Analyze code (identify functions and procedures)
- Right-click on function: Follow in new window
- Space: Assemble (modify instructions)
- Semicolon: Add comment
- Colon: Add label

**Memory Operations:**

- Ctrl+G: Go to address
- Ctrl+B: Binary search
- Ctrl+E: Edit data
- Right-click: Search for references, patterns

**Searching:**

- Search for all referenced strings
- Search for command sequences
- Search for constant values
- Search for API calls

**Plugins:** OllyDbg supports plugins that extend functionality, such as anti-anti-debugging tools, script execution, and advanced analysis features.

### x64dbg

x64dbg is a modern, open-source debugger for Windows supporting both 32-bit (x32dbg) and 64-bit (x64dbg) applications.

**Key Features:**

- Modern interface with tabbed debugging
- Support for both 32-bit and 64-bit
- Plugin system compatible with some OllyDbg plugins
- Integrated memory map viewer
- Call stack with symbols
- Script engine
- Thread viewing

**Main Interface:**

**CPU Tab:** Shows disassembly, registers, stack, and memory dump similar to OllyDbg.

**Memory Map:** Displays all allocated memory regions with permissions and module information.

**Symbols:** Shows loaded symbols from PDB files or generated from exports.

**Call Stack:** Displays function call chain with return addresses.

**Threads:** Lists all threads with their current state.

**Handles:** Shows open handles (files, registry keys, etc.).

**Basic Commands:**

**Execution Control:**

- F7: Step into
- F8: Step over
- F9: Run
- Ctrl+F2: Restart
- F12: Pause execution

**Breakpoints:**

- F2: Toggle breakpoint
- Hardware breakpoints on execution, read, write
- Conditional breakpoints with expressions
- Exception breakpoints
- Memory access breakpoints

**Analysis Features:**

- Automatic analysis on load
- Xref (cross-reference) analysis
- String references
- Function recognition
- Control flow graph visualization

**Scripting:** x64dbg includes a scripting engine for automating debugging tasks:

```
bp MessageBoxA
run
log "MessageBox called"
bc MessageBoxA
```

**Command Line:** Built-in command line interface for advanced operations:

```
bp address              # Set breakpoint
bc address              # Clear breakpoint
log "text"              # Print to log
dump address            # Dump memory
dis address             # Disassemble at address
```

**Advanced Features:**

- Trace recording and replay
- Animation mode for automated stepping
- Pattern scanning
- Yara rule integration
- Remote debugging support

### WinDbg

WinDbg is Microsoft's debugger for Windows, supporting both user-mode and kernel-mode debugging. It's particularly powerful for system-level debugging and crash dump analysis.

**Key Features:**

- User-mode and kernel-mode debugging
- Crash dump analysis
- Time-travel debugging (in WinDbg Preview)
- Symbol server support
- Powerful command language
- Extension DLLs for specialized debugging

**Starting WinDbg:**

```
windbg program.exe                    # Debug executable
windbg -p 1234                        # Attach to process
windbg -z crash.dmp                   # Open crash dump
windbg -k                             # Kernel debugging
```

**Basic Commands:**

**Execution Control:**

```
g                       # Go (continue execution)
p                       # Step over
t                       # Step into (trace)
gu                      # Go up (execute until return)
q                       # Quit
.restart               # Restart debugging session
```

**Breakpoints:**

```
bp address              # Set breakpoint
bu address              # Set unresolved breakpoint
bl                      # List breakpoints
bc *                    # Clear all breakpoints
bd 0                    # Disable breakpoint 0
be 0                    # Enable breakpoint 0
bp address "commands"   # Breakpoint with commands
```

**Examining Data:**

```
r                       # Display registers
r eax                   # Display EAX register
r eax=5                 # Set EAX to 5

d address               # Display memory (default format)
db address              # Display bytes
dw address              # Display words
dd address              # Display dwords
dq address              # Display qwords
da address              # Display ASCII string
du address              # Display Unicode string
dc address              # Display dwords with ASCII

? expression            # Evaluate expression
dt variable             # Display type (structure)
dt ntdll!_PEB           # Display structure definition
```

**Disassembly:**

```
u address               # Unassemble (disassemble)
uf function             # Unassemble function
ub address              # Unassemble backwards
```

**Stack and Context:**

```
k                       # Display call stack
kb                      # Stack with first 3 parameters
kv                      # Stack with frame information
.frame n                # Switch to frame n
dv                      # Display local variables
```

**Symbols:**

```
.sympath srv*c:\symbols*https://msdl.microsoft.com/download/symbols
.reload                 # Reload symbols
lm                      # List loaded modules
x module!symbol         # Examine symbols
ln address              # List nearest symbol to address
```

**Memory Searching:**

```
s -b address L?length pattern      # Search bytes
s -a address L?length "string"     # Search ASCII
s -u address L?length "string"     # Search Unicode
```

**Extensions:**

```
!analyze -v             # Analyze crash dump
!peb                    # Display Process Environment Block
!teb                    # Display Thread Environment Block
!address                # Display memory usage
!heap                   # Heap analysis
!handle                 # Handle information
```

**WinDbg Preview:**

The modern version of WinDbg includes:

- Modern UI with dark theme
- Time Travel Debugging (TTD) for recording and replaying execution
- Integrated disassembly window
- Memory window with live updates
- Better scripting support with JavaScript
- Improved command window with syntax highlighting

**Time Travel Debugging:**

```
# Record execution
ttd.exe -out recording.run program.exe

# Load recording in WinDbg Preview
windbgx -z recording.run

# Navigate time
!tt 0                   # Go to start
!tt 100                 # Go to position 100
g-                      # Go backwards
p-                      # Step backwards
```

**JavaScript Scripting:**

```javascript
// Example: Find all calls to a function
function findCalls(addr) {
    var calls = [];
    for (var instr of host.currentProcess.Memory.GetInstructions(addr)) {
        if (instr.Mnemonic === "call") {
            calls.push(instr.Address);
        }
    }
    return calls;
}
```

### Debugger Comparison

| Feature             | GDB         | OllyDbg             | x64dbg              | WinDbg              |
| ------------------- | ----------- | ------------------- | ------------------- | ------------------- |
| Platform            | Unix/Linux  | Windows             | Windows             | Windows             |
| UI                  | CLI/TUI     | GUI                 | GUI                 | GUI/CLI             |
| 64-bit Support      | Yes         | No                  | Yes                 |                     |
| Feature             | GDB         | OllyDbg             | x64dbg              | WinDbg              |
| Platform            | Unix/Linux  | Windows             | Windows             | Windows             |
| UI                  | CLI/TUI     | GUI                 | GUI                 | GUI/CLI             |
| 64-bit Support      | Yes         | No                  | Yes                 | Yes                 |
| Kernel Debugging    | Limited     | No                  | No                  | Yes                 |
| Scripting           | Python      | Plugins             | Script engine       | Commands/JavaScript |
| Source-level        | Yes         | No                  | Limited             | Yes                 |
| Crash Dump Analysis | Yes         | No                  | Limited             | Excellent           |
| Remote Debugging    | Yes         | No                  | Yes                 | Yes                 |
| Best For            | Development | Reverse engineering | Reverse engineering | System debugging    |

### Debugging Techniques

### Breakpoint Strategies

**Software Breakpoints:** The debugger replaces the instruction at the target address with a breakpoint instruction (INT3 on x86, which is opcode 0xCC). When the CPU executes this instruction, it generates an exception that the debugger catches.

**Advantages:** Unlimited number of breakpoints possible.

**Disadvantages:** Modifies code in memory, detectable by anti-debugging techniques.

**Hardware Breakpoints:** Use CPU debug registers (DR0-DR7 on x86) to trigger exceptions when specific addresses are accessed. No code modification required.

**DR0-DR3:** Store breakpoint addresses (4 available on x86/x64).

**DR6:** Debug status register (indicates which breakpoint triggered).

**DR7:** Debug control register (configures breakpoint conditions).

**Breakpoint Types:**

- Execution: Break when instruction at address is executed
- Write: Break when memory location is written
- Read/Write: Break when memory location is accessed
- I/O: Break on I/O port access (rarely used)

**Advantages:** No code modification, harder to detect.

**Disadvantages:** Limited to 4 simultaneous breakpoints on x86/x64.

**Memory Breakpoints:** Set breakpoints on memory regions by changing page protection. When the protected memory is accessed, an access violation exception occurs that the debugger intercepts.

**Conditional Breakpoints:** Break only when a specified condition is true. The debugger automatically evaluates the condition each time the breakpoint is hit.

**Example:**

```
break function if counter > 100
bp address ".if (eax == 5) {} .else {gc}"
```

### Tracing and Logging

**Instruction Tracing:** Record every instruction executed, useful for understanding program flow.

**Example in GDB:**

```gdb
set logging on
set logging file trace.txt
while 1
  stepi
  x/i $pc
end
```

**Call Tracing:** Record function calls and returns to understand program structure.

**Example in x64dbg:**

```
TraceIntoConditional dest:0x401000
```

**System Call Tracing:** Monitor interactions with the operating system.

**Linux (strace):**

```bash
strace ./program
strace -e open,read,write ./program     # Trace specific syscalls
strace -p 1234                          # Attach to running process
```

**Windows (API Monitor):** Third-party tools can intercept and log API calls.

### Memory Inspection

**Stack Analysis:** Examine the stack to understand function calls, parameters, and local variables.

**Stack Layout (x86 cdecl calling convention):**

```
Higher addresses
+------------------+
| Parameter N      |
+------------------+
| ...              |
+------------------+
| Parameter 2      |
+------------------+
| Parameter 1      |
+------------------+
| Return Address   |  <- Pushed by CALL instruction
+------------------+
| Saved EBP        |  <- Pushed by function prologue
+------------------+  <- EBP points here
| Local Variable 1 |
+------------------+
| Local Variable 2 |
+------------------+
| ...              |  <- ESP points here
Lower addresses
```

**Examining Stack in Debugger:**

```gdb
# GDB
info frame
x/20xw $esp                # Display 20 words from stack pointer
backtrace                  # Show call chain
```

```
; WinDbg
k                          # Display call stack
dds esp                    # Display stack with symbols
!analyze -v                # Analyze stack for crashes
```

**Heap Analysis:** Examine dynamically allocated memory to find memory leaks or corruption.

**GDB with Valgrind:**

```bash
valgrind --leak-check=full ./program
valgrind --track-origins=yes ./program
```

**WinDbg Heap Commands:**

```
!heap                      # List all heaps
!heap -stat                # Heap statistics
!heap -flt s <size>        # Find allocations of specific size
!analyze -v                # Detect heap corruption in crash dumps
```

**Pattern Recognition:** Search for known patterns in memory (shellcode signatures, format strings, encryption keys).

**Example in x64dbg:**

```
Pattern scan: "\x55\x8B\xEC"    # Function prologue
```

### Anti-Debugging Detection and Bypass

**Common Anti-Debugging Techniques:**

**IsDebuggerPresent:** Windows API that checks PEB (Process Environment Block) flag.

**Detection:**

```asm
call IsDebuggerPresent
test eax, eax
jnz debugger_detected
```

**Bypass:** Modify return value or patch the PEB flag.

```gdb
# In GDB/x64dbg
Set BeingDebugged flag to 0 at PEB+0x2
```

**PEB Checks:** Direct inspection of Process Environment Block fields.

```asm
mov eax, fs:[0x30]         ; Get PEB address
movzx eax, byte [eax+0x2]  ; BeingDebugged flag
test eax, eax
jnz debugger_detected
```

**Timing Checks:** Measure execution time to detect single-stepping.

```asm
rdtsc                      ; Read Time Stamp Counter
mov ebx, eax
; ... code ...
rdtsc
sub eax, ebx
cmp eax, threshold
ja debugger_detected       ; Too slow, debugger present
```

**Hardware Breakpoint Detection:** Check debug registers for hardware breakpoints.

```asm
mov eax, dr0               ; Privileged instruction in user mode
; If debugger present, this won't cause exception
```

**INT Scanning:** Search for software breakpoints (0xCC bytes) in code.

```asm
lea edi, [code_start]
mov ecx, code_length
mov al, 0xCC
repne scasb
jz breakpoint_found
```

**Bypass Strategies:**

**Plugin-Based:** Use debugger plugins that automatically handle anti-debugging techniques (ScyllaHide, TitanHide).

**Manual Patching:** Modify the anti-debugging checks in memory or on disk.

**Example: NOP out check:**

```
Original: test eax, eax
          jnz detected
Patch to: nop
          nop
          nop
          nop
```

**API Hooking:** Intercept API calls to return false information.

**Virtual Machine Detection:** Some programs detect virtual machines or sandboxes.

**Detection Methods:**

- Check for VM-specific registry keys or files
- Execute VM-specific instructions
- Timing attacks (VMs are slower)
- Hardware fingerprinting

**Bypass:** Run on physical hardware or use VM hardening techniques.

### Debugging Multithreaded Programs

**Thread Identification:**

**GDB:**

```gdb
info threads               # List all threads
thread 2                   # Switch to thread 2
thread apply all bt        # Backtrace all threads
set scheduler-locking on   # Lock scheduler to current thread
```

**WinDbg:**

```
~                          # List threads
~2s                        # Switch to thread 2
~*k                        # Stack trace all threads
!locks                     # Display lock information
!cs                        # Display critical sections
```

**Race Condition Debugging:** [Inference] Setting breakpoints in multiple threads and examining shared data can help identify race conditions, though this approach may not consistently reproduce the issue due to timing changes introduced by debugging.

**Deadlock Detection:**

**WinDbg:**

```
!locks                     # Display all locks
!cs -l                     # Display critical sections with owners
!analyze -v -hang          # Analyze hang dump
```

**Thread Synchronization Analysis:** Examine mutexes, semaphores, and other synchronization primitives.

**Example in GDB:**

```gdb
# Conditional breakpoint on mutex
break pthread_mutex_lock
condition 1 mutex == 0x12345678
```

### Remote Debugging

**GDB Remote Debugging:**

**On target machine:**

```bash
gdbserver :1234 ./program
gdbserver --attach :1234 <pid>
```

**On development machine:**

```gdb
target remote 192.168.1.100:1234
```

**WinDbg Remote Debugging:**

**Setup debugging server:**

```cmd
windbg -server tcp:port=1234 -p <pid>
```

**Connect from client:**

```cmd
windbg -remote tcp:server=192.168.1.100,port=1234
```

**Advantages:**

- Debug on embedded systems or servers
- Minimal impact on target system
- Separate debugging environment from target

### Crash Dump Analysis

**Linux Core Dumps:**

**Enable core dumps:**

```bash
ulimit -c unlimited
```

**Analyze core dump:**

```gdb
gdb ./program core
bt                         # Backtrace
info registers             # Register state at crash
info locals                # Local variables
```

**Generate core dump of running process:**

```bash
gcore <pid>
```

**Windows Crash Dumps:**

**Types:**

- Minidump: Small, contains essential information
- Full dump: Complete memory snapshot

**Analyze in WinDbg:**

```
windbg -z crash.dmp
!analyze -v                # Automatic analysis
.ecxr                      # Set context to exception
k                          # Stack trace
!peb                       # Process information
!teb                       # Thread information
lm                         # Loaded modules
```

**Configure Windows Error Reporting:**

```
Registry: HKLM\Software\Microsoft\Windows\Windows Error Reporting\LocalDumps
- DumpFolder: Dump location
- DumpType: 0=Custom, 1=Mini, 2=Full
- DumpCount: Number of dumps to keep
```

**Post-Mortem Debugging Strategy:**

1. Examine exception type and code
2. Check instruction pointer and disassembly
3. Analyze call stack
4. Examine local variables and parameters
5. Check heap and stack for corruption
6. Review loaded modules and their versions
7. Look for access violations or null pointer dereferences

### Reverse Engineering Workflow

**Initial Analysis:**

1. Identify file format and architecture
2. Check for packers or obfuscation
3. Examine imports/exports
4. Find entry point
5. Identify compiler and programming language

**Static Analysis:** Examine code without execution.

**Tools:**

- IDA Pro: Industry-standard disassembler
- Ghidra: Free NSA tool with decompiler
- Binary Ninja: Modern disassembler with IL
- Radare2: Open-source reverse engineering framework

**Dynamic Analysis:** Execute and observe behavior.

**Steps:**

1. Set breakpoints at interesting functions (APIs, crypto, etc.)
2. Trace execution flow
3. Monitor memory changes
4. Log API calls and parameters
5. Examine algorithm implementations

**Combining Static and Dynamic:**

- Use static analysis to identify targets
- Use dynamic analysis to understand runtime behavior
- Patch and test hypotheses
- Document findings

### Debugging Best Practices

**Reproduce the Issue:** [Inference] Consistently reproducing a bug makes it much easier to debug, as you can test fixes and observe behavior reliably.

**Minimize Test Case:** Reduce the problem to the smallest code that demonstrates the issue.

**Use Assertions:** Add assertions to catch invalid states early.

```c
assert(pointer != NULL);
assert(index < array_size);
```

**Logging:** Strategic logging provides insight without breakpoints.

**Levels:**

- ERROR: Critical failures
- WARN: Potential issues
- INFO: Significant events
- DEBUG: Detailed diagnostic information
- TRACE: Very detailed execution flow

**Version Control:** Track changes to identify when bugs were introduced (git bisect).

**Read Documentation:** Understand API contracts and expected behavior before assuming a bug.

**Check Assumptions:** Verify your understanding of how code should work.

**Take Breaks:** Mental fatigue reduces debugging effectiveness.

### Debugging Assembly-Specific Issues

**Register Corruption:** Track where registers are modified unexpectedly.

```gdb
# Set watchpoint on register (hardware breakpoint)
watch $eax
```

**Stack Imbalance:** Mismatch between pushes and pops causes crashes.

**Symptoms:**

- Function returns to wrong address
- ESP pointing to invalid location
- Segmentation fault on return

**Detection:**

```gdb
# Compare ESP before and after function call
break function
commands
  print $esp
  continue
end
```

**Alignment Issues:** Some instructions require aligned memory access.

**Example:**

```asm
movdqa xmm0, [eax]    ; Requires 16-byte alignment
```

**Segmentation Fault:** Occurs on invalid memory access.

**Common Causes:**

- Null pointer dereference
- Writing to read-only memory (.text section)
- Stack overflow
- Use after free
- Buffer overflow

**Investigation:**

```gdb
# When program crashes
where                  # Show where crash occurred
info registers         # Check register values
x/i $pc                # Examine instruction
x/10xw $esp            # Examine stack
```

**Calling Convention Violations:** Parameters passed incorrectly or stack not cleaned up.

**cdecl:** Caller cleans stack

```asm
push param
call function
add esp, 4             ; Caller cleanup
```

**stdcall:** Callee cleans stack

```asm
push param
call function          ; Function cleans up internally
```

**Mixing conventions causes stack corruption.**

### Debugging Optimization Issues

**Compiler Optimizations:** Optimized code behaves differently from source.

**Effects:**

- Variables optimized away
- Code reordering
- Loop unrolling
- Inlining

**Strategies:**

- Debug with optimizations disabled (-O0)
- Use volatile keyword for critical variables
- Inspect disassembly to understand actual behavior

**Example:**

```c
// Variable optimized away
int counter = 0;
while (condition) {
    counter++;  // If counter never used, may be eliminated
}
```

**Compiler assumes no undefined behavior. Bugs may only appear with optimizations.**

### Advanced Debugging Features

**Reverse Debugging:** Execute backwards to find when state became invalid.

**GDB:**

```gdb
target record-full     # Start recording
continue               # Run forward
reverse-continue       # Run backward
reverse-step           # Step backward
```

**Conditional Logging:** Log without stopping.

**GDB:**

```gdb
break function
commands
  silent
  printf "Called with param=%d\n", param
  continue
end
```

**Scripting Debuggers:**

**GDB Python:**

```python
class CustomBreakpoint(gdb.Breakpoint):
    def stop(self):
        frame = gdb.selected_frame()
        eax = frame.read_register("eax")
        print(f"EAX = {eax}")
        return False  # Don't stop execution

CustomBreakpoint("function")
```

**WinDbg JavaScript:**

```javascript
function invokeScript() {
    var addr = host.parseInt64("poi(esp+4)");
    host.diagnostics.debugLog("Parameter: " + addr.toString(16) + "\n");
}
```

### Performance Profiling

While not strictly debugging, profiling helps identify performance issues.

**Linux Tools:**

- perf: CPU performance counters
- gprof: Function-level profiling
- Valgrind (callgrind): Detailed profiling

**Example:**

```bash
# Profile with perf
perf record ./program
perf report

# Profile with gprof
gcc -pg program.c -o program
./program
gprof program gmon.out
```

**Windows Tools:**

- Visual Studio Profiler
- Intel VTune
- AMD μProf

**Assembly-Level Profiling:** Identify hot spots at instruction level.

```bash
perf record -e cycles:u ./program
perf annotate
```

---

