## Overview of String Instructions


String instructions work with implicit operands using the ESI (Extended Source Index) and EDI (Extended Destination Index) registers as pointers. They automatically increment or decrement these pointers after each operation, allowing efficient sequential processing.

### Core String Instructions

**MOVS** (Move String) - Copies data from [ESI] to [EDI] 
**LODS** (Load String) - Loads data from [ESI] into AL/AX/EAX/RAX 
**STOS** (Store String) - Stores data from AL/AX/EAX/RAX into [EDI] 
**CMPS** (Compare String) - Compares data at [ESI] with [EDI] 
**SCAS** (Scan String) - Compares data at [EDI] with AL/AX/EAX/RAX

Each instruction has variants for different data sizes:

- Byte operations: MOVSB, LODSB, STOSB, CMPSB, SCASB
- Word operations (16-bit): MOVSW, LODSW, STOSW, CMPSW, SCASW
- Doubleword operations (32-bit): MOVSD, LODSD, STOSD, CMPSD, SCASD
- Quadword operations (64-bit): MOVSQ, LODSQ, STOSQ, CMPSQ, SCASQ

---

