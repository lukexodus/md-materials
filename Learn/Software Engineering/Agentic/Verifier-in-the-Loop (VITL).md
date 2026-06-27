# Verifier-in-the-Loop (VITL)
### The Definitive Implementation Handbook for AI-Assisted Software Development

---

> **Prerequisites:** This handbook assumes you have already implemented a spec-first development workflow. All verification concepts here assume that specifications, acceptance criteria, and architectural decisions are written artifacts living in your repository.

---

## Table of Contents

- [Part 1 — Foundations](#part-1--foundations)
- [Part 2 — Architecture](#part-2--architecture)
- [Part 3 — Verifier Types](#part-3--verifier-types)
- [Part 4 — Complete Developer Workflow](#part-4--complete-developer-workflow)
- [Part 5 — Building the Workflow](#part-5--building-the-workflow)
- [Part 6 — Repository Structure](#part-6--repository-structure)
- [Part 7 — Prompt Engineering](#part-7--prompt-engineering)
- [Part 8 — Rule-Based Verification](#part-8--rule-based-verification)
- [Part 9 — CI/CD Integration](#part-9--cicd-integration)
- [Part 10 — Scaling](#part-10--scaling)
- [Part 11 — Failure Modes](#part-11--failure-modes)
- [Part 12 — Best Practices](#part-12--best-practices)
- [Part 13 — End-to-End Example](#part-13--end-to-end-example)
- [Part 14 — Templates](#part-14--templates)
- [Part 15 — Future Directions](#part-15--future-directions)

---

## Part 1 — Foundations

### What Verifier-in-the-Loop (VITL) Is

Verifier-in-the-Loop (VITL) is an engineering pattern in which one or more independent verification agents — LLM-based, rule-based, or hybrid — are inserted into the AI-assisted development pipeline to evaluate outputs before they are accepted, merged, or deployed.

The core claim is straightforward: **an AI that generates code should not be the primary judge of its own output.** A separate verifier — with its own context, prompt, and evaluation criteria — provides an independent signal that the output satisfies the specification, respects constraints, and does not introduce risk.

VITL is not a single tool. It is an architectural discipline. The verifier may be:

- A second LLM call with a different system prompt
- A specialized model fine-tuned for code review
- A deterministic linter, type checker, or test runner
- A human reviewer at a specific gate
- Any combination of the above

The unifying characteristic is **independence**: the verifier does not share the generative agent's context, assumptions, or reasoning path.

---

### Why VITL Exists

AI coding agents have three structural failure modes that VITL is designed to address:

**1. Confident hallucination.** LLMs generate plausible-sounding code that does not satisfy the specification, misuses an API, or introduces subtle logic errors — with high confidence and no self-indication of the problem.

**2. Sycophantic self-review.** When asked to review its own output, an LLM tends to confirm rather than challenge. The same biases that produced the error are active during the review.

**3. Specification drift.** Without an explicit verification step, the implementation gradually diverges from the spec as the agent fills in gaps with assumptions. Each assumption compounds.

VITL inserts a circuit breaker after generation: an independent agent that asks *"Does this output actually satisfy the requirements?"* before the output is accepted.

---

### Problems VITL Solves

| Problem | Without VITL | With VITL |
|---|---|---|
| Hallucinated API usage | Discovered at runtime | Caught by API contract verifier before merge |
| Logic errors in edge cases | Found during QA or production | Caught by testing verifier against acceptance criteria |
| Spec divergence | Discovered in sprint review | Caught by specification verifier per story |
| Security misconfigurations | Found in audit | Flagged by security verifier pre-commit |
| Style and consistency violations | Caught inconsistently | Caught deterministically by style verifier |
| Undocumented behavior | Discovered by future maintainers | Caught by documentation verifier |
| Schema contract violations | Found during integration testing | Caught by API contract verifier |

---

### Distinguishing Related Concepts

These terms are frequently conflated. Precision matters when designing a pipeline.

| Concept | Definition | Who performs it | Independent? |
|---|---|---|---|
| **Self-reflection** | The model examines its own reasoning for consistency | Same model, same context | No |
| **Self-correction** | The model revises its output after detecting an error | Same model, second pass | No |
| **Critique** | A model evaluates output against stated goals | Same or different model | Partially |
| **Verification** | Checking whether output satisfies a formal specification | Different agent or deterministic tool | Yes |
| **Validation** | Checking whether the system solves the right problem | Human or automated test | Yes |
| **Evaluation** | Measuring quality along defined dimensions | Separate judge model or metric | Yes |
| **Guardrails** | Constraints applied at inference time | Inline filter on the generative model | Partial |

**Why this matters:** Self-reflection and self-correction have documented reliability problems — the same model weights that produced an error are unlikely to reliably detect it without independent signal. Guardrails are complementary to VITL, not a substitute.

---

### Why Independent Verification Is More Reliable

**Context contamination.** When a model generates code, it also generates internal context — assumptions, reasoning steps, implicit decisions. When the same model reviews that code, that context is still active. Errors that were "obvious" in generation remain invisible in review because the model's attention is anchored to its own reasoning path.

**Adversarial independence.** A separate model with a different system prompt and no access to the generative model's chain-of-thought is better positioned to notice what the generative model took for granted.

**Specification grounding.** An independent verifier can be explicitly prompted to evaluate against the spec without the "baggage" of the implementation decisions. It reads the spec first and the code second.

[Inference — supported by published findings on LLM review quality, not a controlled claim for all models]: Models that review code they did not generate catch more issues than models reviewing their own output, particularly for logic errors and specification compliance.

---

### Tradeoffs

| Dimension | Cost |
|---|---|
| **Latency** | Each verification step adds one or more LLM round-trips. A 5-verifier pipeline may take 3–10× longer than single-agent. |
| **Monetary cost** | Additional LLM calls at full context size are expensive. A verification pass can cost as much as the generation pass. |
| **Complexity** | Orchestrating multiple agents, managing prompts, routing failures is real engineering work. |
| **False positive friction** | Verifiers that flag correct behavior waste engineer time and erode trust. |
| **Prompt maintenance** | Verifier prompts are specification-dependent. As specs evolve, prompts must be updated. |

These tradeoffs are manageable with the right architecture. Do not adopt VITL wholesale before establishing which verifiers provide the most value for your specific context.


---

## Part 2 — Architecture

### Architecture Overview

```mermaid
graph TD
    subgraph "Verification Architectures — from simple to sophisticated"
        A["1. Single Agent + Self-Review (no VITL)"]
        B["2. Planner → Coder → Verifier"]
        C["3. Multi-Specialist + Aggregator"]
        D["4. Reviewer Chains"]
        E["5. Judge Model"]
        F["6. Hybrid: Deterministic + LLM"]
        G["7. Human-in-the-Loop"]
        H["8. Human-on-the-Loop"]
    end
```

---

### Architecture 1: Single-Agent (Baseline — No VITL)

```mermaid
flowchart LR
    S[Spec] --> A[Coding Agent]
    A --> O[Output]
    A -.->|optional self-review| A
```

**Advantages:** Lowest latency, lowest cost, simplest to implement.

**Weaknesses:** No independent verification. Self-review is unreliable. Specification drift goes undetected. No audit trail.

**Appropriate use cases:** Throwaway scripts, prototypes, tasks where speed matters more than correctness.

> **Verdict:** The baseline to beat. Not recommended for production AI-assisted development.

---

### Architecture 2: Planner → Coder → Verifier

```mermaid
flowchart TD
    Spec[Specification] --> Planner
    Planner -->|Task plan + context| Coder
    Coder -->|Implementation| Verifier
    Verifier -->|PASS| Output[Accepted Output]
    Verifier -->|FAIL + feedback| Coder
    Coder -->|Revised implementation| Verifier
    Verifier -->|Max retries exceeded| Escalate[Human escalation]

    style Output fill:#9f9,stroke:#333
    style Escalate fill:#f99,stroke:#333
```

**How it works:** A Planner reads the spec and produces an annotated task plan. A Coder implements against the plan. A Verifier independently evaluates the implementation against the spec and either approves or returns structured feedback.

**Advantages:**
- Clear separation of concerns
- Verifier has no access to Coder's reasoning — genuine independence
- Revision loop is explicit and bounded
- Easy to log and audit

**Weaknesses:**
- Single verifier may have blind spots
- Revision loop can cycle if feedback is insufficiently specific
- Planner errors propagate to Coder before verification

**Appropriate use cases:** The default VITL architecture for most teams. Feature implementation against a well-defined spec.

**Configuration notes:**
- Set a maximum revision count (typically 2–3) before escalating to human
- Verifier feedback must be structured — see Part 7 for prompt templates
- Planner and Verifier can use the same model; Coder benefits from a code-specialized model

---

### Architecture 3: Planner → Multiple Specialists → Aggregator

```mermaid
flowchart TD
    Spec[Specification] --> Planner
    Planner -->|Task plan| Coder[Coding Agent]
    Coder --> Impl[Implementation]

    Impl --> SV[Spec Verifier]
    Impl --> SecV[Security Verifier]
    Impl --> TestV[Testing Verifier]
    Impl --> DocV[Documentation Verifier]

    SV --> Agg[Aggregator / Judge]
    SecV --> Agg
    TestV --> Agg
    DocV --> Agg

    Agg -->|All PASS| Output[Accepted Output]
    Agg -->|FAIL items| Coder
    Agg -->|Security FAIL| Security[Security Review Gate]

    style Output fill:#9f9,stroke:#333
    style Security fill:#f99,stroke:#333
```

**How it works:** Multiple specialist verifiers evaluate the output in parallel, each focused on a specific dimension. An Aggregator collects all verdicts and produces a single decision.

**Advantages:**
- Each verifier is specialized and tightly prompted
- Parallel execution reduces total latency vs. sequential chains
- Aggregator can apply priority rules (security FAIL always escalates)
- Fine-grained feedback per dimension

**Weaknesses:**
- Higher cost (multiple LLM calls per cycle)
- Aggregator logic becomes complex when verifiers conflict
- Maintaining N verifier prompts as specs evolve is non-trivial

**Appropriate use cases:** Production feature pipelines where multiple quality dimensions matter. Regulated industries requiring documented multi-dimensional review.

---

### Architecture 4: Reviewer Chains

```mermaid
flowchart LR
    Impl[Implementation] --> V1[Style Verifier]
    V1 -->|Annotated output| V2[Spec Verifier]
    V2 -->|Annotated output| V3[Security Verifier]
    V3 -->|Annotated output| V4[Test Verifier]
    V4 -->|Final verdict| Out{Decision}
    Out -->|PASS| Accept[Accept]
    Out -->|FAIL| Revise[Revise]

    style Accept fill:#9f9,stroke:#333
    style Revise fill:#f99,stroke:#333
```

**How it works:** Verifiers run sequentially. Each receives the implementation plus all prior verifier annotations, allowing later verifiers to build on earlier findings.

**Advantages:**
- Later verifiers have richer context (prior findings)
- Natural escalation: style issues caught early so security verifier focuses on security
- Simpler orchestration than parallel aggregation

**Weaknesses:**
- Sequential latency: total time is the sum of all verifier latencies
- Earlier errors propagate and may confuse later verifiers

**Appropriate use cases:** Workflows where verifier ordering has semantic value. Audit-intensive contexts where a running annotation trail is required.

---

### Architecture 5: Judge Model

```mermaid
flowchart TD
    Impl[Implementation] --> J[Judge Model]
    Spec[Specification] --> J
    Criteria[Acceptance Criteria] --> J
    RulesOut[Rule-Based Results] --> J

    J --> Score[Confidence Score + Verdict]
    Score -->|Score >= threshold| Accept[Accept]
    Score -->|Score < threshold| Reject[Reject + Structured Feedback]
    Score -->|Score in review band| Human[Human Review]

    style Accept fill:#9f9,stroke:#333
    style Human fill:#ff9,stroke:#333
    style Reject fill:#f99,stroke:#333
```

**How it works:** A Judge model receives all inputs — implementation, spec, acceptance criteria, and deterministic check outputs — and produces a single scored verdict with structured rationale.

**Advantages:**
- Single authoritative decision point
- Can weight inputs (failing unit test counts more than a style suggestion)
- Confidence scores enable routing to human review only when needed
- One structured output captures the full decision

**Weaknesses:**
- If judge shares architectural similarity with the coder, independence is reduced
- A single model making all decisions is a single point of failure
- Scoring calibration requires ongoing tuning

**Appropriate use cases:** High-volume pipelines where a single decision point reduces complexity. Systems that need quantitative quality scoring for metrics.

---

### Architecture 6: Hybrid Verifier Pipeline (Recommended for Production)

```mermaid
flowchart TD
    Impl[Implementation] --> D[Deterministic Layer]
    D --> Lint[Linter / Type checker]
    D --> Tests[Unit + Integration Tests]
    D --> Schema[Schema Validation]
    D --> Secrets[Secret Scanner]

    Lint -->|Results| Gate{All deterministic\nchecks pass?}
    Tests --> Gate
    Schema --> Gate
    Secrets --> Gate

    Gate -->|No| Block[Block — no LLM call]
    Gate -->|Yes| LLM[LLM Verifier Layer]

    LLM --> SV[Spec Verifier]
    LLM --> SecV[Security Verifier]
    LLM --> TestV[Test Coverage Verifier]

    SV --> J[Judge / Aggregator]
    SecV --> J
    TestV --> J

    J -->|PASS| Accept[Accept]
    J -->|FAIL| Feedback[Structured Feedback → Coder]
    J -->|ESCALATE| Human[Human Review]

    style Accept fill:#9f9,stroke:#333
    style Block fill:#f99,stroke:#333
    style Human fill:#ff9,stroke:#333
```

**How it works:** Deterministic checks run first. If they fail, the implementation is rejected immediately without incurring LLM verification cost. Only implementations that pass all deterministic checks proceed to the LLM verifier layer.

**Advantages:**
- Cost-efficient: LLM calls only for implementations that pass basic quality gates
- Deterministic checks are fast, cheap, and reliable
- LLM verifiers focus on higher-order concerns that deterministic tools cannot address
- Defense in depth: no single failure mode can approve a bad implementation

> **This is the recommended production architecture for most teams.** Adopt it as the default and simplify where needed.

---

### Architecture 7: Human-in-the-Loop

```mermaid
flowchart TD
    Impl[Implementation] --> Auto[Automated Verifiers]
    Auto -->|Issues found| Human[Human Reviewer]
    Auto -->|Clean pass| Human
    Human -->|Approve| Accept[Merge]
    Human -->|Request changes| Coder[Coding Agent revises]
    Coder --> Impl

    style Accept fill:#9f9,stroke:#333
```

**How it works:** Automated verifiers run, but a human always makes the final accept/reject decision. Automated results are presented as structured input, not binding decisions.

**Advantages:** Maximum correctness assurance. Human judgment applied where LLM reasoning is weakest. Often required for compliance.

**Weaknesses:** Does not scale. Human review is the bottleneck. Review fatigue reduces quality over time.

**Appropriate use cases:** Security-critical changes, financial calculation logic, regulated industries (healthcare, finance, critical infrastructure).

---

### Architecture 8: Human-on-the-Loop

```mermaid
flowchart TD
    Impl[Implementation] --> Auto[Automated Verifiers]
    Auto -->|PASS| Accept[Auto-merge]
    Auto -->|FAIL| Coder[Revise]
    Auto -->|ESCALATE| Notify[Notify Human]
    Notify -->|Human reviews async| Decision{Human decision}
    Decision -->|Approve| Accept
    Decision -->|Reject| Coder
    Coder --> Impl

    style Accept fill:#9f9,stroke:#333
```

**How it works:** The pipeline operates autonomously. Humans are notified and can intervene, but are not required for every decision. The escalation path routes to human review only when automated confidence falls below a threshold or a specific risk condition is triggered.

**Advantages:** Scales to high volume. Human attention focused on genuinely uncertain cases. Async review fits team workflows.

**Weaknesses:** Relies on accurate escalation thresholds. Requires robust monitoring and alerting. Teams must trust the automated verifiers.

**Appropriate use cases:** High-volume AI-generated code in mature pipelines with well-calibrated verifiers.

---

### Architecture Selection Guide

```mermaid
flowchart TD
    Q1{Is this a\nprototype?} -->|Yes| A1[Single Agent\nno VITL]
    Q1 -->|No| Q2{High regulatory\nor safety risk?}
    Q2 -->|Yes| A2[Human-in-the-Loop\n+ Hybrid Verifiers]
    Q2 -->|No| Q3{Large team or\nhigh volume?}
    Q3 -->|Yes| A3[Multi-Specialist\n+ Aggregator]
    Q3 -->|No| Q4{Solo or small team?}
    Q4 -->|Yes| A4[Planner → Coder\n→ Verifier]
    Q4 -->|No| A5[Human-on-the-Loop\n+ Hybrid Pipeline]
```


---

## Part 3 — Verifier Types

Each verifier is a discrete agent with a specific purpose, input set, output format, and set of failure conditions. They compose into the architectures described in Part 2.

### Notation

- **`[Essential]`** — Every VITL pipeline should include this verifier
- **`[Recommended]`** — Include unless you have a specific reason not to
- **`[Optional]`** — High value in specific contexts; overhead may not be justified everywhere
- **`[Experimental]`** — Promising but not yet widely validated in production

---

### 1. Specification Verifier `[Essential]`

**Purpose:** Verify that the implementation satisfies all functional requirements and acceptance criteria defined in the relevant spec documents.

**Inputs:**
- Relevant functional spec sections (FUNC-NNN)
- Acceptance criteria for the story being implemented
- The complete implementation (diff or full file set)

**Outputs:**
```json
{
  "verdict": "PASS | FAIL | PARTIAL",
  "requirements_checked": ["FR-001", "FR-002", "FR-003"],
  "failed_requirements": [
    {
      "id": "FR-002",
      "reason": "Character count for note field is not displayed",
      "spec_reference": "FUNC-001 §3.1.2",
      "severity": "HIGH"
    }
  ],
  "unimplemented_requirements": ["FR-003"],
  "out_of_spec_behaviors": ["Adds a 'clear' button not described in spec"],
  "confidence": 0.87
}
```

**Decision criteria:**
- PASS: All requirements satisfied, no out-of-spec behaviors
- PARTIAL: All high-severity requirements satisfied; low-severity gaps exist
- FAIL: Any high-severity requirement unmet, or significant out-of-spec behavior present

**Failure cases:**
- Verifier does not have the full relevant spec in context (context truncation)
- Spec uses ambiguous language the verifier interprets differently than the developer
- Verifier approves implementation that matches spec text but violates intent

**Integration:** Runs after every implementation cycle, before any other verifier. A FAIL here blocks all other verifiers.

**Example prompt:** See Part 7, Prompt 5.

---

### 2. Architecture Verifier `[Recommended]`

**Purpose:** Verify that the implementation follows the system architecture described in the technical spec and does not violate ADR decisions.

**Inputs:** Technical specification (TECH-NNN), all relevant ADRs, implementation, directory structure.

**Outputs:**
```json
{
  "verdict": "PASS | FAIL",
  "adr_violations": [
    {
      "adr_id": "ADR-002",
      "violation": "Uses cookie-based sessions instead of JWT as decided in ADR-002",
      "severity": "HIGH"
    }
  ],
  "layer_violations": ["Business logic placed in controller layer"],
  "dependency_direction_violations": [],
  "component_boundary_violations": []
}
```

**Decision criteria:** Any ADR violation is a FAIL. Layer violations are configurable — HIGH in strict architectures, WARN in pragmatic ones.

**Failure cases:** ADRs not included in context. Architecture patterns not explicitly described in spec.

**Integration:** Runs in parallel with or after the specification verifier.

---

### 3. Security Verifier `[Essential]`

**Purpose:** Identify common security vulnerabilities, insecure patterns, and violations of stated security requirements.

**Inputs:** Full relevant files (not just diff), security requirements from technical spec, authentication and authorization model.

**Outputs:**
```json
{
  "verdict": "PASS | FAIL | ESCALATE",
  "findings": [
    {
      "severity": "CRITICAL | HIGH | MEDIUM | LOW | INFO",
      "category": "Injection | Auth | XSS | IDOR | ...",
      "location": "src/api/users.ts:47",
      "description": "User input concatenated directly into SQL query",
      "recommendation": "Use parameterized queries via the ORM"
    }
  ],
  "escalate": false
}
```

**Decision criteria:**
- CRITICAL or HIGH findings → always FAIL → escalate to security review, not just Coder revision
- MEDIUM findings → FAIL with structured feedback for Coder
- LOW and INFO → included in report, do not block

**Failure cases:**
- LLM-based security verifiers miss novel or complex vulnerabilities not in their training
- Context truncation causes the verifier to miss relevant code paths
- False positives on safe patterns the verifier misreads as vulnerable

> **Important:** The security verifier is a first-pass filter, not a security audit. It catches common patterns. It does not replace a dedicated security review for high-risk changes.

**Integration:** Security FAIL with ESCALATE verdict bypasses the Coder revision loop and routes directly to human security review.

---

### 4. Testing Verifier `[Essential]`

**Purpose:** Verify that the implementation is accompanied by adequate tests that cover the acceptance criteria.

**Inputs:** Acceptance criteria for the story, test files, coverage report (if available), test spec (TEST-NNN).

**Outputs:**
```json
{
  "verdict": "PASS | FAIL",
  "criteria_coverage": {
    "AC-001": "COVERED",
    "AC-002": "COVERED",
    "AC-003": "NOT_COVERED",
    "AC-004": "PARTIALLY_COVERED"
  },
  "missing_test_cases": [
    "No test for duplicate email rejection (AC-004)",
    "Password validation only tests minimum length, not maximum"
  ],
  "test_quality_issues": [
    "TC-002 asserts on implementation detail rather than behavior"
  ]
}
```

**Decision criteria:** Every acceptance criterion must have at least one test. Tests must assert on observable behavior, not implementation details. No test file in the diff → always FAIL.

**Integration:** Runs after deterministic test execution (unit tests must pass before this verifier runs).

---

### 5. Documentation Verifier `[Recommended]`

**Purpose:** Verify that public interfaces, exported functions, APIs, and complex logic are documented appropriately.

**Inputs:** Implementation (all modified files), documentation standards, existing documentation.

**Outputs:**
```json
{
  "verdict": "PASS | FAIL | WARN",
  "undocumented_exports": ["UserService.createUser", "validateEmail"],
  "missing_api_docs": ["POST /api/v1/users response schema not documented"],
  "stale_documentation": ["README still describes v1 auth flow after v2 changes"],
  "quality_issues": ["JSDoc for createUser missing @throws annotation"]
}
```

**Failure cases:** Cannot evaluate documentation quality, only presence. Does not verify accuracy.

**Integration:** Runs in parallel with other verifiers; rarely blocks alone but counts toward Judge score.

---

### 6. Style Verifier `[Recommended]`

**Purpose:** Verify consistency with team coding standards that cannot be fully captured by automated linters.

**Inputs:** Implementation diff, style guide document, examples of approved code in the relevant module.

**Outputs:**
```json
{
  "verdict": "PASS | WARN",
  "style_issues": [
    {
      "location": "src/services/user.ts:23",
      "issue": "Async error handling uses .catch() instead of try/catch per team standard",
      "reference": "CONTRIBUTING.md §4.2"
    }
  ]
}
```

**Decision criteria:** Style verifier outputs WARN, not FAIL, in most pipelines. In strict pipelines (shared libraries, public APIs), style issues can be elevated to FAIL.

**Integration:** Run first in reviewer chains to clean up output before higher-stakes verifiers examine it.

---

### 7. Performance Verifier `[Optional]`

**Purpose:** Identify code patterns likely to cause performance problems: O(n²) loops, missing indexes, N+1 queries, unbounded memory growth.

**Inputs:** Full files, performance requirements from technical spec (latency targets, throughput requirements), database query patterns.

**Outputs:**
```json
{
  "verdict": "PASS | WARN | FAIL",
  "findings": [
    {
      "severity": "HIGH",
      "location": "src/services/dashboard.ts:112",
      "issue": "Query inside loop — potential N+1 on project list endpoint",
      "impact": "Dashboard load time grows linearly with project count",
      "recommendation": "Batch query outside the loop or use eager loading"
    }
  ]
}
```

**Failure cases:** Performance characteristics depend on runtime context the verifier cannot observe. Static analysis misses issues that only manifest under load.

**Integration:** Optional gate; FAIL on HIGH severity when performance requirements are explicitly specified in the technical spec.

---

### 8. Accessibility Verifier `[Recommended for UI features]`

**Purpose:** Verify that UI implementations meet WCAG accessibility requirements.

**Inputs:** UI component code, UX spec accessibility requirements, WCAG 2.1 AA baseline (embedded in prompt).

**Outputs:**
```json
{
  "verdict": "PASS | FAIL",
  "findings": [
    {
      "wcag_criterion": "1.1.1 Non-text Content",
      "location": "src/components/StatusForm.tsx:34",
      "issue": "Status color buttons have no aria-label",
      "fix": "Add aria-label='Green — On track' to each button"
    }
  ]
}
```

**Integration:** Runs on UI-touching changes only. Integrate with `axe-core` (deterministic) first; LLM verifier catches semantic and contextual issues `axe-core` misses.

---

### 9. API Contract Verifier `[Essential for services with APIs]`

**Purpose:** Verify that the implementation matches the OpenAPI specification exactly — request/response schemas, status codes, error formats.

**Inputs:** `specs/api/openapi.yaml`, implementation of the relevant endpoint, test cases that exercise the endpoint.

**Outputs:**
```json
{
  "verdict": "PASS | FAIL",
  "contract_violations": [
    {
      "endpoint": "POST /api/v1/users",
      "violation": "Implementation returns 200 on success; spec requires 201",
      "severity": "HIGH"
    },
    {
      "endpoint": "POST /api/v1/users",
      "violation": "Error response includes 'error' field; spec schema uses 'message'",
      "severity": "HIGH"
    }
  ]
}
```

**Integration:** Combine with `dredd` or `schemathesis` (deterministic tools) which test the running server against the OpenAPI spec. LLM verifier is the static check before the server runs.

---

### 10. Database Verifier `[Recommended for data-layer changes]`

**Purpose:** Verify that schema migrations, query patterns, and data model changes are consistent with the database specification.

**Inputs:** Database spec (DB-NNN), migration files, ORM model files or raw SQL, ERD text representation.

**Outputs:**
```json
{
  "verdict": "PASS | FAIL",
  "findings": [
    {
      "severity": "HIGH",
      "issue": "Migration adds 'user_notes' column without index; spec requires index for dashboard query",
      "reference": "DB-001 §4.3"
    },
    {
      "severity": "MEDIUM",
      "issue": "Migration is not reversible — no down() function",
      "reference": "DB-001 §5.1"
    }
  ]
}
```

---

### 11. Dependency Verifier `[Recommended]`

**Purpose:** Verify that new dependencies are appropriate, licensed correctly, not known-vulnerable, and consistent with ADR technology decisions.

**Inputs:** Package diff, ADRs that specify approved technology, license policy.

**Outputs:**
```json
{
  "verdict": "PASS | WARN | FAIL",
  "new_dependencies": ["lodash@4.17.21", "moment@2.29.4"],
  "findings": [
    {
      "package": "moment",
      "issue": "Moment.js is deprecated; ADR-005 specifies date-fns as the approved date library",
      "severity": "HIGH"
    }
  ]
}
```

**Integration:** Combine with `npm audit`, `pip-audit`, `license-checker` (deterministic) for known-vulnerability and license checks. LLM verifier evaluates appropriateness and ADR compliance.

---

### 12. Acceptance Criteria Verifier `[Essential]`

**Purpose:** A tighter, more literal version of the specification verifier focused specifically on whether each stated acceptance criterion has a verifiable mapping to implementation behavior.

**Inputs:** Story acceptance criteria (Given/When/Then format), implementation, tests.

**Outputs:**
```json
{
  "verdict": "PASS | FAIL",
  "criteria": [
    {"id": "AC-001", "status": "SATISFIED", "evidence": "SignupForm.tsx renders correctly; test TC-001 covers happy path"},
    {"id": "AC-002", "status": "SATISFIED", "evidence": "Email validation in useSignupForm.ts:34; test TC-002 covers"},
    {"id": "AC-003", "status": "NOT_SATISFIED", "evidence": "Password validation exists but no test for AC-003 scenario"},
    {"id": "AC-004", "status": "PARTIALLY_SATISFIED", "evidence": "API handles 409 but UI shows generic error, not specific message per AC-004"}
  ]
}
```

---

### 13. Regression Verifier `[Recommended]`

**Purpose:** Identify changes that may break existing behavior not covered by the current story's tests.

**Inputs:** Implementation diff, list of existing tests touching the same files or modules, dependency graph of modified functions.

**Outputs:**
```json
{
  "verdict": "PASS | WARN | FAIL",
  "potentially_affected_tests": ["auth.test.ts", "user-service.integration.test.ts"],
  "risky_changes": [
    {
      "change": "Modified validateEmail utility",
      "callers": ["signup flow", "invite flow", "admin user creation"],
      "risk": "Change may affect all three flows; only signup flow tested in this story"
    }
  ]
}
```

---

### 14. Risk Verifier `[Optional]`

**Purpose:** Assess the risk profile of the change — blast radius, reversibility, downstream impact.

**Inputs:** Implementation diff, list of dependent services (from technical spec), deployment model.

**Outputs:**
```json
{
  "risk_level": "LOW | MEDIUM | HIGH | CRITICAL",
  "blast_radius": "Affects user creation flow — all new registrations",
  "reversibility": "REVERSIBLE — no schema changes",
  "rollout_recommendation": "Feature flag recommended before full release",
  "monitoring_recommendations": ["Alert on 5xx rate for POST /api/v1/users post-deploy"]
}
```

**Integration:** Used by the Judge to determine deployment gate and rollout strategy.

---

### 15. Compliance Verifier `[Optional — required in regulated industries]`

**Purpose:** Verify that the implementation does not violate specific regulatory requirements (GDPR, HIPAA, PCI-DSS, SOC2, etc.).

**Inputs:** Implementation, compliance requirements section of technical spec, specific regulatory checklist (embedded in prompt).

**Outputs:**
```json
{
  "verdict": "PASS | FAIL | ESCALATE",
  "framework": "GDPR",
  "findings": [
    {
      "severity": "HIGH",
      "article": "GDPR Article 17",
      "issue": "User deletion endpoint removes auth record but does not delete user-generated content",
      "recommendation": "Implement cascading delete or anonymization for all user content tables"
    }
  ]
}
```

> **Note:** Compliance verifiers should be reviewed by qualified compliance personnel regularly. LLM-based compliance checking is a first-pass filter, not a substitute for legal or regulatory review.

---

### 16. Prompt Verifier `[Experimental]`

**Purpose:** When AI-generated prompts are part of the product (e.g., RAG systems, AI features), verify that prompts are correctly specified, injection-resistant, and match intended behavior.

**Inputs:** Prompt under review, expected behavior description, known adversarial inputs.

**Outputs:**
```json
{
  "verdict": "PASS | FAIL",
  "findings": [
    {
      "severity": "HIGH",
      "issue": "System prompt does not prevent role-play override attacks",
      "evidence": "No instruction to ignore attempts to change the AI persona"
    }
  ]
}
```

---

### 17. Reasoning Verifier `[Experimental]`

**Purpose:** For planning or multi-step agent outputs, verify that the reasoning chain is internally consistent and reaches a correct conclusion.

**Inputs:** Reasoning chain (chain-of-thought output), problem specification, expected reasoning properties.

**Outputs:**
```json
{
  "verdict": "PASS | FAIL",
  "reasoning_errors": [
    "Step 3 concludes X but Step 4 assumes not-X without resolving the contradiction",
    "Final recommendation contradicts constraint stated in Step 1"
  ]
}
```

[Inference — reasoning verification is an active research area; reliability varies significantly by domain and model]


---

## Part 4 — Complete Developer Workflow

### The Full Pipeline

```mermaid
flowchart TD
    I[💡 Idea] --> S[Specification\nPRD + FUNC + TECH]
    S --> T[Task Decomposition\nEpics → Stories → Tasks]
    T --> P[Planning\nPlanner Agent]
    P --> C[Implementation\nCoding Agent]
    C --> DL[Deterministic Layer\nLint + Tests + Schema]
    DL -->|Fail| C
    DL -->|Pass| VL[Verifier Layer\nSpec + Security + Tests + Docs]
    VL -->|Fail items| C
    VL -->|All Pass| J[Judge / Aggregator]
    J -->|PASS| CR[Code Review\nHuman or automated]
    J -->|FAIL| C
    J -->|ESCALATE| HR[Human Review]
    CR -->|Approved| M[Merge]
    HR --> M
    M --> D[Deployment]
    D --> Mon[Monitoring\nPRD KPIs]
    Mon -->|Issues| I2[New Idea / Bug Report]
    I2 --> S

    style I fill:#f9f,stroke:#333
    style M fill:#9f9,stroke:#333
    style D fill:#99f,stroke:#333
```

---

### Stage 1: Idea → Specification

**Input:** Idea brief  
**Output:** PRD, FUNC spec, TECH spec, ADRs, openapi.yaml

The specification is the contract. Everything downstream depends on its accuracy. No VITL pipeline compensates for a missing or vague spec.

---

### Stage 2: Specification → Task Decomposition

**Input:** FUNC spec + acceptance criteria  
**Output:** Epic → Feature → Story → Task hierarchy with spec references

**AI assistance:** Feed the FUNC spec to a Planner agent and ask it to decompose into stories following your template. Verify the decomposition against the spec before implementation begins.

```
Planner decomposition prompt:
"Read FUNC-NNN. Decompose it into stories following the template
in tasks/stories/TEMPLATE.md. Each story must reference the
functional requirement(s) it implements. Each story must have
at least one acceptance criterion derived directly from the spec."
```

---

### Stage 3: Task Decomposition → Planning

**Input:** Story document  
**Output:** Implementation plan (files to create/modify, approach, dependencies)

The Planner agent produces an annotated task plan — not code, but a description of what code will be written. This is reviewed before implementation begins to catch planning errors cheaply.

**Planner output format:**

```markdown
## Implementation Plan: STORY-003

### Files to create
- `src/services/user.service.ts` — UserService class
- `src/services/user.service.test.ts` — Unit tests

### Files to modify
- `src/api/routes/users.ts` — Wire POST /api/v1/users to UserService

### Approach
1. Create UserService.createUser(dto) method
2. Validate email format using validator.js (per ADR-007 — approved library)
3. Check for duplicate email — return 409 if exists
4. Hash password with bcrypt (12 rounds per TECH-001 §4.2)
5. Insert user record
6. Return 201 with User schema

### Dependencies
- Requires database migration from DB-001 (STORY-002) to be merged first

### Spec gaps identified
[none]

### Risk
- Duplicate email check requires a DB read before insert — race condition
  possible under concurrent load. Will add unique constraint at DB level per
  DB-001 §3.1 as the authoritative guard.
```

---

### Stage 4: Planning → Implementation

**Input:** Implementation plan + all relevant spec sections  
**Output:** Code diff

The Coding agent receives: the story document, the implementation plan, relevant spec sections (not the full spec), and explicit instructions not to exceed the spec.

**Critical context to always include:**
1. Story acceptance criteria
2. Relevant FUNC spec sections (FR numbers that apply to this story)
3. Relevant openapi.yaml paths (if building an endpoint)
4. Relevant ADRs (if making technology decisions)
5. Examples of existing approved code in the same module

---

### Stage 5: Implementation → Deterministic Layer

**Input:** Implementation diff  
**Output:** Pass/fail per check + structured results

Runs automatically. No human or LLM involvement. Checks:
- Linter (ESLint, Ruff, golangci-lint, etc.)
- Type checker (tsc, mypy, etc.)
- Unit tests
- Integration tests (if fast enough for pre-merge)
- Schema validation
- Secret scanner

If any check fails → return to Coder with the exact error output. Do not invoke LLM verifiers.

---

### Stage 6: Deterministic Layer → Verifier Layer

**Input:** Implementation diff + deterministic check results  
**Output:** Structured verdicts per verifier

Verifiers run in parallel (or sequenced by priority). Each produces a structured JSON verdict. Verifiers do not communicate with each other during evaluation — independence is the point.

**Information routing:**
- Spec Verifier receives: story + spec + implementation
- Security Verifier receives: implementation + security requirements
- Testing Verifier receives: acceptance criteria + tests + coverage report
- API Contract Verifier receives: openapi.yaml + implementation

---

### Stage 7: Verifier Layer → Judge

**Input:** All verifier verdicts + deterministic check results  
**Output:** Single decision (PASS / FAIL / ESCALATE) + structured report

The Judge applies priority rules:
- Security CRITICAL/HIGH → always ESCALATE
- Spec verifier FAIL → always FAIL (no other verifier can override)
- Testing verifier FAIL → FAIL unless in documentation-only PR
- WARN-level findings → accumulate into report, do not block

**Judge decision logic (pseudocode):**

```python
def judge(verdicts, deterministic_results):
    if any_security_critical_or_high(verdicts):
        return ESCALATE, "Security finding requires human review"

    if spec_verifier_failed(verdicts):
        return FAIL, spec_verifier_feedback(verdicts)

    if deterministic_results.has_failures():
        return FAIL, deterministic_results.failures()

    if testing_verifier_failed(verdicts) and not is_docs_only_pr():
        return FAIL, testing_verifier_feedback(verdicts)

    confidence = aggregate_confidence(verdicts)
    if confidence < HUMAN_REVIEW_THRESHOLD:
        return ESCALATE, "Low confidence — human review recommended"

    return PASS, aggregate_report(verdicts)
```

---

### Stage 8: Judge → Revision Loop

When Judge returns FAIL:
1. Structured feedback is bundled into a revision prompt
2. Coder agent receives: original implementation + all FAIL reasons + spec reference for each failure
3. Coder revises only the failed areas (not a full rewrite)
4. Full verification cycle repeats
5. Maximum revision count: configurable (default: 3)
6. After max revisions: escalate to human with full history

**Revision prompt pattern:**

```
The following implementation failed verification.

FAILED REQUIREMENTS:
[structured list from verifier outputs — FR id, spec reference, specific issue, specific fix]

ORIGINAL IMPLEMENTATION:
[implementation]

Fix only the listed failures. Do not change anything not listed.
For each fix, reference the spec requirement it addresses.
```

---

### Stage 9: Code Review → Merge

After Judge PASS, the structured verification report is attached to the PR. Human reviewers see:
- Which verifiers ran
- What each found
- The Judge's decision and confidence score
- Any warnings (non-blocking findings)

Reviewers focus their attention on what automated verification cannot do: business logic correctness, architectural intent, team knowledge sharing.

---

### Stage 10: Deployment → Monitoring

Post-merge, the pipeline:
1. Runs full test suite in CI
2. Builds and deploys per deployment runbook
3. Executes smoke tests post-deploy
4. Begins monitoring PRD KPIs defined in the specification

Monitoring closes the loop: PRD success metrics are now being measured, and deviations trigger new idea briefs that re-enter the pipeline.

---

### Information Flow Diagram

```mermaid
flowchart LR
    subgraph "Inputs to Coder"
        Story[Story doc]
        Plan[Impl plan]
        SpecSections[Spec sections]
        Examples[Code examples]
    end

    subgraph "Inputs to Verifiers"
        Impl[Implementation]
        FullSpec[Full relevant spec]
        AC[Acceptance criteria]
        Tests[Test files]
        OAS[openapi.yaml]
        DetResults[Deterministic results]
    end

    subgraph "Inputs to Judge"
        V1out[Spec verifier out]
        V2out[Security verifier out]
        V3out[Test verifier out]
        DetOut[Deterministic results]
    end

    Story --> Coder
    Plan --> Coder
    SpecSections --> Coder
    Examples --> Coder
    Coder --> Impl

    Impl --> SpecVerifier
    FullSpec --> SpecVerifier
    AC --> SpecVerifier

    Impl --> SecVerifier
    Impl --> TestVerifier
    Tests --> TestVerifier
    AC --> TestVerifier
    Impl --> APIVerifier
    OAS --> APIVerifier
    DetResults --> Judge

    SpecVerifier --> V1out
    SecVerifier --> V2out
    TestVerifier --> V3out

    V1out --> Judge
    V2out --> Judge
    V3out --> Judge
    DetOut --> Judge

    Judge --> Decision[PASS / FAIL / ESCALATE]
```


---

## Part 5 — Building the Workflow

### Claude Code

**Capabilities:**
- Runs in a terminal with persistent context across a session
- Can read files, run shell commands, execute tests, and call external tools
- Supports custom system prompts and project-level configuration via `CLAUDE.md`
- MCP (Model Context Protocol) enables integration with external tools

**Recommended `CLAUDE.md`:**

```markdown
# CLAUDE.md (project root)

## Workflow rules

You are a coding agent in a spec-first, verifier-in-the-loop workflow.

### Before writing any code
1. Read the story document specified in the task
2. Read all spec sections referenced in the story
3. Confirm your understanding of the acceptance criteria
4. If any spec section is ambiguous, ask before proceeding

### While writing code
- Implement only what is described in the spec
- Use only libraries approved in ADRs
- Follow the patterns in existing approved code in this repository

### After writing code
- Run `npm run lint` and fix all errors before considering the task complete
- Run `npm test` and fix all failures before considering the task complete
- Do not submit code that fails lint or tests

### You must not
- Add features not described in the spec
- Modify spec documents unless explicitly asked
- Merge changes — submit only for review

## Verifier integration
After implementation, run: `./scripts/verify.sh <story-id>`
This runs all deterministic checks and submits the result for LLM verification.
```

**Automation opportunities:**
- Use Claude Code's file-reading to auto-load spec context at session start
- Use `--print` flag for non-interactive pipeline invocations
- Integrate with `verify.sh` scripts via shell commands within the session

**Limitations:**
- Context window limits require careful spec section selection
- No native multi-agent coordination (requires external orchestration)

---

### Cursor

**Capabilities:**
- IDE-integrated AI with file-aware context
- `.cursorrules` file for project-level AI instructions
- Cursor Composer for multi-file edits

**Recommended `.cursorrules`:**

```
You are a coding agent working in a spec-first, VITL development workflow.

## Context loading
Before every implementation task, the user will provide:
- A story ID (e.g., STORY-003)
- The spec sections relevant to that story

Load the story from tasks/stories/ and read the referenced spec sections.

## Implementation rules
- Implement only what the spec describes
- If you identify a behavior not in the spec, ask before adding it
- Reference FR numbers from the functional spec in your code comments

## Rejection criteria
Refuse to implement the following without a spec amendment:
- New API endpoints not in openapi.yaml
- New database fields not in the DB spec
- New UI states not in the UX spec

## After implementation
Remind the user to run: npm run verify:story <story-id>
```

**Limitations:**
- Cursor cannot run multi-agent pipelines natively
- `.cursorrules` context competes with file context in long sessions

---

### ChatGPT / OpenAI API

**Capabilities:**
- API access enables programmatic integration into custom pipelines
- `response_format: {"type": "json_object"}` enforces structured verifier output
- Function calling enables typed structured output from verifiers

**Recommended API verifier call pattern:**

```python
import openai
import json

def run_spec_verifier(spec_content: str, implementation: str, story: str) -> dict:
    response = openai.chat.completions.create(
        model="gpt-4o",
        response_format={"type": "json_object"},
        messages=[
            {
                "role": "system",
                "content": open(".ai/prompts/verifiers/spec-verifier/system.md").read()
            },
            {
                "role": "user",
                "content": f"""
STORY: {story}

SPECIFICATION:
{spec_content}

IMPLEMENTATION:
{implementation}

Evaluate and return JSON per your output schema.
"""
            }
        ]
    )
    return json.loads(response.choices[0].message.content)
```

**Limitations:** Rate limits constrain high-volume parallel verification. No persistent session memory between API calls.

---

### Gemini CLI / Gemini API

**Capabilities:**
- Very large context window (1M+ tokens) — useful for loading entire spec directories
- `gemini` CLI supports piping and scripting
- Suitable for full-repo verification passes

**Recommended use:** Due to the large context window, Gemini is well-suited for the **Judge role** — receiving all verifier outputs plus the full spec and making a final decision with full context.

```bash
# Pipe all verifier outputs to Gemini Judge
cat .ai/verifier_outputs/*.json | gemini \
  --system-prompt .ai/prompts/verifiers/judge/system.md \
  --output json \
  > reports/judge_decision.json
```

**Limitations:** CLI is less mature than the API. Structured output reliability varies across model versions.

---

### Codex CLI

**Capabilities:**
- Terminal-based coding agent from OpenAI
- Reads repository context automatically
- Supports `--approval-mode` for staged human review

**VITL integration:**

```bash
# Run codex with spec context and approval gate before applying changes
codex \
  --approval-mode suggest \
  "Implement STORY-003. Spec reference: specs/functional/FUNC-001.md §3.1.
   Accept only if: lint passes, tests pass, no features beyond the spec."
```

**Limitations:** Less configurable system prompt than API-level integrations. Approval mode requires human in the loop per change.

---

### Aider

**Capabilities:**
- Git-aware coding assistant; automatically creates commits
- `--read` flag loads spec files as read-only context
- Supports model selection (Claude, GPT-4, Gemini)

**VITL integration:**

```bash
# Load spec files as read-only context, implement the story
aider \
  --read specs/functional/FUNC-001-user-auth.md \
  --read specs/api/openapi.yaml \
  --read tasks/stories/STORY-003.md \
  --model claude-sonnet-4-6 \
  src/services/user.service.ts \
  src/services/user.service.test.ts
```

**Limitations:** Auto-commit behavior can conflict with PR-based spec amendment workflow. No native verifier pipeline; requires external scripts.

---

### Open-Source Agent Frameworks

| Framework | Strengths | Use Case in VITL |
|---|---|---|
| **LangGraph** | Explicit state machines, cycles, conditional routing | Orchestrating the Planner → Coder → Verifier loop with retry logic |
| **CrewAI** | Role-based multi-agent teams, sequential/parallel tasks | Multi-specialist verifier architectures |
| **AutoGen** | Conversational multi-agent with human-in-the-loop | Review chains and human escalation paths |
| **Pydantic AI** | Type-safe structured outputs, Python-native | Verifier agents that must return validated JSON |
| **Instructor** | Structured output enforcement on any LLM | Ensuring verifier output schema compliance |

**LangGraph verifier loop example:**

```python
from langgraph.graph import StateGraph, END
from typing import TypedDict, Literal

class PipelineState(TypedDict):
    story: str
    spec: str
    implementation: str
    verifier_results: dict
    revision_count: int
    judge_decision: str

def coder_node(state: PipelineState) -> PipelineState:
    # Call coding agent, return updated state with implementation
    ...

def verifier_node(state: PipelineState) -> PipelineState:
    # Call all verifiers in parallel, store results
    ...

def judge_node(state: PipelineState) -> PipelineState:
    # Aggregate and produce judge_decision
    ...

def route_after_judge(state: PipelineState) -> Literal["coder", "human", "__end__"]:
    if state["judge_decision"] == "PASS":
        return END
    if state["judge_decision"] == "ESCALATE":
        return "human"
    if state["revision_count"] >= 3:
        return "human"
    return "coder"

graph = StateGraph(PipelineState)
graph.add_node("coder", coder_node)
graph.add_node("verifier", verifier_node)
graph.add_node("judge", judge_node)
graph.set_entry_point("coder")
graph.add_edge("coder", "verifier")
graph.add_edge("verifier", "judge")
graph.add_conditional_edges("judge", route_after_judge)

pipeline = graph.compile()
```

---

### Custom Scripts

For teams not ready for a full agent framework, a script-based pipeline is a practical starting point:

```bash
#!/bin/bash
# scripts/verify.sh — Main verification runner
# Usage: ./scripts/verify.sh <story-id>

STORY_ID=$1
STORY_FILE="tasks/stories/${STORY_ID}.md"

if [ ! -f "$STORY_FILE" ]; then
  echo "Story file not found: $STORY_FILE"; exit 1
fi

echo "=== Layer 1: Deterministic checks ==="
npm run lint || { echo "Lint failed"; exit 1; }
npm run typecheck || { echo "Type check failed"; exit 1; }
npm test || { echo "Tests failed"; exit 1; }

echo "=== Layer 2: LLM verifiers ==="
python .ai/scripts/run-verifiers.py --story "$STORY_ID" \
  --output reports/verifier-output.json

echo "=== Layer 3: Judge ==="
python .ai/scripts/judge.py \
  --verifier-output reports/verifier-output.json \
  --output reports/judge-decision.json

echo "=== Generating report ==="
python .ai/scripts/generate-report.py \
  --judge-output reports/judge-decision.json \
  --output "reports/${STORY_ID}-$(date +%Y%m%d-%H%M%S).md"

DECISION=$(python -c "import json; print(json.load(open('reports/judge-decision.json'))['decision'])")
echo "=== Decision: $DECISION ==="
[ "$DECISION" = "PASS" ] && exit 0 || exit 1
```

---

### Git Hooks

**`pre-commit` hook (deterministic checks only — fast):**

```bash
#!/bin/bash
# .git/hooks/pre-commit (or via pre-commit framework)
set -e

npm run lint || { echo "Lint failed"; exit 1; }
git-secrets --scan || { echo "Secret detected"; exit 1; }

echo "Pre-commit checks passed."
```

**`pre-push` hook (run tests):**

```bash
#!/bin/bash
# .git/hooks/pre-push
set -e
npm test || { echo "Tests failed — push blocked"; exit 1; }
```

> **Do not run LLM verifiers in git hooks.** The latency (5–30s per call) makes hooks unusable. Git hooks are for fast deterministic checks only.

---

### Tool Capability Summary

| Tool | Spec grounding | Multi-agent | Structured output | CI integration | Cost control |
|---|---|---|---|---|---|
| Claude Code | ✅ via CLAUDE.md | ❌ native | Partial | Via scripts | Manual |
| Cursor | ✅ via .cursorrules | ❌ | Partial | Via scripts | Manual |
| ChatGPT API | ✅ via prompt | ✅ with orchestration | ✅ JSON mode | ✅ | Per-call |
| Claude API | ✅ via prompt | ✅ with orchestration | ✅ JSON mode | ✅ | Per-call |
| Gemini API | ✅ via prompt | ✅ with orchestration | ✅ | ✅ | Per-call |
| Aider | ✅ via --read | ❌ | ❌ | Partial | Manual |
| LangGraph | ✅ via state | ✅ native | ✅ | ✅ | Programmatic |
| Custom scripts | ✅ | ✅ | ✅ | ✅ | Full control |


---

## Part 6 — Repository Structure

```
my-project/
│
├── .ai/                                  # All AI workflow configuration
│   ├── README.md                         # How this directory works
│   │
│   ├── agents/                           # Agent configuration files
│   │   ├── planner.yaml
│   │   ├── coder.yaml
│   │   ├── spec-verifier.yaml
│   │   ├── security-verifier.yaml
│   │   ├── test-verifier.yaml
│   │   ├── doc-verifier.yaml
│   │   ├── api-contract-verifier.yaml
│   │   ├── architecture-verifier.yaml
│   │   └── judge.yaml
│   │
│   ├── prompts/                          # Versioned prompt library
│   │   ├── README.md                     # Prompt index and usage guide
│   │   ├── planner/
│   │   │   ├── system.md
│   │   │   └── CHANGELOG.md
│   │   ├── coder/
│   │   │   ├── system.md
│   │   │   └── CHANGELOG.md
│   │   └── verifiers/
│   │       ├── spec-verifier/
│   │       │   ├── system.md
│   │       │   ├── output-schema.json
│   │       │   └── CHANGELOG.md
│   │       ├── security-verifier/
│   │       │   ├── system.md
│   │       │   ├── output-schema.json
│   │       │   └── CHANGELOG.md
│   │       ├── test-verifier/
│   │       ├── doc-verifier/
│   │       ├── api-contract-verifier/
│   │       ├── architecture-verifier/
│   │       └── judge/
│   │           ├── system.md
│   │           ├── output-schema.json
│   │           └── CHANGELOG.md
│   │
│   ├── rules/                            # Deterministic verification rules
│   │   ├── .spectral.yaml               # OpenAPI linting rules
│   │   ├── semgrep/                      # Security pattern rules
│   │   │   ├── security.yaml
│   │   │   └── custom-patterns.yaml
│   │   └── license-checker.json
│   │
│   ├── templates/                        # Output templates
│   │   ├── implementation-plan.md
│   │   ├── verifier-report.md
│   │   ├── judge-decision.md
│   │   └── revision-prompt.md
│   │
│   ├── scripts/                          # Pipeline automation
│   │   ├── run-verifiers.py              # Parallel verifier orchestration
│   │   ├── judge.py                      # Judge aggregation
│   │   ├── generate-report.py            # Human-readable report generator
│   │   ├── check-spec-freshness.py       # Detect stale specs
│   │   └── full-spec-audit.py            # Nightly codebase audit
│   │
│   └── config/
│       ├── pipeline.yaml                 # Master pipeline configuration
│       ├── thresholds.yaml               # Judge scoring thresholds
│       └── escalation-rules.yaml         # When to escalate to human
│
├── specs/                                # Specification documents
│   ├── product/
│   ├── functional/
│   ├── technical/
│   ├── api/
│   │   └── openapi.yaml
│   ├── database/
│   ├── ui/
│   ├── adr/
│   └── test/
│
├── tasks/
│   ├── epics/
│   ├── features/
│   └── stories/
│
├── evaluations/                          # Verifier quality tracking
│   ├── README.md
│   ├── test-cases/
│   │   ├── spec-verifier/
│   │   │   ├── should-pass/              # Known-good implementations
│   │   │   └── should-fail/              # Known-bad implementations
│   │   └── security-verifier/
│   │       ├── should-pass/
│   │       └── should-fail/
│   └── results/                          # Historical evaluation run results
│
├── reports/                              # Generated verification reports (gitignored)
│   └── .gitignore
│
├── logs/                                 # Pipeline execution logs (gitignored)
│   └── .gitignore
│
├── src/
├── tests/
├── .github/
│   ├── workflows/
│   │   ├── verifier-pipeline.yml
│   │   ├── nightly-verification.yml
│   │   └── post-deploy-validation.yml
│   └── PULL_REQUEST_TEMPLATE.md
│
└── CLAUDE.md                             # Project-level AI agent instructions
```

---

### Directory Reference

**`.ai/agents/`** — YAML configuration files for each agent role. Enables swapping models without editing code.

```yaml
# .ai/agents/spec-verifier.yaml
name: spec-verifier
version: "1.3.0"
description: "Verifies implementation against functional spec and acceptance criteria"
model: claude-sonnet-4-6
temperature: 0.1
max_tokens: 2000
timeout_seconds: 60
prompt_file: .ai/prompts/verifiers/spec-verifier/system.md
output_schema_file: .ai/prompts/verifiers/spec-verifier/output-schema.json
required_inputs: [story, functional_spec_sections, implementation]
optional_inputs: [existing_tests]
blocking: true
escalate_on: []
fail_on_verdict: ["FAIL"]
warn_on_verdict: ["PARTIAL"]
condition: null
```

**`.ai/prompts/`** — All prompts are versioned files, not inline strings. Each directory has a `CHANGELOG.md` tracking what changed and why. Prompt changes go through the same PR review process as code changes.

**`.ai/rules/`** — Deterministic rule configurations. These are the authoritative rulesets used by CI. Not duplicated elsewhere.

**`.ai/config/pipeline.yaml`** — Master pipeline configuration:

```yaml
# .ai/config/pipeline.yaml
pipeline:
  max_revision_cycles: 3
  parallel_verifiers: true

  verifiers:
    - id: spec-verifier
      required: true
      blocks_on_fail: true
    - id: security-verifier
      required: true
      blocks_on_fail: true
      escalate_on: [CRITICAL, HIGH]
    - id: test-verifier
      required: true
      blocks_on_fail: true
    - id: doc-verifier
      required: false
      blocks_on_fail: false
    - id: api-contract-verifier
      required: true
      condition: "files_changed_match: specs/api/ OR src/api/"
      blocks_on_fail: true

judge:
  confidence_threshold_for_auto_pass: 0.85
  confidence_threshold_for_human_review: 0.70
```

**`evaluations/`** — The verifiers themselves are tested. This directory holds known-good (should PASS) and known-bad (should FAIL) examples for each verifier. Run regularly to detect verifier regression as prompts evolve.

**`CLAUDE.md`** — Project-level instructions consumed by Claude Code, Cursor, and other agents that read project context files. Defines workflow rules, banned behaviors, and integration commands.

**`.github/PULL_REQUEST_TEMPLATE.md`:**

```markdown
## Story

Story ID: STORY-
Spec references: FUNC-NNN §x.x

## Changes

[Description of what was implemented]

## Verification

- [ ] `./scripts/verify.sh STORY-NNN` ran and passed
- [ ] Verification report attached below or linked
- [ ] No features added beyond the spec
- [ ] Spec was amended (if behavior changed) — amendment PR: #

## Verification Report

[Paste judge decision summary here]

## Checklist

- [ ] Lint passes
- [ ] Type check passes
- [ ] All tests pass
- [ ] Coverage meets threshold
- [ ] No secrets in diff
- [ ] Migration is reversible (if applicable)
```


---

## Part 7 — Prompt Engineering

### Design Principles for Verifier Prompts

1. **Be explicit about independence.** Tell the verifier it has no access to the coder's reasoning and must evaluate only what it can observe.
2. **Anchor to the spec, not to general principles.** "Does this satisfy FR-003?" not "Is this good code?"
3. **Require structured output.** Every verifier produces JSON. Prose-only outputs are not parseable by the pipeline.
4. **Define failure conditions explicitly.** Ambiguous pass/fail criteria produce inconsistent verdicts.
5. **Include examples.** A few-shot example in the prompt dramatically improves structured output reliability.
6. **Version every prompt.** Prompt changes can change verifier behavior; treat them as code.
7. **Include a quoting requirement.** Ask verifiers to quote the specific code that produced a finding — this catches hallucinated rationales.

---

### Prompt 1: Planner

```markdown
# .ai/prompts/planner/system.md

You are a planning agent in a spec-first software development workflow.
Your role is to read a story document and produce an annotated
implementation plan that a coding agent will follow.

## Your responsibilities
- Read the story and identify all referenced spec documents
- Produce a concrete, sequenced implementation plan
- Identify files to create, files to modify, and the approach for each
- Flag any dependencies that must be resolved before this story can be implemented
- Identify any spec gaps or ambiguities that need clarification before coding begins

## You must not
- Write any code
- Make assumptions about unspecified behavior
- Suggest features beyond the story scope

## Output format
Return a Markdown document with these sections:

### Files to create
[list with rationale]

### Files to modify
[list with rationale]

### Approach
[numbered sequence of implementation steps]

### Dependencies
[list of prerequisite stories or migrations]

### Spec gaps identified
[list any ambiguities found — write "none" if none]

### Risk assessment
[complexity, blast radius, reversibility — one paragraph]
```

---

### Prompt 2: Coder

```markdown
# .ai/prompts/coder/system.md

You are a coding agent in a spec-first development workflow.
You receive a story, an implementation plan, and relevant spec sections.
You implement exactly what the spec describes — nothing more.

## Rules
1. Implement only what is described in the provided spec sections
2. Use only libraries that appear in the codebase or are approved in ADRs
3. Follow the patterns established in existing code in the same module
4. Every new public function must have a documentation comment
5. Every new file must have associated test coverage
6. If you encounter a spec gap, output a GAP_FOUND marker and stop

## Gap format
```
GAP_FOUND: [description of the ambiguity]
SPEC_REFERENCE: [section where the gap exists]
QUESTION: [specific question that needs answering before you can proceed]
```

## What you must never do
- Add functionality not described in the spec
- Modify spec documents
- Silence errors or add TODO comments for issues you cannot resolve
- Write tests that mock so aggressively they test nothing real

## Revision mode
If you are revising a previous implementation, you will receive structured
feedback from the verification layer. Address only the listed failures.
Do not change anything not mentioned in the feedback.
State which failure each change addresses, referencing the FR or AC id.
```

---

### Prompt 3: Architecture Verifier

```markdown
# .ai/prompts/verifiers/architecture-verifier/system.md

You are an independent architecture reviewer.
You have no access to the implementation author's reasoning.
You evaluate only what you can observe: the implementation, the technical
spec, and the ADRs.

## Your task
Determine whether the provided implementation conforms to the system
architecture described in the technical specification and all provided ADRs.

## Evaluation criteria
1. Does the implementation respect layer boundaries defined in the technical spec?
2. Does the implementation follow the patterns established in the ADRs?
3. Does the implementation violate any decisions recorded in ADRs?
4. Are dependencies flowing in the correct direction per the architecture?
5. Are components communicating through defined interfaces?

## Quoting requirement
For each finding, quote the exact code line(s) that evidence the finding.
If you cannot quote specific code, do not report the finding.

## Output schema
Return valid JSON:
{
  "verdict": "PASS" | "FAIL",
  "adr_violations": [
    {
      "adr_id": "string",
      "violation": "string",
      "location": "filename:line",
      "quoted_code": "string",
      "severity": "HIGH" | "MEDIUM" | "LOW"
    }
  ],
  "layer_violations": ["string"],
  "dependency_direction_violations": ["string"],
  "component_boundary_violations": ["string"],
  "notes": "string"
}

## Rules
- If uncertain whether something is a violation, note it as LOW severity
- Do not comment on code style or correctness — only architecture
- Do not suggest improvements beyond architectural compliance
```

---

### Prompt 4: Security Verifier

```markdown
# .ai/prompts/verifiers/security-verifier/system.md

You are an independent security reviewer.
Your role is to identify security vulnerabilities and insecure patterns
in the provided implementation.

## Your scope
- OWASP Top 10 vulnerability patterns
- Authentication and authorization correctness per the stated security model
- Input validation and sanitization
- Data exposure (logging sensitive data, exposing internal state in API responses)
- Cryptographic misuse
- Injection vulnerabilities (SQL, command, template, LDAP)
- Insecure direct object references
- Security requirements stated in the technical specification

## You must examine
1. Every function that handles user input
2. Every database query
3. Every authentication or authorization check
4. Every external API call
5. Every place where data is serialized or logged

## Quoting requirement
For each finding, quote the exact code line(s) that evidence the vulnerability.
If you cannot quote specific code, do not report the finding.

## Output schema
Return valid JSON:
{
  "verdict": "PASS" | "FAIL" | "ESCALATE",
  "escalate": boolean,
  "findings": [
    {
      "severity": "CRITICAL" | "HIGH" | "MEDIUM" | "LOW" | "INFO",
      "category": "string",
      "location": "filename:line",
      "quoted_code": "string",
      "description": "string",
      "recommendation": "string",
      "owasp_reference": "string (optional)"
    }
  ]
}

## Escalation rule
Set escalate: true if ANY finding is CRITICAL or HIGH severity.
These findings require human security review, not just a coding agent revision.

## What you must not do
- Guess at vulnerabilities without specific evidence in the code
- Flag false positives to appear thorough
- Recommend architectural changes beyond the scope of security
```

---

### Prompt 5: Specification Verifier

```markdown
# .ai/prompts/verifiers/spec-verifier/system.md

You are an independent specification verifier.
Your role is to determine whether the provided implementation satisfies the
functional requirements and acceptance criteria in the provided specification.

## Critical rule
You evaluate only what the spec states. You do not evaluate whether the
code is "good" — only whether it satisfies the stated requirements.

## Evaluation process
1. Read all functional requirements in the provided spec sections
2. Read all acceptance criteria for the provided story
3. For each requirement, determine: SATISFIED | NOT_SATISFIED | PARTIALLY_SATISFIED
4. Identify any behaviors in the implementation NOT described in the spec
5. Produce a structured verdict

## Quoting requirement
For each failed requirement, quote the spec text that is not satisfied.
For each out-of-spec behavior, quote the code that implements the extra behavior.

## Output schema
Return valid JSON:
{
  "verdict": "PASS" | "FAIL" | "PARTIAL",
  "requirements_checked": ["FR-001", "FR-002"],
  "failed_requirements": [
    {
      "id": "string",
      "spec_text": "string (quoted from spec)",
      "reason": "string",
      "spec_reference": "string",
      "severity": "HIGH" | "MEDIUM" | "LOW"
    }
  ],
  "partially_satisfied": [
    {
      "id": "string",
      "what_is_satisfied": "string",
      "what_is_missing": "string"
    }
  ],
  "out_of_spec_behaviors": [
    {
      "description": "string",
      "quoted_code": "string",
      "severity": "HIGH" | "MEDIUM" | "LOW"
    }
  ],
  "unimplemented_requirements": ["string"],
  "confidence": 0.0
}

## Verdict rules
- PASS: All requirements satisfied; no out-of-spec behaviors
- PARTIAL: All HIGH severity requirements satisfied; MEDIUM or LOW gaps exist
- FAIL: Any HIGH severity requirement not satisfied, OR significant out-of-spec behavior

## Confidence
Set confidence below 0.75 if:
- The spec uses ambiguous language that makes evaluation uncertain
- The implementation is too large to evaluate completely in this context
- Requirements are incompletely described
```

---

### Prompt 6: Testing Verifier

```markdown
# .ai/prompts/verifiers/test-verifier/system.md

You are an independent testing reviewer.
You evaluate whether the test suite adequately covers the acceptance criteria
for the story being reviewed.

## Your task
1. Read each acceptance criterion in the story
2. Examine the test files in the implementation
3. Determine whether each acceptance criterion has at least one test
4. Evaluate whether the tests assert on observable behavior (not implementation details)
5. Identify missing test cases

## What counts as adequate coverage
- Each acceptance criterion has at least one test that would FAIL if the
  criterion were not implemented
- Tests assert on behavior visible to a caller, not on internal state
- Tests cover the specific scenario described in the Given/When/Then format

## What does NOT count
- Tests that mock every dependency and assert nothing meaningful
- Tests that only verify a function was called, not what it returned
- Tests that would pass even if the acceptance criterion were removed

## Output schema
Return valid JSON:
{
  "verdict": "PASS" | "FAIL",
  "criteria_coverage": {
    "AC-001": "COVERED" | "NOT_COVERED" | "PARTIALLY_COVERED"
  },
  "missing_test_cases": ["string"],
  "test_quality_issues": ["string — describe the issue and which test has it"],
  "coverage_notes": "string"
}
```

---

### Prompt 7: Judge

```markdown
# .ai/prompts/verifiers/judge/system.md

You are the final decision-maker in a multi-verifier software development
pipeline. You receive the outputs of all verifiers and deterministic checks,
and produce a single binding decision.

## Inputs you will receive
- Spec verifier output (JSON)
- Security verifier output (JSON)
- Testing verifier output (JSON)
- Documentation verifier output (JSON, optional)
- Architecture verifier output (JSON, optional)
- API contract verifier output (JSON, if applicable)
- Deterministic check results (structured summary)

## Decision rules — apply in this strict order
1. If any deterministic check failed: decision = FAIL immediately
2. If security verifier has escalate: true: decision = ESCALATE immediately
3. If spec verifier verdict is FAIL: decision = FAIL immediately
4. If testing verifier verdict is FAIL and this is not a docs-only PR: decision = FAIL
5. If aggregate confidence < 0.70: decision = ESCALATE for human review
6. If aggregate confidence 0.70–0.85: decision = PASS with human_review_recommended = true
7. Otherwise: decision = PASS

## Confidence aggregation
- Take the minimum confidence score across all required verifiers
- Reduce by 0.05 for each PARTIAL verdict from the spec verifier
- Reduce by 0.10 if any verifier confidence is below 0.75

## Output schema
Return valid JSON:
{
  "decision": "PASS" | "FAIL" | "ESCALATE",
  "confidence": 0.0,
  "human_review_recommended": boolean,
  "blocking_reasons": ["string"],
  "warnings": ["string"],
  "verifier_summary": {
    "spec_verifier": "PASS" | "FAIL" | "PARTIAL",
    "security_verifier": "PASS" | "FAIL" | "ESCALATE",
    "test_verifier": "PASS" | "FAIL",
    "doc_verifier": "PASS" | "FAIL" | "WARN" | "NOT_RUN",
    "architecture_verifier": "PASS" | "FAIL" | "NOT_RUN"
  },
  "revision_guidance": "string (populated when decision is FAIL — actionable steps only)",
  "escalation_reason": "string (populated when decision is ESCALATE)"
}
```

---

### Prompt 8: Regression Reviewer

```markdown
# .ai/prompts/verifiers/regression-verifier/system.md

You are an independent regression reviewer.
You identify changes that may break existing behavior not covered by the
current story's tests.

## Your task
1. Examine the implementation diff
2. Identify all functions, methods, or components that were modified
3. Cross-reference against the provided list of existing test files and
   their coverage areas
4. Identify callers of modified functions that are tested elsewhere but
   NOT covered by the current story's new tests
5. Flag changes that could break behavior in untested call paths

## Output schema
Return valid JSON:
{
  "verdict": "PASS" | "WARN" | "FAIL",
  "modified_symbols": ["function/method/component names that were changed"],
  "potentially_affected_test_files": ["string"],
  "risky_changes": [
    {
      "changed_symbol": "string",
      "callers_not_covered": ["string"],
      "risk_description": "string",
      "severity": "HIGH" | "MEDIUM" | "LOW"
    }
  ]
}

## Verdict rules
- FAIL: A modified symbol is called by critical paths with no test coverage in this PR
- WARN: A modified symbol is called by non-critical paths not tested in this PR
- PASS: All callers of modified symbols are covered by existing or new tests
```


---

## Part 8 — Rule-Based Verification

### Why Deterministic Checks Come First

LLM verifiers excel at semantic reasoning: "does this logic match the specification intent?" Deterministic tools excel at precise, repeatable, fast checking of syntactic and structural properties. They never hallucinate. They are not subject to prompt drift. They run in milliseconds.

**The hybrid principle:** Use deterministic tools for everything they can check. Reserve LLM verifiers for what deterministic tools cannot assess.

```mermaid
flowchart LR
    subgraph "Deterministic — always first, always cheap"
        L[Linting]
        T[Type Checking]
        U[Unit Tests]
        I[Integration Tests]
        S[Schema Validation]
        Sc[Secret Scanning]
        D[Dependency Audit]
        Li[License Check]
        Cov[Coverage Threshold]
    end

    subgraph "LLM — only after deterministic pass"
        SV[Spec Verifier]
        SecV[Security Verifier]
        TV[Test Verifier]
        DV[Doc Verifier]
    end

    Deterministic -->|All pass| LLM
    Deterministic -->|Any fail| Block[Block — return to coder\nno LLM cost incurred]
```

---

### Deterministic Check Reference

#### Linting

```bash
# ESLint (JavaScript/TypeScript)
npx eslint src/ --max-warnings 0

# Ruff (Python)
ruff check src/

# golangci-lint (Go)
golangci-lint run ./...
```

**When it overrides LLM:** Always. A lint failure is deterministic and must be fixed regardless of LLM verifier opinion.

---

#### Type Checking

```bash
# TypeScript
npx tsc --noEmit

# Python
mypy src/ --strict

# Go
go vet ./...
```

**When it overrides LLM:** Always. Type errors are provably incorrect regardless of spec intent.

---

#### Unit and Integration Tests

```bash
# Jest with coverage threshold
jest --coverage --coverageThreshold='{"global":{"lines":80,"branches":75}}'

# pytest with coverage
pytest --cov=src --cov-fail-under=80 --cov-report=json

# Go tests
go test ./... -coverprofile=coverage.out
go tool cover -func=coverage.out
```

**When tests override LLM:** A failing test always blocks, even if the LLM verifier claims the implementation is correct. A failing test is ground truth; the LLM verifier's opinion is not.

---

#### Schema Validation

```bash
# OpenAPI
npx @stoplight/spectral-cli lint specs/api/openapi.yaml \
  --ruleset .ai/rules/.spectral.yaml

# JSON Schema
ajv validate -s schema.json -d data.json

# Database migration syntax
node scripts/validate-migrations.js
```

---

#### Secret Scanning

```bash
# gitleaks
gitleaks detect --source . --verbose --redact

# truffleHog
trufflehog filesystem . --only-verified --json
```

**When it overrides LLM:** Always. A committed secret is an immediate block regardless of any other verdict.

---

#### Dependency Scanning

```bash
# npm
npm audit --audit-level=high

# Python
pip-audit --output json

# License checking
npx license-checker \
  --onlyAllow "MIT;Apache-2.0;BSD-2-Clause;BSD-3-Clause;ISC" \
  --excludePrivatePackages
```

---

#### API Contract Testing Against a Running Server

```bash
# Dredd — tests running server against OpenAPI spec
dredd specs/api/openapi.yaml http://localhost:3000

# Schemathesis — property-based API testing
schemathesis run specs/api/openapi.yaml --url http://localhost:3000 \
  --checks all
```

**When it overrides LLM:** A contract test failure is deterministic. The API contract verifier (LLM) is a static pre-check; Dredd/Schemathesis test the running server — they are the authoritative check.

---

#### Migration Verification

```bash
# Verify migration is reversible
node scripts/check-migration-reversibility.js

# Detect destructive operations (DROP TABLE, DROP COLUMN)
node scripts/detect-destructive-migrations.js \
  --migrations db/migrations/ \
  --fail-on DROP
```

---

#### Security Static Analysis

```bash
# Semgrep with custom rules
semgrep --config .ai/rules/semgrep/security.yaml src/

# CodeQL (via GitHub Actions)
# Configured in .github/workflows/codeql.yml

# Bandit (Python)
bandit -r src/ -ll
```

---

### When Deterministic Checks Override LLM Decisions

| Situation | Correct outcome |
|---|---|
| LLM verifier says PASS; unit test fails | **FAIL** — test is ground truth |
| LLM verifier says PASS; secret scanner fires | **ESCALATE** — deterministic finding wins |
| LLM verifier says FAIL; all tests pass; spec is satisfied | **Review the verifier prompt** — likely false positive |
| LLM verifier says PASS; type checker fails | **FAIL** — type error is provably incorrect |
| LLM verifier says PASS; coverage falls below threshold | **FAIL** — policy violation |
| LLM verifier says PASS; Semgrep finds SQL injection pattern | **FAIL** — deterministic pattern wins |

**Rule:** Deterministic failures always win over LLM approvals. LLM approvals never override deterministic failures.

---

### Combining Deterministic and LLM Results in the Judge

```python
# .ai/scripts/judge.py (excerpt)

def build_judge_input(
    deterministic_results: dict,
    verifier_outputs: dict
) -> str:
    """
    Formats all inputs for the Judge prompt.
    Deterministic results are presented as facts, not opinions.
    """
    det_summary = format_deterministic_summary(deterministic_results)
    verifier_summary = format_verifier_outputs(verifier_outputs)

    return f"""
## Deterministic Check Results (authoritative — these are facts)

{det_summary}

## LLM Verifier Results (assessments — these are evaluations)

{verifier_summary}

## Decision rules
Apply the decision rules in your system prompt.
Deterministic failures are not overridable by LLM assessments.
"""

def format_deterministic_summary(results: dict) -> str:
    lines = []
    for check, result in results.items():
        status = "PASS" if result["passed"] else "FAIL"
        lines.append(f"- {check}: {status}")
        if not result["passed"] and result.get("output"):
            lines.append(f"  Error: {result['output'][:200]}")
    return "\n".join(lines)
```


---

## Part 9 — CI/CD Integration

### Pipeline Overview

```mermaid
flowchart TD
    PC["pre-commit\n(lint, secret scan)"] -->|git push| PP["pre-push\n(unit tests)"]
    PP --> PR[Pull Request opened]
    PR --> CIL["CI Layer 1\nDeterministic checks"]
    CIL -->|fail| Block1[Block PR — annotate failure]
    CIL -->|pass| CIV["CI Layer 2\nLLM Verifiers — parallel"]
    CIV -->|fail| Block2[Block PR — post verifier report]
    CIV -->|pass| MG["Merge Gate\n(required reviewers + Judge PASS)"]
    MG -->|approved| Merge[Merge to main]
    Merge --> Build[Build + Deploy]
    Build --> Smoke["Post-deploy\nSmoke tests"]
    Smoke -->|fail| Rollback[Rollback + alert]
    Smoke -->|pass| Night["Nightly\nFull verification audit"]
```

---

### Pre-Commit (Local — Deterministic Only)

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-json
      - id: check-merge-conflict

  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.0
    hooks:
      - id: gitleaks

  - repo: local
    hooks:
      - id: eslint
        name: ESLint
        entry: npx eslint --max-warnings 0
        language: node
        files: \.(js|ts|tsx)$
        pass_filenames: true

      - id: typecheck
        name: TypeScript type check
        entry: npx tsc --noEmit
        language: node
        pass_filenames: false
        always_run: false
        files: \.(ts|tsx)$
```

---

### Pull Request Verification Pipeline

```yaml
# .github/workflows/verifier-pipeline.yml
name: VITL Verification Pipeline

on:
  pull_request:
    branches: [main, develop]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  # ── Layer 1: Deterministic ────────────────────────────────
  deterministic:
    name: Deterministic Checks
    runs-on: ubuntu-latest
    outputs:
      passed: ${{ steps.summary.outputs.passed }}
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - run: npm ci

      - name: Lint
        run: npm run lint

      - name: Type check
        run: npm run typecheck

      - name: Unit tests with coverage
        run: |
          npm test -- --coverage \
            --coverageThreshold='{"global":{"lines":80,"branches":75}}'

      - name: OpenAPI validation
        run: |
          npx @stoplight/spectral-cli lint specs/api/openapi.yaml \
            --ruleset .ai/rules/.spectral.yaml

      - name: Secret scanning
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Dependency audit
        run: npm audit --audit-level=high

      - name: License check
        run: |
          npx license-checker \
            --onlyAllow "MIT;Apache-2.0;BSD-2-Clause;BSD-3-Clause;ISC" \
            --excludePrivatePackages

      - name: Semgrep security scan
        uses: semgrep/semgrep-action@v1
        with:
          config: .ai/rules/semgrep/security.yaml

      - id: summary
        run: echo "passed=true" >> $GITHUB_OUTPUT

  # ── Layer 2: LLM Verification ─────────────────────────────
  llm-verification:
    name: LLM Verifiers
    runs-on: ubuntu-latest
    needs: deterministic
    if: needs.deterministic.result == 'success'
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - run: pip install anthropic pyyaml

      - name: Extract story ID from PR title
        id: story
        run: |
          STORY=$(echo "${{ github.event.pull_request.title }}" \
            | grep -oP 'STORY-\d+' | head -1)
          echo "id=${STORY}" >> $GITHUB_OUTPUT
          if [ -z "$STORY" ]; then
            echo "::warning::No STORY-NNN found in PR title. Skipping LLM verification."
          fi

      - name: Get changed files
        id: changed
        run: |
          FILES=$(git diff --name-only origin/${{ github.base_ref }} HEAD | tr '\n' ',')
          echo "files=$FILES" >> $GITHUB_OUTPUT

      - name: Run LLM verifiers (parallel)
        if: steps.story.outputs.id != ''
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
          STORY_ID: ${{ steps.story.outputs.id }}
          CHANGED_FILES: ${{ steps.changed.outputs.files }}
        run: |
          python .ai/scripts/run-verifiers.py \
            --story "$STORY_ID" \
            --changed-files "$CHANGED_FILES" \
            --config .ai/config/pipeline.yaml \
            --output reports/verifier-output.json

      - name: Run judge
        if: steps.story.outputs.id != ''
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          python .ai/scripts/judge.py \
            --verifier-output reports/verifier-output.json \
            --config .ai/config/thresholds.yaml \
            --output reports/judge-decision.json

      - name: Generate PR report
        if: steps.story.outputs.id != ''
        run: |
          python .ai/scripts/generate-report.py \
            --judge-output reports/judge-decision.json \
            --output reports/pr-report.md

      - name: Post report as PR comment
        if: steps.story.outputs.id != ''
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const report = fs.readFileSync('reports/pr-report.md', 'utf8');
            await github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## 🔍 VITL Verification Report\n\n${report}`
            });

      - name: Apply labels based on decision
        if: steps.story.outputs.id != ''
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const decision = JSON.parse(
              fs.readFileSync('reports/judge-decision.json', 'utf8')
            );
            const labels = {
              'PASS': ['verification-passed'],
              'FAIL': ['verification-failed'],
              'ESCALATE': ['verification-escalate', 'needs-human-review']
            };
            await github.rest.issues.addLabels({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              labels: labels[decision.decision] || []
            });

      - name: Fail CI if judge says FAIL
        if: steps.story.outputs.id != ''
        run: |
          DECISION=$(python -c "
          import json
          d = json.load(open('reports/judge-decision.json'))
          print(d['decision'])
          ")
          if [ "$DECISION" = "FAIL" ]; then
            echo "::error::Verification FAILED. See PR comment for details."
            exit 1
          fi
          echo "Decision: $DECISION"

  # ── Layer 3: Integration Tests ─────────────────────────────
  integration:
    name: Integration Tests
    runs-on: ubuntu-latest
    needs: deterministic
    if: needs.deterministic.result == 'success'
    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_PASSWORD: testpassword
          POSTGRES_DB: testdb
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - name: Run migrations
        run: npm run db:migrate
        env:
          DATABASE_URL: postgresql://postgres:testpassword@localhost/testdb
      - name: Integration tests
        run: npm run test:integration
        env:
          DATABASE_URL: postgresql://postgres:testpassword@localhost/testdb
      - name: API contract tests
        run: |
          npm run start:test &
          sleep 5
          npx dredd specs/api/openapi.yaml http://localhost:3000
        env:
          DATABASE_URL: postgresql://postgres:testpassword@localhost/testdb
```

---

### Nightly Verification Job

```yaml
# .github/workflows/nightly-verification.yml
name: Nightly Full Verification

on:
  schedule:
    - cron: '0 2 * * *'
  workflow_dispatch:

jobs:
  spec-freshness:
    name: Spec Freshness Audit
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - name: Check spec freshness
        run: |
          python .ai/scripts/check-spec-freshness.py \
            --max-days 90 \
            --spec-dir specs/ \
            --output reports/spec-freshness.json
      - name: Upload report
        uses: actions/upload-artifact@v4
        with:
          name: spec-freshness-${{ github.run_id }}
          path: reports/spec-freshness.json

  full-security-scan:
    name: Full Security Scan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Semgrep full scan
        uses: semgrep/semgrep-action@v1
        with:
          config: >-
            p/owasp-top-ten
            p/nodejs
            .ai/rules/semgrep/security.yaml
      - name: CodeQL analysis
        uses: github/codeql-action/analyze@v3
        with:
          languages: javascript-typescript

  dependency-freshness:
    name: Dependency Freshness
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - name: Check for outdated packages
        run: npm outdated || true
      - name: Check for new vulnerabilities
        run: npm audit --audit-level=moderate
```

---

### Post-Deployment Validation

```yaml
# .github/workflows/post-deploy-validation.yml
name: Post-Deployment Validation

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Deployment environment'
        required: true
        type: choice
        options: [staging, production]
      deploy_url:
        description: 'Base URL of the deployed service'
        required: true

jobs:
  smoke-tests:
    name: Smoke Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - name: Run smoke tests
        run: npx playwright test tests/smoke/
        env:
          BASE_URL: ${{ inputs.deploy_url }}
      - name: API contract validation (live)
        run: |
          npx schemathesis run specs/api/openapi.yaml \
            --url "${{ inputs.deploy_url }}" \
            --checks all \
            --hypothesis-max-examples 50

  rollback-on-failure:
    name: Rollback if Smoke Tests Fail
    runs-on: ubuntu-latest
    needs: smoke-tests
    if: failure() && inputs.environment == 'production'
    steps:
      - uses: actions/checkout@v4
      - name: Trigger rollback
        run: |
          echo "Smoke tests failed in production — triggering rollback"
          ./scripts/rollback.sh "${{ inputs.environment }}"
        env:
          DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
```


---

## Part 10 — Scaling

### Scale Dimension Matrix

| Dimension | Solo Dev | Small Team (2–8) | Large Team (8–50) | Platform / Enterprise |
|---|---|---|---|---|
| Verifiers to run | Spec + Security | Spec + Security + Tests + API | All relevant | Full suite + custom domain verifiers |
| Parallelism | Sequential | Parallel where possible | Fully parallel | Distributed workers |
| Human review | Optional | PR review | Required gates | Tiered approval |
| Cost optimization | Combined single prompt | Cache verifier results | Incremental verification | Dedicated verification infra |
| Context management | Manual | Semi-automated | Automated assembly | Context pipeline as a service |
| Prompt maintenance | One person | Team owns | Platform team owns | Versioned, tested, deployed |

---

### Solo Developers

**Recommended architecture:** Planner → Coder → single combined verifier.

**Cost optimization:** Run one combined verifier prompt that checks spec + security + tests in one call. Less rigorous than separate specialist verifiers but cheaper and faster for a solo context.

```python
COMBINED_VERIFIER_PROMPT = """
You are verifying a code implementation against three criteria.
For each, return PASS, WARN, or FAIL with brief justification.

Criterion 1 (Spec): Does the implementation satisfy all acceptance criteria?
Criterion 2 (Security): Are there obvious security issues?
Criterion 3 (Tests): Does each acceptance criterion have a test?

Return JSON:
{
  "spec": "PASS|WARN|FAIL",
  "security": "PASS|WARN|FAIL",
  "tests": "PASS|WARN|FAIL",
  "issues": ["string"],
  "overall": "PASS|FAIL"
}
"""
```

**Solo workflow:**
1. Write story and reference spec sections
2. Run coding agent with spec context
3. Run `npm test && npm run lint` (deterministic)
4. Run combined verifier
5. Fix any FAIL items
6. Commit

---

### Small Teams

**Recommended architecture:** Hybrid pipeline with parallel specialist verifiers.

**Key additions over solo:**
- Separate verifier prompts per dimension
- PR-based review with verification report attached as a comment
- Shared `.ai/` directory under version control
- Weekly verifier evaluation against known test cases

---

### Large Teams

**Parallel verification:**

```python
import asyncio
import anthropic
import json
from pathlib import Path

async def run_verifier(client, verifier_config: dict, context: str) -> tuple:
    prompt = Path(verifier_config["prompt_file"]).read_text()
    response = await client.messages.create(
        model=verifier_config["model"],
        max_tokens=verifier_config["max_tokens"],
        system=prompt,
        messages=[{"role": "user", "content": context}]
    )
    raw = response.content[0].text
    try:
        result = json.loads(raw)
    except json.JSONDecodeError:
        result = {"verdict": "ERROR", "error": "Invalid JSON from verifier"}
    return verifier_config["id"], result

async def run_all_verifiers(
    context: str,
    active_verifiers: list[dict]
) -> dict:
    client = anthropic.AsyncAnthropic()
    tasks = [
        run_verifier(client, cfg, context)
        for cfg in active_verifiers
    ]
    results = await asyncio.gather(*tasks, return_exceptions=True)
    return {vid: result for vid, result in results if not isinstance(result, Exception)}
```

**Incremental verification — run only verifiers relevant to changed files:**

```python
def select_active_verifiers(
    changed_files: list[str],
    verifier_configs: list[dict]
) -> list[dict]:
    active = []
    for cfg in verifier_configs:
        condition = cfg.get("condition")
        if not condition:
            active.append(cfg)
            continue
        if "files_changed_match" in condition:
            pattern = condition.split(": ", 1)[1]
            if any(pattern in f for f in changed_files):
                active.append(cfg)
    return active
```

---

### Platform / Enterprise

**Dedicated verification infrastructure:**

```mermaid
flowchart TD
    PR[PR Event] --> Gateway[Verification Gateway Service]
    Gateway --> Queue[Verification Job Queue]
    Queue --> W1[Verifier Worker 1\nSpec Verifier]
    Queue --> W2[Verifier Worker 2\nSecurity Verifier]
    Queue --> W3[Verifier Worker 3\nTest Verifier]
    W1 --> Results[Results Store]
    W2 --> Results
    W3 --> Results
    Results --> Judge[Judge Service]
    Judge --> GH[GitHub Status API]
    Judge --> Audit[Audit Log Service]
    Judge --> Metrics[Metrics Service]
```

At enterprise scale, the verification pipeline becomes a service:
- Verifier workers run as containerized services (one per verifier type)
- Job queue (Redis, SQS) distributes verification work
- Results stored in a database, not ephemeral files
- Judge is a dedicated service with its own API
- All decisions written to an immutable audit log

---

### Cost Optimization

| Technique | Savings | Tradeoff |
|---|---|---|
| **Deterministic first** (always) | 30–70% reduction in LLM calls | None — always do this |
| **Incremental verification** | Only run relevant verifiers per changed files | Must maintain accurate file→verifier mapping |
| **Model tiering** | Use smaller models for low-stakes verifiers | Slightly less accurate |
| **Caching** | Cache verifier results for unchanged files | Cache invalidation complexity |
| **Combined verifiers for low-risk changes** | One call instead of five | Less granular feedback |
| **Skip docs-only PRs** | Skip most verifiers for non-code changes | Must accurately classify PR type |

**Model tiering recommendation:**

| Verifier | Recommended tier | Rationale |
|---|---|---|
| Style verifier | Smallest fast model | Mechanical task |
| Documentation verifier | Small model | Presence check |
| Spec verifier | Mid-tier | Requires careful reading |
| Architecture verifier | Mid-tier | Requires structural reasoning |
| Security verifier | Largest available | High stakes; false negatives are costly |
| Judge | Largest available | Final decision; needs full context |

---

### Caching Implementation

```python
import hashlib
import json
from pathlib import Path
from datetime import datetime, timedelta

CACHE_DIR = Path(".ai/cache/verifier-results")
CACHE_TTL_HOURS = 24

def cache_key(verifier_id: str, spec_content: str, implementation: str) -> str:
    content = f"{verifier_id}:{spec_content}:{implementation}"
    return hashlib.sha256(content.encode()).hexdigest()

def get_cached(key: str) -> dict | None:
    cache_file = CACHE_DIR / f"{key}.json"
    if not cache_file.exists():
        return None
    cached = json.loads(cache_file.read_text())
    cached_at = datetime.fromisoformat(cached["cached_at"])
    if datetime.now() - cached_at > timedelta(hours=CACHE_TTL_HOURS):
        cache_file.unlink()  # Expired
        return None
    return cached["result"]

def set_cached(key: str, result: dict):
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    cache_file = CACHE_DIR / f"{key}.json"
    cache_file.write_text(json.dumps({
        "cached_at": datetime.now().isoformat(),
        "result": result
    }))
```

**Cache invalidation triggers:**
- Spec file changes → invalidate spec verifier cache for related stories
- Prompt file changes → invalidate all cache entries for that verifier
- Implementation changes → always re-run (never cache on unchanged implementation)

---

### Context Management for Large Codebases

When the full codebase exceeds context window limits, use targeted context assembly:

```python
def assemble_verifier_context(
    story_id: str,
    verifier_type: str,
    changed_files: list[str],
    max_tokens: int = 50000
) -> str:
    """
    Assembles the minimal context needed for a specific verifier.
    Avoids loading the full codebase into context.
    """
    story = load_story(story_id)
    spec_sections = load_referenced_specs(story)

    if verifier_type == "spec-verifier":
        return f"""
STORY:
{story}

SPEC SECTIONS:
{spec_sections}

IMPLEMENTATION (changed files only):
{load_files(changed_files, max_tokens - len(story) - len(spec_sections))}
"""
    elif verifier_type == "security-verifier":
        # Security verifier needs full files, not just changed lines
        return f"""
SECURITY REQUIREMENTS:
{load_security_requirements()}

IMPLEMENTATION (full files for changed modules):
{load_full_module_files(changed_files, max_tokens)}
"""
```


---

## Part 11 — Failure Modes

### Failure Mode Map

```mermaid
mindmap
  root((VITL Failures))
    False Positives
      Overly strict prompt
      Spec ambiguity
      Pattern mismatch
      Unrecognized idiom
    False Negatives
      Context truncation
      Novel vulnerability
      Hallucinated PASS
      Verifier blind spot
    Loop Failures
      Max retries exceeded
      Vague feedback
      Spec gap not caught
      Conflicting verifiers
    Structural Failures
      Stale prompts
      Spec drift
      Context loss
      Review deadlock
      Trust erosion
```

---

### False Positives

**Symptom:** Verifier reports FAIL for correct, spec-compliant implementation.

**Common causes:**
- Verifier prompt is more restrictive than the spec
- Verifier interprets a valid architectural pattern it doesn't recognize as a violation
- Style verifier flags valid alternative approaches as non-standard

**Mitigations:**
- Maintain a test suite of known-good implementations that should produce PASS (in `evaluations/`)
- Add explicit "you should NOT flag X" instructions to verifier prompts for known false positive patterns
- Log all false positives in a running document; review monthly and update prompts
- Allow humans to override with documented justification and a note for prompt improvement

**Risk:** If false positive rate is too high, engineers lose trust and start bypassing verifiers. **This is the most damaging failure mode** — a pipeline that cries wolf is worse than no pipeline at all.

---

### False Negatives

**Symptom:** Verifier reports PASS for implementation that violates spec or contains defects.

**Common causes:**
- Context truncation: verifier only sees part of the implementation
- Verifier does not check all spec requirements (prompt scope too narrow)
- LLM hallucinates a PASS rationale for code it didn't fully analyze
- Novel vulnerability pattern not in training data

**Mitigations:**
- Maintain a test suite of known-bad implementations that must produce FAIL (in `evaluations/`)
- For security verifiers: always combine with deterministic tools (Semgrep, CodeQL)
- Require verifiers to quote the specific code that produces each finding — hallucinated rationales cannot accurately quote code that doesn't exist
- Chunk large files rather than truncating them

---

### Verification Loops

**Symptom:** Coder and Verifier cycle repeatedly without convergence.

**Common causes:**
- Verifier feedback is too vague ("the error handling is insufficient")
- Coder is addressing the symptom, not the root cause
- Spec is genuinely ambiguous, causing different interpretations each cycle
- Coder revises the flagged code but breaks something else, triggering a new FAIL

**Mitigations:**
- Require verifier feedback to include: specific location, specific failure, specific spec reference, specific fix suggestion
- Set a hard maximum revision count (3 is typical) and escalate to human after
- If a loop repeats the same finding ≥2 times: escalate — the spec likely needs clarification

**Anti-pattern to avoid:**

```
# Bad verifier feedback — causes loops
"The authentication implementation has several issues that need to be addressed."

# Good verifier feedback — causes resolution
"FR-003 requires that failed login attempts are rate-limited to 5 per minute.
The current implementation in src/auth/login.ts:67 has no rate limiting.
Specifically: the login handler at line 67 calls authenticateUser() with no
preceding rate check. Add rate limiting middleware BEFORE the authenticateUser()
call using the rate-limiter-flexible library (approved in ADR-007).
Reference: FUNC-001 §4.3, FR-003."
```

---

### Conflicting Verifiers

**Symptom:** Two verifiers disagree. Spec verifier says PASS; Architecture verifier says FAIL.

**Resolution rules (apply in priority order):**
1. Security CRITICAL/HIGH always wins — escalate regardless of other verdicts
2. Spec verifier FAIL always blocks — no other verifier overrides this
3. For conflicts between optional verifiers, Judge applies weighted scoring
4. Conflicts are documented in the verification report and surfaced to human reviewer

**Conflict example and resolution:**

```
Spec verifier: PASS — "Implementation satisfies all FR requirements"
Architecture verifier: FAIL — "Business logic placed in controller layer (ADR-003)"

Resolution: Architecture FAIL blocks. The spec verifier evaluated functional
correctness; the architecture verifier evaluated structural compliance.
Both can be simultaneously true. The architecture issue must be fixed
even though the spec is satisfied. Judge decision: FAIL.
```

---

### Hallucinated Verification

**Symptom:** Verifier produces a confident PASS or FAIL with a rationale that does not correspond to what is actually in the implementation or spec.

**Detection:**
- Include a "quote the relevant code" requirement in verifier prompts — hallucinated rationales cannot accurately quote code that doesn't exist
- Review confidence scores: high confidence on very complex evaluations is a warning sign
- Run verifier evaluation suite regularly to detect degradation

**Mitigation — add to all verifier prompts:**

```markdown
## Quoting requirement

For each finding, quote the exact code or spec text that produces the finding.
Format: `filename:line — [exact quoted text]`

If you cannot quote specific text from the provided input, DO NOT report the finding.
A finding without a quotation will be discarded.
```

---

### Spec Drift

**Symptom:** Specs have been updated; verifier prompts or the implementation no longer align with current spec content.

**Types of spec drift:**
1. **Implementation ahead of spec:** Code was updated; spec was not amended
2. **Spec ahead of implementation:** Spec was amended; implementation not yet updated
3. **Verifier prompt drift:** Verifier prompts embed spec section references that no longer exist

**Mitigations:**
- Verifier prompts receive spec content as input (not embedded references) — this eliminates type 3 drift
- Spec amendment PR is required before or alongside implementation changes — prevents type 1
- Nightly spec freshness check alerts when spec `updated` date is stale relative to code changes
- Monthly spec audit: compare spec content against implementation for key behaviors

---

### Stale Prompts

**Symptom:** Verifier prompts were written for an earlier version of the codebase, tech stack, or standards. They now produce irrelevant findings or miss current patterns.

**Mitigations:**
- Every verifier prompt directory has a `CHANGELOG.md` and a mandatory quarterly review
- Treat prompt changes as code changes: PR review required, versioned, tested against evaluation suite
- In retrospectives: "Did any verifier produce clearly wrong or irrelevant output this sprint?"
- When tech stack changes (new framework, new language), audit all verifier prompts

---

### Context Loss in Long Pipelines

**Symptom:** Later stages lose the context of earlier decisions. The Judge doesn't know why a verifier flagged something; the revision prompt loses the original issue.

**Mitigations:**
- All verifier outputs are structured JSON stored on disk between pipeline steps
- Judge receives all prior outputs as structured input, not natural language summaries
- Maintain a pipeline state file that accumulates all decisions for a single run
- Revision prompts include the complete original issue, not just "fix the error"

---

### Review Deadlock

**Symptom:** An ESCALATE verdict reaches a human reviewer who doesn't have the context or authority to make the decision, so it sits unreviewed.

**Mitigations:**
- Define escalation routing explicitly: security ESCALATE → security team, spec ambiguity ESCALATE → product owner + tech lead
- Set SLAs on escalated reviews (e.g., 1 business day for security, 4 hours for spec questions)
- If SLA is missed, auto-reassign and alert the team
- Track escalation rate: if it's above 10% of PRs, the verifier confidence thresholds need tuning

---

### Trust Erosion

**Symptom:** Engineers begin adding "skip verification" flags, creating empty test files to satisfy the test verifier, or treating the pipeline as a bureaucratic hurdle rather than a quality tool.

**This is a pipeline health crisis, not a developer discipline problem.**

**Root causes:**
- False positive rate is too high
- Verifier feedback is not actionable
- Pipeline latency is too high for the workflow
- Engineers don't see the value (verification catches nothing important)

**Mitigations:**
- Track and report what the verifiers actually caught (true positives)
- Reduce false positives aggressively — one false positive per week is too many
- Reduce latency where possible (caching, incremental verification, model tiering)
- Involve engineers in prompt improvement — they see the failures


---

## Part 12 — Best Practices

### Verification Depth by Risk Level `[Essential]`

```mermaid
flowchart LR
    Low["Low Risk\n(docs, copy, config)"] --> LV["Style + Doc verifiers\nDeterministic only"]
    Med["Medium Risk\n(new feature, UI)"] --> MV["Spec + Security\n+ Tests + API"]
    High["High Risk\n(auth, payments, data model)"] --> HV["Full suite\n+ Human review required"]
    Crit["Critical\n(infra, schema breaking, security)"] --> CV["Full suite\n+ Security audit\n+ Change board approval"]
```

---

### Number of Verifiers `[Recommended]`

For most feature work: **3–5 specialist verifiers + 1 Judge.** More is not better.

Adding verifiers adds cost and latency. Each verifier must have a clearly distinct scope. If two verifiers would check the same thing, merge them. If a verifier's output is never acted on, remove it.

**The minimum viable VITL pipeline:**
1. Spec Verifier (blocks on FAIL)
2. Security Verifier (blocks on HIGH/CRITICAL, escalates)
3. Testing Verifier (blocks on FAIL)
4. Judge (aggregates; routes to human if needed)

Everything else is an enhancement.

---

### When to Stop Iterating `[Essential]`

Set hard limits, not soft expectations:

```yaml
# .ai/config/pipeline.yaml
pipeline:
  max_revision_cycles: 3

  escalation_triggers:
    - condition: revision_count >= max_revision_cycles
      action: escalate_to_human
      message: "Max revision cycles reached. Human review required."

    - condition: same_finding_repeated_count >= 2
      action: escalate_to_human
      message: "Same finding repeated — spec clarification may be needed."

    - condition: security_escalate == true
      action: escalate_to_security_team
      message: "Security escalation — requires security team review."
```

After escalation, a human reviews the full history and determines root cause: implementation issue, spec gap, or verifier false positive. One of the three is always the cause.

---

### Approval Thresholds `[Recommended]`

Three-zone confidence model:

| Zone | Confidence Range | Action |
|---|---|---|
| Auto-pass | ≥ 0.85 | Merge after human skims report — no blocking review required |
| Human review | 0.70 – 0.85 | Human reviews before merge — verifier report surfaces the specific uncertainty |
| Escalate | < 0.70 | Human investigates — pipeline may be miscalibrated, or task is genuinely hard |

Tune thresholds based on observed false positive and false negative rates over time. Start conservative (0.90 auto-pass threshold) and lower it as verifier quality is validated.

---

### Confidence Scoring `[Recommended]`

Implement a consistent confidence aggregation approach:

```python
def aggregate_confidence(verifier_outputs: dict) -> float:
    """
    Aggregates verifier confidence scores into a single pipeline confidence.
    More conservative than a simple average — uses minimum as the floor.
    """
    scores = []
    for vid, output in verifier_outputs.items():
        if "confidence" in output:
            scores.append(output["confidence"])

    if not scores:
        return 0.5  # Unknown — default to human review band

    base = min(scores)  # Floor: confidence is only as good as the least confident verifier

    # Reduce for PARTIAL verdicts
    partial_count = sum(
        1 for o in verifier_outputs.values()
        if o.get("verdict") == "PARTIAL"
    )
    base -= (partial_count * 0.05)

    # Reduce if any score is below 0.75
    low_confidence_count = sum(1 for s in scores if s < 0.75)
    base -= (low_confidence_count * 0.10)

    return max(0.0, min(1.0, base))
```

---

### Traceability `[Essential]`

Every verification decision must be traceable:

- PR contains: story ID → spec references → verifier report → judge decision
- Verifier report contains: which requirements were checked → verdict per requirement → evidence (quoted code and spec text)
- All reports stored as PR artifacts and/or in an external audit log
- Judge decision references all verifier IDs and their prompt versions

**Traceability chain:**

```
STORY-007 → FUNC-001 §4.3 (FR-012, FR-013)
         → spec-verifier v1.3.0 → PASS (confidence 0.91)
         → security-verifier v2.1.0 → PASS (no HIGH/CRITICAL)
         → test-verifier v1.1.0 → PASS (all AC covered)
         → judge v1.5.0 → PASS (confidence 0.91)
         → @engineer approved 2024-03-15 14:22
         → Merged to main: commit abc1234
```

---

### Logging and Audit Trails `[Essential]`

```python
import json
from datetime import datetime, timezone
from pathlib import Path

AUDIT_LOG = Path("logs/audit.jsonl")

def log_verification_event(
    run_id: str,
    story_id: str,
    stage: str,
    actor: str,        # model name or human @handle
    decision: str,
    evidence: dict,
    prompt_version: str | None = None
):
    event = {
        "run_id": run_id,
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "story_id": story_id,
        "stage": stage,
        "actor": actor,
        "decision": decision,
        "evidence": evidence,
        "prompt_version": prompt_version
    }
    # Append-only
    with open(AUDIT_LOG, "a") as f:
        f.write(json.dumps(event) + "\n")
```

The audit log is append-only. Never modify or delete entries.

---

### Observability and Metrics `[Recommended]`

Track these metrics per verifier, per week:

| Metric | Definition | Target |
|---|---|---|
| **True positive rate** | FAIL verdicts where human confirmed a real issue | > 80% |
| **False positive rate** | FAIL verdicts where human overrode | < 10% |
| **False negative rate** | PASS verdicts where issues were later found | < 5% |
| **Mean time to verification** | Time from implementation complete to judge decision | < 60 seconds |
| **Revision cycle rate** | % of implementations requiring ≥1 revision | Track trend |
| **Escalation rate** | % of implementations escalated to human | 5–15% is healthy |
| **Pipeline bypass rate** | % of PRs that skip verification | Should be 0% for feature PRs |

Review metrics monthly. If true positive rate drops below 70%, the verifiers need recalibration. If false positive rate exceeds 15%, engineers will start bypassing the pipeline.

---

### Prompt Maintenance Discipline `[Essential]`

```markdown
## Prompt maintenance checklist (quarterly)

For each verifier prompt:

- [ ] Review against current spec structure — do section references still exist?
- [ ] Run against evaluations/test-cases/ — does pass rate meet baseline?
- [ ] Check CHANGELOG.md — were changes made without evaluation?
- [ ] Review false positive log — are there patterns to suppress?
- [ ] Review false negative log — are there patterns to add?
- [ ] Update CHANGELOG.md with review outcome (even if no changes made)
```

---

### Verifier Evaluation `[Recommended]`

Verifiers must themselves be tested. Maintain evaluation cases for each verifier:

```python
# evaluations/run-eval.py
import json
from pathlib import Path

def run_evaluations(verifier_id: str) -> dict:
    should_pass = Path(f"evaluations/test-cases/{verifier_id}/should-pass").glob("*.json")
    should_fail = Path(f"evaluations/test-cases/{verifier_id}/should-fail").glob("*.json")

    results = {"tp": 0, "tn": 0, "fp": 0, "fn": 0}

    for case_file in should_pass:
        case = json.loads(case_file.read_text())
        verdict = run_verifier(verifier_id, case["input"])
        if verdict["verdict"] in ("PASS", "PARTIAL"):
            results["tn"] += 1  # Correctly not flagged
        else:
            results["fp"] += 1  # False positive
            print(f"FALSE POSITIVE: {case_file.name}")

    for case_file in should_fail:
        case = json.loads(case_file.read_text())
        verdict = run_verifier(verifier_id, case["input"])
        if verdict["verdict"] == "FAIL":
            results["tp"] += 1  # Correctly flagged
        else:
            results["fn"] += 1  # False negative
            print(f"FALSE NEGATIVE: {case_file.name}")

    total = sum(results.values())
    accuracy = (results["tp"] + results["tn"]) / total if total else 0
    print(f"{verifier_id}: accuracy={accuracy:.2%} TP={results['tp']} FP={results['fp']} FN={results['fn']}")
    return results
```

Run evaluations before deploying prompt changes. Require accuracy ≥ 80% before a prompt update ships.


---

## Part 13 — End-to-End Example

### Feature: Rate Limiting on Login Endpoint

**Story:** STORY-007 — Add rate limiting to the login endpoint to prevent brute force attacks.

---

#### Step 1: Story Document

```markdown
---
id: STORY-007
feature: FEAT-003
func-spec: FUNC-001 §4.3
story-points: 3
assignee: @engineer
---

# STORY-007: Rate Limiting on Login Endpoint

## User Story
As a security-conscious platform, we want to limit failed login attempts
to prevent brute force attacks against user accounts.

## Spec References
- FUNC-001 §4.3 — FR-012, FR-013
- TECH-001 §5.1 — Rate limiting requirements (Redis, rate-limiter-flexible)
- ADR-007 — Approved: rate-limiter-flexible library for rate limiting

## Acceptance Criteria

**AC-001:** After 5 failed login attempts from the same IP within 60 seconds,
subsequent attempts return HTTP 429 with a Retry-After header.

**AC-002:** Successful logins reset the failed attempt counter for that IP.

**AC-003:** Rate limit events are logged for security monitoring with: IP,
timestamp, and endpoint.

**AC-004:** The rate limit window and max attempts are configurable via
environment variables RATE_LIMIT_MAX_ATTEMPTS and RATE_LIMIT_WINDOW_SECONDS.
```

---

#### Step 2: Planner Output

```markdown
## Implementation Plan: STORY-007

### Files to create
- `src/middleware/rate-limiter.ts` — RateLimiter middleware using rate-limiter-flexible
- `src/middleware/rate-limiter.test.ts` — Unit tests for all AC

### Files to modify
- `src/api/routes/auth.ts` — Apply middleware to POST /api/v1/auth/login
- `.env.example` — Document RATE_LIMIT_MAX_ATTEMPTS and RATE_LIMIT_WINDOW_SECONDS

### Approach
1. Create `loginRateLimiter` middleware using RateLimiterRedis from rate-limiter-flexible
2. Configure from env vars with defaults: 5 attempts, 60 second window (AC-004)
3. Apply BEFORE credential validation in the login route (fail fast)
4. On limit exceeded: return 429 with Retry-After header (AC-001)
5. Create `resetLoginRateLimit(ip)` helper — call on successful login (AC-002)
6. Log all rate limit events via existing structured logger (AC-003)

### Dependencies
- Redis is already in the stack per TECH-001 — no new infrastructure
- rate-limiter-flexible is already in package.json per ADR-007

### Spec gaps identified
None.

### Risk
Medium. Redis connection failure edge case: fail open (allow login) rather than
fail closed (block all logins). This prioritizes availability over security for
the Redis failure case. This is a deliberate tradeoff — will document in TECH-001.
```

---

#### Step 3: Implementation

```typescript
// src/middleware/rate-limiter.ts
import { RateLimiterRedis } from 'rate-limiter-flexible';
import { redis } from '../lib/redis';
import { logger } from '../lib/logger';
import { Request, Response, NextFunction } from 'express';

const MAX_ATTEMPTS = parseInt(process.env.RATE_LIMIT_MAX_ATTEMPTS ?? '5', 10);
const WINDOW_SECONDS = parseInt(process.env.RATE_LIMIT_WINDOW_SECONDS ?? '60', 10);

const rateLimiter = new RateLimiterRedis({
  storeClient: redis,
  keyPrefix: 'login_fail',
  points: MAX_ATTEMPTS,
  duration: WINDOW_SECONDS,
});

/**
 * Rate limiting middleware for the login endpoint.
 * Applies IP-based rate limiting per FUNC-001 §4.3 FR-012.
 * Fails open if Redis is unavailable (availability prioritized per TECH-001 §5.1).
 */
export async function loginRateLimiter(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  const ip = req.ip ?? 'unknown';

  try {
    await rateLimiter.consume(ip);
    next();
  } catch (err: unknown) {
    if (err && typeof err === 'object' && 'msBeforeNext' in err) {
      const retryAfter = Math.ceil(
        (err as { msBeforeNext: number }).msBeforeNext / 1000
      );
      // AC-003: Log rate limit event
      logger.warn({
        event: 'rate_limit_exceeded',
        ip,
        endpoint: '/api/v1/auth/login',
        retryAfterSeconds: retryAfter,
      });
      // AC-001: Return 429 with Retry-After header
      res
        .status(429)
        .set('Retry-After', String(retryAfter))
        .json({
          code: 'RATE_LIMIT_EXCEEDED',
          message: 'Too many login attempts. Please try again later.',
        });
      return;
    }
    // Redis failure — fail open (TECH-001 §5.1)
    logger.error({ event: 'rate_limiter_redis_error', ip, error: String(err) });
    next();
  }
}

/**
 * Resets the rate limit counter for an IP on successful login.
 * Per FUNC-001 §4.3 FR-013 (AC-002).
 */
export async function resetLoginRateLimit(ip: string): Promise<void> {
  try {
    await rateLimiter.delete(ip);
  } catch (err) {
    logger.error({ event: 'rate_limit_reset_error', ip, error: String(err) });
  }
}
```

---

#### Step 4: Deterministic Layer Results

```
✅ ESLint:      0 errors, 0 warnings
✅ TypeScript:  No errors
✅ Unit tests:  9 passed, 0 failed
   Coverage:   94% lines (threshold: 80%)
✅ OpenAPI:     Unchanged — lint skipped (no API changes)
✅ Secrets:     None detected
✅ npm audit:   0 vulnerabilities
✅ Licenses:    All approved

→ All deterministic checks passed. Proceeding to LLM verifier layer.
```

---

#### Step 5: LLM Verifier Outputs (parallel execution)

**Spec Verifier (claude-sonnet-4-6, v1.3.0):**
```json
{
  "verdict": "PASS",
  "requirements_checked": ["FR-012", "FR-013"],
  "failed_requirements": [],
  "partially_satisfied": [],
  "out_of_spec_behaviors": [],
  "unimplemented_requirements": [],
  "confidence": 0.91,
  "notes": "All four acceptance criteria satisfied. Fail-open behavior on Redis error is not specified in FUNC-001 but is the appropriate safe default for availability. Recommend noting this in TECH-001 §5.1."
}
```

**Security Verifier (claude-sonnet-4-6, v2.1.0):**
```json
{
  "verdict": "PASS",
  "escalate": false,
  "findings": [
    {
      "severity": "INFO",
      "category": "Defense in depth",
      "location": "src/middleware/rate-limiter.ts:10",
      "quoted_code": "const ip = req.ip ?? 'unknown'",
      "description": "IP-based rate limiting can be bypassed via IP rotation or by attackers behind NAT that share an IP with legitimate users.",
      "recommendation": "Consider adding user-ID-based rate limiting post-authentication for additional protection. This is a known limitation of IP-based approaches and is out of scope for this story per TECH-001 §5.1."
    }
  ]
}
```

**Testing Verifier (claude-sonnet-4-6, v1.1.0):**
```json
{
  "verdict": "PASS",
  "criteria_coverage": {
    "AC-001": "COVERED",
    "AC-002": "COVERED",
    "AC-003": "COVERED",
    "AC-004": "COVERED"
  },
  "missing_test_cases": [],
  "test_quality_issues": [],
  "coverage_notes": "Test for Redis failure (fail-open) is present and meaningful."
}
```

**Architecture Verifier (claude-sonnet-4-6, v1.2.0):**
```json
{
  "verdict": "PASS",
  "adr_violations": [],
  "layer_violations": [],
  "notes": "Middleware correctly placed in middleware/ layer. Redis client imported from lib/ per ADR-003. rate-limiter-flexible used per ADR-007."
}
```

---

#### Step 6: Judge Decision

```json
{
  "decision": "PASS",
  "confidence": 0.91,
  "human_review_recommended": false,
  "blocking_reasons": [],
  "warnings": [
    "Spec verifier noted: fail-open Redis behavior should be documented in TECH-001 §5.1",
    "Security verifier noted: IP rotation bypass — informational, acknowledged limitation"
  ],
  "verifier_summary": {
    "spec_verifier": "PASS",
    "security_verifier": "PASS",
    "test_verifier": "PASS",
    "architecture_verifier": "PASS"
  },
  "revision_guidance": null,
  "escalation_reason": null
}
```

---

#### Step 7: Auto-Generated PR Comment

```markdown
## ✅ VITL Verification Report — STORY-007

**Decision: PASS** | Confidence: 91% | Run: vitl-2024031500042

| Verifier | Version | Verdict | Notes |
|---|---|---|---|
| Spec Verifier | v1.3.0 | ✅ PASS | All FR-012, FR-013 satisfied |
| Security Verifier | v2.1.0 | ✅ PASS | 1 INFO finding |
| Testing Verifier | v1.1.0 | ✅ PASS | All 4 AC covered |
| Architecture Verifier | v1.2.0 | ✅ PASS | ADR-003, ADR-007 respected |

**Deterministic checks:** All passed (94% line coverage)

**Warnings (non-blocking):**
- Spec verifier: fail-open Redis behavior should be documented in TECH-001 §5.1
- Security verifier: IP rotation bypass is a known limitation of IP-based rate limiting

**Recommendation:** Ready for human review. Address TECH-001 documentation note before or
alongside merge.
```

---

#### Step 8: Human Code Review

The reviewer reads the 45-line middleware file and the verification report. They focus on:

1. **Fail-open decision** — Is this the right call? *Yes: login infrastructure should stay available if Redis fails; Redis failure should not take down login.*
2. **Redis key prefix** — Is `'login_fail'` scoped appropriately? *Yes: per TECH-001 Redis key conventions.*
3. **resetLoginRateLimit** — Is it called in the right place in auth.ts? *Reviewer checks auth.ts — yes, called after credential validation succeeds.*

Reviewer approves and opens a spec amendment PR for TECH-001 §5.1 to document the fail-open behavior, as flagged.

---

#### Step 9: Merge

Both PRs (STORY-007 implementation and TECH-001 amendment) are merged. CI runs the full test suite. Deployment pipeline executes.

---

#### Step 10: Post-Deploy Validation

```bash
# Post-deploy smoke test for STORY-007
POST /api/v1/auth/login (bad credentials) × 5 → expect 200 (or 401)
POST /api/v1/auth/login (bad credentials) × 1 more → expect 429 with Retry-After
POST /api/v1/auth/login (good credentials) → expect 200 (counter reset)
POST /api/v1/auth/login (bad credentials) × 5 → expect 200 (or 401) (counter was reset)
POST /api/v1/auth/login (bad credentials) × 1 more → expect 429

All assertions pass. Monitoring alert configured for spike in 429s on /auth/login.
```

---

## Part 14 — Templates

### Template 1: Verifier Agent Configuration

```yaml
# .ai/agents/[verifier-name].yaml

name: spec-verifier
version: "1.3.0"
description: "Verifies implementation against functional spec and acceptance criteria"

model: claude-sonnet-4-6
temperature: 0.1
max_tokens: 2000
timeout_seconds: 60

prompt_file: .ai/prompts/verifiers/spec-verifier/system.md
output_schema_file: .ai/prompts/verifiers/spec-verifier/output-schema.json

required_inputs:
  - story
  - functional_spec_sections
  - implementation

optional_inputs:
  - existing_tests

blocking: true
escalate_on: []
fail_on_verdict: ["FAIL"]
warn_on_verdict: ["PARTIAL"]

# Conditional execution
condition: null  # null = always run
# condition: "files_changed_match: src/api/"  # example conditional
```

---

### Template 2: Verification Report

```markdown
# Verification Report — [STORY-ID]

**Generated:** YYYY-MM-DD HH:MM:SS UTC
**Pipeline run:** [run-id]
**Branch:** [branch-name]
**Commit:** [sha]

## Decision: [PASS | FAIL | ESCALATE]
**Confidence:** [0.0–1.0]
**Human review recommended:** [yes | no]

## Verifier Summary

| Verifier | Version | Verdict | Confidence | Key Finding |
|---|---|---|---|---|
| Spec Verifier | [v] | [verdict] | [score] | [one-liner] |
| Security Verifier | [v] | [verdict] | [score] | [one-liner] |
| Testing Verifier | [v] | [verdict] | [score] | [one-liner] |
| Architecture Verifier | [v] | [verdict] | [score] | [one-liner] |

## Blocking Issues

[Populate only if decision is FAIL or ESCALATE]

### Issue 1: [Short title]
- **Verifier:** [verifier name]
- **Severity:** [HIGH | CRITICAL]
- **Requirement:** [FR/AC reference]
- **Finding:** [specific finding]
- **Quoted evidence:** `[exact code or spec text]`
- **Required action:** [what the coder must do, specifically]

## Warnings (Non-blocking)

- [Warning 1]
- [Warning 2]

## Deterministic Check Results

| Check | Result | Detail |
|---|---|---|
| Linting | ✅ PASS | 0 errors, 0 warnings |
| Type checking | ✅ PASS | |
| Unit tests | ✅ PASS | N tests passed |
| Coverage | ✅ PASS | N% lines |
| Secret scan | ✅ PASS | |
| Dependency audit | ✅ PASS | |

## Revision History

| Cycle | Decision | Primary Finding |
|---|---|---|
| 1 | [decision] | [one-liner] |
| 2 | [decision] | [one-liner] |

---
*VITL Pipeline v[version] | Prompts: spec-verifier v[N], security-verifier v[N]*
```

---

### Template 3: Decision Log (Audit Trail)

```jsonl
{"run_id":"vitl-20240315-00042","timestamp":"2024-03-15T14:12:00Z","story_id":"STORY-007","stage":"spec-verifier","actor":"claude-sonnet-4-6","decision":"PASS","evidence":{"confidence":0.91,"requirements_checked":["FR-012","FR-013"]},"prompt_version":"spec-verifier-v1.3.0"}
{"run_id":"vitl-20240315-00042","timestamp":"2024-03-15T14:12:03Z","story_id":"STORY-007","stage":"security-verifier","actor":"claude-sonnet-4-6","decision":"PASS","evidence":{"findings":[{"severity":"INFO","category":"Defense in depth"}]},"prompt_version":"security-verifier-v2.1.0"}
{"run_id":"vitl-20240315-00042","timestamp":"2024-03-15T14:12:05Z","story_id":"STORY-007","stage":"judge","actor":"claude-sonnet-4-6","decision":"PASS","evidence":{"confidence":0.91},"prompt_version":"judge-v1.5.0"}
{"run_id":"vitl-20240315-00042","timestamp":"2024-03-15T14:22:11Z","story_id":"STORY-007","stage":"human-review","actor":"@engineer","decision":"APPROVED","evidence":{"pr":1234,"comment":"Fail-open rationale confirmed"}}
{"run_id":"vitl-20240315-00042","timestamp":"2024-03-15T14:23:45Z","story_id":"STORY-007","stage":"merge","actor":"github-actions","decision":"MERGED","evidence":{"commit":"abc1234","branch":"main"}}
```

---

### Template 4: Review Checklist (for Human Reviewers)

```markdown
# Code Review Checklist — VITL Workflow

## Before reviewing the code

- [ ] Read the verification report attached to this PR
- [ ] Note any warnings (non-blocking) the reviewer should be aware of
- [ ] Check the judge confidence score — if < 0.80, spend more time on review

## Spec compliance (already verified — sanity check only)

- [ ] The implementation matches the story's acceptance criteria
- [ ] No features were added beyond what the spec describes

## What automated verification does NOT check (focus here)

- [ ] Business logic correctness — does this actually solve the problem?
- [ ] Team knowledge sharing — is this approach the team would use?
- [ ] Future maintainability — will the next engineer understand this?
- [ ] Edge cases not covered by acceptance criteria
- [ ] Performance under realistic load (if not in perf verifier scope)

## Final sign-off

- [ ] Verification report shows PASS or ESCALATE with justification
- [ ] All blocking items from verification have been addressed
- [ ] Non-blocking warnings have been reviewed and accepted or actioned
- [ ] Spec amendment PR merged or linked (if behavior changed)
```

---

### Template 5: Risk Assessment

```markdown
# Risk Assessment — [STORY-ID]

**Risk level:** [LOW | MEDIUM | HIGH | CRITICAL]

## Blast radius
[What does this change affect? Which user flows, services, or data?]

## Reversibility
- [ ] REVERSIBLE — rollback without data migration
- [ ] PARTIALLY_REVERSIBLE — rollback requires minor migration
- [ ] IRREVERSIBLE — data changes cannot be undone

## Rollout recommendation
- [ ] Direct release to all users
- [ ] Feature flag recommended — release to N% initially
- [ ] Staged rollout (10% → 50% → 100%)
- [ ] Requires scheduled maintenance window

## Post-deploy monitoring
| Metric | Alert threshold | Dashboard |
|---|---|---|
| [metric] | [threshold] | [link] |

## Rollback plan
1. [Step to revert]
2. [Step to verify rollback succeeded]
3. [Communication steps]
```

---

### Template 6: CI Pipeline Configuration Snippet

```yaml
# .github/workflows/verifier-pipeline.yml (minimal version)
name: VITL

on:
  pull_request:
    branches: [main]

jobs:
  deterministic:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm' }
      - run: npm ci
      - run: npm run lint
      - run: npm run typecheck
      - run: npm test -- --coverage --coverageThreshold='{"global":{"lines":80}}'
      - uses: gitleaks/gitleaks-action@v2

  llm-verify:
    needs: deterministic
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }
      - uses: actions/setup-python@v5
        with: { python-version: '3.11' }
      - run: pip install anthropic pyyaml
      - name: Run VITL pipeline
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          STORY=$(echo "${{ github.event.pull_request.title }}" | grep -oP 'STORY-\d+')
          [ -n "$STORY" ] && python .ai/scripts/run-verifiers.py --story "$STORY"
```


---

## Part 15 — Future Directions

### Establishing the Baseline

Before discussing what is emerging, it is important to characterize what is currently **established** versus what is **experimental**. This section uses explicit labels:

- **`[Widely Adopted]`** — Production use, documented, tooling available today
- **`[Increasing Adoption]`** — Established in research, appearing in production pipelines
- **`[Active Research]`** — Studied, limited production tooling, not yet standard practice
- **`[Early / Experimental]`** — Research stage, speculative for production use

---

### LLM-as-a-Judge `[Increasing Adoption]`

LLM-as-a-Judge uses a large language model as the evaluation function for another model's output. In VITL terms, this is the Judge role described throughout this handbook.

**What is established:**
- Using a separate model to evaluate generated outputs is demonstrably more reliable than self-review
- Structured output formats (JSON verdict + rationale) improve consistency
- Using a larger or differently-configured model as the judge improves decision quality

**Known weaknesses** (from published research [Inference — documented in LLM evaluation literature, specific numbers vary by study]):
- **Position bias:** Judges can prefer outputs placed first in the prompt
- **Verbosity bias:** Judges can favor longer, more elaborate responses
- **Self-preference:** Models may subtly favor outputs from their own model family
- **Confidence miscalibration:** Stated confidence scores may not accurately reflect reliability

**Practical mitigations in use today:**
- Swap ordering: evaluate the same pair in both orderings and check for consistency
- Use a different model family for the judge than for the coder when possible
- Calibrate confidence scores against known ground truth before relying on automated routing
- Require evidence quotation (as described in Part 7) to reduce hallucinated rationales

**Where this is going:** Judge model quality is improving as frontier model capabilities improve. The primary open problem is calibration — getting judges to accurately represent their own uncertainty.

---

### Process Reward Models (PRMs) `[Active Research]`

A Process Reward Model is a model trained to assign a reward signal to *intermediate steps* in a reasoning or generation process, not just to the final output. In code generation, a PRM could evaluate whether each step of an implementation plan is sound before any code is written.

**What is established:** PRMs have demonstrated meaningful improvements in mathematical reasoning tasks (particularly in competitive math, where the reasoning chain is explicit and verifiable). The OpenAI o1/o3 series and similar models use forms of this internally [Inference — based on published technical reports, not confirmed implementation details].

**Current state for code generation:** Applying PRMs to multi-step code generation is an active research area. Fine-tuning a PRM requires substantial labeled training data (correct and incorrect intermediate steps), which most engineering teams cannot produce at scale.

**Relevance to VITL:** PRMs represent a potential future replacement for or complement to LLM-based verifiers — a model specifically trained to identify when a coding agent's reasoning is going wrong at each step, rather than only at the end. [Speculation — the tooling for this does not yet exist as an off-the-shelf component for most teams]

**Practical approximation available now:** The Planner agent (Part 4, Stage 3) approximates PRM behavior by evaluating the implementation plan before coding begins. This is a manual, prompt-based version of the same idea.

---

### Outcome Reward Models (ORMs) `[Active Research]`

An Outcome Reward Model is trained to predict whether a final output is correct, by training on (output, label) pairs where the label indicates correctness. In code generation, an ORM could predict whether a code submission will pass tests — potentially before running the tests.

**Current state:** ORMs trained on code correctness prediction exist in research settings (e.g., trained on competitive programming problems where ground truth is available). They are not yet widely available as off-the-shelf components.

**Limitation:** Code correctness is highly context-dependent. An ORM trained on competitive programming does not transfer directly to production application code, which has different correctness criteria (spec compliance, security, style, architecture) rather than a single pass/fail test oracle.

**Relevance to VITL:** ORMs could accelerate the verification layer by filtering out clearly incorrect implementations before more expensive LLM verifiers run. [Speculation — not yet practical for most teams without significant ML infrastructure]

---

### Tree Search / MCTS-Style Planning `[Active Research → Early Adoption]`

Techniques inspired by Monte Carlo Tree Search (MCTS) apply branching exploration to generation: produce multiple candidate outputs, evaluate each, expand the most promising branches, backtrack from dead ends. This is computationally expensive but can produce higher-quality outputs on complex tasks.

**What is established:** Models like AlphaCode 2 and internal systems at major AI labs use search-based approaches over code candidates. OpenAI o1/o3 and Anthropic's extended thinking models perform multi-step internal reasoning that has properties similar to search, though the implementation details are not fully public [Inference].

**Practical approximation available now — generate-N-and-verify:**

```python
import asyncio
import anthropic

async def generate_and_select_best(
    spec: str,
    story: str,
    n_candidates: int = 3
) -> str:
    """
    Generate N candidate implementations, verify each,
    return the one with the highest verification confidence.
    A practical approximation of search-based generation.
    """
    client = anthropic.AsyncAnthropic()

    # Generate N candidates in parallel
    generation_tasks = [
        client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=4000,
            temperature=0.3,  # Slight variation across candidates
            system=open(".ai/prompts/coder/system.md").read(),
            messages=[{"role": "user", "content": f"SPEC:\n{spec}\n\nSTORY:\n{story}"}]
        )
        for _ in range(n_candidates)
    ]
    candidates = await asyncio.gather(*generation_tasks)
    implementations = [c.content[0].text for c in candidates]

    # Verify each candidate
    verification_tasks = [
        run_spec_verifier(spec, impl, story)
        for impl in implementations
    ]
    verdicts = await asyncio.gather(*verification_tasks)

    # Select the best (highest confidence among passing candidates)
    passing = [
        (impl, v) for impl, v in zip(implementations, verdicts)
        if v.get("verdict") in ("PASS", "PARTIAL")
    ]
    if passing:
        best_impl, best_verdict = max(passing, key=lambda x: x[1].get("confidence", 0))
        return best_impl

    # No passing candidate — return the one with highest confidence for revision
    best_impl, _ = max(
        zip(implementations, verdicts),
        key=lambda x: x[1].get("confidence", 0)
    )
    return best_impl
```

**When this is worth the cost:** For complex algorithmic implementations or high-stakes changes where the cost of revision cycles exceeds the cost of N initial generations. Not cost-effective for routine feature work.

---

### Verifier Ensembles `[Experimental]`

Rather than a single verifier per dimension, an ensemble runs multiple verifier instances (possibly with different prompts, temperatures, or models) and aggregates their votes. The ensemble verdict is more robust to individual verifier failure modes.

**Aggregation approaches:**

| Approach | Rule | When to use |
|---|---|---|
| Majority vote | PASS if ≥ 2/3 verifiers say PASS | General use — balanced |
| Unanimous pass | PASS only if all verifiers agree | High-stakes, security-critical |
| Skeptical | FAIL if any verifier says FAIL | Maximum sensitivity |
| Weighted | Weight verifiers by historical accuracy | When evaluation data exists |

**Example implementation:**

```python
async def ensemble_verify(
    spec: str,
    implementation: str,
    story: str,
    n_ensemble: int = 3
) -> dict:
    """
    Run N verifier instances with slight prompt variation.
    Aggregate by majority vote.
    """
    base_prompt = open(".ai/prompts/verifiers/spec-verifier/system.md").read()

    # Slightly varied prompts for ensemble diversity
    prompts = [
        base_prompt,
        base_prompt + "\n\nBe especially attentive to edge cases and error handling.",
        base_prompt + "\n\nPay particular attention to what the spec explicitly excludes."
    ]

    tasks = [
        run_verifier_with_prompt(prompt, spec, implementation, story)
        for prompt in prompts[:n_ensemble]
    ]
    verdicts = await asyncio.gather(*tasks)

    pass_count = sum(1 for v in verdicts if v["verdict"] == "PASS")
    fail_count = sum(1 for v in verdicts if v["verdict"] == "FAIL")

    # Majority vote
    majority_verdict = "PASS" if pass_count > fail_count else "FAIL"
    avg_confidence = sum(v.get("confidence", 0.5) for v in verdicts) / len(verdicts)

    return {
        "verdict": majority_verdict,
        "confidence": avg_confidence,
        "ensemble_votes": {"pass": pass_count, "fail": fail_count},
        "individual_verdicts": verdicts
    }
```

**Tradeoff:** N× the cost per verifier dimension. Warranted only for very high-stakes decisions (security-critical changes, financial logic, irreversible data operations). [Experimental — reliability gains over single verifier need to be validated per domain]

---

### Constitutional AI Applied to Code `[Active Research]`

Constitutional AI (CAI) trains models to evaluate outputs against a set of principles ("the constitution") and revise them to comply. Applied to code generation, a "code constitution" could define properties that all generated code must satisfy before submission.

**Example code constitution:**

```markdown
## Code Constitution — Article Set

Article 1: No user input shall be used in a database query without
           parameterization or an ORM-provided abstraction.

Article 2: No authentication secret, token, or credential shall appear
           in log output at any log level.

Article 3: All public API endpoints shall require authentication unless
           explicitly marked public in the OpenAPI spec.

Article 4: No function shall silently swallow errors — all catch blocks
           must either log the error or re-throw it.

Article 5: No dependency shall be added that is not approved in an ADR
           or already present in the codebase.
```

**Current state:** CAI as a training technique (fine-tuning models to follow a constitution) is not accessible for most teams. However, the principle — explicit, numbered rules that the model evaluates its output against — is directly applicable as a prompt engineering technique.

**Practical implementation today:**

```markdown
# Add to coder system prompt

## Code constitution
Before submitting your implementation, evaluate it against each article below.
If any article is violated, revise before submitting.

Article 1: No user input in raw SQL queries (use ORM or parameterized queries)
Article 2: No secrets in log output
Article 3: All API endpoints require auth unless spec marks them public
Article 4: No silent error swallowing — catch blocks must log or re-throw
Article 5: No new dependencies not in the codebase or approved in ADRs

For each article: state [SATISFIED] or [VIOLATED: description] before submitting.
```

This is a structured self-review against explicit rules — more reliable than unstructured self-review (see Part 1), but less reliable than independent verification.

---

### Model Context Protocol (MCP) `[Widely Adopted — integration with VITL is emerging]`

MCP is Anthropic's open protocol for connecting AI agents to external tools and data sources in a standardized way. MCP servers expose tools that agents can call during a session.

**Current VITL-relevant MCP servers available:**
- GitHub MCP: read PRs, issues, file contents, commit history
- Database MCP servers: query schemas directly
- File system MCP: read repository structure
- Custom internal MCP servers: connect to your issue tracker, spec system, or monitoring

**How MCP enhances VITL verifiers:**

```
# Without MCP: verifier receives spec content pasted into prompt
# With MCP: verifier can fetch the current spec, DB schema, and PR diff directly

Spec Verifier with MCP:
→ Calls github_mcp.get_file("specs/functional/FUNC-001.md") to get current spec
→ Calls github_mcp.get_pr_diff(pr_number) to get the actual implementation diff
→ Calls database_mcp.get_schema() to verify DB usage against current schema
→ Evaluates with fully current, authoritative inputs rather than pasted snapshots
```

**Near-term opportunity:** Building MCP servers for your spec and task systems makes context assembly automatic. The verifier always receives the current, authoritative spec rather than a potentially stale pasted version. This directly addresses spec drift.

**Building a custom spec MCP server:**

```python
# Example: MCP server that exposes spec files
from mcp.server import Server
from mcp.types import Tool, TextContent
import json
from pathlib import Path

app = Server("spec-server")

@app.tool()
async def get_spec(spec_id: str) -> list[TextContent]:
    """Fetch a specification document by ID (e.g., 'FUNC-001')"""
    spec_file = Path(f"specs/functional/{spec_id}.md")
    if not spec_file.exists():
        return [TextContent(type="text", text=f"Spec {spec_id} not found")]
    return [TextContent(type="text", text=spec_file.read_text())]

@app.tool()
async def get_story(story_id: str) -> list[TextContent]:
    """Fetch a story document by ID (e.g., 'STORY-007')"""
    story_file = Path(f"tasks/stories/{story_id}.md")
    if not story_file.exists():
        return [TextContent(type="text", text=f"Story {story_id} not found")]
    return [TextContent(type="text", text=story_file.read_text())]

@app.tool()
async def list_specs(prefix: str = "") -> list[TextContent]:
    """List all available spec IDs, optionally filtered by prefix"""
    specs = [f.stem for f in Path("specs").rglob("*.md") if prefix in f.stem]
    return [TextContent(type="text", text=json.dumps(specs))]
```

---

### Formal Methods Integration `[Active Research]`

Formal verification uses mathematical proof to establish that a program satisfies a specification. Tools like TLA+, Coq, Isabelle, Lean, and Dafny have been used in high-assurance systems (aerospace, cryptography, operating systems) for decades.

**Current state of LLM + formal methods:**
- LLMs can generate TLA+ or Lean proofs for simple algorithms [Active Research]
- LLMs can help write Dafny contracts that are then formally verified [Active Research]
- Generating correct formal proofs for non-trivial programs remains unreliable [Inference]

**Practical availability today:** For most engineering teams building web applications, formal methods integration is not yet practical. The tooling requires significant domain expertise and the proof generation reliability of current LLMs is insufficient for production use in non-trivial programs.

**Where it may matter:** Cryptographic implementations, consensus algorithms, financial calculation logic — areas where a bug is catastrophic and the specification can be expressed formally. In these domains, formal verification as a final gate (after all VITL checks) is worth exploring. [Experimental for general use]

---

### Reflection Loops `[Increasing Adoption]`

Reflection loops ask the generating model to explicitly critique its own output before submitting it, using a structured critique prompt rather than a free-form review.

**Distinction from self-review (Part 1):** Structured reflection with explicit criteria is more reliable than unstructured self-review, though still less reliable than independent verification. It is best understood as a pre-filter that reduces the rate of obvious errors before independent verification.

**Structured reflection pattern:**

```
After generating your implementation, answer these questions before submitting:

1. Does every acceptance criterion have at least one test? [YES/NO — list each AC]
2. Did you add any functionality not described in the spec? [YES/NO — list any additions]
3. Did you use any library not in the codebase or ADRs? [YES/NO — list any new dependencies]
4. Does every public function have a documentation comment? [YES/NO — list any missing]

If any answer is NO, revise before submitting.
```

**Appropriate use:** As a first pass before the verifier layer — a cheap, fast filter that reduces obvious errors before expensive LLM verifiers run. Not a replacement for independent verification.

---

### Long-Horizon Autonomous Agents `[Early / Experimental for complex tasks]`

Long-horizon autonomous agents — capable of independently planning, implementing, verifying, and iterating across an entire epic without human checkpoints — are an active development frontier.

**Current capabilities** [Inference — based on published benchmarks and documented agent behavior, subject to rapid change]:
- Well-scoped, single-file tasks: high reliability
- Multi-file feature implementation: moderate reliability with verification
- Multi-story epic implementation: low reliability without frequent human checkpoints
- Full product feature with novel architecture decisions: not yet production-ready

**Current limitations:**
- Context management across many hours of work accumulates errors
- Error recovery (an agent that digs itself into a hole over many steps) is unreliable
- The longer the autonomous run, the harder human oversight becomes

**How VITL fits the long-horizon future:** As agent reliability improves, the human checkpoints in the VITL pipeline can be relaxed. Today, human review happens at every story boundary. In the future, human review may happen at feature or epic boundaries. The verification infrastructure — verifiers, judges, audit logs — remains valuable regardless of autonomy level. The checkpoints move; the verification discipline does not.

> **Recommendation:** Do not remove human oversight checkpoints before the verification infrastructure demonstrates sustained reliability in your specific domain. Expand autonomy incrementally, with each expansion justified by measured verifier accuracy. [Essential — applies regardless of how capable agents become]

---

### Summary: Where to Invest Now vs. Later

| Technique | Invest now | Watch | Wait |
|---|---|---|---|
| Hybrid deterministic + LLM verifiers | ✅ Essential | | |
| Planner / Coder / Verifier separation | ✅ Essential | | |
| Judge model with structured output | ✅ Essential | | |
| Verifier prompt versioning + evaluation | ✅ Essential | | |
| MCP-connected verifiers | ✅ Recommended | | |
| Per-story human review gates | ✅ Essential | | |
| Parallel specialist verifiers | ✅ Recommended | | |
| LLM-as-a-Judge with calibration | | ✅ Monitor | |
| Multi-candidate generation + selection | | ✅ Monitor | |
| Structured reflection loops | ✅ Optional now | | |
| Constitutional prompting | ✅ Optional now | | |
| Verifier ensembles (high-stakes only) | | ✅ Monitor | |
| PRM integration | | | ✅ Wait |
| ORM integration | | | ✅ Wait |
| MCTS-style full tree search | | | ✅ Wait |
| Formal methods for general code | | | ✅ Wait |
| Long-horizon autonomous epics | | | ✅ Wait |

---

## Closing Reference: VITL Pipeline Health Checklist

Run this checklist monthly.

```markdown
## VITL Pipeline Health Check

### Verifier accuracy
- [ ] Spec verifier true positive rate: ___% (target > 80%)
- [ ] Security verifier false negative rate: ___% (target < 5%)
- [ ] Testing verifier false positive rate: ___% (target < 10%)
- [ ] Evaluation suite run this month: [ ] passed / [ ] regressions found

### Pipeline reliability
- [ ] Mean time to verification: ___ seconds (target < 60s for simple PRs)
- [ ] Escalation rate: ___% (healthy range: 5–15%)
- [ ] Pipeline bypass rate: ___% (target: 0% for feature PRs)
- [ ] Revision cycle rate: ___% (track trend — should decrease over time)

### Prompt hygiene
- [ ] All verifier prompts reviewed in last 90 days
- [ ] CHANGELOG.md updated for all prompts
- [ ] No embedded spec references that no longer exist

### Spec alignment
- [ ] Spec freshness check run: [ ] all specs current / [ ] stale specs found
- [ ] No verifier prompts reference deprecated spec sections
- [ ] Nightly audit ran without critical findings

### Infrastructure
- [ ] Audit log is intact and append-only
- [ ] Reports are being generated and stored per PR
- [ ] CI pipeline runtime is within acceptable bounds
- [ ] API costs are within budget

### Team feedback
- [ ] Engineers surveyed on verifier quality this quarter
- [ ] False positive log reviewed and prompt updates made
- [ ] False negative log reviewed and mitigations applied
- [ ] Retrospective included at least one VITL improvement item
```

---

*Handbook version: 1.0*
*Companion to: Spec-First Software Development Guide*

*Labeling conventions used throughout:*
*`[Widely Adopted]` — Production use, documented, tooling available*
*`[Increasing Adoption]` — Established in research, appearing in production*
*`[Active Research]` — Studied, limited production tooling*
*`[Early / Experimental]` — Research stage*
*`[Inference]` — Logically reasoned from available evidence; not a controlled claim*
*`[Speculation]` — Possible future direction; not confirmed*

*All LLM behavior claims are labeled where they extend beyond established practices.*
*Pipeline behavior is not guaranteed — validate all approaches against your specific*
*tools, models, context windows, and production environment before relying on them.*