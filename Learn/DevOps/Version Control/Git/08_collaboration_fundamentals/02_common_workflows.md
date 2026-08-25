## Common Workflows


### Feature branch workflow

The feature branch workflow revolves around isolating new development into dedicated branches rather than committing directly to the main branch. This creates a clean separation between in-progress work and stable code.

#### Core principles

- Main branch always contains stable, production-ready code
- Each new feature is developed in a dedicated branch
- Features are integrated back into main through pull/merge requests
- Code review happens during the pull/merge request process

#### Workflow steps

1. Create a feature branch from main
    
    ```bash
    git checkout main
    git pull
    git checkout -b feature/user-authentication
    ```
    
2. Develop and commit changes to the feature branch
    
    ```bash
    # Make changes, then...
    git add .
    git commit -m "Add login form and validation"
    ```
    
3. Push the branch to the remote repository
    
    ```bash
    git push -u origin feature/user-authentication
    ```
    
4. Create a pull/merge request for code review
    
5. Make requested changes based on feedback
    
6. Merge the feature branch into main
    
    ```bash
    git checkout main
    git merge --no-ff feature/user-authentication
    git push
    ```
    
7. Delete the feature branch after merging
    
    ```bash
    git branch -d feature/user-authentication
    git push origin --delete feature/user-authentication
    ```
    

**Key Points**:

- Simple and intuitive workflow for teams of any size
- Provides isolation for experimental or disruptive changes
- Enables parallel development of multiple features
- Facilitates code reviews and collaboration
- Keeps the main branch stable at all times

### Gitflow workflow

Gitflow is a robust branching model designed for projects with scheduled releases, providing a structured framework for managing feature development, releases, and hotfixes.

#### Core branches

- **main**: Production code only, represents released versions
- **develop**: Integration branch for features, contains latest delivered development changes

#### Supporting branches

- **feature/***: New features, branched from and merged back to develop
- **release/***: Preparation for production release, branched from develop
- **hotfix/***: Urgent fixes for production, branched from main
- **bugfix/***: Non-urgent bug fixes, branched from develop

#### Workflow steps

1. **Feature development**
    
    ```bash
    git checkout develop
    git checkout -b feature/shopping-cart
    # Work, commit, and push changes
    git checkout develop
    git merge --no-ff feature/shopping-cart
    git branch -d feature/shopping-cart
    ```
    
2. **Release preparation**
    
    ```bash
    git checkout develop
    git checkout -b release/1.2.0
    # Final testing, bug fixes, version bumps
    # When ready:
    git checkout main
    git merge --no-ff release/1.2.0
    git tag -a v1.2.0 -m "Release 1.2.0"
    git checkout develop
    git merge --no-ff release/1.2.0
    git branch -d release/1.2.0
    ```
    
3. **Hotfix implementation**
    
    ```bash
    git checkout main
    git checkout -b hotfix/payment-failure
    # Fix critical issue
    # When ready:
    git checkout main
    git merge --no-ff hotfix/payment-failure
    git tag -a v1.2.1 -m "Hotfix 1.2.1"
    git checkout develop
    git merge --no-ff hotfix/payment-failure
    git branch -d hotfix/payment-failure
    ```
    

**Key Points**:

- Well-suited for projects with scheduled releases
- Provides clear separation between development and production
- Accommodates parallel development of multiple versions
- Has a defined process for emergency fixes
- Includes explicit support for maintenance of multiple releases

### GitHub Flow

GitHub Flow is a lightweight, branch-based workflow that supports teams and projects where deployments are made regularly. It simplifies Gitflow by eliminating the distinction between develop and main branches.

#### Core principles

- Main branch is always deployable
- All work happens in topic branches
- Pull requests initiate discussion about changes
- Production deployment happens after merge to main
- Issues are fixed immediately rather than batched

#### Workflow steps

1. Create a descriptive branch from main
    
    ```bash
    git checkout main
    git pull
    git checkout -b fix-login-redirect
    ```
    
2. Add commits with clear, descriptive messages
    
    ```bash
    git add .
    git commit -m "Fix redirect loop on failed login"
    ```
    
3. Open a pull request for discussion
    
    ```bash
    git push -u origin fix-login-redirect
    # Then create PR through GitHub interface
    ```
    
4. Discuss and review code in the pull request
    
5. Deploy and test the changes (optionally)
    
6. Merge into main and deploy to production
    
    ```bash
    # Through GitHub interface or:
    git checkout main
    git merge fix-login-redirect
    git push
    ```
    

**Key Points**:

- Designed for continuous delivery and deployment
- Simplifies branching strategy to only main and feature branches
- Emphasizes deployment of features as they're completed
- Heavily integrated with GitHub's pull request workflow
- Suitable for web applications and services with frequent releases

### GitLab Flow

GitLab Flow expands on GitHub Flow by adding environment branches and explicit versioning to accommodate different deployment strategies while maintaining simplicity.

#### Core principles

- Main branch represents production-ready code
- Feature branches are created from main
- Environment branches (staging, production) act as deployment milestones
- Version tags mark significant releases
- Uses merge requests for code review

#### Environment branch models

**Production branch model**:

- main → pre-production → production

**Release branch model**:

- main → releases/1.0 → releases/1.1

#### Workflow steps

1. Create a feature branch from main
    
    ```bash
    git checkout main
    git checkout -b feature/improved-search
    ```
    
2. Develop and commit changes
    
    ```bash
    git add .
    git commit -m "Add search filtering capability"
    git push -u origin feature/improved-search
    ```
    
3. Create a merge request for review
    
4. After approval, merge into main
    
    ```bash
    git checkout main
    git merge --no-ff feature/improved-search
    git push
    ```
    
5. Deploy to staging environment (automatic or manual)
    
    ```bash
    git checkout staging
    git merge --no-ff main
    git push
    ```
    
6. After testing, deploy to production
    
    ```bash
    git checkout production
    git merge --no-ff staging
    git push
    ```
    

**Key Points**:

- Bridges the gap between GitHub Flow and Gitflow
- Adapts to different deployment strategies
- Supports continuous delivery with environment branches
- Provides clear visualization of deployment status
- Accommodates projects with multiple versions in production

### Trunk-based development

Trunk-based development is a source control pattern where developers collaborate on code in a single branch called "trunk" (usually main), with an emphasis on small, frequent updates.

#### Core principles

- Developers integrate frequently (at least daily)
- Feature flags are used for incomplete or experimental code
- Short-lived feature branches (if used) are kept to hours, not days
- Continuous integration ensures trunk stability
- Focus on breaking work into small, deployable increments

#### Variations

**Direct trunk commits**:

```bash
git checkout main
# Make small changes
git commit -am "Add validation for email field"
git pull --rebase  # Incorporate any changes
git push
```

**Short-lived feature branches**:

```bash
git checkout -b quick-fix
# Make changes (ideally completed within a day)
git commit -am "Fix login button styling"
git checkout main
git pull
git merge quick-fix
git push
git branch -d quick-fix
```

**Feature flags**:

```javascript
// Example of feature flag in code
if (FEATURES.enableNewCheckout) {
  // New checkout flow
} else {
  // Old checkout flow
}
```

**Key Points**:

- Minimizes merge conflicts through frequent integration
- Reduces overhead of branch management
- Enables continuous delivery and deployment
- Requires strong testing practices and CI/CD
- Often used by high-performing DevOps teams

### Choosing the right workflow for your team

Selecting an appropriate Git workflow depends on several factors related to your team, project, and deployment requirements.

#### Key considerations

**Team size and distribution**:

- Small, co-located teams: Simpler workflows like GitHub Flow or trunk-based
- Large, distributed teams: More structured approaches like Gitflow or GitLab Flow

**Release cadence**:

- Continuous deployment: GitHub Flow or trunk-based development
- Scheduled releases: Gitflow or GitLab Flow with release branches
- Multiple supported versions: Gitflow

**Project type**:

- Web applications: GitHub Flow, trunk-based development
- Mobile apps: Gitflow (for versioned releases)
- Libraries/frameworks: GitLab Flow with release branches

**Team experience**:

- Git beginners: Feature branch workflow
- Experienced teams: Any workflow that suits the project

#### Workflow comparison

|Workflow|Complexity|Release Frequency|Multiple Versions|CI/CD Friendly|
|---|---|---|---|---|
|Feature Branch|Low|Any|No|Yes|
|GitHub Flow|Low|Continuous|No|Very|
|GitLab Flow|Medium|Regular/Continuous|Yes|Yes|
|Gitflow|High|Scheduled|Yes|Moderate|
|Trunk-based|Low-Medium|Continuous|No|Very|

#### Implementation strategies

**Introducing a new workflow**:

1. Document the chosen workflow with diagrams and examples
2. Train the team on the process and commands
3. Set up branch protection rules in your Git host
4. Configure CI/CD to align with the workflow
5. Start with a pilot project or team
6. Regularly review and adjust as needed

**Migrating between workflows**:

1. Complete in-progress work in the old workflow
2. Document the new workflow process
3. Set a transition date
4. Consider a "hybrid" approach during transition
5. Update automation and CI/CD pipelines

**Key Points**:

- No single workflow is universally "best"
- Choose based on team and project needs, not popularity
- The right workflow should reduce friction, not create it
- Be willing to adapt workflows as projects evolve
- Consistency within a team is more important than adhering to any particular workflow

### Workflow automation best practices

#### Automated testing

Integrate testing into your workflow:

```yaml
# Example GitHub Actions workflow
name: Test
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: |
          npm install
          npm test
```

#### Branch protection

Configure repository settings to:

- Require pull request reviews before merging
- Require status checks to pass
- Prevent direct commits to protected branches
- Automatically delete merged branches

#### CI/CD integration

```yaml
# Example deployment pipeline for GitHub Flow
name: Deploy
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to production
        run: ./deploy.sh
```

**Key Points**:

- Automate repetitive parts of your workflow
- Enforce workflow rules through technical measures
- Keep documentation updated with actual practices
- Periodically review and optimize workflows
- Remember that workflows should serve the team, not vice versa

The workflow you choose shapes how your team collaborates, how code reaches production, and ultimately how quickly and safely you can deliver value to users. The most successful teams adapt their workflows over time based on their evolving needs and experiences.


---

