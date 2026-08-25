## Complexity classes: co-NP


### Formal definition

Let $\Sigma$ be a finite alphabet. A language $L \subseteq \Sigma^*$ belongs to $\text{coNP}$ if its complement $\overline{L} = \Sigma^* \setminus L$ belongs to $\text{NP}$. Equivalently, $L \in \text{coNP}$ if there exists a polynomial $p$ and a polynomial-time computable predicate $R$ such that  
$$  
x \in L \iff \forall y,\ |y| \le p(|x|)\ \neg R(x,y),  
$$  
or, dually, $\overline{L}$ has polynomially verifiable witnesses of membership. The characteristic functions of coNP languages are those decidable by nondeterministic polynomial-time Turing machines rejecting on all computation branches.

### Placement in hierarchies

Standard inclusions:  
$$  
\text{P} \subseteq \text{NP} \cap \text{coNP} \subseteq \text{NP} \cup \text{coNP} \subseteq \text{PSPACE}.  
$$  
No strictness is known among $\text{P},\text{NP},\text{coNP}$; however,  
$$  
\text{PH} = \bigcup_{k \ge 0} \Sigma_k^{\text{P}},\qquad  
\text{coNP} = \Pi_1^{\text{P}} = \text{co}\text{-}\Sigma_1^{\text{P}}.  
$$  
The polynomial hierarchy collapses to level one if $\text{NP}=\text{coNP}$:  
$$  
\text{NP}=\text{coNP} \Rightarrow \text{PH}=\text{NP}.  
$$

### Complementation and machine characterizations

A nondeterministic polynomial-time Turing machine $M$ recognizes $L \in \text{coNP}$ if for all $x$:
- $x \in L$ implies all computation branches of $M$ accept within polynomial time
- $x \notin L$ implies the existence of a rejecting branch
    

Thus $\text{coNP}$ corresponds to universal nondeterminism with polynomial time bounds. In alternating time,  
$$  
\text{coNP} = \text{ATIME}_{\exists,\forall}(n^{O(1)}) \text{ with one alternation starting universally}.  
$$

### Proof-system and certificate viewpoints

Languages in $\text{coNP}$ have _efficient refutations_: membership in $L$ is equivalent to the nonexistence of short NP-certificates for $\overline{L}$. Equivalently, $x\in L$ admits polynomial-size _disqualifying_ evidence for $\overline{L}$. If $\text{NP}\ne\text{coNP}$, then there exist languages with efficiently checkable positive certificates but no efficiently checkable negative certificates or vice versa.

Propositional proof complexity connects coNP to the existence of polynomially bounded proof systems for tautologies. Let $TAUT$ be the set of propositional tautologies. Then  
$$  
TAUT \in \text{coNP}, \qquad SAT = \overline{TAUT} \in \text{NP}.  
$$  
The existence of polynomially bounded propositional proof systems is equivalent to $\text{NP}=\text{coNP}$.

### Canonical complete problems

A language $L$ is coNP-complete if $L \in \text{coNP}$ and every language in coNP reduces to $L$ under polynomial-time many-one reductions. Representative coNP-complete problems:
- $UNSAT = { \varphi : \varphi \text{ a propositional formula and has no satisfying assignment} }$
- $TAUT = { \varphi : \varphi \text{ is valid in propositional logic} }$
- Complement of CLIQUE
- Complement of VERTEX-COVER decision version
- Validity of quantified Boolean formulas with one block of universal quantifiers: $\forall$-QBF with quantifier-free matrix
    

Reductions typically complement classical NP-complete reductions or use duality of Boolean operations.

### Closure properties

- closed under union, intersection
- closed under polynomial-time many-one reductions
- closed under complement if and only if $\text{coNP}=\text{NP}$
- closed under polynomial-time Turing reductions  
    Not closed under polynomial-time truth-table reductions unless $\text{PH}$ collapses at the first level.
    

### Separation consequences and collapse phenomena

- If $\text{NP}\subseteq\text{coNP}$ then $\text{NP}=\text{coNP}$
- If any NP-complete problem lies in coNP, then $\text{NP}=\text{coNP}$
- If $\text{coNP}\subseteq\text{NP/poly}$ then the polynomial hierarchy collapses to $\Sigma_2^{\text{P}}$
- $\text{coNP}\subseteq\text{AM}$ via interactive proofs, and $\text{coNP}\subseteq\text{IP}=\text{PSPACE}$

### Descriptive complexity

In descriptive complexity,  
$$  
\text{NP} = \text{ESO},  
\qquad  
\text{coNP} = \text{co}\text{-}\text{ESO},  
$$  
where ESO is existential second-order logic over finite structures. Hence coNP corresponds to the complement of ESO properties, equivalently, universal second-order sentences up to prenex transformations. The distinction between $\text{SO}\exists$ and $\text{SO}\forall$ reflects the NP/coNP duality.

### Algebraic and automata-theoretic connections

- For regular languages, membership in $\text{AC}^0$, $\text{NC}^1$, $\text{P}$, $\text{coNP}$ can be characterized via properties of syntactic monoids, circuit families, or logical definability
- Word problems for finite algebras can be coNP-complete under succinct encodings
- Model checking universal fragments of temporal or modal logics often yields coNP-completeness

### Relationships with formal verification

- Complement of SAT-based safety property checking is coNP-complete
- Validity of propositional Hoare triples under strongest postconditions corresponds to coNP
- Unsatisfiability cores provide coNP certificates for failed realizability or refinement

### Relations with other classes

- $\text{coNP}\subseteq \text{PSPACE}$, strictness unknown
- $\text{coNP}\subseteq \text{AM}\subseteq \text{IP}$
- $\text{BPP}$ is low for the polynomial hierarchy; whether $\text{coNP}\subseteq \text{BPP}$ is open
- $\text{NL}=\text{coNL}$ contrasts unknown $\text{NP}$ versus $\text{coNP}$

### Completeness via complementing reductions

If $L$ is NP-complete and $f$ is a polynomial-time computable complementing bijection on encodings, then $\overline{L}$ is coNP-complete. Many coNP-complete problems are obtained by complementing canonical NP-complete problems and verifying closure under the relevant reductions.

### Oracle and relativization behavior

Relativized worlds exist where  
$$  
\text{NP}^A \ne \text{coNP}^A,\qquad  
\text{NP}^B = \text{coNP}^B,  
$$  
showing equality cannot be resolved by relativizing proof techniques.

### Related topics

NP  
Polynomial hierarchy  
Σ₁ᵖ and Π₁ᵖ classes  
Propositional proof systems  
TAUT and UNSAT  
Descriptive complexity  
Alternating Turing machines  
Interactive proofs

---

