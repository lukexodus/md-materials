## Photonic and Approximate Computing


These are two architecturally distinct responses to the same underlying pressure: conventional CMOS scaling no longer delivers the power-performance improvements it once did. Photonic computing attacks the interconnect and analog computation bottleneck by replacing electrons with photons. Approximate computing attacks the energy-per-operation bottleneck by relaxing the correctness guarantee that digital logic has always treated as inviolable. They are covered together here because both represent departures from the foundational assumptions of the preceding modules — not incremental refinements of existing architecture.

---

### Part I — Photonic Computing

#### Why photons

Electrons in metal interconnects dissipate energy as heat (Joule heating, $P = I^2 R$), generate electromagnetic interference that limits signal density, and propagate at speeds limited by RC time constants that worsen as wires scale down. At the board and chip level, interconnect energy now dominates over compute energy for memory-bandwidth-bound workloads.

Photons in waveguides have fundamentally different physical properties:

- Zero rest mass → propagation at near-$c$ with no RC delay penalty
- No charge → no Joule heating in the transmission medium
- Wavelength-division multiplexing (WDM) → multiple independent data streams on the same physical waveguide simultaneously, something impossible with electrical wires without crosstalk
- Weak photon-photon interaction → signals on adjacent wavelengths do not interfere

The trade-off is that photons are difficult to modulate, route, and detect at low energy, and all useful computation ultimately requires nonlinearity — which photons in linear media do not provide.

---

#### Silicon photonics platform

The dominant implementation platform is **silicon photonics**: photonic devices fabricated on silicon-on-insulator (SOI) substrates using CMOS-compatible processes. This allows co-integration (or at minimum, flip-chip bonding) with electronic circuits.

Core device primitives:

**Waveguide:** A silicon strip (typically 450 nm × 220 nm on SiO₂ cladding) that confines light by total internal reflection — silicon's refractive index (~3.47) versus SiO₂ (~1.44) provides strong confinement. Single-mode operation at 1310 nm or 1550 nm (telecom wavelengths) is standard.

**Microring resonator (MRR):** A circular waveguide evanescently coupled to a bus waveguide. At resonance (when the ring circumference is an integer multiple of the guided wavelength), light couples into the ring and is attenuated from the through port. The resonant wavelength is tunable by heating the ring (thermo-optic effect, ~100 pm/°C in silicon) or by carrier injection/depletion (electro-optic, faster but smaller shift). MRRs are the primary element for modulation, switching, and wavelength-selective filtering.

**Mach-Zehnder modulator (MZM):** An interferometric device that splits light into two arms, applies a phase shift to one arm via the plasma dispersion effect (carrier injection changes silicon's refractive index), and recombines them. Constructive or destructive interference encodes a bit. MZMs have broader bandwidth than MRRs (~50 GHz) but larger footprint (~100–500 µm).

**Photodetector:** A germanium-on-silicon p-i-n junction that absorbs photons at 1310/1550 nm (silicon is transparent at these wavelengths; germanium is not) and produces a photocurrent. Responsivity ~1 A/W, bandwidth >50 GHz.

**Optical amplifier:** Silicon has no optical gain; amplification requires a III-V gain medium (InP, GaAs) bonded or butt-coupled to the silicon waveguide. This is the integration challenge: CMOS fab processes are incompatible with III-V growth.---

#### Optical computation: the matrix-vector multiply case

Pure optical logic gates are not practical — they require extremely high optical power or large nonlinear media. What is practical is **analog optical computation** for specific linear algebra operations, particularly matrix-vector multiplication (MVM).

The physical basis is the coherent superposition of optical fields. Consider a mesh of Mach-Zehnder interferometers (MZIs). Each MZI implements a 2×2 unitary transformation on optical amplitudes. An $N \times N$ mesh of MZIs (the Clements or Reck decomposition) can implement any $N \times N$ unitary matrix. Singular value decomposition allows any real-valued matrix $W$ to be decomposed as $W = U \Sigma V^T$, where $U$ and $V$ are unitary (implemented as MZI meshes) and $\Sigma$ is diagonal (implemented by optical attenuators).

The input vector $\mathbf{x}$ is encoded as optical amplitudes on $N$ wavelengths or spatial modes. The matrix-vector product $W\mathbf{x}$ emerges at the output ports of the MZI mesh **at the speed of light**, with energy consumption proportional only to the modulation and detection operations, not to the multiply-accumulate count. At large $N$, this offers a potential energy-per-operation advantage over electronic MAC units.

This is the operating principle behind photonic tensor cores proposed for neural network inference. [Inference] The energy advantage is real in principle, but achieving it in practice requires overcoming optical loss, thermal drift of MRRs, and analog noise — none of which have been fully solved at production scale as of the knowledge cutoff.

**Optical nonlinearity for activation functions:** After each MVM layer, a neural network requires a nonlinear activation. In a photonic system this requires converting the optical signal to electrical, applying the nonlinearity electronically, and reconverting — an electro-optic (E-O) conversion penalty paid once per layer. This is the primary energy overhead that erodes the MVM advantage for deep networks.

---

#### Photonic interconnect vs. photonic compute

A critical distinction in the field: **photonic interconnect** (optical data movement between chips or across a chip) is commercially deployed today. **Photonic compute** (optical matrix multiplication replacing electronic ALUs) is in research and early commercial prototype phase.

|Capability|Maturity|Example|
|---|---|---|
|On-board optical transceivers (100G–800G)|Production|All major data center switches|
|Co-packaged optics (laser + silicon photonics in same package)|Early production|Intel IPU, Broadcom Tomahawk 5 co-packaged|
|On-chip optical interconnect (die-to-die)|Research / early demo|MIT, IMEC prototypes|
|Optical matrix-vector multiply (inference accelerator)|Research / startup prototype|Lightmatter, Lightelligence|
|Fully optical neural network inference|Research|Academic demonstrations only|

---

#### Thermal sensitivity and control

Silicon's thermo-optic coefficient ($dn/dT \approx 1.86 \times 10^{-4}$ K⁻¹) means that a 1 °C temperature change shifts an MRR resonance by approximately 100 pm. A 10 °C chip temperature variation — well within normal operating range — causes a 1 nm shift, which is comparable to the MRR linewidth. Uncontrolled, this detunes the resonator and eliminates modulation contrast.

Active thermal control of each MRR (via a resistive microheater deposited above the ring) is therefore mandatory. Each heater consumes static power proportional to the tuning range required. In large photonic systems with hundreds of MRRs, the aggregate heater power is a significant fraction — sometimes the dominant fraction — of total system power. This is a known architectural challenge without a resolved solution; techniques including athermal waveguide design (cladding materials with opposing thermo-optic coefficients), localized thermal isolation trenches, and feedback-controlled tuning are active research areas.

---

### Part II — Approximate Computing

#### The exactness assumption and where it fails

All preceding modules have assumed that every arithmetic operation produces the correct mathematical result. This assumption is appropriate when: (a) results feed directly into branching decisions or addresses, (b) the computation is cryptographic or financial, or (c) error accumulation over many operations is unbounded. It is **not** necessary when the consumer of the result is a human perception system (vision, audio), a statistical estimator (ML inference, sensor fusion), or an iterative solver with its own convergence criterion. In these domains, a result that is approximately correct is as useful as an exact result, and approximate hardware can be dramatically more efficient.

Approximate computing is the deliberate exploitation of this tolerance — accepting occasional or bounded errors in exchange for reductions in energy, area, or latency.

---

#### Voltage overscaling

The simplest approximate computing technique requires no architectural change. In standard operation, a circuit's supply voltage $V_{dd}$ is set above the level needed for timing closure, providing a guardband against process variation and temperature drift. **Voltage overscaling** (or underscaling) reduces $V_{dd}$ below the guardband into the region where some logic paths violate their setup time constraints, producing timing errors.

In conventional design this is catastrophic — a timing violation causes an unpredictable bit flip anywhere in the design. In approximate computing it is acceptable if the paths that fail are in non-critical data computation (adder carry chains, multiplier partial products) rather than control logic (branch resolution, address calculation). The energy reduction is quadratic in voltage reduction, as in DVFS. The error characteristic is workload-dependent: values with large magnitudes (long carry chains) are more likely to error than small values.

**Critical path isolation:** A practical implementation separates control-path logic (running at full $V_{dd}$) from data-path logic (running at reduced $V_{dd}$). The memory subsystem, PC logic, and branch predictor remain exact; the ALU, FPU, or MAC units are overscaled. This requires explicit hardware partitioning of the power domains — an extension of the power domain architecture discussed in the previous module.

---

#### Approximate arithmetic units

Rather than accepting whatever errors voltage overscaling produces, approximate arithmetic units are designed with deliberate, characterized inaccuracies that are architecturally controlled.

**Approximate adders.** The carry chain in a ripple-carry or carry-lookahead adder is the critical path — it propagates information from LSB to MSB. Approximate adders break this chain:

- **Lower-part-or (LOA):** The lower $k$ bits are computed with a simplified carry-skip or carry-less logic; only the upper $n-k$ bits use exact carry propagation. Errors are bounded to the lower $k$ bits, with maximum error $2^k - 1$.
- **ETAII / AMA adders:** Each full adder cell in the lower partition is replaced with an approximate cell having a simplified Boolean implementation (fewer transistors). The exact topology varies; the shared principle is that the simplified cell produces the correct output for most input combinations but errs on a minority.
- **Segmented adder:** Divide the $n$-bit adder into segments, compute each segment with a speculative carry-in assumption (carry-in = 0 or carry-in = 1), then select the result based on the actual carry-out from the previous segment — but only for the upper segments. Lower segments never receive a correction. This is a hardware simplification of carry-select that eliminates the selector for low-order bits.

**Approximate multipliers.** A $k$-bit multiplier produces $2k$ partial products. The lower partial products (contributing to lower-order bits of the result) are the primary targets for approximation:

- **Truncated multiplier:** Discard the lower $m$ columns of the partial product array before accumulation, replacing them with a constant rounding correction term. This eliminates $m \cdot k$ adder cells and reduces critical path length.
- **Approximate partial product reduction:** Replace exact compressors (4:2, 5:3) in the Wallace tree with approximate compressors that have fewer gates and shorter delay but occasional output errors.
- **Mitchell's logarithmic multiplication:** Approximate $a \times b \approx 2^{\lfloor \log_2 a \rfloor + \lfloor \log_2 b \rfloor}$ using only bit-shift and addition, with relative error bounded at ~11.1% in the worst case. Implementable with barrel shifters and small correction logic.---

#### Memory-level approximation

**Approximate SRAM:** SRAM cell stability degrades as $V_{dd}$ is reduced. Below a threshold, read disturb errors and write failures occur. An approximate SRAM accepts this: for cache arrays holding non-critical data (pixel values, intermediate neural network activations), errors at low $V_{dd}$ are tolerable. The SNM (Static Noise Margin) curve quantitatively relates error probability to supply voltage; application designers set $V_{dd}$ to achieve a target error rate rather than zero errors.

**Stochastic DRAM:** DRAM retention time is a function of cell leakage, which varies with temperature and manufacturing process. Conventionally, the refresh interval is set conservatively to guarantee zero errors at maximum temperature. Relaxed refresh (doubling the refresh interval) causes a small fraction of cells to lose data but reduces refresh power by 50%. For applications using DRAM as a frame buffer or a weight store for inference, occasional stale bits in the data produce output perturbations acceptable within the application's tolerance. [Inference] This is an active research direction; production deployment is limited as of the knowledge cutoff.

---

#### Neural processing and approximate computing synergy

Neural network inference is the application domain most naturally suited to approximate computing, for three reasons:

1. **Redundancy:** Weights and activations are real-valued approximations of a learned function. Replacing 32-bit floats with 8-bit integers (quantization) introduces bounded error but typically degrades accuracy by less than 1%. Reducing to 4-bit or binary representations is an extreme form of approximation with significant accuracy trade-offs that network architecture can partially compensate.
    
2. **Statistical noise tolerance:** A neural network trained with weight noise (a regularization technique) is provably more robust to hardware errors than one trained without it. The training process can be made aware of the approximate hardware's error distribution.
    
3. **MAC dominance:** Network inference is dominated by multiply-accumulate operations. Replacing exact multipliers with approximate multipliers (e.g., Mitchell's log multiplier) directly reduces the energy of the dominant operation. Errors in individual MACs are averaged across thousands of accumulations per output neuron, drastically reducing their effect on the final output.
    

**Quantization as structured approximation.** Quantization maps floating-point weights and activations to low-precision integers. It is implemented in hardware by replacing FP32 MAC units with INT8 or INT4 MAC units, which are substantially smaller and more energy-efficient. INT8 MAC units are approximately 16× more energy-efficient than FP32 for the same operation count, and occupy approximately 4× less area. This is not speculative — it is the design principle behind Google's TPUv1 (INT8), NVIDIA's Tensor Cores (INT8, INT4), and Apple's Neural Engine (INT8/INT16). Quantization is the most widely deployed form of approximate computing in production hardware today.

---

#### Error control mechanisms

Approximate computing is not uncontrolled: error bounds must be characterized and respected by the application.

**Significance-based protection.** In positional number systems (binary integers, floating-point), high-order bits contribute exponentially more to the value than low-order bits. Selectively protecting high-order bits with exact logic while approximating low-order bits bounds the maximum error as a fraction of the value. This is the principle behind truncated multipliers and lower-part-approximate adders described above.

**Algorithmic noise tolerance (ANT).** A software technique where the same computation is executed once on approximate hardware and once (periodically, on a random sample of outputs) on exact hardware. When the difference exceeds a threshold, the exact result is used instead. This provides a tunable trade-off between error rate and energy savings without requiring exact execution for every output.

**Selective approximation.** Not all stages of a computation are equally error-tolerant. In a video codec, the motion estimation stage can tolerate significant approximation (a slightly suboptimal motion vector produces a marginally larger residual); the entropy coding stage cannot (a bit error corrupts the bitstream decoder). Approximate hardware is applied to the tolerant stages; exact hardware protects the intolerant ones. Identifying this partition is an application-specific analysis, not a hardware responsibility.

---

#### Landscape summary

|Technique|Error type|Energy reduction|Application fit|
|---|---|---|---|
|Voltage overscaling|Probabilistic, data-dependent|20–50%|Image/audio processing|
|Approximate adder (LOA)|Bounded magnitude|10–30%|DSP, image filters|
|Truncated multiplier|Bounded, low-order bits|20–40%|Neural inference, graphics|
|Mitchell log multiplier|Bounded relative (~11%)|30–60%|Neural inference|
|SRAM $V_{dd}$ reduction|Probabilistic, random cells|20–45%|Cache for tolerant data|
|Relaxed DRAM refresh|Rare, cell-specific|~50% refresh power|Frame buffers, weight stores|
|INT8 quantization|Bounded, model-accuracy|16× vs FP32 MACs|All neural inference|

---

**Key Points:** Photonic computing offers physics-level advantages in interconnect (low-loss, WDM, no Joule heating in the medium) and potential advantages in analog matrix-vector multiplication (linear optics executing MVM at light speed). Production deployment is confined to optical interconnect; on-chip photonic compute remains pre-commercial. The fundamental challenges are optical nonlinearity (unavoidable E-O-E conversion per layer), thermal sensitivity of microring resonators (requiring per-ring active tuning), and the absence of an optical gain medium compatible with CMOS processes. Approximate computing exploits application-level error tolerance to reduce energy quadratically (via voltage reduction) or proportionally (via simplified arithmetic units). It is most effective where the output consumer is a human perceptual system or a statistical model — and it is already deployed at scale as quantized integer arithmetic in every commercial neural inference accelerator.

**Next Steps:** Domain-specific architectures (TPUs, NPUs, FPGAs, ASICs) which are the primary commercial deployment context for both quantized approximate arithmetic and co-packaged photonic interconnect, or neuromorphic computing which shares the approximate, noise-tolerant computing philosophy but implements it through an entirely different substrate — spiking neural networks in analog CMOS.

---

