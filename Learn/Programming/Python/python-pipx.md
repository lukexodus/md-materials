# Comprehensive Guide: python-pipx on Arch Linux

## What is pipx?

pipx is a tool to install and run end-user applications written in Python. It's roughly similar to macOS's `brew`, JavaScript's `npx`, and Linux's `apt`. It uses pip under the hood but focuses on installing and managing Python packages that can be run directly from the command line as applications.

By using pipx, you get the best of both approaches: each application is installed in its own virtual environment, while still being accessible globally from anywhere on the system.

**Important distinction:** pipx is specifically designed to install packages which expose one or more command-line utilities. If a package doesn't contain any executable, pipx will refuse to install it. It is not a replacement for pip for library packages.

---

## Installation on Arch Linux

The `python-pipx` package is available in the official Arch Linux `extra` repository.

```bash
sudo pacman -S python-pipx
```

After installing, ensure pipx's bin directory is on your PATH:

```bash
pipx ensurepath
```

Then restart your shell or source your config:

```bash
source ~/.bashrc   # or ~/.zshrc, depending on your shell
```

**Verify installation:**

```bash
pipx --version
```

---

## Directory Structure

Pipx installs packages, together with their dependencies, in their own virtual environments, under the `~/.local/pipx/venvs` directory. To make the utilities exposed by a package globally accessible, links are created in the `~/.local/bin` directory.

pipx also writes a log file for each pipx command executed to `$PIPX_HOME/logs` (typically `~/.local/pipx/logs`), keeping the most recent 10 logs.

---

## Environment Variables

You can customize pipx behavior via these variables:

|Variable|Default|Purpose|
|---|---|---|
|`PIPX_HOME`|`~/.local/pipx`|Root dir for pipx venvs|
|`PIPX_BIN_DIR`|`~/.local/bin`|Where app symlinks are placed|
|`PIPX_DEFAULT_PYTHON`|System python3|Python interpreter to use|
|`PIPX_MAN_DIR`|`~/.local/share/man`|Manual pages location|

If the `--global` option is used, the default app location is `/usr/local/bin` and can be overridden by `PIPX_GLOBAL_BIN_DIR`.

---

## Core Commands

### Install a package

```bash
pipx install <package>
```

Install from a specific source:

```bash
pipx install <package>==1.2.3          # specific version
pipx install git+https://github.com/user/repo.git
pipx install ./local/path
pipx install package.tar.gz
```

You can also specify a Python version at install time:

```bash
pipx install --python python3.11 <package>
```

---

### Run a package without installing

The `run` command executes a Python application in a temporary environment without installing it permanently. This is useful for trying out applications or running one-off commands.

```bash
pipx run pycowsay "hello"
pipx run --spec package==2.0.0 <app>     # specific version
pipx run --python python3.11 <app>        # specific Python
pipx run --spec git+https://github.com/user/repo.git <app>
```

---

### List installed packages

```bash
pipx list           # full listing
pipx list --short   # name + version only
pipx list --json    # machine-readable output
pipx list --pinned  # show pinned packages
```

---

### Upgrade packages

```bash
pipx upgrade <package>               # upgrade one
pipx upgrade --include-injected <package>  # include injected deps too
pipx upgrade-all                     # upgrade all installed packages
pipx upgrade-all --upgrade-injected  # also upgrade injected packages
```

---

### Uninstall packages

```bash
pipx uninstall <package>
pipx uninstall-all
```

---

### Reinstall packages

Useful after upgrading to a new Python version:

Packages are uninstalled, then reinstalled with the same options used in the original install. This is useful if you upgraded to a new version of Python and want all your packages to use the latest as well.

```bash
pipx reinstall <package>
pipx reinstall-all
pipx reinstall-all --python python3.13   # use specific Python for all
```

---

### Inject extra packages into an environment

The `inject` command installs additional packages into an existing pipx-managed virtual environment. This is useful for adding dependencies or plugins to installed applications.

```bash
pipx inject <installed-package> <extra-package> [<extra-package2> ...]
```

Example — add useful libraries to a REPL:

```bash
pipx install ptpython
pipx inject ptpython requests pendulum
```

Options:

```bash
pipx inject <pkg> <dep> --include-apps   # expose dep's CLI apps on PATH too
pipx inject <pkg> -r requirements.txt    # inject from a requirements file
```

Remove injected packages:

```bash
pipx uninject <installed-package> <injected-package>
```

---

### Pin / Unpin packages

Pinning keeps an installation at its current version until you call `pipx unpin`.

```bash
pipx pin <package>               # pin main package + injected
pipx pin <package> --injected-only  # only pin injected packages
pipx pin <package> --skip <dep>     # skip a specific injected package
pipx unpin <package>
```

---

### Run pip inside a specific venv

The `runpip` command runs pip inside a specific package's virtual environment, allowing direct management of the packages within.

```bash
pipx runpip <package> list
pipx runpip <package> show requests
```

---

### Shell completions

```bash
pipx completions
```

This prints instructions for enabling tab completion in your shell (bash, zsh, fish, etc.).

---

### Export and restore all packages

```bash
pipx list --json > pipx.json       # export
pipx install-all pipx.json         # restore
```

---

## Arch Linux–Specific Notes

**PEP 668 / externally managed environment:** Arch Linux marks the system Python environment as externally managed per PEP 668. Running `pip install` outside a virtual environment will fail with an "externally-managed-environment" error. This is intentional — it prevents pip from overwriting packages managed by pacman and breaking system tools. pipx sidesteps this entirely by using isolated venvs.

**Prefer pacman for system-wide tools:** For packages available in the AUR, installing via an AUR helper is often preferable since pacman will track it and its dependencies. Use pipx for tools not packaged in Arch/AUR or when you want version isolation.

**pipx vs. uv:** uv is an extremely fast Python package installer and project manager written in Rust, described as a single tool to replace pip, pip-tools, pipx, poetry, pyenv, twine, virtualenv, and more. It is also available in the official Arch Linux repositories. [Inference — uv may be worth evaluating if you want a unified tool, but behavior differences between pipx and uv are not fully documented here.]

---

## Quick Reference

|Command|Purpose|
|---|---|
|`pipx install <pkg>`|Install app in isolated venv|
|`pipx run <pkg>`|Run app without installing|
|`pipx list`|Show installed apps|
|`pipx upgrade <pkg>`|Upgrade one package|
|`pipx upgrade-all`|Upgrade all packages|
|`pipx inject <pkg> <dep>`|Add dep to existing venv|
|`pipx uninject <pkg> <dep>`|Remove injected dep|
|`pipx pin <pkg>`|Prevent upgrades|
|`pipx uninstall <pkg>`|Remove package|
|`pipx reinstall-all`|Rebuild all venvs (e.g., after Python upgrade)|
|`pipx ensurepath`|Add pipx bin dir to PATH|
|`pipx runpip <pkg> <args>`|Run pip inside a package's venv|
|`pipx environment`|Show pipx env vars and paths|
|`pipx completions`|Shell tab completion setup|