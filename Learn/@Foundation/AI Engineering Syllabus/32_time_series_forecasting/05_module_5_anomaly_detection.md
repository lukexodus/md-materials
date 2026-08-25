## Module 5: Anomaly Detection


### 5.1 Anomaly Detection Fundamentals

#### 5.1.1 Definition & Types

- Point anomalies: individual outliers
- Contextual anomalies: anomalous in specific context
- Collective anomalies: sequence of points
- Global vs local anomalies
- Novelty vs outlier detection

#### 5.1.2 Applications

- Fraud detection: financial transactions
- System monitoring: IT infrastructure
- Quality control: manufacturing
- Healthcare: patient monitoring
- Network security: intrusion detection
- IoT sensor monitoring

#### 5.1.3 Challenges

- Imbalanced data: rare anomalies
- Evolving patterns: concept drift
- Lack of labeled anomalies
- High dimensionality
- Real-time detection requirements

### 5.2 Statistical Methods

#### 5.2.1 Z-Score (Standard Score)

- Assumption: Gaussian distribution
- Z = (x - μ) / σ
- Threshold: typically |Z| > 3
- [Limitation] Sensitive to outliers in μ and σ
- Robust variants: median absolute deviation (MAD)

#### 5.2.2 Grubbs' Test

- Detecting single outlier in univariate data
- Assumes normal distribution
- Hypothesis testing framework
- Iterative application for multiple outliers
- [Limitation] One outlier at a time

#### 5.2.3 Generalized ESD Test

- Extension of Grubbs' test
- Multiple outliers simultaneously
- Specifies maximum number of outliers
- [Note] Still assumes normality
- Sequential testing procedure

#### 5.2.4 Box Plot Method

- Interquartile range (IQR)
- Outliers: below Q1 - 1.5×IQR or above Q3 + 1.5×IQR
- Robust to non-normal distributions
- Visual interpretation
- [Limitation] Ignores temporal structure

### 5.3 Time Series-Specific Methods

#### 5.3.1 ARIMA-Based Detection

- Fit ARIMA model to historical data
- Forecast expected values
- Residual analysis: forecast errors
- Threshold on residuals or confidence intervals
- [Advantage] Captures temporal structure

#### 5.3.2 STL Decomposition

- Separate trend, seasonality, remainder
- Anomalies in remainder component
- Robust STL (RSTL): outlier-resistant
- Threshold on remainder magnitude
- [Application] Seasonal pattern preservation

#### 5.3.3 Prophet for Anomaly Detection

- Fit Prophet model
- Anomalies: observations outside prediction intervals
- Adjusting interval width
- Handling seasonality and trend
- [Practical] Easy implementation

#### 5.3.4 Change Point Detection

- Structural break identification
- CUSUM: cumulative sum control chart
- Bayesian change point detection
- PELT: Pruned Exact Linear Time
- [Application] Regime shifts, interventions

### 5.4 Machine Learning Approaches

#### 5.4.1 Isolation Forest

- Tree-based anomaly detection
- Principle: anomalies easier to isolate
- Path length in isolation tree
- Contamination parameter: expected anomaly rate
- [Advantage] Efficient for high dimensions

#### 5.4.2 Local Outlier Factor (LOF)

- Density-based method
- Local density deviation
- K-nearest neighbors
- LOF score: degree of outlierness
- [Application] Local anomaly detection

#### 5.4.3 One-Class SVM

- Learning normal data boundary
- Nu parameter: anomaly proportion
- Kernel trick for nonlinear boundaries
- [Challenge] Hyperparameter sensitivity
- [Computational] Scalability issues

#### 5.4.4 Clustering-Based Methods

- K-means: distance to nearest centroid
- DBSCAN: points not in any cluster
- Gaussian Mixture Models: low probability points
- [Assumption] Normal data forms clusters
- [Limitation] Cluster number selection

### 5.5 Deep Learning Methods

#### 5.5.1 Autoencoders

- Learning compressed representation
- Reconstruction error as anomaly score
- Anomalies: high reconstruction error
- Architecture: encoder-decoder
- [Assumption] Normal data reconstructs well

**Variants:**

- Denoising autoencoders: robustness
- Variational autoencoders (VAE): probabilistic
- LSTM autoencoders: temporal sequences
- Convolutional autoencoders: spatial data

#### 5.5.2 LSTM-Based Detection

- Learning temporal patterns
- Prediction error as anomaly indicator
- Many-to-one or sequence-to-sequence
- [Advantage] Captures long-term dependencies
- Bidirectional LSTM consideration [Caution: future leakage]

#### 5.5.3 Generative Adversarial Networks (GANs)

- Generator: producing normal samples
- Discriminator: distinguishing real/generated
- AnoGAN: adversarial approach
- [Inference] Anomalies: difficult to generate
- [Challenge] Training instability

#### 5.5.4 Transformers for Anomaly Detection

- Self-attention for temporal context
- Anomaly Transformer: prior-association discrepancy
- [Recent] State-of-the-art on benchmarks
- [Computational] Resource intensive

### 5.6 Hybrid Approaches

#### 5.6.1 Forecasting + Residual Analysis

- Forecast with any method (ARIMA, Prophet, NN)
- Anomaly score from forecast error
- Dynamic thresholds: adaptive to volatility
- [Advantage] Leveraging forecast accuracy
- Separating expected from unexpected

#### 5.6.2 Ensemble Methods

- Combining multiple detectors
- Voting or averaging scores
- Diversity among detectors
- [Empirical] Often improves robustness
- Computational cost increase

#### 5.6.3 Multi-Level Detection

- Point anomalies: statistical tests
- Contextual anomalies: forecasting-based
- Collective anomalies: subsequence methods
- Hierarchical detection pipeline
- [Design] Task-specific combination

### 5.7 Threshold Selection & Scoring

#### 5.7.1 Static Thresholds

- Fixed value: domain knowledge
- Percentile-based: top x%
- Standard deviation multiples
- [Limitation] Non-adaptive to changes
- Requires historical calibration

#### 5.7.2 Dynamic Thresholds

- Adapting to recent history
- Rolling statistics: moving average, std dev
- Seasonal adjustment
- [Advantage] Handles non-stationarity
- Tuning window size

#### 5.7.3 Anomaly Scores

- Continuous scores vs binary labels
- Ranking anomalies by severity
- ROC-AUC for evaluation
- Precision-Recall curves
- [Practical] Human review prioritization

### 5.8 Evaluation Metrics

#### 5.8.1 Classification Metrics

- Precision: true positives / (true + false positives)
- Recall (Sensitivity): true positives / (true positives + false negatives)
- F1-Score: harmonic mean of precision and recall
- False positive rate
- [Challenge] Extreme class imbalance

#### 5.8.2 Ranking Metrics

- Precision@K: precision in top-K anomalies
- Average Precision
- ROC-AUC: overall ranking quality
- [Practical] When labels scarce or review capacity limited

#### 5.8.3 Evaluation Challenges

- Lack of labeled data
- Subjective anomaly definition
- Delayed labels in production
- Cost-sensitive errors: false alarms vs missed anomalies
- [Practice] Domain expert validation

### 5.9 Real-Time Anomaly Detection

#### 5.9.1 Streaming Algorithms

- Online learning: updating models
- Sliding window approaches
- Incremental statistics
- [Requirement] Low latency
- Memory-efficient data structures

#### 5.9.2 Edge Computing

- On-device detection: IoT sensors
- Resource constraints: CPU, memory
- Model compression: pruning, quantization
- [Trade-off] Accuracy vs efficiency
- Federated learning considerations

#### 5.9.3 Alert Management

- Alert fatigue: too many false positives
- Alert aggregation: related anomalies
- Severity levels: prioritization
- Feedback loops: human validation
- [Practical] Tuning for operational constraints

### 5.10 Domain-Specific Considerations

#### 5.10.1 IT/Network Monitoring

- Multivariate time series: many metrics
- Log analysis: text + time series
- Dependency graphs: causality
- [Application] Root cause analysis
- Tools: Prometheus, Grafana

#### 5.10.2 Finance & Fraud

- Real-time transaction monitoring
- Concept drift: evolving fraud patterns
- Explainability requirements: regulatory
- Imbalanced data: rare fraud
- [Challenge] Adversarial evasion

#### 5.10.3 Manufacturing & IoT

- Sensor data: high frequency
- Multivariate dependencies
- Degradation detection: gradual
- [Application] Predictive maintenance link
- Environmental noise robustness

---

