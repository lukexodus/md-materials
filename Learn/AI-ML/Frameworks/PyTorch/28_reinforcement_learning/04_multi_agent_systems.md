## Multi-Agent Systems


Multi-agent reinforcement learning addresses scenarios where multiple learning agents interact simultaneously, creating non-stationary environments from each agent's perspective. The presence of other learning agents fundamentally changes the learning dynamics and requires specialized algorithms and analysis frameworks.

The multi-agent setting introduces additional complexity through agent interaction, coordination requirements, and non-stationary learning environments. Each agent's optimal policy depends on other agents' policies, creating interdependent learning dynamics that challenge single-agent algorithms.

### Independent Learning

Independent learning approaches train agents separately using single-agent algorithms while treating other agents as part of the environment. This approach is simple to implement but provides no theoretical guarantees due to environment non-stationarity from other learning agents.

**Challenges with Independent Learning:**
- Non-stationary environment violates single-agent learning assumptions
- Agents may converge to suboptimal equilibria due to lack of coordination
- Training instability can arise from simultaneous adaptation of multiple agents

### Multi-Agent Policy Gradient

Multi-agent policy gradients extend single-agent policy gradient methods to multi-agent settings, accounting for the joint policy space and coordination requirements. These methods can incorporate communication, centralized training, or game-theoretic solution concepts.

**Multi-Agent Actor-Critic (MAAC)** uses centralized critics during training while maintaining decentralized actors for execution. The centralized critic has access to global information including other agents' actions and observations, enabling more stable training.

```python
def maac_loss(agents, states, actions, rewards, next_states, dones):
    policy_losses = []
    value_losses = []
    
    for i, agent in enumerate(agents):
        ## Centralized critic sees global state and all actions
        global_state = torch.cat(states, dim=-1)
        global_actions = torch.cat(actions, dim=-1)
        
        ## Actor loss using centralized critic
        q_value = agent.critic(global_state, global_actions)
        policy_loss = -q_value.mean()
        
        ## Critic loss
        target_q = compute_target_q(agents, states, actions, rewards, next_states, dones)
        value_loss = F.mse_loss(q_value, target_q.detach())
        
        policy_losses.append(policy_loss)
        value_losses.append(value_loss)
    
    return policy_losses, value_losses
```

### Cooperative Multi-Agent Learning

Cooperative settings require agents to coordinate toward shared objectives, often involving communication, role assignment, or joint action selection. These scenarios benefit from centralized training with decentralized execution paradigms.

**Multi-Agent Deep Deterministic Policy Gradient (MADDPG)** adapts DDPG to multi-agent settings using centralized critics and decentralized actors. The approach enables handling of continuous action spaces while maintaining sample efficiency through centralized value function approximation.

### Competitive and Mixed-Motive Settings

Competitive environments require game-theoretic analysis and specialized algorithms that account for adversarial behavior. Nash equilibrium concepts provide solution frameworks, though computing and learning equilibria remains challenging.

**Self-Play** training creates competitive scenarios by training agents against copies of themselves, enabling skill development through adversarial interaction. This approach has achieved success in games like Go, poker, and real-time strategy games.

**Population-Based Training** maintains diverse agent populations to avoid overfitting to specific opponent strategies and encourage robust policy development across varied competitive scenarios.

**Key Points:**
- Multi-agent learning faces fundamental challenges from non-stationary environments
- Centralized training with decentralized execution provides a practical compromise
- Game-theoretic analysis becomes essential for competitive and mixed-motive scenarios

[Inference] The scalability of multi-agent algorithms to large numbers of agents remains an active research challenge, with most successful applications limited to small numbers of interacting agents.

