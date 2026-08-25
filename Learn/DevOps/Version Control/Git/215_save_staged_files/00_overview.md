## Overview

staged_files=$(git diff --cached --name-only --diff-filter=ACM | grep '\.py$')

if [ -n "$staged_files" ]; then
  # Format code
  echo "Running Black formatter..."
  python -m black $staged_files
  
  # Run linter
  echo "Running flake8..."
  python -m flake8 $staged_files
  if [ $? -ne 0 ]; then
    echo "Linting failed! Please fix the issues before committing."
    exit 1
  fi
  
  # Run tests
  echo "Running pytest..."
  python -m pytest
  if [ $? -ne 0 ]; then
    echo "Tests failed! Please fix the issues before committing."
    exit 1
  fi
  
  # Re-stage formatted files
  git add $staged_files
fi

exit 0
```

#### Pre-commit Hook Tools

Several tools exist to manage pre-commit hooks more effectively:

- **Husky**: JavaScript tool that manages Git hooks
- **pre-commit**: Python framework for managing multi-language pre-commit hooks
- **lint-staged**: Run linters on staged files only
- **commitlint**: Lint commit messages against conventions
- **git-hooks-js**: Simple JavaScript Git hooks manager

```yaml
