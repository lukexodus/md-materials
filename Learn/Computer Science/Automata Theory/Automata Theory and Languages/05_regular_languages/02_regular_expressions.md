## Regular Expressions


### Syntax and Algebraic Structure

Let $\Sigma$ be a finite alphabet. Regular expressions are inductively defined terms over $\Sigma$ generating elements of $\Sigma^*$.

The set $\mathrm{RE}(\Sigma)$ is the smallest set such that:

* $\emptyset \in \mathrm{RE}(\Sigma)$
* $\varepsilon \in \mathrm{RE}(\Sigma)$
* $a \in \mathrm{RE}(\Sigma)$ for each $a \in \Sigma$
* If $r,s \in \mathrm{RE}(\Sigma)$ then $r + s \in \mathrm{RE}(\Sigma)$
* If $r,s \in \mathrm{RE}(\Sigma)$ then $rs \in \mathrm{RE}(\Sigma)$
* If $r \in \mathrm{RE}(\Sigma)$ then $r^* \in \mathrm{RE}(\Sigma)$

The denotation function $\mathcal{L} : \mathrm{RE}(\Sigma) \to \mathcal{P}(\Sigma^*)$ is defined homomorphically:

$$
\begin{aligned}
\mathcal{L}(\emptyset) &= \emptyset \
\mathcal{L}(\varepsilon) &= {\varepsilon} \
\mathcal{L}(a) &= {a} \
\mathcal{L}(r + s) &= \mathcal{L}(r) \cup \mathcal{L}(s) \
\mathcal{L}(rs) &= \mathcal{L}(r)\mathcal{L}(s) \
\mathcal{L}(r^*) &= \mathcal{L}(r)^*
\end{aligned}
$$

Regular expressions form the free Kleene algebra over $\Sigma$.

---

### Expressive Power and Language Characterization

The class of languages denoted by regular expressions is exactly the class of regular languages:

$$
{ \mathcal{L}(r) \mid r \in \mathrm{RE}(\Sigma) } = \mathrm{REG}(\Sigma)
$$

Equivalence holds via constructive transformations:

* Thompson construction yields an $\varepsilon$-NFA from any regular expression
* State elimination yields a regular expression from any finite automaton

Thus, regular expressions, NFAs, DFAs, and right-linear grammars are equivalent in expressive power.

---

### Normal Forms and Algebraic Identities

Regular expressions satisfy equational laws of Kleene algebra. For expressions $r,s,t$:

* Idempotence: $r + r = r$
* Commutativity: $r + s = s + r$
* Associativity: $(r + s) + t = r + (s + t)$
* Distributivity: $r(s + t) = rs + rt$
* Annihilation: $\emptyset r = r \emptyset = \emptyset$
* Star identities: $r^* = \varepsilon + rr^* = \varepsilon + r^*r$

Every regular language has a regular expression in **star normal form**, where no subexpression under a Kleene star denotes $\varepsilon$. This form is central in complexity bounds for expression size.

---

### Automaton Constructions and Size Bounds

Given a regular expression $r$ of size $n$:

* Thompson construction yields an $\varepsilon$-NFA with $O(n)$ states
* Subset construction yields a DFA with up to $2^{O(n)}$ states
* State elimination may produce expressions of exponential size

Conversely, converting a DFA with $k$ states into a regular expression yields worst-case size $2^{\Theta(k)}$.

These bounds are asymptotically tight.

---

### Closure Properties via Regular Expressions

Regular expressions directly witness closure of regular languages under:

* Union via $r + s$
* Concatenation via $rs$
* Kleene star via $r^*$
* Homomorphism via symbol substitution
* Inverse homomorphism via syntactic rewriting

Intersection and complement are not primitive operations but are definable via automata equivalence and Boolean closure.

---

### Decidability and Equivalence

Given regular expressions $r$ and $s$, the equivalence problem

$$
\mathcal{L}(r) = \mathcal{L}(s)
$$

is decidable by automaton minimization or bisimulation on DFAs. The problem is PSPACE-complete when expressions are part of the input.

The emptiness problem

$$
\mathcal{L}(r) = \emptyset
$$

is decidable in linear time via automaton construction or syntactic analysis.

---

### Pumping Arguments and Limitations

Regular expressions cannot define non-regular languages. For example:

$$
L = { a^n b^n \mid n \in \mathbb{N} }
$$

is not denotable by any regular expression, as shown by the pumping lemma or Myhill–Nerode theorem.

The Kleene star enforces unbounded repetition but cannot enforce cross-serial dependencies or matching counts.

---

### Logical Characterization

Regular expressions correspond to existential monadic second-order logic over words with order:

$$
\mathrm{REG} = \mathrm{MSO}[<]
$$

Star-free regular expressions correspond exactly to first-order logic with order:

$$
\mathrm{FO}[<]
$$

This yields the equivalence:

$$
\text{Star-free RE} = \text{Aperiodic monoids} = \mathrm{FO}[<]
$$

establishing deep connections between algebra, logic, and automata.

---

### Extensions and Restrictions

* Extended regular expressions allow intersection and complement
* Regular expressions with backreferences exceed regular power
* Weighted regular expressions correspond to semiring-valued automata
* Two-way regular expressions correspond to two-way finite automata

Some extensions preserve regularity, others yield undecidable or non-regular languages.

---

### Related Topics

* Kleene algebra
* Thompson construction
* State elimination
* Myhill–Nerode theorem
* Star-free languages
* Aperiodic monoids
* MSO logic over words


---

