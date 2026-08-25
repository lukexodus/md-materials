## Options and Flags


### Operation Flags (Primary Operations)

Pacman requires one of these primary operation flags to specify the type of action:

**-S, --sync:** Synchronize packages from repositories (install/upgrade)
```
pacman -S package_name
```

**-R, --remove:** Remove packages from the system
```
pacman -R package_name
```

**-Q, --query:** Query the local package database
```
pacman -Q
```

**-U, --upgrade:** Install packages from local files or URLs
```
pacman -U package-file.pkg.tar.zst
```

**-F, --files:** Query the files database
```
pacman -F filename
```

**-D, --database:** Modify package database (change install reasons)
```
pacman -D --asexplicit package_name
```

### Global Options (Apply to All Operations)

#### Path Configuration

**-b, --dbpath \<path\>:** Specify alternative database path
```
pacman --dbpath /custom/db/path
```
**Note:** This is an absolute path; root is not automatically prepended.[5]

**-r, --root \<path\>:** Specify alternative installation root
```
pacman --root /mnt
```
**Note:** Not suitable for mounted guest systems; use `--sysroot` instead.[5]

**--sysroot \<dir\>:** Operate on a mounted guest system
```
pacman --sysroot /mnt/guest
```

**--cachedir \<dir\>:** Specify alternative cache directory
```
pacman --cachedir /custom/cache
```
**Note:** Absolute path, root not automatically prepended.[5]

**--gpgdir \<dir\>:** Specify alternative GnuPG directory
```
pacman --gpgdir /custom/gnupg
```

**--hookdir \<dir\>:** Specify alternative hooks directory
```
pacman --hookdir /custom/hooks
```

**--logfile \<file\>:** Specify alternative log file
```
pacman --logfile /custom/pacman.log
```

**--config \<file\>:** Use alternative configuration file
```
pacman --config /custom/pacman.conf
```

#### System and Architecture

**--arch \<arch\>:** Specify architecture
```
pacman --arch x86_64
```

#### Output Control

**-v, --verbose:** Display verbose output
```
pacman -v
```

**--color \<when\>:** Control colored output
```
pacman --color always   # Force colors on
pacman --color never    # Force colors off
pacman --color auto     # Auto (default for tty)
```


**--debug:** Display debug messages
```
pacman --debug
```

**--noconfirm:** Bypass confirmation prompts
```
pacman -Syu --noconfirm
```

**--confirm:** Ask for confirmation (opposite of --noconfirm)
```
pacman --confirm
```

**--noprogressbar:** Disable progress bar display
```
pacman --noprogressbar
```

**--disable-download-timeout:** Disable download timeout
```
pacman --disable-download-timeout
```

**--disable-sandbox:** Disable process sandboxing
```
pacman --disable-sandbox
```

### Transaction Options (Apply to -S, -R, -U)

**-d, --nodeps:** Skip dependency checks
```
pacman -Sd package_name  # Single level
pacman -Sdd package_name # All checks
```


**--assume-installed \<package=version\>:** Assume a package is installed
```
pacman --assume-installed package=1.0
```
Works like `--nodeps` but for specific packages.[5]

**--dbonly:** Modify database only, don't touch files
```
pacman -S --dbonly package_name
```


**--noscriptlet:** Skip install/upgrade scriptlets
```
pacman -S --noscriptlet package_name
```


**-p, --print:** Print targets instead of performing operation
```
pacman -Sp package_name   # Print URLs
pacman -Rp package_name   # Print package names
```


**--print-format \<format\>:** Customize print output format
```
pacman -Sp --print-format "%n %v"
```
Default format is `%l` (URLs for -S, filenames for -U, pkgname-pkgver for -R).[2][5]

### Sync Options (Apply to -S)

#### Basic Sync Operations

**-y, --refresh:** Refresh package databases
```
pacman -Sy      # Refresh once
pacman -Syy     # Force refresh
```


**-u, --sysupgrade:** Upgrade installed packages
```
pacman -Su      # Upgrade
pacman -Suu     # Allow downgrades
```


**-c, --clean:** Remove old packages from cache
```
pacman -Sc      # Remove uninstalled packages
pacman -Scc     # Remove all cached packages
```

**-g, --groups:** View or install package groups
```
pacman -Sg               # List all groups
pacman -Sg group_name    # List group members
pacman -S group_name     # Install group
```

**-i, --info:** Display package information
```
pacman -Si package_name   # Repository package info
pacman -Sii package_name  # Include reverse dependencies
```


**-l, --list:** List repository packages
```
pacman -Sl               # All packages
pacman -Sl repo_name     # Specific repository
```


**-s, --search:** Search package names and descriptions
```
pacman -Ss search_term
```

**-q, --quiet:** Quiet output (names only)
```
pacman -Ssq search_term
```


### Upgrade Options (Apply to -S and -U)

**-w, --downloadonly:** Download packages without installing
```
pacman -Sw package_name
pacman -Syuw            # Download upgrades only
```


**--asdeps:** Mark packages as dependencies
```
pacman -S --asdeps package_name
```


**--asexplicit:** Mark packages as explicitly installed
```
pacman -S --asexplicit package_name
```


**--ignore \<package\>:** Skip specific packages during upgrade
```
pacman -Syu --ignore linux,firefox
```


**--ignoregroup \<group\>:** Skip package groups during upgrade
```
pacman -Syu --ignoregroup gnome
```


**--needed:** Don't reinstall up-to-date packages
```
pacman -S --needed package_name
```


**--overwrite \<glob\>:** Overwrite conflicting files
```
pacman -S --overwrite /path/to/file package_name
pacman -S --overwrite '*' package_name  # All files
```


Multiple patterns can be specified:
```
pacman -S --overwrite /usr/lib/\* --overwrite /usr/bin/\* package_name
```

Patterns can be negated with `!`:
```
pacman -S --overwrite '/usr/\*' --overwrite '!/usr/bin/\*' package_name
```


### Query Options (Apply to -Q)

**-c, --changelog:** View package changelog
```
pacman -Qc package_name
```


**-d, --deps:** List dependency packages
```
pacman -Qd      # All dependencies
pacman -Qdt     # Orphaned dependencies
```


**-e, --explicit:** List explicitly installed packages
```
pacman -Qe      # All explicit
pacman -Qet     # Explicit not required by others
```


**-g, --groups:** Display package groups
```
pacman -Qg               # All groups
pacman -Qg group_name    # Specific group
```


**-i, --info:** Display package information
```
pacman -Qi package_name   # Basic info
pacman -Qii package_name  # Include backup files
```


**-k, --check:** Check package files
```
pacman -Qk package_name   # File presence
pacman -Qkk package_name  # Detailed check
```


**-l, --list:** List package files
```
pacman -Ql package_name
```


**-m, --foreign:** List foreign packages (AUR/manually installed)
```
pacman -Qm
```


**-n, --native:** List native packages (from repositories)
```
pacman -Qn
```


**-o, --owns \<file\>:** Find package owning a file
```
pacman -Qo /usr/bin/vim
```


**-p, --file:** Query package file instead of database
```
pacman -Qip package.pkg.tar.zst
pacman -Qlp package.pkg.tar.zst
```


**-q, --quiet:** Quiet output (names only)
```
pacman -Qq      # All packages (names)
pacman -Qeq     # Explicit packages (names)
```


**-s, --search \<regexp\>:** Search installed packages
```
pacman -Qs search_term
```


**-t, --unrequired:** List unrequired packages
```
pacman -Qt      # Not required
pacman -Qtt     # Include optional requirements
```


**-u, --upgrades:** List out-of-date packages
```
pacman -Qu
```


### Remove Options (Apply to -R)

**-c, --cascade:** Remove package and all dependents
```
pacman -Rc package_name
```
**Warning:** Removes packages that depend on the target.[5][2]

**-n, --nosave:** Don't create .pacsave backup files
```
pacman -Rn package_name
```


**-s, --recursive:** Remove dependencies
```
pacman -Rs package_name   # Remove unneeded dependencies
pacman -Rss package_name  # Remove all dependencies
```


**-u, --unneeded:** Remove targets not required by others
```
pacman -Ru package_name
```


### Files Options (Apply to -F)

**-y, --refresh:** Refresh files database
```
pacman -Fy
```

**-l, --list:** List files in package
```
pacman -Fl package_name
```

**-s, --search:** Search for packages containing files
```
pacman -F filename
```

**-o, --owns:** Query remote package owning file
```
pacman -F /usr/bin/program
```

**-q, --quiet:** Quiet output
```
pacman -Flq package_name
```

### Database Options (Apply to -D)

**--asdeps:** Mark packages as dependencies
```
pacman -D --asdeps package_name
```

**--asexplicit:** Mark packages as explicitly installed
```
pacman -D --asexplicit package_name
```

**-k, --check:** Check database consistency
```
pacman -Dk
```

### Common Flag Combinations

**Full system upgrade:**
```
pacman -Syu
```

**Install with dependencies:**
```
pacman -S package_name
```

**Remove with config files and dependencies:**
```
pacman -Rns package_name
```

**Search repositories:**
```
pacman -Ss search_term
```

**Search installed:**
```
pacman -Qs search_term
```

**List orphaned packages:**
```
pacman -Qdt
```

**Check for updates:**
```
pacman -Qu
```

**Download without installing:**
```
pacman -Sw package_name
```

**Install local package:**
```
pacman -U package.pkg.tar.zst
```

These options and flags provide comprehensive control over pacman's behavior, allowing fine-tuned package management operations tailored to specific needs.

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] pacman(8) https://pacman.archlinux.page/pacman.8.html
[3] An intro to pacman commands - Newbie https://forum.endeavouros.com/t/an-intro-to-pacman-commands/9614
[4] Asking for a Safe pacman command list and good practices ... https://www.reddit.com/r/archlinux/comments/1g6ydx8/asking_for_a_safe_pacman_command_list_and_good/
[5] pacman(8) - Arch manual pages https://man.archlinux.org/man/pacman.8.en
[6] Pacman cheatsheet https://devhints.io/pacman
[7] Pacman Cheatsheet https://gist.github.com/HFTrader/4fb15d461d86634fd1cba5d251ca7925
[8] Arch Linux pacman – Just the Most Useful Commands https://psychocod3r.wordpress.com/2021/07/11/arch-linux-pacman-just-the-most-useful-commands/
[9] pacman cheat sheet - Linux Audit https://linux-audit.com/cheat-sheets/pacman/

