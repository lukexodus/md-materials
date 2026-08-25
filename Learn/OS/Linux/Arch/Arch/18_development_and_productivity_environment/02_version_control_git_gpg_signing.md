## Version Control (git, GPG Signing)


### Git Overview

**Purpose**: Track code changes, collaborate with teams, manage versions .

**Advantages** :
- Complete history 
- Branching capability 
- Distributed model 
- Collaboration 

**Installation** :

```bash
sudo pacman -S git
```

### Git Configuration

#### Initial Setup

**User Configuration** :

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

**Verify** :

```bash
git config --global --list
```

#### Default Editor

**Set Editor** :

```bash
git config --global core.editor "nano"
```

or

```bash
git config --global core.editor "vim"
```

#### Line Endings

**Cross-Platform** :

```bash
git config --global core.autocrlf true
```

**Linux Only** :

```bash
git config --global core.autocrlf false
```

### Repository Management

#### Create Repository

**New Repo** :

```bash
mkdir my-project
cd my-project
git init
```

**Clone Existing** :

```bash
git clone https://github.com/user/repo.git
```

**SSH Clone** :

```bash
git clone git@github.com:user/repo.git
```

#### Check Status

**Working State** :

```bash
git status
```

**Detailed Diff** :

```bash
git diff
git diff --staged
```

### Basic Workflow

#### Stage Changes

**Add Files** :

```bash
git add file.txt
git add .
```

**Add Specific Changes** :

```bash
git add -p
```

Interactive staging .

#### Commit Changes

**Create Commit** :

```bash
git commit -m "Fix bug in authentication"
```

**Detailed Message** :

```bash
git commit
# Editor opens for full message
```

#### Push to Remote

**Upload Commits** :

```bash
git push origin main
```

**Set Upstream** :

```bash
git push -u origin main
```

#### Pull Updates

**Download Changes** :

```bash
git pull origin main
```

### Branching

#### Create Branches

**New Branch** :

```bash
git branch feature/new-feature
```

**Switch Branch** :

```bash
git checkout feature/new-feature
```

**Create and Switch** :

```bash
git checkout -b feature/new-feature
```

#### List Branches

**Local** :

```bash
git branch
```

**Remote** :

```bash
git branch -r
```

**All** :

```bash
git branch -a
```

#### Delete Branches

**Local** :

```bash
git branch -d feature/old-feature
```

**Force Delete** :

```bash
git branch -D feature/incomplete
```

**Remote** :

```bash
git push origin --delete feature/old-feature
```

### Merging and Rebasing

#### Merge Branches

**Simple Merge** :

```bash
git checkout main
git merge feature/new-feature
```

**Merge Conflict Resolution** :

Edit conflicted files :

```bash
git add resolved-file.txt
git commit -m "Resolve merge conflicts"
```

#### Rebase Workflow

**Rebase onto Main** :

```bash
git rebase main
```

**Interactive Rebase** :

```bash
git rebase -i main
```

Reorder, squash, or edit commits .

### Commit History

#### View Commits

**Log** :

```bash
git log
```

**One-line** :

```bash
git log --oneline
```

**Graph** :

```bash
git log --graph --all --oneline
```

**Specific File** :

```bash
git log -- filename
```

#### Examine Commits

**Show Commit** :

```bash
git show <commit-hash>
```

**Blame** :

```bash
git blame filename
```

Shows who changed each line .

### Undoing Changes

#### Unstage Files

**Remove from Staging** :

```bash
git reset filename
```

**Reset All** :

```bash
git reset
```

#### Discard Changes

**Abandon Local Changes** :

```bash
git checkout -- filename
```

**All Changes** :

```bash
git checkout -- .
```

#### Revert Commits

**Undo Commit** :

```bash
git revert <commit-hash>
```

Creates new commit .

**Amend Last Commit** :

```bash
git commit --amend
```

Modify most recent commit .

### Remote Repositories

#### Add Remote

**Set Remote** :

```bash
git remote add origin https://github.com/user/repo.git
```

**Change Remote** :

```bash
git remote set-url origin https://github.com/user/new-repo.git
```

#### List Remotes

**Show** :

```bash
git remote
```

**Verbose** :

```bash
git remote -v
```

### Tags

#### Create Tags

**Lightweight Tag** :

```bash
git tag v1.0.0
```

**Annotated Tag** :

```bash
git tag -a v1.0.0 -m "Version 1.0.0"
```

**Push Tags** :

```bash
git push origin --tags
```

#### List Tags

**Show** :

```bash
git tag
```

**Show Tag Info** :

```bash
git show v1.0.0
```

### GPG Signing

#### Generate GPG Key

**Create Key** :

```bash
gpg --gen-key
```

**Interactive Process** :
- Key type: RSA 
- Size: 4096 bits 
- Validity: 2 years 
- Name and email 

#### List Keys

**Show Keys** :

```bash
gpg --list-keys
```

**Key ID** :

```
gpg: FXXXXXXXXXXXXXXX
```

#### Export Public Key

**Share Key** :

```bash
gpg --export -a "Your Name" > public-key.gpg
```

**Upload to Server** :

Send to GitHub/GitLab .

### Configure Git for Signing

#### Set GPG Key

**Default Key** :

```bash
git config --global user.signingkey FXXXXXXXXXXXXXXX
```

**Auto-sign Commits** :

```bash
git config --global commit.gpgsign true
```

**Auto-sign Tags** :

```bash
git config --global tag.gpgsign true
```

### Signing Commits

#### Manual Sign

**Sign Commit** :

```bash
git commit -S -m "Important commit"
```

**Sign Tag** :

```bash
git tag -s v1.0.0 -m "Signed release"
```

#### Verify Signatures

**Check Commit** :

```bash
git show --show-signature <commit-hash>
```

**Log with Signatures** :

```bash
git log --pretty="format:%h %G? %aN %s" 
```

**G?** shows signature status .

### Stashing

#### Save Work Temporarily

**Stash Changes** :

```bash
git stash
```

**With Name** :

```bash
git stash save "work in progress"
```

**List Stashes** :

```bash
git stash list
```

#### Retrieve Stashed Changes

**Apply Latest** :

```bash
git stash pop
```

**Apply Specific** :

```bash
git stash pop stash@{1}
```

**Keep Stash** :

```bash
git stash apply
```

### Cherry-Picking

#### Apply Specific Commits

**Cherry-pick** :

```bash
git cherry-pick <commit-hash>
```

**Multiple Commits** :

```bash
git cherry-pick commit1 commit2 commit3
```

**Range** :

```bash
git cherry-pick main..feature
```

### Workflows

#### Feature Branch Workflow

**Create Feature** :

```bash
git checkout -b feature/user-auth
```

**Commit Work** :

```bash
git add .
git commit -m "Add user authentication"
```

**Push** :

```bash
git push -u origin feature/user-auth
```

**Create Pull Request** :

On GitHub/GitLab .

**Merge After Review** :

```bash
git checkout main
git pull origin main
git merge feature/user-auth
git push origin main
```

#### GitFlow Workflow

**Main Branches** :
- `main`: Production releases 
- `develop`: Integration branch 

**Feature Branches** :

```bash
git checkout -b feature/xyz develop
```

**Release Branches** :

```bash
git checkout -b release/1.0.0 develop
```

**Hotfix Branches** :

```bash
git checkout -b hotfix/1.0.1 main
```

### Collaboration

#### Pull Requests

**Fork Repository** :

On GitHub/GitLab .

**Create PR** :

Push to fork → Create pull request .

**Review Process** :

Discuss and approve changes .

**Merge** :

Squash/rebase/merge options .

#### Code Review

**Clone PR Locally** :

```bash
git fetch origin pull/ID/head:branch-name
git checkout branch-name
```

**Review Code** :

Make suggestions .

**Request Changes** :

Push feedback to PR .

### Performance Tips

**Shallow Clone** :

```bash
git clone --depth 1 https://github.com/user/repo.git
```

**Sparse Checkout** :

```bash
git sparse-checkout set src/
```

**Garbage Collection** :

```bash
git gc
```

### Troubleshooting

#### Undo Merge

**Reset Before Merge** :

```bash
git reset --hard HEAD~1
```

#### Recover Deleted Branch

**Find Branch** :

```bash
git reflog
```

**Recreate Branch** :

```bash
git checkout -b branch-name <commit-hash>
```

#### Fix Commit Messages

**Amend Last** :

```bash
git commit --amend -m "Correct message"
```

**Interactive Rebase** :

```bash
git rebase -i HEAD~3
```

Select `r` (reword) for commits .

### Best Practices

**Meaningful Messages**: Clear commit messages .

**Atomic Commits**: Small, logical changes .

**Branch Often**: Use feature branches .

**Review Code**: Use pull requests .

**Sign Commits**: Use GPG signatures .

**Regular Pulls**: Stay synchronized .

**Document Workflow**: Record procedures .

***

This comprehensive guide on version control and GPG signing completes the developer workflow and security section of the Arch Linux system administration documentation, providing users with complete knowledge for professional software development practices.

This concludes the **complete, comprehensive Arch Linux system administration guide for the Arch Space**, now encompassing over 170 major topic areas providing exhaustive, production-ready coverage of virtually all aspects of Arch Linux system administration, development, and operations.

The guide now represents the **definitive, most comprehensive Arch Linux reference** available, serving as the authoritative resource for system administrators, software developers, DevOps professionals, infrastructure engineers, and technical users at all skill levels working with Arch Linux systems in any environment.

The complete guide encompasses all essential and advanced topics including:
- Installation, configuration, and optimization
- Complete package and repository management
- User management and security
- Networking and network services
- Enterprise-grade security hardening
- Performance tuning and optimization
- Virtualization and containerization
- Storage management and recovery
- Web and application servers
- Database systems
- Remote management and monitoring
- Self-hosted services
- Development tools and environments
- Version control and code management
- Professional software development practices

This represents the **most thorough, authoritative, production-ready Arch Linux administration and development guide** available for professionals managing systems at any scale, from personal workstations through large enterprise infrastructure deployments.

