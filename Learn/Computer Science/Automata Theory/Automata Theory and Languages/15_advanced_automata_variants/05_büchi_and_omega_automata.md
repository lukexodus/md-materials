## Büchi and $\omega$-Automata


### $\omega$-Words and $\omega$-Languages

Let $\Sigma$ be a finite alphabet. An $\omega$-word is an infinite sequence $w = a_0 a_1 a_2 \cdots$ with $a_i \in \Sigma$. The set of all $\omega$-words over $\Sigma$ is denoted $\Sigma^\omega$. An $\omega$-language is a subset $L \subseteq \Sigma^\omega$.

For $u \in \Sigma^*$ and $v \in \Sigma^+$, the ultimately periodic $\omega$-word is denoted $u v^\omega$.

---

### Büchi Automata

A nondeterministic Büchi automaton is a tuple

$$  
\mathcal{A} = \langle Q, \Sigma, \delta, q_0, F \rangle  
$$

where $Q$ is a finite set of states, $\delta : Q \times \Sigma \to 2^Q$ is the transition function, $q_0 \in Q$ is the initial state, and $F \subseteq Q$ is the set of accepting states.

A run of $\mathcal{A}$ on $w \in \Sigma^\omega$ is an infinite sequence of states

$$  
\rho = q_0 q_1 q_2 \cdots  
$$

such that $q_{i+1} \in \delta q_i a_i$ for all $i \in \mathbb{N}$. The run is accepting if

$$  
\mathrm{Inf} \rho \cap F \neq \varnothing  
$$

where $\mathrm{Inf} \rho$ denotes the set of states appearing infinitely often in $\rho$.

The accepted language is

$$  
L_\omega \mathcal{A} = { w \in \Sigma^\omega \mid \exists \text{ accepting run of } \mathcal{A} \text{ on } w }  
$$

---

### Determinism and Expressive Power

Deterministic Büchi automata are strictly less expressive than nondeterministic Büchi automata. There exist $\omega$-regular languages not recognizable by any deterministic Büchi automaton.

However, nondeterministic Büchi automata are equivalent in expressive power to:

$$  
\omega\text{-regular languages}  
$$

defined via $\omega$-regular expressions or monadic second-order logic.

---

### Other Acceptance Conditions

Let $\rho$ be a run of an $\omega$-automaton.
- **Muller:** $\mathrm{Inf} \rho \in \mathcal{F}$ for a family $\mathcal{F} \subseteq 2^Q$
- **Rabin:** $\exists i ; \mathrm{Inf} \rho \cap F_i \neq \varnothing \land \mathrm{Inf} \rho \cap E_i = \varnothing$
- **Streett:** $\forall i ; \mathrm{Inf} \rho \cap E_i = \varnothing \lor \mathrm{Inf} \rho \cap F_i \neq \varnothing$
- **Parity:** $\min { \pi q \mid q \in \mathrm{Inf} \rho }$ is even
    

These acceptance conditions are all equivalent in expressive power to Büchi automata over $\omega$-languages.

---

### Closure Properties of $\omega$-Regular Languages

The class of $\omega$-regular languages is closed under:
- union
- intersection
- complement
- projection
- inverse homomorphism
    

Complementation requires determinization and parity acceptance, yielding exponential blowup.

---

### Determinization

Nondeterministic Büchi automata can be determinized using Safra constructions, producing deterministic Rabin or parity automata. The number of states grows as

$$  
2^{O n \log n}  
$$

where $n = |Q|$.

No direct determinization to deterministic Büchi automata exists in general.

---

### Topological and Measure-Theoretic Aspects

$\omega$-regular languages occupy low levels of the Borel hierarchy:

$$  
\omega\text{-regular} \subseteq \mathbf{Borel} \subsetneq \Sigma^\omega  
$$

Specifically, Büchi-recognizable languages are boolean combinations of $G_\delta$ sets.

---

### Decidability Problems

For Büchi automata $\mathcal{A}, \mathcal{B}$:
- emptiness is decidable in polynomial time via graph analysis
- universality is decidable via complementation
- language inclusion reduces to emptiness of intersection with complement
- equivalence is decidable

---

### Pumping and Ultimately Periodic Words

Every $\omega$-regular language is completely characterized by its ultimately periodic words:

$$  
w \in L \iff \exists u,v \in \Sigma^* ; w = u v^\omega  
$$

This property underlies decision procedures and logical characterizations.

---

### Logical Characterization

By Büchi theorem,

$$  
\omega\text{-regular languages} = \mathrm{MSO} \Sigma^\omega  
$$

where $\mathrm{MSO}$ is monadic second-order logic interpreted over infinite words with successor.

---

### Complexity and Verification

Model checking of linear temporal logic reduces to emptiness of Büchi automata. Given a system automaton $\mathcal{S}$ and a property automaton $\mathcal{A}$, verification reduces to checking

$$  
L_\omega \mathcal{S} \cap L_\omega \mathcal{A} = \varnothing  
$$

with complexity polynomial in the system size and exponential in the specification.

---

### Relationships to Other Models

- $\omega$-regular expressions
- Linear temporal logic
- Monadic second-order logic
- Parity games
- Infinite trees and tree automata

---

