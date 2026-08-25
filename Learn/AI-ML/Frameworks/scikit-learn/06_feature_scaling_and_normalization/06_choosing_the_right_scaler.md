## Choosing the Right Scaler


The selection depends on data characteristics and algorithm requirements:

**StandardScaler when:**

- Features are approximately normally distributed
- Using linear models, PCA, or clustering
- No significant outliers present
- Need interpretable coefficients in linear models

**MinMaxScaler when:**

- Need bounded feature ranges
- Using neural networks with bounded activation functions
- Preserving zero values is important
- Features have known theoretical bounds

**RobustScaler when:**

- Data contains outliers
- Distribution is not normal
- Need robust preprocessing
- Outliers are measurement errors, not meaningful extremes

**Normalizer when:**

- Working with text data or sparse features
- Direction matters more than magnitude
- Using cosine similarity
- Features represent proportions or compositions

**QuantileTransformer when:**

- Data is heavily skewed
- Presence of extreme outliers
- Need uniform or normal distribution
- Non-linear relationships benefit the model

