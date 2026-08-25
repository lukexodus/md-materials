## Commit message conventions


A commit message is a permanent record in the project's history. It serves as the primary communication channel for explaining the evolution of the codebase to future maintainers (including the original author). Structured conventions transform the commit log from a chaotic list of "updates" into a searchable, semantic history that enables automated tooling, such as semantic versioning and changelog generation.

**Key Points**

- **Imperative Mood:** The subject line must be written in the imperative mood, meaning it should complete the sentence "If applied, this commit will..." (e.g., "Refactor login controller" instead of "Refactored..." or "Refactoring..."). This matches the default output of git merge and revert commands.
    
- **The 50/72 Rule:** The subject line should be limited to 50 characters to ensure readability in `git log --oneline` and GitHub UI. The body should be wrapped at 72 characters to prevent horizontal scrolling in terminal environments.
    
- **Separation of Concerns:** A blank line must separate the subject from the body. Without this, many git tools will treat the entire message as a single run-on header.
    
- **Conventional Commits (Semantic Versioning):** Adopting a strict prefix system (e.g., Angular convention) allows for machine-readable history.
    
    - `feat`: A new feature (correlates to MINOR in SemVer).
        
    - `fix`: A bug fix (correlates to PATCH in SemVer).
        
    - `docs`: Documentation only changes.
        
    - `style`: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc).
        
    - `refactor`: A code change that neither fixes a bug nor adds a feature.
        
    - `perf`: A code change that improves performance.
        
    - `test`: Adding missing tests or correcting existing tests.
        
    - `chore`: Changes to the build process or auxiliary tools and libraries such as documentation generation.
        
- **Context in Body:** The body should explain _why_ the change was made and _what_ the problem was, rather than repeating _how_ the code was changed (which is visible in the diff). It should include references to issue tracker IDs (e.g., "Closes #123").
    

**Example**

_Bad (Vague and inconsistent):_

Plaintext

```
fixed the bug with the login
updated utils
changing the api endpoint
```

_Good (Semantic and structured):_

Plaintext

```
fix(auth): handle null token in session storage

The previous implementation threw an unhandled exception when local
storage was cleared while the user was active. This resulted in a
white screen of death.

We now strictly check for null before attempting to parse the JWT.

Closes #405
```

---

