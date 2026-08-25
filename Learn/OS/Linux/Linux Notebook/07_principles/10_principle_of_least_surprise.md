## Principle of Least Surprise


The **Principle of Least Surprise** (also called the Principle of Least Astonishment) is a design philosophy stating that a component of a system should behave in a way that most users expect it to behave, and therefore should not astonish or surprise them.  This principle is foundational to Unix philosophy and was formalized in The Art of Unix Programming by Eric Steven Raymond, who stated: "In interface design, always do the least surprising thing."[1][5]

### Core Concept

The principle proposes that every construct in a system should behave exactly as its syntax suggests, and widely accepted conventions should be followed whenever possible.  Users should be able to anticipate system behavior based on their previous experiences with similar systems, and the behavior must remain consistent with the user's expectations.[2][1]

### Application in Interface Design

In user interface design, the principle ensures that applications behave intuitively and predictably.  For example, when a user clicks a "Save" button, they expect the system to save their work—not discard or delete it.  To minimize learning burden and entry barriers, designers should think carefully about users' existing experiences and mimic relevant parts of familiar interfaces rather than creating entirely novel interface models.[4][5]

### Application in Software and API Design

In software development, the principle applies to classes, methods, functions, and API calls.  A method named `add(int a, int b)` should return the sum of the two numbers, not their product, as anything else would be surprising and cause defects.  Methods should use clear, obvious names with expected return types and should never have unexpected side effects.  The Command-Query Separation principle complements this concept by ensuring that query methods only retrieve data without modifying state.[5]

### Place in Unix Philosophy

The Rule of Least Surprise is one of 17 core principles of Unix philosophy.  It exists alongside other important rules such as clarity, simplicity, transparency, and robustness.  The principle emphasizes that behavior should be predictable and consistent, avoiding unexpected behavior that would frustrate users and reduce system usability.[6][7]

Sources
[1] Principle of least astonishment https://en.wikipedia.org/wiki/Principle_of_least_astonishment
[2] Principle Of Least Surprise (PLS) http://principles-wiki.net/principles:principle_of_least_surprise
[3] Unix philosophy and its relevance today https://www.facebook.com/groups/retrocomputers/posts/24779261828343698/
[4] Applying the Rule of Least Surprise http://www.catb.org/esr/writings/taoup/html/ch11s01.html
[5] The Principle of Least Surprise • 2025 https://incusdata.com/blog/the-principle-of-least-surprise
[6] Basics of the Unix Philosophy from 'The Art ... https://gist.github.com/jiafulow/6fbfe0844a116c4cbfcf98da75ed495f
[7] Unix Philosophy https://www.linkedin.com/pulse/unix-philosophy-mike-niner-suj5f
[8] Unix Philosophy and Timeless Software Architecture Patterns ... https://www.softwareseni.com/unix-philosophy-and-timeless-software-architecture-patterns-that-transcend-technology-eras/

