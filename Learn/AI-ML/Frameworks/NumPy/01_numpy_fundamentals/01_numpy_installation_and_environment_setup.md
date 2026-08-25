## NumPy Installation and Environment Setup


NumPy can be installed through multiple package managers and methods:

**Standard Installation Methods:**

- `pip install numpy` - Standard Python package installer
- `conda install numpy` - Anaconda/Miniconda package manager
- `pip install numpy==1.24.3` - Specific version installation

**Development Installation:** For contributing to NumPy development, install from source:

```bash
git clone https://github.com/numpy/numpy.git
cd numpy
pip install -e .
```

**Environment Verification:**

```python
import numpy as np
print(np.__version__)
print(np.show_config())  # Shows build configuration
```

**Dependencies:** NumPy requires Python 3.8+ and automatically installs necessary build dependencies. Core dependencies include BLAS and LAPACK libraries for linear algebra operations.

