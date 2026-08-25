## LACP (Link Aggregation Control Protocol)


LACP is the IEEE 802.3ad standard protocol for link aggregation, providing interoperability between different vendor equipment.

**LACP Modes:**

**Active Mode:**

```
Switch(config-if)# channel-group 1 mode active
```

The interface actively sends LACP packets and initiates negotiation. Similar to PAgP desirable mode.

**Passive Mode:**

```
Switch(config-if)# channel-group 1 mode passive
```

The interface responds to LACP packets but does not initiate negotiation. Similar to PAgP auto mode.

**Working Combinations:**

- Active ↔ Active: Forms EtherChannel
- Active ↔ Passive: Forms EtherChannel
- Passive ↔ Passive: Does not form EtherChannel

**LACP Priority System:** LACP uses system priority values to determine which device controls the EtherChannel formation:

```
Switch(config)# lacp system-priority 100
```

Lower values indicate higher priority. Default system priority is 32768.

**Port Priority:** Individual interface priority within LACP:

```
Switch(config-if)# lacp port-priority 100
```

Used to determine which interfaces become active when more than 8 interfaces are configured in a channel group.

**LACP Timers:**

```
Switch(config-if)# lacp rate fast
Switch(config-if)# lacp rate normal
```

- **Fast**: LACP packets sent every 1 second
- **Normal**: LACP packets sent every 30 seconds (default)

**LACP Operation:** LACP exchanges Link Aggregation Control Protocol Data Units (LACPDUs) to negotiate and maintain the EtherChannel. The protocol continuously monitors link status and automatically adjusts the channel membership.

