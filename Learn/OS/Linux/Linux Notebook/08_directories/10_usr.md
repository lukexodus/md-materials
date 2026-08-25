## `/usr`


The `/usr` directory in Linux, including Arch Linux, is a major hierarchy that contains user-space system software, applications, libraries, and documentation that are not required for basic system booting but are essential for running and using the installed software environment.[1][2][6]

### Purpose and Role

- **User Programs and Utilities:** `/usr` hosts the majority of user commands and applications accessible to all users of the system, such as editors, browsers, and compilers.[4][1]
- **Shared Libraries and Data:** It contains libraries and shared resources needed by user-land programs, keeping system binaries in `/bin` and `/sbin` minimal.[2][5]
- **Non-Essential to Boot:** This directory is typically mounted as read-only and is not necessary for the system’s earliest boot stages, unlike `/bin`, `/lib`, and `/sbin`. This means the system is structured so it can still boot even if `/usr` is on a separate partition.[1][2]

### Key Subdirectories

| Path              | Purpose                                                             |
|-------------------|---------------------------------------------------------------------|
| /usr/bin          | Main user executable programs for all users [1][2]        |
| /usr/sbin         | System administration binaries for superuser [2][6]       |
| /usr/lib          | Libraries for binaries in `/usr/bin` and `/usr/sbin` [1]      |
| /usr/share        | Shared, architecture-independent data and documentation [2]    |
| /usr/include      | Header files for software development [1]                      |
| /usr/local        | Local software and custom scripts not managed by the distribution [7][2] |

### Summary

The `/usr` hierarchy is vital for delivering a portable and manageable user environment, housing almost all standard program files, libraries, documentation, and architecture-independent resources on a Linux system. It allows for efficient software management and a clear separation between essential system files and the broader software environment.[6][2][1]

Sources
[1] /usr https://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/usr.html
[2] Linux Directory Structure Simplified: A Comprehensive Guide https://dev.to/softwaresennin/linux-directory-structure-simplified-a-comprehensive-guide-3012
[3] Linux Directory Structure https://www.geeksforgeeks.org/linux-unix/linux-directory-structure/
[4] Decoding the /usr Directory | StarOps Technologies Blog https://staropstech.com/blog/decoding-the-usr-directory
[5] Linux File System Structure Explained: From / to /usr https://www.youtube.com/watch?v=ISJ44S5sZu8
[6] Linux Directory Structure and Important Files Paths Explained https://www.tecmint.com/linux-directory-structure-and-important-files-paths-explained/
[7] 4.9. /usr/local : Local hierarchy https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch04s09.html

