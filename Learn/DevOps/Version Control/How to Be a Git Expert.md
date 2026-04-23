# How to Be a Git Expert

https://youtu.be/hZS96dwKvt0?si=Zw3AIPgcCx4uzGEl

This document is based on the talk "How to Be a Git Expert" by Maxwell Anselm. It is organized thematically and expanded for clarity. It assumes basic familiarity with git — if you have never used git before, work through introductory tutorials first.

---

## Part 1: Core Concepts and Mental Models

The vast majority of confusion people have with git comes not from lack of memorizing commands, but from lacking a solid mental model of how git works internally. Building that model is the primary goal of this section.

---

### Commits

A commit is the fundamental unit of git. At its core, a commit tracks:

- **File paths** — where each file lives in the directory tree
- **File permissions** — the read/write/execute bits on each file
- **File contents** — the actual data inside each file

#### What a Commit Does NOT Track

- **Directories.** Git does not store directories as objects. A directory only implicitly exists because a file has a path that passes through it. If a directory is empty, git does not care that it exists. Conversely, if a file lives inside a directory and you commit it, git knows the directory must exist. Git will create or remove directories automatically as needed. You never need to think about directories when working with git — think only about files and their contents.
    
- **Renames.** The concept of renaming a file does not exist in git's data model. If you move a file from `src/foo.py` to `lib/foo.py`, git sees this as: "in the old state, a file existed at `src/foo.py`; in the new state, a file exists at `lib/foo.py`." The contents may be identical or nearly identical, but git treats this as a deletion and a creation. Understanding this helps explain why renames can sometimes produce surprising diffs.
    

#### Commit Identifiers (Checksums)

Every commit is identified by a checksum (a hash such as `ab301f7c…`). This checksum is derived from the contents of the commit itself — the files, the metadata, and the parent commit. Because of this:

- The checksum is effectively immutable. If anything about the commit changes, the checksum changes.
- Checksums are how git uniquely identifies every point in history.

#### HEAD

At all times, a git repository maintains a special pointer called `HEAD`. HEAD is "you are here" — it tells git what the current state of the working tree is supposed to represent. HEAD points at a specific commit (or, more commonly, at a branch name that in turn points at a commit).

When you make a new commit, HEAD updates to point at the new commit automatically.

#### Two Valid Ways to Think About a Commit

This is an important source of confusion that is worth internalizing:

1. **A commit as a snapshot.** You can think of a commit as representing the complete state of all files in the repository at that point in time — the full accumulated result of every change ever made up to that commit.
    
2. **A commit as a diff.** You can also think of a commit as just the _difference_ between itself and its parent — only the changes introduced in that single step.
    

Both interpretations are equally valid. Git sometimes treats commits one way and sometimes the other, depending on the operation being performed. When you understand which mode git is using for a given command, a lot of seemingly mysterious behavior becomes clear.

---

### Branching

#### Automatic Branching

Git has what some people call automatic branching. If you check out an older commit and then create a new commit from there, git automatically creates a fork in the history — no explicit "create a branch" command is required. This is a natural consequence of how commits point to parents: the new commit has the old commit as its parent, creating a diverging line of history.

#### What a Branch Actually Is

A branch is simply a named, _moveable_ pointer to a commit. When HEAD is pointing at a branch (rather than directly at a commit), any new commit you make will automatically advance the branch pointer forward to the new commit. The branch "moves with you."

This is the entire definition of a branch. It is not a separate copy of the code. It is not a separate folder. It is a label that advances as you commit.

When you run `git branch`, you are seeing a list of these named pointers.

#### Tags

A tag is similar to a branch name — it is a human-readable name for a commit. The key difference is that tags are **immutable**. Once a tag is created, it does not move when new commits are made. Tags are used to permanently mark specific commits, such as release points (e.g., `release/1.0`).

---

### Merging

#### The Three-Way Merge

When you merge two branches, git must reconcile divergent histories. To do this, git identifies three components:

- **BASE** — the most recent common ancestor commit between the two branches (the point where they diverged)
- **LOCAL** — the commits reachable only from the branch you are currently on
- **REMOTE** — the commits reachable only from the branch being merged in

Git uses these three reference points to perform what is called a **three-way merge**. The key insight is that git is not just comparing the two branch tips — it also has context about _where they came from_, which allows it to automatically resolve many conflicts that a naive two-way comparison could not. When git reports a merge conflict, it means the change is genuinely ambiguous and requires human judgment. These conflicts are usually non-trivial and should be taken seriously.

The result of a merge is a **merge commit** — a special commit that has two parents instead of one. The branch pointer advances to this new merge commit.

#### Fast-Forward Merge

A fast-forward merge is a special, simpler case. It occurs when one branch is a direct linear ancestor of the other — meaning no real divergence has occurred. In this case, git does not need to create a merge commit. It simply moves the branch pointer forward to the tip of the other branch.

Fast-forward merges are desirable when possible because they produce no new commits and cannot produce conflicts.

#### Keeping a Feature Branch Up to Date

A practical and common use of merging is keeping a long-lived feature branch synchronized with the main development branch. While you work on your feature, other contributors are pushing commits to `develop`. You can regularly merge `origin/develop` directly into your feature branch without needing to switch branches. This keeps your feature close to the current state of the codebase and prevents a large, painful conflict at the time of final integration.

---

### Fetch and Pull

#### Fetch

`git fetch` downloads commits from a remote repository and stores them locally, but it does **not** update your local branches. Instead, fetched branches are stored under a prefixed namespace like `origin/develop`, `origin/main`, etc. This separation keeps remote changes isolated from your local work until you are ready to integrate them.

When you check out a branch after fetching, your local branch gets an **upstream pointer** that tracks which remote branch it corresponds to. Git uses this pointer to tell you if your local branch is ahead or behind the remote.

#### Pull

`git pull` is simply **fetch + merge** in one command. It fetches the remote changes and then merges the remote version of your current branch into your local branch (often as a fast-forward).

Many experienced git users prefer to run `git fetch` and `git merge` separately. This allows you to inspect what changed remotely before merging it into your local work — providing a cleaner workflow and more control over what happens to your history.

---

### Push

Pushing sends your local commits to a remote repository. Before pushing, git performs an implicit fetch to check the current state of the remote branch.

#### The Happy Case

If the remote commit is in your local commit history (i.e., you are simply ahead of the remote), git pushes your new commits and updates the remote branch. Everything is synchronized.

#### The Diverged Case (Push Failure)

If the remote has new commits that are **not** in your local history — for example, someone else pushed while you were working — your push will fail. Git cannot perform a push that would cause the remote to lose commits. The fix is to first merge the remote changes into your local branch (making the remote commit part of your history), and then push again.

---

### Diff and the Staging Area (Index)

Creating a commit is not a single atomic action — it is a multi-step process.

#### Working Tree

At any moment, git can compare the current state of the files on disk against the HEAD commit. The set of all files on disk as they currently exist is called the **working tree**. Running `git diff` shows the difference between the working tree and HEAD.

#### Staging Area (Index)

When you run `git add`, you are not committing anything. You are copying changes from the working tree into the **index** (also called the staging area or cache). The index is a soft, temporary holding area. Nothing in the index is permanent yet.

The purpose of the index is to let you carefully choose _which_ changes become part of your next commit, rather than forcing you to commit everything at once.

#### Committing

`git commit` takes everything in the index and creates a permanent, checksummed commit from it. The commit is now part of the git history.

#### Reset (Walking Backwards)

`git reset` allows you to walk backward through the commit-to-index-to-working-tree pipeline:

- **Soft reset** — moves the last commit back into the index (the staging area). The changes are still grouped together, ready to be re-committed differently.
- **Mixed reset (default)** — moves the last commit all the way back into the working tree. The changes are still there, but they are unstaged.
- **Hard reset** — **destructive**. Discards the changes entirely. The working tree and index are reset to match the target commit. Use with extreme caution.

---

### Stash

`git stash` allows you to temporarily set aside changes in your working tree without committing them. Think of it as putting your current work in a box so you can do something else (e.g., switch branches to fix a bug) and then unbox it later.

- You can have multiple stashes.
- Stashes can be applied to any branch, not just the branch where they were created — which means conflicts can occur when popping a stash onto a different branch.
- Stash is useful as a temporary holding area, but it is not a substitute for proper commits. Stashes can be lost if you are not careful.

---

### Submodules

Submodules allow you to embed one git repository inside another. They are conceptually simple despite having a reputation for confusion.

#### What a Submodule Is

A submodule is just a single tracked change in the outer repository that records:

1. The URL of the inner repository
2. The HEAD commit of the inner repository at the time it was recorded

That is all. The outer repository tracks _where_ the submodule's HEAD is pointing, and stores that as a diff item like any other file change.

#### The Critical Rule

**Git will never update a submodule automatically.** Every operation on a submodule — initialization, updating, switching its HEAD — must be done explicitly by you. This is intentional: if git updated submodules automatically, it could silently discard in-progress work inside them.

The most common source of submodule confusion ("why does my submodule show a diff I didn't make?") is usually failing to explicitly update the submodule after a fetch or branch switch. Always explicitly manage your submodules.

---

### Log and History Inspection

Git log shows the commit history, but its default behavior is often not the most useful view.

#### Default Log Behavior

By default, `git log` shows all commits reachable from HEAD, sorted chronologically. Commits that are not reachable from HEAD (e.g., on an unmerged branch) are not shown.

#### Graphical View

Running `git log --graph` adds ASCII art showing the branching structure of commits. This is far more informative for understanding how branches relate to each other. Only reachable commits are shown, but the graph makes the topology visible.

#### Filtering the Log

Git log supports complex filtering:

- **Inclusion/exclusion by commit name:** `git log A B ^C` shows commits reachable from A and B but not from C. This is useful for viewing only the commits on a specific branch, excluding shared history.
- **Ancestry path:** `--ancestry-path` restricts the log to commits that lie directly in the path between two commits, cutting out side branches.
- **By file path:** Adding a file path shows only commits that touched that file. The result can look patchy because only matching commits appear.
- **By date and author:** `--since`, `--until`, `--author` and similar options allow further filtering.

These filters can be combined to construct precise historical queries.

---

### Bisect

`git bisect` is one of git's most powerful and underused features. It performs a **binary search through commit history** to identify the exact commit that introduced a bug.

#### When to Use It

Bisect is most useful when you have an obvious bug — something is clearly broken — but you cannot easily trace its origin in the code.

#### The Process

1. **Identify a "bad" commit** — usually the current HEAD where the bug is present.
2. **Identify a "good" commit** — some point in the past where the bug did not exist. You may need to check out older commits and test manually to find this.
3. **Start bisecting:** `git bisect start`, then `git bisect bad [commit]` and `git bisect good [commit]`.
4. Git checks out a midpoint commit and asks you: is the bug here? You test and answer `git bisect good` or `git bisect bad`.
5. Git repeats this binary search. Even across months of history, the process typically narrows down to the culprit in about seven or eight steps.
6. Git announces the exact commit that introduced the bug.

This makes root-cause analysis dramatically faster in situations where normal debugging has stalled.

---

### Operations With Gotchas

The following operations are more dangerous than standard git operations because git's safety mechanisms are reduced or absent. Approach all of them with extra care.

#### Revert

`git revert` creates a new commit that is the **inverse** of a previous commit — it applies the opposite diff, effectively undoing a prior change without removing it from history.

**Why use it instead of reset?** Once you have pushed commits to a shared remote, you cannot use reset to undo them (since other people may already have those commits). Revert is the safe alternative because it adds a new commit rather than rewriting history. Everyone can pull the revert commit and the mistake is undone for all.

**The gotcha:** Git does not remember that a revert occurred. To git, the revert commit is just another commit — it has no special metadata marking the reverted commits as permanently invalid. If someone checks out one of the reverted commits later and merges it, the original bug can be reintroduced. You must remember which commits were reverted and treat them as permanently poisoned.

#### Cherry Pick

`git cherry-pick` takes a commit from one branch and applies its diff to another branch. A typical use case: you fixed a bug while working on a feature branch and want that fix on the main development branch without merging the whole feature.

**The gotcha:** Git does not understand the relationship between the original commit and the cherry-picked copy. They are two entirely separate commits with no recorded link. This can cause conflicts — especially if the source branch and destination branch have diverged significantly — and if both commits eventually end up in the same branch through a later merge, the history can become confusing.

Use cherry-pick sparingly and be prepared to resolve conflicts.

#### Rebase

`git rebase` takes a series of commits and replays them onto a different base commit. For example, if your feature branch started from an older commit on `develop`, rebase can lift your feature commits and replay them on top of the current tip of `develop`.

**What it does internally:**

1. Identifies the commits unique to your branch.
2. Detaches them.
3. Applies them one by one onto the new base, generating brand-new commits with new checksums.
4. Moves the branch pointer to the new tip.

**The main benefit:** After rebasing, merging your feature into `develop` is a clean fast-forward with no merge commit.

**The gotchas:**

- Every rebased commit is a new commit. It has a different checksum. If you have shared these commits with others, rebasing rewrites history they already have, causing significant problems.
- Conflicts can occur at each step of the replay, making rebase potentially tedious and error-prone.
- Rebase has many interactive options that add further complexity.

**The instructor's opinion:** Rebase is rarely necessary. You can have a successful professional git workflow without ever using it. If the only goal is a clean linear history, weigh that aesthetic preference against the operational risk and complexity.

---

## Part 2: Setup and Configuration

### Use the Command Line

Git is a command-line tool. Every GUI client (Sourcetree, GitHub Desktop, GitKraken, etc.) is a derivative product built on top of git. GUIs may omit features, rename concepts, or introduce their own bugs. Using the command line means:

- You use git itself, not an approximation of it.
- The skill is fully transferable across every team and environment.
- You can access every git feature with no limitations.

### Installing Git

- **Linux:** Git is typically pre-installed or available through the system package manager.
- **Windows:** Use the official installer from git-scm.com. It includes **Git Bash**, a terminal pre-configured for git use.
- **macOS:** Git may already be installed, but it is often outdated. Install a fresh version via Homebrew or another package manager.

### Essential Configuration

#### Name and Email

Git requires your identity to tag commits with an author. Set these globally:

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

#### Configure Your Terminal Prompt

Your terminal prompt should display git information automatically whenever you are inside a git repository. A well-configured prompt shows:

- Which branch you are on
- Whether there are uncommitted changes
- Whether your local branch is ahead or behind the remote

This alone saves enormous amounts of time. Many prompt frameworks (Starship, Oh My Zsh, Bash-it, Powerlevel10k, etc.) support git out of the box. Search for one that works with your shell and follow its setup instructions.

#### SSH Keys

Cloning repositories with HTTPS requires typing your username and password repeatedly. SSH keys eliminate this. Setup:

1. Generate a key pair:
    
    ```bash
    ssh-keygen
    ```
    
    Accept the defaults. Give it a meaningful name (e.g., `github_key`). **Do not set a passphrase** — your computer's login password already protects your machine.
    
2. Copy the contents of the `.pub` file (the public key).
    
3. Add the public key to your account settings on your git host (GitHub, GitLab, Bitbucket, etc.).
    
4. Add a block to your SSH config file (`~/.ssh/config`):
    
    ```
    Host github
      HostName github.com
      User git
      IdentityFile ~/.ssh/github_key
    ```
    
5. Now you can clone using the short nickname:
    
    ```bash
    git clone github:username/repo
    ```
    

#### Configure Your Editor

Git opens a text editor when you need to write a commit message or resolve certain conflicts. To set your preferred editor:

```bash
git config --global core.editor "code --wait"   # VS Code example
git config --global core.editor "subl -n -w"    # Sublime Text example
```

If you use home-row touch typing, `vim` is worth learning — it is git's default editor and is very efficient once you know it. Run `vimtutor` to learn the basics interactively.

#### Configure Your Merge Tool

When resolving a merge conflict, git should open **four windows** (or tabs/panes) simultaneously:

- **LOCAL** — the version on your branch
- **REMOTE** — the version from the other branch
- **BASE** — the common ancestor
- **RESULT** — where you edit to produce the final merged output

If your merge tool does not show all four, you are working without full context. Configure a proper four-way merge view in your editor of choice. In your git config, specify the editor command and arguments needed to open four files. Set `trustExitCode = false` if your editor does not return a meaningful exit code — git will then explicitly ask whether the conflict resolution was successful.

---

## Part 3: Command Line Usage

### Creating a Git Playground

Before experimenting with destructive operations, create a safe local environment:

```bash
git init playground
cd playground
git init --bare ../playground-remote
git remote add origin ../playground-remote
```

This gives you a local repository and a fake remote repository on your own machine. You can practice push, pull, merge, and all remote operations without risk.

### Command Structure

Every git command follows this pattern:

```
git <subcommand> [arguments]
```

The subcommands map directly to git concepts: `commit`, `fetch`, `pull`, `push`, `merge`, `diff`, `add`, `log`, `stash`, `rebase`, `cherry-pick`, etc.

The most important subcommand that most people overlook:

```bash
git help <subcommand>
```

This opens the full manual page for any subcommand, including all options and examples.

### Core Daily Workflow

The typical loop for getting work done:

1. **`git status`** — See an overview of what has changed: new files, deleted files, modified files.
2. **`git diff`** — See the line-by-line changes in each modified file.
3. **`git add`** — Stage the changes you want to include in the next commit.
4. **`git commit`** — Save staged changes as a permanent commit.

Useful options for this workflow:

- **`git diff --word-diff`** — Instead of showing entire changed lines, highlights the specific words or characters that changed. Much more readable for small edits.
- **`git add -p`** — Interactively steps through every change in your working tree, asking whether to stage each one. This is extremely useful for crafting clean, focused commits and for catching mistakes before they are committed.
- **`git commit -m "message"`** — Write the commit message directly on the command line without opening an editor.

### Identifying Commits on the Command Line

Many git commands require you to specify a particular commit. There are multiple ways to do this:

|Method|Example|Meaning|
|---|---|---|
|HEAD|`HEAD`|The current commit|
|Branch name|`develop`|The tip of a branch|
|Tag name|`release/1.0`|A tagged commit|
|Checksum|`ab301f7`|A specific commit by hash (can be abbreviated)|
|Relative (tilde)|`HEAD~3`|Three commits before HEAD|
|Parent (caret)|`HEAD^2`|The second parent of a merge commit|
|Combined|`HEAD^2~`|One commit before the second parent of HEAD|

The tilde (`~`) traverses backward through a linear chain. The caret (`^`) selects among multiple parents (relevant for merge commits). These can be chained in complex ways. You will encounter these notations when reading git documentation or answers online — they look cryptic but follow a consistent logic.

### Using Diff Beyond the Working Tree

`git diff` is not limited to comparing the working tree against HEAD. You can diff any two references:

```bash
git diff develop feature      # Compare two branches
git diff HEAD~5 HEAD          # Compare two arbitrary commits
git diff HEAD~3               # Compare a commit against HEAD (implicit)
```

You can also save a diff to a file, which produces a **patch file**:

```bash
git diff > my-changes.patch
```

A patch file is a portable description of how to transform one state of code into another. It can be applied to any compatible repository:

```bash
git apply my-changes.patch
```

This is useful for sharing experimental or temporary code — for example, test scaffolding or hacks that help reproduce a bug — without committing them to any branch.

### Aliases

If you find yourself typing long git commands repeatedly, aliases let you define shortcuts in your git config:

```ini
[alias]
    wdiff = diff --word-diff
    update-subs = submodule update --init --recursive
    sub-diff = diff --submodule=diff
    nuke = !git reset --hard HEAD && git clean -fd
```

Aliases replace a full subcommand invocation. They can also run arbitrary shell commands (prefix with `!`). You can pass positional arguments into shell-based aliases using shell scripting.

Example aliases worth considering:

- `wdiff` — `diff --word-diff` for more readable small changes
- `update-subs` — quickly update all submodules
- `sub-diff` — show the full diff inside a submodule rather than just recording the HEAD pointer change
- `nuke` — destructively discard all local changes and untracked files (use with caution)

---

## Summary: Key Principles

- **Mental model first.** Most git confusion dissolves when you understand how commits, HEAD, branches, and the index actually work. Every command is just an operation on these simple structures.
- **Commits are either snapshots or diffs** depending on context. Both views are valid; knowing which one applies removes confusion.
- **Branches are just moveable pointers.** They are not copies of the code.
- **Fetch before you merge.** Prefer `git fetch` + `git merge` over `git pull` when you want visibility into what changed remotely.
- **Use the index deliberately.** `git add -p` is one of the most valuable habits for writing clean commits.
- **Be careful with history-rewriting operations** (reset, rebase, cherry-pick, revert). They bypass git's normal safety checks.
- **Use the command line.** It is the full tool. GUIs are subsets of it.
- **Set up SSH keys, a git-aware prompt, and a proper four-window merge tool.** These are one-time investments that pay off continuously.
- **`git help <command>` is always available.** Use it.