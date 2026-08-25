## Overview

git bisect start HEAD $(git rev-parse HEAD~500)
```

#### Common Bisect Pitfalls

Be aware of these common issues:

- Inconsistent test environments producing unreliable results
- Marking commits incorrectly, confusing the search
- Bugs that depend on multiple commits or external factors
- Forgetting to `git bisect reset` when done (leaving the repository in a detached HEAD state)
- Not saving the bisect log for future reference

**Related Topics**

- Git hooks for automated testing
- Debugging techniques for complex applications
- Continuous integration integration with git bisect
- Git worktree for parallel debugging
- Creating reproducible development environments

---

## Advanced Debugging

### Using `git blame` effectively

Git blame is a powerful tool for determining who changed each line of a file, when they changed it, and in which commit. This helps identify the author of specific code sections and understand the context behind changes.

#### Basic usage

```bash
git blame [options] <file>
```

For example:

```bash
git blame src/app.js
```

The output shows each line with:

- Commit hash (partial)
- Author name
- Timestamp
- Line number
- Line content

#### Useful options

```bash
