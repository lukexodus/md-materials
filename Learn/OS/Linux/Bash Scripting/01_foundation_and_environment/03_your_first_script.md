## Your First Script


### Creating Executable Scripts

A bash script is a text file containing a series of commands that the bash shell can execute. Scripts allow you to automate repetitive tasks, combine multiple commands, and create reusable programs.

To create your first script, use any text editor to create a file with a `.sh` extension (though the extension isn't required for execution):

```bash
# Create a new script file
touch myscript.sh

# Edit with your preferred editor
nano myscript.sh
# or
vim myscript.sh
# or
code myscript.sh
```

### Shebang Line (#!/bin/bash)

The shebang (hash-bang) line is the first line of your script that tells the system which interpreter to use for executing the script. It starts with `#!` followed by the path to the interpreter.

```bash
#!/bin/bash
# This is a comment
echo "Hello, World!"
echo "This is my first bash script"
```

Common shebang variations:

- `#!/bin/bash` - Uses the bash shell located at /bin/bash
- `#!/usr/bin/env bash` - Uses env to find bash in the PATH (more portable)
- `#!/bin/sh` - Uses the system's default shell (POSIX compliant)

The env approach is more portable because it doesn't hardcode the path to bash, making your script work across different systems where bash might be installed in different locations.

**Example** of a complete first script:

```bash
#!/bin/bash
# File: hello.sh
# Purpose: Demonstrate basic script structure

echo "Welcome to bash scripting!"
echo "Current date: $(date)"
echo "Current user: $(whoami)"
echo "Current directory: $(pwd)"
```

### Running Scripts

There are multiple ways to execute bash scripts, each with different implications:

#### Method 1: Direct Execution (./script.sh)

```bash
./myscript.sh
```

This method requires the script to be executable and uses the shebang line to determine the interpreter. The script must have execute permissions.

#### Method 2: Explicit Interpreter (bash script.sh)

```bash
bash myscript.sh
# or
sh myscript.sh
```

This method explicitly calls the bash interpreter and passes the script as an argument. The script doesn't need to be executable, and the shebang line is ignored.

#### Method 3: Source/Dot Command

```bash
source myscript.sh
# or
. myscript.sh
```

This executes the script in the current shell environment, meaning variables and functions defined in the script remain available after execution.

#### Method 4: Absolute Path

```bash
/full/path/to/myscript.sh
```

Run the script using its complete path, useful when the script isn't in your current directory or PATH.

**Key differences:**

- `./script.sh` - Creates a new process (subshell)
- `bash script.sh` - Creates a new process but ignores shebang
- `source script.sh` - Runs in current shell (no new process)

### Script Permissions and PATH

#### Understanding File Permissions

Before you can execute a script with `./script.sh`, it must have execute permissions. Use `ls -l` to check current permissions:

```bash
ls -l myscript.sh
-rw-r--r-- 1 user group 145 Jul 11 10:30 myscript.sh
```

The permission string `-rw-r--r--` breaks down as:

- First character: file type (`-` for regular file, `d` for directory)
- Next three: owner permissions (read, write, execute)
- Next three: group permissions
- Last three: other permissions

#### Setting Execute Permissions

Use `chmod` to add execute permissions:

```bash
# Add execute permission for owner
chmod +x myscript.sh

# Add execute permission for owner, group, and others
chmod 755 myscript.sh

# Add execute permission for owner only
chmod 744 myscript.sh
```

Common permission modes:

- `755` - Owner: read/write/execute, Group/Others: read/execute
- `744` - Owner: read/write/execute, Group/Others: read only
- `700` - Owner: read/write/execute, Group/Others: no permissions

#### Understanding PATH

The PATH environment variable contains a list of directories where the shell looks for executable files. When you type a command without specifying its full path, the shell searches through PATH directories.

```bash
# View current PATH
echo $PATH
/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin

# Check which directories are in PATH
echo $PATH | tr ':' '\n'
```

#### Adding Scripts to PATH

To run your scripts from anywhere without specifying the full path, you can:

1. **Move script to existing PATH directory:**

```bash
sudo mv myscript.sh /usr/local/bin/myscript
sudo chmod +x /usr/local/bin/myscript
```

2. **Add custom directory to PATH:**

```bash
# Create a personal bin directory
mkdir -p ~/bin
mv myscript.sh ~/bin/myscript
chmod +x ~/bin/myscript

# Add to PATH temporarily
export PATH=$PATH:~/bin

# Add to PATH permanently (add to ~/.bashrc or ~/.bash_profile)
echo 'export PATH=$PATH:~/bin' >> ~/.bashrc
source ~/.bashrc
```

3. **Create symbolic links:**

```bash
# Create a symlink in a PATH directory
sudo ln -s /full/path/to/myscript.sh /usr/local/bin/myscript
```

#### Best Practices for Script Location

- **Personal scripts:** `~/bin` or `~/.local/bin`
- **System-wide scripts:** `/usr/local/bin`
- **Administrative scripts:** `/usr/local/sbin`
- **Development scripts:** Keep in project directories

**Example** of setting up a personal scripts directory:

```bash
# Create and set up personal bin directory
mkdir -p ~/.local/bin
echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc
source ~/.bashrc

# Move your script and make it executable
cp myscript.sh ~/.local/bin/myscript
chmod +x ~/.local/bin/myscript

# Now you can run it from anywhere
myscript
```

### Security Considerations

- **Never add current directory (.) to PATH** - This is a security risk
- **Be careful with script permissions** - Don't make scripts world-writable
- **Validate script sources** - Only run scripts from trusted sources
- **Use full paths in scripts** - Avoid relying on PATH for critical operations

**Example** of a secure script setup:

```bash
#!/usr/bin/env bash
# Secure script template

# Exit on any error
set -e

# Exit on undefined variables
set -u

# Make functions inherit ERR trap
set -E

# Your script content here
echo "This script follows security best practices"
```

**Key points:**

- Always include a proper shebang line
- Make scripts executable with appropriate permissions
- Understand the difference between execution methods
- Organize scripts in appropriate directories
- Add personal script directories to PATH for convenience
- Follow security best practices for script permissions and execution

Understanding these fundamentals will provide a solid foundation for writing and deploying bash scripts effectively and securely.

---

