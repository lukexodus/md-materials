## Locale, Timezone, and Hostname Setup


### Locale Configuration

**Overview**: Locales determine region-specific formatting for dates, times, currency, decimal separators, and language display. Proper locale configuration ensures applications display information correctly for the user's region.[1][2]

#### Enabling Locales

**Configuration File**: `/etc/locale.gen` lists all available locales. By default, all locales are commented out.[3][1]

**Enable Locales**: Edit `/etc/locale.gen` using a text editor and uncomment desired UTF-8 locales by removing the `#` character:[4][1]

```
#en_US.UTF-8 UTF-8     →  en_US.UTF-8 UTF-8
#de_DE.UTF-8 UTF-8     →  de_DE.UTF-8 UTF-8
#ja_JP.UTF-8 UTF-8     →  ja_JP.UTF-8 UTF-8
```

**Recommended Locales**: Install at least one UTF-8 locale; most systems use `en_US.UTF-8` as the default.[1][3]

**Common UTF-8 Locales**:[1]
- `en_US.UTF-8 UTF-8`: American English
- `en_GB.UTF-8 UTF-8`: British English
- `de_DE.UTF-8 UTF-8`: German
- `fr_FR.UTF-8 UTF-8`: French
- `es_ES.UTF-8 UTF-8`: Spanish
- `ja_JP.UTF-8 UTF-8`: Japanese
- `zh_CN.UTF-8 UTF-8`: Simplified Chinese
- `ru_RU.UTF-8 UTF-8`: Russian

#### Generate Locales

**Command**: `locale-gen`.[3][4][1]

This command processes `/etc/locale.gen` and generates locale data files in `/usr/share/locale/`. Warnings about available locales can be ignored.[1]

#### Set Default Locale

**Configuration File**: Create `/etc/locale.conf` with the default system locale:[4][3][1]

```
LANG=en_US.UTF-8
LC_COLLATE=C.UTF-8
```

**Parameters**:[1]
- **`LANG`**: Primary language and locale for all `LC_*` variables not explicitly set[1]
- **`LC_COLLATE=C.UTF-8`**: Optional; specifies C locale for sorting to avoid unexpected behavior[1]

**Alternative Format**:[3]

```
echo LANG=en_US.UTF-8 > /etc/locale.conf
```

#### Verify Locale

**Current Session**: `locale` displays all locale variables.[2]

**Installed Locales**: `locale -a` lists all available locales.[1]

### Console Keyboard Layout (Optional)

**Configuration File**: `/etc/vconsole.conf` sets keyboard layout for the virtual console (non-graphical environment):[3][1]

```
KEYMAP=de-latin1
FONT=
FONT_MAP=
```

**Parameters**:[1]
- **`KEYMAP`**: Keyboard layout identifier (examples: `us`, `de-latin1`, `fr`, `uk`)[1]
- **`FONT`**: Console font (optional; defaults to Lat2-Terminus16)[1]
- **`FONT_MAP`**: Font mapping (optional)[1]

**Find Available Keymaps**: `ls /usr/share/kbd/keymaps/`.[1]

**Note**: This configuration only affects the console; X11 and Wayland require separate keyboard configuration.[1]

### Timezone Configuration

**Overview**: System timezone determines local time conversion from UTC and affects time-dependent operations.[2][1]

#### Set Timezone

**Command**: `ln -sf /usr/share/zoneinfo/Region/City /etc/localtime`.[5][1]

**Example**: `ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime`.[5][2]

**Parameters**:
- **`-sf`**: Create symbolic link, forcing overwrite if target exists[1]
- **`Region/City`**: Timezone identifier from zoneinfo database[1]

#### Find Timezone

**Available Timezones**: `timedatectl list-timezones`.[2][5][1]

**Browse Manually**: `ls -la /usr/share/zoneinfo/` explores timezone files.[1]

**Search**: `timedatectl list-timezones | grep -i city` searches for specific locations [1].

#### Hardware Clock Synchronization

**Command**: `hwclock --systohc`.[5][1]

This command synchronizes the hardware clock to the system clock. The hardware clock stores time even when the system is powered off.[5][1]

**UTC Assumption**: By default, `hwclock --systohc` assumes the hardware clock is set to UTC.[1]

**Local Time**: For systems using local time on hardware clock, use `hwclock --systohc --localtime`.[5]

#### Verification

**Check Current Time**: `timedatectl` displays timezone and time information.[5][1]

**Output Example**:[5]

```
               Local time: Wed 2024-01-10 12:34:56 EST
           Universal time: Wed 2024-01-10 17:34:56 UTC
                 RTC time: Wed 2024-01-10 17:34:56
```

#### NTP Synchronization (Optional)

**Enable Service**: `systemctl enable --now systemd-timesyncd`.[5][1]

This daemon automatically synchronizes system time with NTP servers, ensuring accuracy.[1]

**Verify**: `timedatectl status` shows NTP synchronization status.[5]

### Hostname Configuration

**Overview**: Hostname identifies the system on the network and is displayed in terminal prompts and application titles.[3][1]

#### Set Hostname

**Configuration File**: Create `/etc/hostname` containing only the hostname:[3][1]

```
myhostname
```

**Command**: `echo myhostname > /etc/hostname`.[4][3][1]

**Hostname Requirements** (RFC 1178):[1]
- 1-63 characters maximum length[1]
- Contains only lowercase `a` to `z`, digits `0` to `9`, and hyphens `-`[1]
- Does not start with `-`[1]
- Does not end with `-`[1]

#### Network Hostname Mapping

**Configuration File**: `/etc/hosts` maps hostnames to IP addresses for local hostname resolution:[3][1]

```
127.0.0.1       localhost
::1             localhost
127.0.1.1       myhostname.localdomain myhostname
```

**Entries**:[1]
- **`127.0.0.1 localhost`**: IPv4 loopback[1]
- **`::1 localhost`**: IPv6 loopback[1]
- **`127.0.1.1 myhostname.localdomain myhostname`**: Local hostname mapping[1]

**FQDN Format**: The fully qualified domain name (FQDN) format `hostname.localdomain` is conventional.[1]

#### Verify Hostname

**Command**: `hostnamectl` displays current hostname and system information.[2][3]

**Alternative**: `cat /etc/hostname` displays the hostname directly.[1]

**Hostname Resolution**: `hostname -f` attempts to resolve the FQDN.[1]

### Coordinated Configuration Example

**Complete Setup Session**:[3]

```bash
# Generate locales
nano /etc/locale.gen       # Uncomment desired locales
locale-gen

# Set default locale
echo LANG=en_US.UTF-8 > /etc/locale.conf

# Set timezone
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc

# Set keyboard layout (optional)
echo KEYMAP=us > /etc/vconsole.conf

# Set hostname
echo myhostname > /etc/hostname

# Update hosts file
cat > /etc/hosts << EOF
127.0.0.1       localhost
::1             localhost
127.0.1.1       myhostname.localdomain myhostname
EOF

# Enable NTP
systemctl enable systemd-timesyncd
```

### Important Considerations

**Language Support**: Installing additional locales enables language-specific sorting, formatting, and character handling.[1]

**UTF-8 Priority**: UTF-8 is the standard encoding; non-UTF-8 locales are legacy and should be avoided.[1]

**Persistent Changes**: All changes in this section persist across reboots.[3]

**Application Locale**: Individual users can override system locale by setting `LANG` and related variables in shell configuration files.[2]

Sources
[1] Installation guide - ArchWiki https://wiki.archlinux.org/title/Installation_guide
[2] How to Set the System Timezone on Arch Linux https://www.siberoloji.com/how-to-set-the-system-timezone-on-arch-linux/
[3] Arch Linux Installation: Easy Step-by-Step Guide https://linuxconfig.org/arch-linux-installation-easy-step-by-step-guide
[4] Arch installation guide - chroot steps : r/archlinux https://www.reddit.com/r/archlinux/comments/1ipehvf/arch_installation_guide_chroot_steps/
[5] System time - ArchWiki https://wiki.archlinux.org/title/System_time

