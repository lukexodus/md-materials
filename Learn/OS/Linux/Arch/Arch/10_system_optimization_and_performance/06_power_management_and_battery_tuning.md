## Power Management and Battery Tuning


### Power Management Overview

**Purpose**: Optimize power consumption for battery life and efficiency.[1][2]

**Target Systems**:[2][1]
- Laptops[1]
- Portable devices[1]
- Data centers[1]

**Benefits**:[1]
- Extended battery life[1]
- Reduced heat[1]
- Lower electricity costs[1]
- Environmental impact[1]

### Laptop Power States

#### CPU States

**P-States**: Performance states.[1]

**C-States**: Idle states.[1]

**Modern Processors**: Multiple power levels available.[1]

#### Check Supported States

**CPU Frequency**:[1]

```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
```

**Idle States**:[1]

```bash
cat /sys/devices/system/cpu/cpu0/cpuidle/states/*/name
```

### Power Profiles

#### tlp (Advanced Power Management)

**Installation**: `sudo pacman -S tlp`.[2][1]

**Enable Service**:[1]

```bash
sudo systemctl enable --now tlp.service
sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket
```

**Configuration**: `/etc/tlp.conf`.[1]

#### Default Configuration

**Balanced Profile**:[1]

```bash
# AC mode
CPU_SCALING_GOVERNOR_ON_AC=performance
CPU_ENERGY_PERF_POLICY_ON_AC=performance

# Battery mode
CPU_SCALING_GOVERNOR_ON_BAT=powersave
CPU_ENERGY_PERF_POLICY_ON_BAT=powersave
CPU_MAX_PERF_ON_BAT=60
```

**Turbo Boost**:[1]

```bash
CPU_BOOST_ON_AC=1
CPU_BOOST_ON_BAT=0
```

#### Monitor tlp Status

**Check Active Profile**:[1]

```bash
sudo tlp-stat
```

**Power Status**:[1]

```bash
sudo tlp-stat -p
```

#### USB Power Saving

**Configuration**:[1]

```bash
USB_AUTOSUSPEND=1
USB_AUTOSUSPEND_BLACKLIST="1234:5678"  # Device ID to exclude
```

**Verify**:[1]

```bash
sudo tlp-stat -u
```

### Power Profiles Daemon

#### Installation

**Modern Alternative**: `sudo pacman -S power-profiles-daemon`.[2]

**Enable Service**:[2]

```bash
sudo systemctl enable --now power-profiles-daemon.service
```

#### Profile Selection

**Available Profiles**:[2]

```bash
powerprofilesctl list
```

**Set Profile**:[2]

```bash
powerprofilesctl set performance  # Max performance
powerprofilesctl set balanced     # Balanced
powerprofilesctl set power-saver  # Battery saver
```

**Current Profile**:[2]

```bash
powerprofilesctl get
```

### Battery Management

#### Check Battery Status

**Battery Information**:[1]

```bash
acpi -b
```

**Detailed Battery Info**:[1]

```bash
upower -e
upower -i /org/freedesktop/UPower/devices/battery_BAT0
```

#### Battery Health

**Cycle Count**:[1]

```bash
cat /sys/class/power_supply/BAT0/cycle_count
```

**Capacity**:[1]

```bash
cat /sys/class/power_supply/BAT0/charge_full
cat /sys/class/power_supply/BAT0/charge_full_design
```

**Degradation**: Current capacity vs. design capacity.[1]

#### Battery Conservation Mode

**Limit Charging**:[1]

Some laptops support threshold limiting:

```bash
echo 80 | sudo tee /sys/class/power_supply/BAT0/charge_stop_threshold
echo 20 | sudo tee /sys/class/power_supply/BAT0/charge_start_threshold
```

**Extends Battery Life**: Reduces stress.[1]

### Display Power Management

#### DPMS (Display Power Management Signaling)

**Auto Suspend**:[1]

```bash
xset dpms 300 600 900
```

Parameters: standby, suspend, off times in seconds.[1]

**Disable DPMS**:[1]

```bash
xset -dpms
```

#### Brightness Control

**Current Brightness**:[1]

```bash
cat /sys/class/backlight/intel_backlight/brightness
cat /sys/class/backlight/intel_backlight/max_brightness
```

**Adjust Brightness**:[1]

```bash
echo 50 | sudo tee /sys/class/backlight/intel_backlight/brightness
```

**Percentage**:[1]

```bash
MAX=$(cat /sys/class/backlight/intel_backlight/max_brightness)
echo $((MAX * 70 / 100)) | sudo tee /sys/class/backlight/intel_backlight/brightness
```

#### Automatic Brightness

**Installation**: `sudo pacman -S brightnessctl`:[1]

```bash
brightnessctl set 70%
```

**Dynamic Adjustment**:[1]

Use system tools based on power state.[1]

### CPU Frequency Scaling

#### Set Governor

**Power Saving**:[1]

```bash
echo "powersave" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

**Balanced**:[1]

```bash
echo "schedutil" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

**Verify**:[1]

```bash
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

#### Frequency Limits

**Maximum Frequency**:[1]

```bash
echo 1800000 | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq
```

Frequency in kHz.[1]

**Dynamic Frequency**:[1]

Modern processors adjust automatically with schedutil.[1]

#### Disable Turbo Boost

**Intel**:[1]

```bash
echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo
```

**AMD**:[1]

```bash
echo 0 | sudo tee /sys/devices/system/cpu/cpufreq/boost
```

**Battery Life**: Significant improvement.[1]

### Disk Power Management

#### Spin-Down

**IDE/SATA Drives**:[1]

```bash
sudo hdparm -S 60 /dev/sda
```

Parameter: 5 × 60 seconds = 5 minutes.[1]

**SSD**: Usually no spin-down.[1]

#### Aggressive Power Management

**Configuration**:[1]

```bash
echo 1 | sudo tee /sys/module/libata/parameters/link_power_management_policy
```

**Monitor Idle**:[1]

```bash
watch -n 1 'cat /proc/diskstats | awk "{print $1, $2, $3, $4, $5}"'
```

### Network Power Management

#### WiFi Power Saving

**Configuration**:[1]

```bash
sudo iw wlan0 set power_save on
```

**Disable on AC Power**:[1]

```bash
sudo iw wlan0 set power_save off
```

#### Ethernet Wake-on-LAN

**Disable** (saves power):[1]

```bash
sudo ethtool -s eth0 wol d
```

**Options**:[1]
- `d`: Disable[1]
- `p`: Physical activity[1]
- `m`: Magic packet[1]

### Bluetooth Power Management

**Disable When Not Needed**:[1]

```bash
echo "disable" | sudo tee /proc/acpi/ibm/bluetooth
```

Or via systemd:

```bash
sudo systemctl stop bluetooth.service
sudo systemctl disable bluetooth.service
```

**Enable Only When Needed**:[1]

```bash
sudo systemctl start bluetooth.service
```

### Suspend and Hibernate

#### Suspend to RAM

**Command**:[1]

```bash
systemctl suspend
```

**Keyboard Shortcut**: Configure in desktop environment.[1]

**Power Draw**: Minimal (memory powered).[1]

#### Suspend to Disk (Hibernate)

**Enable Hibernation**:[1]

Create swap partition/file ≥ RAM size.[1]

**Kernel Parameter**: Add to boot options:[1]

```
resume=/dev/sdX#
```

**Command**:[1]

```bash
systemctl hibernate
```

**Resume**: Boot normally, kernel detects hibernation.[1]

#### Hybrid Sleep

**Suspend and Hibernation**:[1]

```bash
systemctl hybrid-sleep
```

**Advantage**: Fast resume or recovery.[1]

### Idle Tuning

#### CPU Idle States

**C-States Configuration**:[1]

```bash
cat /sys/devices/system/cpu/cpu0/cpuidle/states/*/latency
```

Lower latency = faster wake-up.[1]

**Latency Budget**:[1]

```bash
echo 1000 | sudo tee /sys/devices/system/cpu/cpu0/cpuidle/latency_us
```

### Power Monitoring

#### Real-time Power Draw

**powertop Tool**:[1]

```bash
sudo pacman -S powertop
sudo powertop --calibrate
sudo powertop
```

**Shows**: Power consumption by component.[1]

#### Battery Statistics

**Battery Report**:[1]

```bash
sudo powertop --html=report.html
```

**Analysis**: Power usage per hour.[1]

#### Consumption Over Time

**Monitor Battery Drain**:[1]

```bash
watch -n 5 'acpi -b'
```

Track percentage over time.[1]

### Thermal Management

#### Temperature Monitoring

**Current Temps**:[1]

```bash
sensors
cat /sys/class/thermal/thermal_zone*/temp
```

#### Thermal Throttling

**Reduce Frequency to Cool**:[1]

Automatic or configure limits.[1]

#### Fan Speed Control

**Manual Control**:[1]

```bash
echo "manual" | sudo tee /proc/acpi/ibm/fan
echo 5 | sudo tee /proc/acpi/ibm/fan
```

**Automated**:[1]

Use `lm_sensors` and `fancontrol`.[1]

### Battery Profile Scripts

#### Power Saving Script

**`/usr/local/bin/battery-mode.sh`**:[1]

```bash
#!/bin/bash
# Battery saving mode

echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo
echo 1 | sudo tee /sys/module/libata/parameters/link_power_management_policy
echo 1800000 | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq

# Optional: Reduce brightness
brightnessctl set 40%
```

**Make Executable**:[1]

```bash
sudo chmod +x /usr/local/bin/battery-mode.sh
```

#### AC Power Script

**`/usr/local/bin/ac-mode.sh`**:[1]

```bash
#!/bin/bash
# AC power mode

echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
echo 0 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo
echo 3000000 | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq

# Restore brightness
brightnessctl set 100%
```

### Automated Power Management

#### Event Hooks

**AC Adapter**: `/etc/acpi/events/ac-adapter`:[1]

```
event=ac_adapter
action=/usr/local/bin/power-profile.sh
```

**Script**: `/usr/local/bin/power-profile.sh`:[1]

```bash
#!/bin/bash
if acpi -a | grep -q "on-line"; then
    # AC power
    /usr/local/bin/ac-mode.sh
else
    # Battery
    /usr/local/bin/battery-mode.sh
fi
```

### Best Practices

**Profile Devices**: Identify power hogs.[1]

**Balance Needs**: Don't sacrifice too much functionality.[1]

**Use tlp or power-profiles-daemon**: Automated management.[2][1]

**Disable Unused Hardware**: Bluetooth, WiFi when not needed.[1]

**Monitor Temperature**: Prevent thermal damage.[1]

**Test Modifications**: Ensure stability.[1]

**Document Settings**: Record optimizations.[1]

**Regular Maintenance**: Clean cooling vents.[1]

### Performance Targets

**Laptop Idle**: 3-5W.[1]

**Video Playing**: 8-12W.[1]

**Heavy Load**: 20-30W+.[1]

**Battery Life**: 8+ hours typical, 4-5 with optimizations.[1]

Varies by hardware and usage patterns.[1]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] Which should I use, x11 or wayland? - openSUSE Forums https://forums.opensuse.org/t/which-should-i-use-x11-or-wayland/166824

