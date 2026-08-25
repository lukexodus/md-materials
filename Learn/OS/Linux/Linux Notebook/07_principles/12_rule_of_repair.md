## Rule of Repair


The **Rule of Repair** is a core Unix philosophy principle stating that when a program must fail, it should fail noisily and as soon as possible.  This principle, also known as the "fail fast" or "fail loud" philosophy, emphasizes that immediate and visible failure is far better than attempting to proceed in an unstable or possibly corrupted state.[1][2]

### Core Concept

The Rule of Repair dictates that programs should detect errors early and announce them loudly rather than silently attempting workarounds that may hide problems.  When a failure remains undetected, it propagates through the system, ultimately causing other modules to fail, which results in more complicated fault removal and potentially undesired side effects like corrupted files.  A crashed program clearly communicates that a problem exists, which is often a better situation than a misbehaving program that operates in an undefined state.[3]

### Why Fail Fast Works

Failing fast dramatically reduces the number of bugs that reach production by making defects much easier to find and fix.  When software fails immediately and visibly upon encountering an error, developers can identify the root cause close to where the problem occurred, making debugging straightforward.  In contrast, "failing slowly" allows the program to continue working after an error but fail in strange ways later on, making the original cause nearly impossible to trace.[2][4]

### Implementation Strategies

The fail fast principle can be implemented through several concrete techniques.  Programs should check input parameters for validity and nullness before processing.  In object-oriented programming, constructors should initialize internal state and throw exceptions if something is wrong, rather than allowing non-initialized or partially initialized objects that fail later.  Functions should verify all preconditions before proceeding with computation, and client-server architectures should validate requests immediately upon arrival before processing or redirecting them to internal components.[5][3]

### Benefits in Modern Development

The fail fast approach has become increasingly relevant in Agile, DevOps, and continuous delivery models, where faster feedback is critical.  By detecting issues early in the development lifecycle—during coding, building, testing, or deployment—teams avoid discovering problems late in production when fixes are exponentially more expensive.  This approach reduces technical debt, prevents systems from operating in an undefined state, and saves time through easier root cause analysis.[4]

### Contrast with Fail Safe

Fail fast differs from the "fail safe" approach, which continues operation by handling errors gracefully with fallback logic.  While fail safe is ideal for distributed systems, APIs, and production environments where uptime is critical, fail fast excels at input validation, early-stage configuration checks, unit testing, and early pipeline stages.  The choice between these approaches depends on the specific use case and context.[4]

Sources
[1] Basics of the Unix Philosophy http://www.catb.org/esr/writings/taoup/html/ch01s06.html
[2] What does the expression "Fail Early" mean, and when ... https://stackoverflow.com/questions/2807241/what-does-the-expression-fail-early-mean-and-when-would-you-want-to-do-so
[3] Fail Fast (FF) - Principles Wiki http://principles-wiki.net/principles:fail_fast
[4] What Is the Fail Fast Principle in Software Development - LambdaTest https://www.lambdatest.com/learning-hub/fail-fast
[5] Fail-fast system https://en.wikipedia.org/wiki/Fail-fast_system
[6] Unix philosophy and its relevance today https://www.facebook.com/groups/retrocomputers/posts/24779261828343698/
[7] The Fail Fast Mentality : r/engineering https://www.reddit.com/r/engineering/comments/18rnqd7/the_fail_fast_mentality/
[8] The Philosophy of “Fail Early, Fail Often” - Think Different https://flowchainsensei.wordpress.com/2023/07/31/the-philosophy-of-fail-early-fail-often/
[9] Fail early: the hidden design principle behind great UX - UX Collective https://uxdesign.cc/fail-early-a-hidden-design-principle-of-good-products-and-services-b23af66e0247
[10] Fail fast (business) https://en.wikipedia.org/wiki/Fail_fast_(business)

