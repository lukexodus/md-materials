## Overview

git bisect terms --term-old=missing --term-new=exists
```

#### Dealing with Large Commit Ranges

For very large commit ranges:

- Start with a rough manual search to narrow the range
- Consider using git log to identify potential areas of interest
- Use `git bisect skip` liberally for unrelated or known-good areas
- Optimize your test script for speed

**Example**

```
