# Prompt Library — Tutorial

This document covers everything you need to use and grow this vault effectively: plugin setup, the frontmatter schema, writing prompts, querying with Dataview, filling variables with Templater, and the Rofi retrieval workflow.

---

## 1. Initial Setup

### Required Obsidian Plugins

Install all four from **Settings → Community Plugins → Browse**:

|Plugin|Purpose|
|---|---|
|**Dataview**|Query and display prompts as dynamic tables|
|**Templater**|Fill `{{variables}}` interactively, create new prompts from templates|
|**obsidian-git**|Auto-commit to GitHub for versioning and sharing|
|**Commander** _(optional)_|Add toolbar buttons for quick actions|

After installing, enable each plugin. Dataview and Templater need one configuration step each — covered below.

### Dataview Configuration

Settings → Dataview:

- **Enable JavaScript Queries**: off (not needed here)
- **Inline Query Prefix**: `=` (default, keep it)
- **Render Null as**: leave blank (empty cells are cleaner than "null")

### Templater Configuration

Settings → Templater:

- **Template folder location**: `prompts/snippets` — or create a dedicated `_templates/` folder if you prefer
- **Trigger Templater on new file creation**: **ON** — this is what makes new prompt creation smooth
- **Enable Folder Templates**: **ON**, then map:
    - `prompts/` → `_templates/new-prompt.md` (you'll create this below)

### obsidian-git Configuration

Settings → obsidian-git:

- **Vault backup interval**: 10–15 minutes (auto-commit while you work)
- **Auto pull interval**: 5 minutes
- **Commit message**: `vault backup: {{date}} {{time}}`
- **Pull updates on startup**: ON

Run **obsidian-git: Initialize a new repo** from the command palette the first time, then set your remote:

```bash
# In your vault directory
git remote add origin git@github.com:youruser/prompt-vault.git
git push -u origin main
```

---

## 2. Frontmatter Schema — Field by Field

Every prompt file starts with a YAML block between `---` delimiters. This is what powers Dataview queries, Rofi retrieval, and variant linking.

```yaml
---
id: cs-learning-resource
title: CS Learning Resource Generator
type: metaprompt
tags: [learning, cs, curriculum]
models: [claude, llama, default]
variables: [topic, depth, audience]
generates: [learning-resource]
version: 2
status: active
last-tested: 2026-05-08
variants:
  claude: cs-learning-resource.claude
  llama: cs-learning-resource.llama
---
```

### Field Reference

#### `id` — string, required

Unique identifier in kebab-case. Used as the retrieval key everywhere. Must be unique across the entire vault.

```yaml
id: debug-assistant
id: cs-learning-resource.claude   # variant: base-id.model
```

**Rules:**

- Lowercase, hyphens only (no underscores, no spaces)
- Variants use dot notation: `base-id.modelname`
- Never change an `id` once a prompt is in use — it breaks Rofi lookups

---

#### `title` — string, required

Human-readable name shown in Rofi and Dataview tables.

```yaml
title: CS Learning Resource Generator
title: CS Learning Resource Generator (Claude)
```

---

#### `type` — enum, required

One of four values. Determines behavior in retrieval and display. See [Section 3](https://claude.ai/chat/d5165691-84b1-425d-8dba-d13a04d5f936#3-the-four-prompt-types) for full explanation.

```yaml
type: prompt       # ready-to-use, no variables
type: template     # has {{variables}}, used directly with a model
type: metaprompt   # generates or configures other prompts
type: snippet      # short fragment embedded in other prompts
```

---

#### `tags` — list, required

Free-form keywords for search and filtering. Use consistent vocabulary.

```yaml
tags: [learning, cs, curriculum]
tags: [coding, debugging, python]
tags: [snippet, role, educator]
```

**Suggested tag conventions:**

|Category|Tags|
|---|---|
|Domain|`cs`, `math`, `writing`, `systems`|
|Task|`learning`, `coding`, `research`, `debugging`, `review`|
|Format|`curriculum`, `explainer`, `brief`, `doc`, `blog`|
|Meta|`snippet`, `role`, `constraint`, `output-format`|
|Quality|`draft`, `tested`, `reliable`|

Snippets always get the tag `snippet` plus their function tag (`role`, `constraint`, etc.).

---

#### `models` — list, required

Which models this prompt is tuned for. Use `default` for model-agnostic prompts.

```yaml
models: [default]                    # works with any model
models: [claude]                     # Claude-specific (uses XML tags, system prompt)
models: [llama, mistral, local]      # local LLMs
models: [claude, gpt-4, default]     # tested on multiple
```

This field is informational — it helps you pick the right file and is shown in Rofi.

---

#### `variables` — list, optional

Names of all `{{placeholders}}` in the prompt body. Must exactly match the placeholder names (case-sensitive).

```yaml
variables: [topic, depth, audience]
```

The body would then contain: `{{topic}}`, `{{depth}}`, `{{audience}}`.

If there are no variables, omit this field or leave it empty. The Rofi script reads this field to know whether to trigger the variable-filling flow.

---

#### `generates` — list, optional, metaprompts only

What kind of output this metaprompt produces. Used in Dataview queries.

```yaml
generates: [learning-resource]
generates: [system-prompt]
generates: [prompt, template]
```

---

#### `version` — integer, required

Increment by 1 each time you make a meaningful change to the prompt body. Not the same as git history — this is a human-readable signal of maturity.

```yaml
version: 1    # initial
version: 2    # revised after testing
version: 3    # major restructure
```

---

#### `status` — enum, required

Controls visibility in queries and Rofi.

```yaml
status: active     # in use, shown everywhere
status: draft      # work in progress, shown in draft table only
status: archived   # retired, hidden from Rofi and active queries
```

The Rofi script skips `archived` prompts entirely. Use `archived` instead of deleting — git history is not enough context on its own.

---

#### `last-tested` — date, required for active prompts

ISO date of the last time you ran this prompt and verified the output was good. Used to surface stale prompts in Dataview.

```yaml
last-tested: 2026-05-08
```

---

#### `variants` — map, optional

Links a base prompt to its model-specific sibling files by `id`.

```yaml
variants:
  claude: cs-learning-resource.claude
  llama: cs-learning-resource.llama
```

This is informational metadata — it documents the relationship. The Rofi launcher currently loads each variant as a separate entry. A future enhancement could let you select the variant from within Rofi.

---

## 3. The Four Prompt Types

### `prompt`

Fully self-contained. No variables. Copy and paste directly. Use when the prompt is fixed and doesn't need customization.

```markdown
---
type: prompt
variables: []
---

Summarize the following text in three bullet points. Be concise.
Each bullet must be one sentence. Do not add commentary.

[Paste text below]
```

---

### `template`

Has `{{variables}}` that get filled before use. The most common type — covers most prompts that need light customization.

```markdown
---
type: template
variables: [language, context]
---

Review the following **{{language}}** code.
Context: {{context}}
...
```

---

### `metaprompt`

A prompt whose output is another prompt, a system prompt, or a structured configuration for an AI workflow. Also uses variables.

The key distinction: you're prompting the model to _produce something that will be used with a model_, not to produce a final end-user output.

```markdown
---
type: metaprompt
variables: [task_description, model_target]
generates: [prompt]
---

You are an expert prompt engineer.
Generate a high-quality prompt for: {{task_description}}
Target model: {{model_target}}
...
```

---

### `snippet`

A short, reusable fragment — typically a role definition, output constraint, or format instruction. Not used standalone; embedded into other prompts.

```markdown
---
type: snippet
---

You are a senior software engineer with deep expertise in systems design...
```

To use a snippet: open it, copy the body, paste it at the top of another prompt. A future Templater macro could automate this insertion.

---

## 4. Writing a New Prompt

### Step 1 — Create the file

In Obsidian, create a new note in the correct folder under `prompts/`. If you have Templater's folder templates configured, it will auto-fill the frontmatter skeleton.

Naming convention: `kebab-case-description.md` For variants: `base-name.modelname.md`

### Step 2 — Fill the frontmatter

Copy this skeleton and fill every field:

```yaml
---
id: your-unique-id
title: Your Human Readable Title
type: template
tags: [tag1, tag2]
models: [default]
variables: [var1, var2]
version: 1
status: draft
last-tested:
---
```

Start with `status: draft`. Promote to `active` after your first successful test.

### Step 3 — Write the body

Write your prompt below the closing `---`.

Variable placeholders use double curly braces: `{{variable_name}}` These must exactly match the names listed in the `variables` field.

```markdown
---
id: explain-algorithm
title: Algorithm Explainer
type: template
tags: [learning, cs, algorithms]
models: [default]
variables: [algorithm, audience]
version: 1
status: draft
last-tested:
---

Explain the **{{algorithm}}** algorithm to a **{{audience}}** audience.

Cover:
1. What problem it solves
2. How it works, step by step
3. Time and space complexity
4. One concrete example with input and output shown

Be precise. Do not add a conclusion paragraph.
```

### Step 4 — Test it

Copy the body, fill the variables manually, run it against your target model. If the output is good: set `status: active` and set `last-tested` to today.

### Step 5 — Create the Templater new-prompt template

Create `prompts/_templates/new-prompt.md` (or wherever your Templater folder points):

```markdown
---
id: <% tp.file.title.toLowerCase().replace(/ /g, '-') %>
title: <% tp.file.title %>
type: template
tags: []
models: [default]
variables: []
version: 1
status: draft
last-tested:
---

[Write your prompt here]
```

Now every new file created in `prompts/` auto-fills the frontmatter with the filename as the starting point for `id` and `title`.

---

## 5. Model Variants

When a prompt needs meaningfully different wording for different models, use sibling files with dot notation IDs.

### File naming

```
prompts/learning/
  cs-learning-resource.md          ← base / default
  cs-learning-resource.claude.md   ← Claude-specific
  cs-learning-resource.llama.md    ← local LLM
```

### When to create a variant

Create a variant when:

- The model requires a different prompt structure (e.g. local LLMs prefer `### Instruction` headers)
- You want to use Claude-specific features: `<system>` tags, XML section tags, extended thinking
- The base prompt performs poorly on a specific model and you've found a better wording

Do **not** create a variant just for minor wording differences. Variants add maintenance cost.

### Base file links to variants

In the base file's frontmatter:

```yaml
variants:
  claude: cs-learning-resource.claude
  llama: cs-learning-resource.llama
```

### Claude variant conventions

Claude responds well to:

- A `<system>` block at the top defining the role
- XML section tags for structured output (`<overview>`, `<summary>`, etc.)
- Explicit constraints stated as their own paragraph

```markdown
<system>
You are an expert educator. Every sentence must earn its place.
</system>

Create a learning resource on **{{topic}}** for **{{audience}}** at **{{depth}}** depth.

<core_concepts>
Explain each concept precisely. Use analogies.
</core_concepts>
```

### Local LLM variant conventions

Local models (Llama, Mistral, etc.) often respond better to:

- `### Instruction` / `### Response` format headers
- Shorter, simpler sentences
- Explicit section headers in the prompt rather than prose descriptions

```markdown
### Instruction

You are a computer science educator.

**Topic:** {{topic}}
**Audience:** {{audience}}

## Overview
## Core Concepts
## Examples
## Summary
```

---

## 6. Dataview — Querying Your Library

Dataview reads your frontmatter and renders live tables inside Obsidian. The `_index.md` file is your main dashboard — open it as your home view.

### How Dataview works

A Dataview block is a fenced code block with the language set to `dataview`:

````markdown
```dataview
TABLE title, tags, version
FROM "prompts"
WHERE type = "template" AND status = "active"
SORT last-tested DESC
```
````

Obsidian renders this as a live table, re-queried every time you open or edit the note.

### Query anatomy

```
TABLE  <fields to show as columns>
FROM   <folder or tag source>
WHERE  <filter conditions>
SORT   <field> ASC|DESC
LIMIT  <max rows>
```

### Key query patterns

**All active prompts for a specific tag:**

````markdown
```dataview
TABLE title, type, models, version
FROM "prompts"
WHERE contains(tags, "learning") AND status = "active"
SORT title ASC
```
````

**Find prompts that accept a specific variable:**

````markdown
```dataview
TABLE title, type, variables
FROM "prompts"
WHERE contains(variables, "topic") AND status = "active"
```
````

**Prompts not tested in over 60 days:**

````markdown
```dataview
TABLE title, last-tested, type
FROM "prompts"
WHERE status = "active" AND (last-tested < date(today) - dur(60 days) OR !last-tested)
SORT last-tested ASC
```
````

**All metaprompts and what they generate:**

````markdown
```dataview
TABLE title, generates, variables, version
FROM "prompts"
WHERE type = "metaprompt" AND status = "active"
SORT title ASC
```
````

**Prompts for a specific model:**

````markdown
```dataview
TABLE title, type, tags
FROM "prompts"
WHERE contains(models, "claude") AND status = "active"
SORT title ASC
```
````

**All drafts (your work queue):**

````markdown
```dataview
TABLE title, type, tags, file.mtime AS "Last edited"
FROM "prompts"
WHERE status = "draft"
SORT file.mtime DESC
```
````

### Adding a custom view

You can create any number of `.md` files with Dataview blocks as focused views. Examples worth creating:

- `prompts/_by-model.md` — one table per model
- `prompts/_stale.md` — prompts not tested in 30+ days
- `prompts/_metaprompts.md` — metaprompts with their `generates` field

### Dataview field reference for this vault

|Field|Type|Notes|
|---|---|---|
|`id`|string|kebab-case unique key|
|`title`|string|human-readable name|
|`type`|string|`prompt`, `template`, `metaprompt`, `snippet`|
|`tags`|list|use `contains(tags, "x")` to filter|
|`models`|list|use `contains(models, "claude")` to filter|
|`variables`|list|use `contains(variables, "topic")` to filter|
|`generates`|list|metaprompts only|
|`version`|number|use `version > 1` to find iterated prompts|
|`status`|string|`active`, `draft`, `archived`|
|`last-tested`|date|supports date arithmetic|
|`file.mtime`|date|auto — last modified time|
|`file.ctime`|date|auto — creation time|
|`file.name`|string|auto — filename without extension|

---

## 7. Templater — Variable Filling

Templater serves two purposes in this vault:

1. **New prompt creation** — auto-fill frontmatter skeleton when you create a file
2. **Variable filling on mobile** — interactively prompt you for each `{{variable}}`

On desktop, Rofi handles variable filling. On mobile, Templater handles it.

### Install and configure

Already covered in [Section 1](https://claude.ai/chat/d5165691-84b1-425d-8dba-d13a04d5f936#1-initial-setup). Confirm:

- Template folder: points to your templates location
- Trigger on new file creation: ON
- Folder templates: `prompts/` → `new-prompt.md`

### The new-prompt template

Create this file at `prompts/_templates/new-prompt.md`:

```markdown
---
id: <% tp.file.title.toLowerCase().replace(/ /g, '-') %>
title: <% tp.file.title %>
type: <% ['prompt','template','metaprompt','snippet'].includes(await tp.system.suggester(['prompt','template','metaprompt','snippet'], ['prompt','template','metaprompt','snippet'])) ? await tp.system.suggester(['prompt','template','metaprompt','snippet'], ['prompt','template','metaprompt','snippet']) : 'template' %>
tags: []
models: [default]
variables: []
version: 1
status: draft
last-tested:
---

<%*
// Prompt for initial variables list
const vars = await tp.system.prompt("Variables (comma-separated, or leave blank):", "");
if (vars && vars.trim()) {
  const varList = vars.split(',').map(v => v.trim()).filter(Boolean);
  // Update the variables line - user will need to also add {{placeholders}} in body
  tR += `\n> Variables defined: ${varList.join(', ')}\n> Remember to add {{placeholders}} in the body.\n`;
}
%>

[Write your prompt here]
```

### A simpler version (no JavaScript)

If you prefer to avoid Templater's JavaScript:

```markdown
---
id: {{VALUE:id (kebab-case)}}
title: {{VALUE:title}}
type: template
tags: []
models: [default]
variables: []
version: 1
status: draft
last-tested:
---

[Write your prompt here]
```

This uses Templater's `{{VALUE:prompt}}` syntax which shows an input dialog for each field.

### Variable-filling template for mobile use

Create `prompts/_templates/fill-prompt.md`. When you want to use a prompt on mobile:

1. Open the prompt file
2. Duplicate it to a scratch note
3. Run Templater on it using a fill template

A more practical mobile approach: use Templater's **"Run Templater on this file"** command after manually placing your cursor, combined with find-and-replace.

Or — the simplest mobile approach — use Obsidian's built-in **Find & Replace** (`Cmd+H` on iOS) to replace each `{{variable}}` with your value before copying.

### Useful Templater snippets for prompt files

**Insert today's date into `last-tested`:**

Create a Templater command or hotkey that runs:

```javascript
<%* 
const file = tp.file.find_tfile(tp.file.path(true));
await app.fileManager.processFrontMatter(file, (fm) => {
  fm['last-tested'] = tp.date.now("YYYY-MM-DD");
  fm['version'] = (parseInt(fm['version']) || 1) + 1;
});
tR += "";
%>
```

Bind this to a hotkey and run it after successfully testing a prompt. It auto-increments `version` and sets `last-tested` to today.

**Increment version only:**

```javascript
<%* 
const file = tp.file.find_tfile(tp.file.path(true));
await app.fileManager.processFrontMatter(file, (fm) => {
  fm['version'] = (parseInt(fm['version']) || 1) + 1;
});
tR += "";
%>
```

---

## 8. Rofi Retrieval on Desktop

### How it works

The `prompt-rofi.py` script reads all `.md` files under your `prompts/` folder, parses frontmatter, and presents them as a fuzzy-searchable Rofi list.

On selection:

- If the prompt has `variables`, Rofi shows one input dialog per variable, in order.
- The filled prompt body is copied to your clipboard via `wl-copy`.
- A desktop notification confirms the copy.

### Setup

```bash
cp prompt-rofi.py ~/.local/bin/prompt-rofi.py
chmod +x ~/.local/bin/prompt-rofi.py
pip install pyyaml --user   # for proper YAML parsing
```

Set the vault path if it differs from the default (`~/obsidian-vault/prompts`):

```bash
# Add to ~/.bashrc or ~/.zshrc
export PROMPT_VAULT="$HOME/path/to/your/vault/prompts"
```

### Hyprland keybinding

In `~/.config/hypr/hyprland.conf` — or your user override file if omarchy manages the main config:

```
bind = SUPER, P, exec, rofi -show prompt -modi "prompt:prompt-rofi.py"
```

Your existing run binding is untouched:

```
bind = SUPER SHIFT, R, exec, rofi -show run
```

### Searching in Rofi

The Rofi list shows each prompt as:

```
Title  #tag1 #tag2 [model1,model2]  (type)
```

You can type any part of this — title words, tag names, model names, or type — and Rofi's fuzzy matcher will narrow the list.

Examples:

- Type `learn` → shows all learning prompts
- Type `claude` → shows all Claude-specific variants
- Type `meta` → shows all metaprompts
- Type `debug python` → if you have a debug prompt tagged `python`

### Variable filling flow

When you select a prompt with variables, Rofi shows one input per variable:

```
[Rofi input] topic:     ← you type: "binary search trees"
[Rofi input] depth:     ← you type: "intermediate"
[Rofi input] audience:  ← you type: "CS undergrads"
```

Each value is substituted into the prompt body. The result goes to clipboard. If you press Escape on any input, that variable is left as `{{variable_name}}` — a visible placeholder you can fill manually after pasting.

### Testing without Hyprland

```bash
# Test listing output
python3 ~/.local/bin/prompt-rofi.py

# Test full Rofi integration
rofi -show prompt -modi "prompt:prompt-rofi.py"
```

---

## 9. Mobile Workflow

### Setup

- Install Obsidian on iOS or Android
- Set up Syncthing to sync your vault folder bidirectionally with your desktop
- Install the same plugins (Dataview, Templater, obsidian-git) in the mobile app

### Creating a prompt on mobile

1. Navigate to the correct `prompts/` subfolder
2. Create a new note — Templater fires automatically and fills the frontmatter skeleton
3. Give it a title when prompted
4. Write the prompt body
5. Set `status: draft`
6. obsidian-git syncs it back to desktop on the next interval (or trigger manually)

### Using a prompt on mobile

**If the prompt has no variables:**

1. Open the file
2. Select all body text (below the frontmatter)
3. Copy → paste into your AI interface

**If the prompt has variables — Option A (Find & Replace):**

1. Open the file
2. Use Find & Replace (`Cmd+H` on iOS) to replace `{{topic}}` with your value
3. Repeat for each variable
4. Copy the body
5. Undo all replacements (or just close without saving — don't save the filled version)

**If the prompt has variables — Option B (Scratch note):**

1. Duplicate the prompt file to a `_scratch/` folder
2. Fill variables in the duplicate
3. Copy the body
4. Delete the scratch file

Option B is safer — you never risk accidentally saving a half-filled prompt over the template.

### Recommended mobile view

Pin `prompts/_index.md` as a starred note. It gives you Dataview tables to browse even when you don't know what you're looking for.

---

## 10. Versioning with obsidian-git

### What gets versioned

Everything in the vault folder: prompt files, `_index.md`, templates, and the Rofi script.

### The version field vs. git history

These are different things:

- **`version` in frontmatter**: human-readable signal. Version 1 = initial. Version 2 = tested and revised. Version 3+ = significantly improved. Increment deliberately.
- **git history**: full change log, every save. Use this to recover old wording or see exactly what changed.

### Viewing history in Obsidian

obsidian-git adds a **File History** command (command palette: `obsidian-git: Show file history`). This shows every commit that touched the current file. You can diff against any previous version.

### Branching for experiments

If you want to test a significantly different version of a prompt without overwriting the working one:

```bash
# In your vault directory
git checkout -b experiment/cs-learning-v3
# edit the file
# test it
# if good: git checkout main && git merge experiment/cs-learning-v3
# if bad: git checkout main && git branch -d experiment/cs-learning-v3
```

Or simpler: just create a sibling file with a `-v3` suffix, test it, then rename/replace the original once you're happy.

### Sharing the vault

The vault is a standard git repo. To share with someone:

- Add them as a collaborator on GitHub (private repo)
- They clone it and open the folder as an Obsidian vault
- Syncthing or git handles ongoing sync

For a read-only share, a public GitHub repo works — just make sure no sensitive prompt content is in there before making it public.

---

## 11. Maintenance Habits

A prompt library degrades without upkeep. These habits keep it useful.

### When you write a prompt that works

Immediately:

1. Add it to the vault with proper frontmatter
2. Set `status: active` and `last-tested: today`
3. Let obsidian-git commit it

### Weekly (5 minutes)

Open `prompts/_index.md` and glance at the **Recently Updated** table. Check if any drafts are ready to promote to `active`.

### Monthly (15 minutes)

Run this Dataview query (add it to `_index.md` or a separate `_maintenance.md`):

````markdown
```dataview
TABLE title, last-tested, version
FROM "prompts"
WHERE status = "active" AND (last-tested < date(today) - dur(30 days) OR !last-tested)
SORT last-tested ASC
```
````

For each prompt surfaced:

- Still using it and it still works? Update `last-tested`.
- Not using it anymore? Set `status: archived`.
- Using it but getting mediocre results? Revise and increment `version`.

### When a prompt stops working well

1. Edit the body
2. Increment `version`
3. Update `last-tested` after testing the new version
4. If the change was significant, add a comment in the file body:

```markdown
<!-- v3: tightened output constraints, removed redundant section headers -->
```

### Archiving vs. deleting

Always archive, never delete. Set `status: archived` — the prompt disappears from Rofi and active Dataview tables but remains in git history with full context.

Delete only if a prompt was never used and has no value even as a reference.

---

## Quick Reference

### Frontmatter skeleton

```yaml
---
id: your-id-here
title: Your Title Here
type: template
tags: []
models: [default]
variables: []
version: 1
status: draft
last-tested:
---
```

### Type decision

```
Does it produce another prompt or system config?  → metaprompt
Is it a short role/constraint fragment?           → snippet
Does it have {{variables}}?                       → template
No variables, ready to use as-is?                → prompt
```

### Status lifecycle

```
draft → (test it) → active → (no longer useful) → archived
```

### Rofi search tips

|You type|You get|
|---|---|
|`learn`|all learning prompts|
|`claude`|all Claude-specific variants|
|`meta`|all metaprompts|
|`snippet`|all snippets|
|`debug`|debugging prompts|
|`#cs`|prompts tagged `cs`|

### Variable naming conventions

Use lowercase snake_case for variable names:

```
{{topic}}          not {{Topic}} or {{TOPIC}}
{{target_model}}   not {{targetModel}} or {{target-model}}
{{depth}}
{{audience}}
{{error_message}}
{{tools_available}}
```

Consistent casing means the Rofi input labels are clean and the find-replace on mobile is predictable.