## systemd Basics


### What is systemd

systemd is a system and service manager for Linux operating systems that serves as the init system (PID 1). It manages the boot process, system services, and various system resources. systemd replaces traditional SysV init scripts with a more modern, parallel, and dependency-based approach to system initialization and service management.

### systemd Architecture and Core Concepts

#### Process Tree Structure

systemd operates as PID 1 and becomes the parent of all other processes on the system. It uses a hierarchical structure where services are organized into units that can depend on other units, creating a dependency graph that determines startup order.

#### Targets and Runlevels

systemd uses "targets" instead of traditional runlevels. Targets are special unit types that group other units together, similar to how runlevels worked in SysV init but with more flexibility:

- `poweroff.target` (runlevel 0)
- `rescue.target` (runlevel 1)
- `multi-user.target` (runlevel 2,3,4)
- `graphical.target` (runlevel 5)
- `reboot.target` (runlevel 6)

#### Socket-Based Activation

systemd can start services on-demand when a connection is made to their socket, enabling faster boot times and resource conservation. Services remain inactive until actually needed.

#### Cgroups Integration

systemd uses Linux control groups (cgroups) to organize and manage processes, providing better resource management, process tracking, and cleanup capabilities.

### Unit Types and Files

#### Service Units (.service)

The most common unit type, representing system services or daemons. Service units define how to start, stop, and manage individual services.

**Example service unit structure:**

```ini
[Unit]
Description=My Application
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/myapp
Restart=always
User=myuser

[Install]
WantedBy=multi-user.target
```

#### Socket Units (.socket)

Define network or IPC sockets that systemd monitors. When a connection is made, systemd can automatically start the associated service.

#### Target Units (.target)

Grouping units that define system states or synchronization points. They don't perform actions themselves but coordinate other units.

#### Timer Units (.timer)

Provide cron-like functionality for scheduling tasks. Timer units can trigger service units at specified intervals or times.

#### Mount Units (.mount)

Control filesystem mount points. systemd automatically creates mount units for entries in `/etc/fstab`.

#### Device Units (.device)

Represent hardware devices exposed by the kernel. systemd automatically creates these based on udev events.

#### Path Units (.path)

Monitor filesystem paths and can trigger other units when files or directories change.

#### Slice Units (.slice)

Organize units in a hierarchy for resource management through cgroups.

### Unit File Locations

systemd searches for unit files in several directories with different priorities:

1. `/etc/systemd/system/` - Local configuration (highest priority)
2. `/run/systemd/system/` - Runtime units
3. `/usr/lib/systemd/system/` - Distribution package units
4. `/lib/systemd/system/` - Distribution package units (alternative location)

### Service States and Lifecycle

#### Service States

Services can exist in various states that indicate their current status:

- **loaded** - Unit file has been loaded into memory
- **active (running)** - Service is currently running
- **active (exited)** - Service completed successfully and exited
- **active (waiting)** - Service is running but waiting for an event
- **inactive (dead)** - Service is not running
- **failed** - Service failed to start or crashed
- **activating** - Service is in the process of starting
- **deactivating** - Service is in the process of stopping

#### Service Types

The `Type=` directive in service units defines how systemd manages the service:

- **simple** - Default type; service process is the main process
- **exec** - Similar to simple but systemd waits for the main process to start
- **forking** - Service forks and the parent process exits
- **oneshot** - Process is expected to exit; useful for scripts
- **dbus** - Service is considered started when it takes a name on D-Bus
- **notify** - Service sends a notification when it's ready
- **idle** - Service execution is delayed until all jobs are finished

#### Restart Policies

The `Restart=` directive controls automatic restart behavior:

- **no** - Never restart (default)
- **always** - Always restart regardless of exit status
- **on-success** - Restart only on clean exit
- **on-failure** - Restart only on failure
- **on-abnormal** - Restart on unclean signals or timeouts
- **on-abort** - Restart only on abort signals
- **on-watchdog** - Restart on watchdog timeout

### systemd vs SysV init

#### Startup Process Differences

**SysV init:**

- Sequential startup based on numbered scripts (S01, S02, etc.)
- Shell scripts in `/etc/init.d/` with start/stop functions
- Runlevels define system states (0-6)
- Slower boot times due to sequential processing
- Simple but inflexible dependency management

**systemd:**

- Parallel startup based on dependency resolution
- Binary unit files with declarative syntax
- Targets replace runlevels with more flexibility
- Faster boot times through parallelization
- Sophisticated dependency and ordering management

#### Service Management Differences

**SysV init commands:**

```bash
service apache2 start
service apache2 stop
service apache2 status
chkconfig apache2 on
```

**systemd equivalents:**

```bash
systemctl start apache2
systemctl stop apache2
systemctl status apache2
systemctl enable apache2
```

#### Configuration File Differences

**SysV init script example:**

```bash
#!/bin/bash
case "$1" in
    start)
        echo "Starting myservice"
        /usr/bin/myservice &
        ;;
    stop)
        echo "Stopping myservice"
        killall myservice
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
```

**systemd service unit example:**

```ini
[Unit]
Description=My Service
After=network.target

[Service]
ExecStart=/usr/bin/myservice
Type=simple
Restart=always

[Install]
WantedBy=multi-user.target
```

#### Advantages of systemd

**Key points:**

- Faster boot times through parallel execution
- Better dependency management and ordering
- Automatic service monitoring and restart capabilities
- Unified logging through journald
- Socket-based activation for on-demand service starting
- Cgroups integration for better process management
- Standardized service configuration format

#### Disadvantages and Criticisms

**Key points:**

- Increased complexity compared to simple shell scripts
- Larger binary size and memory footprint
- Less portable across different Unix-like systems
- Learning curve for administrators familiar with SysV
- [Speculation] Some view it as violating Unix philosophy of "do one thing well"

### Common systemd Commands

#### Service Management

```bash
systemctl start service-name
systemctl stop service-name
systemctl restart service-name
systemctl reload service-name
systemctl status service-name
```

#### Enable/Disable Services

```bash
systemctl enable service-name    # Start at boot
systemctl disable service-name   # Don't start at boot
systemctl is-enabled service-name
```

#### System State Management

```bash
systemctl list-units
systemctl list-unit-files
systemctl get-default           # Show default target
systemctl set-default target    # Set default target
```

#### Journal Management

```bash
journalctl -u service-name      # Show logs for specific service
journalctl -f                   # Follow logs in real-time
journalctl --since "1 hour ago" # Show recent logs
```

**Key points:** systemd represents a fundamental shift in Linux system initialization, offering improved performance and capabilities while requiring administrators to learn new concepts and commands. The transition from SysV init to systemd has been [Inference] one of the most significant changes in Linux system administration in recent years, though adoption and acceptance vary across different distributions and user communities.

---

