## `pyenv`


### What is pyenv?

pyenv is a Python version management tool that lets you easily install, switch between, and manage multiple Python versions on your machine. It's especially useful when working on different projects that require different Python versions.

### Installation

**macOS (using Homebrew):**

```bash
brew install pyenv
```

**Linux/macOS (using the installer):**

```bash
curl https://pyenv.run | bash
```

**Manual installation:**

```bash
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
```

After installation, add these lines to your shell configuration file (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
```

Then restart your shell or run `source ~/.bashrc` (or your shell config file).

### Core Commands

#### Installing Python versions

```bash
# List available Python versions
pyenv install --list

# Install a specific version
pyenv install 3.11.5
pyenv install 3.12.0

# Install the latest version of a series
pyenv install 3.11:latest
```

#### Managing versions

```bash
# List installed versions
pyenv versions

# Set global Python version (system-wide default)
pyenv global 3.11.5

# Set local Python version (for current directory/project)
pyenv local 3.12.0

# Set shell Python version (for current shell session)
pyenv shell 3.10.8

# Check current Python version
pyenv version

# Show which pyenv provided the current python
pyenv which python
```

#### Removing versions

```bash
# Uninstall a Python version
pyenv uninstall 3.9.16
```

### Understanding pyenv's Priority System

pyenv determines which Python version to use in this order:

1. **Shell**: Set with `pyenv shell` (highest priority)
2. **Local**: Set with `pyenv local` (creates `.python-version` file)
3. **Global**: Set with `pyenv global`
4. **System**: Your system's default Python (lowest priority)

### Working with Projects

The most common workflow is setting local versions for projects:

```bash
# Navigate to your project
cd my-project

# Set Python version for this project
pyenv local 3.11.5

# This creates a .python-version file
cat .python-version  # Shows: 3.11.5
```

Now whenever you're in this directory, pyenv automatically uses Python 3.11.5.

### Integration with Virtual Environments

pyenv works great with virtual environments:

```bash
# Set project Python version
cd my-project
pyenv local 3.11.5

# Create virtual environment
python -m venv venv

# Activate virtual environment
source venv/bin/activate  # Linux/macOS
# or
venv\Scripts\activate     # Windows
```

### Advanced Features

#### pyenv-virtualenv Plugin

Install pyenv-virtualenv for enhanced virtual environment management:

```bash
# Install via Homebrew (macOS)
brew install pyenv-virtualenv

# Or clone manually
git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
```

Add to your shell config:

```bash
eval "$(pyenv virtualenv-init -)"
```

Then you can:

```bash
# Create a virtual environment
pyenv virtualenv 3.11.5 myproject-env

# Activate it
pyenv activate myproject-env

# Set it as local for a project
pyenv local myproject-env

# List virtual environments
pyenv virtualenvs

# Deactivate
pyenv deactivate

# Delete virtual environment
pyenv uninstall myproject-env
```

### Troubleshooting Common Issues

#### Build dependencies missing

On Ubuntu/Debian:

```bash
sudo apt update
sudo apt install build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev \
liblzma-dev python3-openssl git
```

On CentOS/RHEL:

```bash
sudo yum groupinstall "Development Tools"
sudo yum install openssl-devel bzip2-devel libffi-devel
```

#### Command not found

Make sure pyenv is in your PATH and the init command is in your shell config.

#### Python version not switching

Check your shell configuration and make sure you've restarted your terminal or sourced your config file.

### Best Practices

1. **Use local versions for projects**: Always set specific Python versions for your projects using `pyenv local`
    
2. **Keep .python-version in version control**: Commit the `.python-version` file so team members use the same Python version
    
3. **Update regularly**: Keep pyenv updated to access new Python releases:
    
    ```bash
    brew upgrade pyenv  # macOS
    # or
    cd $(pyenv root) && git pull  # Manual installation
    ```
    
4. **Use specific versions**: Instead of `pyenv install 3.11`, use `pyenv install 3.11.5` for reproducibility
    
5. **Combine with requirements.txt**: Document both Python version (via `.python-version`) and dependencies (via `requirements.txt`)
    

### Common Workflow Example

Here's a typical workflow for starting a new project:

```bash
# Create project directory
mkdir my-new-project
cd my-new-project

# Set Python version for this project
pyenv local 3.11.5

# Create virtual environment
python -m venv venv
source venv/bin/activate

# Install dependencies
pip install requests flask
pip freeze > requirements.txt

# Your .python-version file ensures everyone uses Python 3.11.5
# Your requirements.txt ensures everyone has the same packages
```

This setup ensures consistent Python environments across different machines and team members. The `.python-version` file will automatically activate the correct Python version whenever you enter the project directory.

---

