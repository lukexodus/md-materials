# Prompt Library Management: Developer Workflow Edition

> Git + Folders + Jinja2. Free, fully local, no SaaS.  
> Organized by domain (software engineering · machine learning · learning).  
> Systematic, versioned, scriptable, scalable.

---

## Table of Contents

1. [Philosophy and Design Principles](https://claude.ai/chat/1e71ba84-587c-47a9-bce2-ea7b6905f447#1-philosophy-and-design-principles)
2. [Full Folder Structure](https://claude.ai/chat/1e71ba84-587c-47a9-bce2-ea7b6905f447#2-full-folder-structure)
3. [Domain Organization](https://claude.ai/chat/1e71ba84-587c-47a9-bce2-ea7b6905f447#3-domain-organization)
    - 3a. [Software Engineering](https://claude.ai/chat/1e71ba84-587c-47a9-bce2-ea7b6905f447#3a-software-engineering)
    - 3b. [Machine Learning](https://claude.ai/chat/1e71ba84-587c-47a9-bce2-ea7b6905f447#3b-machine-learning)
    - 3c. [General Learning](https://claude.ai/chat/1e71ba84-587c-47a9-bce2-ea7b6905f447#3c-general-learning)
4. [Jinja2 Template System](https://claude.ai/chat/1e71ba84-587c-47a9-bce2-ea7b6905f447#4-jinja2-template-system)
5. [YAML Variable Schema](https://claude.ai/chat/1e71ba84-587c-47a9-bce2-ea7b6905f447#5-yaml-variable-schema)
6. [Rendering Pipeline](https://claude.ai/chat/1e71ba84-587c-47a9-bce2-ea7b6905f447#6-rendering-pipeline)
7. [Git Workflow](https://claude.ai/chat/1e71ba84-587c-47a9-bce2-ea7b6905f447#7-git-workflow)
8. [Testing and Validation](https://claude.ai/chat/1e71ba84-587c-47a9-bce2-ea7b6905f447#8-testing-and-validation)
9. [CI/CD Integration](https://claude.ai/chat/1e71ba84-587c-47a9-bce2-ea7b6905f447#9-cicd-integration)
10. [Developer Tooling](https://claude.ai/chat/1e71ba84-587c-47a9-bce2-ea7b6905f447#10-developer-tooling)
11. [Scaling Patterns](https://claude.ai/chat/1e71ba84-587c-47a9-bce2-ea7b6905f447#11-scaling-patterns)
12. [Reference: End-to-End Examples](https://claude.ai/chat/1e71ba84-587c-47a9-bce2-ea7b6905f447#12-reference-end-to-end-examples)

---

## 1. Philosophy and Design Principles

A prompt library is a **codebase**. Apply the same discipline you would to source code.

|Principle|What it means in practice|
|---|---|
|Single source of truth|One canonical template per task. No copy-paste variants floating in notes.|
|Separation of concerns|Template logic (`*.j2`) is separate from data (`*.yaml`). Never hardcode values in templates.|
|Composability|Build complex prompts from small, tested partials — not monolithic strings.|
|Reviewability|Every prompt change is a diff. PRs, comments, and rollbacks all work.|
|Environment parity|The same template renders consistently across dev, staging, and production via var overrides.|
|Testability|Renders are deterministic given the same template + vars. Write assertions. Run them in CI.|

**What this system is not:** a runtime prompt injection framework. Templates are rendered before the LLM call, producing a static string. Rendering is a build step, not a runtime step.

---

## 2. Full Folder Structure

```
prompts/
│
├── _base/                        # Shared across all domains
│   ├── macros.j2                 # Reusable Jinja2 macros
│   ├── persona.j2                # Persona/role block
│   ├── output_format.j2          # Output constraints
│   ├── chain_of_thought.j2       # CoT instruction block
│   └── safety.j2                 # Scope/refusal rules
│
├── swe/                          # Software Engineering domain
│   ├── vars/
│   │   ├── default.yaml
│   │   ├── python.yaml           # Language-specific overrides
│   │   ├── typescript.yaml
│   │   └── production.yaml
│   ├── system.j2                 # SWE agent system prompt
│   ├── code_review.j2
│   ├── refactor.j2
│   ├── debug.j2
│   ├── test_writer.j2
│   ├── doc_writer.j2
│   ├── adr.j2                    # Architecture Decision Record
│   ├── pr_description.j2
│   └── onboarding.j2
│
├── ml/                           # Machine Learning domain
│   ├── vars/
│   │   ├── default.yaml
│   │   ├── nlp.yaml
│   │   ├── cv.yaml
│   │   └── tabular.yaml
│   ├── system.j2
│   ├── experiment_design.j2
│   ├── paper_review.j2
│   ├── dataset_analysis.j2
│   ├── error_analysis.j2
│   ├── hyperparameter_guide.j2
│   ├── ablation_plan.j2
│   └── results_summary.j2
│
├── learning/                     # General learning / knowledge work
│   ├── vars/
│   │   ├── default.yaml
│   │   ├── beginner.yaml
│   │   └── expert.yaml
│   ├── system.j2
│   ├── concept_explainer.j2
│   ├── study_plan.j2
│   ├── flashcard_generator.j2
│   ├── socratic_tutor.j2
│   ├── reading_guide.j2
│   └── feynman_review.j2
│
├── render.py                     # Main rendering CLI
├── test_prompts.py               # Automated test suite
├── validate.py                   # YAML schema validation
├── Makefile                      # Developer task runner
├── .github/
│   └── workflows/
│       └── prompt-ci.yml         # GitHub Actions CI
├── .gitignore
├── CHANGELOG.md
└── README.md
```

**Key conventions:**

- `system.j2` — the agent's standing system prompt, rendered once per session
- `vars/default.yaml` — baseline variables for the domain
- `vars/<specialization>.yaml` — overrides for a specific context (language, subfield, audience level)
- `vars/production.yaml` — production-ready overrides (shorter outputs, stricter scope)
- `_base/` — shared building blocks; never domain-specific logic here

---

## 3. Domain Organization

### 3a. Software Engineering

The `swe/` domain covers the full development lifecycle: writing, reviewing, debugging, documenting, and designing software.

**Role model:** a senior engineer pair-programming with you. Knows the stack, reads context, gives actionable output.

```
swe/
├── system.j2            # Standing SWE agent identity
├── code_review.j2       # PR or snippet review
├── refactor.j2          # Targeted refactoring with rationale
├── debug.j2             # Root-cause analysis from error + context
├── test_writer.j2       # Unit/integration test generation
├── doc_writer.j2        # Docstrings, READMEs, API docs
├── adr.j2               # Architecture Decision Record generator
├── pr_description.j2    # PR title + body from diff summary
└── onboarding.j2        # Codebase orientation for new team members
```

**Variable dimensions for SWE:**

```yaml
# swe/vars/default.yaml
stack:
  language: python
  framework: ""
  test_runner: pytest
  linter: ruff
  type_checker: mypy

standards:
  style_guide: PEP 8
  doc_format: Google
  commit_format: Conventional Commits
  coverage_target: 80

review:
  criteria:
    - correctness
    - readability
    - test coverage
    - error handling
    - performance implications
  severity_labels: ["critical", "major", "minor", "nit"]

context:
  has_codebase: false
  codebase_summary: ""
  related_files: []
  pr_diff: ""
```

**Language override — swe/vars/python.yaml:**

```yaml
stack:
  language: Python
  framework: FastAPI
  test_runner: pytest
  linter: ruff
  type_checker: mypy

standards:
  style_guide: PEP 8
  doc_format: Google
  type_hints: required
```

**Language override — swe/vars/typescript.yaml:**

```yaml
stack:
  language: TypeScript
  framework: Next.js
  test_runner: vitest
  linter: eslint
  type_checker: tsc

standards:
  style_guide: Airbnb
  doc_format: JSDoc
  strict_mode: true
```

---

### 3b. Machine Learning

The `ml/` domain covers experiment design, paper review, dataset analysis, error analysis, and results communication.

**Role model:** a methodical ML researcher who asks "what would invalidate this result?" before accepting it.

```
ml/
├── system.j2               # Standing ML agent identity
├── experiment_design.j2    # Hypothesis → metrics → controls
├── paper_review.j2         # Structured academic paper critique
├── dataset_analysis.j2     # EDA framing and data quality checks
├── error_analysis.j2       # Failure mode identification
├── hyperparameter_guide.j2 # Search strategy recommendations
├── ablation_plan.j2        # Ablation study design
└── results_summary.j2      # Results → conclusions → caveats
```

**Variable dimensions for ML:**

```yaml
# ml/vars/default.yaml
task:
  type: classification         # classification | regression | generation | retrieval
  modality: tabular            # tabular | text | image | audio | multimodal
  domain: ""

experiment:
  framework: pytorch
  tracking: mlflow            # mlflow | wandb | none
  hardware: cpu               # cpu | single-gpu | multi-gpu | tpu
  reproducibility:
    seed: true
    deterministic: true

evaluation:
  primary_metric: f1
  secondary_metrics:
    - precision
    - recall
    - latency_ms
  baseline: random            # random | majority | prior_art

reporting:
  include_confidence_intervals: true
  include_ablations: true
  caveat_depth: thorough      # brief | thorough
```

**Subfield overrides — ml/vars/nlp.yaml:**

```yaml
task:
  modality: text

experiment:
  framework: pytorch
  tokenizer: huggingface

evaluation:
  primary_metric: f1
  secondary_metrics:
    - exact_match
    - bleu
    - rouge_l

context:
  dataset_size_note: "Report train/val/test split sizes explicitly."
```

---

### 3c. General Learning

The `learning/` domain supports structured knowledge acquisition: concept explanation, study planning, Socratic dialogue, and Feynman-method review.

**Role model:** a patient, rigorous tutor who adapts depth to your current understanding and surfaces gaps before moving on.

```
learning/
├── system.j2              # Standing tutor agent identity
├── concept_explainer.j2   # Explain a concept at the right depth
├── study_plan.j2          # Structured multi-week learning plan
├── flashcard_generator.j2 # Q&A pairs for spaced repetition
├── socratic_tutor.j2      # Guided discovery via questions
├── reading_guide.j2       # Pre/during/post reading framework
└── feynman_review.j2      # Expose gaps via simple explanation
```

**Variable dimensions for learning:**

```yaml
# learning/vars/default.yaml
learner:
  level: intermediate        # beginner | intermediate | advanced | expert
  background: []             # list of relevant prior knowledge
  goal: understand           # understand | apply | teach | research

topic:
  name: ""
  domain: ""
  prerequisites: []

pedagogy:
  style: socratic            # direct | socratic | example-first | analogy-first
  use_analogies: true
  check_understanding: true
  pacing: moderate           # slow | moderate | fast

output:
  include_exercises: true
  include_references: false
  max_depth: 3               # concept nesting depth
```

**Audience overrides — learning/vars/beginner.yaml:**

```yaml
learner:
  level: beginner

pedagogy:
  style: example-first
  use_analogies: true
  pacing: slow

output:
  include_exercises: true
  max_depth: 1
```

**Audience overrides — learning/vars/expert.yaml:**

```yaml
learner:
  level: expert

pedagogy:
  style: socratic
  pacing: fast
  check_understanding: false

output:
  include_exercises: false
  include_references: true
  max_depth: 5
```

---

## 4. Jinja2 Template System

Install dependencies:

```bash
pip install jinja2 pyyaml jsonschema
```

### Base macros (_base/macros.j2)

```jinja2
{# ── Output format ─────────────────────────────────────────────── #}
{% macro format_block(format, max_words) %}
Output format: {{ format }}.
Word limit: {{ max_words }} words. Do not exceed this.
{% endmacro %}

{# ── Chain of thought ───────────────────────────────────────────── #}
{% macro chain_of_thought() %}
Before giving your final answer, reason step by step inside <thinking> tags.
Only then write your response outside those tags.
{% endmacro %}

{# ── Scope refusal ──────────────────────────────────────────────── #}
{% macro refuse_scope(boundary) %}
If the user asks about {{ boundary }}, politely decline and state that this is outside your current scope.
{% endmacro %}

{# ── Severity-labelled feedback ─────────────────────────────────── #}
{% macro severity_labels(labels) %}
Label every issue with one of: {{ labels | join(", ") }}.
{% endmacro %}

{# ── Codebase context block ─────────────────────────────────────── #}
{% macro codebase_context(ctx) %}
{% if ctx.has_codebase %}
Codebase context:
{{ ctx.codebase_summary }}

{% if ctx.related_files %}
Relevant files:
{% for f in ctx.related_files %}
- {{ f }}
{% endfor %}
{% endif %}
{% endif %}
{% endmacro %}

{# ── Stack declaration ───────────────────────────────────────────── #}
{% macro stack_block(stack) %}
Stack: {{ stack.language }}{% if stack.framework %} / {{ stack.framework }}{% endif %}.
Test runner: {{ stack.test_runner }}.
Linter: {{ stack.linter }}.
{% if stack.type_checker %}Type checker: {{ stack.type_checker }}.{% endif %}
{% endmacro %}
```

### Persona partial (_base/persona.j2)

```jinja2
{% macro persona_block(role, domain, seniority, org="") %}
You are a {{ seniority }} {{ role }}{% if org %} at {{ org }}{% endif %}.
Domain: {{ domain }}.
{% endmacro %}
```

### SWE templates

**swe/system.j2**

```jinja2
{% from "_base/persona.j2" import persona_block %}
{% from "_base/macros.j2" import stack_block, codebase_context, refuse_scope %}

{{ persona_block("software engineer", stack.language, "senior") }}

{{ stack_block(stack) }}

Standards:
- Style guide: {{ standards.style_guide }}
- Documentation format: {{ standards.doc_format }}
- Commit format: {{ standards.commit_format }}
- Test coverage target: {{ standards.coverage_target }}%

{{ codebase_context(context) }}

{{ refuse_scope("deployment configuration, infrastructure provisioning, and security auditing") }}
```

**swe/code_review.j2**

```jinja2
{% from "_base/macros.j2" import chain_of_thought, severity_labels, stack_block %}

{{ stack_block(stack) }}

{{ chain_of_thought() }}

Review the following code. Evaluate it for:
{% for criterion in review.criteria %}
- {{ criterion }}
{% endfor %}

For each issue:
1. Quote the relevant line(s)
2. Explain the problem clearly
3. Provide a concrete fix or alternative

{{ severity_labels(review.severity_labels) }}

{% if context.pr_diff %}
PR diff context:
{{ context.pr_diff }}
{% endif %}

End with a one-paragraph overall assessment.
```

**swe/debug.j2**

```jinja2
{% from "_base/macros.j2" import chain_of_thought, codebase_context %}

You are debugging a {{ stack.language }} issue.

{{ chain_of_thought() }}

Approach:
1. Identify the root cause — not just the symptom
2. State your hypothesis
3. List what would confirm or refute it
4. Propose the minimal fix
5. Suggest how to prevent this class of error in the future

{{ codebase_context(context) }}

{% if context.error_message %}
Error:
{{ context.error_message }}
{% endif %}
```

**swe/test_writer.j2**

```jinja2
{% from "_base/macros.j2" import stack_block %}

{{ stack_block(stack) }}

Write {{ test_type | default("unit") }} tests for the following code using {{ stack.test_runner }}.

Requirements:
- Cover happy paths, edge cases, and failure modes
- Use descriptive test names that state the scenario, not the implementation
- Aim for {{ standards.coverage_target }}% branch coverage
- {% if stack.type_checker %}Include type annotations{% endif %}
- No mocking unless strictly necessary; prefer real objects

{% if context.has_codebase %}
Codebase context:
{{ context.codebase_summary }}
{% endif %}
```

**swe/adr.j2**

```jinja2
Generate an Architecture Decision Record (ADR) in the following format.

# ADR-{{ adr.number | default("NNN") }}: {{ adr.title }}

## Status
{{ adr.status | default("Proposed") }}

## Context
[Describe the technical situation and the problem being solved.]

## Decision
[State the decision clearly.]

## Rationale
[Explain why this option was chosen over alternatives.]

## Alternatives Considered
{% for alt in adr.alternatives | default(["Alternative A", "Alternative B"]) %}
- {{ alt }}
{% endfor %}

## Consequences
[Positive and negative consequences of this decision.]

## Review Date
{{ adr.review_date | default("TBD") }}

---
Stack: {{ stack.language }}{% if stack.framework %} / {{ stack.framework }}{% endif %}
Standards: {{ standards.style_guide }}
```

### ML templates

**ml/system.j2**

```jinja2
{% from "_base/persona.j2" import persona_block %}

{{ persona_block("machine learning engineer", task.modality + " / " + task.type, "senior") }}

Task type: {{ task.type }}
Modality: {{ task.modality }}
{% if task.domain %}Domain: {{ task.domain }}{% endif %}

Framework: {{ experiment.framework }}
Experiment tracking: {{ experiment.tracking }}
Hardware: {{ experiment.hardware }}

Primary evaluation metric: {{ evaluation.primary_metric }}
Secondary metrics: {{ evaluation.secondary_metrics | join(", ") }}

Reproducibility requirements:
- Fixed random seed: {{ experiment.reproducibility.seed }}
- Deterministic ops: {{ experiment.reproducibility.deterministic }}

Always surface caveats and limitations before stating conclusions.
```

**ml/experiment_design.j2**

```jinja2
{% from "_base/macros.j2" import chain_of_thought %}

{{ chain_of_thought() }}

Design an experiment to test the following hypothesis:

Hypothesis: {{ hypothesis }}

Structure your output as:

## Experimental Setup
- Dataset: [describe splits, size, class balance]
- Baseline: {{ evaluation.baseline }}
- Model(s) to evaluate:
- Controls (what is held constant):

## Metrics
Primary: {{ evaluation.primary_metric }}
Secondary: {{ evaluation.secondary_metrics | join(", ") }}
{% if evaluation.include_confidence_intervals %}
Report all metrics with 95% confidence intervals.
{% endif %}

## Validity Threats
- What would invalidate this experiment?
- What confounds exist?

## Compute Budget
Hardware: {{ experiment.hardware }}
Estimated runs: [fill in]

## Reproducibility Checklist
- [ ] Random seed fixed ({{ experiment.reproducibility.seed }})
- [ ] Deterministic operations: {{ experiment.reproducibility.deterministic }}
- [ ] Environment captured (requirements.txt / conda env)
- [ ] Tracked in: {{ experiment.tracking }}
```

**ml/error_analysis.j2**

```jinja2
{% from "_base/macros.j2" import chain_of_thought %}

{{ chain_of_thought() }}

Perform a systematic error analysis for the following {{ task.type }} model.

Task: {{ task.type }} on {{ task.modality }} data
Primary metric: {{ evaluation.primary_metric }}

Structure your analysis as:

## Failure Mode Taxonomy
Group errors into categories. For each:
- Label the failure mode
- Describe the pattern
- Estimate frequency (if data is available)
- Hypothesize the cause

## Slice Analysis
Identify which data slices perform worst. Consider:
- Class/label imbalance
- Length or size distribution
- Domain shift from training data

## Root Cause Hypotheses
Rank the top 3 hypotheses for poor performance. For each:
- State the hypothesis
- What evidence supports it?
- What experiment would confirm or refute it?

## Remediation Options
For each root cause, propose a concrete fix (data, model, training, post-processing).

Caveat depth: {{ reporting.caveat_depth }}
```

### Learning templates

**learning/concept_explainer.j2**

```jinja2
{% from "_base/macros.j2" import chain_of_thought %}

You are explaining "{{ topic.name }}" to someone at the {{ learner.level }} level.

{% if learner.background %}
Their relevant background: {{ learner.background | join(", ") }}.
{% endif %}

Their goal: {{ learner.goal }}.

{% if pedagogy.style == "socratic" %}
Do not explain directly. Instead, guide them to the understanding through questions.
Begin by asking what they already know about {{ topic.name }}.
{% elif pedagogy.style == "analogy-first" %}
Begin with a concrete analogy before introducing the formal concept.
{% elif pedagogy.style == "example-first" %}
Begin with a working example, then extract the general principle.
{% else %}
Explain directly and clearly.
{% endif %}

{% if pedagogy.use_analogies %}
Use at least one concrete analogy grounded in everyday experience.
{% endif %}

{% if pedagogy.check_understanding %}
End with 2–3 short comprehension questions to verify understanding.
Do not provide the answers — let them respond.
{% endif %}

Nesting depth: explain up to {{ output.max_depth }} levels of sub-concepts before deferring to references.

{% if output.include_exercises %}
Include one short exercise the learner can do immediately.
{% endif %}
```

**learning/study_plan.j2**

```jinja2
Create a structured {{ duration | default("4-week") }} study plan for:

Topic: {{ topic.name }}
Domain: {{ topic.domain }}
Learner level: {{ learner.level }}
Goal: {{ learner.goal }}

{% if topic.prerequisites %}
Prerequisites already known:
{% for p in topic.prerequisites %}
- {{ p }}
{% endfor %}
{% endif %}

Structure the plan as:

## Week-by-Week Breakdown
For each week:
- Theme and learning objective
- Core concepts to cover
- Recommended activities (reading, coding, problem sets)
- Milestone: what the learner should be able to do by end of week

## Daily Session Structure
Suggest a repeatable session format:
- Duration: {{ session_duration | default("60 minutes") }}
- Ratio of concept study to practice

## Resources
{% if output.include_references %}
List 3–5 high-quality resources (books, papers, courses, documentation).
{% else %}
List resource types only — no specific titles.
{% endif %}

## Progress Checkpoints
Define 3 observable milestones across the full plan.

Pacing: {{ pedagogy.pacing }}
```

**learning/feynman_review.j2**

```jinja2
You are reviewing someone's Feynman-method explanation of "{{ topic.name }}".

The Feynman method requires explaining a concept simply enough that a beginner could understand it. Gaps in the explanation reveal gaps in understanding.

Your job:
1. Identify any point where the explanation relies on jargon without defining it
2. Identify any logical leap that skips a step
3. Identify any claim that is imprecise or incorrect
4. Ask one clarifying question per gap — do not answer it for them

Tone: direct, constructive, not discouraging.
Learner level: {{ learner.level }}

Do not rephrase or rewrite their explanation. Only surface the gaps.
```

---

## 5. YAML Variable Schema

Use a consistent schema across all domains. The top-level keys are standardized; domains add their own sub-trees.

```
vars/
├── persona       # Who the agent is
├── org           # Organizational context (optional)
├── stack         # Tech stack (swe only)
├── task          # Task definition (ml only)
├── learner       # Learner profile (learning only)
├── topic         # Topic definition (ml + learning)
├── experiment    # Experiment config (ml only)
├── evaluation    # Metrics and baselines
├── pedagogy      # Teaching style (learning only)
├── standards     # Engineering standards (swe only)
├── review        # Review criteria (swe only)
├── output        # Output format constraints
├── reporting     # Reporting depth/style
└── context       # Runtime context (codebase, error, diff, etc.)
```

### Schema validation with jsonschema

Define a schema per domain to catch missing or malformed vars before rendering:

```python
# schemas/swe.json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["stack", "standards", "output"],
  "properties": {
    "stack": {
      "type": "object",
      "required": ["language", "test_runner", "linter"],
      "properties": {
        "language": {"type": "string"},
        "framework": {"type": "string"},
        "test_runner": {"type": "string"},
        "linter": {"type": "string"},
        "type_checker": {"type": "string"}
      }
    },
    "standards": {
      "type": "object",
      "required": ["style_guide", "doc_format", "coverage_target"],
      "properties": {
        "style_guide": {"type": "string"},
        "doc_format": {"type": "string"},
        "coverage_target": {"type": "integer", "minimum": 0, "maximum": 100}
      }
    },
    "output": {
      "type": "object",
      "required": ["format"],
      "properties": {
        "format": {"type": "string"},
        "max_length": {"type": "integer"}
      }
    }
  }
}
```

```python
# validate.py
import json
import sys
from pathlib import Path
import yaml
import jsonschema

SCHEMAS = {
    "swe": "schemas/swe.json",
    "ml":  "schemas/ml.json",
    "learning": "schemas/learning.json",
}

def validate_vars(domain: str, vars_path: str):
    schema_path = SCHEMAS.get(domain)
    if not schema_path:
        print(f"No schema defined for domain: {domain}")
        return

    schema = json.loads(Path(schema_path).read_text())
    data = yaml.safe_load(Path(vars_path).read_text())
    jsonschema.validate(instance=data, schema=schema)
    print(f"✓ {vars_path}")

if __name__ == "__main__":
    domain, vars_path = sys.argv[1], sys.argv[2]
    try:
        validate_vars(domain, vars_path)
    except jsonschema.ValidationError as e:
        print(f"✗ Validation error in {vars_path}:\n  {e.message}")
        sys.exit(1)
```

---

## 6. Rendering Pipeline

### render.py — full CLI

```python
#!/usr/bin/env python3
"""
Render a Jinja2 prompt template with layered YAML variables.

Usage:
  python render.py swe/code_review
  python render.py swe/code_review --vars swe/vars/typescript.yaml
  python render.py ml/experiment_design --context '{"hypothesis": "CoT improves accuracy"}'
  python render.py learning/concept_explainer --level beginner --topic "gradient descent"
  python render.py swe/code_review --out review.txt --validate
"""

import argparse
import json
import sys
from pathlib import Path

import yaml
from jinja2 import Environment, FileSystemLoader, StrictUndefined

PROMPTS_DIR = Path(__file__).parent
RENDERED_DIR = PROMPTS_DIR / "rendered"

DOMAIN_DEFAULTS = {
    "swe":      "swe/vars/default.yaml",
    "ml":       "ml/vars/default.yaml",
    "learning": "learning/vars/default.yaml",
}


def deep_merge(base: dict, override: dict) -> dict:
    result = dict(base)
    for k, v in override.items():
        if k in result and isinstance(result[k], dict) and isinstance(v, dict):
            result[k] = deep_merge(result[k], v)
        else:
            result[k] = v
    return result


def load_vars(*paths) -> dict:
    merged = {}
    for path in paths:
        p = Path(path)
        if p.exists():
            with open(p) as f:
                data = yaml.safe_load(f) or {}
            merged = deep_merge(merged, data)
    return merged


def render(
    template_path: str,
    extra_vars: dict = None,
    var_files: list = None,
    strict: bool = False,
) -> str:
    domain = template_path.split("/")[0]

    undefined = StrictUndefined if strict else None
    env_kwargs = dict(
        loader=FileSystemLoader(str(PROMPTS_DIR)),
        trim_blocks=True,
        lstrip_blocks=True,
    )
    if strict:
        env_kwargs["undefined"] = StrictUndefined

    env = Environment(**env_kwargs)

    # Variable resolution order:
    # 1. Domain default  →  2. Explicit --vars files  →  3. --context inline JSON
    vars_chain = [PROMPTS_DIR / DOMAIN_DEFAULTS.get(domain, "")]
    if var_files:
        vars_chain.extend(var_files)

    variables = load_vars(*vars_chain)
    if extra_vars:
        variables = deep_merge(variables, extra_vars)

    template = env.get_template(f"{template_path}.j2")
    return template.render(**variables)


def main():
    parser = argparse.ArgumentParser(description="Render a prompt template")
    parser.add_argument("template", help="e.g. swe/code_review, ml/experiment_design")
    parser.add_argument("--vars", nargs="+", help="One or more YAML override files (applied in order)")
    parser.add_argument("--context", help="Inline JSON vars (highest priority)")
    parser.add_argument("--out", help="Output filename (written to rendered/)")
    parser.add_argument("--strict", action="store_true", help="Fail on undefined variables")
    parser.add_argument("--validate", action="store_true", help="Validate vars against schema before rendering")
    args = parser.parse_args()

    extra = {}
    if args.context:
        extra = json.loads(args.context)

    if args.validate:
        domain = args.template.split("/")[0]
        import subprocess
        for vf in (args.vars or []):
            result = subprocess.run(
                ["python", "validate.py", domain, vf],
                capture_output=True, text=True
            )
            if result.returncode != 0:
                print(result.stdout)
                sys.exit(1)

    output = render(
        args.template,
        extra_vars=extra,
        var_files=args.vars,
        strict=args.strict,
    )

    if args.out:
        RENDERED_DIR.mkdir(exist_ok=True)
        out_path = RENDERED_DIR / args.out
        out_path.write_text(output)
        print(f"Written to {out_path}", file=sys.stderr)
    else:
        print(output)


if __name__ == "__main__":
    main()
```

### Variable resolution order (highest wins)

```
--context JSON   ← highest priority (runtime overrides)
      ↓
--vars file(s)   ← specialization overrides (python.yaml, beginner.yaml)
      ↓
domain default   ← swe/vars/default.yaml, ml/vars/default.yaml, etc.
```

### Usage examples

```bash
# SWE — Python code review with strict undefined check
python render.py swe/code_review \
  --vars swe/vars/python.yaml \
  --strict

# SWE — TypeScript PR description
python render.py swe/pr_description \
  --vars swe/vars/typescript.yaml \
  --context '{"context": {"pr_diff": "Added OAuth2 middleware"}}'

# SWE — ADR generation
python render.py swe/adr \
  --vars swe/vars/python.yaml \
  --context '{"adr": {"number": "012", "title": "Adopt async task queue", "status": "Proposed"}}'

# ML — NLP experiment design
python render.py ml/experiment_design \
  --vars ml/vars/nlp.yaml \
  --context '{"hypothesis": "Adding retrieval context reduces hallucination rate by >10%"}'

# ML — error analysis for a CV model
python render.py ml/error_analysis \
  --vars ml/vars/cv.yaml \
  --context '{"task": {"type": "detection", "modality": "image"}}'

# Learning — explain gradient descent to a beginner
python render.py learning/concept_explainer \
  --vars learning/vars/beginner.yaml \
  --context '{"topic": {"name": "gradient descent", "domain": "machine learning"}}'

# Learning — expert-level study plan
python render.py learning/study_plan \
  --vars learning/vars/expert.yaml \
  --context '{"topic": {"name": "Transformers", "domain": "NLP"}, "duration": "6-week"}'

# Save to file with schema validation
python render.py swe/code_review \
  --vars swe/vars/python.yaml \
  --validate \
  --out swe_code_review.txt
```

---

## 7. Git Workflow

### Commit conventions

Follow [Conventional Commits](https://www.conventionalcommits.org/). Scope = domain.

```
feat(swe): add pr_description template
feat(ml): add ablation_plan template
fix(learning): fix infinite loop in socratic_tutor.j2
refactor(_base): extract stack_block macro from swe/system.j2
chore(swe): add typescript.yaml var overrides
test: add smoke tests for ml domain
docs: update CHANGELOG for v1.2.0
```

### Branch strategy

```
main              → stable, reviewed, tagged
dev               → integration branch for all work-in-progress
feat/<domain>/<name>  → new template or variable file
fix/<domain>/<name>   → bug fix in an existing template
exp/<domain>/<name>   → experimental variant (may not merge)
```

```bash
# Start a new template
git checkout -b feat/ml/ablation-plan
# ... write ml/ablation_plan.j2 and vars ...
git add ml/ablation_plan.j2
git commit -m "feat(ml): add ablation_plan template"
git push origin feat/ml/ablation-plan
# Open PR → review → merge to dev → promote to main
```

### A/B variant testing

```bash
# Variant A: chain-of-thought in code review
git checkout -b exp/swe/cot-code-review
# edit swe/code_review.j2 to add CoT instruction
git commit -am "exp(swe): add CoT to code_review — testing if rationale quality improves"

# Run both and compare outputs manually or with eval harness
python render.py swe/code_review > review_no_cot.txt
git stash
python render.py swe/code_review > review_with_cot.txt

# Promote or discard
git checkout main && git merge exp/swe/cot-code-review  # or
git branch -D exp/swe/cot-code-review
```

### Stable releases

```bash
git tag -a v1.0.0 -m "Stable: swe + ml + learning domains, all smoke tests passing"
git tag -a v1.1.0 -m "feat: typescript.yaml, nlp.yaml, beginner.yaml overrides"
git tag -a v1.2.0 -m "feat: adr.j2, ablation_plan.j2; fix: socratic loop"

# Pin a specific version in downstream tooling
git checkout v1.0.0 -- swe/code_review.j2

# View full history of a single template
git log --oneline --follow -- swe/code_review.j2
```

### CHANGELOG.md

Keep a structured changelog. Update it on every release:

```markdown
## [1.2.0] — 2025-09-01

### Added
- `swe/adr.j2` — Architecture Decision Record generator
- `ml/ablation_plan.j2` — Ablation study design template
- `learning/feynman_review.j2` — Feynman-method gap analysis

### Fixed
- `learning/socratic_tutor.j2` — removed runaway question loop on undefined topic
- `_base/macros.j2` — `codebase_context` macro now handles empty `related_files` list

### Changed
- `swe/vars/default.yaml` — coverage_target raised from 70 to 80
```

---

## 8. Testing and Validation

### test_prompts.py — full test suite

```python
"""
Prompt library test suite.

Covers:
  - All templates render without error
  - Rendered output meets minimum length
  - Required strings appear in output
  - No undefined variable placeholders leak through
  - Schema validation passes for all var files

Run: pytest test_prompts.py -v
"""

import json
import subprocess
import re
from pathlib import Path
import pytest
import yaml

PROMPTS_DIR = Path(__file__).parent

# ─── Smoke tests (renders without error, output > 50 chars) ──────────────────

SMOKE_CASES = [
    # (template, extra_context)
    ("swe/system",        {}),
    ("swe/code_review",   {}),
    ("swe/debug",         {"context": {"error_message": "AttributeError: 'NoneType' object has no attribute 'split'"}}),
    ("swe/test_writer",   {}),
    ("swe/adr",           {"adr": {"number": "001", "title": "Adopt Redis for caching"}}),
    ("ml/system",         {}),
    ("ml/experiment_design", {"hypothesis": "CoT prompting improves F1 by >5%"}),
    ("ml/error_analysis", {}),
    ("learning/system",   {}),
    ("learning/concept_explainer", {"topic": {"name": "backpropagation", "domain": "ML"}}),
    ("learning/study_plan",        {"topic": {"name": "transformers", "domain": "NLP"}}),
    ("learning/feynman_review",    {"topic": {"name": "attention mechanism"}}),
]

@pytest.mark.parametrize("template,ctx", SMOKE_CASES)
def test_renders_without_error(template, ctx):
    result = subprocess.run(
        ["python", "render.py", template, "--context", json.dumps(ctx)],
        capture_output=True, text=True, cwd=PROMPTS_DIR
    )
    assert result.returncode == 0, f"Render failed:\n{result.stderr}"
    assert len(result.stdout.strip()) > 50, "Output suspiciously short"


# ─── Content assertions (specific strings must appear) ───────────────────────

CONTENT_CASES = [
    ("swe/code_review",  {}, ["critical", "major", "minor", "nit"]),
    ("swe/debug",        {"context": {"error_message": "TypeError"}}, ["root cause", "hypothesis"]),
    ("ml/experiment_design", {"hypothesis": "test"}, ["Baseline", "Metrics", "Reproducibility"]),
    ("learning/concept_explainer", {"topic": {"name": "overfitting", "domain": "ML"}}, ["overfitting"]),
]

@pytest.mark.parametrize("template,ctx,required_strings", CONTENT_CASES)
def test_required_content(template, ctx, required_strings):
    result = subprocess.run(
        ["python", "render.py", template, "--context", json.dumps(ctx)],
        capture_output=True, text=True, cwd=PROMPTS_DIR
    )
    output = result.stdout
    for s in required_strings:
        assert s.lower() in output.lower(), f"Expected '{s}' in output of {template}"


# ─── No undefined variable leakage ────────────────────────────────────────────

UNDEFINED_PATTERN = re.compile(r"\{\{[^}]+\}\}")

@pytest.mark.parametrize("template,ctx", SMOKE_CASES)
def test_no_undefined_variables(template, ctx):
    result = subprocess.run(
        ["python", "render.py", template, "--context", json.dumps(ctx)],
        capture_output=True, text=True, cwd=PROMPTS_DIR
    )
    matches = UNDEFINED_PATTERN.findall(result.stdout)
    assert not matches, f"Unrendered variables found in {template}: {matches}"


# ─── YAML validity for all var files ──────────────────────────────────────────

VAR_FILES = list(PROMPTS_DIR.rglob("vars/*.yaml"))

@pytest.mark.parametrize("var_file", VAR_FILES)
def test_yaml_parses(var_file):
    try:
        data = yaml.safe_load(var_file.read_text())
        assert isinstance(data, dict), "Expected top-level dict"
    except yaml.YAMLError as e:
        pytest.fail(f"YAML parse error in {var_file}: {e}")


# ─── Override merging correctness ─────────────────────────────────────────────

def test_typescript_override_applies():
    """TypeScript override should change language from python to TypeScript."""
    result = subprocess.run(
        ["python", "render.py", "swe/system",
         "--vars", "swe/vars/typescript.yaml"],
        capture_output=True, text=True, cwd=PROMPTS_DIR
    )
    assert "TypeScript" in result.stdout
    assert "python" not in result.stdout.lower()
```

```bash
# Run all tests
pytest test_prompts.py -v

# Run only smoke tests
pytest test_prompts.py -v -k "smoke"

# Run only content assertion tests
pytest test_prompts.py -v -k "content"

# Run with coverage report
pytest test_prompts.py --tb=short -q
```

---

## 9. CI/CD Integration

### GitHub Actions — .github/workflows/prompt-ci.yml

```yaml
name: Prompt Library CI

on:
  push:
    branches: [main, dev]
    paths:
      - "**/*.j2"
      - "**/*.yaml"
      - "render.py"
      - "test_prompts.py"
      - "validate.py"
  pull_request:
    branches: [main]
    paths:
      - "**/*.j2"
      - "**/*.yaml"

jobs:
  validate-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.11"

      - name: Install dependencies
        run: pip install jinja2 pyyaml jsonschema pytest

      - name: Validate YAML files
        run: |
          python -c "
          import yaml, pathlib, sys
          errors = []
          for f in pathlib.Path('.').rglob('*.yaml'):
              try:
                  yaml.safe_load(f.read_text())
              except yaml.YAMLError as e:
                  errors.append(f'{f}: {e}')
          if errors:
              print('\n'.join(errors)); sys.exit(1)
          print(f'All YAML valid ({len(list(pathlib.Path(\".\").rglob(\"*.yaml\")))} files checked)')
          "

      - name: Validate vars against schemas
        run: |
          for domain in swe ml learning; do
            for f in $domain/vars/*.yaml; do
              python validate.py $domain $f
            done
          done

      - name: Run prompt test suite
        run: pytest test_prompts.py -v --tb=short

      - name: Check for undefined variable leakage
        run: pytest test_prompts.py -v -k "undefined"
```

### Pre-commit hook

Run tests locally before every commit:

```bash
# .git/hooks/pre-commit
#!/bin/bash
set -e
echo "Running prompt library checks..."
python -c "
import yaml, pathlib, sys
for f in pathlib.Path('.').rglob('*.yaml'):
    yaml.safe_load(f.read_text())
print('YAML valid')
"
pytest test_prompts.py -q --tb=short
echo "All checks passed."
```

```bash
chmod +x .git/hooks/pre-commit
```

Or use [pre-commit](https://pre-commit.com/):

```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: validate-yaml
        name: Validate YAML vars
        entry: python validate.py
        language: python
        files: "vars/.*\\.yaml$"
        pass_filenames: true

      - id: prompt-tests
        name: Prompt smoke tests
        entry: pytest test_prompts.py -q --tb=short
        language: python
        pass_filenames: false
        always_run: true
```

---

## 10. Developer Tooling

### Makefile

```makefile
.PHONY: render render-all test validate lint clean tag help

TEMPLATE ?= swe/system
VERSION  ?= v0.0.0

help:
	@echo "Usage:"
	@echo "  make render TEMPLATE=swe/code_review"
	@echo "  make render-all"
	@echo "  make test"
	@echo "  make validate"
	@echo "  make lint"
	@echo "  make tag VERSION=v1.2.0"
	@echo "  make clean"

render:
	python render.py $(TEMPLATE)

render-python:
	python render.py swe/$(TEMPLATE) --vars swe/vars/python.yaml

render-typescript:
	python render.py swe/$(TEMPLATE) --vars swe/vars/typescript.yaml

render-nlp:
	python render.py ml/$(TEMPLATE) --vars ml/vars/nlp.yaml

render-beginner:
	python render.py learning/$(TEMPLATE) --vars learning/vars/beginner.yaml

render-all:
	@mkdir -p rendered
	@for domain in swe ml learning; do \
	  python render.py $$domain/system --out $${domain}_system.txt; \
	  echo "Rendered $$domain/system"; \
	done

test:
	pytest test_prompts.py -v

test-smoke:
	pytest test_prompts.py -v -k "smoke"

test-content:
	pytest test_prompts.py -v -k "content"

validate:
	@for domain in swe ml learning; do \
	  for f in $$domain/vars/*.yaml; do \
	    python validate.py $$domain $$f; \
	  done; \
	done

lint:
	@python -c "\
	import yaml, pathlib, sys; \
	errors = []; \
	[errors.append(str(f)) or yaml.safe_load(f.read_text()) \
	 for f in pathlib.Path('.').rglob('*.yaml')]; \
	print('YAML lint: OK')"

clean:
	rm -rf rendered/ __pycache__/ .pytest_cache/

tag:
	git tag -a $(VERSION) -m "Release $(VERSION)"
	git push origin $(VERSION)
	@echo "Tagged $(VERSION)"

diff:
	git diff HEAD -- $(FILE)

log:
	git log --oneline -- $(FILE)
```

### Shell aliases (add to .zshrc / .bashrc)

```bash
# Navigate quickly
alias prompts="cd ~/projects/prompts"

# Render shortcuts
alias pr-swe="python ~/projects/prompts/render.py swe/code_review"
alias pr-ml="python ~/projects/prompts/render.py ml/experiment_design"
alias pr-learn="python ~/projects/prompts/render.py learning/concept_explainer"

# Render to clipboard (macOS)
alias pr-clip="python ~/projects/prompts/render.py $1 | pbcopy && echo 'Copied to clipboard'"

# Run tests
alias pr-test="cd ~/projects/prompts && pytest test_prompts.py -q"
```

### List all available templates

```bash
# List all templates by domain
find . -name "*.j2" ! -path "./_base/*" | sort | awk -F'/' '{print $2"/"$3}' | sed 's/.j2//'
```

---

## 11. Scaling Patterns

### Pattern 1: Multi-level variable inheritance

For large teams or projects, use a 3-layer var stack:

```
org/default.yaml        ← organization-wide defaults (shared by all teams)
      ↓
team/backend.yaml       ← team-level overrides
      ↓
project/payments.yaml   ← project-specific overrides
```

```bash
python render.py swe/code_review \
  --vars org/default.yaml \
  --vars team/backend.yaml \
  --vars project/payments.yaml
```

The deep-merge in `render.py` handles this automatically — files are merged left to right, later files win.

### Pattern 2: Prompt chains (sequential templates)

Some workflows require multiple prompts in sequence. Render them as a pipeline:

```bash
#!/bin/bash
# chain_ml_experiment.sh
# Step 1: Design the experiment
python render.py ml/experiment_design \
  --vars ml/vars/nlp.yaml \
  --context '{"hypothesis": "'"$HYPOTHESIS"'"}' \
  > rendered/01_design.txt

# Step 2: Plan the ablations
python render.py ml/ablation_plan \
  --vars ml/vars/nlp.yaml \
  > rendered/02_ablations.txt

# Step 3: Results summary template (filled after runs)
python render.py ml/results_summary \
  --vars ml/vars/nlp.yaml \
  > rendered/03_summary.txt

echo "Chain rendered: rendered/01_design.txt, 02_ablations.txt, 03_summary.txt"
```

### Pattern 3: Parametric batch rendering

Generate many variants at once for evaluation:

```python
# batch_render.py
import json
import subprocess
from pathlib import Path

VARIANTS = [
    {"pedagogy": {"style": "direct"},        "tag": "direct"},
    {"pedagogy": {"style": "socratic"},       "tag": "socratic"},
    {"pedagogy": {"style": "example-first"},  "tag": "example_first"},
    {"pedagogy": {"style": "analogy-first"},  "tag": "analogy_first"},
]

topic = {"topic": {"name": "gradient descent", "domain": "ML"}}

Path("rendered/batch").mkdir(parents=True, exist_ok=True)

for v in VARIANTS:
    ctx = {**topic, **v}
    ctx.pop("tag")
    result = subprocess.run(
        ["python", "render.py", "learning/concept_explainer",
         "--vars", "learning/vars/beginner.yaml",
         "--context", json.dumps(ctx)],
        capture_output=True, text=True
    )
    out_path = Path(f"rendered/batch/concept_explainer_{v['tag']}.txt")
    out_path.write_text(result.stdout)
    print(f"Written: {out_path}")
```

```bash
python batch_render.py
# Then evaluate which style produces the best output
```

### Pattern 4: Context injection from files

Pipe real file content (code, papers, logs) into templates at render time:

```bash
# Inject a real file as codebase context
CODEBASE=$(cat src/auth/middleware.py | python -c "import sys,json; print(json.dumps(sys.stdin.read()))")

python render.py swe/code_review \
  --vars swe/vars/python.yaml \
  --context "{\"context\": {\"has_codebase\": true, \"codebase_summary\": $CODEBASE}}"
```

Or use a helper script:

```python
# inject_file.py
import argparse
import json
import subprocess
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("template")
parser.add_argument("--file", required=True, help="File to inject as context")
parser.add_argument("--vars", nargs="+")
args = parser.parse_args()

content = Path(args.file).read_text()
ctx = {"context": {"has_codebase": True, "codebase_summary": content}}

cmd = ["python", "render.py", args.template,
       "--context", json.dumps(ctx)]
if args.vars:
    cmd += ["--vars"] + args.vars

result = subprocess.run(cmd, capture_output=True, text=True)
print(result.stdout)
```

```bash
python inject_file.py swe/code_review \
  --file src/auth/middleware.py \
  --vars swe/vars/python.yaml
```

---

## 12. Reference: End-to-End Examples

### Example A: SWE — Python code review pipeline

```bash
# 1. Inject a real file, render, copy to clipboard
python inject_file.py swe/code_review \
  --file src/payments/processor.py \
  --vars swe/vars/python.yaml | pbcopy

# 2. Paste into your LLM interface
# 3. Commit the template version used
git log --oneline -1 -- swe/code_review.j2
# → abc1234 fix(swe): sharpen severity label instructions
```

### Example B: ML — full experiment workflow

```bash
# Design
python render.py ml/experiment_design \
  --vars ml/vars/nlp.yaml \
  --context '{"hypothesis": "Few-shot CoT reduces hallucination rate on medical QA by >8%"}' \
  --out 01_design.txt

# Plan ablations
python render.py ml/ablation_plan \
  --vars ml/vars/nlp.yaml \
  --out 02_ablations.txt

# Error analysis (after running experiments)
python render.py ml/error_analysis \
  --vars ml/vars/nlp.yaml \
  --context '{"task": {"type": "QA", "modality": "text"}}' \
  --out 03_error_analysis.txt

# Results summary
python render.py ml/results_summary \
  --vars ml/vars/nlp.yaml \
  --out 04_results.txt
```

### Example C: Learning — structured topic onboarding

```bash
# 1. Get a concept explanation at the right level
python render.py learning/concept_explainer \
  --vars learning/vars/intermediate.yaml \
  --context '{"topic": {"name": "attention is all you need", "domain": "NLP"}}' \
  --out concept.txt

# 2. Generate a study plan
python render.py learning/study_plan \
  --vars learning/vars/intermediate.yaml \
  --context '{"topic": {"name": "Transformers", "domain": "NLP"}, "duration": "4-week"}' \
  --out study_plan.txt

# 3. Generate flashcards
python render.py learning/flashcard_generator \
  --vars learning/vars/intermediate.yaml \
  --context '{"topic": {"name": "attention mechanism"}}' \
  --out flashcards.txt

# 4. After studying — Feynman review to surface gaps
python render.py learning/feynman_review \
  --vars learning/vars/intermediate.yaml \
  --context '{"topic": {"name": "multi-head attention"}}' \
  --out feynman.txt
```

---

## Quick Reference

|Domain|Templates|Key vars|
|---|---|---|
|`swe/`|system, code_review, refactor, debug, test_writer, doc_writer, adr, pr_description|stack, standards, review, context|
|`ml/`|system, experiment_design, paper_review, dataset_analysis, error_analysis, ablation_plan, results_summary|task, experiment, evaluation, reporting|
|`learning/`|system, concept_explainer, study_plan, flashcard_generator, socratic_tutor, reading_guide, feynman_review|learner, topic, pedagogy, output|
|`_base/`|macros.j2, persona.j2, output_format.j2, chain_of_thought.j2, safety.j2|(imported by all)|

|Operation|Command|
|---|---|
|Render a template|`python render.py swe/code_review`|
|Render with override|`python render.py swe/code_review --vars swe/vars/typescript.yaml`|
|Render with inline context|`python render.py ml/experiment_design --context '{"hypothesis": "..."}'`|
|Inject a file|`python inject_file.py swe/code_review --file src/auth.py`|
|Batch render variants|`python batch_render.py`|
|Run tests|`pytest test_prompts.py -v`|
|Validate YAML schemas|`make validate`|
|Tag a release|`make tag VERSION=v1.2.0`|
|Diff a template|`git diff HEAD~1 HEAD -- swe/code_review.j2`|
|View template history|`git log --oneline -- swe/code_review.j2`|

---

_Stack: Python 3.11+, Jinja2, PyYAML, jsonschema, pytest, Git. No external services._