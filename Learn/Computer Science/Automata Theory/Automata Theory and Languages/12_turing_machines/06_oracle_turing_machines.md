## Oracle Turing Machines


### Formal Model

An **oracle Turing machine** is a Turing machine augmented with access to an oracle language $A \subseteq \Sigma^*$. Formally, an oracle Turing machine is a tuple
$$
M^A = \langle Q, \Sigma, \Gamma, \delta, q_0, q_{\mathrm{acc}}, q_{\mathrm{rej}}, q_{\mathrm{query}} \rangle
$$
where all components are as in a standard single-tape Turing machine, except that:

* There is a distinguished **query state** $q_{\mathrm{query}}$.
* The transition function $\delta$ is extended with oracle semantics.

When $M^A$ enters $q_{\mathrm{query}}$ with a string $x \in \Sigma^*$ written on a designated query tape or region, the machine receives an instantaneous answer indicating whether
$$
x \in A.
$$
Based on this answer, $M^A$ transitions deterministically to a next state.

Oracle access is abstract and unbounded in computational power, with each query counted as a single step unless otherwise specified.

### Computation and Acceptance

A language $L$ is **Turing-reducible** to $A$ if there exists an oracle Turing machine $M^A$ such that
$$
L = L(M^A).
$$

This reducibility is denoted
$$
L \le_T A.
$$

Oracle Turing machines define relative computability, isolating the contribution of a specific decision problem to computational power.

### Relativized Complexity Classes

Given a complexity class $\mathcal{C}$, its relativization with respect to an oracle $A$ is defined as
$$
\mathcal{C}^A = { L \mid \exists M^A \text{ deciding } L \text{ within the resource bounds of } \mathcal{C} }.
$$

Examples include:

* $\mathrm{P}^A$
* $\mathrm{NP}^A$
* $\mathrm{PSPACE}^A$

Oracle access allows defining **relative complexity separations** independent of unrelativized open problems.

### Polynomial-Time Oracles

For polynomial-time oracle machines, oracle queries are assumed to have unit cost. A language $L$ is in $\mathrm{P}^A$ if there exists a polynomial-time oracle Turing machine deciding $L$.

Oracle Turing machines formalize many-one and Turing reductions within complexity theory.

### Turing Reductions vs. Many-One Reductions

Oracle machines naturally characterize Turing reductions. For a many-one reduction $f : \Sigma^* \to \Sigma^*$,
$$
x \in L \iff f(x) \in A,
$$
only a single oracle query is needed.

Thus,
$$
L \le_m A \implies L \le_T A
$$
with strict containment in general.

### Oracle Hierarchies

The **polynomial hierarchy** can be defined inductively using oracle Turing machines:

$$
\Sigma_0^P = \Pi_0^P = \mathrm{P}
$$
$$
\Sigma_{k+1}^P = \mathrm{NP}^{\Sigma_k^P}
$$
$$
\Pi_{k+1}^P = \mathrm{coNP}^{\Sigma_k^P}
$$

Oracle access provides alternating layers of existential and universal nondeterminism.

### Relativization and Its Limits

Many classical complexity results relativize. For example:
$$
\mathrm{P}^A \subseteq \mathrm{NP}^A \subseteq \mathrm{PSPACE}^A
$$
for all oracles $A$.

However, there exist oracles $A$ and $B$ such that:
$$
\mathrm{P}^A = \mathrm{NP}^A
$$
$$
\mathrm{P}^B \neq \mathrm{NP}^B
$$

This demonstrates that oracle-based techniques cannot resolve $\mathrm{P}$ vs. $\mathrm{NP}$.

### Oracle Separation Theorems

Baker–Gill–Solovay showed the existence of oracles yielding contradictory relativized worlds. These constructions rely on diagonalization relativized to oracle access.

Such results motivate the search for non-relativizing techniques, such as circuit complexity and interactive proofs.

### Oracle Turing Degrees

Define an equivalence relation
$$
A \equiv_T B
$$
if $A \le_T B$ and $B \le_T A$.

Equivalence classes under $\le_T$ form **Turing degrees**, partially ordered by relative computability.

Oracle Turing machines provide the operational semantics of this lattice.

### Jump Operator

The **Turing jump** of a set $A$ is defined as
$$
A' = { \langle M, x \rangle \mid M^A \text{ halts on input } x }.
$$

$A'$ is strictly more powerful than $A$, yielding a strict hierarchy:
$$
A <_T A' <_T A'' <_T \cdots
$$

This hierarchy stratifies undecidable problems by relative unsolvability.

### Decidability and Completeness

A language $L$ is **$A$-decidable** if $L \le_T A$.

Completeness notions extend relativistically: $L$ is $\mathrm{NP}^A$-complete if
$$
L \in \mathrm{NP}^A
$$
and every language in $\mathrm{NP}^A$ reduces to $L$ via a polynomial-time oracle reduction.

### Oracle Machines and Computability Theory

In computability theory, oracle Turing machines define relative computability and underpin:

* Arithmetical hierarchy
* Hyperarithmetical sets
* Degrees of unsolvability

For example, the halting problem relative to $A$ is complete for $\Sigma_1^A$.

### Logical Characterization

Oracle computation corresponds to first-order arithmetic with an additional predicate symbol interpreting $A$.

Relativized classes correspond to syntactic restrictions on quantifier alternation with oracle predicates.

### Variants and Restrictions

Variants include:

* Bounded-query oracle machines
* Truth-table oracle machines
* Adaptive vs. non-adaptive oracle access

These define finer reducibility notions strictly weaker than full Turing reducibility.

### Limitations

Oracle Turing machines do not correspond to physically realizable computation models. They serve as idealized abstractions isolating relative computational power rather than absolute feasibility.

### Related Topics

* Turing reductions
* Many-one reductions
* Polynomial hierarchy
* Turing degrees
* Arithmetical hierarchy
* Relativization in complexity theory
* Interactive proofs

---

