## Module 2: Code Review Practices


### 2.1 Code Review Fundamentals

- Purpose and benefits of code review
- Review vs inspection vs walkthrough
- Synchronous vs asynchronous reviews
- Pre-commit vs post-commit reviews
- Pair programming as continuous review
- Review velocity and thoroughness tradeoff

### 2.2 Code Review Process

**Pre-Review Preparation:**

- Self-review checklist
- Running tests locally
- Linting and formatting
- Commit message quality
- PR/MR description standards
- Linking to issues/tickets

**Review Workflow:**

- Review assignment strategies
- Review priority levels
- Time allocation guidelines (review within 24h)
- Multiple reviewer approaches
- Review approval requirements
- Handling review iterations

**Post-Review:**

- Addressing feedback
- Re-review triggers
- Merge strategies (squash, rebase, merge commit)
- Post-merge validation

### 2.3 What to Review: General Code

**Code Structure and Design:**

- Modularity and separation of concerns
- SOLID principles adherence
- Design patterns appropriate usage
- Code duplication (DRY principle)
- Function/class size and complexity
- Dependency management

**Code Quality:**

- Readability and clarity
- Naming conventions (variables, functions, classes)
- Comment quality and necessity
- Magic numbers and hardcoded values
- Error handling and edge cases
- Resource management (memory leaks, file handles)

**Testing:**

- Test coverage (target: 80%+ for critical paths)
- Test quality and meaningfulness
- Edge case coverage
- Mock usage appropriateness
- Integration test presence
- Test naming and organization

**Security:**

- Input validation
- Authentication and authorization
- Sensitive data handling
- SQL injection prevention
- XSS prevention
- Dependency vulnerabilities

**Performance:**

- Algorithmic complexity (Big O analysis)
- Database query efficiency
- Caching opportunities
- Unnecessary computations
- Memory usage patterns
- I/O operations optimization

### 2.4 What to Review: ML-Specific Code

**Data Pipeline Code:**

- Data loading efficiency
- Data validation checks
- Missing value handling
- Outlier detection and treatment
- Feature engineering logic
- Data leakage prevention [CRITICAL]
- Train/validation/test splitting correctness
- Data augmentation appropriateness
- Batch processing logic

**Model Code:**

- Architecture implementation correctness
- Layer connectivity verification
- Activation function choices
- Loss function appropriateness
- Initialization strategies
- Regularization implementation
- Gradient flow considerations

**Training Code:**

- Training loop correctness
- Metric calculation accuracy
- Checkpoint saving logic
- Early stopping implementation
- Learning rate scheduling
- Gradient accumulation correctness
- Mixed precision training setup
- Distributed training configuration

**Evaluation Code:**

- Metric selection appropriateness
- Evaluation on correct dataset splits
- Confusion matrix interpretation
- Cross-validation implementation
- Statistical significance testing
- Confidence interval calculation

**Inference Code:**

- Input preprocessing consistency (train vs inference)
- Batch processing correctness
- Post-processing logic
- Output format verification
- Error handling for edge cases
- Latency optimization

### 2.5 Code Review Best Practices

**For Reviewers:**

- Review code, not the author
- Ask questions rather than make demands
- Provide specific, actionable feedback
- Explain the "why" behind suggestions
- Distinguish between blocking vs non-blocking issues
- Praise good practices
- Use review checklists
- Focus on one PR at a time
- Review in multiple passes (high-level → details)
- Set aside dedicated review time

**For Authors:**

- Keep PRs small (<400 lines when possible)
- Single responsibility per PR
- Provide context in description
- Respond to all comments
- Don't take feedback personally
- Ask for clarification when needed
- Update based on feedback promptly
- Mark conversations as resolved appropriately

**Communication Guidelines:**

- Use constructive language
- Be respectful and empathetic
- Use "we" instead of "you"
- Provide examples and references
- Use conventional comments:
    - `nit:` Minor/stylistic suggestion
    - `question:` Seeking clarification
    - `suggestion:` Optional improvement
    - `issue:` Must be addressed
    - `blocking:` Cannot merge until fixed
    - `praise:` Acknowledge good work

### 2.6 Code Review Tools and Automation

**Version Control Platforms:**

- GitHub Pull Requests
- GitLab Merge Requests
- Bitbucket Pull Requests
- Gerrit Code Review

**Automated Checks:**

- Linters (pylint, flake8, black for Python)
- Type checkers (mypy, pyright)
- Security scanners (bandit, safety)
- Complexity analyzers (radon, mccabe)
- Test runners and coverage reports
- CI/CD pipeline integration

**Review Assistance Tools:**

- CodeClimate
- SonarQube
- DeepCode (AI-powered)
- Codacy
- Reviewable

### 2.7 Code Review Metrics

- Review turnaround time
- Number of review iterations
- Comments per review
- Defect detection rate
- Post-merge bug rate
- Code coverage trends
- Technical debt accumulation

### 2.8 Common Code Review Pitfalls

- Reviewing too much code at once
- Focusing only on style
- Ignoring tests
- Not running the code
- Rubber-stamp approvals
- Nitpicking without constructive value
- Delaying reviews excessively
- Personal preference debates
- Scope creep in reviews

---

