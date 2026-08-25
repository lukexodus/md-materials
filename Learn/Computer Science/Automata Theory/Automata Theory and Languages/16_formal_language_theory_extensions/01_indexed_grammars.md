## Indexed Grammars


### Formal Definition

An **indexed grammar** is a generative system  
$$  
G = \langle N, T, I, P, S \rangle  
$$  
where $N$ is a finite set of nonterminals, $T$ is a finite set of terminals, $I$ is a finite set of indices, $S \in N$ is the start symbol, and $P$ is a finite set of productions of the following forms:  
$$  
A \to \alpha  
$$  
$$  
A \to B i  
$$  
$$  
A i \to \alpha  
$$  
where $A,B \in N$, $i \in I$, and $\alpha \in \langle N \cup T \rangle^*$. Each nonterminal carries a stack of indices from $I^*$.

Derivations operate by attaching, removing, and propagating index stacks. If a nonterminal is written as $A \gamma$ with $\gamma \in I^*$, then:
- $A \to B i$ pushes $i$ onto $\gamma$
- $A i \to \alpha$ pops $i$ from $\gamma$
- $A \to \alpha$ preserves $\gamma$ across all nonterminals in $\alpha$
    

The language generated is:  
$$  
L \langle G \rangle = { w \in T^* \mid S \Rightarrow^* w }  
$$

---

### Operational Semantics via Indexed Nonterminals

A sentential form consists of symbols in $\langle N \times I^* \rangle \cup T$. Productions are applied only when index conditions are met. All nonterminals in the right-hand side inherit the full remaining index stack of the left-hand side.

This global propagation distinguishes indexed grammars from context-free grammars and yields strictly greater expressive power.

---

### Expressive Power and Language Class

The class of indexed languages $\mathrm{IL}$ satisfies:  
$$  
\mathrm{CFL} \subsetneq \mathrm{IL} \subsetneq \mathrm{CSL}  
$$

Proper containments are witnessed by:  
$$  
{ a^n b^n c^n \mid n \ge 1 } \in \mathrm{IL} \setminus \mathrm{CFL}  
$$  
and by the existence of context-sensitive languages not generable by indexed grammars.

Indexed grammars generate exactly the languages accepted by **nested stack automata**, also known as higher-order pushdown automata of order $2$.

---

### Normal Forms

Every indexed grammar can be transformed into a normal form where productions are restricted to:  
$$  
A \to a  
$$  
$$  
A \to B C  
$$  
$$  
A \to B i  
$$  
$$  
A i \to B  
$$  
$$  
A \to \epsilon  
$$  
subject to standard side conditions. These transformations are effective and preserve language equivalence.

---

### Closure Properties

Indexed languages are closed under:
- Union
- Concatenation
- Kleene star
- Homomorphism
- Inverse homomorphism
- Intersection with regular languages
    

They are not closed under:
- Intersection
- Complementation
    

Non-closure under complement follows from containment in $\mathrm{CSL}$ and separation results using pumping arguments specific to indexed grammars.

---

### Decidability Properties

For indexed grammars $G$:
- Membership $w \in L \langle G \rangle$ is decidable and lies in $\mathrm{PSPACE}$
- Emptiness is decidable
- Finiteness is decidable
- Universality is undecidable
- Equivalence is undecidable
    

Membership complexity arises from depth-first traversal of derivation trees with bounded index stack reuse.

---

### Pumping and Shrinking Lemmas

Indexed languages satisfy a **shrinking lemma** rather than a classical pumping lemma. For sufficiently long $w \in L$, there exists a decomposition:  
$$  
w = u_1 u_2 \dots u_k  
$$  
allowing deletion of some factors while preserving membership. The lemma reflects unbounded but structured growth of index stacks.

This tool separates indexed languages from both context-free and context-sensitive classes.

---

### Relationship to Automata

Indexed grammars are equivalent in power to:
- Nested stack automata
- Level-$2$ pushdown automata
- Certain classes of macro grammars
    

The derivation depth corresponds to stack nesting depth rather than linear stack height.

---

### Complexity-Theoretic Position

Parsing for indexed grammars is $\mathrm{PSPACE}$-complete. This matches the complexity of nested stack automaton acceptance.

There exist indexed languages complete for $\mathrm{PSPACE}$ under logspace reductions.

---

### Logical and Verification Connections

Indexed languages correspond to fragments of monadic second-order logic extended with restricted second-order quantification over stacks.

They appear in:
- Analysis of mildly context-sensitive languages
- Formal models of cross-serial dependencies
- Verification of recursive programs with bounded nesting

---

### Related Topics

- Nested stack automata
- Higher-order pushdown automata
- Macro grammars
- Tree-adjoining grammars
- Context-sensitive languages
- $\mathrm{PSPACE}$-complete language classes

---

