## 1. What is `pyenv`?

`pyenv` is a Python version manager that lets you install and switch between multiple Python versions without touching your system Python. It works by manipulating `PATH` and using shims.

Source: [github.com/pyenv/pyenv](https://github.com/pyenv/pyenv)

---

## 2. Installation

### macOS (Homebrew — recommended)

```bash
brew update
brew install pyenv
```

### Linux (automatic installer)

```bash
curl https://pyenv.run | bash
# installs pyenv + pyenv-update + pyenv-virtualenv
```

### Manual (any Unix)

```bash
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
cd ~/.pyenv && src/configure && make -C src   # optional: compile dynamic bash extension
```

### Windows

pyenv is not natively supported on Windows. Use [pyenv-win](https://github.com/pyenv-win/pyenv-win):

```powershell
Invoke-WebRequest -UseBasicParsing \
  -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1" \
  -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1"
```

---

## 3. Shell Configuration

Add to your shell profile (`.bashrc`, `.zshrc`, `.bash_profile`, etc.):

### bash / zsh

```bash
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
```

### For virtualenv plugin support, also add:

```bash
eval "$(pyenv virtualenv-init -)"
```

Then reload:

```bash
exec "$SHELL"
# or
source ~/.zshrc
```

---

## 4. How pyenv Works (The Shim System)

pyenv inserts `~/.pyenv/shims` at the front of your `PATH`. Every Python-related binary (`python`, `pip`, `python3`, etc.) has a shim there. When invoked, the shim asks pyenv: _which Python version should I use right now?_

pyenv resolves the version by checking in this order:

1. `PYENV_VERSION` environment variable
2. `.python-version` file in current directory (walks up to root)
3. `~/.pyenv/version` (global default)
4. System Python (fallback)

---

## 5. Build Dependencies

Before installing Python versions, install required system libraries.

### Ubuntu / Debian

```bash
sudo apt-get update && sudo apt-get install -y \
  build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev curl git \
  libncursesw5-dev xz-utils tk-dev libxml2-dev \
  libxmlsec1-dev libffi-dev liblzma-dev
```

### macOS

```bash
brew install openssl readline sqlite3 xz zlib tcl-tk
```

### Fedora / RHEL

```bash
sudo dnf install make gcc zlib-devel bzip2 bzip2-devel \
  readline-devel sqlite sqlite-devel openssl-devel \
  tk-devel libffi-devel xz-devel
```

---

## 6. Installing Python Versions

### List all installable versions

```bash
pyenv install --list
pyenv install --list | grep "3\.12"    # filter
pyenv install --list | grep "pypy"     # PyPy builds
```

### Install a version

```bash
pyenv install 3.12.3
pyenv install 3.11.9
pyenv install 3.10.14
pyenv install pypy3.10-7.3.15          # PyPy
pyenv install anaconda3-2024.02-1      # Anaconda
pyenv install miniconda3-latest        # Miniconda
```

### Install with flags (useful on macOS)

```bash
# If openssl or zlib issues arise:
LDFLAGS="-L$(brew --prefix openssl)/lib" \
CPPFLAGS="-I$(brew --prefix openssl)/include" \
pyenv install 3.12.3

# Optimized build (slower compile, faster Python):
PYTHON_CONFIGURE_OPTS='--enable-optimizations --with-lto' \
PYTHON_CFLAGS='-march=native -mtune=native' \
pyenv install 3.12.3
```

### Uninstall a version

```bash
pyenv uninstall 3.11.9
pyenv uninstall -f 3.11.9    # skip confirmation
```

---

## 7. Switching Python Versions

### Global default

```bash
pyenv global 3.12.3
pyenv global system          # revert to system Python
```

### Per-directory (writes `.python-version`)

```bash
cd ~/myproject
pyenv local 3.11.9
cat .python-version          # confirms: 3.11.9
pyenv local --unset          # remove the override
```

### Shell session only

```bash
pyenv shell 3.10.14
pyenv shell --unset
```

### Multiple versions simultaneously

```bash
# Makes python→3.12.3, python3.11→3.11.9, python2→2.7.18
pyenv global 3.12.3 3.11.9 2.7.18
```

Useful when tools require a specific `python3.11` binary.

---

## 8. Inspecting State

```bash
pyenv version              # active version + why
pyenv versions             # all installed versions
pyenv which python         # full path to active python shim target
pyenv which pip
pyenv prefix               # installation directory of active version
pyenv prefix 3.12.3        # installation directory of specific version
pyenv root                 # ~/.pyenv
```

---

## 9. `pyenv-virtualenv` Plugin

Comes bundled with `pyenv.run`. Integrates virtualenvs with pyenv's version switching.

### Create a virtualenv

```bash
pyenv virtualenv 3.12.3 myproject-env
pyenv virtualenv 3.11.9 data-science-env
```

### List virtualenvs

```bash
pyenv virtualenvs
```

### Activate / deactivate

```bash
pyenv activate myproject-env
pyenv deactivate
```

### Auto-activation with `local`

```bash
cd ~/myproject
pyenv local myproject-env
# now activates automatically on cd
```

### Delete a virtualenv

```bash
pyenv virtualenv-delete myproject-env
# or
pyenv uninstall myproject-env
```

---

## 10. Rehashing

Shims are cached. After installing a new Python package that adds executables (e.g., `pip install black`), refresh shims:

```bash
pyenv rehash
```

> **Note:** pyenv rehashes automatically after `pyenv install`. You typically only need this manually after `pip install` adds new CLI tools.

---

## 11. Updating pyenv

### If installed via Homebrew

```bash
brew upgrade pyenv
```

### If installed via pyenv.run (includes `pyenv-update` plugin)

```bash
pyenv update
```

### If installed manually

```bash
cd ~/.pyenv && git pull
```

---

## 12. Environment Variables

|Variable|Effect|
|---|---|
|`PYENV_ROOT`|pyenv home directory (default: `~/.pyenv`)|
|`PYENV_VERSION`|Force a specific version for this shell|
|`PYENV_DEBUG`|Output debug info if set|
|`PYTHON_BUILD_ARIA2_OPTS`|Pass args to aria2 for parallel downloads|
|`PYTHON_CONFIGURE_OPTS`|Extra flags passed to `./configure` at build time|
|`PYTHON_CFLAGS`|Extra C compiler flags|
|`PYTHON_BUILD_BUILD_PATH`|Temp build directory|
|`TMPDIR`|Override temp dir used during builds|

---

## 13. CI / Docker Patterns

### GitHub Actions

```yaml
- name: Set up Python via pyenv
  run: |
    curl https://pyenv.run | bash
    echo "$HOME/.pyenv/bin" >> $GITHUB_PATH
    echo "$HOME/.pyenv/shims" >> $GITHUB_PATH
    pyenv install 3.12.3
    pyenv global 3.12.3
```

> [Inference] Most CI workflows use `actions/setup-python` instead, which is simpler. pyenv in CI is most useful when you need version combinations not available in the runner's default toolset. Behavior not guaranteed.

### Dockerfile

```dockerfile
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y \
    curl git build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev libffi-dev liblzma-dev

ENV PYENV_ROOT="/root/.pyenv"
ENV PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"

RUN curl https://pyenv.run | bash && \
    pyenv install 3.12.3 && \
    pyenv global 3.12.3
```

---

## 14. Project Workflow (End-to-End)

```bash
# 1. Install Python version
pyenv install 3.12.3

# 2. Create a virtualenv for the project
pyenv virtualenv 3.12.3 myapp

# 3. Set it as the local version
cd ~/myapp
pyenv local myapp

# 4. Confirm
python --version       # Python 3.12.3
which python           # ~/.pyenv/shims/python

# 5. Install dependencies
pip install -r requirements.txt

# 6. Rehash if new CLI tools were installed
pyenv rehash
```

---

## 15. Troubleshooting

|Problem|Fix|
|---|---|
|`pyenv: command not found`|Shell config not sourced; re-run `exec "$SHELL"`|
|`python: command not found`|Shims not in PATH; check `eval "$(pyenv init -)"` in profile|
|Build fails (SSL errors)|Install `openssl-dev` / pass `LDFLAGS`+`CPPFLAGS`|
|Build fails (zlib errors)|Install `zlib1g-dev` or `zlib-devel`|
|Wrong version active|Run `pyenv version` to see why; check for `.python-version` files up the tree|
|Shim points to wrong binary|Run `pyenv rehash`|
|Slow builds|Use `PYTHON_CONFIGURE_OPTS='--enable-shared'` or pre-built versions|
|macOS: `tcl-tk` warnings|`brew install tcl-tk` and set `LDFLAGS`/`CPPFLAGS` accordingly|

### Check entire version resolution chain

```bash
pyenv version              # active + source
pyenv versions             # all installed
echo $PYENV_VERSION        # env var override
cat .python-version        # local file
cat ~/.pyenv/version       # global file
```

---

## 16. Quick Reference Cheatsheet

```bash
# Install
pyenv install 3.12.3
pyenv install --list | grep "3\.12"

# Switch versions
pyenv global 3.12.3
pyenv local 3.11.9          # writes .python-version
pyenv shell 3.10.14         # current session only

# Inspect
pyenv version
pyenv versions
pyenv which python

# Virtualenvs (pyenv-virtualenv)
pyenv virtualenv 3.12.3 myenv
pyenv local myenv
pyenv activate myenv
pyenv deactivate
pyenv virtualenvs
pyenv uninstall myenv

# Maintenance
pyenv rehash
pyenv update               # if pyenv-update installed
brew upgrade pyenv         # if Homebrew

# Uninstall
pyenv uninstall 3.12.3
```

---

All information is based on the official [pyenv repository](https://github.com/pyenv/pyenv) and [pyenv-virtualenv](https://github.com/pyenv/pyenv-virtualenv). Build dependency lists and flags may vary by OS version and Python version — verify against current docs for your platform.