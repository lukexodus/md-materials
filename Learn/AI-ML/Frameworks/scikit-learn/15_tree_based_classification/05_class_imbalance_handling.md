## Class Imbalance Handling


Tree-based methods offer several strategies for handling class imbalance, a common challenge in real-world classification problems. These approaches range from simple class weighting to sophisticated sampling techniques.

**Key points:**

- Class weighting adjusts algorithm behavior based on class frequencies
- Sampling techniques modify the training dataset distribution
- Performance metrics must account for class imbalance
- Different tree algorithms respond differently to imbalance handling

### Class Weight Strategies

```python
from sklearn.utils.class_weight import compute_class_weight
from collections import Counter

# Analyze class distribution
class_distribution = Counter(y_train)
print("Class distribution:", class_distribution)

# Compute class weights
classes = np.unique(y_train)
class_weights = compute_class_weight('balanced', classes=classes, y=y_train)
class_weight_dict = dict(zip(classes, class_weights))
print("Computed class weights:", class_weight_dict)

# Apply class weights to different algorithms
models_balanced = {
    'DT_Balanced': DecisionTreeClassifier(
        class_weight='balanced',
        max_depth=5,
        random_state=42
    ),
    'RF_Balanced': RandomForestClassifier(
        class_weight='balanced',
        n_estimators=100,
        random_state=42
    ),
    'ET_Balanced': ExtraTreesClassifier(
        class_weight='balanced',
        n_estimators=100,
        random_state=42
    )
}
```

### Advanced Sampling Techniques

```python
from imblearn.over_sampling import SMOTE, ADASYN
from imblearn.under_sampling import RandomUnderSampler
from imblearn.combine import SMOTETomek
from sklearn.metrics import confusion_matrix, classification_report

# SMOTE oversampling
smote = SMOTE(random_state=42)
X_train_smote, y_train_smote = smote.fit_resample(X_train, y_train)

# ADASYN adaptive sampling
adasyn = ADASYN(random_state=42)
X_train_adasyn, y_train_adasyn = adasyn.fit_resample(X_train, y_train)

# Combined sampling with SMOTETomek
smote_tomek = SMOTETomek(random_state=42)
X_train_combined, y_train_combined = smote_tomek.fit_resample(X_train, y_train)

# Train models with different sampling strategies
sampling_strategies = {
    'Original': (X_train, y_train),
    'SMOTE': (X_train_smote, y_train_smote),
    'ADASYN': (X_train_adasyn, y_train_adasyn),
    'SMOTE-Tomek': (X_train_combined, y_train_combined)
}

results_imbalanced = {}
for strategy, (X_tr, y_tr) in sampling_strategies.items():
    rf_model = RandomForestClassifier(n_estimators=100, random_state=42)
    rf_model.fit(X_tr, y_tr)
    y_pred = rf_model.predict(X_test)
    results_imbalanced[strategy] = classification_report(y_test, y_pred, output_dict=True)
```

### Performance Evaluation for Imbalanced Data

```python
from sklearn.metrics import precision_recall_curve, roc_curve, auc
from sklearn.metrics import balanced_accuracy_score, f1_score

def evaluate_imbalanced_classifier(y_true, y_pred, y_prob=None):
    """Comprehensive evaluation for imbalanced classification."""
    metrics = {}
    
    # Basic metrics
    metrics['accuracy'] = accuracy_score(y_true, y_pred)
    metrics['balanced_accuracy'] = balanced_accuracy_score(y_true, y_pred)
    metrics['f1_macro'] = f1_score(y_true, y_pred, average='macro')
    metrics['f1_weighted'] = f1_score(y_true, y_pred, average='weighted')
    
    # Class-wise metrics
    report = classification_report(y_true, y_pred, output_dict=True)
    metrics['class_metrics'] = report
    
    # Confusion matrix
    cm = confusion_matrix(y_true, y_pred)
    metrics['confusion_matrix'] = cm
    
    return metrics

# Example evaluation
for strategy, (X_tr, y_tr) in sampling_strategies.items():
    rf_model = RandomForestClassifier(n_estimators=100, random_state=42)
    rf_model.fit(X_tr, y_tr)
    y_pred = rf_model.predict(X_test)
    y_prob = rf_model.predict_proba(X_test)
    
    results = evaluate_imbalanced_classifier(y_test, y_pred, y_prob)
    print(f"\n{strategy} Strategy Results:")
    print(f"Balanced Accuracy: {results['balanced_accuracy']:.4f}")
    print(f"F1 Macro: {results['f1_macro']:.4f}")
    print(f"F1 Weighted: {results['f1_weighted']:.4f}")
```

**Conclusion:** Tree-based classification methods in scikit-learn provide a comprehensive toolkit for tackling diverse classification challenges. Decision trees offer interpretability and serve as building blocks for more sophisticated ensemble methods. Random Forests and Extra Trees leverage the wisdom of crowds through different randomization strategies, while Gradient Boosting achieves high performance through sequential error correction. Proper handling of class imbalance through weighting, sampling, and appropriate evaluation metrics ensures robust performance across various real-world scenarios. The choice between methods depends on dataset characteristics, interpretability requirements, computational constraints, and performance objectives.

**Next steps:** Consider exploring XGBoost and LightGBM for advanced gradient boosting implementations, ensemble stacking techniques for combining different tree-based methods, and automated hyperparameter optimization using tools like Optuna or Hyperopt.

---

