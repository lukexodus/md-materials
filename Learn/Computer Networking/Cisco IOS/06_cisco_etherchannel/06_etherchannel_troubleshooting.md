## EtherChannel Troubleshooting


EtherChannel issues often stem from configuration mismatches, protocol negotiation failures, or physical connectivity problems.

**Common Issues:**

**Configuration Mismatch:** All member interfaces must have identical configurations. Mismatched settings prevent EtherChannel formation or cause erratic behavior.

**Typical Mismatches:**

- Speed/duplex settings
- VLAN configuration
- Access/trunk mode differences
- Native VLAN mismatches on trunk ports

**Protocol Negotiation Failures:** Incompatible negotiation modes prevent EtherChannel establishment:

- PAgP auto ↔ auto
- LACP passive ↔ passive
- Mixing PAgP and LACP modes

**Physical Issues:**

- Cable faults
- Port hardware failures
- Inconsistent physical connections

**Diagnostic Commands:**

**EtherChannel Status:**

```
Switch# show etherchannel summary
Switch# show etherchannel 1 detail
Switch# show etherchannel 1 port-channel
```

**Protocol-Specific Information:**

```
Switch# show pagp neighbor
Switch# show pagp 1 internal
Switch# show lacp neighbor
Switch# show lacp 1 internal
Switch# show lacp 1 counters
```

**Interface Status:**

```
Switch# show interfaces port-channel 1
Switch# show interfaces gigabitethernet 1/0/1 etherchannel
Switch# show spanning-tree interface port-channel 1
```

**Load Balancing Verification:**

```
Switch# show etherchannel load-balance
Switch# show etherchannel 1 load-balance
Switch# test etherchannel load-balance interface port-channel 1 mac 0000.1111.2222 0000.3333.4444
```

**Troubleshooting Steps:**

1. **Verify Physical Connectivity**: Ensure all cables are properly connected and ports are operational
2. **Check Configuration Consistency**: Compare configurations of all member interfaces
3. **Verify Protocol Settings**: Confirm compatible negotiation modes on both sides
4. **Monitor Protocol Messages**: Check for PAgP or LACP packet exchange
5. **Review Error Counters**: Look for errors that might indicate hardware issues
6. **Test Load Distribution**: Verify traffic is distributed across all member links

**Common Error Messages:**

- "Port-channel X: ports not compatible"
- "LACP: neighbor not responding"
- "PAgP: inconsistent partner"

**Resolution Strategies:**

- Reset EtherChannel configuration and reconfigure step by step
- Verify both sides of connection have compatible settings
- Use protocol debugging for detailed troubleshooting information
- Consider using manual (on) mode for basic aggregation without protocols

**Key points** for successful EtherChannel implementation: All member interfaces must have identical configurations, appropriate negotiation modes must be selected for the environment, and load-balancing methods should be chosen based on traffic patterns. Regular monitoring ensures optimal performance and early detection of potential issues.

---

