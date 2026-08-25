## URI Syntax Components


A URI consists of several hierarchical components that provide the information necessary to identify a resource:

**Scheme**: Identifies the protocol or naming authority. The scheme component is mandatory and must begin with a letter, followed by any combination of letters, digits, plus (+), period (.), or hyphen (-). The scheme is case-insensitive and is separated from the remainder of the URI by a colon (:).

**Authority**: Contains information about the naming authority responsible for the namespace. The authority component begins with a double slash (//) and may include:

- Userinfo: Optional username and password (deprecated for security reasons)
- Host: Domain name or IP address
- Port: Optional network port number

**Path**: Identifies the specific resource within the scope of the authority. The path component consists of a sequence of segments separated by forward slashes (/). The path may be empty, absolute (beginning with /), or relative.

**Query**: Contains non-hierarchical data that identifies the resource in conjunction with the path. The query component is indicated by a question mark (?) and typically consists of key-value pairs.

**Fragment**: Provides direction to a secondary resource or a specific portion of the primary resource. The fragment component is indicated by a hash symbol (#) and is processed by the client after retrieval.

