## Circuit complexity relationships


**Boolean circuits and resource measures.**  
Directed acyclic graphs with input nodes, internal gates from a finite basis such as ${\land,\lor,\lnot}$, and one or more output nodes. Size is the number of gates. Depth is the length of the longest path from an input to an output. Fan-in constraints (constant versus unbounded) and uniformity constraints determine the associated complexity classes. Uniformity typically uses $DLOGTIME$-uniformity: a deterministic log-time Turing machine outputs local circuit descriptions.

**Nonuniform computation and $P/poly$.**  
Language $L$ lies in $P/poly$ if there exists a family ${C_n}$ of Boolean circuits of size $\operatorname{poly}(n)$ deciding $L\cap{0,1}^n$. Simulation of polynomial-time Turing machines by circuits yields  
$$P \subseteq P/poly.$$  
Nonuniformity is strictly more expressive: $P/poly$ contains undecidable languages via diagonalization with advice encoded into circuits of each input length.

**Circuit classes and inclusions.**  
Define
- $AC^0$: constant depth, polynomial size, unbounded fan-in $\land,\lor,\lnot$
- $ACC^0$: as $AC^0$ with unbounded fan-in $\operatorname{MOD}_m$ gates for fixed $m \ge 2$
- $TC^0$: constant depth, polynomial size, threshold (majority) gates
- $NC^1$: depth $O(\log n)$, polynomial size, fan-in two
- $NC$: depth $\operatorname{polylog}(n)$, polynomial size, fan-in two
    

Standard inclusions:  
$$AC^0 \subseteq ACC^0 \subseteq TC^0 \subseteq NC^1 \subseteq NC \subseteq P \subseteq P/poly.$$

**Formulas versus circuits and $NC^1$.**  
Boolean formulas are tree circuits. Any polynomial-size $NC^1$ circuit can be balanced and converted to polynomial-size formulas of depth $O(\log n)$; conversely, Spira’s balancing theorem gives the reverse direction, establishing  
$$NC^1 = \text{poly-size Boolean formulas of depth }O(\log n).$$

**Karchmer–Wigderson correspondence.**  
Formula depth of a Boolean function equals the deterministic communication complexity of its associated monotone or nonmonotone Karchmer–Wigderson game. Consequence: lower bounds in communication complexity yield formula depth lower bounds and hence $NC^1$ separations.

**Depth reduction and size–depth tradeoffs.**  
Any polynomial-size circuit of depth $d$ can be rebalanced to depth $O(\log s)$ with polynomial blowup in size. Tradeoffs imply that superpolynomial depth reduction would entail superpolynomial size increases, constraining parallelizability.

**Lower bounds and hierarchy separations.**

_Shannon counting argument._  
Number of Boolean functions on $n$ bits is $2^{2^n}$, while the number of Boolean circuits of size $s$ is at most $2^{O(s\log s)}$. Therefore almost all Boolean functions require size  
$$\Omega!\left(\frac{2^n}{n}\right).$$

_$AC^0$ lower bounds via random restrictions._  
Håstad’s switching lemma yields optimal lower bounds for constant-depth circuits, implying  
$$\text{PARITY} \notin AC^0,$$  
and the $AC^0$ hierarchy theorem: for fixed depth $d$, there are functions in $AC^{0}_{d+1}$ not in $AC^{0}_d$ under polynomial-size restrictions. Consequence:  
$$AC^0 \subsetneq NC^1.$$

_$ACC^0$ modular lower bounds._  
Smolensky’s theorem: for coprime $m,p$,  
$$\operatorname{MOD}_p \notin ACC^0[\operatorname{MOD}_m],$$  
using low-degree polynomial approximations over finite fields.

_Nontrivial separations beyond $ACC^0$._  
Williams’ algorithmic method establishes  
$$NEXP \not\subseteq ACC^0,$$  
a major nonuniform lower bound with algebraic and satisfiability-based consequences.

_Monotone versus nonmonotone circuits._  
Monotone circuit complexity can be exponentially larger than general circuit complexity. Razborov’s lower bounds for $\text{CLIQUE}$ and related functions show exponential monotone circuit size while nonmonotone circuits remain polynomial for many such functions.

**Threshold and majority.**  
$TC^0$ strictly contains $AC^0$ because $\text{MAJORITY}$ lies in $TC^0$ and not in $AC^0$. Known upper bounds include integer addition, iterated multiplication, and division in uniform $TC^0$ via threshold circuits.

**ACC gates and parity.**  
Parity is in $ACC^0$ when $\operatorname{MOD}_2$ gates are present; without $\operatorname{MOD}_2$, parity is excluded by modular lower bounds, emphasizing sensitivity of class power to gate sets.

**Uniformity and descriptive complexity correspondences.**  
For $DLOGTIME$-uniform classes:
- uniform $AC^0$ coincides with first-order logic with built-in arithmetic predicates such as $<$, $+$, $\times$ over finite structures
- uniform $NC^1$ corresponds to first-order logic with transitive closure  
    Such logical characterizations place circuit classes within descriptive complexity and finite model theory.
    

**Relationships with Turing-machine complexity.**

_Simulation of circuits by Turing machines._  
Polynomial-size log-depth circuits yield polylogarithmic parallel time. Conversely, uniformity constraints ensure polynomial-time constructibility.

_Karp–Lipton collapse._  
If  
$$NP \subseteq P/poly,$$  
then the polynomial hierarchy collapses to its second level $\Sigma_2^P$, via advice-taking simulations and quantified circuit families.

_Circuit value and satisfiability problems._  
Circuit Value Problem is $P$-complete under logspace reductions. Circuit SAT is $NP$-complete under Karp reductions, relating nonuniform computation to uniform reducibility and completeness.

**Pseudorandomness and natural proofs barrier.**  
Razborov–Rudich show that a broad class of “natural” proof techniques for circuit lower bounds would contradict strong pseudorandom generators. This identifies limits of current lower-bound methods for classes approaching $P$ or $NP$.

**Formula, branching program, and communication relations.**  
Branching programs characterize space-bounded computation; size and width correspond to $NC^1$ and $L$ in various restricted models. Lower bounds often use communication complexity or information complexity to separate models such as formulas versus bounded-width branching programs.

**Connections to automata and regular computations.**  
Constant-depth $AC^0$ corresponds to regular languages under majority-free first-order definability; $NC^1$ connects to word problems of finite monoids of limited alternation depth via algebraic automata theory. Circuit classes map to varieties of finite semigroups through the Straubing–Thérien hierarchy.

**Open and resolved separations.**  
Resolved: $AC^0 \subsetneq NC^1.$  
Unresolved: $NC^1$ versus $P$, $ACC^0$ versus $NC^1$, $TC^0$ versus $NC^1$, $P$ versus $NP$, $P$ versus $NC.$  
Nonuniform lower bounds beyond $ACC^0$ remain largely open for general $\operatorname{poly}(n)$-size circuits.

**Related topics (no explanations).**
- Boolean formulas and balancing
- Karchmer–Wigderson games
- Random restriction method
- Polynomial approximation method
- Descriptive complexity and FO with arithmetic
- Arithmetic circuits and depth reduction
- Monotone circuit complexity
- Communication complexity
- Branching programs and ordered binary decision diagrams
- Natural proofs barrier
- Circuit SAT and CVP completeness
- Advice classes and nonuniform hierarchies

---

