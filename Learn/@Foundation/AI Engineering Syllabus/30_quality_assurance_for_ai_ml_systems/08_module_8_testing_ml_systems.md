## Module 8: Testing ML Systems


### 8.1 Testing Philosophy for ML

**Differences from Traditional Software:**

- Non-deterministic behavior
- Data-dependent outputs
- Emergent properties
- Probabilistic guarantees
- Continuous integration challenges

**Testing Pyramid for ML:**

1. Unit tests (data, features, model components)
2. Integration tests (pipeline, end-to-end)
3. System tests (production-like environment)
4. Validation tests (model performance)

### 8.2 Data Testing

**Schema Validation:**

- Column names and types
- Value ranges (min, max)
- Categorical value sets
- Missing value thresholds
- Data type consistency

**Statistical Tests:**

- Distribution tests (KS test, chi-square)
- Mean, variance within expected range
- Correlation structure preservation
- Outlier detection
- Data drift detection

**Data Quality Checks:**

- Completeness (missing values)
- Uniqueness (duplicate detection)
- Consistency (cross-field validation)
- Timeliness (freshness checks)
- Accuracy (ground truth comparison)

**Example Test:**

```python
def test_data_schema():
    df = load_data()
    assert set(df.columns) == expected_columns
    assert df['age'].between(0, 120).all()
    assert df['category'].isin(valid_categories).all()
    assert df.isnull().sum().sum() < max_missing
```

### 8.3 Feature Engineering Testing

**Transformation Tests:**

- Invertibility (where applicable)
- Boundedness (outputs in expected range)
- Handling edge cases (NaN, inf, extreme values)
- Consistency (same input → same output)

**Feature Validation:**

- Feature distributions
- Feature correlations
- Feature importance stability
- No data leakage (temporal ordering)

**Example Test:**

```python
def test_feature_normalization():
    features = normalize(raw_features)
    assert np.abs(features.mean()) < 1e-6  # approximately 0
    assert np.abs(features.std() - 1) < 1e-6  # approximately 1
    assert not np.any(np.isnan(features))
    assert not np.any(np.isinf(features))
```

### 8.4 Model Testing

**Invariance Tests:**

- Translation invariance (images)
- Rotation invariance
- Case invariance (text)
- Synonym robustness

**Directional Expectation Tests:**

- Increasing feature X should increase/decrease prediction
- Monotonicity constraints
- Logical consistency

**Minimum Functionality Tests:**

- Simple cases model must get right
- Hand-crafted examples
- Known ground truth

**Behavioral Tests:**

```python
def test_sentiment_model():
    # Positive sentiment
    assert model.predict("This is amazing!") > 0.7
    # Negative sentiment
    assert model.predict("This is terrible!") < 0.3
    # Negation
    pos_score = model.predict("This is good")
    neg_score = model.predict("This is not good")
    assert neg_score < pos_score
```

### 8.5 Training Testing

**Training Loop Tests:**

- Loss decreases over epochs
- Gradient flow (no vanishing/exploding)
- Checkpoint saving and loading
- Reproducibility with same seed

**Overfitting Tests:**

- Model can overfit small dataset
- Regularization prevents overfitting
- Training metrics improve

**Performance Tests:**

- Model exceeds baseline
- Model exceeds random guess
- Convergence within reasonable time

### 8.6 Inference Testing

**Prediction Tests:**

- Output shape correctness
- Output range validity (probabilities sum to 1)
- Consistency across runs
- Batch vs single prediction equivalence

**Performance Tests:**

- Latency requirements met
- Throughput targets met
- Memory usage within bounds
- GPU utilization

**Integration Tests:**

- Input preprocessing matches training
- Output postprocessing correct
- Error handling for invalid inputs
- Graceful degradation

### 8.7 Regression Testing

**Model Version Comparison:**

- New model vs old model on test set
- Performance should not degrade
- Acceptable performance difference threshold
- Regression on specific subsets

**Shadow Mode Testing:**

- Run new model alongside production
- Compare predictions
- Monitor discrepancies
- No user impact

### 8.8 Test Data Management

**Test Set Curation:**

- Representative of production
- Includes edge cases
- Updated periodically
- Never used for training

**Golden Test Set:**

- High-quality, manually verified
- Stable over time
- Used for regression testing
- Version controlled

**Adversarial Test Set:**

- Challenging examples
- Known failure modes
- Stress testing
- Robustness evaluation

### 8.9 Testing Tools

**Testing Frameworks:**

- pytest (Python)
- unittest (Python)
- pytest-cov (coverage)
- hypothesis (property-based testing)

**ML-Specific Testing:**

- Great Expectations (data validation)
- Deepchecks (ML validation)
- Evidently (data drift)
- Checklist (behavioral testing)

**Example pytest setup:**

```python
# conftest.py
import pytest

@pytest.fixture(scope="session")
def model():
    return load_model("model.pth")

@pytest.fixture
def sample_data():
    return load_test_data()

# test_model.py
def test_model_output_shape(model, sample_data):
    predictions = model.predict(sample_data)
    assert predictions.shape == (len(sample_data), num_classes)
```

### 8.10 Continuous Integration for ML

**CI Pipeline Components:**

1. Lint and format check
2. Unit tests
3. Integration tests
4. Model tests (small-scale training)
5. Performance benchmarks
6. Documentation generation

**GitHub Actions Example:**

```yaml
name: ML Pipeline Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Set up Python
        uses: actions/setup-python@v2
      - name: Install dependencies
        run: pip install -r requirements.txt
      - name: Lint
        run: flake8 src/
      - name: Unit tests
        run: pytest tests/unit
      - name: Data validation
        run: pytest tests/data
      - name: Model tests
        run: pytest tests/model
```

### 8.11 Testing Best Practices

- Write tests before fixing bugs
- Automate all tests
- Keep tests fast (use small datasets)
- Test one thing per test
- Use descriptive test names
- Mock expensive operations
- Parametrize tests for multiple inputs
- Measure test coverage
- Run tests in CI/CD
- Maintain and update tests

---

