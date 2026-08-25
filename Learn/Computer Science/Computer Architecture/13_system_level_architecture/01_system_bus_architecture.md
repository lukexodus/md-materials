## System Bus Architecture


A system bus is the shared communication infrastructure through which the processor, memory, and peripheral devices exchange data, addresses, and control signals. Bus architecture defines not only the physical medium but the protocol, arbitration policy, timing discipline, and topological organization that govern all communication within a computer system. The evolution of system bus design reflects a continuous tension between bandwidth demand, latency, scalability, and cost.

---

### Foundational Concepts

#### What a Bus Is

A bus is a set of shared signal lines over which multiple agents communicate by adhering to a common protocol. Three logical groups of signals are present in any bus:

|Signal Group|Function|
|---|---|
|**Address lines**|Carry the target address of a memory or I/O operation|
|**Data lines**|Transfer the actual data payload|
|**Control lines**|Encode operation type (read/write), timing strobes, interrupt signals, bus grants|

In early systems these three groups were carried on physically distinct sets of wires. In modern serial buses they are multiplexed over a small number of differential pairs.

#### Bus Transaction Structure

Every bus transaction follows a general pattern regardless of bus type:

```svg
<svg viewBox="0 0 680 120" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11">
  <text x="20" y="20" font-weight="bold" font-size="13">Generic Bus Transaction Phases</text>

  <!-- Phases -->
  <rect x="30" y="35" width="100" height="50" rx="4" fill="#bbdefb" stroke="#1976d2"/>
  <text x="80" y="57" text-anchor="middle" font-weight="bold">Arbitration</text>
  <text x="80" y="73" text-anchor="middle">Master claims</text>
  <text x="80" y="85" text-anchor="middle">the bus</text>

  <rect x="145" y="35" width="100" height="50" rx="4" fill="#c8e6c9" stroke="#388e3c"/>
  <text x="195" y="57" text-anchor="middle" font-weight="bold">Address</text>
  <text x="195" y="73" text-anchor="middle">Target addr</text>
  <text x="195" y="85" text-anchor="middle">placed on bus</text>

  <rect x="260" y="35" width="100" height="50" rx="4" fill="#fff9c4" stroke="#f9a825"/>
  <text x="310" y="57" text-anchor="middle" font-weight="bold">Decode</text>
  <text x="310" y="73" text-anchor="middle">Slave decodes</text>
  <text x="310" y="85" text-anchor="middle">address → ACK</text>

  <rect x="375" y="35" width="100" height="50" rx="4" fill="#ffe0b2" stroke="#e65100"/>
  <text x="425" y="57" text-anchor="middle" font-weight="bold">Data</text>
  <text x="425" y="73" text-anchor="middle">Payload</text>
  <text x="425" y="85" text-anchor="middle">transferred</text>

  <rect x="490" y="35" width="100" height="50" rx="4" fill="#f3e5f5" stroke="#7b1fa2"/>
  <text x="540" y="57" text-anchor="middle" font-weight="bold">Completion</text>
  <text x="540" y="73" text-anchor="middle">Bus released,</text>
  <text x="540" y="85" text-anchor="middle">status signaled</text>

  <!-- Arrows -->
  <line x1="130" y1="60" x2="144" y2="60" stroke="#333" stroke-width="1.5" marker-end="url(#a)"/>
  <line x1="245" y1="60" x2="259" y2="60" stroke="#333" stroke-width="1.5" marker-end="url(#a)"/>
  <line x1="360" y1="60" x2="374" y2="60" stroke="#333" stroke-width="1.5" marker-end="url(#a)"/>
  <line x1="475" y1="60" x2="489" y2="60" stroke="#333" stroke-width="1.5" marker-end="url(#a)"/>

  <defs>
    <marker id="a" markerWidth="6" markerHeight="6" refX="5" refY="3" orient="auto">
      <path d="M0,0 L6,3 L0,6 Z" fill="#333"/>
    </marker>
  </defs>
</svg>
```

---

### Bus Classification

#### By Topology

**Shared bus (multidrop):** A single set of signal lines is physically shared among all agents. All agents observe all transactions. Only one agent may drive the bus at a time, enforced by arbitration. Bandwidth is a shared resource; adding agents increases contention.

**Point-to-point:** Each pair of communicating agents has a dedicated link. Modern system interconnects (PCIe, HyperTransport, QPI/UPI) use this topology. Bandwidth is not shared across links; contention occurs only at switches and crossbars.

#### By Timing Discipline

**Synchronous bus:** All agents share a common clock. Signal sampling occurs at defined clock edges. Simple to implement and analyze; clock skew across long buses or many agents limits maximum frequency.

**Asynchronous bus:** Handshaking signals (request/acknowledge) synchronize each transaction independently. No shared clock required; naturally accommodates agents at different speeds. More complex protocol logic and higher per-transaction overhead.

**Semi-synchronous (clocked with wait states):** A shared clock governs timing, but slower agents may insert wait cycles using a `READY` or `WAIT` signal, stalling the master until the slave is prepared.

#### By Data Transfer Mode

**Serial:** One or a small number of differential pairs carry data bit-by-bit at very high line rates. Modern high-bandwidth interconnects (PCIe, USB 3.x, SATA) are serial.

**Parallel:** Many data lines carry multiple bits simultaneously. Classic system buses (ISA, PCI, FSB) were parallel. Parallel buses suffer from signal integrity problems (crosstalk, skew) at high frequencies, which limits scalable bandwidth growth.

---

### Classical Bus Hierarchy

Early PC and workstation architectures organized buses in a hierarchy: a fast local bus connected the CPU to memory; a slower expansion bus connected peripherals.

```svg
<svg viewBox="0 0 680 380" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11">
  <text x="340" y="22" text-anchor="middle" font-weight="bold" font-size="13">Classical Bus Hierarchy (Legacy PC)</text>

  <!-- CPU -->
  <rect x="280" y="35" width="120" height="40" rx="4" fill="#1976d2" stroke="#0d47a1"/>
  <text x="340" y="60" text-anchor="middle" fill="white" font-weight="bold">CPU</text>

  <!-- Front Side Bus -->
  <rect x="100" y="100" width="480" height="28" rx="4" fill="#42a5f5" stroke="#1565c0"/>
  <text x="340" y="119" text-anchor="middle" fill="white" font-weight="bold">Front Side Bus (FSB)</text>
  <line x1="340" y1="75" x2="340" y2="100" stroke="#1976d2" stroke-width="2"/>

  <!-- North Bridge -->
  <rect x="260" y="148" width="160" height="40" rx="4" fill="#0d47a1" stroke="#01579b"/>
  <text x="340" y="173" text-anchor="middle" fill="white" font-weight="bold">North Bridge</text>
  <line x1="340" y1="128" x2="340" y2="148" stroke="#1976d2" stroke-width="2"/>

  <!-- Memory bus -->
  <line x1="240" y1="168" x2="140" y2="168" stroke="#388e3c" stroke-width="2"/>
  <rect x="40" y="148" width="100" height="40" rx="4" fill="#388e3c" stroke="#1b5e20"/>
  <text x="90" y="168" text-anchor="middle" fill="white">DRAM</text>
  <text x="90" y="183" text-anchor="middle" fill="white">Bus</text>
  <rect x="40" y="210" width="100" height="35" rx="4" fill="#c8e6c9" stroke="#388e3c"/>
  <text x="90" y="232" text-anchor="middle">Main</text>
  <text x="90" y="245" text-anchor="middle">Memory</text>
  <line x1="90" y1="188" x2="90" y2="210" stroke="#388e3c" stroke-width="1.5"/>

  <!-- AGP/PCIe x16 -->
  <line x1="420" y1="168" x2="540" y2="168" stroke="#7b1fa2" stroke-width="2"/>
  <rect x="540" y="148" width="100" height="40" rx="4" fill="#7b1fa2" stroke="#4a148c"/>
  <text x="590" y="168" text-anchor="middle" fill="white">AGP /</text>
  <text x="590" y="183" text-anchor="middle" fill="white">PCIe x16</text>
  <rect x="540" y="210" width="100" height="35" rx="4" fill="#f3e5f5" stroke="#7b1fa2"/>
  <text x="590" y="232" text-anchor="middle">GPU /</text>
  <text x="590" y="245" text-anchor="middle">Display</text>
  <line x1="590" y1="188" x2="590" y2="210" stroke="#7b1fa2" stroke-width="1.5"/>

  <!-- PCI Bus -->
  <rect x="100" y="238" width="480" height="28" rx="4" fill="#f9a825" stroke="#e65100"/>
  <text x="340" y="257" text-anchor="middle" font-weight="bold">PCI Bus</text>
  <line x1="340" y1="188" x2="340" y2="238" stroke="#0d47a1" stroke-width="2"/>

  <!-- South Bridge -->
  <rect x="260" y="286" width="160" height="40" rx="4" fill="#e65100" stroke="#bf360c"/>
  <text x="340" y="311" text-anchor="middle" fill="white" font-weight="bold">South Bridge</text>
  <line x1="340" y1="266" x2="340" y2="286" stroke="#e65100" stroke-width="2"/>

  <!-- ISA / LPC -->
  <line x1="260" y1="306" x2="180" y2="306" stroke="#555" stroke-width="1.5"/>
  <rect x="100" y="292" width="80" height="30" rx="4" fill="#9e9e9e" stroke="#616161"/>
  <text x="140" y="307" text-anchor="middle" fill="white">ISA/LPC</text>
  <text x="140" y="318" text-anchor="middle" fill="white">Legacy</text>

  <!-- SATA / USB -->
  <line x1="420" y1="306" x2="500" y2="306" stroke="#555" stroke-width="1.5"/>
  <rect x="500" y="292" width="100" height="30" rx="4" fill="#9e9e9e" stroke="#616161"/>
  <text x="550" y="307" text-anchor="middle" fill="white">SATA / USB</text>
  <text x="550" y="318" text-anchor="middle" fill="white">Storage / I/O</text>
</svg>
```

The **North Bridge** handled high-bandwidth traffic: CPU-to-memory and CPU-to-GPU. The **South Bridge** handled lower-bandwidth peripherals: storage, USB, audio, legacy I/O. Communication between North and South Bridge traversed a dedicated internal link (e.g., Intel's Hub Interface or AMD's HyperTransport).

This two-chip hub model replaced the older single shared bus (where CPU, memory, and PCI all shared one bus) but was itself eventually replaced by integrating memory controllers and PCIe root complexes directly into the CPU die.

---

### Front Side Bus (FSB)

The FSB was the primary interface between the CPU and North Bridge in Intel architectures from the Pentium era through the Core 2 generation.

|Property|Detail|
|---|---|
|Topology|Shared multidrop parallel bus|
|Width|64-bit data, 32-bit address|
|Transfer mode|Quad-pumped (4 transfers per clock cycle)|
|Peak bandwidth|Up to ~12.8 GB/s (1600 MHz FSB)|
|Key limitation|All cores share one FSB to memory|

As core counts increased, the FSB became a serial bottleneck: all cores competed for one path to memory. This drove the integration of the memory controller into the CPU itself, eliminating the FSB.

---

### PCI — Peripheral Component Interconnect

PCI (1992) standardized the expansion bus, replacing ISA with a 32-bit (later 64-bit) shared parallel bus.

|Property|PCI (32-bit)|PCI-X 2.0 (64-bit)|
|---|---|---|
|Bus width|32 bits|64 bits|
|Clock|33 / 66 MHz|Up to 533 MHz|
|Peak bandwidth|133 MB/s|4.3 GB/s|
|Topology|Shared multidrop|Shared multidrop|

PCI uses a **split transaction** protocol: a master can release the bus between issuing a request and receiving data, allowing other agents to use the bus during memory latency. This improves bus utilization significantly over locked transactions.

PCI addressing distinguishes **memory space** (accessed by address) and **I/O space** (accessed via special I/O instructions on x86, e.g., `IN`/`OUT`). Configuration space provides a standardized register layout for device enumeration.

The shared multidrop topology of PCI limits scalability: high-frequency operation is impossible because signal reflections from multiple taps degrade signal integrity. This motivates PCIe's switch-based point-to-point topology.

---

### PCIe as System Interconnect

PCIe replaced PCI as the primary expansion and device interconnect. Its role in the system bus context extends beyond storage (covered in the Storage Interfaces topic) to encompass the entire peripheral fabric.

```svg
<svg viewBox="0 0 680 340" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11">
  <text x="340" y="22" text-anchor="middle" font-weight="bold" font-size="13">Modern CPU-Centric Architecture (No North Bridge)</text>

  <!-- CPU Die -->
  <rect x="200" y="40" width="280" height="140" rx="6" fill="#e3f2fd" stroke="#1565c0" stroke-width="2"/>
  <text x="340" y="60" text-anchor="middle" font-weight="bold" font-size="12" fill="#0d47a1">CPU Die</text>

  <!-- Cores -->
  <rect x="215" y="68" width="70" height="35" rx="3" fill="#90caf9" stroke="#1976d2"/>
  <text x="250" y="88" text-anchor="middle">Core 0</text>
  <rect x="295" y="68" width="70" height="35" rx="3" fill="#90caf9" stroke="#1976d2"/>
  <text x="330" y="88" text-anchor="middle">Core 1</text>
  <rect x="375" y="68" width="70" height="35" rx="3" fill="#90caf9" stroke="#1976d2"/>
  <text x="410" y="88" text-anchor="middle">Core 2</text>

  <!-- IMC -->
  <rect x="215" y="115" width="100" height="30" rx="3" fill="#1976d2" stroke="#0d47a1"/>
  <text x="265" y="134" text-anchor="middle" fill="white" font-weight="bold">IMC</text>

  <!-- PCIe Root Complex -->
  <rect x="335" y="115" width="130" height="30" rx="3" fill="#7b1fa2" stroke="#4a148c"/>
  <text x="400" y="134" text-anchor="middle" fill="white" font-weight="bold">PCIe Root Complex</text>

  <!-- DDR Channels -->
  <line x1="265" y1="145" x2="265" y2="200" stroke="#1976d2" stroke-width="2"/>
  <rect x="190" y="200" width="150" height="40" rx="4" fill="#bbdefb" stroke="#1976d2"/>
  <text x="265" y="222" text-anchor="middle" font-weight="bold">DDR5 Channel</text>
  <rect x="190" y="255" width="150" height="30" rx="4" fill="#e3f2fd" stroke="#1976d2"/>
  <text x="265" y="274" text-anchor="middle">DRAM DIMMs</text>
  <line x1="265" y1="240" x2="265" y2="255" stroke="#1976d2" stroke-width="1.5"/>

  <!-- PCIe Switch -->
  <line x1="400" y1="145" x2="400" y2="200" stroke="#7b1fa2" stroke-width="2"/>
  <rect x="330" y="200" width="140" height="35" rx="4" fill="#ce93d8" stroke="#7b1fa2"/>
  <text x="400" y="222" text-anchor="middle" font-weight="bold">PCIe Switch</text>

  <!-- GPU -->
  <line x1="360" y1="235" x2="310" y2="270" stroke="#7b1fa2" stroke-width="1.5"/>
  <rect x="240" y="270" width="80" height="30" rx="3" fill="#f3e5f5" stroke="#7b1fa2"/>
  <text x="280" y="289" text-anchor="middle">GPU x16</text>

  <!-- NVMe -->
  <line x1="400" y1="235" x2="400" y2="270" stroke="#7b1fa2" stroke-width="1.5"/>
  <rect x="355" y="270" width="90" height="30" rx="3" fill="#f3e5f5" stroke="#7b1fa2"/>
  <text x="400" y="289" text-anchor="middle">NVMe x4</text>

  <!-- Network -->
  <line x1="440" y1="235" x2="490" y2="270" stroke="#7b1fa2" stroke-width="1.5"/>
  <rect x="460" y="270" width="90" height="30" rx="3" fill="#f3e5f5" stroke="#7b1fa2"/>
  <text x="505" y="289" text-anchor="middle">NIC x4</text>

  <!-- PCH -->
  <line x1="340" y1="168" x2="120" y2="240" stroke="#e65100" stroke-width="1.5" stroke-dasharray="6,3"/>
  <rect x="30" y="240" width="120" height="40" rx="4" fill="#ffe0b2" stroke="#e65100"/>
  <text x="90" y="258" text-anchor="middle" font-weight="bold">PCH</text>
  <text x="90" y="272" text-anchor="middle">(USB/SATA/LPC)</text>

  <text x="90" y="315" text-anchor="middle" font-size="10" fill="#555">--- DMI link to CPU</text>
</svg>
```

The **Integrated Memory Controller (IMC)** inside the CPU eliminates the North Bridge bottleneck. The **PCIe Root Complex**, also inside the CPU, owns the PCIe hierarchy. The **Platform Controller Hub (PCH)** — the remnant of the South Bridge — handles legacy and lower-bandwidth I/O and connects to the CPU via **DMI (Direct Media Interface)**, which is electrically identical to PCIe.

---

### Bus Arbitration

When multiple agents share a bus, arbitration determines which agent gains access.

#### Daisy Chain (Serial Priority)

A `BUS GRANT` signal propagates from agent to agent in a fixed physical chain. The first agent in the chain that asserts `BUS REQUEST` captures the grant. Simple to implement; inherently unfair — agents early in the chain starve agents later.

```svg
<svg viewBox="0 0 680 110" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11">
  <text x="20" y="20" font-weight="bold" font-size="12">Daisy Chain Arbitration</text>

  <rect x="20" y="35" width="80" height="35" rx="4" fill="#1976d2" stroke="#0d47a1"/>
  <text x="60" y="57" text-anchor="middle" fill="white">Arbiter</text>

  <rect x="160" y="35" width="70" height="35" rx="4" fill="#c8e6c9" stroke="#388e3c"/>
  <text x="195" y="57" text-anchor="middle">Agent 0</text>
  <rect x="290" y="35" width="70" height="35" rx="4" fill="#c8e6c9" stroke="#388e3c"/>
  <text x="325" y="57" text-anchor="middle">Agent 1</text>
  <rect x="420" y="35" width="70" height="35" rx="4" fill="#c8e6c9" stroke="#388e3c"/>
  <text x="455" y="57" text-anchor="middle">Agent 2</text>
  <rect x="550" y="35" width="70" height="35" rx="4" fill="#c8e6c9" stroke="#388e3c"/>
  <text x="585" y="57" text-anchor="middle">Agent 3</text>

  <!-- GRANT chain -->
  <line x1="100" y1="47" x2="160" y2="47" stroke="#1976d2" stroke-width="2" marker-end="url(#b)"/>
  <line x1="230" y1="47" x2="290" y2="47" stroke="#1976d2" stroke-width="2" marker-end="url(#b)"/>
  <line x1="360" y1="47" x2="420" y2="47" stroke="#1976d2" stroke-width="2" marker-end="url(#b)"/>
  <line x1="490" y1="47" x2="550" y2="47" stroke="#1976d2" stroke-width="2" marker-end="url(#b)"/>

  <!-- REQUEST line -->
  <line x1="100" y1="63" x2="620" y2="63" stroke="#e65100" stroke-width="1.5"/>
  <text x="350" y="80" text-anchor="middle" fill="#e65100">BUS REQUEST (shared wired-OR)</text>

  <defs>
    <marker id="b" markerWidth="6" markerHeight="6" refX="5" refY="3" orient="auto">
      <path d="M0,0 L6,3 L0,6 Z" fill="#1976d2"/>
    </marker>
  </defs>
</svg>
```

#### Centralized Arbitration

A dedicated arbiter receives `REQ` signals from all agents and asserts `GNT` to one winner. This allows flexible priority policies:

- **Fixed priority** — highest-priority requester always wins
- **Round-robin** — rotating priority prevents starvation
- **Least recently used** — the agent that used the bus least recently wins
- **Weighted fair queuing** — agents receive bandwidth proportional to assigned weights

Centralized arbitration adds an arbiter component and requires dedicated REQ/GNT signal pairs to each agent, which does not scale to large numbers of agents.

#### Distributed Arbitration

Each agent independently observes the bus and runs the same arbitration algorithm simultaneously. Used in older VMEbus and NuBus designs. Eliminates the single arbiter point but requires careful protocol design to prevent simultaneous assertion conflicts.

---

### Split Transactions vs. Locked Transactions

**Locked (atomic) transaction:** The master holds the bus continuously from address phase through data return. Simple, but wastes bus bandwidth during memory latency.

**Split transaction:** The master issues a request and releases the bus. The target later re-arbitrates and drives the data. The bus is free during the memory access latency.

```svg
<svg viewBox="0 0 680 190" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11">
  <text x="20" y="20" font-weight="bold" font-size="12">Locked vs Split Transaction</text>

  <!-- Locked -->
  <text x="30" y="45" font-weight="bold" fill="#c62828">Locked:</text>
  <rect x="100" y="32" width="80" height="22" rx="2" fill="#ef9a9a" stroke="#c62828"/>
  <text x="140" y="47" text-anchor="middle">Addr</text>
  <rect x="180" y="32" width="200" height="22" rx="2" fill="#ffcdd2" stroke="#c62828"/>
  <text x="280" y="47" text-anchor="middle">Bus held — waiting for memory</text>
  <rect x="380" y="32" width="80" height="22" rx="2" fill="#ef9a9a" stroke="#c62828"/>
  <text x="420" y="47" text-anchor="middle">Data</text>
  <text x="490" y="47" fill="#c62828">Bus idle during wait</text>

  <!-- Split -->
  <text x="30" y="90" font-weight="bold" fill="#2e7d32">Split:</text>

  <!-- Master A request -->
  <rect x="100" y="77" width="80" height="22" rx="2" fill="#a5d6a7" stroke="#2e7d32"/>
  <text x="140" y="92" text-anchor="middle">A: Addr</text>

  <!-- Other master uses bus -->
  <rect x="180" y="77" width="90" height="22" rx="2" fill="#90caf9" stroke="#1976d2"/>
  <text x="225" y="92" text-anchor="middle">B: Addr</text>
  <rect x="270" y="77" width="90" height="22" rx="2" fill="#90caf9" stroke="#1976d2"/>
  <text x="315" y="92" text-anchor="middle">B: Data</text>

  <!-- A's data returns -->
  <rect x="360" y="77" width="100" height="22" rx="2" fill="#a5d6a7" stroke="#2e7d32"/>
  <text x="410" y="92" text-anchor="middle">A: Data return</text>

  <text x="30" y="125" fill="#2e7d32">Bus is used by other masters while A waits for memory response.</text>

  <!-- Timeline arrow -->
  <line x1="100" y1="150" x2="650" y2="150" stroke="#333" stroke-width="1.5" marker-end="url(#c)"/>
  <text x="660" y="154" fill="#333">time</text>

  <defs>
    <marker id="c" markerWidth="6" markerHeight="6" refX="5" refY="3" orient="auto">
      <path d="M0,0 L6,3 L0,6 Z" fill="#333"/>
    </marker>
  </defs>
</svg>
```

Split transactions require the master to carry a **transaction tag** (identifier) so the returning data can be matched to the original request when multiple outstanding transactions are in flight.

---

### CPU-to-CPU Interconnects

In multi-socket systems, processors themselves must communicate directly — bypassing memory for cache coherence traffic and NUMA-aware data placement. Dedicated point-to-point CPU interconnects replaced the shared FSB for this purpose.

#### HyperTransport (AMD)

HyperTransport (HT), introduced by AMD in 2001, replaced the FSB for Opteron and Athlon 64 processors. It is a high-speed, low-latency, point-to-point differential serial link operating in a daisy-chain or mesh topology.

|Property|HyperTransport 3.1|
|---|---|
|Link width|Up to 32 bits (each direction)|
|Frequency|Up to 3.2 GHz (DDR)|
|Peak bandwidth|Up to 51.2 GB/s (per direction)|
|Topology|Point-to-point, chained|

HyperTransport carries both coherence traffic and I/O transactions (it served as the I/O fabric as well as the CPU interconnect in AMD systems).

#### Intel QPI / UPI

Intel's **QuickPath Interconnect (QPI)**, introduced with the Nehalem microarchitecture (2008), replaced the FSB for multi-socket Xeon and high-end desktop platforms. Its successor, **Ultra Path Interconnect (UPI)**, is used in Skylake-SP and later Xeons.

|Property|QPI|UPI (gen 3)|
|---|---|---|
|Link type|Serial differential|Serial differential|
|Width|20 lanes each direction|20 lanes each direction|
|Transfer rate|6.4–9.6 GT/s|Up to 16 GT/s|
|Encoding|8b/10b|8b/10b / Flit|
|Peak BW (per link)|~25.6 GB/s|~41.6 GB/s|

QPI/UPI carries NUMA coherence traffic using the **MESIF** (QPI) or **MESIFS** coherence protocol, extended from MESI with Forwarding and Snoop states optimized for multi-socket operation.

```svg
<svg viewBox="0 0 680 220" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11">
  <text x="340" y="20" text-anchor="middle" font-weight="bold" font-size="13">Dual-Socket QPI/UPI Topology</text>

  <!-- Socket 0 -->
  <rect x="60" y="40" width="200" height="120" rx="6" fill="#e3f2fd" stroke="#1565c0" stroke-width="2"/>
  <text x="160" y="60" text-anchor="middle" font-weight="bold" fill="#0d47a1">Socket 0</text>
  <rect x="80" y="68" width="160" height="25" rx="3" fill="#90caf9" stroke="#1976d2"/>
  <text x="160" y="84" text-anchor="middle">Cores + LLC</text>
  <rect x="80" y="100" width="70" height="25" rx="3" fill="#1976d2" stroke="#0d47a1"/>
  <text x="115" y="116" text-anchor="middle" fill="white">IMC</text>
  <rect x="160" y="100" width="80" height="25" rx="3" fill="#7b1fa2" stroke="#4a148c"/>
  <text x="200" y="116" text-anchor="middle" fill="white">QPI/UPI</text>
  <rect x="80" y="135" width="160" height="18" rx="3" fill="#bbdefb" stroke="#1976d2"/>
  <text x="160" y="148" text-anchor="middle">Local DRAM</text>

  <!-- Socket 1 -->
  <rect x="420" y="40" width="200" height="120" rx="6" fill="#fce4ec" stroke="#c62828" stroke-width="2"/>
  <text x="520" y="60" text-anchor="middle" font-weight="bold" fill="#b71c1c">Socket 1</text>
  <rect x="440" y="68" width="160" height="25" rx="3" fill="#ef9a9a" stroke="#c62828"/>
  <text x="520" y="84" text-anchor="middle">Cores + LLC</text>
  <rect x="440" y="100" width="80" height="25" rx="3" fill="#c62828" stroke="#b71c1c"/>
  <text x="480" y="116" text-anchor="middle" fill="white">QPI/UPI</text>
  <rect x="530" y="100" width="70" height="25" rx="3" fill="#e91e63" stroke="#880e4f"/>
  <text x="565" y="116" text-anchor="middle" fill="white">IMC</text>
  <rect x="440" y="135" width="160" height="18" rx="3" fill="#fce4ec" stroke="#c62828"/>
  <text x="520" y="148" text-anchor="middle">Local DRAM</text>

  <!-- QPI Link -->
  <line x1="240" y1="113" x2="420" y2="113" stroke="#7b1fa2" stroke-width="3"/>
  <text x="330" y="107" text-anchor="middle" fill="#7b1fa2" font-weight="bold">QPI / UPI Link</text>
  <text x="330" y="130" text-anchor="middle" fill="#7b1fa2">(bidirectional)</text>

  <!-- NUMA annotation -->
  <text x="160" y="185" text-anchor="middle" fill="#1565c0" font-size="10">Local access: low latency</text>
  <text x="520" y="185" text-anchor="middle" fill="#c62828" font-size="10">Local access: low latency</text>
  <text x="330" y="200" text-anchor="middle" fill="#555" font-size="10">Remote access crosses QPI link: higher latency (NUMA)</text>
</svg>
```

---

### Address Decoding and Memory-Mapped I/O

The system bus must route each transaction to the correct agent. **Address decoding** maps address ranges to specific targets.

In modern x86 systems, the physical address space is partitioned by firmware (BIOS/UEFI) and the OS into:

|Region|Typical Use|
|---|---|
|0x00000000 – 0x0009FFFF|Conventional memory (legacy)|
|0x000A0000 – 0x000FFFFF|VGA buffer, ROM (legacy)|
|~0x00100000 – top of DRAM|Main system memory|
|Above DRAM (or in hole)|MMIO for PCIe devices, APIC, HPET|
|0xFEC00000|I/O APIC|
|0xFEE00000|Local APIC|
|0xFFFF0000|BIOS reset vector|

**Memory-mapped I/O (MMIO)** places device registers in the physical address space. A CPU load or store to an MMIO address is routed by the bus fabric to the target device rather than DRAM. The device register responds to read transactions and accepts write transactions as commands. This allows device access using normal load/store instructions rather than special I/O port instructions.

**Port-mapped I/O (PMIO)** — still used on x86 for legacy devices — uses a separate 16-bit I/O address space accessed via `IN` and `OUT` instructions. The bus distinguishes memory cycles from I/O cycles via a dedicated control signal (`M/IO#`).

---

### Bus Performance Metrics

**Bus bandwidth** — the maximum data transfer rate:

$$B = \frac{W \times f \times k}{t_{cycle}}$$

Where $W$ is bus width in bytes, $f$ is clock frequency, $k$ is transfers per cycle (1 for SDR, 2 for DDR, 4 for quad-pumped), and $t_{cycle}$ is the total transaction cycle count including overhead.

**Bus utilization** — the fraction of bus cycles spent on useful data transfer versus arbitration, address, and turnaround cycles. A split-transaction bus achieves higher utilization under load than a locked-transaction bus.

**Bus latency** — the number of cycles from transaction initiation to data availability. Pipelined buses reduce effective latency by overlapping address and data phases of successive transactions.

**Effective bandwidth under contention** — as the number of bus masters increases, contention for a shared bus reduces per-master effective bandwidth. For $N$ equal masters on a shared bus:

$$B_{effective,master} \approx \frac{B_{peak}}{N}$$

This relationship motivates point-to-point topologies with dedicated links.

---

### Transition to Modern Interconnects

The limitations of shared parallel buses drove architectural changes across three decades:

|Era|Dominant Interconnect|Key Limitation Addressed|
|---|---|---|
|1980s|ISA (8/16-bit parallel shared)|Replaced PATA, serial ports|
|1990s|PCI (32/64-bit parallel shared)|Higher bandwidth than ISA|
|Late 1990s|AGP (dedicated GPU link)|PCI contention for graphics|
|2000s|PCI Express (serial point-to-point)|Parallel bus signal integrity|
|2000s|HyperTransport / QPI|FSB bottleneck in multicore|
|2010s+|UPI, CXL, Gen-Z|Coherent memory semantics over PCIe|

**CXL (Compute Express Link)**, built on PCIe 5.0 physical layer, extends the system bus concept further: it provides cache-coherent memory semantics between CPUs and accelerators, allowing a GPU or FPGA to participate in the CPU's coherence domain and access host memory with coherent load/store semantics — effectively expanding the concept of a system bus to encompass heterogeneous memory and compute fabrics.

---

**Example**

A server with two sockets connected by UPI links executes a workload where Socket 0 cores frequently read data owned by Socket 1 DRAM. Each such read traverses the UPI link, incurring additional latency (~40–80 ns round trip across the link) compared to a local DRAM access (~60–80 ns). The system bus architecture — specifically the UPI bandwidth and latency — directly bounds the NUMA penalty. Profiling with hardware performance counters (`UNC_M_CAS_COUNT.RD` for memory accesses, `UPI_L_TxL_FLITS` for link utilization) quantifies the fraction of accesses crossing the UPI link, guiding thread and memory affinity decisions.

[Unverified: specific latency values are representative estimates from published Intel architecture documentation and vary by platform, memory configuration, and workload. Behavior is not guaranteed.]

---

**Conclusion**

System bus architecture encompasses the physical signaling, protocol, arbitration policy, address decoding, and topological organization that binds processor, memory, and I/O into a coherent system. The evolution from shared parallel buses through dedicated hub designs to point-to-point serial fabrics reflects repeated removal of bandwidth and scalability bottlenecks as CPU performance, core counts, and peripheral demands grew. The integration of memory controllers and PCIe root complexes directly into the CPU die eliminated the North Bridge as a central bottleneck, while CPU-to-CPU interconnects (HyperTransport, QPI, UPI) replaced the shared FSB to scale across sockets. Modern systems continue this trajectory with coherent fabric standards such as CXL, which extend memory-semantic bus semantics across heterogeneous compute elements.

**Next Steps**

- Interrupt controllers (PIC, APIC) — how interrupt signaling is routed through the system bus fabric and arbitrated across cores
- BIOS/UEFI and boot sequence — how the system bus is enumerated, configured, and initialized before OS control
- NUMA — how the system bus topology directly determines memory access latency asymmetry across sockets
- Cache coherence (MESI, MOESI) — how coherence traffic flows over the system bus and CPU interconnects

---

