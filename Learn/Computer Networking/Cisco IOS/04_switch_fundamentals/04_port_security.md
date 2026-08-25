## Port Security


Port security restricts which MAC addresses can send traffic through a switch port, protecting against MAC flooding attacks, unauthorized device connections, and network access control violations.

**Security Violation Modes:**

- **Protect**: Drops packets from unauthorized MAC addresses but doesn't log or disable the port. Traffic from authorized MACs continues normally.
- **Restrict**: Drops packets from unauthorized MACs, increments a violation counter, and logs SNMP traps and syslog messages. Port remains operational.
- **Shutdown**: Disables the port by placing it in err-disabled state, sends SNMP trap, logs syslog message. This is the default mode and requires manual or automatic recovery.

**Basic Port Security Configuration:**

```
Switch(config)# interface gigabitethernet 0/5
Switch(config-if)# switchport mode access
Switch(config-if)# switchport port-security
Switch(config-if)# switchport port-security maximum 2
Switch(config-if)# switchport port-security violation restrict
Switch(config-if)# switchport port-security mac-address sticky
```

**MAC Address Learning Methods:**

- **Static**: Manually configure allowed MAC addresses that persist in running and startup configs
    
    ```
    Switch(config-if)# switchport port-security mac-address [mac-address]
    ```
    
- **Dynamic**: Switch learns MAC addresses dynamically up to the maximum, but they're lost on reload
- **Sticky**: Dynamically learned MACs are converted to static entries in the running config and can be saved

**Aging Configuration:** Port security can age out learned MAC addresses to allow flexibility:

```
Switch(config-if)# switchport port-security aging time 120
Switch(config-if)# switchport port-security aging type {absolute | inactivity}
```

Absolute aging removes MACs after the specified time regardless of activity. Inactivity aging removes MACs only after they've been inactive for the timer duration.

**Recovery from Err-Disabled:** When a port is shut down due to violation, recovery options include:

```
! Manual recovery
Switch(config)# interface gigabitethernet 0/5
Switch(config-if)# shutdown
Switch(config-if)# no shutdown

! Automatic recovery
Switch(config)# errdisable recovery cause psecure-violation
Switch(config)# errdisable recovery interval 300
```

**Verification Commands:**

```
Switch# show port-security
Switch# show port-security interface [interface-id]
Switch# show port-security address
Switch# show errdisable recovery
```

