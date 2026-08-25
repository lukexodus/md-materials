## Generic URI Syntax


The complete generic URI syntax follows this structure:

```
scheme:[//authority]path[?query][#fragment]
```

Where the authority component expands to:

```
[userinfo@]host[:port]
```

**Key Points:**

- Square brackets indicate optional components
- The scheme and path are the only required components
- Components must appear in the specified order
- The authority component, when present, is preceded by //

Examples of URI structure variations:

```
http://www.example.com/path/to/resource?key=value#section
ftp://user:password@ftp.example.com:21/file.txt
mailto:user@example.com
urn:isbn:0-486-27557-4
file:///C:/Users/Documents/file.txt
```

The specification defines reserved characters that have special meaning within URI components:

**General delimiters**: : / ? # [ ] @ **Sub-delimiters**: ! $ & ' ( ) * + , ; =

Reserved characters must be percent-encoded when used for purposes other than their reserved function.

