## Component Separator Characters


URI syntax employs specific reserved characters to delimit and separate components. These characters have designated syntactic purposes and must be percent-encoded when used literally within component values.

**Primary Separators:**

The colon (:) separates the scheme from the hierarchical part. In `http://example.com`, the colon after "http" terminates the scheme component. The double forward slash (//) marks the beginning of the authority component when present. The single forward slash (/) separates the authority from the path and delimits path segments. The question mark (?) introduces the query component. The hash symbol (#) introduces the fragment component.

**Authority Component Separators:**

Within the authority component, the at symbol (@) separates optional userinfo from the host. In `ftp://user:pass@ftp.example.com`, the @ symbol divides the authentication credentials from the hostname. Square brackets ([]) enclose IPv6 addresses to distinguish colons in the address from the port separator. The colon (:) within the authority separates the host from the optional port number.

**Sub-Delimiters:**

The characters ! $ & ' ( ) * + , ; = function as sub-delimiters. These characters are reserved but may appear in certain URI components without percent-encoding. Their specific usage depends on the URI scheme and component. For instance, the semicolon historically separated path parameters in some schemes, though this usage has declined.

**Percent-Encoding Requirements:**

Reserved characters must be percent-encoded when they appear as data rather than delimiters. The percent sign (%) itself must be encoded as %25 when used literally. To include a literal question mark in a path segment, encode it as %3F. To include a literal hash in a query parameter value, encode it as %23.

**Character Precedence:**

The separators have hierarchical significance. The scheme separator (:) is processed first, followed by the authority marker (//), then path separators (/), query separator (?), and finally fragment separator (#). This ordering determines how parsers tokenize URI strings.

