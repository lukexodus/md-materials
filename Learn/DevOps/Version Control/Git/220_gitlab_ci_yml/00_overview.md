## Overview

stages:
  - build
  - test
  - deploy

variables:
  MAVEN_OPTS: "-Dmaven.repo.local=.m2/repository"

cache:
  paths:
    - .m2/repository

build:
  stage: build
  script:
    - mvn compile
  artifacts:
    paths:
      - target/

test:
  stage: test
  script:
    - mvn test
  artifacts:
    reports:
      junit: target/surefire-reports/TEST-*.xml

deploy_staging:
  stage: deploy
  script:
    - mvn package
    - ./deploy.sh staging
  environment:
    name: staging
  only:
    - develop

deploy_production:
  stage: deploy
  script:
    - mvn package
    - ./deploy.sh production
  environment:
    name: production
  only:
    - main
  when: manual
```

#### Platform Comparison

|Feature|Jenkins|GitHub Actions|GitLab CI|
|---|---|---|---|
|**Repository Integration**|External|Native|Native|
|**Configuration**|Jenkinsfile|YAML workflows|.gitlab-ci.yml|
|**Execution Environment**|Self-hosted|GitHub-hosted or self-hosted|GitLab-hosted or self-hosted|
|**Parallelism**|Limited by executors|Matrix builds|Parallel jobs|
|**Branch Handling**|MultiBranch Pipeline|Event filters|Branch specifications|
|**Secret Management**|Jenkins Credentials|GitHub Secrets|GitLab Variables|
|**Pull Request Support**|Via plugins|Native|Native|
|**Self-hosting Option**|Yes|Yes (runners only)|Yes (runners only)|

### Advanced Git DevOps Patterns

#### Feature Branch Workflows

Implementing feature branch workflows with CI/CD:

- **Branch-specific pipelines**: Different CI steps for different branch types
- **Pull request validation**: Automated testing for PRs
- **Environment deployment**: Deploy feature branches to isolated environments
- **Merge validation**: Pre-merge verification steps

```yaml
