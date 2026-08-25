## CDP (Cisco Discovery Protocol) and LLDP


### Cisco Discovery Protocol (CDP)

CDP is a Cisco proprietary Layer 2 protocol for discovering directly connected Cisco devices.

**CDP Global Configuration:**

```
R1(config)# cdp run                    ! Enable CDP globally
R1(config)# cdp timer 60               ! Advertisement interval (default: 60 seconds)
R1(config)# cdp holdtime 180           ! Hold time (default: 180 seconds)
R1(config)# cdp advertise-v2           ! Enable CDPv2
```

**CDP Interface Configuration:**

```
R1(config)# interface gigabitEthernet 0/0
R1(config-if)# cdp enable              ! Enable CDP on interface
R1(config-if)# no cdp enable           ! Disable CDP on interface
```

**CDP Verification Commands:**

```
R1# show cdp
Global CDP information:
    Sending CDP packets every 60 seconds
    Sending a holdtime value of 180 seconds
    Sending CDPv2 advertisements is enabled

R1# show cdp neighbors
Capability Codes: R - Router, T - Trans Bridge, B - Source Route Bridge
                  S - Switch, H - Host, I - IGMP, r - Repeater, P - Phone,
                  D - Remote, C - CVTA, M - Two-port Mac Relay

Device ID        Local Intrfce     Holdtme    Capability  Platform  Port ID
SW1              Gig 0/0           165        S I         WS-C2960  Gig 0/1
R2               Gig 0/1           155        R S I       ISR4321   Gig 0/0

Total cdp entries displayed : 2

R1# show cdp neighbors detail
-------------------------
Device ID: SW1
Entry address(es): 
  IP address: 192.168.1.10
Platform: cisco WS-C2960-24TT-L,  Capabilities: Switch IGMP 
Interface: GigabitEthernet0/0,  Port ID (outgoing port): GigabitEthernet0/1
Holdtime : 165 sec

Version :
Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(2)SE11
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2018 by Cisco Systems, Inc.

advertisement version: 2
Protocol Hello:  OUI=0x00000C, Protocol ID=0x0112; payload len=27
VTP Management Domain: ''
Native VLAN: 1
Duplex: full
Management address(es): 
  IP address: 192.168.1.10

-------------------------
Device ID: R2
Entry address(es): 
  IP address: 10.1.1.2
Platform: Cisco ISR4321/K9,  Capabilities: Router Switch IGMP 
Interface: GigabitEthernet0/1,  Port ID (outgoing port): GigabitEthernet0/0
Holdtime : 155 sec

Version :
Cisco IOS Software [Fuji], ISR Software (X86_64_LINUX_IOSD-UNIVERSALK9-M)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2018 by Cisco Systems, Inc.

advertisement version: 2
VTP Management Domain: ''
Duplex: full
Management address(es): 
  IP address: 10.1.1.2

Total cdp entries displayed : 2

R1# show cdp entry R2
-------------------------
Device ID: R2
Entry address(es): 
  IP address: 10.1.1.2
Platform: Cisco ISR4321/K9,  Capabilities: Router Switch IGMP 
Interface: GigabitEthernet0/1,  Port ID (outgoing port): GigabitEthernet0/0
Holdtime : 150 sec
...

R1# show cdp interface
GigabitEthernet0/0 is up, line protocol is up
  Encapsulation ARPA
  Sending CDP packets every 60 seconds
  Holdtime is 180 seconds
GigabitEthernet0/1 is up, line protocol is up
  Encapsulation ARPA
  Sending CDP packets every 60 seconds
  Holdtime is 180 seconds

R1# show cdp traffic
CDP counters :
    Total packets output: 245, Input: 198
    Hdr syntax: 0, Chksum error: 0, Encaps failed: 0
    No memory: 0, Invalid packet: 0, 
    CDP version 1 advertisements output: 0, Input: 0
    CDP version 2 advertisements output: 245, Input: 198
```

**Clearing CDP Table:**

```
R1# clear cdp table
R1# clear cdp counters
```

**Key points:**

- Operates at Layer 2 (data link layer)
- Multicast address: 0100.0CCC.CCCC
- Discovers only directly connected Cisco devices
- Transmits device type, IOS version, IP addresses, platform
- Security risk: reveals network topology information
- Should be disabled on interfaces facing untrusted networks
- CDPv2 adds additional information (Native VLAN, duplex)

**Security Best Practice:**

```
R1(config)# no cdp run                                    ! Disable globally
! OR
R1(config)# interface range gigabitEthernet 0/0 - 1
R1(config-if-range)# no cdp enable                        ! Disable per interface
```

### Link Layer Discovery Protocol (LLDP)

LLDP is an IEEE 802.1AB standard protocol for vendor-neutral device discovery.

**LLDP Global Configuration:**

```
R1(config)# lldp run                              ! Enable LLDP globally
R1(config)# lldp timer 30                         ! Advertisement interval (default: 30 seconds)
R1(config)# lldp holdtime 120                     ! Hold time (default: 120 seconds)
R1(config)# lldp reinit 2                         ! Delay before re-init (default: 2 seconds)
```

**LLDP Interface Configuration:**

```
R1(config)# interface gigabitEthernet 0/0
R1(config-if)# lldp transmit                      ! Enable LLDP transmission
R1(config-if)# lldp receive                       ! Enable LLDP reception
R1(config-if)# no lldp transmit                   ! Disable transmission
R1(config-if)# no lldp receive                    ! Disable reception
```

**LLDP Verification Commands:**

```
R1# show lldp
Global LLDP Information:
    Status: ACTIVE
    LLDP advertisements are sent every 30 seconds
    LLDP hold time advertised is 120 seconds
    LLDP interface reinitialisation delay is 2 seconds

R1# show lldp neighbors
Capability codes:
    (R) Router, (B) Bridge, (T) Telephone, (C) DOCSIS Cable Device
    (W) WLAN Access Point, (P) Repeater, (S) Station, (O) Other

Device ID           Local Intf     Hold-time  Capability      Port ID
SW1                 Gi0/0          120        B               Gi0/1
R2                  Gi0/1          120        R               Gi0/0

Total entries displayed: 2

R1# show lldp neighbors detail
------------------------------------------------
Chassis id: aabb.cc00.1000
Port id: Gi0/1
Port Description: GigabitEthernet0/1
System Name: SW1

System Description: 
Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(2)SE11
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2018 by Cisco Systems, Inc.

Time remaining: 115 seconds
System Capabilities: B
Enabled Capabilities: B
Management Addresses:
    IP: 192.168.1.10
Auto Negotiation - supported, enabled
Physical media capabilities:
    1000baseT(FD)
    100base-TX(FD)
    100base-TX(HD)
    10base-T(FD)
    10base-T(HD)
Media Attachment Unit type: 30
Vlan ID: 1

------------------------------------------------
Chassis id: aabb.cc00.2000
Port id: Gi0/0
Port Description: GigabitEthernet0/0
System Name: R2

System Description: 
Cisco IOS Software [Fuji], ISR Software (X86_64_LINUX_IOSD-UNIVERSALK9-M)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2018 by Cisco Systems, Inc.

Time remaining: 110 seconds
System Capabilities: R
Enabled Capabilities: R
Management Addresses:
    IP: 10.1.1.2
Auto Negotiation - supported, enabled
Physical media capabilities:
    1000baseT(FD)
Media Attachment Unit type: 30

Total entries displayed: 2

R1# show lldp entry R2
------------------------------------------------
Chassis id: aabb.cc00.2000
Port id: Gi0/0
Port Description: GigabitEthernet0/0
System Name: R2
...

R1# show lldp interface
GigabitEthernet0/0:
    Tx: enabled
    Rx: enabled
    Tx state: IDLE
    Rx state: WAIT FOR FRAME

GigabitEthernet0/1:
    Tx: enabled
    Rx: enabled
    Tx state: IDLE
    Rx state: WAIT FOR FRAME

R1# show lldp traffic
LLDP traffic statistics:
    Total frames out: 312
    Total entries aged: 0
    Total frames in: 245
    Total frames received in error: 0
    Total frames discarded: 0
    Total TLVs discarded: 0
    Total TLVs unrecognized: 0
```

**Key points:**

- IEEE 802.1AB standard (vendor-neutral)
- Multicast address: 0180.C200.000E
- Discovers multi-vendor network devices
- More widely supported than CDP in heterogeneous environments
- Transmits system name, description, capabilities, management address
- Can coexist with CDP
- Should be disabled on untrusted interfaces
- Separate transmit/receive control per interface

### CDP vs LLDP Comparison

|Feature|CDP|LLDP|
|---|---|---|
|Standard|Cisco proprietary|IEEE 802.1AB|
|Vendor support|Cisco only|Multi-vendor|
|Default interval|60 seconds|30 seconds|
|Default holdtime|180 seconds|120 seconds|
|Multicast MAC|0100.0CCC.CCCC|0180.C200.000E|
|Default state|Enabled (on Cisco)|Disabled|

