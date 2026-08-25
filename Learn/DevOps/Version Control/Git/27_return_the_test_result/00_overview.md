## Overview

exit $RESULT
```

The special exit code 125 tells Git to skip the current commit and move to another one.

**Example**

```
$ git bisect start HEAD v1.2.0
$ git bisect run ./test_for_bug.sh
running ./test_for_bug.sh
Bisecting: 112 revisions left to test after this (roughly 7 steps)
running ./test_for_bug.sh
Bisecting: 56 revisions left to test after this (roughly 6 steps)
running ./test_for_bug.sh
...
b6dd6a7c351e2f02b6746d2aed961f99e32cc441 is the first bad commit
commit b6dd6a7c351e2f02b6746d2aed961f99e32cc441
Author: Developer <dev@example.com>
Date:   Wed Oct 16 14:23:44 2024 -0400

    Add user authentication feature
bisect run success
```

### Understanding Bisect Logs

Git bisect maintains detailed logs of the search process, which can be useful for review, documentation, or sharing with team members.

#### Viewing the Bisect Log

During a bisect session, you can view the current log:

```
git bisect log
```

This command shows all steps taken so far in the bisect process:

```
