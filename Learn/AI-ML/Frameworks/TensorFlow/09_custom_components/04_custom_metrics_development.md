## Custom Metrics Development


Metrics provide interpretable measures of model performance during training and evaluation. Custom metrics enable domain-specific performance assessment and specialized evaluation criteria.

**Classification Metrics**

Advanced classification metrics beyond standard accuracy:

```python
class F1Score(tf.keras.metrics.Metric):
    def __init__(self, name='f1_score', **kwargs):
        super(F1Score, self).__init__(name=name, **kwargs)
        self.true_positives = self.add_weight(name='tp', initializer='zeros')
        self.false_positives = self.add_weight(name='fp', initializer='zeros')
        self.false_negatives = self.add_weight(name='fn', initializer='zeros')
    
    def update_state(self, y_true, y_pred, sample_weight=None):
        y_pred = tf.round(tf.clip_by_value(y_pred, 0, 1))
        
        tp = tf.reduce_sum(tf.cast(y_true * y_pred, tf.float32))
        fp = tf.reduce_sum(tf.cast((1 - y_true) * y_pred, tf.float32))
        fn = tf.reduce_sum(tf.cast(y_true * (1 - y_pred), tf.float32))
        
        self.true_positives.assign_add(tp)
        self.false_positives.assign_add(fp)
        self.false_negatives.assign_add(fn)
    
    def result(self):
        precision = self.true_positives / (self.true_positives + self.false_positives + 1e-8)
        recall = self.true_positives / (self.true_positives + self.false_negatives + 1e-8)
        return 2 * (precision * recall) / (precision + recall + 1e-8)
    
    def reset_state(self):
        self.true_positives.assign(0)
        self.false_positives.assign(0)
        self.false_negatives.assign(0)

class IoU(tf.keras.metrics.Metric):
    def __init__(self, num_classes, name='iou', **kwargs):
        super(IoU, self).__init__(name=name, **kwargs)
        self.num_classes = num_classes
        self.confusion_matrix = self.add_weight(
            name='confusion_matrix',
            shape=(num_classes, num_classes),
            initializer='zeros'
        )
    
    def update_state(self, y_true, y_pred, sample_weight=None):
        y_true = tf.cast(y_true, tf.int32)
        y_pred = tf.cast(tf.argmax(y_pred, axis=-1), tf.int32)
        
        # Flatten tensors
        y_true = tf.reshape(y_true, [-1])
        y_pred = tf.reshape(y_pred, [-1])
        
        # Update confusion matrix
        cm = tf.math.confusion_matrix(y_true, y_pred, num_classes=self.num_classes)
        self.confusion_matrix.assign_add(tf.cast(cm, tf.float32))
    
    def result(self):
        # Calculate IoU for each class
        sum_over_row = tf.reduce_sum(self.confusion_matrix, axis=0)
        sum_over_col = tf.reduce_sum(self.confusion_matrix, axis=1)
        true_positives = tf.linalg.diag_part(self.confusion_matrix)
        
        denominator = sum_over_row + sum_over_col - true_positives
        iou = tf.math.divide_no_nan(true_positives, denominator)
        
        return tf.reduce_mean(iou)
```

**Regression and Time Series Metrics**

Specialized metrics for regression and sequential data:

```python
class MAPE(tf.keras.metrics.Metric):
    def __init__(self, name='mape', **kwargs):
        super(MAPE, self).__init__(name=name, **kwargs)
        self.total_ape = self.add_weight(name='total_ape', initializer='zeros')
        self.count = self.add_weight(name='count', initializer='zeros')
    
    def update_state(self, y_true, y_pred, sample_weight=None):
        y_true = tf.cast(y_true, self.dtype)
        y_pred = tf.cast(y_pred, self.dtype)
        
        ape = tf.abs((y_true - y_pred) / (y_true + 1e-8)) * 100
        
        if sample_weight is not None:
            ape *= tf.cast(sample_weight, self.dtype)
            self.count.assign_add(tf.reduce_sum(sample_weight))
        else:
            self.count.assign_add(tf.cast(tf.size(y_true), self.dtype))
        
        self.total_ape.assign_add(tf.reduce_sum(ape))
    
    def result(self):
        return tf.math.divide_no_nan(self.total_ape, self.count)

class DirectionalAccuracy(tf.keras.metrics.Metric):
    def __init__(self, name='directional_accuracy', **kwargs):
        super(DirectionalAccuracy, self).__init__(name=name, **kwargs)
        self.correct_directions = self.add_weight(name='correct', initializer='zeros')
        self.total_predictions = self.add_weight(name='total', initializer='zeros')
    
    def update_state(self, y_true, y_pred, sample_weight=None):
        # Calculate direction changes
        true_direction = tf.sign(y_true[1:] - y_true[:-1])
        pred_direction = tf.sign(y_pred[1:] - y_pred[:-1])
        
        # Count correct direction predictions
        correct = tf.cast(tf.equal(true_direction, pred_direction), tf.float32)
        
        self.correct_directions.assign_add(tf.reduce_sum(correct))
        self.total_predictions.assign_add(tf.cast(tf.size(correct), tf.float32))
    
    def result(self):
        return tf.math.divide_no_nan(self.correct_directions, self.total_predictions)
```

