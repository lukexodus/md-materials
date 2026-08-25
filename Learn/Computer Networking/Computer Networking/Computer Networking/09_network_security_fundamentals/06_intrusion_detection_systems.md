## Intrusion Detection Systems


Intrusion Detection Systems (IDS) monitor network traffic and system activities to identify potential security threats and policy violations.

### IDS Categories

#### Network-Based IDS (NIDS)

**Deployment:** Sensors positioned at strategic network locations **Traffic Analysis:** Monitor network segments for suspicious activities **Placement Strategies:**

- Internet connection points for external threat detection
- Internal network segments for insider threat monitoring
- Server farm connections for critical asset protection
- Wireless network access points for mobile device monitoring

**Advantages:**

- Monitor multiple hosts simultaneously
- Detect network-based attacks effectively
- Minimal impact on monitored systems
- Centralized monitoring and management

**Limitations:**

- Cannot inspect encrypted traffic content
- Performance degrades with high bandwidth utilization
- Limited visibility into host-specific activities
- Difficulty analyzing fragmented or reassembled packets

#### Host-Based IDS (HIDS)

**Agent Installation:** Software installed on individual systems requiring protection **System Monitoring:** File integrity, log analysis, system call monitoring, configuration changes **Data Sources:**

- Operating system audit logs
- Application logs and error messages
- File system modifications
- Registry changes (Windows systems)
- Process execution monitoring

**Advantages:**

- Detailed visibility into system activities
- Can detect encrypted attack communications
- Monitor system-specific vulnerabilities
- Provide precise attack attribution

**Limitations:**

- Resource consumption on monitored hosts
- Management complexity with many agents
- Operating system specific implementations
- Vulnerable to sophisticated rootkit attacks

### Detection Methodologies

#### Signature-Based Detection

**Pattern Matching:** Compare network traffic or system activities against known attack signatures **Signature Database:** Comprehensive collection of attack patterns and malware indicators **Accuracy:** Low false positive rates for known threats **Update Requirements:** Regular signature updates to detect new threats

**Signature Components:**

- Attack pattern descriptions
- Protocol-specific indicators
- Byte sequence patterns
- Statistical anomaly thresholds

**Limitations:**

- Cannot detect previously unknown attacks (zero-day threats)
- Requires frequent signature updates
- Performance impact with large signature databases
- Vulnerable to attack signature evasion techniques

#### Anomaly-Based Detection

**Baseline Establishment:** Learn normal network and system behavior patterns **Deviation Detection:** Identify activities significantly different from established baselines **Machine Learning:** Advanced algorithms improve detection accuracy over time **Adaptive Capabilities:** Continuously update behavioral models

**Behavioral Indicators:**

- Unusual network traffic volumes or patterns
- Abnormal user access patterns
- Unexpected system resource utilization
- Atypical application usage patterns

**Advantages:**

- Detect previously unknown attacks
- Adapt to changing network environments
- Identify insider threats and policy violations
- Provide early warning of emerging threats

**Challenges:**

- Higher false positive rates
- Requires extensive training periods
- Difficulty distinguishing malicious from legitimate anomalies
- Complex tuning and configuration requirements

#### Hybrid Detection Systems

**Combined Approach:** Integrate signature-based and anomaly-based detection methods **Complementary Strengths:** Leverage advantages of both detection methodologies **Correlation Engines:** Combine alerts from multiple detection systems **Risk Scoring:** Prioritize alerts based on multiple detection indicators

### IDS Response Capabilities

#### Passive Response

**Alert Generation:** Notify security personnel of detected threats **Logging:** Record detailed information about security events **Reporting:** Generate periodic security summary reports **Evidence Collection:** Preserve forensic evidence for investigation

#### Active Response

**Connection Termination:** Automatically drop suspicious network connections **IP Address Blocking:** Temporarily block traffic from attacking sources **Service Reconfiguration:** Modify firewall rules or service configurations **Countermeasures:** Launch defensive actions against detected attacks

**Caution:** Active responses may cause service disruptions if misconfigured or triggered by false positives

