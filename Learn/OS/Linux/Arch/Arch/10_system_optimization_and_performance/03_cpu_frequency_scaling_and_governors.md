## CPU Frequency Scaling and Governors


### CPU Frequency Scaling Overview

**Purpose**: Adjust processor frequency for power efficiency.[1][2]

**Benefits**:[2][1]
- Reduced power consumption[1]
- Lower heat generation[1]
- Extended battery life[1]
- Extended hardware lifespan[1]

**Trade-off**: Lower frequency means reduced performance.[1]

### CPU Frequency Framework

#### Kernel Support

**cpufreq Module**: Manages frequency scaling.[1]

**Check Availability**:[1]

```bash
ls /sys/devices/system/cpu/cpu0/cpufreq/
```

**Module Loading**:[1]

```bash
sudo modprobe cpufreq_powersave
sudo modprobe cpufreq_performance
```

#### Scaling Drivers

**Detection**:[1]

```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver
```

**Common Drivers**:[1]
- `intel_pstate`: Intel processors[1]
- `amd_pstate`: AMD processors[1]
- `cpufreq-dt`: Device tree[1]

### Governors

**Purpose**: Policies determining frequency selection.[1]

**Kernel Decision**: Governor responds to system load.[1]

#### Performance Governor

**Behavior**: Always maximum frequency.[1]

**Use Case**: Gaming, compilation, CPU-intensive work.[1]

**Power Draw**: Maximum.[1]

**Set Governor**:[1]

```bash
echo "performance" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

#### Powersave Governor

**Behavior**: Always minimum frequency.[1]

**Use Case**: Battery mode, idle systems.[1]

**Power Draw**: Minimum.[1]

**Set Governor**:[1]

```bash
echo "powersave" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

#### Ondemand Governor

**Behavior**: Scales frequency based on load.[1]

**Responsiveness**: Good responsiveness.[1]

**Decision**: CPU usage triggers changes.[1]

**Tunables**:[1]
- `up_threshold`: CPU% to increase frequency[1]
- `sampling_rate`: Check interval[1]

#### Conservative Governor

**Behavior**: Gradual frequency adjustment.[1]

**Responsiveness**: Slower response than ondemand.[1]

**Power Efficiency**: Better power efficiency.[1]

#### Schedutil Governor

**Modern Default**: Uses scheduler information.[1]

**Intelligent**: Predicts needed frequency.[1]

**Responsive**: Fast adjustment.[1]

**Efficient**: Balances power and performance.[1]

### Checking Frequency

#### Current Frequency

**All CPUs**:[1]

```bash
watch -n 0.5 'cat /proc/cpuinfo | grep MHz'
```

Continuously monitor CPU frequency.[1]

**Single Check**:[1]

```bash
cpufreq-info
```

or

```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq
```

#### Available Frequencies

**Frequency Range**:[1]

```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq
cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq
```

**Conversion**: Divide by 1000 for MHz.[1]

#### Current Governor

**Active Governor**:[1]

```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
```

**All CPUs**:[1]

```bash
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

### Setting Frequency Scaling

#### Temporary Changes

**Set Governor**:[1]

```bash
echo "schedutil" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

**Set Maximum Frequency**:[1]

```bash
echo 2400000 | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq
```

Frequency in kHz.[1]

#### Persistent Configuration

**Using sysfs**: Create startup script:[1]

```bash
#!/bin/bash
echo "schedutil" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

**Using cpupower**: `sudo pacman -S cpupower`:[1]

```bash
sudo cpupower frequency-set -g schedutil
```

**Systemd Service**: `/etc/systemd/system/cpu-freq.service`:[1]

```ini
[Unit]
Description=CPU Frequency Scaling
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/cpupower frequency-set -g schedutil
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

**Enable**:[1]

```bash
sudo systemctl enable --now cpu-freq.service
```

### Intel P-State Driver

#### Overview

**Modern Intel**: Integrated frequency management.[1]

**Control Method**: Different from traditional cpufreq.[1]

**Status**:[1]

```bash
cat /sys/devices/system/cpu/intel_pstate/status
```

#### Intel P-State Configuration

**Min/Max Frequency**:[1]

```bash
echo 1400000 | sudo tee /sys/devices/system/cpu/intel_pstate/min_perf_pct
echo 100 | sudo tee /sys/devices/system/cpu/intel_pstate/max_perf_pct
```

**Disable Turbo**:[1]

```bash
echo 0 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo
```

#### Intel Turbo Boost

**Purpose**: Temporarily exceed base frequency.[1]

**Current Status**:[1]

```bash
cat /sys/devices/system/cpu/intel_pstate/no_turbo
```

**Disable**:[1]

```bash
echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo
```

### AMD P-State Driver

#### Overview

**Modern AMD**: Integrated frequency scaling.[1]

**Similar to Intel**: Modern approach.[1]

#### AMD P-State Configuration

**Status**:[1]

```bash
cat /sys/devices/system/cpu/amd_pstate/status
```

**Scalable Boost**:[1]

```bash
cat /sys/devices/system/cpu/cpufreq/boost
```

**Disable Boost**:[1]

```bash
echo 0 | sudo tee /sys/devices/system/cpu/cpufreq/boost
```

### Turbo/Boost Control

#### Intel Turbo Boost

**Check Status**:[1]

```bash
cat /sys/devices/system/cpu/intel_pstate/no_turbo
```

**Disable for Consistency**:[1]

```bash
echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo
```

#### AMD Boost

**Check Status**:[1]

```bash
cat /sys/devices/system/cpu/cpufreq/boost
```

**Disable**:[1]

```bash
echo 0 | sudo tee /sys/devices/system/cpu/cpufreq/boost
```

### Thermal Management

#### CPU Temperature

**Check Temperature**:[1]

```bash
sensors
```

or

```bash
cat /sys/class/thermal/thermal_zone*/temp
```

#### Thermal Throttling

**Purpose**: Reduces frequency to prevent overheating.[1]

**Monitor**:[1]

```bash
watch -n 1 'cat /proc/cpuinfo | grep MHz'
```

Watch for frequency drops.[1]

#### Fan Control

**Tool**: `lm_sensors`:[1]

```bash
sudo pacman -S lm_sensors
sudo sensors-detect
sensors
```

**PWM Fan**: `pwmconfig` tool:[1]

```bash
sudo pacman -S fancontrol
sudo pwmconfig
```

### Performance Profiling

#### Before and After

**Benchmark Base**:[1]

```bash
time stress-ng --cpu 4 --timeout 60s
```

Record with default settings.[1]

**Change Governor**:[1]

```bash
echo "performance" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

**Benchmark Again**:[1]

```bash
time stress-ng --cpu 4 --timeout 60s
```

Compare results.[1]

#### Power Consumption

**Monitor Power**:[1]

```bash
watch -n 1 'grep MHz /proc/cpuinfo'
```

Lower frequency = lower power.[1]

### Laptop Power Profiles

#### Balanced Profile

**Default**: Balances performance and power.[1]

**Governor**: `schedutil` or `ondemand`.[1]

**Max Frequency**: 100%.[1]

#### Power Saving Profile

**Battery Mode**:[1]

```bash
echo "powersave" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

**Max Frequency**: Reduce to 70-80%:[1]

```bash
echo 2400000 | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq
```

#### Performance Profile

**Maximum Speed**:[1]

```bash
echo "performance" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

### Frequency Scaling Tools

#### cpufreq-info

**Installation**: `sudo pacman -S cpupower`.[1]

**Current Information**:[1]

```bash
cpufreq-info
```

#### cpupower

**Set Governor**:[1]

```bash
sudo cpupower frequency-set -g schedutil
```

**Set Max Frequency**:[1]

```bash
sudo cpupower frequency-set -u 3000MHz
```

**Current Status**:[1]

```bash
sudo cpupower frequency-info
```

### Best Practices

**Default to Schedutil**: Modern, efficient governor.[1]

**Monitor Temperature**: Prevent thermal issues.[1]

**Disable Turbo if Needed**: For consistent performance.[1]

**Use Profiles**: Different settings for different scenarios.[1]

**Document Settings**: Record optimizations.[1]

**Test Performance**: Measure actual impact.[1]

**Balance Needs**: Match CPU tuning to workload.[1]

### Common Issues

**Frequency Not Changing**:[1]

Verify driver support:[1]

```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver
```

**High Temperature**:[1]

Reduce frequency or improve cooling.[1]

**Poor Performance**:[1]

Increase frequency or use performance governor.[1]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] Which should I use, x11 or wayland? - openSUSE Forums https://forums.opensuse.org/t/which-should-i-use-x11-or-wayland/166824

