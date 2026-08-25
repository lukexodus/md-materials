## R with Python (reticulate)


The reticulate package provides seamless integration between R and Python, enabling data scientists to leverage the strengths of both ecosystems within a single workflow.

**Setting Up reticulate**

```r
library(reticulate)

# Install Python packages from R
py_install(c("pandas", "numpy", "scikit-learn", "matplotlib"))

# Configure Python environment
use_python("/usr/bin/python3")
use_virtualenv("r-reticulate")
use_condaenv("r-reticulate")

# Check Python configuration
py_config()
```

**Calling Python from R**

```r
# Import Python modules
pd <- import("pandas")
np <- import("numpy")
plt <- import("matplotlib.pyplot")

# Use Python functions directly
python_array <- np$array(c(1, 2, 3, 4, 5))
python_series <- pd$Series(c(1, 2, 3, 4, 5))

# Python data manipulation
df_python <- pd$DataFrame(list(
  x = c(1, 2, 3, 4, 5),
  y = c(2, 4, 6, 8, 10)
))

# Call Python methods with $ notation
summary_stats <- df_python$describe()
filtered_data <- df_python$query("x > 2")
```

**Data Exchange Between R and Python**

```r
# R to Python conversion
r_data <- data.frame(
  id = 1:100,
  value = rnorm(100),
  category = sample(c("A", "B", "C"), 100, replace = TRUE)
)

# Automatic conversion to pandas DataFrame
python_data <- r_to_py(r_data)

# Python to R conversion
r_result <- py_to_r(python_data)

# NumPy arrays and R matrices
r_matrix <- matrix(rnorm(100), nrow = 10)
numpy_array <- r_to_py(r_matrix)
back_to_r <- py_to_r(numpy_array)
```

**Executing Python Scripts**

```r
# Run Python scripts
py_run_file("analysis_script.py")

# Execute Python code strings
py_run_string("
import pandas as pd
import numpy as np

def process_data(data):
    return data.groupby('category').mean()
")

# Access Python objects created in scripts
processed_result <- py$process_data(python_data)
```

**Python Environment in R Markdown**

````r
# In R Markdown, use Python chunks
```{python}
import pandas as pd
import matplotlib.pyplot as plt

