## Transfer Learning Methodologies


Transfer learning leverages knowledge acquired from source tasks to improve performance on target tasks, particularly when target domain data is limited. The effectiveness depends on the similarity between source and target domains and the appropriateness of the transferred representations.

**Key Points:**

- Transfer learning exploits feature hierarchies learned from large-scale datasets
- Different layers capture features at varying levels of abstraction
- [Inference] Lower layers typically contain more generalizable features while higher layers are more task-specific
- Domain similarity significantly influences transfer learning effectiveness

**Feature Extraction Approach:**

```python
import torch
import torch.nn as nn
import torchvision.models as models

class FeatureExtractorNetwork(nn.Module):
    def __init__(self, pretrained_model_name, num_classes, freeze_features=True):
        super(FeatureExtractorNetwork, self).__init__()
        
        # Load pre-trained model
        if pretrained_model_name == 'resnet50':
            self.backbone = models.resnet50(pretrained=True)
            feature_dim = self.backbone.fc.in_features
            self.backbone.fc = nn.Identity()  # Remove final classifier
        elif pretrained_model_name == 'vit_b_16':
            self.backbone = models.vit_b_16(pretrained=True)
            feature_dim = self.backbone.head.in_features
            self.backbone.head = nn.Identity()
            
        # Freeze backbone parameters if specified
        if freeze_features:
            for param in self.backbone.parameters():
                param.requires_grad = False
                
        # Add custom classifier
        self.classifier = nn.Sequential(
            nn.Dropout(0.5),
            nn.Linear(feature_dim, 512),
            nn.ReLU(),
            nn.Dropout(0.3),
            nn.Linear(512, num_classes)
        )
        
    def forward(self, x):
        features = self.backbone(x)
        return self.classifier(features)
```

**Progressive Unfreezing:**

```python
class ProgressiveUnfreezing:
    def __init__(self, model, unfreeze_schedule):
        self.model = model
        self.unfreeze_schedule = unfreeze_schedule
        self.current_epoch = 0
        
    def step_epoch(self, epoch):
        self.current_epoch = epoch
        if epoch in self.unfreeze_schedule:
            layers_to_unfreeze = self.unfreeze_schedule[epoch]
            self._unfreeze_layers(layers_to_unfreeze)
            
    def _unfreeze_layers(self, layer_names):
        for name, param in self.model.named_parameters():
            if any(layer_name in name for layer_name in layer_names):
                param.requires_grad = True
                print(f"Unfrozen layer: {name}")

# Usage example
unfreeze_schedule = {
    5: ['backbone.layer4'],   # Unfreeze last ResNet block at epoch 5
    10: ['backbone.layer3'],  # Unfreeze second-to-last block at epoch 10
    15: ['backbone']          # Unfreeze entire backbone at epoch 15
}
progressive_unfreezer = ProgressiveUnfreezing(model, unfreeze_schedule)
```

**Cross-Domain Transfer Learning:**

```python
class DomainAdaptationNetwork(nn.Module):
    def __init__(self, source_model, target_classes, adaptation_layers):
        super().__init__()
        self.feature_extractor = source_model.backbone
        
        # Domain adaptation layers
        self.domain_adapter = nn.Sequential(
            nn.Linear(adaptation_layers['input_dim'], adaptation_layers['hidden_dim']),
            nn.BatchNorm1d(adaptation_layers['hidden_dim']),
            nn.ReLU(),
            nn.Dropout(0.3)
        )
        
        # Target domain classifier
        self.target_classifier = nn.Linear(adaptation_layers['hidden_dim'], target_classes)
        
    def forward(self, x, return_features=False):
        features = self.feature_extractor(x)
        adapted_features = self.domain_adapter(features)
        output = self.target_classifier(adapted_features)
        
        if return_features:
            return output, adapted_features
        return output
```

