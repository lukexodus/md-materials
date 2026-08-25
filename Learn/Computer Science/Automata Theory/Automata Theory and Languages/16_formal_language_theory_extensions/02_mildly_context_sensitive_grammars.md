## Mildly Context-Sensitive Grammars


### Informal Characterization via Formal Criteria

A grammar formalism is **mildly context-sensitive** if the class of languages it generates satisfies the following constraints:  
$$  
\text{properly contains } \mathrm{CFL}  
$$  
$$  
\text{is strictly contained in } \mathrm{CSL}  
$$  
$$  
\text{is closed under intersection with regular languages}  
$$  
$$  
\text{admits polynomial-time parsing}  
$$  
$$  
\text{supports limited cross-serial and multiple agreement dependencies}  
$$

These criteria isolate language classes sufficient to model natural language syntax while avoiding the full expressive power and computational cost of general context-sensitive grammars.

### Formal Language-Theoretic Position

Let $\mathrm{MCS}$ denote a generic mildly context-sensitive class. Then:  
$$  
\mathrm{CFL} \subsetneq \mathrm{MCS} \subsetneq \mathrm{CSL}  
$$

Containment in $\mathrm{CSL}$ follows from linear bounded automaton simulations of derivations. Strictness on both sides is witnessed by canonical separation languages such as:  
$$  
{ a^n b^n c^n \mid n \ge 1 } \in \mathrm{MCS} \setminus \mathrm{CFL}  
$$  
$$  
{ ww \mid w \in \Sigma^* } \notin \mathrm{MCS}  
$$

### Linear Growth and Constant Growth Property

Mildly context-sensitive languages satisfy the **constant growth property**: there exists a finite set $D \subset \mathbb{N}$ such that for any sufficiently long string $w \in L$, there exists $w' \in L$ with:  
$$  
|w| - |w'| \in D  
$$

This excludes languages with exponential copying or unbounded duplication, ruling out typical $\mathrm{CSL}$-complete constructions.

### Tree Adjoining Grammars

A **Tree Adjoining Grammar** is defined as:  
$$  
\mathrm{TAG} = \langle \Sigma, N, I, A, S \rangle  
$$  
where $I$ is a finite set of initial trees and $A$ a finite set of auxiliary trees with distinguished foot nodes.

Derivations are defined via substitution and adjunction operations.

Expressive characterization:  
$$  
\mathrm{CFL} \subsetneq \mathrm{TAG} \subsetneq \mathrm{CSL}  
$$

TAG languages generate exactly the class of **tree-adjoining languages**, forming a canonical example of mild context-sensitivity.

### Linear Indexed Grammars

A **Linear Indexed Grammar** restricts indexed grammars such that each production introduces at most one index symbol.

The resulting class satisfies:  
$$  
\mathrm{LIG} = \mathrm{TAG}  
$$

This equivalence is established via mutual simulation of index passing and adjunction.

### Combinatory Categorial Grammars

A **Combinatory Categorial Grammar** with bounded degree restricts combinatory rules to finite composition depth.

Bounded CCGs generate exactly the TAG languages:  
$$  
\mathrm{CCG}_{\mathrm{bounded}} = \mathrm{TAG}  
$$

Unbounded CCGs exceed mild context-sensitivity.

### Multiple Context-Free Grammars

A **Multiple Context-Free Grammar** generalizes CFGs by allowing nonterminals to derive tuples of strings:  
$$  
A \Rightarrow \langle w_1, \dots, w_k \rangle  
$$

Productions are linear and non-erasing. The fan-out $k$ is bounded.

The generated languages satisfy:  
$$  
\mathrm{TAG} \subsetneq \mathrm{MCFL} \subsetneq \mathrm{CSL}  
$$

### Equivalence with Automata Models

Mildly context-sensitive grammars admit equivalent automaton models:  
$$  
\mathrm{MCFL} = \text{languages of linear context-free rewriting systems}  
$$  
$$  
\mathrm{MCFL} = \text{languages of pushdown automata with tuple stacks}  
$$

These automata have polynomially bounded configuration graphs.

### Closure Properties

Typical mild context-sensitive classes are closed under:  
$$  
\cup, \cap \text{ with regular}, \cdot, {}^*  
$$

They are generally not closed under:  
$$  
\cap, \complement  
$$

Failure of closure under intersection reflects bounded copying constraints.

### Pumping and Non-Membership Arguments

Generalized pumping lemmas exist, typically based on tuple decomposition:  
$$  
w = x_1 y_1 \dots x_k y_k z  
$$  
where simultaneous pumping preserves membership.

Such lemmas separate mild context-sensitive languages from full context-sensitive languages.

### Parsing Complexity

For bounded fan-out $k$:  
$$  
\text{Parsing complexity} = O n^{3k}  
$$

In particular:  
$$  
\mathrm{TAG} \text{ parsing is } O n^6  
$$

Polynomial-time parsing is essential to the definition of mild context-sensitivity.

### Logical Characterizations

Mildly context-sensitive languages correspond to fragments of monadic second-order logic extended with limited tuple concatenation and linear order.

They remain strictly weaker than full second-order logic on strings.

### Relevance to Verification and Types

Mildly context-sensitive grammars appear in:
- analysis of concurrent call-return systems
- higher-order pushdown systems of bounded order
- type systems with linear resource tracking
    

Bounded duplication ensures decidability of reachability and equivalence problems.

### Related Topics

- Tree adjoining grammars
- Linear indexed grammars
- Multiple context-free grammars
- Linear context-free rewriting systems
- Combinatory categorial grammars
- Indexed grammars
- Context-sensitive languages

---

