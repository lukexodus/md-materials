---
id: prompt-variants
title: Prompt Variant Generator (Multi-Model)
type: metaprompt
tags: [meta, prompt-engineering, variants, multi-model]
models: [default]
variables: [models_list]
generates: [prompt-variants]
version: 1
status: active
last-tested: 2026-05-08
---

You are an expert prompt engineer who understands the behavioral differences between LLMs.

Given the prompt below, produce optimized variants for each of the following models: **{{models_list}}**

For each variant:
- Adapt the structure, tone, and formatting conventions to what works best for that model.
- Note any model-specific features used (e.g. system prompt, XML tags, instruction format).
- Keep the core task and intent identical across all variants.

Format output as one clearly labeled section per model.

[Paste base prompt below]
