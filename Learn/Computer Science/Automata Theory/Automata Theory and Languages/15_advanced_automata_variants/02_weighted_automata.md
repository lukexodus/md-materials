## Weighted automata


### Algebraic setting

A **semiring** is a structure $K = \langle K, \oplus, \otimes, 0, 1 \rangle$ such that $\langle K, \oplus, 0 \rangle$ is a commutative monoid, $\langle K, \otimes, 1 \rangle$ is a monoid, $\otimes$ distributes over $\oplus$, and $0$ is absorbing for $\otimes$.

Canonical examples:
- Boolean semiring $\langle {0,1}, \lor, \land, 0, 1 \rangle$
- Tropical semiring $\langle \mathbb{R} \cup {\infty}, \min, +, \infty, 0 \rangle$
- Probability semiring $\langle \mathbb{R}_{\ge 0}, +, \cdot, 0, 1 \rangle$
- Integer semiring $\langle \mathbb{Z}, +, \cdot, 0, 1 \rangle$
    

The algebraic properties of $K$ determine closure, decidability, and equivalence behavior.

---

### Definition

A weighted automaton over semiring $K$ is a tuple

$$  
\mathcal{A} = \langle Q, \Sigma, \mu, \lambda, \rho \rangle  
$$

where:
- $Q$ is a finite set of states
- $\Sigma$ is a finite alphabet
- $\mu : \Sigma \to K^{Q \times Q}$ assigns a transition weight matrix to each symbol
- $\lambda \in K^{1 \times Q}$ is the initial weight vector
- $\rho \in K^{Q \times 1}$ is the final weight vector
    

For a word $w = a_1 a_2 \cdots a_n$, define

$$  
\mu w = \mu a_1 \otimes \mu a_2 \otimes \cdots \otimes \mu a_n  
$$

The recognized formal power series $S_\mathcal{A} : \Sigma^* \to K$ is

$$  
S_\mathcal{A} w = \lambda \otimes \mu w \otimes \rho  
$$

---

### Weighted languages and formal power series

A **formal power series** over $\Sigma$ and $K$ is a function

$$  
S : \Sigma^* \to K  
$$

The set of all such series is denoted $K \langle!\langle \Sigma^* \rangle!\rangle$.

A series is **recognizable** if it is realized by some weighted automaton.

Recognizable series form the smallest class containing polynomials and closed under sum, product, and star.

---

### Kleene–Schützenberger theorem

For any semiring $K$:

$$  
\text{Recognizable series} = \text{Rational series}  
$$

where rational series are generated from finite-support series using $\oplus$, Cauchy product, and Kleene star.

Proof proceeds via matrix representations and fixed-point constructions in $K^{Q \times Q}$.

---

### Expressive power

- Over the Boolean semiring, weighted automata coincide with nondeterministic finite automata.
- Over $\mathbb{N}$ or $\mathbb{Z}$, weighted automata define counting languages.
- Over the tropical semiring, they compute shortest-path or minimal-cost semantics.
- Over probability semirings, they model stochastic processes and hidden Markov models.
    

Expressiveness strictly exceeds regular languages when weights are observed rather than thresholded.

---

### Closure properties

Recognizable series are closed under:

$$  
\oplus,\ \otimes,\ \text{scalar multiplication}  
$$

Closure under star holds if $K$ is **star-continuous**.

Hadamard product closure holds for commutative semirings.

Complement closure fails outside the Boolean semiring.

---

### Determinization and ambiguity

Weighted automata determinization requires:

$$  
\oplus \text{ idempotent}  
$$

and typically fails over $\mathbb{N}$ or $\mathbb{Z}$.

Ambiguity is measured by the number of accepting paths contributing nonzero weight.

Finite ambiguity implies equivalence to unambiguous weighted automata in idempotent semirings.

---

### Equivalence and decidability

Given $\mathcal{A}_1, \mathcal{A}_2$, equivalence asks whether

$$  
\forall w \in \Sigma^* : S_{\mathcal{A}_1} w = S_{\mathcal{A}_2} w  
$$

Results depend on $K$:
- Decidable in polynomial time over fields
- Decidable over $\mathbb{Z}$ using linear algebra
- Undecidable over general semirings
- PSPACE-complete over tropical semiring
    

Equivalence reduces to equality of rational series.

---

### Minimization

For semirings admitting linear representations, minimization corresponds to finding a minimal-rank realization.

The minimal dimension equals the rank of the Hankel matrix

$$  
H_S u, v = S u v  
$$

Computable over fields but undecidable over arbitrary semirings.

---

### Logical characterizations

Weighted automata correspond to weighted monadic second-order logic.

For suitable $K$:

$$  
\text{Weighted MSO} = \text{Recognizable series}  
$$

Boolean MSO collapses to Büchi–Elgot–Trakhtenbrot theorem.

---

### Complexity of evaluation

Given $\mathcal{A}$ and $w$:

$$  
\text{Evaluation time} = O |Q|^2 |w|  
$$

Optimized to $O |Q|^\omega \log |w|$ using matrix exponentiation.

---

### Probabilistic and quantitative verification

Weighted automata form the basis of:
- Quantitative model checking
- Cost automata
- Mean-payoff and discounted-sum automata
    

Decision problems often reduce to reachability in weighted graphs.

---

### Related topics

- Cost automata
- Probabilistic automata
- Formal power series
- Tropical algebra
- Quantitative logics
- Semiring semantics

---

