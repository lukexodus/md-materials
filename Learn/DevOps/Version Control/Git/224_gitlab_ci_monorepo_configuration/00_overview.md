## Overview

stages:
  - build
  - test
  - deploy

.only_frontend_changes: &only_frontend_changes
  changes:
    - frontend/**/*

.only_backend_changes: &only_backend_changes
  changes:
    - backend/**/*

build_frontend:
  stage: build
  script: cd frontend && npm build
  only:
    <<: *only_frontend_changes

test_frontend:
  stage: test
  script: cd frontend && npm test
  only:
    <<: *only_frontend_changes

build_backend:
  stage: build
  script: cd backend && mvn package
  only:
    <<: *only_backend_changes

test_backend:
  stage: test
  script: cd backend && mvn test
  only:
    <<: *only_backend_changes

deploy:
  stage: deploy
  script: ./deploy_changed_components.sh
  only:
    - main
```

### Best Practices for Git DevOps Integration

#### Configuration Management

Effectively managing configuration across environments:

- **Branch-based configuration**: Different configs per branch
- **Environment variables**: Inject environment-specific settings
- **Config templates**: Parameterized configuration files
- **Secret management**: Secure handling of sensitive values
- **Configuration validation**: Verify configs before deployment

#### CI/CD Pipeline Structure

Designing effective pipelines:

- **Fast feedback**: Prioritize quick-running tests early in the pipeline
- **Parallel execution**: Run independent steps concurrently
- **Fail fast**: Stop the pipeline as soon as an issue is detected
- **Artifact reuse**: Generate artifacts once and reuse them
- **Deployment gates**: Include manual approval for production deployments

#### Testing Strategies

Implementing effective testing in Git-driven pipelines:

- **Progressive testing**: Unit → Integration → End-to-End
- **Test selection**: Run only tests affected by changes
- **Test environment management**: Clean, reproducible test environments
- **Test result tracking**: Monitor trends across commits
- **Test coverage enforcement**: Maintain or improve coverage

#### Security Considerations

Securing Git-based CI/CD systems:

- **Secret management**: Never store secrets in Git repositories
- **Dependency scanning**: Check for vulnerable dependencies
- **SAST/DAST**: Static and dynamic security testing
- **CI/CD permissions**: Limit access to pipeline configuration
- **Signed commits**: Verify commit authenticity

#### Feedback Mechanisms

Creating effective feedback loops:

- **Status checks**: Visible status in Git interfaces
- **Notifications**: Alert relevant team members of build status
- **Deployment tracking**: Link deployments to specific commits
- **Monitoring integration**: Connect monitoring alerts to code changes
- **Post-deployment validation**: Verify successful deployments

**Related Topics**

- Trunk-based development with CI/CD
- Containerization and Git-based deployment
- Microservices deployment strategies
- A/B testing with feature flags in Git
- Immutable infrastructure and Git workflows

---

## Enterprise Git

### Git at Scale

Managing Git repositories in large enterprise environments presents unique challenges that require specialized strategies and tooling to ensure performance, security, and collaboration.

**Key Points**

- Enterprise Git implementations often involve hundreds or thousands of repositories
- Large repositories can contain millions of files and require specialized handling
- Scale challenges affect clone time, network traffic, and storage requirements
- Specialized Git servers and infrastructure are needed for reliability and performance

#### Performance Optimization Techniques

```bash
