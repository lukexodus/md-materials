## Deterministic PDA


### Formal Definition

A deterministic pushdown automaton is a tuple
$$
M = \langle Q, \Sigma, \Gamma, \delta, q_0, Z_0, F \rangle
$$
where $Q$ is a finite set of states, $\Sigma$ is the input alphabet, $\Gamma$ is the stack alphabet, $q_0 \in Q$ is the start state, $Z_0 \in \Gamma$ is the initial stack symbol, $F \subseteq Q$ is the set of accepting states, and
$$
\delta : Q \times \left( \Sigma \cup { \varepsilon } \right) \times \Gamma \to Q \times \Gamma^*
$$
is a partial transition function satisfying the determinism constraints:

* For all $q \in Q$, $a \in \Sigma$, $X \in \Gamma$, at most one of $\delta(q, a, X)$ and $\delta(q, \varepsilon, X)$ is defined.
* For all $q, a, X$, there is at most one transition $\delta(q, a, X)$.

Configurations are triples
$$
\langle q, w, \alpha \rangle \in Q \times \Sigma^* \times \Gamma^*
$$
with stack top on the left.

### Acceptance Modes

Two standard acceptance criteria are used:

* **Acceptance by final state**: $w \in L(M)$ if
  $$
  \langle q_0, w, Z_0 \rangle \vdash^* \langle q, \varepsilon, \alpha \rangle
  $$
  for some $q \in F$.
* **Acceptance by empty stack**: $w \in L(M)$ if
  $$
  \langle q_0, w, Z_0 \rangle \vdash^* \langle q, \varepsilon, \varepsilon \rangle
  $$
  for some $q \in Q$.

For deterministic PDAs, these two acceptance modes are not equivalent. Acceptance by empty stack is strictly more expressive.

### Determinism Constraints and Consequences

Determinism enforces a single computation path for every input. In particular, a DPDA cannot guess the correct point to apply an $\varepsilon$-transition. This restriction fundamentally limits expressive power.

For any configuration $\langle q, w, X\alpha \rangle$, there is at most one successor configuration under $\vdash$.

### Language Class

The class of languages recognized by DPDAs is the class of **deterministic context-free languages**, denoted $\mathrm{DCFL}$.

Proper containment holds:
$$
\mathrm{DCFL} \subsetneq \mathrm{CFL}.
$$

A canonical separating example is
$$
L = { ww^R \mid w \in {a,b}^* },
$$
which is context-free but not deterministic context-free.

### Closure Properties

$\mathrm{DCFL}$ satisfies:

* Closed under complement.
* Closed under intersection with regular languages.
* Closed under inverse homomorphisms.

$\mathrm{DCFL}$ is not closed under:

* Union.
* Intersection.
* Homomorphisms.
* Kleene star.

Closure under complement follows from the determinism and totality properties after suitable completion.

### Normal Forms and Restrictions

Every DPDA can be transformed into an equivalent one with:

* No $\varepsilon$-moves except possibly those that pop the stack.
* Single-symbol push operations.
* Acceptance by final state with a nonempty stack invariant.

However, unlike NPDA, there is no general normal form eliminating $\varepsilon$-moves entirely while preserving determinism.

### Decidability Results

Decidable problems for DPDAs include:

* Membership: given $M$ and $w$, decide $w \in L(M)$.
* Emptiness: decide $L(M) = \emptyset$.
* Finiteness: decide whether $L(M)$ is finite.

Undecidable problems include:

* Equivalence of two DPDAs.
* Inclusion between DPDA languages.
* Ambiguity of equivalent CFGs defining DCFLs.

### Equivalence with Deterministic CFGs

A CFG $G$ is deterministic if there exists a DPDA $M$ such that
$$
L(G) = L(M).
$$

Deterministic CFGs correspond to grammars parseable by deterministic parsing strategies, such as LR parsing. The correspondence is not structural but language-theoretic.

### Parsing and DPDA

LR parsing constructs a DPDA whose stack encodes viable prefixes of a rightmost derivation. For an LR grammar $G$, the induced DPDA recognizes $L(G)$ deterministically.

The parsing stack symbols correspond to LR states rather than grammar symbols, reflecting a shift from syntactic to automaton-theoretic structure.

### Pumping and Structural Properties

DCFLs satisfy a restricted pumping property stronger than the CFL pumping lemma. In particular, deterministic pumping enforces unambiguous repetition points tied to unique computation paths.

However, there exists no simple pumping lemma characterizing DCFLs exactly.

### Relationship to Complexity

Membership for DPDA-recognized languages is decidable in deterministic linear time.

The class $\mathrm{DCFL}$ lies strictly between $\mathrm{REG}$ and $\mathrm{CFL}$ and is contained in $\mathrm{P}$.

### Logical Characterization

DCFLs correspond to languages definable by deterministic monadic second-order transductions from regular tree languages. They are also characterizable by visibly pushdown automata under suitable encodings.

### Related Topics

* Nondeterministic pushdown automata
* Context-free grammars
* Deterministic context-free languages
* LR parsing
* Visibly pushdown automata
* Pushdown systems
* Tree automata

---

