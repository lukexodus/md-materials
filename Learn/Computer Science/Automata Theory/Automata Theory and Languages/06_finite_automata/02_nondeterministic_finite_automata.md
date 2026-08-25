## Nondeterministic Finite Automata


### Formal Model

A nondeterministic finite automaton is a quintuple
$$
A = \langle Q, \Sigma, \delta, Q_0, F \rangle
$$
where $Q$ is a finite set of states, $\Sigma$ is a finite alphabet, $Q_0 \subseteq Q$ is a nonempty set of initial states, $F \subseteq Q$ is the set of accepting states, and the transition function is
$$
\delta : Q \times \Sigma \to \mathcal{P}!\left(Q\right).
$$

An equivalent and often more expressive formulation allows $\epsilon$-moves via
$$
\delta : Q \times \left(\Sigma \cup {\epsilon}\right) \to \mathcal{P}!\left(Q\right).
$$

The presence of $\epsilon$-transitions does not increase expressive power but simplifies constructions.

### Configuration Semantics and Acceptance

A configuration is a pair $\langle q, w \rangle$ with $q \in Q$ and $w \in \Sigma^*$. The one-step transition relation $\vdash$ is defined by
$$
\langle q, aw \rangle \vdash \langle q', w \rangle
\quad\text{iff}\quad
q' \in \delta!\left(q, a\right),
$$
and for $\epsilon$-moves by
$$
\langle q, w \rangle \vdash \langle q', w \rangle
\quad\text{iff}\quad
q' \in \delta!\left(q, \epsilon\right).
$$

Let $\vdash^*$ denote the reflexive transitive closure. A string $w \in \Sigma^*$ is accepted if
$$
\exists q_0 \in Q_0,; \exists q_f \in F \colon
\langle q_0, w \rangle \vdash^* \langle q_f, \epsilon \rangle.
$$

The language recognized by $A$ is denoted $L!\left(A\right)$.

### Extended Transition Function

Define the extended transition function
$$
\hat{\delta} : \mathcal{P}!\left(Q\right) \times \Sigma^* \to \mathcal{P}!\left(Q\right)
$$
inductively by
$$
\hat{\delta}!\left(S, \epsilon\right) = \epsilon\text{-closure}!\left(S\right),
$$
$$
\hat{\delta}!\left(S, aw\right)
===============================

\hat{\delta}!\left(
\bigcup_{q \in \epsilon\text{-closure}!\left(S\right)} \delta!\left(q, a\right),
w
\right).
$$

Acceptance can be equivalently characterized as
$$
w \in L!\left(A\right)
;\Leftrightarrow;
\hat{\delta}!\left(Q_0, w\right) \cap F \neq \emptyset.
$$

### Expressive Power and Equivalence to DFA

NFAs recognize exactly the class of regular languages.

**Theorem**
For every NFA $A$ there exists a DFA $D$ such that
$$
L!\left(A\right) = L!\left(D\right).
$$

**Subset Construction**

Given $A = \langle Q, \Sigma, \delta, Q_0, F \rangle$, define
$$
D = \langle \mathcal{P}!\left(Q\right), \Sigma, \delta_D, Q_0', F' \rangle
$$
where
$$
\delta_D!\left(S, a\right)
==========================

\epsilon\text{-closure}!\left(
\bigcup_{q \in S} \delta!\left(q, a\right)
\right),
$$
$$
Q_0' = \epsilon\text{-closure}!\left(Q_0\right),
$$
$$
F' = { S \subseteq Q \mid S \cap F \neq \emptyset }.
$$

The construction is correct but may induce a worst-case exponential blowup
$$
\left|Q_D\right| \le 2^{\left|Q\right|}.
$$

### Succinctness and Lower Bounds

NFAs can be exponentially more succinct than DFAs. There exist regular languages $L_n$ such that:

* $L_n$ is recognized by an NFA with $O!\left(n\right)$ states
* any equivalent DFA requires $2^{\Omega!\left(n\right)}$ states

Canonical examples include languages defined by subset constraints or modular counting under partial observation.

### Closure Properties via NFA Constructions

NFAs admit direct constructive proofs of closure for regular languages:

* **Union:** disjoint union of state sets with a fresh initial state and $\epsilon$-transitions
* **Concatenation:** $\epsilon$-transitions from accepting states of the first automaton to initial states of the second
* **Kleene star:** $\epsilon$-transitions from accepting states to initial states and inclusion of $\epsilon$ in the language

These constructions are linear in automaton size and preserve nondeterminism.

### Decision Problems

For NFAs, the following problems are decidable:

* **Emptiness**
  $$
  L!\left(A\right) = \emptyset
  $$
  decidable via graph reachability

* **Finiteness**
  decidable by detecting reachable cycles on accepting paths

* **Membership**
  $$
  w \in L!\left(A\right)
  $$
  decidable in $O!\left(\left|w\right| \cdot \left|Q\right|\right)$ time

* **Equivalence**
  decidable by determinization followed by DFA equivalence testing

* **Universality**
  $$
  L!\left(A\right) = \Sigma^*
  $$
  PSPACE-complete when $A$ is given as an NFA

### Complexity-Theoretic Perspective

The nondeterminism in NFAs is *structural*, not computational:

* NFAs do not correspond to nondeterministic time complexity classes
* Determinization is a semantic transformation, not a simulation of nondeterministic computation
* Regular languages satisfy
  $$
  \text{REG} \subseteq \text{DTIME}!\left(O!\left(n\right)\right)
  $$
  independently of the automaton model

### Logical Characterization

NFAs correspond to existential branching in monadic second-order logic:

* Regular languages recognized by NFAs are exactly those definable in MSO over strings
* Nondeterministic choice corresponds to existential quantification over state paths
* Determinism corresponds to functional interpretations of successor relations

### Limitations

NFAs cannot recognize:

* Non-regular languages such as ${ a^n b^n \mid n \ge 0 }$
* Any language requiring unbounded memory or counting beyond finite thresholds

These limitations are formalized by the pumping lemma and by Myhill–Nerode equivalence classes.

### Related Topics

* Deterministic finite automata
* $\epsilon$-elimination
* Subset construction
* Myhill–Nerode theorem
* Regular expressions
* Monadic second-order logic over strings


---



---


