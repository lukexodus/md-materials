## Embedded System Architectures


### Overview

Embedded systems are computing systems designed to perform dedicated functions within a larger mechanical or electronic system, subject to constraints — on power, cost, physical size, real-time responsiveness, or all four simultaneously — that general-purpose computing architectures are not optimized for. The architectural decisions that define an embedded system follow directly from these constraints: what processing resources are needed, how memory is organized, how peripherals are integrated, and how the system responds to the physical world in bounded time.

The field spans an enormous range — from an 8-bit microcontroller managing a toothbrush timer to a heterogeneous SoC running a real-time operating system alongside Linux in an automotive ECU. What unifies them is the principle of **co-design**: hardware and software are specified together for a fixed application domain, rather than the hardware being designed to run arbitrary software.

---

### Architectural Taxonomy

Embedded processors are classified along three dimensions: the width of their data path, their memory architecture, and their degree of integration.

**By datapath width:**

- **8-bit microcontrollers** (AVR, PIC baseline, Intel MCS-51): 8-bit ALU, 8-bit registers, program counters from 12 to 22 bits. Optimized for minimal silicon area and sub-milliwatt operation. Suited to simple control loops, sensor reading, and LED/motor drive.
- **16-bit microcontrollers** (MSP430, PIC24, dsPIC): 16-bit ALU; the dsPIC family adds a hardware MAC unit and modified Harvard architecture for DSP workloads. MSP430 is the archetype of ultra-low-power design — sub-microamp standby current.
- **32-bit microcontrollers** (ARM Cortex-M series, RISC-V, RL78, RX): dominant in modern embedded design. Sufficient address space for complex firmware, RTOS support, and peripheral integration without discrete memory chips in most applications.
- **64-bit application processors** (ARM Cortex-A, RISC-V application class, MIPS): used when the embedded application requires an OS (Linux, Android), virtual memory, or processing workloads that exceed 32-bit address space. Found in automotive infotainment, industrial HMIs, and consumer electronics.

**By memory architecture:**

The Von Neumann vs. Harvard distinction is foundational. Both remain relevant across the taxonomy.

- **Von Neumann:** Single address space for instructions and data; shared bus. Simpler memory management; flexible; allows self-modifying code (relevant for bootloaders and over-the-air update mechanisms). Most 32-bit and 64-bit embedded processors use modified Von Neumann with caches.
- **Harvard:** Physically separate instruction and data memory, with separate buses. Allows simultaneous instruction fetch and data access — important on cores without caches. Classic 8-bit MCUs (AVR, PIC) use strict Harvard architecture; the program memory is often Flash, the data memory SRAM.
- **Modified Harvard:** Separate caches backed by a unified physical memory. The Cortex-M3/M4/M7 use this — the Instruction TCM and Data TCM are Harvard at the local level, but the external memory interface is shared.

---

### The Microcontroller Unit (MCU)

The MCU is the canonical embedded building block. It integrates CPU core, Flash (program memory), SRAM (data memory), and peripheral controllers on a single die. No external memory chips are required for most applications.

**Core peripheral set present in virtually all MCUs:**

- **GPIO (General-Purpose I/O):** Digital input/output pins configurable at runtime; each pin has direction register, output data register, input data register, and often alternate-function multiplexing for peripheral signals.
- **Timers/Counters:** 16-bit or 32-bit count registers with prescalers, compare/capture registers. Used for PWM generation, input capture (measuring pulse widths), output compare (generating periodic events), and watchdog timer functions.
- **UART/USART:** Asynchronous serial communication; the lowest common denominator for debugging output (via a USB-UART bridge) and communication with GPS modules, Bluetooth modules, etc.
- **SPI and I²C:** As covered in Module 10 — the dominant short-range peripheral buses.
- **ADC (Analog-to-Digital Converter):** Samples analog voltages (0–V~REF~) and produces a digital code (typically 10–16 bit resolution). Successive approximation register (SAR) ADCs are standard; Σ-Δ ADCs appear where high resolution at low sample rates is needed.
- **DAC (Digital-to-Analog Converter):** Present on higher-end MCUs; produces analog output for audio or reference voltage generation.
- **DMA controller:** Moves data between memory and peripherals without CPU involvement; essential for high-throughput ADC, SPI Flash, and USB transactions.
- **Interrupt controller (NVIC on Cortex-M):** Manages prioritized interrupt requests from all peripheral sources. Cortex-M's NVIC supports up to 240 external interrupt lines with 256 priority levels and tail-chaining (back-to-back ISR dispatch without full context restore/save between them).

**The ARM Cortex-M family** is the dominant 32-bit MCU core architecture. The family spans a wide capability range while maintaining binary compatibility:

|Core|Pipeline|ISA features|Typical use|
|---|---|---|---|
|Cortex-M0/M0+|2–3 stage in-order|Thumb-2 subset|Ultra-low-power, cost-sensitive|
|Cortex-M3|3-stage in-order|Full Thumb-2, hardware divide|General-purpose control|
|Cortex-M4|3-stage in-order|M3 + SIMD, FPU (single-precision)|DSP, motor control, audio|
|Cortex-M7|6-stage dual-issue in-order|M4 + double-precision FPU, TCM, L1 cache|High-performance embedded|
|Cortex-M33|3-stage|M4 equivalent + TrustZone|Secure IoT, PSA-certified|
|Cortex-M85|Longer, out-of-order capable|Helium (M-profile SIMD)|ML inference at the edge|

**Memory map on Cortex-M:** The 4 GB address space is architecturally partitioned — Code region (0x00000000), SRAM (0x20000000), Peripheral registers (0x40000000), External RAM (0x60000000), External device (0xA0000000), Private Peripheral Bus / system control (0xE0000000). Peripheral registers are memory-mapped; accessing a GPIO output register is a store to a specific address, not a special instruction.

---

### Memory Architecture in Embedded Systems

Memory organization is often the most constrained resource and the primary driver of architectural decisions.

**Flash (NOR):** The dominant program storage medium. NOR Flash allows random-read at byte granularity (execute-in-place, XIP), but erases only in sectors (typically 2–64 KB) and programs in pages (64–256 bytes). Write endurance is limited to 10,000–100,000 erase cycles — a relevant constraint for systems that update firmware frequently or use Flash as data logging storage.

Dual-bank Flash (found on STM32H7, RP2040's XIP interface, etc.) allows one bank to be read/executed while the other is being erased/programmed — enabling live firmware updates without halting execution.

**SRAM:** Zero wait-state random read/write; limited in size by on-die area cost. Typical on-chip SRAM ranges from 2 KB (low-end 8-bit MCUs) to 1 MB (Cortex-M7 devices). SRAM is volatile — contents lost on power loss.

**EEPROM:** Byte-addressable non-volatile storage; very low endurance (100,000–1,000,000 cycles) and small capacity. Used for configuration parameters, calibration constants, and wear-leveled data logging. Many modern MCUs emulate EEPROM semantics in Flash using software wear-leveling layers.

**External memory interfaces:** When on-chip memory is insufficient, dedicated interfaces expand the space:

- **FSMC / FMC (Flexible Memory Controller):** Common on STM32 and similar MCUs; interfaces SRAM, NOR Flash, NAND Flash, SDRAM via a parallel bus. SDRAM access requires configuration of timing parameters (CAS latency, RAS-to-CAS delay) matching the DRAM device.
- **QSPI / OctoSPI:** Serial NOR Flash at 80–200 MB/s effective throughput via memory-mapped XIP. The RP2040, ESP32-S3, and STM32H7 all use this for external program storage.
- **HyperBus / HyperRAM:** Single 8-bit differential serial interface providing pseudo-SRAM semantics; eliminates the large parallel address/data bus of FSMC at the cost of higher latency. Used in space-constrained IoT designs.

**TCM (Tightly Coupled Memory):** On Cortex-M7 and Cortex-A application processors, TCM is a small SRAM (64–512 KB) with a dedicated bus directly to the CPU core — access is always single-cycle regardless of bus activity. Interrupt handlers, real-time control loops, and DMA buffers are placed in ITCM/DTCM for deterministic latency. Code running from cache has non-deterministic latency (cache miss penalty); code in TCM does not.

---

### Real-Time Constraints

The defining characteristic separating embedded systems from general computing is the **real-time requirement**: the system must respond to external events within a bounded, predictable time. Failure to meet timing is as incorrect as producing a wrong result.

**Hard real-time:** Missing a deadline is a system failure. Automotive airbag deployment (must fire within ~1 ms of collision detection), industrial motor control (PWM period must be updated every 10 µs), and cardiac pacemaker timing are canonical examples.

**Soft real-time:** Missing a deadline degrades quality but is not catastrophic. Video decoding (a dropped frame is a glitch, not a failure), network packet processing, and audio playback.

**Firm real-time:** Missing a deadline renders the result useless but does not cause system failure. A weather measurement that arrives too late to feed the control loop is simply discarded.

**Worst-Case Execution Time (WCET) analysis** is the discipline of bounding the maximum time any code path can take. It requires:

- No unbounded loops or recursion.
- No dynamic memory allocation (heap allocation time is non-deterministic in general-purpose allocators).
- Deterministic memory access latency (hence preference for TCM over cache in hard real-time code paths).
- Interrupt latency analysis: the NVIC on Cortex-M guarantees a deterministic interrupt entry latency (12 cycles for FPU context push on M4), but the time for the CPU to finish the current instruction before accepting the interrupt must also be bounded.

**Interrupt latency** on Cortex-M has the following contributors: current instruction completion (at most a few cycles for most instructions; long-latency instructions like `STMDB` may take up to 12 cycles), interrupt entry overhead (pushing 8 registers: xPSR, PC, LR, R12, R3–R0 — 12 cycles minimum, with FPU lazy stacking up to ~14 cycles additional), and vector fetch (1–2 cycles from ITCM/ICache).

The total guaranteed interrupt entry latency on Cortex-M4 is ≤ 15 cycles (without FPU state) from IRQ assertion to first instruction of the ISR — a deterministic bound not available on superscalar OOO cores.

---

### Power Architecture

Power is the primary physical constraint in battery-operated embedded systems. Architectures are designed around power states, not peak performance.

**Power consumption model:**

Dynamic power: `P_dynamic = α · C · V² · f`

where α is the activity factor (fraction of capacitances switching per cycle), C is the total switched capacitance, V is the supply voltage, and f is the clock frequency. This gives the two primary levers: **voltage scaling** and **clock gating**.

Static (leakage) power: `P_static = I_leak · V`

At sub-threshold voltages (some ultra-low-power MCUs operate at 0.5–0.9 V), leakage current is reduced, but dynamic power does not scale as favorably.

**Power states in a typical ARM Cortex-M MCU:**

|State|Clock|Core|SRAM|Peripherals|Current (typical)|
|---|---|---|---|---|---|
|Run|On|Active|Powered|Active|1–10 mA|
|Sleep|CPU stopped; peripherals clocked|Halted|Powered|Active|0.5–5 mA|
|Deep sleep|All clocks off|Halted|Powered|Stopped|1–100 µA|
|Standby|RTC only|Halted|Off|Off|0.1–2 µA|
|Shutdown|Nothing|Off|Off|Off|<100 nA|

The system wakes from Sleep on any interrupt. It wakes from Deep Sleep only on selected wakeup sources (RTC alarm, external interrupt, comparator). From Standby/Shutdown, a full reset sequence occurs.

**Event-driven architecture** (run-to-completion model): Rather than polling or running a continuous loop, the system spends the vast majority of time in deep sleep. An interrupt or scheduled wakeup triggers a handler that performs the necessary computation, queues results, and returns to sleep. The duty cycle of active computation can be 0.01–1% in a low-power sensor node.

**MSP430 ultra-low-power philosophy:** The MSP430 architecture was designed so that the overhead of waking, performing an ADC sample, and returning to sleep is small enough that a 3 V coin cell can power a sensing node for years. The CPU can wake in under 1 µs, execute an ISR, and return to LPM4 (1 µA) before significant charge has been drawn.

---

### System-on-Chip (SoC) Architecture

As embedded applications grow in complexity, single-core MCUs with simple peripheral sets become insufficient. System-on-Chip designs integrate heterogeneous processing elements, dedicated hardware accelerators, and complex interconnects on a single die.

The diagram below shows the internal organization of a representative embedded SoC.**Bus hierarchy rationale:** The AXI (Advanced eXtensible Interface) backbone carries high-bandwidth traffic — CPU instruction fetch, DMA bursts, accelerator data transfers — at full core clock speeds. The APB (Advanced Peripheral Bus) runs at a divided clock (typically 1/4 to 1/2 the AXI frequency) and is accessed through a bridge. Low-speed peripherals (UART, I²C, timers, ADC) sit on APB because their register interfaces are narrow and their data rates are low; putting them on the AXI backbone would waste bus bandwidth and complicate timing.

**AMBA protocol family (ARM):** The de facto standard for on-chip bus interconnects in ARM-based SoCs. AHB (Advanced High-performance Bus) is an older single-channel variant; AXI4 introduced separate read and write channels, out-of-order transaction IDs, and burst support. AXI4-Lite is a simplified subset (no bursts, no out-of-order) used for register-mapped accelerator control interfaces. AXI4-Stream is a unidirectional data stream variant used for DSP and video pipelines.

---

### Heterogeneous Multiprocessor SoC

High-capability embedded systems — automotive, industrial, and advanced IoT — deploy multiple heterogeneous processing elements on the same SoC to serve fundamentally different workload characters.

**Automotive example (representative of TI TDA4VM, NXP S32G class):**

- **Cortex-A72 cluster (application cores):** Runs Linux, AUTOSAR Adaptive Platform, and high-level perception algorithms. Cache-coherent, virtual memory, full OS scheduler.
- **Cortex-R5F cluster (real-time cores):** Runs AUTOSAR Classic or a bare-metal RTOS. No virtual memory; deterministic interrupt latency; TCRAM for guaranteed execution timing. Controls safety-critical actuators.
- **C7x DSP / MMA (matrix multiply accelerator):** Executes neural network inference for object detection and lane recognition.
- **Safety island (Cortex-M4F):** Lockstep pair executing identical instructions; comparator detects divergence and asserts a safe-state output. Implements ISO 26262 ASIL-D redundancy.
- **ICSSG (Industrial Communications Subsystem with PRU):** Programmable real-time units executing custom Ethernet protocols (EtherCAT, PROFINET) with sub-microsecond timing.

**Asymmetric multiprocessing (AMP):** Each core runs its own OS or bare-metal firmware independently. Communication between cores via shared memory regions and hardware mailboxes (inter-processor interrupts, IPIs). The cores are not cache-coherent with each other — the software must manage cache flush/invalidate explicitly when passing buffers between cores. This is the dominant model in embedded heterogeneous SoCs.

**Symmetric multiprocessing (SMP):** Multiple identical cores sharing a single OS instance, a unified virtual address space, and a cache-coherent interconnect (CCI or CCN on ARM). Used in application-class embedded processors (i.MX8, Snapdragon for embedded). Requires hardware cache coherency (MESI protocol across cores) — not available in MCU-class processors.

---

### Memory Protection and Safety

**MPU (Memory Protection Unit):** Present on all Cortex-M3 and later devices. Configures up to 8 or 16 regions with base address, size (power-of-two), and access permissions (privileged/unprivileged read/write/execute). Violations generate a hard fault or MemManage fault. The MPU does not provide virtual memory — it is purely a protection mechanism with a flat physical address space.

**MMU (Memory Management Unit):** Present on Cortex-A and RISC-V application-class processors. Translates virtual to physical addresses using a page table hierarchy (2-level on Armv7-A, 4-level on Armv8-A), enabling OS-enforced process isolation, demand paging, and the full POSIX process model.

**Lockstep execution:** Two identical processor cores execute the same instruction stream simultaneously. Their outputs are compared by a hardware comparator every cycle. Any divergence (caused by a transient radiation-induced bit flip, or a permanent silicon fault) is detected immediately and can trigger a safe-state response. Used in safety-critical automotive and industrial processors to achieve IEC 61508 SIL-3 / ISO 26262 ASIL-D requirements. The performance cost is 50% of raw throughput; the reliability gain is a latent fault detection coverage above 90%.

**Functional safety standards:** Embedded architectures targeting safety-critical markets must comply with domain-specific standards. ISO 26262 (automotive), IEC 61508 (industrial), DO-178C (avionics), and IEC 62443 (industrial cybersecurity) each impose requirements on hardware redundancy, software testing rigor, and failure mode analysis that directly shape architecture choices.

---

### RTOS and Bare-Metal Execution Models

**Bare-metal (superloop):** The simplest execution model. A single `while(1)` loop polls peripheral status registers and executes state-machine logic. Interrupts may be used for time-critical events. Suitable for simple single-function devices; latency of response to events depends on polling frequency and is not tightly bounded for lower-priority events.

```c
while (1) {
    if (ADC_ready())  process_sample();
    if (UART_rx())    parse_command();
    if (button_pressed()) trigger_action();
    update_outputs();
}
```

**RTOS (Real-Time Operating System):** Provides a kernel with:

- **Preemptive priority-based scheduler:** A higher-priority task preempts a lower-priority task immediately when it becomes ready. Guarantees that the highest-priority ready task always runs within a bounded time (scheduler latency).
- **Tasks/threads:** Independent execution contexts, each with its own stack. The RTOS saves and restores context (registers, PC, SP) on task switches.
- **Synchronization primitives:** Semaphores, mutexes (with priority inheritance to prevent priority inversion), event flags, message queues.
- **Timers:** Software timers (resolution = RTOS tick period, typically 1 ms) and hardware-timer-backed high-resolution timers.

Common embedded RTOSes: **FreeRTOS** (dominant in MCU space; Apache 2.0 licensed; ported to Cortex-M, RISC-V, Xtensa), **Zephyr** (Linux Foundation; strong hardware support; native networking), **ThreadX / Azure RTOS** (Microsoft; safety-certified versions available), **RTEMS** (aerospace/defense; POSIX-compliant), **µC/OS-III** (commercial; DO-178C and IEC 62443 certified).

**Priority inversion and the Mars Pathfinder incident:** In 1997, the Mars Pathfinder lander experienced repeated system resets caused by priority inversion. A low-priority meteorological task holding a shared mutex was preempted by a medium-priority task, blocking a high-priority bus management task. The watchdog timer, observing the high-priority task not completing within its deadline, reset the system. The fix — enabling priority inheritance on the mutex — was patched and uplinked from Earth. This remains the canonical real-world case study for priority inversion in embedded RTOS design.

---

### Bootloader Architecture and Startup Sequence

**Reset vector and startup code:** On Cortex-M, the reset vector table begins at address 0x00000000 (or a remapped address). The first two entries are the initial Main Stack Pointer value and the Reset_Handler address. On power-on or reset, the CPU loads SP from offset 0 and branches to Reset_Handler. Startup code initializes the `.data` section (copying initialized variables from Flash to SRAM), zeros the `.bss` section, calls constructors (C++), and then calls `main()`.

**Bootloader stages:**

1. **ROM bootloader (immutable):** Baked into mask ROM at fabrication. Validates and loads the next stage from Flash, external SPI, UART, USB DFU, or SD card depending on boot pin configuration. Implements the most basic security anchor — often supports RSA signature verification of the next stage using a public key burned into one-time-programmable (OTP) fuses.
    
2. **First-stage bootloader (FSBL):** Loaded by ROM bootloader. Initializes DDR/SDRAM timing, PLL configuration, and board-specific hardware. On complex SoCs (i.MX, AM6x), the FSBL is provided by the vendor (U-Boot SPL, TI SysConfig).
    
3. **Second-stage bootloader (SSBL / U-Boot):** Loads the OS kernel image, applies device tree overlays, and passes control to the kernel entry point. Provides a shell for development and recovery.
    
4. **Kernel / RTOS / bare-metal application.**
    

**Secure boot:** OTP fuses store a hash of the trusted public key. The ROM bootloader computes a SHA-256 hash of the FSBL, verifies it against the stored public key hash, and rejects execution if the signature is invalid. This establishes a **hardware root of trust** that chains upward — each stage verifies the next before launching it. Corruption or replacement of firmware at any stage is detected before execution. [This is the architectural mechanism; the security guarantees of specific implementations are not universally verified across all vendors.]

---

### Key Differentiating Design Decisions

The principal embedded architecture decisions and their implications:

**Harvard vs. modified Harvard:** Strict Harvard (AVR, PIC) maximizes throughput on small in-order pipelines but complicates self-modifying firmware and XIP from Flash. Modified Harvard (Cortex-M) provides the bus bandwidth benefit of separate instruction/data paths while allowing the linker to treat memory as a single flat space.

**Cache vs. TCM:** Caches improve average-case performance on memory-bound workloads but introduce non-deterministic latency (cache miss penalty). TCM gives single-cycle deterministic access but is fixed in size. Hard real-time systems place ISRs and control loops in TCM; general-purpose firmware runs from cache.

**DMA vs. CPU-driven transfers:** DMA frees the CPU from byte-by-byte polling/interruption during bulk transfers (ADC samples to SRAM, SPI Flash reads, UART transmit). DMA-driven transfers require careful cache coherency management on cores with data caches — the CPU must flush its write-back D-cache entries before a DMA read, and invalidate them before reading DMA-written data.

**MPU vs. MMU:** MPU provides coarse protection with no address translation — suitable for RTOS-based embedded where tasks share a physical address space and the overhead of a full MMU is unnecessary. MMU is required for full OS isolation, virtual addressing, and POSIX process semantics. The choice determines whether Linux can run on the processor.

**Bare-metal vs. RTOS vs. Linux:** The trade-off is determinism vs. ecosystem. Bare-metal offers the tightest latency and smallest footprint. RTOS adds task isolation, priority scheduling, and middleware support at the cost of a few KB of RAM and scheduler latency overhead (typically <10 µs on Cortex-M at 168 MHz). Linux adds a rich driver ecosystem, TCP/IP, filesystems, and dynamic memory at the cost of millisecond-class latency and megabytes of RAM — unsuitable for hard real-time control but appropriate for the application processing layer of a heterogeneous SoC.

---

**Next Steps:** The most directly adjacent topics are **BIOS/UEFI and boot sequence** (which extends the bootloader architecture discussion to the PC/server domain and the full UEFI PI specification), **interrupt controllers** (the NVIC on Cortex-M and the GIC on Cortex-A are architecturally detailed topics that underpin everything discussed about real-time response), and **fault tolerance and redundancy** (lockstep, ECC memory, and watchdog mechanisms are central to automotive and industrial embedded design).

---

