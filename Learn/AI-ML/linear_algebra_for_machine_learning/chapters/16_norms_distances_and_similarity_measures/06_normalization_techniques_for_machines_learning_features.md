## Normalization Techniques for Machine Learning Features

### Overview

Feature normalization rescales numeric data onto a common range or distribution so that no single feature dominates a model due to its scale. This is a preprocessing step for algorithms sensitive to feature magnitude, including gradient-descent-based models, distance-based methods, and regularized linear models.

### Why Normalization Matters

#### Scale Sensitivity in Algorithms

Many ML algorithms compute distances, dot products, or gradients directly on feature values.

**Key Points**
- Distance-based methods (k-NN, k-means, SVM with RBF kernels) are directly affected by feature scale, since large-magnitude features dominate distance calculations
- Gradient descent converges faster and more reliably when features are on comparable scales, since a poorly scaled feature space produces elongated, ill-conditioned loss surfaces
- Regularization (L1/L2) penalizes coefficient magnitude, so unnormalized features with different scales receive inconsistent penalty effects
- Tree-based models (decision trees, random forests, gradient boosting) are generally invariant to monotonic feature scaling, since splits are based on relative ordering, not magnitude

#### Diagram: Effect of Scaling on Gradient Descent Path

<svg viewBox="0 0 700 380" xmlns="http://www.w3.org/2000/svg">
  <text x="350" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Gradient Descent: Unscaled vs Scaled Features (svg_diagram)</text>

  <text x="175" y="60" text-anchor="middle" font-size="14" font-weight="bold" fill="#333">Unscaled Features</text>
  <ellipse cx="175" cy="210" rx="150" ry="60" fill="none" stroke="#999" stroke-width="1.5"/>
  <ellipse cx="175" cy="210" rx="110" ry="40" fill="none" stroke="#999" stroke-width="1.5"/>
  <ellipse cx="175" cy="210" rx="70" ry="20" fill="none" stroke="#999" stroke-width="1.5"/>
  <path d="M 60 100 L 100 160 L 130 195 L 150 205 L 165 209 L 172 210" stroke="#dc2626" stroke-width="2.5" fill="none"/>
  <circle cx="60" cy="100" r="4" fill="#dc2626"/>
  <circle cx="172" cy="210" r="4" fill="#dc2626"/>
  <text x="175" y="300" text-anchor="middle" font-size="12" fill="#555">Zigzagging path,</text>
  <text x="175" y="316" text-anchor="middle" font-size="12" fill="#555">slower convergence</text>

  <text x="525" y="60" text-anchor="middle" font-size="14" font-weight="bold" fill="#333">Scaled Features</text>
  <circle cx="525" cy="210" r="90" fill="none" stroke="#999" stroke-width="1.5"/>
  <circle cx="525" cy="210" r="60" fill="none" stroke="#999" stroke-width="1.5"/>
  <circle cx="525" cy="210" r="30" fill="none" stroke="#999" stroke-width="1.5"/>
  <path d="M 440 130 L 490 175 L 515 200 L 523 208" stroke="#16a34a" stroke-width="2.5" fill="none"/>
  <circle cx="440" cy="130" r="4" fill="#16a34a"/>
  <circle cx="523" cy="208" r="4" fill="#16a34a"/>
  <text x="525" y="300" text-anchor="middle" font-size="12" fill="#555">Direct path,</text>
  <text x="525" y="316" text-anchor="middle" font-size="12" fill="#555">faster convergence</text>
</svg>

This diagram is a conceptual illustration of contour geometry, not a plot generated from a specific dataset or model run. [Inference] The general relationship between conditioning and convergence speed is established optimization theory, but actual convergence behavior depends on the optimizer, learning rate, and loss landscape of a given problem, and is not guaranteed to match this idealized picture in every case.

### Core Normalization Techniques

#### Min-Max Scaling (Normalization)

Rescales features to a fixed range, typically $[0, 1]$.

$$x' = \frac{x - x_{\min}}{x_{\max} - x_{\min}}$$

**Key Points**
- Preserves the shape of the original distribution
- Highly sensitive to outliers, since a single extreme value compresses the rest of the data into a narrow sub-range
- Common in image processing (pixel values scaled to $[0,1]$) and neural network inputs

**Example**

```
x = [10, 20, 30, 40, 50]
x_min = 10, x_max = 50

x' = [(10-10)/40, (20-10)/40, (30-10)/40, (40-10)/40, (50-10)/40]
   = [0.0, 0.25, 0.5, 0.75, 1.0]
```

#### Z-Score Standardization

Centers data around a mean of $0$ with a standard deviation of $1$.

$$x' = \frac{x - \mu}{\sigma}$$

where $\mu$ is the feature mean and $\sigma$ is the feature standard deviation.

**Key Points**
- Does not bound values to a fixed range
- Less sensitive to outliers than min-max scaling, though still affected since $\mu$ and $\sigma$ are themselves outlier-sensitive statistics
- Assumes, or works best under, roughly Gaussian-distributed data, though it is applied in practice to non-Gaussian data as well [Inference: this is standard practice, but the degree of performance benefit on non-Gaussian features is model- and task-dependent]
- Preferred for algorithms assuming zero-centered data, such as PCA and linear/logistic regression with regularization

**Example**

```
x = [10, 20, 30, 40, 50]
mean = 30, std ≈ 14.14

x' ≈ [-1.41, -0.71, 0.0, 0.71, 1.41]
```

#### Robust Scaling

Uses median and interquartile range (IQR) instead of mean and standard deviation.

$$x' = \frac{x - \text{median}(x)}{\text{IQR}(x)}$$

where $\text{IQR}(x) = Q_3 - Q_1$.

**Key Points**
- Substantially less affected by outliers than min-max or z-score scaling, since median and IQR are robust statistics
- Recommended when the dataset contains significant outliers that should not dominate the scaling
- Does not produce a fixed output range

#### Unit Vector Normalization (L2 Normalization)

Rescales each sample (row) so that its vector has unit norm, rather than scaling each feature (column).

$$x' = \frac{\mathbf{x}}{\|\mathbf{x}\|_2}$$

**Key Points**
- Operates per-sample, not per-feature — a fundamentally different axis of normalization than the previous techniques
- Common in text processing (TF-IDF vectors) and when direction, not magnitude, carries the relevant signal
- Often paired with cosine similarity, since normalized vectors make cosine similarity equivalent to a dot product

#### Max Abs Scaling

Scales each feature by its maximum absolute value.

$$x' = \frac{x}{|x_{\max}|}$$

**Key Points**
- Preserves sparsity, since zero values remain zero — important for sparse matrices where preserving zeros avoids densifying the data structure
- Result range is $[-1, 1]$
- Commonly used with sparse data, such as one-hot encoded or TF-IDF features

#### Log Transformation

Applies a logarithmic function to compress the range of skewed data, typically prior to further scaling.

$$x' = \log(x + c)$$

where $c$ is a small constant added to handle zero or near-zero values.

**Key Points**
- Reduces the influence of extreme values and right-skewed distributions
- Not defined for negative values without an offset or a signed-log variant
- Common for features such as income, population counts, or word frequencies, which tend to follow heavy-tailed distributions

#### Power Transformations (Box-Cox, Yeo-Johnson)

Family of transformations designed to make data more Gaussian-like.

$$x'_{\text{Box-Cox}} = \begin{cases} \dfrac{x^{\lambda} - 1}{\lambda} & \lambda \neq 0 \\ \ln(x) & \lambda = 0 \end{cases}$$

**Key Points**
- Box-Cox requires strictly positive input values
- Yeo-Johnson extends the concept to handle zero and negative values
- The parameter $\lambda$ is typically estimated from the data to maximize normality of the resulting distribution

### Comparison Table

| Technique | Output Range | Outlier Sensitivity | Typical Use Case |
|---|---|---|---|
| Min-Max Scaling | Fixed (e.g., $[0,1]$) | High | Neural network inputs, image pixels |
| Z-Score Standardization | Unbounded | Moderate | PCA, linear models, SVM |
| Robust Scaling | Unbounded | Low | Data with significant outliers |
| Unit Vector (L2) Normalization | Unit norm per sample | Depends on vector composition | Text/TF-IDF, cosine similarity contexts |
| Max Abs Scaling | $[-1, 1]$ | High | Sparse data |
| Log Transformation | Compressed, unbounded | Reduces skew impact | Skewed count/frequency data |
| Box-Cox / Yeo-Johnson | Unbounded | Reduces skew impact | Making data approximately Gaussian |

This table reflects general conventions observed in common ML practice. [Unverified] The best technique for a given dataset depends on empirical validation, and no single method is universally optimal across all models and data distributions.

### Practical Considerations

#### Fitting on Training Data Only

Scaling parameters ($\mu$, $\sigma$, $x_{\min}$, $x_{\max}$, median, IQR, etc.) should be computed from the training set only, then applied to validation and test sets using those same parameters. Computing scaling parameters from the full dataset, including test data, introduces data leakage, since information about the test distribution influences preprocessing applied to the training set. [Inference: this is a widely-taught methodological principle in ML practice, though its practical impact on final model performance varies by dataset size and the degree of distributional difference between splits]

#### Normalization vs Standardization Terminology

The terms "normalization" and "standardization" are used inconsistently across sources. Some treat "normalization" as synonymous with min-max scaling specifically and "standardization" as synonymous with z-score scaling, while others use "normalization" as an umbrella term covering all scaling techniques. [Unverified — terminology conventions vary by textbook, library documentation, and community, and there is no single authoritative standard]

#### Handling New/Unseen Data at Inference Time

Values outside the range seen during training (e.g., a new maximum for min-max scaling) can produce output values outside the expected normalized range at inference time. This is a structural property of range-based scaling methods, not a flaw specific to any implementation. [Inference]

### Related Topics

- Principal Component Analysis (PCA) and its dependence on feature scaling
- Regularization techniques (L1/L2) and their interaction with feature scale
- Batch normalization and layer normalization in deep learning
- Handling outliers and skewed distributions in feature engineering
- Data leakage in preprocessing pipelines
- Distance metrics and their sensitivity to feature scale
