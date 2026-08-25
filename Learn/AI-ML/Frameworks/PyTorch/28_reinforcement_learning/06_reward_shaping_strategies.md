## Reward Shaping Strategies


Reward shaping modifies the reward function to improve learning efficiency, convergence speed, and final performance while ideally preserving the optimal policy. Effective reward shaping requires careful design to avoid unintended consequences and policy distortion.

The fundamental challenge involves providing informative guidance without introducing reward hacking or suboptimal behavior. Potential-based reward shaping provides theoretical guarantees for preserving optimal policies under specific conditions.

### Potential-Based Reward Shaping

Potential-based reward shaping adds terms F(s,a,s') = γΦ(s') - Φ(s) to the original reward function, where Φ(s) represents a potential function over states. This formulation preserves optimal policies while providing additional learning signal.

```python
def potential_based_reward(original_reward, state, next_state, potential_func, gamma=0.99):
    potential_diff = gamma * potential_func(next_state) - potential_func(state)
    return original_reward + potential_diff

## Example: Distance-based potential for navigation tasks
def distance_potential(state, goal_position):
    agent_position = state[:2]  ## Assuming first 2 dimensions are position
    distance_to_goal = np.linalg.norm(goal_position - agent_position)
    return -distance_to_goal  ## Negative distance as potential
```

**Theoretical Guarantees** ensure that potential-based shaping preserves the optimal policy ordering, though the specific optimal actions may change. The approach provides additional learning signal without fundamentally altering the task structure.

### Curiosity-Driven Exploration

**Intrinsic Curiosity Module (ICM)** generates intrinsic rewards based on prediction errors in a learned forward model. The approach encourages exploration of states where the agent's world model performs poorly, promoting discovery of novel experiences.

**Random Network Distillation (RND)** uses prediction errors on randomly initialized networks as intrinsic rewards, encouraging visitation of states that differ from the training distribution. This approach provides exploration bonuses without requiring environment-specific design.

```python
class CuriosityModule(nn.Module):
    def __init__(self, state_dim, action_dim, feature_dim):
        super().__init__()
        self.feature_net = nn.Sequential(
            nn.Linear(state_dim, feature_dim),
            nn.ReLU(),
            nn.Linear(feature_dim, feature_dim)
        )
        self.forward_model = nn.Linear(feature_dim + action_dim, feature_dim)
        self.inverse_model = nn.Linear(feature_dim * 2, action_dim)
    
    def forward(self, state, action, next_state):
        phi_state = self.feature_net(state)
        phi_next = self.feature_net(next_state)
        
        ## Forward model prediction
        pred_next_features = self.forward_model(torch.cat([phi_state, action], dim=-1))
        forward_loss = F.mse_loss(pred_next_features, phi_next.detach())
        
        ## Inverse model prediction
        pred_action = self.inverse_model(torch.cat([phi_state, phi_next], dim=-1))
        inverse_loss = F.cross_entropy(pred_action, action)
        
        ## Intrinsic reward based on prediction error
        intrinsic_reward = forward_loss.detach()
        
        return intrinsic_reward, forward_loss, inverse_loss
```

### Hierarchical Reward Structures

**Hierarchical Reinforcement Learning** decomposes complex tasks into subtask hierarchies, with each level receiving appropriate reward signals. Higher-level policies set goals for lower-level policies, creating natural reward shaping through task decomposition.

**Goal-Conditioned Reinforcement Learning** trains agents to reach arbitrary goals within the environment, using goal achievement as reward signals. Hindsight Experience Replay (HER) improves sample efficiency by treating failed attempts as successful goal achievements for different goals.

### Curriculum Learning

**Progressive Task Difficulty** gradually increases task complexity during training, starting with simplified versions and advancing to full complexity. This approach improves learning efficiency and reduces training instability in complex environments.

**Automatic Curriculum Generation** adaptively adjusts task difficulty based on agent performance, maintaining appropriate challenge levels throughout training. The approach balances task difficulty to optimize learning progress.

### Reward Design Principles

**Sparse vs. Dense Rewards** trade-off between natural task specification and learning efficiency. Sparse rewards better reflect true task objectives but may require sophisticated exploration, while dense rewards provide more learning signal but risk reward hacking.

**Avoiding Reward Hacking** requires careful consideration of unintended behaviors that maximize reward without achieving task objectives. Common issues include specification gaming, edge case exploitation, and distributional shift problems.

**Key Points:**
- Potential-based shaping provides theoretical guarantees for preserving optimal policies
- Curiosity-driven approaches automatically generate exploration rewards
- Curriculum learning can significantly improve training efficiency in complex domains

[Unverified] The long-term effects of reward shaping on policy robustness and generalization across different environment configurations remain areas of ongoing research, with limited comprehensive studies across diverse domains.

---

