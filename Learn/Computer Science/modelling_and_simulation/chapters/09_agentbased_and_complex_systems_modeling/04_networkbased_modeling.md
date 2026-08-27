## Network-Based Modeling

### Overview

Network-based modeling represents a system as a graph of nodes (vertices) and edges (links), where the topology of connections — rather than spatial proximity alone — governs how entities interact, influence one another, and propagate effects. In modeling and simulation, network-based approaches are used both as a standalone modeling paradigm (e.g., epidemiology on contact networks, information diffusion on social networks) and as an interaction substrate underlying agent-based models, replacing or supplementing grid-based or continuous-space neighborhoods.

### Formal Definition

A network (graph) is defined as:

$$
G = (V, E)
$$

where $V$ is the set of nodes (vertices) and $E \subseteq V \times V$ is the set of edges (links) connecting pairs of nodes. Additional structure is often added:

- **Weighted networks**: each edge $e \in E$ has an associated weight $w(e)$, representing interaction strength, distance, or capacity
- **Directed networks**: edges have direction, $(i \rightarrow j) \neq (j \rightarrow i)$, representing asymmetric relationships (e.g., "follows," "influences")
- **Attributed networks**: nodes and/or edges carry additional properties (e.g., node type, edge creation time)
- **Multilayer/multiplex networks**: multiple distinct edge types or layers connect the same node set (e.g., a "friendship" layer and a "work" layer)

### Key Network Topologies

**Regular Lattice**
Every node connects to a fixed number of geometrically nearby neighbors (e.g., a ring or grid lattice). High clustering, but long average path lengths.

**Random Network (Erdős–Rényi)**
Edges are placed between node pairs independently with fixed probability $p$.

$$
P(k) = \binom{n-1}{k} p^{k} (1-p)^{n-1-k}
$$

Degree distribution approximates a Poisson distribution for large $n$; low clustering, short average path length.

**Small-World Network (Watts-Strogatz)**
Constructed by starting from a regular lattice and randomly rewiring a small fraction of edges. Produces networks with **high clustering** (like lattices) *and* **short average path length** (like random networks) — the hallmark "small-world" property observed in many real social and biological networks.

**Scale-Free Network (Barabási-Albert)**
Generated via **preferential attachment**: new nodes are more likely to connect to already highly-connected nodes ("rich get richer"). Produces a power-law degree distribution:

$$
P(k) \sim k^{-\gamma}
$$

typically with $2 < \gamma < 3$ for real-world networks. Characterized by a small number of highly connected "hub" nodes and many low-degree nodes.

```mermaid
flowchart TD
    A[Choose Network Generation Model (svg_diagram)] --> B{Topology Type}
    B -->|Regular| C[Lattice]
    B -->|Random| D[Erdos-Renyi]
    B -->|Rewired Lattice| E[Watts-Strogatz Small-World]
    B -->|Preferential Attachment| F[Barabasi-Albert Scale-Free]
    C --> G[Assign Node/Edge Attributes]
    D --> G
    E --> G
    F --> G
    G --> H[Run Dynamic Process on Network]
```

### Structural Metrics

**Degree and Degree Distribution**
$k_i$, the number of edges incident to node $i$; the distribution $P(k)$ across the whole network characterizes overall connectivity structure and heavily influences dynamic processes (e.g., disease spread, cascade failure).

**Clustering Coefficient**
Measures the extent to which a node's neighbors are also connected to each other:

$$
C_i = \frac{2 e_i}{k_i (k_i - 1)}
$$

where $e_i$ is the number of edges actually present among node $i$'s neighbors, and $k_i(k_i-1)/2$ is the maximum possible number of such edges.

**Average Path Length**
The mean shortest-path distance between all pairs of nodes; short average path length underlies the "six degrees of separation" phenomenon observed in many social networks.

**Centrality Measures**
- *Degree centrality*: number of direct connections
- *Betweenness centrality*: how often a node lies on shortest paths between other node pairs (identifies "bridge" or "broker" nodes)
- *Closeness centrality*: inverse of the average shortest-path distance to all other nodes
- *Eigenvector centrality / PageRank*: importance weighted by the importance of one's neighbors, not just their count

**Community Structure (Modularity)**
Many real networks exhibit densely connected sub-groups (communities) with sparser connections between groups. Modularity $Q$ quantifies the strength of a given community partition relative to a random null model:

$$
Q = \frac{1}{2m} \sum_{ij} \left( A_{ij} - \frac{k_i k_j}{2m} \right) \delta(c_i, c_j)
$$

where $A_{ij}$ is the adjacency matrix, $m$ is the total number of edges, $k_i$/$k_j$ are node degrees, and $\delta(c_i, c_j)$ is 1 if nodes $i,j$ are assigned to the same community.

### Dynamic Processes on Networks

**Diffusion / Spreading Models**

*Epidemic models on networks* extend classic compartmental models (SIR/SIS) by replacing well-mixed population assumptions with explicit contact-network structure, so that individual node degree and network topology directly affect outbreak size and speed.

```plaintext
IF node.state == Susceptible AND neighbor.state == Infectious 
   AND random() < transmission_rate 
THEN node.state = Infectious
IF node.state == Infectious AND random() < recovery_rate 
THEN node.state = Recovered
```

*Information/behavior diffusion* (e.g., Bass diffusion model, complex contagion) models the spread of adoption, opinions, or behaviors, often requiring reinforcement from *multiple* neighbors (as opposed to simple single-contact contagion) for behaviors that carry social risk or cost.

**Cascading Failure**
Used in infrastructure and financial network modeling: the failure or overload of one node redistributes load to neighboring nodes, potentially triggering further failures. Highly sensitive to network topology — scale-free networks are notably robust to random node failure but vulnerable to targeted attacks on hub nodes.

**Opinion Dynamics on Networks**
Models such as the voter model or bounded-confidence model, run on an explicit network rather than a fully-mixed population, where the network structure (density, community structure, presence of hubs) significantly shapes whether consensus, polarization, or fragmentation emerges.

**Synchronization**
Coupled oscillator models (e.g., Kuramoto model) examine how network topology affects whether distributed oscillating units synchronize their phase over time — relevant to power grid stability and neural network dynamics.

### Network Generation and Rewiring in Simulation

Simulations often need to generate synthetic networks matching known real-world statistical properties (degree distribution, clustering, community structure) without using actual empirical data.

- **Configuration model**: generates a random graph with a specified degree sequence
- **Exponential Random Graph Models (ERGMs)**: statistical models specifying the probability of an entire graph configuration as a function of selected structural features, often used to fit and generate networks matching empirical social network statistics
- **Dynamic/temporal networks**: edges appear, disappear, or reweight over simulation time, capturing evolving relationships (e.g., contact networks that change hourly)

### Network-Based vs. Grid-Based Agent Interaction

| Aspect | Grid/Spatial-Based | Network-Based |
|---|---|---|
| Neighbor definition | Geometric proximity | Explicit edge/link structure |
| Realism for social systems | Limited (assumes spatial proximity = interaction) | High (captures actual relational structure) |
| Degree heterogeneity | Fixed, uniform (e.g., 8 neighbors in Moore) | Can be highly heterogeneous (hubs vs. peripheral nodes) |
| Computational representation | Array/matrix | Adjacency list/matrix, sparse graph structures |
| Typical use case | Physical/ecological diffusion, CA-style models | Social contagion, organizational, transportation, biological networks |

Many contemporary ABMs combine both: agents occupy a spatial environment *and* maintain a separate social network layer, allowing spatially-local and network-mediated interactions to coexist.

### Implementation Considerations

- **Data structures**: adjacency matrices are simple but $O(n^2)$ in memory, inefficient for large sparse networks; adjacency lists or sparse matrix representations scale far better for realistic network sizes
- **Static vs. dynamic networks**: static-network simulations can precompute neighbor lists once; dynamic/temporal networks require efficient incremental updates to avoid repeated full-graph recomputation
- **Scalability**: network diameter and clustering computations can become expensive at scale ($O(n^2)$ to $O(n^3)$ for some centrality measures); approximate or sampling-based algorithms are commonly used for very large networks

[Unverified: exact computational complexity figures depend on the specific algorithm and library implementation used; consult current documentation of the chosen simulation/network-analysis toolkit (e.g., NetworkX, igraph, SNAP) for precise performance characteristics.]

### Common Toolkits

| Tool | Primary Use |
|---|---|
| NetworkX (Python) | General-purpose graph creation, analysis, and generation |
| igraph (R/Python/C) | High-performance graph algorithms and large-network analysis |
| Gephi | Interactive network visualization |
| NetLogo (network extension) | Combining network structure with ABM |
| Repast/MASON | Programmatic network + agent integration in Java |

### Key Points

- Network-based modeling replaces spatial proximity with explicit relational structure as the basis for agent interaction
- Topology type (regular, random, small-world, scale-free) fundamentally shapes dynamic processes such as diffusion, cascading failure, and synchronization
- Structural metrics (degree distribution, clustering coefficient, centrality, modularity) are essential for both characterizing a network and interpreting simulation outcomes
- Many real-world social and biological networks exhibit small-world and/or scale-free properties, which materially affect robustness, spreading speed, and vulnerability to targeted disruption
- Grid-based and network-based interaction structures are not mutually exclusive and are frequently combined in modern ABMs

**Related Topics**
- Epidemic Modeling on Contact Networks (SIR/SIS Variants)
- Small-World and Scale-Free Network Generation Algorithms
- Centrality Measures and Their Interpretation in Simulation
- Cascading Failures in Infrastructure and Financial Networks
- Temporal and Dynamic Network Modeling
- Community Detection Algorithms
- Multilayer and Multiplex Network Models
- Coupled Oscillators and Synchronization (Kuramoto Model)