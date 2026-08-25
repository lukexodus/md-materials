## Overview

if [ $? -ne 0 ]; then
  echo "Linting failed. Please fix the issues before committing."
  exit 1
fi

exit 0
```

#### Sharing Hooks with Teams

Since `.git/hooks` isn't part of the repository, teams often use these approaches to share hooks:

1. **Script installation**: Include hook scripts in the repo with installation instructions
2. **Hook management tools**: Use tools like Husky or pre-commit
3. **Template directories**: Configure Git to use a template directory with hooks
4. **Custom Git commands**: Create custom Git commands that include hook functionality

```json
// package.json with Husky configuration
{
  "husky": {
    "hooks": {
      "pre-commit": "npm run lint && npm test",
      "pre-push": "npm run build"
    }
  }
}
```

### Pre-commit Hooks for Quality Control

Pre-commit hooks are particularly valuable for quality control, catching issues before they enter the repository.

#### Common Pre-commit Checks

1. **Code Formatting**
    - Ensure consistent formatting (Prettier, Black, gofmt)
    - Normalize line endings and whitespace
    - Check for trailing whitespace or tabs vs. spaces
2. **Linting**
    - Run static code analysis (ESLint, Pylint, RuboCop)
    - Check syntax and style guide compliance
    - Identify potential bugs or anti-patterns
3. **Testing**
    - Run unit tests affected by changes
    - Verify test coverage requirements
    - Ensure all tests pass before allowing commit
4. **Security Checks**
    - Scan for credentials or sensitive data
    - Check for vulnerable dependencies
    - Verify license compliance
5. **Build Verification**
    - Ensure the code builds successfully
    - Check for compilation warnings
    - Verify resource generation

**Example**

```bash
#!/bin/bash
