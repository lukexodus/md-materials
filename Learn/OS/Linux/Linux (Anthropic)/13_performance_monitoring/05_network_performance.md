## Network Performance


### Network Throughput Testing

Network throughput testing measures the maximum data transfer rate between network endpoints, providing critical insights into bandwidth utilization and network capacity.

#### Bandwidth vs Throughput

Bandwidth represents the theoretical maximum capacity of a network link, while throughput measures the actual data transfer rate achieved in practice. Throughput is typically lower than bandwidth due to protocol overhead, network congestion, and system limitations.

#### Testing Tools and Methods

**iperf3** serves as the industry standard for network throughput testing. It operates in client-server mode, allowing bidirectional testing with customizable parameters:

```bash
# Server mode
iperf3 -s

# Client mode - basic test
iperf3 -c server_ip

# Advanced testing options
iperf3 -c server_ip -t 60 -P 4 -w 1M
```

**netperf** provides comprehensive network performance measurement capabilities with multiple test types including TCP_STREAM, UDP_STREAM, and TCP_RR (request-response).

**nuttcp** offers similar functionality to iperf with additional features for one-way delay measurement and packet loss detection.

#### Factors Affecting Throughput

Network interface capabilities, CPU processing power, memory bandwidth, and kernel network stack efficiency all impact achievable throughput. Modern systems may require tuning of TCP window sizes, interrupt handling, and buffer allocations to achieve optimal performance.

**Key points**: Consistent testing requires isolated network conditions, multiple test runs for statistical validity, and consideration of both upload and download directions.

### Latency Measurement

Network latency represents the time delay for data to travel between network endpoints, critically affecting application responsiveness and user experience.

#### Types of Latency

**Round-Trip Time (RTT)** measures the complete journey from source to destination and back. **One-way delay** measures transmission time in a single direction, requiring synchronized clocks between endpoints.

**Processing delay** occurs at network devices, **transmission delay** depends on link speed and packet size, **propagation delay** relates to physical distance, and **queuing delay** results from network congestion.

#### Measurement Tools

**ping** provides basic RTT measurement using ICMP echo requests:

```bash
# Basic ping test
ping -c 10 target_host

# Specify packet size and interval
ping -c 100 -s 1472 -i 0.1 target_host
```

**hping3** offers advanced packet crafting capabilities for testing with different protocols and packet types.

**mtr** combines ping and traceroute functionality, providing continuous monitoring of latency and packet loss across network hops.

**sockperf** specializes in application-level latency testing with microsecond precision, particularly useful for low-latency applications.

#### Statistical Analysis

Latency measurements require statistical analysis to understand network behavior. Minimum, maximum, average, and percentile values provide insights into network consistency. Jitter (latency variation) affects real-time applications like VoIP and video conferencing.

**Example**: A network showing average latency of 10ms but 99th percentile of 100ms indicates intermittent congestion issues.

### Network Optimization

Network optimization involves systematic tuning of kernel parameters, buffer sizes, and protocol settings to maximize performance for specific workloads.

#### TCP Tuning Parameters

**TCP window scaling** enables larger receive windows for high-bandwidth, high-latency networks:

```bash
# Enable TCP window scaling
echo 1 > /proc/sys/net/ipv4/tcp_window_scaling

# Set TCP receive buffer sizes
echo "4096 87380 16777216" > /proc/sys/net/ipv4/tcp_rmem
echo "4096 65536 16777216" > /proc/sys/net/ipv4/tcp_wmem
```

**TCP congestion control algorithms** significantly impact performance. Modern algorithms like BBR optimize for bandwidth and latency rather than packet loss.

#### Buffer Management

Network buffers at various layers require careful tuning. Socket buffers, network interface ring buffers, and kernel network buffers all affect performance. Insufficient buffering causes packet drops, while excessive buffering increases latency.

#### Interrupt Handling Optimization

**Receive Side Scaling (RSS)** distributes network interrupts across multiple CPU cores, improving scalability on multi-core systems. **NAPI (New API)** polling reduces interrupt overhead for high-traffic scenarios.

#### Network Interface Optimization

Modern network interfaces support hardware offloading features including TCP Segment Offload (TSO), Generic Receive Offload (GRO), and checksum offloading. These features reduce CPU utilization but may affect latency-sensitive applications.

**Key points**: Optimization requires understanding application requirements, network characteristics, and system capabilities. Changes should be tested systematically with rollback procedures.

### Traffic Shaping

Traffic shaping controls network bandwidth allocation and packet scheduling to ensure quality of service and prevent network congestion.

#### Quality of Service (QoS) Concepts

**Traffic classification** categorizes network flows based on application type, source/destination, or other criteria. **Traffic policing** enforces rate limits by dropping or marking non-conforming packets. **Traffic shaping** smooths traffic bursts by buffering and scheduling packet transmission.

#### Linux Traffic Control (tc)

The tc utility provides comprehensive traffic shaping capabilities through queuing disciplines (qdiscs), classes, and filters.

**Hierarchical Token Bucket (HTB)** enables bandwidth allocation with borrowing between classes:

```bash
# Create HTB qdisc
tc qdisc add dev eth0 root handle 1: htb default 20

# Create classes with bandwidth limits
tc class add dev eth0 parent 1: classid 1:1 htb rate 100mbit
tc class add dev eth0 parent 1:1 classid 1:10 htb rate 80mbit ceil 100mbit
tc class add dev eth0 parent 1:1 classid 1:20 htb rate 20mbit ceil 100mbit

# Add filters to classify traffic
tc filter add dev eth0 parent 1: protocol ip prio 1 u32 match ip dport 80 0xffff flowid 1:10
```

#### Queuing Disciplines

**FIFO (First In, First Out)** provides simple packet queuing without prioritization. **Priority queuing** serves higher-priority traffic first. **Fair queuing** ensures equitable bandwidth sharing among flows.

**Controlled Delay (CoDel)** actively manages queue length to reduce bufferbloat while maintaining throughput. **Fair Queue CoDel (fq_codel)** combines fair queuing with active queue management.

#### Advanced Shaping Techniques

**Token bucket algorithms** allow traffic bursts while maintaining average rate limits. **Hierarchical shaping** enables complex policies with multiple priority levels and bandwidth guarantees.

**Ingress shaping** controls incoming traffic, though options are more limited than egress shaping. **[Inference]** Ingress policing typically drops excess packets rather than queuing them.

#### Monitoring and Troubleshooting

Traffic shaping effectiveness requires continuous monitoring of queue depths, drop rates, and latency metrics. Tools like tc, ss, and netstat provide visibility into shaping behavior.

**Example**: A web server requiring 80Mbps guaranteed bandwidth with ability to burst to 100Mbps during peak periods would use HTB with rate 80mbit and ceil 100mbit.

**Key points**: Traffic shaping policies must align with network capacity and application requirements. Complex hierarchies require careful testing to avoid unintended interactions between classes.

**Important related topics**: Network security performance impact, container networking optimization, network monitoring and alerting, software-defined networking (SDN) integration.

---

