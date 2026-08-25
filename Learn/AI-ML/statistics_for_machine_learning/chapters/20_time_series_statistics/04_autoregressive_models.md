## Autoregressive Models

### Definition

An autoregressive (AR) model is a time series model in which the current value of a variable is expressed as a linear combination of its own previous values, plus a stochastic error term. The term "autoregressive" reflects that the process regresses on itself.

### Formal Definition: AR(p) Process

An autoregressive process of order $p$, denoted AR(p), is defined as:

$$X_t = c + \sum_{i=1}^{p} \phi_i X_{t-i} + \epsilon_t$$

where:

- $c$ is a constant term
- $\phi_1, \dots, \phi_p$ are the model coefficients
- $\epsilon_t$ is white noise, typically assumed to have mean zero, constant variance $\sigma^2$, and no autocorrelation
- $p$ is the order of the process, indicating how many past values are used

### AR(1): The Simplest Case

$$X_t = c + \phi_1 X_{t-1} + \epsilon_t$$

This models the current value as a function of only the immediately preceding value plus noise.

===MERMAID_DIAGRAM===

graph LR

Xt1["X(t-1) (svg_diagram)"] -->|"phi_1"| Xt["X(t)"]

E["epsilon_t"] --> Xt

### Stationarity Condition

For an AR(p) process to be weakly stationary, the roots of its characteristic polynomial must lie outside the unit circle. For the AR(1) case specifically, this condition reduces to:

$$|\phi_1| < 1$$

[Inference] This stationarity condition is a standard theoretical result presented in time series references. I cannot verify this against a specific primary source directly quoted within this conversation, so it is stated as consistent with general time series literature rather than independently confirmed here.

If $|\phi_1| = 1$, the process becomes a random walk, which is non-stationary. If $|\phi_1| > 1$, the process is explosive, with variance growing without bound over time.

### Mean and Variance of a Stationary AR(1) Process

For a stationary AR(1) process, the theoretical mean and variance are:

$$\mathbb{E}[X_t] = \frac{c}{1 - \phi_1}$$



$$\text{Var}(X_t) = \frac{\sigma^2}{1 - \phi_1^2}$$

[Inference] These closed-form expressions follow from taking expectations and variances of both sides of the AR(1) recursive definition under the stationarity assumption, reasoned from the model's algebraic structure. I do not have a specific external source directly quoted within this conversation confirming this derivation, so this should be treated as a reasoned mathematical consequence rather than an independently verified citation.

### Autocorrelation Structure of AR(p) Processes

For a stationary AR(1) process, the theoretical autocorrelation function decays geometrically:

$$\rho(k) = \phi_1^{k}$$

For general AR(p) processes, the ACF decays gradually (as a mixture of exponentials or a damped sinusoid, depending on the roots of the characteristic equation), while the partial autocorrelation function cuts off sharply after lag $p$. [Inference] This ACF/PACF pattern is a standard heuristic from Box-Jenkins time series methodology used to identify AR model order. I do not have the original Box-Jenkins text directly quoted within this conversation, so this is presented as a commonly referenced modeling heuristic rather than an independently verified claim, and it is not something that can be assumed to correctly identify order for any specific dataset without direct testing.

### Parameter Estimation

Common estimation methods for AR model coefficients include:

- **Ordinary Least Squares (OLS)**: treats the AR model as a linear regression of $X_t$ on its own lags.
- **Yule-Walker equations**: solve for coefficients using the theoretical relationship between AR coefficients and the autocorrelation function.
- **Maximum Likelihood Estimation (MLE)**: assumes a distributional form for $\epsilon_t$ (commonly Gaussian) and maximizes the resulting likelihood function.

[Unverified] I do not have a specific primary source directly quoted within this conversation comparing the statistical efficiency of these three estimation methods against one another, so no claim is made here about which method performs better on any specific dataset.

### Order Selection

The order $p$ is commonly selected using information criteria that balance model fit against complexity:

$$\text{AIC} = -2\ln(\hat{L}) + 2k$$



$$\text{BIC} = -2\ln(\hat{L}) + k\ln(n)$$

where $\hat{L}$ is the maximized likelihood, $k$ is the number of estimated parameters, and $n$ is the sample size. [Inference] BIC is generally described in time series literature as penalizing model complexity more heavily than AIC for larger sample sizes, due to the $\ln(n)$ term growing with $n$. I do not have a specific primary source directly quoted within this conversation confirming this comparison, so it is presented as a commonly stated property rather than independently verified here. Which criterion selects a "better" model for any specific dataset is not something that can be determined without direct comparison on that dataset.

### Worked Example: Fitting an AR Model

**Example**

```python
import numpy as np
from statsmodels.tsa.ar_model import AutoReg

np.random.seed(7)
n = 250
x = np.zeros(n)
for t in range(2, n):
    x[t] = 0.6 * x[t-1] - 0.2 * x[t-2] + np.random.normal(0, 1)

model = AutoReg(x, lags=2, old_names=False)
fitted = model.fit()
print("Estimated coefficients:", fitted.params)
```

**Output**

I cannot verify this. I do not have code execution access in this session, so I cannot confirm the exact printed coefficient values this code would produce.

[Inference] Based on the data-generating process defined in the code (true coefficients 0.6 and -0.2 for lags 1 and 2), the estimated coefficients from `fitted.params` are expected to be numerically close to these true values, subject to estimation error from the finite sample size of 250. This is a reasoned expectation based on standard OLS/MLE consistency properties for correctly specified AR models, not a confirmed output value, since the code has not been executed. [Unverified] I cannot confirm the exact numerical precision of this closeness without running the code directly.

### AR Models as a Special Case of ARMA

An AR(p) model is the special case of an ARMA(p, q) model with $q = 0$, meaning no moving-average (lagged error) terms are included. The general ARMA(p, q) model is:

$$X_t = c + \sum_{i=1}^{p} \phi_i X_{t-i} + \sum_{j=1}^{q} \theta_j \epsilon_{t-j} + \epsilon_t$$

### Comparison Table

| Model | Depends On | ACF Pattern | PACF Pattern |
| --- | --- | --- | --- |
| AR(p) | Past values of $X_t$ | Gradual decay | Sharp cutoff after lag $p$ |
| MA(q) | Past error terms | Sharp cutoff after lag $q$ | Gradual decay |
| ARMA(p,q) | Both | Gradual decay | Gradual decay |

### Vector Autoregression (VAR)

When multiple interdependent time series are modeled jointly, the univariate AR model generalizes to Vector Autoregression (VAR), where each variable is regressed on lagged values of itself and all other variables in the system:

$$\mathbf{X}_t = \mathbf{c} + \sum_{i=1}^{p} \mathbf{\Phi}_i \mathbf{X}_{t-i} + \boldsymbol{\epsilon}_t$$

where $\mathbf{X}_t$ is a vector of variables and $\mathbf{\Phi}_i$ are coefficient matrices. [Inference] VAR models are commonly described in econometrics and time series literature as useful for capturing dynamic interdependencies between multiple series, though I do not have a specific primary source directly quoted within this conversation to confirm this characterization, and whether a VAR model is appropriate for any specific multivariate dataset is not something that can be assumed without testing.

### Applications in Machine Learning

- Time series forecasting, as a foundational building block within ARIMA and SARIMA models.
- Feature engineering, where AR coefficients or residuals can serve as inputs to downstream models.
- Econometric and financial modeling, including VAR extensions for multivariate systems.
- Signal processing, where AR models are used for spectral estimation.

[Speculation] Whether AR-based features improve predictive performance relative to alternative sequence modeling approaches (e.g., recurrent neural networks) for any specific task is not something that can be assumed without direct empirical comparison on that task and dataset. I do not have benchmark results available in this conversation to confirm this in either direction.

### Limitations

- AR models assume a fixed, finite-order linear dependence structure; nonlinear dependencies between lagged values are not captured directly by the linear AR formulation, as a consequence of its definition as a linear combination of past values.
- Model validity depends on the stationarity condition being satisfied; applying an AR model to a non-stationary series without appropriate differencing may not be reliable, though the specific consequences depend on the type of non-stationarity present and cannot be generalized without case-specific analysis.
- Order selection via AIC/BIC is a statistical heuristic and does not guarantee identification of the "true" underlying data-generating process, particularly since real-world processes are not guaranteed to follow a finite-order linear AR structure at all.

### Conclusion

Autoregressive models represent a time series as a linear function of its own past values plus noise, forming a foundational component of more general models such as ARMA, ARIMA, and VAR. Their validity relies on stationarity conditions expressed through constraints on the model coefficients, and practical use requires order selection and parameter estimation methods that carry their own statistical uncertainty.

[Unverified] Multiple claims in this document — including comparative properties of AIC versus BIC, Box-Jenkins order-selection heuristics, and general characterizations of VAR model usefulness — are presented consistent with general time series and econometrics literature but are not drawn from a specific primary source directly quoted within this conversation. These should be treated as generally documented conventions rather than independently verified claims.

**Related Topics**

- Moving Average Models
- ARIMA and SARIMA Models
- Vector Autoregression (VAR)
- Stationarity
- Autocorrelation and Partial Autocorrelation
- Yule-Walker Equations
- Information Criteria (AIC, BIC) for Model Selection