## Task Management API

### Overview

The Task Management API exposes information about tasks currently running within an Elasticsearch cluster — long-running operations like reindexing, search requests, bulk operations, and internal cluster maintenance tasks. It allows operators to list, inspect, and cancel in-flight tasks, which is essential for diagnosing slow operations and recovering from runaway or stuck requests.

### What Counts as a Task

**Key Points**
- Nearly every action Elasticsearch performs internally is tracked as a task, including search requests, bulk indexing requests, reindex operations, cluster state updates, and shard-level operations.
- Each task is assigned a unique task ID, scoped to the node executing it, in the form `node_id:task_number`.
- Tasks can be parent/child structured — for example, a search request against multiple shards spawns child tasks per shard under one parent task, and cancelling the parent typically propagates cancellation intent to children.

### Listing Tasks

```
GET _tasks
```

Returns all currently running tasks across the cluster, grouped by node, including task type, action name, start time, running time, and the node executing each task.

**Key Points**
- `?actions=` filters to tasks matching an action name pattern, such as `*reindex` or `*search*`.
- `?nodes=` filters to tasks running on specific node IDs.
- `?detailed=true` includes additional per-task detail, such as a human-readable description of what the task is doing.
- `?parent_task_id=` filters to child tasks of a specific parent task.

```
GET _tasks?actions=*reindex&detailed=true
```

### Getting a Specific Task

```
GET _tasks/<task_id>
```

Returns detailed status for a single task by its `node_id:task_number` identifier, including whether it has completed and, for completed tasks that stored their result, the result itself.

### Canceling a Task

**Key Points**
- Not all tasks are cancelable — cancellation support depends on the action implementing cancellation checks internally, and cancellation is cooperative (the task must periodically check whether it's been asked to cancel) rather than a forceful kill.
- Reindex, update-by-query, and delete-by-query are commonly cancelable long-running tasks.
- Cancellation is requested, not guaranteed instantaneous — a task may take some time to notice the cancellation flag and stop.

```
POST _tasks/<task_id>/_cancel
```

```
POST _tasks/<task_id>/_cancel?wait_for_completion=false
```

- `?wait_for_completion=false` returns immediately after requesting cancellation rather than blocking until the task has actually stopped.
- `?nodes=` and `?actions=` can also be used with `_cancel` to bulk-cancel matching tasks rather than targeting a single task ID.

### Waiting for a Task to Complete

For asynchronous operations that return a task ID immediately (such as reindex run with `wait_for_completion=false`), the task's progress and eventual result can be polled:

```
GET _tasks/<task_id>?wait_for_completion=true&timeout=30s
```

This blocks until the task completes or the timeout elapses, which is useful for scripting workflows that need to know when a long-running operation has finished without polling in a loop.

### Diagram: Task Lifecycle for an Async Reindex

<svg width="100%" viewBox="0 0 680 300" role="img"><title>Task lifecycle for an asynchronous reindex operation (svg_diagram)</title><desc>A reindex request submitted with wait_for_completion false returns a task ID immediately, which can then be polled for status, waited on for completion, or cancelled.</desc>
<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<g class="node c-blue">
<rect x="40" y="30" width="220" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="150" y="50" text-anchor="middle" dominant-baseline="central">POST _reindex</text>
<text class="ts" x="150" y="70" text-anchor="middle" dominant-baseline="central">wait_for_completion=false</text>
</g>

<line x1="260" y1="58" x2="310" y2="58" class="arr" marker-end="url(#arrow)" />

<g class="node c-teal">
<rect x="310" y="30" width="200" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="410" y="50" text-anchor="middle" dominant-baseline="central">Task ID returned</text>
<text class="ts" x="410" y="70" text-anchor="middle" dominant-baseline="central">node_id:task_number</text>
</g>

<line x1="150" y1="86" x2="150" y2="140" class="arr" marker-end="url(#arrow)" />
<g class="node c-gray">
<rect x="40" y="140" width="220" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="150" y="160" text-anchor="middle" dominant-baseline="central">GET _tasks/&lt;id&gt;</text>
<text class="ts" x="150" y="180" text-anchor="middle" dominant-baseline="central">Poll for status</text>
</g>

<line x1="410" y1="86" x2="410" y2="140" class="arr" marker-end="url(#arrow)" />
<g class="node c-coral">
<rect x="310" y="140" width="200" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="410" y="160" text-anchor="middle" dominant-baseline="central">POST _cancel</text>
<text class="ts" x="410" y="180" text-anchor="middle" dominant-baseline="central">Request cancellation</text>
</g>

<line x1="150" y1="196" x2="150" y2="250" class="arr" marker-end="url(#arrow)" />
<line x1="410" y1="196" x2="270" y2="250" class="arr" marker-end="url(#arrow)" />
<g class="node c-purple">
<rect x="150" y="250" width="200" height="40" rx="8" stroke-width="0.5" />
<text class="th" x="250" y="270" text-anchor="middle" dominant-baseline="central">Task completes or stops</text>
</g>
</svg>

### Common Diagnostic Uses

**Key Points**
- Identifying a slow or stuck search request by listing tasks with `?actions=*search*` and inspecting running time to find long-running outliers.
- Diagnosing runaway bulk indexing or reindex jobs consuming excessive cluster resources, then cancelling them if needed.
- Correlating high thread pool queue/rejection counts (visible via `_cat/thread_pool` or Stack Monitoring) with specific long-running tasks holding up a thread pool.
- Auditing what operations are currently in flight before performing cluster maintenance, such as a rolling restart, to avoid interrupting critical operations mid-flight.

### Limitations and Caveats

**Key Points**
- Task cancellation is not guaranteed for every action — some internal operations do not implement cancellation hooks, so a `_cancel` request against them has no effect.
- The task list reflects a point-in-time snapshot gathered by querying all nodes, so extremely short-lived tasks may complete before or during the collection and not appear in results.
- [Unverified] Task IDs are not guaranteed stable or meaningful across node restarts, since they are scoped to a specific node's runtime, so stored task IDs should not be relied upon across a node recycling event.

### Related Topics

- **Reindex API** in depth — batching, scripting during reindex, throttling with `requests_per_second`
- **`_cat/thread_pool`** and diagnosing thread pool saturation
- **Update by query and delete by query APIs**, which share the same async task pattern as reindex
- **Cluster pending tasks API** (`_cluster/pending_tasks`) for cluster-state-update-specific task queuing, distinct from the general Task Management API
- **Search cancellation** and how client-side request cancellation (e.g. a dropped HTTP connection) interacts with server-side task cancellation
- **X-Opaque-Id header** for tagging requests to make tasks easier to correlate with their originating client request