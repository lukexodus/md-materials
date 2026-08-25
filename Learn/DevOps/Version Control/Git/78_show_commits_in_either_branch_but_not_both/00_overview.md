## Overview

git log main...feature-branch --left-right
```

**Example**: Creating a weekly progress report

```bash
git log --since="1 week ago" --until="today" \
    --author="$(git config user.email)" \
    --pretty=format:"%h %s" \
    --reverse
```

**Key Points**:

- Advanced logging helps create a mental map of project history
- Filtering narrows focus to relevant changes
- Custom formatting extracts exactly the information needed
- Combining filters creates powerful queries
- Log visualization aids in understanding complex branching

### Debugging with `git grep`

While not exclusive to debugging, `git grep` is a powerful tool for searching through your codebase to find patterns, usages, and potential issues.

#### Basic usage

```bash
git grep "searchTerm"
```

Unlike regular `grep`, this searches across all tracked files in your repository.

#### Useful options

```bash
