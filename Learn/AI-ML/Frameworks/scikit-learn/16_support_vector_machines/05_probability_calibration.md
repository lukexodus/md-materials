## Probability Calibration


SVMs don't naturally output class probabilities since they focus on margin optimization rather than probability estimation. Scikit-learn provides probability calibration methods to convert decision function outputs into well-calibrated probability estimates.

**Key Points:**

- `probability=True` enables probability prediction via Platt scaling or isotonic regression
- Platt scaling fits sigmoid function to decision function outputs
- Isotonic regression provides non-parametric monotonic mapping
- Calibration requires additional training time and cross-validation
- CalibratedClassifierCV wrapper offers more control over calibration process
- Probability estimates useful for ranking, uncertainty quantification, and threshold tuning

Internal cross-validation during calibration prevents overfitting to training data. The method parameter in CalibratedClassifierCV allows choosing between 'sigmoid' (Platt) and 'isotonic' calibration approaches.

**Example:**

```python
from sklearn.svm import SVC
from sklearn.calibration import CalibratedClassifierCV, calibration_curve
from sklearn.model_selection import cross_val_score
import matplotlib.pyplot as plt

# SVM with built-in probability calibration
svc_prob = SVC(kernel='rbf', probability=True, random_state=42)
svc_prob.fit(X_train, y_train)

# Manual calibration with more control
base_svc = SVC(kernel='rbf', random_state=42)
calibrated_svc = CalibratedClassifierCV(
    base_svc, method='isotonic', cv=3, ensemble=True
)
calibrated_svc.fit(X_train, y_train)

# Probability predictions
prob_builtin = svc_prob.predict_proba(X_test)
prob_calibrated = calibrated_svc.predict_proba(X_test)

# Calibration curve analysis
fraction_of_positives, mean_predicted_value = calibration_curve(
    y_test, prob_calibrated[:, 1], n_bins=10
)

# Cross-validation with probability scoring
prob_scores = cross_val_score(
    calibrated_svc, X_train, y_train, cv=5, scoring='neg_log_loss'
)

print(f"Average log-loss: {-prob_scores.mean():.3f}")
```

**Output:** Probability calibration transforms SVM decision functions into interpretable confidence scores, enabling threshold optimization, probabilistic predictions, and integration with other probabilistic models. Proper calibration assessment using reliability diagrams helps validate probability quality.

**Conclusion:** Scikit-learn's SVM implementations provide comprehensive tools for both linear and non-linear classification tasks. SVC offers maximum flexibility through kernel methods, LinearSVC provides scalable linear classification, Nu-SVC enables intuitive parameter control, multi-class strategies handle complex categorical problems, and probability calibration adds probabilistic interpretation capabilities.

**Next Steps:** Parameter optimization through grid search or randomized search, feature engineering and scaling for improved performance, ensemble methods combining multiple SVM variants, and specialized techniques like class weight balancing for imbalanced datasets represent key areas for advanced SVM usage in scikit-learn.

---

