## TFTP, FTP, and SCP File Transfers


### TFTP Configuration and Usage

**Configuring TFTP Server (on external server):**
- Install TFTP server software (Tftpd64, SolarWinds TFTP, etc.)
- Configure root directory
- Disable firewall restrictions for UDP port 69
- Ensure network connectivity

**TFTP Upload from Router:**
```
R1# copy flash:c2900-universalk9-mz.SPA.157-3.M5.bin tftp: Address or name of remote host []? 192.168.1.100 Destination filename [c2900-universalk9-mz.SPA.157-3.M5.bin]? !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 125456789 bytes copied in 456.789 secs (274567 bytes/sec)
```

**TFTP Download to Router:**
```
R1# copy tftp: flash: Address or name of remote host []? 192.168.1.100 Source filename []? c2900-universalk9-mz.SPA.157-3.M5.bin Destination filename [c2900-universalk9-mz.SPA.157-3.M5.bin]? Accessing tftp://192.168.1.100/c2900-universalk9-mz.SPA.157-3.M5.bin... Loading c2900-universalk9-mz.SPA.157-3.M5.bin from 192.168.1.100 (via GigabitEthernet0/0): !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! [OK - 125456789 bytes]

125456789 bytes copied in 512.345 secs (244897 bytes/sec)
```

**TFTP Limitations:**
- Maximum file size: typically 32MB (protocol limitation)
- No authentication mechanism
- No encryption
- Uses UDP (unreliable transport)
- Not suitable for modern IOS images (usually >100MB)
- Acceptable for configuration files only

**Key points:**
- Legacy protocol, simple to configure
- Insecure for production environments
- Blocked by many firewalls (UDP 69)
- Consider alternatives for large files
- Useful for emergency recovery scenarios

### FTP Configuration and Usage

**Configuring FTP Credentials on Router:**
```
R1# configure terminal R1(config)# ip ftp username ftpuser R1(config)# ip ftp password ftppass123 R1(config)# exit
```

**FTP Upload from Router:**
```
R1# copy flash:c2900-universalk9-mz.SPA.157-3.M5.bin ftp: Address or name of remote host []? 192.168.1.100 Destination filename [c2900-universalk9-mz.SPA.157-3.M5.bin]? Writing c2900-universalk9-mz.SPA.157-3.M5.bin !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 125456789 bytes copied in 234.567 secs (534891 bytes/sec)
```

**FTP Download to Router:**
```
R1# copy ftp: flash: Address or name of remote host []? 192.168.1.100 Source username [ftpuser]? Source password [ftppass123]? Source filename []? c2900-universalk9-mz.SPA.157-3.M5.bin Destination filename [c2900-universalk9-mz.SPA.157-3.M5.bin]? Accessing ftp://192.168.1.100/c2900-universalk9-mz.SPA.157-3.M5.bin... Loading c2900-universalk9-mz.SPA.157-3.M5.bin !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! [OK - 125456789 bytes]

125456789 bytes copied in 198.456 secs (632147 bytes/sec)
```

**Interactive FTP (alternative method):**
```
R1# copy ftp: flash: Address or name of remote host []? 192.168.1.100 Source username []? ftpuser Source password? ftppass123 Source filename []? c2900-universalk9-mz.SPA.157-3.M5.bin Destination filename [c2900-universalk9-mz.SPA.157-3.M5.bin]? ...
```

**FTP Passive Mode:**
```
R1# configure terminal R1(config)# ip ftp passive R1(config)# exit
```

**Key points:**
- Faster than TFTP (TCP vs UDP)
- Supports large files (no 32MB limitation)
- Uses TCP ports 20 (data) and 21 (control)
- Credentials transmitted in plaintext (security risk)
- Passive mode helps with firewall/NAT traversal
- Suitable for internal networks only

### SCP Configuration and Usage

**Prerequisites for SCP:**
- SSH must be configured and operational
- Username and password authentication required
- RSA keys generated on router

**Enabling SCP Server on Router:**
```
R1# configure terminal R1(config)# ip scp server enable R1(config)# aaa new-model R1(config)# aaa authentication login default local R1(config)# aaa authorization exec default local R1(config)# username scpuser privilege 15 secret ScpP@ss123 R1(config)# exit
```

**SCP Upload from Router:**
```
R1# copy flash:c2900-universalk9-mz.SPA.157-3.M5.bin scp: Address or name of remote host []? 192.168.1.100 Destination username []? scpuser Destination filename [c2900-universalk9-mz.SPA.157-3.M5.bin]? /backups/IOS/c2900-universalk9-mz.SPA.157-3.M5.bin Password: Sending file modes: C0644 125456789 c2900-universalk9-mz.SPA.157-3.M5.bin !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 125456789 bytes copied in 245.123 secs (511897 bytes/sec)
```

**SCP Download to Router:**
```
R1# copy scp: flash: Address or name of remote host []? 192.168.1.100 Source username []? scpuser Source filename []? /cisco-ios/c2900-universalk9-mz.SPA.157-3.M5.bin Destination filename [c2900-universalk9-mz.SPA.157-3.M5.bin]? Password: Receiving file modes: C0644 125456789 c2900-universalk9-mz.SPA.157-3.M5.bin !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! [OK - 125456789 bytes]

125456789 bytes copied in 234.789 secs (534278 bytes/sec)
```

**Specifying Full SCP URI:**
```
R1# copy scp://scpuser@192.168.1.100//cisco-ios/c2900-universalk9-mz.SPA.157-3.M5.bin flash: Password: ...
```

**Key points:**
- Most secure file transfer method (encrypted)
- Uses SSH (TCP port 22)
- Requires AAA configuration (basic or full)
- Privilege level 15 typically required for file operations
- Supports absolute paths on server
- Recommended for production environments
- Slower than FTP due to encryption overhead

### Comparison of File Transfer Protocols

| Feature | TFTP | FTP | SCP |
|---------|------|-----|-----|
| Protocol | UDP | TCP | SSH/TCP |
| Port(s) | 69 | 20, 21 | 22 |
| Authentication | None | Username/Password | SSH keys or Username/Password |
| Encryption | No | No | Yes |
| File size limit | ~32MB | Unlimited | Unlimited |
| Speed | Slow | Fast | Moderate (encryption overhead) |
| Reliability | Low (UDP) | High (TCP) | High (TCP) |
| Security | Very Low | Low | High |
| Complexity | Simple | Moderate | Complex |
| Firewall-friendly | Moderate | Low (active mode) | High |
| Production use | Emergency only | Internal networks | Recommended |

### HTTP/HTTPS File Transfers

**HTTP Download:**
```
R1# copy http://192.168.1.100/ios-images/c2900-universalk9-mz.SPA.157-3.M5.bin flash: Destination filename [c2900-universalk9-mz.SPA.157-3.M5.bin]? Accessing http://192.168.1.100/ios-images/c2900-universalk9-mz.SPA.157-3.M5.bin... Loading http://192.168.1.100/ios-images/c2900-universalk9-mz.SPA.157-3.M5.bin !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! [OK - 125456789 bytes]

125456789 bytes copied in 221.456 secs (566542 bytes/sec)
```

**HTTPS Download with Authentication:**
```
R1# configure terminal R1(config)# ip http client username httpuser R1(config)# ip http client password HttpP@ss123 R1(config)# exit

R1# copy https://192.168.1.100/ios-images/c2900-universalk9-mz.SPA.157-3.M5.bin flash:
```

**Enabling HTTP Server on Router:**
```
R1# configure terminal R1(config)# ip http server R1(config)# ip http authentication local R1(config)# ip http secure-server ! HTTPS R1(config)# ip http port 8080 ! Custom port R1(config)# exit
```

**Key points:**
- HTTP simple for downloading files
- HTTPS provides encryption
- Requires web server setup on source
- HTTP server on router enables web-based management
- Disable HTTP server if not needed (security)
- Can use basic or digest authentication
- Useful when centralized file server available

### USB File Transfers

**Checking USB Filesystem:**
```
R1# dir usbflash0: Directory of usbflash0:/
```
1  -rw-     6789  Jan 15 2025 15:30:12 +00:00  config-backup.cfg
2  -rw-   125456789  Jan 15 2025 15:45:23 +00:00  c2900-universalk9-mz.SPA.157-3.M5.bin
```
8000000000 bytes total (7874536422 bytes free)
```

**Copying to USB:**
```
R1# copy running-config usbflash0:R1-backup-20250115.cfg 6789 bytes copied in 0.234 secs (29013 bytes/sec)

R1# copy flash:c2900-universalk9-mz.SPA.157-3.M5.bin usbflash0: 125456789 bytes copied in 89.456 secs (1402456 bytes/sec)
```

**Copying from USB:**
```
R1# copy usbflash0:c2900-universalk9-mz.SPA.157-3.M5.bin flash: Destination filename [c2900-universalk9-mz.SPA.157-3.M5.bin]? 125456789 bytes copied in 92.123 secs (1361897 bytes/sec)
```

**Key points:**
- USB provides portable offline backup
- FAT32 filesystem typical (4GB file size limit per file)
- Useful for devices without network connectivity
- Insert USB while router running (hot-swappable on most platforms)
- Remove safely: no unmount required on Cisco IOS
- Verify USB recognized: `show file systems`

### File System Management

**Viewing Available File Systems:**
```
R1# show file systems File Systems:
```
   Size(b)       Free(b)      Type  Flags  Prefixes
```
- 256487424 130902144 flash rw flash0: flash:# 8000000000 7874536422 usbf rw usbflash0: - - opaque rw bs: - - opaque rw vb: 262136 257909 nvram rw nvram: - - network rw tftp: - - network rw ftp: - - network rw http: - - network rw https: - - network rw scp: - - opaque ro null: - - opaque ro tar: - - network rw rcp: - - network rw system: - - opaque wo xmodem: - - opaque wo ymodem:
```

**Changing Default Filesystem:**
```
R1# cd usbflash0: R1# pwd usbflash0:

R1# cd flash: R1# pwd flash:
```

**Key points:**
- `*` indicates current default filesystem
- `rw` = read/write, `ro` = read-only, `wo` = write-only
- `flash:` typically default on most platforms
- Network filesystems accessible via protocols
- NVRAM stores startup-config (limited size)

**Important Related Topics:**
- Configuration management systems (RANCID, Oxidized)
- Network automation for backups (Ansible, Python)
- Centralized configuration repositories (Git)
- Disaster recovery planning and testing
- Change management procedures
- Configuration compliance auditing

---

