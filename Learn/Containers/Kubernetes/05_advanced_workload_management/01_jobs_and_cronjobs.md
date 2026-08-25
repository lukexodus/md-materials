## Jobs and CronJobs


### Running Batch Workloads with Jobs

Jobs in Kubernetes are designed to run pods to completion, making them ideal for batch processing, data migration, backups, and other finite tasks that need to run once or a specific number of times.

#### Basic Job Configuration

**Simple Job:**

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: data-processing-job
spec:
  template:
    spec:
      containers:
      - name: data-processor
        image: busybox
        command: ['sh', '-c']
        args:
        - |
          echo "Starting data processing..."
          sleep 30
          echo "Processing complete"
      restartPolicy: Never
  backoffLimit: 4
```

**Job with Specific Completion Requirements:**

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: batch-job
spec:
  completions: 3
  parallelism: 2
  template:
    spec:
      containers:
      - name: worker
        image: perl
        command: ["perl", "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
  backoffLimit: 4
  activeDeadlineSeconds: 300
```

#### Job Specifications and Behavior

**Job Spec Fields:**

- `completions`: Number of successful pod completions required
- `parallelism`: Maximum number of pods running simultaneously
- `backoffLimit`: Number of retries before marking job as failed
- `activeDeadlineSeconds`: Maximum time job can run before termination
- `ttlSecondsAfterFinished`: Cleanup delay after job completion

**Job with Resource Limits:**

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: resource-limited-job
spec:
  template:
    spec:
      containers:
      - name: cpu-intensive-task
        image: busybox
        command: ['sh', '-c']
        args:
        - |
          for i in $(seq 1 100); do
            echo "Processing batch $i"
            sleep 1
          done
        resources:
          requests:
            memory: "256Mi"
            cpu: "200m"
          limits:
            memory: "512Mi"
            cpu: "500m"
      restartPolicy: Never
  backoffLimit: 3
  activeDeadlineSeconds: 600
```

#### Job Management Commands

```bash
# Create job
kubectl apply -f job.yaml

# List jobs
kubectl get jobs

# Describe job
kubectl describe job data-processing-job

# View job logs
kubectl logs job/data-processing-job

# Delete job
kubectl delete job data-processing-job

# Delete job and associated pods
kubectl delete job data-processing-job --cascade=foreground
```

### Parallel and Sequential Job Execution

Jobs can be configured to run multiple pods in parallel or sequentially, depending on the workload requirements.

#### Parallel Job Patterns

**Fixed Completion Count with Parallelism:**

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: parallel-fixed-job
spec:
  completions: 10
  parallelism: 3
  template:
    spec:
      containers:
      - name: worker
        image: busybox
        command: ['sh', '-c']
        args:
        - |
          TASK_ID=$((RANDOM % 1000))
          echo "Processing task $TASK_ID"
          sleep $((RANDOM % 30 + 10))
          echo "Task $TASK_ID completed"
      restartPolicy: Never
  backoffLimit: 6
```

**Work Queue Pattern:**

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: work-queue-job
spec:
  parallelism: 5
  template:
    spec:
      containers:
      - name: worker
        image: myapp/queue-worker:latest
        env:
        - name: QUEUE_URL
          value: "redis://redis-service:6379/0"
        - name: WORKER_ID
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        command: ['python', 'worker.py']
      restartPolicy: Never
  backoffLimit: 10
```

**Indexed Job (Kubernetes 1.21+):**

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: indexed-job
spec:
  completions: 5
  parallelism: 3
  completionMode: Indexed
  template:
    spec:
      containers:
      - name: worker
        image: busybox
        command: ['sh', '-c']
        args:
        - |
          echo "Processing job with index: $JOB_COMPLETION_INDEX"
          # Process specific data slice based on index
          START=$((JOB_COMPLETION_INDEX * 100))
          END=$(((JOB_COMPLETION_INDEX + 1) * 100))
          echo "Processing records $START to $END"
          sleep 20
      restartPolicy: Never
  backoffLimit: 4
```

#### Sequential Job Execution

**Chain of Jobs with Dependencies:**

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: stage-1-job
spec:
  template:
    spec:
      containers:
      - name: stage1
        image: busybox
        command: ['sh', '-c']
        args:
        - |
          echo "Stage 1: Data extraction"
          # Extract data logic
          echo "Stage 1 complete"
      restartPolicy: Never
---
apiVersion: batch/v1
kind: Job
metadata:
  name: stage-2-job
spec:
  template:
    spec:
      initContainers:
      - name: wait-for-stage1
        image: busybox
        command: ['sh', '-c']
        args:
        - |
          while ! kubectl get job stage-1-job -o jsonpath='{.status.conditions[?(@.type=="Complete")].status}' | grep -q True; do
            echo "Waiting for stage 1 to complete..."
            sleep 10
          done
      containers:
      - name: stage2
        image: busybox
        command: ['sh', '-c']
        args:
        - |
          echo "Stage 2: Data transformation"
          # Transform data logic
          echo "Stage 2 complete"
      restartPolicy: Never
```

#### Advanced Parallel Processing

**Job with Shared Storage:**

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: shared-storage-job
spec:
  completions: 3
  parallelism: 2
  template:
    spec:
      containers:
      - name: processor
        image: busybox
        command: ['sh', '-c']
        args:
        - |
          WORKER_ID=$(hostname)
          echo "Worker $WORKER_ID processing files"
          ls -la /shared-data/
          # Process files in shared storage
          echo "Worker $WORKER_ID completed"
        volumeMounts:
        - name: shared-storage
          mountPath: /shared-data
      volumes:
      - name: shared-storage
        persistentVolumeClaim:
          claimName: shared-pvc
      restartPolicy: Never
  backoffLimit: 3
```

### Scheduling Recurring Tasks with CronJobs

CronJobs schedule Jobs to run at specific times or intervals, similar to Unix cron jobs.

#### Basic CronJob Configuration

**Simple CronJob:**

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: daily-backup
spec:
  schedule: "0 2 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: busybox
            command: ['sh', '-c']
            args:
            - |
              echo "Starting backup at $(date)"
              # Backup logic here
              echo "Backup completed at $(date)"
          restartPolicy: OnFailure
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
```

**CronJob with Advanced Scheduling:**

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: report-generator
spec:
  schedule: "0 9 * * MON"  # Every Monday at 9 AM
  timeZone: "America/New_York"
  concurrencyPolicy: Forbid
  suspend: false
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: report-generator
            image: reporting-app:latest
            env:
            - name: REPORT_TYPE
              value: "weekly"
            - name: OUTPUT_PATH
              value: "/reports"
            volumeMounts:
            - name: reports-volume
              mountPath: /reports
          volumes:
          - name: reports-volume
            persistentVolumeClaim:
              claimName: reports-pvc
          restartPolicy: OnFailure
  successfulJobsHistoryLimit: 5
  failedJobsHistoryLimit: 3
```

#### CronJob Schedule Formats

**Common Schedule Patterns:**

```yaml
# Every minute
schedule: "* * * * *"

# Every hour at minute 0
schedule: "0 * * * *"

# Every day at 2:30 AM
schedule: "30 2 * * *"

# Every Monday at 9 AM
schedule: "0 9 * * 1"

# Every 15 minutes
schedule: "*/15 * * * *"

# Twice daily (6 AM and 6 PM)
schedule: "0 6,18 * * *"

# Every weekday at 8 AM
schedule: "0 8 * * 1-5"

# First day of every month at midnight
schedule: "0 0 1 * *"
```

#### CronJob Concurrency Management

**Concurrency Policies:**

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: concurrent-job-example
spec:
  schedule: "*/5 * * * *"
  concurrencyPolicy: Allow  # Allow concurrent executions
  # concurrencyPolicy: Forbid  # Skip new job if previous is running
  # concurrencyPolicy: Replace  # Cancel previous job and start new one
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: long-running-task
            image: busybox
            command: ['sh', '-c']
            args:
            - |
              echo "Starting long task at $(date)"
              sleep 600  # 10 minutes
              echo "Task completed at $(date)"
          restartPolicy: OnFailure
```

#### CronJob with Complex Configuration

**Production-Ready CronJob:**

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: data-sync-job
  labels:
    app: data-sync
    component: batch
spec:
  schedule: "0 */6 * * *"  # Every 6 hours
  timeZone: "UTC"
  concurrencyPolicy: Forbid
  suspend: false
  startingDeadlineSeconds: 300
  jobTemplate:
    spec:
      activeDeadlineSeconds: 3600  # 1 hour timeout
      backoffLimit: 3
      template:
        metadata:
          labels:
            app: data-sync
            job-type: sync
        spec:
          containers:
          - name: sync-worker
            image: data-sync:v1.2.3
            env:
            - name: SOURCE_DB
              valueFrom:
                configMapKeyRef:
                  name: sync-config
                  key: source_db_url
            - name: TARGET_DB
              valueFrom:
                secretKeyRef:
                  name: sync-secrets
                  key: target_db_url
            - name: SYNC_TIMESTAMP
              value: "$(date -u +%Y%m%d%H%M%S)"
            resources:
              requests:
                memory: "512Mi"
                cpu: "250m"
              limits:
                memory: "1Gi"
                cpu: "500m"
            volumeMounts:
            - name: temp-storage
              mountPath: /tmp/sync
          volumes:
          - name: temp-storage
            emptyDir: {}
          restartPolicy: OnFailure
  successfulJobsHistoryLimit: 5
  failedJobsHistoryLimit: 3
```

### Job Cleanup and Retention Policies

Proper cleanup prevents resource accumulation and maintains cluster performance.

#### Automatic Cleanup with TTL

**TTL Controller for Jobs:**

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: self-cleaning-job
spec:
  ttlSecondsAfterFinished: 300  # Cleanup after 5 minutes
  template:
    spec:
      containers:
      - name: worker
        image: busybox
        command: ['sh', '-c']
        args:
        - |
          echo "Running temporary job"
          sleep 60
          echo "Job completed"
      restartPolicy: Never
```

**CronJob with Cleanup Configuration:**

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: cleanup-aware-cronjob
spec:
  schedule: "0 * * * *"
  jobTemplate:
    spec:
      ttlSecondsAfterFinished: 3600  # Cleanup after 1 hour
      template:
        spec:
          containers:
          - name: hourly-task
            image: busybox
            command: ['sh', '-c']
            args:
            - |
              echo "Running hourly task"
              # Task logic
              echo "Task completed"
          restartPolicy: OnFailure
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
```

#### Manual Cleanup Strategies

**Cleanup Script Job:**

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: cleanup-old-jobs
spec:
  template:
    spec:
      serviceAccountName: job-cleaner
      containers:
      - name: cleaner
        image: kubectl:latest
        command: ['sh', '-c']
        args:
        - |
          # Delete completed jobs older than 1 day
          kubectl get jobs --field-selector=status.successful=1 \
            -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.completionTime}{"\n"}{end}' | \
            while read job completion_time; do
              if [[ -n "$completion_time" ]]; then
                age=$(( $(date +%s) - $(date -d "$completion_time" +%s) ))
                if (( age > 86400 )); then
                  echo "Deleting old job: $job"
                  kubectl delete job "$job"
                fi
              fi
            done
      restartPolicy: Never
```

**RBAC for Cleanup Job:**

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: job-cleaner
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: job-cleaner-role
rules:
- apiGroups: ["batch"]
  resources: ["jobs"]
  verbs: ["get", "list", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: job-cleaner-binding
subjects:
- kind: ServiceAccount
  name: job-cleaner
  namespace: default
roleRef:
  kind: ClusterRole
  name: job-cleaner-role
  apiGroup: rbac.authorization.k8s.io
```

#### Monitoring and Alerting

**Job Monitoring Configuration:**

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: monitored-job
  labels:
    monitoring: enabled
spec:
  template:
    metadata:
      labels:
        monitoring: enabled
    spec:
      containers:
      - name: worker
        image: busybox
        command: ['sh', '-c']
        args:
        - |
          echo "Job started at $(date)"
          # Simulate work with potential failure
          if (( RANDOM % 10 == 0 )); then
            echo "Simulated failure"
            exit 1
          fi
          sleep 30
          echo "Job completed successfully at $(date)"
      restartPolicy: Never
  backoffLimit: 3
  activeDeadlineSeconds: 300
```

**CronJob with Monitoring:**

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: monitored-cronjob
  annotations:
    monitoring.coreos.com/enabled: "true"
spec:
  schedule: "*/10 * * * *"
  jobTemplate:
    spec:
      template:
        metadata:
          annotations:
            prometheus.io/scrape: "true"
            prometheus.io/port: "8080"
        spec:
          containers:
          - name: worker
            image: monitored-app:latest
            ports:
            - containerPort: 8080
              name: metrics
            env:
            - name: ENABLE_METRICS
              value: "true"
          restartPolicy: OnFailure
  successfulJobsHistoryLimit: 5
  failedJobsHistoryLimit: 3
```

#### Advanced Cleanup Patterns

**Conditional Cleanup Based on Job Status:**

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: conditional-cleanup
spec:
  schedule: "0 1 * * *"  # Daily at 1 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: cleanup-worker
            image: kubectl:latest
            command: ['sh', '-c']
            args:
            - |
              # Cleanup successful jobs older than 7 days
              kubectl get jobs --field-selector=status.successful=1 \
                -o go-template='{{range .items}}{{if .status.completionTime}}{{.metadata.name}} {{.status.completionTime}}{{"\n"}}{{end}}{{end}}' | \
                while read job completion_time; do
                  age_seconds=$(( $(date +%s) - $(date -d "$completion_time" +%s) ))
                  if (( age_seconds > 604800 )); then
                    echo "Deleting successful job: $job (age: $age_seconds seconds)"
                    kubectl delete job "$job"
                  fi
                done
              
              # Cleanup failed jobs older than 30 days
              kubectl get jobs --field-selector=status.failed=1 \
                -o go-template='{{range .items}}{{if .status.conditions}}{{.metadata.name}} {{(index .status.conditions 0).lastTransitionTime}}{{"\n"}}{{end}}{{end}}' | \
                while read job failure_time; do
                  age_seconds=$(( $(date +%s) - $(date -d "$failure_time" +%s) ))
                  if (( age_seconds > 2592000 )); then
                    echo "Deleting failed job: $job (age: $age_seconds seconds)"
                    kubectl delete job "$job"
                  fi
                done
          restartPolicy: OnFailure
```

**Namespace-Specific Cleanup:**

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: namespace-cleanup
  namespace: batch-jobs
spec:
  schedule: "0 2 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: namespace-cleaner
            image: kubectl:latest
            command: ['sh', '-c']
            args:
            - |
              NAMESPACE="batch-jobs"
              MAX_SUCCESSFUL_JOBS=10
              MAX_FAILED_JOBS=5
              
              # Keep only the most recent successful jobs
              kubectl get jobs -n "$NAMESPACE" --field-selector=status.successful=1 \
                --sort-by=.status.completionTime \
                -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | \
                head -n -"$MAX_SUCCESSFUL_JOBS" | \
                while read job; do
                  echo "Deleting excess successful job: $job"
                  kubectl delete job -n "$NAMESPACE" "$job"
                done
              
              # Keep only the most recent failed jobs
              kubectl get jobs -n "$NAMESPACE" --field-selector=status.failed=1 \
                --sort-by=.metadata.creationTimestamp \
                -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | \
                head -n -"$MAX_FAILED_JOBS" | \
                while read job; do
                  echo "Deleting excess failed job: $job"
                  kubectl delete job -n "$NAMESPACE" "$job"
                done
          restartPolicy: OnFailure
```

**Key points:** Jobs and CronJobs provide essential batch processing capabilities in Kubernetes. Jobs run finite tasks with configurable completion requirements, parallelism, and retry policies. CronJobs schedule recurring tasks with flexible timing and concurrency management. Proper cleanup strategies prevent resource accumulation and maintain cluster health. Parallel job execution enables efficient processing of large workloads, while sequential patterns support complex multi-stage workflows.

**Next steps:** Explore advanced batch processing patterns with workflow engines like Argo Workflows or Tekton, job monitoring and alerting integration, resource quota management for batch workloads, and integration with external scheduling systems for enterprise batch processing requirements.

---

