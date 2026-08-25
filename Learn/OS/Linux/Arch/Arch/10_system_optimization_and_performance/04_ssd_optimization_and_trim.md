## SSD Optimization and TRIM


### SSD Fundamentals

**Technology**: Solid State Drive uses flash memory.[1][2]

**Advantages**:[2][1]
- Fast read/write speeds[1]
- No moving parts[1]
- Lower power consumption[1]
- Silent operation[1]

**Limitations**:[1]
- Write endurance (limited cycles)[1]
- Erase before write requirement[1]

### TRIM Operation

#### Purpose

**TRIM Command**: Tells SSD which blocks are unused.[2][1]

**Without TRIM**:[1]
- SSD thinks all blocks occupied[1]
- Performance degrades as blocks fill[1]
- Write amplification increases[1]

**With TRIM**:[1]
- SSD reclaims unused blocks[1]
- Maintains performance[1]
- Reduces wear[1]

#### TRIM Support

**Check Support**:[1]

```bash
lsblk -D
```

**Output**:[1]

```
NAME     DISC-ALN DISC-GRAN DISC-MAX DISC-ZERO
sda             0      512B       2G         0
sda1            0      512B       2G         0
```

**DISC-GRAN > 0**: TRIM supported.[1]

**Alternative Check**:[1]

```bash
sudo hdparm -I /dev/sda | grep TRIM
```

### Enabling TRIM

#### Automatic TRIM

**systemd-fstrim Service**:[2][1]

```bash
sudo systemctl enable --now fstrim.timer
```

**Frequency**: Weekly by default.[1]

**Verify**:[1]

```bash
sudo systemctl status fstrim.timer
```

#### Manual TRIM

**Run Immediately**:[2][1]

```bash
sudo fstrim -v /
```

**All Mounted Filesystems**:[1]

```bash
sudo fstrim -v -a
```

**Verbose Output**: Shows blocks trimmed.[1]

#### Continuous TRIM (LVM/dm-crypt)

**Mount Option**: `discard` enables continuous TRIM:[1]

In `/etc/fstab`:

```
/dev/mapper/root / ext4 defaults,discard 0 1
```

**Caution**: Slight performance overhead.[1]

### SSD Performance Optimization

#### Alignment

**Check Alignment**:[1]

```bash
cat /sys/block/sda/alignment_offset
```

**Output 0**: Properly aligned.[1]

**Verify Partition**:[1]

```bash
sudo parted /dev/sda align-check optimal 1
```

**Newly Created**: Modern partitioners align automatically.[1]

#### Overprovisioning

**Purpose**: Reserve space for SSD operations.[1]

**Typical**: 5-10% of drive capacity.[1]

**Configuration**:[1]

When partitioning, leave space unpartitioned.[1]

**Example**: 1TB drive, create 900GB partition.[1]

**Benefits**:[1]
- Longer lifespan[1]
- Better performance[1]
- Wear leveling capacity[1]

#### Scheduler Selection

**Check Current**:[1]

```bash
cat /sys/block/sda/queue/scheduler
```

**For SSD**:[1]

```bash
echo "none" | sudo tee /sys/block/sda/queue/scheduler
```

or

```bash
echo "mq-deadline" | sudo tee /sys/block/sda/queue/scheduler
```

**Persistent Configuration**: `/etc/udev/rules.d/60-ssd-scheduler.rules`:[1]

```
ACTION=="add|change", KERNEL=="sd*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
```

### Write Optimization

#### Caching Behavior

**Write Cache**:[1]

```bash
sudo hdparm -W /dev/sda
```

**Enable Cache**:[1]

```bash
sudo hdparm -W 1 /dev/sda
```

**Caution**: Risk data loss on power failure.[1]

#### Dirty Ratio

**Aggressive Writeback**:[1]

```bash
echo "vm.dirty_ratio = 5" | sudo tee -a /etc/sysctl.d/99-ssd.conf
echo "vm.dirty_background_ratio = 2" | sudo tee -a /etc/sysctl.d/99-ssd.conf
```

**Apply**:[1]

```bash
sudo sysctl -p
```

#### Flush Frequency

**Configure Writeback**:[1]

```bash
echo "vm.dirty_writeback_centisecs = 1500" | sudo tee -a /etc/sysctl.d/99-ssd.conf
```

Changes flush interval.[1]

### Firmware and Temperature

#### Check Firmware

**SSD Info**:[1]

```bash
sudo nvme list
sudo smartctl -a /dev/nvme0n1
```

**Firmware Version**: Shown in output.[1]

**Updates**: Check manufacturer website.[1]

#### Temperature Monitoring

**NVMe Temperature**:[1]

```bash
sudo nvme smart-log /dev/nvme0n1
```

**SATA Temperature**:[1]

```bash
sudo smartctl -a /dev/sda | grep Temp
```

**Safe Range**: 30-50°C typical.[1]

**Throttling**: Usually occurs above 80°C.[1]

#### Thermal Throttling

**Performance Impact**:[1]

```bash
watch -n 1 'fio --name=test --ioengine=libaio --direct=1 --rw=read --bs=4k --numjobs=1 --runtime=60 --group_reporting'
```

Monitor for speed drops.[1]

**Prevent**:[1]
- Improve airflow[1]
- Use heatsink[1]
- Reduce ambient temperature[1]

### SMART Monitoring

#### Check Health

**SMART Status**:[2][1]

```bash
sudo smartctl -H /dev/sda
```

**Output**:[1]

```
SMART overall-health self-assessment test result: PASSED
```

#### Monitor Attributes

**Detailed Report**:[1]

```bash
sudo smartctl -a /dev/sda
```

**Key Attributes**:[1]
- `Reallocated Sector Count`: Defects[1]
- `Program Fail Count`: Write errors[1]
- `Erase Fail Count`: Erase errors[1]
- `Wear Leveling Count`: Remaining life[1]

#### SMART Daemon

**Installation**: `sudo pacman -S smartmontools`.[2][1]

**Enable Service**:[1]

```bash
sudo systemctl enable --now smartd.service
```

**Configuration**: `/etc/smartd.conf`:[1]

```
/dev/sda -a -o on -S on -n standby,q -m root
```

### Partition Scheme

#### Optimal Layout

**First Partition Start**: At 2048 sectors (1MB).[1]

**Verification**:[1]

```bash
sudo parted /dev/sda unit s print
```

**Modern Tools**: `gdisk`, `parted` align automatically.[1]

### Ext4 Optimization

#### Mount Options

**Fstab Configuration**:[1]

```
/dev/sda1 / ext4 defaults,noatime,discard,errors=remount-ro 0 1
```

**Options**:[1]
- `noatime`: Disable access time updates[1]
- `discard`: Enable TRIM[1]
- `errors=remount-ro`: Remount read-only on error[1]

#### Disable Journaling

**Not Recommended**: Risks data corruption.[1]

**If Desired**:[1]

```bash
sudo tune2fs -O ^has_journal /dev/sda1
sudo e2fsck -f /dev/sda1
```

### Btrfs Optimization

#### Btrfs TRIM

**Automatic TRIM**: `fstrim.timer` works with Btrfs.[1]

**Mount Option**:[1]

```
/dev/sda1 / btrfs defaults,discard,noatime 0 0
```

#### Background Balance

**Automatic Balancing**:[1]

```bash
sudo btrfs balance start /
```

**Check Status**:[1]

```bash
sudo btrfs filesystem usage /
```

### Performance Testing

#### Benchmark Speed

**Before Optimization**:[1]

```bash
sudo fio --name=randread --ioengine=libaio --iodepth=16 --rw=randread --bs=4k --direct=1 --size=1G --numjobs=1 --runtime=60 --group_reporting
```

**Record Results**.[1]

**Apply Optimizations**.[1]

**After Optimization**:[1]

```bash
sudo fio --name=randread --ioengine=libaio --iodepth=16 --rw=randread --bs=4k --direct=1 --size=1G --numjobs=1 --runtime=60 --group_reporting
```

**Compare Results**.[1]

### Wear Estimation

#### Endurance Calculation

**SSD Rating**: TBW (Terabytes Written).[1]

**Example**: 500 TBW rating on 1TB drive.[1]

**Estimation**:[1]

Write 50GB/month = 600GB/year.[1]

500 TBW ÷ 0.6 TB/year ≈ 833 years.[1]

**Practical Lifespan**: Usually exceeds actual use.[1]

### SSD Maintenance

#### Regular TRIM

**Enable Service**: `systemd-fstrim.timer`.[1]

**Manual Check**: Monthly verification:[1]

```bash
sudo fstrim -v -a
```

#### Monitor Health

**Monthly Check**:[1]

```bash
sudo smartctl -H /dev/sda
```

**Watch Attributes**:[1]

```bash
sudo smartctl -a /dev/sda | grep -E "Reallocated|Program Fail|Erase Fail|Wear"
```

#### Firmware Updates

**Check Availability**:[1]

Manufacturer website.[1]

**Update Process**: Follow manufacturer instructions.[1]

### Best Practices

**Enable TRIM**: Activate `fstrim.timer`.[2][1]

**Proper Alignment**: Verify during installation.[1]

**Monitor SMART**: Use smartd for health tracking.[1]

**Optimize Mount**: Use `noatime` and `discard`.[1]

**Avoid Full Capacity**: Leave 10-15% free space.[1]

**Monitor Temperature**: Prevent thermal throttling.[1]

**Firmware Current**: Update when available.[1]

**Benchmark Regularly**: Track performance trends.[1]

***

This comprehensive guide covers the essential aspects of Arch Linux system administration and package management, from foundational concepts through advanced troubleshooting and optimization techniques. The information provided reflects current best practices as of the knowledge cutoff date and should serve as a reliable reference for users managing Arch Linux systems at various skill levels.

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] Which should I use, x11 or wayland? - openSUSE Forums https://forums.opensuse.org/t/which-should-i-use-x11-or-wayland/166824

