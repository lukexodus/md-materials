## Predictive Parsing Tables


### Formal Setting

Let $G = \langle V, \Sigma, P, S \rangle$ be a context-free grammar. A predictive parsing table encodes a deterministic top-down control strategy implementing a leftmost derivation without backtracking. The table is a partial function
$$
M : V \times \left(\Sigma \cup {$}\right) \to P
$$
where $\$$ denotes end-of-input.

A grammar admits a predictive parsing table iff it is $\mathsf{LL}(1)$.

---

### FIRST and FOLLOW Foundations

For $\alpha \in \left(V \cup \Sigma\right)^*$,
$$
\mathsf{FIRST}(\alpha) = { a \in \Sigma \mid \alpha \Rightarrow^* a\beta } \cup {\epsilon \mid \alpha \Rightarrow^* \epsilon}
$$

For $A \in V$,
$$
\mathsf{FOLLOW}(A) = { a \in \Sigma \mid S \Rightarrow^* xAa y } \cup {$ \mid S \Rightarrow^* xA}
$$

Both sets are computable by monotone fixed-point iteration over $P$.

---

### Table Construction Rules

For each production
$$
A \to \alpha
$$
populate $M$ as follows:
1. For every $a \in \mathsf{FIRST}(\alpha) \setminus {\epsilon}$,
   $$
   M[A,a] = A \to \alpha
   $$
2. If $\epsilon \in \mathsf{FIRST}(\alpha)$, then for every $b \in \mathsf{FOLLOW}(A)$,
   $$
   M[A,b] = A \to \alpha
   $$

All other entries are undefined and correspond to parsing errors.

---

### LL$(1)$ Correctness Condition

$G$ is $\mathsf{LL}(1)$ iff for every $A \in V$ with productions
$$
A \to \alpha_1 \mid \cdots \mid \alpha_k
$$
the following hold:
1. Pairwise disjoint FIRST sets:
   $$
   \mathsf{FIRST}(\alpha_i) \cap \mathsf{FIRST}(\alpha_j) = \emptyset \quad i \ne j
   $$
2. $\epsilon$-conflict freedom:
   $$
   \epsilon \in \mathsf{FIRST}(\alpha_i) \Rightarrow \mathsf{FIRST}(\alpha_j) \cap \mathsf{FOLLOW}(A) = \emptyset \quad j \ne i
   $$

Equivalently, $M$ is single-valued.

---

### Operational Semantics

Predictive parsing operates with a stack $\Gamma \subseteq V \cup \Sigma \cup {\$}$ and input buffer $w$$.

Invariant:
$$
\text{stack} \cdot \text{input} \Rightarrow_\ell^* w
$$

Transition rules:

* If top is terminal $a$ and input head is $a$, pop and advance.
* If top is $A \in V$ and input head is $a$, apply $M[A,a] = A \to \alpha$, pop $A$, push $\alpha$ in reverse order.
* If undefined, signal error.

Acceptance occurs iff both stack and input reduce to $\$$.

---

### Deterministic PDA Correspondence

A predictive parser is a deterministic pushdown automaton with:

* Stack alphabet $V \cup \Sigma$
* Control encoded by table $M$
* Acceptance by empty stack and end marker

Thus,
$$
\mathsf{LL}(1) \subsetneq \mathsf{DCFL}
$$

---

### Grammar Transformations for Table Construction

#### Left Recursion Elimination

Immediate left recursion:
$$
A \to A\alpha \mid \beta
$$
is transformed to:
$$
A \to \beta A' \
A' \to \alpha A' \mid \epsilon
$$

This is necessary for termination of table-driven parsing.

#### Left Factoring

For common prefixes:
$$
A \to \alpha\beta_1 \mid \alpha\beta_2
$$
factor to:
$$
A \to \alpha A' \
A' \to \beta_1 \mid \beta_2
$$

Left factoring enforces FIRST-set disjointness.

---

### Conflict Analysis

Conflicts arise when multiple productions map to the same table entry.

* **FIRST/FIRST conflict**:
  $$
  \mathsf{FIRST}(\alpha_i) \cap \mathsf{FIRST}(\alpha_j) \ne \emptyset
  $$

* **FIRST/FOLLOW conflict**:
  $$
  \epsilon \in \mathsf{FIRST}(\alpha_i) \land \mathsf{FIRST}(\alpha_j) \cap \mathsf{FOLLOW}(A) \ne \emptyset
  $$

Such conflicts imply non-$\mathsf{LL}(1)$ behavior.

---

### Soundness and Completeness

For $\mathsf{LL}(1)$ grammars:

* **Soundness**: Every parse produced corresponds to a valid leftmost derivation.
* **Completeness**: Every $w \in L(G)$ is accepted.

Formally:
$$
w \in L(G) \iff \text{predictive parser accepts } w
$$

---

### Complexity

Let $n = |w|$.

* Table construction: $O(|P||\Sigma|)$
* Parsing time: $O(n)$
* Stack depth: $O(h)$ where $h$ is parse tree height

---

### Relation to Grammar Ambiguity

Ambiguous grammars cannot be $\mathsf{LL}(1)$ since ambiguity implies multiple leftmost derivations for some $w$, yielding unavoidable table conflicts.

Unambiguity is necessary but not sufficient for $\mathsf{LL}(1)$.

---

### Extensions and Variants

* $\mathsf{LL}(k)$ tables with $k$-symbol lookahead:
  $$
  M : V \times \Sigma^k \to P
  $$
* Error-recovering tables using synchronization sets
* Table compression via row equivalence

---

### Theoretical Limitations

There exist deterministic CFLs not representable by predictive tables:
$$
\mathsf{LL}(1) \subsetneq \mathsf{LR}(1)
$$

Canonical counterexample languages require right-context sensitivity not capturable by FIRST/FOLLOW information alone.

---

### Related Topics

* LL$(k)$ grammars
* FIRST and FOLLOW computation
* Recursive descent parsing
* Deterministic pushdown automata
* LR parsing tables
* Grammar transformations
* Viable prefixes

---

