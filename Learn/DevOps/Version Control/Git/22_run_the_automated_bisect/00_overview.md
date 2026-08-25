## Overview

git bisect run ./test_script.sh
```

Git will run through the entire process automatically, executing your test script at each step and marking commits based on the script's exit code.

#### Complex Test Scripts

Test scripts can be much more sophisticated, including:

- Build steps before testing
- Multiple test conditions
- Environment setup and teardown
- Timeout handling
- Result logging

```bash
#!/bin/bash
