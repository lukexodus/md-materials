## CLI Basics and Navigation


The Cisco CLI is accessed through console cable, SSH, or Telnet connections. Navigation relies on understanding command structure, shortcuts, and editing features.

**Command Structure**

Commands follow a hierarchical syntax: `command keyword [argument]`. Square brackets indicate optional parameters, curly braces with pipes {option1 | option2} indicate required choices, and angle brackets \<value> indicate user-supplied values.

**Navigation Shortcuts**

- `Tab`: Completes partial commands and keywords
- `Ctrl+A`: Moves cursor to beginning of line
- `Ctrl+E`: Moves cursor to end of line
- `Ctrl+W`: Erases word to left of cursor
- `Ctrl+U`: Erases line
- `Ctrl+C`: Exits configuration mode or cancels command
- `Ctrl+Z`: Exits to privileged EXEC mode from any configuration level
- `Ctrl+Shift+6`: Interrupt sequence (stops ping, traceroute, DNS lookup)
- `Up Arrow` or `Ctrl+P`: Recalls previous command
- `Down Arrow` or `Ctrl+N`: Recalls next command in history

**Terminal Settings**

- `terminal length 0`: Disables page breaks (useful for capturing full outputs)
- `terminal length 24`: Sets screen length for pagination
- `terminal history size 256`: Adjusts command history buffer

**Output Filtering**

IOS supports output filtering with pipe operations:

- `show running-config | include hostname`: Shows only lines containing "hostname"
- `show running-config | begin interface`: Displays from first match onward
- `show running-config | section interface`: Shows complete sections matching keyword
- `show ip interface brief | exclude unassigned`: Excludes lines with "unassigned"

