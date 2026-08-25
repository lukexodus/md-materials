## Table of Contents: Data Preprocessing and Cleaning for Machine Learning

### Foundations of Data Preprocessing

- Role of preprocessing in the machine learning pipeline
- Data quality dimensions: accuracy, completeness, consistency, timeliness
- Structured, semi-structured, and unstructured data
- Data types: numerical, categorical, ordinal, binary, text, datetime
- Population vs sample and sampling bias
- Understanding data generation processes
- Garbage in, garbage out principle
- Preprocessing vs feature engineering distinction
- Common preprocessing tools and libraries overview

### Data Acquisition and Ingestion

- Reading flat files: CSV, TSV, JSON, Parquet
- Connecting to relational databases
- Working with NoSQL data sources
- API-based data collection
- Web scraping fundamentals
- Handling large files and chunked loading
- Schema inference and validation on ingestion
- Encoding issues on file read (UTF-8, Latin-1)
- Merging data from multiple sources

### Exploratory Data Analysis for Cleaning

- Descriptive statistics for numerical columns
- Frequency counts for categorical columns
- Data profiling tools and automated reports
- Visualizing distributions: histograms, boxplots, density plots
- Visualizing relationships: scatterplots, correlation matrices
- Identifying anomalies through visualization
- Checking data types against expected schema
- Cardinality analysis for categorical features
- Detecting mixed-type columns

### Handling Missing Data

- Types of missingness: MCAR, MAR, MNAR
- Detecting missing values and missing value patterns
- Visualizing missingness (matrix plots, heatmaps)
- Deletion methods: listwise and pairwise deletion
- Simple imputation: mean, median, mode
- Constant value and placeholder imputation
- Forward fill and backward fill for sequential data
- Regression-based imputation
- K-nearest neighbors imputation
- Multiple imputation techniques
- Model-based imputation (e.g. iterative imputer)
- Creating missingness indicator features
- Evaluating imputation quality

### Handling Duplicate and Redundant Data

- Exact duplicate detection
- Fuzzy duplicate and near-duplicate detection
- Deduplication strategies for records
- Entity resolution and record linkage basics
- Handling duplicate features and multicollinearity at the raw data level
- Deciding which duplicate record to retain

### Outlier Detection and Treatment

- Statistical methods: z-score, IQR
- Visualization-based outlier detection
- Distance-based and density-based outlier detection
- Isolation forest and other model-based methods
- Univariate vs multivariate outliers
- Domain-driven outlier definitions
- Winsorization and capping
- Trimming and removal strategies
- Transforming vs removing outliers
- Distinguishing true anomalies from data errors

### Data Cleaning for Categorical Variables

- Standardizing inconsistent category labels
- Handling typos and spelling variants
- Merging rare categories
- Encoding unknown or unseen categories
- Handling case sensitivity and whitespace issues
- Resolving conflicting category hierarchies

### Data Cleaning for Text Fields

- Whitespace trimming and normalization
- Case normalization
- Removing or handling special characters
- Encoding and decoding issues (Unicode, HTML entities)
- Tokenization basics for cleaning purposes
- Spell correction and normalization
- Removing stopwords in preprocessing context
- Handling multilingual text fields

### Data Cleaning for Dates and Time

- Parsing inconsistent date formats
- Time zone normalization
- Handling invalid or impossible dates
- Extracting components: year, month, day, weekday
- Handling irregular time intervals
- Aligning timestamps across data sources

### Data Validation and Consistency Checks

- Defining validation rules and constraints
- Range and boundary checks
- Cross-field consistency checks
- Referential integrity checks
- Schema validation frameworks
- Automated data quality testing
- Logging and reporting validation failures

### Feature Scaling and Normalization

- Min-max scaling
- Standardization (z-score scaling)
- Robust scaling using median and IQR
- Unit vector normalization
- Log and power transformations
- Box-Cox and Yeo-Johnson transformations
- Choosing scaling methods based on downstream model
- Scaling considerations for sparse data

### Encoding Categorical Variables

- One-hot encoding
- Label encoding
- Ordinal encoding
- Target and mean encoding
- Frequency and count encoding
- Binary encoding
- Hashing trick for high-cardinality features
- Encoding strategies for tree-based vs linear models
- Avoiding data leakage during encoding

### Handling Imbalanced Data

- Identifying class imbalance
- Random oversampling and undersampling
- SMOTE and other synthetic sampling methods
- Class weighting approaches
- Evaluation metric considerations for imbalance
- Stratified sampling for train/test splits

### Dimensionality and Redundancy Reduction

- Identifying low-variance features
- Correlation-based feature filtering
- Variance inflation factor for multicollinearity
- Principal component analysis as a preprocessing step
- Feature selection vs dimensionality reduction distinction

### Handling Structured Data Quality Issues

- Fixing inconsistent units of measurement
- Resolving currency and locale formatting issues
- Handling inconsistent identifiers across tables
- Normalizing hierarchical or nested data
- Flattening JSON and nested structures

### Data Leakage Prevention

- Understanding train-test contamination
- Leakage through preprocessing steps
- Leakage through feature engineering
- Correct order of operations: split before preprocess
- Cross-validation-safe preprocessing pipelines

### Building Preprocessing Pipelines

- Pipeline design principles
- Using pipeline objects in common ML libraries
- Column transformers for mixed data types
- Custom transformer creation
- Reproducibility and version control for pipelines
- Saving and loading fitted preprocessing objects
- Testing preprocessing pipelines

### Preprocessing for Specialized Data Types

- Preprocessing image data: resizing, normalization
- Preprocessing audio data basics
- Preprocessing time series data: resampling, detrending
- Preprocessing graph-structured data basics
- Preprocessing geospatial data basics

### Data Governance and Documentation

- Documenting preprocessing decisions
- Data dictionaries and metadata management
- Handling sensitive and personally identifiable information
- Anonymization and pseudonymization techniques
- Auditing preprocessing steps for compliance

### Scaling Preprocessing to Production

- Batch vs streaming preprocessing
- Preprocessing consistency between training and inference
- Monitoring data drift after deployment
- Automating preprocessing workflows
- Handling schema evolution over time
