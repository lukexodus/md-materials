## Sentential Forms & Derivations


### Formal Setting

Let $G = \langle V, \Sigma, P, S \rangle$ be a context-free grammar with variables $V$, terminals $\Sigma$, productions $P \subseteq V \times \left(V \cup \Sigma\right)^*$, and start symbol $S$.

Define the alphabet of sentential forms as $V \cup \Sigma$.

### Sentential Forms

A **sentential form** is any string $\alpha \in \left(V \cup \Sigma\right)^*$ such that
$$
S \Rightarrow^* \alpha
$$
where $\Rightarrow$ denotes the single-step derivation relation induced by $P$.

The set of all sentential forms is
$$
\mathsf{SF}!\left(G\right) = { \alpha \in \left(V \cup \Sigma\right)^* \mid S \Rightarrow^* \alpha }
$$

Terminal strings are those $\alpha \in \Sigma^*$; the generated language is
$$
L!\left(G\right) = \mathsf{SF}!\left(G\right) \cap \Sigma^*
$$

### Derivation Relation

For $\alpha, \beta \in \left(V \cup \Sigma\right)^*$,
$$
\alpha \Rightarrow \beta
$$
iff there exist $x,y \in \left(V \cup \Sigma\right)^*$, $A \in V$, and $A \to \gamma \in P$ such that
$$
\alpha = xAy \quad \land \quad \beta = x\gamma y
$$

The reflexive–transitive closure $\Rightarrow^*$ defines multi-step derivations.

### Leftmost and Rightmost Derivations

A **leftmost derivation** restricts rewriting to the leftmost variable:
$$
\alpha \Rightarrow_\ell \beta \iff \alpha = xAy,\ x \in \Sigma^*,\ A \in V
$$

A **rightmost derivation** restricts rewriting to the rightmost variable:
$$
\alpha \Rightarrow_r \beta \iff \alpha = xAy,\ y \in \Sigma^*,\ A \in V
$$

For all $\alpha \in \Sigma^*$:
$$
S \Rightarrow^* \alpha \iff S \Rightarrow_\ell^* \alpha \iff S \Rightarrow_r^* \alpha
$$

Thus unrestricted, leftmost, and rightmost derivations are equivalent in generative power.

### Derivation Length and Depth

The **length** of a derivation is the number of production applications. The **derivation height** corresponds to the height of the induced parse tree.

There exists no recursive bound on derivation length as a function of $|\alpha|$ for arbitrary CFGs due to ambiguity and left recursion.

### Parse Trees and Yield

A parse tree $T$ is a rooted, ordered tree with:

* Internal nodes labeled by variables
* Leaves labeled by terminals or $\epsilon$
* Each internal node labeled $A$ has children labeled by $\gamma$ if $A \to \gamma \in P$

The yield function $\mathsf{yield}(T)$ is the left-to-right concatenation of leaf labels.

For every derivation $S \Rightarrow^* w$, there exists a parse tree $T$ such that $\mathsf{yield}(T) = w$, and conversely.

Leftmost and rightmost derivations correspond to depth-first traversals of the same parse tree.

### Ambiguity and Derivations

A string $w \in L(G)$ is **ambiguous** if there exist two distinct parse trees for $w$, equivalently two distinct leftmost derivations:
$$
S \Rightarrow_\ell^* w \quad \text{via two distinct sequences}
$$

A grammar is ambiguous if it admits an ambiguous string.

There exist inherently ambiguous CFLs for which no unambiguous CFG exists.

### Normal Forms and Derivation Structure

#### Chomsky Normal Form

In CNF, productions satisfy:
$$
A \to BC \quad \text{or} \quad A \to a \quad \text{or} \quad S \to \epsilon
$$

Every derivation of a string $w$ with $|w| = n$ has exactly $2n-1$ production applications.

#### Greibach Normal Form

In GNF, productions satisfy:
$$
A \to a\alpha \quad \alpha \in V^*
$$

Every leftmost derivation produces exactly one terminal per step, yielding derivation length $|w|$.

### Derivational Equivalence and Grammar Transformations

Two grammars $G_1$ and $G_2$ are weakly equivalent if
$$
L(G_1) = L(G_2)
$$

They are strongly equivalent if they generate identical parse trees or derivation structures.

CNF and GNF preserve weak but not strong equivalence.

### Sentential Forms in Parsing Algorithms

Bottom-up parsing reconstructs sentential forms in reverse derivational order. For LR parsing, viable prefixes correspond to prefixes of right-sentential forms.

The set of viable prefixes is regular and recognized by a DFA constructed from LR items.

### Decidability Properties

Given a CFG $G$ and sentential form $\alpha$:

* Reachability: deciding $S \Rightarrow^* \alpha$ is undecidable
* Membership: deciding $\alpha \in \Sigma^*$ and $S \Rightarrow^* \alpha$ is decidable in $O(|\alpha|^3)$ via CYK
* Ambiguity: undecidable

### Pumping and Derivations

The CFL pumping lemma follows from parse tree height arguments: for sufficiently long $w \in L(G)$, any derivation tree contains repeated variables along a root-to-leaf path, yielding decompositions
$$
w = uvxyz
$$
with derivational repetition.

### Relation to Pushdown Automata

Sentential forms correspond to PDA stack contents during leftmost derivation simulation.

For every CFG $G$, there exists a PDA $M$ such that:
$$
S \Rightarrow_\ell^* w \iff M \text{ accepts } w
$$

### Related Topics

* Parse trees
* Grammar ambiguity
* Chomsky normal form
* Greibach normal form
* LR parsing and viable prefixes
* Pushdown automata simulation
* Inherent ambiguity


---

