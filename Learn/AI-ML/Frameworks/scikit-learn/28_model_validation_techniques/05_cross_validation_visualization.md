## Cross-validation Visualization


Effective visualization of cross-validation results helps communicate model performance, stability, and comparison results. Good visualizations make complex validation results accessible and actionable for both technical and non-technical stakeholders.

Cross-validation visualizations include box plots showing score distributions across folds, radar charts for multi-metric comparisons, heatmaps for hyperparameter grids, and time series plots for temporal validation results.

**Key points:**

- Makes complex validation results accessible and interpretable
- Reveals performance distributions and stability patterns
- Facilitates model comparison and hyperparameter selection
- Communicates uncertainty and confidence in results

**Example:**

```python
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import cross_validate, StratifiedKFold
from sklearn.metrics import make_scorer, precision_score, recall_score, f1_score
import pandas as pd

def comprehensive_cv_visualization(models, X, y, cv=5):
    """
    Create comprehensive cross-validation visualizations.
    """
    # Define multiple scoring metrics
    scoring = {
        'accuracy': 'accuracy',
        'precision': make_scorer(precision_score, average='weighted'),
        'recall': make_scorer(recall_score, average='weighted'),
        'f1': make_scorer(f1_score, average='weighted')
    }
    
    # Collect CV results
    all_results = []
    
    for name, model in models.items():
        cv_results = cross_validate(
            model, X, y, cv=cv, scoring=scoring,
            return_train_score=True, n_jobs=-1
        )
        
        for metric in scoring.keys():
            for fold in range(cv):
                all_results.append({
                    'Model': name,
                    'Metric': metric.title(),
                    'Split': 'Test',
                    'Fold': fold,
                    'Score': cv_results[f'test_{metric}'][fold]
                })
                all_results.append({
                    'Model': name,
                    'Metric': metric.title(),
                    'Split': 'Train',
                    'Fold': fold,
                    'Score': cv_results[f'train_{metric}'][fold]
                })
    
    df_results = pd.DataFrame(all_results)
    
    # Create comprehensive visualization
    fig, axes = plt.subplots(2, 2, figsize=(16, 12))
    fig.suptitle('Comprehensive Cross-Validation Analysis', fontsize=16)
    
    # 1. Box plot of test scores by model and metric
    plt.subplot(2, 2, 1)
    test_data = df_results[df_results['Split'] == 'Test']
    sns.boxplot(data=test_data, x='Model', y='Score', hue='Metric')
    plt.title('Test Score Distribution by Model and Metric')
    plt.xticks(rotation=45)
    plt.legend(bbox_to_anchor=(1.05, 1), loc='upper left')
    
    # 2. Training vs Test scores comparison
    plt.subplot(2, 2, 2)
    pivot_data = df_results.pivot_table(
        index=['Model', 'Fold'], 
        columns=['Split', 'Metric'], 
        values='Score'
    ).reset_index()
    
    for model in models.keys():
        model_data = pivot_data[pivot_data['Model'] == model]
        train_acc = model_data[('Test', 'Accuracy')].mean()
        test_acc = model_data[('Train', 'Accuracy')].mean()
        plt.scatter(train_acc, test_acc, label=model, s=100)
    
    plt.plot([0, 1], [0, 1], 'k--', alpha=0.5)
    plt.xlabel('Training Accuracy')
    plt.ylabel('Test Accuracy')
    plt.title('Training vs Test Performance')
    plt.legend()
    
    # 3. Metric correlation heatmap
    plt.subplot(2, 2, 3)
    test_pivot = test_data.pivot_table(
        index=['Model', 'Fold'], 
        columns='Metric', 
        values='Score'
    )
    correlation_matrix = test_pivot.corr()
    sns.heatmap(correlation_matrix, annot=True, cmap='coolwarm', center=0)
    plt.title('Metric Correlation Matrix')
    
    # 4. Performance stability (coefficient of variation)
    plt.subplot(2, 2, 4)
    stability_data = []
    for model in models.keys():
        model_test_data = test_data[test_data['Model'] == model]
        for metric in scoring.keys():
            metric_data = model_test_data[model_test_data['Metric'] == metric.title()]
            cv_coefficient = metric_data['Score'].std() / metric_data['Score'].mean()
            stability_data.append({
                'Model': model,
                'Metric': metric.title(),
                'CV_Coefficient': cv_coefficient
            })
    
    stability_df = pd.DataFrame(stability_data)
    stability_pivot = stability_df.pivot(index='Model', columns='Metric', values='CV_Coefficient')
    
    sns.heatmap(stability_pivot, annot=True, cmap='YlOrRd', fmt='.3f')
    plt.title('Performance Stability (Lower is Better)')
    plt.ylabel('Model')
    
    plt.tight_layout()
    plt.show()
    
    # Summary statistics table
    print("\nCross-Validation Summary Statistics:")
    print("=" * 60)
    
    summary_stats = test_data.groupby(['Model', 'Metric'])['Score'].agg([
        'mean', 'std', 'min', 'max'
    ]).round(4)
    
    print(summary_stats)
    
    return df_results

# Create visualization
df_results = comprehensive_cv_visualization(models, X, y, cv=5)

# Additional specialized visualization for hyperparameter tuning
def plot_hyperparameter_heatmap(param_grid_results, param1, param2, score_name='mean_test_score'):
    """
    Create heatmap for 2D hyperparameter grid search results.
    """
    results_df = pd.DataFrame(param_grid_results.cv_results_)
    
    # Create pivot table for heatmap
    pivot_table = results_df.pivot_table(
        values=score_name,
        index=f'param_{param1}',
        columns=f'param_{param2}',
        aggfunc='mean'
    )
    
    plt.figure(figsize=(10, 8))
    sns.heatmap(pivot_table, annot=True, fmt='.3f', cmap='viridis')
    plt.title(f'Hyperparameter Grid Search Results\n{score_name}')
    plt.xlabel(param2)
    plt.ylabel(param1)
    plt.tight_layout()
    plt.show()

# Example of hyperparameter heatmap (would require GridSearchCV results)
from sklearn.model_selection import GridSearchCV

param_grid = {
    'max_depth': [3, 5, 7, 10],
    'n_estimators': [50, 100, 150, 200]
}

grid_search = GridSearchCV(
    RandomForestClassifier(random_state=42),
    param_grid, cv=5, scoring='accuracy', n_jobs=-1
)

grid_search.fit(X, y)
plot_hyperparameter_heatmap(grid_search, 'max_depth', 'n_estimators')
```

Advanced visualizations can include interactive plots using plotly, animated learning curves showing convergence over time, and 3D plots for exploring three-dimensional hyperparameter spaces.

**Conclusion:** Model validation techniques provide essential tools for understanding model behavior, diagnosing problems, and making informed decisions about model selection and improvement. Learning curves reveal the impact of training data size, validation curves guide hyperparameter selection, bias-variance decomposition explains fundamental model behavior, statistical testing ensures reliable comparisons, and comprehensive visualization makes results accessible and actionable. These techniques work together to provide a complete picture of model performance and reliability.

**Next steps:** Explore domain-specific validation techniques, implement custom validation metrics for specialized problems, investigate ensemble validation strategies, and study advanced statistical methods for model comparison and selection.

---

