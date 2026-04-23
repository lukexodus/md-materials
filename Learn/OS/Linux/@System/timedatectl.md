# timedatectl

Part of systemd. `timedatectl` queries and sets the system clock, timezone, and NTP synchronization. Replaces older tools like `date`, `hwclock`, and manual `/etc/localtime` symlink editing.

---

## Basic Usage

```bash
timedatectl                     # show current time, timezone, and NTP status
timedatectl status              # same as above (explicit)
timedatectl show                # machine-readable property output
```

**Example output:**

```
               Local time: Fri 2026-03-06 14:32:11 PST
           Universal time: Fri 2026-03-06 22:32:11 UTC
                 RTC time: Fri 2026-03-06 22:32:10
                Time zone: America/Los_Angeles (PST, -0800)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
```

Fields explained:

- **Local time** — current time in the configured timezone
- **Universal time** — current UTC time
- **RTC time** — hardware clock (Real Time Clock) time
- **Time zone** — active timezone with offset
- **System clock synchronized** — whether NTP has successfully synced
- **NTP service** — whether the NTP daemon is running
- **RTC in local TZ** — whether the hardware clock stores local time (should be `no` on Linux)

---

## Time & Date

### Setting Time Manually

Manual time setting only works when NTP is disabled:

```bash
timedatectl set-ntp false                       # disable NTP first
timedatectl set-time "2026-03-06 14:30:00"      # set date and time
timedatectl set-time "14:30:00"                 # set time only
timedatectl set-time "2026-03-06"               # set date only
```

Format is `YYYY-MM-DD HH:MM:SS`. Quotes required when including both date and time.

### Re-enabling NTP

```bash
timedatectl set-ntp true                        # re-enable NTP sync
```

---

## Timezones

### Viewing

```bash
timedatectl list-timezones                      # list all available timezones
timedatectl list-timezones | grep America       # filter by region
timedatectl list-timezones | grep -i london     # case-insensitive search
timedatectl list-timezones | wc -l              # count available timezones
```

### Setting

```bash
timedatectl set-timezone America/New_York
timedatectl set-timezone Europe/London
timedatectl set-timezone Asia/Tokyo
timedatectl set-timezone UTC
```

This updates the `/etc/localtime` symlink to point to the correct zoneinfo file under `/usr/share/zoneinfo/`. No reboot required.

**Find your timezone:**

```bash
timedatectl list-timezones | grep -i paris      # Europe/Paris
timedatectl list-timezones | grep Australia     # Australia/Sydney etc.
```

---

## NTP & Synchronization

### Checking Status

```bash
timedatectl show -p NTPSynchronized --value     # yes or no
timedatectl show -p NTP --value                 # whether NTP is enabled
```

### Enabling / Disabling

```bash
timedatectl set-ntp true        # enable NTP (starts timesyncd or chronyd)
timedatectl set-ntp false       # disable NTP
```

`set-ntp true` activates whichever NTP implementation is installed:

- `systemd-timesyncd` — lightweight, default on most systemd distros
- `chronyd` — more accurate, common on RHEL/Fedora
- `ntpd` — traditional NTP daemon

### Inspecting NTP in Detail

For `systemd-timesyncd` specifically:

```bash
timedatectl timesync-status             # detailed NTP sync info
```

**Example output:**

```
       Server: 185.125.190.57 (ntp.ubuntu.com)
Poll interval: 34min 8s (min: 32s; max 34min 8s)
         Leap: normal
      Version: 4
      Stratum: 2
    Reference: 11FABA04
    Precision: 1us (-20)
Root distance: 23.659ms (max: 5s)
       Offset: -1.375ms
        Delay: 28.498ms
       Jitter: 2.006ms
 Packet count: 5
    Frequency: -20.415ppm
```

Key fields:

- **Server** — NTP server currently in use
- **Stratum** — distance from reference clock (1 = directly connected to atomic clock, 2 = synced from stratum 1, etc.)
- **Offset** — difference between system clock and NTP time
- **Delay** — round-trip time to NTP server
- **Jitter** — variability in offset measurements

---

## Hardware Clock (RTC)

The RTC is a battery-backed clock on the motherboard that keeps time when the system is off.

```bash
timedatectl show -p RTCTimeUSec --value         # current RTC time
```

### RTC Timezone Mode

```bash
timedatectl set-local-rtc 0         # store UTC in RTC (recommended for Linux)
timedatectl set-local-rtc 1         # store local time in RTC (needed for dual-boot with Windows)
```

**Why this matters for dual-boot:** Windows stores local time in the RTC by default. Linux stores UTC. If dual-booting, either configure Windows to use UTC or set Linux to use local time in the RTC:

```bash
timedatectl set-local-rtc 1 --adjust-system-clock
```

The `--adjust-system-clock` flag adjusts the system clock when changing RTC mode to avoid a jump.

---

## Machine-Readable Output

```bash
timedatectl show                            # all properties as key=value
timedatectl show -p Timezone               # specific property
timedatectl show -p Timezone --value       # value only (no key)
timedatectl show -p NTP,NTPSynchronized    # multiple properties
```

**All available properties:**

```bash
timedatectl show                # see the full list
```

Common ones:

|Property|Example value|
|---|---|
|`Timezone`|`America/New_York`|
|`LocalRTC`|`no`|
|`NTP`|`yes`|
|`NTPSynchronized`|`yes`|
|`TimeUSec`|`Fri 2026-03-06 22:32:11 UTC`|
|`RTCTimeUSec`|`Fri 2026-03-06 22:32:10 UTC`|

---

## Practical Examples

**Check if the system clock is synced (for scripts):**

```bash
timedatectl show -p NTPSynchronized --value     # prints: yes or no
```

**Set timezone non-interactively in a provisioning script:**

```bash
timedatectl set-timezone UTC
```

**Temporarily disable NTP, set a specific time, re-enable:**

```bash
timedatectl set-ntp false
timedatectl set-time "2026-03-06 12:00:00"
timedatectl set-ntp true
```

**Find and set timezone by city:**

```bash
timedatectl list-timezones | grep -i sydney
# Australia/Sydney
timedatectl set-timezone Australia/Sydney
```

**Verify RTC is storing UTC (good practice):**

```bash
timedatectl show -p LocalRTC --value            # should print: no
```

**Check NTP server and sync quality:**

```bash
timedatectl timesync-status
```

---

## Configuration Files

### systemd-timesyncd

NTP server configuration for `systemd-timesyncd` lives at `/etc/systemd/timesyncd.conf`:

```ini
[Time]
NTP=0.pool.ntp.org 1.pool.ntp.org
FallbackNTP=ntp.ubuntu.com
RootDistanceMaxSec=5
PollIntervalMinSec=32
PollIntervalMaxSec=2048
```

After editing:

```bash
systemctl restart systemd-timesyncd
timedatectl timesync-status             # verify new server is in use
```

### Timezone data

Timezone definitions live in `/usr/share/zoneinfo/`. `set-timezone` creates a symlink:

```
/etc/localtime -> /usr/share/zoneinfo/America/New_York
```

You can verify:

```bash
readlink /etc/localtime
```

---

## Relationship to Other Tools

|Tool|Purpose|
|---|---|
|`timedatectl`|Query/set time, timezone, NTP (systemd)|
|`date`|Display or set system time (low-level)|
|`hwclock`|Read/write hardware RTC directly|
|`ntpdate`|One-shot NTP sync (deprecated)|
|`chronyc`|Control chronyd NTP daemon|
|`systemctl status systemd-timesyncd`|NTP daemon service status|

`timedatectl` is the right tool for most tasks on systemd systems. `hwclock` and `date` are lower-level and bypass logind's coordination.

---

## Tips

**Always use UTC in the RTC on pure-Linux systems** — it avoids DST-related clock jumps and is the standard. Only use local time in the RTC if dual-booting with Windows and you can't change Windows behavior.

**NTP must be disabled to set time manually** — `timedatectl set-time` will fail with an error if NTP is active. Disable it first, set the time, then re-enable.

**`timesync-status` only works with timesyncd** — if your system uses `chronyd` or `ntpd` instead, use `chronyc tracking` or `ntpq -p` for equivalent detail.

**Timezone changes take effect immediately** — no reboot or service restart needed. Running processes that cached the old timezone may need restarting to pick up the change.

**Stratum 2 is normal** — most public NTP servers are stratum 2. Stratum 1 servers are rare and generally reserved for infrastructure use. A stratum of 16 means unsynchronized.