## Authority Parsing Algorithm


### Complete Parsing Process

**Step-by-step algorithm:**

1. **Extract authority from URI:**
    
    - Locate `://` after scheme
    - Authority ends at first `/`, `?`, `#`, or end of string
2. **Check for userinfo:**
    
    - Scan for `@` symbol
    - If found, everything before last `@` is userinfo
    - Split userinfo on first `:` into username and password
3. **Identify host boundaries:**
    
    - If `[` present, host is IPv6 (extract up to matching `]`)
    - Otherwise, host extends from start (or after `@`) to `:` or end
4. **Parse host:**
    
    - IPv6: Validate bracket-enclosed address
    - IPv4: Validate dotted-decimal format
    - DNS: Validate registered name syntax
5. **Extract port:**
    
    - Locate colon after host (after `]` for IPv6)
    - Parse remaining digits as port number
    - Validate range (0-65535)
6. **Percent-decode components:**
    
    - Decode userinfo if present
    - Decode host (except IPv6 literals)
    - Port is not percent-encoded

### Parsing Example

**Input:**

```
https://user%40email:p%40ss@[2001:db8::1]:8080/path
```

**Parsing steps:**

```
1. Extract authority:
   "user%40email:p%40ss@[2001:db8::1]:8080"

2. Find @ at position 22:
   userinfo = "user%40email:p%40ss"
   host+port = "[2001:db8::1]:8080"

3. Split userinfo on first ::
   username = "user%40email"
   password = "p%40ss"

4. Host starts with [:
   IPv6 = "2001:db8::1"
   Remaining = ":8080"

5. Port after ]:
   port = "8080"

6. Decode:
   username = "user@email"
   password = "p@ss"
   host = "2001:db8::1" (no decoding for IPv6)
   port = 8080
```

