## Matplotlib and Seaborn Visualization


**Matplotlib** provides low-level plotting functionality with fine-grained control over figure elements. The pyplot interface offers MATLAB-like plotting commands, while the object-oriented interface enables complex multi-panel figures. Matplotlib serves as the foundation for most Python plotting libraries.

**Figure and axes management** distinguishes between figure-level properties (size, DPI, layout) and axes-level properties (scales, labels, limits). Subplots enable multiple plots within single figures, while tight layout and constrained layout manage spacing automatically.

**Key Points:**

- Pyplot interface: convenient MATLAB-like commands
- Object-oriented interface: explicit control over figure elements
- Extensive customization: colors, markers, line styles, annotations
- Multiple backends: interactive display, file export, web embedding
- Integration with NumPy arrays and Pandas DataFrames

**Example:**

```python
import matplotlib.pyplot as plt
import numpy as np

# Basic plotting
x = np.linspace(0, 10, 100)
y1 = np.sin(x)
y2 = np.cos(x)

plt.figure(figsize=(10, 6))
plt.plot(x, y1, label='sin(x)', linewidth=2)
plt.plot(x, y2, label='cos(x)', linestyle='--')
plt.xlabel('x')
plt.ylabel('y')
plt.title('Trigonometric Functions')
plt.legend()
plt.grid(True, alpha=0.3)
plt.show()

# Object-oriented interface
fig, axes = plt.subplots(2, 2, figsize=(12, 8))
data = np.random.randn(1000)

axes[0, 0].hist(data, bins=30, alpha=0.7)
axes[0, 1].scatter(data[:-1], data[1:], alpha=0.5)
axes[1, 0].boxplot(data)
axes[1, 1].plot(np.cumsum(data))

plt.tight_layout()
plt.show()
```

**Seaborn** builds on Matplotlib to provide high-level statistical visualization with attractive default styling. Seaborn specializes in exploring relationships between variables through statistical plots, automatic legend generation, and integration with Pandas DataFrames.

**Statistical plots** include distribution plots (`distplot`, `histplot`), relationship plots (`scatterplot`, `regplot`), and categorical plots (`boxplot`, `violinplot`, `barplot`). These functions automatically handle statistical computations and provide informative visualizations with minimal code.

**Key Points:**

- Built-in statistical functionality and attractive defaults
- Direct integration with Pandas DataFrames
- Automatic handling of categorical variables and grouping
- Theme and palette management for consistent styling
- Specialized plots: heatmaps, pair plots, facet grids

**Example:**

```python
import seaborn as sns
import pandas as pd

# Set style and palette
sns.set_style("whitegrid")
sns.set_palette("husl")

# Sample data
tips = sns.load_dataset("tips")

# Statistical relationships
fig, axes = plt.subplots(2, 2, figsize=(12, 10))

sns.scatterplot(data=tips, x="total_bill", y="tip", hue="time", ax=axes[0, 0])
sns.boxplot(data=tips, x="day", y="total_bill", ax=axes[0, 1])
sns.histplot(data=tips, x="tip", hue="sex", kde=True, ax=axes[1, 0])
sns.heatmap(tips.corr(), annot=True, ax=axes[1, 1])

plt.tight_layout()
plt.show()

# Advanced plots
g = sns.FacetGrid(tips, col="time", row="sex", margin_titles=True)
g.map(sns.scatterplot, "total_bill", "tip", alpha=0.7)
g.add_legend()

# Pairplot for multiple variables
sns.pairplot(tips, hue="sex", diag_kind="kde")
plt.show()
```

