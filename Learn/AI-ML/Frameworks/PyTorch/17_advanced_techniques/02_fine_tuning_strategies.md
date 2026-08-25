## Fine-Tuning Strategies


Fine-tuning involves adapting pre-trained models to new tasks through careful parameter updates, learning rate management, and architectural modifications. Effective fine-tuning balances knowledge retention with task-specific adaptation.

**Key Points:**

- Fine-tuning requires different learning rates for different model components
- [Inference] Catastrophic forgetting can occur if learning rates are too high for pre-trained layers
- Layer-wise learning rate decay often improves fine-tuning performance
- Task similarity influences optimal fine-tuning strategies

**Discriminative Learning Rates:**

```python
class DiscriminativeLearningRateOptimizer:
    def __init__(self, model, base_lr=1e-3, lr_decay_factor=0.5):
        self.model = model
        self.base_lr = base_lr
        self.lr_decay_factor = lr_decay_factor
        self.param_groups = self._create_param_groups()
        
    def _create_param_groups(self):
        param_groups = []
        layer_names = [name for name, _ in self.model.named_parameters()]
        
        # Group parameters by layer depth
        backbone_params = []
        classifier_params = []
        
        for name, param in self.model.named_parameters():
            if 'backbone' in name:
                # Apply decay based on layer depth
                layer_depth = self._get_layer_depth(name)
                lr = self.base_lr * (self.lr_decay_factor ** layer_depth)
                param_groups.append({
                    'params': [param],
                    'lr': lr,
                    'name': name
                })
            else:
                classifier_params.append(param)
                
        # Higher learning rate for classifier
        if classifier_params:
            param_groups.append({
                'params': classifier_params,
                'lr': self.base_lr,
                'name': 'classifier'
            })
            
        return param_groups
        
    def _get_layer_depth(self, layer_name):
        # [Inference] Earlier layers should have lower learning rates
        if 'layer1' in layer_name:
            return 3
        elif 'layer2' in layer_name:
            return 2
        elif 'layer3' in layer_name:
            return 1
        else:
            return 0

# Create optimizer with discriminative learning rates
optimizer = torch.optim.Adam(discriminative_optimizer.param_groups)
```

**Gradual Unfreezing with Warm Restarts:**

```python
class GradualUnfreezingScheduler:
    def __init__(self, model, total_epochs, warmup_epochs=5):
        self.model = model
        self.total_epochs = total_epochs
        self.warmup_epochs = warmup_epochs
        self.frozen_layers = list(model.backbone.children())
        
    def step(self, epoch, optimizer):
        # Gradual unfreezing schedule
        if epoch >= self.warmup_epochs:
            unfreeze_point = (epoch - self.warmup_epochs) / (self.total_epochs - self.warmup_epochs)
            layers_to_unfreeze = int(len(self.frozen_layers) * unfreeze_point)
            
            # Unfreeze layers progressively
            for i, layer in enumerate(self.frozen_layers[-layers_to_unfreeze:]):
                for param in layer.parameters():
                    param.requires_grad = True
                    
        # Warm restart for learning rate
        if epoch % (self.total_epochs // 3) == 0 and epoch > 0:
            for param_group in optimizer.param_groups:
                param_group['lr'] *= 0.1
```

**Task-Specific Layer Addition:**

```python
class AdaptiveFineTuningModel(nn.Module):
    def __init__(self, pretrained_model, target_task_config):
        super().__init__()
        self.backbone = pretrained_model
        
        # Freeze backbone initially
        for param in self.backbone.parameters():
            param.requires_grad = False
            
        # Add task-specific adaptation layers
        backbone_output_dim = self._get_backbone_output_dim()
        
        self.task_adapter = nn.Sequential(
            nn.Linear(backbone_output_dim, target_task_config['adapter_dim']),
            nn.LayerNorm(target_task_config['adapter_dim']),
            nn.GELU(),
            nn.Dropout(target_task_config['dropout_rate'])
        )
        
        self.task_head = nn.Linear(
            target_task_config['adapter_dim'], 
            target_task_config['num_classes']
        )
        
    def forward(self, x):
        with torch.set_grad_enabled(self.backbone.training):
            backbone_features = self.backbone(x)
        
        adapted_features = self.task_adapter(backbone_features)
        output = self.task_head(adapted_features)
        return output
        
    def _get_backbone_output_dim(self):
        # [Inference] Determine output dimension from backbone architecture
        dummy_input = torch.randn(1, 3, 224, 224)
        with torch.no_grad():
            output = self.backbone(dummy_input)
        return output.shape[-1]
```

