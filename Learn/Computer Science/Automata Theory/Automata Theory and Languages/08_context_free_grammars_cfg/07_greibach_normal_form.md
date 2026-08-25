## Greibach normal form


### Formal definition

A context-free grammar
$$
G = \langle V, \Sigma, P, S \rangle
$$
is in **Greibach normal form** iff every production in $P$ is of the form
$$
A \to a \alpha
$$
where:

* $A \in V$,
* $a \in \Sigma$,
* $\alpha \in V^*$,

and optionally
$$
S \to \varepsilon
$$
is permitted iff $\varepsilon \in L(G)$ and $S$ does not appear on the right-hand side of any production.

All derivations in GNF emit exactly one terminal symbol at each derivation step.

---

### Structural properties

For any $A \in V$ and any leftmost derivation
$$
A \Rightarrow_G^* w,
$$
if $|w| = n$ and $w \neq \varepsilon$, then the derivation consists of exactly $n$ production applications.

Consequences:

* Derivation length is linearly bounded by output length.
* No left recursion is possible.
* No $\varepsilon$-productions occur except possibly at $S$.

---

### Expressive completeness

For every context-free language $L \subseteq \Sigma^*$ with $L \setminus {\varepsilon} \neq \varnothing$, there exists a grammar $G$ in GNF such that
$$
L(G) = L \setminus {\varepsilon}.
$$
If $\varepsilon \in L$, then $L(G) = L$ by allowing $S \to \varepsilon$.

Thus GNF characterizes exactly the class $\mathrm{CFL}$.

---

### Transformation into GNF

Given a CFG $G$, construction of an equivalent GNF grammar proceeds via the following steps.

---

#### Step 1: Elimination of useless symbols

Remove all variables $A \in V$ such that:

* $A \not\Rightarrow_G^* w$ for all $w \in \Sigma^*$, or
* $S \not\Rightarrow_G^* \gamma A \delta$ for all $\gamma, \delta \in (V \cup \Sigma)^*$.

This preserves $L(G)$.

---

#### Step 2: Elimination of $\varepsilon$-productions

Remove all productions $A \to \varepsilon$ except possibly $S \to \varepsilon$ if $\varepsilon \in L(G)$, introducing compensating productions for nullable variables.

---

#### Step 3: Elimination of unit productions

Eliminate all productions of the form
$$
A \to B
$$
with $A,B \in V$, using the unit-derivation closure
$$
A \Rightarrow_{\mathrm{unit}}^* B.
$$

---

#### Step 4: Removal of left recursion

Eliminate both direct and indirect left recursion. For variables $A_1, \dots, A_n$ ordered linearly, rewrite productions so that no production has the form
$$
A_i \Rightarrow^+ A_i \alpha.
$$

This step is essential, since GNF forbids left recursion entirely.

---

#### Step 5: Terminal-fronting transformation

For each production
$$
A \to B_1 B_2 \dots B_k,
$$
replace it by productions obtained from all rules
$$
B_1 \to a \gamma
$$
yielding
$$
A \to a \gamma B_2 \dots B_k.
$$

Iterate until every production begins with a terminal.

---

### Complexity of the transformation

The conversion from an arbitrary CFG to GNF may cause exponential blowup in the number of productions in the worst case:
$$
|P_{\mathrm{GNF}}| = 2^{\Theta(|P|)}.
$$

The transformation is computable but not size-efficient. No polynomial-size GNF conversion exists unless $\mathrm{P} = \mathrm{NP}$.

---

### Derivational consequences

For any grammar $G$ in GNF and any $w \in L(G)$ with $|w| = n$:

* Every leftmost derivation has length exactly $n$.
* Every parse tree has height $O(n)$.
* The branching factor is bounded by $|V|$.

---

### Relationship to pushdown automata

GNF grammars correspond directly to **real-time nondeterministic pushdown automata**.

Given a production
$$
A \to a B_1 \dots B_k,
$$
the PDA transition is:
$$
\delta(q, a, A) \ni (q, B_k \dots B_1).
$$

Thus every CFL is accepted by a PDA that consumes exactly one input symbol per transition.

---

### Parsing implications

* Top-down parsing without backtracking is facilitated by GNF structure.
* Predictive parsing is still undecidable in general due to ambiguity.
* Membership testing remains $O(n^3)$ in the worst case.

GNF is foundational for proofs of:

* decidability of membership,
* equivalence between derivations and PDA computations.

---

### Limitations

GNF does not:

* eliminate ambiguity,
* provide efficient grammars in practice,
* preserve grammar size,
* ensure deterministic parsing.

GNF is unsuitable for practical parser construction but central in theoretical reductions.

---

### Logical and algebraic interpretation

GNF derivations correspond to:

* stepwise unfolding of inductive definitions,
* linear-time derivation semantics,
* algebraic series with terminal-leading monomials.

GNF is essential in proofs involving:

* bounded derivation depth,
* pumping arguments for CFLs,
* normal-form–based reductions.

---

### Decidability and verification roles

GNF enables:

* simulation of CFGs by real-time PDAs,
* encoding CFL membership into bounded-step computations,
* reductions from CFL properties to PDA reachability.

---

### Related topics

* Chomsky normal form
* Left recursion elimination
* Pushdown automata
* Real-time computation
* Context-free language pumping
* Grammar ambiguity
* Parsing theory

---

