## Architecture


A Kubernetes cluster consists of a **control plane** and one or more **worker nodes**.

### Control Plane

The control plane manages the cluster state. It makes global decisions about scheduling, detecting and responding to cluster events, and storing cluster state.

**kube-apiserver** is the front end of the control plane. All communication with the cluster goes through it — `kubectl`, other control plane components, and worker nodes all talk to the API server. It validates and processes REST requests and updates the cluster state in etcd.

**etcd** is a distributed key-value store that holds all cluster state. It is the source of truth for the cluster. Only the API server communicates with etcd directly.

**kube-scheduler** watches for newly created Pods that have no assigned node and selects a node for them to run on, based on resource requirements, affinity rules, taints, tolerations, and other constraints.

**kube-controller-manager** runs a collection of controllers as a single process. Controllers are control loops that watch the cluster state through the API server and make changes to drive the current state toward the desired state. Examples include the Node controller, Job controller, Deployment controller, and ReplicaSet controller.

**cloud-controller-manager** (optional) integrates with cloud provider APIs to manage cloud-specific resources such as load balancers, storage volumes, and node lifecycle.

### Worker Nodes

Worker nodes run the actual application workloads.

**kubelet** is an agent that runs on every node. It watches for Pods assigned to its node through the API server and ensures the containers in those Pods are running and healthy.

**kube-proxy** maintains network rules on each node to implement the Service abstraction — it enables communication to Pods from inside and outside the cluster.

**Container runtime** is the software that runs containers. Kubernetes supports any runtime implementing the Container Runtime Interface (CRI), most commonly containerd.

### Component Interaction Summary

```
kubectl / external clients
        │
        ▼
  kube-apiserver  ◄──► etcd
        │
   ┌────┴────┐
   │         │
kube-     kube-
scheduler controller-manager
   │
   ▼
Worker Node
  ├── kubelet
  ├── kube-proxy
  └── container runtime
        └── Pods (containers)
```

---

