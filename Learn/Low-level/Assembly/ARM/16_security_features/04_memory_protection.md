## Memory Protection


ARM architectures provide multiple layers of memory protection mechanisms to enforce security policies, isolate processes, and prevent unauthorized access.

### Memory Management Unit (MMU)

The MMU translates virtual addresses to physical addresses while enforcing access permissions. It uses a hierarchical page table structure with configurable page sizes.

### Translation Table Structure

**AArch64 Translation Tables** support multiple granule sizes:

- 4KB pages: 4-level page tables (512 entries per level)
- 16KB pages: 4-level page tables (2048 entries per level)
- 64KB pages: 3-level page tables (8192 entries per level)

Each translation table entry contains:

- Output address (physical address)
- Access permissions (AP bits)
- Memory attributes (AttrIndx)
- Security attributes (NS bit in Secure state)
- Shareability attributes
- Access flag and dirty bit

### Access Permission Control

**AP[2:1] bits** in translation table entries control read/write permissions:

- `00`: Read/Write at EL1, No access at EL0
- `01`: Read/Write at EL1 and EL0
- `10`: Read-only at EL1, No access at EL0
- `11`: Read-only at EL1 and EL0

**UXN/PXN bits** control execution permissions:

- **UXN (Unprivileged Execute Never)**: Prevents execution at EL0
- **PXN (Privileged Execute Never)**: Prevents execution at EL1/EL2

**Example:**

```assembly
// Creating a page table entry for user read-only, kernel read/write page
// X0 = virtual address of page table entry
// X1 = physical address of page
// Assume 4KB granule

create_pte:
        // Set up the descriptor
        AND     X1, X1, #0xFFFFFFFFF000     // Mask to page boundary
        ORR     X1, X1, #0x3                // Valid, page descriptor
        
        // Set access permissions: AP[2:1] = 11 (read-only all levels)
        // But we want kernel RW, user RO, so use AP[2:1] = 10
        ORR     X1, X1, #(0x2 << 6)         // AP[2:1] = 10
        
        // Allow user execution (clear UXN), prevent kernel execution
        ORR     X1, X1, #(0x1 << 53)        // PXN = 1
        // UXN = 0 (bit 54 cleared)
        
        // Set memory attributes (index to MAIR)
        ORR     X1, X1, #(0x0 << 2)         // AttrIndx = 0 (normal memory)
        
        // Set shareability
        ORR     X1, X1, #(0x3 << 8)         // Inner shareable
        
        // Set access flag
        ORR     X1, X1, #(0x1 << 10)        // AF = 1 (accessed)
        
        // Store the entry
        STR     X1, [X0]
        
        // Ensure visibility
        DSB     ISH
        
        RET
```

### Memory Attributes

**MAIR_ELx registers** (Memory Attribute Indirection Registers) define memory types referenced by translation table entries. Each MAIR register contains 8 attribute encoding fields.

**Memory Types:**

- **Device memory**: Unpredictable behavior if speculative access occurs; used for memory-mapped I/O
    
    - Device-nGnRnE: Non-gathering, non-reordering, no early write acknowledgment
    - Device-nGnRE: Non-gathering, non-reordering, early write acknowledgment
    - Device-GRE: Gathering, reordering, early write acknowledgment
- **Normal memory**: Safe for speculative access; used for code and data
    
    - Non-cacheable
    - Write-through cacheable
    - Write-back cacheable
    - Write-back transient cacheable

**Example:**

```assembly
// Setting up MAIR_EL1 with common memory attributes
setup_mair:
        // Attr0: Normal memory, write-back cacheable
        MOV     X0, #0xFF                   // Inner/Outer Write-Back
        
        // Attr1: Device-nGnRnE (strongly ordered device)
        ORR     X0, X0, #(0x00 << 8)
        
        // Attr2: Normal memory, non-cacheable
        ORR     X0, X0, #(0x44 << 16)
        
        // Attr3: Device-GRE
        ORR     X0, X0, #(0x0C << 24)
        
        MSR     MAIR_EL1, X0
        ISB                                 // Synchronize context change
        
        RET
```

### Memory Protection Unit (MPU)

Some ARM processors (especially embedded/real-time variants) use an MPU instead of or alongside an MMU. The MPU divides memory into regions with configurable attributes but without address translation.

**MPU Regions** are defined by:

- Base address
- Size (must be power of 2, minimum 32 bytes)
- Access permissions
- Memory attributes
- Enable/disable bit

**[Inference]** MPU configuration typically occurs at system initialization and requires privileged access to modify. The number of supported regions varies by implementation.

### Pointer Authentication (ARMv8.3-PAuth)

Pointer Authentication cryptographically signs pointers to detect corruption or malicious modification. This provides protection against return-oriented programming (ROP) and jump-oriented programming (JOP) attacks.

**Pointer Authentication Instructions:**

- **PACIA, PACIB**: Sign pointer using key A or B (instruction address)
- **PACDA, PACDB**: Sign pointer using key A or B (data address)
- **AUTIA, AUTIB**: Authenticate pointer using key A or B (instruction)
- **AUTDA, AUTDB**: Authenticate pointer using key A or B (data)
- **XPACI, XPACD**: Strip authentication code

**Example:**

```assembly
// Function prologue with return address signing
function_with_pac:
        PACIASP                             // Sign LR using SP as modifier, key A
        STP     X29, X30, [SP, #-16]!      // Save frame pointer and signed LR
        MOV     X29, SP
        
        // Function body
        // ...
        
        // Function epilogue
        LDP     X29, X30, [SP], #16         // Restore frame pointer and signed LR
        AUTIASP                             // Authenticate LR using SP, key A
        RET                                 // Return; authentication failure causes exception
```

**Example:**

```assembly
// Protecting a function pointer in a structure
// X0 = pointer to structure
// X1 = function pointer to protect
// X2 = context value (discriminator)

store_protected_fptr:
        PACIA   X1, X2                      // Sign function pointer with context
        STR     X1, [X0, #FPTR_OFFSET]      // Store signed pointer
        RET

call_protected_fptr:
        LDR     X1, [X0, #FPTR_OFFSET]      // Load signed pointer
        AUTIA   X1, X2                      // Authenticate with same context
        BLR     X1                          // Call authenticated pointer
        RET
```

### Memory Tagging Extension (ARMv8.5-MTE)

MTE assigns 4-bit tags to memory allocations and pointers, detecting memory safety violations at runtime.

**Tag Management Instructions:**

- **IRG**: Insert Random Tag
- **GMI**: Tag Mask Insert
- **ADDG**: Add with tag
- **SUBG**: Subtract with tag
- **STG**: Store Allocation Tag
- **LDG**: Load Allocation Tag
- **ST2G, STZ2G, STZG**: Store multiple tags

**Load/Store Instructions** with tag checking:

- **LDGM, STGM**: Load/Store multiple tags
- Normal load/store instructions check tags when MTE is enabled

**Example:**

```assembly
// Allocating tagged memory
// X0 = untagged pointer to allocated memory
// X1 = size of allocation

tag_allocation:
        IRG     X0, X0, XZR                 // Generate random tag for pointer
        MOV     X2, X0                      // Copy tagged pointer
        
        // Set allocation tags in memory
tag_loop:
        STG     X2, [X2], #16               // Store tag, advance by 16 bytes
        SUB     X1, X1, #16
        CBNZ    X1, tag_loop
        
        // X0 contains tagged pointer
        RET

// Using tagged pointer
tagged_store:
        // X0 = tagged pointer
        // X1 = value to store
        STR     X1, [X0]                    // Tag checked automatically
        // If pointer tag doesn't match memory tag, generates exception
        RET
```

### Domain-Based Protection (AArch32)

**[Inference]** AArch32 state supports domain-based memory protection through the DACR (Domain Access Control Register). Domains partition memory into up to 16 sections with independent access control.

**Domain Access Types:**

- No access (00): Any access generates a fault
- Client (01): Access permissions checked
- Manager (11): Access permissions not checked

This feature is not available in AArch64 state.

### Execute-Never (XN) Protection

**XN attribute** in translation table entries prevents instruction fetches from specific memory regions, critical for preventing code injection attacks.

**Implementation Strategy:**

- Mark stack and heap as XN
- Mark data sections as XN
- Only mark explicitly designated code regions as executable

**Example:**

```assembly
// Setting up translation table entry for non-executable data page
// X0 = virtual address of page table entry
// X1 = physical address of data page

create_data_pte:
        AND     X1, X1, #0xFFFFFFFFF000
        ORR     X1, X1, #0x3                // Valid page
        ORR     X1, X1, #(0x1 << 54)        // UXN = 1 (user execute-never)
        ORR     X1, X1, #(0x1 << 53)        // PXN = 1 (privileged execute-never)
        ORR     X1, X1, #(0x1 << 6)         // AP[1] = 1 (read/write)
        
        STR     X1, [X0]
        DSB     ISH
        
        RET
```

### Cache Maintenance and Security

Cache maintenance operations are security-relevant because they affect timing and data visibility across security boundaries.

**Cache Maintenance Instructions:**

- **DC CIVAC**: Clean and invalidate by VA to PoC
- **DC CVAU**: Clean by VA to PoU
- **IC IVAU**: Invalidate instruction cache by VA to PoU
- **DC ZVA**: Zero cache line by VA

**Security Considerations:**

- Secure data in cache may leak to Non-secure world if not properly cleaned
- Cache timing can reveal information about execution patterns
- Translation table walks can be cached, affecting access times

**Example:**

```assembly
// Securely clearing a buffer before returning to Non-secure state
// X0 = buffer address
// X1 = buffer size

secure_clear_buffer:
        MOV     X2, X0
        MOV     X3, X1
        
        // Zero the buffer
clear_loop:
        STR     XZR, [X2], #8
        SUB     X3, X3, #8
        CBNZ    X3, clear_loop
        
        // Clean cache to ensure zeros written to memory
        MOV     X2, X0
        MOV     X3, X1
        
cache_clean_loop:
        DC      CIVAC, X2                   // Clean and invalidate by VA
        ADD     X2, X2, #64                 // Assume 64-byte cache line
        SUB     X3, X3, #64
        CBNZ    X3, cache_clean_loop
        
        DSB     SY                          // Ensure completion
        
        RET
```

**Key Points:**

- Memory protection operates at multiple privilege levels and security states
- Translation table entries combine address translation with access control
- Modern ARM architectures provide hardware-based protection against common memory exploits through Pointer Authentication and Memory Tagging
- Execute-Never protection should be default for data regions
- Cache maintenance is critical when transitioning between security domains
- Permission checks occur on each memory access; privileged software cannot bypass them without explicit configuration
- TLB maintenance operations must be performed after modifying translation tables

---

