## Basic Merging


### Understanding Merge Operations

Merging in Git is the process of combining changes from different branches. When you merge, Git attempts to automatically integrate the changes made in separate development lines into a single unified history.

Merging is essential for bringing together parallel work and is a fundamental operation in any collaborative Git workflow. It allows team members to work independently on different features or fixes and then combine their changes when ready.

**Key Points:**

- Merging combines the history of two or more branches
- Git analyzes commit histories to determine how to combine changes
- The target branch (where you're merging into) is updated, but the source branch remains unchanged
- Git's merge algorithms handle most integrations automatically

### Fast-Forward Merges

A fast-forward merge is the simplest type of merge, occurring when the current branch's tip is a direct ancestor of the branch you're merging in. In other words, there are no divergent changes to reconcile.

In a fast-forward merge:

1. The current branch pointer simply moves forward to point to the same commit as the merged branch
2. No new commit is created
3. The history remains linear

**Example:**

```
Before:          After:
A---B---C main   A---B---C---D---E main
         \                       \
          D---E feature           feature
```

To perform a fast-forward merge:

```bash
git checkout main
git merge feature
```

**Output:**

```
Updating 83ed0f7..bd6903f
Fast-forward
 file.txt | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)
```

**Key Points:**

- Fast-forward is Git's default behavior when possible
- No merge commit is created, resulting in a clean, linear history
- To prevent fast-forward and force a merge commit: `git merge --no-ff feature`
- Fast-forward is only possible when no new changes exist in the target branch

### Recursive Merges

When the branch being merged has diverged from the current branch (both have unique commits), Git uses a recursive merge strategy. This is Git's default merge strategy for branches that have diverted.

The recursive strategy:

1. Identifies a common ancestor (base) commit between the branches
2. Compares the changes made in each branch since the common ancestor
3. Combines these changes into a new "merge commit"
4. The merge commit has two parent commits (one from each branch)

**Example:**

```
Before:             After:
      A---B---C main       A---B---C-------M main
           \                          /
            D---E feature   D---E feature
```

To perform a recursive merge:

```bash
git checkout main
git merge feature
```

**Output:**

```
Merge made by the 'recursive' strategy.
 file.txt | 15 +++++++++++++++
 1 file changed, 15 insertions(+)
```

**Key Points:**

- The recursive strategy creates a merge commit with two parent commits
- It preserves the complete history of both branches
- The resulting history shows the parallel development that occurred
- This is Git's automatic behavior when branches have diverged

### Merge Commits

A merge commit is a special commit that has two parent commits, representing the tips of the merged branches. It marks the point where two development histories are joined together.

Anatomy of a merge commit:

- Has a unique commit hash like any other commit
- Contains combined changes from both branches
- Records two parent commits instead of one
- Typically has an auto-generated commit message: "Merge branch 'feature' into main"

**Example:**

```
commit 83ab2f1c9bd7a149b23719f01c2a23fb5d2257b1 (HEAD -> main)
Merge: 6d04a22 bd6903f
Author: Jane Doe <jane@example.com>
Date:   Wed May 8 15:42:31 2025 -0700

    Merge branch 'feature' into main
```

You can customize the merge commit message using:

```bash
git merge feature -m "Merge feature X implementation"
```

**Key Points:**

- Merge commits provide visual cues in the project history
- They explicitly indicate when and where integration occurred
- Some teams prefer to avoid merge commits for a cleaner history
- Others value merge commits for preserving the project's development narrative

### Using `git merge`

The `git merge` command is used to combine changes from one branch into another. The syntax is:

```bash
git merge <branch-name>
```

Before merging:

1. Commit or stash all changes in your working directory
2. Checkout the target branch (where changes will be merged into)
3. Pull the latest changes from remote (if applicable)
4. Run the merge command

**Example workflow:**

```bash
# Ensure working directory is clean
git status

# Switch to target branch
git checkout main

# Update from remote (if applicable)
git pull origin main

# Merge the feature branch
git merge feature-branch
```

#### Merge Options

Git provides several options to control merge behavior:

```bash
git merge --no-ff feature      # Create a merge commit even if fast-forward is possible
git merge --ff-only feature    # Only merge if fast-forward is possible
git merge --squash feature     # Combine all changes as a single commit
git merge --abort              # Abort a merge in progress
git merge -X ours feature      # Favor our version in conflicts
git merge -X theirs feature    # Favor their version in conflicts
```

**Example:** Using `--squash` to combine multiple commits into one:

```bash
git checkout main
git merge --squash feature

# This stages all changes but doesn't commit
# You need to commit manually:
git commit -m "Implement feature X"
```

Result:

```
         A---B---C---D main
        /
A---B---C
        \
         E---F---G feature
```

**Key Points:**

- `--no-ff` is useful for explicitly marking feature integrations
- `--squash` creates a cleaner history but loses the detailed commit information
- `--abort` is helpful when merge conflicts are too complex to resolve immediately
- `-X` options provide automatic conflict resolution strategies

### Handling Merge Conflicts

When Git can't automatically merge changes, it reports a conflict. This happens when the same part of a file was modified differently in both branches.

When a conflict occurs:

1. Git pauses the merge operation
2. Marks the conflicted files with conflict markers
3. Allows you to manually resolve the conflicts

```
<<<<<<< HEAD
Changes in the current branch
=======
Changes from the branch being merged
>>>>>>> feature
```

To resolve conflicts:

1. Open the conflicted files and edit them to remove conflict markers
2. Choose which changes to keep or combine them
3. Save the files
4. Add the resolved files: `git add <filename>`
5. Complete the merge: `git commit`

**Key Points:**

- Use `git status` to identify conflicted files
- Use `git diff` to see the exact conflicts
- Visual merge tools can simplify conflict resolution
- Always test after resolving conflicts

### Best Practices for Merging

1. **Merge frequently** to minimize conflicts
2. **Use feature branches** for isolated work
3. **Keep commits focused** on single, logical changes
4. **Write descriptive commit messages**
5. **Test before and after merging**
6. **Consider your team's preferred workflow**:
    - Some teams prefer regular merges with merge commits
    - Others prefer rebasing for a linear history

**Example branch strategy:**

```
main       A---B---C---------------G---H
              \                   /
feature-1      D---E---F---------/
                   \         /
feature-2           I---J---K
```

**Key Points:**

- Communicate with your team before merging significant changes
- Consider code reviews before merging
- Use Pull/Merge Requests for review on GitHub/GitLab/Bitbucket
- Understand your project's merge conventions

### When to Use Different Merge Approaches

|Merge Type|Best For|
|---|---|
|Fast-forward|Simple features with linear history|
|Recursive (with merge commit)|Major features, release branches|
|Squash|Bug fixes, minor changes, keeping history clean|
|Rebase then merge|Linear history preference|

**Example decision process:**

- For a small bug fix: `git merge --squash bugfix`
- For a major feature: `git merge --no-ff feature`
- For ongoing development: `git merge feature`

**Conclusion:** Merging is a fundamental Git operation that enables collaborative development. Understanding the different merge types helps you choose the right approach for your specific situation. While Git handles most merges automatically, knowing how to resolve conflicts and when to use various merge options will make your development workflow more efficient. As you gain experience, you'll develop preferences for how your project's history should be structured through merging strategies.

---

