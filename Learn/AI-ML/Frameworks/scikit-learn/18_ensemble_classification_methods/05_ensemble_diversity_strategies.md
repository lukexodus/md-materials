## Ensemble Diversity Strategies


Ensemble diversity is crucial for effective ensemble performance. Multiple strategies ensure base classifiers make different types of errors that can be corrected through combination.

**Key points:**

- Algorithm diversity: Use different learning algorithms with varying inductive biases
- Data diversity: Train on different subsets or representations of data
- Parameter diversity: Use different hyperparameters for the same algorithm
- Feature diversity: Train on different feature subsets

**Algorithm diversity strategies:**

```python
# Create maximally diverse classifier ensemble
from sklearn.neural_network import MLPClassifier
from sklearn.ensemble import ExtraTreesClassifier

diverse_ensemble = VotingClassifier([
    # Linear methods
    ('lr', LogisticRegression(max_iter=1000)),
    ('ridge', RidgeClassifier()),
    
    # Tree-based methods
    ('rf', RandomForestClassifier(n_estimators=100)),
    ('et', ExtraTreesClassifier(n_estimators=100)),
    ('gb', GradientBoostingClassifier()),
    
    # Instance-based
    ('knn', KNeighborsClassifier()),
    
    # Probabilistic
    ('nb', GaussianNB()),
    
    # Non-linear
    ('svc', SVC(probability=True)),
    ('mlp', MLPClassifier(hidden_layer_sizes=(100,), max_iter=500))
], voting='soft')
```

**Data diversity techniques:**

```python
from sklearn.utils import resample
from sklearn.model_selection import StratifiedShuffleSplit

# Bootstrap sampling with different strategies
def create_diverse_datasets(X, y, n_datasets=5):
    diverse_datasets = []
    
    # Different bootstrap strategies
    for i in range(n_datasets):
        if i == 0:
            # Standard bootstrap
            X_boot, y_boot = resample(X, y, random_state=i)
        elif i == 1:
            # Balanced bootstrap
            X_boot, y_boot = resample(X, y, stratify=y, random_state=i)
        elif i == 2:
            # Subsample (no replacement)
            sss = StratifiedShuffleSplit(n_splits=1, train_size=0.8, random_state=i)
            idx, _ = next(sss.split(X, y))
            X_boot, y_boot = X[idx], y[idx]
        else:
            # Add noise to features
            X_boot = X + np.random.normal(0, 0.1, X.shape)
            y_boot = y.copy()
            
        diverse_datasets.append((X_boot, y_boot))
    
    return diverse_datasets

# Train ensemble on diverse datasets
diverse_classifiers = []
datasets = create_diverse_datasets(X_train, y_train)

for i, (X_div, y_div) in enumerate(datasets):
    clf = RandomForestClassifier(n_estimators=50, random_state=i)
    clf.fit(X_div, y_div)
    diverse_classifiers.append(clf)
```

**Feature diversity methods:**

```python
from sklearn.feature_selection import SelectPercentile, mutual_info_classif

# Random feature subsets
def create_feature_diverse_ensemble(X, y, n_classifiers=5):
    n_features = X.shape[1]
    feature_ensemble = []
    
    for i in range(n_classifiers):
        # Random feature selection
        np.random.seed(i)
        n_selected = np.random.randint(n_features//2, int(n_features*0.8))
        selected_features = np.random.choice(n_features, n_selected, replace=False)
        
        # Train classifier on selected features
        clf = RandomForestClassifier(n_estimators=100, random_state=i)
        clf.fit(X[:, selected_features], y)
        
        feature_ensemble.append((clf, selected_features))
    
    return feature_ensemble

# Prediction with feature-diverse ensemble
def predict_feature_ensemble(ensemble, X):
    predictions = []
    for clf, features in ensemble:
        pred_proba = clf.predict_proba(X[:, features])
        predictions.append(pred_proba)
    
    # Average predictions
    return np.mean(predictions, axis=0)
```

**Diversity measurement:**

```python
def measure_ensemble_diversity(classifiers, X, y):
    """Calculate various diversity measures"""
    predictions = np.array([clf.predict(X) for clf in classifiers])
    n_classifiers = len(classifiers)
    
    # Disagreement measure
    disagreement = 0
    for i in range(n_classifiers):
        for j in range(i+1, n_classifiers):
            disagreement += np.mean(predictions[i] != predictions[j])
    disagreement /= (n_classifiers * (n_classifiers - 1) / 2)
    
    # Double fault measure
    double_fault = 0
    for i in range(n_classifiers):
        for j in range(i+1, n_classifiers):
            both_wrong = (predictions[i] != y) & (predictions[j] != y)
            double_fault += np.mean(both_wrong)
    double_fault /= (n_classifiers * (n_classifiers - 1) / 2)
    
    # Q-statistic (correlation between classifier errors)
    q_statistics = []
    for i in range(n_classifiers):
        for j in range(i+1, n_classifiers):
            n11 = np.sum((predictions[i] == y) & (predictions[j] == y))
            n10 = np.sum((predictions[i] == y) & (predictions[j] != y))
            n01 = np.sum((predictions[i] != y) & (predictions[j] == y))
            n00 = np.sum((predictions[i] != y) & (predictions[j] != y))
            
            if n11*n00 + n01*n10 != 0:
                q = (n11*n00 - n01*n10) / (n11*n00 + n01*n10)
                q_statistics.append(q)
    
    return {
        'disagreement': disagreement,
        'double_fault': double_fault,
        'mean_q_statistic': np.mean(q_statistics),
        'std_q_statistic': np.std(q_statistics)
    }

# **Example** usage
diversity_metrics = measure_ensemble_diversity(diverse_classifiers, X_test, y_test)
print("Ensemble Diversity Metrics:")
for metric, value in diversity_metrics.items():
    print(f"{metric}: {value:.4f}")
```

**Advanced ensemble diversity optimization:**

```python
from scipy.optimize import differential_evolution

class OptimizedEnsemble:
    def __init__(self, base_classifiers):
        self.base_classifiers = base_classifiers
        self.weights_ = None
        
    def fit(self, X, y):
        # Get base predictions
        base_predictions = np.array([clf.predict_proba(X) for clf in self.base_classifiers])
        
        # Optimize weights to maximize accuracy while maintaining diversity
        def objective(weights):
            weights = weights / np.sum(weights)  # Normalize
            ensemble_pred = np.average(base_predictions, axis=0, weights=weights)
            accuracy = np.mean(np.argmax(ensemble_pred, axis=1) == y)
            
            # Calculate diversity bonus
            individual_preds = np.array([np.argmax(pred, axis=1) for pred in base_predictions])
            diversity_bonus = self.calculate_diversity(individual_preds, y)
            
            return -(accuracy + 0.1 * diversity_bonus)  # Negative for minimization
        
        # Optimize weights
        bounds = [(0.01, 1.0)] * len(self.base_classifiers)
        result = differential_evolution(objective, bounds, seed=42)
        self.weights_ = result.x / np.sum(result.x)
        
        return self
    
    def calculate_diversity(self, predictions, y):
        n_classifiers = len(predictions)
        disagreement = 0
        for i in range(n_classifiers):
            for j in range(i+1, n_classifiers):
                disagreement += np.mean(predictions[i] != predictions[j])
        return disagreement / (n_classifiers * (n_classifiers - 1) / 2)
    
    def predict_proba(self, X):
        base_predictions = np.array([clf.predict_proba(X) for clf in self.base_classifiers])
        return np.average(base_predictions, axis=0, weights=self.weights_)
    
    def predict(self, X):
        return np.argmax(self.predict_proba(X), axis=1)
```

**Output** evaluation framework:

```python
def comprehensive_ensemble_evaluation(ensemble_methods, X_train, X_test, y_train, y_test):
    results = {}
    
    for name, ensemble in ensemble_methods.items():
        ensemble.fit(X_train, y_train)
        
        # Predictions and probabilities
        y_pred = ensemble.predict(X_test)
        y_proba = ensemble.predict_proba(X_test) if hasattr(ensemble, 'predict_proba') else None
        
        # Performance metrics
        from sklearn.metrics import accuracy_score, precision_recall_fscore_support, roc_auc_score
        
        accuracy = accuracy_score(y_test, y_pred)
        precision, recall, f1, _ = precision_recall_fscore_support(y_test, y_pred, average='weighted')
        
        if y_proba is not None and len(np.unique(y_test)) == 2:
            auc = roc_auc_score(y_test, y_proba[:, 1])
        elif y_proba is not None:
            auc = roc_auc_score(y_test, y_proba, multi_class='ovr')
        else:
            auc = None
            
        results[name] = {
            'accuracy': accuracy,
            'precision': precision,
            'recall': recall,
            'f1_score': f1,
            'auc': auc
        }
    
    return results

# **Example** usage
ensemble_methods = {
    'voting_soft': voting_soft,
    'bagging': bagging_advanced,
    'adaboost': ada_custom,
    'stacking': stacking,
    'optimized': OptimizedEnsemble(diverse_classifiers)
}

evaluation_results = comprehensive_ensemble_evaluation(
    ensemble_methods, X_train, X_test, y_train, y_test
)
```

**Conclusion:** Ensemble classification methods in scikit-learn provide powerful approaches to improve predictive performance through diversity and combination of multiple models. VotingClassifier offers simple but effective aggregation, BaggingClassifier reduces variance through bootstrap sampling, AdaBoostClassifier sequentially corrects errors through adaptive reweighting, StackingClassifier learns optimal combination strategies, and diversity strategies ensure complementary base classifiers for maximum ensemble benefits.

**Next steps:**

- **Hyperparameter optimization**: Use grid search or Bayesian optimization for ensemble parameters
- **Advanced ensemble methods**: Explore gradient boosting, random forests, and extreme gradient boosting
- **Dynamic ensembles**: Implement online learning and concept drift adaptation
- **Ensemble pruning**: Select optimal subset of base classifiers to reduce computational cost
- **Interpretability**: Develop methods to understand ensemble decision-making processes

Related topics include gradient boosting methods, deep ensemble learning, multi-objective ensemble optimization, and automated machine learning for ensemble construction.

---

