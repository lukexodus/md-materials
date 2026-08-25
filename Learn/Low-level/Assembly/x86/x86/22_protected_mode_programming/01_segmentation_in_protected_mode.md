## Segmentation in Protected Mode


Protected mode fundamentally changes how memory segmentation works compared to real mode. Instead of segment registers containing physical base addresses, they hold **selectors** that index into descriptor tables. These tables contain **segment descriptors** that define the actual properties of memory segments.

### Segment Selectors

A segment selector is a 16-bit value loaded into segment registers (CS, DS, ES, FS, GS, SS) with the following structure:

```
15                           3  2  1  0
+-----------------------------+---+----+
|         Index               |TI |RPL |
+-----------------------------+---+----+
```

- **Index (bits 3-15)**: Index into the descriptor table (13 bits = 8192 possible descriptors)
- **TI (Table Indicator, bit 2)**: 0 = GDT, 1 = LDT
- **RPL (Requested Privilege Level, bits 0-1)**: Privilege level (0-3)

When a segment register is loaded with a selector, the processor locates the corresponding descriptor, validates access rights, and caches the descriptor's information in hidden shadow registers for fast access.

