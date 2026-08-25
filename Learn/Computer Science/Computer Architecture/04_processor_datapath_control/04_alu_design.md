## ALU Design


The Arithmetic Logic Unit is the computational core of a processor datapath — a purely combinational circuit that performs arithmetic and bitwise logical operations on binary operands under the direction of control signals. Every instruction that transforms data passes through or is implemented by the ALU. Its design determines the set of operations the processor can perform in a single cycle, the critical path delay through the datapath, and the silicon area devoted to computation.

---

### Functional Specification

An ALU accepts two $n$-bit operands $A$ and $B$, a set of control signals $F$ selecting the operation, and optionally a carry-in $C_{in}$. It produces an $n$-bit result $R$ and a set of status flags.

$$\text{ALU}: (A, B, F, C_{in}) \rightarrow (R, \text{flags})$$

The control input $F$ indexes the operation table. For a minimal 4-operation ALU, 2 control bits suffice; a full-featured ALU with arithmetic, logic, shift, and comparison operations may require 4–6 control bits.

**Standard status flags:**

|Flag|Symbol|Condition|
|---|---|---|
|Zero|Z|$R = 0$|
|Carry|C|Unsigned overflow / borrow|
|Negative|N|$R[n-1] = 1$ (sign bit set)|
|Overflow|V|Signed overflow|
|Parity|P|XOR of all result bits|

These flags feed the branch logic — conditional branches test one or more flags rather than inspecting the full result register.

---

### One-Bit ALU Cell

The fundamental building block is a 1-bit ALU slice. An $n$-bit ALU is constructed by replicating this cell $n$ times and connecting carry signals between adjacent cells.

A 1-bit ALU cell capable of AND, OR, and addition contains:

- One AND gate
- One OR gate
- One full adder
- A MUX selecting among the three operation outputs

For subtraction, $B$ is complemented and $C_{in}$ of the LSB cell is set to 1, implementing two's complement negation: $A - B = A + \bar{B} + 1$.

The operation select MUX is the defining structure. With control signals $F_1 F_0$:

|$F_1$|$F_0$|Operation|
|---|---|---|
|0|0|AND|
|0|1|OR|
|1|0|ADD|
|1|1|SUB (via $\bar{B}$, $C_{in}=1$)|

The full adder sum output, AND output, and OR output are computed in parallel; the MUX selects among them based on $F$.

---

### Ripple Carry ALU

The simplest $n$-bit ALU chains $n$ 1-bit cells, passing $C_{out}$ of cell $i$ to $C_{in}$ of cell $i+1$.

**Delay analysis:**

The critical path runs from inputs $A_0, B_0$ through the carry chain to the most significant bit:

$$T_{ALU} = T_{setup} + n \cdot T_{carry} + T_{sum}$$

where $T_{carry}$ is the carry propagation delay through one full adder stage (typically 2 gate delays for a standard CMOS full adder). For a 32-bit ripple carry ALU at $T_{carry} = 2$ gate delays:

$$T_{ALU} = 2 + 32 \times 2 + 2 = 68 \text{ gate delays}$$

This is acceptable for low-frequency designs but becomes the datapath critical path in any pipelined processor operating above a few hundred MHz.

---

### Carry Lookahead ALU

The carry lookahead adder (CLA) eliminates the ripple by precomputing all carry signals simultaneously. Each bit position defines:

$$G_i = A_i \cdot B_i \qquad \text{(generate: this position produces a carry regardless of } C_{in}\text{)}$$ $$P_i = A_i \oplus B_i \qquad \text{(propagate: this position passes a carry through if one arrives)}$$

Carry at each position is then:

$$C_1 = G_0 + P_0 C_0$$ $$C_2 = G_1 + P_1 G_0 + P_1 P_0 C_0$$ $$C_3 = G_2 + P_2 G_1 + P_2 P_1 G_0 + P_2 P_1 P_0 C_0$$ $$C_i = G_{i-1} + P_{i-1}G_{i-2} + \cdots + \left(\prod_{j=0}^{i-1} P_j\right) C_0$$

All carry signals are computed in two logic levels regardless of $n$, after a one-level $G/P$ generation stage. Total delay:

$$T_{CLA} = T_{GP} + T_{carry} + T_{sum} = 3 \times 2 = 6 \text{ gate delays (4-bit)}$$

**Hierarchical CLA:** A single CLA block scales poorly beyond 16 bits because the carry equations become excessively wide (high fan-in). The solution is a two-level hierarchy: group-level $G$ and $P$ signals summarize each 4-bit block, and a second CLA layer computes inter-group carries.

$$G_{[0:3]} = G_3 + P_3 G_2 + P_3 P_2 G_1 + P_3 P_2 P_1 G_0$$ $$P_{[0:3]} = P_3 P_2 P_1 P_0$$

A 64-bit ALU built from 4-bit CLA blocks with a 16-block second-level CLA runs in approximately 10–12 gate delays — constant and independent of word width.

---

### Carry Select and Carry Save Adders

**Carry select adder:** Each group of $k$ bits is duplicated — one copy assumes $C_{in}=0$, the other assumes $C_{in}=1$. Both compute their sum and carry simultaneously. When the actual carry arrives from the previous group, a MUX selects the correct pre-computed result. Delay is reduced to MUX propagation along the carry chain rather than full adder propagation.

$$T_{CSA-select} = T_{GP} + \lceil n/k \rceil \times T_{MUX}$$

**Carry save adder (CSA):** Used when three or more operands must be summed (multiplication reduction, multiply-accumulate). Instead of producing a single sum, a CSA accepts three inputs $A, B, C$ and produces two outputs — a partial sum $S$ and a carry vector $K$ — without propagating carries:

$$S_i = A_i \oplus B_i \oplus C_i$$ $$K_i = A_i B_i + A_i C_i + B_i C_i \qquad (\text{carry shifted left by 1 before final add})$$

CSA trees (Wallace trees) reduce $m$ operands to 2 in $O(\log_{3/2} m)$ CSA levels, after which a single fast adder produces the final result. This is the standard architecture for hardware multipliers.

---

### Shifter Design

Most ALUs incorporate a barrel shifter — a combinational circuit that shifts an $n$-bit value by any amount from 0 to $n-1$ in a single operation with constant delay.

**Construction:** A barrel shifter is built as a tree of MUX stages. For an $n$-bit shifter with $\log_2 n$ stages, stage $k$ either shifts by $2^k$ positions or passes the value unchanged, controlled by bit $k$ of the shift amount.

For a 4-bit left barrel shifter (shift amount $s = s_1 s_0$):

- Stage 0 ($s_0$): shift by 0 or 1
- Stage 1 ($s_1$): shift by 0 or 2

Delay: $\log_2 n$ MUX delays — for 64-bit, 6 MUX levels, each approximately 1–2 gate delays.

**Shift operations supported:**

|Operation|Behavior|Use|
|---|---|---|
|Logical left shift (LSL)|Shift left, fill with 0|Multiply by $2^k$|
|Logical right shift (LSR)|Shift right, fill with 0|Unsigned divide by $2^k$|
|Arithmetic right shift (ASR)|Shift right, fill with sign bit|Signed divide by $2^k$|
|Rotate right (ROR)|Wrap bits around|Cryptography, bit manipulation|
|Rotate through carry (RRC)|Rotate including carry flag|Extended precision shift|

The fill bit selection (0 vs. sign bit vs. carry) is a final MUX controlled by the operation type.

---

### Overflow Detection

Overflow detection is operation-dependent and must be implemented as a separate combinational circuit whose output sets the V flag.

**Unsigned overflow (carry out):**

$$C_{overflow} = C_{out}$$

Addition overflows unsigned range when carry propagates out of the MSB.

**Signed overflow (two's complement):**

Overflow occurs when operands have the same sign but the result has the opposite sign:

$$V = C_{n-1} \oplus C_n$$

where $C_{n-1}$ is carry into the sign bit and $C_n$ is carry out of the sign bit. Equivalently:

$$V = (\bar{A}_{n-1} \cdot \bar{B}_{n-1} \cdot R_{n-1}) + (A_{n-1} \cdot B_{n-1} \cdot \bar{R}_{n-1})$$

**Subtraction overflow:**

For $A - B$, implemented as $A + \bar{B} + 1$, the same $V = C_{n-1} \oplus C_n$ formula applies with $B$ replaced by $\bar{B}$.

**Zero flag:**

$$Z = \overline{R_{n-1} + R_{n-2} + \cdots + R_0}$$

A large NOR tree across all result bits. For 64-bit results, this is a 6-level NOR tree, potentially on the critical path if not carefully designed.

---

### Comparison Operations

Many ISAs include a set-less-than (SLT) or compare instruction. Rather than implementing comparison as a separate functional unit, it is derived from the subtraction result:

**Signed $A < B$:**

$$\text{SLT} = N \oplus V$$

The result is 1 when the sign flag differs from the overflow flag — capturing the case where subtraction wraps due to overflow.

**Unsigned $A < B$ (set-less-than-unsigned, SLTU):**

$$\text{SLTU} = C_{borrow} = \overline{C_{out}}$$

Unsigned comparison is simply the absence of a carry out from subtraction.

The SLT result is placed into a register as a 0 or 1 value (0-extended), which can then be used by branch instructions. RISC-V uses this approach: `slt rd, rs1, rs2` writes 1 to `rd` if `rs1 < rs2` signed, 0 otherwise, and branch instructions test registers directly rather than flags.

---

### Flag-Based vs. Condition-Code-Free Designs

There are two architectural approaches to communicating ALU results to branch logic:

**Condition code registers (x86, ARM32):** The ALU writes N, Z, C, V flags to a dedicated status register after every (flag-modifying) instruction. Branch instructions read this register. Advantage: branches require no additional operand. Disadvantage: the flag register is a hidden dependency that complicates out-of-order execution — a branch cannot be scheduled before the instruction that sets its flags.

**Compare-and-branch / explicit comparison (RISC-V, MIPS):** No flag register exists. Comparison instructions write a 0/1 result to a GPR. Branch instructions take two register operands and compare them directly (`beq rs1, rs2, offset`). The dependency is explicit in the register operands, making it transparent to the out-of-order scheduler.

ARM64 (AArch64) takes a hybrid approach: condition codes are retained but compare-and-branch instructions (`CBZ`, `CBNZ`, `TBZ`) are added for the common case of comparing against zero, avoiding flag writes in those paths.

---

### Multi-Function ALU Architecture

A production ALU integrates arithmetic, logic, shift, and comparison into a unified structure with a wide operation MUX at the output stage.

The parallel functional units compute simultaneously; the final MUX selects the relevant result. This is the key implementation insight: the ALU does not sequentially try operations — all functional units operate on the inputs every cycle, and the control logic selects among the already-computed results.

The result MUX is on the critical path, and its delay adds directly to the ALU cycle time. For a 4-to-1 MUX selecting among adder result, AND result, OR result, and shift result, this is 1–2 additional gate delays after the slowest functional unit (the adder) completes.

---

### Critical Path and Timing

The ALU critical path determines the minimum clock period of a non-pipelined datapath. For a 32-bit ALU with carry lookahead:

|Stage|Delay|
|---|---|
|Input inversion (for SUB)|1 gate delay|
|G/P generation|1 gate delay|
|4-bit CLA carry|2 gate delays|
|Group carry (hierarchical)|2 gate delays|
|Sum generation|2 gate delays|
|Result MUX|2 gate delays|
|Zero flag NOR tree|3 gate delays|
|**Total (approx.)**|**~13 gate delays**|

The zero flag detection is frequently on or near the critical path for wide ALUs. One optimization is to compute the zero flag speculatively during the carry propagation phase rather than after the full sum is available.

---

The diagram below shows the internal structure of a complete 1-bit ALU cell and its extension to an $n$-bit carry lookahead ALU, alongside the operation MUX and flag generation logic.---

### Barrel Shifter Integration

The barrel shifter is typically implemented as a separate parallel unit whose output feeds the operation select MUX alongside the adder and logic results. It does not share gates with the adder — both units compute simultaneously every cycle. The MUX control signal determines which result is written to the destination register.

For a 32-bit barrel shifter using a 5-stage MUX tree (shift amounts 1, 2, 4, 8, 16):

$$T_{barrel} = 5 \times T_{MUX} \approx 10 \text{ gate delays}$$

This is faster than the CLA adder on the same critical path, so the barrel shifter does not determine the ALU cycle time for 32-bit designs. For 64-bit designs, 6 MUX stages are required, and the barrel shifter delay becomes comparable to the adder.

---

### ALU in the Datapath Context

The ALU does not operate in isolation. Its position in the datapath imposes additional timing constraints:

**Register file read** precedes the ALU. The register file access time ($T_{RF}$) adds to the cycle time before the ALU even receives its inputs. Register file read is typically 2–4 gate delays in a standard cell implementation.

**Result MUX** follows the ALU when forwarding is implemented. Data forwarding paths in a pipelined processor route the ALU output back to its own inputs (for back-to-back dependent instructions), adding a MUX on the ALU input path. This MUX delay appears before every ALU operation and is part of the effective cycle time.

**Sign extension** for immediate operands must be completed before the ALU receives the B operand. Sign extension is a wiring operation (no gates required for the extension itself), but it is logically part of the input preparation stage.

The total single-cycle datapath delay including the ALU is therefore:

$$T_{cycle} = T_{RF-read} + T_{mux-forward} + T_{sext} + T_{ALU} + T_{RF-write}$$

For a simple RISC datapath, this sum is typically 15–25 gate delays, which at 2 ns per gate delay yields a maximum clock of ~25–35 MHz for a non-pipelined single-cycle design — illustrating why pipelining is necessary for GHz-class operation.

---

### **Key Points**

- The ALU is a purely combinational circuit; all functional units (adder, logic, shifter) compute simultaneously and a MUX selects the result.
- Subtraction is implemented as addition of the two's complement: $A - B = A + \bar{B} + 1$, requiring only a controllable inverter on the $B$ input and a forced $C_{in} = 1$.
- Carry propagation is the fundamental speed bottleneck; CLA eliminates the linear carry chain at the cost of wider gate inputs, and hierarchical CLA extends this to arbitrary word widths with $O(\log n)$ delay.
- Overflow detection requires distinguishing signed and unsigned interpretations: signed overflow is $V = C_{n-1} \oplus C_n$; unsigned overflow is simply $C_{out}$.
- The zero flag NOR tree across all result bits is frequently on or near the critical path for wide ALUs and must be designed carefully.
- Flag-based condition codes (x86, ARM32) create implicit register dependencies that complicate out-of-order scheduling; compare-and-branch designs (RISC-V) expose the dependency explicitly in the register operands.

---

**Next Steps**

ALU design feeds directly into **single-cycle and multi-cycle datapath design** — how the ALU is embedded in a complete processor with register files, memory ports, control logic, and the program counter. The subsequent topic of **pipelining** then introduces the timing constraints that force the datapath to be partitioned into stages, with the ALU occupying exactly one pipeline stage bounded by pipeline registers on each side.

---

