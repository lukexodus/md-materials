## Module 3: Actor-Critic Methods


### 3.1 Actor-Critic Architecture

- Actor component (policy)
- Critic component (value function)
- Advantage function estimation
- Separation of concerns
- Shared vs separate networks

### 3.2 Classical Actor-Critic

- Online actor-critic
- TD error as critic signal
- Policy gradient update
- Baseline from value function
- Convergence properties

### 3.3 Advantage Actor-Critic (A2C)

- Synchronous updates
- Parallel environment sampling
- Advantage estimation
- Implementation architecture
- Stability considerations

### 3.4 Asynchronous Advantage Actor-Critic (A3C)

- Asynchronous updates
- Thread-based parallelism
- Gradient accumulation
- Lock-free optimization
- Exploration diversity

### 3.5 Deep Deterministic Policy Gradient (DDPG)

- Deterministic actor
- Q-function critic
- Target networks (actor and critic)
- Ornstein-Uhlenbeck noise
- Batch normalization
- Replay buffer integration
- Continuous control applications

### 3.6 Twin Delayed DDPG (TD3)

- Clipped double Q-learning
- Delayed policy updates
- Target policy smoothing
- Addressing overestimation
- Stability improvements

### 3.7 Soft Actor-Critic (SAC)

- Maximum entropy framework
- Stochastic actor
- Twin Q-functions
- Automatic temperature tuning
- Sample efficiency
- Off-policy learning
- Stability and robustness

### 3.8 Multi-Critic Architectures

- Ensemble critics
- Variance reduction
- Uncertainty estimation
- Overestimation mitigation

### 3.9 Distributed Actor-Critic Methods

- IMPALA (Importance Weighted Actor-Learner Architecture)
    - V-trace correction
    - Distributed architecture
    - Actor-learner separation
- Ape-X DQN/DDPG
    - Distributed replay
    - Prioritization

---

