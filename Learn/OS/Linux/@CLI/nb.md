**Comprehensive Guide to `nb`** — A powerful CLI and local web plain-text note-taking, bookmarking, archiving, and knowledge base tool.

`nb` stores everything as plain text files (Markdown by default, but supports Org, LaTeX, AsciiDoc, and any format). It features Git-backed versioning/syncing, encryption, tagging, search, linking, folders, todos, Pandoc import/export, and a browser interface. It’s a single portable Bash script, highly flexible, and works great alongside tools like Obsidian or Neovim.

### 1. Installation on Arch Linux
**Recommended (AUR):**  
```bash
yay -S nb    # or your preferred AUR helper (paru, etc.)
```

**Alternative (direct script, always latest):**  
```bash
sudo curl -L https://raw.github.com/xwmx/nb/master/nb -o /usr/local/bin/nb &&
sudo chmod +x /usr/local/bin/nb &&
sudo nb completions install --download
```

**Optional dependencies** (highly recommended for full features):  
```bash
sudo nb env install
```
This installs tools like `ripgrep`, `fzf`, `pandoc`, `git`, etc., for better search, previews, and conversions.

**Tab completion**: Usually installed automatically. For manual setup, check the repo’s `etc/` directory.

**Update**: `nb update` (or use your package manager).

### 2. First Run & Basic Concepts
Run `nb` once — it creates your default `home` notebook at `~/.nb`.

- **Notebooks**: Separate collections (like workspaces). Global by default (`~/.nb`), but support local ones too.
- **Notes**: Plain text files, auto-named with timestamps or custom names.
- **Selectors**: Identify items by number (`3`), filename, or title. Relative to the current notebook.
- **Folders**: Normal directories inside notebooks for organization.

### 3. Core Commands

#### Adding Notes
```bash
nb add                    # Open editor for new note
nb add "Quick note text"  # Instant note
echo "Content" | nb add   # Pipe content

nb add example.md         # Specific filename/extension
nb add sample/            # In a folder (creates if needed)
nb add --title "My Note" --tags tag1,tag2
nb add --encrypt          # Password-protected (AES-256 or GPG)
```

Shortcuts: `nb a`, `nb +`.

#### Listing & Filtering
```bash
nb ls          # List notes (paged, with colors)
nb list        # Same
nb ls --tag tag1
nb ls --todo   # Todos only
nb ls sample/  # In folder
nb ls 5        # Around item 5
```

Use `--limit`, `--sort`, `--order`, pinning (`--pinned`), etc.

#### Viewing & Browsing
```bash
nb show 3          # View note
nb show 3 --no-color
nb browse          # Local web interface (terminal or GUI browser)
nb browse 5        # Specific item
```

`browse` supports images, syntax highlighting, and distraction-free reading.

#### Editing & Deleting
```bash
nb edit 3          # Or nb e 3
nb delete 3        # Or nb d 3 (with confirmation)
nb move 3 archive/ # Or rename
```

#### Search
```bash
nb search "keyword"     # Or nb q "keyword"
nb q \#tag1             # Tag search
nb q -t tag1 -t tag2    # AND
nb q \#tag1 --or \#tag2 # OR
nb q --regex pattern
```

Uses `ripgrep` (if available) for blazing-fast full-text search, including inside bookmarks.

#### Tagging
Tags are `#hashtags` in the note (auto-inserted via `--tags` on add). Filter/search as above.

#### Pinning
```bash
nb pin 5
nb unpin 5
nb ls --pinned
```

#### Todos & Tasks
```bash
nb todo            # List todos
nb todo add "Task" # Or use checkboxes in Markdown: - [ ] Task
```

#### Linking (Wiki-style)
Use `[[Note Title]]` or `[[filename]]` for internal links. Works in `show`/`browse`.

#### Bookmarks
```bash
nb bookmark https://example.com
nb b https://example.com "Custom title"
```

`nb` downloads, cleans, and saves page content as Markdown. Full-text searchable.

#### Encryption
Use `--encrypt` on add/edit. Prompts for password per item. Decryptable with OpenSSL/GPG directly.

### 4. Notebooks
```bash
nb notebooks       # List
nb notebook add work
nb use work        # Or nb w work (switch)
nb home:add ...    # Use specific notebook
```

**Global vs Local**: Global notebooks are always available. Local ones are tied to a directory.

**Syncing**:
- Git is built-in: `nb git` commands or auto-sync.
- Configure remote: `nb notebook remote set origin <url>`.
- Or use Syncthing/Dropbox on the `~/.nb` folder.

### 5. Advanced Features
- **Revision History**: `nb history` or `nb git log`.
- **Import/Export**: Pandoc-powered (`nb import`, `nb export`).
- **Images**: Inline support in Markdown; view in `browse`.
- **Templates**: Custom via `--template` or `$NB_DEFAULT_TEMPLATE`.
- **Settings**: `nb set editor nvim`, `nb set default_extension org`, `nb settings`.
- **Plugins**: Extend with custom commands (see repo’s `plugins/`).
- **Interactive Shell**: `nb shell`.
- **Color Themes**: Customizable.
- **Zettelkasten Support**: Numbered notes, linking, tags, folders — natural fit.

**Help System** (excellent built-in docs):
```bash
nb help
nb help add
nb help search
nb --help
```

### 6. Recommended Workflow / Tips
1. **Daily use**: `nb add` for quick capture, `nb ls` / `nb q` for retrieval.
2. **Editor integration**: Set `$EDITOR` to Neovim/Vim/Helix. Use with fzf for selection.
3. **Power combo**: `nb` + `ripgrep` + `fzf` + `git` + Syncthing.
4. **Mobile/Other devices**: Sync folder with Syncthing + edit in any Markdown app (Obsidian, etc.).
5. **Backups**: Git + regular `~/.nb` backups.
6. **Performance**: Excellent even with thousands of notes (plain files + fast tools).

### 7. Configuration (`~/.nbrc`)
Example:
```bash
export NB_DEFAULT_EXTENSION="md"
export NB_EDITOR="nvim"
export NB_DEFAULT_TEMPLATE="..."
# Git auto-sync, colors, etc.
```

### Resources
- Official Docs: https://xwmx.github.io/nb/ (very comprehensive)
- GitHub: https://github.com/xwmx/nb
- Arch Wiki mention: Part of note-taking apps list.

`nb` is extremely powerful yet simple to start with. Begin with `nb add`, `nb ls`, and `nb browse`, then explore `nb help`.

If you want examples for a specific workflow (Zettelkasten, daily journaling, bookmarks, scripting, etc.), let me know and I’ll expand!

---

**Here's a realistic, end-to-end sample usage lifecycle for `nb`** — from initial setup to daily operation, organization, retrieval, syncing, and maintenance.

This example assumes you're building a **Personal Knowledge Base** with sections for Journal, Work, Learning, and Bookmarks.

### 1. Initial Setup (One-time)

```bash
# Install recommended tools (if not done)
sudo nb env install

# Set your preferences
nb set editor nvim              # or vim, helix, code --wait, etc.
nb set default_extension md
nb set browser firefox          # or chromium, w3m

# Optional: nicer colors and behavior
nb set color_theme classic
nb set auto_sync 1              # Auto git commit on changes
```

### 2. Create Notebooks (Workspaces)

```bash
nb notebooks                # See current (you start with "home")

nb notebook add work
nb notebook add learning
nb use home                 # Switch back to default
```

### 3. Daily Capture & Note Creation

**Morning routine:**

```bash
# Quick journal entry
nb add journal/"$(date +%Y-%m-%d).md" --title "Journal $(date +%Y-%m-%d)"

# Or just quick capture
nb add "Idea: Build a habit tracker using nb + taskwarrior"

# Add with tags and folder
nb add learning/ --title "Zettelkasten Method" --tags zettelkasten,productivity

# Bookmark a useful page (auto-fetches + converts to Markdown)
nb bookmark https://xwmx.github.io/nb/ --tags nb,documentation
```

**Other capture styles:**

```bash
# From clipboard
xclip -o | nb add quick/clipboard-$(date +%H%M).md

# Todo item
nb todo add "Finish Arch Linux nb guide"
```

### 4. Organization

```bash
# Create folders
nb add journal/ --type folder
nb add references/ --type folder

# Move / organize
nb move 12 references/
nb rename 15 "better-title.md"

# Pin important notes
nb pin 7
nb pin 22
```

**Tagging & Linking** (inside notes):
- Use `#productivity`, `#idea`, `#todo`
- Link with `[[Note Title]]` or `[[filename.md]]`

### 5. Browsing & Reviewing

```bash
nb browse                    # Open full local web UI (best experience)
# or
nb browse 12                 # Specific item
nb ls --pinned
nb todo                      # View todos
```

### 6. Search & Retrieval (The superpower)

```bash
nb q "Zettelkasten"          # Full-text search (very fast with ripgrep)
nb q "#productivity"
nb q --tag idea --or --tag todo

nb ls learning/              # List inside folder
nb ls --limit 20             # Recent items
```

### 7. Editing & Updating

```bash
nb edit 12                   # Open in your $EDITOR
nb edit "Journal 2026-05-04" # By title/filename
```

After editing and saving, `nb` automatically commits the change to git.

### 8. Versioning & History

```bash
nb history 12                # See changes for a note
nb git log --oneline -10     # Overall history
nb git status
```

Revert if needed with standard git commands inside `~/.nb`.

### 9. Syncing Across Devices

**Option A: Git (recommended)**

```bash
cd ~/.nb/home
git remote add origin git@github.com:yourusername/nb-home.git
nb notebook remote set origin git@github.com:yourusername/nb-home.git

# On another machine: clone and link
```

**Option B: Simple folder sync**
- Use **Syncthing** on the entire `~/.nb` folder (great for mobile + Obsidian access).

### 10. Advanced Daily Workflow Example

Create a small script or aliases for speed:

```bash
# ~/.config/fish/config.fish or .bashrc
alias n='nb'
alias na='nb add'
alias nq='nb q'
alias nbw='nb browse'
alias nt='nb todo'

# Quick capture alias
capture() { echo "$*" | nb add quick/"$(date +%Y%m%d-%H%M)".md --title "$*"; }
```

**Sample morning flow**:
1. `nb todo` → review tasks
2. `na` → write daily journal
3. `nbw` → browse recent notes and links
4. Throughout day: `capture Great idea about X`
5. Evening: `nb q \#idea` → process loose ideas

### 11. Maintenance & Archiving

```bash
nb notebooks                # Manage multiple
nb export 45 output.pdf     # Using Pandoc
nb delete 50                # Safe delete with confirmation

# Backup
cp -a ~/.nb ~/backups/nb-$(date +%Y%m%d)
```

### 12. Full Lifecycle Summary (One Day)

- **Capture** → `nb add`, bookmark, todo, clipboard
- **Organize** → tags, folders, links, pin
- **Review** → `nb ls`, `nb browse`, search
- **Process** → edit, link to other notes
- **Sync** → automatic git or Syncthing
- **Archive** → move old notes or export
