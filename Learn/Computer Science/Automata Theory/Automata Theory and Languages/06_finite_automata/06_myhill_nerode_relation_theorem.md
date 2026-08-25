## Myhill–Nerode relation & theorem


### Right congruences on $\Sigma^*$

A binary relation $\equiv \subseteq \Sigma^* \times \Sigma^*$ is a **right congruence** iff it is an equivalence relation and satisfies right invariance:
$$
\forall x,y,z \in \Sigma^* \quad x \equiv y \implies xz \equiv yz .
$$
The **index** of $\equiv$ is the cardinality of the quotient set $\Sigma^* / {\equiv}$.

A right congruence **recognizes** a language $L \subseteq \Sigma^*$ iff $L$ is a union of equivalence classes of $\equiv$.

---

### Myhill–Nerode equivalence

For a fixed language $L \subseteq \Sigma^*$, define the Myhill–Nerode relation $\equiv_L$ by
$$
x \equiv_L y \iff \forall z \in \Sigma^* \quad xz \in L \leftrightarrow yz \in L .
$$
Properties:

* $\equiv_L$ is an equivalence relation.
* $\equiv_L$ is a right congruence.
* $\equiv_L$ is the **coarsest** right congruence that recognizes $L$.

Coarseness means that for any right congruence $\equiv$ recognizing $L$,
$$
x \equiv y \implies x \equiv_L y .
$$

---

### Myhill–Nerode theorem

For any language $L \subseteq \Sigma^*$, the following are equivalent:
1. $L$ is regular.
2. $\equiv_L$ has finite index.
3. There exists a right congruence of finite index that recognizes $L$.

Moreover, if $\equiv_L$ has finite index $n$, then $n$ equals the number of states in the unique minimal deterministic finite automaton recognizing $L$.

---

### Proof structure

#### Regularity implies finite index

Let $M = \langle Q,\Sigma,\delta,q_0,F \rangle$ be a DFA recognizing $L$. Define
$$
x \sim_M y \iff \delta^*\langle q_0,x \rangle = \delta^*\langle q_0,y \rangle .
$$
Then $\sim_M$ is a right congruence with index at most $\lvert Q \rvert$. If $x \sim_M y$, then for all $z \in \Sigma^*$,
$$
xz \in L \leftrightarrow yz \in L ,
$$
hence $x \equiv_L y$. Therefore $\equiv_L$ has finite index.

---

#### Finite index implies regularity

Assume $\equiv_L$ has finite index. Construct a DFA
$$
M_L = \langle \Sigma^*/{\equiv_L}, \Sigma, \delta_L, [\varepsilon], F_L \rangle
$$
where
$$
\delta_L\langle [x], a \rangle = [xa]
$$
and
$$
F_L = { [x] \mid x \in L } .
$$
Right invariance guarantees $\delta_L$ is well-defined. By definition of $\equiv_L$,
$$
x \in L \leftrightarrow [x] \in F_L ,
$$
so $M_L$ recognizes $L$.

---

### Minimal DFA characterization

Let $M$ be a DFA recognizing $L$.

* Two states $p,q \in Q$ are **indistinguishable** iff
  $$
  \forall z \in \Sigma^* \quad \delta^*\langle p,z \rangle \in F \leftrightarrow \delta^*\langle q,z \rangle \in F .
  $$
* Indistinguishability induces a right congruence on $\Sigma^*$ isomorphic to $\equiv_L$.
* The minimal DFA is obtained by quotienting $M$ by this equivalence.

Uniqueness:
Any two minimal DFAs recognizing $L$ are isomorphic via a bijection preserving transitions and acceptance.

---

### Distinguishing extensions

For $x,y \in \Sigma^*$ with $x \not\equiv_L y$, there exists a **distinguishing suffix** $z \in \Sigma^*$ such that
$$
xz \in L \land yz \notin L
\quad \text{or} \quad
yz \in L \land xz \notin L .
$$
Such suffixes witness inequivalence and are central in lower bounds for DFA size.

---

### Closure and algebraic structure

* The set of all right congruences of finite index over $\Sigma^*$ forms a lattice under refinement.
* $\equiv_L$ is the greatest lower bound of all right congruences recognizing $L$.
* Regular languages are exactly those that are unions of classes of some finite-index right congruence.

---

### Decidability and complexity

Given a DFA $M$:

* Computation of $\equiv_L$ corresponds to DFA minimization.
* Standard partition refinement runs in time $O\lvert \Sigma \rvert \lvert Q \rvert \log \lvert Q \rvert$.
* Equivalence of regular languages reduces to isomorphism of minimal DFAs.

Given a general language specification:

* Finite index of $\equiv_L$ is undecidable for context-free grammars and Turing machines.

---

### Logical characterization

* Regular languages correspond to definability in monadic second-order logic over words.
* $\equiv_L$ coincides with logical indistinguishability under all MSO formulas with one free variable interpreted as a prefix.
* Finite index corresponds to finitely many logical types.

---

### Pumping-style consequences

If $\equiv_L$ has infinite index, then for any $n \in \mathbb{N}$ there exist pairwise inequivalent strings $x_1,\dots,x_n$ such that
$$
\forall i \neq j \quad x_i \not\equiv_L x_j .
$$
This yields non-regularity proofs independent of pumping lemmas.

---

### Related topics

* Nerode automaton
* DFA minimization
* Right-invariant equivalence relations
* Syntactic congruence
* Syntactic monoid
* Brzozowski derivatives
* Regular language lower bounds
* MSO logic on words


---

