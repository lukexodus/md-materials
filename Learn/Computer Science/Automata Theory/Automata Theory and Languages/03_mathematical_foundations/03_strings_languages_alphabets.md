## Strings, Languages, Alphabets


### Alphabets and Free Monoids

Let $\Sigma$ be a finite, nonempty set of symbols. The set of all finite strings over $\Sigma$ is denoted $\Sigma^*$ and forms the free monoid under concatenation, with identity element $\varepsilon$. Concatenation is an associative binary operation $\cdot : \Sigma^* \times \Sigma^* \to \Sigma^*$, yielding the algebraic structure $\langle \Sigma^*, \cdot, \varepsilon \rangle$.

The universal property holds: for any monoid $\langle M, \circ, e \rangle$ and any function $f : \Sigma \to M$, there exists a unique monoid homomorphism $\hat f : \Sigma^* \to M$ extending $f$.

The length function $|\cdot| : \Sigma^* \to \mathbb{N}$ is the unique monoid homomorphism mapping each symbol to $1$. For $w \in \Sigma^*$, $w[i]$ denotes the $i$-th symbol and $w[i..j]$ the corresponding factor.

Define
$$
\Sigma^n = { w \in \Sigma^* \mid |w| = n }
$$
which yields the graded decomposition
$$
\Sigma^* = \bigsqcup_{n \ge 0} \Sigma^n .
$$

### Structural Orders on Strings

Several partial orders on $\Sigma^*$ are central to language-theoretic arguments.

Prefix order:
$$
u \preceq_p v \iff \exists x \in \Sigma^* : v = ux
$$

Suffix order:
$$
u \preceq_s v \iff \exists x \in \Sigma^* : v = xu
$$

Factor order:
$$
u \preceq_f v \iff \exists x,y \in \Sigma^* : v = xuy
$$

Subsequence order:
$$
u \preceq_{sub} v \iff u \text{ is obtained from } v \text{ by deleting symbols}
$$

Higman’s Lemma establishes that $\langle \Sigma^*, \preceq_{sub} \rangle$ is a well-quasi-order. This property underpins decidability results for downward-closed languages and regular separability.

### Languages as Algebraic Objects

A language over $\Sigma$ is a subset $L \subseteq \Sigma^*$. The powerset $\mathcal{P}(\Sigma^*)$ forms a Boolean algebra under union, intersection, and complement. Equipped with concatenation
$$
L_1 \cdot L_2 = { uv \mid u \in L_1, v \in L_2 }
$$
it forms an idempotent semiring with zero $\emptyset$ and unit ${ \varepsilon }$.

The Kleene star is defined by
$$
L^* = \bigcup_{n \ge 0} L^n
$$
and is the least fixed point of the operator
$$
X \mapsto { \varepsilon } \cup L \cdot X .
$$

### Quotients and Syntactic Structure

For $L \subseteq \Sigma^*$ and $w \in \Sigma^*$, define left and right quotients:
$$
w^{-1} L = { x \in \Sigma^* \mid wx \in L }
$$
$$
L w^{-1} = { x \in \Sigma^* \mid xw \in L }
$$

These induce the syntactic congruence
$$
u \equiv_L v \iff \forall x,y \in \Sigma^* : xuy \in L \Leftrightarrow xvy \in L .
$$

The quotient monoid $\Sigma^* / \equiv_L$ is the syntactic monoid of $L$. Finiteness of this monoid is equivalent to regularity by the Myhill–Nerode theorem.

### Cardinality and Growth Properties

Languages may be classified by size and asymptotic density. Define the growth function
$$
g_L n = | L \cap \Sigma^n | .
$$

Regular languages admit rational generating functions
$$
G_L z = \sum_{n \ge 0} g_L n z^n .
$$

Context-free languages admit algebraic generating functions. For general recursively enumerable languages, growth functions may be non-recursive.

### Decision Problems on Languages

Given effective representations, classical decision problems include:

Emptiness:
$$
L = \emptyset
$$

Universality:
$$
L = \Sigma^*
$$

Inclusion:
$$
L_1 \subseteq L_2
$$

Equivalence:
$$
L_1 = L_2
$$

Equivalence and inclusion are decidable for regular languages, undecidable for context-free languages, and trivially undecidable for recursively enumerable languages.

### Closure Sensitivity and Alphabet Transformations

Language classes exhibit non-uniform behavior under operations such as complement, concatenation, star, homomorphism, inverse homomorphism, projection, and alphabet extension. These transformations are central to hierarchy separations and collapse results, particularly in connections to logic and complexity.

### Logical Correspondence

Words over $\Sigma$ can be viewed as finite relational structures with unary predicates indexed by alphabet symbols. Under this interpretation:

Regular languages coincide with MSO-definable languages over finite words.

FO-definable languages form a strict subclass characterized algebraically by aperiodic syntactic monoids.

The characteristic function
$$
\chi_L : \Sigma^* \to {0,1}
$$
connects language theory with Boolean-valued logic and descriptive complexity.

### Related Topics

* Syntactic Monoids and Varieties
* Rational and Algebraic Series
* String Rewriting and Thue Systems
* Trace Monoids
* Well-Quasi-Orders on Words
* Descriptive Complexity of Formal Languages

---

