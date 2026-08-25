## Model Evaluation and Metrics


Model evaluation assesses performance on unseen data using various metrics appropriate to the problem domain.

**Basic Evaluation** The evaluate method computes loss and metrics on test data:

```python
# Simple evaluation
test_loss, test_accuracy = model.evaluate(x_test, y_test, verbose=0)
print(f'Test accuracy: {test_accuracy:.4f}')

# Detailed evaluation with multiple metrics
results = model.evaluate(
    x_test, y_test,
    batch_size=32,
    verbose=1,
    return_dict=True  # Return results as dictionary
)
print(f"Test results: {results}")
```

**Prediction Generation** Generate predictions for analysis and inference:

```python
# Generate predictions
predictions = model.predict(x_test)

# Batch prediction with progress tracking
predictions = model.predict(
    x_test,
    batch_size=32,
    verbose=1,
    steps=None,
    max_queue_size=10
)

# Convert predictions to class labels (for classification)
predicted_classes = tf.argmax(predictions, axis=1)
```

**Custom Evaluation Metrics** Implement domain-specific evaluation metrics:

```python
from sklearn.metrics import classification_report, confusion_matrix

# Generate predictions for custom metrics
y_pred = model.predict(x_test)
y_pred_classes = tf.argmax(y_pred, axis=1)

# Classification metrics
print("Classification Report:")
print(classification_report(y_test, y_pred_classes))

# Confusion matrix
cm = confusion_matrix(y_test, y_pred_classes)
print("Confusion Matrix:")
print(cm)
```

**Evaluation on Different Datasets** Evaluate model performance across various data distributions:

```python
# Evaluate on multiple test sets
train_results = model.evaluate(x_train, y_train, verbose=0)
val_results = model.evaluate(x_val, y_val, verbose=0)
test_results = model.evaluate(x_test, y_test, verbose=0)

print(f"Train accuracy: {train_results[1]:.4f}")
print(f"Validation accuracy: {val_results[1]:.4f}")
print(f"Test accuracy: {test_results[1]:.4f}")
```

