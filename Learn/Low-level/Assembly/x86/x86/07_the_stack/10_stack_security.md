## Stack Security


The stack is a common target for security exploits. Understanding stack security mechanisms is important for writing secure code.

### Buffer Overflow Attacks

Classic buffer overflow overwrites return address:

```asm
vulnerable:
    SUB RSP, 64         ; 64-byte buffer
    MOV RDI, RSP        ; Buffer address
    CALL gets           ; Unsafe: no bounds checking
    ; If input > 64 bytes, overwrites return address
    ADD RSP, 64
    RET                 ; Returns to attacker-controlled address
```

Modern defenses:

- Stack canaries: detect overwrites before return
- Address Space Layout Randomization (ASLR): randomize stack location
- Non-executable stack (DEP/NX): prevent code execution from stack
- Bounds checking: validate buffer operations

### Return-Oriented Programming (ROP)

ROP bypasses non-executable stack by chaining existing code fragments ("gadgets"):

```asm
; Attacker overwrites stack to contain:
; [address of gadget1]  <- return address
; [data]
; [address of gadget2]  <- gadget1 returns here
; [data]
; ...

; Gadget example:
gadget1:
    POP RDI
    RET         ; Returns to next gadget

gadget2:
    POP RSI
    RET
```

Defenses:

- Control Flow Integrity (CFI): restrict control flow to valid targets
- Return Flow Guard (RFG): protect return addresses
- Code signing: prevent gadget creation in modified code

### Stack Pivoting

Attackers may redirect RSP to attacker-controlled memory:

```asm
; Vulnerability: stack pointer modification
vuln:
    MOV RSP, [attacker_controlled]  ; Point to fake stack
    RET                             ; Return using fake stack
```

Defenses:

- Stack limit checking: validate RSP within bounds
- Shadow stacks: hardware-maintained second stack for return addresses (Intel CET)

### Safe Stack Usage

Best practices for secure stack usage:

**Bounds checking**: Always validate buffer operations

```asm
safe_copy:
    CMP RDX, 64         ; Check size
    JA too_large        ; Reject if too large
    ; Proceed with copy
```

**Stack canaries**: Enable compiler protections (-fstack-protector)

**Minimal privilege**: Reduce code running with elevated privileges

**Address sanitization**: Use ASan during development to detect stack issues

**Safe functions**: Use bounds-checked alternatives (strncpy vs strcpy)

**Key Points:**

- The x86 stack grows downward from high to low addresses, with RSP pointing to the most recently pushed item; stack alignment requirements mandate 16-byte alignment before CALL instructions in 64-bit calling conventions
- PUSH decrements RSP then writes data; POP reads data then increments RSP; stack operations must be balanced with every PUSH matched by a corresponding POP or equivalent adjustment
- Stack pointer management includes manual adjustment (SUB/ADD RSP), red zone optimization (128-byte area below RSP in System V ABI), stack probing for large allocations, and alignment maintenance for correct calling convention compliance
- Stack frames contain incoming parameters, return address, saved frame pointer (RBP), local variables, saved callee registers, and temporary storage; function prologues establish frames while epilogues dismantle them before returning

---

