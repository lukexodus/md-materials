## Hotfix Branches


Hotfix branches are a specialized component of structured branching strategies (such as Gitflow) designed to address critical, unplanned issues in the production environment. Unlike feature or release branches, hotfixes bypass the standard development lifecycle to restore service stability or security immediately. Proper management of hotfix branches is essential to prevent regression bugs and maintain the integrity of the codebase across parallel streams of development.

**Key Points**

- **Source of Truth:** Hotfix branches must branch directly from `master` (or `main` / `production`), representing the exact state of the code currently live. They should never branch from `develop`, as the development branch contains unreleased features that are not ready for production.
    
- **Minimal Scope:** The content of a hotfix must be strictly limited to the bug fix. No refactoring, no stylistic changes, and no feature additions. Every line changed increases the risk of introducing a secondary bug during a high-pressure deployment.
    
- **Dual Merge Requirement:** Once the fix is verified, the branch must be merged into **both** `master` (to release the fix) and `develop` (to ensure the bug does not reappear in the next release). Failing to merge back to `develop` is a common cause of regression defects.
    
- **SemVer Strictness:** Hotfixes typically trigger a "patch" version bump (e.g., v1.0.0 → v1.0.1). This clear versioning allows for easy rollback and tracking of deployed artifacts.
    
- **Fast-Track CI/CD:** Hotfix branches should trigger a specific CI pipeline that focuses on regression testing the critical path and smoke testing, ensuring the fastest possible time-to-recovery (TTR) without sacrificing basic quality gates.
    

**Example**

_Gitflow Hotfix Workflow:_

1. **Critical Bug Found:** Production (v1.2.0) has a critical payment error.
    
2. **Branch Creation:**
    
    Bash
    
    ```
    git checkout main
    git pull origin main
    git checkout -b hotfix/v1.2.1
    ```
    
3. **Implementation:** The fix is applied. Tests are added to reproduce the bug and verify the fix.
    
4. **Verification & Merge:**
    
    Bash
    
    ```
    # Merge to Main for Release
    git checkout main
    git merge hotfix/v1.2.1
    git tag -a v1.2.1 -m "Critical payment fix"
    
    # Merge to Develop to prevent regression
    git checkout develop
    git merge hotfix/v1.2.1
    ```
    
5. **Cleanup:**
    
    Bash
    
    ```
    git branch -d hotfix/v1.2.1
    ```

---

