## Complexity Classes: $\mathrm{PSPACE}$


### Formal Definition and Machine Models

$\mathrm{PSPACE}$ is the class of languages decidable by deterministic Turing machines using space polynomial in the input length. Formally:  
$$  
\mathrm{PSPACE} = { L \subseteq \Sigma^* \mid \exists k \in \mathbb{N}, \exists \text{TM } M \text{ such that } M \text{ decides } L \text{ using } O \langle n^k \rangle \text{ space} }  
$$  
where space counts the number of tape cells ever visited on the work tapes as a function of input length $n$.

Equivalent definitions hold using multi-tape machines, read-only input tapes, and write-only output tapes; all reasonable variants differ by at most polynomial factors in space.

---

### Nondeterminism and $\mathrm{NPSPACE}$

Define $\mathrm{NPSPACE}$ analogously using nondeterministic Turing machines. Savitch’s Theorem establishes:  
$$  
\mathrm{PSPACE} = \mathrm{NPSPACE}  
$$

Proof sketch: Given a nondeterministic machine $M$ using $s \langle n \rangle$ space, configurations have size $O \langle s \langle n \rangle \rangle$. Reachability between configurations can be decided by recursive divide-and-conquer in $O \langle s \langle n \rangle^2 \rangle$ space.

This collapse is specific to space-bounded complexity and has no known time analogue.

---

### Configuration Graphs and Space Bounds

For a space-$s \langle n \rangle$ Turing machine $M$, the configuration graph $G_{M,x}$ on input $x$ has:
- At most $2^{O \langle s \langle n \rangle \rangle}$ vertices
- Directed edges representing single transitions
    

Deciding acceptance reduces to reachability in $G_{M,x}$. Since depth-first search uses only polynomial space via pointer reuse, reachability in exponentially large graphs lies in $\mathrm{PSPACE}$.

---

### Completeness and Reductions

A language $L$ is $\mathrm{PSPACE}$-complete if:
- $L \in \mathrm{PSPACE}$
- For all $A \in \mathrm{PSPACE}$, $A \leq_m L$ under polynomial-time many-one reductions
    

Reductions are required to be computable in polynomial time, not polynomial space, to preserve robustness of the class.

---

### Canonical $\mathrm{PSPACE}$-Complete Problems

#### Quantified Boolean Formula

$\mathrm{QBF}$ is defined as:  
$$  
\mathrm{QBF} = { \varphi \mid \varphi = Q_1 x_1 , Q_2 x_2 \dots Q_n x_n , \psi \text{ is true} }  
$$  
where $Q_i \in { \forall, \exists }$ and $\psi$ is a propositional formula.

$\mathrm{QBF}$ is $\mathrm{PSPACE}$-complete under polynomial-time reductions.

Membership follows by recursive evaluation of quantifiers using depth-first recursion with linear space. Hardness follows from encoding polynomial-space Turing machine computations as alternating quantifiers.

---

#### TQBF as a Complete Fragment

The restriction $\mathrm{TQBF}$, where quantifiers alternate and $\psi$ is in CNF, remains $\mathrm{PSPACE}$-complete. This establishes completeness even under strong syntactic constraints.

---

### Hierarchy and Containment Relations

Known containments:  
$$  
\mathrm{P} \subseteq \mathrm{NP} \subseteq \mathrm{PSPACE} \subseteq \mathrm{EXPTIME}  
$$

Strictness is known for:  
$$  
\mathrm{PSPACE} \subsetneq \mathrm{EXPTIME}  
$$  
by the deterministic time hierarchy theorem and the simulation of time by space:  
$$  
\mathrm{TIME} \langle t \langle n \rangle \rangle \subseteq \mathrm{SPACE} \langle t \langle n \rangle \rangle  
$$  
for time-constructible $t \langle n \rangle$.

Strictness of $\P vs $\mathrm{PSPACE}$ and $\mathrm{NP}$ vs $\mathrm{PSPACE}$ remains open.

---

### Alternation and Logical Characterizations

Alternating Turing machines characterize $\mathrm{PSPACE}$:  
$$  
\mathrm{PSPACE} = \mathrm{AP}  
$$  
where $\mathrm{AP}$ denotes polynomial-time alternating machines.

Quantifier alternation corresponds to alternation depth in computation trees, explaining the $\mathrm{PSPACE}$-completeness of $\mathrm{QBF}$.

In descriptive complexity:  
$$  
\mathrm{PSPACE} = \mathrm{FO} \langle \mathrm{LFP} \rangle  
$$  
first-order logic with a least fixed-point operator, over finite ordered structures.

---

### Closure Properties

$\mathrm{PSPACE}$ is closed under:
- Complementation
- Union and intersection
- Concatenation and Kleene star
- Polynomial-time many-one reductions
- Logspace reductions
    

Closure under complement follows from $\mathrm{PSPACE} = \mathrm{NPSPACE}$ and closure of nondeterministic space under complement.

---

### Relationship to Automata and Formal Languages

- Membership for regular and context-free languages lies in $\mathrm{P}$.
- Membership for general context-sensitive languages is $\mathrm{PSPACE}$-complete.
- Emptiness for linear bounded automata is $\mathrm{PSPACE}$-complete.
    

For automata on infinite words:
- Emptiness of alternating Büchi automata is $\mathrm{PSPACE}$-complete.
- Model checking for linear temporal logic is $\mathrm{PSPACE}$-complete.

---

### Space-Bounded Reductions and Completeness Variants

Polynomial-space reductions collapse to polynomial-time reductions:  
$$  
\mathrm{PSPACE}\text{-hard under poly-space reductions} = \mathrm{PSPACE}\text{-hard under poly-time reductions}  
$$  
since reductions can be recomputed on demand using small space.

---

### Lower Bounds and Limitations

No nontrivial super-polynomial space lower bounds are known for natural problems in $\mathrm{PSPACE}$.

Diagonalization yields:  
$$  
\mathrm{SPACE} \langle s \langle n \rangle \rangle \subsetneq \mathrm{SPACE} \langle o \langle s \langle n \rangle \rangle \rangle  
$$  
for space-constructible $s \langle n \rangle$.

---

### Related Topics

- $\mathrm{NPSPACE}$
- $\mathrm{AP}$
- $\mathrm{QBF}$
- Alternating automata
- Linear bounded automata
- Descriptive complexity
- Space hierarchy theorem

---


