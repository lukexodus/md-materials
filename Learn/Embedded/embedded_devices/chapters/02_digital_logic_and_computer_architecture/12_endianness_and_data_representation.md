## Endianness and Data Representation


### Overview

Endianness defines the order in which bytes of a multi-byte value are arranged in memory or transmitted over a communication channel. Because most modern data types (integers, floating point, addresses) occupy more than one byte, and memory is fundamentally addressed a byte at a time, a convention is required to determine which byte is "first." This topic was introduced briefly under Instruction Set Architectures Overview; here it is treated in depth, alongside broader binary data representation concerns relevant to embedded firmware — bit ordering, alignment, and cross-system data interchange.

### The Core Concept

Consider the 32-bit hexadecimal value $\text{0x12345678}$ stored starting at memory address $\text{0x1000}$. The value occupies four consecutive byte addresses, but the *order* in which the four bytes ($\text{0x12}$, $\text{0x34}$, $\text{0x56}$, $\text{0x78}$) are placed into those addresses depends entirely on the endianness convention in use.

### Little-Endian

In little-endian ordering, the **least significant byte (LSB)** is stored at the **lowest memory address**.

| Address | 0x1000 | 0x1001 | 0x1002 | 0x1003 |
| --- | --- | --- | --- | --- |
| Byte value | 0x78 | 0x56 | 0x34 | 0x12 |

**Key Points**

- Used by x86/x86-64, most ARM configurations (default), and most RISC-V implementations
- A useful mnemonic: the byte address matches the byte's numeric "weight" order, smallest weight (LSB) at the smallest address
- Simplifies certain low-level operations: casting a pointer to a smaller type (e.g., reading a 32-bit value as a 16-bit or 8-bit value) naturally yields the low-order portion of the value without any address offset adjustment

### Big-Endian

In big-endian ordering, the **most significant byte (MSB)** is stored at the **lowest memory address**.

| Address | 0x1000 | 0x1001 | 0x1002 | 0x1003 |
| --- | --- | --- | --- | --- |
| Byte value | 0x12 | 0x34 | 0x56 | 0x78 |

**Key Points**

- Historically used by many older architectures (original Motorola 68k, classic PowerPC in its default mode, SPARC)
- Matches the natural left-to-right reading order humans use for writing numbers, which can aid manual memory-dump debugging
- Network protocols conventionally specify big-endian byte order for multi-byte header fields — commonly referred to as **network byte order** — regardless of the host system's native endianness

### Visual Comparison

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 260" font-family="monospace" font-size="13">
<text x="320" y="20" text-anchor="middle" font-size="15" font-weight="bold">Little-Endian vs Big-Endian Storage (svg_diagram)</text>

<text x="60" y="55" font-size="13" font-weight="bold">Little-Endian</text>

<g stroke="black" stroke-width="1.5" fill="`#f0f0f0`">

<rect x="60" y="65" width="60" height="45" />

<rect x="120" y="65" width="60" height="45" />

<rect x="180" y="65" width="60" height="45" />

<rect x="240" y="65" width="60" height="45" />

</g>

<text x="90" y="93" text-anchor="middle">0x78</text>

<text x="150" y="93" text-anchor="middle">0x56</text>

<text x="210" y="93" text-anchor="middle">0x34</text>

<text x="270" y="93" text-anchor="middle">0x12</text>

<text x="90" y="125" text-anchor="middle" font-size="11">1000</text>

<text x="150" y="125" text-anchor="middle" font-size="11">1001</text>

<text x="210" y="125" text-anchor="middle" font-size="11">1002</text>

<text x="270" y="125" text-anchor="middle" font-size="11">1003</text>

<text x="90" y="140" text-anchor="middle" font-size="10">LSB</text>

<text x="270" y="140" text-anchor="middle" font-size="10">MSB</text>

<text x="60" y="180" font-size="13" font-weight="bold">Big-Endian</text>

<g stroke="black" stroke-width="1.5" fill="`#f0f0f0`">

<rect x="60" y="190" width="60" height="45" />

<rect x="120" y="190" width="60" height="45" />

<rect x="180" y="190" width="60" height="45" />

<rect x="240" y="190" width="60" height="45" />

</g>

<text x="90" y="218" text-anchor="middle">0x12</text>

<text x="150" y="218" text-anchor="middle">0x34</text>

<text x="210" y="218" text-anchor="middle">0x56</text>

<text x="270" y="218" text-anchor="middle">0x78</text>

<text x="90" y="248" text-anchor="middle" font-size="10">MSB</text>

<text x="270" y="248" text-anchor="middle" font-size="10">LSB</text>

</svg>

### Bi-Endian and Configurable Systems

Some ISAs and implementations support **bi-endian** operation, where byte order is configurable, typically fixed at reset/boot time via a hardware pin or configuration register rather than switchable during normal operation. Several ARM cores support this mode. [Inference] Whether a specific chip's endianness is fixed, boot-configurable, or runtime-switchable depends on the exact core and vendor implementation, and must be confirmed against that part's reference manual rather than assumed from the core family.

### Endianness and Bit Ordering (Distinct Concepts)

Byte-order endianness should not be confused with **bit ordering** within a single byte or word, which is a separate concern:

- **Bit numbering convention**: whether bit 0 refers to the least significant bit (LSB0, most common) or the most significant bit (MSB0), used in documentation and register descriptions
- Serial communication protocols (UART, SPI) additionally specify **transmission bit order** — whether the least significant bit or most significant bit of each byte is transmitted first — independent of both memory endianness and bit-numbering convention

**Key Points**

- UART typically transmits LSB-first
- SPI bit order is configurable per-device (`MSBFIRST` or `LSBFIRST` in many embedded HAL/library APIs) and must match between master and slave
- These are firmware/protocol-level conventions distinct from CPU memory endianness, though confusion between the two is a common source of bugs when interfacing peripherals

### Practical Embedded Implications

#### Struct Layout and Type Punning

Reading a multi-byte value through a pointer of a different type (a practice sometimes called type punning) exposes endianness directly:

```c
#include <stdint.h>

uint32_t value = 0x12345678;
uint8_t *byte_ptr = (uint8_t *)&value;

// On little-endian systems: byte_ptr[0] == 0x78
// On big-endian systems:    byte_ptr[0] == 0x12
```

**Key Points**

- Code relying on this kind of implicit byte access is inherently non-portable across endianness
- Firmware intended to run on multiple target architectures should avoid raw byte-pointer casting for multi-byte values and instead use explicit, endianness-independent bit-shift and mask operations

#### Portable Serialization

Writing a multi-byte value to a buffer (for storage, transmission, or logging) in a defined, explicit byte order regardless of host endianness:

```c
#include <stdint.h>

void write_be32(uint8_t *buf, uint32_t value) {
    buf[0] = (uint8_t)(value >> 24);
    buf[1] = (uint8_t)(value >> 16);
    buf[2] = (uint8_t)(value >> 8);
    buf[3] = (uint8_t)(value);
}

uint32_t read_be32(const uint8_t *buf) {
    return ((uint32_t)buf[0] << 24) |
           ((uint32_t)buf[1] << 16) |
           ((uint32_t)buf[2] << 8)  |
           ((uint32_t)buf[3]);
}
```

**Key Points**

- This bit-shift approach produces identical, correct results regardless of the host CPU's native endianness, since it relies only on arithmetic bit operations rather than raw memory layout assumptions
- This pattern is the basis of standard network byte-order conversion functions (`htons`, `htonl`, `ntohs`, `ntohl` in POSIX/BSD sockets APIs, and equivalents in embedded TCP/IP stacks like lwIP)
- Many embedded communication protocols (Modbus, various sensor/IMU register interfaces, file formats) specify their own required byte order per field, which firmware must respect explicitly regardless of host CPU endianness

#### Communication Protocol Endianness Awareness

**Key Points**

- I2C and SPI multi-byte register reads on sensors/peripherals often follow a datasheet-specified byte order that may not match host CPU endianness — this must be read from the specific device's datasheet, not assumed
- File formats used in embedded contexts (e.g., WAV, BMP, many binary configuration formats) specify fixed byte orders per field that firmware parsers must respect explicitly
- Cross-platform communication between a little-endian microcontroller and a big-endian (or differently-endian) host system requires explicit conversion at the protocol boundary

### Data Alignment (Related Representation Concern)

Closely related to endianness is memory **alignment** — the requirement (varying by ISA and configuration) that multi-byte values be stored at memory addresses evenly divisible by their size (e.g., a 4-byte value at an address divisible by 4).

**Key Points**

- Many embedded cores either require aligned access (faulting on misaligned access) or incur a performance penalty for misaligned access; behavior is architecture- and configuration-specific
- ARM Cortex-M cores generally support unaligned access for most instructions by default in recent architecture versions, but this is configurable and should be verified for the specific core and use case rather than assumed [Inference — exact unaligned-access behavior and any associated performance penalty is core- and configuration-specific and should be confirmed against the target part's reference manual]
- Compilers insert padding bytes within structs to satisfy alignment requirements of individual members, which affects `sizeof(struct)` and requires care when overlaying a struct directly onto a communication buffer or memory-mapped register block
- The `packed` attribute (e.g., `__attribute__((packed))` in GCC/Clang) instructs the compiler to omit this padding, at the cost of potentially requiring unaligned access to individual members

```c
// Without packing: compiler may insert padding for alignment
struct SensorReading {
    uint8_t  status;   // 1 byte
    uint32_t value;    // 4 bytes — compiler may insert 3 padding bytes before this
};

// Packed: no padding, but may require unaligned access support
struct __attribute__((packed)) SensorReadingPacked {
    uint8_t  status;
    uint32_t value;
};
```

### Detecting Host Endianness Programmatically

```c
#include <stdint.h>
#include <stdio.h>

int is_little_endian(void) {
    uint16_t test = 0x0001;
    return *((uint8_t *)&test) == 0x01;
}

int main(void) {
    printf("System is %s-endian\n", is_little_endian() ? "little" : "big");
    return 0;
}
```

This runtime check works by examining the actual first byte in memory of a known multi-byte value, rather than relying on compile-time architecture assumptions — useful in portable code bases that may target multiple embedded architectures.

### Endianness Comparison Summary

| Attribute | Little-Endian | Big-Endian |
| --- | --- | --- |
| Byte at lowest address | Least significant | Most significant |
| Common architectures | x86, most ARM/RISC-V configs | Classic 68k, PowerPC (default), SPARC |
| Network protocol convention | N/A (must convert) | Standard ("network byte order") |
| Manual hex-dump readability | Less intuitive | More intuitive (matches written number order) |
| Pointer type-punning to smaller type | Yields low-order bits directly | Yields high-order bits directly |

**Related Topics**

- Instruction Set Architectures Overview
- CPU Architecture Basics
- Memory Hierarchy Fundamentals
- Communication Protocols (UART, SPI, I2C) Bit and Byte Ordering
- Struct Packing, Alignment, and Memory-Mapped Register Overlays
- Network Byte Order and Socket Programming Conventions
- Binary File Format Parsing in Embedded Firmware
- Cross-Platform Firmware Portability Considerations