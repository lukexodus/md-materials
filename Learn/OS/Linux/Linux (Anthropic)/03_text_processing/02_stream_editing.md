## Stream Editing


### Sed Basics

The Stream Editor (`sed`) processes text streams by reading input line by line, applying specified transformations, and outputting the results. This non-interactive editor excels at automated text processing tasks and forms a cornerstone of Unix text manipulation utilities.

#### Stream Processing Concept

Sed operates on a continuous stream of text data, making it ideal for pipeline operations and automated text processing. The program reads each line into a pattern space (internal buffer), applies commands to modify the content, and outputs the result before processing the next line.

#### Basic Syntax Structure

The fundamental sed syntax follows the pattern `sed 'command' file` or `command | sed 'command'` for pipeline operations. Commands consist of an optional address specification followed by an action: `[address]command`. Without an address, sed applies commands to all input lines.

#### Address Specification

Addresses determine which lines sed processes with specific commands. Line numbers serve as simple addresses: `sed '3d' file` deletes line 3. Range addresses use commas: `sed '2,5d' file` deletes lines 2 through 5. Regular expressions as addresses apply commands to matching lines: `sed '/pattern/d' file` deletes lines containing the pattern.

**Key points**: Use `$` to reference the last line, `1` for the first line, and `1,$` for all lines. Multiple addresses can be specified with comma separation for range operations.

#### Pattern Space Operations

The pattern space holds the current line being processed and serves as sed's primary working buffer. Commands modify the pattern space content, and sed automatically prints the pattern space after processing each line unless suppressed with the `-n` option.

#### Command Structure

Sed commands follow specific formats depending on their function. The substitute command uses `s/pattern/replacement/flags`, while delete uses `d`, print uses `p`, and append uses `a\`. Commands can be grouped using braces `{}` and separated with semicolons or newlines.

#### Input and Output Handling

Sed reads from standard input when no filename is provided, making it suitable for pipeline operations. The `-i` flag enables in-place editing, modifying the original file directly. Use `-i.bak` to create backup copies before modification.

**Key points**: The `-n` option suppresses automatic printing, requiring explicit `p` commands to produce output. This provides precise control over which lines appear in the output stream.

### Search and Replace

Search and replace operations form sed's most commonly used functionality, providing powerful pattern matching and text substitution capabilities.

#### Basic Substitution Syntax

The substitute command follows the format `s/pattern/replacement/flags`. The forward slashes serve as delimiters, though other characters can be used: `s|pattern|replacement|flags` or `s#pattern#replacement#flags` when dealing with paths containing forward slashes.

#### Pattern Matching

Regular expressions in the pattern field enable complex matching scenarios. Literal text matches exactly: `sed 's/old/new/' file` replaces the first occurrence of "old" with "new" on each line. Special characters require escaping: `sed 's/\./period/g' file` replaces all periods with the word "period".

#### Replacement Strategies

The replacement field can contain literal text, special characters, and backreferences. The ampersand `&` represents the entire matched pattern: `sed 's/[0-9][0-9]*/(&)/' file` surrounds numbers with parentheses. Backreferences `\1`, `\2`, etc., reference captured groups from the pattern.

#### Substitution Flags

The `g` flag performs global replacement, affecting all occurrences on each line rather than just the first: `sed 's/old/new/g' file`. Numeric flags specify which occurrence to replace: `sed 's/old/new/2' file` replaces only the second occurrence on each line.

**Key points**: The `p` flag prints lines where substitutions occurred, useful with `-n` for showing only modified lines. The `w filename` flag writes lines with successful substitutions to a specified file.

#### Case-Insensitive Matching

[Inference] Most sed implementations support the `I` flag for case-insensitive matching: `sed 's/pattern/replacement/gI' file`. However, this flag availability varies between sed versions and implementations.

#### Advanced Replacement Techniques

Use `\n` in the replacement string to insert newlines, `\t` for tabs, and `\\` for literal backslashes. The `\l` and `\u` sequences convert the next character to lowercase or uppercase respectively, while `\L` and `\U` affect all following characters until `\E`.

#### Multi-Character Delimiters

When patterns or replacements contain the delimiter character, choose alternative delimiters or escape the conflicts. For file paths, use `sed 's|/old/path|/new/path|g' file` to avoid escaping forward slashes.

### Line Manipulation

Line manipulation commands provide comprehensive control over text structure, enabling insertion, deletion, and modification of entire lines.

#### Line Deletion

The delete command `d` removes entire lines from the output stream. Apply deletion to specific line numbers: `sed '3d' file` removes line 3. Delete ranges using `sed '2,5d' file` to remove lines 2 through 5. Pattern-based deletion removes lines matching regular expressions: `sed '/^#/d' file` deletes comment lines starting with hash symbols.

#### Line Insertion and Appending

The append command `a\` adds text after specified lines: `sed '3a\New line text' file` inserts "New line text" after line 3. The insert command `i\` adds text before lines: `sed '1i\Header text' file` inserts "Header text" before the first line.

#### Line Replacement

The change command `c\` replaces entire lines with new text: `sed '2c\Replacement line' file` replaces line 2 with "Replacement line". This command works with addresses and patterns: `sed '/pattern/c\New text' file` replaces all lines containing the pattern.

**Key points**: Multi-line insertions require backslash escaping at line endings: `sed '1i\Line 1\nLine 2\nLine 3' file`. Each `\n` creates a new line in the output.

#### Line Numbering

The `=` command prints line numbers: `sed '=' file` displays line numbers before each line. Combine with other commands for selective numbering: `sed '/pattern/=' file` numbers only lines matching the pattern.

#### Line Duplication

Duplicate lines using the `p` print command with specific addresses: `sed '3p' file` prints line 3 twice (once automatically, once explicitly). Use `-n` to suppress automatic printing for precise control: `sed -n '3p' file` prints only line 3.

#### Empty Line Handling

Remove empty lines using `sed '/^$/d' file` where `^$` matches lines containing only the beginning and end anchors. Insert empty lines with `sed 's/pattern/&\n/' file` to add newlines after pattern matches.

#### Line Joining and Splitting

The `N` command appends the next line to the pattern space, enabling multi-line operations. Use `sed 'N;s/\n/ /' file` to join consecutive lines with spaces. The `G` command appends the hold space to the pattern space, typically adding empty lines between text lines.

### Multiple Commands

Multiple command execution enables complex text transformations by combining operations in single sed invocations.

#### Command Separation

Separate multiple commands using semicolons: `sed 's/old/new/g; /pattern/d' file` performs substitution followed by deletion. Alternatively, use the `-e` option for each command: `sed -e 's/old/new/g' -e '/pattern/d' file`.

#### Script Files

Store complex command sequences in script files for reusability. Create a file containing sed commands, one per line, and execute with `sed -f script.sed file`. Script files support comments using `#` at line beginnings.

#### Command Grouping

Group commands using braces to apply multiple operations to specific addresses: `sed '/pattern/{s/old/new/g; s/foo/bar/g;}' file` applies both substitutions only to lines matching the pattern.

#### Conditional Execution

Use the `t` command for conditional branching based on successful substitutions: `sed 's/pattern/replacement/; t skip; s/default/other/; :skip' file`. The `t` command jumps to a label when the preceding substitution succeeds.

**Key points**: Labels in sed scripts use colon syntax: `:label_name`. The `b` command provides unconditional branching to labels, while `t` branches only after successful substitutions.

#### Hold Space Operations

The hold space provides auxiliary storage for complex multi-line operations. The `h` command copies the pattern space to hold space, `H` appends to hold space, `g` copies hold space to pattern space, and `G` appends hold space to pattern space.

#### Advanced Multi-Command Patterns

Reverse file line order using hold space operations: `sed '1!G;h;$!d' file`. This technique demonstrates complex sed programming by building reversed content in the hold space and outputting only at the end.

#### Pipeline Integration

Combine sed with other commands in pipelines for comprehensive text processing: `grep pattern file | sed 's/old/new/g' | sort | uniq`. Each command in the pipeline processes the output from the previous command.

#### Performance Considerations

Multiple commands in single sed invocations generally perform better than multiple sed processes in pipelines. However, complex scripts may benefit from breaking operations into simpler, more maintainable steps.

**Key points**: Use the `q` command to quit processing after specific conditions, improving performance for large files when only initial lines require processing.

#### Error Handling in Scripts

[Inference] Sed continues processing after errors in individual commands unless the error prevents further execution. Test complex scripts thoroughly with representative data to identify potential failure points.

#### Command Sequencing

The order of multiple commands affects results, particularly when combining substitutions with line deletions. Perform substitutions before deletions to ensure patterns match original content rather than modified text.

**Conclusion**: Stream editing with sed provides powerful text transformation capabilities essential for system administration, data processing, and automation tasks. The combination of addressing, pattern matching, and multiple command execution creates a flexible toolset for complex text manipulation requirements.

**Next steps**: Practice combining sed with other Unix utilities in pipelines, explore advanced features like hold space manipulation for complex transformations, and study sed script development for automated text processing workflows.

---

