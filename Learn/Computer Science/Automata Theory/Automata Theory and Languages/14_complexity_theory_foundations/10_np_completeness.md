## NP-completeness


### Formal Setting

Let $\Sigma$ be a finite alphabet. Decision problems are identified with languages $L \subseteq \Sigma^*$. Time complexity is measured with respect to deterministic and nondeterministic Turing machines.

Define

$$  
\mathsf{P} = { L \mid \exists \text{ deterministic TM } M \text{ deciding } L \text{ in time } O p n \text{ for some polynomial } p }  
$$

$$  
\mathsf{NP} = { L \mid \exists \text{ nondeterministic TM } M \text{ deciding } L \text{ in time } O p n }  
$$

Equivalently, $L \in \mathsf{NP}$ iff there exists a polynomial-time computable relation $R \subseteq \Sigma^* \times \Sigma^*$ and polynomial $p$ such that

$$  
x \in L \iff \exists y \in \Sigma^* \text{ with } |y| \leq p |x| \wedge R x y  
$$

---

### Polynomial-Time Mapping Reductions

A language $A$ is _polynomial-time many-one reducible_ to $B$, denoted $A \leq_m^p B$, if there exists a polynomial-time computable function $f$ such that

$$  
x \in A \iff f x \in B  
$$

Properties:
- $\leq_m^p$ is transitive and reflexive
- $\mathsf{P}$ is closed under $\leq_m^p$
- If $A \leq_m^p B$ and $B \in \mathsf{P}$, then $A \in \mathsf{P}$

---

### NP-hardness

A language $L$ is _NP-hard_ if for all $A \in \mathsf{NP}$,

$$  
A \leq_m^p L  
$$

NP-hardness imposes no membership requirement on $L$. In particular, NP-hard languages may be undecidable.

---

### NP-completeness

A language $L$ is _NP-complete_ if:
- $L \in \mathsf{NP}$
- $L$ is NP-hard under $\leq_m^p$
    

Equivalently:

$$  
L \in \mathsf{NP} \wedge \forall A \in \mathsf{NP},; A \leq_m^p L  
$$

Consequences:

$$  
L \in \mathsf{P} \iff \mathsf{P} = \mathsf{NP}  
$$

for any NP-complete $L$.

---

### Canonical NP-complete Problems

#### Boolean Satisfiability

Define

$$  
SAT = { \varphi \mid \varphi \text{ is a satisfiable Boolean formula} }  
$$

Cook–Levin Theorem:

$$  
SAT \text{ is NP-complete}  
$$

Proof outline:
- $SAT \in \mathsf{NP}$ via polynomial-size certificates
- For any $L \in \mathsf{NP}$, encode accepting computations of a nondeterministic TM as Boolean formulas
- Enforce local consistency of configurations using polynomially many clauses

---

#### Restricted Normal Forms

- $3SAT \leq_m^p SAT$
- $SAT \leq_m^p 3SAT$
    

Thus:

$$  
3SAT \text{ is NP-complete}  
$$

Normal form constraints preserve NP-completeness under polynomial reductions.

---

### Reduction Methodology

To prove $L$ NP-complete:
1. Show $L \in \mathsf{NP}$ via polynomial-time verification
2. Choose known NP-complete $A$
3. Construct $f$ computable in polynomial time such that:
    

$$  
x \in A \iff f x \in L  
$$

Reductions preserve _yes-instances_ exactly.

---

### Closure Properties

- NP-complete languages are closed under polynomial-time isomorphism
- If $L$ is NP-complete and $L \leq_m^p L' \leq_m^p L$, then $L'$ is NP-complete
- NP-complete languages are not closed under complement unless $\mathsf{NP} = \mathsf{coNP}$

---

### Structural Consequences

If $L$ is NP-complete:
- $L \notin \mathsf{P}$ unless $\mathsf{P} = \mathsf{NP}$
- $L$ is not sparse unless $\mathsf{P} = \mathsf{NP}$
- $L$ has no polynomial-time algorithm with subpolynomial nondeterminism unless hierarchy collapses

---

### Completeness Under Other Reductions

- Turing reductions yield $\mathsf{NP}$-hardness but not standard completeness
- Truth-table reductions define intermediate completeness notions
- Log-space reductions define $\mathsf{NL}$- and $\mathsf{P}$-complete analogues

---

### Relationship to Logic

- $\mathsf{NP}$ corresponds to existential second-order logic
- NP-complete problems correspond to complete problems under first-order interpretations with successor
- Descriptive complexity provides reduction-free characterizations of NP-completeness

---

### Verification and Automata Connections

- Model checking with existential path quantification reduces from $SAT$
- Constraint satisfaction problems capture large subclasses of NP-complete problems
- Intersection emptiness of polynomially bounded automata families is NP-complete

---

### Hierarchy and Separation Results

- If any NP-complete language lies in $\mathsf{coNP}$, then $\mathsf{NP} = \mathsf{coNP}$
- If NP-complete languages are immune, then $\mathsf{P} \neq \mathsf{NP}$
- Ladner’s theorem implies existence of intermediate languages assuming $\mathsf{P} \neq \mathsf{NP}$

---

### Related Topics

- Cook–Levin theorem
- Polynomial hierarchy
- Ladner’s theorem
- coNP-completeness
- Log-space reductions
- Descriptive complexity
- Constraint satisfaction problems
- PSPACE-completeness

---

