## Overview

git bisect bad 3f8b2c...
```

#### Saving the Bisect Log

To save the log to a file:

```
git bisect log > bisect_results.txt
```

This creates a text file with the full bisect session history.

#### Replaying a Bisect Session

You can use a saved log to replay a bisect session:

```
