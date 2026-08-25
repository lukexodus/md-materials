## Natural language processing syntax models


### Formal language perspective

Syntactic models in natural language processing are formal devices defining a language $L \subseteq \Sigma^*$ together with structured descriptions of derivations. Central concerns are weak generative capacity, strong generative capacity, parsing complexity, and logical definability.

Natural language syntax is not adequately captured by regular languages and is widely believed to exceed context-free expressiveness while remaining below full context-sensitive power.

---

### Context-free grammars

A context-free grammar is a tuple

$$  
G = \langle V, \Sigma, P, S \rangle  
$$

with productions $A \to \alpha$, $A \in V$, $\alpha \in (V \cup \Sigma)^*$.

CFGs define the class $\text{CFL}$.

Key properties:
- Membership decidable in $O n^3$ time
- Emptiness and finiteness decidable
- Equivalence and inclusion undecidable
- Closure under union, concatenation, star
- Not closed under intersection or complement
    

CFGs capture hierarchical constituency but fail on cross-serial dependencies and multiple agreement phenomena.

---

### Parse trees and strong generative capacity

A CFG induces a mapping

$$  
\tau : \Sigma^* \to \mathcal{T}  
$$

from strings to parse trees.

Two grammars may be weakly equivalent while inducing distinct tree languages. Strong generative capacity compares sets of trees rather than strings.

Tree languages of CFGs correspond to regular tree languages.

---

### Dependency grammars

Dependency structures are directed graphs

$$  
D = \langle V, E, r \rangle  
$$

over word positions, forming a rooted tree.

Projective dependency grammars correspond to CFGs in weak generative power.

Non-projective dependencies exceed $\text{CFL}$ and require mildly context-sensitive formalisms.

---

### Tree adjoining grammars

A tree adjoining grammar consists of:
- Initial trees
- Auxiliary trees
- Adjunction operation
    

TAG languages satisfy

$$  
\text{CFL} \subsetneq \text{TAG} \subsetneq \text{CSL}  
$$

Properties:
- Mildly context-sensitive
- Polynomial-time parsing $O n^6$
- Can generate cross-serial dependencies
- Constant growth property
    

TAGs are equivalent in weak power to linear indexed grammars.

---

### Combinatory categorial grammar

CCG assigns categories as types and uses combinatory rules.

Lexical categories are functions:

$$  
A / B,\ A \backslash B  
$$

Expressive power:

$$  
\text{CCG} \equiv \text{TAG}  
$$

under appropriate constraints.

Parsing complexity is polynomial for restricted rule sets but becomes NP-complete with unrestricted composition.

---

### Linear context-free rewriting systems

An LCFRS is defined by nonterminals with arity $k$ and productions rewriting tuples of strings.

Formally, productions define linear functions

$$  
f : (\Sigma^*)^m \to (\Sigma^*)^k  
$$

LCFRS properties:
- Strictly more expressive than CFGs
- Includes TAG, CCG, and MCFGs
- Parsing complexity $O n^{\omega k}$
- Closed under intersection with regular languages
    

LCFRS capture discontinuous constituents.

---

### Mildly context-sensitive languages

A language class $\mathcal{L}$ is mildly context-sensitive if:
- $\text{CFL} \subsetneq \mathcal{L} \subsetneq \text{CSL}$
- Polynomial-time parsable
- Semilinear Parikh images
- Bounded fan-out
    

TAG, LCFRS, and MCFG satisfy these constraints.

---

### Logical characterizations

CFG-definable languages satisfy:

$$  
\text{CFL} \subseteq \text{MSO}_{\text{tree}}  
$$

Mildly context-sensitive languages correspond to fragments of higher-order logic or MSO with additional predicates.

Dependency grammars correspond to MSO-definable graph languages under projectivity constraints.

---

### Parsing as automata recognition

Parsing corresponds to recognition by pushdown or higher-order automata.
- CFG parsing via pushdown automata
- TAG parsing via embedded pushdown automata
- LCFRS via multi-stack automata
    

Chart parsing algorithms implement dynamic programming over derivation forests.

---

### Probabilistic and weighted syntax models

Probabilistic CFGs define distributions

$$  
P : \Sigma^* \to \mathbb{R}_{\ge 0}  
$$

with normalization over derivations.

Weighted TAGs and LCFRS generalize PCFGs.

Inference problems include:
- Most probable parse
- Partition function computation
- Inside-outside algorithms
    

These correspond to evaluation in weighted automata over semirings.

---

### Learnability and identifiability

CFGs are not identifiable in the limit from positive data.

Subclasses such as deterministic CFGs and certain LCFRS fragments admit polynomial-time learning under structural constraints.

---

### Verification and type-theoretic connections

Syntax models correspond to:
- Type-logical grammars
- Lambda calculus derivations
- Proof nets
    

Parsing corresponds to proof search under resource sensitivity.

---

### Related topics

- Pushdown automata
- Mildly context-sensitive grammars
- Weighted automata
- Tree languages
- Monadic second-order logic
- Parsing complexity

---

