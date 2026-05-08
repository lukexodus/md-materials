## Core / General

**blackarch** The meta-group containing all BlackArch tools. Installing this pulls the entire toolset.

**blackarch-misc** Tools that don't fit neatly into other categories — miscellaneous utilities used in security work.

**blackarch-config** Tools for configuration auditing, management, or manipulation of system/application configs.

**blackarch-automation** Tools that automate repetitive security tasks — scripting frameworks, task runners, workflow helpers.

**blackarch-wordlist** Password lists, dictionary files, and other wordlist resources used in cracking and fuzzing.

---

## Reconnaissance & Information Gathering

**blackarch-recon** Active and passive reconnaissance tools — OSINT, subdomain enumeration, service discovery, footprinting.

**blackarch-reocn** [Unverified] Likely a typographical duplicate or alias of `blackarch-recon`. The distinction, if any, is not confirmed in official documentation.

**blackarch-fingerprint** Tools that identify software versions, OS types, service banners, and device characteristics.

**blackarch-networking** General network analysis and utility tools — topology mapping, protocol analysis, connectivity testing.

**blackarch-scanner** Vulnerability and port scanners — tools like network sweepers, service probers, and CVE scanners.

---

## Web & Application Security

**blackarch-webapp** Web application security tools — SQL injection testers, XSS scanners, CMS auditors, web crawlers.

**blackarch-fuzzer** Fuzzing tools that send malformed or random input to applications to discover crashes or vulnerabilities.

**blackarch-proxy** Intercepting and traffic manipulation proxies — tools that sit between client and server to inspect or modify HTTP/S and other traffic.

**blackarch-code-audit** Static analysis and source code review tools that look for security flaws in codebases.

---

## Exploitation

**blackarch-exploitation** Exploit frameworks and tools — payloads, shellcode runners, post-exploitation utilities.

**blackarch-backdoor** Tools for creating or managing persistent remote access mechanisms after a system is compromised.

**blackarch-binary** Tools that operate on binary files — patching, analysis, manipulation at the binary level.

**blackarch-packer** Tools for packing, compressing, or obfuscating executables — often used in malware research and AV evasion testing.

**blackarch-unpacker** The inverse of packers — tools that unpack or decompress obfuscated/packed executables.

---

## Reverse Engineering & Analysis

**blackarch-reversing** Reverse engineering tools — disassemblers, decompilers, binary analysis frameworks.

**blackarch-disassembler** Tools specifically focused on disassembly — converting machine code back to assembly language.

**blackarch-decompiler** Tools that attempt to recover higher-level source code from compiled binaries.

**blackarch-debugger** Dynamic analysis tools that let you step through program execution, inspect memory, and set breakpoints.

---

## Password & Credential Attacks

**blackarch-cracker** Password cracking tools — hash crackers, brute-force engines, offline and online attack tools.

**blackarch-gpu** Tools that leverage GPU acceleration, primarily for password cracking (e.g., Hashcat-class workloads).

---

## Network Attacks & Interception

**blackarch-sniffer** Packet capture and traffic analysis tools — tools that passively observe network traffic.

**blackarch-spoof** Spoofing tools for impersonating IP addresses, MAC addresses, DNS responses, ARP entries, etc.

**blackarch-dos** Denial-of-Service testing tools — used in controlled environments to test service resilience.

**blackarch-tunnel** Tunneling tools — encapsulate traffic inside other protocols, bypass firewalls, or create covert channels.

**blackarch-proxy** _(also listed above under Web)_ Overlaps here too — proxies are used for both web app testing and network-level traffic interception.

---

## Wireless & Radio

**blackarch-wireless** Wi-Fi security tools — WPA/WEP cracking, deauthentication attacks, rogue AP setup, wireless monitoring.

**blackarch-bluetooth** Bluetooth security tools — scanning, pairing attacks, protocol fuzzing over Bluetooth.

**blackarch-radio** Software-defined radio (SDR) tools — analyzing and interacting with RF signals across various frequencies.

**blackarch-nfc** Near-field communication security tools — cloning, fuzzing, and analyzing NFC/RFID tags and readers.

**blackarch-drone** Tools related to drone/UAV security — signal interception, protocol analysis, or control system testing.

---

## Mobile & Embedded

**blackarch-mobile** Mobile platform security tools — Android/iOS app analysis, ADB utilities, APK reversing.

**blackarch-firmware** Tools for extracting, analyzing, and modifying firmware from embedded devices and IoT hardware.

**blackarch-hardware** Physical hardware security tools — JTAG interfaces, SPI/I2C communication, hardware debugging.

**blackarch-automobile** Automotive security tools — CAN bus analysis, OBD-II interfaces, vehicle network testing.

---

## Cryptography & Steganography

**blackarch-crypto** Cryptographic tools — cipher analysis, key generation, protocol testing, hash utilities.

**blackarch-stego** Steganography tools — hiding or detecting hidden data inside images, audio, or other carrier files.

---

## Forensics & Anti-Forensics

**blackarch-forensic** Digital forensics tools — disk imaging, memory analysis, artifact recovery, timeline reconstruction.

**blackarch-anti-forensic** Tools designed to hinder forensic investigation — log wiping, file shredding, timestamp manipulation.

---

## Social Engineering & OSINT

**blackarch-social** Social engineering frameworks and tools — phishing kits, pretexting aids, credential harvesting pages.

---

## Specialized Protocols & Services

**blackarch-voip** VoIP security tools — SIP fuzzing, call interception, protocol analysis for voice-over-IP systems.

**blackarch-database** Database security tools — SQL injection frameworks, database enumeration, credential testing against DB services.

**blackarch-windows** Tools specifically targeting Windows environments — AD attacks, SMB exploitation, credential dumping, etc.

---

## Defense & Monitoring

**blackarch-defensive** Security defense tools — hardening utilities, monitoring agents, configuration checkers.

**blackarch-ids** Intrusion detection system tools — both for setting up IDS and for testing/evading them.

**blackarch-honeypot** Decoy systems and services designed to attract and detect attackers or study attack behavior.

**blackarch-threat-model** Tools that assist with threat modeling — mapping attack surfaces, diagramming trust boundaries, risk analysis.

---

## Malware Research

**blackarch-malware** Malware analysis tools — sandboxes, behavior analyzers, signature extractors, dynamic analysis environments.

**blackarch-keylogger** Keylogging tools — used in controlled security research and red team scenarios.

---

## AI / Emerging

**blackarch-ai** Tools applying AI or machine learning in a security context — anomaly detection, AI-assisted fuzzing, adversarial ML research.

---

These groups collectively form one of the largest open security tool repositories, with **2,800+ tools** as of recent counts. They're intended for use by penetration testers, security researchers, and CTF participants in **authorized environments only**.