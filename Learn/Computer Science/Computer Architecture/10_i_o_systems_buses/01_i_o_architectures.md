## I/O Architectures


I/O architecture defines how a processor communicates with peripheral devices — determining who initiates transfers, who manages them, and how the CPU is involved throughout.

---

### Core I/O Methods

There are three fundamental methods for handling I/O, each representing a different trade-off between CPU utilization and transfer efficiency.

**Programmed I/O (Polling)**

The CPU directly controls every aspect of a transfer. It continuously reads a status register on the device controller in a tight loop — _polling_ — until the device signals readiness, then transfers data one unit at a time.

```
while (status_register != READY) { /* busy-wait */ }
data_register = next_byte;
```

The CPU is entirely occupied during this process. No other work can be performed while waiting. This wastes cycles on any device slower than the CPU, which is essentially all of them.

**Interrupt-Driven I/O**

The CPU initiates a transfer and then resumes other work. When the device completes the requested operation, it asserts an interrupt line. The CPU suspends its current instruction stream, saves state, and vectors to an interrupt service routine (ISR) that handles the data transfer. After the ISR returns, the CPU restores state and resumes the interrupted task.

This eliminates busy-waiting but introduces interrupt-handling overhead: context save/restore, ISR execution, and return. For high-throughput devices (e.g., gigabit NICs), the ISR fires so frequently that interrupt overhead dominates — a phenomenon called _interrupt storm_ or _livelock_.

**Direct Memory Access (DMA)**

A dedicated DMA controller assumes responsibility for the actual data movement. The CPU programs the DMA controller with a source address, destination address, transfer count, and direction, then issues a start command. The DMA controller moves data directly between device and memory over the system bus, independent of the CPU. When the transfer completes, the DMA controller issues a single interrupt.

The CPU is involved only at the start and end of a potentially large transfer — not for every byte or word. DMA dramatically reduces CPU overhead for bulk transfers.---

### DMA Architecture in Depth

A DMA controller exposes a set of registers to the CPU: a memory address register, a device address or I/O port register, a word count register, and a control/status register. The CPU writes these fields and sets the start bit. The DMA controller then takes control of the system bus and issues read/write cycles on behalf of the device.

**Cycle stealing** is a common DMA mode: the DMA controller takes one bus cycle at a time from the CPU to transfer one word, then releases the bus. This interleaves DMA transfers with CPU memory accesses, reducing peak latency at the cost of lower DMA throughput. In **burst mode**, the DMA controller holds the bus for the entire transfer — maximizing throughput but stalling the CPU for the duration.

**Bus mastering** extends this concept. High-performance peripherals (PCIe devices, for example) are themselves bus masters: they can initiate DMA transactions independently, bypassing a central DMA controller entirely. The device's internal DMA engine reads/writes main memory directly using physical addresses after being granted bus arbitration.

**IOMMU** (I/O Memory Management Unit) intercepts DMA transactions and translates device-visible addresses to physical memory addresses, enforcing protection domains. Without an IOMMU, a compromised or buggy peripheral with DMA capability can overwrite arbitrary memory. With an IOMMU, each device operates within a bounded address space.

---

### I/O Port Addressing

Two models exist for mapping devices into the CPU's address space.

**Port-mapped I/O (PMIO)** maintains a separate I/O address space, accessed via dedicated instructions (`IN`/`OUT` on x86). The 16-bit x86 I/O port space supports 65,536 ports. The hardware distinguishes memory accesses from I/O accesses via a dedicated M/IO# signal on the bus.

**Memory-mapped I/O (MMIO)** assigns device registers to ranges within the physical memory address space. The CPU accesses them with ordinary load/store instructions. The memory controller routes accesses to these ranges to the device rather than to DRAM. MMIO is simpler to program, avoids special instructions, and is the dominant model in modern systems (ARM exclusively uses MMIO; x86 uses both).

**Key trade-off:** PMIO conserves the physical address space and provides implicit hardware protection (user-mode processes cannot issue privileged `IN`/`OUT` instructions without ring 0). MMIO is architecturally simpler and required on architectures lacking dedicated I/O instructions.

---

### I/O Software Layers

I/O architecture is not hardware alone. It is organized as a stack of abstraction layers, each with a defined responsibility.

```
┌──────────────────────────────────┐
│     User-space I/O library       │   fopen(), read(), write()
├──────────────────────────────────┤
│     Virtual file system (VFS)    │   unified interface over all FS types
├──────────────────────────────────┤
│     Device-independent OS layer  │   buffering, error reporting, scheduling
├──────────────────────────────────┤
│     Device driver                │   device-specific register sequences
├──────────────────────────────────┤
│     Interrupt handlers           │   ISR dispatch, bottom halves
├──────────────────────────────────┤
│     Hardware (controller + bus)  │
└──────────────────────────────────┘
```

Each layer communicates only with adjacent layers. A device driver translates the OS-generic `read` call into the specific sequence of register writes required by one particular controller. The interrupt handler is kept minimal — it acknowledges the interrupt, records that work is pending, and defers processing to a _bottom half_ (Linux tasklet/softirq/workqueue) to avoid blocking other interrupts.

---

### Interrupt Handling in Detail

When a device asserts an interrupt:

1. The CPU completes the current instruction (or a safe boundary in pipelined/OOO implementations).
2. Hardware saves the program counter and processor status to the stack or a dedicated register.
3. The interrupt vector table (IVT) or interrupt descriptor table (IDT) is indexed by the interrupt number to obtain the ISR address.
4. The CPU branches to the ISR.
5. The ISR saves additional registers (those it will modify), services the device, acknowledges the interrupt controller, restores registers, and executes a return-from-interrupt instruction (`IRET` on x86).
6. The CPU restores PC and status, resuming the interrupted context.

**Interrupt prioritization:** A programmable interrupt controller (PIC, or APIC in modern x86 systems) arbitrates among simultaneous interrupt sources and assigns priority levels. A higher-priority interrupt can preempt an ISR handling a lower-priority one — _nested interrupts_. The end-of-interrupt (EOI) signal must be sent to the PIC to allow further interrupts from that priority level.

**Interrupt latency** is the time from device assertion to first ISR instruction execution. It is bounded by: instruction completion time + state save + IVT lookup + branch prediction flush. Real-time systems require deterministic bounds on this value.

---

### Buffering and Spooling

The OS mediates the speed mismatch between fast CPUs and slow devices through buffering.

**Single buffering:** The OS allocates one buffer in kernel memory. Data is transferred from device to buffer; the application then copies from buffer to user space. The device must wait while the application consumes the buffer.

**Double buffering:** Two buffers alternate. While the application processes buffer A, the device fills buffer B — pipelining device and CPU activity.

**Circular (ring) buffering:** A fixed array of buffer slots with producer and consumer indices. Used in network I/O and audio, where continuous streaming is required. The producer (DMA/device) writes to the tail; the consumer (CPU/application) reads from the head.

**Spooling** (Simultaneous Peripheral Operations On-Line): A dedicated process mediates access to a device that cannot multiplex (e.g., a printer). Jobs write to a spool directory on disk; the spooler serializes them to the device.

---

### I/O Scheduling

Multiple outstanding I/O requests must be ordered for efficiency. For block storage:

**FCFS** services requests in arrival order — simple but can cause excessive seek movement on HDDs.

**SCAN / Elevator:** The head sweeps in one direction, servicing all requests in that direction, then reverses. Predictable maximum wait time.

**C-SCAN (Circular SCAN):** Services requests on one sweep only; returns to the start without servicing on the way back. More uniform wait times.

**Deadline / CFQ (Completely Fair Queuing):** Used in Linux; assigns deadlines to requests to bound latency for reads (which block processes) while still batching writes for throughput.

For SSDs, seek time is negligible and scheduling primarily optimizes command queue depth (NCQ/NVMe queue depth) and read/write mixing rather than physical position.

---

### Channel I/O (Mainframe Architecture)

Mainframe systems introduce a dedicated I/O processor called a **channel**. The CPU submits a _channel program_ — a sequence of channel command words (CCWs) describing a complex multi-step I/O operation — and the channel executes the program autonomously. The CPU is interrupted only upon channel program completion or error. This generalizes DMA to programmable, sequential I/O operations with no CPU involvement between steps, enabling sustained high-throughput I/O on many devices concurrently. Modern analogues include NVMe's submission/completion queue model and GPU command buffers.

---

### Comparison Table

|Property|Programmed I/O|Interrupt-Driven|DMA|Channel I/O|
|---|---|---|---|---|
|CPU involvement|Entire transfer|Initiate + ISR|Initiate + final ISR|Program submission only|
|Granularity|Per byte/word|Per byte/word|Per buffer|Per channel program|
|Suitable for|Very fast or simple devices|Medium-speed devices|High-throughput bulk|Mainframe, many parallel devices|
|Latency|Low (no overhead)|Medium|Medium + setup|High setup, low CPU load|
|Implementation cost|Trivial|Low|Requires DMA controller|Requires channel processor|

---

**Key Points**

- Programmed I/O wastes CPU cycles in a polling loop and is only appropriate for devices where transfer latency is bounded and short.
- Interrupt-driven I/O frees the CPU during device operation but incurs per-transfer ISR overhead; this overhead becomes the bottleneck on high-throughput devices.
- DMA transfers move data autonomously between device and memory, with the CPU interrupted once per buffer, not once per unit.
- MMIO and PMIO are the two addressing models for device registers; MMIO dominates modern non-x86 architectures.
- The IOMMU enforces address-space isolation for DMA-capable devices, preventing unauthorized memory access.
- The I/O software stack — hardware, ISR, driver, OS I/O layer, VFS, userspace — isolates device specifics behind uniform interfaces.
- I/O scheduling policies trade fairness, latency, and throughput; optimal choice depends on device characteristics (HDD seek time vs. SSD random access).

**Conclusion**

I/O architecture is fundamentally concerned with the allocation of CPU time across the transfer lifecycle. Each successive method — programmed, interrupt-driven, DMA, channel — removes the CPU from progressively more of that lifecycle, freeing it for computation at the cost of additional hardware mechanism. Modern systems combine all three: simple status polls for fast in-CPU peripherals, interrupts for human-speed devices, and DMA (often via PCIe bus mastering with IOMMU oversight) for all bulk data movement.

**Next Steps**

From the syllabus: **Bus arbitration** and **modern interconnects (PCIe, USB, I²C, SPI)** extend this material by examining how multiple devices contend for the shared bus used by DMA and MMIO — and how PCIe's point-to-point switched fabric replaces shared-bus arbitration entirely.

---

