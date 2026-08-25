## Differential Privacy


Differential privacy provides mathematical guarantees for privacy preservation by adding calibrated noise to computations, essential for sensitive data applications.

**Differentially Private SGD (DP-SGD)**

DP-SGD clips gradients and adds noise to provide privacy guarantees during training:

```python
from opacus import PrivacyEngine
import torch.nn.utils as utils

class DifferentiallyPrivateTrainer:
    def __init__(self, model, data_loader, target_epsilon=1.0, target_delta=1e-5):
        self.model = model
        self.data_loader = data_loader
        self.target_epsilon = target_epsilon
        self.target_delta = target_delta
        self.privacy_engine = PrivacyEngine()
        
    def setup_private_training(self, max_grad_norm=1.0, noise_multiplier=1.1):
        """Initialize differential privacy components"""
        optimizer = torch.optim.SGD(self.model.parameters(), lr=0.05)
        
        # Attach privacy engine
        self.model, optimizer, self.data_loader = self.privacy_engine.make_private_with_epsilon(
            module=self.model,
            optimizer=optimizer,
            data_loader=self.data_loader,
            target_epsilon=self.target_epsilon,
            target_delta=self.target_delta,
            epochs=10,
            max_grad_norm=max_grad_norm,
        )
        
        return optimizer
    
    def private_training_step(self, data, target, optimizer, criterion):
        """Execute one private training step with gradient clipping and noise"""
        optimizer.zero_grad()
        
        # Forward pass
        output = self.model(data)
        loss = criterion(output, target)
        
        # Backward pass with privacy
        loss.backward()
        
        # Gradient clipping is handled automatically by Opacus
        optimizer.step()
        
        return loss.item()
    
    def get_privacy_spent(self):
        """Get current privacy budget expenditure"""
        return self.privacy_engine.get_epsilon(self.target_delta)

class CustomDPOptimizer:
    """Custom implementation showing DP-SGD mechanics"""
    def __init__(self, model, noise_multiplier=1.0, max_grad_norm=1.0):
        self.model = model
        self.noise_multiplier = noise_multiplier
        self.max_grad_norm = max_grad_norm
        self.base_optimizer = torch.optim.SGD(model.parameters(), lr=0.01)
        
    def step(self):
        """[Inference] - Manual implementation of DP-SGD step"""
        # Clip gradients per sample (simplified - requires per-sample gradients)
        total_norm = 0
        for param in self.model.parameters():
            if param.grad is not None:
                param_norm = param.grad.data.norm(2)
                total_norm += param_norm ** 2
        total_norm = total_norm ** 0.5
        
        # Clip gradients
        clip_coeff = min(1, self.max_grad_norm / (total_norm + 1e-6))
        for param in self.model.parameters():
            if param.grad is not None:
                param.grad.data.mul_(clip_coeff)
        
        # Add calibrated noise
        for param in self.model.parameters():
            if param.grad is not None:
                noise = torch.normal(
                    0, self.noise_multiplier * self.max_grad_norm, 
                    size=param.grad.shape
                ).to(param.device)
                param.grad.data.add_(noise)
        
        # Standard optimizer step
        self.base_optimizer.step()
```

**Private Aggregation in Federated Learning**

Combining differential privacy with federated learning provides enhanced privacy protection:

```python
class DPFederatedServer:
    def __init__(self, model, epsilon_per_round=0.1, delta=1e-5):
        self.global_model = model
        self.epsilon_per_round = epsilon_per_round
        self.delta = delta
        self.total_epsilon = 0.0
        
    def private_federated_averaging(self, client_updates, sensitivity=1.0):
        """[Inference] - Perform differentially private federated averaging"""
        total_samples = sum(num_samples for _, num_samples in client_updates)
        
        # Standard weighted averaging
        aggregated_updates = {}
        for key in self.global_model.state_dict():
            aggregated_updates[key] = torch.zeros_like(
                self.global_model.state_dict()[key]
            )
        
        for updates, num_samples in client_updates:
            weight = num_samples / total_samples
            for key in aggregated_updates:
                aggregated_updates[key] += weight * updates[key]
        
        # Add calibrated noise for differential privacy
        noise_scale = sensitivity / (self.epsilon_per_round * len(client_updates))
        
        for key in aggregated_updates:
            noise = torch.normal(
                0, noise_scale, size=aggregated_updates[key].shape
            ).to(aggregated_updates[key].device)
            aggregated_updates[key] += noise
        
        # Update global model
        global_weights = self.global_model.state_dict()
        for key in global_weights:
            global_weights[key] += aggregated_updates[key]
        
        self.global_model.load_state_dict(global_weights)
        self.total_epsilon += self.epsilon_per_round
        
        return self.global_model.state_dict()
    
    def get_privacy_budget_remaining(self, total_budget=1.0):
        """Calculate remaining privacy budget"""
        return max(0, total_budget - self.total_epsilon)
```

**Local Differential Privacy**

Local DP adds noise at the client level before any data sharing:

```python
class LocalDPMechanism:
    def __init__(self, epsilon=1.0):
        self.epsilon = epsilon
        
    def randomized_response(self, true_value, domain_size=2):
        """[Inference] - Binary randomized response for categorical data"""
        if domain_size == 2:  # Binary case
            p = torch.exp(self.epsilon) / (torch.exp(self.epsilon) + 1)
            if torch.rand(1) < p:
                return true_value
            else:
                return 1 - true_value
        else:
            # Generalized randomized response
            p_true = torch.exp(self.epsilon) / (torch.exp(self.epsilon) + domain_size - 1)
            p_other = 1 / (torch.exp(self.epsilon) + domain_size - 1)
            
            if torch.rand(1) < p_true:
                return true_value
            else:
                return torch.randint(0, domain_size, (1,)).item()
    
    def laplace_mechanism(self, true_value, sensitivity=1.0):
        """[Inference] - Laplace mechanism for numerical data"""
        scale = sensitivity / self.epsilon
        noise = torch.distributions.Laplace(0, scale).sample(true_value.shape)
        return true_value + noise
    
    def exponential_mechanism(self, candidates, quality_function, sensitivity=1.0):
        """[Inference] - Exponential mechanism for selecting from candidates"""
        qualities = torch.tensor([quality_function(c) for c in candidates])
        probabilities = torch.exp(self.epsilon * qualities / (2 * sensitivity))
        probabilities = probabilities / probabilities.sum()
        
        selected_idx = torch.multinomial(probabilities, 1).item()
        return candidates[selected_idx]
```

