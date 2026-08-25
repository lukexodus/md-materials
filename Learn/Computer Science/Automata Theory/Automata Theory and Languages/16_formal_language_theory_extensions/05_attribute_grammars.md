## Attribute Grammars


### Formal Model

An attribute grammar is a tuple  
$$  
G = \langle N, \Sigma, P, S, A, R \rangle  
$$  
where:
- $\langle N, \Sigma, P, S \rangle$ is a context-free grammar
- $A = A^S \cup A^I$ assigns to each $X \in N$ a finite set of **synthesized attributes** $A^S X$ and **inherited attributes** $A^I X$
- $R$ is a finite set of semantic rules defining attribute values
    

For each production  
$$  
p : X \to Y_1 Y_2 \dots Y_k  
$$  
attributes are associated with the nodes of the derivation tree corresponding to $X,Y_1,\dots,Y_k$.

---

### Attribute Occurrences and Domains

Each attribute $a \in A X$ has a domain $D_a$, typically a finite or computable set.

An **attribute occurrence** is denoted $a X_i$, referring to attribute $a$ at the node labeled $X_i$ in a derivation tree.

Semantic rules define equations of the form:  
$$  
a X_i := f b_1 Y_{j_1}, \dots, b_m Y_{j_m}  
$$  
where $f$ is a computable function.

---

### Dependency Graph

For a fixed derivation tree $T$, define the **attribute dependency graph**:  
$$  
D_T = \langle V_T, E_T \rangle  
$$  
where:
- $V_T$ consists of all attribute occurrences in $T$
- $(u,v) \in E_T$ iff the semantic rule defining $v$ depends on $u$
    

An attribute grammar is **well-defined** iff for all derivation trees $T$, $D_T$ is acyclic.

---

### Evaluation Semantics

Given acyclicity, attribute values are determined by a topological order of $D_T$.

Evaluation strategies:
- **Static scheduling:** order depends only on grammar
- **Dynamic scheduling:** order computed per tree
- **Demand-driven:** values computed lazily
    

Attribute grammars generalize syntax-directed definitions by allowing non-local dependencies.

---

### S-Attributed Grammars

A grammar is **S-attributed** iff:  
$$  
\forall X \in N : A^I X = \varnothing  
$$

Properties:
- All attributes are synthesized
- Evaluation proceeds bottom-up
- Directly implementable via postorder traversal
- Compatible with LR parsing
    

Expressive power remains within context-free derivations augmented with computations.

---

### L-Attributed Grammars

A grammar is **L-attributed** iff for each production  
$$  
X \to Y_1 \dots Y_k  
$$  
every inherited attribute of $Y_i$ depends only on:

$$  
A^S Y_1, \dots, A^S Y_{i-1}, ; A^I X  
$$

Properties:
- Left-to-right evaluation
- Compatible with LL parsing
- Strictly more expressive than S-attributed grammars

---

### Expressive Power

Attribute grammars define **tree transductions**:  
$$  
\tau : \mathrm{Deriv} G \to D  
$$

Relations to known models:
- S-attributed grammars correspond to bottom-up tree transducers
- L-attributed grammars correspond to top-down tree transducers with lookahead
- General attribute grammars correspond to macro tree transducers
    

They can define non-context-free dependencies while preserving context-free syntax.

---

### Decidability Results

Undecidable problems:
- Whether an attribute grammar is well-defined
- Whether all dependency graphs are acyclic
- Equivalence of attribute grammars
    

Decidable restrictions:
- S-attributed and L-attributed membership
- Local dependency checks under fixed evaluation order

---

### Circular Attribute Grammars

An attribute grammar is **circular** if some $D_T$ contains a cycle.

Variants:
- **Circular but consistent:** cycles converge to a fixed point
- **General circular:** undefined semantics
    

Fixed-point semantics:  
$$  
a := F a  
$$  
evaluated over complete partial orders using least fixed points.

---

### Attribute Grammars and Logic

Attribute grammars correspond to logical formalisms:
- Monadic second-order logic over trees with interpretations
- First-order logic with recursive definitions
- Typed λ-calculus with structured recursion
    

They serve as a bridge between parsing theory and formal semantics.

---

### Complexity of Attribute Evaluation

Given a fixed derivation tree $T$:
- Evaluation time is $O |V_T| + |E_T|$
- Space proportional to number of attribute occurrences
    

For unrestricted grammars, dependency graph construction may be exponential in grammar size.

---

### Transformations and Normal Forms

Known transformations:
- Elimination of inherited attributes via tree duplication
- Conversion to equivalent S-attributed grammar with exponential blowup
- Scheduling normalization for fixed traversal orders
    

No general polynomial-size normal form exists for unrestricted attribute grammars.

---

### Applications in Formal Language Theory

- Syntax-directed translation
- Formal specification of semantics
- Static analysis and type checking
- Compiler correctness proofs
    

Attribute grammars formalize semantic computation over context-free structures without extending the underlying language class.

---

### Related Topics

- Syntax-directed definitions
- Tree transducers
- Macro tree transducers
- Monadic second-order logic on trees
- Descriptive complexity
- Compiler semantics
- Context-free grammars

---

