## Scenario Generation and Reduction

### Definition and Core Idea

Scenario generation and reduction are complementary techniques used to construct a computationally tractable, finite representation of an uncertain future for use in stochastic programming. **Scenario generation** creates a set of representative realizations (scenarios) of random parameters, each with an associated probability, that approximates the true underlying distribution. **Scenario reduction** takes an existing, often large, scenario set and identifies a smaller subset that preserves as much statistical fidelity to the original set as possible, discarding or merging scenarios that contribute little distinct information. Both techniques address the same underlying challenge: the size of the deterministic equivalent problem in stochastic programming (as seen in SAA-based two-stage and multi-stage models) grows directly with the number of scenarios, so managing scenario count is essential for computational tractability.

### Why Scenario Generation Matters

A stochastic program's scenario tree is only as good as the scenarios feeding it. Poorly constructed scenario sets can lead to two distinct failure modes:

- **Too few or unrepresentative scenarios**: the optimization solves quickly but may produce a solution that performs poorly when the true, unmodeled uncertainty is realized — a form of the same out-of-sample risk discussed in sample average approximation and distributionally robust optimization.
- **Too many scenarios**: the resulting deterministic equivalent problem, particularly in multi-stage settings where scenario count grows exponentially with the number of stages, may become computationally intractable even for state-of-the-art solvers.

Scenario generation methods aim to construct scenario sets that are statistically representative at a manageable size; scenario reduction methods aim to shrink an existing set while minimizing the loss of representativeness.

### Scenario Generation Methods

**Monte Carlo Sampling**

The most direct method: draw $N$ independent samples from the assumed (or fitted) probability distribution of the random parameters, each assigned equal probability $1/N. This is the approach underlying SAA. Its main drawback is that pure random sampling can leave gaps or clusters in coverage, especially in higher dimensions, requiring large $N
 for adequate coverage.

**Moment Matching**

Constructs a discrete scenario set such that its statistical moments (mean, variance, skewness, and sometimes correlations across random variables) match target values derived from historical data or a fitted distribution. This is typically formulated as a nonlinear optimization problem: choose scenario values and probabilities to minimize the distance between the scenario set's moments and the target moments. Moment matching can achieve good statistical representativeness with fewer scenarios than plain Monte Carlo sampling, at the cost of requiring a nontrivial optimization step to construct the set itself.

**Bootstrap Methods**

Generate scenarios by resampling with replacement from historical observations, which avoids the need to assume a parametric distribution. This is particularly useful when the underlying distribution is unknown or difficult to fit, and preserves empirical features (e.g., fat tails, skewness) present in the historical record without requiring them to be explicitly modeled.

**Quasi-Monte Carlo and Low-Discrepancy Sequences**

Uses deterministic, low-discrepancy point sets (e.g., Sobol or Halton sequences) instead of pseudo-random sampling to achieve more even coverage of the probability space for a given number of points, improving convergence for smooth objective functions compared to plain Monte Carlo.

**Scenario Trees for Multi-Stage Problems**

For multi-stage stochastic programs, scenarios must capture the sequential revelation of information over time, represented as a branching tree structure where each node corresponds to a decision point and each branch to a possible realization of new information. Tree construction methods include:

- **Recursive moment matching**: applying moment matching at each stage conditional on the path taken to that node.
- **Sampling-based tree construction**: simulating paths forward from a root scenario using a stochastic process model, then discretizing.
- **Bushiness control**: deliberately limiting the branching factor at each stage to control tree size, since the number of scenarios in a full tree grows multiplicatively with the number of stages and branches per stage.

### Diagram: Scenario Tree Structure

===MERMAID_DIAGRAM===

flowchart TD

A["Root Node<br/>(Stage 0 decision) (svg_diagram)"] --> B1["Scenario Branch 1<br/>(Stage 1)"]

A --> B2["Scenario Branch 2<br/>(Stage 1)"]

A --> B3["Scenario Branch 3<br/>(Stage 1)"]

B1 --> C1["Sub-scenario 1.1<br/>(Stage 2)"]

B1 --> C2["Sub-scenario 1.2<br/>(Stage 2)"]

B2 --> C3["Sub-scenario 2.1<br/>(Stage 2)"]

B2 --> C4["Sub-scenario 2.2<br/>(Stage 2)"]

B3 --> C5["Sub-scenario 3.1<br/>(Stage 2)"]

B3 --> C6["Sub-scenario 3.2<br/>(Stage 2)"]

### Scenario Reduction: Motivation

Even when a scenario set is statistically well-constructed, it may still be larger than what a solver can handle efficiently, especially for large-scale two-stage problems with expensive recourse subproblems or multi-stage problems with deep trees. Scenario reduction addresses this by identifying a subset of scenarios — with adjusted probabilities — that stays close to the original scenario set in a well-defined probabilistic distance, while using substantially fewer scenarios.

### Probability Metrics for Scenario Reduction

Scenario reduction methods rely on a distance metric between probability distributions (the original scenario set and the reduced set) to guide which scenarios to keep or discard. The most common choice is a variant of the **Wasserstein distance** (also called the Kantorovich distance in this literature), because it has direct interpretability in terms of the "transportation cost" of redistributing probability mass from deleted scenarios to retained ones, and because stability results in stochastic programming show that optimal values and solutions vary continuously with respect to this metric under standard regularity conditions.

### Scenario Reduction Algorithms

**Forward Selection**

Builds the reduced scenario set incrementally: starting from an empty set, it repeatedly adds the scenario whose inclusion most reduces the Wasserstein distance between the current reduced set and the original set, until the target number of scenarios (or a distance threshold) is reached. This approach tends to perform well when the target reduced set size is small relative to the original.

**Backward Reduction (Backward Elimination)**

Starts from the full scenario set and repeatedly removes the scenario whose deletion increases the Wasserstein distance the least, redistributing its probability mass to the nearest remaining scenario. This approach tends to perform well when the target reduced set size is large relative to the original (i.e., only a modest number of scenarios need to be removed).

**Simultaneous Backward Reduction**

A variant that considers removing multiple scenarios simultaneously in each step rather than one at a time, which can improve the quality of the reduction at increased computational cost per step.

**Fast Forward Selection**

A computationally efficient approximation to forward selection that avoids the full combinatorial search at each step, making it more scalable to large initial scenario sets.

[Inference] The choice between forward and backward variants in practice is often guided by the ratio of target to original scenario count and by available computational budget, since neither method dominates the other across all problem sizes and structures.

### Probability Redistribution

A critical detail in scenario reduction is that when a scenario is deleted, its probability mass is not simply discarded — it must be redistributed to remaining scenarios to preserve the total probability mass of 1. The standard rule redistributes each deleted scenario's probability to its closest remaining scenario (in the underlying distance metric), which is the choice that minimizes the increase in Wasserstein distance for a given deletion.

### Application to Multi-Stage Scenario Trees

For scenario trees, reduction is complicated by the need to preserve the **non-anticipativity** structure — the property that decisions at any node can only depend on information revealed up to that point in the tree, not on future branches. Tree reduction techniques therefore typically combine:

- **Scenario reduction** at the level of full scenario paths (root-to-leaf sequences), followed by
- **Tree reconstruction/clustering**, which regroups the reduced set of paths back into a tree structure that respects non-anticipativity, often by clustering paths that share common early-stage realizations into shared tree nodes.

This two-step process (reduce, then re-cluster into a valid tree) is standard because a naive union of unrelated reduced scenario paths does not generally form a valid, well-shaped scenario tree.

### Practical Example

**Example**

Suppose an initial Monte Carlo sample generates $N = 5000$ demand scenarios for a two-stage capacity planning problem, each with probability $1/5000$. Solving the full SAA problem with 5000 scenarios is computationally expensive due to the size of the second-stage recourse problem. A scenario reduction procedure is applied:

1. Compute pairwise distances between all 5000 scenarios (using, e.g., Euclidean distance on the demand vector as the base metric for the Wasserstein/Kantorovich distance).
2. Apply fast forward selection to build a reduced set of $n = 50$ scenarios, minimizing the Wasserstein distance to the original 5000-scenario distribution at each step.
3. Redistribute the probability mass of the 4950 deleted scenarios to their closest respective scenarios among the retained 50, resulting in a new probability vector over 50 scenarios that sums to 1.
4. Solve the SAA problem using this reduced 50-scenario set.

**Output**

The reduced problem with 50 scenarios is solved substantially faster than the original 5000-scenario problem, and stability theory guarantees that if the Wasserstein distance between the reduced and original distributions is small, the resulting first-stage solution's objective value will be close to what would have been obtained with the full 5000-scenario problem — though the exact closeness depends on problem-specific Lipschitz-type constants that are not always known in practice.

### Evaluating Scenario Set Quality

Beyond distance metrics, generated or reduced scenario sets are often validated using:

- **Out-of-sample testing**: solving the stochastic program using the reduced/generated scenario set, then evaluating the resulting first-stage decision's performance on an independent, larger test scenario set (analogous to the validation step in the multiple replication procedure for SAA).
- **In-sample vs. out-of-sample stability**: comparing optimal objective values obtained from different generated scenario sets (or different reductions) of the same size to check whether results are consistent, which indicates the scenario set size is adequate.

### Computational Considerations

- **Distance matrix computation cost**: computing pairwise distances for scenario reduction scales quadratically with the initial scenario count, which can itself become a bottleneck for very large initial sets, motivating approximate or fast variants.
- **Reduction ratio**: the appropriate ratio of reduced to original scenario count is problem-dependent; overly aggressive reduction can discard information relevant to rare but impactful scenarios, particularly a concern in risk-sensitive or chance-constrained formulations.
- **Interaction with decomposition methods**: reduced scenario sets are often used as the scenario input to decomposition algorithms (e.g., the L-shaped method), so the reduction step and the solution algorithm are frequently treated as a combined pipeline rather than independent stages.

### Common Pitfalls

- Using a scenario reduction technique built for single-stage scenario sets directly on multi-stage trees without addressing non-anticipativity, producing an invalid tree structure.
- Reducing scenarios based solely on a generic distance metric without considering whether rare, high-impact scenarios (e.g., tail-risk events) are preserved, which can be especially problematic for risk-averse or chance-constrained models.
- Treating scenario generation and reduction as a one-time preprocessing step disconnected from solution validation, rather than iterating with out-of-sample testing to confirm the chosen scenario set size and structure are adequate.
- Redistributing deleted scenario probabilities arbitrarily (e.g., uniformly) rather than to the nearest remaining scenario, which unnecessarily inflates the Wasserstein distance and degrades the reduced set's fidelity.

**Related Topics**

- Sample average approximation methods
- Multi-stage stochastic programming and non-anticipativity constraints
- The L-shaped method and Benders decomposition
- Stability analysis in stochastic programming
- Distributionally robust optimization
- Moment-matching optimization for scenario construction
- Wasserstein distance and optimal transport in optimization
- Risk-averse stochastic programming (CVaR-based models)