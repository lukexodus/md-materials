## MAC Address Table


The MAC address table (also called CAM table or Content Addressable Memory table) is the core database that enables switching functionality. It maps MAC addresses to physical switch ports and VLAN associations.

**Table Operations:**

- **Learning**: When a frame enters a port, the switch records the source MAC address, port number, and VLAN in the table
- **Aging**: Entries are removed after the aging timer expires without activity (default 300 seconds)
- **Flooding**: When destination MAC is unknown, the switch floods the frame to all ports in the VLAN except the source port
- **Forwarding**: When destination MAC exists in table, frame is sent only to that port

**Viewing MAC Address Table:**

```
Switch# show mac address-table
Switch# show mac address-table dynamic
Switch# show mac address-table address [mac-address]
Switch# show mac address-table interface [interface-id]
Switch# show mac address-table vlan [vlan-id]
```

**Managing MAC Address Table:**

```
Switch(config)# mac address-table aging-time [seconds]
Switch# clear mac address-table dynamic
Switch# clear mac address-table dynamic address [mac-address]
Switch# clear mac address-table dynamic interface [interface-id]
```

**Static MAC Address Entries:** You can manually configure static MAC entries that never age out:

```
Switch(config)# mac address-table static [mac-address] vlan [vlan-id] interface [interface-id]
```

**Table Size Limitations:** Different switch models have varying MAC address table capacities, ranging from 8,000 entries on small switches to over 100,000 on enterprise models. When the table fills, the switch may drop new learning attempts or remove older entries.

