## Conceptual Architecture & The "Golden Master" Pattern


Characterization tests (often synonymous with "Golden Master" testing) serve a distinct architectural purpose compared to unit or integration tests. While standard tests assert against a specification, characterization tests assert against _current behavior_, regardless of correctness. Their primary function is to lock down the behavior of legacy, undocumented, or uncovered code to create a safety net for refactoring.

**The Workflow Loop:**

1. **Stimulation:** The System Under Test (SUT) is executed with a fixed set of inputs.
    
2. **Capture:** All observable side effects (return values, logs, database state, console output) are serialized into a stable text format.
    
3. **Ratification:** The initial output is reviewed manually (once) and saved as the "Golden Master" file.
    
4. **Verification:** Subsequent runs generate a new output file which is bit-wise compared against the Golden Master. Any deviation causes a test failure.
    

Strategic Usage:

These tests are transient artifacts. They are typically introduced immediately prior to refactoring a high-risk module and are often deleted or evolved into proper unit tests once the code is modularized and understood.

