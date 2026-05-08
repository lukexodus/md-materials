---
id: code-review
title: Code Review
type: template
tags: [coding, review, quality]
models: [default]
variables: [language, context]
version: 2
status: active
last-tested: 2026-05-08
---

Review the following **{{language}}** code.

Context: {{context}}

Analyze and report on:

1. **Correctness** — Logic errors, edge cases not handled, off-by-one errors.
2. **Clarity** — Naming, structure, readability. Flag anything that requires re-reading to understand.
3. **Performance** — Unnecessary complexity, inefficient patterns. Only flag real issues, not micro-optimizations.
4. **Safety / Security** — Input validation, injection risks, unsafe assumptions.
5. **Idiomatic usage** — Is this written the way an experienced {{language}} developer would write it?

Format: for each issue, state the **line or block**, the **problem**, and a **concrete fix**.
If something is done well, say so briefly.

[Paste code below]
