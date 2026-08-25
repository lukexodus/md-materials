## Complexity Classes: EXPTIME


### Formal Definition

The class $\mathrm{EXPTIME}$ is defined as  
$$  
\mathrm{EXPTIME} = \bigcup_{k \in \mathbb{N}} \mathrm{DTIME},2^{n^k}  
$$  
where $\mathrm{DTIME},f$ denotes the class of languages decidable by a deterministic Turing machine in time $O f n$.

Equivalently, $L \in \mathrm{EXPTIME}$ if there exists a deterministic Turing machine $M$ and a polynomial $p$ such that for all $w \in \Sigma^*$, $M$ decides membership of $w$ in $L$ within time $2^{p |w|}$.

### Machine and Model Robustness

The definition of $\mathrm{EXPTIME}$ is invariant under standard changes of computational model, including:
- single-tape versus multi-tape deterministic Turing machines
- reasonable RAM models
- register machines with logarithmic cost measure
    

Polynomial slowdowns between models are absorbed into the exponent.

### Hierarchy Placement

$$  
\mathrm{P} \subsetneq \mathrm{PSPACE} \subseteq \mathrm{EXPTIME} \subsetneq \mathrm{EXPSPACE}  
$$

The strict containment $\mathrm{PSPACE} \subsetneq \mathrm{EXPTIME}$ follows from the deterministic time hierarchy theorem:  
$$  
\mathrm{DTIME},n^k \subsetneq \mathrm{DTIME},2^n  
$$

The containment $\mathrm{PSPACE} \subseteq \mathrm{EXPTIME}$ follows from the fact that a machine using polynomial space has at most exponentially many configurations, yielding an exponential-time deterministic simulation.

### Deterministic Time Hierarchy

For time-constructible functions $f$ and $g$ satisfying  
$$  
f n \log f n = o g n  
$$  
there exists a language in $\mathrm{DTIME},g$ not in $\mathrm{DTIME},f$.

Taking $f n = n^k$ and $g n = 2^n$ yields separation of polynomial time from exponential time and establishes non-collapse of $\mathrm{EXPTIME}$ to lower deterministic time classes.

### Closure Properties

$\mathrm{EXPTIME}$ is closed under:  
$$  
\cup, \cap, \complement, \setminus  
$$  
$$  
\text{concatenation, Kleene star, homomorphism, inverse homomorphism}  
$$

Closure under complement follows from determinism.

$\mathrm{EXPTIME}$ is also closed under polynomial-time many-one reductions.

### Complete Problems

A language $L$ is **$\mathrm{EXPTIME}$-complete** if:  
$$  
L \in \mathrm{EXPTIME} \land \forall A \in \mathrm{EXPTIME},; A \le_m^p L  
$$

Canonical $\mathrm{EXPTIME}$-complete problems include:  
$$  
\mathrm{QBF}_{\mathrm{alt}} \text{ with polynomial alternation depth}  
$$  
$$  
\text{Generalized chess on an } n \times n \text{ board}  
$$  
$$  
\text{Acceptance of alternating polynomial-space Turing machines}  
$$  
$$  
\text{Model checking of CTL and fixed-point logics}  
$$

Completeness proofs typically use reductions encoding exponential-length computations via succinct representations.

### Alternation Characterization

Using alternating Turing machines:  
$$  
\mathrm{EXPTIME} = \mathrm{APSPACE}  
$$

Proof relies on the equivalence:  
$$  
\mathrm{ATIME},f = \mathrm{DSPACE},f  
$$  
for time-constructible $f$.

Thus, exponential time corresponds to polynomial space under alternation.

### Logical Characterizations

$\mathrm{EXPTIME}$ corresponds to descriptive complexity classes:  
$$  
\mathrm{EXPTIME} = \mathrm{FO} + \mathrm{LFP}  
$$  
on ordered structures, where $\mathrm{LFP}$ denotes least fixed-point logic.

Fixed-point depth corresponds to exponential unfolding in the worst case.

### Automata-Theoretic Characterizations

$\mathrm{EXPTIME}$ arises naturally in automata over infinite objects:
- Emptiness of alternating parity tree automata
- Satisfiability of propositional dynamic logic
- Decision procedures for $\mu$-calculus
    

The exponential blowup originates from subset and powerset constructions combined with fixpoint iteration.

### Relationship to Space Complexity

For any language $L \in \mathrm{PSPACE}$, deterministic simulation yields:  
$$  
L \in \mathrm{DTIME},2^{p n}  
$$  
for some polynomial $p$.

Conversely, $\mathrm{EXPTIME}$ strictly exceeds $\mathrm{PSPACE}$ by time hierarchy arguments, independent of space considerations.

### Reductions and Hardness Techniques

Typical $\mathrm{EXPTIME}$ hardness proofs involve:
- succinct encodings of exponential objects
- simulation of alternating polynomial-space machines
- reduction from infinite-duration games with polynomial descriptions
    

Reductions are polynomial-time and preserve exponential computation implicitly.

### Implications for Verification and Synthesis

Many verification problems for systems with recursion, concurrency, or fixed-point semantics are $\mathrm{EXPTIME}$-complete:
- CTL model checking
- equivalence of recursive state machines
- reachability in pushdown games
    

These bounds are tight under standard complexity assumptions.

### Related Topics

- Deterministic time hierarchy theorem
- Alternating Turing machines
- EXPSPACE
- Fixed-point logics
- CTL and $\mu$-calculus
- Succinct representations
- Infinite games and automata

---

