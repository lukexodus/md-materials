## Rule of Composition


The **Rule of Composition** is a foundational Unix philosophy principle stating that you should design programs to be connected to other programs.  This rule emphasizes that software should be built as modular, independent components that work seamlessly together rather than as monolithic systems that attempt to handle all tasks internally.[1][2]

### Core Concept

The Rule of Composition reflects one of Unix's most distinctive characteristics—the ability to combine simple, single-purpose tools to solve complex problems.  Rather than building one large, all-encompassing program, developers should create programs that handle specific tasks well and can be easily connected with other programs through standard interfaces.  This approach enables tremendous flexibility and power through the combination of relatively simple building blocks.[3][4][1]

### Enabling Program Interconnection

The Unix philosophy explicitly states that programs should expect the output of every program to become the input to another, as yet unknown, program.  This principle led to the development of standard text streams and pipes as the primary means of connecting programs, allowing data to flow seamlessly from one program's output to another's input.  Because programs must work together, they should avoid cluttering output with extraneous information and should handle text streams as a universal interface.[1]

### Composability as a Design Pattern

Composability is the software design method where developers combine and reuse smaller, self-contained components to create complex systems.  The bedrock of composable systems rests on several foundational principles: **modularity** breaks complex systems into smaller, independent modules that can be reused in different systems; **interoperability** ensures that various components can communicate and share data seamlessly through common protocols and standards; **loose coupling** keeps components separate through clearly defined interfaces, avoiding direct links that would create dependencies; and **standardization** establishes shared practices, protocols, and interfaces that enable components from diverse sources to interoperate.[5]

### Benefits of Composition

Composition enables **accelerated development** by allowing developers to assemble applications from pre-built, tested components, significantly reducing development time for complex applications.  It supports **parallel development**, as different teams can work on different components simultaneously without creating dependencies or bottlenecks, enhancing productivity and collaboration.  **Component reusability** reduces the need to write new code for every feature, saving time and resources by leveraging existing modules across different parts of an application or even in different projects.  **Flexibility and adaptability** make it easier to modify, replace, or extend individual components without overhauling the entire system, enabling quick implementation of new features and responsive adaptation to changing requirements.[5]

### Architecture for Team Scaling

The Rule of Composition supports team scaling through modularity, enabling parallel development when systems are broken into independent components with clear boundaries.  Clear interfaces between components reduce coordination overhead—when teams work through well-defined APIs, they do not need constant synchronization.  This approach aligns with Conway's Law, which states that system architecture mirrors organizational structure; Unix-style modular systems are a natural fit for multi-team organizations where each team owns a bounded context with clear boundaries.[6]

Sources
[1] Unix philosophy https://en.wikipedia.org/wiki/Unix_philosophy
[2] Basics of the Unix Philosophy from 'The Art ... https://gist.github.com/jiafulow/6fbfe0844a116c4cbfcf98da75ed495f
[3] The Rule of Composition https://www.linfo.org/rule_of_composition.html
[4] A Few Rules of the Unix Philosophy https://dev.to/chrisf1031/a-few-rules-of-the-unix-philosophy-f0p
[5] What is composability? - Mulesoft https://www.mulesoft.com/integration/what-is-composability
[6] Unix Philosophy and Timeless Software Architecture Patterns ... https://www.softwareseni.com/unix-philosophy-and-timeless-software-architecture-patterns-that-transcend-technology-eras/
[7] Unix philosophy and its relevance today https://www.facebook.com/groups/retrocomputers/posts/24779261828343698/
[8] Rules of the UNIX philosophy. - Squidtree https://www.squidtree.com/notes/rules-of-the-unix-philosophy/1154,1A
[9] Understanding composability: Definitions and explanations https://www.contentful.com/blog/what-is-composability/
[10] 17 Principles of (Unix) Software Design https://paulvanderlaken.com/2019/09/17/17-principles-of-unix-software-design/


