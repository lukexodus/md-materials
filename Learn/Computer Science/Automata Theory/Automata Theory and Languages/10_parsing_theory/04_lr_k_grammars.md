## LR($k$) grammars


### Definition

Let $G = \langle V, \Sigma, P, S \rangle$ be a context-free grammar augmented with a unique start symbol $S'$ and production $S' \to S$.
$G$ is **LR($k$)** iff there exists a deterministic bottom-up parser that, given any rightmost derivation in reverse and at most $k$ symbols of lookahead, uniquely determines each parsing action.

Equivalently, $G$ is LR($k$) iff for every viable prefix $\alpha$ and lookahead string $w \in \Sigma^{\le k}$, there is at most one valid parser action consistent with $\alpha w$.

---

### Rightmost derivations and viable prefixes

A **rightmost derivation** is a sequence
$$
S \Rightarrow \gamma_1 \Rightarrow \gamma_2 \Rightarrow \dots \Rightarrow w
$$
where at each step the rightmost variable is rewritten.

A **viable prefix** is any prefix of a right-sentential form that does not extend beyond the handle in a rightmost derivation.

LR parsing recognizes viable prefixes using a deterministic pushdown automaton.

---

### Handles and correctness condition

Let
$$
\gamma A \beta \Rightarrow \gamma \alpha \beta
$$
be a step in a rightmost derivation. Then $\alpha$ is a **handle** of $\gamma \alpha \beta$.

$G$ is LR($k$) iff for every string $x \in \Sigma^*$ with viable prefix $\gamma \alpha$ and lookahead $w \in \Sigma^{\le k}$, the handle $(A \to \alpha)$ is uniquely determined by $\gamma \alpha w$.

---

### LR($k$) parsing automaton

LR($k$) parsers are constructed using **items** of the form
$$
[A \to \alpha ,\boldsymbol{\cdot}, \beta,; u]
$$
where:

* $A \to \alpha\beta \in P$,
* $u \in \Sigma^{\le k}$ is a lookahead string.

The dot marks the parser position within a production.

---

### Canonical LR($k$) item sets

Define the **closure** operator $\mathrm{closure}_k$:

If
$$
[A \to \alpha ,\boldsymbol{\cdot}, B \beta,; u] \in I
$$
and $B \to \gamma \in P$, then for all
$$
v \in \mathrm{FIRST}_k(\beta u),
$$
add
$$
[B \to \boldsymbol{\cdot}, \gamma,; v]
$$
to $I$.

Define the **goto** function:
$$
\mathrm{goto}_k(I, X) = \mathrm{closure}_k({ [A \to \alpha X ,\boldsymbol{\cdot}, \beta,; u] \mid [A \to \alpha ,\boldsymbol{\cdot}, X \beta,; u] \in I }).
$$

The canonical collection of LR($k$) item sets forms the states of a deterministic pushdown automaton.

---

### Parsing table construction

From the canonical item sets, define:

* **ACTION**$[i,a]$ for state $i$ and terminal $a \in \Sigma$:

  * *shift* $j$ if $\mathrm{goto}_k(i,a)=j$,
  * *reduce* $A \to \alpha$ if $[A \to \alpha ,\boldsymbol{\cdot}, a] \in i$,
  * *accept* if $[S' \to S ,\boldsymbol{\cdot}, \varepsilon] \in i$.

* **GOTO**$[i,A]$ for $A \in V$.

$G$ is LR($k$) iff no ACTION entry contains a conflict.

---

### Conflict characterization

* **Shift–reduce conflict**: both shift and reduce actions are possible.
* **Reduce–reduce conflict**: two distinct reductions are possible.

$G$ is LR($k$) iff neither conflict arises in the canonical LR($k$) table.

---

### Hierarchy and strict inclusions

Let $\mathrm{LR}(k)$ denote the class of LR($k$) grammars.

$$
\mathrm{LR}(0) \subsetneq \mathrm{LR}(1) \subsetneq \mathrm{LR}(2) \subsetneq \dots \subsetneq \mathrm{LR}(\infty)
$$

Moreover:
$$
\mathrm{LR}(k) \subsetneq \mathrm{DCFL} \subsetneq \mathrm{CFL}.
$$

Every LR($k$) grammar generates a deterministic context-free language, but not conversely.

---

### Relationship to deterministic pushdown automata

For every LR($k$) grammar $G$, there exists a deterministic pushdown automaton $M$ such that
$$
L(M) = L(G).
$$

Conversely, for every $\mathrm{DCFL}$ there exists some $k$ and an equivalent LR($k$) grammar.

---

### Comparison with related grammar classes

Strict inclusions:
$$
\mathrm{LL}(k) \subsetneq \mathrm{LR}(k)
$$

LR parsing handles:

* left recursion,
* right associativity,
* a larger class of unambiguous grammars.

---

### Ambiguity and determinism

Every LR($k$) grammar is unambiguous.

The converse is false: there exist unambiguous CFGs that are not LR($k)$ for any finite $k$.

---

### Complexity

Let $n = |w|$.

* Parsing time: $O(n)$
* Stack height: $O(n)$
* Table size: exponential in $k$ and $|P|$

Canonical LR($k$) construction is exponential in grammar size.

---

### Practical restrictions

Due to complexity, restricted variants are used:

* LR($0$)
* SLR($1$)
* LALR($1$)

Each sacrifices recognition power for smaller parsing tables.

---

### Decidability

For fixed $k$:
$$
\text{LR}(k)\text{-MEMBERSHIP} = { \langle G \rangle \mid G \in \mathrm{LR}(k) }
$$
is decidable.

The problem
$$
\exists k; G \in \mathrm{LR}(k)
$$
is undecidable.

---

### Formal language implications

LR($k$) grammars provide:

* a constructive characterization of $\mathrm{DCFL}$,
* a bridge between CFGs and deterministic automata,
* a foundation for syntax-directed translation and compiler verification.

---

### Related topics

* LL($k$) grammars
* Deterministic context-free languages
* Pushdown automata
* Shift–reduce parsing
* LALR parsing
* Canonical item construction
* Syntax-directed translation


---

