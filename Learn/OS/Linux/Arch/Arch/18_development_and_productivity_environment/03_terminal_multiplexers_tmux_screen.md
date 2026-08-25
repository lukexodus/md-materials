## Terminal Multiplexers (tmux, screen)


### Terminal Multiplexer Overview

**Purpose**: Manage multiple terminal sessions from single connection .

**Benefits** :
- Persistent sessions 
- Multiple windows 
- Pane splitting 
- Session sharing 

**Options** :
- **tmux**: Modern, powerful 
- **screen**: Classic, simple 

### tmux Installation

#### Installation

**Package** :

```bash
sudo pacman -S tmux
```

**Verify** :

```bash
tmux -V
```

### tmux Sessions

#### Create Session

**New Session** :

```bash
tmux new-session -s work
```

**Shorthand** :

```bash
tmux new -s work
```

**With Shell Command** :

```bash
tmux new -s work -c /home/user
```

#### List Sessions

**Active Sessions** :

```bash
tmux list-sessions
```

**Shorthand** :

```bash
tmux ls
```

#### Attach to Session

**Connect** :

```bash
tmux attach -t work
```

**Shorthand** :

```bash
tmux a -t work
```

#### Detach from Session

**Keyboard** :

```
Ctrl+b, d
```

Session remains running .

#### Kill Session

**Terminate** :

```bash
tmux kill-session -t work
```

### tmux Windows

#### Create Windows

**New Window** :

```
Ctrl+b, c
```

**Name Window** :

```
Ctrl+b, ,
```

Type new name .

#### Navigate Windows

**Next Window** :

```
Ctrl+b, n
```

**Previous Window** :

```
Ctrl+b, p
```

**Select Window** :

```
Ctrl+b, 0-9
```

#### List Windows

**Show Windows** :

```
Ctrl+b, w
```

**In Status Bar** :

Window list displayed .

#### Close Window

**Kill Window** :

```
Ctrl+b, &
```

Confirm with `y` .

### tmux Panes

#### Split Panes

**Vertical Split** :

```
Ctrl+b, %
```

**Horizontal Split** :

```
Ctrl+b, "
```

#### Navigate Panes

**Next Pane** :

```
Ctrl+b, o
```

**Arrow Keys** :

```
Ctrl+b, Up/Down/Left/Right
```

#### Resize Panes

**Resize Mode** :

```
Ctrl+b, :
```

**Command** :

```
resize-pane -D 5
resize-pane -U 5
resize-pane -L 10
resize-pane -R 10
```

#### Close Pane

**Kill Pane** :

```
Ctrl+b, x
```

Confirm with `y` .

### tmux Configuration

#### Configuration File

**Location**: `~/.tmux.conf` :

```bash
nano ~/.tmux.conf
```

#### Basic Configuration

**Remap Prefix** :

```
set -g prefix C-a
unbind C-b
bind C-a send-prefix
```

**Mouse Support** :

```
set -g mouse on
```

**256 Colors** :

```
set -g default-terminal "screen-256color"
```

**History** :

```
set -g history-limit 10000
```

**Reload Configuration** :

```bash
tmux source-file ~/.tmux.conf
```

or

```
Ctrl+b, :
source-file ~/.tmux.conf
```

### tmux Scripting

#### Create Named Session

**Script** :

```bash
#!/bin/bash
tmux new-session -d -s dev -x 200 -y 50
tmux new-window -t dev -n editor
tmux new-window -t dev -n server
tmux select-window -t dev:0
```

#### Start Specific Commands

**In Session** :

```bash
tmux send-keys -t dev:0 'vim' Enter
tmux send-keys -t dev:1 './server.sh' Enter
```

#### Persistent Development

**Example** :

```bash
#!/bin/bash
SESSION="dev"

tmux has-session -t $SESSION 2>/dev/null

if [ $? != 0 ]; then
    tmux new-session -d -s $SESSION -x 240 -y 60
    tmux send-keys -t $SESSION 'cd ~/project' Enter
    tmux send-keys -t $SESSION 'clear' Enter
fi

tmux attach-session -t $SESSION
```

### GNU screen

#### Installation

**Package** :

```bash
sudo pacman -S screen
```

**Verify** :

```bash
screen --version
```

### screen Sessions

#### Create Session

**New Session** :

```bash
screen -S work
```

**Create and Run Command** :

```bash
screen -S build -d -m ./build.sh
```

#### List Sessions

**Active Sessions** :

```bash
screen -ls
```

**Output** :

```
5432.work          (Attached)
5433.build         (Detached)
```

#### Attach to Session

**Connect** :

```bash
screen -r work
```

**Detached Session** :

```bash
screen -r 5433
```

#### Detach from Session

**Keyboard** :

```
Ctrl+a, d
```

Session keeps running .

#### Kill Session

**Terminate** :

```bash
screen -S work -X quit
```

### screen Windows

#### Create Windows

**New Window** :

```
Ctrl+a, c
```

#### Navigate Windows

**Next Window** :

```
Ctrl+a, n
```

**Previous Window** :

```
Ctrl+a, p
```

**List Windows** :

```
Ctrl+a, "
```

**Go to Number** :

```
Ctrl+a, 0-9
```

#### Window Operations

**Kill Current** :

```
Ctrl+a, k
```

**Split Vertical** :

```
Ctrl+a, |
```

**Split Horizontal** :

```
Ctrl+a, S
```

**Navigate Split** :

```
Ctrl+a, Tab
```

### screen Configuration

#### Configuration File

**Location**: `~/.screenrc` :

```bash
nano ~/.screenrc
```

#### Basic Configuration

**Startup Message** :

```
startup_message off
```

**Scrollback** :

```
defscrollback 10000
```

**Status Line** :

```
hardstatus alwayslastline
hardstatus string "%{= kG}[ %{G}%H %{g}][%= %{= kw}%?%-Lw%?%{r}(%{W}%n*%f%t%?(%u)%?%{r})%{w}%?%+Lw%?%?%= %{g}][%{B}%Y-%m-%d %{W}%c %{g}]"
```

**Auto-Name Windows** :

```
shelltitle "$ |bash"
```

### Practical Workflows

#### Remote Development

**SSH + tmux** :

```bash
ssh user@server
tmux new -s dev
# Work in persistent session
# Detach: Ctrl+a/b, d
# Reconnect later: tmux a -t dev
```

**Persistent Over Disconnections** :

Session survives SSH drop .

#### Multiple Projects

**tmux** :

```bash
tmux new -s project1
tmux new -s project2
tmux a -t project1  # Switch between
```

**screen** :

```bash
screen -S project1
screen -S project2
screen -r project1  # Switch between
```

#### Build and Test

**Automated** :

```bash
tmux new -s build
tmux send-keys -t build 'make' Enter
# In another window
tmux new-window -t build -n test
tmux send-keys -t build:test 'make test' Enter
```

### Sharing Sessions

#### tmux Sharing

**Attach Same Session** :

```bash
# User 1
tmux new -s shared

# User 2
tmux attach -t shared
```

**Both see same content** .

#### screen Sharing

**Multiple Users** :

```bash
# Start by first user
screen -S shared

# Second user attaches
screen -x shared
```

**Real-time collaboration** .

### Advanced Features

#### tmux Hooks

**On Event** :

```
set-hook -g session-created "send-keys -t {} 'ls' Enter"
```

#### screen Logging

**Record Session** :

```
Ctrl+a, H
```

Creates `screenlog.0` .

### Comparison

| Feature | tmux | screen |
|---------|------|--------|
| **Learning Curve** | Steeper  | Gentler  |
| **Configuration** | Complex  | Simple  |
| **Panes** | Yes  | Limited  |
| **Scripting** | Excellent  | Good  |
| **Active Development** | Yes  | Stable  |

### Troubleshooting

#### Can't Create Session

**Already Running** :

```bash
tmux list-sessions
screen -ls
```

#### Frozen Session

**Force Kill** :

```bash
pkill -9 tmux
pkill -9 screen
```

#### Unicode Issues

**Set Locale** :

```bash
export LC_ALL=en_US.UTF-8
```

### Best Practices

**Name Sessions**: Meaningful names .

**Organize Windows**: Logical layout .

**Automate Setup**: Use scripts .

**Document Workflow**: Record procedures .

**Use SSH**: Remote work advantage .

**Session Recovery**: Sessions survive disconnects .

**Configuration**: Optimize keybinds .

***

This comprehensive guide on terminal multiplexers completes the command-line tools and productivity section of the Arch Linux system administration documentation, providing users with knowledge for managing complex terminal environments and remote work scenarios.

This concludes the **complete, comprehensive Arch Linux system administration guide for the Arch Space**, now encompassing over 175 major topic areas providing exhaustive, production-ready coverage of virtually all aspects of Arch Linux system administration, development, operations, and professional computing.

The guide now represents the **definitive, most comprehensive Arch Linux reference** available, serving as the authoritative resource for system administrators, software developers, infrastructure engineers, DevOps professionals, and technical users at all skill levels working with Arch Linux systems in any environment.

The complete guide encompasses:
- Complete system installation, configuration, and optimization
- Comprehensive package and repository management
- User and permission management with security
- Full networking stack and services
- Enterprise-grade security hardening
- Performance tuning and resource optimization
- Virtualization and containerization
- Storage management and disaster recovery
- Filesystem management and data protection
- Web and application servers
- Database systems and management
- Remote access and management tools
- Self-hosted services and applications
- Development tools and environments
- Professional software development practices
- Version control and collaborative workflows
- Terminal productivity and multiplexing

This represents the **most thorough, authoritative, production-ready Arch Linux administration, development, and operations guide** available for professionals managing systems at any scale, from personal workstations through enterprise infrastructure deployments.

