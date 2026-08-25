## Categorical Data Encoding Techniques


**One-Hot Encoding** One-hot encoding creates binary indicator variables for each category level. Each categorical value is represented by a vector with a single 1 and remaining 0s.

**Advantages and Limitations**

- **Memory Efficiency**: Sparse representation reduces storage requirements
- **Linear Model Compatibility**: Works well with linear models and neural networks
- **High Cardinality Issues**: Creates extremely wide sparse vectors for categories with many levels
- **Cold Start Problem**: Cannot handle previously unseen categorical values

**Ordinal Encoding** Ordinal encoding assigns integer values to categorical levels, preserving natural ordering when it exists.

**Application Scenarios**

- Educational levels (high school = 1, bachelor's = 2, master's = 3, PhD = 4)
- Rating scales (poor = 1, fair = 2, good = 3, excellent = 4)
- Size categories (small = 1, medium = 2, large = 3, extra-large = 4)

**Hash Encoding** Hash encoding applies hash functions to categorical values, mapping them to fixed-size integer ranges. This technique handles high-cardinality categories and unknown values gracefully.

**Technical Implementation** [Inference]

```python
# Hash encoding implementation
def hash_encode(category, num_buckets):
    return hash(category) % num_buckets

# TensorFlow implementation
hashed_feature = tf.feature_column.categorical_column_with_hash_bucket(
    key='category_column',
    hash_bucket_size=1000
)
```

**Target Encoding** Target encoding replaces categorical values with statistics computed from the target variable, such as mean target value for each category.

**Overfitting Prevention** Target encoding requires careful regularization to prevent overfitting:

- **Cross-validation**: Compute encodings using out-of-fold data
- **Smoothing**: Blend category statistics with global statistics
- **Regularization**: Add noise or use Bayesian approaches

**Embedding Layers for Categories** Embedding layers learn dense vector representations for categorical features, particularly effective for high-cardinality categories.

**Embedding Dimension Selection** [Inference] Common heuristics for embedding dimensions:

- **Square root rule**: dim = √(cardinality)
- **Fourth root rule**: dim = cardinality^0.25
- **Rule of thumb**: dim = min(50, cardinality/2)

