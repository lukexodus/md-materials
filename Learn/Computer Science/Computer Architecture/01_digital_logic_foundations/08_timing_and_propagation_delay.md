## Timing and Propagation Delay


Timing analysis and propagation delay are foundational to understanding how digital circuits behave in real hardware — where gates are not instantaneous and signals take time to stabilize.

---

### Propagation Delay Defined

Every logic gate introduces a delay between when its input changes and when its output reflects that change. Two parameters characterize this:

|Parameter|Symbol|Definition|
|---|---|---|
|Propagation delay (low-to-high)|t_pLH|Time from input transition to output rising to 50% of V_DD|
|Propagation delay (high-to-low)|t_pHL|Time from input transition to output falling to 50% of V_DD|
|Propagation delay (average)|t_pd|(t_pLH + t_pHL) / 2|

t_pLH and t_pHL are often unequal because PMOS and NMOS transistors have different drive strengths.

---

### Contributing Factors

Propagation delay arises from physical causes, not logic abstraction:

**Transistor switching time** — Transistors do not switch instantly. The time required to charge or discharge a gate depends on carrier mobility and threshold voltage.

**Capacitive load** — Every wire and gate input presents capacitance. The time to charge a capacitor through a resistance is τ = RC, so longer wires and fan-out increase delay.

**Fan-out** — Driving more gate inputs increases the effective capacitive load on the output, increasing delay.

**Supply voltage** — Lower V_DD slows switching (less overdrive above threshold), trading power for speed.

**Temperature** — Higher temperature reduces carrier mobility, increasing delay.

---

### Rise Time and Fall Time

Distinct from propagation delay:

|Parameter|Definition|
|---|---|
|Rise time (t_r)|Time for output to transition from 10% to 90% of V_DD|
|Fall time (t_f)|Time for output to transition from 90% to 10% of V_DD|

These measure signal edge quality, not gate-to-gate latency. They matter for signal integrity and setup/hold analysis.

---

### Critical Path

In a combinational circuit, the **critical path** is the longest delay path from any input to any output. It determines the minimum clock period and therefore the maximum operating frequency.

```
T_clk ≥ t_pd_critical + t_setup + t_skew
```

Where:

- `t_pd_critical` — sum of gate delays along the critical path
- `t_setup` — setup time of the destination flip-flop
- `t_skew` — clock skew between source and destination registers

**Example:** A 4-bit ripple carry adder has a critical path that propagates carry through all 4 full adders in series. If each full adder has t_pd = 2 ns, the critical path delay is 8 ns, limiting the circuit to f_max = 125 MHz (ignoring setup time).

---

### Contamination Delay

Alongside propagation delay, contamination delay (t_cd) is also defined:

|Parameter|Definition|
|---|---|
|Propagation delay (t_pd)|Maximum time until output is guaranteed stable|
|Contamination delay (t_cd)|Minimum time before output begins to change|

t_cd ≤ t_pd always. Contamination delay is used in hold time analysis.

---

### Setup and Hold Times

Flip-flops impose timing constraints on their data input relative to the clock edge:

|Constraint|Symbol|Definition|
|---|---|---|
|Setup time|t_su|Data must be stable this long _before_ the clock edge|
|Hold time|t_h|Data must remain stable this long _after_ the clock edge|

Violating either constraint places the flip-flop in a metastable state, where the output is neither a valid 0 nor a valid 1 for an indeterminate duration.

```
Timing constraint (setup): t_pd_logic ≤ T_clk - t_su - t_skew
Timing constraint (hold):  t_cd_logic ≥ t_h + t_skew
```

---

### Clock Skew

Clock skew is the difference in arrival time of the clock signal at two different flip-flops in the same domain. It arises from:

- Different wire lengths in the clock distribution network
- Buffer insertion asymmetries
- Process variation

**Positive skew** (destination clock arrives later than source): relaxes setup but tightens hold.  
**Negative skew** (destination arrives earlier): tightens setup.

Clock trees are designed to minimize skew, ideally achieving zero skew across all registers.

---

### Glitches and Hazards

When multiple paths of different lengths feed a gate, intermediate spurious transitions — **glitches** — can appear before the output stabilizes. These arise from:

**Static-1 hazard** — Output momentarily goes to 0 during a transition that should stay at 1.  
**Static-0 hazard** — Output momentarily goes to 1 during a transition that should stay at 0.  
**Dynamic hazard** — Output changes more than once before settling.

Glitches are a direct consequence of unequal propagation delays across parallel paths. In combinational logic feeding asynchronous logic or latches, glitches can cause incorrect state captures.

---

### SVG: Signal Timing Diagram

```svg
<svg viewBox="0 0 720 260" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">

  <!-- Background -->
  <rect width="720" height="260" fill="#1e1e2e"/>

  <!-- Labels -->
  <text x="10" y="55" fill="#cdd6f4">IN</text>
  <text x="10" y="120" fill="#cdd6f4">OUT</text>
  <text x="10" y="200" fill="#cdd6f4">CLK</text>

  <!-- IN signal: goes high at x=100 -->
  <polyline points="60,70 100,70 100,40 400,40 400,70 660,70"
            fill="none" stroke="#89b4fa" stroke-width="2"/>

  <!-- OUT signal: delayed rising edge, showing t_pLH -->
  <polyline points="60,135 140,135 160,105 400,105 420,135 660,135"
            fill="none" stroke="#a6e3a1" stroke-width="2"/>

  <!-- Delay annotation: t_pLH -->
  <line x1="100" y1="150" x2="100" y2="170" stroke="#fab387" stroke-width="1" stroke-dasharray="4,2"/>
  <line x1="160" y1="150" x2="160" y2="170" stroke="#fab387" stroke-width="1" stroke-dasharray="4,2"/>
  <line x1="100" y1="162" x2="160" y2="162" stroke="#fab387" stroke-width="1.5" marker-end="url(#arr)" marker-start="url(#arrl)"/>
  <text x="108" y="158" fill="#fab387" font-size="11">t_pLH</text>

  <!-- CLK signal -->
  <polyline points="60,215 120,215 120,185 200,185 200,215 280,215 280,185 360,185 360,215 440,215 440,185 520,185 520,215 600,215 600,185 660,185"
            fill="none" stroke="#f38ba8" stroke-width="2"/>

  <!-- setup/hold annotation near last CLK edge at x=600 -->
  <line x1="560" y1="100" x2="560" y2="145" stroke="#cba6f7" stroke-width="1" stroke-dasharray="3,2"/>
  <line x1="600" y1="100" x2="600" y2="215" stroke="#f38ba8" stroke-width="1" stroke-dasharray="3,2"/>
  <line x1="620" y1="100" x2="620" y2="145" stroke="#cba6f7" stroke-width="1" stroke-dasharray="3,2"/>

  <text x="548" y="97" fill="#cba6f7" font-size="10">t_su</text>
  <text x="603" y="97" fill="#cba6f7" font-size="10">t_h</text>

  <!-- Axis line -->
  <line x1="60" y1="230" x2="660" y2="230" stroke="#585b70" stroke-width="1"/>
  <text x="330" y="250" fill="#585b70" text-anchor="middle">time →</text>

  <!-- 50% markers on IN -->
  <line x1="100" y1="40" x2="100" y2="70" stroke="#89b4fa" stroke-width="1" stroke-dasharray="2,2"/>

  <!-- 50% markers on OUT -->
  <line x1="160" y1="105" x2="160" y2="135" stroke="#a6e3a1" stroke-width="1" stroke-dasharray="2,2"/>

  <!-- Arrow markers -->
  <defs>
    <marker id="arr" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto">
      <path d="M0,0 L6,3 L0,6 Z" fill="#fab387"/>
    </marker>
    <marker id="arrl" markerWidth="6" markerHeight="6" refX="0" refY="3" orient="auto">
      <path d="M6,0 L0,3 L6,6 Z" fill="#fab387"/>
    </marker>
  </defs>
</svg>
```

---

### SVG: Critical Path in a Combinational Circuit

```svg
<svg viewBox="0 0 700 180" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">

  <rect width="700" height="180" fill="#1e1e2e"/>

  <!-- FF source -->
  <rect x="20" y="60" width="60" height="50" rx="4" fill="#313244" stroke="#89b4fa" stroke-width="1.5"/>
  <text x="50" y="80" fill="#cdd6f4" text-anchor="middle">FF</text>
  <text x="50" y="98" fill="#585b70" text-anchor="middle">src</text>

  <!-- Gate 1 -->
  <rect x="140" y="65" width="60" height="40" rx="4" fill="#313244" stroke="#a6e3a1" stroke-width="1.5"/>
  <text x="170" y="80" fill="#a6e3a1" text-anchor="middle">AND</text>
  <text x="170" y="96" fill="#585b70" text-anchor="middle">2 ns</text>

  <!-- Gate 2 -->
  <rect x="260" y="65" width="60" height="40" rx="4" fill="#313244" stroke="#a6e3a1" stroke-width="1.5"/>
  <text x="290" y="80" fill="#a6e3a1" text-anchor="middle">OR</text>
  <text x="290" y="96" fill="#585b70" text-anchor="middle">1.5 ns</text>

  <!-- Gate 3 -->
  <rect x="380" y="65" width="60" height="40" rx="4" fill="#313244" stroke="#fab387" stroke-width="2"/>
  <text x="410" y="80" fill="#fab387" text-anchor="middle">XOR</text>
  <text x="410" y="96" fill="#585b70" text-anchor="middle">3 ns</text>

  <!-- FF dest -->
  <rect x="510" y="60" width="60" height="50" rx="4" fill="#313244" stroke="#89b4fa" stroke-width="1.5"/>
  <text x="540" y="80" fill="#cdd6f4" text-anchor="middle">FF</text>
  <text x="540" y="98" fill="#585b70" text-anchor="middle">dst</text>

  <!-- Wires -->
  <line x1="80" y1="85" x2="140" y2="85" stroke="#cdd6f4" stroke-width="1.5"/>
  <line x1="200" y1="85" x2="260" y2="85" stroke="#cdd6f4" stroke-width="1.5"/>
  <line x1="320" y1="85" x2="380" y2="85" stroke="#cdd6f4" stroke-width="1.5"/>
  <line x1="440" y1="85" x2="510" y2="85" stroke="#cdd6f4" stroke-width="1.5"/>

  <!-- Critical path label -->
  <text x="350" y="140" fill="#fab387" text-anchor="middle">Critical Path: 2 + 1.5 + 3 = 6.5 ns → f_max ≈ 153 MHz</text>
  <text x="350" y="158" fill="#585b70" text-anchor="middle">(excluding t_setup and t_skew)</text>

  <!-- Title -->
  <text x="350" y="22" fill="#cdd6f4" text-anchor="middle" font-size="13">Critical Path Through Combinational Logic</text>
</svg>
```

---

### Timing Closure

**Timing closure** is the process of ensuring all paths in a design meet their timing constraints after placement and routing. It involves:

- Identifying failing paths via static timing analysis (STA)
- Restructuring logic to shorten the critical path
- Inserting buffers or resizing gates to reduce load-driven delay
- Adjusting clock frequency or introducing pipeline registers

STA tools (e.g., Synopsys PrimeTime, OpenSTA) compute worst-case delays across all process, voltage, and temperature (PVT) corners without requiring simulation.

---

### Performance Implications

|Technique|Effect on Timing|
|---|---|
|Pipelining|Cuts critical path; increases throughput at cost of latency|
|Logic restructuring|Reduces gate depth on critical path|
|Gate sizing (upsizing)|Increases drive strength, reduces RC delay; increases area and power|
|Clock gating|Reduces dynamic power; no direct timing benefit|
|Retiming|Moves registers across combinational logic to balance path lengths|
|DVFS|Lowers frequency and voltage to reduce power; increases t_pd|

---

**Conclusion:** Propagation delay is the fundamental timing primitive of digital design. It propagates upward in abstraction — from transistor physics to gate delay, to path delay, to clock period constraints — and is the primary bottleneck governing how fast a synchronous circuit can operate. All timing analysis, pipeline design, and frequency optimization trace back to accurately characterizing and managing these delays.

**Next Steps:** Proceed to combinational logic circuits to see how delay accumulates across multi-gate networks, or advance to sequential logic circuits to examine how setup and hold constraints govern clocked storage elements in practice.

---

---

