# Syllabus

## 1. Reconnaissance & Information Gathering

- Physical device inspection
- Component identification
- Port and interface mapping
- Datasheet research
- FCC ID database searches
- PCB layer analysis techniques
- Visual reverse engineering

## 2. UART (Universal Asynchronous Receiver-Transmitter)

- Pin identification (VCC, GND, TX, RX)
- Baud rate detection
- Serial console access
- Common UART tools in Kali
- Bootloader interruption
- Shell access techniques

## 3. JTAG (Joint Test Action Group)

- JTAG interface identification
- Pin identification (TDI, TDO, TCK, TMS, TRST)
- Boundary scan
- Firmware extraction
- Debug access
- OpenOCD usage

## 4. SPI (Serial Peripheral Interface)

- SPI flash chip identification
- Pin mapping (MISO, MOSI, CLK, CS)
- Firmware extraction
- Firmware modification
- Re-flashing techniques

## 5. I²C (Inter-Integrated Circuit)

- Bus sniffing
- Device enumeration
- EEPROM dumping
- Data modification
- Communication analysis

## 6. USB Analysis

- USB enumeration
- Protocol analysis
- BadUSB attacks
- HID device manipulation
- Firmware analysis

## 7. Radio Frequency (RF)

- Signal identification
- Frequency analysis
- SDR (Software Defined Radio) basics
- Replay attacks
- Signal decoding
- Common protocols (433MHz, 315MHz, etc.)

## 8. RFID & NFC

- Card cloning
- UID manipulation
- Protocol analysis (ISO 14443, ISO 15693)
- Mifare classic attacks
- Access control bypass

## 9. Firmware Analysis

- Binwalk usage
- Filesystem extraction
- String analysis
- Entropy analysis
- Compression identification
- Encryption detection

## 10. Reverse Engineering

- Binary analysis
- Ghidra/IDA usage
- ARM/MIPS architecture basics
- Function identification
- Vulnerability discovery

## 11. Side-Channel Attacks

- Power analysis concepts
- Timing attacks
- Electromagnetic analysis
- Fault injection basics
- Glitching techniques

## 12. Exploitation Techniques

- Buffer overflows in embedded systems
- Format string vulnerabilities
- ROP chains for embedded
- Shellcode for ARM/MIPS
- Return-to-libc attacks

## 13. Hardware Tools

- Logic analyzers
- Oscilloscopes
- Multimeters
- Bus Pirate
- FT2232H/FT232H adapters
- ChipWhisperer
- Proxmark3
- HackRF/RTL-SDR

## 14. Kali Linux Tools

- minicom/screen
- flashrom
- avrdude
- esptool
- sigrok
- urh (Universal Radio Hacker)
- inspectrum
- gqrx

## 15. Automotive Systems

- CAN bus analysis
- OBD-II interface
- ECU communication
- Message injection
- Replay attacks

## 16. IoT Protocols

- MQTT analysis
- CoAP protocol
- Zigbee/Z-Wave
- Bluetooth Low Energy (BLE)
- LoRaWAN

## 17. Boot Process Exploitation

- U-Boot manipulation
- Bootloader vulnerabilities
- Secure boot bypass
- Root filesystem modification
- Init system exploitation

## 18. Debug Interfaces

- SWD (Serial Wire Debug)
- J-Link usage
- ST-Link for ARM
- AVR debugging
- Core dump analysis

## 19. Memory Extraction

- NAND flash dumping
- NOR flash extraction
- EEPROM reading
- RAM analysis
- Cold boot attacks

## 20. Network Services

- Telnet exploitation
- SSH weak credentials
- Web interface vulnerabilities
- UPnP exploitation
- DNS vulnerabilities

## 21. Cryptographic Analysis

- Weak key detection
- Hardcoded credentials
- Custom crypto identification
- Random number generation flaws
- Key extraction techniques

## 22. Physical Security

- Tamper detection bypass
- Enclosure opening techniques
- Anti-debugging bypass
- Chip desoldering/reballing
- PCB trace cutting/bridging

## 23. Documentation & Reporting

- Evidence preservation
- Photographic documentation
- Writeup structure
- Proof-of-concept development
- Chain of custody

## 24. Legal & Ethical Considerations

- Authorization requirements
- Responsible disclosure
- CTF rules and boundaries
- Equipment handling
- Data privacy

---

**Note**: [Inference] This syllabus assumes standard CTF hardware challenges and common Kali Linux tool availability. Specific tool versions and capabilities may vary.