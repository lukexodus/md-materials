## Complexity classes: NP


### Formal characterization via nondeterminism

$\mathrm{NP}$ is the class of decision problems $L \subseteq \Sigma^*$ for which there exists a nondeterministic Turing machine $M$ and a polynomial $p$ such that for all $x \in \Sigma^*$:

$$  
x \in L \iff \exists \text{ accepting computation path of } M \text{ on } x \text{ of length } \le p |x|  
$$

Time is measured along the longest branch. Acceptance is existential over branches.

Analogy: a nondeterministic machine behaves like an omniscient guesser that explores all possible guesses in parallel and succeeds if at least one guess leads to acceptance within a polynomial budget.

### Verifier-based definition

Equivalently, $L \in \mathrm{NP}$ iff there exists a deterministic polynomial-time Turing machine $V$ and a polynomial $p$ such that

$$  
x \in L \iff \exists y \in \Sigma^* \text{ with } |y| \le p(|x|) \text{ and } V(x \# y) = 1  
$$

Here $y$ is a certificate or witness. This definition emphasizes verification rather than search.

The equivalence between nondeterministic acceptance and polynomial-time verification follows by encoding accepting computation paths as certificates.

### Relationship to function classes

Associated with $\mathrm{NP}$ is the function class $\mathrm{FNP}$ consisting of multivalued search problems whose solutions can be verified in polynomial time.

For $L \in \mathrm{NP}$, define the witness relation

$$  
R_L = \{ \langle x , y \rangle \mid V(x \# y) = 1 \}  
$$

Then $R_L$ is polynomially balanced and polynomial-time decidable.

### Closure properties

$\mathrm{NP}$ is closed under:
- union
- intersection
- concatenation under polynomial padding
- homomorphism and inverse homomorphism
- polynomial-time many-one reductions
    

$\mathrm{NP}$ is not known to be closed under complement. Closure under complement is equivalent to $\mathrm{NP} = \mathrm{coNP}$.

### Reductions and completeness

A language $A$ is polynomial-time many-one reducible to $B$, written $A \le_m^p B$, if there exists a polynomial-time computable function $f$ such that

$$  
x \in A \iff f x \in B  
$$

A language $B$ is $\mathrm{NP}$-complete if:
- $B \in \mathrm{NP}$
- for all $A \in \mathrm{NP}$, $A \le_m^p B$
    

$\mathrm{NP}$-complete languages represent the maximal difficulty within $\mathrm{NP}$ under efficient reductions.

Analogy: reductions are adapters that transform any puzzle in $\mathrm{NP}$ into a standardized hard puzzle without increasing effort beyond polynomial overhead.

### Canonical NP-complete problems

**SAT**

Given a Boolean formula $\varphi$, determine whether there exists an assignment satisfying $\varphi$.

Cook–Levin theorem establishes:

$$  
\mathrm{SAT} \text{ is } \mathrm{NP}\text{-complete}  
$$

The proof encodes polynomial-time bounded nondeterministic computations as Boolean formulas using tableau constructions.

**3SAT**

Restriction of $\mathrm{SAT}$ to conjunctive normal form with exactly three literals per clause. $\mathrm{3SAT}$ remains $\mathrm{NP}$-complete via polynomial-time reductions.

**CLIQUE**

Given a graph $G$ and integer $k$, determine whether $G$ contains a clique of size at least $k$.

**VERTEX-COVER**, **HAMILTONIAN-PATH**, **SUBSET-SUM** are all $\mathrm{NP}$-complete under standard reductions.

### Structural properties

$\mathrm{P} \subseteq \mathrm{NP} \subseteq \mathrm{PSPACE}$

All containments are known, all strictness questions remain open except $\mathrm{P} \ne \mathrm{EXPTIME}$.

$\mathrm{NP}$ admits complete problems under extremely weak reductions, including first-order projections.

### Descriptive complexity

$\mathrm{NP}$ coincides with existential second-order logic over finite structures:

$$  
\mathrm{NP} = \mathrm{ESO}  
$$

A language is in $\mathrm{NP}$ iff it is definable by a formula of the form

$$  
\exists R_1 \ldots \exists R_k , \varphi  
$$

where $\varphi$ is first-order. This connects $\mathrm{NP}$ to logic and finite model theory.

Analogy: certificates correspond to existentially quantified relations guessed by the logic before checking a local condition.

### Circuit characterization

$\mathrm{NP}$ corresponds to polynomial-size Boolean circuits with existentially quantified inputs, yielding the class $\mathrm{NP}/\mathrm{poly}$ under advice.

Uniform $\mathrm{NP}$ does not collapse to nonuniform $\mathrm{P}/\mathrm{poly}$ unless unlikely circuit lower bounds fail.

### Hierarchy and relativization

Under relativization, there exist oracles $A$ and $B$ such that:

$$  
\mathrm{P}^A = \mathrm{NP}^A \quad \text{and} \quad \mathrm{P}^B \ne \mathrm{NP}^B  
$$

Thus any proof resolving $\mathrm{P}$ versus $\mathrm{NP}$ must be nonrelativizing.

$\mathrm{NP}$ is the first level of the polynomial hierarchy:

$$  
\mathrm{PH} = \bigcup_{k \ge 0} \Sigma_k^p  
$$

with $\Sigma_1^p = \mathrm{NP}$.

### Limitations and open problems

The central open problem is:

$$  
\mathrm{P} \stackrel{?}{=} \mathrm{NP}  
$$

Equivalently, whether every polynomially verifiable problem is polynomially decidable.

No superpolynomial lower bounds are known for general $\mathrm{NP}$ problems in standard computation models.

### Connections to verification and synthesis

$\mathrm{NP}$ captures bounded existential verification. Many specification satisfaction problems reduce to $\mathrm{NP}$ when witnesses encode finite models or executions of bounded length.

Model checking with existential path quantification over polynomially bounded structures is $\mathrm{NP}$-complete.

### Related topics

$\mathrm{coNP}$  
Polynomial hierarchy  
Cook–Levin theorem  
$\mathrm{FNP}$  
$\mathrm{NP}$-completeness  
Descriptive complexity  
Circuit complexity

---

