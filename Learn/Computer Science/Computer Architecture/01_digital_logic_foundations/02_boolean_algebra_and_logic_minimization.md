## Boolean Algebra and Logic Minimization


Boolean algebra is a mathematical framework for analyzing and simplifying logic expressions. It operates on binary variables and forms the theoretical basis for digital circuit design and optimization.

---

### Boolean Variables and Constants

A Boolean variable takes one of two values: **0** (false) or **1** (true). The three fundamental operations are:

|Operation|Symbol|Expression|Meaning|
|---|---|---|---|
|AND|· or ∧|A · B|Both must be 1|
|OR|+ or ∨|A + B|At least one must be 1|
|NOT|¯ or ¬|Ā|Inversion|

---

### Fundamental Laws and Identities

#### Identity Laws

```
A + 0 = A
A · 1 = A
```

#### Null (Dominance) Laws

```
A + 1 = 1
A · 0 = 0
```

#### Idempotent Laws

```
A + A = A
A · A = A
```

#### Complement Laws

```
A + Ā = 1
A · Ā = 0
```

#### Involution Law

```
Ā̄ = A
```

#### Commutative Laws

```
A + B = B + A
A · B = B · A
```

#### Associative Laws

```
(A + B) + C = A + (B + C)
(A · B) · C = A · (B · C)
```

#### Distributive Laws

```
A · (B + C) = A·B + A·C
A + (B · C) = (A + B) · (A + C)
```

#### Absorption Laws

```
A + A·B = A
A · (A + B) = A
```

#### De Morgan's Theorems

$$\overline{A \cdot B} = \bar A + \bar B$$
$$\overline{A + B} = \bar A \cdot \bar B$$

De Morgan's theorems are critical in practice: they allow conversion between AND-OR and OR-AND forms, and enable expression using only NAND or only NOR gates.

---

### Canonical Forms

Any Boolean expression can be represented in two standard canonical forms.

#### Sum of Minterms (SOM) — Sum of Products (SOP)

A **minterm** for _n_ variables is a product term where each variable appears exactly once (complemented or uncomplemented). For two variables A, B:

| Index | A   | B   | Minterm |
| ----- | --- | --- | ------- |
| m₀    | 0   | 0   | Ā·B̄    |
| m₁    | 0   | 1   | Ā·B     |
| m₂    | 1   | 0   | A·B̄    |
| m₃    | 1   | 1   | A·B     |

A function is expressed as the sum of all minterms for which the output is 1:

```
F = Σm(1, 2) = Ā·B + A·B̄
```

**Core intuition**
- Minterms describe exact rows of a truth table.
- A complemented variable means “this variable must be 0.”
- An uncomplemented variable means “this variable must be 1.”
- Summing minterms means OR-ing together all rows where the output should be true.

#### Product of Maxterms (POM) — Product of Sums (POS)

A **maxterm** is a sum term where each variable appears exactly once. It is the dual of the minterm. The function is the product of all maxterms where the output is 0:

```
F = ΠM(0, 3) = (A + B)·(Ā + B̄)
```

SOP and POS are duals; minimizing one is equivalent to minimizing the other.

**Core Intuition for POS / Maxterms**
- Maxterms describe exact rows where the function is **0**.
- In a maxterm:
    - an **uncomplemented** variable means “this variable must be 0”
    - a **complemented** variable means “this variable must be 1”
- Each maxterm is constructed so the entire sum becomes 0 for exactly one row.
- Taking the product of maxterms means AND-ing together all rows where the output should be false.

The key intuition is:

- **SOP / minterms** describe where the function is **1**
- **POS / maxterms** describe where the function is **0**

- **minterms select a row**
- **maxterms reject a row**

---

### Logic Minimization

Minimization reduces a Boolean expression to a simpler, equivalent form — fewer literals and terms — to reduce gate count, propagation delay, and power consumption.

#### Algebraic Minimization

Uses the laws above to reduce expressions by hand. This approach is not systematic for large expressions.

**Example:**

```
F = A·B·C + A·B·C̄
  = A·B·(C + C̄)
  = A·B·1
  = A·B
```

---

### Karnaugh Map (K-Map) Method

The K-map is a graphical tool for systematic minimization of expressions with up to 5–6 variables. It exploits the visual grouping of adjacent minterms that differ by exactly one variable (Gray code ordering).

#### K-Map Structure

Cells are arranged so that adjacent cells differ in exactly one variable (including wrap-around edges).

**2-Variable K-Map:**

<svg viewBox="0 0 260 160" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="14">
  <!-- Outer border -->
  <rect x="60" y="40" width="160" height="80" fill="none" stroke="#ccc" stroke-width="1.5"/>
  <!-- Cell dividers -->
  <line x1="140" y1="40" x2="140" y2="120" stroke="#ccc" stroke-width="1"/>
  <line x1="60" y1="80" x2="220" y2="80" stroke="#ccc" stroke-width="1"/>
  <!-- Column headers -->
  <text x="100" y="30" text-anchor="middle" fill="#aaa">B=0</text>
  <text x="180" y="30" text-anchor="middle" fill="#aaa">B=1</text>
  <!-- Row headers -->
  <text x="45" y="65" text-anchor="middle" fill="#aaa">A=0</text>
  <text x="45" y="105" text-anchor="middle" fill="#aaa">A=1</text>
  <!-- Cell labels -->
  <text x="100" y="65" text-anchor="middle" fill="#e0e0e0">m₀</text>
  <text x="180" y="65" text-anchor="middle" fill="#e0e0e0">m₁</text>
  <text x="100" y="105" text-anchor="middle" fill="#e0e0e0">m₂</text>
  <text x="180" y="105" text-anchor="middle" fill="#e0e0e0">m₃</text>
</svg>

**3-Variable K-Map (A vs BC):**

<svg viewBox="0 0 340 160" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">
  <rect x="60" y="40" width="240" height="80" fill="none" stroke="#ccc" stroke-width="1.5"/>
  <line x1="120" y1="40" x2="120" y2="120" stroke="#ccc" stroke-width="1"/>
  <line x1="180" y1="40" x2="180" y2="120" stroke="#ccc" stroke-width="1"/>
  <line x1="240" y1="40" x2="240" y2="120" stroke="#ccc" stroke-width="1"/>
  <line x1="60" y1="80" x2="300" y2="80" stroke="#ccc" stroke-width="1"/>
  <!-- Column headers (Gray code) -->
  <text x="90"  y="30" text-anchor="middle" fill="#aaa">BC=00</text>
  <text x="150" y="30" text-anchor="middle" fill="#aaa">BC=01</text>
  <text x="210" y="30" text-anchor="middle" fill="#aaa">BC=11</text>
  <text x="270" y="30" text-anchor="middle" fill="#aaa">BC=10</text>
  <!-- Row headers -->
  <text x="40" y="65"  text-anchor="middle" fill="#aaa">A=0</text>
  <text x="40" y="105" text-anchor="middle" fill="#aaa">A=1</text>
  <!-- Minterm indices -->
  <text x="90"  y="65"  text-anchor="middle" fill="#e0e0e0">0</text>
  <text x="150" y="65"  text-anchor="middle" fill="#e0e0e0">1</text>
  <text x="210" y="65"  text-anchor="middle" fill="#e0e0e0">3</text>
  <text x="270" y="65"  text-anchor="middle" fill="#e0e0e0">2</text>
  <text x="90"  y="105" text-anchor="middle" fill="#e0e0e0">4</text>
  <text x="150" y="105" text-anchor="middle" fill="#e0e0e0">5</text>
  <text x="210" y="105" text-anchor="middle" fill="#e0e0e0">7</text>
  <text x="270" y="105" text-anchor="middle" fill="#e0e0e0">6</text>
</svg>

Note the **Gray code column ordering** (00, 01, 11, 10) — not binary order. This ensures adjacency between all neighboring cells.

#### Grouping Rules

- Groups must be powers of 2: 1, 2, 4, 8, 16 cells
- Groups must be rectangular (including wrap-around)
- Each group must contain only 1s
- Use the **largest possible groups** (prime implicants)
- Each 1 must be covered by at least one group
- Overlapping is allowed and encouraged

#### Implicant Terminology

|Term|Definition|
|---|---|
|**Implicant**|Any valid group of 1s|
|**Prime Implicant (PI)**|An implicant that cannot be combined further|
|**Essential Prime Implicant (EPI)**|A PI that is the **only** group covering a given minterm|

The minimal SOP expression is: all EPIs + minimum additional PIs to cover remaining uncovered minterms.

#### Don't-Care Conditions

Denoted **X** or **d** in K-maps. These are input combinations that either cannot occur or whose output is irrelevant. They may be treated as 0 or 1 — whichever produces larger groups.

---

### Worked K-Map Example

**Given:** F(A,B,C,D) = Σm(0, 1, 3, 7, 8, 9, 11, 15)

**4-Variable K-Map:**

```svg
<svg viewBox="0 0 420 200" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">
  <!-- Grid -->
  <rect x="80" y="50" width="320" height="120" fill="none" stroke="#ccc" stroke-width="1.5"/>
  <line x1="160" y1="50" x2="160" y2="170" stroke="#ccc" stroke-width="1"/>
  <line x1="240" y1="50" x2="240" y2="170" stroke="#ccc" stroke-width="1"/>
  <line x1="320" y1="50" x2="320" y2="170" stroke="#ccc" stroke-width="1"/>
  <line x1="80"  y1="110" x2="400" y2="110" stroke="#ccc" stroke-width="1"/>

  <!-- Column headers -->
  <text x="120" y="40" text-anchor="middle" fill="#aaa">CD=00</text>
  <text x="200" y="40" text-anchor="middle" fill="#aaa">CD=01</text>
  <text x="280" y="40" text-anchor="middle" fill="#aaa">CD=11</text>
  <text x="360" y="40" text-anchor="middle" fill="#aaa">CD=10</text>

  <!-- Row headers -->
  <text x="50" y="85"  text-anchor="middle" fill="#aaa">AB=00</text>
  <text x="50" y="145" text-anchor="middle" fill="#aaa">AB=10</text>

  <!-- Wait — need full 4-row map; using 4 rows -->
</svg>
```

A full 4-variable map has 4 rows (AB: 00,01,11,10) and 4 columns (CD: 00,01,11,10). Filling in the minterms:

```
        CD
AB    00  01  11  10
00  [  1   1   1   0 ]   ← minterms 0,1,3
01  [  0   0   0   0 ]
11  [  0   1   1   0 ]   ← minterms 7 (AB=11,CD=11), wait—
10  [  1   1   1   0 ]   ← minterms 8,9,11
```

Recalculating minterm positions:

|Minterm|A|B|C|D|
|---|---|---|---|---|
|0|0|0|0|0|
|1|0|0|0|1|
|3|0|0|1|1|
|7|0|1|1|1|
|8|1|0|0|0|
|9|1|0|0|1|
|11|1|0|1|1|
|15|1|1|1|1|

```
        CD
AB    00  01  11  10
00  [  1   1   1   0 ]   m0  m1  m3
01  [  0   0   1   0 ]           m7
11  [  0   0   1   0 ]           m15
10  [  1   1   1   0 ]   m8  m9  m11
```

**Groups identified:**

1. **Group A** — {m0, m1, m8, m9}: column CD=00 and CD=01, rows AB=00 and AB=10 → B=0, C=0 → **B̄·C̄**
2. **Group B** — {m1, m3, m9, m11}: CD=01 and CD=11, rows AB=00 and AB=10 → B=0, D=1 → **B̄·D**
3. **Group C** — {m3, m7, m11, m15}: CD=11, all rows where C=1, D=1 → **C·D**

**Minimal SOP:**

```
F = B̄·C̄ + B̄·D + C·D
```

---

### Quine-McCluskey (Tabular) Method

The Quine-McCluskey (QM) method is an algorithmic alternative to K-maps, suitable for automated minimization with more than 4–5 variables.

#### Procedure

1. **List all minterms** in binary, grouped by the number of 1s in each.
2. **Combine adjacent groups**: two terms differing in exactly one bit are combined; the differing bit is replaced with a dash (–).
3. **Repeat** until no further combinations are possible. All uncombined terms are prime implicants.
4. **Build a prime implicant chart**: rows are PIs, columns are minterms. Cover all minterms using the minimum set of PIs.

**Example:** F = Σm(0, 1, 3, 7)

Step 1 — Grouping by number of 1-bits:

```
Group 0:  0 → 0000
Group 1:  1 → 0001
Group 2:  3 → 0011
Group 3:  7 → 0111
```

Step 2 — First merge pass:

```
(0,1)  → 000–   [differ at bit 0]
(1,3)  → 00–1   [differ at bit 1]
(3,7)  → 0–11   [differ at bit 2]
```

Step 3 — Second merge pass:

```
(0,1,2,3): 000– and 00–1 cannot combine (differ in two positions)
(1,3,5,7): 00–1 and 0–11 → 0––1  [differ at bit 2 only]
           (verify: covers m1,m3,m5,m7 — but m5 not in set, so check)
```

This continues iteratively. The final prime implicants are identified, and a covering table selects the minimum set.

QM is exact and automatable but exponential in the worst case. In practice, heuristic minimizers (e.g., Espresso) are used for large circuits.

---

### Two-Level vs. Multi-Level Logic

|Property|Two-Level (SOP/POS)|Multi-Level|
|---|---|---|
|Depth|Fixed (2 gate layers)|Variable|
|Delay|Predictable, low|May increase|
|Area|Higher (more literals)|Lower (factored forms)|
|Optimization|K-map, QM, Espresso|Factoring, decomposition|

**Example — Factoring:**

```
F = A·C + A·D + B·C + B·D
  = (A + B)·(C + D)          ← multi-level, fewer gates
```

---

### Espresso Algorithm

Espresso is a widely used heuristic two-level minimizer used in CAD tools (e.g., synthesis flows in Yosys, Cadence). It operates on a cover representation and iteratively applies three operations:

|Operation|Action|
|---|---|
|**Expand**|Grow each cube (implicant) to cover more minterms|
|**Irredundant**|Remove cubes that are covered by others|
|**Reduce**|Shrink cubes to enable further expansion in next iteration|

Espresso does not guarantee a globally optimal result but performs well in practice and runs in polynomial time.

---

### NAND-NAND and NOR-NOR Realizations

In practice, NAND and NOR gates are preferred because they are faster and cheaper to fabricate (fewer transistors in CMOS).

**SOP → NAND-NAND:**

By De Morgan's theorem:

```
F = A·B + C·D
  = ((A·B)' · (C·D)')'     ← double inversion
  = NAND(NAND(A,B), NAND(C,D))
```

Any SOP expression can be realized directly with two levels of NAND gates without modification.

**POS → NOR-NOR:**

Similarly, any POS expression maps directly to two levels of NOR gates.

---

### Hazards in Combinational Logic

Logic minimization can inadvertently introduce or remove hazards — momentary incorrect output transitions during input changes.

|Hazard Type|Description|
|---|---|
|**Static-1 hazard**|Output should remain 1 but briefly glitches to 0|
|**Static-0 hazard**|Output should remain 0 but briefly glitches to 1|
|**Dynamic hazard**|Output changes more than once during a single transition|

**Static-1 hazard detection:** In a K-map, a static-1 hazard exists when two adjacent 1s belong to different groups with no overlapping group. The hazard is eliminated by adding a **consensus term** — a redundant group in the K-map that bridges the two groups.

**Example:**

```
F = A·C̄ + B·C

When A=1, B=1, C transitions 0→1:
  At C=0: F = 1·1 + 1·0 = 1
  At C=1: F = 1·0 + 1·1 = 1
  During transition: brief glitch possible

Fix: Add consensus term A·B
  F = A·C̄ + B·C + A·B     ← hazard-free
```

---

**Key Points**

- Boolean algebra provides a closed algebraic system over {0,1} governed by a finite set of provable laws.
- Canonical SOP and POS forms are unique representations; minimized forms are not necessarily unique.
- K-maps are optimal for up to 4–5 variables; Quine-McCluskey and Espresso scale to larger designs.
- Essential prime implicants must always be included in a minimal cover; remaining PIs are selected by minimum cover.
- Don't-care conditions are a design resource — treating them as 1s can significantly reduce expression complexity.
- NAND-NAND and NOR-NOR realizations follow directly from SOP and POS forms via De Morgan's theorems.
- Hazard-free design requires redundant consensus terms that would otherwise be eliminated by minimization.

**Conclusion** Boolean algebra and logic minimization form the analytical and computational foundation of combinational circuit design. Mastery of minimization methods — algebraic, graphical (K-map), and algorithmic (QM, Espresso) — is necessary for producing area- and delay-efficient implementations. The transition from minimized expressions to gate-level realizations, and the awareness of hazards introduced by minimization, completes the path from specification to physical circuit.

**Next Steps**

- Karnaugh Maps (extended treatment: 5-variable, don't-cares, hazard elimination)
- Combinational Logic Circuits (adders, multiplexers, decoders, PLAs)
- Sequential Logic Circuits (how minimized combinational logic integrates with state elements)

---

