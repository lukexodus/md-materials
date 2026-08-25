## Artificial Intelligence Planning


### Formal Models

A **planning domain** is specified as a tuple  
$$  
\mathcal{D} = \langle \Sigma, S, A, \gamma \rangle  
$$  
where $\Sigma$ is a finite alphabet encoding propositional symbols, $S \subseteq 2^\Sigma$ is the set of states, $A$ is a finite set of actions, and $\gamma : S \times A \to S \cup {\bot}$ is a (partial) transition function. A **planning instance** augments $\mathcal{D}$ with an initial state $s_0 \in S$ and a goal specification $G \subseteq S$ or a goal formula $\varphi_G$ over $\Sigma$.

A **plan** is a finite word $w \in A^*$ such that the induced transition sequence  
$$  
s_0 \xrightarrow{a_1} s_1 \xrightarrow{a_2} \dots \xrightarrow{a_n} s_n  
$$  
is well-defined and $s_n \in G$ or $s_n \models \varphi_G$.

Classical planning assumes deterministic $\gamma$, complete observability, and finite $S$. Variants relax these assumptions.

---

### Planning as Automata and Language Acceptance

Define a labeled transition system  
$$  
\mathcal{T} = \langle S, A, \delta, s_0 \rangle  
$$  
with $\delta = \gamma$. The set of valid plans is the language  
$$  
L_{\text{plan}} = { w \in A^* \mid \delta^* s_0, w \in G }  
$$  
which is a regular language if and only if $S$ is finite and actions are propositional. Goal reachability corresponds to reachability in a finite automaton. Planning reduces to emptiness of $L_{\text{plan}} \cap L_G$.

Temporal planning with liveness or fairness constraints yields $\omega$-languages and Büchi or parity automata.

---

### STRIPS and Propositional Planning

A STRIPS action $a \in A$ is a triple  
$$  
a = \langle \text{pre} a, \text{add} a, \text{del} a \rangle  
$$  
with $\text{pre} a, \text{add} a, \text{del} a \subseteq \Sigma$.

State transition is defined by  
$$  
\gamma s, a =  
\begin{cases}  
s \setminus \text{del} a \cup \text{add} a & \text{if } \text{pre} a \subseteq s \  
\bot & \text{otherwise}  
\end{cases}  
$$

Propositional STRIPS planning is PSPACE-complete via reduction from QBF. Bounded-length planning is NP-complete.

---

### Planning and Logic

Classical planning corresponds to satisfiability in propositional dynamic logic fragments. A plan $w = a_1 \dots a_n$ satisfies  
$$  
\langle a_1 \rangle \langle a_2 \rangle \dots \langle a_n \rangle \varphi_G  
$$

First-order planning induces infinite-state transition systems; reachability is undecidable in general. Restrictions such as monadic predicates or bounded arity recover decidability.

---

### Complexity and Hierarchies

Let $\text{PLAN}$ denote classical propositional planning.

$$  
\text{PLAN} \in \text{PSPACE}, \quad \text{PLAN} \text{ is PSPACE-complete}  
$$

Variants:  
$$  
\text{Bounded PLAN} \in \text{NP}, \quad \text{Bounded PLAN} \text{ is NP-complete}  
$$  
$$  
\text{Conditional PLAN} \text{ is EXPTIME-complete}  
$$  
$$  
\text{Partial-Observation PLAN} \text{ is 2EXPTIME-complete}  
$$

Planning with costs and optimization yields decision problems complete for $\text{P}^{\text{NP}}$ or higher.

---

### Reductions and Decidability

Planning reduces to:  
$$  
\text{Reachability in finite transition systems}  
$$  
$$  
\text{SAT and QBF}  
$$  
$$  
\text{CTL or LTL model checking}  
$$

Conversely, reachability and model checking reduce to planning via encoding system transitions as actions. Infinite-horizon planning with unrestricted function symbols is undecidable by reduction from the halting problem.

---

### Normal Forms and Transformations

Any propositional planning instance can be transformed into:
- Unary-effect actions
- Binary preconditions
- Delete-free form via compilation with auxiliary propositions
    

Such transformations preserve plan existence with polynomial or exponential blowup, depending on restrictions.

---

### Planning Graphs and Fixpoint Semantics

Planning graphs define a monotone sequence  
$$  
G_0 \subseteq G_1 \subseteq \dots  
$$  
approximating reachable states. Convergence corresponds to a least fixpoint in the powerset lattice of propositions. Non-reachability is certified by fixpoint stabilization without goal inclusion.

---

### Temporal and Infinite-Horizon Planning

Temporal planning introduces durative actions and constraints over $\mathbb{R}_{\ge 0}$. Infinite-horizon planning with recurring goals corresponds to Büchi acceptance:  
$$  
\exists w \in A^\omega \text{ such that } \inf s_i \models \varphi_G  
$$

Decidability depends on whether the induced transition system is finite or well-structured.

---

### Verification and Synthesis Perspective

Planning is equivalent to controller synthesis in deterministic transition systems. Reactive planning corresponds to strategy synthesis in games:  
$$  
\mathcal{G} = \langle S, A_{\text{env}}, A_{\text{sys}}, \delta \rangle  
$$

Winning strategies correspond to plans under adversarial nondeterminism. Complexity aligns with automata-theoretic synthesis bounds.

---

### Related Topics

Finite automata  
Pushdown systems  
Model checking  
Temporal logic  
Program synthesis  
Game semantics  
Reactive systems  
Well-structured transition systems

---

