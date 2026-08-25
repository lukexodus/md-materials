## Rule of Silence 


The **Rule of Silence** (also known as "Silence is Golden") is a fundamental design principle of Unix philosophy stating that when a program has nothing interesting, surprising, or useful to say, it should remain silent.  Well-behaved Unix programs do their jobs unobtrusively, with a minimum of fuss and bother, treating the user's attention and concentration as a precious and limited resource.[1][2]

### Core Principle

The rule dictates that programs should only communicate important information and avoid cluttering output with unnecessary messages.  This means successful operations typically produce no output, while only errors or important results are displayed.  For example, Unix commands like `touch`, `cp`, and `rm` typically produce no output when they execute successfully—silence indicates everything worked as intended.[3][4]

### Historical Origins

The Rule of Silence evolved because Unix predates modern video displays.  On slow printing terminals in 1969, each line of unnecessary output was a serious drain on the user's time and resources.  Although screen limitations are no longer a primary concern, excellent reasons for terseness and silence remain.[2]

### Reasons for Silence

Several important reasons justify this principle.  First, unnecessary information can distract users and clutter their minds with data that might not be needed or desired.  Second, avoiding screen clutter conserves valuable display space, which remains limited in some special situations.  Third, and most critically for Unix systems, command-line programs are designed to work together through pipes, where one program's output becomes another program's input—therefore, only truly important information should be included in output to avoid corrupting downstream data.[3][1]

### Information Remains Available

The Rule of Silence does not mean less information is available to users.  Instead, by default, programs simply do not provide information likely to be unnecessary in most situations.  However, users can access detailed information through options, commonly the `-v` (verbose) flag, which allows programs to display additional details when explicitly requested.[1][3]

### Application Beyond Command-Line

Although the Rule of Silence originally applied to command-line programs, it applies equally to graphical user interfaces (GUIs).  Unnecessary and annoying information should be avoided regardless of interface type—for example, dialog boxes containing obvious, cryptic, or unnecessary messages should only appear when unexpected results occur or important data needs protection.[1]

Sources
[1] The Rule of Silence (Silence is Golden) - Linux https://marquesfernandes.com/en/technology/the-rule-of-silence-silence-and-gold-linux/
[2] Rule of Silence: When a program has nothing surprising - Linuxtopia https://www.linuxtopia.org/online_books/programming_books/art_of_unix_programming/ch01s06_10.html
[3] The Rule of Silence https://www.linfo.org/rule_of_silence.html
[4] The Rule of Silence in Unix: A Simple Principle for Cleaner Code ... https://www.linkedin.com/pulse/rule-silence-unix-simple-principle-cleaner-code-perhaps-life-he5tc
[5] The Rule of Silence (2006) https://news.ycombinator.com/item?id=13165517
[6] Unix philosophy https://en.wikipedia.org/wiki/Unix_philosophy
[7] Unix philosophy and its relevance today https://www.facebook.com/groups/retrocomputers/posts/24779261828343698/
[8] 12 Computer Communication Types You May Use at Work https://www.indeed.com/career-advice/career-development/computer-communications-types
[9] The Art of Unix Programming http://www.catb.org/esr/writings/taoup/html/
[10] Communication between programs : r/computerscience https://www.reddit.com/r/computerscience/comments/1d7pr2x/communication_between_programs/

