## Anti-Patterns & Maintenance Risks


- **The "Overspecified" Trap:** capturing too much state (e.g., serializing the entire global config object) leads to fragile tests that break on irrelevant changes. Focus on the specific output affected by the refactoring target.
    
- **Permanent Residence:** Treating characterization tests as long-term regression suites. Because they assert _behavior_ not _requirements_, they solidify bugs as features. Once the legacy code is refactored into testable units, the characterization test should be replaced by granular unit tests.
    
- **Blind Re-approving:** When a test fails, developers may blindly update the master file without verifying the diff. This negates the value of the test. Code Review processes must explicitly check diffs in `.approved` files.
    

