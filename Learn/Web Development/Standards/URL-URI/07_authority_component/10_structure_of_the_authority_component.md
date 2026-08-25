## Structure of the Authority Component


The authority component follows the optional scheme and double-slash (//) and precedes the path. Its general structure is: `[userinfo@]host[:port]`

Each subcomponent serves a specific purpose in identifying and accessing the resource. The host is the only required element, while userinfo and port are optional.

The authority component is delimited by the first single slash (/), question mark (?), or hash (#) following the double slash, or by the end of the URL string. This structure allows clear separation of the authority from other URL components.

**Example:**

```
https://user:pass@example.com:8080/path?query#fragment
        └─────────┬─────────┘
            authority component
        └───┬───┘ └───┬──┘ └┬┘
        userinfo    host   port
```

