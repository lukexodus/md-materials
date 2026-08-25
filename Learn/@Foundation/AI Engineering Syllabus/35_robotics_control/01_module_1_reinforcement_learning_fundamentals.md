## Module 1: Reinforcement Learning Fundamentals


### 1.1 RL Problem Formulation

- Markov Decision Processes (MDPs)
    - States, actions, rewards
    - Transition dynamics
    - Discount factor rationale
    - Episode vs continuing tasks
- Partially Observable MDPs (POMDPs)
    - Belief states
    - Observation models
    - History and memory

### 1.2 Core RL Concepts

- Return and value functions
    - Cumulative return
    - Discounted return
    - State-value function V(s)
    - Action-value function Q(s,a)
- Policies
    - Deterministic policies
    - Stochastic policies
    - Policy representation
- Bellman equations
    - Bellman expectation equations
    - Bellman optimality equations
    - Dynamic programming perspective

### 1.3 Exploration vs Exploitation

- Multi-armed bandits
    - ε-greedy strategies
    - Upper Confidence Bound (UCB)
    - Thompson sampling
    - Contextual bandits
- Exploration strategies
    - Random exploration
    - Entropy regularization
    - Curiosity-driven exploration
    - Count-based exploration
    - Intrinsic motivation

### 1.4 Value-Based Methods

- Dynamic Programming
    - Policy evaluation
    - Policy improvement
    - Policy iteration
    - Value iteration
- Monte Carlo methods
    - First-visit vs every-visit MC
    - MC prediction
    - MC control
    - Importance sampling
- Temporal Difference learning
    - TD(0) prediction
    - TD(λ) and eligibility traces
    - SARSA (on-policy)
    - Q-Learning (off-policy)
    - Expected SARSA
    - Double Q-Learning

### 1.5 Function Approximation

- Linear function approximation
- Feature engineering for RL
- Non-linear approximation with neural networks
- Value function approximation
- Deadly triad challenges
    - Function approximation
    - Bootstrapping
    - Off-policy learning
- Experience replay
    - Replay buffer mechanics
    - Prioritized experience replay
    - Hindsight experience replay (HER)

### 1.6 Deep Q-Networks (DQN)

- DQN architecture
- Target networks
- Loss function formulation
- Training stability techniques
- Double DQN
    - Overestimation bias
    - Action selection vs evaluation
- Dueling DQN
    - Value and advantage streams
    - Aggregation methods
- Rainbow DQN
    - Component integration
    - Performance analysis

---

