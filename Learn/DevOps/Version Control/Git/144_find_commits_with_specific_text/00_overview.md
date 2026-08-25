## Overview

git config --global alias.find "!f() { git log --pretty=format:'%C(yellow)%h  %Cblue%ad  %Creset%s%Cgreen  [%cn] %Cred%d' --decorate --date=short -S\"$1\"; }; f"
```

**Example** Using the log alias:

```bash
$ git lg
* a4b3ef7 - (HEAD -> main) Add user authentication (2 hours ago) <Jane Doe>
* 7d2f561 - Implement responsive design (2 days ago) <John Smith>
* 3e8f12a - Initial commit (1 week ago) <John Smith>
```

### Per-Repository Configurations

Per-repository configurations are stored in `.git/config` and allow for project-specific settings:

#### User Identity Overrides

```bash
