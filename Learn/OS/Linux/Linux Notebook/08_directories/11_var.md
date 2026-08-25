## `/var`


The `/var` directory in Linux contains files and directories whose contents are likely to change during system operation, serving as storage for system and application data that is dynamic or variable. Unlike `/usr`, which mainly holds static data, `/var` is designed to house files that grow, shrink, or are constantly updated as the system runs.[1][2][4][5]

### Common Contents of `/var`

- **Log Files:** System and application logs live in `/var/log`, recording events, access, errors, and system activity.[4][5]
- **Spool Files:** Directories like `/var/spool` contain files meant for queued operations (e.g., print jobs, outgoing email).[2][5][4]
- **Mail:** User and system mailbox files are stored under `/var/mail`.[4]
- **Caches:** Temporary, re-creatable data (such as application caches) is placed in `/var/cache`.[5][4]
- **Lock Files:** Resources in use are tracked with lock files in `/var/lock` to prevent conflicts.[4]
- **Temporary Files:** Persistent temporary files that survive reboots reside in `/var/tmp`.[4]
- **Databases and State:** Application state, package data, and local databases are found under `/var/lib`.[5][4]
- **Other:** Add-on packages might store their changing data in `/var/opt`. Crash dumps and variable game data might also appear within appropriate subdirectories.[5][4]

### Why Use `/var`

The system can safely mount `/usr` as read-only since it holds mostly static files, while `/var` remains writable for data required to be updated during typical system operation. Backup, disk usage, and permissions can be adjusted more flexibly for major categories of variable data by isolating them in `/var`.[1][5]

### Example Subdirectories

| Path         | Purpose                                              |
|--------------|------------------------------------------------------|
| /var/log     | System and application log files [5][4]    |
| /var/spool   | Queued print/mail tasks [4][2]             |
| /var/lib     | State and database files [5][4]            |
| /var/cache   | Application caches [4][5]                  |
| /var/mail    | User and system mailboxes [4]                   |
| /var/tmp     | Persistent temporary files [4]                  |
| /var/lock    | Lock files for resources [4]                    |

The `/var` hierarchy is essential for proper system operation as it manages all dynamic, transient, and changeable system and application data.[2][1][5]

Sources
[1] Chapter 5. The /var Hierarchy https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch05.html
[2] linux - What goes in /var? https://stackoverflow.com/questions/18514447/what-goes-in-var
[3] Linux Directory Structure https://www.geeksforgeeks.org/linux-unix/linux-directory-structure/
[4] Navigating the Linux Directory Structure: A Roadmap to ... https://www.linkedin.com/pulse/navigating-linux-directory-structure-roadmap-gauri-yadav
[5] /var https://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/var.html
[6] The /var Directory https://www.linfo.org/var.html

