## C Coding Standards


**Industry Standards** The MISRA C standard provides comprehensive guidelines for safety-critical systems, emphasizing predictable behavior and reduced complexity. ISO/IEC standards define language specifications, while organizations like NASA, automotive manufacturers, and medical device companies maintain domain-specific coding standards that address particular reliability and safety requirements.

**Formatting Consistency** Consistent code formatting improves readability and reduces cognitive load during code review and maintenance. Standard practices include consistent indentation (typically 2, 4, or 8 spaces), brace placement conventions (K&R style, Allman style, or variations), line length limits (commonly 80 or 120 characters), and whitespace usage around operators and function parameters.

**Code Structure Standards** Well-structured C code follows established patterns for function organization, variable declarations, and control flow. Functions should have single responsibilities and manageable complexity, typically staying under 50-100 lines. Variable declarations should appear at the beginning of blocks in C90 or at the point of first use in C99 and later standards.

**Header File Organization** Header files require careful organization to prevent compilation issues and maintain clean interfaces. Include guards or `#pragma once` directives prevent multiple inclusions, while forward declarations minimize dependencies between modules. Headers should contain only declarations, constants, and inline functions, avoiding executable code that could create linking problems.

