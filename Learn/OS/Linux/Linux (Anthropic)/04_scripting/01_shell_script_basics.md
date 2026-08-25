## Shell Script Basics


### Shebang and Script Structure

The shebang (`#!`) is the first line in a shell script that tells the system which interpreter to use for executing the script. It consists of a hash symbol followed by an exclamation mark and the path to the interpreter.

**Common shebang examples:**

- `#!/bin/bash` - Uses the Bash shell
- `#!/bin/sh` - Uses the system's default shell (usually dash or bash)
- `#!/usr/bin/env bash` - Uses env to find bash in the PATH (more portable)
- `#!/bin/zsh` - Uses the Z shell

**Basic script structure:**

```bash
#!/bin/bash
# Script description and metadata
# Author: Your name
# Date: Creation date
# Version: Script version

# Script body starts here
echo "Hello, World!"
```

**Key points:**

- The shebang must be the absolute first line with no preceding whitespace
- Comments begin with `#` (except for the shebang line)
- Proper documentation improves script maintainability
- Scripts should have a logical flow: setup, main logic, cleanup

### Variables and Assignment

Shell variables store data that can be referenced and manipulated throughout the script. Variable assignment in shell scripting follows specific syntax rules.

**Variable assignment syntax:**

```bash
# Correct assignment (no spaces around =)
variable_name="value"
NUMBER=42
PATH_TO_FILE="/home/user/document.txt"

# Incorrect (will cause errors)
# variable_name = "value"  # Spaces around = not allowed
```

**Variable naming conventions:**

- Use lowercase for local variables
- Use UPPERCASE for environment variables and constants
- Use underscores to separate words
- Start with letters or underscores, not numbers
- Avoid special characters except underscores

**Variable types and usage:**

```bash
# String variables
NAME="John Doe"
MESSAGE='Hello World'

# Numeric variables (treated as strings but can be used in arithmetic)
COUNT=10
PRICE=29.99

# Array variables (bash-specific)
FRUITS=("apple" "banana" "cherry")
NUMBERS=(1 2 3 4 5)

# Command substitution
CURRENT_DATE=$(date)
USER_COUNT=`who | wc -l`  # Backticks (older syntax)
```

**Variable expansion and quoting:**

```bash
# Basic expansion
echo $NAME
echo ${NAME}  # Preferred for clarity

# Double quotes preserve variable expansion
echo "Hello, $NAME"

# Single quotes prevent variable expansion
echo 'Hello, $NAME'  # Outputs: Hello, $NAME

# Parameter expansion examples
echo ${NAME:-"Default"}  # Use default if NAME is unset
echo ${#NAME}            # Length of variable
echo ${NAME:0:3}         # Substring (first 3 characters)
```

### Environment Variables

Environment variables are system-wide variables that affect the behavior of processes and applications. They can be inherited by child processes and are available to all programs run from the shell.

**Common environment variables:**

- `PATH` - Directories searched for executable commands
- `HOME` - User's home directory
- `USER` or `USERNAME` - Current user's name
- `SHELL` - Path to the current shell
- `PWD` - Current working directory
- `OLDPWD` - Previous working directory
- `PS1` - Primary shell prompt
- `IFS` - Internal Field Separator

**Viewing environment variables:**

```bash
# Display all environment variables
env
printenv

# Display specific variable
echo $PATH
printenv PATH

# Display with default value if unset
echo ${CUSTOM_VAR:-"Not set"}
```

**Setting environment variables:**

```bash
# Set for current session only
export MY_VAR="value"

# Set temporarily for a single command
MY_VAR="value" command

# Set in script (available to child processes)
export DATABASE_URL="postgresql://localhost:5432/mydb"

# Unset a variable
unset MY_VAR
```

**Making variables persistent:**

```bash
# Add to ~/.bashrc for user-specific variables
echo 'export MY_CUSTOM_PATH="/opt/myapp/bin"' >> ~/.bashrc

# Add to /etc/environment for system-wide variables (Ubuntu/Debian)
echo 'JAVA_HOME="/usr/lib/jvm/java-11-openjdk"' | sudo tee -a /etc/environment

# Add to ~/.profile for POSIX-compliant shells
echo 'export EDITOR=vim' >> ~/.profile
```

**Key points:**

- Environment variables are inherited by child processes
- Use `export` to make variables available to subprocesses
- Variable names are case-sensitive
- System environment variables typically use UPPERCASE names
- Changes to shell configuration files require sourcing or new session to take effect

### Script Execution Methods

There are several ways to execute shell scripts, each with different implications for variable scope, process creation, and security.

**Making scripts executable:**

```bash
# Add execute permission for owner
chmod +x script.sh

# Add execute permission for all users
chmod 755 script.sh

# Check permissions
ls -l script.sh
```

**Direct execution methods:**

```bash
# Execute with explicit interpreter
bash script.sh
sh script.sh
zsh script.sh

# Execute as executable (requires shebang and execute permissions)
./script.sh
/full/path/to/script.sh

# Execute from PATH (if script is in a PATH directory)
script.sh  # Assumes script.sh is in PATH and executable
```

**Sourcing vs executing:**

```bash
# Execute in subshell (default behavior)
./script.sh
bash script.sh

# Source in current shell (variables persist)
source script.sh
. script.sh  # POSIX-compliant alternative
```

**Process behavior differences:**

- **Subshell execution**: Creates new process, variables don't affect parent shell
- **Sourcing**: Runs in current shell, variables and functions persist after completion
- **Background execution**: Use `&` to run scripts in background

**Security considerations:**

```bash
# Check script before execution
file script.sh
head -n 10 script.sh

# Execute with restricted permissions
bash -r script.sh  # Restricted mode

# Execute with debugging
bash -x script.sh  # Show commands as they execute
bash -n script.sh  # Syntax check without execution
```

**Advanced execution options:**

```bash
# Execute with timeout
timeout 30s ./long_running_script.sh

# Execute with different user (requires sudo)
sudo -u username ./script.sh

# Execute with modified environment
env -i PATH=/usr/bin:/bin ./script.sh  # Clean environment

# Execute and capture output
OUTPUT=$(./script.sh)
./script.sh > output.log 2>&1  # Redirect stdout and stderr
```

**Key points:**

- Scripts need execute permissions to run directly with `./script.sh`
- Sourcing executes in current shell context, affecting environment
- Subshell execution isolates the script's environment changes
- Always verify script permissions and content before execution
- Use appropriate execution method based on whether you need persistent environment changes

**Next steps:** Understanding command-line arguments, conditional statements, loops, and functions will build upon these shell scripting fundamentals.

---

