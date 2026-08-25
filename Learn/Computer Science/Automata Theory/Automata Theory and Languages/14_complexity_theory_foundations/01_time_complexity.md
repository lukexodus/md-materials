## Time complexity


### Machine models and time measures

For a deterministic single-tape Turing machine $M$, the time complexity function is

$$  
T_M : \mathbb{N} \to \mathbb{N}, \quad  
T_M n = \max_{x \in \Sigma^n} \text{number of steps of } M \text{ on input } x  
$$

For a language $L \subseteq \Sigma^*$,

$$  
\text{TIME} f n = { L \mid \exists M \text{ deterministic TM such that } L = L M \land T_M n = O f n }  
$$

For nondeterministic Turing machines,

$$  
\text{NTIME} f n = { L \mid \exists M \text{ NTM such that } x \in L \iff \exists \text{ accepting branch of } M \text{ on } x \text{ of length } O f |x| }  
$$

Acceptance is existential over computation paths. Time is measured as the maximum length of the shortest accepting branch.

Multi-tape, multi-head, and random-access Turing machines define equivalent time classes up to polynomial factors.

---

### Time-constructible functions

A function $f : \mathbb{N} \to \mathbb{N}$ is time-constructible if there exists a TM that on input $1^n$ halts in exactly $f n$ steps.

All standard bounds including $n$, $n \log n$, $n^k$, $2^n$, and $n^n$ are time-constructible.

Time-constructibility is required for diagonalization and hierarchy theorems.

---

### Deterministic time hierarchy

For time-constructible functions $f, g$ such that

$$  
f n \log f n = o g n  
$$

the strict inclusion holds:

$$  
\text{TIME} f n \subsetneq \text{TIME} g n  
$$

Proof uses diagonalization with padding and universal simulation bounded by $O f n \log f n$.

Corollary: there exists a strict infinite hierarchy

$$  
\text{TIME} n \subsetneq \text{TIME} n^2 \subsetneq \text{TIME} n^3 \subsetneq \cdots  
$$

---

### Nondeterministic time hierarchy

For time-constructible $f, g$ with

$$  
f n = o g n  
$$

the inclusion

$$  
\text{NTIME} f n \subsetneq \text{NTIME} g n  
$$

holds.

The proof relies on nondeterministic diagonalization without the logarithmic overhead required in the deterministic case.

---

### Polynomial time

The class

$$  
\text{P} = \bigcup_{k \in \mathbb{N}} \text{TIME} n^k  
$$

is invariant under reasonable machine models and encodings.

Key properties:
- Closed under union, intersection, complement
- Closed under homomorphism and inverse homomorphism
- Closed under polynomial-time many-one reductions
    

Polynomial-time computable relations define feasible verification predicates.

---

### Nondeterministic polynomial time

Defined as

$$  
\text{NP} = \bigcup_{k \in \mathbb{N}} \text{NTIME} n^k  
$$

Equivalent verifier-based characterization:

$$  
L \in \text{NP} \iff \exists R \in \text{P}, \exists p \in \mathbb{N}[x], \forall x :  
x \in L \iff \exists y \in \Sigma^{\le p |x|} : R x y  
$$

Relationship:

$$  
\text{P} \subseteq \text{NP} \subseteq \text{EXPTIME}  
$$

Whether $\text{P} = \text{NP}$ remains unresolved.

---

### Exponential time

Defined as

$$  
\text{EXPTIME} = \bigcup_{k \in \mathbb{N}} \text{TIME} 2^{n^k}  
$$

Properties:
- Strictly contains $\text{P}$ by the deterministic time hierarchy
- Closed under complement
- Corresponds to problems solvable by exhaustive state-space exploration
    

Complete problems include generalized games and alternating Turing machine reachability.

---

### Alternation and time

Alternating Turing machines define time classes:

$$  
\text{ATIME} f n  
$$

Key equivalence:

$$  
\text{AP} = \text{PSPACE}  
$$

More generally,

$$  
\text{ATIME} f n = \text{DSPACE} f n  
$$

for $f n \ge n$.

This connects time-bounded alternation with space complexity.

---

### Time complexity and automata

- Deterministic finite automata decide regular languages in time $O n$
- Two-way deterministic finite automata simulate one-way automata in linear time
- Deterministic pushdown automata run in $O n$ time
- General context-free parsing has worst-case time $O n^3$
- Linear-time parsing exists for deterministic subclasses
    

Regular and context-free language membership problems lie in $\text{P}$.

---

### Simulation and speedup

Linear speedup theorem:

For any $c > 0$,

$$  
\text{TIME} f n = \text{TIME} c f n  
$$

provided $f n \ge n$.

Polynomial slowdown occurs when simulating multi-tape machines on single-tape machines:

$$  
\text{TIME}_{1\text{-tape}} n^k \supseteq \text{TIME}_{k\text{-tape}} n^{k-1}  
$$

---

### Padding and completeness

Padding transforms languages:

$$  
L \mapsto \{ x \#^{p(|x|)} \mid x \in L \}  
$$

Used to amplify time bounds and construct complete problems for $\text{TIME} f n$ under linear-time reductions.

---

### Reductions respecting time bounds

Many-one reduction:

$$  
L \le_m^p L' \iff \exists f \in \text{FP} : x \in L \iff f x \in L'  
$$

Turing reductions allow adaptive oracle queries within polynomial time.

Completeness under these reductions characterizes canonical problems within $\text{P}$, $\text{NP}$, and $\text{EXPTIME}$.

---

### Descriptive complexity connections

Logical characterizations:

$$  
\text{P} = \text{FO} + \text{LFP}  
$$

$$  
\text{NP} = \text{ESO}  
$$

Time complexity classes correspond to expressiveness of fixed-point and second-order logics.

---

### Related topics

- Space complexity
- Circuit complexity
- Alternating Turing machines
- Descriptive complexity
- Fine-grained complexity
- Time-space tradeoffs

---

