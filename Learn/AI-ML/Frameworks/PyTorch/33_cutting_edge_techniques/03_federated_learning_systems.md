## Federated Learning Systems


Federated learning enables distributed model training across multiple participants while preserving data privacy, with PyTorch providing frameworks for decentralized optimization.

**Federated Averaging (FedAvg)**

The foundational federated learning algorithm aggregates local model updates:

```python
class FederatedClient:
    def __init__(self, client_id, model, data_loader, device):
        self.client_id = client_id
        self.model = model.to(device)
        self.data_loader = data_loader
        self.device = device
        self.optimizer = torch.optim.SGD(self.model.parameters(), lr=0.01)
        
    def local_update(self, global_weights, num_epochs=5):
        """Perform local training and return weight updates"""
        # Load global weights
        self.model.load_state_dict(global_weights)
        self.model.train()
        
        initial_weights = copy.deepcopy(self.model.state_dict())
        
        for epoch in range(num_epochs):
            for batch_idx, (data, target) in enumerate(self.data_loader):
                data, target = data.to(self.device), target.to(self.device)
                
                self.optimizer.zero_grad()
                output = self.model(data)
                loss = F.cross_entropy(output, target)
                loss.backward()
                self.optimizer.step()
        
        # Calculate weight updates
        final_weights = self.model.state_dict()
        weight_updates = {}
        for key in final_weights:
            weight_updates[key] = final_weights[key] - initial_weights[key]
        
        return weight_updates, len(self.data_loader.dataset)

class FederatedServer:
    def __init__(self, model, clients):
        self.global_model = model
        self.clients = clients
        
    def federated_averaging(self, client_updates):
        """Aggregate client updates using weighted averaging"""
        total_samples = sum(num_samples for _, num_samples in client_updates)
        
        # Initialize aggregated updates
        aggregated_updates = {}
        for key in self.global_model.state_dict():
            aggregated_updates[key] = torch.zeros_like(
                self.global_model.state_dict()[key]
            )
        
        # Weighted aggregation
        for updates, num_samples in client_updates:
            weight = num_samples / total_samples
            for key in aggregated_updates:
                aggregated_updates[key] += weight * updates[key]
        
        # Update global model
        global_weights = self.global_model.state_dict()
        for key in global_weights:
            global_weights[key] += aggregated_updates[key]
        
        self.global_model.load_state_dict(global_weights)
        
    def train_round(self, selected_clients, num_epochs=5):
        """Execute one round of federated training"""
        client_updates = []
        
        for client in selected_clients:
            updates, num_samples = client.local_update(
                self.global_model.state_dict(), num_epochs
            )
            client_updates.append((updates, num_samples))
        
        self.federated_averaging(client_updates)
        return self.global_model.state_dict()
```

**Personalized Federated Learning**

Personalization addresses heterogeneity in federated settings through adaptive approaches:

```python
class PersonalizedFedClient:
    def __init__(self, client_id, global_model, local_data):
        self.client_id = client_id
        self.global_model = copy.deepcopy(global_model)
        self.personal_model = copy.deepcopy(global_model)
        self.local_data = local_data
        self.personalization_strength = 0.1
        
    def personalized_update(self, global_weights):
        """Update personal model balancing global and local knowledge"""
        # Load new global weights
        self.global_model.load_state_dict(global_weights)
        
        # Personalization via regularized local training
        optimizer = torch.optim.SGD(self.personal_model.parameters(), lr=0.01)
        
        for epoch in range(10):
            for data, target in self.local_data:
                optimizer.zero_grad()
                
                # Personal model prediction
                personal_output = self.personal_model(data)
                personal_loss = F.cross_entropy(personal_output, target)
                
                # Regularization toward global model
                reg_loss = 0
                for (name1, param1), (name2, param2) in zip(
                    self.personal_model.named_parameters(),
                    self.global_model.named_parameters()
                ):
                    reg_loss += torch.norm(param1 - param2) ** 2
                
                total_loss = personal_loss + self.personalization_strength * reg_loss
                total_loss.backward()
                optimizer.step()
    
    def meta_learning_personalization(self, global_weights, support_set, query_set):
        """[Inference] - MAML-style personalization for few-shot adaptation"""
        # Initialize with global weights
        self.personal_model.load_state_dict(global_weights)
        
        # Inner loop: adapt to local data
        inner_optimizer = torch.optim.SGD(self.personal_model.parameters(), lr=0.1)
        
        for data, target in support_set:
            inner_optimizer.zero_grad()
            output = self.personal_model(data)
            loss = F.cross_entropy(output, target)
            loss.backward()
            inner_optimizer.step()
        
        # Evaluate on query set
        query_loss = 0
        for data, target in query_set:
            output = self.personal_model(data)
            query_loss += F.cross_entropy(output, target)
        
        return query_loss / len(query_set)
```

**Secure Aggregation**

Cryptographic protocols protect individual client updates during aggregation:

```python
class SecureAggregator:
    def __init__(self, num_clients, threshold=None):
        self.num_clients = num_clients
        self.threshold = threshold or num_clients // 2 + 1
        self.secret_shares = {}
        
    def generate_secret_shares(self, secret_value, client_id):
        """[Inference] - Generate Shamir secret shares for secure aggregation"""
        # Simplified secret sharing implementation
        # In practice, use cryptographically secure libraries
        
        from random import randint
        
        # Convert tensor to integer representation
        quantized_secret = (secret_value * 1000000).int()
        
        # Generate polynomial coefficients
        coefficients = [quantized_secret] + [randint(0, 2**32) for _ in range(self.threshold-1)]
        
        # Generate shares
        shares = []
        for i in range(1, self.num_clients + 1):
            share_value = sum(coeff * (i ** power) for power, coeff in enumerate(coefficients))
            shares.append((i, share_value))
        
        return shares
    
    def reconstruct_secret(self, shares):
        """[Inference] - Lagrange interpolation for secret reconstruction"""
        if len(shares) < self.threshold:
            raise ValueError("Insufficient shares for reconstruction")
        
        # Lagrange interpolation at x=0
        secret = 0
        for i, (xi, yi) in enumerate(shares[:self.threshold]):
            numerator = 1
            denominator = 1
            for j, (xj, _) in enumerate(shares[:self.threshold]):
                if i != j:
                    numerator *= (0 - xj)
                    denominator *= (xi - xj)
            
            secret += yi * (numerator // denominator)
        
        return torch.tensor(secret / 1000000.0)  # Dequantize
    
    def secure_federated_averaging(self, client_updates):
        """[Inference] - Perform secure aggregation using secret sharing"""
        aggregated_weights = {}
        
        for param_name in client_updates[0][0].keys():
            # Collect all client values for this parameter
            client_values = [updates[param_name] for updates, _ in client_updates]
            
            # Generate and distribute secret shares
            all_shares = []
            for client_idx, value in enumerate(client_values):
                shares = self.generate_secret_shares(value.mean(), client_idx)  # Simplified
                all_shares.extend(shares)
            
            # Simulate secure aggregation (clients would compute this collaboratively)
            aggregated_value = self.reconstruct_secret(all_shares[:self.threshold])
            aggregated_weights[param_name] = aggregated_value * torch.ones_like(client_values[0])
        
        return aggregated_weights
```

