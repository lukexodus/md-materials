## Acceptance by empty stack vs final state


### Pushdown automaton models

A pushdown automaton is a tuple
$$
M = \langle Q, \Sigma, \Gamma, \delta, q_0, Z_0, F \rangle
$$
where $\delta \subseteq Q \times \Sigma_\epsilon \times \Gamma_\epsilon \to \mathcal{P}(Q \times \Gamma_\epsilon)$.

Two acceptance criteria are standard:

* **Acceptance by final state**
  $$
  w \in L_F(M) ;\Longleftrightarrow; \exists \text{ computation } (q_0,w,Z_0) \vdash^* (q,\epsilon,\gamma) \text{ with } q \in F
  $$

* **Acceptance by empty stack**
  $$
  w \in L_E(M) ;\Longleftrightarrow; \exists \text{ computation } (q_0,w,Z_0) \vdash^* (q,\epsilon,\epsilon)
  $$

No restriction is placed on $q$ in the empty-stack case.

---

### Equivalence of expressive power

For nondeterministic PDAs:
$$
\text{CFL} = { L_F(M) \mid M \text{ PDA} } = { L_E(M) \mid M \text{ PDA} }
$$

Thus acceptance by final state and acceptance by empty stack are equivalent in expressive power.

---

### Construction: final state to empty stack

Given a PDA $M$ accepting by final state, construct $M'$ accepting by empty stack.

Add a new bottom-of-stack symbol $\bot \notin \Gamma$ and a new initial state $q_0'$.

Initial transition:
$$
\delta'(q_0',\epsilon,\epsilon) \ni (q_0,Z_0\bot)
$$

For each $f \in F$, add transitions:
$$
\delta'(f,\epsilon,a) \ni (f,\epsilon) \quad \forall a \in \Gamma \cup {\bot}
$$

Then:
$$
L_E(M') = L_F(M)
$$

The construction preserves nondeterminism and introduces no additional stack growth beyond a constant.

---

### Construction: empty stack to final state

Given a PDA $M$ accepting by empty stack, construct $M'$ accepting by final state.

Add a fresh final state $q_f$ and preserve the stack alphabet.

For every state $q \in Q$, add:
$$
\delta'(q,\epsilon,\epsilon) \ni (q_f,\epsilon)
$$
only when the stack is empty.

Then:
$$
L_F(M') = L_E(M)
$$

Alternatively, enforce a bottom marker and detect its removal to trigger acceptance.

---

### Determinism sensitivity

For deterministic PDAs, acceptance criteria are not equivalent.

Define:

* $\text{DCFL}_F = { L_F(M) \mid M \text{ deterministic PDA} }$
* $\text{DCFL}_E = { L_E(M) \mid M \text{ deterministic PDA} }$

Then:
$$
\text{DCFL}_F \subsetneq \text{DCFL}_E
$$

Acceptance by empty stack is strictly more expressive for deterministic PDAs.

---

### Canonical counterexample

The language
$$
L = { wcw^R \mid w \in {a,b}^* }
$$
is accepted by a deterministic PDA using empty-stack acceptance but not by any deterministic PDA using final-state acceptance.

The failure arises because deterministic final-state acceptance requires knowledge of input exhaustion before stack clearance.

---

### Operational distinction

Acceptance by final state enforces:
$$
\text{control-state observability}
$$

Acceptance by empty stack enforces:
$$
\text{structural completion of stack discipline}
$$

In deterministic settings, these observability constraints are not inter-derivable.

---

### Relation to grammar derivations

Given a CFG $G$:

* Acceptance by empty stack corresponds naturally to leftmost derivations
* Acceptance by final state corresponds to explicit derivation completion markers

Standard CFG-to-PDA constructions typically yield empty-stack acceptance.

---

### Closure properties impact

For deterministic PDAs:

* $\text{DCFL}_F$ is closed under complement
* $\text{DCFL}_E$ is not closed under complement

This asymmetry follows from the ability to detect rejection via final-state nonreachability.

---

### Normal form implications

Acceptance by empty stack admits PDAs with:

* Single state
* No final states
* Pure stack-driven control

Acceptance by final state generally requires:

* At least one accepting state
* Stack nonemptiness tolerated at acceptance

---

### Complexity and verification relevance

In model checking and parsing:

* Empty-stack acceptance aligns with well-nested execution traces
* Final-state acceptance aligns with control-flow reachability

Equivalence checking between the two requires nondeterministic simulation or state augmentation.

---

### Logical characterization

Acceptance by empty stack corresponds to existential acceptance over configurations satisfying:
$$
\text{stack} = \epsilon
$$

Acceptance by final state corresponds to existential acceptance over:
$$
q \in F
$$

These predicates are not interdefinable under deterministic transition semantics.

---

### Algebraic perspective

Empty-stack acceptance enforces annihilation of the stack monoid action.

Final-state acceptance enforces membership in a distinguished subset of control states.

These correspond to different congruence quotients of the PDA transition system.

---

### Related topics

* Deterministic pushdown automata
* Context-free grammar to PDA constructions
* LR parsing automata
* Visibly pushdown languages
* Closure properties of DCFLs


---

