## PAgP (Port Aggregation Protocol)


PAgP is Cisco's proprietary protocol for automatically forming EtherChannel connections between compatible Cisco devices.

**PAgP Modes:**

**Auto Mode:**

```
Switch(config-if)# channel-group 1 mode auto
```

The interface responds to PAgP packets but does not initiate negotiation. Forms EtherChannel only if the other side is set to desirable mode.

**Desirable Mode:**

```
Switch(config-if)# channel-group 1 mode desirable
```

The interface actively sends PAgP packets and initiates negotiation. Can form EtherChannel with auto or desirable modes on the other side.

**Working Combinations:**

- Desirable ↔ Desirable: Forms EtherChannel
- Desirable ↔ Auto: Forms EtherChannel
- Auto ↔ Auto: Does not form EtherChannel

**PAgP Operation:** PAgP exchanges information about interface capabilities, including speed, duplex, and VLAN configuration. The protocol ensures both sides have compatible configurations before forming the EtherChannel.

**PAgP Packets:** The protocol uses multicast frames sent every 30 seconds to maintain the EtherChannel and detect configuration changes. If PAgP packets are not received, the protocol can remove interfaces from the channel.

**Limitations:** PAgP only works between Cisco devices and cannot interoperate with other vendors' equipment. For multi-vendor environments, LACP provides standardized link aggregation.

