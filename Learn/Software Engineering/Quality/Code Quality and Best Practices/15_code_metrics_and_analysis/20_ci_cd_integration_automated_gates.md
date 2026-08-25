## CI/CD Integration & Automated Gates


Integrating Bandit requires handling exit codes and artifact parsing to prevent blocking builds on low-priority warnings (False Positives).

**Pipeline Architecture:**

1. **Stage:** Pre-Build or Static Analysis.
    
2. **Failure Strategy:** Fail only on `HIGH` severity and `HIGH` confidence.
    
3. **Reporting:** Export to JUnit XML or JSON for dashboard ingestion (e.g., SonarQube, DefectDojo).
    

**Robust CI Command:**

Bash

```
bandit -r ./app \
  --configfile bandit.yaml \
  --profile ci_gate \
  --format json \
  --output bandit-report.json \
  --severity-level high \
  --confidence-level high \
  --exit-zero
```

**Note on `--exit-zero`:** In advanced pipelines, it is often better to use `--exit-zero` and let an external parser (like a script processing the JSON output) determine the failure condition. This allows for more complex logic, such as "Fail if > 0 High Severity issues OR > 5 Medium Severity issues."

