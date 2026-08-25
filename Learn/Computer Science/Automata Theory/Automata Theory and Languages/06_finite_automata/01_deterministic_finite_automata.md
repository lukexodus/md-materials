## Deterministic Finite Automata


### Formal Model

A deterministic finite automaton is a tuple  
$$  
A = \langle Q, \Sigma, \delta, q_0, F \rangle  
$$  
where $Q$ is a finite set of states, $\Sigma$ a finite alphabet, $\delta : Q \times \Sigma \to Q$ a total transition function, $q_0 \in Q$ the initial state, and $F \subseteq Q$ the accepting states. Extend $\delta$ to words by the unique homomorphism  
$$  
\hat{\delta} : Q \times \Sigma^* \to Q  
$$  
defined inductively by  
$$  
\hat{\delta} q \epsilon = q  
$$  
$$  
\hat{\delta} q aw = \hat{\delta} \delta q a w  
$$  
The language recognized by $A$ is  
$$  
L A = { w \in \Sigma^* \mid \hat{\delta} q_0 w \in F }  
$$

---

### Determinism and Totality

Determinism enforces single-valued transitions and forbids $\epsilon$-moves. Totality of $\delta$ ensures closure under complement. Any partial DFA can be completed by adjoining a sink state $q_\bot$ with  
$$  
\delta q_\bot a = q_\bot \quad \forall a \in \Sigma  
$$

---

### Expressive Power

DFAs recognize exactly the class $\mathrm{REG}$ of regular languages. For every NFA $N$ there exists a DFA $A$ such that  
$$  
L A = L N  
$$  
via subset construction. Determinism does not reduce expressive power but impacts succinctness.

---

### Subset Construction

Given an NFA  
$$  
N = \langle Q, \Sigma, \Delta, Q_0, F \rangle  
$$  
the equivalent DFA is  
$$  
A = \langle 2^Q, \Sigma, \delta, Q_0, F' \rangle  
$$  
where  
$$  
\delta S a = { q' \mid \exists q \in S \text{ such that } q' \in \Delta q a }  
$$  
$$  
F' = { S \subseteq Q \mid S \cap F \neq \varnothing }  
$$  
Worst-case state complexity is $2^{|Q|}$ and is asymptotically tight.

---

### Closure Properties

The class of DFA-recognizable languages is closed under:  
$$  
\cup,\ \cap,\ \overline{\cdot},\ \setminus,\ \oplus  
$$  
via product constructions and complementing final states. Given DFAs $A_1, A_2$, the synchronous product has state set $Q_1 \times Q_2$ with acceptance conditions determined by Boolean combinations of $F_1, F_2$.

---

### Algebraic Characterization

Each DFA induces a right congruence $\equiv_A$ on $\Sigma^*$:  
$$  
u \equiv_A v \iff \hat{\delta} q_0 u = \hat{\delta} q_0 v  
$$  
$\equiv_A$ has finite index and refines the Myhill–Nerode equivalence $\equiv_L$. Conversely, every finite-index right congruence yields a DFA.

---

### Myhill–Nerode Theorem

For a language $L \subseteq \Sigma^*$, the following are equivalent:  
$$  
L \in \mathrm{REG}  
$$  
$$  
\equiv_L \text{ has finite index}  
$$  
$$  
L \text{ is recognized by a DFA}  
$$  
where  
$$  
u \equiv_L v \iff \forall w \in \Sigma^* : uw \in L \leftrightarrow vw \in L  
$$  
The number of equivalence classes equals the number of states in the minimal DFA for $L$.

---

### DFA Minimization

Every DFA has a unique minimal form up to isomorphism.

_Partition refinement._  
Initialize the partition  
$$  
{ F,\ Q \setminus F }  
$$  
and iteratively split blocks by transition distinguishability until stable.

_Correctness._  
Two states are equivalent iff they accept the same set of continuations. Minimization computes the quotient automaton under this equivalence.

_Complexity._  
Hopcroft’s algorithm runs in  
$$  
O \lvert \Sigma \rvert \lvert Q \rvert \log \lvert Q \rvert  
$$

---

### Decision Problems

For DFAs $A, B$:  
$$  
\text{Emptiness } L A = \varnothing \in \mathrm{P}  
$$  
$$  
\text{Universality } L A = \Sigma^* \in \mathrm{P}  
$$  
$$  
\text{Equivalence } L A = L B \in \mathrm{P}  
$$  
All are solvable by graph reachability or product constructions. DFA equivalence is complete for deterministic logspace.

---

### State Complexity

For regular operations, DFA state complexity is often tight:  
$$  
\lvert L_1 \cup L_2 \rvert \le \lvert Q_1 \rvert \cdot \lvert Q_2 \rvert  
$$  
$$  
\lvert \overline{L} \rvert = \lvert Q \rvert  
$$  
$$  
\lvert L^R \rvert \le 2^{\lvert Q \rvert}  
$$  
Reversal requires determinization of the reversed NFA.

---

### Pumping and Distinguishability

The DFA pumping lemma follows from finiteness of states:  
$$  
\exists p > 0 \ \forall w \in L \ \lvert w \rvert \ge p \Rightarrow w = xyz  
$$  
with  
$$  
\lvert xy \rvert \le p,\ \lvert y \rvert \ge 1,\ \forall k \ge 0 : xy^k z \in L  
$$  
Non-regularity proofs correspond to infinite Myhill–Nerode index.

---

### Logical and Verification Connections

DFAs correspond exactly to MSO-definable languages over words. Determinism enables:
- Efficient complementation for model checking
- Language containment via product automata
- Symbolic minimization via Boolean encodings
    

In verification, DFAs serve as monitors and specification automata for trace properties.

---

### Related Topics

Nondeterministic finite automata  
Myhill–Nerode equivalence  
Syntactic monoids  
Regular expressions  
State complexity  
Automata minimization algorithms  
Monadic second-order logic

---

