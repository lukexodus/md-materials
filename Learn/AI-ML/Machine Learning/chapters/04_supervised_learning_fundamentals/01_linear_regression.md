## Linear Regression

### Overview

Linear regression is a supervised learning algorithm used to model the relationship between one or more independent variables (features) and a continuous dependent variable (target) by fitting a linear equation to observed data. It is one of the foundational algorithms in machine learning and statistics, valued for its interpretability and computational simplicity.

### Mathematical Foundation

#### Simple Linear Regression

Models the relationship between a single feature and the target variable.

$$y = \beta_0 + \beta_1 x + \epsilon$$

Where $y$ is the predicted target, $\beta_0$ is the intercept, $\beta_1$ is the coefficient for feature $x$, and $\epsilon$ is the error term.

#### Multiple Linear Regression

Extends the model to multiple features.

$$y = \beta_0 + \beta_1 x_1 + \beta_2 x_2 + \dots + \beta_n x_n + \epsilon$$

In matrix form:

$$y = X\beta + \epsilon$$

### Fitting the Model — Ordinary Least Squares

The most common method for fitting a linear regression model is Ordinary Least Squares (OLS), which finds the coefficients that minimize the sum of squared residuals between predicted and actual values.

$$\hat{\beta} = \arg\min_{\beta} \sum_{i=1}^{n} (y_i - \hat{y}_i)^2$$

The closed-form OLS solution is:

$$\hat{\beta} = (X^T X)^{-1} X^T y$$

**Key Points**

- This closed-form solution is documented in standard statistics and machine learning references as the analytical solution to the least-squares minimization problem.
- Requires $X^T X$ to be invertible; this can fail when features are perfectly collinear (multicollinearity).

### Implementation Example

```python
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, r2_score

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

model = LinearRegression()
model.fit(X_train, y_train)

y_pred = model.predict(X_test)

print("Coefficients:", model.coef_)
print("Intercept:", model.intercept_)
print("R² Score:", r2_score(y_test, y_pred))
print("MSE:", mean_squared_error(y_test, y_pred))
```

**Example**

For a dataset predicting house price from square footage, the model might produce an equation such as:

$$\text{Price} = 50000 + 150 \times \text{SquareFootage}$​

This specific equation is illustrative only. I cannot verify what coefficients would result from any actual dataset without fitting the model directly to that data.

### Assumptions of Linear Regression

[Inference] These assumptions are commonly documented in statistics and machine learning literature as conditions under which OLS estimates have desirable statistical properties (e.g., unbiasedness, minimum variance). The following list reflects standard textbook treatment of the topic rather than a claim I have independently verified through testing.

#### Linearity

The relationship between independent variables and the target is assumed to be linear.

#### Independence of Errors

Residuals (errors) are assumed to be independent of one another, meaning the error for one observation should not predict the error for another.

#### Homoscedasticity

The variance of residuals is assumed to be constant across all levels of the independent variables. Violation of this assumption is referred to as heteroscedasticity.

#### Normality of Residuals

Residuals are assumed to be approximately normally distributed, which is particularly relevant for the validity of hypothesis tests and confidence intervals on coefficients.

#### No Multicollinearity

Independent variables are assumed not to be highly correlated with one another, since severe multicollinearity can make coefficient estimates unstable and difficult to interpret.

### Diagnosing Assumption Violations

```python
import matplotlib.pyplot as plt

residuals = y_test - y_pred

# Residual plot to check homoscedasticity and linearity
plt.scatter(y_pred, residuals)
plt.axhline(y=0, color='r', linestyle='--')
plt.xlabel('Predicted Values')
plt.ylabel('Residuals')
plt.title('Residual Plot')
plt.show()
```

```python
from statsmodels.stats.outliers_influence import variance_inflation_factor

vif_data = pd.DataFrame()
vif_data['feature'] = X.columns
vif_data['VIF'] = [variance_inflation_factor(X.values, i) for i in range(X.shape[1])]
```

**Key Points**

- Variance Inflation Factor (VIF) is a documented, standard statistical measure used to detect multicollinearity; a commonly cited rule of thumb considers VIF values above 5 or 10 as indicating problematic multicollinearity. [Inference] The specific threshold considered "problematic" varies across sources and domains; I cannot verify a single universally correct cutoff value.

### Model Evaluation Metrics

#### Mean Squared Error (MSE)

$$MSE = \frac{1}{n}\sum_{i=1}^{n}(y_i - \hat{y}_i)^2$$

#### Root Mean Squared Error (RMSE)

$$RMSE = \sqrt{MSE}$$

#### Mean Absolute Error (MAE)

$$MAE = \frac{1}{n}\sum_{i=1}^{n}|y_i - \hat{y}_i|$$

#### R-squared (Coefficient of Determination)

$$R^2 = 1 - \frac{\sum_{i=1}^{n}(y_i - \hat{y}_i)^2}{\sum_{i=1}^{n}(y_i - \bar{y})^2}$$

**Key Points**

- $R^2$ represents the proportion of variance in the target variable explained by the model, as documented in standard statistics references.
- A higher $R^2$ does not necessarily indicate a well-specified model; [Inference] R² can increase simply by adding more features to the model regardless of their true relevance, which is why adjusted R² is often used instead for models with multiple features. This reflects standard statistical practice rather than a claim I have independently tested.

#### Adjusted R-squared

$$R^2_{adj} = 1 - \left(1 - R^2\right)\frac{n-1}{n-p-1}$$

Where $n$ is the number of observations and $p$ is the number of predictors.

### Regularized Variants

#### Ridge Regression (L2 Regularization)

Adds a penalty proportional to the square of the coefficients, shrinking them toward zero without eliminating them entirely.

$$\text{Loss} = \sum_{i=1}^{n}(y_i - \hat{y}_i)^2 + \lambda \sum_{j=1}^{p}\beta_j^2$$

```python
from sklearn.linear_model import Ridge

ridge_model = Ridge(alpha=1.0)
ridge_model.fit(X_train, y_train)
```

#### Lasso Regression (L1 Regularization)

Adds a penalty proportional to the absolute value of coefficients, which can shrink some coefficients exactly to zero, performing implicit feature selection.

$$\text{Loss} = \sum_{i=1}^{n}(y_i - \hat{y}_i)^2 + \lambda \sum_{j=1}^{p}|\beta_j|$$

```python
from sklearn.linear_model import Lasso

lasso_model = Lasso(alpha=0.1)
lasso_model.fit(X_train, y_train)
```

#### Elastic Net

Combines L1 and L2 penalties.

$$\text{Loss} = \sum_{i=1}^{n}(y_i - \hat{y}_i)^2 + \lambda_1 \sum_{j=1}^{p}|\beta_j| + \lambda_2 \sum_{j=1}^{p}\beta_j^2$$

```python
from sklearn.linear_model import ElasticNet

elastic_model = ElasticNet(alpha=0.1, l1_ratio=0.5)
elastic_model.fit(X_train, y_train)
```

### Regression Line Illustration

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 400">
<text x="300" y="30" font-size="18" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Linear Regression Fit (svg_diagram)</text>
<line x1="70" y1="340" x2="70" y2="60" stroke="#333" stroke-width="1.5" />
<line x1="70" y1="340" x2="560" y2="340" stroke="#333" stroke-width="1.5" />
<text x="40" y="200" font-size="12" fill="#333" transform="rotate(-90 40 200)">Target (y)</text>
<text x="315" y="375" font-size="12" fill="#333">Feature (x)</text>
<circle cx="120" cy="300" r="4" fill="#4285f4" />
<circle cx="160" cy="270" r="4" fill="#4285f4" />
<circle cx="190" cy="290" r="4" fill="#4285f4" />
<circle cx="230" cy="240" r="4" fill="#4285f4" />
<circle cx="260" cy="220" r="4" fill="#4285f4" />
<circle cx="300" cy="200" r="4" fill="#4285f4" />
<circle cx="330" cy="180" r="4" fill="#4285f4" />
<circle cx="370" cy="170" r="4" fill="#4285f4" />
<circle cx="400" cy="140" r="4" fill="#4285f4" />
<circle cx="440" cy="120" r="4" fill="#4285f4" />
<circle cx="480" cy="100" r="4" fill="#4285f4" />
<line x1="90" y1="310" x2="530" y2="90" stroke="#ea4335" stroke-width="2.5" />
<text x="500" y="80" font-size="12" fill="#ea4335" font-weight="bold">Fitted Line</text>
<line x1="230" y1="240" x2="230" y2="228" stroke="#34a853" stroke-width="1" stroke-dasharray="3,2" />
<text x="235" y="255" font-size="10" fill="#34a853">residual</text>
</svg>

### Advantages and Limitations

**Key Points — Advantages**

- Highly interpretable: coefficients directly indicate the estimated effect of each feature on the target, holding other features constant.
- Computationally efficient, with a closed-form solution available for smaller datasets.
- Well-documented statistical theory supports confidence intervals and hypothesis testing on coefficients.

**Key Points — Limitations**

- Cannot capture non-linear relationships without manual feature engineering (e.g., polynomial features).
- Sensitive to outliers, since the squared error loss function penalizes large residuals disproportionately.
- Performance degrades when core assumptions (linearity, homoscedasticity, independence, no multicollinearity) are substantially violated. [Inference] The degree of performance degradation depends on the severity of the violation and the specific dataset; I do not have access to information that would let me quantify this for a general case.

### Common Pitfalls

- **Ignoring Multicollinearity**: High correlation between features can produce unstable or difficult-to-interpret coefficient estimates.
- **Extrapolation Beyond Training Range**: Predictions for feature values far outside the range seen during training are less reliable, since the model has no evidence about behavior in that region. I cannot verify how a specific model will behave when extrapolating on any given dataset.
- **Ignoring Residual Diagnostics**: Failing to check residual plots can result in an undetected violation of linearity or homoscedasticity assumptions.
- **Overfitting with Excessive Polynomial or Interaction Terms**: Adding many polynomial or interaction terms can improve training fit while degrading generalization to new data.

### Conclusion

Linear regression is a documented, foundational supervised learning method for modeling linear relationships between features and a continuous target variable. Its interpretability and computational simplicity make it a common baseline model, though its assumptions (linearity, homoscedasticity, independence of errors, no severe multicollinearity) must be reasonably satisfied for coefficient estimates and associated statistical inferences to be considered reliable. [Inference] Whether linear regression is an appropriate choice for a specific problem depends on the nature of the relationship between the specific features and target variable in that dataset; I cannot verify this without direct information about that dataset.

### Related Topics

- Regularization techniques (Ridge, Lasso, Elastic Net)
- Polynomial regression for non-linear relationships
- Logistic regression for classification tasks
- Feature scaling and its effect on regularized regression
- Multicollinearity detection and mitigation
- Residual analysis and regression diagnostics
- Gradient descent as an alternative optimization method for large datasets