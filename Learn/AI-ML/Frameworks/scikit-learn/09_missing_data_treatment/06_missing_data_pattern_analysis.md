## Missing Data Pattern Analysis


Understanding missing data patterns is crucial for selecting appropriate imputation strategies and assessing the potential impact of missingness on analysis results.

### Pattern Classification

**Complete Cases**: Samples with no missing values across any feature. These represent the ideal scenario for analysis and modeling.

**Monotone Missing Pattern**: A structured pattern where if a feature is missing for a sample, all subsequent features (in some ordering) are also missing. This pattern is common in longitudinal studies or surveys with conditional questions.

**Arbitrary Missing Pattern**: Random or complex patterns of missingness that don't follow structured rules. This is the most challenging scenario for imputation and analysis.

### Analytical Approaches

**Missing Data Matrix Visualization**: Creating heatmaps or bar charts to visualize missing data patterns across features and samples. This helps identify systematic patterns and assess the extent of missingness.

**Correlation Analysis**: Examining correlations between missing data indicators can reveal whether certain features tend to be missing together, suggesting underlying mechanisms.

**Statistical Testing**: Implementing Little's MCAR test to assess whether data is missing completely at random, providing insights into the appropriate imputation strategy.

**Pattern Frequency Analysis**: Counting and analyzing the frequency of different missing data patterns to understand the dominant patterns in the dataset.

### Impact Assessment

**Information Loss Quantification**: Measuring how much information is lost due to missing data, considering both the quantity of missing values and their distribution across features.

**Bias Evaluation**: Assessing whether missing data introduces bias by comparing characteristics of complete cases versus cases with missing values.

**Power Analysis**: Determining how missing data affects statistical power and the ability to detect meaningful relationships in the data.

### Visualization and Reporting

**Missing Data Profiles**: Creating comprehensive reports that summarize missing data patterns, their frequency, and potential implications for analysis.

**Interactive Visualizations**: Developing interactive plots that allow exploration of missing data patterns across different dimensions and subgroups.

**Pattern Evolution**: For longitudinal data, tracking how missing data patterns evolve over time and identifying trends or systematic changes.

**Key points**:

- Guides the selection of appropriate imputation strategies
- Helps identify potential biases and limitations in the analysis
- Informs decisions about feature engineering and model selection
- Provides insights into data collection processes and quality issues
- Essential for transparent reporting of analytical limitations

**Example**:

```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.stats import chi2_contingency

class MissingDataAnalyzer:
    """Comprehensive missing data pattern analysis toolkit."""
    
    def __init__(self, data):
        self.data = data
        self.missing_matrix = data.isnull()
        self.missing_counts = self.missing_matrix.sum()
        self.missing_percentages = (self.missing_counts / len(data)) * 100
    
    def pattern_summary(self):
        """Generate comprehensive missing data summary."""
        total_values = self.data.shape[0] * self.data.shape[1]
        total_missing = self.missing_matrix.sum().sum()
        
        summary = {
            'total_samples': self.data.shape[0],
            'total_features': self.data.shape[1],
            'total_values': total_values,
            'total_missing': total_missing,
            'missing_percentage': (total_missing / total_values) * 100,
            'complete_cases': self.missing_matrix.sum(axis=1).eq(0).sum(),
            'features_with_missing': self.missing_counts.gt(0).sum()
        }
        
        return summary
    
    def visualize_patterns(self, figsize=(12, 8)):
        """Create comprehensive missing data visualizations."""
        fig, axes = plt.subplots(2, 2, figsize=figsize)
        
        # Missing data heatmap
        sns.heatmap(self.missing_matrix.T, cbar=True, ax=axes[0,0], 
                   cmap='viridis', yticklabels=True, xticklabels=False)
        axes[0,0].set_title('Missing Data Pattern Heatmap')
        axes[0,0].set_ylabel('Features')
        
        # Missing percentage by feature
        self.missing_percentages.plot(kind='bar', ax=axes[0,1])
        axes[0,1].set_title('Missing Data Percentage by Feature')
        axes[0,1].set_ylabel('Missing Percentage (%)')
        axes[0,1].tick_params(axis='x', rotation=45)
        
        # Missing values per sample
        missing_per_sample = self.missing_matrix.sum(axis=1)
        missing_per_sample.hist(bins=20, ax=axes[1,0])
        axes[1,0].set_title('Distribution of Missing Values per Sample')
        axes[1,0].set_xlabel('Number of Missing Features')
        axes[1,0].set_ylabel('Frequency')
        
        # Co-occurrence matrix
        co_occurrence = self.missing_matrix.T.dot(self.missing_matrix)
        sns.heatmap(co_occurrence, annot=True, fmt='d', ax=axes[1,1], 
                   cmap='Blues')
        axes[1,1].set_title('Missing Data Co-occurrence Matrix')
        
        plt.tight_layout()
        return fig
    
    def pattern_frequency_analysis(self):
        """Analyze frequency of missing data patterns."""
        # Convert missing pattern to string for grouping
        pattern_strings = self.missing_matrix.apply(
            lambda row: ''.join(row.astype(int).astype(str)), axis=1
        )
        
        pattern_counts = pattern_strings.value_counts()
        pattern_analysis = pd.DataFrame({
            'pattern': pattern_counts.index,
            'frequency': pattern_counts.values,
            'percentage': (pattern_counts.values / len(self.data)) * 100
        })
        
        # Decode patterns for readability
        feature_names = self.data.columns.tolist()
        pattern_analysis['missing_features'] = pattern_analysis['pattern'].apply(
            lambda p: [feature_names[i] for i, char in enumerate(p) if char == '1']
        )
        
        return pattern_analysis.head(20)  # Top 20 patterns
    
    def correlation_analysis(self):
        """Analyze correlations between missing data indicators."""
        missing_corr = self.missing_matrix.corr()
        
        # Find highly correlated missing patterns
        high_corr_pairs = []
        for i in range(len(missing_corr.columns)):
            for j in range(i+1, len(missing_corr.columns)):
                corr_val = missing_corr.iloc[i, j]
                if abs(corr_val) > 0.5:  # Threshold for high correlation
                    high_corr_pairs.append({
                        'feature1': missing_corr.columns[i],
                        'feature2': missing_corr.columns[j],
                        'correlation': corr_val
                    })
        
        return pd.DataFrame(high_corr_pairs)
    
    def little_mcar_test(self, alpha=0.05):
        """Simplified implementation of Little's MCAR test concept."""
        # This is a simplified version - full implementation requires more complex statistics
        patterns = self.missing_matrix.apply(
            lambda row: ''.join(row.astype(int).astype(str)), axis=1
        )
        
        observed_patterns = patterns.value_counts()
        
        # Calculate expected frequencies under MCAR assumption
        total_samples = len(self.data)
        missing_probs = self.missing_percentages / 100
        
        # For simplicity, we'll compare observed vs expected for complete cases
        expected_complete = total_samples * np.prod(1 - missing_probs)
        observed_complete = (patterns == '0' * len(self.data.columns)).sum()
        
        return {
            'observed_complete_cases': observed_complete,
            'expected_complete_cases': expected_complete,
            'suggests_mcar': abs(observed_complete - expected_complete) / expected_complete < 0.1
        }

# Usage example with comprehensive analysis
np.random.seed(42)
n_samples, n_features = 1000, 6

# Create synthetic data with different missing patterns
data = pd.DataFrame(np.random.randn(n_samples, n_features), 
                   columns=[f'feature_{i}' for i in range(n_features)])

# Introduce different types of missing patterns
# MCAR pattern
mcar_mask = np.random.random((n_samples, 2)) < 0.1
data.iloc[:, 0:2] = data.iloc[:, 0:2].mask(mcar_mask)

# MAR pattern - missingness depends on other variables
mar_condition = data['feature_2'] > 0.5
data.loc[mar_condition, 'feature_3'] = np.nan

# Monotone pattern
monotone_samples = np.random.choice(n_samples, 200, replace=False)
data.loc[monotone_samples, 'feature_4':] = np.nan

# Perform comprehensive analysis
analyzer = MissingDataAnalyzer(data)

# Generate summary statistics
summary = analyzer.pattern_summary()
print("Missing Data Summary:")
for key, value in summary.items():
    print(f"{key}: {value}")

# Visualize patterns
fig = analyzer.visualize_patterns()
plt.show()

# Analyze pattern frequencies
pattern_freq = analyzer.pattern_frequency_analysis()
print("\nTop Missing Data Patterns:")
print(pattern_freq)

# Correlation analysis
corr_analysis = analyzer.correlation_analysis()
print("\nHighly Correlated Missing Patterns:")
print(corr_analysis)

# MCAR test
mcar_results = analyzer.little_mcar_test()
print("\nMCAR Test Results:")
print(mcar_results)
```

**Conclusion**: Effective missing data treatment in scikit-learn requires a thorough understanding of the available imputation methods, their underlying assumptions, and their appropriate application contexts. SimpleImputer provides robust univariate solutions for straightforward scenarios, while KNNImputer captures local data structure through neighborhood-based imputation. IterativeImputer offers sophisticated multivariate modeling capabilities for complex feature relationships, and custom imputation methods enable domain-specific solutions. Comprehensive missing data pattern analysis guides strategy selection and ensures transparent reporting of analytical limitations. The choice of imputation method should align with the missing data mechanism, computational constraints, and downstream modeling requirements.

**Next steps**: Consider implementing multiple imputation frameworks for uncertainty quantification, exploring deep learning-based imputation methods for complex high-dimensional data, integrating external data sources for enhanced imputation accuracy, and developing automated imputation strategy selection based on data characteristics and missing patterns.

---

