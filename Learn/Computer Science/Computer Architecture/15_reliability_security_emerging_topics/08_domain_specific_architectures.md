## Domain-Specific Architectures


Domain-specific architectures (DSAs) are processors designed to execute a narrow, well-defined class of computations with efficiency that general-purpose processors cannot match. Rather than providing flexible instruction sets and complex microarchitectural machinery to handle arbitrary workloads, DSAs expose the structure of a target computation directly in silicon — eliminating the overhead of instruction decode, general-purpose control flow, and cache hierarchies optimized for pointer-chasing rather than streaming arithmetic. The result is orders-of-magnitude improvement in energy efficiency and throughput for the target domain, at the cost of inflexibility outside it.

---

### Motivation: The Efficiency Gap

A general-purpose CPU core expends the majority of its die area and power budget on mechanisms that serve flexibility: out-of-order execution engines, branch predictors, large register files, TLB hierarchies, and instruction decoders. For a narrow computation executed billions of times per second, these mechanisms are pure overhead.

The roofline model makes this precise. A computation's arithmetic intensity — operations per byte of memory traffic — determines whether it is compute-bound or memory-bound. DSAs are designed to push the roofline ceiling upward (more compute per area) and move the memory wall rightward (wider, more structured data movement), specifically for the arithmetic intensities characteristic of their target domain.

```
Efficiency gap example — 8-bit matrix multiply:

  CPU (single core, scalar):   ~10 GOPS/W
  CPU (AVX-512 vectorized):    ~100 GOPS/W
  GPU (tensor cores):          ~1,000 GOPS/W
  TPU v1 (systolic array):     ~10,000 GOPS/W
  Custom ASIC (INT8):          ~100,000 GOPS/W
```

The gap is not primarily clock speed — it is elimination of architectural overhead and co-design of the datapath with the algorithm's data flow.

---

### Taxonomy of Domain-Specific Approaches

```
Domain-Specific Architectures
│
├── Fixed-function (fully custom silicon)
│   ├── ASIC — Application-Specific Integrated Circuit
│   │         Fixed forever at tape-out; highest efficiency
│   └── TPU / NPU — ML-targeted ASICs
│                   Fixed datapath, programmable mapping
│
└── Reconfigurable (programmable fabric)
    └── FPGA — Field-Programmable Gate Array
              Configurable at runtime; intermediate efficiency
```

The central trade-off across all DSA types is the **flexibility–efficiency frontier**:

<svg viewBox="0 0 540 240" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <defs> <marker id="ta" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#888"/> </marker> </defs> <line x1="60" y1="200" x2="500" y2="200" stroke="#888" stroke-width="1.5" marker-end="url(#ta)"/> <line x1="60" y1="200" x2="60" y2="30" stroke="#888" stroke-width="1.5" marker-end="url(#ta)"/> <text x="505" y="204" fill="#aaa" font-size="11">Flexibility</text> <text x="18" y="50" fill="#aaa" font-size="10" transform="rotate(-90,30,120)">Efficiency</text> <!-- Frontier curve -->

<path d="M 90,45 Q 200,60 310,120 Q 390,165 470,195" fill="none" stroke="#4caf88" stroke-width="2" stroke-dasharray="6,3"/>

<!-- Architecture points --> <!-- ASIC --> <circle cx="100" cy="48" r="7" fill="#e07b54"/> <text x="112" y="45" fill="#e07b54" font-size="11" font-weight="bold">ASIC</text> <text x="112" y="58" fill="#888" font-size="10">Max efficiency, zero flex</text> <!-- TPU/NPU --> <circle cx="185" cy="68" r="7" fill="#c06030"/> <text x="197" y="65" fill="#c06030" font-size="11" font-weight="bold">TPU / NPU</text> <text x="197" y="78" fill="#888" font-size="10">ML ops fixed, model flexible</text> <!-- FPGA --> <circle cx="310" cy="120" r="7" fill="#7c6fcd"/> <text x="322" y="117" fill="#7c6fcd" font-size="11" font-weight="bold">FPGA</text> <text x="322" y="130" fill="#888" font-size="10">Reconfigurable logic</text> <!-- GPU --> <circle cx="390" cy="158" r="7" fill="#4caf88"/> <text x="402" y="155" fill="#4caf88" font-size="11" font-weight="bold">GPU</text> <text x="402" y="168" fill="#888" font-size="10">SIMT parallel, programmable</text> <!-- CPU --> <circle cx="458" cy="192" r="7" fill="#aaa"/> <text x="430" y="185" fill="#aaa" font-size="11" font-weight="bold">CPU</text> </svg>

---

### TPU — Tensor Processing Unit

#### Design Philosophy

Google's TPU is the most influential public example of a neural-network ASIC. Its central observation is that neural network inference (and training) reduce overwhelmingly to **matrix multiply and convolution**, and that these operations have high arithmetic intensity if batched correctly — making them compute-bound rather than memory-bound. The TPU eliminates everything a GPU or CPU provides for workloads outside this class.

#### Systolic Array Architecture

The core computational structure is a **systolic array**: a two-dimensional grid of multiply-accumulate (MAC) units that rhythmically pass data between neighbors without accessing shared memory on every operation.

<svg viewBox="0 0 560 340" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <defs> <marker id="sy" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#7c6fcd"/> </marker> <marker id="sw" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#e07b54"/> </marker> <marker id="sd" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#4caf88"/> </marker> </defs> <!-- Title annotations -->

<text x="30" y="18" fill="#7c6fcd" font-size="11">← Activations flow right (A columns)</text> <text x="210" y="18" fill="#e07b54" font-size="11"> Weights flow down (W rows) ↓</text>

<!-- 4x4 systolic array --> <!-- Row 0 --> <rect x="80" y="40" width="50" height="50" rx="4" fill="#1e2a3a" stroke="#4caf88" stroke-width="1.5"/> <text x="105" y="60" fill="#4caf88" text-anchor="middle" font-size="10">MAC</text> <text x="105" y="74" fill="#888" text-anchor="middle" font-size="9">[0,0]</text> <rect x="180" y="40" width="50" height="50" rx="4" fill="#1e2a3a" stroke="#4caf88" stroke-width="1.5"/> <text x="205" y="60" fill="#4caf88" text-anchor="middle" font-size="10">MAC</text> <text x="205" y="74" fill="#888" text-anchor="middle" font-size="9">[0,1]</text> <rect x="280" y="40" width="50" height="50" rx="4" fill="#1e2a3a" stroke="#4caf88" stroke-width="1.5"/> <text x="305" y="60" fill="#4caf88" text-anchor="middle" font-size="10">MAC</text> <text x="305" y="74" fill="#888" text-anchor="middle" font-size="9">[0,2]</text> <rect x="380" y="40" width="50" height="50" rx="4" fill="#1e2a3a" stroke="#4caf88" stroke-width="1.5"/> <text x="405" y="60" fill="#4caf88" text-anchor="middle" font-size="10">MAC</text> <text x="405" y="74" fill="#888" text-anchor="middle" font-size="9">[0,3]</text> <!-- Row 1 --> <rect x="80" y="140" width="50" height="50" rx="4" fill="#1e2a3a" stroke="#4caf88" stroke-width="1.5"/> <text x="105" y="160" fill="#4caf88" text-anchor="middle" font-size="10">MAC</text> <text x="105" y="174" fill="#888" text-anchor="middle" font-size="9">[1,0]</text> <rect x="180" y="140" width="50" height="50" rx="4" fill="#1e2a3a" stroke="#4caf88" stroke-width="1.5"/> <text x="205" y="160" fill="#4caf88" text-anchor="middle" font-size="10">MAC</text> <text x="205" y="174" fill="#888" text-anchor="middle" font-size="9">[1,1]</text> <rect x="280" y="140" width="50" height="50" rx="4" fill="#1e2a3a" stroke="#4caf88" stroke-width="1.5"/> <text x="305" y="160" fill="#4caf88" text-anchor="middle" font-size="10">MAC</text> <text x="305" y="174" fill="#888" text-anchor="middle" font-size="9">[1,2]</text> <rect x="380" y="140" width="50" height="50" rx="4" fill="#1e2a3a" stroke="#4caf88" stroke-width="1.5"/> <text x="405" y="160" fill="#4caf88" text-anchor="middle" font-size="10">MAC</text> <text x="405" y="174" fill="#888" text-anchor="middle" font-size="9">[1,3]</text> <!-- Row 2 --> <rect x="80" y="240" width="50" height="50" rx="4" fill="#1e2a3a" stroke="#4caf88" stroke-width="1.5"/> <text x="105" y="260" fill="#4caf88" text-anchor="middle" font-size="10">MAC</text> <text x="105" y="274" fill="#888" text-anchor="middle" font-size="9">[2,0]</text> <rect x="180" y="240" width="50" height="50" rx="4" fill="#1e2a3a" stroke="#4caf88" stroke-width="1.5"/> <text x="205" y="260" fill="#4caf88" text-anchor="middle" font-size="10">MAC</text> <text x="205" y="274" fill="#888" text-anchor="middle" font-size="9">[2,1]</text> <rect x="280" y="240" width="50" height="50" rx="4" fill="#1e2a3a" stroke="#4caf88" stroke-width="1.5"/> <text x="305" y="260" fill="#4caf88" text-anchor="middle" font-size="10">MAC</text> <text x="305" y="274" fill="#888" text-anchor="middle" font-size="9">[2,2]</text> <rect x="380" y="240" width="50" height="50" rx="4" fill="#1e2a3a" stroke="#4caf88" stroke-width="1.5"/> <text x="405" y="260" fill="#4caf88" text-anchor="middle" font-size="10">MAC</text> <text x="405" y="274" fill="#888" text-anchor="middle" font-size="9">[2,3]</text> <!-- Horizontal flow arrows (activations, purple) --> <!-- Row 0 --> <line x1="30" y1="65" x2="78" y2="65" stroke="#7c6fcd" stroke-width="1.5" marker-end="url(#sy)"/> <line x1="130" y1="65" x2="178" y2="65" stroke="#7c6fcd" stroke-width="1.5" marker-end="url(#sy)"/> <line x1="230" y1="65" x2="278" y2="65" stroke="#7c6fcd" stroke-width="1.5" marker-end="url(#sy)"/> <line x1="330" y1="65" x2="378" y2="65" stroke="#7c6fcd" stroke-width="1.5" marker-end="url(#sy)"/> <!-- Row 1 --> <line x1="30" y1="165" x2="78" y2="165" stroke="#7c6fcd" stroke-width="1.5" marker-end="url(#sy)"/> <line x1="130" y1="165" x2="178" y2="165" stroke="#7c6fcd" stroke-width="1.5" marker-end="url(#sy)"/> <line x1="230" y1="165" x2="278" y2="165" stroke="#7c6fcd" stroke-width="1.5" marker-end="url(#sy)"/> <line x1="330" y1="165" x2="378" y2="165" stroke="#7c6fcd" stroke-width="1.5" marker-end="url(#sy)"/> <!-- Row 2 --> <line x1="30" y1="265" x2="78" y2="265" stroke="#7c6fcd" stroke-width="1.5" marker-end="url(#sy)"/> <line x1="130" y1="265" x2="178" y2="265" stroke="#7c6fcd" stroke-width="1.5" marker-end="url(#sy)"/> <line x1="230" y1="265" x2="278" y2="265" stroke="#7c6fcd" stroke-width="1.5" marker-end="url(#sy)"/> <line x1="330" y1="265" x2="378" y2="265" stroke="#7c6fcd" stroke-width="1.5" marker-end="url(#sy)"/> <!-- Vertical flow arrows (weights, orange) --> <!-- Col 0 --> <line x1="105" y1="20" x2="105" y2="38" stroke="#e07b54" stroke-width="1.5" marker-end="url(#sw)"/> <line x1="105" y1="90" x2="105" y2="138" stroke="#e07b54" stroke-width="1.5" marker-end="url(#sw)"/> <line x1="105" y1="190" x2="105" y2="238" stroke="#e07b54" stroke-width="1.5" marker-end="url(#sw)"/> <!-- Col 1 --> <line x1="205" y1="20" x2="205" y2="38" stroke="#e07b54" stroke-width="1.5" marker-end="url(#sw)"/> <line x1="205" y1="90" x2="205" y2="138" stroke="#e07b54" stroke-width="1.5" marker-end="url(#sw)"/> <line x1="205" y1="190" x2="205" y2="238" stroke="#e07b54" stroke-width="1.5" marker-end="url(#sw)"/> <!-- Col 2 --> <line x1="305" y1="20" x2="305" y2="38" stroke="#e07b54" stroke-width="1.5" marker-end="url(#sw)"/> <line x1="305" y1="90" x2="305" y2="138" stroke="#e07b54" stroke-width="1.5" marker-end="url(#sw)"/> <line x1="305" y1="190" x2="305" y2="238" stroke="#e07b54" stroke-width="1.5" marker-end="url(#sw)"/> <!-- Col 3 --> <line x1="405" y1="20" x2="405" y2="38" stroke="#e07b54" stroke-width="1.5" marker-end="url(#sw)"/> <line x1="405" y1="90" x2="405" y2="138" stroke="#e07b54" stroke-width="1.5" marker-end="url(#sw)"/> <line x1="405" y1="190" x2="405" y2="238" stroke="#e07b54" stroke-width="1.5" marker-end="url(#sw)"/> <!-- Output annotation -->

<text x="450" y="300" fill="#a0c4a0" font-size="10">Partial sums</text> <text x="450" y="313" fill="#a0c4a0" font-size="10">accumulate ↓</text> <text x="450" y="326" fill="#888" font-size="10">→ result matrix</text> </svg>

In a weight-stationary systolic array:

- **Weights** are preloaded into MAC registers and remain stationary.
- **Activations** enter from the left edge and propagate rightward one cell per cycle.
- Each MAC computes `acc += activation × weight` and passes the activation to its right neighbor.
- **Partial sums** flow downward, accumulating through each row.

The critical property is **data reuse without memory bandwidth**: each weight is loaded once and participates in every activation that passes through its cell. For an N×N array computing an N×N matrix multiply, memory bandwidth requirement is O(N²) for weights fetched once, while compute is O(N³) — arithmetic intensity scales as O(N).

#### TPU v1 Architecture

```
TPU v1 Key Dimensions:
  Matrix Multiply Unit:  256 × 256 systolic array (65,536 MACs)
  Precision:             8-bit integer (INT8)
  Peak throughput:       92 TOPS
  On-chip memory:        28 MB unified buffer (activation staging)
  Weight FIFO:           feeds weights into systolic array
  Host interface:        PCIe (acts as coprocessor to CPU host)
  Activation functions:  hardwired (ReLU, sigmoid, tanh)
  Instruction set:       CISC-like, ~12 high-level instructions
```

The instruction set reflects the DSA philosophy: instructions are coarse-grained operations (`MatrixMultiply`, `Convolve`, `Activate`, `NormalizePool`) that each trigger thousands of underlying MAC operations. A single `MatrixMultiply` instruction on a 256×256 array performs 256³ = ~16.7 million multiply-accumulate operations.

#### TPU Evolution

|Generation|Year|Key Addition|Precision|Scale|
|---|---|---|---|---|
|TPU v1|2016|Inference only; systolic array|INT8|Single chip|
|TPU v2|2017|Training support; HBM; liquid cooling|BF16|4-chip pod|
|TPU v3|2018|Higher clock; larger HBM|BF16|64-chip pod|
|TPU v4|2021|3D torus interconnect; sparsity|BF16/INT8|4096-chip pod|
|TPU v5e/p|2023|Inference/training split; SparseCore|INT8/BF16|Scalable|

The progression reveals a pattern common to ML ASICs: the first generation targets inference (fixed weights, repeated activation passes); subsequent generations add training (gradient computation, optimizer state), require higher precision (BF16 to preserve gradient fidelity), and scale the interconnect to support model parallelism across chips.

---

### NPU — Neural Processing Unit

#### Distinction from TPU

The term NPU is used loosely but typically refers to ML inference accelerators embedded in SoCs — mobile, edge, and client processors — rather than datacenter-scale standalone chips. The architectural principles overlap significantly with TPUs, but the design constraints differ sharply:

||TPU|NPU (edge/mobile)|
|---|---|---|
|Power budget|200–600 W (server)|0.5–5 W|
|Memory|HBM, tens of GB|SRAM on-die, shared LPDDR|
|Target workload|Large model training/inference|Quantized inference only|
|Precision|BF16, INT8|INT4, INT8, sometimes FP16|
|Programmability|XLA compiler stack|Vendor SDK (CoreML, NNAPI, QNN)|
|Integration|PCIe coprocessor or standalone|SoC tile alongside CPU/GPU|

#### Representative NPU Architectures

**Apple Neural Engine (ANE):** Integrated into every Apple Silicon SoC (A11 onward, M-series). The ANE is a fixed-function matrix accelerator with direct DMA access to shared LPDDR memory. On M2, it delivers 15.8 TOPS at a power envelope far below the GPU. Models are compiled offline by Core ML into ANE-executable binary blobs; the ISA is not publicly documented.

**Qualcomm Hexagon NPU:** Part of the Snapdragon AI Engine, which includes the Hexagon DSP scalar core, HVX (Hexagon Vector eXtensions) for SIMD, and a dedicated Tensor Accelerator (HTA) for matrix operations. The Hexagon architecture is unusual in exposing a programmable DSP alongside the fixed-function accelerator, allowing custom preprocessing kernels.

**Google Pixel Neural Core:** Derived from TPU lineage, designed specifically for on-device inference of Google's own models (speech, camera, assistant). Uses INT8 quantized inference with a compiler that maps TensorFlow Lite graphs onto the accelerator's dataflow.

**Intel NPU (Meteor Lake):** Distinct tile in Intel's disaggregated Meteor Lake die. Uses a grid of processing elements called SHAVE (Streaming Hybrid Architecture Vector Engine) cores. Explicitly designed to offload always-on tasks (wake word, noise cancellation) from the CPU and GPU at milliwatt power levels.

#### Dataflow Architectures in NPUs

Many NPUs implement **dataflow execution** rather than the instruction-fetch-decode cycle of von Neumann machines. In a dataflow model, a computation is expressed as a directed acyclic graph (DAG); each node fires when all its input operands are available, without a central program counter orchestrating sequencing.

```
Dataflow DAG (simplified transformer block):

  [Input Tokens]
       │
  [LayerNorm] ──────────────────────────────────┐
       │                                         │
  [QKV Linear]                             [Residual]
       │                                         │
  [Attention]                                    │
       │                                         │
  [Projection] ────────────────────────── [Add & Norm]
                                                 │
                                           [FFN Block]
                                                 │
                                           [Output]

Each node mapped to a PE; data flows along edges.
No instruction fetch per-operation — topology IS the program.
```

Dataflow is efficient when the graph is statically known (as in inference of a fixed model architecture) because the compiler can schedule all data movement at compile time, eliminating runtime control overhead entirely.

---

### FPGA — Field-Programmable Gate Array

#### Architecture

An FPGA is not a fixed processor — it is a fabric of reconfigurable logic elements that can be wired together to implement any digital circuit, including custom processors, datapaths, and state machines. The three fundamental components are:

**1. Configurable Logic Blocks (CLBs):** Each CLB contains look-up tables (LUTs), flip-flops, and carry chains. An n-input LUT implements any Boolean function of n variables by storing all 2ⁿ output values in a small SRAM. Modern FPGAs use 6-input LUTs as the base primitive.

**2. Programmable Interconnect:** A hierarchical mesh of routing channels and programmable switches connecting CLBs. The interconnect fabric consumes the majority of FPGA die area (~60–70%) and is the primary source of latency and power overhead versus ASICs.

**3. Hard IP Blocks:** Fixed-function circuits embedded in the fabric for efficiency: DSP slices (multiply-accumulate units), block RAM (BRAM), PCIe controllers, high-speed transceivers, and on modern devices, hard processor systems (ARM cores on Xilinx Zynq / Intel Agilex).

```
FPGA Internal Structure (simplified tile):

┌──────────────────────────────────────────────┐
│                  Interconnect Fabric          │
│  ┌───────┐    ┌───────┐    ┌───────────────┐ │
│  │  CLB  │────│  CLB  │    │   DSP Slice   │ │
│  │ 6-LUT │    │ 6-LUT │    │  (18×18 MAC)  │ │
│  │  FF   │    │  FF   │    └───────────────┘ │
│  └───────┘    └───────┘                       │
│  ┌───────┐    ┌───────┐    ┌───────────────┐ │
│  │  CLB  │    │  CLB  │    │   Block RAM   │ │
│  │ 6-LUT │    │ 6-LUT │    │  (36 Kb dual  │ │
│  │  FF   │    │  FF   │    │   port SRAM)  │ │
│  └───────┘    └───────┘    └───────────────┘ │
└──────────────────────────────────────────────┘
```

#### Configuration and Bitstream

An FPGA is configured by loading a **bitstream** — a binary file that programs every LUT, flip-flop, and routing switch in the fabric. The bitstream is generated by a synthesis and place-and-route toolchain (Xilinx Vivado, Intel Quartus) from RTL (Verilog, VHDL, or high-level synthesis source). Configuration takes milliseconds to seconds depending on device size and interface speed (JTAG, SPI, PCIe).

**Partial reconfiguration** allows regions of the fabric to be reprogrammed while other regions continue executing — enabling runtime adaptation, for example swapping a different neural network layer accelerator into a fixed communications pipeline.

#### HLS: High-Level Synthesis

Traditionally, FPGA design required cycle-accurate RTL — a high barrier to entry for software engineers. High-Level Synthesis (HLS) tools (Xilinx Vitis HLS, Intel oneAPI, Bambu) compile C/C++ or OpenCL into RTL automatically, handling pipelining, memory partitioning, and loop unrolling.

**Key Points:**

- HLS quality is sensitive to code structure. Pointer aliasing, irregular memory access, and data-dependent control flow resist efficient synthesis.
- Directives (`#pragma HLS pipeline`, `#pragma HLS unroll`) guide the tool to produce pipelined and parallel datapaths without manual RTL.
- The resulting circuit is spatially parallel rather than temporally multiplexed: different loop iterations execute in different pipeline stages simultaneously, achieving initiation interval (II) of 1 cycle per iteration in the ideal case.

#### FPGA vs. ASIC Efficiency

The programmable interconnect imposes a consistent overhead relative to equivalent ASIC logic:

|Metric|FPGA|ASIC (equivalent function)|
|---|---|---|
|Clock frequency|~200–500 MHz typical|~1–3 GHz|
|Area efficiency|~10–30× worse|Baseline|
|Power efficiency|~5–15× worse|Baseline|
|NRE cost|~$0 (use existing device)|$5M–$100M+|
|Time to market|Days–weeks|12–24 months|

The inefficiency of FPGAs is the price of reconfigurability. For low-volume production, prototyping, and rapidly evolving algorithms (early-stage ML inference, network packet processing with changing protocols), FPGAs offer better economics than ASICs despite the efficiency penalty.

#### FPGA Deployment Examples

**Microsoft Catapult (Azure):** FPGAs inserted between NIC and network stack on every server in Azure, initially for Bing ranking acceleration. Later repurposed for network packet processing (SmartNIC functions), ML inference, and encryption offload — all without changing hardware. The same physical FPGA serves different functions in different configurations.

**Xilinx Alveo (AMD):** PCIe accelerator cards used for video transcoding (H.264/H.265 encode pipelines in broadcast infrastructure), database query acceleration (Xilinx Vitis Database library implements hash joins, aggregation, and bloom filters in fabric), and financial trading (FPGA-based order matching with sub-microsecond latency that CPUs cannot achieve).

**Intel Agilex for 5G:** FPGAs implement the physical layer (FEC encoding, beamforming, FFT) of 5G base stations, where standards evolve faster than ASIC design cycles and multiple radio standards (LTE, NR, mmWave) must coexist.

---

### ASIC — Application-Specific Integrated Circuit

#### What Makes an ASIC

An ASIC is a chip designed, fabricated, and permanently fixed to implement one specific function or family of functions. Every transistor is committed at tape-out. The design process involves:

```
ASIC Design Flow:

  Specification
       │
  RTL Design (Verilog/VHDL)
       │
  Functional Simulation
       │
  Logic Synthesis  ← Technology library (standard cells)
       │
  Static Timing Analysis (STA)
       │
  Floorplanning / Place & Route
       │
  Physical Verification (DRC, LVS)
       │
  Tape-out → Foundry (TSMC, Samsung, GF)
       │
  Silicon back (12–24 weeks)
       │
  Bring-up / Characterization
```

The non-recurring engineering (NRE) cost — mask sets, EDA tool licenses, engineering time — ranges from $5M at mature nodes (28 nm) to over $500M at leading edge (3 nm). This cost is amortized over production volume; an ASIC becomes economically justified at roughly 10,000–100,000 units depending on node and complexity.

#### Efficiency Sources

ASICs achieve their efficiency advantage through mechanisms unavailable to programmable architectures:

**Custom datapaths:** The bit width of every bus, adder, and register is exactly matched to the computation's requirements. An 8-bit multiplier for INT8 inference uses exactly 8-bit wiring; no hardware is wasted maintaining 64-bit path width.

**Eliminated control logic:** No instruction fetch, decode, or scheduling hardware. The control flow is baked into the circuit topology.

**Optimized memory hierarchy:** SRAM can be sized and banked precisely for access patterns of the algorithm — no cache misses against irregular workloads, no tag arrays, no coherence hardware.

**Technology node optimization:** Custom standard cell libraries with multiple V_th variants allow fine-grained power/performance trading at cell level. High-V_th cells in non-critical paths reduce leakage; low-V_th on the critical path maximizes speed.

**Physical optimization:** Clock tree synthesis, power grid design, and cell placement are co-optimized with the specific logic, reducing clock skew and IR drop beyond what a generic chip achieves.

#### Case Study: Bitcoin ASIC (SHA-256 Mining)

The bitcoin mining ASIC is the most extreme real-world example of DSA specialization. The entire chip implements one function: compute SHA-256 twice in a loop, checking if the output meets a difficulty target.

```
SHA-256 double-hash inner loop — unrolled 64 rounds per hash:

  Each round: Ch, Maj, Σ₀, Σ₁ = fixed Boolean functions
              W[t] = schedule function of prior words
              T₁ = h + Σ₁(e) + Ch(e,f,g) + K[t] + W[t]
              T₂ = Σ₀(a) + Maj(a,b,c)

An ASIC unrolls all 64 rounds spatially as a pipeline.
One hash completes every clock cycle once the pipeline fills.
Throughput: 100–200 TH/s per chip (TSMC 5 nm, 2023)
vs. CPU: ~50 MH/s — a 2,000,000× advantage.
```

The efficiency comes from the complete absence of generality: no branches, no memory hierarchy (all constants hardwired), no programmable registers — just a deep combinational pipeline implementing exactly SHA-256.

#### Cryptographic ASICs Beyond Mining

The same principle applies to other cryptographic accelerators: AES engines implement the 10/12/14-round AES-NI as a fixed pipeline; the CPU instruction `VAES*` is itself a small ASIC embedded within a general-purpose core. Network ASICs (Broadcom Tomahawk, Cisco Silicon One) implement packet forwarding at terabit rates by hardwiring forwarding table lookup, header modification, and buffer management as fixed hardware rather than software running on embedded CPUs.

---

### Comparative Architecture Analysis

#### Computational Model

|Architecture|Execution Model|Parallelism Exposed|Control|
|---|---|---|---|
|TPU|Systolic dataflow|Spatial (MAC array)|Compiler-scheduled|
|NPU|Dataflow graph|Spatial + pipeline|Static graph mapping|
|FPGA|Spatial pipeline|Spatial + temporal|Custom finite state machines|
|ASIC|Fixed circuit|Fully spatial|Hardwired logic|

#### Memory Architecture

The memory hierarchy of DSAs reflects their workload's access patterns rather than general-purpose cache behavior:

```
TPU v4 Memory Hierarchy:
  ┌─────────────────────────────────────────┐
  │  Systolic Array Registers               │ ~0 pJ/op (local)
  │  (weight stationary, no explicit store) │
  ├─────────────────────────────────────────┤
  │  Vector Memory (VMEM) — on-chip SRAM    │ ~1 pJ/op
  │  ~16–32 MB per chip                     │
  ├─────────────────────────────────────────┤
  │  HBM (High Bandwidth Memory)            │ ~10 pJ/op
  │  ~32 GB, ~1 TB/s bandwidth              │
  ├─────────────────────────────────────────┤
  │  Inter-chip network (ICI / 3D torus)    │ ~50 pJ/bit
  │  for model / data parallelism across    │
  │  thousands of chips                     │
  └─────────────────────────────────────────┘
```

The energy per operation grows by roughly 10× at each memory level — the primary motivation for on-chip buffering and weight-stationary execution is to keep as many operations as possible at the register/SRAM level.

#### Programming Model

```
Programmability Stack:

  User Code (Python / C++)
       │
  ML Framework (JAX, PyTorch, TensorFlow)
       │
  Compiler (XLA, TVM, MLIR)       ← Primary abstraction boundary
       │
  ISA / Runtime
  ├── TPU: XLA → HLO → LLO → TPU binary
  ├── NPU: Core ML / NNAPI / QNN model compiler
  ├── FPGA: HLS → RTL → bitstream (Vivado/Quartus)
  └── ASIC: fixed; no runtime programmability
```

TPUs and NPUs present a **graph-level ISA**: the programmer never writes instructions; the compiler lowers a computational graph to the hardware. FPGAs present a **circuit-level abstraction**: the programmer describes hardware behavior in RTL or HLS, and the toolchain produces a circuit. ASICs have no programming model at runtime — the function is the chip.

---

### Design Trade-offs and Selection Criteria

#### When to Use Each

```
Decision framework:

  Is the algorithm fully defined and stable?
  ├── No (evolving standard, research) → FPGA
  └── Yes
       │
       Is volume high enough to amortize NRE?
       ├── No (<10K units) → FPGA or merchant ASIC
       └── Yes
            │
            Is the domain ML inference/training?
            ├── Yes → TPU (datacenter) / NPU (edge)
            └── No (custom signal processing, crypto,
                    networking, compression)
                     → Custom ASIC
```

#### Power–Performance–Area (PPA) Triangle

Every DSA design navigates three competing objectives simultaneously:

**Power:** Dominated by switching activity (dynamic) and leakage (static). Quantization (INT8, INT4, FP8) reduces operand width, shrinking multiplier area and switching energy quadratically. Sparsity exploitation (skipping zero activations/weights) reduces switching activity proportionally to sparsity ratio.

**Performance:** Determined by parallelism degree (array size), clock frequency (critical path length), and memory bandwidth (data supply rate). Performance bottlenecks shift as dimensions scale — a 256×256 systolic array at 1 GHz requires 256 GB/s of activation bandwidth to remain compute-bound.

**Area:** Constrains on-chip memory capacity and compute array size. SRAM is the largest area consumer in most ML ASICs — a 32 MB SRAM at 7 nm occupies roughly 16 mm².

**Key Points:**

- Quantization is the single most impactful optimization across all DSA types: halving bit width quarters multiplier area and halves weight memory.
- Sparsity acceleration (NVIDIA Ampere 2:4 structured sparsity, Google SparseCore in TPU v4) doubles effective compute by skipping known-zero operations, but requires sparsity in the model — not guaranteed for all architectures.
- The roofline ceiling for a DSA is set at design time; if a new model architecture has lower arithmetic intensity than the chip was designed for, it will be memory-bandwidth-bound regardless of compute capacity.

---

### Emerging Directions

**Chiplet-based DSAs:** Disaggregating a monolithic ASIC into multiple chiplets connected via high-bandwidth die-to-die interconnects (UCIe, BoW) allows mixing logic from different foundries and nodes. A TPU-like chip might integrate a logic chiplet at TSMC 3 nm with HBM stacked on a silicon interposer, combining leading-edge compute with high-density DRAM without requiring both on one reticle.

**Analog and near-memory compute:** Analog in-memory computing performs matrix-vector multiply directly in SRAM or ReRAM crossbar arrays using Ohm's law and Kirchhoff's current law. Each crossbar intersection is a conductance; input voltages multiply by conductance values simultaneously. This eliminates the digital memory wall entirely for weight access, at the cost of noise, precision limits, and process variation challenges.

**Reconfigurable DSAs:** Architectures like MIT's Eyeriss and Stanford's SCNN provide configurable dataflow — the same chip can switch between weight-stationary, output-stationary, and row-stationary execution depending on layer dimensions. This addresses the brittleness of fully fixed datapaths when model architectures evolve.

**Sparse and irregular computation:** Transformers with attention mechanisms exhibit quadratic attention complexity and irregular sparsity patterns that neither systolic arrays nor GPUs handle efficiently. Dedicated attention accelerators (MIT's SpAtten, Stanford's Spatten) exploit dynamic sparsity in attention weights to skip computation, requiring content-addressable memory structures and dynamic scheduling unavailable in current TPUs.

---

**Conclusion:** TPUs, NPUs, FPGAs, and ASICs represent four points along the flexibility–efficiency frontier, each suited to a different combination of algorithmic stability, production volume, power budget, and time-to-market constraints. The architectural principles underlying all four — eliminating control overhead, matching memory hierarchy to access pattern, maximizing data reuse, and exploiting domain-specific numerical structure — reflect a unified design philosophy: that efficiency is recovered by removing generality that the target computation does not require. As general-purpose scaling decelerates beyond the end of Dennard scaling, domain-specific architecture has become the primary mechanism by which the semiconductor industry continues to deliver improvements in computational efficiency.

**Next Steps:** Proceed to **Neuromorphic Computing** for an architectural approach that departs from the von Neumann model at a deeper level than DSAs — targeting sparse, event-driven computation modeled on biological neural circuits — or revisit **GPU Architecture Fundamentals** to examine how the SIMT execution model positions GPUs between the flexibility of CPUs and the efficiency of TPUs on the DSA spectrum.

---
