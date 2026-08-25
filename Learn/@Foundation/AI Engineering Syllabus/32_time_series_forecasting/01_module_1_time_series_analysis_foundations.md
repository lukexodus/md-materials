## Module 1: Time Series Analysis Foundations


### 1.1 Time Series Fundamentals

#### 1.1.1 Core Concepts

- Definition: ordered sequence of observations
- Temporal dependence and autocorrelation
- Stationarity: strict vs weak (covariance stationarity)
- Ergodicity: time averages vs ensemble averages
- Time series vs cross-sectional data

#### 1.1.2 Components Decomposition

- Trend: long-term direction (linear, polynomial, nonlinear)
- Seasonality: periodic patterns with fixed frequency
- Cyclical patterns: non-fixed periodic fluctuations
- Irregular/residual: random noise component
- Additive vs multiplicative models

#### 1.1.3 Temporal Patterns

- Deterministic vs stochastic trends
- Seasonal patterns: daily, weekly, monthly, yearly
- Multiple seasonality: complex periodic structures
- Calendar effects: holidays, weekdays vs weekends
- Structural breaks: regime changes, interventions

### 1.2 Stationarity & Transformations

#### 1.2.1 Stationarity Testing

- Visual inspection: time plots, ACF plots
- Augmented Dickey-Fuller (ADF) test
- KPSS test: null hypothesis of stationarity
- Phillips-Perron test
- Statistical vs practical significance

#### 1.2.2 Differencing

- First-order differencing: Δy_t = y_t - y_{t-1}
- Seasonal differencing: Δ_s y_t = y_t - y_{t-s}
- Second-order differencing: when needed
- Over-differencing dangers
- [Inference] Integration order determination

#### 1.2.3 Transformations

- Log transformation: variance stabilization
- Box-Cox transformation: family of power transforms
- Square root transformation
- Seasonal adjustment methods
- Detrending techniques

### 1.3 Autocorrelation Analysis

#### 1.3.1 Autocorrelation Function (ACF)

- Definition: ρ_k = Cov(y_t, y_{t-k}) / Var(y_t)
- Sample ACF computation
- Confidence intervals: ±1.96/√n
- Interpretation: identifying patterns
- Correlogram visualization

#### 1.3.2 Partial Autocorrelation Function (PACF)

- Definition: correlation after removing intermediate lags
- Distinguishing direct vs indirect correlation
- Sample PACF computation
- Model identification role
- AR vs MA pattern recognition

#### 1.3.3 Cross-Correlation Function (CCF)

- Correlation between two time series
- Lead-lag relationships
- Causality investigation (Granger causality)
- Transfer function models
- Multivariate extension

### 1.4 Classical Decomposition Methods

#### 1.4.1 Moving Average Decomposition

- Simple moving average (SMA)
- Centered moving average
- Weighted moving average
- Trend extraction
- Seasonal component isolation

#### 1.4.2 STL Decomposition

- Seasonal and Trend decomposition using Loess
- Robust to outliers
- Handling non-constant seasonality
- Flexible seasonal window selection
- Advantages over classical methods

#### 1.4.3 X-11/X-13-ARIMA-SEATS

- U.S. Census Bureau methods
- Seasonal adjustment for economic data
- Trading day adjustments
- Outlier detection and treatment
- Industry standard for official statistics

### 1.5 Spectral Analysis

#### 1.5.1 Frequency Domain Analysis

- Fourier transform: time to frequency
- Power spectral density
- Periodogram: sample spectrum
- Dominant frequency identification
- Nyquist frequency: sampling considerations

#### 1.5.2 Wavelet Analysis

- Time-frequency localization
- Multi-resolution analysis
- Non-stationary signal decomposition
- Discrete vs continuous wavelets
- Applications in finance and geophysics

### 1.6 Basic Forecasting Concepts

#### 1.6.1 Point Forecasts

- One-step-ahead forecasting
- Multi-step forecasting: direct vs iterative
- Forecast horizon considerations
- Static vs dynamic forecasting
- Forecast updating strategies

#### 1.6.2 Forecast Intervals

- Prediction intervals: uncertainty quantification
- Confidence vs prediction intervals
- Parametric interval construction
- Bootstrap prediction intervals
- Conformal prediction for coverage

#### 1.6.3 Forecast Evaluation

- In-sample vs out-of-sample evaluation
- Rolling window validation
- Expanding window validation
- Time series cross-validation
- Forecast combination strategies

---

