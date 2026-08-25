## Categorial Grammars


### Formal System

A categorial grammar is a deductive system generating a language by typing strings with syntactic categories via logical inference. Fix a finite set of _atomic categories_ $\mathcal{A}$ and define the set of _categories_ inductively.

In the classical Ajdukiewicz–Bar-Hillel system:

$$  
\mathcal{C} ::= a \mid \mathcal{C} / \mathcal{C} \mid \mathcal{C} \backslash \mathcal{C} \quad a \in \mathcal{A}  
$$

A _lexicon_ is a finite relation

$$  
\mathcal{L} \subseteq \Sigma \times \mathcal{C}  
$$

assigning categories to terminal symbols.

---

### Derivations and Recognition

A string $w = w_1 \cdots w_n$ is grammatical with respect to distinguished category $S$ if there exist categories $C_1, \dots, C_n$ such that $(w_i, C_i) \in \mathcal{L}$ and

$$  
C_1, \dots, C_n \vdash S  
$$

Derivability is defined by inference rules:

$$  
\frac{\Gamma \vdash A \quad \Delta \vdash A \backslash B}{\Gamma , \Delta \vdash B}  
\qquad  
\frac{\Gamma \vdash B / A \quad \Delta \vdash A}{\Gamma , \Delta \vdash B}  
$$

with $\Gamma, \Delta$ sequences of categories.

---

### Logical Interpretation

Categorial grammars correspond to fragments of substructural logic:
- Associative Lambek calculus $L$
- Non-commutative intuitionistic linear logic without structural rules
    

Sequents $\Gamma \vdash A$ are interpreted as typing judgments.

---

### Weak Generative Capacity

- Classical categorial grammars generate exactly the class of context-free languages.
- For every context-free grammar $G$, there exists a categorial grammar $C$ such that:
    

$$  
L G = L C  
$$
- The equivalence holds under fixed target category $S$.

---

### Normal Forms and Elimination

Derivations admit normalization via cut elimination:

$$  
\Gamma \vdash A \quad A , \Delta \vdash B \implies \Gamma , \Delta \vdash B  
$$

Elimination ensures:
- Subformula property
- Polynomial bounds on derivation depth for fixed lexicon

---

### Parsing Complexity

- Membership is decidable in $O n^3$ time
- Parsing corresponds to proof search in Lambek calculus
- CYK-style dynamic programming applies after category normalization

---

### Extensions and Increased Expressiveness

#### Product and Unit

Introduce product $\cdot$ and unit $1$:

$$  
\mathcal{C} ::= a \mid \mathcal{C} / \mathcal{C} \mid \mathcal{C} \backslash \mathcal{C} \mid \mathcal{C} \cdot \mathcal{C} \mid 1  
$$

Generative capacity remains context-free.

---

#### Multimodal Categorial Grammars

Augment categories with modes controlling structural rules:

$$  
A \circ_i B  
$$

Permits limited permutation and associativity control.

---

### Relationship to Automata

- Classical categorial grammars correspond to pushdown automata
- Parsing simulates PDA stack discipline via residuation
- Derivations correspond to PDA accepting computations

---

### Decidability and Undecidability

- Membership is decidable
- Grammar equivalence is undecidable
- Lexical ambiguity leads to NP-complete parsing under unrestricted polymorphism

---

### Linear Logic Variants

- Non-associative Lambek calculus increases expressive precision
- Adding exponentials yields weakly context-sensitive languages
- Proof nets provide canonical representations of derivations

---

### Algebraic Semantics

Categories form a residuated monoid:

$$  
A \cdot B \leq C \iff B \leq A \backslash C \iff A \leq C / B  
$$

Semantic interpretation uses partially ordered monoids.

---

### Relationship to Formal Language Hierarchy

- Classical categorial grammars: $\mathsf{CFL}$
- With controlled structural rules: mildly context-sensitive
- With unrestricted exponentials: recursively enumerable

---

### Verification and Type-Theoretic Connections

- Types correspond to resources
- Parsing corresponds to type inhabitation
- Grammar recognition reduces to provability

---

### Related Topics

- Lambek calculus
- Linear logic
- Combinatory categorial grammar
- Type-logical grammar
- Mildly context-sensitive languages
- Pushdown automata
- Proof nets

---

