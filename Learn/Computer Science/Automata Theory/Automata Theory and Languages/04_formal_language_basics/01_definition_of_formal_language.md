## Definition of Formal Language


Let $\Sigma$ be a finite, nonempty alphabet. The set of all finite strings over $\Sigma$ is denoted $\Sigma^*$, equipped with concatenation as a binary operation and $\varepsilon$ as the identity element, forming the free monoid over $\Sigma$.

A **formal language** $L$ over $\Sigma$ is defined as an arbitrary subset of $\Sigma^*$:
$$
L \subseteq \Sigma^*
$$

No syntactic, semantic, or computational constraints are inherent in the definition. All structure arises exclusively from the formal mechanism used to specify, generate, recognize, or characterize $L$.

### Algebraic Properties

The universe of all formal languages over $\Sigma$ is the power set $\mathcal{P}(\Sigma^*)$, which forms a complete Boolean algebra under the operations:
$$
L_1 \cup L_2,\quad L_1 \cap L_2,\quad \overline{L} = \Sigma^* \setminus L
$$

Language concatenation is defined as:
$$
L_1 L_2 = { xy \mid x \in L_1 \land y \in L_2 }
$$

The Kleene star operation is defined by:
$$
L^* = \bigcup_{i \ge 0} L^i
$$
with $L^0 = {\varepsilon}$.

### Specification and Characterization

A formal language may be specified through multiple mathematically equivalent or inequivalent formalisms:

* **Generative**: grammars $G$ such that $L = L(G)$
* **Recognitive**: abstract machines $M$ such that $L = L(M)$
* **Logical**: formulas $\varphi$ over string structures such that
  $$
  L = { w \in \Sigma^* \mid w \models \varphi }
  $$
* **Algorithmic**: characteristic functions
  $$
  \chi_L : \Sigma^* \to {0,1}
  $$

Equivalence between these characterizations defines major language classes.

### Hierarchical Classification

Restrictions on the expressive power of the defining mechanism induce strict containment hierarchies among language classes:
$$
\text{REG} \subsetneq \text{CFL} \subsetneq \text{CSL} \subsetneq \text{RE}
$$

Each class corresponds to a canonical computational model and admits alternative algebraic and logical characterizations.

### Decidability Framework

Given a language $L \subseteq \Sigma^*$, fundamental decision problems include:

* Membership: $w \in L$
* Emptiness: $L = \varnothing$
* Finiteness: $|L| < \infty$
* Equivalence: $L_1 = L_2$

Decidability and complexity of these problems depend on the formalism defining $L$.

### Logical and Descriptive Characterizations

Formal languages can be defined via logical theories over word models, including:

* First-order logic over $\langle \mathbb{N}, < \rangle$
* Monadic second-order logic
* Fixed-point and transitive closure logics

Definability in these logics corresponds to automaton-recognizable language classes.

### Complexity-Theoretic Interpretation

If membership in $L$ is decidable, the resource bounds of deciding $\chi_L$ place $L$ within time- and space-bounded complexity classes, including $\text{AC}^0$, $\text{NC}$, $\text{P}$, and $\text{PSPACE}$.

### Expressiveness and Closure

Core theoretical concerns include:

* Closure properties under Boolean and algebraic operations
* Expressive limitations of restricted models
* Separation results via pumping arguments, diagonalization, and reductions

### Related Topics

* Regular expressions
* Grammars and derivation systems
* Automata models
* Computability and decidability
* Descriptive complexity
* Algebraic language theory
* Language containment and equivalence


---

