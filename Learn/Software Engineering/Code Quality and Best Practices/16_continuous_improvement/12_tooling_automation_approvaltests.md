## Tooling & Automation: ApprovalTests


While ad-hoc file comparison is possible, the industry standard implementation utilizes libraries like **ApprovalTests**. These libraries handle the heavy lifting of:

1. Naming conventions for master/received files.
    
2. Invoking the diff tool (Beyond Compare, Kaleidoscope, git diff) automatically on failure.
    
3. Sanitizing inputs.
    

**Approvals Architecture:**

- **Reporters:** The mechanism that triggers when a test fails. In a CI/CD environment, the reporter should be a "Quiet Reporter" that fails the build and outputs the diff to the build log. In a dev environment, it should launch a GUI diff tool.
    
- **Namer:** Automatically derives the Golden Master filename from the class and test method name (e.g., `LegacyServiceTest.test_export_json.approved.txt`).
    

CI/CD Integration:

Characterization tests must run in the pipeline. However, unlike unit tests, failure often indicates a change rather than a bug. The pipeline configuration must distinguish between intended behavior changes (requiring an update to the master file) and regression.

