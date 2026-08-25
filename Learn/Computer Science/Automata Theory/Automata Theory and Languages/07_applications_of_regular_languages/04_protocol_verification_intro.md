## Protocol verification (intro)


### Formalization of protocols as languages

A protocol is modeled as a set $L \subseteq \Sigma^*$ of **admissible executions**, where $\Sigma$ is a finite alphabet of observable actions such as message sends, receives, timeouts, or internal steps. Words encode linearizations of distributed behavior under an observation semantics.

Security or correctness properties are specified as language-theoretic constraints:

* **Safety**: $L \subseteq S$ for some prefix-closed $S \subseteq \Sigma^*$.
* **Liveness**: $\forall x \in \mathrm{Pref}\langle L \rangle \ \exists z \in \Sigma^* \ xz \in L$.
* **Trace equivalence**: $L_1 = L_2$.
* **Refinement**: $L_1 \subseteq L_2$.

Protocols with internal nondeterminism or concurrency are often represented by infinite-state generators whose trace languages are regular, context-free, or recursively enumerable depending on abstraction strength.

---

### Automata-based models

Protocol participants are modeled as automata communicating via shared actions or channels.

* **Finite-state protocols**: product of DFAs or NFAs with synchronization, yielding regular trace languages.
* **Communicating automata**: finite control with unbounded FIFO channels, generating non-regular languages.
* **Pushdown systems**: model recursion or protocol stacks, yielding context-free trace sets.
* **Labeled transition systems**: graphs $\langle S,\Sigma,\to,s_0 \rangle$ inducing languages via paths.

Global behavior is the language
$$
L = { a_1 \cdots a_n \in \Sigma^* \mid s_0 \xrightarrow{a_1} \cdots \xrightarrow{a_n} s_n } .
$$

---

### Specification languages and logic

Desired properties are expressed in logical formalisms interpreted over executions.

* **Regular specifications**: given by automata or regular expressions $R \subseteq \Sigma^*$.
* **Temporal logic**: formulas interpreted over infinite words in $\Sigma^\omega$.
* **MSO on words**: characterizes all regular trace properties.

Verification reduces to language inclusion or emptiness:
$$
L \cap \overline{R} = \varnothing .
$$

---

### Verification problems

Core decision problems:

* **Reachability**: $\exists x \in L \ x \in B$ for bad-event language $B$.
* **Safety**: $L \cap B = \varnothing$.
* **Equivalence**: $L_1 = L_2$.
* **Observational equivalence**: $h\langle L_1 \rangle = h\langle L_2 \rangle$ for abstraction homomorphism $h : \Sigma^* \to \Gamma^*$.

For regular $L$ and $B$, these are decidable via automata constructions. For pushdown or communicating models, decidability depends on channel bounds, stack discipline, or abstraction.

---

### Abstraction and overapproximation

Infinite-state protocols are verified via abstraction maps
$$
\alpha : \Sigma^* \to \Gamma^*
$$
such that
$$
\alpha\langle L \rangle \supseteq L_{\text{abs}} .
$$
Soundness requires
$$
L_{\text{abs}} \cap B = \varnothing \implies L \cap B = \varnothing .
$$
Regular abstractions enable reduction to DFA-based verification.

Analogy: abstraction acts like compressing an infinite movie into a finite storyboard; if no forbidden scene appears in the storyboard, none appears in the full movie.

---

### State-space explosion and minimization

The synchronous product of $k$ participants with state sets $Q_1,\dots,Q_k$ yields up to $\prod_i \lvert Q_i \rvert$ global states.

Automata-theoretic mitigation:

* DFA minimization via Myhill–Nerode equivalence
* Language quotients and projections
* Partial-order reduction preserving trace equivalence

---

### Decidability landscape

* Finite-state protocol safety: decidable, PSPACE-complete via NFA emptiness.
* Pushdown protocol safety: decidable via reachability in pushdown systems.
* Unbounded FIFO channels: reachability undecidable.
* Equivalence of general protocol generators: undecidable by reduction from Turing machine equivalence.

---

### Algebraic and language-theoretic view

Protocols induce congruences on $\Sigma^*$ via observational indistinguishability. Correctness properties correspond to unions of equivalence classes under these congruences.

Verification asks whether
$$
\equiv_L \preceq \equiv_{\text{spec}}
$$
where $\equiv_L$ is the syntactic congruence of the protocol language and $\equiv_{\text{spec}}$ that of the specification.

---

### Related topics

* Model checking
* Communicating finite-state machines
* Trace semantics
* Language inclusion
* Bisimulation
* Refinement checking
* Temporal logic over words
* Automata-based verification

---

