## Overview

if [ $? -ne 0 ]; then
  echo "Linting failed! Fix errors before committing."
  exit 1
fi
```

Make the hook executable:

```bash
chmod +x ~/.git-templates/hooks/pre-commit
```

**Custom Files** Create default files like `.gitignore` in your template:

```bash
