## Branch naming conventions


A standardized branch naming convention is critical for maintaining a clean version control history, automating CI/CD pipelines, and facilitating team collaboration. Inconsistent naming leads to confusion about the purpose of a branch, difficulties in automated filtering, and cluttered repository lists.

**Key Points**

- **Categorization via Prefixes:** Use prefixes to immediately identify the type of work contained in the branch. This is heavily influenced by workflows like Gitflow.
    
    - `feature/`: Used for new features or non-breaking changes (e.g., `feature/login-system`).
        
    - `bugfix/` or `fix/`: Used for fixing bugs in the codebase (e.g., `fix/header-alignment`).
        
    - `hotfix/`: Used for urgent fixes that need to be applied directly to production/main, bypassing the standard release cycle (e.g., `hotfix/critical-security-patch`).
        
    - `release/`: Used for preparing a new production release (e.g., `release/v1.2.0`).
        
    - `chore/`: Used for maintenance tasks that do not affect the application code, such as updating dependencies, build scripts, or documentation (e.g., `chore/update-readme`).
        
    - `test/` or `experiment/`: Used for research or proof of concept code that may not be merged.
        
- **Issue Tracker Integration:** Include the ticket or issue ID from your project management tool (Jira, Trello, Linear) directly in the branch name. This provides immediate context and often allows CI tools to automatically link Pull Requests to the corresponding ticket.
    
    - _Format:_ `category/ID-description`
        
    - _Example:_ `feature/PROJ-101-add-search-bar`
        
- **Use Separators:** Use hyphens (`-`) to separate words in the description. Avoid underscores or camelCase, as hyphens are more readable and standard in URL slugs. Use forward slashes (`/`) to separate the category from the specific name. Many Git GUI clients treat forward slashes as folder directories, grouping branches visually (e.g., a "feature" folder containing all feature branches).
    
- **Lowercase Only:** Always use lowercase letters. Git is case-sensitive, but file systems on Windows and macOS are often case-insensitive. Creating `Feature/New` and `feature/new` can cause devastating conflicts and synchronization issues across different operating systems.
    
- **Be Descriptive but Concise:** The description part of the name should summarize the "what" clearly. Avoid generic names.
    
    - _Bad:_ `feature/PROJ-123-update` (Update what?)
        
    - _Good:_ `feature/PROJ-123-update-user-profile-api`
        
- **Avoid Personal Names:** In shared repositories, avoid prefixing branches with your name (e.g., `john/feature`). Ownership should be determined by the commit author or the assignee in the Pull Request, not the branch name.
    

**Example**

**Bad Practice:**

Plaintext

```
test
my_branch
FixBug
feature/login
JIRA-4022
```

**Refactored for Standards:**

Plaintext

```
feature/auth-login-page
fix/JIRA-4022-resolve-memory-leak
hotfix/production-crash-handler
chore/upgrade-react-v18
docs/update-api-spec
```

---

