## Karnaugh Maps


A Karnaugh map (K-map) is a graphical method for minimizing Boolean expressions by exploiting visual adjacency to group minterms. The underlying mechanism is the consensus theorem: two terms differing in exactly one variable can be merged by eliminating that variable.

---

### Theoretical Basis

For any Boolean expression, the sum-of-minterms (canonical SOP) and product-of-maxterms (canonical POS) forms are unique but rarely minimal. K-maps perform prime implicant extraction visually. A **prime implicant** is a maximal group of 2ⁿ minterms that cannot be absorbed into a larger group. An **essential prime implicant** covers at least one minterm covered by no other prime implicant.

The minimization objective: find a minimal cover — fewest prime implicants of largest size — such that every minterm is covered at least once.

---

### Map Construction and Gray Code Ordering

Variables are distributed across axes using **Gray code** (reflected binary), ensuring adjacent cells differ in exactly one bit. This is the structural guarantee that makes adjacency meaningful.

|Variables|Axes|Map size|
|---|---|---|
|2|1×1 per axis|2×2|
|3|1 var / 2 vars|2×4|
|4|2 vars / 2 vars|4×4|
|5|2 vars / 3 vars|4×8 (or two 4×4 planes)|
|6|3 vars / 3 vars|8×8|

Gray code column/row ordering for 4-variable map:

```
      CD
AB    00  01  11  10
00  [  ][  ][  ][  ]
01  [  ][  ][  ][  ]
11  [  ][  ][  ][  ]
10  [  ][  ][  ][  ]
```

Minterm numbering: the cell at (AB=00, CD=00) is m₀; (AB=01, CD=11) is m₇, etc. Cell index = decimal value of ABCD concatenated.

---

### Grouping Rules

Groups must satisfy:

- Size is a power of 2: 1, 2, 4, 8, 16, …
- All cells in a group contain 1 (for SOP) or 0 (for POS)
- Cells must be adjacent — including **wrap-around adjacency** (top row wraps to bottom, leftmost column wraps to rightmost)
- Groups must be rectangular (after accounting for wrap-around)

Each group of size 2ⁿ eliminates n variables. A group of 4 minterms → eliminates 2 variables from the term. A group of 8 → eliminates 3 variables.

**Wrap-around adjacency** is the most commonly misapplied rule. The map is topologically a torus: all four corners form a valid group of 4.

---

### Minimization Algorithm

1. Plot all minterms (1s) and don't-care positions (X) on the map.
2. Identify all prime implicants — the largest valid groups covering each minterm.
3. Identify essential prime implicants — those covering at least one minterm uncovered by any other prime implicant.
4. Select remaining prime implicants greedily to cover any uncovered minterms, preferring larger groups.
5. Write the minimized SOP: one product term per selected group, retaining only variables constant within the group.

Don't-care cells (X) may be treated as 1 when expanding a group but need not be covered.

---

### Reading the Simplified Term

For a selected group, examine each variable:

- If the variable is **0 throughout** the group → it appears complemented in the term.
- If the variable is **1 throughout** the group → it appears uncomplemented.
- If the variable **changes** within the group → it is eliminated.

**Example:** A group covering cells where AB = 01 and CD varies across 00, 01, 10, 11 → A is 0, B is 1, C and D vary → term = **A'B**.

---

### POS Minimization

For product-of-sums: group the **0s** (maxterms) instead. Each group produces a sum term. Variables constant at 0 in the group appear uncomplemented; constant at 1 appear complemented. The final expression is the product of all selected sum terms.

---

### Five and Six Variable Maps

Beyond four variables, a single 2D grid cannot represent all adjacencies simultaneously.

**5-variable:** Implemented as two overlaid 4×4 maps (one for A=0, one for A=1). Cells at the same position across both planes are adjacent. Groups spanning both planes must occupy identical positions in each plane.

**6-variable:** Four 4×4 planes. Becomes unwieldy; at this scale, Quine–McCluskey or espresso algorithms are preferable.

---

### Comparison with Quine–McCluskey

|Property|K-map|Quine–McCluskey|
|---|---|---|
|Input size|≤ 4 vars (practical)|Arbitrary|
|Method|Visual grouping|Tabular prime implicant generation|
|Automation|Not directly automatable|Fully algorithmic|
|Error surface|Mis-grouping, missed wrap-arounds|Column tabulation errors|
|Output|Minimal SOP/POS directly|Prime implicant table → covering problem|

Both target the same minimal cover. Quine–McCluskey solves the same problem algorithmically and is the basis for tools like espresso.

---

### Worked Example — 4-Variable Minimization**Example:** F = Σm(0,1,3,7,8,9,11,15)

The two prime implicants are **B'C'** (the wrap-around group spanning the top and bottom rows across the first two columns) and **CD** (the full column of CD=11). Both are essential — B'C' is the only group covering m0 and m8; CD is the only group covering m7 and m15. Together they cover all eight minterms without overlap redundancy.

**F = B'C' + CD** — two terms, two variables each, reduced from eight minterms.

---

### Common Errors

**Missed wrap-around adjacency.** The four-corner group and the top-bottom, left-right column/row wraps are the most frequently missed. The map is a torus; edges connect.

**Non-power-of-2 groups.** Groups of 3, 5, 6, or any non-power-of-2 are invalid regardless of adjacency.

**Non-rectangular groups.** After wrap-around resolution, all groups must resolve to a rectangle on the torus. L-shapes, T-shapes, and diagonals are invalid.

**Premature covering.** Selecting a smaller group when a larger prime implicant exists wastes terms. Always maximize group size before selecting.

**Ignoring don't-cares in expansion.** Don't-care cells can enlarge groups and must be considered during prime implicant identification, even if they need not appear in the final cover.

---

**Next Steps:** Quine–McCluskey tabular minimization · Petrick's method for minimal cover selection · ESPRESSO heuristic minimization · Application to PLA and PAL programmable logic structures.

---

