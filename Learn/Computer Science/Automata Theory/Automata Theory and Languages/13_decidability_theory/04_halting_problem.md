## Halting Problem


### Formal Statement and Model

Let $\Sigma$ be a finite alphabet and let $\langle M \rangle \in \Sigma^*$ denote a standard effective encoding of a deterministic single-tape Turing machine $M$. Define the language

$$  
\mathrm{HALT} = { \langle M, w \rangle \in \Sigma^* \mid M \text{ halts on input } w }  
$$

where $w \in \Sigma^*$ is an arbitrary input string.

The decision problem is to determine, given $\langle M, w \rangle$, whether $M$ eventually enters a halting configuration.

### Computability Classification

- $\mathrm{HALT}$ is **recursively enumerable** $\Sigma_1^0$
- $\mathrm{HALT}$ is **not recursive**
- $\overline{\mathrm{HALT}}$ is **not recursively enumerable**
    

Formally:

$$  
\mathrm{HALT} \in \mathrm{RE} \setminus \mathrm{R}  
$$

### Proof of Undecidability

Assume there exists a decider $H$ such that

$$  
H \langle M, w \rangle =  
\begin{cases}  
1 & \text{if } M \text{ halts on } w \  
0 & \text{otherwise}  
\end{cases}  
$$

Construct a Turing machine $D$ defined as follows:

On input $\langle M \rangle$:
1. Run $H$ on $\langle M, \langle M \rangle \rangle$
2. If $H$ accepts, loop forever
3. If $H$ rejects, halt
    

Consider $D$ on input $\langle D \rangle$:
- If $D$ halts on $\langle D \rangle$, then $H$ must have rejected, implying $D$ does not halt
- If $D$ does not halt on $\langle D \rangle$, then $H$ must have accepted, implying $D$ halts
    

Contradiction. Therefore, $H$ does not exist.

### Diagonalization Perspective

Define the partial characteristic function

$$  
\chi_{\mathrm{HALT}} \langle M, w \rangle =  
\begin{cases}  
1 & \text{if } M \text{ halts on } w \  
\uparrow & \text{otherwise}  
\end{cases}  
$$

The diagonal language

$$  
L_d = { \langle M \rangle \mid M \text{ does not halt on } \langle M \rangle }  
$$

is not computable. $\mathrm{HALT}$ encodes the complement of $L_d$ under a computable pairing function.

### Many-One Completeness

$\mathrm{HALT}$ is $\mathrm{RE}$-complete under computable many-one reductions.

For any $L \in \mathrm{RE}$, there exists a total computable function $f$ such that

$$  
x \in L \iff f x \in \mathrm{HALT}  
$$

Construction: simulate the enumerator for $L$ and halt iff $x$ is enumerated.

### Relationship to the Universal Machine

Let $U$ be a universal Turing machine. Then

$$  
\mathrm{HALT} = { \langle M, w \rangle \mid U \text{ halts on } \langle M, w \rangle }  
$$

Undecidability is invariant under choice of universal model, encoding, or tape convention.

### Rice-Type Generalization

The Halting Problem is a special case of nontrivial semantic properties of partial computable functions.

For any nontrivial property $P$ of partial functions,

$$  
{ \langle M \rangle \mid \varphi_M \in P }  
$$

is undecidable.

The halting behavior on a fixed input is a semantic property.

### Semi-Decidability

There exists a recognizer $R$ such that:
- If $\langle M, w \rangle \in \mathrm{HALT}$, $R$ halts and accepts
- If $\langle M, w \rangle \notin \mathrm{HALT}$, $R$ diverges
    

$R$ simulates $M$ on $w$ step-by-step.

No recognizer exists for $\overline{\mathrm{HALT}}$.

### Time-Bounded Variants

Define the bounded halting language

$$  
\mathrm{HALT}_{\le t} = { \langle M, w, 1^t \rangle \mid M \text{ halts on } w \text{ within } t \text{ steps} }  
$$

$\mathrm{HALT}_{\le t}$ is decidable and complete for $\mathrm{NTIME} t$ under log-space reductions.

Unbounded halting is the limit case $t \to \infty$.

### Arithmetical Hierarchy Placement

Using Kleene’s $T$-predicate:

$$  
\langle M, w \rangle \in \mathrm{HALT}  
\iff \exists t ; T \langle M, w, t \rangle  
$$

Thus

$$  
\mathrm{HALT} \in \Sigma_1^0  
$$

and

$$  
\overline{\mathrm{HALT}} \in \Pi_1^0 \setminus \Sigma_1^0  
$$

### Logical Characterization

Under first-order arithmetic:

$$  
\mathrm{HALT} = { x \mid \exists t ; \mathrm{Exec} x t }  
$$

where $\mathrm{Exec}$ is primitive recursive.

$\mathrm{HALT}$ is definable by an existential arithmetic formula but not by a universal one.

### Implications for Program Analysis

- No sound and complete termination checker exists
- Total correctness verification is undecidable
- Reachability in general transition systems is undecidable
- Equivalence of Turing-complete programs is undecidable

### Related Topics

- Rice’s Theorem
- Universal Turing Machines
- Entscheidungsproblem
- Arithmetical Hierarchy
- Post Correspondence Problem
- Totality Problem
- Busy Beaver Function
- Program Equivalence
- Model Checking Boundaries

---

