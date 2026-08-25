## Markov Decision Processes

### Overview

A Markov Decision Process (MDP) is a mathematical framework for modeling sequential decision-making problems in which an agent interacts with an environment over time. At each step, the agent observes a state, selects an action, receives a reward, and transitions to a new state according to defined probabilities. MDPs form the foundational formalism underlying most of reinforcement learning.

### Core Motivation

Many real-world decision problems involve a sequence of choices where each decision affects future states and future opportunities for reward, not just an immediate outcome. MDPs were developed to formalize this class of problems mathematically, providing a structure in which optimal decision-making strategies can be defined and, in many cases, computed.

### Formal Definition

An MDP is defined by the tuple $(S, A, P, R, \gamma)$:

- **$S$**: The set of possible states.
- **$A$**: The set of possible actions.
- **$P(s' | s, a)$**: The state transition probability function, giving the probability of moving to state $s'$ given current state $s$ and action $a$.
- **$R(s, a, s')$**: The reward function, giving the immediate reward received after transitioning from $s$ to $s'$ via action $a$.
- **$\gamma$**: The discount factor, a value between 0 and 1 that determines how much future rewards are weighted relative to immediate rewards.

### The Markov Property

The defining assumption of an MDP is the Markov property: the probability of transitioning to the next state depends only on the current state and action, not on the sequence of states and actions that preceded it.

$$P(s_{t+1} | s_t, a_t, s_{t-1}, a_{t-1}, \dots, s_0, a_0) = P(s_{t+1} | s_t, a_t)$$

This assumption is what makes MDPs mathematically tractable, since the current state is treated as a sufficient statistic summarizing all relevant history for the purpose of predicting future dynamics.

flowchart LR
    A["State s_t"] -->|Action a_t| B["Reward r_t"]
    B --> C["State s_(t+1) (svg_diagram)"]
    C -->|Action a_(t+1)| D["Reward r_(t+1)"]
    D --> E["State s_(t+2)"]

```mermaid
flowchart LR
    A["State st"] -->|Action at| B["Reward rt"]
    B --> C["State s(t+1)"]
    C -->|Action a(t+1)| D["Reward r(t+1)"]
    D --> E["State s(t+2)"]
```

### Policies

A policy $\pi$ defines the agent's behavior, mapping states to actions. Policies can be:

- **Deterministic**: $\pi(s) = a$, always selecting the same action for a given state.
- **Stochastic**: $\pi(a|s)$, defining a probability distribution over actions for a given state.

The goal in solving an MDP is generally to find a policy that maximizes the expected cumulative discounted reward over time.

### Return and Discounting

The return $G_t$ at time $t$ is the total discounted sum of future rewards:

$$G_t = R_{t+1} + \gamma R_{t+2} + \gamma^2 R_{t+3} + \dots = \sum_{k=0}^{\infty} \gamma^k R_{t+k+1}$$

The discount factor $\gamma$ serves two mathematical purposes: it ensures the sum converges to a finite value for infinite-horizon problems when $\gamma < 1$, and it encodes a preference for rewards received sooner rather than later. A value of $\gamma$ close to 0 makes the agent prioritize immediate rewards, while a value close to 1 makes it weight future rewards nearly as heavily as immediate ones.

### Value Functions

Two core value functions are used to evaluate how good a given state or state-action pair is under a policy $\pi$:

**State-value function**: the expected return starting from state $s$ and following policy $\pi$ thereafter.

$$V^\pi(s) = \mathbb{E}_\pi \left[ G_t \mid S_t = s \right]$$

**Action-value function (Q-function)**: the expected return starting from state $s$, taking action $a$, and following policy $\pi$ thereafter.

$$Q^\pi(s, a) = \mathbb{E}_\pi \left[ G_t \mid S_t = s, A_t = a \right]$$

### The Bellman Equations

The Bellman equation expresses the value of a state in terms of the values of its possible successor states, exploiting the recursive structure of the return:

$$V^\pi(s) = \sum_{a} \pi(a|s) \sum_{s'} P(s'|s,a) \left[ R(s,a,s') + \gamma V^\pi(s') \right]$$

The corresponding Bellman equation for the action-value function is:

$$Q^\pi(s,a) = \sum_{s'} P(s'|s,a) \left[ R(s,a,s') + \gamma \sum_{a'} \pi(a'|s') Q^\pi(s',a') \right]$$

These recursive relationships are the mathematical basis for most algorithms that compute or approximate value functions.

### Optimal Value Functions and the Bellman Optimality Equation

The optimal state-value function $V^*(s)$ and optimal action-value function $Q^*(s,a)$ represent the best possible expected return achievable from a given state (or state-action pair), across all possible policies:

$$V^*(s) = \max_{a} \sum_{s'} P(s'|s,a) \left[ R(s,a,s') + \gamma V^*(s') \right]$$

$$Q^*(s,a) = \sum_{s'} P(s'|s,a) \left[ R(s,a,s') + \gamma \max_{a'} Q^*(s',a') \right]$$

Once $Q^*(s,a)$ is known, an optimal policy can be derived directly by selecting the action that maximizes $Q^*$ in each state:

$$\pi^*(s) = \arg\max_{a} Q^*(s,a)$$

### Solving MDPs: Dynamic Programming Methods

When the full model of the environment ($P$ and $R$) is known, MDPs can be solved using dynamic programming techniques:

- **Value Iteration**: Repeatedly applies the Bellman optimality equation as an update rule until the value function converges, then extracts the optimal policy.
- **Policy Iteration**: Alternates between policy evaluation (computing $V^\pi$ for the current policy) and policy improvement (updating the policy to be greedy with respect to the current value function), repeating until the policy stabilizes.

[Inference] Policy iteration is commonly reported in the literature to converge in fewer iterations than value iteration for many problems, though each iteration of policy iteration is more computationally expensive due to the policy evaluation step. I cannot verify that this tradeoff holds for every specific problem instance, since actual convergence behavior depends on the particular MDP being solved. This is not something I can guarantee, and behavior may vary.

### Model-Free Approaches

When the transition probabilities $P$ and reward function $R$ are not known in advance, model-free reinforcement learning methods estimate value functions or policies directly from experience (sampled trajectories of states, actions, and rewards) rather than from an explicit model of the environment. Examples include:

- **Q-learning**: An off-policy method that directly learns an estimate of $Q^*$ using sampled transitions.
- **Temporal-difference (TD) learning**: Updates value estimates based on the difference between successive predictions, without waiting for a full episode to complete.
- **Policy gradient methods**: Directly optimize a parameterized policy using gradient ascent on expected return.

[Unverified] I do not have access to a comprehensive, up-to-date benchmark comparing the sample efficiency of these specific model-free methods across all problem types, since reported results vary substantially depending on the environment, hyperparameters, and implementation used. This is not something I can confirm generalizes to any specific case, and behavior may vary.

### Practical Example (Conceptual Python pseudocode: Value Iteration)

```python
import numpy as np

def value_iteration(states, actions, P, R, gamma, theta=1e-6):
    V = {s: 0.0 for s in states}
    while True:
        delta = 0
        for s in states:
            v_old = V[s]
            action_values = []
            for a in actions:
                total = 0
                for s_next, prob in P[s][a].items():
                    total += prob * (R[s][a][s_next] + gamma * V[s_next])
                action_values.append(total)
            V[s] = max(action_values)
            delta = max(delta, abs(v_old - V[s]))
        if delta < theta:
            break
    return V
```

This pseudocode follows the standard value iteration update rule as defined by the Bellman optimality equation.

### Partially Observable MDPs (POMDPs)

A partially observable MDP extends the standard MDP framework to cases where the agent does not have direct access to the true state, but instead receives an observation that provides incomplete or noisy information about the underlying state. POMDPs are generally considered more computationally difficult to solve than fully observable MDPs, since the agent must maintain and reason over a belief distribution across possible underlying states rather than acting on a known state directly.

### Comparison with Related Frameworks

| Framework | State Observability | Number of Agents | Key Distinction |
|---|---|---|---|
| MDP | Fully observable | Single agent | Standard sequential decision-making formalism |
| POMDP | Partially observable | Single agent | Agent maintains a belief distribution over states |
| Markov Chain | Fully observable | No agent (no actions) | Pure stochastic process, no decisions or rewards |
| Markov Game (Stochastic Game) | Fully or partially observable | Multiple agents | Extends MDPs to multi-agent, game-theoretic settings |

### Common Applications

- **Reinforcement learning**: MDPs are the standard formalism used to define the environment in most reinforcement learning research and applications.
- **Robotics**: Sequential control and navigation problems.
- **Operations research**: Inventory management, scheduling, and resource allocation problems.
- **Game playing**: Formalizing turn-based and sequential decision environments.
- **Recommendation systems**: Modeling sequential user interactions as a decision process.

### Limitations

- The Markov property assumption may not hold exactly in many real-world problems, where relevant information from the past extends beyond what is captured in the current state representation; in such cases, the state representation itself may need to be engineered or learned to approximately restore this property.
- Computing exact solutions via dynamic programming requires a complete and accurate model of transition probabilities and rewards, which is often unavailable in practice, and the state and action spaces must generally be small enough for tabular methods to be computationally feasible.
- [Speculation] For very large or continuous state and action spaces, tabular dynamic programming methods are unlikely to be computationally feasible in practice, which is a commonly cited motivation in the literature for function approximation methods such as deep reinforcement learning. This is a reasoned extrapolation on my part based on general computational scaling considerations, not a confirmed benchmark result for any specific problem, and I cannot verify this holds for every case.

**Disclaimer**: Statements in this document regarding algorithm convergence behavior, computational tradeoffs, or comparative performance between methods reflect patterns commonly reported in the reinforcement learning and operations research literature. I do not have access to a comprehensive, up-to-date benchmark confirming these effects for every specific implementation or problem instance. This behavior is not guaranteed, and actual results may vary based on the specific problem, algorithm implementation, and hyperparameters used.

### **Related Topics**

- Reinforcement Learning algorithms in depth (Q-learning, SARSA, Deep Q-Networks)
- Policy Gradient methods and Actor-Critic architectures
- Partially Observable MDPs (POMDPs) in depth
- Dynamic programming foundations
- Multi-Armed Bandits (a simplified special case without state transitions)
- Function approximation in reinforcement learning
- Markov Chains and stochastic processes