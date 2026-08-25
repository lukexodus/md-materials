## Regular Languages Definition


### Model-Theoretic Characterizations

A language $L \subseteq \Sigma^*$ is **regular** if it is recognized by a finite-state computational model. The following characterizations are equivalent and define the same class $\mathrm{REG}$.

### Finite Automaton Characterization

$L$ is regular if there exists a deterministic finite automaton $\mathcal A$ such that
$$
L = L \mathcal A .
$$

A deterministic finite automaton is a tuple
$$
\mathcal A = \langle Q, \Sigma, \delta, q_0, F \rangle
$$
where $Q$ is finite, $\delta : Q \times \Sigma \to Q$ is total, $q_0 \in Q$ is the initial state, and $F \subseteq Q$ is the set of accepting states. The extended transition function satisfies
$$
\delta^* : Q \times \Sigma^* \to Q .
$$

Acceptance is defined by
$$
w \in L \mathcal A \iff \delta^* q_0 w \in F .
$$

Non-deterministic finite automata and $\varepsilon$-automata define the same class under subset construction and $\varepsilon$-elimination.

### Algebraic Characterization

$L$ is regular if and only if its syntactic congruence $\equiv_L$ has finite index. Equivalently, the syntactic monoid
$$
M_L = \Sigma^* / \equiv_L
$$
is finite.

This yields an algebraic definition:
$$
L \text{ is regular } \iff \exists \text{ finite monoid } M \text{ and homomorphism } h : \Sigma^* \to M
$$
such that
$$
L = h^{-1} F
$$
for some $F \subseteq M$.

### Logical Characterization

$L$ is regular if and only if it is definable in monadic second-order logic over finite words. Formally,
$$
\mathrm{REG} = \mathrm{MSO} \langle <, P_a \rangle .
$$

Here, words are structures with a linear order $<$ on positions and unary predicates $P_a$ for each $a \in \Sigma$.

First-order logic with order defines a strict subclass:
$$
\mathrm{FO} \langle < \rangle \subsetneq \mathrm{REG} .
$$

### Inductive Definition via Regular Expressions

$L$ is regular if it is denoted by a regular expression over $\Sigma$, defined inductively using:

* Base languages $\emptyset$, ${ \varepsilon }$, and ${ a }$ for $a \in \Sigma$
* Union, concatenation, and Kleene star

Formally, the class $\mathcal R$ is the smallest family satisfying:
$$
\emptyset, { \varepsilon }, { a } \in \mathcal R
$$
$$
L_1, L_2 \in \mathcal R \Rightarrow L_1 \cup L_2 \in \mathcal R
$$
$$
L_1, L_2 \in \mathcal R \Rightarrow L_1 L_2 \in \mathcal R
$$
$$
L \in \mathcal R \Rightarrow L^* \in \mathcal R .
$$

Then
$$
\mathrm{REG} = \mathcal R .
$$

### Myhill–Nerode Definition

$L$ is regular if and only if the equivalence relation
$$
u \sim_L v \iff \forall x \in \Sigma^* : ux \in L \Leftrightarrow vx \in L
$$
has finitely many equivalence classes.

Each equivalence class corresponds to a state of the minimal deterministic automaton recognizing $L$.

### Closure-Theoretic Definition

$\mathrm{REG}$ is the smallest class of languages over $\Sigma$ such that:

* It contains all finite languages
* It is closed under union, concatenation, and Kleene star
* It is closed under homomorphism and inverse homomorphism
* It is closed under complement and intersection

This closure-based definition uniquely characterizes regular languages among effective language families.

### Complexity-Theoretic Perspective

Every regular language is decidable in deterministic time $O n$ and space $O 1$ on a multitape Turing machine. Conversely, any language decidable with constant space and one-way input head is regular.

### Related Topics

* Deterministic and Non-Deterministic Finite Automata
* Regular Expressions
* Syntactic Monoids
* Aperiodic Languages
* Star-Free Languages
* MSO and FO Definability

---

