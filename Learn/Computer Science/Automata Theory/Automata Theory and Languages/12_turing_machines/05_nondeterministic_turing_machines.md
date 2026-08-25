## Nondeterministic Turing machines


### Formal definition

A **nondeterministic Turing machine** is a tuple
$$
M = \langle Q, \Sigma, \Gamma, \delta, q_0, q_{\mathrm{acc}}, q_{\mathrm{rej}} \rangle
$$
where:

* $Q$ is a finite set of states,
* $\Sigma$ is the input alphabet with $\blank \notin \Sigma$,
* $\Gamma \supseteq \Sigma \cup {\blank}$ is the tape alphabet,
* $q_0 \in Q$ is the start state,
* $q_{\mathrm{acc}}, q_{\mathrm{rej}} \in Q$ are distinct halting states,
* the transition relation
  $$
  \delta \subseteq Q \times \Gamma \times Q \times \Gamma \times {L,R}
  $$
  is finite and possibly multivalued.

A configuration is a triple
$$
(q, w, i)
$$
where $q \in Q$, $w \in \Gamma^*$ with exactly one head position, and $i \in \mathbb{N}$.

---

### Computation semantics

From a configuration $C$, the machine may move to any $C'$ such that
$$
C \vdash_M C'
$$
according to $\delta$.

A string $w \in \Sigma^*$ is **accepted** iff there exists at least one computation path
$$
C_0 \vdash_M C_1 \vdash_M \dots \vdash_M C_t
$$
with $C_0 = (q_0, w, 0)$ and $C_t$ in state $q_{\mathrm{acc}}$.

Rejection requires that **all** computation paths halt in $q_{\mathrm{rej}}$.

---

### Language classes

Let $\mathrm{NTM}$ denote nondeterministic Turing machines.

Define:
$$
L(M) = { w \mid M \text{ accepts } w }.
$$

Then:
$$
\mathrm{RE} = { L(M) \mid M \text{ is an NTM} }.
$$

Thus nondeterminism does not increase expressive power at the level of computable languages.

---

### Determinization

For every NTM $M$, there exists a deterministic TM $D$ such that:
$$
L(D) = L(M).
$$

Construction: dovetailing or breadth-first simulation of the nondeterministic computation tree.

Consequences:
$$
\mathrm{NTM} = \mathrm{DTM} \quad \text{(language recognition power)}.
$$

---

### Semi-decidability

If $M$ is an NTM, then $L(M)$ is recursively enumerable.

If $L$ is recursively enumerable, then there exists an NTM $M$ such that:
$$
L = L(M).
$$

The complement class $\mathrm{coRE}$ is defined analogously.

---

### Time complexity

Let $M$ be an NTM and $t(n)$ a time bound.

Define:
$$
\mathrm{NTIME}(t(n)) = { L \mid \exists \text{ NTM } M \text{ s.t. } M \text{ accepts in } O(t(n)) \text{ steps} }.
$$

Key result:
$$
\mathrm{DTIME}(t(n)) \subseteq \mathrm{NTIME}(t(n)).
$$

Simulation bound:
$$
\mathrm{NTIME}(t(n)) \subseteq \mathrm{DTIME}(2^{O(t(n))}).
$$

---

### Space complexity

Define:
$$
\mathrm{NSPACE}(s(n)) = { L \mid \exists \text{ NTM } M \text{ using } O(s(n)) \text{ space} }.
$$

Savitch’s theorem:
$$
\mathrm{NSPACE}(s(n)) \subseteq \mathrm{DSPACE}(s(n)^2)
$$
for $s(n) \ge \log n$.

Consequently:
$$
\mathrm{PSPACE} = \mathrm{NPSPACE}.
$$

---

### Acceptance conventions

Alternative acceptance definitions:

* **Existential acceptance**: accept iff some branch accepts.
* **Universal acceptance**: accept iff all branches accept.

Existential NTMs characterize $\mathrm{RE}$ and $\mathrm{NP}$.

Universal NTMs correspond to co-nondeterministic complexity classes.

---

### Relationship to complexity classes

Canonical identifications:
$$
\mathrm{P} = \mathrm{DTIME}(n^{O(1)}),
$$
$$
\mathrm{NP} = \mathrm{NTIME}(n^{O(1)}).
$$

The question:
$$
\mathrm{P} \stackrel{?}{=} \mathrm{NP}
$$
is central to complexity theory.

---

### Certificates and verifiers

For $L \in \mathrm{NP}$, there exists a polynomial-time deterministic TM $V$ such that:
$$
w \in L \iff \exists c,; |c| \le |w|^{O(1)} \land V(w,c) = 1.
$$

This verifier-based characterization is equivalent to nondeterministic computation.

---

### Configurational graph view

An NTM induces a directed graph of configurations.

Acceptance corresponds to reachability of an accepting node from the initial configuration.

This view underlies:

* Savitch’s theorem,
* reachability-based reductions,
* alternating computation.

---

### Normal forms and restrictions

Nondeterminism remains unchanged under:

* single-tape vs multi-tape,
* left/right vs stay moves,
* bounded branching degree.

All such variants are polynomially equivalent.

---

### Limits of nondeterminism

At the language level:
$$
\mathrm{NTM} = \mathrm{DTM}.
$$

At the complexity level:
$$
\mathrm{DTIME}(n^k) \subsetneq \mathrm{NTIME}(n^k) ;; ?
$$
is open for all $k \ge 1$.

---

### Related topics

* Deterministic Turing machines
* Alternating Turing machines
* Savitch’s theorem
* Complexity classes $\mathrm{P}, \mathrm{NP}, \mathrm{PSPACE}$
* Configuration graphs
* Reducibility and completeness

---

