## Switch Port Modes


Switch ports can operate in different modes that determine how they handle VLAN traffic and participate in network segmentation.

**Access Mode:** Access ports belong to a single VLAN and typically connect end devices like computers, phones, or printers. They send and receive untagged frames.

```
Switch(config)# interface gigabitethernet 0/1
Switch(config-if)# switchport mode access
Switch(config-if)# switchport access vlan 10
```

Access ports strip any VLAN tags from incoming frames and add the configured VLAN tag when forwarding frames into the switch fabric. When forwarding to end devices, tags are removed again.

**Trunk Mode:** Trunk ports carry traffic for multiple VLANs simultaneously and use VLAN tagging (802.1Q or ISL) to identify which VLAN each frame belongs to. Trunks typically interconnect switches or connect switches to routers for inter-VLAN routing.

```
Switch(config)# interface gigabitethernet 0/24
Switch(config-if)# switchport mode trunk
Switch(config-if)# switchport trunk encapsulation dot1q
Switch(config-if)# switchport trunk allowed vlan 10,20,30
Switch(config-if)# switchport trunk native vlan 99
```

The native VLAN carries untagged traffic on a trunk. By default, this is VLAN 1, but changing it is a security best practice. Frames in the native VLAN traverse the trunk without 802.1Q tags.

**Dynamic Desirable Mode:** The port actively attempts to negotiate a trunk link using Dynamic Trunking Protocol (DTP). It will form a trunk if the neighbor port is set to trunk, desirable, or auto mode.

```
Switch(config-if)# switchport mode dynamic desirable
```

**Dynamic Auto Mode:** The port passively waits for DTP negotiation. It will become a trunk only if the neighbor actively negotiates (trunk or desirable mode). If both sides are auto, they remain access ports.

```
Switch(config-if)# switchport mode dynamic auto
```

**Port Mode Negotiation (DTP):** DTP is enabled by default on Cisco switches but can be disabled for security:

```
Switch(config-if)# switchport nonegotiate
```

**Verification Commands:**

```
Switch# show interfaces [interface-id] switchport
Switch# show interfaces trunk
Switch# show dtp interface [interface-id]
```

