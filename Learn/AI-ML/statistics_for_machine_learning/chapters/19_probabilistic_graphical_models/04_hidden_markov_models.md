## Hidden Markov Models

### Definition

A Hidden Markov Model (HMM) is a statistical model for sequential data in which the system is assumed to be a Markov process with unobserved (hidden) states. At each time step, the model occupies a hidden state that emits an observable output, and the sequence of hidden states follows the Markov property: the next state depends only on the current state, not on the full history.

### Formal Components

An HMM is defined by the following elements:

- A finite set of hidden states $S = \{s_1, \dots, s_N\}$
- A finite set of possible observations $O = \{o_1, \dots, o_M\}$ (for discrete HMMs) or a continuous observation space with an emission density (for continuous HMMs)
- A state transition probability matrix $A$, where $A_{ij} = P(q_{t+1} = s_j \mid q_t = s_i)$
- An emission probability distribution $B$, where $B_j(o) = P(x_t = o \mid q_t = s_j)$
- An initial state distribution $\pi$, where $\pi_i = P(q_1 = s_i)$

The complete model is often denoted $\lambda = (A, B, \pi)$.

### The Markov Assumption

$$P(q_t \mid q_1, q_2, \dots, q_{t-1}) = P(q_t \mid q_{t-1})$$

This first-order Markov assumption states that the current hidden state depends only on the immediately preceding state. [Inference] This is a simplifying assumption rather than a property that holds for all real-world sequential processes; whether it adequately approximates any specific real-world system is not something that can be confirmed without testing against that system's actual data.

### The Independence Assumption on Observations

$$P(x_t \mid q_1, \dots, q_t, x_1, \dots, x_{t-1}) = P(x_t \mid q_t)$$

Each observation is assumed to depend only on the current hidden state, not on prior states or prior observations.

### Graphical Structure

===MERMAID_DIAGRAM===

graph LR

Q1["Hidden State 1 (svg_diagram)"] --> Q2["Hidden State 2"]

Q2 --> Q3["Hidden State 3"]

Q1 --> X1["Observation 1"]

Q2 --> X2["Observation 2"]

Q3 --> X3["Observation 3"]

style Q1 fill:#2d5,stroke:#333

style Q2 fill:#2d5,stroke:#333

style Q3 fill:#2d5,stroke:#333

### Joint Distribution

The joint probability of a hidden state sequence $q_{1:T}$ and observation sequence $x_{1:T}$ factorizes as:

$$P(q_{1:T}, x_{1:T}) = \pi_{q_1} \prod_{t=2}^{T} A_{q_{t-1} q_t} \prod_{t=1}^{T} B_{q_t}(x_t)$$

This factorization follows directly from the Markov and observation independence assumptions stated above, combined with the chain rule of probability.

### The Three Canonical Problems

HMMs are traditionally organized around three inference problems, a framing widely used in the standard HMM literature (e.g., Rabiner's 1989 tutorial on HMMs):

**1. Evaluation Problem**: Given a model $\lambda$ and an observation sequence $x_{1:T}$, compute $P(x_{1:T} \mid \lambda)$. Solved using the **Forward algorithm** (or Backward algorithm).

**2. Decoding Problem**: Given a model $\lambda$ and an observation sequence $x_{1:T}$, find the most likely hidden state sequence $q_{1:T}$. Solved using the **Viterbi algorithm**.

**3. Learning Problem**: Given an observation sequence $x_{1:T}, estimate the model parameters $\lambda = (A, B, \pi)
 that maximize $P(x_{1:T} \mid \lambda)$. Solved using the **Baum-Welch algorithm** (a special case of Expectation-Maximization).

### Forward Algorithm

Defines $\alpha_t(i) = P(x_1, \dots, x_t, q_t = s_i \mid \lambda)$, computed recursively:

$$\alpha_1(i) = \pi_i B_i(x_1)$$



$$\alpha_{t+1}(j) = \left[\sum_{i=1}^{N} \alpha_t(i) A_{ij}\right] B_j(x_{t+1})$$

The total likelihood is obtained by summing over the final time step:

$$P(x_{1:T} \mid \lambda) = \sum_{i=1}^{N} \alpha_T(i)$$

This recursive formulation reduces the computational cost from exponential in $T$ (summing over all possible state sequences directly) to $O(N^2 T)$, by reusing partial computations. [Inference] This complexity reduction is a well-established property of the algorithm's dynamic programming structure, though actual runtime in a specific implementation depends on factors such as programming language, hardware, and whether the implementation is vectorized.

### Viterbi Algorithm

Defines $\delta_t(i) = \max_{q_1, \dots, q_{t-1}} P(q_1, \dots, q_{t-1}, q_t = s_i, x_1, \dots, x_t \mid \lambda)$, computed recursively:

$$\delta_1(i) = \pi_i B_i(x_1)$$



$$\delta_{t+1}(j) = \max_i \left[\delta_t(i) A_{ij}\right] B_j(x_{t+1})$$

Backtracking through stored argmax pointers recovers the most likely hidden state sequence. This is a dynamic programming approach analogous to the Forward algorithm, but using max instead of sum at each step.

### Baum-Welch Algorithm (EM for HMMs)

The Baum-Welch algorithm alternates between two steps:

- **E-step**: Compute expected state occupancy and transition counts using the Forward-Backward algorithm, given current parameter estimates.
- **M-step**: Re-estimate $A$, $B$, and $\pi$ using these expected counts, analogous to maximum likelihood estimation with soft (probabilistic) counts instead of hard counts.

$$\hat{A}_{ij} = \frac{\text{expected transitions from } s_i \text{ to } s_j}{\text{expected transitions from } s_i}$$

[Inference] As an instance of the EM algorithm, Baum-Welch is generally understood to converge to a local optimum of the likelihood function rather than a global optimum, and outcomes can depend on parameter initialization. This is a commonly stated property of EM-based methods in the literature, not a claim I have independently verified through execution in this session.

### Worked Example: Weather and Activities

A classic illustrative HMM: hidden states are `Rainy` and `Sunny`; observations are `Walk`, `Shop`, `Clean`.

===MERMAID_DIAGRAM===

graph LR

R["Rainy (svg_diagram)"] -->|0.7| R

R -->|0.3| Su["Sunny"]

Su -->|0.4| R

Su -->|0.6| Su

R -.->|emits| Clean

Su -.->|emits| Walk

**Example**

```python
import numpy as np
from hmmlearn import hmm

model = hmm.CategoricalHMM(n_components=2, random_state=42)
model.startprob_ = np.array([0.6, 0.4])
model.transmat_ = np.array([[0.7, 0.3],
                             [0.4, 0.6]])
model.emissionprob_ = np.array([[0.1, 0.4, 0.5],
                                 [0.6, 0.3, 0.1]])

observations = np.array([[0, 1, 2, 1, 0]]).T
logprob, hidden_states = model.decode(observations, algorithm="viterbi")

print("Log probability:", logprob)
print("Hidden states:", hidden_states)
```

**Output**

I cannot verify the exact numerical output of this code without executing it in a live environment. [Inference] Based on the structure of the `hmmlearn` API and the Viterbi algorithm as described above, the output is expected to consist of a log-probability scalar and an array of integer state indices of the same length as the input observation sequence, but I cannot confirm the specific numerical values without running the code directly.

### Continuous HMMs

When observations are continuous rather than discrete, the emission distribution $B_j(x)$ is typically modeled as a Gaussian or Gaussian Mixture Model rather than a categorical distribution:

$$B_j(x) = \mathcal{N}(x \mid \mu_j, \Sigma_j)$$

This variant is commonly referred to as a Gaussian HMM, and is used in applications such as speech recognition acoustic modeling.

### Comparison with Related Models

| Model | State Type | Structure |
| --- | --- | --- |
| Markov Chain | Observed | States directly observed, no hidden layer |
| Hidden Markov Model | Hidden, discrete | Hidden discrete states, sequential |
| Kalman Filter | Hidden, continuous | Hidden continuous states, linear-Gaussian dynamics |
| Conditional Random Field | N/A (discriminative) | Directly models $P(Y \mid X)$, no generative assumption on $X$ |

[Inference] The Kalman filter can be understood as a continuous-state analogue of the HMM under linear-Gaussian assumptions; this relationship is commonly described in the graphical models and signal processing literature, though I do not have a specific verified primary source to cite within this conversation.

### Applications in Machine Learning

- Speech recognition, modeling phoneme sequences as hidden states underlying acoustic observations.
- Part-of-speech tagging in natural language processing, where grammatical tags are hidden states and words are observations.
- Bioinformatics, for gene prediction and sequence alignment (e.g., profile HMMs).
- Financial time series modeling, treating latent market regimes as hidden states.

[Unverified] I do not have access to specific performance benchmarks for these applications within this conversation, so I cannot state how well HMMs perform relative to alternative methods (e.g., neural sequence models) on any particular dataset without a cited source.

### Limitations

- The first-order Markov assumption may not adequately capture longer-range dependencies present in some real-world sequences; whether this matters depends on the specific application and is not something that can be assumed generally.
- The number of hidden states $N$ is typically fixed in advance and must be chosen using methods such as cross-validation or information criteria; there is no single method that reliably works across all datasets.
- Baum-Welch, as an EM-based method, is not guaranteed to reach a global optimum, and results can depend on initialization. Behavior may vary across different implementations and software versions, and I cannot confirm specific convergence behavior without direct testing.

### Conclusion

Hidden Markov Models provide a generative probabilistic framework for sequential data with unobserved discrete states, built on a first-order Markov assumption and observation independence given the current state. The Forward, Viterbi, and Baum-Welch algorithms address the three canonical evaluation, decoding, and learning problems using dynamic programming, reducing what would otherwise be exponential computation to polynomial time. Practical use requires attention to model assumptions, initialization sensitivity in parameter learning, and the fixed-state-count limitation.

**Related Topics**

- Markov Chains and Transition Matrices
- Kalman Filters and State-Space Models
- Conditional Random Fields
- Expectation-Maximization Algorithm
- Viterbi Algorithm
- Forward-Backward Algorithm
- Bayesian Networks
- Sequence Labeling in Natural Language Processing