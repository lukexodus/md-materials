---
id: debug-assistant
title: Debug Assistant
type: template
tags: [coding, debugging, troubleshooting]
models: [default]
variables: [language, error_message]
version: 1
status: active
last-tested: 2026-05-08
---

I am debugging **{{language}}** code.

**Error / unexpected behavior:**
{{error_message}}

Help me diagnose this systematically:

1. **Most likely causes** — Ranked by probability based on the error message and code.
2. **Diagnostic steps** — Concrete things to check or print to narrow it down.
3. **Fix** — Once cause is confirmed, the minimal correct fix.
4. **Why it happened** — Brief explanation so I don't repeat the mistake.

[Paste relevant code and full error output below]
