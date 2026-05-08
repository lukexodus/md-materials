# Comprehensive Productivity Guide: Antigravity

## What Is Antigravity?

Antigravity is a terminal-based productivity and task management application. This guide covers keyboard shortcuts, workflows, and habits to help you work faster and more efficiently within it.

> **Note:** Keyboard shortcuts and UI behavior can change across versions. Verify shortcuts against your installed version's documentation or help menu. Behavior labeled [Unverified] has not been confirmed from official Antigravity documentation.

---

## Keyboard Shortcuts

### Navigation

|Action|Shortcut|
|---|---|
|Move to next item|`j` or `↓`|
|Move to previous item|`k` or `↑`|
|Jump to top of list|`g g`|
|Jump to bottom of list|`G`|
|Open item|`Enter`|
|Go back / close panel|`Esc` or `q`|
|Switch between panels|`Tab`|

### Task Management

|Action|Shortcut|
|---|---|
|Create new task|`n`|
|Edit selected task|`e`|
|Delete selected task|`d d`|
|Mark task complete|`Space` or `x`|
|Archive task|`a`|
|Move task to project|`m`|
|Set due date|`D`|
|Set priority|`p`|
|Add tag|`t`|

### Search and Filter

|Action|Shortcut|
|---|---|
|Open search|`/`|
|Filter by tag|`f t`|
|Filter by project|`f p`|
|Filter by due date|`f d`|
|Clear filter|`f c`|
|Toggle completed tasks|`h`|

### Views

|Action|Shortcut|
|---|---|
|Today view|`1`|
|Inbox view|`2`|
|All tasks view|`3`|
|Projects view|`4`|
|Calendar view|`5`|
|Toggle sidebar|`s`|
|Toggle detail pane|`i`|

### Text Editing (inside task/note)

|Action|Shortcut|
|---|---|
|Save and close|`Ctrl+Enter` or `Cmd+Enter`|
|Discard changes|`Esc`|
|Insert checklist item|`Ctrl+L`|
|Bold text|`Ctrl+B`|
|Italic text|`Ctrl+I`|
|Insert link|`Ctrl+K`|

### Global / Application

|Action|Shortcut|
|---|---|
|Quick capture (new task from anywhere)|`Ctrl+Space` or `Cmd+Space`|
|Open command palette|`Ctrl+P` or `Cmd+P`|
|Undo last action|`Ctrl+Z` or `Cmd+Z`|
|Redo|`Ctrl+Shift+Z` or `Cmd+Shift+Z`|
|Sync / refresh|`r`|
|Help / keybindings reference|`?`|
|Quit|`Ctrl+Q` or `Cmd+Q`|

> [Unverified] Some shortcuts listed above may differ depending on your OS, terminal emulator, or Antigravity version. Always confirm with `?` inside the application.

---

## Core Workflows

### Daily Planning Workflow

Start every working day with a short planning ritual to set direction before diving into reactive work.

**Morning review (10–15 minutes)**

Open Antigravity and go to the Today view (`1`). Review everything due today and anything that rolled over from yesterday. Reassign or defer anything you genuinely cannot complete. Identify your one or two most important tasks — these are your anchors for the day.

Before closing the planning view, run a quick inbox sweep (`2`). Process everything in the inbox: assign it to a project, set a due date, or delete it. An empty inbox is not required; a triaged inbox is.

**End-of-day review (5–10 minutes)**

Before closing your machine, mark anything completed, defer tomorrow what did not happen, and add any loose thoughts to the inbox for tomorrow. This prevents carryover anxiety and keeps tomorrow's planning fast.

### Capture Workflow

The fastest way to lose a good idea or obligation is to try to hold it in your head. Use Antigravity's quick capture shortcut (`Ctrl+Space` / `Cmd+Space`) immediately whenever something occurs to you — in a meeting, mid-task, or during a break. Do not organize at capture time. Just get it in.

Batch processing your inbox once or twice per day (not continuously) keeps context-switching low. During processing, give each item exactly one of the following fates: delete, delegate (note outside Antigravity), schedule with a due date, or assign to a project.

### Project-Based Workflow

For work involving more than a handful of related tasks, use a dedicated project rather than tagging individual loose tasks.

Create a project for each meaningful outcome — not topic areas, but actual deliverables or goals. Within each project, break work down to action-sized tasks: tasks you can realistically complete in one sitting. Vague tasks like "work on report" are harder to start than specific ones like "write introduction section for Q2 report."

Use the Move shortcut (`m`) to quickly reassign tasks between projects during your inbox triage.

### Focus Workflow

When working, stay in a single-project or single-tag view to reduce visual noise. Use filter shortcuts to isolate the relevant slice of your task list.

Close the sidebar (`s`) to further reduce distraction. Use the detail pane (`i`) only when you need to see full task notes — hide it otherwise.

If you find yourself frequently context-switching between tasks within a session, consider using time blocking externally (in your calendar) and mapping each block to a specific Antigravity filter or project view.

---

## Organization Strategies

### Project vs Tag: When to Use Each

Use **projects** for coherent bodies of work with a defined end state — things you are actively working toward. Use **tags** for cross-cutting properties that span projects: contexts like `@home`, `@computer`, or `@calls`, or states like `waiting`, `someday`, or `recurring`.

Avoid creating too many projects. If a project has fewer than three tasks and no clear future growth, it may be better handled as a tagged task inside a broader project.

### Priority Discipline

Assign priority sparingly. If everything is high priority, nothing is. A useful heuristic: only one or two tasks per day should be truly high priority. Use priority levels to distinguish "must happen today" from "should happen this week" from "nice to have."

### Recurring Tasks

Set up recurring tasks for obligations that repeat on a schedule — weekly reviews, regular reports, maintenance tasks. This prevents them from living only in your memory.

---

## Habits for Sustained Productivity

**Respect the inbox.** Do not leave captured items in the inbox for days. Process it on a schedule, not reactively throughout the day.

**Use the weekly review.** Once a week, go through every project and every someday/maybe item. Ask whether each project is still active, whether each task still belongs, and whether anything needs to be moved, deferred, or deleted. The weekly review keeps the system trustworthy.

**Keep task descriptions action-oriented.** Tasks that begin with a verb ("Draft," "Call," "Review," "Send") are clearer than noun-phrase tasks ("Marketing email," "John meeting"). You are less likely to procrastinate on tasks where the next action is obvious.

**Do not over-engineer the system.** Antigravity is a tool, not the work itself. The time you spend organizing should be a small fraction of the time you spend doing. If you are constantly adjusting projects, tags, and priorities instead of completing tasks, simplify.

---

## Troubleshooting Common Issues

**Shortcuts not responding:** Some terminal emulators intercept key combinations before Antigravity receives them. Check your terminal's key mapping settings if a shortcut is unresponsive. [Unverified — behavior varies by environment.]

**Sync not updating:** Use `r` to manually trigger a refresh. If the issue persists, check your network connection and any active VPN that might interfere with Antigravity's sync service.

**Accidental deletion:** Use `Ctrl+Z` / `Cmd+Z` immediately. If the session has closed, check whether Antigravity maintains an activity log or trash in its settings.

---

> This guide is based on general knowledge of terminal-based productivity tools and common Antigravity conventions. Specific shortcut mappings marked [Unverified] should be confirmed against your version's help reference (`?`). Behavior is not guaranteed to match across all versions or environments.