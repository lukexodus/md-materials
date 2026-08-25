## NTP (Network Time Protocol)


### NTP Overview

NTP synchronizes clocks across network devices using a hierarchical stratum system.

**Stratum Levels:**
- Stratum 0: Reference clocks (atomic clocks, GPS)
- Stratum 1: Servers directly connected to stratum 0
- Stratum 2: Servers synchronized to stratum 1
- Stratum 3-15: Each level synchronized to level above
- Stratum 16: Unsynchronized

### NTP Client Configuration

**Basic NTP Client:**
```
R1(config)# ntp server 192.168.1.200
R1(config)# ntp server 192.168.1.201
R1(config)# ntp server 10.10.10.100 prefer
```

**With Source Interface:**
```
R1(config)# interface loopback 0
R1(config-if)# ip address 1.1.1.1 255.255.255.255
R1(config-if)# exit
R1(config)# ntp source loopback 0
R1(config)# ntp server 192.168.1.200
```

**Key points:**
- `prefer` keyword designates preferred NTP server
- Configure multiple NTP servers for redundancy
- Source interface provides consistent source IP
- NTP uses UDP port 123

### NTP Server Configuration

**Configuring Device as NTP Server:**
```
R1(config)# ntp master 3                          ! Stratum 3 server
```

**Key points:**
- Default stratum when using `ntp master`: 8
- Lower stratum number = higher priority
- Should only configure `ntp master` if device has accurate clock source
- Typically used in isolated networks without internet access

### NTP Authentication

**Configuring NTP Authentication:**
```
R1(config)# ntp authenticate
R1(config)# ntp authentication-key 1 md5 NTP@SecretKey123
R1(config)# ntp trusted-key 1
R1(config)# ntp server 192.168.1.200 key 1
```

**On NTP Server:**
```
NTP-Server(config)# ntp authenticate
NTP-Server(config)# ntp authentication-key 1 md5 NTP@SecretKey123
NTP-Server(config)# ntp trusted-key 1
NTP-Server(config)# ntp master 2
```

**Key points:**
- Authentication prevents rogue NTP servers
- All devices must share same key and key number
- Keys are MD5 hashed
- Multiple keys can be configured for key rotation

### NTP Access Control

**Restricting NTP Access:**
```
R1(config)# access-list 10 permit 192.168.1.0 0.0.0.255
R1(config)# access-list 10 permit 10.10.10.0 0.0.0.255
R1(config)# ntp access-group peer 10
```

**NTP Access Group Types:**
```
R1(config)# ntp access-group query-only 10        ! Allow only time queries
R1(config)# ntp access-group serve-only 10        ! Allow time requests
R1(config)# ntp access-group serve 10             ! Allow time requests and queries
R1(config)# ntp access-group peer 10              ! Allow full NTP peering
```

**Key points:**
- `query-only`: Most restrictive, control queries only
- `serve-only`: Allow time synchronization requests
- `serve`: Allow time sync and control queries
- `peer`: Least restrictive, full synchronization
- Apply in order: peer > serve > serve-only > query-only

### NTP Verification

**Show NTP Status:**
```
R1# show ntp status
Clock is synchronized, stratum 3, reference is 192.168.1.200
nominal freq is 250.0000 Hz, actual freq is 249.9995 Hz, precision is 2**18
ntp uptime is 145200 (1/100 of seconds), resolution is 4016
reference time is E4C8A1F2.3D70A3D7 (14:23:46.240 PST Mon Jan 15 2025)
clock offset is -2.5432 msec, root delay is 15.23 msec
root dispersion is 45.67 msec, peer dispersion is 2.34 msec
loopfilter state is 'CTRL' (Normal Controlled Loop), drift is -0.000012345 s/s
system poll interval is 64, last update was 23 sec ago.
```

**Show NTP Associations:**
```
R1# show ntp associations

  address         ref clock       st   when   poll reach  delay  offset   disp
*~192.168.1.200  .GPS.            1     45     64   377  10.23   -2.54   1.25
+~192.168.1.201  .GPS.            1     52     64   377  11.45   -1.87   2.13
 ~10.10.10.100   192.168.1.200    2    102     64   377  25.67   +5.23   3.45
 * sys.peer, # selected, + candidate, - outlyer, x falseticker, ~ configured
```

**Show NTP Associations Detail:**
```
R1# show ntp associations detail
192.168.1.200 configured, our_master, sane, valid, stratum 1
ref ID .GPS., time E4C8A1F2.3D70A3D7 (14:23:46.240 PST Mon Jan 15 2025)
our mode client, peer mode server, our poll intvl 64, peer poll intvl 64
root delay 0.00 msec, root disp 2.34, reach 377, sync dist 12.345
delay 10.23 msec, offset -2.5432 msec, dispersion 1.25
precision 2**6, version 4
org time E4C8A234.5F8C9D2E (14:25:56.373 PST Mon Jan 15 2025)
rec time E4C8A234.60A3B4F1 (14:25:56.377 PST Mon Jan 15 2025)
xmt time E4C8A234.61B2C5D8 (14:25:56.382 PST Mon Jan 15 2025)
filtdelay =    10.23   11.34   10.87   12.01   11.56   10.98   11.23   10.67
filtoffset =   -2.54   -2.89   -2.67   -3.12   -2.78   -2.45   -2.91   -2.56
filterror =     1.25    2.34    3.45    4.56    5.67    6.78    7.89    8.91
```

**Useful Verification Commands:**
```
R1# show ntp status                               ! Overall NTP status
R1# show ntp associations                         ! NTP peer summary
R1# show ntp associations detail                  ! Detailed peer info
R1# show clock                                    ! Current system time
R1# show clock detail                             ! Time source details
```

**Output Examples:**
```
R1# show clock
14:28:34.567 PST Mon Jan 15 2025

R1# show clock detail
14:28:42.123 PST Mon Jan 15 2025
Time source is NTP
```

**Key points:**
- `*` indicates synchronized peer (sys.peer)
- `+` indicates candidate for synchronization
- `-` indicates outlier (rejected)
- `x` indicates falseticker (bad time source)
- `~` indicates configured peer
- `reach` value 377 (octal) = 255 (decimal) = 8 consecutive successful polls
- Synchronization takes several minutes
- Stratum increases by 1 from reference clock

### NTP Peer Configuration

**Configuring NTP Peers (Symmetric Active Mode):**
```
R1(config)# ntp peer 192.168.1.2
R1(config)# ntp peer 192.168.1.3

R2(config)# ntp peer 192.168.1.1
R2(config)# ntp peer 192.168.1.3

R3(config)# ntp peer 192.168.1.1
R3(config)# ntp peer 192.168.1.2
```

**Key points:**
- Peer mode for devices at same stratum level
- Both devices attempt to synchronize with each other
- Provides redundancy in NTP topology
- Used in meshed NTP architectures

### Timezone and Daylight Saving Time

**Configuring Timezone:**
```
R1(config)# clock timezone PST -8                 ! Pacific Standard Time
R1(config)# clock timezone EST -5                 ! Eastern Standard Time
R1(config)# clock timezone UTC 0                  ! Coordinated Universal Time
R1(config)# clock timezone JST 9                  ! Japan Standard Time
```

**Configuring Daylight Saving Time:**
```
R1(config)# clock summer-time PDT recurring       ! US Pacific Daylight Time
R1(config)# clock summer-time EDT recurring       ! US Eastern Daylight Time
```

**Custom Daylight Saving Time:**
```
R1(config)# clock summer-time PDT recurring 2 Sunday March 02:00 1 Sunday November 02:00
```

**Key points:**
- Timezone offset in hours from UTC
- Positive for east of UTC, negative for west
- `recurring` uses built-in DST rules
- Can specify custom DST start/end dates
- Timezone configuration independent of NTP

### Manual Clock Configuration

**Setting Clock Manually (Privileged EXEC):**
```
R1# clock set 14:30:00 15 January 2025
```

**Key points:**
- Format: `clock set hh:mm:ss day month year`
- Manual setting lost after reload without NTP
- Use only for initial configuration or when NTP unavailable
- NTP will override manual setting once synchronized

### NTP Troubleshooting

**Common Issues:**

**Problem: Clock not synchronizing**
```
R1# show ntp status
Clock is unsynchronized, stratum 16, no reference clock
```

**Troubleshooting steps:**
1. Verify NTP server reachability: `ping 192.168.1.200`
2. Check NTP associations: `show ntp associations`
3. Verify reach value (should increase to 377)
4. Check for ACLs blocking UDP 123
5. Verify NTP authentication configuration matches
6. Wait sufficient time (5-10 minutes minimum)

**Problem: High offset or dispersion**
```
R1# show ntp associations
  address         ref clock       st   when   poll reach  delay  offset   disp
*~192.168.1.200  .GPS.            1     12     64   377  10.23  +250.4  45.67
```

**Possible causes:**
- Network latency or jitter
- Incorrect timezone configuration
- Faulty NTP server clock
- Local clock drift

**Debugging NTP:**
```
R1# debug ntp all                                 ! Enable all NTP debugging
R1# debug ntp packets                             ! Debug NTP packets
R1# debug ntp validity                            ! Debug NTP validity checks
R1# debug ntp sync                                ! Debug synchronization
R1# undebug all                                   ! Disable all debugging
```

**Key points:**
- NTP synchronization requires patience (several poll intervals)
- Poll interval increases as clock stability improves
- Initial poll interval: 64 seconds, can increase to 1024 seconds
- Use debug commands cautiously on production devices

