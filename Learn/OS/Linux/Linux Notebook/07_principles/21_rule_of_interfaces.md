## Rule of Interfaces


The **Rule of Interfaces**, also known as "Avoid Captive User Interfaces," is a core Unix philosophy principle stating that you should avoid designing interfaces that trap users in interactive sessions.  A captive user interface (CUI) requires users to communicate with a program in an interactive session before returning to the command interpreter, preventing programs from working together seamlessly.[1][2]

### Understanding Captive Interfaces

A **captive user interface** is a style of interaction where an application traps the user until completion, preventing communication with the command interpreter until the application exits.  Examples include programs that prompt for input one item at a time, forcing users to navigate through menus or dialogs before regaining control of the shell.  Once you invoke a CUI program, you cannot interact with other programs or the shell until you explicitly exit the application.[3][2]

### Unix-Style Non-Captive Interfaces

In contrast, Unix-style non-captive interfaces accept arguments directly from the command line and complete their tasks without requiring interactive prompts.  Each program completes its task at the shell prompt level, returning control immediately to the command interpreter so users can chain multiple commands together.  Users need to learn only one language—the shell—rather than multiple specialized interfaces for different programs.[2]

### Problems with Captive Interfaces

Captive interfaces fundamentally undermine Unix composition and leverage by preventing multiple commands from working together.  Commands cannot be easily piped together or scripted when they require interactive user input.  CUIs force the assumption that a person sits at the keyboard ready to respond to prompts, making automation and composition impossible.  This design approach directly contradicts the Unix philosophy's emphasis on programs working together and data flowing between components.[2]

### GUI Scalability Issues

Graphical user interfaces (GUIs) suffer from similar problems to CUIs, particularly regarding scalability and software leverage.  Clicking the mouse several times to perform an operation is practical, but repeating the same operation thousands of times becomes tedious and forces users to realize the computer controls them rather than vice versa.  GUIs do not take advantage of software leverage—scripting GUI operations requires resort to fragile record-and-playback programs that capture mouse and keyboard events, which often fail when unexpected output requires user decisions.[2]

### Supporting Composability and Scripting

Non-captive interfaces enable composability and scripting by allowing programs to accept all necessary information as command-line arguments or configuration files.  This design philosophy allows programs to operate autonomously within scripts and pipelines, enabling developers to combine multiple programs into powerful workflows.  Programs designed this way become true building blocks in the Unix ecosystem, maximizing their reusability across diverse contexts.[1][2]

### Connection to Other Principles

The Rule of Interfaces supports the Rule of Composition by ensuring programs can be easily combined without user intervention.  It complements the Rule of Leverage by enabling automation and scripting through non-captive design.  The principle also aligns with the Rule of Simplicity and Rule of Clarity by creating straightforward interaction models that users can understand and program against.[1][2]

Sources
[1] The UNIX Philosophy in 2019 - Jason Eckert's Website and Blog https://jasoneckert.github.io/myblog/the-unix-philosophy-in-2019/
[2] Tenet 8: Avoid captive user interfaces https://flylib.com/books/en/2.506.1.34/1/
[3] Captive User Interfaces — Why You Should Avoid Them https://blog.finxter.com/captive-user-interfaces-why-you-should-avoid-them/
[4] Unix philosophy https://en.wikipedia.org/wiki/Unix_philosophy
[5] Unix philosophy and its relevance today https://www.facebook.com/groups/retrocomputers/posts/24779261828343698/
[6] A Few Rules of the Unix Philosophy https://dev.to/chrisf1031/a-few-rules-of-the-unix-philosophy-f0p
[7] Basics of the Unix Philosophy from 'The Art ... https://gist.github.com/jiafulow/6fbfe0844a116c4cbfcf98da75ed495f
[8] Rules of the UNIX philosophy. - Squidtree https://www.squidtree.com/notes/rules-of-the-unix-philosophy/1154,1A
[9] The Unix Philosophy: A Brief Introduction https://www.linfo.org/unix_philosophy.html
[10] 2.7 Example 4: The UNIX philosophy https://web.mit.edu/6.055/old/S2009/notes/unix.pdf

