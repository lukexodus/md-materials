## Security Threats and Vulnerabilities


Network security addresses the protection of data in transit and network infrastructure from malicious activities, unauthorized access, and various forms of attacks.

### Threat Categories

#### Passive Attacks

**Eavesdropping/Sniffing:** Unauthorized interception of network communications without altering data **Traffic Analysis:** Studying communication patterns to infer sensitive information **Characteristics:**

- Difficult to detect as no data modification occurs
- Primary goal is information gathering
- Can reveal confidential data, user behavior, and network topology
- Often precede active attacks

#### Active Attacks

**Data Modification:** Altering transmitted information to change its meaning or purpose **Denial of Service (DoS):** Overwhelming network resources to prevent legitimate access **Man-in-the-Middle:** Intercepting and potentially modifying communications between parties **Session Hijacking:** Taking control of established network sessions **Replay Attacks:** Retransmitting captured data to gain unauthorized access

#### Malicious Code Threats

**Viruses:** Self-replicating programs that attach to other executable files **Worms:** Independent programs that spread across networks without user intervention **Trojans:** Seemingly legitimate programs containing hidden malicious functionality **Ransomware:** Malware that encrypts victim data and demands payment for decryption **Botnet Formation:** Compromised computers controlled remotely for coordinated attacks

### Common Vulnerabilities

#### Protocol Vulnerabilities

**Inherent Weaknesses:** Design flaws in network protocols enabling exploitation **Implementation Bugs:** Programming errors in protocol implementations creating security gaps **Configuration Issues:** Improper protocol setup exposing unnecessary attack surfaces

**Examples:**

- Unencrypted protocols transmitting sensitive data in clear text
- Weak authentication mechanisms in legacy protocols
- Buffer overflow vulnerabilities in protocol processing code
- Default configurations with known security weaknesses

#### Infrastructure Vulnerabilities

**Unpatched Systems:** Missing security updates leaving known vulnerabilities exploitable **Weak Access Controls:** Insufficient authentication and authorization mechanisms **Physical Security Gaps:** Inadequate protection of network equipment and cabling **Social Engineering:** Manipulation of personnel to reveal sensitive information or access

#### Application Layer Vulnerabilities

**Cross-Site Scripting (XSS):** Injection of malicious scripts into web applications **SQL Injection:** Database manipulation through malformed input data **Buffer Overflows:** Memory corruption attacks enabling arbitrary code execution **Privilege Escalation:** Gaining higher access levels than initially authorized

### Risk Assessment Framework

**Asset Identification:** Cataloging valuable network resources requiring protection **Threat Modeling:** Identifying potential attackers and their capabilities **Vulnerability Assessment:** Discovering weaknesses in systems and processes **Impact Analysis:** Evaluating potential damage from successful attacks **Risk Calculation:** Combining threat likelihood with potential impact severity

