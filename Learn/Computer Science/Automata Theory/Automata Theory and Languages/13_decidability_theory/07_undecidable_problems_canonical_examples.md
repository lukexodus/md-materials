## Undecidable Problems — Canonical Examples


### Halting Problem

**Formal statement.**  
Define the language  
$$  
\text{HALT} = { \langle M, w \rangle \in \Sigma^* \mid M \text{ halts on input } w }  
$$  
where $M$ ranges over deterministic Turing machines and $w \in \Sigma^*$.

**Result.** $\text{HALT}$ is undecidable.

**Proof technique.** Diagonalization via self-reference. Assume a decider $H$ for $\text{HALT}$ and construct a machine $D$ such that  
$$  
D\langle M \rangle =  
\begin{cases}  
\text{loop} & \text{if } H\langle M, \langle M \rangle \rangle = 1 \  
\text{halt} & \text{otherwise}  
\end{cases}  
$$  
Evaluating $D\langle D \rangle$ yields contradiction.

**Hierarchy placement.** $\text{HALT}$ is $\text{r.e.}$-complete under many-one reductions.

---

### Acceptance Problem

**Formal statement.**  
$$  
A_{\text{TM}} = { \langle M, w \rangle \mid M \text{ accepts } w }  
$$

**Result.** $A_{\text{TM}}$ is undecidable.

**Remarks.**  
Stronger than $\text{HALT}$ since halting without acceptance is excluded. $A_{\text{TM}}$ is $\text{r.e.}$-complete.

---

### Emptiness of Turing Machine Languages

**Formal statement.**  
$$  
\text{EMPTY}_{\text{TM}} = { \langle M \rangle \mid L M = \emptyset }  
$$

**Result.** Undecidable.

**Reduction.**  
$A_{\text{TM}} \leq_m \text{EMPTY}_{\text{TM}}$ via construction of $M'$ such that  
$$  
L M' =  
\begin{cases}  
{ 0 } & \text{if } M \text{ accepts } w \  
\emptyset & \text{otherwise}  
\end{cases}  
$$

---

### Universality of Turing Machines

**Formal statement.**  
$$  
\text{UNIV}_{\text{TM}} = { \langle M \rangle \mid L M = \Sigma^* }  
$$

**Result.** Undecidable.

**Observation.**  
Complement is not recursively enumerable. Neither $\text{UNIV}_{\text{TM}}$ nor its complement is semi-decidable.

---

### Equivalence of Turing Machines

**Formal statement.**  
$$  
\text{EQ}_{\text{TM}} = { \langle M_1, M_2 \rangle \mid L M_1 = L M_2 }  
$$

**Result.** Undecidable.

**Method.** Reduction from $\text{EMPTY}_{\text{TM}}$ using a fixed universal language $U$ and comparison against a machine accepting $U$.

---

### Post Correspondence Problem

**Formal statement.**  
Given a finite set of dominoes  
$$  
{ \langle u_i, v_i \rangle \mid u_i, v_i \in \Sigma^+ }  
$$  
determine whether there exists a sequence $i_1, \dots, i_k$ such that  
$$  
u_{i_1} \cdots u_{i_k} = v_{i_1} \cdots v_{i_k}  
$$

**Result.** Undecidable.

**Properties.**
- Undecidable even for binary alphabets.
- Serves as a standard reduction source for grammar and automaton undecidability.

---

### Ambiguity of Context-Free Grammars

**Formal statement.**  
$$  
\text{AMB}_{\text{CFG}} = { \langle G \rangle \mid G \text{ is ambiguous} }  
$$

**Result.** Undecidable.

**Stronger variant.**  
$$  
\text{INHAMB}_{\text{CFG}} = { \langle G \rangle \mid L G \text{ is inherently ambiguous} }  
$$  
also undecidable.

---

### Equivalence of Context-Free Grammars

**Formal statement.**  
$$  
\text{EQ}_{\text{CFG}} = { \langle G_1, G_2 \rangle \mid L G_1 = L G_2 }  
$$

**Result.** Undecidable.

**Contrast.**
- Emptiness and finiteness of CFGs are decidable.
- Equivalence sharply separates CFLs from regular languages.

---

### Inclusion of Context-Free Languages

**Formal statement.**  
$$  
\text{INCL}_{\text{CFG}} = { \langle G_1, G_2 \rangle \mid L G_1 \subseteq L G_2 }  
$$

**Result.** Undecidable.

**Note.**  
Inclusion is decidable when $G_2$ is regular, highlighting asymmetry in expressive power.

---

### Totality Problem

**Formal statement.**  
$$  
\text{TOTAL}_{\text{TM}} = { \langle M \rangle \mid M \text{ halts on all inputs} }  
$$

**Result.** Undecidable.

**Classification.**
- Not recursively enumerable.
- $\Pi_2$-complete in the arithmetical hierarchy.

---

### Rice’s Theorem (Semantic Properties)

**Statement.**  
Let $P$ be a nontrivial semantic property of recursively enumerable languages. Then  
$$  
{ \langle M \rangle \mid L M \text{ satisfies } P }  
$$  
is undecidable.

**Examples derived directly.**
- Regularity of $L M$
- Finiteness of $L M$
- Context-freeness of $L M$
- Membership of a fixed string $w$ in $L M$

---

### Mortality and Boundedness Problems

**Matrix mortality.**  
$$  
\exists k \ge 1 \text{ such that } A_{i_1} \cdots A_{i_k} = 0  
$$  
for integer matrices $A_i$.

**Counter machine boundedness.**  
Determining whether all computations remain bounded.

**Result.** Undecidable via simulation of Turing machines.

---

### Logical Undecidability Connections

**First-order logic validity.**  
$$  
\text{VALID}_{\text{FOL}} = { \varphi \mid \varphi \text{ is valid} }  
$$

**Result.** Undecidable.

**Relation.**
- Reduces to Turing machine acceptance via encoding of computation histories.
- Establishes correspondence between computation and logic.

---

### Related Topics

- Recursive enumerability
- Many-one and Turing reductions
- Arithmetical hierarchy
- Gödel incompleteness
- Decision problems in formal verification
- Program equivalence
- Model checking boundaries

---

