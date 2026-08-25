## I/O Transfer Mechanisms


Three fundamental strategies exist for transferring data between the CPU and peripherals: programmed I/O, interrupt-driven I/O, and DMA. Each represents a different answer to the same question — who is responsible for orchestrating the transfer, and when?

---

### Programmed I/O (Polling)

The CPU drives every aspect of the transfer. It executes a tight loop, continuously querying the device status register until the device signals readiness, then performs the data transfer itself.

**Mechanism**: The CPU issues a command to the device controller, then enters a busy-wait loop, reading the device's status register on each iteration. When the status register indicates the device is ready (either data available for input or buffer empty for output), the CPU reads or writes one unit of data (byte or word) directly, then either returns to the polling loop for the next unit or completes the transfer.

```
loop:
    IN  AL, STATUS_PORT     ; read device status register
    TEST AL, READY_BIT      ; test ready flag
    JZ  loop                ; not ready → poll again
    IN  AL, DATA_PORT       ; ready → read data
    MOV [buffer+offset], AL ; store to memory
    INC offset
    CMP offset, count
    JL  loop
```

**Key Points**:

- CPU utilization during I/O is 100% — no other work is done while polling.
- No interrupt hardware required; simplest possible implementation.
- Deterministic and predictable timing; no interrupt latency.
- Appropriate for devices that respond within a few CPU cycles, or in bare-metal/embedded contexts where interrupt overhead is unacceptable.
- Transfer granularity is typically one byte or word per loop iteration.

**Performance characteristic**: If a device takes $T_{device}$ time to become ready and the CPU polls every $T_{poll}$ cycles, the CPU wastes $T_{device}/T_{poll}$ poll iterations spinning before any useful work is done.

---

### Interrupt-Driven I/O

The CPU initiates a transfer, then resumes other work. The device signals completion (or readiness) via a hardware interrupt, at which point the CPU suspends its current task, services the interrupt by transferring one unit of data, then resumes.

**Mechanism**:

1. CPU writes a command to the device controller.
2. CPU continues executing the current or next process (scheduler can dispatch another task).
3. When the device is ready, it asserts an interrupt request (IRQ) line.
4. The CPU completes the current instruction, saves its architectural state (PC, registers, PSW) to the stack or interrupt frame, and vectors to the interrupt service routine (ISR) via the interrupt vector table.
5. The ISR transfers one unit of data (byte or word) between the device data register and memory, then executes IRET (or equivalent) to restore state.
6. For block transfers: the ISR re-arms the device for the next unit and returns; the process repeats until the buffer is exhausted.

**Interrupt acknowledgment cycle** (x86, using 8259A PIC):

- CPU asserts INTA̅ (interrupt acknowledge) twice; the PIC places the interrupt vector on the data bus.
- ISR reads/writes the device register, then sends EOI (end-of-interrupt) to the PIC.

**Key Points**:

- CPU is free between interrupts to execute other instructions.
- One interrupt per byte/word transferred — high overhead for large block transfers. For a 4 KB sector from a disk, interrupt-driven I/O would generate 4,096 interrupts for byte-granularity transfers.
- Context-save/restore cost at each interrupt can be 50–1000 cycles depending on architecture depth (register windows, FPU state, etc.).
- ISRs must be short and non-blocking; no page faults, no blocking calls.
- Appropriate for low-bandwidth devices: keyboards, serial ports, human-interface peripherals.

**Interrupt latency** comprises: IRQ-to-CPU recognition time + state-save cycles + vector fetch + ISR entry. Modern processors guarantee maximum latency bounds only when interrupts are not disabled for extended periods.

---

The two diagrams below show the CPU timeline under each strategy for a 4-unit transfer.---

### Direct Memory Access (DMA)

DMA removes the CPU from the transfer loop entirely for bulk data movement. A dedicated hardware controller — the DMA controller (DMAC) — takes ownership of the system bus and transfers data directly between a device and memory, interrupting the CPU only once per block (or per significant event) rather than once per byte.

**Mechanism**:

1. CPU programs the DMAC by writing to its registers: source address (device or memory), destination address (memory), transfer count, transfer width, and direction (device→memory or memory→device).
2. CPU issues a start command and resumes execution.
3. The DMAC issues bus requests (BR) to the CPU. When the CPU grants the bus (BG), the DMAC performs a bus cycle: it places the memory address on the address bus, asserts the appropriate bus signals, and reads or writes one transfer unit (typically a word or cache line) from/to the device.
4. The DMAC decrements its internal counter and increments the address pointer, then releases the bus back to the CPU.
5. Steps 3–4 repeat, stealing bus cycles from the CPU, until the counter reaches zero.
6. At transfer completion, the DMAC asserts an IRQ. The CPU executes one short ISR to check status and release resources.

**Cycle stealing vs. burst mode**:

|Mode|Bus behavior|
|---|---|
|Cycle stealing|DMAC takes one bus cycle per unit, interleaved with CPU cycles|
|Burst|DMAC holds the bus for the entire transfer; CPU stalls completely|
|Transparent|DMAC transfers only during CPU cycles that don't use the bus|

**Key Points**:

- CPU overhead: one interrupt at the end of the entire block, plus DMAC programming cost at the start.
- The CPU still executes during cycle-stealing transfers; it experiences bus contention but is not blocked.
- Burst mode is faster for throughput but stalls the CPU for the full transfer duration — acceptable for memory-to-memory moves, undesirable for real-time tasks.
- DMAC hardware includes address registers, count registers, control registers, and bus arbitration logic.
- Modern implementations: PCIe DMA engines, IOMMU-mediated DMA (which remaps DMAC-generated addresses through a translation layer to prevent errant or malicious DMAs from accessing arbitrary physical memory).

**Address generation**: DMAC maintains a current-address register incremented (or decremented) after each bus cycle. Scatter-gather DMA extends this with a descriptor chain in memory — each descriptor specifies a (address, count) pair, enabling non-contiguous buffer filling without CPU re-programming between segments.

---

### Comparative Analysis

|Property|Programmed I/O|Interrupt-driven|DMA|
|---|---|---|---|
|CPU involvement|Continuous (all cycles)|Per byte/word (ISR)|Once per block (setup + completion)|
|Interrupt count per block transfer|0 (no interrupts)|N (one per unit)|1|
|CPU utilization for I/O|100% (busy-wait)|Low (between interrupts)|Minimal|
|Transfer rate|Limited by polling loop|Limited by ISR cost|Limited by bus bandwidth|
|Latency to first byte|Zero|ISR entry latency|DMAC programming latency|
|Complexity|Minimal|Moderate|High (DMAC hardware + driver)|
|Suitability|Fast low-latency devices, embedded|Low-bandwidth HID peripherals|High-bandwidth bulk: disk, NIC, GPU|

**CPU bus bandwidth impact under DMA**: In cycle-stealing mode, each DMA bus cycle displaces one CPU memory access. If the DMAC steals $f_{steal}$ fraction of bus cycles, CPU-executable instruction bandwidth is reduced by approximately that fraction. The CPU does not stall but executes more slowly. This is measured as the _DMA penalty_ and depends on DMAC cycle frequency versus CPU memory request frequency.

**IOMMU and security**: In systems with an IOMMU (Intel VT-d, AMD-Vi, ARM SMMU), each DMAC-capable device is assigned an I/O page table. Physical addresses generated by the DMAC are translated through this table before reaching the memory controller. A compromised or misconfigured DMA-capable device cannot access memory outside its allocated I/O virtual address range. Without an IOMMU, any DMAC-capable device that can be programmed by an attacker represents a full physical memory read/write primitive — a well-known class of hardware attack.

**Scatter-gather descriptor chain** (structure used by all modern DMA engines):

```c
struct dma_descriptor {
    uint64_t src_addr;     /* physical source address */
    uint64_t dst_addr;     /* physical destination address */
    uint32_t byte_count;
    uint32_t control;      /* flags: interrupt, end-of-chain, etc. */
    uint64_t next;         /* pointer to next descriptor, or NULL */
};
```

The DMAC fetches the head descriptor from memory, processes it, fetches the next descriptor via `next`, and continues until `next` is NULL or the end-of-chain flag is set. This allows a single DMAC invocation to fill or drain a non-contiguous buffer (e.g., a socket receive ring).

---

**Conclusion**: The three mechanisms define a spectrum of CPU involvement. Programmed I/O trades CPU time for simplicity and zero-latency response. Interrupt-driven I/O returns CPU cycles to other work but generates per-unit interrupt overhead that becomes prohibitive for bulk transfers. DMA amortizes the CPU cost across entire blocks, scaling to bus-speed data rates, at the cost of DMAC hardware, address management, and IOMMU-level memory protection. Modern systems deploy all three simultaneously: DMA for disk, network, and GPU transfers; interrupt-driven for keyboards and serial ports; programmed I/O for ultra-low-latency sensor polling in embedded or real-time contexts.

---

