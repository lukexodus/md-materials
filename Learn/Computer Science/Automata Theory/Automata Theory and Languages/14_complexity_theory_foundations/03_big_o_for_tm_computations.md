## Big-O for TM computations


### Time and space measures

Let $M$ be a single-tape or multitape Turing machine with input alphabet $\Sigma$ and work alphabet $\Gamma$. For an input $w \in \Sigma^*$, let $T_M w$ denote the number of transition steps executed before halting, and let $S_M w$ denote the number of distinct tape cells visited. Define worst-case time and space complexity functions  
$$  
T_M n = \max { T_M w \mid |w| = n }, \quad  
S_M n = \max { S_M w \mid |w| = n }.  
$$  
Big-O bounds classify asymptotic growth: $T_M n \in O f n$ and $S_M n \in O g n$.

### Machine-model invariance

For reasonable encodings, time and space complexity are invariant up to polynomial factors across standard TM variants. For any $k$-tape TM $M_k$ with time $T_k n$, there exists a single-tape TM $M_1$ such that  
$$  
T_1 n \in O T_k n^2.  
$$  
Conversely, multitape simulation incurs at most constant-factor overhead in space and linear-factor overhead in time. Deterministic and nondeterministic variants preserve time bounds under standard simulations with polynomial overhead.

### Deterministic time classes

Define  
$$  
\mathbf{DTIME} f n = { L \subseteq \Sigma^* \mid \exists \text{ TM } M \text{ s.t. } T_M n \in O f n \text{ and } L = L M }.  
$$  
Canonical classes include:  
$$  
\mathbf{P} = \bigcup_{k \in \mathbb{N}} \mathbf{DTIME} n^k, \quad  
\mathbf{EXPTIME} = \bigcup_{k \in \mathbb{N}} \mathbf{DTIME} 2^{n^k}.  
$$  
Time-constructibility of $f$ ensures robustness of $\mathbf{DTIME} f n$ under diagonalization and padding.

### Nondeterministic time classes

For nondeterministic TMs, define $T_M w$ as the maximum length of any computation branch. Let  
$$  
\mathbf{NTIME} f n = { L \mid \exists \text{ NTM } M \text{ s.t. } T_M n \in O f n }.  
$$  
The class  
$$  
\mathbf{NP} = \bigcup_{k \in \mathbb{N}} \mathbf{NTIME} n^k  
$$  
is invariant under polynomial-time reductions. Deterministic simulation of nondeterminism yields  
$$  
\mathbf{NTIME} f n \subseteq \mathbf{DTIME} 2^{O f n}.  
$$

### Space complexity and Big-O

Space-bounded classes are defined analogously:  
$$  
\mathbf{DSPACE} g n = { L \mid \exists M \text{ s.t. } S_M n \in O g n }.  
$$  
Key classes include  
$$  
\mathbf{L} = \mathbf{DSPACE} \log n, \quad  
\mathbf{PSPACE} = \bigcup_{k \in \mathbb{N}} \mathbf{DSPACE} n^k.  
$$  
Space bounds are more robust than time bounds: by Savitch’s theorem,  
$$  
\mathbf{NSPACE} g n \subseteq \mathbf{DSPACE} g n^2 \quad \text{for } g n \ge \log n.  
$$

### Time–space tradeoffs

For single-tape TMs, strong lower bounds relate time and space. If $S_M n \in o n$, then $T_M n \in \Omega n^2$ for nonregular languages. Crossing sequence arguments establish quadratic lower bounds for single-tape recognition of certain regular and context-free languages.

### Hierarchy theorems

Big-O bounds enable strict separations. For time-constructible $f$,  
$$  
\mathbf{DTIME} f n \subsetneq \mathbf{DTIME} f n \log f n.  
$$  
Similarly, for space-constructible $g$,  
$$  
\mathbf{DSPACE} g n \subsetneq \mathbf{DSPACE} o g n.  
$$  
These results rely on diagonalization over time- or space-bounded TMs and are sensitive to Big-O definitions.

### Completeness under Big-O bounds

Many decision problems are complete for time classes under polynomial-time many-one reductions. If $L$ is $\mathbf{NP}$-complete, then $L \in \mathbf{NTIME} n^k$ for some $k$ and for all $L' \in \mathbf{NP}$,  
$$  
L' \le_m^p L.  
$$  
Completeness is invariant under Big-O rescaling within polynomial factors.

### Universal simulation overhead

Let $U$ be a universal TM simulating any $M$ with description length $| \langle M \rangle |$. If $M$ runs in time $T n$, then  
$$  
T_U n \in O T n \log T n  
$$  
for standard encodings, accounting for instruction decoding and bookkeeping. This bound underpins the polynomial slowdown thesis.

### Lower bounds and incompressibility

Kolmogorov complexity arguments yield time lower bounds: for any TM $M$ deciding a language with incompressible inputs, $T_M n \in \Omega n$. Stronger lower bounds depend on machine restrictions and tape structure; unconditional superlinear lower bounds are known primarily for restricted models.

### Logical characterization

By descriptive complexity, time classes correspond to logics over finite structures. For example,  
$$  
\mathbf{P} = \text{FO} + \text{LFP},  
$$  
where evaluation time corresponds to polynomial-time TM computation under Big-O bounds.

### Related topics

Time-constructible functions  
Space-constructible functions  
Crossing sequences  
Savitch’s theorem  
Descriptive complexity  
Universal Turing machines  
Time hierarchy theorem

---

