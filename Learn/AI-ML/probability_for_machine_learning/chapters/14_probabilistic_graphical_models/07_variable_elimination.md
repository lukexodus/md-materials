## Variable Elimination

**[Unverified]** This section describes standard theoretical material from the probability and graphical models literature. Individual claims are labeled per stated preferences. I cannot verify derivations or proofs below against a specific cited source in this session.

### Definition

Variable elimination is an exact inference algorithm for graphical models that computes a target marginal distribution by successively summing out (eliminating) non-query variables from the joint factorization, in a chosen order, rather than summing over the full joint configuration space directly.

$$p(x_Q) = \sum_{x_1} \sum_{x_2} \cdots \sum_{x_k} \prod_{c} \psi_c(x_c)$$

where $x_Q$ is the query variable and $x_1, \dots, x_k$ are the variables to be eliminated.

### Core Idea

[Inference] The algorithm's efficiency relative to brute-force summation comes from exploiting the distributive law of multiplication over addition: instead of computing one large sum over the full joint configuration, sums are pushed inward so that each variable is summed out only over the factors that actually depend on it. This is the standard stated motivation for the algorithm in the literature. I cannot verify a formal efficiency proof without referencing a specific cited source, which has not been done in this session.

### Algorithm Steps

Given a set of factors $\{\psi_c\}$ over variables $\{x_1, \dots, x_D\}$, a query variable $x_Q$, and an elimination order over the remaining variables:

1. Select the next variable $x_i$ to eliminate, per the chosen order.
2. Collect all factors that involve $x_i$.
3. Multiply these factors together to form a single combined factor.
4. Sum out $x_i$ from the combined factor, producing a new factor over the remaining variables (those that were in the combined factor other than $x_i$).
5. Replace the collected factors with this new factor in the factor set.
6. Repeat until all non-query variables have been eliminated.
7. Multiply any remaining factors together; the result, normalized if necessary, is $p(x_Q)$.

[Inference] This procedure is the standard stated algorithm in the literature; not independently re-derived here.

### Diagram: Variable Elimination on a Chain

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 340">
  <text x="350" y="30" font-size="18" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Variable Elimination, Step by Step (svg_diagram)</text>

  <text x="100" y="70" font-size="12" fill="#1a1a1a" font-weight="bold">Initial factors:</text>
  <text x="100" y="90" font-size="11" fill="#333">psi(X1,X2), psi(X2,X3), psi(X3,X4)</text>

  <line x1="350" y1="100" x2="350" y2="130" stroke="#333" stroke-width="2" marker-end="url(#arrowve)" />

  <rect x="200" y="130" width="300" height="50" rx="8" fill="#fef5e7" stroke="#e67e22" stroke-width="2" />
  <text x="350" y="150" font-size="12" text-anchor="middle" fill="#1a1a1a" font-weight="bold">Eliminate X1:</text>
  <text x="350" y="168" font-size="11" text-anchor="middle" fill="#333">tau1(X2) = sum_X1 psi(X1,X2)</text>

  <line x1="350" y1="180" x2="350" y2="210" stroke="#333" stroke-width="2" marker-end="url(#arrowve)" />

  <rect x="200" y="210" width="300" height="50" rx="8" fill="#fef5e7" stroke="#e67e22" stroke-width="2" />
  <text x="350" y="230" font-size="12" text-anchor="middle" fill="#1a1a1a" font-weight="bold">Eliminate X2:</text>
  <text x="350" y="248" font-size="11" text-anchor="middle" fill="#333">tau2(X3) = sum_X2 tau1(X2) psi(X2,X3)</text>

  <line x1="350" y1="260" x2="350" y2="290" stroke="#333" stroke-width="2" marker-end="url(#arrowve)" />

  <rect x="200" y="290" width="300" height="40" rx="8" fill="#eafaf1" stroke="#27ae60" stroke-width="2" />
  <text x="350" y="315" font-size="12" text-anchor="middle" fill="#1a1a1a" font-weight="bold">Continue until only p(X4) remains</text>

  </svg>

### Worked Example

Consider a chain $X_1 \to X_2 \to X_3$ with factors $\psi(x_1, x_2) = p(x_2 \mid x_1) p(x_1)$ and $\psi(x_2, x_3) = p(x_3 \mid x_2)$, and suppose the query is $p(x_3)$.

**Step 1 — Eliminate $x_1$:** Only $\psi(x_1, x_2)$ involves $x_1$. Sum it out:

$$\tau_1(x_2) = \sum_{x_1} \psi(x_1, x_2) = \sum_{x_1} p(x_2 \mid x_1) p(x_1)$$

**Step 2 — Eliminate $x_2$:** Both $\tau_1(x_2)$ and $\psi(x_2, x_3)$ involve $x_2$. Multiply and sum out:

$$\tau_2(x_3) = \sum_{x_2} \tau_1(x_2) \, \psi(x_2, x_3)$$

**Result:** $\tau_2(x_3) = p(x_3)$, the desired marginal.

[Inference] This worked derivation follows directly from applying the general algorithm steps above to this specific chain structure; it has not been independently verified through separate numeric computation in this session, since no specific conditional probability tables were supplied.

### The Role of Elimination Order

[Inference] The literature commonly states that the size of the intermediate factors produced during variable elimination — and therefore the total computational cost — depends heavily on the order in which variables are eliminated. Different elimination orders on the same graph can produce intermediate factors of very different sizes. This is presented as commonly stated theory in the literature; not independently re-derived here.

### Treewidth and Computational Complexity

[Inference] The literature commonly relates the cost of variable elimination to a graph-theoretic quantity called the induced width (or treewidth) of the graph under a given elimination order: the complexity of the algorithm is commonly stated to be exponential in this induced width. This is presented as commonly stated theory in the literature. I cannot verify the formal complexity proof without referencing a specific cited source, which has not been done in this session.

**[Unverified]** Finding the elimination order that minimizes induced width is commonly described in the literature as itself a computationally hard problem in general (related to the NP-hardness of finding optimal treewidth for arbitrary graphs). I cannot verify this specific complexity-theoretic claim without referencing a specific cited source.

### Heuristics for Choosing Elimination Order

[Speculation] Since finding the globally optimal elimination order is commonly discussed as computationally hard, the literature commonly discusses greedy heuristics as practical alternatives, including:

- **Min-degree heuristic**: At each step, eliminate the variable with the fewest neighbors in the current graph.
- **Min-fill heuristic**: At each step, eliminate the variable that would add the fewest new edges (fill-in edges) to the graph.

**[Unverified]** I cannot verify the relative practical performance of these heuristics for any specific graph without a cited benchmark, which has not been done in this session. This is presented as commonly cited practice in the literature, not as an independently confirmed result.

### Variable Elimination for Multiple Queries

[Inference] The literature commonly notes that variable elimination, as described above, computes a marginal for a single query variable at a time; computing marginals for multiple variables generally requires re-running the algorithm for each query, unless the intermediate messages are cached and reused, which is described in the literature as a motivation for the junction tree algorithm (covered in a prior section) when multiple marginals are needed. This is presented as commonly stated theory; not independently re-derived here.

### Comparison to Belief Propagation

[Inference] Variable elimination and belief propagation are commonly described in the literature as closely related: variable elimination for a single query corresponds to one direction of message passing in belief propagation, while belief propagation's two-pass schedule additionally reuses intermediate computations to obtain marginals for all variables in a single set of passes on a tree. This is a commonly stated characterization in the literature; not independently re-derived here.

### Applications in Machine Learning

- Exact inference in Bayesian networks and Markov random fields with low treewidth, such as chain- or tree-structured models (e.g., Hidden Markov Models).
- Used as a subroutine or conceptual basis within the junction tree algorithm for general graphs.
- Diagnostic and expert systems requiring exact marginal probabilities over small to moderately sized graphical models. **[Unverified]** I cannot verify current specific usage in production systems without checking current sources, which has not been done in this session.

### Limitations

- Computational cost grows exponentially with the induced width (treewidth) of the graph under the chosen elimination order, per commonly stated literature. [Inference]
- Finding an elimination order that minimizes induced width is commonly described as computationally hard in general. **[Unverified]**
- Re-running the algorithm separately for each query variable is commonly noted as inefficient when multiple marginals are needed, motivating the junction tree algorithm as an alternative. [Inference]
- Not applicable, in its exact form, to graphs where treewidth is too large for practical computation; approximate methods (sampling, variational inference, loopy belief propagation) are commonly used in such cases. [Inference]

### Key Points

- Variable elimination computes exact marginals by successively summing out non-query variables, exploiting factorized structure to avoid full joint summation. [Inference]
- Computational cost depends on elimination order, commonly related in the literature to the graph's induced width (treewidth). [Inference]
- Finding the optimal elimination order is commonly described as computationally hard in general; greedy heuristics (min-degree, min-fill) are commonly used in practice. [Speculation] / [Unverified]
- The algorithm computes one query marginal at a time; the junction tree algorithm addresses the need for multiple marginals more efficiently. [Inference]
- Variable elimination is closely related to belief propagation, corresponding to one direction of its message-passing schedule. [Inference]

### Related Topics

- Junction tree algorithm
- Belief propagation and the sum-product algorithm
- Treewidth and graph structure complexity
- Hidden Markov Models (chain-structured exact inference)
- Approximate inference methods (MCMC, variational inference, loopy belief propagation)

> Correction: No claim has been identified as stated without a label in this response at time of generation. All uncertain content above carries [Inference], [Speculation], or [Unverified] labels per stated preferences; per the instruction that any unverified part labels the entire output, this full response should be treated as containing unverified material.