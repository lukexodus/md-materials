## Stationarity

### Definition

Stationarity is a property of a stochastic process describing whether its statistical characteristics remain constant over time. A process is stationary if its joint probability distribution, or a subset of its moments, does not change when shifted in time.

### Strict Stationarity

A stochastic process $\{X_t\}$ is strictly stationary if, for any set of time indices $t_1, \dots, t_k$ and any shift $\tau$, the joint distribution of $(X_{t_1}, \dots, X_{t_k})$ is identical to the joint distribution of $(X_{t_1+\tau}, \dots, X_{t_k+\tau})$:

$$F_{X_{t_1}, \dots, X_{t_k}}(x_1, \dots, x_k) = F_{X_{t_1+\tau}, \dots, X_{t_k+\tau}}(x_1, \dots, x_k)$$

for all $k$, all time indices, and all $\tau$. This is a condition on the entire joint distribution, not merely on a finite set of moments.

### Weak (Second-Order) Stationarity

A weaker and more commonly used condition requires only that the first two moments be time-invariant:

$$\mathbb{E}[X_t] = \mu \quad \text{(constant mean)}$$



$$\text{Cov}(X_t, X_{t+\tau}) = \gamma(\tau) \quad \text{(covariance depends only on lag } \tau\text{, not on } t\text{)}$$



$$\text{Var}(X_t) = \gamma(0) < \infty \quad \text{(finite, constant variance)}$$

Weak stationarity is sometimes called second-order or covariance stationarity. [Inference] Strict stationarity implies weak stationarity only when the first two moments exist and are finite; a process can satisfy weak stationarity without satisfying strict stationarity, and the two conditions are not equivalent in general. This relationship follows from the formal definitions of each condition rather than from a specific external source I can cite here.

### Visualizing Stationary vs. Non-Stationary Processes

===MERMAID_DIAGRAM===

graph TD

A["Stochastic Process (svg_diagram)"] --> B["Constant Mean and Variance Over Time"]

A --> C["Changing Mean or Variance Over Time"]

B --> D["Stationary"]

C --> E["Non-Stationary"]

style D fill:#2d5,stroke:#333

style E fill:#a33,stroke:#333

### Autocovariance and Autocorrelation Under Stationarity

For a weakly stationary process, the autocovariance function depends only on the lag $\tau$ between two time points, not on the absolute time position:

$$\gamma(\tau) = \text{Cov}(X_t, X_{t+\tau})$$

The autocorrelation function (ACF) normalizes this by the variance:

$$\rho(\tau) = \frac{\gamma(\tau)}{\gamma(0)}$$

This lag-only dependence is what allows autocovariance and autocorrelation to be estimated from a single observed time series, since it permits pooling information across different time origins that share the same lag.

### Why Stationarity Matters in Machine Learning

Many statistical and machine learning methods applied to sequential or time-dependent data assume some form of stationarity, including classical time series models such as ARMA and ARIMA (in their differenced form), and certain assumptions underlying cross-validation schemes for time series. [Inference] When the assumption of stationarity does not hold for a given dataset, model estimates and forecasts produced by methods that rely on that assumption may not behave as expected, though the specific consequences depend on the type and degree of non-stationarity present and cannot be stated in general without reference to a specific model and dataset. I do not have a verified source in this conversation to cite for quantified degradation figures.

### Testing for Stationarity

**Augmented Dickey-Fuller (ADF) test**: tests the null hypothesis that a unit root is present (indicating non-stationarity) against the alternative of stationarity.

**KPSS test**: tests the null hypothesis of stationarity against the alternative of a unit root, structured in the opposite direction from the ADF test.

[Inference] Because these two tests have opposing null hypotheses, they are sometimes used together, where agreement between both test outcomes is treated as stronger evidence than either test alone. This is a commonly described practice in applied time series literature, but I do not have a specific primary source available in this conversation to quote directly on this point, and I cannot verify how often this combined approach is used in practice.

### Example: ADF Test in Python

**Example**

```python
import numpy as np
from statsmodels.tsa.stattools import adfuller

np.random.seed(0)
stationary_series = np.random.normal(0, 1, 200)
trend_series = np.cumsum(np.random.normal(0, 1, 200))

result_stationary = adfuller(stationary_series)
result_trend = adfuller(trend_series)

print("Stationary series ADF p-value:", result_stationary[1])
print("Trend series ADF p-value:", result_trend[1])
```

**Output**

I cannot verify this. I do not have execution access in this session, so I cannot confirm the exact printed p-values.

[Inference] Based on the construction of the data — `stationary_series` drawn i.i.d. from a fixed-parameter normal distribution, and `trend_series` constructed as a cumulative sum (a random walk, a canonical non-stationary process) — the ADF test is expected to report a low p-value for `stationary_series` (rejecting the unit-root null) and a high p-value for `trend_series` (failing to reject the unit-root null). This is a reasoned expectation based on the known theoretical properties of i.i.d. noise versus random walks, not a confirmed output value, since I have not executed this code.

### Non-Stationarity: Common Forms

- **Trend**: a systematic, long-term increase or decrease in the mean over time.
- **Seasonality**: regular, periodic fluctuations tied to a fixed period (e.g., daily, yearly).
- **Changing variance (heteroscedasticity)**: the spread of the process changes over time, as seen in volatility clustering in financial time series.
- **Structural breaks**: abrupt shifts in the underlying process parameters at specific points in time.

### Transformations to Induce Stationarity

- **Differencing**: replacing $X_t$ with $X_t - X_{t-1}$, commonly used to remove linear trends and is the basis of the "I" (integrated) component in ARIMA models.
- **Log transformation**: applied to stabilize variance when the process exhibits multiplicative rather than additive fluctuations.
- **Seasonal differencing**: subtracting the value from the same point in the previous seasonal cycle, to remove periodic patterns.

[Inference] Whether a given transformation successfully induces stationarity in a specific dataset is not something that can be assumed; it must be checked, for example using ADF or KPSS tests, after applying the transformation, rather than assumed to hold automatically as a property of the transformation method itself.

### Stationarity in Markov Chains

A distinct but related usage of "stationary" applies to Markov chains: a stationary distribution $\pi$ is a probability distribution over states that remains unchanged under the transition dynamics:

$$\pi = \pi P$$

where $P$ is the transition matrix. This is a different concept from stationarity of a time series' statistical moments, though both use the term "stationary" to describe a form of invariance under a time-evolution or transition operation. [Unverified] I do not have a specific primary source available in this conversation to confirm the historical relationship, if any, between the two uses of this term, so I am not asserting one term derives from the other.

### Applications in Machine Learning

- Time series forecasting models (ARIMA, SARIMA), which generally assume stationarity of the series after differencing.
- Reinforcement learning, where stationary transition dynamics or stationary policies are often assumed in convergence analyses of certain algorithms.
- Signal processing and spectral analysis, where stationarity assumptions underlie the applicability of Fourier-based spectral density estimation.
- Anomaly detection, where deviations from an assumed stationary baseline can be used as a detection signal.

[Speculation] Whether a specific deployed anomaly detection system relies on a stationarity assumption, and how it behaves when that assumption is violated, would depend on that system's specific design; I do not have information about any particular system's implementation to confirm this, so this is an unconfirmed possibility rather than an established fact.

### Limitations

- Real-world data-generating processes are not guaranteed to satisfy stationarity, and testing for it (via ADF, KPSS, or similar) provides statistical evidence rather than certainty, since these tests operate under their own modeling assumptions and are subject to finite-sample error.
- Transformations intended to induce stationarity (differencing, log transforms) do not automatically succeed for every dataset; success must be verified rather than assumed.
- Models built on a stationarity assumption may produce unreliable forecasts if applied to data that violates that assumption, though the specific nature and severity of unreliability depends on the model and the type of non-stationarity present, and cannot be generalized without case-specific analysis.

### Conclusion

Stationarity describes the invariance of a stochastic process's statistical properties over time, ranging from the strict form (invariance of the full joint distribution) to the weaker and more commonly applied second-order form (constant mean, constant variance, lag-dependent covariance). It underlies key assumptions in time series modeling, certain reinforcement learning convergence results, and spectral analysis methods, and its presence or absence in real data must be assessed using statistical tests rather than assumed.

[Unverified] Several claims in this document regarding common practices in applied time series literature (e.g., combined use of ADF and KPSS tests) are stated consistent with general literature descriptions but are not drawn from a specific primary source directly quoted within this conversation.

**Related Topics**

- Autocorrelation and Autocovariance Functions
- ARIMA and SARIMA Models
- Markov Chains and Stationary Distributions
- Augmented Dickey-Fuller and KPSS Tests
- Heteroscedasticity and Volatility Modeling
- Spectral Density Estimation
- Reinforcement Learning: Stationary vs. Non-Stationary Environments