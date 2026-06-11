# Claude Code — Comprehensive Guide (Arch Linux)

> Sources: [Official docs](https://code.claude.com/docs/en/overview.md) · [Quickstart](https://code.claude.com/docs/en/quickstart.md) · [How it works](https://code.claude.com/docs/en/how-claude-code-works.md) · [Memory](https://code.claude.com/docs/en/memory.md) · [Permissions](https://code.claude.com/docs/en/permission-modes.md) · [Best practices](https://code.claude.com/docs/en/best-practices.md)  
> Last verified against docs: 2026-06-03

---

## What Is Claude Code

Claude Code is an agentic coding tool built by Anthropic. It runs in your terminal, reads your entire codebase, edits files, runs commands, and integrates with your development environment — all through natural language.

It is not a code-completion tool. It operates at the project level: understanding how components connect, planning multi-file changes, running tests, making commits, and iterating autonomously until a task is done.

---

## Requirements and Account

Claude Code requires one of:

- A **Claude Pro, Max, Team, or Enterprise** subscription at [claude.com](https://claude.com/pricing)
- A **Claude Console** account with API credits at [console.anthropic.com](https://console.anthropic.com/)
- Access via a **third-party cloud provider** (Amazon Bedrock, Google Vertex AI, Microsoft Foundry)

There is no standalone free tier for Claude Code.

---

## Installation on Arch Linux

### Native Installer (Recommended)

The native installer auto-updates in the background:

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

### npm (Manual)

```bash
npm install -g @anthropic-ai/claude-code
```

With npm you are responsible for updates:

```bash
npm update -g @anthropic-ai/claude-code
```

### Linux Package Managers

The official docs mention `apt`, `dnf`, and `apk` support for Debian, Fedora, RHEL, and Alpine. Arch is not among these — use the native installer or npm on Arch.

> [Inference] Arch users can also install via the AUR if a community package exists, but this is not documented by Anthropic. Verify any AUR package independently.

---

## First Run and Authentication

Start Claude Code in any project directory:

```bash
cd /path/to/your/project
claude
```

On first launch, you are prompted to authenticate. Follow the prompts to complete OAuth in your browser. Credentials are stored locally and persist across sessions.

To switch accounts later, run `/login` inside an active session.

---

## The Agentic Loop

Claude Code works through three repeating phases:

1. **Gather context** — reads files, searches code, runs queries
2. **Take action** — edits files, runs commands, calls tools
3. **Verify results** — runs tests, checks output, corrects mistakes

These phases blend. A simple question may only gather context. A bug fix cycles through all three repeatedly. You can interrupt at any point to redirect Claude.

---

## Built-In Tools

|Category|What Claude can do|
|---|---|
|File operations|Read, edit, create, rename, reorganize files|
|Search|Find files by pattern, search content with regex|
|Execution|Run shell commands, start servers, run tests, use git|
|Web|Search the web, fetch documentation|
|Code intelligence|See type errors and warnings after edits (requires plugins)|

Claude chooses which tools to use based on what it knows so far — you do not select them manually.

---

## Starting a Session

### Interactive mode

```bash
claude
```

### One-off task, then exit

```bash
claude "fix the build error"
```

### One-off query, then exit

```bash
claude -p "explain this function"
```

### Continue most recent session

```bash
claude -c
```

### Resume a previous session (picker)

```bash
claude -r
```

### Fork a session from the same point

```bash
claude --continue --fork-session
```

This creates a new session ID while keeping the conversation history. The original session is not affected.

---

## Essential In-Session Commands

|Command|Purpose|
|---|---|
|`/help`|Show available commands|
|`/clear`|Clear conversation history|
|`/compact`|Manually compact context|
|`/context`|Show what is using context space|
|`/model`|Switch models mid-session|
|`/login`|Re-authenticate or switch accounts|
|`/memory`|View and edit memory|
|`/init`|Generate a starter CLAUDE.md for the project|
|`Shift+Tab`|Cycle permission modes|
|`Ctrl+C`|Interrupt Claude mid-task|
|`exit` or `Ctrl+D`|Exit|

---

## Sessions and Context

Each session stores your full conversation locally, including all messages, tool outputs, and file reads. Sessions are independent — a new session starts with a fresh context window.

**Context fills up fast.** Everything loaded into a session — conversation history, file reads, command outputs, CLAUDE.md, auto memory — consumes the context window. LLM performance degrades as context fills. This is the primary resource to manage.

When context nears its limit, Claude Code compacts automatically: it clears old tool outputs first, then summarises the conversation. Put persistent rules in `CLAUDE.md` rather than relying on them surviving compaction.

Run `/context` to inspect what is consuming space. Use `/compact focus on <topic>` to guide what is preserved.

---

## Memory: CLAUDE.md and Auto Memory

Claude Code has two persistence mechanisms across sessions:

### CLAUDE.md

A markdown file you write. Claude reads it at the start of every session. Use it for:

- Build and test commands
- Coding conventions and standards
- Project architecture notes
- "Always do X" rules

**Scopes and locations:**

|Scope|Location|Shared with|
|---|---|---|
|Managed policy (org-wide)|`/etc/claude-code/CLAUDE.md` (Linux)|All org users|
|User (all projects)|`~/.claude/CLAUDE.md`|Just you|
|Project (team-shared)|`./CLAUDE.md` or `./.claude/CLAUDE.md`|Team via version control|
|Local (personal, per project)|`./CLAUDE.local.md`|Just you (add to `.gitignore`)|

**Tips for effective CLAUDE.md files:**

- Target under 200 lines per file. Longer files consume more context and reduce adherence.
- Use markdown headers and bullets to group related instructions.
- Use `/init` to auto-generate a starting file from your codebase.
- For path-specific rules, use `.claude/rules/` to scope instructions to certain file types or directories.

### Auto Memory

Notes Claude writes itself as you work — learnings like build commands, debugging insights, and preferences it discovers. Stored per repository, loaded at the start of every session (first 200 lines or 25 KB).

Enable or disable via `/memory`. Audit and edit stored memories with the same command.

---

## Permission Modes

Permission modes control how often Claude pauses to ask before acting.

|Mode|What runs without asking|Best for|
|---|---|---|
|`default`|Reads only|Getting started, sensitive work|
|`acceptEdits`|Reads, file edits, common filesystem commands|Iterating on code you are reviewing|
|`plan`|Reads only (no edits)|Exploring before changing|
|`auto`|Everything, with background safety checks|Long tasks, reducing interruptions|
|`dontAsk`|Only pre-approved tools|Locked-down CI and scripts|
|`bypassPermissions`|Everything|Isolated containers or VMs **only**|

**Switch modes:**

- Press `Shift+Tab` in the CLI to cycle `default → acceptEdits → plan`
- Pass `--permission-mode <mode>` at startup: `claude --permission-mode plan`
- Set a persistent default in settings: `{ "permissions": { "defaultMode": "acceptEdits" } }`

In every mode except `bypassPermissions`, writes to protected paths (e.g. `.git`, Claude's own config) are never auto-approved.

---

## Working with Git

Claude Code works directly with git. Example prompts:

```
what files have I changed?
commit my changes with a descriptive message
create a new branch called feature/my-feature
show me the last 5 commits
help me resolve merge conflicts
```

For parallel work, use git worktrees. Each worktree is a separate directory, so you can run separate Claude Code sessions in each:

```bash
git worktree add ../project-feature-a feature-a
git worktree add ../project-feature-b feature-b
# Then: cd ../project-feature-a && claude
# And:  cd ../project-feature-b && claude
```

---

## Effective Prompting Patterns

### Explore before implementing

Use Plan Mode to explore without making changes, then switch to Normal Mode to implement:

```
# In Plan Mode:
read /src/auth and understand how sessions work

# Still in Plan Mode:
I want to add Google OAuth. What files need to change? Create a plan.

# Switch to Normal Mode, then:
implement the OAuth flow. write tests, run them, fix failures.
```

### Give Claude a way to verify its work

Claude performs substantially better when it can check its own output.

Instead of: `implement email validation`

Try: `write a validateEmail function. test cases: user@example.com → true, invalid → false. run the tests after implementing.`

### Be specific and reference real files

Instead of: `fix the bug`

Try: `the login page throws a blank screen after a wrong password. the relevant code is in /src/auth/login.ts. fix it and verify the error is handled gracefully.`

### Provide rich content

Paste error messages, stack traces, or screenshots directly into the prompt. Claude reads them as context.

---

## Automation and Non-Interactive Use

Claude Code follows the Unix philosophy. Pipe into it, use it in scripts, chain it with other tools:

```bash
# Analyse recent logs
tail -200 app.log | claude -p "summarise any anomalies"

# Bulk review changed files
git diff main --name-only | claude -p "review these for security issues"

# Run in CI without interaction
claude --permission-mode dontAsk -p "run tests and output a summary"
```

The `-p` flag runs a single prompt non-interactively and exits.

---

## MCP (Model Context Protocol)

MCP is an open standard for connecting Claude Code to external services. With MCP, Claude can read from Google Drive, update Jira tickets, pull Slack messages, or use custom tooling.

Configure MCP servers in your settings. The official MCP quickstart is at [code.claude.com/docs/en/mcp-quickstart.md](https://code.claude.com/docs/en/mcp-quickstart.md).

MCP tool definitions are deferred by default and loaded on demand, so they do not consume context until Claude actually uses a tool.

---

## Subagents

Claude Code can spawn subagents — separate Claude instances that work on parts of a task in parallel. A lead agent coordinates the work, assigns subtasks, and merges results.

Subagents can maintain their own auto memory. See the subagents documentation for configuration details.

---

## Hooks

Hooks let you run shell commands before or after Claude Code actions:

- Auto-format files after every edit
- Run a linter before a commit
- Post a notification when a task finishes

Hooks are configured in settings and fire on specific events in the agentic loop.

---

## Skills

Skills are packaged, reusable workflows your team can invoke as slash commands, e.g. `/review-pr` or `/deploy-staging`. Create them with `/init` (interactive mode) or by writing them manually in `.claude/`.

Skills reduce context usage compared to re-explaining a workflow each session.

---

## Available Interfaces

All surfaces connect to the same underlying Claude Code engine. CLAUDE.md files, settings, and MCP servers work across all of them.

|Interface|Notes|
|---|---|
|Terminal CLI|Full-featured, composable, scriptable|
|VS Code extension|Inline diffs, @-mentions, plan review|
|JetBrains plugin|Interactive diff viewing, IntelliJ/PyCharm/WebStorm|
|Desktop app|Visual diff review, multiple parallel sessions, scheduled tasks|
|Web (claude.ai/code)|No local setup, runs in cloud VMs, accessible from mobile|
|Slack|Mention @Claude in a channel, get a pull request back|
|GitHub Actions / GitLab CI|Automate code review and issue triage in CI/CD|

---

## Context Cost by Feature

Some features are more expensive in context than others. A rough hierarchy (highest to lowest context cost, [Inference]):

1. Large file reads and command outputs
2. Subagent spawning and coordination
3. MCP tool calls
4. CLAUDE.md files at startup
5. Auto memory at startup
6. Skill invocations
7. Short conversational turns

Use `/context` to inspect your current session. Compact early and often on long tasks.

---

## Common Failure Patterns to Avoid

From the official best practices documentation:

- **Jumping straight to coding** without exploring: use Plan Mode first for unfamiliar or multi-file changes.
- **Vague prompts**: "fix the bug" is harder for Claude to act on than "the login form fails silently when the API is unreachable — trace and fix it."
- **No verification criteria**: Claude cannot confirm correctness without tests, expected outputs, or screenshots to compare against.
- **Relying on conversation history for persistent rules**: rules in chat get lost when context compacts. Put them in CLAUDE.md.
- **Long uninterrupted sessions**: interrupt early and course-correct rather than letting a session run far in the wrong direction. Shorter, focused sessions with clear goals generally outperform long ones.

---

## Further Reading

All official documentation is at [code.claude.com/docs](https://code.claude.com/docs/en/overview.md).

Key pages:

- [Overview](https://code.claude.com/docs/en/overview.md)
- [Quickstart](https://code.claude.com/docs/en/quickstart.md)
- [How Claude Code works](https://code.claude.com/docs/en/how-claude-code-works.md)
- [Memory (CLAUDE.md)](https://code.claude.com/docs/en/memory.md)
- [Permission modes](https://code.claude.com/docs/en/permission-modes.md)
- [Best practices](https://code.claude.com/docs/en/best-practices.md)
- [Common workflows](https://code.claude.com/docs/en/common-workflows.md)
- [CLI reference](https://code.claude.com/docs/en/cli-reference.md)
- [MCP quickstart](https://code.claude.com/docs/en/mcp-quickstart.md)
- [Sub-agents](https://code.claude.com/docs/en/sub-agents.md)
- [Hooks](https://code.claude.com/docs/en/hooks-guide.md)
- [Skills](https://code.claude.com/docs/en/skills.md)