## Basic Git Workflow


### Creating Your First Repository

Git is a distributed version control system that allows you to track changes in your codebase. To start using Git on a new project, you'll need to initialize a repository.

```bash
git init
```

This command creates a hidden `.git` directory in your project folder, which contains all the necessary metadata for the repository. Once executed, you've created your first Git repository.

**Key Points:**

- `git init` transforms your regular directory into a Git repository
- The `.git` directory contains the entire history and configuration
- You only need to run this command once per project
- Use `git init --bare` for repositories that won't contain working files (like central repositories)

### Understanding the Three Git Areas

Git manages your files using three main areas:

1. **Working Directory**: The files in your project folder that you're actively editing
2. **Staging Area** (or Index): A preparation area where you select which changes should be included in your next commit
3. **Repository**: The database where Git permanently stores your project's history as commits

This three-stage architecture gives Git its power and flexibility, allowing you to carefully craft commits rather than automatically tracking all changes.

**Example:**

```
                    git add              git commit
Working Directory -----------> Staging Area -----------> Repository
    (Unstaged)                 (Staged)                (Committed)
```

### Making Your First Commit

After modifying files in your working directory, you need to tell Git which changes to include in your commit.

1. First, add modified files to the staging area:

```bash
git add filename.txt          # Add a specific file
git add directory/            # Add a directory
git add .                     # Add all changes
```

2. Then, commit the staged changes to the repository:

```bash
git commit -m "Your commit message here"
```

**Key Points:**

- The `-m` flag allows you to specify a commit message inline
- Without `-m`, Git will open your default text editor for a more detailed message
- Use `git commit -a -m "message"` to add and commit all tracked files in one command
- Commit messages should be clear and descriptive about the changes

### The Anatomy of a Commit

A Git commit is a snapshot of your project at a specific point in time. Each commit contains:

- A unique identifier (SHA-1 hash)
- The author's name and email
- The date and time of the commit
- A commit message
- A pointer to the parent commit(s)
- A snapshot of all tracked files

**Example:**

```
commit 3a7f2e9b6a47d62c7f996e3f2a9616d3cc4c4a4a
Author: Jane Doe <jane@example.com>
Date:   Wed May 8 14:32:41 2025 -0700

    Add user authentication feature
    
    - Created login form
    - Implemented password hashing
    - Added session management
```

Each commit builds on previous commits, forming a chain that represents your project's history.

### Viewing History with git log

To view the commit history of your repository, use:

```bash
git log
```

This displays all commits in reverse chronological order (newest first).

For a more compact view:

```bash
git log --oneline
```

For a graphical representation of branches:

```bash
git log --graph --oneline --all
```

**Output:**

```
* 3a7f2e9 (HEAD -> main) Add user authentication feature
* 5d9e8f1 Update README with project description
* 7c2b4d6 Initial commit
```

**Key Points:**

- `git log` shows the commit history
- Press `q` to exit the log view
- Many formatting options are available (--oneline, --graph, --decorate)
- Filter logs with options like `--author`, `--since`, `--until`, `--grep`

### Checking Repository Status

To see the current state of your working directory and staging area:

```bash
git status
```

This shows:

- Which branch you're on
- Files that have been modified but not staged
- Files that are staged but not committed
- Untracked files

**Example:**

```
On branch main
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        modified:   login.php

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   styles.css

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        new-feature.js
```

### Handling Mistakes

Git provides several ways to correct mistakes:

To unstage a file:

```bash
git restore --staged filename.txt
```

To discard changes in the working directory:

```bash
git restore filename.txt
```

To modify the most recent commit:

```bash
git commit --amend
```

**Key Points:**

- Be careful with commands that discard changes, as they cannot be recovered
- `--amend` creates a new commit that replaces the previous one
- Avoid amending commits that have been pushed to shared repositories

### Ignoring Files

Create a `.gitignore` file in your repository to specify files and directories that Git should ignore:

```
# Example .gitignore file
node_modules/
*.log
.env
.DS_Store
```

**Key Points:**

- Ignored files won't appear as untracked in `git status`
- Useful for build artifacts, dependencies, and sensitive information
- Pattern matching follows glob syntax
- `.gitignore` itself should be committed

### Basic Branching

Branches allow parallel development paths:

```bash
git branch              # List branches
git branch new-feature  # Create a branch
git checkout new-feature # Switch to a branch
git checkout -b new-feature # Create and switch in one command
```

In newer Git versions, you can use:

```bash
git switch new-feature  # Switch to a branch
git switch -c new-feature # Create and switch in one command
```

**Key Points:**

- The default branch is typically called `main` or `master`
- The `HEAD` pointer indicates your current branch
- Branches are lightweight and easy to create

### Working with Remote Repositories

To connect to a remote repository:

```bash
git remote add origin https://github.com/username/repository.git
```

To push your changes to the remote:

```bash
git push -u origin main
```

To get changes from the remote:

```bash
git pull origin main
```

**Key Points:**

- "origin" is a conventional name for your primary remote repository
- The `-u` flag sets up tracking, allowing future `git push` and `git pull` commands without specifying the remote and branch
- Always pull before pushing when collaborating

**Conclusion:** Understanding these Git basics provides a solid foundation for version control in your projects. As you grow more comfortable with these commands, you'll develop a workflow that enhances your productivity and collaboration capabilities. Git's power comes from mastering not just the commands but understanding the underlying concepts of its distributed nature and commit history structure.

---

