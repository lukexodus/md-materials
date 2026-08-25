## Factor Graphs

### Definition

A factor graph is a bipartite graphical representation of a factorized function, most commonly a joint probability distribution, consisting of two types of nodes: variable nodes and factor nodes. Edges connect a factor node to each variable it depends on, making explicit the decomposition structure that is otherwise implicit in Bayesian networks and Markov Random Fields.

### Formal Structure

A factor graph represents a function of the form:

$$g(X_1, \dots, X_n) = \prod_{a} f_a(X_a)$$

where each factor $f_a$ is a function over a subset $X_a \subseteq \{X_1, \dots, X_n\}$ of the variables. The graph $G = (V \cup F, E)$ consists of:

- Variable nodes $V = \{X_1, \dots, X_n\}$
- Factor nodes $F = \{f_a\}$
- Edges $E$, where an edge connects $X_i$ to $f_a$ if and only if $X_i \in X_a$

When $g$ represents a joint probability distribution, a normalization constant $Z$ is included:

$$P(X_1, \dots, X_n) = \frac{1}{Z} \prod_{a} f_a(X_a)$$

### Bipartite Property

Factor graphs are strictly bipartite: edges only ever connect a variable node to a factor node, never variable-to-variable or factor-to-factor. This is a defining structural constraint of the representation, not an incidental property.

===MERMAID_DIAGRAM===

graph TD

X1["X1 (svg_diagram)"] --- fa["f_a"]

X2["X2"] --- fa

X2 --- fb["f_b"]

X3["X3"] --- fb

X3 --- fc["f_c"]

X1 --- fc

style fa fill:#2d5,stroke:#333

style fb fill:#2d5,stroke:#333

style fc fill:#2d5,stroke:#333

### Why Factor Graphs Exist as a Separate Representation

Both Bayesian networks and Markov Random Fields can represent factorized distributions, but neither makes the factorization fully explicit at the graph level. A single undirected edge in an MRF, for example, does not by itself specify whether it belongs to a pairwise factor or a larger clique factor involving additional variables. Factor graphs resolve this ambiguity by giving each factor its own explicit node. [Inference] This motivation — that factor graphs remove structural ambiguity present in MRFs regarding clique membership — is a reasoned characterization based on comparing the two representations' formal definitions, and is consistent with how the distinction is commonly presented in graphical models literature, though I do not have a specific primary source available in this conversation to quote directly on this exact point. [Unverified]

### Converting from Bayesian Networks

A Bayesian network with factorization $P(X_1, \dots, X_n) = \prod_i P(X_i \mid \text{Pa}(X_i))$ converts to a factor graph by creating one factor node per conditional probability distribution, connected to the child variable and all of its parents.

===MERMAID_DIAGRAM===

graph TD

A["A (svg_diagram)"] --> fA["f_A = P(A)"]

B["B"] --> fB["f_B = P(B given A)"]

A --> fB

C["C"] --> fC["f_C = P(C given A,B)"]

A --> fC

B --> fC

### Converting from Markov Random Fields

An MRF with clique potentials $\phi_c(X_c)$ converts to a factor graph by creating one factor node per clique potential, connected to all variables in that clique. This conversion typically preserves the same variable nodes while making each potential function's scope an explicit node, which can matter when a clique's internal factorization needs to be represented at a finer grain than the clique itself. [Inference] This finer-grain representational capacity is a structural consequence of factor graphs allowing multiple smaller factors to replace what would otherwise be a single larger clique potential in an MRF, reasoned from the formal definitions of both representations rather than drawn from a specific cited passage.

### Role in the Sum-Product Algorithm

Factor graphs serve as the native graph structure on which belief propagation (the sum-product algorithm) operates. The message-passing update rules are defined directly in terms of variable nodes and factor nodes:

$$\mu_{X \to f_a}(x) = \prod_{b \in \text{Ne}(X) \setminus \{a\}} \mu_{f_b \to X}(x)$$



$$\mu_{f_a \to X}(x) = \sum_{X_a \setminus X} f_a(X_a) \prod_{Y \in \text{Ne}(f_a) \setminus \{X\}} \mu_{Y \to f_a}(y)$$

For tree-structured factor graphs, this message passing computes exact marginals. [Unverified] I do not have a specific primary source available in this conversation to directly quote regarding the original formalization of this exactness result (commonly attributed to Kschischang, Frey, and Loeliger's 2001 paper on factor graphs and the sum-product algorithm), so this is stated as a widely documented property rather than a directly cited claim.

### Worked Example: Chain Factorization

Consider a joint distribution over three variables factorized as:

$$P(X_1, X_2, X_3) = f_1(X_1, X_2) \cdot f_2(X_2, X_3)$$

===MERMAID_DIAGRAM===

graph LR

X1["X1 (svg_diagram)"] --- f1["f_1"] --- X2["X2"] --- f2["f_2"] --- X3["X3"]

This factor graph structure is a tree (no cycles), so sum-product message passing computes exact marginals for $X_1$, $X_2$, and $X_3$ in a single forward-backward pass.

### Example: Constructing a Factor Graph Programmatically

**Example**

```python
import numpy as np
import networkx as nx

FG = nx.Graph()
FG.add_nodes_from(['X1', 'X2', 'X3'], bipartite=0)
FG.add_nodes_from(['f1', 'f2'], bipartite=1)

FG.add_edge('X1', 'f1')
FG.add_edge('X2', 'f1')
FG.add_edge('X2', 'f2')
FG.add_edge('X3', 'f2')

is_bipartite = nx.is_bipartite(FG)
print("Is bipartite:", is_bipartite)
```

**Output**

I cannot verify the exact printed output of this code without executing it in a live environment. [Inference] Based on the structure defined in the code — variable and factor nodes connected only across the two declared groups, with no edges within either group — the `nx.is_bipartite(FG)` call is expected to return `True`, following the standard definition of a bipartite graph as implemented in the `networkx` library. This expectation is reasoned from the code's structure and the documented behavior of the function, not from direct execution.

### Cycles in Factor Graphs

A factor graph can contain cycles even when the underlying Bayesian network or MRF representation does not appear obviously cyclic, depending on how clique or CPD structures overlap. When cycles are present, exact sum-product inference is no longer guaranteed, and loopy belief propagation must be used instead, carrying the same lack of general convergence guarantee described for loopy BP on other graph types. [Unverified] Whether a specific factor graph derived from a specific model contains cycles depends entirely on that model's structure and cannot be determined in general without inspecting the specific case.

### Comparison with Bayesian Networks and MRFs

| Aspect | Bayesian Network | Markov Random Field | Factor Graph |
| --- | --- | --- | --- |
| Node types | Variables only | Variables only | Variables and factors (bipartite) |
| Edge meaning | Directed dependency | Undirected clique membership | Variable-factor participation |
| Factorization visibility | Implicit in CPDs | Implicit in clique structure | Explicit, one node per factor |
| Native inference algorithm | Variable elimination, junction tree | Variable elimination, junction tree | Sum-product (belief propagation) |

### Applications in Machine Learning

- Error-correcting codes, including low-density parity-check (LDPC) codes, where factor graphs represent the constraint structure decoded via sum-product message passing.
- Probabilistic graphical model inference generally, as a unifying representation for both Bayesian networks and MRFs prior to running belief propagation.
- Structured prediction tasks in natural language processing.
- Sensor fusion and tracking, where multiple overlapping measurement factors are combined.

[Unverified] I do not have specific performance benchmarks available in this conversation for these applications, so they are described as documented use cases rather than evaluated for comparative effectiveness.

### Limitations

- Representing a distribution as a factor graph does not by itself avoid the computational intractability of exact inference on graphs with cycles or high treewidth.
- Behavior of loopy belief propagation on a factor graph with cycles is not guaranteed to converge, and where it does converge, resulting marginals are approximate rather than exact.
- The choice of how finely to decompose factors (e.g., one large clique factor versus several smaller factors) can affect inference efficiency, and there is no single decomposition that is correct for all models; this depends on the specific structure and must be assessed case by case.

### Conclusion

Factor graphs provide a bipartite graphical representation that makes the factorization structure of a joint distribution explicit through dedicated factor nodes, serving as the native structure for the sum-product (belief propagation) algorithm. They can represent the same distributions as Bayesian networks and Markov Random Fields while resolving structural ambiguity about factor scope. Exact inference remains limited to tree-structured factor graphs, with cyclic cases requiring approximate methods that carry no general convergence guarantee.

[Unverified] Several structural and historical claims in this document are stated consistently with standard graphical models literature but are not drawn from a specific primary source directly quoted within this conversation; they should be treated as generally documented rather than independently confirmed here.

**Related Topics**

- Belief Propagation and the Sum-Product Algorithm
- Bayesian Networks
- Markov Random Fields
- Junction Tree Algorithm
- Low-Density Parity-Check Codes
- Max-Product Algorithm and MAP Inference
- Treewidth and Graph Complexity in Inference