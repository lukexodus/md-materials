## Overview

git log -p b6dd6a7c351e~3..b6dd6a7c351e
```

### Advanced Bisect Techniques

#### Handling Non-Linear History

When working with branches and merges, bisect intelligently navigates the commit graph:

- It follows the first parent when encountering merge commits by default
- You can use `git bisect skip` to skip problematic commits
- For complex histories, consider using `--first-parent` or `--no-walk` options

```
