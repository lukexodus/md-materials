## Mirror Optimization (reflector, rankmirrors)


### Mirror System Overview

**Purpose**: Arch Linux distributes packages through geographically diverse mirror servers worldwide. Mirror optimization improves download speeds and reliability by selecting mirrors closest to the user's location with low latency.[1][2]

**Mirror List**: `/etc/pacman.d/mirrorlist` contains all available mirrors, with most commented out by default.[1]

**Mirror Structure**: Mirrors follow the standard path structure `https://mirror-domain/$repo/$arch/` for accessing repositories.[1]

### reflector Tool

**Overview**: Reflector is a Python utility that automatically ranks mirrors based on geographic location, synchronization status, and download speed.[2][1]

**Installation**: `sudo pacman -S reflector`.[2][1]

**Official Status**: Reflector is maintained by the Arch Linux team.[1]

#### Basic reflector Usage

**Simple Optimization**: `sudo reflector --country 'United States' --latest 12 --sort rate --save /etc/pacman.d/mirrorlist`.[1]

**Parameters**:[2][1]
- **`--country 'Country Name'`**: Filters mirrors by country; use quotes for multi-word names[1]
- **`--latest 12`**: Selects mirrors updated within last 12 hours[1]
- **`--sort rate`**: Sorts by download speed (fastest first)[1]
- **`--save [path]`**: Saves optimized list to specified location[1]

#### Advanced reflector Options

**Multiple Countries**: `sudo reflector --country 'United States' --country Canada --latest 12 --sort rate --save /etc/pacman.d/mirrorlist`.[2]

**Age-Based Selection**: `--age 6` selects mirrors updated within 6 hours.[2]

**Sort Options**:[2]
- **`--sort rate`**: Fastest first[2]
- **`--sort delay`**: Lowest latency first[2]
- **`--sort score`**: Highest score first (default)[2]

**Timeout Setting**: `--timeout 5` sets HTTP request timeout in seconds.[2]

**Number of Mirrors**: `--latest 20` or other numbers control how many mirrors are included.[1][2]

**Save to Temporary**: `--save -` prints results to stdout without saving.[2]

#### Country Code Reference

**Common Country Codes**:[1][2]
- `'United States'`: U.S. mirrors[1]
- `'Germany'`: German mirrors[1]
- `'France'`: French mirrors[1]
- `'United Kingdom'`: UK mirrors[1]
- `'Australia'`: Australian mirrors[1]
- `'Japan'`: Japanese mirrors[1]

**Full Country List**: `reflector --list-countries` displays all available countries.[2]

#### Backup Current Mirrorlist

**Save Backup**: `sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup`.[1]

**Restore if Needed**: `sudo cp /etc/pacman.d/mirrorlist.backup /etc/pacman.d/mirrorlist`.[1]

### rankmirrors Tool

**Overview**: Rankmirrors is a legacy utility ranking mirrors based on actual speed testing by downloading a small test file.[2]

**Origin**: Part of the Arch Linux scripts package.[2]

**Installation**: `sudo pacman -S arch-install-scripts`.[2]

#### rankmirrors Usage

**Basic Ranking**: `rankmirrors /etc/pacman.d/mirrorlist > /tmp/mirrorlist.ranked && sudo mv /tmp/mirrorlist.ranked /etc/pacman.d/mirrorlist`.[2]

**Parameters**:[2]
- First argument: Path to mirrorlist file[2]
- Output: Ranked mirrors in order of speed[2]

**Direct Testing**: `rankmirrors -n 5 /etc/pacman.d/mirrorlist` tests top 5 mirrors.[2]

**Time-Intensive**: Rankmirrors performs actual downloads for testing, making it slower than reflector.[2]

### Comparison: reflector vs rankmirrors

| Feature | reflector | rankmirrors |
|---------|-----------|-------------|
| **Speed** | Fast (uses metadata) [2] | Slow (downloads test files) [2] |
| **Accuracy** | Metadata-based [2] | Actual speed testing [2] |
| **Geographic Filtering** | Yes [1] | Limited [2] |
| **Synchronization Check** | Yes [1] | No [2] |
| **Country Selection** | Multiple countries [2] | Single file [2] |
| **Automation** | Suitable for scripting [2] | Less suitable [2] |
| **Maintenance** | Actively maintained [1] | Legacy [2] |

### Systemd Service Integration

**Automatic Optimization**: Set up reflector to run automatically via systemd.[2]

**Service File**: Create `/etc/systemd/system/reflector.service`:[2]

```
[Unit]
Description=Arch Linux Repository Mirror Ranking
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/bin/reflector --country 'United States' --latest 12 --sort rate --save /etc/pacman.d/mirrorlist

[Install]
WantedBy=multi-user.target
```

**Timer Unit**: Create `/etc/systemd/system/reflector.timer` for periodic execution:[2]

```
[Unit]
Description=Run Reflector Hourly

[Timer]
OnBootSec=1min
OnUnitActiveSec=1h
Persistent=true

[Install]
WantedBy=timers.target
```

**Enable Services**:[2]
```
sudo systemctl enable --now reflector.timer
```

### Manual Mirror List Editing

**Edit Mirrorlist**: `sudo nano /etc/pacman.d/mirrorlist` allows manual editing.[1]

**Uncomment Mirrors**: Remove `#` from preferred mirrors to enable them.[1]

**Mirror Order**: Mirrors at the beginning of the file are prioritized.[1]

**Format**: Each mirror line follows:[1]

```
Server = https://mirror.example.com/$repo/os/$arch
```

### Default Mirror Configuration

**Initial State**: Official installation media include pre-sorted mirrors by download speed.[1]

**Limited Set**: Typically, 10-15 mirrors are uncommented by default.[1]

**Optimization Still Recommended**: Even default mirrors benefit from reflector optimization for individual location.[1]

### Geolocation-Based Selection

**Automatic Country Detection**: Some tools detect user geolocation automatically.[2]

**Manual Selection**: For predictable configuration, explicitly specify country.[1]

**Fallback Mirrors**: Include at least one mirror from alternative country for redundancy.[2]

### Testing Mirror Speed

**Test Specific Mirror**: `wget -O /dev/null https://mirror.example.com/core/os/x86_64/core.db` tests download speed.[2]

**Timing**: `time wget` displays elapsed time.[2]

**Download Large File**: Test with repository database file for realistic speed.[2]

### Best Practices

**Regular Optimization**: Run `reflector` monthly to maintain optimal mirror selection.[1]

**Backup Original**: Always backup `/etc/pacman.d/mirrorlist` before making changes.[1]

**Multiple Mirrors**: Include at least 3-5 mirrors for redundancy.[2]

**Consistent Speed**: Choose mirrors with consistent uptime and synchronization.[1]

**Geographic Diversity**: Select mirrors from different locations within country when possible.[2]

**Document Choice**: Add comments explaining mirror selection reasoning.[1]

### Troubleshooting Mirror Issues

**Slow Downloads**: Re-run reflector with different parameters.[1]

**Connection Failures**: Test mirror directly with browser or wget.[2]

**Out-of-Sync Mirrors**: Reflector automatically filters mirrors older than specified threshold.[1]

**Regional Issues**: If country-specific mirrors fail, select larger geographic regions.[1]

Sources
[1] Comprehensive Arch Linux Installation Guide https://www.liquidweb.com/blog/arch-linux-installation-guide/
[2] Arch Linux Installation: Easy Step-by-Step Guide https://linuxconfig.org/arch-linux-installation-easy-step-by-step-guide

