## Chiplet and Disaggregated Design


Monolithic die scaling has approached economic and physical limits. As process nodes advance, the cost per transistor no longer falls at the historical rate, defect density on large dies reduces yield nonlinearly, and integrating disparate circuit types — logic, SRAM, analog, I/O, DRAM — on a single optimized process is increasingly inefficient. Chiplet-based and disaggregated design decomposes a processor or system into smaller, independently manufactured dies that are integrated into a single package, recovering yield, enabling heterogeneous process node selection, and allowing modular composition of complex systems.

---

### Motivation: The Monolithic Yield Problem

Die yield follows a statistical model. A widely used approximation is the **Seeds model**:

$$Y = \left(1 + \frac{D_0 \cdot A}{n}\right)^{-n}$$

where $D_0$ is defect density (defects/cm²), $A$ is die area, and $n$ is a process complexity factor. As die area grows, yield falls superlinearly. A defect anywhere on the die scraps the entire unit.

**Example:** If defect density is 0.1 defects/cm² and a monolithic die is 800 mm²:

$$Y \approx \left(1 + \frac{0.1 \times 8}{2}\right)^{-2} \approx 0.308$$

Splitting that die into four 200 mm² chiplets, each yielding independently:

$$Y_{\text{chiplet}} \approx \left(1 + \frac{0.1 \times 2}{2}\right)^{-2} \approx 0.826$$

System yield of four chiplets: $0.826^4 \approx 0.464$ — still substantially higher than 0.308, and improving further when known-good-die (KGD) testing allows defective chiplets to be discarded before assembly.

---

### Terminology

|Term|Definition|
|---|---|
|**Chiplet**|A small, self-contained die designed to be integrated with other chiplets in a multi-chip package|
|**Interposer**|A substrate (silicon, organic, or glass) that provides dense wiring between chiplets|
|**Package**|The physical enclosure that houses one or more dies and presents external pins or balls|
|**KGD (Known-Good Die)**|A chiplet that has been individually tested and confirmed functional before packaging|
|**Die-to-die (D2D) interface**|The electrical interface between chiplets within a package|
|**UCIe**|Universal Chiplet Interconnect Express — an open standard for die-to-die interfaces|
|**Disaggregation**|The architectural practice of decomposing a previously monolithic system into separate, independently sourced functional units|

---

### Chiplet Decomposition Strategies

A system can be decomposed along several axes:

#### Functional Decomposition

Separate dies for logically distinct functions: compute cores, last-level cache (LLC) / SRAM, memory controllers, I/O, analog/mixed-signal blocks, SerDes.

**Example — AMD EPYC (Genoa):**

```
┌────────────────────────────────────────────────────────┐
│                      Package                           │
│                                                        │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐         │
│  │ CCD  │ │ CCD  │ │ CCD  │ │ CCD  │ │ CCD  │  ...    │
│  │(5nm) │ │(5nm) │ │(5nm) │ │(5nm) │ │(5nm) │         │
│  └──┬───┘ └──┬───┘ └──┬───┘ └──┬───┘ └──┬───┘         │
│     └────────┴────────┴──┬─────┴────────┘             │
│                          │  Infinity Fabric            │
│                    ┌─────┴──────┐                      │
│                    │   cIOD     │                      │
│                    │ (6nm I/O)  │                      │
│                    │ MC·PCIe·IF │                      │
│                    └────────────┘                      │
└────────────────────────────────────────────────────────┘
```

- **CCD (Core Complex Die):** Contains CPU cores, L1/L2/L3 caches. Manufactured on TSMC 5nm for maximum compute density.
- **cIOD (I/O Die):** Contains memory controllers, PCIe controllers, Infinity Fabric interconnect logic. Manufactured on TSMC 6nm (a more cost-effective node for I/O-heavy circuits).

This separation allows the I/O die — which does not benefit as much from leading-edge lithography — to be manufactured on a less expensive node, while the compute die uses the most advanced process available.

#### Replication-Based Decomposition

A single compute tile design is replicated N times within a package. AMD's CCD is an example: up to 12 CCDs in a single Genoa package. Intel's GPU Max (Ponte Vecchio) replicates compute tiles.

This approach enables a product family from a single chiplet SKU: a 4-CCD package and a 12-CCD package use identical chiplets, differing only in assembly.

#### Memory Disaggregation

DRAM is integrated as a separate chiplet or stacked directly above the logic die (HBM). This separates DRAM process optimization (DRAM uses older, specialized nodes) from logic process optimization.

---

### Integration Technologies

The method of physically connecting chiplets determines bandwidth, latency, power, and cost.

#### Organic Substrate (Wire Bond / Flip-Chip)

The baseline packaging substrate. Chiplets are flip-chip bonded to an organic laminate with solder bumps. Bump pitch is typically 100–200 µm. Die-to-die bandwidth is limited by the number of bumps and the bump pitch.

- **Bandwidth density:** Low (limited by organic substrate wiring pitch ~10–20 µm)
- **Cost:** Lowest
- **Use case:** Loosely coupled multi-chip modules (MCM) where bandwidth requirements are modest

#### Silicon Interposer (2.5D Integration)

Chiplets are placed side-by-side on a passive silicon interposer. The interposer provides dense wiring between chiplets at pitches unreachable in organic substrates (2–5 µm). The entire assembly is mounted on an organic substrate for external connectivity.

```svg
<svg viewBox="0 0 420 220" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11">
  <!-- Organic substrate -->
  <rect x="20" y="160" width="380" height="40" rx="4" fill="#5a4a2a" stroke="#8a7040" stroke-width="1.5"/>
  <text x="210" y="185" text-anchor="middle" fill="#e8d090" font-size="10">Organic Substrate (Package)</text>
  <!-- Silicon interposer -->
  <rect x="50" y="110" width="320" height="45" rx="3" fill="#3a3a5c" stroke="#7070aa" stroke-width="1.5"/>
  <text x="210" y="137" text-anchor="middle" fill="#a0a0e0" font-size="10">Silicon Interposer (dense wiring, 2–5 µm pitch)</text>
  <!-- Chiplets -->
  <rect x="60" y="55" width="110" height="50" rx="4" fill="#2a6090" stroke="#4a90c0" stroke-width="2"/>
  <text x="115" y="78" text-anchor="middle" fill="white" font-size="11">Compute</text>
  <text x="115" y="93" text-anchor="middle" fill="#a0d0ff" font-size="10">Die (5nm)</text>
  <rect x="190" y="55" width="110" height="50" rx="4" fill="#2a6090" stroke="#4a90c0" stroke-width="2"/>
  <text x="245" y="78" text-anchor="middle" fill="white" font-size="11">Compute</text>
  <text x="245" y="93" text-anchor="middle" fill="#a0d0ff" font-size="10">Die (5nm)</text>
  <rect x="315" y="55" width="70" height="50" rx="4" fill="#60402a" stroke="#c07040" stroke-width="2"/>
  <text x="350" y="78" text-anchor="middle" fill="white" font-size="11">I/O</text>
  <text x="350" y="93" text-anchor="middle" fill="#ffc080" font-size="10">Die (7nm)</text>
  <!-- Micro bumps interposer to chiplets -->
  <line x1="115" y1="105" x2="115" y2="110" stroke="#aaa" stroke-width="1" stroke-dasharray="2,2"/>
  <line x1="245" y1="105" x2="245" y2="110" stroke="#aaa" stroke-width="1" stroke-dasharray="2,2"/>
  <line x1="350" y1="105" x2="350" y2="110" stroke="#aaa" stroke-width="1" stroke-dasharray="2,2"/>
  <!-- C4 bumps interposer to substrate -->
  <line x1="150" y1="155" x2="150" y2="160" stroke="#aaa" stroke-width="1" stroke-dasharray="2,2"/>
  <line x1="250" y1="155" x2="250" y2="160" stroke="#aaa" stroke-width="1" stroke-dasharray="2,2"/>
  <!-- Labels -->
  <text x="22" y="105" fill="#aaa" font-size="9">µ-bumps</text>
  <text x="22" y="158" fill="#aaa" font-size="9">C4 bumps</text>
</svg>
```

**Examples:** AMD's EPYC with HBM, Xilinx (AMD) Virtex UltraScale+ with HBM, NVIDIA H100 SXM with HBM3.

- **Bandwidth density:** High (silicon wiring density)
- **Latency:** Low within the interposer
- **Cost:** Significant — the passive silicon interposer is a large, expensive piece of silicon (though it need not be a cutting-edge node)

#### Embedded Multi-die Interconnect Bridge (EMIB) — Intel

Instead of a full-size silicon interposer, Intel embeds small silicon **bridge dies** within the organic substrate at specific chiplet-to-chiplet crossing points. Only the interface regions use dense silicon wiring; the rest of the substrate is organic.

- **Advantage:** Lower cost than a full silicon interposer; no need for TSVs through the interposer
- **Limitation:** Bridges are local — only chiplets positioned above a bridge die can communicate over the dense interconnect. Topology must be planned at package design time.
- **Example:** Intel Ponte Vecchio (GPU Max), Stratix 10 FPGA family

#### Foveros (3D Stacking) — Intel

Dies are stacked vertically. A **base die** (often a low-power I/O die on an older node) sits on the package substrate. A **top die** (compute, on a leading-edge node) is stacked directly atop the base die and communicates through **micro-bumps** at fine pitch (~10–50 µm).

Through-silicon vias (TSVs) are not required in Foveros — the top die connects to the base die through face-to-face bonding.

- **Bandwidth:** Very high — vertical connections are extremely dense
- **Thermal challenge:** Heat from the top die must dissipate through or around the bottom die, complicating thermal management
- **Example:** Intel Meteor Lake (tiled architecture: Compute Tile + SoC Tile + I/O Tile + GPU Tile stacked/integrated on a base tile)

#### Hybrid Bonding (Direct Bond Interconnect — DBI, Cu-Cu)

The most advanced integration technique. Copper pads on two die surfaces are bonded directly via thermal compression — no solder bumps. This achieves bump pitch below 1 µm (current leading edge: ~0.5–1 µm).

- **Bandwidth density:** Extremely high — an order of magnitude beyond micro-bumps
- **Power per bit:** Dramatically lower than package-level I/O
- **Use case:** DRAM-to-logic (HBM uses TSV + micro-bump; future DRAM stacking may use hybrid bonding), sensor-to-processor (image sensors), future CPU cache stacking
- **Example (2026):** [Unverified — specific production implementations beyond CMOS image sensors are not confirmed in my knowledge] research prototypes and early production for memory integration

---

### Die-to-Die Interface Standards

Proprietary die-to-die interfaces fragment the ecosystem and prevent mixing chiplets from different vendors. Standardization efforts:

#### UCIe (Universal Chiplet Interconnect Express)

Announced in 2022, backed by Intel, AMD, ARM, TSMC, Samsung, and others. Defines the physical layer, die-to-die adapter logic, and the protocol stack carried over the link (PCIe and CXL are the primary supported protocols).

|UCIe Parameter|Standard Package|Advanced Package|
|---|---|---|
|Bump pitch|100–130 µm|25–55 µm|
|Bandwidth density|~16 Gbps/mm|~385 Gbps/mm|
|Reach|Organic substrate|Silicon interposer / bridge|

UCIe enables a **chiplet ecosystem** analogous to PCIe for discrete components: a vendor can design a chiplet to the UCIe spec and integrate it with chiplets from other vendors without custom interface negotiation.

#### Competing / Complementary Standards

|Standard|Origin|Notes|
|---|---|---|
|**Infinity Fabric**|AMD|Proprietary; used within AMD products (CCD↔cIOD, die-to-die, socket-to-socket)|
|**MDFI / MCIO**|Intel|Internal mesh fabric for tile interconnect in Xeon|
|**NVLink-C2C**|NVIDIA|Used between Grace CPU and Hopper GPU in Grace Hopper Superchip; 900 GB/s bidirectional|
|**OpenHBI**|HBM consortium|For high-bandwidth memory stacking|

---

### HBM as a Chiplet-Adjacent Technology

High Bandwidth Memory (HBM) is a DRAM stack — multiple DRAM dies connected vertically through TSVs — mounted alongside the logic die on a silicon interposer. While not a chiplet in the compute sense, it exemplifies disaggregation: DRAM is manufactured on a DRAM-optimized process, logic on a logic-optimized process, and they are co-packaged.

|Generation|Bandwidth per stack|Capacity per stack|Interface width|
|---|---|---|---|
|HBM2|256 GB/s|up to 8 GB|1024-bit|
|HBM2E|460 GB/s|up to 16 GB|1024-bit|
|HBM3|819 GB/s|up to 24 GB|1024-bit|
|HBM3E|~1.2 TB/s|up to 36 GB|1024-bit|

A GPU like the NVIDIA H100 SXM integrates six HBM3 stacks on an interposer, providing ~3.35 TB/s aggregate bandwidth — bandwidth that would be physically impossible with conventional DRAM and package-edge I/O.

---

### Disaggregated System Architecture

Beyond chiplets within a package, **system-level disaggregation** separates resources that were previously co-located on a server motherboard:

#### CXL (Compute Express Link)

Built on PCIe 5.0/6.0 physical layer. Defines three protocol types:

|Protocol|Function|
|---|---|
|**CXL.io**|PCIe-compatible I/O for devices|
|**CXL.cache**|Device can cache host memory coherently|
|**CXL.mem**|Host can access device-attached memory coherently|

CXL.mem enables **memory disaggregation**: large DRAM or persistent memory pools are placed in separate CXL-attached devices (potentially in different chassis via CXL switches), accessible by multiple hosts with cache-coherent semantics. This allows:

- Servers to access more memory than physically fit in their DIMM slots
- Memory to be shared across multiple server nodes
- Memory capacity to be independently scaled from compute

#### Resource Disaggregation at Rack Scale

Data-center-scale disaggregation decouples compute, memory, storage, and accelerators as independent resource pools connected by a high-speed fabric (e.g., CXL over optical links). Software orchestration allocates resources to workloads on demand, improving utilization over fixed server configurations.

[Inference] This model is analogous to how cloud storage (S3, object storage) disaggregated persistent storage from compute over TCP/IP — CXL-class disaggregation attempts the same for DRAM latency classes. This is an architectural direction, not a claim about any specific deployed system.

---

### Design and Verification Challenges

|Challenge|Description|
|---|---|
|**KGD testing**|Each chiplet must be tested to a high confidence level before packaging; post-package defects are costly to diagnose and cannot be reworked|
|**Thermal management**|Heat generation is concentrated; stacked dies have restricted thermal paths; power density can exceed monolithic designs|
|**Signal integrity**|Die-to-die interfaces at high bandwidth must be carefully designed for impedance, crosstalk, and equalization|
|**Latency non-uniformity**|Access latency varies depending on which chiplet holds the data — creates NUMA-like effects within a single package|
|**ESD and reliability**|Exposed die edges in 2.5D configurations require careful handling and protection|
|**Software topology awareness**|The OS and runtime must understand chiplet topology (which cores share an LLC, which are on a remote CCD) to make scheduling and allocation decisions|
|**Standardization lag**|Many high-bandwidth D2D interfaces remain proprietary, limiting interoperability across vendors|

---

### Comparative Summary of Integration Approaches

|Approach|Bump pitch|BW density|Cost|Example|
|---|---|---|---|---|
|Organic MCM|100–200 µm|Low|Lowest|Early multi-chip modules|
|EMIB|55 µm (bridge)|Medium-high|Medium|Intel Ponte Vecchio|
|Silicon interposer (2.5D)|10–55 µm|High|High|AMD EPYC + HBM, Xilinx UltraScale+|
|Foveros (3D face-to-face)|10–50 µm|Very high|High|Intel Meteor Lake|
|Hybrid bonding (Cu-Cu)|<1–2 µm|Extremely high|Very high (early stage)|CMOS image sensors (production); logic [Unverified for broad production]|

---

**Key Points**

- Chiplet decomposition recovers yield losses from large monolithic dies by manufacturing smaller, independently tested units and assembling them in-package.
- Process node heterogeneity — compute on 5nm, I/O on 7nm, DRAM on specialized DRAM process — is a primary economic motivation independent of yield.
- Integration technology (organic substrate → silicon interposer → EMIB → Foveros → hybrid bonding) trades cost against bandwidth density and latency.
- UCIe is the primary open standardization effort for die-to-die interfaces; widespread multi-vendor chiplet ecosystems depend on its adoption.
- CXL extends disaggregation beyond the package to the system and rack level, enabling coherent memory pooling across nodes.
- Intra-package NUMA effects from chiplet topology must be visible to the OS and runtime scheduler to avoid latency penalties.

**Next Steps**

The natural continuations are **NUMA architecture and memory consistency** (Module 11) for the software-facing consequences of non-uniform intra-package topology, **HBM and DDR memory systems** (Module 8) for memory bandwidth and latency analysis, and **Power and Thermal Management / DVFS** (Module 12) for the thermal constraints that chiplet stacking intensifies.

---

