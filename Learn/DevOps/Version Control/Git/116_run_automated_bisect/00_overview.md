## Overview

git bisect start HEAD v1.0.0
git bisect run ./test-script.sh
```

**Key Points**:

- Bisect can dramatically reduce debugging time
- Automating the process makes it even more efficient
- It works best with reproducible bugs
- Keep test cases focused for accurate results
- Document findings to prevent future regressions

### Visualizing changes

#### Using git difftool

Configure a visual diff tool for easier comparison:

```bash
