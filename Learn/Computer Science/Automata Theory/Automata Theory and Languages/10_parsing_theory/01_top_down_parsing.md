## Top-down parsing


### Predictive derivation model

Top-down parsing constructs a **leftmost derivation** of a string $w \in \Sigma^*$ starting from the start symbol $S$ of a CFG
$$
G = \langle V, \Sigma, P, S \rangle
$$
by repeatedly expanding the leftmost nonterminal.

Formally, parsing searches for a derivation
$$
S \Rightarrow^*_{lm} w
$$
using a control strategy that selects productions based on the current input prefix.

---

### Pushdown automaton characterization

Top-down parsers correspond exactly to **deterministic pushdown automata** that:

* Push the right-hand side of productions onto the stack
* Match terminals against input symbols
* Never inspect stack symbols below the top

The canonical PDA $M_G$ satisfies:
$$
L_E(M_G) = L(G)
$$
with acceptance by empty stack.

---

### LL parsing framework

A grammar is **LL $\lparen k \rparen$** if there exists a deterministic top-down parser that decides which production to apply using at most $k$ symbols of lookahead.

Formally, $G$ is LL $\lparen k \rparen$ if for any two distinct productions
$$
A \to \alpha \quad A \to \beta
$$
the sets
$$
\text{FIRST}_k(\alpha \gamma), \quad \text{FIRST}_k(\beta \gamma)
$$
are disjoint for all $\gamma \in \Sigma^*$ derivable from the context.

---

### FIRST and FOLLOW sets

For $\alpha \in \lparen V \cup \Sigma \rparen^*$, define
$$
\text{FIRST}(\alpha) = { a \in \Sigma \mid \alpha \Rightarrow^* a \gamma } \cup { \epsilon \mid \alpha \Rightarrow^* \epsilon }
$$

For $A \in V$, define
$$
\text{FOLLOW}(A) = { a \in \Sigma \mid S \Rightarrow^* \alpha A a \beta } \cup { $ \mid S \Rightarrow^* \alpha A }
$$

These sets determine predictive parsing tables.

---

### LL $\lparen 1 \rparen$ decision condition

A grammar $G$ is LL $\lparen 1 \rparen$ if and only if for each $A \in V$:

* $\text{FIRST}(\alpha_i) \cap \text{FIRST}(\alpha_j) = \emptyset$ for $i \neq j$
* If $\epsilon \in \text{FIRST}(\alpha_i)$, then
  $$
  \text{FIRST}(\alpha_j) \cap \text{FOLLOW}(A) = \emptyset
  $$

for all productions $A \to \alpha_i$, $A \to \alpha_j$.

---

### Grammar transformations for top-down parsing

#### Left recursion elimination

Immediate left recursion:
$$
A \to A\alpha \mid \beta
$$
is transformed into:
$$
A \to \beta A' \quad A' \to \alpha A' \mid \epsilon
$$

Indirect left recursion requires nonterminal ordering and substitution.

Left recursion elimination preserves the generated language but may introduce ambiguity.

---

#### Left factoring

If productions share a common prefix:
$$
A \to \alpha \beta_1 \mid \alpha \beta_2
$$
factor into:
$$
A \to \alpha A' \quad A' \to \beta_1 \mid \beta_2
$$

Left factoring preserves LL predictability but not unambiguity in general.

---

### Expressive limitations

Top-down parsing cannot handle:

* Left-recursive grammars
* Grammars requiring unbounded lookahead
* Many unambiguous but non-LL languages

Formally:
$$
\text{LL} \subsetneq \text{DCFL}
$$

---

### Determinism and ambiguity

All LL grammars are unambiguous.

Proof follows from uniqueness of production choice at each derivation step under deterministic lookahead.

The converse fails: there exist unambiguous CFLs not in LL.

---

### Parsing table construction

For LL $\lparen 1 \rparen$, the parsing table
$$
M : V \times \lparen \Sigma \cup {$} \rparen \to P
$$
is defined by:

* If $a \in \text{FIRST}(\alpha)$, insert $A \to \alpha$ in $M[A,a]$
* If $\epsilon \in \text{FIRST}(\alpha)$, insert $A \to \alpha$ in $M[A,b]$ for all $b \in \text{FOLLOW}(A)$

Conflicts imply non-LL grammar.

---

### Complexity guarantees

For LL $\lparen 1 \rparen$ grammars:

* Parsing time:
  $$
  O(n)
  $$
* Stack depth bounded by derivation depth
* No backtracking required

---

### Relation to top-down automata

LL parsing corresponds to deterministic PDAs with:

* No $\epsilon$-moves except nonterminal expansions
* Stack symbols encoding grammar symbols
* Acceptance by empty stack

These PDAs are strictly less expressive than general deterministic PDAs.

---

### Logical characterization

LL languages correspond to CFLs definable by existential monadic second-order logic with bounded quantifier alternation under prefix constraints.

---

### Comparison with bottom-up parsing

Top-down parsing:

* Predicts structure from root to leaves
* Matches leftmost derivations
* Uses FIRST and FOLLOW constraints

Bottom-up parsing constructs rightmost derivations in reverse and strictly dominates LL in expressive power.

---

### Related topics

* LL $\lparen k \rparen$ grammars
* Predictive parsing
* Recursive descent parsers
* Deterministic pushdown automata
* LR parsing
* Left recursion elimination

---

