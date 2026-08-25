## Belief Propagation

### Definition

Belief propagation (BP), also called the sum-product algorithm, is a message-passing algorithm used to compute marginal probability distributions over variables in a graphical model by exchanging local messages between neighboring nodes. It is exact for tree-structured graphs and approximate (as "loopy belief propagation") when applied to graphs containing cycles.

### Formal Setting

Belief propagation operates on a factor graph, a bipartite graph representation with two types of nodes:

- Variable nodes, representing random variables
- Factor nodes, representing potential functions or conditional probability distributions over subsets of variables

$$P(X_1, \dots, X_n) = \frac{1}{Z} \prod_{a} f_a(X_a)$$

where $f_a$ is a factor over the variable subset $X_a$, and $Z$ is the normalization constant.

===MERMAID_DIAGRAM===

graph TD

X1["X1 (svg_diagram)"] --- f1["f_a"]

X2["X2"] --- f1

X2 --- f2["f_b"]

X3["X3"] --- f2

style f1 fill:#2d5,stroke:#333

style f2 fill:#2d5,stroke:#333

### Message Definitions

Belief propagation defines two types of messages passed along edges of the factor graph:

**Variable-to-factor message**: a variable node $X$ sends a message to a neighboring factor node $f_a$, summarizing information from all other neighboring factors:

$$\mu_{X \to f_a}(x) = \prod_{b \in \text{Ne}(X) \setminus \{a\}} \mu_{f_b \to X}(x)$$

**Factor-to-variable message**: a factor node $f_a$ sends a message to a neighboring variable node $X$, summing out all other variables involved in that factor:

$$\mu_{f_a \to X}(x) = \sum_{X_a \setminus X} f_a(X_a) \prod_{Y \in \text{Ne}(f_a) \setminus \{X\}} \mu_{Y \to f_a}(y)$$

### Computing Marginals

Once messages have converged (or, for tree-structured graphs, after a single pass from leaves to root and back), the marginal distribution of a variable $X$ is obtained by multiplying together all incoming messages from its neighboring factors:

$$P(X) \propto \prod_{a \in \text{Ne}(X)} \mu_{f_a \to X}(x)$$

### Exactness on Trees

For factor graphs that form a tree (no cycles), belief propagation computes exact marginals in a finite number of steps, specifically two passes over the tree: one from the leaves inward, and one from the root outward. This exactness result is a standard, well-established property in the graphical models literature (e.g., described in Koller and Friedman's *Probabilistic Graphical Models* and Bishop's *Pattern Recognition and Machine Learning*). I do not have direct access to those texts within this conversation to quote them, so I am stating this as a widely documented property rather than a directly cited claim. [Unverified]

===MERMAID_DIAGRAM===

graph TD

L1["Leaf 1 (svg_diagram)"] --> R["Root"]

L2["Leaf 2"] --> R

R --> L3["Leaf 3"]

R --> L4["Leaf 4"]

### Loopy Belief Propagation

When the factor graph contains cycles, the same message-passing update rules can still be applied iteratively, but the algorithm is no longer guaranteed to converge, and if it does converge, the resulting marginals are not guaranteed to be exact. [Inference] The lack of a general convergence guarantee for loopy belief propagation on arbitrary cyclic graphs is a property widely discussed in the graphical models literature. Whether loopy BP converges for any specific graph, and how close the resulting approximate marginals are to the true marginals in that case, cannot be determined without testing that specific graph directly. [Unverified] I do not have a verified source in this conversation to cite for precise bounds on approximation error in the general loopy case.

### Max-Product Variant

A closely related variant, max-product belief propagation, replaces the sum in the factor-to-variable message with a max operation, and is used to compute the most probable joint assignment (MAP inference) rather than marginal distributions:

$$\mu_{f_a \to X}(x) = \max_{X_a \setminus X} f_a(X_a) \prod_{Y \in \text{Ne}(f_a) \setminus \{X\}} \mu_{Y \to f_a}(y)$$

On tree-structured graphs, max-product BP is a generalization of the Viterbi algorithm used in Hidden Markov Models. [Inference] I am reasoning this connection from the shared dynamic-programming structure between the Viterbi algorithm and max-product BP on chain-structured factor graphs, which is a commonly described relationship in the graphical models literature, though I do not have a specific primary source to cite for this exact claim within this conversation.

### Worked Example: Chain Structure

Consider three variables $X_1, X_2, X_3$ connected in a chain, with pairwise factors $f_{12}(X_1, X_2)$ and $f_{23}(X_2, X_3)$:

===MERMAID_DIAGRAM===

graph LR

X1["X1 (svg_diagram)"] --- f12["f_12"] --- X2["X2"] --- f23["f_23"] --- X3["X3"]

The marginal of $X_2$ is computed as:

$$P(X_2) \propto \left[\sum_{X_1} f_{12}(X_1, X_2)\right] \cdot \left[\sum_{X_3} f_{23}(X_2, X_3)\right]$$

This corresponds to a message from $f_{12}$ arriving at $X_2$ (summing out $X_1$) multiplied by a message from $f_{23}$ arriving at $X_2$ (summing out $X_3$).

### Example Implementation

**Example**

```python
import numpy as np

f12 = np.array([[0.3, 0.7],
                [0.6, 0.4]])
f23 = np.array([[0.5, 0.5],
                [0.2, 0.8]])

msg_f12_to_x2 = f12.sum(axis=0)
msg_f23_to_x2 = f23.sum(axis=1)

unnormalized = msg_f12_to_x2 * msg_f23_to_x2
marginal_x2 = unnormalized / unnormalized.sum()

print("Marginal P(X2):", marginal_x2)
```

**Output**

I cannot verify the exact printed numerical values without executing this code in a live environment. [Inference] Based on the matrix values defined in the code, `msg_f12_to_x2` sums each column of `f12`, and `msg_f23_to_x2` sums each row of `f23`; the elementwise product of these two vectors, normalized to sum to 1, should produce a two-element probability vector for `marginal_x2`. I have not executed this code, so the specific numeric result is not confirmed here.

### Convergence Behavior on Loopy Graphs

[Speculation] Some approximate characterizations of loopy belief propagation's fixed points relate them to stationary points of the Bethe free energy from statistical physics, a connection discussed in some graphical models literature. I do not have a verified primary source available in this conversation to confirm the precise technical conditions under which this correspondence holds, so this connection is marked as speculation rather than an established fact I can confirm here.

### Comparison with Other Inference Methods

| Method | Exactness | Graph Requirement | Typical Use Case |
| --- | --- | --- | --- |
| Variable Elimination | Exact | Any (cost depends on treewidth) | Small to moderate networks |
| Belief Propagation (tree) | Exact | Tree-structured factor graph | Chains, trees |
| Loopy Belief Propagation | Approximate | Any | Large graphs with cycles, e.g., image models |
| Junction Tree Algorithm | Exact | Any (via tree decomposition) | General graphs, at higher computational cost |
| Gibbs Sampling / MCMC | Approximate (asymptotically exact) | Any | High-dimensional or continuous models |

[Unverified] I do not have benchmark data available in this conversation comparing runtime or accuracy across these methods on any specific dataset, so no comparative performance claim is made here beyond the structural properties described in standard references.

### Applications in Machine Learning

- Error-correcting codes, particularly low-density parity-check (LDPC) codes, where loopy belief propagation is used for decoding.
- Computer vision tasks such as stereo matching and image denoising, modeled using grid-structured Markov Random Fields.
- Natural language processing tasks involving structured prediction.
- Probabilistic inference in Bayesian networks and Markov Random Fields more generally, as an alternative to variable elimination when the graph structure suits message passing.

[Unverified] I do not have specific verified performance figures for these applications within this conversation, so I am describing them as documented use cases rather than making claims about comparative effectiveness.

### Limitations

- Loopy belief propagation carries no general convergence guarantee; behavior may vary depending on graph structure, and this is not something that can be assumed to hold without testing the specific graph in question.
- Even when loopy BP converges, the resulting marginals are approximate and their accuracy is not established in the general case.
- Computational cost of exact belief propagation grows with the size of the factors involved (related to treewidth for general graphs converted via junction tree methods), and large factors can make even tree-structured inference computationally demanding.

### Conclusion

Belief propagation computes marginal distributions through local message passing between variable and factor nodes, and is exact for tree-structured factor graphs. Its extension to graphs with cycles, loopy belief propagation, is used widely in practice despite lacking general convergence or exactness guarantees. [Unverified] Because several claims in this document rely on general descriptions from the graphical models literature without a directly quotable primary source available in this conversation, portions of this content should be treated as consistent with standard references rather than independently verified against a specific cited source.

**Related Topics**

- Markov Random Fields
- Bayesian Networks
- Hidden Markov Models and the Viterbi Algorithm
- Junction Tree Algorithm
- Factor Graphs
- Bethe Free Energy and Variational Inference
- Low-Density Parity-Check Codes
- Gibbs Sampling and Markov Chain Monte Carlo