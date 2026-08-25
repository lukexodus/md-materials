## Baseline Management for Legacy Codebases


Introducing Bandit to a mature codebase often results in hundreds of "wont-fix" alerts. The "Baseline" feature allows teams to "grandfather" existing issues and only fail builds on _net new_ vulnerabilities.

**Implementation Workflow:**

1. **Generate Baseline:** Create a JSON report of the current state.
    
    Bash
    
    ```
    bandit -r ./src -f json -o bandit_baseline.json
    ```
    
2. **Differential Scan:** Configure the CI pipeline to compare the current run against the baseline.
    
    Bash
    
    ```
    bandit -r ./src -b bandit_baseline.json -f txt
    ```
    
3. **Exit Code Behavior:**
    
    - **0:** No _new_ issues found (existing baseline issues are ignored).
        
    - **1:** New issues introduced that match the configured severity profile.
        

**Maintenance:** The baseline file must be treated as a live artifact. When a legacy issue is remediated, the baseline must be regenerated to prevent regression.

