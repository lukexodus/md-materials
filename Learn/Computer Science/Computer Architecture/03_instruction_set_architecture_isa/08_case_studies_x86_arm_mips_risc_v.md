## Case Studies: x86, ARM, MIPS, RISC-V


These four architectures collectively span the entire design space of modern ISAs — from the maximally complex variable-length CISC of x86, through the clean fixed-length RISC designs of MIPS and RISC-V, to the pragmatic hybrid evolution of ARM. Studying them together reveals how ISA decisions propagate into microarchitecture, compiler design, and ecosystem lock-in.

---

### x86

#### Origins and Evolution

x86 originates from Intel's 8086 (1978), a 16-bit processor designed for compatibility with the 8080. Each generation extended the ISA while preserving backward compatibility:

|Generation|Width|Key Addition|
|---|---|---|
|8086 (1978)|16-bit|Base ISA, segmented memory|
|80386 (1985)|32-bit (IA-32)|Flat memory, protected mode, paging|
|Pentium (1993)|32-bit|Superscalar, FPU on-die|
|AMD64 / EM64T (2003)|64-bit (x86-64)|64-bit registers, expanded GPRs|
|Core series+|64-bit|SSE, AVX, AVX-512 SIMD extensions|

The result is an ISA that carries five decades of layered decisions — real mode, protected mode, long mode, and dozens of extension namespaces coexist in every modern x86 CPU.

#### Register File

x86-64 exposes 16 general-purpose registers, though their names reflect historical segmentation:

```
RAX  RBX  RCX  RDX   — general, with legacy roles (accumulator, base, counter, data)
RSI  RDI  RBP  RSP   — source index, destination index, base pointer, stack pointer
R8–R15               — added in x86-64; no legacy aliases
RIP                  — instruction pointer
RFLAGS               — condition codes (ZF, SF, CF, OF, PF, AF)
```

Each 64-bit register is aliased to narrower sub-registers:

```
RAX (64) → EAX (32) → AX (16) → AH (8, high) / AL (8, low)
```

Writing to EAX zero-extends into RAX; writing to AX or AL does not — a persistent source of subtle bugs.

Separate register files exist for:

- **x87 FPU** — 8-entry stack-based 80-bit registers (ST0–ST7)
- **MMX** — aliased to x87 registers, 64-bit integer SIMD
- **XMM0–XMM15** — 128-bit, used by SSE/SSE2–SSE4
- **YMM0–YMM15** — 256-bit, AVX/AVX2 (upper half of XMM)
- **ZMM0–ZMM31** — 512-bit, AVX-512

#### Instruction Encoding

x86 uses **variable-length encoding** from 1 to 15 bytes per instruction. The format is a layered sequence of optional fields:

```
[Legacy Prefixes] [REX/VEX/EVEX] [Opcode] [ModRM] [SIB] [Displacement] [Immediate]
   0–4 bytes        0–4 bytes     1–3 B    0–1 B   0–1B    0,1,2,4 B     0,1,2,4 B
```

- **ModRM byte** — encodes addressing mode, register operands, and opcode extensions
- **SIB byte** (Scale-Index-Base) — encodes complex address calculations: `[base + index × scale + disp]`
- **REX prefix** — in 64-bit mode, extends register fields to access R8–R15 and YMM8–YMM15

This complexity is entirely hidden from software but imposes significant burden on the **instruction fetch and decode frontend** of the microarchitecture. Modern Intel/AMD designs dedicate substantial silicon to a multi-stage predecoder → decoder → microcode pipeline just to convert x86 instructions into internal fixed-width micro-ops (µops).

#### Addressing Modes

x86 supports one of the richest addressing mode sets of any architecture:

|Mode|Syntax|Example|
|---|---|---|
|Register|`reg`|`MOV RAX, RBX`|
|Immediate|`imm`|`MOV RAX, 42`|
|Direct|`[addr]`|`MOV RAX, [0x1000]`|
|Register indirect|`[reg]`|`MOV RAX, [RBX]`|
|Base + displacement|`[reg + disp]`|`MOV RAX, [RBX + 8]`|
|Base + index|`[reg + reg]`|`MOV RAX, [RBX + RCX]`|
|Base + index × scale + disp|`[reg + reg*s + d]`|`MOV RAX, [RBX + RCX*4 + 16]`|

#### Memory Model and Segmentation

x86 retains a vestigial segmentation model. In 64-bit long mode, CS/DS/ES/SS segments are treated as base-zero by the hardware, but **FS and GS** remain usable with non-zero bases — the OS exploits this for thread-local storage (TLS) and per-CPU data structures.

The memory model is **strong**: x86 implements Total Store Order (TSO), in which stores from a single core become visible to other cores in program order. This is stronger than most other architectures and simplifies lock-free programming at the cost of memory fence overhead on the microarchitecture.

#### Calling Convention (System V AMD64 ABI)

```
Integer arguments:   RDI, RSI, RDX, RCX, R8, R9  (then stack)
Floating-point:      XMM0–XMM7
Return value:        RAX (integer), XMM0 (float)
Callee-saved:        RBX, RBP, R12–R15
Caller-saved:        RAX, RCX, RDX, RSI, RDI, R8–R11
Stack alignment:     16-byte at CALL instruction
```

Windows uses a different ABI (RCX, RDX, R8, R9 for integer args), making cross-platform assembly non-portable at the calling convention level.

#### Microarchitecture Realities

Because x86 is so complex at the ISA level, all modern implementations translate it internally:

- Intel Core: variable-length x86 → fixed 4-wide µop decode → µop cache (Decoded ICache) → out-of-order engine
- AMD Zen: similar decode → µop cache → out-of-order engine with separate integer and FP schedulers

The µop cache (Intel: "Decoded ICache"; AMD: "Op Cache") bypasses the expensive decode logic on cache hits, effectively making the processor behave like a RISC machine internally with a CISC front-end translating cold paths.

---

### ARM

#### Origins and Philosophy

ARM (Acorn RISC Machine, 1983; later Advanced RISC Machines) was designed from the outset for **low power and simplicity**. The original ARM1 had no cache, no FPU, and 25,000 transistors. Its defining constraint — that every instruction must complete in one cycle on simple hardware — shaped an ISA that is genuinely RISC in design.

ARM's business model is IP licensing, not chip manufacturing. This has resulted in the widest deployment of any ISA: embedded microcontrollers, mobile SoCs, server chips (Graviton, Neoverse), and Apple Silicon all implement ARM ISAs.

#### Architecture Versions

|Version|Key Features|
|---|---|
|ARMv4T|Thumb 16-bit compressed ISA introduced|
|ARMv5TE|DSP instructions, improved Thumb|
|ARMv6|SIMD, Thumb-2 (mixed 16/32-bit)|
|ARMv7-A|Thumb-2 baseline, VFP, NEON, TrustZone|
|ARMv8-A|64-bit (AArch64) + 32-bit (AArch32) execution states|
|ARMv9-A|SVE2, Memory Tagging Extension (MTE), Realm Management|

The shift to **AArch64** in ARMv8 was a clean break: a new 64-bit ISA with 31 general-purpose registers, fixed 32-bit instruction encoding, and no segmentation.

#### Register File (AArch64)

```
X0–X30    — 64-bit general-purpose registers
W0–W30    — 32-bit views of X0–X30 (zero-extended on write)
XZR/WZR   — zero register (reads as 0, writes discarded)
SP        — stack pointer (not a general register in most contexts)
PC        — program counter (not directly accessible as a GPR)
LR (X30)  — link register (return address on branch-and-link)
NZCV      — condition flags (Negative, Zero, Carry, oVerflow)
```

SIMD/FP registers:

```
V0–V31    — 128-bit vector registers
  accessed as: B (8), H (16), S (32), D (64), Q (128) views
```

#### Instruction Encoding (AArch64)

All AArch64 instructions are **exactly 32 bits**, with the top bits determining the instruction class:

```
Bits [31:29]  — top-level encoding group
Bits [28:24]  — instruction class within group
Remaining     — operands, immediates, shift amounts
```

This uniformity makes the decoder trivially simple: fetch address is always PC+4, instruction boundaries are always aligned, and the decode pipeline is shallow.

#### Condition Codes and Predication

In AArch32, **every instruction** could be conditionally executed via a 4-bit condition field — a form of predication that eliminates many short branches. AArch64 removed per-instruction predication (except for a few instructions like `CSEL`, `CSINC`) in favor of relying on the branch predictor, which is the right trade-off at high clock rates.

Condition suffixes in AArch32:

```
EQ NE CS CC MI PL VS VC HI LS GE LT GT LE AL NV
```

AArch64 retains conditional select and conditional branch:

```asm
CSEL  X0, X1, X2, EQ    ; X0 = (Z==1) ? X1 : X2
CSINC X0, X1, XZR, NE   ; X0 = (Z==0) ? X1+1 : X1  (common idiom)
B.EQ  label              ; branch if Z==1
CBZ   X0, label          ; branch if X0 == 0
CBNZ  X0, label          ; branch if X0 != 0
TBZ   X0, #3, label      ; branch if bit 3 of X0 == 0
```

#### Load/Store Architecture

ARM is a strict **load/store architecture**: arithmetic operates only on registers, and memory is accessed exclusively through load/store instructions. AArch64 provides rich addressing modes:

|Mode|Syntax|Semantics|
|---|---|---|
|Base register|`[Xn]`|`addr = Xn`|
|Base + immediate offset|`[Xn, #imm]`|`addr = Xn + imm`|
|Base + register offset|`[Xn, Xm]`|`addr = Xn + Xm`|
|Base + scaled register|`[Xn, Xm, LSL #2]`|`addr = Xn + Xm<<2`|
|Pre-index|`[Xn, #imm]!`|`Xn += imm; addr = Xn`|
|Post-index|`[Xn], #imm`|`addr = Xn; Xn += imm`|

#### Thumb and Thumb-2

For embedded and mobile contexts, ARM introduced **Thumb** — a 16-bit compressed encoding of the most common ARM instructions. Thumb-2 extended this to a **mixed 16/32-bit** encoding, allowing code density close to 8-bit embedded processors while retaining 32-bit computational power. The processor switches between ARM and Thumb state via the T bit in the CPSR, or implicitly through interworking branches.

#### Calling Convention (AAPCS64)

```
Arguments:      X0–X7 (integer/pointer), V0–V7 (float/SIMD)
Return:         X0–X1 (integer), V0–V3 (SIMD)
Callee-saved:   X19–X28, X29 (frame pointer), X30 (LR), SP
Caller-saved:   X0–X18
Stack:          16-byte aligned at all times
```

#### TrustZone and Security

ARM's **TrustZone** partitions the processor into a Secure World and a Normal World at the hardware level. All registers, memory, and peripherals can be tagged as secure or non-secure. A dedicated monitor mode and the `SMC` (Secure Monitor Call) instruction mediate transitions. This is the hardware basis for trusted execution environments (TEEs) such as OP-TEE and Apple's Secure Enclave.

---

### MIPS

#### Design Philosophy

MIPS (Microprocessor without Interlocked Pipeline Stages, 1981, Stanford; commercial: MIPS Technologies 1984) was one of the first architectures designed explicitly with pipelining in mind. Its name refers to the original design goal: eliminate the hardware interlocks that stall a pipeline on data hazards, instead requiring the **compiler** to schedule instructions to avoid hazards. Early MIPS hardware literally had no hazard detection — an instruction following a load that depended on its result would silently read garbage.

This philosophy produced an exceptionally clean ISA that became the canonical teaching architecture, used in Patterson & Hennessy's _Computer Organization and Design_ for decades.

#### Register File

MIPS has 32 general-purpose registers, all 32-bit in MIPS32 (64-bit in MIPS64):

|Register|ABI Name|Conventional Use|
|---|---|---|
|`$0`|`$zero`|Hardwired zero|
|`$1`|`$at`|Assembler temporary|
|`$2–$3`|`$v0–$v1`|Function return values|
|`$4–$7`|`$a0–$a3`|Function arguments|
|`$8–$15`|`$t0–$t7`|Caller-saved temporaries|
|`$16–$23`|`$s0–$s7`|Callee-saved|
|`$24–$25`|`$t8–$t9`|More caller-saved temporaries|
|`$26–$27`|`$k0–$k1`|Reserved for OS kernel|
|`$28`|`$gp`|Global pointer|
|`$29`|`$sp`|Stack pointer|
|`$30`|`$fp`|Frame pointer|
|`$31`|`$ra`|Return address|

Special registers outside the main file:

- **HI / LO** — hold the 64-bit result of multiply/divide (`MULT`, `DIV`; result read with `MFHI`, `MFLO`)
- **PC** — not directly accessible

#### Instruction Formats

MIPS uses exactly **three fixed 32-bit formats**:

```
R-format (register):
  [31:26] op=000000 | [25:21] rs | [20:16] rt | [15:11] rd | [10:6] shamt | [5:0] funct

I-format (immediate):
  [31:26] opcode    | [25:21] rs | [20:16] rt | [15:0]  immediate (16-bit signed)

J-format (jump):
  [31:26] opcode    | [25:0]  target address (26-bit, shifted left 2, combined with PC[31:28])
```

This three-format system is among the simplest possible for a practical ISA and made MIPS a favorite for hardware implementation courses.

#### Branch Delay Slot

One of MIPS's most distinctive (and controversial) features: the instruction **immediately after a branch** is always executed, regardless of whether the branch is taken. This is the **branch delay slot**.

```asm
BEQ  $t0, $t1, label    ; branch if $t0 == $t1
ADD  $t2, $t3, $t4      ; THIS executes regardless of branch outcome
                         ; (the delay slot instruction)
label:
  ...
```

The rationale: in a simple 5-stage pipeline, a branch resolves in the EX stage. By the time the branch is resolved, the next instruction has already been fetched. Rather than squashing it (wasting a cycle), MIPS defines it as architecturally part of the branch. The compiler is responsible for placing a useful instruction in the delay slot (or a NOP if nothing is available).

In MIPS32 Release 6 (2014), the delay slot was abolished and compact branches (no delay slot) were introduced — a tacit acknowledgment that the feature was a mistake at scale.

#### Load Delay Slot

Early MIPS also had a **load delay slot**: a load instruction's result was not available until the instruction **two positions later**. The instruction immediately after a load could not use its result:

```asm
LW   $t0, 0($s0)        ; load
ADD  $t1, $t2, $t3      ; delay slot — cannot use $t0
SUB  $t4, $t0, $t5      ; $t0 is valid here
```

Hardware interlocks were added in later implementations, making this a software convention rather than a hardware requirement — but the ISA definition retained the hazard semantics.

#### Memory Alignment

MIPS enforces **natural alignment**: a word load (`LW`) must be 4-byte aligned; a halfword (`LH`) must be 2-byte aligned. Misaligned accesses raise an exception. Special instructions `LWL`/`LWR` (Load Word Left/Right) allow software to handle misaligned accesses explicitly.

#### Calling Convention (O32 ABI)

```
Arguments:      $a0–$a3 (first 4), then stack
Return:         $v0–$v1
Callee-saved:   $s0–$s7, $sp, $fp, $ra
Caller-saved:   $t0–$t9, $a0–$a3, $v0–$v1
Stack:          8-byte aligned, grows downward
```

The O32 ABI reserves 16 bytes of **argument shadow space** on the stack even when arguments are passed in registers — a quirk retained for compatibility.

#### MIPS Today

MIPS as a commercial entity has had a turbulent history (SGI, Imagination Technologies, Wave Computing, MIPS Tech LLC). In 2021, MIPS announced a transition to RISC-V. The architecture survives in embedded applications (routers, set-top boxes) and in simulators/emulators used for education.

---

### RISC-V

#### Origins and Philosophy

RISC-V ("RISC Five") was created at UC Berkeley in 2010, led by Krste Asanović and David Patterson. It was designed as an **open, free, extensible ISA** — with no licensing fees, no royalties, and no single controlling vendor. Its design explicitly incorporated lessons from 30 years of RISC architecture research and avoided the historical baggage that burdened both MIPS and ARM.

RISC-V is governed by RISC-V International, a non-profit with hundreds of member organizations.

#### Modularity: Base + Extensions

RISC-V is defined as a small mandatory base with optional standard extensions:

|Name|Description|
|---|---|
|**RV32I**|32-bit base integer ISA (47 instructions)|
|**RV64I**|64-bit base integer ISA|
|**RV128I**|128-bit base (future)|
|**M**|Integer multiply/divide|
|**A**|Atomic instructions (LR/SC, AMO)|
|**F**|Single-precision floating-point|
|**D**|Double-precision floating-point|
|**C**|Compressed 16-bit instructions|
|**V**|Vector extension|
|**B**|Bit manipulation|
|**H**|Hypervisor extension|
|**Zicsr**|Control and status register instructions|
|**Zifencei**|Instruction-fetch fence|

A profile is denoted by concatenating extension letters: `RV64GC` = RV64I + M + A + F + D + C, which is the standard Linux-capable profile.

The base **RV32I** has only 47 instructions — sufficient to implement a complete, bootstrappable software stack.

#### Register File

```
x0  (zero) — hardwired zero, writes ignored
x1  (ra)   — return address
x2  (sp)   — stack pointer
x3  (gp)   — global pointer
x4  (tp)   — thread pointer
x5–x7   (t0–t2)   — temporaries
x8  (s0/fp)        — saved / frame pointer
x9  (s1)           — saved
x10–x11 (a0–a1)   — arguments / return values
x12–x17 (a2–a7)   — arguments
x18–x27 (s2–s11)  — callee-saved
x28–x31 (t3–t6)   — temporaries
```

No dedicated link register — the `JAL`/`JALR` instructions write the return address to any specified register (by convention `ra` = x1). No HI/LO registers — multiply produces a full-width result split across two instructions (`MUL` for low word, `MULH`/`MULHU`/`MULHSU` for high word).

#### Instruction Formats

RISC-V defines **six** fixed 32-bit formats (plus 16-bit C extension formats):

```
R-type:  [31:25] funct7 | [24:20] rs2 | [19:15] rs1 | [14:12] funct3 | [11:7] rd  | [6:0] opcode
I-type:  [31:20] imm[11:0]            | [19:15] rs1 | [14:12] funct3 | [11:7] rd  | [6:0] opcode
S-type:  [31:25] imm[11:5]| [24:20] rs2| [19:15] rs1 | [14:12] funct3 | [11:7] imm[4:0]| opcode
B-type:  imm[12|10:5]     | rs2        | rs1          | funct3         | imm[4:1|11]    | opcode
U-type:  [31:12] imm[31:12]                                            | [11:7] rd  | [6:0] opcode
J-type:  imm[20|10:1|11|19:12]                                         | [11:7] rd  | [6:0] opcode
```

A deliberate design choice: **rs1, rs2, and rd are always at the same bit positions** across all formats, allowing the register file to be read before the instruction is fully decoded. Immediates are encoded in scrambled bit positions — this is intentional, as it minimizes the number of distinct immediate sign-extension circuits needed in hardware.

#### No Branch Delay Slots, No Load Delay Slots

RISC-V explicitly and deliberately omits both delay slots. The architecture assumes a hardware branch predictor handles control hazards, and hardware interlocks handle load-use hazards. This makes the ISA correct on even the simplest hardware without compiler scheduling tricks.

#### Privileged Architecture

RISC-V defines three privilege levels:

```
M-mode (Machine)      — highest; full hardware access; always present
S-mode (Supervisor)   — OS kernel; optional
U-mode (User)         — application; optional
```

Control and Status Registers (CSRs) govern privilege state:

|CSR|Purpose|
|---|---|
|`mstatus`|Global interrupt enable, privilege state|
|`mepc`|Machine exception program counter|
|`mcause`|Exception cause code|
|`mtvec`|Trap handler base address|
|`satp`|Supervisor address translation and protection (page table root)|

The `ECALL` instruction transitions from U-mode → S-mode (syscall) or S-mode → M-mode. `MRET`/`SRET` return from exception handlers.

#### Memory Model (RVWMO)

RISC-V uses **RVWMO** (RISC-V Weak Memory Ordering) — a relaxed memory model. Stores from one hart (hardware thread) may not be immediately visible to other harts. `FENCE` instructions enforce ordering:

```asm
FENCE rw, rw    ; full fence: all prior reads/writes complete before any subsequent
FENCE.I         ; instruction fence: ensures instruction cache coherence
```

This is weaker than x86's TSO and requires explicit fences in lock-free code — but maps efficiently to both in-order and out-of-order microarchitectures.

#### Compressed Extension (C)

The C extension provides 16-bit encodings for the most common instruction patterns, achieving code density comparable to Thumb-2:

```
C.ADD   rd, rs          → ADD rd, rd, rs
C.LW    rd, offset(rs1) → LW rd, offset(rs1)   (limited register set: x8–x15)
C.J     offset          → JAL x0, offset
C.BEQZ  rs, offset      → BEQ rs, x0, offset
```

C extension instructions are restricted to a subset of registers (x8–x15 for two-register forms) to fit operands into 16 bits.

#### Calling Convention (RISC-V psABI)

```
Arguments:     a0–a7 (x10–x17)
Return:        a0–a1
Callee-saved:  s0–s11 (x8–x9, x18–x27), sp, ra
Caller-saved:  t0–t6, a0–a7
Stack:         16-byte aligned
```

---

### Comparative Analysis

#### ISA Design Dimensions

|Property|x86|ARM (AArch64)|MIPS|RISC-V|
|---|---|---|---|---|
|Instruction width|Variable (1–15 B)|Fixed 32-bit|Fixed 32-bit|Fixed 32-bit (+ 16-bit C)|
|GPRs|16|31 + ZR|32|32|
|Encoding complexity|Very high|Moderate|Low|Low–Moderate|
|Memory model|TSO (strong)|Weak (LDAPR/STLR for ordering)|Weak|RVWMO (weak)|
|Licensing|Proprietary (Intel/AMD)|Proprietary (ARM Ltd.)|Proprietary → declining|Open (royalty-free)|
|Delay slots|No|No|Yes (pre-R6)|No|
|Predication|Limited (CMOVcc)|Partial (CSEL etc.)|No|No|
|SIMD|AVX-512 (512-bit)|SVE2 (scalable)|MSA (128-bit)|V extension (scalable)|
|Primary domain|Servers, desktops|Mobile, embedded, servers|Embedded, education|Embedded → cloud|

#### Instruction Density Comparison

For the operation `result = a[i] + b[i]` (load two words, add, store):

```asm
; x86-64
MOV  EAX, [RBX + RCX*4]      ; load a[i]  (1 instruction, fused load+use)
ADD  EAX, [RDX + RCX*4]      ; add b[i]   (memory operand directly)
MOV  [RSI + RCX*4], EAX      ; store result

; AArch64
LDR  W0, [X1, X2, LSL #2]    ; load a[i]
LDR  W3, [X4, X2, LSL #2]    ; load b[i]
ADD  W0, W0, W3               ; add
STR  W0, [X5, X2, LSL #2]    ; store

; MIPS
SLL  $t0, $a2, 2              ; i << 2 (byte offset)
ADD  $t1, $a0, $t0            ; &a[i]
LW   $t2, 0($t1)              ; load a[i]
ADD  $t3, $a1, $t0            ; &b[i]
LW   $t4, 0($t3)              ; load b[i]
ADD  $t5, $t2, $t4            ; add
SW   $t5, 0($t4)              ; store (needs &result[i])

; RISC-V
SLLI  t0, a2, 2               ; i << 2
ADD   t1, a0, t0              ; &a[i]
LW    t2, 0(t1)               ; load a[i]
ADD   t3, a1, t0              ; &b[i]
LW    t4, 0(t3)               ; load b[i]
ADD   t5, t2, t4              ; add
SW    t5, 0(t4)               ; store
```

x86's memory-to-register operations and scaled indexing compress this to 3 instructions, but each may decode to multiple µops. MIPS and RISC-V are nearly identical — RISC-V's explicit design borrowed heavily from MIPS while removing its warts.

#### Microarchitectural Implications

<svg viewBox="0 0 720 380" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect width="720" height="380" fill="#0d1117"/> <!-- Title -->

<text x="220" y="28" fill="#f0f6fc" font-size="13" font-weight="bold">ISA Complexity vs. Microarchitecture Frontend Cost</text>

<!-- Axes --> <line x1="80" y1="320" x2="660" y2="320" stroke="#58a6ff" stroke-width="1.5"/> <line x1="80" y1="60" x2="80" y2="320" stroke="#58a6ff" stroke-width="1.5"/> <text x="320" y="360" fill="#8b949e" font-size="11">ISA Encoding Complexity →</text> <text x="18" y="200" fill="#8b949e" font-size="11" transform="rotate(-90,18,200)">Frontend Silicon Cost →</text> <!-- Grid lines --> <line x1="80" y1="260" x2="660" y2="260" stroke="#21262d" stroke-width="1"/> <line x1="80" y1="200" x2="660" y2="200" stroke="#21262d" stroke-width="1"/> <line x1="80" y1="140" x2="660" y2="140" stroke="#21262d" stroke-width="1"/> <line x1="200" y1="60" x2="200" y2="320" stroke="#21262d" stroke-width="1"/> <line x1="340" y1="60" x2="340" y2="320" stroke="#21262d" stroke-width="1"/> <line x1="480" y1="60" x2="480" y2="320" stroke="#21262d" stroke-width="1"/> <line x1="600" y1="60" x2="600" y2="320" stroke="#21262d" stroke-width="1"/> <!-- RISC-V point --> <circle cx="160" cy="280" r="10" fill="#3fb950" opacity="0.9"/> <text x="140" y="270" fill="#56d364" font-size="12" font-weight="bold">RISC-V</text> <text x="132" y="256" fill="#56d364" font-size="10">minimal frontend</text> <!-- MIPS point --> <circle cx="200" cy="265" r="10" fill="#79c0ff" opacity="0.9"/> <text x="210" y="260" fill="#79c0ff" font-size="12" font-weight="bold">MIPS</text> <text x="210" y="248" fill="#79c0ff" font-size="10">simple decode</text> <!-- ARM point --> <circle cx="380" cy="210" r="10" fill="#d2a8ff" opacity="0.9"/> <text x="395" y="215" fill="#d2a8ff" font-size="12" font-weight="bold">ARM</text> <text x="360" y="236" fill="#d2a8ff" font-size="10">Thumb-2 adds decode</text> <text x="355" y="248" fill="#d2a8ff" font-size="10">complexity; VEX/SVE2</text> <!-- x86 point --> <circle cx="590" cy="100" r="10" fill="#ff7b72" opacity="0.9"/> <text x="530" y="96" fill="#ff7b72" font-size="12" font-weight="bold">x86</text> <text x="500" y="112" fill="#ff7b72" font-size="10">massive predecoder</text> <text x="502" y="124" fill="#ff7b72" font-size="10">+ µop translation</text> <!-- Trend line --> <line x1="130" y1="295" x2="610" y2="85" stroke="#8b949e" stroke-width="1" stroke-dasharray="6,4"/> <!-- Labels -->

<text x="82" y="263" fill="#484f58" font-size="9">Low</text> <text x="82" y="143" fill="#484f58" font-size="9">High</text> </svg>

---

### Instruction Set Encoding Visual

<svg viewBox="0 0 720 400" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect width="720" height="400" fill="#0d1117"/> <text x="240" y="28" fill="#f0f6fc" font-size="13" font-weight="bold">Instruction Encoding Comparison (32-bit word)</text> <!-- MIPS R-format -->

<text x="40" y="60" fill="#79c0ff" font-size="12" font-weight="bold">MIPS R-format</text> <rect x="40" y="68" width="100" height="28" fill="#1c2d40" stroke="#79c0ff" stroke-width="1" rx="2"/> <text x="62" y="86" fill="#79c0ff">op[5:0]</text> <rect x="140" y="68" width="100" height="28" fill="#1c2d40" stroke="#79c0ff" stroke-width="1" rx="2"/> <text x="168" y="86" fill="#79c0ff">rs[4:0]</text> <rect x="240" y="68" width="100" height="28" fill="#1c2d40" stroke="#79c0ff" stroke-width="1" rx="2"/> <text x="268" y="86" fill="#79c0ff">rt[4:0]</text> <rect x="340" y="68" width="100" height="28" fill="#1c2d40" stroke="#79c0ff" stroke-width="1" rx="2"/> <text x="368" y="86" fill="#79c0ff">rd[4:0]</text> <rect x="440" y="68" width="80" height="28" fill="#1c2d40" stroke="#79c0ff" stroke-width="1" rx="2"/> <text x="454" y="86" fill="#79c0ff">shamt</text> <rect x="520" y="68" width="140" height="28" fill="#1c2d40" stroke="#79c0ff" stroke-width="1" rx="2"/> <text x="545" y="86" fill="#79c0ff">funct[5:0]</text>

<!-- MIPS I-format -->

<text x="40" y="130" fill="#79c0ff" font-size="12" font-weight="bold">MIPS I-format</text> <rect x="40" y="138" width="100" height="28" fill="#1c2d40" stroke="#79c0ff" stroke-width="1" rx="2"/> <text x="62" y="156" fill="#79c0ff">op[5:0]</text> <rect x="140" y="138" width="100" height="28" fill="#1c2d40" stroke="#79c0ff" stroke-width="1" rx="2"/> <text x="168" y="156" fill="#79c0ff">rs[4:0]</text> <rect x="240" y="138" width="100" height="28" fill="#1c2d40" stroke="#79c0ff" stroke-width="1" rx="2"/> <text x="268" y="156" fill="#79c0ff">rt[4:0]</text> <rect x="340" y="138" width="320" height="28" fill="#21362d" stroke="#3fb950" stroke-width="1.5" rx="2"/> <text x="460" y="156" fill="#3fb950">immediate [15:0]</text>

<!-- RISC-V R-type -->

<text x="40" y="200" fill="#56d364" font-size="12" font-weight="bold">RISC-V R-type</text> <rect x="40" y="208" width="140" height="28" fill="#1c2d40" stroke="#56d364" stroke-width="1" rx="2"/> <text x="78" y="226" fill="#56d364">funct7</text> <rect x="180" y="208" width="80" height="28" fill="#1c2d40" stroke="#56d364" stroke-width="1" rx="2"/> <text x="198" y="226" fill="#56d364">rs2</text> <rect x="260" y="208" width="80" height="28" fill="#1c2d40" stroke="#56d364" stroke-width="1" rx="2"/> <text x="278" y="226" fill="#56d364">rs1</text> <rect x="340" y="208" width="80" height="28" fill="#1c2d40" stroke="#56d364" stroke-width="1" rx="2"/> <text x="350" y="226" fill="#56d364">funct3</text> <rect x="420" y="208" width="80" height="28" fill="#1c2d40" stroke="#56d364" stroke-width="1" rx="2"/> <text x="442" y="226" fill="#56d364">rd</text> <rect x="500" y="208" width="160" height="28" fill="#21362d" stroke="#56d364" stroke-width="1.5" rx="2"/> <text x="545" y="226" fill="#56d364">opcode[6:0]</text>

<!-- ARM AArch64 (representative) -->

<text x="40" y="270" fill="#d2a8ff" font-size="12" font-weight="bold">AArch64 (Data Processing)</text> <rect x="40" y="278" width="60" height="28" fill="#1c2d40" stroke="#d2a8ff" stroke-width="1" rx="2"/> <text x="52" y="296" fill="#d2a8ff">sf op</text> <rect x="100" y="278" width="100" height="28" fill="#1c2d40" stroke="#d2a8ff" stroke-width="1" rx="2"/> <text x="118" y="296" fill="#d2a8ff">opcode</text> <rect x="200" y="278" width="80" height="28" fill="#1c2d40" stroke="#d2a8ff" stroke-width="1" rx="2"/> <text x="215" y="296" fill="#d2a8ff">Rm[4:0]</text> <rect x="280" y="278" width="100" height="28" fill="#1c2d40" stroke="#d2a8ff" stroke-width="1" rx="2"/> <text x="290" y="296" fill="#d2a8ff">shift/imm6</text> <rect x="380" y="278" width="80" height="28" fill="#1c2d40" stroke="#d2a8ff" stroke-width="1" rx="2"/> <text x="395" y="296" fill="#d2a8ff">Rn[4:0]</text> <rect x="460" y="278" width="200" height="28" fill="#21262d" stroke="#d2a8ff" stroke-width="1.5" rx="2"/> <text x="520" y="296" fill="#d2a8ff">Rd[4:0]</text>

<!-- x86 variable -->

<text x="40" y="340" fill="#ff7b72" font-size="12" font-weight="bold">x86 (variable length, conceptual)</text> <rect x="40" y="348" width="60" height="28" fill="#2d1a1a" stroke="#ff7b72" stroke-width="1" rx="2"/> <text x="48" y="366" fill="#ff7b72">prefix?</text> <rect x="100" y="348" width="60" height="28" fill="#2d1a1a" stroke="#ff7b72" stroke-width="1" rx="2"/> <text x="110" y="366" fill="#ff7b72">REX?</text> <rect x="160" y="348" width="100" height="28" fill="#2d1a1a" stroke="#ff7b72" stroke-width="1.5" rx="2"/> <text x="170" y="366" fill="#ff7b72">opcode 1–3B</text> <rect x="260" y="348" width="80" height="28" fill="#2d1a1a" stroke="#ff7b72" stroke-width="1" rx="2"/> <text x="270" y="366" fill="#ff7b72">ModRM?</text> <rect x="340" y="348" width="60" height="28" fill="#2d1a1a" stroke="#ff7b72" stroke-width="1" rx="2"/> <text x="352" y="366" fill="#ff7b72">SIB?</text> <rect x="400" y="348" width="100" height="28" fill="#2d1a1a" stroke="#ff7b72" stroke-width="1" rx="2"/> <text x="410" y="366" fill="#ff7b72">disp 0/1/4B</text> <rect x="500" y="348" width="100" height="28" fill="#2d1a1a" stroke="#ff7b72" stroke-width="1" rx="2"/> <text x="510" y="366" fill="#ff7b72">imm 0/1/4B</text> <text x="610" y="366" fill="#ff7b72" font-size="10">← up to 15B</text> </svg>

---

**Conclusion** These four architectures represent distinct points in a multi-dimensional design space. x86 maximizes backward compatibility and instruction density at enormous microarchitectural cost, succeeding through sheer investment in implementation complexity. ARM balances engineering pragmatism with power efficiency, producing an ISA that has dominated mobile computing and is rapidly displacing x86 in servers. MIPS represents the pure expression of first-generation RISC ideals, making it the canonical teaching architecture despite its commercial decline. RISC-V embodies the accumulated wisdom of all three predecessors, deliberately avoiding their historical mistakes while remaining open and extensible — making it the architecture most likely to dominate future embedded and cloud deployments.

**Next Steps** Proceed to **Processor Datapath & Control** (Module 4) to examine how an ISA — particularly a RISC ISA such as MIPS or RISC-V — is realized in actual hardware: the datapath that moves data between functional units, and the control unit that orchestrates the execution of each instruction format.

---

