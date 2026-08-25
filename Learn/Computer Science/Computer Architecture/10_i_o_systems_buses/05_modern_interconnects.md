## Modern Interconnects


### Overview

Modern interconnects are standardized communication interfaces that define how processors, peripherals, and external devices exchange data. Each protocol makes distinct trade-offs across bandwidth, latency, physical complexity, power consumption, and topology — matched to the scale of the subsystem it connects.

Four protocols dominate: **PCIe** for high-throughput internal expansion; **USB** for universal external device connectivity; **I²C** for low-speed, multi-device chip-to-chip buses; and **SPI** for moderate-speed, low-latency chip-level links. They span seven orders of magnitude in bandwidth and operate at profoundly different abstraction levels.

---

### PCIe — Peripheral Component Interconnect Express

#### Architecture and Physical Layer

PCIe is a serial, point-to-point, full-duplex interconnect organized around _lanes_. A lane consists of two differential pairs — one for transmit (TX), one for receive (RX). Lanes are aggregated into _links_ of ×1, ×2, ×4, ×8, ×16, or ×32. Width is negotiated at link-training time; a ×16 slot can operate a ×1 device.

The PHY is AC-coupled. Differential signaling on each pair carries an encoded bitstream. Pre-emphasis and equalization compensate for dielectric loss in FR4 PCB traces and connector pins.

**Generations and raw lane bandwidth:**

|Generation|Encoding|Signaling rate|Raw per-lane (each dir.)|Effective per-lane|
|---|---|---|---|---|
|PCIe 1.0|8b/10b|2.5 GT/s|250 MB/s|200 MB/s|
|PCIe 2.0|8b/10b|5 GT/s|500 MB/s|400 MB/s|
|PCIe 3.0|128b/130b|8 GT/s|984 MB/s|~970 MB/s|
|PCIe 4.0|128b/130b|16 GT/s|1,969 MB/s|~1,970 MB/s|
|PCIe 5.0|128b/130b|32 GT/s|3,938 MB/s|~3,900 MB/s|
|PCIe 6.0|PAM4 + FLIT|64 GT/s|~7,877 MB/s|~7,563 MB/s|

A ×16 PCIe 5.0 link delivers ~62.4 GB/s bidirectionally — the bandwidth that current discrete GPU architectures depend on.

PCIe 6.0 introduces **PAM4** (Pulse Amplitude Modulation, 4-level) encoding instead of NRZ, and replaces the traditional TLP/DLLP framing model with **FLIT** (Flow Control Unit) mode, enabling forward error correction (FEC) without the latency cliff that PAM4's higher bit-error rate would otherwise cause.

#### Protocol Stack

PCIe is a three-layer stack:

```
┌──────────────────────────────────┐
│     Transaction Layer (TL)       │  TLPs: MRd, MWr, CplD, AtomicOp
├──────────────────────────────────┤
│     Data Link Layer (DLL)        │  ACK/NAK, LCRC, retry buffer, FC
├──────────────────────────────────┤
│     Physical Layer (PL)          │  LTSSM, scrambling, 8b10b/128b130b
└──────────────────────────────────┘
```

**Transaction Layer Packets (TLPs):** The unit of work at the application level. Key types:

- **Memory Read (MRd):** Initiates a split-transaction read; the completer returns a Completion with Data (CplD) TLP asynchronously.
- **Memory Write (MWr):** Posted (non-confirmed); fire-and-forget. No explicit acknowledgment at TL.
- **I/O Read/Write:** Legacy x86 I/O address space access.
- **Configuration (CfgRd/CfgWr):** Enumerate and configure endpoint registers (BARs, command register, etc.).
- **AtomicOp:** Fetch-and-add, compare-and-swap, swap — for lock-free synchronization across the fabric.
- **Message (Msg):** Sideband events — interrupts (MSI, MSI-X), power management, error signaling, vendor-defined messages.

Each TLP carries a header (3 or 4 DW), optional data payload (up to 4 KB, configurable via `MaxPayloadSize`), and an ECRC (end-to-end CRC) for optional data integrity over multi-hop switches.

**Data Link Layer:** Adds a 12-bit sequence number and a 32-bit LCRC to each TLP, wrapping it into a DLLP-framed packet. The transmitter holds packets in a _replay buffer_ until an ACK DLLP is received. On NAK or timeout, it replays from the unacknowledged sequence number. Flow control uses credit-based arbitration: the receiver advertises header credits (HdrFC) and data credits (DataFC) for each traffic class; the transmitter only sends when credits are available.

**Physical Layer / LTSSM:** The Link Training and Status State Machine manages hot-plug, power states (L0, L0s, L1, L2/L3), speed negotiation, and lane polarity/reversal correction. Training sequences exchange TS1/TS2 ordered sets to agree on link width and speed.

#### Address Space and Configuration

Each PCIe function exposes up to six **Base Address Registers (BARs)** in its Configuration Space (256 bytes per function; 4 KB with PCIe Extended Configuration Space). The system firmware/OS assigns physical address ranges to each BAR during enumeration. CPU memory accesses to those addresses are routed to the device.

**Memory-mapped I/O (MMIO):** All PCIe register access — including GPU framebuffer, NVMe registers, NIC queues — goes through MMIO. The CPU writes to a virtual address that the MMU translates to a physical address in the PCIe window; the Memory Controller routes the transaction to the root complex, which generates a MWr TLP.

**MSI/MSI-X:** Modern PCIe devices signal interrupts by writing a small memory write TLP to a CPU-local APIC address rather than asserting a physical IRQ line. MSI-X supports up to 2048 independent vectors per function and allows per-vector masking from software.

#### Switch Fabric and Multi-Endpoint Systems

PCIe switches create a hierarchy: a root complex (integrated into the CPU or chipset) connects to one or more downstream ports; switches extend the tree. Each switch implements store-and-forward routing of TLPs by matching the destination bus/device/function address against its routing tables.

PCIe does **not** implement a ring or mesh natively — it is always a rooted tree. NVLink, CXL, and proprietary fabrics extend this topology for multi-GPU and disaggregated memory use cases.

**CXL (Compute Express Link):** Layered on top of PCIe 5.0 PHY, CXL adds three protocols — CXL.io (PCIe-compatible configuration/I/O), CXL.cache (device cache coherency with host), and CXL.mem (host access to device-attached memory with coherency). CXL enables persistent memory expanders, GPU/accelerator shared memory, and pooled memory fabric architectures.

---

### USB — Universal Serial Bus

#### Evolution and Key Revisions

USB is a host-controlled, tiered-star topology serial bus designed for interoperable external device connectivity.

|Version|Max speed|Encoding|Connector|Notes|
|---|---|---|---|---|
|USB 1.0/1.1|12 Mb/s (FS)|NRZI|Type-A/B|Low Speed: 1.5 Mb/s|
|USB 2.0|480 Mb/s (HS)|NRZI + bit stuffing|Type-A/B, Mini, Micro|Still ubiquitous for HID/audio|
|USB 3.2 Gen 1|5 Gb/s|8b/10b, SS|Type-A/B, Micro-B, C|SuperSpeed; separate RX/TX pairs|
|USB 3.2 Gen 2|10 Gb/s|128b/132b, SS+|Type-C||
|USB 3.2 Gen 2×2|20 Gb/s|128b/132b × 2 lanes|Type-C||
|USB4 Gen 2×2|20 Gb/s|Tunneled|Type-C|Thunderbolt 3 compatible|
|USB4 Gen 3×2|40 Gb/s|Tunneled|Type-C|Thunderbolt 4 compatible|
|USB4 v2 Gen 4×2|80 Gb/s|PAM2 × 2 lanes|Type-C||

USB4 tunnels USB 3.2, DisplayPort, and PCIe traffic over the same physical link — the bandwidth is partitioned between protocols at runtime.

#### Host Controller and Enumeration

USB is strictly master–slave (host–device). The host contains a **Host Controller** (OHCI, EHCI, xHCI) that owns the bus. There is no peer-to-peer communication unless mediated by a USB On-The-Go (OTG) or USB4 host-to-host bridge.

**Enumeration sequence:**

1. Device attach detected by hub (D+ or D− pull-up).
2. Hub signals port connect status change to host.
3. Host resets port (SE0 for ≥10 ms).
4. Host addresses device at address 0, issues `GET_DESCRIPTOR` for device descriptor (first 8 bytes).
5. Host assigns a unique device address (1–127) via `SET_ADDRESS`.
6. Host retrieves full device, configuration, interface, and endpoint descriptors.
7. Host loads appropriate driver; sets configuration via `SET_CONFIGURATION`.

Hubs are transparent at the protocol level — the host sees individual device addresses regardless of hub topology depth (max 7 tiers including root hub).

#### Transfer Types and Scheduling

USB 2.0 and later schedule transfers within **frames** (1 ms for FS/LS) or **microframes** (125 µs for HS/SS). Four transfer types:

|Type|Guarantee|Bandwidth alloc.|Typical use|
|---|---|---|---|
|Control|Reliable, low latency|Up to 10% of frame|Enumeration, config commands|
|Bulk|Reliable, no timing|Remaining bandwidth|Mass storage, printers|
|Interrupt|Reliable, bounded latency|Polled at fixed intervals|HID, keyboards, mice|
|Isochronous|Unreliable (no retry), bounded bandwidth|Reserved bandwidth|Audio, video streaming|

Isochronous endpoints sacrifice error recovery for timing guarantees — dropped packets are not retransmitted.

#### USB Type-C and Power Delivery

Type-C introduces a symmetrical, reversible connector with a **CC (Configuration Channel)** line used to negotiate orientation, cable capability, and the **USB Power Delivery (PD)** protocol. PD negotiates VBUS voltage (5 V–48 V) and current (up to 5 A) via a BFSK-encoded message protocol on CC. USB PD 3.1 supports up to 240 W (Extended Power Range).

The **Alternate Mode** mechanism allows a Type-C port to signal a non-USB protocol (DisplayPort, Thunderbolt, HDMI 2.1) on the high-speed pairs after CC negotiation — the USB logic is bypassed entirely for those pins.

---

### I²C — Inter-Integrated Circuit

#### Physical Layer and Topology

I²C (pronounced eye-squared-C) is a two-wire, synchronous, half-duplex, multi-master, multi-slave serial bus. The two signals are:

- **SDA** (Serial Data): bidirectional data line.
- **SCL** (Serial Clock): clock driven by the master (or stretched by the slave).

Both lines are **open-drain** (or open-collector). Each node drives the line low or releases it (high-Z). A pull-up resistor (typically 4.7 kΩ at 100 kHz, 2.2 kΩ at 400 kHz) returns the line to V~DD~. This enforces a **wired-AND**: any device pulling low wins. Bus capacitance limits cable length; rise time τ = R~p~ × C~bus~ constrains maximum speed.

Typical speed modes:

|Mode|Clock rate|
|---|---|
|Standard Mode (SM)|100 kHz|
|Fast Mode (FM)|400 kHz|
|Fast Mode Plus (FM+)|1 MHz|
|High-Speed Mode (HS)|3.4 MHz|
|Ultra Fast-mode (UFm)|5 MHz (unidirectional; push-pull)|

Multiple masters are allowed; the bus uses **arbitration** by clock stretching and SDA collision detection.

#### Transaction Structure

Every I²C transaction follows the pattern:

```
START → [ADDR(7) + R/W̄] → ACK → [DATA(8)] → ACK → … → STOP
```

**START condition:** SDA falls while SCL is high — illegal at all other times, making it unambiguous.  
**STOP condition:** SDA rises while SCL is high.  
**Repeated START (Sr):** A START without a preceding STOP — allows a master to change direction (write → read) or address a different slave without releasing the bus.

Each 7-bit address byte is followed by a read/not-write bit. The addressed slave acknowledges by pulling SDA low during the 9th clock pulse. A **NACK** (SDA left high) signals: device not present, busy, or read complete.

10-bit addressing extends the address space using a reserved prefix (`11110xx`) in the first byte, followed by the remaining 8 bits in a second address byte.

**Register-addressed access pattern** (dominant in sensor/peripheral use):

```
START → ADDR+W → ACK → REG_ADDR → ACK →
  Sr   → ADDR+R → ACK → DATA[0] → ACK → DATA[1] → ACK → … → DATA[n] → NACK → STOP
```

The master writes a register pointer, then issues a repeated START to switch to read direction. This is the idiom used by virtually every I²C sensor, EEPROM, IMU, and codec.

#### Arbitration and Clock Stretching

**Arbitration:** When two masters simultaneously assert START, each continues driving and monitoring SDA. The first master to transmit a `1` while the bus reads `0` (because the other master drove `0`) loses arbitration — it releases the bus immediately without corrupting the winning master's transaction.

**Clock stretching:** A slave may hold SCL low after the master releases it, forcing the master to wait. This allows slow devices (e.g., ADCs performing a conversion) to pace the transaction without protocol overhead. Some fast I²C implementations (e.g., certain FPGAs) do not implement clock stretching detection — a known interoperability hazard.

#### Limitations and Common Pitfalls

- **Address conflicts:** The 7-bit address space (128 addresses; several reserved) is small. Devices with fixed addresses (e.g., some EEPROMs at 0x50–0x57) can conflict when multiple identical parts are on the same bus. Most ICs expose 1–3 address-select pins.
- **No flow control beyond stretching:** Long transactions block all masters.
- **Capacitance budget:** Standard-mode I²C has a 400 pF bus capacitance limit. Long PCB traces, cables, or many devices will degrade rise times and require repeaters or active level-shifters.
- **No built-in error detection:** There is no CRC; NACK indicates presence/absence, not data integrity. SMBus (a subset of I²C) adds a Packet Error Code (PEC) byte using CRC-8.

---

### SPI — Serial Peripheral Interface

#### Physical Signals and Topology

SPI is a four-wire, synchronous, full-duplex, single-master serial protocol. Standard signals:

|Signal|Direction|Function|
|---|---|---|
|**SCLK**|Master → Slave|Serial clock|
|**MOSI**|Master → Slave|Master Out, Slave In (data)|
|**MISO**|Slave → Master|Master In, Slave Out (data)|
|**CS̄ / SS̄**|Master → Slave|Active-low chip select (one per slave)|

There is no addressing on the bus itself — the master asserts a device's CS̄ line to select it. Adding N slaves requires N dedicated CS̄ lines from the master (or an external demultiplexer). Alternatives:

- **Daisy-chain:** MISO of one slave feeds MOSI of the next; the master shifts data through the chain. Used by LED drivers (WS2801), ADC arrays.
- **Dual SPI:** Two data lines (IO0, IO1) for 2× throughput. **Quad SPI (QSPI):** Four data lines (IO0–IO3) for 4× throughput — standard for NOR Flash (JEDEC JESD216 / SFDP). **Octal SPI (OPI):** Eight data lines for 8× throughput, used in HyperBus and high-density NOR Flash.

SPI has no formal standard body specification (unlike I²C, which is Philips/NXP), so implementations vary. Clock speed is constrained only by the device's timing specifications and PCB parasitics — modern SPI Flash runs at 80–133 MHz SDR; QSPI DDR operates at 200 MHz effective (400 MT/s on four lines = ~200 MB/s).

#### Clock Polarity and Phase (CPOL, CPHA)

SPI defines four modes based on idle clock polarity (**CPOL**) and the clock edge on which data is sampled (**CPHA**):

|Mode|CPOL|CPHA|Clock idle|Sample edge|
|---|---|---|---|---|
|0|0|0|Low|Rising|
|1|0|1|Low|Falling|
|2|1|0|High|Falling|
|3|1|1|High|Rising|

Mode 0 (CPOL=0, CPHA=0) and Mode 3 (CPOL=1, CPHA=1) are the most common in practice. Mismatched mode configuration between master and slave is the single most frequent SPI bring-up error.

#### Transaction Mechanics

SPI uses a **shift-register** model. The master and slave each have an N-bit shift register (typically 8, 16, or 32 bits). On each clock edge:

- The transmit register's MSB is driven onto the data line.
- The receive register shifts in the data line's current value at the LSB.

After N clocks, master and slave have exchanged N bits. Because it is simultaneously shifting in and out, every SPI read implies a simultaneous write (often `0x00` or `0xFF` dummy bytes).

CS̄ is asserted (driven low) before the first clock and deasserted after the last — some devices latch data on the CS̄ rising edge rather than on the last SCLK edge, making CS̄ timing critical.

**Setup and hold times:** The master must ensure data on MOSI is stable for `t_setup` before the sample edge, and the slave must hold MISO for `t_hold` after it. At high clock rates, PCB trace length mismatch between SCLK and MISO causes effective hold violations — addressed by adjustable sample point registers in modern SPI controllers.

#### SPI vs I²C — Comparative Summary

|Property|SPI|I²C|
|---|---|---|
|Wires|4 (+ CS̄ per slave)|2|
|Topology|Single-master, point-to-point per CS̄|Multi-master, multi-slave|
|Duplex|Full|Half|
|Addressing|CS̄ line selection|7-bit/10-bit address|
|Speed|Up to 100+ MHz (device limited)|Up to 5 MHz (UFm)|
|Overhead|None|START/STOP + address + ACK per transaction|
|Error detection|None|NACK (presence only); SMBus PEC optional|
|Bus capacitance|Less critical|400 pF limit|
|Typical use|Flash, ADC, DAC, displays|Sensors, EEPROMs, PMICs, codecs|

---

### Topology and System Context

The diagram below places all four protocols in a representative SoC/motherboard system, illustrating where each protocol operates.---

### Error Detection and Reliability Comparison

|Protocol|Error detection mechanism|Recovery|
|---|---|---|
|PCIe|LCRC (DLL, 32-bit), ECRC (TL, optional, 32-bit), FEC (PCIe 6.0)|DLL replay buffer; TL timeout → UR/CA completion status|
|USB|CRC5 (token packets), CRC16 (data packets)|Automatic retry (control/bulk/interrupt); no retry for isochronous|
|I²C|None in base spec; SMBus PEC (CRC-8) optional|NACK causes master to retry or abort; no automatic framing recovery|
|SPI|None|Software must implement checksum in payload if required|

---

### Performance Mental Model

The bandwidth and latency characteristics of the four protocols differ by design intent:

- **PCIe** targets memory-bandwidth-equivalent throughput between CPU and discrete silicon. Its split-transaction, credit-based model is engineered to saturate links with outstanding transactions rather than waiting for each to complete. The dominant latency source for a single MRd is the round-trip TLP time (typically ~1–2 µs for root-to-endpoint on a desktop).
- **USB** tolerates multi-µs to multi-ms frame scheduling latency by design. Bulk transfers are opportunistic; isochronous transfers reserve bandwidth at the cost of reliability. USB is not suitable for register-level peripheral access at sub-µs latency.
- **I²C** has high per-byte overhead relative to SPI: each byte requires a clock + ACK cycle, and START/STOP conditions consume bus time. A 16-byte I²C read at 400 kHz takes on the order of 500 µs. It is appropriate where a handful of bytes per transaction is the norm.
- **SPI** has near-zero framing overhead and is fundamentally limited only by clock rate and device timing. A 256-byte SPI read at 50 MHz completes in ~40 µs. QSPI DDR halves this further on supported Flash devices.

---

### Key Design Selection Criteria

Choosing between protocols at design time involves three primary axes:

**Bandwidth requirement:** PCIe when throughput is measured in GB/s (GPU, NVMe, NIC). QSPI Flash or Octal-SPI when hundreds of MB/s of storage or code-fetch bandwidth are needed. USB for external device access in the 100 MB/s–10 GB/s range. I²C and standard SPI for low-data-rate sensors and control registers.

**Physical constraints:** I²C minimizes pin count to two shared wires regardless of slave count — decisive for dense SoC designs or board space–limited embedded systems. SPI's wire count grows linearly with slaves (one CS̄ per device) but supports full-duplex operation without the wired-AND bus contention. USB handles long external cables and hot-plug natively; PCIe is PCB- or M.2/CXL-connector–centric.

**Protocol complexity and ecosystem:** PCIe demands root-complex silicon, enumeration, IOMMU management, and driver stacks. USB requires a host controller, descriptor-based enumeration, and class drivers. I²C and SPI are bare shift-register protocols implementable in a few dozen lines of firmware, making them suitable for microcontrollers without OS support.

---

**Next Steps:** The most productive adjacent topics are **I/O performance metrics** (bandwidth, latency, IOPS — needed to reason about bottlenecks across these interfaces), **DMA and interrupt-driven I/O** (how the CPU is insulated from per-transaction involvement at high throughput), and **bus arbitration** (the mechanisms that generalize I²C multi-master arbitration and PCIe credit management into a unified framework).

---

