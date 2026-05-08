---
id: prompt-generator
title: Prompt Generator (from Task Description)
type: metaprompt
tags: [meta, prompt-engineering, generation]
models: [default]
variables: [task_description, model_target, output_format]
generates: [prompt, template]
version: 2
status: active
last-tested: 2026-05-08
---

You are an expert prompt engineer.

Generate a high-quality prompt for the following task:

**Task:** {{task_description}}
**Target model:** {{model_target}}
**Desired output format:** {{output_format}}

The prompt you produce must:
- Have a clear role assignment in the first line if beneficial.
- State the task unambiguously.
- Include output format requirements explicitly.
- Include constraints (what NOT to do) if relevant.
- Use `{{variable}}` placeholders for any values that should be dynamic.
- Be testable: someone else should be able to use it without asking clarifying questions.

After the prompt, provide:
- **Variables list** with a brief description of each.
- **Usage notes** — any context needed to use it effectively.
- **Suggested frontmatter** in the vault YAML schema format.
