## Tokenization and Lexical Analysis


### Formal Models of Tokenization

Let $\Sigma$ be a finite alphabet and $\Sigma^*$ the free monoid. Tokenization is modeled as a function mapping an input string $w \in \Sigma^*$ to a sequence of tokens drawn from a finite token alphabet $\mathcal{T}$, possibly annotated with attributes. Formally, tokenization induces a factorization
$$
w = x_1 x_2 \cdots x_k
$$
such that each factor $x_i \in \Sigma^*$ belongs to a token language $L_{t_i} \subseteq \Sigma^*$ for some $t_i \in \mathcal{T}$, and the sequence $t_1 t_2 \cdots t_k$ is the token stream.

Each token language $L_t$ is typically specified as a regular language. The global lexical specification is a finite family $\mathcal{L} = { L_t \mid t \in \mathcal{T} }$ of regular languages over $\Sigma$.

Lexical analysis is the recognition problem:
$$
\text{Given } w \in \Sigma^*, \text{ compute a valid segmentation consistent with } \mathcal{L}.
$$

### Regular Language Foundations

Lexical analyzers rely on the fact that regular languages are closed under union, concatenation, Kleene star, complement, and intersection. Let
$$
L_{\text{lex}} = \bigcup_{t \in \mathcal{T}} L_t.
$$
Correct tokenization requires $w \in L_{\text{lex}}^*$.

Token definitions are usually given as regular expressions, which are compiled into nondeterministic finite automata $A_t$, then combined into a single automaton
$$
A = \bigcup_{t \in \mathcal{T}} A_t
$$
with distinguished accepting states labeled by token types.

Determinization via the subset construction yields a DFA $D$ recognizing $L_{\text{lex}}$, enabling linear-time scanning.

### Longest-Match and Priority Resolution

Lexical specifications are generally ambiguous: multiple tokens may match a prefix of the remaining input. Disambiguation is defined operationally by two partial orders:
1. **Maximal munch**: choose the longest prefix $x$ such that $x \in L_t$ for some $t$.
2. **Priority**: if $x \in L_{t_1} \cap L_{t_2}$ with equal length, select the token with higher precedence.

Formally, define
$$
\ell = \max { |x| \mid \exists t \in \mathcal{T},\ x \preceq w,\ x \in L_t }.
$$
Then choose $t$ minimal under a fixed priority ordering among all $t$ such that the prefix $w[1..\ell] \in L_t$.

This mechanism is not purely language-theoretic; it defines a deterministic transduction not expressible as a regular language alone, but implementable by a DFA augmented with output actions.

### Automata-Theoretic Construction

Given NFAs $A_t = \langle Q_t, \Sigma, \delta_t, q_{0,t}, F_t \rangle$, construct an NFA
$$
A = \langle Q, \Sigma, \delta, q_0, F \rangle
$$
where
$$
Q = { q_0 } \cup \bigcup_{t \in \mathcal{T}} Q_t,
$$
with $\varepsilon$-transitions from $q_0$ to each $q_{0,t}$. Each accepting state is annotated with its token type.

After subset construction, each DFA state corresponds to a set of NFA states; acceptance requires tracking all reachable token types and selecting the one satisfying maximal munch and priority. This yields a DFA with output function
$$
\lambda : Q_D \to \mathcal{T} \cup { \bot }.
$$

### Complexity Bounds

Let $n = |w|$ and let $D$ be the deterministic lexer automaton. Lexical analysis runs in time $O(n)$ and space $O(1)$ auxiliary space, assuming table-driven DFA execution.

The DFA size may be exponential in the size of the regular expressions, reflecting the worst-case blowup of subset construction. This is unavoidable by standard lower bounds on DFA minimization.

### Decidability and Optimization Problems

Decidable problems include:

* Token language emptiness: $L_t = \emptyset$.
* Token overlap: $L_{t_1} \cap L_{t_2} \neq \emptyset$.
* Unreachable tokens under maximal munch semantics.

DFA minimization is decidable in $O(|Q| \log |Q|)$ time. Equivalence of two lexical specifications reduces to DFA equivalence.

Undecidable problems arise when tokenization is extended beyond regular languages, for example by allowing context-free constraints on token boundaries.

### Lexical Analysis as Transduction

Lexical analysis can be modeled as a deterministic finite-state transducer
$$
T : \Sigma^* \to \mathcal{T}^*
$$
with output emitted at accepting transitions. The class of functions computed by such lexers is strictly contained in regular functions and coincides with subsequential transductions.

The maximal munch rule requires bounded lookahead, which remains implementable by deterministic transducers.

### Interaction with Parsing

Separating lexical and syntactic analysis assumes that tokenization is independent of parse context. This fails in languages where the token language depends on syntactic state, requiring scannerless parsing.

Formally, classical lexing enforces that the language of token streams $L_{\text{tok}} \subseteq \mathcal{T}^*$ is regular and independent of the context-free grammar $G$. Scannerless parsing removes this restriction, effectively working over $\Sigma$ directly.

### Limitations of Regular Tokenization

Certain language features are not regular and cannot be captured at the lexical level:

* Nested comments: ${ a^n b^n \mid n \ge 0 }$-like structures
* Indentation-sensitive layouts
* Context-dependent keywords

These require either syntactic handling or extensions beyond finite automata, such as visibly pushdown mechanisms.

### Relationships to Logic

Regular token definitions correspond to monadic second-order definable languages over strings. Tokenization corresponds to MSO-definable partitions with additional deterministic choice constraints, which are not purely logical but operational.

### Related Topics

* Regular expressions
* Deterministic finite automata
* Nondeterministic finite automata
* Finite-state transducers
* Scannerless parsing
* Context-free grammars
* Visibly pushdown languages
* Monadic second-order logic over words

---

