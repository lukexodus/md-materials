## Interrupt Priorities


Interrupt priorities determine which interrupt the processor services when multiple interrupts arrive simultaneously. The x86 architecture defines a strict priority hierarchy:

**Priority Levels (Highest to Lowest)**:

1. **Hardware Reset and Machine Checks**: Highest priority, non-maskable
2. **INIT Signal**: System initialization
3. **Non-Maskable Interrupts (NMI)**: Vector 2, cannot be disabled by software
4. **INTR (Maskable Hardware Interrupts)**: External interrupts through INTR pin
5. **Software Interrupts**: INT n instructions
6. **Single-Step Traps**: Debug exceptions

**Exception Priority Within Instruction Execution**:

When multiple exceptions can occur during a single instruction, the processor uses the following priority:

**Highest Priority**:

- Faults during instruction fetch (breakpoint, page fault on code)
- Instruction length limit violations

**Second Priority**:

- Invalid opcode, privilege violations
- Segment limit violations during operand fetch

**Third Priority**:

- Page faults during operand fetch or write
- Alignment check faults

**Lowest Priority**:

- x87 FPU exceptions
- SIMD exceptions

**External Interrupt Priority**: For hardware interrupts managed by the interrupt controller:

**8259 PIC (Legacy)**: Uses a fixed priority scheme where IRQ0 has the highest priority and IRQ7 (or IRQ15 for the slave controller) has the lowest. The priority can be rotated through software commands.

```assembly
; Example: Masking IRQ 3 on master 8259 PIC
in al, 0x21          ; Read master PIC mask register
or al, 0x08          ; Set bit 3 (IRQ 3)
out 0x21, al         ; Write back mask
```

**APIC (Modern Systems)**: Uses a priority-based scheme with 16 priority levels. Each interrupt vector has an associated priority level derived from the vector number. The processor services the highest priority interrupt when multiple interrupts are pending. The Task Priority Register (TPR) allows the operating system to block interrupts below a certain priority threshold.

APIC priority calculation:

- Priority Class = Vector / 16
- Priority Sub-class = Vector % 16

**Key Points**:

- NMIs always have higher priority than maskable interrupts regardless of vector number
- Among maskable interrupts, hardware interrupts have configurable priorities through the interrupt controller
- Software interrupts (INT instruction) execute synchronously and don't compete with asynchronous hardware interrupts
- Double faults (#DF) occur when the processor fails to handle an exception, creating a special high-priority abort condition
- Within the same priority class in APIC, the interrupt with the highest vector number has priority

