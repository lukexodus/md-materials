## Recursive Descent Parsing


### Formal Framework

Recursive descent parsing is a top-down parsing method implementing a leftmost derivation for a context-free grammar $G = \langle V, \Sigma, P, S \rangle$ by a family of mutually recursive procedures, one per nonterminal in $V$.

Each procedure for $A \in V$ recognizes exactly the language
$$
L_A = { w \in \Sigma^* \mid A \Rightarrow^* w }
$$
and succeeds iff the input prefix matches a right-sentential form derived from $A$.

Correctness requires that parsing decisions be made deterministically using bounded lookahead.

---

### Grammar Restrictions and LL Parsing

Recursive descent without backtracking is correct iff $G$ is an $\mathsf{LL}(k)$ grammar for some fixed $k \ge 1$.

#### LL$(k)$ Condition

For each nonterminal $A$ with productions
$$
A \to \alpha_1 \mid \cdots \mid \alpha_n
$$
the grammar is $\mathsf{LL}(k)$ iff
$$
\mathsf{FIRST}_k(\alpha_i \beta) \cap \mathsf{FIRST}_k(\alpha_j \beta) = \emptyset
$$
for all $i \ne j$ and all $\beta$ such that
$$
S \Rightarrow^* A\beta
$$

For $\mathsf{LL}(1)$, this reduces to disjointness of $\mathsf{FIRST}$ sets, with $\mathsf{FOLLOW}$ used when $\epsilon \in \mathsf{FIRST}(\alpha)$.

---

### FIRST and FOLLOW Sets

For $\alpha \in (V \cup \Sigma)^*$,
$$
\mathsf{FIRST}(\alpha) = { a \in \Sigma \mid \alpha \Rightarrow^* a\gamma } \cup { \epsilon \mid \alpha \Rightarrow^* \epsilon }
$$

For $A \in V$,
$$
\mathsf{FOLLOW}(A) = { a \in \Sigma \mid S \Rightarrow^* xAa y } \cup { $ \mid S \Rightarrow^* xA }
$$
where $\$$ denotes end-of-input.

The predictive parsing condition for $\mathsf{LL}(1)$ is:
$$
\mathsf{FIRST}(\alpha_i) \cap \mathsf{FIRST}(\alpha_j) = \emptyset
$$
and if $\epsilon \in \mathsf{FIRST}(\alpha_i)$ then
$$
\mathsf{FIRST}(\alpha_j) \cap \mathsf{FOLLOW}(A) = \emptyset
$$

---

### Parsing Procedure Semantics

Each nonterminal $A$ corresponds to a procedure $\mathsf{parse}*A$ implementing:
$$
A \Rightarrow*\ell^* w
$$
for the consumed input $w$.

Operationally, the call stack of recursive descent corresponds to the parse tree spine of a leftmost derivation.

The parser accepts iff the call to $\mathsf{parse}_S$ consumes the entire input.

---

### Left Recursion Elimination

Immediate left recursion:
$$
A \to A\alpha \mid \beta
$$
causes nontermination.

Transformation:
$$
A \to \beta A' \
A' \to \alpha A' \mid \epsilon
$$

General left recursion is eliminated by topological ordering of nonterminals and substitution:
$$
A_i \to A_j \gamma \quad j < i
$$

Left recursion elimination preserves language equivalence but not derivation structure.

---

### Left Factoring

If
$$
A \to \alpha\beta_1 \mid \alpha\beta_2
$$
then factor as
$$
A \to \alpha A' \
A' \to \beta_1 \mid \beta_2
$$

Left factoring enforces determinism of choice in recursive descent by delaying decision until sufficient input is seen.

---

### Predictive Parsing Table

Recursive descent corresponds to a table-driven predictive parser with table
$$
M : V \times (\Sigma \cup {$}) \to P \cup {\text{error}}
$$

Construction rule:
$$
M[A,a] = A \to \alpha \quad \text{if } a \in \mathsf{FIRST}(\alpha)
$$
and if $\epsilon \in \mathsf{FIRST}(\alpha)$ then
$$
M[A,b] = A \to \alpha \quad \text{for all } b \in \mathsf{FOLLOW}(A)
$$

Grammar is $\mathsf{LL}(1)$ iff $M$ is single-valued.

---

### Backtracking Recursive Descent

Allowing backtracking removes the $\mathsf{LL}(k)$ restriction but yields worst-case exponential time.

Backtracking corresponds to exploring the nondeterministic choices of a top-down PDA.

In the worst case, membership is $\mathsf{EXPTIME}$-complete for unrestricted backtracking parsers.

---

### Relation to Pushdown Automata

Recursive descent implements a deterministic PDA whose stack alphabet corresponds to nonterminals.

Acceptance is by empty stack and end-of-input.

For $\mathsf{LL}(1)$ grammars, the corresponding DPDA is deterministic:
$$
\mathsf{LL}(1) \subsetneq \mathsf{DCFL}
$$

---

### Error Detection and Recovery

In predictive recursive descent, an error is detected when:
$$
a \notin \mathsf{FIRST}(\alpha) \cup \mathsf{FOLLOW}(A)
$$

Panic-mode recovery skips input symbols until a synchronizing token in $\mathsf{FOLLOW}(A)$ is found.

Error recovery does not preserve language recognition semantics.

---

### Complexity

For $\mathsf{LL}(1)$ grammars:

* Time: $O(|w|)$
* Space: $O(h)$ where $h$ is parse tree height

For backtracking grammars:

* Time: exponential in $|w|$ in worst case

---

### Expressive Limitations

Recursive descent without backtracking cannot parse:

* Left-recursive grammars
* Ambiguous grammars
* Non-$\mathsf{LL}(k)$ CFLs

Languages such as
$$
{ a^n b^n c^n \mid n \ge 0 }
$$
are not context-free and therefore not parsable by any recursive descent method.

---

### Relationship to LR Parsing

Recursive descent constructs leftmost derivations; LR parsing constructs rightmost derivations in reverse.

$\mathsf{LR}(1)$ strictly subsumes $\mathsf{LL}(1)$:
$$
\mathsf{LL}(1) \subsetneq \mathsf{LR}(1)
$$

Certain deterministic CFLs are not amenable to top-down parsing.

---

### Formal Verification View

Recursive descent corresponds to structurally recursive programs whose correctness can be proved by induction on derivation depth.

Termination is guaranteed iff the grammar is non-left-recursive.

---

### Related Topics

* LL$(k)$ grammars
* FIRST and FOLLOW sets
* Predictive parsing
* Left recursion elimination
* Deterministic pushdown automata
* LR parsing
* Top-down parsing algorithms


---

