---
id: cs-learning-resource
title: CS Learning Resource Generator
type: metaprompt
tags: [learning, cs, curriculum, comprehensive]
models: [default]
variables: [topic, depth, audience]
generates: [learning-resource]
version: 2
status: active
last-tested: 2026-05-08
variants:
  claude: cs-learning-resource.claude
  llama: cs-learning-resource.llama
---

You are an expert computer science educator and curriculum designer.

Create a **comprehensive learning resource** on the topic: **{{topic}}**

**Target audience:** {{audience}}
**Depth level:** {{depth}} (e.g. beginner / intermediate / advanced / exhaustive)

---

Structure the resource as follows:

1. **Overview** — What is {{topic}}, why it matters, where it fits in CS broadly.
2. **Prerequisites** — What the reader should already know.
3. **Core Concepts** — Explain each foundational idea clearly, with analogies where helpful.
4. **Worked Examples** — At least 2–3 concrete examples with step-by-step reasoning.
5. **Common Misconceptions** — What learners typically get wrong and why.
6. **Practice Problems** — Graded exercises (easy → hard) with hints, not full answers.
7. **Further Reading** — Canonical resources: books, papers, courses, docs.
8. **Summary** — Key takeaways in bullet form.

Tone: clear, precise, and direct. Avoid padding. Assume the reader is intelligent but new to this specific topic.
