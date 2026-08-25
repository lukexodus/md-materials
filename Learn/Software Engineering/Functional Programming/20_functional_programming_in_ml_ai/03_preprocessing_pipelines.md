## Preprocessing Pipelines


Preprocessing pipelines orchestrate data cleaning, normalization, and transformation operations in a structured, reproducible manner. Functional preprocessing pipelines maintain separation between transformation logic and execution, enabling testing, optimization, and deployment across environments.

**Pipeline Construction Patterns:**

**Sequential Composition:**

```
def create_preprocessing_pipeline(steps):
    """
    Compose preprocessing steps sequentially
    """
    def pipeline(data):
        result = data
        for step_name, step_func, params in steps:
            result = step_func(result, **params)
        return result
    
    return pipeline

# Usage
pipeline = create_preprocessing_pipeline([
    ('remove_duplicates', remove_duplicate_rows, {}),
    ('handle_missing', impute_missing_values, {'strategy': 'median'}),
    ('encode_categoricals', encode_categories, {'method': 'onehot'}),
    ('scale_features', scale_numerical, {'method': 'standard'})
])

processed_data = pipeline(raw_data)
```

**Parallel Composition:**

```
def create_parallel_pipeline(branches):
    """
    Apply multiple transformations in parallel and merge results
    """
    def pipeline(data):
        results = []
        for branch_func in branches:
            results.append(branch_func(data))
        return merge_results(results)
    
    return pipeline

# Usage
pipeline = create_parallel_pipeline([
    numerical_pipeline,
    categorical_pipeline,
    text_pipeline
])
```

**Data Validation Stage:**

Validate data quality and schema conformance before transformation:

```
def create_validation_step(schema, rules):
    """
    Validate data against schema and business rules
    """
    def validate(data):
        # Schema validation
        validate_schema(data, schema)
        
        # Business rule validation
        violations = []
        for rule_name, rule_func in rules:
            if not rule_func(data):
                violations.append(rule_name)
        
        if violations:
            return Error(f"Validation failed: {violations}")
        
        return Success(data)
    
    return validate

validation = create_validation_step(
    schema={
        'age': {'type': 'int', 'min': 0, 'max': 150},
        'income': {'type': 'float', 'min': 0},
        'category': {'type': 'str', 'values': ['A', 'B', 'C']}
    },
    rules=[
        ('positive_balance', lambda d: all(d['balance'] >= 0)),
        ('valid_dates', lambda d: all(d['end_date'] > d['start_date']))
    ]
)
```

**Data Cleaning Operations:**

**Duplicate Removal:**

```
def remove_duplicates(data, key_columns=None, keep='first'):
    """
    Remove duplicate records based on key columns
    """
    if key_columns is None:
        key_columns = data.columns
    
    seen = set()
    result = []
    
    for record in data:
        key = tuple(record[col] for col in key_columns)
        
        if key not in seen:
            seen.add(key)
            result.append(record)
        elif keep == 'last':
            # Remove previous occurrence, keep current
            result = [r for r in result if tuple(r[col] for col in key_columns) != key]
            result.append(record)
    
    return result
```

**Outlier Detection and Handling:**

```
def handle_outliers(data, columns, method='clip', n_std=3):
    """
    Detect and handle outliers in numerical columns
    """
    result = data.copy()
    
    for column in columns:
        values = data[column]
        mean = compute_mean(values)
        std = compute_std(values)
        
        lower_bound = mean - n_std * std
        upper_bound = mean + n_std * std
        
        if method == 'clip':
            result[column] = [
                clip(v, lower_bound, upper_bound)
                for v in values
            ]
        elif method == 'remove':
            result = filter_records(
                result,
                lambda r: lower_bound <= r[column] <= upper_bound
            )
        elif method == 'null':
            result[column] = [
                v if lower_bound <= v <= upper_bound else None
                for v in values
            ]
    
    return result
```

**Type Coercion:**

```
def coerce_types(data, type_spec):
    """
    Convert columns to specified types with error handling
    """
    result = data.copy()
    
    for column, target_type in type_spec.items():
        result[column] = [
            safe_convert(value, target_type)
            for value in data[column]
        ]
    
    return result

def safe_convert(value, target_type):
    """
    Attempt type conversion with fallback to None
    """
    try:
        if target_type == 'int':
            return int(value)
        elif target_type == 'float':
            return float(value)
        elif target_type == 'str':
            return str(value)
        elif target_type == 'bool':
            return bool(value)
    except (ValueError, TypeError):
        return None
```

**Text Normalization:**

```
def normalize_text(data, text_columns, operations):
    """
    Apply text normalization operations
    """
    result = data.copy()
    
    for column in text_columns:
        texts = data[column]
        
        for operation in operations:
            if operation == 'lowercase':
                texts = [t.lower() if t else t for t in texts]
            elif operation == 'remove_punctuation':
                texts = [remove_punctuation(t) if t else t for t in texts]
            elif operation == 'remove_whitespace':
                texts = [' '.join(t.split()) if t else t for t in texts]
            elif operation == 'remove_numbers':
                texts = [remove_digits(t) if t else t for t in texts]
        
        result[column] = texts
    
    return result
```

**Feature Type Separation:**

```
def separate_feature_types(data):
    """
    Partition features by data type for specialized processing
    """
    numerical = []
    categorical = []
    text = []
    datetime = []
    
    for column in data.columns:
        dtype = infer_column_type(data[column])
        
        if dtype == 'numerical':
            numerical.append(column)
        elif dtype == 'categorical':
            categorical.append(column)
        elif dtype == 'text':
            text.append(column)
        elif dtype == 'datetime':
            datetime.append(column)
    
    return {
        'numerical': select_columns(data, numerical),
        'categorical': select_columns(data, categorical),
        'text': select_columns(data, text),
        'datetime': select_columns(data, datetime)
    }
```

**Column-Specific Transformations:**

```
def apply_column_transforms(data, transforms):
    """
    Apply different transformations to different columns
    """
    result = {}
    
    for column, transform_func in transforms.items():
        if column in data:
            result[column] = transform_func(data[column])
    
    # Preserve untransformed columns
    for column in data:
        if column not in result:
            result[column] = data[column]
    
    return result

# Usage
transformed = apply_column_transforms(data, {
    'age': lambda x: clip(x, 0, 100),
    'income': lambda x: log_transform(x),
    'category': lambda x: encode_categories(x, method='label')
})
```

**Train-Test Split Aware Preprocessing:**

```
def create_fitted_pipeline(fit_steps, transform_steps):
    """
    Create pipeline that fits on training data and applies to any data
    """
    fitted_params = {}
    
    def fit(training_data):
        """
        Learn parameters from training data
        """
        current_data = training_data
        
        for step_name, fit_func in fit_steps:
            params = fit_func(current_data)
            fitted_params[step_name] = params
            current_data = apply_with_params(current_data, step_name, params)
        
        return fitted_params
    
    def transform(data):
        """
        Apply learned transformations to new data
        """
        result = data
        
        for step_name, transform_func in transform_steps:
            params = fitted_params.get(step_name, {})
            result = transform_func(result, **params)
        
        return result
    
    return fit, transform

# Usage
fit, transform = create_fitted_pipeline(
    fit_steps=[
        ('scaler', fit_standard_scaler),
        ('encoder', fit_label_encoder)
    ],
    transform_steps=[
        ('scaler', apply_standard_scaler),
        ('encoder', apply_label_encoder)
    ]
)

# Fit on training data
fit(training_data)

# Transform both training and test data consistently
train_transformed = transform(training_data)
test_transformed = transform(test_data)
```

**Conditional Preprocessing:**

```
def create_conditional_step(condition, true_branch, false_branch):
    """
    Apply different preprocessing based on data characteristics
    """
    def step(data):
        if condition(data):
            return true_branch(data)
        else:
            return false_branch(data)
    
    return step

# Usage
handle_missing = create_conditional_step(
    condition=lambda d: missing_percentage(d) < 0.05,
    true_branch=lambda d: drop_missing(d),
    false_branch=lambda d: impute_missing(d, strategy='median')
)
```

**Pipeline Monitoring:**

```
def create_monitored_pipeline(pipeline, monitors):
    """
    Wrap pipeline with monitoring/logging
    """
    def monitored_pipeline(data):
        # Pre-processing monitoring
        for monitor_name, monitor_func in monitors.get('pre', []):
            monitor_func(data, stage='pre')
        
        # Execute pipeline
        result = pipeline(data)
        
        # Post-processing monitoring
        for monitor_name, monitor_func in monitors.get('post', []):
            monitor_func(result, stage='post')
        
        return result
    
    return monitored_pipeline

# Usage
monitored = create_monitored_pipeline(
    pipeline=preprocessing_pipeline,
    monitors={
        'pre': [
            ('shape', log_data_shape),
            ('missing', log_missing_values),
            ('types', log_data_types)
        ],
        'post': [
            ('shape', log_data_shape),
            ('distributions', log_feature_distributions)
        ]
    }
)
```

**Error Recovery in Pipelines:**

```
def create_resilient_pipeline(steps, error_handlers):
    """
    Pipeline that handles errors gracefully
    """
    def pipeline(data):
        result = data
        
        for step_name, step_func in steps:
            try:
                result = step_func(result)
            except Exception as e:
                handler = error_handlers.get(step_name)
                
                if handler:
                    result = handler(result, e)
                else:
                    # Log and re-raise
                    log_error(f"Step {step_name} failed: {e}")
                    raise
        
        return result
    
    return pipeline

# Usage
pipeline = create_resilient_pipeline(
    steps=[
        ('parse_dates', parse_date_columns),
        ('handle_missing', impute_values),
        ('encode', encode_categoricals)
    ],
    error_handlers={
        'parse_dates': lambda data, err: data,  # Skip on failure
        'handle_missing': lambda data, err: drop_missing_rows(data)  # Fallback strategy
    }
)
```

