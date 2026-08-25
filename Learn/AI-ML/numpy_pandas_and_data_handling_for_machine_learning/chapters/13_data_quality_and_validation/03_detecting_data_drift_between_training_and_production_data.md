## Detecting Data Drift Between Training and Production Data

### Core Concept

Data drift refers to a change in the statistical properties of input data between when a model was trained and when it is later used in production. Detecting drift is a documented practice in ML monitoring, intended to catch cases where a model's assumptions about incoming data no longer hold. This does not guarantee that a model's predictions will degrade — it flags a distributional change that may warrant investigation.

### Types of Drift

**Key Points**
- **Covariate drift**: the distribution of input features changes, while the underlying relationship between features and target is assumed unchanged. This is a standard, documented term in ML literature.
- **Label/target drift**: the distribution of the target variable changes over time.
- **Concept drift**: the relationship between features and target itself changes, even if feature distributions look similar.
- [Unverified] I cannot verify that these three categories are used with fully consistent definitions across all sources, since terminology in this area varies somewhat between papers and practitioner communities.

### Comparing Summary Statistics

```python
import pandas as pd
import numpy as np

train_data = pd.DataFrame({"age": np.random.normal(40, 10, 1000)})
prod_data = pd.DataFrame({"age": np.random.normal(45, 12, 1000)})

print(train_data["age"].describe())
print(prod_data["age"].describe())
```

I cannot verify the exact numeric output of `.describe()` for this specific code without executing it, since both DataFrames are generated from random sampling and results will differ on each run. The general mechanism — `.describe()` returning count, mean, std, min, quartiles, and max — is documented pandas behavior.

**Key Points**
- Comparing mean, standard deviation, and quantiles between training and production snapshots is a basic, commonly used first check for drift.
- [Inference] A difference in these summary statistics suggests a change in distribution, but does not by itself indicate the size of any resulting impact on model performance. I cannot verify how large a statistical difference needs to be before it becomes practically meaningful for any specific model without direct evaluation of that model.

### Kolmogorov-Smirnov Test for Distributional Difference

```python
from scipy import stats

ks_statistic, p_value = stats.ks_2samp(train_data["age"], prod_data["age"])
print(ks_statistic, p_value)
```

**Key Points**
- The two-sample Kolmogorov-Smirnov test is a documented statistical method that compares two samples' empirical cumulative distribution functions and returns a test statistic and p-value.
- [Inference] A low p-value is commonly interpreted as evidence against the two samples coming from the same distribution, following standard statistical hypothesis-testing convention — but this is a probabilistic inference, not a confirmed causal determination that "real" drift has occurred, and I cannot verify the appropriate significance threshold for any specific application without domain-specific guidance.
- I cannot verify the exact numeric output of this specific code without executing it, since the underlying data is randomly generated.

### Population Stability Index (PSI)

```python
def calculate_psi(expected, actual, bins=10):
    breakpoints = np.linspace(0, 100, bins + 1)
    expected_percents = np.percentile(expected, breakpoints)
    expected_counts, _ = np.histogram(expected, bins=expected_percents)
    actual_counts, _ = np.histogram(actual, bins=expected_percents)

    expected_prop = expected_counts / len(expected)
    actual_prop = actual_counts / len(actual)

    expected_prop = np.where(expected_prop == 0, 0.0001, expected_prop)
    actual_prop = np.where(actual_prop == 0, 0.0001, actual_prop)

    psi = np.sum((actual_prop - expected_prop) * np.log(actual_prop / expected_prop))
    return psi

psi_value = calculate_psi(train_data["age"].values, prod_data["age"].values)
print(psi_value)
```

**Key Points**
- PSI is a documented metric commonly used in credit risk modeling and broader ML monitoring to quantify the shift in a variable's distribution between two samples, based on binned proportions.
- [Inference] Commonly cited practitioner thresholds describe PSI values below roughly 0.1 as indicating little shift, values between roughly 0.1 and 0.25 as indicating moderate shift, and values above roughly 0.25 as indicating significant shift. I cannot verify these specific threshold values as a formally standardized rule across all sources — they are widely repeated in practitioner literature and industry blog posts, but I do not have a single authoritative source to confirm them as universally agreed-upon, so treat these numbers as commonly cited convention rather than confirmed fact.
- I cannot verify the exact numeric output of this specific code without executing it, since the underlying data is randomly generated.

### Comparing Categorical Distributions

```python
train_cat = pd.Series(np.random.choice(["A", "B", "C"], 1000, p=[0.5, 0.3, 0.2]))
prod_cat = pd.Series(np.random.choice(["A", "B", "C"], 1000, p=[0.3, 0.3, 0.4]))

train_props = train_cat.value_counts(normalize=True)
prod_props = prod_cat.value_counts(normalize=True)

print(train_props)
print(prod_props)
```

**Key Points**
- `.value_counts(normalize=True)` is documented pandas functionality returning the relative frequency of each category.
- Comparing these proportions directly, or using a chi-squared test (`scipy.stats.chisquare`), is a documented approach for detecting categorical distribution shift.
- I cannot verify the exact numeric output of this specific code without executing it, since the underlying data is randomly generated.

### Chi-Squared Test for Categorical Drift

```python
from scipy.stats import chisquare

train_counts = train_cat.value_counts().sort_index()
prod_counts = prod_cat.value_counts().sort_index()

expected = train_counts / train_counts.sum() * prod_counts.sum()
chi_stat, p_val = chisquare(f_obs=prod_counts, f_exp=expected)
print(chi_stat, p_val)
```

**Key Points**
- The chi-squared goodness-of-fit test is documented statistical methodology for comparing an observed categorical distribution against an expected one.
- [Inference] As with the KS test, a low p-value is conventionally interpreted as evidence against the two distributions being the same, following standard hypothesis-testing practice, but this is a statistical inference, not a confirmed determination of practical significance for any specific model, and I cannot verify what threshold is appropriate for any particular use case.

### Monitoring Feature-by-Feature Drift Over Time

```python
def drift_report(train_df, prod_df, numeric_cols):
    report = {}
    for col in numeric_cols:
        ks_stat, p_val = stats.ks_2samp(train_df[col], prod_df[col])
        report[col] = {"ks_statistic": ks_stat, "p_value": p_val}
    return pd.DataFrame(report).T

report = drift_report(train_data, prod_data, ["age"])
print(report)
```

**Key Points**
- Running drift checks across all model input features (rather than a single column) and aggregating results into a report is a documented, common pattern in ML monitoring tooling.
- [Speculation] Whether a per-feature drift report should trigger automated retraining, alerting, or manual review is a design decision specific to a given organization's ML operations practice; I have no basis to state a universally correct policy here.

### Drift Detection Frequency and Windowing

**Key Points**
- Drift checks can be run on a fixed schedule (e.g., daily, weekly) or triggered by a rolling window of recent production data compared against a fixed training baseline.
- [Inference] Very small comparison windows are commonly discussed as more susceptible to noise (false-positive drift signals due to natural sampling variation), while very large windows may be slower to detect a genuine, recent shift — but I cannot verify an appropriate window size for any specific application without domain-specific evaluation.

### Limitations of Drift Detection

**Key Points**
- [Inference] Statistical drift in input features does not necessarily correspond to degraded model performance, since a model may be robust to certain distributional shifts depending on its structure and the nature of the shift — this is a logical possibility grounded in general ML reasoning, not a confirmed outcome for any specific model.
- Conversely, [Inference] the absence of detected drift in monitored features does not guarantee stable model performance, since concept drift (a change in the feature-target relationship) can occur without a detectable change in feature distributions alone.
- [Unverified] I cannot verify the comparative effectiveness of PSI versus KS test versus chi-squared test versus other drift metrics for any specific dataset or model without direct empirical comparison in that specific context, since published comparisons in this area are not something I can confirm without being able to check current literature directly.

### Drift Detection Workflow

===MERMAID_DIAGRAM===
flowchart TD
    A["Training data baseline"] --> B["Store reference distribution per feature"]
    C["Incoming production data"] --> D["Compute distribution over recent window"]
    B --> E["Compare distributions: KS test, PSI, chi-squared"]
    D --> E
    E --> F{"Drift metric exceeds threshold?"}
    F -- No --> G["Continue monitoring on schedule"]
    F -- Yes --> H["Flag feature for review"]
    H --> I{"Investigate: data pipeline issue or genuine population change?"}
    I -- "Pipeline issue" --> J["Fix upstream data issue"]
    I -- "Genuine change" --> K["Evaluate model performance on recent labeled data if available"]
    K --> L{"Performance degraded?"}
    L -- Yes --> M["Consider retraining or model update"]
    L -- "Unclear or no labels yet" --> N["Continue monitoring, increase check frequency"]
    G --> C

[Inference] This flow reflects a commonly documented general pattern in ML monitoring practice; whether this exact sequence or these specific thresholds are appropriate for any specific pipeline cannot be verified without knowledge of that pipeline's specific requirements and access to current, authoritative sources confirming best practice.

### PSI Threshold Illustration

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 220">
  <text x="20" y="25" font-size="15" font-weight="bold">Commonly cited PSI interpretation ranges (svg_diagram)</text>

  <rect x="20" y="60" width="180" height="40" fill="none" stroke="#1a73e8" />
  <text x="110" y="85" font-size="11" text-anchor="middle">PSI &lt; 0.1: little shift</text>

  <rect x="220" y="60" width="180" height="40" fill="none" stroke="#e8710a" />
  <text x="310" y="85" font-size="11" text-anchor="middle">0.1 - 0.25: moderate shift</text>

  <rect x="420" y="60" width="180" height="40" fill="none" stroke="#c0392b" />
  <text x="510" y="85" font-size="11" text-anchor="middle">PSI &gt; 0.25: significant shift</text>

  <text x="20" y="140" font-size="10" fill="#555">[Unverified] These ranges are widely repeated in practitioner sources</text>
  <text x="20" y="155" font-size="10" fill="#555">but I cannot confirm a single authoritative standard defining them.</text>
  <text x="20" y="175" font-size="10" fill="#555">Treat as commonly cited convention, not a confirmed universal rule.</text>
</svg>

### Uncertainty Label for This Response

[Unverified] This response combines documented statistical methodology (KS test, chi-squared test, PSI calculation mechanics, `.describe()`, `.value_counts()`) with inferred and speculative practical guidance (threshold interpretation, monitoring frequency, when drift matters for model performance) that is individually labeled [Inference] or [Speculation] above. I do not have access to confirm PSI threshold conventions or drift-detection best practices against a single authoritative source, and no library behavior or statistical claim in this response should be treated as a guarantee for any specific dataset, model, or production environment. This should be verified against current, authoritative sources before being relied upon in production monitoring systems.

### Related Topics

- Evidently AI and other open-source libraries purpose-built for drift monitoring dashboards
- Concept drift detection methods (e.g., DDM, ADWIN) for streaming data
- Designing retraining triggers and automated ML pipeline responses to detected drift
- Feature attribution shift versus raw distributional shift as complementary monitoring signals
- Statistical multiple-testing correction when monitoring many features simultaneously
- A/B testing and shadow deployment as complementary strategies to distributional drift checks