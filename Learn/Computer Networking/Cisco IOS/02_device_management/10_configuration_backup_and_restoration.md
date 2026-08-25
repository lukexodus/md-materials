## Configuration Backup and Restoration


### Local Configuration Backup

**Copying Configuration to Flash:**
```

R1# copy running-config flash:config-backup-20250115.cfg Destination filename [config-backup-20250115.cfg]? 6789 bytes copied in 0.234 secs (29013 bytes/sec)

R1# dir flash: Directory of flash0:/

```
1  -rw-   125456789  Jan 15 2025 14:45:23 +00:00  c2900-universalk9-mz.SPA.157-3.M5.bin
2  -rw-        6789  Jan 15 2025 15:12:45 +00:00  config-backup-20250115.cfg
```

256487424 bytes total (130902144 bytes free)

```

**Copying Startup-Config to Flash:**
```

R1# copy startup-config flash:startup-backup.cfg Destination filename [startup-backup.cfg]? 6789 bytes copied in 0.189 secs (35942 bytes/sec)

```

**Key points:**
- Use descriptive filenames with dates
- Running-config contains current active configuration
- Startup-config used after reload
- Configurations typically small (few KB to few MB)
- Regular backups essential for disaster recovery

### Remote Configuration Backup

**Backup to TFTP Server:**
```

R1# copy running-config tftp: Address or name of remote host []? 192.168.1.100 Destination filename [r1-confg]? R1-running-config-20250115.cfg !! 6789 bytes copied in 0.456 secs (14889 bytes/sec)

```

**Backup to FTP Server:**
```

R1# copy running-config ftp: Address or name of remote host []? 192.168.1.100 Destination username [R1]? ftpuser Destination password? ftppass Destination filename [r1-confg]? R1-running-config-20250115.cfg ! 6789 bytes copied in 0.334 secs (20327 bytes/sec)

```

**Backup to SCP Server:**
```

R1# copy running-config scp: Address or name of remote host []? 192.168.1.100 Destination username []? scpuser Destination filename [r1-confg]? /backups/R1-running-config-20250115.cfg Password: ! 6789 bytes copied in 0.412 secs (16478 bytes/sec)

```

**Backup to USB:**
```

R1# copy running-config usbflash0:R1-backup-20250115.cfg 6789 bytes copied in 0.156 secs (43519 bytes/sec)

```

**Key points:**
- TFTP simple but insecure
- FTP faster than TFTP, but credentials in plaintext
- SCP recommended (encrypted transfer)
- USB backup useful for offline storage
- Automate backups for production networks

### Automated Configuration Backup

**Using Archive Configuration:**
```

R1# configure terminal R1(config)# archive R1(config-archive)# path tftp://192.168.1.100/configs/$h-$t R1(config-archive)# time-period 1440 R1(config-archive)# write-memory R1(config-archive)# exit

```

**Manual Archive Save:**
```

R1# archive config

```

**Variables in archive path:**
- `$h` = hostname
- `$t` = timestamp (YYYYMMDD-HHMMSS)

**Example resulting filename:**
```

R1-20250115-151245-1 R1-20250115-163012-2 R1-20250116-091523-3

```

**Key points:**
- `time-period` in minutes (1440 = 24 hours)
- `write-memory` triggers backup on configuration save
- Sequential number appended to filename
- Automatic backup reduces human error
- Configure on all production devices

### Configuration Restoration

**Restoring from Flash:**
```

R1# copy flash:config-backup-20250115.cfg running-config Destination filename [running-config]? 6789 bytes copied in 0.123 secs (55195 bytes/sec)

```

**Restoring from TFTP:**
```

R1# copy tftp: running-config Address or name of remote host []? 192.168.1.100 Source filename []? R1-running-config-20250115.cfg Destination filename [running-config]? Accessing tftp://192.168.1.100/R1-running-config-20250115.cfg... Loading R1-running-config-20250115.cfg from 192.168.1.100 (via GigabitEthernet0/0): ! [OK - 6789 bytes]

6789 bytes copied in 1.234 secs (5501 bytes/sec)

```

**Restoring Startup-Config:**
```

R1# copy tftp: startup-config Address or name of remote host []? 192.168.1.100 Source filename []? R1-startup-config-20250115.cfg Destination filename [startup-config]? ! [OK - 6789 bytes]

6789 bytes copied in 1.123 secs (6047 bytes/sec) R1# reload

```

**Key points:**
- Restoring to running-config applies immediately
- Restoring to startup-config requires reload
- Merge operation: new config added to existing
- Lines in backup override conflicting lines in running-config
- To completely replace: `write erase` then restore

### Configuration Replace

**Complete Configuration Replacement:**
```

R1# configure replace flash:config-backup-20250115.cfg This will apply all necessary additions and deletions to replace the current running configuration with the contents of the specified configuration file, which is assumed to be a complete configuration, not a partial configuration. Enter Y if you are sure you want to proceed. ? [no]: yes

Total number of passes: 1 Rollback Done

```

**Configuration Replace with Rollback:**
```

R1# configure replace flash:config-backup-20250115.cfg force time 5

```

**Key points:**
- `configure replace` removes lines not in backup file
- `force` bypasses confirmation prompt
- `time` value enables automatic rollback if connection lost
- Safer than manual copy for complete restoration
- Requires IOS 12.3(7)T or later

### Archive Compare and Rollback

**Viewing Archive History:**
```

R1# show archive The maximum archive configurations allowed is 14. The next archive file will be named flash:archive-config-1 Archive # Name 1 flash:archive-config-1 2 flash:archive-config-2 3 flash:archive-config-3 <- Most Recent 4  
5  
...

```

**Comparing Configurations:**
```

R1# show archive config differences flash:archive-config-2 flash:archive-config-3 Contextual Config Diffs: +no ip http server +interface GigabitEthernet0/1 +description Link to R2 +ip address 10.1.1.1 255.255.255.0

```

**Rolling Back Configuration:**
```

R1# configure revert now Loading configuration from flash:archive-config-2

R1# configure revert timer 5 Loading configuration from flash:archive-config-2 The configuration will be reverted in 5 minutes unless confirmed. R1# configure confirm ! Confirm to keep changes

```

**Key points:**
- Rollback restores previous configuration version
- `timer` provides automatic revert (safety mechanism)
- `confirm` cancels automatic revert
- Useful for risky configuration changes
- Always test in lab before production use

### Configuration Templates

**Creating Configuration Template:**
```

R1# show running-config | redirect flash:template-base-router.cfg

R1# more flash:template-base-router.cfg ! ! Last configuration change at 15:45:23 PST Mon Jan 15 2025 ! version 15.7 service timestamps debug datetime msec localtime show-timezone service timestamps log datetime msec localtime show-timezone service password-encryption service sequence-numbers ! hostname TEMPLATE ! ...

```

**Using Template for New Device:**
```

NewRouter# copy tftp: running-config Address or name of remote host []? 192.168.1.100 Source filename []? template-base-router.cfg Destination filename [running-config]? ! [OK - 8456 bytes]

NewRouter# configure terminal NewRouter(config)# hostname R3 R3(config)# interface gigabitEthernet 0/0 R3(config-if)# ip address 192.168.3.1 255.255.255.0 R3(config-if)# no shutdown ...

```

**Key points:**
- Templates ensure consistent baseline configuration
- Remove device-specific parameters (hostname, IP addresses, keys)
- Version control templates like code
- Customize template after applying
- Reduces configuration errors and deployment time

