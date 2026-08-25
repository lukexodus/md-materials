## Data Quality Dimensions: Accuracy, Completeness, Consistency, Timeliness

### Overview

Data quality is commonly described using a set of measurable dimensions. Four of the most widely referenced are accuracy, completeness, consistency, and timeliness. These dimensions provide a structured vocabulary for diagnosing why a dataset may be unsuitable for machine learning and for deciding which preprocessing techniques are needed to address specific problems.

### Why Dimensional Framing Matters

Treating "data quality" as a single vague concept makes it hard to act on. Breaking it into dimensions allows a practitioner to ask targeted diagnostic questions: Is this value correct? Is anything missing? Do records agree with each other? Is this data current enough to be relevant? Each question points toward a different family of preprocessing techniques.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 900 260">
  <text x="450" y="20" font-size="14" font-weight="bold" text-anchor="middle" fill="#222">Four Data Quality Dimensions (svg_diagram)</text>
  <g font-family="sans-serif" font-size="12">
    <rect x="30" y="60" width="180" height="90" rx="8" fill="#dbeafe" stroke="#2563eb" />
    <text x="120" y="90" text-anchor="middle" font-weight="bold">Accuracy</text>
    <text x="120" y="110" text-anchor="middle">Does the value</text>
    <text x="120" y="125" text-anchor="middle">reflect reality?</text>

    <rect x="250" y="60" width="180" height="90" rx="8" fill="#fef3c7" stroke="#d97706" />
    <text x="340" y="90" text-anchor="middle" font-weight="bold">Completeness</text>
    <text x="340" y="110" text-anchor="middle">Is anything</text>
    <text x="340" y="125" text-anchor="middle">missing?</text>

    <rect x="470" y="60" width="180" height="90" rx="8" fill="#dcfce7" stroke="#16a34a" />
    <text x="560" y="90" text-anchor="middle" font-weight="bold">Consistency</text>
    <text x="560" y="110" text-anchor="middle">Do records agree</text>
    <text x="560" y="125" text-anchor="middle">with each other?</text>

    <rect x="690" y="60" width="180" height="90" rx="8" fill="#ede9fe" stroke="#7c3aed" />
    <text x="780" y="90" text-anchor="middle" font-weight="bold">Timeliness</text>
    <text x="780" y="110" text-anchor="middle">Is the data</text>
    <text x="780" y="125" text-anchor="middle">current enough?</text>

    <text x="450" y="190" text-anchor="middle" font-size="12" fill="#444">All four dimensions jointly determine whether a dataset is fit for modeling</text>
    <path d="M120 150 L120 175 L780 175 L780 150" stroke="#888" fill="none" />
    <path d="M340 150 L340 175" stroke="#888" fill="none" />
    <path d="M560 150 L560 175" stroke="#888" fill="none" />
    <path d="M450 175 L450 200" stroke="#888" fill="none" marker-end="url(#arrow2)" />
  </g>
  </svg>

### Accuracy

**Definition**: Accuracy refers to how closely a data value reflects the true, real-world value it is meant to represent.

**Key Points**
- Inaccurate data can arise from measurement error, transcription error, sensor faults, or outdated reference data.
- Accuracy problems are often the hardest quality issue to detect automatically, because the data may be well-formed and plausible while still being wrong (e.g., a valid-looking but incorrect address).
- Common detection methods: cross-referencing with a trusted source, range/plausibility checks, outlier detection, and business-rule validation (e.g., age cannot be negative).

**Example**

| Field | Recorded Value | Issue |
|---|---|---|
| Age | 150 | Implausible; likely a data entry error |
| Latitude | 91.2 | Outside valid range (-90 to 90); invalid |
| Blood Type | "AB+" recorded as "A+" | Plausible but factually wrong; hard to detect without external verification |

The third row illustrates why accuracy is difficult: the value "A+" is a valid blood type and passes all format and range checks, yet it may still be incorrect relative to the real-world fact. [Inference] Detecting this class of error generally requires an external source of truth or domain expert review, since statistical checks on the dataset alone often cannot reveal it.

### Completeness

**Definition**: Completeness measures the extent to which all required data is present, at both the field level (missing values within a record) and the record level (missing entire records that should exist).

**Key Points**
- Field-level completeness is usually measured as the percentage of non-missing values per column.
- Record-level completeness concerns whether the dataset contains all the entities/events it is supposed to represent (e.g., a day of sensor readings with an entire hour missing).
- Missingness can follow different mechanisms — commonly categorized as Missing Completely At Random (MCAR), Missing At Random (MAR), and Missing Not At Random (MNAR) — which affect which handling strategy is appropriate. This categorization is covered in more depth in a dedicated topic on missing data mechanisms.

**Example**

$$
\text{Completeness}(\text{column}) = \frac{\text{Number of non-missing values}}{\text{Total number of records}} \times 100
$$

For a column with 950 non-missing values out of 1,000 records, completeness is 95%. [Inference] Whether a 95% completeness rate is "acceptable" is not a fixed statistical threshold — it depends on the field's importance to the modeling task and the mechanism behind the missingness, so no universal cutoff applies.

### Consistency

**Definition**: Consistency refers to whether data values agree with each other across records, tables, or systems, and whether the same real-world entity is represented the same way everywhere it appears.

**Key Points**
- Includes format consistency (e.g., date formats), value consistency (e.g., the same category spelled differently), and cross-field logical consistency (e.g., a "ship date" that occurs before an "order date").
- Consistency problems are especially common when integrating data from multiple sources with different schemas or conventions.
- Referential consistency concerns whether foreign-key-like relationships hold (e.g., every `CustomerID` in an orders table exists in the customers table).

**Example**

| Row | Country Field |
|---|---|
| 1 | "USA" |
| 2 | "U.S.A." |
| 3 | "usa" |
| 4 | "United States" |

All four values likely refer to the same entity but would be treated as four distinct categories by most machine learning encoding schemes unless normalized first. This is a standard string-normalization problem addressed in later cleaning topics.

### Timeliness

**Definition**: Timeliness refers to whether data is sufficiently up to date for the purpose it is being used for, and whether the time lag between data generation and data use is acceptable.

**Key Points**
- Timeliness is context-dependent: a customer's address updated within the last year may be timely for a marketing model, but stock price data from an hour ago may be unacceptably stale for a high-frequency trading model.
- Related but distinct from "currency" (age of the data) and "volatility" (how quickly the underlying real-world value tends to change).
- In production ML systems, timeliness issues often show up as **training-serving skew**, where the distribution of live data has shifted since the model was trained on older data. [Inference] Whether a given time lag causes meaningful model degradation depends on how quickly the underlying data-generating process changes, which varies by domain and cannot be assumed universally.

**Example**

A fraud detection model trained on transaction data from two years ago may perform poorly on current transactions if spending patterns, fraud tactics, or currency values have shifted materially in the interim. [Speculation] The specific magnitude of performance loss in any real deployment is not something that can be stated without evaluating that specific model and dataset.

### Interactions Between Dimensions

These dimensions are not independent; addressing one can affect another:

- Imputing missing values (improving completeness) can reduce accuracy if the imputation method introduces incorrect estimates.
- Enforcing consistency by collapsing categories can obscure real accuracy differences if the collapsed categories were not actually equivalent.
- Prioritizing timeliness (using only the most recent data) can reduce completeness if historical data is discarded.

[Inference] These trade-offs are a logical consequence of how the dimensions are defined, but the actual severity of any trade-off in a specific project depends on the dataset and cannot be generalized as a fixed rule.

### Measuring Data Quality Dimensions in Practice

A common practical approach is to compute a quality scorecard, such as:

| Dimension | Metric Example |
|---|---|
| Accuracy | % of records passing validation against a reference source |
| Completeness | % of non-missing values per required field |
| Consistency | % of records passing cross-field/referential integrity checks |
| Timeliness | Average age of records relative to a defined freshness threshold |

I do not have access to information confirming which specific scorecard format or thresholds are used in any particular organization's practice; the table above illustrates a generic structure rather than a documented standard. [Unverified]

### Conclusion

Accuracy, completeness, consistency, and timeliness provide a practical vocabulary for diagnosing data quality problems before they are addressed through cleaning and transformation. Each dimension points toward different diagnostic checks and different remediation techniques, and in practice a dataset's overall fitness for machine learning depends on the joint state of all four rather than any single one in isolation.

**Related Topics**
- Understanding Missing Data Mechanisms (MCAR, MAR, MNAR)
- Outlier Detection Methods for Accuracy Issues
- String Normalization and Categorical Consistency Cleaning
- Detecting and Handling Training-Serving Skew
- Data Validation Frameworks and Automated Quality Checks
- Referential Integrity Checks Across Merged Datasets

*Note on this response: [Unverified] labels above reflect claims I cannot confirm against a specific source; [Inference] labels reflect reasoning I consider logically sound but not independently confirmed. No language implying guaranteed outcomes ("prevents," "ensures," "eliminates," "guarantees") was used for LLM/system behavior claims in this response.*