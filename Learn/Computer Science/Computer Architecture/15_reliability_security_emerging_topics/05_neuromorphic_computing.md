## Neuromorphic Computing


### Overview

Neuromorphic computing is a computing paradigm that draws structural and operational principles from biological neural systems — specifically the mammalian neocortex and retina — to build hardware that processes information fundamentally differently from the von Neumann stored-program model. The term was coined by Carver Mead at Caltech in the late 1980s to describe analog VLSI circuits that exploited the physics of silicon transistors to emulate the electrochemical dynamics of neurons and synapses.

The central claim of the paradigm is that the brain's extraordinary efficiency — roughly 20 W supporting ~86 billion neurons and ~100 trillion synapses engaged in massively parallel, adaptive, low-latency computation — arises not merely from the scale of its connectivity, but from its computational principles: **spike-based asynchronous event-driven signaling**, **co-location of memory and computation**, **analog or mixed-signal dynamics**, and **Hebbian-style local plasticity rules**. Neuromorphic architecture attempts to instantiate these principles in silicon.

---

### Biological Principles and Their Architectural Mapping

Understanding neuromorphic hardware requires grounding in the biological mechanisms it abstracts.

#### The Neuron as a Computational Unit

A biological neuron integrates synaptic input currents across its dendritic tree, summing them at the soma. When the membrane potential V_m crosses a threshold V_th (~−55 mV in cortical neurons), an **action potential** (spike) is generated — a stereotyped all-or-nothing voltage pulse of ~1 ms duration. Following the spike, the membrane hyperpolarizes (refractory period, ~2–5 ms), preventing immediate re-firing.

The **integrate-and-fire** abstraction reduces this to:

```
C_m · dV/dt = -g_L(V - E_L) + I_syn(t)
```

where C_m is membrane capacitance, g_L is leak conductance, E_L is the leak reversal potential, and I_syn is the time-varying synaptic current. Spike when V ≥ V_th; reset V → V_reset.

Variants with increasing biological fidelity:

- **Leaky Integrate-and-Fire (LIF):** The above equation. The dominant model in neuromorphic hardware.
- **Adaptive Exponential I&F (AdEx):** Adds a subthreshold adaptation current — captures spike-frequency adaptation (firing rate decreasing under constant input) observed in cortical neurons.
- **Izhikevich model:** Two-variable model capturing 20+ distinct cortical firing patterns (regular spiking, bursting, chattering, fast-spiking) with modest computational cost.
- **Hodgkin-Huxley:** Full conductance-based model with gating variables for Na⁺, K⁺, leak channels. Biologically exact; computationally expensive. Rarely implemented directly in large-scale neuromorphic hardware.

#### Synapses and Plasticity

A synapse connects a presynaptic axon terminal to a postsynaptic dendritic spine. When a presynaptic spike arrives, neurotransmitter is released, opening ion channels in the postsynaptic membrane. The resulting postsynaptic current is the product of the synaptic weight w and a temporal kernel h(t):

```
I_syn(t) = w · h(t - t_spike)
```

where h(t) is typically an exponential decay (τ_syn ~ 5–20 ms for fast AMPA synapses, ~50–200 ms for slow NMDA synapses).

**Spike-Timing Dependent Plasticity (STDP):** The canonical unsupervised learning rule. If a presynaptic spike arrives shortly before a postsynaptic spike (pre → post, causal order), the synapse is potentiated (w increases). If the postsynaptic spike precedes the presynaptic (post → pre, acausal), the synapse is depressed (w decreases). The magnitude decays exponentially with the inter-spike interval Δt:

```
Δw = A₊ · exp(-Δt / τ₊)   if Δt > 0  (pre before post)
Δw = -A₋ · exp(Δt / τ₋)   if Δt < 0  (post before pre)
```

STDP has a Hebbian character — it strengthens connections that causally contribute to postsynaptic firing — and implements a form of temporal correlation learning directly from spike timing, with no global error signal.

#### Rate Coding vs. Temporal Coding

How information is carried in spike trains is a fundamental open question in neuroscience with direct implications for neuromorphic design:

- **Rate coding:** Information is encoded in the mean firing rate over a time window (50–200 ms). Simple to decode; averages out spike-timing noise. Rate-coded networks require longer integration windows and produce higher spike counts (higher energy per inference).
- **Temporal coding:** Information is encoded in the precise timing of spikes relative to a reference (phase coding, time-to-first-spike). Can convey information faster (single spike per neuron per stimulus) but requires precise timing circuitry and is sensitive to jitter.
- **Population coding:** Information is distributed across the relative activity of many neurons. Combines rate and temporal aspects; most consistent with cortical physiology.

The coding scheme assumed by a neuromorphic system determines how inputs must be encoded (rate-to-spike conversion, or direct temporal encoding) and what the output spike trains mean.

---

### Spiking Neural Network Computation

The spiking neural network (SNN) is the computational model implemented on neuromorphic hardware. It differs from the artificial neural network (ANN) used in deep learning in three fundamental ways:

**Temporal dynamics:** SNN neurons are stateful — they maintain a membrane potential that integrates input over time. A neuron that received no inputs in the last 50 ms has different behavior than one that received 10 inputs. ANNs are stateless per forward pass.

**Binary, asynchronous communication:** SNNs communicate via discrete spike events at irregular times. The presence or absence of a spike in a time step is the information carrier (1 bit per synapse per time step in hardware). ANNs communicate dense floating-point activations along weighted edges in synchronous layers.

**Event-driven computation:** A neuromorphic processor only performs computation when a spike arrives at a neuron. Neurons that receive no spikes in a time window consume no dynamic power. ANNs compute dense matrix multiplications at every layer for every inference regardless of input sparsity.

**The energy argument:** In an ANN accelerator, computing a layer requires multiplying every activation by every weight — O(N²) multiply-accumulate operations per layer even for sparse inputs. In an SNN, an input spike triggers only the fan-out synaptic additions for that neuron's axon — O(fan-out) per spike. If the firing rate is low (sparse activity), the total number of operations per inference is dramatically reduced. The claimed energy efficiency of neuromorphic hardware is entirely contingent on sparse, low-rate spike activity; a network firing at 100% rate is no more efficient than an ANN.

---

### Analog vs. Digital Neuromorphic Implementation

The field divides into two implementation philosophies with distinct trade-offs:

#### Analog / Mixed-Signal Neuromorphic

The original Mead vision. Transistors operating in the **subthreshold regime** (gate voltage below threshold voltage) exhibit exponential I-V characteristics that naturally reproduce the exponential dynamics of biological ion channels and membrane conductances:

```
I_DS = I₀ · exp(κV_GS / V_T)  (subthreshold MOSFET)
```

where κ ≈ 0.7 is the slope factor and V_T = kT/q ≈ 26 mV at room temperature — identical in functional form to the Boltzmann factor governing ion channel opening probability.

This allows neuron and synapse circuits to be implemented with transistors, capacitors, and resistors at extremely low power (picoampere bias currents, nanojoule per spike), because the computation is performed by the device physics rather than by clocked digital logic.

**Advantages:** Extremely low power per neuron/synapse; continuous-time (not discretized to a clock); physics directly implements biology.

**Disadvantages:** Process variation in subthreshold transistors creates mismatch — nominally identical circuits have different thresholds, leakage, and gain. Calibration overhead is substantial. Precision of synaptic weights is limited to 4–6 effective bits. Temperature sensitivity (V_T ∝ kT/q) requires compensation. Programming and interfacing to digital systems adds complexity.

**Representative systems:** Carver Mead's original silicon retina and cochlea; INI Zurich's neuromorphic circuits; BrainScaleS (Heidelberg/EU HBP).

#### Digital Neuromorphic

Neuron dynamics are computed digitally — typically as fixed-point integer arithmetic on a state machine or as a small processor per neuron core. Synaptic weights are stored in SRAM. Spike events are communicated as digital packets over an on-chip network.

**Advantages:** Deterministic, reproducible, scalable; weight precision up to 8–16 bits; amenable to standard CMOS manufacturing without calibration; easier to program and verify.

**Disadvantages:** Higher energy per spike-event than analog (digital logic switching energy vs. subthreshold current integration); clock required (though the system-level behavior is event-driven); less direct correspondence to biological dynamics.

**Representative systems:** IBM TrueNorth, Intel Loihi, SpiNNaker.

---

### Major Neuromorphic Hardware Platforms

The diagram below maps the principal platforms by their implementation philosophy and scale, before the detailed descriptions that follow.#### IBM TrueNorth (2014)

TrueNorth is a digital neuromorphic processor fabricated in Samsung 28 nm CMOS. It contains 4,096 neurosynaptic cores on a single chip, each core containing 256 neurons and 256 × 256 = 65,536 binary synapses, totaling approximately 1 million neurons and 256 million synapses on one die.

**Core architecture:** Each core is a completely self-contained, clock-gated digital circuit. In each tick (1 ms by default), the core processes arriving spike packets, accumulates synaptic inputs into neuron state registers, checks threshold conditions, generates output spikes, and then powers off. If no spikes arrive, the core does not activate — this is the basis of TrueNorth's energy efficiency.

**Constraints:** Synaptic weights are 1-bit (binary) — a synapse either has weight +w_j or 0. Each neuron has a 4-bit programmable weight parameter. This severely limits weight precision and, consequently, the accuracy achievable on tasks requiring fine-grained weight values. TrueNorth has no on-chip learning — weights must be programmed externally after offline training.

**Energy:** TrueNorth consumes approximately 70 mW running a real-time pattern recognition workload at 26 trillion synaptic operations per second, [Unverified — figure cited from IBM publications; independent replication not confirmed here] yielding approximately 400 GSOPS/W. The comparison point for context: a GPU performing equivalent operations at FP32 consumes orders of magnitude more power per operation.

**Routing:** Spikes are routed between cores using a 2D torus mesh. Each spike packet carries a destination core address; the network routes packets using dimension-order routing. Multi-chip scaling is achieved by connecting chips in a similar mesh.

#### Intel Loihi and Loihi 2

**Loihi (2018):** Intel's first research neuromorphic chip. 128 neuromorphic cores plus 3 Lakemont x86 management cores. Each neuromorphic core supports 1,024 compartments (neurons), with configurable LIF dynamics, on-chip STDP learning, and a hierarchical spike routing mesh. Total: ~131,072 neurons per chip; up to 8.3 billion synapses (with weight sharing).

**Loihi 2 (2021):** Redesigned in Intel 4 process (EUV). Key advances:

- 128 neuromorphic cores, each supporting up to 8,192 neurons (1M neurons per chip).
- Microcode-programmable learning rules — the on-chip learning engine is no longer hardwired to STDP; arbitrary three-factor learning rules can be expressed in a small instruction set. This enables reinforcement-modulated STDP, Bienenstock-Cooper-Munro (BCM) rules, and custom plasticity.
- Graded (multi-bit) spikes — a spike can carry a small payload (up to 24 bits) rather than being purely binary. This bridges SNN and ANN computation.
- Faster inter-chip communication via a dedicated spike routing interface.

**Hala Point (2024):** Intel's largest neuromorphic research system, comprising 1,152 Loihi 2 chips in a rack-mounted system. Total: approximately 1.15 billion neurons and 128 billion synapses. [Unverified — these figures are from Intel press materials; independent characterization is not confirmed here.] Designed as a research platform for large-scale SNN experiments, not a commercial product.

#### SpiNNaker and SpiNNaker 2

SpiNNaker (Spiking Neural Network Architecture) is a massively parallel computing platform developed at the University of Manchester as part of the EU Human Brain Project. Rather than custom analog or dedicated digital neuron circuits, SpiNNaker uses a network of small ARM processors — each running simulated neuron models in software — connected by a custom packet-switched network optimized for spike communication.

**SpiNNaker 1:** 48-node board contains 48 SpiNNaker chips, each with 18 ARM968 cores, for 864 ARM cores per board. A full machine (106 chips) supports approximately 10⁹ neurons in real time. The network uses a custom triangular torus topology optimized for low-latency, high-fanout multicast packet delivery.

**SpiNNaker 2:** Redesigned in 22 nm FD-SOI. Each chip integrates 152 ARM Cortex-M4F cores, hardware MAC units for accelerated neuron computation, and on-chip learning acceleration. The architecture adds explicit support for quantized ANN computation alongside SNNs, acknowledging the importance of hybrid workloads.

**Key property:** Because neurons are simulated in software on ARM cores, SpiNNaker can run any neuron model that fits in the core's instruction and data memory — Hodgkin-Huxley, multicompartment models, custom plasticity rules — without hardware changes. Flexibility is maximized; energy efficiency per neuron is lower than TrueNorth or Loihi due to the overhead of general-purpose ARM instruction execution.

#### BrainScaleS-2

BrainScaleS-2 (BSS-2) is a mixed-signal accelerated neuromorphic system developed at Heidelberg University. Its central distinguishing property is **accelerated time**: the analog circuits operate approximately 10,000× faster than biological real time. A 1-second biological experiment runs in ~100 µs on BSS-2.

Each BSS-2 chip contains 512 AdEx (Adaptive Exponential integrate-and-fire) neuron circuits implemented in analog CMOS, with 256 × 512 synaptic crossbar arrays. Calibration routines characterize and compensate for transistor mismatch, bringing neuron-to-neuron variation within acceptable bounds.

The 10,000× acceleration makes BSS-2 uniquely suited for plasticity research — long-timescale biological processes (hours of STDP training) can be explored in seconds. The trade-off is that interfacing with real-time external sensors is non-trivial; input data must be compressed in time to match the accelerated dynamics.

---

### The Address Event Representation (AER) Protocol

AER is the standard communication protocol for spike transmission in neuromorphic systems, originating in Mahowald and Douglas's 1991 work at Caltech.

Each spike event is encoded as a digital packet containing the **address** of the neuron that fired, plus a timestamp. The receiving chip uses the address to look up which target neurons should receive the spike and what their synaptic weights are.

The AER abstraction separates the spike generation (analog, continuous-time) from spike routing (digital, packet-switched). This allows analog neuron circuits to communicate with digital routing fabric — the essential interface in mixed-signal neuromorphic systems.

**Bandwidth consideration:** In a network of N neurons with mean firing rate r, the aggregate spike rate is N·r packets/second. At r = 10 Hz (typical cortical rate) and N = 10⁶ neurons, the aggregate is 10⁷ events/second — manageable with a multi-Gb/s serial link. At high firing rates or large N, the bus can saturate — AER-based systems must be designed with the spike bandwidth budget in mind.

---

### On-Chip Learning Mechanisms

On-chip learning distinguishes neuromorphic hardware that can adapt from systems that are purely inference engines.

**STDP (Spike-Timing Dependent Plasticity):** Implemented on Loihi 1 as a hardwired rule. Each synapse maintains a pre- and post-synaptic trace — exponentially decaying scalar values updated on each spike. When a post-synaptic spike occurs, the weight is updated proportional to the current pre-synaptic trace value, and vice versa.

**Three-factor learning rules (Loihi 2):** Classical STDP is a two-factor rule — it depends only on pre- and post-synaptic spike timing. Biological reinforcement learning requires a third factor: a neuromodulatory signal (dopamine, acetylcholine) that gates whether STDP-driven weight changes are committed or discarded. Three-factor rules: `Δw = f(pre, post) · M(t)` where M(t) is a modulator signal. This implements reward-modulated STDP — the basis of neuromorphic reinforcement learning.

**Homeostatic plasticity:** Mechanisms that regulate overall network activity to prevent runaway excitation or silence. Implemented as adaptive thresholds (V_th increases when a neuron fires too frequently, decreasing its sensitivity) or synaptic scaling (all weights into a neuron scaled by a factor that keeps its average firing rate near a target). Hardware implementations exist on Loihi and BrainScaleS-2.

**Weight storage:** On digital chips, weights are stored in SRAM within each core — near the computation, avoiding the memory bottleneck of von Neumann architectures. On analog chips, weights are stored as analog voltages on capacitors (volatile, require refresh) or as conductance states of non-volatile memory devices (see below).

---

### Non-Volatile Memory Devices as Synapses

A significant research thrust uses non-volatile analog memory devices as physical synaptic weights, enabling in-memory compute — the multiply-accumulate operation is performed by Ohm's law in the device array rather than in digital logic.

**Phase-Change Memory (PCM):** Stores information as the crystalline vs. amorphous state of a chalcogenide glass (typically Ge₂Sb₂Te₅). Amorphous = high resistance (low weight); crystalline = low resistance (high weight). Intermediate states are accessible via partial crystallization. IBM Research has demonstrated multi-layer SNN inference using PCM crossbar arrays. Write endurance: ~10⁸ cycles — limiting on-chip learning iterations. Conductance drift (resistance increasing over time in the amorphous state) introduces weight errors that must be compensated. [Inference — device characteristics vary by fabrication; these are representative figures, not universally confirmed.]

**Resistive RAM (RRAM / ReRAM):** Stores information as the conductance of a thin filament formed/ruptured by oxygen vacancy migration in a metal oxide (HfO₂, TaO₂). Lower operating voltage than PCM; faster switching; potentially higher endurance (~10¹⁰ cycles). Stochastic switching behavior requires statistical programming protocols. [Inference — endurance figures are material- and process-dependent; not universally confirmed.]

**Ferroelectric FET (FeFET):** Stores analog weight as the polarization state of a ferroelectric gate dielectric (HZO — hafnium zirconium oxide). The threshold voltage of the FET shifts with polarization, modulating conductance. Integrated into standard CMOS flows (HZO is compatible with HKMG processing). Still early-stage for multi-bit analog operation. [Inference — this characterization reflects the state of research literature through early 2025; the field is rapidly evolving.]

**The crossbar array:** Synaptic devices are arranged in a 2D matrix. Neuron outputs drive rows (input voltage), synaptic conductances are the crosspoint devices, and column currents are the accumulated dot-product outputs. This implements a vector-matrix multiply in O(1) time using Kirchhoff's current law. The fundamental challenge is the non-ideal device characteristics — nonlinearity, asymmetry between potentiation and depression, cycle-to-cycle variation, and device-to-device variation — which degrade weight precision and require mitigation strategies.

---

### Training Spiking Neural Networks

Training SNNs for deployment on neuromorphic hardware is one of the field's principal challenges, because the spike function (threshold crossing) is non-differentiable — standard backpropagation through time (BPTT) cannot be applied directly.

**ANN-to-SNN conversion:** Train a standard ANN (using backpropagation, full float32 precision) and then convert it to an SNN by replacing ReLU activations with LIF neurons, mapping activation values to firing rates. The conversion introduces accuracy loss from rate-coding approximation — especially for low firing rates where a short time window produces few spikes. Mitigation: threshold balancing, weight normalization, and longer integration windows. This is the most mature approach for deploying accurate SNNs on TrueNorth and Loihi. [Inference — accuracy of converted SNNs relative to ANN originals is workload-dependent; no universal characterization exists.]

**Surrogate gradient training:** Replace the non-differentiable spike function with a smooth surrogate during the backward pass (e.g., a piecewise linear or sigmoid approximation to the Heaviside function). Forward pass uses true binary spikes; backward pass uses the surrogate gradient. This allows BPTT to train SNNs directly from spike sequences. The approach introduces a gradient mismatch (the forward and backward functions differ) but empirically trains effectively on many benchmarks.

**Online local learning (STDP, e-prop):** Avoid backpropagation entirely. STDP is purely local — each synapse updates based only on the timing of its pre- and post-synaptic neurons, with no global error signal. The advantage is hardware amenability (implemented directly in Loihi's learning engine) and biological plausibility. The disadvantage is that STDP alone does not optimize a global loss function — tasks requiring precise output targets are difficult to train. **Eligibility propagation (e-prop)** is a biologically plausible approximation to BPTT that uses local eligibility traces modulated by a global learning signal — a compromise between STDP's locality and BPTT's accuracy.

---

### Energy Efficiency Analysis

The energy per synaptic operation (EPSO, in joules per synaptic operation) is the primary efficiency metric for neuromorphic hardware.

|System|EPSO (approx.)|Notes|
|---|---|---|
|Human brain|~10 fJ|Estimated; highly [Unverified]|
|BrainScaleS-2|~1 pJ|Analog, per synaptic event|
|Intel Loihi 2|~5–10 pJ|Digital, per synaptic event|
|IBM TrueNorth|~26 pJ|Digital, per synaptic event|
|GPU (A100, FP16)|~1–10 nJ per MAC|Not directly comparable (dense, not sparse)|

The comparison to GPU is not straightforward — GPU MACs are dense FP16 multiplications on dense tensors; neuromorphic EPSO counts a binary addition triggered by one spike event. The operations are incommensurable without specifying the task, the network architecture, and the encoding. Claims that neuromorphic hardware is "N× more efficient than GPUs" require careful qualification of what is being compared. [Inference — these figures are drawn from published characterizations; their comparability across platforms is limited by differing measurement methodologies.]

The efficiency advantage materializes in practice when three conditions hold simultaneously: sparse spike activity (low firing rate), a task that can be accurately solved by an SNN, and sufficiently large-scale network to amortize chip infrastructure overhead.

---

### Applications and Benchmarks

**Keyword spotting and audio classification:** Dense spiking input from a silicon cochlea (analog filterbank producing tonotopic spike streams) fed to a spiking classifier. Demonstrated on Loihi with competitive accuracy on Google Speech Commands at a fraction of the power of a Cortex-M DSP implementation. [Inference — benchmark comparisons are task- and configuration-dependent; not universally replicable.]

**Dynamic vision sensor (DVS) processing:** The DVS (silicon retina) outputs events asynchronously — each pixel fires when its local log-luminance changes by a threshold, rather than capturing frames. The output is a sparse spatiotemporal spike stream naturally suited to neuromorphic processing. Object recognition, optical flow, and gesture recognition have been demonstrated.

**Optimization problems (constraint satisfaction):** Loihi has been demonstrated on combinatorial optimization problems — maximum cut, graph coloring, integer programming — by mapping them to energy minimization in a Hopfield-like spiking network. The asynchronous dynamics perform a form of stochastic local search. [Inference — whether this constitutes a practical computational advantage over specialized classical solvers is an open research question.]

**Robotic motor control and sensorimotor integration:** SNNs running on Loihi embedded in robotic platforms (Zheng et al., Intel Labs collaborations) have demonstrated adaptive locomotion control and tactile sensing integration with lower latency and power than equivalent GPU inference.

---

### Fundamental Challenges and Open Problems

**The accuracy gap:** On most standard benchmarks (ImageNet, CIFAR-10), converted or directly trained SNNs achieve accuracy several percentage points below their ANN equivalents, particularly at short time windows (few time steps). Closing this gap while maintaining low firing rates — which are necessary for the energy efficiency argument — remains an active research problem.

**Weight precision:** Biological synapses are effectively continuous (though the biological substrate is debated). Analog hardware provides 4–6 bits of weight precision; digital hardware can support 8 bits or more at the cost of more SRAM per synapse. The expressiveness of networks is constrained by weight precision.

**Programming and toolchains:** There is no ecosystem remotely comparable to PyTorch/TensorFlow for neuromorphic hardware. Intel's Lava framework (for Loihi), BrainScaleS's PyNN-based interface, and SpiNNaker's PyNN support are research tools with limited coverage of standard ML workflows. The translation from a trained model to on-chip configuration is non-trivial.

**Lack of standardized benchmarks:** NeuroBench (2023) is an effort to establish standardized workloads for neuromorphic hardware comparison, addressing the difficulty of comparing across platforms with different neuron models, time steps, and spike encodings. [Unverified — NeuroBench's adoption across the field as of the knowledge cutoff is not fully confirmed.]

**Scaling on-chip learning:** On-chip STDP and surrogate-gradient methods have been demonstrated at small to moderate scale. Whether on-chip learning can scale to the network sizes required for competitive task performance — and whether the resulting weight updates remain stable under analog noise and device variation — is unresolved.

---

### Positioning Within the Broader Landscape

Neuromorphic computing is neither a replacement for GPUs nor a straightforward competitor to digital AI accelerators (TPUs, NPUs). Its current position is best characterized as a **specialized accelerator class** for:

- Event-driven sensor processing with sparse, asynchronous input streams (DVS cameras, acoustic sensors).
- Ultra-low-power inference at the extreme edge (µW–mW power budgets, coin-cell operation).
- Adaptive systems requiring on-chip learning without the overhead of gradient computation.
- Scientific simulation of neural circuits at biological scale (the neuroscience use case of SpiNNaker and BrainScaleS).

The paradigm's commercial viability remains contingent on the emergence of killer applications that simultaneously require its specific combination of properties — and on the maturation of training toolchains to the point where deploying a competitive model on neuromorphic hardware does not require specialist knowledge of spiking network dynamics. Both conditions remain works in progress as of the knowledge cutoff.

---

**Next Steps:** The most directly adjacent topics from the syllabus are **domain-specific architectures (TPUs, NPUs, FPGAs, ASICs)** — which contextualize neuromorphic hardware within the broader landscape of accelerators — **hardware security and trusted execution environments** (the side-channel characteristics of analog and memristive hardware are a new research frontier), and **fault tolerance and redundancy** (the stochastic nature of analog neuromorphic circuits creates a class of reliability problems with no direct analogue in digital systems).

---

