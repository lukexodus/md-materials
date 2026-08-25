## Module 7: Motion Planning and Control


### 7.1 Motion Planning Fundamentals

- Configuration space
- Workspace vs C-space
- Collision checking
- Planning completeness and optimality
- Kinematic vs dynamic planning

### 7.2 Sampling-Based Planning

- Rapidly-exploring Random Trees (RRT)
    - Basic RRT algorithm
    - RRT* for optimality
    - Informed RRT*
    - Bidirectional RRT
- Probabilistic Roadmaps (PRM)
    - Construction phase
    - Query phase
    - Lazy PRM variants
- Sampling strategies
    - Uniform sampling
    - Gaussian sampling
    - Bridge test sampling

### 7.3 Trajectory Optimization

- Optimization problem formulation
- Direct collocation methods
- Sequential Quadratic Programming (SQP)
- Interior point methods
- Differential Dynamic Programming (DDP)
    - Iterative LQR
    - Shooting methods
- Minimum snap trajectories
- Time-optimal trajectories

### 7.4 Classical Control Methods

- PID control
    - Tuning methods
    - Limitations for nonlinear systems
- Linear Quadratic Regulator (LQR)
    - Riccati equation
    - Infinite horizon LQR
- Model Predictive Control (MPC)
    - Prediction horizon
    - Constraints handling
    - Computational considerations
- Computed torque control
- Impedance control
    - Compliance specification
    - Hybrid force-position control

### 7.5 Learning-Based Control

- Neural network controllers
- End-to-end learning (perception to action)
- Behavioral cloning
    - Supervised learning from demonstrations
    - Distribution mismatch issues
    - DAgger (Dataset Aggregation)
- Inverse reinforcement learning
    - Reward function recovery
    - Maximum entropy IRL
    - Adversarial IRL (GAIL, AIRL)

### 7.6 Manipulation Planning

- Task and motion planning (TAMP)
- Pick-and-place planning
- Assembly planning
- Dual-arm coordination
- Mobile manipulation

### 7.7 Reactive Control

- Artificial potential fields
- Dynamic window approach (DWA)
- Vector field histograms
- Obstacle avoidance behaviors
- Hybrid planning-reactive systems

---

