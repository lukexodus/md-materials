## Nondeterministic PDA


### Formal Model

A nondeterministic pushdown automaton is a tuple
$$
M = \langle Q, \Sigma, \Gamma, \Delta, q_0, Z_0, F \rangle
$$
where $Q$ is a finite set of states, $\Sigma$ is the input alphabet, $\Gamma$ is the stack alphabet, $q_0 \in Q$ is the initial state, $Z_0 \in \Gamma$ is the initial stack symbol, $F \subseteq Q$ is the set of accepting states, and
$$
\Delta : Q \times \left(\Sigma \cup {\epsilon}\right) \times \Gamma \to \mathcal{P}!\left(Q \times \Gamma^*\right)
$$
is the transition relation.

A transition $\langle q', \gamma \rangle \in \Delta(q,a,X)$ pops $X$, optionally consumes $a$, and pushes $\gamma$.

### Configurations and Computations

A configuration is a triple
$$
\langle q, w, \alpha \rangle \in Q \times \Sigma^* \times \Gamma^*
$$
with state $q$, unread input $w$, and stack content $\alpha$.

The single-step move relation $\vdash$ is defined by
$$
\langle q, aw, X\beta \rangle \vdash \langle q', w, \gamma\beta \rangle
$$
if $\langle q', \gamma \rangle \in \Delta(q,a,X)$, and similarly for $a = \epsilon$ without consuming input.

The reflexive–transitive closure $\vdash^*$ defines computations.

### Acceptance Criteria

Acceptance by final state:
$$
w \in L(M) \iff \exists q \in F : \langle q_0, w, Z_0 \rangle \vdash^* \langle q, \epsilon, \alpha \rangle
$$

Acceptance by empty stack:
$$
w \in L_{\emptyset}(M) \iff \langle q_0, w, Z_0 \rangle \vdash^* \langle q, \epsilon, \epsilon \rangle
$$

These acceptance modes are equivalent in expressive power for nondeterministic PDAs.

### Expressive Power

The class of languages recognized by nondeterministic PDAs is exactly the class of context-free languages:
$$
\mathsf{NPDA} = \mathsf{CFL}
$$

This equivalence holds via:

* CFG $\Rightarrow$ NPDA: simulate leftmost derivations
* NPDA $\Rightarrow$ CFG: encode stack behavior as nonterminals

### Determinism vs Nondeterminism

Deterministic PDAs recognize a strict subclass:
$$
\mathsf{DPDA} \subsetneq \mathsf{NPDA}
$$

Witness language:
$$
L = { ww^R \mid w \in {0,1}^* }
$$
is context-free but not deterministic context-free.

Nondeterminism is essential to guess the midpoint.

### Normal Forms

Every NPDA can be transformed into an equivalent one satisfying:

* Single-symbol push
* No $\epsilon$-moves on both input and stack simultaneously
* One accepting state
* Acceptance by empty stack

These transformations preserve language recognition.

### Closure Properties

CFLs recognized by NPDAs are closed under:

* Union
* Concatenation
* Kleene star
* Homomorphism
* Inverse homomorphism
* Intersection with regular languages

They are not closed under general intersection or complement.

### Decidability Properties

For NPDA-recognized languages:

* Emptiness: decidable
* Finiteness: decidable
* Membership: decidable in $O(|w|^3)$
* Universality: undecidable
* Equivalence: undecidable
* Inclusion: undecidable

### Pumping Lemma via NPDA

The CFL pumping lemma can be derived from repeating configurations:
$$
\langle q, w_i, \alpha \rangle
$$
with identical state and top-of-stack symbol during a long computation.

This yields the decomposition
$$
w = uvxyz
$$
with pumpable segments.

### Time and Space Complexity

Simulation of NPDA by a Turing machine yields polynomial time membership.

Stack height in accepting computations is $O(|w|)$ for fixed NPDA.

### Relation to Parsing

NPDA executions correspond to parse trees of CFGs.

Nondeterministic branching mirrors grammar ambiguity.

Top-down and bottom-up parsers are restricted NPDA subclasses.

### Logical Characterization

CFLs correspond to existential second-order logic with linear order:
$$
\mathsf{CFL} = \mathsf{ESO}[<]
$$

Nondeterminism corresponds to existential quantification over derivation trees.

### Related Topics

* Deterministic PDA
* Context-free grammars
* LR and LL parsing
* Pushdown systems
* Visibly pushdown automata
* Higher-order pushdown automata


---

