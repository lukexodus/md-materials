## Adversarial Robustness


Adversarial robustness techniques defend against malicious inputs designed to fool neural networks, employing both defensive training strategies and detection mechanisms.

**Adversarial Training**

Training with adversarial examples improves model robustness to perturbations:

```python
class AdversarialTrainer:
    def __init__(self, model, epsilon=0.3, alpha=0.01, num_iter=7):
        self.model = model
        self.epsilon = epsilon  # Maximum perturbation magnitude
        self.alpha = alpha      # Step size for attack
        self.num_iter = num_iter # Number of attack iterations
        
    def pgd_attack(self, data, target, criterion):
        """Project Gradient Descent attack for generating adversarial examples"""
        # Initialize perturbation
        delta = torch.zeros_like(data, requires_grad=True)
        
        for _ in range(self.num_iter):
            # Forward pass
            output = self.model(data + delta)
            loss = criterion(output, target)
            
            # Backward pass
            loss.backward()
            
            # Update perturbation
            grad_sign = delta.grad.data.sign()
            delta.data = delta.data + self.alpha * grad_sign
            
            # Project to epsilon ball
            delta.data = torch.clamp(delta.data, -self.epsilon, self.epsilon)
            delta.data = torch.clamp(data + delta.data, 0, 1) - data
            
            # Zero gradients
            delta.grad.data.zero_()
        
        return data + delta.detach()
    
    def trades_loss(self, data, target, criterion, beta=1.0):
        """TRadeoff-inspired Adversarial DEfense via Surrogate-loss minimization"""
        batch_size = len(data)
        
        # Generate adversarial examples
        adv_data = self.pgd_attack(data, target, criterion)
        
        # Clean predictions
        clean_logits = self.model(data)
        clean_loss = criterion(clean_logits, target)
        
        # Adversarial predictions
        adv_logits = self.model(adv_data)
        
        # KL divergence between clean and adversarial predictions
        kl_div = F.kl_div(
            F.log_softmax(adv_logits, dim=1),
            F.softmax(clean_logits, dim=1),
            reduction='batchmean'
        )
        
        # Combined loss
        total_loss = clean_loss + beta * kl_div
        return total_loss, clean_loss, kl_div
    
    def adversarial_training_step(self, data, target, optimizer, criterion, method='pgd'):
        """Execute one adversarial training step"""
        self.model.train()
        optimizer.zero_grad()
        
        if method == 'pgd':
            adv_data = self.pgd_attack(data, target, criterion)
            output = self.model(adv_data)
            loss = criterion(output, target)
        elif method == 'trades':
            loss, clean_loss, kl_div = self.trades_loss(data, target, criterion)
        
        loss.backward()
        optimizer.step()
        
        return loss.item()

class CertifiedDefense:
    """Certified robustness through randomized smoothing"""
    def __init__(self, base_model, noise_std=0.25):
        self.base_model = base_model
        self.noise_std = noise_std
        
    def certify_prediction(self, x, num_samples=1000, alpha=0.001):
        """[Inference] - Provide certified robustness guarantees"""
        self.base_model.eval()
        
        with torch.no_grad():
            # Sample predictions with Gaussian noise
            predictions = []
            for _ in range(num_samples):
                noise = torch.randn_like(x) * self.noise_std
                noisy_input = x + noise
                logits = self.base_model(noisy_input)
                pred = torch.argmax(logits, dim=1)
                predictions.append(pred)
            
            predictions = torch.stack(predictions)
            
            # Count predictions for each class
            batch_size, num_classes = x.size(0), logits.size(1)
            counts = torch.zeros(batch_size, num_classes)
            
            for i in range(batch_size):
                unique, counts_i = torch.unique(predictions[:, i], return_counts=True)
                counts[i][unique] = counts_i.float()
            
            # Compute confidence intervals
            n = num_samples
            top_counts, top_classes = torch.topk(counts, 2, dim=1)
            
            # Clopper-Pearson confidence interval
            p_lower = self._beta_inverse_cdf(alpha/2, top_counts[:, 0], n - top_counts[:, 0] + 1)
            
            # Certified radius
            from scipy import stats
            radius = self.noise_std * stats.norm.ppf(p_lower.numpy())
            
        return top_classes[:, 0], torch.tensor(radius)
```

**Adversarial Detection and Defense**

Detection mechanisms identify adversarial inputs before they reach the model:

```python
class AdversarialDetector:
    def __init__(self, model, detection_method='mahalanobis'):
        self.model = model
        self.detection_method = detection_method
        self.feature_means = {}
        self.feature_covs = {}
        
    def extract_features(self, x, layer_name):
        """Extract intermediate layer features"""
        features = {}
        def hook_fn(module, input, output):
            features[layer_name] = output
        
        handle = dict(self.model.named_modules())[layer_name].register_forward_hook(hook_fn)
        _ = self.model(x)
        handle.remove()
        
        return features[layer_name]
    
    def fit_gaussian_distribution(self, clean_loader, layer_names):
        """[Inference] - Fit Gaussian distributions to clean data features"""
        self.model.eval()
        
        for layer_name in layer_names:
            all_features = []
            
            with torch.no_grad():
                for data, _ in clean_loader:
                    features = self.extract_features(data, layer_name)
                    features = features.view(features.size(0), -1)
                    all_features.append(features)
            
            all_features = torch.cat(all_features, dim=0)
            
            # Compute mean and covariance
            self.feature_means[layer_name] = torch.mean(all_features, dim=0)
            centered_features = all_features - self.feature_means[layer_name]
            self.feature_covs[layer_name] = torch.mm(centered_features.t(), centered_features) / (all_features.size(0) - 1)
    
    def mahalanobis_distance(self, x, layer_name):
        """[Inference] - Compute Mahalanobis distance for anomaly detection"""
        features = self.extract_features(x, layer_name)
        features = features.view(features.size(0), -1)
        
        mean = self.feature_means[layer_name]
        cov_inv = torch.inverse(self.feature_covs[layer_name] + 1e-6 * torch.eye(self.feature_covs[layer_name].size(0)))
        
        diff = features - mean
        distances = torch.sum((torch.mm(diff, cov_inv) * diff), dim=1)
        
        return distances
    
    def detect_adversarial(self, x, threshold=10.0):
        """[Inference] - Detect adversarial examples using statistical methods"""
        if self.detection_method == 'mahalanobis':
            distances = self.mahalanobis_distance(x, 'features')  # Assumes layer named 'features'
            return distances > threshold
        elif self.detection_method == 'lid':
            return self.local_intrinsic_dimensionality(x)
    
    def local_intrinsic_dimensionality(self, x, k=20):
        """[Inference] - LID-based detection method"""
        features = self.extract_features(x, 'features')
        batch_size = features.size(0)
        
        # Compute pairwise distances
        distances = torch.cdist(features, features)
        
        # Find k-nearest neighbors
        _, indices = torch.topk(distances, k+1, largest=False)
        knn_distances = torch.gather(distances, 1, indices[:, 1:])  # Exclude self
        
        # Compute LID
        lid_scores = []
        for i in range(batch_size):
            r_k = knn_distances[i, -1]  # Distance to k-th neighbor
            ratios = r_k / (knn_distances[i] + 1e-8)
            lid = -k / torch.sum(torch.log(ratios + 1e-8))
            lid_scores.append(lid)
        
        return torch.tensor(lid_scores)
```

**Robust Optimization Techniques**

Advanced optimization methods for adversarial robustness:

```python
class RobustOptimizer:
    def __init__(self, model, attack_config):
        self.model = model
        self.attack_config = attack_config
        
    def sam_optimizer(self, base_optimizer, rho=0.05):
        """Sharpness-Aware Minimization for robust optimization"""
        class SAM:
            def __init__(self, optimizer, rho):
                self.optimizer = optimizer
                self.rho = rho
                self.param_groups = optimizer.param_groups
                
            def first_step(self, zero_grad=False):
                grad_norm = self._grad_norm()
                for group in self.param_groups:
                    scale = self.rho / (grad_norm + 1e-12)
                    for p in group["params"]:
                        if p.grad is None:
                            continue
                        e_w = p.grad * scale
                        p.add_(e_w)
                        self.state[p]["e_w"] = e_w
                
                if zero_grad:
                    self.zero_grad()
            
            def second_step(self, zero_grad=False):
                for group in self.param_groups:
                    for p in group["params"]:
                        if p.grad is None:
                            continue
                        p.sub_(self.state[p]["e_w"])
                
                self.optimizer.step()
                if zero_grad:
                    self.zero_grad()
            
            def _grad_norm(self):
                shared_device = self.param_groups[0]["params"][0].device
                norm = torch.norm(
                    torch.stack([
                        p.grad.norm(dtype=torch.float32).to(shared_device)
                        for group in self.param_groups for p in group["params"]
                        if p.grad is not None
                    ]),
                    dtype=torch.float32
                )
                return norm
            
            def zero_grad(self):
                self.optimizer.zero_grad()
        
        return SAM(base_optimizer, rho)
    
    def awp_training(self, model, data, target, criterion, weight_perturbation=0.01):
        """[Inference] - Adversarial Weight Perturbation training"""
        # Standard forward pass
        output = model(data)
        clean_loss = criterion(output, target)
        
        # Compute gradients w.r.t. model parameters
        grads = torch.autograd.grad(clean_loss, model.parameters(), create_graph=True)
        
        # Perturb weights
        original_params = []
        for param, grad in zip(model.parameters(), grads):
            original_params.append(param.data.clone())
            param.data += weight_perturbation * grad / (torch.norm(grad) + 1e-8)
        
        # Forward pass with perturbed weights
        perturbed_output = model(data)
        perturbed_loss = criterion(perturbed_output, target)
        
        # Restore original weights
        for param, original in zip(model.parameters(), original_params):
            param.data = original
        
        return perturbed_loss
```

