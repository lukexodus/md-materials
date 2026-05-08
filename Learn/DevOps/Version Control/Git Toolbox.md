## Commands

Certainly! Below is a list of the most common Git commands, ordered by typical workflow stages. This will guide you through a standard Git workflow from repository creation to collaboration and merging changes.

### 1. **Repository Setup**

- **Initialize a repository:**
  ```bash
  git init
  ```

- **Clone an existing repository:**
  ```bash
  git clone <repository-url>
  ```

### 2. **Basic Snapshotting**

- **Check the status of your working directory and staging area:**
  ```bash
  git status
  ```

- **Track new files and stage changes for commit:**
  ```bash
  git add <file>
  git add .
  ```

- **Commit staged changes:**
  ```bash
  git commit -m "Commit message"
  ```

- **Amend the last commit (only if not pushed):**
  ```bash
  git commit --amend
  ```

### 3. **Branching and Merging**

- **Create a new branch:**
  ```bash
  git branch <branch-name>
  ```

- **Switch to a branch:**
  ```bash
  git checkout <branch-name>
  ```

- **Create and switch to a new branch:**
  ```bash
  git checkout -b <branch-name>
  ```

- **Merge a branch into the current branch:**
  ```bash
  git merge <branch-name>
  ```

- **Delete a branch:**
  ```bash
  git branch -d <branch-name>
  git branch -D <branch-name>  # Force delete
  ```

### 4. **Remote Repositories**

- **Add a remote repository:**
  ```bash
  git remote add origin <repository-url>
  ```

- **Fetch changes from a remote repository:**
  ```bash
  git fetch origin
  ```

- **Push changes to a remote repository:**
  ```bash
  git push origin <branch-name>
  ```

- **Pull changes from a remote repository and merge:**
  ```bash
  git pull origin <branch-name>
  ```

### 5. **Stashing and Cleaning**

- **Stash uncommitted changes:**
  ```bash
  git stash
  ```

- **Apply stashed changes:**
  ```bash
  git stash apply
  ```

- **List stashes:**
  ```bash
  git stash list
  ```

- **Clean untracked files:**
  ```bash
  git clean -f
  ```

### 6. **Inspecting and Comparing**

- **Show commit history:**
  ```bash
  git log
  git log --oneline
  ```

- **Show changes between commits, branches, or working directory:**
  ```bash
  git diff
  git diff <commit> <commit>
  git diff <branch> <branch>
  ```

- **Show detailed information about a commit:**
  ```bash
  git show <commit>
  ```

- **Blame on a file to see who made changes:**
  ```bash
  git blame <file>
  ```

### 7. **Undoing Changes**

- **Revert a commit (create a new commit that undoes changes):**
  ```bash
  git revert <commit>
  ```

- **Reset to a previous commit (different reset types):**
  ```bash
  git reset --soft <commit>
  git reset --mixed <commit>  # Default
  git reset --hard <commit>
  ```

- **Unstage a file:**
  ```bash
  git reset <file>
  ```

### 8. **Tagging**

- **Create a new tag:**
  ```bash
  git tag <tag-name>
  ```

- **Push tags to remote:**
  ```bash
  git push origin <tag-name>
  git push origin --tags  # Push all tags
  ```

### 9. **Collaboration and Reviews**

- **Create a Pull Request (typically on a platform like GitHub, GitLab, or Bitbucket).**
- **Review and merge Pull Requests via the web interface of your hosting service.**

### 10. **Advanced Branching**

- **List all branches (local and remote):**
  ```bash
  git branch -a
  ```

- **Rename a branch:**
  ```bash
  git branch -m <old-name> <new-name>
  ```

### 11. **Advanced Merging**

- **Squash merging (combine multiple commits into one):**
  ```bash
  git merge --squash <branch-name>
  ```

### 12. **Rebasing**

- **Rebase current branch onto another branch:**
  ```bash
  git rebase <branch-name>
  ```

- **Interactive rebase (edit, reorder, or squash commits):**
  ```bash
  git rebase -i <commit>
  ```

- **Abort a rebase:**
  ```bash
  git rebase --abort
  ```

- **Continue a rebase after resolving conflicts:**
  ```bash
  git rebase --continue
  ```

### 13. **Cherry-picking**

- **Apply a specific commit from one branch to another:**
  ```bash
  git cherry-pick <commit>
  ```

### 14. **Bisecting**

- **Find the commit that introduced a bug using binary search:**
  ```bash
  git bisect start
  git bisect bad
  git bisect good <commit>
  ```

- **Mark the current commit as good or bad during a bisect session:**
  ```bash
  git bisect good
  git bisect bad
  ```

### 15. **Submodules**

- **Add a submodule to your repository:**
  ```bash
  git submodule add <repository-url> <path>
  ```

- **Initialize and update submodules:**
  ```bash
  git submodule update --init --recursive
  ```

### 16. **Configuration**

- **Set global configuration options (e.g., user name and email):**
  ```bash
  git config --global user.name "Your Name"
  git config --global user.email "your.email@example.com"
  ```

- **List all configuration settings:**
  ```bash
  git config --list
  ```

### 17. **Logs and History**

- **Show a detailed commit log with graphical representation:**
  ```bash
  git log --graph --oneline --decorate --all
  ```

- **Show changes introduced by each commit:**
  ```bash
  git log -p
  ```

### 18. **Aliases**

- **Create a shortcut for a commonly used command:**
  ```bash
  git config --global alias.co checkout
  git config --global alias.br branch
  git config --global alias.ci commit
  git config --global alias.st status
  ```

### 19. **Worktrees**

- **Create a new working directory (worktree) linked to the same repository:**
  ```bash
  git worktree add <path> <branch>
  ```

- **List all worktrees:**
  ```bash
  git worktree list
  ```

### 20. **Hooks**

- **Set up Git hooks for custom actions (e.g., pre-commit, post-commit):**
  - Create a script in the `.git/hooks/` directory, such as `.git/hooks/pre-commit`.

### 21. **Bundle**

- **Create a bundle of a repository:**
  ```bash
  git bundle create <file> <branch>
  ```

- **Clone from a bundle:**
  ```bash
  git clone <file> -b <branch> <directory>
  ```

### 22. **Archive**

- **Create a tar or zip archive of the repository:**
  ```bash
  git archive --format=tar --output=<file>.tar <branch>
  git archive --format=zip --output=<file>.zip <branch>
  ```

### 23. **Git Maintenance**

- **Run garbage collection to optimize the repository:**
  ```bash
  git gc
  ```

### 24. **Handling Large Files**

- **Using Git Large File Storage (LFS) to handle large files:**
  - Install Git LFS:
    ```bash
    git lfs install
    ```

  - Track a large file:
    ```bash
    git lfs track "<file>"
    ```

  - Add and commit the large file as usual:
    ```bash
    git add <file>
    git commit -m "Add large file"
    ```

### 25. **Security**

- **Signing commits with GPG:**
  - Configure Git to use your GPG key:
    ```bash
    git config --global user.signingkey <your-key-id>
    ```

  - Sign a commit:
    ```bash
    git commit -S -m "Signed commit"
    ```
### -- Breakdowns --

### `git reset`

`git reset` is a powerful Git command used to undo changes. It can modify the commit history and the working directory in various ways depending on the options provided. Here's an overview of what `git reset` can do and how to use it effectively.

**Overview of `git reset`**

The `git reset` command comes with three primary options, which determine the scope of its action:

1. **`--soft`**: This option moves the HEAD pointer to a specified commit, but it does not change the working directory or the index (staging area). This means that all changes remain staged for commit.

   ```bash
   git reset --soft <commit>
   ```

2. **`--mixed`** (default): This option moves the HEAD pointer to a specified commit and un-stages all changes that were committed after the specified commit. It leaves your working directory unchanged.

   ```bash
   git reset --mixed <commit>
   ```

3. **`--hard`**: This option moves the HEAD pointer to a specified commit and resets the index and working directory to match that commit. This will remove all changes that were made after the specified commit.

   ```bash
   git reset --hard <commit>
   ```

**Detailed Usage**

**Example Commit History**

For the examples below, assume the following commit history:

```
a1b2c3d (HEAD -> main) Commit 3
e4f5g6h Commit 2
i7j8k9l Commit 1
```

1. **`git reset --soft <commit>`**

Moves the HEAD to the specified commit but keeps all changes in the staging area.

```bash
git reset --soft e4f5g6h
```

- **Before**: The HEAD is at `a1b2c3d` (Commit 3).
- **After**: The HEAD moves to `e4f5g6h` (Commit 2), but the changes from `Commit 3` remain staged.

2. **`git reset --mixed <commit>`**

Moves the HEAD to the specified commit and un-stages all changes after the specified commit, but keeps them in the working directory.

```bash
git reset --mixed e4f5g6h
```

- **Before**: The HEAD is at `a1b2c3d` (Commit 3).
- **After**: The HEAD moves to `e4f5g6h` (Commit 2), and the changes from `Commit 3` are un-staged but remain in the working directory.

3. **`git reset --hard <commit>`**

Moves the HEAD to the specified commit and discards all changes in the index and working directory after the specified commit.

```bash
git reset --hard e4f5g6h
```

- **Before**: The HEAD is at `a1b2c3d` (Commit 3).
- **After**: The HEAD moves to `e4f5g6h` (Commit 2), and the changes from `Commit 3` are completely removed from the working directory and index.

**Practical Use Cases**

*Undoing the Last Commit*

If you want to undo the last commit but keep the changes in the staging area:

```bash
git reset --soft HEAD~1
```

*Unstaging Changes*

If you accidentally staged some changes and want to un-stage them:

```bash
git reset HEAD <file>
```

*Discarding All Changes*

If you want to discard all changes and reset to a specific commit (be careful with this as it will remove all uncommitted changes):

```bash
git reset --hard <commit>
```

**Important Notes**

- **Caution with `--hard`**: The `--hard` option is destructive as it removes changes from the working directory and index. Use it with caution.
- **Backup Changes**: If you are unsure about the changes you are about to discard, consider stashing them using `git stash` or creating a new branch before resetting.
- **Impact on History**: `git reset` changes the commit history. If you have already pushed commits to a remote repository, be aware that using `git reset` can create issues for collaborators. In such cases, `git revert` might be a safer option as it creates a new commit that undoes the changes, preserving the history.

### `git blame`

The `git blame` command is used to find out which commit and author last modified each line of a file. It's a powerful tool to investigate the history of a file and understand who made specific changes.

The basic syntax of the `git blame` command is as follows:

```
git blame <file>
```

Here's how `git blame` works:

1. It shows the contents of the file with annotations for each line, indicating the commit and author responsible for the last modification to that line.
2. The commit hash, author's name, and the date of the last modification are displayed for each line of the file.
3. By default, the output of `git blame` includes the commit hash and the author's name. You can use additional flags to customize the output, such as showing the commit message or a specific format.

Using `git blame`, you can:

1. Identify who made specific changes to a file: By running `git blame`, you can trace back through the commit history and see which commit and author last modified each line of the file. This can be helpful in understanding why certain changes were made and discussing them with the relevant author.

2. Investigate code issues or regressions: If you come across a bug or an issue in a specific line of code, `git blame` allows you to find out who made the change that introduced the issue. This can be valuable for identifying the person who can provide insights into the code or help resolve the problem.

3. Analyze the evolution of code: `git blame` helps you track the evolution of a file over time. By examining the commit history and the authorship of each line, you can understand how the code has changed, who contributed to it, and potentially gain insights into the development process.

It's worth noting that `git blame` should be used in a constructive and collaborative manner, focusing on understanding the code and its history rather than assigning blame. It's an essential tool for investigating and understanding code changes, collaborating effectively with other developers, and maintaining code quality and accountability.

### `git fetch origin` vs `git pull`

`git fetch origin` and `git pull` are both used to update your local repository with changes from a remote repository, but they do so in different ways and serve different purposes. Let's break down the differences and use cases for each:

**`git fetch origin`**

1. **Fetches Changes**: `git fetch origin` retrieves commits, files, and references from the remote repository (referred to as `origin`) and updates your local copy of the remote branches.

2. **No Working Directory Changes**: It does not change your working directory or your current branch. It simply updates your local copy of the remote branches.

3. **Safe and Non-Disruptive**: Since it does not modify your working directory, it is a safe operation. You can use it to see what changes are available on the remote before deciding how to integrate them.

4. **Usage**: Use `git fetch origin` when you want to see the new changes in the remote repository without merging those changes into your current branch.

   ```bash
   git fetch origin
   ```

   After fetching, you can inspect the fetched changes using commands like `git log origin/main` or `git diff origin/main`.

**`git pull`**

1. **Fetches and Integrates Changes**: `git pull` is essentially a combination of `git fetch` followed by `git merge`. It fetches the changes from the remote repository and then merges those changes into your current branch.

2. **Changes Working Directory**: It modifies your working directory by applying the changes from the remote branch to your current branch.

3. **Potential for Merge Conflicts**: Because it merges changes into your current branch, there is a potential for merge conflicts that you will need to resolve.

4. **Usage**: Use `git pull` when you are ready to integrate changes from the remote repository into your current branch.

   ```bash
   git pull origin <branch-name>
   ```

   Replace `<branch-name>` with the name of the branch you want to pull changes from (typically `main` or `master`).

**When to Use Each**

- **`git fetch origin`**: Use this command when you want to see the latest changes from the remote repository without applying them to your current branch. It's useful for reviewing changes and deciding how to integrate them. This command is often used as a precursor to a rebase or manual merge.

- **`git pull`**: Use this command when you are ready to bring your current branch up to date with the latest changes from the remote repository and you are okay with the changes being merged directly into your current branch.

**Example Workflow**

If you want to update your branch with the latest changes from the `main` branch, you might follow this workflow:

1. **Fetch the latest changes:**

   ```bash
   git fetch origin
   ```

2. **Switch to your branch:**

   ```bash
   git checkout <your-branch>
   ```

3. **Merge or rebase the changes from `main`:**

   - **Merge**:

     ```bash
     git merge origin/main
     ```

   - **Rebase**:

     ```bash
     git rebase origin/main
     ```

4. **Resolve any conflicts if necessary, and then push your updated branch:**

   ```bash
   git push origin <your-branch>
   ```

This way, you have more control over the integration process and can review changes before merging them into your branch.

### `git stash`

`git stash` is a powerful command in Git that allows you to temporarily save changes in your working directory and index (staging area) without committing them. This can be useful when you need to switch branches or pull changes from a remote repository without losing your current work.

**Basic Usage**

Stash Changes

- **Save current changes:**
  ```bash
  git stash
  ```

  This command saves your modified and staged changes, and reverts your working directory to match the HEAD commit.

- **Save changes with a message:**
  ```bash
  git stash save "Your stash message"
  ```

List Stashes

- **Show list of stashes:**
  ```bash
  git stash list
  ```

  This will show all stashes you've saved, each with an index and message if provided.

Apply Stash

- **Apply the latest stash:**
  ```bash
  git stash apply
  ```

  This reapplies the most recently created stash to your working directory without removing it from the stash list.

- **Apply a specific stash:**
  ```bash
  git stash apply stash@{index}
  ```

  Replace `index` with the index of the stash you want to apply, which can be found using `git stash list`.

Pop Stash

- **Apply and remove the latest stash:**
  ```bash
  git stash pop
  ```

  This applies the latest stash and removes it from the stash list.

- **Apply and remove a specific stash:**
  ```bash
  git stash pop stash@{index}
  ```

  Replace `index` with the index of the stash you want to apply and remove.

Drop Stash

- **Remove a specific stash:**
  ```bash
  git stash drop stash@{index}
  ```

  This removes the specified stash from the stash list without applying it.

- **Remove the latest stash:**
  ```bash
  git stash drop
  ```

  This removes the most recent stash.

Clear All Stashes

- **Remove all stashes:**
  ```bash
  git stash clear
  ```

  This will delete all stashes.

**Advanced Usage***

Stash Untracked and Ignored Files

- **Stash including untracked files:**
  ```bash
  git stash -u
  ```

  This includes untracked files in the stash.

- **Stash including ignored files:**
  ```bash
  git stash -a
  ```

  This includes both untracked and ignored files in the stash.

Creating a Branch from Stash

- **Create a new branch from a stash:**
  ```bash
  git stash branch <branch-name>
  ```

  This command creates a new branch, applies the latest stash to it, and removes the stash.

**Example Workflow**

1. **Stash Changes:**
   ```bash
   git stash save "Work in progress on feature X"
   ```

2. **Switch Branch:**
   ```bash
   git checkout main
   ```

3. **Pull Latest Changes:**
   ```bash
   git pull origin main
   ```

4. **Switch Back to Original Branch:**
   ```bash
   git checkout feature-branch
   ```

5. **Apply Stash:**
   ```bash
   git stash apply
   ```

6. **Commit Changes:**
   ```bash
   git add .
   git commit -m "Complete feature X"
   ```

7. **Push Changes:**
   ```bash
   git push origin feature-branch
   ```

8. **Drop Stash (if applied successfully):**
   ```bash
   git stash drop
   ```

**Summary**

- **Stash changes:** `git stash`, `git stash save "message"`
- **List stashes:** `git stash list`
- **Apply stash:** `git stash apply`, `git stash apply stash@{index}`
- **Pop stash:** `git stash pop`, `git stash pop stash@{index}`
- **Drop stash:** `git stash drop`, `git stash drop stash@{index}`
- **Clear all stashes:** `git stash clear`
- **Stash untracked/ignored files:** `git stash -u`, `git stash -a`
- **Create branch from stash:** `git stash branch <branch-name>`

### `git show`

The `git show` command in Git is used to display various types of objects, such as commits, trees, tags, and blobs. The most common use of `git show` is to display detailed information about a specific commit.

**Basic Usage**

Show a Specific Commit

- **Show the details of a specific commit:**
  ```bash
  git show <commit>
  ```

  Replace `<commit>` with the commit hash (SHA-1) or a reference to the commit (e.g., `HEAD`, `HEAD~1`).

**Example**

Suppose you want to see the details of the latest commit:
```bash
git show
```

To see the details of a specific commit:
```bash
git show 593181a
```

This command displays detailed information about the commit, including:

- Commit hash
- Author name and email
- Date of the commit
- Commit message
- Changes introduced by the commit (diff)

**Showing Specific Parts**

Show Commit Only

- **Show only the commit message and metadata (excluding the diff):**
  ```bash
  git show --no-patch <commit>
  ```


**Customizing the Output**

Show Commit with Stats

- **Show the commit with a summary of changes:**
  ```bash
  git show --stat <commit>
  ```

  This provides a summary of changes, including the number of files changed, insertions, and deletions.

Show Commit in a Compact Form

- **Show the commit in a more compact form:**
  ```bash
  git show --oneline <commit>
  ```

Show Commit with Patch

- **Show the commit with a patch (default behavior):**
  ```bash
  git show <commit>
  ```

  This includes the full diff of the changes introduced by the commit.

**Advanced Options**

Show Changes for a Specific File

- **Show changes for a specific file in a commit:**
  ```bash
  git show <commit>:<path/to/file>
  ```

  Replace `<path/to/file>` with the path to the file you want to inspect.

Show Multiple Commits

- **Show multiple commits:**
  ```bash
  git show <commit1> <commit2> ...
  ```

  You can list multiple commits to display their details sequentially.

**Example Scenario**

Assume you want to inspect a specific commit to understand the changes it introduced. Here’s a step-by-step example:

1. **Identify the commit hash:**
   ```bash
   git log --oneline
   ```

   This command lists the commits in a compact form. For example:
   ```
   593181a (HEAD -> main) convert js to ts
   f27de89 convert all js/x to ts/x
   7b20ec5 (origin/main) track if passing of req is late or not
   ```

2. **Show the details of a specific commit:**
   ```bash
   git show 593181a
   ```

   The output includes:
   - Commit hash, author, date, and commit message.
   - A detailed diff of the changes introduced by the commit.

**Summary of Useful `git show` Options**

- **Basic usage:** `git show <commit>`
- **Show commit without diff:** `git show --no-patch <commit>`
- **Show commit with summary:** `git show --stat <commit>`
- **Show commit in a compact form:** `git show --oneline <commit>`
- **Show specific file changes in a commit:** `git show <commit>:<path/to/file>`
- **Show multiple commits:** `git show <commit1> <commit2> ...`

### `git revert`

The `git revert` command is used to create a new commit that undoes the changes introduced by a previous commit. Unlike `git reset`, which can alter the commit history, `git revert` is a safe operation for collaborative workflows because it preserves the history by adding a new commit.

**Basic Usage**

Revert a Single Commit

- **Revert a specific commit:**
  ```bash
  git revert <commit>
  ```

  Replace `<commit>` with the commit hash (SHA-1) or a reference to the commit you want to revert.

Example

Suppose you want to revert a commit with the hash `593181a`:

1. **Identify the commit to revert:**
   ```bash
   git log --oneline
   ```

   This command lists the commits in a compact form. For example:
   ```
   593181a (HEAD -> main) convert js to ts
   f27de89 convert all js/x to ts/x
   7b20ec5 (origin/main) track if passing of req is late or not
   ```

2. **Revert the specific commit:**
   ```bash
   git revert 593181a
   ```

   This command will create a new commit that undoes the changes made by the commit `593181a`. Git will open the default text editor to allow you to modify the commit message for the revert commit if needed.

Reverting Multiple Commits

- **Revert multiple commits in a single operation:**
  ```bash
  git revert <commit1> <commit2> ...
  ```

  You can list multiple commit hashes to revert them sequentially.

Interactive Revert

- **Interactive revert to handle conflicts:**
  ```bash
  git revert -n <commit>
  ```

  The `-n` or `--no-commit` option allows you to stage the changes introduced by the revert without committing them. This is useful if you need to resolve conflicts or make additional modifications before committing.

Reverting a Range of Commits

- **Revert a range of commits:**
  ```bash
  git revert <oldest-commit>..<newest-commit>
  ```

  This reverts all the commits in the specified range. Note that the range syntax uses two dots `..`.

Undoing a Revert

If you realize that the revert itself was a mistake, you can undo it by reverting the revert commit:

1. **Identify the revert commit:**
   ```bash
   git log --oneline
   ```

   Find the commit that corresponds to the revert operation.

2. **Revert the revert commit:**
   ```bash
   git revert <revert-commit>
   ```

   This command will create a new commit that undoes the changes introduced by the revert commit.

**Example Scenario**

Assume you have the following commit history:

```
593181a (HEAD -> main) convert js to ts
f27de89 convert all js/x to ts/x
7b20ec5 (origin/main) track if passing of req is late or not
```

You want to revert the commit `593181a`:

1. **Revert the commit:**
   ```bash
   git revert 593181a
   ```

   The command opens the default text editor for the revert commit message. After saving and closing the editor, the new commit is created:
   ```
   Revert "convert js to ts"
   
   This reverts commit 593181a.
   ```

2. **Check the commit history:**
   ```bash
   git log --oneline
   ```

   The history now shows the revert commit:
   ```
   1a2b3c4 (HEAD -> main) Revert "convert js to ts"
   593181a convert js to ts
   f27de89 convert all js/x to ts/x
   7b20ec5 (origin/main) track if passing of req is late or not
   ```

**Summary of Useful `git revert` Options**

- **Basic usage:** `git revert <commit>`
- **Revert multiple commits:** `git revert <commit1> <commit2> ...`
- **Interactive revert (no automatic commit):** `git revert -n <commit>`
- **Revert a range of commits:** `git revert <oldest-commit>..<newest-commit>`

### `git branch`

The `git branch` command is a versatile tool in Git for managing branches within a repository. Branches allow you to develop features, fix bugs, or experiment in isolated environments. Here's a detailed guide on how to use the `git branch` command and related operations:

**Basic Usage**

List Branches

- **List all branches:**
  ```bash
  git branch
  ```

  This command lists all local branches and highlights the current branch with an asterisk (`*`).

- **List remote branches:**
  ```bash
  git branch -r
  ```

  This lists all remote branches.

- **List all branches (local and remote):**
  ```bash
  git branch -a
  ```

  This lists all branches, both local and remote.

Create a New Branch

- **Create a new branch:**
  ```bash
  git branch <branch-name>
  ```

  Replace `<branch-name>` with the desired name for your new branch.

Switch to a Different Branch

- **Switch to an existing branch:**
  ```bash
  git checkout <branch-name>
  ```

  Replace `<branch-name>` with the name of the branch you want to switch to.

- **Create and switch to a new branch in one command:**
  ```bash
  git checkout -b <branch-name>
  ```

  This creates the new branch and switches to it immediately.

Rename a Branch

- **Rename the current branch:**
  ```bash
  git branch -m <new-branch-name>
  ```

  - **Rename a specific branch:**
  ```bash
  git branch -m <old-branch-name> <new-branch-name>
  ```

Delete a Branch

- **Delete a local branch:**
  ```bash
  git branch -d <branch-name>
  ```

  The `-d` option deletes the branch only if it has been fully merged with its upstream branch. Replace `<branch-name>` with the name of the branch you want to delete.

- **Force delete a local branch:**
  ```bash
  git branch -D <branch-name>
  ```

  The `-D` option force deletes the branch regardless of its merge status.

- **Delete a remote branch:**
  ```bash
  git push origin --delete <branch-name>
  ```

  This deletes the specified branch from the remote repository.

**Working with Remote Branches**

Track a Remote Branch

- **Create a local branch tracking a remote branch:**
  ```bash
  git checkout -b <branch-name> origin/<branch-name>
  ```

  This command creates a local branch that tracks the remote branch with the same name.

**Example Workflow**

1. **Create a new branch for a feature:**
   ```bash
   git checkout -b feature-branch
   ```

2. **Work on the feature and commit changes:**
   ```bash
   git add .
   git commit -m "Add new feature"
   ```

3. **Push the new branch to the remote repository:**
   ```bash
   git push -u origin feature-branch
   ```

4. **Switch back to the main branch:**
   ```bash
   git checkout main
   ```

5. **Merge the feature branch into the main branch:**
   ```bash
   git merge feature-branch
   ```

6. **Delete the feature branch locally and remotely:**
   ```bash
   git branch -d feature-branch
   git push origin --delete feature-branch
   ```

**Summary of Useful `git branch` Commands**

- **List branches:** `git branch`, `git branch -r`, `git branch -a`
- **Create a new branch:** `git branch <branch-name>`
- **Switch branches:** `git checkout <branch-name>`, `git checkout -b <branch-name>`
- **Rename a branch:** `git branch -m <new-branch-name>`, `git branch -m <old-branch-name> <new-branch-name>`
- **Delete a branch:** `git branch -d <branch-name>`, `git branch -D <branch-name>`, `git push origin --delete <branch-name>`
- **Track a remote branch:** `git checkout -b <branch-name> origin/<branch-name>`

### `git merge`

The `git merge` command in Git is used to integrate changes from one branch into another. Merging is a fundamental operation in Git and is commonly used to combine the work done in separate branches, such as feature branches, back into the main branch (e.g., `main` or `master`). Here's how you can use `git merge` effectively:

**Basic Usage**

Merge a Branch into the Current Branch

- **Merge a branch into the current branch:**
  ```bash
  git merge <branch-name>
  ```

  Replace `<branch-name>` with the name of the branch you want to merge into the current branch.

Fast-forward Merge

- **Perform a fast-forward merge:**
  ```bash
  git merge --ff-only <branch-name>
  ```

  This command only performs the merge if it can be done as a fast-forward, meaning the current branch's commit is directly ahead of the branch being merged.

**Resolving Merge Conflicts**

Automatic Merge

- **Perform an automatic merge:**
  ```bash
  git merge <branch-name>
  ```

  Git will attempt to automatically merge the changes. If there are no conflicts, the merge will be successful.

Manual Merge

- **Perform a manual merge (if automatic merge fails):**
  1. Git will indicate the files with conflicts.
  2. Open each conflicted file in a text editor and manually resolve the conflicts.
  3. After resolving conflicts, stage the changes:
     ```bash
     git add <conflicted-file>
     ```
  4. Complete the merge:
     ```bash
     git merge --continue
     ```

**Example Workflow**

1. **Switch to the branch you want to merge changes into:**
   ```bash
   git checkout main
   ```

2. **Merge changes from another branch (e.g., feature-branch) into the current branch (main):**
   ```bash
   git merge feature-branch
   ```

   If there are no conflicts, Git will automatically merge the changes. If conflicts occur, you'll need to resolve them manually.

3. **Resolve any merge conflicts (if necessary):**
   - Git will indicate conflicted files.
   - Open each conflicted file in a text editor, resolve the conflicts, and save the changes.

4. **Stage the resolved files:**
   ```bash
   git add <resolved-file>
   ```

5. **Complete the merge:**
   ```bash
   git merge --continue
   ```

6. **Push the merged changes to the remote repository:**
   ```bash
   git push origin main
   ```

**Summary of Useful `git merge` Options**

- **Merge a branch into the current branch:** `git merge <branch-name>`
- **Perform a fast-forward merge:** `git merge --ff-only <branch-name>`

## Usage Scenarios

### Branching

Steps:

1. **Cloning the Repository**
2. **Creating a Branch**
3. **Making Changes**
4. **Pushing the Branch to Remote**
5. **Creating a Pull Request (PR)**
6. **Reviewing and Merging a Pull Request**
7. **Handling Merge Conflicts**
8. **Cleaning Up**

1. **Cloning the Repository**

First, clone the repository to your local machine:

```bash
git clone <repository-url>
cd <repository-directory>
```

Replace `<repository-url>` with the URL of your repository.

2. **Creating a Branch**

It's a good practice to create a new branch for each feature or bug fix. This keeps the main branch clean and stable.

```bash
git checkout -b <feature-branch-name>
```

Replace `<feature-branch-name>` with a descriptive name for your branch, such as `feature/new-login` or `bugfix/fix-crash`.

 3. **Making Changes**

Now, make your changes to the code. You can add, edit, or delete files as needed. After making changes, stage and commit them:

```bash
git add .
git commit -m "Add a description of your changes"
```

4. **Pushing the Branch to Remote**

Push your branch to the remote repository so others can see your changes:

```bash
git push origin <feature-branch-name>
```

5. **Creating a Pull Request (PR)**

Go to your repository on GitHub (or your Git hosting service). You should see a prompt to create a Pull Request for your recently pushed branch. Click on that and fill out the PR form, explaining what changes you made and why.

6. **Reviewing and Merging a Pull Request**

Your teammates can now review your PR. They can leave comments, request changes, or approve it. Once the PR is approved, it can be merged into the main branch.

**Merging the PR:**

If you're authorized to merge PRs, you can do it from the GitHub interface by clicking the "Merge pull request" button.

Alternatively, you can merge it locally:

```bash
git checkout main
git pull origin main
git merge <feature-branch-name>
```

After merging, push the updated main branch back to the remote repository:

```bash
git push origin main
```

7. **Handling Merge Conflicts**

Sometimes, merging a branch will result in conflicts. Git will tell you which files are in conflict. Open those files, look for conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`), and resolve the conflicts manually. After resolving, stage the changes and commit:

```bash
git add <conflicted-file>
git commit -m "Resolve merge conflict in <conflicted-file>"
```

Then, continue with the merge.

8. **Cleaning Up**

After your feature branch has been merged, you can delete it both locally and remotely to keep your repository clean:

```bash
git branch -d <feature-branch-name>
git push origin --delete <feature-branch-name>
```

**Recap**

1. Clone the repository.
2. Create a new branch.
3. Make changes, stage, and commit them.
4. Push the branch to the remote repository.
5. Create a Pull Request.
6. Review and merge the Pull Request.
7. Handle any merge conflicts.
8. Clean up the branch.

#### Switching Branch

To switch to a different branch in Git, you can use the `git checkout` command. Starting from Git version 2.23, you can also use the `git switch` command. Here are examples for both:

**Using `git checkout`:**

```bash
git checkout <branch-name>
```

Replace `<branch-name>` with the name of the branch you want to switch to.

**Using `git switch`:**

```bash
git switch <branch-name>
```

Again, replace `<branch-name>` with the name of the branch you want to switch to.

**Create a New Branch and Switch to It:**

If the branch you want to switch to does not exist yet, you can create a new branch and switch to it in one command:

```bash
git checkout -b <new-branch-name>
```

or with `git switch`:

```bash
git switch -c <new-branch-name>
```

Replace `<new-branch-name>` with the name you want to give to the new branch.

**Note:**

- If you have uncommitted changes in your working directory, Git might prevent you from switching branches. You can either commit those changes, stash them, or discard them depending on your needs.

- If the branch you're switching to is a remote branch, you might need to fetch it first:

  ```bash
  git fetch origin <branch-name>
  ```

  Then, you can switch to it using the commands mentioned above.

Remember to replace placeholders like `<branch-name>` with actual branch names.

#### Update Branch With The Latest Changes

If you have pushed your changes from your branch to the main branch, and the main branch now contains your changes along with changes made by others, and you want to synchronize your non-main branch with the updated code, you can follow these steps:

1. **Fetch the Latest Changes:**
   First, ensure your local repository is up to date with the latest changes from the main branch:

   ```bash
   git fetch origin
   ```

2. **Switch to Your Non-Main Branch:**
   Switch to your non-main branch (the one you want to update with the latest changes from main):

   ```bash
   git checkout <your-non-main-branch>
   ```

3. **Merge or Rebase with Main:**
   You have two options to update your non-main branch with the latest changes from the main branch: merging or rebasing.

   - **Merge:**
     Merge the main branch into your non-main branch:

     ```bash
     git merge main
     ```

   - **Rebase:**
     Rebase your non-main branch onto the main branch:

     ```bash
     git rebase main
     ```

   If there are conflicts during the merge or rebase, resolve them as you would with any other conflicts.

4. **Push the Updated Non-Main Branch:**
   Once you have resolved any conflicts and updated your non-main branch with the latest changes, push the changes to the remote repository:

   ```bash
   git push origin <your-non-main-branch>
   ```

Now, your non-main branch should be synchronized with the latest changes from the main branch, along with any changes you made on that branch. Remember that rebasing changes the commit history, so only use it if you haven't pushed your branch changes to a shared repository or if you are sure about the consequences of rewriting history.

### Commits

#### Change Commit Message

To change a commit message in Git, you can use the `git commit --amend` command. Here's how you can do it:

1. Open your terminal or command prompt.

2. Navigate to your local Git repository directory.

3. Identify the commit whose message you want to change using the `git log` command. Take note of the commit hash.

4. Run the following command to change the commit message:

   ```
   git commit --amend
   ```

   This will open your default text editor with the current commit message. Edit the message to what you want it to be.

5. Save the changes and close the text editor.

6. If you want to change the message without modifying the commit content, simply save the commit message without any changes.

7. If you have already pushed the commit to a remote repository, you might need to force push the amended commit using:

   ```
   git push --force origin <branch-name>
   ```

   Be cautious with force pushing, as it can rewrite the history and potentially cause issues if others are working on the same repository.

Please note that changing commit messages is safe if the commits are not yet pushed or if you're certain that no one else has based their work on these commits. If other collaborators have already seen these commits, consider discussing with your team before making any changes to commit messages.``

#### Delete a Commit

To delete a commit from your Git history, you can use the `git rebase` command. Here are the steps to delete a commit:

1. Open your terminal or command prompt and navigate to the local repository directory.

2. Check the commit history of your repository using the following command:
   
   ```
   git log --oneline
   ```

   This will display the commit history of your repository.

3. Identify the commit that you want to delete and note down its hash value (the long string of numbers and letters next to the commit message).

4. Run the following command to start an interactive rebase:

   ```
   git rebase -i HEAD~n
   ```

   Replace `n` with the number of commits you want to include in the interactive rebase. For example, if you want to include the last 5 commits in the interactive rebase, use `HEAD~5`.

5. This will open an interactive rebase file in your default text editor. In this file, you will see a list of the commits included in the rebase. Find the commit you want to delete and remove its line from the file.

6. Save and close the interactive rebase file. This will apply the changes and delete the selected commit from your Git history.

7. If you have already pushed the commit to a remote repository, you may need to force push the updated history using the following command:

   ```
   git push --force origin <branch-name>
   ```

   Replace `<branch-name>` with the name of the branch that you want to update on the remote repository.

Note that deleting a commit can have consequences for your Git history and potentially break other developers' work, so use this command with caution.

#### Going Back to a Commit

To go back to a previous commit in Git, you can use the `git checkout` command followed by the commit hash or branch name you want to checkout. Here are the steps to do it:

1. First, use the `git log` command to find the commit hash of the commit you want to go back to. This command will show you a list of all the commits in your Git repository, with the most recent commit listed first. Look for the commit hash that corresponds to the one you want to go back to.
    
2. Once you have identified the commit hash, use the `git checkout` command followed by the commit hash or branch name to switch to that commit. For example, if the commit hash is "abc123", you can run the following command:
    
    Copy code
    
    `git checkout abc123`
    
    This will switch your repository to the state it was in at the time of that commit.
    

Note that if you make changes to the files in your repository after checking out a previous commit, those changes will not be preserved when you switch back to the most recent commit. If you want to keep those changes, you should create a new branch before checking out the previous commit.

#### Extract a File From A Previous Commit

You can use the `git checkout` command or the `git restore` command to extract the files from the compressed copies and restore them to their original form. Here's an example command to restore a file from a specific commit:

```
git checkout <commit_hash> <file_path>
```

Replace `<commit_hash>` with the hash of the commit you want to restore the file from, and `<file_path>` with the path to the file you want to restore. Note that this will overwrite the current version of the file in your project, so make sure to back up any changes you have made to the file before running this command.

#### Squashing

In Git, "squash" refers to combining multiple commits into a single commit. Squashing commits is a way to condense the commit history and make it more concise and organized.

When you squash commits, Git takes the changes from the selected commits and applies them on top of the previous commit. The commit messages are typically combined into a single commit message. This process allows you to represent a series of small, incremental changes as a single cohesive commit.

Squashing commits is useful in several scenarios:

1. Cleaning up a branch before merging: By squashing multiple commits into a single commit, you can create a cleaner commit history and make it easier to review and understand changes before merging the branch.

2. Creating a meaningful commit history: Squashing commits allows you to craft a more coherent narrative for the changes introduced. Instead of a series of small, individual commits, you can provide a single commit with a clear message that describes the overall purpose of the changes.

3. Addressing feedback: If you receive feedback on specific commits and need to make adjustments, squashing allows you to incorporate those changes into a single commit, maintaining a clean and focused history.

It's important to note that squashing commits can rewrite the commit history, so it should be used with caution, especially if the branch has been shared with others. It is generally recommended to squash commits on a feature branch before merging it into the main branch, rather than squashing commits on a shared branch.

**Steps**:

To squash commits in Git, you can use the interactive rebase feature. Follow these steps:

1. Open the terminal and navigate to your Git repository.
2. Ensure you are on the branch where you want to squash the commits.
3. Run the following command to initiate the interactive rebase:

   ```
   git rebase -i HEAD~N
   ```

   Replace `N` with the number of commits you want to squash. For example, if you want to squash the last three commits, use `HEAD~3`.

4. An interactive editor will open, presenting a list of commits. Each commit line will start with the word "pick".
5. Change the word "pick" to "squash" or "s" (or even "fixup") for the commits you want to squash into the previous commit. Leave the first "pick" unchanged as it represents the base commit.
6. Save and exit the editor.

Git will then squash the selected commits into the base commit. Another editor will open, allowing you to modify the commit message. By default, it will include the messages from all the squashed commits. You can modify the message as desired, save, and exit the editor.

After completing these steps, the specified commits will be squashed into a single commit, effectively combining their changes. It's important to note that squashing commits rewrites history, so it should be used with caution, especially if the branch has been shared with others.

### Indexing

#### Untrack a Folder or a File

If you want to untrack a folder or file in Git without deleting it, you can use the following steps:

1. **Update `.gitignore`:**
   Add the folder or file entry to your `.gitignore` file. This prevents Git from tracking changes in that file or folder moving forward.

   If it's a file, for example, `file.txt`, add this line to your `.gitignore`:

   ```plaintext
   file.txt
   ```

   If it's a folder, for example, `folder/`, add this line:

   ```plaintext
   folder/
   ```

   Commit your changes:

   ```bash
   git add .gitignore
   git commit -m "Add file/folder to .gitignore"
   ```

2. **Remove from Tracking:**
   If the file or folder is already being tracked, you need to remove it from the Git index:

   ```bash
   git rm --cached file.txt
   ```

   or for a folder:

   ```bash
   git rm -r --cached folder/
   ```

   This will untrack the file or folder but keep it in your working directory.

3. **Commit the Changes:**
   Commit the removal of the file or folder from tracking:

   ```bash
   git commit -m "Stop tracking file/folder"
   ```

   Now, Git will no longer track changes to that file or folder.

4. **Push Changes (if necessary):**
   If you're working in a shared repository, push the changes to the remote repository:

   ```bash
   git push origin <your-branch>
   ```

After these steps, the file or folder will no longer be tracked by Git, and its changes won't be included in future commits. The file or folder will remain in your working directory. If you want to completely remove it from the repository, you would need to remove it locally and commit that change. Keep in mind that this might affect collaborators if they already have the file or folder in their local repositories.

### Staging

#### Unstage Files

1. To unstage all files that have been staged for a commit in Git, you can use the `git reset` command with the `HEAD` argument. 

   ```
   git reset HEAD
   ```

   This will unstage all the files that have been added to the staging area, so that they are no longer marked for the next commit.

2. Use `git reset <file>` to unstage a specific file: If you only want to unstage a specific file, you can use the `git reset` command followed by the path to the file. For example, if you want to unstage `file.txt`, you can run the command:

   ```
   git reset file.txt
   ```

   This will remove the file from the staging area, so that it is no longer marked for the next commit.

3. Use `git restore --staged <file>` to unstage a specific file: The `git restore` command can also be used to unstage a specific file. Use the `--staged` option to specify that you want to unstage the file. For example, to unstage `file.txt`, run the command:

   ```
   git restore --staged file.txt
   ```

   This will remove the file from the staging area, so that it is no longer marked for the next commit.

4. Use `git rm --cached <file>` to unstage a file and remove it from the index: If you want to unstage a file and also remove it from the index (i.e., stop tracking the file in Git), you can use the `git rm` command with the `--cached` option. For example, to unstage and remove `file.txt`, run the command:

   ```
   git rm --cached file.txt
   ```

   This will unstage the file and remove it from the index, but it will not delete the file from your working directory.

Note that all of these methods only remove the file(s) from the staging area, and do not modify the contents of the files in your working directory. If you have made changes to the files that you no longer want to keep, you will need to use the `git checkout` command to discard those changes.

### Diffing
#### Diff Current State to a Previous Commit

To see the difference between the current state of your Git repository and a previous commit, you can use the `git diff` command. Here are the steps to do it:

1. Use the `git log` command to find the commit hash of the previous commit you want to compare to the current state. Look for the commit hash that corresponds to the one you want to compare to.

2. Once you have identified the previous commit hash, run the following command to see the difference between the current state of your repository and the previous commit:

   ```
   git diff <previous_commit_hash>
   ```

   For example, if the previous commit hash is "abc123", you can run the following command:

   ```
   git diff abc123
   ```

   This will show you the difference between the current state of your repository and the state it was in at the time of the previous commit.

You can also use the `git diff HEAD~1` command to see the difference between the current state of your repository and the commit immediately preceding the current one. This is a shorthand for referring to the previous commit.

#### Compare Two Files From Different commits

To compare two files from different commits in Git, you can use the `git diff` command with the commit hashes and the file paths. Here's how you can do it:

1. Find the commit hashes for the two commits you want to compare. You can use the `git log` command to get a list of all the commits in your repository, and copy the commit hash for each of the two commits.

2. Run the `git diff` command with the commit hashes and the file paths you want to compare. For example, if you want to compare the file `file.txt` between two commits with the hashes `abc123` and `def456`, run the following command:

   ```
   git diff abc123 def456 file.txt
   ```

   This will show the differences between the two versions of the file.

   You can also compare the contents of two different files across two commits by specifying their paths:

   ```
   git diff abc123 def456 file1.txt file2.txt
   ```

   This will show the differences between the two versions of both `file1.txt` and `file2.txt`.

Note that the `git diff` command shows the differences between the two versions of the file line by line. The lines with `+` signs indicate additions, and lines with `-` signs indicate deletions.


### Repo

#### Upload Local Repo to GitHub

To upload your local Git repository to GitHub, you need to follow these steps:

1. Create a new repository on GitHub: 
   - Log in to your GitHub account and go to the "Repositories" tab. 
   - Click the "New" button to create a new repository. 
   - Enter a name for your repository and choose whether it should be public or private. 
   - Click the "Create repository" button.

2. Set the remote URL of your local Git repository:
   - Open your terminal or command prompt and navigate to your local Git repository directory.
   - Run the following command to set the remote URL of your local repository to the URL of the repository you just created on GitHub:
     ```
     git remote add origin <GitHub repository URL>
     ```
     Replace `<GitHub repository URL>` with the URL of the repository you created on GitHub.

3. Push your local repository to GitHub:
   - Run the following command to push the contents of your local repository to the remote repository on GitHub:
     ```
     git push -u origin main
     ```
     This will push the contents of the local `main` branch to the `main` branch of the remote repository on GitHub. If you have a different main branch name, replace `main` with the name of your main branch.

After you have completed these steps, your local Git repository should be uploaded to GitHub and you should be able to view its contents on the GitHub website.

#### Remove Remote Repository

To remove a remote repository that you previously added with `git remote add`, you can use the `git remote rm` command followed by the name of the remote. Here are the steps to do it:

1. First, confirm the name of the remote repository you want to remove. You can use the `git remote -v` command to list all the remote repositories that you have added to your local repository:

   ```
   git remote -v
   ```

   This will list all the remote repositories that are currently configured for your local repository, along with their URLs.

2. Once you have confirmed the name of the remote repository you want to remove, use the `git remote rm` command followed by the name of the remote:

   ```
   git remote rm <remote-name>
   ```

   Replace `<remote-name>` with the name of the remote repository you want to remove. For example, if the remote repository is named `origin`, you can run:

   ```
   git remote rm origin
   ```

3. After running the command, Git will remove the remote repository from your local repository, and you will no longer be able to push or pull changes from that repository.

Note that removing a remote repository does not delete any branches or commits that were pushed to that repository. It only removes the reference to that repository from your local repository.

#### Get the Remote URL of Repo

To get the URL of the remote named "origin" in a Git repository, you can use the following command:

```
git remote get-url origin
```

This command will display the URL associated with the remote named "origin." It is useful when you want to quickly check the URL of the remote repository to which you push and pull code.

#### Change Remote URL of Repo

To change the remote URL of a Git repository, you can use the `git remote set-url` command. Here's the basic syntax:

```
git remote set-url <remote-name> <new-url>
```

Here's an example:

Suppose you want to change the remote URL of the `origin` remote to a new URL, you would use the following command:

```
git remote set-url origin <new-url>
```

Replace `<remote-name>` with the name of the remote you want to modify (e.g., `origin`), and `<new-url>` with the new URL you want to set for the remote.

After running this command, the remote URL will be updated, and you can verify the changes using the `git remote -v` command to see the updated remote URL.

#### Enable SSH Connection

To enable SSH connections to GitHub, you can follow these steps:

1. Generate an SSH key pair on your local machine (if you haven't already). You can do this using the `ssh-keygen` command in your terminal. For example, to generate an RSA key pair with default settings, you can run:

   ```
   ssh-keygen -t rsa -b 4096
   ```

or

```
   ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

   Follow the prompts to specify a filename for your key pair and an optional passphrase.

2. Add your public SSH key to your GitHub account. Log in to your GitHub account, go to your account settings, and select "SSH and GPG keys". Click the "New SSH key" button and paste your public key into the "Key" field. Give the key a descriptive title and click "Add SSH key".

3. Test your SSH connection to GitHub. In your terminal, run:

   ```
   ssh -T git@github.com
   ```

   This should attempt to connect to GitHub over SSH and display a message confirming that you have successfully authenticated with GitHub.

4. Update your remote repository URLs to use the SSH protocol. If you have already added a remote repository using the HTTPS protocol, you can update the URL to use SSH instead. For example, to update the URL for a remote repository named "origin", you can run:

   ```
   git remote set-url origin git@github.com:username/repo.git
   ```

   Replace "username/repo" with the appropriate GitHub username and repository name.

Now you should be able to use SSH to connect to and authenticate with GitHub. Note that some Git clients and hosting services may require additional configuration to work with SSH keys.

#### Transfer SSH Key to Another Machine

To transfer an SSH key to a different machine, you should copy the private and public key files to the new machine. 

By default, the private key file is stored in the `.ssh` directory in your home directory, and it is named either `id_rsa` or `id_dsa`. The public key file is stored in the same directory with the same name, but with the `.pub` file extension.

Here are the steps to transfer your SSH key to a new machine:

1. Copy the private key file to the new machine. You can use `scp` or any other file transfer method to copy the private key file to the new machine. For example, if your private key file is named `id_rsa` and is located in the `.ssh` directory in your home directory, you can run:

   ```
   scp ~/.ssh/id_rsa username@new-machine:~/.ssh/
   ```

   Replace `username` with your username on the new machine, and `new-machine` with the hostname or IP address of the new machine.

2. Copy the public key file to the new machine. Similarly, copy the public key file to the new machine using the same method. For example:

   ```
   scp ~/.ssh/id_rsa.pub username@new-machine:~/.ssh/
   ```

3. Add the private key to your SSH agent on the new machine. On the new machine, add the private key to your SSH agent using the `ssh-add` command. For example:

   ```
   ssh-add ~/.ssh/id_rsa
   ```

4. Test the SSH connection using the new key. Finally, test the SSH connection to your remote servers using the new key by connecting to a remote server using SSH. For example:

   ```
   ssh username@remote-server
   ```

   If everything is set up correctly, you should be able to log in to the remote server without entering a password.

Note that copying your private key to another machine exposes it to potential security risks. Be sure to protect your private key file and never share it with others.

### `.gitignore`

#### Ignore All Except...

If you want to ignore all files and subdirectories within a directory in your Git repository except for certain files or directories, you can use the following syntax in your `.gitignore` file:

```gitignore
/path/to/directory/*
!/path/to/directory/allowed-file.txt
!/path/to/directory/allowed-folder/
```

Here's an explanation of each line:

1. `/path/to/directory/*`: This line tells Git to ignore all files and subdirectories within the specified directory.

2. `!/path/to/directory/allowed-file.txt`: This line negates the previous rule and allows Git to track the specific file `allowed-file.txt` within the directory.

3. `!/path/to/directory/allowed-folder/`: This line negates the previous rule and allows Git to track the specific directory `allowed-folder` and its contents.

Make sure to replace `/path/to/directory/` with the actual path of the directory in your repository.

This way, you are instructing Git to ignore everything within the directory except for the files or folders explicitly allowed. This can be useful when you want to exclude most things in a directory but include specific exceptions.

## Enums

### Commit Labels

In software development, commit labels, often referred to as "commit message prefixes" or "commit message conventions," are used to provide a structured and consistent way of categorizing and describing the purpose of a commit. These labels help quickly identify the type of change introduced by the commit. Some common commit labels or prefixes are:

1. **feat**: Indicates the addition of a new feature to the codebase.
   
   Example: `feat: Add user registration functionality`

2. **fix**: Denotes a bug fix or a correction of an issue.
   
   Example: `fix: Fix validation error in login form`

3. **chore**: Refers to maintenance or upkeep tasks that do not directly impact the end-user functionality.
   
   Example: `chore: Update dependencies`

4. **docs**: Describes changes made to documentation, comments, or other non-code documentation.

   Example: `docs: Update README with installation instructions`

5. **style**: Covers code style changes such as formatting, whitespace, and code structure improvements.

   Example: `style: Format code according to style guide`

6. **refactor**: Represents code changes that neither fix a bug nor add a feature, but rather improve the existing codebase.
   
   Example: `refactor: Reorganize file structure for better modularity`

7. **test**: Signifies changes made to tests, including adding new tests or modifying existing ones.

   Example: `test: Add unit tests for user authentication`

8. **perf**: Highlights performance-related changes or optimizations.
   
   Example: `perf: Optimize database query for faster response`

9. **revert**: Indicates that the commit is reverting a previous commit.
   
   Example: `revert: Revert "Fix issue with payment processing"`

10. **build**: Represents changes related to build processes, build tools, or configuration files.

    Example: `build: Update webpack configuration`

11. **ci**: Denotes changes to Continuous Integration (CI) configurations and scripts.
    
    Example: `ci: Configure automated deployment to staging`

12. **temp**: Signifies temporary changes that need to be made but will be reverted later.
    
    Example: `temp: Temporarily disable payment gateway`

13. **security**: Highlights changes made to address security vulnerabilities.
    
    Example: `security: Update library to fix security issue`

14. **wip** (Work in Progress): Indicates that the commit is still a work in progress and not yet ready for release.

    Example: `wip: Add new API endpoint for user profiles`

15. **dep**: Represents changes related to dependencies, such as updates or additions of external libraries.

    Example: `dep: Update axios to version 1.5.0`

16. **lint**: Denotes changes made to linters or code quality tools.

    Example: `lint: Fix linting issues in project files`

17. **cleanup**: Highlights clean-up activities, such as removing unused code or files.

    Example: `cleanup: Remove obsolete function`

18. **merge**: Used to signify merge commits resulting from integrating feature or bug branches.

    Example: `merge: Merge feature/registration into main`

19. **release**: Indicates commits related to preparing for a release or version bump.

    Example: `release: Prepare for v2.0 release`

20. **version**: Represents versioning-related changes, often combined with a version number.

    Example: `version: Bump to v1.2.3`

21. **hotfix**: Used for urgent fixes that need to be deployed quickly.

    Example: `hotfix: Fix critical security vulnerability`

22. **design**: Represents changes related to design or user interface updates.

    Example: `design: Update color scheme for login page`

23. **analytics**: Denotes changes related to tracking or analytics implementations.

    Example: `analytics: Integrate Google Analytics for user tracking`

24. **database**: Highlights changes to the database schema or queries.

    Example: `database: Add new column to user table`

25. **feature-flag**: Used for commits related to feature flag implementations.

    Example: `feature-flag: Implement feature X behind feature flag`

26. **migration**: Indicates changes related to database migrations.

    Example: `migration: Create migration for user profile changes`

27. **maintenance**: Represents general maintenance tasks not covered by other labels.

    Example: `maintenance: Update copyright year in footer`

28. **internationalization**: Denotes changes related to internationalization or localization.

    Example: `internationalization: Add translations for French language`

