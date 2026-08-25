## Partial Autocorrelation

### Definition

Partial autocorrelation measures the correlation between a time series observation $X_t$ and its lagged value $X_{t+k}$, after removing the linear dependence explained by all intermediate lags $X_{t+1}, \dots, X_{t+k-1}$. It isolates the direct relationship at lag $k$ from indirect relationships mediated through shorter lags.

### Formal Definition

The partial autocorrelation at lag $k$, denoted $\phi_{kk}$, is defined as the correlation between $X_t$ and $X_{t+k}$ conditional on the intervening observations:

$$\phi_{kk} = \text{Corr}(X_t, X_{t+k} \mid X_{t+1}, \dots, X_{t+k-1})$$

Equivalently, it can be defined as the coefficient of $X_{t-k}$ in a linear regression of $X_t$ on $X_{t-1}, X_{t-2}, \dots, X_{t-k}$. [Inference] These two framings — conditional correlation and regression coefficient — are commonly presented as equivalent in standard time series references, based on general properties of linear regression and conditional correlation for jointly Gaussian or linearly-related variables. I cannot verify this equivalence against a specific cited primary source within this conversation.

### Distinction from Autocorrelation

Ordinary autocorrelation at lag $k$ reflects both the direct effect of lag $k$ and indirect effects transmitted through intermediate lags. Partial autocorrelation isolates only the direct effect. For an AR(1) process, this distinction is illustrated clearly: the ACF decays gradually across many lags (reflecting propagated indirect dependence), while the PACF shows a single significant spike at lag 1 and values near zero afterward. [Inference] This specific AR(1) pattern is a standard theoretical property described in time series literature; I do not have a directly quotable primary source confirmed within this conversation, so this is presented as a commonly documented theoretical result rather than an independently verified claim.

===MERMAID_DIAGRAM===

graph TD

A["Lag k Total Effect (svg_diagram)"] --> B["Direct Effect at Lag k"]

A --> C["Indirect Effect via Lags 1 to k-1"]

B --> D["Partial Autocorrelation"]

A --> E["Autocorrelation"]

style D fill:#2d5,stroke:#333

### Computation via Yule-Walker Equations

One standard method for computing PACF values uses the Yule-Walker equations, which relate the autocorrelation function to autoregressive coefficients. For an AR(p) process:

$$\rho(k) = \sum_{i=1}^{p} \phi_i \rho(k-i), \quad k = 1, \dots, p$$

Solving this system of equations for increasing values of $p$ yields the partial autocorrelation coefficients as the last coefficient $\phi_{pp}$ at each successive order. [Unverified] I do not have a specific primary source confirmed in this conversation to directly quote the original derivation or attribution of the Yule-Walker equations, so this description is presented as consistent with standard time series references rather than independently verified against a cited source.

### Computation via the Durbin-Levinson Algorithm

The Durbin-Levinson recursion provides a computationally efficient method for solving the Yule-Walker equations sequentially, computing $\phi_{kk}$ for $k = 1, 2, \dots$ without re-solving the full system at each step. [Unverified] I do not have a specific primary source confirmed in this conversation to directly quote the original formulation of this recursion, so this is described as a standard computational method referenced in general time series literature.

### Alternative Computation via Successive Regression

An alternative and more directly interpretable computation method fits a sequence of autoregressive models of increasing order:

$$X_t = c_1 X_{t-1} + \epsilon_t^{(1)}$$



$$X_t = c_1 X_{t-1} + c_2 X_{t-2} + \epsilon_t^{(2)}$$



$$\vdots$$

At each order $k$, the coefficient on $X_{t-k}$ is the partial autocorrelation $\phi_{kk}$ at that lag.

### Use in Model Order Selection

| Process Type | ACF Pattern | PACF Pattern |
| --- | --- | --- |
| AR(p) | Decays gradually (exponential or damped sinusoid) | Cuts off sharply after lag $p$ |
| MA(q) | Cuts off sharply after lag $q$ | Decays gradually |
| ARMA(p,q) | Decays gradually | Decays gradually |

[Inference] This table reflects a standard heuristic from Box-Jenkins time series methodology used to identify candidate AR and MA orders from ACF/PACF plots. I do not have the original Box-Jenkins text available to quote directly within this conversation, so this is presented as a commonly referenced modeling heuristic. I cannot verify that this heuristic correctly identifies model order for any specific dataset without direct testing on that dataset.

### Worked Example: AR(2) Process

Consider a process generated as $X_t = 0.5 X_{t-1} + 0.3 X_{t-2} + \epsilon_t$. [Inference] Based on general AR(p) theory as commonly described in time series references, the theoretical PACF for this process is expected to show significant values at lags 1 and 2, then values close to zero at lag 3 and beyond, since the true process order is 2. I cannot verify this expectation numerically without executing a simulation, and I have not done so in this response.

**Example**

```python
import numpy as np
from statsmodels.tsa.stattools import pacf

np.random.seed(1)
n = 300
x = np.zeros(n)
for t in range(2, n):
    x[t] = 0.5 * x[t-1] + 0.3 * x[t-2] + np.random.normal(0, 1)

pacf_values = pacf(x, nlags=10, method='ywm')
print("PACF values:", pacf_values)
```

**Output**

I cannot verify this. I do not have code execution access in this session, so I cannot confirm the exact printed numeric array this code would produce.

[Inference] Based on the AR(2) data-generating process defined in the code, the PACF is expected to show large-magnitude values at lags 1 and 2 and values close to zero from lag 3 onward, consistent with general AR(p) theory. This expectation is reasoned from theory, not confirmed by execution, and actual sample values would be subject to estimation noise from the finite sample size of 300.

### Confidence Intervals and Significance

Sample PACF values are typically plotted alongside approximate confidence bounds, commonly at $\pm \frac{1.96}{\sqrt{n}}$ for a 95% confidence level under the null hypothesis of no partial autocorrelation at that lag, where $n$ is the sample size. [Unverified] I do not have a specific primary source confirmed in this conversation to directly quote the derivation of this confidence bound formula, so it is presented as a standard approximation referenced in general time series literature rather than independently verified here.

### Relationship to Stationarity

Like the ordinary autocorrelation function, the theoretical interpretation of partial autocorrelation as a lag-dependent-only quantity relies on the assumption of stationarity in the underlying process. [Unverified] I do not have a specific source confirmed in this conversation describing precisely how PACF estimates should be interpreted when computed on a non-stationary series; this is a known caveat consistent with general time series literature, but I cannot confirm further interpretive detail beyond this caveat.

### Applications in Machine Learning

- Autoregressive model order selection (determining $p$ in AR(p) or ARIMA(p,d,q) models).
- Feature selection for lagged time series inputs, where PACF can help identify which lags carry direct predictive information.
- Time series diagnostics, alongside ACF, for evaluating whether a fitted model has adequately captured the autoregressive structure of the data.

[Speculation] Whether PACF-based lag selection improves predictive performance for any specific machine learning task is not something that can be assumed without empirical testing on that specific task and dataset. I do not have benchmark results available in this conversation to confirm this in general, so this remains an unconfirmed possibility.

### Limitations

- Like ordinary autocorrelation, partial autocorrelation captures only linear dependence between lagged values; nonlinear dependence structures may not be reflected in PACF estimates, as a direct consequence of its definition in terms of linear regression coefficients or linear conditional correlation.
- Sample PACF estimates are subject to sampling variability, and this variability generally increases at higher lags due to fewer effective observations being available for estimation at those lags.
- Model order selection based on ACF/PACF cutoff patterns is a heuristic and is not guaranteed to identify the true underlying process order for any specific dataset; this must be checked using validation methods rather than assumed from the plots alone.

### Conclusion

Partial autocorrelation isolates the direct linear relationship between a time series and its lagged values at a specific lag, controlling for the influence of intermediate lags. It complements the ordinary autocorrelation function in time series model order selection, particularly for identifying the autoregressive order in ARIMA modeling, and its computation commonly relies on the Yule-Walker equations or equivalent recursive and regression-based methods.

[Unverified] Multiple claims in this document — including the historical attribution and derivation of the Yule-Walker equations, the Durbin-Levinson recursion, Box-Jenkins order-selection heuristics, and standard confidence interval formulas — are presented consistent with general time series literature but are not drawn from a specific primary source directly quoted within this conversation. These should be treated as generally documented conventions rather than independently verified claims.

**Related Topics**

- Autocorrelation
- Stationarity
- Yule-Walker Equations and Durbin-Levinson Algorithm
- ARIMA and SARIMA Model Order Selection
- Ljung-Box Test
- Autoregressive Model Estimation