# CMMI: REQM vs RD

## Requirements Management (REQM)

**Purpose:** Manage requirements *after* they've been defined — ensuring alignment and traceability throughout the project.

**Key focus:** Consistency between requirements and project plans/work products.

**Core practices:**
- Obtain understanding and commitment to requirements
- Manage requirement changes
- Maintain bidirectional traceability
- Identify inconsistencies between requirements and project work

**Who drives it:** Project/engineering team receiving requirements from a source (customer, product management, etc.)

---

## Requirements Development (RD)

**Purpose:** *Elicit, analyze, and define* customer, product, and product-component requirements.

**Key focus:** Figuring out *what* the requirements actually are.

**Core practices:**
- Elicit stakeholder needs
- Develop customer requirements
- Develop product and product-component requirements
- Analyze and validate requirements (including against operational concepts)

**Who drives it:** Teams working directly with stakeholders to discover and articulate needs.

---

## Key Distinction

| | REQM | RD |
|---|---|---|
| **Question answered** | Are we following and tracking requirements? | What are the right requirements? |
| **Timing** | Ongoing throughout project | Earlier, requirements definition phase |
| **CMMI maturity level** | Level 2 | Level 3 |
| **Traceability** | Central concern | Part of analysis |
| **Stakeholder elicitation** | Not the focus | Core activity |

---

**In short:** RD is about *creating* requirements; REQM is about *managing* them once they exist. A project can practice REQM on requirements handed to them without ever doing RD themselves.


---

# CMMI: Technical Solution (TS) Explained

## Purpose
Design and implement solutions to requirements — translating *what* is needed (from RD) into *how* it will be built.

---

## Where It Fits

```
RD → defines requirements
REQM → manages/tracks them
TS → designs and builds the solution
```

---

## Core Practice Areas

### 1. Select Technical Solutions
- Evaluate alternative solution approaches
- Select the best solution based on criteria (cost, risk, feasibility)
- Document the rationale for the decision

### 2. Develop the Design
- Create architecture and detailed design
- Use established design principles and standards
- Address product components and their interfaces

### 3. Implement the Design
- Translate design into the actual product (code, hardware, documentation, etc.)
- Follow design standards
- Conduct peer reviews

---

## Key Concepts in TS

| Concept | Meaning |
|---|---|
| **Make/buy/reuse** | Deciding whether to build, purchase, or reuse components |
| **Technical data package** | Documentation describing the design |
| **Interface design** | How components interact with each other |
| **Design criteria** | Standards used to evaluate design alternatives |

---

## CMMI Level
TS is a **Level 3** process area — meaning it requires more organizational maturity than basic project management.

---

## How TS Relates to Other PAs

| Process Area | Feeds Into TS                                   |
| ------------ | ----------------------------------------------- |
| **RD**       | Provides requirements TS must satisfy           |
| **REQM**     | Ensures TS work stays traceable to requirements |
| **VER**      | Verifies that TS outputs meet requirements      |
| **VAL**      | Validates the solution works in real use        |

---

**In short:** TS is the bridge between *knowing what to build* (RD) and *confirming it works* (VER/VAL). It covers the full design and implementation cycle.