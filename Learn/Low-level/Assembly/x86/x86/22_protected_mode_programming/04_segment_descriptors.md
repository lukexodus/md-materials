## Segment Descriptors


Segment descriptors are 8-byte (64-bit) data structures that completely define a memory segment's properties. They exist in both GDT and LDT.

### Descriptor Format

```
63        56 55  52 51  48 47      40 39      32
+----------+------+------+----------+----------+
|  Base    |Flags |Limit | Access   |  Base    |
| 24-31    |      |16-19 |   Byte   |  16-23   |
+----------+------+------+----------+----------+

31                16 15              0
+------------------+------------------+
|   Base 0-15      |   Limit 0-15     |
+------------------+------------------+
```

### Base Address (32 bits, split)

- Bits 16-31 of lower dword: Base 0-15
- Bits 0-7 of upper dword: Base 16-23
- Bits 24-31 of upper dword: Base 24-31

The base address specifies the linear address where the segment begins.

### Limit (20 bits, split)

- Bits 0-15 of lower dword: Limit 0-15
- Bits 16-19 of upper dword: Limit 16-19

The limit defines the segment size. Its interpretation depends on the G flag:

- **G=0 (byte granularity)**: Limit in bytes (max 1 MB)
- **G=1 (4KB granularity)**: Limit in 4KB pages (max 4 GB)

Actual segment size = (Limit + 1) × Granularity

### Access Byte (bits 40-47)

```
7   6   5   4   3   2   1   0
+---+-------+---+-------------+
| P | DPL   | S |    Type     |
+---+-------+---+-------------+
```

**P (Present bit, bit 47)**:

- 1 = Segment is present in memory
- 0 = Segment not present (causes segment-not-present exception)

**DPL (Descriptor Privilege Level, bits 45-46)**:

- 00 = Ring 0 (highest privilege, kernel)
- 01 = Ring 1
- 10 = Ring 2
- 11 = Ring 3 (lowest privilege, user mode)

**S (Descriptor type, bit 44)**:

- 0 = System segment (LDT, TSS, gates)
- 1 = Code or data segment

**Type (bits 40-43)**: Depends on S flag

For **code/data segments (S=1)**:

```
Bit 43: Executable (1 = code, 0 = data)
Bit 42: Direction/Conforming
        - Data: 0 = grows up, 1 = grows down
        - Code: 0 = non-conforming, 1 = conforming
Bit 41: Readable/Writable
        - Code: 0 = execute-only, 1 = readable
        - Data: 0 = read-only, 1 = writable
Bit 40: Accessed (set by CPU when segment accessed)
```

Common access byte values:

- `10011010b` (0x9A): Code segment, present, DPL=0, executable, readable
- `10010010b` (0x92): Data segment, present, DPL=0, writable
- `11111010b` (0xFA): Code segment, present, DPL=3, executable, readable
- `11110010b` (0xF2): Data segment, present, DPL=3, writable

For **system segments (S=0)**, Type identifies the system segment:

- `0x1`: Available 16-bit TSS
- `0x2`: LDT descriptor
- `0x3`: Busy 16-bit TSS
- `0x9`: Available 32-bit TSS
- `0xB`: Busy 32-bit TSS

### Flags (bits 52-55)

```
7   6   5   4
+---+---+---+---+
| G | D | L | A |
+---+---+---+---+
```

**G (Granularity, bit 55)**:

- 0 = Limit in bytes
- 1 = Limit in 4KB pages

**D/B (Default/Big, bit 54)**:

- Code segment: 0 = 16-bit, 1 = 32-bit
- Data segment: 0 = 16-bit stack (SP), 1 = 32-bit stack (ESP)
- Affects default operand size and address size

**L (Long mode, bit 53)**:

- 1 = 64-bit code segment (x86-64 only)
- 0 = Not a 64-bit segment
- [Inference] Should be 0 in pure 32-bit protected mode

**A (Available, bit 52)**:

- Available for system use (typically unused)

### Descriptor Types

**Code Segment Descriptor:**

```nasm
; 32-bit code segment, base=0, limit=4GB, DPL=0
dw 0xFFFF           ; Limit 0-15
dw 0x0000           ; Base 0-15
db 0x00             ; Base 16-23
db 10011010b        ; P=1, DPL=00, S=1, Type=1010 (exec/readable)
db 11001111b        ; G=1, D=1, L=0, Limit 16-19=F
db 0x00             ; Base 24-31
```

**Data Segment Descriptor:**

```nasm
; 32-bit data segment, base=0, limit=4GB, DPL=0
dw 0xFFFF           ; Limit 0-15
dw 0x0000           ; Base 0-15
db 0x00             ; Base 16-23
db 10010010b        ; P=1, DPL=00, S=1, Type=0010 (writable)
db 11001111b        ; G=1, D=1, L=0, Limit 16-19=F
db 0x00             ; Base 24-31
```

**Stack Segment Descriptor:**

```nasm
; Stack segment (expand-down), base=0, limit=4GB, DPL=0
dw 0xFFFF           ; Limit 0-15
dw 0x0000           ; Base 0-15
db 0x00             ; Base 16-23
db 10010110b        ; P=1, DPL=00, S=1, Type=0110 (expand-down, writable)
db 11001111b        ; G=1, D=1, L=0, Limit 16-19=F
db 0x00             ; Base 24-31
```

**User Mode Code Descriptor:**

```nasm
; 32-bit user code, base=0, limit=4GB, DPL=3
dw 0xFFFF           ; Limit 0-15
dw 0x0000           ; Base 0-15
db 0x00             ; Base 16-23
db 11111010b        ; P=1, DPL=11, S=1, Type=1010
db 11001111b        ; G=1, D=1, L=0, Limit 16-19=F
db 0x00             ; Base 24-31
```

