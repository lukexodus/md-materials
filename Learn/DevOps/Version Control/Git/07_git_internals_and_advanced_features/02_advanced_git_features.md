## Advanced Git Features


### Submodules

Submodules allow you to keep a Git repository as a subdirectory of another Git repository, enabling you to include external projects within your project while keeping their histories separate.

#### Adding submodules

```bash
git submodule add https://github.com/example/library.git path/to/submodule
```

This creates:

- A `.gitmodules` file tracking submodule paths and URLs
- A subdirectory containing the cloned repository
- A Git reference to the specific commit of the submodule

#### Cloning repositories with submodules

```bash
# Clone and initialize submodules in one step
git clone --recurse-submodules https://github.com/example/project.git

# Or after a regular clone:
git submodule init
git submodule update
```

#### Updating submodules

```bash
# Update all submodules to their latest commits
git submodule update --remote

# Update a specific submodule
git submodule update --remote path/to/submodule
```

#### Working with submodules

```bash
# View submodule status
git submodule status

# Execute a command in each submodule
git submodule foreach 'git checkout main'
```

**Key Points**:

- Submodules point to specific commits, not branches
- Changes in submodules require separate commits
- Submodules can be nested (submodules within submodules)
- They're useful for shared components, libraries, and frameworks
- They create a clear separation between your code and dependencies

### Git hooks

Hooks are scripts that Git executes before or after events like commit, push, and receive. They allow you to customize Git's behavior and implement automated workflows.

#### Common hook types

- **Pre-commit**: Runs before a commit is created
- **Prepare-commit-msg**: Runs before the commit message editor is launched
- **Commit-msg**: Validates commit messages
- **Post-commit**: Runs after a commit is created
- **Pre-push**: Runs before a push is executed
- **Post-receive**: Runs on the remote after a push is received

#### Creating a hook

1. Navigate to `.git/hooks` directory in your repository
2. Create a file named after the hook (e.g., `pre-commit`)
3. Make it executable (`chmod +x pre-commit`)
4. Write your script (can be bash, Python, Ruby, etc.)

**Example**: A pre-commit hook to prevent commits with "WIP" in the message

```bash
#!/bin/bash
# .git/hooks/pre-commit

commit_msg=$(git show -s --format=%B HEAD)
if [[ $commit_msg == *"WIP"* ]]; then
  echo "Error: WIP commits are not allowed"
  exit 1
fi
exit 0
```

#### Sharing hooks with a team

Git doesn't track the hooks directory, but you can:

1. Store hooks in a separate directory in your repo
2. Use symbolic links or a setup script
3. Use tools like Husky or pre-commit framework

```bash
# Example setup script
#!/bin/bash
ln -sf ../../hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

**Key Points**:

- Hooks must be executable
- Failed hooks (non-zero exit code) can block Git operations
- Hooks are local and not pushed with your code
- They can run tests, enforce standards, or trigger CI/CD processes
- Server-side hooks can enforce repository policies

### Git attributes

Git attributes allow you to specify how Git handles specific files or file patterns, controlling features like line ending conversion, diff generation, and merge strategies.

#### Setting up attributes

Create a `.gitattributes` file in your repository:

```
# .gitattributes
*.txt text           # Treat as text files
*.png binary         # Treat as binary files
*.jpg binary

# Use specific diff driver
*.md diff=markdown

# Custom merge driver
database.xml merge=ours
```

#### Common attributes

- **text**: Controls line ending normalization
- **eol**: Specifies line ending style (lf, crlf)
- **binary**: Treats file as binary (no line ending conversion)
- **diff**: Specifies custom diff algorithm
- **merge**: Controls merge strategy
- **export-ignore**: Excludes from archives
- **filter**: Applies a filter when checking in/out

#### Custom diff formats

```
# .gitattributes
*.png diff=exif

# In .git/config:
[diff "exif"]
  textconv = exiftool
```

Now `git diff` on PNG files will show metadata differences instead of binary content.

**Example**: Better Word document diffs

```
# .gitattributes
*.docx diff=word

# In .git/config:
[diff "word"]
  textconv = docx2txt
```

**Key Points**:

- Attributes help maintain consistency across platforms
- They can improve workflow for non-text files
- Repository-specific attributes override global ones
- They're useful for handling platform-specific files
- Custom diff drivers can provide meaningful diffs for binary formats

### Git LFS (Large File Storage)

Git LFS is an extension that replaces large files with text pointers while storing the file contents on a remote server, improving repository performance with large assets.

#### Installing Git LFS

```bash
# Install Git LFS
git lfs install
```

#### Tracking files with LFS

```bash
# Track specific file types
git lfs track "*.psd"
git lfs track "*.zip"

# This creates/updates a .gitattributes file
git add .gitattributes
```

#### Working with LFS

```bash
# Regular Git commands work as usual
git add large-file.psd
git commit -m "Add design file"
git push
```

Behind the scenes:

1. Git LFS replaces the file with a text pointer
2. Original file is stored in LFS cache
3. On push, file is sent to LFS server
4. On pull/clone, pointers are downloaded first, then LFS files

#### Managing LFS objects

```bash
# View tracked patterns
git lfs track

# List LFS files in repo
git lfs ls-files

# Fetch all LFS objects
git lfs fetch

# Prune local LFS cache
git lfs prune
```

**Key Points**:

- Improves performance for repositories with large files
- Reduces clone time by downloading LFS objects on demand
- Requires server support (GitHub, GitLab, Bitbucket, or self-hosted)
- Has bandwidth and storage considerations
- May have associated costs depending on hosting provider

### Git worktrees

Worktrees allow you to have multiple working directories from a single repository, each with different branches checked out simultaneously.

#### Creating worktrees

```bash
# Add a new worktree with a specific branch
git worktree add ../path-to-worktree branch-name

# Create a new branch for the worktree
git worktree add -b new-feature ../path-to-new-feature main
```

#### Listing worktrees

```bash
git worktree list
```

#### Removing worktrees

```bash
git worktree remove path-to-worktree

# Force removal if worktree has modifications
git worktree remove --force path-to-worktree
```

#### Pruning worktrees

Remove references to deleted worktrees:

```bash
git worktree prune
```

**Example workflow**:

```bash
# Working on main
cd ~/project

# Create worktree for hotfix
git worktree add ~/project-hotfix hotfix

# Create worktree for feature
git worktree add -b new-feature ~/project-feature

# Now you can work on different branches simultaneously
# without constant switching
```

**Key Points**:

- Each worktree has its own working directory and HEAD
- All worktrees share the same repository (objects and refs)
- Useful for working on multiple branches simultaneously
- Great for hotfixes while maintaining development context
- Helps avoid frequent context switching

### Advanced Git rewriting

#### Filter-branch

Powerful tool to rewrite history by applying filters:

```bash
# Remove a file from entire history
git filter-branch --tree-filter 'rm -f passwords.txt' HEAD

# Change email in all commits
git filter-branch --env-filter '
    if [ "$GIT_AUTHOR_EMAIL" = "old@example.com" ]
    then
        export GIT_AUTHOR_EMAIL="new@example.com"
        export GIT_COMMITTER_EMAIL="new@example.com"
    fi
' HEAD
```

#### Git filter-repo

A faster, more powerful alternative to filter-branch:

```bash
# Install
pip install git-filter-repo

# Remove sensitive files
git filter-repo --path passwords.txt --invert-paths
```

**Key Points**:

- These tools completely rewrite history
- Should not be used on shared branches without team coordination
- Useful for removing sensitive information or large files
- Creates new commit objects with new hashes
- Requires force-pushing to remote repositories

### Git bisect

Powerful debugging tool that uses binary search to find the commit that introduced a bug:

```bash
# Start bisect process
git bisect start

# Mark current commit as bad
git bisect bad

# Mark a known good commit
git bisect good v1.0

# Git checks out a commit halfway between good and bad
# Test your code at this point

# Mark the current commit
git bisect good  # or git bisect bad

# Continue until Git identifies the first bad commit
# When done:
git bisect reset
```

You can also automate the process:

```bash
git bisect start HEAD v1.0
git bisect run ./test-script.sh
```

**Key Points**:

- Dramatically speeds up finding regression issues
- Works best with reproducible bugs
- Can be automated with test scripts
- Helps identify exactly when functionality broke
- Requires a known good and bad commit

### Git internals

#### Objects and references

Git's data model consists of four object types:

- **Blob**: File contents
- **Tree**: Directory listings
- **Commit**: Snapshots with metadata
- **Tag**: Named references

```bash
# See raw objects
git cat-file -p <hash>

# List references
git show-ref
```

#### Reflogs

Git keeps a record of how references change in the reflog:

```bash
# View HEAD reflog
git reflog

# View branch reflog
git reflog show main
```

Useful for recovering lost commits:

```bash
# Restore a branch to a previous state
git reset --hard main@{2}

# Recover orphaned commits
git checkout -b recovery-branch <commit-hash>
```

**Key Points**:

- Advanced Git features provide powerful capabilities for complex workflows
- Each feature addresses specific needs in software development
- Understanding these features can significantly improve productivity
- They're particularly valuable for larger teams and projects
- Mastering them elevates your Git expertise beyond the basics

---

