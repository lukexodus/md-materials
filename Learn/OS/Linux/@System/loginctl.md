# loginctl

Part of systemd. `loginctl` manages user sessions, seats, and users as tracked by `systemd-logind`. Useful for inspecting who is logged in, managing sessions, and controlling user lingering.

---

## Core Concepts

- **Session** — a single login instance for a user (TTY, SSH, GUI, etc.). Each gets a unique session ID.
- **User** — a user account with one or more sessions. loginctl tracks resource usage per user.
- **Seat** — a physical hardware grouping (display, keyboard, mouse). Most systems have one seat: `seat0`.
- **Lingering** — whether a user's processes survive after all their sessions end. Disabled by default.

---

## Basic Usage

```bash
loginctl                        # same as loginctl list-sessions
loginctl list-sessions          # show all active sessions
loginctl list-users             # show all logged-in users
loginctl list-seats             # show all seats
```

**Example output of `loginctl list-sessions`:**

```
SESSION  UID  USER    SEAT   TTY   
      1 1000  alice  seat0  tty2  
     12 1000  alice         pts/0 
     15 1001  bob           pts/1 
```

Columns: **SESSION** — session ID. **UID** — user ID. **USER** — username. **SEAT** — hardware seat (blank = no seat, e.g. SSH). **TTY** — terminal.

---

## Session Commands

```bash
loginctl show-session <id>          # all properties of a session
loginctl status <id>                # human-readable session status
loginctl activate <id>              # bring a session to foreground
loginctl lock-session <id>          # lock a session (sends lock signal)
loginctl unlock-session <id>        # unlock a session
loginctl lock-sessions              # lock all sessions
loginctl unlock-sessions            # unlock all sessions
loginctl terminate-session <id>     # forcefully end a session
```

**Example `loginctl status 1`:**

```
Session 1 - user alice (1000)
           Since: Mon 2026-03-02 09:14:22 UTC; 3 days ago
          Leader: 1234 (gdm-wayland-ses)
            Seat: seat0; vc2
             TTY: tty2
          Remote: no
         Service: gdm-autologin
            Type: wayland
           Class: user
            State: active
            Units: session-1.scope
                   └─1234 /usr/lib/gdm-wayland-session ...
```

**Useful properties from `show-session`:**

```bash
loginctl show-session 1 -p Type       # wayland, x11, tty, mir
loginctl show-session 1 -p State      # active, online, closing
loginctl show-session 1 -p Remote     # true if SSH
loginctl show-session 1 -p RemoteHost # remote IP if SSH
loginctl show-session 1 -p Display    # X11 display e.g. :0
```

---

## User Commands

```bash
loginctl show-user <user>           # all properties of a user
loginctl status-user <user>         # human-readable user status
loginctl enable-linger <user>       # enable lingering for user
loginctl disable-linger <user>      # disable lingering
loginctl terminate-user <user>      # kill all sessions for a user
```

**Example `loginctl show-user alice`:**

```
UID=1000
GID=1000
Name=alice
RuntimePath=/run/user/1000
Service=user@1000.service
Slice=user-1000.slice
Display=1
State=active
Sessions=1 12
IdleHint=no
```

### Lingering

Lingering allows a user's systemd user services to start at boot and keep running after logout — without requiring a login session.

```bash
loginctl enable-linger alice        # enable for a specific user
loginctl enable-linger              # enable for current user
loginctl disable-linger alice       # disable
loginctl show-user alice -p Linger  # check current state
```

Lingering state is stored in `/var/lib/systemd/linger/`. A file named after the user exists if lingering is enabled:

```bash
ls /var/lib/systemd/linger/         # list users with lingering enabled
```

Common use case: running a user-level systemd service (e.g. a bot, a server) that starts at boot without that user being logged in.

---

## Seat Commands

Most desktop systems have one seat (`seat0`). Relevant mainly for multi-seat setups.

```bash
loginctl list-seats                 # show all seats
loginctl show-seat seat0            # properties of seat0
loginctl status seat0               # human-readable seat info
loginctl attach seat0 <device>      # attach a device to a seat
loginctl flush-devices              # reset all seat assignments
```

---

## Useful Properties & Filtering

`show-session` and `show-user` dump all properties by default. Use `-p` to query specific ones:

```bash
loginctl show-session 1 -p Type,State,Remote
loginctl show-user alice -p Linger,Sessions,State
```

**Session types:**

|Type|Meaning|
|---|---|
|`tty`|Local TTY (virtual console)|
|`x11`|X11 graphical session|
|`wayland`|Wayland graphical session|
|`mir`|Mir display server|
|`unspecified`|SSH or unknown|

**Session states:**

|State|Meaning|
|---|---|
|`active`|Foreground session on a seat|
|`online`|Logged in but not in foreground|
|`opening`|Being created|
|`closing`|Being destroyed|

---

## Practical Examples

**See all currently logged-in users and their session types:**

```bash
loginctl list-sessions
```

**Check if a session is local or remote:**

```bash
loginctl show-session 12 -p Remote,RemoteHost
```

**Find all SSH sessions:**

```bash
loginctl list-sessions | while read session _ _ _ _; do
  remote=$(loginctl show-session "$session" -p Remote --value 2>/dev/null)
  [ "$remote" = "yes" ] && echo "SSH session: $session"
done
```

**Enable lingering for the current user (for persistent user services):**

```bash
loginctl enable-linger "$USER"
```

**Kill all sessions for a specific user:**

```bash
loginctl terminate-user bob
```

**Lock all graphical sessions (e.g. from a script on lid close):**

```bash
loginctl lock-sessions
```

**Check what display server a session is using:**

```bash
loginctl show-session "$XDG_SESSION_ID" -p Type --value
```

This last one is commonly used in scripts to branch behavior between X11 and Wayland.

---

## Environment Variable

`$XDG_SESSION_ID` is set automatically by systemd-logind when a session starts. It contains the current session's ID:

```bash
echo $XDG_SESSION_ID                            # e.g. "3"
loginctl show-session "$XDG_SESSION_ID"         # inspect current session
loginctl show-session "$XDG_SESSION_ID" -p Type --value   # x11 or wayland
```

---

## Relationship to Other systemd Tools

|Tool|Scope|
|---|---|
|`loginctl`|Sessions, users, seats (logind)|
|`systemctl`|System and user services, units|
|`journalctl`|Logs|
|`hostnamectl`|Hostname and OS info|
|`timedatectl`|Time and timezone|
|`localectl`|Locale and keyboard|

loginctl specifically talks to `systemd-logind.service`. If logind is not running, loginctl will not work. On systems without systemd (Alpine, Void with runit, Gentoo with OpenRC) loginctl is not available.

---

## Tips

**`--value` flag strips the key name** — useful in scripts when you want just the raw value:

```bash
loginctl show-session 1 -p State --value    # prints: active
```

**Lingering is the right way to run user services at boot** — the alternative of adding user services to system-level systemd is messier. Enable lingering, then `systemctl --user enable <service>`.

**`terminate-session` vs `terminate-user`** — terminate-session ends one login instance. terminate-user kills everything for that user including all sessions and their processes. Use the latter carefully.

**logind tracks idle state** — `IdleHint` and `IdleSinceHint` properties on sessions and users reflect inactivity, which desktop environments use to trigger screen locks or suspend.

**Sessions without a seat are headless** — SSH sessions and systemd user services don't attach to a seat. This is normal and expected; seat assignment is only meaningful for physical hardware access.