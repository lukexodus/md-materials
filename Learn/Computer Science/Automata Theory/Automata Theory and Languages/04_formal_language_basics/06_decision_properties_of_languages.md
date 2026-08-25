## Decision Properties of Languages


### Decision Problems as Languages

A decision problem is identified with a language $L \subseteq \Sigma^*$ via its characteristic function $\chi_L : \Sigma^* \to {0,1}$. Decidability properties are invariant under computable bijections on $\Sigma^*$ and under many-one reductions.

A language $L$ is **decidable** if there exists a Turing machine $M$ such that for all $w \in \Sigma^*$, $M$ halts and accepts $w$ iff $w \in L$.
A language $L$ is **recognizable** if there exists $M$ such that $M$ accepts exactly the strings in $L$, possibly diverging on $w \notin L$.

Fundamental inclusions:
$$
\mathrm{REG} \subsetneq \mathrm{DCFL} \subsetneq \mathrm{CFL} \subsetneq \mathrm{DEC} \subsetneq \mathrm{RE}
$$

---

### Decision Properties for Regular Languages

Let $L$ be given by a DFA $A$.

Decidable properties:

* Emptiness: $L = \varnothing$
* Finiteness and infiniteness
* Membership: $w \in L$
* Equivalence: $L A_1 = L A_2$
* Inclusion: $L_1 \subseteq L_2$
* Universality: $L = \Sigma^*$

All are decidable via graph reachability, product constructions, and complement closure.

Time bounds: All decision procedures are solvable in polynomial time in $|A|$.

Algebraic structure:

* Boolean algebra under union, intersection, complement
* Effective closure under homomorphism and inverse homomorphism

---

### Decision Properties for Context-Free Languages

Let $L$ be given by a CFG $G$ or PDA $P$.

Decidable properties:

* Membership $w \in L$ using CYK or Earley parsing
* Emptiness
* Finiteness

Undecidable properties:

* Equivalence of two CFGs
* Inclusion $L_1 \subseteq L_2$
* Universality $L = \Sigma^*$
* Ambiguity of CFGs
* Determinism equivalence

Membership complexity:
$$
\mathrm{MEMB}_{\mathrm{CFL}} \in \mathcal O n^3
$$
with lower bounds under general grammars.

Closure limitations:

* Closed under union, concatenation, Kleene star
* Not closed under complement or intersection

Undecidability often shown via reductions from Post correspondence problem.

---

### Decision Properties for Deterministic Context-Free Languages

Let $L \in \mathrm{DCFL}$.

Decidable:

* Membership
* Emptiness
* Complement

Undecidable:

* Equivalence
* Inclusion

Structural observation:
$$
\mathrm{DCFL} \subsetneq \mathrm{CFL}
$$
with strictly stronger closure properties but limited expressive power.

---

### Decision Properties for Recursively Enumerable Languages

Let $L \in \mathrm{RE}$.

Decidable:

* Membership semi-decision
* Emptiness is undecidable
* Finiteness is undecidable

Key undecidable problems:

* Universality
* Equivalence
* Inclusion
* Complementation

Canonical undecidable language:
$$
A_{\mathrm{TM}} = { \langle M, w \rangle \mid M \text{ accepts } w }
$$

Complement relation:
$$
L \in \mathrm{DEC} \iff L \in \mathrm{RE} \land \overline L \in \mathrm{RE}
$$

---

### Rice-Type Decision Properties

Let $\mathcal P$ be a semantic property of Turing-recognizable languages.

If $\mathcal P$ is non-trivial, then the language
$$
{ \langle M \rangle \mid L M \in \mathcal P }
$$
is undecidable.

Consequences:

* Emptiness of TM languages is undecidable
* Finiteness of TM languages is undecidable
* Regularity of TM languages is undecidable

Proof method: many-one reduction from $A_{\mathrm{TM}}$.

---

### Reductions and Completeness

Decision problems are classified by reducibility.

Let $A \le_m B$ denote many-one reducibility.

Completeness:

* $A_{\mathrm{TM}}$ is $\mathrm{RE}$-complete
* $\overline{A_{\mathrm{TM}}}$ is $\mathrm{coRE}$-complete
* PCP is $\mathrm{RE}$-complete

Preservation:
$$
A \le_m B \land B \in \mathrm{DEC} \implies A \in \mathrm{DEC}
$$

---

### Logical Characterizations

Decision properties correspond to logical definability.

* Regular languages correspond to $\mathrm{MSO}$ over strings
* Decidability aligns with effective model checking
* Undecidability arises from second-order or unrestricted quantification

Expressiveness correlation:
$$
\text{More expressive logic} \Rightarrow \text{weaker decision properties}
$$

---

### Complexity-Theoretic Aspects

Decision procedures induce complexity classes.

Examples:

* $\mathrm{REG}$ membership in $\mathcal O n$
* $\mathrm{CFL}$ membership in $\mathcal O n^3$
* TM acceptance is $\mathrm{RE}$-complete

Hierarchy implications:

* Time and space bounds restrict decidability
* Decidable languages form a strict subset of $\mathrm{RE}$

---

### Related Topics

* Many-one reductions
* Rice’s theorem
* Post correspondence problem
* Language equivalence
* Closure properties
* Complexity hierarchies

---

