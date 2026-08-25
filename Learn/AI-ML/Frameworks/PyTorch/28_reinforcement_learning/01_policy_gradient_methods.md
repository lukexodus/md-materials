## Policy Gradient Methods


Policy gradient methods directly optimize parameterized policies by computing gradients of expected cumulative rewards with respect to policy parameters. These approaches avoid the need for explicit value function approximation and can handle continuous action spaces naturally.

The fundamental policy gradient theorem establishes that the gradient of expected returns can be expressed as an expectation over trajectories, enabling Monte Carlo estimation from sampled episodes. The gradient estimator takes the form of weighted log-likelihood gradients, where weights correspond to trajectory returns or advantages.

### REINFORCE Algorithm

REINFORCE represents the basic policy gradient algorithm using Monte Carlo sampling to estimate gradients. The algorithm updates policy parameters in the direction that increases the probability of actions leading to higher returns.

```python
def reinforce_update(policy, trajectories, baseline=None):
    policy_loss = 0
    for trajectory in trajectories:
        returns = compute_returns(trajectory.rewards)
        for t, (state, action, reward) in enumerate(trajectory):
            advantage = returns[t] - (baseline(state) if baseline else 0)
            log_prob = policy.log_prob(action, state)
            policy_loss -= log_prob * advantage
    
    policy_loss.backward()
    policy_optimizer.step()
```

**Variance Reduction Techniques** address the high variance inherent in Monte Carlo gradient estimation:
- **Baseline Subtraction** reduces variance without introducing bias by subtracting state-dependent baseline functions from returns
- **Temporal Difference Bootstrapping** reduces variance by using value function estimates instead of full Monte Carlo returns
- **Control Variates** employ correlated random variables with known expectations to reduce estimation variance

### Natural Policy Gradients

Natural policy gradients account for the geometry of the policy parameter space using the Fisher Information Matrix as a Riemannian metric. This approach provides more stable updates by considering how parameter changes affect the policy distribution.

The natural gradient direction maximizes improvement per unit of distributional change, measured by KL divergence. Trust Region Policy Optimization (TRPO) approximates natural gradients while enforcing explicit trust region constraints.

### Proximal Policy Optimization (PPO)

PPO simplifies TRPO by using a clipped surrogate objective that penalizes large policy updates without requiring expensive second-order computations. The clipped objective prevents destructive policy updates while maintaining computational efficiency.

```python
def ppo_loss(old_log_probs, new_log_probs, advantages, epsilon=0.2):
    ratio = torch.exp(new_log_probs - old_log_probs)
    clipped_ratio = torch.clamp(ratio, 1 - epsilon, 1 + epsilon)
    surrogate_loss = torch.min(ratio * advantages, clipped_ratio * advantages)
    return -surrogate_loss.mean()
```

**Key Points:**
- Policy gradient methods excel in continuous control tasks and stochastic environments
- Variance reduction techniques are crucial for sample efficiency and training stability
- Modern implementations combine multiple variance reduction approaches for optimal performance

