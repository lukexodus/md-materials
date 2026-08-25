## ColumnTransformer Selective Processing


ColumnTransformer enables applying different preprocessing steps to different subsets of features, making it ideal for heterogeneous datasets with mixed data types requiring distinct transformation strategies.

**Key points:**

- Applies different transformers to specific columns or column groups
- Handles mixed data types (numerical, categorical, text) in single workflow
- Supports column selection by name, index, or boolean mask
- Enables feature-specific preprocessing strategies
- Maintains column relationships and interpretability
- Integrates seamlessly with pipelines

**Example:**

```python
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder, OrdinalEncoder
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.impute import SimpleImputer
import pandas as pd
import numpy as np

# Create heterogeneous dataset
np.random.seed(42)
n_samples = 1000

# Generate mixed data
data = {
    'age': np.random.randint(18, 80, n_samples),
    'income': np.random.lognormal(10, 1, n_samples),
    'education': np.random.choice(['High School', 'Bachelor', 'Master', 'PhD'], n_samples),
    'city': np.random.choice(['New York', 'Chicago', 'Los Angeles', 'Houston'], n_samples),
    'description': [f"Person with {np.random.choice(['great', 'good', 'average'])} experience in {np.random.choice(['tech', 'finance', 'healthcare'])}" 
                   for _ in range(n_samples)],
    'rating': np.random.choice(['poor', 'fair', 'good', 'excellent'], n_samples),
    'score1': np.random.randn(n_samples),
    'score2': np.random.randn(n_samples),
    'has_car': np.random.choice([True, False], n_samples)
}

# Introduce some missing values
missing_indices = np.random.choice(n_samples, size=50, replace=False)
for idx in missing_indices[:25]:
    data['income'][idx] = np.nan
for idx in missing_indices[25:]:
    data['education'][idx] = None

df = pd.DataFrame(data)
y = (df['income'] > df['income'].median()).astype(int)

X_train, X_test, y_train, y_test = train_test_split(df, y, test_size=0.2, random_state=42)

# Define column groups
numeric_features = ['age', 'income', 'score1', 'score2']
categorical_nominal = ['city']
categorical_ordinal = ['education', 'rating']
text_features = ['description']
boolean_features = ['has_car']

# Create comprehensive column transformer
preprocessor = ColumnTransformer(
    transformers=[
        # Numeric features: impute missing values and scale
        ('num', Pipeline([
            ('imputer', SimpleImputer(strategy='median')),
            ('scaler', StandardScaler())
        ]), numeric_features),
        
        # Nominal categorical: one-hot encode
        ('cat_nominal', Pipeline([
            ('imputer', SimpleImputer(strategy='most_frequent')),
            ('onehot', OneHotEncoder(drop='first', sparse_output=False))
        ]), categorical_nominal),
        
        # Ordinal categorical: ordinal encode
        ('cat_ordinal', Pipeline([
            ('imputer', SimpleImputer(strategy='most_frequent')),
            ('ordinal', OrdinalEncoder(
                categories=[['High School', 'Bachelor', 'Master', 'PhD'],
                           ['poor', 'fair', 'good', 'excellent']]
            ))
        ]), categorical_ordinal),
        
        # Text features: TF-IDF
        ('text', TfidfVectorizer(max_features=50, stop_words='english'), 'description'),
        
        # Boolean features: pass through
        ('bool', 'passthrough', boolean_features)
    ],
    remainder='drop',  # Drop any remaining columns
    sparse_threshold=0  # Return dense array
)

# Create complete pipeline
column_pipeline = Pipeline([
    ('preprocessor', preprocessor),
    ('classifier', RandomForestClassifier(n_estimators=100, random_state=42))
])

# Fit and evaluate
column_pipeline.fit(X_train, y_train)
column_score = column_pipeline.score(X_test, y_test)
print(f"ColumnTransformer Pipeline Accuracy: {column_score:.4f}")

# Analyze transformed features
X_transformed = preprocessor.fit_transform(X_train)
print(f"Original features: {X_train.shape[1]}")
print(f"Transformed features: {X_transformed.shape[1]}")

# Get feature names after transformation
feature_names = (
    numeric_features +
    list(preprocessor.named_transformers_['cat_nominal'].named_steps['onehot'].get_feature_names_out(categorical_nominal)) +
    categorical_ordinal +
    list(preprocessor.named_transformers_['text'].get_feature_names_out()) +
    boolean_features
)

print(f"First 10 feature names: {feature_names[:10]}")
```

**Advanced ColumnTransformer Usage:**

```python
from sklearn.preprocessing import FunctionTransformer
from sklearn.feature_selection import SelectKBest

# Custom transformer for specific column processing
def extract_numeric_from_text(X):
    """Extract numeric patterns from text columns"""
    import re
    numeric_features = []
    for text in X:
        numbers = re.findall(r'\d+', str(text))
        numeric_features.append([len(numbers), sum(int(n) for n in numbers) if numbers else 0])
    return np.array(numeric_features)

# Advanced column transformer with custom functions
advanced_preprocessor = ColumnTransformer([
    # Numeric processing with feature engineering
    ('numeric_enhanced', Pipeline([
        ('imputer', SimpleImputer(strategy='median')),
        ('poly', PolynomialFeatures(degree=2, include_bias=False, interaction_only=True)),
        ('scaler', StandardScaler()),
        ('selector', SelectKBest(f_classif, k=10))
    ]), numeric_features),
    
    # Categorical with target encoding (using mean encoding)
    ('cat_target_encoded', Pipeline([
        ('imputer', SimpleImputer(strategy='most_frequent')),
        ('target_encoder', FunctionTransformer(lambda x: x))  # Placeholder for target encoding
    ]), categorical_nominal),
    
    # Text processing with custom extraction
    ('text_enhanced', Pipeline([
        ('text_numeric', FunctionTransformer(extract_numeric_from_text)),
        ('scaler', StandardScaler())
    ]), ['description']),
    
    # Keep original text features
    ('text_tfidf', TfidfVectorizer(max_features=30, ngram_range=(1, 2)), 'description')
], remainder='passthrough')

# Pipeline with advanced preprocessing
advanced_column_pipeline = Pipeline([
    ('preprocessor', advanced_preprocessor),
    ('feature_selection', SelectKBest(f_classif, k=50)),
    ('classifier', RandomForestClassifier(n_estimators=100, random_state=42))
])

advanced_column_pipeline.fit(X_train, y_train)
advanced_score = advanced_column_pipeline.score(X_test, y_test)
print(f"Advanced ColumnTransformer Accuracy: {advanced_score:.4f}")
```

**Hyperparameter Optimization with ColumnTransformer:**

```python
# Optimize hyperparameters across column transformer
ct_param_grid = {
    'preprocessor__num__scaler': [StandardScaler(), MinMaxScaler(), RobustScaler()],
    'preprocessor__text__max_features': [30, 50, 100],
    'preprocessor__text__ngram_range': [(1, 1), (1, 2)],
    'classifier__n_estimators': [50, 100, 200],
    'classifier__max_depth': [3, 5, None]
}

ct_grid_search = GridSearchCV(
    column_pipeline, 
    ct_param_grid, 
    cv=5, 
    scoring='accuracy',
    n_jobs=-1
)

ct_grid_search.fit(X_train, y_train)
print(f"Best ColumnTransformer parameters: {ct_grid_search.best_params_}")
```

ColumnTransformer provides essential functionality for real-world datasets with heterogeneous features requiring specialized preprocessing approaches.

