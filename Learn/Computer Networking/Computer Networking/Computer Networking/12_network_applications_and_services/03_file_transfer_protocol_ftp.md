## File Transfer Protocol (FTP)


FTP provides standardized file transfer capabilities between clients and servers, supporting both interactive and automated file operations across networks.

### FTP Architecture and Operation

**Control and Data Connections:**

- Control connection (port 21) handles commands and responses
- Data connection transfers actual file content
- Separate connections enable simultaneous command and data flow
- Data connections created on-demand for transfers

**FTP Modes:**

- Active mode: server initiates data connection to client
- Passive mode: client initiates data connection to server
- Extended passive mode supports IPv6 addresses
- Mode selection affects firewall and NAT compatibility

**Transfer Modes:**

- ASCII mode converts text files between character sets
- Binary mode transfers files without modification
- EBCDIC mode supports IBM mainframe character encoding
- Local mode preserves file structure and attributes

### FTP Commands and Responses

**Connection Management Commands:**

- USER specifies username for authentication
- PASS provides password for user account
- QUIT terminates FTP session cleanly
- SYST returns server system information

**File Operations:**

- RETR downloads file from server to client
- STOR uploads file from client to server
- DELE deletes specified file on server
- RNFR and RNTO rename files on server

**Directory Operations:**

- PWD returns current working directory
- CWD changes current directory
- MKD creates new directory
- RMD removes empty directory
- LIST provides detailed directory listing
- NLST provides simple filename listing

**Response Codes:**

- 1yz Positive preliminary response
- 2yz Positive completion response
- 3yz Positive intermediate response
- 4yz Transient negative completion response
- 5yz Permanent negative completion response

### FTP Security Considerations

**Authentication Limitations:**

- Standard FTP transmits passwords in clear text
- No built-in encryption for data transfers
- Anonymous FTP allows unrestricted access
- Password-based authentication vulnerable to interception

**Secure FTP Variants:**

- FTPS (FTP over SSL/TLS) encrypts control and data connections
- SFTP (SSH File Transfer Protocol) uses SSH for security
- SCP (Secure Copy Protocol) provides simple encrypted file transfer
- WebDAV extends HTTP with file manipulation capabilities

**Access Control:**

- User accounts control server access
- Directory permissions restrict file operations
- Chroot jails limit user access scope
- Bandwidth limiting prevents resource abuse

### FTP Implementation Considerations

**Firewall and NAT Challenges:**

- Active mode requires inbound connections to clients
- Passive mode requires multiple server ports
- Port ranges must be configured for passive mode
- Application-layer gateways needed for NAT environments

**Performance Optimization:**

- Multiple data connections enable parallel transfers
- Buffer size tuning improves transfer rates
- Network topology affects optimal transfer modes
- Compression reduces transfer time for compressible files

**Automation and Scripting:**

- Batch file transfers using script files
- Scheduled transfers for regular operations
- Error handling for unattended operations
- Logging and monitoring for operational oversight

