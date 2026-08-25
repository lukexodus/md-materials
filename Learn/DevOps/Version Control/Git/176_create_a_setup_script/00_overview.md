## Overview

cat > ~/dotfiles/setup.sh <<EOL
#!/bin/bash
ln -sf \$(pwd)/.gitconfig ~/.gitconfig
ln -sf \$(pwd)/.gitignore_global ~/.gitignore_global
EOL

chmod +x ~/dotfiles/setup.sh
```

### Troubleshooting Configuration Issues

Common configuration problems and their solutions:

**Key Points**

- Check which configuration is being applied with `git config --show-origin <key>`
- List all configurations with `git config --list --show-origin`
- Identify and resolve conflicting settings across different configuration levels
- Reset a specific configuration with `git config --unset <key>`

### Related Topics for Further Exploration

- Git hooks for automating workflows
- Git attributes for customizing file handling
- Submodules and subtree configuration
- Git Credential Managers for secure authentication
- Git workflows and branching strategies

---

## Git Performance Optimization

### Understanding Git Performance Bottlenecks

Git is designed to be fast and efficient, but as repositories grow in size and complexity, performance issues can emerge. Understanding the underlying causes of these bottlenecks is the first step toward optimizing Git performance.

**Key Points**

- Git's performance is primarily affected by repository size, history complexity, and file characteristics
- Common operations like cloning, fetching, status checks, and merging can slow down in large repositories
- Performance issues affect both local development and CI/CD pipelines
- Common bottlenecks include disk I/O, large binary files, extensive history, and inefficient configurations

#### Identifying Bottlenecks

To optimize Git performance, you must first identify where the slowdowns occur:

1. **Repository size metrics**:
    
    - Number of objects (commits, trees, blobs)
    - Size of the packfiles in `.git/objects/pack`
    - History depth (number of commits)
    - Size and count of checked-in files
2. **Slow operations diagnosis**:
    
    - Use `git --version` to confirm you're using a recent Git version
    - Enable Git's trace mode with `GIT_TRACE=1 git <command>`
    - Time specific commands with `time git <command>`
    - Use Git's built-in profiling with `git <command> --profile`

**Example**

```bash
$ GIT_TRACE=1 git status
20:04:47.482150 git.c:439               trace: built-in: git status
20:04:47.487028 run-command.c:663       trace: run_command: unset GIT_PAGER_IN_USE; LESS=FRX LV=-c pager
20:04:47.703893 git.c:439               trace: built-in: git rev-parse --git-dir --absolute-git-dir --is-inside-git-dir...
...
```

#### Common Performance Issues

|Issue|Symptoms|Primary Causes|
|---|---|---|
|Slow clone/fetch|Long download times, timeouts|Large repository size, network limitations, many refs|
|Slow checkout|Long wait after branch switch|Many files, large files, filesystem limitations|
|Slow status/add|Terminal hangs when checking status|Many files, large files, complex .gitignore rules|
|Slow merges|Merge operations take minutes|Complex merge conflicts, large diffs, binary files|
|High memory usage|Git operations cause system swapping|Excessive deltas, complex history, large packfiles|

### Working with Large Repositories

As repositories grow beyond a few gigabytes, specialized techniques become necessary for efficient operation.

**Key Points**

- Large repos require different workflows and tools
- File organization and repository structure decisions matter
- Monorepos need special consideration
- Some Git operations should be avoided in large repos

#### Strategies for Large Repository Management

1. **Repository structure optimization**:
    
    - Consider multiple smaller repositories instead of a monorepo
    - Use Git submodules or subtrees for logical separation
    - Implement Git LFS (Large File Storage) for binary files
2. **Git configuration for large repos**:
    
    ```bash
    # Increase buffer sizes
    git config --global http.postBuffer 157286400
    git config --global core.packedGitLimit 512m
    git config --global core.packedGitWindowSize 512m
    git config --global pack.deltaCacheSize 2047m
    git config --global pack.packSizeLimit 2047m
    git config --global pack.windowMemory 2047m
    ```
    
3. **Workflow adaptations**:
    
    - Use sparse checkouts to work with subdirectories
    - Minimize history browsing operations
    - Schedule intensive operations during off-hours
    - Use `--depth` and `--filter` options for fetching

**Example** For a large monorepo project:

```bash
