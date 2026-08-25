## DaemonSets


### Node-Level Workloads

DaemonSets ensure that specific pods run on all or selected nodes within a Kubernetes cluster, providing a mechanism for deploying node-level infrastructure components. Unlike other workload controllers that focus on application scaling, DaemonSets maintain exactly one pod per eligible node, automatically handling pod placement as nodes are added or removed from the cluster.

The primary purpose of DaemonSets is to deploy system-level services that need to run on every node to provide cluster-wide functionality. These services typically operate at the infrastructure layer, providing capabilities like monitoring, logging, networking, or security that benefit all workloads running on the node.

Node affinity and node selectors control which nodes receive DaemonSet pods, enabling targeted deployment based on node characteristics. This selective deployment is crucial when certain workloads should only run on specific node types, such as GPU-enabled nodes or nodes with particular hardware configurations.

DaemonSet pods are scheduled by the DaemonSet controller rather than the default scheduler, ensuring they can be placed even on nodes that might be cordoned or have resource constraints. This behavior is essential for infrastructure components that must run regardless of node conditions.

Tolerations allow DaemonSet pods to run on nodes with taints, ensuring critical infrastructure components can operate even on nodes that normally reject pod scheduling. Common scenarios include running monitoring agents on master nodes or deploying networking components on nodes marked for maintenance.

Resource management for DaemonSet pods requires careful consideration since they compete with application workloads for node resources. Setting appropriate resource requests and limits ensures infrastructure components don't starve applications while maintaining their own operational requirements.

### Log Collection and Monitoring Agents

Log collection represents one of the most common DaemonSet use cases, deploying agents that gather logs from all containers running on each node. These agents provide centralized logging capabilities by collecting, processing, and forwarding log data to centralized logging systems.

Fluentd and Fluent Bit are popular log collection agents deployed via DaemonSets, offering lightweight log forwarding with parsing and transformation capabilities. These agents can read container logs directly from the node's filesystem, eliminating the need for application-level logging configuration.

Log parsing and enrichment occur at the agent level, where raw log data is processed to extract structured information, add metadata like pod names and namespaces, and apply filtering rules. This processing reduces the burden on centralized logging systems and improves log searchability.

Multiple log destinations can be configured, allowing agents to forward logs to different systems based on content, source, or other criteria. This flexibility supports complex logging architectures where different log types require different processing or retention policies.

Monitoring agents deployed through DaemonSets collect system and application metrics from each node, providing comprehensive observability across the cluster. These agents typically expose metrics in formats compatible with monitoring systems like Prometheus.

Node Exporter exemplifies monitoring DaemonSet usage, collecting hardware and OS metrics from each node including CPU usage, memory consumption, disk I/O, and network statistics. This data provides essential insights into cluster health and resource utilization.

Application metric collection can be handled by monitoring agents that discover and scrape metrics from pods running on the same node. This approach reduces network overhead and provides efficient metric collection for dynamic workloads.

### DaemonSet Update Strategies

Rolling updates represent the default update strategy for DaemonSets, gradually replacing pods on each node with new versions. This approach ensures continuous service availability while updating infrastructure components across the cluster.

The rolling update process respects the maxUnavailable parameter, which controls how many nodes can simultaneously have their DaemonSet pods unavailable during updates. This setting balances update speed with service availability requirements.

Update progression can be monitored through DaemonSet status fields, which track the number of nodes with current, updated, and ready pods. This information helps operators understand update progress and identify potential issues.

OnDelete update strategy provides manual control over pod updates, requiring operators to explicitly delete pods to trigger replacement with new versions. This strategy is useful when updates require careful coordination or when infrastructure changes need precise timing.

Rollback capabilities allow reverting to previous DaemonSet versions when updates introduce issues. The rollback process follows the same update strategy rules, ensuring controlled reversion to known-good configurations.

Update validation should include health checks and monitoring to ensure new versions function correctly before proceeding with cluster-wide deployment. This validation is particularly important for infrastructure components where failures can affect entire nodes.

Canary deployments for DaemonSets can be implemented using node selectors to deploy new versions to specific nodes first, allowing validation before broader rollout. This approach provides additional safety for critical infrastructure updates.

Maintenance windows may be required for certain DaemonSet updates, especially when changes affect node-level configurations or require service restarts. Planning these windows ensures minimal impact on running workloads.

**Key points**: DaemonSets provide essential infrastructure for node-level workloads, ensuring critical services run on every eligible node in the cluster. Log collection and monitoring agents represent the most common DaemonSet use cases, providing cluster-wide observability capabilities. Rolling update strategies enable safe infrastructure updates while maintaining service availability.

**Example**: A typical cluster might deploy Fluentd for log collection, Node Exporter for monitoring, and a CNI plugin for networking as DaemonSets. These components would use rolling updates with maxUnavailable set to 1 to ensure gradual, safe updates across all nodes.

**Conclusion**: DaemonSets are fundamental for maintaining cluster infrastructure, providing the foundation for logging, monitoring, and other essential services. Understanding their update strategies and management techniques is crucial for maintaining reliable, observable Kubernetes environments.

---

