## Module 3: Data Drift Detection


### 3.1 Data Drift Fundamentals

- What is data drift
- Why drift occurs
- Impact on model performance
- Drift vs concept drift distinction
- Temporal dynamics of drift
- Multivariate drift considerations

### 3.2 Types of Data Drift

#### 3.2.1 Covariate Shift

- Input distribution changes
- Feature distribution shift
- Population drift
- Selection bias changes
- Seasonality effects
- Environmental changes

#### 3.2.2 Prior Probability Shift

- Label distribution changes
- Class imbalance drift
- Target variable shift
- Outcome prevalence changes
- Event rate drift

#### 3.2.3 Joint Distribution Shift

- Combined input-output changes
- Complex drift patterns
- Multi-modal drift
- Interaction effect changes

### 3.3 Statistical Drift Detection Methods

#### 3.3.1 Univariate Tests

- Kolmogorov-Smirnov test
- Chi-squared test
- Population Stability Index (PSI)
- Kullback-Leibler divergence
- Jensen-Shannon divergence
- Wasserstein distance

#### 3.3.2 Multivariate Tests

- Maximum Mean Discrepancy (MMD)
- Multivariate KS test
- Energy distance
- Hotelling's T² test
- MANOVA
- Dimensionality reduction + univariate

#### 3.3.3 Distribution Comparison

- Histogram comparison
- Density estimation comparison
- Quantile comparison
- Moment comparison (mean, variance, skewness, kurtosis)
- Empirical distribution comparison

### 3.4 Window-Based Drift Detection

#### 3.4.1 Fixed Windows

- Reference window selection
- Test window size determination
- Sliding window approach
- Overlapping windows
- Window size trade-offs
- Temporal alignment

#### 3.4.2 Adaptive Windows

- ADWIN (ADaptive WINdowing)
- Dynamic window sizing
- Change point detection
- Cumulative sum (CUSUM)
- Exponentially weighted moving statistics
- Recursive monitoring

### 3.5 Feature-Level Monitoring

#### 3.5.1 Individual Feature Drift

- Per-feature statistics
- Feature importance weighting
- Critical feature identification
- Redundant feature handling
- Missing value rate tracking
- Value range monitoring

#### 3.5.2 Feature Correlation Changes

- Correlation matrix evolution
- Feature interaction drift
- Multicollinearity changes
- Independence assumption violations
- Network structure changes

#### 3.5.3 Categorical Feature Drift

- Category frequency changes
- New category emergence
- Category disappearance
- Cardinality changes
- Encoding drift

### 3.6 Embedding and Representation Drift

#### 3.6.1 Embedding Space Monitoring

- Embedding distribution shifts
- Cluster structure changes
- Manifold distortion
- Dimensionality changes
- Semantic drift in embeddings

#### 3.6.2 Representation Learning Drift

- Learned feature drift
- Attention pattern changes
- Hidden state distribution
- Activation statistics
- Layer-wise drift analysis

### 3.7 Time Series Specific Drift

#### 3.7.1 Trend Changes

- Trend detection algorithms
- Slope change detection
- Non-stationarity tests
- Detrending strategies
- Seasonal adjustment

#### 3.7.2 Seasonality Changes

- Seasonal pattern detection
- Period change detection
- Amplitude changes
- Phase shifts
- Multiple seasonality handling

#### 3.7.3 Autocorrelation Changes

- ACF/PACF monitoring
- Long-range dependency changes
- Regime switching detection
- Volatility clustering

### 3.8 Drift Severity and Prioritization

#### 3.8.1 Drift Magnitude

- Effect size calculation
- Practical significance assessment
- Threshold determination
- Severity scoring
- Risk-based prioritization

#### 3.8.2 Drift Velocity

- Rate of change measurement
- Acceleration detection
- Sudden vs gradual drift
- Forecasting future drift
- Early warning indicators

### 3.9 Drift Visualization

#### 3.9.1 Distribution Plots

- Overlaid histograms
- KDE plots
- Box plots
- Violin plots
- Quantile-quantile plots

#### 3.9.2 Time Series Plots

- Metric evolution over time
- Rolling statistics
- Change point annotations
- Confidence bands
- Multi-panel comparisons

#### 3.9.3 Dimensionality Reduction Visualization

- t-SNE plots
- UMAP visualizations
- PCA projections
- Reference vs current overlays
- Temporal animation

---

