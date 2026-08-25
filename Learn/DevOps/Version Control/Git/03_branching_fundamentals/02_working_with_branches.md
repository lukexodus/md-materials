## Working with Branches


### Branch Naming Conventions

Establishing consistent branch naming conventions in Git repositories enhances collaboration, aids automation, and improves workflow clarity. Well-structured branch names communicate purpose, ownership, and context at a glance.

**Key Points**

- Consistent branch naming improves team communication and workflow
- Names should be descriptive yet concise
- Hierarchical naming with delimiters helps organize branches by type or purpose
- Machine-readable formats enable automation with CI/CD systems
- Avoid special characters that may cause issues with Git commands

**Common Branch Naming Patterns**

1. **Feature branches**
    
    ```
    feature/user-authentication
    feature/shopping-cart
    feat/payment-gateway-integration
    ```
    
2. **Bugfix branches**
    
    ```
    bugfix/login-redirect-error
    bug/header-overlap-on-mobile
    fix/memory-leak-in-image-processor
    ```
    
3. **Hotfix branches**
    
    ```
    hotfix/security-vulnerability-in-auth
    hotfix/2.5.1/payment-calculation-error
    ```
    
4. **Release branches**
    
    ```
    release/2.5.0
    release/v3.0.0-beta
    release/2023-Q2
    ```
    
5. **Prefixes with ticket numbers**
    
    ```
    feature/PROJ-123-user-profile
    bugfix/JIRA-456-fix-date-format
    ```
    
6. **Personal or developer branches**
    
    ```
    dev/john/refactor-auth-module
    john/experimental-ui
    ```
    

**Example** Consider a team working on an e-commerce platform that follows this convention:

```
<type>/<issue-tracker-id>-<short-description>
```

Examples of their branches:

- `feature/SHOP-123-add-wishlists`
- `bugfix/SHOP-456-fix-checkout-validation`
- `hotfix/SHOP-789-critical-payment-error`

**Hierarchical Structures**

For complex projects, multi-level hierarchies can organize branches more effectively:

```
feature/api/authentication
feature/ui/responsive-navigation
release/2.0/phase-1
release/2.0/phase-2
```

**Conventions by Team Size**

|Team Size|Recommended Convention|Example|
|---|---|---|
|Solo developer|Simple descriptive names|`login-feature`, `fix-header`|
|Small team (2-5)|Type/description|`feature/user-settings`, `fix/navbar`|
|Medium team (5-15)|Type/owner/description|`feature/sarah/payment-api`, `bugfix/alex/date-format`|
|Large team (15+)|Type/ticket-id/description|`feature/PROJ-123/authentication`, `hotfix/SEC-789/oauth-vulnerability`|

**Avoid in Branch Names**

- Uppercase letters (except for issue IDs)
- Spaces (use hyphens or underscores instead)
- Special characters (`$`, `&`, `*`, etc.)
- Overly generic names (`fix`, `update`, `new-stuff`)
- Very long names (aim for under 50 characters)
- Branch names that could conflict with Git commands

### Tracking Branches

Tracking branches are local branches that have a direct relationship with a remote branch, enabling simplified push and pull operations. Understanding how these relationships work is essential for collaborative Git workflows.

**Key Points**

- Tracking branches maintain a reference to a remote branch
- They enable `git pull` and `git push` without specifying remote or branch
- Git automatically creates tracking branches when cloning or with certain checkout operations
- You can manually establish tracking relationships
- The relationship includes upstream branch information and divergence tracking

**How Tracking Works**

When you clone a repository, Git automatically creates a local `main` branch that tracks the remote `origin/main`. This establishes an upstream relationship where:

1. `git pull` knows to fetch from `origin` and merge `origin/main` into your local `main`
2. `git push` knows to push your local `main` to `origin/main`
3. `git status` can show how many commits your branch is ahead/behind its upstream branch

**Example**

```bash
$ git clone https://github.com/example/repo.git
$ cd repo
$ git status
On branch main
Your branch is up to date with 'origin/main'.

Nothing to commit, working tree clean
```

**Creating Tracking Branches**

```bash
# Method 1: When checking out a remote branch
git checkout feature-branch  # If remote branch exists, this creates a tracking branch

# Method 2: Explicit checkout with -t flag
git checkout -t origin/feature-branch

# Method 3: Creating new branch with upstream set
git checkout -b feature-branch origin/feature-branch

# Method 4: Set upstream for existing branch
git branch -u origin/feature-branch
# or
git branch --set-upstream-to=origin/feature-branch
```

**Setting Default Behavior** Configure Git to automatically set up tracking when creating branches:

```bash
git config --global push.default current
git config --global branch.autoSetupMerge always
```

**Viewing Tracking Information**

```bash
# List all branches with tracking info
git branch -vv

# Detailed view of remote branches
git remote show origin

# Get upstream branch for current branch
git rev-parse --abbrev-ref @{upstream}
```

**Example Output**

```bash
$ git branch -vv
* feature/user-auth   a1b2c3d [origin/feature/user-auth: ahead 2, behind 1] Add password reset
  main                e4f5g6h [origin/main] Latest stable release
  feature/search      i7j8k9l Update search algorithm
```

In this output:

- `feature/user-auth` is tracking `origin/feature/user-auth` and is 2 commits ahead and 1 behind
- `main` is tracking `origin/main` and is up to date
- `feature/search` is not tracking any remote branch

### Detached HEAD State

Detached HEAD is a Git state where you're not on a branch but instead directly viewing a specific commit. Understanding this state helps avoid losing work and provides powerful ways to explore repository history.

**Key Points**

- HEAD normally points to a branch reference, which points to a commit
- In detached HEAD state, HEAD points directly to a commit instead of a branch
- Common ways to enter detached HEAD: checking out a commit hash, tag, or remote branch
- Changes made in detached HEAD aren't associated with any branch
- New commits in detached HEAD are unreachable once you switch to another branch unless you create a new branch

**Entering Detached HEAD State**

```bash
# Checkout a specific commit
git checkout abc123

# Checkout a tag
git checkout v2.0.0

# Checkout a remote branch without tracking
git checkout origin/feature-branch
```

**Warning Message** When entering detached HEAD state, Git displays a warning:

```
You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by performing another checkout.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -b with the checkout command again. Example:

  git checkout -b <new-branch-name>
```

**Working in Detached HEAD**

While in detached HEAD, you can:

- View files at that commit point
- Make changes and create new commits
- Run tests against historical code versions
- Experiment without affecting branches

**Example Scenario**

```bash
# Checkout an old commit to examine it
git checkout abc123

# Made some changes and realized they're valuable
git add .
git commit -m "Fix old bug that still exists"

# Create a branch to preserve these changes
git branch bugfix/old-issue

# Switch back to main branch
git checkout main

# Now you can merge the fix if needed
git merge bugfix/old-issue
```

**Recovering from Accidental Detached HEAD Commits**

If you've made commits in detached HEAD and accidentally switched branches without creating a new branch first:

1. Find the lost commit with `git reflog`
    
    ```bash
    git reflog
    ```
    
2. Create a branch at that commit
    
    ```bash
    git checkout -b recovery-branch <commit-hash>
    ```
    

**Intentional Uses of Detached HEAD**

1. **Exploring history**: Examining old code without creating a branch
2. **CI/CD systems**: Testing specific commits without branch overhead
3. **Bisecting**: Finding bugs by checking out different commits
4. **Quick fixes**: Making a small change to a specific commit
5. **Reviewing pull requests**: Checking out PR commits for testing

### Stashing Changes (`git stash`)

Git stash temporarily shelves changes in your working directory, allowing you to switch contexts without committing incomplete work. It's an essential tool for managing workflows with interruptions or multiple concurrent tasks.

**Key Points**

- Stash saves modified tracked files and staged changes
- Creates a "stash entry" that can be reapplied later
- Ideal for switching branches without committing incomplete work
- Multiple stashes can be created and managed
- Stashed changes can be applied to any branch, not just the original one

**Basic Stash Operations**

```bash
# Store current changes in a stash
git stash

# Same as above, but with a custom message
git stash save "WIP: Feature X implementation"

# List all stashes
git stash list

# Show content of latest stash
git stash show

# Show detailed diff of latest stash
git stash show -p

# Apply most recent stash (keeping it in stash list)
git stash apply

# Apply a specific stash
git stash apply stash@{2}

# Apply most recent stash and remove it from stash list
git stash pop

# Remove the most recent stash
git stash drop

# Remove a specific stash
git stash drop stash@{1}

# Clear all stashes
git stash clear
```

**Example Workflow**

```bash
# Working on feature branch
git checkout feature/authentication

# Making changes...
# Urgent bug comes in, need to switch branches

# Stash current work
git stash save "Authentication form validation WIP"

# Switch to bugfix branch
git checkout bugfix/urgent-issue

# Fix the bug, commit, and push...
git add .
git commit -m "Fix urgent login issue"
git push

# Return to feature work
git checkout feature/authentication
git stash pop  # Resume where you left off
```

**Advanced Stashing**

```bash
# Stash untracked files too
git stash -u
# or
git stash --include-untracked

# Stash all files (including ignored ones)
git stash -a
# or
git stash --all

# Create a branch from a stash
git stash branch new-branch stash@{1}

# Stash only specific files
git stash push -m "Partial stash" path/to/file1.js path/to/file2.js

# Interactive stashing to select hunks
git stash -p
# or
git stash --patch
```

**Stash Naming and Organization**

While stashes are automatically numbered, using descriptive messages helps track multiple stashes:

```bash
# Create descriptive stashes
git stash save "feature/login: password validation"
git stash save "bug/header: fix overflow on mobile"

# List with more details
git stash list --date=local
```

**Example Output**

```bash
$ git stash list
stash@{0}: On feature/user-auth: WIP: Implementing two-factor authentication
stash@{1}: On feature/search: Search optimization incomplete
stash@{2}: On main: Quick fix for header layout
```

**Partial Stashing**

For fine-grained control over what to stash:

```bash
# Interactive stash selection
git stash -p

# This will prompt for each change:
# y - stash this hunk
# n - don't stash this hunk
# q - quit
# s - split the current hunk
# ? - help
```

### Branch Management (Renaming, Deleting)

Effective branch management keeps repositories clean and organized. Understanding how to properly create, rename, and delete branches prevents common pitfalls and maintains a healthy Git history.

**Key Points**

- Regular branch maintenance is essential for repository health
- Local and remote branches are managed separately
- Some operations require special handling for tracking relationships
- Deleting branches has different safety levels (--delete vs. --force)
- Branch cleanup should be part of your regular workflow

**Creating Branches**

```bash
# Create new branch from current HEAD
git branch new-feature

# Create and switch to new branch
git checkout -b new-feature

# Create branch from specific commit
git branch new-feature abc123

# Create branch from tag
git branch new-feature v2.0.0

# Create branch that tracks remote branch
git checkout -b local-name origin/remote-name
```

**Renaming Branches**

```bash
# Rename current branch
git branch -m new-name

# Rename specific branch
git branch -m old-name new-name

# Rename and update remote (if branch is already pushed)
git branch -m old-name new-name          # Step 1: Rename locally
git push origin :old-name                # Step 2: Delete old remote branch
git push --set-upstream origin new-name  # Step 3: Push new branch and set tracking
```

**Example**

```bash
# Rename feature branch to be more descriptive
git checkout feature-x
git branch -m feature/user-authentication

# Update remote branch
git push origin :feature-x
git push --set-upstream origin feature/user-authentication
```

**Warning**: Renaming branches that others are using can cause problems. Communicate branch renames to team members.

**Deleting Branches**

```bash
# Delete local branch (only if merged)
git branch -d branch-name

# Force delete local branch (even if not merged)
git branch -D branch-name

# Delete remote branch
git push origin --delete branch-name
# or
git push origin :branch-name
```

**Example**

```bash
# Delete merged feature branch
git checkout main
git branch -d feature/completed-work

# Force delete abandoned experimental branch
git branch -D experimental/failed-idea

# Delete remote branch
git push origin --delete feature/obsolete
```

**Safe Branch Deletion Workflow**

To avoid losing work when cleaning up branches:

1. Ensure changes are merged or preserved elsewhere
    
    ```bash
    git checkout main
    git pull
    git branch --merged  # List branches merged into current branch
    ```
    
2. Delete only merged branches
    
    ```bash
    git branch -d feature/complete  # Will fail if not fully merged
    ```
    
3. For unmerged branches, verify contents first
    
    ```bash
    git log master..feature/incomplete  # Review unique commits
    git diff master...feature/incomplete  # Review changes
    ```
    
4. Then force delete if necessary
    
    ```bash
    git branch -D feature/incomplete
    ```
    

**Bulk Branch Management**

```bash
# Delete all local branches that have been merged into main
git branch --merged main | grep -v "^\*\|main" | xargs git branch -d

# List branches by last commit date
git for-each-ref --sort=-committerdate refs/heads/ --format='%(committerdate:short) %(refname:short)'

# Find stale branches (no commits in last 3 months)
git for-each-ref --sort=committerdate refs/heads/ --format='%(committerdate:relative) %(refname:short)' | grep "months ago"
```

**Branch Information and Metadata**

```bash
# List branches with last commit
git branch -v

# Show branches with upstream tracking information
git branch -vv

# Show branches merged into current branch
git branch --merged

# Show branches not merged into current branch
git branch --no-merged

# Show branches containing a specific commit
git branch --contains abc123
```

**Example Output**

```bash
$ git branch -vv
  feature/api        7fc1234 [origin/feature/api: ahead 1] Add user endpoints
* main               a3b5678 [origin/main] Release version 2.0.0
  bugfix/auth        c9d0123 [origin/bugfix/auth: behind 2] Initial fix for auth
  feature/dashboard  e5f6789 Implement dashboard widgets
```

In this output:

- `feature/api` is tracking a remote branch and is ahead by 1 commit
- `main` is the current branch and is synchronized with its remote
- `bugfix/auth` is behind its remote by 2 commits
- `feature/dashboard` has no tracking relationship with any remote branch

**Branch Protection and Governance**

For team environments, consider these branch management practices:

1. **Protected branches**: Configure on GitHub/GitLab/Bitbucket to prevent force pushes and accidental deletion
2. **Branch permissions**: Restrict who can push to important branches
3. **Branch naming policies**: Enforce through hooks or CI/CD
4. **Regular cleanup**: Schedule periodic cleanup of stale branches
5. **Default branch configuration**: Set appropriate defaults for new repositories

```bash
# Set default branch name for new repositories
git config --global init.defaultBranch main
```

### Related Topics

- Git branching strategies (GitFlow, GitHub Flow, Trunk-based)
- Git workflows for feature development
- Branch merging strategies
- Rebasing vs merging branches
- Remote branch management best practices
- CI/CD integration with Git branches

---

