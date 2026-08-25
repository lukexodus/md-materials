## Fundamental Concepts


**Implicit Registers:**

- **ESI (Source Index):** Points to source data location
- **EDI (Destination Index):** Points to destination data location
- **ECX (Count Register):** Loop counter for repeated operations
- **AL/AX/EAX/RAX:** Accumulator for scan and compare operations

**Direction Flag (DF):** Controls whether string operations increment or decrement index registers.

```assembly
CLD    ; Clear Direction Flag (DF = 0): auto-increment ESI/EDI
STD    ; Set Direction Flag (DF = 1): auto-decrement ESI/EDI
```

When DF = 0: ESI and EDI increase after each operation (forward processing) When DF = 1: ESI and EDI decrease after each operation (backward processing)

**Size Suffixes:** String instructions come in different sizes:

- **B:** Byte (8-bit) - adjusts ESI/EDI by 1
- **W:** Word (16-bit) - adjusts ESI/EDI by 2
- **D:** Doubleword (32-bit) - adjusts ESI/EDI by 4
- **Q:** Quadword (64-bit) - adjusts ESI/EDI by 8 (64-bit mode only)

**Repeat Prefixes:** Repeat prefixes cause string instructions to execute ECX times automatically:

- **REP:** Repeat while ECX ≠ 0
- **REPE/REPZ:** Repeat while equal/zero and ECX ≠ 0
- **REPNE/REPNZ:** Repeat while not equal/not zero and ECX ≠ 0

---

