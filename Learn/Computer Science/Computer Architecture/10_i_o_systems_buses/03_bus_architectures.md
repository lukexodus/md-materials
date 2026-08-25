## Bus Architectures


A bus is a shared communication pathway connecting multiple components in a computer system. It defines how data, addresses, and control signals are transferred between the processor, memory, and I/O devices. Bus architecture determines timing discipline, bandwidth, scalability, and latency characteristics of the entire system interconnect.

---

### Structure of a Bus

A bus is composed of three logically distinct groups of lines:

|Line Group|Function|
|---|---|
|**Address lines**|Carry the target address (memory location or device register)|
|**Data lines**|Transfer actual data between master and slave|
|**Control lines**|Carry signals such as read/write, clock, interrupt, bus request/grant|

Width of each group directly affects addressable space and transfer bandwidth.

---

### Bus Transaction Model

Every bus operation follows a master–slave model:

1. **Arbitration** — a master (CPU, DMA) acquires the bus
2. **Address phase** — master broadcasts the target address
3. **Data phase** — data is transferred (one or more cycles)
4. **Release** — master relinquishes bus control

---

### Synchronous Bus

A synchronous bus operates under a shared clock signal distributed to all devices on the bus. All events — address assertion, data sampling, control acknowledgment — are referenced to clock edges.

#### Timing Model

<svg viewBox="0 0 720 220" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <!-- Clock --> <text x="10" y="30" fill="#aaa">CLK</text> <polyline points="60,20 60,35 100,35 100,20 140,20 140,35 180,35 180,20 220,20 220,35 260,35 260,20 300,20 300,35 340,35 340,20 380,20 380,35 420,35 420,20 460,20 460,35 500,35 500,20 540,20 540,35 580,35 580,20 620,20 620,35 660,35 660,20 700,20" fill="none" stroke="#4fc3f7" stroke-width="2"/> <!-- Address -->

<text x="10" y="75" fill="#aaa">ADDR</text> <line x1="60" y1="65" x2="140" y2="65" stroke="#888" stroke-width="2"/> <line x1="60" y1="85" x2="140" y2="85" stroke="#888" stroke-width="2"/> <polygon points="140,65 160,75 140,85" fill="#f9a825" stroke="#f9a825"/> <polygon points="140,75 160,65 340,65 340,85 160,85" fill="#f9a825" fill-opacity="0.3" stroke="#f9a825" stroke-width="1.5"/> <polygon points="340,65 360,75 340,85" fill="#f9a825" stroke="#f9a825" transform="scale(-1,1) translate(-700,0)"/> <line x1="340" y1="65" x2="700" y2="65" stroke="#888" stroke-width="2"/> <line x1="340" y1="85" x2="700" y2="85" stroke="#888" stroke-width="2"/> <text x="200" y="79" fill="#f9a825" font-size="11">Address Valid</text>

<!-- Data -->

<text x="10" y="130" fill="#aaa">DATA</text> <line x1="60" y1="120" x2="260" y2="120" stroke="#888" stroke-width="2"/> <line x1="60" y1="140" x2="260" y2="140" stroke="#888" stroke-width="2"/> <polygon points="260,120 280,130 260,140" fill="#66bb6a" stroke="#66bb6a"/> <polygon points="260,130 280,120 500,120 500,140 280,140" fill="#66bb6a" fill-opacity="0.3" stroke="#66bb6a" stroke-width="1.5"/> <line x1="500" y1="120" x2="700" y2="120" stroke="#888" stroke-width="2"/> <line x1="500" y1="140" x2="700" y2="140" stroke="#888" stroke-width="2"/> <text x="340" y="134" fill="#66bb6a" font-size="11">Data Valid</text>

<!-- Read/Write -->

<text x="10" y="175" fill="#aaa">R/W</text> <line x1="60" y1="165" x2="700" y2="165" stroke="#ce93d8" stroke-width="2"/>

<!-- Cycle markers --> <line x1="140" y1="10" x2="140" y2="195" stroke="#555" stroke-width="1" stroke-dasharray="4,3"/> <line x1="260" y1="10" x2="260" y2="195" stroke="#555" stroke-width="1" stroke-dasharray="4,3"/> <line x1="500" y1="10" x2="500" y2="195" stroke="#555" stroke-width="1" stroke-dasharray="4,3"/>

<text x="90" y="210" fill="#999" font-size="10">T1</text> <text x="190" y="210" fill="#999" font-size="10">T2 (addr)</text> <text x="360" y="210" fill="#999" font-size="10">T3–T4 (wait)</text> <text x="540" y="210" fill="#999" font-size="10">T5 (data)</text> </svg>

#### Characteristics

- All devices share one clock; the slowest device constrains the bus cycle time
- **Wait states** are inserted when a slow device cannot respond in one cycle; the master holds address/control and waits
- Simple to implement; timing analysis is straightforward
- Clock skew degrades signal integrity at high frequencies, limiting practical bus length and speed
- Examples: PCI (33/66 MHz), ISA (8 MHz), FSB in older Intel systems

#### Synchronous Read Cycle (simplified)

```
Cycle 1: Master asserts address + READ signal
Cycle 2: Address decoded by target (wait states inserted if needed)
Cycle 3: Target drives data onto data lines
         Master samples data on rising clock edge
Cycle 4: Master de-asserts address; target releases data bus
```

---

### Asynchronous Bus

An asynchronous bus uses no shared clock. Instead, it relies on a **handshake protocol** — a sequence of request and acknowledgment signals — to coordinate transfers. Each step begins only when the previous step is confirmed complete.

#### Handshake Protocol (Full Handshake / 4-cycle)

<svg viewBox="0 0 720 280" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <!-- Timeline axis --> <line x1="60" y1="250" x2="700" y2="250" stroke="#555" stroke-width="1"/> <text x="60" y="265" fill="#777" font-size="10">t0</text> <text x="180" y="265" fill="#777" font-size="10">t1</text> <text x="320" y="265" fill="#777" font-size="10">t2</text> <text x="460" y="265" fill="#777" font-size="10">t3</text> <text x="600" y="265" fill="#777" font-size="10">t4</text> <!-- REQ signal -->

<text x="10" y="45" fill="#aaa">REQ</text> <polyline points="60,50 60,35 320,35 320,50 700,50" fill="none" stroke="#4fc3f7" stroke-width="2"/> <text x="160" y="28" fill="#4fc3f7" font-size="10">Master asserts REQ</text> <text x="330" y="28" fill="#4fc3f7" font-size="10">Master de-asserts REQ</text>

<!-- ADDR/DATA lines -->

<text x="10" y="105" fill="#aaa">ADDR</text> <line x1="60" y1="95" x2="180" y2="95" stroke="#888" stroke-width="2"/> <line x1="60" y1="115" x2="180" y2="115" stroke="#888" stroke-width="2"/> <polygon points="180,95 200,105 180,115" fill="#f9a825" stroke="#f9a825"/> <polygon points="180,105 200,95 460,95 460,115 200,115" fill="#f9a825" fill-opacity="0.3" stroke="#f9a825" stroke-width="1.5"/> <line x1="460" y1="95" x2="700" y2="95" stroke="#888" stroke-width="2"/> <line x1="460" y1="115" x2="700" y2="115" stroke="#888" stroke-width="2"/> <text x="280" y="109" fill="#f9a825" font-size="10">Address/Data Valid</text>

<!-- ACK signal -->

<text x="10" y="165" fill="#aaa">ACK</text> <polyline points="60,170 60,155 460,155 460,170 600,170 600,155 700,155" fill="none" stroke="#66bb6a" stroke-width="2"/> <text x="290" y="148" fill="#66bb6a" font-size="10">Slave asserts ACK</text> <text x="470" y="148" fill="#66bb6a" font-size="10">Slave de-asserts ACK</text>

<!-- Vertical event markers --> <line x1="180" y1="20" x2="180" y2="245" stroke="#555" stroke-width="1" stroke-dasharray="3,3"/> <line x1="320" y1="20" x2="320" y2="245" stroke="#555" stroke-width="1" stroke-dasharray="3,3"/> <line x1="460" y1="20" x2="460" y2="245" stroke="#555" stroke-width="1" stroke-dasharray="3,3"/> <line x1="600" y1="20" x2="600" y2="245" stroke="#555" stroke-width="1" stroke-dasharray="3,3"/> <!-- Annotations -->

<text x="65" y="215" fill="#999" font-size="10">①</text> <text x="185" y="215" fill="#999" font-size="10">②</text> <text x="325" y="215" fill="#999" font-size="10">③</text> <text x="465" y="215" fill="#999" font-size="10">④</text>

<text x="10" y="235" fill="#666" font-size="9">① Master drives addr, asserts REQ</text> <text x="240" y="235" fill="#666" font-size="9">② Slave sees REQ, drives data, asserts ACK</text> <text x="10" y="248" fill="#666" font-size="9">③ Master sees ACK, de-asserts REQ, samples data</text> <text x="310" y="248" fill="#666" font-size="9">④ Slave sees REQ↓, de-asserts ACK</text> </svg>

#### Handshake Variants

|Variant|Description|
|---|---|
|**2-cycle (half handshake)**|ACK implicitly resets when REQ is de-asserted; less safe|
|**4-cycle (full handshake)**|Both REQ and ACK explicitly cycle high then low; self-resetting, preferred|
|**Semi-synchronous**|Asynchronous handshake with clock alignment on final data sample|

#### Characteristics

- Each device responds at its own speed; no wait states needed — slower devices simply take longer to assert ACK
- No clock distribution problem; bus length is not constrained by skew
- More complex logic for handshake generation and detection
- Higher per-transaction overhead due to signal propagation round-trips
- Examples: original VMEbus, NuBus, early IEEE 488 (GPIB), some embedded I²C transactions

---

### Synchronous vs Asynchronous — Direct Comparison

|Property|Synchronous|Asynchronous|
|---|---|---|
|Timing reference|Shared clock|Handshake signals (REQ/ACK)|
|Speed|Fixed by clock; fast for matched devices|Adapts to each device's speed|
|Slow device handling|Wait states required|ACK latency absorbs delay naturally|
|Clock skew sensitivity|High; limits bus length|None|
|Implementation complexity|Low|Higher|
|Bandwidth at peak|Higher (no handshake overhead)|Lower (round-trip signaling)|
|Fault behavior|Silent hang if device misses cycle|Detectable via ACK timeout|
|Typical use|On-chip, same-board interconnects|Mixed-speed systems, legacy I/O|

---

### Split-Transaction Bus

A performance refinement applicable to both synchronous and asynchronous designs. The address phase and data phase are decoupled — the bus is released between them, allowing other masters to use it while the first transaction's data is being prepared.

```
Master A: [ADDR phase] → releases bus → ... → [DATA phase when ready]
Master B:              → [ADDR phase] → [DATA phase]  (interleaved)
```

This improves bus utilization significantly when memory latency is high. Used in later PCI variants and most modern split-transaction interconnects.

---

### Multiplexed vs Non-Multiplexed Buses

|Type|Description|Trade-off|
|---|---|---|
|**Non-multiplexed**|Separate address and data lines|Higher pin count, simultaneous transfer|
|**Multiplexed**|Address and data share same lines, time-multiplexed|Lower pin count, extra cycle for demux|

PCI uses a multiplexed 32/64-bit AD bus. ISA uses separate address and data buses.

---

### Bus Bandwidth

For a synchronous bus:

$$\text{Bandwidth} = \frac{\text{Bus width (bytes)} \times \text{Clock frequency}}{\text{Cycles per transaction}}$$

**Example:** A 32-bit synchronous bus at 33 MHz with 4-cycle transactions:

$$\text{BW} = \frac{4 \text{ B} \times 33 \times 10^6}{4} = 33 \text{ MB/s}$$

Burst transfers amortize the overhead cycles across multiple data words, increasing effective bandwidth.

---

### Bus Arbitration (Applies to Both Types)

When multiple masters contend for the bus, arbitration resolves priority:

|Scheme|Description|
|---|---|
|**Daisy-chain**|Grant signal passes serially; closest device wins; simple but unfair|
|**Centralized parallel**|Each master has dedicated request/grant lines to a central arbiter|
|**Distributed (self-selection)**|Devices observe each other's requests and compute priority locally (VMEbus)|
|**Round-robin / Fair**|Arbitration rotates among requesters to prevent starvation|

---

### Transition to Modern Interconnects

Traditional shared buses — both synchronous and asynchronous — suffer from **bus contention**: only one transaction can use the bus at a time, and adding more devices degrades throughput. Modern systems replace shared buses with **point-to-point switched fabrics**:

|Legacy Bus|Modern Replacement|
|---|---|
|PCI (synchronous shared)|PCIe (serial point-to-point, packetized)|
|FSB (synchronous shared)|HyperTransport / QPI / UPI|
|Parallel SCSI|SAS / NVMe over PCIe|
|ISA / LPC|Direct SoC fabric or PCIe|

The conceptual timing disciplines — synchronous clocking, handshake acknowledgment — remain relevant inside these modern fabrics at the link and transaction layer level, even though physical topology has changed.

---

**Key Points**

- Synchronous buses tie all transactions to a clock; fast but limited by skew and slowest device.
- Asynchronous buses use REQ/ACK handshakes; device-speed-independent but carry round-trip overhead.
- Wait states compensate for slow devices on synchronous buses; ACK latency serves the same role on asynchronous buses.
- Split-transaction decouples address and data phases, improving utilization regardless of timing discipline.
- Bus bandwidth is bounded by width, frequency, and cycles-per-transaction; burst modes raise effective throughput.
- Modern point-to-point fabrics (PCIe, UPI) supersede shared buses but inherit their timing principles internally.

**Next Steps** Proceed to bus arbitration depth (centralized vs distributed schemes) or advance to Module 10's modern interconnects: PCIe transaction layer, USB protocol stack, and DMA interaction with bus architecture.

---

