## Actor-Critic Architectures


Actor-critic methods combine policy gradient approaches with value function approximation, using the critic to estimate value functions that guide policy updates. This architecture reduces variance compared to pure policy gradient methods while maintaining the ability to handle continuous action spaces.

The actor network represents the policy and selects actions, while the critic network estimates value functions to evaluate action quality. The critic provides low-variance estimates of expected returns, replacing high-variance Monte Carlo estimates in policy gradient computations.

### Advantage Actor-Critic (A2C)

A2C uses the critic to estimate state values, computing advantages as the difference between observed rewards and value estimates. The advantage function reduces gradient variance while maintaining unbiased gradient estimation.

```python
class A2C(nn.Module):
    def __init__(self, state_dim, action_dim, hidden_dim):
        super().__init__()
        self.shared_layers = nn.Sequential(
            nn.Linear(state_dim, hidden_dim),
            nn.ReLU(),
            nn.Linear(hidden_dim, hidden_dim),
            nn.ReLU()
        )
        self.actor_head = nn.Linear(hidden_dim, action_dim)
        self.critic_head = nn.Linear(hidden_dim, 1)
    
    def forward(self, state):
        features = self.shared_layers(state)
        action_logits = self.actor_head(features)
        state_value = self.critic_head(features)
        return action_logits, state_value
```

### Asynchronous Advantage Actor-Critic (A3C)

A3C parallelizes training across multiple environment instances, with each worker independently collecting experience and updating shared network parameters asynchronously. This approach improves sample efficiency and training stability through experience diversity.

**Asynchronous Updates** enable continuous learning without waiting for batch completion, while diverse parallel experiences reduce correlation between consecutive updates. The asynchronous paradigm eliminates the need for experience replay buffers.

### Twin Delayed Deep Deterministic Policy Gradient (TD3)

TD3 addresses overestimation bias in continuous control by using twin critic networks and delayed policy updates. The algorithm takes the minimum value estimate from twin critics and updates the policy less frequently than the critics.

**Target Policy Smoothing** adds noise to target actions during critic training, improving robustness to policy estimation errors and reducing overestimation bias in value function approximation.

### Soft Actor-Critic (SAC)

SAC incorporates entropy regularization directly into the objective function, encouraging exploration while maximizing expected returns. The entropy-regularized objective promotes policy stochasticity and improves sample efficiency in continuous control tasks.

```python
def sac_policy_loss(log_probs, q_values, alpha):
    return (alpha * log_probs - q_values).mean()

def sac_critic_loss(q_pred, target_q):
    return F.mse_loss(q_pred, target_q.detach())
```

**Automatic Entropy Tuning** adapts the entropy coefficient during training to maintain desired exploration levels throughout the learning process.

**Key Points:**
- Actor-critic architectures balance bias and variance through value function bootstrapping
- Shared representations between actor and critic can improve sample efficiency
- Modern variants address specific challenges like overestimation bias and exploration in continuous spaces

