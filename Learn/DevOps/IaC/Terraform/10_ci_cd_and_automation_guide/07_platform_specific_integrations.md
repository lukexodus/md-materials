## Platform-Specific Integrations


### GitHub Actions

**Complete Workflow**

```yaml
# .github/workflows/terraform.yml
name: Terraform Infrastructure

on:
  push:
    branches: [main, develop]
    paths: ['terraform/**']
  pull_request:
    branches: [main]
    paths: ['terraform/**']

env:
  TF_VERSION: 1.5.0
  AWS_REGION: us-east-1

jobs:
  terraform:
    name: Terraform
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        environment: [dev, staging, prod]
        
    steps:
    - name: Checkout
      uses: actions/checkout@v3
      
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: ${{ env.TF_VERSION }}
        
    - name: Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_REGION }}
        
    - name: Terraform Init
      working-directory: terraform/environments/${{ matrix.environment }}
      run: terraform init
      
    - name: Terraform Validate
      working-directory: terraform/environments/${{ matrix.environment }}
      run: terraform validate
      
    - name: Terraform Plan
      working-directory: terraform/environments/${{ matrix.environment }}
      run: terraform plan -out=tfplan
      
    - name: Terraform Apply
      if: github.ref == 'refs/heads/main' && matrix.environment == 'prod'
      working-directory: terraform/environments/${{ matrix.environment }}
      run: terraform apply tfplan
```

### GitLab CI

**GitLab CI Configuration**

```yaml
# .gitlab-ci.yml
stages:
  - validate
  - plan
  - apply
  - test

variables:
  TF_ROOT: ${CI_PROJECT_DIR}/terraform
  TF_ADDRESS: ${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/terraform/state/default

before_script:
  - cd ${TF_ROOT}
  - terraform init
    -backend-config="address=${TF_ADDRESS}"
    -backend-config="lock_address=${TF_ADDRESS}/lock"
    -backend-config="unlock_address=${TF_ADDRESS}/lock"
    -backend-config="username=gitlab-ci-token"
    -backend-config="password=${CI_JOB_TOKEN}"
    -backend-config="lock_method=POST"
    -backend-config="unlock_method=DELETE"
    -backend-config="retry_wait_min=5"

validate:
  stage: validate
  script:
    - terraform validate
    - terraform fmt -check

plan:
  stage: plan
  script:
    - terraform plan -out=tfplan
  artifacts:
    paths:
      - ${TF_ROOT}/tfplan

apply:
  stage: apply
  script:
    - terraform apply tfplan
  dependencies:
    - plan
  only:
    - main
```

### Jenkins Integration

**Jenkinsfile**

```groovy
// Jenkinsfile
pipeline {
    agent any
    
    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'staging', 'prod'],
            description: 'Target environment'
        )
        booleanParam(
            name: 'DESTROY',
            defaultValue: false,
            description: 'Destroy infrastructure'
        )
    }
    
    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        TF_VAR_environment = "${params.ENVIRONMENT}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Terraform Init') {
            steps {
                dir("terraform/environments/${params.ENVIRONMENT}") {
                    sh 'terraform init'
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                dir("terraform/environments/${params.ENVIRONMENT}") {
                    script {
                        if (params.DESTROY) {
                            sh 'terraform plan -destroy -out=tfplan'
                        } else {
                            sh 'terraform plan -out=tfplan'
                        }
                    }
                }
            }
        }
        
        stage('Approval') {
            when {
                environment name: 'ENVIRONMENT', value: 'prod'
            }
            steps {
                script {
                    def userInput = input(
                        id: 'userInput',
                        message: 'Apply Terraform plan?',
                        parameters: [
                            choice(
                                choices: ['Apply', 'Abort'],
                                description: 'Apply or abort the plan',
                                name: 'action'
                            )
                        ]
                    )
                    
                    if (userInput != 'Apply') {
                        error('User aborted the deployment')
                    }
                }
            }
        }
        
        stage('Terraform Apply') {
            steps {
                dir("terraform/environments/${params.ENVIRONMENT}") {
                    sh 'terraform apply tfplan'
                }
            }
        }
        
        stage('Post-Deploy Tests') {
            steps {
                script {
                    sh './scripts/health-check.sh'
                    sh './scripts/integration-tests.sh'
                }
            }
        }
    }
    
    post {
        always {
            archiveArtifacts artifacts: '**/tfplan', allowEmptyArchive: true
            publishHTML([
                allowMissing: false,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'reports',
                reportFiles: 'terraform-report.html',
                reportName: 'Terraform Report'
            ])
        }
        
        failure {
            script {
                if (params.ENVIRONMENT == 'prod') {
                    // Trigger rollback pipeline
                    build job: 'terraform-rollback',
                          parameters: [
                              string(name: 'ENVIRONMENT', value: params.ENVIRONMENT)
                          ]
                }
            }
        }
    }
}
```

