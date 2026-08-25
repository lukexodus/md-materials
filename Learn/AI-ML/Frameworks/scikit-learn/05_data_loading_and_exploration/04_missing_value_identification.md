## Missing Value Identification


### Basic Missing Value Detection

```python
def detect_missing_values(data, feature_names=None):
    """Comprehensive missing value detection"""
    if isinstance(data, pd.DataFrame):
        df = data
    else:
        df = pd.DataFrame(data, columns=feature_names)
    
    print("=== Missing Value Analysis ===")
    
    # Basic missing value counts
    missing_counts = df.isnull().sum()
    missing_percentages = (missing_counts / len(df)) * 100
    
    missing_summary = pd.DataFrame({
        'Missing_Count': missing_counts,
        'Missing_Percentage': missing_percentages
    })
    
    missing_features = missing_summary[missing_summary['Missing_Count'] > 0]
    
    if len(missing_features) == 0:
        print("No missing values detected")
        return missing_summary
    
    print(f"Features with missing values: {len(missing_features)}")
    print("Missing value summary:")
    print(missing_features.sort_values('Missing_Percentage', ascending=False))
    
    # Missing value patterns
    print("\n=== Missing Value Patterns ===")
    
    # Rows with any missing values
    rows_with_missing = df.isnull().any(axis=1).sum()
    print(f"Rows with any missing values: {rows_with_missing} ({rows_with_missing/len(df)*100:.2f}%)")
    
    # Complete cases
    complete_cases = df.dropna().shape[0]
    print(f"Complete cases: {complete_cases} ({complete_cases/len(df)*100:.2f}%)")
    
    # Missing value combinations
    if len(missing_features) > 1:
        missing_pattern = df.isnull()
        pattern_counts = missing_pattern.value_counts()
        print(f"Unique missing patterns: {len(pattern_counts)}")
        print("Top missing patterns:")
        print(pattern_counts.head())
    
    return missing_summary

# Usage with different data types
missing_summary = detect_missing_values(housing_df)
```

### Advanced Missing Value Analysis

```python
def advanced_missing_analysis(df):
    """Advanced missing value pattern analysis"""
    print("=== Advanced Missing Value Analysis ===")
    
    # Missing value heatmap data
    missing_matrix = df.isnull()
    
    # Co-occurrence of missing values
    missing_correlations = missing_matrix.corr()
    high_corr_missing = []
    
    for i in range(len(missing_correlations.columns)):
        for j in range(i+1, len(missing_correlations.columns)):
            corr_val = missing_correlations.iloc[i, j]
            if abs(corr_val) > 0.5 and not np.isnan(corr_val):
                high_corr_missing.append((
                    missing_correlations.columns[i],
                    missing_correlations.columns[j],
                    corr_val
                ))
    
    if high_corr_missing:
        print("Highly correlated missing patterns:")
        for feat1, feat2, corr in high_corr_missing:
            print(f"  {feat1} <-> {feat2}: {corr:.3f}")
    
    # Missing data mechanisms inference
    print("\n=== Missing Data Mechanism Analysis ===")
    
    numeric_cols = df.select_dtypes(include=[np.number]).columns
    
    for col in df.columns:
        if df[col].isnull().sum() > 0:
            print(f"\nAnalyzing missing pattern for: {col}")
            
            # Test relationship with other variables
            missing_indicator = df[col].isnull()
            
            for other_col in numeric_cols:
                if other_col != col and not df[other_col].isnull().all():
                    # Statistical test for missing at random
                    from scipy.stats import ttest_ind
                    
                    observed_values = df.loc[~missing_indicator, other_col].dropna()
                    missing_context = df.loc[missing_indicator, other_col].dropna()
                    
                    if len(observed_values) > 10 and len(missing_context) > 10:
                        stat, p_value = ttest_ind(observed_values, missing_context)
                        if p_value < 0.05:
                            print(f"  {other_col}: Potential MAR relationship (p={p_value:.3f})")

def visualize_missing_patterns(df):
    """Visualize missing value patterns"""
    import matplotlib.pyplot as plt
    import seaborn as sns
    
    # Missing value heatmap
    plt.figure(figsize=(12, 8))
    sns.heatmap(df.isnull(), cbar=True, yticklabels=False, cmap='viridis')
    plt.title('Missing Value Patterns')
    plt.xlabel('Features')
    plt.ylabel('Samples')
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.show()
    
    # Missing value bar plot
    missing_counts = df.isnull().sum()
    missing_counts = missing_counts[missing_counts > 0].sort_values(ascending=True)
    
    if len(missing_counts) > 0:
        plt.figure(figsize=(10, 6))
        missing_counts.plot(kind='barh')
        plt.title('Missing Values by Feature')
        plt.xlabel('Number of Missing Values')
        plt.tight_layout()
        plt.show()
```

### Handling Different Data Types

```python
def identify_missing_value_types(df):
    """Identify different representations of missing values"""
    print("=== Missing Value Type Identification ===")
    
    # Standard missing values
    standard_missing = df.isnull().sum()
    
    # Common missing value representations
    missing_representations = ['', ' ', 'NA', 'N/A', 'null', 'NULL', 'None', 
                              'missing', 'MISSING', '?', '-', '--', 'n/a']
    
    potential_missing = {}
    
    for col in df.columns:
        if df[col].dtype == 'object':  # Text columns
            col_missing = []
            for repr_val in missing_representations:
                count = (df[col] == repr_val).sum()
                if count > 0:
                    col_missing.append((repr_val, count))
            
            if col_missing:
                potential_missing[col] = col_missing
    
    if potential_missing:
        print("Potential missing value representations found:")
        for col, missing_list in potential_missing.items():
            print(f"  {col}:")
            for repr_val, count in missing_list:
                print(f"    '{repr_val}': {count} occurrences")
    
    # Numeric anomalies that might represent missing values
    numeric_cols = df.select_dtypes(include=[np.number]).columns
    for col in numeric_cols:
        # Check for extreme outliers that might be missing value codes
        Q1 = df[col].quantile(0.25)
        Q3 = df[col].quantile(0.75)
        IQR = Q3 - Q1
        
        extreme_lower = Q1 - 3 * IQR
        extreme_upper = Q3 + 3 * IQR
        
        extreme_values = df[(df[col] < extreme_lower) | (df[col] > extreme_upper)][col]
        
        # Common missing value codes in numeric data
        common_codes = [-999, -99, 999, 9999, 0]  # 0 might be legitimate
        
        for code in common_codes:
            count = (df[col] == code).sum()
            if count > len(df) * 0.01:  # More than 1% of data
                print(f"  {col}: Value {code} appears {count} times ({count/len(df)*100:.1f}%)")

def clean_missing_representations(df):
    """Convert various missing representations to standard NaN"""
    df_cleaned = df.copy()
    
    missing_representations = ['', ' ', 'NA', 'N/A', 'null', 'NULL', 'None', 
                              'missing', 'MISSING', '?', '-', '--', 'n/a']
    
    # Replace string representations with NaN
    df_cleaned = df_cleaned.replace(missing_representations, np.nan)
    
    # Convert numeric columns that might have been read as strings
    for col in df_cleaned.columns:
        if df_cleaned[col].dtype == 'object':
            # Try to convert to numeric
            numeric_version = pd.to_numeric(df_cleaned[col], errors='coerce')
            if not numeric_version.isnull().all():
                df_cleaned[col] = numeric_version
    
    return df_cleaned
```

