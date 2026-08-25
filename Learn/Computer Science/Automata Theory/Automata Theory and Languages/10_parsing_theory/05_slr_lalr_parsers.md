## SLR / LALR Parsers


### LR Parsing Framework

Let $G = \langle V, \Sigma, P, S \rangle$ be an augmented context-free grammar with start production $S' \to S$. LR parsing constructs a deterministic pushdown automaton whose stack symbols encode parser states derived from **items**, representing partial recognition of rightmost derivations.

An **LR item** is a production with a distinguished dot. For a production $A \to \alpha\beta$, the corresponding item is
$$
A \to \alpha ,\bullet, \beta.
$$

A configuration of an LR parser is a pair consisting of a state stack and an unread input suffix. Actions are **shift**, **reduce**, **accept**, or **error**.

### Canonical LR Item Sets

Define the **closure** operator on a set of items $I$ as the least set satisfying:
if $A \to \alpha ,\bullet, B\beta \in I$ and $B \to \gamma \in P$, then
$$
B \to \bullet, \gamma \in \mathrm{closure}(I).
$$

Define the **goto** function for symbol $X \in V \cup \Sigma$ as
$$
\mathrm{goto}(I, X) = \mathrm{closure} \left( { A \to \alpha X ,\bullet, \beta \mid A \to \alpha ,\bullet, X\beta \in I } \right).
$$

The canonical LR collection is the smallest set of item sets containing $\mathrm{closure}({ S' \to \bullet S })$ and closed under $\mathrm{goto}$.

### SLR Parsing

#### Definition

SLR parsing uses **LR(0) items** and resolves reductions using FOLLOW sets. For a completed item
$$
A \to \alpha ,\bullet,
$$
the parser performs a reduce action on lookahead symbol $a$ iff
$$
a \in \mathrm{FOLLOW}(A).
$$

Shift actions are determined solely by transitions in the LR(0) automaton.

#### Parsing Table Construction

Given the LR(0) automaton states ${ I_0, \dots, I_n }$:

* ACTION$[i,a] = \text{shift } j$ if $\mathrm{goto}(I_i,a) = I_j$.
* ACTION$[i,a] = \text{reduce } A \to \alpha$ if $A \to \alpha ,\bullet \in I_i$ and $a \in \mathrm{FOLLOW}(A)$.
* ACTION$[i,$] = \text{accept}$ if $S' \to S ,\bullet \in I_i$.

Conflicts arise if multiple actions are assigned to the same entry.

#### Expressive Power

The class of grammars parsed by SLR is strictly contained in deterministic context-free grammars. SLR parsers fail on grammars where FOLLOW sets are too coarse to disambiguate reductions.

### LALR Parsing

#### Motivation

LALR parsing increases power over SLR while maintaining a table size comparable to LR(0). It approximates canonical LR(1) parsing by merging states with identical LR(0) cores.

#### LR(1) Items

An LR(1) item is of the form
$$
A \to \alpha ,\bullet, \beta, a
$$
where $a \in \Sigma \cup { $ }$ is a lookahead terminal. Closure propagates lookaheads using FIRST sets.

Canonical LR(1) parsing is powerful but yields a potentially exponential number of states.

#### State Merging

Define the **core** of an LR(1) item as the underlying LR(0) item. LALR constructs the canonical LR(1) automaton and merges states with identical cores, unioning their lookahead sets.

Reductions are performed only on the merged lookahead symbols.

#### Parsing Table Semantics

For a merged state $I$ containing
$$
A \to \alpha ,\bullet, a,
$$
the reduce action $A \to \alpha$ is enabled only on terminal $a$.

This refinement avoids many spurious conflicts present in SLR.

### Conflict Analysis

#### Shift-Reduce Conflicts

Occurs if a state contains both
$$
A \to \alpha ,\bullet, a\beta
$$
and
$$
B \to \gamma ,\bullet
$$
with overlapping lookahead conditions.

SLR may introduce conflicts due to FOLLOW-based overapproximation. LALR resolves some of these using precise lookahead propagation.

#### Reduce-Reduce Conflicts

Occurs if two completed items
$$
A \to \alpha ,\bullet, a
$$
and
$$
B \to \beta ,\bullet, a
$$
share a lookahead symbol. Such conflicts indicate non-determinism in the grammar.

### Language-Theoretic Position

Let $\mathcal{L}*{\mathrm{SLR}}$ and $\mathcal{L}*{\mathrm{LALR}}$ denote the classes of languages parsable by SLR and LALR grammars.

Proper containments hold:
$$
\mathcal{L}*{\mathrm{SLR}} \subsetneq \mathcal{L}*{\mathrm{LALR}} \subsetneq \mathrm{DCFL}.
$$

Canonical LR(1) parsing captures all deterministic context-free languages, whereas LALR is a strict approximation.

### Automata-Theoretic Interpretation

Both SLR and LALR parsers construct deterministic pushdown automata. The stack alphabet consists of parser states rather than grammar symbols.

LALR merging corresponds to quotienting the LR(1) automaton by an equivalence relation on cores, preserving determinism but losing some context sensitivity.

### Decidability and Complexity

Decidable problems:

* SLR table construction.
* LALR table construction.
* Conflict detection.

Table construction is polynomial in grammar size, though LR(1) construction may incur exponential blowup prior to merging.

Membership for SLR and LALR grammars is decidable in deterministic linear time.

### Limitations and Pathologies

LALR merging may introduce conflicts not present in canonical LR(1) parsing due to incompatible lookahead unions.

There exist grammars that are LR(1) but not LALR(1), demonstrating loss of precision under merging.

No grammar transformation exists that converts every LR(1) grammar into an equivalent LALR grammar.

### Relationship to Grammar Transformations

Left recursion elimination and left factoring preserve LR-parsability but may change SLR or LALR status.

Conflict resolution via precedence and associativity annotations introduces semantics beyond pure CFG theory, yielding deterministic behavior without altering the underlying language class.

### Related Topics

* LR parsing
* LR(0) items
* LR(1) parsing
* Deterministic pushdown automata
* FOLLOW and FIRST sets
* Canonical LR automata
* Grammar ambiguity


---

