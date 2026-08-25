## Memory Segmentation Model


The segmentation model in x86 architecture divides memory into logical segments, each serving different purposes. This model has evolved significantly across processor generations and operating modes.

### Real Mode Segmentation

In real mode (the original 8086 model), physical addresses are calculated using segment:offset pairs. A segment register contains a 16-bit segment value, which is multiplied by 16 (shifted left by 4 bits) and added to a 16-bit offset to produce a 20-bit physical address. This mechanism allowed the 8086 to address 1 MB of memory despite having only 16-bit registers.

The formula for physical address calculation is: Physical Address = (Segment × 16) + Offset

This created overlapping segments where different segment:offset combinations could reference the same physical memory location. For instance, 0100:0020 and 0101:0010 both reference physical address 0x00420.

### Protected Mode Segmentation

Protected mode, introduced with the 80286 and enhanced in the 80386, transformed segments from simple address multipliers into complex descriptors with protection mechanisms. Instead of containing direct address components, segment registers hold selectors that index into descriptor tables.

Each segment descriptor contains:

**Base Address**: The linear address where the segment begins (24 bits in 80286, 32 bits in 80386+)

**Limit**: The segment size, defining the maximum valid offset within the segment

**Access Rights**: Privilege level (ring 0-3), segment type (code or data), read/write/execute permissions

**Attributes**: Granularity (byte or 4KB page), default operation size (16-bit or 32-bit), and other flags

The Global Descriptor Table (GDT) contains system-wide segment descriptors, while Local Descriptor Tables (LDT) can contain process-specific descriptors. The GDTR and LDTR registers point to these tables.

When a program attempts to access memory, the processor performs segmentation checks:

- Verifying the offset doesn't exceed the segment limit
- Checking privilege levels (Current Privilege Level vs. Descriptor Privilege Level)
- Ensuring the access type (read/write/execute) is permitted
- Validating the segment is present in memory

Violations trigger protection faults (General Protection Fault, Segment Not Present, etc.), which were revolutionary for operating system stability and security when introduced.

### Long Mode Segmentation

x86-64 architecture's long mode largely disables traditional segmentation for most purposes. The CS, DS, ES, and SS segment bases are forced to zero, and limit checks are disabled. This effectively creates a flat 64-bit address space. However, FS and GS segments retain their functionality and are commonly used for thread-local storage and operating system kernel data structures.

