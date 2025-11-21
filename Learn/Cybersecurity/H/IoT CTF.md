# Syllabus

## Module 1: IoT Fundamentals & Architecture

- IoT ecosystem components
- Device types and classifications
- Communication protocols overview
- IoT technology stack layers
- Edge computing vs cloud architecture
- Gateway and hub functions
- Sensor and actuator basics

## Module 2: Environment Setup & Lab Configuration

- Kali Linux IoT tools installation
- Virtual lab environment setup
- Hardware testing lab setup
- Network isolation configuration
- Device emulation platforms
- Firmware analysis environment
- Serial console setup

## Module 3: IoT Reconnaissance & Information Gathering

- Device discovery techniques
- Network scanning for IoT devices
- Service enumeration
- Banner grabbing
- OSINT for IoT devices
- Manufacturer identification
- Default credential databases
- Shodan and IoT search engines

## Module 4: Hardware Analysis Fundamentals

- PCB (Printed Circuit Board) analysis
- Component identification
- Chip marking interpretation
- Datasheet research
- Pin identification
- Voltage level detection
- Hardware documentation analysis

## Module 5: UART/Serial Communication

- UART protocol basics
- Serial port identification
- Baud rate detection
- Serial console access
- Terminal emulation
- Command injection via serial
- Boot sequence analysis

## Module 6: JTAG & Debug Interfaces

- JTAG protocol fundamentals
- Debug port identification
- Pin mapping techniques
- Boundary scan
- Firmware extraction via JTAG
- Debug interface enumeration
- SWD (Serial Wire Debug)

## Module 7: SPI & I2C Analysis

- SPI protocol fundamentals
- I2C protocol fundamentals
- Bus sniffing techniques
- Memory chip communication
- EEPROM extraction
- Flash memory dumping
- Logic analyzer usage

## Module 8: Firmware Acquisition

- Firmware download methods
- OTA update interception
- Physical extraction techniques
- Memory chip reading
- Firmware dumping via debug interfaces
- Network-based extraction
- Bootloader exploitation

## Module 9: Firmware Analysis - Initial Assessment

- File type identification
- Firmware unpacking
- File system extraction
- Compression detection
- Encryption identification
- Entropy analysis
- Firmware format recognition

## Module 10: Firmware Binary Analysis

- Binary structure analysis
- Architecture identification (ARM, MIPS, x86)
- Endianness determination
- Base address identification
- String extraction
- Cryptographic constant search
- Hardcoded credential discovery

## Module 11: Firmware Reverse Engineering

- Disassembly techniques for embedded systems
- Cross-architecture reverse engineering
- Function identification
- Vulnerability pattern recognition
- Custom protocol analysis
- Algorithm reconstruction
- Encryption key extraction

## Module 12: Firmware File System Analysis

- SquashFS extraction
- JFFS2 analysis
- YAFFS examination
- cramfs unpacking
- UBI/UBIFS handling
- Configuration file analysis
- Embedded web server discovery

## Module 13: Firmware Modification & Repackaging

- Firmware unpacking workflows
- Binary patching
- File system modification
- Backdoor insertion
- Firmware repackaging
- Checksum recalculation
- Signature bypass techniques

## Module 14: Firmware Emulation

- QEMU setup for IoT architectures
- User-mode emulation
- Full system emulation
- Firmware-analysis-toolkit usage
- Dynamic analysis in emulation
- Network configuration for emulated devices
- Debug environment setup

## Module 15: Network Protocol Analysis - Wireless

- WiFi security assessment
- Bluetooth/BLE analysis
- Zigbee protocol examination
- Z-Wave security testing
- LoRaWAN analysis
- NFC/RFID testing
- 6LoWPAN analysis

## Module 16: Network Protocol Analysis - Wired

- Ethernet traffic analysis
- VLAN configuration review
- Industrial protocol testing (Modbus, DNP3)
- Building automation protocols (BACnet, KNX)
- CAN bus analysis
- PLC communication protocols

## Module 17: Application Layer Protocols

- MQTT security testing
- CoAP analysis
- AMQP examination
- XMPP testing
- HTTP/HTTPS on embedded devices
- WebSocket analysis
- Custom protocol reverse engineering

## Module 18: Web Interface Analysis

- Embedded web server identification
- Web application vulnerability testing
- Authentication bypass techniques
- Session management analysis
- API endpoint discovery
- Hidden parameter identification
- Client-side code analysis

## Module 19: Mobile Application Analysis

- IoT companion app identification
- APK/IPA extraction and analysis
- API endpoint extraction
- Hardcoded credentials discovery
- Certificate pinning bypass
- Traffic interception
- Deep link analysis

## Module 20: Cloud & Backend Analysis

- Cloud service identification
- API security testing
- Authentication mechanism analysis
- Authorization bypass techniques
- Data storage examination
- Server-side vulnerability testing
- Multi-tenancy issues

## Module 21: Authentication & Authorization

- Default credential testing
- Weak password identification
- Authentication mechanism bypass
- Token analysis and manipulation
- Session hijacking
- Privilege escalation
- Multi-factor authentication bypass

## Module 22: Encryption & Cryptographic Analysis

- Encryption algorithm identification
- Weak cryptography detection
- Key management analysis
- Certificate validation testing
- SSL/TLS configuration review
- Cryptographic implementation flaws
- Custom encryption breaking

## Module 23: Update Mechanisms

- OTA update process analysis
- Update authentication testing
- Update integrity verification
- Downgrade attack feasibility
- Man-in-the-middle update injection
- Update server security
- Rollback protection analysis

## Module 24: Physical Security Assessment

- Tamper protection evaluation
- Physical access exploitation
- Debug port access
- Case opening detection bypass
- Component removal/replacement
- Side-channel attack feasibility
- Secure boot bypass

## Module 25: Radio Frequency Analysis

- SDR (Software Defined Radio) setup
- Frequency identification
- Signal capture and replay
- Modulation analysis
- Jamming attack testing
- RF protocol reverse engineering
- Wireless eavesdropping

## Module 26: Bluetooth & BLE Security

- Bluetooth device enumeration
- BLE service discovery
- Characteristic analysis
- Pairing and bonding testing
- GATT protocol analysis
- Bluetooth sniffing
- Spoofing and replay attacks

## Module 27: Zigbee & Z-Wave Security

- Zigbee network scanning
- Key extraction techniques
- Network joining attacks
- Packet sniffing and analysis
- Replay attacks
- Z-Wave security assessment
- Mesh network exploitation

## Module 28: Industrial IoT (IIoT) Security

- SCADA system reconnaissance
- PLC security testing
- Industrial protocol analysis
- HMI vulnerability assessment
- OT network segmentation review
- Safety system analysis
- Legacy system security

## Module 29: Automotive IoT Security

- CAN bus analysis
- OBD-II interface testing
- ECU identification
- Vehicle network mapping
- Infotainment system testing
- Telematics analysis
- V2X communication security

## Module 30: Smart Home Security

- Smart hub analysis
- Voice assistant security
- Smart lock testing
- Camera security assessment
- Smart lighting exploitation
- Thermostat security testing
- Appliance interface analysis

## Module 31: Wearables & Medical IoT

- Wearable device analysis
- Health data extraction
- Medical device security testing
- Implantable device assessment
- Sensor data manipulation
- Privacy analysis
- Regulatory compliance review

## Module 32: Vulnerability Identification

- Buffer overflow detection
- Command injection identification
- SQL injection in embedded databases
- Path traversal vulnerabilities
- Insecure deserialization
- Race conditions
- Memory corruption bugs

## Module 33: Exploitation Techniques

- Exploit development for embedded systems
- Return-oriented programming (ROP)
- Shellcode for constrained environments
- Privilege escalation exploits
- Remote code execution
- Denial of service attacks
- Persistence mechanism creation

## Module 34: Side-Channel Attacks

- Power analysis (SPA/DPA)
- Timing attacks
- Electromagnetic analysis
- Acoustic cryptanalysis
- Cache timing attacks
- Fault injection
- Glitching attacks

## Module 35: Man-in-the-Middle Attacks

- ARP spoofing for IoT networks
- DNS hijacking
- SSL/TLS interception
- Protocol downgrade attacks
- Rogue access point creation
- Gateway impersonation
- Transparent proxy setup

## Module 36: Backdoor & Persistence Analysis

- Hidden backdoor discovery
- Persistence mechanism identification
- Undocumented feature analysis
- Debug interface abuse
- Rootkit detection
- Supply chain backdoors
- Malicious firmware components

## Module 37: Privacy & Data Protection

- Data collection analysis
- PII identification
- Data transmission security
- Storage security assessment
- Data retention analysis
- User tracking mechanisms
- Consent mechanism review

## Module 38: Wireless Attack Techniques

- Evil twin attacks
- Deauthentication attacks
- WPS vulnerability exploitation
- WiFi password cracking
- Rogue device detection
- Wireless DoS attacks
- Packet injection

## Module 39: Denial of Service Testing

- Resource exhaustion attacks
- Protocol-specific DoS
- Amplification attacks
- Crash condition identification
- Availability impact assessment
- Recovery mechanism testing
- Distributed IoT botnet simulation

## Module 40: Botnet & Malware Analysis

- IoT malware identification
- Botnet C2 communication analysis
- Malware propagation methods
- DDoS bot detection
- Cryptomining malware
- Worm behavior analysis
- Infection vector identification

## Module 41: Supply Chain Security

- Component authenticity verification
- Counterfeit detection
- Third-party library analysis
- Open source component review
- Vendor security assessment
- Manufacturing process security
- Distribution chain analysis

## Module 42: Compliance & Standards

- OWASP IoT Top 10
- NIST IoT security guidelines
- IEC 62443 standards
- ETSI EN 303 645
- IoT security certification schemes
- Regional regulatory requirements
- Industry-specific standards

## Module 43: Automated Testing & Scanning

- Automated vulnerability scanners
- Fuzzing embedded devices
- Network scanning automation
- Continuous security testing
- CI/CD integration for IoT
- Custom script development
- Report generation automation

## Module 44: CTF-Specific Techniques

- Flag hiding locations in IoT
- Multi-stage IoT challenges
- Hardware challenge approaches
- Firmware challenge strategies
- Protocol-based challenges
- Time-limited attack scenarios
- Combined hardware-software challenges

## Module 45: Documentation & Reporting

- Technical report structure
- Vulnerability documentation
- Proof-of-concept creation
- Risk assessment methodology
- Remediation recommendations
- Chain-of-custody for hardware
- Visual documentation techniques

## Module 46: Tool Reference - Hardware

- Logic analyzers
- Oscilloscopes
- Multimeters
- Bus pirates
- JTAGulators
- Chip readers/programmers
- SDR equipment

## Module 47: Tool Reference - Software

- Firmware analysis tools
- Disassemblers and decompilers
- Protocol analyzers
- Network tools
- Exploitation frameworks
- Emulation platforms
- Reverse engineering suites

## Module 48: Resources & Databases

- Vulnerability databases
- Exploit databases
- IoT device databases
- Protocol specifications
- Security advisories
- Research papers
- Community resources