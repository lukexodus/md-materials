## Dataset Loading Utilities


### Built-in Dataset Loading Functions

Scikit-learn provides several functions to load datasets with consistent interfaces and standardized formats:

```python
from sklearn import datasets
import pandas as pd
import numpy as np

# Load classic datasets
iris = datasets.load_iris()
digits = datasets.load_digits()
wine = datasets.load_wine()
breast_cancer = datasets.load_breast_cancer()
boston = datasets.load_boston()  # Deprecated in newer versions
california_housing = datasets.fetch_california_housing()

# Dataset structure examination
print("Keys:", iris.keys())
print("Feature names:", iris.feature_names)
print("Target names:", iris.target_names)
print("Data shape:", iris.data.shape)
print("Target shape:", iris.target.shape)
```

### Fetching Remote Datasets

```python
# Fetch datasets from remote repositories
olivetti_faces = datasets.fetch_olivetti_faces()
lfw_people = datasets.fetch_lfw_people(min_faces_per_person=70, resize=0.4)
covtype = datasets.fetch_covtype()
kddcup99 = datasets.fetch_kddcup99()

# Text datasets
newsgroups_train = datasets.fetch_20newsgroups(subset='train')
reuters = datasets.fetch_rcv1()
```

### Loading External Data Files

```python
# Using pandas for external files
df = pd.read_csv('data.csv')
df = pd.read_excel('data.xlsx')
df = pd.read_json('data.json')
df = pd.read_parquet('data.parquet')

# Converting to scikit-learn format
X = df.drop('target_column', axis=1).values
y = df['target_column'].values

# Using NumPy for structured data
data = np.loadtxt('data.txt', delimiter=',')
data = np.genfromtxt('data.csv', delimiter=',', skip_header=1)
```

### Custom Data Loading Functions

```python
def load_custom_dataset(filepath, target_column, test_size=0.2):
    """Custom function to load and split dataset"""
    from sklearn.model_selection import train_test_split
    
    df = pd.read_csv(filepath)
    X = df.drop(target_column, axis=1)
    y = df[target_column]
    
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=test_size, random_state=42
    )
    
    return {
        'data': X.values,
        'target': y.values,
        'feature_names': X.columns.tolist(),
        'target_names': y.unique() if y.dtype == 'object' else None,
        'X_train': X_train,
        'X_test': X_test,
        'y_train': y_train,
        'y_test': y_test
    }

# Usage
dataset = load_custom_dataset('my_data.csv', 'target')
```

