## Markov Random Fields

### Definition

A Markov Random Field (MRF), also called a Markov network, is a probabilistic graphical model that represents a joint distribution over a set of random variables using an undirected graph. Nodes represent random variables, and edges represent direct dependencies between them, without the directionality constraint imposed by Bayesian networks.

### Formal Structure

An MRF consists of:

- An undirected graph $G = (V, E)$, where $V$ is the set of nodes (random variables) and $E$ is the set of undirected edges.
- A set of potential functions (also called factors) $\phi_c(X_c)$, one for each clique $c$ in the graph, where $X_c$ denotes the subset of variables in that clique.

The joint distribution factorizes as a product of clique potentials, normalized by a partition function:

$$P(X_1, \dots, X_n) = \frac{1}{Z} \prod_{c \in C} \phi_c(X_c)$$

where $C$ is the set of maximal cliques in the graph, and $Z$ is the partition function:

$$Z = \sum_{X_1, \dots, X_n} \prod_{c \in C} \phi_c(X_c)$$

Unlike Bayesian network CPDs, potential functions $\phi_c$ are not required to be normalized probabilities individually; they are non-negative functions that jointly determine the distribution only after normalization by $Z$.

### The Markov Property

An MRF encodes the pairwise, local, and global Markov properties, which are equivalent under the assumption of positive potential functions (a condition established by the Hammersley-Clifford theorem, discussed below).

**Pairwise Markov property**: Two non-adjacent variables are conditionally independent given all other variables.

**Local Markov property**: A variable is conditionally independent of all other variables given its neighbors (its Markov blanket).

**Global Markov property**: For any three disjoint subsets of nodes $A$, $B$, $S$, if $S$ separates $A$ from $B$ in the graph, then $A \perp B \mid S$.

$$X_i \perp \{X_j : j \notin \text{Ne}(i) \cup \{i\}\} \mid \text{Ne}(i)$$

where $\text{Ne}(i)$ denotes the neighbors of node $i$.

### Example Structure

===MERMAID_DIAGRAM===

graph TD

A["A (svg_diagram)"] --- B["B"]

B --- C["C"]

C --- D["D"]

D --- A

A --- C

In this graph, the maximal cliques are $\{A, B, C\}$ and $\{A, C, D\}$ (assuming the diagonal edge $A$–$C$ exists as drawn). The joint distribution factorizes over these cliques:

$$P(A, B, C, D) = \frac{1}{Z} \phi_1(A, B, C) \cdot \phi_2(A, C, D)$$

[Inference] This factorization depends entirely on correctly identifying the maximal cliques of the specific graph structure; for a different edge set, the clique decomposition would differ. I have reasoned this from the stated graph structure rather than verified it against an external source.

### Hammersley-Clifford Theorem

The Hammersley-Clifford theorem establishes the equivalence between a distribution satisfying the Markov properties with respect to a graph and a distribution that factorizes over the graph's cliques, provided the distribution is strictly positive (i.e., $P(X) > 0$ for all configurations $X$). This theorem is a foundational, well-established result in the graphical models literature. [Unverified] I do not have access to a primary source to directly quote the original 1971 unpublished manuscript by Hammersley and Clifford, so I cannot verify the exact original wording of the theorem, though its statement and role are consistently described in standard graphical models textbooks (e.g., Koller and Friedman's *Probabilistic Graphical Models*).

### Energy-Based Formulation

MRFs are frequently expressed in log-linear (energy-based) form, particularly in physics-derived applications:

$$P(X) = \frac{1}{Z} \exp\left(-\sum_{c \in C} E_c(X_c)\right)$$

where $E_c(X_c)$ is an energy function for clique $c$. Lower energy configurations correspond to higher probability. This formulation is common in Conditional Random Fields, Boltzmann Machines, and Ising models.

### Comparison with Bayesian Networks

| Aspect | Bayesian Network | Markov Random Field |
| --- | --- | --- |
| Graph type | Directed acyclic graph | Undirected graph |
| Factorization unit | Conditional probability per node | Potential function per clique |
| Local semantics | Conditional independence given parents | Conditional independence given neighbors |
| Normalization | Automatic (each CPD sums to 1) | Requires explicit partition function $Z$ |
| Cycles | Not permitted | Permitted |
| Causal interpretation | Sometimes used, with added assumptions | Generally not used for causal interpretation |

[Inference] The claim that MRFs are "generally not used for causal interpretation" reflects a common convention in the literature, where undirected edges do not encode directionality of influence, but I cannot verify that this convention is followed universally across all applied work using MRFs.

### Moralization: Converting Bayesian Networks to MRFs

A Bayesian network can be converted to an MRF through moralization: for each node, edges are added connecting all pairs of its parents ("marrying the parents"), and then all directed edges are replaced with undirected edges. This conversion is used in algorithms such as the junction tree algorithm for exact inference. [Unverified] I do not have a specific primary source in this conversation to cite for the term "moralization," though it is a standard term used consistently in graphical models textbooks.

### Conditional Random Fields (CRFs)

A Conditional Random Field is a discriminative variant of an MRF that directly models the conditional distribution $P(Y \mid X)$ rather than the joint distribution $P(X, Y)$, where $X$ is observed input and $Y$ is the output to be predicted. CRFs are commonly used in sequence labeling tasks such as named entity recognition and part-of-speech tagging.

$$P(Y \mid X) = \frac{1}{Z(X)} \prod_{c \in C} \phi_c(Y_c, X)$$

### Example: Ising Model

The Ising model is a classical MRF used to model binary variables (e.g., spins in statistical physics, or binary pixel states in image processing) arranged on a grid, where neighboring variables tend to align:

===MERMAID_DIAGRAM===

graph TD

X11["X(1,1) (svg_diagram)"] --- X12["X(1,2)"]

X11 --- X21["X(2,1)"]

X12 --- X22["X(2,2)"]

X21 --- X22

$$P(X) = \frac{1}{Z} \exp\left(\beta \sum_{(i,j) \in E} X_i X_j\right)$$

where $\beta$ controls the strength of interaction between neighboring nodes, and $X_i \in \{-1, +1\}$.

### Example: Image Denoising

**Example**

```python
import numpy as np
import networkx as nx

def ising_energy(grid, beta):
    energy = 0
    rows, cols = grid.shape
    for i in range(rows):
        for j in range(cols):
            if j + 1 < cols:
                energy -= beta * grid[i, j] * grid[i, j + 1]
            if i + 1 < rows:
                energy -= beta * grid[i, j] * grid[i + 1, j]
    return energy

grid = np.random.choice([-1, 1], size=(10, 10))
beta = 0.5
e = ising_energy(grid, beta)
print(e)
```

**Output**

[Unverified] I cannot verify the exact numerical output of this code without executing it, since `grid` is generated using `np.random.choice` without a fixed random seed, meaning the output value will differ on every run. [Inference] Based on the structure of the energy function, the printed value should be a single float representing total pairwise interaction energy across the grid, but the specific number cannot be determined without setting a seed and running the code directly.

### Inference in MRFs

Inference methods overlap substantially with those used for Bayesian networks:

- **Exact inference**: variable elimination, junction tree algorithm — both are affected by the same NP-hardness concerns as in Bayesian networks for general graph structures.
- **Approximate inference**: Gibbs sampling, loopy belief propagation, mean-field variational inference, contrastive divergence (used specifically for training Restricted Boltzmann Machines).

[Unverified] Whether a specific approximate inference method converges for a specific MRF structure cannot be determined without testing it directly against that structure; convergence guarantees in the general case are not established for methods such as loopy belief propagation on graphs with cycles.

### Applications in Machine Learning

- Image segmentation and denoising, where pixel labels are modeled as spatially dependent.
- Conditional Random Fields for sequence labeling in natural language processing.
- Restricted Boltzmann Machines, a bipartite MRF used historically in deep belief network pretraining.
- Spatial statistics and computer vision tasks involving grid-structured data.

### Limitations

- Computing the partition function $Z$ is generally intractable for large or densely connected graphs, since it requires summing over all possible joint configurations.
- Parameter learning typically requires approximate methods (e.g., contrastive divergence, pseudo-likelihood) because exact maximum likelihood estimation requires the intractable partition function.
- Model behavior on specific real-world datasets depends on the chosen clique structure and potential function parameterization; performance is not something that can be assumed without empirical testing on the specific dataset in question.

### Conclusion

Markov Random Fields provide an undirected alternative to Bayesian networks for representing joint distributions through local clique-based factorization. They are particularly suited to domains with symmetric, non-causal dependencies such as spatial or relational data. Their main practical challenge is the intractability of the partition function, which motivates the range of approximate inference and learning methods developed around them.

**Related Topics**

- Bayesian Networks
- Conditional Random Fields
- Hammersley-Clifford Theorem
- Restricted Boltzmann Machines
- Gibbs Sampling and MCMC Methods
- Belief Propagation
- Ising Model and Statistical Physics Connections
- Junction Tree Algorithm
- Partition Function Estimation Methods