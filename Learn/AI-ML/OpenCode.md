# OpenCode: Comprehensive Guide (Arch / Omarchy)

OpenCode is an open source AI coding agent built primarily for the terminal. It is available as a TUI (Terminal User Interface), a desktop app, and an IDE extension. It is provider-agnostic, supporting 75+ LLM providers including Anthropic, OpenAI, Google Gemini, and local models via Ollama. On Omarchy (an opinionated Arch Linux distribution built on Hyprland), OpenCode ships as a first-class tool with a dedicated alias and clipboard notes worth knowing.

---

## What OpenCode Is

OpenCode is a terminal-native AI coding agent. Rather than acting as a passive chat interface, it has access to a set of tools it can invoke autonomously during a session: reading, writing, and editing files; running shell commands; searching codebases via grep and glob; and surfacing LSP diagnostics. You give it a task in natural language, and it works through it in your project directory.

It was created by the team behind SST and terminal.shop, with a stated focus on pushing the limits of what is possible in the terminal. The architecture is client/server, meaning the TUI frontend is one possible interface, not the only one.

---

## Installation on Arch / Omarchy

### Via pacman (stable)

```bash
sudo pacman -S opencode
```

This installs the stable release from the Arch `extra` repository.

### Via AUR (latest)

```bash
paru -S opencode-bin
```

This pulls the latest release from the AUR. Use this if you want the most current version ahead of the official Arch repo.

### Via install script (YOLO method)

```bash
curl -fsSL https://opencode.ai/install | bash
```

The install script respects the following path priority:

1. `$OPENCODE_INSTALL_DIR` — custom installation directory
2. `$XDG_BIN_DIR` — XDG Base Directory Specification path
3. `$HOME/bin` — standard user binary directory

### Via npm / bun / pnpm / yarn

```bash
npm install -g opencode-ai
# or
bun add -g opencode-ai
```

### Omarchy-specific note

On Omarchy, OpenCode is pre-integrated. The Omarchy Manual documents a `c` alias: navigate to your project directory and invoke `c` to start OpenCode scoped to that directory. This is the recommended way to use it within Omarchy's workflow. Claude Code is also available separately via a `cx` alias (danger mode). Both are distinct tools.

---

## Initial Setup and Provider Configuration

### Connecting a provider

When you first run `opencode`, you will need to configure at least one LLM provider. Inside the TUI, run:

```
/connect
```

This lets you select from the available providers. API keys are stored at `~/.local/share/opencode/auth.json`.

### OpenCode Zen (recommended for new users)

OpenCode Zen is a curated list of models the OpenCode team has tested and verified. It is a managed provider you can subscribe to at `opencode.ai/zen`. It is pay-as-you-go, not a fixed subscription. Use `/connect`, select OpenCode Zen, and paste your API key.

### OpenCode Go

A low-cost subscription plan giving access to popular open coding models managed by the OpenCode team. Also configured via `/connect`.

### Self-managed providers

You can configure any of the 75+ supported providers manually. In `~/.config/opencode/opencode.json`:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "model": "anthropic/claude-sonnet-4-5",
  "provider": {
    "anthropic": {
      "options": {
        "baseURL": "https://api.anthropic.com/v1"
      }
    }
  }
}
```

Credentials can also be set via environment variables. Consult the provider docs at `opencode.ai/docs/providers` for per-provider variable names.

### Local models via Ollama

OpenCode supports Ollama as a provider, allowing fully offline use. Configure it through `/connect` and select Ollama, or set the `baseURL` to your local Ollama server.

---

## Initializing a Project

Navigate to your project directory and launch OpenCode:

```bash
cd /path/to/project
opencode
```

Then run the init command to analyze the project and generate an `AGENTS.md` file:

```
/init
```

`AGENTS.md` is a context file OpenCode (and other AI coding agents) use to understand your project's structure and conventions. You should commit this file to git. It lives in the project root.

---

## The TUI Interface

### Layout and navigation

The TUI is keyboard-driven. You compose prompts in the input area, and the agent's responses, tool calls, and file diffs appear in the main pane. Mouse capture is enabled by default but can be disabled in `tui.json`.

### Modes

OpenCode has two built-in agents, switchable with `Tab`:

- **Build mode** — default; the agent can read, write, and modify files, and run shell commands.
- **Plan mode** — read-only; the agent can only analyze and propose a plan without touching any files.

The current mode is indicated in the lower right corner of the TUI.

### File references

Type `@` in the input to fuzzy-search for files in the current project. Selected files have their content added to the conversation automatically:

```
How is authentication handled in @packages/functions/src/api/index.ts?
```

### Shell commands

Start a message with `!` to run a shell command. The output is added to the conversation as a tool result:

```
!git log --oneline -10
```

### Image input

You can drag and drop images into the terminal to add them to the prompt. OpenCode will include them as context. This is useful for referencing UI mockups or screenshots.

---

## Slash Commands

All slash commands are typed in the TUI input. Most also have keyboard shortcuts using `Ctrl+X` as the default leader key.

|Command|Description|Keybind|
|---|---|---|
|`/connect`|Add or reconfigure a provider|—|
|`/init`|Create or update `AGENTS.md`|—|
|`/new`|Start a new session|`Ctrl+X N`|
|`/sessions`|List and switch between sessions|`Ctrl+X L`|
|`/models`|List available models|`Ctrl+X M`|
|`/themes`|List and switch themes|`Ctrl+X T`|
|`/undo`|Undo last message and revert file changes|`Ctrl+X U`|
|`/redo`|Redo a previously undone message|`Ctrl+X R`|
|`/compact`|Compact/summarize current session|`Ctrl+X C`|
|`/share`|Share current session and copy link|—|
|`/unshare`|Remove a shared session|—|
|`/export`|Export conversation to Markdown, open in `$EDITOR`|`Ctrl+X X`|
|`/editor`|Open `$EDITOR` to compose a long message|`Ctrl+X E`|
|`/details`|Toggle display of tool execution details|—|
|`/thinking`|Toggle display of model reasoning blocks|—|
|`/help`|Show help dialog|—|
|`/exit`|Exit OpenCode|`Ctrl+X Q`|

`/undo` and `/redo` use git internally to manage file changes. Your project must be a git repository for these to work on file contents.

---

## Configuration

OpenCode uses two separate config files. Both support JSON and JSONC (JSON with comments).

### `opencode.json` — server/runtime config

Controls providers, models, tools, shell, permissions, MCP servers, LSP, formatters, and agent behavior.

Global location: `~/.config/opencode/opencode.json`

Project location: `opencode.json` in the project root (safe to commit to git)

### `tui.json` — TUI config

Controls the visual interface: theme, keybinds, scroll behavior, diff style, mouse.

Global location: `~/.config/opencode/tui.json`

Project location: `tui.json` alongside `opencode.json` in the project root

### Config precedence (lowest to highest)

1. Remote config (from `.well-known/opencode` — for organizations)
2. Global config (`~/.config/opencode/opencode.json`)
3. Custom config (`OPENCODE_CONFIG` env var)
4. Project config (`opencode.json` in project root)
5. `.opencode/` directories
6. Inline config (`OPENCODE_CONFIG_CONTENT` env var)
7. Managed config (`/etc/opencode/` on Linux — admin-controlled, not user-overridable)

Configs are **merged**, not replaced. Non-conflicting keys from all sources are preserved.

### Example global config

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "model": "anthropic/claude-sonnet-4-5",
  "small_model": "anthropic/claude-haiku-4-5",
  "autoupdate": true,
  "shell": "/bin/bash"
}
```

### Example TUI config

```jsonc
{
  "$schema": "https://opencode.ai/tui.json",
  "theme": "opencode",
  "scroll_speed": 3,
  "scroll_acceleration": {
    "enabled": false
  },
  "diff_style": "auto",
  "mouse": true,
  "keybinds": {
    "leader": "ctrl+x"
  }
}
```

### Configuring the shell

```jsonc
{
  "shell": "/bin/zsh"
}
```

If not specified, OpenCode auto-detects a sensible default (bash or zsh on Linux).

### Disabling tools

You can restrict which tools the agent has access to:

```jsonc
{
  "tools": {
    "write": false,
    "bash": false
  }
}
```

---

## Models

Set the primary model and an optional cheaper small model (used for lighter tasks):

```jsonc
{
  "model": "anthropic/claude-sonnet-4-5",
  "small_model": "anthropic/claude-haiku-4-5"
}
```

You can switch models mid-session with `/models` or `Ctrl+X M`. Use `Ctrl+T` to cycle through model variants (including thinking/reasoning variants where available).

Model strings follow the format `provider/model-name`. Run `/models` in the TUI to see all models available from your configured providers.

---

## Keybinds

Keybinds are configured in `tui.json` under the `keybinds` key. They are merged with built-in defaults, so you only need to specify what you want to change.

```jsonc
{
  "keybinds": {
    "leader": "ctrl+x",
    "command_list": "ctrl+p"
  }
}
```

The leader key prefixes most session commands. `leader_timeout` controls how long OpenCode waits after you press the leader key (default: 2000ms).

---

## Themes

Switch themes interactively with `/themes` or `Ctrl+X T`. To set a theme persistently in `tui.json`:

```jsonc
{
  "theme": "opencode"
}
```

Custom themes can be placed in `~/.config/opencode/themes/` as JSON files.

---

## Custom Commands

Custom commands are reusable prompts stored as Markdown files. They appear in the TUI as `/commands`.

Locations (in order of scope):

- `~/.config/opencode/commands/` — global, available in all projects
- `.opencode/commands/` — project-local
- `opencode.json` under `commands` — inline

Create a file at `~/.config/opencode/commands/prime-context.md`:

```markdown
RUN git ls-files
RUN cat README.md
Summarize the project structure and tech stack.
```

This creates a command called `user:prime-context`. Commands support named arguments using `$PLACEHOLDER` syntax (uppercase letters, numbers, underscores, must start with a letter). OpenCode will prompt you for values when the command runs.

---

## Rules and AGENTS.md

`AGENTS.md` (created by `/init`) is a plain-text context file committed to your project. It helps OpenCode understand conventions, architecture, and patterns without you repeating them. You can edit it manually. The agent reads it at the start of each session.

Project-level rules go in `AGENTS.md`. Global rules (applying to all projects) can be placed in `~/.config/opencode/AGENTS.md`.

---

## LSP Integration

OpenCode integrates with Language Server Protocol to provide code intelligence. Configure language servers in `opencode.json`:

```jsonc
{
  "lsp": {
    "go": {
      "disabled": false,
      "command": "gopls"
    },
    "typescript": {
      "disabled": false,
      "command": "typescript-language-server",
      "args": ["--stdio"]
    }
  }
}
```

The agent currently exposes LSP diagnostics (errors, warnings) to the AI. The full LSP protocol is implemented, but other features (completions, hover, go-to-definition) are not yet surfaced to the agent as tools.

---

## MCP Servers

OpenCode implements the Model Context Protocol, allowing you to connect the agent to external tools and services. Configured in `opencode.json`:

```jsonc
{
  "mcp": {
    "my-tool": {
      "type": "stdio",
      "command": "/path/to/mcp-server",
      "env": [],
      "args": []
    },
    "remote-tool": {
      "type": "sse",
      "url": "https://example.com/mcp",
      "headers": {
        "Authorization": "Bearer your-token"
      }
    }
  }
}
```

Once configured, MCP tools are automatically available to the agent alongside built-in tools. They follow the same permission model — user approval is required before execution by default.

---

## Permissions

You can control which tool executions require approval. The default is to ask for all potentially destructive actions. Configure in `opencode.json`:

```jsonc
{
  "permission": {
    "*": "ask",
    "bash": {
      "*": "ask",
      "rm -rf *": "deny"
    }
  }
}
```

Permission values: `ask`, `allow`, `deny`.

---

## Session Management

OpenCode persists sessions locally. You can list and resume past sessions with `/sessions` or `Ctrl+X L`. Sessions are stored per-project.

### Sharing sessions

```
/share
```

This creates a shareable link to the current conversation and copies it to your clipboard. Nothing is shared by default. Use `/unshare` to remove the shared link.

### Compacting sessions

Long sessions accumulate context. Use `/compact` (or `Ctrl+X C`) to summarize and compact the conversation, reducing token usage while preserving the essential context.

---

## Formatters

OpenCode can run code formatters automatically after making file changes. Configure in `opencode.json`:

```jsonc
{
  "formatters": {
    "typescript": {
      "command": "prettier",
      "args": ["--write", "$FILE"]
    },
    "python": {
      "command": "ruff",
      "args": ["format", "$FILE"]
    }
  }
}
```

`$FILE` is replaced with the path of the file that was modified.

---

## Editor Integration

Set the `EDITOR` environment variable to use an external editor for composing long messages (`/editor`) or exporting conversations (`/export`).

In `~/.zshrc` or `~/.bashrc`:

```bash
export EDITOR=nvim
# For GUI editors that need blocking mode:
export EDITOR="code --wait"
```

Omarchy defaults to Neovim. If you prefer something else, you can install alternatives via the Omarchy menu (`Super + Alt + Space` → Install → Editor).

---

## Clipboard Notes on Omarchy

Omarchy uses unified clipboard hotkeys (`Super + C/V` for copy/paste) across most applications. However, OpenCode (and Claude Code) are exceptions: inside these AI agent CLIs, you must use the standard `Ctrl + C/V/X` for clipboard operations. The clipboard history manager (Walker, triggered by `Super + Ctrl + V`) works normally outside of these tools.

---

## CLI Usage (Non-interactive)

You can run OpenCode non-interactively for scripting or automation:

```bash
opencode run "Explain this function" --file src/main.go
```

Or pipe input:

```bash
echo "What does this do?" | opencode run
```

Check `opencode --help` for the full CLI reference. The CLI and TUI share the same configuration and session data.

---

## Autoupdate

OpenCode can update itself automatically. Enable in `opencode.json`:

```jsonc
{
  "autoupdate": true
}
```

On Arch, if you installed via pacman or AUR, updates come through those package managers instead. Autoupdate is more relevant if you used the install script or npm.

---

## Useful File Locations

|Path|Purpose|
|---|---|
|`~/.config/opencode/opencode.json`|Global runtime config|
|`~/.config/opencode/tui.json`|Global TUI config|
|`~/.local/share/opencode/auth.json`|Stored provider API keys|
|`~/.config/opencode/commands/`|Global custom commands|
|`~/.config/opencode/themes/`|Custom themes|
|`~/.config/opencode/AGENTS.md`|Global agent rules|
|`<project>/opencode.json`|Project-level runtime config|
|`<project>/AGENTS.md`|Project-level agent rules|
|`<project>/.opencode/commands/`|Project-level custom commands|
|`/etc/opencode/`|System-managed config (admin-only, highest priority)|

---

## Further Reading

- Official docs: `opencode.ai/docs`
- Config schema: `opencode.ai/config.json`
- TUI schema: `opencode.ai/tui.json`
- GitHub: `github.com/anomalyco/opencode`
- Discord: `opencode.ai/discord`
- Omarchy manual: `learn.omacom.io/2/the-omarchy-manual`