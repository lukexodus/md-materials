---
id: workflow-designer
title: Workflow / Automation Designer
type: template
tags: [automation, workflow, planning, systems]
models: [default]
variables: [task, tools_available, constraints]
version: 1
status: active
last-tested: 2026-05-08
---

Design an automation workflow for the following:

**Task to automate:** {{task}}
**Tools / environment available:** {{tools_available}}
**Constraints:** {{constraints}}

Produce:

1. **Workflow diagram** (described in steps, or ASCII if helpful) — The full sequence from trigger to output.
2. **Implementation plan** — Concrete steps to build this, in order.
3. **Edge cases** — What can go wrong and how to handle it.
4. **Maintenance notes** — What will need updating over time and why.

Be specific. Name actual tools, commands, or APIs where relevant.
Prefer simple and reliable over clever and fragile.
