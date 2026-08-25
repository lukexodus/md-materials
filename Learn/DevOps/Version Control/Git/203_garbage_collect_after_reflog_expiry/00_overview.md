## Overview

git gc --prune=now
```

#### Reducing Repository Size

For repositories that have grown too large:

1. **Remove large files**:
    
    ```bash
    # Find large objects
    git rev-list --objects --all | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | sort -k3nr | head -20
    
    # Use BFG Repo-Cleaner to remove large files
    java -jar bfg.jar --strip-blobs-bigger-than 10M repo.git
    ```
    
2. **Filter branch history**:
    
    ```bash
    # Remove a directory from all history
    git filter-branch --tree-filter 'rm -rf node_modules' HEAD
    
    # WARNING: This rewrites history! Don't use on shared repositories without team coordination
    ```
    
3. **Clean untracked files**:
    
    ```bash
    # Preview what would be removed
    git clean -n -d
    
    # Remove untracked files and directories
    git clean -fd
    ```
    

**Example** Complete repository optimization workflow:

```bash
