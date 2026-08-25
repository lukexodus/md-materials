## Learning automata and grammatical inference


### Formal learning frameworks

Learning is formalized as identification of a target language $L \subseteq \Sigma^*$ within a hypothesis space $\mathcal{H}$ of languages or automata, given access to an information source $\mathcal{I}$.

Common learning settings are defined as triples $ \langle \mathcal{C}, \mathcal{H}, \mathcal{I} \rangle $, where $\mathcal{C}$ is a class of target languages.

Gold-style learning in the limit assumes $\mathcal{I}$ is a text or informant.

A **text** for $L$ is an infinite sequence $T = w_0, w_1, \dots$ such that $L = { w \mid \exists i : w = w_i }$.

An **informant** is a sequence of labeled examples $(w, \ell)$ with $\ell \in {0,1}$ encoding membership in $L$.

A learner is a computable function  
$$  
\mathcal{A} : \Sigma^* \to 2^\mathcal{H}  
$$  
mapping finite prefixes of observations to hypotheses.

Identification in the limit requires existence of $N$ such that for all $n \ge N$,  
$$  
\mathcal{A}(T \restriction n) = H  
$$  
and $L(H) = L$.

### Learnability results and hierarchy

Gold's theorem establishes that any class $\mathcal{C}$ containing all finite languages and at least one infinite language is not identifiable in the limit from text.

Consequences:  
$$  
\text{REG}, \text{CFL} \text{ are not identifiable from positive data alone}  
$$

From informants, the class of recursive languages is identifiable in the limit, while recursively enumerable languages are not.

The hierarchy of learnability satisfies:  
$$  
\text{Finite} \subsetneq \text{REG} \subsetneq \text{CFL} \subsetneq \text{CSL}  
$$  
with strict separations under standard information models.

### Learning regular languages

Regular languages admit effective learning under stronger query models.

Angluin's $L^\omega$ algorithm learns minimal DFA using membership queries  
$$  
\chi_L : \Sigma^* \to {0,1}  
$$  
and equivalence queries returning counterexamples.

The hypothesis DFA $H$ converges to the minimal DFA for $L$ in time polynomial in  
$$  
|Q| \cdot |\Sigma|  
$$  
and the length of counterexamples.

Key invariant: construction of an observation table satisfying closure and consistency, inducing a canonical DFA isomorphic to the Myhill–Nerode quotient.

Passive learning of REG from text is impossible in general, but possible for restricted subclasses such as:
- strictly $k$-local languages
- reversible automata
- acyclic DFAs

### Grammatical inference for context-free languages

Context-free languages are unlearnable in the limit from text or informants.

Proof techniques reduce from the undecidability of CFG equivalence:  
$$  
\text{EQ}_{\text{CFG}} = { \langle G_1, G_2 \rangle \mid L(G_1) = L(G_2) }  
$$

Learning is feasible for constrained subclasses:
- deterministic CFL
- linear grammars
- visibly pushdown languages
    

Structural restrictions enable polynomial-time parsing and canonical normal forms, such as Greibach or Chomsky normal form, aiding inference.

### Identification by queries and oracles

Query learning generalizes Gold learning.

Standard query types:
- membership
- equivalence
- subset
- superset
    

Learning power increases monotonically with query strength:  
$$  
\text{text} \prec \text{informant} \prec \text{membership} \prec \text{equivalence}  
$$

For visibly pushdown languages, learning algorithms exist using structured membership queries respecting call-return structure.

### Complexity-theoretic aspects

Learning complexity is analyzed via:
- sample complexity
- query complexity
- computational complexity
    

In the PAC model, a concept class $\mathcal{C}$ is learnable if there exists an algorithm producing hypothesis $H$ such that  
$$  
\Pr_{w \sim D} \chi_L(w) \ne \chi_H(w) \le \epsilon  
$$  
with probability at least $1 - \delta$.

Regular languages are PAC-learnable under fixed alphabet size, while general CFGs are not, unless standard complexity collapses occur.

### Algebraic and logical perspectives

Learning automata is closely related to algebraic characterizations.

Eilenberg correspondence connects varieties of regular languages to pseudovarieties of finite monoids.

Learning tasks can be phrased as reconstruction of syntactic monoids:  
$$  
M_L = \Sigma^* / \equiv_L  
$$

Logical descriptions via $\text{FO}\langle < \rangle$ or $\text{MSO}$ induce learnability results for fragments with bounded quantifier alternation.

### Normal forms and transformations

Canonical forms are central to inference:
- minimal DFA for REG
- prefix tree acceptors for finite samples
- characteristic automata for congruence classes
    

Transformations preserve language but alter learnability properties, e.g. determinization of NFA increases state complexity exponentially, affecting sample bounds.

### Undecidability and hardness results

Fundamental impossibility results follow from Rice-style arguments.

For any nontrivial property $P$ of recursively enumerable languages, the problem  
$$  
{ G \mid L(G) \in P }  
$$  
is undecidable, implying non-learnability under broad hypothesis spaces.

Even approximate inference of CFG structure is $\text{NP}$-hard under standard encodings.

### Related topics

- Active automata learning
- PAC learning of formal languages
- Query complexity
- Myhill–Nerode theory
- Algebraic automata theory
- Inductive inference
- Language identification in the limit
- Model inference in verification

---

