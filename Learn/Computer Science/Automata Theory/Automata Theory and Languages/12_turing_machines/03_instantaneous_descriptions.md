## Instantaneous descriptions


### Formal notion

An instantaneous description is a finite syntactic encoding of the complete computational state of a machine model at a single computation step. For an automaton or grammar-based device, it determines the unique next-step behavior under the transition relation.

Given a device $M$, its set of instantaneous descriptions $\text{ID}(M)$ is equipped with a binary step relation $\vdash_M \subseteq \text{ID}(M)\times\text{ID}(M)$ induced by the transition function or production relation. The reflexive–transitive closure is denoted $\vdash_M^*$.

Acceptance for input $w$ is phrased as reachability of an accepting instantaneous description from the initial one.

### Finite automata

For a deterministic or nondeterministic finite automaton $M=\langle Q,\Sigma,\delta,q_0,F\rangle$:
$$\text{ID}(M)=Q\times\Sigma^*$$
An instantaneous description is written $q,w$ with current state $q$ and unread input $w$.

Transition relation:
$$q,aw ;\vdash_M; q',w \quad\text{iff}\quad q'\in \delta(q,a)$$
Acceptance:
$$w\in L(M);\Longleftrightarrow; q_0,w \vdash_M^* q_f,\lambda \text{ for some } q_f\in F$$

For $\epsilon$-moves, add $q,w\vdash_M q',w$ if $q'\in\delta(q,\lambda)$.

Language membership is graph reachability over a finite configuration graph.

### Pushdown automata

For a PDA $M=\langle Q,\Sigma,\Gamma,\delta,q_0,Z_0,F\rangle$:
$$\text{ID}(M)=Q\times\Sigma^*\times\Gamma^*$$
Instantaneous description $q,w,\gamma$ specifies state $q$, unread input $w$, and stack contents $\gamma$ with leftmost symbol the top.

Transition relation:
$$q,aw,X\alpha ;\vdash_M; q',w,\beta\alpha$$
iff $(q',\beta)\in\delta(q,a,X)$, where $a\in\Sigma\cup{\lambda}$ and $X\in\Gamma$.

Acceptance by final state:
$$w\in L(M);\Longleftrightarrow; q_0,w,Z_0 \vdash_M^* q_f,\lambda,\alpha \text{ for some } q_f\in F,\alpha\in\Gamma^*$$
Acceptance by empty stack defined analogously. Equivalence of the acceptance conventions is proved by stack/state coding.

The set of instantaneous descriptions is infinite but regular-language encodings enable decidability of reachability properties associated with context-free languages.

### Turing machines

For a single-tape nondeterministic Turing machine
$$M=\langle Q,\Sigma,\Gamma,\delta,q_0,q_{\text{acc}},q_{\text{rej}}\rangle$$
an instantaneous description is a word over $\Gamma^* Q \Gamma^*$ representing the tape content with a single state symbol marking the head position.

Write instantaneous descriptions as
$$u,q,a,v$$
with $u,v\in\Gamma^*$, $a\in\Gamma$, where the head scans $a$ in state $q$.

Transition relation:
$$u,q,a,v \vdash_M u,b,q',v \quad\text{if } (q',b,S)\in\delta(q,a)$$
$$u,q,a,v \vdash_M u,b,x,q',v \quad\text{if } (q',b,R)\in\delta(q,a), v=xv'$$
$$u,q,a,v \vdash_M u',q',y,b,v \quad\text{if } (q',b,L)\in\delta(q,a), u=u'y$$
where $L,R,S$ are head motions. Boundary conditions are handled by a distinguished blank symbol $\sqcup$ extending the tape content to $\Gamma^\omega$ but finitely represented by trimming trailing blanks.

Acceptance:
$$w\in L(M);\Longleftrightarrow; q_0,w \vdash_M^* \text{ an ID containing } q_{\text{acc}}$$

Instantaneous descriptions encode configurations; configuration graphs for TM are infinite and of degree bounded by $|\delta|$.

### Linear bounded automata

Instantaneous descriptions for LBAs are as above with the additional invariant that the represented tape segment is bounded by linear functions of $|w|$ and head movement constrained to that segment. Linear-space invariants are properties over IDs, enabling reductions to context-sensitive grammars.

### Complexity and configuration graphs

For machine $M$ operating within resource bound $b(n)$ on inputs of length $n$:

* number of distinct instantaneous descriptions is at most exponential in $b(n)$
* acceptance becomes reachability in the configuration graph $(\text{ID}(M),\vdash_M)$
* space-bounded classes are characterized by reachability over bounded-ID graphs

Savitch’s theorem:
$$\text{NSPACE}(s(n)) \subseteq \text{DSPACE}(s(n)^2)$$
is proved by recursive reachability over instantaneous descriptions.

PSPACE-completeness of QBF is shown by polynomial-space simulation via ID graphs.

### Encodings and reductions

Encodings of instantaneous descriptions as strings over finite alphabets allow:

* many-one reductions between decision problems by mapping $M$ and $w$ to $\langle M,w\rangle$ encoded IDs
* proofs of undecidability via configuration encodings and simulation (e.g., Post correspondence via TM IDs)
* mapping derivations in grammars to IDs for automata models

### Derivations and IDs

For grammars, sentential forms act as instantaneous descriptions of derivations.

For a context-free grammar $G$:

* instantaneous descriptions are sentential forms in $(V\cup\Sigma)^*$
* derivation relation $\Rightarrow$ acts as $\vdash_G$
* leftmost and rightmost derivations correspond to deterministic rewriting strategies over IDs

Parse trees correspond to traces in the ID derivation graph.

### Decidability via IDs

Key decision results expressed on instantaneous descriptions:

* DFA equivalence via bisimulation on finite ID graphs
* PDA emptiness via graph reachability on pushdown systems using saturation
* TM halting problem as reachability of halting IDs, undecidable
* LBA membership decidable via bounded-ID space search

Model checking on pushdown systems uses regular sets of IDs and pre∗ closures.

### Well-formedness invariants

Instantaneous descriptions satisfy machine-specific invariants:

* exactly one control state marker occurs
* head position uniqueness for TMs
* stack discipline encoded by $\Gamma^*$ form for PDAs
* boundary markers for LBAs delimiting accessible segment

Proofs about correctness of simulations maintain invariants across $\vdash_M$.

### Logical characterizations

IDs support descriptive complexity interpretations:

* configurations as structures with successor relations
* $\text{FO}$ or $\text{MSO}$ properties interpreted over configuration graphs
* reachability definability corresponds to transitive closure operators

### Related topics

* configuration graphs
* derivation trees
* transition systems
* structural equivalence of automata
* model checking over pushdown systems

---

