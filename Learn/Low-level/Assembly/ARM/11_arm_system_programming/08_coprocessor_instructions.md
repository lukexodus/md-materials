## Coprocessor Instructions


ARM architecture supports up to 16 coprocessors (CP0-CP15), providing extensible interfaces for specialized hardware. CP15 is the system control coprocessor, mandatory in all implementations, providing access to configuration registers, MMU, caches, and performance counters. Other coprocessor numbers are used for optional features.

**Coprocessor Instruction Format:**

ARM provides four coprocessor instruction types:

**CDP (Coprocessor Data Processing):** Internal coprocessor operation.

```assembly
CDP  coproc, opcode1, CRd, CRn, CRm, opcode2
```

**MCR (Move to Coprocessor from ARM Register):** Transfer data from ARM register to coprocessor register.

```assembly
MCR  coproc, opcode1, Rt, CRn, CRm, opcode2
```

**MRC (Move to ARM Register from Coprocessor):** Transfer data from coprocessor register to ARM register.

```assembly
MRC  coproc, opcode1, Rt, CRn, CRm, opcode2
```

**LDC/STC (Load/Store Coprocessor):** Transfer data between memory and coprocessor.

```assembly
LDC  coproc, CRd, [Rn]
STC  coproc, CRd, [Rn]
```

**CP15 System Control Coprocessor:**

CP15 provides access to system control registers through a register addressing scheme using CRn (primary register), CRm (secondary register), and opcode values. The combination uniquely identifies each register.

**Common CP15 Registers:**

**c0 - Identification Registers:**

```assembly
; Main ID Register
MRC     p15, 0, R0, c0, c0, 0        ; Read MIDR
; Returns: implementer, variant, architecture, part number, revision

; Cache Type Register
MRC     p15, 0, R0, c0, c0, 1        ; Read CTR
; Returns: cache line sizes, cache type information

; Processor Feature Registers
MRC     p15, 0, R0, c0, c1, 0        ; Read ID_PFR0 (processor features)
MRC     p15, 0, R0, c0, c1, 1        ; Read ID_PFR1
```

**c1 - System Control Register (SCCR):**

```assembly
; Read SCCR
MRC     p15, 0, R0, c1, c0, 0

; SCCR bit fields:
; [0]    M  - MMU enable
; [1]    A  - Alignment check enable
; [2]    C  - D-cache enable
; [11]   Z  - Branch prediction enable
; [12]   I  - I-cache enable
; [13]   V  - High exception vectors (0xFFFF0000 vs 0x00000000)
; [14]   RR - Round-robin cache replacement
; [28]   TRE - TEX remap enable
; [29]   AFE - Access flag enable

; Enable MMU and caches
MRC     p15, 0, R0, c1, c0, 0
ORR     R0, R0, #0x1                 ; MMU
ORR     R0, R0, #0x4                 ; D-cache
ORR     R0, R0, #0x1000              ; I-cache
ORR     R0, R0, #0x800               ; Branch prediction
MCR     p15, 0, R0, c1, c0, 0
```

**c2 - Translation Table Base Registers:**

```assembly
; TTBR0 - User space translation table
MCR     p15, 0, R0, c2, c0, 0        ; Write TTBR0

; TTBR1 - Kernel space translation table
MCR     p15, 0, R0, c2, c0, 1        ; Write TTBR1

; TTBCR - Translation table base control
MCR     p15, 0, R0, c2, c0, 2        ; Write TTBCR
```

**c3 - Domain Access Control Register:**

```assembly
; Set domain 0 to manager, others no access
MOV     R0, #3                       ; Domain 0 = manager (11b)
MCR     p15, 0, R0, c3, c0, 0        ; Write DACR
```

**c5/c6 - Fault Status and Fault Address:**

```assembly
; Read fault information after abort
MRC     p15, 0, R0, c5, c0, 0        ; DFSR - Data Fault Status
MRC     p15, 0, R0, c5, c0, 1        ; IFSR - Instruction Fault Status
MRC     p15, 0, R0, c6, c0, 0        ; DFAR - Data Fault Address
MRC     p15, 0, R0, c6, c0, 2        ; IFAR - Instruction Fault Address
```

**c7 - Cache and Branch Predictor Maintenance:**

```assembly
; Invalidate entire I-cache
MOV     R0, #0
MCR     p15, 0, R0, c7, c5, 0        ; ICIALLU

; Invalidate I-cache line by MVA
MCR     p15, 0, R0, c7, c5, 1        ; ICIMVAU

; Clean D-cache line by MVA
MCR     p15, 0, R0, c7, c10, 1       ; DCCMVAC

; Clean and invalidate D-cache line by MVA
MCR     p15, 0, R0, c7, c14, 1       ; DCCIMVAC

; Invalidate branch predictor
MOV     R0, #0
MCR     p15, 0, R0, c7, c5, 6        ; BPIALL

````

**c8 - TLB Maintenance:**
```assembly
; Invalidate entire unified TLB
MOV     R0, #0
MCR     p15, 0, R0, c8, c7, 0        ; TLBIALL

; Invalidate TLB entry by MVA
MCR     p15, 0, R0, c8, c7, 1        ; TLBIMVA

; Invalidate TLB by ASID
MCR     p15, 0, R0, c8, c7, 2        ; TLBIASID

; Invalidate instruction TLB
MCR     p15, 0, R0, c8, c5, 0        ; ITLBIALL

; Invalidate data TLB
MCR     p15, 0, R0, c8, c6, 0        ; DTLBIALL
````

**c9 - Performance Monitors and Cache Lockdown:**

```assembly
; Performance Monitor Control Register
MRC     p15, 0, R0, c9, c12, 0       ; Read PMCR
ORR     R0, R0, #1                   ; Enable all counters
ORR     R0, R0, #2                   ; Reset event counters
ORR     R0, R0, #4                   ; Reset cycle counter
MCR     p15, 0, R0, c9, c12, 0       ; Write PMCR

; Count Enable Set Register
MOV     R0, #0x80000001              ; Enable cycle counter and counter 0
MCR     p15, 0, R0, c9, c12, 1       ; Write PMCNTENSET

; Event Counter Selection Register
MOV     R0, #0                       ; Select counter 0
MCR     p15, 0, R0, c9, c12, 5       ; Write PMSELR

; Event Type Select Register
MOV     R0, #0x04                    ; Event 0x04 = D-cache access
MCR     p15, 0, R0, c9, c13, 1       ; Write PMXEVTYPER

; Read cycle counter
MRC     p15, 0, R0, c9, c13, 0       ; Read PMCCNTR

; Read event counter
MRC     p15, 0, R0, c9, c13, 2       ; Read PMXEVCNTR (selected counter)
```

**c10 - Memory Remap and TLB Lockdown:**

```assembly
; Primary Region Remap Register
MRC     p15, 0, R0, c10, c2, 0       ; Read PRRR

; Normal Memory Remap Register
MRC     p15, 0, R0, c10, c2, 1       ; Read NMRR
```

**c13 - Context ID and Thread Registers:**

```assembly
; Context ID Register (ASID)
MOV     R0, #5                       ; Set ASID to 5
MCR     p15, 0, R0, c13, c0, 1       ; Write CONTEXTIDR

; Thread ID registers (for thread-local storage)
MCR     p15, 0, R0, c13, c0, 2       ; Write TPIDRURW (user read/write)
MCR     p15, 0, R0, c13, c0, 3       ; Write TPIDRURO (user read-only)
MCR     p15, 0, R0, c13, c0, 4       ; Write TPIDRPRW (privileged)

; Read thread ID
MRC     p15, 0, R0, c13, c0, 2       ; Read TPIDRURW
```

**c15 - Implementation-Defined Registers:**

CP15 c15 is reserved for implementation-specific features. Different ARM cores use this for various purposes:

```assembly
; Example: Cortex-A9 Auxiliary Control Register
MRC     p15, 0, R0, c1, c0, 1        ; Read ACTLR
ORR     R0, R0, #(1 << 6)            ; Enable SMP mode
MCR     p15, 0, R0, c1, c0, 1        ; Write ACTLR

; Implementation-specific cache operations might use c15
; (varies by processor)
```

**VFP/NEON Coprocessors (CP10/CP11):**

VFP uses coprocessors 10 and 11 for floating-point operations:

```assembly
; Enable VFP/NEON access
MRC     p15, 0, R0, c1, c0, 2        ; Read CPACR (Coprocessor Access Control)
ORR     R0, R0, #(0xF << 20)         ; Enable CP10 and CP11 (full access)
MCR     p15, 0, R0, c1, c0, 2        ; Write CPACR
ISB                                  ; Synchronize

; Enable VFP
MOV     R0, #0x40000000
VMSR    FPEXC, R0                    ; Enable VFP (EN bit in FPEXC)

; Access FPSCR (Floating-Point Status and Control Register)
VMRS    R0, FPSCR                    ; Move FPSCR to R0
BIC     R0, R0, #0x00370000          ; Clear exception enable bits
VMSR    FPSCR, R0                    ; Move R0 to FPSCR
```

**Coprocessor Access Control:**

The CPACR (Coprocessor Access Control Register) controls access to coprocessors from different privilege levels:

```assembly
; Read CPACR
MRC     p15, 0, R0, c1, c0, 2

; CPACR format: 2 bits per coprocessor
; 00 = Access denied
; 01 = Privileged access only
; 10 = Reserved
; 11 = Full access (privileged and unprivileged)

; Enable CP10 and CP11 for full access (VFP/NEON)
ORR     R0, R0, #(0xF << 20)         ; CP10/CP11 = 0b11 each
MCR     p15, 0, R0, c1, c0, 2
```

**Synchronization Requirements:**

Coprocessor register accesses affecting processor state require synchronization barriers:

```assembly
; After modifying MMU configuration
MCR     p15, 0, R0, c2, c0, 0        ; Write TTBR0
DSB                                  ; Ensure write completes
ISB                                  ; Flush pipeline

; After TLB invalidation
MCR     p15, 0, R0, c8, c7, 0        ; TLBIALL
DSB                                  ; Wait for completion
ISB                                  ; Synchronize context

; After cache maintenance
MCR     p15, 0, R0, c7, c5, 0        ; Invalidate I-cache
DSB                                  ; Data synchronization
ISB                                  ; Instruction synchronization
```

**Complete MMU Setup Example:**

```assembly
setup_mmu:
    ; Disable MMU and caches
    MRC     p15, 0, R0, c1, c0, 0
    BIC     R0, R0, #0x1             ; Disable MMU
    BIC     R0, R0, #0x4             ; Disable D-cache
    BIC     R0, R0, #0x1000          ; Disable I-cache
    BIC     R0, R0, #0x800           ; Disable branch prediction
    MCR     p15, 0, R0, c1, c0, 0
    DSB
    ISB
    
    ; Invalidate caches
    MOV     R0, #0
    MCR     p15, 0, R0, c7, c5, 0    ; Invalidate I-cache
    MCR     p15, 0, R0, c7, c6, 0    ; Invalidate D-cache
    
    ; Invalidate TLB
    MCR     p15, 0, R0, c8, c7, 0    ; TLBIALL
    DSB
    ISB
    
    ; Set domain access (domain 0 = client)
    MOV     R0, #1
    MCR     p15, 0, R0, c3, c0, 0    ; Write DACR
    
    ; Build page tables (implementation omitted)
    BL      build_page_tables
    
    ; Set TTBR0
    LDR     R0, =page_table_base
    MCR     p15, 0, R0, c2, c0, 0    ; Write TTBR0
    
    ; Set TTBCR (use only TTBR0, split at 0x00000000)
    MOV     R0, #0
    MCR     p15, 0, R0, c2, c0, 2    ; Write TTBCR
    
    DSB
    ISB
    
    ; Enable MMU, caches, branch prediction
    MRC     p15, 0, R0, c1, c0, 0
    ORR     R0, R0, #0x1             ; Enable MMU
    ORR     R0, R0, #0x4             ; Enable D-cache
    ORR     R0, R0, #0x1000          ; Enable I-cache
    ORR     R0, R0, #0x800           ; Enable branch prediction
    MCR     p15, 0, R0, c1, c0, 0
    DSB
    ISB
    
    BX      LR
```

**Debug and Trace Coprocessor (CP14):**

CP14 provides access to debug, breakpoint, and watchpoint registers:

```assembly
; Set breakpoint
; R0 = breakpoint address
MCR     p14, 0, R0, c0, c0, 4        ; Write DBGBVR0 (Breakpoint Value Register 0)

MOV     R1, #0x1E7                   ; Enable breakpoint, match address
MCR     p14, 0, R1, c0, c0, 5        ; Write DBGBCR0 (Breakpoint Control Register 0)

; Read Debug Status and Control Register
MRC     p14, 0, R0, c0, c1, 0        ; Read DBGDSCR
```

**ARMv8 AArch64 System Register Access:**

ARMv8 AArch64 state uses different syntax for system register access (MSR/MRS instructions instead of MCR/MRC):

```assembly
; ARMv8 AArch64 examples
MRS     X0, SCTLR_EL1                ; Read System Control Register
MSR     TTBR0_EL1, X0                ; Write Translation Table Base Register
MRS     X0, ID_AA64PFR0_EL1          ; Read Processor Feature Register

; Cache maintenance
DC      CIVAC, X0                    ; Clean and invalidate by VA
IC      IALLU                        ; Invalidate all I-cache

; TLB maintenance
TLBI    VMALLE1                      ; Invalidate all TLB entries
```

**Key Points:**

- System calls use SVC instruction to transition user mode → kernel mode
- MMU provides virtual memory through two-level page table translation
- TLB caches translations and requires explicit invalidation after page table modifications
- Cache maintenance operations essential for DMA, self-modifying code, and coherency
- CP15 provides system control through coprocessor registers accessed via MCR/MRC
- Synchronization barriers (DSB, ISB) required after configuration changes
- Different coprocessor numbers allocated for VFP (CP10/CP11), debug (CP14), and system control (CP15)

done

---

