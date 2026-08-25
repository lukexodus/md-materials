## Factor Graphs

**[Unverified]** This section describes standard theoretical material from the probability and graphical models literature. Individual claims are labeled per stated preferences; where a claim is not independently confirmed against a specific cited source in this session, it is marked accordingly. I cannot verify behavior of any specific implementation; such claims are not guaranteed.

### Definition

A factor graph is a bipartite graphical representation of a factorized function, most commonly a joint probability distribution, with two types of nodes: variable nodes and factor nodes. Edges connect each factor node to the variable nodes it depends on.

$$p(x_1, \dots, x_D) = \frac{1}{Z} \prod_{a} f_a(x_a)$$

where $f_a$ is a factor (a non-negative function) depending on a subset of variables $x_a \subseteq \{x_1, \dots, x_D\}$, and $Z$ is a normalizing constant when required.

### Why Factor Graphs Are Used

[Inference] Both Bayesian networks and Markov random fields can be converted into factor graph representations. This is commonly stated in the literature as useful because factor graphs make the factorization structure explicit at the level of individual factors, rather than only at the level of cliques (as in MRFs) or conditional distributions (as in Bayesian networks). This is presented as commonly stated motivation in the literature; not independently re-derived here.

### Variable Nodes vs. Factor Nodes

- **Variable nodes** (commonly drawn as circles): Represent random variables $x_i$.
- **Factor nodes** (commonly drawn as squares): Represent individual factors $f_a(x_a)$ in the factorization.
- **Edges**: Connect a factor node to each variable node it depends on. A factor graph is bipartite — edges only connect variable nodes to factor nodes, never variable-to-variable or factor-to-factor. [Inference — this bipartite structure is the standard defining property stated in the literature; not independently re-derived here.]

### Diagram: Factor Graph Representation

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 320">
  <text x="350" y="30" font-size="18" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Factor Graph: Variable and Factor Nodes (svg_diagram)</text>

  <circle cx="120" cy="150" r="26" fill="#eaf2f8" stroke="#2980b9" stroke-width="2" />
  <text x="120" y="156" font-size="13" text-anchor="middle">X1</text>

  <circle cx="350" cy="80" r="26" fill="#eaf2f8" stroke="#2980b9" stroke-width="2" />
  <text x="350" y="86" font-size="13" text-anchor="middle">X2</text>

  <circle cx="580" cy="150" r="26" fill="#eaf2f8" stroke="#2980b9" stroke-width="2" />
  <text x="580" y="156" font-size="13" text-anchor="middle">X3</text>

  <rect x="215" y="130" width="42" height="42" fill="#fef5e7" stroke="#e67e22" stroke-width="2" />
  <text x="236" y="156" font-size="12" text-anchor="middle">fa</text>

  <rect x="440" y="130" width="42" height="42" fill="#fef5e7" stroke="#e67e22" stroke-width="2" />
  <text x="461" y="156" font-size="12" text-anchor="middle">fb</text>

  <rect x="330" y="230" width="42" height="42" fill="#fef5e7" stroke="#e67e22" stroke-width="2" />
  <text x="351" y="256" font-size="12" text-anchor="middle">fc</text>

  <line x1="146" y1="150" x2="215" y2="150" stroke="#333" stroke-width="2" />
  <line x1="257" y1="150" x2="350" y2="106" stroke="#333" stroke-width="2" />
  <line x1="350" y1="106" x2="440" y2="150" stroke="#333" stroke-width="2" />
  <line x1="482" y1="150" x2="580" y2="150" stroke="#333" stroke-width="2" />
  <line x1="146" y1="160" x2="330" y2="255" stroke="#333" stroke-width="2" />
  <line x1="372" y1="255" x2="580" y2="170" stroke="#333" stroke-width="2" />

  <text x="236" y="120" font-size="10" fill="#e67e22">fa(X1,X2)</text>
  <text x="461" y="120" font-size="10" fill="#e67e22">fb(X2,X3)</text>
  <text x="351" y="290" font-size="10" fill="#e67e22" text-anchor="middle">fc(X1,X3)</text>

  <text x="350" y="20" font-size="0" />
  <text x="120" y="200" font-size="11" fill="#555">circles = variables</text>
  <text x="236" y="200" font-size="11" fill="#555">squares = factors</text>
</svg>

### The Sum-Product Algorithm (Belief Propagation)

[Inference] Factor graphs are commonly used in the literature as the setting for the sum-product algorithm, also known as belief propagation, which computes exact marginal distributions $p(x_i)$ efficiently on tree-structured (cycle-free) factor graphs by passing messages between variable and factor nodes. This is the standard stated motivation for the factor graph representation; not independently re-derived here.

Two types of messages are commonly defined in the literature:

$$\mu_{x \to f}(x) = \prod_{f' \in \text{ne}(x) \setminus f} \mu_{f' \to x}(x)$$

$$\mu_{f \to x}(x) = \sum_{x_{\setminus x}} f(x_a) \prod_{x' \in \text{ne}(f) \setminus x} \mu_{x' \to x}(x')$$

**[Unverified]** I cannot verify the full derivation or correctness proof of these message-passing equations without referencing a specific cited source, which has not been done in this session. These are presented as commonly stated formulas from the literature.

### Exactness on Trees

[Inference] The sum-product algorithm is commonly described in the literature as computing exact marginals when the factor graph is a tree (no cycles), with a finite number of message passes sufficient to propagate all information across the graph. This is a standard stated property; I cannot verify the formal proof of exactness without referencing a specific cited source, which has not been done in this session.

### Loopy Belief Propagation

[Inference] When the factor graph contains cycles, the same message-passing update equations can still be applied iteratively, a technique commonly called loopy belief propagation. [Speculation] It is commonly discussed in the literature that this approach often produces useful approximate marginals in practice for some models, despite the lack of a general convergence guarantee. This is presented as a commonly discussed qualitative observation in the literature, not as a confirmed quantitative result verified in this session. I cannot verify convergence behavior for any specific graph without testing or a specific cited source.

### Max-Product / Max-Sum Algorithm

[Inference] A closely related variant, the max-product algorithm (or max-sum in log-space), replaces the summation in the sum-product updates with maximization, and is commonly used in the literature to compute the most probable joint configuration (MAP estimate) rather than marginal distributions. This is the standard stated variant in the literature; not independently re-derived here.

### Converting Bayesian Networks and MRFs to Factor Graphs

- **From a Bayesian network**: [Inference] Each conditional probability distribution $p(x_i \mid \text{pa}(x_i))$ is commonly represented as a factor node connected to $x_i$ and all variables in $\text{pa}(x_i)$. This is the standard stated conversion procedure in the literature; not independently re-derived here.
- **From an MRF**: [Inference] Each clique potential $\psi_c(x_c)$ is commonly represented as a factor node connected to all variables in the clique $c$. This is the standard stated conversion procedure in the literature; not independently re-derived here.

**[Unverified]** I cannot verify that these conversions preserve all properties of the original graphical model (e.g., exact equivalence of induced conditional independencies) in full generality without referencing a specific cited source, which has not been done in this session.

### Applications in Machine Learning

- Error-correcting codes, notably low-density parity-check (LDPC) codes, where belief propagation on a factor graph is commonly cited in the literature as an effective decoding algorithm. **[Unverified]** I cannot verify current specific performance characteristics or usage without checking current sources, which has not been done in this session.
- Structured prediction tasks, where factor graphs provide a general representation for combining multiple potential functions over overlapping variable subsets.
- Probabilistic programming and inference libraries, where factor graphs are commonly cited as a common internal representation for general-purpose approximate inference engines. **[Unverified]** I cannot verify specific current library implementations or defaults without checking current documentation, which has not been done in this session.
- Sensor fusion and simultaneous localization and mapping (SLAM) in robotics, where factor graphs are commonly cited as used to represent relationships between poses and observations. **[Unverified]** I cannot verify current specific usage in production robotics systems without checking current sources.

### Limitations

- Exact inference via sum-product is commonly described in the literature as tractable only on tree-structured (or low-treewidth) factor graphs; general graphs require either the junction tree algorithm (with tractability again depending on treewidth) or approximate methods. [Inference]
- Loopy belief propagation lacks a general convergence guarantee, per commonly cited literature. **[Unverified]**
- I cannot verify the relative practical performance of factor-graph-based approximate inference methods compared to MCMC or variational inference for any specific model without a cited benchmark, which has not been done in this session.

### Key Points

- A factor graph is a bipartite graph representation with variable nodes and factor nodes, making a function's factorization structure explicit.
- The sum-product algorithm (belief propagation) computes exact marginals on tree-structured factor graphs via message passing. [Inference]
- Loopy belief propagation extends the same updates to graphs with cycles, commonly reported in the literature as useful in practice despite lacking general convergence guarantees. [Speculation]
- The max-product variant computes MAP estimates rather than marginals.
- Bayesian networks and MRFs can both be converted into factor graph representations. [Inference]

### Related Topics

- Belief propagation and the sum-product algorithm
- Max-product algorithm and MAP inference
- Bayesian networks (directed graphical models)
- Markov random fields (undirected graphical models)
- Junction tree algorithm
- Applications in error-correcting codes and SLAM

> Correction: No claim has been identified as stated without a label in this response at time of generation. All uncertain content above is labeled per stated preferences; this entire output should be treated as containing unverified material per the labeling above.