## Multi-objective Optimization


Multi-objective optimization addresses scenarios where multiple conflicting objectives must be balanced, such as maximizing accuracy while minimizing model complexity or training time.

**Key points:**

- Optimizes multiple objectives simultaneously rather than single metrics
- Produces Pareto-optimal solutions representing different trade-offs
- Requires careful objective weighting or Pareto frontier analysis
- Common objectives include accuracy, precision, recall, F1-score, model size, inference time
- Can be implemented through custom scoring functions or specialized libraries

**Example:**

```python
from sklearn.metrics import make_scorer, accuracy_score, f1_score
from sklearn.model_selection import cross_val_score
import numpy as np

# Custom multi-objective scorer
def multi_objective_score(estimator, X, y):
    # Predict and calculate multiple metrics
    y_pred = estimator.predict(X)
    accuracy = accuracy_score(y, y_pred)
    f1 = f1_score(y, y_pred, average='weighted')
    
    # Model complexity (number of trees * average depth)
    if hasattr(estimator, 'estimators_'):
        complexity = len(estimator.estimators_) * np.mean([tree.get_depth() for tree in estimator.estimators_])
        complexity_penalty = complexity / 1000  # Normalize
    else:
        complexity_penalty = 0
    
    # Weighted combination of objectives
    combined_score = 0.6 * accuracy + 0.3 * f1 - 0.1 * complexity_penalty
    return combined_score

# Use custom scorer in optimization
param_grid = {
    'n_estimators': [50, 100, 200],
    'max_depth': [3, 5, 7]
}

grid_search_multi = GridSearchCV(
    estimator=RandomForestClassifier(random_state=42),
    param_grid=param_grid,
    scoring=make_scorer(multi_objective_score),
    cv=5,
    n_jobs=-1
)

grid_search_multi.fit(X_train, y_train)

# Analyze Pareto frontier
results = grid_search_multi.cv_results_
accuracies = []
complexities = []

for params in grid_search_multi.cv_results_['params']:
    rf_temp = RandomForestClassifier(**params, random_state=42)
    rf_temp.fit(X_train, y_train)
    
    accuracy = cross_val_score(rf_temp, X_train, y_train, cv=5, scoring='accuracy').mean()
    complexity = params['n_estimators'] * (params['max_depth'] if params['max_depth'] else 10)
    
    accuracies.append(accuracy)
    complexities.append(complexity)

# Visualize trade-offs
plt.figure(figsize=(10, 6))
plt.scatter(complexities, accuracies, alpha=0.7)
plt.xlabel('Model Complexity')
plt.ylabel('Accuracy')
plt.title('Accuracy vs Complexity Trade-off')
plt.show()
```

**Advanced Implementation with NSGA-II:**

```python
# Using DEAP library for true multi-objective optimization
from deap import base, creator, tools, algorithms
import random

# Define multi-objective problem
creator.create("FitnessMulti", base.Fitness, weights=(1.0, -1.0))  # Maximize accuracy, minimize complexity
creator.create("Individual", list, fitness=creator.FitnessMulti)

def evaluate_individual(individual):
    n_estimators, max_depth, min_samples_split = individual
    
    rf = RandomForestClassifier(
        n_estimators=int(n_estimators),
        max_depth=int(max_depth) if max_depth > 0 else None,
        min_samples_split=int(min_samples_split),
        random_state=42
    )
    
    # Calculate accuracy
    accuracy = cross_val_score(rf, X_train, y_train, cv=3, scoring='accuracy').mean()
    
    # Calculate complexity
    complexity = int(n_estimators) * (int(max_depth) if max_depth > 0 else 10)
    
    return accuracy, complexity

# Setup genetic algorithm
toolbox = base.Toolbox()
toolbox.register("n_estimators", random.randint, 50, 300)
toolbox.register("max_depth", random.randint, 3, 15)
toolbox.register("min_samples_split", random.randint, 2, 10)

toolbox.register("individual", tools.initCycle, creator.Individual,
                (toolbox.n_estimators, toolbox.max_depth, toolbox.min_samples_split), n=1)
toolbox.register("population", tools.initRepeat, list, toolbox.individual)
toolbox.register("mate", tools.cxTwoPoint)
toolbox.register("mutate", tools.mutUniformInt, low=[50, 3, 2], up=[300, 15, 10], indpb=0.2)
toolbox.register("select", tools.selNSGA2)
toolbox.register("evaluate", evaluate_individual)

# Run multi-objective optimization
population = toolbox.population(n=50)
algorithms.eaNSGA2(population, toolbox, mu=50, lambda_=100, 
                   cxpb=0.7, mutpb=0.3, ngen=20, verbose=True)
```

**Output:** Multi-objective optimization produces a set of Pareto-optimal solutions, each representing a different trade-off between objectives. Decision-makers can then select the solution that best matches their priorities.

**Conclusion:** Hyperparameter optimization in scikit-learn offers multiple strategies ranging from exhaustive grid search for guaranteed optimal results to efficient randomized and Bayesian approaches for large parameter spaces. Successive halving provides intelligent resource allocation, while multi-objective optimization handles complex trade-offs between competing goals. The choice of method depends on computational constraints, parameter space size, evaluation cost, and whether single or multiple objectives need optimization.

**Next steps:** Consider implementing ensemble methods that combine multiple optimized models, exploring automated machine learning (AutoML) frameworks that integrate hyperparameter optimization with feature engineering and model selection, and investigating neural architecture search for deep learning models.

**Related topics:** Cross-validation strategies, model selection techniques, automated feature engineering, ensemble methods, computational optimization algorithms, and distributed hyperparameter tuning frameworks.

---

