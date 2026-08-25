## State equivalence & distinguishability


**Formal setting.** Deterministic finite automaton $M$ over alphabet $\Sigma$ is a tuple $M = \langle Q,\Sigma,\delta,q_0,F\rangle$ with total transition function $\delta:Q\times \Sigma \to Q$. The unique extension to $\Sigma^*$ is denoted $\delta^*:Q\times \Sigma^*\to Q$.

---

### Language-theoretic state equivalence

**Right language of a state.** For $q\in Q$ define
$$L_r(q)={,w\in \Sigma^* \mid \delta^*(q,w)\in F,}.$$

**Equivalence.** States $p,q\in Q$ are **language-equivalent** if
$$L_r(p)=L_r(q).$$
Write $p\sim q$.

**Distinguishability.** States $p,q$ are **distinguishable** if
$$\exists, w\in \Sigma^*: \chi_{L_r(p)}(w)\neq \chi_{L_r(q)}(w),$$
equivalently $L_r(p)\neq L_r(q)$. Any such $w$ is a **distinguishing string** or **separator**.

$\sim$ is an equivalence relation over $Q$ and moreover a right congruence with respect to $\delta$:
$$p\sim q \Rightarrow \delta(p,a)\sim \delta(q,a)\text{ for all }a\in \Sigma.$$

---

### Myhill–Nerode right congruence over $\Sigma^*$

Define the **indistinguishability relation** on strings:
$$x\equiv_L y ;\Longleftrightarrow; \forall z\in \Sigma^*: \chi_L(xz)=\chi_L(yz).$$

Properties:

* $\equiv_L$ is an equivalence relation on $\Sigma^*$.
* $\equiv_L$ is a right congruence: $x\equiv_L y \Rightarrow xa\equiv_L ya$ for all $a\in \Sigma$.
* Equivalence classes correspond bijectively to right languages of reachable DFA states recognizing $L$.

**Myhill–Nerode Theorem.** For $L\subseteq \Sigma^*$ the following are equivalent:
1. $L$ is regular.
2. $\equiv_L$ has finitely many equivalence classes.
3. There exists a DFA with finitely many states recognizing $L$.
4. The minimal DFA for $L$ has exactly the number of $\equiv_L$-classes.

---

### Minimal DFA and quotient construction

For DFA $M$, let $Q/{\sim}$ be the partition of $Q$ under language-equivalence. Define the **quotient automaton**
$$M/{\sim}=\langle Q/{\sim},\Sigma,\hat{\delta},[q_0],F/{\sim}\rangle,$$
where $\hat{\delta}([q],a)=[\delta(q,a)]$. This is well defined since $\sim$ is a right congruence.

Properties:

* $M/{\sim}$ recognizes the same language as $M$.
* $M/{\sim}$ is minimal among DFAs language-equivalent to $M$.
* If $M$ is reachable (every state reachable from $q_0$), then $M/{\sim}$ is isomorphic to the unique minimal DFA for $L(M)$.

---

### k-equivalence and iterative distinguishability

Define $k$-equivalence inductively:

* $p\sim_0 q$ iff $p\in F \Leftrightarrow q\in F$.
* $p\sim_{k+1} q$ iff $p\sim_k q$ and for all $a\in \Sigma$, $\delta(p,a)\sim_k \delta(q,a)$.

Then:

* $\sim_0 \supseteq \sim_1 \supseteq \dots$
* There exists minimal $k\le |Q|-1$ with $\sim_k=\sim_{k+1}=\sim$.
* $p,q$ are distinguishable iff $\exists k: p\not\sim_k q$.
* The minimal length of a distinguishing string between $p,q$ is at most $|Q|-1$.

---

### Partition-refinement minimization algorithms

**Moore’s algorithm (successive refinement).** Iteratively refine the partition by $\sim_k$ until stabilization. Time complexity
$$O(|Q|^2\cdot|\Sigma|).$$

**Hopcroft’s algorithm (optimal).** Maintains splitters and refines blocks; worst-case complexity
$$O(|Q|\cdot|\Sigma|\log |Q|).$$

Correctness is established by the coincidence of the limit partition with $\sim$.

---

### Equivalence and distinguishability in NFAs

For NFAs $N=\langle Q,\Sigma,\Delta,Q_0,F\rangle$ with $\epsilon$-moves:

* **State language:** $L_r(S)={w\mid \exists q\in S: \delta^*(q,w)\in F}$ for $S\subseteq Q$ under $\epsilon$-closure.
* Distinguishability defined as for DFAs via characteristic functions of right languages.

Relationship:

* Subset construction induces DFA states corresponding to subsets $S\subseteq Q$; equivalence of NFA states reduces to equivalence of their subsets’ right languages.
* Deciding NFA state equivalence is PSPACE-complete; DFA state equivalence is decidable in polynomial time as above.

---

### Decidability and complexity results

* DFA state equivalence problem is decidable in time $O(|Q|\cdot|\Sigma|\log |Q|)$.
* DFA equivalence (language equivalence of initial states) is in NL and P-complete under logspace reductions; also solvable via product construction and reachability of a distinguishing pair.
* NFA equivalence and NFA state equivalence are PSPACE-complete.
* For DFAs, shortest distinguishing string between inequivalent states has length $<|Q|$; for NFAs, shortest distinguishing string may be exponential in $|Q|$.

---

### Logical and algebraic characterizations

* Minimal DFA states correspond to classes of the syntactic right congruence $\equiv_L$ and to prime ideals in the syntactic monoid of $L$.
* $\equiv_L$ coincides with the kernel of the syntactic morphism from $\Sigma^*$ onto the syntactic monoid.
* In monadic second-order logic on words, equivalence reflects indistinguishability under right-context extension.

---

### Proof sketches of central properties

**Right congruence of $\equiv_L$.**
Assume $x\equiv_L y$. For any $z\in \Sigma^*$ and $a\in \Sigma$,
$$\chi_L(xaz)=\chi_L((xa)z)=\chi_L((ya)z)=\chi_L(yaz),$$
hence $xa\equiv_L ya$.

**Uniqueness of minimal DFA up to isomorphism.**
Let $M_1,M_2$ be minimal reachable DFAs for $L$. Their state sets are in bijection with $\equiv_L$-classes. Map each state in $M_i$ to its class; composing bijections yields an isomorphism preserving $q_0$, $F$, and transitions.

**Correspondence of state equivalence and $\equiv_L$.**
For reachable $q$ with $x$ such that $\delta^*(q_0,x)=q$, right language $L_r(q)$ equals the class of $x$ modulo $\equiv_L$. Hence indistinguishable strings induce equivalent states and conversely.

---

### Distinguishing sequences and testing

* **Separating word:** $w$ with $\chi_L(xw)\ne \chi_L(yw)$ distinguishes $x,y$ or the associated states.
* **Adaptive vs. preset distinguishing sequences:** In Mealy/Moore testing, adaptive sequences may be shorter; existence of preset sequences corresponds to state partition properties (relevant in conformance testing of DFAs).

Bounds:

* Any two inequivalent DFA states have a distinguishing word of length $<|Q|$.
* For complete state identification (all states), shortest preset homing/distinguishing sequences may be exponential in $|Q|$.

---

### Extensions and related notions

* Bisimulation vs. language equivalence in nondeterministic systems
* Syntactic monoid and syntactic congruence
* Left congruence and left languages
* Myhill–Nerode for trees and tree automata
* Minimization of weighted automata and probabilistic bisimulation
* Right congruence indexes and variety of languages

---

