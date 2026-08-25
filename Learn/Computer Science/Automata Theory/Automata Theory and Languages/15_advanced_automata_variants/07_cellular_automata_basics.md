## Cellular automata basics


### Global configuration space and local rule specification

A cellular automaton CA is a quadruple $\langle d,\Sigma,N,f\rangle$ where $d\in \mathbb{N}$ is the dimension, $\Sigma$ is a finite state alphabet, $N \subset \mathbb{Z}^d$ is a finite neighborhood index set, and $f : \Sigma^{N} \to \Sigma$ is the local transition rule. A configuration is a function  
$$  
c : \mathbb{Z}^d \to \Sigma,  
$$  
so the configuration space is the full shift $\Sigma^{\mathbb{Z}^d}$ endowed with the product topology of the discrete topology on $\Sigma$. The **global map**  
$$  
F : \Sigma^{\mathbb{Z}^d} \to \Sigma^{\mathbb{Z}^d}  
$$  
is defined by  
$$  
F(c)(z) = f\big( c(z+u) : u\in N \big),\quad z\in \mathbb{Z}^d.  
$$

### Curtis–Hedlund–Lyndon characterization

For finite $\Sigma$, a map $F:\Sigma^{\mathbb{Z}^d}\to \Sigma^{\mathbb{Z}^d}$ is the global map of some cellular automaton if and only if $F$ is continuous in the product topology and commutes with all shift maps $\sigma_v$ for $v\in \mathbb{Z}^d$:  
$$  
F\circ \sigma_v = \sigma_v \circ F.  
$$  
This gives an intrinsic characterization in symbolic dynamics, independent of local presentations.

### Symbolic dynamics perspective

The pair $\langle \Sigma^{\mathbb{Z}^d},F\rangle$ is a dynamical system over a Cantor space. The **shift action** $\sigma_v$ is given by  
$$  
\sigma_v(c)(z)=c(z+v),  
$$  
and CA are precisely shift-commuting continuous endomorphisms of the full shift. Subshifts $X\subseteq \Sigma^{\mathbb{Z}^d}$ defined by forbidden finite patterns formalize language-theoretic constraints on configurations; those defined by finitely many forbidden patterns are **subshifts of finite type** SFT.

### Language of a subshift

For a subshift $X$, the associated language $L(X)\subseteq \Sigma^*$ consists of all finite patterns occurring in configurations of $X$. For one-dimensional SFTs, $L(X)$ is a regular language recognized by a finite directed labeled graph; minimal deterministic presentations correspond to Fischer covers and Krieger covers. Entropy of $X$ coincides with growth rate of $|L(X)\cap \Sigma^n|$.

### Reversibility, injectivity, and surjectivity

For one-dimensional CA over finite $\Sigma$:
- surjectivity $\Leftrightarrow$ preinjectivity (Moore–Myhill Garden-of-Eden theorem)
- injectivity $\Rightarrow$ surjectivity
- injective global maps are reversible CA with a CA inverse
    

Garden-of-Eden theorem: the following are equivalent for $F$ on $\Sigma^{\mathbb{Z}^d}$:
1. $F$ is surjective
2. $F$ is preinjective, i.e., has no mutually erasable finite-difference configurations
3. there are no Garden-of-Eden configurations forbidden from the image
    

In dimensions $d\ge 2$, injectivity does not imply surjectivity for general continuous endomorphisms, but the equivalence above holds for CA.

### Decidability and complexity of structural properties

For one-dimensional CA:
- surjectivity is decidable
- injectivity is decidable
- reversibility is decidable
- nilpotency is undecidable for $d\ge 2$; decidable for $d=1$
    

For $d\ge 2$, strong undecidability emerges:
- surjectivity is undecidable
- injectivity is undecidable
- mortality and nilpotency problems are $\Sigma_1^0$-complete
- equality of global maps is undecidable under succinct local-rule encodings
    

Reductions commonly proceed from tiling problems and $PCP$ via space-time diagram encodings.

### Limit sets, attractors, and $\omega$-limit languages

The limit set  
$$  
\Omega(F)=\bigcap_{n\ge 0} F^n(\Sigma^{\mathbb{Z}^d})  
$$  
collects configurations with infinite backward orbits. The language of $\Omega(F)$ captures asymptotically persistent patterns; its membership problem is often undecidable for $d\ge 2$. Decision questions about stability, asymptotic nilpotency, and reachability relate to arithmetical hierarchy levels of the induced languages of space-time diagrams.

### Space-time diagrams and automata connections

A space-time diagram is a function  
$$  
D : \mathbb{Z}^d \times \mathbb{Z}_{\ge 0} \to \Sigma  
$$  
satisfying the local constraint induced by $f$. The set of finite patterns occurring in diagrams forms a language definable by local constraints; for $d=1$, these are two-dimensional SFTs. Acceptance by tiling systems and tree automata connects CA evolution constraints to recognizable picture languages and monadic second-order definability.

### Computational universality

There exist one-dimensional CA that are Turing universal. Formally, there are CA whose finite patterns encode instantaneous descriptions of Turing machines with simulation preserved by $F$. Consequences:
- reachability of a pattern is $\Sigma_1^0$-complete in general
- prediction problems for universal CA are $\text{P}$-hard, often $\text{PSPACE}$-complete under natural encodings
- intrinsic simulation quasiorder induces degree structures resembling Turing degrees

### Entropy and growth rates

Topological entropy of a CA or subshift measures exponential growth of admissible blocks:  
$$  
h(X)=\lim_{n\to\infty} \frac{1}{n}\log |L(X)\cap \Sigma^n|.  
$$  
For $d\ge 2$, entropy values of SFTs can be $\Pi_1^0$-hard to approximate. In $d=1$ SFTs, entropy is computable from the Perron eigenvalue of the adjacency matrix of a presenting graph.

### Relationships to logic and decidability

- MSO definability over grids characterizes picture languages arising from two-dimensional CA
- first-order theories of subshifts relate to automatic structures
- validity and model-checking problems over configuration graphs connect to $\omega$-automatic structures and Büchi automata

### Radius, block maps, and conjugacies

Radius of $F$ is the minimal $r$ such that $N \subseteq { z : |z|_\infty \le r}$. Block maps between subshifts are continuous shift-commuting maps, captured by local rules. Topological conjugacy classes of CA are studied via sliding block codes; invariants include entropy, zeta functions, and periodic point counts.

### Periodicity and fixed points

Periodicity questions:
- existence of fixed points and periodic points under $F$
- classification of ultimately periodic configurations  
    Counting periodic points of period $n$ connects to traces of powers of adjacency matrices in one-dimensional SFT presentations and to zeta functions of subshifts.
    

### Higher-dimensional phenomena

For $d\ge 2$, qualitative changes include:
- undecidable tiling problems encoding CA behavior
- existence of aperiodic SFTs with no periodic configurations
- intrinsic universality more robust via planar wiring of simulations
    

Hierarchical structure of Wang tilings and domino problems embeds CA decision problems into $\Sigma_1^0$ and $\Pi_1^0$ levels.

### Related topics

Symbolic dynamics  
Subshifts of finite type  
Garden-of-Eden theorem  
Reversible cellular automata  
Picture languages  
Wang tilings  
Post correspondence problem  
Limit sets and attractors

---

