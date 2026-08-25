## Interprocess Communication


### Communication Primitives

**Shared Memory** Process address spaces map to common physical memory regions. Requires explicit synchronization primitives (mutexes, semaphores, condition variables, read-write locks). Zero-copy semantics within same host. Primary concerns: memory coherence across CPU caches, false sharing on cache-line boundaries, ABA problems in lock-free implementations, memory ordering guarantees (acquire-release, sequential consistency). NUMA architectures introduce non-uniform latency profiles. Applicable for high-throughput local communication between processes with tight latency requirements (< 1µs). Failure isolation poor—corrupted shared state affects all participants.

**Message Passing** Discrete message transfer between processes via kernel-mediated or user-space transports. Enforces explicit data serialization and deserialization boundaries. No shared state—failure isolation inherent. Latency overhead from context switches, memory copies, serialization tax. Transport options: UNIX domain sockets, TCP/IP loopback, UDP, named pipes (FIFOs), message queues (POSIX mqueues, System V message queues). Backpressure and flow control mechanisms vary by transport. Delivery semantics: at-most-once (UDP), at-least-once (TCP with retries), exactly-once (requires application-level deduplication with idempotency tokens or sequence numbers).

**Memory-Mapped Files** File-backed shared memory regions. Kernel manages page cache coherence. Supports persistent IPC state across process restarts. `msync()` controls synchronization to backing storage. Locking protocols required for coordination (file locks via `fcntl`, `flock`). Supports zero-copy reads via `mmap`. Write amplification concerns on small updates due to page granularity (typically 4KB). Performance depends on page cache hit rates and filesystem implementation.

**Signals** Asynchronous notification mechanism. Limited payload (signal number only, or extended via `sigqueue` with small integer/pointer). Non-blocking delivery—signal handlers execute in arbitrary process context. Reentrant safety requirements restrict handler operations. Race conditions between signal delivery and handler execution. Not suitable for data transfer—used for coordination events (SIGTERM, SIGUSR1/2, SIGCHLD).

### Transport Mechanisms

**UNIX Domain Sockets** Filesystem-namespaced endpoints. Stream (SOCK_STREAM) provides ordered, reliable byte streams analogous to TCP. Datagram (SOCK_DGRAM) provides message boundaries with unreliable delivery. Supports credential passing via `SCM_CREDENTIALS` ancillary data. File descriptor passing via `SCM_RIGHTS` enables zero-copy handoff of resources (files, sockets, DMA buffers). Latency: 2-10µs round-trip for small messages. Throughput constrained by socket buffer sizes, achievable 10-40 GB/s on modern systems. No network stack overhead—purely kernel memory operations.

**Named Pipes (FIFOs)** Unidirectional byte streams with filesystem namespace. Blocking semantics on open until both reader and writer attach. No message boundaries—application must frame data. Single writer, single reader typical pattern. Buffer size limited (typically 64KB on Linux via `F_SETPIPE_SZ`). Simpler than sockets for unidirectional pipelines. Legacy mechanism—domain sockets preferred for bidirectional or multi-party communication.

**POSIX Message Queues** Persistent message-oriented channels with priority ordering. Messages have explicit boundaries and size limits (system-dependent, often 8KB default). Non-blocking and blocking send/receive modes. Notification via signals or threads on message arrival. Queue depth limits enforced—sender blocks or fails on full queue. Not widely adopted—often replaced by in-process or distributed message brokers. Kernel implementation with `/dev/mqueue` pseudo-filesystem.

**System V IPC (Legacy)** Message queues (`msgget`, `msgsnd`, `msgrcv`), semaphore sets (`semget`, `semop`), shared memory segments (`shmget`, `shmat`). Global integer-keyed namespace. Permission model via mode bits. Persistent across process lifetimes—requires explicit cleanup (`ipcrm`). Semaphore operations atomic across sets. Legacy interface—POSIX alternatives preferred. Still present in some HPC and embedded systems.

### Zero-Copy Techniques

**File Descriptor Passing** Transfer open file descriptors between processes via UNIX domain sockets and `sendmsg`/`recvmsg` with `SCM_RIGHTS`. Receiving process gains reference to same kernel file structure—no data copy. Useful for delegation patterns: privileged process opens resource, passes to unprivileged worker. Supports TCP sockets, files, eventfds, DMA buffers. Reference counting in kernel—FD remains valid until all processes close.

**Splice/Vmsplice/Tee** Linux-specific zero-copy operations. `splice()` transfers data between file descriptors via kernel pipe buffers—no userspace copy. `vmsplice()` maps userspace memory into pipe buffer pages. `tee()` duplicates pipe data without consumption. Achievable throughput: 10-40 GB/s for large transfers. Constraints: requires pipe as intermediary, limited by pipe buffer size (default 16 pages = 64KB). Use case: proxy services, log aggregation, file transfers.

**Shared Memory with Atomic Operations** Lock-free queues (ring buffers, MPMC queues) using atomic compare-and-swap (CAS) primitives. Avoids kernel syscall overhead. Requires careful memory ordering (acquire-release semantics). Contention on cache lines degrades performance—pad structures to cache-line boundaries (64 bytes typical). SPSC queues achieve 10-50M ops/sec. MPMC queues degrade with contention—performance drops 10-100x under high contention. ABA problem mitigation: tagged pointers, hazard pointers, epoch-based reclamation.

### Synchronization Primitives

**POSIX Mutexes/Condition Variables** Process-shared attribute (`PTHREAD_PROCESS_SHARED`) enables cross-process synchronization. Must reside in shared memory region. Priority inheritance (`PTHREAD_PRIO_INHERIT`) mitigates priority inversion. Robust mutexes (`PTHREAD_MUTEX_ROBUST`) handle owner process death—next acquirer receives `EOWNERDEAD`. Futex-based implementation on Linux—syscall only on contention. Uncontended lock/unlock: 10-50ns. Contended: 1-10µs.

**Semaphores** POSIX semaphores: named (filesystem namespace) or unnamed (memory-based). Named semaphores persistent across processes. Counting semaphores track resource availability. Binary semaphores degenerate to mutexes. No ownership concept—any process can signal. Use cases: producer-consumer, resource pools, rate limiting.

**File Locks** Advisory locks (`flock`, `fcntl` with `F_SETLK`/`F_SETLKW`) coordinate file access. Range locks via `fcntl` support byte-level granularity. Mandatory locks (rarely enabled) enforced by kernel. NFS v4 supports distributed file locking—earlier versions unreliable. Lock recovery protocols required for distributed filesystems. Performance: 10-100µs per lock operation.

**Eventfd** Linux-specific signaling mechanism. Integer counter shared between processes. Non-blocking read/write. Integrates with `epoll`/`poll`/`select` for event-driven architectures. Semaphore semantics via `EFD_SEMAPHORE` flag. Use case: wakeup notifications in event loops, integrating non-socket events into poll loops.

### Serialization and Framing

**Wire Protocols** Fixed-length headers with length prefixes standard pattern. Network byte order (big-endian) for multi-architecture compatibility. Length-delimited frames prevent buffering ambiguity. CRC32/CRC64 checksums detect corruption. Protocol versioning via magic numbers or version fields. TLV (Type-Length-Value) encoding supports schema evolution.

**Binary Serialization** Protocol Buffers, FlatBuffers, Cap'n Proto, MessagePack, CBOR. Schema-driven ensures forward/backward compatibility. FlatBuffers and Cap'n Proto support zero-copy access—data accessed in-place without deserialization. Protocol Buffers requires parse step—5-10x slower than FlatBuffers for read-heavy workloads. Schema evolution: field numbering, optional/required fields, deprecation markers. Wire size: 2-10x smaller than JSON for typical payloads.

**Text Serialization** JSON, YAML, XML. Human-readable, debugging-friendly. 5-20x larger wire size than binary formats. Parsing overhead: 10-100x slower than binary. No schema enforcement—runtime validation required. JSON lacks native binary data support—base64 encoding adds 33% overhead. Use cases: configuration files, external APIs, human-in-the-loop workflows.

### Failure Modes and Reliability

**Process Crashes** Shared memory: orphaned locks, corrupted data structures. Robust mutexes mitigate—successor detects owner death. Shared memory persists—requires explicit cleanup or reinitialization. Message queues: unacknowledged messages remain queued. File descriptor passing: kernel cleans up references. Detection: heartbeat mechanisms, watchdog timers, parent-child relationships (`SIGCHLD`).

**Resource Exhaustion** Socket buffer overflow: sender blocks or receives `EAGAIN`/`EWOULDBLOCK`. Message queue full: sender blocks or fails. Shared memory exhaustion: `shm_open` fails, `mmap` fails. File descriptor limits (`ulimit -n`, `RLIMIT_NOFILE`): `accept()`, `socket()` fail. Mitigation: backpressure propagation, flow control, admission control, resource quotas.

**Stale State** Shared memory: last-writer-wins semantics without coordination. File locks released on process exit—lock holder death may leave inconsistent state. Message queues: stale messages from crashed senders. Mitigation: sequence numbers, timestamps, generation counters, lease-based ownership with timeout.

**Deadlocks** Circular lock dependencies in shared memory. File lock cycles across multiple files. Avoidance: lock ordering discipline, lock hierarchies, timeouts (`pthread_mutex_timedlock`), deadlock detection via resource allocation graphs.

### Performance Characteristics

**Latency Comparison (Round-Trip, Single Core)**

- Shared memory atomic operation: 20-50ns
- UNIX domain socket (SOCK_STREAM): 2-10µs
- TCP loopback: 10-30µs
- Named pipe: 5-15µs
- POSIX message queue: 10-50µs
- Signal delivery: 1-5µs

**Throughput Comparison (Single Sender/Receiver)**

- Shared memory zero-copy: 40-100 GB/s
- UNIX domain socket: 10-40 GB/s
- TCP loopback: 5-20 GB/s
- Splice zero-copy: 10-40 GB/s
- Named pipe: 1-5 GB/s

**Scalability Limits** UNIX domain sockets: high connection count overhead, file descriptor exhaustion. Shared memory: contention on atomic operations degrades exponentially. Message queues: global kernel locks limit concurrency. File locks: scalability poor—centralized lock manager.

### Security and Isolation

**Credential Verification** `SO_PEERCRED` socket option retrieves peer PID, UID, GID on UNIX domain sockets. Credential passing via `SCM_CREDENTIALS` must be verified—sender cannot spoof. Namespace isolation (PID, user namespaces) affects credential visibility. Use cases: privilege checks, audit logging, access control.

**Namespace Isolation** Mount namespaces isolate filesystem views—UNIX socket paths, named pipes, mqueues separated. IPC namespaces isolate System V IPC objects, POSIX message queues. Network namespaces isolate loopback interface—processes in different namespaces cannot communicate via 127.0.0.1. PID namespaces affect signal delivery—signals cannot cross namespace boundaries without CAP_SYS_ADMIN.

**Capability-Based Security** File descriptor passing enables capability-style security—possession of FD grants access, no ambient authority. Revocation via close, or indirect via eBPF filtering. Supports least-privilege architectures—privileged process opens resource, unprivileged worker receives FD.

**Side Channels** Shared memory timing attacks: cache-line probing reveals concurrent access patterns. Spectre/Meltdown require process isolation, not just IPC boundaries. Covert channels via filesystem metadata, lock contention patterns, CPU cache behavior. Mitigation: process isolation via namespaces/cgroups, CPU pinning, memory encryption (SEV, TDX).

### Observability and Debugging

**Tracing** `strace`/`dtrace`/`bpftrace` intercepts syscalls: `sendmsg`, `recvmsg`, `shmget`, `futex`. Overhead: 10-1000x slowdown depending on frequency. eBPF-based tracing minimizes overhead—kprobes/uprobes with in-kernel aggregation. Tracepoints: `sock:inet_sock_set_state`, `ipc:*`, `syscalls:sys_enter_*`.

**Metrics** Socket buffer usage: `/proc/net/unix`, `ss -x`. Message queue depth: `mq_getattr`, `/proc/sys/fs/mqueue/*`. Shared memory segments: `/proc/sysvipc/shm`, `/dev/shm`. File descriptor count: `/proc/<pid>/fd/`, `lsof`. Lock contention: futex wait counts via perf, BCC tools.

**Diagnostics** `gcore` generates core dump for postmortem shared memory inspection. `ipcs` lists System V IPC objects. `lsof` identifies open file descriptors, sockets. GDB shared memory inspection: attach to process, examine memory at known offsets. Systemtap/eBPF scripts trace lock acquisition/release, message sends/receives.

### Related Topics

- Remote Procedure Call (RPC) frameworks
- Message-Oriented Middleware (MOM)
- Actor Model and message-passing concurrency
- Shared-nothing architectures
- Memory consistency models
- Lock-free data structures
- Distributed shared memory systems
- Container orchestration IPC patterns

---

