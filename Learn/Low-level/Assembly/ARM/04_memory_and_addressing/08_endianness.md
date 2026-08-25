## Endianness


Endianness specifies the byte ordering for multi-byte values in memory. Little-endian stores the least significant byte at the lowest address; big-endian stores the most significant byte at the lowest address. ARM processors support both orderings, though little-endian predominates in modern systems.

### Little-Endian Layout

In little-endian ordering, a 32-bit value 0x12345678 stored at address 0x1000 appears in memory as:

```
Address:  0x1000  0x1001  0x1002  0x1003
Value:    0x78    0x56    0x34    0x12
          (LSB)                   (MSB)
```

The least significant byte (0x78) occupies the lowest address. Reading sequentially from low to high addresses yields bytes in increasing significance.

A 64-bit value 0x0123456789ABCDEF at 0x2000:

```
Address:  0x2000  0x2001  0x2002  0x2003  0x2004  0x2005  0x2006  0x2007
Value:    0xEF    0xCD    0xAB    0x89    0x67    0x45    0x23    0x01
```

### Big-Endian Layout

Big-endian reverses the byte order. The same 32-bit value 0x12345678 at 0x1000:

```
Address:  0x1000  0x1001  0x1002  0x1003
Value:    0x12    0x34    0x56    0x78
          (MSB)                   (LSB)
```

The most significant byte (0x12) occupies the lowest address, matching human-readable hexadecimal notation.

### ARM Endianness Configuration

ARMv8 processors operate in little-endian mode by default but support configurable endianness through exception level controls. The SCTLR_ELx registers contain endianness bits:

**EE bit (Exception Endianness)**: Controls endianness for explicit data accesses at the current exception level. When cleared (0), little-endian; when set (1), big-endian.

**E0E bit (Endianness of EL0)**: Controls EL0 (user-space) endianness independently of kernel endianness. This allows big-endian applications running on little-endian kernels (or vice versa).

Modern ARM systems overwhelmingly use little-endian mode. Linux on ARM defaults to little-endian for both kernel and user-space. [Inference: Big-endian ARM systems exist primarily in specialized embedded applications requiring big-endian network protocols or legacy compatibility.]

### Endianness and Data Interpretation

Endianness affects interpretation of multi-byte sequences but not individual bytes. A character array appears identical regardless of endianness:

```c
char str[] = "ABCD";
// Memory always contains: 'A' 'B' 'C' 'D' 0x00
// at sequential addresses regardless of endianness
```

Only when interpreting these bytes as multi-byte integers does endianness matter:

```c
int *p = (int *)str;
// Little-endian: *p = 0x44434241 (assuming ASCII)
// Big-endian:    *p = 0x41424344
```

### Network Byte Order

Network protocols standardize on big-endian byte order ("network byte order") for protocol fields. Systems must convert between host byte order and network byte order when sending/receiving network data.

Standard conversion functions handle this:

```c
uint32_t htonl(uint32_t hostlong);    // Host to network long (32-bit)
uint16_t htons(uint16_t hostshort);   // Host to network short (16-bit)
uint32_t ntohl(uint32_t netlong);     // Network to host long
uint16_t ntohs(uint16_t netshort);    // Network to host short
```

On little-endian systems, these functions byte-swap. On big-endian systems, they compile to no-ops since host order matches network order.

ARM provides byte-swapping instructions for efficient endianness conversion:

```asm
rev w0, w1      // Reverse bytes in 32-bit register
rev x0, x1      // Reverse bytes in 64-bit register
rev16 w0, w1    // Reverse bytes within each halfword
rev32 x0, x1    // Reverse bytes within each word (64-bit register)
```

REV swaps byte order completely. For a 32-bit value 0x12345678, REV produces 0x78563412. For network byte order conversion on little-endian systems, htonl/ntohl compile to REV instructions.

### File Formats and Serialization

File formats must specify endianness for multi-byte values. Some formats mandate specific endianness:

**Little-endian formats**: PE/COFF executables (Windows), DWARF debug info, most modern binary formats

**Big-endian formats**: Java class files, many legacy formats

**Endianness markers**: Some formats include magic numbers that appear different depending on endianness. Readers examine these markers to detect the file's endianness and adapt accordingly. For example, UTF-16 byte order marks (BOM) indicate text encoding direction.

**Endianness-neutral formats**: Text-based formats (JSON, XML, CSV) avoid endianness issues by representing numbers as character sequences. Protocol Buffers and similar serialization libraries handle endianness conversion automatically.

### Structure and Union Interpretation

Endianness affects structure member interpretation in mixed-type contexts:

```c
union EndianTest {
    uint32_t word;
    uint8_t bytes[4];
};

union EndianTest test;
test.word = 0x12345678;

// Little-endian:
// bytes[0] = 0x78, bytes[1] = 0x56, bytes[2] = 0x34, bytes[3] = 0x12

// Big-endian:
// bytes[0] = 0x12, bytes[1] = 0x34, bytes[2] = 0x56, bytes[3] = 0x78
```

Code relying on specific byte orderings within unions or accessing structures through different pointer types creates endianness dependencies. [Inference: Portable code should avoid assuming specific byte orderings within multi-byte types accessed through unions or type-punned pointers.]

### Bit Fields and Endianness

Bit field layout within integers exhibits compiler-dependent and endianness-dependent behavior:

```c
struct BitField {
    unsigned int a : 4;
    unsigned int b : 4;
    unsigned int c : 8;
};
```

The ordering of bit fields within the underlying integer varies by compiler and endianness. [Unverified: Specific bit field layout depends on compiler implementation and may not follow predictable endianness-based rules.] Portable code avoids relying on bit field memory layout, using bit fields only for in-memory access through the defined structure type.

### Detecting Endianness at Runtime

Code can detect system endianness at runtime:

```c
int is_little_endian(void) {
    uint16_t value = 0x0001;
    uint8_t *byte_ptr = (uint8_t *)&value;
    return byte_ptr[0] == 0x01;  // True if little-endian
}
```

This checks whether the least significant byte occupies the lowest address. Compilers often optimize this into constant folding, eliminating runtime checks.

Preprocessor defines may indicate endianness:

```c
#ifdef __BYTE_ORDER__
#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
    // Little-endian code
#elif __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
    // Big-endian code
#endif
#endif
```

### Mixed-Endian Systems

Some ARM configurations support mixed-endian operation where different exception levels or software contexts operate in different endianness modes. The E0E bit enables big-endian user-space applications on little-endian kernels.

[Unverified: Mixed-endian support varies by operating system and requires careful system software implementation.] System calls crossing endianness boundaries must convert pointer arguments and data structures between endianness representations.

### Performance Implications

Little-endian matches the natural byte ordering of modern peripherals and memory systems. [Inference: This alignment contributed to little-endian becoming the dominant choice for ARM systems, though no inherent performance advantage exists at the processor instruction level.] Big-endian systems require byte swapping when interfacing with little-endian devices or protocols, incurring REV instruction overhead.

**Key Points:**
- Stack grows downward (toward lower addresses) with SP pointing to the last occupied location; AArch64 requires 16-byte alignment at function call boundaries
- Static memory divides into .text (code), .rodata (constants), .data (initialized globals), .bss (zero-initialized globals), and TLS (thread-local) sections accessed via PC-relative addressing
- Heap provides dynamic allocation through system allocators that request memory from the OS and subdivide it, with implementations balancing fragmentation, performance, and metadata overhead
- ARM data types require natural alignment (N-byte data on N-byte boundaries) for optimal performance; misalignment handling is configurable with potential performance penalties or faults
- Little-endian (LSB at lowest address) predominates in ARM systems; big-endian support exists but mainly for specialized applications requiring network protocol compatibility
- REV family instructions provide efficient byte-swapping for endianness conversion, compiling to no-ops on systems where host order matches required order

**Important related topics**: Function calling conventions and parameter passing, dynamic linking and GOT/PLT mechanics, page table management and virtual memory translation, cache architecture and coherency protocols, SIMD memory access patterns and alignment requirements, atomics and memory ordering for concurrent programming, executable file formats (ELF structure), stack unwinding mechanisms for exception handling.

---

