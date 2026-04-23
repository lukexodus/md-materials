# Linux Mastery Path — Arch Focus

### Administration · Troubleshooting · Productivity Workflow

_From competent to expert. 16–24 weeks._

---

## How to Use This Guide

Each phase builds on the last. Don't skip phases — the later ones assume muscle memory from earlier ones. Estimate 5–10 hrs/week of deliberate practice. Every command listed should be run, broken, and run again.

**Notation:**

- `[Practice]` — run this now, not later
- `[Milestone]` — checkpoint before moving on
- `[Arch-specific]` — differs from Debian/RHEL

---

## Phase 0 — Orientation (Week 1)

_Know what you have before you touch anything_

### The Arch Philosophy

Arch is a rolling release, minimalist distro. Nothing is installed you didn't ask for. Everything is documented in the Arch Wiki — treat it as your primary reference, not a fallback.

```bash
# Who am I, where am I
whoami
id
hostname
uname -a            # kernel version
cat /etc/os-release # distro info
```

### Filesystem Map

```
/           root of everything
/etc        system-wide config files (edit here often)
/var        variable data: logs, caches, databases
/home       user home dirs
/usr        user-space binaries, libraries, headers
/usr/local  manually installed software (non-pacman)
/opt        self-contained third-party apps
/proc       virtual: live kernel/process info
/sys        virtual: hardware and kernel state
/dev        device files (disks, terminals, etc.)
/run        runtime data (PIDs, sockets) — gone on reboot
/tmp        temporary files — gone on reboot
/boot       kernel, initramfs, bootloader
/mnt /media mount points
```

`[Practice]` Run `ls -la /` and `man hier` — read the filesystem hierarchy man page end to end.

### Shell Basics You Must Internalize

```bash
# Navigation
cd -            # go back to previous dir
pushd /etc      # push to stack
popd            # pop back
dirs            # show stack

# History
!!              # repeat last command
!$              # last argument of previous command
!^              # first argument of previous command
ctrl+r          # reverse search history
history | grep ssh

# Redirection
cmd > file      # stdout to file (overwrite)
cmd >> file     # stdout to file (append)
cmd 2> err.log  # stderr only
cmd &> all.log  # stdout + stderr
cmd 2>&1        # redirect stderr to stdout

# Pipes and logic
cmd1 | cmd2     # pipe stdout of 1 into stdin of 2
cmd1 && cmd2    # run cmd2 only if cmd1 succeeds
cmd1 || cmd2    # run cmd2 only if cmd1 fails
cmd1 ; cmd2     # run both regardless

# Subshells
$(cmd)          # command substitution
(cmd1; cmd2)    # subshell group
{ cmd1; cmd2; } # current shell group
```

`[Milestone]` You can navigate the filesystem blindfolded, pipe two commands together without thinking, and explain what `2>&1` means.

---

## Phase 1 — System Management (Weeks 2–3)

_Own your init system_

### systemctl — The Full Picture

```bash
# Unit states
systemctl status nginx
systemctl is-active nginx
systemctl is-enabled nginx
systemctl is-failed nginx

# Lifecycle
systemctl start / stop / restart / reload nginx
systemctl enable / disable nginx           # persist across boots
systemctl enable --now nginx               # enable + start in one
systemctl mask nginx                       # prevent start (even manually)
systemctl unmask nginx

# Exploration
systemctl list-units --type=service
systemctl list-units --state=failed
systemctl list-units --state=inactive
systemctl list-unit-files                  # all installed units
systemctl list-dependencies nginx          # dependency tree

# System-level
systemctl poweroff / reboot / suspend / hibernate
systemctl daemon-reload                    # after editing unit files
systemctl reset-failed                     # clear failed state
```

### Writing Unit Files

```ini
# /etc/systemd/system/myapp.service
[Unit]
Description=My Application
After=network.target

[Service]
Type=simple
User=myuser
WorkingDirectory=/opt/myapp
ExecStart=/opt/myapp/bin/server
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=5s
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

```bash
systemctl daemon-reload
systemctl enable --now myapp
```

Unit types to know: `.service`, `.timer`, `.socket`, `.mount`, `.target`, `.path`

### Targets (Runlevels)

```bash
systemctl get-default               # current default target
systemctl set-default multi-user.target
systemctl isolate rescue.target     # drop to rescue mode (careful)
```

|Target|Old Runlevel|
|---|---|
|poweroff.target|0|
|rescue.target|1|
|multi-user.target|3|
|graphical.target|5|
|reboot.target|6|

### journalctl — Full Mastery

```bash
# Basic views
journalctl                        # all logs (oldest first)
journalctl -r                     # reverse (newest first)
journalctl -f                     # follow (like tail -f)
journalctl -e                     # jump to end
journalctl -n 50                  # last 50 lines

# Filtering by unit
journalctl -u nginx
journalctl -u nginx -u php-fpm    # multiple units
journalctl -u nginx -f            # follow specific unit

# Filtering by time
journalctl --since "2024-01-15 09:00:00"
journalctl --since "1 hour ago"
journalctl --since today
journalctl --since yesterday --until "09:00"
journalctl -b                     # current boot
journalctl -b -1                  # previous boot
journalctl --list-boots           # list all boot sessions

# Filtering by priority
journalctl -p err                 # errors and above
journalctl -p warning..err        # range
# Priorities: emerg alert crit err warning notice info debug

# Filtering by process/PID/UID
journalctl _PID=1234
journalctl _UID=1000
journalctl _COMM=nginx            # by executable name
journalctl /usr/bin/nginx         # by binary path

# Output formats
journalctl -o json
journalctl -o json-pretty
journalctl -o verbose
journalctl -o short-precise       # microsecond timestamps
journalctl -o cat                 # message only, no metadata

# Kernel messages
journalctl -k                     # kernel ring buffer (like dmesg)
journalctl -k -b -1               # kernel logs from last boot

# Disk usage + cleanup
journalctl --disk-usage
journalctl --vacuum-size=500M
journalctl --vacuum-time=2weeks
```

### systemd-analyze — Boot Performance

```bash
systemd-analyze                   # total boot time
systemd-analyze blame             # time per unit (sorted)
systemd-analyze critical-chain    # the critical path
systemd-analyze plot > boot.svg   # visual timeline
systemd-analyze verify /etc/systemd/system/myapp.service
systemd-analyze security nginx.service  # security score
```

`[Milestone]` You can start/stop/write a unit, follow its logs in real time, filter journal output to exactly what you need, and read a boot blame output.

---

## Phase 2 — Package Management (Week 3)

_pacman + AUR fluency_

### pacman Core Operations

```bash
# Sync and update
pacman -Sy              # sync package databases
pacman -Su              # upgrade installed packages
pacman -Syu             # sync + upgrade (standard update)
pacman -Syuu            # allow downgrades (use with care)

# Install / remove
pacman -S package
pacman -S package1 package2
pacman -R package                  # remove (keep deps)
pacman -Rs package                 # remove + unused deps
pacman -Rns package                # remove + deps + config files

# Query local DB
pacman -Q                          # list all installed
pacman -Qs keyword                 # search installed
pacman -Qi package                 # detailed info
pacman -Ql package                 # list owned files
pacman -Qo /usr/bin/vim            # who owns this file

# Query remote DB
pacman -Ss keyword                 # search repos
pacman -Si package                 # remote package info

# Orphans and cleanup
pacman -Qdt                        # list orphaned packages
pacman -Rns $(pacman -Qdtq)        # remove all orphans
pacman -Sc                         # clean old package cache
pacman -Scc                        # clean entire cache

# Verify installation
pacman -Qk package                 # check file integrity
pacman -Qkk package                # stricter check
```

### pacman.conf — Key Settings

```ini
# /etc/pacman.conf
[options]
Color
ParallelDownloads = 5     # parallel downloads (Arch 6.0+)
VerbosePkgLists           # side-by-side diff on upgrade

# Repos — order matters
[core]
[extra]
[multilib]                # 32-bit support
```

### AUR with paru (or yay)

```bash
# Install paru [Arch-specific]
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/paru.git
cd paru && makepkg -si

# paru usage (mirrors pacman flags)
paru -Syu                 # update everything including AUR
paru -S package-name-bin  # install AUR package
paru -Ss keyword          # search AUR
paru -Gc package          # show PKGBUILD (always read this)
paru --fm nano -S package # review PKGBUILD in editor before install
```

**Security habit:** Always read the PKGBUILD before installing AUR packages.

### makepkg — Build from Source

```bash
git clone https://aur.archlinux.org/package.git
cd package
cat PKGBUILD                        # read it
makepkg -si                         # build + install deps + install
makepkg -si --noconfirm             # non-interactive
makepkg --printsrcinfo              # debug
```

`[Milestone]` You can update the full system, remove orphans, find what package owns a file, and install from the AUR with PKGBUILD review.

---

## Phase 3 — Networking (Weeks 4–5)

_ip suite, ss, DNS, firewall_

### The ip Command Suite (Replacing ifconfig/route/arp)

```bash
# Interfaces
ip link show                       # list all interfaces
ip link show dev eth0
ip link set eth0 up / down
ip link set eth0 mtu 9000

# Addresses
ip addr show
ip addr show dev eth0
ip addr add 192.168.1.50/24 dev eth0
ip addr del 192.168.1.50/24 dev eth0

# Routing
ip route show
ip route show table all
ip route add default via 192.168.1.1
ip route add 10.0.0.0/8 via 192.168.1.254 dev eth0
ip route del 10.0.0.0/8
ip route get 8.8.8.8               # what route would this take?

# Neighbors (ARP table)
ip neigh show
ip neigh flush dev eth0

# Statistics
ip -s link show eth0               # TX/RX bytes, errors, drops
ip -s -s link show eth0            # more detail
```

### ss — Socket Statistics (Replacing netstat)

```bash
# Overview
ss -s                              # summary stats

# Common flags
# -t TCP, -u UDP, -l listening, -a all, -n numeric, -p with process

ss -tulpn                          # listening sockets + processes (most useful)
ss -tulpn | grep :80
ss -tnp                            # established TCP connections
ss -tnp state established
ss -tnp state time-wait
ss -unp                            # UDP sockets

# Filter by port/address
ss -tnp '( dport = :22 or sport = :22 )'
ss -tnp dst 192.168.1.1
ss src 192.168.1.100

# Socket memory info
ss -tm
```

### NetworkManager (Desktop/Arch default)

```bash
nmcli device status
nmcli connection show
nmcli connection show "MyWifi"
nmcli device wifi list
nmcli device wifi connect "SSID" password "pass"
nmcli connection up / down "connection-name"
nmcli connection modify "connection-name" ipv4.addresses 192.168.1.50/24
nmcli connection modify "connection-name" ipv4.method manual
nmcli connection modify "connection-name" ipv4.dns "1.1.1.1 8.8.8.8"
nmcli general reload                # reload after config edit
```

### DNS Diagnostics

```bash
# Basic lookup
dig google.com
dig google.com A
dig google.com MX
dig google.com @8.8.8.8            # query specific server
dig +short google.com              # short output
dig +trace google.com              # full delegation trace

# Reverse lookup
dig -x 8.8.8.8
host 8.8.8.8

# systemd-resolved [Arch-specific]
resolvectl status
resolvectl query google.com
resolvectl statistics
resolvectl flush-caches
cat /etc/resolv.conf               # should symlink to stub resolver
```

### nftables — Firewall (Modern iptables Replacement)

```bash
# Check current ruleset
nft list ruleset

# Basic stateful firewall example
# /etc/nftables.conf
table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;
        ct state established,related accept
        ct state invalid drop
        iif lo accept
        ip protocol icmp accept
        tcp dport 22 accept
        tcp dport { 80, 443 } accept
    }
    chain forward {
        type filter hook forward priority 0; policy drop;
    }
    chain output {
        type filter hook output priority 0; policy accept;
    }
}

systemctl enable --now nftables
nft -f /etc/nftables.conf          # load ruleset
```

### Connectivity Diagnostics Workflow

```bash
ping -c 4 8.8.8.8                  # layer 3 reachability
ping -c 4 google.com               # DNS + L3
traceroute google.com              # path tracing
mtr google.com                     # live traceroute (install mtr)
curl -I https://google.com         # HTTP response headers
curl -v https://google.com         # full verbose HTTP
nc -zv host 80                     # port check
nmap -p 80,443 host                # port scan
ss -tulpn | grep :80               # is something listening?
```

`[Milestone]` You can configure a static IP with `ip` or `nmcli`, diagnose DNS failures end-to-end, see what's listening on a port, and load a basic nftables ruleset.

---

## Phase 4 — Process & Resource Management (Week 5)

_See everything the system is doing_

### Process Tools

```bash
# ps — snapshot
ps aux                             # all processes, BSD style
ps -ef                             # all processes, POSIX style
ps aux | grep nginx
ps -p 1234 -o pid,ppid,cmd,%cpu,%mem
ps --forest                        # process tree
ps -u username                     # processes by user

# pgrep/pkill
pgrep nginx                        # find PID by name
pgrep -u root sshd
pkill nginx                        # send SIGTERM by name
pkill -9 nginx                     # send SIGKILL
pkill -u username                  # kill all by user
kill -l                            # list signals
kill -SIGTERM 1234
kill -9 1234                       # SIGKILL (unblockable)
kill -HUP 1234                     # reload config (many daemons)

# Process tree
pstree
pstree -p                          # with PIDs
pstree -u                          # with users
```

### htop — Interactive Process Viewer

```bash
htop
# Inside htop:
# F2 = setup, F3 = search, F4 = filter, F5 = tree view
# F6 = sort, F9 = kill, F10 = quit
# Space = tag process, U = untag all
# k = kill tagged, t = tree mode toggle
```

**Key columns:** PID, USER, PRI, NI (nice value), VIRT (virtual mem), RES (resident mem), SHR, S (state), %CPU, %MEM, TIME+, COMMAND

### Memory Deep Dive

```bash
free -h                            # overview (human readable)
free -h -s 2                       # refresh every 2s

# /proc/meminfo — detailed
cat /proc/meminfo
grep -E "MemTotal|MemFree|MemAvailable|Cached|SwapTotal|SwapFree" /proc/meminfo

# vmstat — virtual memory + CPU stats
vmstat 1 10                        # 10 samples, 1s interval
# Columns: r(run queue) b(blocked) swpd free buff cache si so bi bo in cs us sy id wa st

# per-process memory
cat /proc/PID/status | grep -i vm
pmap -x PID                        # detailed memory map
```

### Disk & I/O

```bash
# Disk space
df -h                              # all filesystems
df -h /home                        # specific mount
df -i                              # inodes (not blocks)

# Disk usage
du -sh /var                        # size of dir
du -sh /*                          # top-level breakdown
du -h --max-depth=1 /var
du -ah /etc | sort -rh | head -20  # largest files in /etc

# I/O monitoring
iostat                             # install sysstat
iostat -xz 1                       # extended, 1s interval
iotop                              # per-process I/O (run as root)
iotop -o                           # only processes doing I/O

# Block devices
lsblk                              # tree of block devices
lsblk -f                           # with filesystems
blkid                              # UUIDs and types
fdisk -l                           # partition tables (root)
```

### CPU & Load

```bash
uptime                             # load averages (1, 5, 15 min)
nproc                              # CPU count
lscpu                              # CPU architecture details

# Load average interpretation:
# Load = 1.0 on single core = 100% utilized
# Load = 4.0 on 4 cores = 100% all cores
# Rule of thumb: sustained load > nproc = system is overloaded

top -b -n 1 | head -20             # non-interactive snapshot
mpstat -P ALL 1                    # per-CPU stats (sysstat)
```

### lsof — What's Open

```bash
lsof                               # everything (noisy)
lsof -p PID                        # files open by process
lsof -u username                   # files open by user
lsof /var/log/nginx/access.log     # who has this file open
lsof -i :80                        # process using port 80
lsof -i TCP:22                     # TCP port 22
lsof -i @192.168.1.1               # connections to IP
```

`[Milestone]` You can identify top memory/CPU consumers, trace I/O bottlenecks, find what process owns a port, and interpret load averages correctly.

---

## Phase 5 — File Operations Mastery (Week 6)

_find, grep, text processing, permissions_

### find — Surgical File Location

```bash
# Basic
find /etc -name "*.conf"
find /var/log -name "*.log" -type f
find /home -type d -name ".ssh"

# By modification time
find /var/log -mtime -1            # modified in last 24h
find /tmp -mtime +7                # older than 7 days
find /etc -newer /etc/passwd       # newer than reference file

# By size
find / -size +100M -type f
find /var -size +50M -size -500M

# By permissions
find / -perm -4000 -type f         # SUID files (security audit)
find / -perm -2000 -type f         # SGID files
find /home -perm 777               # world-writable

# By owner
find /var -user www-data
find /tmp -nouser                  # no owner (orphaned)

# Execute actions
find /tmp -name "*.tmp" -delete
find /var/log -name "*.log" -exec ls -lh {} \;
find /var/log -name "*.log" -exec gzip {} \;
find . -type f -exec chmod 644 {} \;

# Combining conditions
find /etc -name "*.conf" -not -name "locale*"
find /var -type f -size +10M -mtime -7
```

### grep — Pattern Mastery

```bash
grep "error" /var/log/syslog
grep -i "error" file               # case insensitive
grep -r "pattern" /etc/            # recursive
grep -r "pattern" /etc/ -l        # only filenames
grep -r "pattern" /etc/ -n        # with line numbers
grep -v "debug" logfile            # invert match
grep -c "error" logfile            # count matches
grep -A 3 "error" logfile          # 3 lines after match
grep -B 3 "error" logfile          # 3 lines before
grep -C 3 "error" logfile          # 3 lines context

# Regex
grep -E "error|warning" logfile    # extended regex (ERE)
grep -P "\d{4}-\d{2}-\d{2}" file  # Perl regex
grep "^error" logfile              # starts with
grep "error$" logfile              # ends with
grep "err[oa]r" logfile            # character class
grep "err.*log" logfile            # wildcard

# With pipes
journalctl -u nginx | grep -i "warn\|error"
cat access.log | grep " 500 " | awk '{print $1}' | sort | uniq -c
```

### xargs — Turning Output into Arguments

```bash
# Basic pattern: feed input to a command as arguments
find /tmp -name "*.tmp" | xargs rm
find /var/log -name "*.log" | xargs grep -l "error"
ls *.txt | xargs wc -l

# Parallel execution
find . -name "*.jpg" | xargs -P 4 -I{} convert {} {}.webp

# Handle spaces in filenames
find . -name "*.log" -print0 | xargs -0 grep "error"

# With placeholder
cat servers.txt | xargs -I{} ssh {} uptime
```

### Text Processing Pipeline: awk, sed, sort, uniq

```bash
# awk — column manipulation
awk '{print $1, $3}' file          # print columns 1 and 3
awk -F: '{print $1}' /etc/passwd   # custom delimiter
awk '$3 > 1000' /etc/passwd        # filter by column value
awk 'NR==1,NR==10' file            # lines 1–10
awk '/error/ {count++} END {print count}' logfile

# sed — stream editor
sed 's/old/new/' file              # replace first per line
sed 's/old/new/g' file             # replace all per line
sed -i 's/old/new/g' file         # in-place edit
sed -n '5,10p' file                # print lines 5–10
sed '/^#/d' file                   # delete comment lines
sed '/^$/d' file                   # delete blank lines

# sort
sort file                          # alphabetical
sort -n file                       # numeric
sort -rn file                      # reverse numeric
sort -t: -k3 -n /etc/passwd        # sort by 3rd field (UID)
sort -u file                       # sort + deduplicate

# uniq (requires sorted input)
sort file | uniq                   # deduplicate
sort file | uniq -c                # count occurrences
sort file | uniq -d                # show only duplicates
sort file | uniq -u                # show only unique lines

# Real pipeline example: top 10 IP addresses in access.log
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -10
```

### Permissions Deep Dive

```bash
# Notation
# rwxrwxrwx = owner | group | other
# chmod with octal: 4=r, 2=w, 1=x
chmod 755 file                     # rwxr-xr-x
chmod 644 file                     # rw-r--r--
chmod 600 file                     # rw------- (private key, etc.)
chmod +x script.sh                 # add execute
chmod u+x,g-w file                 # symbolic notation

# Ownership
chown user file
chown user:group file
chown -R user:group dir/           # recursive
chgrp group file

# Special bits
chmod +s /usr/bin/program          # SUID — runs as file owner
chmod g+s directory/               # SGID — new files inherit group
chmod +t /tmp                      # sticky — only owner can delete

# umask — default permission mask
umask                              # show current
umask 022                          # new files = 644, dirs = 755
umask 027                          # new files = 640, dirs = 750

# ACLs — extended permissions
getfacl file
setfacl -m u:username:rwx file
setfacl -m g:groupname:rx file
setfacl -x u:username file        # remove entry
setfacl -b file                    # remove all ACLs
```

`[Milestone]` You can find any file by any attribute, extract columns from logs, do in-place text replacement, and explain SUID/SGID/sticky bit behavior.

---

## Phase 6 — Storage & Filesystems (Week 7)

_Disks, partitions, btrfs, LVM_

### Disk Operations

```bash
# Identify storage
lsblk -f
fdisk -l
parted -l

# Partitioning with fdisk
fdisk /dev/sdb
# Commands: m=help, p=print, n=new, d=delete, t=type, w=write, q=quit

# Formatting
mkfs.ext4 /dev/sdb1
mkfs.xfs /dev/sdb1
mkfs.fat -F 32 /dev/sdb1           # FAT32 for EFI

# Mounting
mount /dev/sdb1 /mnt/data
mount -t ext4 /dev/sdb1 /mnt/data
umount /mnt/data
umount -l /mnt/data                # lazy unmount (when busy)

# Persistent mounts via /etc/fstab
# UUID  mountpoint  type  options  dump  pass
UUID=abc123  /mnt/data  ext4  defaults,noatime  0  2
# Get UUID: blkid /dev/sdb1
# After editing fstab: mount -a (test before reboot)
```

### btrfs [Arch-specific — Common Default]

```bash
# Info
btrfs filesystem show
btrfs filesystem usage /
btrfs filesystem df /

# Subvolumes
btrfs subvolume list /
btrfs subvolume create /data/subvol
btrfs subvolume snapshot / /snapshots/root-$(date +%Y%m%d)
btrfs subvolume snapshot -r / /snapshots/root-readonly  # read-only
btrfs subvolume delete /snapshots/old-snapshot

# Scrub (data integrity check)
btrfs scrub start /
btrfs scrub status /

# Balance (redistribute data across devices)
btrfs balance start /
btrfs balance status /

# Compression
mount -o compress=zstd /dev/sda1 /   # zstd compression
# Or in fstab: UUID=... / btrfs defaults,compress=zstd 0 1
```

### LVM — Logical Volume Management

```bash
# Physical volumes
pvcreate /dev/sdb
pvs / pvdisplay

# Volume groups
vgcreate vgdata /dev/sdb
vgextend vgdata /dev/sdc
vgs / vgdisplay

# Logical volumes
lvcreate -L 50G -n lvhome vgdata
lvcreate -l 100%FREE -n lvdata vgdata
lvs / lvdisplay

# Resize
lvextend -L +20G /dev/vgdata/lvhome
resize2fs /dev/vgdata/lvhome       # ext4: resize after extend
xfs_growfs /mnt/point              # XFS: can only grow
lvreduce -L -10G /dev/vgdata/lvhome  # shrink (unmount first)
```

### SMART — Disk Health

```bash
# Install: sudo pacman -S smartmontools
smartctl -i /dev/sda               # drive info
smartctl -H /dev/sda               # health check
smartctl -a /dev/sda               # all data
smartctl -t short /dev/sda         # start short self-test
smartctl -t long /dev/sda          # start long self-test (hours)
smartctl -l selftest /dev/sda      # view test results
```

`[Milestone]` You can partition a disk, mount it persistently, create btrfs snapshots, and check SMART health on a drive.

---

## Phase 7 — Security Hardening (Week 8)

_User management, SSH, auditing_

### User and Group Management

```bash
# Users
useradd -m -s /bin/bash -G wheel username
useradd -r -s /sbin/nologin serviceuser   # system user, no shell
passwd username
usermod -aG docker username         # add to group (append)
usermod -s /bin/zsh username        # change shell
userdel -r username                 # remove + home dir

# Groups
groupadd mygroup
groupdel mygroup
gpasswd -a username mygroup
gpasswd -d username mygroup
id username                         # show user's groups
groups username

# Privilege files
visudo                              # edit sudoers safely
# /etc/sudoers.d/ — drop-in files

# Example sudoers entries:
username ALL=(ALL) ALL              # full sudo
username ALL=(ALL) NOPASSWD: ALL   # passwordless (avoid)
%wheel ALL=(ALL) ALL               # group-based
username ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx
```

### SSH Hardening

```bash
# Key generation
ssh-keygen -t ed25519 -C "user@host"
ssh-keygen -t rsa -b 4096 -C "user@host"

# Copy key to server
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@server
# Or manually: cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys

# SSH config file (~/.ssh/config)
Host myserver
    HostName 192.168.1.50
    User admin
    Port 2222
    IdentityFile ~/.ssh/id_ed25519
    ServerAliveInterval 60

# /etc/ssh/sshd_config hardening
Port 2222                          # non-standard port
PermitRootLogin no
PasswordAuthentication no          # key-only after copying keys
PubkeyAuthentication yes
AllowUsers username1 username2
MaxAuthTries 3
LoginGraceTime 30
X11Forwarding no
AllowTcpForwarding no              # unless needed

systemctl restart sshd             # apply changes
```

### File Integrity & Auditing

```bash
# Find recently changed files
find /etc -mtime -1 -type f
find / -newer /tmp/timestamp -type f 2>/dev/null

# AIDE — file integrity monitoring
# pacman -S aide
aide --init                        # create baseline DB
aide --check                       # check against baseline

# auditd — system call auditing
# pacman -S audit
systemctl enable --now auditd
auditctl -w /etc/passwd -p wa -k passwd-changes   # watch file
auditctl -l                        # list rules
ausearch -k passwd-changes         # search audit log
aureport --auth                    # authentication report
```

### Fail2ban / Automated Defense

```bash
# pacman -S fail2ban
# /etc/fail2ban/jail.local
[DEFAULT]
bantime = 1h
findtime = 10m
maxretry = 5

[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log

systemctl enable --now fail2ban
fail2ban-client status
fail2ban-client status sshd
fail2ban-client set sshd unbanip 1.2.3.4
```

`[Milestone]` You can create a service user, configure key-only SSH auth, lock down sshd_config, and watch for unauthorized file changes.

---

## Phase 8 — Advanced Troubleshooting (Weeks 9–10)

_Systematic diagnosis_

### The Diagnostic Framework

When something breaks, work through layers:

1. **What changed?** (`journalctl -b -1`, git log, pacman log)
2. **What's the error?** (`journalctl -u service -p err`, `dmesg -T | tail -50`)
3. **Is it running?** (`systemctl status`, `ps aux | grep`)
4. **Is it listening?** (`ss -tulpn | grep PORT`)
5. **Can it be reached?** (`nc -zv host port`, `curl -v`)
6. **Resource exhaustion?** (`df -h`, `free -h`, `ulimit -a`)

### strace — Syscall Tracing

```bash
strace command                     # trace from start
strace -p PID                      # attach to running process
strace -e trace=open,read,write command   # filter syscalls
strace -e trace=network command    # network calls only
strace -e trace=file command       # file ops only
strace -f command                  # follow forks
strace -o /tmp/trace.log command   # write to file
strace -T command                  # time each syscall
strace -c command                  # summary stats
```

### lsof + /proc for Deep Inspection

```bash
# What files does a process have open?
lsof -p $(pgrep nginx)

# Deleted files still held open (wasting disk)
lsof +L1                           # files with 0 link count
lsof -nP | grep deleted

# /proc filesystem
cat /proc/PID/cmdline | tr '\0' ' '  # full command
cat /proc/PID/environ | tr '\0' '\n' # environment
ls -la /proc/PID/fd                   # open file descriptors
cat /proc/PID/net/tcp                 # network connections
cat /proc/PID/limits                  # resource limits
cat /proc/PID/status                  # process status
```

### dmesg — Kernel Messages

```bash
dmesg                              # all kernel messages
dmesg -T                           # human timestamps
dmesg -H                           # human readable + colors
dmesg -T | grep -i error
dmesg -T | grep -i "oom"           # out-of-memory killer
dmesg -T | grep -i "fail\|error\|warn"
dmesg -w                           # follow (like -f)
dmesg --level=err,warn             # filter by level
```

### OOM — Out of Memory Situations

```bash
# Check if OOM killer fired
journalctl -k | grep -i "oom\|killed process"
dmesg -T | grep -i "out of memory\|oom_kill"

# OOM score (higher = more likely to be killed)
cat /proc/PID/oom_score
cat /proc/PID/oom_adj
echo -1000 > /proc/PID/oom_score_adj   # protect process

# Swap
swapon --show
mkswap /dev/sdb2
swapon /dev/sdb2
swapoff /dev/sdb2
# Swapfile
dd if=/dev/zero of=/swapfile bs=1M count=4096
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
```

### Performance Analysis Workflow

```bash
# CPU bottleneck?
top / htop                         # look at us (user) vs sy (system) vs wa (wait)
mpstat -P ALL 1 5                  # per-core utilization

# I/O bottleneck?
iostat -xz 1 5                     # look at %util, await, r/s, w/s
iotop -o                           # top I/O consumers

# Memory pressure?
free -h                            # available vs used
vmstat 1 5                         # si/so (swap in/out) > 0 = problem
cat /proc/meminfo | grep -i dirty  # dirty pages

# Network bottleneck?
ss -s                              # connection counts
ip -s link                         # errors, drops
sar -n DEV 1 5                     # network stats (sysstat)
```

`[Milestone]` You can attach strace to a running process, interpret OOM killer output, identify whether a bottleneck is CPU/IO/memory/network, and trace a process's open files.

---

## Phase 9 — Shell Scripting (Weeks 10–12)

_Automate the administration work_

### Bash Script Structure

```bash
#!/usr/bin/env bash
set -euo pipefail    # exit on error, unbound vars, pipe failures
IFS=$'\n\t'          # sane word splitting

# Logging
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >&2; }
die() { log "ERROR: $*"; exit 1; }

# Check dependencies
command -v jq >/dev/null || die "jq is required"

# Argument handling
[[ $# -lt 1 ]] && die "Usage: $0 <argument>"
INPUT="$1"
```

### Variables, Arrays, Arithmetic

```bash
# Variables
NAME="value"
READONLY_VAR="fixed"
readonly READONLY_VAR
unset NAME

# String operations
${VAR:-default}         # use default if unset
${VAR:=default}         # assign default if unset
${VAR:?error msg}       # exit with error if unset
${#VAR}                 # string length
${VAR#prefix}           # remove prefix
${VAR%suffix}           # remove suffix
${VAR/old/new}          # replace first
${VAR//old/new}         # replace all
${VAR^^}                # uppercase
${VAR,,}                # lowercase
${VAR:2:5}              # substring (pos 2, len 5)

# Arrays
arr=("a" "b" "c")
arr+=(d)                # append
${arr[0]}               # first element
${arr[@]}               # all elements
${#arr[@]}              # length
unset arr[1]            # remove element

# Associative arrays (bash 4+)
declare -A map
map["key"]="value"
${map["key"]}
${!map[@]}              # all keys
```

### Control Flow

```bash
# Conditionals
if [[ -f "$file" ]]; then
    echo "exists"
elif [[ -d "$file" ]]; then
    echo "is directory"
else
    echo "not found"
fi

# Test operators
[[ -f file ]]    # is regular file
[[ -d dir ]]     # is directory
[[ -z "$var" ]]  # is empty
[[ -n "$var" ]]  # is non-empty
[[ -r file ]]    # is readable
[[ -x file ]]    # is executable
[[ "$a" == "$b" ]]
[[ "$a" != "$b" ]]
[[ "$a" =~ regex ]]   # regex match
[[ $n -gt 0 ]]        # numeric comparison: -eq -ne -lt -le -gt -ge

# Loops
for i in {1..10}; do echo $i; done
for f in /etc/*.conf; do echo "$f"; done
for i in "${arr[@]}"; do echo "$i"; done

while read -r line; do
    echo "$line"
done < file.txt

while [[ $retries -gt 0 ]]; do
    cmd && break
    ((retries--))
    sleep 2
done

# until, break, continue work as expected
```

### Functions

```bash
myfunc() {
    local arg1="$1"           # always use local
    local result
    result=$(do_something "$arg1")
    echo "$result"            # return value via stdout
    return 0                  # return code
}

# Call and capture
output=$(myfunc "input")
myfunc "input" || die "myfunc failed"
```

### Real Script Examples

```bash
# System health snapshot
#!/usr/bin/env bash
set -euo pipefail

echo "=== System Health: $(date) ==="
echo ""
echo "-- Load --"
uptime

echo ""
echo "-- Memory --"
free -h

echo ""
echo "-- Disk --"
df -h | grep -v tmpfs

echo ""
echo "-- Failed Services --"
systemctl list-units --state=failed --no-legend || echo "None"

echo ""
echo "-- Recent Errors (last hour) --"
journalctl --since "1 hour ago" -p err --no-pager | tail -20
```

```bash
# Backup with rotation
#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="/mnt/backups"
SOURCE="/etc"
KEEP=7
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DEST="$BACKUP_DIR/etc_$TIMESTAMP.tar.gz"

tar czf "$DEST" "$SOURCE" || { echo "Backup failed"; exit 1; }
echo "Backup created: $DEST"

# Rotate: keep only last N
ls -t "$BACKUP_DIR"/etc_*.tar.gz | tail -n +$((KEEP+1)) | xargs -r rm
echo "Rotation complete. Keeping last $KEEP backups."
```

### systemd Timers (Cron Replacement)

```ini
# /etc/systemd/system/backup.timer
[Unit]
Description=Daily backup timer

[Timer]
OnCalendar=daily
Persistent=true             # run if missed (e.g., system was off)
RandomizedDelaySec=10m

[Install]
WantedBy=timers.target
```

```bash
systemctl enable --now backup.timer
systemctl list-timers
systemctl list-timers --all
```

`[Milestone]` You can write a bash script with proper error handling, functions, argument parsing, and deploy it as a systemd timer.

---

## Phase 10 — Arch-Specific Administration (Weeks 12–14)

### mkinitcpio — Initramfs

```bash
# /etc/mkinitcpio.conf — key settings
MODULES=(btrfs)                  # preload kernel modules
HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)

# Regenerate
mkinitcpio -P                    # all presets
mkinitcpio -p linux              # specific kernel
mkinitcpio -p linux-lts

# After kernel update, pacman usually does this automatically
```

### GRUB / systemd-boot

```bash
# GRUB [Arch-specific]
grub-mkconfig -o /boot/grub/grub.cfg   # regenerate config
/etc/default/grub                       # edit parameters here
# After editing: always regenerate

# systemd-boot (simpler, UEFI only)
bootctl status
bootctl update
ls /boot/loader/entries/          # boot entries
# /boot/loader/loader.conf        # default entry, timeout
```

### Kernel Parameters & Module Management

```bash
# Current parameters
cat /proc/cmdline

# Add persistent params (GRUB)
# Edit GRUB_CMDLINE_LINUX_DEFAULT in /etc/default/grub
# Example: "quiet loglevel=3 nowatchdog"

# Modules
lsmod                             # loaded modules
modinfo module_name               # module info
modprobe module_name              # load
modprobe -r module_name           # unload
modprobe --show-depends module    # dependency tree

# Blacklist modules
# /etc/modprobe.d/blacklist.conf
blacklist pcspkr
blacklist nouveau                 # if using proprietary NVIDIA

# Persistent module loading
# /etc/modules-load.d/mymodules.conf
v4l2loopback
```

### Pacman Hooks

```ini
# /etc/pacman.d/hooks/grub-update.hook
[Trigger]
Operation = Upgrade
Type = Package
Target = grub

[Action]
Description = Regenerating GRUB config...
When = PostTransaction
Exec = /usr/bin/grub-mkconfig -o /boot/grub/grub.cfg
```

### reflector — Mirrorlist Management [Arch-specific]

```bash
# pacman -S reflector
reflector --country 'United States' --age 12 --protocol https \
          --sort rate --save /etc/pacman.d/mirrorlist

# Run automatically on pacman-mirrorlist upgrade
# /etc/xdg/reflector/reflector.conf
--country US,Germany
--age 12
--protocol https
--sort rate
--save /etc/pacman.d/mirrorlist

systemctl enable --now reflector.timer
```

### Recovery Procedures

```bash
# Boot to live ISO, then chroot
mount /dev/sda2 /mnt              # root partition
mount /dev/sda1 /mnt/boot/efi    # EFI partition (if applicable)
arch-chroot /mnt

# Inside chroot: fix whatever's broken
pacman -Syu                       # update
mkinitcpio -P                     # rebuild initramfs
grub-mkconfig -o /boot/grub/grub.cfg
exit
reboot
```

`[Milestone]` You can rebuild initramfs, regenerate GRUB, blacklist a kernel module, and chroot from a live ISO to rescue a broken system.

---

## Phase 11 — Productivity Workflow (Weeks 14–16)

_Speed and repeatability_

### Terminal Multiplexer: tmux

```bash
# Sessions
tmux new -s main                  # new named session
tmux ls                           # list sessions
tmux attach -t main               # attach to session
tmux kill-session -t main

# Inside tmux (prefix = Ctrl+b by default)
Prefix c         # new window
Prefix ,         # rename window
Prefix n/p       # next/previous window
Prefix 0-9       # switch to window number
Prefix %         # split vertical
Prefix "         # split horizontal
Prefix arrow     # move between panes
Prefix z         # zoom pane (toggle)
Prefix d         # detach session (keeps running)
Prefix [         # copy mode (scroll, search)

# ~/.tmux.conf
set -g prefix C-a                  # change prefix to Ctrl+a
set -g mouse on                    # mouse support
set -g history-limit 50000
setw -g mode-keys vi               # vi keys in copy mode
```

### vim — From Functional to Efficient

```
# Modes: Normal (Esc), Insert (i), Visual (v), Command (:)

# Movement
h j k l         left down up right
w/b             word forward/backward
e               end of word
0/$             line start/end
gg/G            file start/end
Ctrl+d/u        half-page down/up
Ctrl+f/b        full page down/up
:42             go to line 42

# Editing
i/a             insert before/after cursor
I/A             insert at line start/end
o/O             new line below/above
dd              delete line
yy              yank (copy) line
p/P             paste after/before
x               delete char
r               replace char
ciw             change inner word
di"             delete inside quotes
.               repeat last change
u               undo
Ctrl+r          redo

# Search
/pattern        forward search
?pattern        backward search
n/N             next/previous match
*               search word under cursor
:%s/old/new/g   global replace
:%s/old/new/gc  global replace with confirm

# Files and buffers
:w              write
:wq             write and quit
:q!             quit without saving
:e filename     open file
:split file     horizontal split
:vsplit file    vertical split
Ctrl+w w        switch pane
```

### Shell Configuration: zsh + useful tools

```bash
# Install zsh, oh-my-zsh or prezto
pacman -S zsh
chsh -s /bin/zsh

# Recommended additions
pacman -S zsh-autosuggestions
pacman -S zsh-syntax-highlighting
pacman -S fzf                     # fuzzy finder
pacman -S ripgrep                 # fast grep (rg)
pacman -S fd                      # fast find
pacman -S bat                     # cat with syntax highlighting
pacman -S eza                     # modern ls
pacman -S zoxide                  # smart cd
pacman -S tldr                    # simplified man pages

# ~/.zshrc additions
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
eval "$(zoxide init zsh)"

# fzf key bindings
# Ctrl+r = fuzzy history search
# Ctrl+t = fuzzy file search
# Alt+c  = fuzzy cd
```

### Useful Aliases and Functions

```bash
# ~/.zshrc or ~/.bashrc

# Shortcuts
alias ls='eza --group-directories-first'
alias ll='eza -la --group-directories-first'
alias tree='eza --tree'
alias cat='bat'
alias grep='rg'
alias find='fd'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ip='ip -c'                  # colorized ip output

# Safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Pacman shortcuts [Arch-specific]
alias pS='sudo pacman -S'
alias pR='sudo pacman -Rns'
alias pSyu='sudo pacman -Syu'
alias pSs='pacman -Ss'
alias pQo='pacman -Qo'

# Systemctl shortcuts
alias sc='systemctl'
alias scst='systemctl status'
alias scr='sudo systemctl restart'
alias jc='journalctl'
alias jcf='journalctl -f'
alias jcu='journalctl -u'

# Frequently used
alias ..='cd ..'
alias ...='cd ../..'
alias md='mkdir -p'
alias rd='rmdir'

# Functions
mkcd() { mkdir -p "$1" && cd "$1"; }
extract() {
    case "$1" in
        *.tar.gz) tar xzf "$1" ;;
        *.tar.bz2) tar xjf "$1" ;;
        *.tar.xz) tar xJf "$1" ;;
        *.zip) unzip "$1" ;;
        *.7z) 7z x "$1" ;;
        *) echo "Unknown format" ;;
    esac
}
```

### dotfiles Management

```bash
# Track config with git
git init --bare $HOME/.dotfiles
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotfiles config status.showUntrackedFiles no

dotfiles add ~/.zshrc
dotfiles add ~/.tmux.conf
dotfiles add ~/.config/nvim/init.lua
dotfiles commit -m "Add zsh config"
dotfiles remote add origin git@github.com:user/dotfiles.git
dotfiles push
```

`[Milestone]` You can use tmux without looking at a cheatsheet, edit config files efficiently in vim, have a personalized shell with useful aliases, and track your dotfiles in git.

---

## Phase 12 — Monitoring & Observability (Weeks 16–18)

### Prometheus + Node Exporter (Self-Hosted)

```bash
# Install
pacman -S prometheus node_exporter
systemctl enable --now node_exporter   # exposes :9100
systemctl enable --now prometheus      # scrapes + stores

# /etc/prometheus/prometheus.yml
scrape_configs:
  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']

# Query via HTTP: http://localhost:9090
# PromQL examples
node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100
rate(node_cpu_seconds_total{mode="idle"}[5m])
node_filesystem_avail_bytes{mountpoint="/"}
```

### Grafana (Visualization)

```bash
pacman -S grafana
systemctl enable --now grafana
# Web UI: http://localhost:3000 (admin/admin)
# Add Prometheus as data source
# Import dashboard: Node Exporter Full (ID: 1860)
```

### Alertmanager — Practical Alerting

```yaml
# /etc/prometheus/rules/node.yml
groups:
  - name: node
    rules:
      - alert: DiskAlmostFull
        expr: node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes < 0.10
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Disk space < 10%"

      - alert: HighMemoryUsage
        expr: node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes < 0.10
        for: 2m
        labels:
          severity: critical
```

### Log Aggregation with Loki + Promtail

```bash
# Loki = log storage, Promtail = log shipper
# Basic setup for single-host
pacman -S loki promtail   # or via AUR
systemctl enable --now loki
systemctl enable --now promtail

# /etc/promtail/config.yml - scrape journal
scrape_configs:
  - job_name: journal
    journal:
      max_age: 12h
      labels:
        job: systemd-journal
    relabel_configs:
      - source_labels: ['__journal__systemd_unit']
        target_label: unit
```

`[Milestone]` You have a working metrics + alerting stack, and logs queryable from Grafana.

---

## Phase 13 — Containers & Virtualization (Weeks 18–20)

### Podman [Arch-specific — rootless default]

```bash
pacman -S podman podman-compose

# Basic operations (Docker-compatible)
podman pull nginx
podman run -d -p 8080:80 --name web nginx
podman ps
podman ps -a
podman logs web
podman exec -it web bash
podman stop web
podman rm web
podman images
podman rmi nginx

# Rootless Podman
podman info | grep rootless       # should be true
# User namespaces must be enabled
cat /proc/sys/kernel/unprivileged_userns_clone

# Persistent storage
podman run -v /host/path:/container/path:Z nginx
# :Z = set SELinux label (important on SELinux systems)

# Systemd integration
podman generate systemd --name web > ~/.config/systemd/user/web.service
systemctl --user enable --now web
```

### systemd-nspawn — Lightweight Containers

```bash
# Arch container
mkdir /var/lib/machines/archtest
pacstrap -c /var/lib/machines/archtest base

# Start
systemd-nspawn -D /var/lib/machines/archtest
machinectl start archtest
machinectl login archtest
machinectl list
machinectl stop archtest
```

### QEMU/KVM — Full Virtualization

```bash
# Install
pacman -S qemu-full virt-manager libvirt dnsmasq
systemctl enable --now libvirtd
usermod -aG libvirt $USER

# Check hardware virtualization
grep -E 'vmx|svm' /proc/cpuinfo | head -5

# virt-manager = GUI
# virsh = CLI

virsh list --all
virsh start vm-name
virsh shutdown vm-name
virsh destroy vm-name              # force off
virsh snapshot-create-as vm-name snap1
virsh snapshot-revert vm-name snap1
```

`[Milestone]` You can run a rootless Podman container, persist it via systemd user unit, and create a QEMU/KVM VM.

---

## Phase 14 — Automation & IaC (Weeks 20–22)

### Ansible — Idempotent Automation

```bash
pacman -S ansible

# Inventory (/etc/ansible/hosts or ./inventory)
[webservers]
web1 ansible_host=192.168.1.10
web2 ansible_host=192.168.1.11

[all:vars]
ansible_user=admin

# Ad-hoc commands
ansible all -m ping
ansible webservers -m command -a "uptime"
ansible webservers -m package -a "name=nginx state=present" -b

# Playbook
---
- name: Setup webserver
  hosts: webservers
  become: true
  tasks:
    - name: Install nginx
      pacman:
        name: nginx
        state: present

    - name: Start nginx
      systemd:
        name: nginx
        state: started
        enabled: true

    - name: Copy config
      copy:
        src: nginx.conf
        dest: /etc/nginx/nginx.conf
      notify: reload nginx

  handlers:
    - name: reload nginx
      systemd:
        name: nginx
        state: reloaded
```

```bash
ansible-playbook site.yml -i inventory
ansible-playbook site.yml --check    # dry run
ansible-playbook site.yml --diff     # show diffs
```

### git for System Configuration

```bash
# Track /etc in git (read changes, coordinate manually)
cd /etc
git init
git add nginx/ ssh/ systemd/
git commit -m "Initial state"

# Before any change
git diff                           # see what changed
git log --oneline                  # history
```

`[Milestone]` You can write an Ansible playbook that installs and configures a service idempotently.

---

## Phase 15 — Performance Tuning (Weeks 22–24)

### Kernel Parameters via sysctl

```bash
# View
sysctl -a
sysctl vm.swappiness
sysctl net.ipv4.ip_forward

# Set temporarily
sysctl -w vm.swappiness=10

# Persist in /etc/sysctl.d/99-custom.conf
vm.swappiness=10                   # lower = prefer RAM over swap
vm.vfs_cache_pressure=50           # reduce pressure to reclaim inode cache
net.core.rmem_max=16777216         # increase socket buffers
net.core.wmem_max=16777216
net.ipv4.tcp_fastopen=3            # TCP Fast Open
fs.inotify.max_user_watches=524288 # for dev tools (VSCode, etc.)

sysctl -p /etc/sysctl.d/99-custom.conf   # apply
```

### CPU Frequency Scaling

```bash
pacman -S cpupower
cpupower frequency-info
cpupower frequency-set -g performance   # governor
# Governors: performance, powersave, schedutil, ondemand

# systemd service for persistent governor
# /etc/systemd/system/cpupower.service
[Service]
ExecStart=/usr/bin/cpupower frequency-set -g schedutil
```

### I/O Schedulers

```bash
# Check current scheduler
cat /sys/block/sda/queue/scheduler

# Set for HDD
echo mq-deadline > /sys/block/sda/queue/scheduler

# Set for NVMe/SSD (often none is fine)
echo none > /sys/block/nvme0n1/queue/scheduler

# Persist via udev rule
# /etc/udev/rules.d/60-ioschedulers.rules
ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="mq-deadline"
ACTION=="add|change", KERNEL=="nvme*", ATTR{queue/scheduler}="none"
```

### Profile: where is time actually spent?

```bash
# perf — Linux profiler
pacman -S perf
perf top                           # live CPU profiling
perf record -g -p PID sleep 30     # record for 30s
perf report                        # interactive report
perf stat command                  # CPU counter stats

# Flamegraph
perf record -F 99 -g -p PID sleep 30
perf script | stackcollapse-perf.pl | flamegraph.pl > flame.svg
```

`[Milestone]` You've tuned sysctl settings for your use case, set an I/O scheduler appropriately, and profiled a CPU-heavy process with perf.

---

## Daily Maintenance Routine

After completing this path, a healthy daily/weekly practice:

```bash
# Daily (< 5 min)
paru -Syu                         # update everything
systemctl list-units --state=failed
journalctl -p err --since today
df -h && free -h

# Weekly
pacman -Qdt | wc -l               # check orphan count
journalctl --disk-usage
btrfs scrub start /               # if on btrfs
smartctl -H /dev/sda              # disk health

# Monthly
reflector --save /etc/pacman.d/mirrorlist --sort rate --country US --age 12
paccache -r                       # clean pacman cache (keep 3 versions)
systemd-analyze security          # review service hardening
```

---

## Reference: Key File Locations

|File|Purpose|
|---|---|
|`/etc/systemd/system/`|Custom unit files|
|`/etc/pacman.conf`|Pacman config + repos|
|`/etc/pacman.d/mirrorlist`|Mirror list|
|`/etc/mkinitcpio.conf`|Initramfs config|
|`/etc/default/grub`|GRUB parameters|
|`/etc/ssh/sshd_config`|SSH daemon config|
|`/etc/nftables.conf`|Firewall ruleset|
|`/etc/sysctl.d/`|Kernel parameter drops|
|`/etc/modules-load.d/`|Modules to load at boot|
|`/etc/modprobe.d/`|Module options + blacklists|
|`/etc/fstab`|Filesystem mounts|
|`/etc/locale.conf`|System locale|
|`/etc/hostname`|Machine name|
|`/proc/`|Live kernel state|
|`/sys/`|Hardware + kernel interface|
|`/var/log/`|Log files (+ journal)|

---

## Arch Wiki — Essential Pages

Bookmark these. Read them fully at least once.

- `wiki.archlinux.org/title/Installation_guide`
- `wiki.archlinux.org/title/Systemd`
- `wiki.archlinux.org/title/Pacman`
- `wiki.archlinux.org/title/Mkinitcpio`
- `wiki.archlinux.org/title/GRUB`
- `wiki.archlinux.org/title/General_recommendations`
- `wiki.archlinux.org/title/Security`
- `wiki.archlinux.org/title/Improving_performance`
- `wiki.archlinux.org/title/Btrfs`
- `wiki.archlinux.org/title/Arch_Build_System`

---

_This document reflects practices and tools current as of early 2025. Package names, default configs, and tool behavior may change on a rolling release. Always verify against the Arch Wiki for your current system state._