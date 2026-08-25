## Reductions (Mapping & Turing)


### Formal Framework

Let $\Sigma$ be a finite alphabet. A _language_ is a subset of $\Sigma^*$. Decision problems are identified with languages via characteristic functions $\chi_L : \Sigma^* \to {0,1}$. Reductions formalize relative computational hardness and enable transfer of decidability, recognizability, and complexity properties between languages.

Let $\mathcal{C}$ be a class of languages closed under computable preimages. A reduction $\leq_\mathcal{R}$ is a preorder on languages satisfying reflexivity and transitivity.

---

### Mapping Reductions (Many-One Reductions)

#### Definition

A _mapping reduction_ from language $A \subseteq \Sigma^*$ to language $B \subseteq \Gamma^*$ is a total computable function $f : \Sigma^* \to \Gamma^*$ such that

$$  
x \in A \iff f x \in B  
$$

This is denoted $A \leq_m B$ or $A \leq_{m} B$.

If $f$ is required to be computable in time $O p n$ for some polynomial $p$, the reduction is a _polynomial-time many-one reduction_, denoted $A \leq_m^p B$.

---

#### Structural Properties

- $\leq_m$ is transitive and reflexive.
- If $A \leq_m B$ and $B$ is decidable, then $A$ is decidable.
- If $A \leq_m B$ and $B$ is recursively enumerable, then $A$ is recursively enumerable.
- If $A$ is undecidable and $A \leq_m B$, then $B$ is undecidable.

---

#### Completeness

A language $L$ is _$\mathcal{C}$-complete under mapping reductions_ if:
- $L \in \mathcal{C}$
- For all $A \in \mathcal{C}$, $A \leq_m L$
    

Canonical examples:
- $A_{TM}$ is recursively enumerable complete under $\leq_m$
- $HALT_{TM}$ is recursively enumerable complete
- $SAT$ is $\mathsf{NP}$-complete under $\leq_m^p$

---

#### Normal Form of Reductions

Given $A \leq_m B$ via $f$, membership can be decided by the composition:

$$  
\chi_A = \chi_B \circ f  
$$

Thus mapping reductions correspond to _functional preimages_ under computable transformations, inducing a homomorphic structure on decision problems.

---

#### Expressive Limitations

Mapping reductions preserve complement only if the target class is closed under complement. In particular:

$$  
A \leq_m B \nRightarrow \overline{A} \leq_m \overline{B}  
$$

unless $\mathcal{C}$ is closed under complement.

---

### Turing Reductions

#### Definition

A _Turing reduction_ from language $A$ to language $B$ is an oracle Turing machine $M^B$ such that:

$$  
x \in A \iff M^B \text{ accepts } x  
$$

Denoted $A \leq_T B$.

The machine may make finitely many adaptive oracle queries to $B$ during computation.

Polynomial-time bounded oracle access yields _polynomial-time Turing reductions_, denoted $A \leq_T^p B$.

---

#### Structural Properties

- $\leq_T$ is transitive and reflexive.
- $A \leq_m B \implies A \leq_T B$
- If $B$ is decidable and $A \leq_T B$, then $A$ is decidable.
- If $B$ is recursively enumerable and $A \leq_T B$, $A$ need not be recursively enumerable.

---

#### Oracle Computation Semantics

An oracle TM $M^B$ computes a partial function $f^B : \Sigma^* \to {0,1}$ where oracle queries are resolved in unit time. The reduction corresponds to _relative computability_:

$$  
A \in \mathsf{DEC}^B  
$$

where $\mathsf{DEC}^B$ denotes languages decidable with oracle $B$.

---

#### Degrees of Unsolvability

Turing reductions induce _Turing degrees_:

$$  
\deg_T A = { B \mid A \leq_T B \wedge B \leq_T A }  
$$

Properties:
- Mapping degrees refine Turing degrees
- There exist incomparable Turing degrees
- The degree of the halting problem is maximal among recursively enumerable degrees

---

### Comparison: Mapping vs Turing Reductions

|Property|Mapping|Turing|
|---|---|---|
|Queries|Single|Multiple, adaptive|
|Strength|Weaker|Stronger|
|Preserves r.e.|Yes|No|
|Induces degrees|Many-one degrees|Turing degrees|
|Used for completeness|Yes|Rarely|

Formally:

$$  
A \leq_m B \subsetneq A \leq_T B  
$$

---

### Reductions and Undecidability Proofs

Standard undecidability proofs use mapping reductions from $A_{TM}$ or $HALT_{TM}$:

Given $L$, construct computable $f$ such that:

$$  
\langle M, w \rangle \in A_{TM} \iff f \langle M, w \rangle \in L  
$$

This ensures undecidability of $L$ via closure under preimages.

Turing reductions are used to show _relative undecidability_:

$$  
A \leq_T B \wedge B \text{ undecidable } \nRightarrow A \text{ undecidable}  
$$

---

### Complexity-Theoretic Reductions

- $\mathsf{NP}$-completeness is defined via $\leq_m^p$
- $\mathsf{PSPACE}$-completeness often uses $\leq_T^p$
- $\mathsf{EXPTIME}$-completeness allows polynomial-time Turing reductions
    

Oracle-based complexity classes:

$$  
\mathsf{P}^A, \mathsf{NP}^A, \mathsf{PSPACE}^A  
$$

---

### Logical and Verification Connections

- Mapping reductions correspond to first-order interpretations
- Turing reductions correspond to second-order oracle access
- Reductions preserve definability in fixed-point logics under syntactic translation
- Program verification undecidability results rely on reductions from $A_{TM}$

---

### Related Topics

- Many-one degrees
- Truth-table reductions
- Weak truth-table reductions
- Polynomial-time reductions
- Oracle Turing machines
- Completeness and hardness
- Rice’s theorem
- Arithmetical hierarchy
- Polynomial hierarchy

---

