## PortFast and BPDU Guard


PortFast and BPDU Guard are complementary features that optimize STP behavior for end-device connections while maintaining network security.

**PortFast Operation**

PortFast (called "Edge Port" in RSTP terminology) instructs a switch port to immediately transition to forwarding state when connected, bypassing listening and learning states. This eliminates the 30-second delay that would otherwise occur when an end device (workstation, printer, server) connects to the network.

**When to Use PortFast**

PortFast should be enabled only on access ports connecting to end devices:

- Workstations and laptops
- Printers and copiers
- IP phones
- Servers (single-attached)
- Access points
- Cameras and IoT devices

**When NOT to Use PortFast**

Never enable PortFast on:

- Trunk ports between switches
- Ports connecting to other switches
- Ports connecting to hubs
- Any port that could receive BPDUs from another switch

Enabling PortFast on inter-switch connections can create temporary loops during topology changes, potentially causing network outages.

**PortFast Configuration**

```
! Enable PortFast on specific interface
interface gigabitethernet1/0/5
 switchport mode access
 spanning-tree portfast
 
! Enable PortFast on all access ports globally
spanning-tree portfast default

! Disable PortFast on specific interface (if globally enabled)
interface gigabitethernet1/0/23
 spanning-tree portfast disable
```

When enabling PortFast, the switch displays a warning:

```
%Warning: portfast should only be enabled on ports connected to a single
host. Connecting hubs, concentrators, switches, bridges, etc... to this
interface when portfast is enabled, can cause temporary bridging loops.
Use with CAUTION
```

**PortFast Behavior**

- Port immediately enters forwarding state when link comes up
- If BPDU is received, PortFast is automatically disabled on that port
- Port enters normal STP operation if BPDUs detected
- TCN (Topology Change Notification) is not generated when PortFast port goes up/down (reduces unnecessary MAC table flushes)

**BPDU Guard Operation**

BPDU Guard provides security by shutting down ports if BPDUs are received. This prevents unauthorized switches from connecting to the network and potentially disrupting the spanning tree topology or creating loops.

**BPDU Guard Use Cases**

- Enforce policy that end-user ports never connect to switches
- Prevent rogue switches from being introduced to the network
- Protect against malicious attacks attempting to manipulate spanning tree
- Detect misconfigured ports (PortFast enabled on uplink ports)
- Meet security compliance requirements

**BPDU Guard Configuration**

```
! Enable BPDU Guard on specific interface
interface gigabitethernet1/0/5
 spanning-tree portfast
 spanning-tree bpduguard enable

! Enable BPDU Guard globally on all PortFast ports
spanning-tree portfast bpduguard default
```

The global configuration automatically applies BPDU Guard to all interfaces with PortFast enabled (either explicitly or via `portfast default`).

**BPDU Guard Behavior**

When BPDU Guard is enabled and a BPDU is received:

1. Port is immediately placed in err-disabled state
2. Syslog message is generated indicating BPDU Guard violation
3. Port LED typically turns amber/orange
4. Port remains disabled until manually recovered or auto-recovery is configured

**Recovery from err-disabled**

```
! Manual recovery
interface gigabitethernet1/0/5
 shutdown
 no shutdown

! Configure automatic recovery (global configuration)
errdisable recovery cause bpduguard
errdisable recovery interval 300

! Verify err-disabled status
show interfaces status err-disabled
show errdisable recovery
```

Auto-recovery automatically brings the port back up after the configured interval (300 seconds = 5 minutes). This is useful in environments where temporary misconnections occur, though manual recovery provides better security oversight.

**Verification**

```
! Verify PortFast configuration
show running-config interface gigabitethernet1/0/5

interface GigabitEthernet1/0/5
 switchport mode access
 spanning-tree portfast
 spanning-tree bpduguard enable

! Check spanning-tree interface details
show spanning-tree interface gi1/0/5 detail

Port 5 (GigabitEthernet1/0/5) of VLAN0010 is designated forwarding
  Port path cost 4, Port priority 128, Port Identifier 128.5
  Designated root has priority 24586, address 0023.04ee.be01
  Designated bridge has priority 32778, address f8b7.e203.5b00
  Designated port id is 128.5, designated path cost 4
  Timers: message age 0, forward delay 0, hold 0
  Number of transitions to forwarding state: 1
  Link type is point-to-point by default
  Bpdu guard is enabled
  BPDU: sent 245, received 0

! View err-disabled interfaces
show interfaces status err-disabled

Port      Name               Status       Reason               Err-disabled Vlans
Gi1/0/8                      err-disabled bpduguard
```

**Best Practice Configuration Template**

```
! Global configuration for all access ports
spanning-tree portfast default
spanning-tree portfast bpduguard default

! Enable auto-recovery with notification monitoring
errdisable recovery cause bpduguard
errdisable recovery interval 300

! Configure specific access port
interface range gigabitethernet1/0/1-48
 switchport mode access
 switchport access vlan 10
 ! PortFast and BPDU Guard applied via global defaults
 
! Explicitly disable on uplinks
interface range gigabitethernet1/0/49-52
 switchport mode trunk
 spanning-tree portfast disable
 spanning-tree bpduguard disable
```

**Additional Guard Features**

**Root Guard** Prevents external switches from becoming root bridge. If superior BPDUs are received, the port enters root-inconsistent state.

```
interface gigabitethernet1/0/23
 spanning-tree guard root
```

**Loop Guard** Prevents alternate or root ports from becoming designated ports due to unidirectional link failure.

```
interface gigabitethernet1/0/23
 spanning-tree guard loop
```

