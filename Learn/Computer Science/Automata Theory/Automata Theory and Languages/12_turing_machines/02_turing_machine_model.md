## Turing machine model


### Formal definition

A single-tape deterministic Turing machine is a tuple
$$
M = \langle Q, \Sigma, \Gamma, \delta, q_0, q_{\text{acc}}, q_{\text{rej}} \rangle
$$
where:

* $Q$ is a finite set of states
* $\Sigma$ is the input alphabet with $\sqcup \notin \Sigma$
* $\Gamma$ is the tape alphabet with $\Sigma \subseteq \Gamma$ and blank symbol $\sqcup$
* $\delta : Q \times \Gamma \to Q \times \Gamma \times {L,R}$ is a partial transition function
* $q_0$ is the initial state
* $q_{\text{acc}}, q_{\text{rej}} \in Q$, $q_{\text{acc}} \neq q_{\text{rej}}$, are halting states

Acceptance is defined by reaching $q_{\text{acc}}$; rejection by reaching $q_{\text{rej}}$.

---

### Configurations and computation

A configuration is a triple
$$
\langle q, \alpha, \beta \rangle \in Q \times \Gamma^* \times \Gamma^*
$$
where the tape contents are $\alpha \beta$, the head scans the first symbol of $\beta$, and $q$ is the current state.

The one-step move relation
$$
\vdash_M ;\subseteq; \text{Conf}(M) \times \text{Conf}(M)
$$
is induced by $\delta$. The reflexive transitive closure is denoted $\vdash_M^*$.

A string $w \in \Sigma^*$ is accepted if
$$
\langle q_0, \epsilon, w \rangle \vdash_M^* \langle q_{\text{acc}}, \alpha, \beta \rangle
$$
for some $\alpha,\beta \in \Gamma^*$.

---

### Language classes

* **Recursively enumerable languages**
  $$
  \text{RE} = { L \subseteq \Sigma^* \mid \exists M : L = L(M) }
  $$

* **Recursive languages**
  $$
  \text{REC} = { L \mid \exists M \text{ that halts on all inputs and decides } L }
  $$

Relationship:
$$
\text{REC} \subsetneq \text{RE}
$$

---

### Nondeterministic Turing machines

A nondeterministic TM replaces $\delta$ by
$$
\delta : Q \times \Gamma \to \mathcal{P}(Q \times \Gamma \times {L,R})
$$

Acceptance:
$$
w \in L(M) \iff \exists \text{ accepting computation branch}
$$

Expressive equivalence:
$$
\text{DTM} \equiv \text{NTM}
$$
with respect to language recognition.

---

### Variants and robustness

All following models are equivalent in expressive power:

* Multi-tape Turing machines
* Multi-head Turing machines
* Two-way infinite tape machines
* Off-line input tapes
* Read-only input with work tapes
* Enumerator Turing machines

Equivalence is via polynomial-time or linear-time simulations depending on the variant.

---

### Multi-tape simulation

A $k$-tape TM can be simulated by a single-tape TM with at most quadratic time overhead:
$$
T_{\text{single}}(n) = O\lparen T_{\text{multi}}(n)^2 \rparen
$$

Thus time complexity classes are invariant up to polynomial factors.

---

### Universal Turing machine

There exists a universal TM $U$ such that
$$
U(\langle M,w \rangle) = M(w)
$$

Formally:
$$
\forall M, w ; \lparen M(w) \downarrow \implies U(\langle M,w \rangle) \downarrow \text{ with same outcome} \rparen
$$

Universality underlies undecidability via self-reference.

---

### Undecidability results

#### Halting problem

$$
L_{\text{HALT}} = { \langle M,w \rangle \mid M \text{ halts on } w }
$$
is undecidable.

Proof uses diagonalization.

---

#### Rice’s theorem

For any nontrivial semantic property $P$ of recursively enumerable languages:
$$
{ \langle M \rangle \mid L(M) \text{ satisfies } P }
$$
is undecidable.

---

### Reductions and completeness

Many undecidable problems are shown via many-one reductions:
$$
A \le_m B
$$

Example:
$$
L_{\text{HALT}} \le_m L_{\text{ACC}}
$$

Completeness defines maximal undecidable problems under reduction.

---

### Time and space complexity

A TM runs in time $T(n)$ if:
$$
\forall |w| = n ; \text{steps}(M,w) \le T(n)
$$

Space complexity:
$$
\text{SPACE}(f(n)) = { L \mid \exists M \text{ using } O(f(n)) \text{ tape cells} }
$$

Key results:

* Time hierarchy theorem
* Space hierarchy theorem
* $\text{CSL} = \text{NSPACE}(n)$

---

### Normal forms

Every TM can be transformed into:

* A binary alphabet TM
* A TM with a single halting state
* A TM with only right moves except marked left sweeps

These transformations preserve computability and decidability.

---

### Logical characterization

By Fagin’s theorem:
$$
\text{NP} = \text{ESO}
$$

Recursive languages correspond to arithmetic definability over $\langle \mathbb{N}, +, \times \rangle$.

---

### Algebraic viewpoint

Configurations form a countable graph; computation corresponds to path existence.

The transition relation induces a partial function on configurations.

Undecidability arises from non-well-founded reachability.

---

### Relationship to automata hierarchy

$$
\text{REG} \subsetneq \text{CFL} \subsetneq \text{CSL} \subsetneq \text{RE}
$$

Turing machines characterize the top level of the Chomsky hierarchy.

---

### Related topics

* Universal computation
* Recursive enumerability
* Halting problem
* Linear bounded automata
* Time and space hierarchy theorems
* Lambda calculus and register machines

---

