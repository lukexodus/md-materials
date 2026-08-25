## Space Complexity


### Formal Definition

Let $M$ be a deterministic Turing machine with input alphabet $\Sigma$ and tape alphabet $\Gamma$. For an input $x \in \Sigma^*$, define the **space usage** of $M$ on $x$ as  
$$  
\mathrm{space}_M(x) = \max {, |{ i \in \mathbb{Z} : t(i) \neq \sqcup }| \mid \text{over all configurations in the computation of } M \text{ on } x ,}.  
$$  
Equivalently, space may be measured as the number of distinct tape cells ever scanned or written during the computation.

For a function $s : \mathbb{N} \to \mathbb{N}$, a language $L \subseteq \Sigma^*$ is **decidable in space $s(n)$** if there exists a Turing machine $M$ such that for all $x \in \Sigma^*$:  
$$  
x \in L \iff M \text{ accepts } x, \quad \mathrm{space}_M(x) \leq s(|x|).  
$$

### Space Complexity Classes

Define the deterministic and nondeterministic space complexity classes:  
$$  
\mathsf{SPACE}(s(n)) = { L \mid L \text{ decidable by a deterministic TM using } O(s(n)) \text{ space} },  
$$  
$$  
\mathsf{NSPACE}(s(n)) = { L \mid L \text{ decidable by a nondeterministic TM using } O(s(n)) \text{ space} }.  
$$

Standard classes:  
$$  
\mathsf{L} = \mathsf{SPACE}(\log n), \quad  
\mathsf{NL} = \mathsf{NSPACE}(\log n),  
$$  
$$  
\mathsf{PSPACE} = \bigcup_{k \ge 1} \mathsf{SPACE}(n^k).  
$$

### Input Tape Conventions

Space complexity is typically measured **excluding** the read-only input tape. Formally, machines are assumed to have:
- A read-only input tape.
- One or more read-write work tapes.
    

This convention is without loss of generality, since any machine that overwrites its input can be transformed into one that copies the input to a work tape using $O(n)$ space.

### Multi-Tape and Multi-Track Invariance

Space complexity is invariant under standard machine variants.

For any $k$-tape Turing machine $M$ using space $s(n)$, there exists a single-tape Turing machine $M'$ such that  
$$  
\mathrm{space}_{M'}(n) = O(s(n)).  
$$

Similarly, multi-track machines satisfy  
$$  
\mathsf{SPACE}_{\text{multi-track}}(s(n)) = \mathsf{SPACE}(s(n)).  
$$

Unlike time complexity, no polynomial or logarithmic blowup arises when simulating multiple tapes or tracks in space-bounded computation.

### Configuration Graph Characterization

For a machine $M$ using space $s(n)$ on inputs of length $n$, the number of possible configurations is bounded by  
$$  
|Q| \cdot |\Gamma|^{O(s(n))} \cdot O(s(n)).  
$$

Thus, the configuration graph is finite and has size at most exponential in $s(n)$. This observation underlies many space-bounded decidability results.

### Savitch’s Theorem

For all space-constructible functions $s(n) \ge \log n$,  
$$  
\mathsf{NSPACE}(s(n)) \subseteq \mathsf{SPACE}(s(n)^2).  
$$

In particular,  
$$  
\mathsf{NL} \subseteq \mathsf{SPACE}(\log^2 n) \subseteq \mathsf{PSPACE}.  
$$

The proof relies on recursive reachability in the configuration graph using divide-and-conquer, storing only $O(s(n))$-bit configuration descriptions and a recursion depth of $O(\log |V|)$.

### Deterministic vs Nondeterministic Space

A fundamental open problem:  
$$  
\mathsf{L} \stackrel{?}{=} \mathsf{NL}.  
$$

In contrast to time complexity, nondeterminism is strictly weaker in space, as Savitch’s theorem shows only a quadratic overhead, not exponential.

### Space Hierarchy Theorem

For space-constructible functions $s_1(n)$ and $s_2(n)$ such that  
$$  
\lim_{n \to \infty} \frac{s_1(n)}{s_2(n)} = 0,  
$$  
there exists a language $L$ such that  
$$  
L \in \mathsf{SPACE}(s_2(n)) \setminus \mathsf{SPACE}(s_1(n)).  
$$

Consequences include:  
$$  
\mathsf{L} \subsetneq \mathsf{PSPACE}, \quad  
\mathsf{SPACE}(n) \subsetneq \mathsf{SPACE}(n^2).  
$$

### Relationship to Time Complexity

Space-bounded computation implies a time bound:  
$$  
\mathsf{SPACE}(s(n)) \subseteq \mathsf{TIME}(2^{O(s(n))}).  
$$

This follows from exhaustive exploration of the configuration graph. Conversely, no general nontrivial upper bound on space follows from time bounds alone.

### Completeness and Reductions

$\mathsf{PSPACE}$-complete languages are defined via polynomial-time many-one reductions.

Canonical $\mathsf{PSPACE}$-complete problems:
- $\mathsf{TQBF}$, the set of true fully quantified Boolean formulas.
- Acceptance of polynomial-space-bounded Turing machines.
- Generalized reachability in succinctly represented graphs.
    

Completeness proofs rely on encoding polynomial-space computations into logical or combinatorial structures of polynomial size.

### Closure Properties

For space-constructible $s(n) \ge \log n$:
- $\mathsf{SPACE}(s(n))$ is closed under union, intersection, and complement.
- $\mathsf{NSPACE}(s(n))$ is closed under union and intersection.
    

Closure under complement for nondeterministic space follows from:  
$$  
\mathsf{NSPACE}(s(n)) = \mathsf{coNSPACE}(s(n)).  
$$

### Space-Bounded Reductions

Logarithmic-space reductions are defined as functions computable in $\mathsf{L}$. They preserve membership in $\mathsf{L}$, $\mathsf{NL}$, and $\mathsf{PSPACE}$, forming the standard reduction notion for space-bounded completeness.

### Connections to Logic and Verification

- $\mathsf{PSPACE}$ corresponds to polynomially bounded alternating computation.
- $\mathsf{PSPACE}$ captures the expressive power of quantified Boolean logic.
- Space complexity aligns with model checking for temporal logics such as $\mathsf{CTL}^*$.
- Logarithmic space corresponds to first-order logic with deterministic transitive closure under suitable encodings.

### Related Topics

- Time complexity
- Configuration graphs
- Alternating Turing machines
- Descriptive complexity
- Polynomial hierarchy
- Model checking
- Log-space reductions

---

