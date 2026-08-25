## Complexity Class $\mathbf{P}$


### Formal Definition

The class $\mathbf{P}$ consists of all languages decidable by a deterministic Turing machine in polynomial time. Formally,

$$  
\mathbf{P} = { L \subseteq \Sigma^* \mid \exists k \in \mathbb{N} ; \exists M ; \forall w \in \Sigma^* ; M \text{ decides } w \text{ in time } O |w|^k }  
$$

Equivalently, $\mathbf{P}$ is the class of languages decidable by uniform families of Boolean circuits of polynomial size and logarithmic depth under appropriate uniformity constraints.

---

### Machine Models and Robustness

The definition of $\mathbf{P}$ is invariant under standard deterministic computation models:

$$  
\mathbf{P} = \mathbf{P}_{\text{single-tape}} = \mathbf{P}_{\text{multi-tape}} = \mathbf{P}_{\text{RAM}}  
$$

by polynomial simulation theorems. Changes in tape number, alphabet size, or transition representation affect runtime by at most a polynomial factor.

---

### Closure Properties

$\mathbf{P}$ is closed under the following operations:
- union and intersection
- complement
- concatenation
- Kleene star
- inverse homomorphism
- polynomial-time many-one reductions
- polynomial-time Turing reductions
    

Formally, if $L_1, L_2 \in \mathbf{P}$, then

$$  
L_1 \cup L_2 \in \mathbf{P}, \quad L_1 \cap L_2 \in \mathbf{P}, \quad \overline{L_1} \in \mathbf{P}  
$$

---

### Reductions and Completeness

Polynomial-time many-one reductions are defined by total computable functions $f$ satisfying

$$  
w \in L_1 \iff f w \in L_2  
$$

with $f$ computable in polynomial time.

A language $L$ is $\mathbf{P}$-complete under log-space reductions if

$$  
L \in \mathbf{P} \quad \text{and} \quad \forall L' \in \mathbf{P}, ; L' \leq_L L  
$$

Canonical $\mathbf{P}$-complete problems include:
- Circuit Value Problem
- Monotone Circuit Value Problem
- Horn satisfiability

---

### Structural Properties

$\mathbf{P}$ admits a **time hierarchy**:

$$  
\mathbf{P} = \bigcup_{k \in \mathbb{N}} \mathbf{DTIME} n^k  
$$

By the deterministic time hierarchy theorem, there exist strict inclusions

$$  
\mathbf{DTIME} n^k \subsetneq \mathbf{DTIME} n^{k+1}  
$$

assuming time-constructibility.

---

### Relation to Other Classes

Key inclusions include:

$$  
\mathbf{L} \subseteq \mathbf{NL} \subseteq \mathbf{P} \subseteq \mathbf{NP} \subseteq \mathbf{PSPACE} \subseteq \mathbf{EXPTIME}  
$$

All inclusions are known to be strict except possibly $\mathbf{P} = \mathbf{NP}$.

---

### Logical Characterizations

By descriptive complexity theory,

$$  
\mathbf{P} = \mathrm{FO} + \mathrm{LFP}  
$$

where $\mathrm{FO}$ denotes first-order logic and $\mathrm{LFP}$ denotes least fixed-point operators over finite structures.

This characterization is robust under variations of fixed-point semantics.

---

### Circuit Complexity Characterization

$\mathbf{P}$ corresponds to families of Boolean circuits of polynomial size and polylogarithmic depth under uniformity:

$$  
\mathbf{P} = \mathbf{P}\text{-uniform } \mathbf{NC}  
$$

and more generally to polynomial-size circuits with uniformity constraints.

---

### Completeness and Incompleteness Phenomena

Not all problems in $\mathbf{P}$ are efficiently parallelizable. There exist problems in $\mathbf{P}$ that are $\mathbf{P}$-complete under log-space reductions and thus unlikely to be in $\mathbf{NC}$.

---

### Relationship to Verification and Automata

Languages in $\mathbf{P}$ arise as:
- reachability in finite graphs
- model checking of fixed-point logics
- emptiness and equivalence of deterministic finite automata
- membership for context-free grammars under deterministic parsing

---

### Lower Bounds and Open Problems

No superpolynomial lower bound is known for any explicit language in $\mathbf{P}$ under standard models. The separation

$$  
\mathbf{P} \stackrel{?}{=} \mathbf{NP}  
$$

remains unresolved.

---

### Related Topics

- $\mathbf{L}$ and $\mathbf{NL}$
- $\mathbf{NP}$ and $\mathbf{coNP}$
- $\mathbf{PSPACE}$
- Circuit complexity
- Descriptive complexity
- Parallel complexity $\mathbf{NC}$
- Time hierarchy theorem

---

