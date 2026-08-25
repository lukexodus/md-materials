## Comments should explain why


Comments in a codebase serve a distinct purpose separate from the code itself. While code dictates implementation mechanics, comments must articulate the intent, architectural decisions, and external constraints that necessitated the specific implementation. The most dangerous comments are those that duplicate the code, as they drift out of sync during maintenance, becoming "lies" that mislead future developers.

**Key Points**

- **Intent over Implementation:** Use comments to describe the business rule or design pattern being applied, not the syntax used to achieve it.
    
- **Documentation of Constraints:** Explicitly state non-obvious constraints, such as hardware limitations, downstream API quirks, or specific compliance requirements that force a suboptimal or unusual implementation.
    
- **"Chesterton's Fence":** Comments should prevent the accidental removal of necessary but obscure code (e.g., a specific delay required for a race condition).
    
- **Linking to Context:** Reference issue trackers, bug IDs, or external documentation (RFCs, whitepapers) to provide a paper trail for complex logic.
    
- **Warning Markers:** Use standardized tags (`FIXME`, `HACK`, `DEPRECATED`) to indicate technical debt or areas requiring caution.
    

**Example**

_Bad (Redundant):_

Python

```
# Increment retry count
retries += 1

# Check if retries is greater than 5
if retries > 5:
    # return False
    return False
```

_Good (Contextual):_

Python

```
# The legacy payment gateway (v1 API) silently drops connections
# without error codes if the payload exceeds 1kb. We implement an
# exponential backoff here to avoid triggering their rate limiter
# which bans IPs for 24 hours. See Ticket #4022.
if retries > MAX_GATEWAY_RETRIES:
    logger.error("Gateway rate limit risk exceeded.")
    return False
```

