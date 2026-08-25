## Sampling Strategies and Data Distribution


Sampling strategies control data selection and ordering during training, significantly impacting model convergence and generalization. Random sampling ensures uniform data distribution, while stratified sampling maintains class balance across batches. Weighted sampling enables bias correction for imbalanced datasets.

Custom sampler implementations extend the Sampler base class, defining data selection logic through the **iter**() method. Samplers can implement complex strategies like curriculum learning, importance sampling, or domain-specific selection criteria. The **len**() method must return the total number of samples to be generated.

Data distribution considerations include class imbalance handling, domain adaptation requirements, and temporal ordering constraints. Imbalanced datasets benefit from weighted sampling or specialized loss functions, while temporal data may require sequential or sliding window sampling approaches.

Batch sampling strategies affect gradient computation and model training dynamics. BatchSampler controls how individual samples are grouped into batches, enabling variable batch sizes, stratified batching, or custom grouping criteria based on data characteristics.

**Key Points:**

- Sampling strategies directly impact training convergence and model performance
- Custom samplers enable sophisticated data selection and ordering approaches
- Class imbalance requires specialized sampling or loss function modifications
- Batch sampling controls gradient computation characteristics and training dynamics

**Example:**

```python
from torch.utils.data import Sampler, WeightedRandomSampler
import numpy as np

class StratifiedSampler(Sampler):
    """Stratified sampling ensuring balanced classes per epoch."""
    
    def __init__(self, labels, samples_per_class=None):
        self.labels = np.array(labels)
        self.classes = np.unique(self.labels)
        self.samples_per_class = samples_per_class or len(self.labels) // len(self.classes)
        
        # Create class-to-indices mapping
        self.class_indices = {}
        for cls in self.classes:
            self.class_indices[cls] = np.where(self.labels == cls)[0].tolist()
    
    def __iter__(self):
        indices = []
        for cls in self.classes:
            class_indices = self.class_indices[cls]
            # Sample with replacement if needed
            sampled = np.random.choice(
                class_indices, 
                size=self.samples_per_class, 
                replace=len(class_indices) < self.samples_per_class
            )
            indices.extend(sampled.tolist())
        
        # Shuffle the combined indices
        np.random.shuffle(indices)
        return iter(indices)
    
    def __len__(self):
        return len(self.classes) * self.samples_per_class

# Weighted sampling for imbalanced datasets
def create_weighted_sampler(labels):
    """Create weighted sampler based on class frequencies."""
    class_counts = np.bincount(labels)
    class_weights = 1.0 / class_counts
    sample_weights = class_weights[labels]
    
    return WeightedRandomSampler(
        weights=sample_weights,
        num_samples=len(labels),
        replacement=True
    )

# Custom batch sampler for variable batch sizes
class VariableBatchSampler:
    def __init__(self, sampler, batch_sizes):
        self.sampler = sampler
        self.batch_sizes = batch_sizes
    
    def __iter__(self):
        batch = []
        batch_size_idx = 0
        current_batch_size = self.batch_sizes[batch_size_idx]
        
        for idx in self.sampler:
            batch.append(idx)
            if len(batch) == current_batch_size:
                yield batch
                batch = []
                batch_size_idx = (batch_size_idx + 1) % len(self.batch_sizes)
                current_batch_size = self.batch_sizes[batch_size_idx]
        
        if batch:  # Yield remaining samples
            yield batch
    
    def __len__(self):
        return (len(self.sampler) + min(self.batch_sizes) - 1) // min(self.batch_sizes)
```

