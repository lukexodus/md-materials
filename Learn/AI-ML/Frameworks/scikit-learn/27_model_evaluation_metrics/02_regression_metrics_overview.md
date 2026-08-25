## Regression Metrics Overview


### Error-Based Metrics

**Mean Absolute Error (MAE)** measures average absolute differences between predictions and actual values. MAE is robust to outliers and provides intuitive interpretation in original units.

**Mean Squared Error (MSE)** squares prediction errors before averaging, penalizing larger errors more heavily than smaller ones. MSE amplifies the impact of outliers and is mathematically convenient for optimization.

**Root Mean Squared Error (RMSE)** takes the square root of MSE, returning error measurements to original scale while maintaining MSE's outlier sensitivity.

```python
from sklearn.metrics import mean_absolute_error, mean_squared_error, mean_squared_log_error
mae = mean_absolute_error(y_true, y_pred)
mse = mean_squared_error(y_true, y_pred)
rmse = mean_squared_error(y_true, y_pred, squared=False)
msle = mean_squared_log_error(y_true, y_pred)  # For positive targets only
```

### Percentage and Relative Metrics

**Mean Absolute Percentage Error (MAPE)** expresses errors as percentages of actual values, enabling comparison across different scales. However, MAPE becomes undefined when actual values are zero and can be biased toward low forecasts.

**Median Absolute Error** provides robust central tendency measures less influenced by extreme outliers compared to mean-based metrics.

```python
from sklearn.metrics import mean_absolute_percentage_error, median_absolute_error
mape = mean_absolute_percentage_error(y_true, y_pred)
medae = median_absolute_error(y_true, y_pred)
```

### Coefficient of Determination

**R² (R-squared)** represents the proportion of variance in the dependent variable explained by the model. R² ranges from negative infinity to 1, where 1 indicates perfect prediction and 0 means the model performs no better than predicting the mean.

```python
from sklearn.metrics import r2_score, explained_variance_score
r2 = r2_score(y_true, y_pred)
evs = explained_variance_score(y_true, y_pred)
```

**Explained variance score** measures the proportion of variance explained but differs from R² in how it handles bias in predictions.

### Robust Regression Metrics

**Max error** identifies the worst-case prediction error, useful for applications requiring guarantees on maximum deviation. **Mean Poisson deviance** and **mean gamma deviance** serve specialized regression scenarios with specific distributional assumptions.

```python
from sklearn.metrics import max_error, mean_poisson_deviance, mean_gamma_deviance
max_err = max_error(y_true, y_pred)
poisson_dev = mean_poisson_deviance(y_true, y_pred)
gamma_dev = mean_gamma_deviance(y_true, y_pred)
```

