## Transforms and Data Augmentation


**Transform System Architecture**

PyTorch's transform system provides a unified interface for data preprocessing through callable objects that can be composed into pipelines. Transforms are designed to be deterministic during inference and optionally stochastic during training for data augmentation purposes.

```python
from torchvision import transforms
import torch

# Basic transform composition
transform = transforms.Compose([
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], 
                        std=[0.229, 0.224, 0.225])
])

# Apply transform
transformed_data = transform(raw_data)
```

**Data Augmentation Principles**

Data augmentation artificially increases dataset diversity by applying label-preserving transformations during training. This technique helps models generalize better by exposing them to variations of the training data that might occur in real-world scenarios.

**Augmentation Categories**:

- **Geometric Transformations**: Rotation, scaling, translation, flipping
- **Photometric Transformations**: Color jittering, brightness/contrast adjustment, noise addition
- **Occlusion-based**: Random erasing, cutout, mixup
- **Advanced Techniques**: AutoAugment, RandAugment, TrivialAugment [Inference]

**Stochastic vs Deterministic Transforms**

Many transforms support both stochastic and deterministic modes:

```python
# Stochastic augmentation (training)
train_transform = transforms.Compose([
    transforms.RandomHorizontalFlip(p=0.5),
    transforms.RandomRotation(degrees=10),
    transforms.ColorJitter(brightness=0.2, contrast=0.2),
    transforms.ToTensor()
])

# Deterministic preprocessing (validation/test)
val_transform = transforms.Compose([
    transforms.ToTensor()
])
```

**Transform Reproducibility**

Controlling randomness in transforms is crucial for reproducible experiments:

```python
import random
import numpy as np

def set_seed(seed):
    torch.manual_seed(seed)
    np.random.seed(seed)
    random.seed(seed)

# Set seed before creating datasets with stochastic transforms
set_seed(42)
dataset = MyDataset(transform=train_transform)
```

**Key Points:**

- Transforms provide a modular approach to data preprocessing and augmentation
- Stochastic augmentation during training improves model generalization
- Deterministic preprocessing ensures consistent inference results
- Proper seed management enables reproducible augmentation strategies

