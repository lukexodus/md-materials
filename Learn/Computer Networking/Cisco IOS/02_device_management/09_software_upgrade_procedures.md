## Software Upgrade Procedures


### Pre-Upgrade Preparation

**Verify Current IOS:**
```
R1# show version | include Software|image
Cisco IOS Software, C2900 Software (C2900-UNIVERSALK9-M), Version 15.4(3)M6
System image file is "flash0:c2900-universalk9-mz.SPA.154-3.M6.bin"
```

**Check Flash Memory:**
```
R1# show flash:
-#- --length-- -----date/time------ path
1   117835268  Jan 10 2025 10:23:45 +00:00 c2900-universalk9-mz.SPA.154-3.M6.bin
2      245678  Jan 10 2025 10:25:12 +00:00 config_backup.cfg

256487424 bytes total (138404992 bytes free)
```

**Calculate Required Space:**
```
R1# dir flash:
Directory of flash0:/

    1  -rw-   117835268  Jan 10 2025 10:23:45 +00:00  c2900-universalk9-mz.SPA.154-3.M6.bin
    2  -rw-      245678  Jan 10 2025 10:25:12 +00:00  config_backup.cfg

256487424 bytes total (138404992 bytes free)
```

**Key points:**
- Verify sufficient flash space for new image
- New image typically 100-200MB depending on platform
- Keep old image as backup if space permits
- Download release notes for new IOS version
- Check hardware/memory requirements
- Verify feature compatibility

### Downloading New IOS Image

**Copy from TFTP Server:**
```
R1# copy tftp: flash:
Address or name of remote host []? 192.168.1.100
Source filename []? c2900-universalk9-mz.SPA.157-3.M5.bin
Destination filename [c2900-universalk9-mz.SPA.157-3.M5.bin]? 
Accessing tftp://192.168.1.100/c2900-universalk9-mz.SPA.157-3.M5.bin...
Loading c2900-universalk9-mz.SPA.157-3.M5.bin from 192.168.1.100 (via GigabitEthernet0/0): !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
[OK - 125456789 bytes]

125456789 bytes copied in 245.678 secs (510789 bytes/sec)
```

**Copy from FTP Server:**
```
R1# copy ftp: flash:
Address or name of remote host []? 192.168.1.100
Source username [R1]? ftpuser
Source password? ftppass
Source filename []? c2900-universalk9-mz.SPA.157-3.M5.bin
Destination filename [c2900-universalk9-mz.SPA.157-3.M5.bin]? 
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
[OK - 125456789 bytes]
```

**Copy from SCP Server (Secure):**
```
R1# copy scp: flash:
Address or name of remote host []? 192.168.1.100
Source username []? scpuser
Source filename []? /cisco-ios/c2900-universalk9-mz.SPA.157-3.M5.bin
Destination filename [c2900-universalk9-mz.SPA.157-3.M5.bin]? 
Password: 
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
[OK - 125456789 bytes]
```

**Copy from HTTP/HTTPS:**
```
R1# copy http://192.168.1.100/ios-images/c2900-universalk9-mz.SPA.157-3.M5.bin flash:
Destination filename [c2900-universalk9-mz.SPA.157-3.M5.bin]? 
Accessing http://192.168.1.100/ios-images/c2900-universalk9-mz.SPA.157-3.M5.bin...
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
[OK - 125456789 bytes]
```

**Key points:**
- TFTP limited to files \<32MB (not suitable for modern IOS images on most platforms)
- FTP transfers faster than TFTP
- SCP recommended for security (encrypted transfer)
- HTTP/HTTPS useful when file servers available
- Monitor transfer progress (exclamation marks indicate successful segments)

### Verifying IOS Image Integrity

**MD5 Hash Verification:**
```
R1# verify /md5 flash:c2900-universalk9-mz.SPA.157-3.M5.bin
...........................................................
...........................................................
...Done!
verify /md5 (flash:c2900-universalk9-mz.SPA.157-3.M5.bin) = a1b2c3d4e5f67890a1b2c3d4e5f67890
```

Compare with MD5 hash from Cisco.com download page.

**Digital Signature Verification:**
```
R1# show software authenticity file flash:c2900-universalk9-mz.SPA.157-3.M5.bin
File Name                   : flash:c2900-universalk9-mz.SPA.157-3.M5.bin
Image type                  : Development
File Integrity              : Signature Verified
```

**Key points:**
- Always verify MD5/SHA hash before using new image
- Hash mismatch indicates corrupted download
- Digital signature verification confirms authentic Cisco image
- Re-download if verification fails

### Configuring Boot System

**Setting Boot System Variable:**
```
R1# configure terminal
R1(config)# boot system flash:c2900-universalk9-mz.SPA.157-3.M5.bin
R1(config)# boot system flash:c2900-universalk9-mz.SPA.154-3.M6.bin
R1(config)# end
R1# copy running-config startup-config
```

**Verification:**
```
R1# show running-config | include boot
boot-start-marker
boot system flash:c2900-universalk9-mz.SPA.157-3.M5.bin
boot system flash:c2900-universalk9-mz.SPA.154-3.M6.bin
boot-end-marker
```

**Key points:**
- Multiple boot system commands create fallback chain
- Router attempts boot in order configured
- First successful boot stops process
- If all fail, router boots from ROMMON
- Always save configuration before reload

### Performing the Upgrade

**Reload with Configuration Save Prompt:**
```
R1# reload
System configuration has been modified. Save? [yes/no]: yes
Building configuration...
[OK]
Proceed with reload? [confirm]

*Jan 15 14:45:12.345: %SYS-5-RELOAD: Reload requested by admin on console.
...
(Router reboots)
...
```

**Scheduled Reload:**
```
R1# reload in 10
Reload scheduled in 10 minutes by admin on console
Reload reason: Planned IOS upgrade

R1# reload cancel                                 ! Cancel scheduled reload
```

**Reload at Specific Time:**
```
R1# reload at 02:00 15 Jan
Reload scheduled for 02:00:00 PST Mon Jan 15 2025 (in 11 hours and 14 minutes) by admin on console
```

**Key points:**
- Schedule reloads during maintenance windows
- Notify users of planned downtime
- Monitor reload process via console connection
- Have rollback plan ready
- Test new IOS in lab environment first

### Post-Upgrade Verification

**Verify New IOS Version:**
```
R1# show version
Cisco IOS Software, C2900 Software (C2900-UNIVERSALK9-M), Version 15.7(3)M5
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2018 by Cisco Systems, Inc.
Compiled Wed 01-Aug-18 12:34 by prod_rel_team

ROM: System Bootstrap, Version 15.0(1r)M16, RELEASE SOFTWARE (fc1)

R1 uptime is 5 minutes
System returned to ROM by reload at 14:45:23 PST Mon Jan 15 2025
System image file is "flash0:c2900-universalk9-mz.SPA.157-3.M5.bin"
Last reload type: Normal Reload
Last reload reason: Reload Command
...
```

**Verify Configuration Retained:**
```
R1# show running-config
...

R1# show startup-config
...
```

**Verify Interfaces:**
```
R1# show ip interface brief
Interface                  IP-Address      OK? Method Status                Protocol
GigabitEthernet0/0         192.168.1.1     YES NVRAM  up                    up      
GigabitEthernet0/1         10.1.1.1        YES NVRAM  up                    up      
Loopback0                  1.1.1.1         YES NVRAM  up
up
```

**Verify Routing:**
```
R1# show ip route Codes: L - local, C - connected, S - static, R - RIP, M - mobile, B - BGP D - EIGRP, EX - EIGRP external, O - OSPF, IA - OSPF inter area N1 - OSPF NSSA external type 1, N2 - OSPF NSSA external type 2 E1 - OSPF external type 1, E2 - OSPF external type 2 i - IS-IS, su - IS-IS summary, L1 - IS-IS level-1, L2 - IS-IS level-2 ia - IS-IS inter area, * - candidate default, U - per-user static route o - ODR, P - periodic downloaded static route, H - NHRP, l - LISP a - application route + - replicated route, % - next hop override, p - overrides from PfR

Gateway of last resort is 192.168.1.254 to network 0.0.0.0

S* 0.0.0.0/0 [1/0] via 192.168.1.254 1.0.0.0/32 is subnetted, 1 subnets C 1.1.1.1 is directly connected, Loopback0 10.0.0.0/8 is variably subnetted, 2 subnets, 2 masks C 10.1.1.0/24 is directly connected, GigabitEthernet0/1 L 10.1.1.1/32 is directly connected, GigabitEthernet0/1 192.168.1.0/24 is variably subnetted, 2 subnets, 2 masks C 192.168.1.0/24 is directly connected, GigabitEthernet0/0 L 192.168.1.1/32 is directly connected, GigabitEthernet0/0

```

**Verify Routing Protocols:**
```

R1# show ip protocols *** IP Routing is NSF aware ***

Routing Protocol is "ospf 1" Outgoing update filter list for all interfaces is not set Incoming update filter list for all interfaces is not set Router ID 1.1.1.1 Number of areas in this router is 1. 1 normal 0 stub 0 nssa Maximum path: 4 Routing for Networks: 192.168.1.0 0.0.0.255 area 0 10.1.1.0 0.0.0.255 area 0 Routing Information Sources: Gateway Distance Last Update 2.2.2.2 110 00:03:45 3.3.3.3 110 00:03:45 Distance: (default is 110)

```

**Verify Key Services:**
```

R1# show ntp status Clock is synchronized, stratum 3, reference is 192.168.1.200

R1# show cdp neighbors Device ID Local Intrfce Holdtme Capability Platform Port ID SW1 Gig 0/0 165 S I WS-C2960 Gig 0/1 R2 Gig 0/1 155 R S I ISR4321 Gig 0/0

R1# show users Line User Host(s) Idle Location

- 0 con 0 admin idle 00:00:00  
    194 vty 0 netadmin idle 00:05:23 192.168.1.50

Interface User Mode Idle Peer Address

```

**Key points:**
- Verify all critical features operational
- Check interface status and IP connectivity
- Confirm routing protocols converged
- Test SSH/Telnet access
- Verify NTP synchronization
- Check system logs for errors
- Validate license status if applicable

### Rollback Procedures

**If upgrade fails or issues discovered:**

**Method 1: Change boot system priority:**
```

R1# configure terminal R1(config)# no boot system flash:c2900-universalk9-mz.SPA.157-3.M5.bin R1(config)# end R1# copy running-config startup-config R1# reload

```

**Method 2: Boot from ROMMON:**
```

rommon 1 > boot flash:c2900-universalk9-mz.SPA.154-3.M6.bin

```

**Method 3: TFTP boot from ROMMON:**
```

rommon 1 > IP_ADDRESS=192.168.1.1 rommon 2 > IP_SUBNET_MASK=255.255.255.0 rommon 3 > DEFAULT_GATEWAY=192.168.1.254 rommon 4 > TFTP_SERVER=192.168.1.100 rommon 5 > TFTP_FILE=c2900-universalk9-mz.SPA.154-3.M6.bin rommon 6 > tftpdnld rommon 7 > boot

```

**Key points:**
- Always maintain previous working IOS image
- Document rollback procedures before upgrade
- Test rollback in lab if possible
- Keep console access available during upgrade
- Have TFTP server ready with known-good image

### Deleting Old IOS Images

**After successful upgrade and testing:**
```

R1# delete flash:c2900-universalk9-mz.SPA.154-3.M6.bin Delete filename [c2900-universalk9-mz.SPA.154-3.M6.bin]? Delete flash:c2900-universalk9-mz.SPA.154-3.M6.bin? [confirm]

```

**Squeeze Flash (recover deleted space):**
```

R1# squeeze flash: All deleted files will be removed. Continue? [confirm] Squeezing flash filesys (erasing sector blocks) ... !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

```

**Key points:**
- Wait at least 24-48 hours before deleting old image
- Ensure new image stable in production
- Keep old image if flash space permits
- `delete` marks file for deletion but doesn't reclaim space
- `squeeze` permanently removes deleted files and reclaims space
- `squeeze` operation can take several minutes

