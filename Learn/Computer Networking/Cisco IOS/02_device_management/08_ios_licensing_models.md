## IOS Licensing Models


### License Types

Cisco IOS uses different licensing models depending on platform and IOS version.

**Traditional IOS (Pre-15.0):**
- Feature sets bundled into IOS images
- IP Base, IP Services, Advanced Security, etc.
- License embedded in IOS image filename

**IOS 15.0+ Universal Image:**
- Single universal image contains all features
- Software activation via license keys
- Right-To-Use (RTU) licensing

**IOS-XE:**
- Smart Licensing (cloud-based)
- Traditional license files
- Evaluation mode available

### License Levels (ISR G2 Example)

**Technology Packages:**
- IP Base: Basic routing and switching
- Security: Firewall, VPN, IPS features
- Unified Communications: Voice features
- Data: Advanced routing protocols (EIGRP, OSPF, BGP)

**Example tiers:**
```
ipbasek9      - IP Base with crypto
securityk9    - Security features
datak9        - Data features  
uck9          - Unified Communications
```

### Viewing License Information

**Show License:**
```
R1# show license
Index 1 Feature: ipbasek9
        Period left: Life time
        License Type: Permanent
        License State: Active, In Use
        License Count: Non-Counted
        License Priority: Medium

Index 2 Feature: securityk9
        Period left: 8 weeks 4 days
        Period Used: 0 minute 0 second
        License Type: EvalRightToUse
        License State: Active, In Use
        License Count: Non-Counted
        License Priority: None

Index 3 Feature: datak9
        Period left: Not Activated
        Period Used: 0 minute 0 second
        License Type: EvalRightToUse
        License State: Not in Use, EULA not accepted
        License Count: Non-Counted
        License Priority: None
```

**Show License UDI (Unique Device Identifier):**
```
R1# show license udi
Device#   PID                   SN              UDI
------------------------------------------------------------------
*0        CISCO2901/K9          FTX152400KS     CISCO2901/K9:FTX152400KS
```

**Show Version (includes license info):**
```
R1# show version
Cisco IOS Software, C2900 Software (C2900-UNIVERSALK9-M), Version 15.4(3)M6
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2016 by Cisco Systems, Inc.
Compiled Fri 17-Jun-16 10:08 by prod_rel_team

ROM: System Bootstrap, Version 15.0(1r)M16, RELEASE SOFTWARE (fc1)

R1 uptime is 2 days, 4 hours, 23 minutes
System returned to ROM by reload at 12:34:56 PST Mon Jan 13 2025
System image file is "flash0:c2900-universalk9-mz.SPA.154-3.M6.bin"
Last reload type: Normal Reload
Last reload reason: Reload Command

...

Technology Package License Information for Module:'c2900' 

-----------------------------------------------------------------
Technology    Technology-package           Technology-package
              Current       Type           Next reboot  
------------------------------------------------------------------
ipbase        ipbasek9      Permanent      ipbasek9
security      None          None           None
uc            None          None           None
data          None          None           None

Configuration register is 0x2102
```

**Show License Feature:**
```
R1# show license feature
Feature name             Enforcement  Evaluation  Subscription   Enabled  RightToUse
ipbasek9                 yes          no          no             yes      no
securityk9               yes          yes         no             yes      yes
uck9                     yes          yes         no             no       yes
datak9                   yes          yes         no             no       yes
```

### Installing Licenses

**Installing Permanent License:**
```
R1# license install flash0:FTX152400KS_201501151423.lic
Installing licenses from "flash0:FTX152400KS_201501151423.lic"
Installing...Feature:datak9...Successful:Supported
1/1 licenses were successfully installed
0/1 licenses were existing licenses
0/1 licenses were failed to install
```

**Accepting EULA and Activating Evaluation License:**
```
R1# configure terminal
R1(config)# license accept end user agreement
R1(config)# license boot module c2900 technology-package securityk9
R1(config)# exit
R1# reload
```

**Key points:**
- License files named: `PID_SN_yyyymmddhhmmss.lic`
- Permanent licenses survive reload
- Evaluation licenses expire after 60 days
- Reload required to activate some licenses
- License stored in flash, not in configuration

### Backing Up Licenses

**Saving License to Flash:**
```
R1# license save flash0:all_licenses.lic
License data saved to flash0:all_licenses.lic
```

**Transferring License:**
```
R1# copy flash0:all_licenses.lic tftp:
Address or name of remote host []? 192.168.1.100
Destination filename [all_licenses.lic]? R1_licenses_backup.lic
!
2345 bytes copied in 0.523 secs (4485 bytes/sec)
```

### Removing Licenses

**Clearing License:**
```
R1# license clear securityk9
Clear license feature securityk9? [yes/no]: yes
R1# reload
```

**Disabling License:**
```
R1(config)# no license boot module c2900 technology-package securityk9
R1(config)# exit
R1# reload
```

**Key points:**
- `license clear` removes license from license storage
- `no license boot` prevents license activation at boot
- Reload required for changes to take effect
- Clearing license doesn't delete license file from flash

### Smart Licensing (Modern Platforms)

**Smart Licensing Overview:**
- Cloud-based licensing management
- Centralized through Cisco Smart Software Manager (CSSM)
- No license files required
- Automatic license tracking and reporting

**Smart Licensing Configuration:**
```
R1# configure terminal
R1(config)# license smart enable
R1(config)# license smart url https://smartreceiver.cisco.com/licservice/license
R1(config)# license smart transport smart
```

**Registering Device:**
```
R1# license smart register idtoken \<TOKEN>
*Jan 15 14:35:23.456: %SMART_LIC-6-AGENT_ENABLED: Smart Agent for Licensing is enabled
*Jan 15 14:35:45.789: %SMART_LIC-6-AUTHORIZATION_INSTALL_SUCCESS
```

**Verification:**
```
R1# show license summary
Smart Licensing is ENABLED

Registration:
  Status: REGISTERED
  Smart Account: Example Corp
  Virtual Account: Network Infrastructure
  Export-Controlled Functionality: Allowed
  Initial Registration: SUCCEEDED on Jan 15 14:35:45 2025 PST
  Last Renewal Attempt: None
  Next Renewal Attempt: Jul 14 14:35:45 2025 PST

License Authorization:
  Status: AUTHORIZED on Jan 15 14:35:46 2025 PST
  Last Communication Attempt: SUCCEEDED on Jan 15 14:35:46 2025 PST
  Next Communication Attempt: Jan 16 14:35:46 2025 PST

License Usage:
  License                 Entitlement tag               Count Status
  -----------------------------------------------------------------------------
  network-advantage       (C9300_NW_Advantage)          1     IN USE
  dna-advantage           (C9300_DNA_Advantage)         1     IN USE
```

**Key points:**
- Token generated from Cisco Smart Software Manager portal
- Device communicates with CSSM periodically
- Can operate in disconnected mode for up to 90 days
- Supports satellite/on-premise licensing for air-gapped networks

