# The Complete Guide to Building TUIs with Python's `curses`

## Table of Contents

1. [What curses is and when to reach for it](#1-what-curses-is-and-when-to-reach-for-it)
2. [Setup, initialization, and the `wrapper()` pattern](#2-setup-initialization-and-the-wrapper-pattern)
3. [The coordinate system and the core drawing model](#3-the-coordinate-system-and-the-core-drawing-model)
4. [Windows, subwindows, and derwins](#4-windows-subwindows-and-derwins)
5. [Text output: `addstr`, attributes, and the refresh model](#5-text-output-addstr-attributes-and-the-refresh-model)
6. [Color](#6-color)
7. [Input handling: keys, mouse, and non-blocking reads](#7-input-handling-keys-mouse-and-non-blocking-reads)
8. [Text input widgets with `curses.textpad`](#8-text-input-widgets-with-cursestextpad)
9. [Panels: managing overlapping windows](#9-panels-managing-overlapping-windows)
10. [Handling terminal resize](#10-handling-terminal-resize)
11. [Building an event loop and an application architecture](#11-building-an-event-loop-and-an-application-architecture)
12. [A complete worked example: a task manager TUI](#12-a-complete-worked-example-a-task-manager-tui)
13. [Common pitfalls and how to debug them](#13-common-pitfalls-and-how-to-debug-them)
14. [Platform notes (Windows, macOS, remote terminals)](#14-platform-notes-windows-macos-remote-terminals)
15. [When to graduate to a framework instead](#15-when-to-graduate-to-a-framework-instead)
16. [Reference: function/method cheat sheet](#16-reference-functionmethod-cheat-sheet)

---

## 1. What curses is and when to reach for it

`curses` is a thin Python wrapper around the C `ncurses` library, which is the de facto standard for painting characters onto a terminal and reading keystrokes back out of it, in a way that's portable across terminal types. It's been in the Python standard library since the 1990s and is still there today — it's a compiled extension module (`_curses`), included on Unix-like systems by default. On Windows it's absent from the standard install; you install the third-party `windows-curses` package to get the same interface.

What curses actually gives you is low-level: a way to say "put this character at row 3, column 12, in bold red" and a way to say "block until a key is pressed, then tell me which one." It does **not** give you buttons, dropdown menus, layout managers, or a widget tree — you build all of that yourself out of raw character placement. This is the central trade-off of curses: total control, zero scaffolding.

**Reach for curses when:**
- You want zero runtime dependencies beyond the standard library (Unix) or one small package (Windows).
- You're building something small-to-medium: a dashboard, a log viewer, a simple menu-driven tool, a game like the classic "curses snake."
- You want to deeply understand what a "framework" like Textual is actually doing underneath, because you're going to build one, extend one, or debug one.
- You need extremely tight control over exactly what gets written to the terminal and when (e.g., minimizing flicker in a very specific way, or writing to a non-standard terminal emulator with quirks).

**Don't reach for curses when:**
- You want mouse-driven web-style layouts, CSS-like styling, or a large library of pre-built widgets (tables, tabs, modals) — that's what [Textual](https://textual.textualize.io/) is for, and it will save you weeks.
- You need something that also runs natively on Windows without an extra pip install and extra testing burden.
- The project is large enough that "I'll just write my own layout math" stops being fun on day three.

This guide teaches you curses itself — the primitives — because that knowledge transfers to *understanding* every higher-level framework, even if you end up shipping with one of those frameworks in production.

---

## 2. Setup, initialization, and the `wrapper()` pattern

### Why initialization is dangerous to do by hand

A terminal, left to its own devices, is in "cooked" mode: it buffers your keystrokes line-by-line, echoes what you type back to the screen, and interprets Ctrl-C as an interrupt signal. None of that works for a TUI — you need every keystroke immediately, un-echoed, and you want to decide yourself what Ctrl-C does.

curses achieves this by reconfiguring terminal state on startup (`initscr()`), and it is **your job** to put that state back before your program exits (`endwin()`). If your program crashes between those two calls — an unhandled exception, a `sys.exit()`, anything — the user's terminal is left in a broken, unreadable state (no echo, no line buffering, weird cursor behavior) and they have to run `reset` or close the tab.

### `curses.wrapper()` — always use this

Because "restore terminal state even if my code throws" is such a universal need, curses ships a helper that does it for you:

```python
import curses

def main(stdscr):
    # stdscr is the main, full-screen Window object.
    # curses.wrapper() has already called initscr(), noecho(),
    # cbreak(), and stdscr.keypad(True) for you before this
    # function runs.
    stdscr.addstr(0, 0, "Hello, curses!")
    stdscr.refresh()
    stdscr.getch()  # block until any key is pressed

curses.wrapper(main)
```

`curses.wrapper(func, /, *args, **kwds)` does the following, in order:

1. Calls `initscr()`, which determines your terminal type, sends the appropriate setup codes, and returns the `stdscr` window object representing the whole screen.
2. Calls `noecho()` — keystrokes are no longer automatically echoed to the screen (you decide what appears).
3. Calls `cbreak()` — keystrokes are available to your program immediately, without the user pressing Enter (this is "cbreak mode," as opposed to the default "cooked mode").
4. Calls `stdscr.keypad(True)` — special keys (arrow keys, F-keys, Home/End) get translated into single logical constants like `curses.KEY_UP` instead of arriving as multi-byte escape sequences you'd have to parse yourself.
5. Calls `func(stdscr, *args, **kwds)` — your actual program.
6. **Regardless of whether step 5 raised an exception**, restores the terminal: turns keypad translation off, turns echo back on, leaves cbreak mode, and calls `endwin()`.
7. If step 5 raised, the exception is re-raised *after* cleanup — so you still see your real Python traceback, printed normally to a restored terminal, instead of it being swallowed or garbled.

This is the single most important habit in this whole guide: **never call `initscr()` yourself in real code.** Always go through `wrapper()`. The only time you'd call `initscr()` directly is if you're doing something wrapper() genuinely can't accommodate (rare), and even then you'd hand-roll the same try/finally structure wrapper() gives you for free.

### What if my program needs to print something *after* curses exits?

This is common — e.g., "print an error message to stderr and exit with a nonzero code." Since `wrapper()` restores the terminal before returning (or before propagating an exception), this pattern works cleanly:

```python
import curses
import sys

def run(stdscr):
    stdscr.addstr(0, 0, "Working...")
    stdscr.refresh()
    stdscr.getch()
    return "some result"

try:
    result = curses.wrapper(run)
except KeyboardInterrupt:
    # terminal is already restored by wrapper() before this fires
    print("Interrupted by user.", file=sys.stderr)
    sys.exit(1)

print(f"Done. Result: {result}")
```

Because the terminal was already un-curses'd by the time `wrapper()` returns or raises, ordinary `print()` after it behaves exactly like ordinary `print()` in any other script.

---

## 3. The coordinate system and the core drawing model

This trips up almost everyone coming from GUI programming, so it's worth stating baldly and early:

> **In curses, all coordinates are `(y, x)` — row first, then column. Not `(x, y)`.**

Every method that takes a position — `addstr(y, x, text)`, `move(y, x)`, `derwin(nlines, ncols, begin_y, begin_x)` — follows this convention. It's consistent throughout the library, but it's the opposite of almost every other graphics API you've used, and it will bite you the first several times.

**Rows and columns are zero-indexed.** The top-left character cell of any window is `(0, 0)`. If a window is 24 rows tall and 80 columns wide (`stdscr.getmaxyx()` would return `(24, 80)`), then valid `y` values are `0` through `23`, and valid `x` values are `0` through `79`.

**The whole terminal is a grid of fixed-size character cells.** There is no sub-pixel positioning, no partial characters. Everything you draw snaps to this grid. Terminal size is measured in "how many rows and columns of text fit," which depends on the user's font size and terminal window size, so you generally shouldn't hard-code an assumed screen size — you query it (`stdscr.getmaxyx()`) and lay out relative to whatever you get back.

**Writing past the last valid cell of a window normally throws an error.** If your window is 80 columns wide and you try to write a 5-character string starting at column 78, you're asking curses to write into column 82, which doesn't exist, and by default this raises `curses.error`. There's one specific, deliberate exception to this that's worth knowing: writing to the very last cell of the very last line of `stdscr` (bottom-right corner) is a special case some terminals mishandle by auto-scrolling, so curses errors on it defensively. In general: assume writing off the edge of a window throws, and clip your own strings before you draw them, or wrap the call in `try/except curses.error: pass` at boundaries you don't fully control (e.g., dynamic text near a window edge).

---

## 4. Windows, subwindows, and derwins

### The window is the fundamental unit

Everything you draw in curses, you draw onto a `Window` object. `stdscr`, the object `wrapper()` hands you, is just the window representing the entire terminal. You are free to — and for anything beyond a single screen of static text, you *should* — create additional windows: rectangular regions that you draw into independently, each with its own local `(0,0)` origin.

Two ways to make a new window:

**`curses.newwin(nlines, ncols, begin_y, begin_x)`** — creates a brand-new, independent window at an absolute position on the terminal. It has no relationship to `stdscr` other than sharing the same physical screen.

**`parent_win.derwin(nlines, ncols, begin_y, begin_x)`** — creates a window whose position is expressed *relative to its parent's origin*, and which is understood by curses to be a sub-region of that parent. ("derwin" = "derived window.") There's also `parent_win.subwin(...)`, which is nearly identical but takes absolute (not parent-relative) coordinates — `derwin` is almost always what you want because you don't have to recompute absolute offsets by hand every time you reposition the parent.

```python
import curses

def main(stdscr):
    stdscr.clear()
    max_y, max_x = stdscr.getmaxyx()

    # A header bar: full width, 1 row tall, at the very top.
    header = stdscr.derwin(1, max_x, 0, 0)
    header.addstr(0, 0, " My App ".center(max_x, "="))

    # A sidebar: 20 columns wide, starting just below the header,
    # running to just above the bottom row (reserved for a status bar).
    sidebar = stdscr.derwin(max_y - 2, 20, 1, 0)
    sidebar.box()  # draws a border using default box-drawing characters
    sidebar.addstr(1, 2, "Menu")

    # A main content area: everything to the right of the sidebar.
    content = stdscr.derwin(max_y - 2, max_x - 20, 1, 20)
    content.box()
    content.addstr(1, 2, "Content goes here")

    # A status bar: full width, 1 row tall, at the very bottom.
    status = stdscr.derwin(1, max_x, max_y - 1, 0)
    status.addstr(0, 0, "Press q to quit")

    for win in (header, sidebar, content, status):
        win.noutrefresh()
    curses.doupdate()

    stdscr.getch()

curses.wrapper(main)
```

A few things worth calling out in that example:

- Each sub-window has its **own local coordinate system**. `sidebar.addstr(1, 2, "Menu")` writes to row 1, column 2 *of the sidebar*, which curses translates internally to the correct absolute screen position. You never do that translation math yourself.
- `.box()` is a convenience method that draws a border of default line-drawing characters (`│`, `─`, corner pieces) just inside the window's own edges. It's genuinely one of the most-used single calls in any curses program with a visible UI, because "draw a box around this region" is such a common operation.
- Note `.noutrefresh()` and `curses.doupdate()` instead of `.refresh()` on each window — that's covered properly in the next section, but the short version: when you have multiple windows, refreshing them individually causes visible flicker; batching the update avoids it.

### Windows can be moved and resized after creation

`win.mvwin(new_y, new_x)` repositions a window without changing its size. `win.resize(nlines, ncols)` changes its size without moving its origin. These matter a lot for handling terminal resize events (§10) — rather than destroying and recreating your layout from scratch on every resize, you often just resize and reposition the windows you already have.

---

## 5. Text output: `addstr`, attributes, and the refresh model

### The core method

`win.addstr([y, x,] text[, attr])` writes `text` into `win`, starting at the cursor's current position, or at `(y, x)` if you provide it. This is what you'll call more than any other method in a curses program.

```python
win.addstr("Plain text")                    # write at current cursor position
win.addstr(5, 10, "Positioned text")         # move to (5,10), then write
win.addstr(5, 10, "Bold text", curses.A_BOLD)  # positioned, with an attribute
```

There's also `addch(y, x, ch[, attr])` for writing a single character (useful when the character might be a special box-drawing constant like `curses.ACS_VLINE` rather than a plain string), and `insstr` / `insch` variants that insert rather than overwrite, shifting existing content right.

### Attributes — how you get bold, underline, and reverse video

Text attributes are bitmask constants you pass as the final argument to `addstr`/`addch`, or set as the "current" attribute for a window with `win.attron(attr)` / `win.attroff(attr)` / `win.attrset(attr)`:

| Constant | Effect |
|---|---|
| `curses.A_NORMAL` | No attributes (the default) |
| `curses.A_BOLD` | Bold / bright |
| `curses.A_DIM` | Dim (support varies by terminal) |
| `curses.A_UNDERLINE` | Underlined |
| `curses.A_REVERSE` | Swap foreground/background (great for a "selected" highlight) |
| `curses.A_BLINK` | Blinking (many modern terminals ignore this) |
| `curses.A_STANDOUT` | Terminal's own "make this stand out" mode, whatever that means locally |
| `curses.A_ITALIC` | Italic (support varies; not universal) |

Attributes combine with bitwise OR:

```python
win.addstr(0, 0, "Warning", curses.A_BOLD | curses.A_UNDERLINE)
```

`attron`/`attroff` are useful when several consecutive `addstr` calls should share an attribute without repeating it each time:

```python
win.attron(curses.A_REVERSE)
win.addstr(row, 0, item_text)
win.attroff(curses.A_REVERSE)
```

### `refresh()` vs. `noutrefresh()` + `doupdate()` — the single most important performance concept

Here's the model you need to internalize: **windows are drawn to in memory first, and only actually painted to the physical terminal when you tell curses to sync.**

- `win.refresh()` does two things: it (1) copies the window's in-memory contents into curses's internal "virtual screen" representation, then (2) immediately compares that virtual screen against what's physically on the terminal and sends the minimal set of terminal control codes to reconcile the difference.
- `win.noutrefresh()` does only step (1) — updates the virtual screen — **without** touching the physical terminal.
- `curses.doupdate()` does only step (2) — compares the virtual screen to the physical terminal, once, and sends the minimal diff.

If you have five windows and you call `.refresh()` on each of them in a loop, you trigger **five separate physical terminal writes**, each one independently computing and sending a diff — and because each write happens before the next window's content is even in the virtual screen yet, users can see partial, flickery intermediate states, especially over a laggy SSH connection.

If instead you call `.noutrefresh()` on all five, then call `curses.doupdate()` once, curses builds up the complete "what should the whole screen look like now" picture in memory first, and *then* computes a single minimal diff against the real terminal and sends it once. This is dramatically less flickery and, for anything beyond a trivially simple single-window program, is the pattern you should default to.

**Rule of thumb:** if you're only ever touching one window, `.refresh()` is fine and simpler. The moment you have two or more windows you're updating together (which is essentially always, once you have a header/sidebar/content-style layout), switch to `noutrefresh()` on each, followed by exactly one `curses.doupdate()` at the end of your draw pass.

### Clearing and erasing

`win.clear()` and `win.erase()` both blank the window, but `clear()` additionally forces the *next* refresh to fully repaint the terminal region from scratch (setting an internal "needs total redraw" flag), whereas `erase()` just blanks the in-memory window and lets the normal diffing logic figure out the minimal repaint. Prefer `erase()` in your regular per-frame redraw loop; reach for `clear()` only when you specifically need to force a full repaint (e.g., after some external process may have scribbled on the terminal, or right after a resize).

---

## 6. Color

### Initialization is mandatory and must happen before you use any color

```python
curses.start_color()
```

Call this once, early — `wrapper()` doesn't call it for you automatically. It's safe to call even on terminals with no color support; check `curses.has_colors()` first if you want to degrade gracefully rather than assume color is available.

### Color pairs, not raw foreground/background

curses colors work through **pairs**, not independent foreground/background values, for historical reasons tied to how terminals actually implement color at the hardware/protocol level. You define a pair once, then reference that pair by number wherever you want that combination:

```python
curses.start_color()
curses.init_pair(1, curses.COLOR_RED, curses.COLOR_BLACK)     # pair 1: red on black
curses.init_pair(2, curses.COLOR_GREEN, curses.COLOR_BLACK)   # pair 2: green on black
curses.init_pair(3, curses.COLOR_BLACK, curses.COLOR_WHITE)   # pair 3: black on white (good for a selection highlight)

win.addstr(0, 0, "Error!", curses.color_pair(1))
win.addstr(1, 0, "Success", curses.color_pair(2))
win.addstr(2, 0, "Selected item", curses.color_pair(3))
```

The base colors available on every terminal are `curses.COLOR_BLACK`, `_RED`, `_GREEN`, `_YELLOW`, `_BLUE`, `_MAGENTA`, `_CYAN`, `_WHITE`. `curses.color_pair(n)` converts a pair number into the attribute bitmask you pass to `addstr` — and it composes with other attributes the same way: `curses.color_pair(1) | curses.A_BOLD`.

**Pair 0 is reserved** — it always means "the terminal's default foreground and background" and you cannot redefine it with `init_pair`.

### Extended / 256-color and truecolor support

Whether you get access to more than the 8 base colors depends on the terminal and how curses was compiled. Check `curses.COLORS` (the max color count the current terminal reports) and `curses.COLOR_PAIRS` (max simultaneous pairs) before assuming you have access to, say, 256 colors or arbitrary RGB. If `curses.COLORS >= 256`, you can generally call `init_pair` with color numbers `0`–`255` directly (the numbering follows the standard 256-color terminal palette) rather than being limited to the 8 named constants. True 24-bit RGB support exists in newer curses/ncurses builds via `curses.init_color()` for custom palette entries, but support is inconsistent across terminal emulators — test on your actual target environment rather than assuming.

---

## 7. Input handling: keys, mouse, and non-blocking reads

### The basic call: `getch()`

`win.getch([y, x])` reads a single keystroke. By default this **blocks** — your program does nothing until the user presses a key. It returns an integer: either the ordinal value of a plain character, or one of the `curses.KEY_*` constants for special keys (assuming `keypad(True)` is set, which `wrapper()` does for you on `stdscr` — remember to also call it on any other window you create if you want that window to read special keys directly from it).

```python
key = stdscr.getch()

if key == ord('q'):
    break
elif key == curses.KEY_UP:
    cursor_row -= 1
elif key == curses.KEY_DOWN:
    cursor_row += 1
elif key in (curses.KEY_ENTER, 10, 13):  # KEY_ENTER, \n, \r — cover all cases
    select_item()
```

That last line demonstrates a real-world quirk: `curses.KEY_ENTER` corresponds to the *numeric keypad* Enter key on many systems, while the main Enter key often comes through as plain `\n` (10) or `\r` (13) depending on the terminal. Checking all three is standard defensive practice.

`win.getkey()` is an alternative that returns a *string* instead of an int — `'q'`, `'KEY_UP'`, etc. — which some people find more readable, at the cost of string-comparison overhead and slightly different handling at the edges. Both are widely used; pick one and be consistent.

### Non-blocking and timed input

Blocking on every keystroke is wrong the moment you need your program to do *anything* on its own — animate something, update a clock, poll a background task — while also listening for input. Two ways to avoid blocking forever:

```python
win.nodelay(True)   # getch() returns curses.ERR (-1) immediately if no key is waiting
key = win.getch()
if key == curses.ERR:
    pass  # no input this cycle — do other work
```

```python
win.timeout(150)     # getch() blocks for AT MOST 150ms, then returns curses.ERR if nothing arrived
key = win.getch()
```

`timeout()` is generally the better default for an interactive app's main loop: it gives you a natural "tick rate" (e.g., 100–150ms) at which your loop wakes up to redraw or poll something, without the CPU-spinning of a pure `nodelay(True)` busy-loop, and without the total unresponsiveness of a fully blocking call.

### Mouse support

```python
curses.mousemask(curses.ALL_MOUSE_EVENTS)
```

Call once during setup. Then, `curses.KEY_MOUSE` will show up as a return value from `getch()` when a mouse event occurs; call `curses.getmouse()` immediately after to retrieve the event details as a tuple `(id, x, y, z, bstate)`, where `bstate` is a bitmask you compare against constants like `curses.BUTTON1_CLICKED`, `curses.BUTTON1_PRESSED`, etc. Mouse support depends on terminal emulator cooperation and is more inconsistent across environments than keyboard input — test on your actual target terminals rather than assuming full parity with a GUI mouse model.

### Special-key constants worth knowing

| Constant | Key |
|---|---|
| `curses.KEY_UP`, `KEY_DOWN`, `KEY_LEFT`, `KEY_RIGHT` | Arrow keys |
| `curses.KEY_HOME`, `KEY_END` | Home / End |
| `curses.KEY_PPAGE`, `KEY_NPAGE` | Page Up / Page Down |
| `curses.KEY_BACKSPACE` | Backspace (also sometimes arrives as `127` or `8` — check both) |
| `curses.KEY_DC` | Delete |
| `curses.KEY_F1`...`KEY_F12` | Function keys |
| `curses.KEY_RESIZE` | The terminal was resized (see §10) |
| `curses.KEY_MOUSE` | A mouse event occurred |

---

## 8. Text input widgets with `curses.textpad`

Raw curses gives you no built-in "text field" — you'd have to track a cursor position, handle backspace, handle line wrapping, and redraw on every keystroke yourself. `curses.textpad` provides exactly one step up from that: a basic single/multi-line editable text box.

```python
import curses
from curses.textpad import Textbox, rectangle

def main(stdscr):
    stdscr.addstr(0, 0, "Enter a message (Ctrl-G to submit): ")
    stdscr.refresh()

    # Draw a visible border for the input area.
    editwin_y, editwin_x = 2, 2
    editwin_h, editwin_w = 3, 40
    rectangle(
        stdscr,
        editwin_y - 1, editwin_x - 1,
        editwin_y + editwin_h, editwin_x + editwin_w,
    )
    stdscr.refresh()

    editwin = curses.newwin(editwin_h, editwin_w, editwin_y, editwin_x)
    box = Textbox(editwin)

    # edit() blocks until the user presses Ctrl-G (ASCII BEL, 0x07),
    # which is the textpad convention for "submit."
    box.edit()

    message = box.gather()
    stdscr.addstr(6, 0, f"You entered: {message!r}")
    stdscr.refresh()
    stdscr.getch()

curses.wrapper(main)
```

**The Ctrl-G quirk, explained properly:** `Textbox.edit()` terminates on Ctrl-G by default (ASCII `BEL`, decimal 7 — `curses.ascii.BEL`), *not* on Enter. This surprises almost everyone the first time, because every other text input paradigm in existence submits on Enter. If you want Enter-to-submit behavior (which you almost always do, for a normal-feeling app), you supply a `validate` callback to `edit()`: a function that receives each keystroke and returns the keystroke to actually process, letting you intercept and remap specific keys before textpad's internal logic sees them.

```python
def enter_is_submit(key):
    if key in (curses.KEY_ENTER, curses.ascii.CR, curses.ascii.NL):
        return curses.ascii.BEL  # remap Enter to what edit() treats as "done"
    return key

box.edit(enter_is_submit)
```

`Textbox.gather()` returns the current contents of the box as a string (with trailing whitespace on each line stripped, by default — this is controlled by the window's `.stripspaces` attribute, which is `1` on the window a `Textbox` wraps, by default).

`curses.textpad.rectangle(win, uly, ulx, lry, lrx)` is a free-standing helper — note it's a module-level function, not a window method — that draws a rectangle border using the corner coordinates you give it (upper-left y/x, lower-right y/x), which is handy for drawing a border *around* an editable window without that border being erased and redrawn by the textbox's own editing logic (since the border lives on the *parent* window, not inside the edit window itself).

For anything beyond "get one line or a few lines of raw text," you'll typically end up writing your own input-handling logic on top of raw `getch()` calls rather than fighting `Textbox`'s more limited feature set (no cursor-position-aware backspace across a multi-line box in every version, no built-in placeholder text, etc.) — but for a simple prompt, it's exactly the right amount of tool.

---

## 9. Panels: managing overlapping windows

Plain curses windows have no concept of stacking order — if two windows overlap and you refresh both, whichever one you refreshed *last* wins for the overlapping region, and you'd have to manage that ordering by hand. The moment you want something like a modal dialog that sits *on top of* your main content and can later be dismissed to reveal what was underneath, unmanaged, that gets fiddly fast.

`curses.panel` solves exactly this: it adds a z-ordering ("stacking") layer on top of ordinary windows.

```python
import curses
import curses.panel

def main(stdscr):
    stdscr.addstr(0, 0, "Main content window")
    stdscr.addstr(1, 0, "Press 'd' to toggle a dialog on top of this")
    stdscr.refresh()

    dialog_win = curses.newwin(7, 30, 5, 10)
    dialog_win.box()
    dialog_win.addstr(1, 2, "This is a dialog!")
    dialog_win.addstr(2, 2, "Press 'd' again to hide it")

    dialog_panel = curses.panel.new_panel(dialog_win)
    dialog_panel.hide()  # start hidden

    while True:
        curses.panel.update_panels()  # sync panel stack -> virtual screen
        curses.doupdate()             # sync virtual screen -> physical terminal

        key = stdscr.getch()
        if key == ord('q'):
            break
        elif key == ord('d'):
            if dialog_panel.hidden():
                dialog_panel.show()
                dialog_panel.top()  # ensure it's above everything else
            else:
                dialog_panel.hide()

curses.wrapper(main)
```

Key panel operations:

- `curses.panel.new_panel(win)` — wraps an existing window in a panel, added to the top of the stack.
- `panel.top()` / `panel.bottom()` — move a panel to the top or bottom of the stacking order.
- `panel.above()` / `panel.below()` — query the panel immediately above/below this one in the stack.
- `panel.hide()` / `panel.show()` / `panel.hidden()` — remove/restore a panel from the stack without destroying its underlying window (its content is preserved; it just isn't composited while hidden).
- `panel.replace(new_win)` — swap out a panel's underlying window for a different one, keeping its position in the stack.
- `curses.panel.update_panels()` — this is the crucial one. It doesn't touch the physical terminal at all; it walks the current panel stack and updates curses's internal virtual screen to reflect proper stacking order (so overlapping content is composited correctly, bottom-to-top). You still need `curses.doupdate()` afterward to actually paint that virtual screen to the terminal — the two-step "virtual then physical" split from §5 applies here too, just at the panel-stack level instead of the individual-window level.

If your whole application is a single window with no overlays or modals, skip `curses.panel` entirely — it's genuinely unnecessary overhead for that case. Reach for it the moment you have two or more things that can visually overlap and you need explicit control over which one is "on top."

---

## 10. Handling terminal resize

Users resize their terminal windows constantly, and a TUI that doesn't handle this gracefully — garbled layout, text bleeding outside its intended box, a crash — feels broken immediately. Handling resize properly has two parts.

### Part 1: detecting that a resize happened

On most Unix systems, a terminal resize sends the process a `SIGWINCH` signal. curses translates this, at the Python level, into the pseudo-keystroke `curses.KEY_RESIZE` showing up as a `getch()` return value — so if you're already checking `getch()`'s return value in your main loop (you are), you get resize notification for free, through the same channel as every other keystroke:

```python
key = stdscr.getch()
if key == curses.KEY_RESIZE:
    handle_resize(stdscr)
```

### Part 2: actually re-laying-out on resize

Detecting the event is the easy part; recomputing everything that depended on the old terminal size is the actual work, and there's no way around doing this yourself, because curses has no idea what "layout" means to your application — that's what your architecture layer (§11) is for.

The one curses-level helper worth knowing here is `curses.update_lines_cols()`. Calling it refreshes the module-level `curses.LINES` and `curses.COLS` values (and re-queries the terminal's actual dimensions), which some code paths read from directly instead of calling `stdscr.getmaxyx()`. It's good practice to call it as the first thing you do in your resize handler, before anything else queries the terminal's dimensions:

```python
def handle_resize(stdscr):
    curses.update_lines_cols()
    max_y, max_x = stdscr.getmaxyx()

    stdscr.erase()

    # Recompute and resize/reposition every window your layout owns.
    # For a header/sidebar/content/status layout like §4's example:
    header.resize(1, max_x)

    sidebar_height = max_y - 2
    sidebar.resize(sidebar_height, 20)

    content.resize(sidebar_height, max_x - 20)
    content.mvwin(1, 20)

    status.mvwin(max_y - 1, 0)
    status.resize(1, max_x)

    # Redraw content into the newly-sized windows.
    redraw_everything()
```

**Watch for a terminal shrunk smaller than your minimum layout can support.** If a user drags their terminal down to 10 columns wide and your sidebar alone wants 20, your resize math will produce negative or nonsensical dimensions, and `resize()`/`derwin()` calls will start throwing `curses.error`. Defensive code checks `max_y`/`max_x` against known minimums and either clamps sub-window sizes to something sane (even if content gets clipped or hidden) or displays a simple "terminal too small" message instead of attempting your full layout.

---

## 11. Building an event loop and an application architecture

Raw curses has no concept of an "application" — no `App` base class, no event dispatch system, no widget tree. You build that structure yourself, and the shape it takes matters a lot for how maintainable your program stays as it grows past a hundred lines or so.

### The minimal loop shape

Every non-trivial curses program eventually converges on some variant of this:

```python
def main(stdscr):
    curses.curs_set(0)      # hide the blinking terminal cursor (0=invisible, 1=normal, 2=very visible)
    stdscr.timeout(100)     # non-blocking-ish getch(), ~10 ticks/sec
    curses.start_color()
    # ... init_pair calls, initial window creation ...

    running = True
    while running:
        key = stdscr.getch()

        if key == curses.KEY_RESIZE:
            handle_resize(stdscr)
        elif key != curses.ERR:
            running = handle_key(key)   # your app's key-dispatch logic

        # Redraw every tick, whether or not a key was pressed —
        # this is what lets you animate things or reflect
        # background state changes even with no input.
        draw(stdscr)

    # loop exits -> wrapper() cleans up the terminal for you

curses.wrapper(main)
```

### A slightly more structured shape: an explicit application object

For anything with more than one "screen" (a main view, a settings dialog, a help overlay), it pays to model state explicitly rather than accumulating a pile of booleans and `if` branches in one function:

```python
import curses

class App:
    def __init__(self, stdscr):
        self.stdscr = stdscr
        self.running = True
        self.mode = "main"   # "main", "help", "confirm_quit", ...
        self.items = ["Alpha", "Bravo", "Charlie"]
        self.selected = 0

    def run(self):
        curses.curs_set(0)
        self.stdscr.timeout(100)
        while self.running:
            key = self.stdscr.getch()
            if key == curses.KEY_RESIZE:
                curses.update_lines_cols()
            elif key != curses.ERR:
                self.handle_key(key)
            self.draw()

    def handle_key(self, key):
        if self.mode == "main":
            self._handle_key_main(key)
        elif self.mode == "help":
            self._handle_key_help(key)

    def _handle_key_main(self, key):
        if key == ord('q'):
            self.running = False
        elif key == curses.KEY_UP:
            self.selected = max(0, self.selected - 1)
        elif key == curses.KEY_DOWN:
            self.selected = min(len(self.items) - 1, self.selected + 1)
        elif key == ord('?'):
            self.mode = "help"

    def _handle_key_help(self, key):
        # any key dismisses help
        self.mode = "main"

    def draw(self):
        self.stdscr.erase()
        if self.mode == "main":
            self._draw_main()
        elif self.mode == "help":
            self._draw_help()
        self.stdscr.noutrefresh()
        curses.doupdate()

    def _draw_main(self):
        for i, item in enumerate(self.items):
            attr = curses.A_REVERSE if i == self.selected else curses.A_NORMAL
            self.stdscr.addstr(i, 0, item, attr)
        self.stdscr.addstr(len(self.items) + 1, 0, "? for help, q to quit")

    def _draw_help(self):
        self.stdscr.addstr(0, 0, "Arrow keys to move, q to quit.")
        self.stdscr.addstr(1, 0, "Press any key to return.")


def main(stdscr):
    App(stdscr).run()

curses.wrapper(main)
```

This is still simple, but the seams are now obvious places to grow from: `mode` could become a proper state-machine/stack (so "help" can be dismissed back to whatever mode was active before it, rather than always to `"main"`); `_draw_main`/`_handle_key_main` could each become their own small class if the main screen gets complex enough to deserve one; `self.items` could be replaced with a data model that's decoupled from drawing entirely. The point isn't that this exact shape is "correct" — it's that **explicitly separating "what state am I in," "how do I react to input in that state," and "how do I draw that state"** is what keeps a curses program from turning into an unmaintainable tangle of nested conditionals, and that separation is on *you* to build, because curses gives you none of it.

### `erase()` every frame vs. selective redraw

The loop above calls `stdscr.erase()` unconditionally every tick and redraws everything from scratch. For small-to-medium UIs at a 100ms tick rate, this is completely fine — curses's diffing at `doupdate()` time means the *physical* terminal only gets writes for cells that actually changed, even though your *logical* drawing code redrew the whole screen. Don't prematurely optimize by trying to track "what actually changed" yourself and only touching those cells — that's real complexity, and curses is already doing the diffing for you at the layer where it matters (the physical write), so you rarely need to duplicate that work at your own application layer too. Reach for manual dirty-tracking only if profiling shows your *drawing computations themselves* (not the terminal writes) are the bottleneck.

---

## 12. A complete worked example: a task manager TUI

This ties together windows, colors, input handling, resize handling, and an explicit application structure into one runnable program: a simple task list where you can add tasks, mark them done, delete them, and navigate with arrow keys.

```python
#!/usr/bin/env python3
"""A minimal terminal task manager built with curses."""

import curses
import curses.ascii
from curses.textpad import Textbox


class Task:
    def __init__(self, text, done=False):
        self.text = text
        self.done = done


class TaskManagerApp:
    def __init__(self, stdscr):
        self.stdscr = stdscr
        self.running = True
        self.tasks = [
            Task("Write the curses guide"),
            Task("Review pull request", done=True),
            Task("Reply to emails"),
        ]
        self.selected = 0
        self.mode = "list"  # "list" or "adding"

        self._setup_colors()
        self._build_windows()

    def _setup_colors(self):
        curses.start_color()
        curses.use_default_colors()
        curses.init_pair(1, curses.COLOR_GREEN, -1)   # done tasks
        curses.init_pair(2, curses.COLOR_BLACK, curses.COLOR_WHITE)  # selection
        curses.init_pair(3, curses.COLOR_YELLOW, -1)  # header/status accents

    def _build_windows(self):
        max_y, max_x = self.stdscr.getmaxyx()
        self.max_y, self.max_x = max_y, max_x

        self.header = self.stdscr.derwin(1, max_x, 0, 0)
        self.list_win = self.stdscr.derwin(max_y - 3, max_x, 1, 0)
        self.status = self.stdscr.derwin(1, max_x, max_y - 1, 0)
        self.input_border = self.stdscr.derwin(1, max_x, max_y - 2, 0)

    def run(self):
        curses.curs_set(0)
        self.stdscr.timeout(100)
        while self.running:
            key = self.stdscr.getch()

            if key == curses.KEY_RESIZE:
                self._handle_resize()
            elif key != curses.ERR:
                if self.mode == "list":
                    self._handle_key_list(key)
                # "adding" mode is handled synchronously inside
                # _start_add_task() via Textbox.edit(), so no
                # branch is needed for it here.

            self._draw()

    def _handle_resize(self):
        curses.update_lines_cols()
        self.stdscr.erase()
        self._build_windows()

    def _handle_key_list(self, key):
        if key in (ord('q'), curses.ascii.ESC):
            self.running = False
        elif key == curses.KEY_UP:
            self.selected = max(0, self.selected - 1)
        elif key == curses.KEY_DOWN:
            self.selected = min(len(self.tasks) - 1, self.selected + 1)
        elif key in (curses.KEY_ENTER, curses.ascii.CR, curses.ascii.NL) and self.tasks:
            self.tasks[self.selected].done = not self.tasks[self.selected].done
        elif key in (curses.KEY_DC, ord('d')) and self.tasks:
            del self.tasks[self.selected]
            self.selected = max(0, min(self.selected, len(self.tasks) - 1))
        elif key == ord('a'):
            self._start_add_task()

    def _start_add_task(self):
        """Runs its own tiny blocking sub-loop via Textbox.edit()."""
        self.mode = "adding"
        self._draw()  # show the "type your task" prompt before blocking on edit()

        edit_h, edit_w = 1, self.max_x - 12
        edit_win = curses.newwin(edit_h, edit_w, self.max_y - 2, 11)
        box = Textbox(edit_win)

        def enter_submits(key):
            if key in (curses.KEY_ENTER, curses.ascii.CR, curses.ascii.NL):
                return curses.ascii.BEL
            return key

        curses.curs_set(1)
        box.edit(enter_submits)
        curses.curs_set(0)

        text = box.gather().strip()
        if text:
            self.tasks.append(Task(text))
            self.selected = len(self.tasks) - 1

        self.mode = "list"

    def _draw(self):
        self.stdscr.erase()

        self.header.erase()
        self.header.addstr(0, 0, " TASKS ".center(self.max_x, "="), curses.color_pair(3))

        self.list_win.erase()
        if not self.tasks:
            self.list_win.addstr(0, 2, "(no tasks — press 'a' to add one)")
        for i, task in enumerate(self.tasks):
            if i >= self.list_win.getmaxyx()[0]:
                break  # don't try to draw past the window — avoid curses.error
            mark = "[x]" if task.done else "[ ]"
            line = f"{mark} {task.text}"
            attr = curses.A_NORMAL
            if task.done:
                attr |= curses.color_pair(1)
            if i == self.selected:
                attr = curses.color_pair(2)
            try:
                self.list_win.addstr(i, 0, line.ljust(self.max_x), attr)
            except curses.error:
                pass  # defensive: swallow edge-of-window write errors

        self.status.erase()
        if self.mode == "adding":
            self.status.addstr(0, 0, "New task: ", curses.color_pair(3))
        else:
            self.status.addstr(0, 0, "↑/↓ move  Enter toggle done  d delete  a add  q quit")

        for win in (self.header, self.list_win, self.status):
            win.noutrefresh()
        curses.doupdate()


def main(stdscr):
    TaskManagerApp(stdscr).run()


if __name__ == "__main__":
    curses.wrapper(main)
```

Notes on choices made in this example, since a "comprehensive guide" should explain *why*, not just *what*:

- **`curses.use_default_colors()`** is called during setup, and `-1` is used as a color value in `init_pair` calls. This is a genuinely useful trick not covered earlier: by default, curses color pairs force *both* foreground and background, meaning if the user's terminal has a customized background (not pure black), your UI ignores it and paints its own black background everywhere. `use_default_colors()` plus passing `-1` for either the foreground or background argument to `init_pair` means "use whatever the terminal's actual default is for this slot," letting your colored text sit on the user's real terminal background instead of clobbering it.
- **`_start_add_task()` runs its own nested blocking loop** via `Textbox.edit()`, rather than trying to fold text-input character handling into the main event loop's `getch()` dispatch. This is a legitimate and common pattern for simple TUIs: instead of building a full non-blocking state machine for text entry, you temporarily hand control to a self-contained blocking widget, and when it returns, you're back in your normal loop. It's less "correct" in a strict async sense than routing everything through one non-blocking loop, but it's dramatically simpler to write and reason about, and for something like "type a short line of text to add a task," the user isn't going to notice or care that input briefly became blocking.
- **The `try/except curses.error: pass` around `addstr`** in the list-drawing loop is deliberate defensive coding for exactly the edge-of-window situation described in §3 — if `line.ljust(self.max_x)` happens to produce something one character too long for a particular terminal width edge case, this swallows the resulting error rather than crashing the whole app.
- **The bounds check `if i >= self.list_win.getmaxyx()[0]: break`** prevents trying to draw more task rows than the window has room for after a resize shrinks it — silently truncating the visible list rather than throwing.

---

## 13. Common pitfalls and how to debug them

**"My terminal is broken/garbled after my program crashed."** You called `initscr()` (or otherwise touched terminal state) outside of `curses.wrapper()`, or an exception occurred in a code path that bypassed wrapper's cleanup somehow. Run `reset` (or `tput reset`) in your terminal to fix it immediately, and audit your code to make sure literally everything runs inside the function you pass to `wrapper()`.

**`_curses.error: addwstr() returned ERR` (or similar) when writing text.** Almost always means you tried to write outside the bounds of the window — often after a resize shrank a window smaller than the text you're unconditionally writing into it, or an off-by-one in manual layout math. Add bounds checks before the `addstr` call, or wrap in `try/except curses.error`.

**Special keys (arrows, F-keys) show up as garbage escape sequences instead of `curses.KEY_UP` etc.** You created a window with `curses.newwin()` and are calling `getch()` on *that* window directly, but forgot `win.keypad(True)` on it — `wrapper()` only sets this on `stdscr` automatically, not on windows you create yourself.

**Program appears to hang.** Check whether you're calling a blocking `getch()` somewhere you meant to call a non-blocking or timed one (§7), or whether an unhandled `curses.error` inside your draw logic is being silently caught by an over-broad `except Exception: pass` somewhere in your loop and effectively freezing your redraw without you realizing it.

**Colors look wrong, or all text is black-on-black / invisible.** Check `curses.has_colors()` — you might be on a terminal without color support, and code that assumes color pairs are meaningful will produce nonsense. Also double-check you called `curses.start_color()` at all, and that you're not accidentally reusing pair `0` (reserved, always default) for something you meant to customize.

**Flickering, especially over SSH.** You're very likely calling `.refresh()` on multiple windows individually instead of `.noutrefresh()` + a single `curses.doupdate()` — see §5.

**`curses.error: setupterm: could not find terminal` or similar, when running inside some other process/harness (CI, certain sandboxes, some IDE "run" panels, some containers/pipelines).** curses needs `TERM` to be set to something with a corresponding terminfo entry, and needs an actual TTY attached to standard input/output — not every environment your code might run inside provides one. This isn't a code bug; it's an environment that doesn't have a real interactive terminal for curses to attach to. Test interactively in a normal terminal emulator, not by piping the script's output or running it inside something that doesn't allocate a pty.

**Using `print()` instead of `addstr()` anywhere inside curses-managed code.** Once you're inside `wrapper()`'s function, `print()` output does not go where you expect and will corrupt your carefully-managed screen state — everything has to go through window methods. If you need to log/debug, write to a file instead (see next).

**Debugging technique: log to a file, not the screen.** Since you can't just `print()` for debugging while curses owns the terminal, set up a plain file logger at the top of your program (`logging.basicConfig(filename="debug.log", level=logging.DEBUG)`) and call `logging.debug(...)` from anywhere in your app logic. Then `tail -f debug.log` in a second terminal while your TUI runs in the first.

---

## 14. Platform notes (Windows, macOS, remote terminals)

**Windows:** the standard `curses` module is not part of the default Windows Python install. Install `windows-curses` (`pip install windows-curses`) to get an interface-compatible drop-in — your code otherwise runs unmodified. Some advanced/obscure functionality has historically had rougher edges on the Windows port than on native Unix ncurses, so if you're targeting Windows specifically, test there directly rather than assuming 1:1 parity, especially around color depth and certain special-key sequences.

**macOS:** works natively out of the box (it's Unix-like), same as Linux. The default Terminal.app supports the core feature set fine; more advanced things like true 24-bit color or certain mouse reporting modes may behave differently across Terminal.app, iTerm2, and other emulators — as with any terminal program, test on your actual target.

**Remote / SSH terminals:** curses works over SSH exactly as well as the terminal emulator on the far end supports it — there's nothing curses-specific to worry about beyond "some terminal emulators/multiplexers support fewer colors or mouse features than others," and beyond the general SSH-latency-causes-visible-flicker-if-you're-refreshing-inefficiently point from §5, which is exactly why the `noutrefresh()`/`doupdate()` batching pattern matters more, not less, in this context.

**Terminal multiplexers (tmux, screen):** generally fine, but be aware they add their own layer of terminal emulation, which occasionally introduces its own quirks around color count reporting or certain escape sequences on top of whatever the underlying terminal already has. If something behaves oddly specifically inside tmux/screen but not outside it, that's the first thing to suspect.

---

## 15. When to graduate to a framework instead

Everything in this guide is genuinely useful even if you end up using a higher-level framework, because frameworks like [Textual](https://textual.textualize.io/) are, underneath, doing conceptually the same things you just learned by hand: managing a screen buffer, diffing against the terminal, handling special keys, batching updates to avoid flicker. Understanding curses means you understand *why* those frameworks are built the way they are, and you'll debug them more effectively when something goes wrong.

That said, consider moving to a framework when:

- You want CSS-like styling and a real layout engine (flexbox-style containers, grid layouts) instead of manually computing every `derwin` offset by hand.
- You want a substantial library of ready-made, polished widgets — data tables with sorting, tabbed interfaces, tree views, progress bars, modal dialogs — rather than building each of those primitives yourself on top of raw windows and panels.
- You want the same application to also run in a web browser (Textual apps can be served as web pages via `textual serve`, with no separate web-specific code) — that's simply outside curses's scope entirely.
- Native Windows support without an extra dependency and extra testing surface matters to you.
- Your team is going to maintain this for years and you'd rather lean on a framework's test suite, documentation, and community than re-solve solved problems (resize edge cases, mouse-event normalization across terminals, accessibility considerations) yourself.

There's no shame in "learn curses to understand the terminal deeply, ship with Textual (or a comparable framework) in practice." That's a very common and entirely sensible path.

---

## 16. Reference: function/method cheat sheet

**Setup**

| Call | Purpose |
|---|---|
| `curses.wrapper(func, *args)` | Initialize, run `func(stdscr, *args)`, guarantee cleanup |
| `curses.curs_set(visibility)` | `0` hidden, `1` normal, `2` very visible |
| `curses.start_color()` | Enable color support |
| `curses.use_default_colors()` | Allow `-1` in `init_pair` to mean "terminal's actual default" |
| `curses.has_colors()` | Whether the terminal supports color at all |
| `curses.noecho()` / `curses.echo()` | Toggle keystroke echo |
| `curses.cbreak()` / `curses.nocbreak()` | Toggle immediate (vs. line-buffered) key availability |

**Windows**

| Call | Purpose |
|---|---|
| `curses.newwin(h, w, y, x)` | New independent window at absolute position |
| `win.derwin(h, w, y, x)` | New sub-window, parent-relative coordinates |
| `win.subwin(h, w, y, x)` | New sub-window, absolute coordinates |
| `win.mvwin(y, x)` | Move a window |
| `win.resize(h, w)` | Resize a window |
| `win.getmaxyx()` | Returns `(height, width)` |
| `win.getbegyx()` | Returns `(begin_y, begin_x)` |
| `win.box()` | Draw a default border just inside the window's edges |
| `win.erase()` / `win.clear()` | Blank contents (`clear()` also forces full repaint next refresh) |

**Drawing**

| Call | Purpose |
|---|---|
| `win.addstr([y, x,] text[, attr])` | Write a string |
| `win.addch([y, x,] ch[, attr])` | Write a single character |
| `win.attron(attr)` / `attroff(attr)` / `attrset(attr)` | Set attributes for subsequent writes |
| `curses.color_pair(n)` | Convert a pair number into an attribute bitmask |
| `curses.init_pair(n, fg, bg)` | Define color pair `n` |
| `win.move(y, x)` | Move the window's internal cursor without writing |

**Refresh**

| Call | Purpose |
|---|---|
| `win.refresh()` | Update virtual screen AND physically repaint — single-window case |
| `win.noutrefresh()` | Update virtual screen only — batch with others |
| `curses.doupdate()` | Physically repaint from virtual screen — call once after a batch |

**Input**

| Call | Purpose |
|---|---|
| `win.getch([y, x])` | Read one keystroke, as an int; blocking by default |
| `win.getkey([y, x])` | Same, but returns a string |
| `win.nodelay(bool)` | Make `getch()` return `curses.ERR` immediately if nothing waiting |
| `win.timeout(ms)` | Make `getch()` block for at most `ms` milliseconds |
| `win.keypad(bool)` | Translate special keys into `curses.KEY_*` constants |
| `curses.mousemask(mask)` | Enable mouse event reporting |
| `curses.getmouse()` | Retrieve details of a `curses.KEY_MOUSE` event |

**Text input**

| Call | Purpose |
|---|---|
| `curses.textpad.Textbox(win)` | Wrap a window as an editable text box |
| `box.edit([validate])` | Block until Ctrl-G (or your `validate` callback signals done) |
| `box.gather()` | Retrieve the box's current text as a string |
| `curses.textpad.rectangle(win, uly, ulx, lry, lrx)` | Draw a border by corner coordinates |

**Panels (`curses.panel`)**

| Call | Purpose |
|---|---|
| `curses.panel.new_panel(win)` | Wrap a window with z-order management |
| `panel.top()` / `bottom()` | Move within the stack |
| `panel.show()` / `hide()` / `hidden()` | Toggle visibility without destroying the window |
| `panel.replace(win)` | Swap underlying window, keep stack position |
| `curses.panel.update_panels()` | Composite the panel stack into the virtual screen |

**Resize**

| Call | Purpose |
|---|---|
| `curses.KEY_RESIZE` | Pseudo-keystroke returned by `getch()` on terminal resize |
| `curses.update_lines_cols()` | Re-query and refresh `curses.LINES`/`curses.COLS` |