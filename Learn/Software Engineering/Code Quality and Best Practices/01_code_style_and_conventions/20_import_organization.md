## Import Organization


Proper organization of imports determines how modular and decoupled the codebase remains. It impacts initialization speed, prevents namespace pollution, and resolves circular dependencies.

**Key Points**

- **Absolute Imports:** Prefer absolute imports (full path from project root) over relative imports for clarity and refactoring ease.
    
- **Explicit Exports:** Use `__all__` in `__init__.py` to control the public API of a package.
    
- **Avoid Star Imports:** Never use `from module import *` in production code. It obscures the origin of names and causes conflicts.
    
- **Lazy Importing:** Import inside functions or methods only if strictly necessary to resolve circular dependencies or improve startup time for heavy modules.
    

Absolute vs. Relative

Absolute imports are unambiguous. Relative imports (. or ..) should be restricted to strictly internal package references where moving the whole package together is expected.

Python

```
# Good: Absolute
from my_project.utils.string_helpers import normalize

# Acceptable: Explicit Relative (within same package)
from .validators import validate_email

# Bad: Implicit Relative (deprecated in Python 3)
import validators 
```

Handling Circular Imports

Use typing.TYPE_CHECKING to import modules solely for type hints without triggering runtime circular dependency errors.

Python

```
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from my_project.models import User  # Only imported during static analysis

def get_user_name(user: "User") -> str: # String forward reference required
    return user.name
```

Module Aliasing

Alias imports only to avoid name collisions or shorten significantly verbose package names. Do not alias for brevity if it sacrifices readability.

Python

```
# Good: Resolving conflict
from json import dump as json_dump
from yaml import dump as yaml_dump

# Good: Standard convention
import numpy as np
import pandas as pd

# Bad: Obscure alias
import datetime as d
```

