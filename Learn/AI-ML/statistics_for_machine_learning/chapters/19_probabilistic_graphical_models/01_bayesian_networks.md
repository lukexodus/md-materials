## Bayesian Networks

### Definition

A Bayesian network is a probabilistic graphical model that represents a set of random variables and their conditional dependencies using a directed acyclic graph (DAG). Each node represents a random variable, and each directed edge represents a direct probabilistic dependency between two variables. The full joint probability distribution over all variables factorizes according to the graph structure.

### Formal Structure

A Bayesian network consists of:

- A DAG $G = (V, E)$, where $V$ is the set of nodes (random variables) and $E$ is the set of directed edges.
- A conditional probability distribution (CPD) for each node $X_i$, given its parent nodes $\text{Pa}(X_i)$ in the graph: $P(X_i \mid \text{Pa}(X_i))$.

The joint distribution over all variables $X_1, \dots, X_n$ factorizes as:

$$P(X_1, X_2, \dots, X_n) = \prod_{i=1}^{n} P(X_i \mid \text{Pa}(X_i))$$

This factorization is the defining mathematical property of a Bayesian network and follows directly from the chain rule of probability combined with the conditional independence assumptions encoded by the graph structure.

### Conditional Independence and the Markov Property

A Bayesian network encodes the assumption that each variable is conditionally independent of its non-descendants, given its parents. This is known as the local Markov property.

$$X_i \perp \text{NonDescendants}(X_i) \mid \text{Pa}(X_i)$$

This property is what allows the full joint distribution, which in general requires exponentially many parameters, to be represented compactly using only the local conditional distributions.

### Example Structure

===MERMAID_DIAGRAM===

graph TD

A["Rain (svg_diagram)"] --> B["Sprinkler"]

A --> C["Wet Grass"]

B --> C

C --> D["Slippery"]

In this example: Rain influences whether the Sprinkler is used and whether the Grass is Wet. The Sprinkler also directly influences Wet Grass. Wet Grass influences whether the surface is Slippery. The joint distribution factorizes as:

$$P(R, S, W, L) = P(R) \cdot P(S \mid R) \cdot P(W \mid R, S) \cdot P(L \mid W)$$

### D-Separation

D-separation is a graphical criterion used to determine whether two sets of variables are conditionally independent given a third set, based solely on the structure of the DAG, without needing to compute actual probability values. Three canonical connection patterns determine dependency behavior:

**Chain** ($A \rightarrow B \rightarrow C$): $A$ and $C$ are dependent, but become conditionally independent given $B$.

**Fork** ($A \leftarrow B \rightarrow C$): $A$ and $C$ are dependent through the common cause $B$, but become conditionally independent given $B$.

**Collider** ($A \rightarrow B \leftarrow C$): $A$ and $C$ are marginally independent, but become dependent once conditioned on $B$ (or any descendant of $B$). This is sometimes called "explaining away."

===MERMAID_DIAGRAM===

graph TD

subgraph Chain["Chain Pattern (svg_diagram)"]

A1["A"] --> B1["B"] --> C1["C"]

end

subgraph Fork["Fork Pattern"]

B2["B"] --> A2["A"]

B2 --> C2["C"]

end

subgraph Collider["Collider Pattern"]

A3["A"] --> B3["B"]

C3["C"] --> B3

end

### Explaining Away Example

Consider two independent causes of an alarm sounding: a burglary and an earthquake. Both are marginally independent of each other. However, if it is known that the alarm sounded (conditioning on the collider), observing that an earthquake occurred makes burglary less probable, since the earthquake now "explains away" the alarm. This is a well-established qualitative behavior in the standard Bayesian network literature covering collider structures, though the exact magnitude of the effect depends on the specific conditional probability tables defined for the network.

### Inference in Bayesian Networks

Inference refers to computing the probability of some variables given evidence about others, e.g., $P(X \mid E = e)$.

**Exact inference methods:**

- Variable elimination: sums out variables one at a time, exploiting the factorized structure to avoid computing the full joint distribution explicitly.
- Junction tree algorithm: converts the DAG into a tree of clusters, enabling efficient exact inference through message passing.

**Approximate inference methods:**

- Markov Chain Monte Carlo (MCMC), including Gibbs sampling.
- Variational inference, which approximates the posterior with a simpler tractable distribution.
- Loopy belief propagation, which applies message-passing algorithms designed for trees to graphs with cycles; convergence is not guaranteed in this setting. [Inference] The lack of a general convergence guarantee for loopy belief propagation on arbitrary graphs is a widely documented property in the graphical models literature, though whether it converges for any specific graph structure depends on that structure and cannot be determined without testing it directly.

Exact inference is known to be NP-hard in general for arbitrary Bayesian network structures. [Unverified] I cannot verify without access to the specific complexity-theoretic proof source whether this NP-hardness result applies uniformly to every inference query type (e.g., MAP inference vs. marginal inference) with identical complexity bounds; these are generally treated as related but distinct hardness results in the literature.

### Parameter Learning

Given a fixed graph structure, learning the conditional probability tables (CPTs) from data can be done via:

- **Maximum Likelihood Estimation (MLE)**: sets each CPT entry to the empirical frequency observed in the training data.
- **Bayesian estimation**: incorporates a prior distribution over CPT parameters (commonly a Dirichlet prior for discrete variables) and computes a posterior, which helps regularize estimates when data is sparse.

$$\hat{\theta}_{X_i \mid \text{Pa}(X_i)} = \frac{\text{count}(X_i, \text{Pa}(X_i))}{\text{count}(\text{Pa}(X_i))}$$

### Structure Learning

When the graph structure itself is not known in advance, it must be learned from data. Two broad approaches:

- **Score-based methods**: search over possible DAG structures, scoring each with a metric such as BIC (Bayesian Information Criterion) or BDeu, and selecting the structure that optimizes the score.
- **Constraint-based methods**: use conditional independence tests (e.g., chi-squared tests) to infer which edges should exist, based on statistical independence relationships observed in the data.

[Inference] Structure learning is generally considered a harder problem than parameter learning because the space of possible DAGs grows super-exponentially with the number of variables, which is a combinatorial property of DAG counting rather than an empirical claim requiring dataset-specific verification.

### Example: Simple Two-Node Network

**Example**

```python
from pgmpy.models import DiscreteBayesianNetwork
from pgmpy.factors.discrete import TabularCPD
from pgmpy.inference import VariableElimination

model = DiscreteBayesianNetwork([('Rain', 'WetGrass')])

cpd_rain = TabularCPD(variable='Rain', variable_card=2,
                       values=[[0.8], [0.2]])

cpd_wetgrass = TabularCPD(variable='WetGrass', variable_card=2,
                           values=[[0.9, 0.1], [0.1, 0.9]],
                           evidence=['Rain'], evidence_card=[2])

model.add_cpds(cpd_rain, cpd_wetgrass)
model.check_model()

infer = VariableElimination(model)
result = infer.query(variables=['WetGrass'], evidence={'Rain': 1})
print(result)
```

**Output**

[Unverified] I cannot verify the exact printed output values without executing this code in a live environment against the installed `pgmpy` version. Based on the CPD values defined in the code, the query should return a probability distribution over `WetGrass` conditioned on `Rain = 1`, weighted according to the second column of `cpd_wetgrass` (values 0.1 and 0.9), but exact library output formatting and any version-specific behavior cannot be confirmed here. [Inference] The general behavior of returning a normalized probability table for the queried variable is consistent with pgmpy's documented `VariableElimination.query` interface, though this is based on typical documented usage rather than direct execution in this session.

### Naive Bayes as a Special Case

Naive Bayes classifiers are a restricted form of Bayesian network where a single class variable $C$ is the parent of all feature variables $X_1, \dots, X_n$, and features are assumed conditionally independent given the class:

$$P(C, X_1, \dots, X_n) = P(C) \prod_{i=1}^n P(X_i \mid C)$$

===MERMAID_DIAGRAM===

graph TD

C["Class (svg_diagram)"] --> X1["Feature 1"]

C --> X2["Feature 2"]

C --> X3["Feature 3"]

### Applications in Machine Learning

- Medical diagnosis systems, where symptoms and diseases are modeled as dependent variables.
- Spam filtering, using Naive Bayes as a lightweight special case.
- Sensor fusion and robotics, for combining uncertain measurements.
- Causal inference, since the DAG structure of a Bayesian network is often (though not always) interpreted as encoding causal relationships when additional causal assumptions are layered on top of the purely probabilistic model.

[Inference] Treating a Bayesian network's edges as causal requires additional assumptions beyond the basic probabilistic model, such as the causal Markov condition and faithfulness; a Bayesian network by itself, as a purely statistical object, only encodes conditional independence relationships and does not by itself establish causal direction. This distinction is a standard point made in the causal inference literature, though whether it applies to any specific claimed causal Bayesian network requires checking that network's stated assumptions individually.

### Limitations

- Requires a DAG structure — cannot natively represent cyclic dependencies (e.g., feedback loops) without modification, such as converting to a Dynamic Bayesian Network for temporal cycles.
- Exact inference does not scale well to networks with many variables and high connectivity, due to the NP-hardness of general inference.
- The quality of both structure learning and parameter estimation depends heavily on the amount and quality of available data; behavior on small or biased datasets may vary and is not something that can be assumed to work well without empirical validation.

### Conclusion

Bayesian networks provide a structured, graph-based framework for representing joint probability distributions compactly by exploiting conditional independence relationships. Their factorized representation supports both probabilistic inference and structured reasoning about dependency patterns such as chains, forks, and colliders. Practical use requires attention to the scalability limits of exact inference and the assumptions required to interpret network structure causally rather than purely statistically.

**Related Topics**

- Markov Random Fields and Undirected Graphical Models
- Hidden Markov Models
- Dynamic Bayesian Networks
- Causal Inference and Structural Causal Models
- Naive Bayes Classifiers
- Variable Elimination Algorithm
- Markov Chain Monte Carlo Methods
- D-Separation and Conditional Independence Testing
- Structure Learning Algorithms (PC Algorithm, Hill-Climbing Search)