## Kubernetes Deployment Basics

### Overview

Deploying Elasticsearch on Kubernetes is the standard approach for containerized production environments. Elastic provides an official **Kubernetes Operator** — **Elastic Cloud on Kubernetes (ECK)** — that manages the full lifecycle of Elastic Stack components as native Kubernetes resources.

This section covers:

- Core Kubernetes concepts relevant to Elasticsearch
- ECK installation and architecture
- Deploying Elasticsearch via ECK
- Deploying Kibana via ECK
- Storage, networking, and resource configuration
- Scaling and node topology
- Upgrades and common operational tasks

> ECK is the recommended and officially supported method for running Elasticsearch on Kubernetes. Manual Kubernetes deployments (without ECK) are possible but significantly increase operational complexity and are not covered in depth here.

> Verify current ECK version compatibility at [https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-quickstart.html](https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-quickstart.html) before deploying.

---

### Kubernetes Concepts Relevant to Elasticsearch

Understanding the following Kubernetes primitives is necessary before deploying Elasticsearch on Kubernetes.

#### Pod

The smallest deployable unit in Kubernetes. Each Elasticsearch node runs as a Pod containing one primary container (the Elasticsearch process) and potentially init containers and sidecar containers.

#### StatefulSet

Elasticsearch nodes are managed via **StatefulSets**, not Deployments. StatefulSets provide:

- **Stable, persistent network identities** — each Pod gets a consistent DNS name (e.g., `elasticsearch-es-default-0`)
- **Ordered, graceful deployment and scaling**
- **Stable storage** — each Pod gets its own PersistentVolumeClaim that persists across Pod restarts

ECK manages StatefulSets automatically; operators do not create them directly.

#### PersistentVolume (PV) and PersistentVolumeClaim (PVC)

Elasticsearch data must persist beyond the lifecycle of individual Pods. Kubernetes handles this via:

- **PersistentVolume (PV)** — a piece of storage provisioned in the cluster (by an administrator or dynamically)
- **PersistentVolumeClaim (PVC)** — a Pod's request for storage, bound to a PV
- **StorageClass** — defines how storage is dynamically provisioned (e.g., SSD via `gp3` on AWS, `pd-ssd` on GCP)

Each Elasticsearch Pod in an ECK-managed StatefulSet gets its own PVC, ensuring data is not shared or lost on Pod restart.

#### ConfigMap and Secret

- **ConfigMap** — stores non-sensitive configuration data as key-value pairs
- **Secret** — stores sensitive data (passwords, certificates, tokens) in base64-encoded form

ECK automatically manages Secrets for TLS certificates and user credentials.

#### Service

A Kubernetes Service provides a stable network endpoint for accessing Pods. ECK creates several Services per Elasticsearch cluster:

|Service|Purpose|
|---|---|
|`<name>-es-http`|External HTTP/HTTPS access to Elasticsearch|
|`<name>-es-transport`|Inter-node transport communication (internal)|
|`<name>-es-internal-http`|Internal cluster HTTP communication|

#### Namespace

Kubernetes resources are organized into **Namespaces**. ECK and Elastic Stack resources are typically deployed in a dedicated namespace (e.g., `elastic-system` for ECK, `default` or a custom namespace for clusters).

#### Custom Resource Definition (CRD)

ECK extends the Kubernetes API by registering **Custom Resource Definitions** — new resource types that Kubernetes learns to manage. These include:

|CRD|Resource Kind|
|---|---|
|`elasticsearches.elasticsearch.k8s.elastic.co`|`Elasticsearch`|
|`kibanas.kibana.k8s.elastic.co`|`Kibana`|
|`agents.agent.k8s.elastic.co`|`Agent`|
|`beats.beat.k8s.elastic.co`|`Beat`|
|`logstashes.logstash.k8s.elastic.co`|`Logstash`|
|`elasticmapsservers.maps.k8s.elastic.co`|`ElasticMapsServer`|

---

### ECK Architecture

```
[Kubernetes API Server]
        ↕
[ECK Operator Pod]  ← watches CRDs, reconciles desired state
        ↕
[StatefulSets / Pods / Services / Secrets / PVCs]
        ↕
[Elasticsearch Pods]  ←→  [Kibana Pods]  ←→  [Agent Pods]
```

The ECK operator runs as a Deployment in the `elastic-system` namespace. It continuously watches ECK custom resources and reconciles the actual cluster state to match the desired state defined in those resources. This means:

- If a Pod crashes, ECK detects the drift and restores it.
- If the `Elasticsearch` spec is updated (e.g., node count increased), ECK applies the change safely.
- TLS certificates are automatically rotated by ECK before expiry.

---

### Prerequisites

|Requirement|Detail|
|---|---|
|**Kubernetes version**|1.27 or later recommended (verify ECK compatibility matrix)|
|**kubectl**|Configured and authenticated against the target cluster|
|**Cluster permissions**|`cluster-admin` role or equivalent for CRD installation|
|**StorageClass**|A default or named StorageClass capable of dynamic provisioning|
|**vm.max_map_count**|Set to `262144` on all nodes that will run Elasticsearch Pods|
|**Resource availability**|Sufficient CPU and memory quota in the target namespace|

#### Setting vm.max_map_count on Kubernetes Nodes

This is one of the most common prerequisites that is missed. It must be set on the **host OS** of each Kubernetes node, not inside the container.

**Option A — DaemonSet with privileged init container (recommended for managed clusters):**

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: max-map-count-setter
  namespace: elastic-system
spec:
  selector:
    matchLabels:
      app: max-map-count-setter
  template:
    metadata:
      labels:
        app: max-map-count-setter
    spec:
      initContainers:
        - name: max-map-count-setter
          image: docker.io/bash:5
          command: ['/usr/local/bin/bash', '-e', '-c', 'echo 262144 > /proc/sys/vm/max_map_count']
          securityContext:
            privileged: true
          volumeMounts:
            - name: proc
              mountPath: /proc
      containers:
        - name: sleep
          image: docker.io/bash:5
          command: ['sleep', 'infinity']
      volumes:
        - name: proc
          hostPath:
            path: /proc
```

**Option B — Node-level configuration (for self-managed nodes):**

```bash
# On each Kubernetes worker node
sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
```

**Option C — ECK init container per Pod (alternative):**

```yaml
podTemplate:
  spec:
    initContainers:
      - name: sysctl
        securityContext:
          privileged: true
        command: ['sh', '-c', 'sysctl -w vm.max_map_count=262144']
```

> Option C requires Pods to have `privileged` security context, which may conflict with Pod Security Standards or OPA/Gatekeeper policies in hardened clusters. [Inference]

---

### Installing ECK

#### Step 1 — Install ECK CRDs and Operator

```bash
kubectl create -f https://download.elastic.co/downloads/eck/2.13.0/crds.yaml
kubectl apply -f https://download.elastic.co/downloads/eck/2.13.0/operator.yaml
```

> Replace `2.13.0` with the current ECK version. Always check the ECK release page for the latest version.

This creates:

- The `elastic-system` namespace
- ECK Custom Resource Definitions
- The ECK operator Deployment, ServiceAccount, ClusterRole, and ClusterRoleBinding

#### Step 2 — Verify the Operator is Running

```bash
kubectl get pods -n elastic-system
```

**Expected output:**

```
NAME                             READY   STATUS    RESTARTS   AGE
elastic-operator-0               1/1     Running   0          60s
```

#### Step 3 — Monitor ECK Operator Logs

```bash
kubectl logs -n elastic-system elastic-operator-0 -f
```

---

### Deploying Elasticsearch

#### Minimal Single-Node Development Cluster

```yaml
# elasticsearch-dev.yaml
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: quickstart
  namespace: default
spec:
  version: 8.13.0
  nodeSets:
    - name: default
      count: 1
      config:
        node.store.allow_mmap: false  # Disable mmap for dev (avoids vm.max_map_count requirement)
```

```bash
kubectl apply -f elasticsearch-dev.yaml
```

> `node.store.allow_mmap: false` disables memory-mapped files, which avoids the `vm.max_map_count` requirement but [Inference] may reduce performance compared to mmap-enabled configurations. It is suitable for development only.

#### Monitor Deployment

```bash
# Watch cluster status
kubectl get elasticsearch

# Expected output when ready:
# NAME         HEALTH   NODES   VERSION   PHASE   AGE
# quickstart   green    1       8.13.0    Ready   2m
```

```bash
# Watch Pods
kubectl get pods -l common.k8s.elastic.co/type=elasticsearch
```

```bash
# Describe the Elasticsearch resource for events and status
kubectl describe elasticsearch quickstart
```

#### Retrieve the Auto-Generated Password

ECK creates a Secret named `<cluster-name>-es-elastic-user` containing the `elastic` user password:

```bash
kubectl get secret quickstart-es-elastic-user \
  -o jsonpath='{.data.password}' | base64 --decode
```

#### Access Elasticsearch from Outside the Cluster

The default Service type is `ClusterIP` — accessible only within the cluster. To access from a local machine:

**Port-forward:**

```bash
kubectl port-forward service/quickstart-es-http 9200:9200
```

Then in another terminal:

```bash
PASSWORD=$(kubectl get secret quickstart-es-elastic-user \
  -o jsonpath='{.data.password}' | base64 --decode)

curl -u "elastic:$PASSWORD" -k https://localhost:9200
```

---

### Production-Grade Elasticsearch Deployment

#### Multi-Node Cluster with Role Separation

```yaml
# elasticsearch-production.yaml
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: production
  namespace: elastic-system
spec:
  version: 8.13.0

  nodeSets:

    # Dedicated master nodes
    - name: masters
      count: 3
      config:
        node.roles: ["master"]
        node.store.allow_mmap: true
      podTemplate:
        spec:
          containers:
            - name: elasticsearch
              resources:
                requests:
                  memory: 4Gi
                  cpu: 1
                limits:
                  memory: 4Gi
                  cpu: 2
          initContainers:
            - name: sysctl
              securityContext:
                privileged: true
              command: ['sh', '-c', 'sysctl -w vm.max_map_count=262144']
      volumeClaimTemplates:
        - metadata:
            name: elasticsearch-data
          spec:
            accessModes:
              - ReadWriteOnce
            resources:
              requests:
                storage: 10Gi
            storageClassName: standard

    # Hot data nodes
    - name: hot
      count: 3
      config:
        node.roles: ["data_hot", "data_content", "ingest"]
        node.store.allow_mmap: true
        node.attr.data: hot
      podTemplate:
        spec:
          containers:
            - name: elasticsearch
              resources:
                requests:
                  memory: 16Gi
                  cpu: 4
                limits:
                  memory: 16Gi
                  cpu: 8
          initContainers:
            - name: sysctl
              securityContext:
                privileged: true
              command: ['sh', '-c', 'sysctl -w vm.max_map_count=262144']
      volumeClaimTemplates:
        - metadata:
            name: elasticsearch-data
          spec:
            accessModes:
              - ReadWriteOnce
            resources:
              requests:
                storage: 500Gi
            storageClassName: fast-ssd

    # Warm data nodes
    - name: warm
      count: 2
      config:
        node.roles: ["data_warm"]
        node.store.allow_mmap: true
        node.attr.data: warm
      podTemplate:
        spec:
          containers:
            - name: elasticsearch
              resources:
                requests:
                  memory: 8Gi
                  cpu: 2
                limits:
                  memory: 8Gi
                  cpu: 4
      volumeClaimTemplates:
        - metadata:
            name: elasticsearch-data
          spec:
            accessModes:
              - ReadWriteOnce
            resources:
              requests:
                storage: 2Ti
            storageClassName: standard

    # Coordinating-only nodes
    - name: coordinating
      count: 2
      config:
        node.roles: []
      podTemplate:
        spec:
          containers:
            - name: elasticsearch
              resources:
                requests:
                  memory: 8Gi
                  cpu: 2
                limits:
                  memory: 8Gi
                  cpu: 4
      volumeClaimTemplates:
        - metadata:
            name: elasticsearch-data
          spec:
            accessModes:
              - ReadWriteOnce
            resources:
              requests:
                storage: 10Gi
            storageClassName: standard
```

#### Key Configuration Sections Explained

##### nodeSets

Each `nodeSet` defines a group of Elasticsearch nodes sharing the same configuration, resource profile, and storage. Multiple nodeSets allow different hardware profiles for different node roles — a core best practice for production clusters.

##### node.roles

Explicitly defining roles prevents nodes from taking on unintended responsibilities:

|Role|Purpose|
|---|---|
|`master`|Cluster coordination and metadata management|
|`data_hot`|Active indexing and fast search|
|`data_warm`|Less frequently queried data|
|`data_cold`|Infrequently accessed data|
|`data_frozen`|Partially mounted data from snapshots|
|`data_content`|Non-time-series data|
|`ingest`|Ingest pipeline processing|
|`ml`|Machine learning jobs|
|`remote_cluster_client`|Cross-cluster search/replication|
|`[]` (empty)|Coordinating only|

##### podTemplate

The `podTemplate` follows standard Kubernetes Pod specification. It allows full control over:

- Container resource requests and limits
- Init containers (e.g., sysctl settings)
- Affinity and anti-affinity rules
- Tolerations
- Environment variables
- Volume mounts

##### volumeClaimTemplates

Defines the PersistentVolumeClaim template for each node's data storage. Each Pod in the nodeSet gets its own PVC of the specified size and StorageClass.

---

### Pod Affinity and Anti-Affinity

Distributing Elasticsearch Pods across availability zones and nodes is critical for fault tolerance.

#### Spread Masters Across Nodes

```yaml
podTemplate:
  spec:
    affinity:
      podAntiAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchLabels:
                elasticsearch.k8s.elastic.co/cluster-name: production
                elasticsearch.k8s.elastic.co/node-master: "true"
            topologyKey: kubernetes.io/hostname
```

#### Spread Data Nodes Across Availability Zones

```yaml
podTemplate:
  spec:
    affinity:
      podAntiAffinity:
        preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchLabels:
                  elasticsearch.k8s.elastic.co/cluster-name: production
              topologyKey: topology.kubernetes.io/zone
```

> `requiredDuringScheduling` prevents scheduling if the constraint cannot be met (hard rule). `preferredDuringScheduling` attempts to meet the constraint but allows scheduling if not possible (soft rule). Choose based on your fault tolerance requirements.

---

### Deploying Kibana

ECK manages Kibana as a separate custom resource that automatically connects to a referenced Elasticsearch cluster.

```yaml
# kibana.yaml
apiVersion: kibana.k8s.elastic.co/v1
kind: Kibana
metadata:
  name: quickstart
  namespace: default
spec:
  version: 8.13.0
  count: 1
  elasticsearchRef:
    name: quickstart        # Must match the Elasticsearch resource name
  podTemplate:
    spec:
      containers:
        - name: kibana
          resources:
            requests:
              memory: 1Gi
              cpu: 500m
            limits:
              memory: 2Gi
              cpu: 2
```

```bash
kubectl apply -f kibana.yaml
```

#### Monitor Kibana Deployment

```bash
kubectl get kibana
```

**Expected output:**

```
NAME         HEALTH   NODES   VERSION   AGE
quickstart   green    1       8.13.0    90s
```

#### Access Kibana

```bash
kubectl port-forward service/quickstart-kb-http 5601:5601
```

Open `https://localhost:5601` in a browser. Log in with username `elastic` and the auto-generated password retrieved earlier.

> ECK automatically configures Kibana to trust the Elasticsearch TLS certificate and sets the `kibana_system` user credentials. No manual connection configuration is needed.

---

### Exposing Services Externally

#### LoadBalancer Service

For cloud providers that support LoadBalancer provisioning:

```yaml
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: production
spec:
  version: 8.13.0
  http:
    service:
      spec:
        type: LoadBalancer
  nodeSets:
    - name: default
      count: 3
```

#### Ingress Controller

For HTTP/HTTPS routing via an Ingress controller (e.g., nginx-ingress):

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: elasticsearch-ingress
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    nginx.ingress.kubernetes.io/ssl-passthrough: "true"
spec:
  ingressClassName: nginx
  rules:
    - host: elasticsearch.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: production-es-http
                port:
                  number: 9200
```

> TLS passthrough (`ssl-passthrough`) is required if Elasticsearch's own TLS certificate is to be presented directly to clients. Alternatively, TLS termination can be handled at the Ingress layer with Elasticsearch's TLS disabled — though this is [Inference] only appropriate in environments where the network path between the Ingress and Elasticsearch is trusted and secured by other means.

---

### Custom Elasticsearch Configuration

Additional `elasticsearch.yml` settings are passed via the `config` block in the nodeSet:

```yaml
nodeSets:
  - name: default
    count: 3
    config:
      node.roles: ["master", "data", "ingest"]
      cluster.routing.allocation.disk.watermark.low: "85%"
      cluster.routing.allocation.disk.watermark.high: "90%"
      cluster.routing.allocation.disk.watermark.flood_stage: "95%"
      indices.memory.index_buffer_size: "20%"
      thread_pool.write.queue_size: 1000
      xpack.ml.enabled: true
```

#### Keystore Secrets

Sensitive settings (API keys, S3 credentials, SMTP passwords) should be stored in the Elasticsearch keystore rather than `elasticsearch.yml`. ECK manages keystore entries via Kubernetes Secrets:

```yaml
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: production
spec:
  version: 8.13.0
  secureSettings:
    - secretName: s3-credentials
  nodeSets:
    - name: default
      count: 3
```

The referenced Secret:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: s3-credentials
stringData:
  s3.client.default.access_key: "AKIAIOSFODNN7EXAMPLE"
  s3.client.default.secret_key: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
```

---

### Scaling

#### Horizontal Scaling (Adding Nodes)

Update the `count` in the relevant nodeSet and apply:

```yaml
nodeSets:
  - name: hot
    count: 5    # Previously 3
```

```bash
kubectl apply -f elasticsearch-production.yaml
```

ECK detects the change, provisions new Pods and PVCs, and adds the nodes to the cluster. Shard rebalancing occurs automatically.

#### Vertical Scaling (Changing Resources)

Update the container resource requests/limits in `podTemplate` and apply. ECK performs a rolling restart of the affected nodeSet.

```yaml
containers:
  - name: elasticsearch
    resources:
      requests:
        memory: 32Gi    # Increased from 16Gi
        cpu: 8
      limits:
        memory: 32Gi
        cpu: 8
```

> Vertical scaling triggers a rolling restart. Plan for temporary reduction in cluster capacity during the restart. [Inference] The impact depends on cluster size, shard distribution, and replica configuration.

---

### Upgrading Elasticsearch

ECK handles version upgrades via rolling restarts when the `version` field is updated:

```yaml
spec:
  version: 8.14.0    # Updated from 8.13.0
```

```bash
kubectl apply -f elasticsearch-production.yaml
```

ECK upgrades nodes one at a time, ensuring the cluster remains available throughout. During the upgrade:

- ECK disables shard allocation before restarting each node.
- After the node rejoins the cluster, ECK re-enables allocation before proceeding to the next node.

> Always review the Elasticsearch upgrade documentation for breaking changes before applying a major or minor version upgrade. ECK does not validate semantic compatibility of the upgrade path. [Inference]

---

### Monitoring ECK-Managed Clusters

#### Cluster Status via kubectl

```bash
# Elasticsearch
kubectl get elasticsearch -A

# Kibana
kubectl get kibana -A

# All ECK resources
kubectl get elastic -A
```

#### Pod Status

```bash
kubectl get pods -l common.k8s.elastic.co/type=elasticsearch -n elastic-system
```

#### Resource Events

```bash
kubectl describe elasticsearch production -n elastic-system
```

#### Stack Monitoring

ECK supports configuring **Stack Monitoring** to ship cluster metrics to a dedicated monitoring cluster:

```yaml
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: production
spec:
  version: 8.13.0
  monitoring:
    metrics:
      elasticsearchRefs:
        - name: monitoring-cluster
    logs:
      elasticsearchRefs:
        - name: monitoring-cluster
  nodeSets:
    - name: default
      count: 3
```

---

### Common Operational Tasks

#### Get Elasticsearch Cluster Health via kubectl exec

```bash
kubectl exec -it production-es-default-0 -n elastic-system -- \
  curl -s -u "elastic:$PASSWORD" -k https://localhost:9200/_cluster/health?pretty
```

#### View Elasticsearch Logs

```bash
kubectl logs production-es-default-0 -n elastic-system -f
```

#### Access Elasticsearch Shell

```bash
kubectl exec -it production-es-default-0 -n elastic-system -- bash
```

#### Delete an ECK-Managed Cluster

```bash
# Deletes the Elasticsearch resource and associated Pods, Services, Secrets
# PVCs are NOT automatically deleted — data is preserved by default
kubectl delete elasticsearch quickstart

# To also remove PVCs (data loss):
kubectl delete pvc -l elasticsearch.k8s.elastic.co/cluster-name=quickstart
```

---

### ECK Licensing

ECK operates under two license tiers:

|Tier|Features|License Required|
|---|---|---|
|**Basic (free)**|Core deployment, TLS, basic monitoring|None|
|**Enterprise**|Hot-warm-cold topology, autoscaling, advanced monitoring, cross-cluster features|Elastic Enterprise license|

A **trial license** (30 days) can be activated to evaluate Enterprise features:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: eck-trial-license
  namespace: elastic-system
  labels:
    license.k8s.elastic.co/type: trial
data: {}
```

---

### Summary: ECK Resource Hierarchy

```
Namespace
└── Elasticsearch (CRD)
    ├── StatefulSet(s) — one per nodeSet
    │   └── Pods — one per node count
    │       └── PersistentVolumeClaim — one per Pod
    ├── Services (http, transport, internal-http)
    └── Secrets (TLS certs, elastic-user password)

Namespace
└── Kibana (CRD)
    ├── Deployment
    │   └── Pods
    ├── Service (http)
    └── Secrets (TLS certs, kibana_system credentials)
```

---

**Conclusion**

ECK provides a robust, declarative approach to managing Elasticsearch on Kubernetes. By modeling Elasticsearch clusters as Kubernetes custom resources, ECK handles the complexity of TLS certificate management, rolling upgrades, credential rotation, and StatefulSet lifecycle management. The key operational concerns for production deployments are correct `vm.max_map_count` configuration on worker nodes, appropriate StorageClass selection for persistent volumes, role-separated nodeSets with defined resource limits, and Pod anti-affinity rules to distribute nodes across failure domains.

===END_SYLLABOT_RESPONSE_7be29025d26b4c6c===