## Overview

git config filter.lfs.clean "git-lfs clean -- %f"
git config filter.lfs.smudge "git-lfs smudge -- %f"
git config filter.lfs.process "git-lfs filter-process"
git config filter.lfs.required true
```

### Setting Up Template Directories

Template directories contain files that will be copied to every newly created or cloned repository:

#### Creating a Template Directory

```bash
