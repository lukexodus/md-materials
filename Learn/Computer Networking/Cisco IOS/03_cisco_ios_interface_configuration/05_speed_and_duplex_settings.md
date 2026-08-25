## Speed and Duplex Settings


Network interfaces can operate at different speeds and duplex modes depending on hardware capabilities.

**Speed Configuration:**

```
Router(config-if)# speed 100
Router(config-if)# speed 1000
Router(config-if)# speed auto
```

**Duplex Configuration:**

```
Router(config-if)# duplex full
Router(config-if)# duplex half
Router(config-if)# duplex auto
```

**Auto-negotiation:**

```
Router(config-if)# speed auto
Router(config-if)# duplex auto
```

Auto-negotiation is the default setting on most modern interfaces and automatically determines the best speed and duplex combination.

**Manual Configuration Scenarios:**

- Connecting to legacy devices that don't support auto-negotiation
- Troubleshooting speed/duplex mismatches
- Enforcing specific performance requirements
- Connecting to devices with known auto-negotiation issues

**Common Speed/Duplex Combinations:**

- 10 Mbps half-duplex
- 10 Mbps full-duplex
- 100 Mbps half-duplex
- 100 Mbps full-duplex
- 1000 Mbps full-duplex (Gigabit Ethernet doesn't support half-duplex)

**Mismatch Issues:** Speed and duplex mismatches cause performance problems, including excessive collisions, frame errors, and reduced throughput. Both ends of a link must be configured identically when using manual settings.

