## Manipulation of Commits


### Amending Commits

The `git commit --amend` command allows you to modify your most recent commit. This is useful for:

- Adding forgotten changes
- Correcting commit messages
- Adjusting author information

When you amend a commit, Git replaces the previous commit with a new one, effectively erasing the old commit from history.

```bash
# First, make your changes
git add forgotten-file.txt

# Then amend the previous commit
git commit --amend
```

By default, this opens your text editor to edit the commit message. To keep the same message:

```bash
git commit --amend --no-edit
```

To change only the commit message:

```bash
git commit --amend -m "New improved commit message"
```

**Key Points:**

- Amending creates a new commit with a different SHA-1 hash
- Only amend commits that haven't been pushed to a shared repository
- If the commit has been pushed, amending will require a force push (`git push --force`)
- Force pushing can disrupt teammates' work if they've based work on the original commit
- You can also amend author information: `git commit --amend --author="New Author <email@example.com>"`

### Interactive Rebase

Interactive rebase is a powerful tool for rewriting commit history. It allows you to:

- Reorder commits
- Edit commit messages
- Combine (squash) commits
- Split commits
- Remove commits entirely

The basic syntax is:

```bash
git rebase -i <base-commit>
```

where `<base-commit>` is the commit before the first one you want to modify.

**Example:** To modify the last 3 commits:

```bash
git rebase -i HEAD~3
```

This opens your text editor with a list of commits and commands:

```
pick f7f3f6d Update feature A
pick 310154e Fix typo in docs
pick a5f4a0d Add new validation

# Rebase 710f0f8..a5f4a0d onto 710f0f8
#
# Commands:
# p, pick <commit> = use commit
# r, reword <commit> = use commit, but edit the commit message
# e, edit <commit> = use commit, but stop for amending
# s, squash <commit> = use commit, but meld into previous commit
# f, fixup <commit> = like "squash", but discard this commit's message
# d, drop <commit> = remove commit
# ...
```

You modify this file to indicate what you want to do with each commit, save, and close the editor.

**Key Points:**

- Interactive rebase changes commit hashes for all modified commits and their descendants
- Never rebase commits that have been pushed to a shared repository unless coordinated with your team
- Git may pause the rebase for you to make changes, then you continue with `git rebase --continue`
- If things go wrong, you can abort with `git rebase --abort`
- Check your work with `git log` after rebasing

### Squashing Commits

Squashing combines multiple commits into a single, cohesive commit. This is useful for cleaning up work-in-progress commits before sharing code.

There are two main ways to squash commits:

1. **During interactive rebase:**

```bash
git rebase -i HEAD~3
```

Then change `pick` to `squash` or `fixup` for the commits you want to combine:

```
pick f7f3f6d First commit in feature
squash 310154e WIP: Continued implementation
squash a5f4a0d Fix bug in implementation
```

2. **Using `--squash` during merge:**

```bash
git checkout main
git merge --squash feature-branch
git commit -m "Implement feature X"
```

The difference between `squash` and `fixup` during rebase:

- `squash` preserves the commit message and lets you edit the combined message
- `fixup` discards the commit message entirely

**Example:** Original history:

```
A---B---C---D---E  (feature)
```

After squashing C, D, and E:

```
A---B---F  (feature)
```

Where F contains all changes from C, D, and E.

**Key Points:**

- Squashing is great for cleaning up "checkpoint" commits
- Use descriptive commit messages for the resulting squashed commit
- Remember that squashing loses the individual commit history
- Consider preserving significant commits that represent logical steps
- Squashing before pushing helps maintain a clean public history

### Editing Commit Messages

Git provides multiple ways to edit commit messages:

1. **For the most recent commit:**

```bash
git commit --amend
```

2. **For older commits (via interactive rebase):**

```bash
git rebase -i HEAD~5
```

Then change `pick` to `reword` for the commits whose messages you want to edit:

```
pick f7f3f6d First feature commit
reword 310154e Implement core functionality
pick a5f4a0d Add tests
```

After saving, Git will open an editor for each commit marked with `reword`.

**Best practices for commit messages:**

- First line: concise summary (50 chars or less)
- Blank line after the summary
- Detailed explanation (if needed) with line breaks at ~72 chars
- Use imperative mood ("Add feature" not "Added feature")
- Explain what and why, not how

**Example of a good commit message:**

```
Add user authentication with JWT

- Implement JWT token generation on login
- Add middleware for protected routes
- Store refresh tokens in Redis for better security

Fixes #123
```

**Key Points:**

- Clear commit messages make project history valuable for future developers
- Focus on why the change was made, not just what was changed
- Reference issue numbers where applicable
- Rewriting public commit messages can cause confusion for collaborators

### Reordering Commits

Reordering commits allows you to organize your history in a logical sequence before sharing it. This is particularly useful when you've made fixes or changes that conceptually belong earlier in the development process.

To reorder commits:

```bash
git rebase -i HEAD~5
```

In the editor, simply move the lines to reorder the commits:

```
# Original order
pick f7f3f6d Implement feature
pick 310154e Add tests
pick a5f4a0d Fix bug

# Reordered
pick a5f4a0d Fix bug
pick f7f3f6d Implement feature
pick 310154e Add tests
```

**Key Points:**

- Reordering commits that modify the same file may cause conflicts
- Git will stop the rebase when conflicts occur, allowing you to resolve them
- Use `git rebase --continue` after resolving conflicts
- Logical ordering helps create a coherent development narrative
- Consider the dependencies between commits when reordering

### Cherry-Picking Commits

Cherry-picking allows you to apply the changes from specific commits to your current branch, without merging the entire branch history.

```bash
git cherry-pick <commit-hash>
```

This creates a new commit on your current branch with the same changes as the original commit.

**Example scenario:** You have a bug fix in a feature branch that you also need in the main branch:

```bash
# Find the commit hash of the bug fix
git log feature-branch

# Switch to main and apply the fix
git checkout main
git cherry-pick abc1234
```

For multiple commits:

```bash
git cherry-pick abc1234 def5678 ghi9012
```

Or a range:

```bash
git cherry-pick abc1234^..ghi9012
```

**Key Points:**

- Cherry-picked commits get new hashes since they have new parent commits
- You may encounter conflicts that need resolution
- Use `--edit` to modify the commit message during cherry-pick
- Use `--no-commit` (`-n`) to apply changes without creating commits
- Cherry-picking is useful for hotfixes or backporting features

### Splitting Commits

Sometimes you may want to break a large commit into smaller, more focused commits. This process involves:

1. Start an interactive rebase:

```bash
git rebase -i HEAD~3
```

2. Mark the commit you want to split with `edit`:

```
pick f7f3f6d First commit
edit 310154e Large commit to split
pick a5f4a0d Final commit
```

3. When the rebase stops at the marked commit, reset it to unstage all changes:

```bash
git reset HEAD^
```

4. Add and commit changes in logical chunks:

```bash
git add part-of-changes.js
git commit -m "First part: Add feature X"

git add another-part.js
git commit -m "Second part: Add feature Y"
```

5. Continue the rebase:

```bash
git rebase --continue
```

**Key Points:**

- Splitting creates more granular, focused commits
- Makes code review easier by separating unrelated changes
- Useful when you realize a commit contains multiple logical changes
- Can help isolate the source of bugs using `git bisect`

### Recovering Lost Commits

Even after manipulating history, Git preserves commits for a period of time. The `git reflog` command shows a history of where HEAD has pointed, allowing you to recover "lost" commits:

```bash
git reflog
```

**Output:**

```
a5f4a0d (HEAD -> feature) HEAD@{0}: rebase -i (finish): returning to refs/heads/feature
310154e HEAD@{1}: rebase -i (squash): Fix implementation
f7f3f6d HEAD@{2}: rebase -i (start): checkout HEAD~3
b7d3f9c HEAD@{3}: commit: Add feature test
...
```

To recover a lost commit:

```bash
git checkout -b recovery-branch b7d3f9c
```

Or reset your current branch to it:

```bash
git reset --hard b7d3f9c
```

**Key Points:**

- Reflog entries expire after 30 days by default
- Only tracks commits that were part of your local repository
- Does not track unpushed commits on other machines
- A safety net for risky history-altering operations

### Best Practices for Commit Manipulation

1. **Never rewrite public history**
    
    - Only rewrite commits that haven't been pushed
    - If you must rewrite pushed commits, coordinate with your team
2. **Create clean, logical commits**
    
    - Each commit should represent one logical change
    - Use squashing to clean up work-in-progress commits
    - Split large commits into focused units
3. **Write meaningful commit messages**
    
    - Clearly explain the purpose of the change
    - Reference issue numbers where applicable
4. **Test after rebasing**
    
    - History rewrites can introduce subtle bugs
    - Run tests to ensure functionality is preserved
5. **Use branches for experimental history rewrites**
    
    - Work on a temporary branch for major rewrites
    - This preserves your original history until you're satisfied

**Conclusion:** Manipulating commits is a powerful aspect of Git that allows you to craft a clean, logical history. Used carefully, these techniques help create a project history that serves as useful documentation rather than a mere log of changes. However, these powers come with responsibility—always be mindful of when and how you alter history, especially in collaborative environments. Master these techniques to maintain a professional, readable, and useful Git history that helps rather than hinders your team's understanding of the project's evolution.

---

