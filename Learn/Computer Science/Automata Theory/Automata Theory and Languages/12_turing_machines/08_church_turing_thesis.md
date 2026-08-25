## Church–Turing thesis


### Statement and scope

The Church–Turing thesis asserts that every effectively calculable function on natural numbers is computable by a Turing machine. Formally, for any partial function $f : \mathbb{N} \to \mathbb{N}$ that is intuitively computable by a finite, mechanical procedure, there exists a Turing machine $M$ such that $M$ computes $f$. The thesis is not a theorem within mathematics; it is a foundational identification between an informal notion of effective calculability and precise formal models.

### Equivalent formal characterizations

The thesis is supported by the convergence of multiple independently defined models of computation that define the same class of partial functions:
- Turing-computable partial functions
- Partial recursive functions defined via initial functions, composition, primitive recursion, and minimization
- $\lambda$-definable functions in untyped $\lambda$-calculus
- Functions computable by Post canonical systems
- Functions computable by register machines and RAM models with unbounded registers
    

For each model $M_i$, the class of computable functions coincides with the class $\mathcal{R}$ of partial recursive functions:  
$$  
\mathcal{F}_{\text{TM}} = \mathcal{F}_{\lambda} = \mathcal{F}_{\text{PR}} = \mathcal{F}_{\text{Post}} = \mathcal{R}.  
$$

### Formal implications for language theory

Let $L \subseteq \Sigma^*$ be a language. A language is decidable if and only if its characteristic function $\chi_L : \Sigma^* \to {0,1}$ is total recursive. A language is recursively enumerable if and only if it is accepted by some Turing machine. Under the thesis, these definitions capture exactly the class of algorithmically decidable and semi-decidable problems.

### Decidability and undecidability consequences

Assuming the thesis, negative results for Turing machines imply absolute impossibility results for all effective procedures. In particular:
- The halting problem $H = { \langle M,w \rangle \mid M \text{ halts on } w }$ is undecidable.
- No effective procedure decides first-order validity over arithmetic.
- No algorithm decides equivalence of arbitrary Turing machines.
    

These results are invariant under choice of computational model due to the equivalence guaranteed by the thesis.

### Reductions and completeness

Many undecidable problems are shown undecidable via computable many-one reductions. If $A \le_m B$ and $A$ is not decidable, then $B$ is not decidable. Under the Church–Turing thesis, the reduction itself represents an effective transformation, preserving the interpretation of undecidability as algorithmic impossibility.

### Extended and strengthened theses

Several strengthened forms refine the original claim:
- The physical Church–Turing thesis states that any function computable by a physically realizable device is Turing-computable.
- The complexity-theoretic Church–Turing thesis asserts that any reasonable computation model can be simulated by a Turing machine with at most polynomial overhead.
    

The latter underlies the robustness of complexity classes such as $\mathbf{P}$, $\mathbf{NP}$, $\mathbf{PSPACE}$, and $\mathbf{EXPTIME}$.

### Hypercomputation and limitations

Models that appear to exceed Turing power include oracle machines, infinite time Turing machines, real-number computation over exact reals, and analog models with infinite precision. These models violate implicit effectiveness constraints such as finiteness of description, bounded precision, or discrete time evolution. The thesis excludes such models by restricting attention to finitely specifiable, mechanically realizable procedures.

### Logical and proof-theoretic connections

The thesis underlies the identification of provability with computability in formal systems. Gödel numbering enables encoding of syntactic objects as natural numbers, making metamathematical questions computable in principle. The undecidability of validity and incompleteness phenomena rely on the assumption that formal proof systems correspond to effective procedures.

### Normal forms and universality

The existence of universal Turing machines formalizes the thesis at the machine level. There exists a single Turing machine $U$ such that for all machines $M$ and inputs $w$,  
$$  
U \langle M,w \rangle \simeq M w.  
$$  
Universality supports the claim that computational power is model-independent up to effective simulation.

### Relationship to verification and semantics

In program semantics, the thesis justifies modeling programs as partial recursive functions or as Turing machines. Semantic equivalence, termination, and reachability problems inherit undecidability results. Model checking and type systems operate within decidable fragments, whose boundaries are ultimately constrained by the thesis.

### Related topics

Partial recursive functions  
$\lambda$-calculus  
Universal Turing machines  
Halting problem  
Gödel incompleteness  
Computability vs. complexity  
Hypercomputation models

---

