## Bayesian Networks

**[Unverified]** This section describes standard theoretical material from the probability and graphical models literature. Individual claims are labeled per stated preferences; where a claim is not independently confirmed against a specific cited source in this session, it is marked accordingly. Behavior claims about any specific system or implementation are not guaranteed.

### Definition

A Bayesian network is a probabilistic graphical model that represents a joint probability distribution over a set of random variables using a directed acyclic graph (DAG), where nodes represent variables and directed edges represent direct probabilistic dependencies.

$$p(x_1, x_2, \dots, x_D) = \prod_{i=1}^{D} p(x_i \mid \text{pa}(x_i))$$

where $\text{pa}(x_i)$ denotes the set of parent nodes of $x_i$ in the graph.

### Core Components

- **Nodes**: Represent random variables (discrete or continuous).
- **Directed edges**: Represent a direct probabilistic dependency from parent to child; an edge from $A$ to $B$ indicates $A$ is a direct cause or predictor within the model's structure.
- **Conditional probability distributions (CPDs)**: Each node stores $p(x_i \mid \text{pa}(x_i))$, specifying the node's distribution given its parents.
- **Acyclicity constraint**: The graph must contain no directed cycles, which is what allows the factorization above to define a valid joint distribution. [Inference — this is the standard stated requirement in the literature; the formal proof of why acyclicity is required is not independently reproduced here.]

### Factorization and the Chain Rule

[Inference] The factorization shown above follows from repeated application of the chain rule of probability, combined with conditional independence assumptions encoded by the graph structure (each variable is assumed conditionally independent of its non-descendants given its parents). This is the standard derivation presented in the literature; it has not been independently reproduced or checked against a specific cited proof in this session.

### Conditional Independence and D-Separation

A key property of Bayesian networks is that the graph structure encodes conditional independence statements between variables. The formal criterion used in the literature to read off these independencies from the graph is called **d-separation**.

Three canonical structures determine how information flows through a path:

- **Chain** ($A \to B \to C$): $A$ and $C$ are conditionally independent given $B$. [Inference — standard stated property in the literature; not independently re-derived here.]
- **Fork** ($A \leftarrow B \to C$): $A$ and $C$ are conditionally independent given $B$. [Inference — same caveat.]
- **Collider** ($A \to B \leftarrow C$): $A$ and $C$ are marginally independent, but become dependent when conditioning on $B$ (or any descendant of $B$). [Inference — this is commonly described in the literature as counterintuitive relative to the chain and fork cases; not independently re-derived here.]

**[Unverified]** I cannot verify the full formal definition of d-separation for arbitrary graph structures beyond these canonical cases without referencing a specific cited source, which has not been done in this session.

### Diagram: Canonical Structures

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 320">
  <text x="350" y="30" font-size="18" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Canonical Bayesian Network Structures (svg_diagram)</text>

  <text x="100" y="70" font-size="13" text-anchor="middle" fill="#1a1a1a" font-weight="bold">Chain</text>
  <circle cx="50" cy="130" r="22" fill="#eaf2f8" stroke="#2980b9" stroke-width="2" />
  <text x="50" y="135" font-size="13" text-anchor="middle">A</text>
  <line x1="72" y1="130" x2="118" y2="130" stroke="#333" stroke-width="2" marker-end="url(#arrowbn)" />
  <circle cx="140" cy="130" r="22" fill="#fef5e7" stroke="#e67e22" stroke-width="2" />
  <text x="140" y="135" font-size="13" text-anchor="middle">B</text>
  <line x1="162" y1="130" x2="208" y2="130" stroke="#333" stroke-width="2" marker-end="url(#arrowbn)" />
  <circle cx="230" cy="130" r="22" fill="#eaf2f8" stroke="#2980b9" stroke-width="2" />
  <text x="230" y="135" font-size="13" text-anchor="middle">C</text>

  <text x="380" y="70" font-size="13" text-anchor="middle" fill="#1a1a1a" font-weight="bold">Fork</text>
  <circle cx="380" cy="90" r="22" fill="#fef5e7" stroke="#e67e22" stroke-width="2" />
  <text x="380" y="95" font-size="13" text-anchor="middle">B</text>
  <line x1="365" y1="108" x2="325" y2="150" stroke="#333" stroke-width="2" marker-end="url(#arrowbn)" />
  <line x1="395" y1="108" x2="435" y2="150" stroke="#333" stroke-width="2" marker-end="url(#arrowbn)" />
  <circle cx="310" cy="170" r="22" fill="#eaf2f8" stroke="#2980b9" stroke-width="2" />
  <text x="310" y="175" font-size="13" text-anchor="middle">A</text>
  <circle cx="450" cy="170" r="22" fill="#eaf2f8" stroke="#2980b9" stroke-width="2" />
  <text x="450" y="175" font-size="13" text-anchor="middle">C</text>

  <text x="600" y="70" font-size="13" text-anchor="middle" fill="#1a1a1a" font-weight="bold">Collider</text>
  <circle cx="540" cy="170" r="22" fill="#eaf2f8" stroke="#2980b9" stroke-width="2" />
  <text x="540" y="175" font-size="13" text-anchor="middle">A</text>
  <circle cx="680" cy="170" r="22" fill="#eaf2f8" stroke="#2980b9" stroke-width="2" />
  <text x="680" y="175" font-size="13" text-anchor="middle">C</text>
  <line x1="558" y1="155" x2="592" y2="115" stroke="#333" stroke-width="2" marker-end="url(#arrowbn)" />
  <line x1="662" y1="155" x2="628" y2="115" stroke="#333" stroke-width="2" marker-end="url(#arrowbn)" />
  <circle cx="610" cy="95" r="22" fill="#fdecea" stroke="#c0392b" stroke-width="2" />
  <text x="610" y="100" font-size="13" text-anchor="middle">B</text>

  <text x="100" y="200" font-size="10" text-anchor="middle" fill="#555">A ⊥ C | B</text>
  <text x="380" y="220" font-size="10" text-anchor="middle" fill="#555">A ⊥ C | B</text>
  <text x="610" y="220" font-size="10" text-anchor="middle" fill="#555">A ⊥ C (marginally)</text>

  </svg>

### Worked Example

Consider a simple network with three binary variables: $R$ (Rain), $S$ (Sprinkler), $G$ (Grass Wet), where $R \to S$, $R \to G$, $S \to G$. The joint distribution factorizes as:

$$p(R, S, G) = p(R) \, p(S \mid R) \, p(G \mid R, S)$$

Given specified conditional probability tables for each factor, the network allows computation of quantities such as $p(R \mid G = \text{true})$ via Bayes' rule and marginalization over $S$. [Inference — this is the standard illustrative example commonly used in introductory graphical models material; the specific numeric conditional probability tables have not been supplied or computed here, so no numeric result is being claimed.]

### Inference in Bayesian Networks

Inference refers to computing conditional probabilities of unobserved variables given observed evidence, e.g., $p(x_i \mid x_{\text{evidence}})$.

- **Exact inference**: Methods such as variable elimination and the junction tree algorithm compute exact conditional probabilities by exploiting the graph's factorization structure. [Inference — standard stated methods in the literature; not independently re-derived here.] **[Unverified]** Exact inference is commonly described in the literature as computationally intractable in general for densely connected graphs (a property related to graph treewidth), though the specific complexity for any given network structure is not established here.
- **Approximate inference**: When exact inference is intractable, methods such as MCMC (including Gibbs sampling, applicable when full conditionals are tractable) and variational inference are commonly used, as covered in prior sections.

### Learning in Bayesian Networks

Two distinct learning problems are commonly discussed in the literature:

- **Parameter learning**: Given a fixed graph structure, estimate the conditional probability distributions (CPDs) from data, e.g., via maximum likelihood estimation or Bayesian estimation with priors over CPD parameters.
- **Structure learning**: Given data, infer the graph structure itself. Commonly cited approaches include score-based search (optimizing a model selection criterion such as BIC) and constraint-based methods (using conditional independence tests to infer edges). **[Unverified]** I cannot verify the relative performance or current best practices among these approaches without a cited benchmark, which has not been done in this session.

### Bayesian Networks vs. Other Graphical Models

- **Markov random fields (undirected graphical models)**: Represent joint distributions via undirected edges and factor potentials rather than directed conditional distributions; used when directionality/causal interpretation is not appropriate or available. [Inference — standard contrast made in the literature; not independently re-derived here.]
- **Hidden Markov Models**: A specific, simple case of a dynamic Bayesian network with a chain structure over discrete latent states evolving over time. **[Unverified]** This characterization is commonly stated in the literature; not independently re-derived here.

### Applications in Machine Learning

- Diagnostic and expert systems, where observed symptoms are used to infer probable underlying causes.
- Probabilistic graphical models for structured prediction tasks.
- Causal inference research, where the DAG structure is sometimes given a causal interpretation (distinct from purely statistical/associational Bayesian network usage). **[Unverified]** Whether a specific Bayesian network structure represents a valid causal model depends on strong additional assumptions not guaranteed by the graphical formalism alone; this distinction is commonly discussed in the causal inference literature and is not established generally here.
- Naive Bayes classifiers, a specific simple Bayesian network structure with a single class variable as parent of all feature variables, assuming conditional independence of features given the class.

### Limitations

- Exact inference is commonly described in the literature as computationally intractable for large, densely connected graphs. **[Unverified]**
- Requires specifying (or learning) a graph structure, which for complex domains is commonly discussed as a difficult modeling problem in itself. [Speculation]
- The directed edges do not necessarily imply causation unless additional causal assumptions are made; this distinction is commonly emphasized in the causal inference literature. [Inference]

### Key Points

- A Bayesian network factorizes a joint distribution using a directed acyclic graph and per-node conditional distributions.
- D-separation, via chain, fork, and collider structures, determines conditional independence relationships encoded by the graph.
- Inference can be exact (variable elimination, junction tree) or approximate (MCMC, variational inference), depending on graph complexity.
- Parameter learning and structure learning are distinct problems, each with multiple commonly cited approaches.
- Directed edges represent statistical dependency in the model; a causal interpretation requires additional assumptions not guaranteed by the graphical formalism alone.

### Related Topics

- D-separation and conditional independence
- Variable elimination and exact inference algorithms
- Hidden Markov Models
- Naive Bayes classifiers
- Markov random fields
- Causal inference and structural causal models