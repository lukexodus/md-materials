## Overview

git log -G "function auth\w*\("
```

#### Combining with blame

For an effective workflow:

1. Use `git blame` to identify the last commit that changed a line
2. Use `git show <commit>` to see the full context of that change
3. Use `git log -S` to find related changes elsewhere

**Example**:

```bash
