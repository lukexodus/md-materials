## System Logging and Syslog


### Logging Destinations

Cisco IOS supports multiple logging destinations:

**Console Logging:**

```
R1(config)# logging console                       ! Enable console logging
R1(config)# logging console informational         ! Set level
R1(config)# no logging console                    ! Disable console logging
```

**Monitor (VTY) Logging:**

```
R1(config)# logging monitor warnings              ! Set monitor level
R1# terminal monitor                               ! Enable for current session
R1# terminal no monitor                            ! Disable for current session
```

**Buffered Logging:**

```
R1(config)# logging buffered 16384                ! Set buffer size (bytes)
R1(config)# logging buffered debugging            ! Set level
R1# show logging                                   ! View buffered logs
R1# clear logging                                  ! Clear log buffer
```

**Syslog Server:**

```
R1(config)# logging host 192.168.1.100            ! Syslog server IP
R1(config)# logging host 192.168.1.100 transport udp port 514
R1(config)# logging trap notifications            ! Set level for syslog
R1(config)# logging source-interface loopback 0   ! Source interface
R1(config)# logging facility local5               ! Facility code
```

### Logging Severity Levels

|Level|Keyword|Description|Example|
|---|---|---|---|
|0|emergencies|System unusable|Device shutdown|
|1|alerts|Immediate action needed|Temperature critical|
|2|critical|Critical conditions|Hardware failure|
|3|errors|Error conditions|Interface down|
|4|warnings|Warning conditions|Configuration change|
|5|notifications|Normal but significant|Line protocol up/down|
|6|informational|Informational messages|ACL match|
|7|debugging|Debug messages|Packet details|

**Key points:**

- Configuring a level includes all higher severity levels
- Level 7 (debugging) includes all messages
- Level 0 (emergencies) includes only emergencies

**Setting Logging Levels:**

```
R1(config)# logging console warnings              ! Levels 0-4 to console
R1(config)# logging monitor notifications         ! Levels 0-5 to monitor
R1(config)# logging buffered informational        ! Levels 0-6 to buffer
R1(config)# logging trap errors                   ! Levels 0-3 to syslog
```

### Syslog Message Format

**Standard Format:**

```
%FACILITY-SEVERITY-MNEMONIC: Message-text
```

**Example:**

```
%LINK-3-UPDOWN: Interface GigabitEthernet0/0, changed state to down
%LINEPROTO-5-UPDOWN: Line protocol on Interface GigabitEthernet0/0, changed state to down
%SYS-5-CONFIG_I: Configured from console by admin on vty0 (192.168.1.50)
```

**With Timestamps and Sequence Numbers:**

```
R1(config)# service timestamps log datetime msec localtime show-timezone
R1(config)# service timestamps debug datetime msec localtime show-timezone
R1(config)# service sequence-numbers
```

**Output:**

```
000045: Jan 15 2025 14:23:15.234 PST: %LINK-3-UPDOWN: Interface GigabitEthernet0/0, changed state to down
000046: Jan 15 2025 14:23:16.235 PST: %LINEPROTO-5-UPDOWN: Line protocol on Interface GigabitEthernet0/0, changed state to down
```

### Advanced Logging Configuration

**Rate Limiting:**

```
R1(config)# logging rate-limit console 10 except errors
R1(config)# logging rate-limit all 100
```

**Discriminator (Filtering):**

```
R1(config)# logging discriminator FILTER facility includes LINEPROTO
R1(config)# logging discriminator NOCDP mnemonics drops CDP
R1(config)# logging console discriminator FILTER
R1(config)# logging host 192.168.1.100 discriminator NOCDP
```

**Logging to Multiple Servers:**

```
R1(config)# logging host 192.168.1.100
R1(config)# logging host 192.168.1.101
R1(config)# logging host 10.10.10.50
```

**Enabling Logging for Specific Features:**

```
R1(config)# logging trap debugging
R1(config)# access-list 100 permit ip any any log
R1(config)# logging on                            ! Enable logging globally
```

### Logging Verification

**Show Logging:**

```
R1# show logging
Syslog logging: enabled (0 messages dropped, 3
messages rate-limited, 0 flushes, 0 overruns, xml disabled, filtering disabled)

No Active Message Discriminator.

No Inactive Message Discriminator.

    Console logging: level warnings, 245 messages logged, xml disabled,
                     filtering disabled
    Monitor logging: level debugging, 0 messages logged, xml disabled,
                     filtering disabled
    Buffer logging:  level informational, 1024 messages logged, xml disabled,
                    filtering disabled
    Exception Logging: size (4096 bytes)
    Count and timestamp logging messages: disabled
    Persistent logging: disabled

No active filter modules.

    Trap logging: level informational, 312 message lines logged
        Logging to 192.168.1.100  (udp port 514, audit disabled,
              link up),
              512 message lines logged, 
              0 message lines rate-limited, 
              0 message lines dropped-by-MD, 
              xml disabled, sequence number disabled
              filtering disabled
        Logging Source-Interface:       VRF Name:

Log Buffer (16384 bytes):

000045: Jan 15 2025 14:23:15.234 PST: %LINK-3-UPDOWN: Interface GigabitEthernet0/0, changed state to down
000046: Jan 15 2025 14:23:16.235 PST: %LINEPROTO-5-UPDOWN: Line protocol on Interface GigabitEthernet0/0, changed state to down
000047: Jan 15 2025 14:25:42.156 PST: %SYS-5-CONFIG_I: Configured from console by admin on vty0 (192.168.1.50)
```

**Show Logging History:**
```
R1# show logging history
Syslog History Table: 1 maximum table entries,
                      saving level warnings or higher
45 messages ignored, 0 dropped, 0 recursion drops
    entry number 1 : %LINK-3-UPDOWN
    Interface GigabitEthernet0/0, changed state to down
    timestamp: 245
```

**Debugging Considerations:**
```
R1# debug ip routing
IP routing debugging is on
R1# undebug all                                   ! Disable all debugging
All possible debugging has been turned off
```

**Key points:**
- Debug output uses CPU resources extensively
- Use debugging cautiously on production devices
- Debug output goes to console by default (use `terminal monitor` for VTY)
- Always disable debugging when troubleshooting complete
- `undebug all` or `no debug all` disables all debugging

### Syslog Best Practices

**Recommended Configuration:**
```
R1(config)# service timestamps log datetime msec localtime show-timezone
R1(config)# service timestamps debug datetime msec localtime show-timezone
R1(config)# service sequence-numbers
R1(config)# clock timezone PST -8
R1(config)# clock summer-time PDT recurring
R1(config)# ntp server 192.168.1.200
R1(config)# 
R1(config)# logging buffered 32768 informational
R1(config)# logging console warnings
R1(config)# logging monitor informational
R1(config)# logging trap informational
R1(config)# logging source-interface loopback 0
R1(config)# logging host 192.168.1.100
R1(config)# logging host 192.168.1.101
```

**Key points:**
- Use NTP for accurate timestamps across devices
- Configure timezone and daylight saving time
- Send logs to redundant syslog servers
- Use appropriate severity levels to avoid log flooding
- Enable sequence numbers for log analysis
- Use source-interface for consistent syslog source addresses
- Monitor syslog server storage capacity
- Implement log rotation on syslog servers

