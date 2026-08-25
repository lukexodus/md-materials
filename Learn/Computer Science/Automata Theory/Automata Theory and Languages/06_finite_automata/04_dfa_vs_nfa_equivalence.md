## DFA vs NFA Equivalence


### Formal Models

A deterministic finite automaton is a tuple
$M_D = \langle Q, \Sigma, \delta, q_0, F \rangle$
with transition function $\delta : Q \times \Sigma \to Q$.

A nondeterministic finite automaton is a tuple
$M_N = \langle Q, \Sigma, \Delta, Q_0, F \rangle$
with transition relation $\Delta : Q \times \Sigma \to \mathcal{P}!\left(Q\right)$ and initial state set $Q_0 \subseteq Q$.

Acceptance for $M_N$ is defined by existence of a computation path. For $w = a_1 \dots a_n \in \Sigma^*$, define the extended transition function
$$
\Delta^*!\left(S, w\right) = \bigcup_{q \in S} \Delta^*!\left(q, w\right)
$$
with $\Delta^*!\left(q, \epsilon\right) = {q}$ and
$$
\Delta^*!\left(q, aw\right) = \Delta^*!\left(\Delta!\left(q,a\right), w\right)
$$

The language recognized by $M_N$ is
$$
L!\left(M_N\right) = { w \in \Sigma^* \mid \Delta^*!\left(Q_0, w\right) \cap F \neq \emptyset }
$$

### Equivalence Theorem

For every NFA $M_N$, there exists a DFA $M_D$ such that
$$
L!\left(M_D\right) = L!\left(M_N\right)
$$

Conversely, every DFA is trivially an NFA by interpreting $\delta$ as a singleton-valued transition relation. Hence the classes of languages recognized by DFAs and NFAs coincide and equal the class of regular languages $\mathsf{REG}$.

### Subset Construction

Given $M_N = \langle Q, \Sigma, \Delta, Q_0, F \rangle$, define the DFA
$$
M_D = \langle \mathcal{P}!\left(Q\right), \Sigma, \delta', Q_0, F' \rangle
$$
where
$$
\delta'!\left(S,a\right) = \bigcup_{q \in S} \Delta!\left(q,a\right)
$$
and
$$
F' = { S \subseteq Q \mid S \cap F \neq \emptyset }
$$

For all $w \in \Sigma^*$, an invariant holds:
$$
\delta'^*!\left(Q_0, w\right) = \Delta^*!\left(Q_0, w\right)
$$
established by induction on $|w|$. Acceptance equivalence follows immediately.

### State Complexity and Exponential Blow-up

If $|Q| = n$, then $|\mathcal{P}!\left(Q\right)| = 2^n$. This bound is tight: there exist families of NFAs $M_n$ such that any equivalent DFA requires $2^n$ states.

Canonical witness languages include:
$$
L_n = { w \in {0,1}^* \mid \exists i \le n : \text{the $i$th symbol from the end is } 1 }
$$

The NFA tracks all possible positions nondeterministically, while any DFA must encode all subsets of active positions.

### Structural Expressiveness

NFAs and DFAs have identical language recognition power but differ in structural succinctness.

* NFAs allow implicit parallelism.
* DFAs enforce explicit state encoding.
* NFAs admit linear constructions for union and concatenation.
* DFAs may require determinization prior to closure operations.

There exists no polynomial upper bound on the size of equivalent DFAs relative to NFAs.

### Closure Properties via Equivalence

Using DFA–NFA equivalence, $\mathsf{REG}$ is closed under:

* Union: via NFA branching
* Concatenation: via $\epsilon$-free simulation
* Kleene star: via nondeterministic restart
* Complement: via DFA totalization and final-state complementation
* Intersection: via DFA product construction

Closure under complement fundamentally relies on determinism.

### Decision Problems and Reductions

Language equivalence for DFAs is decidable in polynomial time via minimization or bisimulation. For NFAs, equivalence is PSPACE-complete, reducible from NFA universality.

Containment reduces to emptiness:
$$
L!\left(M_1\right) \subseteq L!\left(M_2\right) \iff L!\left(M_1\right) \cap \overline{L!\left(M_2\right)} = \emptyset
$$

Determinization followed by complement enables this reduction.

### Relation to Regular Expressions

Kleene’s theorem establishes equivalence among DFAs, NFAs, and regular expressions:
$$
\mathsf{REG} = \mathsf{DFA} = \mathsf{NFA} = \mathsf{RE}
$$

Thompson construction yields NFAs of size $O!\left(|r|\right)$ for regular expressions $r$, while DFA construction may induce exponential blow-up.

### Logical Characterization

By Büchi–Elgot–Trakhtenbrot:
$$
\mathsf{REG} = \mathsf{FO}!\left[<\right]
$$
Determinism and nondeterminism correspond to alternative automaton representations of the same first-order definable languages over finite words.

### Minimization and Canonical Forms

Every regular language has a unique minimal DFA up to isomorphism, obtained via Myhill–Nerode equivalence:
$$
x \equiv_L y \iff \forall z \in \Sigma^* : xz \in L \Leftrightarrow yz \in L
$$

NFAs lack a canonical minimal form; minimal-NFA problems are PSPACE-hard.

### Related Topics

* $\epsilon$-NFAs
* Two-way finite automata
* Alternating finite automata
* Myhill–Nerode relations
* Regular expressions
* FO-definable languages
* Automata minimization
* State complexity theory


---

