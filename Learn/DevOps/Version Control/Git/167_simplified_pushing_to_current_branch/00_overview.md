## Overview

git config --global push.default current
```

#### Ignoring Files Globally

Create a global `.gitignore` file:

```bash
git config --global core.excludesfile ~/.gitignore_global
```

Then add common patterns to ignore across all repositories:

```bash
