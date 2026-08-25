## Non context-sensitive examples


### Context-sensitive baseline

Context-sensitive languages satisfy
$$
\text{CSL} = \text{NSPACE}(n)
$$
and are therefore **decidable**. Consequently, any **undecidable** language is not context-sensitive.

---

### Halting-based languages

#### Halting problem language

$$
L_{\text{HALT}} = { \langle M,w \rangle \mid M \text{ halts on input } w }
$$

* $L_{\text{HALT}}$ is recursively enumerable
* $L_{\text{HALT}}$ is undecidable
* Every context-sensitive language is decidable

Therefore:
$$
L_{\text{HALT}} \notin \text{CSL}
$$

---

#### Acceptance problem

$$
L_{\text{ACC}} = { \langle M,w \rangle \mid M \text{ accepts } w }
$$

Properties:

* $L_{\text{ACC}}$ is recursively enumerable
* $L_{\text{ACC}}$ is undecidable
* $L_{\text{ACC}} \le_m L_{\text{HALT}}$

Thus:
$$
L_{\text{ACC}} \notin \text{CSL}
$$

---

### Totality and universality languages

#### Totality

$$
L_{\text{TOT}} = { \langle M \rangle \mid M \text{ halts on all inputs} }
$$

* $L_{\text{TOT}}$ is not recursively enumerable
* By Rice’s theorem, $L_{\text{TOT}}$ is undecidable

Hence:
$$
L_{\text{TOT}} \notin \text{CSL}
$$

---

#### Universality

$$
L_{\text{UNIV}} = { \langle M \rangle \mid L(M) = \Sigma^* }
$$

* $L_{\text{UNIV}}$ is undecidable
* $L_{\text{UNIV}}$ is neither recursively enumerable nor co-recursively enumerable

Thus:
$$
L_{\text{UNIV}} \notin \text{CSL}
$$

---

### Post Correspondence Problem language

Let
$$
L_{\text{PCP}} = { \langle P \rangle \mid P \text{ has a PCP solution} }
$$

* $L_{\text{PCP}}$ is recursively enumerable
* $L_{\text{PCP}}$ is undecidable

Therefore:
$$
L_{\text{PCP}} \notin \text{CSL}
$$

---

### Diagonalization via space hierarchy

By the space hierarchy theorem:
$$
\text{SPACE}(n) \subsetneq \text{SPACE}(n^2)
$$

Since:
$$
\text{CSL} = \text{NSPACE}(n)
$$
there exists a decidable language
$$
L \in \text{SPACE}(n^2) \setminus \text{SPACE}(n)
$$

Thus:
$$
\exists L \text{ decidable such that } L \notin \text{CSL}
$$

This yields **decidable but non–context-sensitive** languages, though not constructively simple ones.

---

### Encoding-based examples

Let
$$
L_{\text{DIAG}} = { \langle M \rangle \mid M \text{ does not accept } \langle M \rangle }
$$

* $L_{\text{DIAG}}$ is undecidable by diagonalization
* $L_{\text{DIAG}}$ is not recursively enumerable

Hence:
$$
L_{\text{DIAG}} \notin \text{CSL}
$$

---

### Closure-based nonexamples

Context-sensitive languages are closed under:

* Complement
* Intersection
* Concatenation
* Linear erasing homomorphisms

Thus any language violating **decidability** or **linear-space recognizability** cannot be context-sensitive.

---

### Summary characterization

For any language $L$:
$$
L \text{ undecidable } ;\Longrightarrow; L \notin \text{CSL}
$$

Conversely, there exist decidable languages outside CSL by space hierarchy separation.

---

### Related topics

* Linear bounded automata
* Space hierarchy theorem
* Rice’s theorem
* Post Correspondence Problem
* Recursive enumerability
* Context-sensitive grammar limitations

---

