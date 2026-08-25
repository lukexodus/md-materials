## Numerical Feature Normalization


**Min-Max Scaling** Min-max scaling transforms features to a fixed range, typically [0, 1] or [-1, 1].

**Formula**: (x - min) / (max - min)

**Use Cases**

- Neural networks with bounded activation functions
- Algorithms sensitive to feature magnitude (k-NN, SVM)
- When preserving the original distribution shape is important

**Standardization (Z-score)** Standardization transforms features to have zero mean and unit variance.

**Formula**: (x - μ) / σ

**Statistical Properties**

- Preserves the shape of the original distribution
- Makes features comparable across different scales
- Required for algorithms that assume normally distributed inputs

**Robust Scaling** Robust scaling uses median and interquartile range instead of mean and standard deviation, making it less sensitive to outliers.

**Formula**: (x - median) / IQR

**Outlier Handling** Robust scaling is particularly valuable when:

- Data contains significant outliers that shouldn't be removed
- Distribution has heavy tails
- Standard scaling would be dominated by extreme values

**Quantile Transformation** Quantile transformation maps features to a uniform or normal distribution by replacing values with their quantile ranks.

**Implementation Considerations** [Inference]

```python
# TensorFlow preprocessing layer approach
normalizer = tf.keras.layers.Normalization()
normalizer.adapt(training_data)

# Scikit-learn integration
from sklearn.preprocessing import QuantileTransformer
qt = QuantileTransformer(output_distribution='uniform')
transformed_data = qt.fit_transform(data)
```

**Power Transformations** Power transformations (Box-Cox, Yeo-Johnson) modify the distributional shape of features to approximate normality.

**Box-Cox Limitations** [Unverified] Box-Cox transformation requires strictly positive input values, while Yeo-Johnson handles negative values and zeros.

