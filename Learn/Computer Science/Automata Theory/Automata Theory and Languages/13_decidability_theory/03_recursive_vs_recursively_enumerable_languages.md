## Recursive vs Recursively Enumerable Languages


### Formal Definitions

A language $L \subseteq \Sigma^*$ is **recursive** if there exists a Turing machine $M$ such that for every input $w \in \Sigma^*$, $M$ halts and accepts if $w \in L$, and halts and rejects if $w \notin L$. Equivalently, the characteristic function $\chi_L : \Sigma^* \to {0,1}$ is total and computable.

A language $L \subseteq \Sigma^*$ is **recursively enumerable** if there exists a Turing machine $M$ such that for every $w \in \Sigma^*$, $M$ accepts if $w \in L$, and either rejects or diverges if $w \notin L$. Equivalently, $L$ is the domain or range of a partial computable function.

The classes are denoted:  
$$  
\mathrm{REC} \subsetneq \mathrm{RE}  
$$

### Machine Characterizations

Recursive languages correspond to **deciders**, i.e. halting Turing machines.

Recursively enumerable languages correspond to **recognizers**, i.e. semi-decision procedures.

Equivalent characterizations of $\mathrm{RE}$:  
$$  
L \in \mathrm{RE} \iff L = { w \mid \exists t ; M \text{ accepts } w \text{ within } t \text{ steps} }  
$$  
$$  
L \in \mathrm{RE} \iff L = \mathrm{dom} , \varphi_e \text{ for some partial computable } \varphi_e  
$$  
$$  
L \in \mathrm{RE} \iff L \text{ is enumerable by a Turing machine}  
$$

Equivalent characterizations of $\mathrm{REC}$:  
$$  
L \in \mathrm{REC} \iff L \in \mathrm{RE} \land \overline{L} \in \mathrm{RE}  
$$

### Hierarchy Placement

$$  
\mathrm{REG} \subsetneq \mathrm{CFL} \subsetneq \mathrm{CSL} \subsetneq \mathrm{REC} \subsetneq \mathrm{RE}  
$$

Where $\mathrm{CSL}$ denotes context-sensitive languages.

Every recursive language is decidable within unbounded time and space. Every recursively enumerable language is semidecidable but not necessarily decidable.

### Closure Properties

Closure properties of $\mathrm{REC}$:  
$$  
\text{closed under } \cup, \cap, \complement, \setminus, \cdot, {}^*, \text{ homomorphism, inverse homomorphism}  
$$

Closure properties of $\mathrm{RE}$:  
$$  
\text{closed under } \cup, \cap, \cdot, {}^*, \text{ homomorphism}  
$$  
$$  
\text{not closed under } \complement \text{ or } \setminus  
$$

Non-closure under complement follows from the existence of undecidable problems.

### Expressive Power and Separation

Strict containment $\mathrm{REC} \subsetneq \mathrm{RE}$ is established via the Halting Problem:  
$$  
\mathrm{HALT} = { \langle M,w \rangle \mid M \text{ halts on } w }  
$$  
$$  
\mathrm{HALT} \in \mathrm{RE} \land \mathrm{HALT} \notin \mathrm{REC}  
$$

Proof uses diagonalization and reduction from the Entscheidungsproblem.

### Decidability and Undecidability

For $L \in \mathrm{REC}$:
- Membership problem is decidable
- Emptiness, finiteness, equivalence are decidable relative to effective representations
    

For $L \in \mathrm{RE} \setminus \mathrm{REC}$:
- Membership is semidecidable
- Complement membership is not semidecidable
- Many meta-properties are undecidable
    

Rice's Theorem applies to all nontrivial semantic properties of $\mathrm{RE}$ languages:  
$$  
P \text{ nontrivial } \Rightarrow P \text{ undecidable}  
$$

### Reductions and Completeness

A language $L$ is **$\mathrm{RE}$-complete** if:  
$$  
L \in \mathrm{RE} \land \forall A \in \mathrm{RE}, ; A \le_m L  
$$

Examples:  
$$  
\mathrm{HALT}, ; \mathrm{PCP}, ; \mathrm{TM}_{\mathrm{ACCEPT}}  
$$

No recursive language can be $\mathrm{RE}$-complete under many-one reductions.

### Enumeration and Approximation

For $L \in \mathrm{RE}$, there exists a computable enumeration $e : \mathbb{N} \to \Sigma^*$ such that:  
$$  
L = { e(n) \mid n \in \mathbb{N} }  
$$

For $L \in \mathrm{REC}$, enumeration can be made injective and decidable membership can be recovered from the enumeration index.

Limit computability:  
$$  
L \in \mathrm{REC} \iff \chi_L \text{ is computable}  
$$  
$$  
L \in \mathrm{RE} \iff \chi_L \text{ is limit-computable}  
$$

### Logical Characterizations

Recursive languages correspond to arithmetical $\Delta_1$ sets.

Recursively enumerable languages correspond to arithmetical $\Sigma_1$ sets:  
$$  
w \in L \iff \exists x ; R(w,x)  
$$  
where $R$ is recursive.

### Complexity-Theoretic Perspective

$$  
\mathrm{REC} = \bigcup_{f \text{ total}} \mathrm{DTIME}(f)  
$$  
$$  
\mathrm{RE} = \bigcup_{f \text{ partial}} \mathrm{DTIME}(f)  
$$

Time bounds do not separate $\mathrm{REC}$ and $\mathrm{RE}$; halting behavior is the distinguishing factor.

### Relationships to Verification

Recursive languages correspond to decidable safety and liveness properties.

Recursively enumerable languages correspond to semidecidable verification problems such as reachability in infinite-state systems.

### Related Topics

- Arithmetical hierarchy
- Halting problem
- Rice's theorem
- Many-one and Turing reductions
- Partial recursive functions
- Limit computability
- Entscheidungsproblem
- $\Sigma_1$ and $\Delta_1$ definability

---

