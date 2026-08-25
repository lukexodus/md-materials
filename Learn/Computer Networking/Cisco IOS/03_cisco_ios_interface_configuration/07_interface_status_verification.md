## Interface Status Verification


Multiple commands provide different views of interface status and configuration.

**Basic Interface Status:**

```
Router# show interfaces
Router# show interfaces gigabitethernet 0/0/1
Router# show interfaces brief
Router# show ip interface brief
```

**Interface Statistics:**

```
Router# show interfaces gigabitethernet 0/0/1 stats
Router# show interfaces counters
Router# show interfaces counters errors
```

**Layer 2 Information:**

```
Router# show interfaces status
Router# show interfaces switchport
Router# show interfaces trunk
```

**Layer 3 Information:**

```
Router# show ip interface
Router# show ip interface gigabitethernet 0/0/1
Router# show ipv6 interface
Router# show ipv6 interface brief
```

**Key Status Indicators:**

**Administrative Status:**

- up: Interface is enabled (`no shutdown`)
- administratively down: Interface is disabled (`shutdown`)

**Operational Status:**

- up: Interface is functioning and has physical connectivity
- down: Interface has no physical connectivity or hardware issues

**Protocol Status:**

- up: Layer 3 protocols are operational
- down: Layer 3 protocols are not operational

**Common Status Combinations:**

- up/up: Interface is fully operational
- administratively down/down: Interface is intentionally disabled
- up/down: Physical connection exists but protocol issues prevent operation
- down/down: No physical connectivity

