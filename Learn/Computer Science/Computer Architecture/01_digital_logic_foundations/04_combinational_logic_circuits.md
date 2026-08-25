## Combinational Logic Circuits


A combinational logic circuit is a network of logic gates whose outputs are a function solely of the current input values — there is no internal state, no feedback, and no dependency on past inputs. Given a fixed input vector, the output is deterministic and stable after propagation delay.

---

### Formal Definition and Properties

A combinational circuit implements a Boolean function:

$$f: {0,1}^n \rightarrow {0,1}^m$$

mapping $n$ input lines to $m$ output lines. The defining properties are:

- **Memorylessness** — no storage elements (no flip-flops, no latches)
- **Acyclicity** — no feedback paths from output to input
- **Functional completeness** — any Boolean function can be realized using gates from a functionally complete set (e.g., {NAND} alone suffices)

---

### Gate-Level Primitives

All combinational circuits reduce to interconnections of primitive gates. The universal sets are `{NAND}` and `{NOR}` — both are individually sufficient to implement any Boolean function.

|Gate|Symbol|Expression|Notes|
|---|---|---|---|
|AND|·|$A \cdot B$|Output high only if all inputs high|
|OR|+|$A + B$|Output high if any input high|
|NOT|¬|$\bar{A}$|Inverts input|
|NAND|↑|$\overline{A \cdot B}$|Universal gate|
|NOR|↓|$\overline{A + B}$|Universal gate|
|XOR|⊕|$A \oplus B$|High when inputs differ|
|XNOR|⊙|$\overline{A \oplus B}$|High when inputs equal|

---

### Design Methodology

The standard design flow for any combinational circuit proceeds as follows:

**1. Problem specification** — Identify input and output variables; define the truth table completely, including don't-care conditions if applicable.

**2. Boolean expression derivation** — Read the function directly from the truth table (SOP from minterms, POS from maxterms).

**3. Minimization** — Apply Boolean algebra identities or Karnaugh maps to reduce gate count and logic levels.

**4. Implementation** — Map the minimized expression to the target gate set, respecting fan-in limits and drive strength constraints.

**5. Timing verification** — Compute the critical path delay; confirm setup and hold constraints are met if the combinational block feeds a register.

---

### Sum of Products and Product of Sums

Any Boolean function can be canonically expressed in two dual forms.

**Canonical SOP (minterm expansion):**

$$f(A,B,C) = \sum m(i_1, i_2, \ldots)$$

Each minterm $m_i$ is a product term where every variable appears exactly once, complemented or uncomplemented. SOP corresponds to a two-level AND-OR implementation.

**Canonical POS (maxterm expansion):**

$$f(A,B,C) = \prod M(j_1, j_2, \ldots)$$

Each maxterm $M_j$ is a sum term covering every variable once. POS corresponds to a two-level OR-AND implementation.

**Conversion identity:**

$$\sum m(i_1, \ldots) = \prod M(\text{complement indices})$$

---

### Propagation Delay and Timing

Every gate introduces delay. In a combinational network:

|Parameter|Definition|
|---|---|
|$t_{pd}$|Propagation delay — time from input transition to stable output|
|$t_{pHL}$|High-to-low output transition delay|
|$t_{pLH}$|Low-to-high output transition delay|
|Critical path|Longest delay path from any input to any output|
|Logic levels|Number of gate stages on the critical path|

The total circuit delay is:

$$T_{total} = \sum_{g \in \text{critical path}} t_{pd}(g)$$

Minimizing logic levels reduces delay; minimizing gate count reduces area and power. These objectives are frequently in tension.

**Glitches (hazards)** arise when two paths of unequal delay drive a gate simultaneously. For a moment, the output may toggle spuriously before settling at its final correct value.

---

### Hazards

**Static-1 hazard:** Output should remain high but momentarily goes low.  
**Static-0 hazard:** Output should remain low but momentarily goes high.  
**Dynamic hazard:** Output should change once but transitions multiple times.

Static hazards in SOP implementations are eliminated by adding **consensus terms** — additional product terms that bridge adjacent Karnaugh map groups, ensuring no gap is exposed during transitions.

**Example:** $f = AB + \bar{A}C$ has a static-1 hazard when $B=C=1$ and $A$ transitions. Adding the consensus term $BC$ yields $f = AB + \bar{A}C + BC$, eliminating the hazard.

---

### Standard Combinational Building Blocks

The following are the canonical medium-scale combinational components, each derived directly from Boolean logic.

#### Multiplexer (MUX)

Selects one of $2^n$ data inputs onto a single output using $n$ select lines.

$$Y = \sum_{i=0}^{2^n - 1} \left( D_i \cdot \prod_j S_j^{(i)} \right)$$

where $S_j^{(i)}$ denotes $S_j$ or $\bar{S_j}$ according to the binary encoding of $i$.

A 4-to-1 MUX: $Y = \bar{S_1}\bar{S_0}D_0 + \bar{S_1}S_0D_1 + S_1\bar{S_0}D_2 + S_1S_0D_3$

**Key property:** Any $n$-variable Boolean function can be implemented with a single $2^n$-to-1 MUX by routing constants (0 or 1) or a single variable to its data inputs. This enables function implementation without gate minimization.

#### Demultiplexer (DEMUX)

Routes a single input to one of $2^n$ outputs. Structurally, a DEMUX is the dual of a MUX; it is commonly used as a 1-to-$2^n$ decoder with an enable.

#### Decoder

An $n$-to-$2^n$ decoder asserts exactly one output for each input combination. Each output implements one minterm of $n$ variables.

$$O_i = 1 \iff \text{input} = i$$

**Design use:** Any combinational function over $n$ variables can be implemented by OR-ing the minterm outputs of an $n$-to-$2^n$ decoder corresponding to the function's on-set.

#### Encoder

The inverse of a decoder: $2^n$ inputs (one-hot asserted) to an $n$-bit binary output. A **priority encoder** additionally handles the case where multiple inputs are asserted simultaneously by outputting the index of the highest-priority active input.

#### Half Adder

Adds two single bits, producing a sum and carry-out.

|A|B|Sum|Cout|
|---|---|---|---|
|0|0|0|0|
|0|1|1|0|
|1|0|1|0|
|1|1|0|1|

$$\text{Sum} = A \oplus B \qquad C_{out} = A \cdot B$$

#### Full Adder

Adds two bits plus a carry-in.

$$\text{Sum} = A \oplus B \oplus C_{in}$$ $$C_{out} = AB + C_{in}(A \oplus B)$$

A full adder requires 5 gates in the canonical two-level implementation, or two half adders plus an OR gate.

#### Ripple Carry Adder

$n$ full adders chained so that $C_{out}$ of stage $i$ feeds $C_{in}$ of stage $i+1$. Simple but slow: delay grows linearly with $n$ since carry must ripple through every stage.

$$T_{RCA} = t_{FA} \cdot n$$

#### Carry Lookahead Adder (CLA)

Eliminates the ripple by computing carry signals in parallel using two auxiliary signals per bit position:

$$G_i = A_i B_i \qquad (\text{generate: carry produced regardless of } C_{in})$$ $$P_i = A_i \oplus B_i \qquad (\text{propagate: carry passed through if } C_{in}=1)$$

Carry at position $i$:

$$C_{i+1} = G_i + P_i C_i$$

Expanding recursively eliminates the chain dependency. A 4-bit CLA computes all four carry signals simultaneously in two logic levels, making delay $O(\log n)$ for hierarchical extension.

#### Comparator

Compares two $n$-bit values $A$ and $B$, asserting one of three outputs: $A>B$, $A=B$, $A<B$.

**Equality:** $E = \prod_{i=0}^{n-1}(A_i \odot B_i)$ — all bit positions must match (XNOR on each bit, AND all results).

**Magnitude:** Determined by finding the most significant bit position where $A_i \neq B_i$.

#### ALU (Arithmetic Logic Unit)

An ALU combines multiple arithmetic and logical functions, selected by control inputs. Its combinational structure is a MUX tree over the outputs of parallel functional units (adder, AND array, OR array, XOR array, comparator). The ALU is not a sequential element — it is purely combinational, though it feeds into and is fed from registers in the datapath.

---

### Two-Level vs. Multi-Level Logic

|Property|Two-Level|Multi-Level|
|---|---|---|
|Delay|Bounded (2 gate delays)|Proportional to depth|
|Area/gate count|High (all minterms explicit)|Low (shared subexpressions)|
|Hazard analysis|Straightforward|Complex|
|Fan-in requirement|Can be large|Manageable with limited fan-in|

Two-level logic (SOP/POS) is analytically clean and easily minimized via Karnaugh maps. Multi-level logic is preferred in practice when fan-in is constrained (standard cell libraries impose maximum fan-in of 4–6) or when subexpressions are shared across multiple outputs.

**Factoring example:**

Two-level: $f = ABC + ABD + AEF + AEG$  
Multi-level: $f = A(B(C+D) + E(F+G))$ — four fewer gate inputs, one additional logic level.

---

### Programmable Logic Implementations

Combinational logic maps directly onto programmable structures:

**ROM (Read-Only Memory):** Implements any function as a lookup table. An $n$-input ROM has $2^n$ words, one per minterm. Straightforward but exponential in input count.

**PLA (Programmable Logic Array):** Programmable AND plane followed by programmable OR plane. Implements a set of SOP expressions sharing product terms. Area-efficient when many outputs share the same product terms.

**PAL (Programmable Array Logic):** Fixed OR plane, programmable AND plane. Less flexible than PLA but faster and simpler.

**FPGA LUT (Look-Up Table):** A $k$-input LUT is a $2^k$-entry RAM acting as a truth table. Modern FPGAs use 6-input LUTs. Any 6-variable Boolean function maps to a single LUT; larger functions require multiple LUTs connected via routing fabric.

---

### Worked Design Example: 3-to-8 Decoder

**Specification:** Inputs $A_2 A_1 A_0$ (3-bit binary); outputs $O_0 \ldots O_7$; exactly one output asserted high for each input combination.

**Boolean expressions:**

$$O_0 = \bar{A_2}\bar{A_1}\bar{A_0} \quad O_1 = \bar{A_2}\bar{A_1}A_0 \quad O_2 = \bar{A_2}A_1\bar{A_0} \quad O_3 = \bar{A_2}A_1A_0$$ $$O_4 = A_2\bar{A_1}\bar{A_0} \quad O_5 = A_2\bar{A_1}A_0 \quad O_6 = A_2A_1\bar{A_0} \quad O_7 = A_2A_1A_0$$

Each output is a 3-literal AND gate. All eight AND gates share the same six literal inputs ($A_2, A_1, A_0, \bar{A_2}, \bar{A_1}, \bar{A_0}$), so three NOT gates suffice. Total: 3 NOT + 8 AND gates.

**Expansion to larger decoders:** Two 3-to-8 decoders with an additional address bit on their enable inputs form a 4-to-16 decoder without redesign.

---

The diagram below illustrates the internal structure of core combinational building blocks — half adder, full adder, 2-to-1 MUX, and 2-to-4 decoder — showing gate-level interconnections.---

### Functional Completeness and Gate Universality

A set of gates is **functionally complete** if every Boolean function can be expressed using only gates from that set. The single-element sets `{NAND}` and `{NOR}` are each independently complete.

**NAND as universal gate:**

$$\text{NOT: } \overline{A} = \overline{A \cdot A}$$ $$\text{AND: } A \cdot B = \overline{\overline{A \cdot B}} \quad (\text{NAND followed by NAND-as-NOT})$$ $$\text{OR: } A + B = \overline{\bar{A} \cdot \bar{B}} \quad (\text{De Morgan})$$

This is significant in fabrication: CMOS NAND gates are physically simpler and faster than AND gates (AND is NAND + inverter in CMOS), so synthesis tools preferentially target NAND-based implementations.

---

### Logic Families and Fan-In/Fan-Out

Physical implementation constraints interact with combinational design:

**Fan-in** is the maximum number of inputs a gate can accept. Standard cell libraries typically cap fan-in at 4 or 6. Functions requiring more inputs must be decomposed into a tree of smaller gates, adding logic levels.

**Fan-out** is the number of gate inputs a single output can drive without signal degradation. Exceeding fan-out requires **buffer insertion** — adding inverter pairs (to preserve polarity) or specialized buffer gates.

**Logic effort** (from the Logical Effort methodology) quantifies the delay contribution of a gate relative to an ideal inverter, enabling systematic comparison of multi-stage implementations and optimal stage sizing for minimum delay.

---

### **Key Points**

- A combinational circuit's output depends only on its current inputs — no memory, no feedback, no internal state.
- Any Boolean function is realizable; the set `{NAND}` alone is sufficient for all combinational logic.
- Two-level (SOP/POS) implementations have predictable, bounded delay but may require large fan-in; multi-level implementations reduce gate count at the cost of added logic levels.
- Hazards arise from unequal path delays; static hazards in SOP are eliminated by adding consensus terms.
- Standard building blocks — adders, MUXes, decoders, comparators — are composable into arbitrarily complex datapath logic.
- Physical constraints (fan-in, fan-out, drive strength) govern how a minimized Boolean expression translates to actual gates.

---

**Next Steps**

The natural progression from combinational circuits leads to **Sequential Logic Circuits** — once feedback and memory elements (latches, flip-flops) are introduced, circuits gain state, and analysis requires finite state machine formalism rather than pure Boolean algebra. Timing analysis also becomes substantially more involved, as setup and hold constraints on flip-flop inputs interact with combinational path delays.

---

