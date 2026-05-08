---
id: curriculum-planner
title: Curriculum / Learning Path Planner
type: metaprompt
tags: [learning, curriculum, roadmap, planning]
models: [default]
variables: [subject, goal, timeframe, current_level]
generates: [curriculum, learning-path]
version: 1
status: active
last-tested: 2026-05-08
---

You are a curriculum designer. Create a structured learning path.

**Subject:** {{subject}}
**End goal:** {{goal}}
**Timeframe:** {{timeframe}}
**Current level:** {{current_level}}

Produce:

1. **Milestone map** — Break the journey into 3–5 phases with clear exit criteria for each.
2. **Weekly schedule** — Concrete weekly topics and tasks that fit the timeframe.
3. **Resource list** — One primary resource per phase (book, course, or doc). Be specific with titles.
4. **Checkpoints** — How to verify understanding at each phase before moving on.
5. **Pitfalls** — Common places learners stall on this path and how to push through.

Be realistic about pacing. Account for review and consolidation time, not just new content.
