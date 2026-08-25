## Statistical Summaries


### Descriptive Statistics

```python
def comprehensive_statistical_summary(df, target_col=None):
    """Generate comprehensive statistical summaries"""
    print("=== Comprehensive Statistical Summary ===")
    
    # Separate numeric and categorical columns
    numeric_cols = df.select_dtypes(include=[np.number]).columns.tolist()
    categorical_cols = df.select_dtypes(include=['object', 'category']).columns.tolist()
    
    if target_col in numeric_cols:
        numeric_cols.remove(target_col)
    if target_col in categorical_cols:
        categorical_cols.remove(target_col)
    
    # Numeric variable summary
    if numeric_cols:
        print("\n=== Numeric Variables Summary ===")
        numeric_summary = df[numeric_cols].describe()
        
        # Add additional statistics
        additional_stats = pd.DataFrame({
            'skewness': df[numeric_cols].skew(),
            'kurtosis': df[numeric_cols].kurtosis(),
            'variance': df[numeric_cols].var(),
            'range': df[numeric_cols].max() - df[numeric_cols].min()
        })
        
        extended_summary = pd.concat([numeric_summary, additional_stats.T])
        print(extended_summary.round(3))
        
        # Distribution analysis
        print("\n=== Distribution Analysis ===")
        for col in numeric_cols:
            data = df[col].dropna()
            
            # Normality assessment
            from scipy import stats
            _, p_value = stats.shapiro(data[:5000])  # Limit sample size for Shapiro-Wilk
            
            print(f"{col}:")
            print(f"  Normality test p-value: {p_value:.4f}")
            print(f"  Distribution shape: {'Normal-like' if p_value > 0.05 else 'Non-normal'}")
            
            # Outlier detection using IQR
            Q1 = data.quantile(0.25)
            Q3 = data.quantile(0.75)
            IQR = Q3 - Q1
            outliers = data[(data < Q1 - 1.5*IQR) | (data > Q3 + 1.5*IQR)]
            print(f"  Outliers (IQR method): {len(outliers)} ({len(outliers)/len(data)*100:.1f}%)")
    
    # Categorical variable summary
    if categorical_cols:
        print("\n=== Categorical Variables Summary ===")
        for col in categorical_cols:
            unique_values = df[col].nunique()
            most_frequent = df[col].mode().iloc[0] if len(df[col].mode()) > 0 else 'N/A'
            most_frequent_count = df[col].value_counts().iloc[0] if unique_values > 0 else 0
            
            print(f"{col}:")
            print(f"  Unique values: {unique_values}")
            print(f"  Most frequent: {most_frequent} ({most_frequent_count} times)")
            print(f"  Cardinality: {'High' if unique_values > 50 else 'Medium' if unique_values > 10 else 'Low'}")
            
            if unique_values <= 10:
                print(f"  Value counts:")
                for value, count in df[col].value_counts().head().items():
                    print(f"    {value}: {count} ({count/len(df)*100:.1f}%)")

def correlation_analysis(df, target_col=None):
    """Detailed correlation analysis"""
    print("=== Correlation Analysis ===")
    
    numeric_df = df.select_dtypes(include=[np.number])
    
    if len(numeric_df.columns) < 2:
        print("Insufficient numeric columns for correlation analysis")
        return
    
    # Correlation matrix
    corr_matrix = numeric_df.corr()
    
    # Find highly correlated pairs
    high_corr_pairs = []
    for i in range(len(corr_matrix.columns)):
        for j in range(i+1, len(corr_matrix.columns)):
            corr_val = corr_matrix.iloc[i, j]
            if abs(corr_val) > 0.7:
                high_corr_pairs.append((
                    corr_matrix.columns[i],
                    corr_matrix.columns[j],
                    corr_val
                ))
    
    if high_corr_pairs:
        print("Highly correlated feature pairs (|correlation| > 0.7):")
        for feat1, feat2, corr in sorted(high_corr_pairs, key=lambda x: abs(x[2]), reverse=True):
            print(f"  {feat1} <-> {feat2}: {corr:.3f}")
    
    # Target correlation if specified
    if target_col and target_col in numeric_df.columns:
        print(f"\nCorrelation with target ({target_col}):")
        target_corr = corr_matrix[target_col].abs().sort_values(ascending=False)
        for feature, corr in target_corr.head(10).items():
            if feature != target_col:
                print(f"  {feature}: {corr:.3f}")

def data_quality_assessment(df):
    """Comprehensive data quality assessment"""
    print("=== Data Quality Assessment ===")
    
    total_cells = df.shape[0] * df.shape[1]
    
    # Completeness
    missing_cells = df.isnull().sum().sum()
    completeness = (total_cells - missing_cells) / total_cells
    print(f"Data completeness: {completeness:.2%}")
    
    # Uniqueness
    duplicate_rows = df.duplicated().sum()
    uniqueness = (len(df) - duplicate_rows) / len(df)
    print(f"Row uniqueness: {uniqueness:.2%}")
    
    # Consistency checks
    print(f"Duplicate rows: {duplicate_rows}")
    print(f"Columns with mixed data types: {sum(df.dtypes == 'object')}")
    
    # Feature-specific quality
    quality_issues = {}
    
    for col in df.columns:
        issues = []
        
        # High cardinality in categorical
        if df[col].dtype == 'object' and df[col].nunique() > len(df) * 0.8:
            issues.append("High cardinality categorical")
        
        # Potential encoding issues
        if df[col].dtype == 'object':
            if df[col].str.contains('�', na=False).any():
                issues.append("Potential encoding issues")
        
        # Extreme outliers in numeric
        if df[col].dtype in ['int64', 'float64']:
            Q1 = df[col].quantile(0.25)
            Q3 = df[col].quantile(0.75)
            IQR = Q3 - Q1
            extreme_outliers = df[(df[col] < Q1 - 3*IQR) | (df[col] > Q3 + 3*IQR)][col]
            if len(extreme_outliers) > len(df) * 0.05:
                issues.append("High proportion of extreme outliers")
        
        if issues:
            quality_issues[col] = issues
    
    if quality_issues:
        print("\nData quality issues detected:")
        for col, issues in quality_issues.items():
            print(f"  {col}: {', '.join(issues)}")
    
    return {
        'completeness': completeness,
        'uniqueness': uniqueness,
        'duplicate_rows': duplicate_rows,
        'quality_issues': quality_issues
    }
```

### Visualization for Exploration

```python
def create_exploration_visualizations(df, target_col=None, sample_size=1000):
    """Create comprehensive exploration visualizations"""
    import matplotlib.pyplot as plt
    import seaborn as sns
    
    # Sample data if too large
    if len(df) > sample_size:
        df_sample = df.sample(n=sample_size, random_state=42)
    else:
        df_sample = df.copy()
    
    numeric_cols = df_sample.select_dtypes(include=[np.number]).columns.tolist()
    categorical_cols = df_sample.select_dtypes(include=['object', 'category']).columns.tolist()
    
    # Remove target from feature lists
    if target_col in numeric_cols:
        numeric_cols.remove(target_col)
    if target_col in categorical_cols:
        categorical_cols.remove(target_col)
    
    # Distribution plots for numeric variables
    if numeric_cols:
        n_cols = min(4, len(numeric_cols))
        n_rows = (len(numeric_cols) - 1) // n_cols + 1
        
        fig, axes = plt.subplots(n_rows, n_cols, figsize=(15, 4*n_rows))
        axes = axes.ravel() if n_rows * n_cols > 1 else [axes]
        
        for i, col in enumerate(numeric_cols):
            if i < len(axes):
                df_sample[col].hist(bins=30, ax=axes[i], alpha=0.7)
                axes[i].set_title(f'Distribution of {col}')
                axes[i].set_xlabel(col)
                axes[i].set_ylabel('Frequency')
        
        # Hide unused subplots
        for i in range(len(numeric_cols), len(axes)):
            axes[i].set_visible(False)
        
        plt.tight_layout()
        plt.show()
    
    # Correlation heatmap
    if len(numeric_cols) > 1:
        plt.figure(figsize=(12, 8))
        corr_matrix = df_sample[numeric_cols].corr()
        sns.heatmap(corr_matrix, annot=True, cmap='coolwarm', center=0,
                    square=True, fmt='.2f', cbar_kws={'label': 'Correlation Coefficient'})
        plt.title('Feature Correlation Heatmap')
        plt.tight_layout()
        plt.show()
    
    # Categorical variable distributions
    if categorical_cols:
        for col in categorical_cols[:4]:  # Limit to first 4 categorical variables
            plt.figure(figsize=(10, 6))
            value_counts = df_sample[col].value_counts().head(10)
            
            if len(value_counts) > 1:
                value_counts.plot(kind='bar')
                plt.title(f'Distribution of {col}')
                plt.xlabel(col)
                plt.ylabel('Count')
                plt.xticks(rotation=45)
                plt.tight_layout()
                plt.show()
    
    # Target variable analysis
    if target_col and target_col in df_sample.columns:
        plt.figure(figsize=(12, 4))
        
        if df_sample[target_col].dtype in ['object', 'category'] or df_sample[target_col].nunique() <= 20:
            # Categorical target
            plt.subplot(1, 2, 1)
            df_sample[target_col].value_counts().plot(kind='bar')
            plt.title(f'Target Distribution: {target_col}')
            plt.xticks(rotation=45)
            
            plt.subplot(1, 2, 2)
            df_sample[target_col].value_counts().plot(kind='pie', autopct='%1.1f%%')
            plt.title(f'Target Proportions: {target_col}')
            plt.ylabel('')
            
        else:
            # Numeric target
            plt.subplot(1, 2, 1)
            df_sample[target_col].hist(bins=30, alpha=0.7)
            plt.title(f'Target Distribution: {target_col}')
            plt.xlabel(target_col)
            plt.ylabel('Frequency')
            
            plt.subplot(1, 2, 2)
            plt.boxplot(df_sample[target_col].dropna())
            plt.title(f'Target Boxplot: {target_col}')
            plt.ylabel(target_col)
        
        plt.tight_layout()
        plt.show()
    
    # Feature vs Target relationships
    if target_col and len(numeric_cols) > 0:
        fig, axes = plt.subplots(2, 2, figsize=(15, 10))
        axes = axes.ravel()
        
        for i, col in enumerate(numeric_cols[:4]):
            if df_sample[target_col].dtype in ['object', 'category'] or df_sample[target_col].nunique() <= 20:
                # Box plot for categorical target
                df_sample.boxplot(column=col, by=target_col, ax=axes[i])
                axes[i].set_title(f'{col} by {target_col}')
            else:
                # Scatter plot for numeric target
                axes[i].scatter(df_sample[col], df_sample[target_col], alpha=0.6)
                axes[i].set_xlabel(col)
                axes[i].set_ylabel(target_col)
                axes[i].set_title(f'{col} vs {target_col}')
        
        plt.tight_layout()
        plt.show()

def generate_data_profile_report(df, target_col=None):
    """Generate a comprehensive data profile report"""
    print("="*60)
    print("COMPREHENSIVE DATA EXPLORATION REPORT")
    print("="*60)
    
    # Basic dataset information
    print(f"Dataset shape: {df.shape}")
    print(f"Memory usage: {df.memory_usage(deep=True).sum() / 1024**2:.2f} MB")
    print(f"Target variable: {target_col if target_col else 'Not specified'}")
    
    # Data types summary
    print(f"\nData types:")
    dtype_counts = df.dtypes.value_counts()
    for dtype, count in dtype_counts.items():
        print(f"  {dtype}: {count} columns")
    
    # Missing values
    missing_summary = detect_missing_values(df)
    
    # Statistical summaries
    comprehensive_statistical_summary(df, target_col)
    
    # Correlation analysis
    correlation_analysis(df, target_col)
    
    # Data quality assessment
    quality_metrics = data_quality_assessment(df)
    
    # Feature insights
    print("\n=== Feature Insights ===")
    
    numeric_cols = df.select_dtypes(include=[np.number]).columns
    categorical_cols = df.select_dtypes(include=['object', 'category']).columns
    
    # High cardinality features
    high_cardinality = []
    for col in categorical_cols:
        cardinality = df[col].nunique()
        if cardinality > 50:
            high_cardinality.append((col, cardinality))
    
    if high_cardinality:
        print("High cardinality categorical features:")
        for col, cardinality in high_cardinality:
            print(f"  {col}: {cardinality} unique values")
    
    # Potential feature engineering opportunities
    print("\n=== Feature Engineering Opportunities ===")
    
    # Date/time features
    potential_dates = []
    for col in df.columns:
        if df[col].dtype == 'object':
            # Try to parse a sample as datetime
            sample = df[col].dropna().head(100)
            try:
                pd.to_datetime(sample, errors='raise')
                potential_dates.append(col)
            except:
                pass
    
    if potential_dates:
        print("Potential date/time features:")
        for col in potential_dates:
            print(f"  {col}")
    
    # Text features
    text_features = []
    for col in categorical_cols:
        if df[col].dtype == 'object':
            avg_length = df[col].dropna().astype(str).str.len().mean()
            if avg_length > 20:  # Arbitrary threshold for text
                text_features.append((col, avg_length))
    
    if text_features:
        print("Potential text features:")
        for col, avg_len in text_features:
            print(f"  {col}: Average length {avg_len:.1f} characters")
    
    # Highly skewed numeric features
    skewed_features = []
    for col in numeric_cols:
        skewness = df[col].skew()
        if abs(skewness) > 2:
            skewed_features.append((col, skewness))
    
    if skewed_features:
        print("Highly skewed numeric features (|skewness| > 2):")
        for col, skew in skewed_features:
            print(f"  {col}: {skew:.2f}")
    
    return {
        'basic_info': {
            'shape': df.shape,
            'memory_mb': df.memory_usage(deep=True).sum() / 1024**2,
            'dtypes': dtype_counts.to_dict()
        },
        'missing_summary': missing_summary,
        'quality_metrics': quality_metrics,
        'feature_insights': {
            'high_cardinality': high_cardinality,
            'potential_dates': potential_dates,
            'text_features': text_features,
            'skewed_features': skewed_features
        }
    }

# Advanced exploration functions

def detect_feature_relationships(df, threshold=0.1):
    """Detect complex relationships between features"""
    print("=== Advanced Feature Relationship Detection ===")
    
    numeric_cols = df.select_dtypes(include=[np.number]).columns
    
    # Non-linear relationships detection
    from scipy.stats import spearmanr
    
    nonlinear_relationships = []
    
    for i, col1 in enumerate(numeric_cols):
        for col2 in numeric_cols[i+1:]:
            # Pearson vs Spearman comparison
            pearson_corr = df[col1].corr(df[col2])
            spearman_corr, _ = spearmanr(df[col1].dropna(), df[col2].dropna())
            
            # Large difference suggests non-linear relationship
            if abs(spearman_corr - pearson_corr) > threshold and abs(spearman_corr) > 0.3:
                nonlinear_relationships.append({
                    'feature1': col1,
                    'feature2': col2,
                    'pearson': pearson_corr,
                    'spearman': spearman_corr,
                    'difference': abs(spearman_corr - pearson_corr)
                })
    
    if nonlinear_relationships:
        print("Potential non-linear relationships detected:")
        for rel in sorted(nonlinear_relationships, key=lambda x: x['difference'], reverse=True):
            print(f"  {rel['feature1']} <-> {rel['feature2']}")
            print(f"    Pearson: {rel['pearson']:.3f}, Spearman: {rel['spearman']:.3f}")
            print(f"    Difference: {rel['difference']:.3f}")

def identify_feature_groups(df, correlation_threshold=0.8):
    """Identify groups of highly correlated features"""
    print("=== Feature Grouping Analysis ===")
    
    numeric_df = df.select_dtypes(include=[np.number])
    corr_matrix = numeric_df.corr().abs()
    
    # Find connected components of highly correlated features
    import networkx as nx
    
    # Create graph
    G = nx.Graph()
    features = corr_matrix.columns
    
    # Add edges for high correlations
    for i, feat1 in enumerate(features):
        for feat2 in features[i+1:]:
            if corr_matrix.loc[feat1, feat2] > correlation_threshold:
                G.add_edge(feat1, feat2, weight=corr_matrix.loc[feat1, feat2])
    
    # Find connected components (feature groups)
    feature_groups = list(nx.connected_components(G))
    
    if feature_groups:
        print(f"Found {len(feature_groups)} feature groups with correlation > {correlation_threshold}:")
        for i, group in enumerate(feature_groups, 1):
            if len(group) > 1:
                print(f"  Group {i}: {list(group)}")
                
                # Calculate average correlation within group
                group_corrs = []
                group_list = list(group)
                for j, feat1 in enumerate(group_list):
                    for feat2 in group_list[j+1:]:
                        group_corrs.append(corr_matrix.loc[feat1, feat2])
                
                avg_corr = np.mean(group_corrs)
                print(f"    Average correlation: {avg_corr:.3f}")

def suggest_preprocessing_steps(df, target_col=None):
    """Suggest preprocessing steps based on data analysis"""
    print("=== Recommended Preprocessing Steps ===")
    
    recommendations = []
    
    # Missing value handling
    missing_counts = df.isnull().sum()
    if missing_counts.sum() > 0:
        recommendations.append("Handle missing values:")
        for col, count in missing_counts[missing_counts > 0].items():
            percentage = count / len(df) * 100
            if percentage < 5:
                recommendations.append(f"  - {col}: Consider imputation (only {percentage:.1f}% missing)")
            elif percentage > 50:
                recommendations.append(f"  - {col}: Consider dropping ({percentage:.1f}% missing)")
            else:
                recommendations.append(f"  - {col}: Careful imputation needed ({percentage:.1f}% missing)")
    
    # Scaling recommendations
    numeric_cols = df.select_dtypes(include=[np.number]).columns
    if target_col in numeric_cols:
        numeric_cols = numeric_cols.drop(target_col)
    
    if len(numeric_cols) > 0:
        # Check scales
        ranges = df[numeric_cols].max() - df[numeric_cols].min()
        max_range = ranges.max()
        min_range = ranges.min()
        
        if max_range / min_range > 100:
            recommendations.append("Apply feature scaling (large scale differences detected)")
        
        # Check distributions
        skewed_features = []
        for col in numeric_cols:
            skewness = abs(df[col].skew())
            if skewness > 2:
                skewed_features.append(col)
        
        if skewed_features:
            recommendations.append(f"Consider transformation for skewed features: {skewed_features}")
    
    # Categorical encoding
    categorical_cols = df.select_dtypes(include=['object', 'category']).columns
    if target_col in categorical_cols:
        categorical_cols = categorical_cols.drop(target_col)
    
    if len(categorical_cols) > 0:
        recommendations.append("Categorical encoding needed:")
        for col in categorical_cols:
            cardinality = df[col].nunique()
            if cardinality == 2:
                recommendations.append(f"  - {col}: Binary encoding or label encoding")
            elif cardinality < 10:
                recommendations.append(f"  - {col}: One-hot encoding")
            else:
                recommendations.append(f"  - {col}: Target encoding or embedding (high cardinality: {cardinality})")
    
    # Outlier handling
    for col in numeric_cols:
        Q1 = df[col].quantile(0.25)
        Q3 = df[col].quantile(0.75)
        IQR = Q3 - Q1
        outliers = df[(df[col] < Q1 - 1.5*IQR) | (df[col] > Q3 + 1.5*IQR)]
        
        if len(outliers) > len(df) * 0.05:  # More than 5% outliers
            recommendations.append(f"Consider outlier handling for {col} ({len(outliers)} outliers, {len(outliers)/len(df)*100:.1f}%)")
    
    # Feature selection recommendations
    if len(df.columns) > 50:
        recommendations.append("Consider feature selection due to high dimensionality")
    
    # Print recommendations
    for rec in recommendations:
        print(rec)
    
    return recommendations

# Usage example combining all functions
def complete_data_exploration(data_source, target_col=None, sample_size=None):
    """Complete data exploration workflow"""
    
    # Load data
    if isinstance(data_source, str):
        if data_source.endswith('.csv'):
            df = pd.read_csv(data_source)
        elif data_source.endswith('.xlsx'):
            df = pd.read_excel(data_source)
        else:
            raise ValueError("Unsupported file format")
    elif hasattr(data_source, 'data'):
        # Scikit-learn dataset
        df = pd.DataFrame(data_source.data, columns=data_source.feature_names)
        if target_col is None and hasattr(data_source, 'target'):
            df['target'] = data_source.target
            target_col = 'target'
    else:
        df = data_source
    
    # Sample if needed
    if sample_size and len(df) > sample_size:
        df = df.sample(n=sample_size, random_state=42)
        print(f"Dataset sampled to {sample_size} rows for exploration")
    
    # Run complete analysis
    profile_report = generate_data_profile_report(df, target_col)
    
    # Advanced analyses
    detect_feature_relationships(df)
    identify_feature_groups(df)
    suggest_preprocessing_steps(df, target_col)
    
    # Generate visualizations
    create_exploration_visualizations(df, target_col)
    
    return profile_report, df
```

