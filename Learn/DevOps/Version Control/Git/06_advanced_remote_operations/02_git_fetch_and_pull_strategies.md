## Git Fetch and Pull Strategies


### Fetch vs. pull

Git provides two primary commands for retrieving changes from remote repositories: `fetch` and `pull`.

**Fetch**:

- Downloads commits, files, and refs from a remote repository
- Updates your remote-tracking branches (`origin/main`, etc.)
- Does not modify your working directory or local branches
- Is a "safe" operation as it never changes your local work

```bash
git fetch origin
```

**Pull**:

- Combines `fetch` + `merge` or `fetch` + `rebase` in one operation
- Updates your remote-tracking branches AND your current local branch
- Changes your working directory to reflect the new commits
- Is essentially a convenience shortcut for two operations

```bash
git pull origin main
```

**Key Points**:

- `fetch` is non-destructive and information-gathering
- `pull` is a higher-level command that makes changes to your working directory
- Using `fetch` first gives you a chance to examine changes before incorporating them
- `pull` is faster when you're confident about integrating remote changes

### Rebasing vs. merging pulled changes

When pulling changes, Git offers two strategies to integrate them into your local branch:

**Merging (default)**:

```bash
git pull origin main
# equivalent to:
git fetch origin
git merge origin/main
```

- Creates a merge commit if not a fast-forward
- Preserves complete branch history
- Shows when and how branches were integrated
- Maintains chronological order of development
- Can create "merge bubbles" in history

**Rebasing**:

```bash
git pull --rebase origin main
# equivalent to:
git fetch origin
git rebase origin/main
```

- Replays your commits on top of the remote branch
- Creates a linear history without merge commits
- Makes it appear as if you started working from the latest commit
- Can simplify history visualization and navigation
- Requires care with shared/published branches

**Example**: Starting point:

```
A---B---C (main)
     \
      D---E (your branch)
```

After merge:

```
A---B---C (main)
     \   \
      D---E---M (your branch)
```

After rebase:

```
A---B---C (main)
         \
          D'---E' (your branch)
```

### Pull strategies

Git's `pull` command accepts various options to modify its behavior:

#### `--rebase`

```bash
git pull --rebase origin main
```

- Rebases instead of merging
- Creates a linear history
- Avoids unnecessary merge commits
- Recommended for keeping feature branches up-to-date

You can configure this as default:

```bash
git config --global pull.rebase true
```

#### `--no-rebase`

```bash
git pull --no-rebase origin main
```

- Forces a merge even if rebase is configured as default
- Creates a merge commit when branches have diverged

#### `--ff-only` (Fast-Forward Only)

```bash
git pull --ff-only origin main
```

- Succeeds only if a fast-forward merge is possible
- Aborts if a merge commit would be required
- Ensures history remains linear
- Useful when you want to avoid accidental merge commits

#### `--no-ff` (No Fast-Forward)

```bash
git pull --no-ff origin main
```

- Always creates a merge commit, even for fast-forward merges
- Preserves the historical existence of a feature branch
- Useful for tracking where features were merged

#### `--squash`

```bash
git pull --squash origin feature
```

- Combines all changes from the remote branch into a single commit
- Does not record the merge relationship
- Useful for integrating a feature branch while keeping history clean

**Key Points**:

- Each strategy creates a different commit history
- Choose based on your project's branching strategy
- Consider team conventions for consistency

### Resolving remote conflicts

Conflicts can occur during `pull` operations when local and remote changes overlap:

1. When using merge (default pull):
    
    - Git enters the "merging" state
    - Conflict markers are added to affected files
    - Resolve manually as with any merge conflict
    - Complete with `git commit`
2. When using rebase (pull --rebase):
    
    - Git stops at the conflicting commit
    - Resolve the conflict
    - `git add` the resolved files
    - Continue with `git rebase --continue`
    - Repeat for any additional conflicts

**Example workflow for resolving rebase conflicts**:

```bash
git pull --rebase
# Conflict occurs
# Edit files to resolve
git add resolved-file.js
git rebase --continue
# Repeat if more conflicts
```

If you get stuck or want to abort:

```bash
git rebase --abort  # When using --rebase
git merge --abort   # When using default merge
```

### Advanced fetch operations

#### Fetching specific branches

```bash
git fetch origin develop
```

#### Fetching all remotes

```bash
git fetch --all
```

#### Pruning deleted remote branches

```bash
git fetch --prune
```

This removes remote-tracking branches that no longer exist on the remote.

#### Fetching tags

```bash
git fetch --tags
```

### Remote reference specifications

Remote references are how Git tracks the state of branches on remote repositories.

#### Viewing remote references

```bash
git ls-remote origin
```

#### Remote branch specifications

Format: `<remote>/<branch>` Example: `origin/main`

These can be used in most Git commands:

```bash
git log origin/main
git diff origin/main
git checkout -b new-branch origin/main
```

#### Refspecs

Refspecs define the mapping between remote and local references:

Format: `+<src>:<dst>`

Example in `.git/config`:

```
[remote "origin"]
    fetch = +refs/heads/*:refs/remotes/origin/*
```

Custom refspecs:

```bash
# Fetch just one branch
git fetch origin main:refs/remotes/origin/main

# Track a remote branch with a different local name
git fetch origin dev:refs/remotes/origin/development
```

### Pull strategies for specific workflows

#### Feature branch workflow

```bash
git checkout main
git pull                  # Update main
git checkout feature
git rebase main           # Rebase feature onto updated main
```

#### Centralized workflow

```bash
git pull --rebase         # Update with remote changes
# Work and commit
git push                  # Share your changes
```

#### Fork and pull request workflow

```bash
git remote add upstream https://github.com/original/repo.git
git fetch upstream
git checkout main
git rebase upstream/main
git push origin main      # Update your fork
```

### Best practices

- Use `fetch` before `pull` when unsure about remote changes
- Configure pull.rebase according to your team's workflow
- Commit or stash local changes before pulling
- Use `git pull --rebase` for feature branches to maintain clean history
- Consider `git pull --ff-only` for protected branches to avoid accidental merges
- Regularly prune deleted remote branches with `git fetch --prune`
- Set up branch tracking for commonly used remote branches

**Key Points**:

- Different workflows benefit from different pull strategies
- Consistency within a team is more important than the specific strategy chosen
- Document your team's preferred approach to prevent confusion
- Be careful with rebase on shared branches as it rewrites history

