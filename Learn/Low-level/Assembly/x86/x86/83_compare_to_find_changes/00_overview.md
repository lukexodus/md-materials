## Overview

```

[Inference] Memory diffing identifies where keys are stored, how data transforms, and which regions are affected by specific operations.

### Dynamic Binary Instrumentation (DBI)

Modify program behavior at runtime without recompilation.

**Instrumentation Frameworks**:

**Intel PIN**: Powerful DBI framework for x86/x86-64:

```cpp
// PIN tool to count instructions
#include "pin.H"
UINT64 icount = 0;

VOID docount() { icount++; }

VOID Instruction(INS ins, VOID *v) {
    INS_InsertCall(ins, IPOINT_BEFORE, (AFUNPTR)docount, IEND);
}

int main(int argc, char *argv[]) {
    PIN_Init(argc, argv);
    INS_AddInstrumentFunction(Instruction, 0);
    PIN_StartProgram();
    return 0;
}
```

**DynamoRIO**: Open-source DBI framework, cross-platform:

```c
// DynamoRIO client to trace branches
static void event_basic_block(void *drcontext, void *tag, instrlist_t *bb,
                               bool for_trace, bool translating) {
    instr_t *instr, *next_instr;
    for (instr = instrlist_first(bb); instr != NULL; instr = next_instr) {
        next_instr = instr_get_next(instr);
        if (instr_is_cbr(instr)) {  // Conditional branch
            dr_insert_clean_call(drcontext, bb, instr, (void *)log_branch, 
                                 false, 1, OPND_CREATE_INTPTR(instr_get_app_pc(instr)));
        }
    }
}
```

**Frida**: Dynamic instrumentation toolkit with JavaScript API:

```javascript
// Frida script to hook function
Interceptor.attach(Module.findExportByName(null, "strcmp"), {
    onEnter: function(args) {
        console.log("strcmp called:");
        console.log("  arg1: " + Memory.readUtf8String(args[0]));
        console.log("  arg2: " + Memory.readUtf8String(args[1]));
    },
    onLeave: function(retval) {
        console.log("  result: " + retval);
        // Modify return value
        retval.replace(0);  // Make strcmp always return 0 (equal)
    }
});
```

[Inference] DBI frameworks enable sophisticated analysis like taint tracking, code coverage measurement, performance profiling, and behavior modification without source code or recompilation.

**Use Cases**:

- Tracing function calls and arguments
- Measuring code coverage
- Implementing custom analysis (taint tracking, information flow)
- Bypassing anti-debugging and anti-tampering
- Fuzzing instrumentation
- Performance profiling

### Anti-Debugging Detection and Evasion

Programs may detect debugging and alter behavior.

**Common Anti-Debugging Techniques**:

**Debugger Detection**:

```nasm
; Windows: Check for debugger present
mov eax, fs:[30h]           ; PEB (Process Environment Block)
movzx eax, byte [eax+2]     ; BeingDebugged flag
test eax, eax
jnz debugger_detected

; Linux: Check TracerPid in /proc/self/status
; Read file and look for "TracerPid: 0"
```

**Timing Checks**: Measuring execution time to detect single-stepping:

```nasm
rdtsc                       ; Read timestamp counter
mov ebx, eax
; Execute instructions
rdtsc
sub eax, ebx
cmp eax, 0x1000            ; Check if too slow (being debugged)
ja debugger_detected
```

**Hardware Breakpoint Detection**: Check debug registers:

```nasm
mov eax, dr0
test eax, eax
jnz debugger_detected      ; DR0 is set

mov eax, dr7
test eax, eax
jnz debugger_detected      ; Debug control register is set
```

**INT3 Scanning**: Search code for software breakpoints (0xCC bytes):

```c
unsigned char *code = (unsigned char *)function_address;
for (int i = 0; i < length; i++) {
    if (code[i] == 0xCC) {
        // Breakpoint detected
    }
}
```

**Parent Process Check**: Verify not launched from debugger:

```c
// Windows
HANDLE snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
// Check if parent is known debugger (windbg.exe, x64dbg.exe, etc.)
```

**Exception-Based Detection**: Trigger exception and check handling:

```nasm
int3                        ; Generate debug exception
; If debugger present, it may handle differently
nop                         ; Execution continues here normally
```

**Evasion Techniques**:

**Patching Checks**: Modify anti-debug code to always take benign branch:

```nasm
; Original
test eax, eax
jnz debugger_detected

; Patched
test eax, eax
nop                         ; Replace jnz with nops
nop
```

**Hooking Detection Functions**: Intercept API calls that reveal debugging:

```javascript
// Frida: Hook IsDebuggerPresent
Interceptor.replace(Module.findExportByName("kernel32.dll", "IsDebuggerPresent"),
    new NativeCallback(function() {
        return 0;  // Always return FALSE
    }, 'int', [])
);
```

**Hardware Breakpoints**: Use hardware breakpoints instead of software (doesn't modify code)

**Hiding Debugger**: Plugins like ScyllaHide, HideDebugger modify debugger to be less detectable

**Timing Normalization**: Tools that hide timing delays caused by debugging

[Inference] The cat-and-mouse game between anti-debugging and evasion techniques is ongoing. Modern malware uses multiple layers of detection, requiring sophisticated evasion strategies.

### Network Analysis

Monitor network communications during execution.

**Traffic Capture**:

```bash
