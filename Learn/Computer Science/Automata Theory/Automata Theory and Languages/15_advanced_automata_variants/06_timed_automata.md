## Timed automata


### Formal model

A timed automaton is a tuple  
$A = \langle L , \ell_0 , C , \Sigma , E , \mathrm{Inv} \rangle$  
where $L$ is a finite set of locations, $\ell_0 \in L$ is the initial location, $C$ is a finite set of real-valued clocks, $\Sigma$ is a finite alphabet, $E \subseteq L \times \Sigma \times \Phi C \times 2^C \times L$ is a finite set of edges, and $\mathrm{Inv} : L \to \Phi C$ assigns invariants to locations.

$\Phi C$ denotes conjunctions of atomic constraints of the form  
$x \bowtie c$ or $x - y \bowtie c$  
with $x , y \in C$, $c \in \mathbb{Z}$, and $\bowtie \in { < , \le , = , \ge , > }$.

A configuration is a pair $\langle \ell , \nu \rangle$ where $\ell \in L$ and $\nu : C \to \mathbb{R}_{\ge 0}$ is a clock valuation satisfying $\mathrm{Inv} \ell$.

Analogy: locations are rooms, clocks are stopwatches that run uniformly, invariants are deadlines attached to rooms, and edges are doors guarded by time constraints.

### Operational semantics

Two kinds of transitions are defined.

**Delay transitions**

For $d \in \mathbb{R}_{\ge 0}$,

$$  
\langle \ell , \nu \rangle \xrightarrow{d} \langle \ell , \nu + d \rangle  
$$

iff for all $0 \le d' \le d$, $\nu + d'$ satisfies $\mathrm{Inv} \ell$.

**Discrete transitions**

For $e = \langle \ell , a , g , R , \ell' \rangle \in E$,

$$  
\langle \ell , \nu \rangle \xrightarrow{a} \langle \ell' , \nu[R := 0] \rangle  
$$

iff $\nu$ satisfies $g$ and $\nu[R := 0]$ satisfies $\mathrm{Inv} \ell'$.

A run is an alternating sequence of delay and discrete transitions. Acceptance is defined via designated accepting locations or Büchi conditions in the infinite-word case.

### Timed languages and expressiveness

The semantics of a timed automaton is a timed language  
$L A \subseteq \Sigma \times \mathbb{R}_{\ge 0}$-words, consisting of sequences  
$a_1 t_1 a_2 t_2 \ldots$  
with nondecreasing time stamps.

Timed automata strictly extend finite automata. They can express punctual constraints such as exact delays and bounded response properties not definable in regular languages.

Timed automata are less expressive than general hybrid automata but strictly more expressive than event-recording automata.

### Region equivalence and finiteness

Define a maximal constant $M$ as the largest absolute constant appearing in any clock constraint.

Two valuations $\nu$ and $\nu'$ are region-equivalent if:
- either $\nu x > M$ and $\nu' x > M$, or $\lfloor \nu x \rfloor = \lfloor \nu' x \rfloor$
- ordering of fractional parts of clocks is identical
- fractional part zero tests coincide
    

This equivalence partitions $\mathbb{R}_{\ge 0}^{|C|}$ into finitely many regions.

The **region automaton** has states $L \times \mathcal{R}$ where $\mathcal{R}$ is the set of regions. Reachability is preserved under this abstraction.

Analogy: continuous time is sliced into finitely many time zones, each zone summarizing infinitely many exact clock values.

### Decidability results

**Reachability**

Given a timed automaton $A$ and target location $\ell_f$, the reachability problem  
$\exists$ run reaching $\ell_f$  
is decidable and PSPACE-complete.

**Language emptiness**

Emptiness of timed automata languages is decidable via region or zone construction.

**Universality and equivalence**

Language universality and equivalence are undecidable for nondeterministic timed automata.

Deterministic timed automata are not closed under complementation.

### Zone-based symbolic analysis

Instead of regions, practical analysis uses zones, represented as convex sets of valuations definable by difference-bound matrices.

Zones are closed under time elapse, intersection with guards, and reset operations.

Symbolic reachability explores the graph of symbolic states  
$\langle \ell , Z \rangle$  
where $Z$ is a zone.

Zones yield potentially infinite state graphs; finiteness is restored via extrapolation operators based on $M$.

### Closure properties

Timed automata languages are closed under:
- union
- intersection
    

They are not closed under:
- complementation
- determinization
    

This asymmetry sharply contrasts with regular languages.

### Comparison with other models

Timed automata versus pushdown automata:
- timed automata add dense time but no unbounded discrete memory
- pushdown automata add unbounded stack but no quantitative time
    

Timed automata versus counter machines:
- clocks evolve synchronously and continuously
- counters evolve discretely and independently
    

Timed automata can be encoded into restricted hybrid automata, preserving reachability.

### Complexity-theoretic perspective

Although region graphs are exponential in the number of clocks, reachability remains PSPACE-complete due to symbolic compression.

Adding features such as diagonal constraints or stopwatch clocks preserves decidability, while unrestricted hybrid dynamics leads to undecidability.

### Extensions and variants

- Timed Büchi automata
- Event-recording automata
- Event-predicting automata
- Stopwatch automata
- Parametric timed automata
    

Many extensions trade expressiveness for decidability or complexity bounds.

### Logical characterization

Timed automata correspond to fragments of timed temporal logics such as TCTL over dense time.

Existential path quantification with bounded clocks yields PSPACE-complete model checking.

### Verification significance

Timed automata provide a mathematically precise model for real-time systems where correctness depends on quantitative timing constraints, forming the theoretical foundation of real-time model checking.

### Related topics

Region automata  
Zones and difference-bound matrices  
Timed temporal logics  
Hybrid automata  
Real-time model checking  
Parametric verification

---

