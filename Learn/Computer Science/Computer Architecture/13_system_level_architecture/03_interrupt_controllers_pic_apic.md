## Interrupt Controllers (PIC, APIC)


An interrupt controller is the hardware intermediary between peripheral devices and the CPU. Devices assert electrical signals when they need attention; the interrupt controller arbitrates among them, assigns priorities, encodes the interrupt number, and delivers it to the appropriate CPU core. Without this layer, the CPU would need dedicated input lines for every device, and multi-processor interrupt routing would be architecturally intractable.

---

### The 8259A Programmable Interrupt Controller (PIC)

The Intel 8259A, introduced in 1976, was the standard interrupt controller for the x86 PC platform for over two decades. The original IBM PC used a single 8259A supporting eight interrupt request lines (IRQ0–IRQ7). The IBM AT extended this to sixteen lines by cascading two 8259As: a _master_ and a _slave_. The slave's output (INT) is wired to IRQ2 of the master, so IRQ8–IRQ15 are delivered as IRQ2 to the master, which then forwards to the CPU.**8259A interrupt sequence** (a precise description of what happens on each IRQ assertion):

1. A device asserts one of the IRQn lines high.
2. The 8259A records this in its _Interrupt Request Register_ (IRR).
3. The priority resolver compares pending IRQs against the _In-Service Register_ (ISR) — which tracks interrupts currently being serviced — and the _Interrupt Mask Register_ (IMR), which masks disabled IRQs. If the unmasked pending IRQ has higher priority than what is currently in service, it asserts INT to the CPU.
4. The CPU completes its current instruction and checks the IF (interrupt flag). If set, it asserts INTA (interrupt acknowledge).
5. On the first INTA pulse, the 8259A freezes its state. On the second INTA pulse, it places the _interrupt vector_ (a byte programmed during initialization via ICW2) onto the data bus. The CPU reads this byte and indexes the Interrupt Descriptor Table to find the ISR address.
6. The 8259A sets the corresponding bit in the ISR, clearing the IRR bit.
7. After the CPU's ISR executes, it writes the _End of Interrupt_ (EOI) command to the 8259A. In non-specific EOI mode this clears the highest-priority ISR bit; in specific EOI mode it clears a named bit.

**Priority:** By default IRQ0 has the highest priority and IRQ7 the lowest. The 8259A supports priority rotation (useful for fairness) by reprogramming the priority order, though most OS drivers leave it fixed.

**Initialization Command Words (ICWs):** The 8259A is programmed at boot with a sequence of up to four ICWs written to its I/O ports (0x20/0x21 for master, 0xA0/0xA1 for slave). ICW1 triggers the initialization sequence; ICW2 sets the base interrupt vector; ICW3 identifies the cascade configuration; ICW4 sets the operating mode (8086 vs 8080, auto-EOI, etc.).

**Limitations of the 8259A:**

- Supports at most 16 IRQ lines (with cascading); modern systems have hundreds of interrupt sources.
- Assumes a uniprocessor: it can only deliver interrupts to one CPU. In an SMP system it cannot route interrupts to specific cores or balance load.
- Fixed-vector routing: all IRQs from one 8259A are contiguous in the vector space, with no per-IRQ control.
- Requires explicit EOI from software; missing an EOI stalls all lower-priority interrupts indefinitely.

These limitations motivated the APIC.

---

### The Advanced Programmable Interrupt Controller (APIC)

The APIC architecture, introduced with the Pentium, addresses all limitations of the 8259A by splitting interrupt handling into two components: a **Local APIC** on each CPU and an **I/O APIC** on the chipset. These communicate over a dedicated _APIC bus_ (later superseded by the system bus or a message-signaled mechanism).#### Local APIC

Every CPU core contains a Local APIC, accessible via a memory-mapped register block (default physical base `0xFEE00000`, relocatable via the `IA32_APIC_BASE` MSR). Key registers:

**Task Priority Register (TPR):** Holds the current priority threshold of the CPU. The Local APIC suppresses delivery of any interrupt whose priority class is ≤ TPR. This allows OS code to mask a range of interrupts simply by writing TPR, without touching individual IMR bits.

**Interrupt Request Register (IRR) and In-Service Register (ISR):** Each is a 256-bit bitmap. The IRR records pending interrupts awaiting delivery to the CPU core. When the CPU accepts an interrupt, the bit moves from IRR to ISR. The ISR bit is cleared when the OS writes EOI.

**Local Vector Table (LVT):** Configures local interrupt sources — sources that don't come through the I/O APIC but are internal to the CPU package: APIC timer, thermal sensor, performance monitoring counters, LINT0 and LINT1 (legacy pins for 8259A passthrough and NMI). Each LVT entry specifies vector number, delivery mode, polarity, trigger mode, and mask bit.

**APIC Timer:** The Local APIC contains a programmable countdown timer that fires a local interrupt at a configured period. It is per-core (not shared), making it the standard source for per-CPU periodic timer ticks in multi-core OS schedulers.

**Spurious Interrupt Vector Register (SVR):** The APIC can generate a _spurious interrupt_ if the CPU acknowledges an interrupt that was already retracted by the device. The SVR defines which vector is delivered in this case (typically the highest vector, `0xFF`). The spurious ISR does nothing and does not send EOI.

#### I/O APIC

The I/O APIC sits on the chipset (or is part of the PCH) and receives device IRQ lines. It contains a **Redirection Table** with one entry per input pin (typically 24 entries, expandable to 240). Each _Redirection Table Entry_ (RTE) is a 64-bit register specifying:

|Field|Meaning|
|---|---|
|Vector [7:0]|Interrupt vector number delivered to CPU|
|Delivery mode [10:8]|Fixed, lowest-priority, SMI, NMI, INIT, ExtINT|
|Destination mode [11]|Physical (APIC ID) or logical (cluster/flat mask)|
|Delivery status [12]|Idle or send-pending (read-only)|
|Polarity [13]|Active-high or active-low|
|Remote IRR [14]|Set when level-triggered IRQ is in-service; cleared by EOI|
|Trigger mode [15]|Edge or level|
|Mask [16]|1 = masked|
|Destination [63:56]|Target APIC ID(s)|

**Delivery modes:**

- _Fixed:_ deliver to the CPU(s) specified in the destination field.
- _Lowest priority:_ deliver to whichever CPU in the destination set has the lowest current TPR. Used for load-balanced interrupt distribution.
- _SMI:_ delivers a System Management Interrupt, causing the CPU to enter SMM.
- _NMI:_ delivers a non-maskable interrupt regardless of IF flag.
- _ExtINT:_ passes the vector from an external 8259A (compatibility mode).

**Edge vs level triggering:** Edge-triggered interrupts fire on the rising (or falling) edge of the IRQ signal. Level-triggered interrupts remain asserted as long as the device needs service; the OS must acknowledge the device to deassert the line before sending EOI, otherwise the interrupt fires again immediately. PCI uses level-triggered interrupts; ISA legacy devices often used edge.

#### x2APIC

The original xAPIC uses MMIO registers in a 4 KB page at `0xFEE00000`. This limits the addressable APIC ID space to 8 bits (256 CPUs). Modern many-core systems (and virtual machines with large vCPU counts) use **x2APIC**, which maps APIC registers to MSRs rather than MMIO. This expands the APIC ID to 32 bits, supports more than 255 logical processors, and improves access performance (MSR reads/writes are faster than MMIO in virtualized environments).

---

### Message Signaled Interrupts (MSI and MSI-X)

Physical IRQ lines are a scarce resource: a standard I/O APIC has 24 input pins, and pin sharing (used by PCI for INTx interrupts) introduces latency and ambiguity. **Message Signaled Interrupts** replace physical wires with memory-write transactions.

An MSI-capable device is programmed (by the OS via its PCIe configuration space) with a _message address_ (pointing to a Local APIC register) and a _message data_ value (containing the interrupt vector and delivery mode). When the device wants to interrupt, it issues a PCIe Memory Write transaction to that address with that data. The memory write is routed by the PCIe fabric to the appropriate Local APIC, which treats it as a normal vector delivery — no I/O APIC involved.

**MSI-X** extends this: a device can have up to 2048 independent MSI-X vectors, each with its own address/data pair stored in a per-device MSI-X table in its BAR space. This allows each interrupt source within a device (e.g., each NIC receive queue) to target a different CPU, enabling lock-free interrupt-driven I/O at high bandwidth.

Properties of MSI(X) that make it preferable to pin-based interrupts:

- No IRQ pin sharing — each MSI vector is unique.
- CPU targeting is fully programmable per-vector.
- Edge-only semantics — no remote IRR complexity.
- In-order delivery: a DMA write followed by an MSI write guarantees the data is in memory before the interrupt fires (PCI ordering rules), eliminating a class of driver races.

---

### APIC Interrupt Delivery Sequence

Putting it together, the path from device assertion to ISR execution in a modern system:

```
Device asserts MSI write  →  PCIe fabric routes to Local APIC MMIO
Local APIC checks vector priority vs TPR
  If vector priority > TPR: set IRR bit
  If CPU is not in interrupt context: assert INTP to CPU core
CPU completes current instruction boundary
CPU reads interrupt vector from Local APIC  (no INTA bus cycle needed)
CPU vectors to IDT[vector].ISR
ISR executes
ISR writes EOI to Local APIC  (offset 0xB0)
Local APIC clears ISR bit; checks IRR for next pending
```

For level-triggered I/O APIC delivery (legacy devices), the EOI write is also broadcast to the I/O APIC, clearing the Remote IRR bit in the relevant RTE and allowing the IRQ line to re-assert.

---

### Inter-Processor Interrupts (IPIs)

Local APICs communicate directly with each other via the **Interrupt Command Register (ICR)**. Writing a 64-bit value to ICR causes the Local APIC to send an interrupt message on the system bus addressed to one or more other Local APICs. IPIs are used for:

- **TLB shootdown:** after modifying a shared page table, the modifying CPU sends a FLUSH IPI to all CPUs sharing that address space, causing them to invalidate relevant TLB entries.
- **Scheduler reschedule:** a CPU queuing work for another CPU sends a RESCHED IPI.
- **INIT/SIPI:** during SMP bring-up, the BSP (bootstrap processor) sends INIT then STARTUP IPIs to each AP (application processor) to wake it from halted state and direct it to the startup vector.
- **NMI delivery:** for watchdog timers or crash dumps, an NMI IPI forces all CPUs into a known state.

IPI delivery modes are the same as I/O APIC delivery modes. The destination can be a specific APIC ID, a logical cluster, all-excluding-self, or all-including-self.

---

### PIC Compatibility Mode and Legacy Coexistence

Modern systems initialize in _PIC compatibility mode_ — the 8259A is still present (or emulated), because BIOS/UEFI uses it before the OS configures the APIC. The OS must:

1. Mask all 8259A interrupts (write `0xFF` to both IMR ports).
2. Remap the 8259A vectors away from `0x00–0x0F` (which overlap CPU exception vectors) — typically to `0x20–0x2F`.
3. Enable the I/O APIC (set the APIC enable bit in `IA32_APIC_BASE` MSR and the SVR).
4. Program I/O APIC RTEs for all needed IRQs.

The `MP Table` (legacy) and `ACPI MADT` (Modern) tables in firmware describe the system's APIC topology — how many Local APICs exist, I/O APIC base addresses, and interrupt source overrides (e.g., ISA IRQ0 is routed to I/O APIC pin 2 on some platforms). The OS reads these tables during boot to configure routing correctly.

---

**Key Points**

- The 8259A delivers interrupts to a single CPU via a cascaded master-slave topology with 16 IRQ lines; it is adequate for uniprocessor systems but architecturally incompatible with SMP.
- The APIC architecture splits into Local APIC (per CPU) and I/O APIC (per chipset): the I/O APIC receives device IRQs and routes them as messages to selected Local APICs.
- Each I/O APIC Redirection Table Entry independently configures vector, delivery mode, destination CPU, trigger mode, and polarity per IRQ source — enabling fine-grained per-interrupt routing policy.
- The Task Priority Register in each Local APIC provides a hardware priority threshold, allowing the OS to suppress interrupts below a given class without masking individual sources.
- MSI and MSI-X replace physical IRQ lines with PCIe memory-write transactions, eliminating pin sharing, supporting thousands of independent vectors, and enabling per-queue CPU targeting in high-throughput devices.
- IPIs are sent via the Interrupt Command Register and are the mechanism for TLB shootdowns, SMP wakeup (INIT/SIPI), and inter-core scheduler signaling.
- x2APIC extends the APIC ID field from 8 to 32 bits and uses MSRs instead of MMIO, supporting systems with more than 255 logical processors.

**Conclusion**

The evolution from 8259A to APIC reflects the broader evolution of the x86 platform from uniprocessor to massively parallel: each new layer (Local APIC, I/O APIC, MSI-X, x2APIC) removes a bottleneck — in IRQ line count, CPU routing flexibility, vector space, or addressable processor count — that the previous generation could not accommodate. A correct mental model of interrupt delivery is essential for OS kernel development, real-time scheduling, and performance analysis of interrupt-driven I/O.

**Next Steps**

From the syllabus: **BIOS/UEFI and boot sequence** directly follows from this material — boot firmware initializes the 8259A and APIC, builds the MADT, and transitions control to the OS, which then re-configures interrupt routing. **Synchronization primitives in hardware** connects to IPI-driven TLB shootdown, which is a concrete example of hardware-level inter-core synchronization.

---

