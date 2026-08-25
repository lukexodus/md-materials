## Graphs and Trees (Basics)


### Formal Definitions and Structural Constraints

* **Graphs.** A graph is a pair $G = (V,E)$ where $E \subseteq V \times V$. Undirected graphs satisfy $(u,v) \in E \Rightarrow (v,u) \in E$; directed graphs allow asymmetric edges. Multigraphs and labeled graphs generalize via labeling functions $\lambda_V: V \to \Sigma_V$ and $\lambda_E: E \to \Sigma_E$.
* **Degree-boundedness and sparsity.** Degree bounds and sparsity constraints (planarity, minor exclusion) influence MSO-definability, automata-based decision procedures, and parameterized complexity via treewidth and branchwidth.
* **Trees.** A rooted tree is a connected acyclic directed graph with designated root $r$ such that every node other than $r$ has indegree $1$. Ranked trees assign fixed arities, unranked trees allow arbitrary branching, and ordered trees impose a sibling order.

### Language-Theoretic Placement

* **Tree languages.** Sets of finite trees over ranked alphabets. Regular tree languages are recognized by finite-state tree automata and strictly extend regular word languages under the yield mapping.
* **Graph languages.** Sets of finite graphs closed under isomorphism. Generative mechanisms include HR-grammars, VR-grammars, NCE graph grammars, and hyperedge-replacement versus node-replacement formalisms; encodings relate these to context-free word languages.

### Automata on Trees and Graphs

* **Bottom-up and top-down finite tree automata.** Deterministic and nondeterministic variants; nondeterministic and deterministic bottom-up automata are equivalent in expressive power, whereas deterministic top-down automata are strictly weaker than their nondeterministic counterparts.
* **Alternating tree automata.** Characterize $\mu$-calculus model checking; determinization entails exponential blowups and index transformations.
* **Weighted tree automata.** Semiring-weighted recognition with closure properties dependent on semiring assumptions such as commutativity and completeness.
* **Graph-walking automata.** Navigational automata over graph structures; comparison with MSO-definability, pebble automata, and pointer-machine models highlights expressive limitations.

### Expressive Power and Logical Characterizations

* **Words vs. trees.** Regular word languages coincide with MSO-definable sets over linear orders, $$\text{REG} = \text{MSO}(,<,)$$
* **Regular tree languages.** Exactly MSO-definable sets of finite trees and equivalently recognized by deterministic parity tree automata.
* **Courcelle-type characterizations.** MSO-definable properties over bounded-treewidth graphs are decidable via tree automata constructions; clique-width distinctions arise between $\text{MSO}_1$ and $\text{MSO}_2$.
* **FO vs. MSO.** Strict hierarchy on trees; locality theorems (Gaifman, Hanf) yield automata-theoretic consequences and lower bounds.

### Closure Properties

* **Regular tree languages** are closed under Boolean operations, homomorphisms respecting rank, inverse homomorphisms, relabelings, tree substitution, and projections.
* **Graph languages from HR-grammars** are closed under disjoint union and substitution; complement is not generally closed; contrasts with VR-grammars yield strict inclusions in several cases.

### Normal Forms and Transformations

* **Tree automata normal forms.** Completion, reduction, determinization, and $\epsilon$-rule elimination for tree grammars; conversions preserve recognized languages with known complexity bounds.
* **Graph grammars.** HR-grammars admit normal forms eliminating useless productions and chain rules; confluence constraints ensure uniqueness of generated graphs modulo isomorphism.

### Decidability and Undecidability Results

* **Trees.** Emptiness, finiteness, inclusion, and equivalence for regular tree languages are decidable. Inclusion and equivalence for nondeterministic tree automata are EXPTIME-complete.
* **Graphs.** Inclusion and equivalence for general graph grammars are undecidable via reductions from PCP and Turing machine halting encoded through graph productions.
* **Monadic second-order theories.** MSO over finite trees is decidable, MSO over arbitrary graphs is undecidable, and bounded treewidth yields decidability through automata-based decompositions.

### Complexity Bounds

* **Emptiness for finite tree automata:** PTIME with linear dependence on automaton size.
* **Determinization of tree automata:** entails exponential blowup; parity-to-Rabin/Streett index conversions incur exponential cost.
* **MSO model checking on bounded treewidth graphs:** fixed-parameter tractable with linear dependence on graph size and elementary dependence on formula size, conditioned lower bounds via ETH.
* **Graph reachability:** NL-complete in directed graphs and fundamental for reductions to automata nonemptiness and temporal-logic model checking.

### Pumping and Incomparability Arguments

* **Tree pumping lemma.** For regular tree languages there exist height-bounded pumpable contexts ensuring language preservation upon iteration; used to prove non-regularity of tree sets violating MSO-definable constraints.
* **Graphs.** No uniform pumping lemma for arbitrary graph families; minor theory, treewidth arguments, and width measures substitute for pumping in non-definability and lower-bound proofs.

### Reductions and Completeness

* **Tree–word encodings.** Unary-branching tree encodings preserve regularity and context-freeness, transferring hardness results for inclusion and equivalence problems.
* **Graph problems.** Reductions from halting and PCP demonstrate undecidability of graph grammar equivalence; reachability reductions establish hardness for model checking on transition graphs.

### Trees in Grammars and Parsing

* **Derivation and parse trees.** Unambiguous context-free grammars yield unique parse trees whose yields are strings; CYK and related algorithms operate on shared packed parse forests interpretable as automata over trees.
* **Mildly context-sensitive tree formalisms.** Tree-adjoining grammars and higher-order tree grammars increase expressiveness beyond context-free while maintaining polynomial parsing for several subclasses.

### Relationships to Verification

* **Transition systems.** Modeled as graphs with reachability, simulation, and bisimulation relations expressed automata-theoretically; safety and liveness verification correspond to automata acceptance over paths or trees.
* **Tree models.** Infinite branching behaviors captured by $\omega$-tree automata with parity, Rabin, or Streett conditions aligned with $\mu$-calculus specifications.

### Related Topics (no elaboration)

* Hyperedge-replacement grammars
* Node-replacement grammars
* Regular tree grammars
* Treewidth and branchwidth
* Courcelle’s theorem
* Monadic second-order logic over graphs and trees
* Parity, Rabin, and Streett tree automata
* Pebble automata on graphs
* Infinite trees and $\omega$-tree automata

---

