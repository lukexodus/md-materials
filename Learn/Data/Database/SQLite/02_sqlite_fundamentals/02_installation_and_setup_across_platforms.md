## Installation and Setup Across Platforms


SQLite requires minimal installation effort since it's a library rather than a standalone application. The database engine comes pre-installed on many systems and is embedded in numerous applications.

**Windows:**

SQLite is not pre-installed on Windows. To use the command-line tools, download the precompiled binaries from the official SQLite website. The sqlite-tools package contains sqlite3.exe, which is the command-line interface. Extract the zip file to a directory, optionally adding it to your system PATH for convenient access from any location. No installation wizard or registry modifications are required.

For development purposes, download the appropriate DLL (sqlite3.dll) and header files (sqlite3.h) from the amalgamation package. Many programming languages include SQLite bindings that handle the library automatically.

**macOS:**

SQLite comes pre-installed on macOS systems. The sqlite3 command-line tool is immediately available from the Terminal. To verify installation, run `sqlite3 --version`. The pre-installed version may not be the latest release. For the newest version, install through Homebrew using `brew install sqlite3`, or download binaries directly from the SQLite website.

**Linux:**

Most Linux distributions include SQLite by default. On Debian-based systems (Ubuntu, Mint), install or update using `sudo apt-get install sqlite3`. On Red Hat-based systems (Fedora, CentOS), use `sudo yum install sqlite` or `sudo dnf install sqlite`. On Arch Linux, use `sudo pacman -S sqlite`.

For development, install the development package that includes header files. On Debian-based systems, this is `libsqlite3-dev`. On Red Hat-based systems, use `sqlite-devel`.

**Mobile platforms:**

Both iOS and Android include SQLite as part of their core system libraries. On iOS, SQLite is available through the libsqlite3 library. On Android, SQLite is accessible through the android.database.sqlite package. Applications can use SQLite without additional installation or bundling.

**Verification:**

After installation, verify SQLite is working by opening a terminal or command prompt and typing `sqlite3 --version`. This displays the version number and compilation options. To test basic functionality, create a temporary in-memory database by typing `sqlite3 :memory:` followed by a simple SQL command like `SELECT sqlite_version();`.

