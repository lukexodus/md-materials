## Countability & Uncountability


### Cardinality Framework

Let $\Sigma$ be a finite alphabet. A set $A$ is **countable** iff there exists an injection $A \to \mathbb{N}$, **countably infinite** iff there exists a bijection $A \leftrightarrow \mathbb{bb{N}}$, and **uncountable** otherwise. Denote $|\mathbb{N}| = \aleph_0$ and $|\mathbb{R}| = 2^{\aleph_0}$.

Cantor’s theorem establishes strict growth of cardinality under the powerset operator:
$$
|A| < |\mathcal{P}(A)|
$$
for any set $A$. This result underlies all uncountability arguments in computability and language theory.

### Countability of Syntactic Objects

All finitely described formal objects are countable.

* $\Sigma^*$ is countably infinite via length-lexicographic enumeration.
* Finite automata, pushdown automata, Turing machines, grammars, logical formulas, and proofs admit finite encodings as strings in $\Sigma^*$.
* The set of all algorithms and the set of all computable functions are countable.

Formally, any class of objects representable by finite strings over a finite alphabet is countable.

### Languages as Sets of Strings

A language $L$ over $\Sigma$ is a subset $L \subseteq \Sigma^*$ and corresponds to its characteristic function $\chi_L : \Sigma^* \to {0,1}$.

Since $\Sigma^*$ is countable, its powerset is uncountable:
$$
|\mathcal{P}(\Sigma^*)| = 2^{\aleph_0}
$$

Therefore, the class of all languages over $\Sigma$ is uncountable.

### Countability of Language Classes

Let $\mathcal{C}$ be a class of languages defined by a finitely describable computational model.

* Regular languages are countable, since deterministic finite automata are finite objects.
* Context-free languages are countable, since context-free grammars are finite.
* Recursively enumerable languages are countable, since Turing machines are countable.
* Recursive languages are countable as a subclass of recursively enumerable languages.

Hence the strict hierarchy
$$
\mathrm{REG} \subset \mathrm{CFL} \subset \mathrm{REC} \subset \mathrm{RE} \subset \mathcal{P}(\Sigma^*)
$$
where the final inclusion is strict by cardinality alone.

### Uncountability and Non-Computability

Since $\mathrm{RE}$ is countable and $\mathcal{P}(\Sigma^*)$ is uncountable,
$$
|\mathcal{P}(\Sigma^*) \setminus \mathrm{RE}| = 2^{\aleph_0}
$$

Thus, almost all languages are not recursively enumerable, and a fortiori not decidable.

Let ${ M_i }*{i \in \mathbb{N}}$ be an effective enumeration of Turing machines, and let ${ w_i }*{i \in \mathbb{N}}$ be a computable enumeration of $\Sigma^*$. Define the diagonal language
$$
L_D = { w_i \mid M_i \text{ does not accept } w_i }
$$
Then $L_D \notin \mathrm{RE}$ by diagonalization.

### Decision Problems and Cardinality

Decision problems are languages over ${0,1}^*$.

* The set of all decision problems is uncountable.
* The set of decidable decision problems is countable.

Undecidability is therefore the norm rather than the exception within $\mathcal{P}(\Sigma^*)$.

### Real Numbers and Computable Reals

The analogy with real analysis is exact.

* $\mathbb{R}$ is uncountable.
* The set of computable real numbers is countable.
* Almost all real numbers are non-computable.

Similarly, almost all infinite binary sequences and almost all languages are non-computable.

### Oracle Computation and Cardinality

For a fixed oracle $A$:

* The class of $A$-computable languages is countable.

However, the set of all oracles $A \subseteq \Sigma^*$ is uncountable. Oracle constructions exploit this asymmetry to establish relativized separations.

### Measure-Theoretic Refinements

Beyond cardinality, measure-theoretic results strengthen the picture.

* The set of decidable languages has measure zero in ${0,1}^{\mathbb{N}}$.
* Almost all languages are algorithmically random and incompressible.

Algorithmic randomness refines uncountability into structural typicality.

### Reductions and Completeness

Effective reductions preserve countability.

* The image of a countable class under any computable many-one or Turing reduction is countable.
* Completeness results classify maximal elements within countable strata embedded in an uncountable universe.

### Logical Definability

* Languages definable in first-order logic, monadic second-order logic, or fixed higher-order logics are countable.
* The space of all semantic interpretations over infinite structures is uncountable.

### Related Topics

* Diagonalization
* Halting problem
* Rice’s theorem
* Computable analysis
* Algorithmic randomness
* Oracle machines
* Measure and category in complexity
* Descriptive set complexity


---

