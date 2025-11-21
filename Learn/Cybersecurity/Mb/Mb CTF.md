# Syllabus

## **Module 1: Fundamentals**

### 1.1 Mobile Security Basics

- Mobile OS architectures (Android/iOS)
- Security models and sandboxing
- Permission systems
- Application signing and certificates
- Mobile threat landscape

### 1.2 CTF Competition Basics

- Challenge types and categories
- Scoring systems
- Common flags formats
- Time management strategies
- Documentation practices

---

## **Module 2: Environment Setup (Kali Linux)**

### 2.1 Virtual Environment

- Kali Linux installation and configuration
- Android emulator setup (Genymotion, Android Studio AVD)
- iOS simulator alternatives
- Virtual device networking

### 2.2 Essential Tools Installation

- ADB (Android Debug Bridge)
- Frida and Frida-server
- Objection
- MobSF (Mobile Security Framework)
- APKTool, dex2jar, JD-GUI
- Burp Suite configuration
- SSL pinning bypass tools

### 2.3 Physical Device Setup

- USB debugging enablement
- Root/jailbreak procedures
- Custom ROM installation
- Magisk and root management

---

## **Module 3: Android Reconnaissance**

### 3.1 APK Analysis

- APK structure and components
- AndroidManifest.xml examination
- Package inspection
- Certificate and signature verification
- Version and build information extraction

### 3.2 Static Analysis

- Decompilation techniques
- Source code review
- Resource file analysis
- Native library examination
- Identifying entry points

### 3.3 Information Gathering

- Permission analysis
- Activity and intent enumeration
- Broadcast receiver identification
- Content provider discovery
- Service mapping

---

## **Module 4: Android Reverse Engineering**

### 4.1 Decompilation Tools

- APKTool usage
- dex2jar conversion
- JD-GUI, JADX, Ghidra
- Baksmali/Smali manipulation
- Asset extraction

### 4.2 Code Analysis

- Java/Kotlin code review
- Obfuscation identification
- Control flow analysis
- Algorithm reconstruction
- Cryptographic function identification

### 4.3 Native Code Analysis

- ARM assembly basics
- Native library (.so) analysis
- IDA Pro/Ghidra for ARM
- JNI interface examination
- String and function identification

---

## **Module 5: Android Dynamic Analysis**

### 5.1 Runtime Environment

- ADB command reference
- Logcat monitoring
- File system navigation
- Process and package management
- Shell access techniques

### 5.2 Debugging

- Remote debugging setup
- Breakpoint placement
- Variable inspection
- Method hooking
- Runtime manipulation

### 5.3 Traffic Analysis

- Proxy configuration (Burp Suite, mitmproxy)
- Certificate installation
- HTTP/HTTPS interception
- WebSocket monitoring
- API endpoint discovery

---

## **Module 6: Android Instrumentation**

### 6.1 Frida Framework

- Frida installation and setup
- JavaScript API basics
- Script writing fundamentals
- Process attachment methods
- Spawn vs attach modes

### 6.2 Runtime Manipulation

- Method hooking techniques
- Function overriding
- Return value modification
- Argument manipulation
- Class instantiation

### 6.3 Objection Usage

- Common objection commands
- SSL pinning bypass
- Root detection bypass
- File system operations
- Runtime class exploration

---

## **Module 7: Android Security Bypass**

### 7.1 Authentication Bypass

- Root detection mechanisms
- Emulator detection
- Debugger detection
- Integrity checks
- License verification

### 7.2 SSL Pinning Bypass

- Certificate pinning methods
- Frida scripts for bypass
- Objection automation
- Manual patching techniques
- Network security config modification

### 7.3 Obfuscation Defeat

- ProGuard/R8 deobfuscation
- String decryption
- Control flow unflattening
- Packer identification
- Anti-tampering bypass

---

## **Module 8: Android Exploitation**

### 8.1 Common Vulnerabilities

- Insecure data storage
- Weak cryptography
- Insecure communication
- Improper platform usage
- Code injection points

### 8.2 Intent Exploitation

- Intent fuzzing
- Exported component exploitation
- Intent spoofing
- Deep link manipulation
- Broadcast injection

### 8.3 WebView Attacks

- JavaScript interface exploitation
- XSS in WebViews
- File access vulnerabilities
- URL scheme handling
- Bridge function abuse

---

## **Module 9: iOS Basics**

### 9.1 iOS Architecture

- iOS security model
- Sandbox architecture
- Code signing
- Entitlements system
- Keychain services

### 9.2 iOS Application Structure

- IPA file format
- Binary analysis (Mach-O)
- Info.plist examination
- Resource bundling
- Framework dependencies

### 9.3 iOS Analysis Tools

- Class-dump usage
- Hopper/IDA for ARM64
- Cycript basics
- iProxy and usbmuxd
- SSH over USB

---

## **Module 10: iOS Reverse Engineering**

### 10.1 Static Analysis

- Binary decompilation
- Objective-C/Swift analysis
- Class and method enumeration
- String analysis
- Cryptographic routine identification

### 10.2 Dynamic Analysis

- LLDB debugging
- Frida on iOS
- Runtime class dumping
- Method swizzling
- Cycript injection

### 10.3 Jailbreak Detection Bypass

- Common detection methods
- Frida bypass scripts
- Binary patching
- Substrate hook removal
- File system artifact hiding

---

## **Module 11: Data Extraction & Analysis**

### 11.1 Application Data

- Shared preferences/NSUserDefaults
- SQLite database extraction
- File system analysis
- Cache examination
- Log file review

### 11.2 Secure Storage

- Android Keystore analysis
- iOS Keychain extraction
- Encrypted database handling
- Secure enclave interaction
- Backup file analysis

### 11.3 Memory Analysis

- Memory dumping techniques
- Heap analysis
- String extraction from memory
- Sensitive data in RAM
- Memory forensics tools

---

## **Module 12: Network Security**

### 12.1 Protocol Analysis

- HTTP/HTTPS traffic inspection
- REST API analysis
- GraphQL endpoint testing
- WebSocket communication
- Protocol buffer decoding

### 12.2 Man-in-the-Middle

- Proxy setup and configuration
- Certificate authority installation
- SSL/TLS interception
- Request tampering
- Response modification

### 12.3 API Security Testing

- Authentication mechanism testing
- Authorization bypass
- Parameter manipulation
- Rate limiting testing
- API endpoint discovery

---

## **Module 13: Cryptography in Mobile**

### 13.1 Cryptographic Analysis

- Algorithm identification
- Key extraction techniques
- Hardcoded secrets discovery
- Weak implementation identification
- Custom crypto analysis

### 13.2 Common Crypto Issues

- Weak encryption algorithms
- Insecure key storage
- Predictable IVs/salts
- ECB mode usage
- Hash collision attacks

### 13.3 Cryptanalysis Tools

- John the Ripper
- Hashcat
- CyberChef
- Python cryptography libraries
- OpenSSL utilities

---

## **Module 14: Automated Analysis**

### 14.1 Static Analysis Frameworks

- MobSF setup and usage
- QARK (Quick Android Review Kit)
- AndroBugs Framework
- Report interpretation
- Custom rule creation

### 14.2 Dynamic Analysis Automation

- Drozer framework
- Appmon usage
- Custom Frida scripts
- Automated testing frameworks
- CI/CD integration

### 14.3 Vulnerability Scanning

- OWASP dependency check
- Third-party library scanning
- Known vulnerability databases
- CVE identification
- Patch level verification

---

## **Module 15: Advanced Techniques**

### 15.1 Code Injection

- Smali code injection
- DEX manipulation
- Library injection
- Hook implementation
- Payload crafting

### 15.2 Binary Patching

- Hex editing techniques
- Instruction modification
- Function NOP-ing
- Jump instruction insertion
- Checksum recalculation

### 15.3 Custom Tool Development

- Python scripting for automation
- Frida script development
- ADB wrapper creation
- Custom analysis tools
- Report generators

---

## **Module 16: CTF-Specific Techniques**

### 16.1 Flag Hunting

- Common hiding locations
- Encoded flag identification
- Obfuscated strings
- Resource file flags
- Network response flags

### 16.2 Challenge Categories

- Reverse engineering challenges
- Cryptography challenges
- Forensics challenges
- Web-based mobile challenges
- Binary exploitation

### 16.3 Time Optimization

- Triage techniques
- Tool selection strategies
- Automation approaches
- Team collaboration
- Note-taking systems

---

## **Module 17: Reporting & Documentation**

### 17.1 Finding Documentation

- Screenshot capture
- Command history preservation
- Tool output saving
- Video recording techniques
- Proof-of-concept creation

### 17.2 Write-up Creation

- Structure and format
- Step-by-step documentation
- Tool command reference
- Solution explanation
- Lessons learned

### 17.3 Knowledge Base Building

- Personal cheatsheet creation
- Script repository management
- Tool configuration backup
- Common pattern library
- Quick reference guides

---

## **Module 18: Platform-Specific Advanced Topics**

### 18.1 Android Advanced

- SELinux policy analysis
- Binder IPC exploitation
- Native service interaction
- System app analysis
- Custom ROM modifications

### 18.2 iOS Advanced

- XPC service analysis
- Objective-C runtime manipulation
- Swift runtime internals
- Secure enclave research
- Private framework usage

### 18.3 Cross-Platform

- React Native analysis
- Flutter reverse engineering
- Xamarin application testing
- Cordova/Ionic security
- Unity game hacking

---

## **Module 19: Lab Exercises**

### 19.1 Beginner Challenges

- Basic APK analysis
- Simple authentication bypass
- Hardcoded credential extraction
- Basic traffic interception
- String decoding

### 19.2 Intermediate Challenges

- SSL pinning bypass
- Custom encryption breaking
- Native library analysis
- Complex obfuscation
- Multi-stage challenges

### 19.3 Advanced Challenges

- Anti-analysis defeat
- Custom protocol analysis
- Advanced exploitation
- Multi-platform challenges
- Real-world application testing

---

## **Module 20: Resources & Community**

### 20.1 Practice Platforms

- Mobile CTF platforms
- Vulnerable mobile apps
- Training applications
- Online labs
- Practice challenges

### 20.2 Reference Materials

- OWASP Mobile Top 10
- Tool documentation
- Blog and write-up collections
- Video tutorials
- Research papers

### 20.3 Community Engagement

- CTF team participation
- Discord/Slack communities
- Conference attendance
- Bug bounty programs
- Open-source contribution

---

## **Appendix: Quick Reference**

### A. Command Cheatsheets

- ADB commands
- Frida snippets
- Objection commands
- APKTool usage
- Common exploits

### B. Tool Comparison Matrices

- Decompiler comparison
- Analysis framework features
- Debugger capabilities
- Proxy tool features

### C. File Format References

- APK structure
- IPA structure
- Manifest elements
- Binary formats
- Certificate formats

### D. Vulnerability Templates

- OWASP Mobile categories
- Common weakness patterns
- Testing methodologies
- Remediation guidance