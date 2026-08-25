## Encoding of Machines & Strings


### Effective Encodings and Gödel Numberings

An **encoding** is a total, injective, computable function mapping finite syntactic objects to strings over a fixed finite alphabet, typically ${0,1}$. Formally, for a class of objects $\mathcal{O}$, an encoding is a function $\langle \cdot \rangle : \mathcal{O} \to {0,1}^*$ such that:
- $\langle \cdot \rangle$ is computable.
- The inverse relation is decidable on its image.
- $\langle \mathcal{O} \rangle \subseteq {0,1}^*$ is recursive.
    

A **Gödel numbering** is an encoding $\varphi : \mathcal{O} \to \mathbb{N}$ with the same properties, typically obtained by interpreting $\langle O \rangle$ as a binary numeral. Encodings induce an effective enumeration ${O_i}_{i \in \mathbb{N}}$ of $\mathcal{O}$.

Encodings are not unique; invariance theorems ensure that computability-theoretic results are robust under choice of reasonable encoding.

---

### Encoding of Strings and Alphabets

Given a finite alphabet $\Sigma = {\sigma_1, \dots, \sigma_k}$, fix a binary code $\mathrm{code} : \Sigma \to {0,1}^+$ such that $\mathrm{code}$ is prefix-free. Extend $\mathrm{code}$ homomorphically to $\Sigma^*$:  
$$  
\mathrm{code} \langle w_1 w_2 \dots w_n \rangle = \mathrm{code} \langle w_1 \rangle \mathrm{code} \langle w_2 \rangle \dots \mathrm{code} \langle w_n \rangle  
$$

Properties:
- $\mathrm{code} \langle \Sigma^* \rangle$ is a regular language.
- Decoding is computable in linear time.
- Length-preserving encodings are impossible in general; polynomial overhead is standard.
    

Pairing and tupling functions are defined via computable bijections:  
$$  
\langle x, y \rangle : {0,1}^* \times {0,1}^* \to {0,1}^*  
$$  
with computable projections $\pi_1, \pi_2$. Iteration yields encodings of finite sequences.

---

### Encoding of Finite Automata

A deterministic finite automaton $M = \langle Q, \Sigma, \delta, q_0, F \rangle$ is encoded by:
- A canonical enumeration of $Q = {q_1, \dots, q_n}$.
- Binary encodings of $n$, $|\Sigma|$, $q_0$, and $F \subseteq Q$.
- A table encoding of $\delta : Q \times \Sigma \to Q$.
    

The resulting language:  
$$  
\mathrm{DFA} = {\langle M \rangle \mid M \text{ is a DFA}}  
$$  
is recursive. Similar encodings exist for NFA and $\epsilon$-NFA, with $\delta$ encoded as finite relations.

Decidability of DFA properties, such as emptiness and equivalence, is preserved under encoding.

---

### Encoding of Pushdown Automata and Grammars

A pushdown automaton $P = \langle Q, \Sigma, \Gamma, \delta, q_0, Z_0, F \rangle$ is encoded by:
- Finite descriptions of $Q$, $\Sigma$, $\Gamma$.
- Encoding of $\delta \subseteq Q \times \Sigma_\epsilon \times \Gamma \to \mathcal{P} \langle Q \times \Gamma^* \rangle$ as a finite set of tuples.
    

Context-free grammars $G = \langle V, \Sigma, P, S \rangle$ are encoded by:
- Enumerations of $V$ and $\Sigma$.
- A finite list of productions $A \to \alpha$ encoded as pairs of strings.
    

The set:  
$$  
\mathrm{CFG} = {\langle G \rangle \mid G \text{ is a context-free grammar}}  
$$  
is recursive. Normal forms such as Chomsky and Greibach normal form are computable transformations on encodings.

---

### Encoding of Turing Machines

A single-tape deterministic Turing machine $M = \langle Q, \Sigma, \Gamma, \delta, q_0, q_{\mathrm{acc}}, q_{\mathrm{rej}} \rangle$ is encoded via:
- Finite alphabets $Q$, $\Sigma$, $\Gamma$.
- Transition function $\delta : Q \times \Gamma \to Q \times \Gamma \times {L,R}$ encoded as a finite table.
    

The language of valid encodings:  
$$  
\mathrm{TM} = {\langle M \rangle \mid M \text{ is a Turing machine}}  
$$  
is recursive. Multi-tape, nondeterministic, and alternative models admit uniform encodings with polynomial-time translations.

A **universal Turing machine** $U$ operates on encodings:  
$$ U \langle \langle M \rangle \# w \rangle = M \langle w \rangle $$  
establishing effective programmability and supporting diagonalization arguments.

---

### Self-Reference and the Recursion Theorem

Encodings enable machines to manipulate descriptions of machines. Let $\varphi_e$ denote the partial computable function computed by the machine with index $e$.

The **Recursion Theorem** states:  
For any total computable function $f : \mathbb{N} \to \mathbb{N}$, there exists $e$ such that:  
$$  
\varphi_e = \varphi_{f \langle e \rangle}  
$$

This relies on effective encodings and underpins fixed-point constructions, quines, and undecidability proofs.

---

### Reductions via Encodings

Many-one reductions are defined using encodings:  
A language $A \subseteq \Sigma^*$ is many-one reducible to $B \subseteq \{0,1\}^*$ if there exists a total computable $f$ such that:  
$$  
x \in A \iff f \langle x \rangle \in B  
$$

Encodings allow decision problems about machines to be treated as languages:
- $\mathrm{HALT} = {\langle M, w \rangle \mid M \text{ halts on } w}$
- $\mathrm{EMPTY}_{\mathrm{TM}} = {\langle M \rangle \mid L \langle M \rangle = \emptyset}$
    

Undecidability proofs rely on computable, injective encodings to preserve semantic properties under reduction.

---

### Size, Complexity, and Robustness

Encoding size affects complexity measures:
- Time complexity is invariant up to polynomial factors under reasonable encodings.
- Space complexity is invariant up to constant or linear factors.
    

The **Invariance Thesis** asserts that all reasonable machine encodings yield equivalent complexity classes, such as $\mathrm{P}$, $\mathrm{NP}$, and $\mathrm{PSPACE}$.

---

### Logical and Verification Connections

Encodings relate syntactic objects to arithmetic:
- Machines correspond to formulas under arithmetization.
- Encodings enable the definition of $\Sigma_1$ predicates representing computably enumerable sets.
    

In verification, encodings allow automata and transition systems to be inputs to meta-algorithms such as model checking and language inclusion testing.

---

### Related Topics

- Universal machines
- Gödel incompleteness
- Rice’s theorem
- Arithmetization of syntax
- Effective enumerations
- Kolmogorov complexity
- Program self-reference
- Descriptive complexity

---

