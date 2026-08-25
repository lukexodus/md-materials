## Automated checks before review


Automated checks constitute the "gatekeeping" layer of the software development lifecycle, ensuring that code meets a defined baseline of quality before it requests human attention. By offloading mechanical and stylistic verification to machines, teams reduce the cognitive load on reviewers, allowing them to focus on architecture, logic, and maintainability rather than syntax or formatting. These checks typically run at two stages: locally via pre-commit hooks and remotely via Continuous Integration (CI) pipelines.

**Key Points**

- **Shift-Left Strategy:** Moving detection mechanisms as close to the developer as possible. Errors caught locally (pre-commit) are cheaper to fix than errors caught in CI, which are cheaper than errors caught in review.
    
- **Linting and Formatting:**
    
    - **Linters (e.g., ESLint, Pylint, RuboCop):** Analyze code for potential errors, stylistic inconsistencies, and suspicious constructs.
        
    - **Formatters (e.g., Prettier, Black, gofmt):** Automatically rewrite code to adhere to a strict style guide, eliminating "bike-shedding" discussions about spacing or quotes during code review.
        
- **Static Analysis (SAST):** Tools like SonarQube or CodeQL scan for complex bugs, security vulnerabilities (e.g., SQL injection risks), and cyclomatic complexity limits without executing the code.
    
- **Type Checking:** For dynamically typed languages with type hints (TypeScript, Python with MyPy), automated checks verify type consistency to prevent runtime type errors.
    
- **Automated Testing:** Running unit tests (and potentially fast integration tests) to ensure the changes do not break existing functionality (regression testing).
    
- **Commit Message Enforcement:** Tools like Commitlint ensure commit messages follow a standard convention (e.g., Conventional Commits), which is vital for automated changelog generation and semantic versioning.
    

**Example**

The following example demonstrates a configuration using the Python `pre-commit` framework. This setup ensures that before code is committed to git, it is automatically formatted, checked for large files, and linted.

_File: .pre-commit-config.yaml_

YAML

```
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files

  - repo: https://github.com/psf/black
    rev: 23.3.0
    hooks:
      - id: black
        language_version: python3

  - repo: https://github.com/pycqa/flake8
    rev: 6.0.0
    hooks:
      - id: flake8
        args: ['--max-line-length=88', '--ignore=E203']
```

_Developer Workflow:_

Bash

```
# Developer attempts to commit messy code
git add main.py
git commit -m "feat: update logic"
```

**Output**

The terminal output when the automated check intercepts a non-compliant commit:

Plaintext

```
Check Yaml...............................................................Passed
Fix End of Files.........................................................Passed
Trim Trailing Whitespace.................................................Failed
- hook id: trailing-whitespace
- exit code: 1
- files were modified by this hook

black....................................................................Failed
- hook id: black
- files were modified by this hook

flake8...................................................................Passed

[WARNING] The commit failed because some hooks modified files or found errors.
Review the changes and re-commit.
```

_Result:_ The commit is blocked. The tools automatically fixed the whitespace and formatting (`black`). The developer simply needs to `git add` the fixes and commit again.

**Conclusion**

Automated checks before review are essential for maintaining a high signal-to-noise ratio in code reviews. They act as an impersonal enforcer of standards, preventing human relationships from being strained by nitpicking. A Pull Request (PR) should only be open for review once it has passed these automated gates; otherwise, the review process becomes a debugging session for trivial issues.

---

