## Quantum automata


### Mathematical model

A quantum automaton is defined over a finite alphabet $\Sigma$ with a finite-dimensional complex Hilbert space $\mathcal{H} \cong \mathbb{C}^d$. Configurations are unit vectors $\lvert \psi \rangle \in \mathcal{H}$. Input symbols induce linear transformations subject to quantum-mechanical constraints.

The two standard introductory models are measure-once and measure-many one-way quantum finite automata.

### Measure-once one-way quantum finite automata

A measure-once one-way quantum finite automaton is a tuple  
$$  
\mathcal{A} = \langle \Sigma, \mathcal{H}, \lvert \psi_0 \rangle, { U_a }_{a \in \Sigma}, P_{\mathrm{acc}} \rangle  
$$  
where $\lvert \psi_0 \rangle$ is the initial state, each $U_a$ is a unitary operator on $\mathcal{H}$, and $P_{\mathrm{acc}}$ is an orthogonal projection onto an accepting subspace $\mathcal{H}_{\mathrm{acc}} \subseteq \mathcal{H}$.

For an input $w = a_1 a_2 \cdots a_n \in \Sigma^*$, the final state is  
$$  
\lvert \psi_w \rangle = U_{a_n} \cdots U_{a_2} U_{a_1} \lvert \psi_0 \rangle  
$$  
and the acceptance probability is  
$$  
\Pr_{\mathcal{A}}[w] = \lVert P_{\mathrm{acc}} \lvert \psi_w \rangle \rVert^2.  
$$

A language $L \subseteq \Sigma^*$ is recognized with bounded error if there exists $\varepsilon < \frac{1}{2}$ such that  
$$  
w \in L \Rightarrow \Pr_{\mathcal{A}}[w] \ge 1 - \varepsilon  
$$  
$$  
w \notin L \Rightarrow \Pr_{\mathcal{A}}[w] \le \varepsilon.  
$$

### Measure-many one-way quantum finite automata

A measure-many one-way quantum finite automaton replaces the single final measurement by intermediate measurements after each symbol. The automaton is specified by projections $P_{\mathrm{acc}}, P_{\mathrm{rej}}, P_{\mathrm{non}}$ satisfying  
$$  
P_{\mathrm{acc}} + P_{\mathrm{rej}} + P_{\mathrm{non}} = I  
$$  
with $P_{\mathrm{non}}$ corresponding to non-halting subspace evolution. After each unitary update, a measurement is applied and the computation halts upon observing acceptance or rejection.

This model strictly increases expressive power over measure-once automata under bounded-error semantics.

### Language classes and hierarchy placement

Let $\mathrm{MO\text{-}QFA}$ and $\mathrm{MM\text{-}QFA}$ denote the classes of languages recognized with bounded error by measure-once and measure-many one-way quantum finite automata.

Known strict containments:  
$$  
\mathrm{MO\text{-}QFA} \subsetneq \mathrm{MM\text{-}QFA} \subsetneq \mathrm{REG}  
$$  
where $\mathrm{REG}$ is the class of regular languages.

The inclusion $\mathrm{MM\text{-}QFA} \subsetneq \mathrm{REG}$ follows from group-theoretic constraints on transition monoids induced by unitarity. In particular, languages whose minimal deterministic automata contain certain non-reversible structures are not quantum-recognizable with bounded error.

### Algebraic and structural constraints

For measure-once automata, the acceptance probability function $f : \Sigma^* \to \mathbb{R}$ satisfies  
$$  
f(w) = \langle \psi_0 \lvert U_w^\dagger P_{\mathrm{acc}} U_w \rvert \psi_0 \rangle  
$$  
with $U_w = U_{a_n} \cdots U_{a_1}$. Such functions are almost periodic with respect to $w$, implying strong regularity constraints.

The syntactic monoid of any language in $\mathrm{MO\text{-}QFA}$ must be a group. Consequently, only group languages are recognizable in this model.

### Closure properties

For bounded-error semantics:
- $\mathrm{MO\text{-}QFA}$ is closed under complement.
- $\mathrm{MO\text{-}QFA}$ is not closed under union or intersection.
- $\mathrm{MM\text{-}QFA}$ is closed under complement.
- $\mathrm{MM\text{-}QFA}$ is not closed under union or intersection.
    

Closure failures follow from interference effects and the impossibility of synchronizing independent quantum evolutions without intermediate measurements.

### Expressive power comparisons

Deterministic finite automata correspond to classical reversible automata when transition functions are bijections. Quantum automata generalize reversible automata by allowing superposition and interference but remain constrained by unitarity.

There exist regular languages recognizable by quantum automata with exponentially fewer states than any deterministic finite automaton, demonstrating succinctness advantages:  
$$  
\exists L \in \mathrm{REG} : \mathrm{size}_{\mathrm{QFA}}(L) = O(n) \land \mathrm{size}_{\mathrm{DFA}}(L) = 2^{\Omega(n)}.  
$$

### Decidability and algorithmic properties

For fixed dimension $d$, emptiness and equivalence problems for measure-once quantum finite automata are decidable by reduction to real algebraic geometry. Without fixed dimension bounds, equivalence becomes undecidable.

Cutpoint languages defined by  
$$  
L_\lambda = { w \in \Sigma^* \mid \Pr_{\mathcal{A}}[w] > \lambda }  
$$  
exhibit undecidable emptiness for arbitrary cutpoints $\lambda \in \mathbb{R}$.

### Complexity-theoretic perspective

Quantum finite automata operate in constant space and linear time with respect to input length. Their power aligns with $\mathrm{BQSPACE}\langle O(1) \rangle$ under one-way input restrictions. No non-regular language is recognizable with bounded error in this regime.

### Logical characterization

Languages recognized by quantum automata correspond to regular languages definable by weighted logical formalisms with complex amplitudes and norm-based acceptance semantics. Connections exist to monadic second-order logic with quantitative extensions.

### Related topics

- Reversible automata
- Probabilistic finite automata
- Two-way quantum finite automata
- Quantum Turing machines
- Weighted automata over semirings
- Quantum complexity classes
- Algebraic automata theory

---

