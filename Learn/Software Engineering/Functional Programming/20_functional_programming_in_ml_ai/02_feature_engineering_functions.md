## Feature Engineering Functions


Feature engineering functions transform raw data into representations that expose patterns for machine learning models. Functional approaches to feature engineering emphasize composability, reusability, and explicit dependencies between derived features.

**Feature Extraction Functions:**

Feature extraction isolates relevant information from complex data structures:

**Text Features** - Extract quantitative representations from unstructured text:

```
def extract_text_features(text):
    return {
        'length': len(text),
        'word_count': count_words(text),
        'avg_word_length': average_word_length(text),
        'unique_words': count_unique_words(text),
        'punctuation_ratio': compute_punctuation_ratio(text),
        'uppercase_ratio': compute_uppercase_ratio(text)
    }
```

**Temporal Features** - Decompose timestamps into cyclical and trend components:

```
def extract_temporal_features(timestamp):
    dt = parse_datetime(timestamp)
    return {
        'hour': dt.hour,
        'day_of_week': dt.weekday(),
        'day_of_month': dt.day,
        'month': dt.month,
        'quarter': (dt.month - 1) // 3 + 1,
        'is_weekend': dt.weekday() >= 5,
        'is_business_hours': 9 <= dt.hour < 17,
        'hour_sin': sin(2 * pi * dt.hour / 24),
        'hour_cos': cos(2 * pi * dt.hour / 24)
    }
```

Cyclical encoding using sine and cosine ensures that hour 23 and hour 0 have similar representations, capturing the circular nature of time.

**Spatial Features** - Extract location-based attributes:

```
def extract_spatial_features(latitude, longitude):
    return {
        'distance_to_center': haversine_distance(latitude, longitude, center_lat, center_lon),
        'population_density': lookup_population_density(latitude, longitude),
        'nearest_landmark': find_nearest_landmark(latitude, longitude),
        'grid_cell': spatial_hash(latitude, longitude, resolution=0.01)
    }
```

**Feature Combination:**

Combining existing features creates interaction terms that capture relationships:

**Polynomial Features** - Generate powers and interactions:

```
def polynomial_features(features, degree=2):
    result = {}
    feature_names = list(features.keys())
    
    # Original features
    result.update(features)
    
    # Degree 2 interactions
    for i, name1 in enumerate(feature_names):
        for name2 in feature_names[i:]:
            result[f"{name1}_{name2}"] = features[name1] * features[name2]
    
    # Higher degree terms if needed
    if degree > 2:
        for name in feature_names:
            for d in range(2, degree + 1):
                result[f"{name}_pow_{d}"] = features[name] ** d
    
    return result
```

**Ratio Features** - Compute proportional relationships:

```
def create_ratio_features(features, numerators, denominators):
    ratios = {}
    for num in numerators:
        for denom in denominators:
            if features[denom] != 0:
                ratios[f"{num}_per_{denom}"] = features[num] / features[denom]
            else:
                ratios[f"{num}_per_{denom}"] = None
    return ratios
```

**Statistical Aggregations:**

Aggregate features from grouped or related observations:

```
def aggregate_features(group_data, aggregations):
    """
    aggregations: list of (column, function) tuples
    """
    result = {}
    for column, func_name in aggregations:
        values = [row[column] for row in group_data]
        
        if func_name == 'mean':
            result[f"{column}_mean"] = sum(values) / len(values)
        elif func_name == 'std':
            mean = sum(values) / len(values)
            variance = sum((x - mean) ** 2 for x in values) / len(values)
            result[f"{column}_std"] = sqrt(variance)
        elif func_name == 'min':
            result[f"{column}_min"] = min(values)
        elif func_name == 'max':
            result[f"{column}_max"] = max(values)
        elif func_name == 'median':
            sorted_values = sorted(values)
            n = len(sorted_values)
            result[f"{column}_median"] = sorted_values[n // 2]
    
    return result
```

**Lag Features:**

Create temporal features from historical values:

```
def create_lag_features(time_series, lags):
    """
    Create features from previous time steps
    """
    lagged = {}
    for lag in lags:
        lagged[f"lag_{lag}"] = shift(time_series, lag)
    return lagged

def create_rolling_features(time_series, windows):
    """
    Compute rolling statistics over windows
    """
    rolling = {}
    for window in windows:
        rolling[f"rolling_mean_{window}"] = rolling_mean(time_series, window)
        rolling[f"rolling_std_{window}"] = rolling_std(time_series, window)
        rolling[f"rolling_min_{window}"] = rolling_min(time_series, window)
        rolling[f"rolling_max_{window}"] = rolling_max(time_series, window)
    return rolling
```

**Domain-Specific Transformations:**

Apply domain knowledge through specialized feature functions:

**Financial Features:**

```
def extract_financial_features(transactions):
    return {
        'transaction_velocity': count_transactions(transactions, window='1h') / 1,
        'amount_volatility': std(amounts(transactions)),
        'merchant_diversity': count_unique_merchants(transactions),
        'cross_border_ratio': count_cross_border(transactions) / len(transactions),
        'night_transaction_ratio': count_night_transactions(transactions) / len(transactions),
        'amount_zscore': (current_amount - mean_amount(transactions)) / std_amount(transactions)
    }
```

**NLP Features:**

```
def extract_nlp_features(text, vocabulary, embeddings):
    tokens = tokenize(text)
    return {
        'tfidf_vector': compute_tfidf(tokens, vocabulary),
        'sentiment_score': compute_sentiment(text),
        'entity_count': count_named_entities(text),
        'pos_distribution': compute_pos_distribution(tokens),
        'avg_embedding': mean(lookup_embeddings(tokens, embeddings))
    }
```

**Encoding Categorical Variables:**

Transform discrete categories into numerical representations:

**One-Hot Encoding:**

```
def one_hot_encode(value, categories):
    """
    Create binary indicator for each category
    """
    encoding = {f"is_{cat}": 0 for cat in categories}
    if value in categories:
        encoding[f"is_{value}"] = 1
    return encoding
```

**Target Encoding:**

```
def create_target_encoder(category_column, target_column, training_data):
    """
    Encode categories by their mean target value
    """
    category_means = compute_category_means(training_data, category_column, target_column)
    global_mean = mean(training_data[target_column])
    
    def encode(category):
        return category_means.get(category, global_mean)
    
    return encode
```

**Frequency Encoding:**

```
def frequency_encode(value, value_counts):
    """
    Encode by frequency of occurrence
    """
    total = sum(value_counts.values())
    return value_counts.get(value, 0) / total
```

**Feature Scaling Functions:**

Normalize feature magnitudes for algorithms sensitive to scale:

**Standardization (Z-score normalization):**

```
def standardize(values, mean=None, std=None):
    """
    Transform to zero mean and unit variance
    """
    if mean is None:
        mean = compute_mean(values)
    if std is None:
        std = compute_std(values)
    
    return [(v - mean) / std for v in values]
```

**Min-Max Scaling:**

```
def min_max_scale(values, feature_min=None, feature_max=None, target_min=0, target_max=1):
    """
    Scale values to a fixed range
    """
    if feature_min is None:
        feature_min = min(values)
    if feature_max is None:
        feature_max = max(values)
    
    range_span = feature_max - feature_min
    target_span = target_max - target_min
    
    return [
        target_min + ((v - feature_min) / range_span) * target_span
        for v in values
    ]
```

**Robust Scaling:**

```
def robust_scale(values, median=None, iqr=None):
    """
    Scale using median and interquartile range (robust to outliers)
    """
    if median is None:
        median = compute_median(values)
    if iqr is None:
        q1 = compute_quantile(values, 0.25)
        q3 = compute_quantile(values, 0.75)
        iqr = q3 - q1
    
    return [(v - median) / iqr for v in values]
```

**Feature Selection Functions:**

Identify and retain informative features:

**Variance Threshold:**

```
def select_by_variance(features, threshold=0.01):
    """
    Remove low-variance features
    """
    variances = {
        name: compute_variance(values)
        for name, values in features.items()
    }
    
    return {
        name: values
        for name, values in features.items()
        if variances[name] > threshold
    }
```

**Correlation-Based Selection:**

```
def select_by_correlation(features, target, threshold=0.1):
    """
    Select features correlated with target
    """
    correlations = {
        name: compute_correlation(values, target)
        for name, values in features.items()
    }
    
    return {
        name: values
        for name, values in features.items()
        if abs(correlations[name]) > threshold
    }
```

**Feature Importance Functions:**

```
def create_importance_selector(model, n_features):
    """
    Select top n features by model importance scores
    """
    importances = model.feature_importances()
    
    def select_features(features):
        sorted_features = sorted(
            features.items(),
            key=lambda x: importances.get(x[0], 0),
            reverse=True
        )
        return dict(sorted_features[:n_features])
    
    return select_features
```

**Missing Value Handling:**

Transform incomplete data through imputation strategies:

```
def impute_missing(features, strategy='mean', fill_value=None):
    """
    Fill missing values using specified strategy
    """
    result = {}
    
    for name, values in features.items():
        if strategy == 'mean':
            fill = compute_mean([v for v in values if v is not None])
        elif strategy == 'median':
            fill = compute_median([v for v in values if v is not None])
        elif strategy == 'mode':
            fill = compute_mode([v for v in values if v is not None])
        elif strategy == 'constant':
            fill = fill_value
        
        result[name] = [v if v is not None else fill for v in values]
    
    return result
```

**Feature Hashing:**

Map high-cardinality categorical features to fixed-size representations:

```
def hash_features(values, n_features=1024):
    """
    Hash categorical values to fixed-size space
    """
    hashed = [0] * n_features
    
    for value in values:
        hash_index = hash(value) % n_features
        hashed[hash_index] += 1
    
    return hashed
```

