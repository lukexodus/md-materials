# Git-Flow

## What Is Git-Flow?

Git-flow is a branching model for Git, originally proposed by Vincent Driessen in a 2010 blog post titled _"A successful Git branching model."_ It defines a strict set of rules about how branches are created, named, merged, and deleted over the lifecycle of a software project. It is not a built-in Git feature — it is a convention, optionally supported by a CLI extension called `git-flow`.

Git-flow is best suited for projects with scheduled, versioned releases. It may be heavier than necessary for teams doing continuous delivery or trunk-based development.

---

## Core Concepts

Git-flow divides work across two permanent branches and several types of temporary (supporting) branches.

### Permanent Branches

**`main` (or `master`)** Represents the official release history. Every commit on `main` is a tagged, production-ready release. No direct commits are made here; all changes arrive via merges.

**`develop`** The integration branch. This is where all completed features accumulate and where the next release is assembled. Direct commits are generally avoided here too; changes arrive from feature branches.

### Supporting Branch Types

These are temporary and deleted after their purpose is fulfilled.

**Feature branches** — for new work  
**Release branches** — for release preparation  
**Hotfix branches** — for urgent production fixes  
**Support branches** — for maintaining older release lines (less commonly used)

---

## Branch Naming Conventions

|Branch Type|Convention|Example|
|---|---|---|
|Feature|`feature/<name>`|`feature/user-auth`|
|Release|`release/<version>`|`release/1.4.0`|
|Hotfix|`hotfix/<version>`|`hotfix/1.4.1`|
|Support|`support/<version>`|`support/1.x`|

These are conventions, not Git-enforced rules. The `git-flow` CLI extension uses these prefixes automatically.

---

## The Branch Lifecycle in Detail

### Feature Branches

Feature branches are where individual pieces of work happen — new features, improvements, or non-urgent bug fixes.

**Branched from:** `develop`  
**Merged back into:** `develop`  
**Never merged into:** `main`

**Workflow:**

```bash
# Start a feature
git checkout develop
git checkout -b feature/my-feature

# Work, commit as needed
git add .
git commit -m "Add my feature"

# Merge back into develop when done
git checkout develop
git merge --no-ff feature/my-feature
git branch -d feature/my-feature
```

The `--no-ff` flag (no fast-forward) is important. It preserves a merge commit even when the history is linear, making it possible to see that a feature branch existed and when it was integrated. Driessen's original model explicitly calls for this.

---

### Release Branches

When `develop` has accumulated enough features for a release — or a release date is approaching — a release branch is cut. No new features are added here; only release-oriented changes are allowed.

**Allowed on a release branch:**

- Bug fixes discovered during QA
- Version number bumps
- Documentation updates
- Build configuration changes

**Branched from:** `develop`  
**Merged into:** both `main` and `develop`

**Workflow:**

```bash
# Start a release branch
git checkout develop
git checkout -b release/1.4.0

# Bump version, fix minor issues
# Commit those changes

# Merge into main and tag
git checkout main
git merge --no-ff release/1.4.0
git tag -a 1.4.0 -m "Release 1.4.0"

# Merge back into develop (to capture release-branch fixes)
git checkout develop
git merge --no-ff release/1.4.0

# Delete the release branch
git branch -d release/1.4.0
```

The merge back into `develop` is critical. Any fixes made on the release branch would otherwise be lost as `develop` moves forward.

---

### Hotfix Branches

Hotfix branches address critical bugs in production that cannot wait for the normal release cycle.

**Branched from:** `main` (specifically, from the tagged release that needs the fix)  
**Merged into:** both `main` and `develop` (or the current release branch if one exists)

**Workflow:**

```bash
# Start hotfix from the tagged production release
git checkout main
git checkout -b hotfix/1.4.1

# Fix the bug, update the version number
git add .
git commit -m "Fix critical login bug"

# Merge into main and tag
git checkout main
git merge --no-ff hotfix/1.4.1
git tag -a 1.4.1 -m "Hotfix 1.4.1"

# Merge into develop to keep the fix in future releases
git checkout develop
git merge --no-ff hotfix/1.4.1

# Delete the hotfix branch
git branch -d hotfix/1.4.1
```

If a release branch is currently open, merge the hotfix into that release branch instead of `develop` directly. The fix will reach `develop` when the release branch is eventually merged.

---

### Support Branches

Support branches are used to maintain older major versions when the team needs to backport fixes or maintain long-term support (LTS) lines in parallel with newer development.

**Branched from:** a specific tag on `main`  
**Not merged back** (generally treated as a long-lived parallel line)

Support branches are less common and their exact workflow varies by team. They are not part of Driessen's original 2010 model but are included in the `git-flow` CLI extension.

---

## Using the `git-flow` CLI Extension

The `git-flow` tool is an optional extension that automates the branching conventions. It wraps the manual git commands into shorter commands and handles the merging rules automatically.

### Installation

**macOS (Homebrew):**

```bash
brew install git-flow-avh
```

**Linux (Debian/Ubuntu):**

```bash
apt-get install git-flow
```

**Windows:** Included with Git for Windows, or installable via `choco install gitflow-avh`.

### Initialization

```bash
cd your-repo
git flow init
```

This prompts you to confirm branch names and prefixes. Accept the defaults unless your project uses different conventions.

### Feature Commands

```bash
git flow feature start my-feature       # Creates feature/my-feature from develop
git flow feature finish my-feature      # Merges into develop, deletes branch
git flow feature publish my-feature     # Pushes feature branch to remote
git flow feature pull origin my-feature # Pulls a remote feature branch
```

### Release Commands

```bash
git flow release start 1.4.0            # Creates release/1.4.0 from develop
git flow release finish 1.4.0           # Merges into main + develop, tags, deletes branch
git flow release publish 1.4.0          # Pushes release branch to remote
```

### Hotfix Commands

```bash
git flow hotfix start 1.4.1             # Creates hotfix/1.4.1 from main
git flow hotfix finish 1.4.1            # Merges into main + develop, tags, deletes branch
```

---

## Versioning and Tagging

Every merge into `main` should produce a tag. Semantic versioning (`MAJOR.MINOR.PATCH`) is the most common scheme used alongside git-flow:

- **MAJOR** — breaking changes
- **MINOR** — new backward-compatible features
- **PATCH** — backward-compatible bug fixes (hotfixes)

```bash
git tag -a 1.4.0 -m "Release 1.4.0"
git push origin --tags
```

Tags should be pushed to the remote explicitly. `git push` does not push tags by default.

---

## Working with Remote Repositories

Git-flow was designed for teams, so remote coordination matters.

### Publishing Branches

Feature and release branches that need collaboration should be pushed to the remote:

```bash
git push origin feature/my-feature
git push origin release/1.4.0
```

### Tracking a Remote Branch

```bash
git checkout -b feature/my-feature origin/feature/my-feature
```

Or with the CLI:

```bash
git flow feature track my-feature
```

### After Finishing Branches

Finished branches should be deleted both locally and remotely:

```bash
# Delete remote branch
git push origin --delete feature/my-feature

# Delete local branch
git branch -d feature/my-feature
```

The `git-flow` CLI deletes the local branch automatically on `finish`, but does not always delete the remote. Verify with your team's workflow.

---

## Merge Strategies

### Always Use `--no-ff`

Driessen's model relies on `--no-ff` merges to preserve branch topology. Without it, fast-forward merges flatten the history and make it impossible to distinguish feature work from direct commits on `develop`.

```bash
# Correct
git merge --no-ff feature/my-feature

# Avoid for git-flow merges
git merge feature/my-feature  # may fast-forward
```

### Rebasing

Rebasing feature branches onto `develop` before merging is a common practice to keep history linear. However, it conflicts with the `--no-ff` intent of git-flow. Whether to rebase is a team decision.

**If rebasing before merge:**

```bash
git checkout feature/my-feature
git rebase develop
git checkout develop
git merge --no-ff feature/my-feature
```

**Never rebase branches that have been pushed and shared with others.** Rewriting shared history causes conflicts for everyone pulling that branch.

---

## Handling Merge Conflicts

Merge conflicts occur when the same lines in a file have been changed in both branches being merged.

**Basic resolution workflow:**

```bash
# Attempt merge
git merge --no-ff feature/my-feature

# If conflicts occur, Git marks the files
# Open conflicted files and resolve manually

# Mark as resolved
git add resolved-file.txt

# Complete the merge
git commit
```

**Viewing conflicts:**

```bash
git status              # Shows which files have conflicts
git diff                # Shows the conflict markers in detail
```

**Conflict markers in a file:**

```
<<<<<<< HEAD
code from the current branch
=======
code from the branch being merged
>>>>>>> feature/my-feature
```

Remove the markers and keep the correct version (or a combination of both), then stage and commit.

---

## Common Workflows by Scenario

### Scenario: Starting a New Feature

```bash
git checkout develop
git pull origin develop
git flow feature start user-profile
# ... work and commit ...
git flow feature finish user-profile
git push origin develop
```

### Scenario: Preparing a Release

```bash
git checkout develop
git pull origin develop
git flow release start 2.0.0
# bump version in package.json, changelog, etc.
git commit -am "Prepare release 2.0.0"
git flow release finish 2.0.0
git push origin develop
git push origin main
git push origin --tags
```

### Scenario: Fixing a Production Bug

```bash
git checkout main
git pull origin main
git flow hotfix start 2.0.1
# fix the bug
git commit -am "Fix null pointer in payment module"
git flow hotfix finish 2.0.1
git push origin main
git push origin develop
git push origin --tags
```

---

## Comparison: Git-Flow vs. Other Models

### Trunk-Based Development

In trunk-based development, all developers commit to a single branch (usually `main`) directly or via very short-lived feature branches. There is no `develop` branch and no release branches in the traditional sense. This model is common in teams doing continuous delivery.

Git-flow is heavier than trunk-based development. Teams releasing multiple times a day are likely better served by trunk-based approaches.

### GitHub Flow

GitHub Flow uses a single long-lived branch (`main`) and feature branches that are merged via pull requests. There is no `develop` or `release` concept. It is simpler than git-flow and works well for continuous deployment.

### GitLab Flow

GitLab Flow combines aspects of both, often using environment branches (`staging`, `production`) rather than release branches.

---

## When to Use Git-Flow

Git-flow is well-suited for:

- Projects with defined release cycles (weekly, monthly, quarterly)
- Projects that must maintain multiple versions simultaneously
- Teams large enough that uncoordinated branching becomes a problem
- Software with a formal QA stage before each release

Git-flow is less well-suited for:

- Applications deployed continuously from `main`
- Small teams with rapid iteration
- Projects where release timing is unpredictable or ad-hoc
- Open source projects where contributors branch and PR freely

---

## Common Pitfalls

**Forgetting to merge the release branch back into `develop`**  
Fixes made on the release branch disappear from future development if this step is skipped.

**Merging hotfixes only into `main`**  
The same problem: the fix is live in production but not in the next release.

**Long-lived feature branches**  
Feature branches that stay open for weeks accumulate large diffs and painful conflicts. Keep features small and merge often.

**Committing directly to `main` or `develop`**  
Bypasses the intent of the model. Use pull requests or at minimum get a second review before direct commits to these branches.

**Forgetting to tag releases**  
Tags are what make `main` meaningful in git-flow. Untagged merges lose the traceability that the model depends on.

**Not deleting finished branches**  
Stale branches accumulate quickly and create confusion about what is active work.

---

## Quick Reference

### Branch Rules Summary

|Branch|Branches From|Merges Into|Deleted After?|
|---|---|---|---|
|`main`|—|—|No (permanent)|
|`develop`|`main`|—|No (permanent)|
|`feature/*`|`develop`|`develop`|Yes|
|`release/*`|`develop`|`main` + `develop`|Yes|
|`hotfix/*`|`main`|`main` + `develop`|Yes|
|`support/*`|`main` tag|(long-lived)|No|

### Essential Commands

```bash
# Initialize
git flow init

# Feature
git flow feature start <name>
git flow feature finish <name>

# Release
git flow release start <version>
git flow release finish <version>

# Hotfix
git flow hotfix start <version>
git flow hotfix finish <version>

# Push all tags
git push origin --tags
```

---

## Further Reading

- Vincent Driessen's original post: `nvie.com/posts/a-successful-git-branching-model/` — includes his 2020 note reflecting on when git-flow is and is not appropriate.
- The `git-flow` AVH edition (actively maintained fork): `github.com/petervanderdoes/gitflow-avh`
- Atlassian's git-flow tutorial: `atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow`

---

# git-flow: The CLI Tool

## What It Is

git-flow is a set of Git subcommands that automate the branching conventions of Vincent Driessen's branching model. It is not a replacement for Git — it is simply a set of scripts that combine standard Git commands in a clever way. Strictly speaking, you would not even have to install anything to use the git-flow workflows: you could learn which workflow involves which individual tasks and perform those Git commands with the right parameters and in the right order yourself. The git-flow scripts save you from having to memorize all of this.

### The Two Implementations

Two CLI tools carry the git-flow name:

**gitflow-avh** (`petervanderdoes/gitflow-avh`) is the original shell-script implementation and the AVH Edition fork of Driessen's original scripts. This repository was archived by the owner on June 19, 2023. It is now read-only. It is still widely installed and used, and most package managers still provide it under the name `git-flow`.

**git-flow-next** (`gittower/git-flow-next`) is a newer rewrite in Go, maintained by the Tower team. It is backward-compatible with gitflow-avh repositories and configuration. See the separate git-flow-next guide for full coverage of that tool.

This document covers **gitflow-avh**, which is what most `git flow` installations currently are.

---

## Installation

### macOS

```bash
# Homebrew (installs gitflow-avh)
brew install git-flow-avh

# MacPorts
port install git-flow-avh
```

### Linux (Debian/Ubuntu)

```bash
apt-get install git-flow
```

### Linux (manual / curl installer)

```bash
wget -q -O - --no-check-certificate \
  https://raw.github.com/petervanderdoes/gitflow-avh/develop/contrib/gitflow-installer.sh \
  install stable | bash
```

`wget` and `util-linux` are prerequisites for the installer.

### Windows (Cygwin)

Same installer as above, run in a Cygwin shell. Git for Windows also includes git-flow-avh.

### Shell Completion

Tab-completion for git-flow subcommands and branch names is available separately:

- **bobthecow/git-flow-completion** — original, covers the basic commands
- **petervanderdoes/git-flow-completion** — AVH fork, includes tab-completion for AVH-added commands

---

## How the Tool Works

git-flow is by no means a replacement for Git. It's just a set of scripts that combine standard Git commands in a clever way. When you run a git-flow command, it executes a predetermined sequence of plain Git operations. You can observe exactly which Git commands are being run by passing `--showcommands` to any git-flow subcommand.

git-flow stores its configuration inside the repository's `.git/config` file under the `gitflow.*` namespace. Nothing else is modified; stopping use of git-flow requires no cleanup — you simply stop running git-flow commands.

---

## Initialization

Before using git-flow in a repository, it must be initialized. This sets branch names and prefix conventions in `.git/config`.

```bash
git flow init
```

You will be prompted to confirm or override the default values:

```
Branch name for production releases: [master]
Branch name for "next release" development: [develop]

How to name your supporting branch prefixes?
Feature branches? [feature/]
Bugfix branches? [bugfix/]
Release branches? [release/]
Hotfix branches? [hotfix/]
Support branches? [support/]
Version tag prefix? []
```

It is recommended to accept the defaults unless your project already uses different conventions.

### Init Options

|Option|Description|
|---|---|
|`-d, --defaults`|Use default values without prompting|
|`-f, --force`|Force reinitialization of an existing repo|
|`--showcommands`|Print each Git command as it is executed|

```bash
git flow init -d          # non-interactive, all defaults
git flow init -f          # reconfigure an already-initialized repo
```

---

## Feature Branches

### `git flow feature [list]`

Lists existing feature branches in the local repository.

```bash
git flow feature
git flow feature list
git flow feature list -v    # verbose: shows additional info
```

**Flags:** `-v / --[no]verbose`

### `git flow feature start`

Creates a new feature branch based on `develop` and switches to it.

```bash
git flow feature start <name> [<base>]
```

If `<base>` is supplied, it must be a commit SHA, tag, or branch name on `develop`. Omitting it uses the tip of `develop`.

**Flags:**

|Flag|Description|
|---|---|
|`-F / --[no]fetch`|Fetch from origin before performing the local operation|

```bash
git flow feature start my-feature
git flow feature start my-feature abc123    # start from specific commit
git flow feature start my-feature -F        # fetch first
```

**What it does internally:**

```
git checkout -b feature/my-feature develop
```

### `git flow feature finish`

Merges the feature branch back into `develop`, deletes the branch, and checks out `develop`.

```bash
git flow feature finish <name|nameprefix>
```

**Flags:**

|Flag|Description|
|---|---|
|`-F / --[no]fetch`|Fetch from origin before finishing|
|`-r / --[no]rebase`|Rebase instead of merge|
|`-p / --[no]preserve-merges`|Preserve merges when rebasing|
|`-k / --[no]keep`|Keep the branch after finishing|
|`-D / --[no]force_delete`|Force branch deletion|
|`-S / --[no]squash`|Squash all commits into a single commit on develop|
|`--no-ff`|Always create a merge commit (no fast-forward)|

```bash
git flow feature finish my-feature
git flow feature finish my-feature -k      # keep the branch
git flow feature finish my-feature -S      # squash commits
git flow feature finish my-feature --no-ff
```

**What it does internally (no-ff merge):**

```
git checkout develop
git merge --no-ff feature/my-feature
git branch -d feature/my-feature
```

git-flow used `git merge --no-ff feature/authentication` to prevent losing historical information about your feature branch before it is removed.

### `git flow feature publish`

Pushes the feature branch to the remote so collaborators can access it.

```bash
git flow feature publish <name>
```

**What it does internally:**

```
git push origin feature/<name>
git checkout feature/<name>
git branch --set-upstream-to=origin/feature/<name>
```

### `git flow feature track`

Creates a local tracking branch for a remote feature branch.

```bash
git flow feature track <name>
```

### `git flow feature pull`

Pulls a feature branch from a remote. Deprecated in later AVH versions; `track` is preferred.

```bash
git flow feature pull origin <name>
```

### `git flow feature checkout`

Switches to a feature branch.

```bash
git flow feature checkout <name|nameprefix>
```

Supports prefix matching: if only a prefix is given and exactly one branch matches, it checks out that branch.

### `git flow feature diff`

Shows a diff of all changes on the feature branch since it diverged from `develop`.

```bash
git flow feature diff [<name|nameprefix>]
```

### `git flow feature rebase`

Rebases the feature branch on `develop`.

```bash
git flow feature rebase [-i] [-p] [<name|nameprefix>]
```

**Flags:**

|Flag|Description|
|---|---|
|`-i / --[no]interactive`|Interactive rebase|
|`-p / --[no]preserve-merges`|Preserve merges during rebase|

### `git flow feature delete`

Deletes a feature branch.

```bash
git flow feature delete [-f] [-r] <name|nameprefix>
```

**Flags:**

|Flag|Description|
|---|---|
|`-f / --[no]force`|Force deletion|
|`-r / --[no]remote`|Also delete the remote tracking branch|

---

## Release Branches

### `git flow release [list]`

Lists existing release branches.

```bash
git flow release
git flow release list -v
```

### `git flow release start`

Creates a release branch from the `develop` branch. Optionally, a `[BASE]` commit SHA-1 hash can be supplied to start from a specific point; the commit must be on `develop`.

```bash
git flow release start <release> [<base>]
```

**Flags:**

|Flag|Description|
|---|---|
|`-F / --[no]fetch`|Fetch from origin before starting|

```bash
git flow release start 1.4.0
git flow release start 1.4.0 abc123def
```

**What it does internally:**

```
git checkout -b release/1.4.0 develop
```

### `git flow release finish`

Finishing a release is one of the big steps in git branching. It performs several actions: merges the release branch back into `master`, tags the release with its name, back-merges the release into `develop`, and removes the release branch.

```bash
git flow release finish <release>
```

**Flags:**

|Flag|Description|
|---|---|
|`-F / --[no]fetch`|Fetch from origin before finishing|
|`-p / --[no]push`|Push `master`, `develop`, and tags to origin after finishing|
|`-k / --[no]keep`|Keep the release branch after finishing|
|`-D / --[no]force_delete`|Force branch deletion|
|`-n / --[no]tag`|Do not tag this release|
|`-T <tagname>`|Use a custom tag name instead of the release name|
|`-m <msg>`|Use a given tag message|
|`-f <file>`|Use contents of file as tag message|
|`-s / --[no]sign`|Sign the release tag with GPG|
|`-u <keyid>`|Use a specific GPG key for signing|
|`-S / --[no]squash`|Squash release branch commits into a single commit|
|`-b / --[no]nobackmerge`|Skip the back-merge into `develop`|
|`--no-ff`|Always create merge commits|

```bash
git flow release finish 1.4.0
git flow release finish 1.4.0 -p          # push everything after finishing
git flow release finish 1.4.0 -s          # sign the tag
git flow release finish 1.4.0 -m "Release 1.4.0"
git flow release finish 1.4.0 -n          # skip tagging
```

After finishing, push tags manually unless `-p` is used:

```bash
git push origin --tags
```

### `git flow release publish`

Pushes the release branch to origin for collaborative release preparation.

```bash
git flow release publish <release>
```

### `git flow release track`

Creates a local tracking branch for a remote release branch.

```bash
git flow release track <release>
```

### `git flow release delete`

Deletes a release branch.

```bash
git flow release delete [-f] [-r] <release>
```

---

## Hotfix Branches

### `git flow hotfix [list]`

Lists existing hotfix branches.

```bash
git flow hotfix
git flow hotfix list -v
```

### `git flow hotfix start`

Creates a hotfix branch that may be branched off from the corresponding tag on the `master` branch that marks the production version.

```bash
git flow hotfix start <version> [<basename>]
```

`<basename>` is an optional base commit, tag, or branch. Without it, the branch starts from `master`.

**Flags:**

|Flag|Description|
|---|---|
|`-F / --[no]fetch`|Fetch from origin before starting|

```bash
git flow hotfix start 1.4.1
git flow hotfix start 1.4.1 v1.4.0    # start from specific tag
```

**What it does internally:**

```
git checkout -b hotfix/1.4.1 master
```

### `git flow hotfix finish`

By finishing a hotfix it gets merged back into `develop` and `master`. Additionally the `master` merge is tagged with the hotfix version.

```bash
git flow hotfix finish <version>
```

**Flags:**

|Flag|Description|
|---|---|
|`-F / --[no]fetch`|Fetch from origin before finishing|
|`-p / --[no]push`|Push `master`, `develop`, and tags after finishing|
|`-k / --[no]keep`|Keep the hotfix branch after finishing|
|`-D / --[no]force_delete`|Force branch deletion|
|`-n / --[no]tag`|Do not tag this hotfix|
|`-T <tagname>`|Use a custom tag name|
|`-m <msg>`|Use a given tag message|
|`-f <file>`|Use file contents as tag message|
|`-s / --[no]sign`|Sign the tag with GPG|
|`-u <keyid>`|Use a specific GPG key|
|`-b / --[no]nobackmerge`|Skip the back-merge into `develop`|

```bash
git flow hotfix finish 1.4.1
git flow hotfix finish 1.4.1 -p -s    # push and sign
```

### `git flow hotfix publish`

Pushes the hotfix branch to the remote.

```bash
git flow hotfix publish <version>
```

### `git flow hotfix delete`

Deletes a hotfix branch.

```bash
git flow hotfix delete [-f] [-r] <version>
```

---

## Support Branches

Support branches are for maintaining older release lines in parallel. The support feature is still beta; using it is not advised.

### `git flow support [list]`

```bash
git flow support
git flow support list -v
```

### `git flow support start`

Creates a support branch from `master` (or an optional base).

```bash
git flow support start <version> [<base>]
```

**Flags:**

|Flag|Description|
|---|---|
|`-F / --[no]fetch`|Fetch from origin before starting|

### `git flow support rebase`

Rebases a support branch on its base branch.

```bash
git flow support rebase [-i] [-p] [<name|nameprefix>]
```

**Flags:**

|Flag|Description|
|---|---|
|`-i / --[no]interactive`|Interactive rebase|
|`-p / --[no]preserve-merges`|Preserve merges|

---

## Bugfix Branches (AVH addition)

The AVH edition added a `bugfix` branch type, which operates identically to `feature` but uses the `bugfix/` prefix by default. The intended use is for bug fixes that need to be tracked separately from features.

```bash
git flow bugfix start <name> [<base>]
git flow bugfix finish <name>
git flow bugfix publish <name>
git flow bugfix track <name>
git flow bugfix delete <name>
git flow bugfix list
git flow bugfix rebase <name>
git flow bugfix checkout <name>
git flow bugfix diff <name>
```

All flags are identical to the `feature` subcommands.

---

## `git flow config`

Reads and writes git-flow configuration values stored in `.git/config`.

### List current configuration

```bash
git flow config
git flow config list
```

### Set a configuration value

```bash
git flow config set [options] <config-option> <config-value>
```

**Scope flags:**

|Flag|Description|
|---|---|
|`--local`|Write to repository config (default)|
|`--global`|Write to `~/.gitconfig`|
|`--system`|Write to `/etc/gitconfig`|
|`--file <path>`|Write to a specific file|

**Examples:**

```bash
git flow config set gitflow.branch.master main
git flow config set gitflow.prefix.feature feat/
```

### Set the base branch for a branch type

```bash
git flow config base [--get] <branch_type> [<base_branch>]
```

```bash
git flow config base feature develop       # set feature base to develop
git flow config base --get feature         # read feature base
```

---

## Configuration Variables

git-flow reads configuration variables from `.git/config` (or `~/.gitconfig` / `/etc/gitconfig`) using the pattern:

```
gitflow.<command>.<subcommand>.<flag>
```

All variable names must be lowercase.

### Commonly Used Variables

**Branch names:**

```bash
git config gitflow.branch.master main       # production branch name
git config gitflow.branch.develop develop   # development branch name
```

**Prefixes:**

```bash
git config gitflow.prefix.feature feature/
git config gitflow.prefix.bugfix bugfix/
git config gitflow.prefix.release release/
git config gitflow.prefix.hotfix hotfix/
git config gitflow.prefix.support support/
git config gitflow.prefix.versiontag ""     # tag prefix, empty by default
```

**Remote:**

```bash
git config gitflow.origin myorigin          # use a remote other than 'origin'
```

**Auto-push after finish:**

```bash
git config gitflow.feature.finish.push yes
git config gitflow.release.finish.push yes
git config gitflow.hotfix.finish.push yes
git config gitflow.bugfix.finish.push yes
```

**Allow dirty working tree when starting release/hotfix/support branches:**

```bash
git config --bool --set gitflow.allowdirty true
```

By default, git-flow refuses to start a release, hotfix, or support branch when the working tree is dirty.

**Environment variables via `.gitflow_export`:**

git-flow reads a file named `.gitflow_export` in the home directory and sources it before executing operations. This allows setting Git environment variables that apply only when git-flow is running. Example:

```bash
# ~/.gitflow_export
export GIT_MERGE_AUTOEDIT=no
```

---

## The `--showcommands` Flag

Any git-flow subcommand accepts `--showcommands`, which prints each underlying Git command to stdout as it is executed. This is useful for understanding exactly what git-flow does, for debugging, or for learning the raw Git equivalents.

```bash
git flow feature start my-feature --showcommands
git flow release finish 1.4.0 --showcommands
```

---

## Hooks (AVH Edition)

gitflow-avh supports pre- and post-hooks for a wide range of operations. Hook scripts live in `.git/hooks/` and follow the naming pattern:

```
{pre,post}-flow-{type}-{action}
```

Where `{type}` is `feature`, `release`, `hotfix`, `support`, or `bugfix`, and `{action}` is `start`, `finish`, `delete`, `publish`, or `track`.

**Examples of hook names:**

```
pre-flow-feature-start
post-flow-feature-finish
pre-flow-release-start
post-flow-release-finish
pre-flow-hotfix-finish
```

Hook scripts receive positional arguments that vary by action. For `start`, the arguments are the branch name and the base. For `finish`, they include the branch name and version.

A pre-hook that exits with a non-zero status aborts the git-flow operation.

**Example — block a release if a file is missing:**

```bash
#!/bin/sh
# .git/hooks/pre-flow-release-start
if [ ! -f CHANGELOG.md ]; then
    echo "Error: CHANGELOG.md not found. Update it before starting a release."
    exit 1
fi
exit 0
```

---

## What Each `finish` Command Does Internally

Understanding the full sequence each command runs makes it easier to reproduce it manually or troubleshoot failures.

### `feature finish`

```bash
git checkout develop
git merge --no-ff feature/<name>
git branch -d feature/<name>
git checkout develop
```

If `-S` (squash) is used, the merge becomes:

```bash
git merge --squash feature/<name>
git commit
git branch -d feature/<name>
```

### `release finish`

```bash
git checkout master
git merge --no-ff release/<name>
git tag -a <name>
git checkout develop
git merge --no-ff release/<name>    # back-merge
git branch -d release/<name>
git checkout develop
```

### `hotfix finish`

```bash
git checkout master
git merge --no-ff hotfix/<name>
git tag -a <name>
git checkout develop
git merge --no-ff hotfix/<name>    # back-merge
git branch -d hotfix/<name>
git checkout develop
```

---

## Using git-flow with Protected Branches

Many teams configure `main` / `master` and `develop` as protected branches on GitHub, GitLab, or Bitbucket, which prevents direct pushes.

In this case, `git flow feature finish` will successfully merge locally, but pushing to the remote will fail. The typical workaround is to skip `finish` for the remote push step and instead create a pull request from the feature branch to `develop`. You then clean up the local branch manually after the PR is merged:

```bash
# Skip finish, push the feature branch and open a PR
git flow feature publish my-feature
# ... merge via PR on the platform ...

# Clean up local branch manually
git checkout develop
git pull origin develop
git branch -d feature/my-feature
```

---

## Quick Reference

### Feature

```bash
git flow feature start <name>
git flow feature finish <name>
git flow feature publish <name>
git flow feature track <name>
git flow feature pull origin <name>
git flow feature checkout <name>
git flow feature diff [<name>]
git flow feature rebase [-i] [<name>]
git flow feature delete [-f] [-r] <name>
git flow feature list [-v]
```

### Release

```bash
git flow release start <version> [<base>]
git flow release finish <version>
git flow release publish <version>
git flow release track <version>
git flow release delete [-f] [-r] <version>
git flow release list [-v]
```

### Hotfix

```bash
git flow hotfix start <version> [<base>]
git flow hotfix finish <version>
git flow hotfix publish <version>
git flow hotfix delete [-f] [-r] <version>
git flow hotfix list [-v]
```

### Bugfix (AVH)

```bash
git flow bugfix start <name>
git flow bugfix finish <name>
git flow bugfix publish <name>
git flow bugfix list [-v]
```

### Support (beta)

```bash
git flow support start <version> [<base>]
git flow support list [-v]
```

### Init and Config

```bash
git flow init [-d] [-f]
git flow config list
git flow config set <key> <value>
git flow config base <type> [<base>]
git flow version
```

### Universal Flags

These flags are accepted by every subcommand:

|Flag|Description|
|---|---|
|`-h / --[no]help`|Show help for the subcommand|
|`--showcommands`|Print each underlying Git command as it runs|

---

## Further Reading

- gitflow-avh GitHub (archived): `github.com/petervanderdoes/gitflow-avh`
- git-flow cheatsheet by Daniel Kummer: `danielkummer.github.io/git-flow-cheatsheet/`
- gitflow-avh wiki (configuration reference, per-command reference): `github.com/petervanderdoes/gitflow-avh/wiki`
- Vincent Driessen's original post: `nvie.com/posts/a-successful-git-branching-model/`
- git-flow-next (the actively maintained Go successor): `git-flow.sh`

---

# git-flow-next

## What Is git-flow-next?

git-flow-next is a modern reimplementation of the git-flow branching model, written in Go. It is built and maintained by the team behind Tower, the Git client for Mac and Windows. The project was publicly introduced in September 2025 and is hosted at `github.com/gittower/git-flow-next`. Its companion site and documentation are at `git-flow.sh`.

It was created because both the original git-flow (by Vincent Driessen) and the gitflow-avh fork are now discontinued and no longer maintained. git-flow-next picks up where those projects left off, adding significant new capabilities while remaining backward-compatible with existing git-flow repositories.

The core branching model — `main`, `develop`, feature branches, release branches, hotfix branches — is the same as the original git-flow. What git-flow-next adds is customizability, a richer CLI, better conflict guidance, a new configuration system, support for alternative workflow presets, and a Go-based implementation replacing the original shell scripts.

---

## Key Differences from the Original git-flow

### Written in Go

The original git-flow and gitflow-avh were shell scripts. git-flow-next is written in Go, which the project describes as offering better reliability, resource efficiency, and responsiveness. Shell-script-based behavior had limitations in error handling and portability; the Go rewrite is intended to address those directly.

### Actively Maintained

Both the original git-flow and gitflow-avh are discontinued. git-flow-next receives regular updates and bug fixes.

### Workflow Presets

Instead of enforcing a single branching model, git-flow-next ships with three preset workflows:

- **Classic GitFlow** — the original Driessen model (main, develop, feature/, release/, hotfix/, support/)
- **GitHub Flow** — simplified model with only main and feature/ branches
- **GitLab Flow** — multi-environment model with production, staging, main, feature/, and hotfix/ branches

Teams can also start from scratch and define a fully custom workflow.

### Branch Dependency Tracking

git-flow-next can automatically detect and propagate changes between parent and child branches. This is intended to address a common pain point where, for example, `main` can lag behind a `production` branch when hotfixes are applied.

### Configurable Merge Strategies

Each branch type can be configured with independent upstream (merging to parent) and downstream (updating from parent) merge strategies: `merge`, `rebase`, `squash`, or (for trunk branches) `none`.

### Unified Topic Branch System

Rather than hard-coding feature, hotfix, release, and support as the only valid topic branch types, git-flow-next allows you to define any topic branch type you need. All types share the same set of `start`, `finish`, `publish`, `update`, `delete`, `rename`, `checkout`, `track`, and `list` subcommands.

### Shorthand Commands

git-flow-next adds context-aware shorthand commands. If you are on a topic branch, you can run `git flow finish` without specifying the branch type or name — the tool detects both from your current branch.

### Improved Conflict Handling

The tool provides more actionable guidance when merge conflicts occur, and supports `--continue` and `--abort` flags to resume or cancel an in-progress finish operation after conflicts are resolved.

### git-flow-avh Compatibility

git-flow-next automatically detects and translates git-flow-avh configuration at runtime without modifying existing settings. Existing hook scripts written for git-flow-avh work without modification.

---

## Installation

### macOS and Linux (Homebrew)

```bash
brew install gittower/tap/git-flow-next
```

Note: the Homebrew formula name is `git-flow-next`, not `git-flow`. Installing via Homebrew installs the `git-flow` binary.

### Manual Installation

1. Download the latest release from `github.com/gittower/git-flow-next/releases`
2. Extract the binary to a directory in your `PATH`
3. Make it executable:

```bash
chmod +x /path/to/git-flow
```

### VS Code Extension

A VS Code extension is available at the Visual Studio Marketplace under the name "Git Flow Next" (publisher: GitTower). It provides workflow management within the editor.

---

## Initialization

### Interactive Initialization

```bash
git flow init
```

This prompts you to configure branch names and prefixes interactively.

### Using a Preset

```bash
# Classic GitFlow
git flow init --preset=classic

# GitHub Flow
git flow init --preset=github

# GitLab Flow
git flow init --preset=gitlab
```

### Non-interactive with Defaults

```bash
git flow init --defaults
git flow init --preset=classic --defaults
```

### Key Init Options

|Option|Description|
|---|---|
|`-f, --force`|Force reconfiguration even if already initialized|
|`--preset=<name>`|Apply a preset: `classic`, `github`, or `gitlab`|
|`--defaults, -d`|Use default naming without prompting|
|`--custom`|Enable custom configuration mode|
|`--no-create-branches`|Don't create branches if they don't exist|
|`--main=<name>`|Override main branch name|
|`--develop=<name>`|Override develop branch name|
|`--feature=<prefix>`|Override feature branch prefix|
|`--release=<prefix>`|Override release branch prefix|
|`--hotfix=<prefix>`|Override hotfix branch prefix|
|`--support=<prefix>`|Override support branch prefix|
|`--tag=<prefix>`|Override version tag prefix|

### Configuration Scope for Init

Configuration can be stored at different scopes. Only the `init` command uses these scope flags; all other commands read from the merged configuration.

```bash
git flow init --defaults --local    # store in .git/config (default)
git flow init --defaults --global   # store in ~/.gitconfig
git flow init --defaults --system   # store in /etc/gitconfig
git flow init --defaults --file=/path/to/file
```

---

## Workflow Presets in Detail

### Classic GitFlow

The original Driessen model. Two permanent branches (`main`, `develop`) and four topic branch types (`feature/`, `release/`, `hotfix/`, `support/`).

```bash
git flow init --preset=classic
```

Equivalent manual configuration:

```bash
git flow config add base main
git flow config add base develop main --auto-update=true
git flow config add topic feature develop --prefix=feature/
git flow config add topic release main --starting-point=develop --tag=true
git flow config add topic hotfix main --prefix=hotfix/ --tag=true
git flow config add topic support main --prefix=support/
```

### GitHub Flow

Simplified model with only `main` and feature branches. No `develop`, no release branches in the classic sense.

```bash
git flow init --preset=github
```

Equivalent manual configuration:

```bash
git flow config add base main
git flow config add topic feature main --prefix=feature/
```

### GitLab Flow

Multi-environment model with `production`, `staging`, and `main`, plus feature and hotfix branches.

```bash
git flow init --preset=gitlab
```

Equivalent manual configuration:

```bash
git flow config add base production
git flow config add base staging production --auto-update=true
git flow config add base main staging --auto-update=true
git flow config add topic feature main --prefix=feature/
git flow config add topic hotfix production --prefix=hotfix/ --tag=true
```

The `--auto-update=true` flag tells git-flow-next to propagate changes from parent to child branch automatically.

---

## Core Commands

### `git flow init`

Initializes git-flow configuration in the current repository. See the Initialization section above.

### `git flow config`

Manages git-flow configuration for base and topic branches. Provides `add`, `edit`, `rename`, `delete`, and `list` subcommands.

```bash
git flow config list                   # show current configuration
git flow config add base staging       # add a base branch
git flow config add topic bugfix develop --prefix=bug/
git flow config edit topic feature --upstream-strategy=squash
git flow config rename base develop integration
git flow config delete topic support
```

### `git flow overview`

Displays the repository's current git-flow configuration, branch structure, active branches with ahead/behind counts, and workflow health status. Useful for diagnosing configuration or sync issues.

```bash
git flow overview
git flow overview --verbose
git flow overview --format=json    # for CI/CD tooling
git flow overview --format=yaml
```

Health checks include configuration validation, branch sync status, and workflow compliance verification. Each item is reported as `healthy`, `warning`, or `error`.

### `git flow version`

Shows the installed version of git-flow-next.

### `git flow completion`

Generates shell completion scripts.

```bash
git flow completion bash
git flow completion zsh
git flow completion fish
git flow completion powershell
```

---

## Topic Branch Commands

All topic branch types — whether built-in or custom — share the same set of subcommands. The following sections document each subcommand.

### `start`

Creates and checks out a new topic branch.

```bash
git flow feature start <name> [base]
git flow release start <version>
git flow hotfix start <version> [tag]
```

**Options:**

|Option|Description|
|---|---|
|`--fetch`|Fetch from remote before creating branch|
|`--no-fetch`|Don't fetch (default)|

**Examples:**

```bash
git flow feature start user-authentication
git flow release start 1.4.0
git flow feature start emergency-fix abc123def    # start from specific commit
git flow hotfix start 1.4.1 v1.4.0               # start from specific tag
git flow feature start new-api --fetch
```

### `finish`

Merges a topic branch into its parent branch according to the configured or specified merge strategy. Handles tagging (if configured), updating child branches, and branch deletion. Supports conflict recovery via `--continue` and `--abort`.

```bash
git flow feature finish <name>
git flow release finish <version>
git flow hotfix finish <version>
git flow finish                        # shorthand: operates on current branch
```

**Operation control:**

|Option|Description|
|---|---|
|`--continue, -c`|Continue after resolving merge conflicts|
|`--abort, -a`|Abort and return to original state|
|`--force, -f`|Skip remote sync check, allow finishing non-standard branches|

**Tag creation:**

|Option|Description|
|---|---|
|`--tag`|Create a tag on finish|
|`--notag`|Don't create a tag|
|`--sign`|Sign the tag with GPG|
|`--signingkey <keyid>`|Use a specific GPG key|
|`-m, --message <msg>`|Tag message|
|`--messagefile <file>`|Use file contents as tag message|
|`--tagname <name>`|Use a specific tag name|

**Branch retention:**

|Option|Description|
|---|---|
|`--keep`|Keep topic branch after finishing|
|`--no-keep`|Delete topic branch after finishing (default)|
|`--keepremote`|Keep remote tracking branch|
|`--keeplocal`|Keep local branch|
|`--force-delete`|Force delete even if not fully merged|

**Merge strategy control:**

|Option|Description|
|---|---|
|`--rebase`|Rebase before merging|
|`--squash`|Squash all commits into one|
|`--squash-message <msg>`|Custom message for the squash commit|
|`--merge-message, -M <msg>`|Custom message for the upstream merge commit|
|`--update-message <msg>`|Custom message for child branch update commits|
|`--no-ff`|Create merge commit even if fast-forward is possible|
|`--ff`|Allow fast-forward (default)|
|`--preserve-merges`|Preserve merges during rebase|

**Remote sync check:**

Before merging, `finish` checks whether the local branch is in sync with its remote tracking branch. If the local branch is behind or diverged, the operation aborts to prevent data loss. Use `--force` to bypass this check.

**Message placeholders:**

Custom merge and update messages support these placeholders:

|Placeholder|Description|Example|
|---|---|---|
|`%b`|Branch name|`feature/my-feature`|
|`%B`|Full refname|`refs/heads/feature/my-feature`|
|`%p`|Parent branch|`develop`|
|`%P`|Full parent refname|`refs/heads/develop`|
|`%%`|Literal percent sign|`%`|

**Examples:**

```bash
git flow feature finish user-authentication
git flow release finish 1.4.0 --tag --sign
git flow feature finish my-feature --rebase
git flow feature finish my-feature --squash --squash-message "feat: add auth"
git flow feature finish my-feature --merge-message "feat: merge %b into %p"
git flow hotfix finish 1.4.1 --keep
git flow feature finish my-feature --no-verify    # bypass hooks

# Conflict recovery
git flow feature finish my-feature
# ... resolve conflicts in editor ...
git flow feature finish my-feature --continue
```

### `publish`

Pushes a topic branch to the remote repository.

```bash
git flow feature publish
git flow feature publish <name>
git flow publish                       # shorthand
```

**Options:**

|Option|Description|
|---|---|
|`-o, --push-option=<option>`|Pass push options to the server (repeatable)|
|`--no-push-option`|Suppress all push options, including configured defaults|

**Examples:**

```bash
git flow feature publish user-authentication
git flow release publish 1.4.0
git flow feature publish my-feature -o ci.skip
git flow feature publish my-feature -o merge_request.create -o merge_request.target=main
```

### `update`

Updates a topic branch from its parent using the configured downstream strategy.

```bash
git flow feature update <name>
git flow update                        # shorthand
```

**Options:**

|Option|Description|
|---|---|
|`--rebase`|Force rebase strategy|

**Examples:**

```bash
git flow feature update user-authentication
git flow feature update my-feature --rebase
git flow release update 1.4.0
```

### `delete`

Deletes a topic branch locally and optionally on the remote.

```bash
git flow feature delete <name>
git flow delete                        # shorthand
```

**Options:**

|Option|Description|
|---|---|
|`--force, -f`|Force delete even if unmerged|
|`--remote, -r`|Also delete the remote tracking branch|

**Examples:**

```bash
git flow feature delete old-feature
git flow feature delete my-feature --remote
git flow feature delete experimental --force
```

### `rename`

Renames a topic branch while preserving Git history.

```bash
git flow feature rename <old-name> <new-name>
git flow rename <new-name>             # shorthand for current branch
```

### `checkout`

Switches to a topic branch, with partial name matching. If no exact match is found, git-flow-next looks for branches whose names begin with the given prefix.

```bash
git flow feature checkout user-authentication
git flow feature checkout user          # partial match
```

If multiple branches match a partial name, the tool reports an error and prompts for a more specific name.

### `track`

Creates a local branch tracking a remote topic branch, for collaborating on branches started by teammates.

```bash
git flow feature track user-authentication
git flow release track 1.4.0
```

**Typical team workflow:**

```bash
# Developer A publishes
git flow feature publish shared-feature

# Developer B tracks
git flow feature track shared-feature
```

### `list`

Lists topic branches of a given type, with optional glob pattern filtering.

```bash
git flow feature list
git flow release list
git flow feature list "user-*"
git flow release list "1.*"
```

---

## Shorthand Commands

git-flow-next detects the type and name of your current branch automatically, so you can use abbreviated commands when you are already checked out on a topic branch.

|Shorthand|Equivalent full command|
|---|---|
|`git flow finish`|`git flow <type> finish <name>`|
|`git flow update`|`git flow <type> update <name>`|
|`git flow rebase`|`git flow <type> update --rebase`|
|`git flow publish`|`git flow <type> publish <name>`|
|`git flow rename <new>`|`git flow <type> rename <name> <new>`|
|`git flow delete`|`git flow <type> delete <name>`|

Branch type detection is based on configured prefixes. If a branch name is ambiguous, the tool prompts for clarification.

**Examples:**

```bash
git checkout feature/my-feature
git flow finish       # equivalent to: git flow feature finish my-feature
git flow rebase       # equivalent to: git flow feature update --rebase

git checkout release/1.4.0
git flow publish      # equivalent to: git flow release publish 1.4.0
```

---

## Configuration System

git-flow-next stores all configuration under the `gitflow.*` namespace in Git's native configuration system.

### Hierarchy

Configuration follows a three-layer precedence (highest to lowest):

1. **Command-line flags** — always win
2. **Command-specific overrides** (`gitflow.<type>.<command>.*`) — override defaults for a specific operation
3. **Branch type defaults** (`gitflow.branch.*`) — default behavior for a branch type

Git's own scope precedence also applies: local (`.git/config`) > global (`~/.gitconfig`) > system (`/etc/gitconfig`).

### Branch Type Configuration Keys

```bash
git config gitflow.branch.<type>.prefix <prefix>
git config gitflow.branch.<type>.parent <parent-branch>
git config gitflow.branch.<type>.startpoint <start-branch>
git config gitflow.branch.<type>.upstreamstrategy <merge|rebase|squash>
git config gitflow.branch.<type>.downstreamstrategy <merge|rebase>
git config gitflow.branch.<type>.tag <true|false>
git config gitflow.branch.<type>.tagprefix <prefix>
git config gitflow.branch.<type>.autoupdate <true|false>
git config gitflow.branch.<type>.forcedelete <true|false>
```

### Command-Specific Overrides

```bash
# Always fetch before starting features
git config gitflow.feature.start.fetch true

# Always rebase when finishing features
git config gitflow.feature.finish.rebase true

# Squash when finishing hotfixes
git config gitflow.hotfix.finish.squash true

# Sign release tags
git config gitflow.release.finish.sign true
git config gitflow.release.finish.signingkey ABC123DEF

# Keep support branches after finishing
git config gitflow.support.finish.keep true

# Custom merge message
git config gitflow.feature.finish.mergemessage "feat: merge %b into %p"

# Custom update message
git config gitflow.release.finish.updatemessage "chore: sync %b from %p"

# Bypass hooks during finish
git config gitflow.feature.finish.noverify true

# Push options for publish
git config gitflow.feature.publish.push-option "ci.skip"
```

### Merge Strategies

|Strategy|Behavior|
|---|---|
|`merge`|Standard Git merge, creates a merge commit, preserves branch history|
|`rebase`|Rebase onto target, creates linear history, no merge commits|
|`squash`|Combines all commits into one commit on the target branch|
|`none`|No automatic merge; manual merge required (base branches only)|

### Custom Hooks Path

```bash
git config gitflow.path.hooks /shared/team-hooks      # absolute path
git config gitflow.path.hooks .githooks               # relative to repo root
git config --global gitflow.path.hooks .githooks      # user-wide default
```

The hooks directory precedence: `gitflow.path.hooks` > `core.hooksPath` > `.git/hooks`.

---

## Hooks and Filters

### Hooks

Hook scripts execute before or after git-flow operations. Pre-hooks can stop an operation by exiting with a non-zero status.

**Naming pattern:** `{pre,post}-flow-{type}-{action}`

**Available actions:** `start`, `finish`, `publish`, `track`, `delete`, `update`

**Positional arguments passed to each hook:**

|Action|Arguments|
|---|---|
|`start`|`$1=name`, `$2=origin`, `$3=branch`, `$4=base`|
|`finish`|`$1=name`, `$2=origin`, `$3=branch`|
|`publish`|`$1=name`, `$2=origin`, `$3=branch`|
|`track`|`$1=name`, `$2=origin`, `$3=branch`|
|`delete`|`$1=name`, `$2=origin`, `$3=branch`|
|`update`|`$1=name`, `$2=origin`, `$3=branch`, `$4=base`|

**Environment variables available in all hooks:**

|Variable|Description|
|---|---|
|`BRANCH`|Full branch name, e.g. `feature/my-feature`|
|`BRANCH_NAME`|Short name, e.g. `my-feature`|
|`BRANCH_TYPE`|Type, e.g. `feature`|
|`BASE_BRANCH`|Parent branch, e.g. `develop`|
|`ORIGIN`|Remote name|
|`VERSION`|Version (for release/hotfix branches)|
|`EXIT_CODE`|Exit code of the operation (post-hooks only)|

Hooks written for git-flow-avh work without modification in git-flow-next.

**Example pre-hook (check CI before release):**

```bash
#!/bin/sh
# .git/hooks/pre-flow-release-start
if command -v gh &> /dev/null; then
    STATUS=$(gh run list --branch "${BASE_BRANCH:-develop}" --limit 1 --json conclusion -q '.[0].conclusion')
    if [ "$STATUS" != "success" ]; then
        echo "Error: CI is not passing on ${BASE_BRANCH:-develop}"
        exit 1
    fi
fi
exit 0
```

**Example post-hook (notify on release completion):**

```bash
#!/bin/sh
# .git/hooks/post-flow-release-finish
if [ "$EXIT_CODE" -eq 0 ]; then
    echo "Release $VERSION completed successfully!"
fi
```

### Filters

Filters transform values during git-flow operations. A filter script receives input as arguments and writes the transformed value to stdout. If the filter does not exist or exits with a non-zero status, the original value is used.

**Available filters:**

|Filter name|Triggered by|Purpose|
|---|---|---|
|`filter-flow-release-start-version`|`git flow release start`|Modify version number|
|`filter-flow-hotfix-start-version`|`git flow hotfix start`|Modify version number|
|`filter-flow-release-finish-tag-message`|`git flow release finish`|Customize tag message|
|`filter-flow-hotfix-finish-tag-message`|`git flow hotfix finish`|Customize tag message|

Version filters receive the version as `$1`. Tag message filters receive the version as `$1` and the original message as `$2`, plus the standard environment variables.

---

## Custom Workflows

One of the principal differences from the original git-flow is the ability to define arbitrary branch topologies.

### Example: Multi-environment with Custom Topic Types

```bash
# Base branch hierarchy
git flow config add base production
git flow config add base staging production --auto-update=true
git flow config add base develop staging --auto-update=true

# Custom topic branch types
git flow config add topic feature develop --prefix=feat/
git flow config add topic bugfix develop --prefix=bug/
git flow config add topic epic develop --prefix=epic/
git flow config add topic release staging --prefix=release/ --tag=true
git flow config add topic hotfix production --prefix=hotfix/ --tag=true
```

With `--auto-update=true`, git-flow-next propagates changes from parent to child when branches are finished, so that `staging` is kept in sync with `production`, and `develop` stays in sync with `staging`.

### Verifying Configuration

```bash
git flow config list
git flow overview --verbose
```

---

## Migration from git-flow-avh

Because git-flow-next automatically translates git-flow-avh configuration at runtime, migration is straightforward in most cases:

1. Install git-flow-next.
2. The binary is named `git-flow`, so it replaces the previous binary on your `PATH`.
3. Existing repositories do not need to be re-initialized.
4. Existing hook scripts do not need to be modified.

There is no need to run `git flow init --force` unless you want to change your configuration.

---

## Quick Reference

### Init

```bash
git flow init                            # interactive
git flow init --preset=classic --defaults
git flow init --preset=github --defaults
git flow init --preset=gitlab --defaults
git flow init --force                    # reconfigure existing repo
```

### Feature

```bash
git flow feature start <name>
git flow feature finish <name>
git flow feature publish <name>
git flow feature update <name>
git flow feature list
git flow feature checkout <name>
git flow feature track <name>
git flow feature delete <name>
git flow feature rename <old> <new>
```

### Release

```bash
git flow release start <version>
git flow release finish <version>
git flow release finish <version> --tag --sign
git flow release publish <version>
git flow release list
```

### Hotfix

```bash
git flow hotfix start <version>
git flow hotfix finish <version>
git flow hotfix publish <version>
```

### Shorthands (on current topic branch)

```bash
git flow finish
git flow update
git flow rebase
git flow publish
git flow delete
git flow rename <new-name>
```

### Configuration

```bash
git flow config list
git flow config add base <name> [parent]
git flow config add topic <name> <parent> [options]
git flow config edit topic <name> [options]
git flow config rename base <old> <new>
git flow config delete topic <name>
```

### Diagnostics

```bash
git flow overview
git flow overview --verbose
git flow overview --format=json
git flow version
```

---

## Further Reading

- Official site and documentation: `git-flow.sh`
- GitHub repository: `github.com/gittower/git-flow-next`
- VS Code extension: Visual Studio Marketplace, publisher GitTower
- Tower Git client (maintainer of the project): `git-tower.com`
- Vincent Driessen's original git-flow post (2010, with 2020 reflection note): `nvie.com/posts/a-successful-git-branching-model/`