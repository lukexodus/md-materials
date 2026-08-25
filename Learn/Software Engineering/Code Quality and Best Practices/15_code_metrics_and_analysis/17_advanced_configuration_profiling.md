## Advanced Configuration & Profiling


Default Bandit configurations are often too noisy for enterprise pipelines. Architecting a high-signal configuration requires granular control over test profiles and skipping logic.

Configuration Hierarchy:

Bandit resolves configuration in the following order (highest precedence first):

1. Command-line arguments
    
2. Per-project config (`.bandit`)
    
3. Global config (`bandit.yaml`)
    

Profile Strategy:

Instead of globally suppressing tests, define profiles for different environments (e.g., strict for production code, permissive for test suites).

YAML

```
# bandit.yaml
profiles:
  production_audit:
    include:
      - B101  # assert_used
      - B102  # exec_used
      - B301  # pickle
      - B324  # hashlib_new_insecure_functions
    exclude:
      - B404  # blacklist_subprocess (too noisy if subprocess is architectural req)

  ci_gate:
    include:
      - B608  # hardcoded_sql_expressions
      - B506  # yaml_load
```

Anti-Pattern - Blanket Exclusion:

Avoid using command-line excludes like -s B101,B102 in CI scripts. This decouples configuration from version control. Always commit exclusions in .bandit or bandit.yaml.

