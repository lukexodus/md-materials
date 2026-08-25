## $\varepsilon$-NFA


### Formal Model

An $\varepsilon$-NFA is a quintuple
$$
A = \langle Q, \Sigma, \delta, q_0, F \rangle
$$
where $Q$ is a finite set of states, $\Sigma$ is a finite alphabet, $q_0 \in Q$ is the start state, $F \subseteq Q$ is the set of accepting states, and the transition function is
$$
\delta : Q \times \left(\Sigma \cup {\varepsilon}\right) \to \mathcal{P}(Q)
$$

The transition relation is extended to subsets of states and strings via $\varepsilon$-closure.

---

### $\varepsilon$-Closure

For $q \in Q$, the $\varepsilon$-closure of $q$ is defined as
$$
\varepsilon\text{-cl}\left(q\right) = { p \in Q \mid q \xRightarrow{\varepsilon^*} p }
$$
where $\xRightarrow{\varepsilon^*}$ denotes the reflexive transitive closure of $\varepsilon$-moves.

For $S \subseteq Q$,
$$
\varepsilon\text{-cl}\left(S\right) = \bigcup_{q \in S} \varepsilon\text{-cl}\left(q\right)
$$

---

### Extended Transition Function

The extended transition function $\hat{\delta} : \mathcal{P}(Q) \times \Sigma^* \to \mathcal{P}(Q)$ is defined inductively.

Base case:
$$
\hat{\delta}\left(S, \varepsilon\right) = \varepsilon\text{-cl}\left(S\right)
$$

Inductive step:
$$
\hat{\delta}\left(S, aw\right) = \hat{\delta}\left(\varepsilon\text{-cl}\left(\delta\left(S, a\right)\right), w\right)
$$
for $a \in \Sigma$ and $w \in \Sigma^*$.

---

### Acceptance Condition

A string $w \in \Sigma^*$ is accepted by $A$ iff
$$
\hat{\delta}\left({q_0}, w\right) \cap F \neq \emptyset
$$

Equivalently, there exists a path labeled by $w$ interleaved with $\varepsilon$-moves from $q_0$ to some $f \in F$.

---

### Expressive Power

$\varepsilon$-NFAs recognize exactly the class of regular languages.

For every $\varepsilon$-NFA $A$, there exists an NFA $A'$ without $\varepsilon$-moves such that
$$
L\left(A\right) = L\left(A'\right)
$$

Thus,
$$
\varepsilon\text{-NFA} \equiv \text{NFA} \equiv \text{DFA}
$$

---

### Elimination of $\varepsilon$-Transitions

Given an $\varepsilon$-NFA $A = \langle Q, \Sigma, \delta, q_0, F \rangle$, construct an NFA $A' = \langle Q, \Sigma, \delta', q_0, F' \rangle$.

Transition function:
$$
\delta'\left(q, a\right) = \varepsilon\text{-cl}\left(\delta\left(\varepsilon\text{-cl}\left(q\right), a\right)\right)
$$

Accepting states:
$$
F' = { q \in Q \mid \varepsilon\text{-cl}\left(q\right) \cap F \neq \emptyset }
$$

This construction preserves the number of states and is computable in polynomial time.

---

### Relationship to Regular Expressions

$\varepsilon$-NFAs arise naturally in Thompson constructions.

Each regular expression $R$ can be converted into an $\varepsilon$-NFA $A_R$ such that
$$
L\left(A_R\right) = L\left(R\right)
$$

Key correspondences:

* Union introduces $\varepsilon$-branching
* Concatenation introduces $\varepsilon$-linking
* Kleene star introduces $\varepsilon$-loops and $\varepsilon$-entry and exit states

---

### Closure Properties

Since $\varepsilon$-NFAs recognize regular languages, closure properties follow immediately.

Regular languages are closed under:
$$
\cup,; \cap,; \setminus,; \cdot,; {}^*,; {}^+,; \text{homomorphism},; \text{inverse homomorphism}
$$

Many of these closures are realized directly via $\varepsilon$-transitions.

---

### Complexity Considerations

* $\varepsilon$-closure computation is linear in the number of $\varepsilon$-edges
* Membership testing runs in $O\left(|Q| \cdot |w|\right)$ time
* Subset construction applied after $\varepsilon$-elimination yields up to $2^{|Q|}$ states

---

### Logical and Verification Connections

* $\varepsilon$-moves correspond to silent transitions in labeled transition systems
* Central in automata-based model checking
* Used in translation from monadic second-order logic to automata
* Basis for automata-theoretic decision procedures in verification

---

### Related Topics

* Nondeterministic finite automata
* Determinization
* Thompson construction
* Regular expressions
* Kleene star
* Labeled transition systems
* Monadic second-order logic


---

