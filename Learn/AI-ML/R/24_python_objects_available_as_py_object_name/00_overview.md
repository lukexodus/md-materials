## Overview

r_data <- py$data
```
````

**Machine Learning Integration**

```r
# Use scikit-learn from R
sklearn <- import("sklearn")
train_test_split <- import("sklearn.model_selection")$train_test_split
RandomForestRegressor <- import("sklearn.ensemble")$RandomForestRegressor

# Prepare data
X <- r_to_py(iris[, 1:4])
y <- r_to_py(iris$Sepal.Length)

# Split data
split_data <- train_test_split(X, y, test_size = 0.3, random_state = 42)
X_train <- split_data[[1]]
X_test <- split_data[[2]]
y_train <- split_data[[3]]
y_test <- split_data[[4]]

# Train model
rf_model <- RandomForestRegressor(n_estimators = 100L, random_state = 42L)
rf_model$fit(X_train, y_train)

# Make predictions
predictions <- rf_model$predict(X_test)
r_predictions <- py_to_r(predictions)
```

**Advanced Integration Patterns**

```r
# Source Python functions into R environment
source_python("custom_functions.py")

# Use Python context managers
with(py$open("large_file.txt", "r") %as% f, {
  content <- f$read()
})

# Handle Python exceptions
tryCatch({
  result <- py_eval("1/0")
}, error = function(e) {
  cat("Python error:", e$message)
})
```

