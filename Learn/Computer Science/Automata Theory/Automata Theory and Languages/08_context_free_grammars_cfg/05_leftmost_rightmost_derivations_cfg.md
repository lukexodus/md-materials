## Leftmost & rightmost derivations (CFG)


**Setting.** Context-free grammar $G=\langle V,\Sigma,R,S\rangle$ with variables $V$, terminals $\Sigma$, productions $R\subseteq V\times (V\cup \Sigma)^*$, start symbol $S$.

---

### Sentential forms and derivations

A **sentential form** is any $\alpha\in (V\cup \Sigma)^*$ derivable from $S$ by $R$. One-step derivation relation:
$$\alpha \Rightarrow_G \beta ;\Longleftrightarrow; \exists A\to \gamma\in R,;\alpha=xAy,;\beta=x\gamma y.$$

Reflexive–transitive closure: $\Rightarrow_G^*$.

---

### Leftmost derivations

**Leftmost step.** $\alpha \Rightarrow_\ell \beta$ iff in $\alpha=xAy$ the variable $A$ is the **leftmost** variable of $\alpha$.

**Leftmost derivation.** $w\in \Sigma^*$ has a leftmost derivation if
$$S \Rightarrow_\ell^* w.$$

Properties:

* Every leftmost derivation is a derivation: $\Rightarrow_\ell^*\subseteq \Rightarrow^*$.
* In a leftmost derivation, at every step the unique rewritten variable is the leftmost nonterminal in the current sentential form.

---

### Rightmost derivations

**Rightmost step.** $\alpha \Rightarrow_r \beta$ iff in $\alpha=xAy$ the variable $A$ is the **rightmost** variable of $\alpha$.

**Rightmost derivation.** $w$ has a rightmost derivation if $S\Rightarrow_r^* w$.

Properties analogous to leftmost with rightmost variable selection constraint.

---

### Equivalence to derivability and parse trees

For any $w\in \Sigma^*$:

$$S\Rightarrow^* w \quad\Longleftrightarrow\quad S\Rightarrow_\ell^* w \quad\Longleftrightarrow\quad S\Rightarrow_r^* w.$$

Proof outline:

* $\Leftarrow$ direction is immediate.
* $\Rightarrow$ direction by induction on the number of derivation steps and variable-permutation lemma: any derivation can be rearranged into a leftmost or rightmost schedule because productions only expand variables independent of sibling order in the tree.

**Parse trees.** Each leftmost or rightmost derivation corresponds to a unique parse tree; conversely each parse tree induces a unique leftmost and a unique rightmost derivation (string of productions in preorder or reverse preorder traversal).

---

### Ambiguity and multiple derivations

Ambiguity criterion:

* Grammar $G$ is **ambiguous** iff there exists $w\in \Sigma^*$ with two distinct leftmost derivations (equivalently, two distinct rightmost derivations; equivalently, two distinct parse trees).

Hence leftmost and rightmost derivational ambiguity coincide.

---

### Derivation sequences and production histories

**Leftmost derivation sequence.** Sequence of productions applied when always choosing the leftmost variable. The **leftmost derivation yield** equals the frontier yield of the parse tree.

**Yield-preservation lemma.** For a fixed parse tree $T$:

* Leftmost derivation is obtained by repeatedly expanding leftmost unexpanded node of $T$.
* Rightmost derivation uses rightmost unexpanded node.

The production sequence can differ, but yields coincide.

---

### Normal forms and derivation properties

**Chomsky normal form (CNF).** In CNF, every non-$\epsilon$ derivation has length $2|w|-1$ steps. Both leftmost and rightmost derivations have the same fixed length for a given $w$:
$$\text{number of steps}=2|w|-1.$$

**Greibach normal form (GNF).** Every production has form $A\to a\alpha$ with $a\in \Sigma$. Leftmost derivations in GNF generate the first terminal of $w$ at each step; yields correspond directly to left-to-right scanning. Rightmost derivations in GNF still exist but lose the immediate-prefix property.

---

### Deterministic parsing connections

**LL parsing.** Predictive parsing constructs leftmost derivations using left-to-right input scan. LL($k$) grammars: leftmost derivation determined by $k$-symbol lookahead. Left recursion obstructs deterministic leftmost derivation choice.

**LR parsing.** Bottom-up parsers construct rightmost derivations **in reverse** (rightmost derivation in reverse, or canonical LR derivation). LR($k$) grammars guarantee determinism of this reversed rightmost derivation with $k$-symbol lookahead.

Correspondence:

* LL $\Longleftrightarrow$ deterministic leftmost derivation construction.
* LR $\Longleftrightarrow$ deterministic reverse rightmost derivation construction.

---

### Formal relationships and equivalences

**Left–right derivation duality.**

For every $w$ and parse tree $T$:

* $T$ induces exactly one leftmost and one rightmost derivation.
* Different parse trees may share either leftmost or rightmost derivations only if grammar has useless productions; otherwise coincidence implies identical tree.

**Leftmost versus rightmost length bounds.**

Let $h$ be height of parse tree $T$. In unrestricted CFG,
$$|w|\le \text{derivation length}\le c\cdot |w|^h$$
for some grammar-dependent constant $c$; however leftmost and rightmost derivation lengths for a fixed $T$ are identical and equal to the number of internal nodes.

---

### Derivation-based proofs of non-context-freeness

Use of **leftmost derivation constraints** in pumping/interchange arguments:

* Ogden’s lemma and interchange lemma reason about marked occurrences within leftmost derivations.
* Leftmost derivation subtrees serve as loci for pumping paths in derivation trees, ensuring preservation of leftmost derivation order during pumping.

---

### Decidability aspects

* Given $G$ and $w$, existence of a leftmost (or rightmost) derivation of $w$ is decidable in polynomial time via CYK (CNF) or Earley parsing; equivalently membership.
* Ambiguity detection via multiplicity of leftmost derivations is undecidable in general; inherent ambiguity persists under both leftmost and rightmost perspectives.

---

### Transformations preserving derivation type

* Left factoring and elimination of left recursion preserve language but change leftmost derivation determinism properties.
* Grammar equivalence transformations may alter leftmost versus rightmost derivation sequences while preserving parse trees modulo node ordering.

---

### Related topics

* Parse trees and derivation trees
* Normal forms for CFGs
* LL and LR parsing families
* Ambiguity and inherent ambiguity of CFLs
* Pumping and interchange lemmas for CFLs


---

