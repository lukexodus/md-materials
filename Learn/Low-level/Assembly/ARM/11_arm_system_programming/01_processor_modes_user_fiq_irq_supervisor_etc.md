## Processor Modes (User, FIQ, IRQ, Supervisor, etc.)


ARM processors operate in different privilege modes that control access to system resources and provide isolation between operating system code and user applications.

**ARMv7 (32-bit) Processor Modes:**

**User Mode (USR):**

- Unprivileged mode for normal application execution
- Cannot access protected system resources
- Cannot change CPSR mode bits
- Cannot execute privileged instructions
- No access to banked registers of other modes

**System Mode (SYS):**

- Privileged mode with same register set as User mode
- Can access all system resources
- Used by operating system tasks that need privileges
- Shares R0-R15 with User mode (no banking)

**Fast Interrupt Mode (FIQ):**

- Entered on FIQ exception
- Priority over IRQ
- Has banked registers: R8_fiq through R14_fiq, SPSR_fiq
- Seven banked registers allow faster interrupt handling (less context saving)
- Vector address: 0x0000001C or 0xFFFF001C

**Interrupt Mode (IRQ):**

- Entered on IRQ exception
- Normal interrupt processing
- Has banked registers: R13_irq, R14_irq, SPSR_irq
- Vector address: 0x00000018 or 0xFFFF0018

**Supervisor Mode (SVC):**

- Entered on reset or SVC (software interrupt) instruction
- Used by operating system kernel
- Has banked registers: R13_svc, R14_svc, SPSR_svc
- Vector address: 0x00000008 or 0xFFFF0008

**Abort Mode (ABT):**

- Entered on memory access violations
- Data abort or prefetch abort
- Has banked registers: R13_abt, R14_abt, SPSR_abt
- Data abort vector: 0x00000010 or 0xFFFF0010
- Prefetch abort vector: 0x0000000C or 0xFFFF000C

**Undefined Mode (UND):**

- Entered when undefined instruction executed
- Used for software emulation of instructions
- Has banked registers: R13_und, R14_und, SPSR_und
- Vector address: 0x00000004 or 0xFFFF0004

**Monitor Mode (MON) - Security Extensions:**

- Secure state management
- TrustZone context switching
- Has banked registers: R13_mon, R14_mon, SPSR_mon

**Hyp Mode (HYP) - Virtualization Extensions:**

- Hypervisor mode for virtualization
- Most privileged mode in ARMv7
- Has banked registers: R13_hyp, SPSR_hyp, ELR_hyp

**Register banking:**

Each mode has access to:

- R0-R7: Shared across all modes (not banked)
- R8-R12: Banked only in FIQ mode (R8_fiq-R12_fiq)
- R13 (SP): Banked in all privileged modes
- R14 (LR): Banked in all privileged modes
- R15 (PC): Shared across all modes
- CPSR: Current Program Status Register (shared, but modified by mode)
- SPSR: Saved Program Status Register (banked in privileged modes)

```
Mode    | R0-R7 | R8-R12 | R13(SP) | R14(LR) | R15(PC) | CPSR | SPSR
--------|-------|--------|---------|---------|---------|------|------
User    | ✓     | ✓      | ✓       | ✓       | ✓       | ✓    | -
System  | ✓     | ✓      | ✓       | ✓       | ✓       | ✓    | -
FIQ     | ✓     | Banked | Banked  | Banked  | ✓       | ✓    | ✓
IRQ     | ✓     | ✓      | Banked  | Banked  | ✓       | ✓    | ✓
SVC     | ✓     | ✓      | Banked  | Banked  | ✓       | ✓    | ✓
ABT     | ✓     | ✓      | Banked  | Banked  | ✓       | ✓    | ✓
UND     | ✓     | ✓      | Banked  | Banked  | ✓       | ✓    | ✓
```

**CPSR Mode bits (bits 4-0):**

```
10000 (0x10) - User mode
10001 (0x11) - FIQ mode
10010 (0x12) - IRQ mode
10011 (0x13) - Supervisor mode
10111 (0x17) - Abort mode
11011 (0x1B) - Undefined mode
11111 (0x1F) - System mode
11010 (0x1A) - Hyp mode (if supported)
10110 (0x16) - Monitor mode (if supported)
```

**CPSR Control bits:**

- N (bit 31): Negative flag
- Z (bit 30): Zero flag
- C (bit 29): Carry flag
- V (bit 28): Overflow flag
- Q (bit 27): Saturation flag
- IT[1:0] (bits 26-25): If-Then execution state (Thumb)
- J (bit 24): Jazelle state
- GE[3:0] (bits 19-16): Greater-than-or-Equal flags (SIMD)
- IT[7:2] (bits 15-10): If-Then execution state
- E (bit 9): Endianness (0=little, 1=big)
- A (bit 8): Asynchronous abort disable
- I (bit 7): IRQ disable
- F (bit 6): FIQ disable
- T (bit 5): Thumb state
- M[4:0] (bits 4-0): Mode bits

**ARMv8 Exception Levels (AArch64):**

ARMv8 uses Exception Levels instead of modes:

- EL0: User applications (unprivileged)
- EL1: Operating system kernel (privileged)
- EL2: Hypervisor (virtualization)
- EL3: Secure monitor (TrustZone)

