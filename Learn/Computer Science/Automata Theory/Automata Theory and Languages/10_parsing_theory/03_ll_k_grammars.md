## LL(k) Grammars


### Formal Definition

Let $G = \langle V, \Sigma, P, S \rangle$ be a context-free grammar.
$G$ is **LL$k$** if for every nonterminal $A \in V$ and for all distinct productions

$$
A \to \alpha \qquad A \to \beta
$$

the following condition holds:

$$
\mathsf{FIRST}_k \alpha \cdot \mathsf{FOLLOW}_k A \ \cap\ \mathsf{FIRST}_k \beta \cdot \mathsf{FOLLOW}_k A = \varnothing
$$

Equivalently, for every leftmost derivation, the next production is uniquely determined by the next $k$ input symbols.

---

### $\mathsf{FIRST}_k$ and $\mathsf{FOLLOW}_k$ Sets

For $\alpha \in V^* \Sigma^*$,

$$
\mathsf{FIRST}_k \alpha = { w \in \Sigma^{\le k} \mid \exists x \in \Sigma^* : \alpha \Rightarrow^* w x }
$$

For a nonterminal $A$,

$$
\mathsf{FOLLOW}_k A = { w \in \Sigma^{\le k} \mid \exists u,v \in \Sigma^* : S \Rightarrow^* u A v \ \land\ v \Rightarrow^* w x }
$$

These sets are finite and effectively computable.

---

### Parsing Interpretation

LL$k$ grammars admit **deterministic top-down parsing**:

* Left-to-right input scan.
* Leftmost derivation.
* $k$-symbol lookahead.

The parser chooses productions without backtracking.

---

### Relationship to Pushdown Automata

Every LL$k$ grammar defines a deterministic pushdown automaton $M$ such that:

$$
L M = L G
$$

Conversely, not every deterministic context-free language admits an LL$k$ grammar.

Strict containment:

$$
\text{LL} \subsetneq \text{DCFL}
$$

where:

$$
\text{LL} = \bigcup_{k \ge 1} \text{LL} k
$$

---

### Left Recursion and LL Incompatibility

If a grammar contains direct or indirect left recursion:

$$
A \Rightarrow^+ A \alpha
$$

then it cannot be LL$k$ for any finite $k$.

Left recursion causes immediate ambiguity in top-down parsing since no terminal prefix distinguishes the recursive choice.

---

### Left Factoring

For productions:

$$
A \to \alpha \beta_1 \mid \alpha \beta_2
$$

LL$k$ requires transformation to:

$$
A \to \alpha A'
$$

$$
A' \to \beta_1 \mid \beta_2
$$

Left factoring reduces common prefixes but may increase grammar size and does not guarantee LL$k$-ness.

---

### Hierarchy of Lookahead

Strict hierarchy holds:

$$
\text{LL} 1 \subsetneq \text{LL} 2 \subsetneq \cdots \subsetneq \text{LL}
$$

For each $k$ there exists a language in $\text{LL} k+1$ not in $\text{LL} k$.

However:

$$
\bigcup_{k \ge 1} \text{LL} k \subsetneq \text{DCFL}
$$

---

### Ambiguity and Determinism

* Every LL$k$ grammar is unambiguous.
* There exist unambiguous grammars not in LL$k$ for any $k$.
* LL$k$ enforces a stronger syntactic determinism than unambiguity.

---

### Decidability and Complexity

For fixed $k$:

* Membership in $\text{LL} k$ is decidable.
* Testing whether a grammar is LL$k$ is decidable via $\mathsf{FIRST}_k$ and $\mathsf{FOLLOW}_k$ computation.
* Parsing runs in $O n$ time.

The constant factor grows exponentially with $k$ due to lookahead.

---

### Comparison with LR Parsing

* LL$k$ parses top-down.
* LR$k$ parses bottom-up.
* $\text{LL} k \subsetneq \text{LR} k$ for all $k \ge 1$.
* There exist deterministic context-free languages that are LR$1$ but not LL$k$ for any $k$.

---

### Expressive Limitations

LL$k$ grammars cannot express:

* Left-associative constructs without rewriting.
* Context-sensitive disambiguation.
* Languages requiring bottom-up context to decide reductions.

These limitations stem from the lack of stack content inspection beyond the top and fixed lookahead.

---

### Logical and Verification Perspective

LL$k$ grammars correspond to deterministic recursive descent procedures with bounded lookahead.

They support:

* Predictive parsing
* Syntax-directed translation
* Structural induction over parse trees

Their determinism simplifies proof obligations in parser correctness and compiler verification.

---

### Normal Forms and Transformations

* No canonical normal form for LL$k$ grammars exists.
* Transformation to LL$k$ may require grammar refactoring and language-preserving but structure-altering rewrites.
* Some CFLs have no LL$k$ grammar for any finite $k$.

---

### Related Topics

* Deterministic context-free languages
* LR parsing
* Predictive parsing
* Left recursion elimination
* Grammar ambiguity
* Pushdown automata
* Parsing complexity


---

