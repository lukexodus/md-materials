## Monitoring & Auditing


### System Auditing (`auditd`)

The Linux Audit Framework provides comprehensive system-level auditing capabilities through the kernel audit subsystem and userspace daemon `auditd`. This framework tracks security-relevant events, system calls, file access, and user activities for compliance and security monitoring.

**Audit Framework Architecture** The audit framework operates through kernel hooks that intercept system calls and generate audit records. The kernel audit subsystem captures events and forwards them to the `auditd` daemon, which processes, filters, and stores audit logs.

Audit rules define which events trigger logging, what information to capture, and how to tag events for analysis. Rules can monitor specific files, directories, system calls, or user actions with granular control over event generation.

The `auditctl` command manages active audit rules, while `/etc/audit/rules.d/` contains persistent rule files loaded at daemon startup. Rule ordering matters since the first matching rule determines event handling.

**Rule Configuration** File system auditing monitors access to sensitive files and directories. Rules like `-w /etc/passwd -p wa -k passwd_changes` watch password file modifications with write and attribute change permissions, tagging events with the "passwd_changes" key.

System call auditing captures process behavior through rules targeting specific syscalls. Complex rules can combine multiple conditions, such as `-a always,exit -F arch=b64 -S openat -F success=0 -k failed_file_access` to log failed file access attempts on 64-bit systems.

User and group-based rules enable tracking activities by specific accounts. Rules can monitor privileged operations, such as `-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts` to log mount operations by regular users.

Network auditing captures socket operations and network connections. Rules can monitor network service access, connection attempts, and data transfer operations for security analysis.

**Event Processing** Audit events contain detailed information including timestamps, process IDs, user IDs, system call numbers, file paths, and return codes. The `ausearch` tool queries audit logs with flexible filtering options based on time ranges, users, files, or event types.

Event correlation links related audit records that comprise complete operations. Multi-record events require reassembly to understand full context, particularly for complex system calls involving multiple objects.

The `aureport` command generates summary reports from audit logs, providing statistics on user activity, file access patterns, failed operations, and system call usage. Custom reports can focus on specific security concerns or compliance requirements.

**Performance Considerations** Audit rule scope directly impacts system performance and log volume. Broad rules monitoring common system calls can generate massive log volumes and measurable performance overhead.

Rule optimization includes using specific file paths rather than directory trees, limiting system call monitoring to security-relevant operations, and excluding high-frequency but low-risk events.

Buffer sizing and log rotation prevent audit log storage exhaustion. The `auditd.conf` configuration controls buffer sizes, log file rotation, and action responses when storage capacity is exceeded.

### Log Monitoring

Comprehensive log monitoring aggregates, analyzes, and responds to log data from system components, applications, and security tools to detect anomalies and security incidents.

**Log Sources and Types** System logs include kernel messages, authentication events, service status changes, and resource utilization data. The systemd journal (`journalctl`) centralizes logging on modern systems, while traditional syslog handles distributed logging across multiple files.

Application logs provide service-specific information about operations, errors, and user interactions. Web server logs, database logs, and custom application logs contain valuable security information about access patterns and potential attacks.

Security tool logs from firewalls, intrusion detection systems, and antivirus software provide specialized threat intelligence. These logs often use structured formats enabling automated analysis and correlation.

**Centralized Logging Architecture** Log aggregation systems collect logs from multiple sources into centralized repositories for analysis. The ELK stack (Elasticsearch, Logstash, Kibana) provides scalable log processing, storage, and visualization capabilities.

Syslog protocols enable network-based log forwarding using UDP, TCP, or encrypted transport. Reliable delivery mechanisms ensure critical security events reach central collectors even during network disruptions.

Log parsing and normalization convert diverse log formats into standardized schemas enabling cross-source correlation. Regular expressions, structured parsing, and field extraction prepare raw logs for analysis.

**Real-time Monitoring** Stream processing analyzes logs as they arrive, enabling immediate detection of security events. Tools like `tail -f`, `journalctl --follow`, or specialized log monitoring software provide real-time visibility.

Alert generation based on log patterns triggers notifications for security incidents. Rule-based systems can detect failed authentication attempts, privilege escalation, unusual network connections, or application errors.

Threshold-based alerting identifies anomalies in log volume, error rates, or specific event frequencies. Statistical analysis can establish baselines and detect deviations indicating potential security issues.

**Log Correlation and Analysis** Multi-source correlation links related events across different systems and applications. Failed authentication attempts followed by successful logins from different locations indicate potential compromise scenarios.

Behavioral analysis identifies patterns in user and system activity that deviate from established baselines. Machine learning approaches can detect subtle anomalies that rule-based systems might miss.

Forensic analysis capabilities enable detailed investigation of security incidents through historical log data. Timestamp synchronization and chain-of-custody procedures ensure log evidence integrity.

### Intrusion Detection

Intrusion Detection Systems (IDS) monitor network traffic and system activity to identify malicious behavior, policy violations, and security threats through signature-based and anomaly-based detection methods.

**Network Intrusion Detection Systems (NIDS)** NIDS solutions like Suricata, Snort, and Zeek analyze network traffic for malicious patterns, protocol violations, and suspicious communications. These systems inspect packet headers and payload content against threat signatures.

Signature-based detection identifies known attack patterns through rule sets maintained by security researchers. Rules specify packet characteristics, protocol behaviors, and payload content indicating specific threats or exploit attempts.

Protocol analysis detects violations of network protocol specifications that could indicate evasion attempts or malformed attack traffic. Deep packet inspection examines application-layer protocols for embedded threats.

Traffic flow analysis identifies suspicious communication patterns, unusual data volumes, or connections to known malicious infrastructure. NetFlow and similar protocols provide metadata for behavioral analysis.

**Host Intrusion Detection Systems (HIDS)** HIDS solutions monitor individual systems for suspicious activities, unauthorized changes, and policy violations. These systems analyze system calls, file modifications, process behavior, and log entries.

File integrity monitoring detects unauthorized modifications to critical system files, configuration files, and executable programs. Cryptographic hashing identifies even subtle changes to monitored files.

Process behavior monitoring identifies anomalous process execution, unusual system call patterns, or privilege escalation attempts. Behavioral baselines establish normal patterns for comparison.

Log-based HIDS analyze system logs for indicators of compromise, failed authentication attempts, privilege abuse, or other suspicious activities. Integration with system audit facilities provides comprehensive coverage.

**Anomaly Detection** Statistical anomaly detection establishes baselines of normal network and system behavior, then identifies deviations that could indicate threats. Machine learning approaches can adapt to changing environments.

Behavioral profiling creates models of normal user, application, and system activities. Significant deviations from established profiles trigger alerts for investigation.

Threshold-based detection identifies unusual volumes of network traffic, system calls, file access, or other measurable activities. Dynamic thresholds adapt to changing operational patterns.

**Response and Integration** Automated response capabilities can block suspicious network connections, isolate compromised systems, or trigger additional security controls when threats are detected.

Integration with Security Information and Event Management (SIEM) systems enables correlation with other security tools and centralized incident management.

Threat intelligence feeds provide current information about attack signatures, malicious IP addresses, and emerging threats for enhanced detection capabilities.

### File Integrity Monitoring

File Integrity Monitoring (FIM) systems detect unauthorized changes to critical files and directories by maintaining cryptographic checksums and comparing them against current file states.

**Monitoring Scope and Strategy** Critical file selection includes system binaries, configuration files, security credentials, and application executables. The `/etc/` directory, system libraries in `/lib/` and `/usr/lib/`, and executable directories require comprehensive monitoring.

Exclusion strategies prevent alert fatigue from legitimate file changes. Log files, temporary directories, and frequently updated data files should be excluded from monitoring or handled with specialized rules.

Directory tree monitoring can recursively watch entire file system hierarchies, but performance impacts require careful consideration. Selective monitoring of specific files provides better performance characteristics.

**Checksum Algorithms** Cryptographic hash functions like SHA-256 or SHA-512 provide strong integrity verification resistant to collision attacks. Multiple hash algorithms can provide additional verification confidence.

Checksum storage requires secure protection since attackers might attempt to modify integrity databases. Separate storage systems or read-only media can protect integrity data.

Performance optimization includes incremental scanning that only processes files with changed modification times, reducing computational overhead for large file systems.

**Implementation Tools** AIDE (Advanced Intrusion Detection Environment) provides comprehensive file integrity monitoring with flexible configuration options and detailed reporting capabilities. Configuration files specify which files to monitor and what attributes to track.

Tripwire offers commercial and open-source file integrity solutions with policy-based monitoring and cryptographically signed databases. Integration with enterprise security systems provides centralized management.

OSSEC includes file integrity monitoring capabilities alongside host intrusion detection features. Real-time monitoring can detect changes as they occur rather than during scheduled scans.

Custom implementations using tools like `find`, `md5sum`, and scripting can provide tailored file integrity monitoring for specific requirements or resource-constrained environments.

**Baseline Management** Initial baseline creation requires clean system states with all intended software installed and configured. Baseline timing should occur after system hardening but before production deployment.

Baseline updates must be carefully managed to incorporate legitimate system changes while maintaining security. Authorized change procedures should include FIM baseline updates.

Version control systems can track baseline changes over time, providing historical context for file modifications and enabling rollback to previous states if necessary.

**Alert Processing** Change classification distinguishes between authorized and unauthorized modifications. Integration with change management systems can automatically approve expected modifications.

Priority levels help focus attention on critical changes while managing routine modifications. Changes to security-sensitive files warrant immediate investigation.

Forensic capabilities preserve evidence of unauthorized changes for incident response and legal proceedings. Detailed logging includes timestamps, process information, and change context.

**Key points:**

- System auditing through `auditd` provides comprehensive tracking of security-relevant events and system activities
- Log monitoring aggregates and analyzes diverse log sources for security event detection and incident response
- Intrusion detection systems monitor networks and hosts for malicious activities using signature-based and anomaly-based approaches
- File integrity monitoring detects unauthorized changes to critical system files through cryptographic checksums and baseline comparison
- Integration between monitoring tools enables comprehensive security visibility and coordinated incident response

---

