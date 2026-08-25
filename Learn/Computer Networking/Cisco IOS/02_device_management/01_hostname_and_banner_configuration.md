## Hostname and Banner Configuration


### Hostname Configuration

The hostname identifies a Cisco device on the network and appears in the CLI prompt. It should be descriptive and follow organizational naming conventions.

```
Router> enable
Router# configure terminal
Router(config)# hostname R1
R1(config)#
```

**Key points:**

- Hostname changes take effect immediately
- Must start with a letter
- Can contain letters, digits, and hyphens
- Cannot exceed 63 characters
- Case-sensitive
- Appears in system logs and prompts

### Banner Configuration

Banners display messages to users connecting to the device. Four types exist:

**Message of the Day (MOTD) Banner:**

```
R1(config)# banner motd #
Enter TEXT message. End with the character '#'.
******************************************
* Unauthorized access is prohibited     *
* All access is logged and monitored    *
******************************************
#
R1(config)#
```

**Login Banner:**

```
R1(config)# banner login #
Enter TEXT message. End with the character '#'.
User Access Verification Required
#
```

**EXEC Banner:**

```
R1(config)# banner exec #
Enter TEXT message. End with the character '#'.
Welcome to R1 - Production Router
#
```

**Incoming Banner:**

```
R1(config)# banner incoming #
Enter TEXT message. End with the character '#'.
Reverse Telnet Session
#
```

**Key points:**

- MOTD banner displays before login prompt
- Login banner displays after MOTD, before username/password prompt
- EXEC banner displays after successful login
- Incoming banner displays for reverse Telnet connections
- Use delimiters that don't appear in the banner text
- Legal language in banners can support prosecution of unauthorized access

