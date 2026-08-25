## Memory-Mapped I/O


Memory-mapped I/O (MMIO) is an addressing scheme in which device registers and device memory are assigned addresses within the same address space used for RAM. The processor communicates with peripherals by issuing ordinary load and store instructions to these addresses — no separate I/O instructions or I/O address space are required.

---

### The Two I/O Addressing Models

Before MMIO can be understood precisely, it must be contrasted with the alternative:

<svg viewBox="0 0 680 310" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect width="680" height="310" fill="#0d1117" rx="8"/> <text x="340" y="26" text-anchor="middle" fill="#c9d1d9" font-size="13" font-weight="bold">Port-Mapped I/O vs. Memory-Mapped I/O</text> <!-- PMIO side -->

<text x="170" y="52" text-anchor="middle" fill="#58a6ff" font-size="12" font-weight="bold">Port-Mapped I/O (PMIO)</text>

<rect x="30" y="65" width="130" height="30" rx="4" fill="#1a2332" stroke="#3b6ea5" stroke-width="1.3"/> <text x="95" y="85" text-anchor="middle" fill="#c9d1d9" font-size="10">Memory Address Space</text> <rect x="30" y="105" width="130" height="30" rx="4" fill="#1a2332" stroke="#f78166" stroke-width="1.3"/> <text x="95" y="125" text-anchor="middle" fill="#f78166" font-size="10">I/O Address Space</text> <rect x="190" y="65" width="110" height="70" rx="4" fill="#1a2332" stroke="#3b6ea5" stroke-width="1.3"/> <text x="245" y="90" text-anchor="middle" fill="#8b949e" font-size="10">CPU</text> <text x="245" y="106" text-anchor="middle" fill="#8b949e" font-size="9">MOV / LOAD</text> <text x="245" y="118" text-anchor="middle" fill="#f78166" font-size="9">IN / OUT</text> <line x1="160" y1="80" x2="189" y2="88" stroke="#3b6ea5" stroke-width="1.2" marker-end="url(#ma)"/> <line x1="160" y1="120" x2="189" y2="112" stroke="#f78166" stroke-width="1.2" marker-end="url(#ma)"/>

<text x="170" y="165" text-anchor="middle" fill="#8b949e" font-size="9">Separate address buses.</text> <text x="170" y="178" text-anchor="middle" fill="#8b949e" font-size="9">Dedicated IN/OUT instructions.</text> <text x="170" y="191" text-anchor="middle" fill="#8b949e" font-size="9">x86 supports up to 65,536 ports.</text> <text x="170" y="210" text-anchor="middle" fill="#f78166" font-size="9">Requires privilege (ring 0 or IOPL).</text> <text x="170" y="223" text-anchor="middle" fill="#f78166" font-size="9">Not available on ARM, RISC-V, MIPS.</text>

<!-- Divider --> <line x1="340" y1="45" x2="340" y2="290" stroke="#30363d" stroke-width="1" stroke-dasharray="4,3"/> <!-- MMIO side -->

<text x="510" y="52" text-anchor="middle" fill="#3fb950" font-size="12" font-weight="bold">Memory-Mapped I/O (MMIO)</text>

<rect x="370" y="65" width="280" height="130" rx="4" fill="#1a2332" stroke="#3b6ea5" stroke-width="1.3"/> <text x="510" y="85" text-anchor="middle" fill="#c9d1d9" font-size="10">Unified Address Space</text> <rect x="382" y="95" width="120" height="22" rx="3" fill="#1a3d28" stroke="#3fb950" stroke-width="1"/> <text x="442" y="110" text-anchor="middle" fill="#3fb950" font-size="9">0x00000000 RAM</text> <rect x="382" y="123" width="120" height="22" rx="3" fill="#1a3d28" stroke="#3fb950" stroke-width="1"/> <text x="442" y="138" text-anchor="middle" fill="#3fb950" font-size="9">0x40000000 RAM</text> <rect x="382" y="151" width="120" height="22" rx="3" fill="#2d1f3a" stroke="#e6c07b" stroke-width="1.2"/> <text x="442" y="166" text-anchor="middle" fill="#e6c07b" font-size="9">0xFEC00000 DEVICE</text> <rect x="516" y="95" width="120" height="78" rx="3" fill="#1a2332" stroke="#3b6ea5" stroke-width="1.2"/> <text x="576" y="115" text-anchor="middle" fill="#8b949e" font-size="10">CPU</text> <text x="576" y="132" text-anchor="middle" fill="#3fb950" font-size="9">LOAD / STORE</text> <text x="576" y="148" text-anchor="middle" fill="#3fb950" font-size="9">(same instrs)</text> <text x="576" y="164" text-anchor="middle" fill="#8b949e" font-size="9">to any addr</text> <line x1="502" y1="162" x2="515" y2="155" stroke="#e6c07b" stroke-width="1.2" marker-end="url(#mb)"/> <line x1="502" y1="106" x2="515" y2="120" stroke="#3fb950" stroke-width="1.2" marker-end="url(#mb)"/>

<text x="510" y="225" text-anchor="middle" fill="#8b949e" font-size="9">One address space, one bus.</text> <text x="510" y="238" text-anchor="middle" fill="#8b949e" font-size="9">Ordinary LD/ST instructions.</text> <text x="510" y="251" text-anchor="middle" fill="#3fb950" font-size="9">Universal: ARM, RISC-V, x86, MIPS.</text> <text x="510" y="264" text-anchor="middle" fill="#3fb950" font-size="9">Address decoding routes to RAM or device.</text>

<defs> <marker id="ma" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#3b6ea5"/> </marker> <marker id="mb" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#3fb950"/> </marker> </defs> </svg>

|Property|Port-Mapped I/O|Memory-Mapped I/O|
|---|---|---|
|Address space|Separate I/O space|Unified with RAM|
|Instructions|`IN`/`OUT` (x86-specific)|`LDR`/`STR`, `MOV`, `LD`/`SD`|
|ISA support|x86 only|Universal|
|Address range|16-bit (65,536 ports)|Full address space width|
|Privilege|Requires `IOPL` or ring 0|Controlled by MMU page attributes|
|Caching|Never cached|Must be explicitly marked non-cacheable|

x86 retains both models for historical compatibility. ARM, RISC-V, and MIPS support MMIO exclusively.

---

### Address Space Layout

In a typical 32-bit embedded or SoC system, the address space is partitioned by the hardware designer:

```
0x00000000 – 0x1FFFFFFF   Flash / ROM (executable code)
0x20000000 – 0x3FFFFFFF   SRAM
0x40000000 – 0x5FFFFFFF   APB peripherals (UART, SPI, I²C, timers)
0x60000000 – 0x9FFFFFFF   External RAM (SDRAM)
0xA0000000 – 0xDFFFFFFF   External device bus
0xE0000000 – 0xFFFFFFFF   System control (NVIC, SysTick, debug — Cortex-M)
```

This is the ARM Cortex-M memory map. The specific addresses are fixed by the silicon vendor. Peripheral registers at `0x40000000` and above are accessed with the same `LDR`/`STR` instructions used to access SRAM.

**Example — ARM Cortex-M UART transmit:**

```c
#define UART0_BASE   0x4000C000UL
#define UART0_DR     (*(volatile uint32_t *)(UART0_BASE + 0x000))  // Data register
#define UART0_FR     (*(volatile uint32_t *)(UART0_BASE + 0x018))  // Flag register
#define UART_FR_TXFF (1u << 5)                                      // TX FIFO full

void uart_send(char c) {
    while (UART0_FR & UART_FR_TXFF);  // spin until TX FIFO not full
    UART0_DR = c;                      // write byte to device register
}
```

The write to `UART0_DR` compiles to a single `STR` instruction. The memory bus routes this store to the UART peripheral, not to RAM.

---

### Hardware Mechanism: Address Decoding

The system bus uses address decoding logic to route each transaction to the correct target. The decoder examines the upper address bits:

<svg viewBox="0 0 660 280" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect width="660" height="280" fill="#0d1117" rx="8"/> <text x="330" y="24" text-anchor="middle" fill="#c9d1d9" font-size="13" font-weight="bold">Address Decoding on the System Bus</text> <!-- CPU --> <rect x="20" y="100" width="80" height="80" rx="5" fill="#1a2332" stroke="#58a6ff" stroke-width="1.5"/> <text x="60" y="136" text-anchor="middle" fill="#58a6ff" font-size="11" font-weight="bold">CPU</text> <text x="60" y="152" text-anchor="middle" fill="#8b949e" font-size="9">issues LOAD</text> <text x="60" y="164" text-anchor="middle" fill="#8b949e" font-size="9">or STORE</text> <!-- Bus --> <rect x="120" y="128" width="180" height="24" rx="3" fill="#1a2d1a" stroke="#3fb950" stroke-width="1.2"/> <text x="210" y="144" text-anchor="middle" fill="#3fb950" font-size="10">Address + Data Bus</text> <!-- Arrow CPU → Bus --> <line x1="100" y1="140" x2="119" y2="140" stroke="#3fb950" stroke-width="1.3" marker-end="url(#mc)"/> <!-- Decoder --> <polygon points="300,110 300,170 340,185 340,95" fill="#1e2d3a" stroke="#e6c07b" stroke-width="1.5"/> <text x="312" y="142" fill="#e6c07b" font-size="9">Addr</text> <text x="312" y="154" fill="#e6c07b" font-size="9">Dec</text> <!-- Bus → Decoder --> <line x1="300" y1="140" x2="300" y2="140" stroke="#3fb950" stroke-width="1.3"/> <!-- Decoder → RAM --> <line x1="340" y1="108" x2="400" y2="80" stroke="#3b6ea5" stroke-width="1.2" marker-end="url(#md)"/> <rect x="400" y="55" width="90" height="50" rx="4" fill="#1a2332" stroke="#3b6ea5" stroke-width="1.3"/> <text x="445" y="78" text-anchor="middle" fill="#79b8ff" font-size="10">RAM</text> <text x="445" y="92" text-anchor="middle" fill="#6e7681" font-size="9">0x0000–0x3FFF</text> <!-- Decoder → GPU/PCIe --> <line x1="341" y1="138" x2="400" y2="140" stroke="#e6c07b" stroke-width="1.2" marker-end="url(#me)"/> <rect x="400" y="115" width="90" height="50" rx="4" fill="#2d2416" stroke="#e6c07b" stroke-width="1.3"/> <text x="445" y="138" text-anchor="middle" fill="#e6c07b" font-size="10">PCIe Dev</text> <text x="445" y="152" text-anchor="middle" fill="#6e7681" font-size="9">0x4000–0x7FFF</text> <!-- Decoder → UART --> <line x1="340" y1="168" x2="400" y2="200" stroke="#f78166" stroke-width="1.2" marker-end="url(#mf)"/> <rect x="400" y="175" width="90" height="50" rx="4" fill="#2d1f1f" stroke="#f78166" stroke-width="1.3"/> <text x="445" y="198" text-anchor="middle" fill="#f78166" font-size="10">UART</text> <text x="445" y="212" text-anchor="middle" fill="#6e7681" font-size="9">0x8000–0x8FFF</text> <!-- Devices → System bus note -->

<text x="510" y="78" fill="#8b949e" font-size="9">→ responds with</text> <text x="510" y="90" fill="#8b949e" font-size="9"> read data</text> <text x="510" y="140" fill="#8b949e" font-size="9">→ DMA, framebuf</text> <text x="510" y="200" fill="#8b949e" font-size="9">→ TX/RX register</text>

<!-- Address bits label -->

<text x="210" y="112" text-anchor="middle" fill="#8b949e" font-size="9">addr[31:12] selects target</text> <text x="210" y="123" text-anchor="middle" fill="#8b949e" font-size="9">addr[11:0] selects register</text>

<defs> <marker id="mc" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#3fb950"/> </marker> <marker id="md" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#3b6ea5"/> </marker> <marker id="me" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#e6c07b"/> </marker> <marker id="mf" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#f78166"/> </marker> </defs> </svg>

The decoder asserts a chip-select line to exactly one target per transaction. RAM responds with data from its array. A peripheral responds with the contents of a hardware register or ignores the address if it is invalid.

---

### Device Register Types

MMIO peripherals expose their functionality through a small set of registers at fixed offsets from a base address. Register semantics differ from RAM in fundamental ways:

|Register Type|Read Behavior|Write Behavior|Example|
|---|---|---|---|
|Control|Returns current config|Configures device|UART baud rate, enable bits|
|Status|Returns device state|Often read-only or no effect|TX ready, RX overflow flag|
|Data (TX)|Undefined / last write|Sends data to device|UART transmit FIFO|
|Data (RX)|Consumes one item|Often no effect|UART receive FIFO — reading removes byte|
|Clear-on-read|Clears flag upon read|No effect|Interrupt status register|
|Write-to-clear|No effect|Writing 1 clears the bit|Interrupt flag clear|
|FIFO|Pops next item|Pushes item|DMA buffer, audio sample buffer|

**Reading a status register can change device state.** This is categorically different from RAM reads and has direct implications for debugging — a debugger that reads a clear-on-read status register to observe it has consumed the event being observed.

---

### The `volatile` Requirement

The C/C++ `volatile` qualifier is mandatory for MMIO register access. Without it, the compiler may eliminate, reorder, or coalesce memory accesses that it infers are redundant:

```c
// WITHOUT volatile — compiler may optimize away the loop
uint32_t *status = (uint32_t *)0x40001018;
while (*status & 0x20);   // compiler sees: value never changes in this thread
                           // may hoist read out of loop or eliminate entirely

// WITH volatile — every access is emitted as a memory instruction
volatile uint32_t *status = (volatile uint32_t *)0x40001018;
while (*status & 0x20);   // compiler re-reads on every iteration
```

`volatile` instructs the compiler that:

1. Every read must generate a load instruction (no caching in a register)
2. Every write must generate a store instruction (no write merging)
3. Accesses must not be reordered relative to other `volatile` accesses
4. Reads and writes may not be eliminated regardless of apparent redundancy

`volatile` does not provide memory ordering guarantees between cores. On multicore systems, memory barriers (`dmb`, `dsb` on ARM; `mfence` on x86; `fence` on RISC-V) are required in addition to `volatile`.

---

### Caching and Memory Attributes

MMIO regions must be marked **non-cacheable** in the MMU or MPU page table. Caching MMIO produces incorrect behavior:

```
Problem scenario (if MMIO were cacheable):

  CPU writes 0x01 to GPIO_OUT register → stored in cache, not forwarded to device
  Device sees no change                → LED does not turn on
  CPU reads GPIO_OUT → returns 0x01 from cache → no indication of failure
  Cache eviction eventually writes 0x01 to device → behavior is delayed and wrong
```

**For read side:**

```
  Device UART RX FIFO has new byte → device register contains 0x41 ('A')
  CPU reads UART_DR → cache returns stale 0x00 from previous read
  New byte is never consumed        → receive overrun
```

#### Page Table / MPU Memory Type Attributes

|Memory Type|Cacheable|Bufferable|Typical Use|
|---|---|---|---|
|Normal (WB)|Yes|Yes|RAM|
|Normal (WT)|Yes (reads)|No|ROM|
|Device|No|Yes|MMIO peripherals|
|Strongly Ordered|No|No|Ordering-critical registers|

On ARM, the `Device` and `Strongly Ordered` memory types additionally constrain instruction reordering in the memory subsystem, not just the compiler. This matters for register sequences where order of access is architecturally significant (e.g., clearing an interrupt flag before re-enabling interrupts).

---

### Read-Modify-Write Hazard

MMIO control registers are frequently shared between multiple bit fields. A read-modify-write sequence on a shared register is non-atomic:

```c
// Enabling bit 3 of a GPIO direction register
// Shared with other fields set by other drivers or interrupt handlers

uint32_t val = GPIO_DIR;   // read
val |= (1u << 3);          // modify
GPIO_DIR = val;            // write

// Between read and write:
//   An ISR could modify GPIO_DIR for a different pin
//   The write above would overwrite the ISR's change → race condition
```

Solutions:

- **Atomic set/clear registers:** Many peripherals provide separate `SET` and `CLR` registers that affect only the bits written, eliminating read-modify-write entirely (e.g., ARM GPIO `BSRR` register).
- **Disable interrupts** around the read-modify-write sequence.
- **Hardware bit-band region** (Cortex-M3/M4): a region where each word address maps to a single bit in the peripheral space, enabling atomic single-bit access.

---

### MMIO in Device Driver Architecture

A device driver abstracts MMIO register access behind a hardware abstraction layer:

```
Application
    │
    ▼
Kernel driver API   (open, read, write, ioctl)
    │
    ▼
HAL / register abstraction
    │  read_reg(base, offset)
    │  write_reg(base, offset, val)
    ▼
volatile pointer dereference
    │  *(volatile uint32_t *)(base + offset) = val
    ▼
MMU (marks region Device / non-cacheable)
    │
    ▼
System bus → Address decoder → Peripheral register
```

In Linux, MMIO regions are mapped into kernel virtual address space using `ioremap()`, which establishes a non-cacheable mapping. Drivers then use `readl()`/`writel()` accessors which wrap the volatile dereference and include any required memory barriers for the target architecture.

---

### DMA and MMIO Interaction

Direct Memory Access (DMA) controllers are themselves MMIO devices. Configuring a DMA transfer means writing MMIO registers:

```c
// Configure DMA channel for UART TX (simplified)
DMA_SRC_ADDR  = (uint32_t)tx_buffer;     // source: RAM buffer
DMA_DST_ADDR  = UART0_BASE + 0x000;      // destination: UART data register (MMIO)
DMA_COUNT     = length;                   // number of bytes
DMA_CONTROL   = DMA_SRC_INC             // source address increments
              | DMA_DST_FIXED           // destination is fixed (register)
              | DMA_ENABLE;             // start transfer
```

The DMA controller then generates bus transactions directly — bypassing the CPU — transferring bytes from RAM to the UART peripheral register. The DMA controller itself is accessed via MMIO; the transfer destination is also an MMIO address. Both addresses live in the same unified address space.

---

### MMIO in x86: APIC and PCIe

On x86 systems, MMIO is pervasive at the system level:

#### Local APIC

The Advanced Programmable Interrupt Controller is MMIO-mapped at a configurable base address (default `0xFEE00000`):

```
0xFEE00020  Local APIC ID register
0xFEE00080  Task Priority Register (TPR)
0xFEE00300  Interrupt Command Register low (ICR_LO) — send IPI
0xFEE00310  Interrupt Command Register high (ICR_HI)
0xFEE000B0  EOI register — write 0 to signal end-of-interrupt
```

Writing `0` to the EOI register (`0xFEE000B0`) after handling an interrupt is a mandatory MMIO write for each interrupt serviced.

#### PCIe BAR (Base Address Register)

Each PCIe device exposes one or more memory regions via BARs, which the OS programs during enumeration:

```
BIOS/OS reads PCIe config space → finds BAR requesting 16 MB
OS assigns physical address range 0xF0000000–0xF0FFFFFF
OS writes base address into BAR register
Driver maps 0xF0000000 via ioremap()
Driver accesses device registers at 0xF0000000 + offset
```

PCIe BARs are the mechanism by which GPU framebuffers, NIC descriptor rings, and NVMe submission queues appear in the CPU's address space.

---

### Alignment and Access Width Constraints

MMIO registers frequently impose stricter access constraints than RAM:

```
Rule (device-specific — varies by peripheral):
  32-bit register → must be accessed as a 32-bit word (LDR/STR, not LDRB)
  Writing two 16-bit halves separately may trigger two separate device actions
  Byte access to a 32-bit control register is undefined on many peripherals
```

**Example violation:**

```c
volatile uint32_t *ctrl = (volatile uint32_t *)0x40010000;

// CORRECT: single 32-bit write
*ctrl = 0x00000001;

// POTENTIALLY INCORRECT: compiler may decompose into byte stores
memcpy((void *)0x40010000, &value, 4);  // do not use memcpy for MMIO
```

`memcpy` has no obligation to use word-sized accesses. The compiler may generate `STRB` (store byte) instructions. Always access MMIO through a correctly sized `volatile` pointer.

---

### MMIO vs. DMA: When Each Is Used

|Criterion|MMIO Access|DMA Transfer|
|---|---|---|
|Transfer size|Small (register reads/writes)|Large (buffers, blocks)|
|CPU involvement|Required per access|Setup only; transfer is autonomous|
|Latency|Immediate|Setup overhead + transfer time|
|Use case|Status polling, config, control|Network packets, disk blocks, audio|
|Interrupt|Not inherent|Completion interrupt typical|

MMIO and DMA are complementary: DMA controllers are configured via MMIO; DMA transfers move bulk data between RAM and MMIO device regions without CPU involvement.

---

**Key Points**

- MMIO places device registers in the same address space as RAM; ordinary load/store instructions access them.
- Address decoding logic on the system bus routes each transaction to the correct target (RAM or peripheral) based on upper address bits.
- Device registers are not RAM: reads may consume data or clear flags; writes may trigger device actions immediately.
- `volatile` is mandatory; without it, the compiler may eliminate or reorder device accesses. `volatile` alone does not provide multicore memory ordering.
- MMIO regions must be marked non-cacheable in the MMU/MPU; caching MMIO produces stale reads and delayed writes.
- Read-modify-write on shared registers is non-atomic; use set/clear register pairs or disable interrupts to avoid races.
- PCIe BARs, the Local APIC, GPU framebuffers, and NVMe queues are all accessed through MMIO on modern x86 systems.

**Conclusion** Memory-mapped I/O is the architectural foundation of peripheral communication on virtually every modern processor outside of legacy x86 port I/O. Its elegance lies in reducing device access to the same load/store model used for all memory — at the cost of requiring the programmer to understand that these addresses behave differently from RAM in caching, ordering, access width, and side-effect semantics. Every device driver, embedded firmware component, and OS kernel that interacts with hardware depends on correct MMIO access patterns.

**Next Steps** Proceed to _Programmed I/O, Interrupt-Driven I/O, and DMA_ to examine the three models for managing data transfer between CPU and peripherals, or to _Bus Architectures_ to see how the system bus that carries MMIO transactions is structured and arbitrated.

---

