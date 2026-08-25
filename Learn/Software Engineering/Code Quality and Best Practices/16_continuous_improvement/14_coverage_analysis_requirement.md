## Coverage Analysis Requirement


A characterization test is useless if it does not exercise the specific lines of code being refactored.

**Procedure:**

1. Instrument the codebase with a coverage tool (e.g., `coverage.py`, JaCoCo).
    
2. Run the characterization test suite.
    
3. **Strict Check:** Verify that the "Refactoring Target Area" has 100% branch coverage.
    
4. If coverage is missing, new input combinations must be added to the characterization suite _before_ touching the legacy code.

---

