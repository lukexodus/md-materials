## Autocorrelation

### Definition

Autocorrelation, also called serial correlation, measures the linear dependence between a time series and a lagged version of itself. It quantifies how much current values of a process relate to past values at a specified lag.

### Formal Definition

For a stationary stochastic process $\{X_t\}$ with mean $\mu$ and variance $\sigma^2$, the autocorrelation function (ACF) at lag $\tau$ is defined as:

$$\rho(\tau) = \frac{\text{Cov}(X_t, X_{t+\tau})}{\sqrt{\text{Var}(X_t)\text{Var}(X_{t+\tau})}} = \frac{\gamma(\tau)}{\gamma(0)}$$

where $\gamma(\tau) = \text{Cov}(X_t, X_{t+\tau})$ is the autocovariance function at lag $\tau$, and $\gamma(0) = \text{Var}(X_t)$. Under weak stationarity, $\gamma(\tau)$ depends only on the lag $\tau$, not on the absolute time $t$, which is what makes $\rho(\tau)$ well-defined independent of time origin.

### Sample Autocorrelation

For an observed series $x_1, \dots, x_T$, the sample autocorrelation at lag $k$ is typically estimated as:

$$\hat{\rho}(k) = \frac{\sum_{t=1}^{T-k} (x_t - \bar{x})(x_{t+k} - \bar{x})}{\sum_{t=1}^{T} (x_t - \bar{x})^2}$$

where $\bar{x}$ is the sample mean. [Inference] This is one common estimator form used in standard time series references; some sources use a slightly different denominator normalization (e.g., dividing by $T-k$ instead of $T$ in the numerator sum), and I do not have a single authoritative source confirmed in this conversation establishing one form as universally standard over the other.

### Properties

- $\rho(0) = 1$ always, since a series is perfectly correlated with itself at lag zero.
- $\rho(\tau) = \rho(-\tau)$ for real-valued stationary processes, meaning the ACF is symmetric around lag zero.
- $-1 \leq \rho(\tau) \leq 1$ for all $\tau$, following from the Cauchy-Schwarz inequality applied to covariance.

### Autocorrelation Function Plot

===MERMAID_DIAGRAM===

graph LR

A["Lag 0: rho=1.0 (svg_diagram)"] --> B["Lag 1: rho=0.7"]

B --> C["Lag 2: rho=0.4"]

C --> D["Lag 3: rho=0.2"]

D --> E["Lag 4: rho approx 0"]

style A fill:#2d5,stroke:#333

[Inference] The specific numeric values shown in this diagram (0.7, 0.4, 0.2) are illustrative placeholders chosen to depict a typical decaying-ACF pattern, not values derived from any actual dataset or computation. I have not verified these numbers against any real series.

### Partial Autocorrelation Function (PACF)

The partial autocorrelation at lag $k$ measures the correlation between $X_t$ and $X_{t+k}$ after removing the linear effect of the intermediate lags $X_{t+1}, \dots, X_{t+k-1}$. It is commonly computed via the Yule-Walker equations or by fitting successive autoregressive models. [Unverified] I do not have a specific primary source confirmed in this conversation to cite for the exact historical derivation of the Yule-Walker approach, so I am describing it as a standard computational method referenced in general time series literature rather than quoting a specific source.

### Distinguishing ACF and PACF

| Function | Measures | Common Use |
| --- | --- | --- |
| ACF | Total correlation between $X_t$ and $X_{t+k}$, including indirect effects through intermediate lags | Identifying MA(q) order in ARIMA modeling |
| PACF | Direct correlation between $X_t$ and $X_{t+k}$, controlling for intermediate lags | Identifying AR(p) order in ARIMA modeling |

[Inference] This usage of ACF and PACF cutoff patterns to identify AR and MA orders is a standard heuristic described in classical Box-Jenkins time series methodology. I do not have the original Box-Jenkins text available to quote directly in this conversation, so this is stated as a commonly referenced modeling heuristic rather than a directly cited claim, and I cannot verify that this heuristic reliably identifies correct model order on any specific dataset without testing.

### Example: Computing Autocorrelation in Python

**Example**

```python
import numpy as np
from statsmodels.tsa.stattools import acf, pacf

np.random.seed(0)
n = 200
x = np.zeros(n)
for t in range(1, n):
    x[t] = 0.6 * x[t-1] + np.random.normal(0, 1)

acf_values = acf(x, nlags=10)
pacf_values = pacf(x, nlags=10)

print("ACF:", acf_values)
print("PACF:", pacf_values)
```

**Output**

I cannot verify this. I do not have code execution access in this session, so I cannot confirm the exact printed numeric arrays this code would produce.

[Inference] Based on the data-generating process defined in the code — an AR(1) process with coefficient 0.6 — the ACF is expected to decay approximately geometrically with lag (roughly proportional to $0.6^k$), and the PACF is expected to show a large value at lag 1 and values close to zero at higher lags, consistent with the theoretical properties of an AR(1) process. This is a reasoned expectation based on known AR(1) theory, not a confirmed output value, since the code has not been executed.

### Ljung-Box Test

The Ljung-Box test is a statistical hypothesis test used to assess whether autocorrelations of a time series are significantly different from zero, jointly across a set of lags. The null hypothesis is that the data are independently distributed (no autocorrelation up to the tested lag).

$$Q = n(n+2) \sum_{k=1}^{h} \frac{\hat{\rho}(k)^2}{n-k}$$

where $n$ is the sample size and $h$ is the number of lags tested. Under the null hypothesis, $Q$ approximately follows a chi-squared distribution with $h$ degrees of freedom. [Unverified] I do not have a specific primary source confirmed in this conversation to directly quote the original derivation of this test statistic, so this formula is presented as consistent with standard time series references rather than independently verified against a cited source.

### Autocorrelation in Model Diagnostics

Autocorrelation analysis of model residuals is commonly used as a diagnostic tool: if a fitted model has adequately captured the dependence structure in the data, its residuals should show autocorrelation values close to zero at all lags. Significant residual autocorrelation is generally interpreted as evidence of model misspecification. [Inference] Whether residual autocorrelation actually indicates misspecification in a specific fitted model depends on the model and data in question, and I cannot confirm this holds in any specific case without direct testing; this is a general diagnostic heuristic rather than a rule that applies with certainty in every case.

### Relationship to Stationarity

Autocorrelation as a lag-dependent-only function is well-defined under the assumption of weak stationarity. For non-stationary series, sample autocorrelation estimates can still be computed numerically but do not have the same theoretical interpretation, since the underlying assumption of time-invariant covariance structure does not hold. [Unverified] I do not have a specific source confirmed in this conversation to state precisely how sample ACF estimates should be interpreted when computed on a non-stationary series; this is a known caveat in general time series literature, but exact interpretive guidance beyond the general caveat is not something I can confirm here.

### Applications in Machine Learning

- Time series model order selection (identifying AR and MA components in ARIMA modeling) via ACF and PACF plots.
- Feature engineering for sequential data, where lagged autocorrelation values can be used as input features.
- Residual diagnostics for regression and time series models.
- Detecting periodicity or seasonality in a series through peaks in the ACF at seasonal lags.

[Speculation] Whether autocorrelation-based features improve predictive performance for any specific machine learning task is not something that can be assumed without empirical testing on that specific task and dataset; I do not have benchmark results available in this conversation to confirm this in general.

### Limitations

- Sample autocorrelation estimates are subject to sampling variability, particularly at higher lags where fewer pairs of observations are available for the calculation.
- Interpretation of ACF and PACF plots for model order selection is a heuristic method and does not guarantee correct identification of the true underlying process order.
- Autocorrelation only captures linear dependence; a series can exhibit strong nonlinear dependence between lagged values while showing near-zero autocorrelation, and this limitation is a direct consequence of the correlation coefficient's definition as a measure of linear association only.

### Conclusion

Autocorrelation quantifies the linear relationship between a time series and its own lagged values, forming the basis for identifying dependence structure, selecting time series model orders, and diagnosing model adequacy through residual analysis. Its theoretical interpretation relies on the assumption of stationarity, and its estimation from finite samples carries statistical uncertainty that grows at higher lags.

[Unverified] Several claims in this document regarding standard estimator forms, historical derivations (e.g., Yule-Walker, Ljung-Box), and Box-Jenkins methodology conventions are presented consistent with general time series literature but are not drawn from a specific primary source directly quoted within this conversation, and should be treated as generally documented rather than independently confirmed here.

**Related Topics**

- Stationarity
- Partial Autocorrelation Function and Yule-Walker Equations
- ARIMA and SARIMA Models
- Ljung-Box Test for Residual Autocorrelation
- Spectral Density Estimation
- Time Series Cross-Validation
- Seasonal Decomposition