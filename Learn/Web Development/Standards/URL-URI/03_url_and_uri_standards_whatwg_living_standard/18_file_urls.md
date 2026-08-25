## File URLs


File URLs reference files on local file systems using the file: scheme. The syntax and behavior vary significantly across operating systems and implementations.

General format: `file://[host]/path`

On Windows: `file:///C:/path/to/file.txt` On Unix/Linux: `file:///path/to/file.txt` With UNC paths: `file://server/share/file.txt`

File URLs have security implications as they access local resources. Modern browsers restrict file URL usage in web contexts and prevent cross-origin access from file URLs to other schemes.

