# Prompt Library Vault

A structured, local-first prompt library for AI workflows.

## Structure

```
prompts/
├── learning/       # Learning resource generation prompts
├── coding/         # Code generation, review, explanation
├── research/       # Research, summarization, analysis
├── automation/     # Scripting, workflow, task automation
├── content/        # Writing, documentation, social content
├── metaprompts/    # Prompts that generate or configure other prompts
└── snippets/       # Short reusable fragments embedded in other prompts
```

## Frontmatter Schema

Every prompt file uses this YAML frontmatter:

```yaml
---
id: unique-kebab-case-id
title: Human Readable Title
type: prompt | template | metaprompt | snippet
tags: [tag1, tag2]
models: [claude, llama, default]
variables: [var1, var2]        # matches {{var1}} in body
generates: [type-it-produces]  # for metaprompts only
version: 1
status: active | draft | archived
last-tested: YYYY-MM-DD
---
```

## Retrieval

Use Rofi prompt mode:
```bash
rofi -show prompt -modi "prompt:prompt-rofi.py"
```

Or browse via Obsidian Dataview dashboard: `prompts/_index.md`

## Tools

- `prompt-rofi.py` — Rofi launcher with variable filling
- `obsidian-git` plugin — auto-versioning to GitHub
- Templater plugin — variable filling on mobile
