## VLAN Configuration and Assignment


Virtual LANs (VLANs) logically segment a physical network into separate broadcast domains, improving security, performance, and management flexibility. Each VLAN operates as if it were a separate physical LAN.

**VLAN Ranges:**

- **Normal Range VLANs (1-1005)**: Stored in vlan.dat file in flash memory, can be configured in global configuration mode, supports VTP
- **Extended Range VLANs (1006-4094)**: Stored only in running configuration, requires VTP transparent mode, not all features supported on all platforms
- **Reserved VLANs**: VLAN 1 (default), 1002-1005 (Token Ring and FDDI defaults)

**Creating VLANs:**

```
Switch(config)# vlan 10
Switch(config-vlan)# name SALES
Switch(config-vlan)# exit

Switch(config)# vlan 20
Switch(config-vlan)# name ENGINEERING
Switch(config-vlan)# exit

Switch(config)# vlan 30
Switch(config-vlan)# name MANAGEMENT
```

**Assigning Ports to VLANs:**

```
Switch(config)# interface gigabitethernet 0/1
Switch(config-if)# switchport mode access
Switch(config-if)# switchport access vlan 10

! Range assignment
Switch(config)# interface range gigabitethernet 0/2-10
Switch(config-if-range)# switchport mode access
Switch(config-if-range)# switchport access vlan 20
```

**VLAN 1 Considerations:** VLAN 1 is the default VLAN for all ports and cannot be deleted. It carries control plane traffic like CDP, VTP, PAgP, DTP, and STP BPDUs. Best practice is to avoid using VLAN 1 for user data and configure an alternative native VLAN on trunks.

**Voice VLANs:** Cisco IP phones can use dual VLANs - one for voice traffic and one for data from connected PCs:

```
Switch(config-if)# switchport mode access
Switch(config-if)# switchport access vlan 10
Switch(config-if)# switchport voice vlan 50
```

The phone tags voice traffic with VLAN 50 while passing data traffic untagged in VLAN 10.

**Deleting VLANs:**

```
Switch(config)# no vlan 10

! Delete entire VLAN database
Switch# delete flash:vlan.dat
Switch# reload
```

**Verification Commands:**

```
Switch# show vlan brief
Switch# show vlan id [vlan-id]
Switch# show vlan name [vlan-name]
Switch# show interfaces [interface-id] switchport
Switch# show running-config
```

