## Overview

*.log
*.sql
*.sqlite
```

### Working with Configuration Files Directly

Sometimes it's easier to edit configuration files directly instead of using commands:

#### File Locations

- System: `/etc/gitconfig`
- Global: `~/.gitconfig` or `~/.config/git/config`
- Local: `.git/config` in repository

**Example** A sample global `.gitconfig` file:

```ini
[user]
    name = Jane Developer
    email = jane@example.com
    
[core]
    editor = code --wait
    excludesfile = ~/.gitignore_global
    pager = delta

[alias]
    st = status
    co = checkout
    cm = commit -m
    unstage = reset HEAD --
    last = log -1 HEAD
    
[color]
    ui = auto
    
[pull]
    rebase = true
    
[init]
    defaultBranch = main
    templatedir = ~/.git-templates
    
[delta]
    plus-style = "syntax #012800"
    minus-style = "syntax #340001"
    navigate = true
```

### Migrating Configurations Between Systems

Keeping your Git configurations consistent across multiple machines:

#### Manual Export and Import

```bash
