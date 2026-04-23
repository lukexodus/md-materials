# direnv

---

## What It Is

**direnv** is a shell extension that automatically loads and unloads environment variables when you enter or leave a directory. It reads a `.envrc` file in the directory and sources it into your shell — then unsets everything when you `cd` away.

No more manually `source`-ing files or polluting your global environment.

---

## Installation

```bash
# macOS
brew install direnv

# Debian/Ubuntu
sudo apt install direnv

# Arch
sudo pacman -S direnv

# Nix
nix-env -i direnv

# From binary releases
# https://github.com/direnv/direnv/releases
```

### Shell Hook (required)

After installing, add the hook to your shell config. Without this, direnv does nothing.

```bash
# bash — add to ~/.bashrc
eval "$(direnv hook bash)"

# zsh — add to ~/.zshrc
eval "$(direnv hook zsh)"

# fish — add to ~/.config/fish/config.fish
direnv hook fish | source

# tcsh — add to ~/.cshrc
eval `direnv hook tcsh`
```

Restart your shell or `source` the config file after adding.

---

## Core Concept

1. Create a `.envrc` file in a directory
2. Run `direnv allow` to authorize it
3. Every time you `cd` into that directory, direnv loads it
4. When you `cd` out, everything is unloaded

```bash
mkdir myproject && cd myproject
echo 'export API_KEY="abc123"' > .envrc
direnv allow
# direnv: loading .envrc
# direnv: export +API_KEY

echo $API_KEY   # abc123

cd ..
# direnv: unloading

echo $API_KEY   # (empty)
```

---

## .envrc Syntax

`.envrc` is a bash script with access to direnv's stdlib functions. Standard bash works, plus direnv-specific helpers.

### Basic exports

```bash
export APP_ENV=development
export DATABASE_URL=postgres://localhost/mydb
export PORT=3000
```

### Unset a variable

```bash
unset SOME_VAR
```

### Conditional logic

```bash
if [ -f .env.local ]; then
  source_env .env.local
fi
```

### Load from a separate file

```bash
dotenv                  # loads .env in current dir
dotenv .env.local       # loads specific file
source_env .env         # source another .envrc-style file
source_env_if_exists .env.local   # only if file exists
```

---

## direnv stdlib Functions

These are built-in helpers available inside `.envrc`:

### Path manipulation

```bash
PATH_add bin              # prepend ./bin to $PATH
PATH_add ./scripts        # prepend ./scripts to $PATH
path_add MANPATH ./man    # prepend to any PATH-style variable
```

### Python

```bash
layout python             # creates/activates a venv in .direnv/python
layout python3            # same, explicit python3
layout python python3.11  # specific version
```

### Node.js

```bash
layout node               # adds node_modules/.bin to PATH
```

### Ruby

```bash
layout ruby               # sets GEM_HOME, GEM_PATH, adds bin to PATH
```

### Go

```bash
layout go                 # sets GOPATH to .direnv/go
```

### Nix

```bash
use nix                   # loads nix-shell from shell.nix or default.nix
use flake                 # loads nix flake devShell
```

### Version managers

```bash
use node 20.0.0           # via nodenv or nvm (if configured)
use ruby 3.2.0            # via rbenv
use python 3.11.0         # via pyenv
```

Note: `use <tool> <version>` requires the relevant version manager to be installed and configured with direnv. Behavior depends on your setup. [Inference — not guaranteed to work without additional configuration]

### Inherit from parent

```bash
source_up                 # load .envrc from parent directory too
source_up_if_exists       # same, but silent if none found
```

### Load secrets from external tools

```bash
# 1Password CLI
export SECRET=$(op read "op://vault/item/field")

# AWS SSM
export DB_PASS=$(aws ssm get-parameter --name /app/db_pass --with-decryption --query Parameter.Value --output text)
```

---

## Commands

```bash
direnv allow              # authorize .envrc in current directory
direnv allow /path/dir    # authorize specific directory
direnv deny               # revoke authorization for current dir
direnv deny /path/dir     # revoke specific directory
direnv reload             # force reload current .envrc
direnv edit               # open .envrc in $EDITOR, auto-allow on save
direnv status             # show current state and loaded vars
direnv version            # print version
direnv exec /path cmd     # run command with that dir's env, without cd-ing
direnv prune              # remove stale authorizations
```

---

## Authorization Model

direnv will **not** load an `.envrc` unless you have explicitly allowed it. This prevents automatically executing arbitrary code when entering a directory (e.g. from a cloned repo).

```bash
# First time, or after any edit:
direnv allow

# After editing .envrc, direnv blocks it again:
# direnv: error .envrc is blocked. Run `direnv allow` to approve its content.
```

Allowed directories are recorded in `~/.local/share/direnv/allow/` (hashes of paths).

---

## Hierarchy & Inheritance

direnv loads only the **nearest** `.envrc` by default. To also load parent directories:

```bash
# in child .envrc
source_up_if_exists
```

This lets you have a root-level `.envrc` with shared config and project-level ones that extend it.

---

## Global Config

direnv's config file lives at `~/.config/direnv/direnv.toml`:

```toml
[global]
# Suppress the "export +VAR" output on load
hide_env_diff = false

# Warn if .envrc takes longer than this to load (seconds)
warn_timeout = "5s"

# Whitelist directories (auto-allow without explicit direnv allow)
[whitelist]
prefix = ["/home/alice/trusted-projects"]
exact = ["/home/alice/dotfiles/.envrc"]
```

Whitelisting bypasses the manual `direnv allow` requirement — use carefully.

---

## Custom stdlib (direnvrc)

You can add your own functions available in all `.envrc` files:

```bash
# ~/.config/direnv/direnvrc  (or ~/.direnvrc)

# Example: load .env silently if present
load_dotenv() {
  local f="${1:-.env}"
  [ -f "$f" ] && dotenv "$f"
}

# Example: require a variable to be set
require() {
  [ -z "${!1}" ] && echo "ERROR: $1 is required" && exit 1
  true
}
```

Then in any `.envrc`:

```bash
load_dotenv
require DATABASE_URL
```

---

## Common Patterns

### Python project with venv

```bash
layout python3
export PYTHONPATH=$PWD
export FLASK_ENV=development
```

### Node project

```bash
layout node
export NODE_ENV=development
export PORT=3000
```

### Per-project AWS profile

```bash
export AWS_PROFILE=my-project-profile
export AWS_DEFAULT_REGION=us-east-1
```

### Docker Compose override

```bash
export COMPOSE_FILE=docker-compose.yml:docker-compose.dev.yml
export COMPOSE_PROJECT_NAME=myapp
```

### Multiple environments with a selector

```bash
ENV_FILE=".env.${APP_ENV:-.development}"
[ -f "$ENV_FILE" ] && dotenv "$ENV_FILE"
```

---

## .gitignore Recommendations

```gitignore
.envrc          # if it contains secrets — but usually commit a .envrc.example
.env
.env.local
.direnv/        # direnv's working directory (venvs, etc.)
```

[Inference] A common pattern is to commit `.envrc` with no secrets (only `layout` calls and non-sensitive exports), and keep a `.env.local` or `.env` gitignored for actual secrets — then load it via `dotenv` inside `.envrc`.

---

## Tips & Gotchas

- **Always run `direnv allow` after editing** — direnv blocks the file again on any change
- **`direnv edit` is safer** — opens `$EDITOR` and auto-allows on save, skipping the manual allow step
- **`layout python` creates a venv in `.direnv/`** — this can be large; add `.direnv/` to `.gitignore`
- **direnv runs in a subshell** — functions and aliases defined in `.envrc` do not persist to your interactive shell; only exported variables do
- **`source_up` can cause double-loading** — if parent and child both export the same var, child wins
- **Slow load times** — if `.envrc` calls slow external tools (AWS CLI, Vault, etc.), your prompt will stall on every `cd`; cache values where possible
- **Fish shell users** — direnv works with fish but `.envrc` is still bash syntax; fish just receives the exported variables

---

## Quick Reference

```
direnv allow              Authorize current .envrc
direnv deny               Block current .envrc
direnv reload             Force re-load
direnv edit               Edit + auto-allow
direnv status             Show what's loaded
direnv exec /dir cmd      Run cmd with that dir's env

export FOO=bar            Basic export in .envrc
dotenv                    Load .env file
dotenv .env.local         Load specific file
layout python3            Create/activate venv
layout node               Add node_modules/.bin to PATH
PATH_add bin              Prepend ./bin to PATH
source_up_if_exists       Also load parent .envrc
```