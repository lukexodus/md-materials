## Rule of Generation


The **Rule of Generation** is a core Unix philosophy principle stating that programmers should avoid hand-hacking and instead write programs to write programs when you can.  This rule represents an early form of automation, encouraging developers to use code generation tools rather than manually writing repetitive or formulaic code.[1][2]

### Core Concept

The Rule of Generation recognizes that writing code to generate code is often more efficient than manually writing similar code multiple times.  This principle reflects the broader Unix philosophy emphasis on building tools and using those tools to solve problems, even if building the tools requires a detour.  By automating code generation, developers conserve programmer time—their most expensive resource—while reducing the likelihood of human error.[3][4][2]

### Historical Tools and Examples

Unix has a long-standing tradition of hosting tools specifically designed to generate code for various special purposes.  The venerable code generation tools `lex` and `yacc` go back to Version 7 Unix and were actually used to write the original Portable C Compiler in the 1970s.  Modern successors like `flex` and `bison` remain part of the GNU toolkit and are still heavily used today for generating language parsers.[5]

### Parser Generators

Parser generators exemplify the Rule of Generation in practice.  The `yacc` tool was written to automate part of the job of writing compilers by taking as input a grammar specification in a declarative minilanguage resembling BNF (Backus-Naur Form) with associated code.  The combination of `lex` and `yacc` is very effective for writing language interpreters of all kinds and is extremely useful for writing parsers for run-control file syntaxes and domain-specific minilanguages.[5]

### Modern Applications

The Rule of Generation extends beyond traditional compiler tools to modern software development.  Projects like GNOME's Glade interface builder exemplify this principle by generating code in multiple target languages from declarative specifications, rather than requiring developers to write boilerplate code manually.  The separation of declarative data formats from code generators allows the same specification to produce code in different languages, demonstrating how automated generation conserves programmer effort across multiple implementations.[5]

### Practical Benefits

Following the Rule of Generation reduces manual labor, decreases maintenance and debugging time, and improves consistency across generated code.  When you avoid implementing a complex parser or similar algorithmic task by hand, you eliminate entire classes of bugs that arise from manual implementation.  This approach aligns with the Rule of Economy by directly trading machine cycles (running the code generator) for precious programmer time.[4][6][5]

Sources
[1] Basics of the Unix Philosophy from 'The Art ... https://gist.github.com/jiafulow/6fbfe0844a116c4cbfcf98da75ed495f
[2] A Few Rules of the Unix Philosophy https://dev.to/chrisf1031/a-few-rules-of-the-unix-philosophy-f0p
[3] Unix philosophy https://en.wikipedia.org/wiki/Unix_philosophy
[4] Unix philosophy and its relevance today https://www.facebook.com/groups/retrocomputers/posts/24779261828343698/
[5] Special-Purpose Code Generators http://rus-linux.net/MyLDP/BOOKS/ArtProgr/ch15s03.html
[6] Unix Philosophy and Timeless Software Architecture Patterns ... https://www.softwareseni.com/unix-philosophy-and-timeless-software-architecture-patterns-that-transcend-technology-eras/
[7] How does the Unix Philosophy matter in modern times? https://www.reddit.com/r/linux/comments/mjmfd1/how_does_the_unix_philosophy_matter_in_modern/
[8] Deconstructing the "Unix philosophy" - Ted Kaminski https://www.tedinski.com/2018/05/08/case-study-unix-philosophy.html
[9] The Art of Unix Programming https://cdn.nakamotoinstitute.org/docs/taoup.pdf
[10] Where the Unix philosophy breaks down https://www.johndcook.com/blog/2010/06/30/where-the-unix-philosophy-breaks-down/

