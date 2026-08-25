## Module 4: Concept Drift Detection


### 4.1 Concept Drift Fundamentals

- Definition of concept drift
- Difference from data drift
- Real vs virtual drift
- Impact on model validity
- Sources of concept drift
- Detectability challenges

### 4.2 Types of Concept Drift

#### 4.2.1 Sudden Drift

- Abrupt changes
- Event-driven drift
- System changes
- Policy changes
- Market shocks

#### 4.2.2 Gradual Drift

- Slow evolution
- Trend-based changes
- Population shifts
- Behavioral adaptation
- Environmental evolution

#### 4.2.3 Incremental Drift

- Step-wise changes
- Phase transitions
- Sequential shifts
- Cumulative effects

#### 4.2.4 Recurring Drift

- Seasonal patterns
- Cyclic concepts
- Context switching
- Periodic events
- Regime changes

### 4.3 Concept Drift Detection Methods

#### 4.3.1 Performance-Based Detection

- Accuracy degradation monitoring
- Error rate tracking
- Loss function monitoring
- Metric threshold violations
- Sequential probability ratio test (SPRT)

#### 4.3.2 Distribution-Based Detection

- Posterior probability shifts
- Decision boundary changes
- Class overlap changes
- Conditional distribution P(Y|X) monitoring
- Likelihood ratio tests

#### 4.3.3 Model-Based Detection

- Ensemble disagreement
- Model diversity changes
- Prediction confidence shifts
- Uncertainty increase
- Model weight evolution

### 4.4 Window Strategies for Concept Drift

#### 4.4.1 Sliding Window

- Fixed-size windows
- Forgetting old data
- Adaptation speed
- Memory requirements
- Stationary assumption

#### 4.4.2 Landmark Window

- Fixed reference point
- Growing window
- Historical context preservation
- Drift accumulation
- Reset strategies

#### 4.4.3 Fading Factor

- Exponential weighting
- Recent data emphasis
- Continuous adaptation
- Memory efficiency
- Smooth transitions

### 4.5 Supervised Drift Detection

#### 4.5.1 With Immediate Labels

- Real-time error monitoring
- Prequential evaluation
- Sequential analysis
- Online accuracy tracking
- Cumulative error analysis

#### 4.5.2 With Delayed Labels

- Batched evaluation
- Temporal lag handling
- Imputation strategies
- Surrogate metrics
- Periodic revalidation

### 4.6 Unsupervised Drift Detection

#### 4.6.1 Prediction-Based Approaches

- Confidence monitoring
- Uncertainty tracking
- Prediction stability
- Ensemble disagreement
- Margin-based detection

#### 4.6.2 Clustering-Based Approaches

- Cluster structure changes
- Cluster membership evolution
- Cluster density changes
- New cluster emergence
- Cluster overlap detection

#### 4.6.3 Density-Based Methods

- Density ratio estimation
- Likelihood monitoring
- Novelty detection
- Anomaly scoring
- Local outlier factor

### 4.7 Multi-Model Drift Detection

#### 4.7.1 Ensemble Monitoring

- Individual model performance
- Ensemble diversity
- Weight optimization needs
- Member replacement triggers
- Collective drift indicators

#### 4.7.2 Stacked Models

- Meta-learner monitoring
- Base model drift
- Stacking weight changes
- Layer-specific drift
- End-to-end performance

### 4.8 Context-Aware Drift Detection

#### 4.8.1 Contextual Features

- Context identification
- Context-specific models
- Context transition detection
- Multi-context management
- Context hierarchy

#### 4.8.2 Causal Drift Analysis

- Causal relationship changes
- Intervention effects
- Confounder evolution
- Treatment effect drift
- Counterfactual analysis

### 4.9 Drift Attribution and Root Cause Analysis

#### 4.9.1 Feature Contribution

- SHAP value evolution
- Feature importance tracking
- Attribution drift
- Interaction effect changes
- Sensitivity analysis

#### 4.9.2 Error Pattern Analysis

- Error clustering
- Misclassification patterns
- Error concentration detection
- Systematic error identification
- Error correlation analysis

### 4.10 Proactive Drift Management

#### 4.10.1 Drift Prediction

- Leading indicators
- Trend extrapolation
- Early warning systems
- Forecasting drift onset
- Risk assessment

#### 4.10.2 Robustness Enhancement

- Adversarial training
- Domain adaptation
- Robust optimization
- Invariant learning
- Causal regularization

---

