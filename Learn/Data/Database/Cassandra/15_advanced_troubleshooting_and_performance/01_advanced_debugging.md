## Advanced Debugging


### Overview

Advanced debugging encompasses systematic approaches to identifying, analyzing, and resolving complex issues in distributed systems, applications, and infrastructure. Modern debugging techniques leverage specialized tools, methodologies, and analysis frameworks to diagnose performance bottlenecks, resource leaks, concurrency issues, and system-level problems that traditional logging cannot effectively capture.

### JVM Profiling and Analysis

#### Profiling Fundamentals

JVM profiling involves collecting runtime performance data to identify bottlenecks, resource consumption patterns, and optimization opportunities. Profiling can be performed using sampling-based or instrumentation-based approaches, each with distinct trade-offs between accuracy and performance overhead.

##### Sampling vs. Instrumentation

- **Sampling profilers**: Periodically capture stack traces with minimal overhead but may miss short-lived methods
- **Instrumentation profilers**: Modify bytecode to collect detailed metrics with higher precision but increased performance impact
- **Hybrid approaches**: Combine sampling and instrumentation for balanced profiling strategies

#### CPU Profiling Techniques

CPU profiling identifies methods consuming excessive processing time and reveals optimization opportunities through call graph analysis and hotspot detection.

##### Flame Graphs

Flame graphs provide visual representation of CPU usage patterns, showing call stacks and their relative execution time:

```bash
# Generate flame graph using async-profiler
java -jar async-profiler.jar -e cpu -d 30 -f profile.html <pid>
```

Flame graph interpretation involves identifying wide plateaus representing CPU-intensive methods and tall stacks indicating deep call hierarchies that may benefit from optimization.

##### JProfiler CPU Analysis

JProfiler offers comprehensive CPU profiling with call tree analysis and method-level timing:

```java
// Programmatic profiling control
Controller.startCPURecording(true);
// Code to profile
performCPUIntensiveOperation();
Controller.saveSnapshot(new File("cpu-profile.jps"));
```

#### Memory Profiling Strategies

Memory profiling reveals allocation patterns, object lifecycle management, and potential memory leaks through heap analysis and garbage collection monitoring.

##### Heap Dump Analysis

Heap dumps capture complete memory state for post-mortem analysis:

```bash
# Generate heap dump
jcmd <pid> GC.run_finalization
jcmd <pid> VM.gc
jmap -dump:format=b,file=heap.hprof <pid>

# Analysis with Eclipse MAT
java -Xmx4g -jar mat.jar -consoleLog -application org.eclipse.mat.api.parse heap.hprof
```

##### Allocation Rate Monitoring

High allocation rates can trigger frequent garbage collection and degrade performance:

```java
// Monitor allocation using JFR
-XX:+FlightRecorder
-XX:StartFlightRecording=duration=60s,filename=allocation.jfr,settings=profile

// Custom allocation tracking
public class AllocationTracker {
    private static final long ALLOCATION_THRESHOLD = 1024 * 1024; // 1MB
    
    public static void trackAllocation(Object obj) {
        long size = sizeOf(obj);
        if (size > ALLOCATION_THRESHOLD) {
            System.out.printf("Large allocation: %d bytes at %s%n", 
                size, Thread.currentThread().getStackTrace()[2]);
        }
    }
}
```

#### Garbage Collection Analysis

GC analysis identifies collection patterns, pause times, and memory pressure that impact application performance.

##### GC Logging Configuration

Comprehensive GC logging provides insights into collection behavior:

```bash
# Java 11+ GC logging
-Xlog:gc*:gc.log:time,pid,tid,level,tags

# Legacy GC logging (Java 8)
-XX:+PrintGC -XX:+PrintGCDetails -XX:+PrintGCTimeStamps 
-XX:+PrintGCApplicationStoppedTime -Xloggc:gc.log
```

##### GC Tuning Parameters

GC tuning involves adjusting heap sizes, generation ratios, and collector algorithms:

```bash
# G1GC configuration
-XX:+UseG1GC
-XX:MaxGCPauseMillis=200
-XX:G1HeapRegionSize=16m
-XX:G1MixedGCCountTarget=8

# Parallel GC configuration
-XX:+UseParallelGC
-XX:ParallelGCThreads=8
-XX:MaxGCPauseMillis=100
```

#### Java Flight Recorder (JFR)

JFR provides low-overhead continuous profiling with comprehensive runtime metrics collection.

##### JFR Configuration

JFR can be configured for different profiling scenarios:

```bash
# Continuous recording
-XX:+FlightRecorder
-XX:StartFlightRecording=maxage=24h,maxsize=100m,name=continuous

# Triggered recording
jcmd <pid> JFR.start duration=60s filename=profile.jfr settings=profile

# Custom event recording
jcmd <pid> JFR.start settings=custom.jfc
```

##### Custom JFR Events

Applications can emit custom JFR events for domain-specific profiling:

```java
@Name("com.example.DatabaseQuery")
@Label("Database Query")
@Category("Application")
public class DatabaseQueryEvent extends Event {
    @Label("Query")
    String query;
    
    @Label("Duration")
    @Timespan
    long duration;
    
    @Label("Rows Returned")
    int rowCount;
}

// Usage
DatabaseQueryEvent event = new DatabaseQueryEvent();
event.begin();
try {
    // Execute database query
    ResultSet rs = statement.executeQuery(sql);
    event.query = sql;
    event.rowCount = getRowCount(rs);
} finally {
    event.end();
    event.commit();
}
```

### Memory Leak Detection

#### Leak Detection Methodologies

Memory leak detection requires systematic analysis of heap growth patterns, object retention, and reference chains that prevent garbage collection.

##### Heap Growth Analysis

Monitoring heap usage over time reveals potential memory leaks:

```java
public class HeapMonitor {
    private final MemoryMXBean memoryBean = ManagementFactory.getMemoryMXBean();
    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);
    
    public void startMonitoring() {
        scheduler.scheduleAtFixedRate(() -> {
            MemoryUsage heapUsage = memoryBean.getHeapMemoryUsage();
            long used = heapUsage.getUsed();
            long max = heapUsage.getMax();
            double percentage = (double) used / max * 100;
            
            System.out.printf("Heap usage: %d MB / %d MB (%.1f%%)%n",
                used / 1024 / 1024, max / 1024 / 1024, percentage);
                
            if (percentage > 90) {
                triggerHeapDump();
            }
        }, 0, 30, TimeUnit.SECONDS);
    }
}
```

##### Reference Chain Analysis

Eclipse Memory Analyzer Tool (MAT) provides reference chain analysis to identify leak root causes:

```sql
-- MAT OQL query to find objects with specific retention patterns
SELECT * FROM java.util.HashMap$Node s 
WHERE (s.key != null) AND (s.key.toString().matches(".*session.*"))
```

#### Common Leak Patterns

##### Event Listener Leaks

Event listeners that are not properly unregistered can cause memory leaks:

```java
public class LeakProneComponent {
    private final EventBus eventBus;
    
    public LeakProneComponent(EventBus eventBus) {
        this.eventBus = eventBus;
        // LEAK: Listener registered but never unregistered
        eventBus.register(this);
    }
    
    // Proper cleanup
    public void shutdown() {
        eventBus.unregister(this);
    }
}
```

##### ThreadLocal Leaks

ThreadLocal variables can cause leaks when not properly cleaned up:

```java
public class ThreadLocalLeakExample {
    private static final ThreadLocal<List<String>> CACHE = 
        ThreadLocal.withInitial(ArrayList::new);
    
    public void processRequest() {
        try {
            List<String> data = CACHE.get();
            // Process data
        } finally {
            // Prevent leak by clearing ThreadLocal
            CACHE.remove();
        }
    }
}
```

##### Collection Growth Leaks

Unbounded collections that continue growing without cleanup:

```java
public class CacheManager {
    private final Map<String, Object> cache = new ConcurrentHashMap<>();
    private final ScheduledExecutorService cleanup = 
        Executors.newScheduledThreadPool(1);
    
    public CacheManager() {
        // Implement cache cleanup to prevent unbounded growth
        cleanup.scheduleAtFixedRate(this::cleanupExpiredEntries, 
            1, 1, TimeUnit.HOURS);
    }
    
    private void cleanupExpiredEntries() {
        cache.entrySet().removeIf(entry -> isExpired(entry));
    }
}
```

#### Automated Leak Detection

##### JVM Leak Detection Flags

JVM provides built-in leak detection capabilities:

```bash
# OutOfMemoryError heap dump generation
-XX:+HeapDumpOnOutOfMemoryError
-XX:HeapDumpPath=/tmp/heapdumps/

# GC overhead monitoring
-XX:+UseGCOverheadLimit
-XX:GCTimeLimit=5
-XX:GCHeapFreeLimit=10
```

##### Programmatic Leak Detection

Applications can implement custom leak detection logic:

```java
public class LeakDetector {
    private final Map<Class<?>, AtomicLong> objectCounts = new ConcurrentHashMap<>();
    private final ScheduledExecutorService monitor = Executors.newScheduledThreadPool(1);
    
    public void registerAllocation(Object obj) {
        objectCounts.computeIfAbsent(obj.getClass(), k -> new AtomicLong(0))
                   .incrementAndGet();
    }
    
    public void registerDeallocation(Object obj) {
        AtomicLong count = objectCounts.get(obj.getClass());
        if (count != null) {
            count.decrementAndGet();
        }
    }
    
    public void startMonitoring() {
        monitor.scheduleAtFixedRate(() -> {
            objectCounts.entrySet().stream()
                .filter(entry -> entry.getValue().get() > 1000)
                .forEach(entry -> 
                    System.out.printf("Potential leak: %s with %d instances%n",
                        entry.getKey().getSimpleName(), entry.getValue().get()));
        }, 0, 5, TimeUnit.MINUTES);
    }
}
```

### Thread Dump Analysis

#### Thread Dump Generation

Thread dumps capture the state of all threads at a specific moment, providing insights into deadlocks, contention, and performance issues.

##### Generation Methods

Multiple approaches exist for generating thread dumps:

```bash
# Using jstack
jstack <pid> > threaddump.txt

# Using jcmd
jcmd <pid> Thread.print > threaddump.txt

# Using kill signal (Linux/Unix)
kill -3 <pid>

# Programmatic generation
ThreadMXBean threadBean = ManagementFactory.getThreadMXBean();
ThreadInfo[] threadInfos = threadBean.dumpAllThreads(true, true);
```

#### Thread State Analysis

##### Thread States and Interpretation

Understanding thread states is crucial for effective analysis:

- **RUNNABLE**: Thread is executing or ready to execute
- **BLOCKED**: Thread is blocked waiting for a monitor lock
- **WAITING**: Thread is waiting indefinitely for another thread
- **TIMED_WAITING**: Thread is waiting for a specified period
- **NEW**: Thread has been created but not started
- **TERMINATED**: Thread has completed execution

**Example** thread dump snippet analysis:

```
"DatabaseConnectionPool-Worker-1" #23 daemon prio=5 os_prio=0 tid=0x00007f8b2c001000 nid=0x7f2b waiting on condition [0x00007f8b1c5fe000]
   java.lang.Thread.State: WAITING (parking)
        at sun.misc.Unsafe.park(Native Method)
        - parking to wait for  <0x000000076ab62208> (a java.util.concurrent.SynchronousQueue$TransferStack)
        at java.util.concurrent.locks.LockSupport.park(LockSupport.java:175)
        at java.util.concurrent.SynchronousQueue$TransferStack.awaitFulfill(SynchronousQueue.java:458)
```

This indicates a thread waiting in a connection pool, which is normal behavior.

#### Deadlock Detection

Thread dumps automatically detect and report deadlocks:

```
Found one Java-level deadlock:
=============================
"Thread-1":
  waiting to lock monitor 0x00007f8b2c006708 (object 0x000000076ab62300, a java.lang.Object),
  which is held by "Thread-2"
"Thread-2":
  waiting to lock monitor 0x00007f8b2c006718 (object 0x000000076ab62310, a java.lang.Object),
  which is held by "Thread-1"
```

##### Deadlock Prevention Strategies

Implementing ordered lock acquisition prevents circular dependencies:

```java
public class DeadlockFreeTransfer {
    private static final Object tieLock = new Object();
    
    public void transfer(Account from, Account to, int amount) {
        class Helper {
            public void transfer() {
                if (from.acctNo < to.acctNo) {
                    synchronized (from) {
                        synchronized (to) {
                            from.debit(amount);
                            to.credit(amount);
                        }
                    }
                } else if (from.acctNo > to.acctNo) {
                    synchronized (to) {
                        synchronized (from) {
                            from.debit(amount);
                            to.credit(amount);
                        }
                    }
                } else {
                    synchronized (tieLock) {
                        synchronized (from) {
                            synchronized (to) {
                                from.debit(amount);
                                to.credit(amount);
                            }
                        }
                    }
                }
            }
        }
        new Helper().transfer();
    }
}
```

#### Thread Contention Analysis

##### Lock Contention Identification

High contention on synchronized blocks creates performance bottlenecks:

```java
public class ContentionMonitor {
    private final ThreadMXBean threadBean = ManagementFactory.getThreadMXBean();
    
    public void analyzeContention() {
        if (threadBean.isThreadContentionMonitoringSupported()) {
            threadBean.setThreadContentionMonitoringEnabled(true);
            
            ThreadInfo[] threadInfos = threadBean.getAllThreadInfo();
            for (ThreadInfo info : threadInfos) {
                long blockedTime = info.getBlockedTime();
                long blockedCount = info.getBlockedCount();
                
                if (blockedTime > 1000) { // More than 1 second blocked
                    System.out.printf("Thread %s: blocked %d times for %d ms%n",
                        info.getThreadName(), blockedCount, blockedTime);
                }
            }
        }
    }
}
```

##### Alternative Concurrency Mechanisms

Using lock-free data structures and atomic operations reduces contention:

```java
public class LockFreeCounter {
    private final AtomicLong counter = new AtomicLong(0);
    
    public long increment() {
        return counter.incrementAndGet();
    }
    
    public long get() {
        return counter.get();
    }
}

// Using ConcurrentHashMap instead of synchronized HashMap
private final Map<String, String> cache = new ConcurrentHashMap<>();
```

### Network Debugging Techniques

#### Network Traffic Analysis

Network debugging involves analyzing packet flows, connection states, and protocol-specific behaviors to identify communication issues and performance bottlenecks.

##### Packet Capture and Analysis

Tools like tcpdump and Wireshark provide detailed network traffic inspection:

```bash
# Capture HTTP traffic on port 80
tcpdump -i eth0 -s 0 -w http_traffic.pcap port 80

# Filter specific host communication
tcpdump -i eth0 host 192.168.1.100 and port 443

# Analyze captured traffic with tshark
tshark -r http_traffic.pcap -Y "http.request.method == GET" -T fields -e http.host -e http.request.uri
```

##### Connection State Monitoring

Monitoring TCP connection states reveals network health:

```bash
# Monitor connection states
netstat -tuln | grep LISTEN
ss -tuln | grep LISTEN

# Monitor connection counts by state
ss -ant | awk '{print $1}' | sort | uniq -c

# Monitor network interface statistics
cat /proc/net/dev
```

#### Application-Level Network Debugging

##### HTTP Client Debugging

Debugging HTTP communications requires logging request/response details:

```java
public class HTTPDebugClient {
    private static final Logger logger = LoggerFactory.getLogger(HTTPDebugClient.class);
    
    public String makeRequest(String url) throws IOException {
        HttpURLConnection connection = (HttpURLConnection) new URL(url).openConnection();
        
        // Log request details
        logger.debug("Request: {} {}", connection.getRequestMethod(), url);
        connection.getRequestProperties().forEach((key, values) ->
            logger.debug("Request Header: {}: {}", key, String.join(", ", values)));
        
        // Execute request
        connection.connect();
        
        // Log response details
        logger.debug("Response: {} {}", connection.getResponseCode(), connection.getResponseMessage());
        connection.getHeaderFields().forEach((key, values) ->
            logger.debug("Response Header: {}: {}", key, String.join(", ", values)));
        
        // Read response
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(connection.getInputStream()))) {
            return reader.lines().collect(Collectors.joining("\n"));
        }
    }
}
```

##### Socket-Level Debugging

Low-level socket debugging for custom protocols:

```java
public class SocketDebugger {
    public void debugConnection(String host, int port) {
        try (Socket socket = new Socket()) {
            socket.connect(new InetSocketAddress(host, port), 5000);
            
            System.out.printf("Connected to %s:%d%n", host, port);
            System.out.printf("Local address: %s%n", socket.getLocalSocketAddress());
            System.out.printf("Remote address: %s%n", socket.getRemoteSocketAddress());
            System.out.printf("Keep alive: %s%n", socket.getKeepAlive());
            System.out.printf("TCP no delay: %s%n", socket.getTcpNoDelay());
            System.out.printf("Receive buffer size: %d%n", socket.getReceiveBufferSize());
            System.out.printf("Send buffer size: %d%n", socket.getSendBufferSize());
            
        } catch (IOException e) {
            System.err.printf("Connection failed: %s%n", e.getMessage());
        }
    }
}
```

#### DNS Resolution Debugging

DNS issues can cause significant application delays and failures:

```java
public class DNSDebugger {
    public void debugDNSResolution(String hostname) {
        try {
            long startTime = System.currentTimeMillis();
            InetAddress[] addresses = InetAddress.getAllByName(hostname);
            long duration = System.currentTimeMillis() - startTime;
            
            System.out.printf("DNS resolution for %s took %d ms%n", hostname, duration);
            for (InetAddress addr : addresses) {
                System.out.printf("  %s -> %s%n", hostname, addr.getHostAddress());
            }
            
        } catch (UnknownHostException e) {
            System.err.printf("DNS resolution failed for %s: %s%n", hostname, e.getMessage());
        }
    }
    
    public void monitorDNSPerformance() {
        String[] testHosts = {"google.com", "github.com", "stackoverflow.com"};
        
        for (String host : testHosts) {
            long total = 0;
            int attempts = 5;
            
            for (int i = 0; i < attempts; i++) {
                long start = System.nanoTime();
                try {
                    InetAddress.getByName(host);
                    total += (System.nanoTime() - start) / 1_000_000; // Convert to ms
                } catch (UnknownHostException e) {
                    System.err.printf("Failed to resolve %s: %s%n", host, e.getMessage());
                }
            }
            
            System.out.printf("Average DNS resolution time for %s: %.2f ms%n", 
                host, (double) total / attempts);
        }
    }
}
```

### Storage System Debugging

#### Disk I/O Analysis

Storage debugging involves analyzing disk performance, I/O patterns, and file system behaviors that impact application performance.

##### I/O Monitoring Tools

System-level tools provide insights into storage performance:

```bash
# Monitor disk I/O statistics
iostat -x 1

# Monitor per-process I/O
iotop -o

# Analyze disk usage patterns
sar -d 1

# Monitor file system cache effectiveness
free -h
cat /proc/meminfo | grep -E "Cached|Buffers"
```

##### Application-Level I/O Debugging

Java applications can monitor their own I/O patterns:

```java
public class IODebugger {
    private final OperatingSystemMXBean osBean = 
        (OperatingSystemMXBean) ManagementFactory.getOperatingSystemMXBean();
    
    public void monitorIOPerformance() {
        long startTime = System.currentTimeMillis();
        long startReads = osBean.getProcessCpuTime();
        
        // Perform I/O operations
        performFileOperations();
        
        long endTime = System.currentTimeMillis();
        long endReads = osBean.getProcessCpuTime();
        
        System.out.printf("I/O operation took %d ms%n", endTime - startTime);
        System.out.printf("CPU time consumed: %d ns%n", endReads - startReads);
    }
    
    public void analyzeFileAccess(Path filePath) throws IOException {
        BasicFileAttributes attrs = Files.readAttributes(filePath, BasicFileAttributes.class);
        
        System.out.printf("File: %s%n", filePath);
        System.out.printf("Size: %d bytes%n", attrs.size());
        System.out.printf("Created: %s%n", attrs.creationTime());
        System.out.printf("Modified: %s%n", attrs.lastModifiedTime());
        System.out.printf("Accessed: %s%n", attrs.lastAccessTime());
        System.out.printf("Regular file: %s%n", attrs.isRegularFile());
    }
}
```

#### Database Connection Debugging

Database connectivity issues require systematic analysis of connection pools, query performance, and transaction isolation:

```java
public class DatabaseDebugger {
    private final DataSource dataSource;
    
    public void debugConnectionPool() {
        if (dataSource instanceof HikariDataSource) {
            HikariDataSource hikari = (HikariDataSource) dataSource;
            HikariPoolMXBean pool = hikari.getHikariPoolMXBean();
            
            System.out.printf("Pool name: %s%n", hikari.getPoolName());
            System.out.printf("Active connections: %d%n", pool.getActiveConnections());
            System.out.printf("Idle connections: %d%n", pool.getIdleConnections());
            System.out.printf("Total connections: %d%n", pool.getTotalConnections());
            System.out.printf("Threads waiting: %d%n", pool.getThreadsAwaitingConnection());
        }
    }
    
    public void debugQuery(String sql, Object... params) {
        long startTime = System.nanoTime();
        
        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            // Log connection details
            DatabaseMetaData meta = conn.getMetaData();
            System.out.printf("Database: %s %s%n", 
                meta.getDatabaseProductName(), meta.getDatabaseProductVersion());
            System.out.printf("Driver: %s %s%n", 
                meta.getDriverName(), meta.getDriverVersion());
            System.out.printf("Auto-commit: %s%n", conn.getAutoCommit());
            System.out.printf("Transaction isolation: %d%n", conn.getTransactionIsolation());
            
            // Set parameters and execute
            for (int i = 0; i < params.length; i++) {
                stmt.setObject(i + 1, params[i]);
            }
            
            long queryStart = System.nanoTime();
            try (ResultSet rs = stmt.executeQuery()) {
                long queryEnd = System.nanoTime();
                
                System.out.printf("Query executed in %.2f ms%n", 
                    (queryEnd - queryStart) / 1_000_000.0);
                
                // Analyze result set metadata
                ResultSetMetaData rsmd = rs.getMetaData();
                System.out.printf("Columns returned: %d%n", rsmd.getColumnCount());
                
                int rowCount = 0;
                while (rs.next()) {
                    rowCount++;
                }
                System.out.printf("Rows returned: %d%n", rowCount);
            }
            
        } catch (SQLException e) {
            System.err.printf("Query failed: %s%n", e.getMessage());
            System.err.printf("SQL State: %s%n", e.getSQLState());
            System.err.printf("Error Code: %d%n", e.getErrorCode());
        } finally {
            long totalTime = System.nanoTime() - startTime;
            System.out.printf("Total operation time: %.2f ms%n", totalTime / 1_000_000.0);
        }
    }
}
```

#### File System Performance Analysis

File system debugging involves analyzing access patterns, cache behavior, and storage device performance:

```java
public class FileSystemDebugger {
    public void analyzeDirectoryStructure(Path directory) throws IOException {
        Map<String, Long> extensionSizes = new HashMap<>();
        AtomicLong totalSize = new AtomicLong(0);
        AtomicInteger fileCount = new AtomicInteger(0);
        
        Files.walk(directory)
            .filter(Files::isRegularFile)
            .forEach(path -> {
                try {
                    long size = Files.size(path);
                    totalSize.addAndGet(size);
                    fileCount.incrementAndGet();
                    
                    String extension = getFileExtension(path);
                    extensionSizes.merge(extension, size, Long::sum);
                    
                } catch (IOException e) {
                    System.err.printf("Error processing %s: %s%n", path, e.getMessage());
                }
            });
        
        System.out.printf("Directory: %s%n", directory);
        System.out.printf("Total files: %d%n", fileCount.get());
        System.out.printf("Total size: %.2f MB%n", totalSize.get() / 1024.0 / 1024.0);
        
        extensionSizes.entrySet().stream()
            .sorted(Map.Entry.<String, Long>comparingByValue().reversed())
            .limit(10)
            .forEach(entry -> System.out.printf("  %s: %.2f MB%n", 
                entry.getKey(), entry.getValue() / 1024.0 / 1024.0));
    }
    
    private String getFileExtension(Path path) {
        String fileName = path.getFileName().toString();
        int lastDot = fileName.lastIndexOf('.');
        return lastDot >= 0 ? fileName.substring(lastDot + 1) : "no extension";
    }
    
    public void monitorFileSystemSpace() {
        File[] roots = File.listRoots();
        for (File root : roots) {
            long total = root.getTotalSpace();
            long free = root.getFreeSpace();
            long used = total - free;
            double usedPercent = (double) used / total * 100;
            
            System.out.printf("File system: %s%n", root.getAbsolutePath());
            System.out.printf("  Total: %.2f GB%n", total / 1024.0 / 1024.0 / 1024.0);
            System.out.printf("  Used: %.2f GB (%.1f%%)%n", 
                used / 1024.0 / 1024.0 / 1024.0, usedPercent);
            System.out.printf("  Free: %.2f GB%n", free / 1024.0 / 1024.0 / 1024.0);
        }
    }
}
```

**Key points** for advanced debugging:

- Use profiling tools continuously in development environments to identify issues early
- Implement automated monitoring and alerting for memory usage, thread contention, and I/O performance
- Maintain historical performance baselines to detect degradation trends
- Combine multiple debugging approaches for comprehensive analysis
- Document debugging procedures and common issue resolution patterns
- Consider performance impact when enabling debugging features in production environments
- Use sampling-based profiling for continuous monitoring with minimal overhead

**Conclusion**

Advanced debugging requires systematic approaches combining specialized tools, monitoring strategies, and analysis techniques. [Inference] Effective debugging practices likely reduce mean time to resolution for production issues and improve overall system reliability. Modern applications benefit from continuous profiling, automated anomaly detection, and comprehensive observability frameworks that provide insights into system behavior before issues become critical.

Related topics include distributed tracing, observability frameworks, chaos engineering, performance testing methodologies, and production debugging strategies.

---

