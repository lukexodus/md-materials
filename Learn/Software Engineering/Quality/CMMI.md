# CMMI for Software Engineering
---

## 1. Background & Purpose

CMMI was built on an earlier model called **CMM (Capability Maturity Model)**, originally developed in the late 1980s for the U.S. Department of Defense to assess software contractor capability.

The core idea: **the quality of a software system is largely determined by the quality of the process used to build it.**

CMMI doesn't tell you *what* to build — it tells you *how mature and disciplined your engineering processes are.*

---

## 2. The Two Representations

CMMI can be viewed in two ways:

### Staged Representation
- Uses the **5 maturity levels** (most common)
- You progress level by level
- Best for organizations wanting a roadmap

### Continuous Representation
- Uses **capability levels** per individual process area
- You can improve specific processes independently
- Best for organizations targeting specific weaknesses

---

## 3. Process Areas Relevant to Software Engineering

At **Maturity Level 2** (Managed):

| Process Area                                   | What It Covers                                    |
| ---------------------------------------------- | ------------------------------------------------- |
| **Requirements Management (REQM)**             | Managing changes to requirements, traceability    |
| **Project Planning (PP)**                      | Estimating size, effort, schedule                 |
| **Project Monitoring & Control (PMC)**         | Tracking actual vs. planned progress              |
| **Configuration Management (CM)**              | Version control, baselines, change control        |
| **Measurement & Analysis (MA)**                | Defining metrics, collecting and analyzing data   |
| **Process & Product Quality Assurance (PPQA)** | Independent review of processes and work products |
| **Supplier Agreement Management (SAM)**        | Managing third-party/vendor relationships         |

---

At **Maturity Level 3** (Defined):

| Process Area                                | What It Covers                                     |     |
| ------------------------------------------- | -------------------------------------------------- | --- |
| **Requirements Development (RD)**           | Eliciting, analyzing, defining requireme nts       |     |
| **Technical Solution (TS)**                 | Designing and implementing solutions               |     |
| **Product Integration (PI)**                | Assembling components, integration testing         |     |
| **Verification (VER)**                      | Reviews, inspections, testing against requirements |     |
| **Validation (VAL)**                        | Confirming the product meets user needs            |     |
| **Organizational Process Focus (OPF)**      | Assessing and improving org-wide processes         |     |
| **Organizational Process Definition (OPD)** | Building a standard process library                |     |
| **Organizational Training (OT)**            | Identifying and addressing skill gaps              |     |
| **Integrated Project Management (IPM)**     | Using org standards on your project                |     |
| **Risk Management (RSKM)**                  | Identifying, analyzing, mitigating risks           |     |
| **Decision Analysis & Resolution (DAR)**    | Formal evaluation of major decisions               |     |

---

At **Maturity Level 4** (Quantitatively Managed):

| Process Area | What It Covers |
|---|---|
| **Organizational Process Performance (OPP)** | Baselines and models for process performance |
| **Quantitative Project Management (QPM)** | Statistical control of project processes |

---

At **Maturity Level 5** (Optimizing):

| Process Area | What It Covers |
|---|---|
| **Causal Analysis & Resolution (CAR)** | Finding root causes of defects and fixing them |
| **Organizational Innovation & Deployment (OID)** | Piloting and deploying process improvements |

---

## 4. How It Applies to the Software Engineering Lifecycle

### Requirements Phase
- **REQM** requires traceability matrices — every requirement traced to design, code, and test
- **RD** (Level 3) adds formal elicitation and analysis of stakeholder needs

### Design & Architecture
- **Technical Solution (TS)** mandates evaluating alternative solutions, documenting design decisions
- **DAR** formalizes how major architectural decisions are made

### Coding
- **Configuration Management (CM)** covers version control, branching strategies, baselines
- Code reviews are part of **Verification (VER)**

### Testing
- **VER** = verification (are we building it right?) → unit tests, integration tests, inspections
- **VAL** = validation (are we building the right thing?) → acceptance testing, user validation

### Release & Integration
- **Product Integration (PI)** covers how components are assembled, integration order, interface management

### Project Management
- **PP** and **PMC** together form a disciplined planning and tracking loop
- **RSKM** formalizes risk registers and mitigation plans

### Metrics & Measurement
- **MA** defines what to measure (defect density, velocity, test coverage)
- At Level 4, **QPM** applies statistical process control — control charts, process capability indices

---

## 5. Maturity Level Characteristics in Practice

### Level 1 – Initial
- Ad hoc, heroic efforts
- Success depends on individuals, not process
- Unpredictable delivery and quality

### Level 2 – Managed
- Projects are planned with estimates
- Requirements are tracked
- Basic metrics collected
- Repeatable at the **project** level

### Level 3 – Defined
- Organization has a **standard process**
- All projects tailor from this standard
- Lessons learned feed back into the process library
- Repeatable at the **organization** level

### Level 4 – Quantitatively Managed
- Key processes statistically controlled
- Variation is understood and managed
- Predictions about quality and schedule are data-driven

### Level 5 – Optimizing
- Continuous improvement is systematic
- Root cause analysis drives defect prevention
- Innovation is piloted and deployed formally

---

## 6. CMMI Appraisal (How You Get Rated)

The formal appraisal method is called **SCAMPI** (Standard CMMI Appraisal Method for Process Improvement):

| Class | Purpose |
|---|---|
| **SCAMPI A** | Full appraisal → official maturity level rating |
| **SCAMPI B** | Partial appraisal → readiness assessment |
| **SCAMPI C** | Lightweight → gap analysis |

A SCAMPI A is conducted by a certified **Lead Appraiser** and involves document review, interviews, and artifact inspection.

---

## 7. CMMI vs. Agile

A common misconception is that CMMI and Agile conflict. They do not necessarily.

| Aspect | CMMI | Agile |
|---|---|---|
| Focus | Process discipline & measurement | Flexibility & delivery speed |
| Documentation | Emphasizes artifacts | Prefers working software |
| Planning | Detailed upfront | Iterative |
| Compatibility | [Inference] Can be applied together with adaptation | Standalone |

> **[Inference]** Many organizations attempt to combine CMMI process rigor with Agile delivery practices. Whether this succeeds depends heavily on implementation. *Behavior/outcome is not guaranteed.*

---

## 8. Criticisms of CMMI in Software Engineering

- Can become **documentation-heavy** at the expense of actual delivery
- Higher maturity levels are expensive and time-consuming to achieve
- Risk of **"compliance theater"** — following the letter but not the spirit
- Less naturally suited to small teams or startups
- Agile adoption has reduced its dominance in commercial software

---

## Summary Table

| Level | Key Software Engineering Focus |
|---|---|
| 1 | Survival mode |
| 2 | Basic project discipline |
| 3 | Org-wide standardized engineering practices |
| 4 | Data-driven quality control |
| 5 | Systematic innovation and defect prevention |

---

