## Console, VTY, and AUX Line Configuration


### Console Line Configuration

The console port provides local administrative access:

```
R1(config)# line console 0
R1(config-line)# password Cons0le@123
R1(config-line)# login
R1(config-line)# logging synchronous
R1(config-line)# exec-timeout 5 30
R1(config-line)# history size 100
```

**With Local Username Authentication:**

```
R1(config)# username admin privilege 15 secret Admin@123
R1(config)# line console 0
R1(config-line)# login local
R1(config-line)# logging synchronous
R1(config-line)# exec-timeout 10 0
```

**Key points:**

- `login` requires password configured with `password` command
- `login local` uses local username database
- `logging synchronous` prevents log messages from interrupting commands
- `exec-timeout minutes seconds` sets idle timeout (0 0 = never timeout)
- `history size` configures command history buffer
- Only one console line exists: line console 0

### VTY Line Configuration

VTY (Virtual Teletype) lines handle remote access via Telnet and SSH:

```
R1(config)# line vty 0 4
R1(config-line)# password VTY@123
R1(config-line)# login
R1(config-line)# exec-timeout 15 0
R1(config-line)# logging synchronous
R1(config-line)# transport input telnet ssh
```

**With Access Control:**

```
R1(config)# access-list 10 permit 192.168.1.0 0.0.0.255
R1(config)# access-list 10 permit 10.10.10.0 0.0.0.255
R1(config)# access-list 10 deny any log
R1(config)# 
R1(config)# line vty 0 4
R1(config-line)# access-class 10 in
R1(config-line)# login local
R1(config-line)# transport input ssh
```

**Extended VTY Lines:**

```
R1(config)# line vty 0 15
R1(config-line)# login local
R1(config-line)# transport input ssh
```

**Key points:**

- Default VTY lines: 0-4 (5 concurrent sessions)
- Can extend to 0-15 or higher depending on platform
- `transport input` controls allowed protocols (telnet, ssh, all, none)
- `access-class` applies ACL to VTY access
- `login local` recommended over simple password
- Configure all VTY lines identically for consistency

### AUX Line Configuration

The auxiliary port supports modem connections and out-of-band management:

```
R1(config)# line aux 0
R1(config-line)# password AUX@123
R1(config-line)# login
R1(config-line)# exec-timeout 5 0
R1(config-line)# transport input telnet
R1(config-line)# no exec
```

**For Modem Connection:**

```
R1(config)# line aux 0
R1(config-line)# login local
R1(config-line)# modem InOut
R1(config-line)# transport input all
R1(config-line)# flowcontrol hardware
R1(config-line)# speed 115200
```

**Key points:**

- AUX port rarely used in modern networks
- Security risk if not properly configured
- Use `no exec` to disable EXEC shell if not needed
- Only one AUX line: line aux 0
- Consider disabling if not in use: `transport input none`

### Common Line Configuration Parameters

```
R1(config-line)# exec-timeout 10 0
R1(config-line)# logging synchronous
R1(config-line)# history size 50
R1(config-line)# session-timeout 30
R1(config-line)# absolute-timeout 60
R1(config-line)# login block-for 120 attempts 3 within 60
R1(config-line)# login on-failure log
R1(config-line)# login on-success log
```

**Key points:**

- `session-timeout` disconnects after specified minutes of connectivity
- `absolute-timeout` disconnects after specified minutes regardless of activity
- `login block-for` implements login failure rate-limiting
- Apply consistent security settings across all line types

