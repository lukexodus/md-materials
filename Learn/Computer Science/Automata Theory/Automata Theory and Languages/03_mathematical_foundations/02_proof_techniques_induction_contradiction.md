## Proof Techniques (Induction, Contradiction)


### Mathematical Induction in Language Theory

#### Induction on Word Length

Used to establish properties $P w$ for all strings $w \in \Sigma^*$, parameterized by $|w|$.
- **Base case:** $|w| = 0$ or minimal length consistent with side constraints.
- **Inductive hypothesis:** Assume $P w$ holds for all strings with $|w| \le n$.
- **Inductive step:** Prove $P w$ for arbitrary $w$ with $|w| = n + 1$.

Canonical applications:
- Correctness of DFA and NFA transition semantics.
- Proofs of language equivalence under automaton constructions.
- Closure properties such as concatenation and homomorphism.

---

#### Structural Induction on Syntax

Applies to recursively defined syntactic objects such as regular expressions or derivation trees.

Let $\mathcal R$ denote the set of regular expressions over alphabet $\Sigma$.
- **Base cases:** $\emptyset$, $\varepsilon$, and $a \in \Sigma$.
- **Inductive cases:** If $r_1, r_2 \in \mathcal R$, then $r_1 + r_2$, $r_1 r_2$, and $r_1^*$.
    

Typical statements proven by structural induction:
- $L r \subseteq \Sigma^*$
- Correctness of Thompson and Glushkov constructions
- Preservation of regularity under syntactic composition

---

#### Induction on Derivation Height

Used for context-free grammars $G = V, \Sigma, P, S$.

Parameter: height of parse tree or number of production applications in a derivation $S \Rightarrow^* w$.

Inductive structure:
- **Base case:** Single-step derivations.
- **Inductive step:** Extension by one production application.
    

Applications:
- Soundness of Chomsky and Greibach normal forms.
- Properties of yields of parse trees.
- Proofs of grammar ambiguity or unambiguity.

---

#### Induction on Computation Length

Used for automata and Turing machines.

Parameter: number of transitions in a computation sequence.

Let $C_0 \vdash C_1 \vdash \dots \vdash C_t$ be a computation.

Induction establishes invariants such as:
- Preservation of tape content properties.
- Correct simulation between computational models.
- Correspondence between machine runs and language acceptance.

---

### Pumping Arguments as Inductive Schemes

Although typically presented via contradiction, pumping lemmas rely on implicit induction.

#### Regular Languages

Given a DFA with $n$ states, any accepting run on $w \in L$ with $|w| \ge n$ yields repeated states.

Inductive principle:
- Finite state space implies repetition along paths.
- Repetition induces decompositions $w = xyz$ with  
    $$  
    |xy| \le n \quad |y| \ge 1 \quad \forall k \ge 0 \colon xy^k z \in L  
    $$
    

---

#### Context-Free Languages

Parse trees of height exceeding the number of nonterminals imply repeated nonterminals along a root-to-leaf path.

This yields decompositions  
$$  
w = uvxyz  
$$  
satisfying pumping conditions derived from structural repetition.

---

### Proof by Contradiction in Formal Language Theory

#### Non-Regularity Proofs

Assume $L \in \mathrm{REG}$ and derive a contradiction using:
- Violation of the regular pumping lemma.
- Infinitely many Myhill–Nerode equivalence classes.
- Closure properties combined with known non-regular languages.

Logical schema:
1. Assume $L$ is regular.
2. Deduce existence of finite automaton or pumping length $p$.
3. Construct $w \in L$ contradicting required constraints.
4. Contradiction.

---

#### Non-Context-Freeness Proofs

Assume $L \in \mathrm{CFL}$ and derive a contradiction using:
- Context-free pumping lemma.
- Ogden’s lemma.
- Intersection with regular languages.
- Reductions from canonical non-context-free languages.

---

#### Undecidability Proofs

Contradiction via reduction.

Assume decidability of language $A$.  
Construct a mapping reduction  
$$  
x \mapsto f x  
$$  
such that  
$$  
x \in B \iff f x \in A  
$$  
for known undecidable language $B$.

This yields a decider for $B$, contradicting established undecidability.

---

#### Rice-Style Arguments

Assume decidability of a non-trivial semantic property $\mathcal P$ of Turing-recognizable languages.

By Rice’s theorem, this implies decidability of the acceptance problem  
$$  
A_{\mathrm{TM}} = { \langle M, w \rangle \mid M \text{ accepts } w }  
$$  
yielding a contradiction.

---

### Structural Roles of the Techniques

- Induction proves universal properties over infinite recursively generated domains.
- Contradiction establishes impossibility, separation, and non-membership results.
    

Hybrid proofs are common:
- Induction to establish invariants.
- Contradiction to refute classification assumptions.

---

### Logical and Complexity-Theoretic Perspective

- Induction relies on well-foundedness of $\mathbb N$ or derivation trees.
- Contradiction exploits classical logic and non-constructive reasoning.
- Hierarchy theorems use diagonalization combined with contradiction.
- Correctness of reductions often proven by induction on input size or simulation depth.

---

### Related Topics

- Myhill–Nerode equivalence
- Pumping lemmas
- Ogden’s lemma
- Rice’s theorem
- Diagonalization
- Mapping reductions
- Normal form transformations

---

