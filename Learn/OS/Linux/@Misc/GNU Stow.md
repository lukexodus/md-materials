# A Comprehensive Guide to GNU Stow

## Table of Contents

1. [What Is GNU Stow?](#what-is-gnu-stow)
2. [The Core Concept: Symlink Farms](#the-core-concept-symlink-farms)
3. [Installation](#installation)
4. [How Stow Thinks: The Two Trees](#how-stow-thinks-the-two-trees)
5. [Basic Usage](#basic-usage)
6. [Setting Up a Dotfiles Repository](#setting-up-a-dotfiles-repository)
7. [Stowing and Unstowing](#stowing-and-unstowing)
8. [Restowing (Re-syncing)](#restowing-re-syncing)
9. [Conflict Resolution](#conflict-resolution)
10. [Ignoring Files](#ignoring-files)
11. [The `--adopt` Flag](#the---adopt-flag)
12. [Nested Directories and Tree Folding](#nested-directories-and-tree-folding)
13. [Multiple Stow Directories and Target Directories](#multiple-stow-directories-and-target-directories)
14. [Simulation Mode (`--simulate` / `-n`)](#simulation-mode---simulate---n)
15. [Verbosity Levels](#verbosity-levels)
16. [Practical Dotfiles Layout Example](#practical-dotfiles-layout-example)
17. [Common Pitfalls](#common-pitfalls)
18. [Stow vs. Alternatives](#stow-vs-alternatives)
19. [Advanced: `.stow-local-ignore` and `.stowrc`](#advanced-stow-local-ignore-and-stowrc)
20. [Scripting and Automation](#scripting-and-automation)
21. [Quick Reference / Cheat Sheet](#quick-reference--cheat-sheet)

---

## What Is GNU Stow?

GNU Stow is a symlink farm manager. It was originally written to help manage installations of software packages that live in separate directory trees, but its most popular modern use case is **dotfiles management** — keeping your configuration files (`.bashrc`, `.vimrc`, `.gitconfig`, etc.) in a version-controlled directory and symlinking them into place in your home directory (or wherever they need to live).

Stow itself is a small Perl script. It doesn't do anything you couldn't do by hand with `ln -s`, `mkdir`, and careful bookkeeping — but it automates that bookkeeping so you don't make mistakes, and it can cleanly *undo* what it did, which manual symlinking usually can't do gracefully.

The name comes from the nautical sense of "stow" — to pack cargo away neatly. The mental model is: you have a bunch of "packages" (directories of related files) sitting in a warehouse (your stow directory), and Stow's job is to "stow" them out into their proper destination (the target directory) by creating symlinks, and to "unstow" them cleanly when you don't want them there anymore.

---

## The Core Concept: Symlink Farms

A **symlink farm** is a directory tree that is largely made of symbolic links pointing into another, "real" tree. The idea predates Stow — it comes from a technique used at MIT and Bell Labs to manage software installed on multiple platforms without duplicating files.

Imagine you have:

```
~/dotfiles/
└── vim/
    └── .vimrc
```

Instead of copying `.vimrc` into your home directory, you create a symlink:

```
~/.vimrc -> ~/dotfiles/vim/.vimrc
```

Now your home directory has a "shadow" of the file structure inside `dotfiles/vim/`, except the leaf is a link rather than a real file. Stow's entire job is to create (and later remove) these links for you, correctly, in bulk, and across nested directory structures.

Why bother instead of just copying files?

- **Single source of truth.** Edit the file in one place (your repo), and it's live everywhere it's linked, with no "did I remember to copy this over" step.
- **Version control friendly.** Your actual dotfiles repo (say, a git repo) contains real files; only your home directory contains links. `git status`, `git diff`, etc. all work normally on the real files.
- **Reversible.** Because Stow tracks what it linked (implicitly, by knowing what it *would* link), it can cleanly remove exactly those links without touching anything else.
- **Composable.** You can enable/disable whole "packages" of configuration (e.g., a `work` profile vs. a `personal` profile) just by stowing/unstowing a directory.

---

## Installation

Stow is packaged for essentially every mainstream distribution and OS.

**Debian/Ubuntu:**
```bash
sudo apt install stow
```

**Fedora:**
```bash
sudo dnf install stow
```

**Arch Linux:**
```bash
sudo pacman -S stow
```

**macOS (Homebrew):**
```bash
brew install stow
```

**From source** (if you need a specific version or your distro's package is stale):
```bash
git clone https://git.savannah.gnu.org/git/stow.git
cd stow
autoreconf -iv
./configure
make
sudo make install
```

Building from source requires Perl and the `Test::More`, `Test::Output`, and `Text::Diff` Perl modules for the test suite (optional but recommended if you're building from source).

Verify installation:
```bash
stow --version
```

---

## How Stow Thinks: The Two Trees

Understanding Stow means understanding its two-directory model:

1. **The Stow directory** (sometimes called the "package directory" or source): this is where your actual files live — typically a git repo like `~/dotfiles`. By default, Stow assumes the *current working directory* is the stow directory, though you can override this with `-d`.

2. **The target directory**: this is where the symlinks get created — typically your home directory `~`. By default, Stow assumes the target is the *parent* of the stow directory. If your stow directory is `~/dotfiles`, the default target is `~`. This is exactly why the dotfiles convention of keeping a `dotfiles` folder directly inside `$HOME` works so smoothly out of the box.

Inside the stow directory, each **top-level subdirectory is a "package."** A package is just a name Stow gives to "one coherent bundle of stuff that gets stowed together." For dotfiles, people typically make one package per application: `vim/`, `git/`, `zsh/`, `tmux/`, etc.

**Critically:** the internal structure of a package *mirrors* the structure you want relative to the target. So if you want `~/.vimrc` and `~/.vim/colors/solarized.vim` to exist, your package looks like:

```
dotfiles/
└── vim/
    ├── .vimrc
    └── .vim/
        └── colors/
            └── solarized.vim
```

When you stow the `vim` package, Stow strips off the `vim/` prefix and recreates the remaining structure relative to the target, using symlinks:

```
~/.vimrc              -> ~/dotfiles/vim/.vimrc
~/.vim/colors/solarized.vim -> ~/dotfiles/vim/.vim/colors/solarized.vim
```

(In practice, thanks to "tree folding," discussed later, Stow will actually often just link the whole `.vim` directory rather than every file inside it individually — but the conceptual mapping is as shown.)

---

## Basic Usage

The general invocation form is:

```bash
stow [OPTIONS] PACKAGE...
```

Run from inside the stow directory, targeting the parent directory by default:

```bash
cd ~/dotfiles
stow vim
```

This one command creates all the necessary symlinks (and parent directories, if needed) in `~` to mirror the contents of `~/dotfiles/vim`.

You can stow multiple packages at once:

```bash
stow vim zsh git tmux
```

To be explicit about directories rather than relying on "current dir is the stow dir, parent is the target":

```bash
stow -d ~/dotfiles -t ~ vim
```

- `-d` / `--dir=DIR`: specify the stow directory.
- `-t` / `--target=DIR`: specify the target directory.

This explicit form is what you want in scripts, cron jobs, or any context where "current working directory" can't be trusted.

---

## Setting Up a Dotfiles Repository

A typical workflow for starting from scratch:

```bash
mkdir ~/dotfiles
cd ~/dotfiles
git init
```

Then create one directory per "package" and move your existing dotfiles into them, preserving the path they'd need relative to `$HOME`:

```bash
mkdir -p ~/dotfiles/vim
mv ~/.vimrc ~/dotfiles/vim/.vimrc

mkdir -p ~/dotfiles/git
mv ~/.gitconfig ~/dotfiles/git/.gitconfig

mkdir -p ~/dotfiles/zsh
mv ~/.zshrc ~/dotfiles/zsh/.zshrc
```

At this point your home directory is *missing* those files (you moved them out), so you re-link them via Stow:

```bash
cd ~/dotfiles
stow vim git zsh
```

Now `~/.vimrc` is a symlink pointing back into the repo, `git status` inside `~/dotfiles` shows your tracked files, and you can commit:

```bash
git add .
git commit -m "Initial dotfiles"
```

On a new machine, the whole setup becomes:

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
stow vim git zsh tmux
```

Two commands and your entire configuration is live.

---

## Stowing and Unstowing

**Stow** (`-S` or default, no flag needed) creates the links:
```bash
stow vim
# equivalent to:
stow -S vim
```

**Unstow** (`-D` / `--delete`) removes exactly the links that stowing would have created — and *nothing else*:
```bash
stow -D vim
```

This is the key safety property that makes Stow trustworthy: unstowing a package removes only the symlinks pointing into that package, and only the ones that correspond to files currently present in the package. It won't touch unrelated files sitting in the same target directories, and it will clean up any directories it created that are now empty (but will leave alone directories that contain other, unrelated content).

You can combine stow/unstow operations across multiple packages in a single invocation, and even mix delete and stow operations for different packages by repeating the flags:

```bash
stow -D old-vim -S new-vim
```

---

## Restowing (Re-syncing)

**Restow** (`-R` / `--restow`) is unstow-then-stow in one step:

```bash
stow -R vim
```

This is what you want after you've:
- Added new files to a package and want them linked without re-typing the package name twice
- Changed the *structure* of a package (e.g., you flattened a nested directory) and need Stow to notice and fix the resulting links
- Suspect something is out of sync and want a clean re-application

Restow is idempotent — running it repeatedly with no changes to the package produces no changes to the target.

---

## Conflict Resolution

Stow refuses to overwrite files that aren't already symlinks pointing where Stow would put them. This is a deliberate, important safety feature.

Example: suppose you already have a real `~/.vimrc` (not a symlink) with content you haven't backed up yet, and you try:

```bash
stow vim
```

Stow will report a conflict and refuse to link over it:

```
WARNING! stowing vim would cause conflicts:
  * existing target is neither a link nor a directory: .vimrc
All operations aborted.
```

This "all operations aborted" behavior is important — by default, Stow is **all-or-nothing** for a given invocation. If *any* file in the package would conflict, Stow aborts the *entire* stow operation for that package rather than partially linking it. This prevents you from ending up in a confusing half-linked state.

To resolve, you have a few options:

1. **Back up and remove the conflicting file, then stow:**
   ```bash
   mv ~/.vimrc ~/.vimrc.bak
   stow vim
   ```

2. **Use `--adopt`** (see below) to pull the existing file *into* your stow package instead of discarding it.

3. **Override conflict handling globally** with `--override` (a regex of paths that you explicitly permit Stow to overwrite even if they're not owned by Stow) — this is a blunt, dangerous instrument and rarely what you actually want; `--adopt` is almost always the better tool for the "I have real content I want to keep" case.

---

## Ignoring Files

Sometimes a package directory contains files that shouldn't be stowed — the classic case is a `.git` directory inside your dotfiles repo, or editor swap files, `README.md` files that document a specific package, `.gitignore` files, etc.

Stow has built-in default ignore patterns (things like `RCS`, `.git`, `.svn`, `CVS`, `*~`, `#*#`, `.gitignore`, `.gitmodules`) that it never stows, so a `.git` folder sitting at the top of your stow directory is already safe.

For anything beyond the defaults, you create a `.stow-local-ignore` file. This can live either in the top-level stow directory (applies to all packages) or inside an individual package directory (applies only to that package). It contains one Perl regular expression per line, matched against the *basename* of each file/directory being considered.

Example `.stow-local-ignore` at the top of your dotfiles repo:

```
\.md$
^README
^LICENSE$
\.stow-local-ignore$
```

This tells Stow: never symlink anything ending in `.md`, anything starting with `README`, an exact file named `LICENSE`, or the ignore file itself.

**Important subtlety:** these are regexes, not glob patterns. `\.md$` (matching a literal dot, then "md", then end-of-string) is correct; `*.md` (a shell glob) is not — in fact `*.md` as a "regex" would mean "zero or more of the literal character before the dot" followed by "md", which is not what you want.

---

## The `--adopt` Flag

`--adopt` inverts Stow's normal conflict-avoidance behavior for a single invocation: instead of refusing to touch a pre-existing real file, Stow will **move the real file into the package directory** (overwriting whatever placeholder was there in the package, if any) and *then* create the symlink back to it.

```bash
stow --adopt vim
```

This is extremely useful in exactly one scenario: you're setting up Stow-management retroactively on a machine that already has your desired final config sitting in `~/.vimrc`, and you'd rather *pull that live version into version control* than blow it away in favor of whatever your repo currently has. Concretely:

1. You have `~/dotfiles/vim/.vimrc` (maybe from another machine, maybe stale) and a *real*, current `~/.vimrc` you like better.
2. `stow --adopt vim` moves `~/.vimrc`'s content into `~/dotfiles/vim/.vimrc` (clobbering the old repo version!) and symlinks `~/.vimrc` back to it.
3. You now `cd ~/dotfiles && git diff` to see exactly what changed, and decide whether to commit the adopted version or revert.

**Warning, stated plainly because this is the most common way people surprise themselves with Stow:** `--adopt` overwrites whatever was in your package directory with whatever was in the target directory. If you run it without checking `git diff` afterward, and the target version was *worse* than your repo version, you've just silently regressed your tracked dotfile. Always follow an `--adopt` invocation with a diff review before committing.

---

## Nested Directories and Tree Folding

By default, Stow tries to be economical with symlinks through a behavior called **tree folding**: if an entire subdirectory of a package would be linked into the target, and that subdirectory doesn't already exist as a real directory in the target, Stow links the *directory itself* as a single symlink rather than descending in and linking every file individually.

Example: your package is
```
dotfiles/vim/.vim/colors/solarized.vim
dotfiles/vim/.vim/colors/gruvbox.vim
```
and `~/.vim` doesn't exist yet. Stow will create:
```
~/.vim -> ~/dotfiles/vim/.vim
```
as a single symlink for the whole directory, rather than:
```
~/.vim/colors/solarized.vim -> ~/dotfiles/vim/.vim/colors/solarized.vim
~/.vim/colors/gruvbox.vim -> ~/dotfiles/vim/.vim/colors/gruvbox.vim
```

**However**, if `~/.vim` *already exists as a real directory* (not a symlink) — for instance, because another package also contributes files under `.vim/`, or because some other tool created it — Stow cannot fold the tree (it can't replace an existing real directory with a symlink without destroying whatever else is in there). Instead, it "unfolds" and descends into the directory, linking individual files:
```
~/.vim/colors/solarized.vim -> ~/dotfiles/vim/.vim/colors/solarized.vim
~/.vim/colors/gruvbox.vim -> ~/dotfiles/vim/.vim/colors/gruvbox.vim
```

This is exactly the mechanism that lets **multiple packages contribute to the same directory** without conflicting — e.g., a `vim-colors` package and a `vim-plugins` package can both put files under `.vim/` in the target, because Stow will unfold `.vim/` into individual per-file links rather than trying to have two different packages each own the single folded-directory symlink.

You generally don't need to think about tree folding day-to-day — it's an internal optimization — but understanding it explains two things people often find surprising:
1. Why `ls -la ~` sometimes shows a whole directory as one symlink and sometimes shows a real directory full of individually-symlinked files.
2. Why adding a *second* package that touches an already-folded directory causes Stow to seemingly "restructure" the target (it's unfolding, not something going wrong).

---

## Multiple Stow Directories and Target Directories

Stow supports multiple `-d` and multiple `-t` style workflows, and — more commonly used — the ability to stow into a target that *isn't* the parent of the stow directory, which is essential for anything beyond home-directory dotfiles.

Explicit form, useful when your dotfiles repo doesn't live directly inside `$HOME`:
```bash
stow -d ~/projects/dotfiles -t ~ vim
```

For XDG-style configuration (increasingly the norm — many modern tools read from `$XDG_CONFIG_HOME`, typically `~/.config`, rather than dumping a dotfile directly into `$HOME`):

```
dotfiles/
└── nvim/
    └── .config/
        └── nvim/
            └── init.lua
```

```bash
stow -t ~ nvim
```

Because the package itself contains the `.config/nvim/...` path internally, targeting `~` (the default parent-of-stow-dir) still produces the correct `~/.config/nvim/init.lua` result. Some people instead prefer to keep the `.config` prefix *out* of the package structure and target `~/.config` directly:

```
dotfiles/
└── nvim/
    └── nvim/
        └── init.lua
```

```bash
stow -t ~/.config nvim
```

Both approaches are common; which one you pick mostly affects how deeply nested your repo structure looks and whether a single package can conveniently also drop a file directly in `$HOME` alongside files in `$HOME/.config`. If a package needs to write to *both* `~/.something` and `~/.config/something`, the first approach (target `~`, embed `.config/` inside the package) is more flexible, since a single `-t` target directory can't simultaneously be `~` and `~/.config`.

---

## Simulation Mode (`--simulate` / `-n`)

Before running any Stow operation you're unsure about, run it in simulate mode first:

```bash
stow -n -v vim
```

`-n` (`--simulate` / `--no`) tells Stow to report everything it *would* do without actually touching the filesystem. Combined with `-v` (verbose, discussed next), this gives you a full preview — a dry run — which is invaluable for:

- Checking for conflicts before committing to an operation
- Understanding exactly what a restow will change before you run it for real
- Reviewing what an `--adopt` will move before it moves it

This should be a habit any time you're doing something non-routine with Stow (adopting, restowing after a structural change, stowing a brand-new package for the first time on an unfamiliar machine).

---

## Verbosity Levels

Stow's `-v` flag is cumulative — you can stack it for increasing detail:

```bash
stow -v vim        # -v      : shows top-level actions (linking, skipping)
stow -vv vim       # -v -v   : shows more detail per file
stow -vvv vim      # -v -v -v: shows internal decision-making, fold/unfold logic
```

In practice, `-v` (single) is usually sufficient for a human to understand what happened; the higher levels are more for debugging Stow's behavior itself when something surprising occurs (e.g., "why didn't this directory get folded the way I expected").

---

## Practical Dotfiles Layout Example

Here's a realistic, complete example structure combining several of the concepts above:

```
~/dotfiles/
├── .stow-local-ignore
├── README.md
├── bash/
│   ├── .bashrc
│   └── .bash_profile
├── git/
│   └── .gitconfig
├── nvim/
│   └── .config/
│       └── nvim/
│           ├── init.lua
│           └── lua/
│               └── plugins.lua
├── tmux/
│   └── .tmux.conf
└── zsh/
    ├── .zshrc
    └── .zsh/
        └── aliases.zsh
```

`.stow-local-ignore` (top level):
```
\.md$
^\.git$
```

Bootstrap script (`install.sh`) you might commit alongside the repo:
```bash
#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

PACKAGES=(bash git nvim tmux zsh)

for pkg in "${PACKAGES[@]}"; do
  stow -v --target="$HOME" "$pkg"
done
```

Running this once on a fresh machine, after `git clone`, sets up everything.

---

## Common Pitfalls

**1. Running Stow from the wrong directory.**
If you `cd` somewhere other than your stow directory and run `stow vim` without `-d`, Stow will look for a `vim/` subdirectory relative to *wherever you are*, not your dotfiles repo, and will either error out or (worse) silently do nothing useful. Always either `cd` into your stow dir first, or always pass `-d` explicitly in scripts.

**2. Forgetting the target defaults to the *parent* of the stow directory.**
If your dotfiles repo is nested somewhere unusual — say `~/projects/personal/dotfiles` — the default target becomes `~/projects/personal`, not `~`. You must pass `-t ~` explicitly in that case.

**3. Conflicts from pre-existing real files on a "fresh" machine that isn't actually fresh.**
New machine images often already ship a default `.bashrc` or `.gitconfig`. Your first `stow` invocation will hit conflicts against these. Either remove them first or use `--adopt` (with the caveats discussed above).

**4. Assuming unstow deletes your actual files.**
It doesn't — it deletes *symlinks*, i.e., the pointer, never the pointed-to content in your stow directory. This confuses people the first time, in a good way (nothing was lost) and sometimes in a confusing way (they expected the target file to be "gone" in some more thorough sense, e.g., if they were trying to fully purge a config, they still need to separately delete it from the repo).

**5. Two packages fighting over the same non-directory file.**
If `vim` package and `vim-extra` package both try to provide `.vimrc` directly (not as a directory, an actual leaf file both packages contain), Stow will conflict — tree folding/unfolding solves the "same directory, different files" case, but it can't merge two different real files that want to occupy the exact same path. Restructure so only one package owns any given leaf file.

**6. Trailing slashes on `-d`/`-t` arguments generally don't matter**, but inconsistent absolute-vs-relative paths across scripted invocations can cause confusion when debugging with `-v`; prefer absolute paths (`$HOME` rather than `~` in shell scripts, since `~` expansion depends on context) in any non-interactive script.

---

## Stow vs. Alternatives

It's worth knowing where Stow sits relative to other dotfiles-management approaches, since "which tool should I use" is a common follow-up question:

- **Plain symlinking by hand** (`ln -s`): Works, but you're manually maintaining the bookkeeping Stow automates — no clean batch-undo, easy to forget a file, no conflict detection.
- **A custom install script** (just `cp` or `ln -s` everything via a bash script you wrote): Total control, zero dependencies beyond bash, but you re-implement (poorly, usually) everything Stow already does well, including conflict safety.
- **`chezmoi`**: A much more full-featured dotfiles manager with templating (different config per machine), encryption for secrets, and a "source of truth" model that's copy-based rather than symlink-based by default. More powerful, but a bigger tool with a steeper learning curve — often overkill if your only need is "put these files in these places, consistently, across a couple of machines."
- **`yadm`** ("Yet Another Dotfiles Manager"): Git-based, symlink-alternative-free (it manages a bare git repo directly against `$HOME`), with built-in encryption and templating support similar to chezmoi. Different philosophy — no separate "package" concept, more like "your home directory just *is* the repo."
- **`rcm`**: Another symlink-farm-style manager, similar in spirit to Stow but purpose-built for dotfiles specifically (rather than Stow's more general "manage any symlink farm" origin), with some dotfiles-specific conveniences like host-specific overrides baked in.

Stow's niche is: minimal, dependency-light (it's one Perl script), extremely predictable, and *not* dotfiles-specific — meaning the mental model transfers if you ever use it for its original purpose (managing multiple software package installations under something like `/usr/local/stow`). If you want templating or encrypted secrets, look at chezmoi; if you want the absolute simplest thing that reliably does "symlink these files, and let me cleanly undo it," Stow remains a very good answer.

---

## Advanced: `.stow-local-ignore` and `.stowrc`

Beyond the ignore file, Stow supports a `.stowrc` file for default command-line options, so you don't have to retype flags you always want. Stow looks for `.stowrc` in the current directory and in `$HOME/.stowrc`.

Example `~/.stowrc`:
```
--target=/home/yourusername
--verbose=1
```

With this in place, running `stow vim` from inside `~/dotfiles` behaves as though you'd typed `stow --target=/home/yourusername --verbose=1 vim`.

This is convenient when you're always running Stow against the same target with the same verbosity preference, but be aware that it makes ad-hoc invocations less "obviously correct from reading the command" if someone else (or future-you) is reading your shell history — the effective flags are partly invisible. For scripts meant to be portable or shared, prefer explicit flags over relying on `.stowrc`.

---

## Scripting and Automation

For a dotfiles repo you actually maintain over time across multiple machines, a small bootstrap script is the standard pattern. A slightly more robust version than the simple loop shown earlier, with per-package error reporting:

```bash
#!/usr/bin/env bash
set -uo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${HOME}"
PACKAGES=(bash git nvim tmux zsh)

for pkg in "${PACKAGES[@]}"; do
  echo "==> Stowing ${pkg}"
  if ! stow -d "$DOTFILES_DIR" -t "$TARGET" -v "$pkg"; then
    echo "!!! Failed to stow ${pkg} (likely a conflict) -- skipping" >&2
    continue
  fi
done

echo "Done."
```

Notes on this script:
- `set -uo pipefail` (deliberately *without* `-e`) so that one package's conflict doesn't abort the entire loop and leave later packages unstowed — the `continue` on failure means you get a report of *all* problems in one run rather than fixing them one at a time across repeated invocations.
- Resolving `DOTFILES_DIR` via `BASH_SOURCE` rather than assuming `pwd` means the script works correctly even if invoked from a different directory or via a symlink to the script itself.
- Explicit `-d`/`-t` throughout, per the "don't rely on defaults in scripts" pitfall noted above.

For machine-specific packages (e.g., a `work-laptop` package with configuration you only want on one machine), you'd simply exclude that package name from `PACKAGES` on machines where it doesn't apply, or read the package list from a per-machine config file/environment variable rather than hardcoding it.

---

## Quick Reference / Cheat Sheet

| Task | Command |
|---|---|
| Stow a package | `stow PACKAGE` |
| Stow multiple packages | `stow PKG1 PKG2 PKG3` |
| Unstow (remove links) | `stow -D PACKAGE` |
| Restow (unstow + stow) | `stow -R PACKAGE` |
| Specify stow dir | `stow -d DIR PACKAGE` |
| Specify target dir | `stow -t DIR PACKAGE` |
| Dry run / preview | `stow -n -v PACKAGE` |
| Verbose output | `stow -v PACKAGE` (stackable: `-vv`, `-vvv`) |
| Adopt existing real files into package | `stow --adopt PACKAGE` |
| Override conflict protection (dangerous) | `stow --override=REGEX PACKAGE` |
| Check version | `stow --version` |
| Show help | `stow --help` |

**Mental model recap:**
- Stow directory = where your real files live (repo).
- Target directory = where symlinks get created (usually `$HOME`).
- Package = a top-level subdirectory of the stow directory; its internal structure mirrors the target structure it should produce.
- Stowing = create links. Unstowing = remove exactly those links, nothing more.
- Conflicts are refused by default (safe); `--adopt` and `--override` are the two ways to force through a conflict, with very different safety properties (`--adopt` preserves data by relocating it into the repo; `--override` just clobbers).