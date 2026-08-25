## Overview

git gc --prune=now
```

**When to run GC**:

- Before pushing to remote repositories
- After extensive history rewriting
- When the repository feels sluggish
- After deleting large files or branches

#### Configuring GC Behavior

Git's garbage collection can be tuned via configuration:

```bash
