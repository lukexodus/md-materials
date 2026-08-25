## Automata on Infinite Trees


### Formal Models

An **infinite tree** over a finite ranked alphabet $\Sigma$ is a function $t : D^* \to \Sigma$ where $D$ is a finite set of directions and $D^*$ is the set of all finite sequences over $D$. Typically $D = {0,1}$ for full binary trees or $D = {1,\dots,k}$ for $k$-ary trees. Nodes are addressed by words in $D^*$, with the root at $\epsilon$.

A **tree automaton on infinite trees** is a tuple  
$$  
\mathcal{A} = \langle Q, \Sigma, D, q_0, \delta, \mathsf{Acc} \rangle  
$$  
where $Q$ is a finite set of states, $q_0 \in Q$ is the initial state, and $\delta$ is a transition function assigning to each pair $q \in Q$, $a \in \Sigma$ a set of successor state tuples indexed by $D$. A **run** of $\mathcal{A}$ on a tree $t$ is a labeling $\rho : D^* \to Q$ such that $\rho(\epsilon) = q_0$ and for every node $u \in D^*$,  
$$  
\langle \rho(u \cdot d) \rangle_{d \in D} \in \delta \bigl( \rho(u), t(u) \bigr)  
$$

Acceptance is defined via conditions on infinite paths of the run tree.

### Acceptance Conditions

Let $\pi = u_0 u_1 u_2 \dots$ be an infinite path in $D^*$.

**Büchi condition**  
Given $F \subseteq Q$, a run $\rho$ is accepting if for every infinite path $\pi$,  
$$  
\mathrm{Inf} \bigl( \rho \circ \pi \bigr) \cap F \neq \emptyset  
$$  
where $\mathrm{Inf}$ denotes states occurring infinitely often.

**Co-Büchi condition**  
Given $F \subseteq Q$, acceptance requires  
$$  
\mathrm{Inf} \bigl( \rho \circ \pi \bigr) \subseteq F  
$$

**Rabin condition**  
Given a finite set of pairs ${ \langle E_i, F_i \rangle }_{i \in I}$, acceptance requires for every path $\pi$ the existence of $i \in I$ such that  
$$  
\mathrm{Inf} \bigl( \rho \circ \pi \bigr) \cap E_i = \emptyset  
\quad \land \quad  
\mathrm{Inf} \bigl( \rho \circ \pi \bigr) \cap F_i \neq \emptyset  
$$

**Streett and parity conditions** are defined analogously; parity assigns a priority function $\Omega : Q \to \mathbb{N}$ and requires the minimal priority occurring infinitely often along each path to be even.

Parity conditions are canonical due to closure and determinization properties.

### Nondeterminism, Alternation, and Determinism

A **nondeterministic tree automaton** chooses one successor tuple per node. An **alternating tree automaton** generalizes transitions to positive Boolean formulas over $Q^D$, allowing both existential and universal branching. Formally,  
$$  
\delta : Q \times \Sigma \to \mathcal{B}^+ \bigl( Q^D \bigr)  
$$  
where $\mathcal{B}^+$ denotes monotone Boolean formulas.

Alternation strictly increases succinctness but not expressive power under parity acceptance:  
$$  
\text{ALT-PARITY} = \text{NDET-PARITY}  
$$  
with exponential blow-up in state space for alternation removal.

Deterministic parity tree automata are strictly weaker in expressive power than nondeterministic ones.

### Expressive Power and Language Classes

Let $\mathsf{REG}_\omega^\mathsf{tree}$ denote the class of tree languages recognized by nondeterministic parity tree automata.

Key results:  
$$  
\mathsf{REG}_\omega^\mathsf{tree} = \text{MSO-definable tree languages}  
$$  
where MSO is monadic second-order logic over infinite trees.

Deterministic parity tree automata recognize a strict subclass:  
$$  
\mathsf{DET}_\omega^\mathsf{tree} \subsetneq \mathsf{REG}_\omega^\mathsf{tree}  
$$

Büchi and co-Büchi automata are strictly weaker than parity automata on infinite trees, unlike the $\omega$-word case.

### Closure Properties

The class $\mathsf{REG}_\omega^\mathsf{tree}$ is closed under:
- Union
- Intersection
- Complement
- Projection
- Inverse homomorphism
    

Complementation requires parity acceptance and relies on game-theoretic dualization.

Deterministic classes fail closure under complement.

### Game-Theoretic Semantics

Acceptance of a tree by an alternating parity automaton corresponds to the existence of a winning strategy in a parity game  
$$  
\mathcal{G} = \langle V_\exists, V_\forall, E, \Omega \rangle  
$$  
where positions correspond to configurations $\langle u, q \rangle$.

Memoryless determinacy holds:  
$$  
\text{Parity games are positionally determined}  
$$  
which underlies closure under complement and decidability of emptiness.

### Decidability and Complexity

**Emptiness problem**  
Given a nondeterministic parity tree automaton $\mathcal{A}$, decide whether $L(\mathcal{A}) = \emptyset$.

Decidable via parity games with complexity:  
$$  
\text{EXPTIME-complete}  
$$

**Universality and inclusion** are also EXPTIME-complete.

For alternating automata, emptiness reduces to solving parity games of size exponential in the automaton.

### Normal Forms and Transformations

Every alternating parity tree automaton can be transformed into:
- An equivalent nondeterministic parity tree automaton
- A parity automaton with priorities in ${0,\dots,2|Q|-1}$
    

Büchi automata can be transformed into parity automata with at most $2$ priorities but not conversely.

### Pumping and Non-Regularity

There is no direct pumping lemma analogous to finite trees. Non-regularity is typically shown via:
- MSO undefinability
- Ehrenfeucht–Fraïssé games on trees
- Topological arguments using the Cantor topology on $D^*$
    

Regular tree languages form a Boolean algebra but are not well-quasi-ordered under embedding.

### Logical Characterizations

Equivalences:  
$$ \mathsf{REG}_\omega^\mathsf{tree} \subseteq \text{MSO} \subseteq \mu\text{-calculus} $$

The modal $\mu$-calculus corresponds exactly to alternating parity tree automata, with fixpoint alternation depth matching parity index.

First-order logic is strictly weaker:  
$$  
\text{FO} \subsetneq \text{MSO}  
$$

### Complexity-Theoretic Connections

Tree automata underpin:
- Model checking of branching-time logics
- Satisfiability of MSO on trees
- Verification of non-terminating reactive systems
    

The modal $\mu$-calculus model checking problem over trees is EXPTIME-complete.

### Topological and Measure-Theoretic Aspects

Tree languages induce subsets of $\Sigma^{D^*}$ with the product topology.

Parity-recognizable languages are Borel sets of finite rank:  
$$  
\mathsf{REG}_\omega^\mathsf{tree} \subseteq \Delta^0_\omega  
$$

Büchi-recognizable tree languages may be non-Borel-complete but not closed under complement.

### Related Topics

- Rabin tree automata
- Alternating automata
- Parity games
- Modal $\mu$-calculus
- MSO on trees
- Branching-time temporal logics
- Infinite graph automata
- Descriptive set theory in automata

---

