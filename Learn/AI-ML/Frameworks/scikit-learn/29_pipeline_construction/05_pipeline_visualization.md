## Pipeline Visualization


Pipeline visualization provides crucial insights into workflow structure, data transformations, and model behavior. Effective visualization helps debug pipelines, communicate methodologies, and optimize preprocessing steps.

**Key points:**

- Displays pipeline structure and data flow graphically
- Reveals transformation effects on data distributions
- Enables debugging of complex preprocessing workflows
- Facilitates communication with stakeholders and team members
- Supports performance analysis and bottleneck identification
- Integrates with various visualization libraries

**Example:**

```python
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.tree import plot_tree
from sklearn.inspection import plot_partial_dependence
import networkx as nx
from graphviz import Digraph

# Create comprehensive pipeline for visualization
visualization_pipeline = Pipeline([
    ('outlier_removal', OutlierRemover(method='iqr')),
    ('feature_union', FeatureUnion([
        ('numeric', Pipeline([
            ('scaler', StandardScaler()),
            ('pca', PCA(n_components=3))
        ])),
        ('statistical', StatisticalFeatures())
    ])),
    ('feature_selection', SelectKBest(f_classif, k=8)),
    ('final_scaler', MinMaxScaler()),
    ('classifier', RandomForestClassifier(n_estimators=50, max_depth=3, random_state=42))
])

# Generate sample data for visualization
X_vis, y_vis = make_classification(n_samples=300, n_features=10, n_informative=6, 
                                  n_redundant=2, random_state=42)
X_train_vis, X_test_vis, y_train_vis, y_test_vis = train_test_split(
    X_vis, y_vis, test_size=0.3, random_state=42)

# Fit pipeline
visualization_pipeline.fit(X_train_vis, y_train_vis)

# Function to create pipeline structure visualization
def visualize_pipeline_structure(pipeline, figsize=(12, 8)):
    """Create a visual representation of pipeline structure"""
    fig, ax = plt.subplots(figsize=figsize)
    
    # Extract pipeline steps
    steps = pipeline.steps if hasattr(pipeline, 'steps') else [('Pipeline', pipeline)]
    
    # Create positions for each step
    n_steps = len(steps)
    positions = [(i, 0) for i in range(n_steps)]
    
    # Draw boxes for each step
    for i, (name, transformer) in enumerate(steps):
        # Determine box color based on transformer type
        if 'scaler' in name.lower() or 'standard' in str(type(transformer)).lower():
            color = 'lightblue'
        elif 'selector' in name.lower() or 'select' in name.lower():
            color = 'lightgreen'
        elif 'classifier' in name.lower() or 'regressor' in name.lower():
            color = 'lightcoral'
        elif 'union' in name.lower():
            color = 'lightyellow'
        else:
            color = 'lightgray'
            
        # Draw rectangle
        rect = plt.Rectangle((i-0.4, -0.3), 0.8, 0.6, 
                           facecolor=color, edgecolor='black', linewidth=2)
        ax.add_patch(rect)
        
        # Add text
        ax.text(i, 0, name, ha='center', va='center', fontweight='bold', fontsize=10)
        ax.text(i, -0.15, str(type(transformer).__name__), ha='center', va='center', fontsize=8)
        
        # Draw arrows between steps
        if i < n_steps - 1:
            ax.arrow(i+0.4, 0, 0.2, 0, head_width=0.05, head_length=0.05, 
                    fc='black', ec='black')
    
    ax.set_xlim(-0.5, n_steps-0.5)
    ax.set_ylim(-0.5, 0.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Pipeline Structure', fontsize=16, fontweight='bold')
    
    plt.tight_layout()
    return fig

# Visualize pipeline structure
structure_fig = visualize_pipeline_structure(visualization_pipeline)
plt.show()

# Function to visualize data transformations at each step
def visualize_data_transformations(pipeline, X_sample, n_samples=100):
    """Show how data changes through pipeline steps"""
    X_subset = X_sample[:n_samples].copy()
    transformations = [('Original', X_subset)]
    
    # Apply each transformation step
    X_current = X_subset.copy()
    for name, transformer in pipeline.steps[:-1]:  # Exclude final classifier
        if hasattr(transformer, 'transform'):
            X_current = transformer.transform(X_current)
            transformations.append((name, X_current))
    
    # Create subplots
    n_transformations = len(transformations)
    fig, axes = plt.subplots(2, (n_transformations + 1) // 2, figsize=(15, 8))
    axes = axes.flatten() if n_transformations > 2 else [axes] if n_transformations == 1 else axes
    
    for i, (step_name, data) in enumerate(transformations):
        ax = axes[i]
        
        # Handle different data shapes
        if data.shape[1] >= 2:
            ax.scatter(data[:, 0], data[:, 1], c=y_vis[:n_samples], 
                      cmap='viridis', alpha=0.6, s=30)
            ax.set_xlabel('Feature 1')
            ax.set_ylabel('Feature 2')
        else:
            ax.hist(data[:, 0], bins=20, alpha=0.7, color='skyblue')
            ax.set_xlabel('Feature Value')
            ax.set_ylabel('Frequency')
        
        ax.set_title(f'{step_name}\nShape: {data.shape}', fontweight='bold')
        ax.grid(True, alpha=0.3)
    
    # Hide unused subplots
    for i in range(len(transformations), len(axes)):
        axes[i].axis('off')
    
    plt.tight_layout()
    return fig

# Visualize transformations
transformation_fig = visualize_data_transformations(visualization_pipeline, X_train_vis)
plt.show()

# Advanced pipeline visualization with feature importance
def create_comprehensive_pipeline_report(pipeline, X_test, y_test, feature_names=None):
    """Create comprehensive visualization report"""
    fig = plt.figure(figsize=(20, 12))
    
    # 1. Pipeline structure (top left)
    ax1 = plt.subplot(2, 4, 1)
    steps_text = '\n'.join([f"{i+1}. {name}: {type(step).__name__}" 
                           for i, (name, step) in enumerate(pipeline.steps)])
    ax1.text(0.05, 0.95, steps_text, transform=ax1.transAxes, fontsize=10,
             verticalalignment='top', bbox=dict(boxstyle='round', facecolor='lightgray'))
    ax1.set_title('Pipeline Steps', fontweight='bold')
    ax1.axis('off')
    
    # 2. Performance metrics (top center-left)
    ax2 = plt.subplot(2, 4, 2)
    from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
    y_pred = pipeline.predict(X_test)
    
    metrics = {
        'Accuracy': accuracy_score(y_test, y_pred),
        'Precision': precision_score(y_test, y_pred, average='weighted'),
        'Recall': recall_score(y_test, y_pred, average='weighted'),
        'F1-Score': f1_score(y_test, y_pred, average='weighted')
    }
    
    bars = ax2.bar(metrics.keys(), metrics.values(), color=['skyblue', 'lightgreen', 'lightcoral', 'gold'])
    ax2.set_ylim(0, 1)
    ax2.set_title('Performance Metrics', fontweight='bold')
    ax2.tick_params(axis='x', rotation=45)
    
    # Add value labels on bars
    for bar, value in zip(bars, metrics.values()):
        ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.01,
                f'{value:.3f}', ha='center', va='bottom', fontweight='bold')
    
    # 3. Feature importance (top center-right)
    ax3 = plt.subplot(2, 4, 3)
    if hasattr(pipeline.named_steps['classifier'], 'feature_importances_'):
        importances = pipeline.named_steps['classifier'].feature_importances_
        indices = np.argsort(importances)[-10:]  # Top 10 features
        
        ax3.barh(range(len(indices)), importances[indices], color='lightsteelblue')
        ax3.set_yticks(range(len(indices)))
        ax3.set_yticklabels([f'Feature {i}' for i in indices])
        ax3.set_xlabel('Importance')
        ax3.set_title('Top 10 Feature Importances', fontweight='bold')
    
    # 4. Confusion matrix (top right)
    ax4 = plt.subplot(2, 4, 4)
    from sklearn.metrics import confusion_matrix
    cm = confusion_matrix(y_test, y_pred)
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', ax=ax4)
    ax4.set_title('Confusion Matrix', fontweight='bold')
    ax4.set_ylabel('True Label')
    ax4.set_xlabel('Predicted Label')
    
    # 5. Learning curve (bottom left)
    ax5 = plt.subplot(2, 4, 5)
    from sklearn.model_selection import learning_curve
    train_sizes, train_scores, val_scores = learning_curve(
        pipeline, X_train_vis, y_train_vis, cv=5, n_jobs=-1,
        train_sizes=np.linspace(0.1, 1.0, 10))
    
    train_mean = np.mean(train_scores, axis=1)
    train_std = np.std(train_scores, axis=1)
    val_mean = np.mean(val_scores, axis=1)
    val_std = np.std(val_scores, axis=1)
    
    ax5.plot(train_sizes, train_mean, 'o-', color='blue', label='Training Score')
    ax5.fill_between(train_sizes, train_mean - train_std, train_mean + train_std, alpha=0.2, color='blue')
    ax5.plot(train_sizes, val_mean, 'o-', color='red', label='Validation Score')
    ax5.fill_between(train_sizes, val_mean - val_std, val_mean + val_std, alpha=0.2, color='red')
    
    ax5.set_xlabel('Training Set Size')
    ax5.set_ylabel('Score')
    ax5.set_title('Learning Curve', fontweight='bold')
    ax5.legend()
    ax5.grid(True, alpha=0.3)
    
    # 6. Data distribution before/after preprocessing (bottom center-left)
    ax6 = plt.subplot(2, 4, 6)
    original_first_feature = X_train_vis[:, 0]
    
    # Get transformed data (before final classifier)
    X_transformed = X_train_vis.copy()
    for name, step in pipeline.steps[:-1]:
        X_transformed = step.transform(X_transformed)
    transformed_first_feature = X_transformed[:, 0]
    
    ax6.hist(original_first_feature, bins=30, alpha=0.5, label='Original', density=True)
    ax6.hist(transformed_first_feature, bins=30, alpha=0.5, label='Transformed', density=True)
    ax6.set_xlabel('Feature Value')
    ax6.set_ylabel('Density')
    ax6.set_title('Feature Distribution\n(First Feature)', fontweight='bold')
    ax6.legend()
    
    # 7. Cross-validation scores (bottom center-right)
    ax7 = plt.subplot(2, 4, 7)
    from sklearn.model_selection import cross_val_score
    cv_scores = cross_val_score(pipeline, X_train_vis, y_train_vis, cv=5)
    
    ax7.boxplot([cv_scores], labels=['CV Scores'])
    ax7.scatter([1] * len(cv_scores), cv_scores, color='red', alpha=0.7)
    ax7.set_ylabel('Score')
    ax7.set_title(f'Cross-Validation Scores\nMean: {cv_scores.mean():.3f} ± {cv_scores.std():.3f}', 
                 fontweight='bold')
    ax7.grid(True, alpha=0.3)
    
    # 8. Pipeline timing analysis (bottom right)
    ax8 = plt.subplot(2, 4, 8)
    import time
    
    step_times = {}
    X_temp = X_test.copy()
    
    for name, step in pipeline.steps:
        start_time = time.time()
        if hasattr(step, 'transform'):
            X_temp = step.transform(X_temp)
        elif hasattr(step, 'predict'):
            _ = step.predict(X_temp)
        step_times[name] = time.time() - start_time
    
    bars = ax8.bar(range(len(step_times)), list(step_times.values()), 
                   color='lightcyan', edgecolor='navy')
    ax8.set_xticks(range(len(step_times)))
    ax8.set_xticklabels(step_times.keys(), rotation=45, ha='right')
    ax8.set_ylabel('Time (seconds)')
    ax8.set_title('Step Execution Times', fontweight='bold')
    
    # Add value labels on bars
    for bar, value in zip(bars, step_times.values()):
        ax8.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.0001,
                f'{value:.4f}', ha='center', va='bottom', fontsize=8)
    
    plt.tight_layout()
    return fig

# Create comprehensive report
report_fig = create_comprehensive_pipeline_report(visualization_pipeline, X_test_vis, y_test_vis)
plt.show()
```

**Interactive Pipeline Visualization:**

```python
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import plotly.express as px

def create_interactive_pipeline_visualization(pipeline, X_train, X_test, y_train, y_test):
    """Create interactive pipeline visualization using Plotly"""
    
    # Create subplots
    fig = make_subplots(
        rows=2, cols=3,
        subplot_titles=('Pipeline Structure', 'Feature Importance', 'Performance Metrics',
                       'Data Distribution', 'Learning Curve', 'Confusion Matrix'),
        specs=[[{"type": "scatter"}, {"type": "bar"}, {"type": "bar"}],
               [{"type": "histogram"}, {"type": "scatter"}, {"type": "heatmap"}]]
    )
    
    # 1. Feature importance
    if hasattr(pipeline.named_steps['classifier'], 'feature_importances_'):
        importances = pipeline.named_steps['classifier'].feature_importances_
        feature_names = [f'Feature_{i}' for i in range(len(importances))]
        
        fig.add_trace(go.Bar(x=feature_names[-10:], y=importances[-10:], 
                           name='Feature Importance', marker_color='lightblue'),
                     row=1, col=2)
    
    # 2. Performance metrics
    y_pred = pipeline.predict(X_test)
    from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
    
    metrics = {
        'Accuracy': accuracy_score(y_test, y_pred),
        'Precision': precision_score(y_test, y_pred, average='weighted'),
        'Recall': recall_score(y_test, y_pred, average='weighted'),
        'F1-Score': f1_score(y_test, y_pred, average='weighted')
    }
    
    fig.add_trace(go.Bar(x=list(metrics.keys()), y=list(metrics.values()),
                        name='Metrics', marker_color=['red', 'blue', 'green', 'orange']),
                 row=1, col=3)
    
    # 3. Data distribution comparison
    original_feature = X_train[:, 0]
    X_transformed = X_train.copy()
    for name, step in pipeline.steps[:-1]:
        X_transformed = step.transform(X_transformed)
    transformed_feature = X_transformed[:, 0]
    
    fig.add_trace(go.Histogram(x=original_feature, name='Original', opacity=0.7,
                              marker_color='lightcoral'), row=2, col=1)
    fig.add_trace(go.Histogram(x=transformed_feature, name='Transformed', opacity=0.7,
                              marker_color='lightblue'), row=2, col=1)
    
    # 4. Learning curve
    from sklearn.model_selection import learning_curve
    train_sizes, train_scores, val_scores = learning_curve(
        pipeline, X_train, y_train, cv=3, n_jobs=-1,
        train_sizes=np.linspace(0.1, 1.0, 5))
    
    train_mean = np.mean(train_scores, axis=1)
    val_mean = np.mean(val_scores, axis=1)
    
    fig.add_trace(go.Scatter(x=train_sizes, y=train_mean, mode='lines+markers',
                           name='Training Score', line=dict(color='blue')), row=2, col=2)
    fig.add_trace(go.Scatter(x=train_sizes, y=val_mean, mode='lines+markers',
                           name='Validation Score', line=dict(color='red')), row=2, col=2)
    
    # 5. Confusion matrix
    from sklearn.metrics import confusion_matrix
    cm = confusion_matrix(y_test, y_pred)
    
    fig.add_trace(go.Heatmap(z=cm, colorscale='Blues', showscale=True), row=2, col=3)
    
    # Update layout
    fig.update_layout(height=800, showlegend=True, 
                     title_text="Interactive Pipeline Analysis Dashboard")
    
    return fig

# Create interactive visualization
interactive_fig = create_interactive_pipeline_visualization(
    visualization_pipeline, X_train_vis, X_test_vis, y_train_vis, y_test_vis)

# Note: In Jupyter notebook, use: interactive_fig.show()
```

**Pipeline Export and Documentation:**

```python
def export_pipeline_documentation(pipeline, X_sample, y_sample, filename='pipeline_report'):
   """Generate comprehensive pipeline documentation"""
   
   import json
   import pickle
   import matplotlib.pyplot as plt
   import seaborn as sns
   from sklearn.model_selection import cross_val_score
   from sklearn.inspection import permutation_importance
   from datetime import datetime
   import pandas as pd
   
   documentation = {
       'pipeline_structure': [],
       'hyperparameters': {},
       'feature_transformations': {},
       'performance_metrics': {},
       'data_flow': [],
       'metadata': {
           'creation_date': datetime.now().isoformat(),
           'sklearn_version': sklearn.__version__,
           'sample_size': len(X_sample),
           'target_type': 'classification' if len(np.unique(y_sample)) < 50 else 'regression'
       }
   }
   
   # Extract pipeline structure
   for i, (name, step) in enumerate(pipeline.steps):
       step_info = {
           'step_number': i + 1,
           'name': name,
           'transformer_type': type(step).__name__,
           'parameters': step.get_params() if hasattr(step, 'get_params') else {},
           'module': step.__class__.__module__,
           'is_fitted': hasattr(step, 'is_fitted_') or any(
               hasattr(step, attr) for attr in ['coef_', 'feature_importances_', 'components_']
           )
       }
       documentation['pipeline_structure'].append(step_info)
       documentation['hyperparameters'][name] = step.get_params() if hasattr(step, 'get_params') else {}
   
   # Analyze data transformations with error handling
   X_current = X_sample.copy()
   original_shape = X_current.shape
   
   def safe_missing_count(X):
       try:
           if hasattr(X, 'isnull'):  # pandas DataFrame
               return X.isnull().sum().sum()
           elif np.issubdtype(X.dtype, np.number):
               return np.isnan(X).sum()
           else:
               return 0
       except:
           return 0
   
   def safe_data_type(X):
       try:
           if hasattr(X, 'dtypes'):  # pandas DataFrame
               return str(X.dtypes.tolist())
           else:
               return str(X.dtype)
       except:
           return "unknown"
   
   documentation['data_flow'].append({
       'stage': 'original',
       'shape': original_shape,
       'data_type': safe_data_type(X_current),
       'missing_values': safe_missing_count(X_current),
       'memory_usage_mb': X_current.nbytes / (1024**2) if hasattr(X_current, 'nbytes') else 0
   })
   
   # Track transformations through pipeline
   feature_names = []
   if hasattr(X_sample, 'columns'):
       feature_names = X_sample.columns.tolist()
   
   for name, step in pipeline.steps[:-1]:  # Exclude final estimator
       if hasattr(step, 'transform'):
           try:
               X_previous = X_current.copy()
               X_current = step.transform(X_current)
               
               # Calculate transformation statistics
               transformation_stats = {
                   'stage': name,
                   'shape': X_current.shape,
                   'data_type': safe_data_type(X_current),
                   'missing_values': safe_missing_count(X_current),
                   'memory_usage_mb': X_current.nbytes / (1024**2) if hasattr(X_current, 'nbytes') else 0,
                   'shape_change': {
                       'rows_before': X_previous.shape[0],
                       'rows_after': X_current.shape[0],
                       'cols_before': X_previous.shape[1] if len(X_previous.shape) > 1 else 1,
                       'cols_after': X_current.shape[1] if len(X_current.shape) > 1 else 1
                   }
               }
               
               # Feature importance for certain transformers
               if hasattr(step, 'get_support'):  # Feature selectors
                   try:
                       selected_features = step.get_support()
                       transformation_stats['selected_features_count'] = np.sum(selected_features)
                       if feature_names and len(feature_names) == len(selected_features):
                           transformation_stats['selected_features'] = [
                               feature_names[i] for i, selected in enumerate(selected_features) if selected
                           ]
                   except:
                       pass
               
               if hasattr(step, 'feature_importances_'):
                   try:
                       importances = step.feature_importances_
                       transformation_stats['feature_importances'] = {
                           'mean': float(np.mean(importances)),
                           'std': float(np.std(importances)),
                           'top_5_indices': np.argsort(importances)[-5:].tolist()
                       }
                   except:
                       pass
               
               documentation['data_flow'].append(transformation_stats)
               
           except Exception as e:
               documentation['data_flow'].append({
                   'stage': name,
                   'error': f"Transformation failed: {str(e)}",
                   'shape': 'unknown',
                   'data_type': 'unknown',
                   'missing_values': 0
               })
   
   # Performance analysis with comprehensive metrics
   try:
       # Basic scoring
       if hasattr(pipeline, 'score'):
           score = pipeline.score(X_sample, y_sample)
           documentation['performance_metrics']['pipeline_score'] = float(score)
       
       # Cross-validation scores
       try:
           cv_scores = cross_val_score(pipeline, X_sample, y_sample, cv=5)
           documentation['performance_metrics']['cross_validation'] = {
               'mean_score': float(np.mean(cv_scores)),
               'std_score': float(np.std(cv_scores)),
               'individual_scores': cv_scores.tolist(),
               'confidence_interval_95': [
                   float(np.mean(cv_scores) - 1.96 * np.std(cv_scores) / np.sqrt(len(cv_scores))),
                   float(np.mean(cv_scores) + 1.96 * np.std(cv_scores) / np.sqrt(len(cv_scores)))
               ]
           }
       except Exception as e:
           documentation['performance_metrics']['cross_validation_error'] = str(e)
       
       # Feature importance analysis for final estimator
       final_estimator = pipeline.steps[-1][1]
       if hasattr(final_estimator, 'feature_importances_'):
           try:
               importances = final_estimator.feature_importances_
               documentation['performance_metrics']['feature_importance'] = {
                   'values': importances.tolist(),
                   'top_10_indices': np.argsort(importances)[-10:].tolist(),
                   'importance_distribution': {
                       'mean': float(np.mean(importances)),
                       'std': float(np.std(importances)),
                       'min': float(np.min(importances)),
                       'max': float(np.max(importances))
                   }
               }
           except Exception as e:
               documentation['performance_metrics']['feature_importance_error'] = str(e)
       
       # Permutation importance (comprehensive but slower)
       try:
           perm_importance = permutation_importance(
               pipeline, X_sample, y_sample, n_repeats=3, random_state=42, n_jobs=-1
           )
           documentation['performance_metrics']['permutation_importance'] = {
               'importances_mean': perm_importance.importances_mean.tolist(),
               'importances_std': perm_importance.importances_std.tolist(),
               'top_10_features': np.argsort(perm_importance.importances_mean)[-10:].tolist()
           }
       except Exception as e:
           documentation['performance_metrics']['permutation_importance_error'] = str(e)
           
   except Exception as e:
       documentation['performance_metrics']['error'] = str(e)
   
   # Memory and computational complexity analysis
   try:
       import psutil
       import time
       
       # Measure prediction time
       start_time = time.time()
       predictions = pipeline.predict(X_sample[:100])  # Sample for timing
       prediction_time = time.time() - start_time
       
       documentation['performance_metrics']['computational_performance'] = {
           'prediction_time_100_samples': prediction_time,
           'predictions_per_second': 100 / prediction_time if prediction_time > 0 else float('inf'),
           'memory_usage_mb': psutil.Process().memory_info().rss / (1024**2)
       }
   except Exception as e:
       documentation['performance_metrics']['computational_performance_error'] = str(e)
   
   # Generate comprehensive report files
   base_filename = filename.replace('.json', '').replace('.html', '').replace('.pkl', '')
   
   # 1. JSON Report
   json_filename = f"{base_filename}.json"
   try:
       with open(json_filename, 'w') as f:
           json.dump(documentation, f, indent=2, default=str)
       print(f"JSON documentation saved to: {json_filename}")
   except Exception as e:
       print(f"Error saving JSON: {e}")
   
   # 2. Pickle the pipeline
   pickle_filename = f"{base_filename}_pipeline.pkl"
   try:
       with open(pickle_filename, 'wb') as f:
           pickle.dump(pipeline, f)
       print(f"Pipeline pickled to: {pickle_filename}")
   except Exception as e:
       print(f"Error pickling pipeline: {e}")
   
   # 3. HTML Report
   html_filename = f"{base_filename}.html"
   try:
       html_content = generate_html_report(documentation, pipeline)
       with open(html_filename, 'w', encoding='utf-8') as f:
           f.write(html_content)
       print(f"HTML report saved to: {html_filename}")
   except Exception as e:
       print(f"Error generating HTML report: {e}")
   
   # 4. Generate visualizations
   try:
       generate_pipeline_visualizations(documentation, pipeline, X_sample, y_sample, base_filename)
       print(f"Visualizations saved with prefix: {base_filename}")
   except Exception as e:
       print(f"Error generating visualizations: {e}")
   
   return documentation

def generate_html_report(documentation, pipeline):
   """Generate comprehensive HTML report"""
   
   html_template = """
   <!DOCTYPE html>
   <html>
   <head>
       <title>Pipeline Documentation Report</title>
       <style>
           body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
           .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
           .header { text-align: center; color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 20px; margin-bottom: 30px; }
           .section { margin-bottom: 30px; }
           .section h2 { color: #2980b9; border-left: 4px solid #3498db; padding-left: 15px; }
           .section h3 { color: #34495e; margin-top: 25px; }
           .pipeline-step { background: #ecf0f1; padding: 15px; margin: 10px 0; border-radius: 5px; border-left: 4px solid #e74c3c; }
           .step-header { font-weight: bold; color: #e74c3c; margin-bottom: 10px; }
           .parameters { background: #f8f9fa; padding: 10px; border-radius: 3px; font-family: monospace; font-size: 12px; }
           .data-flow { background: #d5dbdb; padding: 10px; margin: 5px 0; border-radius: 3px; }
           .metrics { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 15px; }
           .metric-card { background: #fff; border: 1px solid #bdc3c7; padding: 15px; border-radius: 5px; }
           .metric-value { font-size: 24px; font-weight: bold; color: #27ae60; }
           .warning { color: #e67e22; background: #fef9e7; padding: 10px; border-radius: 3px; margin: 10px 0; }
           .error { color: #e74c3c; background: #fadbd8; padding: 10px; border-radius: 3px; margin: 10px 0; }
           table { width: 100%; border-collapse: collapse; margin: 15px 0; }
           th, td { border: 1px solid #bdc3c7; padding: 8px; text-align: left; }
           th { background-color: #34495e; color: white; }
           .code { background: #2c3e50; color: #ecf0f1; padding: 15px; border-radius: 5px; font-family: monospace; overflow-x: auto; }
       </style>
   </head>
   <body>
       <div class="container">
           <div class="header">
               <h1>🔧 Pipeline Documentation Report</h1>
               <p>Generated on: {creation_date}</p>
               <p>Scikit-learn Version: {sklearn_version}</p>
           </div>
   """.format(
       creation_date=documentation['metadata']['creation_date'],
       sklearn_version=documentation['metadata']['sklearn_version']
   )
   
   # Pipeline Structure Section
   html_template += """
           <div class="section">
               <h2>📋 Pipeline Structure</h2>
               <p>Total Steps: {total_steps}</p>
   """.format(total_steps=len(documentation['pipeline_structure']))
   
   for step in documentation['pipeline_structure']:
       params_html = "<br>".join([f"<strong>{k}:</strong> {v}" for k, v in step['parameters'].items()][:5])
       if len(step['parameters']) > 5:
           params_html += f"<br><em>... and {len(step['parameters']) - 5} more parameters</em>"
       
       html_template += f"""
               <div class="pipeline-step">
                   <div class="step-header">Step {step['step_number']}: {step['name']}</div>
                   <div><strong>Type:</strong> {step['transformer_type']}</div>
                   <div><strong>Module:</strong> {step['module']}</div>
                   <div><strong>Fitted:</strong> {'✅' if step['is_fitted'] else '❌'}</div>
                   <details>
                       <summary>Parameters ({len(step['parameters'])})</summary>
                       <div class="parameters">{params_html}</div>
                   </details>
               </div>
       """
   
   # Data Flow Section
   html_template += """
           </div>
           <div class="section">
               <h2>🔄 Data Flow Analysis</h2>
               <table>
                   <tr><th>Stage</th><th>Shape</th><th>Data Type</th><th>Missing Values</th><th>Memory (MB)</th></tr>
   """
   
   for flow in documentation['data_flow']:
       if 'error' not in flow:
           html_template += f"""
                   <tr>
                       <td>{flow['stage']}</td>
                       <td>{flow['shape']}</td>
                       <td>{flow['data_type']}</td>
                       <td>{flow['missing_values']}</td>
                       <td>{flow.get('memory_usage_mb', 0):.2f}</td>
                   </tr>
           """
       else:
           html_template += f"""
                   <tr class="error">
                       <td>{flow['stage']}</td>
                       <td colspan="4">{flow['error']}</td>
                   </tr>
           """
   
   html_template += "</table></div>"
   
   # Performance Metrics Section
   html_template += """
           <div class="section">
               <h2>📊 Performance Metrics</h2>
               <div class="metrics">
   """
   
   metrics = documentation['performance_metrics']
   
   if 'pipeline_score' in metrics:
       html_template += f"""
                   <div class="metric-card">
                       <h4>Pipeline Score</h4>
                       <div class="metric-value">{metrics['pipeline_score']:.4f}</div>
                   </div>
       """
   
   if 'cross_validation' in metrics:
       cv = metrics['cross_validation']
       html_template += f"""
                   <div class="metric-card">
                       <h4>Cross-Validation</h4>
                       <div class="metric-value">{cv['mean_score']:.4f} ± {cv['std_score']:.4f}</div>
                       <small>5-Fold CV</small>
                   </div>
       """
   
   if 'computational_performance' in metrics:
       comp = metrics['computational_performance']
       html_template += f"""
                   <div class="metric-card">
                       <h4>Performance</h4>
                       <div class="metric-value">{comp.get('predictions_per_second', 0):.1f}</div>
                       <small>Predictions/second</small>
                   </div>
       """
   
   html_template += "</div>"
   
   # Error reporting
   error_keys = [k for k in metrics.keys() if 'error' in k]
   if error_keys:
       html_template += "<h3>⚠️ Errors Encountered:</h3>"
       for error_key in error_keys:
           html_template += f'<div class="error"><strong>{error_key}:</strong> {metrics[error_key]}</div>'
   
   html_template += """
           </div>
           
           <div class="section">
               <h2>🔬 Pipeline Recreation Code</h2>
               <div class="code">
# To recreate this pipeline:
from sklearn.pipeline import Pipeline
from sklearn.base import clone

# Load the pickled pipeline
import pickle
with open('{pipeline_file}', 'rb') as f:
   pipeline = pickle.load(f)

# Or recreate manually:
# pipeline = Pipeline([
#     ('step_name', TransformerClass(**parameters)),
#     # ... add all steps
# ])
               </div>
           </div>
           
           <div class="section">
               <h2>📈 Recommendations</h2>
               <ul>
   """.format(pipeline_file=f"{documentation['metadata'].get('filename', 'pipeline')}_pipeline.pkl")
   
   # Generate recommendations based on analysis
   recommendations = generate_recommendations(documentation)
   for rec in recommendations:
       html_template += f"<li>{rec}</li>"
   
   html_template += """
               </ul>
           </div>
       </div>
   </body>
   </html>
   """
   
   return html_template

def generate_recommendations(documentation):
   """Generate recommendations based on pipeline analysis"""
   recommendations = []
   
   # Check data flow for issues
   data_flows = documentation['data_flow']
   
   # Check for significant shape changes
   for i, flow in enumerate(data_flows[1:], 1):
       prev_flow = data_flows[i-1]
       if 'shape' in flow and 'shape' in prev_flow:
           try:
               prev_cols = prev_flow['shape'][1] if len(prev_flow['shape']) > 1 else 1
               curr_cols = flow['shape'][1] if len(flow['shape']) > 1 else 1
               
               if curr_cols > prev_cols * 5:
                   recommendations.append(f"⚠️ Step '{flow['stage']}' significantly increases feature count ({prev_cols} → {curr_cols}). Consider feature selection.")
               elif curr_cols < prev_cols * 0.1:
                   recommendations.append(f"ℹ️ Step '{flow['stage']}' dramatically reduces features ({prev_cols} → {curr_cols}). Verify this is intended.")
           except:
               pass
   
   # Check missing values
   for flow in data_flows:
       if flow.get('missing_values', 0) > 0:
           recommendations.append(f"⚠️ Missing values detected in stage '{flow['stage']}' ({flow['missing_values']} missing). Consider imputation strategies.")
   
   # Performance recommendations
   metrics = documentation['performance_metrics']
   if 'cross_validation' in metrics:
       cv_std = metrics['cross_validation']['std_score']
       if cv_std > 0.1:
           recommendations.append(f"⚠️ High cross-validation variance ({cv_std:.3f}). Consider regularization or more stable algorithms.")
   
   if 'computational_performance' in metrics:
       pps = metrics['computational_performance'].get('predictions_per_second', 0)
       if pps < 100:
           recommendations.append("⚠️ Slow prediction performance. Consider model simplification or optimization.")
   
   # Memory recommendations
   total_memory = sum(flow.get('memory_usage_mb', 0) for flow in data_flows)
   if total_memory > 1000:  # > 1GB
       recommendations.append("⚠️ High memory usage detected. Consider out-of-core processing or dimensionality reduction.")
   
   if not recommendations:
       recommendations.append("✅ No major issues detected. Pipeline appears well-configured.")
   
   return recommendations

def generate_pipeline_visualizations(documentation, pipeline, X_sample, y_sample, base_filename):
   """Generate visualization plots for the pipeline"""
   
   import matplotlib.pyplot as plt
   import seaborn as sns
   
   plt.style.use('default')
   
   # 1. Data Flow Visualization
   fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=(15, 12))
   
   # Shape changes through pipeline
   stages = [flow['stage'] for flow in documentation['data_flow'] if 'shape' in flow]
   shapes = [flow['shape'][1] if len(flow['shape']) > 1 else 1 for flow in documentation['data_flow'] if 'shape' in flow]
   
   ax1.plot(stages, shapes, marker='o', linewidth=2, markersize=8)
   ax1.set_title('Feature Count Through Pipeline', fontsize=14, fontweight='bold')
   ax1.set_xlabel('Pipeline Stage')
   ax1.set_ylabel('Number of Features')
   ax1.tick_params(axis='x', rotation=45)
   ax1.grid(True, alpha=0.3)
   
   # Memory usage through pipeline
   memory_usage = [flow.get('memory_usage_mb', 0) for flow in documentation['data_flow']]
   ax2.bar(stages, memory_usage, color='skyblue', alpha=0.7)
   ax2.set_title('Memory Usage by Stage', fontsize=14, fontweight='bold')
   ax2.set_xlabel('Pipeline Stage')
   ax2.set_ylabel('Memory Usage (MB)')
   ax2.tick_params(axis='x', rotation=45)
   
   # Performance metrics (if available)
   if 'cross_validation' in documentation['performance_metrics']:
       cv_scores = documentation['performance_metrics']['cross_validation']['individual_scores']
       ax3.bar(range(1, len(cv_scores) + 1), cv_scores, color='lightgreen', alpha=0.7)
       ax3.axhline(y=np.mean(cv_scores), color='red', linestyle='--', label=f'Mean: {np.mean(cv_scores):.3f}')
       ax3.set_title('Cross-Validation Scores', fontsize=14, fontweight='bold')
       ax3.set_xlabel('Fold')
       ax3.set_ylabel('Score')
       ax3.legend()
       ax3.grid(True, alpha=0.3)
   else:
       ax3.text(0.5, 0.5, 'No CV scores available', ha='center', va='center', transform=ax3.transAxes)
       ax3.set_title('Cross-Validation Scores', fontsize=14, fontweight='bold')
   
   # Feature importance (if available)
   if 'feature_importance' in documentation['performance_metrics']:
       importances = documentation['performance_metrics']['feature_importance']['values']
       top_10_idx = documentation['performance_metrics']['feature_importance']['top_10_indices']
       
       # Show distribution of all importances
       ax4.hist(importances, bins=20, alpha=0.7, color='orange')
       ax4.set_title('Feature Importance Distribution', fontsize=14, fontweight='bold')
       ax4.set_xlabel('Importance Score')
       ax4.set_ylabel('Frequency')
       ax4.grid(True, alpha=0.3)
   else:
       ax4.text(0.5, 0.5, 'No feature importance available', ha='center', va='center', transform=ax4.transAxes)
       ax4.set_title('Feature Importance Distribution', fontsize=14, fontweight='bold')
   
   plt.tight_layout()
   plt.savefig(f'{base_filename}_overview.png', dpi=300, bbox_inches='tight')
   plt.close()
   
   # 2. Pipeline Structure Diagram
   fig, ax = plt.subplots(figsize=(12, 8))
   
   # Create a simple flow diagram
   steps = documentation['pipeline_structure']
   y_positions = range(len(steps))
   
   for i, step in enumerate(steps):
       # Draw step box
       rect = plt.Rectangle((0, i-0.4), 8, 0.8, 
                          facecolor='lightblue' if i < len(steps)-1 else 'lightcoral',
                          edgecolor='black', linewidth=1)
       ax.add_patch(rect)
       
       # Add step text
       ax.text(4, i, f"{step['step_number']}. {step['name']}\n({step['transformer_type']})", 
              ha='center', va='center', fontweight='bold', fontsize=10)
       
       # Add arrow to next step
       if i < len(steps) - 1:
           ax.arrow(4, i+0.4, 0, 0.2, head_width=0.2, head_length=0.1, fc='black', ec='black')
   
   ax.set_xlim(-1, 9)
   ax.set_ylim(-0.5, len(steps)-0.5)
   ax.set_title('Pipeline Structure Flow', fontsize=16, fontweight='bold', pad=20)
   ax.axis('off')
   
   plt.savefig(f'{base_filename}_structure.png', dpi=300, bbox_inches='tight')
   plt.close()
   
   # 3. Performance Summary
   if documentation['performance_metrics']:
       fig, ax = plt.subplots(figsize=(10, 6))
       
       # Collect available metrics
       metric_names = []
       metric_values = []
       
       metrics = documentation['performance_metrics']
       if 'pipeline_score' in metrics:
           metric_names.append('Pipeline Score')
           metric_values.append(metrics['pipeline_score'])
       
       if 'cross_validation' in metrics:
           metric_names.append('CV Mean')
           metric_values.append(metrics['cross_validation']['mean_score'])
       
       if len(metric_values) > 0:
           bars = ax.bar(metric_names, metric_values, color=['skyblue', 'lightgreen', 'orange'][:len(metric_values)])
           ax.set_title('Performance Metrics Summary', fontsize=14, fontweight='bold')
           ax.set_ylabel('Score')
           ax.grid(True, alpha=0.3, axis='y')
           
           # Add value labels on bars
           for bar, value in zip(bars, metric_values):
               height = bar.get_height()
               ax.text(bar.get_x() + bar.get_width()/2., height + 0.01,
                      f'{value:.3f}', ha='center', va='bottom', fontweight='bold')
           
           plt.xticks(rotation=45)
           plt.tight_layout()
           plt.savefig(f'{base_filename}_performance.png', dpi=300, bbox_inches='tight')
       
       plt.close()

# Usage example and additional utility functions
def compare_pipelines(pipeline1, pipeline2, X_sample, y_sample, names=None):
   """Compare two pipelines and generate comparative documentation"""
   
   if names is None:
       names = ['Pipeline 1', 'Pipeline 2']
   
   print("Generating documentation for both pipelines...")
   
   doc1 = export_pipeline_documentation(pipeline1, X_sample, y_sample, f'{names[0]}_comparison')
   doc2 = export_pipeline_documentation(pipeline2, X_sample, y_sample, f'{names[1]}_comparison')
   
   # Generate comparison report
   comparison = {
       'pipeline1': doc1,
       'pipeline2': doc2,
       'comparison_metrics': {}
   }
   
   # Compare key metrics
   metrics1 = doc1['performance_metrics']
   metrics2 = doc2['performance_metrics']
   
   if 'pipeline_score' in metrics1 and 'pipeline_score' in metrics2:
       score_diff = metrics2['pipeline_score'] - metrics1['pipeline_score']
       comparison['comparison_metrics']['score_difference'] = {
           'difference': score_diff,
           'better_pipeline': names[1] if score_diff > 0 else names[0],
           'improvement': abs(score_diff)
       }
   
   if 'cross_validation' in metrics1 and 'cross_validation' in metrics2:
       cv_diff = metrics2['cross_validation']['mean_score'] - metrics1['cross_validation']['mean_score']
       comparison['comparison_metrics']['cv_difference'] = {
           'difference': cv_diff,
           'better_pipeline': names[1] if cv_diff > 0 else names[0],
           'improvement': abs(cv_diff)
       }
   
   # Save comparison report
   with open('pipeline_comparison.json', 'w') as f:
       json.dump(comparison, f, indent=2, default=str)
   
   print("Pipeline comparison saved to: pipeline_comparison.json")
   return comparison

import os
import json
import yaml

def load_pipeline_documentation(doc_path: str) -> dict:
    """
    Load pipeline documentation from a given path.
    
    Supports:
      - JSON
      - YAML/YML
      - Markdown (.md)
      - Plain text
    
    Args:
        doc_path (str): Path to the documentation file.
    
    Returns:
        dict: Structured documentation with keys:
              - "format": file type (json, yaml, markdown, text)
              - "content": raw content (string or parsed dict for JSON/YAML)
              - "metadata": extra info (filename, size, etc.)
    """
    if not os.path.exists(doc_path):
        raise FileNotFoundError(f"Documentation file not found: {doc_path}")
    
    _, ext = os.path.splitext(doc_path)
    ext = ext.lower()
    
    # Read file content
    with open(doc_path, "r", encoding="utf-8") as f:
        raw_content = f.read()
    
    # Process based on extension
    if ext in [".json"]:
        try:
            content = json.loads(raw_content)
            fmt = "json"
        except json.JSONDecodeError as e:
            raise ValueError(f"Invalid JSON documentation: {e}")
    
    elif ext in [".yaml", ".yml"]:
        try:
            content = yaml.safe_load(raw_content)
            fmt = "yaml"
        except yaml.YAMLError as e:
            raise ValueError(f"Invalid YAML documentation: {e}")
    
    elif ext in [".md"]:
        content = raw_content
        fmt = "markdown"
    
    else:  # fallback to plain text
        content = raw_content
        fmt = "text"
    
    return {
        "format": fmt,
        "content": content,
        "metadata": {
            "filename": os.path.basename(doc_path),
            "size": os.path.getsize(doc_path),
            "path": os.path.abspath(doc_path)
        }
    }

# Function usage
# doc = load_pipeline_documentation("pipeline_docs.yaml")
# print(doc["format"])   # yaml
# print(doc["content"])  # parsed YAML dictionary
```

---

