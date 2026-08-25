## Context-Sensitive Help and Command Completion


**Question Mark Help**

Typing `?` at any point displays available commands or parameters:

- At prompt: `?` shows all available commands in current mode
- After partial command: `sh?` shows commands starting with "sh"
- After command: `show ?` displays available keywords
- After keyword: `show ip ?` shows next available options
- Mid-command: `show inter?` completes to "interface" options

**Tab Completion**

Pressing Tab after entering enough characters to uniquely identify a command completes it automatically. If multiple matches exist, nothing happens until more characters are typed. This accelerates command entry and reduces typos.

**Error Messages**

IOS provides specific error feedback:

- `% Ambiguous command`: Multiple commands match; type more characters
- `% Incomplete command`: Command requires additional parameters
- `% Invalid input detected at '^' marker`: Syntax error at the caret position
- `% Unknown command or computer name`: Command not recognized in current mode

**Command Abbreviation**

Commands can be abbreviated to the shortest unique string: `conf t` for `configure terminal`, `int gi0/0` for `interface gigabitethernet0/0`, `sh ip int br` for `show ip interface brief`. This efficiency is common in production environments but full commands improve documentation clarity.

