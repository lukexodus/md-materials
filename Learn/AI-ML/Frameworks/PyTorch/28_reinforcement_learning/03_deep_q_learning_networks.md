## Deep Q-Learning Networks


Deep Q-Networks (DQN) combine Q-learning with deep neural networks to handle high-dimensional state spaces while learning optimal action-value functions. This breakthrough enabled reinforcement learning success in complex domains like Atari games and robotics.

The DQN algorithm approximates the optimal action-value function Q*(s,a) using a deep neural network trained with temporal difference learning. The approach faces challenges including non-stationary targets, correlated sequential data, and overestimation bias.

### Experience Replay

Experience replay stores transitions in a replay buffer and samples random batches for training, breaking temporal correlations and enabling more stable learning. This technique reuses experiences multiple times and smooths over changes in the data distribution.

```python
class ReplayBuffer:
    def __init__(self, capacity):
        self.buffer = deque(maxlen=capacity)
    
    def push(self, state, action, reward, next_state, done):
        self.buffer.append((state, action, reward, next_state, done))
    
    def sample(self, batch_size):
        batch = random.sample(self.buffer, batch_size)
        states, actions, rewards, next_states, dones = zip(*batch)
        return (torch.stack(states), torch.tensor(actions), 
                torch.tensor(rewards), torch.stack(next_states), torch.tensor(dones))
```

### Target Networks

Target networks provide stable training targets by maintaining separate networks for computing target values. The target network parameters are updated periodically or through exponential moving averages, reducing training instability from rapidly changing targets.

### Double DQN

Double DQN addresses overestimation bias by decoupling action selection from action evaluation. The online network selects actions while the target network evaluates the selected actions, reducing positive bias in value estimation.

```python
def double_dqn_loss(online_q, target_q, states, actions, rewards, next_states, dones, gamma=0.99):
    current_q = online_q(states).gather(1, actions.unsqueeze(1))
    
    ## Double DQN: online network selects actions, target network evaluates
    next_actions = online_q(next_states).argmax(1, keepdim=True)
    next_q = target_q(next_states).gather(1, next_actions)
    target_values = rewards + gamma * next_q * (1 - dones.float())
    
    return F.mse_loss(current_q.squeeze(), target_values.squeeze())
```

### Dueling DQN

Dueling DQN decomposes Q-values into state values and advantage functions, improving learning efficiency by separating the estimation of state values from action-dependent advantages. This architecture proves particularly effective in environments where action choice has varying importance across states.

### Prioritized Experience Replay

Prioritized replay samples experiences based on temporal difference errors, focusing learning on transitions where the agent's predictions are most incorrect. This approach improves sample efficiency by learning more from informative experiences.

**Rainbow DQN** combines multiple DQN improvements including double Q-learning, prioritized replay, dueling networks, multi-step returns, distributional RL, and noisy networks into a single algorithm achieving state-of-the-art performance.

**Key Points:**
- Experience replay and target networks are fundamental to stable deep Q-learning
- Overestimation bias significantly impacts performance and requires careful mitigation
- Combining multiple improvements often yields synergistic performance gains

