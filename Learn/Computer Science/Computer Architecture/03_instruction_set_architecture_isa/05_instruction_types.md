## Instruction Types


Instructions are the atomic operations exposed by an ISA. Every program — regardless of source language — reduces to sequences of these operations at the machine level. The three primary functional categories are data transfer, arithmetic/logic, and control flow.

---

### Data Transfer Instructions

Data transfer instructions move values between locations: registers, memory, and I/O ports. They do not transform values — only relocate them.

#### Register-to-Register

Copies a value from one register to another. No memory access occurs.

```
MOV R1, R2        ; R1 ← R2  (x86-style)
```

#### Load (Memory → Register)

Reads a value from a memory address into a register. The address may be specified directly, or computed via a base + offset.

```
LDR R1, [R2, #4]  ; R1 ← Mem[R2 + 4]  (ARM)
LW  $t0, 8($s0)   ; $t0 ← Mem[$s0 + 8] (MIPS)
```

#### Store (Register → Memory)

Writes a register value to a memory address.

```
STR R1, [R2, #4]  ; Mem[R2 + 4] ← R1  (ARM)
SW  $t0, 8($s0)   ; Mem[$s0 + 8] ← $t0 (MIPS)
```

#### Push and Pop (Stack Operations)

Implicitly use the stack pointer. Push decrements SP then writes; pop reads then increments SP.

```
PUSH R1           ; SP ← SP - 4; Mem[SP] ← R1
POP  R1           ; R1 ← Mem[SP]; SP ← SP + 4
```

#### Load Immediate

Loads a constant value encoded directly in the instruction into a register.

```
MOV R1, #42       ; R1 ← 42  (ARM)
LI  $t0, 42       ; $t0 ← 42  (MIPS pseudo-instruction)
```

#### Data Transfer Summary

<svg viewBox="0 0 680 200" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <rect width="680" height="200" fill="#1e1e2e"/> <!-- Register file --> <rect x="40" y="40" width="120" height="130" rx="4" fill="#313244" stroke="#89b4fa" stroke-width="1.5"/> <text x="100" y="30" fill="#89b4fa" text-anchor="middle" font-size="13">Registers</text> <text x="100" y="62" fill="#cdd6f4" text-anchor="middle">R0</text> <line x1="50" y1="68" x2="150" y2="68" stroke="#585b70" stroke-width="0.8"/> <text x="100" y="88" fill="#cdd6f4" text-anchor="middle">R1</text> <line x1="50" y1="94" x2="150" y2="94" stroke="#585b70" stroke-width="0.8"/> <text x="100" y="114" fill="#cdd6f4" text-anchor="middle">R2</text> <line x1="50" y1="120" x2="150" y2="120" stroke="#585b70" stroke-width="0.8"/> <text x="100" y="140" fill="#cdd6f4" text-anchor="middle">R3</text> <line x1="50" y1="146" x2="150" y2="146" stroke="#585b70" stroke-width="0.8"/> <text x="100" y="164" fill="#cdd6f4" text-anchor="middle">SP</text> <!-- Memory --> <rect x="480" y="40" width="140" height="130" rx="4" fill="#313244" stroke="#a6e3a1" stroke-width="1.5"/> <text x="550" y="30" fill="#a6e3a1" text-anchor="middle" font-size="13">Memory</text> <text x="550" y="62" fill="#cdd6f4" text-anchor="middle">0x1000</text> <line x1="490" y1="68" x2="610" y2="68" stroke="#585b70" stroke-width="0.8"/> <text x="550" y="88" fill="#cdd6f4" text-anchor="middle">0x1004</text> <line x1="490" y1="94" x2="610" y2="94" stroke="#585b70" stroke-width="0.8"/> <text x="550" y="114" fill="#cdd6f4" text-anchor="middle">0x1008</text> <line x1="490" y1="120" x2="610" y2="120" stroke="#585b70" stroke-width="0.8"/> <text x="550" y="140" fill="#cdd6f4" text-anchor="middle">0x100C</text> <line x1="490" y1="146" x2="610" y2="146" stroke="#585b70" stroke-width="0.8"/> <text x="550" y="164" fill="#cdd6f4" text-anchor="middle">Stack</text> <!-- MOV: reg to reg --> <path d="M160,80 Q290,55 290,80 Q290,105 160,105" fill="none" stroke="#cba6f7" stroke-width="1.5" marker-end="url(#arrc)"/> <text x="235" y="74" fill="#cba6f7" text-anchor="middle">MOV</text> <!-- LOAD arrow --> <line x1="480" y1="88" x2="170" y2="100" stroke="#fab387" stroke-width="1.5" marker-end="url(#arrw)"/> <text x="330" y="80" fill="#fab387" text-anchor="middle">LOAD</text> <!-- STORE arrow --> <line x1="170" y1="120" x2="480" y2="125" stroke="#f38ba8" stroke-width="1.5" marker-end="url(#arrr)"/> <text x="330" y="148" fill="#f38ba8" text-anchor="middle">STORE</text> <defs> <marker id="arrc" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"> <path d="M0,0 L6,3 L0,6 Z" fill="#cba6f7"/> </marker> <marker id="arrw" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"> <path d="M0,0 L6,3 L0,6 Z" fill="#fab387"/> </marker> <marker id="arrr" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"> <path d="M0,0 L6,3 L0,6 Z" fill="#f38ba8"/> </marker> </defs> </svg>

---

### Arithmetic and Logic Instructions

These instructions compute a result from one or two operands and write it to a destination register. They operate entirely within the register file; memory is not accessed (in RISC designs; x86 allows memory operands).

#### Integer Arithmetic

|Instruction|Operation|Notes|
|---|---|---|
|ADD Rd, Rs1, Rs2|Rd ← Rs1 + Rs2|May set carry/overflow flags|
|SUB Rd, Rs1, Rs2|Rd ← Rs1 − Rs2|May set borrow/overflow flags|
|MUL Rd, Rs1, Rs2|Rd ← Rs1 × Rs2|Result may be wider than register width|
|DIV Rd, Rs1, Rs2|Rd ← Rs1 ÷ Rs2|Quotient and remainder often in separate registers|

#### Bitwise Logic

|Instruction|Operation|
|---|---|
|AND Rd, Rs1, Rs2|Rd ← Rs1 & Rs2|
|OR Rd, Rs1, Rs2|Rd ← Rs1 \| Rs2|
|XOR Rd, Rs1, Rs2|Rd ← Rs1 ^ Rs2|
|NOT Rd, Rs1|Rd ← ~Rs1|

#### Shift and Rotate

|Instruction|Operation|Notes|
|---|---|---|
|SHL Rd, Rs, n|Logical left shift by n|Fills with 0s on right|
|SHR Rd, Rs, n|Logical right shift by n|Fills with 0s on left|
|SAR Rd, Rs, n|Arithmetic right shift by n|Sign-extends; preserves sign|
|ROR Rd, Rs, n|Rotate right by n|Bits wrap around|

**Example — isolating a bitfield using AND + SHR:**

```
; Extract bits [11:8] from R1 into R0
AND R0, R1, #0x0F00   ; mask bits 11:8
SHR R0, R0, #8        ; shift down to bits 3:0
```

#### Condition Flags

Most architectures maintain a condition code register (or NZCV flags in ARM) updated by arithmetic instructions:

|Flag|Meaning|
|---|---|
|N (Negative)|Result MSB is 1|
|Z (Zero)|Result is 0|
|C (Carry)|Unsigned overflow / borrow|
|V (Overflow)|Signed overflow|

These flags feed directly into conditional branch instructions.

---

### Control Flow Instructions

Control flow instructions alter the program counter (PC), breaking the default sequential fetch order. Without them, no loops, conditionals, or function calls are possible.

#### Unconditional Jump / Branch

Loads a new address into the PC unconditionally.

```
J   LABEL       ; PC ← LABEL  (MIPS)
B   LABEL       ; PC ← LABEL  (ARM)
JMP LABEL       ; PC ← LABEL  (x86)
```

#### Conditional Branch

Tests one or more condition flags and branches only if the condition holds.

```
BEQ R1, R2, LABEL   ; if R1 == R2: PC ← LABEL  (MIPS)
BNE R1, R2, LABEL   ; if R1 != R2: PC ← LABEL
BGT LABEL           ; branch if greater than (ARM, tests flags)
JZ  LABEL           ; jump if zero flag set (x86)
```

**Example — a simple loop in MIPS:**

```asm
        LI   $t0, 0       ; i = 0
        LI   $t1, 10      ; limit = 10
LOOP:   BGE  $t0, $t1, END  ; if i >= 10, exit
        ADDI $t0, $t0, 1    ; i++
        J    LOOP
END:    ...
```

#### Compare Instructions

Some ISAs separate comparison from branching. CMP subtracts operands and discards the result, retaining only the flags.

```
CMP R1, R2      ; flags ← R1 - R2, result discarded
BLT LABEL       ; branch if less than (based on flags)
```

RISC-V takes a different approach — it embeds the comparison directly in the branch instruction:

```
BLT x1, x2, LABEL   ; branch if x1 < x2 (signed)
BLTU x1, x2, LABEL  ; branch if x1 < x2 (unsigned)
```

#### Call and Return

Function calls must save the return address so execution can resume after the callee finishes.

|Mechanism|Description|
|---|---|
|Link register|Return address stored in a dedicated register (ARM: LR, RISC-V: x1/ra)|
|Stack|Return address pushed onto the stack (x86: CALL pushes PC+n; RET pops it)|

```
; ARM
BL   FUNC       ; LR ← PC+4; PC ← FUNC
BX   LR         ; PC ← LR  (return)

; x86
CALL FUNC       ; Mem[SP-4] ← PC+n; SP -= 4; PC ← FUNC
RET             ; PC ← Mem[SP]; SP += 4
```

#### Control Flow SVG

<svg viewBox="0 0 680 310" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <rect width="680" height="310" fill="#1e1e2e"/> <!-- Sequential flow column -->

<text x="90" y="22" fill="#585b70" text-anchor="middle" font-size="11">Sequential</text>

<rect x="30" y="30" width="120" height="34" rx="4" fill="#313244" stroke="#89b4fa" stroke-width="1.5"/> <text x="90" y="52" fill="#cdd6f4" text-anchor="middle">Instr N</text> <line x1="90" y1="64" x2="90" y2="80" stroke="#585b70" stroke-width="1.5" marker-end="url(#ag)"/> <rect x="30" y="80" width="120" height="34" rx="4" fill="#313244" stroke="#89b4fa" stroke-width="1.5"/> <text x="90" y="102" fill="#cdd6f4" text-anchor="middle">Instr N+1</text> <line x1="90" y1="114" x2="90" y2="130" stroke="#585b70" stroke-width="1.5" marker-end="url(#ag)"/> <rect x="30" y="130" width="120" height="34" rx="4" fill="#313244" stroke="#89b4fa" stroke-width="1.5"/> <text x="90" y="152" fill="#cdd6f4" text-anchor="middle">Instr N+2</text> <!-- Unconditional jump column -->

<text x="310" y="22" fill="#585b70" text-anchor="middle" font-size="11">Unconditional Jump</text>

<rect x="250" y="30" width="120" height="34" rx="4" fill="#313244" stroke="#a6e3a1" stroke-width="1.5"/> <text x="310" y="52" fill="#cdd6f4" text-anchor="middle">Instr N</text> <rect x="250" y="80" width="120" height="34" rx="4" fill="#313244" stroke="#fab387" stroke-width="2"/> <text x="310" y="98" fill="#fab387" text-anchor="middle">JMP TARGET</text> <text x="310" y="109" fill="#585b70" text-anchor="middle" font-size="10">unconditional</text> <!-- jump arc bypassing N+1 --> <path d="M370,97 Q430,97 430,180 Q430,210 370,210" fill="none" stroke="#fab387" stroke-width="1.5" marker-end="url(#ao)"/> <rect x="250" y="130" width="120" height="34" rx="4" fill="#313244" stroke="#585b70" stroke-width="1" stroke-dasharray="4,3"/> <text x="310" y="152" fill="#585b70" text-anchor="middle">skipped</text> <rect x="250" y="195" width="120" height="34" rx="4" fill="#313244" stroke="#a6e3a1" stroke-width="1.5"/> <text x="310" y="217" fill="#cdd6f4" text-anchor="middle">TARGET</text> <!-- Conditional branch column -->

<text x="560" y="22" fill="#585b70" text-anchor="middle" font-size="11">Conditional Branch</text>

<rect x="500" y="30" width="120" height="34" rx="4" fill="#313244" stroke="#cba6f7" stroke-width="1.5"/> <text x="560" y="52" fill="#cdd6f4" text-anchor="middle">Instr N</text> <rect x="500" y="80" width="120" height="34" rx="4" fill="#313244" stroke="#cba6f7" stroke-width="2"/> <text x="560" y="98" fill="#cba6f7" text-anchor="middle">BEQ R1,R2,T</text> <text x="560" y="109" fill="#585b70" text-anchor="middle" font-size="10">tests flags</text> <!-- taken path --> <path d="M620,97 Q665,97 665,210 Q665,240 620,240" fill="none" stroke="#a6e3a1" stroke-width="1.5" marker-end="url(#at)"/> <text x="668" y="160" fill="#a6e3a1" font-size="10">taken</text> <!-- not-taken path --> <line x1="560" y1="114" x2="560" y2="130" stroke="#f38ba8" stroke-width="1.5" marker-end="url(#an)"/> <text x="530" y="128" fill="#f38ba8" font-size="10">not taken</text> <rect x="500" y="130" width="120" height="34" rx="4" fill="#313244" stroke="#f38ba8" stroke-width="1.5"/> <text x="560" y="152" fill="#cdd6f4" text-anchor="middle">Instr N+1</text> <rect x="500" y="225" width="120" height="34" rx="4" fill="#313244" stroke="#a6e3a1" stroke-width="1.5"/> <text x="560" y="247" fill="#cdd6f4" text-anchor="middle">TARGET</text> <!-- CALL/RET row -->

<text x="340" y="283" fill="#585b70" text-anchor="middle" font-size="11">CALL pushes return address → callee executes → RET restores PC</text>

<defs> <marker id="ag" markerWidth="6" markerHeight="6" refX="3" refY="6" orient="auto"> <path d="M0,0 L3,6 L6,0 Z" fill="#585b70"/> </marker> <marker id="ao" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"> <path d="M0,0 L6,3 L0,6 Z" fill="#fab387"/> </marker> <marker id="at" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"> <path d="M0,0 L6,3 L0,6 Z" fill="#a6e3a1"/> </marker> <marker id="an" markerWidth="6" markerHeight="6" refX="3" refY="6" orient="auto"> <path d="M0,0 L3,6 L6,0 Z" fill="#f38ba8"/> </marker> </defs> </svg>

---

### Special-Purpose Transfer and Control Instructions

Beyond the three main categories, most ISAs include instructions that bridge categories or serve system-level roles:

|Instruction|Category|Purpose|
|---|---|---|
|LEA (x86)|Data transfer|Loads effective address (not the value at that address) into register|
|XCHG|Data transfer|Atomically swaps two register or memory values|
|NOP|Control|No operation; advances PC only; used for alignment and pipeline padding|
|HLT / WFI|Control|Halts execution or waits for interrupt|
|SYSCALL / SVC|Control|Transfers control to OS kernel (privilege level change)|
|CMOV (x86)|Data transfer + control|Conditional move; avoids branches for simple predicates|

---

### ISA Design Tradeoffs by Category

|Concern|RISC Approach|CISC Approach|
|---|---|---|
|Data transfer|Strict load/store only; no memory operands in arithmetic|Arithmetic can read/write memory directly|
|Arithmetic|Fixed-width, register-only operands|Variable-width operands, memory operands allowed|
|Control flow|Condition tested in branch instruction (RISC-V) or flag register (ARM)|FLAGS register updated by most arithmetic ops|
|Call/return|Link register; callee saves convention explicit|CALL/RET manage stack implicitly|

---

**Conclusion:** The three instruction categories — data transfer, arithmetic/logic, and control flow — form a minimal but complete basis for general-purpose computation. Data transfer connects the memory hierarchy to the register file; arithmetic/logic computes results within the register file; and control flow determines which instructions execute next. All higher-level constructs — loops, conditionals, functions, objects — reduce to compositions of these three categories at the ISA level.

**Next Steps:** Proceed to Assembly Language Basics to see how these instruction categories compose into working programs, or to Calling Conventions and ABI to understand how control flow and data transfer instructions are standardized across function boundaries.

---

