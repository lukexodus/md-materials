## SQLite Command-Line Interface (sqlite3)


The sqlite3 command-line program is a powerful tool for interacting with SQLite databases. It provides an interactive shell for executing SQL statements, managing databases, and performing administrative tasks.

**Starting the shell:**

Launch the SQLite shell by typing `sqlite3` followed optionally by a database filename. If no filename is provided, SQLite creates a temporary in-memory database. If a filename is specified but doesn't exist, SQLite creates a new database file. To open an existing database, provide its path: `sqlite3 /path/to/database.db`.

**Basic SQL execution:**

Once in the shell, execute SQL statements by typing them and ending with a semicolon. Multi-line statements are supported - the shell continues accepting input until it encounters a semicolon. Statements can be interrupted using Ctrl+C. The shell displays query results in a default column mode with headers.

**Dot commands:**

The shell includes special meta-commands that begin with a period. These commands control shell behavior and perform administrative functions. Unlike SQL statements, dot commands don't require a semicolon.

`.help` displays a list of all available dot commands with brief descriptions. `.databases` shows all attached databases with their file paths. `.tables` lists all tables in the current database, optionally filtered by pattern. `.schema` displays the CREATE statements for tables and indexes, showing the database structure. `.schema tablename` shows the schema for a specific table.

`.mode` changes the output format. Available modes include csv, column, html, insert, json, line, list, quote, and tabs. The column mode displays results in aligned columns. The csv mode produces comma-separated values suitable for spreadsheet import. The json mode outputs results as JSON arrays.

`.headers on` or `.headers off` controls whether column names appear in query results. `.separator` changes the delimiter for list and csv modes. `.width` sets column widths for column mode output.

`.import FILE TABLE` reads data from a CSV file into a table. `.output FILE` redirects subsequent query output to a file instead of the screen. `.output stdout` returns output to the terminal. `.once FILE` redirects only the next query's output to a file.

`.dump` generates SQL statements that recreate the entire database. `.dump tablename` dumps only a specific table. This creates a backup in SQL format that can be restored by piping it back to sqlite3. `.backup FILE` creates a binary backup of the database to a file.

`.read FILE` executes SQL statements from a file. This is useful for running scripts or restoring database dumps. `.open FILE` closes the current database and opens a different one.

`.exit` or `.quit` terminates the shell session. Ctrl+D also exits on Unix-like systems.

**Configuration:**

The shell reads commands from a .sqliterc file in the user's home directory at startup. This file can contain dot commands to customize the shell environment. Common customizations include setting output mode, enabling headers, and adjusting column widths.

**Performance analysis:**

`.timer on` displays execution time for each SQL statement, useful for performance analysis. `.explain` changes the output mode to display VDBE bytecode instructions. `.eqp on` shows query execution plans before displaying results.

