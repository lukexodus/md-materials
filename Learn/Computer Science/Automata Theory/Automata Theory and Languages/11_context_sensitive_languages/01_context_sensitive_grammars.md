## Context-sensitive grammars


### Formal definition

A context-sensitive grammar is a quadruple $G = \langle V,\Sigma,R,S\rangle$ with $V$ a finite set of variables, $\Sigma$ a finite terminal alphabet, $S\in V$, and $R$ a finite set of productions of the form
$$\alpha \to \beta$$
such that $\alpha,\beta \in (V\cup\Sigma)^+$ and
$$|\alpha| \le |\beta|$$
Every derivation is noncontracting. The empty word $\lambda$ is not generable unless $L(G)={\lambda}$, in which case $S\to \lambda$ is permitted and $S$ does not occur on any right-hand side.

The generated language is
$$L(G)={,w\in\Sigma^* \mid S \Rightarrow^* w,}$$

The class of context-sensitive languages is denoted $\text{CSL}$.

### Language-theoretic placement

$$\text{REG} \subsetneq \text{CFL} \subsetneq \text{CSL} \subseteq \text{RE}$$
and
$$\text{CSL} = \text{NSPACE}(n)$$

The strictness $\text{CFL} \subsetneq \text{CSL}$ follows from $L={a^n b^n c^n \mid n\ge 0} \in \text{CSL}\setminus \text{CFL}$.

### Noncontracting grammars and length-increasing derivations

Every context-sensitive grammar can be transformed into an equivalent noncontracting grammar where each rule satisfies
$$|\alpha| < |\beta|$$
except the possible special $\lambda$-rule for $S$. Derivations thus preserve or increase sentential form length monotonically; no derivation can loop without increasing length, ensuring polynomial space boundedness of derivations relative to $|w|$.

### Kuroda normal form

Every context-sensitive grammar $G$ with $L(G)\ne{\lambda}$ is equivalent to a grammar in Kuroda normal form whose rules are of the following shapes:
$$A \to BC$$
$$A \to B$$
$$A \to a$$
$$AB \to CD$$
with $A,B,C,D\in V$ and $a\in\Sigma$, subject to global noncontractingness. Equivalence proof proceeds by eliminating terminals from long right-hand sides, binarizing productions, and simulating length-increasing context rules by $AB\to CD$ productions.

### Equivalence to linear bounded automata

A linear bounded automaton is a nondeterministic Turing machine whose tape head is restricted to the portion of the tape containing the input bounded by linear space in input length. The fundamental equivalence:
$$\text{CSL}=\text{LBA}$$
More precisely:

* For every context-sensitive grammar there exists an LBA that accepts $L(G)$.
* For every LBA $M$ there exists a context-sensitive grammar $G$ such that $L(M)=L(G)$.

The first direction simulates monotone derivations within a tape bounded linearly by $|w|$. The second direction encodes LBA configurations as sentential forms with length preserved under valid transitions.

By the Immerman–Szelepcsényi theorem,
$$\text{NSPACE}(n)=\text{co-NSPACE}(n)$$
hence $\text{CSL}$ is closed under complement.

Equality with deterministic linear bounded automata is open:
$$\text{DSPACE}(n)\stackrel{?}{=}\text{NSPACE}(n)$$
equivalently, deterministic context-sensitive languages versus context-sensitive languages remains an open problem.

### Closure properties

Closed under:

* union
* intersection
* concatenation
* Kleene star
* complement
* inverse homomorphism
* $\lambda$-free homomorphism
* substitution by context-sensitive languages

Not closed under arbitrary homomorphism due to possible length-decreasing images that violate linear boundedness.

### Decision problems

For $\text{CSL}$:

* Membership problem: decidable and $\text{PSPACE}$-complete
* Emptiness: undecidable
* Finiteness: undecidable
* Universality: undecidable
* Inclusion and equivalence: undecidable

Membership $\text{PSPACE}$-completeness follows from LBA acceptance characterization and the Savitch–Cook bounds; simulation runs in polynomial space and completeness is by reductions from canonical $\text{PSPACE}$-complete problems.

### Structural properties

Length-monotonicity implies that any derivation for $w$ has length at most polynomially bounded in $|w|$, consistent with linear-space acceptance. Sentential forms can be encoded as bounded configurations of LBAs. Parse trees are not bounded in depth by $|w|$, but width expansion is length-monotone.

### Pumping and non-context-free proofs

No classical pumping lemma analogous to regular or context-free languages characterizes $\text{CSL}$. Useful tools include:

* interchange lemma for context-sensitive languages
* shrinking lemma variants for length-increasing grammars

Typical separations use:
$${a^n b^n c^n \mid n\ge 0}\in \text{CSL}\setminus\text{CFL}$$
and
$${ww \mid w\in{0,1}^*}\in \text{CSL}\setminus\text{CFL}$$

### Descriptive and complexity-theoretic correspondences

Via descriptive complexity,
$$\text{CSL}=\text{NSPACE}(n)$$
capturing problems definable in existential second-order logic with transitive closure under linear space resource bounds. Complement closure follows from inductive counting enabling space-bounded reachability complement acceptance.

### Normal-form transformations

Transformations preserving language:

* elimination of useless and inaccessible symbols under noncontracting constraints
* $AB\to CD$ simulation of context rules $\alpha A \beta \to \alpha \gamma \beta$
* binarization while preserving noncontractingness
* removal of $\lambda$-productions when $L\ne{\lambda}$

Each transformation preserves linear boundedness and noncontracting derivations.

### Expressive power comparisons

$$\text{CFL}\subsetneq\text{CSL}\subsetneq\text{RE}$$
Nonrecursive-enumerable languages are not generable by any grammar or automaton model. Some recursively enumerable but non–context-sensitive languages are produced via exponential workspace requirements exceeding linear bounds.

### Related models and classes

* linear bounded automata
* deterministic linear bounded automata
* indexed grammars
* ET0L systems
* mildly context-sensitive formalisms
* matrix grammars
* type-0 grammars
* recursively enumerable languages

---

