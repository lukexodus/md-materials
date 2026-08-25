## Random Oversampling and Undersampling

### Overview

Random oversampling and random undersampling are the two most basic resampling techniques used to address class imbalance. Both work by directly changing the number of observations from each class in the training data, without generating new synthetic data points, distinguishing them from more sophisticated techniques like SMOTE.

### Random Oversampling

#### Mechanics

Random oversampling duplicates existing minority class observations, chosen randomly (with replacement), until the class distribution reaches a specified target ratio, often full balance with the majority class.

**Example:**

| Class | Original Count | After Random Oversampling |
| --- | --- | --- |
| Not fraud (0) | 9,850 | 9,850 |
| Fraud (1) | 150 | 9,850 |

```python
from imblearn.over_sampling import RandomOverSampler

ros = RandomOverSampler(random_state=42)
X_resampled, y_resampled = ros.fit_resample(X_train, y_train)
```

`RandomOverSampler` from the `imbalanced-learn` (`imblearn`) library is a documented implementation of this technique, which duplicates minority class rows at random until the target balance is reached.

#### Key Limitation: Overfitting Risk

Since random oversampling creates exact duplicate copies of existing minority class rows rather than new information, the same minority class observations can appear multiple times across the resampled training set.

- [Inference] This repetition increases the risk that a model will overfit to the specific characteristics of the duplicated minority class examples, since the model may effectively "memorize" these repeated rows rather than learning a generalizable pattern for the minority class. This is a reasoned consequence of how duplication interacts with model training, not a benchmarked measurement of overfitting severity for any specific dataset or model.
- I cannot verify the exact degree of overfitting risk for any specific combination of dataset and model type without direct testing, since this depends on factors such as the model's capacity, the degree of oversampling applied, and the underlying data characteristics.

### Random Undersampling

#### Mechanics

Random undersampling removes existing majority class observations, chosen randomly, until the class distribution reaches a specified target ratio, often full balance with the minority class.

**Example:**

| Class | Original Count | After Random Undersampling |
| --- | --- | --- |
| Not fraud (0) | 9,850 | 150 |
| Fraud (1) | 150 | 150 |

```python
from imblearn.under_sampling import RandomUnderSampler

rus = RandomUnderSampler(random_state=42)
X_resampled, y_resampled = rus.fit_resample(X_train, y_train)
```

`RandomUnderSampler` from `imblearn` is a documented implementation that removes majority class rows at random until the target balance is reached.

#### Key Limitation: Information Loss

Because random undersampling discards actual observed data points from the majority class, it can remove information that may have been useful for the model to learn the majority class's true distribution.

- [Inference] This risk is generally considered more severe when the original majority class sample size is not very large to begin with, since removing a substantial fraction of majority class data may leave too few observations to characterize that class well. This is a reasoned concern based on general statistical sampling principles rather than a benchmarked finding for a specific dataset.
- For datasets where the majority class already has a very large number of observations relative to what is needed to characterize its distribution, [Inference] the practical information loss from undersampling may be less severe, though I do not have a reliable general basis to state a specific sample size threshold at which this becomes true or false for a given dataset.

### Choosing Between Oversampling and Undersampling

| Consideration | Favors Oversampling | Favors Undersampling |
| --- | --- | --- |
| Overall dataset size | Small datasets (undersampling would leave too little data) | Very large datasets (majority class has data to spare) |
| Computational cost | Increases training set size and thus training time | Decreases training set size and thus training time |
| Risk profile | Overfitting to duplicated minority examples | Losing potentially useful majority class information |

[Inference] In practice, the choice is often dataset-dependent, and some practitioners combine both techniques (partial undersampling of the majority class alongside partial oversampling of the minority class) to balance these tradeoffs, rather than applying either technique to its full extreme. I do not have a single authoritative source establishing this combined approach as a formally standardized best practice, though it is a commonly described pattern in imbalanced learning literature.

### Decision Path

===MERMAID_DIAGRAM===

flowchart TD

A[Class imbalance identified] --> B{Overall dataset size}

B -->|Small| C[Consider oversampling]

B -->|Large| D[Consider undersampling]

C --> E{Risk of overfitting to duplicates a concern?}

E -->|Yes| F["Consider synthetic methods like SMOTE instead"]

E -->|No| G[Random oversampling acceptable]

D --> H{Risk of losing majority class information a concern?}

H -->|Yes| I["Consider combining partial undersampling with partial oversampling"]

H -->|No| J[Random undersampling acceptable]

### Critical Practice: Resampling Only the Training Set

A critical and frequently emphasized practice is that resampling (whether oversampling or undersampling) should be applied **only to the training set**, never to the validation or test set.

- **Reasoning:** Validation and test sets are meant to reflect the real-world class distribution the model will encounter in production. Artificially balancing these sets would produce evaluation metrics that do not reflect genuine expected performance on real, imbalanced incoming data.
- This is a widely documented best practice in the imbalanced learning literature, not merely a stylistic preference.

```python
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, stratify=y)

ros = RandomOverSampler(random_state=42)
X_train_resampled, y_train_resampled = ros.fit_resample(X_train, y_train)

model.fit(X_train_resampled, y_train_resampled)
model.predict(X_test)
```

Note that `X_test` and `y_test` remain untouched by the resampler in this pattern, preserving the original class distribution for evaluation.

### Resampling Within Cross-Validation

Similar to the encoding leakage concerns discussed earlier, resampling must be performed within each cross-validation fold, not applied once to the entire training set before cross-validation begins.

- **Incorrect approach:** Resample the entire training set once, then run cross-validation on the already-resampled data. This can allow duplicated (oversampled) or removed (undersampled) rows to be inconsistently distributed between cross-validation folds in ways that distort validation performance estimates.
- **Correct approach:** Apply resampling only within each fold's training portion, leaving each fold's validation portion at the original class distribution.

`imblearn` provides a `Pipeline` class (distinct from scikit-learn's own `Pipeline`) specifically designed to integrate resampling steps correctly within cross-validation workflows.

```python
from imblearn.pipeline import Pipeline as ImbPipeline

pipeline = ImbPipeline([
    ('sampler', RandomOverSampler(random_state=42)),
    ('model', LogisticRegression())
])

scores = cross_val_score(pipeline, X, y, cv=5)
```

Using `imblearn.pipeline.Pipeline` in place of scikit-learn's standard `Pipeline` is documented as necessary specifically because scikit-learn's own `Pipeline` does not support resampling steps that change the number of rows, only transformations that preserve row count.

### Common Pitfalls

- Applying oversampling or undersampling to the full dataset before splitting into train and test sets, which allows duplicated or resampled information to leak across the split.
- Resampling the entire training set once before cross-validation rather than within each fold, distorting validation performance estimates.
- Using scikit-learn's standard `Pipeline` with a resampling step, which is not designed to support steps that alter the number of rows in the dataset.
- Assuming full 50/50 class balance is always the correct target ratio — [Inference] partial rebalancing (e.g., targeting a 70/30 ratio rather than 50/50) is sometimes preferred depending on the specific problem and cost of misclassification, though I do not have a general rule for determining the optimal target ratio for any given dataset without testing.

### Key Points

- Random oversampling duplicates existing minority class rows; random undersampling removes existing majority class rows, both without generating new synthetic data.
- [Inference] Random oversampling carries a risk of overfitting to duplicated examples, while random undersampling carries a risk of losing potentially useful majority class information; the severity of either risk is dataset- and model-dependent and has not been benchmarked here.
- Resampling should be applied only to the training set, never to validation or test sets, to preserve realistic evaluation of model performance on the original class distribution.
- Resampling must be integrated within cross-validation folds rather than applied once globally, typically using `imblearn`'s `Pipeline` rather than scikit-learn's standard `Pipeline`.
- There is no single universally correct target balance ratio; this is a dataset- and problem-specific decision that I cannot generalize into a fixed rule.

I cannot verify optimal resampling ratios, specific overfitting magnitudes, or exact information loss thresholds for any dataset not directly tested; such determinations require empirical evaluation on the specific data and model in question.

**Related Topics**

- SMOTE and other synthetic oversampling techniques
- Combining oversampling and undersampling (hybrid resampling strategies)
- Cost-sensitive learning and class weighting as alternatives to resampling
- Stratified sampling for preserving class distribution in train/test splits
- Evaluation metrics suited to imbalanced classification (precision-recall, F1, etc.)