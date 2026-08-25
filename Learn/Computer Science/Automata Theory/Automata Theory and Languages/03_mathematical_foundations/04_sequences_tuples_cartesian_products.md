## Sequences, Tuples, Cartesian Products


### Formal Structures and Notation

Let $\Sigma$ be a finite alphabet and let $A,B,C$ be arbitrary sets.

A **finite sequence** over $A$ is a function $s : {1,\dots,n} \to A$ for some $n \in \mathbb{N}$. Its length is $|s| = n$.
An **infinite sequence** over $A$ is a function $s : \mathbb{N} \to A$, written $s = a_0 a_1 a_2 \dots$.
A **tuple** is an element of a finite Cartesian product $A_1 \times \cdots \times A_k$ and can be identified with a sequence of fixed arity $k$.
The **Cartesian product** of $A$ and $B$ is $A \times B = {(a,b) \mid a \in A \land b \in B}$. Finite products are defined inductively and countable products by functions with domain $\mathbb{N}$.

In automata theory, words are finite sequences in $\Sigma^*$, while machine configurations and transitions are tuples over structured Cartesian products.

---

### Sequences as Words and Configurations

The free monoid $\Sigma^*$ consists of all finite sequences over $\Sigma$ under concatenation with identity $\varepsilon$.

Automaton computations are sequences over configuration spaces:

* Deterministic finite automaton configurations are elements of $Q$.
* Pushdown automaton configurations are elements of $Q \times \Gamma^*$.
* Turing machine configurations can be represented as elements of $Q \times \Gamma^* \times \Gamma^*$.

Thus, configuration spaces are Cartesian products whose components may themselves be sequence sets. For example, the Turing machine configuration space is

$$
\mathcal{C}_{TM} = Q \times \Gamma^* \times \Gamma^* .
$$

The transition relation of any automaton is a subset of $\mathcal{C} \times \mathcal{C}$, that is, a binary relation over tuples of sequences.

---

### Cartesian Products and Alphabet Constructions

Given alphabets $\Sigma_1$ and $\Sigma_2$, the **product alphabet** $\Sigma_1 \times \Sigma_2$ is fundamental in multi-track and synchronous models.

A language $L \subseteq (\Sigma_1 \times \Sigma_2)^*$ represents pairs of words of equal length. The projection homomorphisms

$$
\pi_i : (\Sigma_1 \times \Sigma_2)^* \to \Sigma_i^*
$$

map each paired symbol to its $i$-th component. Projections preserve regularity but do not preserve context-freeness in general.

---

### Closure Properties via Cartesian Products

Let $L_1 \subseteq \Sigma_1^*$ and $L_2 \subseteq \Sigma_2^*$ be regular languages. The synchronized language

$$
L = { w \in (\Sigma_1 \times \Sigma_2)^* \mid \pi_1(w) \in L_1 \land \pi_2(w) \in L_2 }
$$

is regular. Recognition is achieved by a product automaton with state space $Q_1 \times Q_2$.

For pushdown automata, Cartesian products of state spaces combined with independent stacks do not preserve context-freeness, yielding the classical non-closure of context-free languages under intersection.

---

### Tuples in Grammar and Parsing Theory

Context-free derivations operate over sequences of variables and terminals, with derivation relations contained in $V^* \times V^*$.

Explicit tuple structures arise in advanced grammar formalisms:

* Attribute grammars, where attribute vectors are tuples propagated along derivation trees.
* LR parsing, where parser states are tuples of items of the form $A \to \alpha \bullet \beta$ paired with lookahead information.

Thus, parsing algorithms manipulate tuples whose components encode grammatical and contextual information.

---

### Encodings, Pairings, and Decidability

Many computability-theoretic reductions rely on effective encodings of tuples as single words. There exist computable pairing functions

$$
\langle \cdot , \cdot \rangle : \Sigma^* \times \Sigma^* \to \Sigma^*
$$

with computable projections. Consequently,

$$
\Sigma^* \times \Sigma^* \leq_m \Sigma^* .
$$

This establishes that finite Cartesian products of countable sets are countable and supports the definition of universal machines operating on encoded tuples of inputs.

---

### Infinite Products and $\omega$-Sequences

Infinite sequences form $\Sigma^\omega$. Automata over $\omega$-words operate on infinite Cartesian products of symbol positions indexed by $\mathbb{N}$.

Languages over $(\Sigma_1 \times \Sigma_2)^\omega$ represent synchronized infinite behaviors. Projections of $\omega$-regular languages are $\omega$-regular, while complementation requires determinization constructions over Cartesian products of state spaces.

These structures are central in temporal logic semantics and automata-based model checking.

---

### Complexity and State-Space Explosion

Cartesian products induce multiplicative growth in state spaces:

* Intersection of automata yields $|Q_1 \times Q_2| = |Q_1| \cdot |Q_2|$ states.
* Determinization yields subsets of Cartesian products, producing exponential blowup.

This structural phenomenon underlies PSPACE-completeness and EXPTIME-completeness results in automata-based verification and decision procedures.

---

### Logical and Algebraic Correspondence

In logic, tuples correspond to variable assignments in first-order structures, and Cartesian products of domains correspond to direct product constructions.

In algebraic automata theory, **recognizable relations** are subsets of

$$
\Sigma_1^* \times \cdots \times \Sigma_k^*
$$

recognized by finite automata over product alphabets. These generalize regular languages from unary predicates to $k$-ary relations and are closed under Boolean operations with decidable emptiness.

---

### Related Topics

* Pairing functions
* Product automata
* Recognizable relations
* $\omega$-words and Büchi automata
* Attribute grammars
* Automatic structures
* Transducers and rational relations

---

