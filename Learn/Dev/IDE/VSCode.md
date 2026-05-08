# Comprehensive Guide to Productivity in Visual Studio Code

## 1. Understanding the Interface

VS Code is organized around a few core areas:

- **Activity Bar** (far left): switches between views like Explorer, Search, Source Control, Extensions
- **Side Bar**: shows the contents of the active view
- **Editor Groups**: where files open; supports splits and tabs
- **Panel**: bottom area for Terminal, Output, Problems, Debug Console
- **Status Bar**: context-sensitive info at the very bottom

Familiarity with these regions makes navigation faster because most shortcuts map to one of them.

---

## 2. Essential Keyboard Shortcuts

Shortcuts below are listed as **Windows/Linux** | **macOS**. Where behavior differs meaningfully, both are noted.

### 2.1 Command Palette and Quick Open

The Command Palette is the single most important shortcut. Nearly every VS Code feature is reachable from it.

|Action|Windows/Linux|macOS|
|---|---|---|
|Open Command Palette|`Ctrl+Shift+P`|`Cmd+Shift+P`|
|Quick Open (file by name)|`Ctrl+P`|`Cmd+P`|
|Go to symbol in file|`Ctrl+Shift+O`|`Cmd+Shift+O`|
|Go to symbol in workspace|`Ctrl+T`|`Cmd+T`|
|Go to line number|`Ctrl+G`|`Ctrl+G`|

**Tip:** Inside Quick Open (`Ctrl+P` / `Cmd+P`), prefix your query with:

- `@` to filter symbols in the current file
- `#` to search symbols workspace-wide
- `:` followed by a number to jump to a line

### 2.2 File and Editor Management

|Action|Windows/Linux|macOS|
|---|---|---|
|New file|`Ctrl+N`|`Cmd+N`|
|Open file|`Ctrl+O`|`Cmd+O`|
|Save|`Ctrl+S`|`Cmd+S`|
|Save all|`Ctrl+K S`|`Cmd+Option+S`|
|Close editor tab|`Ctrl+W`|`Cmd+W`|
|Reopen closed tab|`Ctrl+Shift+T`|`Cmd+Shift+T`|
|Switch between open tabs|`Ctrl+Tab`|`Ctrl+Tab`|
|Go to specific tab (1–9)|`Ctrl+1`…`Ctrl+9`|`Cmd+1`…`Cmd+9`|
|Split editor|`Ctrl+\`|`Cmd+\`|
|Focus left/right editor group|`Ctrl+K Ctrl+←/→`|`Cmd+K Cmd+←/→`|

### 2.3 Navigation Within a File

|Action|Windows/Linux|macOS|
|---|---|---|
|Go to definition|`F12`|`F12`|
|Peek definition|`Alt+F12`|`Option+F12`|
|Go to references|`Shift+F12`|`Shift+F12`|
|Go back / forward|`Alt+←` / `Alt+→`|`Ctrl+-` / `Ctrl+Shift+-`|
|Scroll up/down without moving cursor|`Ctrl+↑` / `Ctrl+↓`|`Ctrl+↑` / `Ctrl+↓`|
|Jump to matching bracket|`Ctrl+Shift+\`|`Cmd+Shift+\`|
|Go to beginning / end of file|`Ctrl+Home` / `Ctrl+End`|`Cmd+↑` / `Cmd+↓`|

### 2.4 Search and Replace

|Action|Windows/Linux|macOS|
|---|---|---|
|Find in file|`Ctrl+F`|`Cmd+F`|
|Replace in file|`Ctrl+H`|`Cmd+H`|
|Find in workspace|`Ctrl+Shift+F`|`Cmd+Shift+F`|
|Replace in workspace|`Ctrl+Shift+H`|`Cmd+Shift+H`|
|Next / previous match|`F3` / `Shift+F3`|`Cmd+G` / `Cmd+Shift+G`|
|Toggle case sensitivity|`Alt+C`|`Option+C`|
|Toggle regex|`Alt+R`|`Option+R`|
|Toggle whole word|`Alt+W`|`Option+W`|

### 2.5 Multi-Cursor and Selection

Multi-cursor editing is one of VS Code's most powerful features for repetitive edits.

|Action|Windows/Linux|macOS|
|---|---|---|
|Add cursor above / below|`Ctrl+Alt+↑` / `Ctrl+Alt+↓`|`Cmd+Option+↑` / `Cmd+Option+↓`|
|Add cursor at click position|`Alt+Click`|`Option+Click`|
|Select all occurrences of current word|`Ctrl+Shift+L`|`Cmd+Shift+L`|
|Add next occurrence to selection|`Ctrl+D`|`Cmd+D`|
|Skip current occurrence|`Ctrl+K Ctrl+D`|`Cmd+K Cmd+D`|
|Column (box) selection|`Shift+Alt+drag`|`Shift+Option+drag`|
|Expand selection|`Shift+Alt+→`|`Shift+Option+→`|
|Shrink selection|`Shift+Alt+←`|`Shift+Option+←`|
|Select line|`Ctrl+L`|`Cmd+L`|

### 2.6 Code Editing

|Action|Windows/Linux|macOS|
|---|---|---|
|Move line up / down|`Alt+↑` / `Alt+↓`|`Option+↑` / `Option+↓`|
|Copy line up / down|`Shift+Alt+↑` / `Shift+Alt+↓`|`Shift+Option+↑` / `Shift+Option+↓`|
|Delete line|`Ctrl+Shift+K`|`Cmd+Shift+K`|
|Insert line below|`Ctrl+Enter`|`Cmd+Enter`|
|Insert line above|`Ctrl+Shift+Enter`|`Cmd+Shift+Enter`|
|Indent / outdent line|`Ctrl+]` / `Ctrl+[`|`Cmd+]` / `Cmd+[`|
|Toggle line comment|`Ctrl+/`|`Cmd+/`|
|Toggle block comment|`Shift+Alt+A`|`Shift+Option+A`|
|Format document|`Shift+Alt+F`|`Shift+Option+F`|
|Format selection|`Ctrl+K Ctrl+F`|`Cmd+K Cmd+F`|
|Trigger IntelliSense|`Ctrl+Space`|`Ctrl+Space`|
|Trigger parameter hints|`Ctrl+Shift+Space`|`Cmd+Shift+Space`|
|Quick fix / lightbulb|`Ctrl+.`|`Cmd+.`|
|Rename symbol|`F2`|`F2`|
|Fold / unfold region|`Ctrl+Shift+[` / `Ctrl+Shift+]`|`Cmd+Option+[` / `Cmd+Option+]`|
|Fold all / unfold all|`Ctrl+K Ctrl+0` / `Ctrl+K Ctrl+J`|`Cmd+K Cmd+0` / `Cmd+K Cmd+J`|

### 2.7 Terminal

|Action|Windows/Linux|macOS|
|---|---|---|
|Toggle integrated terminal|`` Ctrl+` ``|`` Ctrl+` ``|
|New terminal|`` Ctrl+Shift+` ``|`` Ctrl+Shift+` ``|
|Split terminal|`Ctrl+Shift+5`|`Cmd+\`|
|Kill terminal|`Ctrl+Shift+Delete`|—|
|Clear terminal|`Ctrl+K` (inside terminal)|`Cmd+K` (inside terminal)|

### 2.8 Display and Layout

|Action|Windows/Linux|macOS|
|---|---|---|
|Toggle sidebar|`Ctrl+B`|`Cmd+B`|
|Toggle panel (bottom)|`Ctrl+J`|`Cmd+J`|
|Toggle full screen|`F11`|`Ctrl+Cmd+F`|
|Zoom in / out|`Ctrl+=` / `Ctrl+-`|`Cmd+=` / `Cmd+-`|
|Reset zoom|`Ctrl+Numpad0`|`Cmd+Numpad0`|
|Toggle Zen Mode|`Ctrl+K Z`|`Cmd+K Z`|
|Toggle word wrap|`Alt+Z`|`Option+Z`|

### 2.9 Debugging

|Action|Windows/Linux|macOS|
|---|---|---|
|Start / continue debugging|`F5`|`F5`|
|Stop debugging|`Shift+F5`|`Shift+F5`|
|Step over|`F10`|`F10`|
|Step into|`F11`|`F11`|
|Step out|`Shift+F11`|`Shift+F11`|
|Toggle breakpoint|`F9`|`F9`|
|Show hover (debug)|`Ctrl+K Ctrl+I`|`Cmd+K Cmd+I`|

### 2.10 Source Control (Git)

|Action|Windows/Linux|macOS|
|---|---|---|
|Open Source Control view|`Ctrl+Shift+G`|`Ctrl+Shift+G`|
|Stage changes (from diff view)|`Ctrl+Shift+Alt+S`|—|
|Open changes for current file|`Ctrl+Shift+G` then select file|same|

Most Git operations are better handled from the Command Palette (`> Git: …`) or the Source Control panel.

---

## 3. IntelliSense and Language Features

IntelliSense provides completions, parameter hints, hover docs, and signature help. It activates automatically in most languages or on demand with `Ctrl+Space`.

- **Hover documentation:** Rest the cursor over a symbol. A doc popup appears without any shortcut needed.
- **Go to Type Definition:** Available via the Command Palette or right-click context menu; useful when `F12` leads to a `.d.ts` stub rather than the source.
- **Breadcrumbs:** Enable via `View > Show Breadcrumbs`. Displays the file path and symbol hierarchy at the top of the editor — clicking any segment navigates there.
- **Outline view:** Found in the Explorer sidebar under "Outline." Lists all symbols in the current file. Useful for large files.

---

## 4. Snippets

Snippets are reusable code templates triggered by a prefix and `Tab`.

### 4.1 Built-in snippets

Type a known prefix (e.g., `for`, `if`, `class`) and press `Tab` in a supported language to expand it.

### 4.2 User-defined snippets

Open via: `File > Preferences > Configure User Snippets` (or Command Palette `> Snippets: Configure User Snippets`).

```json
"Print to console": {
  "prefix": "log",
  "body": [
    "console.log('$1');",
    "$2"
  ],
  "description": "Log output to console"
}
```

- `$1`, `$2` are tab stops — cursor lands on each in order.
- `${1:placeholder}` adds default text at that stop.
- `$0` is the final cursor position.

### 4.3 Snippet variables

Built-in variables include `$TM_FILENAME`, `$CURRENT_DATE`, `$CLIPBOARD`, and others. Check the VS Code docs for the full list.

---

## 5. Extensions That Meaningfully Affect Productivity

These are well-established extensions. Behavior and availability may change over time — verify in the Marketplace before installing.

### 5.1 General

- **Prettier – Code formatter**: Opinionated formatting on save. Pair with `"editor.formatOnSave": true`.
- **ESLint**: Surfaces lint errors inline as you type.
- **GitLens**: Enriches the built-in Git experience with blame annotations, commit history, and file comparisons.
- **Path IntelliSense**: Auto-completes file paths in import statements.
- **Error Lens**: Shows inline error and warning messages at the end of the offending line.

### 5.2 Navigation and Editing

- **Bookmarks**: Mark lines with `Ctrl+Alt+K` and jump between them with `Ctrl+Alt+J` / `Ctrl+Alt+L`.
- **Todo Tree**: Scans workspace for `TODO`, `FIXME`, etc. and lists them in a dedicated view.

### 5.3 Remote and Containers

- **Remote – SSH**: Edit files on a remote server as if they were local.
- **Dev Containers**: Opens a project inside a Docker container with a full VS Code environment.

---

## 6. Settings That Directly Affect Workflow

Access settings via `Ctrl+,` / `Cmd+,` (UI) or `Ctrl+Shift+P > Open User Settings (JSON)`.

```json
{
  "editor.formatOnSave": true,
  "editor.tabSize": 2,
  "editor.wordWrap": "on",
  "editor.minimap.enabled": false,
  "editor.stickyScroll.enabled": true,
  "editor.linkedEditing": true,
  "editor.bracketPairColorization.enabled": true,
  "workbench.editor.enablePreview": false,
  "files.autoSave": "onFocusChange",
  "terminal.integrated.scrollback": 5000,
  "editor.suggest.preview": true
}
```

**Notable settings:**

- `editor.stickyScroll.enabled` — pins the current class/function header at the top of the editor while you scroll its body. Available in VS Code 1.70+.
- `editor.linkedEditing` — in HTML, renaming an opening tag also renames the closing tag.
- `workbench.editor.enablePreview: false` — files open as permanent tabs rather than closing when you open the next file.
- `editor.suggest.preview` — shows a ghost-text preview of the top autocomplete suggestion inline.

---

## 7. Workspace and Project Organization

### 7.1 Multi-root workspaces

VS Code supports opening multiple folders in one window via `File > Add Folder to Workspace`. Save the configuration as a `.code-workspace` file to reopen the same set of folders. This is useful for monorepos or projects that span multiple directories.

### 7.2 .editorconfig

If a `.editorconfig` file exists in the project root, VS Code respects it (with the EditorConfig extension) for consistent indentation and line endings across editors and contributors.

### 7.3 Tasks

Tasks run shell commands from inside VS Code. Define them in `.vscode/tasks.json`:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Build",
      "type": "shell",
      "command": "npm run build",
      "group": {
        "kind": "build",
        "isDefault": true
      }
    }
  ]
}
```

Run the default build task with `Ctrl+Shift+B` / `Cmd+Shift+B`. Other tasks are reachable via `Terminal > Run Task`.

### 7.4 Launch configurations

`.vscode/launch.json` defines debug configurations. Once defined, press `F5` to launch the configured debugger without setting it up each time.

---

## 8. The Terminal: Working Efficiently

The integrated terminal shares the project's working directory, which reduces context-switching.

- **Multiple terminal instances:** Use the `+` button or `` Ctrl+Shift+` `` to open additional terminals. Split a terminal with the split icon for side-by-side shells.
- **Terminal profiles:** Configure default shell (bash, zsh, PowerShell, etc.) in `terminal.integrated.defaultProfile.<platform>`.
- **Shell integration:** In VS Code 1.70+, shell integration marks command output, adds run-time decorations, and enables `Ctrl+↑` / `Ctrl+↓` to jump between command outputs inside the terminal.

---

## 9. Refactoring Workflows

- **Rename symbol (`F2`):** Renames a variable, function, or class across all usages in the workspace — not just the current file.
- **Extract to function / variable:** Select a block of code, press `Ctrl+.` / `Cmd+.`, and choose an extract refactoring option if the language server offers one.
- **Move to new file:** Some language servers (e.g., TypeScript) offer "Move to a new file" from the `Ctrl+.` menu.
- **Organize imports:** Available via `Shift+Alt+O` / `Shift+Option+O` in TypeScript and JavaScript. Removes unused imports and sorts the rest.

---

## 10. Customizing Shortcuts

All shortcuts are editable. Open the Keyboard Shortcuts editor with `Ctrl+K Ctrl+S` / `Cmd+K Cmd+S`.

- Search by command name or current keybinding.
- Click the pencil icon to reassign.
- Power users can edit `keybindings.json` directly via the `{}` icon in the top-right of the shortcuts editor.

Example — assign `Ctrl+Alt+T` to open a new terminal:

```json
[
  {
    "key": "ctrl+alt+t",
    "command": "workbench.action.terminal.new"
  }
]
```

Keybindings support `when` clauses to restrict them to a context (e.g., `"when": "editorTextFocus"`).

---

## 11. Profiles

VS Code Profiles (introduced in 1.75) let you save and switch between different sets of settings, extensions, and keybindings. Useful for switching between, for example, a Python data-science setup and a web-dev setup.

Access via: `File > Preferences > Profiles` or the gear icon in the Activity Bar.

Profiles can be exported as a JSON file or shared via a URL (through VS Code's Settings Sync feature).

---

## 12. Settings Sync

Enable via: `File > Preferences > Settings Sync` (sign in with a GitHub or Microsoft account).

Syncs settings, keybindings, snippets, extensions, and profiles across machines. You can control which categories sync independently.

---

## 13. Practical Habits

These are workflow patterns rather than single shortcuts.

- **Keep the Command Palette as the default entry point.** Before reaching for a menu, try typing the action name in `Ctrl+Shift+P`. Over time this is faster than any menu.
- **Use `Ctrl+D` iteratively for targeted multi-rename.** Select one instance of a word, then press `Ctrl+D` repeatedly to add the next match one at a time. Press `Ctrl+K Ctrl+D` to skip one if needed. This gives more control than replacing all occurrences at once.
- **Pin frequently opened files.** Right-click a tab and choose "Pin Tab" (`Ctrl+K Shift+Enter`). Pinned tabs stay at the left and don't close automatically.
- **Use Sticky Scroll for deep nesting.** With `editor.stickyScroll.enabled: true`, the enclosing function or class header remains visible while reading nested code.
- **Commit to one formatter.** Mixing auto-formatters causes noisy diffs. Pick one (e.g., Prettier) and set it as the default formatter per language:

```json
"[javascript]": {
  "editor.defaultFormatter": "esbenp.prettier-vscode"
}
```

- **Use workspace-level settings for project-specific config.** Place a `.vscode/settings.json` in the project root. These settings apply only when that folder is open and override user settings.