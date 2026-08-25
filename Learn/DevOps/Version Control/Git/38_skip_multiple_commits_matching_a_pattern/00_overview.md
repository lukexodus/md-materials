## Overview

git bisect skip $(git rev-list --grep="WIP" HEAD)
```

#### Working with Submodules

If your project uses submodules, bisect can be more complex:

1. Make sure the submodule is properly initialized and updated
2. Consider using a test script that updates submodules as needed
3. Be aware that bisect doesn't automatically track submodule changes

```bash
#!/bin/bash
