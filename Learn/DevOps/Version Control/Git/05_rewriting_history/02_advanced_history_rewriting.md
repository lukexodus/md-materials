## Advanced History Rewriting


### Cherry-picking Commits (`git cherry-pick`)

Cherry-picking is a powerful Git feature that allows you to apply specific commits from one branch to another. It's useful for selectively transferring changes without merging entire branches.

**Key Points**

- Copies a commit from one branch and applies it to another
- Creates a new commit with the same changes but different metadata
- Preserves the original commit message (can be modified if needed)
- Particularly useful for backporting fixes to release branches
- Can be applied to single commits or ranges of commits
- May introduce conflicts that need manual resolution

**Basic Cherry-pick Usage**

```bash
# Apply a single commit to the current branch
git cherry-pick abc123

# Apply multiple specific commits
git cherry-pick abc123 def456 ghi789

# Apply a range of commits (from oldest to newest)
git cherry-pick abc123^..def456

# Cherry-pick without automatically committing (stage changes only)
git cherry-pick -n abc123
# or
git cherry-pick --no-commit abc123

# Cherry-pick with a custom commit message
git cherry-pick -e abc123
# or
git cherry-pick --edit abc123

# Skip the commit if it would create an empty commit
git cherry-pick --skip-empty abc123
```

**Example Workflow: Backporting a Bugfix**

Imagine you've fixed a bug in your development branch, but need to apply the same fix to a stable release branch:

```bash
# Start on development branch with the fix
git checkout development

# Identify the commit with the bugfix
git log --oneline
# fa12345 Fix critical authentication bug
# ...

# Switch to release branch
git checkout release/2.0

# Apply the bugfix commit
git cherry-pick fa12345

# Push the backported fix
git push origin release/2.0
```

**Handling Cherry-pick Conflicts**

When cherry-picking introduces conflicts:

```bash
# Cherry-pick that results in conflict
git cherry-pick abc123
# CONFLICT (content): Merge conflict in file.txt
# error: could not apply abc123... Commit message

# Resolve the conflicts manually in your editor

# After resolving, stage the files
git add file.txt

# Continue the cherry-pick operation
git cherry-pick --continue

# Or abort the cherry-pick if needed
git cherry-pick --abort
```

**Advanced Cherry-pick Options**

```bash
# Preserve original authorship information
git cherry-pick -x abc123

# Add a line saying "cherry picked from commit..." to the message
git cherry-pick -x abc123

# Allow empty commits (when changes were already applied)
git cherry-pick --allow-empty abc123

# Perform cherry-pick but do not create a commit
git cherry-pick --no-commit abc123

# Cherry-pick a merge commit (specify parent number)
git cherry-pick -m 1 merge_commit_hash
```

**Example: Cherry-picking from a Forked Repository**

```bash
# Add the fork as a remote
git remote add fork https://github.com/user/forked-repo.git

# Fetch the fork's branches
git fetch fork

# Cherry-pick a commit from the fork
git cherry-pick fork/branch~3
```

**Best Practices for Cherry-picking**

1. **Use sparingly**: Prefer merging or rebasing for integrating related changes
2. **Document cherry-picks**: Use the `-x` flag to reference the original commit
3. **Be aware of dependencies**: Cherry-picked commits might depend on other changes
4. **Consider context**: A commit might not make sense in isolation from its branch
5. **Verify after cherry-picking**: Test that the cherry-picked changes work as expected

### Understanding the Reflog (`git reflog`)

The reflog is Git's safety net—a chronological record of where your HEAD and branch references have been. It's an essential tool for recovering from mistakes, especially after history-altering operations.

**Key Points**

- Records all reference changes (where HEAD pointed) in your local repository
- Maintains history of branch tips and HEAD movements
- Entries expire after a configurable time (default 90 days)
- Only exists locally; not pushed to remote repositories
- Critical for recovering from destructive commands or mistakes
- Provides a safety net when rewriting history

**Basic Reflog Commands**

```bash
# Show the HEAD reflog
git reflog
# or
git reflog show HEAD

# Show reflog for a specific branch
git reflog show main

# Show detailed reflog entries
git reflog --all

# Show the reflog with dates
git reflog --date=iso

# Limit the number of entries
git reflog -n 10
```

**Example Reflog Output**

```
$ git reflog
734713b (HEAD -> main) HEAD@{0}: commit: Update documentation
a6f113e HEAD@{1}: checkout: moving from feature/login to main
89acf21 (feature/login) HEAD@{2}: commit: Add password validation
427dea9 HEAD@{3}: commit: Implement login form
a6f113e HEAD@{4}: checkout: moving from main to feature/login
a6f113e HEAD@{5}: reset: moving to HEAD~2
7f4e115 HEAD@{6}: commit: Add user settings
2b504be HEAD@{7}: commit: Refactor auth module
a6f113e HEAD@{8}: clone: from https://github.com/user/repo.git
```

Each entry shows:

1. The commit hash at that point
2. HEAD@{n} reference (position in reflog history)
3. The action that caused the reference change
4. Additional context about the action

**Recovery Scenarios Using Reflog**

1. **Recovering from Detached HEAD**
    
    ```bash
    # You made commits in detached HEAD state and checked out another branch
    git reflog
    # Find your lost commits in the reflog output
    git branch recovered-work abc123  # Create branch at the lost commit
    ```
    
2. **Undoing a Reset**
    
    ```bash
    # You did a hard reset and lost commits
    git reflog
    # Find the commit before the reset
    git reset --hard HEAD@{1}  # Go back to before the reset
    ```
    
3. **Recovering from a Bad Rebase**
    
    ```bash
    # Rebase went wrong
    git reflog
    # Find the commit before rebase started
    git reset --hard HEAD@{5}  # Back to pre-rebase state
    ```
    
4. **Recovering Deleted Branches**
    
    ```bash
    # You deleted a branch accidentally
    git reflog
    # Find the commit that was at branch tip
    git checkout -b restored-branch abc123
    ```
    

**Reflog Expiration and Maintenance**

By default, reflog entries expire after:

- 90 days for reachable entries
- 30 days for unreachable entries

You can adjust these settings:

```bash
# Change expiration time for all entries
git config --global gc.reflogExpire "60 days"

# Change expiration for unreachable entries
git config --global gc.reflogExpireUnreachable "2 weeks"

# Force immediate expiration of old reflog entries
git reflog expire --expire=now --all

# Prune all unreachable objects
git gc --prune=now
```

**Analyzing Reflog with Advanced Commands**

```bash
# Show the complete history of a file across reflog
git log --walk-reflogs -- path/to/file

# Compare state across reflog entries
git diff HEAD@{2} HEAD@{0}

# Show detailed information about a specific reflog entry
git show HEAD@{2}

# View branches and HEAD at a specific point in reflog
git branch -a --contains HEAD@{1}
```

### The Dangers of Rewriting Public History

Rewriting Git history can be powerful for maintaining clean repositories, but it becomes problematic when applied to shared or public history. Understanding these dangers is critical to using Git effectively in collaborative environments.

**Key Points**

- Rewriting public history disrupts other developers' workflows
- Changes commit hashes, making history diverge
- Requires force pushes which can overwrite others' work
- Can lead to duplicate commits and merge conflicts
- May cause loss of contributions or code
- Goes against Git's design principle of immutable history
- Can break CI/CD pipelines and automated processes

**Commands That Rewrite History**

These commands alter existing commits and should be used with caution:

1. `git commit --amend`
2. `git rebase`
3. `git filter-branch`
4. `git reset --hard`
5. `git push --force`
6. `git cherry-pick` (when duplicating already pushed commits)
7. Interactive rebase operations (squash, reword, etc.)

**Common Problematic Scenarios**

1. **The Forced Push Problem**
    
    ```bash
    # Developer A
    git checkout main
    git pull
    # Makes changes and commits
    git push
    
    # Developer B (meanwhile)
    git checkout main
    git pull
    # Amends the last commit
    git commit --amend
    git push --force  # Overwrites Developer A's commit
    
    # Developer A now has diverged history
    git pull  # Results in conflicts or lost work
    ```
    
2. **Rebasing Public Branches**
    
    ```bash
    # Developer A
    git checkout feature
    git rebase main  # Rewrites all feature branch commits
    git push --force  # Forces new history to remote
    
    # Developer B working on the same feature branch
    git pull  # Now has both old and new versions of commits
    # Results in duplicate commits and confusing history
    ```
    

**Visual Example**

Before rewriting:

```
A---B---C (main)
     \
      D---E---F (feature)
```

After rebasing and force pushing `feature`:

```
A---B---C (main)
         \
          D'---E'---F' (feature)
     \
      D---E---F (Developer B's local feature)
```

Developer B now has both the original commits (D, E, F) and the rewritten ones (D', E', F'), causing confusion and potential duplicated work.

**Impact on Collaboration**

1. **Lost work**: Force pushes can delete commits pushed by others
2. **Duplicate work**: Developers may fix the same issues twice due to history divergence
3. **Merge hell**: Complex conflicts when trying to reconcile divergent histories
4. **Build breakage**: CI/CD systems may fail due to unexpected history changes
5. **Bisect problems**: Git bisect becomes unreliable with rewritten history
6. **Trust issues**: Changing history can be seen as tampering with the project record

**Warning Signs You're About to Rewrite Public History**

- Using `--force` or `-f` with `git push`
- Rebasing a branch that exists on the remote repository
- Amending commits that have been pushed
- Running `filter-branch` on shared branches
- Hard resetting to an older commit and pushing

**Safer Alternatives**

Instead of rewriting public history, consider:

1. **New commits**: Add new commits that fix issues rather than rewriting old ones
2. **Revert commits**: Use `git revert` to create inverse commits
3. **Feature branches**: Limit history rewriting to private feature branches
4. **Fixup commits**: Use temporary fixup commits during development, squash before merging
5. **Pull requests**: Use PR systems that can squash on merge

**Example: Using Revert Instead of Rewrite**

```bash
# Instead of amending a pushed commit with a fix
git commit --amend  # BAD for public history

# Create a new commit with the fix
git add file.txt
git commit -m "Fix bug introduced in previous commit"  # GOOD

# Or explicitly revert a bad commit
git revert abc123
```

### When to Rewrite History (and When Not To)

Knowing when history rewriting is appropriate—and when it's dangerous—is an essential skill for Git users. Different contexts and workflows have different tolerances for history manipulation.

**Key Points**

- Private branches are generally safe to rewrite
- Public/shared branches should rarely if ever be rewritten
- Consider the team's Git expertise before rewriting shared history
- Some organizations have strict policies against history rewriting
- Always communicate history rewrites to affected team members
- The appropriateness depends on the branch's purpose and audience

**Safe to Rewrite**

1. **Personal branches only you use**
    
    ```bash
    # Your private feature branch
    git checkout my-feature
    git rebase -i HEAD~3  # Safe - only you see this branch
    ```
    
2. **Feature branches before opening pull requests**
    
    ```bash
    # Clean up history before creating PR
    git checkout feature/user-auth
    git rebase -i main
    git push --force-with-lease  # If already pushed to YOUR fork
    ```
    
3. **Local commits that haven't been pushed**
    
    ```bash
    # Fix the last commit before pushing
    git commit --amend
    ```
    
4. **Short-lived shared feature branches (with communication)**
    
    ```bash
    # After coordinating with team members
    git checkout feature/shared
    git rebase -i main
    # Alert team: "I've rebased feature/shared, please reset your local copy"
    git push --force-with-lease
    ```
    

**Avoid Rewriting**

1. **Main/master branches**
    
    ```bash
    # Never do this on main branch
    git checkout main
    git reset --hard HEAD~3
    git push --force  # Extremely dangerous!
    ```
    
2. **Release branches**
    
    ```bash
    # Avoid on branches tracking releases
    git checkout release/2.0
    git rebase -i main  # Problematic!
    ```
    
3. **Any branch others actively work on**
    
    ```bash
    # Disrupts team workflow
    git checkout team-feature
    git rebase -i  # Will cause problems for collaborators
    ```
    
4. **Any branch relied upon by CI/CD systems**
    
    ```bash
    # Can break builds and deployments
    git checkout staging
    git reset --hard feature  # May break automated processes
    ```
    

**Decision Framework**

Ask these questions before rewriting history:

1. Who has access to this branch?
2. Has anyone else pulled this branch?
3. Is this branch integrated into any automated systems?
4. Does our team have protocols for history rewriting?
5. Can I effectively communicate this change to all stakeholders?
6. Would a new commit serve the same purpose?

**Examples of Appropriate History Rewriting**

1. **Cleaning up feature branches before review**
    
    ```bash
    # Before submitting PR, clean up history
    git checkout feature/login
    git rebase -i main
    # Squash related commits, fix messages, etc.
    git push --force-with-lease  # Only if previously pushed to your fork
    ```
    
2. **Removing sensitive information**
    
    ```bash
    # Remove accidentally committed credentials
    git filter-branch --force --index-filter \
    "git rm --cached --ignore-unmatch config/secrets.yml" \
    --prune-empty --tag-name-filter cat -- --all
    # Must coordinate with team before pushing!
    ```
    
3. **Applying fixup commits before merging**
    
    ```bash
    # During development
    git commit --fixup abc123  # Mark as fix for earlier commit
    
    # Before PR/merge
    git rebase -i --autosquash main
    ```
    

**Examples of Inappropriate History Rewriting**

1. **Rewriting main branch because of a bad commit**
    
    ```bash
    # WRONG APPROACH
    git checkout main
    git reset --hard HEAD~1  # Remove bad commit
    git push --force
    
    # RIGHT APPROACH
    git checkout main
    git revert HEAD  # Create new commit that undoes changes
    git push
    ```
    
2. **Rebasing a long-running feature branch with multiple contributors**
    
    ```bash
    # WRONG APPROACH
    git checkout feature/team-project
    git rebase main
    git push --force  # Breaks everyone's workflow
    
    # RIGHT APPROACH
    git checkout feature/team-project
    git merge main  # Preserves history
    git push
    ```
    

**Best Practices When History Rewriting Is Necessary**

1. **Communicate clearly beforehand**
    
    ```
    "I will rebase feature/X at 2pm today. Please commit and push your work before then and
    refresh your branch afterward with git fetch && git reset --hard origin/feature/X"
    ```
    
2. **Use `--force-with-lease` instead of `--force`**
    
    ```bash
    git push --force-with-lease  # Safer, prevents overwriting others' new work
    ```
    
3. **Create backups before significant history manipulation**
    
    ```bash
    git branch backup/feature-before-rebase feature
    ```
    
4. **Document changes in commit messages**
    
    ```bash
    # After significant rewriting
    git commit --allow-empty -m "NOTE: Branch history rewritten to remove sensitive data"
    ```
    
5. **Establish team protocols for rewriting**
    
    ```
    "Feature branch owners may rebase their branches before merge.
    Main, release, and develop branches are never rewritten."
    ```
    

**Git Configuration for Safer History Rewriting**

```bash
# Prevent accidental force pushes to protected branches
git config --global receive.denyNonFastForwards true

# Make --force-with-lease the default force push behavior
git config --global alias.forcepush 'push --force-with-lease'

# Warn when rewinding more than 5 commits on checkout/reset
git config --global warn.rewindOnCheckout 5

# Create an alias for safe rebase workflow
git config --global alias.saferebase '!f() { git checkout -b backup/$(git rev-parse --abbrev-ref HEAD)-$(date +%Y%m%d%H%M%S); git checkout -; git rebase "$@"; }; f'
```

### Related Topics

- Interactive rebasing techniques and workflows
- Git filter-branch for repository cleanup
- Git BFG Repo-Cleaner for removing sensitive data
- Repository recovery strategies
- Git hooks to enforce history protection
- Team policies for Git history management

---

