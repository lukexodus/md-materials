---
id: script-generator
title: Script / Tool Generator
type: template
tags: [coding, automation, scripting, cli]
models: [default]
variables: [language, task, constraints]
version: 1
status: active
last-tested: 2026-05-08
---

Write a **{{language}}** script to accomplish the following:

**Task:** {{task}}
**Constraints / requirements:** {{constraints}}

Requirements for the output:
- Include a usage comment or docstring at the top.
- Handle errors explicitly — do not silently fail.
- Use clear variable and function names.
- Keep it minimal: do not add features not asked for.
- If there are non-obvious implementation choices, add a brief inline comment explaining why.

After the code, add a short section:
- **How to run it**
- **Dependencies** (if any)
- **Limitations / known edge cases**
