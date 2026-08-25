## Module 7: Advanced Topics & Integration


### 7.1 Hierarchical Forecasting

#### 7.1.1 Hierarchy Structures

- Geographical: country → region → store
- Product: total → category → SKU
- Temporal: year → quarter → month
- Mixed hierarchies
- Grouped structures

#### 7.1.2 Reconciliation Methods

- Bottom-up: sum of base-level forecasts
- Top-down: proportional disaggregation
- Middle-out: combination approach
- Optimal reconciliation: MinT (Minimum Trace)
- [Research] Probabilistic coherent forecasting

#### 7.1.3 Implementation

- R: hts, fable packages
- Python: scikit-hts, hierarchicalforecast
- [Challenge] Computational complexity at scale
- [Benefit] Coherent forecasts across levels

### 7.2 Probabilistic Forecasting

#### 7.2.1 Beyond Point Forecasts

- Full predictive distribution
- Quantile forecasts: prediction intervals
- Scenario generation
- Risk management applications
- [Decision-making] Incorporating uncertainty

#### 7.2.2 Evaluation Metrics

- Quantile loss: pinball loss
- Continuous Ranked Probability Score (CRPS)
- Interval coverage: calibration
- Winkler score: interval sharpness + coverage
- [Proper scoring rules] Incentivizing honest forecasts

#### 7.2.3 Methods

- Quantile regression
- Conformal prediction
- Bootstrap methods
- Deep learning: probabilistic outputs
- Ensemble diversity for uncertainty

### 7.3 Causal Inference in Time Series

#### 7.3.1 Granger Causality

- Does X help predict Y?
- Vector autoregression (VAR) framework
- F-test for additional predictive power
- [Note] Predictive causality, not true causation
- Directionality investigation

#### 7.3.2 Intervention Analysis

- Interrupted time series design
- Synthetic control methods
- Difference-in-differences
- [Application] Policy evaluation, A/B testing
- Counterfactual estimation

#### 7.3.3 Causal Discovery

- Learning causal graphs from time series
- PCMCI: constraint-based approach
- DYNOTEARS: score-based optimization
- [Research area] Temporal causal discovery
- [Challenge] Identifiability assumptions

### 7.4 Online Learning & Adaptation

#### 7.4.1 Concept Drift

- Covariate shift: X distribution changes
- Prior probability shift: Y distribution changes
- Concept shift: P(Y|X) changes
- Detection methods: statistical tests, performance monitoring
- [Practical] Non-stationary environments

#### 7.4.2 Adaptive Models

- Sliding window: recent data only
- Exponential forgetting: weighted recent data
- Ensemble with dynamic weighting
- Online gradient descent
- [Trade-off] Stability vs adaptability

#### 7.4.3 Continual Learning

- Catastrophic forgetting prevention
- Elastic Weight Consolidation (EWC)
- Experience replay
- [Application] Evolving time series patterns
- Model update strategies

### 7.5 Explainability & Interpretability

#### 7.5.1 Model-Agnostic Methods

- SHAP: Shapley values for features
- LIME: local linear approximations
- Partial dependence plots
- Individual conditional expectation (ICE)
- [Application] Understanding predictions

#### 7.5.2 Time Series-Specific Interpretation

- Attention weight visualization
- Saliency maps: important time steps
- Counterfactual explanations: minimal changes
- Feature importance over time
- [Challenge] Temporal dependencies complicate interpretation

#### 7.5.3 Intrinsically Interpretable Models

- N-BEATS interpretable variant: trend + seasonality
- GAMs: Generalized Additive Models
- Rule-based models
- [Trade-off] Interpretability vs performance
- [Regulatory] Explainability requirements (e.g., GDPR)

### 7.6 Multivariate & High-Dimensional Methods

#### 7.6.1 Vector Autoregression (VAR)

- Multivariate extension of AR
- All variables depend on all lags
- Granger causality testing framework
- [Limitation] Parameter explosion with many variables
- VARMA: adding MA component

#### 7.6.2 Dimensionality Reduction

- PCA: principal component analysis
- Factor models: latent factors
- Autoencoders: nonlinear compression
- Dynamic factor models
- [Benefit] Reducing curse of dimensionality

#### 7.6.3 Sparse Methods

- LASSO for variable selection
- Graphical lasso: learning dependencies
- Vector autoregression with LASSO (VARL)
- [Assumption] Sparsity in relationships
- [Scalability] Handling many series

### 7.7 External Regressors & Transfer Functions

#### 7.7.1 ARIMAX Models

- Exogenous variables in ARIMA framework
- Static regression vs dynamic
- [Challenge] Forecasting exogenous variables
- [Application] Weather, promotions, holidays

#### 7.7.2 Transfer Functions

- Distributed lag models
- Impulse response functions
- Modeling lead-lag relationships
- System identification
- [Engineering] Control theory connections

#### 7.7.3 Multivariate Neural Methods

- Temporal Fusion Transformer: covariate handling
- DeepAR: covariates in RNN
- Attention over covariates
- [Flexibility] Learning complex interactions

### 7.8 Forecasting at Scale

#### 7.8.1 Computational Challenges

- Thousands to millions of series
- Model selection per series
- Training time constraints
- [Infrastructure] Distributed computing

#### 7.8.2 Global vs Local Models

- Local: separate model per series (prophet per store)
- Global: single model for all (neural network across stores)
- [Empirical] Global often competitive or better
- Cold-start handling: new series

#### 7.8.3 Automation

- AutoML for time series: auto.arima, AutoGluon-TS
- Hyperparameter optimization at scale
- Model selection pipelines
- [Practical] Reducing human effort
- Monitoring thousands of forecasts

### 7.9 Specialized Domains

#### 7.9.1 Finance

- High-frequency data: tick data
- Volatility forecasting: GARCH models
- Risk measures: VaR, CVaR
- Portfolio optimization
- [Challenge] Market efficiency, noise

#### 7.9.2 Energy

- Load forecasting: electricity demand
- Price forecasting: spot markets
- Renewable generation: solar, wind forecasting
- [Multiple seasonality] Hourly, daily, weekly, yearly
- [Uncertainty] Weather dependence

#### 7.9.3 Retail

- Demand forecasting: SKU-level
- Promotional effects: complex interventions
- Hierarchical aggregation: store/region
- [Business metrics] Inventory optimization
- [Data quality] POS data issues

#### 7.9.4 Healthcare

- Patient volume forecasting
- Disease outbreak prediction
- Resource allocation
- [Data] Often limited, sensitive
- [Interpretability] Clinical decision support

### 7.10 Tools & Ecosystem

#### 7.10.1 Python Libraries

- statsmodels: classical methods (ARIMA, SARIMAX)
- pmdarima: auto_arima functionality
- prophet: Facebook's tool
- GluonTS: deep learning forecasting
- Darts: user-friendly unified interface
- sktime: scikit-learn compatible
- NeuralProphet: neural extension of Prophet
- PyTorch Forecasting: TFT and others

#### 7.10.2 R Packages

- forecast: auto.arima, ets, prophet
- fable: modern tidyverse-compatible
- modeltime: unified interface
- tsibble: time series data structures
- feasts: feature extraction and visualization

#### 7.10.3 Commercial Platforms

- AWS Forecast: managed forecasting service
- Azure Time Series Insights
- Google Cloud AI Platform
- DataRobot: automated time series modeling
- [Consideration] Cost vs customization

#### 7.10.4 Evaluation & Benchmarking

- M-competitions: M5 Forecasting - Walmart sales
- Kaggle competitions: practical datasets
- [Resource] Common benchmarks for research
- [Community] Active forecasting community

---

