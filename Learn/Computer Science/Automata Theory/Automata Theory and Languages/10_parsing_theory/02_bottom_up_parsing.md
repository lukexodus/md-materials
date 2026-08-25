## Bottom-up parsing


**Setting.** Context-free grammar $G=\langle V,\Sigma,R,S\rangle$ with $V$ variables, $\Sigma$ terminals, $R$ productions, start symbol $S$. Parsing treats $w\in \Sigma^*$ and determines whether $w\in L(G)$ while reconstructing a derivation.

---

### Rightmost derivation in reverse

Bottom-up parsing constructs a **rightmost derivation in reverse**:

* Start from $w$ and repeatedly **reduce** substrings by applying inverse productions until $S$ is obtained.
* Each reduction step corresponds to replacing a sentential form substring $\alpha$ by variable $A$ whenever $A\to \alpha\in R$.
* Sequence of reductions reversed yields a rightmost derivation $S\Rightarrow_r^* w$.

Correctness criterion:

$$w\in L(G)\quad\Longleftrightarrow\quad S \xRightarrow{,r,*} w.$$

---

### Handles and viable prefixes

**Handle.** In a rightmost derivation
$$S\Rightarrow_r^* \gamma A w' \Rightarrow_r \gamma \alpha w',$$
the string $\alpha$ is the **handle** of $\gamma\alpha w'$ relative to the production $A\to\alpha$.

* A bottom-up parser must identify handles in $w$ for reduction.

**Viable prefix.** A prefix of a right-sentential form that never extends to the right of a handle. Characterization:

* Set of viable prefixes is a prefix-closed subset of $(V\cup\Sigma)^*$.
* Recognizable by a deterministic finite automaton constructed from LR items.

---

### Shift–reduce parsing

Parser maintains a stack over $V\cup\Sigma$:

* **Shift:** move next input symbol to stack.
* **Reduce:** replace handle $\alpha$ on top of stack by variable $A$ when $A\to\alpha\in R$.
* **Accept:** when stack contains $S$ and input exhausted.
* **Error:** no valid move.

Correctness invariant: stack always contains a viable prefix.

Conflicts:

* **Shift–reduce conflict** or **reduce–reduce conflict** indicate nondeterminism for the given parsing table/grammar.

---

### LR item automaton

**LR(0) item.** Production with dot marking position:
$$A\to \alpha\cdot\beta.$$

Closure and goto operations define canonical collection of LR(0) items:

* $\mathrm{closure}(I)$ adds $B\to\cdot\gamma$ for every item in $I$ with dot before $B$.
* $\mathrm{goto}(I,X)$ shifts dot over $X$.

Deterministic automaton over $\Sigma\cup V$ recognizes viable prefixes; states are item sets, transitions given by goto.

---

### LR parsing families

#### LR(0)

* Parsing table built from LR(0) item automaton.
* Grammar is LR(0) if no conflicts.
* Strong restriction; most practical grammars are not LR(0).

#### SLR(1)

* Uses LR(0) automaton, but reduction entries filtered by FOLLOW sets.
* Reduction by $A\to\alpha$ only on lookahead in $\mathrm{FOLLOW}(A)$.
* Sound but sometimes incomplete compared to LR(1).

#### Canonical LR(1)

* **LR(1) item:** $A\to \alpha\cdot\beta, a$ where $a$ is lookahead in $\Sigma\cup{\$ }$.
* Closure propagates lookahead via FIRST of $\beta a$.
* Most powerful deterministic bottom-up parsing method; recognizes all LR(1) grammars.

#### LALR(1)

* Merge canonical LR(1) states with same LR(0) core.
* Table is smaller; language class strictly between SLR(1) and LR(1).
* Possible introduction of spurious conflicts; widely used in practice.

Inclusions:
$$\text{LR(0)}\subsetneq \text{SLR(1)}\subsetneq \text{LALR(1)}\subsetneq \text{LR(1)}.$$

All are proper subsets of deterministic CFLs recognized by DPDAs.

---

### Parsing tables

Action–Goto table:

* **Action** indexed by (state, terminal): shift $s_j$, reduce $A\to\alpha$, accept, or error.
* **Goto** indexed by (state, variable): next state after reduction by $A$.

Operational semantics:
1. Maintain state stack synchronized with grammar symbols.
2. Shift moves to goto of terminal; reduction pops $|\alpha|$ states and pushes goto on $A$.

---

### Formal correctness and relation to PDAs

Bottom-up LR parser corresponds to a **deterministic PDA**:

* States of the PDA coincide with LR automaton states.
* Stack symbols pair grammar symbols with LR states.
* Determinism of table implies determinism of PDA.
* Accepted language is deterministic CFL recognized by that DPDA.

---

### Ambiguity and determinism

* LR grammar is unambiguous.
* Existence of multiple rightmost derivations implies LR conflicts.
* Not every unambiguous CFG is LR(1); LR parsing characterizes a strict subclass of unambiguous CFLs.

Undecidability:

* LR($k$)-membership for arbitrary $k$ is decidable; smallest $k$ may be exponential.
* Ambiguity of CFGs undecidable even when grammar is not LR($k$).

---

### Complexity bounds

* LR parsing time $O(n)$ for fixed table size; $n=|w|$.
* LR(1) table construction potentially exponential in grammar size due to item blow-up.
* LALR(1) construction mitigates size while preserving $O(n)$ parsing.

---

### Normal forms and grammar transformations

* Left factoring and left recursion elimination modify suitability for LL versus LR methods; LR parsing tolerates left recursion but not ambiguous constructs inducing conflicts.
* Conversion to **operator-precedence grammars** yields specialized bottom-up parsers via precedence relations.

---

### Error detection and recovery (formal view)

* Detection relies on absence of valid action entry.
* Recovery strategies (panic mode, phrase-level) can be formalized as controlled extensions of the DPDA transition relation preserving prefix-correctness of viable prefixes.

---

### Relationships to derivations and trees

* Bottom-up parsers build parse trees **from leaves to root**.
* Stack represents frontier of partially reduced tree.
* Each reduce action corresponds to completing a subtree matching a production.

---

### Related topics

* Rightmost derivations and handle pruning
* Deterministic pushdown automata and DCFLs
* LR, LALR, and SLR parser construction
* Viable prefixes and LR item automata
* Operator-precedence and precedence relations


---

