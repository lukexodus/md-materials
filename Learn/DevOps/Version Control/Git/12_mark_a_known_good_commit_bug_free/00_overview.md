## Overview

git bisect good v1.0
```

Git will automatically check out a commit halfway between the good and bad commits.

#### Iterating Through Commits

For each commit that Git checks out:

1. Test the code to determine if the bug exists
    
2. Mark the commit accordingly:
    
    ```
    # If the bug exists in this commit
    git bisect bad
    
    # If the bug doesn't exist in this commit
    git bisect good
    ```
    
3. Git will automatically check out the next commit to test
    
4. Continue until Git identifies the first bad commit
    

#### Completing the Process

When Git finds the first bad commit, it will display information about that commit:

```
b6dd6a7c351e2f02b6746d2aed961f99e32cc441 is the first bad commit
commit b6dd6a7c351e2f02b6746d2aed961f99e32cc441
Author: Developer <dev@example.com>
Date:   Wed Oct 16 14:23:44 2024 -0400

    Add user authentication feature
```

To end the bisect session:

```
git bisect reset
```

This command returns to the original branch and state.

**Example**

```
$ git bisect start
$ git bisect bad
$ git bisect good v1.2.0
Bisecting: 112 revisions left to test after this (roughly 7 steps)
[75bcd9... ] checkout: moving from master to 75bcd9...

