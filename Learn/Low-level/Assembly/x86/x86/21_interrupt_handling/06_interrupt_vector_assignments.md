## Interrupt Vector Assignments


The x86 architecture reserves specific vector ranges:

**Vectors 0-31 (Reserved by Intel)**:

- 0 (#DE): Divide Error
- 1 (#DB): Debug Exception
- 2: NMI (Non-Maskable Interrupt)
- 3 (#BP): Breakpoint
- 4 (#OF): Overflow
- 5 (#BR): BOUND Range Exceeded
- 6 (#UD): Invalid Opcode
- 7 (#NM): Device Not Available (FPU)
- 8 (#DF): Double Fault
- 9: Coprocessor Segment Overrun (legacy)
- 10 (#TS): Invalid TSS
- 11 (#NP): Segment Not Present
- 12 (#SS): Stack-Segment Fault
- 13 (#GP): General Protection Fault
- 14 (#PF): Page Fault
- 15: Reserved
- 16 (#MF): x87 FPU Error
- 17 (#AC): Alignment Check
- 18 (#MC): Machine Check
- 19 (#XM): SIMD Floating-Point Exception
- 20 (#VE): Virtualization Exception
- 21-31: Reserved for future use

**Vectors 32-255**: Available for user-defined interrupts, typically used for hardware IRQs and software interrupts. Operating systems map hardware interrupts starting from vector 32 (0x20) to avoid conflicts with CPU exceptions.

