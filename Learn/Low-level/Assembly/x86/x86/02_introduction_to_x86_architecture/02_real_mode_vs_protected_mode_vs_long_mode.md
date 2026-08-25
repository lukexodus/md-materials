## Real Mode vs Protected Mode vs Long Mode


x86 processors operate in distinct modes that determine their addressing capabilities, memory protection mechanisms, and available features. These modes reflect the architecture's evolution while maintaining backward compatibility.

### Real Mode

Real mode is the operating mode of the original 8086 processor and remains the default mode when x86 processors first power on. In real mode, the processor behaves like an 8086, providing direct hardware access and simple memory addressing.

Memory addressing in real mode uses segmentation with 16-bit segment registers and 16-bit offset values. The physical address is calculated as (segment × 16) + offset, producing a 20-bit physical address capable of accessing 1 MB of memory (0x00000 to 0xFFFFF). This creates the characteristic segment:offset addressing format, where an address might be written as 0x1234:0x5678, representing physical address 0x179B8.

Real mode provides no memory protection mechanisms. All code executes with full hardware privileges, and any program can access any memory location or I/O port. There are no privilege levels, virtual memory, or memory segmentation protection. Programs can directly access hardware and overwrite the operating system or other programs' memory, leading to system instability.

The limited addressing space creates the famous "640 KB barrier" for DOS programs, as the upper 384 KB of the 1 MB address space was reserved for hardware ROMs and memory-mapped I/O. Real mode remains important because BIOS firmware runs in this mode, and operating systems must begin execution in real mode before transitioning to more advanced modes.

### Protected Mode

Protected mode, introduced with the 80286 and significantly enhanced in the 80386, provides memory protection, privilege levels, and advanced memory management. The 80286 provided 16-bit protected mode, while the 80386 and later processors support 32-bit protected mode, which became the standard for modern 32-bit operating systems.

Memory addressing in 32-bit protected mode uses either segmentation or a flat memory model. Segment registers no longer contain the segment base address directly; instead, they contain selectors that index into descriptor tables (GDT - Global Descriptor Table, or LDT - Local Descriptor Table). Each descriptor defines a segment's base address, limit (size), privilege level, and access rights. This indirection enables sophisticated memory protection.

Protected mode implements four privilege levels (rings 0-3), though most operating systems use only ring 0 (kernel mode) and ring 3 (user mode). The processor enforces privilege checks on memory access, I/O operations, and instruction execution. Code at a lower privilege level cannot access higher-privileged memory or execute privileged instructions without going through controlled gates.

Virtual memory support through paging allows the operating system to manage memory in 4 KB pages (or larger page sizes like 2 MB or 4 MB). The paging mechanism translates linear addresses to physical addresses through page tables, enabling features like memory protection, demand paging, copy-on-write, and the ability to use more virtual memory than physical RAM available.

The Task State Segment (TSS) provides hardware support for multitasking, storing processor state during task switches. Protected mode also introduces various gates (call gates, interrupt gates, trap gates, task gates) that control transitions between different privilege levels and segments, ensuring system security.

Protected mode allows access to the full 32-bit address space (4 GB) with the 80386 and later processors. Modern 32-bit operating systems like Windows XP, Linux (32-bit), and others run in protected mode, taking advantage of memory protection, virtual memory, and hardware-enforced security.

### Long Mode

Long mode, introduced with the x86-64 architecture extension, provides 64-bit computing capabilities. It consists of two sub-modes: 64-bit mode (the primary operating mode for 64-bit code) and compatibility mode (which allows 16-bit and 32-bit code to run under a 64-bit operating system).

In 64-bit mode, the processor provides 64-bit addressing, though current implementations typically support only 48-bit or 57-bit virtual addressing due to practical limitations. This provides a theoretical address space of 256 TB (48-bit) or 128 PB (57-bit). Physical addressing is also extended, with most modern processors supporting 48-52 bits of physical addressing.

The general-purpose register set expands from 8 registers (EAX, EBX, ECX, EDX, ESI, EDI, EBP, ESP) to 16 registers (RAX, RBX, RCX, RDX, RSI, RDI, RBP, RSP, R8-R15). All general-purpose registers are 64 bits wide. The SSE register set also expands from 8 registers (XMM0-XMM7) to 16 registers (XMM0-XMM15), and with AVX, the vector registers become 256-bit YMM registers.

Long mode simplifies segmentation significantly. Segmentation is effectively disabled for code, data, and stack segments, with CS, DS, ES, and SS segment bases forced to zero (creating a flat memory model). The FS and GS segments remain usable with non-zero bases for special purposes like thread-local storage. This simplification eliminates much of the complexity associated with segmented memory models.

A new addressing mode, RIP-relative addressing, allows instructions to reference data relative to the instruction pointer. This facilitates position-independent code and improves code efficiency. The instruction encoding also changes slightly, with REX prefixes providing access to extended registers and 64-bit operand sizes.

Long mode requires paging to be enabled - it cannot operate without virtual memory. Page tables are extended to support 64-bit addressing through four-level (or five-level with recent processors) page table hierarchies: PML4 (Page Map Level 4), PDPT (Page Directory Pointer Table), PD (Page Directory), and PT (Page Table). Five-level paging adds PML5 above PML4.

Compatibility mode allows 16-bit and 32-bit applications to run under a 64-bit operating system without modification. In this mode, individual code segments can be marked as 32-bit or 16-bit, allowing legacy applications to execute while the operating system kernel runs in 64-bit mode. However, pure 16-bit real mode code cannot execute directly in long mode.

Transitioning between modes involves specific sequences. Moving from real mode to protected mode requires setting up descriptor tables, enabling the protection enable (PE) bit in CR0, and loading appropriate segment selectors. Transitioning to long mode requires enabling PAE (Physical Address Extension) paging, setting up long mode page tables, enabling long mode through the EFER MSR (Model Specific Register), then enabling paging in CR0.

