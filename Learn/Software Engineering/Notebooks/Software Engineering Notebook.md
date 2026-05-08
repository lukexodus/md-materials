# Principles

## CUPID

CUPID is a software engineering framework created by **Daniel Terhorst-North** that prioritizes designing joyful, maintainable code by focusing on properties rather than prescriptive principles.  It serves as a modern alternative to the SOLID principles, emphasizing characteristics that make code a pleasure to work with.[1][2]

CUPID comprises five core properties that guide software design:[3]

### **Composable**
– Plays well with others, featuring a small surface area, clear intentions, and minimal dependencies.  This property encourages designing software as small, independent modules that integrate seamlessly with other components, promoting reusability and scalability.[4][5]

### **Unix Philosophy** 
– Does one thing well, emphasizing that each component should have a focused responsibility.  This draws from the Unix philosophy of simplicity and clarity, distinguishing between single-purpose functionality and broader responsibility.[5][4]

### **Predictable**
– Does what you expect, with deterministic behavior and strong observability.  Software should behave as anticipated, allowing developers to reason about outcomes based on inputs without surprises.[4][5]

### **Idiomatic** 
– Feels natural, conforming to the conventions and established patterns of the programming language or framework being used.  This reduces cognitive load by following language idioms and local conventions that developers recognize and understand.[5][4]

### **Domain-Based**
– Aligns the solution domain with the problem domain through matching language and structure.  The software's design should mirror real-world entities and interactions, making it intuitive for developers familiar with the problem domain.[4][5]

**Properties Over Principles**

A key distinction of CUPID is its shift from prescriptive design principles to descriptive properties.  Rather than rigid rules to follow, properties define goals or centers to move toward, allowing code to be closer or further from the ideal without achieving absolute success or failure.  Developers can use properties as lenses to assess their code and decide which aspects to address next.[2][1][5]

**Design for Joy**

CUPID's foundational philosophy centers on making code joyful to work with, building on Martin Fowler's concept that "good programmers write code that humans can understand."  The framework emphasizes habitability—the characteristic that enables developers to understand a codebase's construction and intentions while changing it comfortably and confidently.[2][5]

Sources
[1] CUPID: for joyful coding | Dan North & Associates Limited https://dannorth.net/blog/cupid-for-joyful-coding/
[2] CUPID Method Explained by Daniel Terhorst-North https://gotopia.tech/articles/250/exploring-the-cupid-method-by-daniel-terhorst-north
[3] CUPID—for joyful coding [alternative to SOLID; 2022] https://www.reddit.com/r/programming/comments/184acow/cupidfor_joyful_coding_alternative_to_solid_2022/
[4] CUPID - Code with Love - by Thiago Bomfim https://devjava.substack.com/p/cupid-code-with-love
[5] Unpacking Dan North's CUPID properties for joyful coding https://infrastructure-as-code.com/posts/cupid-for-infrastructure.html
[6] SOLID, CUPID, GRASP Principles of Object-Oriented Design https://www.boldare.com/blog/solid-cupid-grasp-principles-object-oriented-design/
[7] Why We Need Design Principles Like SOLID, CUPID & ... https://gokhul.hashnode.dev/the-building-blocks-of-software-why-we-need-design-principles-like-solid-cupid-grasp
[8] CUPID - Why every single element of SOLID is wrong https://dev.to/llotz/cupid-why-every-single-element-of-solid-is-wrong-1f6
[9] CUPID — For Joyful Coding in 7 Minutes • Daniel Terhorst- ... https://www.youtube.com/watch?v=sV6UptcmSRA
[10] Why You Should Start Using CUPID and Not SOLID https://dzone.com/articles/why-you-should-start-using-cupid-and-not-solid-to

## SOLID

### **Single Responsibility Principle (SRP)**
– A class should have only one reason to change, meaning it should have a single responsibility or job.  This makes code easier to understand, test, and maintain, as each class focuses on one specific task.[3][4]

### **Open-Closed Principle (OCP)**
– Software entities should be open for extension but closed for modification.  This means you should be able to add new functionality without changing existing code, typically using abstractions like inheritance or interfaces.[3]

### **Liskov Substitution Principle (LSP)**
– Subtypes must be substitutable for their base types without breaking the application. This principle ensures that derived classes can be used interchangeably with their parent classes without causing unexpected behavior.[5][3]

### **Interface Segregation Principle (ISP)**
– Clients should not be forced to depend on interfaces they do not use.  This principle encourages creating smaller, more specific interfaces rather than one large, general-purpose interface.[5][3]

### **Dependency Inversion Principle (DIP)** 
– High-level modules should not depend on low-level modules; both should depend on abstractions.  This decouples components and makes code more flexible and testable.[3][5]

**Purpose and Benefits**

SOLID principles seek to reduce dependencies so that changes in one area of software do not impact others.  They make software more understandable, flexible, scalable, and maintainable over time.  While following SOLID principles may lead to longer and more complex code during development, the investment pays off through easier maintenance, testing, and extension in the long run.[5][3]

Sources
[1] SOLID https://en.wikipedia.org/wiki/SOLID
[2] The SOLID Principles of Object-Oriented Programming ... https://www.freecodecamp.org/news/solid-principles-explained-in-plain-english/
[3] SOLID Principles in Object Oriented Design https://www.bmc.com/blogs/solid-design-principles/
[4] What are SOLID Principles? https://contabo.com/blog/what-are-solid-principles/
[5] What Are SOLID Design Principles https://dev.to/ggorantala/what-are-solid-design-principles-1n22
[6] SOLID Design Principles Explained: Building Better ... https://www.digitalocean.com/community/conceptual-articles/s-o-l-i-d-the-first-five-principles-of-object-oriented-design
[7] SOLID Design Principles in Software Development https://www.freecodecamp.org/news/solid-design-principles-in-software-development/
[8] The SOLID Principles in Software Development https://codefinity.com/blog/The-SOLID-Principles-in-Software-Development
[9] SOLID Design Principles: The Single Responsibility ... https://stackify.com/solid-design-principles/
[10] A Solid Guide to SOLID Principles https://www.baeldung.com/solid-principles

---

# Unorganized

## **Software Engineering Change Management**

---

### What Is It?

Change management in SE is the structured process for requesting, reviewing, approving, implementing, and tracking changes to software systems — code, infrastructure, configuration, or documentation.

---

### Core Goals

- Minimize risk when modifying production systems
- Maintain traceability (who changed what, when, and why)
- Prevent uncoordinated or conflicting changes
- Support rollback if something goes wrong

---

### Key Components

**Change Request (CR)** A formal record describing the proposed change, its rationale, scope, risk, and rollback plan.

**Change Advisory Board (CAB)** A group (technical leads, ops, security, business stakeholders) that reviews and approves high-risk changes.

**Change Types**

- **Standard** — pre-approved, low-risk, routine (e.g., dependency updates)
- **Normal** — goes through full review and approval
- **Emergency** — expedited process for critical incidents or outages

**Version / Configuration Control** Using tools like Git, Terraform, or Ansible to track and manage changes at the code or infrastructure level.

**Testing & Staging Gates** Changes pass through dev → QA → staging → production, with sign-off at each stage.

**Post-Implementation Review (PIR)** After deployment, assess whether the change achieved its goal and whether any issues arose.

---

### Common Frameworks

|Framework|Context|
|---|---|
|ITIL v4|IT service management, enterprise|
|DevOps / GitOps|Developer-driven, continuous delivery|
|SAFe|Scaled agile environments|
|ISO/IEC 20000|IT service standard|

---

### In DevOps Contexts

Modern DevOps shifts change management left — embedding it into CI/CD pipelines via:

- Pull request reviews
- Automated testing gates
- Feature flags for gradual rollouts
- Audit logs and deployment tracking

---

## Configuration Management (CM) in Software Engineering

---

### What Is It?

Configuration Management is the discipline of **identifying, controlling, tracking, and auditing** the state of software and system components throughout their lifecycle. It answers: _What is deployed, where, in what version, and how did it get there?_

---

### Core Concepts

**Configuration Item (CI)** Any artifact under CM control — source code, binaries, config files, infrastructure definitions, documentation, database schemas.

**Baseline** A formally approved snapshot of one or more CIs at a point in time. Serves as a reference for future changes.

**Configuration Control** The process of managing changes to CIs — ensuring only authorized, reviewed changes are applied.

**Configuration Status Accounting** Recording and reporting the state of CIs over time — who changed what, when, and from which version to which.

**Configuration Audit** Verifying that the actual deployed state matches the documented/intended state.

---

### CM in Practice

**Version Control (Source)**

- Git is the de facto standard
- Branching strategies (GitFlow, trunk-based) govern how changes are integrated

**Infrastructure as Code (IaC)**

- Tools: Terraform, Pulumi, AWS CloudFormation
- Infrastructure state is defined in code, versioned, and auditable

**Configuration as Code**

- Tools: Ansible, Chef, Puppet, SaltStack
- System configuration (packages, services, files) is codified and repeatable

**Environment Configuration Management**

- Separating config from code (12-factor app principle)
- Using environment variables, secrets managers (Vault, AWS Secrets Manager), or config services

**Container & Image Management**

- Docker images as immutable, versioned artifacts
- Image registries (Docker Hub, ECR, GCR) as the source of truth for deployed software

---

### CM vs. Change Management

|Aspect|Change Management|Configuration Management|
|---|---|---|
|Focus|_Process_ of making changes|_State_ of what exists|
|Question answered|"How do we change safely?"|"What is deployed and how?"|
|Output|Approvals, audit trails|Baselines, CI records|
|Overlap|CM provides the "what" that change mgmt controls|Change mgmt updates CM records|

They are complementary — change management governs _how_ changes happen; configuration management tracks _what_ the system looks like as a result.

---

### Key Standards & Frameworks

|Standard / Framework|Notes|
|---|---|
|ITIL v4|Defines CM as part of service configuration management|
|IEEE 828|Standard for Software Configuration Management Plans|
|CMMI|Includes CM as a process area|
|ISO/IEC 10007|Guidelines for configuration management|

---

### Common Failure Modes

- **Configuration drift** — actual state diverges from intended state over time
- **Undocumented manual changes** — "cowboy" fixes applied directly to production
- **Snowflake servers** — environments that can't be reproduced because their config wasn't tracked
- **Secret sprawl** — credentials and keys scattered across systems without central control

---

### Modern Best Practices

- Treat **everything as code** — config, infra, pipelines
- Use **immutable infrastructure** — replace rather than patch
- Enforce **GitOps** — Git is the single source of truth; deployments are driven by repo state
- Automate **drift detection** — tools like `terraform plan`, Driftctl, or AWS Config
- Maintain **environment parity** — dev, staging, and prod should be as similar as possible

---

## The 12-Factor App

A methodology for building **software-as-a-service (SaaS) applications** that are portable, scalable, and maintainable. Originally documented by engineers at Heroku.

> Source: [12factor.net](https://12factor.net/) — the canonical reference.

---

### The 12 Factors

---

**I. Codebase** _One codebase tracked in version control, many deploys._

- One app = one repo
- Multiple environments (dev, staging, prod) deploy from the same codebase
- Multiple codebases = distributed system, not a single app

---

**II. Dependencies** _Explicitly declare and isolate dependencies._

- Never rely on implicit system-wide packages
- Declare all dependencies in a manifest (e.g., `requirements.txt`, `package.json`, `Gemfile`)
- Use isolation tools (`virtualenv`, `bundler`, `npm ci`) so no system dependency leaks in

---

**III. Config** _Store config in the environment._

- Config = anything that varies between deploys (credentials, hostnames, ports)
- **Never hardcode config in code or commit it to the repo**
- Use environment variables — not config files checked into version control
- Test: could you open-source the codebase right now without exposing secrets?

---

**IV. Backing Services** _Treat backing services as attached resources._

- Databases, queues, caches, email services = attached resources
- No distinction between local and third-party services
- Swap a local PostgreSQL for an RDS instance by changing a URL — no code change needed

---

**V. Build, Release, Run** _Strictly separate build and run stages._

- **Build** — converts code into an executable bundle
- **Release** — combines build with config for a specific environment
- **Run** — executes the app in the environment
- Releases are immutable and versioned; you can roll back to a prior release

---

**VI. Processes** _Execute the app as one or more stateless processes._

- Processes are stateless and share nothing
- Persistent data lives in a backing service (e.g., a database), not in memory or local disk
- No sticky sessions — session state goes to a datastore like Redis

---

**VII. Port Binding** _Export services via port binding._

- The app is self-contained and exposes its service by binding to a port
- Does not rely on a runtime injection of a web server (e.g., Apache)
- One app can become a backing service for another

---

**VIII. Concurrency** _Scale out via the process model._

- Scale horizontally by adding more processes, not by making one process bigger
- Different workloads run as different process types (web, worker, scheduler)
- Relies on the OS process model, not internal threading

---

**IX. Disposability** _Maximize robustness with fast startup and graceful shutdown._

- Processes start quickly and shut down gracefully on SIGTERM
- Handles unexpected termination without data corruption
- Enables elastic scaling, rapid deployment, and resilience

---

**X. Dev/Prod Parity** _Keep development, staging, and production as similar as possible._

- Minimize the **time gap** — deploy frequently
- Minimize the **personnel gap** — developers involved in deployment
- Minimize the **tools gap** — use the same backing services across environments
- "Works on my machine" is a parity failure

---

**XI. Logs** _Treat logs as event streams._

- The app writes logs to `stdout` only — unbuffered
- The app does not manage log files or routing
- The execution environment captures and routes log streams (e.g., to Splunk, Datadog, CloudWatch)

---

**XII. Admin Processes** _Run admin/management tasks as one-off processes._

- DB migrations, console sessions, one-time scripts = one-off processes
- Run in the same environment and against the same release as the app
- Shipped in the same codebase; avoids ad-hoc manual intervention

---

### Why It Matters

|Problem|12-Factor Response|
|---|---|
|"It works on my machine"|Dev/prod parity (X), Dependencies (II)|
|Secrets in source code|Config in environment (III)|
|Can't scale horizontally|Stateless processes (VI), Concurrency (VIII)|
|Fragile deployments|Build/Release/Run separation (V), Disposability (IX)|
|Hard to debug in production|Logs as streams (XI)|

---

### Relationship to Modern Practices

The 12-factor methodology aligns closely with:

- **Containerization** (Docker) — stateless, port-binding, disposable processes map well to containers
- **Kubernetes** — process model, concurrency, and disposability align with pod design
- **GitOps** — codebase and build/release/run separation
- **Configuration Management** — factor III directly addresses config drift and secrets sprawl

---

## Software Cost Estimation

The process of **forecasting the effort, time, and resources** required to develop a software system. It informs budgeting, scheduling, staffing, and project feasibility decisions.

---

### Why It's Difficult

- Requirements are often incomplete or ambiguous early on
- Software development involves significant unknowns and human factors
- Estimation accuracy improves as the project progresses — but decisions are often made earliest
- [Inference] Optimism bias and external pressure frequently distort estimates — this is widely observed but individual project outcomes vary

---

### Estimation Approaches

---

#### 1. Expert Judgment

Relies on the experience of individuals or groups familiar with similar work.

- **Delphi Method** — multiple experts estimate independently, then reconcile iteratively
- Fast, low overhead
- Highly dependent on estimator experience and availability
- Subject to anchoring and groupthink if not structured properly

---

#### 2. Analogous Estimation

Uses data from **past similar projects** as a basis.

- "This project is similar to Project X, which took 6 months"
- Requires a repository of historical project data
- Accuracy depends on how comparable the reference projects truly are

---

#### 3. Parametric Estimation

Uses **mathematical models** with measurable input variables.

- More structured than analogy-based
- Requires calibration with historical data to be reliable
- Examples covered below (COCOMO, Function Points)

---

#### 4. Bottom-Up Estimation

Decompose the system into small tasks, estimate each, then aggregate.

- Higher accuracy when requirements are well-defined
- Time-consuming to produce
- Common in agile via story point estimation per user story

---

#### 5. Three-Point Estimation (PERT)

For each task, define:

- **O** = Optimistic estimate
- **M** = Most likely estimate
- **P** = Pessimistic estimate

Formula:

```
Expected = (O + 4M + P) / 6
```

Produces a weighted average that accounts for uncertainty. Can be combined with standard deviation for risk analysis.

---

### Algorithmic / Parametric Models

---

#### COCOMO II (Constructive Cost Model)

Developed by Barry Boehm. Estimates effort in **person-months** based on size and cost drivers.

**Basic formula:**

```
Effort (PM) = A × Size^B × ∏ Cost Drivers
```

- **Size** measured in KSLOC (thousands of source lines of code) or function points
- **Cost drivers** include product complexity, team capability, tool use, schedule pressure
- Three sub-models: Early Design, Post-Architecture, Application Composition
- Requires historical calibration for accuracy in a specific organization

---

#### Function Point Analysis (FPA)

Measures software size based on **functional requirements**, not code.

Counts:

- External inputs
- External outputs
- External inquiries
- Internal logical files
- External interface files

Each is weighted by complexity. Produces an **Unadjusted Function Point (UFP)** count, then adjusted by a Value Adjustment Factor (VAF).

- Language-independent
- Applicable early in the lifecycle
- Labor-intensive to count accurately

---

#### Use Case Points (UCP)

Extends function point concepts to **use-case-driven** development.

- Counts actors and use cases, weighted by complexity
- Adjusted for technical and environmental factors
- Common in UML-based or RUP projects

---

#### Story Points (Agile Context)

Relative measure of effort, complexity, and uncertainty per user story.

- Not directly translatable to hours without team velocity data
- Velocity (points completed per sprint) used to forecast delivery
- Accuracy improves over multiple sprints with a stable team

---

### Estimation in the Project Lifecycle

|Phase|Typical Accuracy Range|Common Method|
|---|---|---|
|Concept / Feasibility|±50% or more|Expert judgment, analogy|
|Requirements defined|±25–40%|Function points, COCOMO|
|Architecture complete|±15–25%|Parametric, bottom-up|
|Detailed design|±5–15%|Bottom-up, task-level|

> These ranges are commonly cited in literature (e.g., McConnell's _Software Estimation_) but actual accuracy varies significantly by project and organization. [Unverified as universal — treat as indicative, not guaranteed.]

---

### Common Estimation Pitfalls

- **Hofstadter's Law** — _"It always takes longer than you expect, even when you take into account Hofstadter's Law."_
- **Planning fallacy** — systematic underestimation of time and cost
- **Scope creep** — uncontrolled requirement growth inflates actual cost beyond estimates
- **Padding without transparency** — hidden buffers obscure real uncertainty
- **Estimating under pressure** — external deadlines distort technical judgment
- **Confusing effort with duration** — 10 person-months ≠ 1 month with 10 people (Brooks's Law)

---

### Brooks's Law

From _The Mythical Man-Month_ (Fred Brooks, 1975):

> _"Adding manpower to a late software project makes it later."_

New team members require onboarding time and increase communication overhead, which can reduce overall throughput in the short term.

---

### Estimation vs. Planning

||Estimation|Planning|
|---|---|---|
|Purpose|Predict likely outcome|Define intended outcome|
|Nature|Probabilistic|Prescriptive|
|Output|Range or distribution|Schedule, budget, milestones|
|Risk|Underestimation bias|Overcommitment|

Estimates should inform plans — not be reverse-engineered from them.

---

### Key References

- _Software Estimation: Demystifying the Black Art_ — Steve McConnell
- _The Mythical Man-Month_ — Fred Brooks
- COCOMO II model — USC Center for Systems and Software Engineering
- IFPUG (International Function Point Users Group) — FPA standards

---

## COCOMO II — Constructive Cost Model

Developed by **Barry Boehm** at the University of Southern California. COCOMO II is an algorithmic software cost estimation model that predicts **effort, schedule, and cost** based on software size and a set of calibrated factors.

> Primary reference: Boehm et al., _Software Cost Estimation with COCOMO II_ (2000), Prentice Hall.

---

### Evolution of COCOMO

|Version|Year|Notes|
|---|---|---|
|COCOMO 81|1981|Original model, SLOC-based, three modes|
|COCOMO II|1995–2000|Revised for modern processes, multiple sizing methods, richer drivers|

COCOMO II was redesigned to address development paradigms that did not exist in 1981 — object-oriented development, rapid prototyping, reuse-driven development, and COTS (commercial off-the-shelf) integration.

---

### Three Sub-Models

COCOMO II is not a single formula — it has three sub-models applied at different lifecycle stages.

---

#### 1. Application Composition Model

- Used during **early prototyping** and feasibility
- Size measured in **Object Points** (screens, reports, 3GL components)
- Addresses projects built largely from reusable components or COTS
- Produces a rough early estimate

---

#### 2. Early Design Model

- Used when **requirements are defined** but architecture is not yet set
- Size measured in **Function Points** (converted to KSLOC if needed)
- Uses 7 aggregate cost drivers (collapsed from the full set)
- Suitable for feasibility and early planning

---

#### 3. Post-Architecture Model

- Used after **architecture is established**
- Most detailed and accurate sub-model
- Size in **KSLOC** (thousands of source lines of code) or converted function points
- Uses 17 cost drivers and 5 scale factors
- This is the most commonly referenced COCOMO II formulation

---

### Core Formula — Post-Architecture Model

```
Effort (PM) = A × Size^E × ∏ EM_i

Schedule (TDEV) = B × Effort^F
```

Where:

|Symbol|Meaning|
|---|---|
|`PM`|Person-months of effort|
|`A`|Calibration constant (default: **2.94**)|
|`Size`|Software size in KSLOC|
|`E`|Scaling exponent (derived from scale factors)|
|`EM_i`|Effort multipliers (cost drivers, 17 total)|
|`B`|Schedule calibration constant (default: **3.67**)|
|`F`|Schedule scaling exponent|

---

### Scale Factors (SF) — Determining the Exponent E

The exponent `E` captures **economies or diseconomies of scale**.

```
E = B_constant + 0.01 × Σ SF_i
```

Where `B_constant = 0.91` (post-architecture default).

There are **5 scale factors**, each rated on a 6-point scale (Very Low to Extra High, mapped to numeric values 0–5 approximately):

|#|Scale Factor|What It Measures|
|---|---|---|
|SF1|**PREC** — Precedentedness|How familiar the team is with this type of project|
|SF2|**FLEX** — Development Flexibility|Degree of flexibility in process and requirements|
|SF3|**RESL** — Architecture/Risk Resolution|Thoroughness of risk analysis and architecture|
|SF4|**TEAM** — Team Cohesion|How well the team works together|
|SF5|**PMAT** — Process Maturity|CMMI-based process maturity level|

- Lower scale factor ratings → higher exponent → **diseconomies of scale** (larger projects cost disproportionately more)
- Higher ratings → exponent approaches 1.0 → more linear scaling

---

### Effort Multipliers (EM) — Cost Drivers

17 cost drivers adjust the base estimate. Each is rated and mapped to a multiplier value. Ratings below nominal reduce effort; above nominal increase it.

Grouped into four categories:

#### Product Factors

|Driver|Description|
|---|---|
|RELY|Required software reliability|
|DATA|Database size relative to program size|
|CPLX|Product complexity|
|RUSE|Required reusability|
|DOCU|Documentation requirements|

#### Platform Factors

|Driver|Description|
|---|---|
|TIME|Execution time constraint|
|STOR|Main storage constraint|
|PVOL|Platform volatility|

#### Personnel Factors

|Driver|Description|
|---|---|
|ACAP|Analyst capability|
|PCAP|Programmer capability|
|PCON|Personnel continuity|
|APEX|Application experience|
|PLEX|Platform experience|
|LTEX|Language and tool experience|

#### Project Factors

|Driver|Description|
|---|---|
|TOOL|Use of software tools|
|SITE|Multisite development|
|SCED|Required development schedule|

> Personnel factors tend to have the **largest impact** on the effort multiplier product. This is consistent with COCOMO II literature but [Inference] actual impact varies by project context.

---

### Worked Example (Simplified)

**Scenario:** A 100 KSLOC project with nominal cost drivers and scale factors.

Assume:

- All scale factors rated nominal → SF sum ≈ 13.5
- E = 0.91 + 0.01 × 13.5 = **1.045**
- All effort multipliers = 1.0 (nominal) → ∏EM = 1.0
- A = 2.94

```
Effort = 2.94 × 100^1.045 × 1.0
       = 2.94 × 111.2
       ≈ 327 person-months
```

**Schedule:**

- F ≈ 0.28 + 0.2 × (E − B_constant) ≈ 0.31
- TDEV = 3.67 × 327^0.31 ≈ 3.67 × 6.1 ≈ **22.4 months**

> [Unverified as exact — this is illustrative. Actual outputs depend on precise rating-to-value mappings from the calibrated model. Do not use for real project estimation without proper tooling and calibration.]

---

### Size Input Options

COCOMO II accepts multiple size measures:

|Measure|Description|
|---|---|
|**KSLOC**|Thousands of source lines of code (new + modified)|
|**Function Points**|Converted to KSLOC using language-specific ratios (backfiring)|
|**Object Points**|Used in Application Composition sub-model|

**SLOC counting rules matter** — logical vs. physical lines, blank lines, comments, and auto-generated code must be handled consistently. COCOMO II uses **logical SLOC**.

---

### Reuse and Maintenance Extensions

COCOMO II includes formulas for:

**Equivalent Size (ESLOC)** — accounts for reused code that is modified:

```
ESLOC = ASLOC × (AT/100) + ASLOC × (1 - AT/100) × AAM
```

Where `AT` = percentage auto-translated, `AAM` = adaptation adjustment multiplier.

**Software Maintenance Model** — estimates annual maintenance effort as a function of the annual change traffic (ACT) relative to the base system size.

---

### Calibration

COCOMO II's default constants (A = 2.94, B = 3.67) were derived from a dataset of historical projects. For organizational accuracy:

- Collect historical project data (actual effort, size, drivers)
- Recalibrate constants A and B to fit your organization's context
- Without calibration, estimates may be systematically biased for your environment

> [Inference] Uncalibrated COCOMO II applied to a new organization or domain is likely to produce estimates with significant error. Calibration is widely recommended in the literature but actual improvement varies.

---

### Limitations

- SLOC is difficult to estimate early and varies by language and counting method
- Model assumes a structured, document-driven process — less naturally suited to highly iterative or agile methods
- Requires calibration to be reliable in a specific organizational context
- Does not model all modern cost factors (e.g., cloud infrastructure costs, DevOps toolchain overhead)
- [Inference] Accuracy degrades significantly when project characteristics differ substantially from the calibration dataset

---

### Tools

|Tool|Notes|
|---|---|
|**COSTAR**|Commercial COCOMO II tool|
|**USC COCOMO II Tool**|Reference implementation from USC|
|**SEER-SEM**|Parametric model with COCOMO II compatibility|
|**TruePlanning**|Commercial parametric estimation platform|

---

### Relationship to Other Topics

- Feeds into **software cost estimation** as a parametric method
- Size inputs (function points, SLOC) connect to **measurement and metrics**
- Scale factors (especially PMAT) link to **CMMI process maturity**
- Used alongside **three-point estimation** and **expert judgment** for validation

---

## COCOMO II Computation Cheatsheet

---

### Core Formulas

```
Effort (PM)  = A × Size^E × ∏EM

Schedule (TDEV) = B × Effort^F

Staff (People) = Effort / TDEV
```

|Constant|Default Value|
|---|---|
|A|2.94|
|B|3.67|

---

### Exponent E (from Scale Factors)

```
E = 0.91 + 0.01 × Σ(SF₁ + SF₂ + SF₃ + SF₄ + SF₅)
```

**Scale Factor Rating → Value**

|Rating|Value|
|---|---|
|Very Low|6.20 – 4.96 (varies per SF)|
|Low|4.96 – 3.72|
|Nominal|3.72 – 2.48|
|High|2.48 – 1.24|
|Very High|1.24 – 0.00|
|Extra High|0.00|

> Exact values per scale factor differ — consult the COCOMO II model definition document. These are approximate bands. [Unverified as exact without the reference table.]

---

### Exponent F (Schedule)

```
F = 0.28 + 0.2 × (E − 0.91)
```

---

### Step-by-Step

```
1. Determine Size      → KSLOC (new + modified)
2. Rate 5 Scale Factors → sum them → compute E
3. Rate 17 Cost Drivers → look up each EM value → multiply all together
4. Compute Effort       → 2.94 × Size^E × ∏EM
5. Compute Schedule     → 3.67 × Effort^F
6. Compute Staff        → Effort ÷ TDEV
```

---

### Quick Example

|Input|Value|
|---|---|
|Size|50 KSLOC|
|Σ SF|15 (all nominal)|
|∏ EM|1.0 (all nominal)|

```
E     = 0.91 + 0.01 × 15  = 1.06
F     = 0.28 + 0.2 × 0.15 = 0.31

Effort = 2.94 × 50^1.06 × 1.0
       = 2.94 × 58.9
       ≈ 173 PM

TDEV  = 3.67 × 173^0.31
       = 3.67 × 5.5
       ≈ 20.2 months

Staff = 173 ÷ 20.2 ≈ 8.6 people
```

> [Unverified as exact — illustrative only. Do not use for real estimation without calibrated tooling and proper driver ratings.]

---

### EM Quick Reference — Nominal = 1.00

|Driver|Below Nominal|Nominal|Above Nominal|
|---|---|---|---|
|RELY|< 1.00|1.00|> 1.00|
|CPLX|< 1.00|1.00|> 1.00|
|ACAP|> 1.00|1.00|< 1.00|
|PCAP|> 1.00|1.00|< 1.00|
|TOOL|> 1.00|1.00|< 1.00|

> Personnel capability drivers (ACAP, PCAP) **reduce** effort when rated high — more capable teams cost less effort. Product/platform drivers generally **increase** effort when rated high.

---

### Sanity Checks

- If `E > 1.0` → diseconomies of scale (larger = disproportionately more effort)
- If `E < 1.0` → economies of scale (rare in practice)
- If `∏EM >> 1.0` → check if high-risk drivers are dominating
- Staff figure is an **average** across the schedule, not a fixed headcount

---
