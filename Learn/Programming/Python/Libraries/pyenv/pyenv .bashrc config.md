```
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
```

This block of shell code (usually added to your `~/.bashrc`, `~/.zshrc`, `~/.bash_profile` etc.) is the **standard way to set up pyenv** in your shell so that it works automatically every time you open a terminal.

Here's exactly what **each line does**, step by step:

```bash
export PYENV_ROOT="$HOME/.pyenv"
```

- Tells pyenv where it is installed → almost always `~/.pyenv`
- Many pyenv commands and scripts look at this variable to know where to find versions, shims, etc.

```bash
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
```

- `command -v pyenv` → checks if the `pyenv` command is already found in your current `$PATH`
- `>/dev/null` → throws away the output (we only care about the exit status)
- `||` → "or else" — only runs the next part **if pyenv was NOT found**
- `export PATH="$PYENV_ROOT/bin:$PATH"` → adds the pyenv binary folder to the very beginning of your PATH  
  → this is what lets you type `pyenv` in the first place

In modern pyenv docs this is sometimes written more concisely as:

```bash
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
```

(but the `command -v` version is very common and slightly more defensive)

```bash
eval "$(pyenv init -)"
```

This is the **most important line** — it does several things at once:

1. Adds `~/.pyenv/shims` to the **very beginning** of your `$PATH`  
   (this is how pyenv "intercepts" calls to `python`, `pip`, `pytest`, `black`, etc.)

2. Creates / updates **shim files** if needed (like `pyenv rehash` does)

3. Defines shell functions / helpers that pyenv needs (`pyenv()`, `_pyenv()`, etc.)

4. Sets up tab-completion for pyenv commands (in bash/zsh/fish)

5. Makes commands like `pyenv shell 3.11.9`, `pyenv local 3.12`, `pyenv global 3.10` actually work

Without this `eval` line, pyenv is installed but basically does nothing useful — you couldn't switch Python versions or have per-project versions.

### In short — the whole block means:

"Make sure pyenv can be found → initialize pyenv completely so that it can **control which Python version is used** whenever you (or your scripts) run `python`, `pip`, etc."

After you add these lines and reload your shell (or open a new terminal), commands like these start working magically:

```bash
pyenv install 3.12.2
pyenv global 3.12.2
python --version     # → Python 3.12.2
cd my-old-project
pyenv local 3.9.18
python --version     # → Python 3.9.18 (only in this folder!)
```

