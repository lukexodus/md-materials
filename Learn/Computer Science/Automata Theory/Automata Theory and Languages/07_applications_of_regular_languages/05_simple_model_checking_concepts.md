## Simple model checking concepts


**Models.** Finite-state transition system as tuple $\mathcal{S}=\langle S,\mathrm{Act},\to, I, AP, L\rangle$ with states $S$, initial set $I\subseteq S$, labeled transition relation $\to \subseteq S\times \mathrm{Act}\times S$, atomic propositions $AP$, labeling $L:S\to 2^{AP}$. Kripke structure is the unlabeled special case with total transition relation and omitted actions.

**Paths.** Infinite path $\pi=s_0s_1\ldots$ with $s_0\in I$ and $s_i\to s_{i+1}$. Trace of $\pi$ is $\mathrm{trace}(\pi)=(L(s_0)L(s_1)\ldots)$ over alphabet $2^{AP}$.

---

### Temporal logics over transition systems

**Linear-time temporal logic (LTL).** Syntax generated from $AP$ using Boolean connectives and temporal operators $\mathbf{X}$, $\mathbf{U}$, $\mathbf{F}$, $\mathbf{G}$. Semantics on infinite paths $\pi$; model satisfaction:
$$\mathcal{S}\models \varphi \Longleftrightarrow \forall \text{ initial path }\pi: \pi\models \varphi.$$
LTL defines $\omega$-regular sets of traces.

**Computation tree logic (CTL).** Branching-time logic with path quantifiers $\mathbf{A},\mathbf{E}$ and temporal operators $\mathbf{X},\mathbf{U},\mathbf{F},\mathbf{G}$ interpreted on states. Satisfaction:
$$\mathcal{S},s\models \mathbf{A}\psi \Longleftrightarrow \forall \pi\text{ from }s: \pi\models \psi.$$

**CTL*** strictly more expressive than both LTL and CTL, combining linear and branching operators.

**Modal $\mu$-calculus.** Fixpoint logic with least $\mu X.\varphi$ and greatest $\nu X.\varphi$ fixpoints, subsuming CTL*. Denotational semantics over $2^S$ with monotone operators and Tarski–Knaster fixpoints.

**Expressiveness relationships.**
$$\text{LTL}\subsetneq \text{CTL}^* \qquad \text{CTL}\subsetneq \text{CTL}^*$$
LTL and CTL are incomparable; $\mu$-calculus is expressively equivalent to CTL*.

---

### Automata-theoretic model checking

**ω-automata.** Büchi automaton $\mathcal{A}=\langle Q,\Sigma,\delta,Q_0,F\rangle$ accepts infinite word $\alpha$ if a run visits $F$ infinitely often. Parity, Rabin, Streett acceptance provide equivalent expressive power ($\omega$-regular).

**LTL-to-automata translation.** For LTL sentence $\varphi$, construct Büchi automaton $\mathcal{A}*\varphi$ over alphabet $2^{AP}$ such that
$$L*\omega(\mathcal{A}_\varphi)={\mathrm{traces}\mid \text{trace satisfies }\varphi}.$$

**Product construction.** Model checking reduces to emptiness:
1. Construct $\mathcal{A}_{\neg\varphi}$ for $\neg\varphi$.
2. Build synchronous product $K\otimes \mathcal{A}_{\neg\varphi}$ where $K$ is the Kripke structure viewed as Büchi automaton.
3. Check language emptiness of the product.

**Emptiness test.** For Büchi automaton, nonemptiness iff reachable accepting strongly connected component exists. Linear-time graph search in $O(|Q|+|\delta|)$.

**Correctness argument.** Nonemptiness of the product corresponds to existence of path with trace violating $\varphi$; counterexample is accepting cycle reachable from an initial product state.

---

### Branching-time model checking by fixpoints

**CTL algorithm.** Structural recursion with least and greatest fixpoints over $2^S$:
$$\llbracket \mathbf{E}[\varphi \mathbf{U}\psi]\rrbracket=\mu X.(\llbracket \psi\rrbracket \cup (\llbracket \varphi\rrbracket \cap \mathrm{Pre}*\exists(X)))$$
with predecessor operator $\mathrm{Pre}*\exists(X)={s\mid \exists s': s\to s'\wedge s'\in X}$.

**Complexity.**

* CTL model checking: $O(|\varphi|\cdot(|S|+|\to|))$.
* LTL model checking (explicit): PSPACE-complete in $|\varphi|$, polynomial in $|S|$, typically $O(2^{|\varphi|} \cdot (|S|+|\to|))$ via automata blow-up.
* CTL* model checking: PSPACE-complete.

---

### Bisimulation and behavioral equivalence

**Bisimulation.** Relation $R\subseteq S\times S$ satisfying label agreement and back-and-forth step correspondence. Bisimulation-invariant logics: CTL*, $\mu$-calculus. Quotienting by maximal bisimulation preserves satisfaction of these logics and yields reduced models.

**Simulation preorders** approximate inclusion of behaviors; used for abstraction refinement.

---

### Abstraction, refinement, and counterexamples

**Abstract interpretation for model checking.** Galois connection $\alpha:2^S\leftrightarrows 2^{\hat S}:\gamma$; soundness requires over-approximation of reachable behaviors.

**CEGAR.** Counterexample-guided abstraction refinement iterates:
1. Abstract model violates property via counterexample.
2. Check concretizability; if spurious, refine abstraction via interpolants or predicate discovery.

---

### Fairness constraints

**Fairness assumptions** restrict admissible paths (justice, compassion). Acceptance conditions in $\omega$-automata encode fairness; generalized Büchi or Rabin conditions capture multiple fairness constraints. Model checking under fairness reduces to acceptance with modified product.

---

### Symbolic and bounded model checking

**Symbolic representations.** Use Boolean encodings of sets and relations:

* BDD-based fixpoint computation for CTL and $\mu$-calculus.
* Symbolic reachability via image and preimage operations.

**Bounded model checking (BMC).** SAT/SMT encoding of counterexample existence of length $k$:
$$\exists s_0,\ldots,s_k: \text{Init}(s_0)\wedge \bigwedge_{i<k} T(s_i,s_{i+1})\wedge \neg \varphi(s_0,\ldots,s_k).$$
Incremental $k$ increases; completeness requires diameter bounds or induction.

---

### State-space reduction

**Partial order reduction.** Exploits independence of concurrent actions using ample sets; preserves LTL\textbackslash X properties.

**Symmetry reduction.** Quotients by permutation group actions on isomorphic components.

**Cone-of-influence and slicing.** Reduce state variables irrelevant to property.

**Compositional reasoning.** Assume–guarantee rules using trace inclusion and simulation.

---

### Decidability and complexity boundaries

* Finite-state model checking for $\omega$-regular properties is decidable.
* Pushdown systems: model checking for LTL and $\mu$-calculus remains decidable with higher complexity; reachability becomes EXPTIME-complete.
* General Turing-powerful transition systems: LTL and CTL* model checking undecidable by reduction from halting; safety properties undecidable in general.

---

### Related topics

* ω-regular languages and Büchi–Elgot–Trakhtenbrot theorem
* Tree automata and branching-time properties
* Alternating automata and parity games
* Satisfiability of temporal logics
* Model checking for timed and probabilistic automata

---

