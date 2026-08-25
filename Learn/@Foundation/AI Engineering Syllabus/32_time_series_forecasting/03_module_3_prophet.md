## Module 3: Prophet


### 3.1 Prophet Framework Overview

#### 3.1.1 Design Philosophy

- Analyst-in-the-loop forecasting
- Intuitive hyperparameters
- Robust to missing data and outliers
- Handling holidays and special events
- Automatic changepoint detection
- Developed by Facebook (Meta)

#### 3.1.2 Target Use Cases

- Business time series: daily/weekly data
- Strong seasonal patterns
- Multiple seasonality components
- Historical trend changes
- Holiday effects important
- [Note] Not suitable for sub-daily high-frequency data

#### 3.1.3 Prophet vs Traditional Methods

- Decomposable model vs ARIMA
- Flexible trend vs polynomial
- Fourier seasonality vs seasonal dummies
- Easier parameter interpretation
- [Inference] Less statistical rigor, more practical flexibility

### 3.2 Prophet Model Components

#### 3.2.1 Additive Model Structure

- y(t) = g(t) + s(t) + h(t) + ε_t
- g(t): piecewise linear or logistic growth trend
- s(t): periodic seasonality (Fourier series)
- h(t): holiday effects
- ε_t: error term (normal distribution assumed)

#### 3.2.2 Trend Component g(t)

**Piecewise Linear Trend**

- Changepoints: times where growth rate changes
- Automatic changepoint selection
- Bayesian approach: sparse prior on rate changes
- Default: 25 potential changepoints (first 80% of data)
- Growth rate adjustments: δ parameters

**Logistic Growth Trend**

- Carrying capacity: market saturation
- Time-varying capacity: C(t)
- S-curve shape for bounded growth
- Applications: user growth, market penetration
- Capacity specification required

#### 3.2.3 Seasonality Component s(t)

- Fourier series representation
- Yearly seasonality: default 10 Fourier terms (N=10)
- Weekly seasonality: default 3 Fourier terms (N=3)
- Daily seasonality: default 4 Fourier terms (N=4)
- Custom seasonality: user-defined periods
- Conditional seasonality: event-dependent patterns

#### 3.2.4 Holiday Component h(t)

- Country-specific holiday calendars
- Custom holiday definition
- Holiday windows: days before/after
- Independent effect per holiday
- Prior scale for holiday effects
- Recurring vs one-time events

### 3.3 Prophet Hyperparameters

#### 3.3.1 Trend Flexibility

- changepoint_prior_scale: trend flexibility (default 0.05)
- Higher values: more flexible, potential overfitting
- Lower values: smoother trend
- Typical range: 0.001 to 0.5
- Validation-based tuning

#### 3.3.2 Seasonality Strength

- seasonality_prior_scale: seasonal component strength (default 10)
- Controls regularization of seasonal components
- Higher values: stronger seasonal effects
- Fourier order selection: more terms = more flexibility
- [Inference] Over-smoothing vs overfitting trade-off

#### 3.3.3 Holiday Prior Scale

- holidays_prior_scale: holiday effect magnitude (default 10)
- Similar interpretation to seasonality prior
- Independent control for holiday regularization
- Per-holiday custom priors possible

#### 3.3.4 Changepoint Configuration

- n_changepoints: number of potential changepoints (default 25)
- changepoint_range: proportion of history for changepoints (default 0.8)
- Manual changepoint specification
- [Inference] Future trend uncertainty from changepoint detection

### 3.4 Advanced Prophet Features

#### 3.4.1 Multiple Seasonality

- Adding custom seasonal periods
- Fourier order per seasonality
- Conditional seasonality: active on subsets
- Mode: additive vs multiplicative
- Example: business hours patterns

#### 3.4.2 Additional Regressors

- External variables as features
- Must have future values for forecasting
- Mode: additive or multiplicative
- Prior scale for regularization
- Standardization handling

#### 3.4.3 Multiplicative Seasonality

- seasonality_mode='multiplicative'
- Seasonal effects proportional to trend level
- Common in economic/financial data
- Heteroscedastic time series
- Can mix additive and multiplicative components

#### 3.4.4 Uncertainty Intervals

- Trend uncertainty: from changepoint posterior
- Seasonal uncertainty: [Limited] assumes fixed seasonal pattern
- Observation noise: from residual variance
- Simulation-based intervals
- Interval width parameter (default 0.8 = 80%)

### 3.5 Prophet Workflow

#### 3.5.1 Data Preparation

- Required columns: 'ds' (date) and 'y' (value)
- Date format: YYYY-MM-DD or datetime
- Missing values: automatically handled
- Outlier treatment: optional manual removal
- Frequency inference: automatic

#### 3.5.2 Model Fitting

- Instantiate Prophet object with parameters
- Add holidays, seasonalities, regressors
- Fit to historical data: model.fit(df)
- Stan backend for Bayesian inference
- [Note] Fitting time increases with data size and complexity

#### 3.5.3 Forecasting

- Create future dataframe: make_future_dataframe()
- Specify periods and frequency
- Include history: optional
- Add regressor values for future
- Generate forecasts: model.predict(future)

#### 3.5.4 Visualization

- Plot forecast: model.plot(forecast)
- Components plot: model.plot_components(forecast)
- Trend, seasonality, holidays separately
- Interactive plots: plotly backend
- Custom plotting for specific components

### 3.6 Model Diagnostics & Evaluation

#### 3.6.1 Cross-Validation

- Time series cross-validation: cross_validation()
- Parameters: initial training period, horizon, period
- Rolling window evaluation
- Generates DataFrame of predictions
- Computational cost considerations

#### 3.6.2 Performance Metrics

- performance_metrics(): MAE, MAPE, MSE, RMSE, coverage
- Horizon-dependent metrics
- Aggregation over folds
- Visualization: plot_cross_validation_metric()
- Comparison across models

#### 3.6.3 Hyperparameter Tuning

- Grid search over parameter space
- Cross-validation for each configuration
- Metric optimization: minimize MAE/RMSE
- Manual vs automated search
- [Practical] Computational expense limits search space

### 3.7 Prophet Limitations & Considerations

#### 3.7.1 Known Limitations

- [Documented] Sub-daily data: computationally expensive
- Assumes piecewise trends: may not fit smooth nonlinear trends
- [Inference] Limited handling of multiple interacting seasonalities
- Uncertainty intervals: may be miscalibrated
- External regressors: requires future values

#### 3.7.2 When Prophet May Not Be Ideal

- High-frequency financial data (seconds/minutes)
- Short time series: insufficient for pattern detection
- Complex autocorrelation structures
- Need for statistical inference on parameters
- Multivariate time series dependencies

#### 3.7.3 Best Practices

- Always perform cross-validation
- Visualize components for interpretability
- Start with defaults, tune if necessary
- Domain knowledge for holidays and regressors
- Compare with simpler baselines

### 3.8 Implementation Details

#### 3.8.1 Installation & Setup

- Python: pip install prophet (requires pystan)
- R: install.packages('prophet')
- Dependency: Stan probabilistic programming
- [Note] Installation can be complex on some systems
- Docker images available for ease

#### 3.8.2 Code Examples

```python
# Basic Prophet model
from prophet import Prophet
model = Prophet()
model.fit(df)  # df has 'ds' and 'y' columns
future = model.make_future_dataframe(periods=365)
forecast = model.predict(future)

# With hyperparameters
model = Prophet(
    changepoint_prior_scale=0.05,
    seasonality_prior_scale=10,
    seasonality_mode='multiplicative'
)

# Adding holidays
model.add_country_holidays(country_name='US')

# Custom seasonality
model.add_seasonality(name='monthly', period=30.5, fourier_order=5)
```

#### 3.8.3 Performance Optimization

- Parallel cross-validation
- Reduced Stan iterations for speed
- Sampling vs optimization mode
- [Trade-off] Speed vs uncertainty quantification accuracy

---

