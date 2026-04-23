# zoxide

A smarter `cd` command. zoxide learns which directories you visit most and lets you jump to them with minimal typing — no need to type full paths.

---

## How It Works

Every time you `cd` into a directory, zoxide records it with a score. The more frequently and recently you visit a directory, the higher its score ("frecency" — frequency + recency). When you jump with `z`, zoxide finds the highest-scoring directory that matches your query.

---

## Installation

|OS|Command|
|---|---|
|macOS|`brew install zoxide`|
|Ubuntu/Debian|`sudo apt install zoxide`|
|Fedora/RHEL|`sudo dnf install zoxide`|
|Arch|`sudo pacman -S zoxide`|
|Cargo (any)|`cargo install zoxide --locked`|

---

## Shell Setup

After installing, add the init line to your shell config. This is required — zoxide won't work without it.

**bash** — add to `~/.bashrc`:

```bash
eval "$(zoxide init bash)"
```

**zsh** — add to `~/.zshrc`:

```bash
eval "$(zoxide init zsh)"
```

**fish** — add to `~/.config/fish/config.fish`:

```fish
zoxide init fish | source
```

**nushell** — add to `$nu.config-path`:

```nu
zoxide init nushell | save -f ~/.zoxide.nu
source ~/.zoxide.nu
```

**PowerShell** — add to your profile:

```powershell
Invoke-Expression (& { (zoxide init powershell | Out-String) })
```

Then restart your shell or `source` the config file.

---

## Basic Usage

|Command|Action|
|---|---|
|`z foo`|Jump to the highest-scoring directory matching `foo`|
|`z foo bar`|Match a directory containing both `foo` and `bar` in the path|
|`z foo/`|Jump to an exact subdirectory named `foo`|
|`z ..`|Go up one directory (same as `cd ..`)|
|`z -`|Jump to the previous directory|
|`z`|Go to home directory|

**Examples:**

```bash
z proj          # jumps to ~/code/projects if you've been there often
z doc api       # jumps to ~/work/documentation/api
z down          # jumps to ~/Downloads
```

You don't need to type the full name — just enough to uniquely identify the target from your history.

---

## Interactive Mode (with fzf)

If you have `fzf` installed, zoxide can show an interactive fuzzy picker.

|Command|Action|
|---|---|
|`zi`|Open interactive picker across all tracked directories|
|`zi foo`|Open interactive picker filtered to matches for `foo`|

Install fzf: `brew install fzf` / `apt install fzf` / `pacman -S fzf`

---

## The `zoxide` Command Directly

Beyond `z`, you can use the `zoxide` binary directly for database management.

|Command|Action|
|---|---|
|`zoxide query foo`|Show the best match for `foo` without jumping|
|`zoxide query -l foo`|List all matches for `foo` with their scores|
|`zoxide query -s foo`|Show matches with scores|
|`zoxide add <path>`|Manually add a path to the database|
|`zoxide remove <path>`|Remove a path from the database|
|`zoxide edit`|Open the database in an interactive editor|

---

## Database

zoxide stores its database at:

|OS|Default path|
|---|---|
|Linux|`~/.local/share/zoxide/db.zo`|
|macOS|`~/Library/Application Support/zoxide/db.zo`|
|Custom|Set `$ZOXIDE_DATA_DIR` to override|

---

## Configuration

zoxide is configured via environment variables, set in your shell config before the `eval "$(zoxide init ...)"` line.

```bash
# Don't add these directories to the database
export ZOXIDE_EXCLUDE_DIRS="/tmp:/private/tmp:$HOME"

# Use a custom data directory
export ZOXIDE_DATA_DIR="$HOME/.config/zoxide"

# Set maximum number of entries in the database
export ZOXIDE_MAXAGE=10000
```

---

## Renaming the Command

If you want to keep your existing `cd` behavior but also have zoxide, you can alias or rename. The most common approach is to replace `cd` entirely:

```bash
# In ~/.bashrc or ~/.zshrc — init with --cmd cd to replace cd
eval "$(zoxide init bash --cmd cd)"
```

Now `cd` uses zoxide, and `cdi` becomes the interactive picker. This is the most seamless setup — you never have to think about which command to use.

Alternatively, keep both:

```bash
eval "$(zoxide init bash)"
# z = zoxide jump
# cd = normal cd (still recorded by zoxide)
```

---

## How Frecency Scoring Works

zoxide uses a decaying score:

- Each visit to a directory adds to its score
- Scores decay over time — recent visits matter more than old ones
- When you run `z foo`, zoxide picks the **highest-scoring** directory whose path contains `foo` as a substring
- If multiple directories match, the highest scorer wins
- You can bias the result by adding more terms: `z foo bar` requires both substrings to appear in the path

---

## Tips

**Seed your database early** — the more you use your shell normally, the better zoxide gets. You can also bulk-add directories:

```bash
find ~ -maxdepth 3 -type d | xargs -I{} zoxide add {}
```

**Combine with fzf for maximum effect** — `zi` with a fuzzy finder is one of the fastest ways to navigate a large filesystem.

**Works across shells** — if you use both bash and zsh, they share the same database by default (same `$ZOXIDE_DATA_DIR`), so history carries over.

**Use with `--cmd cd`** — the least friction setup. You type `cd` as always; zoxide handles the smarts transparently.

---

## Comparison with Alternatives

|Tool|Mechanism|Interactive|
|---|---|---|
|`cd`|Exact path only|No|
|`zoxide`|Frecency-based fuzzy match|Yes (with fzf)|
|`autojump`|Frequency-based|No|
|`fasd`|Frecency, files + dirs|No (unmaintained)|
|`z.lua`|Frecency, Lua-based|Optional|

zoxide is generally considered the fastest and most actively maintained of these, and it supports the most shells.