## KNNImputer Implementation


The `KNNImputer` employs k-nearest neighbors methodology to impute missing values by leveraging the relationships between features and samples. This approach considers the local structure of the data and can capture complex patterns that simple statistical measures might miss.

### Algorithm Mechanics

The imputation process involves identifying the k nearest neighbors for each sample with missing values using a distance metric (typically Euclidean distance). The missing values are then filled using a weighted or unweighted average of the corresponding feature values from these neighbors.

**Distance Calculation**: Only features that are non-missing in both the target sample and potential neighbors contribute to the distance calculation. This ensures that the similarity assessment is based on available information.

**Neighbor Selection**: The algorithm ranks all complete or partially complete samples by their distance to the target sample and selects the k closest ones. The choice of k represents a bias-variance tradeoff: smaller k values may be noisy but capture local patterns, while larger k values provide smoother but potentially less accurate imputations.

**Value Aggregation**: For numerical features, the algorithm typically uses the mean or weighted mean of the neighbors' values. For categorical features, it uses the mode or weighted mode.

### Advanced Configuration

**Distance Metrics**: While Euclidean distance is default, the implementation can handle different distance metrics appropriate for various data types and scales.

**Weighting Schemes**: Uniform weighting treats all neighbors equally, while distance-based weighting gives more influence to closer neighbors, potentially improving imputation accuracy for locally structured data.

**Missing Pattern Handling**: The algorithm handles various missing data patterns, including cases where different features are missing across different samples.

**Key points**:

- Captures local data structure and feature relationships
- Handles both numerical and categorical variables
- Requires complete feature vectors for distance calculation accuracy
- Computationally intensive for large datasets due to distance calculations
- Performance depends critically on the choice of k and distance metric

**Example**:

```python
from sklearn.impute import KNNImputer
import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline

# Create sample data with missing values
data = np.array([[1, 2, 3, 4],
                 [5, np.nan, 7, 8],
                 [9, 10, np.nan, 12],
                 [13, 14, 15, np.nan],
                 [np.nan, 18, 19, 20]])

# KNN imputation with different k values
knn_imputer_3 = KNNImputer(n_neighbors=3, weights='uniform')
knn_imputed_3 = knn_imputer_3.fit_transform(data)

# Distance-weighted KNN imputation
knn_imputer_weighted = KNNImputer(n_neighbors=5, weights='distance')
knn_imputed_weighted = knn_imputer_weighted.fit_transform(data)

# Integration with preprocessing pipeline
pipeline = Pipeline([
    ('scaler', StandardScaler()),
    ('imputer', KNNImputer(n_neighbors=3))
])
processed_data = pipeline.fit_transform(data)
```

