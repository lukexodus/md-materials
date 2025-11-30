The most effective programmer or engineer is not the one who can use a lot of programming languages, framworks, libraries, or systems, but rather the one who understands how each of them works, especially at the lowest level, and if necessary, he can himself create a language/system/framework/library that is specifically suited to a problem he is trying to solve.

In this, he values the knowledge of how things work in the lowest levels. He is always thinking of how to best bridge the gap or link the capabilities of a computer into how it can best solve a problem at a high level.

He is not content into knowing just how things work on the high level. He knows that there will always be edge cases in which it is essential to know what specific low-level mechanisms to use in order to solve the edge cases.

Since he is knowledgeable about the low-level mechanisms, he doesn't produce hacks or makeshift solutions, but rather he can capably conceive and create intricate but practical mechanisms or solutions and can discerningly choose and utilize the computer capabilities that are already available to solve a particular problem.

He can effectively use different computer mechanisms and capabilities together in way that produces the results he wants to achieve.

He is not only learning how to use the tools to solve problems. He is also learning how those tools work, and if necessary, modifies or improves them to better make them more effective as tools in solving problems.

***

## Medium

The Engineer plans and writes software that balances stability and change.

##### Stability
Most people understand the main concepts of stability: The first concept is that software should do what it is supposed to do. It shouldn’t be buggy. It should be reliable. The second concept is that the way the software is used should not change rapidly and frequently. That’s, true in two senses: the interface should be relatively stable over time, and the interface should be consistent across the software.

##### Change
The Engineer writes software in a way that accommodates change. More precisely, the Engineer is able to anticipate the way their software will likely need to change, and writes accordingly.

**Bugs**. The Engineer assumes that every piece of software they produce has something wrong with it. In order to change (fix) the bug, code should be organized, be highly readable, and use logging. I won’t go in depth here. At a minimum, the Engineer knows how to organize code into reusable blocks, whether those are functions or classes, and knows how to loosely couple those blocks of code so that bugs are as isolated as possible and require a limited number of changes.

Plan your software to deal with changes (data, behavior, ...) via abstraction rather than hard-coding.

**Extension**. In some scenarios, the use case changes significantly beyond what you were either expecting or beyond what you are willing to support. Continuing our example case, maybe you don’t want to support a data loader for blob storage from every different cloud provider. If you’ve clearly defined the interface for loading data, you don’t have to. Downstream developers can still use your software to import data from S3 by writing code that implements the interface, so long as you’ve left that opportunity open to them. There are a number of ways to do this and a number of concepts that can help (inheritance, injection, generics, even duck typing). The Engineer is able to write software that can be extended beyond what they can plan for.