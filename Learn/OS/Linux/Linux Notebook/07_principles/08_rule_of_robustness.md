## Rule of Robustness


The **Rule of Robustness** is a core Unix philosophy principle stating that robustness is the child of transparency and simplicity.  This rule emphasizes that software achieves reliability not through elaborate error handling, but through design that prioritizes clarity and straightforward logic, enabling systems to perform well even under unexpected conditions that stress the designer's assumptions.[1][2]

### Core Concept

Software is robust when it performs well under both normal conditions and unexpected or stressful circumstances that test the original assumptions behind its design.  Robustness emerges naturally from transparency, which enables problems to be identified and debugged, and from simplicity, which reduces hidden edge cases and complex interactions.  By designing systems to be transparent and simple, developers create software that naturally handles unusual situations without elaborate special-case logic.[3][2][1]

### Avoiding Special Cases

One very important tactic for achieving robustness under unusual inputs is avoiding special cases in code.  When special cases proliferate, they create hidden complexity and interactions that become difficult to reason about, often leading to bugs when edge cases interact in unexpected ways.  By designing code to handle variations within a unified framework rather than through multiple conditional branches, developers reduce the likelihood of logic errors and unexpected behavior.[2][4]

### The Robustness Principle

The **Robustness Principle**, also known as Postel's Law, complements the Rule of Robustness by stating: "be conservative in what you do, be liberal in what you accept from others."  Programs sending output should conform completely to specifications, while programs receiving input should accept non-conformant data as long as the meaning is clear.  This principle encourages designing systems that are forgiving of minor deviations from specifications while maintaining strict standards for their own output.[5]

### Simplicity and Logic Reduction

A critical approach to robustness involves shifting complexity from program logic to data structures.  Even the simplest procedural logic is hard for humans to verify, whereas data is more tractable than program logic.  Where there is a choice between complexity in data structures and complexity in code, developers should choose the former, keeping program logic simple and therefore robust.  This approach makes code easier to reason about and less prone to hidden bugs.[2]

### Practical Error Handling

Robust error handling follows Unix principles by checking critical operations, returning specific error codes for different failure modes, providing clear error messages sent to standard error, and validating results before declaring success.  Rather than attempting to recover gracefully from every possible error, programs should report failures clearly, enabling transparent debugging and remediation.  This aligns with the Rule of Repair, which states that when failure occurs, it should be loud and immediate rather than silent and corrupting.[4][6][2]

### Connection to Other Principles

The Rule of Robustness works in concert with the Rule of Transparency, which emphasizes designing systems that expose their internal state for inspection and debugging.  Together, these principles create software that is easier to understand, monitor, test, and maintain.  Robustness also connects to the Rule of Simplicity and Rule of Clarity, which prevent unnecessary complexity that would hide edge cases and unexpected behaviors.[7][3][4]

Sources
[1] Unix philosophy and its relevance today https://www.facebook.com/groups/retrocomputers/posts/24779261828343698/
[2] Always revisit this page when in doubt; The Basics of UNIX ... https://dev.to/harshbanthiya/always-revisit-this-page-when-in-doubt-the-basics-of-unix-philosophy-45k9
[3] Chapter 1. Philosophy http://www.catb.org/esr/writings/taoup/html/philosophychapter.html
[4] 17 Principles of (Unix) Software Design https://paulvanderlaken.com/2019/09/17/17-principles-of-unix-software-design/
[5] Robustness principle https://en.wikipedia.org/wiki/Robustness_principle
[6] Bulletproof Bash Scripts: Mastering Error Handling for ... https://karandeepsingh.ca/posts/bash-error-handling-bulletproof-scripts/
[7] The Art of Unix Programming - Coding Challenges https://codingchallenges.fyi/blog/art-of-unix-programming/
[8] Unix philosophy https://en.wikipedia.org/wiki/Unix_philosophy
[9] Rules of the UNIX philosophy. - Squidtree https://www.squidtree.com/notes/rules-of-the-unix-philosophy/1154,1A
[10] UNIX-Based Operating Systems Robustness Evaluation https://ntrs.nasa.gov/api/citations/19960034349/downloads/19960034349.pdf


