## Overview

while read oldrev newrev refname; do
  branch=$(echo $refname | sed 's|refs/heads/||')
  
  # Protect main branch from force pushes
  if [ "$branch" = "main" ]; then
    if [ "$oldrev" != "0000000000000000000000000000000000000000" ]; then
      # Check for force push
      if git merge-base --is-ancestor $oldrev $newrev; then
        echo "Normal push to main branch - OK"
      else
        echo "Force push to main branch detected - REJECTED"
        exit 1
      fi
    fi
    
    # Check commit message format
    commits=$(git rev-list $oldrev..$newrev)
    for commit in $commits; do
      message=$(git show -s --format=%B $commit)
      if ! echo "$message" | grep -q "^[A-Z]+-[0-9]+:"; then
        echo "Commit $commit doesn't reference an issue in message - REJECTED"
        exit 1
      fi
    done
  fi
done

exit 0
```

#### Implementing Server-side Hooks

Server-side hooks can be implemented in different ways depending on the Git hosting solution:

1. **Self-hosted Git servers**: Directly modify the hooks in the server's repository
2. **GitHub**: Use GitHub Apps, Actions, or branch protection rules
3. **GitLab**: Use Server Hooks, Push Rules, or Protected Branches
4. **Bitbucket**: Use pre-receive hooks (Bitbucket Server) or Access Controls
5. **Azure DevOps**: Use branch policies and build validation

#### Limitations of Server-side Hooks

Server-side hooks have some limitations to consider:

- They can only reject changes, not modify them
- They run after developers have already committed locally
- They can cause frustration if they reject changes without clear messages
- They require server-side access for modification
- Performance impacts can affect all users

### Git with Jenkins, GitHub Actions, GitLab CI

Different CI/CD platforms offer varying approaches to Git integration, each with unique strengths.

#### Jenkins and Git

Jenkins, a widely-used CI/CD server, integrates with Git in several ways:

- **Git Plugin**: Basic Git checkout and branch building
- **Git Parameter Plugin**: Parameterized builds for branches/tags
- **Pipeline SCM**: Jenkinsfile from Git repositories
- **MultiBranch Pipeline**: Automatic pipeline discovery for branches
- **GitHub/GitLab Integration**: Webhooks for build triggering

```groovy
// Jenkinsfile
pipeline {
    agent any
    
    triggers {
        githubPush() // Trigger on GitHub push events
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/organization/repo.git'
            }
        }
        
        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }
        
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
        
        stage('Deploy') {
            when {
                expression { env.BRANCH_NAME == 'main' }
            }
            steps {
                sh './deploy.sh'
            }
        }
    }
}
```

#### GitHub Actions

GitHub Actions provides native CI/CD capabilities directly integrated with GitHub repositories:

- **Event-driven workflows**: Run on Git-related events
- **Built-in secrets management**: Securely store credentials
- **Matrix builds**: Test across multiple configurations
- **Marketplace actions**: Reusable components for common tasks
- **Artifact storage**: Save and share build outputs

```yaml
