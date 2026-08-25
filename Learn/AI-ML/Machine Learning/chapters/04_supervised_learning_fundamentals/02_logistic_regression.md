## Logistic Regression

### Overview

Logistic regression is a supervised learning algorithm used for classification tasks, most commonly binary classification, where the goal is to predict the probability that an observation belongs to a particular class. Despite its name, logistic regression is a classification algorithm, not a regression algorithm in the sense of predicting continuous values.

### Mathematical Foundation

#### The Sigmoid Function

Logistic regression models the probability of the positive class using the sigmoid (logistic) function, which maps any real-valued input to a value between 0 and 1.

$$\sigma(z) = \frac{1}{1 + e^{-z}}$$

Where:

$$z = \beta_0 + \beta_1 x_1 + \beta_2 x_2 + \dots + \beta_n x_n$$

#### Probability Interpretation

$$P(y=1 \mid x) = \sigma(z) = \frac{1}{1 + e^{-(\beta_0 + \beta_1 x_1 + \dots + \beta_n x_n)}}$$

**Key Points**

- The output represents an estimated probability, documented as the standard interpretation in statistics and machine learning references, and is bounded between 0 and 1 due to the mathematical properties of the sigmoid function.
- A decision threshold (commonly 0.5) is applied to this probability to produce a final class prediction.

#### Log-Odds (Logit)

The logistic regression model is linear in the log-odds (logit) of the outcome.

$$\ln\left(\frac{P(y=1)}{1 - P(y=1)}\right) = \beta_0 + \beta_1 x_1 + \dots + \beta_n x_n$$

**Key Points**

- This log-odds formulation is the standard mathematical basis documented for logistic regression, distinguishing it from linear regression, which models the target directly rather than its log-odds transformation.

### Fitting the Model — Maximum Likelihood Estimation

Unlike linear regression's closed-form OLS solution, logistic regression coefficients are typically estimated using Maximum Likelihood Estimation (MLE), solved iteratively (e.g., via gradient descent or Newton-Raphson methods).

$$\mathcal{L}(\beta) = \prod_{i=1}^{n} P(y_i \mid x_i)^{y_i} (1 - P(y_i \mid x_i))^{1-y_i}$$

The corresponding loss function minimized during training is the log loss (binary cross-entropy):

$$\text{Log Loss} = -\frac{1}{n}\sum_{i=1}^{n}\left[y_i \ln(\hat{p}_i) + (1-y_i)\ln(1-\hat{p}_i)\right]$$

**Key Points**

- This loss function is documented as the standard objective minimized in logistic regression training in scikit-learn and general machine learning literature.
- No closed-form solution exists for logistic regression coefficients in general; iterative optimization is required.

### Implementation Example

```python
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, confusion_matrix, roc_auc_score

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

model = LogisticRegression(max_iter=1000)
model.fit(X_train, y_train)

y_pred = model.predict(X_test)
y_pred_proba = model.predict_proba(X_test)[:, 1]

print("Coefficients:", model.coef_)
print("Intercept:", model.intercept_)
print(classification_report(y_test, y_pred))
print("ROC-AUC:", roc_auc_score(y_test, y_pred_proba))
```

**Example**

For a dataset predicting loan default (1 = default, 0 = no default) from income and debt ratio, the model outputs a probability for each applicant, such as 0.73, which would then be classified as "default" if the threshold is 0.5. I cannot verify what coefficients or probabilities would result from any actual dataset without fitting the model directly to that data.

### Interpreting Coefficients

Coefficients in logistic regression represent the change in log-odds for a one-unit increase in the corresponding feature, holding other features constant.

$$\text{Odds Ratio} = e^{\beta_i}$$

**Key Points**

- Exponentiating a coefficient produces the odds ratio, which is the standard, documented method for translating log-odds coefficients into a more interpretable multiplicative effect on the odds of the outcome.
- An odds ratio greater than 1 indicates increasing odds of the positive class as the feature increases; an odds ratio less than 1 indicates decreasing odds.

```python
import numpy as np

odds_ratios = np.exp(model.coef_[0])
```

### Decision Boundary

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 400">
<text x="300" y="30" font-size="18" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Logistic Regression Decision Boundary (svg_diagram)</text>
<line x1="70" y1="340" x2="70" y2="60" stroke="#333" stroke-width="1.5" />
<line x1="70" y1="340" x2="560" y2="340" stroke="#333" stroke-width="1.5" />
<text x="40" y="200" font-size="12" fill="#333" transform="rotate(-90 40 200)">Feature 2</text>
<text x="300" y="375" font-size="12" fill="#333">Feature 1</text>
<line x1="100" y1="100" x2="480" y2="320" stroke="#ea4335" stroke-width="2.5" stroke-dasharray="6,3" />
<text x="420" y="290" font-size="12" fill="#ea4335" font-weight="bold">Decision Boundary</text>
<circle cx="150" cy="120" r="5" fill="#4285f4" />
<circle cx="190" cy="150" r="5" fill="#4285f4" />
<circle cx="220" cy="110" r="5" fill="#4285f4" />
<circle cx="250" cy="160" r="5" fill="#4285f4" />
<circle cx="180" cy="190" r="5" fill="#4285f4" />
<circle cx="350" cy="220" r="5" fill="#fbbc05" />
<circle cx="390" cy="250" r="5" fill="#fbbc05" />
<circle cx="420" cy="200" r="5" fill="#fbbc05" />
<circle cx="450" cy="270" r="5" fill="#fbbc05" />
<circle cx="480" cy="230" r="5" fill="#fbbc05" />
<text x="150" y="90" font-size="11" fill="#4285f4">Class 0</text>
<text x="450" y="180" font-size="11" fill="#fbbc05">Class 1</text>
</svg>

**Key Points**

- Logistic regression produces a linear decision boundary in the feature space (or a hyperplane in higher dimensions), which is a documented mathematical consequence of the model's linear log-odds formulation.
- Non-linear decision boundaries require feature engineering (e.g., polynomial features) or a different model class entirely.

### Regularized Logistic Regression

```python
from sklearn.linear_model import LogisticRegression

# L2 regularization (default in scikit-learn)
model_l2 = LogisticRegression(penalty='l2', C=1.0)

# L1 regularization
model_l1 = LogisticRegression(penalty='l1', solver='liblinear', C=1.0)

# Elastic Net
model_en = LogisticRegression(penalty='elasticnet', solver='saga', l1_ratio=0.5, C=1.0)
```

**Key Points**

- In scikit-learn's documented parameterization, `C` is the inverse of regularization strength; smaller values of `C` specify stronger regularization.
- L1 regularization can shrink some coefficients to exactly zero, providing implicit feature selection, as documented in standard regularization literature.

### Multiclass Extensions

#### Multinomial (Softmax) Logistic Regression

Extends logistic regression to handle more than two classes directly using the softmax function.

$$P(y=k \mid x) = \frac{e^{z_k}}{\sum_{j=1}^{K} e^{z_j}}$$

```python
model_multinomial = LogisticRegression(multi_class='multinomial', solver='lbfgs')
```

#### One-vs-Rest (OvR)

Trains a separate binary classifier for each class against all other classes combined.

```python
model_ovr = LogisticRegression(multi_class='ovr')
```

**Key Points**

- [Unverified] Whether multinomial or one-vs-rest performs better depends on the specific dataset and class structure; I do not have access to benchmark results that would support a general claim of superiority for either approach across all datasets.

### Model Evaluation Metrics

Since logistic regression is a classification algorithm, evaluation typically uses classification-specific metrics rather than regression metrics like MSE.

- **Accuracy**: $\frac{TP+TN}{TP+TN+FP+FN}$
- **Precision**: $\frac{TP}{TP+FP}$
- **Recall**: $\frac{TP}{TP+FN}$
- **F1-Score**: $2 \times \frac{\text{Precision} \times \text{Recall}}{\text{Precision}+\text{Recall}}$
- **ROC-AUC**: Measures discrimination ability across all classification thresholds.
- **Log Loss**: Directly measures the quality of predicted probabilities, penalizing confident incorrect predictions more heavily than less confident ones.

```python
from sklearn.metrics import log_loss

loss = log_loss(y_test, y_pred_proba)
```

**Key Points**

- As discussed in the imbalanced datasets topic, accuracy alone can be a misleading metric when class distributions are imbalanced; precision, recall, F1-score, and ROC-AUC are generally considered more informative in such cases.

### Assumptions of Logistic Regression

[Inference] These assumptions are commonly documented in statistics and machine learning literature as conditions under which logistic regression coefficient estimates and their statistical inferences (e.g., confidence intervals) are considered valid. This reflects standard textbook treatment rather than a claim independently verified through testing on any specific dataset.

#### Linearity of Log-Odds

The relationship between independent variables and the log-odds of the outcome is assumed to be linear, even though the relationship between the features and the raw probability is non-linear (sigmoidal).

#### Independence of Observations

Observations are assumed to be independent of one another.

#### No Severe Multicollinearity

As with linear regression, highly correlated independent variables can produce unstable coefficient estimates.

#### Large Sample Size

[Inference] Maximum Likelihood Estimation, the method used to fit logistic regression, generally performs better with larger sample sizes; small sample sizes can result in unstable or biased coefficient estimates. This is a commonly cited general guideline in statistics literature, not a precise, universally applicable threshold.

### Logistic vs. Linear Regression

| Aspect | Linear Regression | Logistic Regression |
| --- | --- | --- |
| Output type | Continuous value | Probability (0 to 1) |
| Target variable | Continuous | Categorical (typically binary) |
| Loss function | Mean Squared Error | Log Loss (Binary Cross-Entropy) |
| Fitting method | Closed-form OLS | Iterative MLE |
| Decision boundary | Not applicable | Linear in log-odds space |

[Inference] This comparison reflects standard, documented distinctions between the two algorithms as commonly presented in machine learning literature. I cannot verify that every implementation across every library adheres to this comparison in every detail.

### Common Pitfalls

- **Using Accuracy on Imbalanced Data**: As with other classification algorithms, relying solely on accuracy can mask poor performance on a minority class.
- **Ignoring the Linearity of Log-Odds Assumption**: If the true relationship between features and log-odds is non-linear, logistic regression without feature engineering (e.g., polynomial or interaction terms) may underfit the data.
- **Misinterpreting Coefficients as Probabilities**: Raw coefficients represent changes in log-odds, not direct changes in probability; this is a common source of misinterpretation documented in applied statistics guidance.
- **Ignoring Multicollinearity**: As with linear regression, highly correlated features can destabilize coefficient estimates and complicate interpretation.

### Conclusion

Logistic regression is a documented, standard algorithm for binary and multiclass classification that models the log-odds of class membership as a linear function of input features, using the sigmoid or softmax function to produce interpretable probability outputs. [Inference] Whether logistic regression is an appropriate choice for a specific classification problem depends on whether the relationship between features and log-odds is approximately linear and whether the dataset satisfies the model's other underlying assumptions; I cannot verify this without direct information about that specific dataset.

I cannot verify claims about model performance on any dataset without direct testing on that specific dataset.

### Related Topics

- Linear regression (related foundational algorithm for continuous targets)
- Regularization techniques (L1, L2, Elastic Net)
- Support Vector Machines as an alternative classification approach
- Decision trees and ensemble classifiers
- ROC curves and precision-recall curves for classification evaluation
- Handling imbalanced datasets in classification
- Multiclass classification strategies (One-vs-Rest, One-vs-One, Softmax)