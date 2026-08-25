## Module 5: A/B Testing Frameworks


### 5.1 A/B Testing Fundamentals

- What is A/B testing?
- Hypothesis formulation
- Control vs treatment groups
- Statistical significance
- Business vs statistical metrics
- When to use A/B testing for ML models

### 5.2 Experiment Design

- Sample size calculation
- Power analysis
- Minimum detectable effect (MDE)
- Randomization strategies
- Stratification techniques
- Blocking variables

### 5.3 Randomization Techniques

- Simple random assignment
- User-level randomization
- Session-level randomization
- Cluster randomization
- Consistent hashing for assignment
- Deterministic randomization

### 5.4 Traffic Allocation

- Fixed allocation (50/50, 90/10, etc.)
- Adaptive allocation
- Multi-armed bandit integration
- Gradual rollout strategies
- Safety guardrails

### 5.5 Metrics Definition

- Primary metrics (success criteria)
- Secondary metrics
- Guardrail metrics
- Counter metrics
- Leading vs lagging indicators
- Metric sensitivity and noise

### 5.6 Statistical Analysis

- T-tests for continuous metrics
- Chi-square tests for categorical metrics
- Mann-Whitney U test for non-normal distributions
- Confidence intervals
- P-values and significance levels
- Multiple testing corrections (Bonferroni, FDR)

### 5.7 A/B Testing Platforms

- Optimizely
- Google Optimize
- VWO (Visual Website Optimizer)
- LaunchDarkly
- Split.io
- Unleash
- Custom frameworks
- Platform selection criteria

### 5.8 Feature Flags Integration

- Feature flag systems
- Flag-based experiment control
- Targeting rules
- Flag lifecycle management
- Gradual rollouts
- Kill switches

### 5.9 Multi-variate Testing

- Testing multiple variations simultaneously
- Factorial designs
- Interaction effects
- Sample size implications
- Analysis complexity

### 5.10 Sequential Testing

- Early stopping criteria
- Sequential probability ratio test (SPRT)
- Always-valid p-values
- Continuous monitoring
- False discovery rate control

### 5.11 Experiment Monitoring

- Real-time metric tracking
- Anomaly detection during experiments
- Sample ratio mismatch (SRM) detection
- Experiment health dashboards
- Automated alerts

### 5.12 Bias and Confounding

- Selection bias mitigation
- Novelty effects
- Temporal effects
- Network effects in social products
- Simpson's paradox
- Survivorship bias

### 5.13 Long-term Effects Analysis

- Delayed conversion tracking
- Cohort analysis
- Long-term metric tracking
- Holdout groups for long-term validation

### 5.14 Model-Specific A/B Testing

- Prediction quality metrics
- Latency and performance metrics
- Model confidence analysis
- Error analysis across segments
- Fairness metrics across groups

### 5.15 Multi-Model Testing

- Testing multiple models simultaneously
- Pairwise comparisons
- Thompson sampling for model selection
- Contextual bandits for personalization

### 5.16 Segmentation Analysis

- Subgroup analysis
- Heterogeneous treatment effects
- Segment-specific rollout
- Personalization opportunities

### 5.17 Experimentation Ethics

- Informed consent considerations
- Minimal risk principles
- Ethical review processes
- Transparency requirements
- Opt-out mechanisms

### 5.18 Reporting and Documentation

- Experiment documentation templates
- Results visualization
- Statistical vs practical significance
- Decision-making frameworks
- Post-experiment analysis

### 5.19 Common Pitfalls

- Peeking at results (early stopping without correction)
- Insufficient sample size
- Metric dilution
- Ignoring network effects
- Carryover effects
- Primacy/recency effects

### 5.20 Advanced Topics

- Switchback experiments
- Synthetic control methods
- Difference-in-differences
- Regression discontinuity designs
- Instrumental variables

### 5.21 Infrastructure Requirements

- Logging and data collection
- Real-time analytics pipelines
- Data warehouse integration
- Computation at scale
- Low-latency experiment assignment

### 5.22 Best Practices

- Pre-registration of hypotheses
- A/A testing for validation
- Guardrail metric definition
- Reproducible analysis
- Clear success criteria
- Iteration and learning cycles

---

