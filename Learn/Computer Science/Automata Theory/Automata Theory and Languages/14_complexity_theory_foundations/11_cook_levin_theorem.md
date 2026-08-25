## Cook–Levin Theorem


### Formal Statement

Let $\mathrm{SAT} = { \varphi \mid \varphi \text{ is a satisfiable Boolean formula in CNF} }$.

**Cook–Levin Theorem:**  
$\mathrm{SAT}$ is $\mathrm{NP}$-complete under polynomial-time many-one reductions.

Formally:

$$  
\mathrm{SAT} \in \mathrm{NP}  
\quad\land\quad  
\forall L \in \mathrm{NP} ; \exists f \in \mathrm{FP} :  
x \in L \iff f x \in \mathrm{SAT}  
$$

where $\mathrm{FP}$ denotes the class of polynomial-time computable functions.

---

### Complexity-Theoretic Context

$\mathrm{NP}$ is defined as the class of languages $L \subseteq \Sigma^*$ such that:

$$  
\exists \text{ nondeterministic TM } M,;  
\exists p \in \mathbb{N}[x] :  
x \in L \iff \exists \text{ accepting computation of } M \text{ on } x \text{ of length } \le p |x|  
$$

Equivalent verifier-based characterization:

$$  
L \in \mathrm{NP}  
\iff  
\exists R \in \mathrm{P},;  
\exists p \in \mathbb{N}[x] :  
x \in L \iff \exists y \in \Sigma^{\le p |x|} : R x y  
$$

---

### Membership of $\mathrm{SAT}$ in $\mathrm{NP}$

Given a CNF formula $\varphi$ with $n$ variables and $m$ clauses:
- Certificate: truth assignment $a \in {0,1}^n$
- Verification: evaluate each clause under $a$
    

Verification runs in time $O m n$, hence polynomial.

Thus:

$$  
\mathrm{SAT} \in \mathrm{NP}  
$$

---

### Core Reduction Idea

For arbitrary $L \in \mathrm{NP}$, fix a nondeterministic TM $M$ and polynomial $p$ such that $M$ decides $L$ in time $p |x|$.

Construct a Boolean formula $\varphi_x$ encoding the existence of an accepting computation tableau of $M$ on input $x$ of length $T = p |x|$.

Then:

$$  
x \in L \iff \varphi_x \in \mathrm{SAT}  
$$

The mapping $x \mapsto \varphi_x$ is computable in time polynomial in $|x|$.

---

### Computation Tableau Encoding

Let:
- $Q$ be the finite state set of $M$
- $\Gamma$ be the tape alphabet
- Tape length bounded by $T$
    

Define Boolean variables:

$$  
X_{t,i,s} \quad  
0 \le t \le T,;  
0 \le i \le T,;  
s \in Q \cup \Gamma  
$$

Interpretation:

$$  
X_{t,i,s} = 1  
\iff  
\text{at time } t \text{, cell } i \text{ contains symbol or state } s  
$$

---

### Constraint Families

#### Cell Consistency

Each cell contains exactly one symbol or state:

$$  
\forall t,i:  
\bigvee_{s} X_{t,i,s}  
\quad\land\quad  
\bigwedge_{s \ne s'} \neg X_{t,i,s} \lor \neg X_{t,i,s'}  
$$

---

#### Initial Configuration

Encodes input $x$ at time $0$:

$$  
X_{0,0,q_0}  
\quad\land\quad  
\bigwedge_{i=1}^{|x|}  
X_{0,i,x_i}  
\quad\land\quad  
\bigwedge_{i>|x|} X_{0,i,\sqcup}  
$$

---

#### Transition Constraints

For each valid local transition of $M$:

$$  
X_{t,i,q} \land X_{t,i,a}  
\implies  
X_{t+1,i',q'} \land X_{t+1,i',a'}  
$$

Encoded using CNF by enumerating all illegal local patterns and forbidding them.

Locality ensures polynomial size.

---

#### Acceptance Condition

At some time step, an accepting state appears:

$$  
\bigvee_{t,i} X_{t,i,q_{\mathrm{acc}}}  
$$

---

### Size and Complexity Bounds

- Number of variables: $O T^3$
- Number of clauses: $O T^3$
- Formula size polynomial in $|x|$
    

Thus the reduction is polynomial-time.

---

### Normal Form Considerations

- Initial construction yields CNF with clauses of bounded width
- Conversion to $3$-CNF via standard Tseitin transformation
- Preserves satisfiability and polynomial size
    

Hence:

$$  
\mathrm{SAT} \le_m \mathrm{3SAT}  
$$

---

### Completeness and Closure Properties

- $\mathrm{SAT}$ is complete under $\le_m^{\mathrm{P}}$
- $\mathrm{NP}$ is closed under polynomial-time reductions
- All $\mathrm{NP}$-complete problems interreduce under $\le_m^{\mathrm{P}}$

---

### Automata-Theoretic Interpretation

The tableau construction encodes:
- Bounded-time Turing machine acceptance
- Space-time diagram as a two-dimensional word
- Local consistency constraints akin to tiling systems
    

This parallels:

$$  
\mathrm{NP}

\exists \text{-FO} \text{ over finite structures}  
$$

under descriptive complexity.

---

### Logical Characterization

Cook–Levin establishes:

$$  
\mathrm{NP}

{ L \mid L \text{ definable by existential second-order logic} }  
$$

by showing Boolean satisfiability captures existential quantification over relations encoding computations.

---

### Decidability and Hardness Implications

- If $\mathrm{SAT} \in \mathrm{P}$, then $\mathrm{P} = \mathrm{NP}$
- No known polynomial-time algorithm for $\mathrm{SAT}$
- $\mathrm{SAT}$ hardness is robust under syntactic restrictions

---

### Related Topics

- $\mathrm{NP}$-completeness
- Polynomial-time reductions
- $\mathrm{3SAT}$
- Tableau constructions
- Descriptive complexity
- Fagin’s theorem
- Turing machine time hierarchy
- Constraint satisfaction problems

---

