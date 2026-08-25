## Edge Cases and Limitations


Bandit is purely static. It does not execute code, which leads to specific blind spots:

1. **Dynamic Attribute Access:**
    
    Python
    
    ```
    # Bandit will miss this
    module = importlib.import_module("subprocess")
    func = getattr(module, "call")
    func("rm -rf /", shell=True)
    ```
    
    _Mitigation:_ Use dynamic analysis tools (DAST) or runtime instrumentation alongside Bandit.
    
2. Taint Propagation:
    
    Bandit sees cursor.execute(query), but it does not know if query was constructed safely upstream or if it contains user input. It relies on detecting patterns of string concatenation within the SQL query node itself.
    
    Mitigation: Human code review is required for complex data flows.
    
3. False Positives in Tests:
    
    Test files frequently use assert (B101) or hardcoded credentials for mocking.
    
    Remediation: STRICTLY isolate test directories using exclude_dirs in configuration, rather than globally disabling B101.
    
4. Nosec Abuse:
    
    Developers may silence valid warnings using # nosec.
    
    Audit Strategy: Periodically grep the codebase for # nosec comments to audit why security checks were bypassed.
    
    Bash
    
    ```
    grep -r "# nosec" ./src
    ```
    

