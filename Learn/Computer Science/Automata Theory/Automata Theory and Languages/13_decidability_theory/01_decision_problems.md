## Decision problems


### Formal characterization

A decision problem is identified with a language $L \subseteq \Sigma^*$ via its characteristic function $\chi_L : \Sigma^* \to {0,1}$. Algorithms, automata, or deduction systems for the problem correspond to effective realizations of $\chi_L$. The study focuses on representation of $L$ within language hierarchies and on structural properties of the induced class of characteristic functions.

A decision problem is **decidable** if $L$ is recursive $\subseteq$ $\mathcal{R}$, **semidecidable** if $L$ is recursively enumerable $\subseteq$ $\mathcal{RE}$, and **co-semidecidable** if $\Sigma^* \setminus L$ is recursively enumerable. The trichotomy  
$$  
\mathcal{R} \subsetneq \mathcal{RE} \cap co\text{-}\mathcal{RE} \subsetneq \mathcal{RE}  
$$  
is fundamental for separation arguments.

### Reductions and completeness

Given decision problems $A,B \subseteq \Sigma^*$, a mapping reduction is a computable function $f : \Sigma^* \to \Sigma^*$ such that  
$$  
x \in A \iff f(x) \in B.  
$$  
Write $A \le_m B$. Closure of decidability under $\le_m$ and the monotonicity of undecidability yield completeness notions.

For a class $\mathcal{C}$, a language $L$ is $\mathcal{C}$-complete if $L \in \mathcal{C}$ and for every $A \in \mathcal{C}$, $A \le_m L$. Central examples:
- $\text{HALT}$ is $\mathcal{RE}$-complete
- $\text{K}_0$ and related index sets are $\mathcal{RE}$-complete
- $\text{VALID}_{\text{QBF}}$ is PSPACE-complete under polynomial-time many-one reductions

### Automata-theoretic decision problems

Representative problems parameterized by automaton models:
- **Finite automata**
    - emptiness, universality, language inclusion, equivalence
    - state minimization and distinguishability
    - star-height, aperiodicity, syntactic monoid properties
- **Pushdown automata**
    - emptiness decidable
    - equivalence undecidable for general PDA, decidable for deterministic PDA
    - inclusion problems with mixed decidability boundaries
- **Turing machines**
    - acceptance, halting, totality, equivalence, boundedness properties
        

Each problem is treated as a language over encodings of machines and inputs. Encoding choices do not affect decidability status up to polynomial-time computable isomorphism.

### Classical undecidable decision problems

Key undecidable problems and typical proof schemas:
- Halting problem $HALT = { \langle M,x \rangle : M \text{ halts on } x }$
- Acceptance problem $A_{TM} = { \langle M,x \rangle : x \in L(M) }$
- Emptiness of TM language
- Equivalence of Turing machines
- Post correspondence problem $PCP$
- Validity of first-order logic over arithmetic
    

Diagonalization, fixed-point constructions, and simulation arguments yield reductions among these problems. Rice’s theorem asserts that every nontrivial semantic property of recursively enumerable languages is undecidable:  
$$  
\forall \text{ nontrivial } P, \quad { \langle M \rangle : L(M) \text{ satisfies } P } \text{ is undecidable.}  
$$

### Decidable decision problems by model restriction

- DFA emptiness, universality, inclusion, equivalence all decidable via graph reachability or product construction
- CFG emptiness and membership decidable; universality undecidable
- Deterministic PDA equivalence decidable via deterministic context-free language structure
- Presburger arithmetic validity decidable via automata and semilinear sets

### Logical characterization

Decision problems correspond to satisfiability and validity in logical systems:
- Regular languages correspond to monadic second-order logic over $\langle \Sigma^*,< \rangle$
- Star-free languages correspond to first-order logic with $<$ and to aperiodic monoids
- Decidability of MSO over words versus undecidability over $\langle \mathbb{N}^2,< \rangle$ connects structure theory and automata
    

Completeness results are often transferred by descriptive complexity:
- FO = AC$^0$
- ESO = NP
- MSO over trees = regular tree languages
    

Thus decision problems about structures reduce to model-checking problems in these logics.

### Complexity-theoretic decision problems

Decision problems are mapped to complexity classes through resource-bounded Turing machines. Central classes:  
$$  
\text{P} \subseteq \text{NP} \subseteq \text{PSPACE} \subseteq \text{EXPTIME}.  
$$  
Decision versions of optimization or search tasks are used to define completeness (e.g., SAT ∈ NP-complete). Hierarchy theorems guarantee strictness of DTIME and DSPACE towers.

Time and space constructibility conditions are assumed when applying diagonalization. Padding arguments relate classes and enable completeness transfer between time scales.

### Closure properties of decision problem classes

- $\mathcal{R}$ closed under complement, union, intersection
- $\mathcal{RE}$ closed under union and intersection but not complement
- $co\text{-}\mathcal{RE}$ symmetric results
- For complexity classes, closure under complement distinguishes P from NL and coNL via Immerman–Szelepcsényi
    

Algebraic closure behavior directly influences reduction strategies and separations.

### Decision procedures via normal forms and transformations

- DFA minimization and Myhill–Nerode equivalence decide regular language equivalence
- Chomsky and Greibach normal forms facilitate CFG decision procedures for membership and emptiness
- Parikh images and semilinearity decide properties of commutative abstractions of CFLs
- Büchi–Elgot–Trakhtenbrot correspondence gives MSO decision procedures via automata construction

### Hardness via pumping and pumping-like arguments

- Non-regularity via Myhill–Nerode or pumping lemma for regular languages
- Non-context-freeness via CFL pumping lemma or Ogden’s lemma  
    These yield negative decision results for membership within smaller hierarchies.
    

### Hierarchical placement of decision problems

Decision problems are located in the Chomsky hierarchy and arithmetical hierarchy:
- $\Sigma_1^0 = \mathcal{RE}$
- $\Pi_1^0 = co\text{-}\mathcal{RE}$
- Higher $\Sigma_n^0, \Pi_n^0$ via alternations of bounded quantifiers over $\mathbb{N}$
    

Quantifier alternation in logical formulations directly controls the degree of undecidability.

### Verification-oriented decision problems

- Model checking for temporal logics: LTL PSPACE-complete, CTL EXPTIME-complete
- Automata-theoretic model checking reduces to language emptiness for $\omega$-automata
- Satisfiability for various logics mapped to automata emptiness or tree automata nonemptiness

### Related topics

Turing degrees  
Arithmetical hierarchy  
Analytical hierarchy  
Index sets  
Rice–Shapiro theorem  
Myhill–Nerode relation  
Descriptive complexity  
Post correspondence problem  
Recursive functionals

---

