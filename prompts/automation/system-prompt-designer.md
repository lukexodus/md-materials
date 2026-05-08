---
id: system-prompt-designer
title: System Prompt Designer
type: metaprompt
tags: [automation, system-prompt, llm-config]
models: [default]
variables: [agent_role, task_domain, constraints, output_format]
generates: [system-prompt]
version: 1
status: active
last-tested: 2026-05-08
---

Design a system prompt for an AI agent with the following specification:

**Role:** {{agent_role}}
**Task domain:** {{task_domain}}
**Constraints / rules it must follow:** {{constraints}}
**Expected output format:** {{output_format}}

The system prompt you produce must:
- Define the role precisely in the first sentence.
- State what the agent should always do.
- State what the agent should never do.
- Specify the output format with an example if helpful.
- Be concise — every sentence must serve a function.

After the system prompt, briefly explain the reasoning behind any non-obvious choices.
