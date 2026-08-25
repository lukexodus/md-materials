## Overview

git show  # Examine the problematic commit
git bisect reset  # End bisect session
```

**Key Points**:

- Git show provides focused views of specific repository objects
- It's ideal for examining the details of individual changes
- Special references (HEAD~n, ^n) enable navigation through history
- It can extract file contents from any point in history
- Combined with bisect, it pinpoints when issues were introduced

### Advanced binary search with git bisect

Git bisect helps find which commit introduced a bug using binary search.

#### Basic workflow

```bash
