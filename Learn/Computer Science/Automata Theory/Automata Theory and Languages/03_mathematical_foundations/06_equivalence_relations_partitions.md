## Equivalence Relations & Partitions


### Formal Definition and Algebraic Structure

An equivalence relation on a set $X$ is a binary relation $\sim \subseteq X \times X$ satisfying:

* **Reflexivity:** $\forall x \in X,; x \sim x$
* **Symmetry:** $\forall x,y \in X,; x \sim y \Rightarrow y \sim x$
* **Transitivity:** $\forall x,y,z \in X,; x \sim y \land y \sim z \Rightarrow x \sim z$

The collection of all equivalence relations on $X$, ordered by refinement, forms a complete lattice. For equivalence relations $\sim_1$ and $\sim_2$ on $X$:

* $\sim_1 \preceq \sim_2 \iff \sim_1 \subseteq \sim_2$
* The meet is $\sim_1 \cap \sim_2$
* The join is the transitive closure of $\sim_1 \cup \sim_2$

---

### Equivalence Classes

For $x \in X$, the equivalence class of $x$ under $\sim$ is defined as

$$
[x]_\sim = { y \in X \mid x \sim y }
$$

Fundamental properties:

* $x \sim y \iff [x]*\sim = [y]*\sim$
* $x \not\sim y \iff [x]*\sim \cap [y]*\sim = \emptyset$
* $\bigcup_{x \in X} [x]_\sim = X$

The quotient set of $X$ by $\sim$ is denoted $X / \sim$ and consists of all equivalence classes.

---

### Partitions

A partition $\mathcal{P}$ of a set $X$ is a family of subsets of $X$ such that:

$$
\forall A \in \mathcal{P},; A \neq \emptyset
$$

$$
\forall A,B \in \mathcal{P},; A \neq B \Rightarrow A \cap B = \emptyset
$$

$$
\bigcup_{A \in \mathcal{P}} A = X
$$

Each element of $X$ belongs to exactly one block of the partition.

---

### Equivalence Relation–Partition Correspondence

There exists a bijective correspondence between equivalence relations on $X$ and partitions of $X$.

**From equivalence relations to partitions**

Given $\sim$ on $X$, define

$$
\mathcal{P}*\sim = { [x]*\sim \mid x \in X }
$$

**From partitions to equivalence relations**

Given a partition $\mathcal{P}$ of $X$, define a relation $\sim_\mathcal{P}$ by

$$
x \sim_\mathcal{P} y \iff \exists A \in \mathcal{P} \text{ such that } x \in A \land y \in A
$$

These constructions are mutually inverse and preserve refinement order.

---

### Congruence Relations

Let $A$ be an algebra equipped with an operation $\circ$. An equivalence relation $\sim$ on $A$ is a **congruence** if

$$
a_1 \sim a_2 \land b_1 \sim b_2 \Rightarrow a_1 \circ b_1 \sim a_2 \circ b_2
$$

Congruence relations enable quotient algebras $A / \sim$ where the operation $\circ$ is well-defined on equivalence classes. In automata theory, congruences over $\Sigma^*$ are central to algebraic language recognition.

---

### Myhill–Nerode Equivalence

For a language $L \subseteq \Sigma^*$, define the Myhill–Nerode equivalence $\equiv_L$ by

$$
x \equiv_L y \iff \forall z \in \Sigma^*,; xz \in L \iff yz \in L
$$

Properties:

* $\equiv_L$ is an equivalence relation on $\Sigma^*$
* $\equiv_L$ is a right-invariant congruence with respect to concatenation
* The index of $\equiv_L$ equals the number of states in the minimal DFA recognizing $L$
* $L$ is regular if and only if $\equiv_L$ has finite index

The equivalence classes of $\equiv_L$ induce the canonical partition underlying DFA minimization.

---

### Right, Left, and Two-Sided Congruences

For a monoid $M$ with operation $\cdot$:

* **Right congruence:** $x \sim y \Rightarrow xz \sim yz$ for all $z \in M$
* **Left congruence:** $x \sim y \Rightarrow zx \sim zy$ for all $z \in M$
* **Two-sided congruence:** both conditions hold

The syntactic congruence of a language is the coarsest two-sided congruence saturating the language.

---

### Partitions in Automata Minimization

For a deterministic finite automaton $A = (Q, \Sigma, \delta, q_0, F)$, define a relation $\sim$ on $Q$ by

$$
p \sim q \iff \forall w \in \Sigma^*,; \delta(p,w) \in F \iff \delta(q,w) \in F
$$

This equivalence partitions $Q$ into indistinguishable states. The quotient automaton $A / \sim$ is minimal and unique up to isomorphism.

Partition refinement algorithms compute the coarsest stable partition compatible with transition structure and accepting states.

---

### Equivalence Relations in Grammars and Parsing

* Nonterminal equivalence: $A \sim B$ if $L(G,A) = L(G,B)$
* Item-set equivalence in LR parsing defines parser automaton states
* Bisimulation equivalence partitions configurations of pushdown systems

---

### Logical Characterizations

Equivalence relations correspond to definable congruences in logical frameworks:

* First-order definable equivalences over $\Sigma^*$ correspond to aperiodic monoids
* MSO-definable equivalence relations characterize regular congruences
* Ehrenfeucht–Fraïssé equivalence partitions structures by quantifier rank

---

### Decidability and Complexity

* Equivalence of DFA states is decidable in $O(|Q|\log|Q|)$
* Language equivalence:

  * DFA equivalence is decidable in polynomial time
  * PDA equivalence is undecidable
  * Turing machine equivalence is undecidable by Rice’s theorem

---

### Related Topics

* Syntactic monoids
* Congruence lattices
* DFA minimization
* Bisimulation
* Quotient automata
* Algebraic automata
* Language recognition congruences
* Partition refinement algorithms

---

