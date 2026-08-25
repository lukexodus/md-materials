## Shell Options


### Built-in Shell Options (set command)

Most shells support these options that can be viewed with `set -o` or `set +o`:

**Bash/POSIX shells:**
- allexport (-a) - Export all variables
- braceexpand (-B) - Enable brace expansion  
- emacs - Use emacs-style command line editing
- errexit (-e) - Exit on command failure
- errtrace (-E) - Trap ERR signal in functions
- functrace (-T) - Trap DEBUG/RETURN in functions
- hashall (-h) - Remember command locations
- histexpand (-H) - Enable history expansion
- history - Enable command history
- ignoreeof - Don't exit on EOF
- interactive-comments - Allow comments in interactive mode
- keyword (-k) - Accept keyword arguments anywhere
- monitor (-m) - Enable job control
- noclobber (-C) - Don't overwrite files with redirection
- noexec (-n) - Read commands but don't execute
- noglob (-f) - Disable filename expansion
- nolog - Don't save function definitions in history
- notify (-b) - Report job status immediately
- nounset (-u) - Treat unset variables as error
- onecmd (-t) - Exit after reading one command
- physical (-P) - Don't follow symbolic links
- pipefail - Pipeline fails if any command fails
- posix - Enable POSIX mode
- privileged (-p) - Enable privileged mode
- verbose (-v) - Print commands as read
- vi - Use vi-style command line editing
- xtrace (-x) - Print commands as executed

### Shell-Specific Options

**Bash shopt options:**
- autocd - cd to directory if command is directory name
- cdable_vars - Treat non-directory arguments to cd as variables
- cdspell - Correct minor spelling errors in cd
- checkhash - Check if hashed commands exist before executing
- checkjobs - Check for running jobs before exiting
- checkwinsize - Update LINES/COLUMNS after each command
- cmdhist - Save multiline commands as single history entry
- compat31/32/40/41/42/43/44 - Compatibility modes
- complete_fullquote - Quote all characters in completion
- direxpand - Expand directory names during completion
- dirspell - Correct spelling errors during completion
- dotglob - Include dotfiles in pathname expansion
- execfail - Don't exit if exec fails
- expand_aliases - Expand aliases
- extdebug - Enable extended debugging mode
- extglob - Enable extended pattern matching
- extquote - Enable $'string' quoting
- failglob - Fail if glob patterns don't match
- force_fignore - Force use of FIGNORE suffixes
- globasciiranges - Use ASCII order for ranges in globs
- globstar - Enable ** recursive globbing
- gnu_errfmt - Use GNU error message format
- histappend - Append to history file
- histreedit - Re-edit failed history substitution
- histverify - Verify history substitution before executing
- hostcomplete - Complete hostnames after @
- huponexit - Send SIGHUP to jobs on exit
- inherit_errexit - Command substitutions inherit errexit
- interactive_comments - Allow comments in interactive shells
- lastpipe - Run last command in pipeline in current shell
- lithist - Save multiline commands with newlines
- login_shell - Shell is login shell
- mailwarn - Warn about mail file access
- no_empty_cmd_completion - Don't complete on empty line
- nocaseglob - Case-insensitive globbing
- nocasematch - Case-insensitive pattern matching
- nullglob - Expand unmatched globs to null
- progcomp - Enable completion
- progcomp_alias - Enable completion for aliases
- promptvars - Expand variables in prompts
- restricted_shell - Shell is restricted
- shift_verbose - Print error for invalid shift
- sourcepath - Use PATH to find scripts for source
- xpg_echo - Make echo interpret escape sequences

**Zsh setopt options:** [Unverified - would need to verify complete list]
- Common ones include AUTO_CD, CORRECT, HIST_IGNORE_DUPS, SHARE_HISTORY, etc.

**Fish shell:** [Unverified - would need to verify options format]
- Uses different configuration system with variables rather than traditional shell options

### Viewing Current Options

```bash
# View all set options
set -o

# View specific option status  
set -o noclobber

# Bash shopt options
shopt

# Show only enabled shopt options
shopt -s
```

[Inference] The exact options available may vary between shell versions and distributions. Some options listed may not be available in all environments.

