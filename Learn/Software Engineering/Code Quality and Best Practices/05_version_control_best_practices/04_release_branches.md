## Release branches


Release branches are temporary branches used to prepare a new version of the software for production deployment. They serve as a buffer between the fast-paced development branch (often `develop`) and the stable production branch (often `main` or `master`). This isolation allows for final polishing, bug fixing, and documentation generation without blocking the development of features for future releases.

**Key Points**

- **Stabilization Phase:** The primary purpose of a release branch is stabilization. Once a release branch is cut, strictly **no new features** should be added to it. Only bug fixes, documentation updates, and release-oriented tasks (like bumping version numbers) are permitted.
    
- **Dual Merge Strategy:** When the release is ready, it must be merged into two places:
    
    1. **`main` (or `master`):** To deploy the code to production. This commit is usually tagged with the version number (e.g., `v1.0.0`).
        
    2. **`develop`:** To ensure that any bug fixes or hotfixes made during the release candidate phase are preserved in the ongoing development history. Failing to do this causes regression bugs in future versions.
        
- **Continuous Delivery Pipeline:** Release branches often trigger specific CI/CD pipelines. While feature branches might only run unit tests, release branches might trigger integration tests, user acceptance testing (UAT) deployments, and artifact generation.
    
- **Semantic Versioning:** The creation of a release branch typically coincides with the decision of the semantic version number (Major.Minor.Patch). The branch name often reflects this (e.g., `release/1.2.0`).
    
- **Avoiding "Code Freeze":** In teams without release branches, a "code freeze" is often declared where no one can merge code until the release is done. Release branches eliminate this bottleneck; developers can continue merging features for _vNext_ into `develop` while the _current_ release is being finalized in its specific branch.
    

**Example**

_Standard Gitflow Workflow_

1. **Start the Release:** The team decides `develop` is feature-complete for version 1.2.0.
    
    Bash
    
    ```
    git checkout develop
    git checkout -b release/1.2.0
    # Run script to bump version number in files to 1.2.0
    git commit -a -m "Bump version number to 1.2.0"
    ```
    
2. **Stabilize:** QA finds a bug. The fix is applied directly to the release branch.
    
    Bash
    
    ```
    # Fix bug in code
    git commit -a -m "Fix login timeout bug"
    ```
    
3. **Finish the Release:** The release is stable and ready for production.
    
    Bash
    
    ```
    # 1. Merge to master and tag
    git checkout master
    git merge release/1.2.0
    git tag -a v1.2.0 -m "Version 1.2.0"
    
    # 2. Merge back to develop (CRITICAL STEP)
    git checkout develop
    git merge release/1.2.0
    
    # 3. Delete the release branch
    git branch -d release/1.2.0
    ```

---

