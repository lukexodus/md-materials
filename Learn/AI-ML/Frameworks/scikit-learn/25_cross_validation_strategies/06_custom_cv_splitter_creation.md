## Custom CV Splitter Creation


Scikit-learn allows creation of custom cross-validation splitters for specialized requirements. Custom splitters must implement the split method and optionally get_n_splits method.

**Key points:**

- Inherit from sklearn.model_selection.BaseCrossValidator
- Implement split(X, y=None, groups=None) method
- Can incorporate domain-specific splitting logic
- Useful for specialized data structures or constraints

**Example:**

```python
from sklearn.model_selection import BaseCrossValidator
import numpy as np

class GroupedTimeSeriesSplit(BaseCrossValidator):
    """Custom splitter for grouped time series data."""
    
    def __init__(self, n_splits=3, group_col=None):
        self.n_splits = n_splits
        self.group_col = group_col
    
    def split(self, X, y=None, groups=None):
        if groups is None:
            raise ValueError("groups parameter is required")
        
        unique_groups = np.unique(groups)
        n_groups = len(unique_groups)
        
        # Ensure we have enough groups for the requested splits
        if n_groups < self.n_splits + 1:
            raise ValueError(f"Cannot split {n_groups} groups into {self.n_splits} folds")
        
        group_size = n_groups // (self.n_splits + 1)
        
        for i in range(self.n_splits):
            # Training groups: all groups before the test group
            train_groups = unique_groups[:(i + 1) * group_size]
            # Test group: next group(s)
            test_groups = unique_groups[(i + 1) * group_size:(i + 2) * group_size]
            
            train_mask = np.isin(groups, train_groups)
            test_mask = np.isin(groups, test_groups)
            
            yield np.where(train_mask)[0], np.where(test_mask)[0]
    
    def get_n_splits(self, X=None, y=None, groups=None):
        return self.n_splits

# Usage example
from sklearn.datasets import make_classification

# Create data with group structure
X, y = make_classification(n_samples=1000, n_features=10, random_state=42)
groups = np.repeat(range(50), 20)  # 50 groups, 20 samples each

# Use custom splitter
custom_cv = GroupedTimeSeriesSplit(n_splits=3)

for fold, (train_idx, test_idx) in enumerate(custom_cv.split(X, y, groups=groups)):
    print(f"Fold {fold + 1}:")
    print(f"  Training groups: {np.unique(groups[train_idx])}")
    print(f"  Test groups: {np.unique(groups[test_idx])}")
```

