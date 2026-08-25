## DFA minimization


### Model and equivalence relation

Let $M = \langle Q, \Sigma, \delta, q_0, F \rangle$ be a deterministic finite automaton with total transition function $\delta : Q \times \Sigma \to Q$. Two states $p,q \in Q$ are **Myhill–Nerode equivalent** if and only if
$$
\forall w \in \Sigma^* ; \delta^*(p,w) \in F \iff \delta^*(q,w) \in F
$$
where $\delta^*$ is the canonical extension of $\delta$ to $\Sigma^*$.

Define the equivalence relation
$$
p \equiv_M q ;;\Longleftrightarrow;; \forall w \in \Sigma^* ; \delta^*(p,w) \in F \iff \delta^*(q,w) \in F
$$

This relation is right-invariant:
$$
p \equiv_M q ;\Longrightarrow; \delta(p,a) \equiv_M \delta(q,a) \quad \forall a \in \Sigma
$$

The quotient automaton $M / {\equiv_M}$ is well-defined.

---

### Minimality criterion

A DFA $M$ is **minimal** if and only if:

* All states are reachable from $q_0$
* No two distinct states are Myhill–Nerode equivalent

Equivalently, $M$ is minimal if and only if $|Q|$ equals the number of equivalence classes of $\equiv_L$, where $L = L(M)$ and
$$
x \equiv_L y ;;\Longleftrightarrow;; \forall z \in \Sigma^* ; xz \in L \iff yz \in L
$$

---

### Uniqueness of the minimal DFA

For any regular language $L \subseteq \Sigma^*$, there exists a unique minimal DFA for $L$ up to isomorphism.

Formally, if $M_1$ and $M_2$ are minimal DFAs such that $L(M_1) = L(M_2)$, then there exists a bijection $h : Q_1 \to Q_2$ such that:
$$
h \delta_1(q,a) = \delta_2(h(q),a), \quad h(q_{0,1}) = q_{0,2}, \quad q \in F_1 \iff h(q) \in F_2
$$

---

### Partition refinement formulation

Let $\mathcal{P}$ be a partition of $Q$. A partition is **stable** if
$$
\forall B \in \mathcal{P}, \forall a \in \Sigma, \forall p,q \in B :
\delta(p,a), \delta(q,a) \in B'
$$
for some $B' \in \mathcal{P}$.

The coarsest stable partition refining
$$
{F, Q \setminus F}
$$
corresponds exactly to the equivalence classes of $\equiv_M$.

---

### DFA minimization algorithms

#### Table-filling algorithm

Define a table over unordered pairs ${p,q} \subseteq Q$, $p \neq q$.
1. Mark ${p,q}$ if exactly one of $p,q$ is in $F$
2. Iteratively mark ${p,q}$ if
   $$
   \exists a \in \Sigma : {\delta(p,a), \delta(q,a)} \text{ is marked}
   $$
3. Unmarked pairs correspond to equivalent states

Correctness follows from induction on distinguishing string length.

Time complexity:
$$
O\left(|Q|^2 \cdot |\Sigma|\right)
$$

Space complexity:
$$
O\left(|Q|^2\right)
$$

---

#### Hopcroft algorithm

Maintain a partition $\mathcal{P}$ and a worklist $\mathcal{W}$.

Initialization:
$$
\mathcal{P}_0 = {F, Q \setminus F}, \quad \mathcal{W}_0 = {F}
$$

Refinement step: for $A \in \mathcal{W}$ and $a \in \Sigma$, split any $B \in \mathcal{P}$ using
$$
B_1 = {q \in B \mid \delta(q,a) \in A}, \quad B_2 = B \setminus B_1
$$

Replace $B$ by $B_1,B_2$ if both nonempty, and update $\mathcal{W}$ accordingly.

Time complexity:
$$
O\left(|\Sigma| \cdot |Q| \cdot \log |Q|\right)
$$

This bound is asymptotically optimal for DFA minimization.

---

### Construction of the minimal DFA

Given the equivalence classes $[q]_{\equiv_M}$, define:
$$
Q' = Q / {\equiv_M}
$$
$$
\delta'([q],a) = [\delta(q,a)]
$$
$$
q_0' = [q_0], \quad F' = {[q] \mid q \in F}
$$

Right-invariance ensures $\delta'$ is well-defined.

---

### Connection to Myhill–Nerode theorem

A language $L \subseteq \Sigma^*$ is regular if and only if $\equiv_L$ has finite index.

Moreover:
$$
\text{index}(\equiv_L) = \text{number of states in the minimal DFA for } L
$$

Thus DFA minimization computes the syntactic congruence of $L$.

---

### Lower bounds and hardness

Any DFA recognizing $L$ must have at least $\text{index}(\equiv_L)$ states.

There exist families of DFAs where minimization requires $\Omega(|Q| \log |Q|)$ time in the comparison-based model.

---

### Decidability and transformations

* DFA equivalence is decidable via minimization
* DFA isomorphism is decidable in polynomial time
* NFA minimization is PSPACE-complete
* DFA minimization is closed under alphabet projection via quotienting

---

### Algebraic interpretation

The minimal DFA corresponds to the **syntactic monoid** of $L$ acting on right congruence classes.

State transitions induce a homomorphism:
$$
\varphi : \Sigma^* \to \text{End}(Q')
$$

---

### Logical characterization

States of the minimal DFA correspond to equivalence classes of formulas in $\text{FO}[<]$ under indistinguishability by suffixes.

---

### Related topics

* Myhill–Nerode equivalence
* Syntactic monoids
* Brzozowski derivatives
* DFA equivalence checking
* NFA determinization
* Regular language decision problems


---

