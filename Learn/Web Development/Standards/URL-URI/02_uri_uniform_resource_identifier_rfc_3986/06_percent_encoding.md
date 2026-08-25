## Percent-Encoding


Characters outside the unreserved set should be percent-encoded as `%HH` where HH is the hexadecimal representation of the character's byte value.

**Example:**

- Space: → `%20`
- Exclamation: `!` → `%21` (when used literally)
- UTF-8 character 'ñ': `%C3%B1`

