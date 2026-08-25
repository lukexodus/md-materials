## Rule of Parsimony


The **Rule of Parsimony** is a core Unix philosophy principle stating that you should write a big program only when it is clear by demonstration that nothing else will do.  This rule emphasizes that developers should favor creating small, focused utility programs over building monolithic applications, recognizing that the overhead and complexity of large programs often outweigh their benefits.[1][2]

### Core Concept

The Rule of Parsimony reflects the Unix tradition of building small, sharp tools that do one thing well and can be combined to solve complex problems.  Rather than attempting to create comprehensive applications that handle every possible scenario, developers should build minimal programs focused on specific tasks.  Big programs in both volume and ambition should only be written when there is clear evidence that no simpler approach will suffice.[3][4][1]

### Small Programs as Building Blocks

Unix has long championed small utility programs like `cd`, `ls`, `cat`, `grep`, and `tail` that can be composed through pipelines, redirections, and the shell to work in tandem and build more complex workflows than any single program could provide alone.  These simple, consistent interfaces follow Unix conventions for specifying input and standardized exit codes that are reused between programs, enabling seamless integration.  By designing programs to be small and maintainable, developers create building blocks that can be understood, debugged, and composed into larger systems without creating monolithic complexity.[2][4]

### Trade-offs of Small Programs

While favoring small programs provides significant benefits, the philosophy acknowledges legitimate trade-offs exist.  Building tools that are too small can result in increased burden on their users, who must manually orchestrate multiple programs and learn multiple command-line interfaces.  The Rule of Parsimony therefore requires judgment—developers must balance the elegance of small, single-purpose tools against the practical usability of their systems.[4][1]

### Modern Application to Microservices

The principle of small programs extends naturally to modern architecture patterns.  Many contemporary web applications build their architecture as sets of services that communicate over the network layer, paralleling the Unix model of programs communicating via operating system primitives.  Microservices philosophy similarly advises building web architecture as sets of small services that can be easily reasoned about, operated, and evolved, demonstrating the continued relevance of the Rule of Parsimony to contemporary software design.[4]

### Integration with Other Principles

The Rule of Parsimony works alongside the Rule of Simplicity by encouraging developers to avoid unnecessary complexity and overhead.  Together with the Rule of Composition, which states that programs should be designed to work together, the Rule of Parsimony creates a philosophy where complex solutions emerge from the combination of elegant, minimal components rather than from monolithic design.  This approach supports the Rule of Clarity and Rule of Modularity by ensuring individual programs remain understandable and maintainable.[5][2]

Sources
[1] Basics of the Unix Philosophy http://www.catb.org/esr/writings/taoup/html/ch01s06.html
[2] 17 Principles of (Unix) Software Design https://paulvanderlaken.com/2019/09/17/17-principles-of-unix-software-design/
[3] Unix philosophy and its relevance today https://www.facebook.com/groups/retrocomputers/posts/24779261828343698/
[4] Small, Sharp Tools https://brandur.org/small-sharp-tools
[5] Basics of the Unix Philosophy from 'The Art ... https://gist.github.com/jiafulow/6fbfe0844a116c4cbfcf98da75ed495f
[6] "The Unix Philosophy" says create small functions that do ... https://www.reddit.com/r/functionalprogramming/comments/1awo4bf/the_unix_philosophy_says_create_small_functions/
[7] Essential Utility Programs for Everyday Computing https://utilityreview.net/uncategorized/utility-programs/
[8] Rules of the UNIX philosophy. - Squidtree https://www.squidtree.com/notes/rules-of-the-unix-philosophy/1154,1A
[9] Understanding the Unix Philosophy https://miikanissi.com/blog/understanding-unix-philosophy/
[10] 15 Excellent Examples of Utility Software | Techreviewer Blog https://techreviewer.co/blog/utility-software-15-excellent-examples-of-utility-software

