## TimeSeriesSplit for Temporal Data


TimeSeriesSplit is specifically designed for time series data where temporal order matters. Unlike standard cross-validation, it respects the chronological sequence and uses only past data to predict future values, preventing data leakage.

**Key points:**

- Maintains chronological order of data
- Each fold uses all previous data for training
- Test sets are always in the future relative to training sets
- Expanding window approach by default

**Example:**

```python
from sklearn.model_selection import TimeSeriesSplit
from sklearn.linear_model import LinearRegression
import pandas as pd
import numpy as np

# Create time series data
dates = pd.date_range('2020-01-01', periods=1000, freq='D')
X = np.cumsum(np.random.randn(1000, 5), axis=0)  # Features with temporal correlation
y = X.sum(axis=1) + np.random.randn(1000) * 0.1  # Target with noise

# Initialize TimeSeriesSplit
tscv = TimeSeriesSplit(n_splits=5)

model = LinearRegression()

# Perform time series cross-validation
for fold, (train_idx, test_idx) in enumerate(tscv.split(X)):
    X_train, X_test = X[train_idx], X[test_idx]
    y_train, y_test = y[train_idx], y[test_idx]
    
    model.fit(X_train, y_train)
    score = model.score(X_test, y_test)
    
    print(f"Fold {fold + 1}: R² = {score:.3f}")
    print(f"  Train period: {dates[train_idx[0]]} to {dates[train_idx[-1]]}")
    print(f"  Test period: {dates[test_idx[0]]} to {dates[test_idx[-1]]}")
```

TimeSeriesSplit can be configured with different parameters like max_train_size to limit the training window size, useful for datasets where distant past data may be less relevant.

