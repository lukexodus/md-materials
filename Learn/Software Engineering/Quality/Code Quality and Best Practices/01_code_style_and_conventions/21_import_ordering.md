## Import Ordering


Consistent ordering reduces merge conflicts and allows developers to scan dependencies quickly. Adherence to PEP 8 standards is the baseline for high-quality Python code.

**Key Points**

- **Three Block Structure:** Imports must be grouped into three distinct sections, separated by a blank line.
    
    1. Standard Library Imports
        
    2. Third-Party Imports
        
    3. Local Application/Library Specific Imports
        
- **Alphabetical Sort:** Within each block, imports should be sorted alphabetically to ensure determinism.
    
- **Structure:** `import X` statements generally precede `from X import Y` statements within the same block, though strict alphabetical sorting often supersedes this depending on the linter configuration.
    

**Standard Grouping Example**

Python

```
# 1. Standard Library
import os
import sys
from datetime import datetime
from typing import List, Optional

# (Blank Line)

# 2. Third-Party
import boto3
import requests
from flask import Flask

# (Blank Line)

# 3. Local Application
from my_project.config import AppConfig
from my_project.utils import logger
```

Multi-line Imports

When importing many names from a single module, wrap them in parentheses to allow trailing commas and cleaner diffs. Avoid backslash line continuations.

Python

```
# Good
from my_project.very_long_module_name import (
    CONST_A,
    CONST_B,
    CONST_C,
    CONST_D,
)

# Bad
from my_project.very_long_module_name import CONST_A, CONST_B, \
    CONST_C, CONST_D
```

Tooling

Manual sorting is error-prone. Enforce ordering automatically using tools in the CI/CD pipeline or pre-commit hooks.

- **isort:** The industry standard for sorting imports.
    
- **ruff:** A faster, modern alternative that handles linting and import sorting.
    

Output (isort configuration example)

A .isort.cfg or pyproject.toml ensures the whole team uses the same sorting logic (e.g., forcing imports to wrap when exceeding line length).

Ini, TOML

```
[tool.isort]
profile = "black"
multi_line_output = 3
include_trailing_comma = true
force_grid_wrap = 0
use_parentheses = true
line_length = 88
```

---

