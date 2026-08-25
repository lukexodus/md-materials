## Knowledge Distillation


Knowledge distillation transfers knowledge from large teacher models to smaller student models, enabling deployment of efficient models while maintaining performance. The process involves training students to match both hard targets and soft distributions from teachers.

**Key Points:**

- Knowledge distillation enables model compression while preserving performance
- Temperature scaling in softmax affects the smoothness of probability distributions
- [Inference] Soft targets provide richer information than hard labels
- Multiple teacher models can provide diverse knowledge sources

**Basic Knowledge Distillation:**

```python
class KnowledgeDistillationLoss(nn.Module):
    def __init__(self, temperature=4.0, alpha=0.7):
        super().__init__()
        self.temperature = temperature
        self.alpha = alpha
        self.kl_div = nn.KLDivLoss(reduction='batchmean')
        self.ce_loss = nn.CrossEntropyLoss()
        
    def forward(self, student_logits, teacher_logits, true_labels):
        # Soft target loss (knowledge distillation)
        student_soft = F.log_softmax(student_logits / self.temperature, dim=1)
        teacher_soft = F.softmax(teacher_logits / self.temperature, dim=1)
        distillation_loss = self.kl_div(student_soft, teacher_soft) * (self.temperature ** 2)
        
        # Hard target loss (standard classification)
        classification_loss = self.ce_loss(student_logits, true_labels)
        
        # Combined loss
        total_loss = (self.alpha * distillation_loss + 
                     (1 - self.alpha) * classification_loss)
        
        return total_loss, distillation_loss, classification_loss

class DistillationTrainer:
    def __init__(self, teacher_model, student_model, distillation_loss, optimizer):
        self.teacher_model = teacher_model
        self.student_model = student_model
        self.distillation_loss = distillation_loss
        self.optimizer = optimizer
        
        # Set teacher to evaluation mode
        self.teacher_model.eval()
        for param in self.teacher_model.parameters():
            param.requires_grad = False
            
    def train_step(self, data, targets):
        self.student_model.train()
        
        # Get teacher predictions
        with torch.no_grad():
            teacher_logits = self.teacher_model(data)
            
        # Get student predictions
        student_logits = self.student_model(data)
        
        # Compute distillation loss
        total_loss, dist_loss, class_loss = self.distillation_loss(
            student_logits, teacher_logits, targets
        )
        
        # Backward pass
        self.optimizer.zero_grad()
        total_loss.backward()
        self.optimizer.step()
        
        return {
            'total_loss': total_loss.item(),
            'distillation_loss': dist_loss.item(),
            'classification_loss': class_loss.item()
        }
```

**Feature-Based Knowledge Distillation:**

```python
class FeatureDistillationModel(nn.Module):
    def __init__(self, teacher_model, student_model, feature_layers):
        super().__init__()
        self.teacher_model = teacher_model
        self.student_model = student_model
        self.feature_layers = feature_layers
        
        # Feature adaptation layers to match dimensions
        self.feature_adapters = nn.ModuleDict()
        for layer_name in feature_layers:
            teacher_dim = self._get_feature_dim(teacher_model, layer_name)
            student_dim = self._get_feature_dim(student_model, layer_name)
            
            if teacher_dim != student_dim:
                self.feature_adapters[layer_name] = nn.Conv2d(
                    student_dim, teacher_dim, kernel_size=1
                )
                
    def forward(self, x, return_features=False):
        # Extract intermediate features
        teacher_features = self._extract_features(self.teacher_model, x)
        student_features = self._extract_features(self.student_model, x)
        
        # Adapt student features if necessary
        adapted_student_features = {}
        for layer_name, features in student_features.items():
            if layer_name in self.feature_adapters:
                adapted_features = self.feature_adapters[layer_name](features)
            else:
                adapted_features = features
            adapted_student_features[layer_name] = adapted_features
            
        if return_features:
            return adapted_student_features, teacher_features
        
        return self.student_model(x)
        
    def _extract_features(self, model, x):
        features = {}
        def hook_fn(name):
            def hook(module, input, output):
                features[name] = output
            return hook
            
        hooks = []
        for name, module in model.named_modules():
            if name in self.feature_layers:
                hook = module.register_forward_hook(hook_fn(name))
                hooks.append(hook)
                
        _ = model(x)
        
        # Remove hooks
        for hook in hooks:
            hook.remove()
            
        return features
```

**Multi-Teacher Distillation:**

```python
class MultiTeacherDistillation(nn.Module):
    def __init__(self, teacher_models, student_model, teacher_weights=None):
        super().__init__()
        self.teacher_models = nn.ModuleList(teacher_models)
        self.student_model = student_model
        
        # Set teacher weights
        if teacher_weights is None:
            self.teacher_weights = torch.ones(len(teacher_models)) / len(teacher_models)
        else:
            self.teacher_weights = torch.tensor(teacher_weights)
            
        # Freeze teacher models
        for teacher in self.teacher_models:
            teacher.eval()
            for param in teacher.parameters():
                param.requires_grad = False
                
    def forward(self, x):
        # Get predictions from all teachers
        teacher_logits = []
        with torch.no_grad():
            for teacher in self.teacher_models:
                logits = teacher(x)
                teacher_logits.append(logits)
                
        # Weighted ensemble of teacher predictions
        ensemble_logits = torch.zeros_like(teacher_logits[0])
        for i, logits in enumerate(teacher_logits):
            ensemble_logits += self.teacher_weights[i] * logits
            
        # Student prediction
        student_logits = self.student_model(x)
        
        return student_logits, ensemble_logits
```

