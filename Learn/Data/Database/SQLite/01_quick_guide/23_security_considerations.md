## Security Considerations


- **No built-in user authentication.** Access control is at the OS file permission level.
- **Encryption.** The open-source SQLite does not include encryption. The commercial SQLite Encryption Extension (SEE) adds this. Third-party open-source options such as SQLCipher also exist.
- **SQL injection.** Always use parameterized queries or prepared statements in application code. Never construct SQL by concatenating user-supplied strings.
- **File permissions.** Protect database files with appropriate OS-level permissions, since anyone who can read the file has access to all data.

---

