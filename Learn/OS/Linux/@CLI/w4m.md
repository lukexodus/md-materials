**Comprehensive Guide to `w3m`** — A fast, lightweight text-based web browser and pager for the terminal.

`w3m` is excellent for quick browsing, viewing rendered HTML in terminals, and tools like `nb browse`. It handles tables well, supports colors, images (with extra setup), mouse, and is highly configurable.

### 1. Installation on Arch Linux

```bash
sudo pacman -S w3m
```

**For inline images** (works in some terminals like kitty, xterm with support):
```bash
sudo pacman -S w3m-img
```

**Optional useful companions**:
- `sudo pacman -S lynx` (alternative/comparison)
- `fzf`, `ripgrep` for workflows

### 2. Basic Usage

```bash
w3m https://example.com
w3m google.com              # Works without https://
w3m duckduckgo.com/search?q=arch+linux

# Local files
w3m index.html
w3m ~/notes/file.md

# Pipe content (great for nb or scripts)
echo "<h1>Hello</h1>" | w3m -T text/html
cat file.html | w3m -dump -T text/html > output.txt   # Text-only output
```

**Quit**: `q`

### 3. Essential Keybindings (Default)

| Action                        | Key(s)                  | Notes |
|-------------------------------|-------------------------|-------|
| **Show help / key list**      | `H` or `?`              | Most important first key |
| **Quit**                      | `q`                     | - |
| **Next link**                 | `Tab`                   | - |
| **Previous link**             | `Shift+Tab`             | - |
| **Follow link**               | `Enter`                 | - |
| **Scroll down**               | `Space`, `Ctrl+V`       | Page down |
| **Scroll up**                 | `b`, `Ctrl+U`           | Page up |
| **Go to top**                 | `g`                     | - |
| **Go to bottom**              | `G`                     | - |
| **Forward / Back**            | `s` / `B`               | History |
| **Reload**                    | `r` or `Ctrl+L`         | - |
| **View source**               | `v`                     | - |
| **Search forward**            | `/`                     | - |
| **Search backward**           | `?`                     | - |
| **Next/Prev search result**   | `n` / `N`               | - |
| **Open URL**                  | `U`                     | Type new URL |
| **Bookmarks**                 | `a` (add), `v` (view)   | - |
| **Download**                  | `d`                     | - |
| **Options menu**              | `o`                     | Config |
| **Toggle images**             | `I`                     | If w3m-img installed |

**Navigation tips**:
- Arrow keys + `hjkl` (Vim-like) work for movement.
- Mouse works in many terminals (click links, scroll).

### 4. Configuration

Config files live in `~/.w3m/`

**First-time setup** (creates default config):
1. Run `w3m`
2. Press `o` (options)
3. Navigate with Tab, change settings, select **OK**

**Key files**:
- `~/.w3m/config` — Main settings (colors, proxies, display options, etc.)
- `~/.w3m/keymap` — Custom keybindings
- `~/.w3m/bookmark.html` — Your bookmarks

**Popular tweaks** (add/edit in `~/.w3m/config`):

```ini
# Better colors
color yes
display_link_number 1        # Show numbers on links (like qutebrowser hints)

# External image viewer
inline_img_protocol 0
ext_image_viewer "feh %s"    # Or kitty + w3m-img

# Other useful
confirm_q exit 0             # Less confirmation on quit
display_image 1
frame 1                      # Better frame handling
```

**Vim-like keybindings** (popular):
Many users replace the default keymap. Check Arch Wiki or GitHub gists for ready files.

### 5. Advanced Features

- **URL hints / numbering**: Set `display_link_number 1` + custom keys `f` and `F` for fast link selection.
- **Tabs**: Limited support (some builds).
- **Cookies**: Enabled by default in recent versions.
- **JavaScript**: No support (by design — security & speed).
- **Download manager**: Built-in basic downloader.
- **Proxy / HTTPS**: Full support.
- **As pager**: `w3m -dump` for text extraction, great for scripts.

### 6. Pro Tips & Workflows

**For use with `nb`**:
- `nb set browser w3m`
- `nb browse` now opens beautifully in terminal.

**Daily browsing**:
```bash
# Quick search
w3m duckduckgo.com

# Open multiple (new instances)
w3m url1 & w3m url2 &

# Bookmark heavy sites
```

**Combine with other tools**:
- Use `surfraw` for quick searches from terminal.
- Pipe HTML to `w3m -dump` for clean text.
- `w3m -T text/html` for rendered previews.

**Performance**:
- Extremely fast and low resource usage.
- Great for low-bandwidth or SSH sessions.

### 7. Common Issues & Fixes

- **No colors**: Terminal not supporting them → use `xterm`, `kitty`, `alacritty`, etc.
- **Images not showing**: Install `w3m-img` + compatible terminal.
- **Slow rendering**: Disable heavy options in `o` menu.
- **Japanese/UTF-8**: Usually works well out of the box.

### 8. Comparison with Alternatives

| Browser | Strengths | Best for |
|---------|-----------|----------|
| **w3m** | Tables, images, speed, pager | General use + nb |
| **lynx** | Simple, bookmarks, very stable | Minimalism |
| **links/elinks** | Better CSS/frames, colors | Complex sites |

### Resources
- Official Manual: `w3m` then press `H` (or https://w3m.sourceforge.net/MANUAL)
- Arch Wiki: `https://wiki.archlinux.org/title/W3m`
- Man page: `man w3m`
