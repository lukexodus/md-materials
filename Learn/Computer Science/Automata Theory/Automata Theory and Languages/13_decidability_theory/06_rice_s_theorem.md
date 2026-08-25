## Rice’s Theorem


### Formal Statement

Let $\Sigma$ be a finite alphabet and let $\mathcal{R}$ denote the class of all partial recursive functions $\varphi : \Sigma^* \to \Sigma^*$, equivalently the class of all Turing-computable partial functions.  
Let $\mathcal{P} \subseteq \mathcal{R}$ be a **non-trivial semantic property**, meaning:
- $\mathcal{P} \neq \varnothing$
- $\mathcal{P} \neq \mathcal{R}$
- $\mathcal{P}$ depends only on the function computed, not on its syntactic representation
    

Define the associated index set:

$$  
I_{\mathcal{P}} = { e \in \mathbb{N} \mid \varphi_e \in \mathcal{P} }  
$$

where $\varphi_e$ denotes the partial recursive function computed by the Turing machine with index $e$ under a fixed Gödel numbering.

**Rice’s Theorem:**  
$I_{\mathcal{P}}$ is undecidable.

---

### Semantic vs Syntactic Properties

A property $\mathcal{P}$ is **semantic** iff:

$$  
\forall e_1,e_2 \in \mathbb{N} \quad \varphi_{e_1} = \varphi_{e_2} \implies e_1 \in I_{\mathcal{P}} \leftrightarrow e_2 \in I_{\mathcal{P}}  
$$

Examples of semantic properties:
- $\varphi_e$ is total
- $\mathrm{dom},\varphi_e = \varnothing$
- $\exists x \in \Sigma^* : \varphi_e x = 1$
- $\mathrm{range},\varphi_e$ is finite
- $L_e = { x \mid \varphi_e x = 1 }$ is regular
    

Non-semantic properties:
- Machine $e$ has at most $100$ states
- Machine $e$ halts in $\le 10^6$ steps on all inputs
    

Rice’s theorem applies exclusively to semantic properties.

---

### Proof via Many-One Reduction

Let $\mathcal{P}$ be non-trivial. Then:

$$  
\exists f_0 \in \mathcal{P}, \quad \exists f_1 \in \mathcal{R} \setminus \mathcal{P}  
$$

Fix indices $e_0,e_1$ such that $\varphi_{e_0} = f_0$ and $\varphi_{e_1} = f_1$.

Let $K = { x \mid \varphi_x x \downarrow }$ be the halting set.

Define a computable function $g : \mathbb{N} \to \mathbb{N}$ such that $g x$ is an index of a Turing machine $M_x$ defined as:
- On input $y$:
    - Simulate $\varphi_x x$
    - If it halts, compute $f_0 y$
    - Otherwise, diverge
        

Formally:

$$  
\varphi_{g x} y =  
\begin{cases}  
f_0 y & \text{if } \varphi_x x \downarrow \  
\uparrow & \text{otherwise}  
\end{cases}  
$$

Then:
- If $x \in K$, $\varphi_{g x} = f_0 \in \mathcal{P}$
- If $x \notin K$, $\varphi_{g x}$ is nowhere defined, hence $\varphi_{g x} = f_1 \notin \mathcal{P}$ after appropriate choice of $f_1$
    

Thus:

$$  
x \in K \iff g x \in I_{\mathcal{P}}  
$$

Hence $K \le_m I_{\mathcal{P}}$, implying $I_{\mathcal{P}}$ is undecidable.

---

### Index Sets and Arithmetical Hierarchy

For any semantic property $\mathcal{P}$:
- $I_{\mathcal{P}}$ is an index set
- $I_{\mathcal{P}}$ is neither recursive nor co-recursive unless trivial
    

Refinements:
- If $\mathcal{P}$ is $\Sigma^0_n$-definable over partial functions, then $I_{\mathcal{P}} \in \Sigma^0_n$
- Many natural properties are $\Pi^0_2$-complete:
    - Totality
    - Infiniteness of domain
    - Equality with a fixed computable function

---

### Language-Theoretic Formulation

Let $L_e \subseteq \Sigma^*$ be the language recognized by TM $e$.

For any non-trivial language property $\mathcal{Q} \subseteq \mathcal{P} \Sigma^*$ invariant under language equality:

$$  
I_{\mathcal{Q}} = { e \mid L_e \in \mathcal{Q} }  
$$

is undecidable.

Examples:
- $L_e = \varnothing$
- $L_e$ is finite
- $L_e$ is regular
- $L_e$ is context-free
- $L_e = \Sigma^*$

---

### Consequences for Automata and Formal Languages

- No algorithm decides whether a TM-recognized language is regular
- No algorithm decides whether a TM-recognized language is context-free
- No algorithm decides equivalence of TM languages
- No algorithm decides emptiness of the complement of a TM language
    

Contrast:
- Emptiness for DFA, NFA, PDA is decidable
- Equivalence for DFA is decidable
    

The undecidability boundary arises precisely at semantic properties of unrestricted computation.

---

### Rice–Shapiro Refinement

For recursively enumerable properties $\mathcal{P}$:

$I_{\mathcal{P}}$ is r.e. iff $\mathcal{P}$ is **effectively open**, meaning:

$$  
\exists F \subseteq \Sigma^* \times \Sigma^* \text{ finite} :  
F \subseteq \mathrm{graph},f \implies f \in \mathcal{P}  
$$

This characterizes which semantic properties yield semi-decidable index sets.

---

### Logical Interpretation

Rice’s theorem corresponds to:
- Undecidability of non-trivial extensional predicates over computable functions
- Inexpressibility of semantic program properties in decidable fragments of first-order arithmetic
- Limits of program verification under full Turing completeness

---

### Related Topics

- Halting problem
- Rice–Shapiro theorem
- Arithmetical hierarchy
- Index sets
- Many-one reductions
- Program equivalence
- Semantic vs syntactic properties
- Recursively enumerable languages

---

