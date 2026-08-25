## False Positive Suppression Strategies


Suppression should be granular to avoid masking genuine risks.

Inline Suppression:

Use # nosec followed by the specific test ID to ignore only that check. Omitting the ID disables all checks for that line, which is an anti-pattern.

- **Bad:**
    
    Python
    
    ```
    subprocess.call(cmd, shell=True)  # nosec
    ```
    
- **Good:**
    
    Python
    
    ```
    # Justification: cmd is sanitized via shlex.quote() upstream
    subprocess.call(cmd, shell=True)  # nosec B602
    ```
    

Safe Hash Usage (B303/B324):

Bandit flags usage of MD5/SHA1. If these are used for non-security purposes (e.g., file deduplication), explicit suppression is required. Verify intent before suppressing.

---

