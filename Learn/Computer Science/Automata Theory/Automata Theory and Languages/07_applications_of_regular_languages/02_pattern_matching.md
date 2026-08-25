## Pattern Matching


### Formalization as Language Recognition

Let $\Sigma$ be a finite alphabet and $P \in \Sigma^*$ a fixed pattern. Pattern matching is the problem of deciding, for an input string $w \in \Sigma^*$, whether $P$ occurs as a contiguous substring of $w$.

Define the language
$$
L_P = { w \in \Sigma^* \mid \exists x,y \in \Sigma^* : w = xPy }
$$
Then $L_P$ is regular and can be characterized by the regular expression
$$
\Sigma^* P \Sigma^*
$$

The computational problem reduces to membership testing $w \in L_P$.

### Automaton Constructions

#### Naive NFA Construction

An NFA for $L_P$ is obtained by a linear chain recognizing $P$ with nondeterministic restart:

* States $Q = {0,1,\dots,|P|}$
* Initial state $0$
* Accepting state $|P|$
* For all $a \in \Sigma$, $\Delta(0,a) \ni 0$
* For $1 \le i \le |P|$, if $P_i = a$, then $\Delta(i-1,a) \ni i$

This NFA has $|P|+1$ states and $O(|P||\Sigma|)$ transitions.

#### Deterministic Construction via Prefix Function

Determinization yields the Knuth–Morris–Pratt automaton. Define the prefix function
$$
\pi : {1,\dots,|P|} \to {0,\dots,|P|-1}
$$
where $\pi(i)$ is the length of the longest proper prefix of $P$ that is also a suffix of $P[1..i]$.

The DFA has states ${0,\dots,|P|}$, with transition function
$$
\delta(q,a) =
\begin{cases}
q+1 & \text{if } q < |P| \land P_{q+1} = a \
\delta(\pi(q),a) & \text{otherwise}
\end{cases}
$$

The accepting state is $|P|$. This DFA recognizes $L_P$ and has $O(|P||\Sigma|)$ transitions.

### Correctness Invariant

For any input prefix $u \in \Sigma^*$, the DFA state $q$ satisfies:
$$
q = \max { k \mid P[1..k] \text{ is a suffix of } u }
$$
This invariant ensures linear-time matching.

### Complexity Bounds

* Deterministic matching: $O(|w|)$ time, $O(|P|)$ space
* NFA simulation: $O(|w||P|)$ worst-case time
* DFA preprocessing: $O(|P||\Sigma|)$ time

Pattern matching remains in $\mathsf{AC}^0$ for fixed $P$ and unbounded input $w$.

### Generalized Pattern Languages

Let $\Pi$ be a set of patterns. Define
$$
L_\Pi = \bigcup_{P \in \Pi} \Sigma^* P \Sigma^*
$$
If $\Pi$ is finite, $L_\Pi$ is regular. A trie-based NFA followed by subset construction yields the Aho–Corasick automaton.

For $|\Pi| = m$ and total pattern length $N$, the DFA has $O(N)$ states.

### Aho–Corasick Automaton

States correspond to prefixes of patterns. Failure links generalize the prefix function:
$$
f(q) = \max { k < q \mid \text{label}(k) \text{ is a suffix of label}(q) }
$$

Transitions satisfy:
$$
\delta(q,a) =
\begin{cases}
\text{goto}(q,a) & \text{if defined} \
\delta(f(q),a) & \text{otherwise}
\end{cases}
$$

Accepting states correspond to pattern completions, possibly multiple per state.

### Regular Expressions and Matching

Given a regular expression $r$, pattern matching generalizes to deciding whether $w \in \Sigma^* L(r) \Sigma^*$. Thompson construction produces an NFA of size $O(|r|)$; determinization may induce exponential blow-up.

Matching with backreferences exceeds regular expressiveness and yields NP-complete membership problems.

### Logical Characterization

For fixed $P = a_1 \dots a_k$, the language $L_P$ is definable in $\mathsf{FO}[<]$:
$$
\exists i : \bigwedge_{j=1}^k \text{symbol}(i+j-1) = a_j
$$

Thus pattern matching lies strictly within first-order definable regular languages.

### Two-Way and Streaming Models

Two-way DFAs do not increase expressive power but may reduce state complexity for matching certain patterns.

Streaming pattern matching corresponds to online DFA execution with constant memory per state.

### Approximate Pattern Matching

Allowing mismatches or edit distance constraints yields non-regular languages. For fixed bound $k$, languages of strings within distance $k$ of $P$ are regular and recognizable by automata with $O(|P|^k)$ states.

Unbounded approximate matching is not regular.

### Decision Problems

* Emptiness: trivial, $L_P \neq \emptyset$
* Universality: false unless $P = \epsilon$
* Equivalence: reducible to DFA equivalence
* Containment: $L_P \subseteq L_Q$ decidable via automata inclusion

### Lower Bounds

Any DFA recognizing $L_P$ must distinguish all prefixes of $P$, yielding a lower bound of $|P|+1$ states by Myhill–Nerode:
$$
x_i = P[1..i] \quad 0 \le i \le |P|
$$
are pairwise inequivalent.

### Related Topics

* Knuth–Morris–Pratt automaton
* Aho–Corasick construction
* Regular expression matching
* Streaming algorithms
* Two-way finite automata
* Approximate matching automata
* Myhill–Nerode lower bounds

---

