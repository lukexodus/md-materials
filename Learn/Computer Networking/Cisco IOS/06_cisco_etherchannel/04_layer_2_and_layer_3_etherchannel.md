## Layer 2 and Layer 3 EtherChannel


EtherChannel operates at both Layer 2 (switching) and Layer 3 (routing) depending on the configuration and device capabilities.

**Layer 2 EtherChannel:**

**Access Port Configuration:**

```
Switch(config)# interface range gigabitethernet 1/0/1-2
Switch(config-if-range)# switchport mode access
Switch(config-if-range)# switchport access vlan 10
Switch(config-if-range)# channel-group 1 mode active
Switch(config-if-range)# exit
Switch(config)# interface port-channel 1
Switch(config-if)# switchport mode access
Switch(config-if)# switchport access vlan 10
```

**Trunk Port Configuration:**

```
Switch(config)# interface range gigabitethernet 1/0/3-4
Switch(config-if-range)# switchport mode trunk
Switch(config-if-range)# switchport trunk allowed vlan 10,20,30
Switch(config-if-range)# channel-group 2 mode active
Switch(config-if-range)# exit
Switch(config)# interface port-channel 2
Switch(config-if)# switchport mode trunk
Switch(config-if)# switchport trunk allowed vlan 10,20,30
```

**Layer 3 EtherChannel:**

**Routed Interface Configuration:**

```
Switch(config)# interface range gigabitethernet 1/0/5-6
Switch(config-if-range)# no switchport
Switch(config-if-range)# channel-group 3 mode active
Switch(config-if-range)# exit
Switch(config)# interface port-channel 3
Switch(config-if)# no switchport
Switch(config-if)# ip address 192.168.1.1 255.255.255.252
```

**Layer 3 Requirements:**

- Interfaces must be configured as routed ports (`no switchport`)
- IP addressing applied to port-channel interface
- Routing protocols can use the logical interface
- Supports both IPv4 and IPv6 addressing

**Mixed Layer Considerations:** All member interfaces must operate at the same layer. Layer 2 and Layer 3 interfaces cannot be mixed within the same EtherChannel.

