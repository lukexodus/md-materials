## Rule of Representation


The **Rule of Representation** is one of the 17 core Unix design principles, which states: "fold knowledge into data rather than code" so that program logic can be stupid and robust.[1][2]

### Core Concept

This principle means that instead of encoding complex decision logic and business rules directly into your program's code, you should store that knowledge as data that your program can read and interpret.  The key advantage is that your actual program logic becomes simpler, more maintainable, and less error-prone, since the data—rather than the code—drives the program's behavior.[3][1]

### Practical Applications

In data-driven programming, the data itself controls the flow and behavior of the program rather than hardcoded conditional logic.  For example, instead of writing separate code for different game variations with different prompts and outputs, you can define each game's behavior in a JSON data structure and write generic code that interprets that data.  This approach means you can create new variations simply by changing the data files, without modifying the underlying code at all.[4]

### Relationship to Other Principles

The Rule of Representation works alongside other Unix philosophy tenets like the **Rule of Clarity** (write clear code over clever code) and **Rule of Simplicity** (design for minimum complexity).  By moving complexity from code into data, you create more transparent systems that are easier to understand and maintain.  The philosophy also values **Store Data in Flat Text Files**, which enables this knowledge-in-data approach by making that data human-readable and easily composable with other Unix tools.[5][1]

### Modern Relevance

This principle continues to influence modern software architecture frameworks like **CUPID** (Composable, Unix philosophy, Predictable, Idiomatic, Domain-based), which explicitly incorporates Unix philosophy alongside contemporary best practices.  The data-driven approach reduces technical debt by preventing complex hardcoded logic that creates bugs and makes systems difficult to modify.[1]

Sources
[1] Unix Philosophy and Timeless Software Architecture Patterns That ... https://www.softwareseni.com/unix-philosophy-and-timeless-software-architecture-patterns-that-transcend-technology-eras/
[2] Basics of the Unix Philosophy from 'The Art of Unix Programming" by ... https://gist.github.com/jiafulow/6fbfe0844a116c4cbfcf98da75ed495f
[3] Data-Driven Programming - catb. Org http://www.catb.org/esr/writings/taoup/html/ch09s01.html
[4] What is data-driven programming? - Stack Overflow https://stackoverflow.com/questions/1065584/what-is-data-driven-programming
[5] How the 9 major tenets of the Linux philosophy affect you https://opensource.com/business/15/2/how-linux-philosophy-affects-you
[6] The Basics of the Unix Philosophy : r/programming - Reddit https://www.reddit.com/r/programming/comments/77rk0d/the_basics_of_the_unix_philosophy/
[7] Deconstructing the "Unix philosophy" - Ted Kaminski https://www.tedinski.com/2018/05/08/case-study-unix-philosophy.html
[8] Why code-as-data? - Stack Overflow https://stackoverflow.com/questions/4140727/why-code-as-data
[9] Unix philosophy and its relevance today - Facebook https://www.facebook.com/groups/retrocomputers/posts/24779261828343698/
[10] Unix philosophy - Wikipedia https://en.wikipedia.org/wiki/Unix_philosophy

