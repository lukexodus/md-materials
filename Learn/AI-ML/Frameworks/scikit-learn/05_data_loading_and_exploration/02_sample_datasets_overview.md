## Sample Datasets Overview


### Classification Datasets

#### Iris Dataset

```python
iris = datasets.load_iris()
print("Dataset description:", iris.DESCR[:500])
print("Features:", iris.feature_names)
print("Classes:", iris.target_names)
print("Samples per class:", np.bincount(iris.target))

# Convert to DataFrame for better exploration
iris_df = pd.DataFrame(iris.data, columns=iris.feature_names)
iris_df['species'] = iris.target
```

#### Wine Recognition Dataset

```python
wine = datasets.load_wine()
print("Number of features:", wine.data.shape[1])
print("Number of classes:", len(wine.target_names))
print("Class distribution:", np.bincount(wine.target))

wine_df = pd.DataFrame(wine.data, columns=wine.feature_names)
wine_df['wine_class'] = wine.target
```

#### Breast Cancer Wisconsin Dataset

```python
cancer = datasets.load_breast_cancer()
print("Feature categories:")
for i, name in enumerate(cancer.feature_names):
    print(f"{i}: {name}")
    
print("Target mapping:", dict(zip(range(len(cancer.target_names)), cancer.target_names)))
```

### Regression Datasets

#### California Housing Dataset

```python
housing = datasets.fetch_california_housing()
print("Target variable:", "Median house value in hundreds of thousands of dollars")
print("Geographic scope:", "California districts from 1990 census")
print("Sample size:", housing.data.shape[0])

housing_df = pd.DataFrame(housing.data, columns=housing.feature_names)
housing_df['median_house_value'] = housing.target
```

#### Diabetes Dataset

```python
diabetes = datasets.load_diabetes()
print("Features represent:", "physiological measurements")
print("Target represents:", "disease progression after one year")
print("Data preprocessing:", "Each feature normalized to mean zero and std one")
```

### Computer Vision Datasets

#### Digits Dataset

```python
digits = datasets.load_digits()
print("Image dimensions:", "8x8 grayscale")
print("Pixel values range:", f"{digits.data.min():.1f} to {digits.data.max():.1f}")
print("Number of classes:", len(digits.target_names))

# Visualize sample digits
import matplotlib.pyplot as plt
fig, axes = plt.subplots(2, 5, figsize=(10, 5))
for i, ax in enumerate(axes.ravel()):
    ax.imshow(digits.images[i], cmap='gray')
    ax.set_title(f'Digit: {digits.target[i]}')
    ax.axis('off')
```

#### Olivetti Faces Dataset

```python
faces = datasets.fetch_olivetti_faces()
print("Image dimensions:", "64x64 grayscale")
print("Number of people:", len(np.unique(faces.target)))
print("Images per person:", faces.data.shape[0] // len(np.unique(faces.target)))
```

### Text Datasets

#### 20 Newsgroups Dataset

```python
newsgroups = datasets.fetch_20newsgroups(subset='train')
print("Number of categories:", len(newsgroups.target_names))
print("Sample categories:", newsgroups.target_names[:5])
print("Total documents:", len(newsgroups.data))
print("Sample document length:", len(newsgroups.data[0]))
```

### Synthetic Dataset Generation

```python
from sklearn.datasets import make_classification, make_regression
from sklearn.datasets import make_blobs, make_circles, make_moons

# Classification datasets
X_class, y_class = make_classification(
    n_samples=1000,
    n_features=20,
    n_informative=10,
    n_redundant=5,
    n_classes=3,
    random_state=42
)

# Regression datasets
X_reg, y_reg = make_regression(
    n_samples=1000,
    n_features=10,
    noise=0.1,
    random_state=42
)

# Clustering datasets
X_blobs, y_blobs = make_blobs(
    n_samples=300,
    centers=4,
    cluster_std=0.60,
    random_state=42
)

X_circles, y_circles = make_circles(
    n_samples=1000,
    noise=0.03,
    factor=0.5,
    random_state=42
)

X_moons, y_moons = make_moons(
    n_samples=1000,
    noise=0.1,
    random_state=42
)
```

