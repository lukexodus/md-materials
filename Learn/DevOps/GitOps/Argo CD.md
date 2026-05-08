# Comprehensive Guide to Argo CD

Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes. It monitors Git repositories as the source of truth for application state and reconciles the live cluster state to match what is defined in Git.

---

## What Is Argo CD

Argo CD is part of the Argo project, a set of Kubernetes-native tools for running and managing jobs and applications on Kubernetes. Argo CD specifically handles continuous delivery by automating the deployment of desired application states defined in Git repositories to target Kubernetes clusters.

It operates on a pull-based model: instead of a CI pipeline pushing deployments into a cluster, Argo CD continuously polls or receives webhooks from Git, compares the desired state to the live state, and either reports drift or reconciles it automatically.

### Core Principles

**Declarative configuration.** All application configuration, including Kubernetes manifests, Helm charts, Kustomize overlays, and Jsonnet files, lives in Git. What is in Git is what should be running.

**Version-controlled deployments.** Every deployment is traceable to a specific Git commit. Rollbacks are as simple as reverting a commit.

**Automated reconciliation.** Argo CD can be configured to automatically sync the cluster state to Git without human intervention.

**Auditability.** Because all changes flow through Git, there is a natural audit trail for who changed what and when.

---

## Architecture

Argo CD consists of several components that run inside a Kubernetes cluster.

### API Server

The API server is a gRPC/REST server that exposes the application management API. It is consumed by the web UI, the CLI (`argocd` command), and CI/CD pipelines. It handles application CRUD operations, authentication and authorization, repository and cluster credential management, and webhook events from Git providers.

### Repository Server

The repository server is an internal service that maintains a local cache of Git repositories. It is responsible for cloning repos, generating Kubernetes manifests from source tools (Helm, Kustomize, Jsonnet, plain YAML), and serving those manifests to the application controller.

### Application Controller

This is the core reconciliation loop. It continuously watches running applications and compares the live cluster state against the desired state from the repository server. When it detects a difference (OutOfSync), it can optionally trigger a sync operation. It also invokes configured resource health checks and lifecycle hooks.

### ApplicationSet Controller

An optional controller that manages `ApplicationSet` resources, which allow templating and generating multiple `Application` objects from a single definition. Useful for managing applications across many clusters or namespaces.

### Dex (Optional)

Argo CD bundles Dex, an OpenID Connect identity service, to handle SSO integrations with external identity providers like GitHub, GitLab, LDAP, and SAML 2.0.

### Redis

Argo CD uses Redis as a cache layer for manifests, cluster state, and other computed data to reduce load on the Kubernetes API server and Git repositories.

### Notification Controller (Optional)

Handles alerting and notifications for application events. Supports integrations with Slack, email, PagerDuty, and others via a trigger/template model.

---

## Installation

### Prerequisites

- A running Kubernetes cluster (v1.19+ is a common baseline; verify with your Argo CD release notes)
- `kubectl` configured with cluster access
- Cluster-admin permissions for the initial install

### Standard Installation

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

This installs all Argo CD components into the `argocd` namespace. The `stable` channel tracks the latest stable release.

### High Availability Installation

For production environments, Argo CD provides an HA manifest that runs multiple replicas of the API server, repo server, and application controller:

```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/ha/install.yaml
```

### Installing via Helm

Argo CD maintains an official Helm chart:

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  --values values.yaml
```

A minimal `values.yaml` to get started:

```yaml
server:
  service:
    type: LoadBalancer
configs:
  params:
    server.insecure: "true"  # Only use behind a TLS-terminating ingress
```

### Accessing the UI

By default, the Argo CD API server is not exposed externally. You have several options:

**Port forwarding (quickstart only):**

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Then visit `https://localhost:8080`.

**LoadBalancer service:**

```bash
kubectl patch svc argocd-server -n argocd \
  -p '{"spec": {"type": "LoadBalancer"}}'
```

**Ingress (recommended for production):** Configure an Ingress resource pointing to `argocd-server` on port 443 (or 80 if running in insecure mode behind a TLS-terminating proxy). Argo CD's documentation has nginx and Traefik examples.

### Initial Admin Password

Argo CD generates an initial admin password stored in a Kubernetes Secret:

```bash
kubectl get secret argocd-initial-admin-secret \
  -n argocd \
  -o jsonpath="{.data.password}" | base64 -d
```

Log in with username `admin` and the decoded password. You should change this password immediately and delete the secret afterward.

### Installing the CLI

```bash
# macOS
brew install argocd

# Linux (replace VERSION with the desired release tag)
curl -sSL -o argocd \
  https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd
sudo mv argocd /usr/local/bin/

# Windows
# Use the release page or winget:
winget install ArgoProj.ArgoCD
```

Log in via CLI:

```bash
argocd login <ARGOCD_SERVER> --username admin --password <PASSWORD>
```

---

## Core Concepts

### Application

An `Application` is the fundamental Argo CD resource. It defines:

- **Source**: where to find the desired state (Git repo URL, path, revision)
- **Destination**: which Kubernetes cluster and namespace to deploy into
- **Sync policy**: whether to sync automatically or manually

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/my-org/my-app.git
    targetRevision: HEAD
    path: k8s/overlays/production
  destination:
    server: https://kubernetes.default.svc
    namespace: my-app
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

### AppProject

An `AppProject` groups applications and enforces policies on them. It controls:

- Which Git repositories are allowed as sources
- Which clusters and namespaces are allowed as destinations
- Which Kubernetes resource kinds are allowed or denied
- RBAC roles scoped to the project

The `default` project permits everything and is created automatically.

### Sync

A sync is the act of applying the desired state from Git to the target cluster. Syncs can be:

- **Manual**: triggered by the user via UI, CLI, or API
- **Automated**: triggered by Argo CD when it detects drift (requires `spec.syncPolicy.automated`)

### Sync Status

An application's sync status is one of:

- `Synced`: the live state matches the desired Git state
- `OutOfSync`: there is a diff between Git and live state
- `Unknown`: the status could not be determined

### Health Status

Argo CD evaluates the health of Kubernetes resources using built-in and custom health checks:

- `Healthy`: the resource is operating as expected
- `Progressing`: a deployment or rollout is in progress
- `Degraded`: the resource is failing or not ready
- `Suspended`: the resource is intentionally paused
- `Missing`: the resource does not exist in the cluster
- `Unknown`: health cannot be determined

### Revision

A revision is a Git commit SHA, tag, or branch name. Applications track a `targetRevision`. Using `HEAD` tracks the branch tip. Pinning to a specific SHA gives immutable deployments.

---

## Source Types

Argo CD supports several manifest generation tools.

### Plain YAML / Kustomize

If the path contains plain YAML manifests, Argo CD applies them directly. If it detects a `kustomization.yaml`, it runs `kustomize build` automatically.

You can explicitly configure Kustomize options:

```yaml
source:
  repoURL: https://github.com/my-org/my-app.git
  path: k8s/overlays/production
  targetRevision: main
  kustomize:
    namePrefix: prod-
    images:
      - my-image:latest=my-image:v1.2.3
    commonLabels:
      environment: production
```

### Helm

Argo CD can render Helm charts from a Git repo or a Helm repository:

```yaml
# From a Helm repository
source:
  repoURL: https://charts.bitnami.com/bitnami
  chart: postgresql
  targetRevision: 12.1.0
  helm:
    releaseName: my-postgresql
    values: |
      auth:
        postgresPassword: "changeme"
    valueFiles:
      - values.yaml
      - values-production.yaml
```

```yaml
# From a Git repository containing a chart
source:
  repoURL: https://github.com/my-org/charts.git
  path: charts/my-app
  targetRevision: main
  helm:
    releaseName: my-app
    parameters:
      - name: image.tag
        value: v1.2.3
```

Note that Argo CD renders Helm charts using `helm template`, not `helm install`. This means Helm hooks behave differently than in a native Helm install. Refer to Argo CD's documentation on Helm hook support if you rely on Helm lifecycle hooks.

### Jsonnet

Argo CD supports Jsonnet files natively:

```yaml
source:
  path: jsonnet/app
  directory:
    jsonnet:
      extVars:
        - name: env
          value: production
      libs:
        - vendor/
```

### Multiple Sources (Multi-Source Applications)

Since Argo CD v2.6, a single `Application` can pull from multiple sources. This is useful for combining a Helm chart from one repo with values files from another:

```yaml
spec:
  sources:
    - repoURL: https://charts.bitnami.com/bitnami
      chart: postgresql
      targetRevision: 12.1.0
      helm:
        valueFiles:
          - $values/helm/postgresql/values-prod.yaml
    - repoURL: https://github.com/my-org/my-config.git
      targetRevision: main
      ref: values
```

---

## Repository Configuration

Argo CD needs credentials to access private repositories.

### HTTPS Repositories

```bash
argocd repo add https://github.com/my-org/my-private-repo.git \
  --username my-user \
  --password my-token
```

Or declaratively via a Kubernetes Secret:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-repo-creds
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
type: Opaque
stringData:
  url: https://github.com/my-org/my-private-repo.git
  username: my-user
  password: my-token
```

### SSH Repositories

```bash
argocd repo add git@github.com:my-org/my-private-repo.git \
  --ssh-private-key-path ~/.ssh/id_rsa
```

### Repository Templates (Credential Templates)

If you have many repos under the same organization, you can define a credential template that applies to all matching repo URLs:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: github-creds
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repo-creds
type: Opaque
stringData:
  url: https://github.com/my-org
  username: my-user
  password: my-token
```

Any repo URL starting with `https://github.com/my-org` inherits these credentials.

---

## Cluster Management

### Registering External Clusters

By default, Argo CD can deploy to the cluster it is installed on (referenced as `https://kubernetes.default.svc`). To manage external clusters:

```bash
# Assumes your kubeconfig has a context for the target cluster
argocd cluster add my-context-name --name my-cluster
```

This creates a ServiceAccount and ClusterRoleBinding in the target cluster and stores the credentials in Argo CD.

### Cluster Secrets

Cluster credentials are stored as Kubernetes Secrets with a specific label:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-cluster-secret
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: cluster
type: Opaque
stringData:
  name: my-cluster
  server: https://my-cluster.example.com
  config: |
    {
      "bearerToken": "<token>",
      "tlsClientConfig": {
        "caData": "<base64-ca-cert>"
      }
    }
```

---

## Sync Policies and Options

### Automated Sync

```yaml
syncPolicy:
  automated:
    prune: true       # Delete resources removed from Git
    selfHeal: true    # Revert manual changes to the cluster
    allowEmpty: false # Prevent syncing an empty set of resources
```

`prune: true` means Argo CD will delete Kubernetes resources that exist in the cluster but are no longer defined in Git. Use with caution — verify your Git state is complete before enabling this.

`selfHeal: true` means Argo CD will automatically re-sync if it detects that the live state has diverged from Git (e.g., someone manually edited a Deployment). [Inference: this reduces configuration drift but may conflict with live debugging workflows; behavior is not guaranteed to be instantaneous and depends on reconciliation interval.]

### Manual Sync via CLI

```bash
# Sync with default options
argocd app sync my-app

# Sync a specific resource
argocd app sync my-app --resource apps:Deployment:my-deployment

# Dry run
argocd app sync my-app --dry-run

# Sync and wait until healthy
argocd app sync my-app --timeout 120
```

### Sync Options

Sync options control how syncs behave. They can be set at the application level or per-resource via annotations.

```yaml
syncPolicy:
  syncOptions:
    - CreateNamespace=true        # Create destination namespace if missing
    - PruneLast=true              # Prune resources after all others are applied
    - ApplyOutOfSyncOnly=true     # Only apply resources that are out of sync
    - RespectIgnoreDifferences=true
    - Replace=true                # Use kubectl replace instead of apply
    - ServerSideApply=true        # Use server-side apply
    - FailOnSharedResource=true   # Fail if a resource is managed by another app
```

Per-resource annotation example:

```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-options: Prune=false
```

### Sync Waves

Sync waves control the order in which resources are applied during a sync. Resources with lower wave numbers are applied first. All resources in a wave must be healthy before the next wave begins.

```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "1"
```

Resources with no annotation default to wave 0. Use negative numbers for resources that must be created very early (e.g., Namespaces, CRDs).

### Sync Phases and Hooks

Argo CD defines sync phases: PreSync, Sync, PostSync, and SyncFail. Hooks are Kubernetes resources (typically Jobs) annotated to run in a specific phase:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: db-migrate
  annotations:
    argocd.argoproj.io/hook: PreSync
    argocd.argoproj.io/hook-delete-policy: BeforeHookCreation
spec:
  template:
    spec:
      containers:
        - name: migrate
          image: my-app:v1.2.3
          command: ["python", "manage.py", "migrate"]
      restartPolicy: Never
```

Hook delete policies control when hook resources are cleaned up:

- `BeforeHookCreation`: delete the previous hook resource before creating a new one
- `HookSucceeded`: delete after the hook succeeds
- `HookFailed`: delete after the hook fails

---

## Ignore Differences

Sometimes live resources legitimately differ from Git state (e.g., a controller adds fields, or you use an operator that mutates resources). You can tell Argo CD to ignore specific differences:

```yaml
spec:
  ignoreDifferences:
    - group: apps
      kind: Deployment
      jsonPointers:
        - /spec/replicas        # Ignore replica count (managed by HPA)
    - group: ""
      kind: Service
      jsonPointers:
        - /spec/clusterIP       # Auto-assigned by Kubernetes
    - group: admissionregistration.k8s.io
      kind: MutatingWebhookConfiguration
      jqPathExpressions:
        - .webhooks[].clientConfig.caBundle  # Injected by cert-manager
```

`jsonPointers` uses RFC 6901 JSON Pointer syntax. `jqPathExpressions` uses JQ syntax for more complex matching.

---

## ApplicationSets

The `ApplicationSet` controller lets you generate multiple `Application` resources from a single template, using generators to parameterize values.

### List Generator

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: my-apps
  namespace: argocd
spec:
  generators:
    - list:
        elements:
          - cluster: staging
            url: https://staging.example.com
            env: staging
          - cluster: production
            url: https://production.example.com
            env: production
  template:
    metadata:
      name: "my-app-{{cluster}}"
    spec:
      project: default
      source:
        repoURL: https://github.com/my-org/my-app.git
        targetRevision: main
        path: "k8s/overlays/{{env}}"
      destination:
        server: "{{url}}"
        namespace: my-app
```

### Git Generator

The Git generator creates applications based on directory structure or file contents in a Git repository:

```yaml
generators:
  - git:
      repoURL: https://github.com/my-org/my-apps.git
      revision: main
      directories:
        - path: apps/*
```

This creates one Application per directory matching `apps/*`.

### Cluster Generator

Creates applications for all clusters registered with Argo CD (or a filtered subset):

```yaml
generators:
  - clusters:
      selector:
        matchLabels:
          environment: production
```

### Matrix Generator

Combines two generators to create the cartesian product:

```yaml
generators:
  - matrix:
      generators:
        - clusters: {}
        - list:
            elements:
              - app: frontend
              - app: backend
```

### SCM Provider Generator

Generates applications dynamically from repositories in a GitHub organization, GitLab group, or other SCM provider:

```yaml
generators:
  - scmProvider:
      github:
        organization: my-org
        tokenRef:
          secretName: github-token
          key: token
      filters:
        - repositoryMatch: "^app-"
```

---

## RBAC and Access Control

Argo CD has its own RBAC system layered on top of Kubernetes RBAC. Permissions are defined in the `argocd-rbac-cm` ConfigMap.

### RBAC Policy Syntax

Policies follow a Casbin-style syntax:

```
p, <subject>, <resource>, <action>, <object>, <effect>
```

- **subject**: a user (`user:alice`), group (`role:my-role`), or role name
- **resource**: `applications`, `repositories`, `clusters`, `projects`, etc.
- **action**: `get`, `create`, `update`, `delete`, `sync`, `action`, `*`
- **object**: `<project>/<app>` for applications, `*` for all
- **effect**: `allow` or `deny`

### ConfigMap Example

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: argocd
data:
  policy.default: role:readonly
  policy.csv: |
    p, role:org-admin, applications, *, */*, allow
    p, role:org-admin, clusters, get, *, allow
    p, role:org-admin, repositories, *, *, allow
    p, role:org-admin, projects, *, *, allow

    p, role:dev-team, applications, get, my-project/*, allow
    p, role:dev-team, applications, sync, my-project/*, allow

    g, alice, role:org-admin
    g, my-github-org:dev-team, role:dev-team
  scopes: "[groups]"
```

### Built-in Roles

- `role:readonly`: read-only access to all resources
- `role:admin`: full administrative access

The `policy.default` key sets the role assigned to all authenticated users not matched by a more specific rule.

---

## SSO and Authentication

### Configuring Dex (GitHub Example)

Edit `argocd-cm`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  url: https://argocd.example.com
  dex.config: |
    connectors:
      - type: github
        id: github
        name: GitHub
        config:
          clientID: my-github-client-id
          clientSecret: $dex.github.clientSecret
          orgs:
            - name: my-github-org
```

Secrets referenced with `$` syntax are pulled from the `argocd-secret` Kubernetes Secret.

### OIDC (External Provider)

If you have an existing OIDC provider (Okta, Auth0, Keycloak), you can bypass Dex:

```yaml
data:
  url: https://argocd.example.com
  oidc.config: |
    name: Okta
    issuer: https://my-org.okta.com
    clientID: my-client-id
    clientSecret: $oidc.okta.clientSecret
    requestedScopes:
      - openid
      - profile
      - email
      - groups
    requestedIDTokenClaims:
      groups:
        essential: true
```

---

## Notifications

The Argo CD Notifications controller allows you to send alerts when application events occur.

### Installation

```bash
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/notifications_catalog/install.yaml
```

### Configuration

Notifications are configured in the `argocd-notifications-cm` ConfigMap:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-notifications-cm
  namespace: argocd
data:
  service.slack: |
    token: $slack-token
  template.app-deployed: |
    message: |
      Application {{.app.metadata.name}} has been deployed.
      Sync status: {{.app.status.sync.status}}
  trigger.on-deployed: |
    - when: app.status.operationState.phase in ['Succeeded']
      send: [app-deployed]
```

Subscribe an application to a trigger:

```yaml
metadata:
  annotations:
    notifications.argoproj.io/subscribe.on-deployed.slack: my-channel
```

---

## Image Updater

Argo CD Image Updater is a companion tool that monitors container registries and automatically updates `Application` sources when new image tags are published.

### Installation

```bash
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml
```

### Annotation-Based Configuration

```yaml
metadata:
  annotations:
    argocd-image-updater.argoproj.io/image-list: my-image=my-org/my-app
    argocd-image-updater.argoproj.io/my-image.update-strategy: semver
    argocd-image-updater.argoproj.io/my-image.allow-tags: regexp:^v[0-9]+\.[0-9]+\.[0-9]+$
    argocd-image-updater.argoproj.io/write-back-method: git
    argocd-image-updater.argoproj.io/git-branch: main
```

Update strategies include `semver`, `latest`, `digest`, and `name`.

---

## GitOps Patterns and Workflows

### Repository Structure Patterns

**Monorepo:** All application manifests for all environments live in a single repository. Simple to manage at small scale; can become unwieldy as teams and apps grow.

```
repo/
  apps/
    frontend/
      base/
      overlays/
        staging/
        production/
    backend/
      ...
```

**Polyrepo (App of Apps):** Each application has its own repository. A separate "config" or "gitops" repo contains Argo CD Application manifests that point to each app repo.

**App of Apps pattern:** One Argo CD Application manages a directory of other Application manifests. This bootstraps all other applications from a single root application.

```yaml
# root-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: root
  namespace: argocd
spec:
  source:
    repoURL: https://github.com/my-org/gitops.git
    path: applications/
    targetRevision: main
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### Image Promotion Workflow

A typical promotion workflow using Argo CD:

1. A CI pipeline (GitHub Actions, GitLab CI, Jenkins) builds a new image and tags it (e.g., `v1.2.3`).
2. CI updates the image tag in the Git config repo via a commit or PR.
3. Argo CD detects the change in Git and syncs the new image to the target environment.
4. After verification in staging, a PR is opened to promote the image tag to the production overlay.
5. Merging the PR triggers Argo CD to deploy to production.

This keeps the deployment pipeline entirely version-controlled and auditable.

---

## Health Checks

### Built-in Health Checks

Argo CD ships with health checks for standard Kubernetes resources: Deployment, StatefulSet, DaemonSet, ReplicaSet, Pod, PersistentVolumeClaim, Service, Ingress, and many others.

### Custom Health Checks

For custom resources (CRDs), you can define Lua-based health checks in `argocd-cm`:

```yaml
data:
  resource.customizations.health.my-crd.io_MyResource: |
    hs = {}
    if obj.status == nil then
      hs.status = "Progressing"
      hs.message = "Waiting for status"
      return hs
    end
    if obj.status.phase == "Running" then
      hs.status = "Healthy"
    elseif obj.status.phase == "Failed" then
      hs.status = "Degraded"
      hs.message = obj.status.message
    else
      hs.status = "Progressing"
    end
    return hs
```

### Custom Resource Actions

You can define custom actions for CRDs that appear as buttons in the Argo CD UI:

```yaml
data:
  resource.customizations.actions.batch_CronJob: |
    discovery.lua: |
      actions = {}
      actions["create-job"] = {}
      return actions
    definitions:
      - name: create-job
        action.lua: |
          job = {}
          -- Lua to construct the job from the CronJob spec
          return job
```

---

## Rollbacks

### Manual Rollback via UI

In the Argo CD web UI, navigate to the application's history. Each sync is recorded with its Git revision. Select a previous revision and click "Rollback."

### Manual Rollback via CLI

```bash
# List application history
argocd app history my-app

# Rollback to a specific revision ID from the history
argocd app rollback my-app <REVISION-ID>
```

Note: Rolling back while automated sync is enabled [Inference] may result in Argo CD re-syncing to HEAD and overriding the rollback. Disable automated sync or push a revert commit to Git for a durable rollback.

### Git Revert (Recommended)

The GitOps-native approach to rollback is reverting the commit in Git:

```bash
git revert HEAD --no-edit
git push origin main
```

Argo CD detects the new commit and syncs the reverted state.

---

## Disaster Recovery

### Backing Up Argo CD State

Argo CD state consists of Kubernetes resources (Applications, AppProjects, Secrets). Export with:

```bash
argocd admin export > backup.yaml
```

Or use `kubectl`:

```bash
kubectl get applications,appprojects,secrets \
  -n argocd \
  -o yaml > backup.yaml
```

### Restoring

```bash
argocd admin import - < backup.yaml
```

### Infrastructure as Code (Recommended)

The most resilient approach is storing all Argo CD Application and AppProject manifests in Git. Combined with an App of Apps or ApplicationSet pattern, re-installing Argo CD and applying the root application is sufficient to restore all managed applications.

---

## CLI Reference

### Application Management

```bash
# List applications
argocd app list

# Get application details
argocd app get my-app

# Create an application
argocd app create my-app \
  --repo https://github.com/my-org/my-app.git \
  --path k8s/production \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace my-app

# Update application
argocd app set my-app --sync-policy automated

# Delete application
argocd app delete my-app

# Sync application
argocd app sync my-app

# Wait for sync to complete
argocd app wait my-app --sync --health --timeout 120

# Diff (show what would change)
argocd app diff my-app

# Refresh (re-pull from Git without syncing)
argocd app get my-app --refresh

# Get application logs
argocd app logs my-app --container my-container
```

### Repository Management

```bash
argocd repo list
argocd repo add https://github.com/my-org/my-repo.git --username user --password token
argocd repo rm https://github.com/my-org/my-repo.git
```

### Cluster Management

```bash
argocd cluster list
argocd cluster add my-context
argocd cluster rm https://my-cluster.example.com
```

### Project Management

```bash
argocd proj list
argocd proj create my-project
argocd proj get my-project
argocd proj delete my-project
argocd proj add-source my-project https://github.com/my-org/*
argocd proj add-destination my-project https://kubernetes.default.svc my-namespace
```

---

## Troubleshooting

### Application Stuck in Progressing

Check the resource tree in the UI for degraded sub-resources. Via CLI:

```bash
argocd app get my-app
argocd app resources my-app
```

Inspect the Kubernetes events for the failing resource:

```bash
kubectl describe deployment my-deployment -n my-app
kubectl get events -n my-app --sort-by='.lastTimestamp'
```

### OutOfSync After Sync

This can occur if:

- A controller or admission webhook is mutating resources after apply (add `ignoreDifferences` for those fields)
- The resource has `generateName` or other dynamic fields
- Server-side apply is conflicting with client-side apply (try `ServerSideApply=true` sync option)

### Repo Server Errors

Check logs:

```bash
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-repo-server
```

Common issues: invalid credentials, unreachable Git server, Helm/Kustomize version mismatch, missing Helm plugins.

### Sync Stuck

If a sync operation is stuck, you can terminate it:

```bash
argocd app terminate-op my-app
```

### Checking Component Health

```bash
kubectl get pods -n argocd
kubectl logs -n argocd deployment/argocd-application-controller
kubectl logs -n argocd deployment/argocd-server
kubectl logs -n argocd deployment/argocd-repo-server
```

### argocd-cm and argocd-secret Misconfiguration

Many issues trace back to misconfigured ConfigMaps or Secrets. Validate:

```bash
kubectl get configmap argocd-cm -n argocd -o yaml
kubectl get configmap argocd-rbac-cm -n argocd -o yaml
```

---

## Security Considerations

### Least-Privilege Service Accounts

When registering external clusters, Argo CD creates a service account with cluster-admin by default. For production, create a custom ClusterRole with only the permissions Argo CD needs to manage your specific resources.

### Restricting Repository Access with AppProjects

Use AppProjects to limit which repositories and clusters each team's applications can use. Avoid using the `default` project for production workloads, as it is unrestricted.

### Network Policies

Restrict traffic to and from Argo CD components using Kubernetes NetworkPolicies. The repo server and application controller do not need to be reachable from arbitrary pods.

### Secrets Management

Do not store secret values in Git. Use integrations with secret management tools. Common approaches:

- **Sealed Secrets**: Bitnami's controller encrypts secrets with a cluster-specific key; the encrypted form is safe to store in Git.
- **External Secrets Operator**: Syncs secrets from external stores (AWS Secrets Manager, HashiCorp Vault, GCP Secret Manager) into Kubernetes Secrets.
- **Vault Agent / Vault CSI**: Inject secrets directly into pods from HashiCorp Vault.
- **argocd-vault-plugin**: A repo server plugin that substitutes secret placeholders in manifests with values from Vault.

### Webhook Secrets

When configuring Git webhooks to trigger Argo CD refreshes, configure a webhook secret to validate that payloads originate from your Git provider:

```yaml
data:
  webhook.github.secret: $webhook.github.secret
```

### Disabling Admin Account in Production

After setting up SSO and RBAC, disable the local `admin` account:

```yaml
data:
  accounts.admin: ""  # Remove login capability
  # Or patch argocd-cm:
  admin.enabled: "false"
```

---

## Configuration Reference

### argocd-cm (Core Configuration)

```yaml
data:
  # Public URL of the Argo CD server (required for SSO callbacks)
  url: https://argocd.example.com

  # Repo poll interval (default: 3m)
  timeout.reconciliation: 180s

  # Application status cache expiry
  application.instanceLabelKey: argocd.argoproj.io/app

  # Resource tracking method: label (default), annotation, or annotation+label
  application.resourceTrackingMethod: annotation

  # Helm version to use by default
  helm.version: v3

  # Additional Kustomize build options
  kustomize.buildOptions: --enable-helm

  # GA: disable anonymous usage statistics
  ga.trackingid: ""
```

### argocd-cmd-params-cm (Server Parameters)

```yaml
data:
  # Run server without TLS (when behind a TLS-terminating proxy)
  server.insecure: "true"

  # Log level: debug, info, warn, error
  server.log.level: info

  # Application controller workers
  controller.status.processors: "20"
  controller.operation.processors: "10"

  # Repo server timeout
  reposerver.timeout.seconds: "60"
```

---

## Upgrading Argo CD

### Standard Upgrade

```bash
# Check current version
argocd version

# Apply the new manifest (replace VERSION with the target release)
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/vVERSION/manifests/install.yaml
```

Rolling upgrades across major versions require reading the migration notes in the Argo CD release changelog. In particular, CRD changes and breaking API changes are documented per release.

### Helm Upgrade

```bash
helm repo update
helm upgrade argocd argo/argo-cd \
  --namespace argocd \
  --reuse-values \
  --version NEW_CHART_VERSION
```

Always test upgrades in a non-production cluster first and review the release notes for deprecations or breaking changes.

---

## Argo CD vs Other Tools

### Argo CD vs Flux

Both are GitOps tools for Kubernetes. Argo CD provides a web UI, a CLI, multi-cluster management from a central control plane, and a richer application model. Flux is more modular and Kubernetes-native in its CRD design, with separate controllers for each concern (source, kustomization, helm release). The choice often depends on organizational preference, UI requirements, and existing toolchain.

### Argo CD vs Helm (Standalone)

Helm manages the lifecycle of chart releases in a single cluster via push. Argo CD uses Helm as a rendering engine but manages deployment lifecycle through GitOps. Argo CD adds drift detection, automatic reconciliation, and a unified view across clusters on top of Helm's templating.

### Argo CD vs CI-based Deployment

Traditional CI pipelines (e.g., a `kubectl apply` step) push changes to clusters. Argo CD pulls. The pull model means the cluster credentials do not need to live in the CI system, reducing the attack surface. It also means the cluster state is continuously reconciled, not only on pipeline runs.

---

## Further Resources

- Official documentation: https://argo-cd.readthedocs.io
- GitHub repository: https://github.com/argoproj/argo-cd
- Argo CD notifications catalog: https://github.com/argoproj-labs/argocd-notifications
- Argo CD Image Updater: https://github.com/argoproj-labs/argocd-image-updater
- ApplicationSet documentation: https://argo-cd.readthedocs.io/en/stable/user-guide/application-set/
- Community Slack: `#argo-cd` channel on the CNCF Slack workspace