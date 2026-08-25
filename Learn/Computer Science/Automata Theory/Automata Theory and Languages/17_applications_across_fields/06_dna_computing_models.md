## DNA computing models


### Abstract molecular computation

Formal DNA computing models idealize biochemical operations as algebraic transformations on multisets of strings over finite alphabets $\Sigma$. A configuration is a multiset $M \subseteq \Sigma^*$ or a family ${ M_i \mid i \in I }$ representing test tubes. Computation is the iterative application of operations drawn from a fixed instruction set, with acceptance defined by the presence or absence of designated marker strings.

### Adleman–Lipton test tube model

A system consists of finitely many test tubes $T_1,\dots,T_k$, each containing a multiset of DNA strands. The alphabet $\Sigma$ encodes nucleotide sequences at an abstract level.

Primitive operations include:
- **Merge:** $T_i := T_i \cup T_j$
- **Copy:** $T_i := T_j$
- **Separate by prefix or suffix:** for $w \in \Sigma^*$,  
    $$  
    T_i := { x \in T_j \mid w \preceq x }  
    $$
- **Detect emptiness:** predicate $\mathsf{empty},T_i$
- **Discard:** $T_i := \emptyset$
    

A program is a finite sequence of such operations. Uniform families of programs indexed by input length define a nonuniform complexity model.

**Computational power.** Polynomial time test tube programs with polynomially many tubes characterize $\mathsf{NP}$ under standard encodings. Exponential parallelism is exploited via multiset semantics rather than time.

**Decidability.** Reachability and equivalence of programs are undecidable by reduction from Turing machine halting, since the model simulates nondeterministic Turing machines with polynomial overhead.

### Sticker systems

Sticker systems model Watson–Crick complementarity. A sticker system is a tuple $S = \langle \Sigma, \rho, A, D \rangle$ where $\rho \subseteq \Sigma \times \Sigma$ is a complementarity relation, $A$ is a finite set of axioms as partially double stranded strings, and $D$ is a finite set of domination rules.

Derivation consists of attaching single stranded stickers to exposed sites respecting $\rho$. The language $L S$ is the set of fully double stranded molecules derivable from $A$.

**Expressiveness.** Regular sticker systems generate exactly the regular languages. Extended systems with finite delay generate all recursively enumerable languages.

**Closure.** The family of sticker languages is closed under union and homomorphism, and not closed under complement.

### Splicing systems

A splicing system is defined as $S = \langle \Sigma, A, R \rangle$ where $A \subseteq \Sigma^*$ is finite and $R$ is a finite set of splicing rules of the form  
$$ u_1 \# u_2 \text{ or } v_1 \# v_2 $$  
with $u_i, v_i \in \Sigma^*$.

Given strings $x = x_1 u_1 u_2 x_2$ and $y = y_1 v_1 v_2 y_2$, splicing yields  
$$  
x_1 u_1 v_2 y_2 \quad \text{and} \quad y_1 v_1 u_2 x_2  
$$

The language $L S$ is the closure of $A$ under all splicing operations in $R$.

**Hierarchy.** Finite splicing systems generate a proper subclass of regular languages. Allowing iterated or context controlled splicing increases power up to recursively enumerable languages.

**Decidability.** Membership is decidable for finite systems. Equivalence is undecidable.

### DNA tile assembly model

The abstract tile assembly model uses square tiles with glues on edges. A tile type $t$ has labels $g_n, g_e, g_s, g_w \in \Sigma$ and strengths in $\mathbb{N}$. Assemblies are partial functions $\alpha : \mathbb{Z}^2 \to T$.

A tile attaches at location $p$ if the sum of matching glue strengths with neighbors is at least a temperature threshold $\tau$.

**Computation.** Directed systems simulate deterministic Turing machines. Nondirected systems realize nondeterminism via multiple terminal assemblies.

**Complexity.** Time corresponds to assembly depth. Space corresponds to bounding box size. Polynomial size assemblies compute exactly $\mathsf{P}$ uniform families.

### Chemical reaction networks

A chemical reaction network is a pair $N = \langle S, R \rangle$ with species $S$ and reactions  
$$  
\sum_i \alpha_i X_i \to \sum_j \beta_j X_j  
$$  
where $\alpha_i, \beta_j \in \mathbb{N}$.

Under stochastic or deterministic semantics, configurations are vectors in $\mathbb{N}^{\lvert S \rvert}$.

**Computability.** Population protocols and stable CRNs compute exactly semilinear predicates, equivalent to Presburger definable sets. General CRNs simulate Turing machines.

**Decidability.** Reachability is undecidable. Stability of outputs is decidable for conservative networks.

### Language theoretic characterizations

DNA models correspond to classical language families under suitable restrictions:
- Finite splicing systems $\subsetneq$ regular languages
- Regular sticker systems $=$ regular languages
- Extended sticker systems $=$ recursively enumerable languages
- Polynomially bounded test tube systems $=$ $\mathsf{NP}$ nonuniform

### Logic and verification connections

Tile assembly systems correspond to monadic second order definable tilings. CRNs relate to vector addition systems and Petri nets, enabling transfer of reachability and coverability results.

### Related topics

- Membrane systems
- Population protocols
- Petri nets
- Register machines
- Self assembly automata

---

