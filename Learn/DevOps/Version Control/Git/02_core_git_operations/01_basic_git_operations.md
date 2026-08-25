## Basic Git Operations


### Checking Status with `git status`

The `git status` command is one of the most frequently used Git commands, providing a snapshot of your working directory's current state. It shows which files are tracked, modified, staged, or untracked.

**Key Points**

- Shows the state of files in three main areas: working directory, staging area, and repository
- Indicates which branch you're currently on
- Shows if your branch is ahead or behind the remote tracking branch
- Provides suggestions for common next actions
- Can be customized with various flags for different output formats

**Standard Output Components**

1. Current branch name
2. Relationship to remote tracking branch (ahead/behind/up-to-date)
3. Changes staged for commit (green)
4. Changes not staged for commit (red)
5. Untracked files (red)
6. Helpful suggestions for common Git commands

**Example**

```bash
$ git status
On branch feature/user-authentication
Your branch is ahead of 'origin/feature/user-authentication' by 2 commits.
  (use "git push" to publish your local commits)

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        modified:   src/auth/login.js
        new file:   src/auth/two-factor.js

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   src/styles/forms.css
        modified:   README.md

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        src/auth/recovery.js
        docs/authentication.md
```

**Output** In this example, we can see:

- We're on the `feature/user-authentication` branch
- We have 2 local commits not yet pushed to the remote
- Two files are staged for commit (one modified, one new)
- Two files are modified but not yet staged
- Two files are completely new and untracked

**Useful Flags**

```bash
# Short status format (compact view)
git status -s
# or
git status --short

# Branch information only
git status -b
# or
git status --branch

# Verbose mode (shows more details)
git status -v
# or
git status --verbose

# Show ignored files
git status --ignored

# Combine flags for customized output
git status -sb  # Short format with branch info
```

**Short Status Format**

```bash
$ git status -s
 M README.md
MM auth.js
A  CONTRIBUTING.md
?? utils/helper.js
```

The short format uses a two-column output where:

- Left column: staging area status
- Right column: working directory status
- Codes: M (modified), MM (modified, staged, modified again), A (added), C (copied), D (deleted), R (renamed), U (unmerged), ? (untracked), ! (ignored)

### Examining Changes with `git diff`

The `git diff` command allows you to see exactly what has changed in your files at a line-by-line level. It's essential for reviewing your changes before committing them.

**Key Points**

- Shows line-by-line changes between different states of files
- Can compare working directory to staging area, staging area to repository, or between commits
- Uses the unified diff format showing context around changed lines
- Displays additions in green (prefixed with +) and removals in red (prefixed with -)
- Supports various options for customizing the output format and comparison scope

**Basic Usage**

```bash
# Compare working directory with staging area (unstaged changes)
git diff

# Compare staging area with repository (staged changes)
git diff --staged
# or
git diff --cached

# Compare specific file
git diff path/to/file.js

# Compare with specific commit
git diff abc123

# Compare between two commits
git diff abc123 def456

# Compare with a specific branch
git diff feature-branch
```

**Example**

```bash
$ git diff README.md
diff --git a/README.md b/README.md
index 9a7d3c4..8b12492 100644
--- a/README.md
+++ b/README.md
@@ -10,7 +10,8 @@ This project is a web application for managing personal finances.
 
 ## Features
 
-* Expense tracking
+* Expense tracking with categories
+* Budget planning
 * Income management
 * Reports and analytics
 * Data export
```

**Output** This diff shows:

- The line "Expense tracking" was removed
- Two new lines were added: "Expense tracking with categories" and "Budget planning"
- The header shows file paths, commit hashes, and metadata

**Advanced Diff Options**

```bash
# Word-level diff instead of line-level
git diff --word-diff

# Show only the names of changed files
git diff --name-only

# Show statistics about changes
git diff --stat

# Show differences for all staged changes
git diff --staged

# Ignore whitespace changes
git diff -w
# or
git diff --ignore-all-space

# Show changes from specific commit to working directory
git diff abc123

# Compare changes between branches
git diff main feature-branch

# Show diff with context (default is 3 lines)
git diff -U5  # Show 5 lines of context

# Show difference in a specific function
git diff -L "function_name:file.js"
```

**Word Diff Example**

```bash
$ git diff --word-diff README.md
diff --git a/README.md b/README.md
index 9a7d3c4..8b12492 100644
--- a/README.md
+++ b/README.md
@@ -10,7 +10,8 @@ This project is a web application for managing personal finances.

## Features

* Expense tracking [-with-] {+with categories+}
{+* Budget planning+}
* Income management
* Reports and analytics
* Data export
```

**Stat Example**

```bash
$ git diff --stat
 README.md        | 3 ++-
 src/app.js       | 25 ++++++++++++++++++++-----
 src/components/  | 15 ++++++++++-----
 3 files changed, 32 insertions(+), 11 deletions(-)
```

### Using `.gitignore` Files Effectively

The `.gitignore` file specifies intentionally untracked files that Git should ignore. This is essential for preventing temporary files, build artifacts, and sensitive information from being committed to your repository.

**Key Points**

- `.gitignore` files can exist at different levels of your repository
- Patterns use glob syntax for flexible matching
- Later patterns override earlier ones
- Negated patterns (with !) can re-include previously excluded files
- `.gitignore` files are committed to the repository to share ignore rules with collaborators
- You can maintain a global ignore file for personal preferences across all repositories

**Basic Syntax Rules**

- Blank lines or lines starting with `#` are comments
- Standard glob patterns work:
    - `*` matches zero or more characters
    - `?` matches a single character
    - `[abc]` matches any character inside the brackets
    - `**` matches nested directories (e.g., `logs/**/*.log` matches all `.log` files in the `logs` directory and its subdirectories)
- A leading slash `/` matches files only in the repository root
- A trailing slash `/` indicates a directory
- Negating a pattern with `!` re-includes a previously excluded file

**Example `.gitignore` File**

```
# Dependency directories
node_modules/
vendor/

# Build outputs
dist/
build/
*.min.js

# Environment and configuration
.env
.env.local
config.local.js

# Log files
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Editor directories and files
.idea/
.vscode/
*.swp
*.swo

# Operating system files
.DS_Store
Thumbs.db

# Include special file that would otherwise be ignored
!important-library.min.js
```

**Strategies for Effective `.gitignore` Management**

1. **Use specific patterns instead of overly general ones**:
    
    ```
    # Bad: Might ignore important files
    *.json
    
    # Good: More specific
    coverage/*.json
    package-lock.json
    ```
    
2. **Use multiple `.gitignore` files for complex projects**:
    
    - Root `.gitignore` for project-wide patterns
    - Directory-specific `.gitignore` files for more granular control
3. **Combine project and personal ignores properly**:
    
    - Project-specific ignores in repository `.gitignore`
    - Personal ignores (like editor configurations) in global ignore file
4. **Create a global ignore file for personal preferences**:
    
    ```bash
    git config --global core.excludesfile ~/.gitignore_global
    ```
    
5. **Check if files are already being tracked**:
    
    - Adding files to `.gitignore` won't affect already-tracked files
    - If a file is already tracked, remove it from the repository with:
        
        ```bash
        git rm --cached filename
        ```
        

**Common Ignore Patterns by Project Type**

**Node.js**

```
node_modules/
npm-debug.log
yarn-error.log
.env
.env.local
.env.development.local
.env.test.local
.env.production.local
coverage/
```

**Python**

```
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
*.egg-info/
.installed.cfg
*.egg
.pytest_cache/
.coverage
htmlcov/
```

**Java**

```
*.class
*.log
*.ctxt
.mtj.tmp/
*.jar
*.war
*.nar
*.ear
*.zip
*.tar.gz
*.rar
hs_err_pid*
target/
.gradle/
build/
out/
```

**Testing Ignore Patterns**

To verify which files will be ignored:

```bash
# Check if a file would be ignored
git check-ignore -v filename.txt

# List all ignored files
git status --ignored
```

### Git Aliases for Efficiency

Git aliases allow you to create shortcuts for frequently used Git commands, improving your workflow efficiency and reducing typing errors.

**Key Points**

- Aliases are stored in Git configuration
- Can be defined at global or repository-specific level
- Can be simple command substitutions or complex shell commands
- Significantly reduce typing for common operations
- Make complex Git commands more accessible

**Setting Up Basic Aliases**

```bash
# Set aliases via command line
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status

# Or edit ~/.gitconfig directly
# [alias]
#     co = checkout
#     br = branch
#     ci = commit
#     st = status
```

**Example Usage**

```bash
# Instead of:
git checkout feature-branch

# You can use:
git co feature-branch
```

**Powerful Aliases for Common Operations**

```bash
# Last commit
git config --global alias.last 'log -1 HEAD'

# Unstage a file
git config --global alias.unstage 'reset HEAD --'

# View commit history as a graph
git config --global alias.lg 'log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'

# Show all branches with details
git config --global alias.branches 'branch -a -v'

# Show conflicts
git config --global alias.conflicts 'diff --name-only --diff-filter=U'

# Undo last commit but keep changes
git config --global alias.undo 'reset HEAD~1 --soft'

# Quick commit all changes with message
git config --global alias.cim '!git add -A && git commit -m'

# List all aliases
git config --global alias.aliases '!git config --get-regexp "^alias\." | sed "s/^alias\.//" | sort'
```

**Advanced Aliases with Shell Commands**

By prefixing an alias with `!`, you can execute shell commands:

```bash
# Summarize commits by author
git config --global alias.who '!git shortlog -s --'

# Clean up local branches that have been merged
git config --global alias.cleanup '!git branch --merged | grep -v "^*" | grep -v "main" | grep -v "dev" | xargs git branch -d'

# Create and switch to a new branch
git config --global alias.nb '!f() { git checkout -b "$1"; }; f'

# Find text in commit history
git config --global alias.find '!f() { git log --pretty=format:"%C(yellow)%h  %Cblue%ad  %Creset%s%Cgreen  [%cn] %Cred%d" --decorate --date=short -S"$1"; }; f'

# Interactive rebase with the given number of latest commits
git config --global alias.reb '!f() { git rebase -i HEAD~$1; }; f'
```

**Usage Examples**

```bash
# View pretty commit history graph
git lg

# Create and switch to feature branch
git nb feature/user-auth

# Find commits containing "bugfix"
git find bugfix

# Interactive rebase of last 3 commits
git reb 3

# Add all changes and commit with message
git cim "Fix navigation bug in header"
```

**Organizing Aliases by Function**

You can organize your aliases in your `.gitconfig` file for better clarity:

```
[alias]
    # Basic shortcuts
    co = checkout
    br = branch
    ci = commit
    st = status
    
    # Log/history viewing
    lg = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
    last = log -1 HEAD
    changelog = log --pretty=format:'%s' --reverse
    
    # Working with branches
    branches = branch -a -v
    recent-branches = for-each-ref --sort=-committerdate --count=10 --format='%(refname:short)' refs/heads/
    
    # File operations
    unstage = reset HEAD --
    discard = checkout --
    
    # Fixing mistakes
    amend = commit --amend
    undo = reset HEAD~1 --soft
    
    # Utility
    aliases = !git config --get-regexp '^alias\\.' | sed 's/^alias\\.//' | sort
    contributors = shortlog -sn
    tags = tag -l
```

**Best Practices for Git Aliases**

1. **Start with basics**: Begin with aliases for the most common commands
2. **Add progressively**: Add new aliases as you identify repetitive patterns
3. **Document your aliases**: Add comments in your `.gitconfig` file
4. **Backup your aliases**: Store your `.gitconfig` in version control
5. **Share useful aliases**: Exchange helpful aliases with team members
6. **Create safe aliases**: Be careful with destructive commands; consider adding confirmation checks
7. **Use consistent naming**: Develop a personal convention for alias names

**Example Safety Mechanism for Destructive Alias**

```bash
# Force push with lease (safer than plain force push)
git config --global alias.fpush 'push --force-with-lease'

# Clean with confirmation
git config --global alias.cleanall '!f() { read -p "Are you sure you want to clean all untracked files? (y/n) " -n 1 -r; echo; if [[ $REPLY =~ ^[Yy]$ ]]; then git clean -fd; else echo "Operation cancelled"; fi }; f'
```

### Related Topics

- Git commit best practices and workflows
- Stashing changes for later use
- Git hooks for automation
- Advanced Git configuration options
- Git GUI clients and IDE integrations

---

