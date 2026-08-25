## Rule of Optimization 


The **Rule of Optimization** is a core Unix philosophy principle stating that programmers should prototype before polishing and get software working before optimizing it.  This rule emphasizes the fundamental insight that "90% of the functionality delivered now is better than 100% of it delivered never," reflecting the wisdom that premature optimization wastes resources on speculation rather than solving actual problems.[1][2]

### The Problem with Premature Optimization

Premature optimization is widely recognized as "the root of all evil," a principle famously popularized by Donald Knuth, author of The Art of Computer Programming.  Rushing to optimize before bottlenecks are known may be the only error to have ruined more designs than feature creep.  Premature local optimization disturbingly often actually hinders global optimization, reducing overall performance while producing inferior results.  A prematurely optimized portion of a design frequently interferes with changes that would have much higher payoffs across the whole design, resulting in both inferior performance and excessively complex code.[2][3]

### The Prototyping Approach

The Unix tradition advocates a clear three-stage approach that Kent Beck later amplified as: **"Make it run, then make it right, then make it fast."**  This methodology recognizes that getting your design right with an un-optimized, slow, memory-intensive implementation is essential before attempting to tune performance.  Only after you have a working prototype should you tune systematically, looking for places where you can buy big performance wins with the smallest possible increases in local complexity.[2]

### Benefits of Prototype-First Development

Prototyping serves multiple crucial functions beyond optimization considerations.  It is much easier to judge whether a prototype does what you want than it is to read a long specification, making prototyping essential for system design as well.  Using prototyping to learn which features you don't have to implement helps optimization for performance—you don't have to optimize what you don't write.  Gathering early feedback through prototypes makes it easier and cheaper to make necessary changes at the start rather than months down the line after full development.[4][1][2]

### The Power of Deletion

One of the most powerful optimization tools available is the delete key itself.  By validating what you actually need through prototyping, you eliminate entire features and code paths that waste both machine resources and programmer time.  This aligns directly with the Rule of Economy, as deleting unnecessary code is often more effective than optimizing essential code.[1][2]

### Measurement Before Optimization

When optimization becomes necessary, profiling and measurement must guide the effort rather than speculation.  Don't optimize until you have proof that performance is a bottleneck, and when you do optimize, attack the parts which take the most time based on measured data.  This data-driven approach ensures that optimization efforts address actual problems rather than imagined ones.[3][5]

Sources
[1] Always revisit this page when in doubt; The Basics of UNIX ... https://dev.to/harshbanthiya/always-revisit-this-page-when-in-doubt-the-basics-of-unix-philosophy-45k9
[2] Basics of the Unix Philosophy - Rule of Optimization https://www.linuxtopia.org/online_books/programming_books/art_of_unix_programming/ch01s06_14.html
[3] Philosophy of System Implementation | by Jayanth Kumar https://blog.jaykmr.com/philosophy-of-systems-implementation-a24ec5233cf4
[4] The First Step in Custom Software Development - iTech India https://itechindia.co/us/blog/software-prototype-for-software-development/
[5] When is optimisation premature? [closed] https://stackoverflow.com/questions/385506/when-is-optimisation-premature
[6] Unix philosophy and its relevance today https://www.facebook.com/groups/retrocomputers/posts/24779261828343698/
[7] The fallacy of premature optimization rears its ugly head ... https://news.ycombinator.com/item?id=29228427
[8] Laws of Programming - Barış Özmen https://bozmen.io/laws
[9] What is premature optimization? : r/gamedev https://www.reddit.com/r/gamedev/comments/p1g52d/what_is_premature_optimization/
[10] Prototyping In Software Design https://www.meegle.com/en_us/topics/software-lifecycle/prototyping-in-software-design

