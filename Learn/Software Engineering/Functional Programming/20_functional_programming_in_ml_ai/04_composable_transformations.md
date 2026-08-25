## Composable Transformations


Composable transformations enable building complex data processing operations from simple, reusable functions. Composition creates transformation chains where each function's output type matches the next function's input type, ensuring type safety and correctness.

### Function Composition Primitives

#### Basic Composition

```python
def compose(*functions):
    """
    Compose functions right-to-left:
    compose(f, g, h)(x) = f(g(h(x)))
    """
    def composed(data):
        result = data
        for func in reversed(functions):
            result = func(result)
        return result
    
    return composed


# Usage
pipeline = compose(
    normalize_features,
    remove_outliers,
    handle_missing_values,
)

result = pipeline(raw_data)
```

#### Pipe Operator (Left-to-Right Composition)

```python
def pipe(data, *functions):
    """
    Apply functions left-to-right:
    pipe(x, f, g, h) = h(g(f(x)))
    """
    result = data
    for func in functions:
        result = func(result)
    return result


# Usage
result = pipe(
    raw_data,
    handle_missing_values,
    remove_outliers,
    normalize_features
)
```

#### Partial Application

```python
def partial(func, **fixed_params):
    """
    Fix some parameters of a function, creating a new function
    """
    def partial_func(*args, **kwargs):
        merged_params = {**fixed_params, **kwargs}
        return func(*args, **merged_params)
    
    return partial_func


# Usage
normalize_standard = partial(normalize, method='standard')
normalize_minmax = partial(normalize, method='minmax', range=(0, 1))

pipeline = compose(
    normalize_standard,
    encode_categoricals,
    select_features
)
```

#### Curry Functions

```python
def curry(func):
    """
    Convert multi-argument function to sequence of single-argument functions
    """
    def curried(*args):
        if len(args) >= func.__code__.co_argcount:
            return func(*args)
        else:
            return lambda *more_args: curried(*(args + more_args))
    
    return curried


# Usage
@curry
def scale_column(column, method, data):
    return apply_scaling(data, column, method)

scale_age_standard = scale_column('age', 'standard')
scale_income_minmax = scale_column('income', 'minmax')

# Compose curried transformations
pipeline = compose(
    scale_age_standard,
    scale_income_minmax,
    encode_categories
)
```

#### Functor Pattern (Map)

```python
def fmap(transform_func):
    """
    Lift a transformation to operate on containers of data
    """
    def mapped(container):
        return [transform_func(item) for item in container]
    
    return mapped


# Usage
transform_record = compose(
    normalize_values,
    extract_features,
    validate_record
)

# Apply to each record in dataset
transform_dataset = fmap(transform_record)
processed_records = transform_dataset(raw_records)
```

#### Monadic Composition (flatMap/bind)

```python
def flat_map(transform_func):
    """
    Apply transformation that returns a list and flatten results
    """
    def flat_mapped(container):
        result = []
        for item in container:
            transformed = transform_func(item)
            if isinstance(transformed, list):
                result.extend(transformed)
            else:
                result.append(transformed)
        return result
    
    return flat_mapped


# Usage: Generate multiple features per record
def generate_feature_combinations(record):
    """Returns list of feature variants"""
    return [
        {'type': 'original', **record},
        {'type': 'normalized', **normalize(record)},
        {'type': 'augmented', **augment(record)}
    ]

expand_features = flat_map(generate_feature_combinations)
expanded_dataset = expand_features(records)
```

#### Applicative Composition

```python
def apply(func_container, value_container):
    """
    Apply functions in one container to values in another
    """
    return [
        func(value)
        for func in func_container
        for value in value_container
    ]


# Usage: Apply multiple transformations to multiple columns
transformations = [normalize, standardize, log_transform]
columns = ['age', 'income', 'balance']

transformed_columns = apply(transformations, columns)
```

#### Transducers

```python
def mapping(transform_func):
    """
    Create a transducer for mapping
    """
    def transducer(reducing_func):
        def reducer(accumulator, value):
            transformed = transform_func(value)
            return reducing_func(accumulator, transformed)
        return reducer
    return transducer


def filtering(predicate):
    """
    Create a transducer for filtering
    """
    def transducer(reducing_func):
        def reducer(accumulator, value):
            if predicate(value):
                return reducing_func(accumulator, value)
            return accumulator
        return reducer
    return transducer


def transduce(transducer, reducing_func, initial, collection):
    """
    Apply transducer to collection
    """
    reducer = transducer(reducing_func)
    result = initial
    for item in collection:
        result = reducer(result, item)
    return result


# Usage
transform = compose(
    filtering(lambda x: x['age'] > 18),
    mapping(lambda x: {
        'age': x['age'],
        'category': categorize_age(x['age'])
    })
)

result = transduce(
    transform,
    lambda acc, val: acc + [val],
    [],
    records
)
```

#### Lens Composition

```python
def lens(getter, setter):
    """
    Create a lens from getter and setter functions
    """
    return {'get': getter, 'set': setter}


def compose_lenses(outer, inner):
    """
    Compose two lenses to access deeply nested data
    """
    return lens(
        getter=lambda obj: inner['get'](outer['get'](obj)),
        setter=lambda obj, val: outer['set'](
            obj,
            inner['set'](outer['get'](obj), val)
        )
    )


def view(lens, obj):
    """Get value through lens"""
    return lens['get'](obj)


def set_value(lens, obj, value):
    """Set value through lens"""
    return lens['set'](obj, value)


def over(lens, func, obj):
    """Transform value through lens"""
    current = view(lens, obj)
    new_value = func(current)
    return set_value(lens, obj, new_value)


# Usage: Transform nested features
features_lens = lens(
    getter=lambda record: record['features'],
    setter=lambda record, features: {**record, 'features': features}
)

age_lens = lens(
    getter=lambda features: features['age'],
    setter=lambda features, age: {**features, 'age': age}
)

age_in_record = compose_lenses(features_lens, age_lens)

# Transform age value
normalized_record = over(age_in_record, normalize_age, record)
```

#### Composable Validators

```python
def validate_all(*validators):
    """
    Compose validators with AND logic
    """
    def combined_validator(data):
        errors = []
        for validator in validators:
            result = validator(data)
            if not result.is_valid:
                errors.extend(result.errors)
        
        return ValidationResult(
            is_valid=len(errors) == 0,
            errors=errors
        )
    
    return combined_validator


def validate_any(*validators):
    """
    Compose validators with OR logic
    """
    def combined_validator(data):
        for validator in validators:
            result = validator(data)
            if result.is_valid:
                return result
        
        return ValidationResult(
            is_valid=False,
            errors=['No validator passed']
        )
    
    return combined_validator


# Usage
validate_record = validate_all(
    validate_schema,
    validate_ranges,
    validate_business_rules
)

validate_numeric = validate_any(
    validate_int,
    validate_float
)
```

#### Composable Error Handling

```python
def try_transform(transform_func, fallback_func=None):
    """
    Wrap transformation with error handling
    """
    def safe_transform(data):
        try:
            return Success(transform_func(data))
        except Exception as e:
            if fallback_func:
                return Success(fallback_func(data))
            else:
                return Failure(e)
    
    return safe_transform


def chain_results(*transforms):
    """
    Compose transformations that return Success/Failure
    """
    def chained(data):
        result = Success(data)
        
        for transform in transforms:
            if isinstance(result, Failure):
                return result
            
            result = transform(result.value)
        
        return result
    
    return chained


# Usage
pipeline = chain_results(
    try_transform(parse_dates, fallback_func=use_default_dates),
    try_transform(normalize_features),
    try_transform(encode_categoricals, fallback_func=drop_categorical_columns)
)

result = pipeline(raw_data)

if isinstance(result, Success):
    processed_data = result.value
else:
    handle_error(result.error)
```

#### Conditional Composition

```python
def when(predicate, transform_func):
    """
    Apply transformation only when predicate is true
    """
    def conditional_transform(data):
        if predicate(data):
            return transform_func(data)
        return data
    
    return conditional_transform


def unless(predicate, transform_func):
    """
    Apply transformation only when predicate is false
    """
    return when(lambda d: not predicate(d), transform_func)


# Usage
pipeline = compose(
    when(has_missing_values, impute_missing),
    when(has_outliers, remove_outliers),
    unless(is_normalized, normalize_features)
)
```

#### Memoization for Composition

```python
def memoize(func):
    """
    Cache results of expensive transformations
    """
    cache = {}
    
    def memoized(*args):
        key = hash_args(args)
        if key not in cache:
            cache[key] = func(*args)
        return cache[key]
    
    return memoized


# Usage: Memoize expensive feature extraction
extract_text_features_cached = memoize(extract_text_features)
compute_embeddings_cached = memoize(compute_embeddings)

pipeline = compose(
    extract_text_features_cached,
    compute_embeddings_cached,
    classify_sentiment
)
```

#### Branching Composition

```python
def branch(*branches):
    """
    Apply multiple transformations and merge results
    """
    def branched_transform(data):
        results = [transform(data) for transform in branches]
        return merge_results(results)
    
    return branched_transform


# Usage: Process different feature types separately
pipeline = branch(
    compose(select_numerical, normalize, scale),
    compose(select_categorical, encode_onehot),
    compose(select_text, tokenize, embed)
)

combined_features = pipeline(raw_data)
```

