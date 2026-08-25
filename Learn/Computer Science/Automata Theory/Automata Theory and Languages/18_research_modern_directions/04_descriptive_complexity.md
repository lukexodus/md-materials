## Descriptive complexity


### Core principle

Descriptive complexity characterizes complexity classes as sets of finite structures definable by logical formalisms. For a vocabulary $\tau$ and a class of finite $\tau$-structures $\mathcal{C}$, a language $L \subseteq {0,1}^*$ belongs to a complexity class $\mathsf{C}$ iff there exists a logic $\mathcal{L}$ such that $L$ is the set of encodings of structures satisfying some sentence $\varphi \in \mathcal{L}$, and $\mathcal{L}$ captures $\mathsf{C}$ over finite structures.

Formally, a logic $\mathcal{L}$ captures a complexity class $\mathsf{C}$ if for every finite vocabulary $\tau$:  
$$  
{ \mathrm{Str} \mid \mathrm{Str} \models \varphi } = \mathsf{C}_\tau  
$$  
where $\mathsf{C}_\tau$ is the class of $\tau$-structures decidable in $\mathsf{C}$, and $\varphi$ ranges over $\mathcal{L}$-sentences over $\tau$.

---

### Structures, encodings, and uniformity

Finite structures are relational, with universe ${0,\dots,n-1}$. Inputs are viewed as ordered structures via a built-in linear order $<$ or successor $\mathrm{Succ}$. The presence or absence of order determines uniformity:
- **Ordered structures:** logical expressiveness corresponds to uniform complexity classes.
- **Unordered structures:** expressiveness often collapses to very weak classes due to symmetry.
    

Encoding invariance requires that definability is preserved under isomorphism of structures.

---

### First-order logic and constant-depth computation

First-order logic $\mathrm{FO}$ over ordered finite structures captures $\mathsf{AC}^0$.

Key correspondences:  
$$  
\mathrm{FO}[<] = \mathsf{AC}^0  
$$

Properties:
- No ability to define parity or majority.
- Quantifier depth corresponds to circuit depth.
- Variable reuse bounds expressive power.
    

Lower bounds:
- Parity $\notin \mathrm{FO}[<]$
- Majority $\notin \mathrm{FO}[<]$
    

Proof techniques rely on Ehrenfeucht–Fraïssé games and locality theorems.

---

### Extensions of first-order logic

#### $\mathrm{FO} + \mathrm{MOD}_m$

First-order logic with modulo-$m$ counting quantifiers captures $\mathsf{AC}^0[\mathrm{MOD}\ m]$.

Separation results:  
$$  
\mathrm{FO} \subsetneq \mathrm{FO} + \mathrm{MOD}_m  
$$  
for any $m \ge 2$.

---

#### $\mathrm{FO} + \mathrm{TC}$

First-order logic with transitive closure operator defines reachability.

Over ordered structures:  
$$  
\mathrm{FO} + \mathrm{TC} = \mathsf{NL}  
$$

Deterministic transitive closure corresponds to $\mathsf{L}$.

---

#### $\mathrm{FO} + \mathrm{LFP}$

Least fixed-point logic extends $\mathrm{FO}$ with inductive definitions.

Semantics: for a monotone operator $F : \mathcal{P}(A^k) \to \mathcal{P}(A^k)$, $\mathrm{LFP}$ defines  
$$  
\mathrm{lfp}(F) = \bigcap { X \mid F(X) \subseteq X }  
$$

Over ordered finite structures:  
$$  
\mathrm{FO} + \mathrm{LFP} = \mathsf{P}  
$$

This is the Immerman–Vardi theorem.

---

### Fixed-point logics and polynomial time

- $\mathrm{LFP}$ captures $\mathsf{P}$ only with built-in order.
- Without order, $\mathrm{LFP}$ is strictly weaker.
    

Inflationary fixed-point logic $\mathrm{IFP}$ is equivalent to $\mathrm{LFP}$ on finite structures.

---

### Second-order logic and higher complexity

#### Existential second-order logic

Existential second-order logic $\exists\mathrm{SO}$ allows quantification over relations.

Fagin’s theorem:  
$$  
\exists\mathrm{SO} = \mathsf{NP}  
$$

This equivalence holds over finite ordered structures.

Reductions correspond to logical interpretations.

---

#### Full second-order logic

Full second-order logic captures $\mathsf{PH}$ when stratified by quantifier alternation.

Hierarchy:  
$$  
\Sigma_k^1 \leftrightarrow \Sigma_k^p  
$$

Strictness depends on the polynomial hierarchy not collapsing.

---

### Counting logics

Counting quantifiers extend expressiveness beyond $\mathrm{FO}$.
- $\mathrm{FOC}$: first-order with counting.
- $\mathrm{C}^k$: $k$-variable counting logic.
    

Connections:
- $\mathrm{C}^k$ approximates $\mathsf{PTIME}$ properties.
- Weisfeiler–Leman refinement corresponds to $\mathrm{C}^k$ equivalence.
    

Applications:
- Graph isomorphism heuristics
- Inexpressibility results for $\mathsf{P}$

---

### Inexpressibility and lower bounds

Descriptive complexity provides logic-based lower bounds:
- If a property is not definable in $\mathcal{L}$, then it is not in the corresponding complexity class.
- Non-definability proofs use:
    - Ehrenfeucht–Fraïssé games
    - Pebble games
    - Locality theorems
    - Homomorphism preservation
        

Example:  
Reachability is not definable in $\mathrm{FO}$, hence $\mathsf{REACH} \notin \mathsf{AC}^0$.

---

### Capturing $\mathsf{P}$ without order

No known logic captures $\mathsf{P}$ over unordered structures.

Candidates:
- $\mathrm{FO} + \mathrm{LFP} + \mathrm{COUNT}$
- Choiceless polynomial time with counting
    

This problem is equivalent to finding a logic invariant under isomorphism capturing $\mathsf{P}$.

---

### Reductions and interpretations

Logical reductions are given by interpretations:

A $k$-ary interpretation $\mathcal{I}$ maps structures $\mathcal{A}$ to $\mathcal{B}$ via $\mathrm{FO}$-definable relations.

Completeness:  
A property $P$ is $\mathsf{C}$-complete if every $\mathsf{C}$-property reduces to $P$ via interpretations definable in the capturing logic.

---

### Automata-theoretic connections

- $\mathrm{FO}[<]$ corresponds to star-free regular languages.
- $\mathrm{MSO}[<]$ corresponds to regular languages via Büchi–Elgot–Trakhtenbrot.
- Fixed-point logics correspond to alternating automata with bounded resources.

---

### Connections to verification and semantics

- $\mu$-calculus is equivalent to modal fixed-point logic.
- Model checking complexity is characterized descriptively.
- Temporal logics embed into fixed-point logics.

---

### Limitations and open separations

- $\mathrm{FO} + \mathrm{LFP}$ vs $\mathrm{FO} + \mathrm{PTC}$ over unordered structures unresolved.
- $\mathsf{P}$ vs $\mathsf{NP}$ corresponds to $\mathrm{FO} + \mathrm{LFP}$ vs $\exists\mathrm{SO}$ separation.
- Counting vs fixed-point expressiveness unresolved in general.

---

### Related topics

- Finite model theory
- Fixed-point logics
- Monadic second-order logic
- Circuit complexity
- Logic and automata correspondence
- Graph isomorphism
- Polynomial hierarchy

---

