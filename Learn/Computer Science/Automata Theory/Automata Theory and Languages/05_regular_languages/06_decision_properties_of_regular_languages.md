## Decision Properties of Regular Languages


Let $\Sigma$ be a finite alphabet and let $L \subseteq \Sigma^*$ be a regular language, equivalently specified by a deterministic finite automaton $A$, a nondeterministic finite automaton $N$, a regular expression $r$, or a monadic second-order formula over words.

### Membership

**Problem**
Given $w \in \Sigma^*$, decide whether $w \in L$.

**Decidability**
Decidable.

**Method**
Simulate a DFA $A = \langle Q,\Sigma,\delta,q_0,F\rangle$ on input $w$ and accept iff the unique run ends in a state of $F$.

**Complexity**
$$
\text{time } O(|w|), \qquad \text{space } O(1)
$$
for a DFA. For an NFA with $n$ states, membership is decidable in time $O(|w| \cdot n)$ via subset propagation.

---

### Emptiness

**Problem**
Decide whether $L = \varnothing$.

**Decidability**
Decidable.

**Method**
Given a DFA $A$, compute the set of states reachable from $q_0$. Then
$$
L = \varnothing \iff \text{no reachable state is in } F
$$

**Complexity**
$$
O(|Q| + |\delta|)
$$

---

### Nonemptiness and Witness Extraction

**Problem**
Decide whether $L \neq \varnothing$ and, if so, produce $w \in L$.

**Decidability**
Decidable.

**Method**
Perform breadth-first search in the transition graph of $A$ starting from $q_0$ until a state in $F$ is reached. The path labels yield a shortest witness.

---

### Finiteness and Infiniteness

**Problem**
Decide whether $L$ is finite.

**Decidability**
Decidable.

**Characterization**
Let $A$ be a DFA recognizing $L$. Then $L$ is infinite iff there exists a cycle reachable from $q_0$ and from which some accepting state is reachable.

Formally, $L$ is infinite iff there exist states $p,q \in Q$ such that:
$$
q_0 \Rightarrow^* p,\quad p \Rightarrow^+ p,\quad p \Rightarrow^* q,\quad q \in F
$$

**Method**
Compute the directed graph of reachable states and check for reachable cycles with paths to $F$.

---

### Universality

**Problem**
Decide whether $L = \Sigma^*$.

**Decidability**
Decidable.

**Method**
Construct the complement automaton $A^c$ by swapping accepting and rejecting states. Then:
$$
L = \Sigma^* \iff L(A^c) = \varnothing
$$

**Complexity**
Polynomial in $|Q|$.

---

### Equivalence

**Problem**
Given two regular languages $L_1,L_2 \subseteq \Sigma^*$, decide whether $L_1 = L_2$.

**Decidability**
Decidable.

**Method 1: Symmetric Difference**
$$
L_1 = L_2 \iff L_1 \triangle L_2 = \varnothing
$$
Construct an automaton for $L_1 \triangle L_2$ via product construction and test emptiness.

**Method 2: Bisimulation via Minimal DFAs**
Minimize DFAs for $L_1$ and $L_2$ and test isomorphism of the resulting automata.

---

### Containment

**Problem**
Decide whether $L_1 \subseteq L_2$.

**Decidability**
Decidable.

**Reduction**
$$
L_1 \subseteq L_2 \iff L_1 \cap \overline{L_2} = \varnothing
$$

**Method**
Construct product automaton for $L_1 \cap \overline{L_2}$ and test emptiness.

---

### Disjointness

**Problem**
Decide whether $L_1 \cap L_2 = \varnothing$.

**Decidability**
Decidable.

**Method**
Construct the synchronous product automaton and test emptiness.

---

### Regularity of Derived Languages

For regular $L \subseteq \Sigma^*$, the following derived languages are regular and hence have decidable properties:

* Prefixes $\text{Pref}(L)$
* Suffixes $\text{Suff}(L)$
* Substrings $\text{Sub}(L)$
* Reversal $L^R$
* Homomorphic images $h(L)$ and inverse images $h^{-1}(L)$

Decision problems for these languages reduce to the corresponding problems on regular automata.

---

### Equivalence of Descriptions

**Problem**
Given a regular expression $r$ and a DFA $A$, decide whether $L(r) = L(A)$.

**Decidability**
Decidable.

**Method**
Convert $r$ to an NFA, determinize, and reduce to equivalence of DFAs.

---

### Logical Decision Problems

Let $L$ be defined by a monadic second-order formula $\varphi$ over words.

* Satisfiability: decidable
* Validity: decidable
* Equivalence of formulas: decidable

These follow from the equivalence between MSO definability and finite automata recognizability.

---

### Summary of Decidable Properties

For regular languages, the following are decidable:

* Membership
* Emptiness and nonemptiness
* Finiteness and infiniteness
* Universality
* Equivalence
* Containment
* Disjointness
* Description equivalence
* Logical satisfiability and equivalence

These results rely fundamentally on the finiteness of automaton state spaces and closure of regular languages under Boolean operations.

---

### Related Topics

* DFA minimization
* Myhill–Nerode equivalence
* Closure properties of regular languages
* MSO logic over words
* Automata-based model checking
* Language inclusion algorithms


---

