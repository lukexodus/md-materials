## Mailto URLs


Mailto URLs initiate email composition with pre-filled fields. They use the mailto: scheme and can include recipient addresses, subject, body, and other email headers.

Syntax: `mailto:address[?header=value&header=value]`

**Example:**

```
mailto:user@example.com
mailto:user@example.com?subject=Hello&body=Message%20text
mailto:user1@example.com,user2@example.com?cc=user3@example.com
```

The behavior depends on the user's email client configuration. Not all clients support all mailto features, and maximum URL length varies by client and system.

