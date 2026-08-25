## Module 2: ARIMA Models


### 2.1 Autoregressive (AR) Models

#### 2.1.1 AR Model Definition

- AR(p): y_t = c + φ_1y_{t-1} + ... + φ_py_{t-p} + ε_t
- Order p selection
- Stationarity conditions: characteristic equation roots
- Mean and variance derivation
- Yule-Walker equations

#### 2.1.2 AR Model Properties

- ACF: exponential decay or damped sine wave
- PACF: cuts off after lag p
- Model identification strategy
- Partial autocorrelations for order selection
- [Inference] Long-memory behavior

#### 2.1.3 Estimation Methods

- Least squares estimation
- Maximum likelihood estimation (MLE)
- Conditional vs unconditional likelihood
- Yule-Walker estimation
- Standard errors and inference

### 2.2 Moving Average (MA) Models

#### 2.2.1 MA Model Definition

- MA(q): y_t = μ + ε_t + θ_1ε_{t-1} + ... + θ_qε_{t-q}
- Order q selection
- Invertibility conditions: characteristic equation
- White noise process: ε_t ~ WN(0, σ²)
- Always stationary property

#### 2.2.2 MA Model Properties

- ACF: cuts off after lag q
- PACF: exponential decay or damped sine wave
- Model identification using ACF
- Duality with AR models (invertibility)
- Forecasting implications

#### 2.2.3 Estimation Challenges

- Nonlinear optimization required
- MLE via Kalman filter
- Conditional sum of squares
- Numerical optimization algorithms
- Starting value selection

### 2.3 ARMA Models

#### 2.3.1 ARMA(p,q) Specification

- Combined AR and MA terms
- Notation: φ(B)y_t = θ(B)ε_t
- Backshift operator: B^k y_t = y_{t-k}
- Polynomial representation
- Parsimony principle

#### 2.3.2 Model Identification

- Box-Jenkins methodology
- ACF and PACF joint examination
- Information criteria: AIC, BIC, AICc
- Overfitting vs underfitting
- Principle of parsimony

#### 2.3.3 Properties & Estimation

- Stationarity and invertibility conditions
- Moment matching for initialization
- Maximum likelihood estimation
- Hannan-Rissanen algorithm
- Model diagnostics

### 2.4 Integrated Models: ARIMA

#### 2.4.1 ARIMA(p,d,q) Framework

- Integration order d: number of differences
- Notation: ARIMA(p,d,q)
- Non-stationary series handling
- Unit root accommodation
- Differencing vs detrending

#### 2.4.2 Special Cases

- ARIMA(0,1,0): random walk
- ARIMA(0,1,1): exponential smoothing equivalent
- ARIMA(0,2,2): linear trend with drift
- IMA models: integrated moving average
- [Relationship] Connection to exponential smoothing

#### 2.4.3 Model Selection Process

1. Stationarity assessment and differencing
2. ACF/PACF examination
3. Candidate model specification
4. Parameter estimation
5. Diagnostic checking
6. Forecasting and evaluation

### 2.5 Seasonal ARIMA (SARIMA)

#### 2.5.1 SARIMA(p,d,q)(P,D,Q)_s Notation

- Seasonal period s (e.g., 12 for monthly, 7 for daily)
- Seasonal AR: Φ(B^s) operator
- Seasonal MA: Θ(B^s) operator
- Seasonal differencing: (1-B^s)^D
- Combined seasonal and non-seasonal terms

#### 2.5.2 Model Structure

- Multiplicative seasonal model
- Seasonal and non-seasonal components interaction
- Example: SARIMA(1,1,1)(1,1,1)_12
- Additive vs multiplicative seasonality
- Seasonal unit root testing

#### 2.5.3 Identification Strategy

- Seasonal ACF/PACF patterns
- Seasonal differences examination
- Information criteria with seasonality
- Computational complexity considerations
- Auto.arima algorithms

### 2.6 ARIMA Estimation & Diagnostics

#### 2.6.1 Parameter Estimation

- Maximum likelihood via Kalman filter
- Conditional sum of squares (CSS)
- CSS-MLE: hybrid approach
- Optimization algorithms: BFGS, Nelder-Mead
- Standard error computation

#### 2.6.2 Model Diagnostics

- Residual analysis: ACF of residuals
- Ljung-Box test: joint significance of autocorrelations
- Normality tests: Jarque-Bera, Shapiro-Wilk
- Heteroscedasticity tests: ARCH effects
- Residual plots: patterns indicate misspecification

#### 2.6.3 Model Comparison

- AIC: Akaike Information Criterion
- BIC: Bayesian Information Criterion (stronger penalty)
- AICc: corrected AIC for small samples
- Out-of-sample forecast accuracy
- Cross-validation metrics

### 2.7 ARIMA Forecasting

#### 2.7.1 Point Forecasts

- Recursive formula application
- Forecast function: conditional expectation
- Mean reversion in stationary models
- Long-term forecasts approach mean
- Seasonal pattern propagation

#### 2.7.2 Forecast Uncertainty

- Forecast error variance derivation
- Prediction interval construction
- Interval width increases with horizon
- Assumption: normally distributed errors
- Bootstrap intervals for robustness

#### 2.7.3 Forecast Updating

- New observation incorporation
- State space representation
- Kalman filter updating
- Adaptive forecasting
- Real-time forecast revision

### 2.8 Advanced ARIMA Topics

#### 2.8.1 Intervention Analysis

- Step interventions: level shifts
- Pulse interventions: temporary shocks
- Ramp interventions: gradual changes
- Transfer function models
- Policy evaluation applications

#### 2.8.2 Outlier Detection & Treatment

- Additive outliers (AO)
- Innovative outliers (IO)
- Level shifts (LS)
- Temporary changes (TC)
- Iterative detection procedures

#### 2.8.3 ARIMAX Models

- Exogenous variables inclusion
- Regression with ARIMA errors
- Transfer function models
- Dynamic regression
- Covariate forecasting challenges

### 2.9 Implementation

#### 2.9.1 Software Tools

- R: forecast package, auto.arima()
- Python: statsmodels.tsa.arima.model.ARIMA
- Python: pmdarima.auto_arima()
- SAS: PROC ARIMA
- MATLAB: Econometrics Toolbox

#### 2.9.2 Practical Workflow

- Data preprocessing: handling missing values
- Exploratory data analysis
- Stationarity transformation
- Model identification and fitting
- Diagnostic checking loop
- Forecasting and evaluation

---

