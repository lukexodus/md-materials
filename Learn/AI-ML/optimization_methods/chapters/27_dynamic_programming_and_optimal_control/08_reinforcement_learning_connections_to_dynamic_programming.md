## Reinforcement Learning Connections to Dynamic Programming

### Definition and Core Idea

Reinforcement learning (RL) is a framework for solving sequential decision problems formulated as Markov Decision Processes (MDPs) in which the transition probabilities and/or reward function are **unknown** to the decision-maker and must be learned through interaction with the environment, rather than being specified in advance as in classical dynamic programming. RL methods retain the same underlying mathematical objects introduced in the Bellman equation and discrete-time dynamic programming — states, actions, transitions, rewards, value functions, and the Bellman optimality equation — but replace the exact backward-induction or iterative solution methods (which require full knowledge of the model) with sample-based, data-driven algorithms that estimate value functions or policies directly from observed trajectories of states, actions, and rewards.

### The Model-Based vs. Model-Free Distinction

This is the central conceptual line connecting and separating classical dynamic programming from reinforcement learning:

- **Model-based (classical DP)**: the transition probabilities $P(s'|s,a)$ and reward function $c(s,a)$ (or $r(s,a)$ in reward-maximization notation) are fully known, allowing value iteration, policy iteration, or backward induction to be applied directly, as described in the Bellman equation and discrete-time dynamic programming entries.
- **Model-free (much of RL)**: the agent does not know $P(s'|s,a)$ or $r(s,a)$ in advance and must estimate value functions or policies purely from observed transitions $(s_t, a_t, r_t, s_{t+1})$ collected by interacting with the environment.
- **Model-based RL**: an intermediate category in which the agent learns an explicit estimate of $P(s'|s,a)$ and $r(s,a)$ from data, then applies classical DP-style planning (value iteration, policy iteration, or tree search) using the learned model.

This distinction determines which classical DP tools carry over directly (with sampling substituted for exact expectation) and which require fundamentally different algorithmic ideas (such as exploration strategies, discussed below).

### Diagram: DP-to-RL Conceptual Map

===MERMAID_DIAGRAM===

flowchart TD

A["Classical Dynamic Programming (svg_diagram)<br/>Known P(s'|s,a), r(s,a)"] --> B["Value Iteration /<br/>Policy Iteration<br/>(exact expectation)"]

C["Reinforcement Learning<br/>Unknown P(s'|s,a), r(s,a)"] --> D["Model-Free RL<br/>(learn V or Q from samples)"]

C --> E["Model-Based RL<br/>(learn model, then plan)"]

D --> F["Monte Carlo Methods"]

D --> G["Temporal-Difference<br/>Methods (TD, Q-learning)"]

E --> H["Learned Model +<br/>Classical DP Planning"]

B -.shared foundation.-> I["Bellman Equation /<br/>Principle of Optimality"]

D -.shared foundation.-> I

E -.shared foundation.-> I

### The Q-Function: A Key RL-Specific Object

While classical DP typically works with the state-value function $V(s)$, RL algorithms frequently work with the **action-value function** (Q-function):

$$Q(s,a) = \mathbb{E}\left[ r(s,a) + \gamma \, \mathbb{E}_{s' \sim P(\cdot|s,a)}\left[ V(s') \right] \right]$$

related to $V(s)$ by $V(s) = \max_a Q(s,a)$ (for reward maximization; $\min_a$ for cost minimization). The Q-function is preferred in the model-free setting because it allows the greedy policy $\pi(s) = \arg\max_a Q(s,a)$ to be extracted **without** requiring knowledge of the transition model $P(s'|s,a)$ — whereas extracting a greedy policy from $V(s)$ alone requires exactly the model knowledge that model-free RL assumes is unavailable. This single structural difference is a primary reason Q-functions are central to model-free value-based RL.

### Monte Carlo Methods

The most direct sample-based analogue of DP's value function computation: rather than computing $V^\pi(s)$ via the Bellman expectation equation (which requires the transition model), Monte Carlo methods estimate $V^\pi(s)$ by averaging the observed cumulative returns from many sampled trajectories starting from (or passing through) state $s$ under policy $\pi$:

$$V^\pi(s) \approx \frac{1}{K} \sum_{k=1}^{K} G_k(s)$$

where $G_k(s)$ is the observed cumulative discounted return following the $k$-th visit to state $s$ in a sampled trajectory. This is conceptually a direct empirical-average replacement for the expectation in the Bellman expectation equation, closely paralleling the empirical-average logic of sample average approximation, but applied to value estimation within a sequential decision process rather than to a single-stage stochastic objective. A key limitation is that Monte Carlo methods require complete episodes (trajectories that reach a terminal state) before any update can be made, which is unsuitable for continuing (non-episodic) tasks.

### Temporal-Difference Learning

**Temporal-difference (TD) learning** addresses Monte Carlo's requirement for complete episodes by updating value estimates using a **bootstrapped** target: rather than waiting for the full observed return, TD methods update $V(s_t)$ using the immediately observed reward plus the current estimate of the value at the next state:

$$V(s_t) \leftarrow V(s_t) + \alpha \left[ \underbrace{r_t + \gamma V(s_{t+1})}_{\text{TD target}} - V(s_t) \right]$$

where $\alpha$ is a learning rate and the bracketed quantity is the **TD error**. This update rule is a sample-based, incremental version of the Bellman expectation equation: the TD target $r_t + \gamma V(s_{t+1})$ is precisely a single-sample estimate of the expectation $\mathbb{E}[r + \gamma V(s')]$ that appears in the exact Bellman expectation equation, and bootstrapping (using the current estimate $V(s_{t+1})$ rather than the true value) is what allows updates after every single transition rather than only at the end of an episode.

### Q-Learning

**Q-learning** extends TD learning to directly estimate the optimal action-value function $Q^*(s,a)$ without requiring a model, using the update:

$$Q(s_t,a_t) \leftarrow Q(s_t,a_t) + \alpha \left[ r_t + \gamma \max_{a'} Q(s_{t+1}, a') - Q(s_t,a_t) \right]$$

This update is a direct sample-based analogue of the Bellman **optimality** equation (as opposed to the Bellman expectation equation used in TD learning for policy evaluation), since the target uses $\max_{a'} Q(s_{t+1},a')$ rather than the value under the current behavior policy. Q-learning is classified as an **off-policy** algorithm because the update target does not depend on the action the agent would actually take next under its current behavior policy — it uses the maximizing action regardless of what action is actually selected next, allowing it to learn the optimal policy while following any sufficiently exploratory behavior policy.

### SARSA: An On-Policy Alternative

**SARSA** (State-Action-Reward-State-Action) uses a closely related but **on-policy** update:

$$Q(s_t,a_t) \leftarrow Q(s_t,a_t) + \alpha \left[ r_t + \gamma\, Q(s_{t+1}, a_{t+1}) - Q(s_t,a_t) \right]$$

where $a_{t+1}$ is the action actually selected by the current behavior policy at $s_{t+1}$, rather than the maximizing action. This makes SARSA's learned Q-function reflect the value of the policy actually being followed (including its exploration behavior), whereas Q-learning's target reflects the value of the greedy policy regardless of the exploration strategy in use — a distinction with practical consequences in environments where exploration carries risk (e.g., SARSA tends to learn more cautious policies in such settings, since its updates account for the possibility of exploratory, potentially costly actions).

### The Exploration-Exploitation Tradeoff

A feature entirely absent from classical dynamic programming but central to reinforcement learning is the **exploration-exploitation tradeoff**: since the agent does not know the transition and reward functions in advance, it must balance **exploiting** its current estimate of the optimal policy (to accumulate reward) against **exploring** alternative actions (to improve its estimates and avoid converging prematurely to a suboptimal policy). Classical DP has no analogue to this tradeoff, since the model is assumed fully known and no data collection is required. Common exploration strategies include:

- **$\epsilon$-greedy**: with probability $\epsilon$, select a random action; otherwise, select the current greedy action.
- **Upper Confidence Bound (UCB) methods**: select actions based on both estimated value and estimation uncertainty, favoring actions with high uncertainty as well as high estimated value.
- **Softmax/Boltzmann exploration**: select actions probabilistically, weighted by their estimated values, so higher-valued actions are more likely but not guaranteed to be chosen.

### Function Approximation and Deep Reinforcement Learning

Just as classical dynamic programming faces the curse of dimensionality for large or continuous state spaces, tabular RL methods (which store a separate value estimate for every state or state-action pair) face the identical scaling problem. The RL response, directly paralleling **approximate dynamic programming**, is to represent $V(s)$ or $Q(s,a)$ using a parametric function approximator — historically linear basis functions, and more recently deep neural networks, giving rise to **deep reinforcement learning**. Notable examples include **Deep Q-Networks (DQN)**, which approximate $Q(s,a;\theta)$ with a neural network trained using a TD-style loss derived directly from the Q-learning update rule. [Inference] The theoretical convergence guarantees available for tabular TD and Q-learning (under standard step-size and exploration conditions) generally do not carry over automatically to the function-approximation setting, since combining bootstrapping, function approximation, and off-policy learning is known to introduce potential instability, which is a primary motivation for the additional stabilization techniques (e.g., experience replay, target networks) used in practical deep RL algorithms like DQN.

### Policy Gradient Methods: A Distinct Family

Value-based methods (Q-learning, SARSA, DQN) estimate a value function and derive a policy implicitly (e.g., greedily). **Policy gradient methods** instead directly parametrize a policy $\pi_\theta(a|s)$ and optimize its parameters via gradient ascent on the expected return, using the **policy gradient theorem** to compute an estimate of the gradient from sampled trajectories. This family connects less directly to the Bellman equation's value-function recursion and more directly to stochastic gradient-based optimization methods, though many practical policy gradient algorithms (e.g., actor-critic methods) incorporate a learned value function (the "critic") that is itself estimated using TD-learning-style updates, blending the two families.

### Practical Example

**Example**

Consider a simplified grid-world navigation problem: an agent occupies one of 16 grid cells (a 4x4 grid), can move up/down/left/right, receives a reward of $-1$ per step (encouraging shortest paths) and $+10$ upon reaching a designated goal cell (terminating the episode), with walls preventing movement off the grid. Unlike the equipment replacement or inventory examples used for classical dynamic programming, the agent does **not** know the transition probabilities or reward function in advance — it must learn purely from experience.

Applying Q-learning: initialize $Q(s,a) = 0$ for all 16 states and 4 actions. The agent follows an $\epsilon$-greedy policy (e.g., $\epsilon = 0.1$) to select actions, observes the resulting reward and next state after each move, and applies the Q-learning update after every single transition (not just at episode completion, unlike Monte Carlo methods). This process is repeated over many episodes (each episode ending when the agent reaches the goal).

**Output**

Over successive episodes, the Q-values converge toward the optimal action-value function $Q^*(s,a)$ for this grid world, provided the learning rate $\alpha$ is appropriately scheduled and every state-action pair is visited infinitely often in the limit (guaranteed here by the persistent $\epsilon$-greedy exploration) — this is the standard tabular Q-learning convergence guarantee. Once converged, the greedy policy $\pi(s) = \arg\max_a Q^*(s,a)$ recovers the shortest path from any grid cell to the goal, matching what backward-induction dynamic programming would have computed directly and exactly, had the transition and reward model been known in advance.

### Applications Bridging DP and RL

- **Game playing**: classical board games (e.g., backgammon, and later Go and chess via deep RL) where the state space is far too large for exact dynamic programming, motivating sample-based RL approaches combined with function approximation and, in some cases, tree search methods that borrow directly from DP-style planning.
- **Robotics and control**: RL is increasingly applied to control problems traditionally addressed via classical optimal control (LQR, MPC) when an accurate system model is unavailable or difficult to derive analytically, though model-based control methods often remain preferred when a good model is available, due to their stronger theoretical guarantees.
- **Operations research applications**: inventory control, dynamic pricing, and resource allocation problems traditionally solved via exact dynamic programming are increasingly explored using RL when demand or system dynamics are too complex or poorly characterized to model exactly.
- **Recommendation systems and online decision-making**: sequential decision problems where user behavior (the "transition model") is inherently unknown and must be learned from interaction data, naturally framed as RL rather than classical DP problems.

### Computational Considerations

- **Sample efficiency**: unlike classical DP, which computes exact solutions given a known model, RL methods require potentially large amounts of interaction data (or simulated experience) to achieve accurate value or policy estimates, and sample efficiency is a major practical and research concern, particularly in real-world settings where data collection is costly or risky.
- **Convergence guarantees**: tabular TD learning, SARSA, and Q-learning have established convergence guarantees under standard conditions (appropriately decaying step sizes, sufficient exploration), directly inherited from stochastic approximation theory, but these guarantees weaken or require additional assumptions once function approximation and off-policy learning are combined.
- **Bias-variance tradeoff between Monte Carlo and TD methods**: Monte Carlo estimates are unbiased but can have high variance (since they depend on entire trajectory returns), while TD methods introduce bias (through bootstrapping with a possibly inaccurate current value estimate) but typically have lower variance, and often converge faster in practice as a result of this tradeoff.

### Common Pitfalls

- Conflating model-free RL algorithms with the model-based classical DP algorithms they parallel; for example, assuming Q-learning inherits value iteration's exact convergence properties without accounting for the effects of sampling noise, exploration strategy, and (if used) function approximation.
- Applying Monte Carlo methods to continuing (non-terminating) tasks without modification, since these methods fundamentally require complete episodes to compute the observed return.
- Overlooking the on-policy/off-policy distinction between SARSA and Q-learning, which can lead to unexpected differences in learned behavior, particularly in environments with exploration-related risk.
- Assuming deep RL methods (e.g., DQN) inherit the same theoretical convergence guarantees as tabular Q-learning, when in fact the combination of bootstrapping, off-policy learning, and function approximation is a recognized source of potential instability requiring dedicated stabilization techniques.

**Related Topics**

- Bellman equation and the Principle of Optimality
- Discrete-time dynamic programming
- Approximate dynamic programming and function approximation
- Markov Decision Processes
- Policy gradient methods and actor-critic algorithms
- Deep Q-Networks and deep reinforcement learning stabilization techniques
- Exploration strategies in sequential decision-making
- Model-based reinforcement learning and planning