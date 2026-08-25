## Conventional Commits


Conventional Commits is a lightweight specification for adding human and machine-readable meaning to commit messages. It provides an easy set of rules for creating an explicit commit history, which makes it easier to write automated tools on top of the project. This convention dovetails with Semantic Versioning (SemVer), allowing automated changelog generation and version bumping.

**Key Points**

- **Structure:** The commit message should be structured as follows:
    
    Plaintext
    
    ```
    <type>[optional scope]: <description>
    
    [optional body]
    
    [optional footer(s)]
    ```
    
- **Types:** The type communicates the intent of the change:
    
    - `feat`: A new feature (correlates with `MINOR` in SemVer).
        
    - `fix`: A bug fix (correlates with `PATCH` in SemVer).
        
    - `docs`: Documentation only changes.
        
    - `style`: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc.).
        
    - `refactor`: A code change that neither fixes a bug nor adds a feature.
        
    - `perf`: A code change that improves performance.
        
    - `test`: Adding missing tests or correcting existing tests.
        
    - `build`: Changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm).
        
    - `ci`: Changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs).
        
    - `chore`: Other changes that don't modify src or test files.
        
    - `revert`: Reverts a previous commit.12
        
- **Scope:** An optional phrase in parentheses providing additional context (e.g., `feat(parser):`, `fix(api):`).34
    
- **Description:** A short summary of the code changes. It should be written in the imperative mood ("add" not "added", "change" not "changed").56
    
- **Breaking Ch7anges:** In8dicates a major version change. This is denoted by appending a `!` after the type/scope, or by including `BREAKING CHANGE:` in the footer.
    
- **Footer:** Used for referencing issues (e.g., `Closes #123`) or detailing breaking changes.9
    

**Example10**

_Standard Feature Commit:11_

Plaintext

```
feat(auth): add google oauth2 login support
```

_Bug Fix with Issue Reference:12_

Plaintext

```
fix(database): sanitize user inputs to prevent SQL injection

Sanitization was missing in the legacy search query builder.
This strictly types all inputs before execution.

Closes #402
```

_Breaking Change Commit:_

Plaintext

```
feat(api)!: remove v1 endpoints

BREAKING CHANGE: The v1 API endpoints are no longer supported.
Migrate all clients to v2.
```

**Benefits**

- **Automated Changelogs:** Tools like `standard-version` or `semantic-release` can parse the commit history to generate a `CHANGELOG.md` automatically.
    
- **Semantic Versioning:** By mapping types to version numbers (fix->patch, feat->minor, breaking->major), the release process becomes deterministic.
    
- **Better History Navigation:** Developers can filter logs by type (e.g., `git log --grep "^fix"`) to see only bug fixes.
    
- **Code Review Context:** The rigorous structure forces developers to think about the nature of their changes before committing.
    

**Next Steps**

Install `commitlint` and `husky` in your repository to enforce this convention at the git hook level, preventing commits that do not follow the specified format.

---

