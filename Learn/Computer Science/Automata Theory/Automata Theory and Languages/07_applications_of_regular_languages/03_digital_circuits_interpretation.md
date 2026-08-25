## Digital circuits interpretation


### Combinational–sequential correspondence

A DFA $M = \langle Q, \Sigma, \delta, q_0, F \rangle$ admits a direct interpretation as a synchronous sequential digital circuit.

* Alphabet symbols $a \in \Sigma$ correspond to encoded input vectors.
* States $q \in Q$ correspond to configurations of a finite register bank.
* The transition function $\delta$ corresponds to a combinational next-state logic block.
* The acceptance predicate $F \subseteq Q$ corresponds to an output decoding function.

Formally, let $k = \lceil \log_2 |Q| \rceil$. There exists an injective encoding
$$
\eta : Q \to {0,1}^k
$$
such that the DFA transition function induces a Boolean function
$$
\Delta : {0,1}^k \times \Sigma \to {0,1}^k
$$
realizable by combinational logic.

---

### DFA minimization as state reduction

DFA minimization corresponds exactly to **state minimization** in synchronous sequential circuits.

Two states $p,q \in Q$ are equivalent if and only if:
$$
\forall w \in \Sigma^* ; \text{output}(p,w) = \text{output}(q,w)
$$
which is precisely **sequential equivalence** under all future input sequences.

Thus DFA minimization computes the maximal quotient of the circuit state space preserving observable behavior.

---

### Moore and Mealy machine interpretations

For Moore machines, where outputs depend only on states, DFA minimization applies directly.

For Mealy machines, with output function $\lambda : Q \times \Sigma \to \Gamma$, equivalence is defined by:
$$
\forall w \in \Sigma^* ; \lambda^*(p,w) = \lambda^*(q,w)
$$
and reduces to DFA minimization on the expanded transition-output structure.

---

### Equivalence checking of sequential circuits

Given two sequential circuits $C_1,C_2$ with identical input alphabets, equivalence checking reduces to DFA equivalence.

Let $M_1,M_2$ be their induced automata. Construct the product automaton
$$
M = M_1 \times M_2
$$
with accepting states representing output disagreement.

Circuit equivalence holds if and only if no accepting state is reachable from the initial pair.

DFA minimization optimizes this check by collapsing equivalent internal states prior to reachability analysis.

---

### Retiming and state merging

State minimization is orthogonal to **retiming** but interacts algebraically.

* Retiming redistributes registers while preserving language acceptance.
* DFA minimization collapses observationally indistinguishable states.

Both preserve the recognized language $L \subseteq \Sigma^*$.

---

### Sequential logic synthesis implications

Given a minimized DFA $M'$, the resulting circuit:

* Uses the minimum number of logical states.
* Minimizes required flip-flops:
  $$
  \text{registers} = \lceil \log_2 |Q'| \rceil
  $$
* Reduces power and area without altering functionality.

Minimization precedes Boolean logic optimization such as Karnaugh mapping or SAT-based synthesis.

---

### State encoding independence

Minimization is invariant under state encoding.

For any encodings $\eta_1,\eta_2$:
$$
\eta_1^{-1} \circ \Delta_1 = \eta_2^{-1} \circ \Delta_2
$$
if and only if the underlying DFAs are isomorphic.

Thus DFA minimization is a semantic, not syntactic, circuit optimization.

---

### Hazard and glitch abstraction

DFA semantics abstract away transient hazards.

Equivalence is defined over stable clocked behavior:
$$
\delta^*(q,w)
$$
rather than gate-level timing.

Thus DFA minimization preserves synchronous correctness but not asynchronous glitch behavior.

---

### Symbolic representation and BDDs

When $|Q|$ is large, states are represented symbolically using Boolean variables.

Partition refinement operates over characteristic functions:
$$
\chi_B : {0,1}^k \to {0,1}
$$
often implemented via Binary Decision Diagrams.

Symbolic DFA minimization corresponds to symbolic state equivalence reduction in model checking.

---

### Formal verification perspective

In model checking, DFA minimization corresponds to:

* Quotienting Kripke structures by bisimulation-like equivalence
* Reducing Büchi automata prior to LTL verification
* Collapsing control logic in hardware verification

For deterministic systems, DFA minimization computes the coarsest congruence preserving linear-time properties.

---

### Complexity and synthesis bounds

Let $n = |Q|$.

* Worst-case circuit state reduction: exponential reduction in reachable encodings
* Minimization time: $O(|\Sigma| \cdot n \cdot \log n)$
* Flip-flop lower bound:
  $$
  \log_2 \text{index}(\equiv_L)
  $$

No circuit recognizing $L$ can use fewer states without loss of correctness.

---

### Algebraic circuit interpretation

The transition monoid of the DFA corresponds to the semigroup of input-induced state transformations:
$$
T = { f_w : Q \to Q \mid w \in \Sigma^* }
$$

Minimization computes the faithful action of $T$ on $Q / {\equiv_L}$, eliminating redundant transformations.

---

### Related topics

* Sequential circuit minimization
* Moore and Mealy machines
* Symbolic model checking
* Bisimulation minimization
* Register-transfer level synthesis
* Synchronous hardware verification

---

